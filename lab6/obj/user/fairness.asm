
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 a6 0a 00 00       	call   800ae6 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 58 0d 00 00       	call   800db6 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 80 23 80 00       	push   $0x802380
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
		}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 91 23 80 00       	push   $0x802391
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 83 0d 00 00       	call   800e1f <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000ac:	e8 35 0a 00 00       	call   800ae6 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
  8000dd:	83 c4 10             	add    $0x10,%esp
}
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 8b 0f 00 00       	call   80107d <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a9 09 00 00       	call   800aa5 <sys_env_destroy>
  8000fc:	83 c4 10             	add    $0x10,%esp
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 37 09 00 00       	call   800a68 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 4f 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 dc 08 00 00       	call   800a68 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 d1                	mov    %edx,%ecx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d3:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001d6:	72 05                	jb     8001dd <printnum+0x35>
  8001d8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001db:	77 3e                	ja     80021b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	50                   	push   %eax
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 b4 1e 00 00       	call   8020b0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022c:	ff 75 e0             	pushl  -0x20(%ebp)
  80022f:	ff 75 dc             	pushl  -0x24(%ebp)
  800232:	ff 75 d8             	pushl  -0x28(%ebp)
  800235:	e8 a6 1f 00 00       	call   8021e0 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 b2 23 80 00 	movsbl 0x8023b2(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
  800247:	83 c4 10             	add    $0x10,%esp
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800255:	83 fa 01             	cmp    $0x1,%edx
  800258:	7e 0e                	jle    800268 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	8b 52 04             	mov    0x4(%edx),%edx
  800266:	eb 22                	jmp    80028a <getuint+0x38>
	else if (lflag)
  800268:	85 d2                	test   %edx,%edx
  80026a:	74 10                	je     80027c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	eb 0e                	jmp    80028a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800296:	8b 10                	mov    (%eax),%edx
  800298:	3b 50 04             	cmp    0x4(%eax),%edx
  80029b:	73 0a                	jae    8002a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	88 02                	mov    %al,(%edx)
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 10             	pushl  0x10(%ebp)
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	e8 05 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
  8002c1:	83 c4 10             	add    $0x10,%esp
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
  8002cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d8:	eb 12                	jmp    8002ec <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	0f 84 90 03 00 00    	je     800672 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	53                   	push   %ebx
  8002e6:	50                   	push   %eax
  8002e7:	ff d6                	call   *%esi
  8002e9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ec:	83 c7 01             	add    $0x1,%edi
  8002ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f3:	83 f8 25             	cmp    $0x25,%eax
  8002f6:	75 e2                	jne    8002da <vprintfmt+0x14>
  8002f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800303:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 07                	jmp    80031f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8d 47 01             	lea    0x1(%edi),%eax
  800322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800325:	0f b6 07             	movzbl (%edi),%eax
  800328:	0f b6 c8             	movzbl %al,%ecx
  80032b:	83 e8 23             	sub    $0x23,%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 21 03 00 00    	ja     800657 <vprintfmt+0x391>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800343:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800347:	eb d6                	jmp    80031f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034c:	b8 00 00 00 00       	mov    $0x0,%eax
  800351:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800354:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800357:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80035b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800361:	83 fa 09             	cmp    $0x9,%edx
  800364:	77 39                	ja     80039f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800366:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800369:	eb e9                	jmp    800354 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036b:	8b 45 14             	mov    0x14(%ebp),%eax
  80036e:	8d 48 04             	lea    0x4(%eax),%ecx
  800371:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800374:	8b 00                	mov    (%eax),%eax
  800376:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037c:	eb 27                	jmp    8003a5 <vprintfmt+0xdf>
  80037e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800381:	85 c0                	test   %eax,%eax
  800383:	b9 00 00 00 00       	mov    $0x0,%ecx
  800388:	0f 49 c8             	cmovns %eax,%ecx
  80038b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	eb 8c                	jmp    80031f <vprintfmt+0x59>
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039d:	eb 80                	jmp    80031f <vprintfmt+0x59>
  80039f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a9:	0f 89 70 ff ff ff    	jns    80031f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003af:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003bc:	e9 5e ff ff ff       	jmp    80031f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c7:	e9 53 ff ff ff       	jmp    80031f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	53                   	push   %ebx
  8003d9:	ff 30                	pushl  (%eax)
  8003db:	ff d6                	call   *%esi
			break;
  8003dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e3:	e9 04 ff ff ff       	jmp    8002ec <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	99                   	cltd   
  8003f4:	31 d0                	xor    %edx,%eax
  8003f6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f8:	83 f8 0f             	cmp    $0xf,%eax
  8003fb:	7f 0b                	jg     800408 <vprintfmt+0x142>
  8003fd:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	75 18                	jne    800420 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 ca 23 80 00       	push   $0x8023ca
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 94 fe ff ff       	call   8002a9 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041b:	e9 cc fe ff ff       	jmp    8002ec <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800420:	52                   	push   %edx
  800421:	68 d9 27 80 00       	push   $0x8027d9
  800426:	53                   	push   %ebx
  800427:	56                   	push   %esi
  800428:	e8 7c fe ff ff       	call   8002a9 <printfmt>
  80042d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	e9 b4 fe ff ff       	jmp    8002ec <vprintfmt+0x26>
  800438:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80043b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043e:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044c:	85 ff                	test   %edi,%edi
  80044e:	ba c3 23 80 00       	mov    $0x8023c3,%edx
  800453:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800456:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80045a:	0f 84 92 00 00 00    	je     8004f2 <vprintfmt+0x22c>
  800460:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800464:	0f 8e 96 00 00 00    	jle    800500 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	51                   	push   %ecx
  80046e:	57                   	push   %edi
  80046f:	e8 86 02 00 00       	call   8006fa <strnlen>
  800474:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800477:	29 c1                	sub    %eax,%ecx
  800479:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800489:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0f                	jmp    80049c <vprintfmt+0x1d6>
					putch(padc, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	53                   	push   %ebx
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 ff                	test   %edi,%edi
  80049e:	7f ed                	jg     80048d <vprintfmt+0x1c7>
  8004a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	0f 49 c1             	cmovns %ecx,%eax
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	89 cb                	mov    %ecx,%ebx
  8004bd:	eb 4d                	jmp    80050c <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c3:	74 1b                	je     8004e0 <vprintfmt+0x21a>
  8004c5:	0f be c0             	movsbl %al,%eax
  8004c8:	83 e8 20             	sub    $0x20,%eax
  8004cb:	83 f8 5e             	cmp    $0x5e,%eax
  8004ce:	76 10                	jbe    8004e0 <vprintfmt+0x21a>
					putch('?', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 3f                	push   $0x3f
  8004d8:	ff 55 08             	call   *0x8(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 0d                	jmp    8004ed <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	52                   	push   %edx
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	eb 1a                	jmp    80050c <vprintfmt+0x246>
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fe:	eb 0c                	jmp    80050c <vprintfmt+0x246>
  800500:	89 75 08             	mov    %esi,0x8(%ebp)
  800503:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800506:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800509:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800513:	0f be d0             	movsbl %al,%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	74 23                	je     80053d <vprintfmt+0x277>
  80051a:	85 f6                	test   %esi,%esi
  80051c:	78 a1                	js     8004bf <vprintfmt+0x1f9>
  80051e:	83 ee 01             	sub    $0x1,%esi
  800521:	79 9c                	jns    8004bf <vprintfmt+0x1f9>
  800523:	89 df                	mov    %ebx,%edi
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052b:	eb 18                	jmp    800545 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 08                	jmp    800545 <vprintfmt+0x27f>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	85 ff                	test   %edi,%edi
  800547:	7f e4                	jg     80052d <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054c:	e9 9b fd ff ff       	jmp    8002ec <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800551:	83 fa 01             	cmp    $0x1,%edx
  800554:	7e 16                	jle    80056c <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 08             	lea    0x8(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 50 04             	mov    0x4(%eax),%edx
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056a:	eb 32                	jmp    80059e <vprintfmt+0x2d8>
	else if (lflag)
  80056c:	85 d2                	test   %edx,%edx
  80056e:	74 18                	je     800588 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 c1                	mov    %eax,%ecx
  800580:	c1 f9 1f             	sar    $0x1f,%ecx
  800583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800586:	eb 16                	jmp    80059e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 c1                	mov    %eax,%ecx
  800598:	c1 f9 1f             	sar    $0x1f,%ecx
  80059b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ad:	79 74                	jns    800623 <vprintfmt+0x35d>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bd:	f7 d8                	neg    %eax
  8005bf:	83 d2 00             	adc    $0x0,%edx
  8005c2:	f7 da                	neg    %edx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cc:	eb 55                	jmp    800623 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 7c fc ff ff       	call   800252 <getuint>
			base = 10;
  8005d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005db:	eb 46                	jmp    800623 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e0:	e8 6d fc ff ff       	call   800252 <getuint>
                        base = 8;
  8005e5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005ea:	eb 37                	jmp    800623 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 30                	push   $0x30
  8005f2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f4:	83 c4 08             	add    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 78                	push   $0x78
  8005fa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800614:	eb 0d                	jmp    800623 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 34 fc ff ff       	call   800252 <getuint>
			base = 16;
  80061e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800623:	83 ec 0c             	sub    $0xc,%esp
  800626:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062a:	57                   	push   %edi
  80062b:	ff 75 e0             	pushl  -0x20(%ebp)
  80062e:	51                   	push   %ecx
  80062f:	52                   	push   %edx
  800630:	50                   	push   %eax
  800631:	89 da                	mov    %ebx,%edx
  800633:	89 f0                	mov    %esi,%eax
  800635:	e8 6e fb ff ff       	call   8001a8 <printnum>
			break;
  80063a:	83 c4 20             	add    $0x20,%esp
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800640:	e9 a7 fc ff ff       	jmp    8002ec <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	51                   	push   %ecx
  80064a:	ff d6                	call   *%esi
			break;
  80064c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800652:	e9 95 fc ff ff       	jmp    8002ec <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 25                	push   $0x25
  80065d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	eb 03                	jmp    800667 <vprintfmt+0x3a1>
  800664:	83 ef 01             	sub    $0x1,%edi
  800667:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066b:	75 f7                	jne    800664 <vprintfmt+0x39e>
  80066d:	e9 7a fc ff ff       	jmp    8002ec <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800675:	5b                   	pop    %ebx
  800676:	5e                   	pop    %esi
  800677:	5f                   	pop    %edi
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 18             	sub    $0x18,%esp
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800697:	85 c0                	test   %eax,%eax
  800699:	74 26                	je     8006c1 <vsnprintf+0x47>
  80069b:	85 d2                	test   %edx,%edx
  80069d:	7e 22                	jle    8006c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069f:	ff 75 14             	pushl  0x14(%ebp)
  8006a2:	ff 75 10             	pushl  0x10(%ebp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 8c 02 80 00       	push   $0x80028c
  8006ae:	e8 13 fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 05                	jmp    8006c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	ff 75 08             	pushl  0x8(%ebp)
  8006db:	e8 9a ff ff ff       	call   80067a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	eb 03                	jmp    8006f2 <strlen+0x10>
		n++;
  8006ef:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f6:	75 f7                	jne    8006ef <strlen+0xd>
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	ba 00 00 00 00       	mov    $0x0,%edx
  800708:	eb 03                	jmp    80070d <strnlen+0x13>
		n++;
  80070a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	39 c2                	cmp    %eax,%edx
  80070f:	74 08                	je     800719 <strnlen+0x1f>
  800711:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800715:	75 f3                	jne    80070a <strnlen+0x10>
  800717:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800725:	89 c2                	mov    %eax,%edx
  800727:	83 c2 01             	add    $0x1,%edx
  80072a:	83 c1 01             	add    $0x1,%ecx
  80072d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800731:	88 5a ff             	mov    %bl,-0x1(%edx)
  800734:	84 db                	test   %bl,%bl
  800736:	75 ef                	jne    800727 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800738:	5b                   	pop    %ebx
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	53                   	push   %ebx
  800743:	e8 9a ff ff ff       	call   8006e2 <strlen>
  800748:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	01 d8                	add    %ebx,%eax
  800750:	50                   	push   %eax
  800751:	e8 c5 ff ff ff       	call   80071b <strcpy>
	return dst;
}
  800756:	89 d8                	mov    %ebx,%eax
  800758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	56                   	push   %esi
  800761:	53                   	push   %ebx
  800762:	8b 75 08             	mov    0x8(%ebp),%esi
  800765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800768:	89 f3                	mov    %esi,%ebx
  80076a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	89 f2                	mov    %esi,%edx
  80076f:	eb 0f                	jmp    800780 <strncpy+0x23>
		*dst++ = *src;
  800771:	83 c2 01             	add    $0x1,%edx
  800774:	0f b6 01             	movzbl (%ecx),%eax
  800777:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077a:	80 39 01             	cmpb   $0x1,(%ecx)
  80077d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	39 da                	cmp    %ebx,%edx
  800782:	75 ed                	jne    800771 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800784:	89 f0                	mov    %esi,%eax
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800795:	8b 55 10             	mov    0x10(%ebp),%edx
  800798:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079a:	85 d2                	test   %edx,%edx
  80079c:	74 21                	je     8007bf <strlcpy+0x35>
  80079e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a2:	89 f2                	mov    %esi,%edx
  8007a4:	eb 09                	jmp    8007af <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007af:	39 c2                	cmp    %eax,%edx
  8007b1:	74 09                	je     8007bc <strlcpy+0x32>
  8007b3:	0f b6 19             	movzbl (%ecx),%ebx
  8007b6:	84 db                	test   %bl,%bl
  8007b8:	75 ec                	jne    8007a6 <strlcpy+0x1c>
  8007ba:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bf:	29 f0                	sub    %esi,%eax
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ce:	eb 06                	jmp    8007d6 <strcmp+0x11>
		p++, q++;
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	84 c0                	test   %al,%al
  8007db:	74 04                	je     8007e1 <strcmp+0x1c>
  8007dd:	3a 02                	cmp    (%edx),%al
  8007df:	74 ef                	je     8007d0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e1:	0f b6 c0             	movzbl %al,%eax
  8007e4:	0f b6 12             	movzbl (%edx),%edx
  8007e7:	29 d0                	sub    %edx,%eax
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 c3                	mov    %eax,%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fa:	eb 06                	jmp    800802 <strncmp+0x17>
		n--, p++, q++;
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800802:	39 d8                	cmp    %ebx,%eax
  800804:	74 15                	je     80081b <strncmp+0x30>
  800806:	0f b6 08             	movzbl (%eax),%ecx
  800809:	84 c9                	test   %cl,%cl
  80080b:	74 04                	je     800811 <strncmp+0x26>
  80080d:	3a 0a                	cmp    (%edx),%cl
  80080f:	74 eb                	je     8007fc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	0f b6 00             	movzbl (%eax),%eax
  800814:	0f b6 12             	movzbl (%edx),%edx
  800817:	29 d0                	sub    %edx,%eax
  800819:	eb 05                	jmp    800820 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082d:	eb 07                	jmp    800836 <strchr+0x13>
		if (*s == c)
  80082f:	38 ca                	cmp    %cl,%dl
  800831:	74 0f                	je     800842 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800833:	83 c0 01             	add    $0x1,%eax
  800836:	0f b6 10             	movzbl (%eax),%edx
  800839:	84 d2                	test   %dl,%dl
  80083b:	75 f2                	jne    80082f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	eb 03                	jmp    800853 <strfind+0xf>
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800856:	84 d2                	test   %dl,%dl
  800858:	74 04                	je     80085e <strfind+0x1a>
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	75 f2                	jne    800850 <strfind+0xc>
			break;
	return (char *) s;
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	57                   	push   %edi
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 7d 08             	mov    0x8(%ebp),%edi
  800869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 36                	je     8008a6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800870:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800876:	75 28                	jne    8008a0 <memset+0x40>
  800878:	f6 c1 03             	test   $0x3,%cl
  80087b:	75 23                	jne    8008a0 <memset+0x40>
		c &= 0xFF;
  80087d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	89 d3                	mov    %edx,%ebx
  800883:	c1 e3 08             	shl    $0x8,%ebx
  800886:	89 d6                	mov    %edx,%esi
  800888:	c1 e6 18             	shl    $0x18,%esi
  80088b:	89 d0                	mov    %edx,%eax
  80088d:	c1 e0 10             	shl    $0x10,%eax
  800890:	09 f0                	or     %esi,%eax
  800892:	09 c2                	or     %eax,%edx
  800894:	89 d0                	mov    %edx,%eax
  800896:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800898:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80089b:	fc                   	cld    
  80089c:	f3 ab                	rep stos %eax,%es:(%edi)
  80089e:	eb 06                	jmp    8008a6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	fc                   	cld    
  8008a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a6:	89 f8                	mov    %edi,%eax
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bb:	39 c6                	cmp    %eax,%esi
  8008bd:	73 35                	jae    8008f4 <memmove+0x47>
  8008bf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c2:	39 d0                	cmp    %edx,%eax
  8008c4:	73 2e                	jae    8008f4 <memmove+0x47>
		s += n;
		d += n;
  8008c6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008c9:	89 d6                	mov    %edx,%esi
  8008cb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d3:	75 13                	jne    8008e8 <memmove+0x3b>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 0e                	jne    8008e8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008da:	83 ef 04             	sub    $0x4,%edi
  8008dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008e3:	fd                   	std    
  8008e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e6:	eb 09                	jmp    8008f1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e8:	83 ef 01             	sub    $0x1,%edi
  8008eb:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ee:	fd                   	std    
  8008ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f1:	fc                   	cld    
  8008f2:	eb 1d                	jmp    800911 <memmove+0x64>
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 0f                	jne    80090c <memmove+0x5f>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0a                	jne    80090c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800902:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800905:	89 c7                	mov    %eax,%edi
  800907:	fc                   	cld    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 05                	jmp    800911 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	ff 75 0c             	pushl  0xc(%ebp)
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	e8 87 ff ff ff       	call   8008ad <memmove>
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	89 c6                	mov    %eax,%esi
  800935:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800938:	eb 1a                	jmp    800954 <memcmp+0x2c>
		if (*s1 != *s2)
  80093a:	0f b6 08             	movzbl (%eax),%ecx
  80093d:	0f b6 1a             	movzbl (%edx),%ebx
  800940:	38 d9                	cmp    %bl,%cl
  800942:	74 0a                	je     80094e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800944:	0f b6 c1             	movzbl %cl,%eax
  800947:	0f b6 db             	movzbl %bl,%ebx
  80094a:	29 d8                	sub    %ebx,%eax
  80094c:	eb 0f                	jmp    80095d <memcmp+0x35>
		s1++, s2++;
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	39 f0                	cmp    %esi,%eax
  800956:	75 e2                	jne    80093a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80096a:	89 c2                	mov    %eax,%edx
  80096c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096f:	eb 07                	jmp    800978 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	38 08                	cmp    %cl,(%eax)
  800973:	74 07                	je     80097c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	39 d0                	cmp    %edx,%eax
  80097a:	72 f5                	jb     800971 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098a:	eb 03                	jmp    80098f <strtol+0x11>
		s++;
  80098c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098f:	0f b6 01             	movzbl (%ecx),%eax
  800992:	3c 09                	cmp    $0x9,%al
  800994:	74 f6                	je     80098c <strtol+0xe>
  800996:	3c 20                	cmp    $0x20,%al
  800998:	74 f2                	je     80098c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099a:	3c 2b                	cmp    $0x2b,%al
  80099c:	75 0a                	jne    8009a8 <strtol+0x2a>
		s++;
  80099e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a6:	eb 10                	jmp    8009b8 <strtol+0x3a>
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ad:	3c 2d                	cmp    $0x2d,%al
  8009af:	75 07                	jne    8009b8 <strtol+0x3a>
		s++, neg = 1;
  8009b1:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009b4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b8:	85 db                	test   %ebx,%ebx
  8009ba:	0f 94 c0             	sete   %al
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 19                	jne    8009de <strtol+0x60>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 14                	jne    8009de <strtol+0x60>
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	0f 85 82 00 00 00    	jne    800a56 <strtol+0xd8>
		s += 2, base = 16;
  8009d4:	83 c1 02             	add    $0x2,%ecx
  8009d7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dc:	eb 16                	jmp    8009f4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009de:	84 c0                	test   %al,%al
  8009e0:	74 12                	je     8009f4 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ea:	75 08                	jne    8009f4 <strtol+0x76>
		s++, base = 8;
  8009ec:	83 c1 01             	add    $0x1,%ecx
  8009ef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fc:	0f b6 11             	movzbl (%ecx),%edx
  8009ff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 09             	cmp    $0x9,%bl
  800a07:	77 08                	ja     800a11 <strtol+0x93>
			dig = *s - '0';
  800a09:	0f be d2             	movsbl %dl,%edx
  800a0c:	83 ea 30             	sub    $0x30,%edx
  800a0f:	eb 22                	jmp    800a33 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a14:	89 f3                	mov    %esi,%ebx
  800a16:	80 fb 19             	cmp    $0x19,%bl
  800a19:	77 08                	ja     800a23 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a1b:	0f be d2             	movsbl %dl,%edx
  800a1e:	83 ea 57             	sub    $0x57,%edx
  800a21:	eb 10                	jmp    800a33 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a26:	89 f3                	mov    %esi,%ebx
  800a28:	80 fb 19             	cmp    $0x19,%bl
  800a2b:	77 16                	ja     800a43 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a2d:	0f be d2             	movsbl %dl,%edx
  800a30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a36:	7d 0f                	jge    800a47 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a41:	eb b9                	jmp    8009fc <strtol+0x7e>
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	eb 02                	jmp    800a49 <strtol+0xcb>
  800a47:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4d:	74 0d                	je     800a5c <strtol+0xde>
		*endptr = (char *) s;
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	89 0e                	mov    %ecx,(%esi)
  800a54:	eb 06                	jmp    800a5c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	84 c0                	test   %al,%al
  800a58:	75 92                	jne    8009ec <strtol+0x6e>
  800a5a:	eb 98                	jmp    8009f4 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5c:	f7 da                	neg    %edx
  800a5e:	85 ff                	test   %edi,%edi
  800a60:	0f 45 c2             	cmovne %edx,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	89 d1                	mov    %edx,%ecx
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	89 d7                	mov    %edx,%edi
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 cb                	mov    %ecx,%ebx
  800abd:	89 cf                	mov    %ecx,%edi
  800abf:	89 ce                	mov    %ecx,%esi
  800ac1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7e 17                	jle    800ade <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	50                   	push   %eax
  800acb:	6a 03                	push   $0x3
  800acd:	68 df 26 80 00       	push   $0x8026df
  800ad2:	6a 22                	push   $0x22
  800ad4:	68 fc 26 80 00       	push   $0x8026fc
  800ad9:	e8 50 15 00 00       	call   80202e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 02 00 00 00       	mov    $0x2,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_yield>:

void
sys_yield(void)
{      
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2d:	be 00 00 00 00       	mov    $0x0,%esi
  800b32:	b8 04 00 00 00       	mov    $0x4,%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b40:	89 f7                	mov    %esi,%edi
  800b42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b44:	85 c0                	test   %eax,%eax
  800b46:	7e 17                	jle    800b5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 04                	push   $0x4
  800b4e:	68 df 26 80 00       	push   $0x8026df
  800b53:	6a 22                	push   $0x22
  800b55:	68 fc 26 80 00       	push   $0x8026fc
  800b5a:	e8 cf 14 00 00       	call   80202e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b70:	b8 05 00 00 00       	mov    $0x5,%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b81:	8b 75 18             	mov    0x18(%ebp),%esi
  800b84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 05                	push   $0x5
  800b90:	68 df 26 80 00       	push   $0x8026df
  800b95:	6a 22                	push   $0x22
  800b97:	68 fc 26 80 00       	push   $0x8026fc
  800b9c:	e8 8d 14 00 00       	call   80202e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	89 df                	mov    %ebx,%edi
  800bc4:	89 de                	mov    %ebx,%esi
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 06                	push   $0x6
  800bd2:	68 df 26 80 00       	push   $0x8026df
  800bd7:	6a 22                	push   $0x22
  800bd9:	68 fc 26 80 00       	push   $0x8026fc
  800bde:	e8 4b 14 00 00       	call   80202e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	89 df                	mov    %ebx,%edi
  800c06:	89 de                	mov    %ebx,%esi
  800c08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 08                	push   $0x8
  800c14:	68 df 26 80 00       	push   $0x8026df
  800c19:	6a 22                	push   $0x22
  800c1b:	68 fc 26 80 00       	push   $0x8026fc
  800c20:	e8 09 14 00 00       	call   80202e <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 09                	push   $0x9
  800c56:	68 df 26 80 00       	push   $0x8026df
  800c5b:	6a 22                	push   $0x22
  800c5d:	68 fc 26 80 00       	push   $0x8026fc
  800c62:	e8 c7 13 00 00       	call   80202e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 17                	jle    800ca9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 0a                	push   $0xa
  800c98:	68 df 26 80 00       	push   $0x8026df
  800c9d:	6a 22                	push   $0x22
  800c9f:	68 fc 26 80 00       	push   $0x8026fc
  800ca4:	e8 85 13 00 00       	call   80202e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cb7:	be 00 00 00 00       	mov    $0x0,%esi
  800cbc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 cb                	mov    %ecx,%ebx
  800cec:	89 cf                	mov    %ecx,%edi
  800cee:	89 ce                	mov    %ecx,%esi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 17                	jle    800d0d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 0d                	push   $0xd
  800cfc:	68 df 26 80 00       	push   $0x8026df
  800d01:	6a 22                	push   $0x22
  800d03:	68 fc 26 80 00       	push   $0x8026fc
  800d08:	e8 21 13 00 00       	call   80202e <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0f                	push   $0xf
  800d5c:	68 df 26 80 00       	push   $0x8026df
  800d61:	6a 22                	push   $0x22
  800d63:	68 fc 26 80 00       	push   $0x8026fc
  800d68:	e8 c1 12 00 00       	call   80202e <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_recv>:

int
sys_recv(void *addr)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d83:	b8 10 00 00 00       	mov    $0x10,%eax
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 cb                	mov    %ecx,%ebx
  800d8d:	89 cf                	mov    %ecx,%edi
  800d8f:	89 ce                	mov    %ecx,%esi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 10                	push   $0x10
  800d9d:	68 df 26 80 00       	push   $0x8026df
  800da2:	6a 22                	push   $0x22
  800da4:	68 fc 26 80 00       	push   $0x8026fc
  800da9:	e8 80 12 00 00       	call   80202e <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800dcb:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	e8 fd fe ff ff       	call   800cd4 <sys_ipc_recv>
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	79 16                	jns    800df4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  800dde:	85 f6                	test   %esi,%esi
  800de0:	74 06                	je     800de8 <ipc_recv+0x32>
  800de2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  800de8:	85 db                	test   %ebx,%ebx
  800dea:	74 2c                	je     800e18 <ipc_recv+0x62>
  800dec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800df2:	eb 24                	jmp    800e18 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800df4:	85 f6                	test   %esi,%esi
  800df6:	74 0a                	je     800e02 <ipc_recv+0x4c>
  800df8:	a1 08 40 80 00       	mov    0x804008,%eax
  800dfd:	8b 40 74             	mov    0x74(%eax),%eax
  800e00:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800e02:	85 db                	test   %ebx,%ebx
  800e04:	74 0a                	je     800e10 <ipc_recv+0x5a>
  800e06:	a1 08 40 80 00       	mov    0x804008,%eax
  800e0b:	8b 40 78             	mov    0x78(%eax),%eax
  800e0e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  800e10:	a1 08 40 80 00       	mov    0x804008,%eax
  800e15:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  800e31:	85 db                	test   %ebx,%ebx
  800e33:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e38:	0f 44 d8             	cmove  %eax,%ebx
  800e3b:	eb 1c                	jmp    800e59 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  800e3d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e40:	74 12                	je     800e54 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  800e42:	50                   	push   %eax
  800e43:	68 0a 27 80 00       	push   $0x80270a
  800e48:	6a 39                	push   $0x39
  800e4a:	68 25 27 80 00       	push   $0x802725
  800e4f:	e8 da 11 00 00       	call   80202e <_panic>
                 sys_yield();
  800e54:	e8 ac fc ff ff       	call   800b05 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800e59:	ff 75 14             	pushl  0x14(%ebp)
  800e5c:	53                   	push   %ebx
  800e5d:	56                   	push   %esi
  800e5e:	57                   	push   %edi
  800e5f:	e8 4d fe ff ff       	call   800cb1 <sys_ipc_try_send>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 d2                	js     800e3d <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  800e6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e7e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e81:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e87:	8b 52 50             	mov    0x50(%edx),%edx
  800e8a:	39 ca                	cmp    %ecx,%edx
  800e8c:	75 0d                	jne    800e9b <ipc_find_env+0x28>
			return envs[i].env_id;
  800e8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e91:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  800e96:	8b 40 08             	mov    0x8(%eax),%eax
  800e99:	eb 0e                	jmp    800ea9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e9b:	83 c0 01             	add    $0x1,%eax
  800e9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ea3:	75 d9                	jne    800e7e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ea5:	66 b8 00 00          	mov    $0x0,%ax
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ec6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 16             	shr    $0x16,%edx
  800ee2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	74 11                	je     800eff <fd_alloc+0x2d>
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	c1 ea 0c             	shr    $0xc,%edx
  800ef3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	75 09                	jne    800f08 <fd_alloc+0x36>
			*fd_store = fd;
  800eff:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 17                	jmp    800f1f <fd_alloc+0x4d>
  800f08:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f12:	75 c9                	jne    800edd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f14:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f1a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f27:	83 f8 1f             	cmp    $0x1f,%eax
  800f2a:	77 36                	ja     800f62 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2c:	c1 e0 0c             	shl    $0xc,%eax
  800f2f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	c1 ea 16             	shr    $0x16,%edx
  800f39:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f40:	f6 c2 01             	test   $0x1,%dl
  800f43:	74 24                	je     800f69 <fd_lookup+0x48>
  800f45:	89 c2                	mov    %eax,%edx
  800f47:	c1 ea 0c             	shr    $0xc,%edx
  800f4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f51:	f6 c2 01             	test   $0x1,%dl
  800f54:	74 1a                	je     800f70 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f59:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f60:	eb 13                	jmp    800f75 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f67:	eb 0c                	jmp    800f75 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6e:	eb 05                	jmp    800f75 <fd_lookup+0x54>
  800f70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f80:	ba 00 00 00 00       	mov    $0x0,%edx
  800f85:	eb 13                	jmp    800f9a <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f87:	39 08                	cmp    %ecx,(%eax)
  800f89:	75 0c                	jne    800f97 <dev_lookup+0x20>
			*dev = devtab[i];
  800f8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb 36                	jmp    800fcd <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f97:	83 c2 01             	add    $0x1,%edx
  800f9a:	8b 04 95 ac 27 80 00 	mov    0x8027ac(,%edx,4),%eax
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	75 e2                	jne    800f87 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa5:	a1 08 40 80 00       	mov    0x804008,%eax
  800faa:	8b 40 48             	mov    0x48(%eax),%eax
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	51                   	push   %ecx
  800fb1:	50                   	push   %eax
  800fb2:	68 30 27 80 00       	push   $0x802730
  800fb7:	e8 d8 f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 10             	sub    $0x10,%esp
  800fd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800fda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe7:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fea:	50                   	push   %eax
  800feb:	e8 31 ff ff ff       	call   800f21 <fd_lookup>
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 05                	js     800ffc <fd_close+0x2d>
	    || fd != fd2)
  800ff7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ffa:	74 0c                	je     801008 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ffc:	84 db                	test   %bl,%bl
  800ffe:	ba 00 00 00 00       	mov    $0x0,%edx
  801003:	0f 44 c2             	cmove  %edx,%eax
  801006:	eb 41                	jmp    801049 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	ff 36                	pushl  (%esi)
  801011:	e8 61 ff ff ff       	call   800f77 <dev_lookup>
  801016:	89 c3                	mov    %eax,%ebx
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 1a                	js     801039 <fd_close+0x6a>
		if (dev->dev_close)
  80101f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801022:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801025:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	74 0b                	je     801039 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	56                   	push   %esi
  801032:	ff d0                	call   *%eax
  801034:	89 c3                	mov    %eax,%ebx
  801036:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 65 fb ff ff       	call   800ba9 <sys_page_unmap>
	return r;
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	89 d8                	mov    %ebx,%eax
}
  801049:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801056:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801059:	50                   	push   %eax
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	e8 bf fe ff ff       	call   800f21 <fd_lookup>
  801062:	89 c2                	mov    %eax,%edx
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	85 d2                	test   %edx,%edx
  801069:	78 10                	js     80107b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	6a 01                	push   $0x1
  801070:	ff 75 f4             	pushl  -0xc(%ebp)
  801073:	e8 57 ff ff ff       	call   800fcf <fd_close>
  801078:	83 c4 10             	add    $0x10,%esp
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <close_all>:

void
close_all(void)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	53                   	push   %ebx
  801081:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801084:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	53                   	push   %ebx
  80108d:	e8 be ff ff ff       	call   801050 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801092:	83 c3 01             	add    $0x1,%ebx
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	83 fb 20             	cmp    $0x20,%ebx
  80109b:	75 ec                	jne    801089 <close_all+0xc>
		close(i);
}
  80109d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 2c             	sub    $0x2c,%esp
  8010ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b1:	50                   	push   %eax
  8010b2:	ff 75 08             	pushl  0x8(%ebp)
  8010b5:	e8 67 fe ff ff       	call   800f21 <fd_lookup>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	83 c4 08             	add    $0x8,%esp
  8010bf:	85 d2                	test   %edx,%edx
  8010c1:	0f 88 c1 00 00 00    	js     801188 <dup+0xe6>
		return r;
	close(newfdnum);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	56                   	push   %esi
  8010cb:	e8 80 ff ff ff       	call   801050 <close>

	newfd = INDEX2FD(newfdnum);
  8010d0:	89 f3                	mov    %esi,%ebx
  8010d2:	c1 e3 0c             	shl    $0xc,%ebx
  8010d5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010db:	83 c4 04             	add    $0x4,%esp
  8010de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e1:	e8 d5 fd ff ff       	call   800ebb <fd2data>
  8010e6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e8:	89 1c 24             	mov    %ebx,(%esp)
  8010eb:	e8 cb fd ff ff       	call   800ebb <fd2data>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	c1 e8 16             	shr    $0x16,%eax
  8010fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801102:	a8 01                	test   $0x1,%al
  801104:	74 37                	je     80113d <dup+0x9b>
  801106:	89 f8                	mov    %edi,%eax
  801108:	c1 e8 0c             	shr    $0xc,%eax
  80110b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801112:	f6 c2 01             	test   $0x1,%dl
  801115:	74 26                	je     80113d <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801117:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	25 07 0e 00 00       	and    $0xe07,%eax
  801126:	50                   	push   %eax
  801127:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112a:	6a 00                	push   $0x0
  80112c:	57                   	push   %edi
  80112d:	6a 00                	push   $0x0
  80112f:	e8 33 fa ff ff       	call   800b67 <sys_page_map>
  801134:	89 c7                	mov    %eax,%edi
  801136:	83 c4 20             	add    $0x20,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 2e                	js     80116b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801140:	89 d0                	mov    %edx,%eax
  801142:	c1 e8 0c             	shr    $0xc,%eax
  801145:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114c:	83 ec 0c             	sub    $0xc,%esp
  80114f:	25 07 0e 00 00       	and    $0xe07,%eax
  801154:	50                   	push   %eax
  801155:	53                   	push   %ebx
  801156:	6a 00                	push   $0x0
  801158:	52                   	push   %edx
  801159:	6a 00                	push   $0x0
  80115b:	e8 07 fa ff ff       	call   800b67 <sys_page_map>
  801160:	89 c7                	mov    %eax,%edi
  801162:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801165:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801167:	85 ff                	test   %edi,%edi
  801169:	79 1d                	jns    801188 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	53                   	push   %ebx
  80116f:	6a 00                	push   $0x0
  801171:	e8 33 fa ff ff       	call   800ba9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117c:	6a 00                	push   $0x0
  80117e:	e8 26 fa ff ff       	call   800ba9 <sys_page_unmap>
	return r;
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	89 f8                	mov    %edi,%eax
}
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 14             	sub    $0x14,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	53                   	push   %ebx
  80119f:	e8 7d fd ff ff       	call   800f21 <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 6d                	js     80121a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	ff 30                	pushl  (%eax)
  8011b9:	e8 b9 fd ff ff       	call   800f77 <dev_lookup>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 4c                	js     801211 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c8:	8b 42 08             	mov    0x8(%edx),%eax
  8011cb:	83 e0 03             	and    $0x3,%eax
  8011ce:	83 f8 01             	cmp    $0x1,%eax
  8011d1:	75 21                	jne    8011f4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d8:	8b 40 48             	mov    0x48(%eax),%eax
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	68 71 27 80 00       	push   $0x802771
  8011e5:	e8 aa ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f2:	eb 26                	jmp    80121a <read+0x8a>
	}
	if (!dev->dev_read)
  8011f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f7:	8b 40 08             	mov    0x8(%eax),%eax
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	74 17                	je     801215 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	52                   	push   %edx
  801208:	ff d0                	call   *%eax
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 09                	jmp    80121a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	89 c2                	mov    %eax,%edx
  801213:	eb 05                	jmp    80121a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801215:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80121a:	89 d0                	mov    %edx,%eax
  80121c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	57                   	push   %edi
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801230:	bb 00 00 00 00       	mov    $0x0,%ebx
  801235:	eb 21                	jmp    801258 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	89 f0                	mov    %esi,%eax
  80123c:	29 d8                	sub    %ebx,%eax
  80123e:	50                   	push   %eax
  80123f:	89 d8                	mov    %ebx,%eax
  801241:	03 45 0c             	add    0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	57                   	push   %edi
  801246:	e8 45 ff ff ff       	call   801190 <read>
		if (m < 0)
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 0c                	js     80125e <readn+0x3d>
			return m;
		if (m == 0)
  801252:	85 c0                	test   %eax,%eax
  801254:	74 06                	je     80125c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801256:	01 c3                	add    %eax,%ebx
  801258:	39 f3                	cmp    %esi,%ebx
  80125a:	72 db                	jb     801237 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80125c:	89 d8                	mov    %ebx,%eax
}
  80125e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 14             	sub    $0x14,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	53                   	push   %ebx
  801275:	e8 a7 fc ff ff       	call   800f21 <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 68                	js     8012eb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	ff 30                	pushl  (%eax)
  80128f:	e8 e3 fc ff ff       	call   800f77 <dev_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 47                	js     8012e2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a2:	75 21                	jne    8012c5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	50                   	push   %eax
  8012b1:	68 8d 27 80 00       	push   $0x80278d
  8012b6:	e8 d9 ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c3:	eb 26                	jmp    8012eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 17                	je     8012e6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	ff 75 10             	pushl  0x10(%ebp)
  8012d5:	ff 75 0c             	pushl  0xc(%ebp)
  8012d8:	50                   	push   %eax
  8012d9:	ff d2                	call   *%edx
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	eb 09                	jmp    8012eb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	eb 05                	jmp    8012eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 1d fc ff ff       	call   800f21 <fd_lookup>
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 0e                	js     801319 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80130b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80130e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801311:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 14             	sub    $0x14,%esp
  801322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801325:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	53                   	push   %ebx
  80132a:	e8 f2 fb ff ff       	call   800f21 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	89 c2                	mov    %eax,%edx
  801334:	85 c0                	test   %eax,%eax
  801336:	78 65                	js     80139d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	ff 30                	pushl  (%eax)
  801344:	e8 2e fc ff ff       	call   800f77 <dev_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 44                	js     801394 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801357:	75 21                	jne    80137a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801359:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135e:	8b 40 48             	mov    0x48(%eax),%eax
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	53                   	push   %ebx
  801365:	50                   	push   %eax
  801366:	68 50 27 80 00       	push   $0x802750
  80136b:	e8 24 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801378:	eb 23                	jmp    80139d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80137a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80137d:	8b 52 18             	mov    0x18(%edx),%edx
  801380:	85 d2                	test   %edx,%edx
  801382:	74 14                	je     801398 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	ff 75 0c             	pushl  0xc(%ebp)
  80138a:	50                   	push   %eax
  80138b:	ff d2                	call   *%edx
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	eb 09                	jmp    80139d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	89 c2                	mov    %eax,%edx
  801396:	eb 05                	jmp    80139d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801398:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80139d:	89 d0                	mov    %edx,%eax
  80139f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a2:	c9                   	leave  
  8013a3:	c3                   	ret    

008013a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 14             	sub    $0x14,%esp
  8013ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 75 08             	pushl  0x8(%ebp)
  8013b5:	e8 67 fb ff ff       	call   800f21 <fd_lookup>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 58                	js     80141b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	ff 30                	pushl  (%eax)
  8013cf:	e8 a3 fb ff ff       	call   800f77 <dev_lookup>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 37                	js     801412 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e2:	74 32                	je     801416 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ee:	00 00 00 
	stat->st_isdir = 0;
  8013f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f8:	00 00 00 
	stat->st_dev = dev;
  8013fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	53                   	push   %ebx
  801405:	ff 75 f0             	pushl  -0x10(%ebp)
  801408:	ff 50 14             	call   *0x14(%eax)
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	eb 09                	jmp    80141b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801412:	89 c2                	mov    %eax,%edx
  801414:	eb 05                	jmp    80141b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801416:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	6a 00                	push   $0x0
  80142c:	ff 75 08             	pushl  0x8(%ebp)
  80142f:	e8 09 02 00 00       	call   80163d <open>
  801434:	89 c3                	mov    %eax,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 db                	test   %ebx,%ebx
  80143b:	78 1b                	js     801458 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	ff 75 0c             	pushl  0xc(%ebp)
  801443:	53                   	push   %ebx
  801444:	e8 5b ff ff ff       	call   8013a4 <fstat>
  801449:	89 c6                	mov    %eax,%esi
	close(fd);
  80144b:	89 1c 24             	mov    %ebx,(%esp)
  80144e:	e8 fd fb ff ff       	call   801050 <close>
	return r;
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	89 f0                	mov    %esi,%eax
}
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	89 c6                	mov    %eax,%esi
  801466:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801468:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146f:	75 12                	jne    801483 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	6a 01                	push   $0x1
  801476:	e8 f8 f9 ff ff       	call   800e73 <ipc_find_env>
  80147b:	a3 00 40 80 00       	mov    %eax,0x804000
  801480:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801483:	6a 07                	push   $0x7
  801485:	68 00 50 80 00       	push   $0x805000
  80148a:	56                   	push   %esi
  80148b:	ff 35 00 40 80 00    	pushl  0x804000
  801491:	e8 89 f9 ff ff       	call   800e1f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801496:	83 c4 0c             	add    $0xc,%esp
  801499:	6a 00                	push   $0x0
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 13 f9 ff ff       	call   800db6 <ipc_recv>
}
  8014a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a6:	5b                   	pop    %ebx
  8014a7:	5e                   	pop    %esi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014be:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8014cd:	e8 8d ff ff ff       	call   80145f <fsipc>
}
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ef:	e8 6b ff ff ff       	call   80145f <fsipc>
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	8b 40 0c             	mov    0xc(%eax),%eax
  801506:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 05 00 00 00       	mov    $0x5,%eax
  801515:	e8 45 ff ff ff       	call   80145f <fsipc>
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 d2                	test   %edx,%edx
  80151e:	78 2c                	js     80154c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	68 00 50 80 00       	push   $0x805000
  801528:	53                   	push   %ebx
  801529:	e8 ed f1 ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80152e:	a1 80 50 80 00       	mov    0x805080,%eax
  801533:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801539:	a1 84 50 80 00       	mov    0x805084,%eax
  80153e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	57                   	push   %edi
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80155d:	8b 45 08             	mov    0x8(%ebp),%eax
  801560:	8b 40 0c             	mov    0xc(%eax),%eax
  801563:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80156b:	eb 3d                	jmp    8015aa <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80156d:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801573:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801578:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	57                   	push   %edi
  80157f:	53                   	push   %ebx
  801580:	68 08 50 80 00       	push   $0x805008
  801585:	e8 23 f3 ff ff       	call   8008ad <memmove>
                fsipcbuf.write.req_n = tmp; 
  80158a:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801590:	ba 00 00 00 00       	mov    $0x0,%edx
  801595:	b8 04 00 00 00       	mov    $0x4,%eax
  80159a:	e8 c0 fe ff ff       	call   80145f <fsipc>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 0d                	js     8015b3 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8015a6:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8015a8:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015aa:	85 f6                	test   %esi,%esi
  8015ac:	75 bf                	jne    80156d <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8015b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015ce:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8015de:	e8 7c fe ff ff       	call   80145f <fsipc>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 4b                	js     801634 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015e9:	39 c6                	cmp    %eax,%esi
  8015eb:	73 16                	jae    801603 <devfile_read+0x48>
  8015ed:	68 c0 27 80 00       	push   $0x8027c0
  8015f2:	68 c7 27 80 00       	push   $0x8027c7
  8015f7:	6a 7c                	push   $0x7c
  8015f9:	68 dc 27 80 00       	push   $0x8027dc
  8015fe:	e8 2b 0a 00 00       	call   80202e <_panic>
	assert(r <= PGSIZE);
  801603:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801608:	7e 16                	jle    801620 <devfile_read+0x65>
  80160a:	68 e7 27 80 00       	push   $0x8027e7
  80160f:	68 c7 27 80 00       	push   $0x8027c7
  801614:	6a 7d                	push   $0x7d
  801616:	68 dc 27 80 00       	push   $0x8027dc
  80161b:	e8 0e 0a 00 00       	call   80202e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	50                   	push   %eax
  801624:	68 00 50 80 00       	push   $0x805000
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	e8 7c f2 ff ff       	call   8008ad <memmove>
	return r;
  801631:	83 c4 10             	add    $0x10,%esp
}
  801634:	89 d8                	mov    %ebx,%eax
  801636:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 20             	sub    $0x20,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801647:	53                   	push   %ebx
  801648:	e8 95 f0 ff ff       	call   8006e2 <strlen>
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801655:	7f 67                	jg     8016be <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	e8 6f f8 ff ff       	call   800ed2 <fd_alloc>
  801663:	83 c4 10             	add    $0x10,%esp
		return r;
  801666:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 57                	js     8016c3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	53                   	push   %ebx
  801670:	68 00 50 80 00       	push   $0x805000
  801675:	e8 a1 f0 ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80167a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801682:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801685:	b8 01 00 00 00       	mov    $0x1,%eax
  80168a:	e8 d0 fd ff ff       	call   80145f <fsipc>
  80168f:	89 c3                	mov    %eax,%ebx
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	79 14                	jns    8016ac <open+0x6f>
		fd_close(fd, 0);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	6a 00                	push   $0x0
  80169d:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a0:	e8 2a f9 ff ff       	call   800fcf <fd_close>
		return r;
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	89 da                	mov    %ebx,%edx
  8016aa:	eb 17                	jmp    8016c3 <open+0x86>
	}

	return fd2num(fd);
  8016ac:	83 ec 0c             	sub    $0xc,%esp
  8016af:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b2:	e8 f4 f7 ff ff       	call   800eab <fd2num>
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 05                	jmp    8016c3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016be:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c3:	89 d0                	mov    %edx,%eax
  8016c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8016da:	e8 80 fd ff ff       	call   80145f <fsipc>
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016e7:	68 f3 27 80 00       	push   $0x8027f3
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	e8 27 f0 ff ff       	call   80071b <strcpy>
	return 0;
}
  8016f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 10             	sub    $0x10,%esp
  801702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801705:	53                   	push   %ebx
  801706:	e8 69 09 00 00       	call   802074 <pageref>
  80170b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801713:	83 f8 01             	cmp    $0x1,%eax
  801716:	75 10                	jne    801728 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	ff 73 0c             	pushl  0xc(%ebx)
  80171e:	e8 ca 02 00 00       	call   8019ed <nsipc_close>
  801723:	89 c2                	mov    %eax,%edx
  801725:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801728:	89 d0                	mov    %edx,%eax
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801735:	6a 00                	push   $0x0
  801737:	ff 75 10             	pushl  0x10(%ebp)
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	ff 70 0c             	pushl  0xc(%eax)
  801743:	e8 82 03 00 00       	call   801aca <nsipc_send>
}
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801750:	6a 00                	push   $0x0
  801752:	ff 75 10             	pushl  0x10(%ebp)
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	ff 70 0c             	pushl  0xc(%eax)
  80175e:	e8 fb 02 00 00       	call   801a5e <nsipc_recv>
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80176b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80176e:	52                   	push   %edx
  80176f:	50                   	push   %eax
  801770:	e8 ac f7 ff ff       	call   800f21 <fd_lookup>
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 17                	js     801793 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801785:	39 08                	cmp    %ecx,(%eax)
  801787:	75 05                	jne    80178e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	eb 05                	jmp    801793 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80178e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 1c             	sub    $0x1c,%esp
  80179d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80179f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	e8 2a f7 ff ff       	call   800ed2 <fd_alloc>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 1b                	js     8017cc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017b1:	83 ec 04             	sub    $0x4,%esp
  8017b4:	68 07 04 00 00       	push   $0x407
  8017b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 61 f3 ff ff       	call   800b24 <sys_page_alloc>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	79 10                	jns    8017dc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	56                   	push   %esi
  8017d0:	e8 18 02 00 00       	call   8019ed <nsipc_close>
		return r;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	eb 24                	jmp    801800 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017dc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ea:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8017f1:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8017f4:	83 ec 0c             	sub    $0xc,%esp
  8017f7:	52                   	push   %edx
  8017f8:	e8 ae f6 ff ff       	call   800eab <fd2num>
  8017fd:	83 c4 10             	add    $0x10,%esp
}
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	e8 50 ff ff ff       	call   801765 <fd2sockid>
		return r;
  801815:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1f                	js     80183a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	ff 75 10             	pushl  0x10(%ebp)
  801821:	ff 75 0c             	pushl  0xc(%ebp)
  801824:	50                   	push   %eax
  801825:	e8 1c 01 00 00       	call   801946 <nsipc_accept>
  80182a:	83 c4 10             	add    $0x10,%esp
		return r;
  80182d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 07                	js     80183a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801833:	e8 5d ff ff ff       	call   801795 <alloc_sockfd>
  801838:	89 c1                	mov    %eax,%ecx
}
  80183a:	89 c8                	mov    %ecx,%eax
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	e8 19 ff ff ff       	call   801765 <fd2sockid>
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	85 d2                	test   %edx,%edx
  801850:	78 12                	js     801864 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	ff 75 10             	pushl  0x10(%ebp)
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	52                   	push   %edx
  80185c:	e8 35 01 00 00       	call   801996 <nsipc_bind>
  801861:	83 c4 10             	add    $0x10,%esp
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <shutdown>:

int
shutdown(int s, int how)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	e8 f1 fe ff ff       	call   801765 <fd2sockid>
  801874:	89 c2                	mov    %eax,%edx
  801876:	85 d2                	test   %edx,%edx
  801878:	78 0f                	js     801889 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	52                   	push   %edx
  801881:	e8 45 01 00 00       	call   8019cb <nsipc_shutdown>
  801886:	83 c4 10             	add    $0x10,%esp
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	e8 cc fe ff ff       	call   801765 <fd2sockid>
  801899:	89 c2                	mov    %eax,%edx
  80189b:	85 d2                	test   %edx,%edx
  80189d:	78 12                	js     8018b1 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	ff 75 10             	pushl  0x10(%ebp)
  8018a5:	ff 75 0c             	pushl  0xc(%ebp)
  8018a8:	52                   	push   %edx
  8018a9:	e8 59 01 00 00       	call   801a07 <nsipc_connect>
  8018ae:	83 c4 10             	add    $0x10,%esp
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <listen>:

int
listen(int s, int backlog)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	e8 a4 fe ff ff       	call   801765 <fd2sockid>
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	85 d2                	test   %edx,%edx
  8018c5:	78 0f                	js     8018d6 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	ff 75 0c             	pushl  0xc(%ebp)
  8018cd:	52                   	push   %edx
  8018ce:	e8 69 01 00 00       	call   801a3c <nsipc_listen>
  8018d3:	83 c4 10             	add    $0x10,%esp
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018de:	ff 75 10             	pushl  0x10(%ebp)
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	ff 75 08             	pushl  0x8(%ebp)
  8018e7:	e8 3c 02 00 00       	call   801b28 <nsipc_socket>
  8018ec:	89 c2                	mov    %eax,%edx
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	85 d2                	test   %edx,%edx
  8018f3:	78 05                	js     8018fa <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8018f5:	e8 9b fe ff ff       	call   801795 <alloc_sockfd>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	53                   	push   %ebx
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801905:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80190c:	75 12                	jne    801920 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	6a 02                	push   $0x2
  801913:	e8 5b f5 ff ff       	call   800e73 <ipc_find_env>
  801918:	a3 04 40 80 00       	mov    %eax,0x804004
  80191d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801920:	6a 07                	push   $0x7
  801922:	68 00 60 80 00       	push   $0x806000
  801927:	53                   	push   %ebx
  801928:	ff 35 04 40 80 00    	pushl  0x804004
  80192e:	e8 ec f4 ff ff       	call   800e1f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801933:	83 c4 0c             	add    $0xc,%esp
  801936:	6a 00                	push   $0x0
  801938:	6a 00                	push   $0x0
  80193a:	6a 00                	push   $0x0
  80193c:	e8 75 f4 ff ff       	call   800db6 <ipc_recv>
}
  801941:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801956:	8b 06                	mov    (%esi),%eax
  801958:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80195d:	b8 01 00 00 00       	mov    $0x1,%eax
  801962:	e8 95 ff ff ff       	call   8018fc <nsipc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 20                	js     80198d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	ff 35 10 60 80 00    	pushl  0x806010
  801976:	68 00 60 80 00       	push   $0x806000
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	e8 2a ef ff ff       	call   8008ad <memmove>
		*addrlen = ret->ret_addrlen;
  801983:	a1 10 60 80 00       	mov    0x806010,%eax
  801988:	89 06                	mov    %eax,(%esi)
  80198a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80198d:	89 d8                	mov    %ebx,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 08             	sub    $0x8,%esp
  80199d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019a8:	53                   	push   %ebx
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	68 04 60 80 00       	push   $0x806004
  8019b1:	e8 f7 ee ff ff       	call   8008ad <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019b6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c1:	e8 36 ff ff ff       	call   8018fc <nsipc>
}
  8019c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e6:	e8 11 ff ff ff       	call   8018fc <nsipc>
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <nsipc_close>:

int
nsipc_close(int s)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801a00:	e8 f7 fe ff ff       	call   8018fc <nsipc>
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a19:	53                   	push   %ebx
  801a1a:	ff 75 0c             	pushl  0xc(%ebp)
  801a1d:	68 04 60 80 00       	push   $0x806004
  801a22:	e8 86 ee ff ff       	call   8008ad <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a27:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a2d:	b8 05 00 00 00       	mov    $0x5,%eax
  801a32:	e8 c5 fe ff ff       	call   8018fc <nsipc>
}
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a52:	b8 06 00 00 00       	mov    $0x6,%eax
  801a57:	e8 a0 fe ff ff       	call   8018fc <nsipc>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a66:	8b 45 08             	mov    0x8(%ebp),%eax
  801a69:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a6e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a74:	8b 45 14             	mov    0x14(%ebp),%eax
  801a77:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a7c:	b8 07 00 00 00       	mov    $0x7,%eax
  801a81:	e8 76 fe ff ff       	call   8018fc <nsipc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 35                	js     801ac1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a8c:	39 f0                	cmp    %esi,%eax
  801a8e:	7f 07                	jg     801a97 <nsipc_recv+0x39>
  801a90:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a95:	7e 16                	jle    801aad <nsipc_recv+0x4f>
  801a97:	68 ff 27 80 00       	push   $0x8027ff
  801a9c:	68 c7 27 80 00       	push   $0x8027c7
  801aa1:	6a 62                	push   $0x62
  801aa3:	68 14 28 80 00       	push   $0x802814
  801aa8:	e8 81 05 00 00       	call   80202e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aad:	83 ec 04             	sub    $0x4,%esp
  801ab0:	50                   	push   %eax
  801ab1:	68 00 60 80 00       	push   $0x806000
  801ab6:	ff 75 0c             	pushl  0xc(%ebp)
  801ab9:	e8 ef ed ff ff       	call   8008ad <memmove>
  801abe:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	83 ec 04             	sub    $0x4,%esp
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801adc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ae2:	7e 16                	jle    801afa <nsipc_send+0x30>
  801ae4:	68 20 28 80 00       	push   $0x802820
  801ae9:	68 c7 27 80 00       	push   $0x8027c7
  801aee:	6a 6d                	push   $0x6d
  801af0:	68 14 28 80 00       	push   $0x802814
  801af5:	e8 34 05 00 00       	call   80202e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	53                   	push   %ebx
  801afe:	ff 75 0c             	pushl  0xc(%ebp)
  801b01:	68 0c 60 80 00       	push   $0x80600c
  801b06:	e8 a2 ed ff ff       	call   8008ad <memmove>
	nsipcbuf.send.req_size = size;
  801b0b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b11:	8b 45 14             	mov    0x14(%ebp),%eax
  801b14:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b19:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1e:	e8 d9 fd ff ff       	call   8018fc <nsipc>
}
  801b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b39:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b41:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b46:	b8 09 00 00 00       	mov    $0x9,%eax
  801b4b:	e8 ac fd ff ff       	call   8018fc <nsipc>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	ff 75 08             	pushl  0x8(%ebp)
  801b60:	e8 56 f3 ff ff       	call   800ebb <fd2data>
  801b65:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b67:	83 c4 08             	add    $0x8,%esp
  801b6a:	68 2c 28 80 00       	push   $0x80282c
  801b6f:	53                   	push   %ebx
  801b70:	e8 a6 eb ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b75:	8b 56 04             	mov    0x4(%esi),%edx
  801b78:	89 d0                	mov    %edx,%eax
  801b7a:	2b 06                	sub    (%esi),%eax
  801b7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b82:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b89:	00 00 00 
	stat->st_dev = &devpipe;
  801b8c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b93:	30 80 00 
	return 0;
}
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bac:	53                   	push   %ebx
  801bad:	6a 00                	push   $0x0
  801baf:	e8 f5 ef ff ff       	call   800ba9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb4:	89 1c 24             	mov    %ebx,(%esp)
  801bb7:	e8 ff f2 ff ff       	call   800ebb <fd2data>
  801bbc:	83 c4 08             	add    $0x8,%esp
  801bbf:	50                   	push   %eax
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 e2 ef ff ff       	call   800ba9 <sys_page_unmap>
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 1c             	sub    $0x1c,%esp
  801bd5:	89 c6                	mov    %eax,%esi
  801bd7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bda:	a1 08 40 80 00       	mov    0x804008,%eax
  801bdf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	56                   	push   %esi
  801be6:	e8 89 04 00 00       	call   802074 <pageref>
  801beb:	89 c7                	mov    %eax,%edi
  801bed:	83 c4 04             	add    $0x4,%esp
  801bf0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf3:	e8 7c 04 00 00       	call   802074 <pageref>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	39 c7                	cmp    %eax,%edi
  801bfd:	0f 94 c2             	sete   %dl
  801c00:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c03:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c09:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c0c:	39 fb                	cmp    %edi,%ebx
  801c0e:	74 19                	je     801c29 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801c10:	84 d2                	test   %dl,%dl
  801c12:	74 c6                	je     801bda <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c14:	8b 51 58             	mov    0x58(%ecx),%edx
  801c17:	50                   	push   %eax
  801c18:	52                   	push   %edx
  801c19:	53                   	push   %ebx
  801c1a:	68 33 28 80 00       	push   $0x802833
  801c1f:	e8 70 e5 ff ff       	call   800194 <cprintf>
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	eb b1                	jmp    801bda <_pipeisclosed+0xe>
	}
}
  801c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	83 ec 28             	sub    $0x28,%esp
  801c3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c3d:	56                   	push   %esi
  801c3e:	e8 78 f2 ff ff       	call   800ebb <fd2data>
  801c43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	bf 00 00 00 00       	mov    $0x0,%edi
  801c4d:	eb 4b                	jmp    801c9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c4f:	89 da                	mov    %ebx,%edx
  801c51:	89 f0                	mov    %esi,%eax
  801c53:	e8 74 ff ff ff       	call   801bcc <_pipeisclosed>
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	75 48                	jne    801ca4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c5c:	e8 a4 ee ff ff       	call   800b05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c61:	8b 43 04             	mov    0x4(%ebx),%eax
  801c64:	8b 0b                	mov    (%ebx),%ecx
  801c66:	8d 51 20             	lea    0x20(%ecx),%edx
  801c69:	39 d0                	cmp    %edx,%eax
  801c6b:	73 e2                	jae    801c4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	c1 fa 1f             	sar    $0x1f,%edx
  801c7c:	89 d1                	mov    %edx,%ecx
  801c7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801c81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c84:	83 e2 1f             	and    $0x1f,%edx
  801c87:	29 ca                	sub    %ecx,%edx
  801c89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c91:	83 c0 01             	add    $0x1,%eax
  801c94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	83 c7 01             	add    $0x1,%edi
  801c9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9d:	75 c2                	jne    801c61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	eb 05                	jmp    801ca9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	57                   	push   %edi
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 18             	sub    $0x18,%esp
  801cba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cbd:	57                   	push   %edi
  801cbe:	e8 f8 f1 ff ff       	call   800ebb <fd2data>
  801cc3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ccd:	eb 3d                	jmp    801d0c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ccf:	85 db                	test   %ebx,%ebx
  801cd1:	74 04                	je     801cd7 <devpipe_read+0x26>
				return i;
  801cd3:	89 d8                	mov    %ebx,%eax
  801cd5:	eb 44                	jmp    801d1b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cd7:	89 f2                	mov    %esi,%edx
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	e8 ec fe ff ff       	call   801bcc <_pipeisclosed>
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	75 32                	jne    801d16 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ce4:	e8 1c ee ff ff       	call   800b05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce9:	8b 06                	mov    (%esi),%eax
  801ceb:	3b 46 04             	cmp    0x4(%esi),%eax
  801cee:	74 df                	je     801ccf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf0:	99                   	cltd   
  801cf1:	c1 ea 1b             	shr    $0x1b,%edx
  801cf4:	01 d0                	add    %edx,%eax
  801cf6:	83 e0 1f             	and    $0x1f,%eax
  801cf9:	29 d0                	sub    %edx,%eax
  801cfb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d03:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d06:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d09:	83 c3 01             	add    $0x1,%ebx
  801d0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d0f:	75 d8                	jne    801ce9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d11:	8b 45 10             	mov    0x10(%ebp),%eax
  801d14:	eb 05                	jmp    801d1b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	e8 9e f1 ff ff       	call   800ed2 <fd_alloc>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 2c 01 00 00    	js     801e6d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	68 07 04 00 00       	push   $0x407
  801d49:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 d1 ed ff ff       	call   800b24 <sys_page_alloc>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 0d 01 00 00    	js     801e6d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d60:	83 ec 0c             	sub    $0xc,%esp
  801d63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	e8 66 f1 ff ff       	call   800ed2 <fd_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 e2 00 00 00    	js     801e5b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	68 07 04 00 00       	push   $0x407
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 99 ed ff ff       	call   800b24 <sys_page_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 c3 00 00 00    	js     801e5b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	e8 18 f1 ff ff       	call   800ebb <fd2data>
  801da3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da5:	83 c4 0c             	add    $0xc,%esp
  801da8:	68 07 04 00 00       	push   $0x407
  801dad:	50                   	push   %eax
  801dae:	6a 00                	push   $0x0
  801db0:	e8 6f ed ff ff       	call   800b24 <sys_page_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	0f 88 89 00 00 00    	js     801e4b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc8:	e8 ee f0 ff ff       	call   800ebb <fd2data>
  801dcd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd4:	50                   	push   %eax
  801dd5:	6a 00                	push   $0x0
  801dd7:	56                   	push   %esi
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 88 ed ff ff       	call   800b67 <sys_page_map>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	83 c4 20             	add    $0x20,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 55                	js     801e3d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dfd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	ff 75 f4             	pushl  -0xc(%ebp)
  801e18:	e8 8e f0 ff ff       	call   800eab <fd2num>
  801e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e22:	83 c4 04             	add    $0x4,%esp
  801e25:	ff 75 f0             	pushl  -0x10(%ebp)
  801e28:	e8 7e f0 ff ff       	call   800eab <fd2num>
  801e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3b:	eb 30                	jmp    801e6d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	56                   	push   %esi
  801e41:	6a 00                	push   $0x0
  801e43:	e8 61 ed ff ff       	call   800ba9 <sys_page_unmap>
  801e48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e51:	6a 00                	push   $0x0
  801e53:	e8 51 ed ff ff       	call   800ba9 <sys_page_unmap>
  801e58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 41 ed ff ff       	call   800ba9 <sys_page_unmap>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e6d:	89 d0                	mov    %edx,%eax
  801e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e72:	5b                   	pop    %ebx
  801e73:	5e                   	pop    %esi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    

00801e76 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	e8 99 f0 ff ff       	call   800f21 <fd_lookup>
  801e88:	89 c2                	mov    %eax,%edx
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	85 d2                	test   %edx,%edx
  801e8f:	78 18                	js     801ea9 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	ff 75 f4             	pushl  -0xc(%ebp)
  801e97:	e8 1f f0 ff ff       	call   800ebb <fd2data>
	return _pipeisclosed(fd, p);
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	e8 26 fd ff ff       	call   801bcc <_pipeisclosed>
  801ea6:	83 c4 10             	add    $0x10,%esp
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ebb:	68 4b 28 80 00       	push   $0x80284b
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	e8 53 e8 ff ff       	call   80071b <strcpy>
	return 0;
}
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	57                   	push   %edi
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee6:	eb 2d                	jmp    801f15 <devcons_write+0x46>
		m = n - tot;
  801ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eeb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ef0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	53                   	push   %ebx
  801efc:	03 45 0c             	add    0xc(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	57                   	push   %edi
  801f01:	e8 a7 e9 ff ff       	call   8008ad <memmove>
		sys_cputs(buf, m);
  801f06:	83 c4 08             	add    $0x8,%esp
  801f09:	53                   	push   %ebx
  801f0a:	57                   	push   %edi
  801f0b:	e8 58 eb ff ff       	call   800a68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f10:	01 de                	add    %ebx,%esi
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1a:	72 cc                	jb     801ee8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801f2a:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f33:	75 07                	jne    801f3c <devcons_read+0x18>
  801f35:	eb 28                	jmp    801f5f <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f37:	e8 c9 eb ff ff       	call   800b05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f3c:	e8 45 eb ff ff       	call   800a86 <sys_cgetc>
  801f41:	85 c0                	test   %eax,%eax
  801f43:	74 f2                	je     801f37 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 16                	js     801f5f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f49:	83 f8 04             	cmp    $0x4,%eax
  801f4c:	74 0c                	je     801f5a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f51:	88 02                	mov    %al,(%edx)
	return 1;
  801f53:	b8 01 00 00 00       	mov    $0x1,%eax
  801f58:	eb 05                	jmp    801f5f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f67:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f6d:	6a 01                	push   $0x1
  801f6f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f72:	50                   	push   %eax
  801f73:	e8 f0 ea ff ff       	call   800a68 <sys_cputs>
  801f78:	83 c4 10             	add    $0x10,%esp
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <getchar>:

int
getchar(void)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f83:	6a 01                	push   $0x1
  801f85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f88:	50                   	push   %eax
  801f89:	6a 00                	push   $0x0
  801f8b:	e8 00 f2 ff ff       	call   801190 <read>
	if (r < 0)
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	78 0f                	js     801fa6 <getchar+0x29>
		return r;
	if (r < 1)
  801f97:	85 c0                	test   %eax,%eax
  801f99:	7e 06                	jle    801fa1 <getchar+0x24>
		return -E_EOF;
	return c;
  801f9b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f9f:	eb 05                	jmp    801fa6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb1:	50                   	push   %eax
  801fb2:	ff 75 08             	pushl  0x8(%ebp)
  801fb5:	e8 67 ef ff ff       	call   800f21 <fd_lookup>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 11                	js     801fd2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fca:	39 10                	cmp    %edx,(%eax)
  801fcc:	0f 94 c0             	sete   %al
  801fcf:	0f b6 c0             	movzbl %al,%eax
}
  801fd2:	c9                   	leave  
  801fd3:	c3                   	ret    

00801fd4 <opencons>:

int
opencons(void)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdd:	50                   	push   %eax
  801fde:	e8 ef ee ff ff       	call   800ed2 <fd_alloc>
  801fe3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	78 3e                	js     80202a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	68 07 04 00 00       	push   $0x407
  801ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 26 eb ff ff       	call   800b24 <sys_page_alloc>
  801ffe:	83 c4 10             	add    $0x10,%esp
		return r;
  802001:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802003:	85 c0                	test   %eax,%eax
  802005:	78 23                	js     80202a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802007:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802010:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802015:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80201c:	83 ec 0c             	sub    $0xc,%esp
  80201f:	50                   	push   %eax
  802020:	e8 86 ee ff ff       	call   800eab <fd2num>
  802025:	89 c2                	mov    %eax,%edx
  802027:	83 c4 10             	add    $0x10,%esp
}
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802033:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802036:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80203c:	e8 a5 ea ff ff       	call   800ae6 <sys_getenvid>
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	ff 75 0c             	pushl  0xc(%ebp)
  802047:	ff 75 08             	pushl  0x8(%ebp)
  80204a:	56                   	push   %esi
  80204b:	50                   	push   %eax
  80204c:	68 58 28 80 00       	push   $0x802858
  802051:	e8 3e e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802056:	83 c4 18             	add    $0x18,%esp
  802059:	53                   	push   %ebx
  80205a:	ff 75 10             	pushl  0x10(%ebp)
  80205d:	e8 e1 e0 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  802062:	c7 04 24 44 28 80 00 	movl   $0x802844,(%esp)
  802069:	e8 26 e1 ff ff       	call   800194 <cprintf>
  80206e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802071:	cc                   	int3   
  802072:	eb fd                	jmp    802071 <_panic+0x43>

00802074 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207a:	89 d0                	mov    %edx,%eax
  80207c:	c1 e8 16             	shr    $0x16,%eax
  80207f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802086:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208b:	f6 c1 01             	test   $0x1,%cl
  80208e:	74 1d                	je     8020ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802090:	c1 ea 0c             	shr    $0xc,%edx
  802093:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80209a:	f6 c2 01             	test   $0x1,%dl
  80209d:	74 0e                	je     8020ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209f:	c1 ea 0c             	shr    $0xc,%edx
  8020a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a9:	ef 
  8020aa:	0f b7 c0             	movzwl %ax,%eax
}
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	83 ec 10             	sub    $0x10,%esp
  8020b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020c6:	85 d2                	test   %edx,%edx
  8020c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	89 c8                	mov    %ecx,%eax
  8020d1:	75 35                	jne    802108 <__udivdi3+0x58>
  8020d3:	39 f1                	cmp    %esi,%ecx
  8020d5:	0f 87 bd 00 00 00    	ja     802198 <__udivdi3+0xe8>
  8020db:	85 c9                	test   %ecx,%ecx
  8020dd:	89 cd                	mov    %ecx,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f1                	div    %ecx
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 f0                	mov    %esi,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c6                	mov    %eax,%esi
  8020f4:	89 f8                	mov    %edi,%eax
  8020f6:	f7 f5                	div    %ebp
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    
  802101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802108:	3b 14 24             	cmp    (%esp),%edx
  80210b:	77 7b                	ja     802188 <__udivdi3+0xd8>
  80210d:	0f bd f2             	bsr    %edx,%esi
  802110:	83 f6 1f             	xor    $0x1f,%esi
  802113:	0f 84 97 00 00 00    	je     8021b0 <__udivdi3+0x100>
  802119:	bd 20 00 00 00       	mov    $0x20,%ebp
  80211e:	89 d7                	mov    %edx,%edi
  802120:	89 f1                	mov    %esi,%ecx
  802122:	29 f5                	sub    %esi,%ebp
  802124:	d3 e7                	shl    %cl,%edi
  802126:	89 c2                	mov    %eax,%edx
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	d3 ea                	shr    %cl,%edx
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	09 fa                	or     %edi,%edx
  802130:	8b 3c 24             	mov    (%esp),%edi
  802133:	d3 e0                	shl    %cl,%eax
  802135:	89 54 24 08          	mov    %edx,0x8(%esp)
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802143:	89 fa                	mov    %edi,%edx
  802145:	d3 ea                	shr    %cl,%edx
  802147:	89 f1                	mov    %esi,%ecx
  802149:	d3 e7                	shl    %cl,%edi
  80214b:	89 e9                	mov    %ebp,%ecx
  80214d:	d3 e8                	shr    %cl,%eax
  80214f:	09 c7                	or     %eax,%edi
  802151:	89 f8                	mov    %edi,%eax
  802153:	f7 74 24 08          	divl   0x8(%esp)
  802157:	89 d5                	mov    %edx,%ebp
  802159:	89 c7                	mov    %eax,%edi
  80215b:	f7 64 24 0c          	mull   0xc(%esp)
  80215f:	39 d5                	cmp    %edx,%ebp
  802161:	89 14 24             	mov    %edx,(%esp)
  802164:	72 11                	jb     802177 <__udivdi3+0xc7>
  802166:	8b 54 24 04          	mov    0x4(%esp),%edx
  80216a:	89 f1                	mov    %esi,%ecx
  80216c:	d3 e2                	shl    %cl,%edx
  80216e:	39 c2                	cmp    %eax,%edx
  802170:	73 5e                	jae    8021d0 <__udivdi3+0x120>
  802172:	3b 2c 24             	cmp    (%esp),%ebp
  802175:	75 59                	jne    8021d0 <__udivdi3+0x120>
  802177:	8d 47 ff             	lea    -0x1(%edi),%eax
  80217a:	31 f6                	xor    %esi,%esi
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	31 f6                	xor    %esi,%esi
  80218a:	31 c0                	xor    %eax,%eax
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	89 f2                	mov    %esi,%edx
  80219a:	31 f6                	xor    %esi,%esi
  80219c:	89 f8                	mov    %edi,%eax
  80219e:	f7 f1                	div    %ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021b4:	76 0b                	jbe    8021c1 <__udivdi3+0x111>
  8021b6:	31 c0                	xor    %eax,%eax
  8021b8:	3b 14 24             	cmp    (%esp),%edx
  8021bb:	0f 83 37 ff ff ff    	jae    8020f8 <__udivdi3+0x48>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	e9 2d ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021cb:	90                   	nop
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 f8                	mov    %edi,%eax
  8021d2:	31 f6                	xor    %esi,%esi
  8021d4:	e9 1f ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	83 ec 20             	sub    $0x20,%esp
  8021e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f2:	89 c6                	mov    %eax,%esi
  8021f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802200:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802204:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802208:	89 74 24 18          	mov    %esi,0x18(%esp)
  80220c:	85 c0                	test   %eax,%eax
  80220e:	89 c2                	mov    %eax,%edx
  802210:	75 1e                	jne    802230 <__umoddi3+0x50>
  802212:	39 f7                	cmp    %esi,%edi
  802214:	76 52                	jbe    802268 <__umoddi3+0x88>
  802216:	89 c8                	mov    %ecx,%eax
  802218:	89 f2                	mov    %esi,%edx
  80221a:	f7 f7                	div    %edi
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	83 c4 20             	add    $0x20,%esp
  802223:	5e                   	pop    %esi
  802224:	5f                   	pop    %edi
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
  802227:	89 f6                	mov    %esi,%esi
  802229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802230:	39 f0                	cmp    %esi,%eax
  802232:	77 5c                	ja     802290 <__umoddi3+0xb0>
  802234:	0f bd e8             	bsr    %eax,%ebp
  802237:	83 f5 1f             	xor    $0x1f,%ebp
  80223a:	75 64                	jne    8022a0 <__umoddi3+0xc0>
  80223c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802240:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802244:	0f 86 f6 00 00 00    	jbe    802340 <__umoddi3+0x160>
  80224a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80224e:	0f 82 ec 00 00 00    	jb     802340 <__umoddi3+0x160>
  802254:	8b 44 24 14          	mov    0x14(%esp),%eax
  802258:	8b 54 24 18          	mov    0x18(%esp),%edx
  80225c:	83 c4 20             	add    $0x20,%esp
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	90                   	nop
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	85 ff                	test   %edi,%edi
  80226a:	89 fd                	mov    %edi,%ebp
  80226c:	75 0b                	jne    802279 <__umoddi3+0x99>
  80226e:	b8 01 00 00 00       	mov    $0x1,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f7                	div    %edi
  802277:	89 c5                	mov    %eax,%ebp
  802279:	8b 44 24 10          	mov    0x10(%esp),%eax
  80227d:	31 d2                	xor    %edx,%edx
  80227f:	f7 f5                	div    %ebp
  802281:	89 c8                	mov    %ecx,%eax
  802283:	f7 f5                	div    %ebp
  802285:	eb 95                	jmp    80221c <__umoddi3+0x3c>
  802287:	89 f6                	mov    %esi,%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 20             	add    $0x20,%esp
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	90                   	nop
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	29 e8                	sub    %ebp,%eax
  8022a9:	d3 e2                	shl    %cl,%edx
  8022ab:	89 c7                	mov    %eax,%edi
  8022ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 c1                	mov    %eax,%ecx
  8022bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022bf:	09 d1                	or     %edx,%ecx
  8022c1:	89 fa                	mov    %edi,%edx
  8022c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022c7:	89 e9                	mov    %ebp,%ecx
  8022c9:	d3 e0                	shl    %cl,%eax
  8022cb:	89 f9                	mov    %edi,%ecx
  8022cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	d3 e8                	shr    %cl,%eax
  8022d5:	89 e9                	mov    %ebp,%ecx
  8022d7:	89 c7                	mov    %eax,%edi
  8022d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022dd:	d3 e6                	shl    %cl,%esi
  8022df:	89 d1                	mov    %edx,%ecx
  8022e1:	89 fa                	mov    %edi,%edx
  8022e3:	d3 e8                	shr    %cl,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	09 f0                	or     %esi,%eax
  8022e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022ed:	f7 74 24 10          	divl   0x10(%esp)
  8022f1:	d3 e6                	shl    %cl,%esi
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	f7 64 24 0c          	mull   0xc(%esp)
  8022f9:	39 d1                	cmp    %edx,%ecx
  8022fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022ff:	89 d7                	mov    %edx,%edi
  802301:	89 c6                	mov    %eax,%esi
  802303:	72 0a                	jb     80230f <__umoddi3+0x12f>
  802305:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802309:	73 10                	jae    80231b <__umoddi3+0x13b>
  80230b:	39 d1                	cmp    %edx,%ecx
  80230d:	75 0c                	jne    80231b <__umoddi3+0x13b>
  80230f:	89 d7                	mov    %edx,%edi
  802311:	89 c6                	mov    %eax,%esi
  802313:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802317:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80231b:	89 ca                	mov    %ecx,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802323:	29 f0                	sub    %esi,%eax
  802325:	19 fa                	sbb    %edi,%edx
  802327:	d3 e8                	shr    %cl,%eax
  802329:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80232e:	89 d7                	mov    %edx,%edi
  802330:	d3 e7                	shl    %cl,%edi
  802332:	89 e9                	mov    %ebp,%ecx
  802334:	09 f8                	or     %edi,%eax
  802336:	d3 ea                	shr    %cl,%edx
  802338:	83 c4 20             	add    $0x20,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
  802340:	8b 74 24 10          	mov    0x10(%esp),%esi
  802344:	29 f9                	sub    %edi,%ecx
  802346:	19 c6                	sbb    %eax,%esi
  802348:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80234c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802350:	e9 ff fe ff ff       	jmp    802254 <__umoddi3+0x74>
