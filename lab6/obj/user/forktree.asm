
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 e4 0a 00 00       	call   800b26 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 40 27 80 00       	push   $0x802740
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
  800067:	83 c4 10             	add    $0x10,%esp
}
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 9f 06 00 00       	call   800722 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 51 27 80 00       	push   $0x802751
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 63 06 00 00       	call   800708 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 2b 0e 00 00       	call   800ed8 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 50 27 80 00       	push   $0x802750
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
  8000dc:	83 c4 10             	add    $0x10,%esp
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000ec:	e8 35 0a 00 00       	call   800b26 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 9a 11 00 00       	call   8012cc <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 a9 09 00 00       	call   800ae5 <sys_env_destroy>
  80013c:	83 c4 10             	add    $0x10,%esp
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 37 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 4f 01 00 00       	call   800306 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 dc 08 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 d1                	mov    %edx,%ecx
  8001fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800200:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800203:	8b 45 10             	mov    0x10(%ebp),%eax
  800206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800209:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800213:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800216:	72 05                	jb     80021d <printnum+0x35>
  800218:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80021b:	77 3e                	ja     80025b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	53                   	push   %ebx
  800227:	50                   	push   %eax
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 54 22 00 00       	call   802490 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 13                	jmp    800262 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	85 db                	test   %ebx,%ebx
  800260:	7f ed                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	83 ec 04             	sub    $0x4,%esp
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	ff 75 dc             	pushl  -0x24(%ebp)
  800272:	ff 75 d8             	pushl  -0x28(%ebp)
  800275:	e8 46 23 00 00       	call   8025c0 <__umoddi3>
  80027a:	83 c4 14             	add    $0x14,%esp
  80027d:	0f be 80 60 27 80 00 	movsbl 0x802760(%eax),%eax
  800284:	50                   	push   %eax
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	88 02                	mov    %al,(%edx)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 10             	pushl  0x10(%ebp)
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	e8 05 00 00 00       	call   800306 <vprintfmt>
	va_end(ap);
  800301:	83 c4 10             	add    $0x10,%esp
}
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 2c             	sub    $0x2c,%esp
  80030f:	8b 75 08             	mov    0x8(%ebp),%esi
  800312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800315:	8b 7d 10             	mov    0x10(%ebp),%edi
  800318:	eb 12                	jmp    80032c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 84 90 03 00 00    	je     8006b2 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	53                   	push   %ebx
  800326:	50                   	push   %eax
  800327:	ff d6                	call   *%esi
  800329:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032c:	83 c7 01             	add    $0x1,%edi
  80032f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800333:	83 f8 25             	cmp    $0x25,%eax
  800336:	75 e2                	jne    80031a <vprintfmt+0x14>
  800338:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 07                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8d 47 01             	lea    0x1(%edi),%eax
  800362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800365:	0f b6 07             	movzbl (%edi),%eax
  800368:	0f b6 c8             	movzbl %al,%ecx
  80036b:	83 e8 23             	sub    $0x23,%eax
  80036e:	3c 55                	cmp    $0x55,%al
  800370:	0f 87 21 03 00 00    	ja     800697 <vprintfmt+0x391>
  800376:	0f b6 c0             	movzbl %al,%eax
  800379:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800383:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800387:	eb d6                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80039b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a1:	83 fa 09             	cmp    $0x9,%edx
  8003a4:	77 39                	ja     8003df <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bc:	eb 27                	jmp    8003e5 <vprintfmt+0xdf>
  8003be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c8:	0f 49 c8             	cmovns %eax,%ecx
  8003cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	eb 8c                	jmp    80035f <vprintfmt+0x59>
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003dd:	eb 80                	jmp    80035f <vprintfmt+0x59>
  8003df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 70 ff ff ff    	jns    80035f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 5e ff ff ff       	jmp    80035f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 53 ff ff ff       	jmp    80035f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 30                	pushl  (%eax)
  80041b:	ff d6                	call   *%esi
			break;
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 04 ff ff ff       	jmp    80032c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	99                   	cltd   
  800434:	31 d0                	xor    %edx,%eax
  800436:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800438:	83 f8 0f             	cmp    $0xf,%eax
  80043b:	7f 0b                	jg     800448 <vprintfmt+0x142>
  80043d:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800444:	85 d2                	test   %edx,%edx
  800446:	75 18                	jne    800460 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800448:	50                   	push   %eax
  800449:	68 78 27 80 00       	push   $0x802778
  80044e:	53                   	push   %ebx
  80044f:	56                   	push   %esi
  800450:	e8 94 fe ff ff       	call   8002e9 <printfmt>
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 cc fe ff ff       	jmp    80032c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 b1 2c 80 00       	push   $0x802cb1
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 7c fe ff ff       	call   8002e9 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	e9 b4 fe ff ff       	jmp    80032c <vprintfmt+0x26>
  800478:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048c:	85 ff                	test   %edi,%edi
  80048e:	ba 71 27 80 00       	mov    $0x802771,%edx
  800493:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800496:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049a:	0f 84 92 00 00 00    	je     800532 <vprintfmt+0x22c>
  8004a0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004a4:	0f 8e 96 00 00 00    	jle    800540 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	51                   	push   %ecx
  8004ae:	57                   	push   %edi
  8004af:	e8 86 02 00 00       	call   80073a <strnlen>
  8004b4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b7:	29 c1                	sub    %eax,%ecx
  8004b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	eb 0f                	jmp    8004dc <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 ef 01             	sub    $0x1,%edi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7f ed                	jg     8004cd <vprintfmt+0x1c7>
  8004e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e6:	85 c9                	test   %ecx,%ecx
  8004e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ed:	0f 49 c1             	cmovns %ecx,%eax
  8004f0:	29 c1                	sub    %eax,%ecx
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fb:	89 cb                	mov    %ecx,%ebx
  8004fd:	eb 4d                	jmp    80054c <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800503:	74 1b                	je     800520 <vprintfmt+0x21a>
  800505:	0f be c0             	movsbl %al,%eax
  800508:	83 e8 20             	sub    $0x20,%eax
  80050b:	83 f8 5e             	cmp    $0x5e,%eax
  80050e:	76 10                	jbe    800520 <vprintfmt+0x21a>
					putch('?', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	6a 3f                	push   $0x3f
  800518:	ff 55 08             	call   *0x8(%ebp)
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	eb 0d                	jmp    80052d <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	52                   	push   %edx
  800527:	ff 55 08             	call   *0x8(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052d:	83 eb 01             	sub    $0x1,%ebx
  800530:	eb 1a                	jmp    80054c <vprintfmt+0x246>
  800532:	89 75 08             	mov    %esi,0x8(%ebp)
  800535:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800538:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053e:	eb 0c                	jmp    80054c <vprintfmt+0x246>
  800540:	89 75 08             	mov    %esi,0x8(%ebp)
  800543:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800546:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800549:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054c:	83 c7 01             	add    $0x1,%edi
  80054f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800553:	0f be d0             	movsbl %al,%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	74 23                	je     80057d <vprintfmt+0x277>
  80055a:	85 f6                	test   %esi,%esi
  80055c:	78 a1                	js     8004ff <vprintfmt+0x1f9>
  80055e:	83 ee 01             	sub    $0x1,%esi
  800561:	79 9c                	jns    8004ff <vprintfmt+0x1f9>
  800563:	89 df                	mov    %ebx,%edi
  800565:	8b 75 08             	mov    0x8(%ebp),%esi
  800568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056b:	eb 18                	jmp    800585 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	6a 20                	push   $0x20
  800573:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 08                	jmp    800585 <vprintfmt+0x27f>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	85 ff                	test   %edi,%edi
  800587:	7f e4                	jg     80056d <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058c:	e9 9b fd ff ff       	jmp    80032c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800591:	83 fa 01             	cmp    $0x1,%edx
  800594:	7e 16                	jle    8005ac <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 50 08             	lea    0x8(%eax),%edx
  80059c:	89 55 14             	mov    %edx,0x14(%ebp)
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	eb 32                	jmp    8005de <vprintfmt+0x2d8>
	else if (lflag)
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 c1                	mov    %eax,%ecx
  8005c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c6:	eb 16                	jmp    8005de <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ed:	79 74                	jns    800663 <vprintfmt+0x35d>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fd:	f7 d8                	neg    %eax
  8005ff:	83 d2 00             	adc    $0x0,%edx
  800602:	f7 da                	neg    %edx
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060c:	eb 55                	jmp    800663 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 7c fc ff ff       	call   800292 <getuint>
			base = 10;
  800616:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061b:	eb 46                	jmp    800663 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061d:	8d 45 14             	lea    0x14(%ebp),%eax
  800620:	e8 6d fc ff ff       	call   800292 <getuint>
                        base = 8;
  800625:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80062a:	eb 37                	jmp    800663 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800654:	eb 0d                	jmp    800663 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 34 fc ff ff       	call   800292 <getuint>
			base = 16;
  80065e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800663:	83 ec 0c             	sub    $0xc,%esp
  800666:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066a:	57                   	push   %edi
  80066b:	ff 75 e0             	pushl  -0x20(%ebp)
  80066e:	51                   	push   %ecx
  80066f:	52                   	push   %edx
  800670:	50                   	push   %eax
  800671:	89 da                	mov    %ebx,%edx
  800673:	89 f0                	mov    %esi,%eax
  800675:	e8 6e fb ff ff       	call   8001e8 <printnum>
			break;
  80067a:	83 c4 20             	add    $0x20,%esp
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800680:	e9 a7 fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	51                   	push   %ecx
  80068a:	ff d6                	call   *%esi
			break;
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800692:	e9 95 fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 25                	push   $0x25
  80069d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 03                	jmp    8006a7 <vprintfmt+0x3a1>
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ab:	75 f7                	jne    8006a4 <vprintfmt+0x39e>
  8006ad:	e9 7a fc ff ff       	jmp    80032c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5e                   	pop    %esi
  8006b7:	5f                   	pop    %edi
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 18             	sub    $0x18,%esp
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 26                	je     800701 <vsnprintf+0x47>
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	7e 22                	jle    800701 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006df:	ff 75 14             	pushl  0x14(%ebp)
  8006e2:	ff 75 10             	pushl  0x10(%ebp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	68 cc 02 80 00       	push   $0x8002cc
  8006ee:	e8 13 fc ff ff       	call   800306 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 05                	jmp    800706 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	50                   	push   %eax
  800712:	ff 75 10             	pushl  0x10(%ebp)
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	ff 75 08             	pushl  0x8(%ebp)
  80071b:	e8 9a ff ff ff       	call   8006ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	eb 03                	jmp    800732 <strlen+0x10>
		n++;
  80072f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	75 f7                	jne    80072f <strlen+0xd>
		n++;
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	ba 00 00 00 00       	mov    $0x0,%edx
  800748:	eb 03                	jmp    80074d <strnlen+0x13>
		n++;
  80074a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	39 c2                	cmp    %eax,%edx
  80074f:	74 08                	je     800759 <strnlen+0x1f>
  800751:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800755:	75 f3                	jne    80074a <strnlen+0x10>
  800757:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	89 c2                	mov    %eax,%edx
  800767:	83 c2 01             	add    $0x1,%edx
  80076a:	83 c1 01             	add    $0x1,%ecx
  80076d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800771:	88 5a ff             	mov    %bl,-0x1(%edx)
  800774:	84 db                	test   %bl,%bl
  800776:	75 ef                	jne    800767 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800778:	5b                   	pop    %ebx
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	53                   	push   %ebx
  800783:	e8 9a ff ff ff       	call   800722 <strlen>
  800788:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	01 d8                	add    %ebx,%eax
  800790:	50                   	push   %eax
  800791:	e8 c5 ff ff ff       	call   80075b <strcpy>
	return dst;
}
  800796:	89 d8                	mov    %ebx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a8:	89 f3                	mov    %esi,%ebx
  8007aa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ad:	89 f2                	mov    %esi,%edx
  8007af:	eb 0f                	jmp    8007c0 <strncpy+0x23>
		*dst++ = *src;
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	0f b6 01             	movzbl (%ecx),%eax
  8007b7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ba:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	39 da                	cmp    %ebx,%edx
  8007c2:	75 ed                	jne    8007b1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c4:	89 f0                	mov    %esi,%eax
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	74 21                	je     8007ff <strlcpy+0x35>
  8007de:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e2:	89 f2                	mov    %esi,%edx
  8007e4:	eb 09                	jmp    8007ef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	83 c1 01             	add    $0x1,%ecx
  8007ec:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ef:	39 c2                	cmp    %eax,%edx
  8007f1:	74 09                	je     8007fc <strlcpy+0x32>
  8007f3:	0f b6 19             	movzbl (%ecx),%ebx
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	75 ec                	jne    8007e6 <strlcpy+0x1c>
  8007fa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ff:	29 f0                	sub    %esi,%eax
}
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080e:	eb 06                	jmp    800816 <strcmp+0x11>
		p++, q++;
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800816:	0f b6 01             	movzbl (%ecx),%eax
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x1c>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 ef                	je     800810 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	89 c3                	mov    %eax,%ebx
  800837:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083a:	eb 06                	jmp    800842 <strncmp+0x17>
		n--, p++, q++;
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 15                	je     80085b <strncmp+0x30>
  800846:	0f b6 08             	movzbl (%eax),%ecx
  800849:	84 c9                	test   %cl,%cl
  80084b:	74 04                	je     800851 <strncmp+0x26>
  80084d:	3a 0a                	cmp    (%edx),%cl
  80084f:	74 eb                	je     80083c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800851:	0f b6 00             	movzbl (%eax),%eax
  800854:	0f b6 12             	movzbl (%edx),%edx
  800857:	29 d0                	sub    %edx,%eax
  800859:	eb 05                	jmp    800860 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086d:	eb 07                	jmp    800876 <strchr+0x13>
		if (*s == c)
  80086f:	38 ca                	cmp    %cl,%dl
  800871:	74 0f                	je     800882 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	0f b6 10             	movzbl (%eax),%edx
  800879:	84 d2                	test   %dl,%dl
  80087b:	75 f2                	jne    80086f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088e:	eb 03                	jmp    800893 <strfind+0xf>
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800896:	84 d2                	test   %dl,%dl
  800898:	74 04                	je     80089e <strfind+0x1a>
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	75 f2                	jne    800890 <strfind+0xc>
			break;
	return (char *) s;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 36                	je     8008e6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b6:	75 28                	jne    8008e0 <memset+0x40>
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 23                	jne    8008e0 <memset+0x40>
		c &= 0xFF;
  8008bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c1:	89 d3                	mov    %edx,%ebx
  8008c3:	c1 e3 08             	shl    $0x8,%ebx
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	c1 e6 18             	shl    $0x18,%esi
  8008cb:	89 d0                	mov    %edx,%eax
  8008cd:	c1 e0 10             	shl    $0x10,%eax
  8008d0:	09 f0                	or     %esi,%eax
  8008d2:	09 c2                	or     %eax,%edx
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008db:	fc                   	cld    
  8008dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008de:	eb 06                	jmp    8008e6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e3:	fc                   	cld    
  8008e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e6:	89 f8                	mov    %edi,%eax
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fb:	39 c6                	cmp    %eax,%esi
  8008fd:	73 35                	jae    800934 <memmove+0x47>
  8008ff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800902:	39 d0                	cmp    %edx,%eax
  800904:	73 2e                	jae    800934 <memmove+0x47>
		s += n;
		d += n;
  800906:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800909:	89 d6                	mov    %edx,%esi
  80090b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800913:	75 13                	jne    800928 <memmove+0x3b>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 0e                	jne    800928 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091a:	83 ef 04             	sub    $0x4,%edi
  80091d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800920:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800923:	fd                   	std    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 09                	jmp    800931 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800928:	83 ef 01             	sub    $0x1,%edi
  80092b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092e:	fd                   	std    
  80092f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800931:	fc                   	cld    
  800932:	eb 1d                	jmp    800951 <memmove+0x64>
  800934:	89 f2                	mov    %esi,%edx
  800936:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800938:	f6 c2 03             	test   $0x3,%dl
  80093b:	75 0f                	jne    80094c <memmove+0x5f>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 0a                	jne    80094c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800942:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094c:	89 c7                	mov    %eax,%edi
  80094e:	fc                   	cld    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800958:	ff 75 10             	pushl  0x10(%ebp)
  80095b:	ff 75 0c             	pushl  0xc(%ebp)
  80095e:	ff 75 08             	pushl  0x8(%ebp)
  800961:	e8 87 ff ff ff       	call   8008ed <memmove>
}
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c6                	mov    %eax,%esi
  800975:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	eb 1a                	jmp    800994 <memcmp+0x2c>
		if (*s1 != *s2)
  80097a:	0f b6 08             	movzbl (%eax),%ecx
  80097d:	0f b6 1a             	movzbl (%edx),%ebx
  800980:	38 d9                	cmp    %bl,%cl
  800982:	74 0a                	je     80098e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800984:	0f b6 c1             	movzbl %cl,%eax
  800987:	0f b6 db             	movzbl %bl,%ebx
  80098a:	29 d8                	sub    %ebx,%eax
  80098c:	eb 0f                	jmp    80099d <memcmp+0x35>
		s1++, s2++;
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	39 f0                	cmp    %esi,%eax
  800996:	75 e2                	jne    80097a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009af:	eb 07                	jmp    8009b8 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	74 07                	je     8009bc <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	72 f5                	jb     8009b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ca:	eb 03                	jmp    8009cf <strtol+0x11>
		s++;
  8009cc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	3c 09                	cmp    $0x9,%al
  8009d4:	74 f6                	je     8009cc <strtol+0xe>
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f2                	je     8009cc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009da:	3c 2b                	cmp    $0x2b,%al
  8009dc:	75 0a                	jne    8009e8 <strtol+0x2a>
		s++;
  8009de:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e6:	eb 10                	jmp    8009f8 <strtol+0x3a>
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ed:	3c 2d                	cmp    $0x2d,%al
  8009ef:	75 07                	jne    8009f8 <strtol+0x3a>
		s++, neg = 1;
  8009f1:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009f4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	0f 94 c0             	sete   %al
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 19                	jne    800a1e <strtol+0x60>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	75 14                	jne    800a1e <strtol+0x60>
  800a0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0e:	0f 85 82 00 00 00    	jne    800a96 <strtol+0xd8>
		s += 2, base = 16;
  800a14:	83 c1 02             	add    $0x2,%ecx
  800a17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1c:	eb 16                	jmp    800a34 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 12                	je     800a34 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a27:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2a:	75 08                	jne    800a34 <strtol+0x76>
		s++, base = 8;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3c:	0f b6 11             	movzbl (%ecx),%edx
  800a3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 09             	cmp    $0x9,%bl
  800a47:	77 08                	ja     800a51 <strtol+0x93>
			dig = *s - '0';
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 30             	sub    $0x30,%edx
  800a4f:	eb 22                	jmp    800a73 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 08                	ja     800a63 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 57             	sub    $0x57,%edx
  800a61:	eb 10                	jmp    800a73 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 16                	ja     800a83 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a76:	7d 0f                	jge    800a87 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a81:	eb b9                	jmp    800a3c <strtol+0x7e>
  800a83:	89 c2                	mov    %eax,%edx
  800a85:	eb 02                	jmp    800a89 <strtol+0xcb>
  800a87:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8d:	74 0d                	je     800a9c <strtol+0xde>
		*endptr = (char *) s;
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	89 0e                	mov    %ecx,(%esi)
  800a94:	eb 06                	jmp    800a9c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a96:	84 c0                	test   %al,%al
  800a98:	75 92                	jne    800a2c <strtol+0x6e>
  800a9a:	eb 98                	jmp    800a34 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a9c:	f7 da                	neg    %edx
  800a9e:	85 ff                	test   %edi,%edi
  800aa0:	0f 45 c2             	cmovne %edx,%eax
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	b8 03 00 00 00       	mov    $0x3,%eax
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 17                	jle    800b1e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 03                	push   $0x3
  800b0d:	68 9f 2a 80 00       	push   $0x802a9f
  800b12:	6a 22                	push   $0x22
  800b14:	68 bc 2a 80 00       	push   $0x802abc
  800b19:	e8 5f 17 00 00       	call   80227d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 02 00 00 00       	mov    $0x2,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_yield>:

void
sys_yield(void)
{      
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b6d:	be 00 00 00 00       	mov    $0x0,%esi
  800b72:	b8 04 00 00 00       	mov    $0x4,%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	89 f7                	mov    %esi,%edi
  800b82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 04                	push   $0x4
  800b8e:	68 9f 2a 80 00       	push   $0x802a9f
  800b93:	6a 22                	push   $0x22
  800b95:	68 bc 2a 80 00       	push   $0x802abc
  800b9a:	e8 de 16 00 00       	call   80227d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 05                	push   $0x5
  800bd0:	68 9f 2a 80 00       	push   $0x802a9f
  800bd5:	6a 22                	push   $0x22
  800bd7:	68 bc 2a 80 00       	push   $0x802abc
  800bdc:	e8 9c 16 00 00       	call   80227d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	89 de                	mov    %ebx,%esi
  800c06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 06                	push   $0x6
  800c12:	68 9f 2a 80 00       	push   $0x802a9f
  800c17:	6a 22                	push   $0x22
  800c19:	68 bc 2a 80 00       	push   $0x802abc
  800c1e:	e8 5a 16 00 00       	call   80227d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 08                	push   $0x8
  800c54:	68 9f 2a 80 00       	push   $0x802a9f
  800c59:	6a 22                	push   $0x22
  800c5b:	68 bc 2a 80 00       	push   $0x802abc
  800c60:	e8 18 16 00 00       	call   80227d <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 09                	push   $0x9
  800c96:	68 9f 2a 80 00       	push   $0x802a9f
  800c9b:	6a 22                	push   $0x22
  800c9d:	68 bc 2a 80 00       	push   $0x802abc
  800ca2:	e8 d6 15 00 00       	call   80227d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 0a                	push   $0xa
  800cd8:	68 9f 2a 80 00       	push   $0x802a9f
  800cdd:	6a 22                	push   $0x22
  800cdf:	68 bc 2a 80 00       	push   $0x802abc
  800ce4:	e8 94 15 00 00       	call   80227d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cf7:	be 00 00 00 00       	mov    $0x0,%esi
  800cfc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 0d                	push   $0xd
  800d3c:	68 9f 2a 80 00       	push   $0x802a9f
  800d41:	6a 22                	push   $0x22
  800d43:	68 bc 2a 80 00       	push   $0x802abc
  800d48:	e8 30 15 00 00       	call   80227d <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 17                	jle    800dad <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	50                   	push   %eax
  800d9a:	6a 0f                	push   $0xf
  800d9c:	68 9f 2a 80 00       	push   $0x802a9f
  800da1:	6a 22                	push   $0x22
  800da3:	68 bc 2a 80 00       	push   $0x802abc
  800da8:	e8 d0 14 00 00       	call   80227d <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_recv>:

int
sys_recv(void *addr)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc3:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 cb                	mov    %ecx,%ebx
  800dcd:	89 cf                	mov    %ecx,%edi
  800dcf:	89 ce                	mov    %ecx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 10                	push   $0x10
  800ddd:	68 9f 2a 80 00       	push   $0x802a9f
  800de2:	6a 22                	push   $0x22
  800de4:	68 bc 2a 80 00       	push   $0x802abc
  800de9:	e8 8f 14 00 00       	call   80227d <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e00:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e02:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e06:	74 2e                	je     800e36 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 16             	shr    $0x16,%edx
  800e0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 1d                	je     800e36 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 0c             	shr    $0xc,%edx
  800e1e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e25:	f6 c1 01             	test   $0x1,%cl
  800e28:	74 0c                	je     800e36 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e31:	f6 c6 08             	test   $0x8,%dh
  800e34:	75 14                	jne    800e4a <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 cc 2a 80 00       	push   $0x802acc
  800e3e:	6a 21                	push   $0x21
  800e40:	68 5f 2b 80 00       	push   $0x802b5f
  800e45:	e8 33 14 00 00       	call   80227d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4f:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	6a 07                	push   $0x7
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 02 fd ff ff       	call   800b64 <sys_page_alloc>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 14                	jns    800e7d <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 6a 2b 80 00       	push   $0x802b6a
  800e71:	6a 2b                	push   $0x2b
  800e73:	68 5f 2b 80 00       	push   $0x802b5f
  800e78:	e8 00 14 00 00       	call   80227d <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	68 00 10 00 00       	push   $0x1000
  800e85:	53                   	push   %ebx
  800e86:	68 00 f0 7f 00       	push   $0x7ff000
  800e8b:	e8 5d fa ff ff       	call   8008ed <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e90:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e97:	53                   	push   %ebx
  800e98:	6a 00                	push   $0x0
  800e9a:	68 00 f0 7f 00       	push   $0x7ff000
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 01 fd ff ff       	call   800ba7 <sys_page_map>
  800ea6:	83 c4 20             	add    $0x20,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 14                	jns    800ec1 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	68 80 2b 80 00       	push   $0x802b80
  800eb5:	6a 2e                	push   $0x2e
  800eb7:	68 5f 2b 80 00       	push   $0x802b5f
  800ebc:	e8 bc 13 00 00       	call   80227d <_panic>
        sys_page_unmap(0, PFTEMP); 
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	68 00 f0 7f 00       	push   $0x7ff000
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 19 fd ff ff       	call   800be9 <sys_page_unmap>
  800ed0:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800ee1:	68 f6 0d 80 00       	push   $0x800df6
  800ee6:	e8 d8 13 00 00       	call   8022c3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eeb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef0:	cd 30                	int    $0x30
  800ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	79 12                	jns    800f0e <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800efc:	50                   	push   %eax
  800efd:	68 94 2b 80 00       	push   $0x802b94
  800f02:	6a 6d                	push   $0x6d
  800f04:	68 5f 2b 80 00       	push   $0x802b5f
  800f09:	e8 6f 13 00 00       	call   80227d <_panic>
  800f0e:	89 c7                	mov    %eax,%edi
  800f10:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f15:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f19:	75 21                	jne    800f3c <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f1b:	e8 06 fc ff ff       	call   800b26 <sys_getenvid>
  800f20:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f25:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f28:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	e9 9c 01 00 00       	jmp    8010d8 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	c1 e8 16             	shr    $0x16,%eax
  800f41:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f48:	a8 01                	test   $0x1,%al
  800f4a:	0f 84 f3 00 00 00    	je     801043 <fork+0x16b>
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	c1 e8 0c             	shr    $0xc,%eax
  800f55:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	0f 84 de 00 00 00    	je     801043 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f65:	89 c6                	mov    %eax,%esi
  800f67:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f6a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f71:	f6 c6 04             	test   $0x4,%dh
  800f74:	74 37                	je     800fad <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	25 07 0e 00 00       	and    $0xe07,%eax
  800f85:	50                   	push   %eax
  800f86:	56                   	push   %esi
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 17 fc ff ff       	call   800ba7 <sys_page_map>
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 89 a8 00 00 00    	jns    801043 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  800f9b:	50                   	push   %eax
  800f9c:	68 f0 2a 80 00       	push   $0x802af0
  800fa1:	6a 49                	push   $0x49
  800fa3:	68 5f 2b 80 00       	push   $0x802b5f
  800fa8:	e8 d0 12 00 00       	call   80227d <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800fad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb4:	f6 c6 08             	test   $0x8,%dh
  800fb7:	75 0b                	jne    800fc4 <fork+0xec>
  800fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc0:	a8 02                	test   $0x2,%al
  800fc2:	74 57                	je     80101b <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	68 05 08 00 00       	push   $0x805
  800fcc:	56                   	push   %esi
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 d1 fb ff ff       	call   800ba7 <sys_page_map>
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 12                	jns    800fef <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  800fdd:	50                   	push   %eax
  800fde:	68 f0 2a 80 00       	push   $0x802af0
  800fe3:	6a 4c                	push   $0x4c
  800fe5:	68 5f 2b 80 00       	push   $0x802b5f
  800fea:	e8 8e 12 00 00       	call   80227d <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	68 05 08 00 00       	push   $0x805
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 a5 fb ff ff       	call   800ba7 <sys_page_map>
  801002:	83 c4 20             	add    $0x20,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	79 3a                	jns    801043 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801009:	50                   	push   %eax
  80100a:	68 14 2b 80 00       	push   $0x802b14
  80100f:	6a 4e                	push   $0x4e
  801011:	68 5f 2b 80 00       	push   $0x802b5f
  801016:	e8 62 12 00 00       	call   80227d <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	6a 05                	push   $0x5
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 7d fb ff ff       	call   800ba7 <sys_page_map>
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 12                	jns    801043 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801031:	50                   	push   %eax
  801032:	68 3c 2b 80 00       	push   $0x802b3c
  801037:	6a 50                	push   $0x50
  801039:	68 5f 2b 80 00       	push   $0x802b5f
  80103e:	e8 3a 12 00 00       	call   80227d <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801043:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801049:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80104f:	0f 85 e7 fe ff ff    	jne    800f3c <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	6a 07                	push   $0x7
  80105a:	68 00 f0 bf ee       	push   $0xeebff000
  80105f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801062:	e8 fd fa ff ff       	call   800b64 <sys_page_alloc>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 14                	jns    801082 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 a4 2b 80 00       	push   $0x802ba4
  801076:	6a 76                	push   $0x76
  801078:	68 5f 2b 80 00       	push   $0x802b5f
  80107d:	e8 fb 11 00 00       	call   80227d <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	68 32 23 80 00       	push   $0x802332
  80108a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108d:	e8 1d fc ff ff       	call   800caf <sys_env_set_pgfault_upcall>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 14                	jns    8010ad <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801099:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109c:	68 be 2b 80 00       	push   $0x802bbe
  8010a1:	6a 79                	push   $0x79
  8010a3:	68 5f 2b 80 00       	push   $0x802b5f
  8010a8:	e8 d0 11 00 00       	call   80227d <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8010ad:	83 ec 08             	sub    $0x8,%esp
  8010b0:	6a 02                	push   $0x2
  8010b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b5:	e8 71 fb ff ff       	call   800c2b <sys_env_set_status>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 14                	jns    8010d5 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c4:	68 db 2b 80 00       	push   $0x802bdb
  8010c9:	6a 7b                	push   $0x7b
  8010cb:	68 5f 2b 80 00       	push   $0x802b5f
  8010d0:	e8 a8 11 00 00       	call   80227d <_panic>
        return forkid;
  8010d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e6:	68 f2 2b 80 00       	push   $0x802bf2
  8010eb:	68 83 00 00 00       	push   $0x83
  8010f0:	68 5f 2b 80 00       	push   $0x802b5f
  8010f5:	e8 83 11 00 00       	call   80227d <_panic>

008010fa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	05 00 00 00 30       	add    $0x30000000,%eax
  801105:	c1 e8 0c             	shr    $0xc,%eax
}
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110d:	8b 45 08             	mov    0x8(%ebp),%eax
  801110:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801115:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801127:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 16             	shr    $0x16,%edx
  801131:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	74 11                	je     80114e <fd_alloc+0x2d>
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 0c             	shr    $0xc,%edx
  801142:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	75 09                	jne    801157 <fd_alloc+0x36>
			*fd_store = fd;
  80114e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801150:	b8 00 00 00 00       	mov    $0x0,%eax
  801155:	eb 17                	jmp    80116e <fd_alloc+0x4d>
  801157:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801161:	75 c9                	jne    80112c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801163:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801169:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801176:	83 f8 1f             	cmp    $0x1f,%eax
  801179:	77 36                	ja     8011b1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117b:	c1 e0 0c             	shl    $0xc,%eax
  80117e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 16             	shr    $0x16,%edx
  801188:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 24                	je     8011b8 <fd_lookup+0x48>
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 0c             	shr    $0xc,%edx
  801199:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a0:	f6 c2 01             	test   $0x1,%dl
  8011a3:	74 1a                	je     8011bf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	eb 13                	jmp    8011c4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b6:	eb 0c                	jmp    8011c4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bd:	eb 05                	jmp    8011c4 <fd_lookup+0x54>
  8011bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d4:	eb 13                	jmp    8011e9 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8011d6:	39 08                	cmp    %ecx,(%eax)
  8011d8:	75 0c                	jne    8011e6 <dev_lookup+0x20>
			*dev = devtab[i];
  8011da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	eb 36                	jmp    80121c <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e6:	83 c2 01             	add    $0x1,%edx
  8011e9:	8b 04 95 84 2c 80 00 	mov    0x802c84(,%edx,4),%eax
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	75 e2                	jne    8011d6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f9:	8b 40 48             	mov    0x48(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	51                   	push   %ecx
  801200:	50                   	push   %eax
  801201:	68 08 2c 80 00       	push   $0x802c08
  801206:	e8 c9 ef ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  80120b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 10             	sub    $0x10,%esp
  801226:	8b 75 08             	mov    0x8(%ebp),%esi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801230:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801236:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801239:	50                   	push   %eax
  80123a:	e8 31 ff ff ff       	call   801170 <fd_lookup>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 05                	js     80124b <fd_close+0x2d>
	    || fd != fd2)
  801246:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801249:	74 0c                	je     801257 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124b:	84 db                	test   %bl,%bl
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
  801252:	0f 44 c2             	cmove  %edx,%eax
  801255:	eb 41                	jmp    801298 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	ff 36                	pushl  (%esi)
  801260:	e8 61 ff ff ff       	call   8011c6 <dev_lookup>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1a                	js     801288 <fd_close+0x6a>
		if (dev->dev_close)
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801279:	85 c0                	test   %eax,%eax
  80127b:	74 0b                	je     801288 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	56                   	push   %esi
  801281:	ff d0                	call   *%eax
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	56                   	push   %esi
  80128c:	6a 00                	push   $0x0
  80128e:	e8 56 f9 ff ff       	call   800be9 <sys_page_unmap>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 d8                	mov    %ebx,%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 bf fe ff ff       	call   801170 <fd_lookup>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	78 10                	js     8012ca <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	6a 01                	push   $0x1
  8012bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c2:	e8 57 ff ff ff       	call   80121e <fd_close>
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <close_all>:

void
close_all(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	53                   	push   %ebx
  8012dc:	e8 be ff ff ff       	call   80129f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e1:	83 c3 01             	add    $0x1,%ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	83 fb 20             	cmp    $0x20,%ebx
  8012ea:	75 ec                	jne    8012d8 <close_all+0xc>
		close(i);
}
  8012ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	57                   	push   %edi
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 2c             	sub    $0x2c,%esp
  8012fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 67 fe ff ff       	call   801170 <fd_lookup>
  801309:	89 c2                	mov    %eax,%edx
  80130b:	83 c4 08             	add    $0x8,%esp
  80130e:	85 d2                	test   %edx,%edx
  801310:	0f 88 c1 00 00 00    	js     8013d7 <dup+0xe6>
		return r;
	close(newfdnum);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	56                   	push   %esi
  80131a:	e8 80 ff ff ff       	call   80129f <close>

	newfd = INDEX2FD(newfdnum);
  80131f:	89 f3                	mov    %esi,%ebx
  801321:	c1 e3 0c             	shl    $0xc,%ebx
  801324:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80132a:	83 c4 04             	add    $0x4,%esp
  80132d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801330:	e8 d5 fd ff ff       	call   80110a <fd2data>
  801335:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801337:	89 1c 24             	mov    %ebx,(%esp)
  80133a:	e8 cb fd ff ff       	call   80110a <fd2data>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801345:	89 f8                	mov    %edi,%eax
  801347:	c1 e8 16             	shr    $0x16,%eax
  80134a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801351:	a8 01                	test   $0x1,%al
  801353:	74 37                	je     80138c <dup+0x9b>
  801355:	89 f8                	mov    %edi,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
  80135a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801361:	f6 c2 01             	test   $0x1,%dl
  801364:	74 26                	je     80138c <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801366:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	25 07 0e 00 00       	and    $0xe07,%eax
  801375:	50                   	push   %eax
  801376:	ff 75 d4             	pushl  -0x2c(%ebp)
  801379:	6a 00                	push   $0x0
  80137b:	57                   	push   %edi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 24 f8 ff ff       	call   800ba7 <sys_page_map>
  801383:	89 c7                	mov    %eax,%edi
  801385:	83 c4 20             	add    $0x20,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 2e                	js     8013ba <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138f:	89 d0                	mov    %edx,%eax
  801391:	c1 e8 0c             	shr    $0xc,%eax
  801394:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a3:	50                   	push   %eax
  8013a4:	53                   	push   %ebx
  8013a5:	6a 00                	push   $0x0
  8013a7:	52                   	push   %edx
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 f8 f7 ff ff       	call   800ba7 <sys_page_map>
  8013af:	89 c7                	mov    %eax,%edi
  8013b1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013b4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b6:	85 ff                	test   %edi,%edi
  8013b8:	79 1d                	jns    8013d7 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	53                   	push   %ebx
  8013be:	6a 00                	push   $0x0
  8013c0:	e8 24 f8 ff ff       	call   800be9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 17 f8 ff ff       	call   800be9 <sys_page_unmap>
	return r;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f8                	mov    %edi,%eax
}
  8013d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	53                   	push   %ebx
  8013ee:	e8 7d fd ff ff       	call   801170 <fd_lookup>
  8013f3:	83 c4 08             	add    $0x8,%esp
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 6d                	js     801469 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	ff 30                	pushl  (%eax)
  801408:	e8 b9 fd ff ff       	call   8011c6 <dev_lookup>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 4c                	js     801460 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801414:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801417:	8b 42 08             	mov    0x8(%edx),%eax
  80141a:	83 e0 03             	and    $0x3,%eax
  80141d:	83 f8 01             	cmp    $0x1,%eax
  801420:	75 21                	jne    801443 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801422:	a1 08 40 80 00       	mov    0x804008,%eax
  801427:	8b 40 48             	mov    0x48(%eax),%eax
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	53                   	push   %ebx
  80142e:	50                   	push   %eax
  80142f:	68 49 2c 80 00       	push   $0x802c49
  801434:	e8 9b ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801441:	eb 26                	jmp    801469 <read+0x8a>
	}
	if (!dev->dev_read)
  801443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801446:	8b 40 08             	mov    0x8(%eax),%eax
  801449:	85 c0                	test   %eax,%eax
  80144b:	74 17                	je     801464 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	ff 75 10             	pushl  0x10(%ebp)
  801453:	ff 75 0c             	pushl  0xc(%ebp)
  801456:	52                   	push   %edx
  801457:	ff d0                	call   *%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	eb 09                	jmp    801469 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801460:	89 c2                	mov    %eax,%edx
  801462:	eb 05                	jmp    801469 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801464:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801469:	89 d0                	mov    %edx,%eax
  80146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	8b 7d 08             	mov    0x8(%ebp),%edi
  80147c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801484:	eb 21                	jmp    8014a7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	89 f0                	mov    %esi,%eax
  80148b:	29 d8                	sub    %ebx,%eax
  80148d:	50                   	push   %eax
  80148e:	89 d8                	mov    %ebx,%eax
  801490:	03 45 0c             	add    0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	57                   	push   %edi
  801495:	e8 45 ff ff ff       	call   8013df <read>
		if (m < 0)
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 0c                	js     8014ad <readn+0x3d>
			return m;
		if (m == 0)
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	74 06                	je     8014ab <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a5:	01 c3                	add    %eax,%ebx
  8014a7:	39 f3                	cmp    %esi,%ebx
  8014a9:	72 db                	jb     801486 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014ab:	89 d8                	mov    %ebx,%eax
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	53                   	push   %ebx
  8014c4:	e8 a7 fc ff ff       	call   801170 <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 68                	js     80153a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	ff 30                	pushl  (%eax)
  8014de:	e8 e3 fc ff ff       	call   8011c6 <dev_lookup>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 47                	js     801531 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f1:	75 21                	jne    801514 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 65 2c 80 00       	push   $0x802c65
  801505:	e8 ca ec ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801512:	eb 26                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801514:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801517:	8b 52 0c             	mov    0xc(%edx),%edx
  80151a:	85 d2                	test   %edx,%edx
  80151c:	74 17                	je     801535 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	50                   	push   %eax
  801528:	ff d2                	call   *%edx
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <seek>:

int
seek(int fdnum, off_t offset)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801547:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 1d fc ff ff       	call   801170 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 0e                	js     801568 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801560:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801563:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	53                   	push   %ebx
  801579:	e8 f2 fb ff ff       	call   801170 <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	89 c2                	mov    %eax,%edx
  801583:	85 c0                	test   %eax,%eax
  801585:	78 65                	js     8015ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	ff 30                	pushl  (%eax)
  801593:	e8 2e fc ff ff       	call   8011c6 <dev_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 44                	js     8015e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a6:	75 21                	jne    8015c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ad:	8b 40 48             	mov    0x48(%eax),%eax
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	50                   	push   %eax
  8015b5:	68 28 2c 80 00       	push   $0x802c28
  8015ba:	e8 15 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c7:	eb 23                	jmp    8015ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cc:	8b 52 18             	mov    0x18(%edx),%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	74 14                	je     8015e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	50                   	push   %eax
  8015da:	ff d2                	call   *%edx
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb 09                	jmp    8015ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e3:	89 c2                	mov    %eax,%edx
  8015e5:	eb 05                	jmp    8015ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	e8 67 fb ff ff       	call   801170 <fd_lookup>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 58                	js     80166a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	ff 30                	pushl  (%eax)
  80161e:	e8 a3 fb ff ff       	call   8011c6 <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 37                	js     801661 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801631:	74 32                	je     801665 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801633:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801636:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163d:	00 00 00 
	stat->st_isdir = 0;
  801640:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801647:	00 00 00 
	stat->st_dev = dev;
  80164a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	ff 75 f0             	pushl  -0x10(%ebp)
  801657:	ff 50 14             	call   *0x14(%eax)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 09 02 00 00       	call   80188c <open>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 db                	test   %ebx,%ebx
  80168a:	78 1b                	js     8016a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	53                   	push   %ebx
  801693:	e8 5b ff ff ff       	call   8015f3 <fstat>
  801698:	89 c6                	mov    %eax,%esi
	close(fd);
  80169a:	89 1c 24             	mov    %ebx,(%esp)
  80169d:	e8 fd fb ff ff       	call   80129f <close>
	return r;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	89 f0                	mov    %esi,%eax
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	89 c6                	mov    %eax,%esi
  8016b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016be:	75 12                	jne    8016d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	6a 01                	push   $0x1
  8016c5:	e8 49 0d 00 00       	call   802413 <ipc_find_env>
  8016ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8016cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d2:	6a 07                	push   $0x7
  8016d4:	68 00 50 80 00       	push   $0x805000
  8016d9:	56                   	push   %esi
  8016da:	ff 35 00 40 80 00    	pushl  0x804000
  8016e0:	e8 da 0c 00 00       	call   8023bf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e5:	83 c4 0c             	add    $0xc,%esp
  8016e8:	6a 00                	push   $0x0
  8016ea:	53                   	push   %ebx
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 64 0c 00 00       	call   802356 <ipc_recv>
}
  8016f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 02 00 00 00       	mov    $0x2,%eax
  80171c:	e8 8d ff ff ff       	call   8016ae <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 06 00 00 00       	mov    $0x6,%eax
  80173e:	e8 6b ff ff ff       	call   8016ae <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 05 00 00 00       	mov    $0x5,%eax
  801764:	e8 45 ff ff ff       	call   8016ae <fsipc>
  801769:	89 c2                	mov    %eax,%edx
  80176b:	85 d2                	test   %edx,%edx
  80176d:	78 2c                	js     80179b <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	68 00 50 80 00       	push   $0x805000
  801777:	53                   	push   %ebx
  801778:	e8 de ef ff ff       	call   80075b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177d:	a1 80 50 80 00       	mov    0x805080,%eax
  801782:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801788:	a1 84 50 80 00       	mov    0x805084,%eax
  80178d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b2:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8017b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017ba:	eb 3d                	jmp    8017f9 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8017bc:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8017c2:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8017c7:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	57                   	push   %edi
  8017ce:	53                   	push   %ebx
  8017cf:	68 08 50 80 00       	push   $0x805008
  8017d4:	e8 14 f1 ff ff       	call   8008ed <memmove>
                fsipcbuf.write.req_n = tmp; 
  8017d9:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 c0 fe ff ff       	call   8016ae <fsipc>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 0d                	js     801802 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8017f5:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8017f7:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017f9:	85 f6                	test   %esi,%esi
  8017fb:	75 bf                	jne    8017bc <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8017fd:	89 d8                	mov    %ebx,%eax
  8017ff:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 03 00 00 00       	mov    $0x3,%eax
  80182d:	e8 7c fe ff ff       	call   8016ae <fsipc>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 4b                	js     801883 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801838:	39 c6                	cmp    %eax,%esi
  80183a:	73 16                	jae    801852 <devfile_read+0x48>
  80183c:	68 98 2c 80 00       	push   $0x802c98
  801841:	68 9f 2c 80 00       	push   $0x802c9f
  801846:	6a 7c                	push   $0x7c
  801848:	68 b4 2c 80 00       	push   $0x802cb4
  80184d:	e8 2b 0a 00 00       	call   80227d <_panic>
	assert(r <= PGSIZE);
  801852:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801857:	7e 16                	jle    80186f <devfile_read+0x65>
  801859:	68 bf 2c 80 00       	push   $0x802cbf
  80185e:	68 9f 2c 80 00       	push   $0x802c9f
  801863:	6a 7d                	push   $0x7d
  801865:	68 b4 2c 80 00       	push   $0x802cb4
  80186a:	e8 0e 0a 00 00       	call   80227d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	50                   	push   %eax
  801873:	68 00 50 80 00       	push   $0x805000
  801878:	ff 75 0c             	pushl  0xc(%ebp)
  80187b:	e8 6d f0 ff ff       	call   8008ed <memmove>
	return r;
  801880:	83 c4 10             	add    $0x10,%esp
}
  801883:	89 d8                	mov    %ebx,%eax
  801885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 20             	sub    $0x20,%esp
  801893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801896:	53                   	push   %ebx
  801897:	e8 86 ee ff ff       	call   800722 <strlen>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a4:	7f 67                	jg     80190d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	e8 6f f8 ff ff       	call   801121 <fd_alloc>
  8018b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 57                	js     801912 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	68 00 50 80 00       	push   $0x805000
  8018c4:	e8 92 ee ff ff       	call   80075b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d9:	e8 d0 fd ff ff       	call   8016ae <fsipc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 14                	jns    8018fb <open+0x6f>
		fd_close(fd, 0);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	6a 00                	push   $0x0
  8018ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ef:	e8 2a f9 ff ff       	call   80121e <fd_close>
		return r;
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	89 da                	mov    %ebx,%edx
  8018f9:	eb 17                	jmp    801912 <open+0x86>
	}

	return fd2num(fd);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801901:	e8 f4 f7 ff ff       	call   8010fa <fd2num>
  801906:	89 c2                	mov    %eax,%edx
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb 05                	jmp    801912 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80190d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	b8 08 00 00 00       	mov    $0x8,%eax
  801929:	e8 80 fd ff ff       	call   8016ae <fsipc>
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801936:	68 cb 2c 80 00       	push   $0x802ccb
  80193b:	ff 75 0c             	pushl  0xc(%ebp)
  80193e:	e8 18 ee ff ff       	call   80075b <strcpy>
	return 0;
}
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 10             	sub    $0x10,%esp
  801951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801954:	53                   	push   %ebx
  801955:	e8 f1 0a 00 00       	call   80244b <pageref>
  80195a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80195d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801962:	83 f8 01             	cmp    $0x1,%eax
  801965:	75 10                	jne    801977 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 73 0c             	pushl  0xc(%ebx)
  80196d:	e8 ca 02 00 00       	call   801c3c <nsipc_close>
  801972:	89 c2                	mov    %eax,%edx
  801974:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801977:	89 d0                	mov    %edx,%eax
  801979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801984:	6a 00                	push   $0x0
  801986:	ff 75 10             	pushl  0x10(%ebp)
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	ff 70 0c             	pushl  0xc(%eax)
  801992:	e8 82 03 00 00       	call   801d19 <nsipc_send>
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80199f:	6a 00                	push   $0x0
  8019a1:	ff 75 10             	pushl  0x10(%ebp)
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	ff 70 0c             	pushl  0xc(%eax)
  8019ad:	e8 fb 02 00 00       	call   801cad <nsipc_recv>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019ba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019bd:	52                   	push   %edx
  8019be:	50                   	push   %eax
  8019bf:	e8 ac f7 ff ff       	call   801170 <fd_lookup>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	78 17                	js     8019e2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019d4:	39 08                	cmp    %ecx,(%eax)
  8019d6:	75 05                	jne    8019dd <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019db:	eb 05                	jmp    8019e2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 1c             	sub    $0x1c,%esp
  8019ec:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	e8 2a f7 ff ff       	call   801121 <fd_alloc>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 1b                	js     801a1b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a00:	83 ec 04             	sub    $0x4,%esp
  801a03:	68 07 04 00 00       	push   $0x407
  801a08:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0b:	6a 00                	push   $0x0
  801a0d:	e8 52 f1 ff ff       	call   800b64 <sys_page_alloc>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	79 10                	jns    801a2b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	56                   	push   %esi
  801a1f:	e8 18 02 00 00       	call   801c3c <nsipc_close>
		return r;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	89 d8                	mov    %ebx,%eax
  801a29:	eb 24                	jmp    801a4f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a34:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a39:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801a40:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	52                   	push   %edx
  801a47:	e8 ae f6 ff ff       	call   8010fa <fd2num>
  801a4c:	83 c4 10             	add    $0x10,%esp
}
  801a4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	e8 50 ff ff ff       	call   8019b4 <fd2sockid>
		return r;
  801a64:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 1f                	js     801a89 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	ff 75 10             	pushl  0x10(%ebp)
  801a70:	ff 75 0c             	pushl  0xc(%ebp)
  801a73:	50                   	push   %eax
  801a74:	e8 1c 01 00 00       	call   801b95 <nsipc_accept>
  801a79:	83 c4 10             	add    $0x10,%esp
		return r;
  801a7c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 07                	js     801a89 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a82:	e8 5d ff ff ff       	call   8019e4 <alloc_sockfd>
  801a87:	89 c1                	mov    %eax,%ecx
}
  801a89:	89 c8                	mov    %ecx,%eax
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	e8 19 ff ff ff       	call   8019b4 <fd2sockid>
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	85 d2                	test   %edx,%edx
  801a9f:	78 12                	js     801ab3 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	ff 75 10             	pushl  0x10(%ebp)
  801aa7:	ff 75 0c             	pushl  0xc(%ebp)
  801aaa:	52                   	push   %edx
  801aab:	e8 35 01 00 00       	call   801be5 <nsipc_bind>
  801ab0:	83 c4 10             	add    $0x10,%esp
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <shutdown>:

int
shutdown(int s, int how)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	e8 f1 fe ff ff       	call   8019b4 <fd2sockid>
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	85 d2                	test   %edx,%edx
  801ac7:	78 0f                	js     801ad8 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	ff 75 0c             	pushl  0xc(%ebp)
  801acf:	52                   	push   %edx
  801ad0:	e8 45 01 00 00       	call   801c1a <nsipc_shutdown>
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	e8 cc fe ff ff       	call   8019b4 <fd2sockid>
  801ae8:	89 c2                	mov    %eax,%edx
  801aea:	85 d2                	test   %edx,%edx
  801aec:	78 12                	js     801b00 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801aee:	83 ec 04             	sub    $0x4,%esp
  801af1:	ff 75 10             	pushl  0x10(%ebp)
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	52                   	push   %edx
  801af8:	e8 59 01 00 00       	call   801c56 <nsipc_connect>
  801afd:	83 c4 10             	add    $0x10,%esp
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <listen>:

int
listen(int s, int backlog)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b08:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0b:	e8 a4 fe ff ff       	call   8019b4 <fd2sockid>
  801b10:	89 c2                	mov    %eax,%edx
  801b12:	85 d2                	test   %edx,%edx
  801b14:	78 0f                	js     801b25 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	52                   	push   %edx
  801b1d:	e8 69 01 00 00       	call   801c8b <nsipc_listen>
  801b22:	83 c4 10             	add    $0x10,%esp
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b2d:	ff 75 10             	pushl  0x10(%ebp)
  801b30:	ff 75 0c             	pushl  0xc(%ebp)
  801b33:	ff 75 08             	pushl  0x8(%ebp)
  801b36:	e8 3c 02 00 00       	call   801d77 <nsipc_socket>
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 d2                	test   %edx,%edx
  801b42:	78 05                	js     801b49 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801b44:	e8 9b fe ff ff       	call   8019e4 <alloc_sockfd>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 04             	sub    $0x4,%esp
  801b52:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b54:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b5b:	75 12                	jne    801b6f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	6a 02                	push   $0x2
  801b62:	e8 ac 08 00 00       	call   802413 <ipc_find_env>
  801b67:	a3 04 40 80 00       	mov    %eax,0x804004
  801b6c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b6f:	6a 07                	push   $0x7
  801b71:	68 00 60 80 00       	push   $0x806000
  801b76:	53                   	push   %ebx
  801b77:	ff 35 04 40 80 00    	pushl  0x804004
  801b7d:	e8 3d 08 00 00       	call   8023bf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b82:	83 c4 0c             	add    $0xc,%esp
  801b85:	6a 00                	push   $0x0
  801b87:	6a 00                	push   $0x0
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 c6 07 00 00       	call   802356 <ipc_recv>
}
  801b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ba5:	8b 06                	mov    (%esi),%eax
  801ba7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bac:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb1:	e8 95 ff ff ff       	call   801b4b <nsipc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 20                	js     801bdc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	ff 35 10 60 80 00    	pushl  0x806010
  801bc5:	68 00 60 80 00       	push   $0x806000
  801bca:	ff 75 0c             	pushl  0xc(%ebp)
  801bcd:	e8 1b ed ff ff       	call   8008ed <memmove>
		*addrlen = ret->ret_addrlen;
  801bd2:	a1 10 60 80 00       	mov    0x806010,%eax
  801bd7:	89 06                	mov    %eax,(%esi)
  801bd9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bf7:	53                   	push   %ebx
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	68 04 60 80 00       	push   $0x806004
  801c00:	e8 e8 ec ff ff       	call   8008ed <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c05:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c0b:	b8 02 00 00 00       	mov    $0x2,%eax
  801c10:	e8 36 ff ff ff       	call   801b4b <nsipc>
}
  801c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c30:	b8 03 00 00 00       	mov    $0x3,%eax
  801c35:	e8 11 ff ff ff       	call   801b4b <nsipc>
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <nsipc_close>:

int
nsipc_close(int s)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c4a:	b8 04 00 00 00       	mov    $0x4,%eax
  801c4f:	e8 f7 fe ff ff       	call   801b4b <nsipc>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	53                   	push   %ebx
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c68:	53                   	push   %ebx
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	68 04 60 80 00       	push   $0x806004
  801c71:	e8 77 ec ff ff       	call   8008ed <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c76:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c7c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c81:	e8 c5 fe ff ff       	call   801b4b <nsipc>
}
  801c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  801ca6:	e8 a0 fe ff ff       	call   801b4b <nsipc>
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cbd:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cc3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ccb:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd0:	e8 76 fe ff ff       	call   801b4b <nsipc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 35                	js     801d10 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cdb:	39 f0                	cmp    %esi,%eax
  801cdd:	7f 07                	jg     801ce6 <nsipc_recv+0x39>
  801cdf:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ce4:	7e 16                	jle    801cfc <nsipc_recv+0x4f>
  801ce6:	68 d7 2c 80 00       	push   $0x802cd7
  801ceb:	68 9f 2c 80 00       	push   $0x802c9f
  801cf0:	6a 62                	push   $0x62
  801cf2:	68 ec 2c 80 00       	push   $0x802cec
  801cf7:	e8 81 05 00 00       	call   80227d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cfc:	83 ec 04             	sub    $0x4,%esp
  801cff:	50                   	push   %eax
  801d00:	68 00 60 80 00       	push   $0x806000
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	e8 e0 eb ff ff       	call   8008ed <memmove>
  801d0d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    

00801d19 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 04             	sub    $0x4,%esp
  801d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d2b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d31:	7e 16                	jle    801d49 <nsipc_send+0x30>
  801d33:	68 f8 2c 80 00       	push   $0x802cf8
  801d38:	68 9f 2c 80 00       	push   $0x802c9f
  801d3d:	6a 6d                	push   $0x6d
  801d3f:	68 ec 2c 80 00       	push   $0x802cec
  801d44:	e8 34 05 00 00       	call   80227d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	53                   	push   %ebx
  801d4d:	ff 75 0c             	pushl  0xc(%ebp)
  801d50:	68 0c 60 80 00       	push   $0x80600c
  801d55:	e8 93 eb ff ff       	call   8008ed <memmove>
	nsipcbuf.send.req_size = size;
  801d5a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d60:	8b 45 14             	mov    0x14(%ebp),%eax
  801d63:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d68:	b8 08 00 00 00       	mov    $0x8,%eax
  801d6d:	e8 d9 fd ff ff       	call   801b4b <nsipc>
}
  801d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d88:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d90:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d95:	b8 09 00 00 00       	mov    $0x9,%eax
  801d9a:	e8 ac fd ff ff       	call   801b4b <nsipc>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	56                   	push   %esi
  801da5:	53                   	push   %ebx
  801da6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801da9:	83 ec 0c             	sub    $0xc,%esp
  801dac:	ff 75 08             	pushl  0x8(%ebp)
  801daf:	e8 56 f3 ff ff       	call   80110a <fd2data>
  801db4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801db6:	83 c4 08             	add    $0x8,%esp
  801db9:	68 04 2d 80 00       	push   $0x802d04
  801dbe:	53                   	push   %ebx
  801dbf:	e8 97 e9 ff ff       	call   80075b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dc4:	8b 56 04             	mov    0x4(%esi),%edx
  801dc7:	89 d0                	mov    %edx,%eax
  801dc9:	2b 06                	sub    (%esi),%eax
  801dcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dd8:	00 00 00 
	stat->st_dev = &devpipe;
  801ddb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801de2:	30 80 00 
	return 0;
}
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	53                   	push   %ebx
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dfb:	53                   	push   %ebx
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 e6 ed ff ff       	call   800be9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e03:	89 1c 24             	mov    %ebx,(%esp)
  801e06:	e8 ff f2 ff ff       	call   80110a <fd2data>
  801e0b:	83 c4 08             	add    $0x8,%esp
  801e0e:	50                   	push   %eax
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 d3 ed ff ff       	call   800be9 <sys_page_unmap>
}
  801e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	57                   	push   %edi
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	83 ec 1c             	sub    $0x1c,%esp
  801e24:	89 c6                	mov    %eax,%esi
  801e26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e29:	a1 08 40 80 00       	mov    0x804008,%eax
  801e2e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	56                   	push   %esi
  801e35:	e8 11 06 00 00       	call   80244b <pageref>
  801e3a:	89 c7                	mov    %eax,%edi
  801e3c:	83 c4 04             	add    $0x4,%esp
  801e3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e42:	e8 04 06 00 00       	call   80244b <pageref>
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	39 c7                	cmp    %eax,%edi
  801e4c:	0f 94 c2             	sete   %dl
  801e4f:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e52:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e58:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e5b:	39 fb                	cmp    %edi,%ebx
  801e5d:	74 19                	je     801e78 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801e5f:	84 d2                	test   %dl,%dl
  801e61:	74 c6                	je     801e29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e63:	8b 51 58             	mov    0x58(%ecx),%edx
  801e66:	50                   	push   %eax
  801e67:	52                   	push   %edx
  801e68:	53                   	push   %ebx
  801e69:	68 0b 2d 80 00       	push   $0x802d0b
  801e6e:	e8 61 e3 ff ff       	call   8001d4 <cprintf>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	eb b1                	jmp    801e29 <_pipeisclosed+0xe>
	}
}
  801e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5f                   	pop    %edi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 28             	sub    $0x28,%esp
  801e89:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e8c:	56                   	push   %esi
  801e8d:	e8 78 f2 ff ff       	call   80110a <fd2data>
  801e92:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	bf 00 00 00 00       	mov    $0x0,%edi
  801e9c:	eb 4b                	jmp    801ee9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e9e:	89 da                	mov    %ebx,%edx
  801ea0:	89 f0                	mov    %esi,%eax
  801ea2:	e8 74 ff ff ff       	call   801e1b <_pipeisclosed>
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	75 48                	jne    801ef3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eab:	e8 95 ec ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801eb3:	8b 0b                	mov    (%ebx),%ecx
  801eb5:	8d 51 20             	lea    0x20(%ecx),%edx
  801eb8:	39 d0                	cmp    %edx,%eax
  801eba:	73 e2                	jae    801e9e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ec3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ec6:	89 c2                	mov    %eax,%edx
  801ec8:	c1 fa 1f             	sar    $0x1f,%edx
  801ecb:	89 d1                	mov    %edx,%ecx
  801ecd:	c1 e9 1b             	shr    $0x1b,%ecx
  801ed0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ed3:	83 e2 1f             	and    $0x1f,%edx
  801ed6:	29 ca                	sub    %ecx,%edx
  801ed8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801edc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ee0:	83 c0 01             	add    $0x1,%eax
  801ee3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee6:	83 c7 01             	add    $0x1,%edi
  801ee9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eec:	75 c2                	jne    801eb0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eee:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef1:	eb 05                	jmp    801ef8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ef3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5f                   	pop    %edi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 18             	sub    $0x18,%esp
  801f09:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f0c:	57                   	push   %edi
  801f0d:	e8 f8 f1 ff ff       	call   80110a <fd2data>
  801f12:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1c:	eb 3d                	jmp    801f5b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f1e:	85 db                	test   %ebx,%ebx
  801f20:	74 04                	je     801f26 <devpipe_read+0x26>
				return i;
  801f22:	89 d8                	mov    %ebx,%eax
  801f24:	eb 44                	jmp    801f6a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f26:	89 f2                	mov    %esi,%edx
  801f28:	89 f8                	mov    %edi,%eax
  801f2a:	e8 ec fe ff ff       	call   801e1b <_pipeisclosed>
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	75 32                	jne    801f65 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f33:	e8 0d ec ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f38:	8b 06                	mov    (%esi),%eax
  801f3a:	3b 46 04             	cmp    0x4(%esi),%eax
  801f3d:	74 df                	je     801f1e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f3f:	99                   	cltd   
  801f40:	c1 ea 1b             	shr    $0x1b,%edx
  801f43:	01 d0                	add    %edx,%eax
  801f45:	83 e0 1f             	and    $0x1f,%eax
  801f48:	29 d0                	sub    %edx,%eax
  801f4a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f52:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f55:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f58:	83 c3 01             	add    $0x1,%ebx
  801f5b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f5e:	75 d8                	jne    801f38 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f60:	8b 45 10             	mov    0x10(%ebp),%eax
  801f63:	eb 05                	jmp    801f6a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	56                   	push   %esi
  801f76:	53                   	push   %ebx
  801f77:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7d:	50                   	push   %eax
  801f7e:	e8 9e f1 ff ff       	call   801121 <fd_alloc>
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	0f 88 2c 01 00 00    	js     8020bc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	68 07 04 00 00       	push   $0x407
  801f98:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 c2 eb ff ff       	call   800b64 <sys_page_alloc>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	0f 88 0d 01 00 00    	js     8020bc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	e8 66 f1 ff ff       	call   801121 <fd_alloc>
  801fbb:	89 c3                	mov    %eax,%ebx
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	0f 88 e2 00 00 00    	js     8020aa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc8:	83 ec 04             	sub    $0x4,%esp
  801fcb:	68 07 04 00 00       	push   $0x407
  801fd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fd3:	6a 00                	push   $0x0
  801fd5:	e8 8a eb ff ff       	call   800b64 <sys_page_alloc>
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	83 c4 10             	add    $0x10,%esp
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	0f 88 c3 00 00 00    	js     8020aa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	ff 75 f4             	pushl  -0xc(%ebp)
  801fed:	e8 18 f1 ff ff       	call   80110a <fd2data>
  801ff2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff4:	83 c4 0c             	add    $0xc,%esp
  801ff7:	68 07 04 00 00       	push   $0x407
  801ffc:	50                   	push   %eax
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 60 eb ff ff       	call   800b64 <sys_page_alloc>
  802004:	89 c3                	mov    %eax,%ebx
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	0f 88 89 00 00 00    	js     80209a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802011:	83 ec 0c             	sub    $0xc,%esp
  802014:	ff 75 f0             	pushl  -0x10(%ebp)
  802017:	e8 ee f0 ff ff       	call   80110a <fd2data>
  80201c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802023:	50                   	push   %eax
  802024:	6a 00                	push   $0x0
  802026:	56                   	push   %esi
  802027:	6a 00                	push   $0x0
  802029:	e8 79 eb ff ff       	call   800ba7 <sys_page_map>
  80202e:	89 c3                	mov    %eax,%ebx
  802030:	83 c4 20             	add    $0x20,%esp
  802033:	85 c0                	test   %eax,%eax
  802035:	78 55                	js     80208c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802037:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802040:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80204c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802052:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802055:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802057:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802061:	83 ec 0c             	sub    $0xc,%esp
  802064:	ff 75 f4             	pushl  -0xc(%ebp)
  802067:	e8 8e f0 ff ff       	call   8010fa <fd2num>
  80206c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80206f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802071:	83 c4 04             	add    $0x4,%esp
  802074:	ff 75 f0             	pushl  -0x10(%ebp)
  802077:	e8 7e f0 ff ff       	call   8010fa <fd2num>
  80207c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80207f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	ba 00 00 00 00       	mov    $0x0,%edx
  80208a:	eb 30                	jmp    8020bc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80208c:	83 ec 08             	sub    $0x8,%esp
  80208f:	56                   	push   %esi
  802090:	6a 00                	push   $0x0
  802092:	e8 52 eb ff ff       	call   800be9 <sys_page_unmap>
  802097:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80209a:	83 ec 08             	sub    $0x8,%esp
  80209d:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a0:	6a 00                	push   $0x0
  8020a2:	e8 42 eb ff ff       	call   800be9 <sys_page_unmap>
  8020a7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020aa:	83 ec 08             	sub    $0x8,%esp
  8020ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b0:	6a 00                	push   $0x0
  8020b2:	e8 32 eb ff ff       	call   800be9 <sys_page_unmap>
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020bc:	89 d0                	mov    %edx,%eax
  8020be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c1:	5b                   	pop    %ebx
  8020c2:	5e                   	pop    %esi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ce:	50                   	push   %eax
  8020cf:	ff 75 08             	pushl  0x8(%ebp)
  8020d2:	e8 99 f0 ff ff       	call   801170 <fd_lookup>
  8020d7:	89 c2                	mov    %eax,%edx
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	85 d2                	test   %edx,%edx
  8020de:	78 18                	js     8020f8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020e0:	83 ec 0c             	sub    $0xc,%esp
  8020e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e6:	e8 1f f0 ff ff       	call   80110a <fd2data>
	return _pipeisclosed(fd, p);
  8020eb:	89 c2                	mov    %eax,%edx
  8020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f0:	e8 26 fd ff ff       	call   801e1b <_pipeisclosed>
  8020f5:	83 c4 10             	add    $0x10,%esp
}
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80210a:	68 23 2d 80 00       	push   $0x802d23
  80210f:	ff 75 0c             	pushl  0xc(%ebp)
  802112:	e8 44 e6 ff ff       	call   80075b <strcpy>
	return 0;
}
  802117:	b8 00 00 00 00       	mov    $0x0,%eax
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80212a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802135:	eb 2d                	jmp    802164 <devcons_write+0x46>
		m = n - tot;
  802137:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80213a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80213c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80213f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802144:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802147:	83 ec 04             	sub    $0x4,%esp
  80214a:	53                   	push   %ebx
  80214b:	03 45 0c             	add    0xc(%ebp),%eax
  80214e:	50                   	push   %eax
  80214f:	57                   	push   %edi
  802150:	e8 98 e7 ff ff       	call   8008ed <memmove>
		sys_cputs(buf, m);
  802155:	83 c4 08             	add    $0x8,%esp
  802158:	53                   	push   %ebx
  802159:	57                   	push   %edi
  80215a:	e8 49 e9 ff ff       	call   800aa8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215f:	01 de                	add    %ebx,%esi
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	89 f0                	mov    %esi,%eax
  802166:	3b 75 10             	cmp    0x10(%ebp),%esi
  802169:	72 cc                	jb     802137 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80216b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802179:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80217e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802182:	75 07                	jne    80218b <devcons_read+0x18>
  802184:	eb 28                	jmp    8021ae <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802186:	e8 ba e9 ff ff       	call   800b45 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80218b:	e8 36 e9 ff ff       	call   800ac6 <sys_cgetc>
  802190:	85 c0                	test   %eax,%eax
  802192:	74 f2                	je     802186 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802194:	85 c0                	test   %eax,%eax
  802196:	78 16                	js     8021ae <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802198:	83 f8 04             	cmp    $0x4,%eax
  80219b:	74 0c                	je     8021a9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80219d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021a0:	88 02                	mov    %al,(%edx)
	return 1;
  8021a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a7:	eb 05                	jmp    8021ae <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021ae:	c9                   	leave  
  8021af:	c3                   	ret    

008021b0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021bc:	6a 01                	push   $0x1
  8021be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c1:	50                   	push   %eax
  8021c2:	e8 e1 e8 ff ff       	call   800aa8 <sys_cputs>
  8021c7:	83 c4 10             	add    $0x10,%esp
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <getchar>:

int
getchar(void)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021d2:	6a 01                	push   $0x1
  8021d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	6a 00                	push   $0x0
  8021da:	e8 00 f2 ff ff       	call   8013df <read>
	if (r < 0)
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	78 0f                	js     8021f5 <getchar+0x29>
		return r;
	if (r < 1)
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	7e 06                	jle    8021f0 <getchar+0x24>
		return -E_EOF;
	return c;
  8021ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021ee:	eb 05                	jmp    8021f5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021f0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021f5:	c9                   	leave  
  8021f6:	c3                   	ret    

008021f7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	ff 75 08             	pushl  0x8(%ebp)
  802204:	e8 67 ef ff ff       	call   801170 <fd_lookup>
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 11                	js     802221 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802210:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802213:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802219:	39 10                	cmp    %edx,(%eax)
  80221b:	0f 94 c0             	sete   %al
  80221e:	0f b6 c0             	movzbl %al,%eax
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <opencons>:

int
opencons(void)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222c:	50                   	push   %eax
  80222d:	e8 ef ee ff ff       	call   801121 <fd_alloc>
  802232:	83 c4 10             	add    $0x10,%esp
		return r;
  802235:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802237:	85 c0                	test   %eax,%eax
  802239:	78 3e                	js     802279 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80223b:	83 ec 04             	sub    $0x4,%esp
  80223e:	68 07 04 00 00       	push   $0x407
  802243:	ff 75 f4             	pushl  -0xc(%ebp)
  802246:	6a 00                	push   $0x0
  802248:	e8 17 e9 ff ff       	call   800b64 <sys_page_alloc>
  80224d:	83 c4 10             	add    $0x10,%esp
		return r;
  802250:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802252:	85 c0                	test   %eax,%eax
  802254:	78 23                	js     802279 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802256:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80225c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802264:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80226b:	83 ec 0c             	sub    $0xc,%esp
  80226e:	50                   	push   %eax
  80226f:	e8 86 ee ff ff       	call   8010fa <fd2num>
  802274:	89 c2                	mov    %eax,%edx
  802276:	83 c4 10             	add    $0x10,%esp
}
  802279:	89 d0                	mov    %edx,%eax
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    

0080227d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	56                   	push   %esi
  802281:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802282:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802285:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80228b:	e8 96 e8 ff ff       	call   800b26 <sys_getenvid>
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	ff 75 0c             	pushl  0xc(%ebp)
  802296:	ff 75 08             	pushl  0x8(%ebp)
  802299:	56                   	push   %esi
  80229a:	50                   	push   %eax
  80229b:	68 30 2d 80 00       	push   $0x802d30
  8022a0:	e8 2f df ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022a5:	83 c4 18             	add    $0x18,%esp
  8022a8:	53                   	push   %ebx
  8022a9:	ff 75 10             	pushl  0x10(%ebp)
  8022ac:	e8 d2 de ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  8022b1:	c7 04 24 4f 27 80 00 	movl   $0x80274f,(%esp)
  8022b8:	e8 17 df ff ff       	call   8001d4 <cprintf>
  8022bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022c0:	cc                   	int3   
  8022c1:	eb fd                	jmp    8022c0 <_panic+0x43>

008022c3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022c9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022d0:	75 2c                	jne    8022fe <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8022d2:	83 ec 04             	sub    $0x4,%esp
  8022d5:	6a 07                	push   $0x7
  8022d7:	68 00 f0 bf ee       	push   $0xeebff000
  8022dc:	6a 00                	push   $0x0
  8022de:	e8 81 e8 ff ff       	call   800b64 <sys_page_alloc>
  8022e3:	83 c4 10             	add    $0x10,%esp
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	74 14                	je     8022fe <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8022ea:	83 ec 04             	sub    $0x4,%esp
  8022ed:	68 54 2d 80 00       	push   $0x802d54
  8022f2:	6a 21                	push   $0x21
  8022f4:	68 b8 2d 80 00       	push   $0x802db8
  8022f9:	e8 7f ff ff ff       	call   80227d <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802301:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802306:	83 ec 08             	sub    $0x8,%esp
  802309:	68 32 23 80 00       	push   $0x802332
  80230e:	6a 00                	push   $0x0
  802310:	e8 9a e9 ff ff       	call   800caf <sys_env_set_pgfault_upcall>
  802315:	83 c4 10             	add    $0x10,%esp
  802318:	85 c0                	test   %eax,%eax
  80231a:	79 14                	jns    802330 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80231c:	83 ec 04             	sub    $0x4,%esp
  80231f:	68 80 2d 80 00       	push   $0x802d80
  802324:	6a 29                	push   $0x29
  802326:	68 b8 2d 80 00       	push   $0x802db8
  80232b:	e8 4d ff ff ff       	call   80227d <_panic>
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802332:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802333:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802338:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80233a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80233d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802342:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802346:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80234a:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80234c:	83 c4 08             	add    $0x8,%esp
        popal
  80234f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802350:	83 c4 04             	add    $0x4,%esp
        popfl
  802353:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802354:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802355:	c3                   	ret    

00802356 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
  80235b:	8b 75 08             	mov    0x8(%ebp),%esi
  80235e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802361:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802364:	85 c0                	test   %eax,%eax
  802366:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80236b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80236e:	83 ec 0c             	sub    $0xc,%esp
  802371:	50                   	push   %eax
  802372:	e8 9d e9 ff ff       	call   800d14 <sys_ipc_recv>
  802377:	83 c4 10             	add    $0x10,%esp
  80237a:	85 c0                	test   %eax,%eax
  80237c:	79 16                	jns    802394 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80237e:	85 f6                	test   %esi,%esi
  802380:	74 06                	je     802388 <ipc_recv+0x32>
  802382:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802388:	85 db                	test   %ebx,%ebx
  80238a:	74 2c                	je     8023b8 <ipc_recv+0x62>
  80238c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802392:	eb 24                	jmp    8023b8 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802394:	85 f6                	test   %esi,%esi
  802396:	74 0a                	je     8023a2 <ipc_recv+0x4c>
  802398:	a1 08 40 80 00       	mov    0x804008,%eax
  80239d:	8b 40 74             	mov    0x74(%eax),%eax
  8023a0:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8023a2:	85 db                	test   %ebx,%ebx
  8023a4:	74 0a                	je     8023b0 <ipc_recv+0x5a>
  8023a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8023ab:	8b 40 78             	mov    0x78(%eax),%eax
  8023ae:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8023b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8023b5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023bb:	5b                   	pop    %ebx
  8023bc:	5e                   	pop    %esi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    

008023bf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	57                   	push   %edi
  8023c3:	56                   	push   %esi
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 0c             	sub    $0xc,%esp
  8023c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8023d1:	85 db                	test   %ebx,%ebx
  8023d3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023d8:	0f 44 d8             	cmove  %eax,%ebx
  8023db:	eb 1c                	jmp    8023f9 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8023dd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023e0:	74 12                	je     8023f4 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8023e2:	50                   	push   %eax
  8023e3:	68 c6 2d 80 00       	push   $0x802dc6
  8023e8:	6a 39                	push   $0x39
  8023ea:	68 e1 2d 80 00       	push   $0x802de1
  8023ef:	e8 89 fe ff ff       	call   80227d <_panic>
                 sys_yield();
  8023f4:	e8 4c e7 ff ff       	call   800b45 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8023f9:	ff 75 14             	pushl  0x14(%ebp)
  8023fc:	53                   	push   %ebx
  8023fd:	56                   	push   %esi
  8023fe:	57                   	push   %edi
  8023ff:	e8 ed e8 ff ff       	call   800cf1 <sys_ipc_try_send>
  802404:	83 c4 10             	add    $0x10,%esp
  802407:	85 c0                	test   %eax,%eax
  802409:	78 d2                	js     8023dd <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80240b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240e:	5b                   	pop    %ebx
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    

00802413 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802413:	55                   	push   %ebp
  802414:	89 e5                	mov    %esp,%ebp
  802416:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802419:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80241e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802421:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802427:	8b 52 50             	mov    0x50(%edx),%edx
  80242a:	39 ca                	cmp    %ecx,%edx
  80242c:	75 0d                	jne    80243b <ipc_find_env+0x28>
			return envs[i].env_id;
  80242e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802431:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802436:	8b 40 08             	mov    0x8(%eax),%eax
  802439:	eb 0e                	jmp    802449 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80243b:	83 c0 01             	add    $0x1,%eax
  80243e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802443:	75 d9                	jne    80241e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802445:	66 b8 00 00          	mov    $0x0,%ax
}
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802451:	89 d0                	mov    %edx,%eax
  802453:	c1 e8 16             	shr    $0x16,%eax
  802456:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80245d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802462:	f6 c1 01             	test   $0x1,%cl
  802465:	74 1d                	je     802484 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802467:	c1 ea 0c             	shr    $0xc,%edx
  80246a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802471:	f6 c2 01             	test   $0x1,%dl
  802474:	74 0e                	je     802484 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802476:	c1 ea 0c             	shr    $0xc,%edx
  802479:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802480:	ef 
  802481:	0f b7 c0             	movzwl %ax,%eax
}
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	83 ec 10             	sub    $0x10,%esp
  802496:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80249a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80249e:	8b 74 24 24          	mov    0x24(%esp),%esi
  8024a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024a6:	85 d2                	test   %edx,%edx
  8024a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024ac:	89 34 24             	mov    %esi,(%esp)
  8024af:	89 c8                	mov    %ecx,%eax
  8024b1:	75 35                	jne    8024e8 <__udivdi3+0x58>
  8024b3:	39 f1                	cmp    %esi,%ecx
  8024b5:	0f 87 bd 00 00 00    	ja     802578 <__udivdi3+0xe8>
  8024bb:	85 c9                	test   %ecx,%ecx
  8024bd:	89 cd                	mov    %ecx,%ebp
  8024bf:	75 0b                	jne    8024cc <__udivdi3+0x3c>
  8024c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c6:	31 d2                	xor    %edx,%edx
  8024c8:	f7 f1                	div    %ecx
  8024ca:	89 c5                	mov    %eax,%ebp
  8024cc:	89 f0                	mov    %esi,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  8024d0:	f7 f5                	div    %ebp
  8024d2:	89 c6                	mov    %eax,%esi
  8024d4:	89 f8                	mov    %edi,%eax
  8024d6:	f7 f5                	div    %ebp
  8024d8:	89 f2                	mov    %esi,%edx
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	5e                   	pop    %esi
  8024de:	5f                   	pop    %edi
  8024df:	5d                   	pop    %ebp
  8024e0:	c3                   	ret    
  8024e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	3b 14 24             	cmp    (%esp),%edx
  8024eb:	77 7b                	ja     802568 <__udivdi3+0xd8>
  8024ed:	0f bd f2             	bsr    %edx,%esi
  8024f0:	83 f6 1f             	xor    $0x1f,%esi
  8024f3:	0f 84 97 00 00 00    	je     802590 <__udivdi3+0x100>
  8024f9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8024fe:	89 d7                	mov    %edx,%edi
  802500:	89 f1                	mov    %esi,%ecx
  802502:	29 f5                	sub    %esi,%ebp
  802504:	d3 e7                	shl    %cl,%edi
  802506:	89 c2                	mov    %eax,%edx
  802508:	89 e9                	mov    %ebp,%ecx
  80250a:	d3 ea                	shr    %cl,%edx
  80250c:	89 f1                	mov    %esi,%ecx
  80250e:	09 fa                	or     %edi,%edx
  802510:	8b 3c 24             	mov    (%esp),%edi
  802513:	d3 e0                	shl    %cl,%eax
  802515:	89 54 24 08          	mov    %edx,0x8(%esp)
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802523:	89 fa                	mov    %edi,%edx
  802525:	d3 ea                	shr    %cl,%edx
  802527:	89 f1                	mov    %esi,%ecx
  802529:	d3 e7                	shl    %cl,%edi
  80252b:	89 e9                	mov    %ebp,%ecx
  80252d:	d3 e8                	shr    %cl,%eax
  80252f:	09 c7                	or     %eax,%edi
  802531:	89 f8                	mov    %edi,%eax
  802533:	f7 74 24 08          	divl   0x8(%esp)
  802537:	89 d5                	mov    %edx,%ebp
  802539:	89 c7                	mov    %eax,%edi
  80253b:	f7 64 24 0c          	mull   0xc(%esp)
  80253f:	39 d5                	cmp    %edx,%ebp
  802541:	89 14 24             	mov    %edx,(%esp)
  802544:	72 11                	jb     802557 <__udivdi3+0xc7>
  802546:	8b 54 24 04          	mov    0x4(%esp),%edx
  80254a:	89 f1                	mov    %esi,%ecx
  80254c:	d3 e2                	shl    %cl,%edx
  80254e:	39 c2                	cmp    %eax,%edx
  802550:	73 5e                	jae    8025b0 <__udivdi3+0x120>
  802552:	3b 2c 24             	cmp    (%esp),%ebp
  802555:	75 59                	jne    8025b0 <__udivdi3+0x120>
  802557:	8d 47 ff             	lea    -0x1(%edi),%eax
  80255a:	31 f6                	xor    %esi,%esi
  80255c:	89 f2                	mov    %esi,%edx
  80255e:	83 c4 10             	add    $0x10,%esp
  802561:	5e                   	pop    %esi
  802562:	5f                   	pop    %edi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    
  802565:	8d 76 00             	lea    0x0(%esi),%esi
  802568:	31 f6                	xor    %esi,%esi
  80256a:	31 c0                	xor    %eax,%eax
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	83 c4 10             	add    $0x10,%esp
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    
  802575:	8d 76 00             	lea    0x0(%esi),%esi
  802578:	89 f2                	mov    %esi,%edx
  80257a:	31 f6                	xor    %esi,%esi
  80257c:	89 f8                	mov    %edi,%eax
  80257e:	f7 f1                	div    %ecx
  802580:	89 f2                	mov    %esi,%edx
  802582:	83 c4 10             	add    $0x10,%esp
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802594:	76 0b                	jbe    8025a1 <__udivdi3+0x111>
  802596:	31 c0                	xor    %eax,%eax
  802598:	3b 14 24             	cmp    (%esp),%edx
  80259b:	0f 83 37 ff ff ff    	jae    8024d8 <__udivdi3+0x48>
  8025a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025a6:	e9 2d ff ff ff       	jmp    8024d8 <__udivdi3+0x48>
  8025ab:	90                   	nop
  8025ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	89 f8                	mov    %edi,%eax
  8025b2:	31 f6                	xor    %esi,%esi
  8025b4:	e9 1f ff ff ff       	jmp    8024d8 <__udivdi3+0x48>
  8025b9:	66 90                	xchg   %ax,%ax
  8025bb:	66 90                	xchg   %ax,%ax
  8025bd:	66 90                	xchg   %ax,%ax
  8025bf:	90                   	nop

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	83 ec 20             	sub    $0x20,%esp
  8025c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8025ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d2:	89 c6                	mov    %eax,%esi
  8025d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8025e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025ec:	85 c0                	test   %eax,%eax
  8025ee:	89 c2                	mov    %eax,%edx
  8025f0:	75 1e                	jne    802610 <__umoddi3+0x50>
  8025f2:	39 f7                	cmp    %esi,%edi
  8025f4:	76 52                	jbe    802648 <__umoddi3+0x88>
  8025f6:	89 c8                	mov    %ecx,%eax
  8025f8:	89 f2                	mov    %esi,%edx
  8025fa:	f7 f7                	div    %edi
  8025fc:	89 d0                	mov    %edx,%eax
  8025fe:	31 d2                	xor    %edx,%edx
  802600:	83 c4 20             	add    $0x20,%esp
  802603:	5e                   	pop    %esi
  802604:	5f                   	pop    %edi
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    
  802607:	89 f6                	mov    %esi,%esi
  802609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802610:	39 f0                	cmp    %esi,%eax
  802612:	77 5c                	ja     802670 <__umoddi3+0xb0>
  802614:	0f bd e8             	bsr    %eax,%ebp
  802617:	83 f5 1f             	xor    $0x1f,%ebp
  80261a:	75 64                	jne    802680 <__umoddi3+0xc0>
  80261c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802620:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802624:	0f 86 f6 00 00 00    	jbe    802720 <__umoddi3+0x160>
  80262a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80262e:	0f 82 ec 00 00 00    	jb     802720 <__umoddi3+0x160>
  802634:	8b 44 24 14          	mov    0x14(%esp),%eax
  802638:	8b 54 24 18          	mov    0x18(%esp),%edx
  80263c:	83 c4 20             	add    $0x20,%esp
  80263f:	5e                   	pop    %esi
  802640:	5f                   	pop    %edi
  802641:	5d                   	pop    %ebp
  802642:	c3                   	ret    
  802643:	90                   	nop
  802644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802648:	85 ff                	test   %edi,%edi
  80264a:	89 fd                	mov    %edi,%ebp
  80264c:	75 0b                	jne    802659 <__umoddi3+0x99>
  80264e:	b8 01 00 00 00       	mov    $0x1,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f7                	div    %edi
  802657:	89 c5                	mov    %eax,%ebp
  802659:	8b 44 24 10          	mov    0x10(%esp),%eax
  80265d:	31 d2                	xor    %edx,%edx
  80265f:	f7 f5                	div    %ebp
  802661:	89 c8                	mov    %ecx,%eax
  802663:	f7 f5                	div    %ebp
  802665:	eb 95                	jmp    8025fc <__umoddi3+0x3c>
  802667:	89 f6                	mov    %esi,%esi
  802669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	83 c4 20             	add    $0x20,%esp
  802677:	5e                   	pop    %esi
  802678:	5f                   	pop    %edi
  802679:	5d                   	pop    %ebp
  80267a:	c3                   	ret    
  80267b:	90                   	nop
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	b8 20 00 00 00       	mov    $0x20,%eax
  802685:	89 e9                	mov    %ebp,%ecx
  802687:	29 e8                	sub    %ebp,%eax
  802689:	d3 e2                	shl    %cl,%edx
  80268b:	89 c7                	mov    %eax,%edi
  80268d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802691:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802695:	89 f9                	mov    %edi,%ecx
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 c1                	mov    %eax,%ecx
  80269b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80269f:	09 d1                	or     %edx,%ecx
  8026a1:	89 fa                	mov    %edi,%edx
  8026a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026a7:	89 e9                	mov    %ebp,%ecx
  8026a9:	d3 e0                	shl    %cl,%eax
  8026ab:	89 f9                	mov    %edi,%ecx
  8026ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026b1:	89 f0                	mov    %esi,%eax
  8026b3:	d3 e8                	shr    %cl,%eax
  8026b5:	89 e9                	mov    %ebp,%ecx
  8026b7:	89 c7                	mov    %eax,%edi
  8026b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026bd:	d3 e6                	shl    %cl,%esi
  8026bf:	89 d1                	mov    %edx,%ecx
  8026c1:	89 fa                	mov    %edi,%edx
  8026c3:	d3 e8                	shr    %cl,%eax
  8026c5:	89 e9                	mov    %ebp,%ecx
  8026c7:	09 f0                	or     %esi,%eax
  8026c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8026cd:	f7 74 24 10          	divl   0x10(%esp)
  8026d1:	d3 e6                	shl    %cl,%esi
  8026d3:	89 d1                	mov    %edx,%ecx
  8026d5:	f7 64 24 0c          	mull   0xc(%esp)
  8026d9:	39 d1                	cmp    %edx,%ecx
  8026db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8026df:	89 d7                	mov    %edx,%edi
  8026e1:	89 c6                	mov    %eax,%esi
  8026e3:	72 0a                	jb     8026ef <__umoddi3+0x12f>
  8026e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8026e9:	73 10                	jae    8026fb <__umoddi3+0x13b>
  8026eb:	39 d1                	cmp    %edx,%ecx
  8026ed:	75 0c                	jne    8026fb <__umoddi3+0x13b>
  8026ef:	89 d7                	mov    %edx,%edi
  8026f1:	89 c6                	mov    %eax,%esi
  8026f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8026f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8026fb:	89 ca                	mov    %ecx,%edx
  8026fd:	89 e9                	mov    %ebp,%ecx
  8026ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802703:	29 f0                	sub    %esi,%eax
  802705:	19 fa                	sbb    %edi,%edx
  802707:	d3 e8                	shr    %cl,%eax
  802709:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80270e:	89 d7                	mov    %edx,%edi
  802710:	d3 e7                	shl    %cl,%edi
  802712:	89 e9                	mov    %ebp,%ecx
  802714:	09 f8                	or     %edi,%eax
  802716:	d3 ea                	shr    %cl,%edx
  802718:	83 c4 20             	add    $0x20,%esp
  80271b:	5e                   	pop    %esi
  80271c:	5f                   	pop    %edi
  80271d:	5d                   	pop    %ebp
  80271e:	c3                   	ret    
  80271f:	90                   	nop
  802720:	8b 74 24 10          	mov    0x10(%esp),%esi
  802724:	29 f9                	sub    %edi,%ecx
  802726:	19 c6                	sbb    %eax,%esi
  802728:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80272c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802730:	e9 ff fe ff ff       	jmp    802634 <__umoddi3+0x74>
