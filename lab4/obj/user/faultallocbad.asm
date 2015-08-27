
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 9c 01 00 00       	call   8001e6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 10 80 00       	push   $0x8010a0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 10 80 00       	push   $0x80108a
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 10 80 00       	push   $0x8010cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 91 06 00 00       	call   80071a <snprintf>
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
  80009c:	e8 84 0c 00 00       	call   800d25 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
  8000b0:	83 c4 10             	add    $0x10,%esp
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
  8000f1:	83 c4 10             	add    $0x10,%esp
}
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 ef 09 00 00       	call   800af7 <sys_env_destroy>
  800108:	83 c4 10             	add    $0x10,%esp
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 18 0a 00 00       	call   800b38 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 f8 10 80 00       	push   $0x8010f8
  800130:	e8 b1 00 00 00       	call   8001e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 54 00 00 00       	call   800195 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 88 10 80 00 	movl   $0x801088,(%esp)
  800148:	e8 99 00 00 00       	call   8001e6 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 1a                	jne    80018c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	68 ff 00 00 00       	push   $0xff
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 37 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  800183:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800189:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a5:	00 00 00 
	b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	68 53 01 80 00       	push   $0x800153
  8001c4:	e8 4f 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	e8 dc 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 9d ff ff ff       	call   800195 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 1c             	sub    $0x1c,%esp
  800203:	89 c7                	mov    %eax,%edi
  800205:	89 d6                	mov    %edx,%esi
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 d1                	mov    %edx,%ecx
  80020f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800212:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800215:	8b 45 10             	mov    0x10(%ebp),%eax
  800218:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800225:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800228:	72 05                	jb     80022f <printnum+0x35>
  80022a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80022d:	77 3e                	ja     80026d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	ff 75 18             	pushl  0x18(%ebp)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	53                   	push   %ebx
  800239:	50                   	push   %eax
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 72 0b 00 00       	call   800dc0 <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 f2                	mov    %esi,%edx
  800255:	89 f8                	mov    %edi,%eax
  800257:	e8 9e ff ff ff       	call   8001fa <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 13                	jmp    800274 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d7                	call   *%edi
  80026a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f ed                	jg     800261 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	56                   	push   %esi
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	e8 64 0c 00 00       	call   800ef0 <__umoddi3>
  80028c:	83 c4 14             	add    $0x14,%esp
  80028f:	0f be 80 1b 11 80 00 	movsbl 0x80111b(%eax),%eax
  800296:	50                   	push   %eax
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    

008002a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a7:	83 fa 01             	cmp    $0x1,%edx
  8002aa:	7e 0e                	jle    8002ba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	8b 52 04             	mov    0x4(%edx),%edx
  8002b8:	eb 22                	jmp    8002dc <getuint+0x38>
	else if (lflag)
  8002ba:	85 d2                	test   %edx,%edx
  8002bc:	74 10                	je     8002ce <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cc:	eb 0e                	jmp    8002dc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800304:	50                   	push   %eax
  800305:	ff 75 10             	pushl  0x10(%ebp)
  800308:	ff 75 0c             	pushl  0xc(%ebp)
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	e8 05 00 00 00       	call   800318 <vprintfmt>
	va_end(ap);
  800313:	83 c4 10             	add    $0x10,%esp
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 2c             	sub    $0x2c,%esp
  800321:	8b 75 08             	mov    0x8(%ebp),%esi
  800324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800327:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032a:	eb 12                	jmp    80033e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032c:	85 c0                	test   %eax,%eax
  80032e:	0f 84 90 03 00 00    	je     8006c4 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	53                   	push   %ebx
  800338:	50                   	push   %eax
  800339:	ff d6                	call   *%esi
  80033b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033e:	83 c7 01             	add    $0x1,%edi
  800341:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800345:	83 f8 25             	cmp    $0x25,%eax
  800348:	75 e2                	jne    80032c <vprintfmt+0x14>
  80034a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800355:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
  800368:	eb 07                	jmp    800371 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8d 47 01             	lea    0x1(%edi),%eax
  800374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800377:	0f b6 07             	movzbl (%edi),%eax
  80037a:	0f b6 c8             	movzbl %al,%ecx
  80037d:	83 e8 23             	sub    $0x23,%eax
  800380:	3c 55                	cmp    $0x55,%al
  800382:	0f 87 21 03 00 00    	ja     8006a9 <vprintfmt+0x391>
  800388:	0f b6 c0             	movzbl %al,%eax
  80038b:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800395:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800399:	eb d6                	jmp    800371 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ad:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b3:	83 fa 09             	cmp    $0x9,%edx
  8003b6:	77 39                	ja     8003f1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bb:	eb e9                	jmp    8003a6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 27                	jmp    8003f7 <vprintfmt+0xdf>
  8003d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003da:	0f 49 c8             	cmovns %eax,%ecx
  8003dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	eb 8c                	jmp    800371 <vprintfmt+0x59>
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ef:	eb 80                	jmp    800371 <vprintfmt+0x59>
  8003f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 89 70 ff ff ff    	jns    800371 <vprintfmt+0x59>
				width = precision, precision = -1;
  800401:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800407:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040e:	e9 5e ff ff ff       	jmp    800371 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800419:	e9 53 ff ff ff       	jmp    800371 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 50 04             	lea    0x4(%eax),%edx
  800424:	89 55 14             	mov    %edx,0x14(%ebp)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 30                	pushl  (%eax)
  80042d:	ff d6                	call   *%esi
			break;
  80042f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800435:	e9 04 ff ff ff       	jmp    80033e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	8b 00                	mov    (%eax),%eax
  800445:	99                   	cltd   
  800446:	31 d0                	xor    %edx,%eax
  800448:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044a:	83 f8 09             	cmp    $0x9,%eax
  80044d:	7f 0b                	jg     80045a <vprintfmt+0x142>
  80044f:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	75 18                	jne    800472 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045a:	50                   	push   %eax
  80045b:	68 33 11 80 00       	push   $0x801133
  800460:	53                   	push   %ebx
  800461:	56                   	push   %esi
  800462:	e8 94 fe ff ff       	call   8002fb <printfmt>
  800467:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046d:	e9 cc fe ff ff       	jmp    80033e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800472:	52                   	push   %edx
  800473:	68 3c 11 80 00       	push   $0x80113c
  800478:	53                   	push   %ebx
  800479:	56                   	push   %esi
  80047a:	e8 7c fe ff ff       	call   8002fb <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800485:	e9 b4 fe ff ff       	jmp    80033e <vprintfmt+0x26>
  80048a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80048d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800490:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	ba 2c 11 80 00       	mov    $0x80112c,%edx
  8004a5:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ac:	0f 84 92 00 00 00    	je     800544 <vprintfmt+0x22c>
  8004b2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004b6:	0f 8e 96 00 00 00    	jle    800552 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	51                   	push   %ecx
  8004c0:	57                   	push   %edi
  8004c1:	e8 86 02 00 00       	call   80074c <strnlen>
  8004c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c9:	29 c1                	sub    %eax,%ecx
  8004cb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004db:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	eb 0f                	jmp    8004ee <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	83 ef 01             	sub    $0x1,%edi
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	85 ff                	test   %edi,%edi
  8004f0:	7f ed                	jg     8004df <vprintfmt+0x1c7>
  8004f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f8:	85 c9                	test   %ecx,%ecx
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	0f 49 c1             	cmovns %ecx,%eax
  800502:	29 c1                	sub    %eax,%ecx
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	89 cb                	mov    %ecx,%ebx
  80050f:	eb 4d                	jmp    80055e <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800515:	74 1b                	je     800532 <vprintfmt+0x21a>
  800517:	0f be c0             	movsbl %al,%eax
  80051a:	83 e8 20             	sub    $0x20,%eax
  80051d:	83 f8 5e             	cmp    $0x5e,%eax
  800520:	76 10                	jbe    800532 <vprintfmt+0x21a>
					putch('?', putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	ff 75 0c             	pushl  0xc(%ebp)
  800528:	6a 3f                	push   $0x3f
  80052a:	ff 55 08             	call   *0x8(%ebp)
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	eb 0d                	jmp    80053f <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	52                   	push   %edx
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053f:	83 eb 01             	sub    $0x1,%ebx
  800542:	eb 1a                	jmp    80055e <vprintfmt+0x246>
  800544:	89 75 08             	mov    %esi,0x8(%ebp)
  800547:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800550:	eb 0c                	jmp    80055e <vprintfmt+0x246>
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	83 c7 01             	add    $0x1,%edi
  800561:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800565:	0f be d0             	movsbl %al,%edx
  800568:	85 d2                	test   %edx,%edx
  80056a:	74 23                	je     80058f <vprintfmt+0x277>
  80056c:	85 f6                	test   %esi,%esi
  80056e:	78 a1                	js     800511 <vprintfmt+0x1f9>
  800570:	83 ee 01             	sub    $0x1,%esi
  800573:	79 9c                	jns    800511 <vprintfmt+0x1f9>
  800575:	89 df                	mov    %ebx,%edi
  800577:	8b 75 08             	mov    0x8(%ebp),%esi
  80057a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057d:	eb 18                	jmp    800597 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	6a 20                	push   $0x20
  800585:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	83 ef 01             	sub    $0x1,%edi
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	eb 08                	jmp    800597 <vprintfmt+0x27f>
  80058f:	89 df                	mov    %ebx,%edi
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800597:	85 ff                	test   %edi,%edi
  800599:	7f e4                	jg     80057f <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059e:	e9 9b fd ff ff       	jmp    80033e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a3:	83 fa 01             	cmp    $0x1,%edx
  8005a6:	7e 16                	jle    8005be <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 08             	lea    0x8(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 50 04             	mov    0x4(%eax),%edx
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bc:	eb 32                	jmp    8005f0 <vprintfmt+0x2d8>
	else if (lflag)
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	74 18                	je     8005da <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 c1                	mov    %eax,%ecx
  8005d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d8:	eb 16                	jmp    8005f0 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ff:	79 74                	jns    800675 <vprintfmt+0x35d>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80060f:	f7 d8                	neg    %eax
  800611:	83 d2 00             	adc    $0x0,%edx
  800614:	f7 da                	neg    %edx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80061e:	eb 55                	jmp    800675 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 7c fc ff ff       	call   8002a4 <getuint>
			base = 10;
  800628:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80062d:	eb 46                	jmp    800675 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 6d fc ff ff       	call   8002a4 <getuint>
                        base = 8;
  800637:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80063c:	eb 37                	jmp    800675 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 30                	push   $0x30
  800644:	ff d6                	call   *%esi
			putch('x', putdat);
  800646:	83 c4 08             	add    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 78                	push   $0x78
  80064c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800661:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 34 fc ff ff       	call   8002a4 <getuint>
			base = 16;
  800670:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800675:	83 ec 0c             	sub    $0xc,%esp
  800678:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067c:	57                   	push   %edi
  80067d:	ff 75 e0             	pushl  -0x20(%ebp)
  800680:	51                   	push   %ecx
  800681:	52                   	push   %edx
  800682:	50                   	push   %eax
  800683:	89 da                	mov    %ebx,%edx
  800685:	89 f0                	mov    %esi,%eax
  800687:	e8 6e fb ff ff       	call   8001fa <printnum>
			break;
  80068c:	83 c4 20             	add    $0x20,%esp
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800692:	e9 a7 fc ff ff       	jmp    80033e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	51                   	push   %ecx
  80069c:	ff d6                	call   *%esi
			break;
  80069e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a4:	e9 95 fc ff ff       	jmp    80033e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 25                	push   $0x25
  8006af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 03                	jmp    8006b9 <vprintfmt+0x3a1>
  8006b6:	83 ef 01             	sub    $0x1,%edi
  8006b9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bd:	75 f7                	jne    8006b6 <vprintfmt+0x39e>
  8006bf:	e9 7a fc ff ff       	jmp    80033e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5f                   	pop    %edi
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 18             	sub    $0x18,%esp
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006db:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006df:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 26                	je     800713 <vsnprintf+0x47>
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	7e 22                	jle    800713 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f1:	ff 75 14             	pushl  0x14(%ebp)
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	68 de 02 80 00       	push   $0x8002de
  800700:	e8 13 fc ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800705:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800708:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 05                	jmp    800718 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800723:	50                   	push   %eax
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	ff 75 08             	pushl  0x8(%ebp)
  80072d:	e8 9a ff ff ff       	call   8006cc <vsnprintf>
	va_end(ap);

	return rc;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	eb 03                	jmp    800744 <strlen+0x10>
		n++;
  800741:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800748:	75 f7                	jne    800741 <strlen+0xd>
		n++;
	return n;
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	ba 00 00 00 00       	mov    $0x0,%edx
  80075a:	eb 03                	jmp    80075f <strnlen+0x13>
		n++;
  80075c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 c2                	cmp    %eax,%edx
  800761:	74 08                	je     80076b <strnlen+0x1f>
  800763:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800767:	75 f3                	jne    80075c <strnlen+0x10>
  800769:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	53                   	push   %ebx
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800777:	89 c2                	mov    %eax,%edx
  800779:	83 c2 01             	add    $0x1,%edx
  80077c:	83 c1 01             	add    $0x1,%ecx
  80077f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800783:	88 5a ff             	mov    %bl,-0x1(%edx)
  800786:	84 db                	test   %bl,%bl
  800788:	75 ef                	jne    800779 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078a:	5b                   	pop    %ebx
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	53                   	push   %ebx
  800791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800794:	53                   	push   %ebx
  800795:	e8 9a ff ff ff       	call   800734 <strlen>
  80079a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079d:	ff 75 0c             	pushl  0xc(%ebp)
  8007a0:	01 d8                	add    %ebx,%eax
  8007a2:	50                   	push   %eax
  8007a3:	e8 c5 ff ff ff       	call   80076d <strcpy>
	return dst;
}
  8007a8:	89 d8                	mov    %ebx,%eax
  8007aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ba:	89 f3                	mov    %esi,%ebx
  8007bc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	89 f2                	mov    %esi,%edx
  8007c1:	eb 0f                	jmp    8007d2 <strncpy+0x23>
		*dst++ = *src;
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	0f b6 01             	movzbl (%ecx),%eax
  8007c9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007cf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	39 da                	cmp    %ebx,%edx
  8007d4:	75 ed                	jne    8007c3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	74 21                	je     800811 <strlcpy+0x35>
  8007f0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f4:	89 f2                	mov    %esi,%edx
  8007f6:	eb 09                	jmp    800801 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f8:	83 c2 01             	add    $0x1,%edx
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800801:	39 c2                	cmp    %eax,%edx
  800803:	74 09                	je     80080e <strlcpy+0x32>
  800805:	0f b6 19             	movzbl (%ecx),%ebx
  800808:	84 db                	test   %bl,%bl
  80080a:	75 ec                	jne    8007f8 <strlcpy+0x1c>
  80080c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800811:	29 f0                	sub    %esi,%eax
}
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800820:	eb 06                	jmp    800828 <strcmp+0x11>
		p++, q++;
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	84 c0                	test   %al,%al
  80082d:	74 04                	je     800833 <strcmp+0x1c>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	74 ef                	je     800822 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 c0             	movzbl %al,%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
  800847:	89 c3                	mov    %eax,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strncmp+0x17>
		n--, p++, q++;
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800854:	39 d8                	cmp    %ebx,%eax
  800856:	74 15                	je     80086d <strncmp+0x30>
  800858:	0f b6 08             	movzbl (%eax),%ecx
  80085b:	84 c9                	test   %cl,%cl
  80085d:	74 04                	je     800863 <strncmp+0x26>
  80085f:	3a 0a                	cmp    (%edx),%cl
  800861:	74 eb                	je     80084e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 00             	movzbl (%eax),%eax
  800866:	0f b6 12             	movzbl (%edx),%edx
  800869:	29 d0                	sub    %edx,%eax
  80086b:	eb 05                	jmp    800872 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087f:	eb 07                	jmp    800888 <strchr+0x13>
		if (*s == c)
  800881:	38 ca                	cmp    %cl,%dl
  800883:	74 0f                	je     800894 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	0f b6 10             	movzbl (%eax),%edx
  80088b:	84 d2                	test   %dl,%dl
  80088d:	75 f2                	jne    800881 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a0:	eb 03                	jmp    8008a5 <strfind+0xf>
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	74 04                	je     8008b0 <strfind+0x1a>
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	75 f2                	jne    8008a2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008be:	85 c9                	test   %ecx,%ecx
  8008c0:	74 36                	je     8008f8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c8:	75 28                	jne    8008f2 <memset+0x40>
  8008ca:	f6 c1 03             	test   $0x3,%cl
  8008cd:	75 23                	jne    8008f2 <memset+0x40>
		c &= 0xFF;
  8008cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d3:	89 d3                	mov    %edx,%ebx
  8008d5:	c1 e3 08             	shl    $0x8,%ebx
  8008d8:	89 d6                	mov    %edx,%esi
  8008da:	c1 e6 18             	shl    $0x18,%esi
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	c1 e0 10             	shl    $0x10,%eax
  8008e2:	09 f0                	or     %esi,%eax
  8008e4:	09 c2                	or     %eax,%edx
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 06                	jmp    8008f8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090d:	39 c6                	cmp    %eax,%esi
  80090f:	73 35                	jae    800946 <memmove+0x47>
  800911:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800914:	39 d0                	cmp    %edx,%eax
  800916:	73 2e                	jae    800946 <memmove+0x47>
		s += n;
		d += n;
  800918:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800925:	75 13                	jne    80093a <memmove+0x3b>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0e                	jne    80093a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092c:	83 ef 04             	sub    $0x4,%edi
  80092f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800932:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800935:	fd                   	std    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb 09                	jmp    800943 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093a:	83 ef 01             	sub    $0x1,%edi
  80093d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	fd                   	std    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800943:	fc                   	cld    
  800944:	eb 1d                	jmp    800963 <memmove+0x64>
  800946:	89 f2                	mov    %esi,%edx
  800948:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	f6 c2 03             	test   $0x3,%dl
  80094d:	75 0f                	jne    80095e <memmove+0x5f>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 0a                	jne    80095e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800954:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800957:	89 c7                	mov    %eax,%edi
  800959:	fc                   	cld    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 05                	jmp    800963 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096a:	ff 75 10             	pushl  0x10(%ebp)
  80096d:	ff 75 0c             	pushl  0xc(%ebp)
  800970:	ff 75 08             	pushl  0x8(%ebp)
  800973:	e8 87 ff ff ff       	call   8008ff <memmove>
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c6                	mov    %eax,%esi
  800987:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	eb 1a                	jmp    8009a6 <memcmp+0x2c>
		if (*s1 != *s2)
  80098c:	0f b6 08             	movzbl (%eax),%ecx
  80098f:	0f b6 1a             	movzbl (%edx),%ebx
  800992:	38 d9                	cmp    %bl,%cl
  800994:	74 0a                	je     8009a0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800996:	0f b6 c1             	movzbl %cl,%eax
  800999:	0f b6 db             	movzbl %bl,%ebx
  80099c:	29 d8                	sub    %ebx,%eax
  80099e:	eb 0f                	jmp    8009af <memcmp+0x35>
		s1++, s2++;
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a6:	39 f0                	cmp    %esi,%eax
  8009a8:	75 e2                	jne    80098c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bc:	89 c2                	mov    %eax,%edx
  8009be:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c1:	eb 07                	jmp    8009ca <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c3:	38 08                	cmp    %cl,(%eax)
  8009c5:	74 07                	je     8009ce <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	72 f5                	jb     8009c3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dc:	eb 03                	jmp    8009e1 <strtol+0x11>
		s++;
  8009de:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e1:	0f b6 01             	movzbl (%ecx),%eax
  8009e4:	3c 09                	cmp    $0x9,%al
  8009e6:	74 f6                	je     8009de <strtol+0xe>
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f2                	je     8009de <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ec:	3c 2b                	cmp    $0x2b,%al
  8009ee:	75 0a                	jne    8009fa <strtol+0x2a>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f8:	eb 10                	jmp    800a0a <strtol+0x3a>
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ff:	3c 2d                	cmp    $0x2d,%al
  800a01:	75 07                	jne    800a0a <strtol+0x3a>
		s++, neg = 1;
  800a03:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a06:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0a:	85 db                	test   %ebx,%ebx
  800a0c:	0f 94 c0             	sete   %al
  800a0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a15:	75 19                	jne    800a30 <strtol+0x60>
  800a17:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1a:	75 14                	jne    800a30 <strtol+0x60>
  800a1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a20:	0f 85 82 00 00 00    	jne    800aa8 <strtol+0xd8>
		s += 2, base = 16;
  800a26:	83 c1 02             	add    $0x2,%ecx
  800a29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2e:	eb 16                	jmp    800a46 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a30:	84 c0                	test   %al,%al
  800a32:	74 12                	je     800a46 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	75 08                	jne    800a46 <strtol+0x76>
		s++, base = 8;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4e:	0f b6 11             	movzbl (%ecx),%edx
  800a51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 09             	cmp    $0x9,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x93>
			dig = *s - '0';
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 30             	sub    $0x30,%edx
  800a61:	eb 22                	jmp    800a85 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 57             	sub    $0x57,%edx
  800a73:	eb 10                	jmp    800a85 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 16                	ja     800a95 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a88:	7d 0f                	jge    800a99 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a93:	eb b9                	jmp    800a4e <strtol+0x7e>
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	eb 02                	jmp    800a9b <strtol+0xcb>
  800a99:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9f:	74 0d                	je     800aae <strtol+0xde>
		*endptr = (char *) s;
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	89 0e                	mov    %ecx,(%esi)
  800aa6:	eb 06                	jmp    800aae <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa8:	84 c0                	test   %al,%al
  800aaa:	75 92                	jne    800a3e <strtol+0x6e>
  800aac:	eb 98                	jmp    800a46 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 68 13 80 00       	push   $0x801368
  800b24:	6a 23                	push   $0x23
  800b26:	68 85 13 80 00       	push   $0x801385
  800b2b:	e8 dd f5 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 68 13 80 00       	push   $0x801368
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 85 13 80 00       	push   $0x801385
  800bac:	e8 5c f5 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 68 13 80 00       	push   $0x801368
  800be7:	6a 23                	push   $0x23
  800be9:	68 85 13 80 00       	push   $0x801385
  800bee:	e8 1a f5 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 68 13 80 00       	push   $0x801368
  800c29:	6a 23                	push   $0x23
  800c2b:	68 85 13 80 00       	push   $0x801385
  800c30:	e8 d8 f4 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 68 13 80 00       	push   $0x801368
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 85 13 80 00       	push   $0x801385
  800c72:	e8 96 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 68 13 80 00       	push   $0x801368
  800cad:	6a 23                	push   $0x23
  800caf:	68 85 13 80 00       	push   $0x801385
  800cb4:	e8 54 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	be 00 00 00 00       	mov    $0x0,%esi
  800ccc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 cb                	mov    %ecx,%ebx
  800cfc:	89 cf                	mov    %ecx,%edi
  800cfe:	89 ce                	mov    %ecx,%esi
  800d00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 0c                	push   $0xc
  800d0c:	68 68 13 80 00       	push   $0x801368
  800d11:	6a 23                	push   $0x23
  800d13:	68 85 13 80 00       	push   $0x801385
  800d18:	e8 f0 f3 ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d2b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d32:	75 2c                	jne    800d60 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800d34:	83 ec 04             	sub    $0x4,%esp
  800d37:	6a 07                	push   $0x7
  800d39:	68 00 f0 bf ee       	push   $0xeebff000
  800d3e:	6a 00                	push   $0x0
  800d40:	e8 31 fe ff ff       	call   800b76 <sys_page_alloc>
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	74 14                	je     800d60 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800d4c:	83 ec 04             	sub    $0x4,%esp
  800d4f:	68 94 13 80 00       	push   $0x801394
  800d54:	6a 21                	push   $0x21
  800d56:	68 f8 13 80 00       	push   $0x8013f8
  800d5b:	e8 ad f3 ff ff       	call   80010d <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	68 94 0d 80 00       	push   $0x800d94
  800d70:	6a 00                	push   $0x0
  800d72:	e8 08 ff ff ff       	call   800c7f <sys_env_set_pgfault_upcall>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 14                	jns    800d92 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 c0 13 80 00       	push   $0x8013c0
  800d86:	6a 29                	push   $0x29
  800d88:	68 f8 13 80 00       	push   $0x8013f8
  800d8d:	e8 7b f3 ff ff       	call   80010d <_panic>
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d94:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d95:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d9a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d9c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800d9f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800da4:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800da8:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800dac:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800dae:	83 c4 08             	add    $0x8,%esp
        popal
  800db1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800db2:	83 c4 04             	add    $0x4,%esp
        popfl
  800db5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800db6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800db7:	c3                   	ret    
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	83 ec 10             	sub    $0x10,%esp
  800dc6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800dca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800dce:	8b 74 24 24          	mov    0x24(%esp),%esi
  800dd2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dd6:	85 d2                	test   %edx,%edx
  800dd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ddc:	89 34 24             	mov    %esi,(%esp)
  800ddf:	89 c8                	mov    %ecx,%eax
  800de1:	75 35                	jne    800e18 <__udivdi3+0x58>
  800de3:	39 f1                	cmp    %esi,%ecx
  800de5:	0f 87 bd 00 00 00    	ja     800ea8 <__udivdi3+0xe8>
  800deb:	85 c9                	test   %ecx,%ecx
  800ded:	89 cd                	mov    %ecx,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f1                	div    %ecx
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c6                	mov    %eax,%esi
  800e04:	89 f8                	mov    %edi,%eax
  800e06:	f7 f5                	div    %ebp
  800e08:	89 f2                	mov    %esi,%edx
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
  800e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e18:	3b 14 24             	cmp    (%esp),%edx
  800e1b:	77 7b                	ja     800e98 <__udivdi3+0xd8>
  800e1d:	0f bd f2             	bsr    %edx,%esi
  800e20:	83 f6 1f             	xor    $0x1f,%esi
  800e23:	0f 84 97 00 00 00    	je     800ec0 <__udivdi3+0x100>
  800e29:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e2e:	89 d7                	mov    %edx,%edi
  800e30:	89 f1                	mov    %esi,%ecx
  800e32:	29 f5                	sub    %esi,%ebp
  800e34:	d3 e7                	shl    %cl,%edi
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	89 e9                	mov    %ebp,%ecx
  800e3a:	d3 ea                	shr    %cl,%edx
  800e3c:	89 f1                	mov    %esi,%ecx
  800e3e:	09 fa                	or     %edi,%edx
  800e40:	8b 3c 24             	mov    (%esp),%edi
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e49:	89 e9                	mov    %ebp,%ecx
  800e4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e53:	89 fa                	mov    %edi,%edx
  800e55:	d3 ea                	shr    %cl,%edx
  800e57:	89 f1                	mov    %esi,%ecx
  800e59:	d3 e7                	shl    %cl,%edi
  800e5b:	89 e9                	mov    %ebp,%ecx
  800e5d:	d3 e8                	shr    %cl,%eax
  800e5f:	09 c7                	or     %eax,%edi
  800e61:	89 f8                	mov    %edi,%eax
  800e63:	f7 74 24 08          	divl   0x8(%esp)
  800e67:	89 d5                	mov    %edx,%ebp
  800e69:	89 c7                	mov    %eax,%edi
  800e6b:	f7 64 24 0c          	mull   0xc(%esp)
  800e6f:	39 d5                	cmp    %edx,%ebp
  800e71:	89 14 24             	mov    %edx,(%esp)
  800e74:	72 11                	jb     800e87 <__udivdi3+0xc7>
  800e76:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e7a:	89 f1                	mov    %esi,%ecx
  800e7c:	d3 e2                	shl    %cl,%edx
  800e7e:	39 c2                	cmp    %eax,%edx
  800e80:	73 5e                	jae    800ee0 <__udivdi3+0x120>
  800e82:	3b 2c 24             	cmp    (%esp),%ebp
  800e85:	75 59                	jne    800ee0 <__udivdi3+0x120>
  800e87:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e8a:	31 f6                	xor    %esi,%esi
  800e8c:	89 f2                	mov    %esi,%edx
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	31 f6                	xor    %esi,%esi
  800e9a:	31 c0                	xor    %eax,%eax
  800e9c:	89 f2                	mov    %esi,%edx
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	89 f2                	mov    %esi,%edx
  800eaa:	31 f6                	xor    %esi,%esi
  800eac:	89 f8                	mov    %edi,%eax
  800eae:	f7 f1                	div    %ecx
  800eb0:	89 f2                	mov    %esi,%edx
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ec4:	76 0b                	jbe    800ed1 <__udivdi3+0x111>
  800ec6:	31 c0                	xor    %eax,%eax
  800ec8:	3b 14 24             	cmp    (%esp),%edx
  800ecb:	0f 83 37 ff ff ff    	jae    800e08 <__udivdi3+0x48>
  800ed1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed6:	e9 2d ff ff ff       	jmp    800e08 <__udivdi3+0x48>
  800edb:	90                   	nop
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 f8                	mov    %edi,%eax
  800ee2:	31 f6                	xor    %esi,%esi
  800ee4:	e9 1f ff ff ff       	jmp    800e08 <__udivdi3+0x48>
  800ee9:	66 90                	xchg   %ax,%ax
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	83 ec 20             	sub    $0x20,%esp
  800ef6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800efa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800efe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f02:	89 c6                	mov    %eax,%esi
  800f04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f08:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800f10:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f14:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f18:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	75 1e                	jne    800f40 <__umoddi3+0x50>
  800f22:	39 f7                	cmp    %esi,%edi
  800f24:	76 52                	jbe    800f78 <__umoddi3+0x88>
  800f26:	89 c8                	mov    %ecx,%eax
  800f28:	89 f2                	mov    %esi,%edx
  800f2a:	f7 f7                	div    %edi
  800f2c:	89 d0                	mov    %edx,%eax
  800f2e:	31 d2                	xor    %edx,%edx
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    
  800f37:	89 f6                	mov    %esi,%esi
  800f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f40:	39 f0                	cmp    %esi,%eax
  800f42:	77 5c                	ja     800fa0 <__umoddi3+0xb0>
  800f44:	0f bd e8             	bsr    %eax,%ebp
  800f47:	83 f5 1f             	xor    $0x1f,%ebp
  800f4a:	75 64                	jne    800fb0 <__umoddi3+0xc0>
  800f4c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800f50:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800f54:	0f 86 f6 00 00 00    	jbe    801050 <__umoddi3+0x160>
  800f5a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800f5e:	0f 82 ec 00 00 00    	jb     801050 <__umoddi3+0x160>
  800f64:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f68:	8b 54 24 18          	mov    0x18(%esp),%edx
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    
  800f73:	90                   	nop
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	85 ff                	test   %edi,%edi
  800f7a:	89 fd                	mov    %edi,%ebp
  800f7c:	75 0b                	jne    800f89 <__umoddi3+0x99>
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f7                	div    %edi
  800f87:	89 c5                	mov    %eax,%ebp
  800f89:	8b 44 24 10          	mov    0x10(%esp),%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	f7 f5                	div    %ebp
  800f91:	89 c8                	mov    %ecx,%eax
  800f93:	f7 f5                	div    %ebp
  800f95:	eb 95                	jmp    800f2c <__umoddi3+0x3c>
  800f97:	89 f6                	mov    %esi,%esi
  800f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb5:	89 e9                	mov    %ebp,%ecx
  800fb7:	29 e8                	sub    %ebp,%eax
  800fb9:	d3 e2                	shl    %cl,%edx
  800fbb:	89 c7                	mov    %eax,%edi
  800fbd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc5:	89 f9                	mov    %edi,%ecx
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 c1                	mov    %eax,%ecx
  800fcb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fcf:	09 d1                	or     %edx,%ecx
  800fd1:	89 fa                	mov    %edi,%edx
  800fd3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd7:	89 e9                	mov    %ebp,%ecx
  800fd9:	d3 e0                	shl    %cl,%eax
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fe1:	89 f0                	mov    %esi,%eax
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	89 e9                	mov    %ebp,%ecx
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	89 d1                	mov    %edx,%ecx
  800ff1:	89 fa                	mov    %edi,%edx
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	89 e9                	mov    %ebp,%ecx
  800ff7:	09 f0                	or     %esi,%eax
  800ff9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800ffd:	f7 74 24 10          	divl   0x10(%esp)
  801001:	d3 e6                	shl    %cl,%esi
  801003:	89 d1                	mov    %edx,%ecx
  801005:	f7 64 24 0c          	mull   0xc(%esp)
  801009:	39 d1                	cmp    %edx,%ecx
  80100b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80100f:	89 d7                	mov    %edx,%edi
  801011:	89 c6                	mov    %eax,%esi
  801013:	72 0a                	jb     80101f <__umoddi3+0x12f>
  801015:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801019:	73 10                	jae    80102b <__umoddi3+0x13b>
  80101b:	39 d1                	cmp    %edx,%ecx
  80101d:	75 0c                	jne    80102b <__umoddi3+0x13b>
  80101f:	89 d7                	mov    %edx,%edi
  801021:	89 c6                	mov    %eax,%esi
  801023:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801027:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80102b:	89 ca                	mov    %ecx,%edx
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801033:	29 f0                	sub    %esi,%eax
  801035:	19 fa                	sbb    %edi,%edx
  801037:	d3 e8                	shr    %cl,%eax
  801039:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80103e:	89 d7                	mov    %edx,%edi
  801040:	d3 e7                	shl    %cl,%edi
  801042:	89 e9                	mov    %ebp,%ecx
  801044:	09 f8                	or     %edi,%eax
  801046:	d3 ea                	shr    %cl,%edx
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    
  80104f:	90                   	nop
  801050:	8b 74 24 10          	mov    0x10(%esp),%esi
  801054:	29 f9                	sub    %edi,%ecx
  801056:	19 c6                	sbb    %eax,%esi
  801058:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80105c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801060:	e9 ff fe ff ff       	jmp    800f64 <__umoddi3+0x74>
