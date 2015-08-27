
obj/user/forktree:     file format elf32-i386


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
  80003d:	e8 dc 0a 00 00       	call   800b1e <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 13 80 00       	push   $0x801360
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

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
  80007e:	e8 97 06 00 00       	call   80071a <strlen>
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
  800095:	68 71 13 80 00       	push   $0x801371
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 5b 06 00 00       	call   800700 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 40 0d 00 00       	call   800ded <fork>
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
  8000d2:	68 70 13 80 00       	push   $0x801370
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
  8000ec:	e8 2d 0a 00 00       	call   800b1e <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 a9 09 00 00       	call   800add <sys_env_destroy>
  800134:	83 c4 10             	add    $0x10,%esp
}
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 37 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 4f 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 dc 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 d1                	mov    %edx,%ecx
  8001f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800204:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80020b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80020e:	72 05                	jb     800215 <printnum+0x35>
  800210:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800213:	77 3e                	ja     800253 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	ff 75 18             	pushl  0x18(%ebp)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	53                   	push   %ebx
  80021f:	50                   	push   %eax
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 7c 0e 00 00       	call   8010b0 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 13                	jmp    80025a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800253:	83 eb 01             	sub    $0x1,%ebx
  800256:	85 db                	test   %ebx,%ebx
  800258:	7f ed                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	56                   	push   %esi
  80025e:	83 ec 04             	sub    $0x4,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 6e 0f 00 00       	call   8011e0 <__umoddi3>
  800272:	83 c4 14             	add    $0x14,%esp
  800275:	0f be 80 80 13 80 00 	movsbl 0x801380(%eax),%eax
  80027c:	50                   	push   %eax
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028d:	83 fa 01             	cmp    $0x1,%edx
  800290:	7e 0e                	jle    8002a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 08             	lea    0x8(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	8b 52 04             	mov    0x4(%edx),%edx
  80029e:	eb 22                	jmp    8002c2 <getuint+0x38>
	else if (lflag)
  8002a0:	85 d2                	test   %edx,%edx
  8002a2:	74 10                	je     8002b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b2:	eb 0e                	jmp    8002c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ca:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d3:	73 0a                	jae    8002df <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	88 02                	mov    %al,(%edx)
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ea:	50                   	push   %eax
  8002eb:	ff 75 10             	pushl  0x10(%ebp)
  8002ee:	ff 75 0c             	pushl  0xc(%ebp)
  8002f1:	ff 75 08             	pushl  0x8(%ebp)
  8002f4:	e8 05 00 00 00       	call   8002fe <vprintfmt>
	va_end(ap);
  8002f9:	83 c4 10             	add    $0x10,%esp
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 2c             	sub    $0x2c,%esp
  800307:	8b 75 08             	mov    0x8(%ebp),%esi
  80030a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800310:	eb 12                	jmp    800324 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800312:	85 c0                	test   %eax,%eax
  800314:	0f 84 90 03 00 00    	je     8006aa <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	53                   	push   %ebx
  80031e:	50                   	push   %eax
  80031f:	ff d6                	call   *%esi
  800321:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800324:	83 c7 01             	add    $0x1,%edi
  800327:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032b:	83 f8 25             	cmp    $0x25,%eax
  80032e:	75 e2                	jne    800312 <vprintfmt+0x14>
  800330:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800334:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800342:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 07                	jmp    800357 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800353:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8d 47 01             	lea    0x1(%edi),%eax
  80035a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035d:	0f b6 07             	movzbl (%edi),%eax
  800360:	0f b6 c8             	movzbl %al,%ecx
  800363:	83 e8 23             	sub    $0x23,%eax
  800366:	3c 55                	cmp    $0x55,%al
  800368:	0f 87 21 03 00 00    	ja     80068f <vprintfmt+0x391>
  80036e:	0f b6 c0             	movzbl %al,%eax
  800371:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037f:	eb d6                	jmp    800357 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800384:	b8 00 00 00 00       	mov    $0x0,%eax
  800389:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800393:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800396:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800399:	83 fa 09             	cmp    $0x9,%edx
  80039c:	77 39                	ja     8003d7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a1:	eb e9                	jmp    80038c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ac:	8b 00                	mov    (%eax),%eax
  8003ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b4:	eb 27                	jmp    8003dd <vprintfmt+0xdf>
  8003b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	0f 49 c8             	cmovns %eax,%ecx
  8003c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c9:	eb 8c                	jmp    800357 <vprintfmt+0x59>
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d5:	eb 80                	jmp    800357 <vprintfmt+0x59>
  8003d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003da:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e1:	0f 89 70 ff ff ff    	jns    800357 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f4:	e9 5e ff ff ff       	jmp    800357 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ff:	e9 53 ff ff ff       	jmp    800357 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	53                   	push   %ebx
  800411:	ff 30                	pushl  (%eax)
  800413:	ff d6                	call   *%esi
			break;
  800415:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041b:	e9 04 ff ff ff       	jmp    800324 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	99                   	cltd   
  80042c:	31 d0                	xor    %edx,%eax
  80042e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800430:	83 f8 09             	cmp    $0x9,%eax
  800433:	7f 0b                	jg     800440 <vprintfmt+0x142>
  800435:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  80043c:	85 d2                	test   %edx,%edx
  80043e:	75 18                	jne    800458 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800440:	50                   	push   %eax
  800441:	68 98 13 80 00       	push   $0x801398
  800446:	53                   	push   %ebx
  800447:	56                   	push   %esi
  800448:	e8 94 fe ff ff       	call   8002e1 <printfmt>
  80044d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800453:	e9 cc fe ff ff       	jmp    800324 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800458:	52                   	push   %edx
  800459:	68 a1 13 80 00       	push   $0x8013a1
  80045e:	53                   	push   %ebx
  80045f:	56                   	push   %esi
  800460:	e8 7c fe ff ff       	call   8002e1 <printfmt>
  800465:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046b:	e9 b4 fe ff ff       	jmp    800324 <vprintfmt+0x26>
  800470:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800476:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800484:	85 ff                	test   %edi,%edi
  800486:	ba 91 13 80 00       	mov    $0x801391,%edx
  80048b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80048e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800492:	0f 84 92 00 00 00    	je     80052a <vprintfmt+0x22c>
  800498:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80049c:	0f 8e 96 00 00 00    	jle    800538 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	51                   	push   %ecx
  8004a6:	57                   	push   %edi
  8004a7:	e8 86 02 00 00       	call   800732 <strnlen>
  8004ac:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004af:	29 c1                	sub    %eax,%ecx
  8004b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	eb 0f                	jmp    8004d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	83 ef 01             	sub    $0x1,%edi
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	7f ed                	jg     8004c5 <vprintfmt+0x1c7>
  8004d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004de:	85 c9                	test   %ecx,%ecx
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	0f 49 c1             	cmovns %ecx,%eax
  8004e8:	29 c1                	sub    %eax,%ecx
  8004ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f3:	89 cb                	mov    %ecx,%ebx
  8004f5:	eb 4d                	jmp    800544 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	74 1b                	je     800518 <vprintfmt+0x21a>
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	83 e8 20             	sub    $0x20,%eax
  800503:	83 f8 5e             	cmp    $0x5e,%eax
  800506:	76 10                	jbe    800518 <vprintfmt+0x21a>
					putch('?', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	6a 3f                	push   $0x3f
  800510:	ff 55 08             	call   *0x8(%ebp)
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	eb 0d                	jmp    800525 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	52                   	push   %edx
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800525:	83 eb 01             	sub    $0x1,%ebx
  800528:	eb 1a                	jmp    800544 <vprintfmt+0x246>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	eb 0c                	jmp    800544 <vprintfmt+0x246>
  800538:	89 75 08             	mov    %esi,0x8(%ebp)
  80053b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800541:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800544:	83 c7 01             	add    $0x1,%edi
  800547:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054b:	0f be d0             	movsbl %al,%edx
  80054e:	85 d2                	test   %edx,%edx
  800550:	74 23                	je     800575 <vprintfmt+0x277>
  800552:	85 f6                	test   %esi,%esi
  800554:	78 a1                	js     8004f7 <vprintfmt+0x1f9>
  800556:	83 ee 01             	sub    $0x1,%esi
  800559:	79 9c                	jns    8004f7 <vprintfmt+0x1f9>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	eb 18                	jmp    80057d <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	6a 20                	push   $0x20
  80056b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 08                	jmp    80057d <vprintfmt+0x27f>
  800575:	89 df                	mov    %ebx,%edi
  800577:	8b 75 08             	mov    0x8(%ebp),%esi
  80057a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057d:	85 ff                	test   %edi,%edi
  80057f:	7f e4                	jg     800565 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800584:	e9 9b fd ff ff       	jmp    800324 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800589:	83 fa 01             	cmp    $0x1,%edx
  80058c:	7e 16                	jle    8005a4 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 08             	lea    0x8(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 50 04             	mov    0x4(%eax),%edx
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a2:	eb 32                	jmp    8005d6 <vprintfmt+0x2d8>
	else if (lflag)
  8005a4:	85 d2                	test   %edx,%edx
  8005a6:	74 18                	je     8005c0 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 c1                	mov    %eax,%ecx
  8005b8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005be:	eb 16                	jmp    8005d6 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	89 c1                	mov    %eax,%ecx
  8005d0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e5:	79 74                	jns    80065b <vprintfmt+0x35d>
				putch('-', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	53                   	push   %ebx
  8005eb:	6a 2d                	push   $0x2d
  8005ed:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f5:	f7 d8                	neg    %eax
  8005f7:	83 d2 00             	adc    $0x0,%edx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800604:	eb 55                	jmp    80065b <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 7c fc ff ff       	call   80028a <getuint>
			base = 10;
  80060e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800613:	eb 46                	jmp    80065b <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
  800618:	e8 6d fc ff ff       	call   80028a <getuint>
                        base = 8;
  80061d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800622:	eb 37                	jmp    80065b <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800644:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800647:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064c:	eb 0d                	jmp    80065b <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 34 fc ff ff       	call   80028a <getuint>
			base = 16;
  800656:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065b:	83 ec 0c             	sub    $0xc,%esp
  80065e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800662:	57                   	push   %edi
  800663:	ff 75 e0             	pushl  -0x20(%ebp)
  800666:	51                   	push   %ecx
  800667:	52                   	push   %edx
  800668:	50                   	push   %eax
  800669:	89 da                	mov    %ebx,%edx
  80066b:	89 f0                	mov    %esi,%eax
  80066d:	e8 6e fb ff ff       	call   8001e0 <printnum>
			break;
  800672:	83 c4 20             	add    $0x20,%esp
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800678:	e9 a7 fc ff ff       	jmp    800324 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	51                   	push   %ecx
  800682:	ff d6                	call   *%esi
			break;
  800684:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068a:	e9 95 fc ff ff       	jmp    800324 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 25                	push   $0x25
  800695:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	eb 03                	jmp    80069f <vprintfmt+0x3a1>
  80069c:	83 ef 01             	sub    $0x1,%edi
  80069f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a3:	75 f7                	jne    80069c <vprintfmt+0x39e>
  8006a5:	e9 7a fc ff ff       	jmp    800324 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 18             	sub    $0x18,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 26                	je     8006f9 <vsnprintf+0x47>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 22                	jle    8006f9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	ff 75 14             	pushl  0x14(%ebp)
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	68 c4 02 80 00       	push   $0x8002c4
  8006e6:	e8 13 fc ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 05                	jmp    8006fe <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800709:	50                   	push   %eax
  80070a:	ff 75 10             	pushl  0x10(%ebp)
  80070d:	ff 75 0c             	pushl  0xc(%ebp)
  800710:	ff 75 08             	pushl  0x8(%ebp)
  800713:	e8 9a ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	eb 03                	jmp    80072a <strlen+0x10>
		n++;
  800727:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072e:	75 f7                	jne    800727 <strlen+0xd>
		n++;
	return n;
}
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	ba 00 00 00 00       	mov    $0x0,%edx
  800740:	eb 03                	jmp    800745 <strnlen+0x13>
		n++;
  800742:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800745:	39 c2                	cmp    %eax,%edx
  800747:	74 08                	je     800751 <strnlen+0x1f>
  800749:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074d:	75 f3                	jne    800742 <strnlen+0x10>
  80074f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	83 c2 01             	add    $0x1,%edx
  800762:	83 c1 01             	add    $0x1,%ecx
  800765:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800769:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076c:	84 db                	test   %bl,%bl
  80076e:	75 ef                	jne    80075f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800770:	5b                   	pop    %ebx
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077a:	53                   	push   %ebx
  80077b:	e8 9a ff ff ff       	call   80071a <strlen>
  800780:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	01 d8                	add    %ebx,%eax
  800788:	50                   	push   %eax
  800789:	e8 c5 ff ff ff       	call   800753 <strcpy>
	return dst;
}
  80078e:	89 d8                	mov    %ebx,%eax
  800790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	56                   	push   %esi
  800799:	53                   	push   %ebx
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	89 f3                	mov    %esi,%ebx
  8007a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a5:	89 f2                	mov    %esi,%edx
  8007a7:	eb 0f                	jmp    8007b8 <strncpy+0x23>
		*dst++ = *src;
  8007a9:	83 c2 01             	add    $0x1,%edx
  8007ac:	0f b6 01             	movzbl (%ecx),%eax
  8007af:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b8:	39 da                	cmp    %ebx,%edx
  8007ba:	75 ed                	jne    8007a9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	74 21                	je     8007f7 <strlcpy+0x35>
  8007d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007da:	89 f2                	mov    %esi,%edx
  8007dc:	eb 09                	jmp    8007e7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e7:	39 c2                	cmp    %eax,%edx
  8007e9:	74 09                	je     8007f4 <strlcpy+0x32>
  8007eb:	0f b6 19             	movzbl (%ecx),%ebx
  8007ee:	84 db                	test   %bl,%bl
  8007f0:	75 ec                	jne    8007de <strlcpy+0x1c>
  8007f2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f7:	29 f0                	sub    %esi,%eax
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800806:	eb 06                	jmp    80080e <strcmp+0x11>
		p++, q++;
  800808:	83 c1 01             	add    $0x1,%ecx
  80080b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	84 c0                	test   %al,%al
  800813:	74 04                	je     800819 <strcmp+0x1c>
  800815:	3a 02                	cmp    (%edx),%al
  800817:	74 ef                	je     800808 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800819:	0f b6 c0             	movzbl %al,%eax
  80081c:	0f b6 12             	movzbl (%edx),%edx
  80081f:	29 d0                	sub    %edx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 c3                	mov    %eax,%ebx
  80082f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800832:	eb 06                	jmp    80083a <strncmp+0x17>
		n--, p++, q++;
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083a:	39 d8                	cmp    %ebx,%eax
  80083c:	74 15                	je     800853 <strncmp+0x30>
  80083e:	0f b6 08             	movzbl (%eax),%ecx
  800841:	84 c9                	test   %cl,%cl
  800843:	74 04                	je     800849 <strncmp+0x26>
  800845:	3a 0a                	cmp    (%edx),%cl
  800847:	74 eb                	je     800834 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 00             	movzbl (%eax),%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
  800851:	eb 05                	jmp    800858 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800865:	eb 07                	jmp    80086e <strchr+0x13>
		if (*s == c)
  800867:	38 ca                	cmp    %cl,%dl
  800869:	74 0f                	je     80087a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
  800871:	84 d2                	test   %dl,%dl
  800873:	75 f2                	jne    800867 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800886:	eb 03                	jmp    80088b <strfind+0xf>
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088e:	84 d2                	test   %dl,%dl
  800890:	74 04                	je     800896 <strfind+0x1a>
  800892:	38 ca                	cmp    %cl,%dl
  800894:	75 f2                	jne    800888 <strfind+0xc>
			break;
	return (char *) s;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a4:	85 c9                	test   %ecx,%ecx
  8008a6:	74 36                	je     8008de <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ae:	75 28                	jne    8008d8 <memset+0x40>
  8008b0:	f6 c1 03             	test   $0x3,%cl
  8008b3:	75 23                	jne    8008d8 <memset+0x40>
		c &= 0xFF;
  8008b5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b9:	89 d3                	mov    %edx,%ebx
  8008bb:	c1 e3 08             	shl    $0x8,%ebx
  8008be:	89 d6                	mov    %edx,%esi
  8008c0:	c1 e6 18             	shl    $0x18,%esi
  8008c3:	89 d0                	mov    %edx,%eax
  8008c5:	c1 e0 10             	shl    $0x10,%eax
  8008c8:	09 f0                	or     %esi,%eax
  8008ca:	09 c2                	or     %eax,%edx
  8008cc:	89 d0                	mov    %edx,%eax
  8008ce:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d3:	fc                   	cld    
  8008d4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d6:	eb 06                	jmp    8008de <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	fc                   	cld    
  8008dc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008de:	89 f8                	mov    %edi,%eax
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f3:	39 c6                	cmp    %eax,%esi
  8008f5:	73 35                	jae    80092c <memmove+0x47>
  8008f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	73 2e                	jae    80092c <memmove+0x47>
		s += n;
		d += n;
  8008fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800901:	89 d6                	mov    %edx,%esi
  800903:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090b:	75 13                	jne    800920 <memmove+0x3b>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 09                	jmp    800929 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800926:	fd                   	std    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800929:	fc                   	cld    
  80092a:	eb 1d                	jmp    800949 <memmove+0x64>
  80092c:	89 f2                	mov    %esi,%edx
  80092e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	f6 c2 03             	test   $0x3,%dl
  800933:	75 0f                	jne    800944 <memmove+0x5f>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0a                	jne    800944 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	fc                   	cld    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 05                	jmp    800949 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800944:	89 c7                	mov    %eax,%edi
  800946:	fc                   	cld    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800950:	ff 75 10             	pushl  0x10(%ebp)
  800953:	ff 75 0c             	pushl  0xc(%ebp)
  800956:	ff 75 08             	pushl  0x8(%ebp)
  800959:	e8 87 ff ff ff       	call   8008e5 <memmove>
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096b:	89 c6                	mov    %eax,%esi
  80096d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800970:	eb 1a                	jmp    80098c <memcmp+0x2c>
		if (*s1 != *s2)
  800972:	0f b6 08             	movzbl (%eax),%ecx
  800975:	0f b6 1a             	movzbl (%edx),%ebx
  800978:	38 d9                	cmp    %bl,%cl
  80097a:	74 0a                	je     800986 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097c:	0f b6 c1             	movzbl %cl,%eax
  80097f:	0f b6 db             	movzbl %bl,%ebx
  800982:	29 d8                	sub    %ebx,%eax
  800984:	eb 0f                	jmp    800995 <memcmp+0x35>
		s1++, s2++;
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098c:	39 f0                	cmp    %esi,%eax
  80098e:	75 e2                	jne    800972 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a7:	eb 07                	jmp    8009b0 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	38 08                	cmp    %cl,(%eax)
  8009ab:	74 07                	je     8009b4 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	39 d0                	cmp    %edx,%eax
  8009b2:	72 f5                	jb     8009a9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c2:	eb 03                	jmp    8009c7 <strtol+0x11>
		s++;
  8009c4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c7:	0f b6 01             	movzbl (%ecx),%eax
  8009ca:	3c 09                	cmp    $0x9,%al
  8009cc:	74 f6                	je     8009c4 <strtol+0xe>
  8009ce:	3c 20                	cmp    $0x20,%al
  8009d0:	74 f2                	je     8009c4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d2:	3c 2b                	cmp    $0x2b,%al
  8009d4:	75 0a                	jne    8009e0 <strtol+0x2a>
		s++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009de:	eb 10                	jmp    8009f0 <strtol+0x3a>
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e5:	3c 2d                	cmp    $0x2d,%al
  8009e7:	75 07                	jne    8009f0 <strtol+0x3a>
		s++, neg = 1;
  8009e9:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009ec:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f0:	85 db                	test   %ebx,%ebx
  8009f2:	0f 94 c0             	sete   %al
  8009f5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fb:	75 19                	jne    800a16 <strtol+0x60>
  8009fd:	80 39 30             	cmpb   $0x30,(%ecx)
  800a00:	75 14                	jne    800a16 <strtol+0x60>
  800a02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a06:	0f 85 82 00 00 00    	jne    800a8e <strtol+0xd8>
		s += 2, base = 16;
  800a0c:	83 c1 02             	add    $0x2,%ecx
  800a0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a14:	eb 16                	jmp    800a2c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a16:	84 c0                	test   %al,%al
  800a18:	74 12                	je     800a2c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 08                	jne    800a2c <strtol+0x76>
		s++, base = 8;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	0f b6 11             	movzbl (%ecx),%edx
  800a37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 09             	cmp    $0x9,%bl
  800a3f:	77 08                	ja     800a49 <strtol+0x93>
			dig = *s - '0';
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 30             	sub    $0x30,%edx
  800a47:	eb 22                	jmp    800a6b <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 19             	cmp    $0x19,%bl
  800a51:	77 08                	ja     800a5b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a53:	0f be d2             	movsbl %dl,%edx
  800a56:	83 ea 57             	sub    $0x57,%edx
  800a59:	eb 10                	jmp    800a6b <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 19             	cmp    $0x19,%bl
  800a63:	77 16                	ja     800a7b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6e:	7d 0f                	jge    800a7f <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a79:	eb b9                	jmp    800a34 <strtol+0x7e>
  800a7b:	89 c2                	mov    %eax,%edx
  800a7d:	eb 02                	jmp    800a81 <strtol+0xcb>
  800a7f:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a85:	74 0d                	je     800a94 <strtol+0xde>
		*endptr = (char *) s;
  800a87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8a:	89 0e                	mov    %ecx,(%esi)
  800a8c:	eb 06                	jmp    800a94 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8e:	84 c0                	test   %al,%al
  800a90:	75 92                	jne    800a24 <strtol+0x6e>
  800a92:	eb 98                	jmp    800a2c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 03                	push   $0x3
  800b05:	68 c8 15 80 00       	push   $0x8015c8
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 e5 15 80 00       	push   $0x8015e5
  800b11:	e8 b6 04 00 00       	call   800fcc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 04                	push   $0x4
  800b86:	68 c8 15 80 00       	push   $0x8015c8
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 e5 15 80 00       	push   $0x8015e5
  800b92:	e8 35 04 00 00       	call   800fcc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 05                	push   $0x5
  800bc8:	68 c8 15 80 00       	push   $0x8015c8
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 e5 15 80 00       	push   $0x8015e5
  800bd4:	e8 f3 03 00 00       	call   800fcc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 06                	push   $0x6
  800c0a:	68 c8 15 80 00       	push   $0x8015c8
  800c0f:	6a 23                	push   $0x23
  800c11:	68 e5 15 80 00       	push   $0x8015e5
  800c16:	e8 b1 03 00 00       	call   800fcc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 08                	push   $0x8
  800c4c:	68 c8 15 80 00       	push   $0x8015c8
  800c51:	6a 23                	push   $0x23
  800c53:	68 e5 15 80 00       	push   $0x8015e5
  800c58:	e8 6f 03 00 00       	call   800fcc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 09                	push   $0x9
  800c8e:	68 c8 15 80 00       	push   $0x8015c8
  800c93:	6a 23                	push   $0x23
  800c95:	68 e5 15 80 00       	push   $0x8015e5
  800c9a:	e8 2d 03 00 00       	call   800fcc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	be 00 00 00 00       	mov    $0x0,%esi
  800cb2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 cb                	mov    %ecx,%ebx
  800ce2:	89 cf                	mov    %ecx,%edi
  800ce4:	89 ce                	mov    %ecx,%esi
  800ce6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 0c                	push   $0xc
  800cf2:	68 c8 15 80 00       	push   $0x8015c8
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 e5 15 80 00       	push   $0x8015e5
  800cfe:	e8 c9 02 00 00       	call   800fcc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 04             	sub    $0x4,%esp
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d15:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d17:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d1b:	74 2e                	je     800d4b <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	c1 ea 16             	shr    $0x16,%edx
  800d22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d29:	f6 c2 01             	test   $0x1,%dl
  800d2c:	74 1d                	je     800d4b <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	c1 ea 0c             	shr    $0xc,%edx
  800d33:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d3a:	f6 c1 01             	test   $0x1,%cl
  800d3d:	74 0c                	je     800d4b <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d46:	f6 c6 08             	test   $0x8,%dh
  800d49:	75 14                	jne    800d5f <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	68 f4 15 80 00       	push   $0x8015f4
  800d53:	6a 21                	push   $0x21
  800d55:	68 87 16 80 00       	push   $0x801687
  800d5a:	e8 6d 02 00 00       	call   800fcc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d64:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	6a 07                	push   $0x7
  800d6b:	68 00 f0 7f 00       	push   $0x7ff000
  800d70:	6a 00                	push   $0x0
  800d72:	e8 e5 fd ff ff       	call   800b5c <sys_page_alloc>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 14                	jns    800d92 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 92 16 80 00       	push   $0x801692
  800d86:	6a 2b                	push   $0x2b
  800d88:	68 87 16 80 00       	push   $0x801687
  800d8d:	e8 3a 02 00 00       	call   800fcc <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 00 10 00 00       	push   $0x1000
  800d9a:	53                   	push   %ebx
  800d9b:	68 00 f0 7f 00       	push   $0x7ff000
  800da0:	e8 40 fb ff ff       	call   8008e5 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800da5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dac:	53                   	push   %ebx
  800dad:	6a 00                	push   $0x0
  800daf:	68 00 f0 7f 00       	push   $0x7ff000
  800db4:	6a 00                	push   $0x0
  800db6:	e8 e4 fd ff ff       	call   800b9f <sys_page_map>
  800dbb:	83 c4 20             	add    $0x20,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	79 14                	jns    800dd6 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	68 a8 16 80 00       	push   $0x8016a8
  800dca:	6a 2e                	push   $0x2e
  800dcc:	68 87 16 80 00       	push   $0x801687
  800dd1:	e8 f6 01 00 00       	call   800fcc <_panic>
        sys_page_unmap(0, PFTEMP); 
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	68 00 f0 7f 00       	push   $0x7ff000
  800dde:	6a 00                	push   $0x0
  800de0:	e8 fc fd ff ff       	call   800be1 <sys_page_unmap>
  800de5:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800de8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800df6:	68 0b 0d 80 00       	push   $0x800d0b
  800dfb:	e8 12 02 00 00       	call   801012 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e00:	b8 07 00 00 00       	mov    $0x7,%eax
  800e05:	cd 30                	int    $0x30
  800e07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	79 12                	jns    800e23 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800e11:	50                   	push   %eax
  800e12:	68 bc 16 80 00       	push   $0x8016bc
  800e17:	6a 6d                	push   $0x6d
  800e19:	68 87 16 80 00       	push   $0x801687
  800e1e:	e8 a9 01 00 00       	call   800fcc <_panic>
  800e23:	89 c7                	mov    %eax,%edi
  800e25:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800e2a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e2e:	75 21                	jne    800e51 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e30:	e8 e9 fc ff ff       	call   800b1e <sys_getenvid>
  800e35:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e42:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4c:	e9 59 01 00 00       	jmp    800faa <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	c1 e8 16             	shr    $0x16,%eax
  800e56:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e5d:	a8 01                	test   $0x1,%al
  800e5f:	0f 84 b0 00 00 00    	je     800f15 <fork+0x128>
  800e65:	89 d8                	mov    %ebx,%eax
  800e67:	c1 e8 0c             	shr    $0xc,%eax
  800e6a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	0f 84 9b 00 00 00    	je     800f15 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800e7a:	89 c6                	mov    %eax,%esi
  800e7c:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800e7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e86:	f6 c6 08             	test   $0x8,%dh
  800e89:	75 0b                	jne    800e96 <fork+0xa9>
  800e8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e92:	a8 02                	test   $0x2,%al
  800e94:	74 57                	je     800eed <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	68 05 08 00 00       	push   $0x805
  800e9e:	56                   	push   %esi
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 f7 fc ff ff       	call   800b9f <sys_page_map>
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	79 12                	jns    800ec1 <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800eaf:	50                   	push   %eax
  800eb0:	68 18 16 80 00       	push   $0x801618
  800eb5:	6a 4a                	push   $0x4a
  800eb7:	68 87 16 80 00       	push   $0x801687
  800ebc:	e8 0b 01 00 00       	call   800fcc <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	68 05 08 00 00       	push   $0x805
  800ec9:	56                   	push   %esi
  800eca:	6a 00                	push   $0x0
  800ecc:	56                   	push   %esi
  800ecd:	6a 00                	push   $0x0
  800ecf:	e8 cb fc ff ff       	call   800b9f <sys_page_map>
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 3a                	jns    800f15 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800edb:	50                   	push   %eax
  800edc:	68 3c 16 80 00       	push   $0x80163c
  800ee1:	6a 4c                	push   $0x4c
  800ee3:	68 87 16 80 00       	push   $0x801687
  800ee8:	e8 df 00 00 00       	call   800fcc <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	6a 05                	push   $0x5
  800ef2:	56                   	push   %esi
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	6a 00                	push   $0x0
  800ef7:	e8 a3 fc ff ff       	call   800b9f <sys_page_map>
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 12                	jns    800f15 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 64 16 80 00       	push   $0x801664
  800f09:	6a 4f                	push   $0x4f
  800f0b:	68 87 16 80 00       	push   $0x801687
  800f10:	e8 b7 00 00 00       	call   800fcc <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800f15:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f1b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f21:	0f 85 2a ff ff ff    	jne    800e51 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	6a 07                	push   $0x7
  800f2c:	68 00 f0 bf ee       	push   $0xeebff000
  800f31:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f34:	e8 23 fc ff ff       	call   800b5c <sys_page_alloc>
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	79 14                	jns    800f54 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 cc 16 80 00       	push   $0x8016cc
  800f48:	6a 76                	push   $0x76
  800f4a:	68 87 16 80 00       	push   $0x801687
  800f4f:	e8 78 00 00 00       	call   800fcc <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	68 81 10 80 00       	push   $0x801081
  800f5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5f:	e8 01 fd ff ff       	call   800c65 <sys_env_set_pgfault_upcall>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 14                	jns    800f7f <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800f6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6e:	68 e6 16 80 00       	push   $0x8016e6
  800f73:	6a 79                	push   $0x79
  800f75:	68 87 16 80 00       	push   $0x801687
  800f7a:	e8 4d 00 00 00       	call   800fcc <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	6a 02                	push   $0x2
  800f84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f87:	e8 97 fc ff ff       	call   800c23 <sys_env_set_status>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 14                	jns    800fa7 <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f96:	68 03 17 80 00       	push   $0x801703
  800f9b:	6a 7b                	push   $0x7b
  800f9d:	68 87 16 80 00       	push   $0x801687
  800fa2:	e8 25 00 00 00       	call   800fcc <_panic>
        return forkid;
  800fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sfork>:

// Challenge!
int
sfork(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fb8:	68 1a 17 80 00       	push   $0x80171a
  800fbd:	68 83 00 00 00       	push   $0x83
  800fc2:	68 87 16 80 00       	push   $0x801687
  800fc7:	e8 00 00 00 00       	call   800fcc <_panic>

00800fcc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fda:	e8 3f fb ff ff       	call   800b1e <sys_getenvid>
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	ff 75 0c             	pushl  0xc(%ebp)
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	56                   	push   %esi
  800fe9:	50                   	push   %eax
  800fea:	68 30 17 80 00       	push   $0x801730
  800fef:	e8 d8 f1 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff4:	83 c4 18             	add    $0x18,%esp
  800ff7:	53                   	push   %ebx
  800ff8:	ff 75 10             	pushl  0x10(%ebp)
  800ffb:	e8 7b f1 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  801000:	c7 04 24 6f 13 80 00 	movl   $0x80136f,(%esp)
  801007:	e8 c0 f1 ff ff       	call   8001cc <cprintf>
  80100c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100f:	cc                   	int3   
  801010:	eb fd                	jmp    80100f <_panic+0x43>

00801012 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801018:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80101f:	75 2c                	jne    80104d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	6a 07                	push   $0x7
  801026:	68 00 f0 bf ee       	push   $0xeebff000
  80102b:	6a 00                	push   $0x0
  80102d:	e8 2a fb ff ff       	call   800b5c <sys_page_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	74 14                	je     80104d <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	68 54 17 80 00       	push   $0x801754
  801041:	6a 21                	push   $0x21
  801043:	68 b8 17 80 00       	push   $0x8017b8
  801048:	e8 7f ff ff ff       	call   800fcc <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801055:	83 ec 08             	sub    $0x8,%esp
  801058:	68 81 10 80 00       	push   $0x801081
  80105d:	6a 00                	push   $0x0
  80105f:	e8 01 fc ff ff       	call   800c65 <sys_env_set_pgfault_upcall>
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	79 14                	jns    80107f <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	68 80 17 80 00       	push   $0x801780
  801073:	6a 29                	push   $0x29
  801075:	68 b8 17 80 00       	push   $0x8017b8
  80107a:	e8 4d ff ff ff       	call   800fcc <_panic>
}
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801081:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801082:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801087:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801089:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80108c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801091:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801095:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801099:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80109b:	83 c4 08             	add    $0x8,%esp
        popal
  80109e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80109f:	83 c4 04             	add    $0x4,%esp
        popfl
  8010a2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8010a3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8010a4:	c3                   	ret    
  8010a5:	66 90                	xchg   %ax,%ax
  8010a7:	66 90                	xchg   %ax,%ax
  8010a9:	66 90                	xchg   %ax,%ax
  8010ab:	66 90                	xchg   %ax,%ax
  8010ad:	66 90                	xchg   %ax,%ax
  8010af:	90                   	nop

008010b0 <__udivdi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	83 ec 10             	sub    $0x10,%esp
  8010b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8010ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8010be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010c6:	85 d2                	test   %edx,%edx
  8010c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010cc:	89 34 24             	mov    %esi,(%esp)
  8010cf:	89 c8                	mov    %ecx,%eax
  8010d1:	75 35                	jne    801108 <__udivdi3+0x58>
  8010d3:	39 f1                	cmp    %esi,%ecx
  8010d5:	0f 87 bd 00 00 00    	ja     801198 <__udivdi3+0xe8>
  8010db:	85 c9                	test   %ecx,%ecx
  8010dd:	89 cd                	mov    %ecx,%ebp
  8010df:	75 0b                	jne    8010ec <__udivdi3+0x3c>
  8010e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e6:	31 d2                	xor    %edx,%edx
  8010e8:	f7 f1                	div    %ecx
  8010ea:	89 c5                	mov    %eax,%ebp
  8010ec:	89 f0                	mov    %esi,%eax
  8010ee:	31 d2                	xor    %edx,%edx
  8010f0:	f7 f5                	div    %ebp
  8010f2:	89 c6                	mov    %eax,%esi
  8010f4:	89 f8                	mov    %edi,%eax
  8010f6:	f7 f5                	div    %ebp
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	3b 14 24             	cmp    (%esp),%edx
  80110b:	77 7b                	ja     801188 <__udivdi3+0xd8>
  80110d:	0f bd f2             	bsr    %edx,%esi
  801110:	83 f6 1f             	xor    $0x1f,%esi
  801113:	0f 84 97 00 00 00    	je     8011b0 <__udivdi3+0x100>
  801119:	bd 20 00 00 00       	mov    $0x20,%ebp
  80111e:	89 d7                	mov    %edx,%edi
  801120:	89 f1                	mov    %esi,%ecx
  801122:	29 f5                	sub    %esi,%ebp
  801124:	d3 e7                	shl    %cl,%edi
  801126:	89 c2                	mov    %eax,%edx
  801128:	89 e9                	mov    %ebp,%ecx
  80112a:	d3 ea                	shr    %cl,%edx
  80112c:	89 f1                	mov    %esi,%ecx
  80112e:	09 fa                	or     %edi,%edx
  801130:	8b 3c 24             	mov    (%esp),%edi
  801133:	d3 e0                	shl    %cl,%eax
  801135:	89 54 24 08          	mov    %edx,0x8(%esp)
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801143:	89 fa                	mov    %edi,%edx
  801145:	d3 ea                	shr    %cl,%edx
  801147:	89 f1                	mov    %esi,%ecx
  801149:	d3 e7                	shl    %cl,%edi
  80114b:	89 e9                	mov    %ebp,%ecx
  80114d:	d3 e8                	shr    %cl,%eax
  80114f:	09 c7                	or     %eax,%edi
  801151:	89 f8                	mov    %edi,%eax
  801153:	f7 74 24 08          	divl   0x8(%esp)
  801157:	89 d5                	mov    %edx,%ebp
  801159:	89 c7                	mov    %eax,%edi
  80115b:	f7 64 24 0c          	mull   0xc(%esp)
  80115f:	39 d5                	cmp    %edx,%ebp
  801161:	89 14 24             	mov    %edx,(%esp)
  801164:	72 11                	jb     801177 <__udivdi3+0xc7>
  801166:	8b 54 24 04          	mov    0x4(%esp),%edx
  80116a:	89 f1                	mov    %esi,%ecx
  80116c:	d3 e2                	shl    %cl,%edx
  80116e:	39 c2                	cmp    %eax,%edx
  801170:	73 5e                	jae    8011d0 <__udivdi3+0x120>
  801172:	3b 2c 24             	cmp    (%esp),%ebp
  801175:	75 59                	jne    8011d0 <__udivdi3+0x120>
  801177:	8d 47 ff             	lea    -0x1(%edi),%eax
  80117a:	31 f6                	xor    %esi,%esi
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    
  801185:	8d 76 00             	lea    0x0(%esi),%esi
  801188:	31 f6                	xor    %esi,%esi
  80118a:	31 c0                	xor    %eax,%eax
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    
  801195:	8d 76 00             	lea    0x0(%esi),%esi
  801198:	89 f2                	mov    %esi,%edx
  80119a:	31 f6                	xor    %esi,%esi
  80119c:	89 f8                	mov    %edi,%eax
  80119e:	f7 f1                	div    %ecx
  8011a0:	89 f2                	mov    %esi,%edx
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8011b4:	76 0b                	jbe    8011c1 <__udivdi3+0x111>
  8011b6:	31 c0                	xor    %eax,%eax
  8011b8:	3b 14 24             	cmp    (%esp),%edx
  8011bb:	0f 83 37 ff ff ff    	jae    8010f8 <__udivdi3+0x48>
  8011c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c6:	e9 2d ff ff ff       	jmp    8010f8 <__udivdi3+0x48>
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 f8                	mov    %edi,%eax
  8011d2:	31 f6                	xor    %esi,%esi
  8011d4:	e9 1f ff ff ff       	jmp    8010f8 <__udivdi3+0x48>
  8011d9:	66 90                	xchg   %ax,%ax
  8011db:	66 90                	xchg   %ax,%ax
  8011dd:	66 90                	xchg   %ax,%ax
  8011df:	90                   	nop

008011e0 <__umoddi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	83 ec 20             	sub    $0x20,%esp
  8011e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8011ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011f2:	89 c6                	mov    %eax,%esi
  8011f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801200:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801204:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801208:	89 74 24 18          	mov    %esi,0x18(%esp)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	89 c2                	mov    %eax,%edx
  801210:	75 1e                	jne    801230 <__umoddi3+0x50>
  801212:	39 f7                	cmp    %esi,%edi
  801214:	76 52                	jbe    801268 <__umoddi3+0x88>
  801216:	89 c8                	mov    %ecx,%eax
  801218:	89 f2                	mov    %esi,%edx
  80121a:	f7 f7                	div    %edi
  80121c:	89 d0                	mov    %edx,%eax
  80121e:	31 d2                	xor    %edx,%edx
  801220:	83 c4 20             	add    $0x20,%esp
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    
  801227:	89 f6                	mov    %esi,%esi
  801229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801230:	39 f0                	cmp    %esi,%eax
  801232:	77 5c                	ja     801290 <__umoddi3+0xb0>
  801234:	0f bd e8             	bsr    %eax,%ebp
  801237:	83 f5 1f             	xor    $0x1f,%ebp
  80123a:	75 64                	jne    8012a0 <__umoddi3+0xc0>
  80123c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801240:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801244:	0f 86 f6 00 00 00    	jbe    801340 <__umoddi3+0x160>
  80124a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80124e:	0f 82 ec 00 00 00    	jb     801340 <__umoddi3+0x160>
  801254:	8b 44 24 14          	mov    0x14(%esp),%eax
  801258:	8b 54 24 18          	mov    0x18(%esp),%edx
  80125c:	83 c4 20             	add    $0x20,%esp
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
  801263:	90                   	nop
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	85 ff                	test   %edi,%edi
  80126a:	89 fd                	mov    %edi,%ebp
  80126c:	75 0b                	jne    801279 <__umoddi3+0x99>
  80126e:	b8 01 00 00 00       	mov    $0x1,%eax
  801273:	31 d2                	xor    %edx,%edx
  801275:	f7 f7                	div    %edi
  801277:	89 c5                	mov    %eax,%ebp
  801279:	8b 44 24 10          	mov    0x10(%esp),%eax
  80127d:	31 d2                	xor    %edx,%edx
  80127f:	f7 f5                	div    %ebp
  801281:	89 c8                	mov    %ecx,%eax
  801283:	f7 f5                	div    %ebp
  801285:	eb 95                	jmp    80121c <__umoddi3+0x3c>
  801287:	89 f6                	mov    %esi,%esi
  801289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 f2                	mov    %esi,%edx
  801294:	83 c4 20             	add    $0x20,%esp
  801297:	5e                   	pop    %esi
  801298:	5f                   	pop    %edi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    
  80129b:	90                   	nop
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a5:	89 e9                	mov    %ebp,%ecx
  8012a7:	29 e8                	sub    %ebp,%eax
  8012a9:	d3 e2                	shl    %cl,%edx
  8012ab:	89 c7                	mov    %eax,%edi
  8012ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8012b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012b5:	89 f9                	mov    %edi,%ecx
  8012b7:	d3 e8                	shr    %cl,%eax
  8012b9:	89 c1                	mov    %eax,%ecx
  8012bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012bf:	09 d1                	or     %edx,%ecx
  8012c1:	89 fa                	mov    %edi,%edx
  8012c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012c7:	89 e9                	mov    %ebp,%ecx
  8012c9:	d3 e0                	shl    %cl,%eax
  8012cb:	89 f9                	mov    %edi,%ecx
  8012cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d1:	89 f0                	mov    %esi,%eax
  8012d3:	d3 e8                	shr    %cl,%eax
  8012d5:	89 e9                	mov    %ebp,%ecx
  8012d7:	89 c7                	mov    %eax,%edi
  8012d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012dd:	d3 e6                	shl    %cl,%esi
  8012df:	89 d1                	mov    %edx,%ecx
  8012e1:	89 fa                	mov    %edi,%edx
  8012e3:	d3 e8                	shr    %cl,%eax
  8012e5:	89 e9                	mov    %ebp,%ecx
  8012e7:	09 f0                	or     %esi,%eax
  8012e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8012ed:	f7 74 24 10          	divl   0x10(%esp)
  8012f1:	d3 e6                	shl    %cl,%esi
  8012f3:	89 d1                	mov    %edx,%ecx
  8012f5:	f7 64 24 0c          	mull   0xc(%esp)
  8012f9:	39 d1                	cmp    %edx,%ecx
  8012fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8012ff:	89 d7                	mov    %edx,%edi
  801301:	89 c6                	mov    %eax,%esi
  801303:	72 0a                	jb     80130f <__umoddi3+0x12f>
  801305:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801309:	73 10                	jae    80131b <__umoddi3+0x13b>
  80130b:	39 d1                	cmp    %edx,%ecx
  80130d:	75 0c                	jne    80131b <__umoddi3+0x13b>
  80130f:	89 d7                	mov    %edx,%edi
  801311:	89 c6                	mov    %eax,%esi
  801313:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801317:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80131b:	89 ca                	mov    %ecx,%edx
  80131d:	89 e9                	mov    %ebp,%ecx
  80131f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801323:	29 f0                	sub    %esi,%eax
  801325:	19 fa                	sbb    %edi,%edx
  801327:	d3 e8                	shr    %cl,%eax
  801329:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80132e:	89 d7                	mov    %edx,%edi
  801330:	d3 e7                	shl    %cl,%edi
  801332:	89 e9                	mov    %ebp,%ecx
  801334:	09 f8                	or     %edi,%eax
  801336:	d3 ea                	shr    %cl,%edx
  801338:	83 c4 20             	add    $0x20,%esp
  80133b:	5e                   	pop    %esi
  80133c:	5f                   	pop    %edi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    
  80133f:	90                   	nop
  801340:	8b 74 24 10          	mov    0x10(%esp),%esi
  801344:	29 f9                	sub    %edi,%ecx
  801346:	19 c6                	sbb    %eax,%esi
  801348:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80134c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801350:	e9 ff fe ff ff       	jmp    801254 <__umoddi3+0x74>
