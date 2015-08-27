
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800040:	68 40 24 80 00       	push   $0x802440
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 20 0b 00 00       	call   800b7e <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 24 80 00       	push   $0x802460
  80006f:	6a 0f                	push   $0xf
  800071:	68 4a 24 80 00       	push   $0x80244a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 24 80 00       	push   $0x80248c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 99 06 00 00       	call   800722 <snprintf>
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
  80009c:	e8 6f 0d 00 00       	call   800e10 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 12 0a 00 00       	call   800ac2 <sys_cputs>
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
  8000c0:	e8 7b 0a 00 00       	call   800b40 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 6f 0f 00 00       	call   801075 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 ef 09 00 00       	call   800aff <sys_env_destroy>
  800110:	83 c4 10             	add    $0x10,%esp
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 18 0a 00 00       	call   800b40 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 b8 24 80 00       	push   $0x8024b8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 37 09 00 00       	call   800ac2 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 4f 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 dc 08 00 00       	call   800ac2 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 d1                	mov    %edx,%ecx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80021d:	8b 45 10             	mov    0x10(%ebp),%eax
  800220:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800226:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80022d:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800230:	72 05                	jb     800237 <printnum+0x35>
  800232:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800235:	77 3e                	ja     800275 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	53                   	push   %ebx
  800241:	50                   	push   %eax
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 0a 1f 00 00       	call   802160 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 13                	jmp    80027c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f ed                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 fc 1f 00 00       	call   802290 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 db 24 80 00 	movsbl 0x8024db(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
  8002a1:	83 c4 10             	add    $0x10,%esp
}
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
  80031b:	83 c4 10             	add    $0x10,%esp
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	eb 12                	jmp    800346 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800334:	85 c0                	test   %eax,%eax
  800336:	0f 84 90 03 00 00    	je     8006cc <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	53                   	push   %ebx
  800340:	50                   	push   %eax
  800341:	ff d6                	call   *%esi
  800343:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800346:	83 c7 01             	add    $0x1,%edi
  800349:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e2                	jne    800334 <vprintfmt+0x14>
  800352:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800356:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 07                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800375:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8d 47 01             	lea    0x1(%edi),%eax
  80037c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037f:	0f b6 07             	movzbl (%edi),%eax
  800382:	0f b6 c8             	movzbl %al,%ecx
  800385:	83 e8 23             	sub    $0x23,%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 21 03 00 00    	ja     8006b1 <vprintfmt+0x391>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a1:	eb d6                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 39                	ja     8003f9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c3:	eb e9                	jmp    8003ae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 27                	jmp    8003ff <vprintfmt+0xdf>
  8003d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	0f 49 c8             	cmovns %eax,%ecx
  8003e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	eb 8c                	jmp    800379 <vprintfmt+0x59>
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f7:	eb 80                	jmp    800379 <vprintfmt+0x59>
  8003f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 89 70 ff ff ff    	jns    800379 <vprintfmt+0x59>
				width = precision, precision = -1;
  800409:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800416:	e9 5e ff ff ff       	jmp    800379 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800421:	e9 53 ff ff ff       	jmp    800379 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	ff 30                	pushl  (%eax)
  800435:	ff d6                	call   *%esi
			break;
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043d:	e9 04 ff ff ff       	jmp    800346 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	99                   	cltd   
  80044e:	31 d0                	xor    %edx,%eax
  800450:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 0f             	cmp    $0xf,%eax
  800455:	7f 0b                	jg     800462 <vprintfmt+0x142>
  800457:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 18                	jne    80047a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 f3 24 80 00       	push   $0x8024f3
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 94 fe ff ff       	call   800303 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800475:	e9 cc fe ff ff       	jmp    800346 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047a:	52                   	push   %edx
  80047b:	68 69 29 80 00       	push   $0x802969
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 7c fe ff ff       	call   800303 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048d:	e9 b4 fe ff ff       	jmp    800346 <vprintfmt+0x26>
  800492:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800495:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800498:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 50 04             	lea    0x4(%eax),%edx
  8004a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	ba ec 24 80 00       	mov    $0x8024ec,%edx
  8004ad:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004b0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b4:	0f 84 92 00 00 00    	je     80054c <vprintfmt+0x22c>
  8004ba:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004be:	0f 8e 96 00 00 00    	jle    80055a <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	51                   	push   %ecx
  8004c8:	57                   	push   %edi
  8004c9:	e8 86 02 00 00       	call   800754 <strnlen>
  8004ce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1c7>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 4d                	jmp    800566 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1b                	je     80053a <vprintfmt+0x21a>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 10                	jbe    80053a <vprintfmt+0x21a>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 0d                	jmp    800547 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	52                   	push   %edx
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 1a                	jmp    800566 <vprintfmt+0x246>
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800558:	eb 0c                	jmp    800566 <vprintfmt+0x246>
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	83 c7 01             	add    $0x1,%edi
  800569:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056d:	0f be d0             	movsbl %al,%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	74 23                	je     800597 <vprintfmt+0x277>
  800574:	85 f6                	test   %esi,%esi
  800576:	78 a1                	js     800519 <vprintfmt+0x1f9>
  800578:	83 ee 01             	sub    $0x1,%esi
  80057b:	79 9c                	jns    800519 <vprintfmt+0x1f9>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	6a 20                	push   $0x20
  80058d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb 08                	jmp    80059f <vprintfmt+0x27f>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	85 ff                	test   %edi,%edi
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	e9 9b fd ff ff       	jmp    800346 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 fa 01             	cmp    $0x1,%edx
  8005ae:	7e 16                	jle    8005c6 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 08             	lea    0x8(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	eb 32                	jmp    8005f8 <vprintfmt+0x2d8>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 18                	je     8005e2 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	eb 16                	jmp    8005f8 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	79 74                	jns    80067d <vprintfmt+0x35d>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d6                	call   *%esi
				num = -(long long) num;
  800611:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800617:	f7 d8                	neg    %eax
  800619:	83 d2 00             	adc    $0x0,%edx
  80061c:	f7 da                	neg    %edx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800626:	eb 55                	jmp    80067d <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 7c fc ff ff       	call   8002ac <getuint>
			base = 10;
  800630:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800635:	eb 46                	jmp    80067d <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 6d fc ff ff       	call   8002ac <getuint>
                        base = 8;
  80063f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800644:	eb 37                	jmp    80067d <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800669:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066e:	eb 0d                	jmp    80067d <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 34 fc ff ff       	call   8002ac <getuint>
			base = 16;
  800678:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800684:	57                   	push   %edi
  800685:	ff 75 e0             	pushl  -0x20(%ebp)
  800688:	51                   	push   %ecx
  800689:	52                   	push   %edx
  80068a:	50                   	push   %eax
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 6e fb ff ff       	call   800202 <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069a:	e9 a7 fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	51                   	push   %ecx
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ac:	e9 95 fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 25                	push   $0x25
  8006b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 03                	jmp    8006c1 <vprintfmt+0x3a1>
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c5:	75 f7                	jne    8006be <vprintfmt+0x39e>
  8006c7:	e9 7a fc ff ff       	jmp    800346 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 26                	je     80071b <vsnprintf+0x47>
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	7e 22                	jle    80071b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f9:	ff 75 14             	pushl  0x14(%ebp)
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	68 e6 02 80 00       	push   $0x8002e6
  800708:	e8 13 fc ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800710:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 05                	jmp    800720 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	50                   	push   %eax
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	ff 75 08             	pushl  0x8(%ebp)
  800735:	e8 9a ff ff ff       	call   8006d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 03                	jmp    80074c <strlen+0x10>
		n++;
  800749:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800750:	75 f7                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	eb 03                	jmp    800767 <strnlen+0x13>
		n++;
  800764:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 c2                	cmp    %eax,%edx
  800769:	74 08                	je     800773 <strnlen+0x1f>
  80076b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076f:	75 f3                	jne    800764 <strnlen+0x10>
  800771:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078e:	84 db                	test   %bl,%bl
  800790:	75 ef                	jne    800781 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 9a ff ff ff       	call   80073c <strlen>
  8007a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 c5 ff ff ff       	call   800775 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 f3                	mov    %esi,%ebx
  8007c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 0f                	jmp    8007da <strncpy+0x23>
		*dst++ = *src;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	39 da                	cmp    %ebx,%edx
  8007dc:	75 ed                	jne    8007cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	74 21                	je     800819 <strlcpy+0x35>
  8007f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fc:	89 f2                	mov    %esi,%edx
  8007fe:	eb 09                	jmp    800809 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800809:	39 c2                	cmp    %eax,%edx
  80080b:	74 09                	je     800816 <strlcpy+0x32>
  80080d:	0f b6 19             	movzbl (%ecx),%ebx
  800810:	84 db                	test   %bl,%bl
  800812:	75 ec                	jne    800800 <strlcpy+0x1c>
  800814:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800816:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800819:	29 f0                	sub    %esi,%eax
}
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	eb 06                	jmp    800830 <strcmp+0x11>
		p++, q++;
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	84 c0                	test   %al,%al
  800835:	74 04                	je     80083b <strcmp+0x1c>
  800837:	3a 02                	cmp    (%edx),%al
  800839:	74 ef                	je     80082a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 c0             	movzbl %al,%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 c3                	mov    %eax,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800854:	eb 06                	jmp    80085c <strncmp+0x17>
		n--, p++, q++;
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	74 15                	je     800875 <strncmp+0x30>
  800860:	0f b6 08             	movzbl (%eax),%ecx
  800863:	84 c9                	test   %cl,%cl
  800865:	74 04                	je     80086b <strncmp+0x26>
  800867:	3a 0a                	cmp    (%edx),%cl
  800869:	74 eb                	je     800856 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 07                	jmp    800890 <strchr+0x13>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0f                	je     80089c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 03                	jmp    8008ad <strfind+0xf>
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 04                	je     8008b8 <strfind+0x1a>
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	75 f2                	jne    8008aa <strfind+0xc>
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c6:	85 c9                	test   %ecx,%ecx
  8008c8:	74 36                	je     800900 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d0:	75 28                	jne    8008fa <memset+0x40>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 23                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008db:	89 d3                	mov    %edx,%ebx
  8008dd:	c1 e3 08             	shl    $0x8,%ebx
  8008e0:	89 d6                	mov    %edx,%esi
  8008e2:	c1 e6 18             	shl    $0x18,%esi
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	c1 e0 10             	shl    $0x10,%eax
  8008ea:	09 f0                	or     %esi,%eax
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 06                	jmp    800900 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fd:	fc                   	cld    
  8008fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800915:	39 c6                	cmp    %eax,%esi
  800917:	73 35                	jae    80094e <memmove+0x47>
  800919:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 2e                	jae    80094e <memmove+0x47>
		s += n;
		d += n;
  800920:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800923:	89 d6                	mov    %edx,%esi
  800925:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092d:	75 13                	jne    800942 <memmove+0x3b>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0e                	jne    800942 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800934:	83 ef 04             	sub    $0x4,%edi
  800937:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093d:	fd                   	std    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 09                	jmp    80094b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 1d                	jmp    80096b <memmove+0x64>
  80094e:	89 f2                	mov    %esi,%edx
  800950:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	f6 c2 03             	test   $0x3,%dl
  800955:	75 0f                	jne    800966 <memmove+0x5f>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0a                	jne    800966 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 05                	jmp    80096b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 87 ff ff ff       	call   800907 <memmove>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c6                	mov    %eax,%esi
  80098f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	eb 1a                	jmp    8009ae <memcmp+0x2c>
		if (*s1 != *s2)
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	0f b6 1a             	movzbl (%edx),%ebx
  80099a:	38 d9                	cmp    %bl,%cl
  80099c:	74 0a                	je     8009a8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c1             	movzbl %cl,%eax
  8009a1:	0f b6 db             	movzbl %bl,%ebx
  8009a4:	29 d8                	sub    %ebx,%eax
  8009a6:	eb 0f                	jmp    8009b7 <memcmp+0x35>
		s1++, s2++;
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	75 e2                	jne    800994 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c4:	89 c2                	mov    %eax,%edx
  8009c6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c9:	eb 07                	jmp    8009d2 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	38 08                	cmp    %cl,(%eax)
  8009cd:	74 07                	je     8009d6 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	72 f5                	jb     8009cb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 03                	jmp    8009e9 <strtol+0x11>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f6                	je     8009e6 <strtol+0xe>
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f2                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f4:	3c 2b                	cmp    $0x2b,%al
  8009f6:	75 0a                	jne    800a02 <strtol+0x2a>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800a00:	eb 10                	jmp    800a12 <strtol+0x3a>
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	75 07                	jne    800a12 <strtol+0x3a>
		s++, neg = 1;
  800a0b:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a0e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a12:	85 db                	test   %ebx,%ebx
  800a14:	0f 94 c0             	sete   %al
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 19                	jne    800a38 <strtol+0x60>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 14                	jne    800a38 <strtol+0x60>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	0f 85 82 00 00 00    	jne    800ab0 <strtol+0xd8>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 12                	je     800a4e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x76>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x93>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0f                	jge    800aa1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x7e>
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	eb 02                	jmp    800aa3 <strtol+0xcb>
  800aa1:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 0d                	je     800ab6 <strtol+0xde>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
  800aae:	eb 06                	jmp    800ab6 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	84 c0                	test   %al,%al
  800ab2:	75 92                	jne    800a46 <strtol+0x6e>
  800ab4:	eb 98                	jmp    800a4e <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab6:	f7 da                	neg    %edx
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	0f 45 c2             	cmovne %edx,%eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	89 c7                	mov    %eax,%edi
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	b8 01 00 00 00       	mov    $0x1,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	89 d7                	mov    %edx,%edi
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 cb                	mov    %ecx,%ebx
  800b17:	89 cf                	mov    %ecx,%edi
  800b19:	89 ce                	mov    %ecx,%esi
  800b1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 17                	jle    800b38 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	50                   	push   %eax
  800b25:	6a 03                	push   $0x3
  800b27:	68 1f 28 80 00       	push   $0x80281f
  800b2c:	6a 22                	push   $0x22
  800b2e:	68 3c 28 80 00       	push   $0x80283c
  800b33:	e8 dd f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_yield>:

void
sys_yield(void)
{      
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b87:	be 00 00 00 00       	mov    $0x0,%esi
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	89 f7                	mov    %esi,%edi
  800b9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 04                	push   $0x4
  800ba8:	68 1f 28 80 00       	push   $0x80281f
  800bad:	6a 22                	push   $0x22
  800baf:	68 3c 28 80 00       	push   $0x80283c
  800bb4:	e8 5c f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 05                	push   $0x5
  800bea:	68 1f 28 80 00       	push   $0x80281f
  800bef:	6a 22                	push   $0x22
  800bf1:	68 3c 28 80 00       	push   $0x80283c
  800bf6:	e8 1a f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 06                	push   $0x6
  800c2c:	68 1f 28 80 00       	push   $0x80281f
  800c31:	6a 22                	push   $0x22
  800c33:	68 3c 28 80 00       	push   $0x80283c
  800c38:	e8 d8 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 08                	push   $0x8
  800c6e:	68 1f 28 80 00       	push   $0x80281f
  800c73:	6a 22                	push   $0x22
  800c75:	68 3c 28 80 00       	push   $0x80283c
  800c7a:	e8 96 f4 ff ff       	call   800115 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 09                	push   $0x9
  800cb0:	68 1f 28 80 00       	push   $0x80281f
  800cb5:	6a 22                	push   $0x22
  800cb7:	68 3c 28 80 00       	push   $0x80283c
  800cbc:	e8 54 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 0a                	push   $0xa
  800cf2:	68 1f 28 80 00       	push   $0x80281f
  800cf7:	6a 22                	push   $0x22
  800cf9:	68 3c 28 80 00       	push   $0x80283c
  800cfe:	e8 12 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 cb                	mov    %ecx,%ebx
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	89 ce                	mov    %ecx,%esi
  800d4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 0d                	push   $0xd
  800d56:	68 1f 28 80 00       	push   $0x80281f
  800d5b:	6a 22                	push   $0x22
  800d5d:	68 3c 28 80 00       	push   $0x80283c
  800d62:	e8 ae f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d75:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7f:	89 d1                	mov    %edx,%ecx
  800d81:	89 d3                	mov    %edx,%ebx
  800d83:	89 d7                	mov    %edx,%edi
  800d85:	89 d6                	mov    %edx,%esi
  800d87:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 cb                	mov    %ecx,%ebx
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	89 ce                	mov    %ecx,%esi
  800daa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 17                	jle    800dc7 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	50                   	push   %eax
  800db4:	6a 0f                	push   $0xf
  800db6:	68 1f 28 80 00       	push   $0x80281f
  800dbb:	6a 22                	push   $0x22
  800dbd:	68 3c 28 80 00       	push   $0x80283c
  800dc2:	e8 4e f3 ff ff       	call   800115 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_recv>:

int
sys_recv(void *addr)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddd:	b8 10 00 00 00       	mov    $0x10,%eax
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	89 cf                	mov    %ecx,%edi
  800de9:	89 ce                	mov    %ecx,%esi
  800deb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 10                	push   $0x10
  800df7:	68 1f 28 80 00       	push   $0x80281f
  800dfc:	6a 22                	push   $0x22
  800dfe:	68 3c 28 80 00       	push   $0x80283c
  800e03:	e8 0d f3 ff ff       	call   800115 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e16:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e1d:	75 2c                	jne    800e4b <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	6a 07                	push   $0x7
  800e24:	68 00 f0 bf ee       	push   $0xeebff000
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 4e fd ff ff       	call   800b7e <sys_page_alloc>
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	74 14                	je     800e4b <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 4c 28 80 00       	push   $0x80284c
  800e3f:	6a 21                	push   $0x21
  800e41:	68 ae 28 80 00       	push   $0x8028ae
  800e46:	e8 ca f2 ff ff       	call   800115 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	a3 0c 40 80 00       	mov    %eax,0x80400c
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	68 7f 0e 80 00       	push   $0x800e7f
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 67 fe ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 14                	jns    800e7d <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 78 28 80 00       	push   $0x802878
  800e71:	6a 29                	push   $0x29
  800e73:	68 ae 28 80 00       	push   $0x8028ae
  800e78:	e8 98 f2 ff ff       	call   800115 <_panic>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e7f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e80:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e85:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e87:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800e8a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800e8f:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800e93:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800e97:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800e99:	83 c4 08             	add    $0x8,%esp
        popal
  800e9c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800e9d:	83 c4 04             	add    $0x4,%esp
        popfl
  800ea0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800ea1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800ea2:	c3                   	ret    

00800ea3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ebe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	c1 ea 16             	shr    $0x16,%edx
  800eda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 11                	je     800ef7 <fd_alloc+0x2d>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 0c             	shr    $0xc,%edx
  800eeb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	75 09                	jne    800f00 <fd_alloc+0x36>
			*fd_store = fd;
  800ef7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 17                	jmp    800f17 <fd_alloc+0x4d>
  800f00:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f05:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0a:	75 c9                	jne    800ed5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f0c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f12:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1f:	83 f8 1f             	cmp    $0x1f,%eax
  800f22:	77 36                	ja     800f5a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f24:	c1 e0 0c             	shl    $0xc,%eax
  800f27:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	c1 ea 16             	shr    $0x16,%edx
  800f31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	74 24                	je     800f61 <fd_lookup+0x48>
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 0c             	shr    $0xc,%edx
  800f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 1a                	je     800f68 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	89 02                	mov    %eax,(%edx)
	return 0;
  800f53:	b8 00 00 00 00       	mov    $0x0,%eax
  800f58:	eb 13                	jmp    800f6d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb 0c                	jmp    800f6d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f66:	eb 05                	jmp    800f6d <fd_lookup+0x54>
  800f68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f78:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7d:	eb 13                	jmp    800f92 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f7f:	39 08                	cmp    %ecx,(%eax)
  800f81:	75 0c                	jne    800f8f <dev_lookup+0x20>
			*dev = devtab[i];
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	eb 36                	jmp    800fc5 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f8f:	83 c2 01             	add    $0x1,%edx
  800f92:	8b 04 95 3c 29 80 00 	mov    0x80293c(,%edx,4),%eax
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	75 e2                	jne    800f7f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f9d:	a1 08 40 80 00       	mov    0x804008,%eax
  800fa2:	8b 40 48             	mov    0x48(%eax),%eax
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	51                   	push   %ecx
  800fa9:	50                   	push   %eax
  800faa:	68 bc 28 80 00       	push   $0x8028bc
  800faf:	e8 3a f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 10             	sub    $0x10,%esp
  800fcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fdf:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe2:	50                   	push   %eax
  800fe3:	e8 31 ff ff ff       	call   800f19 <fd_lookup>
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 05                	js     800ff4 <fd_close+0x2d>
	    || fd != fd2)
  800fef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff2:	74 0c                	je     801000 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff4:	84 db                	test   %bl,%bl
  800ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffb:	0f 44 c2             	cmove  %edx,%eax
  800ffe:	eb 41                	jmp    801041 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801006:	50                   	push   %eax
  801007:	ff 36                	pushl  (%esi)
  801009:	e8 61 ff ff ff       	call   800f6f <dev_lookup>
  80100e:	89 c3                	mov    %eax,%ebx
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	78 1a                	js     801031 <fd_close+0x6a>
		if (dev->dev_close)
  801017:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801022:	85 c0                	test   %eax,%eax
  801024:	74 0b                	je     801031 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	56                   	push   %esi
  80102a:	ff d0                	call   *%eax
  80102c:	89 c3                	mov    %eax,%ebx
  80102e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	56                   	push   %esi
  801035:	6a 00                	push   $0x0
  801037:	e8 c7 fb ff ff       	call   800c03 <sys_page_unmap>
	return r;
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	89 d8                	mov    %ebx,%eax
}
  801041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801051:	50                   	push   %eax
  801052:	ff 75 08             	pushl  0x8(%ebp)
  801055:	e8 bf fe ff ff       	call   800f19 <fd_lookup>
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	85 d2                	test   %edx,%edx
  801061:	78 10                	js     801073 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	6a 01                	push   $0x1
  801068:	ff 75 f4             	pushl  -0xc(%ebp)
  80106b:	e8 57 ff ff ff       	call   800fc7 <fd_close>
  801070:	83 c4 10             	add    $0x10,%esp
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <close_all>:

void
close_all(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	53                   	push   %ebx
  801079:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	53                   	push   %ebx
  801085:	e8 be ff ff ff       	call   801048 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108a:	83 c3 01             	add    $0x1,%ebx
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	83 fb 20             	cmp    $0x20,%ebx
  801093:	75 ec                	jne    801081 <close_all+0xc>
		close(i);
}
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 2c             	sub    $0x2c,%esp
  8010a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a9:	50                   	push   %eax
  8010aa:	ff 75 08             	pushl  0x8(%ebp)
  8010ad:	e8 67 fe ff ff       	call   800f19 <fd_lookup>
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	85 d2                	test   %edx,%edx
  8010b9:	0f 88 c1 00 00 00    	js     801180 <dup+0xe6>
		return r;
	close(newfdnum);
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	56                   	push   %esi
  8010c3:	e8 80 ff ff ff       	call   801048 <close>

	newfd = INDEX2FD(newfdnum);
  8010c8:	89 f3                	mov    %esi,%ebx
  8010ca:	c1 e3 0c             	shl    $0xc,%ebx
  8010cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d3:	83 c4 04             	add    $0x4,%esp
  8010d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d9:	e8 d5 fd ff ff       	call   800eb3 <fd2data>
  8010de:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e0:	89 1c 24             	mov    %ebx,(%esp)
  8010e3:	e8 cb fd ff ff       	call   800eb3 <fd2data>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ee:	89 f8                	mov    %edi,%eax
  8010f0:	c1 e8 16             	shr    $0x16,%eax
  8010f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fa:	a8 01                	test   $0x1,%al
  8010fc:	74 37                	je     801135 <dup+0x9b>
  8010fe:	89 f8                	mov    %edi,%eax
  801100:	c1 e8 0c             	shr    $0xc,%eax
  801103:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110a:	f6 c2 01             	test   $0x1,%dl
  80110d:	74 26                	je     801135 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	50                   	push   %eax
  80111f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801122:	6a 00                	push   $0x0
  801124:	57                   	push   %edi
  801125:	6a 00                	push   $0x0
  801127:	e8 95 fa ff ff       	call   800bc1 <sys_page_map>
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 2e                	js     801163 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801135:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801138:	89 d0                	mov    %edx,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	25 07 0e 00 00       	and    $0xe07,%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	52                   	push   %edx
  801151:	6a 00                	push   $0x0
  801153:	e8 69 fa ff ff       	call   800bc1 <sys_page_map>
  801158:	89 c7                	mov    %eax,%edi
  80115a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80115d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115f:	85 ff                	test   %edi,%edi
  801161:	79 1d                	jns    801180 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	53                   	push   %ebx
  801167:	6a 00                	push   $0x0
  801169:	e8 95 fa ff ff       	call   800c03 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	ff 75 d4             	pushl  -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	e8 88 fa ff ff       	call   800c03 <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	89 f8                	mov    %edi,%eax
}
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 14             	sub    $0x14,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 7d fd ff ff       	call   800f19 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 6d                	js     801212 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 b9 fd ff ff       	call   800f6f <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 4c                	js     801209 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c0:	8b 42 08             	mov    0x8(%edx),%eax
  8011c3:	83 e0 03             	and    $0x3,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	75 21                	jne    8011ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	50                   	push   %eax
  8011d8:	68 00 29 80 00       	push   $0x802900
  8011dd:	e8 0c f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ea:	eb 26                	jmp    801212 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ef:	8b 40 08             	mov    0x8(%eax),%eax
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	74 17                	je     80120d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	ff 75 10             	pushl  0x10(%ebp)
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	52                   	push   %edx
  801200:	ff d0                	call   *%eax
  801202:	89 c2                	mov    %eax,%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 09                	jmp    801212 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	89 c2                	mov    %eax,%edx
  80120b:	eb 05                	jmp    801212 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801212:	89 d0                	mov    %edx,%eax
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122d:	eb 21                	jmp    801250 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	89 f0                	mov    %esi,%eax
  801234:	29 d8                	sub    %ebx,%eax
  801236:	50                   	push   %eax
  801237:	89 d8                	mov    %ebx,%eax
  801239:	03 45 0c             	add    0xc(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	57                   	push   %edi
  80123e:	e8 45 ff ff ff       	call   801188 <read>
		if (m < 0)
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 0c                	js     801256 <readn+0x3d>
			return m;
		if (m == 0)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	74 06                	je     801254 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124e:	01 c3                	add    %eax,%ebx
  801250:	39 f3                	cmp    %esi,%ebx
  801252:	72 db                	jb     80122f <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801254:	89 d8                	mov    %ebx,%eax
}
  801256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	53                   	push   %ebx
  801262:	83 ec 14             	sub    $0x14,%esp
  801265:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801268:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	53                   	push   %ebx
  80126d:	e8 a7 fc ff ff       	call   800f19 <fd_lookup>
  801272:	83 c4 08             	add    $0x8,%esp
  801275:	89 c2                	mov    %eax,%edx
  801277:	85 c0                	test   %eax,%eax
  801279:	78 68                	js     8012e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801281:	50                   	push   %eax
  801282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801285:	ff 30                	pushl  (%eax)
  801287:	e8 e3 fc ff ff       	call   800f6f <dev_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 47                	js     8012da <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129a:	75 21                	jne    8012bd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129c:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a1:	8b 40 48             	mov    0x48(%eax),%eax
  8012a4:	83 ec 04             	sub    $0x4,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	50                   	push   %eax
  8012a9:	68 1c 29 80 00       	push   $0x80291c
  8012ae:	e8 3b ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bb:	eb 26                	jmp    8012e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c3:	85 d2                	test   %edx,%edx
  8012c5:	74 17                	je     8012de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	ff 75 10             	pushl  0x10(%ebp)
  8012cd:	ff 75 0c             	pushl  0xc(%ebp)
  8012d0:	50                   	push   %eax
  8012d1:	ff d2                	call   *%edx
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	eb 09                	jmp    8012e3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	eb 05                	jmp    8012e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 1d fc ff ff       	call   800f19 <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 0e                	js     801311 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801303:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801306:	8b 55 0c             	mov    0xc(%ebp),%edx
  801309:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	53                   	push   %ebx
  801322:	e8 f2 fb ff ff       	call   800f19 <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 65                	js     801395 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	ff 30                	pushl  (%eax)
  80133c:	e8 2e fc ff ff       	call   800f6f <dev_lookup>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 44                	js     80138c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134f:	75 21                	jne    801372 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801351:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801356:	8b 40 48             	mov    0x48(%eax),%eax
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	53                   	push   %ebx
  80135d:	50                   	push   %eax
  80135e:	68 dc 28 80 00       	push   $0x8028dc
  801363:	e8 86 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801370:	eb 23                	jmp    801395 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801372:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801375:	8b 52 18             	mov    0x18(%edx),%edx
  801378:	85 d2                	test   %edx,%edx
  80137a:	74 14                	je     801390 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	ff 75 0c             	pushl  0xc(%ebp)
  801382:	50                   	push   %eax
  801383:	ff d2                	call   *%edx
  801385:	89 c2                	mov    %eax,%edx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb 09                	jmp    801395 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	eb 05                	jmp    801395 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801390:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801395:	89 d0                	mov    %edx,%eax
  801397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 14             	sub    $0x14,%esp
  8013a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	ff 75 08             	pushl  0x8(%ebp)
  8013ad:	e8 67 fb ff ff       	call   800f19 <fd_lookup>
  8013b2:	83 c4 08             	add    $0x8,%esp
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 58                	js     801413 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c5:	ff 30                	pushl  (%eax)
  8013c7:	e8 a3 fb ff ff       	call   800f6f <dev_lookup>
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 37                	js     80140a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013da:	74 32                	je     80140e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e6:	00 00 00 
	stat->st_isdir = 0;
  8013e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f0:	00 00 00 
	stat->st_dev = dev;
  8013f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801400:	ff 50 14             	call   *0x14(%eax)
  801403:	89 c2                	mov    %eax,%edx
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	eb 09                	jmp    801413 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140a:	89 c2                	mov    %eax,%edx
  80140c:	eb 05                	jmp    801413 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80140e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801413:	89 d0                	mov    %edx,%eax
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	6a 00                	push   $0x0
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 09 02 00 00       	call   801635 <open>
  80142c:	89 c3                	mov    %eax,%ebx
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 db                	test   %ebx,%ebx
  801433:	78 1b                	js     801450 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	53                   	push   %ebx
  80143c:	e8 5b ff ff ff       	call   80139c <fstat>
  801441:	89 c6                	mov    %eax,%esi
	close(fd);
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 fd fb ff ff       	call   801048 <close>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 f0                	mov    %esi,%eax
}
  801450:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	89 c6                	mov    %eax,%esi
  80145e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801460:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801467:	75 12                	jne    80147b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	6a 01                	push   $0x1
  80146e:	e8 70 0c 00 00       	call   8020e3 <ipc_find_env>
  801473:	a3 00 40 80 00       	mov    %eax,0x804000
  801478:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147b:	6a 07                	push   $0x7
  80147d:	68 00 50 80 00       	push   $0x805000
  801482:	56                   	push   %esi
  801483:	ff 35 00 40 80 00    	pushl  0x804000
  801489:	e8 01 0c 00 00       	call   80208f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148e:	83 c4 0c             	add    $0xc,%esp
  801491:	6a 00                	push   $0x0
  801493:	53                   	push   %ebx
  801494:	6a 00                	push   $0x0
  801496:	e8 8b 0b 00 00       	call   802026 <ipc_recv>
}
  80149b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c5:	e8 8d ff ff ff       	call   801457 <fsipc>
}
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e7:	e8 6b ff ff ff       	call   801457 <fsipc>
}
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 05 00 00 00       	mov    $0x5,%eax
  80150d:	e8 45 ff ff ff       	call   801457 <fsipc>
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 d2                	test   %edx,%edx
  801516:	78 2c                	js     801544 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	68 00 50 80 00       	push   $0x805000
  801520:	53                   	push   %ebx
  801521:	e8 4f f2 ff ff       	call   800775 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801526:	a1 80 50 80 00       	mov    0x805080,%eax
  80152b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801531:	a1 84 50 80 00       	mov    0x805084,%eax
  801536:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	8b 40 0c             	mov    0xc(%eax),%eax
  80155b:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801563:	eb 3d                	jmp    8015a2 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801565:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80156b:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801570:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	57                   	push   %edi
  801577:	53                   	push   %ebx
  801578:	68 08 50 80 00       	push   $0x805008
  80157d:	e8 85 f3 ff ff       	call   800907 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801582:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801588:	ba 00 00 00 00       	mov    $0x0,%edx
  80158d:	b8 04 00 00 00       	mov    $0x4,%eax
  801592:	e8 c0 fe ff ff       	call   801457 <fsipc>
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 0d                	js     8015ab <devfile_write+0x62>
		        return r;
                n -= tmp;
  80159e:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8015a0:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015a2:	85 f6                	test   %esi,%esi
  8015a4:	75 bf                	jne    801565 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8015ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	56                   	push   %esi
  8015b7:	53                   	push   %ebx
  8015b8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015c6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d6:	e8 7c fe ff ff       	call   801457 <fsipc>
  8015db:	89 c3                	mov    %eax,%ebx
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 4b                	js     80162c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015e1:	39 c6                	cmp    %eax,%esi
  8015e3:	73 16                	jae    8015fb <devfile_read+0x48>
  8015e5:	68 50 29 80 00       	push   $0x802950
  8015ea:	68 57 29 80 00       	push   $0x802957
  8015ef:	6a 7c                	push   $0x7c
  8015f1:	68 6c 29 80 00       	push   $0x80296c
  8015f6:	e8 1a eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8015fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801600:	7e 16                	jle    801618 <devfile_read+0x65>
  801602:	68 77 29 80 00       	push   $0x802977
  801607:	68 57 29 80 00       	push   $0x802957
  80160c:	6a 7d                	push   $0x7d
  80160e:	68 6c 29 80 00       	push   $0x80296c
  801613:	e8 fd ea ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	50                   	push   %eax
  80161c:	68 00 50 80 00       	push   $0x805000
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	e8 de f2 ff ff       	call   800907 <memmove>
	return r;
  801629:	83 c4 10             	add    $0x10,%esp
}
  80162c:	89 d8                	mov    %ebx,%eax
  80162e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 20             	sub    $0x20,%esp
  80163c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80163f:	53                   	push   %ebx
  801640:	e8 f7 f0 ff ff       	call   80073c <strlen>
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80164d:	7f 67                	jg     8016b6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	e8 6f f8 ff ff       	call   800eca <fd_alloc>
  80165b:	83 c4 10             	add    $0x10,%esp
		return r;
  80165e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801660:	85 c0                	test   %eax,%eax
  801662:	78 57                	js     8016bb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	68 00 50 80 00       	push   $0x805000
  80166d:	e8 03 f1 ff ff       	call   800775 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801672:	8b 45 0c             	mov    0xc(%ebp),%eax
  801675:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80167a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167d:	b8 01 00 00 00       	mov    $0x1,%eax
  801682:	e8 d0 fd ff ff       	call   801457 <fsipc>
  801687:	89 c3                	mov    %eax,%ebx
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	79 14                	jns    8016a4 <open+0x6f>
		fd_close(fd, 0);
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	6a 00                	push   $0x0
  801695:	ff 75 f4             	pushl  -0xc(%ebp)
  801698:	e8 2a f9 ff ff       	call   800fc7 <fd_close>
		return r;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	89 da                	mov    %ebx,%edx
  8016a2:	eb 17                	jmp    8016bb <open+0x86>
	}

	return fd2num(fd);
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016aa:	e8 f4 f7 ff ff       	call   800ea3 <fd2num>
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 05                	jmp    8016bb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016b6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d2:	e8 80 fd ff ff       	call   801457 <fsipc>
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016df:	68 83 29 80 00       	push   $0x802983
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	e8 89 f0 ff ff       	call   800775 <strcpy>
	return 0;
}
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 10             	sub    $0x10,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016fd:	53                   	push   %ebx
  8016fe:	e8 18 0a 00 00       	call   80211b <pageref>
  801703:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80170b:	83 f8 01             	cmp    $0x1,%eax
  80170e:	75 10                	jne    801720 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801710:	83 ec 0c             	sub    $0xc,%esp
  801713:	ff 73 0c             	pushl  0xc(%ebx)
  801716:	e8 ca 02 00 00       	call   8019e5 <nsipc_close>
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801720:	89 d0                	mov    %edx,%eax
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80172d:	6a 00                	push   $0x0
  80172f:	ff 75 10             	pushl  0x10(%ebp)
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	ff 70 0c             	pushl  0xc(%eax)
  80173b:	e8 82 03 00 00       	call   801ac2 <nsipc_send>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801748:	6a 00                	push   $0x0
  80174a:	ff 75 10             	pushl  0x10(%ebp)
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	ff 70 0c             	pushl  0xc(%eax)
  801756:	e8 fb 02 00 00       	call   801a56 <nsipc_recv>
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801763:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801766:	52                   	push   %edx
  801767:	50                   	push   %eax
  801768:	e8 ac f7 ff ff       	call   800f19 <fd_lookup>
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	78 17                	js     80178b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801777:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80177d:	39 08                	cmp    %ecx,(%eax)
  80177f:	75 05                	jne    801786 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	eb 05                	jmp    80178b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801786:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	83 ec 1c             	sub    $0x1c,%esp
  801795:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	50                   	push   %eax
  80179b:	e8 2a f7 ff ff       	call   800eca <fd_alloc>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 1b                	js     8017c4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	68 07 04 00 00       	push   $0x407
  8017b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 c3 f3 ff ff       	call   800b7e <sys_page_alloc>
  8017bb:	89 c3                	mov    %eax,%ebx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	79 10                	jns    8017d4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	56                   	push   %esi
  8017c8:	e8 18 02 00 00       	call   8019e5 <nsipc_close>
		return r;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	89 d8                	mov    %ebx,%eax
  8017d2:	eb 24                	jmp    8017f8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017d4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017dd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8017e9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	52                   	push   %edx
  8017f0:	e8 ae f6 ff ff       	call   800ea3 <fd2num>
  8017f5:	83 c4 10             	add    $0x10,%esp
}
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	e8 50 ff ff ff       	call   80175d <fd2sockid>
		return r;
  80180d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 1f                	js     801832 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801813:	83 ec 04             	sub    $0x4,%esp
  801816:	ff 75 10             	pushl  0x10(%ebp)
  801819:	ff 75 0c             	pushl  0xc(%ebp)
  80181c:	50                   	push   %eax
  80181d:	e8 1c 01 00 00       	call   80193e <nsipc_accept>
  801822:	83 c4 10             	add    $0x10,%esp
		return r;
  801825:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801827:	85 c0                	test   %eax,%eax
  801829:	78 07                	js     801832 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80182b:	e8 5d ff ff ff       	call   80178d <alloc_sockfd>
  801830:	89 c1                	mov    %eax,%ecx
}
  801832:	89 c8                	mov    %ecx,%eax
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	e8 19 ff ff ff       	call   80175d <fd2sockid>
  801844:	89 c2                	mov    %eax,%edx
  801846:	85 d2                	test   %edx,%edx
  801848:	78 12                	js     80185c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	ff 75 10             	pushl  0x10(%ebp)
  801850:	ff 75 0c             	pushl  0xc(%ebp)
  801853:	52                   	push   %edx
  801854:	e8 35 01 00 00       	call   80198e <nsipc_bind>
  801859:	83 c4 10             	add    $0x10,%esp
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <shutdown>:

int
shutdown(int s, int how)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	e8 f1 fe ff ff       	call   80175d <fd2sockid>
  80186c:	89 c2                	mov    %eax,%edx
  80186e:	85 d2                	test   %edx,%edx
  801870:	78 0f                	js     801881 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	ff 75 0c             	pushl  0xc(%ebp)
  801878:	52                   	push   %edx
  801879:	e8 45 01 00 00       	call   8019c3 <nsipc_shutdown>
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	e8 cc fe ff ff       	call   80175d <fd2sockid>
  801891:	89 c2                	mov    %eax,%edx
  801893:	85 d2                	test   %edx,%edx
  801895:	78 12                	js     8018a9 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	ff 75 10             	pushl  0x10(%ebp)
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	52                   	push   %edx
  8018a1:	e8 59 01 00 00       	call   8019ff <nsipc_connect>
  8018a6:	83 c4 10             	add    $0x10,%esp
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <listen>:

int
listen(int s, int backlog)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	e8 a4 fe ff ff       	call   80175d <fd2sockid>
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	85 d2                	test   %edx,%edx
  8018bd:	78 0f                	js     8018ce <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	ff 75 0c             	pushl  0xc(%ebp)
  8018c5:	52                   	push   %edx
  8018c6:	e8 69 01 00 00       	call   801a34 <nsipc_listen>
  8018cb:	83 c4 10             	add    $0x10,%esp
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018d6:	ff 75 10             	pushl  0x10(%ebp)
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	ff 75 08             	pushl  0x8(%ebp)
  8018df:	e8 3c 02 00 00       	call   801b20 <nsipc_socket>
  8018e4:	89 c2                	mov    %eax,%edx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 d2                	test   %edx,%edx
  8018eb:	78 05                	js     8018f2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8018ed:	e8 9b fe ff ff       	call   80178d <alloc_sockfd>
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018fd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801904:	75 12                	jne    801918 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801906:	83 ec 0c             	sub    $0xc,%esp
  801909:	6a 02                	push   $0x2
  80190b:	e8 d3 07 00 00       	call   8020e3 <ipc_find_env>
  801910:	a3 04 40 80 00       	mov    %eax,0x804004
  801915:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801918:	6a 07                	push   $0x7
  80191a:	68 00 60 80 00       	push   $0x806000
  80191f:	53                   	push   %ebx
  801920:	ff 35 04 40 80 00    	pushl  0x804004
  801926:	e8 64 07 00 00       	call   80208f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80192b:	83 c4 0c             	add    $0xc,%esp
  80192e:	6a 00                	push   $0x0
  801930:	6a 00                	push   $0x0
  801932:	6a 00                	push   $0x0
  801934:	e8 ed 06 00 00       	call   802026 <ipc_recv>
}
  801939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80194e:	8b 06                	mov    (%esi),%eax
  801950:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801955:	b8 01 00 00 00       	mov    $0x1,%eax
  80195a:	e8 95 ff ff ff       	call   8018f4 <nsipc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	85 c0                	test   %eax,%eax
  801963:	78 20                	js     801985 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	ff 35 10 60 80 00    	pushl  0x806010
  80196e:	68 00 60 80 00       	push   $0x806000
  801973:	ff 75 0c             	pushl  0xc(%ebp)
  801976:	e8 8c ef ff ff       	call   800907 <memmove>
		*addrlen = ret->ret_addrlen;
  80197b:	a1 10 60 80 00       	mov    0x806010,%eax
  801980:	89 06                	mov    %eax,(%esi)
  801982:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801985:	89 d8                	mov    %ebx,%eax
  801987:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 08             	sub    $0x8,%esp
  801995:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019a0:	53                   	push   %ebx
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	68 04 60 80 00       	push   $0x806004
  8019a9:	e8 59 ef ff ff       	call   800907 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019ae:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8019b9:	e8 36 ff ff ff       	call   8018f4 <nsipc>
}
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019de:	e8 11 ff ff ff       	call   8018f4 <nsipc>
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <nsipc_close>:

int
nsipc_close(int s)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f8:	e8 f7 fe ff ff       	call   8018f4 <nsipc>
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a11:	53                   	push   %ebx
  801a12:	ff 75 0c             	pushl  0xc(%ebp)
  801a15:	68 04 60 80 00       	push   $0x806004
  801a1a:	e8 e8 ee ff ff       	call   800907 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a1f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a25:	b8 05 00 00 00       	mov    $0x5,%eax
  801a2a:	e8 c5 fe ff ff       	call   8018f4 <nsipc>
}
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a45:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a4a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4f:	e8 a0 fe ff ff       	call   8018f4 <nsipc>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a66:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a74:	b8 07 00 00 00       	mov    $0x7,%eax
  801a79:	e8 76 fe ff ff       	call   8018f4 <nsipc>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 35                	js     801ab9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a84:	39 f0                	cmp    %esi,%eax
  801a86:	7f 07                	jg     801a8f <nsipc_recv+0x39>
  801a88:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a8d:	7e 16                	jle    801aa5 <nsipc_recv+0x4f>
  801a8f:	68 8f 29 80 00       	push   $0x80298f
  801a94:	68 57 29 80 00       	push   $0x802957
  801a99:	6a 62                	push   $0x62
  801a9b:	68 a4 29 80 00       	push   $0x8029a4
  801aa0:	e8 70 e6 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aa5:	83 ec 04             	sub    $0x4,%esp
  801aa8:	50                   	push   %eax
  801aa9:	68 00 60 80 00       	push   $0x806000
  801aae:	ff 75 0c             	pushl  0xc(%ebp)
  801ab1:	e8 51 ee ff ff       	call   800907 <memmove>
  801ab6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ab9:	89 d8                	mov    %ebx,%eax
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ad4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ada:	7e 16                	jle    801af2 <nsipc_send+0x30>
  801adc:	68 b0 29 80 00       	push   $0x8029b0
  801ae1:	68 57 29 80 00       	push   $0x802957
  801ae6:	6a 6d                	push   $0x6d
  801ae8:	68 a4 29 80 00       	push   $0x8029a4
  801aed:	e8 23 e6 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801af2:	83 ec 04             	sub    $0x4,%esp
  801af5:	53                   	push   %ebx
  801af6:	ff 75 0c             	pushl  0xc(%ebp)
  801af9:	68 0c 60 80 00       	push   $0x80600c
  801afe:	e8 04 ee ff ff       	call   800907 <memmove>
	nsipcbuf.send.req_size = size;
  801b03:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b09:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b11:	b8 08 00 00 00       	mov    $0x8,%eax
  801b16:	e8 d9 fd ff ff       	call   8018f4 <nsipc>
}
  801b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b31:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b36:	8b 45 10             	mov    0x10(%ebp),%eax
  801b39:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b3e:	b8 09 00 00 00       	mov    $0x9,%eax
  801b43:	e8 ac fd ff ff       	call   8018f4 <nsipc>
}
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	e8 56 f3 ff ff       	call   800eb3 <fd2data>
  801b5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b5f:	83 c4 08             	add    $0x8,%esp
  801b62:	68 bc 29 80 00       	push   $0x8029bc
  801b67:	53                   	push   %ebx
  801b68:	e8 08 ec ff ff       	call   800775 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b6d:	8b 56 04             	mov    0x4(%esi),%edx
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	2b 06                	sub    (%esi),%eax
  801b74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b7a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b81:	00 00 00 
	stat->st_dev = &devpipe;
  801b84:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b8b:	30 80 00 
	return 0;
}
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 0c             	sub    $0xc,%esp
  801ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba4:	53                   	push   %ebx
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 57 f0 ff ff       	call   800c03 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bac:	89 1c 24             	mov    %ebx,(%esp)
  801baf:	e8 ff f2 ff ff       	call   800eb3 <fd2data>
  801bb4:	83 c4 08             	add    $0x8,%esp
  801bb7:	50                   	push   %eax
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 44 f0 ff ff       	call   800c03 <sys_page_unmap>
}
  801bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 1c             	sub    $0x1c,%esp
  801bcd:	89 c6                	mov    %eax,%esi
  801bcf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd2:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	56                   	push   %esi
  801bde:	e8 38 05 00 00       	call   80211b <pageref>
  801be3:	89 c7                	mov    %eax,%edi
  801be5:	83 c4 04             	add    $0x4,%esp
  801be8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801beb:	e8 2b 05 00 00       	call   80211b <pageref>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	39 c7                	cmp    %eax,%edi
  801bf5:	0f 94 c2             	sete   %dl
  801bf8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801bfb:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c01:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c04:	39 fb                	cmp    %edi,%ebx
  801c06:	74 19                	je     801c21 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801c08:	84 d2                	test   %dl,%dl
  801c0a:	74 c6                	je     801bd2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c0c:	8b 51 58             	mov    0x58(%ecx),%edx
  801c0f:	50                   	push   %eax
  801c10:	52                   	push   %edx
  801c11:	53                   	push   %ebx
  801c12:	68 c3 29 80 00       	push   $0x8029c3
  801c17:	e8 d2 e5 ff ff       	call   8001ee <cprintf>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	eb b1                	jmp    801bd2 <_pipeisclosed+0xe>
	}
}
  801c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 28             	sub    $0x28,%esp
  801c32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c35:	56                   	push   %esi
  801c36:	e8 78 f2 ff ff       	call   800eb3 <fd2data>
  801c3b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	bf 00 00 00 00       	mov    $0x0,%edi
  801c45:	eb 4b                	jmp    801c92 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c47:	89 da                	mov    %ebx,%edx
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	e8 74 ff ff ff       	call   801bc4 <_pipeisclosed>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	75 48                	jne    801c9c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c54:	e8 06 ef ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c59:	8b 43 04             	mov    0x4(%ebx),%eax
  801c5c:	8b 0b                	mov    (%ebx),%ecx
  801c5e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c61:	39 d0                	cmp    %edx,%eax
  801c63:	73 e2                	jae    801c47 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	c1 fa 1f             	sar    $0x1f,%edx
  801c74:	89 d1                	mov    %edx,%ecx
  801c76:	c1 e9 1b             	shr    $0x1b,%ecx
  801c79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c7c:	83 e2 1f             	and    $0x1f,%edx
  801c7f:	29 ca                	sub    %ecx,%edx
  801c81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c89:	83 c0 01             	add    $0x1,%eax
  801c8c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8f:	83 c7 01             	add    $0x1,%edi
  801c92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c95:	75 c2                	jne    801c59 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c97:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9a:	eb 05                	jmp    801ca1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 18             	sub    $0x18,%esp
  801cb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cb5:	57                   	push   %edi
  801cb6:	e8 f8 f1 ff ff       	call   800eb3 <fd2data>
  801cbb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc5:	eb 3d                	jmp    801d04 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc7:	85 db                	test   %ebx,%ebx
  801cc9:	74 04                	je     801ccf <devpipe_read+0x26>
				return i;
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	eb 44                	jmp    801d13 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ccf:	89 f2                	mov    %esi,%edx
  801cd1:	89 f8                	mov    %edi,%eax
  801cd3:	e8 ec fe ff ff       	call   801bc4 <_pipeisclosed>
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	75 32                	jne    801d0e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cdc:	e8 7e ee ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce1:	8b 06                	mov    (%esi),%eax
  801ce3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ce6:	74 df                	je     801cc7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce8:	99                   	cltd   
  801ce9:	c1 ea 1b             	shr    $0x1b,%edx
  801cec:	01 d0                	add    %edx,%eax
  801cee:	83 e0 1f             	and    $0x1f,%eax
  801cf1:	29 d0                	sub    %edx,%eax
  801cf3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cfe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d01:	83 c3 01             	add    $0x1,%ebx
  801d04:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d07:	75 d8                	jne    801ce1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d09:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0c:	eb 05                	jmp    801d13 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d26:	50                   	push   %eax
  801d27:	e8 9e f1 ff ff       	call   800eca <fd_alloc>
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	89 c2                	mov    %eax,%edx
  801d31:	85 c0                	test   %eax,%eax
  801d33:	0f 88 2c 01 00 00    	js     801e65 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	68 07 04 00 00       	push   $0x407
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	6a 00                	push   $0x0
  801d46:	e8 33 ee ff ff       	call   800b7e <sys_page_alloc>
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	89 c2                	mov    %eax,%edx
  801d50:	85 c0                	test   %eax,%eax
  801d52:	0f 88 0d 01 00 00    	js     801e65 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d58:	83 ec 0c             	sub    $0xc,%esp
  801d5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d5e:	50                   	push   %eax
  801d5f:	e8 66 f1 ff ff       	call   800eca <fd_alloc>
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	0f 88 e2 00 00 00    	js     801e53 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	68 07 04 00 00       	push   $0x407
  801d79:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7c:	6a 00                	push   $0x0
  801d7e:	e8 fb ed ff ff       	call   800b7e <sys_page_alloc>
  801d83:	89 c3                	mov    %eax,%ebx
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	0f 88 c3 00 00 00    	js     801e53 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	e8 18 f1 ff ff       	call   800eb3 <fd2data>
  801d9b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9d:	83 c4 0c             	add    $0xc,%esp
  801da0:	68 07 04 00 00       	push   $0x407
  801da5:	50                   	push   %eax
  801da6:	6a 00                	push   $0x0
  801da8:	e8 d1 ed ff ff       	call   800b7e <sys_page_alloc>
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	0f 88 89 00 00 00    	js     801e43 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc0:	e8 ee f0 ff ff       	call   800eb3 <fd2data>
  801dc5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dcc:	50                   	push   %eax
  801dcd:	6a 00                	push   $0x0
  801dcf:	56                   	push   %esi
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 ea ed ff ff       	call   800bc1 <sys_page_map>
  801dd7:	89 c3                	mov    %eax,%ebx
  801dd9:	83 c4 20             	add    $0x20,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 55                	js     801e35 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801df5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e03:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e0a:	83 ec 0c             	sub    $0xc,%esp
  801e0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e10:	e8 8e f0 ff ff       	call   800ea3 <fd2num>
  801e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e18:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e1a:	83 c4 04             	add    $0x4,%esp
  801e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e20:	e8 7e f0 ff ff       	call   800ea3 <fd2num>
  801e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e28:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e33:	eb 30                	jmp    801e65 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e35:	83 ec 08             	sub    $0x8,%esp
  801e38:	56                   	push   %esi
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 c3 ed ff ff       	call   800c03 <sys_page_unmap>
  801e40:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	ff 75 f0             	pushl  -0x10(%ebp)
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 b3 ed ff ff       	call   800c03 <sys_page_unmap>
  801e50:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	ff 75 f4             	pushl  -0xc(%ebp)
  801e59:	6a 00                	push   $0x0
  801e5b:	e8 a3 ed ff ff       	call   800c03 <sys_page_unmap>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	ff 75 08             	pushl  0x8(%ebp)
  801e7b:	e8 99 f0 ff ff       	call   800f19 <fd_lookup>
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 d2                	test   %edx,%edx
  801e87:	78 18                	js     801ea1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8f:	e8 1f f0 ff ff       	call   800eb3 <fd2data>
	return _pipeisclosed(fd, p);
  801e94:	89 c2                	mov    %eax,%edx
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	e8 26 fd ff ff       	call   801bc4 <_pipeisclosed>
  801e9e:	83 c4 10             	add    $0x10,%esp
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb3:	68 db 29 80 00       	push   $0x8029db
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	e8 b5 e8 ff ff       	call   800775 <strcpy>
	return 0;
}
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	57                   	push   %edi
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ede:	eb 2d                	jmp    801f0d <devcons_write+0x46>
		m = n - tot;
  801ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ee5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eed:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	53                   	push   %ebx
  801ef4:	03 45 0c             	add    0xc(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	57                   	push   %edi
  801ef9:	e8 09 ea ff ff       	call   800907 <memmove>
		sys_cputs(buf, m);
  801efe:	83 c4 08             	add    $0x8,%esp
  801f01:	53                   	push   %ebx
  801f02:	57                   	push   %edi
  801f03:	e8 ba eb ff ff       	call   800ac2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f08:	01 de                	add    %ebx,%esi
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f12:	72 cc                	jb     801ee0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2b:	75 07                	jne    801f34 <devcons_read+0x18>
  801f2d:	eb 28                	jmp    801f57 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f2f:	e8 2b ec ff ff       	call   800b5f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f34:	e8 a7 eb ff ff       	call   800ae0 <sys_cgetc>
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	74 f2                	je     801f2f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 16                	js     801f57 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f41:	83 f8 04             	cmp    $0x4,%eax
  801f44:	74 0c                	je     801f52 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f49:	88 02                	mov    %al,(%edx)
	return 1;
  801f4b:	b8 01 00 00 00       	mov    $0x1,%eax
  801f50:	eb 05                	jmp    801f57 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f65:	6a 01                	push   $0x1
  801f67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	e8 52 eb ff ff       	call   800ac2 <sys_cputs>
  801f70:	83 c4 10             	add    $0x10,%esp
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <getchar>:

int
getchar(void)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f7b:	6a 01                	push   $0x1
  801f7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	6a 00                	push   $0x0
  801f83:	e8 00 f2 ff ff       	call   801188 <read>
	if (r < 0)
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	78 0f                	js     801f9e <getchar+0x29>
		return r;
	if (r < 1)
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	7e 06                	jle    801f99 <getchar+0x24>
		return -E_EOF;
	return c;
  801f93:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f97:	eb 05                	jmp    801f9e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f99:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa9:	50                   	push   %eax
  801faa:	ff 75 08             	pushl  0x8(%ebp)
  801fad:	e8 67 ef ff ff       	call   800f19 <fd_lookup>
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 11                	js     801fca <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc2:	39 10                	cmp    %edx,(%eax)
  801fc4:	0f 94 c0             	sete   %al
  801fc7:	0f b6 c0             	movzbl %al,%eax
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <opencons>:

int
opencons(void)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	e8 ef ee ff ff       	call   800eca <fd_alloc>
  801fdb:	83 c4 10             	add    $0x10,%esp
		return r;
  801fde:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 3e                	js     802022 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe4:	83 ec 04             	sub    $0x4,%esp
  801fe7:	68 07 04 00 00       	push   $0x407
  801fec:	ff 75 f4             	pushl  -0xc(%ebp)
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 88 eb ff ff       	call   800b7e <sys_page_alloc>
  801ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 23                	js     802022 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fff:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802014:	83 ec 0c             	sub    $0xc,%esp
  802017:	50                   	push   %eax
  802018:	e8 86 ee ff ff       	call   800ea3 <fd2num>
  80201d:	89 c2                	mov    %eax,%edx
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	89 d0                	mov    %edx,%eax
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	56                   	push   %esi
  80202a:	53                   	push   %ebx
  80202b:	8b 75 08             	mov    0x8(%ebp),%esi
  80202e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802031:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802034:	85 c0                	test   %eax,%eax
  802036:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80203b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	50                   	push   %eax
  802042:	e8 e7 ec ff ff       	call   800d2e <sys_ipc_recv>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	79 16                	jns    802064 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80204e:	85 f6                	test   %esi,%esi
  802050:	74 06                	je     802058 <ipc_recv+0x32>
  802052:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802058:	85 db                	test   %ebx,%ebx
  80205a:	74 2c                	je     802088 <ipc_recv+0x62>
  80205c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802062:	eb 24                	jmp    802088 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802064:	85 f6                	test   %esi,%esi
  802066:	74 0a                	je     802072 <ipc_recv+0x4c>
  802068:	a1 08 40 80 00       	mov    0x804008,%eax
  80206d:	8b 40 74             	mov    0x74(%eax),%eax
  802070:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802072:	85 db                	test   %ebx,%ebx
  802074:	74 0a                	je     802080 <ipc_recv+0x5a>
  802076:	a1 08 40 80 00       	mov    0x804008,%eax
  80207b:	8b 40 78             	mov    0x78(%eax),%eax
  80207e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802080:	a1 08 40 80 00       	mov    0x804008,%eax
  802085:	8b 40 70             	mov    0x70(%eax),%eax
}
  802088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	57                   	push   %edi
  802093:	56                   	push   %esi
  802094:	53                   	push   %ebx
  802095:	83 ec 0c             	sub    $0xc,%esp
  802098:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80209e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8020a1:	85 db                	test   %ebx,%ebx
  8020a3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a8:	0f 44 d8             	cmove  %eax,%ebx
  8020ab:	eb 1c                	jmp    8020c9 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8020ad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b0:	74 12                	je     8020c4 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8020b2:	50                   	push   %eax
  8020b3:	68 e7 29 80 00       	push   $0x8029e7
  8020b8:	6a 39                	push   $0x39
  8020ba:	68 02 2a 80 00       	push   $0x802a02
  8020bf:	e8 51 e0 ff ff       	call   800115 <_panic>
                 sys_yield();
  8020c4:	e8 96 ea ff ff       	call   800b5f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020c9:	ff 75 14             	pushl  0x14(%ebp)
  8020cc:	53                   	push   %ebx
  8020cd:	56                   	push   %esi
  8020ce:	57                   	push   %edi
  8020cf:	e8 37 ec ff ff       	call   800d0b <sys_ipc_try_send>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 d2                	js     8020ad <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8020db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ee:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020f1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f7:	8b 52 50             	mov    0x50(%edx),%edx
  8020fa:	39 ca                	cmp    %ecx,%edx
  8020fc:	75 0d                	jne    80210b <ipc_find_env+0x28>
			return envs[i].env_id;
  8020fe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802101:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802106:	8b 40 08             	mov    0x8(%eax),%eax
  802109:	eb 0e                	jmp    802119 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80210b:	83 c0 01             	add    $0x1,%eax
  80210e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802113:	75 d9                	jne    8020ee <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802115:	66 b8 00 00          	mov    $0x0,%ax
}
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    

0080211b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802121:	89 d0                	mov    %edx,%eax
  802123:	c1 e8 16             	shr    $0x16,%eax
  802126:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802132:	f6 c1 01             	test   $0x1,%cl
  802135:	74 1d                	je     802154 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802137:	c1 ea 0c             	shr    $0xc,%edx
  80213a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802141:	f6 c2 01             	test   $0x1,%dl
  802144:	74 0e                	je     802154 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802146:	c1 ea 0c             	shr    $0xc,%edx
  802149:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802150:	ef 
  802151:	0f b7 c0             	movzwl %ax,%eax
}
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	83 ec 10             	sub    $0x10,%esp
  802166:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80216a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80216e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802172:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802176:	85 d2                	test   %edx,%edx
  802178:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80217c:	89 34 24             	mov    %esi,(%esp)
  80217f:	89 c8                	mov    %ecx,%eax
  802181:	75 35                	jne    8021b8 <__udivdi3+0x58>
  802183:	39 f1                	cmp    %esi,%ecx
  802185:	0f 87 bd 00 00 00    	ja     802248 <__udivdi3+0xe8>
  80218b:	85 c9                	test   %ecx,%ecx
  80218d:	89 cd                	mov    %ecx,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f1                	div    %ecx
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 f0                	mov    %esi,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c6                	mov    %eax,%esi
  8021a4:	89 f8                	mov    %edi,%eax
  8021a6:	f7 f5                	div    %ebp
  8021a8:	89 f2                	mov    %esi,%edx
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	3b 14 24             	cmp    (%esp),%edx
  8021bb:	77 7b                	ja     802238 <__udivdi3+0xd8>
  8021bd:	0f bd f2             	bsr    %edx,%esi
  8021c0:	83 f6 1f             	xor    $0x1f,%esi
  8021c3:	0f 84 97 00 00 00    	je     802260 <__udivdi3+0x100>
  8021c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021ce:	89 d7                	mov    %edx,%edi
  8021d0:	89 f1                	mov    %esi,%ecx
  8021d2:	29 f5                	sub    %esi,%ebp
  8021d4:	d3 e7                	shl    %cl,%edi
  8021d6:	89 c2                	mov    %eax,%edx
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	d3 ea                	shr    %cl,%edx
  8021dc:	89 f1                	mov    %esi,%ecx
  8021de:	09 fa                	or     %edi,%edx
  8021e0:	8b 3c 24             	mov    (%esp),%edi
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021f3:	89 fa                	mov    %edi,%edx
  8021f5:	d3 ea                	shr    %cl,%edx
  8021f7:	89 f1                	mov    %esi,%ecx
  8021f9:	d3 e7                	shl    %cl,%edi
  8021fb:	89 e9                	mov    %ebp,%ecx
  8021fd:	d3 e8                	shr    %cl,%eax
  8021ff:	09 c7                	or     %eax,%edi
  802201:	89 f8                	mov    %edi,%eax
  802203:	f7 74 24 08          	divl   0x8(%esp)
  802207:	89 d5                	mov    %edx,%ebp
  802209:	89 c7                	mov    %eax,%edi
  80220b:	f7 64 24 0c          	mull   0xc(%esp)
  80220f:	39 d5                	cmp    %edx,%ebp
  802211:	89 14 24             	mov    %edx,(%esp)
  802214:	72 11                	jb     802227 <__udivdi3+0xc7>
  802216:	8b 54 24 04          	mov    0x4(%esp),%edx
  80221a:	89 f1                	mov    %esi,%ecx
  80221c:	d3 e2                	shl    %cl,%edx
  80221e:	39 c2                	cmp    %eax,%edx
  802220:	73 5e                	jae    802280 <__udivdi3+0x120>
  802222:	3b 2c 24             	cmp    (%esp),%ebp
  802225:	75 59                	jne    802280 <__udivdi3+0x120>
  802227:	8d 47 ff             	lea    -0x1(%edi),%eax
  80222a:	31 f6                	xor    %esi,%esi
  80222c:	89 f2                	mov    %esi,%edx
  80222e:	83 c4 10             	add    $0x10,%esp
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	31 f6                	xor    %esi,%esi
  80223a:	31 c0                	xor    %eax,%eax
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	89 f2                	mov    %esi,%edx
  80224a:	31 f6                	xor    %esi,%esi
  80224c:	89 f8                	mov    %edi,%eax
  80224e:	f7 f1                	div    %ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802264:	76 0b                	jbe    802271 <__udivdi3+0x111>
  802266:	31 c0                	xor    %eax,%eax
  802268:	3b 14 24             	cmp    (%esp),%edx
  80226b:	0f 83 37 ff ff ff    	jae    8021a8 <__udivdi3+0x48>
  802271:	b8 01 00 00 00       	mov    $0x1,%eax
  802276:	e9 2d ff ff ff       	jmp    8021a8 <__udivdi3+0x48>
  80227b:	90                   	nop
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 f8                	mov    %edi,%eax
  802282:	31 f6                	xor    %esi,%esi
  802284:	e9 1f ff ff ff       	jmp    8021a8 <__udivdi3+0x48>
  802289:	66 90                	xchg   %ax,%ax
  80228b:	66 90                	xchg   %ax,%ax
  80228d:	66 90                	xchg   %ax,%ax
  80228f:	90                   	nop

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 20             	sub    $0x20,%esp
  802296:	8b 44 24 34          	mov    0x34(%esp),%eax
  80229a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a2:	89 c6                	mov    %eax,%esi
  8022a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8022b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	89 c2                	mov    %eax,%edx
  8022c0:	75 1e                	jne    8022e0 <__umoddi3+0x50>
  8022c2:	39 f7                	cmp    %esi,%edi
  8022c4:	76 52                	jbe    802318 <__umoddi3+0x88>
  8022c6:	89 c8                	mov    %ecx,%eax
  8022c8:	89 f2                	mov    %esi,%edx
  8022ca:	f7 f7                	div    %edi
  8022cc:	89 d0                	mov    %edx,%eax
  8022ce:	31 d2                	xor    %edx,%edx
  8022d0:	83 c4 20             	add    $0x20,%esp
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    
  8022d7:	89 f6                	mov    %esi,%esi
  8022d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022e0:	39 f0                	cmp    %esi,%eax
  8022e2:	77 5c                	ja     802340 <__umoddi3+0xb0>
  8022e4:	0f bd e8             	bsr    %eax,%ebp
  8022e7:	83 f5 1f             	xor    $0x1f,%ebp
  8022ea:	75 64                	jne    802350 <__umoddi3+0xc0>
  8022ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022f4:	0f 86 f6 00 00 00    	jbe    8023f0 <__umoddi3+0x160>
  8022fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022fe:	0f 82 ec 00 00 00    	jb     8023f0 <__umoddi3+0x160>
  802304:	8b 44 24 14          	mov    0x14(%esp),%eax
  802308:	8b 54 24 18          	mov    0x18(%esp),%edx
  80230c:	83 c4 20             	add    $0x20,%esp
  80230f:	5e                   	pop    %esi
  802310:	5f                   	pop    %edi
  802311:	5d                   	pop    %ebp
  802312:	c3                   	ret    
  802313:	90                   	nop
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	85 ff                	test   %edi,%edi
  80231a:	89 fd                	mov    %edi,%ebp
  80231c:	75 0b                	jne    802329 <__umoddi3+0x99>
  80231e:	b8 01 00 00 00       	mov    $0x1,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f7                	div    %edi
  802327:	89 c5                	mov    %eax,%ebp
  802329:	8b 44 24 10          	mov    0x10(%esp),%eax
  80232d:	31 d2                	xor    %edx,%edx
  80232f:	f7 f5                	div    %ebp
  802331:	89 c8                	mov    %ecx,%eax
  802333:	f7 f5                	div    %ebp
  802335:	eb 95                	jmp    8022cc <__umoddi3+0x3c>
  802337:	89 f6                	mov    %esi,%esi
  802339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 20             	add    $0x20,%esp
  802347:	5e                   	pop    %esi
  802348:	5f                   	pop    %edi
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    
  80234b:	90                   	nop
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	b8 20 00 00 00       	mov    $0x20,%eax
  802355:	89 e9                	mov    %ebp,%ecx
  802357:	29 e8                	sub    %ebp,%eax
  802359:	d3 e2                	shl    %cl,%edx
  80235b:	89 c7                	mov    %eax,%edi
  80235d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802361:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802365:	89 f9                	mov    %edi,%ecx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	89 c1                	mov    %eax,%ecx
  80236b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80236f:	09 d1                	or     %edx,%ecx
  802371:	89 fa                	mov    %edi,%edx
  802373:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802377:	89 e9                	mov    %ebp,%ecx
  802379:	d3 e0                	shl    %cl,%eax
  80237b:	89 f9                	mov    %edi,%ecx
  80237d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802381:	89 f0                	mov    %esi,%eax
  802383:	d3 e8                	shr    %cl,%eax
  802385:	89 e9                	mov    %ebp,%ecx
  802387:	89 c7                	mov    %eax,%edi
  802389:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80238d:	d3 e6                	shl    %cl,%esi
  80238f:	89 d1                	mov    %edx,%ecx
  802391:	89 fa                	mov    %edi,%edx
  802393:	d3 e8                	shr    %cl,%eax
  802395:	89 e9                	mov    %ebp,%ecx
  802397:	09 f0                	or     %esi,%eax
  802399:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80239d:	f7 74 24 10          	divl   0x10(%esp)
  8023a1:	d3 e6                	shl    %cl,%esi
  8023a3:	89 d1                	mov    %edx,%ecx
  8023a5:	f7 64 24 0c          	mull   0xc(%esp)
  8023a9:	39 d1                	cmp    %edx,%ecx
  8023ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8023af:	89 d7                	mov    %edx,%edi
  8023b1:	89 c6                	mov    %eax,%esi
  8023b3:	72 0a                	jb     8023bf <__umoddi3+0x12f>
  8023b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8023b9:	73 10                	jae    8023cb <__umoddi3+0x13b>
  8023bb:	39 d1                	cmp    %edx,%ecx
  8023bd:	75 0c                	jne    8023cb <__umoddi3+0x13b>
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	89 c6                	mov    %eax,%esi
  8023c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8023c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8023cb:	89 ca                	mov    %ecx,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d3:	29 f0                	sub    %esi,%eax
  8023d5:	19 fa                	sbb    %edi,%edx
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8023de:	89 d7                	mov    %edx,%edi
  8023e0:	d3 e7                	shl    %cl,%edi
  8023e2:	89 e9                	mov    %ebp,%ecx
  8023e4:	09 f8                	or     %edi,%eax
  8023e6:	d3 ea                	shr    %cl,%edx
  8023e8:	83 c4 20             	add    $0x20,%esp
  8023eb:	5e                   	pop    %esi
  8023ec:	5f                   	pop    %edi
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    
  8023ef:	90                   	nop
  8023f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023f4:	29 f9                	sub    %edi,%ecx
  8023f6:	19 c6                	sbb    %eax,%esi
  8023f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802400:	e9 ff fe ff ff       	jmp    802304 <__umoddi3+0x74>
