
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 40 21 80 00       	push   $0x802140
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
  800048:	83 c4 10             	add    $0x10,%esp
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 15 0d 00 00       	call   800d81 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 1b 0d 00 00       	call   800db1 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 17 13 00 00       	call   8013c9 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 54 21 80 00       	push   $0x802154
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 0f 17 00 00       	call   8017e9 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 54 21 80 00       	push   $0x802154
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800118:	e8 35 0a 00 00       	call   800b52 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
  800149:	83 c4 10             	add    $0x10,%esp
}
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 44 0f 00 00       	call   8010a2 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 a9 09 00 00       	call   800b11 <sys_env_destroy>
  800168:	83 c4 10             	add    $0x10,%esp
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 37 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 4f 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 dc 08 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 d1                	mov    %edx,%ecx
  800229:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022f:	8b 45 10             	mov    0x10(%ebp),%eax
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800238:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800242:	72 05                	jb     800249 <printnum+0x35>
  800244:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800247:	77 3e                	ja     800287 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	83 eb 01             	sub    $0x1,%ebx
  800252:	53                   	push   %ebx
  800253:	50                   	push   %eax
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 08 1c 00 00       	call   801e70 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 13                	jmp    80028e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f ed                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 fa 1c 00 00       	call   801fa0 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 86 21 80 00 	movsbl 0x802186(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
  8002b3:	83 c4 10             	add    $0x10,%esp
}
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
  80032d:	83 c4 10             	add    $0x10,%esp
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 12                	jmp    800358 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 90 03 00 00    	je     8006de <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	53                   	push   %ebx
  800352:	50                   	push   %eax
  800353:	ff d6                	call   *%esi
  800355:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800358:	83 c7 01             	add    $0x1,%edi
  80035b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e2                	jne    800346 <vprintfmt+0x14>
  800364:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800368:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 07                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 07             	movzbl (%edi),%eax
  800394:	0f b6 c8             	movzbl %al,%ecx
  800397:	83 e8 23             	sub    $0x23,%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 21 03 00 00    	ja     8006c3 <vprintfmt+0x391>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b3:	eb d6                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cd:	83 fa 09             	cmp    $0x9,%edx
  8003d0:	77 39                	ja     80040b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 27                	jmp    800411 <vprintfmt+0xdf>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f4:	0f 49 c8             	cmovns %eax,%ecx
  8003f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fd:	eb 8c                	jmp    80038b <vprintfmt+0x59>
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800409:	eb 80                	jmp    80038b <vprintfmt+0x59>
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 89 70 ff ff ff    	jns    80038b <vprintfmt+0x59>
				width = precision, precision = -1;
  80041b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800421:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800428:	e9 5e ff ff ff       	jmp    80038b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 53 ff ff ff       	jmp    80038b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 30                	pushl  (%eax)
  800447:	ff d6                	call   *%esi
			break;
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044f:	e9 04 ff ff ff       	jmp    800358 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	99                   	cltd   
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 0f             	cmp    $0xf,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x142>
  800469:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 18                	jne    80048c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 9e 21 80 00       	push   $0x80219e
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 94 fe ff ff       	call   800315 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 cc fe ff ff       	jmp    800358 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	52                   	push   %edx
  80048d:	68 71 25 80 00       	push   $0x802571
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 7c fe ff ff       	call   800315 <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	e9 b4 fe ff ff       	jmp    800358 <vprintfmt+0x26>
  8004a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	ba 97 21 80 00       	mov    $0x802197,%edx
  8004bf:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004c2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c6:	0f 84 92 00 00 00    	je     80055e <vprintfmt+0x22c>
  8004cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d0:	0f 8e 96 00 00 00    	jle    80056c <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	51                   	push   %ecx
  8004da:	57                   	push   %edi
  8004db:	e8 86 02 00 00       	call   800766 <strnlen>
  8004e0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e3:	29 c1                	sub    %eax,%ecx
  8004e5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004eb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	eb 0f                	jmp    800508 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800500:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	83 ef 01             	sub    $0x1,%edi
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 ff                	test   %edi,%edi
  80050a:	7f ed                	jg     8004f9 <vprintfmt+0x1c7>
  80050c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800512:	85 c9                	test   %ecx,%ecx
  800514:	b8 00 00 00 00       	mov    $0x0,%eax
  800519:	0f 49 c1             	cmovns %ecx,%eax
  80051c:	29 c1                	sub    %eax,%ecx
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	89 cb                	mov    %ecx,%ebx
  800529:	eb 4d                	jmp    800578 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052f:	74 1b                	je     80054c <vprintfmt+0x21a>
  800531:	0f be c0             	movsbl %al,%eax
  800534:	83 e8 20             	sub    $0x20,%eax
  800537:	83 f8 5e             	cmp    $0x5e,%eax
  80053a:	76 10                	jbe    80054c <vprintfmt+0x21a>
					putch('?', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	6a 3f                	push   $0x3f
  800544:	ff 55 08             	call   *0x8(%ebp)
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	eb 0d                	jmp    800559 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	52                   	push   %edx
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	83 eb 01             	sub    $0x1,%ebx
  80055c:	eb 1a                	jmp    800578 <vprintfmt+0x246>
  80055e:	89 75 08             	mov    %esi,0x8(%ebp)
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800564:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800567:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056a:	eb 0c                	jmp    800578 <vprintfmt+0x246>
  80056c:	89 75 08             	mov    %esi,0x8(%ebp)
  80056f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800572:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800575:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800578:	83 c7 01             	add    $0x1,%edi
  80057b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057f:	0f be d0             	movsbl %al,%edx
  800582:	85 d2                	test   %edx,%edx
  800584:	74 23                	je     8005a9 <vprintfmt+0x277>
  800586:	85 f6                	test   %esi,%esi
  800588:	78 a1                	js     80052b <vprintfmt+0x1f9>
  80058a:	83 ee 01             	sub    $0x1,%esi
  80058d:	79 9c                	jns    80052b <vprintfmt+0x1f9>
  80058f:	89 df                	mov    %ebx,%edi
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800597:	eb 18                	jmp    8005b1 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	6a 20                	push   $0x20
  80059f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a1:	83 ef 01             	sub    $0x1,%edi
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 08                	jmp    8005b1 <vprintfmt+0x27f>
  8005a9:	89 df                	mov    %ebx,%edi
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	7f e4                	jg     800599 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 9b fd ff ff       	jmp    800358 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bd:	83 fa 01             	cmp    $0x1,%edx
  8005c0:	7e 16                	jle    8005d8 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 08             	lea    0x8(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	eb 32                	jmp    80060a <vprintfmt+0x2d8>
	else if (lflag)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 18                	je     8005f4 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f2:	eb 16                	jmp    80060a <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800610:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800615:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800619:	79 74                	jns    80068f <vprintfmt+0x35d>
				putch('-', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 2d                	push   $0x2d
  800621:	ff d6                	call   *%esi
				num = -(long long) num;
  800623:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800626:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800629:	f7 d8                	neg    %eax
  80062b:	83 d2 00             	adc    $0x0,%edx
  80062e:	f7 da                	neg    %edx
  800630:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800638:	eb 55                	jmp    80068f <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 7c fc ff ff       	call   8002be <getuint>
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800647:	eb 46                	jmp    80068f <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 6d fc ff ff       	call   8002be <getuint>
                        base = 8;
  800651:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800656:	eb 37                	jmp    80068f <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 30                	push   $0x30
  80065e:	ff d6                	call   *%esi
			putch('x', putdat);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 78                	push   $0x78
  800666:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800680:	eb 0d                	jmp    80068f <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 34 fc ff ff       	call   8002be <getuint>
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800696:	57                   	push   %edi
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	51                   	push   %ecx
  80069b:	52                   	push   %edx
  80069c:	50                   	push   %eax
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 6e fb ff ff       	call   800214 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ac:	e9 a7 fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	51                   	push   %ecx
  8006b6:	ff d6                	call   *%esi
			break;
  8006b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006be:	e9 95 fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 25                	push   $0x25
  8006c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 03                	jmp    8006d3 <vprintfmt+0x3a1>
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d7:	75 f7                	jne    8006d0 <vprintfmt+0x39e>
  8006d9:	e9 7a fc ff ff       	jmp    800358 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5f                   	pop    %edi
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 18             	sub    $0x18,%esp
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 26                	je     80072d <vsnprintf+0x47>
  800707:	85 d2                	test   %edx,%edx
  800709:	7e 22                	jle    80072d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070b:	ff 75 14             	pushl  0x14(%ebp)
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800714:	50                   	push   %eax
  800715:	68 f8 02 80 00       	push   $0x8002f8
  80071a:	e8 13 fc ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800722:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 05                	jmp    800732 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	ff 75 08             	pushl  0x8(%ebp)
  800747:	e8 9a ff ff ff       	call   8006e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 03                	jmp    80075e <strlen+0x10>
		n++;
  80075b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	75 f7                	jne    80075b <strlen+0xd>
		n++;
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
  800774:	eb 03                	jmp    800779 <strnlen+0x13>
		n++;
  800776:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	39 c2                	cmp    %eax,%edx
  80077b:	74 08                	je     800785 <strnlen+0x1f>
  80077d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800781:	75 f3                	jne    800776 <strnlen+0x10>
  800783:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	75 ef                	jne    800793 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 9a ff ff ff       	call   80074e <strlen>
  8007b4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 c5 ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d4:	89 f3                	mov    %esi,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	89 f2                	mov    %esi,%edx
  8007db:	eb 0f                	jmp    8007ec <strncpy+0x23>
		*dst++ = *src;
  8007dd:	83 c2 01             	add    $0x1,%edx
  8007e0:	0f b6 01             	movzbl (%ecx),%eax
  8007e3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	39 da                	cmp    %ebx,%edx
  8007ee:	75 ed                	jne    8007dd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
  800804:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	85 d2                	test   %edx,%edx
  800808:	74 21                	je     80082b <strlcpy+0x35>
  80080a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080e:	89 f2                	mov    %esi,%edx
  800810:	eb 09                	jmp    80081b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081b:	39 c2                	cmp    %eax,%edx
  80081d:	74 09                	je     800828 <strlcpy+0x32>
  80081f:	0f b6 19             	movzbl (%ecx),%ebx
  800822:	84 db                	test   %bl,%bl
  800824:	75 ec                	jne    800812 <strlcpy+0x1c>
  800826:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800828:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082b:	29 f0                	sub    %esi,%eax
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083a:	eb 06                	jmp    800842 <strcmp+0x11>
		p++, q++;
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	84 c0                	test   %al,%al
  800847:	74 04                	je     80084d <strcmp+0x1c>
  800849:	3a 02                	cmp    (%edx),%al
  80084b:	74 ef                	je     80083c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 c3                	mov    %eax,%ebx
  800863:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800866:	eb 06                	jmp    80086e <strncmp+0x17>
		n--, p++, q++;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086e:	39 d8                	cmp    %ebx,%eax
  800870:	74 15                	je     800887 <strncmp+0x30>
  800872:	0f b6 08             	movzbl (%eax),%ecx
  800875:	84 c9                	test   %cl,%cl
  800877:	74 04                	je     80087d <strncmp+0x26>
  800879:	3a 0a                	cmp    (%edx),%cl
  80087b:	74 eb                	je     800868 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 00             	movzbl (%eax),%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
  800885:	eb 05                	jmp    80088c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800899:	eb 07                	jmp    8008a2 <strchr+0x13>
		if (*s == c)
  80089b:	38 ca                	cmp    %cl,%dl
  80089d:	74 0f                	je     8008ae <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f2                	jne    80089b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	eb 03                	jmp    8008bf <strfind+0xf>
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	74 04                	je     8008ca <strfind+0x1a>
  8008c6:	38 ca                	cmp    %cl,%dl
  8008c8:	75 f2                	jne    8008bc <strfind+0xc>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 36                	je     800912 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 28                	jne    80090c <memset+0x40>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 23                	jne    80090c <memset+0x40>
		c &= 0xFF;
  8008e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 08             	shl    $0x8,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 18             	shl    $0x18,%esi
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 10             	shl    $0x10,%eax
  8008fc:	09 f0                	or     %esi,%eax
  8008fe:	09 c2                	or     %eax,%edx
  800900:	89 d0                	mov    %edx,%eax
  800902:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800904:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800907:	fc                   	cld    
  800908:	f3 ab                	rep stos %eax,%es:(%edi)
  80090a:	eb 06                	jmp    800912 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	fc                   	cld    
  800910:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800912:	89 f8                	mov    %edi,%eax
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 75 0c             	mov    0xc(%ebp),%esi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800927:	39 c6                	cmp    %eax,%esi
  800929:	73 35                	jae    800960 <memmove+0x47>
  80092b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092e:	39 d0                	cmp    %edx,%eax
  800930:	73 2e                	jae    800960 <memmove+0x47>
		s += n;
		d += n;
  800932:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800935:	89 d6                	mov    %edx,%esi
  800937:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093f:	75 13                	jne    800954 <memmove+0x3b>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0e                	jne    800954 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 09                	jmp    80095d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 1d                	jmp    80097d <memmove+0x64>
  800960:	89 f2                	mov    %esi,%edx
  800962:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	f6 c2 03             	test   $0x3,%dl
  800967:	75 0f                	jne    800978 <memmove+0x5f>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0a                	jne    800978 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 87 ff ff ff       	call   800919 <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 c6                	mov    %eax,%esi
  8009a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	eb 1a                	jmp    8009c0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	74 0a                	je     8009ba <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b0:	0f b6 c1             	movzbl %cl,%eax
  8009b3:	0f b6 db             	movzbl %bl,%ebx
  8009b6:	29 d8                	sub    %ebx,%eax
  8009b8:	eb 0f                	jmp    8009c9 <memcmp+0x35>
		s1++, s2++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	39 f0                	cmp    %esi,%eax
  8009c2:	75 e2                	jne    8009a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009db:	eb 07                	jmp    8009e4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	38 08                	cmp    %cl,(%eax)
  8009df:	74 07                	je     8009e8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	72 f5                	jb     8009dd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	eb 03                	jmp    8009fb <strtol+0x11>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f6                	je     8009f8 <strtol+0xe>
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f2                	je     8009f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a06:	3c 2b                	cmp    $0x2b,%al
  800a08:	75 0a                	jne    800a14 <strtol+0x2a>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a12:	eb 10                	jmp    800a24 <strtol+0x3a>
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	75 07                	jne    800a24 <strtol+0x3a>
		s++, neg = 1;
  800a1d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a20:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	85 db                	test   %ebx,%ebx
  800a26:	0f 94 c0             	sete   %al
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 19                	jne    800a4a <strtol+0x60>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 14                	jne    800a4a <strtol+0x60>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	0f 85 82 00 00 00    	jne    800ac2 <strtol+0xd8>
		s += 2, base = 16;
  800a40:	83 c1 02             	add    $0x2,%ecx
  800a43:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a48:	eb 16                	jmp    800a60 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4a:	84 c0                	test   %al,%al
  800a4c:	74 12                	je     800a60 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	75 08                	jne    800a60 <strtol+0x76>
		s++, base = 8;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a68:	0f b6 11             	movzbl (%ecx),%edx
  800a6b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 09             	cmp    $0x9,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x93>
			dig = *s - '0';
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 30             	sub    $0x30,%edx
  800a7b:	eb 22                	jmp    800a9f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 08                	ja     800a8f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 57             	sub    $0x57,%edx
  800a8d:	eb 10                	jmp    800a9f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 16                	ja     800aaf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa2:	7d 0f                	jge    800ab3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aab:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aad:	eb b9                	jmp    800a68 <strtol+0x7e>
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	eb 02                	jmp    800ab5 <strtol+0xcb>
  800ab3:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 0d                	je     800ac8 <strtol+0xde>
		*endptr = (char *) s;
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	89 0e                	mov    %ecx,(%esi)
  800ac0:	eb 06                	jmp    800ac8 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac2:	84 c0                	test   %al,%al
  800ac4:	75 92                	jne    800a58 <strtol+0x6e>
  800ac6:	eb 98                	jmp    800a60 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac8:	f7 da                	neg    %edx
  800aca:	85 ff                	test   %edi,%edi
  800acc:	0f 45 c2             	cmovne %edx,%eax
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 17                	jle    800b4a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	83 ec 0c             	sub    $0xc,%esp
  800b36:	50                   	push   %eax
  800b37:	6a 03                	push   $0x3
  800b39:	68 9f 24 80 00       	push   $0x80249f
  800b3e:	6a 23                	push   $0x23
  800b40:	68 bc 24 80 00       	push   $0x8024bc
  800b45:	e8 a8 11 00 00       	call   801cf2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_yield>:

void
sys_yield(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	be 00 00 00 00       	mov    $0x0,%esi
  800b9e:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bac:	89 f7                	mov    %esi,%edi
  800bae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 04                	push   $0x4
  800bba:	68 9f 24 80 00       	push   $0x80249f
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 bc 24 80 00       	push   $0x8024bc
  800bc6:	e8 27 11 00 00       	call   801cf2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	b8 05 00 00 00       	mov    $0x5,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bed:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 05                	push   $0x5
  800bfc:	68 9f 24 80 00       	push   $0x80249f
  800c01:	6a 23                	push   $0x23
  800c03:	68 bc 24 80 00       	push   $0x8024bc
  800c08:	e8 e5 10 00 00       	call   801cf2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	b8 06 00 00 00       	mov    $0x6,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 06                	push   $0x6
  800c3e:	68 9f 24 80 00       	push   $0x80249f
  800c43:	6a 23                	push   $0x23
  800c45:	68 bc 24 80 00       	push   $0x8024bc
  800c4a:	e8 a3 10 00 00       	call   801cf2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 08                	push   $0x8
  800c80:	68 9f 24 80 00       	push   $0x80249f
  800c85:	6a 23                	push   $0x23
  800c87:	68 bc 24 80 00       	push   $0x8024bc
  800c8c:	e8 61 10 00 00       	call   801cf2 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 09                	push   $0x9
  800cc2:	68 9f 24 80 00       	push   $0x80249f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 bc 24 80 00       	push   $0x8024bc
  800cce:	e8 1f 10 00 00       	call   801cf2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 0a                	push   $0xa
  800d04:	68 9f 24 80 00       	push   $0x80249f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 bc 24 80 00       	push   $0x8024bc
  800d10:	e8 dd 0f 00 00       	call   801cf2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	be 00 00 00 00       	mov    $0x0,%esi
  800d28:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d39:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 cb                	mov    %ecx,%ebx
  800d58:	89 cf                	mov    %ecx,%edi
  800d5a:	89 ce                	mov    %ecx,%esi
  800d5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0d                	push   $0xd
  800d68:	68 9f 24 80 00       	push   $0x80249f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 bc 24 80 00       	push   $0x8024bc
  800d74:	e8 79 0f 00 00       	call   801cf2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800d8d:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800d8f:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800d92:	83 3a 01             	cmpl   $0x1,(%edx)
  800d95:	7e 09                	jle    800da0 <argstart+0x1f>
  800d97:	ba 51 21 80 00       	mov    $0x802151,%edx
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	75 05                	jne    800da5 <argstart+0x24>
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800da8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <argnext>:

int
argnext(struct Argstate *args)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dbb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dc2:	8b 43 08             	mov    0x8(%ebx),%eax
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	74 6f                	je     800e38 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800dc9:	80 38 00             	cmpb   $0x0,(%eax)
  800dcc:	75 4e                	jne    800e1c <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800dce:	8b 0b                	mov    (%ebx),%ecx
  800dd0:	83 39 01             	cmpl   $0x1,(%ecx)
  800dd3:	74 55                	je     800e2a <argnext+0x79>
		    || args->argv[1][0] != '-'
  800dd5:	8b 53 04             	mov    0x4(%ebx),%edx
  800dd8:	8b 42 04             	mov    0x4(%edx),%eax
  800ddb:	80 38 2d             	cmpb   $0x2d,(%eax)
  800dde:	75 4a                	jne    800e2a <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800de0:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800de4:	74 44                	je     800e2a <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800de6:	83 c0 01             	add    $0x1,%eax
  800de9:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	8b 01                	mov    (%ecx),%eax
  800df1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800df8:	50                   	push   %eax
  800df9:	8d 42 08             	lea    0x8(%edx),%eax
  800dfc:	50                   	push   %eax
  800dfd:	83 c2 04             	add    $0x4,%edx
  800e00:	52                   	push   %edx
  800e01:	e8 13 fb ff ff       	call   800919 <memmove>
		(*args->argc)--;
  800e06:	8b 03                	mov    (%ebx),%eax
  800e08:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e0b:	8b 43 08             	mov    0x8(%ebx),%eax
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e14:	75 06                	jne    800e1c <argnext+0x6b>
  800e16:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e1a:	74 0e                	je     800e2a <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e1c:	8b 53 08             	mov    0x8(%ebx),%edx
  800e1f:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e22:	83 c2 01             	add    $0x1,%edx
  800e25:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e28:	eb 13                	jmp    800e3d <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e2a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e36:	eb 05                	jmp    800e3d <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	53                   	push   %ebx
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e4c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	74 58                	je     800eab <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e53:	80 38 00             	cmpb   $0x0,(%eax)
  800e56:	74 0c                	je     800e64 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e58:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e5b:	c7 43 08 51 21 80 00 	movl   $0x802151,0x8(%ebx)
  800e62:	eb 42                	jmp    800ea6 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e64:	8b 13                	mov    (%ebx),%edx
  800e66:	83 3a 01             	cmpl   $0x1,(%edx)
  800e69:	7e 2d                	jle    800e98 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e6b:	8b 43 04             	mov    0x4(%ebx),%eax
  800e6e:	8b 48 04             	mov    0x4(%eax),%ecx
  800e71:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	8b 12                	mov    (%edx),%edx
  800e79:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e80:	52                   	push   %edx
  800e81:	8d 50 08             	lea    0x8(%eax),%edx
  800e84:	52                   	push   %edx
  800e85:	83 c0 04             	add    $0x4,%eax
  800e88:	50                   	push   %eax
  800e89:	e8 8b fa ff ff       	call   800919 <memmove>
		(*args->argc)--;
  800e8e:	8b 03                	mov    (%ebx),%eax
  800e90:	83 28 01             	subl   $0x1,(%eax)
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	eb 0e                	jmp    800ea6 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800e98:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800e9f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ea6:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ea9:	eb 05                	jmp    800eb0 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ebe:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ec1:	89 d0                	mov    %edx,%eax
  800ec3:	85 d2                	test   %edx,%edx
  800ec5:	75 0c                	jne    800ed3 <argvalue+0x1e>
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	51                   	push   %ecx
  800ecb:	e8 72 ff ff ff       	call   800e42 <argnextvalue>
  800ed0:	83 c4 10             	add    $0x10,%esp
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee0:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ef0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ef5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f02:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f07:	89 c2                	mov    %eax,%edx
  800f09:	c1 ea 16             	shr    $0x16,%edx
  800f0c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	74 11                	je     800f29 <fd_alloc+0x2d>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	c1 ea 0c             	shr    $0xc,%edx
  800f1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	75 09                	jne    800f32 <fd_alloc+0x36>
			*fd_store = fd;
  800f29:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	eb 17                	jmp    800f49 <fd_alloc+0x4d>
  800f32:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f37:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3c:	75 c9                	jne    800f07 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f3e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f44:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f51:	83 f8 1f             	cmp    $0x1f,%eax
  800f54:	77 36                	ja     800f8c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f56:	c1 e0 0c             	shl    $0xc,%eax
  800f59:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 16             	shr    $0x16,%edx
  800f63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	74 24                	je     800f93 <fd_lookup+0x48>
  800f6f:	89 c2                	mov    %eax,%edx
  800f71:	c1 ea 0c             	shr    $0xc,%edx
  800f74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7b:	f6 c2 01             	test   $0x1,%dl
  800f7e:	74 1a                	je     800f9a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f83:	89 02                	mov    %eax,(%edx)
	return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	eb 13                	jmp    800f9f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f91:	eb 0c                	jmp    800f9f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f98:	eb 05                	jmp    800f9f <fd_lookup+0x54>
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faa:	ba 48 25 80 00       	mov    $0x802548,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800faf:	eb 13                	jmp    800fc4 <dev_lookup+0x23>
  800fb1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fb4:	39 08                	cmp    %ecx,(%eax)
  800fb6:	75 0c                	jne    800fc4 <dev_lookup+0x23>
			*dev = devtab[i];
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	eb 2e                	jmp    800ff2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc4:	8b 02                	mov    (%edx),%eax
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	75 e7                	jne    800fb1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fca:	a1 04 40 80 00       	mov    0x804004,%eax
  800fcf:	8b 40 48             	mov    0x48(%eax),%eax
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	51                   	push   %ecx
  800fd6:	50                   	push   %eax
  800fd7:	68 cc 24 80 00       	push   $0x8024cc
  800fdc:	e8 1f f2 ff ff       	call   800200 <cprintf>
	*dev = 0;
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 10             	sub    $0x10,%esp
  800ffc:	8b 75 08             	mov    0x8(%ebp),%esi
  800fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801005:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801006:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100f:	50                   	push   %eax
  801010:	e8 36 ff ff ff       	call   800f4b <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 05                	js     801021 <fd_close+0x2d>
	    || fd != fd2)
  80101c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80101f:	74 0c                	je     80102d <fd_close+0x39>
		return (must_exist ? r : 0);
  801021:	84 db                	test   %bl,%bl
  801023:	ba 00 00 00 00       	mov    $0x0,%edx
  801028:	0f 44 c2             	cmove  %edx,%eax
  80102b:	eb 41                	jmp    80106e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	ff 36                	pushl  (%esi)
  801036:	e8 66 ff ff ff       	call   800fa1 <dev_lookup>
  80103b:	89 c3                	mov    %eax,%ebx
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 1a                	js     80105e <fd_close+0x6a>
		if (dev->dev_close)
  801044:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801047:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80104f:	85 c0                	test   %eax,%eax
  801051:	74 0b                	je     80105e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	56                   	push   %esi
  801057:	ff d0                	call   *%eax
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	56                   	push   %esi
  801062:	6a 00                	push   $0x0
  801064:	e8 ac fb ff ff       	call   800c15 <sys_page_unmap>
	return r;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 d8                	mov    %ebx,%eax
}
  80106e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80107b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107e:	50                   	push   %eax
  80107f:	ff 75 08             	pushl  0x8(%ebp)
  801082:	e8 c4 fe ff ff       	call   800f4b <fd_lookup>
  801087:	89 c2                	mov    %eax,%edx
  801089:	83 c4 08             	add    $0x8,%esp
  80108c:	85 d2                	test   %edx,%edx
  80108e:	78 10                	js     8010a0 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	6a 01                	push   $0x1
  801095:	ff 75 f4             	pushl  -0xc(%ebp)
  801098:	e8 57 ff ff ff       	call   800ff4 <fd_close>
  80109d:	83 c4 10             	add    $0x10,%esp
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <close_all>:

void
close_all(void)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	e8 be ff ff ff       	call   801075 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b7:	83 c3 01             	add    $0x1,%ebx
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	83 fb 20             	cmp    $0x20,%ebx
  8010c0:	75 ec                	jne    8010ae <close_all+0xc>
		close(i);
}
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 2c             	sub    $0x2c,%esp
  8010d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	ff 75 08             	pushl  0x8(%ebp)
  8010da:	e8 6c fe ff ff       	call   800f4b <fd_lookup>
  8010df:	89 c2                	mov    %eax,%edx
  8010e1:	83 c4 08             	add    $0x8,%esp
  8010e4:	85 d2                	test   %edx,%edx
  8010e6:	0f 88 c1 00 00 00    	js     8011ad <dup+0xe6>
		return r;
	close(newfdnum);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	56                   	push   %esi
  8010f0:	e8 80 ff ff ff       	call   801075 <close>

	newfd = INDEX2FD(newfdnum);
  8010f5:	89 f3                	mov    %esi,%ebx
  8010f7:	c1 e3 0c             	shl    $0xc,%ebx
  8010fa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801100:	83 c4 04             	add    $0x4,%esp
  801103:	ff 75 e4             	pushl  -0x1c(%ebp)
  801106:	e8 da fd ff ff       	call   800ee5 <fd2data>
  80110b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80110d:	89 1c 24             	mov    %ebx,(%esp)
  801110:	e8 d0 fd ff ff       	call   800ee5 <fd2data>
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80111b:	89 f8                	mov    %edi,%eax
  80111d:	c1 e8 16             	shr    $0x16,%eax
  801120:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801127:	a8 01                	test   $0x1,%al
  801129:	74 37                	je     801162 <dup+0x9b>
  80112b:	89 f8                	mov    %edi,%eax
  80112d:	c1 e8 0c             	shr    $0xc,%eax
  801130:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	74 26                	je     801162 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80113c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801143:	83 ec 0c             	sub    $0xc,%esp
  801146:	25 07 0e 00 00       	and    $0xe07,%eax
  80114b:	50                   	push   %eax
  80114c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114f:	6a 00                	push   $0x0
  801151:	57                   	push   %edi
  801152:	6a 00                	push   $0x0
  801154:	e8 7a fa ff ff       	call   800bd3 <sys_page_map>
  801159:	89 c7                	mov    %eax,%edi
  80115b:	83 c4 20             	add    $0x20,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 2e                	js     801190 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801162:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801165:	89 d0                	mov    %edx,%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
  80116a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	25 07 0e 00 00       	and    $0xe07,%eax
  801179:	50                   	push   %eax
  80117a:	53                   	push   %ebx
  80117b:	6a 00                	push   $0x0
  80117d:	52                   	push   %edx
  80117e:	6a 00                	push   $0x0
  801180:	e8 4e fa ff ff       	call   800bd3 <sys_page_map>
  801185:	89 c7                	mov    %eax,%edi
  801187:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80118a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80118c:	85 ff                	test   %edi,%edi
  80118e:	79 1d                	jns    8011ad <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	53                   	push   %ebx
  801194:	6a 00                	push   $0x0
  801196:	e8 7a fa ff ff       	call   800c15 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a1:	6a 00                	push   $0x0
  8011a3:	e8 6d fa ff ff       	call   800c15 <sys_page_unmap>
	return r;
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	89 f8                	mov    %edi,%eax
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 14             	sub    $0x14,%esp
  8011bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	53                   	push   %ebx
  8011c4:	e8 82 fd ff ff       	call   800f4b <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 6d                	js     80123f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	ff 30                	pushl  (%eax)
  8011de:	e8 be fd ff ff       	call   800fa1 <dev_lookup>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 4c                	js     801236 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ed:	8b 42 08             	mov    0x8(%edx),%eax
  8011f0:	83 e0 03             	and    $0x3,%eax
  8011f3:	83 f8 01             	cmp    $0x1,%eax
  8011f6:	75 21                	jne    801219 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fd:	8b 40 48             	mov    0x48(%eax),%eax
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	53                   	push   %ebx
  801204:	50                   	push   %eax
  801205:	68 0d 25 80 00       	push   $0x80250d
  80120a:	e8 f1 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801217:	eb 26                	jmp    80123f <read+0x8a>
	}
	if (!dev->dev_read)
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	8b 40 08             	mov    0x8(%eax),%eax
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 17                	je     80123a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	ff 75 10             	pushl  0x10(%ebp)
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	52                   	push   %edx
  80122d:	ff d0                	call   *%eax
  80122f:	89 c2                	mov    %eax,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	eb 09                	jmp    80123f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	89 c2                	mov    %eax,%edx
  801238:	eb 05                	jmp    80123f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80123a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80123f:	89 d0                	mov    %edx,%eax
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	57                   	push   %edi
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 0c             	sub    $0xc,%esp
  80124f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801252:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125a:	eb 21                	jmp    80127d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80125c:	83 ec 04             	sub    $0x4,%esp
  80125f:	89 f0                	mov    %esi,%eax
  801261:	29 d8                	sub    %ebx,%eax
  801263:	50                   	push   %eax
  801264:	89 d8                	mov    %ebx,%eax
  801266:	03 45 0c             	add    0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	57                   	push   %edi
  80126b:	e8 45 ff ff ff       	call   8011b5 <read>
		if (m < 0)
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 0c                	js     801283 <readn+0x3d>
			return m;
		if (m == 0)
  801277:	85 c0                	test   %eax,%eax
  801279:	74 06                	je     801281 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80127b:	01 c3                	add    %eax,%ebx
  80127d:	39 f3                	cmp    %esi,%ebx
  80127f:	72 db                	jb     80125c <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801281:	89 d8                	mov    %ebx,%eax
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	83 ec 14             	sub    $0x14,%esp
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	53                   	push   %ebx
  80129a:	e8 ac fc ff ff       	call   800f4b <fd_lookup>
  80129f:	83 c4 08             	add    $0x8,%esp
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 68                	js     801310 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	ff 30                	pushl  (%eax)
  8012b4:	e8 e8 fc ff ff       	call   800fa1 <dev_lookup>
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 47                	js     801307 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c7:	75 21                	jne    8012ea <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	68 29 25 80 00       	push   $0x802529
  8012db:	e8 20 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012e8:	eb 26                	jmp    801310 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f0:	85 d2                	test   %edx,%edx
  8012f2:	74 17                	je     80130b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	ff 75 10             	pushl  0x10(%ebp)
  8012fa:	ff 75 0c             	pushl  0xc(%ebp)
  8012fd:	50                   	push   %eax
  8012fe:	ff d2                	call   *%edx
  801300:	89 c2                	mov    %eax,%edx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	eb 09                	jmp    801310 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	89 c2                	mov    %eax,%edx
  801309:	eb 05                	jmp    801310 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80130b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801310:	89 d0                	mov    %edx,%eax
  801312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <seek>:

int
seek(int fdnum, off_t offset)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 75 08             	pushl  0x8(%ebp)
  801324:	e8 22 fc ff ff       	call   800f4b <fd_lookup>
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 0e                	js     80133e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801330:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801333:	8b 55 0c             	mov    0xc(%ebp),%edx
  801336:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	53                   	push   %ebx
  801344:	83 ec 14             	sub    $0x14,%esp
  801347:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	53                   	push   %ebx
  80134f:	e8 f7 fb ff ff       	call   800f4b <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	89 c2                	mov    %eax,%edx
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 65                	js     8013c2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801367:	ff 30                	pushl  (%eax)
  801369:	e8 33 fc ff ff       	call   800fa1 <dev_lookup>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 44                	js     8013b9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137c:	75 21                	jne    80139f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80137e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801383:	8b 40 48             	mov    0x48(%eax),%eax
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	53                   	push   %ebx
  80138a:	50                   	push   %eax
  80138b:	68 ec 24 80 00       	push   $0x8024ec
  801390:	e8 6b ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139d:	eb 23                	jmp    8013c2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a2:	8b 52 18             	mov    0x18(%edx),%edx
  8013a5:	85 d2                	test   %edx,%edx
  8013a7:	74 14                	je     8013bd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	ff 75 0c             	pushl  0xc(%ebp)
  8013af:	50                   	push   %eax
  8013b0:	ff d2                	call   *%edx
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	eb 09                	jmp    8013c2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	eb 05                	jmp    8013c2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c2:	89 d0                	mov    %edx,%eax
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 14             	sub    $0x14,%esp
  8013d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 6c fb ff ff       	call   800f4b <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 58                	js     801440 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f2:	ff 30                	pushl  (%eax)
  8013f4:	e8 a8 fb ff ff       	call   800fa1 <dev_lookup>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 37                	js     801437 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801407:	74 32                	je     80143b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801409:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801413:	00 00 00 
	stat->st_isdir = 0;
  801416:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141d:	00 00 00 
	stat->st_dev = dev;
  801420:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	ff 75 f0             	pushl  -0x10(%ebp)
  80142d:	ff 50 14             	call   *0x14(%eax)
  801430:	89 c2                	mov    %eax,%edx
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	eb 09                	jmp    801440 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801437:	89 c2                	mov    %eax,%edx
  801439:	eb 05                	jmp    801440 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80143b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801440:	89 d0                	mov    %edx,%eax
  801442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	6a 00                	push   $0x0
  801451:	ff 75 08             	pushl  0x8(%ebp)
  801454:	e8 09 02 00 00       	call   801662 <open>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 db                	test   %ebx,%ebx
  801460:	78 1b                	js     80147d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	53                   	push   %ebx
  801469:	e8 5b ff ff ff       	call   8013c9 <fstat>
  80146e:	89 c6                	mov    %eax,%esi
	close(fd);
  801470:	89 1c 24             	mov    %ebx,(%esp)
  801473:	e8 fd fb ff ff       	call   801075 <close>
	return r;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 f0                	mov    %esi,%eax
}
  80147d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	89 c6                	mov    %eax,%esi
  80148b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80148d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801494:	75 12                	jne    8014a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	6a 01                	push   $0x1
  80149b:	e8 55 09 00 00       	call   801df5 <ipc_find_env>
  8014a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8014a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a8:	6a 07                	push   $0x7
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	56                   	push   %esi
  8014b0:	ff 35 00 40 80 00    	pushl  0x804000
  8014b6:	e8 e6 08 00 00       	call   801da1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014bb:	83 c4 0c             	add    $0xc,%esp
  8014be:	6a 00                	push   $0x0
  8014c0:	53                   	push   %ebx
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 70 08 00 00       	call   801d38 <ipc_recv>
}
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f2:	e8 8d ff ff ff       	call   801484 <fsipc>
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	8b 40 0c             	mov    0xc(%eax),%eax
  801505:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	b8 06 00 00 00       	mov    $0x6,%eax
  801514:	e8 6b ff ff ff       	call   801484 <fsipc>
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
  801528:	8b 40 0c             	mov    0xc(%eax),%eax
  80152b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801530:	ba 00 00 00 00       	mov    $0x0,%edx
  801535:	b8 05 00 00 00       	mov    $0x5,%eax
  80153a:	e8 45 ff ff ff       	call   801484 <fsipc>
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 d2                	test   %edx,%edx
  801543:	78 2c                	js     801571 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	68 00 50 80 00       	push   $0x805000
  80154d:	53                   	push   %ebx
  80154e:	e8 34 f2 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801553:	a1 80 50 80 00       	mov    0x805080,%eax
  801558:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80155e:	a1 84 50 80 00       	mov    0x805084,%eax
  801563:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	57                   	push   %edi
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	8b 40 0c             	mov    0xc(%eax),%eax
  801588:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80158d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801590:	eb 3d                	jmp    8015cf <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801592:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801598:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80159d:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	57                   	push   %edi
  8015a4:	53                   	push   %ebx
  8015a5:	68 08 50 80 00       	push   $0x805008
  8015aa:	e8 6a f3 ff ff       	call   800919 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8015af:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8015bf:	e8 c0 fe ff ff       	call   801484 <fsipc>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 0d                	js     8015d8 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8015cb:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8015cd:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015cf:	85 f6                	test   %esi,%esi
  8015d1:	75 bf                	jne    801592 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8015d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5f                   	pop    %edi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801603:	e8 7c fe ff ff       	call   801484 <fsipc>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 4b                	js     801659 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80160e:	39 c6                	cmp    %eax,%esi
  801610:	73 16                	jae    801628 <devfile_read+0x48>
  801612:	68 58 25 80 00       	push   $0x802558
  801617:	68 5f 25 80 00       	push   $0x80255f
  80161c:	6a 7c                	push   $0x7c
  80161e:	68 74 25 80 00       	push   $0x802574
  801623:	e8 ca 06 00 00       	call   801cf2 <_panic>
	assert(r <= PGSIZE);
  801628:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80162d:	7e 16                	jle    801645 <devfile_read+0x65>
  80162f:	68 7f 25 80 00       	push   $0x80257f
  801634:	68 5f 25 80 00       	push   $0x80255f
  801639:	6a 7d                	push   $0x7d
  80163b:	68 74 25 80 00       	push   $0x802574
  801640:	e8 ad 06 00 00       	call   801cf2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801645:	83 ec 04             	sub    $0x4,%esp
  801648:	50                   	push   %eax
  801649:	68 00 50 80 00       	push   $0x805000
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	e8 c3 f2 ff ff       	call   800919 <memmove>
	return r;
  801656:	83 c4 10             	add    $0x10,%esp
}
  801659:	89 d8                	mov    %ebx,%eax
  80165b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	83 ec 20             	sub    $0x20,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80166c:	53                   	push   %ebx
  80166d:	e8 dc f0 ff ff       	call   80074e <strlen>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167a:	7f 67                	jg     8016e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	e8 74 f8 ff ff       	call   800efc <fd_alloc>
  801688:	83 c4 10             	add    $0x10,%esp
		return r;
  80168b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 57                	js     8016e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	53                   	push   %ebx
  801695:	68 00 50 80 00       	push   $0x805000
  80169a:	e8 e8 f0 ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80169f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8016af:	e8 d0 fd ff ff       	call   801484 <fsipc>
  8016b4:	89 c3                	mov    %eax,%ebx
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	79 14                	jns    8016d1 <open+0x6f>
		fd_close(fd, 0);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	6a 00                	push   $0x0
  8016c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c5:	e8 2a f9 ff ff       	call   800ff4 <fd_close>
		return r;
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	89 da                	mov    %ebx,%edx
  8016cf:	eb 17                	jmp    8016e8 <open+0x86>
	}

	return fd2num(fd);
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d7:	e8 f9 f7 ff ff       	call   800ed5 <fd2num>
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	eb 05                	jmp    8016e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ff:	e8 80 fd ff ff       	call   801484 <fsipc>
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801706:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80170a:	7e 37                	jle    801743 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801715:	ff 70 04             	pushl  0x4(%eax)
  801718:	8d 40 10             	lea    0x10(%eax),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 33                	pushl  (%ebx)
  80171e:	e8 68 fb ff ff       	call   80128b <write>
		if (result > 0)
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	7e 03                	jle    80172d <writebuf+0x27>
			b->result += result;
  80172a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80172d:	39 43 04             	cmp    %eax,0x4(%ebx)
  801730:	74 0d                	je     80173f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801732:	85 c0                	test   %eax,%eax
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	0f 4f c2             	cmovg  %edx,%eax
  80173c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	f3 c3                	repz ret 

00801745 <putch>:

static void
putch(int ch, void *thunk)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80174f:	8b 53 04             	mov    0x4(%ebx),%edx
  801752:	8d 42 01             	lea    0x1(%edx),%eax
  801755:	89 43 04             	mov    %eax,0x4(%ebx)
  801758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80175f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801764:	75 0e                	jne    801774 <putch+0x2f>
		writebuf(b);
  801766:	89 d8                	mov    %ebx,%eax
  801768:	e8 99 ff ff ff       	call   801706 <writebuf>
		b->idx = 0;
  80176d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801774:	83 c4 04             	add    $0x4,%esp
  801777:	5b                   	pop    %ebx
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80178c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801793:	00 00 00 
	b.result = 0;
  801796:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80179d:	00 00 00 
	b.error = 1;
  8017a0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017a7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017aa:	ff 75 10             	pushl  0x10(%ebp)
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	68 45 17 80 00       	push   $0x801745
  8017bc:	e8 71 eb ff ff       	call   800332 <vprintfmt>
	if (b.idx > 0)
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017cb:	7e 0b                	jle    8017d8 <vfprintf+0x5e>
		writebuf(&b);
  8017cd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d3:	e8 2e ff ff ff       	call   801706 <writebuf>

	return (b.result ? b.result : b.error);
  8017d8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ef:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017f2:	50                   	push   %eax
  8017f3:	ff 75 0c             	pushl  0xc(%ebp)
  8017f6:	ff 75 08             	pushl  0x8(%ebp)
  8017f9:	e8 7c ff ff ff       	call   80177a <vfprintf>
	va_end(ap);

	return cnt;
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <printf>:

int
printf(const char *fmt, ...)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801806:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801809:	50                   	push   %eax
  80180a:	ff 75 08             	pushl  0x8(%ebp)
  80180d:	6a 01                	push   $0x1
  80180f:	e8 66 ff ff ff       	call   80177a <vfprintf>
	va_end(ap);

	return cnt;
}
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	ff 75 08             	pushl  0x8(%ebp)
  801824:	e8 bc f6 ff ff       	call   800ee5 <fd2data>
  801829:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80182b:	83 c4 08             	add    $0x8,%esp
  80182e:	68 8b 25 80 00       	push   $0x80258b
  801833:	53                   	push   %ebx
  801834:	e8 4e ef ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801839:	8b 56 04             	mov    0x4(%esi),%edx
  80183c:	89 d0                	mov    %edx,%eax
  80183e:	2b 06                	sub    (%esi),%eax
  801840:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801846:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184d:	00 00 00 
	stat->st_dev = &devpipe;
  801850:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801857:	30 80 00 
	return 0;
}
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
  80185f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	53                   	push   %ebx
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801870:	53                   	push   %ebx
  801871:	6a 00                	push   $0x0
  801873:	e8 9d f3 ff ff       	call   800c15 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801878:	89 1c 24             	mov    %ebx,(%esp)
  80187b:	e8 65 f6 ff ff       	call   800ee5 <fd2data>
  801880:	83 c4 08             	add    $0x8,%esp
  801883:	50                   	push   %eax
  801884:	6a 00                	push   $0x0
  801886:	e8 8a f3 ff ff       	call   800c15 <sys_page_unmap>
}
  80188b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	57                   	push   %edi
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 1c             	sub    $0x1c,%esp
  801899:	89 c6                	mov    %eax,%esi
  80189b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80189e:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	56                   	push   %esi
  8018aa:	e8 7e 05 00 00       	call   801e2d <pageref>
  8018af:	89 c7                	mov    %eax,%edi
  8018b1:	83 c4 04             	add    $0x4,%esp
  8018b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b7:	e8 71 05 00 00       	call   801e2d <pageref>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	39 c7                	cmp    %eax,%edi
  8018c1:	0f 94 c2             	sete   %dl
  8018c4:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8018c7:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8018cd:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8018d0:	39 fb                	cmp    %edi,%ebx
  8018d2:	74 19                	je     8018ed <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8018d4:	84 d2                	test   %dl,%dl
  8018d6:	74 c6                	je     80189e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018d8:	8b 51 58             	mov    0x58(%ecx),%edx
  8018db:	50                   	push   %eax
  8018dc:	52                   	push   %edx
  8018dd:	53                   	push   %ebx
  8018de:	68 92 25 80 00       	push   $0x802592
  8018e3:	e8 18 e9 ff ff       	call   800200 <cprintf>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	eb b1                	jmp    80189e <_pipeisclosed+0xe>
	}
}
  8018ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5f                   	pop    %edi
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	57                   	push   %edi
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 28             	sub    $0x28,%esp
  8018fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801901:	56                   	push   %esi
  801902:	e8 de f5 ff ff       	call   800ee5 <fd2data>
  801907:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	bf 00 00 00 00       	mov    $0x0,%edi
  801911:	eb 4b                	jmp    80195e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801913:	89 da                	mov    %ebx,%edx
  801915:	89 f0                	mov    %esi,%eax
  801917:	e8 74 ff ff ff       	call   801890 <_pipeisclosed>
  80191c:	85 c0                	test   %eax,%eax
  80191e:	75 48                	jne    801968 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801920:	e8 4c f2 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801925:	8b 43 04             	mov    0x4(%ebx),%eax
  801928:	8b 0b                	mov    (%ebx),%ecx
  80192a:	8d 51 20             	lea    0x20(%ecx),%edx
  80192d:	39 d0                	cmp    %edx,%eax
  80192f:	73 e2                	jae    801913 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801934:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801938:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80193b:	89 c2                	mov    %eax,%edx
  80193d:	c1 fa 1f             	sar    $0x1f,%edx
  801940:	89 d1                	mov    %edx,%ecx
  801942:	c1 e9 1b             	shr    $0x1b,%ecx
  801945:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801948:	83 e2 1f             	and    $0x1f,%edx
  80194b:	29 ca                	sub    %ecx,%edx
  80194d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801951:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801955:	83 c0 01             	add    $0x1,%eax
  801958:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80195b:	83 c7 01             	add    $0x1,%edi
  80195e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801961:	75 c2                	jne    801925 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801963:	8b 45 10             	mov    0x10(%ebp),%eax
  801966:	eb 05                	jmp    80196d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80196d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5f                   	pop    %edi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	57                   	push   %edi
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	83 ec 18             	sub    $0x18,%esp
  80197e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801981:	57                   	push   %edi
  801982:	e8 5e f5 ff ff       	call   800ee5 <fd2data>
  801987:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801991:	eb 3d                	jmp    8019d0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801993:	85 db                	test   %ebx,%ebx
  801995:	74 04                	je     80199b <devpipe_read+0x26>
				return i;
  801997:	89 d8                	mov    %ebx,%eax
  801999:	eb 44                	jmp    8019df <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80199b:	89 f2                	mov    %esi,%edx
  80199d:	89 f8                	mov    %edi,%eax
  80199f:	e8 ec fe ff ff       	call   801890 <_pipeisclosed>
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	75 32                	jne    8019da <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019a8:	e8 c4 f1 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019ad:	8b 06                	mov    (%esi),%eax
  8019af:	3b 46 04             	cmp    0x4(%esi),%eax
  8019b2:	74 df                	je     801993 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019b4:	99                   	cltd   
  8019b5:	c1 ea 1b             	shr    $0x1b,%edx
  8019b8:	01 d0                	add    %edx,%eax
  8019ba:	83 e0 1f             	and    $0x1f,%eax
  8019bd:	29 d0                	sub    %edx,%eax
  8019bf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019ca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cd:	83 c3 01             	add    $0x1,%ebx
  8019d0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019d3:	75 d8                	jne    8019ad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d8:	eb 05                	jmp    8019df <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5f                   	pop    %edi
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	e8 04 f5 ff ff       	call   800efc <fd_alloc>
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	0f 88 2c 01 00 00    	js     801b31 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	68 07 04 00 00       	push   $0x407
  801a0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a10:	6a 00                	push   $0x0
  801a12:	e8 79 f1 ff ff       	call   800b90 <sys_page_alloc>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 0d 01 00 00    	js     801b31 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a2a:	50                   	push   %eax
  801a2b:	e8 cc f4 ff ff       	call   800efc <fd_alloc>
  801a30:	89 c3                	mov    %eax,%ebx
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	85 c0                	test   %eax,%eax
  801a37:	0f 88 e2 00 00 00    	js     801b1f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	68 07 04 00 00       	push   $0x407
  801a45:	ff 75 f0             	pushl  -0x10(%ebp)
  801a48:	6a 00                	push   $0x0
  801a4a:	e8 41 f1 ff ff       	call   800b90 <sys_page_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 c3 00 00 00    	js     801b1f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a62:	e8 7e f4 ff ff       	call   800ee5 <fd2data>
  801a67:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a69:	83 c4 0c             	add    $0xc,%esp
  801a6c:	68 07 04 00 00       	push   $0x407
  801a71:	50                   	push   %eax
  801a72:	6a 00                	push   $0x0
  801a74:	e8 17 f1 ff ff       	call   800b90 <sys_page_alloc>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	0f 88 89 00 00 00    	js     801b0f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	ff 75 f0             	pushl  -0x10(%ebp)
  801a8c:	e8 54 f4 ff ff       	call   800ee5 <fd2data>
  801a91:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a98:	50                   	push   %eax
  801a99:	6a 00                	push   $0x0
  801a9b:	56                   	push   %esi
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 30 f1 ff ff       	call   800bd3 <sys_page_map>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	83 c4 20             	add    $0x20,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 55                	js     801b01 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ac1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	ff 75 f4             	pushl  -0xc(%ebp)
  801adc:	e8 f4 f3 ff ff       	call   800ed5 <fd2num>
  801ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ae6:	83 c4 04             	add    $0x4,%esp
  801ae9:	ff 75 f0             	pushl  -0x10(%ebp)
  801aec:	e8 e4 f3 ff ff       	call   800ed5 <fd2num>
  801af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aff:	eb 30                	jmp    801b31 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b01:	83 ec 08             	sub    $0x8,%esp
  801b04:	56                   	push   %esi
  801b05:	6a 00                	push   $0x0
  801b07:	e8 09 f1 ff ff       	call   800c15 <sys_page_unmap>
  801b0c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	ff 75 f0             	pushl  -0x10(%ebp)
  801b15:	6a 00                	push   $0x0
  801b17:	e8 f9 f0 ff ff       	call   800c15 <sys_page_unmap>
  801b1c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b1f:	83 ec 08             	sub    $0x8,%esp
  801b22:	ff 75 f4             	pushl  -0xc(%ebp)
  801b25:	6a 00                	push   $0x0
  801b27:	e8 e9 f0 ff ff       	call   800c15 <sys_page_unmap>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b31:	89 d0                	mov    %edx,%eax
  801b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5e                   	pop    %esi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b43:	50                   	push   %eax
  801b44:	ff 75 08             	pushl  0x8(%ebp)
  801b47:	e8 ff f3 ff ff       	call   800f4b <fd_lookup>
  801b4c:	89 c2                	mov    %eax,%edx
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 d2                	test   %edx,%edx
  801b53:	78 18                	js     801b6d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5b:	e8 85 f3 ff ff       	call   800ee5 <fd2data>
	return _pipeisclosed(fd, p);
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	e8 26 fd ff ff       	call   801890 <_pipeisclosed>
  801b6a:	83 c4 10             	add    $0x10,%esp
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b7f:	68 aa 25 80 00       	push   $0x8025aa
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	e8 fb eb ff ff       	call   800787 <strcpy>
	return 0;
}
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ba4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801baa:	eb 2d                	jmp    801bd9 <devcons_write+0x46>
		m = n - tot;
  801bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801baf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bb1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bb4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bb9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	53                   	push   %ebx
  801bc0:	03 45 0c             	add    0xc(%ebp),%eax
  801bc3:	50                   	push   %eax
  801bc4:	57                   	push   %edi
  801bc5:	e8 4f ed ff ff       	call   800919 <memmove>
		sys_cputs(buf, m);
  801bca:	83 c4 08             	add    $0x8,%esp
  801bcd:	53                   	push   %ebx
  801bce:	57                   	push   %edi
  801bcf:	e8 00 ef ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd4:	01 de                	add    %ebx,%esi
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	89 f0                	mov    %esi,%eax
  801bdb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bde:	72 cc                	jb     801bac <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801bf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf7:	75 07                	jne    801c00 <devcons_read+0x18>
  801bf9:	eb 28                	jmp    801c23 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bfb:	e8 71 ef ff ff       	call   800b71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c00:	e8 ed ee ff ff       	call   800af2 <sys_cgetc>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	74 f2                	je     801bfb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 16                	js     801c23 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c0d:	83 f8 04             	cmp    $0x4,%eax
  801c10:	74 0c                	je     801c1e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c15:	88 02                	mov    %al,(%edx)
	return 1;
  801c17:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1c:	eb 05                	jmp    801c23 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c31:	6a 01                	push   $0x1
  801c33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	e8 98 ee ff ff       	call   800ad4 <sys_cputs>
  801c3c:	83 c4 10             	add    $0x10,%esp
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <getchar>:

int
getchar(void)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c47:	6a 01                	push   $0x1
  801c49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 61 f5 ff ff       	call   8011b5 <read>
	if (r < 0)
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 0f                	js     801c6a <getchar+0x29>
		return r;
	if (r < 1)
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	7e 06                	jle    801c65 <getchar+0x24>
		return -E_EOF;
	return c;
  801c5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c63:	eb 05                	jmp    801c6a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	50                   	push   %eax
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	e8 cd f2 ff ff       	call   800f4b <fd_lookup>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 11                	js     801c96 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c88:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c8e:	39 10                	cmp    %edx,(%eax)
  801c90:	0f 94 c0             	sete   %al
  801c93:	0f b6 c0             	movzbl %al,%eax
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <opencons>:

int
opencons(void)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca1:	50                   	push   %eax
  801ca2:	e8 55 f2 ff ff       	call   800efc <fd_alloc>
  801ca7:	83 c4 10             	add    $0x10,%esp
		return r;
  801caa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 3e                	js     801cee <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb0:	83 ec 04             	sub    $0x4,%esp
  801cb3:	68 07 04 00 00       	push   $0x407
  801cb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 ce ee ff ff       	call   800b90 <sys_page_alloc>
  801cc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 23                	js     801cee <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ccb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ce0:	83 ec 0c             	sub    $0xc,%esp
  801ce3:	50                   	push   %eax
  801ce4:	e8 ec f1 ff ff       	call   800ed5 <fd2num>
  801ce9:	89 c2                	mov    %eax,%edx
  801ceb:	83 c4 10             	add    $0x10,%esp
}
  801cee:	89 d0                	mov    %edx,%eax
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cf7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cfa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d00:	e8 4d ee ff ff       	call   800b52 <sys_getenvid>
  801d05:	83 ec 0c             	sub    $0xc,%esp
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	ff 75 08             	pushl  0x8(%ebp)
  801d0e:	56                   	push   %esi
  801d0f:	50                   	push   %eax
  801d10:	68 b8 25 80 00       	push   $0x8025b8
  801d15:	e8 e6 e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d1a:	83 c4 18             	add    $0x18,%esp
  801d1d:	53                   	push   %ebx
  801d1e:	ff 75 10             	pushl  0x10(%ebp)
  801d21:	e8 89 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d26:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
  801d2d:	e8 ce e4 ff ff       	call   800200 <cprintf>
  801d32:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d35:	cc                   	int3   
  801d36:	eb fd                	jmp    801d35 <_panic+0x43>

00801d38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801d46:	85 c0                	test   %eax,%eax
  801d48:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d4d:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801d50:	83 ec 0c             	sub    $0xc,%esp
  801d53:	50                   	push   %eax
  801d54:	e8 e7 ef ff ff       	call   800d40 <sys_ipc_recv>
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	79 16                	jns    801d76 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801d60:	85 f6                	test   %esi,%esi
  801d62:	74 06                	je     801d6a <ipc_recv+0x32>
  801d64:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801d6a:	85 db                	test   %ebx,%ebx
  801d6c:	74 2c                	je     801d9a <ipc_recv+0x62>
  801d6e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d74:	eb 24                	jmp    801d9a <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801d76:	85 f6                	test   %esi,%esi
  801d78:	74 0a                	je     801d84 <ipc_recv+0x4c>
  801d7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d7f:	8b 40 74             	mov    0x74(%eax),%eax
  801d82:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801d84:	85 db                	test   %ebx,%ebx
  801d86:	74 0a                	je     801d92 <ipc_recv+0x5a>
  801d88:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8d:	8b 40 78             	mov    0x78(%eax),%eax
  801d90:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801d92:	a1 04 40 80 00       	mov    0x804004,%eax
  801d97:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	57                   	push   %edi
  801da5:	56                   	push   %esi
  801da6:	53                   	push   %ebx
  801da7:	83 ec 0c             	sub    $0xc,%esp
  801daa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dad:	8b 75 0c             	mov    0xc(%ebp),%esi
  801db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801db3:	85 db                	test   %ebx,%ebx
  801db5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801dba:	0f 44 d8             	cmove  %eax,%ebx
  801dbd:	eb 1c                	jmp    801ddb <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801dbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dc2:	74 12                	je     801dd6 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801dc4:	50                   	push   %eax
  801dc5:	68 dc 25 80 00       	push   $0x8025dc
  801dca:	6a 39                	push   $0x39
  801dcc:	68 f7 25 80 00       	push   $0x8025f7
  801dd1:	e8 1c ff ff ff       	call   801cf2 <_panic>
                 sys_yield();
  801dd6:	e8 96 ed ff ff       	call   800b71 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ddb:	ff 75 14             	pushl  0x14(%ebp)
  801dde:	53                   	push   %ebx
  801ddf:	56                   	push   %esi
  801de0:	57                   	push   %edi
  801de1:	e8 37 ef ff ff       	call   800d1d <sys_ipc_try_send>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 d2                	js     801dbf <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e00:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e03:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e09:	8b 52 50             	mov    0x50(%edx),%edx
  801e0c:	39 ca                	cmp    %ecx,%edx
  801e0e:	75 0d                	jne    801e1d <ipc_find_env+0x28>
			return envs[i].env_id;
  801e10:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e13:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801e18:	8b 40 08             	mov    0x8(%eax),%eax
  801e1b:	eb 0e                	jmp    801e2b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e1d:	83 c0 01             	add    $0x1,%eax
  801e20:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e25:	75 d9                	jne    801e00 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e27:	66 b8 00 00          	mov    $0x0,%ax
}
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e33:	89 d0                	mov    %edx,%eax
  801e35:	c1 e8 16             	shr    $0x16,%eax
  801e38:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e44:	f6 c1 01             	test   $0x1,%cl
  801e47:	74 1d                	je     801e66 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e49:	c1 ea 0c             	shr    $0xc,%edx
  801e4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e53:	f6 c2 01             	test   $0x1,%dl
  801e56:	74 0e                	je     801e66 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e58:	c1 ea 0c             	shr    $0xc,%edx
  801e5b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e62:	ef 
  801e63:	0f b7 c0             	movzwl %ax,%eax
}
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__udivdi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 10             	sub    $0x10,%esp
  801e76:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801e7a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801e7e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801e82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e86:	85 d2                	test   %edx,%edx
  801e88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e8c:	89 34 24             	mov    %esi,(%esp)
  801e8f:	89 c8                	mov    %ecx,%eax
  801e91:	75 35                	jne    801ec8 <__udivdi3+0x58>
  801e93:	39 f1                	cmp    %esi,%ecx
  801e95:	0f 87 bd 00 00 00    	ja     801f58 <__udivdi3+0xe8>
  801e9b:	85 c9                	test   %ecx,%ecx
  801e9d:	89 cd                	mov    %ecx,%ebp
  801e9f:	75 0b                	jne    801eac <__udivdi3+0x3c>
  801ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea6:	31 d2                	xor    %edx,%edx
  801ea8:	f7 f1                	div    %ecx
  801eaa:	89 c5                	mov    %eax,%ebp
  801eac:	89 f0                	mov    %esi,%eax
  801eae:	31 d2                	xor    %edx,%edx
  801eb0:	f7 f5                	div    %ebp
  801eb2:	89 c6                	mov    %eax,%esi
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	f7 f5                	div    %ebp
  801eb8:	89 f2                	mov    %esi,%edx
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    
  801ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	3b 14 24             	cmp    (%esp),%edx
  801ecb:	77 7b                	ja     801f48 <__udivdi3+0xd8>
  801ecd:	0f bd f2             	bsr    %edx,%esi
  801ed0:	83 f6 1f             	xor    $0x1f,%esi
  801ed3:	0f 84 97 00 00 00    	je     801f70 <__udivdi3+0x100>
  801ed9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ede:	89 d7                	mov    %edx,%edi
  801ee0:	89 f1                	mov    %esi,%ecx
  801ee2:	29 f5                	sub    %esi,%ebp
  801ee4:	d3 e7                	shl    %cl,%edi
  801ee6:	89 c2                	mov    %eax,%edx
  801ee8:	89 e9                	mov    %ebp,%ecx
  801eea:	d3 ea                	shr    %cl,%edx
  801eec:	89 f1                	mov    %esi,%ecx
  801eee:	09 fa                	or     %edi,%edx
  801ef0:	8b 3c 24             	mov    (%esp),%edi
  801ef3:	d3 e0                	shl    %cl,%eax
  801ef5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eff:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f03:	89 fa                	mov    %edi,%edx
  801f05:	d3 ea                	shr    %cl,%edx
  801f07:	89 f1                	mov    %esi,%ecx
  801f09:	d3 e7                	shl    %cl,%edi
  801f0b:	89 e9                	mov    %ebp,%ecx
  801f0d:	d3 e8                	shr    %cl,%eax
  801f0f:	09 c7                	or     %eax,%edi
  801f11:	89 f8                	mov    %edi,%eax
  801f13:	f7 74 24 08          	divl   0x8(%esp)
  801f17:	89 d5                	mov    %edx,%ebp
  801f19:	89 c7                	mov    %eax,%edi
  801f1b:	f7 64 24 0c          	mull   0xc(%esp)
  801f1f:	39 d5                	cmp    %edx,%ebp
  801f21:	89 14 24             	mov    %edx,(%esp)
  801f24:	72 11                	jb     801f37 <__udivdi3+0xc7>
  801f26:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f2a:	89 f1                	mov    %esi,%ecx
  801f2c:	d3 e2                	shl    %cl,%edx
  801f2e:	39 c2                	cmp    %eax,%edx
  801f30:	73 5e                	jae    801f90 <__udivdi3+0x120>
  801f32:	3b 2c 24             	cmp    (%esp),%ebp
  801f35:	75 59                	jne    801f90 <__udivdi3+0x120>
  801f37:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f3a:	31 f6                	xor    %esi,%esi
  801f3c:	89 f2                	mov    %esi,%edx
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    
  801f45:	8d 76 00             	lea    0x0(%esi),%esi
  801f48:	31 f6                	xor    %esi,%esi
  801f4a:	31 c0                	xor    %eax,%eax
  801f4c:	89 f2                	mov    %esi,%edx
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    
  801f55:	8d 76 00             	lea    0x0(%esi),%esi
  801f58:	89 f2                	mov    %esi,%edx
  801f5a:	31 f6                	xor    %esi,%esi
  801f5c:	89 f8                	mov    %edi,%eax
  801f5e:	f7 f1                	div    %ecx
  801f60:	89 f2                	mov    %esi,%edx
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f74:	76 0b                	jbe    801f81 <__udivdi3+0x111>
  801f76:	31 c0                	xor    %eax,%eax
  801f78:	3b 14 24             	cmp    (%esp),%edx
  801f7b:	0f 83 37 ff ff ff    	jae    801eb8 <__udivdi3+0x48>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	e9 2d ff ff ff       	jmp    801eb8 <__udivdi3+0x48>
  801f8b:	90                   	nop
  801f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f90:	89 f8                	mov    %edi,%eax
  801f92:	31 f6                	xor    %esi,%esi
  801f94:	e9 1f ff ff ff       	jmp    801eb8 <__udivdi3+0x48>
  801f99:	66 90                	xchg   %ax,%ax
  801f9b:	66 90                	xchg   %ax,%ax
  801f9d:	66 90                	xchg   %ax,%ax
  801f9f:	90                   	nop

00801fa0 <__umoddi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	83 ec 20             	sub    $0x20,%esp
  801fa6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801faa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb2:	89 c6                	mov    %eax,%esi
  801fb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fb8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fbc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801fc0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fc4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801fc8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	89 c2                	mov    %eax,%edx
  801fd0:	75 1e                	jne    801ff0 <__umoddi3+0x50>
  801fd2:	39 f7                	cmp    %esi,%edi
  801fd4:	76 52                	jbe    802028 <__umoddi3+0x88>
  801fd6:	89 c8                	mov    %ecx,%eax
  801fd8:	89 f2                	mov    %esi,%edx
  801fda:	f7 f7                	div    %edi
  801fdc:	89 d0                	mov    %edx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	83 c4 20             	add    $0x20,%esp
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
  801fe7:	89 f6                	mov    %esi,%esi
  801fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ff0:	39 f0                	cmp    %esi,%eax
  801ff2:	77 5c                	ja     802050 <__umoddi3+0xb0>
  801ff4:	0f bd e8             	bsr    %eax,%ebp
  801ff7:	83 f5 1f             	xor    $0x1f,%ebp
  801ffa:	75 64                	jne    802060 <__umoddi3+0xc0>
  801ffc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802000:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802004:	0f 86 f6 00 00 00    	jbe    802100 <__umoddi3+0x160>
  80200a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80200e:	0f 82 ec 00 00 00    	jb     802100 <__umoddi3+0x160>
  802014:	8b 44 24 14          	mov    0x14(%esp),%eax
  802018:	8b 54 24 18          	mov    0x18(%esp),%edx
  80201c:	83 c4 20             	add    $0x20,%esp
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    
  802023:	90                   	nop
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	85 ff                	test   %edi,%edi
  80202a:	89 fd                	mov    %edi,%ebp
  80202c:	75 0b                	jne    802039 <__umoddi3+0x99>
  80202e:	b8 01 00 00 00       	mov    $0x1,%eax
  802033:	31 d2                	xor    %edx,%edx
  802035:	f7 f7                	div    %edi
  802037:	89 c5                	mov    %eax,%ebp
  802039:	8b 44 24 10          	mov    0x10(%esp),%eax
  80203d:	31 d2                	xor    %edx,%edx
  80203f:	f7 f5                	div    %ebp
  802041:	89 c8                	mov    %ecx,%eax
  802043:	f7 f5                	div    %ebp
  802045:	eb 95                	jmp    801fdc <__umoddi3+0x3c>
  802047:	89 f6                	mov    %esi,%esi
  802049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 f2                	mov    %esi,%edx
  802054:	83 c4 20             	add    $0x20,%esp
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
  80205b:	90                   	nop
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	b8 20 00 00 00       	mov    $0x20,%eax
  802065:	89 e9                	mov    %ebp,%ecx
  802067:	29 e8                	sub    %ebp,%eax
  802069:	d3 e2                	shl    %cl,%edx
  80206b:	89 c7                	mov    %eax,%edi
  80206d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802071:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 c1                	mov    %eax,%ecx
  80207b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80207f:	09 d1                	or     %edx,%ecx
  802081:	89 fa                	mov    %edi,%edx
  802083:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802087:	89 e9                	mov    %ebp,%ecx
  802089:	d3 e0                	shl    %cl,%eax
  80208b:	89 f9                	mov    %edi,%ecx
  80208d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802091:	89 f0                	mov    %esi,%eax
  802093:	d3 e8                	shr    %cl,%eax
  802095:	89 e9                	mov    %ebp,%ecx
  802097:	89 c7                	mov    %eax,%edi
  802099:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80209d:	d3 e6                	shl    %cl,%esi
  80209f:	89 d1                	mov    %edx,%ecx
  8020a1:	89 fa                	mov    %edi,%edx
  8020a3:	d3 e8                	shr    %cl,%eax
  8020a5:	89 e9                	mov    %ebp,%ecx
  8020a7:	09 f0                	or     %esi,%eax
  8020a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8020ad:	f7 74 24 10          	divl   0x10(%esp)
  8020b1:	d3 e6                	shl    %cl,%esi
  8020b3:	89 d1                	mov    %edx,%ecx
  8020b5:	f7 64 24 0c          	mull   0xc(%esp)
  8020b9:	39 d1                	cmp    %edx,%ecx
  8020bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8020bf:	89 d7                	mov    %edx,%edi
  8020c1:	89 c6                	mov    %eax,%esi
  8020c3:	72 0a                	jb     8020cf <__umoddi3+0x12f>
  8020c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8020c9:	73 10                	jae    8020db <__umoddi3+0x13b>
  8020cb:	39 d1                	cmp    %edx,%ecx
  8020cd:	75 0c                	jne    8020db <__umoddi3+0x13b>
  8020cf:	89 d7                	mov    %edx,%edi
  8020d1:	89 c6                	mov    %eax,%esi
  8020d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8020d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8020db:	89 ca                	mov    %ecx,%edx
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020e3:	29 f0                	sub    %esi,%eax
  8020e5:	19 fa                	sbb    %edi,%edx
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8020ee:	89 d7                	mov    %edx,%edi
  8020f0:	d3 e7                	shl    %cl,%edi
  8020f2:	89 e9                	mov    %ebp,%ecx
  8020f4:	09 f8                	or     %edi,%eax
  8020f6:	d3 ea                	shr    %cl,%edx
  8020f8:	83 c4 20             	add    $0x20,%esp
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop
  802100:	8b 74 24 10          	mov    0x10(%esp),%esi
  802104:	29 f9                	sub    %edi,%ecx
  802106:	19 c6                	sbb    %eax,%esi
  802108:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80210c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802110:	e9 ff fe ff ff       	jmp    802014 <__umoddi3+0x74>
