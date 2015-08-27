
obj/user/faultalloc:     file format elf32-i386


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
  800040:	68 80 10 80 00       	push   $0x801080
  800045:	e8 b1 01 00 00       	call   8001fb <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 2d 0b 00 00       	call   800b8b <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 10 80 00       	push   $0x8010a0
  80006f:	6a 0e                	push   $0xe
  800071:	68 8a 10 80 00       	push   $0x80108a
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 10 80 00       	push   $0x8010cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 a6 06 00 00       	call   80072f <snprintf>
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
  80009c:	e8 99 0c 00 00       	call   800d3a <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 10 80 00       	push   $0x80109c
  8000ae:	e8 48 01 00 00       	call   8001fb <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 10 80 00       	push   $0x80109c
  8000c0:	e8 36 01 00 00       	call   8001fb <cprintf>
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
  8000d5:	e8 73 0a 00 00       	call   800b4d <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 ef 09 00 00       	call   800b0c <sys_env_destroy>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 18 0a 00 00       	call   800b4d <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 f8 10 80 00       	push   $0x8010f8
  800145:	e8 b1 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 54 00 00 00       	call   8001aa <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 9e 10 80 00 	movl   $0x80109e,(%esp)
  80015d:	e8 99 00 00 00       	call   8001fb <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 37 09 00 00       	call   800acf <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 4f 01 00 00       	call   80032d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 dc 08 00 00       	call   800acf <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 d1                	mov    %edx,%ecx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
  80022d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800233:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80023d:	72 05                	jb     800244 <printnum+0x35>
  80023f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800242:	77 3e                	ja     800282 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	53                   	push   %ebx
  80024e:	50                   	push   %eax
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 6d 0b 00 00       	call   800dd0 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 13                	jmp    800289 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 eb 01             	sub    $0x1,%ebx
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f ed                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 5f 0c 00 00       	call   800f00 <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 1b 11 80 00 	movsbl 0x80111b(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff d7                	call   *%edi
  8002ae:	83 c4 10             	add    $0x10,%esp
}
  8002b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bc:	83 fa 01             	cmp    $0x1,%edx
  8002bf:	7e 0e                	jle    8002cf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	8b 52 04             	mov    0x4(%edx),%edx
  8002cd:	eb 22                	jmp    8002f1 <getuint+0x38>
	else if (lflag)
  8002cf:	85 d2                	test   %edx,%edx
  8002d1:	74 10                	je     8002e3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e1:	eb 0e                	jmp    8002f1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1b>
		*b->buf++ = ch;
  800304:	8d 4a 01             	lea    0x1(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	88 02                	mov    %al,(%edx)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 10             	pushl  0x10(%ebp)
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	e8 05 00 00 00       	call   80032d <vprintfmt>
	va_end(ap);
  800328:	83 c4 10             	add    $0x10,%esp
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
  800336:	8b 75 08             	mov    0x8(%ebp),%esi
  800339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033f:	eb 12                	jmp    800353 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800341:	85 c0                	test   %eax,%eax
  800343:	0f 84 90 03 00 00    	je     8006d9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	53                   	push   %ebx
  80034d:	50                   	push   %eax
  80034e:	ff d6                	call   *%esi
  800350:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800353:	83 c7 01             	add    $0x1,%edi
  800356:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035a:	83 f8 25             	cmp    $0x25,%eax
  80035d:	75 e2                	jne    800341 <vprintfmt+0x14>
  80035f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800363:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800371:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	eb 07                	jmp    800386 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800382:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8d 47 01             	lea    0x1(%edi),%eax
  800389:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038c:	0f b6 07             	movzbl (%edi),%eax
  80038f:	0f b6 c8             	movzbl %al,%ecx
  800392:	83 e8 23             	sub    $0x23,%eax
  800395:	3c 55                	cmp    $0x55,%al
  800397:	0f 87 21 03 00 00    	ja     8006be <vprintfmt+0x391>
  80039d:	0f b6 c0             	movzbl %al,%eax
  8003a0:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003aa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ae:	eb d6                	jmp    800386 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003be:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 39                	ja     800406 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d0:	eb e9                	jmp    8003bb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e3:	eb 27                	jmp    80040c <vprintfmt+0xdf>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	0f 49 c8             	cmovns %eax,%ecx
  8003f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	eb 8c                	jmp    800386 <vprintfmt+0x59>
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800404:	eb 80                	jmp    800386 <vprintfmt+0x59>
  800406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800409:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800410:	0f 89 70 ff ff ff    	jns    800386 <vprintfmt+0x59>
				width = precision, precision = -1;
  800416:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800419:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800423:	e9 5e ff ff ff       	jmp    800386 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800428:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042e:	e9 53 ff ff ff       	jmp    800386 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 30                	pushl  (%eax)
  800442:	ff d6                	call   *%esi
			break;
  800444:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044a:	e9 04 ff ff ff       	jmp    800353 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	99                   	cltd   
  80045b:	31 d0                	xor    %edx,%eax
  80045d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045f:	83 f8 09             	cmp    $0x9,%eax
  800462:	7f 0b                	jg     80046f <vprintfmt+0x142>
  800464:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	75 18                	jne    800487 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046f:	50                   	push   %eax
  800470:	68 33 11 80 00       	push   $0x801133
  800475:	53                   	push   %ebx
  800476:	56                   	push   %esi
  800477:	e8 94 fe ff ff       	call   800310 <printfmt>
  80047c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800482:	e9 cc fe ff ff       	jmp    800353 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800487:	52                   	push   %edx
  800488:	68 3c 11 80 00       	push   $0x80113c
  80048d:	53                   	push   %ebx
  80048e:	56                   	push   %esi
  80048f:	e8 7c fe ff ff       	call   800310 <printfmt>
  800494:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049a:	e9 b4 fe ff ff       	jmp    800353 <vprintfmt+0x26>
  80049f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b3:	85 ff                	test   %edi,%edi
  8004b5:	ba 2c 11 80 00       	mov    $0x80112c,%edx
  8004ba:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c1:	0f 84 92 00 00 00    	je     800559 <vprintfmt+0x22c>
  8004c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004cb:	0f 8e 96 00 00 00    	jle    800567 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	51                   	push   %ecx
  8004d5:	57                   	push   %edi
  8004d6:	e8 86 02 00 00       	call   800761 <strnlen>
  8004db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004de:	29 c1                	sub    %eax,%ecx
  8004e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	eb 0f                	jmp    800503 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 ef 01             	sub    $0x1,%edi
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 ff                	test   %edi,%edi
  800505:	7f ed                	jg     8004f4 <vprintfmt+0x1c7>
  800507:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	0f 49 c1             	cmovns %ecx,%eax
  800517:	29 c1                	sub    %eax,%ecx
  800519:	89 75 08             	mov    %esi,0x8(%ebp)
  80051c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800522:	89 cb                	mov    %ecx,%ebx
  800524:	eb 4d                	jmp    800573 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800526:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052a:	74 1b                	je     800547 <vprintfmt+0x21a>
  80052c:	0f be c0             	movsbl %al,%eax
  80052f:	83 e8 20             	sub    $0x20,%eax
  800532:	83 f8 5e             	cmp    $0x5e,%eax
  800535:	76 10                	jbe    800547 <vprintfmt+0x21a>
					putch('?', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	6a 3f                	push   $0x3f
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 0d                	jmp    800554 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 0c             	pushl  0xc(%ebp)
  80054d:	52                   	push   %edx
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	eb 1a                	jmp    800573 <vprintfmt+0x246>
  800559:	89 75 08             	mov    %esi,0x8(%ebp)
  80055c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800562:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800565:	eb 0c                	jmp    800573 <vprintfmt+0x246>
  800567:	89 75 08             	mov    %esi,0x8(%ebp)
  80056a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800570:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800573:	83 c7 01             	add    $0x1,%edi
  800576:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057a:	0f be d0             	movsbl %al,%edx
  80057d:	85 d2                	test   %edx,%edx
  80057f:	74 23                	je     8005a4 <vprintfmt+0x277>
  800581:	85 f6                	test   %esi,%esi
  800583:	78 a1                	js     800526 <vprintfmt+0x1f9>
  800585:	83 ee 01             	sub    $0x1,%esi
  800588:	79 9c                	jns    800526 <vprintfmt+0x1f9>
  80058a:	89 df                	mov    %ebx,%edi
  80058c:	8b 75 08             	mov    0x8(%ebp),%esi
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	eb 18                	jmp    8005ac <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 20                	push   $0x20
  80059a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 ef 01             	sub    $0x1,%edi
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	eb 08                	jmp    8005ac <vprintfmt+0x27f>
  8005a4:	89 df                	mov    %ebx,%edi
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ac:	85 ff                	test   %edi,%edi
  8005ae:	7f e4                	jg     800594 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 9b fd ff ff       	jmp    800353 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b8:	83 fa 01             	cmp    $0x1,%edx
  8005bb:	7e 16                	jle    8005d3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 08             	lea    0x8(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 50 04             	mov    0x4(%eax),%edx
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d1:	eb 32                	jmp    800605 <vprintfmt+0x2d8>
	else if (lflag)
  8005d3:	85 d2                	test   %edx,%edx
  8005d5:	74 18                	je     8005ef <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 c1                	mov    %eax,%ecx
  8005e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ed:	eb 16                	jmp    800605 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800605:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800608:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800610:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800614:	79 74                	jns    80068a <vprintfmt+0x35d>
				putch('-', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 2d                	push   $0x2d
  80061c:	ff d6                	call   *%esi
				num = -(long long) num;
  80061e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800621:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800624:	f7 d8                	neg    %eax
  800626:	83 d2 00             	adc    $0x0,%edx
  800629:	f7 da                	neg    %edx
  80062b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800633:	eb 55                	jmp    80068a <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 7c fc ff ff       	call   8002b9 <getuint>
			base = 10;
  80063d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800642:	eb 46                	jmp    80068a <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800644:	8d 45 14             	lea    0x14(%ebp),%eax
  800647:	e8 6d fc ff ff       	call   8002b9 <getuint>
                        base = 8;
  80064c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800651:	eb 37                	jmp    80068a <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 30                	push   $0x30
  800659:	ff d6                	call   *%esi
			putch('x', putdat);
  80065b:	83 c4 08             	add    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 78                	push   $0x78
  800661:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800673:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067b:	eb 0d                	jmp    80068a <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 34 fc ff ff       	call   8002b9 <getuint>
			base = 16;
  800685:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068a:	83 ec 0c             	sub    $0xc,%esp
  80068d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800691:	57                   	push   %edi
  800692:	ff 75 e0             	pushl  -0x20(%ebp)
  800695:	51                   	push   %ecx
  800696:	52                   	push   %edx
  800697:	50                   	push   %eax
  800698:	89 da                	mov    %ebx,%edx
  80069a:	89 f0                	mov    %esi,%eax
  80069c:	e8 6e fb ff ff       	call   80020f <printnum>
			break;
  8006a1:	83 c4 20             	add    $0x20,%esp
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a7 fc ff ff       	jmp    800353 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	51                   	push   %ecx
  8006b1:	ff d6                	call   *%esi
			break;
  8006b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b9:	e9 95 fc ff ff       	jmp    800353 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 25                	push   $0x25
  8006c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 03                	jmp    8006ce <vprintfmt+0x3a1>
  8006cb:	83 ef 01             	sub    $0x1,%edi
  8006ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d2:	75 f7                	jne    8006cb <vprintfmt+0x39e>
  8006d4:	e9 7a fc ff ff       	jmp    800353 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5f                   	pop    %edi
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 18             	sub    $0x18,%esp
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 26                	je     800728 <vsnprintf+0x47>
  800702:	85 d2                	test   %edx,%edx
  800704:	7e 22                	jle    800728 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800706:	ff 75 14             	pushl  0x14(%ebp)
  800709:	ff 75 10             	pushl  0x10(%ebp)
  80070c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070f:	50                   	push   %eax
  800710:	68 f3 02 80 00       	push   $0x8002f3
  800715:	e8 13 fc ff ff       	call   80032d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	eb 05                	jmp    80072d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800728:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800738:	50                   	push   %eax
  800739:	ff 75 10             	pushl  0x10(%ebp)
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	ff 75 08             	pushl  0x8(%ebp)
  800742:	e8 9a ff ff ff       	call   8006e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 03                	jmp    800759 <strlen+0x10>
		n++;
  800756:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800759:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075d:	75 f7                	jne    800756 <strlen+0xd>
		n++;
	return n;
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	eb 03                	jmp    800774 <strnlen+0x13>
		n++;
  800771:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	39 c2                	cmp    %eax,%edx
  800776:	74 08                	je     800780 <strnlen+0x1f>
  800778:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077c:	75 f3                	jne    800771 <strnlen+0x10>
  80077e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078c:	89 c2                	mov    %eax,%edx
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	83 c1 01             	add    $0x1,%ecx
  800794:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800798:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079b:	84 db                	test   %bl,%bl
  80079d:	75 ef                	jne    80078e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079f:	5b                   	pop    %ebx
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a9:	53                   	push   %ebx
  8007aa:	e8 9a ff ff ff       	call   800749 <strlen>
  8007af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	01 d8                	add    %ebx,%eax
  8007b7:	50                   	push   %eax
  8007b8:	e8 c5 ff ff ff       	call   800782 <strcpy>
	return dst;
}
  8007bd:	89 d8                	mov    %ebx,%eax
  8007bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	89 f3                	mov    %esi,%ebx
  8007d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	89 f2                	mov    %esi,%edx
  8007d6:	eb 0f                	jmp    8007e7 <strncpy+0x23>
		*dst++ = *src;
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	0f b6 01             	movzbl (%ecx),%eax
  8007de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	39 da                	cmp    %ebx,%edx
  8007e9:	75 ed                	jne    8007d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007eb:	89 f0                	mov    %esi,%eax
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800801:	85 d2                	test   %edx,%edx
  800803:	74 21                	je     800826 <strlcpy+0x35>
  800805:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 09                	jmp    800816 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800816:	39 c2                	cmp    %eax,%edx
  800818:	74 09                	je     800823 <strlcpy+0x32>
  80081a:	0f b6 19             	movzbl (%ecx),%ebx
  80081d:	84 db                	test   %bl,%bl
  80081f:	75 ec                	jne    80080d <strlcpy+0x1c>
  800821:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800823:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800826:	29 f0                	sub    %esi,%eax
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800835:	eb 06                	jmp    80083d <strcmp+0x11>
		p++, q++;
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	84 c0                	test   %al,%al
  800842:	74 04                	je     800848 <strcmp+0x1c>
  800844:	3a 02                	cmp    (%edx),%al
  800846:	74 ef                	je     800837 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800848:	0f b6 c0             	movzbl %al,%eax
  80084b:	0f b6 12             	movzbl (%edx),%edx
  80084e:	29 d0                	sub    %edx,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 c3                	mov    %eax,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800861:	eb 06                	jmp    800869 <strncmp+0x17>
		n--, p++, q++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800869:	39 d8                	cmp    %ebx,%eax
  80086b:	74 15                	je     800882 <strncmp+0x30>
  80086d:	0f b6 08             	movzbl (%eax),%ecx
  800870:	84 c9                	test   %cl,%cl
  800872:	74 04                	je     800878 <strncmp+0x26>
  800874:	3a 0a                	cmp    (%edx),%cl
  800876:	74 eb                	je     800863 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 00             	movzbl (%eax),%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
  800880:	eb 05                	jmp    800887 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	eb 07                	jmp    80089d <strchr+0x13>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 0f                	je     8008a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	0f b6 10             	movzbl (%eax),%edx
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f2                	jne    800896 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	eb 03                	jmp    8008ba <strfind+0xf>
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	74 04                	je     8008c5 <strfind+0x1a>
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	75 f2                	jne    8008b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	74 36                	je     80090d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008dd:	75 28                	jne    800907 <memset+0x40>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 23                	jne    800907 <memset+0x40>
		c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d3                	mov    %edx,%ebx
  8008ea:	c1 e3 08             	shl    $0x8,%ebx
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 18             	shl    $0x18,%esi
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 10             	shl    $0x10,%eax
  8008f7:	09 f0                	or     %esi,%eax
  8008f9:	09 c2                	or     %eax,%edx
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800902:	fc                   	cld    
  800903:	f3 ab                	rep stos %eax,%es:(%edi)
  800905:	eb 06                	jmp    80090d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	fc                   	cld    
  80090b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800922:	39 c6                	cmp    %eax,%esi
  800924:	73 35                	jae    80095b <memmove+0x47>
  800926:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800929:	39 d0                	cmp    %edx,%eax
  80092b:	73 2e                	jae    80095b <memmove+0x47>
		s += n;
		d += n;
  80092d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800930:	89 d6                	mov    %edx,%esi
  800932:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 13                	jne    80094f <memmove+0x3b>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0e                	jne    80094f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb 09                	jmp    800958 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094f:	83 ef 01             	sub    $0x1,%edi
  800952:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800955:	fd                   	std    
  800956:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800958:	fc                   	cld    
  800959:	eb 1d                	jmp    800978 <memmove+0x64>
  80095b:	89 f2                	mov    %esi,%edx
  80095d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	f6 c2 03             	test   $0x3,%dl
  800962:	75 0f                	jne    800973 <memmove+0x5f>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 0a                	jne    800973 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800969:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 05                	jmp    800978 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097f:	ff 75 10             	pushl  0x10(%ebp)
  800982:	ff 75 0c             	pushl  0xc(%ebp)
  800985:	ff 75 08             	pushl  0x8(%ebp)
  800988:	e8 87 ff ff ff       	call   800914 <memmove>
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c6                	mov    %eax,%esi
  80099c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099f:	eb 1a                	jmp    8009bb <memcmp+0x2c>
		if (*s1 != *s2)
  8009a1:	0f b6 08             	movzbl (%eax),%ecx
  8009a4:	0f b6 1a             	movzbl (%edx),%ebx
  8009a7:	38 d9                	cmp    %bl,%cl
  8009a9:	74 0a                	je     8009b5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ab:	0f b6 c1             	movzbl %cl,%eax
  8009ae:	0f b6 db             	movzbl %bl,%ebx
  8009b1:	29 d8                	sub    %ebx,%eax
  8009b3:	eb 0f                	jmp    8009c4 <memcmp+0x35>
		s1++, s2++;
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	39 f0                	cmp    %esi,%eax
  8009bd:	75 e2                	jne    8009a1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d1:	89 c2                	mov    %eax,%edx
  8009d3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d6:	eb 07                	jmp    8009df <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	38 08                	cmp    %cl,(%eax)
  8009da:	74 07                	je     8009e3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	39 d0                	cmp    %edx,%eax
  8009e1:	72 f5                	jb     8009d8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	eb 03                	jmp    8009f6 <strtol+0x11>
		s++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	3c 09                	cmp    $0x9,%al
  8009fb:	74 f6                	je     8009f3 <strtol+0xe>
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f2                	je     8009f3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a01:	3c 2b                	cmp    $0x2b,%al
  800a03:	75 0a                	jne    800a0f <strtol+0x2a>
		s++;
  800a05:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0d:	eb 10                	jmp    800a1f <strtol+0x3a>
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a14:	3c 2d                	cmp    $0x2d,%al
  800a16:	75 07                	jne    800a1f <strtol+0x3a>
		s++, neg = 1;
  800a18:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a1b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	85 db                	test   %ebx,%ebx
  800a21:	0f 94 c0             	sete   %al
  800a24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2a:	75 19                	jne    800a45 <strtol+0x60>
  800a2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2f:	75 14                	jne    800a45 <strtol+0x60>
  800a31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a35:	0f 85 82 00 00 00    	jne    800abd <strtol+0xd8>
		s += 2, base = 16;
  800a3b:	83 c1 02             	add    $0x2,%ecx
  800a3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a43:	eb 16                	jmp    800a5b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a45:	84 c0                	test   %al,%al
  800a47:	74 12                	je     800a5b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a49:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a51:	75 08                	jne    800a5b <strtol+0x76>
		s++, base = 8;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a63:	0f b6 11             	movzbl (%ecx),%edx
  800a66:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	80 fb 09             	cmp    $0x9,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0x93>
			dig = *s - '0';
  800a70:	0f be d2             	movsbl %dl,%edx
  800a73:	83 ea 30             	sub    $0x30,%edx
  800a76:	eb 22                	jmp    800a9a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a78:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 08                	ja     800a8a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 57             	sub    $0x57,%edx
  800a88:	eb 10                	jmp    800a9a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 16                	ja     800aaa <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9d:	7d 0f                	jge    800aae <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa8:	eb b9                	jmp    800a63 <strtol+0x7e>
  800aaa:	89 c2                	mov    %eax,%edx
  800aac:	eb 02                	jmp    800ab0 <strtol+0xcb>
  800aae:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab4:	74 0d                	je     800ac3 <strtol+0xde>
		*endptr = (char *) s;
  800ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab9:	89 0e                	mov    %ecx,(%esi)
  800abb:	eb 06                	jmp    800ac3 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abd:	84 c0                	test   %al,%al
  800abf:	75 92                	jne    800a53 <strtol+0x6e>
  800ac1:	eb 98                	jmp    800a5b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac3:	f7 da                	neg    %edx
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	0f 45 c2             	cmovne %edx,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cgetc>:

int
sys_cgetc(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 01 00 00 00       	mov    $0x1,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	89 cb                	mov    %ecx,%ebx
  800b24:	89 cf                	mov    %ecx,%edi
  800b26:	89 ce                	mov    %ecx,%esi
  800b28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 68 13 80 00       	push   $0x801368
  800b39:	6a 23                	push   $0x23
  800b3b:	68 85 13 80 00       	push   $0x801385
  800b40:	e8 dd f5 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	be 00 00 00 00       	mov    $0x0,%esi
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	89 f7                	mov    %esi,%edi
  800ba9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 68 13 80 00       	push   $0x801368
  800bba:	6a 23                	push   $0x23
  800bbc:	68 85 13 80 00       	push   $0x801385
  800bc1:	e8 5c f5 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be8:	8b 75 18             	mov    0x18(%ebp),%esi
  800beb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 68 13 80 00       	push   $0x801368
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 85 13 80 00       	push   $0x801385
  800c03:	e8 1a f5 ff ff       	call   800122 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 68 13 80 00       	push   $0x801368
  800c3e:	6a 23                	push   $0x23
  800c40:	68 85 13 80 00       	push   $0x801385
  800c45:	e8 d8 f4 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 68 13 80 00       	push   $0x801368
  800c80:	6a 23                	push   $0x23
  800c82:	68 85 13 80 00       	push   $0x801385
  800c87:	e8 96 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 68 13 80 00       	push   $0x801368
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 85 13 80 00       	push   $0x801385
  800cc9:	e8 54 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	be 00 00 00 00       	mov    $0x0,%esi
  800ce1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 0c                	push   $0xc
  800d21:	68 68 13 80 00       	push   $0x801368
  800d26:	6a 23                	push   $0x23
  800d28:	68 85 13 80 00       	push   $0x801385
  800d2d:	e8 f0 f3 ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d40:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d47:	75 2c                	jne    800d75 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	6a 07                	push   $0x7
  800d4e:	68 00 f0 bf ee       	push   $0xeebff000
  800d53:	6a 00                	push   $0x0
  800d55:	e8 31 fe ff ff       	call   800b8b <sys_page_alloc>
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	74 14                	je     800d75 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 94 13 80 00       	push   $0x801394
  800d69:	6a 21                	push   $0x21
  800d6b:	68 f8 13 80 00       	push   $0x8013f8
  800d70:	e8 ad f3 ff ff       	call   800122 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d7d:	83 ec 08             	sub    $0x8,%esp
  800d80:	68 a9 0d 80 00       	push   $0x800da9
  800d85:	6a 00                	push   $0x0
  800d87:	e8 08 ff ff ff       	call   800c94 <sys_env_set_pgfault_upcall>
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	79 14                	jns    800da7 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	68 c0 13 80 00       	push   $0x8013c0
  800d9b:	6a 29                	push   $0x29
  800d9d:	68 f8 13 80 00       	push   $0x8013f8
  800da2:	e8 7b f3 ff ff       	call   800122 <_panic>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800da9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800daa:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800daf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800db4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800db9:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800dbd:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800dc1:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800dc3:	83 c4 08             	add    $0x8,%esp
        popal
  800dc6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800dc7:	83 c4 04             	add    $0x4,%esp
        popfl
  800dca:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800dcb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800dcc:	c3                   	ret    
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	83 ec 10             	sub    $0x10,%esp
  800dd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800dda:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800dde:	8b 74 24 24          	mov    0x24(%esp),%esi
  800de2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800de6:	85 d2                	test   %edx,%edx
  800de8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dec:	89 34 24             	mov    %esi,(%esp)
  800def:	89 c8                	mov    %ecx,%eax
  800df1:	75 35                	jne    800e28 <__udivdi3+0x58>
  800df3:	39 f1                	cmp    %esi,%ecx
  800df5:	0f 87 bd 00 00 00    	ja     800eb8 <__udivdi3+0xe8>
  800dfb:	85 c9                	test   %ecx,%ecx
  800dfd:	89 cd                	mov    %ecx,%ebp
  800dff:	75 0b                	jne    800e0c <__udivdi3+0x3c>
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f5                	div    %ebp
  800e12:	89 c6                	mov    %eax,%esi
  800e14:	89 f8                	mov    %edi,%eax
  800e16:	f7 f5                	div    %ebp
  800e18:	89 f2                	mov    %esi,%edx
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    
  800e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e28:	3b 14 24             	cmp    (%esp),%edx
  800e2b:	77 7b                	ja     800ea8 <__udivdi3+0xd8>
  800e2d:	0f bd f2             	bsr    %edx,%esi
  800e30:	83 f6 1f             	xor    $0x1f,%esi
  800e33:	0f 84 97 00 00 00    	je     800ed0 <__udivdi3+0x100>
  800e39:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 f1                	mov    %esi,%ecx
  800e42:	29 f5                	sub    %esi,%ebp
  800e44:	d3 e7                	shl    %cl,%edi
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	89 e9                	mov    %ebp,%ecx
  800e4a:	d3 ea                	shr    %cl,%edx
  800e4c:	89 f1                	mov    %esi,%ecx
  800e4e:	09 fa                	or     %edi,%edx
  800e50:	8b 3c 24             	mov    (%esp),%edi
  800e53:	d3 e0                	shl    %cl,%eax
  800e55:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e59:	89 e9                	mov    %ebp,%ecx
  800e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e63:	89 fa                	mov    %edi,%edx
  800e65:	d3 ea                	shr    %cl,%edx
  800e67:	89 f1                	mov    %esi,%ecx
  800e69:	d3 e7                	shl    %cl,%edi
  800e6b:	89 e9                	mov    %ebp,%ecx
  800e6d:	d3 e8                	shr    %cl,%eax
  800e6f:	09 c7                	or     %eax,%edi
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	f7 74 24 08          	divl   0x8(%esp)
  800e77:	89 d5                	mov    %edx,%ebp
  800e79:	89 c7                	mov    %eax,%edi
  800e7b:	f7 64 24 0c          	mull   0xc(%esp)
  800e7f:	39 d5                	cmp    %edx,%ebp
  800e81:	89 14 24             	mov    %edx,(%esp)
  800e84:	72 11                	jb     800e97 <__udivdi3+0xc7>
  800e86:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e8a:	89 f1                	mov    %esi,%ecx
  800e8c:	d3 e2                	shl    %cl,%edx
  800e8e:	39 c2                	cmp    %eax,%edx
  800e90:	73 5e                	jae    800ef0 <__udivdi3+0x120>
  800e92:	3b 2c 24             	cmp    (%esp),%ebp
  800e95:	75 59                	jne    800ef0 <__udivdi3+0x120>
  800e97:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e9a:	31 f6                	xor    %esi,%esi
  800e9c:	89 f2                	mov    %esi,%edx
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	31 f6                	xor    %esi,%esi
  800eaa:	31 c0                	xor    %eax,%eax
  800eac:	89 f2                	mov    %esi,%edx
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
  800eb8:	89 f2                	mov    %esi,%edx
  800eba:	31 f6                	xor    %esi,%esi
  800ebc:	89 f8                	mov    %edi,%eax
  800ebe:	f7 f1                	div    %ecx
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ed4:	76 0b                	jbe    800ee1 <__udivdi3+0x111>
  800ed6:	31 c0                	xor    %eax,%eax
  800ed8:	3b 14 24             	cmp    (%esp),%edx
  800edb:	0f 83 37 ff ff ff    	jae    800e18 <__udivdi3+0x48>
  800ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee6:	e9 2d ff ff ff       	jmp    800e18 <__udivdi3+0x48>
  800eeb:	90                   	nop
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	31 f6                	xor    %esi,%esi
  800ef4:	e9 1f ff ff ff       	jmp    800e18 <__udivdi3+0x48>
  800ef9:	66 90                	xchg   %ax,%ax
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 20             	sub    $0x20,%esp
  800f06:	8b 44 24 34          	mov    0x34(%esp),%eax
  800f0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800f20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f28:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	89 c2                	mov    %eax,%edx
  800f30:	75 1e                	jne    800f50 <__umoddi3+0x50>
  800f32:	39 f7                	cmp    %esi,%edi
  800f34:	76 52                	jbe    800f88 <__umoddi3+0x88>
  800f36:	89 c8                	mov    %ecx,%eax
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	f7 f7                	div    %edi
  800f3c:	89 d0                	mov    %edx,%eax
  800f3e:	31 d2                	xor    %edx,%edx
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    
  800f47:	89 f6                	mov    %esi,%esi
  800f49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f50:	39 f0                	cmp    %esi,%eax
  800f52:	77 5c                	ja     800fb0 <__umoddi3+0xb0>
  800f54:	0f bd e8             	bsr    %eax,%ebp
  800f57:	83 f5 1f             	xor    $0x1f,%ebp
  800f5a:	75 64                	jne    800fc0 <__umoddi3+0xc0>
  800f5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800f60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800f64:	0f 86 f6 00 00 00    	jbe    801060 <__umoddi3+0x160>
  800f6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800f6e:	0f 82 ec 00 00 00    	jb     801060 <__umoddi3+0x160>
  800f74:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f78:	8b 54 24 18          	mov    0x18(%esp),%edx
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	85 ff                	test   %edi,%edi
  800f8a:	89 fd                	mov    %edi,%ebp
  800f8c:	75 0b                	jne    800f99 <__umoddi3+0x99>
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f7                	div    %edi
  800f97:	89 c5                	mov    %eax,%ebp
  800f99:	8b 44 24 10          	mov    0x10(%esp),%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	f7 f5                	div    %ebp
  800fa1:	89 c8                	mov    %ecx,%eax
  800fa3:	f7 f5                	div    %ebp
  800fa5:	eb 95                	jmp    800f3c <__umoddi3+0x3c>
  800fa7:	89 f6                	mov    %esi,%esi
  800fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc5:	89 e9                	mov    %ebp,%ecx
  800fc7:	29 e8                	sub    %ebp,%eax
  800fc9:	d3 e2                	shl    %cl,%edx
  800fcb:	89 c7                	mov    %eax,%edi
  800fcd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fd5:	89 f9                	mov    %edi,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 c1                	mov    %eax,%ecx
  800fdb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fdf:	09 d1                	or     %edx,%ecx
  800fe1:	89 fa                	mov    %edi,%edx
  800fe3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe7:	89 e9                	mov    %ebp,%ecx
  800fe9:	d3 e0                	shl    %cl,%eax
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	89 e9                	mov    %ebp,%ecx
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ffd:	d3 e6                	shl    %cl,%esi
  800fff:	89 d1                	mov    %edx,%ecx
  801001:	89 fa                	mov    %edi,%edx
  801003:	d3 e8                	shr    %cl,%eax
  801005:	89 e9                	mov    %ebp,%ecx
  801007:	09 f0                	or     %esi,%eax
  801009:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80100d:	f7 74 24 10          	divl   0x10(%esp)
  801011:	d3 e6                	shl    %cl,%esi
  801013:	89 d1                	mov    %edx,%ecx
  801015:	f7 64 24 0c          	mull   0xc(%esp)
  801019:	39 d1                	cmp    %edx,%ecx
  80101b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80101f:	89 d7                	mov    %edx,%edi
  801021:	89 c6                	mov    %eax,%esi
  801023:	72 0a                	jb     80102f <__umoddi3+0x12f>
  801025:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801029:	73 10                	jae    80103b <__umoddi3+0x13b>
  80102b:	39 d1                	cmp    %edx,%ecx
  80102d:	75 0c                	jne    80103b <__umoddi3+0x13b>
  80102f:	89 d7                	mov    %edx,%edi
  801031:	89 c6                	mov    %eax,%esi
  801033:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801037:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80103b:	89 ca                	mov    %ecx,%edx
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801043:	29 f0                	sub    %esi,%eax
  801045:	19 fa                	sbb    %edi,%edx
  801047:	d3 e8                	shr    %cl,%eax
  801049:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80104e:	89 d7                	mov    %edx,%edi
  801050:	d3 e7                	shl    %cl,%edi
  801052:	89 e9                	mov    %ebp,%ecx
  801054:	09 f8                	or     %edi,%eax
  801056:	d3 ea                	shr    %cl,%edx
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	8b 74 24 10          	mov    0x10(%esp),%esi
  801064:	29 f9                	sub    %edi,%ecx
  801066:	19 c6                	sbb    %eax,%esi
  801068:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80106c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801070:	e9 ff fe ff ff       	jmp    800f74 <__umoddi3+0x74>
