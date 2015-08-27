
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
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 b7 0c 00 00       	call   800d15 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 80 1e 80 00       	push   $0x801e80
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
  80007e:	68 91 1e 80 00       	push   $0x801e91
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 e2 0c 00 00       	call   800d7e <ipc_send>
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
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000ed:	e8 e5 0e 00 00       	call   800fd7 <close_all>
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
  8001f7:	e8 a4 19 00 00       	call   801ba0 <__udivdi3>
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
  800235:	e8 96 1a 00 00       	call   801cd0 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 b2 1e 80 00 	movsbl 0x801eb2(%eax),%eax
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
  800339:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
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
  8003fd:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	75 18                	jne    800420 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 ca 1e 80 00       	push   $0x801eca
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
  800421:	68 d5 22 80 00       	push   $0x8022d5
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
  80044e:	ba c3 1e 80 00       	mov    $0x801ec3,%edx
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
  800acd:	68 df 21 80 00       	push   $0x8021df
  800ad2:	6a 23                	push   $0x23
  800ad4:	68 fc 21 80 00       	push   $0x8021fc
  800ad9:	e8 39 10 00 00       	call   801b17 <_panic>

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
  800b4e:	68 df 21 80 00       	push   $0x8021df
  800b53:	6a 23                	push   $0x23
  800b55:	68 fc 21 80 00       	push   $0x8021fc
  800b5a:	e8 b8 0f 00 00       	call   801b17 <_panic>

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
  800b90:	68 df 21 80 00       	push   $0x8021df
  800b95:	6a 23                	push   $0x23
  800b97:	68 fc 21 80 00       	push   $0x8021fc
  800b9c:	e8 76 0f 00 00       	call   801b17 <_panic>

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
  800bd2:	68 df 21 80 00       	push   $0x8021df
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 fc 21 80 00       	push   $0x8021fc
  800bde:	e8 34 0f 00 00       	call   801b17 <_panic>

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
  800c14:	68 df 21 80 00       	push   $0x8021df
  800c19:	6a 23                	push   $0x23
  800c1b:	68 fc 21 80 00       	push   $0x8021fc
  800c20:	e8 f2 0e 00 00       	call   801b17 <_panic>
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
  800c56:	68 df 21 80 00       	push   $0x8021df
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 fc 21 80 00       	push   $0x8021fc
  800c62:	e8 b0 0e 00 00       	call   801b17 <_panic>

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
  800c98:	68 df 21 80 00       	push   $0x8021df
  800c9d:	6a 23                	push   $0x23
  800c9f:	68 fc 21 80 00       	push   $0x8021fc
  800ca4:	e8 6e 0e 00 00       	call   801b17 <_panic>

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
  800cfc:	68 df 21 80 00       	push   $0x8021df
  800d01:	6a 23                	push   $0x23
  800d03:	68 fc 21 80 00       	push   $0x8021fc
  800d08:	e8 0a 0e 00 00       	call   801b17 <_panic>

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

00800d15 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  800d23:	85 c0                	test   %eax,%eax
  800d25:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d2a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	e8 9e ff ff ff       	call   800cd4 <sys_ipc_recv>
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	79 16                	jns    800d53 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  800d3d:	85 f6                	test   %esi,%esi
  800d3f:	74 06                	je     800d47 <ipc_recv+0x32>
  800d41:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	74 2c                	je     800d77 <ipc_recv+0x62>
  800d4b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800d51:	eb 24                	jmp    800d77 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800d53:	85 f6                	test   %esi,%esi
  800d55:	74 0a                	je     800d61 <ipc_recv+0x4c>
  800d57:	a1 04 40 80 00       	mov    0x804004,%eax
  800d5c:	8b 40 74             	mov    0x74(%eax),%eax
  800d5f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800d61:	85 db                	test   %ebx,%ebx
  800d63:	74 0a                	je     800d6f <ipc_recv+0x5a>
  800d65:	a1 04 40 80 00       	mov    0x804004,%eax
  800d6a:	8b 40 78             	mov    0x78(%eax),%eax
  800d6d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  800d6f:	a1 04 40 80 00       	mov    0x804004,%eax
  800d74:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d97:	0f 44 d8             	cmove  %eax,%ebx
  800d9a:	eb 1c                	jmp    800db8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  800d9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800d9f:	74 12                	je     800db3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  800da1:	50                   	push   %eax
  800da2:	68 0a 22 80 00       	push   $0x80220a
  800da7:	6a 39                	push   $0x39
  800da9:	68 25 22 80 00       	push   $0x802225
  800dae:	e8 64 0d 00 00       	call   801b17 <_panic>
                 sys_yield();
  800db3:	e8 4d fd ff ff       	call   800b05 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800db8:	ff 75 14             	pushl  0x14(%ebp)
  800dbb:	53                   	push   %ebx
  800dbc:	56                   	push   %esi
  800dbd:	57                   	push   %edi
  800dbe:	e8 ee fe ff ff       	call   800cb1 <sys_ipc_try_send>
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	78 d2                	js     800d9c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ddd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800de0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800de6:	8b 52 50             	mov    0x50(%edx),%edx
  800de9:	39 ca                	cmp    %ecx,%edx
  800deb:	75 0d                	jne    800dfa <ipc_find_env+0x28>
			return envs[i].env_id;
  800ded:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800df0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  800df5:	8b 40 08             	mov    0x8(%eax),%eax
  800df8:	eb 0e                	jmp    800e08 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e02:	75 d9                	jne    800ddd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e04:	66 b8 00 00          	mov    $0x0,%ax
}
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	05 00 00 00 30       	add    $0x30000000,%eax
  800e15:	c1 e8 0c             	shr    $0xc,%eax
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 11                	je     800e5e <fd_alloc+0x2d>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	75 09                	jne    800e67 <fd_alloc+0x36>
			*fd_store = fd;
  800e5e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	eb 17                	jmp    800e7e <fd_alloc+0x4d>
  800e67:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e71:	75 c9                	jne    800e3c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e73:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e79:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e86:	83 f8 1f             	cmp    $0x1f,%eax
  800e89:	77 36                	ja     800ec1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8b:	c1 e0 0c             	shl    $0xc,%eax
  800e8e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 16             	shr    $0x16,%edx
  800e98:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	74 24                	je     800ec8 <fd_lookup+0x48>
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	c1 ea 0c             	shr    $0xc,%edx
  800ea9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb0:	f6 c2 01             	test   $0x1,%dl
  800eb3:	74 1a                	je     800ecf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 13                	jmp    800ed4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec6:	eb 0c                	jmp    800ed4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb 05                	jmp    800ed4 <fd_lookup+0x54>
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edf:	ba ac 22 80 00       	mov    $0x8022ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee4:	eb 13                	jmp    800ef9 <dev_lookup+0x23>
  800ee6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee9:	39 08                	cmp    %ecx,(%eax)
  800eeb:	75 0c                	jne    800ef9 <dev_lookup+0x23>
			*dev = devtab[i];
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	eb 2e                	jmp    800f27 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef9:	8b 02                	mov    (%edx),%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 e7                	jne    800ee6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eff:	a1 04 40 80 00       	mov    0x804004,%eax
  800f04:	8b 40 48             	mov    0x48(%eax),%eax
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	51                   	push   %ecx
  800f0b:	50                   	push   %eax
  800f0c:	68 30 22 80 00       	push   $0x802230
  800f11:	e8 7e f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 10             	sub    $0x10,%esp
  800f31:	8b 75 08             	mov    0x8(%ebp),%esi
  800f34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3a:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f41:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f44:	50                   	push   %eax
  800f45:	e8 36 ff ff ff       	call   800e80 <fd_lookup>
  800f4a:	83 c4 08             	add    $0x8,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 05                	js     800f56 <fd_close+0x2d>
	    || fd != fd2)
  800f51:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f54:	74 0c                	je     800f62 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f56:	84 db                	test   %bl,%bl
  800f58:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5d:	0f 44 c2             	cmove  %edx,%eax
  800f60:	eb 41                	jmp    800fa3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f68:	50                   	push   %eax
  800f69:	ff 36                	pushl  (%esi)
  800f6b:	e8 66 ff ff ff       	call   800ed6 <dev_lookup>
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 1a                	js     800f93 <fd_close+0x6a>
		if (dev->dev_close)
  800f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	74 0b                	je     800f93 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	56                   	push   %esi
  800f8c:	ff d0                	call   *%eax
  800f8e:	89 c3                	mov    %eax,%ebx
  800f90:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 0b fc ff ff       	call   800ba9 <sys_page_unmap>
	return r;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	89 d8                	mov    %ebx,%eax
}
  800fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 c4 fe ff ff       	call   800e80 <fd_lookup>
  800fbc:	89 c2                	mov    %eax,%edx
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 d2                	test   %edx,%edx
  800fc3:	78 10                	js     800fd5 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	6a 01                	push   $0x1
  800fca:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcd:	e8 57 ff ff ff       	call   800f29 <fd_close>
  800fd2:	83 c4 10             	add    $0x10,%esp
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <close_all>:

void
close_all(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	53                   	push   %ebx
  800fe7:	e8 be ff ff ff       	call   800faa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fec:	83 c3 01             	add    $0x1,%ebx
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	83 fb 20             	cmp    $0x20,%ebx
  800ff5:	75 ec                	jne    800fe3 <close_all+0xc>
		close(i);
}
  800ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 2c             	sub    $0x2c,%esp
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801008:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 6c fe ff ff       	call   800e80 <fd_lookup>
  801014:	89 c2                	mov    %eax,%edx
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	85 d2                	test   %edx,%edx
  80101b:	0f 88 c1 00 00 00    	js     8010e2 <dup+0xe6>
		return r;
	close(newfdnum);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	56                   	push   %esi
  801025:	e8 80 ff ff ff       	call   800faa <close>

	newfd = INDEX2FD(newfdnum);
  80102a:	89 f3                	mov    %esi,%ebx
  80102c:	c1 e3 0c             	shl    $0xc,%ebx
  80102f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801035:	83 c4 04             	add    $0x4,%esp
  801038:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103b:	e8 da fd ff ff       	call   800e1a <fd2data>
  801040:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801042:	89 1c 24             	mov    %ebx,(%esp)
  801045:	e8 d0 fd ff ff       	call   800e1a <fd2data>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801050:	89 f8                	mov    %edi,%eax
  801052:	c1 e8 16             	shr    $0x16,%eax
  801055:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105c:	a8 01                	test   $0x1,%al
  80105e:	74 37                	je     801097 <dup+0x9b>
  801060:	89 f8                	mov    %edi,%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106c:	f6 c2 01             	test   $0x1,%dl
  80106f:	74 26                	je     801097 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	25 07 0e 00 00       	and    $0xe07,%eax
  801080:	50                   	push   %eax
  801081:	ff 75 d4             	pushl  -0x2c(%ebp)
  801084:	6a 00                	push   $0x0
  801086:	57                   	push   %edi
  801087:	6a 00                	push   $0x0
  801089:	e8 d9 fa ff ff       	call   800b67 <sys_page_map>
  80108e:	89 c7                	mov    %eax,%edi
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 2e                	js     8010c5 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801097:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109a:	89 d0                	mov    %edx,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
  80109f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ae:	50                   	push   %eax
  8010af:	53                   	push   %ebx
  8010b0:	6a 00                	push   $0x0
  8010b2:	52                   	push   %edx
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 ad fa ff ff       	call   800b67 <sys_page_map>
  8010ba:	89 c7                	mov    %eax,%edi
  8010bc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010bf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c1:	85 ff                	test   %edi,%edi
  8010c3:	79 1d                	jns    8010e2 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	53                   	push   %ebx
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 d9 fa ff ff       	call   800ba9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 cc fa ff ff       	call   800ba9 <sys_page_unmap>
	return r;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 f8                	mov    %edi,%eax
}
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 14             	sub    $0x14,%esp
  8010f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	53                   	push   %ebx
  8010f9:	e8 82 fd ff ff       	call   800e80 <fd_lookup>
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	89 c2                	mov    %eax,%edx
  801103:	85 c0                	test   %eax,%eax
  801105:	78 6d                	js     801174 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801111:	ff 30                	pushl  (%eax)
  801113:	e8 be fd ff ff       	call   800ed6 <dev_lookup>
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 4c                	js     80116b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801122:	8b 42 08             	mov    0x8(%edx),%eax
  801125:	83 e0 03             	and    $0x3,%eax
  801128:	83 f8 01             	cmp    $0x1,%eax
  80112b:	75 21                	jne    80114e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112d:	a1 04 40 80 00       	mov    0x804004,%eax
  801132:	8b 40 48             	mov    0x48(%eax),%eax
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	53                   	push   %ebx
  801139:	50                   	push   %eax
  80113a:	68 71 22 80 00       	push   $0x802271
  80113f:	e8 50 f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114c:	eb 26                	jmp    801174 <read+0x8a>
	}
	if (!dev->dev_read)
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	8b 40 08             	mov    0x8(%eax),%eax
  801154:	85 c0                	test   %eax,%eax
  801156:	74 17                	je     80116f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	ff 75 0c             	pushl  0xc(%ebp)
  801161:	52                   	push   %edx
  801162:	ff d0                	call   *%eax
  801164:	89 c2                	mov    %eax,%edx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 09                	jmp    801174 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	eb 05                	jmp    801174 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801174:	89 d0                	mov    %edx,%eax
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	8b 7d 08             	mov    0x8(%ebp),%edi
  801187:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	eb 21                	jmp    8011b2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	89 f0                	mov    %esi,%eax
  801196:	29 d8                	sub    %ebx,%eax
  801198:	50                   	push   %eax
  801199:	89 d8                	mov    %ebx,%eax
  80119b:	03 45 0c             	add    0xc(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	57                   	push   %edi
  8011a0:	e8 45 ff ff ff       	call   8010ea <read>
		if (m < 0)
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0c                	js     8011b8 <readn+0x3d>
			return m;
		if (m == 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 06                	je     8011b6 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b0:	01 c3                	add    %eax,%ebx
  8011b2:	39 f3                	cmp    %esi,%ebx
  8011b4:	72 db                	jb     801191 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011b6:	89 d8                	mov    %ebx,%eax
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 14             	sub    $0x14,%esp
  8011c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	53                   	push   %ebx
  8011cf:	e8 ac fc ff ff       	call   800e80 <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 68                	js     801245 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	ff 30                	pushl  (%eax)
  8011e9:	e8 e8 fc ff ff       	call   800ed6 <dev_lookup>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 47                	js     80123c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fc:	75 21                	jne    80121f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	53                   	push   %ebx
  80120a:	50                   	push   %eax
  80120b:	68 8d 22 80 00       	push   $0x80228d
  801210:	e8 7f ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121d:	eb 26                	jmp    801245 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801222:	8b 52 0c             	mov    0xc(%edx),%edx
  801225:	85 d2                	test   %edx,%edx
  801227:	74 17                	je     801240 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	ff 75 10             	pushl  0x10(%ebp)
  80122f:	ff 75 0c             	pushl  0xc(%ebp)
  801232:	50                   	push   %eax
  801233:	ff d2                	call   *%edx
  801235:	89 c2                	mov    %eax,%edx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	eb 09                	jmp    801245 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	eb 05                	jmp    801245 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801240:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801245:	89 d0                	mov    %edx,%eax
  801247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <seek>:

int
seek(int fdnum, off_t offset)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801252:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	ff 75 08             	pushl  0x8(%ebp)
  801259:	e8 22 fc ff ff       	call   800e80 <fd_lookup>
  80125e:	83 c4 08             	add    $0x8,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 0e                	js     801273 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801265:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 14             	sub    $0x14,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	53                   	push   %ebx
  801284:	e8 f7 fb ff ff       	call   800e80 <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 65                	js     8012f7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	ff 30                	pushl  (%eax)
  80129e:	e8 33 fc ff ff       	call   800ed6 <dev_lookup>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 44                	js     8012ee <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b1:	75 21                	jne    8012d4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b8:	8b 40 48             	mov    0x48(%eax),%eax
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	53                   	push   %ebx
  8012bf:	50                   	push   %eax
  8012c0:	68 50 22 80 00       	push   $0x802250
  8012c5:	e8 ca ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d2:	eb 23                	jmp    8012f7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d7:	8b 52 18             	mov    0x18(%edx),%edx
  8012da:	85 d2                	test   %edx,%edx
  8012dc:	74 14                	je     8012f2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	ff 75 0c             	pushl  0xc(%ebp)
  8012e4:	50                   	push   %eax
  8012e5:	ff d2                	call   *%edx
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	eb 09                	jmp    8012f7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	eb 05                	jmp    8012f7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f7:	89 d0                	mov    %edx,%eax
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 6c fb ff ff       	call   800e80 <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	89 c2                	mov    %eax,%edx
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 58                	js     801375 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	ff 30                	pushl  (%eax)
  801329:	e8 a8 fb ff ff       	call   800ed6 <dev_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 37                	js     80136c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801338:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133c:	74 32                	je     801370 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801341:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801348:	00 00 00 
	stat->st_isdir = 0;
  80134b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801352:	00 00 00 
	stat->st_dev = dev;
  801355:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	53                   	push   %ebx
  80135f:	ff 75 f0             	pushl  -0x10(%ebp)
  801362:	ff 50 14             	call   *0x14(%eax)
  801365:	89 c2                	mov    %eax,%edx
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	eb 09                	jmp    801375 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	eb 05                	jmp    801375 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801370:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801375:	89 d0                	mov    %edx,%eax
  801377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	6a 00                	push   $0x0
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 09 02 00 00       	call   801597 <open>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 db                	test   %ebx,%ebx
  801395:	78 1b                	js     8013b2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	ff 75 0c             	pushl  0xc(%ebp)
  80139d:	53                   	push   %ebx
  80139e:	e8 5b ff ff ff       	call   8012fe <fstat>
  8013a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a5:	89 1c 24             	mov    %ebx,(%esp)
  8013a8:	e8 fd fb ff ff       	call   800faa <close>
	return r;
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	89 f0                	mov    %esi,%eax
}
  8013b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	89 c6                	mov    %eax,%esi
  8013c0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c9:	75 12                	jne    8013dd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	6a 01                	push   $0x1
  8013d0:	e8 fd f9 ff ff       	call   800dd2 <ipc_find_env>
  8013d5:	a3 00 40 80 00       	mov    %eax,0x804000
  8013da:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013dd:	6a 07                	push   $0x7
  8013df:	68 00 50 80 00       	push   $0x805000
  8013e4:	56                   	push   %esi
  8013e5:	ff 35 00 40 80 00    	pushl  0x804000
  8013eb:	e8 8e f9 ff ff       	call   800d7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f0:	83 c4 0c             	add    $0xc,%esp
  8013f3:	6a 00                	push   $0x0
  8013f5:	53                   	push   %ebx
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 18 f9 ff ff       	call   800d15 <ipc_recv>
}
  8013fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	8b 40 0c             	mov    0xc(%eax),%eax
  801410:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801415:	8b 45 0c             	mov    0xc(%ebp),%eax
  801418:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 02 00 00 00       	mov    $0x2,%eax
  801427:	e8 8d ff ff ff       	call   8013b9 <fsipc>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 06 00 00 00       	mov    $0x6,%eax
  801449:	e8 6b ff ff ff       	call   8013b9 <fsipc>
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	53                   	push   %ebx
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 05 00 00 00       	mov    $0x5,%eax
  80146f:	e8 45 ff ff ff       	call   8013b9 <fsipc>
  801474:	89 c2                	mov    %eax,%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	78 2c                	js     8014a6 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	68 00 50 80 00       	push   $0x805000
  801482:	53                   	push   %ebx
  801483:	e8 93 f2 ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801488:	a1 80 50 80 00       	mov    0x805080,%eax
  80148d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801493:	a1 84 50 80 00       	mov    0x805084,%eax
  801498:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	57                   	push   %edi
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014c5:	eb 3d                	jmp    801504 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014c7:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014cd:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014d2:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	57                   	push   %edi
  8014d9:	53                   	push   %ebx
  8014da:	68 08 50 80 00       	push   $0x805008
  8014df:	e8 c9 f3 ff ff       	call   8008ad <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014e4:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f4:	e8 c0 fe ff ff       	call   8013b9 <fsipc>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 0d                	js     80150d <devfile_write+0x62>
		        return r;
                n -= tmp;
  801500:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801502:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801504:	85 f6                	test   %esi,%esi
  801506:	75 bf                	jne    8014c7 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80150d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	8b 40 0c             	mov    0xc(%eax),%eax
  801523:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801528:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 03 00 00 00       	mov    $0x3,%eax
  801538:	e8 7c fe ff ff       	call   8013b9 <fsipc>
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 4b                	js     80158e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801543:	39 c6                	cmp    %eax,%esi
  801545:	73 16                	jae    80155d <devfile_read+0x48>
  801547:	68 bc 22 80 00       	push   $0x8022bc
  80154c:	68 c3 22 80 00       	push   $0x8022c3
  801551:	6a 7c                	push   $0x7c
  801553:	68 d8 22 80 00       	push   $0x8022d8
  801558:	e8 ba 05 00 00       	call   801b17 <_panic>
	assert(r <= PGSIZE);
  80155d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801562:	7e 16                	jle    80157a <devfile_read+0x65>
  801564:	68 e3 22 80 00       	push   $0x8022e3
  801569:	68 c3 22 80 00       	push   $0x8022c3
  80156e:	6a 7d                	push   $0x7d
  801570:	68 d8 22 80 00       	push   $0x8022d8
  801575:	e8 9d 05 00 00       	call   801b17 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	50                   	push   %eax
  80157e:	68 00 50 80 00       	push   $0x805000
  801583:	ff 75 0c             	pushl  0xc(%ebp)
  801586:	e8 22 f3 ff ff       	call   8008ad <memmove>
	return r;
  80158b:	83 c4 10             	add    $0x10,%esp
}
  80158e:	89 d8                	mov    %ebx,%eax
  801590:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 20             	sub    $0x20,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a1:	53                   	push   %ebx
  8015a2:	e8 3b f1 ff ff       	call   8006e2 <strlen>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015af:	7f 67                	jg     801618 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	e8 74 f8 ff ff       	call   800e31 <fd_alloc>
  8015bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 57                	js     80161d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	68 00 50 80 00       	push   $0x805000
  8015cf:	e8 47 f1 ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e4:	e8 d0 fd ff ff       	call   8013b9 <fsipc>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	79 14                	jns    801606 <open+0x6f>
		fd_close(fd, 0);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	6a 00                	push   $0x0
  8015f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fa:	e8 2a f9 ff ff       	call   800f29 <fd_close>
		return r;
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	89 da                	mov    %ebx,%edx
  801604:	eb 17                	jmp    80161d <open+0x86>
	}

	return fd2num(fd);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	ff 75 f4             	pushl  -0xc(%ebp)
  80160c:	e8 f9 f7 ff ff       	call   800e0a <fd2num>
  801611:	89 c2                	mov    %eax,%edx
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb 05                	jmp    80161d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801618:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162a:	ba 00 00 00 00       	mov    $0x0,%edx
  80162f:	b8 08 00 00 00       	mov    $0x8,%eax
  801634:	e8 80 fd ff ff       	call   8013b9 <fsipc>
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	ff 75 08             	pushl  0x8(%ebp)
  801649:	e8 cc f7 ff ff       	call   800e1a <fd2data>
  80164e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	68 ef 22 80 00       	push   $0x8022ef
  801658:	53                   	push   %ebx
  801659:	e8 bd f0 ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80165e:	8b 56 04             	mov    0x4(%esi),%edx
  801661:	89 d0                	mov    %edx,%eax
  801663:	2b 06                	sub    (%esi),%eax
  801665:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80166b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801672:	00 00 00 
	stat->st_dev = &devpipe;
  801675:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80167c:	30 80 00 
	return 0;
}
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
  801684:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801695:	53                   	push   %ebx
  801696:	6a 00                	push   $0x0
  801698:	e8 0c f5 ff ff       	call   800ba9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80169d:	89 1c 24             	mov    %ebx,(%esp)
  8016a0:	e8 75 f7 ff ff       	call   800e1a <fd2data>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	50                   	push   %eax
  8016a9:	6a 00                	push   $0x0
  8016ab:	e8 f9 f4 ff ff       	call   800ba9 <sys_page_unmap>
}
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	57                   	push   %edi
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 1c             	sub    $0x1c,%esp
  8016be:	89 c6                	mov    %eax,%esi
  8016c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	56                   	push   %esi
  8016cf:	e8 89 04 00 00       	call   801b5d <pageref>
  8016d4:	89 c7                	mov    %eax,%edi
  8016d6:	83 c4 04             	add    $0x4,%esp
  8016d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016dc:	e8 7c 04 00 00       	call   801b5d <pageref>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	39 c7                	cmp    %eax,%edi
  8016e6:	0f 94 c2             	sete   %dl
  8016e9:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8016ec:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8016f2:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8016f5:	39 fb                	cmp    %edi,%ebx
  8016f7:	74 19                	je     801712 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8016f9:	84 d2                	test   %dl,%dl
  8016fb:	74 c6                	je     8016c3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016fd:	8b 51 58             	mov    0x58(%ecx),%edx
  801700:	50                   	push   %eax
  801701:	52                   	push   %edx
  801702:	53                   	push   %ebx
  801703:	68 f6 22 80 00       	push   $0x8022f6
  801708:	e8 87 ea ff ff       	call   800194 <cprintf>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	eb b1                	jmp    8016c3 <_pipeisclosed+0xe>
	}
}
  801712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5f                   	pop    %edi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	57                   	push   %edi
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	83 ec 28             	sub    $0x28,%esp
  801723:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801726:	56                   	push   %esi
  801727:	e8 ee f6 ff ff       	call   800e1a <fd2data>
  80172c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	bf 00 00 00 00       	mov    $0x0,%edi
  801736:	eb 4b                	jmp    801783 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801738:	89 da                	mov    %ebx,%edx
  80173a:	89 f0                	mov    %esi,%eax
  80173c:	e8 74 ff ff ff       	call   8016b5 <_pipeisclosed>
  801741:	85 c0                	test   %eax,%eax
  801743:	75 48                	jne    80178d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801745:	e8 bb f3 ff ff       	call   800b05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80174a:	8b 43 04             	mov    0x4(%ebx),%eax
  80174d:	8b 0b                	mov    (%ebx),%ecx
  80174f:	8d 51 20             	lea    0x20(%ecx),%edx
  801752:	39 d0                	cmp    %edx,%eax
  801754:	73 e2                	jae    801738 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80175d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801760:	89 c2                	mov    %eax,%edx
  801762:	c1 fa 1f             	sar    $0x1f,%edx
  801765:	89 d1                	mov    %edx,%ecx
  801767:	c1 e9 1b             	shr    $0x1b,%ecx
  80176a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80176d:	83 e2 1f             	and    $0x1f,%edx
  801770:	29 ca                	sub    %ecx,%edx
  801772:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801776:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80177a:	83 c0 01             	add    $0x1,%eax
  80177d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801780:	83 c7 01             	add    $0x1,%edi
  801783:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801786:	75 c2                	jne    80174a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801788:	8b 45 10             	mov    0x10(%ebp),%eax
  80178b:	eb 05                	jmp    801792 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5f                   	pop    %edi
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	57                   	push   %edi
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 18             	sub    $0x18,%esp
  8017a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017a6:	57                   	push   %edi
  8017a7:	e8 6e f6 ff ff       	call   800e1a <fd2data>
  8017ac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b6:	eb 3d                	jmp    8017f5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b8:	85 db                	test   %ebx,%ebx
  8017ba:	74 04                	je     8017c0 <devpipe_read+0x26>
				return i;
  8017bc:	89 d8                	mov    %ebx,%eax
  8017be:	eb 44                	jmp    801804 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c0:	89 f2                	mov    %esi,%edx
  8017c2:	89 f8                	mov    %edi,%eax
  8017c4:	e8 ec fe ff ff       	call   8016b5 <_pipeisclosed>
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	75 32                	jne    8017ff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017cd:	e8 33 f3 ff ff       	call   800b05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d2:	8b 06                	mov    (%esi),%eax
  8017d4:	3b 46 04             	cmp    0x4(%esi),%eax
  8017d7:	74 df                	je     8017b8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d9:	99                   	cltd   
  8017da:	c1 ea 1b             	shr    $0x1b,%edx
  8017dd:	01 d0                	add    %edx,%eax
  8017df:	83 e0 1f             	and    $0x1f,%eax
  8017e2:	29 d0                	sub    %edx,%eax
  8017e4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f2:	83 c3 01             	add    $0x1,%ebx
  8017f5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f8:	75 d8                	jne    8017d2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fd:	eb 05                	jmp    801804 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5f                   	pop    %edi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
  801811:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	e8 14 f6 ff ff       	call   800e31 <fd_alloc>
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	89 c2                	mov    %eax,%edx
  801822:	85 c0                	test   %eax,%eax
  801824:	0f 88 2c 01 00 00    	js     801956 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182a:	83 ec 04             	sub    $0x4,%esp
  80182d:	68 07 04 00 00       	push   $0x407
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	6a 00                	push   $0x0
  801837:	e8 e8 f2 ff ff       	call   800b24 <sys_page_alloc>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	89 c2                	mov    %eax,%edx
  801841:	85 c0                	test   %eax,%eax
  801843:	0f 88 0d 01 00 00    	js     801956 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	e8 dc f5 ff ff       	call   800e31 <fd_alloc>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	0f 88 e2 00 00 00    	js     801944 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	68 07 04 00 00       	push   $0x407
  80186a:	ff 75 f0             	pushl  -0x10(%ebp)
  80186d:	6a 00                	push   $0x0
  80186f:	e8 b0 f2 ff ff       	call   800b24 <sys_page_alloc>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	0f 88 c3 00 00 00    	js     801944 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801881:	83 ec 0c             	sub    $0xc,%esp
  801884:	ff 75 f4             	pushl  -0xc(%ebp)
  801887:	e8 8e f5 ff ff       	call   800e1a <fd2data>
  80188c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188e:	83 c4 0c             	add    $0xc,%esp
  801891:	68 07 04 00 00       	push   $0x407
  801896:	50                   	push   %eax
  801897:	6a 00                	push   $0x0
  801899:	e8 86 f2 ff ff       	call   800b24 <sys_page_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	0f 88 89 00 00 00    	js     801934 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b1:	e8 64 f5 ff ff       	call   800e1a <fd2data>
  8018b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018bd:	50                   	push   %eax
  8018be:	6a 00                	push   $0x0
  8018c0:	56                   	push   %esi
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 9f f2 ff ff       	call   800b67 <sys_page_map>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	83 c4 20             	add    $0x20,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 55                	js     801926 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801901:	e8 04 f5 ff ff       	call   800e0a <fd2num>
  801906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801909:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80190b:	83 c4 04             	add    $0x4,%esp
  80190e:	ff 75 f0             	pushl  -0x10(%ebp)
  801911:	e8 f4 f4 ff ff       	call   800e0a <fd2num>
  801916:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801919:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	eb 30                	jmp    801956 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	56                   	push   %esi
  80192a:	6a 00                	push   $0x0
  80192c:	e8 78 f2 ff ff       	call   800ba9 <sys_page_unmap>
  801931:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 f0             	pushl  -0x10(%ebp)
  80193a:	6a 00                	push   $0x0
  80193c:	e8 68 f2 ff ff       	call   800ba9 <sys_page_unmap>
  801941:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	ff 75 f4             	pushl  -0xc(%ebp)
  80194a:	6a 00                	push   $0x0
  80194c:	e8 58 f2 ff ff       	call   800ba9 <sys_page_unmap>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801956:	89 d0                	mov    %edx,%eax
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801965:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801968:	50                   	push   %eax
  801969:	ff 75 08             	pushl  0x8(%ebp)
  80196c:	e8 0f f5 ff ff       	call   800e80 <fd_lookup>
  801971:	89 c2                	mov    %eax,%edx
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	85 d2                	test   %edx,%edx
  801978:	78 18                	js     801992 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	ff 75 f4             	pushl  -0xc(%ebp)
  801980:	e8 95 f4 ff ff       	call   800e1a <fd2data>
	return _pipeisclosed(fd, p);
  801985:	89 c2                	mov    %eax,%edx
  801987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198a:	e8 26 fd ff ff       	call   8016b5 <_pipeisclosed>
  80198f:	83 c4 10             	add    $0x10,%esp
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a4:	68 0e 23 80 00       	push   $0x80230e
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	e8 6a ed ff ff       	call   80071b <strcpy>
	return 0;
}
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	57                   	push   %edi
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
  8019be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019cf:	eb 2d                	jmp    8019fe <devcons_write+0x46>
		m = n - tot;
  8019d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019d6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019de:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e1:	83 ec 04             	sub    $0x4,%esp
  8019e4:	53                   	push   %ebx
  8019e5:	03 45 0c             	add    0xc(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	57                   	push   %edi
  8019ea:	e8 be ee ff ff       	call   8008ad <memmove>
		sys_cputs(buf, m);
  8019ef:	83 c4 08             	add    $0x8,%esp
  8019f2:	53                   	push   %ebx
  8019f3:	57                   	push   %edi
  8019f4:	e8 6f f0 ff ff       	call   800a68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f9:	01 de                	add    %ebx,%esi
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 f0                	mov    %esi,%eax
  801a00:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a03:	72 cc                	jb     8019d1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1c:	75 07                	jne    801a25 <devcons_read+0x18>
  801a1e:	eb 28                	jmp    801a48 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a20:	e8 e0 f0 ff ff       	call   800b05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a25:	e8 5c f0 ff ff       	call   800a86 <sys_cgetc>
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	74 f2                	je     801a20 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 16                	js     801a48 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a32:	83 f8 04             	cmp    $0x4,%eax
  801a35:	74 0c                	je     801a43 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3a:	88 02                	mov    %al,(%edx)
	return 1;
  801a3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a41:	eb 05                	jmp    801a48 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a56:	6a 01                	push   $0x1
  801a58:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a5b:	50                   	push   %eax
  801a5c:	e8 07 f0 ff ff       	call   800a68 <sys_cputs>
  801a61:	83 c4 10             	add    $0x10,%esp
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <getchar>:

int
getchar(void)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a6c:	6a 01                	push   $0x1
  801a6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a71:	50                   	push   %eax
  801a72:	6a 00                	push   $0x0
  801a74:	e8 71 f6 ff ff       	call   8010ea <read>
	if (r < 0)
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 0f                	js     801a8f <getchar+0x29>
		return r;
	if (r < 1)
  801a80:	85 c0                	test   %eax,%eax
  801a82:	7e 06                	jle    801a8a <getchar+0x24>
		return -E_EOF;
	return c;
  801a84:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a88:	eb 05                	jmp    801a8f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a8a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9a:	50                   	push   %eax
  801a9b:	ff 75 08             	pushl  0x8(%ebp)
  801a9e:	e8 dd f3 ff ff       	call   800e80 <fd_lookup>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	78 11                	js     801abb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab3:	39 10                	cmp    %edx,(%eax)
  801ab5:	0f 94 c0             	sete   %al
  801ab8:	0f b6 c0             	movzbl %al,%eax
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <opencons>:

int
opencons(void)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac6:	50                   	push   %eax
  801ac7:	e8 65 f3 ff ff       	call   800e31 <fd_alloc>
  801acc:	83 c4 10             	add    $0x10,%esp
		return r;
  801acf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 3e                	js     801b13 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	68 07 04 00 00       	push   $0x407
  801add:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae0:	6a 00                	push   $0x0
  801ae2:	e8 3d f0 ff ff       	call   800b24 <sys_page_alloc>
  801ae7:	83 c4 10             	add    $0x10,%esp
		return r;
  801aea:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 23                	js     801b13 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	50                   	push   %eax
  801b09:	e8 fc f2 ff ff       	call   800e0a <fd2num>
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	83 c4 10             	add    $0x10,%esp
}
  801b13:	89 d0                	mov    %edx,%eax
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b1c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b25:	e8 bc ef ff ff       	call   800ae6 <sys_getenvid>
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 0c             	pushl  0xc(%ebp)
  801b30:	ff 75 08             	pushl  0x8(%ebp)
  801b33:	56                   	push   %esi
  801b34:	50                   	push   %eax
  801b35:	68 1c 23 80 00       	push   $0x80231c
  801b3a:	e8 55 e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b3f:	83 c4 18             	add    $0x18,%esp
  801b42:	53                   	push   %ebx
  801b43:	ff 75 10             	pushl  0x10(%ebp)
  801b46:	e8 f8 e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b4b:	c7 04 24 07 23 80 00 	movl   $0x802307,(%esp)
  801b52:	e8 3d e6 ff ff       	call   800194 <cprintf>
  801b57:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b5a:	cc                   	int3   
  801b5b:	eb fd                	jmp    801b5a <_panic+0x43>

00801b5d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	c1 e8 16             	shr    $0x16,%eax
  801b68:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b74:	f6 c1 01             	test   $0x1,%cl
  801b77:	74 1d                	je     801b96 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b79:	c1 ea 0c             	shr    $0xc,%edx
  801b7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b83:	f6 c2 01             	test   $0x1,%dl
  801b86:	74 0e                	je     801b96 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b88:	c1 ea 0c             	shr    $0xc,%edx
  801b8b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b92:	ef 
  801b93:	0f b7 c0             	movzwl %ax,%eax
}
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	83 ec 10             	sub    $0x10,%esp
  801ba6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801baa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bae:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bb2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bb6:	85 d2                	test   %edx,%edx
  801bb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bbc:	89 34 24             	mov    %esi,(%esp)
  801bbf:	89 c8                	mov    %ecx,%eax
  801bc1:	75 35                	jne    801bf8 <__udivdi3+0x58>
  801bc3:	39 f1                	cmp    %esi,%ecx
  801bc5:	0f 87 bd 00 00 00    	ja     801c88 <__udivdi3+0xe8>
  801bcb:	85 c9                	test   %ecx,%ecx
  801bcd:	89 cd                	mov    %ecx,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f1                	div    %ecx
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 f0                	mov    %esi,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c6                	mov    %eax,%esi
  801be4:	89 f8                	mov    %edi,%eax
  801be6:	f7 f5                	div    %ebp
  801be8:	89 f2                	mov    %esi,%edx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    
  801bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	3b 14 24             	cmp    (%esp),%edx
  801bfb:	77 7b                	ja     801c78 <__udivdi3+0xd8>
  801bfd:	0f bd f2             	bsr    %edx,%esi
  801c00:	83 f6 1f             	xor    $0x1f,%esi
  801c03:	0f 84 97 00 00 00    	je     801ca0 <__udivdi3+0x100>
  801c09:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c0e:	89 d7                	mov    %edx,%edi
  801c10:	89 f1                	mov    %esi,%ecx
  801c12:	29 f5                	sub    %esi,%ebp
  801c14:	d3 e7                	shl    %cl,%edi
  801c16:	89 c2                	mov    %eax,%edx
  801c18:	89 e9                	mov    %ebp,%ecx
  801c1a:	d3 ea                	shr    %cl,%edx
  801c1c:	89 f1                	mov    %esi,%ecx
  801c1e:	09 fa                	or     %edi,%edx
  801c20:	8b 3c 24             	mov    (%esp),%edi
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c29:	89 e9                	mov    %ebp,%ecx
  801c2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c33:	89 fa                	mov    %edi,%edx
  801c35:	d3 ea                	shr    %cl,%edx
  801c37:	89 f1                	mov    %esi,%ecx
  801c39:	d3 e7                	shl    %cl,%edi
  801c3b:	89 e9                	mov    %ebp,%ecx
  801c3d:	d3 e8                	shr    %cl,%eax
  801c3f:	09 c7                	or     %eax,%edi
  801c41:	89 f8                	mov    %edi,%eax
  801c43:	f7 74 24 08          	divl   0x8(%esp)
  801c47:	89 d5                	mov    %edx,%ebp
  801c49:	89 c7                	mov    %eax,%edi
  801c4b:	f7 64 24 0c          	mull   0xc(%esp)
  801c4f:	39 d5                	cmp    %edx,%ebp
  801c51:	89 14 24             	mov    %edx,(%esp)
  801c54:	72 11                	jb     801c67 <__udivdi3+0xc7>
  801c56:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c5a:	89 f1                	mov    %esi,%ecx
  801c5c:	d3 e2                	shl    %cl,%edx
  801c5e:	39 c2                	cmp    %eax,%edx
  801c60:	73 5e                	jae    801cc0 <__udivdi3+0x120>
  801c62:	3b 2c 24             	cmp    (%esp),%ebp
  801c65:	75 59                	jne    801cc0 <__udivdi3+0x120>
  801c67:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c6a:	31 f6                	xor    %esi,%esi
  801c6c:	89 f2                	mov    %esi,%edx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	31 f6                	xor    %esi,%esi
  801c7a:	31 c0                	xor    %eax,%eax
  801c7c:	89 f2                	mov    %esi,%edx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	31 f6                	xor    %esi,%esi
  801c8c:	89 f8                	mov    %edi,%eax
  801c8e:	f7 f1                	div    %ecx
  801c90:	89 f2                	mov    %esi,%edx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ca4:	76 0b                	jbe    801cb1 <__udivdi3+0x111>
  801ca6:	31 c0                	xor    %eax,%eax
  801ca8:	3b 14 24             	cmp    (%esp),%edx
  801cab:	0f 83 37 ff ff ff    	jae    801be8 <__udivdi3+0x48>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	e9 2d ff ff ff       	jmp    801be8 <__udivdi3+0x48>
  801cbb:	90                   	nop
  801cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 f8                	mov    %edi,%eax
  801cc2:	31 f6                	xor    %esi,%esi
  801cc4:	e9 1f ff ff ff       	jmp    801be8 <__udivdi3+0x48>
  801cc9:	66 90                	xchg   %ax,%ax
  801ccb:	66 90                	xchg   %ax,%ax
  801ccd:	66 90                	xchg   %ax,%ax
  801ccf:	90                   	nop

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	83 ec 20             	sub    $0x20,%esp
  801cd6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801cda:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cde:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce2:	89 c6                	mov    %eax,%esi
  801ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ce8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cf0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cf4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cf8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	89 c2                	mov    %eax,%edx
  801d00:	75 1e                	jne    801d20 <__umoddi3+0x50>
  801d02:	39 f7                	cmp    %esi,%edi
  801d04:	76 52                	jbe    801d58 <__umoddi3+0x88>
  801d06:	89 c8                	mov    %ecx,%eax
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	f7 f7                	div    %edi
  801d0c:	89 d0                	mov    %edx,%eax
  801d0e:	31 d2                	xor    %edx,%edx
  801d10:	83 c4 20             	add    $0x20,%esp
  801d13:	5e                   	pop    %esi
  801d14:	5f                   	pop    %edi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    
  801d17:	89 f6                	mov    %esi,%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	39 f0                	cmp    %esi,%eax
  801d22:	77 5c                	ja     801d80 <__umoddi3+0xb0>
  801d24:	0f bd e8             	bsr    %eax,%ebp
  801d27:	83 f5 1f             	xor    $0x1f,%ebp
  801d2a:	75 64                	jne    801d90 <__umoddi3+0xc0>
  801d2c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d30:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d34:	0f 86 f6 00 00 00    	jbe    801e30 <__umoddi3+0x160>
  801d3a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d3e:	0f 82 ec 00 00 00    	jb     801e30 <__umoddi3+0x160>
  801d44:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d48:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d4c:	83 c4 20             	add    $0x20,%esp
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    
  801d53:	90                   	nop
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	85 ff                	test   %edi,%edi
  801d5a:	89 fd                	mov    %edi,%ebp
  801d5c:	75 0b                	jne    801d69 <__umoddi3+0x99>
  801d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f7                	div    %edi
  801d67:	89 c5                	mov    %eax,%ebp
  801d69:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f5                	div    %ebp
  801d71:	89 c8                	mov    %ecx,%eax
  801d73:	f7 f5                	div    %ebp
  801d75:	eb 95                	jmp    801d0c <__umoddi3+0x3c>
  801d77:	89 f6                	mov    %esi,%esi
  801d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 20             	add    $0x20,%esp
  801d87:	5e                   	pop    %esi
  801d88:	5f                   	pop    %edi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    
  801d8b:	90                   	nop
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	b8 20 00 00 00       	mov    $0x20,%eax
  801d95:	89 e9                	mov    %ebp,%ecx
  801d97:	29 e8                	sub    %ebp,%eax
  801d99:	d3 e2                	shl    %cl,%edx
  801d9b:	89 c7                	mov    %eax,%edi
  801d9d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801da1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801da5:	89 f9                	mov    %edi,%ecx
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 c1                	mov    %eax,%ecx
  801dab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801daf:	09 d1                	or     %edx,%ecx
  801db1:	89 fa                	mov    %edi,%edx
  801db3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801db7:	89 e9                	mov    %ebp,%ecx
  801db9:	d3 e0                	shl    %cl,%eax
  801dbb:	89 f9                	mov    %edi,%ecx
  801dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	d3 e8                	shr    %cl,%eax
  801dc5:	89 e9                	mov    %ebp,%ecx
  801dc7:	89 c7                	mov    %eax,%edi
  801dc9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dcd:	d3 e6                	shl    %cl,%esi
  801dcf:	89 d1                	mov    %edx,%ecx
  801dd1:	89 fa                	mov    %edi,%edx
  801dd3:	d3 e8                	shr    %cl,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	09 f0                	or     %esi,%eax
  801dd9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801ddd:	f7 74 24 10          	divl   0x10(%esp)
  801de1:	d3 e6                	shl    %cl,%esi
  801de3:	89 d1                	mov    %edx,%ecx
  801de5:	f7 64 24 0c          	mull   0xc(%esp)
  801de9:	39 d1                	cmp    %edx,%ecx
  801deb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801def:	89 d7                	mov    %edx,%edi
  801df1:	89 c6                	mov    %eax,%esi
  801df3:	72 0a                	jb     801dff <__umoddi3+0x12f>
  801df5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801df9:	73 10                	jae    801e0b <__umoddi3+0x13b>
  801dfb:	39 d1                	cmp    %edx,%ecx
  801dfd:	75 0c                	jne    801e0b <__umoddi3+0x13b>
  801dff:	89 d7                	mov    %edx,%edi
  801e01:	89 c6                	mov    %eax,%esi
  801e03:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e07:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e0b:	89 ca                	mov    %ecx,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e13:	29 f0                	sub    %esi,%eax
  801e15:	19 fa                	sbb    %edi,%edx
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e1e:	89 d7                	mov    %edx,%edi
  801e20:	d3 e7                	shl    %cl,%edi
  801e22:	89 e9                	mov    %ebp,%ecx
  801e24:	09 f8                	or     %edi,%eax
  801e26:	d3 ea                	shr    %cl,%edx
  801e28:	83 c4 20             	add    $0x20,%esp
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop
  801e30:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e34:	29 f9                	sub    %edi,%ecx
  801e36:	19 c6                	sbb    %eax,%esi
  801e38:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e3c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e40:	e9 ff fe ff ff       	jmp    801d44 <__umoddi3+0x74>
