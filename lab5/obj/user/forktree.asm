
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
  800047:	68 40 22 80 00       	push   $0x802240
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
  800095:	68 51 22 80 00       	push   $0x802251
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 63 06 00 00       	call   800708 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 8a 0d 00 00       	call   800e37 <fork>
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
  8000d2:	68 50 22 80 00       	push   $0x802250
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
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80012d:	e8 f4 10 00 00       	call   801226 <close_all>
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
  800237:	e8 34 1d 00 00       	call   801f70 <__udivdi3>
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
  800275:	e8 26 1e 00 00       	call   8020a0 <__umoddi3>
  80027a:	83 c4 14             	add    $0x14,%esp
  80027d:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
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
  800379:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  80043d:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800444:	85 d2                	test   %edx,%edx
  800446:	75 18                	jne    800460 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800448:	50                   	push   %eax
  800449:	68 78 22 80 00       	push   $0x802278
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
  800461:	68 ad 27 80 00       	push   $0x8027ad
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
  80048e:	ba 71 22 80 00       	mov    $0x802271,%edx
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
  800b0d:	68 9f 25 80 00       	push   $0x80259f
  800b12:	6a 23                	push   $0x23
  800b14:	68 bc 25 80 00       	push   $0x8025bc
  800b19:	e8 48 12 00 00       	call   801d66 <_panic>

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
  800b8e:	68 9f 25 80 00       	push   $0x80259f
  800b93:	6a 23                	push   $0x23
  800b95:	68 bc 25 80 00       	push   $0x8025bc
  800b9a:	e8 c7 11 00 00       	call   801d66 <_panic>

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
  800bd0:	68 9f 25 80 00       	push   $0x80259f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 bc 25 80 00       	push   $0x8025bc
  800bdc:	e8 85 11 00 00       	call   801d66 <_panic>

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
  800c12:	68 9f 25 80 00       	push   $0x80259f
  800c17:	6a 23                	push   $0x23
  800c19:	68 bc 25 80 00       	push   $0x8025bc
  800c1e:	e8 43 11 00 00       	call   801d66 <_panic>

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
  800c54:	68 9f 25 80 00       	push   $0x80259f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 bc 25 80 00       	push   $0x8025bc
  800c60:	e8 01 11 00 00       	call   801d66 <_panic>
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
  800c96:	68 9f 25 80 00       	push   $0x80259f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 bc 25 80 00       	push   $0x8025bc
  800ca2:	e8 bf 10 00 00       	call   801d66 <_panic>

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
  800cd8:	68 9f 25 80 00       	push   $0x80259f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 bc 25 80 00       	push   $0x8025bc
  800ce4:	e8 7d 10 00 00       	call   801d66 <_panic>

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
  800d3c:	68 9f 25 80 00       	push   $0x80259f
  800d41:	6a 23                	push   $0x23
  800d43:	68 bc 25 80 00       	push   $0x8025bc
  800d48:	e8 19 10 00 00       	call   801d66 <_panic>

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

00800d55 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	53                   	push   %ebx
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d5f:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d61:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d65:	74 2e                	je     800d95 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	c1 ea 16             	shr    $0x16,%edx
  800d6c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d73:	f6 c2 01             	test   $0x1,%dl
  800d76:	74 1d                	je     800d95 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d78:	89 c2                	mov    %eax,%edx
  800d7a:	c1 ea 0c             	shr    $0xc,%edx
  800d7d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d84:	f6 c1 01             	test   $0x1,%cl
  800d87:	74 0c                	je     800d95 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d90:	f6 c6 08             	test   $0x8,%dh
  800d93:	75 14                	jne    800da9 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 cc 25 80 00       	push   $0x8025cc
  800d9d:	6a 21                	push   $0x21
  800d9f:	68 5f 26 80 00       	push   $0x80265f
  800da4:	e8 bd 0f 00 00       	call   801d66 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800da9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dae:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	6a 07                	push   $0x7
  800db5:	68 00 f0 7f 00       	push   $0x7ff000
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 a3 fd ff ff       	call   800b64 <sys_page_alloc>
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	79 14                	jns    800ddc <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	68 6a 26 80 00       	push   $0x80266a
  800dd0:	6a 2b                	push   $0x2b
  800dd2:	68 5f 26 80 00       	push   $0x80265f
  800dd7:	e8 8a 0f 00 00       	call   801d66 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	68 00 10 00 00       	push   $0x1000
  800de4:	53                   	push   %ebx
  800de5:	68 00 f0 7f 00       	push   $0x7ff000
  800dea:	e8 fe fa ff ff       	call   8008ed <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800def:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df6:	53                   	push   %ebx
  800df7:	6a 00                	push   $0x0
  800df9:	68 00 f0 7f 00       	push   $0x7ff000
  800dfe:	6a 00                	push   $0x0
  800e00:	e8 a2 fd ff ff       	call   800ba7 <sys_page_map>
  800e05:	83 c4 20             	add    $0x20,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	79 14                	jns    800e20 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	68 80 26 80 00       	push   $0x802680
  800e14:	6a 2e                	push   $0x2e
  800e16:	68 5f 26 80 00       	push   $0x80265f
  800e1b:	e8 46 0f 00 00       	call   801d66 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 ba fd ff ff       	call   800be9 <sys_page_unmap>
  800e2f:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800e32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800e40:	68 55 0d 80 00       	push   $0x800d55
  800e45:	e8 62 0f 00 00       	call   801dac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e4a:	b8 07 00 00 00       	mov    $0x7,%eax
  800e4f:	cd 30                	int    $0x30
  800e51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	79 12                	jns    800e6d <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e5b:	50                   	push   %eax
  800e5c:	68 94 26 80 00       	push   $0x802694
  800e61:	6a 6d                	push   $0x6d
  800e63:	68 5f 26 80 00       	push   $0x80265f
  800e68:	e8 f9 0e 00 00       	call   801d66 <_panic>
  800e6d:	89 c7                	mov    %eax,%edi
  800e6f:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e78:	75 21                	jne    800e9b <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e7a:	e8 a7 fc ff ff       	call   800b26 <sys_getenvid>
  800e7f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e84:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e87:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	e9 9c 01 00 00       	jmp    801037 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	c1 e8 16             	shr    $0x16,%eax
  800ea0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea7:	a8 01                	test   $0x1,%al
  800ea9:	0f 84 f3 00 00 00    	je     800fa2 <fork+0x16b>
  800eaf:	89 d8                	mov    %ebx,%eax
  800eb1:	c1 e8 0c             	shr    $0xc,%eax
  800eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebb:	f6 c2 01             	test   $0x1,%dl
  800ebe:	0f 84 de 00 00 00    	je     800fa2 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800ec4:	89 c6                	mov    %eax,%esi
  800ec6:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800ec9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed0:	f6 c6 04             	test   $0x4,%dh
  800ed3:	74 37                	je     800f0c <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800ed5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	25 07 0e 00 00       	and    $0xe07,%eax
  800ee4:	50                   	push   %eax
  800ee5:	56                   	push   %esi
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	6a 00                	push   $0x0
  800eea:	e8 b8 fc ff ff       	call   800ba7 <sys_page_map>
  800eef:	83 c4 20             	add    $0x20,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	0f 89 a8 00 00 00    	jns    800fa2 <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800efa:	50                   	push   %eax
  800efb:	68 f0 25 80 00       	push   $0x8025f0
  800f00:	6a 49                	push   $0x49
  800f02:	68 5f 26 80 00       	push   $0x80265f
  800f07:	e8 5a 0e 00 00       	call   801d66 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f0c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f13:	f6 c6 08             	test   $0x8,%dh
  800f16:	75 0b                	jne    800f23 <fork+0xec>
  800f18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1f:	a8 02                	test   $0x2,%al
  800f21:	74 57                	je     800f7a <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	68 05 08 00 00       	push   $0x805
  800f2b:	56                   	push   %esi
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	6a 00                	push   $0x0
  800f30:	e8 72 fc ff ff       	call   800ba7 <sys_page_map>
  800f35:	83 c4 20             	add    $0x20,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 12                	jns    800f4e <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 f0 25 80 00       	push   $0x8025f0
  800f42:	6a 4c                	push   $0x4c
  800f44:	68 5f 26 80 00       	push   $0x80265f
  800f49:	e8 18 0e 00 00       	call   801d66 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	68 05 08 00 00       	push   $0x805
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	56                   	push   %esi
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 46 fc ff ff       	call   800ba7 <sys_page_map>
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 3a                	jns    800fa2 <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  800f68:	50                   	push   %eax
  800f69:	68 14 26 80 00       	push   $0x802614
  800f6e:	6a 4e                	push   $0x4e
  800f70:	68 5f 26 80 00       	push   $0x80265f
  800f75:	e8 ec 0d 00 00       	call   801d66 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	6a 05                	push   $0x5
  800f7f:	56                   	push   %esi
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 1e fc ff ff       	call   800ba7 <sys_page_map>
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 12                	jns    800fa2 <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  800f90:	50                   	push   %eax
  800f91:	68 3c 26 80 00       	push   $0x80263c
  800f96:	6a 50                	push   $0x50
  800f98:	68 5f 26 80 00       	push   $0x80265f
  800f9d:	e8 c4 0d 00 00       	call   801d66 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800fa2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fae:	0f 85 e7 fe ff ff    	jne    800e9b <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	6a 07                	push   $0x7
  800fb9:	68 00 f0 bf ee       	push   $0xeebff000
  800fbe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc1:	e8 9e fb ff ff       	call   800b64 <sys_page_alloc>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 14                	jns    800fe1 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  800fcd:	83 ec 04             	sub    $0x4,%esp
  800fd0:	68 a4 26 80 00       	push   $0x8026a4
  800fd5:	6a 76                	push   $0x76
  800fd7:	68 5f 26 80 00       	push   $0x80265f
  800fdc:	e8 85 0d 00 00       	call   801d66 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	68 1b 1e 80 00       	push   $0x801e1b
  800fe9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fec:	e8 be fc ff ff       	call   800caf <sys_env_set_pgfault_upcall>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 14                	jns    80100c <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  800ff8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ffb:	68 be 26 80 00       	push   $0x8026be
  801000:	6a 79                	push   $0x79
  801002:	68 5f 26 80 00       	push   $0x80265f
  801007:	e8 5a 0d 00 00       	call   801d66 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	6a 02                	push   $0x2
  801011:	ff 75 e4             	pushl  -0x1c(%ebp)
  801014:	e8 12 fc ff ff       	call   800c2b <sys_env_set_status>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 14                	jns    801034 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801020:	ff 75 e4             	pushl  -0x1c(%ebp)
  801023:	68 db 26 80 00       	push   $0x8026db
  801028:	6a 7b                	push   $0x7b
  80102a:	68 5f 26 80 00       	push   $0x80265f
  80102f:	e8 32 0d 00 00       	call   801d66 <_panic>
        return forkid;
  801034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <sfork>:

// Challenge!
int
sfork(void)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801045:	68 f2 26 80 00       	push   $0x8026f2
  80104a:	68 83 00 00 00       	push   $0x83
  80104f:	68 5f 26 80 00       	push   $0x80265f
  801054:	e8 0d 0d 00 00       	call   801d66 <_panic>

00801059 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	05 00 00 00 30       	add    $0x30000000,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
}
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801079:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	c1 ea 16             	shr    $0x16,%edx
  801090:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	74 11                	je     8010ad <fd_alloc+0x2d>
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	c1 ea 0c             	shr    $0xc,%edx
  8010a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a8:	f6 c2 01             	test   $0x1,%dl
  8010ab:	75 09                	jne    8010b6 <fd_alloc+0x36>
			*fd_store = fd;
  8010ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010af:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b4:	eb 17                	jmp    8010cd <fd_alloc+0x4d>
  8010b6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c0:	75 c9                	jne    80108b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d5:	83 f8 1f             	cmp    $0x1f,%eax
  8010d8:	77 36                	ja     801110 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010da:	c1 e0 0c             	shl    $0xc,%eax
  8010dd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	c1 ea 16             	shr    $0x16,%edx
  8010e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ee:	f6 c2 01             	test   $0x1,%dl
  8010f1:	74 24                	je     801117 <fd_lookup+0x48>
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	c1 ea 0c             	shr    $0xc,%edx
  8010f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 1a                	je     80111e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 02                	mov    %eax,(%edx)
	return 0;
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
  80110e:	eb 13                	jmp    801123 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb 0c                	jmp    801123 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb 05                	jmp    801123 <fd_lookup+0x54>
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	ba 84 27 80 00       	mov    $0x802784,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801133:	eb 13                	jmp    801148 <dev_lookup+0x23>
  801135:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801138:	39 08                	cmp    %ecx,(%eax)
  80113a:	75 0c                	jne    801148 <dev_lookup+0x23>
			*dev = devtab[i];
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	eb 2e                	jmp    801176 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801148:	8b 02                	mov    (%edx),%eax
  80114a:	85 c0                	test   %eax,%eax
  80114c:	75 e7                	jne    801135 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114e:	a1 04 40 80 00       	mov    0x804004,%eax
  801153:	8b 40 48             	mov    0x48(%eax),%eax
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	51                   	push   %ecx
  80115a:	50                   	push   %eax
  80115b:	68 08 27 80 00       	push   $0x802708
  801160:	e8 6f f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801165:	8b 45 0c             	mov    0xc(%ebp),%eax
  801168:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 10             	sub    $0x10,%esp
  801180:	8b 75 08             	mov    0x8(%ebp),%esi
  801183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801190:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801193:	50                   	push   %eax
  801194:	e8 36 ff ff ff       	call   8010cf <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 05                	js     8011a5 <fd_close+0x2d>
	    || fd != fd2)
  8011a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a3:	74 0c                	je     8011b1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a5:	84 db                	test   %bl,%bl
  8011a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ac:	0f 44 c2             	cmove  %edx,%eax
  8011af:	eb 41                	jmp    8011f2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 36                	pushl  (%esi)
  8011ba:	e8 66 ff ff ff       	call   801125 <dev_lookup>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 1a                	js     8011e2 <fd_close+0x6a>
		if (dev->dev_close)
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 0b                	je     8011e2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	56                   	push   %esi
  8011db:	ff d0                	call   *%eax
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	56                   	push   %esi
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 fc f9 ff ff       	call   800be9 <sys_page_unmap>
	return r;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	89 d8                	mov    %ebx,%eax
}
  8011f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	ff 75 08             	pushl  0x8(%ebp)
  801206:	e8 c4 fe ff ff       	call   8010cf <fd_lookup>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 d2                	test   %edx,%edx
  801212:	78 10                	js     801224 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	6a 01                	push   $0x1
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 57 ff ff ff       	call   801178 <fd_close>
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	53                   	push   %ebx
  801236:	e8 be ff ff ff       	call   8011f9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123b:	83 c3 01             	add    $0x1,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	83 fb 20             	cmp    $0x20,%ebx
  801244:	75 ec                	jne    801232 <close_all+0xc>
		close(i);
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 2c             	sub    $0x2c,%esp
  801254:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801257:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 6c fe ff ff       	call   8010cf <fd_lookup>
  801263:	89 c2                	mov    %eax,%edx
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 d2                	test   %edx,%edx
  80126a:	0f 88 c1 00 00 00    	js     801331 <dup+0xe6>
		return r;
	close(newfdnum);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	56                   	push   %esi
  801274:	e8 80 ff ff ff       	call   8011f9 <close>

	newfd = INDEX2FD(newfdnum);
  801279:	89 f3                	mov    %esi,%ebx
  80127b:	c1 e3 0c             	shl    $0xc,%ebx
  80127e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801284:	83 c4 04             	add    $0x4,%esp
  801287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80128a:	e8 da fd ff ff       	call   801069 <fd2data>
  80128f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801291:	89 1c 24             	mov    %ebx,(%esp)
  801294:	e8 d0 fd ff ff       	call   801069 <fd2data>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	c1 e8 16             	shr    $0x16,%eax
  8012a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ab:	a8 01                	test   $0x1,%al
  8012ad:	74 37                	je     8012e6 <dup+0x9b>
  8012af:	89 f8                	mov    %edi,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 26                	je     8012e6 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	57                   	push   %edi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 ca f8 ff ff       	call   800ba7 <sys_page_map>
  8012dd:	89 c7                	mov    %eax,%edi
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 2e                	js     801314 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	c1 e8 0c             	shr    $0xc,%eax
  8012ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fd:	50                   	push   %eax
  8012fe:	53                   	push   %ebx
  8012ff:	6a 00                	push   $0x0
  801301:	52                   	push   %edx
  801302:	6a 00                	push   $0x0
  801304:	e8 9e f8 ff ff       	call   800ba7 <sys_page_map>
  801309:	89 c7                	mov    %eax,%edi
  80130b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801310:	85 ff                	test   %edi,%edi
  801312:	79 1d                	jns    801331 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	53                   	push   %ebx
  801318:	6a 00                	push   $0x0
  80131a:	e8 ca f8 ff ff       	call   800be9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	ff 75 d4             	pushl  -0x2c(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 bd f8 ff ff       	call   800be9 <sys_page_unmap>
	return r;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 f8                	mov    %edi,%eax
}
  801331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 14             	sub    $0x14,%esp
  801340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801343:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	53                   	push   %ebx
  801348:	e8 82 fd ff ff       	call   8010cf <fd_lookup>
  80134d:	83 c4 08             	add    $0x8,%esp
  801350:	89 c2                	mov    %eax,%edx
  801352:	85 c0                	test   %eax,%eax
  801354:	78 6d                	js     8013c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	ff 30                	pushl  (%eax)
  801362:	e8 be fd ff ff       	call   801125 <dev_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 4c                	js     8013ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801371:	8b 42 08             	mov    0x8(%edx),%eax
  801374:	83 e0 03             	and    $0x3,%eax
  801377:	83 f8 01             	cmp    $0x1,%eax
  80137a:	75 21                	jne    80139d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137c:	a1 04 40 80 00       	mov    0x804004,%eax
  801381:	8b 40 48             	mov    0x48(%eax),%eax
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	50                   	push   %eax
  801389:	68 49 27 80 00       	push   $0x802749
  80138e:	e8 41 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139b:	eb 26                	jmp    8013c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	8b 40 08             	mov    0x8(%eax),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 17                	je     8013be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	ff 75 10             	pushl  0x10(%ebp)
  8013ad:	ff 75 0c             	pushl  0xc(%ebp)
  8013b0:	52                   	push   %edx
  8013b1:	ff d0                	call   *%eax
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb 09                	jmp    8013c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	eb 05                	jmp    8013c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013c3:	89 d0                	mov    %edx,%eax
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013de:	eb 21                	jmp    801401 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	29 d8                	sub    %ebx,%eax
  8013e7:	50                   	push   %eax
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	03 45 0c             	add    0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	57                   	push   %edi
  8013ef:	e8 45 ff ff ff       	call   801339 <read>
		if (m < 0)
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 0c                	js     801407 <readn+0x3d>
			return m;
		if (m == 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 06                	je     801405 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ff:	01 c3                	add    %eax,%ebx
  801401:	39 f3                	cmp    %esi,%ebx
  801403:	72 db                	jb     8013e0 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801405:	89 d8                	mov    %ebx,%eax
}
  801407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
  801416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	53                   	push   %ebx
  80141e:	e8 ac fc ff ff       	call   8010cf <fd_lookup>
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	89 c2                	mov    %eax,%edx
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 68                	js     801494 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	ff 30                	pushl  (%eax)
  801438:	e8 e8 fc ff ff       	call   801125 <dev_lookup>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 47                	js     80148b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144b:	75 21                	jne    80146e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 04 40 80 00       	mov    0x804004,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	53                   	push   %ebx
  801459:	50                   	push   %eax
  80145a:	68 65 27 80 00       	push   $0x802765
  80145f:	e8 70 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146c:	eb 26                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 0c             	mov    0xc(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 17                	je     80148f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	pushl  0x10(%ebp)
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	50                   	push   %eax
  801482:	ff d2                	call   *%edx
  801484:	89 c2                	mov    %eax,%edx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 09                	jmp    801494 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	eb 05                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801494:	89 d0                	mov    %edx,%eax
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <seek>:

int
seek(int fdnum, off_t offset)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	ff 75 08             	pushl  0x8(%ebp)
  8014a8:	e8 22 fc ff ff       	call   8010cf <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 0e                	js     8014c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 14             	sub    $0x14,%esp
  8014cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	53                   	push   %ebx
  8014d3:	e8 f7 fb ff ff       	call   8010cf <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 65                	js     801546 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	ff 30                	pushl  (%eax)
  8014ed:	e8 33 fc ff ff       	call   801125 <dev_lookup>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 44                	js     80153d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801500:	75 21                	jne    801523 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801502:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801507:	8b 40 48             	mov    0x48(%eax),%eax
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	53                   	push   %ebx
  80150e:	50                   	push   %eax
  80150f:	68 28 27 80 00       	push   $0x802728
  801514:	e8 bb ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801521:	eb 23                	jmp    801546 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801523:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801526:	8b 52 18             	mov    0x18(%edx),%edx
  801529:	85 d2                	test   %edx,%edx
  80152b:	74 14                	je     801541 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	50                   	push   %eax
  801534:	ff d2                	call   *%edx
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 14             	sub    $0x14,%esp
  801554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 6c fb ff ff       	call   8010cf <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	89 c2                	mov    %eax,%edx
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 58                	js     8015c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	ff 30                	pushl  (%eax)
  801578:	e8 a8 fb ff ff       	call   801125 <dev_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 37                	js     8015bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158b:	74 32                	je     8015bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801590:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801597:	00 00 00 
	stat->st_isdir = 0;
  80159a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a1:	00 00 00 
	stat->st_dev = dev;
  8015a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b1:	ff 50 14             	call   *0x14(%eax)
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	eb 09                	jmp    8015c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	eb 05                	jmp    8015c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	e8 09 02 00 00       	call   8017e6 <open>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 db                	test   %ebx,%ebx
  8015e4:	78 1b                	js     801601 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	53                   	push   %ebx
  8015ed:	e8 5b ff ff ff       	call   80154d <fstat>
  8015f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f4:	89 1c 24             	mov    %ebx,(%esp)
  8015f7:	e8 fd fb ff ff       	call   8011f9 <close>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 f0                	mov    %esi,%eax
}
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	89 c6                	mov    %eax,%esi
  80160f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801611:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801618:	75 12                	jne    80162c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	6a 01                	push   $0x1
  80161f:	e8 d8 08 00 00       	call   801efc <ipc_find_env>
  801624:	a3 00 40 80 00       	mov    %eax,0x804000
  801629:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162c:	6a 07                	push   $0x7
  80162e:	68 00 50 80 00       	push   $0x805000
  801633:	56                   	push   %esi
  801634:	ff 35 00 40 80 00    	pushl  0x804000
  80163a:	e8 69 08 00 00       	call   801ea8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163f:	83 c4 0c             	add    $0xc,%esp
  801642:	6a 00                	push   $0x0
  801644:	53                   	push   %ebx
  801645:	6a 00                	push   $0x0
  801647:	e8 f3 07 00 00       	call   801e3f <ipc_recv>
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	b8 02 00 00 00       	mov    $0x2,%eax
  801676:	e8 8d ff ff ff       	call   801608 <fsipc>
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 40 0c             	mov    0xc(%eax),%eax
  801689:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 06 00 00 00       	mov    $0x6,%eax
  801698:	e8 6b ff ff ff       	call   801608 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016be:	e8 45 ff ff ff       	call   801608 <fsipc>
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	78 2c                	js     8016f5 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	68 00 50 80 00       	push   $0x805000
  8016d1:	53                   	push   %ebx
  8016d2:	e8 84 f0 ff ff       	call   80075b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8016dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	8b 40 0c             	mov    0xc(%eax),%eax
  80170c:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801714:	eb 3d                	jmp    801753 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801716:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80171c:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801721:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	57                   	push   %edi
  801728:	53                   	push   %ebx
  801729:	68 08 50 80 00       	push   $0x805008
  80172e:	e8 ba f1 ff ff       	call   8008ed <memmove>
                fsipcbuf.write.req_n = tmp; 
  801733:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	b8 04 00 00 00       	mov    $0x4,%eax
  801743:	e8 c0 fe ff ff       	call   801608 <fsipc>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 0d                	js     80175c <devfile_write+0x62>
		        return r;
                n -= tmp;
  80174f:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801751:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801753:	85 f6                	test   %esi,%esi
  801755:	75 bf                	jne    801716 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801757:	89 d8                	mov    %ebx,%eax
  801759:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80175c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8b 40 0c             	mov    0xc(%eax),%eax
  801772:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801777:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 03 00 00 00       	mov    $0x3,%eax
  801787:	e8 7c fe ff ff       	call   801608 <fsipc>
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 4b                	js     8017dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801792:	39 c6                	cmp    %eax,%esi
  801794:	73 16                	jae    8017ac <devfile_read+0x48>
  801796:	68 94 27 80 00       	push   $0x802794
  80179b:	68 9b 27 80 00       	push   $0x80279b
  8017a0:	6a 7c                	push   $0x7c
  8017a2:	68 b0 27 80 00       	push   $0x8027b0
  8017a7:	e8 ba 05 00 00       	call   801d66 <_panic>
	assert(r <= PGSIZE);
  8017ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b1:	7e 16                	jle    8017c9 <devfile_read+0x65>
  8017b3:	68 bb 27 80 00       	push   $0x8027bb
  8017b8:	68 9b 27 80 00       	push   $0x80279b
  8017bd:	6a 7d                	push   $0x7d
  8017bf:	68 b0 27 80 00       	push   $0x8027b0
  8017c4:	e8 9d 05 00 00       	call   801d66 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	50                   	push   %eax
  8017cd:	68 00 50 80 00       	push   $0x805000
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	e8 13 f1 ff ff       	call   8008ed <memmove>
	return r;
  8017da:	83 c4 10             	add    $0x10,%esp
}
  8017dd:	89 d8                	mov    %ebx,%eax
  8017df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	83 ec 20             	sub    $0x20,%esp
  8017ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f0:	53                   	push   %ebx
  8017f1:	e8 2c ef ff ff       	call   800722 <strlen>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fe:	7f 67                	jg     801867 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801800:	83 ec 0c             	sub    $0xc,%esp
  801803:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801806:	50                   	push   %eax
  801807:	e8 74 f8 ff ff       	call   801080 <fd_alloc>
  80180c:	83 c4 10             	add    $0x10,%esp
		return r;
  80180f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801811:	85 c0                	test   %eax,%eax
  801813:	78 57                	js     80186c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	53                   	push   %ebx
  801819:	68 00 50 80 00       	push   $0x805000
  80181e:	e8 38 ef ff ff       	call   80075b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801823:	8b 45 0c             	mov    0xc(%ebp),%eax
  801826:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182e:	b8 01 00 00 00       	mov    $0x1,%eax
  801833:	e8 d0 fd ff ff       	call   801608 <fsipc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	79 14                	jns    801855 <open+0x6f>
		fd_close(fd, 0);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	6a 00                	push   $0x0
  801846:	ff 75 f4             	pushl  -0xc(%ebp)
  801849:	e8 2a f9 ff ff       	call   801178 <fd_close>
		return r;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	89 da                	mov    %ebx,%edx
  801853:	eb 17                	jmp    80186c <open+0x86>
	}

	return fd2num(fd);
  801855:	83 ec 0c             	sub    $0xc,%esp
  801858:	ff 75 f4             	pushl  -0xc(%ebp)
  80185b:	e8 f9 f7 ff ff       	call   801059 <fd2num>
  801860:	89 c2                	mov    %eax,%edx
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb 05                	jmp    80186c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801867:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186c:	89 d0                	mov    %edx,%eax
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801879:	ba 00 00 00 00       	mov    $0x0,%edx
  80187e:	b8 08 00 00 00       	mov    $0x8,%eax
  801883:	e8 80 fd ff ff       	call   801608 <fsipc>
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	ff 75 08             	pushl  0x8(%ebp)
  801898:	e8 cc f7 ff ff       	call   801069 <fd2data>
  80189d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80189f:	83 c4 08             	add    $0x8,%esp
  8018a2:	68 c7 27 80 00       	push   $0x8027c7
  8018a7:	53                   	push   %ebx
  8018a8:	e8 ae ee ff ff       	call   80075b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ad:	8b 56 04             	mov    0x4(%esi),%edx
  8018b0:	89 d0                	mov    %edx,%eax
  8018b2:	2b 06                	sub    (%esi),%eax
  8018b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c1:	00 00 00 
	stat->st_dev = &devpipe;
  8018c4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018cb:	30 80 00 
	return 0;
}
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e4:	53                   	push   %ebx
  8018e5:	6a 00                	push   $0x0
  8018e7:	e8 fd f2 ff ff       	call   800be9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ec:	89 1c 24             	mov    %ebx,(%esp)
  8018ef:	e8 75 f7 ff ff       	call   801069 <fd2data>
  8018f4:	83 c4 08             	add    $0x8,%esp
  8018f7:	50                   	push   %eax
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 ea f2 ff ff       	call   800be9 <sys_page_unmap>
}
  8018ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	57                   	push   %edi
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	83 ec 1c             	sub    $0x1c,%esp
  80190d:	89 c6                	mov    %eax,%esi
  80190f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801912:	a1 04 40 80 00       	mov    0x804004,%eax
  801917:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	56                   	push   %esi
  80191e:	e8 11 06 00 00       	call   801f34 <pageref>
  801923:	89 c7                	mov    %eax,%edi
  801925:	83 c4 04             	add    $0x4,%esp
  801928:	ff 75 e4             	pushl  -0x1c(%ebp)
  80192b:	e8 04 06 00 00       	call   801f34 <pageref>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	39 c7                	cmp    %eax,%edi
  801935:	0f 94 c2             	sete   %dl
  801938:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80193b:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801941:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801944:	39 fb                	cmp    %edi,%ebx
  801946:	74 19                	je     801961 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801948:	84 d2                	test   %dl,%dl
  80194a:	74 c6                	je     801912 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80194c:	8b 51 58             	mov    0x58(%ecx),%edx
  80194f:	50                   	push   %eax
  801950:	52                   	push   %edx
  801951:	53                   	push   %ebx
  801952:	68 ce 27 80 00       	push   $0x8027ce
  801957:	e8 78 e8 ff ff       	call   8001d4 <cprintf>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	eb b1                	jmp    801912 <_pipeisclosed+0xe>
	}
}
  801961:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5f                   	pop    %edi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	57                   	push   %edi
  80196d:	56                   	push   %esi
  80196e:	53                   	push   %ebx
  80196f:	83 ec 28             	sub    $0x28,%esp
  801972:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801975:	56                   	push   %esi
  801976:	e8 ee f6 ff ff       	call   801069 <fd2data>
  80197b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	bf 00 00 00 00       	mov    $0x0,%edi
  801985:	eb 4b                	jmp    8019d2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801987:	89 da                	mov    %ebx,%edx
  801989:	89 f0                	mov    %esi,%eax
  80198b:	e8 74 ff ff ff       	call   801904 <_pipeisclosed>
  801990:	85 c0                	test   %eax,%eax
  801992:	75 48                	jne    8019dc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801994:	e8 ac f1 ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801999:	8b 43 04             	mov    0x4(%ebx),%eax
  80199c:	8b 0b                	mov    (%ebx),%ecx
  80199e:	8d 51 20             	lea    0x20(%ecx),%edx
  8019a1:	39 d0                	cmp    %edx,%eax
  8019a3:	73 e2                	jae    801987 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019af:	89 c2                	mov    %eax,%edx
  8019b1:	c1 fa 1f             	sar    $0x1f,%edx
  8019b4:	89 d1                	mov    %edx,%ecx
  8019b6:	c1 e9 1b             	shr    $0x1b,%ecx
  8019b9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019bc:	83 e2 1f             	and    $0x1f,%edx
  8019bf:	29 ca                	sub    %ecx,%edx
  8019c1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019c9:	83 c0 01             	add    $0x1,%eax
  8019cc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cf:	83 c7 01             	add    $0x1,%edi
  8019d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019d5:	75 c2                	jne    801999 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019da:	eb 05                	jmp    8019e1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019dc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	57                   	push   %edi
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 18             	sub    $0x18,%esp
  8019f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019f5:	57                   	push   %edi
  8019f6:	e8 6e f6 ff ff       	call   801069 <fd2data>
  8019fb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a05:	eb 3d                	jmp    801a44 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a07:	85 db                	test   %ebx,%ebx
  801a09:	74 04                	je     801a0f <devpipe_read+0x26>
				return i;
  801a0b:	89 d8                	mov    %ebx,%eax
  801a0d:	eb 44                	jmp    801a53 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a0f:	89 f2                	mov    %esi,%edx
  801a11:	89 f8                	mov    %edi,%eax
  801a13:	e8 ec fe ff ff       	call   801904 <_pipeisclosed>
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	75 32                	jne    801a4e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a1c:	e8 24 f1 ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a21:	8b 06                	mov    (%esi),%eax
  801a23:	3b 46 04             	cmp    0x4(%esi),%eax
  801a26:	74 df                	je     801a07 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a28:	99                   	cltd   
  801a29:	c1 ea 1b             	shr    $0x1b,%edx
  801a2c:	01 d0                	add    %edx,%eax
  801a2e:	83 e0 1f             	and    $0x1f,%eax
  801a31:	29 d0                	sub    %edx,%eax
  801a33:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a3e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a41:	83 c3 01             	add    $0x1,%ebx
  801a44:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a47:	75 d8                	jne    801a21 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4c:	eb 05                	jmp    801a53 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a66:	50                   	push   %eax
  801a67:	e8 14 f6 ff ff       	call   801080 <fd_alloc>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	85 c0                	test   %eax,%eax
  801a73:	0f 88 2c 01 00 00    	js     801ba5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a79:	83 ec 04             	sub    $0x4,%esp
  801a7c:	68 07 04 00 00       	push   $0x407
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	6a 00                	push   $0x0
  801a86:	e8 d9 f0 ff ff       	call   800b64 <sys_page_alloc>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	89 c2                	mov    %eax,%edx
  801a90:	85 c0                	test   %eax,%eax
  801a92:	0f 88 0d 01 00 00    	js     801ba5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9e:	50                   	push   %eax
  801a9f:	e8 dc f5 ff ff       	call   801080 <fd_alloc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	0f 88 e2 00 00 00    	js     801b93 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab1:	83 ec 04             	sub    $0x4,%esp
  801ab4:	68 07 04 00 00       	push   $0x407
  801ab9:	ff 75 f0             	pushl  -0x10(%ebp)
  801abc:	6a 00                	push   $0x0
  801abe:	e8 a1 f0 ff ff       	call   800b64 <sys_page_alloc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	0f 88 c3 00 00 00    	js     801b93 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad6:	e8 8e f5 ff ff       	call   801069 <fd2data>
  801adb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801add:	83 c4 0c             	add    $0xc,%esp
  801ae0:	68 07 04 00 00       	push   $0x407
  801ae5:	50                   	push   %eax
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 77 f0 ff ff       	call   800b64 <sys_page_alloc>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	0f 88 89 00 00 00    	js     801b83 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f0             	pushl  -0x10(%ebp)
  801b00:	e8 64 f5 ff ff       	call   801069 <fd2data>
  801b05:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b0c:	50                   	push   %eax
  801b0d:	6a 00                	push   $0x0
  801b0f:	56                   	push   %esi
  801b10:	6a 00                	push   $0x0
  801b12:	e8 90 f0 ff ff       	call   800ba7 <sys_page_map>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 20             	add    $0x20,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 55                	js     801b75 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b29:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	e8 04 f5 ff ff       	call   801059 <fd2num>
  801b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b58:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b5a:	83 c4 04             	add    $0x4,%esp
  801b5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b60:	e8 f4 f4 ff ff       	call   801059 <fd2num>
  801b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b68:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b73:	eb 30                	jmp    801ba5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	56                   	push   %esi
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 69 f0 ff ff       	call   800be9 <sys_page_unmap>
  801b80:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b83:	83 ec 08             	sub    $0x8,%esp
  801b86:	ff 75 f0             	pushl  -0x10(%ebp)
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 59 f0 ff ff       	call   800be9 <sys_page_unmap>
  801b90:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b93:	83 ec 08             	sub    $0x8,%esp
  801b96:	ff 75 f4             	pushl  -0xc(%ebp)
  801b99:	6a 00                	push   $0x0
  801b9b:	e8 49 f0 ff ff       	call   800be9 <sys_page_unmap>
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ba5:	89 d0                	mov    %edx,%eax
  801ba7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb7:	50                   	push   %eax
  801bb8:	ff 75 08             	pushl  0x8(%ebp)
  801bbb:	e8 0f f5 ff ff       	call   8010cf <fd_lookup>
  801bc0:	89 c2                	mov    %eax,%edx
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	85 d2                	test   %edx,%edx
  801bc7:	78 18                	js     801be1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcf:	e8 95 f4 ff ff       	call   801069 <fd2data>
	return _pipeisclosed(fd, p);
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd9:	e8 26 fd ff ff       	call   801904 <_pipeisclosed>
  801bde:	83 c4 10             	add    $0x10,%esp
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bf3:	68 e6 27 80 00       	push   $0x8027e6
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	e8 5b eb ff ff       	call   80075b <strcpy>
	return 0;
}
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c13:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c18:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1e:	eb 2d                	jmp    801c4d <devcons_write+0x46>
		m = n - tot;
  801c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c23:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c25:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c28:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c2d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	53                   	push   %ebx
  801c34:	03 45 0c             	add    0xc(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	57                   	push   %edi
  801c39:	e8 af ec ff ff       	call   8008ed <memmove>
		sys_cputs(buf, m);
  801c3e:	83 c4 08             	add    $0x8,%esp
  801c41:	53                   	push   %ebx
  801c42:	57                   	push   %edi
  801c43:	e8 60 ee ff ff       	call   800aa8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c48:	01 de                	add    %ebx,%esi
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	89 f0                	mov    %esi,%eax
  801c4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c52:	72 cc                	jb     801c20 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5f                   	pop    %edi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c6b:	75 07                	jne    801c74 <devcons_read+0x18>
  801c6d:	eb 28                	jmp    801c97 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c6f:	e8 d1 ee ff ff       	call   800b45 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c74:	e8 4d ee ff ff       	call   800ac6 <sys_cgetc>
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	74 f2                	je     801c6f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 16                	js     801c97 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c81:	83 f8 04             	cmp    $0x4,%eax
  801c84:	74 0c                	je     801c92 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c89:	88 02                	mov    %al,(%edx)
	return 1;
  801c8b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c90:	eb 05                	jmp    801c97 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca5:	6a 01                	push   $0x1
  801ca7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	e8 f8 ed ff ff       	call   800aa8 <sys_cputs>
  801cb0:	83 c4 10             	add    $0x10,%esp
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <getchar>:

int
getchar(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cbb:	6a 01                	push   $0x1
  801cbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc0:	50                   	push   %eax
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 71 f6 ff ff       	call   801339 <read>
	if (r < 0)
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 0f                	js     801cde <getchar+0x29>
		return r;
	if (r < 1)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	7e 06                	jle    801cd9 <getchar+0x24>
		return -E_EOF;
	return c;
  801cd3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cd7:	eb 05                	jmp    801cde <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cd9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	ff 75 08             	pushl  0x8(%ebp)
  801ced:	e8 dd f3 ff ff       	call   8010cf <fd_lookup>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 11                	js     801d0a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d02:	39 10                	cmp    %edx,(%eax)
  801d04:	0f 94 c0             	sete   %al
  801d07:	0f b6 c0             	movzbl %al,%eax
}
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <opencons>:

int
opencons(void)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	e8 65 f3 ff ff       	call   801080 <fd_alloc>
  801d1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 3e                	js     801d62 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 2e ee ff ff       	call   800b64 <sys_page_alloc>
  801d36:	83 c4 10             	add    $0x10,%esp
		return r;
  801d39:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 23                	js     801d62 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d3f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d48:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	50                   	push   %eax
  801d58:	e8 fc f2 ff ff       	call   801059 <fd2num>
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	83 c4 10             	add    $0x10,%esp
}
  801d62:	89 d0                	mov    %edx,%eax
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d6b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d6e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d74:	e8 ad ed ff ff       	call   800b26 <sys_getenvid>
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 0c             	pushl  0xc(%ebp)
  801d7f:	ff 75 08             	pushl  0x8(%ebp)
  801d82:	56                   	push   %esi
  801d83:	50                   	push   %eax
  801d84:	68 f4 27 80 00       	push   $0x8027f4
  801d89:	e8 46 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d8e:	83 c4 18             	add    $0x18,%esp
  801d91:	53                   	push   %ebx
  801d92:	ff 75 10             	pushl  0x10(%ebp)
  801d95:	e8 e9 e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d9a:	c7 04 24 4f 22 80 00 	movl   $0x80224f,(%esp)
  801da1:	e8 2e e4 ff ff       	call   8001d4 <cprintf>
  801da6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801da9:	cc                   	int3   
  801daa:	eb fd                	jmp    801da9 <_panic+0x43>

00801dac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801db2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801db9:	75 2c                	jne    801de7 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801dbb:	83 ec 04             	sub    $0x4,%esp
  801dbe:	6a 07                	push   $0x7
  801dc0:	68 00 f0 bf ee       	push   $0xeebff000
  801dc5:	6a 00                	push   $0x0
  801dc7:	e8 98 ed ff ff       	call   800b64 <sys_page_alloc>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	74 14                	je     801de7 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	68 18 28 80 00       	push   $0x802818
  801ddb:	6a 21                	push   $0x21
  801ddd:	68 7c 28 80 00       	push   $0x80287c
  801de2:	e8 7f ff ff ff       	call   801d66 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801def:	83 ec 08             	sub    $0x8,%esp
  801df2:	68 1b 1e 80 00       	push   $0x801e1b
  801df7:	6a 00                	push   $0x0
  801df9:	e8 b1 ee ff ff       	call   800caf <sys_env_set_pgfault_upcall>
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	85 c0                	test   %eax,%eax
  801e03:	79 14                	jns    801e19 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801e05:	83 ec 04             	sub    $0x4,%esp
  801e08:	68 44 28 80 00       	push   $0x802844
  801e0d:	6a 29                	push   $0x29
  801e0f:	68 7c 28 80 00       	push   $0x80287c
  801e14:	e8 4d ff ff ff       	call   801d66 <_panic>
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e1c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e21:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e23:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801e26:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801e2b:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801e2f:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801e33:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801e35:	83 c4 08             	add    $0x8,%esp
        popal
  801e38:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e39:	83 c4 04             	add    $0x4,%esp
        popfl
  801e3c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801e3d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e3e:	c3                   	ret    

00801e3f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	8b 75 08             	mov    0x8(%ebp),%esi
  801e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e54:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	50                   	push   %eax
  801e5b:	e8 b4 ee ff ff       	call   800d14 <sys_ipc_recv>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	79 16                	jns    801e7d <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801e67:	85 f6                	test   %esi,%esi
  801e69:	74 06                	je     801e71 <ipc_recv+0x32>
  801e6b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801e71:	85 db                	test   %ebx,%ebx
  801e73:	74 2c                	je     801ea1 <ipc_recv+0x62>
  801e75:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e7b:	eb 24                	jmp    801ea1 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801e7d:	85 f6                	test   %esi,%esi
  801e7f:	74 0a                	je     801e8b <ipc_recv+0x4c>
  801e81:	a1 04 40 80 00       	mov    0x804004,%eax
  801e86:	8b 40 74             	mov    0x74(%eax),%eax
  801e89:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 0a                	je     801e99 <ipc_recv+0x5a>
  801e8f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e94:	8b 40 78             	mov    0x78(%eax),%eax
  801e97:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801e99:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    

00801ea8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	57                   	push   %edi
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801eba:	85 db                	test   %ebx,%ebx
  801ebc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ec1:	0f 44 d8             	cmove  %eax,%ebx
  801ec4:	eb 1c                	jmp    801ee2 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801ec6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec9:	74 12                	je     801edd <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ecb:	50                   	push   %eax
  801ecc:	68 8a 28 80 00       	push   $0x80288a
  801ed1:	6a 39                	push   $0x39
  801ed3:	68 a5 28 80 00       	push   $0x8028a5
  801ed8:	e8 89 fe ff ff       	call   801d66 <_panic>
                 sys_yield();
  801edd:	e8 63 ec ff ff       	call   800b45 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ee2:	ff 75 14             	pushl  0x14(%ebp)
  801ee5:	53                   	push   %ebx
  801ee6:	56                   	push   %esi
  801ee7:	57                   	push   %edi
  801ee8:	e8 04 ee ff ff       	call   800cf1 <sys_ipc_try_send>
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 d2                	js     801ec6 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f02:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f07:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f0a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f10:	8b 52 50             	mov    0x50(%edx),%edx
  801f13:	39 ca                	cmp    %ecx,%edx
  801f15:	75 0d                	jne    801f24 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f17:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f1a:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801f1f:	8b 40 08             	mov    0x8(%eax),%eax
  801f22:	eb 0e                	jmp    801f32 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	83 c0 01             	add    $0x1,%eax
  801f27:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2c:	75 d9                	jne    801f07 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f2e:	66 b8 00 00          	mov    $0x0,%ax
}
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3a:	89 d0                	mov    %edx,%eax
  801f3c:	c1 e8 16             	shr    $0x16,%eax
  801f3f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4b:	f6 c1 01             	test   $0x1,%cl
  801f4e:	74 1d                	je     801f6d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f50:	c1 ea 0c             	shr    $0xc,%edx
  801f53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5a:	f6 c2 01             	test   $0x1,%dl
  801f5d:	74 0e                	je     801f6d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5f:	c1 ea 0c             	shr    $0xc,%edx
  801f62:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f69:	ef 
  801f6a:	0f b7 c0             	movzwl %ax,%eax
}
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	83 ec 10             	sub    $0x10,%esp
  801f76:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f7a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f7e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f86:	85 d2                	test   %edx,%edx
  801f88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f8c:	89 34 24             	mov    %esi,(%esp)
  801f8f:	89 c8                	mov    %ecx,%eax
  801f91:	75 35                	jne    801fc8 <__udivdi3+0x58>
  801f93:	39 f1                	cmp    %esi,%ecx
  801f95:	0f 87 bd 00 00 00    	ja     802058 <__udivdi3+0xe8>
  801f9b:	85 c9                	test   %ecx,%ecx
  801f9d:	89 cd                	mov    %ecx,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f1                	div    %ecx
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 f0                	mov    %esi,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c6                	mov    %eax,%esi
  801fb4:	89 f8                	mov    %edi,%eax
  801fb6:	f7 f5                	div    %ebp
  801fb8:	89 f2                	mov    %esi,%edx
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	5e                   	pop    %esi
  801fbe:	5f                   	pop    %edi
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    
  801fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	3b 14 24             	cmp    (%esp),%edx
  801fcb:	77 7b                	ja     802048 <__udivdi3+0xd8>
  801fcd:	0f bd f2             	bsr    %edx,%esi
  801fd0:	83 f6 1f             	xor    $0x1f,%esi
  801fd3:	0f 84 97 00 00 00    	je     802070 <__udivdi3+0x100>
  801fd9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fde:	89 d7                	mov    %edx,%edi
  801fe0:	89 f1                	mov    %esi,%ecx
  801fe2:	29 f5                	sub    %esi,%ebp
  801fe4:	d3 e7                	shl    %cl,%edi
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	89 e9                	mov    %ebp,%ecx
  801fea:	d3 ea                	shr    %cl,%edx
  801fec:	89 f1                	mov    %esi,%ecx
  801fee:	09 fa                	or     %edi,%edx
  801ff0:	8b 3c 24             	mov    (%esp),%edi
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ff9:	89 e9                	mov    %ebp,%ecx
  801ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802003:	89 fa                	mov    %edi,%edx
  802005:	d3 ea                	shr    %cl,%edx
  802007:	89 f1                	mov    %esi,%ecx
  802009:	d3 e7                	shl    %cl,%edi
  80200b:	89 e9                	mov    %ebp,%ecx
  80200d:	d3 e8                	shr    %cl,%eax
  80200f:	09 c7                	or     %eax,%edi
  802011:	89 f8                	mov    %edi,%eax
  802013:	f7 74 24 08          	divl   0x8(%esp)
  802017:	89 d5                	mov    %edx,%ebp
  802019:	89 c7                	mov    %eax,%edi
  80201b:	f7 64 24 0c          	mull   0xc(%esp)
  80201f:	39 d5                	cmp    %edx,%ebp
  802021:	89 14 24             	mov    %edx,(%esp)
  802024:	72 11                	jb     802037 <__udivdi3+0xc7>
  802026:	8b 54 24 04          	mov    0x4(%esp),%edx
  80202a:	89 f1                	mov    %esi,%ecx
  80202c:	d3 e2                	shl    %cl,%edx
  80202e:	39 c2                	cmp    %eax,%edx
  802030:	73 5e                	jae    802090 <__udivdi3+0x120>
  802032:	3b 2c 24             	cmp    (%esp),%ebp
  802035:	75 59                	jne    802090 <__udivdi3+0x120>
  802037:	8d 47 ff             	lea    -0x1(%edi),%eax
  80203a:	31 f6                	xor    %esi,%esi
  80203c:	89 f2                	mov    %esi,%edx
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	31 f6                	xor    %esi,%esi
  80204a:	31 c0                	xor    %eax,%eax
  80204c:	89 f2                	mov    %esi,%edx
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
  802058:	89 f2                	mov    %esi,%edx
  80205a:	31 f6                	xor    %esi,%esi
  80205c:	89 f8                	mov    %edi,%eax
  80205e:	f7 f1                	div    %ecx
  802060:	89 f2                	mov    %esi,%edx
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802074:	76 0b                	jbe    802081 <__udivdi3+0x111>
  802076:	31 c0                	xor    %eax,%eax
  802078:	3b 14 24             	cmp    (%esp),%edx
  80207b:	0f 83 37 ff ff ff    	jae    801fb8 <__udivdi3+0x48>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	e9 2d ff ff ff       	jmp    801fb8 <__udivdi3+0x48>
  80208b:	90                   	nop
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f8                	mov    %edi,%eax
  802092:	31 f6                	xor    %esi,%esi
  802094:	e9 1f ff ff ff       	jmp    801fb8 <__udivdi3+0x48>
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	83 ec 20             	sub    $0x20,%esp
  8020a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8020aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b2:	89 c6                	mov    %eax,%esi
  8020b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	89 c2                	mov    %eax,%edx
  8020d0:	75 1e                	jne    8020f0 <__umoddi3+0x50>
  8020d2:	39 f7                	cmp    %esi,%edi
  8020d4:	76 52                	jbe    802128 <__umoddi3+0x88>
  8020d6:	89 c8                	mov    %ecx,%eax
  8020d8:	89 f2                	mov    %esi,%edx
  8020da:	f7 f7                	div    %edi
  8020dc:	89 d0                	mov    %edx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	83 c4 20             	add    $0x20,%esp
  8020e3:	5e                   	pop    %esi
  8020e4:	5f                   	pop    %edi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    
  8020e7:	89 f6                	mov    %esi,%esi
  8020e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020f0:	39 f0                	cmp    %esi,%eax
  8020f2:	77 5c                	ja     802150 <__umoddi3+0xb0>
  8020f4:	0f bd e8             	bsr    %eax,%ebp
  8020f7:	83 f5 1f             	xor    $0x1f,%ebp
  8020fa:	75 64                	jne    802160 <__umoddi3+0xc0>
  8020fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802100:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802104:	0f 86 f6 00 00 00    	jbe    802200 <__umoddi3+0x160>
  80210a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80210e:	0f 82 ec 00 00 00    	jb     802200 <__umoddi3+0x160>
  802114:	8b 44 24 14          	mov    0x14(%esp),%eax
  802118:	8b 54 24 18          	mov    0x18(%esp),%edx
  80211c:	83 c4 20             	add    $0x20,%esp
  80211f:	5e                   	pop    %esi
  802120:	5f                   	pop    %edi
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    
  802123:	90                   	nop
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	85 ff                	test   %edi,%edi
  80212a:	89 fd                	mov    %edi,%ebp
  80212c:	75 0b                	jne    802139 <__umoddi3+0x99>
  80212e:	b8 01 00 00 00       	mov    $0x1,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f7                	div    %edi
  802137:	89 c5                	mov    %eax,%ebp
  802139:	8b 44 24 10          	mov    0x10(%esp),%eax
  80213d:	31 d2                	xor    %edx,%edx
  80213f:	f7 f5                	div    %ebp
  802141:	89 c8                	mov    %ecx,%eax
  802143:	f7 f5                	div    %ebp
  802145:	eb 95                	jmp    8020dc <__umoddi3+0x3c>
  802147:	89 f6                	mov    %esi,%esi
  802149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 20             	add    $0x20,%esp
  802157:	5e                   	pop    %esi
  802158:	5f                   	pop    %edi
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    
  80215b:	90                   	nop
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	b8 20 00 00 00       	mov    $0x20,%eax
  802165:	89 e9                	mov    %ebp,%ecx
  802167:	29 e8                	sub    %ebp,%eax
  802169:	d3 e2                	shl    %cl,%edx
  80216b:	89 c7                	mov    %eax,%edi
  80216d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802171:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 c1                	mov    %eax,%ecx
  80217b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80217f:	09 d1                	or     %edx,%ecx
  802181:	89 fa                	mov    %edi,%edx
  802183:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802187:	89 e9                	mov    %ebp,%ecx
  802189:	d3 e0                	shl    %cl,%eax
  80218b:	89 f9                	mov    %edi,%ecx
  80218d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802191:	89 f0                	mov    %esi,%eax
  802193:	d3 e8                	shr    %cl,%eax
  802195:	89 e9                	mov    %ebp,%ecx
  802197:	89 c7                	mov    %eax,%edi
  802199:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80219d:	d3 e6                	shl    %cl,%esi
  80219f:	89 d1                	mov    %edx,%ecx
  8021a1:	89 fa                	mov    %edi,%edx
  8021a3:	d3 e8                	shr    %cl,%eax
  8021a5:	89 e9                	mov    %ebp,%ecx
  8021a7:	09 f0                	or     %esi,%eax
  8021a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8021ad:	f7 74 24 10          	divl   0x10(%esp)
  8021b1:	d3 e6                	shl    %cl,%esi
  8021b3:	89 d1                	mov    %edx,%ecx
  8021b5:	f7 64 24 0c          	mull   0xc(%esp)
  8021b9:	39 d1                	cmp    %edx,%ecx
  8021bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8021bf:	89 d7                	mov    %edx,%edi
  8021c1:	89 c6                	mov    %eax,%esi
  8021c3:	72 0a                	jb     8021cf <__umoddi3+0x12f>
  8021c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021c9:	73 10                	jae    8021db <__umoddi3+0x13b>
  8021cb:	39 d1                	cmp    %edx,%ecx
  8021cd:	75 0c                	jne    8021db <__umoddi3+0x13b>
  8021cf:	89 d7                	mov    %edx,%edi
  8021d1:	89 c6                	mov    %eax,%esi
  8021d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021db:	89 ca                	mov    %ecx,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021e3:	29 f0                	sub    %esi,%eax
  8021e5:	19 fa                	sbb    %edi,%edx
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021ee:	89 d7                	mov    %edx,%edi
  8021f0:	d3 e7                	shl    %cl,%edi
  8021f2:	89 e9                	mov    %ebp,%ecx
  8021f4:	09 f8                	or     %edi,%eax
  8021f6:	d3 ea                	shr    %cl,%edx
  8021f8:	83 c4 20             	add    $0x20,%esp
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
  8021ff:	90                   	nop
  802200:	8b 74 24 10          	mov    0x10(%esp),%esi
  802204:	29 f9                	sub    %edi,%ecx
  802206:	19 c6                	sbb    %eax,%esi
  802208:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80220c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802210:	e9 ff fe ff ff       	jmp    802114 <__umoddi3+0x74>
