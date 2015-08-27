
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
  800039:	68 40 26 80 00       	push   $0x802640
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
  800067:	e8 b6 0d 00 00       	call   800e22 <argstart>
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
  800091:	e8 bc 0d 00 00       	call   800e52 <argnext>
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
  8000ad:	e8 bd 13 00 00       	call   80146f <fstat>
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
  8000ce:	68 54 26 80 00       	push   $0x802654
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 b5 17 00 00       	call   80188f <fprintf>
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
  8000f0:	68 54 26 80 00       	push   $0x802654
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
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800159:	e8 ea 0f 00 00       	call   801148 <close_all>
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
  800263:	e8 18 21 00 00       	call   802380 <__udivdi3>
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
  8002a1:	e8 0a 22 00 00       	call   8024b0 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 86 26 80 00 	movsbl 0x802686(%eax),%eax
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
  8003a5:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  800469:	8b 14 85 40 29 80 00 	mov    0x802940(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 18                	jne    80048c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 9e 26 80 00       	push   $0x80269e
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
  80048d:	68 75 2a 80 00       	push   $0x802a75
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
  8004ba:	ba 97 26 80 00       	mov    $0x802697,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800b39:	68 9f 29 80 00       	push   $0x80299f
  800b3e:	6a 22                	push   $0x22
  800b40:	68 bc 29 80 00       	push   $0x8029bc
  800b45:	e8 bf 16 00 00       	call   802209 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800bba:	68 9f 29 80 00       	push   $0x80299f
  800bbf:	6a 22                	push   $0x22
  800bc1:	68 bc 29 80 00       	push   $0x8029bc
  800bc6:	e8 3e 16 00 00       	call   802209 <_panic>

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
	// return value.
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
  800bfc:	68 9f 29 80 00       	push   $0x80299f
  800c01:	6a 22                	push   $0x22
  800c03:	68 bc 29 80 00       	push   $0x8029bc
  800c08:	e8 fc 15 00 00       	call   802209 <_panic>

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
	// return value.
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
  800c3e:	68 9f 29 80 00       	push   $0x80299f
  800c43:	6a 22                	push   $0x22
  800c45:	68 bc 29 80 00       	push   $0x8029bc
  800c4a:	e8 ba 15 00 00       	call   802209 <_panic>

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
	// return value.
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
  800c80:	68 9f 29 80 00       	push   $0x80299f
  800c85:	6a 22                	push   $0x22
  800c87:	68 bc 29 80 00       	push   $0x8029bc
  800c8c:	e8 78 15 00 00       	call   802209 <_panic>
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
	// return value.
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
  800cc2:	68 9f 29 80 00       	push   $0x80299f
  800cc7:	6a 22                	push   $0x22
  800cc9:	68 bc 29 80 00       	push   $0x8029bc
  800cce:	e8 36 15 00 00       	call   802209 <_panic>

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
	// return value.
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
  800d04:	68 9f 29 80 00       	push   $0x80299f
  800d09:	6a 22                	push   $0x22
  800d0b:	68 bc 29 80 00       	push   $0x8029bc
  800d10:	e8 f4 14 00 00       	call   802209 <_panic>

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
	// return value.
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
	// return value.
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
  800d68:	68 9f 29 80 00       	push   $0x80299f
  800d6d:	6a 22                	push   $0x22
  800d6f:	68 bc 29 80 00       	push   $0x8029bc
  800d74:	e8 90 14 00 00       	call   802209 <_panic>

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

00800d81 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 d3                	mov    %edx,%ebx
  800d95:	89 d7                	mov    %edx,%edi
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 0f                	push   $0xf
  800dc8:	68 9f 29 80 00       	push   $0x80299f
  800dcd:	6a 22                	push   $0x22
  800dcf:	68 bc 29 80 00       	push   $0x8029bc
  800dd4:	e8 30 14 00 00       	call   802209 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_recv>:

int
sys_recv(void *addr)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 10 00 00 00       	mov    $0x10,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 10                	push   $0x10
  800e09:	68 9f 29 80 00       	push   $0x80299f
  800e0e:	6a 22                	push   $0x22
  800e10:	68 bc 29 80 00       	push   $0x8029bc
  800e15:	e8 ef 13 00 00       	call   802209 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e2e:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e30:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e33:	83 3a 01             	cmpl   $0x1,(%edx)
  800e36:	7e 09                	jle    800e41 <argstart+0x1f>
  800e38:	ba 51 26 80 00       	mov    $0x802651,%edx
  800e3d:	85 c9                	test   %ecx,%ecx
  800e3f:	75 05                	jne    800e46 <argstart+0x24>
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e49:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <argnext>:

int
argnext(struct Argstate *args)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	53                   	push   %ebx
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e5c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e63:	8b 43 08             	mov    0x8(%ebx),%eax
  800e66:	85 c0                	test   %eax,%eax
  800e68:	74 6f                	je     800ed9 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e6a:	80 38 00             	cmpb   $0x0,(%eax)
  800e6d:	75 4e                	jne    800ebd <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e6f:	8b 0b                	mov    (%ebx),%ecx
  800e71:	83 39 01             	cmpl   $0x1,(%ecx)
  800e74:	74 55                	je     800ecb <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e76:	8b 53 04             	mov    0x4(%ebx),%edx
  800e79:	8b 42 04             	mov    0x4(%edx),%eax
  800e7c:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e7f:	75 4a                	jne    800ecb <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e81:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e85:	74 44                	je     800ecb <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e87:	83 c0 01             	add    $0x1,%eax
  800e8a:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	8b 01                	mov    (%ecx),%eax
  800e92:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e99:	50                   	push   %eax
  800e9a:	8d 42 08             	lea    0x8(%edx),%eax
  800e9d:	50                   	push   %eax
  800e9e:	83 c2 04             	add    $0x4,%edx
  800ea1:	52                   	push   %edx
  800ea2:	e8 72 fa ff ff       	call   800919 <memmove>
		(*args->argc)--;
  800ea7:	8b 03                	mov    (%ebx),%eax
  800ea9:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800eac:	8b 43 08             	mov    0x8(%ebx),%eax
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eb5:	75 06                	jne    800ebd <argnext+0x6b>
  800eb7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ebb:	74 0e                	je     800ecb <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ebd:	8b 53 08             	mov    0x8(%ebx),%edx
  800ec0:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ec3:	83 c2 01             	add    $0x1,%edx
  800ec6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ec9:	eb 13                	jmp    800ede <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800ecb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ed7:	eb 05                	jmp    800ede <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800eed:	8b 43 08             	mov    0x8(%ebx),%eax
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	74 58                	je     800f4c <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800ef4:	80 38 00             	cmpb   $0x0,(%eax)
  800ef7:	74 0c                	je     800f05 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800ef9:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800efc:	c7 43 08 51 26 80 00 	movl   $0x802651,0x8(%ebx)
  800f03:	eb 42                	jmp    800f47 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800f05:	8b 13                	mov    (%ebx),%edx
  800f07:	83 3a 01             	cmpl   $0x1,(%edx)
  800f0a:	7e 2d                	jle    800f39 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800f0c:	8b 43 04             	mov    0x4(%ebx),%eax
  800f0f:	8b 48 04             	mov    0x4(%eax),%ecx
  800f12:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	8b 12                	mov    (%edx),%edx
  800f1a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f21:	52                   	push   %edx
  800f22:	8d 50 08             	lea    0x8(%eax),%edx
  800f25:	52                   	push   %edx
  800f26:	83 c0 04             	add    $0x4,%eax
  800f29:	50                   	push   %eax
  800f2a:	e8 ea f9 ff ff       	call   800919 <memmove>
		(*args->argc)--;
  800f2f:	8b 03                	mov    (%ebx),%eax
  800f31:	83 28 01             	subl   $0x1,(%eax)
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	eb 0e                	jmp    800f47 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800f39:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f40:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f47:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f4a:	eb 05                	jmp    800f51 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f4c:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f5f:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f62:	89 d0                	mov    %edx,%eax
  800f64:	85 d2                	test   %edx,%edx
  800f66:	75 0c                	jne    800f74 <argvalue+0x1e>
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	51                   	push   %ecx
  800f6c:	e8 72 ff ff ff       	call   800ee3 <argnextvalue>
  800f71:	83 c4 10             	add    $0x10,%esp
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800f81:	c1 e8 0c             	shr    $0xc,%eax
}
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800f91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f96:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa8:	89 c2                	mov    %eax,%edx
  800faa:	c1 ea 16             	shr    $0x16,%edx
  800fad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb4:	f6 c2 01             	test   $0x1,%dl
  800fb7:	74 11                	je     800fca <fd_alloc+0x2d>
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	c1 ea 0c             	shr    $0xc,%edx
  800fbe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc5:	f6 c2 01             	test   $0x1,%dl
  800fc8:	75 09                	jne    800fd3 <fd_alloc+0x36>
			*fd_store = fd;
  800fca:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	eb 17                	jmp    800fea <fd_alloc+0x4d>
  800fd3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fd8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fdd:	75 c9                	jne    800fa8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fdf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fe5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ff2:	83 f8 1f             	cmp    $0x1f,%eax
  800ff5:	77 36                	ja     80102d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ff7:	c1 e0 0c             	shl    $0xc,%eax
  800ffa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fff:	89 c2                	mov    %eax,%edx
  801001:	c1 ea 16             	shr    $0x16,%edx
  801004:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80100b:	f6 c2 01             	test   $0x1,%dl
  80100e:	74 24                	je     801034 <fd_lookup+0x48>
  801010:	89 c2                	mov    %eax,%edx
  801012:	c1 ea 0c             	shr    $0xc,%edx
  801015:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101c:	f6 c2 01             	test   $0x1,%dl
  80101f:	74 1a                	je     80103b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801021:	8b 55 0c             	mov    0xc(%ebp),%edx
  801024:	89 02                	mov    %eax,(%edx)
	return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 13                	jmp    801040 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80102d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801032:	eb 0c                	jmp    801040 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801034:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801039:	eb 05                	jmp    801040 <fd_lookup+0x54>
  80103b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80104b:	ba 00 00 00 00       	mov    $0x0,%edx
  801050:	eb 13                	jmp    801065 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801052:	39 08                	cmp    %ecx,(%eax)
  801054:	75 0c                	jne    801062 <dev_lookup+0x20>
			*dev = devtab[i];
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801059:	89 01                	mov    %eax,(%ecx)
			return 0;
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	eb 36                	jmp    801098 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801062:	83 c2 01             	add    $0x1,%edx
  801065:	8b 04 95 48 2a 80 00 	mov    0x802a48(,%edx,4),%eax
  80106c:	85 c0                	test   %eax,%eax
  80106e:	75 e2                	jne    801052 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801070:	a1 08 40 80 00       	mov    0x804008,%eax
  801075:	8b 40 48             	mov    0x48(%eax),%eax
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	51                   	push   %ecx
  80107c:	50                   	push   %eax
  80107d:	68 cc 29 80 00       	push   $0x8029cc
  801082:	e8 79 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  801087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
  80109f:	83 ec 10             	sub    $0x10,%esp
  8010a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ab:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010b2:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010b5:	50                   	push   %eax
  8010b6:	e8 31 ff ff ff       	call   800fec <fd_lookup>
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 05                	js     8010c7 <fd_close+0x2d>
	    || fd != fd2)
  8010c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010c5:	74 0c                	je     8010d3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8010c7:	84 db                	test   %bl,%bl
  8010c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ce:	0f 44 c2             	cmove  %edx,%eax
  8010d1:	eb 41                	jmp    801114 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010d3:	83 ec 08             	sub    $0x8,%esp
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	ff 36                	pushl  (%esi)
  8010dc:	e8 61 ff ff ff       	call   801042 <dev_lookup>
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 1a                	js     801104 <fd_close+0x6a>
		if (dev->dev_close)
  8010ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ed:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	74 0b                	je     801104 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	56                   	push   %esi
  8010fd:	ff d0                	call   *%eax
  8010ff:	89 c3                	mov    %eax,%ebx
  801101:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	56                   	push   %esi
  801108:	6a 00                	push   $0x0
  80110a:	e8 06 fb ff ff       	call   800c15 <sys_page_unmap>
	return r;
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	89 d8                	mov    %ebx,%eax
}
  801114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	e8 bf fe ff ff       	call   800fec <fd_lookup>
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	83 c4 08             	add    $0x8,%esp
  801132:	85 d2                	test   %edx,%edx
  801134:	78 10                	js     801146 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	6a 01                	push   $0x1
  80113b:	ff 75 f4             	pushl  -0xc(%ebp)
  80113e:	e8 57 ff ff ff       	call   80109a <fd_close>
  801143:	83 c4 10             	add    $0x10,%esp
}
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <close_all>:

void
close_all(void)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	53                   	push   %ebx
  80114c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80114f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	53                   	push   %ebx
  801158:	e8 be ff ff ff       	call   80111b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80115d:	83 c3 01             	add    $0x1,%ebx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	83 fb 20             	cmp    $0x20,%ebx
  801166:	75 ec                	jne    801154 <close_all+0xc>
		close(i);
}
  801168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 2c             	sub    $0x2c,%esp
  801176:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801179:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	ff 75 08             	pushl  0x8(%ebp)
  801180:	e8 67 fe ff ff       	call   800fec <fd_lookup>
  801185:	89 c2                	mov    %eax,%edx
  801187:	83 c4 08             	add    $0x8,%esp
  80118a:	85 d2                	test   %edx,%edx
  80118c:	0f 88 c1 00 00 00    	js     801253 <dup+0xe6>
		return r;
	close(newfdnum);
  801192:	83 ec 0c             	sub    $0xc,%esp
  801195:	56                   	push   %esi
  801196:	e8 80 ff ff ff       	call   80111b <close>

	newfd = INDEX2FD(newfdnum);
  80119b:	89 f3                	mov    %esi,%ebx
  80119d:	c1 e3 0c             	shl    $0xc,%ebx
  8011a0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011a6:	83 c4 04             	add    $0x4,%esp
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	e8 d5 fd ff ff       	call   800f86 <fd2data>
  8011b1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011b3:	89 1c 24             	mov    %ebx,(%esp)
  8011b6:	e8 cb fd ff ff       	call   800f86 <fd2data>
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	c1 e8 16             	shr    $0x16,%eax
  8011c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011cd:	a8 01                	test   $0x1,%al
  8011cf:	74 37                	je     801208 <dup+0x9b>
  8011d1:	89 f8                	mov    %edi,%eax
  8011d3:	c1 e8 0c             	shr    $0xc,%eax
  8011d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 26                	je     801208 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011f5:	6a 00                	push   $0x0
  8011f7:	57                   	push   %edi
  8011f8:	6a 00                	push   $0x0
  8011fa:	e8 d4 f9 ff ff       	call   800bd3 <sys_page_map>
  8011ff:	89 c7                	mov    %eax,%edi
  801201:	83 c4 20             	add    $0x20,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 2e                	js     801236 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801208:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80120b:	89 d0                	mov    %edx,%eax
  80120d:	c1 e8 0c             	shr    $0xc,%eax
  801210:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	25 07 0e 00 00       	and    $0xe07,%eax
  80121f:	50                   	push   %eax
  801220:	53                   	push   %ebx
  801221:	6a 00                	push   $0x0
  801223:	52                   	push   %edx
  801224:	6a 00                	push   $0x0
  801226:	e8 a8 f9 ff ff       	call   800bd3 <sys_page_map>
  80122b:	89 c7                	mov    %eax,%edi
  80122d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801230:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801232:	85 ff                	test   %edi,%edi
  801234:	79 1d                	jns    801253 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	53                   	push   %ebx
  80123a:	6a 00                	push   $0x0
  80123c:	e8 d4 f9 ff ff       	call   800c15 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	ff 75 d4             	pushl  -0x2c(%ebp)
  801247:	6a 00                	push   $0x0
  801249:	e8 c7 f9 ff ff       	call   800c15 <sys_page_unmap>
	return r;
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	89 f8                	mov    %edi,%eax
}
  801253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801256:	5b                   	pop    %ebx
  801257:	5e                   	pop    %esi
  801258:	5f                   	pop    %edi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 14             	sub    $0x14,%esp
  801262:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	53                   	push   %ebx
  80126a:	e8 7d fd ff ff       	call   800fec <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	89 c2                	mov    %eax,%edx
  801274:	85 c0                	test   %eax,%eax
  801276:	78 6d                	js     8012e5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801282:	ff 30                	pushl  (%eax)
  801284:	e8 b9 fd ff ff       	call   801042 <dev_lookup>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 4c                	js     8012dc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801290:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801293:	8b 42 08             	mov    0x8(%edx),%eax
  801296:	83 e0 03             	and    $0x3,%eax
  801299:	83 f8 01             	cmp    $0x1,%eax
  80129c:	75 21                	jne    8012bf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80129e:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a3:	8b 40 48             	mov    0x48(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	68 0d 2a 80 00       	push   $0x802a0d
  8012b0:	e8 4b ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bd:	eb 26                	jmp    8012e5 <read+0x8a>
	}
	if (!dev->dev_read)
  8012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c2:	8b 40 08             	mov    0x8(%eax),%eax
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	74 17                	je     8012e0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	ff 75 10             	pushl  0x10(%ebp)
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
  8012d2:	52                   	push   %edx
  8012d3:	ff d0                	call   *%eax
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	eb 09                	jmp    8012e5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	eb 05                	jmp    8012e5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012e5:	89 d0                	mov    %edx,%eax
  8012e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	57                   	push   %edi
  8012f0:	56                   	push   %esi
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801300:	eb 21                	jmp    801323 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801302:	83 ec 04             	sub    $0x4,%esp
  801305:	89 f0                	mov    %esi,%eax
  801307:	29 d8                	sub    %ebx,%eax
  801309:	50                   	push   %eax
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	03 45 0c             	add    0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	57                   	push   %edi
  801311:	e8 45 ff ff ff       	call   80125b <read>
		if (m < 0)
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 0c                	js     801329 <readn+0x3d>
			return m;
		if (m == 0)
  80131d:	85 c0                	test   %eax,%eax
  80131f:	74 06                	je     801327 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801321:	01 c3                	add    %eax,%ebx
  801323:	39 f3                	cmp    %esi,%ebx
  801325:	72 db                	jb     801302 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801327:	89 d8                	mov    %ebx,%eax
}
  801329:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5f                   	pop    %edi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	53                   	push   %ebx
  801335:	83 ec 14             	sub    $0x14,%esp
  801338:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	53                   	push   %ebx
  801340:	e8 a7 fc ff ff       	call   800fec <fd_lookup>
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	89 c2                	mov    %eax,%edx
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 68                	js     8013b6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801358:	ff 30                	pushl  (%eax)
  80135a:	e8 e3 fc ff ff       	call   801042 <dev_lookup>
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 47                	js     8013ad <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801366:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801369:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80136d:	75 21                	jne    801390 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80136f:	a1 08 40 80 00       	mov    0x804008,%eax
  801374:	8b 40 48             	mov    0x48(%eax),%eax
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	53                   	push   %ebx
  80137b:	50                   	push   %eax
  80137c:	68 29 2a 80 00       	push   $0x802a29
  801381:	e8 7a ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138e:	eb 26                	jmp    8013b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801393:	8b 52 0c             	mov    0xc(%edx),%edx
  801396:	85 d2                	test   %edx,%edx
  801398:	74 17                	je     8013b1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	ff 75 10             	pushl  0x10(%ebp)
  8013a0:	ff 75 0c             	pushl  0xc(%ebp)
  8013a3:	50                   	push   %eax
  8013a4:	ff d2                	call   *%edx
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	eb 09                	jmp    8013b6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	eb 05                	jmp    8013b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013b6:	89 d0                	mov    %edx,%eax
  8013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 75 08             	pushl  0x8(%ebp)
  8013ca:	e8 1d fc ff ff       	call   800fec <fd_lookup>
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 0e                	js     8013e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 14             	sub    $0x14,%esp
  8013ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	53                   	push   %ebx
  8013f5:	e8 f2 fb ff ff       	call   800fec <fd_lookup>
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 65                	js     801468 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	ff 30                	pushl  (%eax)
  80140f:	e8 2e fc ff ff       	call   801042 <dev_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 44                	js     80145f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801422:	75 21                	jne    801445 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801424:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801429:	8b 40 48             	mov    0x48(%eax),%eax
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	53                   	push   %ebx
  801430:	50                   	push   %eax
  801431:	68 ec 29 80 00       	push   $0x8029ec
  801436:	e8 c5 ed ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801443:	eb 23                	jmp    801468 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801445:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801448:	8b 52 18             	mov    0x18(%edx),%edx
  80144b:	85 d2                	test   %edx,%edx
  80144d:	74 14                	je     801463 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	ff 75 0c             	pushl  0xc(%ebp)
  801455:	50                   	push   %eax
  801456:	ff d2                	call   *%edx
  801458:	89 c2                	mov    %eax,%edx
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	eb 09                	jmp    801468 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	89 c2                	mov    %eax,%edx
  801461:	eb 05                	jmp    801468 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801463:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801468:	89 d0                	mov    %edx,%eax
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801479:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	ff 75 08             	pushl  0x8(%ebp)
  801480:	e8 67 fb ff ff       	call   800fec <fd_lookup>
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	89 c2                	mov    %eax,%edx
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 58                	js     8014e6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801498:	ff 30                	pushl  (%eax)
  80149a:	e8 a3 fb ff ff       	call   801042 <dev_lookup>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 37                	js     8014dd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014ad:	74 32                	je     8014e1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b9:	00 00 00 
	stat->st_isdir = 0;
  8014bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014c3:	00 00 00 
	stat->st_dev = dev;
  8014c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8014d3:	ff 50 14             	call   *0x14(%eax)
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 09                	jmp    8014e6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	eb 05                	jmp    8014e6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	6a 00                	push   $0x0
  8014f7:	ff 75 08             	pushl  0x8(%ebp)
  8014fa:	e8 09 02 00 00       	call   801708 <open>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	85 db                	test   %ebx,%ebx
  801506:	78 1b                	js     801523 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	ff 75 0c             	pushl  0xc(%ebp)
  80150e:	53                   	push   %ebx
  80150f:	e8 5b ff ff ff       	call   80146f <fstat>
  801514:	89 c6                	mov    %eax,%esi
	close(fd);
  801516:	89 1c 24             	mov    %ebx,(%esp)
  801519:	e8 fd fb ff ff       	call   80111b <close>
	return r;
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	89 f0                	mov    %esi,%eax
}
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	56                   	push   %esi
  80152e:	53                   	push   %ebx
  80152f:	89 c6                	mov    %eax,%esi
  801531:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801533:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80153a:	75 12                	jne    80154e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	6a 01                	push   $0x1
  801541:	e8 c6 0d 00 00       	call   80230c <ipc_find_env>
  801546:	a3 00 40 80 00       	mov    %eax,0x804000
  80154b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80154e:	6a 07                	push   $0x7
  801550:	68 00 50 80 00       	push   $0x805000
  801555:	56                   	push   %esi
  801556:	ff 35 00 40 80 00    	pushl  0x804000
  80155c:	e8 57 0d 00 00       	call   8022b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801561:	83 c4 0c             	add    $0xc,%esp
  801564:	6a 00                	push   $0x0
  801566:	53                   	push   %ebx
  801567:	6a 00                	push   $0x0
  801569:	e8 e1 0c 00 00       	call   80224f <ipc_recv>
}
  80156e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	8b 40 0c             	mov    0xc(%eax),%eax
  801581:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801586:	8b 45 0c             	mov    0xc(%ebp),%eax
  801589:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 02 00 00 00       	mov    $0x2,%eax
  801598:	e8 8d ff ff ff       	call   80152a <fsipc>
}
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8015ba:	e8 6b ff ff ff       	call   80152a <fsipc>
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015db:	b8 05 00 00 00       	mov    $0x5,%eax
  8015e0:	e8 45 ff ff ff       	call   80152a <fsipc>
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	85 d2                	test   %edx,%edx
  8015e9:	78 2c                	js     801617 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	68 00 50 80 00       	push   $0x805000
  8015f3:	53                   	push   %ebx
  8015f4:	e8 8e f1 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8015fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801604:	a1 84 50 80 00       	mov    0x805084,%eax
  801609:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	8b 40 0c             	mov    0xc(%eax),%eax
  80162e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801633:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801636:	eb 3d                	jmp    801675 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801638:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80163e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801643:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	57                   	push   %edi
  80164a:	53                   	push   %ebx
  80164b:	68 08 50 80 00       	push   $0x805008
  801650:	e8 c4 f2 ff ff       	call   800919 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801655:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 04 00 00 00       	mov    $0x4,%eax
  801665:	e8 c0 fe ff ff       	call   80152a <fsipc>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 0d                	js     80167e <devfile_write+0x62>
		        return r;
                n -= tmp;
  801671:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801673:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801675:	85 f6                	test   %esi,%esi
  801677:	75 bf                	jne    801638 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	8b 40 0c             	mov    0xc(%eax),%eax
  801694:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801699:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8016a9:	e8 7c fe ff ff       	call   80152a <fsipc>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 4b                	js     8016ff <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016b4:	39 c6                	cmp    %eax,%esi
  8016b6:	73 16                	jae    8016ce <devfile_read+0x48>
  8016b8:	68 5c 2a 80 00       	push   $0x802a5c
  8016bd:	68 63 2a 80 00       	push   $0x802a63
  8016c2:	6a 7c                	push   $0x7c
  8016c4:	68 78 2a 80 00       	push   $0x802a78
  8016c9:	e8 3b 0b 00 00       	call   802209 <_panic>
	assert(r <= PGSIZE);
  8016ce:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016d3:	7e 16                	jle    8016eb <devfile_read+0x65>
  8016d5:	68 83 2a 80 00       	push   $0x802a83
  8016da:	68 63 2a 80 00       	push   $0x802a63
  8016df:	6a 7d                	push   $0x7d
  8016e1:	68 78 2a 80 00       	push   $0x802a78
  8016e6:	e8 1e 0b 00 00       	call   802209 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	50                   	push   %eax
  8016ef:	68 00 50 80 00       	push   $0x805000
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	e8 1d f2 ff ff       	call   800919 <memmove>
	return r;
  8016fc:	83 c4 10             	add    $0x10,%esp
}
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801704:	5b                   	pop    %ebx
  801705:	5e                   	pop    %esi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 20             	sub    $0x20,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801712:	53                   	push   %ebx
  801713:	e8 36 f0 ff ff       	call   80074e <strlen>
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801720:	7f 67                	jg     801789 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801722:	83 ec 0c             	sub    $0xc,%esp
  801725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801728:	50                   	push   %eax
  801729:	e8 6f f8 ff ff       	call   800f9d <fd_alloc>
  80172e:	83 c4 10             	add    $0x10,%esp
		return r;
  801731:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	78 57                	js     80178e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	53                   	push   %ebx
  80173b:	68 00 50 80 00       	push   $0x805000
  801740:	e8 42 f0 ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
  801748:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80174d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801750:	b8 01 00 00 00       	mov    $0x1,%eax
  801755:	e8 d0 fd ff ff       	call   80152a <fsipc>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	79 14                	jns    801777 <open+0x6f>
		fd_close(fd, 0);
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	6a 00                	push   $0x0
  801768:	ff 75 f4             	pushl  -0xc(%ebp)
  80176b:	e8 2a f9 ff ff       	call   80109a <fd_close>
		return r;
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	89 da                	mov    %ebx,%edx
  801775:	eb 17                	jmp    80178e <open+0x86>
	}

	return fd2num(fd);
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	ff 75 f4             	pushl  -0xc(%ebp)
  80177d:	e8 f4 f7 ff ff       	call   800f76 <fd2num>
  801782:	89 c2                	mov    %eax,%edx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	eb 05                	jmp    80178e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801789:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80178e:	89 d0                	mov    %edx,%eax
  801790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a5:	e8 80 fd ff ff       	call   80152a <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8017ac:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017b0:	7e 37                	jle    8017e9 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017bb:	ff 70 04             	pushl  0x4(%eax)
  8017be:	8d 40 10             	lea    0x10(%eax),%eax
  8017c1:	50                   	push   %eax
  8017c2:	ff 33                	pushl  (%ebx)
  8017c4:	e8 68 fb ff ff       	call   801331 <write>
		if (result > 0)
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	7e 03                	jle    8017d3 <writebuf+0x27>
			b->result += result;
  8017d0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017d3:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017d6:	74 0d                	je     8017e5 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	ba 00 00 00 00       	mov    $0x0,%edx
  8017df:	0f 4f c2             	cmovg  %edx,%eax
  8017e2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e8:	c9                   	leave  
  8017e9:	f3 c3                	repz ret 

008017eb <putch>:

static void
putch(int ch, void *thunk)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017f5:	8b 53 04             	mov    0x4(%ebx),%edx
  8017f8:	8d 42 01             	lea    0x1(%edx),%eax
  8017fb:	89 43 04             	mov    %eax,0x4(%ebx)
  8017fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801801:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801805:	3d 00 01 00 00       	cmp    $0x100,%eax
  80180a:	75 0e                	jne    80181a <putch+0x2f>
		writebuf(b);
  80180c:	89 d8                	mov    %ebx,%eax
  80180e:	e8 99 ff ff ff       	call   8017ac <writebuf>
		b->idx = 0;
  801813:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80181a:	83 c4 04             	add    $0x4,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801832:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801839:	00 00 00 
	b.result = 0;
  80183c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801843:	00 00 00 
	b.error = 1;
  801846:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80184d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801850:	ff 75 10             	pushl  0x10(%ebp)
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	68 eb 17 80 00       	push   $0x8017eb
  801862:	e8 cb ea ff ff       	call   800332 <vprintfmt>
	if (b.idx > 0)
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801871:	7e 0b                	jle    80187e <vfprintf+0x5e>
		writebuf(&b);
  801873:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801879:	e8 2e ff ff ff       	call   8017ac <writebuf>

	return (b.result ? b.result : b.error);
  80187e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801884:	85 c0                	test   %eax,%eax
  801886:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801895:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801898:	50                   	push   %eax
  801899:	ff 75 0c             	pushl  0xc(%ebp)
  80189c:	ff 75 08             	pushl  0x8(%ebp)
  80189f:	e8 7c ff ff ff       	call   801820 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <printf>:

int
printf(const char *fmt, ...)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018af:	50                   	push   %eax
  8018b0:	ff 75 08             	pushl  0x8(%ebp)
  8018b3:	6a 01                	push   $0x1
  8018b5:	e8 66 ff ff ff       	call   801820 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018c2:	68 8f 2a 80 00       	push   $0x802a8f
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	e8 b8 ee ff ff       	call   800787 <strcpy>
	return 0;
}
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 10             	sub    $0x10,%esp
  8018dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018e0:	53                   	push   %ebx
  8018e1:	e8 5e 0a 00 00       	call   802344 <pageref>
  8018e6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018ee:	83 f8 01             	cmp    $0x1,%eax
  8018f1:	75 10                	jne    801903 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	ff 73 0c             	pushl  0xc(%ebx)
  8018f9:	e8 ca 02 00 00       	call   801bc8 <nsipc_close>
  8018fe:	89 c2                	mov    %eax,%edx
  801900:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801903:	89 d0                	mov    %edx,%eax
  801905:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801910:	6a 00                	push   $0x0
  801912:	ff 75 10             	pushl  0x10(%ebp)
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	ff 70 0c             	pushl  0xc(%eax)
  80191e:	e8 82 03 00 00       	call   801ca5 <nsipc_send>
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80192b:	6a 00                	push   $0x0
  80192d:	ff 75 10             	pushl  0x10(%ebp)
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	ff 70 0c             	pushl  0xc(%eax)
  801939:	e8 fb 02 00 00       	call   801c39 <nsipc_recv>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801946:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801949:	52                   	push   %edx
  80194a:	50                   	push   %eax
  80194b:	e8 9c f6 ff ff       	call   800fec <fd_lookup>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	78 17                	js     80196e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801960:	39 08                	cmp    %ecx,(%eax)
  801962:	75 05                	jne    801969 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801964:	8b 40 0c             	mov    0xc(%eax),%eax
  801967:	eb 05                	jmp    80196e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801969:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
  801975:	83 ec 1c             	sub    $0x1c,%esp
  801978:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80197a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	e8 1a f6 ff ff       	call   800f9d <fd_alloc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 1b                	js     8019a7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	68 07 04 00 00       	push   $0x407
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	6a 00                	push   $0x0
  801999:	e8 f2 f1 ff ff       	call   800b90 <sys_page_alloc>
  80199e:	89 c3                	mov    %eax,%ebx
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	79 10                	jns    8019b7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019a7:	83 ec 0c             	sub    $0xc,%esp
  8019aa:	56                   	push   %esi
  8019ab:	e8 18 02 00 00       	call   801bc8 <nsipc_close>
		return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	eb 24                	jmp    8019db <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019b7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c5:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8019cc:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	52                   	push   %edx
  8019d3:	e8 9e f5 ff ff       	call   800f76 <fd2num>
  8019d8:	83 c4 10             	add    $0x10,%esp
}
  8019db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	e8 50 ff ff ff       	call   801940 <fd2sockid>
		return r;
  8019f0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 1f                	js     801a15 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	ff 75 10             	pushl  0x10(%ebp)
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	50                   	push   %eax
  801a00:	e8 1c 01 00 00       	call   801b21 <nsipc_accept>
  801a05:	83 c4 10             	add    $0x10,%esp
		return r;
  801a08:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 07                	js     801a15 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a0e:	e8 5d ff ff ff       	call   801970 <alloc_sockfd>
  801a13:	89 c1                	mov    %eax,%ecx
}
  801a15:	89 c8                	mov    %ecx,%eax
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	e8 19 ff ff ff       	call   801940 <fd2sockid>
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	85 d2                	test   %edx,%edx
  801a2b:	78 12                	js     801a3f <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	ff 75 10             	pushl  0x10(%ebp)
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	52                   	push   %edx
  801a37:	e8 35 01 00 00       	call   801b71 <nsipc_bind>
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <shutdown>:

int
shutdown(int s, int how)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	e8 f1 fe ff ff       	call   801940 <fd2sockid>
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	85 d2                	test   %edx,%edx
  801a53:	78 0f                	js     801a64 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a55:	83 ec 08             	sub    $0x8,%esp
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	52                   	push   %edx
  801a5c:	e8 45 01 00 00       	call   801ba6 <nsipc_shutdown>
  801a61:	83 c4 10             	add    $0x10,%esp
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	e8 cc fe ff ff       	call   801940 <fd2sockid>
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	85 d2                	test   %edx,%edx
  801a78:	78 12                	js     801a8c <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	ff 75 10             	pushl  0x10(%ebp)
  801a80:	ff 75 0c             	pushl  0xc(%ebp)
  801a83:	52                   	push   %edx
  801a84:	e8 59 01 00 00       	call   801be2 <nsipc_connect>
  801a89:	83 c4 10             	add    $0x10,%esp
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <listen>:

int
listen(int s, int backlog)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	e8 a4 fe ff ff       	call   801940 <fd2sockid>
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	85 d2                	test   %edx,%edx
  801aa0:	78 0f                	js     801ab1 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801aa2:	83 ec 08             	sub    $0x8,%esp
  801aa5:	ff 75 0c             	pushl  0xc(%ebp)
  801aa8:	52                   	push   %edx
  801aa9:	e8 69 01 00 00       	call   801c17 <nsipc_listen>
  801aae:	83 c4 10             	add    $0x10,%esp
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ab9:	ff 75 10             	pushl  0x10(%ebp)
  801abc:	ff 75 0c             	pushl  0xc(%ebp)
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	e8 3c 02 00 00       	call   801d03 <nsipc_socket>
  801ac7:	89 c2                	mov    %eax,%edx
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	85 d2                	test   %edx,%edx
  801ace:	78 05                	js     801ad5 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801ad0:	e8 9b fe ff ff       	call   801970 <alloc_sockfd>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	53                   	push   %ebx
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ae0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ae7:	75 12                	jne    801afb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	6a 02                	push   $0x2
  801aee:	e8 19 08 00 00       	call   80230c <ipc_find_env>
  801af3:	a3 04 40 80 00       	mov    %eax,0x804004
  801af8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801afb:	6a 07                	push   $0x7
  801afd:	68 00 60 80 00       	push   $0x806000
  801b02:	53                   	push   %ebx
  801b03:	ff 35 04 40 80 00    	pushl  0x804004
  801b09:	e8 aa 07 00 00       	call   8022b8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b0e:	83 c4 0c             	add    $0xc,%esp
  801b11:	6a 00                	push   $0x0
  801b13:	6a 00                	push   $0x0
  801b15:	6a 00                	push   $0x0
  801b17:	e8 33 07 00 00       	call   80224f <ipc_recv>
}
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b31:	8b 06                	mov    (%esi),%eax
  801b33:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b38:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3d:	e8 95 ff ff ff       	call   801ad7 <nsipc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 20                	js     801b68 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	ff 35 10 60 80 00    	pushl  0x806010
  801b51:	68 00 60 80 00       	push   $0x806000
  801b56:	ff 75 0c             	pushl  0xc(%ebp)
  801b59:	e8 bb ed ff ff       	call   800919 <memmove>
		*addrlen = ret->ret_addrlen;
  801b5e:	a1 10 60 80 00       	mov    0x806010,%eax
  801b63:	89 06                	mov    %eax,(%esi)
  801b65:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b68:	89 d8                	mov    %ebx,%eax
  801b6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5e                   	pop    %esi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b83:	53                   	push   %ebx
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	68 04 60 80 00       	push   $0x806004
  801b8c:	e8 88 ed ff ff       	call   800919 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b91:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b97:	b8 02 00 00 00       	mov    $0x2,%eax
  801b9c:	e8 36 ff ff ff       	call   801ad7 <nsipc>
}
  801ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bbc:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc1:	e8 11 ff ff ff       	call   801ad7 <nsipc>
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <nsipc_close>:

int
nsipc_close(int s)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  801bdb:	e8 f7 fe ff ff       	call   801ad7 <nsipc>
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	53                   	push   %ebx
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bf4:	53                   	push   %ebx
  801bf5:	ff 75 0c             	pushl  0xc(%ebp)
  801bf8:	68 04 60 80 00       	push   $0x806004
  801bfd:	e8 17 ed ff ff       	call   800919 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c02:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c08:	b8 05 00 00 00       	mov    $0x5,%eax
  801c0d:	e8 c5 fe ff ff       	call   801ad7 <nsipc>
}
  801c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c28:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  801c32:	e8 a0 fe ff ff       	call   801ad7 <nsipc>
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c49:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c4f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c52:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c57:	b8 07 00 00 00       	mov    $0x7,%eax
  801c5c:	e8 76 fe ff ff       	call   801ad7 <nsipc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 35                	js     801c9c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c67:	39 f0                	cmp    %esi,%eax
  801c69:	7f 07                	jg     801c72 <nsipc_recv+0x39>
  801c6b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c70:	7e 16                	jle    801c88 <nsipc_recv+0x4f>
  801c72:	68 9b 2a 80 00       	push   $0x802a9b
  801c77:	68 63 2a 80 00       	push   $0x802a63
  801c7c:	6a 62                	push   $0x62
  801c7e:	68 b0 2a 80 00       	push   $0x802ab0
  801c83:	e8 81 05 00 00       	call   802209 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c88:	83 ec 04             	sub    $0x4,%esp
  801c8b:	50                   	push   %eax
  801c8c:	68 00 60 80 00       	push   $0x806000
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	e8 80 ec ff ff       	call   800919 <memmove>
  801c99:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca1:	5b                   	pop    %ebx
  801ca2:	5e                   	pop    %esi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 04             	sub    $0x4,%esp
  801cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cb7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cbd:	7e 16                	jle    801cd5 <nsipc_send+0x30>
  801cbf:	68 bc 2a 80 00       	push   $0x802abc
  801cc4:	68 63 2a 80 00       	push   $0x802a63
  801cc9:	6a 6d                	push   $0x6d
  801ccb:	68 b0 2a 80 00       	push   $0x802ab0
  801cd0:	e8 34 05 00 00       	call   802209 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cd5:	83 ec 04             	sub    $0x4,%esp
  801cd8:	53                   	push   %ebx
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	68 0c 60 80 00       	push   $0x80600c
  801ce1:	e8 33 ec ff ff       	call   800919 <memmove>
	nsipcbuf.send.req_size = size;
  801ce6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cec:	8b 45 14             	mov    0x14(%ebp),%eax
  801cef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf9:	e8 d9 fd ff ff       	call   801ad7 <nsipc>
}
  801cfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d14:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d19:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d21:	b8 09 00 00 00       	mov    $0x9,%eax
  801d26:	e8 ac fd ff ff       	call   801ad7 <nsipc>
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	56                   	push   %esi
  801d31:	53                   	push   %ebx
  801d32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	ff 75 08             	pushl  0x8(%ebp)
  801d3b:	e8 46 f2 ff ff       	call   800f86 <fd2data>
  801d40:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d42:	83 c4 08             	add    $0x8,%esp
  801d45:	68 c8 2a 80 00       	push   $0x802ac8
  801d4a:	53                   	push   %ebx
  801d4b:	e8 37 ea ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d50:	8b 56 04             	mov    0x4(%esi),%edx
  801d53:	89 d0                	mov    %edx,%eax
  801d55:	2b 06                	sub    (%esi),%eax
  801d57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d64:	00 00 00 
	stat->st_dev = &devpipe;
  801d67:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d6e:	30 80 00 
	return 0;
}
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
  801d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	53                   	push   %ebx
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d87:	53                   	push   %ebx
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 86 ee ff ff       	call   800c15 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d8f:	89 1c 24             	mov    %ebx,(%esp)
  801d92:	e8 ef f1 ff ff       	call   800f86 <fd2data>
  801d97:	83 c4 08             	add    $0x8,%esp
  801d9a:	50                   	push   %eax
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 73 ee ff ff       	call   800c15 <sys_page_unmap>
}
  801da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	57                   	push   %edi
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 1c             	sub    $0x1c,%esp
  801db0:	89 c6                	mov    %eax,%esi
  801db2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801db5:	a1 08 40 80 00       	mov    0x804008,%eax
  801dba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801dbd:	83 ec 0c             	sub    $0xc,%esp
  801dc0:	56                   	push   %esi
  801dc1:	e8 7e 05 00 00       	call   802344 <pageref>
  801dc6:	89 c7                	mov    %eax,%edi
  801dc8:	83 c4 04             	add    $0x4,%esp
  801dcb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dce:	e8 71 05 00 00       	call   802344 <pageref>
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	39 c7                	cmp    %eax,%edi
  801dd8:	0f 94 c2             	sete   %dl
  801ddb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801dde:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801de4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801de7:	39 fb                	cmp    %edi,%ebx
  801de9:	74 19                	je     801e04 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801deb:	84 d2                	test   %dl,%dl
  801ded:	74 c6                	je     801db5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801def:	8b 51 58             	mov    0x58(%ecx),%edx
  801df2:	50                   	push   %eax
  801df3:	52                   	push   %edx
  801df4:	53                   	push   %ebx
  801df5:	68 cf 2a 80 00       	push   $0x802acf
  801dfa:	e8 01 e4 ff ff       	call   800200 <cprintf>
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	eb b1                	jmp    801db5 <_pipeisclosed+0xe>
	}
}
  801e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	57                   	push   %edi
  801e10:	56                   	push   %esi
  801e11:	53                   	push   %ebx
  801e12:	83 ec 28             	sub    $0x28,%esp
  801e15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e18:	56                   	push   %esi
  801e19:	e8 68 f1 ff ff       	call   800f86 <fd2data>
  801e1e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	bf 00 00 00 00       	mov    $0x0,%edi
  801e28:	eb 4b                	jmp    801e75 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e2a:	89 da                	mov    %ebx,%edx
  801e2c:	89 f0                	mov    %esi,%eax
  801e2e:	e8 74 ff ff ff       	call   801da7 <_pipeisclosed>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	75 48                	jne    801e7f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e37:	e8 35 ed ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e3f:	8b 0b                	mov    (%ebx),%ecx
  801e41:	8d 51 20             	lea    0x20(%ecx),%edx
  801e44:	39 d0                	cmp    %edx,%eax
  801e46:	73 e2                	jae    801e2a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e4f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	c1 fa 1f             	sar    $0x1f,%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	c1 e9 1b             	shr    $0x1b,%ecx
  801e5c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e5f:	83 e2 1f             	and    $0x1f,%edx
  801e62:	29 ca                	sub    %ecx,%edx
  801e64:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e68:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e6c:	83 c0 01             	add    $0x1,%eax
  801e6f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e72:	83 c7 01             	add    $0x1,%edi
  801e75:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e78:	75 c2                	jne    801e3c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e7d:	eb 05                	jmp    801e84 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e7f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5f                   	pop    %edi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	57                   	push   %edi
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	83 ec 18             	sub    $0x18,%esp
  801e95:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e98:	57                   	push   %edi
  801e99:	e8 e8 f0 ff ff       	call   800f86 <fd2data>
  801e9e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea8:	eb 3d                	jmp    801ee7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801eaa:	85 db                	test   %ebx,%ebx
  801eac:	74 04                	je     801eb2 <devpipe_read+0x26>
				return i;
  801eae:	89 d8                	mov    %ebx,%eax
  801eb0:	eb 44                	jmp    801ef6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	e8 ec fe ff ff       	call   801da7 <_pipeisclosed>
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	75 32                	jne    801ef1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ebf:	e8 ad ec ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ec4:	8b 06                	mov    (%esi),%eax
  801ec6:	3b 46 04             	cmp    0x4(%esi),%eax
  801ec9:	74 df                	je     801eaa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ecb:	99                   	cltd   
  801ecc:	c1 ea 1b             	shr    $0x1b,%edx
  801ecf:	01 d0                	add    %edx,%eax
  801ed1:	83 e0 1f             	and    $0x1f,%eax
  801ed4:	29 d0                	sub    %edx,%eax
  801ed6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ede:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ee1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee4:	83 c3 01             	add    $0x1,%ebx
  801ee7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eea:	75 d8                	jne    801ec4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eec:	8b 45 10             	mov    0x10(%ebp),%eax
  801eef:	eb 05                	jmp    801ef6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5f                   	pop    %edi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f09:	50                   	push   %eax
  801f0a:	e8 8e f0 ff ff       	call   800f9d <fd_alloc>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	89 c2                	mov    %eax,%edx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 88 2c 01 00 00    	js     802048 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	68 07 04 00 00       	push   $0x407
  801f24:	ff 75 f4             	pushl  -0xc(%ebp)
  801f27:	6a 00                	push   $0x0
  801f29:	e8 62 ec ff ff       	call   800b90 <sys_page_alloc>
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	89 c2                	mov    %eax,%edx
  801f33:	85 c0                	test   %eax,%eax
  801f35:	0f 88 0d 01 00 00    	js     802048 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f41:	50                   	push   %eax
  801f42:	e8 56 f0 ff ff       	call   800f9d <fd_alloc>
  801f47:	89 c3                	mov    %eax,%ebx
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	0f 88 e2 00 00 00    	js     802036 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f54:	83 ec 04             	sub    $0x4,%esp
  801f57:	68 07 04 00 00       	push   $0x407
  801f5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 2a ec ff ff       	call   800b90 <sys_page_alloc>
  801f66:	89 c3                	mov    %eax,%ebx
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	0f 88 c3 00 00 00    	js     802036 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f73:	83 ec 0c             	sub    $0xc,%esp
  801f76:	ff 75 f4             	pushl  -0xc(%ebp)
  801f79:	e8 08 f0 ff ff       	call   800f86 <fd2data>
  801f7e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f80:	83 c4 0c             	add    $0xc,%esp
  801f83:	68 07 04 00 00       	push   $0x407
  801f88:	50                   	push   %eax
  801f89:	6a 00                	push   $0x0
  801f8b:	e8 00 ec ff ff       	call   800b90 <sys_page_alloc>
  801f90:	89 c3                	mov    %eax,%ebx
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	85 c0                	test   %eax,%eax
  801f97:	0f 88 89 00 00 00    	js     802026 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9d:	83 ec 0c             	sub    $0xc,%esp
  801fa0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa3:	e8 de ef ff ff       	call   800f86 <fd2data>
  801fa8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801faf:	50                   	push   %eax
  801fb0:	6a 00                	push   $0x0
  801fb2:	56                   	push   %esi
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 19 ec ff ff       	call   800bd3 <sys_page_map>
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	83 c4 20             	add    $0x20,%esp
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 55                	js     802018 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fc3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fed:	83 ec 0c             	sub    $0xc,%esp
  801ff0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff3:	e8 7e ef ff ff       	call   800f76 <fd2num>
  801ff8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ffb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ffd:	83 c4 04             	add    $0x4,%esp
  802000:	ff 75 f0             	pushl  -0x10(%ebp)
  802003:	e8 6e ef ff ff       	call   800f76 <fd2num>
  802008:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80200b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	ba 00 00 00 00       	mov    $0x0,%edx
  802016:	eb 30                	jmp    802048 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802018:	83 ec 08             	sub    $0x8,%esp
  80201b:	56                   	push   %esi
  80201c:	6a 00                	push   $0x0
  80201e:	e8 f2 eb ff ff       	call   800c15 <sys_page_unmap>
  802023:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802026:	83 ec 08             	sub    $0x8,%esp
  802029:	ff 75 f0             	pushl  -0x10(%ebp)
  80202c:	6a 00                	push   $0x0
  80202e:	e8 e2 eb ff ff       	call   800c15 <sys_page_unmap>
  802033:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802036:	83 ec 08             	sub    $0x8,%esp
  802039:	ff 75 f4             	pushl  -0xc(%ebp)
  80203c:	6a 00                	push   $0x0
  80203e:	e8 d2 eb ff ff       	call   800c15 <sys_page_unmap>
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802048:	89 d0                	mov    %edx,%eax
  80204a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802057:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	ff 75 08             	pushl  0x8(%ebp)
  80205e:	e8 89 ef ff ff       	call   800fec <fd_lookup>
  802063:	89 c2                	mov    %eax,%edx
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 d2                	test   %edx,%edx
  80206a:	78 18                	js     802084 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80206c:	83 ec 0c             	sub    $0xc,%esp
  80206f:	ff 75 f4             	pushl  -0xc(%ebp)
  802072:	e8 0f ef ff ff       	call   800f86 <fd2data>
	return _pipeisclosed(fd, p);
  802077:	89 c2                	mov    %eax,%edx
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	e8 26 fd ff ff       	call   801da7 <_pipeisclosed>
  802081:	83 c4 10             	add    $0x10,%esp
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802089:	b8 00 00 00 00       	mov    $0x0,%eax
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    

00802090 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802096:	68 e7 2a 80 00       	push   $0x802ae7
  80209b:	ff 75 0c             	pushl  0xc(%ebp)
  80209e:	e8 e4 e6 ff ff       	call   800787 <strcpy>
	return 0;
}
  8020a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	57                   	push   %edi
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
  8020b0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c1:	eb 2d                	jmp    8020f0 <devcons_write+0x46>
		m = n - tot;
  8020c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020c6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020c8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020cb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020d0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020d3:	83 ec 04             	sub    $0x4,%esp
  8020d6:	53                   	push   %ebx
  8020d7:	03 45 0c             	add    0xc(%ebp),%eax
  8020da:	50                   	push   %eax
  8020db:	57                   	push   %edi
  8020dc:	e8 38 e8 ff ff       	call   800919 <memmove>
		sys_cputs(buf, m);
  8020e1:	83 c4 08             	add    $0x8,%esp
  8020e4:	53                   	push   %ebx
  8020e5:	57                   	push   %edi
  8020e6:	e8 e9 e9 ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020eb:	01 de                	add    %ebx,%esi
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	89 f0                	mov    %esi,%eax
  8020f2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020f5:	72 cc                	jb     8020c3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80210a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80210e:	75 07                	jne    802117 <devcons_read+0x18>
  802110:	eb 28                	jmp    80213a <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802112:	e8 5a ea ff ff       	call   800b71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802117:	e8 d6 e9 ff ff       	call   800af2 <sys_cgetc>
  80211c:	85 c0                	test   %eax,%eax
  80211e:	74 f2                	je     802112 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802120:	85 c0                	test   %eax,%eax
  802122:	78 16                	js     80213a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802124:	83 f8 04             	cmp    $0x4,%eax
  802127:	74 0c                	je     802135 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802129:	8b 55 0c             	mov    0xc(%ebp),%edx
  80212c:	88 02                	mov    %al,(%edx)
	return 1;
  80212e:	b8 01 00 00 00       	mov    $0x1,%eax
  802133:	eb 05                	jmp    80213a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802135:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80213a:	c9                   	leave  
  80213b:	c3                   	ret    

0080213c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802142:	8b 45 08             	mov    0x8(%ebp),%eax
  802145:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802148:	6a 01                	push   $0x1
  80214a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214d:	50                   	push   %eax
  80214e:	e8 81 e9 ff ff       	call   800ad4 <sys_cputs>
  802153:	83 c4 10             	add    $0x10,%esp
}
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <getchar>:

int
getchar(void)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80215e:	6a 01                	push   $0x1
  802160:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802163:	50                   	push   %eax
  802164:	6a 00                	push   $0x0
  802166:	e8 f0 f0 ff ff       	call   80125b <read>
	if (r < 0)
  80216b:	83 c4 10             	add    $0x10,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 0f                	js     802181 <getchar+0x29>
		return r;
	if (r < 1)
  802172:	85 c0                	test   %eax,%eax
  802174:	7e 06                	jle    80217c <getchar+0x24>
		return -E_EOF;
	return c;
  802176:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80217a:	eb 05                	jmp    802181 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80217c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802189:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218c:	50                   	push   %eax
  80218d:	ff 75 08             	pushl  0x8(%ebp)
  802190:	e8 57 ee ff ff       	call   800fec <fd_lookup>
  802195:	83 c4 10             	add    $0x10,%esp
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 11                	js     8021ad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021a5:	39 10                	cmp    %edx,(%eax)
  8021a7:	0f 94 c0             	sete   %al
  8021aa:	0f b6 c0             	movzbl %al,%eax
}
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <opencons>:

int
opencons(void)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b8:	50                   	push   %eax
  8021b9:	e8 df ed ff ff       	call   800f9d <fd_alloc>
  8021be:	83 c4 10             	add    $0x10,%esp
		return r;
  8021c1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c3:	85 c0                	test   %eax,%eax
  8021c5:	78 3e                	js     802205 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021c7:	83 ec 04             	sub    $0x4,%esp
  8021ca:	68 07 04 00 00       	push   $0x407
  8021cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 b7 e9 ff ff       	call   800b90 <sys_page_alloc>
  8021d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8021dc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 23                	js     802205 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021e2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021eb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021f7:	83 ec 0c             	sub    $0xc,%esp
  8021fa:	50                   	push   %eax
  8021fb:	e8 76 ed ff ff       	call   800f76 <fd2num>
  802200:	89 c2                	mov    %eax,%edx
  802202:	83 c4 10             	add    $0x10,%esp
}
  802205:	89 d0                	mov    %edx,%eax
  802207:	c9                   	leave  
  802208:	c3                   	ret    

00802209 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802209:	55                   	push   %ebp
  80220a:	89 e5                	mov    %esp,%ebp
  80220c:	56                   	push   %esi
  80220d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80220e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802211:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802217:	e8 36 e9 ff ff       	call   800b52 <sys_getenvid>
  80221c:	83 ec 0c             	sub    $0xc,%esp
  80221f:	ff 75 0c             	pushl  0xc(%ebp)
  802222:	ff 75 08             	pushl  0x8(%ebp)
  802225:	56                   	push   %esi
  802226:	50                   	push   %eax
  802227:	68 f4 2a 80 00       	push   $0x802af4
  80222c:	e8 cf df ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802231:	83 c4 18             	add    $0x18,%esp
  802234:	53                   	push   %ebx
  802235:	ff 75 10             	pushl  0x10(%ebp)
  802238:	e8 72 df ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  80223d:	c7 04 24 50 26 80 00 	movl   $0x802650,(%esp)
  802244:	e8 b7 df ff ff       	call   800200 <cprintf>
  802249:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80224c:	cc                   	int3   
  80224d:	eb fd                	jmp    80224c <_panic+0x43>

0080224f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	8b 75 08             	mov    0x8(%ebp),%esi
  802257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80225d:	85 c0                	test   %eax,%eax
  80225f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802264:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802267:	83 ec 0c             	sub    $0xc,%esp
  80226a:	50                   	push   %eax
  80226b:	e8 d0 ea ff ff       	call   800d40 <sys_ipc_recv>
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	85 c0                	test   %eax,%eax
  802275:	79 16                	jns    80228d <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802277:	85 f6                	test   %esi,%esi
  802279:	74 06                	je     802281 <ipc_recv+0x32>
  80227b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802281:	85 db                	test   %ebx,%ebx
  802283:	74 2c                	je     8022b1 <ipc_recv+0x62>
  802285:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80228b:	eb 24                	jmp    8022b1 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80228d:	85 f6                	test   %esi,%esi
  80228f:	74 0a                	je     80229b <ipc_recv+0x4c>
  802291:	a1 08 40 80 00       	mov    0x804008,%eax
  802296:	8b 40 74             	mov    0x74(%eax),%eax
  802299:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80229b:	85 db                	test   %ebx,%ebx
  80229d:	74 0a                	je     8022a9 <ipc_recv+0x5a>
  80229f:	a1 08 40 80 00       	mov    0x804008,%eax
  8022a4:	8b 40 78             	mov    0x78(%eax),%eax
  8022a7:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8022a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8022ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    

008022b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	57                   	push   %edi
  8022bc:	56                   	push   %esi
  8022bd:	53                   	push   %ebx
  8022be:	83 ec 0c             	sub    $0xc,%esp
  8022c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8022ca:	85 db                	test   %ebx,%ebx
  8022cc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022d1:	0f 44 d8             	cmove  %eax,%ebx
  8022d4:	eb 1c                	jmp    8022f2 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8022d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022d9:	74 12                	je     8022ed <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8022db:	50                   	push   %eax
  8022dc:	68 18 2b 80 00       	push   $0x802b18
  8022e1:	6a 39                	push   $0x39
  8022e3:	68 33 2b 80 00       	push   $0x802b33
  8022e8:	e8 1c ff ff ff       	call   802209 <_panic>
                 sys_yield();
  8022ed:	e8 7f e8 ff ff       	call   800b71 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8022f2:	ff 75 14             	pushl  0x14(%ebp)
  8022f5:	53                   	push   %ebx
  8022f6:	56                   	push   %esi
  8022f7:	57                   	push   %edi
  8022f8:	e8 20 ea ff ff       	call   800d1d <sys_ipc_try_send>
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	85 c0                	test   %eax,%eax
  802302:	78 d2                	js     8022d6 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    

0080230c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802312:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802317:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80231a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802320:	8b 52 50             	mov    0x50(%edx),%edx
  802323:	39 ca                	cmp    %ecx,%edx
  802325:	75 0d                	jne    802334 <ipc_find_env+0x28>
			return envs[i].env_id;
  802327:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80232a:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80232f:	8b 40 08             	mov    0x8(%eax),%eax
  802332:	eb 0e                	jmp    802342 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802334:	83 c0 01             	add    $0x1,%eax
  802337:	3d 00 04 00 00       	cmp    $0x400,%eax
  80233c:	75 d9                	jne    802317 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80233e:	66 b8 00 00          	mov    $0x0,%ax
}
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    

00802344 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	c1 e8 16             	shr    $0x16,%eax
  80234f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80235b:	f6 c1 01             	test   $0x1,%cl
  80235e:	74 1d                	je     80237d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802360:	c1 ea 0c             	shr    $0xc,%edx
  802363:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80236a:	f6 c2 01             	test   $0x1,%dl
  80236d:	74 0e                	je     80237d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80236f:	c1 ea 0c             	shr    $0xc,%edx
  802372:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802379:	ef 
  80237a:	0f b7 c0             	movzwl %ax,%eax
}
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	83 ec 10             	sub    $0x10,%esp
  802386:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80238a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80238e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802392:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802396:	85 d2                	test   %edx,%edx
  802398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80239c:	89 34 24             	mov    %esi,(%esp)
  80239f:	89 c8                	mov    %ecx,%eax
  8023a1:	75 35                	jne    8023d8 <__udivdi3+0x58>
  8023a3:	39 f1                	cmp    %esi,%ecx
  8023a5:	0f 87 bd 00 00 00    	ja     802468 <__udivdi3+0xe8>
  8023ab:	85 c9                	test   %ecx,%ecx
  8023ad:	89 cd                	mov    %ecx,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f1                	div    %ecx
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 f0                	mov    %esi,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c6                	mov    %eax,%esi
  8023c4:	89 f8                	mov    %edi,%eax
  8023c6:	f7 f5                	div    %ebp
  8023c8:	89 f2                	mov    %esi,%edx
  8023ca:	83 c4 10             	add    $0x10,%esp
  8023cd:	5e                   	pop    %esi
  8023ce:	5f                   	pop    %edi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    
  8023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	3b 14 24             	cmp    (%esp),%edx
  8023db:	77 7b                	ja     802458 <__udivdi3+0xd8>
  8023dd:	0f bd f2             	bsr    %edx,%esi
  8023e0:	83 f6 1f             	xor    $0x1f,%esi
  8023e3:	0f 84 97 00 00 00    	je     802480 <__udivdi3+0x100>
  8023e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8023ee:	89 d7                	mov    %edx,%edi
  8023f0:	89 f1                	mov    %esi,%ecx
  8023f2:	29 f5                	sub    %esi,%ebp
  8023f4:	d3 e7                	shl    %cl,%edi
  8023f6:	89 c2                	mov    %eax,%edx
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	d3 ea                	shr    %cl,%edx
  8023fc:	89 f1                	mov    %esi,%ecx
  8023fe:	09 fa                	or     %edi,%edx
  802400:	8b 3c 24             	mov    (%esp),%edi
  802403:	d3 e0                	shl    %cl,%eax
  802405:	89 54 24 08          	mov    %edx,0x8(%esp)
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802413:	89 fa                	mov    %edi,%edx
  802415:	d3 ea                	shr    %cl,%edx
  802417:	89 f1                	mov    %esi,%ecx
  802419:	d3 e7                	shl    %cl,%edi
  80241b:	89 e9                	mov    %ebp,%ecx
  80241d:	d3 e8                	shr    %cl,%eax
  80241f:	09 c7                	or     %eax,%edi
  802421:	89 f8                	mov    %edi,%eax
  802423:	f7 74 24 08          	divl   0x8(%esp)
  802427:	89 d5                	mov    %edx,%ebp
  802429:	89 c7                	mov    %eax,%edi
  80242b:	f7 64 24 0c          	mull   0xc(%esp)
  80242f:	39 d5                	cmp    %edx,%ebp
  802431:	89 14 24             	mov    %edx,(%esp)
  802434:	72 11                	jb     802447 <__udivdi3+0xc7>
  802436:	8b 54 24 04          	mov    0x4(%esp),%edx
  80243a:	89 f1                	mov    %esi,%ecx
  80243c:	d3 e2                	shl    %cl,%edx
  80243e:	39 c2                	cmp    %eax,%edx
  802440:	73 5e                	jae    8024a0 <__udivdi3+0x120>
  802442:	3b 2c 24             	cmp    (%esp),%ebp
  802445:	75 59                	jne    8024a0 <__udivdi3+0x120>
  802447:	8d 47 ff             	lea    -0x1(%edi),%eax
  80244a:	31 f6                	xor    %esi,%esi
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi
  802458:	31 f6                	xor    %esi,%esi
  80245a:	31 c0                	xor    %eax,%eax
  80245c:	89 f2                	mov    %esi,%edx
  80245e:	83 c4 10             	add    $0x10,%esp
  802461:	5e                   	pop    %esi
  802462:	5f                   	pop    %edi
  802463:	5d                   	pop    %ebp
  802464:	c3                   	ret    
  802465:	8d 76 00             	lea    0x0(%esi),%esi
  802468:	89 f2                	mov    %esi,%edx
  80246a:	31 f6                	xor    %esi,%esi
  80246c:	89 f8                	mov    %edi,%eax
  80246e:	f7 f1                	div    %ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802484:	76 0b                	jbe    802491 <__udivdi3+0x111>
  802486:	31 c0                	xor    %eax,%eax
  802488:	3b 14 24             	cmp    (%esp),%edx
  80248b:	0f 83 37 ff ff ff    	jae    8023c8 <__udivdi3+0x48>
  802491:	b8 01 00 00 00       	mov    $0x1,%eax
  802496:	e9 2d ff ff ff       	jmp    8023c8 <__udivdi3+0x48>
  80249b:	90                   	nop
  80249c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	89 f8                	mov    %edi,%eax
  8024a2:	31 f6                	xor    %esi,%esi
  8024a4:	e9 1f ff ff ff       	jmp    8023c8 <__udivdi3+0x48>
  8024a9:	66 90                	xchg   %ax,%ax
  8024ab:	66 90                	xchg   %ax,%ax
  8024ad:	66 90                	xchg   %ax,%ax
  8024af:	90                   	nop

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	83 ec 20             	sub    $0x20,%esp
  8024b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8024ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c2:	89 c6                	mov    %eax,%esi
  8024c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8024d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8024d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	89 c2                	mov    %eax,%edx
  8024e0:	75 1e                	jne    802500 <__umoddi3+0x50>
  8024e2:	39 f7                	cmp    %esi,%edi
  8024e4:	76 52                	jbe    802538 <__umoddi3+0x88>
  8024e6:	89 c8                	mov    %ecx,%eax
  8024e8:	89 f2                	mov    %esi,%edx
  8024ea:	f7 f7                	div    %edi
  8024ec:	89 d0                	mov    %edx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	83 c4 20             	add    $0x20,%esp
  8024f3:	5e                   	pop    %esi
  8024f4:	5f                   	pop    %edi
  8024f5:	5d                   	pop    %ebp
  8024f6:	c3                   	ret    
  8024f7:	89 f6                	mov    %esi,%esi
  8024f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802500:	39 f0                	cmp    %esi,%eax
  802502:	77 5c                	ja     802560 <__umoddi3+0xb0>
  802504:	0f bd e8             	bsr    %eax,%ebp
  802507:	83 f5 1f             	xor    $0x1f,%ebp
  80250a:	75 64                	jne    802570 <__umoddi3+0xc0>
  80250c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802510:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802514:	0f 86 f6 00 00 00    	jbe    802610 <__umoddi3+0x160>
  80251a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80251e:	0f 82 ec 00 00 00    	jb     802610 <__umoddi3+0x160>
  802524:	8b 44 24 14          	mov    0x14(%esp),%eax
  802528:	8b 54 24 18          	mov    0x18(%esp),%edx
  80252c:	83 c4 20             	add    $0x20,%esp
  80252f:	5e                   	pop    %esi
  802530:	5f                   	pop    %edi
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
  802533:	90                   	nop
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	85 ff                	test   %edi,%edi
  80253a:	89 fd                	mov    %edi,%ebp
  80253c:	75 0b                	jne    802549 <__umoddi3+0x99>
  80253e:	b8 01 00 00 00       	mov    $0x1,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f7                	div    %edi
  802547:	89 c5                	mov    %eax,%ebp
  802549:	8b 44 24 10          	mov    0x10(%esp),%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	f7 f5                	div    %ebp
  802551:	89 c8                	mov    %ecx,%eax
  802553:	f7 f5                	div    %ebp
  802555:	eb 95                	jmp    8024ec <__umoddi3+0x3c>
  802557:	89 f6                	mov    %esi,%esi
  802559:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	83 c4 20             	add    $0x20,%esp
  802567:	5e                   	pop    %esi
  802568:	5f                   	pop    %edi
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    
  80256b:	90                   	nop
  80256c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802570:	b8 20 00 00 00       	mov    $0x20,%eax
  802575:	89 e9                	mov    %ebp,%ecx
  802577:	29 e8                	sub    %ebp,%eax
  802579:	d3 e2                	shl    %cl,%edx
  80257b:	89 c7                	mov    %eax,%edi
  80257d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802581:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e8                	shr    %cl,%eax
  802589:	89 c1                	mov    %eax,%ecx
  80258b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80258f:	09 d1                	or     %edx,%ecx
  802591:	89 fa                	mov    %edi,%edx
  802593:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802597:	89 e9                	mov    %ebp,%ecx
  802599:	d3 e0                	shl    %cl,%eax
  80259b:	89 f9                	mov    %edi,%ecx
  80259d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	d3 e8                	shr    %cl,%eax
  8025a5:	89 e9                	mov    %ebp,%ecx
  8025a7:	89 c7                	mov    %eax,%edi
  8025a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025ad:	d3 e6                	shl    %cl,%esi
  8025af:	89 d1                	mov    %edx,%ecx
  8025b1:	89 fa                	mov    %edi,%edx
  8025b3:	d3 e8                	shr    %cl,%eax
  8025b5:	89 e9                	mov    %ebp,%ecx
  8025b7:	09 f0                	or     %esi,%eax
  8025b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8025bd:	f7 74 24 10          	divl   0x10(%esp)
  8025c1:	d3 e6                	shl    %cl,%esi
  8025c3:	89 d1                	mov    %edx,%ecx
  8025c5:	f7 64 24 0c          	mull   0xc(%esp)
  8025c9:	39 d1                	cmp    %edx,%ecx
  8025cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8025cf:	89 d7                	mov    %edx,%edi
  8025d1:	89 c6                	mov    %eax,%esi
  8025d3:	72 0a                	jb     8025df <__umoddi3+0x12f>
  8025d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8025d9:	73 10                	jae    8025eb <__umoddi3+0x13b>
  8025db:	39 d1                	cmp    %edx,%ecx
  8025dd:	75 0c                	jne    8025eb <__umoddi3+0x13b>
  8025df:	89 d7                	mov    %edx,%edi
  8025e1:	89 c6                	mov    %eax,%esi
  8025e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8025e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8025eb:	89 ca                	mov    %ecx,%edx
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025f3:	29 f0                	sub    %esi,%eax
  8025f5:	19 fa                	sbb    %edi,%edx
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8025fe:	89 d7                	mov    %edx,%edi
  802600:	d3 e7                	shl    %cl,%edi
  802602:	89 e9                	mov    %ebp,%ecx
  802604:	09 f8                	or     %edi,%eax
  802606:	d3 ea                	shr    %cl,%edx
  802608:	83 c4 20             	add    $0x20,%esp
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
  80260f:	90                   	nop
  802610:	8b 74 24 10          	mov    0x10(%esp),%esi
  802614:	29 f9                	sub    %edi,%ecx
  802616:	19 c6                	sbb    %eax,%esi
  802618:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80261c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802620:	e9 ff fe ff ff       	jmp    802524 <__umoddi3+0x74>
