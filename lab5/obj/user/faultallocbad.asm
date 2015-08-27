
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
  800040:	68 00 1f 80 00       	push   $0x801f00
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
  80006a:	68 20 1f 80 00       	push   $0x801f20
  80006f:	6a 0f                	push   $0xf
  800071:	68 0a 1f 80 00       	push   $0x801f0a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 1f 80 00       	push   $0x801f4c
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
  80009c:	e8 ce 0c 00 00       	call   800d6f <set_pgfault_handler>
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
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800101:	e8 c9 0e 00 00       	call   800fcf <close_all>
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
  800133:	68 78 1f 80 00       	push   $0x801f78
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 57 24 80 00 	movl   $0x802457,(%esp)
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
  800251:	e8 ea 19 00 00       	call   801c40 <__udivdi3>
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
  80028f:	e8 dc 1a 00 00       	call   801d70 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
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
  800393:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
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
  800457:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 18                	jne    80047a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 b3 1f 80 00       	push   $0x801fb3
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
  80047b:	68 25 24 80 00       	push   $0x802425
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
  8004a8:	ba ac 1f 80 00       	mov    $0x801fac,%edx
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
  800b27:	68 df 22 80 00       	push   $0x8022df
  800b2c:	6a 23                	push   $0x23
  800b2e:	68 fc 22 80 00       	push   $0x8022fc
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
  800ba8:	68 df 22 80 00       	push   $0x8022df
  800bad:	6a 23                	push   $0x23
  800baf:	68 fc 22 80 00       	push   $0x8022fc
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
  800bea:	68 df 22 80 00       	push   $0x8022df
  800bef:	6a 23                	push   $0x23
  800bf1:	68 fc 22 80 00       	push   $0x8022fc
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
  800c2c:	68 df 22 80 00       	push   $0x8022df
  800c31:	6a 23                	push   $0x23
  800c33:	68 fc 22 80 00       	push   $0x8022fc
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
  800c6e:	68 df 22 80 00       	push   $0x8022df
  800c73:	6a 23                	push   $0x23
  800c75:	68 fc 22 80 00       	push   $0x8022fc
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
  800cb0:	68 df 22 80 00       	push   $0x8022df
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 fc 22 80 00       	push   $0x8022fc
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
  800cf2:	68 df 22 80 00       	push   $0x8022df
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 fc 22 80 00       	push   $0x8022fc
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
  800d56:	68 df 22 80 00       	push   $0x8022df
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 fc 22 80 00       	push   $0x8022fc
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

00800d6f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d75:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d7c:	75 2c                	jne    800daa <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	6a 07                	push   $0x7
  800d83:	68 00 f0 bf ee       	push   $0xeebff000
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 ef fd ff ff       	call   800b7e <sys_page_alloc>
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	74 14                	je     800daa <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 0c 23 80 00       	push   $0x80230c
  800d9e:	6a 21                	push   $0x21
  800da0:	68 6e 23 80 00       	push   $0x80236e
  800da5:	e8 6b f3 ff ff       	call   800115 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	a3 08 40 80 00       	mov    %eax,0x804008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800db2:	83 ec 08             	sub    $0x8,%esp
  800db5:	68 de 0d 80 00       	push   $0x800dde
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 08 ff ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	79 14                	jns    800ddc <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	68 38 23 80 00       	push   $0x802338
  800dd0:	6a 29                	push   $0x29
  800dd2:	68 6e 23 80 00       	push   $0x80236e
  800dd7:	e8 39 f3 ff ff       	call   800115 <_panic>
}
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    

00800dde <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dde:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ddf:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800de9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800dee:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800df2:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800df6:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800df8:	83 c4 08             	add    $0x8,%esp
        popal
  800dfb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800dfc:	83 c4 04             	add    $0x4,%esp
        popfl
  800dff:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800e00:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e01:	c3                   	ret    

00800e02 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e22:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e34:	89 c2                	mov    %eax,%edx
  800e36:	c1 ea 16             	shr    $0x16,%edx
  800e39:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e40:	f6 c2 01             	test   $0x1,%dl
  800e43:	74 11                	je     800e56 <fd_alloc+0x2d>
  800e45:	89 c2                	mov    %eax,%edx
  800e47:	c1 ea 0c             	shr    $0xc,%edx
  800e4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e51:	f6 c2 01             	test   $0x1,%dl
  800e54:	75 09                	jne    800e5f <fd_alloc+0x36>
			*fd_store = fd;
  800e56:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5d:	eb 17                	jmp    800e76 <fd_alloc+0x4d>
  800e5f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e64:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e69:	75 c9                	jne    800e34 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e71:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7e:	83 f8 1f             	cmp    $0x1f,%eax
  800e81:	77 36                	ja     800eb9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e83:	c1 e0 0c             	shl    $0xc,%eax
  800e86:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	c1 ea 16             	shr    $0x16,%edx
  800e90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e97:	f6 c2 01             	test   $0x1,%dl
  800e9a:	74 24                	je     800ec0 <fd_lookup+0x48>
  800e9c:	89 c2                	mov    %eax,%edx
  800e9e:	c1 ea 0c             	shr    $0xc,%edx
  800ea1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea8:	f6 c2 01             	test   $0x1,%dl
  800eab:	74 1a                	je     800ec7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ead:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb0:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 13                	jmp    800ecc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebe:	eb 0c                	jmp    800ecc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec5:	eb 05                	jmp    800ecc <fd_lookup+0x54>
  800ec7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 08             	sub    $0x8,%esp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	ba fc 23 80 00       	mov    $0x8023fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edc:	eb 13                	jmp    800ef1 <dev_lookup+0x23>
  800ede:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee1:	39 08                	cmp    %ecx,(%eax)
  800ee3:	75 0c                	jne    800ef1 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb 2e                	jmp    800f1f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef1:	8b 02                	mov    (%edx),%eax
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	75 e7                	jne    800ede <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef7:	a1 04 40 80 00       	mov    0x804004,%eax
  800efc:	8b 40 48             	mov    0x48(%eax),%eax
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	51                   	push   %ecx
  800f03:	50                   	push   %eax
  800f04:	68 7c 23 80 00       	push   $0x80237c
  800f09:	e8 e0 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f17:	83 c4 10             	add    $0x10,%esp
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 10             	sub    $0x10,%esp
  800f29:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f32:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f33:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f39:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3c:	50                   	push   %eax
  800f3d:	e8 36 ff ff ff       	call   800e78 <fd_lookup>
  800f42:	83 c4 08             	add    $0x8,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 05                	js     800f4e <fd_close+0x2d>
	    || fd != fd2)
  800f49:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4c:	74 0c                	je     800f5a <fd_close+0x39>
		return (must_exist ? r : 0);
  800f4e:	84 db                	test   %bl,%bl
  800f50:	ba 00 00 00 00       	mov    $0x0,%edx
  800f55:	0f 44 c2             	cmove  %edx,%eax
  800f58:	eb 41                	jmp    800f9b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	ff 36                	pushl  (%esi)
  800f63:	e8 66 ff ff ff       	call   800ece <dev_lookup>
  800f68:	89 c3                	mov    %eax,%ebx
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 1a                	js     800f8b <fd_close+0x6a>
		if (dev->dev_close)
  800f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f74:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	74 0b                	je     800f8b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	56                   	push   %esi
  800f84:	ff d0                	call   *%eax
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	56                   	push   %esi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 6d fc ff ff       	call   800c03 <sys_page_unmap>
	return r;
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	89 d8                	mov    %ebx,%eax
}
  800f9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 08             	pushl  0x8(%ebp)
  800faf:	e8 c4 fe ff ff       	call   800e78 <fd_lookup>
  800fb4:	89 c2                	mov    %eax,%edx
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	85 d2                	test   %edx,%edx
  800fbb:	78 10                	js     800fcd <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	6a 01                	push   $0x1
  800fc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc5:	e8 57 ff ff ff       	call   800f21 <fd_close>
  800fca:	83 c4 10             	add    $0x10,%esp
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <close_all>:

void
close_all(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	53                   	push   %ebx
  800fdf:	e8 be ff ff ff       	call   800fa2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe4:	83 c3 01             	add    $0x1,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	83 fb 20             	cmp    $0x20,%ebx
  800fed:	75 ec                	jne    800fdb <close_all+0xc>
		close(i);
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 2c             	sub    $0x2c,%esp
  800ffd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	ff 75 08             	pushl  0x8(%ebp)
  801007:	e8 6c fe ff ff       	call   800e78 <fd_lookup>
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	85 d2                	test   %edx,%edx
  801013:	0f 88 c1 00 00 00    	js     8010da <dup+0xe6>
		return r;
	close(newfdnum);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	56                   	push   %esi
  80101d:	e8 80 ff ff ff       	call   800fa2 <close>

	newfd = INDEX2FD(newfdnum);
  801022:	89 f3                	mov    %esi,%ebx
  801024:	c1 e3 0c             	shl    $0xc,%ebx
  801027:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102d:	83 c4 04             	add    $0x4,%esp
  801030:	ff 75 e4             	pushl  -0x1c(%ebp)
  801033:	e8 da fd ff ff       	call   800e12 <fd2data>
  801038:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80103a:	89 1c 24             	mov    %ebx,(%esp)
  80103d:	e8 d0 fd ff ff       	call   800e12 <fd2data>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801048:	89 f8                	mov    %edi,%eax
  80104a:	c1 e8 16             	shr    $0x16,%eax
  80104d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801054:	a8 01                	test   $0x1,%al
  801056:	74 37                	je     80108f <dup+0x9b>
  801058:	89 f8                	mov    %edi,%eax
  80105a:	c1 e8 0c             	shr    $0xc,%eax
  80105d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801064:	f6 c2 01             	test   $0x1,%dl
  801067:	74 26                	je     80108f <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801069:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	25 07 0e 00 00       	and    $0xe07,%eax
  801078:	50                   	push   %eax
  801079:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107c:	6a 00                	push   $0x0
  80107e:	57                   	push   %edi
  80107f:	6a 00                	push   $0x0
  801081:	e8 3b fb ff ff       	call   800bc1 <sys_page_map>
  801086:	89 c7                	mov    %eax,%edi
  801088:	83 c4 20             	add    $0x20,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 2e                	js     8010bd <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801092:	89 d0                	mov    %edx,%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
  801097:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a6:	50                   	push   %eax
  8010a7:	53                   	push   %ebx
  8010a8:	6a 00                	push   $0x0
  8010aa:	52                   	push   %edx
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 0f fb ff ff       	call   800bc1 <sys_page_map>
  8010b2:	89 c7                	mov    %eax,%edi
  8010b4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b9:	85 ff                	test   %edi,%edi
  8010bb:	79 1d                	jns    8010da <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	53                   	push   %ebx
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 3b fb ff ff       	call   800c03 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c8:	83 c4 08             	add    $0x8,%esp
  8010cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 2e fb ff ff       	call   800c03 <sys_page_unmap>
	return r;
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	89 f8                	mov    %edi,%eax
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 14             	sub    $0x14,%esp
  8010e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	53                   	push   %ebx
  8010f1:	e8 82 fd ff ff       	call   800e78 <fd_lookup>
  8010f6:	83 c4 08             	add    $0x8,%esp
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 6d                	js     80116c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	ff 30                	pushl  (%eax)
  80110b:	e8 be fd ff ff       	call   800ece <dev_lookup>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	78 4c                	js     801163 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801117:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80111a:	8b 42 08             	mov    0x8(%edx),%eax
  80111d:	83 e0 03             	and    $0x3,%eax
  801120:	83 f8 01             	cmp    $0x1,%eax
  801123:	75 21                	jne    801146 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801125:	a1 04 40 80 00       	mov    0x804004,%eax
  80112a:	8b 40 48             	mov    0x48(%eax),%eax
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	53                   	push   %ebx
  801131:	50                   	push   %eax
  801132:	68 c0 23 80 00       	push   $0x8023c0
  801137:	e8 b2 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801144:	eb 26                	jmp    80116c <read+0x8a>
	}
	if (!dev->dev_read)
  801146:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801149:	8b 40 08             	mov    0x8(%eax),%eax
  80114c:	85 c0                	test   %eax,%eax
  80114e:	74 17                	je     801167 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	ff 75 10             	pushl  0x10(%ebp)
  801156:	ff 75 0c             	pushl  0xc(%ebp)
  801159:	52                   	push   %edx
  80115a:	ff d0                	call   *%eax
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	eb 09                	jmp    80116c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801163:	89 c2                	mov    %eax,%edx
  801165:	eb 05                	jmp    80116c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801167:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80116c:	89 d0                	mov    %edx,%eax
  80116e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	eb 21                	jmp    8011aa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	89 f0                	mov    %esi,%eax
  80118e:	29 d8                	sub    %ebx,%eax
  801190:	50                   	push   %eax
  801191:	89 d8                	mov    %ebx,%eax
  801193:	03 45 0c             	add    0xc(%ebp),%eax
  801196:	50                   	push   %eax
  801197:	57                   	push   %edi
  801198:	e8 45 ff ff ff       	call   8010e2 <read>
		if (m < 0)
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 0c                	js     8011b0 <readn+0x3d>
			return m;
		if (m == 0)
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	74 06                	je     8011ae <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a8:	01 c3                	add    %eax,%ebx
  8011aa:	39 f3                	cmp    %esi,%ebx
  8011ac:	72 db                	jb     801189 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011ae:	89 d8                	mov    %ebx,%eax
}
  8011b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 14             	sub    $0x14,%esp
  8011bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	53                   	push   %ebx
  8011c7:	e8 ac fc ff ff       	call   800e78 <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	89 c2                	mov    %eax,%edx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 68                	js     80123d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d5:	83 ec 08             	sub    $0x8,%esp
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	ff 30                	pushl  (%eax)
  8011e1:	e8 e8 fc ff ff       	call   800ece <dev_lookup>
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 47                	js     801234 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f4:	75 21                	jne    801217 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fb:	8b 40 48             	mov    0x48(%eax),%eax
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	53                   	push   %ebx
  801202:	50                   	push   %eax
  801203:	68 dc 23 80 00       	push   $0x8023dc
  801208:	e8 e1 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801215:	eb 26                	jmp    80123d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801217:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121a:	8b 52 0c             	mov    0xc(%edx),%edx
  80121d:	85 d2                	test   %edx,%edx
  80121f:	74 17                	je     801238 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	ff 75 10             	pushl  0x10(%ebp)
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	50                   	push   %eax
  80122b:	ff d2                	call   *%edx
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 09                	jmp    80123d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	89 c2                	mov    %eax,%edx
  801236:	eb 05                	jmp    80123d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801238:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <seek>:

int
seek(int fdnum, off_t offset)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 22 fc ff ff       	call   800e78 <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 0e                	js     80126b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801260:	8b 55 0c             	mov    0xc(%ebp),%edx
  801263:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	53                   	push   %ebx
  801271:	83 ec 14             	sub    $0x14,%esp
  801274:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801277:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	53                   	push   %ebx
  80127c:	e8 f7 fb ff ff       	call   800e78 <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	89 c2                	mov    %eax,%edx
  801286:	85 c0                	test   %eax,%eax
  801288:	78 65                	js     8012ef <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	e8 33 fc ff ff       	call   800ece <dev_lookup>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 44                	js     8012e6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a9:	75 21                	jne    8012cc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ab:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b0:	8b 40 48             	mov    0x48(%eax),%eax
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	53                   	push   %ebx
  8012b7:	50                   	push   %eax
  8012b8:	68 9c 23 80 00       	push   $0x80239c
  8012bd:	e8 2c ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ca:	eb 23                	jmp    8012ef <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 18             	mov    0x18(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 14                	je     8012ea <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	pushl  0xc(%ebp)
  8012dc:	50                   	push   %eax
  8012dd:	ff d2                	call   *%edx
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	eb 09                	jmp    8012ef <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	eb 05                	jmp    8012ef <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ef:	89 d0                	mov    %edx,%eax
  8012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 14             	sub    $0x14,%esp
  8012fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801300:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	ff 75 08             	pushl  0x8(%ebp)
  801307:	e8 6c fb ff ff       	call   800e78 <fd_lookup>
  80130c:	83 c4 08             	add    $0x8,%esp
  80130f:	89 c2                	mov    %eax,%edx
  801311:	85 c0                	test   %eax,%eax
  801313:	78 58                	js     80136d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 a8 fb ff ff       	call   800ece <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 37                	js     801364 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801330:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801334:	74 32                	je     801368 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801336:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801339:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801340:	00 00 00 
	stat->st_isdir = 0;
  801343:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134a:	00 00 00 
	stat->st_dev = dev;
  80134d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	53                   	push   %ebx
  801357:	ff 75 f0             	pushl  -0x10(%ebp)
  80135a:	ff 50 14             	call   *0x14(%eax)
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	eb 09                	jmp    80136d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	89 c2                	mov    %eax,%edx
  801366:	eb 05                	jmp    80136d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801368:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136d:	89 d0                	mov    %edx,%eax
  80136f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	6a 00                	push   $0x0
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 09 02 00 00       	call   80158f <open>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 db                	test   %ebx,%ebx
  80138d:	78 1b                	js     8013aa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	ff 75 0c             	pushl  0xc(%ebp)
  801395:	53                   	push   %ebx
  801396:	e8 5b ff ff ff       	call   8012f6 <fstat>
  80139b:	89 c6                	mov    %eax,%esi
	close(fd);
  80139d:	89 1c 24             	mov    %ebx,(%esp)
  8013a0:	e8 fd fb ff ff       	call   800fa2 <close>
	return r;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	89 f0                	mov    %esi,%eax
}
  8013aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	89 c6                	mov    %eax,%esi
  8013b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ba:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c1:	75 12                	jne    8013d5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	6a 01                	push   $0x1
  8013c8:	e8 ff 07 00 00       	call   801bcc <ipc_find_env>
  8013cd:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d5:	6a 07                	push   $0x7
  8013d7:	68 00 50 80 00       	push   $0x805000
  8013dc:	56                   	push   %esi
  8013dd:	ff 35 00 40 80 00    	pushl  0x804000
  8013e3:	e8 90 07 00 00       	call   801b78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e8:	83 c4 0c             	add    $0xc,%esp
  8013eb:	6a 00                	push   $0x0
  8013ed:	53                   	push   %ebx
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 1a 07 00 00       	call   801b0f <ipc_recv>
}
  8013f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801410:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	b8 02 00 00 00       	mov    $0x2,%eax
  80141f:	e8 8d ff ff ff       	call   8013b1 <fsipc>
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	8b 40 0c             	mov    0xc(%eax),%eax
  801432:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 06 00 00 00       	mov    $0x6,%eax
  801441:	e8 6b ff ff ff       	call   8013b1 <fsipc>
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
  801455:	8b 40 0c             	mov    0xc(%eax),%eax
  801458:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	b8 05 00 00 00       	mov    $0x5,%eax
  801467:	e8 45 ff ff ff       	call   8013b1 <fsipc>
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	78 2c                	js     80149e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	68 00 50 80 00       	push   $0x805000
  80147a:	53                   	push   %ebx
  80147b:	e8 f5 f2 ff ff       	call   800775 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801480:	a1 80 50 80 00       	mov    0x805080,%eax
  801485:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148b:	a1 84 50 80 00       	mov    0x805084,%eax
  801490:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 0c             	sub    $0xc,%esp
  8014ac:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014af:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b5:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014bd:	eb 3d                	jmp    8014fc <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014bf:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014c5:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014ca:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	57                   	push   %edi
  8014d1:	53                   	push   %ebx
  8014d2:	68 08 50 80 00       	push   $0x805008
  8014d7:	e8 2b f4 ff ff       	call   800907 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014dc:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ec:	e8 c0 fe ff ff       	call   8013b1 <fsipc>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 0d                	js     801505 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8014f8:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8014fa:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014fc:	85 f6                	test   %esi,%esi
  8014fe:	75 bf                	jne    8014bf <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801500:	89 d8                	mov    %ebx,%eax
  801502:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801505:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801520:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 03 00 00 00       	mov    $0x3,%eax
  801530:	e8 7c fe ff ff       	call   8013b1 <fsipc>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	85 c0                	test   %eax,%eax
  801539:	78 4b                	js     801586 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80153b:	39 c6                	cmp    %eax,%esi
  80153d:	73 16                	jae    801555 <devfile_read+0x48>
  80153f:	68 0c 24 80 00       	push   $0x80240c
  801544:	68 13 24 80 00       	push   $0x802413
  801549:	6a 7c                	push   $0x7c
  80154b:	68 28 24 80 00       	push   $0x802428
  801550:	e8 c0 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801555:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155a:	7e 16                	jle    801572 <devfile_read+0x65>
  80155c:	68 33 24 80 00       	push   $0x802433
  801561:	68 13 24 80 00       	push   $0x802413
  801566:	6a 7d                	push   $0x7d
  801568:	68 28 24 80 00       	push   $0x802428
  80156d:	e8 a3 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	50                   	push   %eax
  801576:	68 00 50 80 00       	push   $0x805000
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	e8 84 f3 ff ff       	call   800907 <memmove>
	return r;
  801583:	83 c4 10             	add    $0x10,%esp
}
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 20             	sub    $0x20,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801599:	53                   	push   %ebx
  80159a:	e8 9d f1 ff ff       	call   80073c <strlen>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a7:	7f 67                	jg     801610 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 74 f8 ff ff       	call   800e29 <fd_alloc>
  8015b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 57                	js     801615 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	68 00 50 80 00       	push   $0x805000
  8015c7:	e8 a9 f1 ff ff       	call   800775 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dc:	e8 d0 fd ff ff       	call   8013b1 <fsipc>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	79 14                	jns    8015fe <open+0x6f>
		fd_close(fd, 0);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	6a 00                	push   $0x0
  8015ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f2:	e8 2a f9 ff ff       	call   800f21 <fd_close>
		return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 da                	mov    %ebx,%edx
  8015fc:	eb 17                	jmp    801615 <open+0x86>
	}

	return fd2num(fd);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 f9 f7 ff ff       	call   800e02 <fd2num>
  801609:	89 c2                	mov    %eax,%edx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801610:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801622:	ba 00 00 00 00       	mov    $0x0,%edx
  801627:	b8 08 00 00 00       	mov    $0x8,%eax
  80162c:	e8 80 fd ff ff       	call   8013b1 <fsipc>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	e8 cc f7 ff ff       	call   800e12 <fd2data>
  801646:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	68 3f 24 80 00       	push   $0x80243f
  801650:	53                   	push   %ebx
  801651:	e8 1f f1 ff ff       	call   800775 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801656:	8b 56 04             	mov    0x4(%esi),%edx
  801659:	89 d0                	mov    %edx,%eax
  80165b:	2b 06                	sub    (%esi),%eax
  80165d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801663:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80166a:	00 00 00 
	stat->st_dev = &devpipe;
  80166d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801674:	30 80 00 
	return 0;
}
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
  80167c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168d:	53                   	push   %ebx
  80168e:	6a 00                	push   $0x0
  801690:	e8 6e f5 ff ff       	call   800c03 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801695:	89 1c 24             	mov    %ebx,(%esp)
  801698:	e8 75 f7 ff ff       	call   800e12 <fd2data>
  80169d:	83 c4 08             	add    $0x8,%esp
  8016a0:	50                   	push   %eax
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 5b f5 ff ff       	call   800c03 <sys_page_unmap>
}
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 1c             	sub    $0x1c,%esp
  8016b6:	89 c6                	mov    %eax,%esi
  8016b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	56                   	push   %esi
  8016c7:	e8 38 05 00 00       	call   801c04 <pageref>
  8016cc:	89 c7                	mov    %eax,%edi
  8016ce:	83 c4 04             	add    $0x4,%esp
  8016d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016d4:	e8 2b 05 00 00       	call   801c04 <pageref>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	39 c7                	cmp    %eax,%edi
  8016de:	0f 94 c2             	sete   %dl
  8016e1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8016e4:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8016ea:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8016ed:	39 fb                	cmp    %edi,%ebx
  8016ef:	74 19                	je     80170a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8016f1:	84 d2                	test   %dl,%dl
  8016f3:	74 c6                	je     8016bb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f5:	8b 51 58             	mov    0x58(%ecx),%edx
  8016f8:	50                   	push   %eax
  8016f9:	52                   	push   %edx
  8016fa:	53                   	push   %ebx
  8016fb:	68 46 24 80 00       	push   $0x802446
  801700:	e8 e9 ea ff ff       	call   8001ee <cprintf>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb b1                	jmp    8016bb <_pipeisclosed+0xe>
	}
}
  80170a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	57                   	push   %edi
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	83 ec 28             	sub    $0x28,%esp
  80171b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80171e:	56                   	push   %esi
  80171f:	e8 ee f6 ff ff       	call   800e12 <fd2data>
  801724:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	bf 00 00 00 00       	mov    $0x0,%edi
  80172e:	eb 4b                	jmp    80177b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801730:	89 da                	mov    %ebx,%edx
  801732:	89 f0                	mov    %esi,%eax
  801734:	e8 74 ff ff ff       	call   8016ad <_pipeisclosed>
  801739:	85 c0                	test   %eax,%eax
  80173b:	75 48                	jne    801785 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80173d:	e8 1d f4 ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801742:	8b 43 04             	mov    0x4(%ebx),%eax
  801745:	8b 0b                	mov    (%ebx),%ecx
  801747:	8d 51 20             	lea    0x20(%ecx),%edx
  80174a:	39 d0                	cmp    %edx,%eax
  80174c:	73 e2                	jae    801730 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80174e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801751:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801755:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	c1 fa 1f             	sar    $0x1f,%edx
  80175d:	89 d1                	mov    %edx,%ecx
  80175f:	c1 e9 1b             	shr    $0x1b,%ecx
  801762:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801765:	83 e2 1f             	and    $0x1f,%edx
  801768:	29 ca                	sub    %ecx,%edx
  80176a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80176e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801772:	83 c0 01             	add    $0x1,%eax
  801775:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801778:	83 c7 01             	add    $0x1,%edi
  80177b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80177e:	75 c2                	jne    801742 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801780:	8b 45 10             	mov    0x10(%ebp),%eax
  801783:	eb 05                	jmp    80178a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801785:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80178a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5f                   	pop    %edi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	57                   	push   %edi
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	83 ec 18             	sub    $0x18,%esp
  80179b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80179e:	57                   	push   %edi
  80179f:	e8 6e f6 ff ff       	call   800e12 <fd2data>
  8017a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ae:	eb 3d                	jmp    8017ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b0:	85 db                	test   %ebx,%ebx
  8017b2:	74 04                	je     8017b8 <devpipe_read+0x26>
				return i;
  8017b4:	89 d8                	mov    %ebx,%eax
  8017b6:	eb 44                	jmp    8017fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017b8:	89 f2                	mov    %esi,%edx
  8017ba:	89 f8                	mov    %edi,%eax
  8017bc:	e8 ec fe ff ff       	call   8016ad <_pipeisclosed>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	75 32                	jne    8017f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017c5:	e8 95 f3 ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017ca:	8b 06                	mov    (%esi),%eax
  8017cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8017cf:	74 df                	je     8017b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d1:	99                   	cltd   
  8017d2:	c1 ea 1b             	shr    $0x1b,%edx
  8017d5:	01 d0                	add    %edx,%eax
  8017d7:	83 e0 1f             	and    $0x1f,%eax
  8017da:	29 d0                	sub    %edx,%eax
  8017dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ea:	83 c3 01             	add    $0x1,%ebx
  8017ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f0:	75 d8                	jne    8017ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f5:	eb 05                	jmp    8017fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	5f                   	pop    %edi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80180c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180f:	50                   	push   %eax
  801810:	e8 14 f6 ff ff       	call   800e29 <fd_alloc>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	89 c2                	mov    %eax,%edx
  80181a:	85 c0                	test   %eax,%eax
  80181c:	0f 88 2c 01 00 00    	js     80194e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801822:	83 ec 04             	sub    $0x4,%esp
  801825:	68 07 04 00 00       	push   $0x407
  80182a:	ff 75 f4             	pushl  -0xc(%ebp)
  80182d:	6a 00                	push   $0x0
  80182f:	e8 4a f3 ff ff       	call   800b7e <sys_page_alloc>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 c0                	test   %eax,%eax
  80183b:	0f 88 0d 01 00 00    	js     80194e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801841:	83 ec 0c             	sub    $0xc,%esp
  801844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	e8 dc f5 ff ff       	call   800e29 <fd_alloc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	0f 88 e2 00 00 00    	js     80193c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	68 07 04 00 00       	push   $0x407
  801862:	ff 75 f0             	pushl  -0x10(%ebp)
  801865:	6a 00                	push   $0x0
  801867:	e8 12 f3 ff ff       	call   800b7e <sys_page_alloc>
  80186c:	89 c3                	mov    %eax,%ebx
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	85 c0                	test   %eax,%eax
  801873:	0f 88 c3 00 00 00    	js     80193c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	ff 75 f4             	pushl  -0xc(%ebp)
  80187f:	e8 8e f5 ff ff       	call   800e12 <fd2data>
  801884:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801886:	83 c4 0c             	add    $0xc,%esp
  801889:	68 07 04 00 00       	push   $0x407
  80188e:	50                   	push   %eax
  80188f:	6a 00                	push   $0x0
  801891:	e8 e8 f2 ff ff       	call   800b7e <sys_page_alloc>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	0f 88 89 00 00 00    	js     80192c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a9:	e8 64 f5 ff ff       	call   800e12 <fd2data>
  8018ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b5:	50                   	push   %eax
  8018b6:	6a 00                	push   $0x0
  8018b8:	56                   	push   %esi
  8018b9:	6a 00                	push   $0x0
  8018bb:	e8 01 f3 ff ff       	call   800bc1 <sys_page_map>
  8018c0:	89 c3                	mov    %eax,%ebx
  8018c2:	83 c4 20             	add    $0x20,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 55                	js     80191e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018c9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f9:	e8 04 f5 ff ff       	call   800e02 <fd2num>
  8018fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801901:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801903:	83 c4 04             	add    $0x4,%esp
  801906:	ff 75 f0             	pushl  -0x10(%ebp)
  801909:	e8 f4 f4 ff ff       	call   800e02 <fd2num>
  80190e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801911:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	eb 30                	jmp    80194e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	56                   	push   %esi
  801922:	6a 00                	push   $0x0
  801924:	e8 da f2 ff ff       	call   800c03 <sys_page_unmap>
  801929:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	ff 75 f0             	pushl  -0x10(%ebp)
  801932:	6a 00                	push   $0x0
  801934:	e8 ca f2 ff ff       	call   800c03 <sys_page_unmap>
  801939:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	ff 75 f4             	pushl  -0xc(%ebp)
  801942:	6a 00                	push   $0x0
  801944:	e8 ba f2 ff ff       	call   800c03 <sys_page_unmap>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801960:	50                   	push   %eax
  801961:	ff 75 08             	pushl  0x8(%ebp)
  801964:	e8 0f f5 ff ff       	call   800e78 <fd_lookup>
  801969:	89 c2                	mov    %eax,%edx
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 d2                	test   %edx,%edx
  801970:	78 18                	js     80198a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 95 f4 ff ff       	call   800e12 <fd2data>
	return _pipeisclosed(fd, p);
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	e8 26 fd ff ff       	call   8016ad <_pipeisclosed>
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80199c:	68 5e 24 80 00       	push   $0x80245e
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	e8 cc ed ff ff       	call   800775 <strcpy>
	return 0;
}
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c7:	eb 2d                	jmp    8019f6 <devcons_write+0x46>
		m = n - tot;
  8019c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019cc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019ce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019d6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	53                   	push   %ebx
  8019dd:	03 45 0c             	add    0xc(%ebp),%eax
  8019e0:	50                   	push   %eax
  8019e1:	57                   	push   %edi
  8019e2:	e8 20 ef ff ff       	call   800907 <memmove>
		sys_cputs(buf, m);
  8019e7:	83 c4 08             	add    $0x8,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	57                   	push   %edi
  8019ec:	e8 d1 f0 ff ff       	call   800ac2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f1:	01 de                	add    %ebx,%esi
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	89 f0                	mov    %esi,%eax
  8019f8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fb:	72 cc                	jb     8019c9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a14:	75 07                	jne    801a1d <devcons_read+0x18>
  801a16:	eb 28                	jmp    801a40 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a18:	e8 42 f1 ff ff       	call   800b5f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a1d:	e8 be f0 ff ff       	call   800ae0 <sys_cgetc>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	74 f2                	je     801a18 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 16                	js     801a40 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a2a:	83 f8 04             	cmp    $0x4,%eax
  801a2d:	74 0c                	je     801a3b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a32:	88 02                	mov    %al,(%edx)
	return 1;
  801a34:	b8 01 00 00 00       	mov    $0x1,%eax
  801a39:	eb 05                	jmp    801a40 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a4e:	6a 01                	push   $0x1
  801a50:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	e8 69 f0 ff ff       	call   800ac2 <sys_cputs>
  801a59:	83 c4 10             	add    $0x10,%esp
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <getchar>:

int
getchar(void)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a64:	6a 01                	push   $0x1
  801a66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 71 f6 ff ff       	call   8010e2 <read>
	if (r < 0)
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 0f                	js     801a87 <getchar+0x29>
		return r;
	if (r < 1)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	7e 06                	jle    801a82 <getchar+0x24>
		return -E_EOF;
	return c;
  801a7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a80:	eb 05                	jmp    801a87 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a82:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 dd f3 ff ff       	call   800e78 <fd_lookup>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 11                	js     801ab3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aab:	39 10                	cmp    %edx,(%eax)
  801aad:	0f 94 c0             	sete   %al
  801ab0:	0f b6 c0             	movzbl %al,%eax
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <opencons>:

int
opencons(void)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 65 f3 ff ff       	call   800e29 <fd_alloc>
  801ac4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 3e                	js     801b0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 07 04 00 00       	push   $0x407
  801ad5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 9f f0 ff ff       	call   800b7e <sys_page_alloc>
  801adf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 23                	js     801b0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afd:	83 ec 0c             	sub    $0xc,%esp
  801b00:	50                   	push   %eax
  801b01:	e8 fc f2 ff ff       	call   800e02 <fd2num>
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	83 c4 10             	add    $0x10,%esp
}
  801b0b:	89 d0                	mov    %edx,%eax
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	8b 75 08             	mov    0x8(%ebp),%esi
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b24:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	50                   	push   %eax
  801b2b:	e8 fe f1 ff ff       	call   800d2e <sys_ipc_recv>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	79 16                	jns    801b4d <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801b37:	85 f6                	test   %esi,%esi
  801b39:	74 06                	je     801b41 <ipc_recv+0x32>
  801b3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801b41:	85 db                	test   %ebx,%ebx
  801b43:	74 2c                	je     801b71 <ipc_recv+0x62>
  801b45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b4b:	eb 24                	jmp    801b71 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b4d:	85 f6                	test   %esi,%esi
  801b4f:	74 0a                	je     801b5b <ipc_recv+0x4c>
  801b51:	a1 04 40 80 00       	mov    0x804004,%eax
  801b56:	8b 40 74             	mov    0x74(%eax),%eax
  801b59:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801b5b:	85 db                	test   %ebx,%ebx
  801b5d:	74 0a                	je     801b69 <ipc_recv+0x5a>
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 78             	mov    0x78(%eax),%eax
  801b67:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801b69:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b8a:	85 db                	test   %ebx,%ebx
  801b8c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b91:	0f 44 d8             	cmove  %eax,%ebx
  801b94:	eb 1c                	jmp    801bb2 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801b96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b99:	74 12                	je     801bad <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801b9b:	50                   	push   %eax
  801b9c:	68 6a 24 80 00       	push   $0x80246a
  801ba1:	6a 39                	push   $0x39
  801ba3:	68 85 24 80 00       	push   $0x802485
  801ba8:	e8 68 e5 ff ff       	call   800115 <_panic>
                 sys_yield();
  801bad:	e8 ad ef ff ff       	call   800b5f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bb2:	ff 75 14             	pushl  0x14(%ebp)
  801bb5:	53                   	push   %ebx
  801bb6:	56                   	push   %esi
  801bb7:	57                   	push   %edi
  801bb8:	e8 4e f1 ff ff       	call   800d0b <sys_ipc_try_send>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 d2                	js     801b96 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be0:	8b 52 50             	mov    0x50(%edx),%edx
  801be3:	39 ca                	cmp    %ecx,%edx
  801be5:	75 0d                	jne    801bf4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801be7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bea:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801bef:	8b 40 08             	mov    0x8(%eax),%eax
  801bf2:	eb 0e                	jmp    801c02 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf4:	83 c0 01             	add    $0x1,%eax
  801bf7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bfc:	75 d9                	jne    801bd7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bfe:	66 b8 00 00          	mov    $0x0,%ax
}
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0a:	89 d0                	mov    %edx,%eax
  801c0c:	c1 e8 16             	shr    $0x16,%eax
  801c0f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1b:	f6 c1 01             	test   $0x1,%cl
  801c1e:	74 1d                	je     801c3d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c20:	c1 ea 0c             	shr    $0xc,%edx
  801c23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c2a:	f6 c2 01             	test   $0x1,%dl
  801c2d:	74 0e                	je     801c3d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c2f:	c1 ea 0c             	shr    $0xc,%edx
  801c32:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c39:	ef 
  801c3a:	0f b7 c0             	movzwl %ax,%eax
}
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    
  801c3f:	90                   	nop

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	83 ec 10             	sub    $0x10,%esp
  801c46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c56:	85 d2                	test   %edx,%edx
  801c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c5c:	89 34 24             	mov    %esi,(%esp)
  801c5f:	89 c8                	mov    %ecx,%eax
  801c61:	75 35                	jne    801c98 <__udivdi3+0x58>
  801c63:	39 f1                	cmp    %esi,%ecx
  801c65:	0f 87 bd 00 00 00    	ja     801d28 <__udivdi3+0xe8>
  801c6b:	85 c9                	test   %ecx,%ecx
  801c6d:	89 cd                	mov    %ecx,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f1                	div    %ecx
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c6                	mov    %eax,%esi
  801c84:	89 f8                	mov    %edi,%eax
  801c86:	f7 f5                	div    %ebp
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    
  801c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c98:	3b 14 24             	cmp    (%esp),%edx
  801c9b:	77 7b                	ja     801d18 <__udivdi3+0xd8>
  801c9d:	0f bd f2             	bsr    %edx,%esi
  801ca0:	83 f6 1f             	xor    $0x1f,%esi
  801ca3:	0f 84 97 00 00 00    	je     801d40 <__udivdi3+0x100>
  801ca9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cae:	89 d7                	mov    %edx,%edi
  801cb0:	89 f1                	mov    %esi,%ecx
  801cb2:	29 f5                	sub    %esi,%ebp
  801cb4:	d3 e7                	shl    %cl,%edi
  801cb6:	89 c2                	mov    %eax,%edx
  801cb8:	89 e9                	mov    %ebp,%ecx
  801cba:	d3 ea                	shr    %cl,%edx
  801cbc:	89 f1                	mov    %esi,%ecx
  801cbe:	09 fa                	or     %edi,%edx
  801cc0:	8b 3c 24             	mov    (%esp),%edi
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cc9:	89 e9                	mov    %ebp,%ecx
  801ccb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cd3:	89 fa                	mov    %edi,%edx
  801cd5:	d3 ea                	shr    %cl,%edx
  801cd7:	89 f1                	mov    %esi,%ecx
  801cd9:	d3 e7                	shl    %cl,%edi
  801cdb:	89 e9                	mov    %ebp,%ecx
  801cdd:	d3 e8                	shr    %cl,%eax
  801cdf:	09 c7                	or     %eax,%edi
  801ce1:	89 f8                	mov    %edi,%eax
  801ce3:	f7 74 24 08          	divl   0x8(%esp)
  801ce7:	89 d5                	mov    %edx,%ebp
  801ce9:	89 c7                	mov    %eax,%edi
  801ceb:	f7 64 24 0c          	mull   0xc(%esp)
  801cef:	39 d5                	cmp    %edx,%ebp
  801cf1:	89 14 24             	mov    %edx,(%esp)
  801cf4:	72 11                	jb     801d07 <__udivdi3+0xc7>
  801cf6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cfa:	89 f1                	mov    %esi,%ecx
  801cfc:	d3 e2                	shl    %cl,%edx
  801cfe:	39 c2                	cmp    %eax,%edx
  801d00:	73 5e                	jae    801d60 <__udivdi3+0x120>
  801d02:	3b 2c 24             	cmp    (%esp),%ebp
  801d05:	75 59                	jne    801d60 <__udivdi3+0x120>
  801d07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d0a:	31 f6                	xor    %esi,%esi
  801d0c:	89 f2                	mov    %esi,%edx
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    
  801d15:	8d 76 00             	lea    0x0(%esi),%esi
  801d18:	31 f6                	xor    %esi,%esi
  801d1a:	31 c0                	xor    %eax,%eax
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	89 f2                	mov    %esi,%edx
  801d2a:	31 f6                	xor    %esi,%esi
  801d2c:	89 f8                	mov    %edi,%eax
  801d2e:	f7 f1                	div    %ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d44:	76 0b                	jbe    801d51 <__udivdi3+0x111>
  801d46:	31 c0                	xor    %eax,%eax
  801d48:	3b 14 24             	cmp    (%esp),%edx
  801d4b:	0f 83 37 ff ff ff    	jae    801c88 <__udivdi3+0x48>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	e9 2d ff ff ff       	jmp    801c88 <__udivdi3+0x48>
  801d5b:	90                   	nop
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 f8                	mov    %edi,%eax
  801d62:	31 f6                	xor    %esi,%esi
  801d64:	e9 1f ff ff ff       	jmp    801c88 <__udivdi3+0x48>
  801d69:	66 90                	xchg   %ax,%ax
  801d6b:	66 90                	xchg   %ax,%ax
  801d6d:	66 90                	xchg   %ax,%ax
  801d6f:	90                   	nop

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	83 ec 20             	sub    $0x20,%esp
  801d76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d82:	89 c6                	mov    %eax,%esi
  801d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	75 1e                	jne    801dc0 <__umoddi3+0x50>
  801da2:	39 f7                	cmp    %esi,%edi
  801da4:	76 52                	jbe    801df8 <__umoddi3+0x88>
  801da6:	89 c8                	mov    %ecx,%eax
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	f7 f7                	div    %edi
  801dac:	89 d0                	mov    %edx,%eax
  801dae:	31 d2                	xor    %edx,%edx
  801db0:	83 c4 20             	add    $0x20,%esp
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	39 f0                	cmp    %esi,%eax
  801dc2:	77 5c                	ja     801e20 <__umoddi3+0xb0>
  801dc4:	0f bd e8             	bsr    %eax,%ebp
  801dc7:	83 f5 1f             	xor    $0x1f,%ebp
  801dca:	75 64                	jne    801e30 <__umoddi3+0xc0>
  801dcc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801dd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801dd4:	0f 86 f6 00 00 00    	jbe    801ed0 <__umoddi3+0x160>
  801dda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dde:	0f 82 ec 00 00 00    	jb     801ed0 <__umoddi3+0x160>
  801de4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801de8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801dec:	83 c4 20             	add    $0x20,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
  801df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df8:	85 ff                	test   %edi,%edi
  801dfa:	89 fd                	mov    %edi,%ebp
  801dfc:	75 0b                	jne    801e09 <__umoddi3+0x99>
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f7                	div    %edi
  801e07:	89 c5                	mov    %eax,%ebp
  801e09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	f7 f5                	div    %ebp
  801e11:	89 c8                	mov    %ecx,%eax
  801e13:	f7 f5                	div    %ebp
  801e15:	eb 95                	jmp    801dac <__umoddi3+0x3c>
  801e17:	89 f6                	mov    %esi,%esi
  801e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 20             	add    $0x20,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	b8 20 00 00 00       	mov    $0x20,%eax
  801e35:	89 e9                	mov    %ebp,%ecx
  801e37:	29 e8                	sub    %ebp,%eax
  801e39:	d3 e2                	shl    %cl,%edx
  801e3b:	89 c7                	mov    %eax,%edi
  801e3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 c1                	mov    %eax,%ecx
  801e4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4f:	09 d1                	or     %edx,%ecx
  801e51:	89 fa                	mov    %edi,%edx
  801e53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e57:	89 e9                	mov    %ebp,%ecx
  801e59:	d3 e0                	shl    %cl,%eax
  801e5b:	89 f9                	mov    %edi,%ecx
  801e5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	d3 e8                	shr    %cl,%eax
  801e65:	89 e9                	mov    %ebp,%ecx
  801e67:	89 c7                	mov    %eax,%edi
  801e69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e6d:	d3 e6                	shl    %cl,%esi
  801e6f:	89 d1                	mov    %edx,%ecx
  801e71:	89 fa                	mov    %edi,%edx
  801e73:	d3 e8                	shr    %cl,%eax
  801e75:	89 e9                	mov    %ebp,%ecx
  801e77:	09 f0                	or     %esi,%eax
  801e79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e7d:	f7 74 24 10          	divl   0x10(%esp)
  801e81:	d3 e6                	shl    %cl,%esi
  801e83:	89 d1                	mov    %edx,%ecx
  801e85:	f7 64 24 0c          	mull   0xc(%esp)
  801e89:	39 d1                	cmp    %edx,%ecx
  801e8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e8f:	89 d7                	mov    %edx,%edi
  801e91:	89 c6                	mov    %eax,%esi
  801e93:	72 0a                	jb     801e9f <__umoddi3+0x12f>
  801e95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e99:	73 10                	jae    801eab <__umoddi3+0x13b>
  801e9b:	39 d1                	cmp    %edx,%ecx
  801e9d:	75 0c                	jne    801eab <__umoddi3+0x13b>
  801e9f:	89 d7                	mov    %edx,%edi
  801ea1:	89 c6                	mov    %eax,%esi
  801ea3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801ea7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801eab:	89 ca                	mov    %ecx,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eb3:	29 f0                	sub    %esi,%eax
  801eb5:	19 fa                	sbb    %edi,%edx
  801eb7:	d3 e8                	shr    %cl,%eax
  801eb9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801ebe:	89 d7                	mov    %edx,%edi
  801ec0:	d3 e7                	shl    %cl,%edi
  801ec2:	89 e9                	mov    %ebp,%ecx
  801ec4:	09 f8                	or     %edi,%eax
  801ec6:	d3 ea                	shr    %cl,%edx
  801ec8:	83 c4 20             	add    $0x20,%esp
  801ecb:	5e                   	pop    %esi
  801ecc:	5f                   	pop    %edi
  801ecd:	5d                   	pop    %ebp
  801ece:	c3                   	ret    
  801ecf:	90                   	nop
  801ed0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ed4:	29 f9                	sub    %edi,%ecx
  801ed6:	19 c6                	sbb    %eax,%esi
  801ed8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801edc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801ee0:	e9 ff fe ff ff       	jmp    801de4 <__umoddi3+0x74>
