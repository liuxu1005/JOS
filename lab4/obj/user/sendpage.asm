
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 67 0e 00 00       	call   800ea5 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 28 10 00 00       	call   801084 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 20 15 80 00       	push   $0x801520
  80006c:	e8 13 02 00 00       	call   800284 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 53 07 00 00       	call   8007d2 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 48 08 00 00       	call   8008db <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 34 15 80 00       	push   $0x801534
  8000a2:	e8 dd 01 00 00       	call   800284 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 1a 07 00 00       	call   8007d2 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 36 09 00 00       	call   800a05 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 0d 10 00 00       	call   8010ed <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 14 0b 00 00       	call   800c14 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 c4 06 00 00       	call   8007d2 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e0 08 00 00       	call   800a05 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 b7 0f 00 00       	call   8010ed <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 3b 0f 00 00       	call   801084 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 20 15 80 00       	push   $0x801520
  800159:	e8 26 01 00 00       	call   800284 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 66 06 00 00       	call   8007d2 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 5b 07 00 00       	call   8008db <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 54 15 80 00       	push   $0x801554
  80018f:	e8 f0 00 00 00       	call   800284 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8001a4:	e8 2d 0a 00 00       	call   800bd6 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
  8001d5:	83 c4 10             	add    $0x10,%esp
}
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001e5:	6a 00                	push   $0x0
  8001e7:	e8 a9 09 00 00       	call   800b95 <sys_env_destroy>
  8001ec:	83 c4 10             	add    $0x10,%esp
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fb:	8b 13                	mov    (%ebx),%edx
  8001fd:	8d 42 01             	lea    0x1(%edx),%eax
  800200:	89 03                	mov    %eax,(%ebx)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800209:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020e:	75 1a                	jne    80022a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	68 ff 00 00 00       	push   $0xff
  800218:	8d 43 08             	lea    0x8(%ebx),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 37 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800227:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f1 01 80 00       	push   $0x8001f1
  800262:	e8 4f 01 00 00       	call   8003b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 dc 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 1c             	sub    $0x1c,%esp
  8002a1:	89 c7                	mov    %eax,%edi
  8002a3:	89 d6                	mov    %edx,%esi
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ab:	89 d1                	mov    %edx,%ecx
  8002ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c3:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002c6:	72 05                	jb     8002cd <printnum+0x35>
  8002c8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002cb:	77 3e                	ja     80030b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	ff 75 18             	pushl  0x18(%ebp)
  8002d3:	83 eb 01             	sub    $0x1,%ebx
  8002d6:	53                   	push   %ebx
  8002d7:	50                   	push   %eax
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 74 0f 00 00       	call   801260 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 9e ff ff ff       	call   800298 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 13                	jmp    800312 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030b:	83 eb 01             	sub    $0x1,%ebx
  80030e:	85 db                	test   %ebx,%ebx
  800310:	7f ed                	jg     8002ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	56                   	push   %esi
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031c:	ff 75 e0             	pushl  -0x20(%ebp)
  80031f:	ff 75 dc             	pushl  -0x24(%ebp)
  800322:	ff 75 d8             	pushl  -0x28(%ebp)
  800325:	e8 66 10 00 00       	call   801390 <__umoddi3>
  80032a:	83 c4 14             	add    $0x14,%esp
  80032d:	0f be 80 cc 15 80 00 	movsbl 0x8015cc(%eax),%eax
  800334:	50                   	push   %eax
  800335:	ff d7                	call   *%edi
  800337:	83 c4 10             	add    $0x10,%esp
}
  80033a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800382:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800386:	8b 10                	mov    (%eax),%edx
  800388:	3b 50 04             	cmp    0x4(%eax),%edx
  80038b:	73 0a                	jae    800397 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800390:	89 08                	mov    %ecx,(%eax)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	88 02                	mov    %al,(%edx)
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80039f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a2:	50                   	push   %eax
  8003a3:	ff 75 10             	pushl  0x10(%ebp)
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	e8 05 00 00 00       	call   8003b6 <vprintfmt>
	va_end(ap);
  8003b1:	83 c4 10             	add    $0x10,%esp
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 2c             	sub    $0x2c,%esp
  8003bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c8:	eb 12                	jmp    8003dc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	0f 84 90 03 00 00    	je     800762 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	53                   	push   %ebx
  8003d6:	50                   	push   %eax
  8003d7:	ff d6                	call   *%esi
  8003d9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dc:	83 c7 01             	add    $0x1,%edi
  8003df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e3:	83 f8 25             	cmp    $0x25,%eax
  8003e6:	75 e2                	jne    8003ca <vprintfmt+0x14>
  8003e8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
  800406:	eb 07                	jmp    80040f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8d 47 01             	lea    0x1(%edi),%eax
  800412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800415:	0f b6 07             	movzbl (%edi),%eax
  800418:	0f b6 c8             	movzbl %al,%ecx
  80041b:	83 e8 23             	sub    $0x23,%eax
  80041e:	3c 55                	cmp    $0x55,%al
  800420:	0f 87 21 03 00 00    	ja     800747 <vprintfmt+0x391>
  800426:	0f b6 c0             	movzbl %al,%eax
  800429:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800433:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800437:	eb d6                	jmp    80040f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800444:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800447:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80044b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80044e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800451:	83 fa 09             	cmp    $0x9,%edx
  800454:	77 39                	ja     80048f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800456:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800459:	eb e9                	jmp    800444 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 48 04             	lea    0x4(%eax),%ecx
  800461:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800464:	8b 00                	mov    (%eax),%eax
  800466:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046c:	eb 27                	jmp    800495 <vprintfmt+0xdf>
  80046e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	b9 00 00 00 00       	mov    $0x0,%ecx
  800478:	0f 49 c8             	cmovns %eax,%ecx
  80047b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800481:	eb 8c                	jmp    80040f <vprintfmt+0x59>
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800486:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80048d:	eb 80                	jmp    80040f <vprintfmt+0x59>
  80048f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800492:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	0f 89 70 ff ff ff    	jns    80040f <vprintfmt+0x59>
				width = precision, precision = -1;
  80049f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ac:	e9 5e ff ff ff       	jmp    80040f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b7:	e9 53 ff ff ff       	jmp    80040f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	ff 30                	pushl  (%eax)
  8004cb:	ff d6                	call   *%esi
			break;
  8004cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d3:	e9 04 ff ff ff       	jmp    8003dc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	99                   	cltd   
  8004e4:	31 d0                	xor    %edx,%eax
  8004e6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e8:	83 f8 09             	cmp    $0x9,%eax
  8004eb:	7f 0b                	jg     8004f8 <vprintfmt+0x142>
  8004ed:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	75 18                	jne    800510 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004f8:	50                   	push   %eax
  8004f9:	68 e4 15 80 00       	push   $0x8015e4
  8004fe:	53                   	push   %ebx
  8004ff:	56                   	push   %esi
  800500:	e8 94 fe ff ff       	call   800399 <printfmt>
  800505:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 cc fe ff ff       	jmp    8003dc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	52                   	push   %edx
  800511:	68 ed 15 80 00       	push   $0x8015ed
  800516:	53                   	push   %ebx
  800517:	56                   	push   %esi
  800518:	e8 7c fe ff ff       	call   800399 <printfmt>
  80051d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800523:	e9 b4 fe ff ff       	jmp    8003dc <vprintfmt+0x26>
  800528:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80052b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052e:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80053c:	85 ff                	test   %edi,%edi
  80053e:	ba dd 15 80 00       	mov    $0x8015dd,%edx
  800543:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800546:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054a:	0f 84 92 00 00 00    	je     8005e2 <vprintfmt+0x22c>
  800550:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800554:	0f 8e 96 00 00 00    	jle    8005f0 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	51                   	push   %ecx
  80055e:	57                   	push   %edi
  80055f:	e8 86 02 00 00       	call   8007ea <strnlen>
  800564:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800567:	29 c1                	sub    %eax,%ecx
  800569:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800573:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800576:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800579:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0f                	jmp    80058c <vprintfmt+0x1d6>
					putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	53                   	push   %ebx
  800581:	ff 75 e0             	pushl  -0x20(%ebp)
  800584:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 ff                	test   %edi,%edi
  80058e:	7f ed                	jg     80057d <vprintfmt+0x1c7>
  800590:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800593:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800596:	85 c9                	test   %ecx,%ecx
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	0f 49 c1             	cmovns %ecx,%eax
  8005a0:	29 c1                	sub    %eax,%ecx
  8005a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ab:	89 cb                	mov    %ecx,%ebx
  8005ad:	eb 4d                	jmp    8005fc <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b3:	74 1b                	je     8005d0 <vprintfmt+0x21a>
  8005b5:	0f be c0             	movsbl %al,%eax
  8005b8:	83 e8 20             	sub    $0x20,%eax
  8005bb:	83 f8 5e             	cmp    $0x5e,%eax
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x21a>
					putch('?', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	ff 75 0c             	pushl  0xc(%ebp)
  8005c6:	6a 3f                	push   $0x3f
  8005c8:	ff 55 08             	call   *0x8(%ebp)
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	eb 0d                	jmp    8005dd <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	52                   	push   %edx
  8005d7:	ff 55 08             	call   *0x8(%ebp)
  8005da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dd:	83 eb 01             	sub    $0x1,%ebx
  8005e0:	eb 1a                	jmp    8005fc <vprintfmt+0x246>
  8005e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ee:	eb 0c                	jmp    8005fc <vprintfmt+0x246>
  8005f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fc:	83 c7 01             	add    $0x1,%edi
  8005ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800603:	0f be d0             	movsbl %al,%edx
  800606:	85 d2                	test   %edx,%edx
  800608:	74 23                	je     80062d <vprintfmt+0x277>
  80060a:	85 f6                	test   %esi,%esi
  80060c:	78 a1                	js     8005af <vprintfmt+0x1f9>
  80060e:	83 ee 01             	sub    $0x1,%esi
  800611:	79 9c                	jns    8005af <vprintfmt+0x1f9>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	eb 18                	jmp    800635 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 20                	push   $0x20
  800623:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800625:	83 ef 01             	sub    $0x1,%edi
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb 08                	jmp    800635 <vprintfmt+0x27f>
  80062d:	89 df                	mov    %ebx,%edi
  80062f:	8b 75 08             	mov    0x8(%ebp),%esi
  800632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800635:	85 ff                	test   %edi,%edi
  800637:	7f e4                	jg     80061d <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063c:	e9 9b fd ff ff       	jmp    8003dc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800641:	83 fa 01             	cmp    $0x1,%edx
  800644:	7e 16                	jle    80065c <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 08             	lea    0x8(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 50 04             	mov    0x4(%eax),%edx
  800652:	8b 00                	mov    (%eax),%eax
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065a:	eb 32                	jmp    80068e <vprintfmt+0x2d8>
	else if (lflag)
  80065c:	85 d2                	test   %edx,%edx
  80065e:	74 18                	je     800678 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800676:	eb 16                	jmp    80068e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	89 c1                	mov    %eax,%ecx
  800688:	c1 f9 1f             	sar    $0x1f,%ecx
  80068b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800691:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800694:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800699:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069d:	79 74                	jns    800713 <vprintfmt+0x35d>
				putch('-', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 2d                	push   $0x2d
  8006a5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ad:	f7 d8                	neg    %eax
  8006af:	83 d2 00             	adc    $0x0,%edx
  8006b2:	f7 da                	neg    %edx
  8006b4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006bc:	eb 55                	jmp    800713 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	e8 7c fc ff ff       	call   800342 <getuint>
			base = 10;
  8006c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006cb:	eb 46                	jmp    800713 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 6d fc ff ff       	call   800342 <getuint>
                        base = 8;
  8006d5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006da:	eb 37                	jmp    800713 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	6a 30                	push   $0x30
  8006e2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e4:	83 c4 08             	add    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 78                	push   $0x78
  8006ea:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ff:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800704:	eb 0d                	jmp    800713 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 34 fc ff ff       	call   800342 <getuint>
			base = 16;
  80070e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80071a:	57                   	push   %edi
  80071b:	ff 75 e0             	pushl  -0x20(%ebp)
  80071e:	51                   	push   %ecx
  80071f:	52                   	push   %edx
  800720:	50                   	push   %eax
  800721:	89 da                	mov    %ebx,%edx
  800723:	89 f0                	mov    %esi,%eax
  800725:	e8 6e fb ff ff       	call   800298 <printnum>
			break;
  80072a:	83 c4 20             	add    $0x20,%esp
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800730:	e9 a7 fc ff ff       	jmp    8003dc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	51                   	push   %ecx
  80073a:	ff d6                	call   *%esi
			break;
  80073c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800742:	e9 95 fc ff ff       	jmp    8003dc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 25                	push   $0x25
  80074d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb 03                	jmp    800757 <vprintfmt+0x3a1>
  800754:	83 ef 01             	sub    $0x1,%edi
  800757:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80075b:	75 f7                	jne    800754 <vprintfmt+0x39e>
  80075d:	e9 7a fc ff ff       	jmp    8003dc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 18             	sub    $0x18,%esp
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800779:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800787:	85 c0                	test   %eax,%eax
  800789:	74 26                	je     8007b1 <vsnprintf+0x47>
  80078b:	85 d2                	test   %edx,%edx
  80078d:	7e 22                	jle    8007b1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078f:	ff 75 14             	pushl  0x14(%ebp)
  800792:	ff 75 10             	pushl  0x10(%ebp)
  800795:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800798:	50                   	push   %eax
  800799:	68 7c 03 80 00       	push   $0x80037c
  80079e:	e8 13 fc ff ff       	call   8003b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	eb 05                	jmp    8007b6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c1:	50                   	push   %eax
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	ff 75 08             	pushl  0x8(%ebp)
  8007cb:	e8 9a ff ff ff       	call   80076a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	eb 03                	jmp    8007e2 <strlen+0x10>
		n++;
  8007df:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	75 f7                	jne    8007df <strlen+0xd>
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f8:	eb 03                	jmp    8007fd <strnlen+0x13>
		n++;
  8007fa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fd:	39 c2                	cmp    %eax,%edx
  8007ff:	74 08                	je     800809 <strnlen+0x1f>
  800801:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800805:	75 f3                	jne    8007fa <strnlen+0x10>
  800807:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	89 c2                	mov    %eax,%edx
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	83 c1 01             	add    $0x1,%ecx
  80081d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800821:	88 5a ff             	mov    %bl,-0x1(%edx)
  800824:	84 db                	test   %bl,%bl
  800826:	75 ef                	jne    800817 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	53                   	push   %ebx
  800833:	e8 9a ff ff ff       	call   8007d2 <strlen>
  800838:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	01 d8                	add    %ebx,%eax
  800840:	50                   	push   %eax
  800841:	e8 c5 ff ff ff       	call   80080b <strcpy>
	return dst;
}
  800846:	89 d8                	mov    %ebx,%eax
  800848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	89 f3                	mov    %esi,%ebx
  80085a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	89 f2                	mov    %esi,%edx
  80085f:	eb 0f                	jmp    800870 <strncpy+0x23>
		*dst++ = *src;
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086a:	80 39 01             	cmpb   $0x1,(%ecx)
  80086d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	39 da                	cmp    %ebx,%edx
  800872:	75 ed                	jne    800861 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800874:	89 f0                	mov    %esi,%eax
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 75 08             	mov    0x8(%ebp),%esi
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	8b 55 10             	mov    0x10(%ebp),%edx
  800888:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 d2                	test   %edx,%edx
  80088c:	74 21                	je     8008af <strlcpy+0x35>
  80088e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800892:	89 f2                	mov    %esi,%edx
  800894:	eb 09                	jmp    80089f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089f:	39 c2                	cmp    %eax,%edx
  8008a1:	74 09                	je     8008ac <strlcpy+0x32>
  8008a3:	0f b6 19             	movzbl (%ecx),%ebx
  8008a6:	84 db                	test   %bl,%bl
  8008a8:	75 ec                	jne    800896 <strlcpy+0x1c>
  8008aa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008af:	29 f0                	sub    %esi,%eax
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	eb 06                	jmp    8008c6 <strcmp+0x11>
		p++, q++;
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c6:	0f b6 01             	movzbl (%ecx),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x1c>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 ef                	je     8008c0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 c3                	mov    %eax,%ebx
  8008e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ea:	eb 06                	jmp    8008f2 <strncmp+0x17>
		n--, p++, q++;
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 15                	je     80090b <strncmp+0x30>
  8008f6:	0f b6 08             	movzbl (%eax),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	74 04                	je     800901 <strncmp+0x26>
  8008fd:	3a 0a                	cmp    (%edx),%cl
  8008ff:	74 eb                	je     8008ec <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800901:	0f b6 00             	movzbl (%eax),%eax
  800904:	0f b6 12             	movzbl (%edx),%edx
  800907:	29 d0                	sub    %edx,%eax
  800909:	eb 05                	jmp    800910 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	eb 07                	jmp    800926 <strchr+0x13>
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	74 0f                	je     800932 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	0f b6 10             	movzbl (%eax),%edx
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f2                	jne    80091f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093e:	eb 03                	jmp    800943 <strfind+0xf>
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800946:	84 d2                	test   %dl,%dl
  800948:	74 04                	je     80094e <strfind+0x1a>
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	75 f2                	jne    800940 <strfind+0xc>
			break;
	return (char *) s;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 7d 08             	mov    0x8(%ebp),%edi
  800959:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	74 36                	je     800996 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800960:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800966:	75 28                	jne    800990 <memset+0x40>
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	75 23                	jne    800990 <memset+0x40>
		c &= 0xFF;
  80096d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800971:	89 d3                	mov    %edx,%ebx
  800973:	c1 e3 08             	shl    $0x8,%ebx
  800976:	89 d6                	mov    %edx,%esi
  800978:	c1 e6 18             	shl    $0x18,%esi
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	c1 e0 10             	shl    $0x10,%eax
  800980:	09 f0                	or     %esi,%eax
  800982:	09 c2                	or     %eax,%edx
  800984:	89 d0                	mov    %edx,%eax
  800986:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800988:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098b:	fc                   	cld    
  80098c:	f3 ab                	rep stos %eax,%es:(%edi)
  80098e:	eb 06                	jmp    800996 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	fc                   	cld    
  800994:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800996:	89 f8                	mov    %edi,%eax
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5f                   	pop    %edi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	57                   	push   %edi
  8009a1:	56                   	push   %esi
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ab:	39 c6                	cmp    %eax,%esi
  8009ad:	73 35                	jae    8009e4 <memmove+0x47>
  8009af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b2:	39 d0                	cmp    %edx,%eax
  8009b4:	73 2e                	jae    8009e4 <memmove+0x47>
		s += n;
		d += n;
  8009b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c3:	75 13                	jne    8009d8 <memmove+0x3b>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 0e                	jne    8009d8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ca:	83 ef 04             	sub    $0x4,%edi
  8009cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb 09                	jmp    8009e1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d8:	83 ef 01             	sub    $0x1,%edi
  8009db:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	fd                   	std    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e1:	fc                   	cld    
  8009e2:	eb 1d                	jmp    800a01 <memmove+0x64>
  8009e4:	89 f2                	mov    %esi,%edx
  8009e6:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	75 0f                	jne    8009fc <memmove+0x5f>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 0a                	jne    8009fc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 05                	jmp    800a01 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a08:	ff 75 10             	pushl  0x10(%ebp)
  800a0b:	ff 75 0c             	pushl  0xc(%ebp)
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 87 ff ff ff       	call   80099d <memmove>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	89 c6                	mov    %eax,%esi
  800a25:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	eb 1a                	jmp    800a44 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2a:	0f b6 08             	movzbl (%eax),%ecx
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	38 d9                	cmp    %bl,%cl
  800a32:	74 0a                	je     800a3e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a34:	0f b6 c1             	movzbl %cl,%eax
  800a37:	0f b6 db             	movzbl %bl,%ebx
  800a3a:	29 d8                	sub    %ebx,%eax
  800a3c:	eb 0f                	jmp    800a4d <memcmp+0x35>
		s1++, s2++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a44:	39 f0                	cmp    %esi,%eax
  800a46:	75 e2                	jne    800a2a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	eb 07                	jmp    800a68 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 07                	je     800a6c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	72 f5                	jb     800a61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 03                	jmp    800a7f <strtol+0x11>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	0f b6 01             	movzbl (%ecx),%eax
  800a82:	3c 09                	cmp    $0x9,%al
  800a84:	74 f6                	je     800a7c <strtol+0xe>
  800a86:	3c 20                	cmp    $0x20,%al
  800a88:	74 f2                	je     800a7c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8a:	3c 2b                	cmp    $0x2b,%al
  800a8c:	75 0a                	jne    800a98 <strtol+0x2a>
		s++;
  800a8e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
  800a96:	eb 10                	jmp    800aa8 <strtol+0x3a>
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9d:	3c 2d                	cmp    $0x2d,%al
  800a9f:	75 07                	jne    800aa8 <strtol+0x3a>
		s++, neg = 1;
  800aa1:	8d 49 01             	lea    0x1(%ecx),%ecx
  800aa4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	0f 94 c0             	sete   %al
  800aad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab3:	75 19                	jne    800ace <strtol+0x60>
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	75 14                	jne    800ace <strtol+0x60>
  800aba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abe:	0f 85 82 00 00 00    	jne    800b46 <strtol+0xd8>
		s += 2, base = 16;
  800ac4:	83 c1 02             	add    $0x2,%ecx
  800ac7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acc:	eb 16                	jmp    800ae4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ace:	84 c0                	test   %al,%al
  800ad0:	74 12                	je     800ae4 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	80 39 30             	cmpb   $0x30,(%ecx)
  800ada:	75 08                	jne    800ae4 <strtol+0x76>
		s++, base = 8;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 11             	movzbl (%ecx),%edx
  800aef:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	77 08                	ja     800b01 <strtol+0x93>
			dig = *s - '0';
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 30             	sub    $0x30,%edx
  800aff:	eb 22                	jmp    800b23 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b01:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 08                	ja     800b13 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 57             	sub    $0x57,%edx
  800b11:	eb 10                	jmp    800b23 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b13:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b16:	89 f3                	mov    %esi,%ebx
  800b18:	80 fb 19             	cmp    $0x19,%bl
  800b1b:	77 16                	ja     800b33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1d:	0f be d2             	movsbl %dl,%edx
  800b20:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b23:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b26:	7d 0f                	jge    800b37 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b28:	83 c1 01             	add    $0x1,%ecx
  800b2b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b2f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b31:	eb b9                	jmp    800aec <strtol+0x7e>
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	eb 02                	jmp    800b39 <strtol+0xcb>
  800b37:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3d:	74 0d                	je     800b4c <strtol+0xde>
		*endptr = (char *) s;
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	89 0e                	mov    %ecx,(%esi)
  800b44:	eb 06                	jmp    800b4c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b46:	84 c0                	test   %al,%al
  800b48:	75 92                	jne    800adc <strtol+0x6e>
  800b4a:	eb 98                	jmp    800ae4 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 28 18 80 00       	push   $0x801828
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 45 18 80 00       	push   $0x801845
  800bc9:	e8 ab 05 00 00       	call   801179 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 28 18 80 00       	push   $0x801828
  800c43:	6a 23                	push   $0x23
  800c45:	68 45 18 80 00       	push   $0x801845
  800c4a:	e8 2a 05 00 00       	call   801179 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 28 18 80 00       	push   $0x801828
  800c85:	6a 23                	push   $0x23
  800c87:	68 45 18 80 00       	push   $0x801845
  800c8c:	e8 e8 04 00 00       	call   801179 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 28 18 80 00       	push   $0x801828
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 45 18 80 00       	push   $0x801845
  800cce:	e8 a6 04 00 00       	call   801179 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 28 18 80 00       	push   $0x801828
  800d09:	6a 23                	push   $0x23
  800d0b:	68 45 18 80 00       	push   $0x801845
  800d10:	e8 64 04 00 00       	call   801179 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 28 18 80 00       	push   $0x801828
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 45 18 80 00       	push   $0x801845
  800d52:	e8 22 04 00 00       	call   801179 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 cb                	mov    %ecx,%ebx
  800d9a:	89 cf                	mov    %ecx,%edi
  800d9c:	89 ce                	mov    %ecx,%esi
  800d9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 17                	jle    800dbb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 0c                	push   $0xc
  800daa:	68 28 18 80 00       	push   $0x801828
  800daf:	6a 23                	push   $0x23
  800db1:	68 45 18 80 00       	push   $0x801845
  800db6:	e8 be 03 00 00       	call   801179 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dcd:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800dcf:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dd3:	74 2e                	je     800e03 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 16             	shr    $0x16,%edx
  800dda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de1:	f6 c2 01             	test   $0x1,%dl
  800de4:	74 1d                	je     800e03 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 0c             	shr    $0xc,%edx
  800deb:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800df2:	f6 c1 01             	test   $0x1,%cl
  800df5:	74 0c                	je     800e03 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800df7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800dfe:	f6 c6 08             	test   $0x8,%dh
  800e01:	75 14                	jne    800e17 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	68 54 18 80 00       	push   $0x801854
  800e0b:	6a 21                	push   $0x21
  800e0d:	68 e7 18 80 00       	push   $0x8018e7
  800e12:	e8 62 03 00 00       	call   801179 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1c:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	6a 07                	push   $0x7
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 e5 fd ff ff       	call   800c14 <sys_page_alloc>
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 14                	jns    800e4a <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 f2 18 80 00       	push   $0x8018f2
  800e3e:	6a 2b                	push   $0x2b
  800e40:	68 e7 18 80 00       	push   $0x8018e7
  800e45:	e8 2f 03 00 00       	call   801179 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 00 10 00 00       	push   $0x1000
  800e52:	53                   	push   %ebx
  800e53:	68 00 f0 7f 00       	push   $0x7ff000
  800e58:	e8 40 fb ff ff       	call   80099d <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800e5d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e64:	53                   	push   %ebx
  800e65:	6a 00                	push   $0x0
  800e67:	68 00 f0 7f 00       	push   $0x7ff000
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 e4 fd ff ff       	call   800c57 <sys_page_map>
  800e73:	83 c4 20             	add    $0x20,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	79 14                	jns    800e8e <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 08 19 80 00       	push   $0x801908
  800e82:	6a 2e                	push   $0x2e
  800e84:	68 e7 18 80 00       	push   $0x8018e7
  800e89:	e8 eb 02 00 00       	call   801179 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	6a 00                	push   $0x0
  800e98:	e8 fc fd ff ff       	call   800c99 <sys_page_unmap>
  800e9d:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800eae:	68 c3 0d 80 00       	push   $0x800dc3
  800eb3:	e8 07 03 00 00       	call   8011bf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eb8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebd:	cd 30                	int    $0x30
  800ebf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 12                	jns    800edb <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800ec9:	50                   	push   %eax
  800eca:	68 1c 19 80 00       	push   $0x80191c
  800ecf:	6a 6d                	push   $0x6d
  800ed1:	68 e7 18 80 00       	push   $0x8018e7
  800ed6:	e8 9e 02 00 00       	call   801179 <_panic>
  800edb:	89 c7                	mov    %eax,%edi
  800edd:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800ee2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee6:	75 21                	jne    800f09 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800ee8:	e8 e9 fc ff ff       	call   800bd6 <sys_getenvid>
  800eed:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efa:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
  800f04:	e9 59 01 00 00       	jmp    801062 <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	c1 e8 16             	shr    $0x16,%eax
  800f0e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f15:	a8 01                	test   $0x1,%al
  800f17:	0f 84 b0 00 00 00    	je     800fcd <fork+0x128>
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	c1 e8 0c             	shr    $0xc,%eax
  800f22:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	0f 84 9b 00 00 00    	je     800fcd <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f32:	89 c6                	mov    %eax,%esi
  800f34:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800f37:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3e:	f6 c6 08             	test   $0x8,%dh
  800f41:	75 0b                	jne    800f4e <fork+0xa9>
  800f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4a:	a8 02                	test   $0x2,%al
  800f4c:	74 57                	je     800fa5 <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	68 05 08 00 00       	push   $0x805
  800f56:	56                   	push   %esi
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 f7 fc ff ff       	call   800c57 <sys_page_map>
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 12                	jns    800f79 <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800f67:	50                   	push   %eax
  800f68:	68 78 18 80 00       	push   $0x801878
  800f6d:	6a 4a                	push   $0x4a
  800f6f:	68 e7 18 80 00       	push   $0x8018e7
  800f74:	e8 00 02 00 00       	call   801179 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	68 05 08 00 00       	push   $0x805
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	56                   	push   %esi
  800f85:	6a 00                	push   $0x0
  800f87:	e8 cb fc ff ff       	call   800c57 <sys_page_map>
  800f8c:	83 c4 20             	add    $0x20,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 3a                	jns    800fcd <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800f93:	50                   	push   %eax
  800f94:	68 9c 18 80 00       	push   $0x80189c
  800f99:	6a 4c                	push   $0x4c
  800f9b:	68 e7 18 80 00       	push   $0x8018e7
  800fa0:	e8 d4 01 00 00       	call   801179 <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800fa5:	83 ec 0c             	sub    $0xc,%esp
  800fa8:	6a 05                	push   $0x5
  800faa:	56                   	push   %esi
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 a3 fc ff ff       	call   800c57 <sys_page_map>
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 12                	jns    800fcd <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800fbb:	50                   	push   %eax
  800fbc:	68 c4 18 80 00       	push   $0x8018c4
  800fc1:	6a 4f                	push   $0x4f
  800fc3:	68 e7 18 80 00       	push   $0x8018e7
  800fc8:	e8 ac 01 00 00       	call   801179 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800fcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fd9:	0f 85 2a ff ff ff    	jne    800f09 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	6a 07                	push   $0x7
  800fe4:	68 00 f0 bf ee       	push   $0xeebff000
  800fe9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fec:	e8 23 fc ff ff       	call   800c14 <sys_page_alloc>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 14                	jns    80100c <fork+0x167>
                panic("user stack alloc failure\n");	
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 2c 19 80 00       	push   $0x80192c
  801000:	6a 76                	push   $0x76
  801002:	68 e7 18 80 00       	push   $0x8018e7
  801007:	e8 6d 01 00 00       	call   801179 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	68 2e 12 80 00       	push   $0x80122e
  801014:	ff 75 e4             	pushl  -0x1c(%ebp)
  801017:	e8 01 fd ff ff       	call   800d1d <sys_env_set_pgfault_upcall>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 14                	jns    801037 <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  801023:	ff 75 e4             	pushl  -0x1c(%ebp)
  801026:	68 46 19 80 00       	push   $0x801946
  80102b:	6a 79                	push   $0x79
  80102d:	68 e7 18 80 00       	push   $0x8018e7
  801032:	e8 42 01 00 00       	call   801179 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 02                	push   $0x2
  80103c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103f:	e8 97 fc ff ff       	call   800cdb <sys_env_set_status>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 14                	jns    80105f <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  80104b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104e:	68 63 19 80 00       	push   $0x801963
  801053:	6a 7b                	push   $0x7b
  801055:	68 e7 18 80 00       	push   $0x8018e7
  80105a:	e8 1a 01 00 00       	call   801179 <_panic>
        return forkid;
  80105f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sfork>:

// Challenge!
int
sfork(void)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801070:	68 7a 19 80 00       	push   $0x80197a
  801075:	68 83 00 00 00       	push   $0x83
  80107a:	68 e7 18 80 00       	push   $0x8018e7
  80107f:	e8 f5 00 00 00       	call   801179 <_panic>

00801084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	8b 75 08             	mov    0x8(%ebp),%esi
  80108c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801092:	85 c0                	test   %eax,%eax
  801094:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801099:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	50                   	push   %eax
  8010a0:	e8 dd fc ff ff       	call   800d82 <sys_ipc_recv>
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	79 16                	jns    8010c2 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8010ac:	85 f6                	test   %esi,%esi
  8010ae:	74 06                	je     8010b6 <ipc_recv+0x32>
  8010b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8010b6:	85 db                	test   %ebx,%ebx
  8010b8:	74 2c                	je     8010e6 <ipc_recv+0x62>
  8010ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c0:	eb 24                	jmp    8010e6 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	74 0a                	je     8010d0 <ipc_recv+0x4c>
  8010c6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010cb:	8b 40 74             	mov    0x74(%eax),%eax
  8010ce:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8010d0:	85 db                	test   %ebx,%ebx
  8010d2:	74 0a                	je     8010de <ipc_recv+0x5a>
  8010d4:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010d9:	8b 40 78             	mov    0x78(%eax),%eax
  8010dc:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8010de:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010e3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801106:	0f 44 d8             	cmove  %eax,%ebx
  801109:	eb 1c                	jmp    801127 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80110b:	83 f8 f8             	cmp    $0xfffffff8,%eax
  80110e:	74 12                	je     801122 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801110:	50                   	push   %eax
  801111:	68 90 19 80 00       	push   $0x801990
  801116:	6a 39                	push   $0x39
  801118:	68 ab 19 80 00       	push   $0x8019ab
  80111d:	e8 57 00 00 00       	call   801179 <_panic>
                 sys_yield();
  801122:	e8 ce fa ff ff       	call   800bf5 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801127:	ff 75 14             	pushl  0x14(%ebp)
  80112a:	53                   	push   %ebx
  80112b:	56                   	push   %esi
  80112c:	57                   	push   %edi
  80112d:	e8 2d fc ff ff       	call   800d5f <sys_ipc_try_send>
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 d2                	js     80110b <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80114f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801155:	8b 52 50             	mov    0x50(%edx),%edx
  801158:	39 ca                	cmp    %ecx,%edx
  80115a:	75 0d                	jne    801169 <ipc_find_env+0x28>
			return envs[i].env_id;
  80115c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801164:	8b 40 08             	mov    0x8(%eax),%eax
  801167:	eb 0e                	jmp    801177 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801169:	83 c0 01             	add    $0x1,%eax
  80116c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801171:	75 d9                	jne    80114c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801173:	66 b8 00 00          	mov    $0x0,%ax
}
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80117e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801181:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801187:	e8 4a fa ff ff       	call   800bd6 <sys_getenvid>
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	ff 75 0c             	pushl  0xc(%ebp)
  801192:	ff 75 08             	pushl  0x8(%ebp)
  801195:	56                   	push   %esi
  801196:	50                   	push   %eax
  801197:	68 b8 19 80 00       	push   $0x8019b8
  80119c:	e8 e3 f0 ff ff       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011a1:	83 c4 18             	add    $0x18,%esp
  8011a4:	53                   	push   %ebx
  8011a5:	ff 75 10             	pushl  0x10(%ebp)
  8011a8:	e8 86 f0 ff ff       	call   800233 <vcprintf>
	cprintf("\n");
  8011ad:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  8011b4:	e8 cb f0 ff ff       	call   800284 <cprintf>
  8011b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011bc:	cc                   	int3   
  8011bd:	eb fd                	jmp    8011bc <_panic+0x43>

008011bf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011c5:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8011cc:	75 2c                	jne    8011fa <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	6a 07                	push   $0x7
  8011d3:	68 00 f0 bf ee       	push   $0xeebff000
  8011d8:	6a 00                	push   $0x0
  8011da:	e8 35 fa ff ff       	call   800c14 <sys_page_alloc>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 14                	je     8011fa <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	68 dc 19 80 00       	push   $0x8019dc
  8011ee:	6a 21                	push   $0x21
  8011f0:	68 40 1a 80 00       	push   $0x801a40
  8011f5:	e8 7f ff ff ff       	call   801179 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fd:	a3 10 20 80 00       	mov    %eax,0x802010
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	68 2e 12 80 00       	push   $0x80122e
  80120a:	6a 00                	push   $0x0
  80120c:	e8 0c fb ff ff       	call   800d1d <sys_env_set_pgfault_upcall>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	79 14                	jns    80122c <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	68 08 1a 80 00       	push   $0x801a08
  801220:	6a 29                	push   $0x29
  801222:	68 40 1a 80 00       	push   $0x801a40
  801227:	e8 4d ff ff ff       	call   801179 <_panic>
}
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80122e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80122f:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  801234:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801236:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801239:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80123e:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801242:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801246:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801248:	83 c4 08             	add    $0x8,%esp
        popal
  80124b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80124c:	83 c4 04             	add    $0x4,%esp
        popfl
  80124f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801250:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801251:	c3                   	ret    
  801252:	66 90                	xchg   %ax,%ax
  801254:	66 90                	xchg   %ax,%ax
  801256:	66 90                	xchg   %ax,%ax
  801258:	66 90                	xchg   %ax,%ax
  80125a:	66 90                	xchg   %ax,%ax
  80125c:	66 90                	xchg   %ax,%ax
  80125e:	66 90                	xchg   %ax,%ax

00801260 <__udivdi3>:
  801260:	55                   	push   %ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	83 ec 10             	sub    $0x10,%esp
  801266:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80126a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80126e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801272:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801276:	85 d2                	test   %edx,%edx
  801278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80127c:	89 34 24             	mov    %esi,(%esp)
  80127f:	89 c8                	mov    %ecx,%eax
  801281:	75 35                	jne    8012b8 <__udivdi3+0x58>
  801283:	39 f1                	cmp    %esi,%ecx
  801285:	0f 87 bd 00 00 00    	ja     801348 <__udivdi3+0xe8>
  80128b:	85 c9                	test   %ecx,%ecx
  80128d:	89 cd                	mov    %ecx,%ebp
  80128f:	75 0b                	jne    80129c <__udivdi3+0x3c>
  801291:	b8 01 00 00 00       	mov    $0x1,%eax
  801296:	31 d2                	xor    %edx,%edx
  801298:	f7 f1                	div    %ecx
  80129a:	89 c5                	mov    %eax,%ebp
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	31 d2                	xor    %edx,%edx
  8012a0:	f7 f5                	div    %ebp
  8012a2:	89 c6                	mov    %eax,%esi
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	f7 f5                	div    %ebp
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	5e                   	pop    %esi
  8012ae:	5f                   	pop    %edi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	3b 14 24             	cmp    (%esp),%edx
  8012bb:	77 7b                	ja     801338 <__udivdi3+0xd8>
  8012bd:	0f bd f2             	bsr    %edx,%esi
  8012c0:	83 f6 1f             	xor    $0x1f,%esi
  8012c3:	0f 84 97 00 00 00    	je     801360 <__udivdi3+0x100>
  8012c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012ce:	89 d7                	mov    %edx,%edi
  8012d0:	89 f1                	mov    %esi,%ecx
  8012d2:	29 f5                	sub    %esi,%ebp
  8012d4:	d3 e7                	shl    %cl,%edi
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	d3 ea                	shr    %cl,%edx
  8012dc:	89 f1                	mov    %esi,%ecx
  8012de:	09 fa                	or     %edi,%edx
  8012e0:	8b 3c 24             	mov    (%esp),%edi
  8012e3:	d3 e0                	shl    %cl,%eax
  8012e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012e9:	89 e9                	mov    %ebp,%ecx
  8012eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012f3:	89 fa                	mov    %edi,%edx
  8012f5:	d3 ea                	shr    %cl,%edx
  8012f7:	89 f1                	mov    %esi,%ecx
  8012f9:	d3 e7                	shl    %cl,%edi
  8012fb:	89 e9                	mov    %ebp,%ecx
  8012fd:	d3 e8                	shr    %cl,%eax
  8012ff:	09 c7                	or     %eax,%edi
  801301:	89 f8                	mov    %edi,%eax
  801303:	f7 74 24 08          	divl   0x8(%esp)
  801307:	89 d5                	mov    %edx,%ebp
  801309:	89 c7                	mov    %eax,%edi
  80130b:	f7 64 24 0c          	mull   0xc(%esp)
  80130f:	39 d5                	cmp    %edx,%ebp
  801311:	89 14 24             	mov    %edx,(%esp)
  801314:	72 11                	jb     801327 <__udivdi3+0xc7>
  801316:	8b 54 24 04          	mov    0x4(%esp),%edx
  80131a:	89 f1                	mov    %esi,%ecx
  80131c:	d3 e2                	shl    %cl,%edx
  80131e:	39 c2                	cmp    %eax,%edx
  801320:	73 5e                	jae    801380 <__udivdi3+0x120>
  801322:	3b 2c 24             	cmp    (%esp),%ebp
  801325:	75 59                	jne    801380 <__udivdi3+0x120>
  801327:	8d 47 ff             	lea    -0x1(%edi),%eax
  80132a:	31 f6                	xor    %esi,%esi
  80132c:	89 f2                	mov    %esi,%edx
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    
  801335:	8d 76 00             	lea    0x0(%esi),%esi
  801338:	31 f6                	xor    %esi,%esi
  80133a:	31 c0                	xor    %eax,%eax
  80133c:	89 f2                	mov    %esi,%edx
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    
  801345:	8d 76 00             	lea    0x0(%esi),%esi
  801348:	89 f2                	mov    %esi,%edx
  80134a:	31 f6                	xor    %esi,%esi
  80134c:	89 f8                	mov    %edi,%eax
  80134e:	f7 f1                	div    %ecx
  801350:	89 f2                	mov    %esi,%edx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801364:	76 0b                	jbe    801371 <__udivdi3+0x111>
  801366:	31 c0                	xor    %eax,%eax
  801368:	3b 14 24             	cmp    (%esp),%edx
  80136b:	0f 83 37 ff ff ff    	jae    8012a8 <__udivdi3+0x48>
  801371:	b8 01 00 00 00       	mov    $0x1,%eax
  801376:	e9 2d ff ff ff       	jmp    8012a8 <__udivdi3+0x48>
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	89 f8                	mov    %edi,%eax
  801382:	31 f6                	xor    %esi,%esi
  801384:	e9 1f ff ff ff       	jmp    8012a8 <__udivdi3+0x48>
  801389:	66 90                	xchg   %ax,%ax
  80138b:	66 90                	xchg   %ax,%ax
  80138d:	66 90                	xchg   %ax,%ax
  80138f:	90                   	nop

00801390 <__umoddi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	83 ec 20             	sub    $0x20,%esp
  801396:	8b 44 24 34          	mov    0x34(%esp),%eax
  80139a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80139e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013a2:	89 c6                	mov    %eax,%esi
  8013a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8013b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8013b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	89 c2                	mov    %eax,%edx
  8013c0:	75 1e                	jne    8013e0 <__umoddi3+0x50>
  8013c2:	39 f7                	cmp    %esi,%edi
  8013c4:	76 52                	jbe    801418 <__umoddi3+0x88>
  8013c6:	89 c8                	mov    %ecx,%eax
  8013c8:	89 f2                	mov    %esi,%edx
  8013ca:	f7 f7                	div    %edi
  8013cc:	89 d0                	mov    %edx,%eax
  8013ce:	31 d2                	xor    %edx,%edx
  8013d0:	83 c4 20             	add    $0x20,%esp
  8013d3:	5e                   	pop    %esi
  8013d4:	5f                   	pop    %edi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    
  8013d7:	89 f6                	mov    %esi,%esi
  8013d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8013e0:	39 f0                	cmp    %esi,%eax
  8013e2:	77 5c                	ja     801440 <__umoddi3+0xb0>
  8013e4:	0f bd e8             	bsr    %eax,%ebp
  8013e7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ea:	75 64                	jne    801450 <__umoddi3+0xc0>
  8013ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8013f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8013f4:	0f 86 f6 00 00 00    	jbe    8014f0 <__umoddi3+0x160>
  8013fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8013fe:	0f 82 ec 00 00 00    	jb     8014f0 <__umoddi3+0x160>
  801404:	8b 44 24 14          	mov    0x14(%esp),%eax
  801408:	8b 54 24 18          	mov    0x18(%esp),%edx
  80140c:	83 c4 20             	add    $0x20,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	85 ff                	test   %edi,%edi
  80141a:	89 fd                	mov    %edi,%ebp
  80141c:	75 0b                	jne    801429 <__umoddi3+0x99>
  80141e:	b8 01 00 00 00       	mov    $0x1,%eax
  801423:	31 d2                	xor    %edx,%edx
  801425:	f7 f7                	div    %edi
  801427:	89 c5                	mov    %eax,%ebp
  801429:	8b 44 24 10          	mov    0x10(%esp),%eax
  80142d:	31 d2                	xor    %edx,%edx
  80142f:	f7 f5                	div    %ebp
  801431:	89 c8                	mov    %ecx,%eax
  801433:	f7 f5                	div    %ebp
  801435:	eb 95                	jmp    8013cc <__umoddi3+0x3c>
  801437:	89 f6                	mov    %esi,%esi
  801439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 f2                	mov    %esi,%edx
  801444:	83 c4 20             	add    $0x20,%esp
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
  80144b:	90                   	nop
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	b8 20 00 00 00       	mov    $0x20,%eax
  801455:	89 e9                	mov    %ebp,%ecx
  801457:	29 e8                	sub    %ebp,%eax
  801459:	d3 e2                	shl    %cl,%edx
  80145b:	89 c7                	mov    %eax,%edi
  80145d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801461:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801465:	89 f9                	mov    %edi,%ecx
  801467:	d3 e8                	shr    %cl,%eax
  801469:	89 c1                	mov    %eax,%ecx
  80146b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80146f:	09 d1                	or     %edx,%ecx
  801471:	89 fa                	mov    %edi,%edx
  801473:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801477:	89 e9                	mov    %ebp,%ecx
  801479:	d3 e0                	shl    %cl,%eax
  80147b:	89 f9                	mov    %edi,%ecx
  80147d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801481:	89 f0                	mov    %esi,%eax
  801483:	d3 e8                	shr    %cl,%eax
  801485:	89 e9                	mov    %ebp,%ecx
  801487:	89 c7                	mov    %eax,%edi
  801489:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80148d:	d3 e6                	shl    %cl,%esi
  80148f:	89 d1                	mov    %edx,%ecx
  801491:	89 fa                	mov    %edi,%edx
  801493:	d3 e8                	shr    %cl,%eax
  801495:	89 e9                	mov    %ebp,%ecx
  801497:	09 f0                	or     %esi,%eax
  801499:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80149d:	f7 74 24 10          	divl   0x10(%esp)
  8014a1:	d3 e6                	shl    %cl,%esi
  8014a3:	89 d1                	mov    %edx,%ecx
  8014a5:	f7 64 24 0c          	mull   0xc(%esp)
  8014a9:	39 d1                	cmp    %edx,%ecx
  8014ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8014af:	89 d7                	mov    %edx,%edi
  8014b1:	89 c6                	mov    %eax,%esi
  8014b3:	72 0a                	jb     8014bf <__umoddi3+0x12f>
  8014b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8014b9:	73 10                	jae    8014cb <__umoddi3+0x13b>
  8014bb:	39 d1                	cmp    %edx,%ecx
  8014bd:	75 0c                	jne    8014cb <__umoddi3+0x13b>
  8014bf:	89 d7                	mov    %edx,%edi
  8014c1:	89 c6                	mov    %eax,%esi
  8014c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8014c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8014cb:	89 ca                	mov    %ecx,%edx
  8014cd:	89 e9                	mov    %ebp,%ecx
  8014cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014d3:	29 f0                	sub    %esi,%eax
  8014d5:	19 fa                	sbb    %edi,%edx
  8014d7:	d3 e8                	shr    %cl,%eax
  8014d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8014de:	89 d7                	mov    %edx,%edi
  8014e0:	d3 e7                	shl    %cl,%edi
  8014e2:	89 e9                	mov    %ebp,%ecx
  8014e4:	09 f8                	or     %edi,%eax
  8014e6:	d3 ea                	shr    %cl,%edx
  8014e8:	83 c4 20             	add    $0x20,%esp
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    
  8014ef:	90                   	nop
  8014f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014f4:	29 f9                	sub    %edi,%ecx
  8014f6:	19 c6                	sbb    %eax,%esi
  8014f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8014fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801500:	e9 ff fe ff ff       	jmp    801404 <__umoddi3+0x74>
