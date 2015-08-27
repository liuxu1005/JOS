
obj/user/sendpage.debug:     file format elf32-i386


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
  800039:	e8 b1 0e 00 00       	call   800eef <fork>
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
  800057:	e8 b5 10 00 00       	call   801111 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 23 80 00       	push   $0x802300
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 5b 07 00 00       	call   8007da <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 50 08 00 00       	call   8008e3 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 23 80 00       	push   $0x802314
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 22 07 00 00       	call   8007da <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 3e 09 00 00       	call   800a0d <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 9a 10 00 00       	call   80117a <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 1c 0b 00 00       	call   800c1c <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 cc 06 00 00       	call   8007da <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e8 08 00 00       	call   800a0d <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 44 10 00 00       	call   80117a <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 c8 0f 00 00       	call   801111 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 23 80 00       	push   $0x802300
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 6e 06 00 00       	call   8007da <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 63 07 00 00       	call   8008e3 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 23 80 00       	push   $0x802334
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
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
  8001a4:	e8 35 0a 00 00       	call   800bde <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

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
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 e9 11 00 00       	call   8013d3 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 a9 09 00 00       	call   800b9d <sys_env_destroy>
  8001f4:	83 c4 10             	add    $0x10,%esp
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 37 09 00 00       	call   800b60 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 4f 01 00 00       	call   8003be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 dc 08 00 00       	call   800b60 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 d1                	mov    %edx,%ecx
  8002b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002cb:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002ce:	72 05                	jb     8002d5 <printnum+0x35>
  8002d0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002d3:	77 3e                	ja     800313 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	ff 75 18             	pushl  0x18(%ebp)
  8002db:	83 eb 01             	sub    $0x1,%ebx
  8002de:	53                   	push   %ebx
  8002df:	50                   	push   %eax
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 3c 1d 00 00       	call   802030 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 13                	jmp    80031a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800313:	83 eb 01             	sub    $0x1,%ebx
  800316:	85 db                	test   %ebx,%ebx
  800318:	7f ed                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	56                   	push   %esi
  80031e:	83 ec 04             	sub    $0x4,%esp
  800321:	ff 75 e4             	pushl  -0x1c(%ebp)
  800324:	ff 75 e0             	pushl  -0x20(%ebp)
  800327:	ff 75 dc             	pushl  -0x24(%ebp)
  80032a:	ff 75 d8             	pushl  -0x28(%ebp)
  80032d:	e8 2e 1e 00 00       	call   802160 <__umoddi3>
  800332:	83 c4 14             	add    $0x14,%esp
  800335:	0f be 80 ac 23 80 00 	movsbl 0x8023ac(%eax),%eax
  80033c:	50                   	push   %eax
  80033d:	ff d7                	call   *%edi
  80033f:	83 c4 10             	add    $0x10,%esp
}
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	3b 50 04             	cmp    0x4(%eax),%edx
  800393:	73 0a                	jae    80039f <sprintputch+0x1b>
		*b->buf++ = ch;
  800395:	8d 4a 01             	lea    0x1(%edx),%ecx
  800398:	89 08                	mov    %ecx,(%eax)
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	88 02                	mov    %al,(%edx)
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003aa:	50                   	push   %eax
  8003ab:	ff 75 10             	pushl  0x10(%ebp)
  8003ae:	ff 75 0c             	pushl  0xc(%ebp)
  8003b1:	ff 75 08             	pushl  0x8(%ebp)
  8003b4:	e8 05 00 00 00       	call   8003be <vprintfmt>
	va_end(ap);
  8003b9:	83 c4 10             	add    $0x10,%esp
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 2c             	sub    $0x2c,%esp
  8003c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003cd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d0:	eb 12                	jmp    8003e4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d2:	85 c0                	test   %eax,%eax
  8003d4:	0f 84 90 03 00 00    	je     80076a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	50                   	push   %eax
  8003df:	ff d6                	call   *%esi
  8003e1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e4:	83 c7 01             	add    $0x1,%edi
  8003e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003eb:	83 f8 25             	cmp    $0x25,%eax
  8003ee:	75 e2                	jne    8003d2 <vprintfmt+0x14>
  8003f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800402:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	eb 07                	jmp    800417 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8d 47 01             	lea    0x1(%edi),%eax
  80041a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041d:	0f b6 07             	movzbl (%edi),%eax
  800420:	0f b6 c8             	movzbl %al,%ecx
  800423:	83 e8 23             	sub    $0x23,%eax
  800426:	3c 55                	cmp    $0x55,%al
  800428:	0f 87 21 03 00 00    	ja     80074f <vprintfmt+0x391>
  80042e:	0f b6 c0             	movzbl %al,%eax
  800431:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043f:	eb d6                	jmp    800417 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	b8 00 00 00 00       	mov    $0x0,%eax
  800449:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800453:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800456:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800459:	83 fa 09             	cmp    $0x9,%edx
  80045c:	77 39                	ja     800497 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800461:	eb e9                	jmp    80044c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 48 04             	lea    0x4(%eax),%ecx
  800469:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80046c:	8b 00                	mov    (%eax),%eax
  80046e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800474:	eb 27                	jmp    80049d <vprintfmt+0xdf>
  800476:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800479:	85 c0                	test   %eax,%eax
  80047b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800480:	0f 49 c8             	cmovns %eax,%ecx
  800483:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	eb 8c                	jmp    800417 <vprintfmt+0x59>
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800495:	eb 80                	jmp    800417 <vprintfmt+0x59>
  800497:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	0f 89 70 ff ff ff    	jns    800417 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b4:	e9 5e ff ff ff       	jmp    800417 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bf:	e9 53 ff ff ff       	jmp    800417 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	ff 30                	pushl  (%eax)
  8004d3:	ff d6                	call   *%esi
			break;
  8004d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004db:	e9 04 ff ff ff       	jmp    8003e4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	99                   	cltd   
  8004ec:	31 d0                	xor    %edx,%eax
  8004ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f0:	83 f8 0f             	cmp    $0xf,%eax
  8004f3:	7f 0b                	jg     800500 <vprintfmt+0x142>
  8004f5:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	75 18                	jne    800518 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800500:	50                   	push   %eax
  800501:	68 c4 23 80 00       	push   $0x8023c4
  800506:	53                   	push   %ebx
  800507:	56                   	push   %esi
  800508:	e8 94 fe ff ff       	call   8003a1 <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 cc fe ff ff       	jmp    8003e4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800518:	52                   	push   %edx
  800519:	68 15 29 80 00       	push   $0x802915
  80051e:	53                   	push   %ebx
  80051f:	56                   	push   %esi
  800520:	e8 7c fe ff ff       	call   8003a1 <printfmt>
  800525:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	e9 b4 fe ff ff       	jmp    8003e4 <vprintfmt+0x26>
  800530:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800533:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800536:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800544:	85 ff                	test   %edi,%edi
  800546:	ba bd 23 80 00       	mov    $0x8023bd,%edx
  80054b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80054e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800552:	0f 84 92 00 00 00    	je     8005ea <vprintfmt+0x22c>
  800558:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80055c:	0f 8e 96 00 00 00    	jle    8005f8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	51                   	push   %ecx
  800566:	57                   	push   %edi
  800567:	e8 86 02 00 00       	call   8007f2 <strnlen>
  80056c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056f:	29 c1                	sub    %eax,%ecx
  800571:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800577:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800581:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0f                	jmp    800594 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	ff 75 e0             	pushl  -0x20(%ebp)
  80058c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	83 ef 01             	sub    $0x1,%edi
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	85 ff                	test   %edi,%edi
  800596:	7f ed                	jg     800585 <vprintfmt+0x1c7>
  800598:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	0f 49 c1             	cmovns %ecx,%eax
  8005a8:	29 c1                	sub    %eax,%ecx
  8005aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b3:	89 cb                	mov    %ecx,%ebx
  8005b5:	eb 4d                	jmp    800604 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bb:	74 1b                	je     8005d8 <vprintfmt+0x21a>
  8005bd:	0f be c0             	movsbl %al,%eax
  8005c0:	83 e8 20             	sub    $0x20,%eax
  8005c3:	83 f8 5e             	cmp    $0x5e,%eax
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x21a>
					putch('?', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ce:	6a 3f                	push   $0x3f
  8005d0:	ff 55 08             	call   *0x8(%ebp)
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 0d                	jmp    8005e5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	ff 75 0c             	pushl  0xc(%ebp)
  8005de:	52                   	push   %edx
  8005df:	ff 55 08             	call   *0x8(%ebp)
  8005e2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e5:	83 eb 01             	sub    $0x1,%ebx
  8005e8:	eb 1a                	jmp    800604 <vprintfmt+0x246>
  8005ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f6:	eb 0c                	jmp    800604 <vprintfmt+0x246>
  8005f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800601:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800604:	83 c7 01             	add    $0x1,%edi
  800607:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060b:	0f be d0             	movsbl %al,%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 23                	je     800635 <vprintfmt+0x277>
  800612:	85 f6                	test   %esi,%esi
  800614:	78 a1                	js     8005b7 <vprintfmt+0x1f9>
  800616:	83 ee 01             	sub    $0x1,%esi
  800619:	79 9c                	jns    8005b7 <vprintfmt+0x1f9>
  80061b:	89 df                	mov    %ebx,%edi
  80061d:	8b 75 08             	mov    0x8(%ebp),%esi
  800620:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800623:	eb 18                	jmp    80063d <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 20                	push   $0x20
  80062b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062d:	83 ef 01             	sub    $0x1,%edi
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	eb 08                	jmp    80063d <vprintfmt+0x27f>
  800635:	89 df                	mov    %ebx,%edi
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063d:	85 ff                	test   %edi,%edi
  80063f:	7f e4                	jg     800625 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 9b fd ff ff       	jmp    8003e4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800649:	83 fa 01             	cmp    $0x1,%edx
  80064c:	7e 16                	jle    800664 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 08             	lea    0x8(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 50 04             	mov    0x4(%eax),%edx
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	eb 32                	jmp    800696 <vprintfmt+0x2d8>
	else if (lflag)
  800664:	85 d2                	test   %edx,%edx
  800666:	74 18                	je     800680 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800676:	89 c1                	mov    %eax,%ecx
  800678:	c1 f9 1f             	sar    $0x1f,%ecx
  80067b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067e:	eb 16                	jmp    800696 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	89 c1                	mov    %eax,%ecx
  800690:	c1 f9 1f             	sar    $0x1f,%ecx
  800693:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800696:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800699:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a5:	79 74                	jns    80071b <vprintfmt+0x35d>
				putch('-', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 2d                	push   $0x2d
  8006ad:	ff d6                	call   *%esi
				num = -(long long) num;
  8006af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b5:	f7 d8                	neg    %eax
  8006b7:	83 d2 00             	adc    $0x0,%edx
  8006ba:	f7 da                	neg    %edx
  8006bc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c4:	eb 55                	jmp    80071b <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 7c fc ff ff       	call   80034a <getuint>
			base = 10;
  8006ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d3:	eb 46                	jmp    80071b <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 6d fc ff ff       	call   80034a <getuint>
                        base = 8;
  8006dd:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006e2:	eb 37                	jmp    80071b <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 30                	push   $0x30
  8006ea:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ec:	83 c4 08             	add    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	6a 78                	push   $0x78
  8006f2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800704:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800707:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070c:	eb 0d                	jmp    80071b <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 34 fc ff ff       	call   80034a <getuint>
			base = 16;
  800716:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071b:	83 ec 0c             	sub    $0xc,%esp
  80071e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800722:	57                   	push   %edi
  800723:	ff 75 e0             	pushl  -0x20(%ebp)
  800726:	51                   	push   %ecx
  800727:	52                   	push   %edx
  800728:	50                   	push   %eax
  800729:	89 da                	mov    %ebx,%edx
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	e8 6e fb ff ff       	call   8002a0 <printnum>
			break;
  800732:	83 c4 20             	add    $0x20,%esp
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800738:	e9 a7 fc ff ff       	jmp    8003e4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	51                   	push   %ecx
  800742:	ff d6                	call   *%esi
			break;
  800744:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074a:	e9 95 fc ff ff       	jmp    8003e4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 25                	push   $0x25
  800755:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 03                	jmp    80075f <vprintfmt+0x3a1>
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800763:	75 f7                	jne    80075c <vprintfmt+0x39e>
  800765:	e9 7a fc ff ff       	jmp    8003e4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 18             	sub    $0x18,%esp
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800781:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800785:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800788:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078f:	85 c0                	test   %eax,%eax
  800791:	74 26                	je     8007b9 <vsnprintf+0x47>
  800793:	85 d2                	test   %edx,%edx
  800795:	7e 22                	jle    8007b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800797:	ff 75 14             	pushl  0x14(%ebp)
  80079a:	ff 75 10             	pushl  0x10(%ebp)
  80079d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a0:	50                   	push   %eax
  8007a1:	68 84 03 80 00       	push   $0x800384
  8007a6:	e8 13 fc ff ff       	call   8003be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 05                	jmp    8007be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	ff 75 08             	pushl  0x8(%ebp)
  8007d3:	e8 9a ff ff ff       	call   800772 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 03                	jmp    8007ea <strlen+0x10>
		n++;
  8007e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f7                	jne    8007e7 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800800:	eb 03                	jmp    800805 <strnlen+0x13>
		n++;
  800802:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	39 c2                	cmp    %eax,%edx
  800807:	74 08                	je     800811 <strnlen+0x1f>
  800809:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080d:	75 f3                	jne    800802 <strnlen+0x10>
  80080f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	89 c2                	mov    %eax,%edx
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ef                	jne    80081f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800830:	5b                   	pop    %ebx
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 9a ff ff ff       	call   8007da <strlen>
  800840:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	01 d8                	add    %ebx,%eax
  800848:	50                   	push   %eax
  800849:	e8 c5 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	89 f3                	mov    %esi,%ebx
  800862:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	89 f2                	mov    %esi,%edx
  800867:	eb 0f                	jmp    800878 <strncpy+0x23>
		*dst++ = *src;
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 39 01             	cmpb   $0x1,(%ecx)
  800875:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800878:	39 da                	cmp    %ebx,%edx
  80087a:	75 ed                	jne    800869 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
  800890:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	74 21                	je     8008b7 <strlcpy+0x35>
  800896:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089a:	89 f2                	mov    %esi,%edx
  80089c:	eb 09                	jmp    8008a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 09                	je     8008b4 <strlcpy+0x32>
  8008ab:	0f b6 19             	movzbl (%ecx),%ebx
  8008ae:	84 db                	test   %bl,%bl
  8008b0:	75 ec                	jne    80089e <strlcpy+0x1c>
  8008b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 15                	je     800913 <strncmp+0x30>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
  800911:	eb 05                	jmp    800918 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strchr+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0f                	je     80093a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 03                	jmp    80094b <strfind+0xf>
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 04                	je     800956 <strfind+0x1a>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	75 f2                	jne    800948 <strfind+0xc>
			break;
	return (char *) s;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 36                	je     80099e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 28                	jne    800998 <memset+0x40>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 23                	jne    800998 <memset+0x40>
		c &= 0xFF;
  800975:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800979:	89 d3                	mov    %edx,%ebx
  80097b:	c1 e3 08             	shl    $0x8,%ebx
  80097e:	89 d6                	mov    %edx,%esi
  800980:	c1 e6 18             	shl    $0x18,%esi
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 10             	shl    $0x10,%eax
  800988:	09 f0                	or     %esi,%eax
  80098a:	09 c2                	or     %eax,%edx
  80098c:	89 d0                	mov    %edx,%eax
  80098e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800990:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800993:	fc                   	cld    
  800994:	f3 ab                	rep stos %eax,%es:(%edi)
  800996:	eb 06                	jmp    80099e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099b:	fc                   	cld    
  80099c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099e:	89 f8                	mov    %edi,%eax
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	39 c6                	cmp    %eax,%esi
  8009b5:	73 35                	jae    8009ec <memmove+0x47>
  8009b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ba:	39 d0                	cmp    %edx,%eax
  8009bc:	73 2e                	jae    8009ec <memmove+0x47>
		s += n;
		d += n;
  8009be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009c1:	89 d6                	mov    %edx,%esi
  8009c3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	75 13                	jne    8009e0 <memmove+0x3b>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0e                	jne    8009e0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d2:	83 ef 04             	sub    $0x4,%edi
  8009d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009db:	fd                   	std    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 09                	jmp    8009e9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e0:	83 ef 01             	sub    $0x1,%edi
  8009e3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e6:	fd                   	std    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e9:	fc                   	cld    
  8009ea:	eb 1d                	jmp    800a09 <memmove+0x64>
  8009ec:	89 f2                	mov    %esi,%edx
  8009ee:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 0f                	jne    800a04 <memmove+0x5f>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0a                	jne    800a04 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 05                	jmp    800a09 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a04:	89 c7                	mov    %eax,%edi
  800a06:	fc                   	cld    
  800a07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a10:	ff 75 10             	pushl  0x10(%ebp)
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	ff 75 08             	pushl  0x8(%ebp)
  800a19:	e8 87 ff ff ff       	call   8009a5 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	89 c6                	mov    %eax,%esi
  800a2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	eb 1a                	jmp    800a4c <memcmp+0x2c>
		if (*s1 != *s2)
  800a32:	0f b6 08             	movzbl (%eax),%ecx
  800a35:	0f b6 1a             	movzbl (%edx),%ebx
  800a38:	38 d9                	cmp    %bl,%cl
  800a3a:	74 0a                	je     800a46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3c:	0f b6 c1             	movzbl %cl,%eax
  800a3f:	0f b6 db             	movzbl %bl,%ebx
  800a42:	29 d8                	sub    %ebx,%eax
  800a44:	eb 0f                	jmp    800a55 <memcmp+0x35>
		s1++, s2++;
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	39 f0                	cmp    %esi,%eax
  800a4e:	75 e2                	jne    800a32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	eb 07                	jmp    800a70 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	74 07                	je     800a74 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	39 d0                	cmp    %edx,%eax
  800a72:	72 f5                	jb     800a69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	eb 03                	jmp    800a87 <strtol+0x11>
		s++;
  800a84:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	3c 09                	cmp    $0x9,%al
  800a8c:	74 f6                	je     800a84 <strtol+0xe>
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f2                	je     800a84 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a92:	3c 2b                	cmp    $0x2b,%al
  800a94:	75 0a                	jne    800aa0 <strtol+0x2a>
		s++;
  800a96:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9e:	eb 10                	jmp    800ab0 <strtol+0x3a>
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	3c 2d                	cmp    $0x2d,%al
  800aa7:	75 07                	jne    800ab0 <strtol+0x3a>
		s++, neg = 1;
  800aa9:	8d 49 01             	lea    0x1(%ecx),%ecx
  800aac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	0f 94 c0             	sete   %al
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 19                	jne    800ad6 <strtol+0x60>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 14                	jne    800ad6 <strtol+0x60>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	0f 85 82 00 00 00    	jne    800b4e <strtol+0xd8>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb 16                	jmp    800aec <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad6:	84 c0                	test   %al,%al
  800ad8:	74 12                	je     800aec <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae2:	75 08                	jne    800aec <strtol+0x76>
		s++, base = 8;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 08                	ja     800b09 <strtol+0x93>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb 22                	jmp    800b2b <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 57             	sub    $0x57,%edx
  800b19:	eb 10                	jmp    800b2b <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 16                	ja     800b3b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2e:	7d 0f                	jge    800b3f <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b39:	eb b9                	jmp    800af4 <strtol+0x7e>
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	eb 02                	jmp    800b41 <strtol+0xcb>
  800b3f:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b45:	74 0d                	je     800b54 <strtol+0xde>
		*endptr = (char *) s;
  800b47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4a:	89 0e                	mov    %ecx,(%esi)
  800b4c:	eb 06                	jmp    800b54 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4e:	84 c0                	test   %al,%al
  800b50:	75 92                	jne    800ae4 <strtol+0x6e>
  800b52:	eb 98                	jmp    800aec <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b54:	f7 da                	neg    %edx
  800b56:	85 ff                	test   %edi,%edi
  800b58:	0f 45 c2             	cmovne %edx,%eax
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 c3                	mov    %eax,%ebx
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	89 c6                	mov    %eax,%esi
  800b77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bab:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 cb                	mov    %ecx,%ebx
  800bb5:	89 cf                	mov    %ecx,%edi
  800bb7:	89 ce                	mov    %ecx,%esi
  800bb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 03                	push   $0x3
  800bc5:	68 df 26 80 00       	push   $0x8026df
  800bca:	6a 23                	push   $0x23
  800bcc:	68 fc 26 80 00       	push   $0x8026fc
  800bd1:	e8 3d 13 00 00       	call   801f13 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_yield>:

void
sys_yield(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	be 00 00 00 00       	mov    $0x0,%esi
  800c2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c38:	89 f7                	mov    %esi,%edi
  800c3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 04                	push   $0x4
  800c46:	68 df 26 80 00       	push   $0x8026df
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 fc 26 80 00       	push   $0x8026fc
  800c52:	e8 bc 12 00 00       	call   801f13 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c79:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 05                	push   $0x5
  800c88:	68 df 26 80 00       	push   $0x8026df
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 fc 26 80 00       	push   $0x8026fc
  800c94:	e8 7a 12 00 00       	call   801f13 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 06                	push   $0x6
  800cca:	68 df 26 80 00       	push   $0x8026df
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 fc 26 80 00       	push   $0x8026fc
  800cd6:	e8 38 12 00 00       	call   801f13 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 08                	push   $0x8
  800d0c:	68 df 26 80 00       	push   $0x8026df
  800d11:	6a 23                	push   $0x23
  800d13:	68 fc 26 80 00       	push   $0x8026fc
  800d18:	e8 f6 11 00 00       	call   801f13 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 09 00 00 00       	mov    $0x9,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 09                	push   $0x9
  800d4e:	68 df 26 80 00       	push   $0x8026df
  800d53:	6a 23                	push   $0x23
  800d55:	68 fc 26 80 00       	push   $0x8026fc
  800d5a:	e8 b4 11 00 00       	call   801f13 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0a                	push   $0xa
  800d90:	68 df 26 80 00       	push   $0x8026df
  800d95:	6a 23                	push   $0x23
  800d97:	68 fc 26 80 00       	push   $0x8026fc
  800d9c:	e8 72 11 00 00       	call   801f13 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	be 00 00 00 00       	mov    $0x0,%esi
  800db4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 cb                	mov    %ecx,%ebx
  800de4:	89 cf                	mov    %ecx,%edi
  800de6:	89 ce                	mov    %ecx,%esi
  800de8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 17                	jle    800e05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	50                   	push   %eax
  800df2:	6a 0d                	push   $0xd
  800df4:	68 df 26 80 00       	push   $0x8026df
  800df9:	6a 23                	push   $0x23
  800dfb:	68 fc 26 80 00       	push   $0x8026fc
  800e00:	e8 0e 11 00 00       	call   801f13 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e17:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e19:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e1d:	74 2e                	je     800e4d <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	c1 ea 16             	shr    $0x16,%edx
  800e24:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2b:	f6 c2 01             	test   $0x1,%dl
  800e2e:	74 1d                	je     800e4d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	c1 ea 0c             	shr    $0xc,%edx
  800e35:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e3c:	f6 c1 01             	test   $0x1,%cl
  800e3f:	74 0c                	je     800e4d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800e48:	f6 c6 08             	test   $0x8,%dh
  800e4b:	75 14                	jne    800e61 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 0c 27 80 00       	push   $0x80270c
  800e55:	6a 21                	push   $0x21
  800e57:	68 9f 27 80 00       	push   $0x80279f
  800e5c:	e8 b2 10 00 00       	call   801f13 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800e61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e66:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	6a 07                	push   $0x7
  800e6d:	68 00 f0 7f 00       	push   $0x7ff000
  800e72:	6a 00                	push   $0x0
  800e74:	e8 a3 fd ff ff       	call   800c1c <sys_page_alloc>
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	79 14                	jns    800e94 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800e80:	83 ec 04             	sub    $0x4,%esp
  800e83:	68 aa 27 80 00       	push   $0x8027aa
  800e88:	6a 2b                	push   $0x2b
  800e8a:	68 9f 27 80 00       	push   $0x80279f
  800e8f:	e8 7f 10 00 00       	call   801f13 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	68 00 10 00 00       	push   $0x1000
  800e9c:	53                   	push   %ebx
  800e9d:	68 00 f0 7f 00       	push   $0x7ff000
  800ea2:	e8 fe fa ff ff       	call   8009a5 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800ea7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eae:	53                   	push   %ebx
  800eaf:	6a 00                	push   $0x0
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 a2 fd ff ff       	call   800c5f <sys_page_map>
  800ebd:	83 c4 20             	add    $0x20,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	79 14                	jns    800ed8 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800ec4:	83 ec 04             	sub    $0x4,%esp
  800ec7:	68 c0 27 80 00       	push   $0x8027c0
  800ecc:	6a 2e                	push   $0x2e
  800ece:	68 9f 27 80 00       	push   $0x80279f
  800ed3:	e8 3b 10 00 00       	call   801f13 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	68 00 f0 7f 00       	push   $0x7ff000
  800ee0:	6a 00                	push   $0x0
  800ee2:	e8 ba fd ff ff       	call   800ca1 <sys_page_unmap>
  800ee7:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800ef8:	68 0d 0e 80 00       	push   $0x800e0d
  800efd:	e8 57 10 00 00       	call   801f59 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f02:	b8 07 00 00 00       	mov    $0x7,%eax
  800f07:	cd 30                	int    $0x30
  800f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	79 12                	jns    800f25 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800f13:	50                   	push   %eax
  800f14:	68 d4 27 80 00       	push   $0x8027d4
  800f19:	6a 6d                	push   $0x6d
  800f1b:	68 9f 27 80 00       	push   $0x80279f
  800f20:	e8 ee 0f 00 00       	call   801f13 <_panic>
  800f25:	89 c7                	mov    %eax,%edi
  800f27:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800f2c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f30:	75 21                	jne    800f53 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800f32:	e8 a7 fc ff ff       	call   800bde <sys_getenvid>
  800f37:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f44:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	e9 9c 01 00 00       	jmp    8010ef <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	0f 84 f3 00 00 00    	je     80105a <fork+0x16b>
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e8 0c             	shr    $0xc,%eax
  800f6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	0f 84 de 00 00 00    	je     80105a <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800f7c:	89 c6                	mov    %eax,%esi
  800f7e:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f88:	f6 c6 04             	test   $0x4,%dh
  800f8b:	74 37                	je     800fc4 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  800f8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9c:	50                   	push   %eax
  800f9d:	56                   	push   %esi
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 b8 fc ff ff       	call   800c5f <sys_page_map>
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	0f 89 a8 00 00 00    	jns    80105a <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 30 27 80 00       	push   $0x802730
  800fb8:	6a 49                	push   $0x49
  800fba:	68 9f 27 80 00       	push   $0x80279f
  800fbf:	e8 4f 0f 00 00       	call   801f13 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800fc4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcb:	f6 c6 08             	test   $0x8,%dh
  800fce:	75 0b                	jne    800fdb <fork+0xec>
  800fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd7:	a8 02                	test   $0x2,%al
  800fd9:	74 57                	je     801032 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	68 05 08 00 00       	push   $0x805
  800fe3:	56                   	push   %esi
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 72 fc ff ff       	call   800c5f <sys_page_map>
  800fed:	83 c4 20             	add    $0x20,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	79 12                	jns    801006 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  800ff4:	50                   	push   %eax
  800ff5:	68 30 27 80 00       	push   $0x802730
  800ffa:	6a 4c                	push   $0x4c
  800ffc:	68 9f 27 80 00       	push   $0x80279f
  801001:	e8 0d 0f 00 00       	call   801f13 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	68 05 08 00 00       	push   $0x805
  80100e:	56                   	push   %esi
  80100f:	6a 00                	push   $0x0
  801011:	56                   	push   %esi
  801012:	6a 00                	push   $0x0
  801014:	e8 46 fc ff ff       	call   800c5f <sys_page_map>
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 3a                	jns    80105a <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801020:	50                   	push   %eax
  801021:	68 54 27 80 00       	push   $0x802754
  801026:	6a 4e                	push   $0x4e
  801028:	68 9f 27 80 00       	push   $0x80279f
  80102d:	e8 e1 0e 00 00       	call   801f13 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	6a 05                	push   $0x5
  801037:	56                   	push   %esi
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	6a 00                	push   $0x0
  80103c:	e8 1e fc ff ff       	call   800c5f <sys_page_map>
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  801048:	50                   	push   %eax
  801049:	68 7c 27 80 00       	push   $0x80277c
  80104e:	6a 50                	push   $0x50
  801050:	68 9f 27 80 00       	push   $0x80279f
  801055:	e8 b9 0e 00 00       	call   801f13 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80105a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801060:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801066:	0f 85 e7 fe ff ff    	jne    800f53 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	6a 07                	push   $0x7
  801071:	68 00 f0 bf ee       	push   $0xeebff000
  801076:	ff 75 e4             	pushl  -0x1c(%ebp)
  801079:	e8 9e fb ff ff       	call   800c1c <sys_page_alloc>
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 14                	jns    801099 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	68 e4 27 80 00       	push   $0x8027e4
  80108d:	6a 76                	push   $0x76
  80108f:	68 9f 27 80 00       	push   $0x80279f
  801094:	e8 7a 0e 00 00       	call   801f13 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	68 c8 1f 80 00       	push   $0x801fc8
  8010a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a4:	e8 be fc ff ff       	call   800d67 <sys_env_set_pgfault_upcall>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	79 14                	jns    8010c4 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8010b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b3:	68 fe 27 80 00       	push   $0x8027fe
  8010b8:	6a 79                	push   $0x79
  8010ba:	68 9f 27 80 00       	push   $0x80279f
  8010bf:	e8 4f 0e 00 00       	call   801f13 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	6a 02                	push   $0x2
  8010c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cc:	e8 12 fc ff ff       	call   800ce3 <sys_env_set_status>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 14                	jns    8010ec <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8010d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010db:	68 1b 28 80 00       	push   $0x80281b
  8010e0:	6a 7b                	push   $0x7b
  8010e2:	68 9f 27 80 00       	push   $0x80279f
  8010e7:	e8 27 0e 00 00       	call   801f13 <_panic>
        return forkid;
  8010ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010fd:	68 32 28 80 00       	push   $0x802832
  801102:	68 83 00 00 00       	push   $0x83
  801107:	68 9f 27 80 00       	push   $0x80279f
  80110c:	e8 02 0e 00 00       	call   801f13 <_panic>

00801111 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	8b 75 08             	mov    0x8(%ebp),%esi
  801119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80111f:	85 c0                	test   %eax,%eax
  801121:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801126:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	50                   	push   %eax
  80112d:	e8 9a fc ff ff       	call   800dcc <sys_ipc_recv>
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	79 16                	jns    80114f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801139:	85 f6                	test   %esi,%esi
  80113b:	74 06                	je     801143 <ipc_recv+0x32>
  80113d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801143:	85 db                	test   %ebx,%ebx
  801145:	74 2c                	je     801173 <ipc_recv+0x62>
  801147:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80114d:	eb 24                	jmp    801173 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80114f:	85 f6                	test   %esi,%esi
  801151:	74 0a                	je     80115d <ipc_recv+0x4c>
  801153:	a1 04 40 80 00       	mov    0x804004,%eax
  801158:	8b 40 74             	mov    0x74(%eax),%eax
  80115b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80115d:	85 db                	test   %ebx,%ebx
  80115f:	74 0a                	je     80116b <ipc_recv+0x5a>
  801161:	a1 04 40 80 00       	mov    0x804004,%eax
  801166:	8b 40 78             	mov    0x78(%eax),%eax
  801169:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 40 70             	mov    0x70(%eax),%eax
}
  801173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	8b 7d 08             	mov    0x8(%ebp),%edi
  801186:	8b 75 0c             	mov    0xc(%ebp),%esi
  801189:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80118c:	85 db                	test   %ebx,%ebx
  80118e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801193:	0f 44 d8             	cmove  %eax,%ebx
  801196:	eb 1c                	jmp    8011b4 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801198:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80119b:	74 12                	je     8011af <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80119d:	50                   	push   %eax
  80119e:	68 48 28 80 00       	push   $0x802848
  8011a3:	6a 39                	push   $0x39
  8011a5:	68 63 28 80 00       	push   $0x802863
  8011aa:	e8 64 0d 00 00       	call   801f13 <_panic>
                 sys_yield();
  8011af:	e8 49 fa ff ff       	call   800bfd <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011b4:	ff 75 14             	pushl  0x14(%ebp)
  8011b7:	53                   	push   %ebx
  8011b8:	56                   	push   %esi
  8011b9:	57                   	push   %edi
  8011ba:	e8 ea fb ff ff       	call   800da9 <sys_ipc_try_send>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 d2                	js     801198 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011d9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011dc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011e2:	8b 52 50             	mov    0x50(%edx),%edx
  8011e5:	39 ca                	cmp    %ecx,%edx
  8011e7:	75 0d                	jne    8011f6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ec:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8011f1:	8b 40 08             	mov    0x8(%eax),%eax
  8011f4:	eb 0e                	jmp    801204 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011f6:	83 c0 01             	add    $0x1,%eax
  8011f9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011fe:	75 d9                	jne    8011d9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801200:	66 b8 00 00          	mov    $0x0,%ax
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	05 00 00 00 30       	add    $0x30000000,%eax
  801211:	c1 e8 0c             	shr    $0xc,%eax
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
  80121c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801226:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801233:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801238:	89 c2                	mov    %eax,%edx
  80123a:	c1 ea 16             	shr    $0x16,%edx
  80123d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801244:	f6 c2 01             	test   $0x1,%dl
  801247:	74 11                	je     80125a <fd_alloc+0x2d>
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 0c             	shr    $0xc,%edx
  80124e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	75 09                	jne    801263 <fd_alloc+0x36>
			*fd_store = fd;
  80125a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
  801261:	eb 17                	jmp    80127a <fd_alloc+0x4d>
  801263:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801268:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126d:	75 c9                	jne    801238 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80126f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801275:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801282:	83 f8 1f             	cmp    $0x1f,%eax
  801285:	77 36                	ja     8012bd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801287:	c1 e0 0c             	shl    $0xc,%eax
  80128a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 ea 16             	shr    $0x16,%edx
  801294:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 24                	je     8012c4 <fd_lookup+0x48>
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 0c             	shr    $0xc,%edx
  8012a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 1a                	je     8012cb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bb:	eb 13                	jmp    8012d0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c2:	eb 0c                	jmp    8012d0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb 05                	jmp    8012d0 <fd_lookup+0x54>
  8012cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012db:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e0:	eb 13                	jmp    8012f5 <dev_lookup+0x23>
  8012e2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012e5:	39 08                	cmp    %ecx,(%eax)
  8012e7:	75 0c                	jne    8012f5 <dev_lookup+0x23>
			*dev = devtab[i];
  8012e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	eb 2e                	jmp    801323 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f5:	8b 02                	mov    (%edx),%eax
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	75 e7                	jne    8012e2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801300:	8b 40 48             	mov    0x48(%eax),%eax
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	51                   	push   %ecx
  801307:	50                   	push   %eax
  801308:	68 70 28 80 00       	push   $0x802870
  80130d:	e8 7a ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	83 ec 10             	sub    $0x10,%esp
  80132d:	8b 75 08             	mov    0x8(%ebp),%esi
  801330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801337:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801340:	50                   	push   %eax
  801341:	e8 36 ff ff ff       	call   80127c <fd_lookup>
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 05                	js     801352 <fd_close+0x2d>
	    || fd != fd2)
  80134d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801350:	74 0c                	je     80135e <fd_close+0x39>
		return (must_exist ? r : 0);
  801352:	84 db                	test   %bl,%bl
  801354:	ba 00 00 00 00       	mov    $0x0,%edx
  801359:	0f 44 c2             	cmove  %edx,%eax
  80135c:	eb 41                	jmp    80139f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	ff 36                	pushl  (%esi)
  801367:	e8 66 ff ff ff       	call   8012d2 <dev_lookup>
  80136c:	89 c3                	mov    %eax,%ebx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 1a                	js     80138f <fd_close+0x6a>
		if (dev->dev_close)
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80137b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801380:	85 c0                	test   %eax,%eax
  801382:	74 0b                	je     80138f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	56                   	push   %esi
  801388:	ff d0                	call   *%eax
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	56                   	push   %esi
  801393:	6a 00                	push   $0x0
  801395:	e8 07 f9 ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	89 d8                	mov    %ebx,%eax
}
  80139f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 c4 fe ff ff       	call   80127c <fd_lookup>
  8013b8:	89 c2                	mov    %eax,%edx
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	85 d2                	test   %edx,%edx
  8013bf:	78 10                	js     8013d1 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	6a 01                	push   $0x1
  8013c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c9:	e8 57 ff ff ff       	call   801325 <fd_close>
  8013ce:	83 c4 10             	add    $0x10,%esp
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <close_all>:

void
close_all(void)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013da:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	e8 be ff ff ff       	call   8013a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e8:	83 c3 01             	add    $0x1,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	83 fb 20             	cmp    $0x20,%ebx
  8013f1:	75 ec                	jne    8013df <close_all+0xc>
		close(i);
}
  8013f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	57                   	push   %edi
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 2c             	sub    $0x2c,%esp
  801401:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801404:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	ff 75 08             	pushl  0x8(%ebp)
  80140b:	e8 6c fe ff ff       	call   80127c <fd_lookup>
  801410:	89 c2                	mov    %eax,%edx
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	85 d2                	test   %edx,%edx
  801417:	0f 88 c1 00 00 00    	js     8014de <dup+0xe6>
		return r;
	close(newfdnum);
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	56                   	push   %esi
  801421:	e8 80 ff ff ff       	call   8013a6 <close>

	newfd = INDEX2FD(newfdnum);
  801426:	89 f3                	mov    %esi,%ebx
  801428:	c1 e3 0c             	shl    $0xc,%ebx
  80142b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801431:	83 c4 04             	add    $0x4,%esp
  801434:	ff 75 e4             	pushl  -0x1c(%ebp)
  801437:	e8 da fd ff ff       	call   801216 <fd2data>
  80143c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80143e:	89 1c 24             	mov    %ebx,(%esp)
  801441:	e8 d0 fd ff ff       	call   801216 <fd2data>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144c:	89 f8                	mov    %edi,%eax
  80144e:	c1 e8 16             	shr    $0x16,%eax
  801451:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801458:	a8 01                	test   $0x1,%al
  80145a:	74 37                	je     801493 <dup+0x9b>
  80145c:	89 f8                	mov    %edi,%eax
  80145e:	c1 e8 0c             	shr    $0xc,%eax
  801461:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801468:	f6 c2 01             	test   $0x1,%dl
  80146b:	74 26                	je     801493 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	25 07 0e 00 00       	and    $0xe07,%eax
  80147c:	50                   	push   %eax
  80147d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801480:	6a 00                	push   $0x0
  801482:	57                   	push   %edi
  801483:	6a 00                	push   $0x0
  801485:	e8 d5 f7 ff ff       	call   800c5f <sys_page_map>
  80148a:	89 c7                	mov    %eax,%edi
  80148c:	83 c4 20             	add    $0x20,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 2e                	js     8014c1 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801493:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801496:	89 d0                	mov    %edx,%eax
  801498:	c1 e8 0c             	shr    $0xc,%eax
  80149b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014aa:	50                   	push   %eax
  8014ab:	53                   	push   %ebx
  8014ac:	6a 00                	push   $0x0
  8014ae:	52                   	push   %edx
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 a9 f7 ff ff       	call   800c5f <sys_page_map>
  8014b6:	89 c7                	mov    %eax,%edi
  8014b8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014bb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014bd:	85 ff                	test   %edi,%edi
  8014bf:	79 1d                	jns    8014de <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 d5 f7 ff ff       	call   800ca1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d2:	6a 00                	push   $0x0
  8014d4:	e8 c8 f7 ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	89 f8                	mov    %edi,%eax
}
  8014de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 14             	sub    $0x14,%esp
  8014ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	53                   	push   %ebx
  8014f5:	e8 82 fd ff ff       	call   80127c <fd_lookup>
  8014fa:	83 c4 08             	add    $0x8,%esp
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 6d                	js     801570 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150d:	ff 30                	pushl  (%eax)
  80150f:	e8 be fd ff ff       	call   8012d2 <dev_lookup>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 4c                	js     801567 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80151e:	8b 42 08             	mov    0x8(%edx),%eax
  801521:	83 e0 03             	and    $0x3,%eax
  801524:	83 f8 01             	cmp    $0x1,%eax
  801527:	75 21                	jne    80154a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801529:	a1 04 40 80 00       	mov    0x804004,%eax
  80152e:	8b 40 48             	mov    0x48(%eax),%eax
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	53                   	push   %ebx
  801535:	50                   	push   %eax
  801536:	68 b1 28 80 00       	push   $0x8028b1
  80153b:	e8 4c ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801548:	eb 26                	jmp    801570 <read+0x8a>
	}
	if (!dev->dev_read)
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	8b 40 08             	mov    0x8(%eax),%eax
  801550:	85 c0                	test   %eax,%eax
  801552:	74 17                	je     80156b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	52                   	push   %edx
  80155e:	ff d0                	call   *%eax
  801560:	89 c2                	mov    %eax,%edx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb 09                	jmp    801570 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	89 c2                	mov    %eax,%edx
  801569:	eb 05                	jmp    801570 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80156b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801570:	89 d0                	mov    %edx,%eax
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	8b 7d 08             	mov    0x8(%ebp),%edi
  801583:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801586:	bb 00 00 00 00       	mov    $0x0,%ebx
  80158b:	eb 21                	jmp    8015ae <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	89 f0                	mov    %esi,%eax
  801592:	29 d8                	sub    %ebx,%eax
  801594:	50                   	push   %eax
  801595:	89 d8                	mov    %ebx,%eax
  801597:	03 45 0c             	add    0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	57                   	push   %edi
  80159c:	e8 45 ff ff ff       	call   8014e6 <read>
		if (m < 0)
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 0c                	js     8015b4 <readn+0x3d>
			return m;
		if (m == 0)
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	74 06                	je     8015b2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ac:	01 c3                	add    %eax,%ebx
  8015ae:	39 f3                	cmp    %esi,%ebx
  8015b0:	72 db                	jb     80158d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015b2:	89 d8                	mov    %ebx,%eax
}
  8015b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b7:	5b                   	pop    %ebx
  8015b8:	5e                   	pop    %esi
  8015b9:	5f                   	pop    %edi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 14             	sub    $0x14,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 ac fc ff ff       	call   80127c <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 68                	js     801641 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	ff 30                	pushl  (%eax)
  8015e5:	e8 e8 fc ff ff       	call   8012d2 <dev_lookup>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 47                	js     801638 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f8:	75 21                	jne    80161b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ff:	8b 40 48             	mov    0x48(%eax),%eax
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	53                   	push   %ebx
  801606:	50                   	push   %eax
  801607:	68 cd 28 80 00       	push   $0x8028cd
  80160c:	e8 7b ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801619:	eb 26                	jmp    801641 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80161b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161e:	8b 52 0c             	mov    0xc(%edx),%edx
  801621:	85 d2                	test   %edx,%edx
  801623:	74 17                	je     80163c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	ff d2                	call   *%edx
  801631:	89 c2                	mov    %eax,%edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 09                	jmp    801641 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	89 c2                	mov    %eax,%edx
  80163a:	eb 05                	jmp    801641 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80163c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <seek>:

int
seek(int fdnum, off_t offset)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	ff 75 08             	pushl  0x8(%ebp)
  801655:	e8 22 fc ff ff       	call   80127c <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 0e                	js     80166f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801661:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801664:	8b 55 0c             	mov    0xc(%ebp),%edx
  801667:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	53                   	push   %ebx
  801680:	e8 f7 fb ff ff       	call   80127c <fd_lookup>
  801685:	83 c4 08             	add    $0x8,%esp
  801688:	89 c2                	mov    %eax,%edx
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 65                	js     8016f3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	ff 30                	pushl  (%eax)
  80169a:	e8 33 fc ff ff       	call   8012d2 <dev_lookup>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 44                	js     8016ea <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ad:	75 21                	jne    8016d0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016af:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b4:	8b 40 48             	mov    0x48(%eax),%eax
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	50                   	push   %eax
  8016bc:	68 90 28 80 00       	push   $0x802890
  8016c1:	e8 c6 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ce:	eb 23                	jmp    8016f3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d3:	8b 52 18             	mov    0x18(%edx),%edx
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	74 14                	je     8016ee <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	ff d2                	call   *%edx
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	eb 09                	jmp    8016f3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	eb 05                	jmp    8016f3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016f3:	89 d0                	mov    %edx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 14             	sub    $0x14,%esp
  801701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	50                   	push   %eax
  801708:	ff 75 08             	pushl  0x8(%ebp)
  80170b:	e8 6c fb ff ff       	call   80127c <fd_lookup>
  801710:	83 c4 08             	add    $0x8,%esp
  801713:	89 c2                	mov    %eax,%edx
  801715:	85 c0                	test   %eax,%eax
  801717:	78 58                	js     801771 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	ff 30                	pushl  (%eax)
  801725:	e8 a8 fb ff ff       	call   8012d2 <dev_lookup>
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 37                	js     801768 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801734:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801738:	74 32                	je     80176c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80173a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80173d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801744:	00 00 00 
	stat->st_isdir = 0;
  801747:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80174e:	00 00 00 
	stat->st_dev = dev;
  801751:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	53                   	push   %ebx
  80175b:	ff 75 f0             	pushl  -0x10(%ebp)
  80175e:	ff 50 14             	call   *0x14(%eax)
  801761:	89 c2                	mov    %eax,%edx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	eb 09                	jmp    801771 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	89 c2                	mov    %eax,%edx
  80176a:	eb 05                	jmp    801771 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80176c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801771:	89 d0                	mov    %edx,%eax
  801773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	6a 00                	push   $0x0
  801782:	ff 75 08             	pushl  0x8(%ebp)
  801785:	e8 09 02 00 00       	call   801993 <open>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 db                	test   %ebx,%ebx
  801791:	78 1b                	js     8017ae <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	53                   	push   %ebx
  80179a:	e8 5b ff ff ff       	call   8016fa <fstat>
  80179f:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a1:	89 1c 24             	mov    %ebx,(%esp)
  8017a4:	e8 fd fb ff ff       	call   8013a6 <close>
	return r;
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	89 f0                	mov    %esi,%eax
}
  8017ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	89 c6                	mov    %eax,%esi
  8017bc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017be:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c5:	75 12                	jne    8017d9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	6a 01                	push   $0x1
  8017cc:	e8 fd f9 ff ff       	call   8011ce <ipc_find_env>
  8017d1:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d9:	6a 07                	push   $0x7
  8017db:	68 00 50 80 00       	push   $0x805000
  8017e0:	56                   	push   %esi
  8017e1:	ff 35 00 40 80 00    	pushl  0x804000
  8017e7:	e8 8e f9 ff ff       	call   80117a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ec:	83 c4 0c             	add    $0xc,%esp
  8017ef:	6a 00                	push   $0x0
  8017f1:	53                   	push   %ebx
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 18 f9 ff ff       	call   801111 <ipc_recv>
}
  8017f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801811:	8b 45 0c             	mov    0xc(%ebp),%eax
  801814:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 02 00 00 00       	mov    $0x2,%eax
  801823:	e8 8d ff ff ff       	call   8017b5 <fsipc>
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	8b 40 0c             	mov    0xc(%eax),%eax
  801836:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 06 00 00 00       	mov    $0x6,%eax
  801845:	e8 6b ff ff ff       	call   8017b5 <fsipc>
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	8b 40 0c             	mov    0xc(%eax),%eax
  80185c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 05 00 00 00       	mov    $0x5,%eax
  80186b:	e8 45 ff ff ff       	call   8017b5 <fsipc>
  801870:	89 c2                	mov    %eax,%edx
  801872:	85 d2                	test   %edx,%edx
  801874:	78 2c                	js     8018a2 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	68 00 50 80 00       	push   $0x805000
  80187e:	53                   	push   %ebx
  80187f:	e8 8f ef ff ff       	call   800813 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801884:	a1 80 50 80 00       	mov    0x805080,%eax
  801889:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80188f:	a1 84 50 80 00       	mov    0x805084,%eax
  801894:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b9:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8018be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8018c1:	eb 3d                	jmp    801900 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8018c3:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8018c9:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8018ce:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	57                   	push   %edi
  8018d5:	53                   	push   %ebx
  8018d6:	68 08 50 80 00       	push   $0x805008
  8018db:	e8 c5 f0 ff ff       	call   8009a5 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8018e0:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f0:	e8 c0 fe ff ff       	call   8017b5 <fsipc>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 0d                	js     801909 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8018fc:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8018fe:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801900:	85 f6                	test   %esi,%esi
  801902:	75 bf                	jne    8018c3 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801904:	89 d8                	mov    %ebx,%eax
  801906:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801909:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801924:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 03 00 00 00       	mov    $0x3,%eax
  801934:	e8 7c fe ff ff       	call   8017b5 <fsipc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 4b                	js     80198a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193f:	39 c6                	cmp    %eax,%esi
  801941:	73 16                	jae    801959 <devfile_read+0x48>
  801943:	68 fc 28 80 00       	push   $0x8028fc
  801948:	68 03 29 80 00       	push   $0x802903
  80194d:	6a 7c                	push   $0x7c
  80194f:	68 18 29 80 00       	push   $0x802918
  801954:	e8 ba 05 00 00       	call   801f13 <_panic>
	assert(r <= PGSIZE);
  801959:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195e:	7e 16                	jle    801976 <devfile_read+0x65>
  801960:	68 23 29 80 00       	push   $0x802923
  801965:	68 03 29 80 00       	push   $0x802903
  80196a:	6a 7d                	push   $0x7d
  80196c:	68 18 29 80 00       	push   $0x802918
  801971:	e8 9d 05 00 00       	call   801f13 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	50                   	push   %eax
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	e8 1e f0 ff ff       	call   8009a5 <memmove>
	return r;
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 20             	sub    $0x20,%esp
  80199a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199d:	53                   	push   %ebx
  80199e:	e8 37 ee ff ff       	call   8007da <strlen>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ab:	7f 67                	jg     801a14 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 74 f8 ff ff       	call   80122d <fd_alloc>
  8019b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019bc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 57                	js     801a19 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	e8 43 ee ff ff       	call   800813 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e0:	e8 d0 fd ff ff       	call   8017b5 <fsipc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	79 14                	jns    801a02 <open+0x6f>
		fd_close(fd, 0);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	6a 00                	push   $0x0
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 2a f9 ff ff       	call   801325 <fd_close>
		return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 da                	mov    %ebx,%edx
  801a00:	eb 17                	jmp    801a19 <open+0x86>
	}

	return fd2num(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	e8 f9 f7 ff ff       	call   801206 <fd2num>
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	eb 05                	jmp    801a19 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a14:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a19:	89 d0                	mov    %edx,%eax
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a30:	e8 80 fd ff ff       	call   8017b5 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 75 08             	pushl  0x8(%ebp)
  801a45:	e8 cc f7 ff ff       	call   801216 <fd2data>
  801a4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a4c:	83 c4 08             	add    $0x8,%esp
  801a4f:	68 2f 29 80 00       	push   $0x80292f
  801a54:	53                   	push   %ebx
  801a55:	e8 b9 ed ff ff       	call   800813 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a5a:	8b 56 04             	mov    0x4(%esi),%edx
  801a5d:	89 d0                	mov    %edx,%eax
  801a5f:	2b 06                	sub    (%esi),%eax
  801a61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a6e:	00 00 00 
	stat->st_dev = &devpipe;
  801a71:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a78:	30 80 00 
	return 0;
}
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a91:	53                   	push   %ebx
  801a92:	6a 00                	push   $0x0
  801a94:	e8 08 f2 ff ff       	call   800ca1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a99:	89 1c 24             	mov    %ebx,(%esp)
  801a9c:	e8 75 f7 ff ff       	call   801216 <fd2data>
  801aa1:	83 c4 08             	add    $0x8,%esp
  801aa4:	50                   	push   %eax
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 f5 f1 ff ff       	call   800ca1 <sys_page_unmap>
}
  801aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	57                   	push   %edi
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 1c             	sub    $0x1c,%esp
  801aba:	89 c6                	mov    %eax,%esi
  801abc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	56                   	push   %esi
  801acb:	e8 1c 05 00 00       	call   801fec <pageref>
  801ad0:	89 c7                	mov    %eax,%edi
  801ad2:	83 c4 04             	add    $0x4,%esp
  801ad5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad8:	e8 0f 05 00 00       	call   801fec <pageref>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	39 c7                	cmp    %eax,%edi
  801ae2:	0f 94 c2             	sete   %dl
  801ae5:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801ae8:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801aee:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801af1:	39 fb                	cmp    %edi,%ebx
  801af3:	74 19                	je     801b0e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801af5:	84 d2                	test   %dl,%dl
  801af7:	74 c6                	je     801abf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af9:	8b 51 58             	mov    0x58(%ecx),%edx
  801afc:	50                   	push   %eax
  801afd:	52                   	push   %edx
  801afe:	53                   	push   %ebx
  801aff:	68 36 29 80 00       	push   $0x802936
  801b04:	e8 83 e7 ff ff       	call   80028c <cprintf>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	eb b1                	jmp    801abf <_pipeisclosed+0xe>
	}
}
  801b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	57                   	push   %edi
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 28             	sub    $0x28,%esp
  801b1f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b22:	56                   	push   %esi
  801b23:	e8 ee f6 ff ff       	call   801216 <fd2data>
  801b28:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	bf 00 00 00 00       	mov    $0x0,%edi
  801b32:	eb 4b                	jmp    801b7f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b34:	89 da                	mov    %ebx,%edx
  801b36:	89 f0                	mov    %esi,%eax
  801b38:	e8 74 ff ff ff       	call   801ab1 <_pipeisclosed>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	75 48                	jne    801b89 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b41:	e8 b7 f0 ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b46:	8b 43 04             	mov    0x4(%ebx),%eax
  801b49:	8b 0b                	mov    (%ebx),%ecx
  801b4b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b4e:	39 d0                	cmp    %edx,%eax
  801b50:	73 e2                	jae    801b34 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b55:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b59:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	c1 fa 1f             	sar    $0x1f,%edx
  801b61:	89 d1                	mov    %edx,%ecx
  801b63:	c1 e9 1b             	shr    $0x1b,%ecx
  801b66:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b69:	83 e2 1f             	and    $0x1f,%edx
  801b6c:	29 ca                	sub    %ecx,%edx
  801b6e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b72:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b76:	83 c0 01             	add    $0x1,%eax
  801b79:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7c:	83 c7 01             	add    $0x1,%edi
  801b7f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b82:	75 c2                	jne    801b46 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	eb 05                	jmp    801b8e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 18             	sub    $0x18,%esp
  801b9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba2:	57                   	push   %edi
  801ba3:	e8 6e f6 ff ff       	call   801216 <fd2data>
  801ba8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb2:	eb 3d                	jmp    801bf1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb4:	85 db                	test   %ebx,%ebx
  801bb6:	74 04                	je     801bbc <devpipe_read+0x26>
				return i;
  801bb8:	89 d8                	mov    %ebx,%eax
  801bba:	eb 44                	jmp    801c00 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bbc:	89 f2                	mov    %esi,%edx
  801bbe:	89 f8                	mov    %edi,%eax
  801bc0:	e8 ec fe ff ff       	call   801ab1 <_pipeisclosed>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	75 32                	jne    801bfb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc9:	e8 2f f0 ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bce:	8b 06                	mov    (%esi),%eax
  801bd0:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd3:	74 df                	je     801bb4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd5:	99                   	cltd   
  801bd6:	c1 ea 1b             	shr    $0x1b,%edx
  801bd9:	01 d0                	add    %edx,%eax
  801bdb:	83 e0 1f             	and    $0x1f,%eax
  801bde:	29 d0                	sub    %edx,%eax
  801be0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801beb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bee:	83 c3 01             	add    $0x1,%ebx
  801bf1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf4:	75 d8                	jne    801bce <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf9:	eb 05                	jmp    801c00 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 14 f6 ff ff       	call   80122d <fd_alloc>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 2c 01 00 00    	js     801d52 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 e4 ef ff ff       	call   800c1c <sys_page_alloc>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 0d 01 00 00    	js     801d52 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4b:	50                   	push   %eax
  801c4c:	e8 dc f5 ff ff       	call   80122d <fd_alloc>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 e2 00 00 00    	js     801d40 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5e:	83 ec 04             	sub    $0x4,%esp
  801c61:	68 07 04 00 00       	push   $0x407
  801c66:	ff 75 f0             	pushl  -0x10(%ebp)
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 ac ef ff ff       	call   800c1c <sys_page_alloc>
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	0f 88 c3 00 00 00    	js     801d40 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	e8 8e f5 ff ff       	call   801216 <fd2data>
  801c88:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8a:	83 c4 0c             	add    $0xc,%esp
  801c8d:	68 07 04 00 00       	push   $0x407
  801c92:	50                   	push   %eax
  801c93:	6a 00                	push   $0x0
  801c95:	e8 82 ef ff ff       	call   800c1c <sys_page_alloc>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 89 00 00 00    	js     801d30 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cad:	e8 64 f5 ff ff       	call   801216 <fd2data>
  801cb2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb9:	50                   	push   %eax
  801cba:	6a 00                	push   $0x0
  801cbc:	56                   	push   %esi
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 9b ef ff ff       	call   800c5f <sys_page_map>
  801cc4:	89 c3                	mov    %eax,%ebx
  801cc6:	83 c4 20             	add    $0x20,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 55                	js     801d22 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccd:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce2:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ceb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	e8 04 f5 ff ff       	call   801206 <fd2num>
  801d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d05:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d07:	83 c4 04             	add    $0x4,%esp
  801d0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0d:	e8 f4 f4 ff ff       	call   801206 <fd2num>
  801d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d15:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d20:	eb 30                	jmp    801d52 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	56                   	push   %esi
  801d26:	6a 00                	push   $0x0
  801d28:	e8 74 ef ff ff       	call   800ca1 <sys_page_unmap>
  801d2d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d30:	83 ec 08             	sub    $0x8,%esp
  801d33:	ff 75 f0             	pushl  -0x10(%ebp)
  801d36:	6a 00                	push   $0x0
  801d38:	e8 64 ef ff ff       	call   800ca1 <sys_page_unmap>
  801d3d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d40:	83 ec 08             	sub    $0x8,%esp
  801d43:	ff 75 f4             	pushl  -0xc(%ebp)
  801d46:	6a 00                	push   $0x0
  801d48:	e8 54 ef ff ff       	call   800ca1 <sys_page_unmap>
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d52:	89 d0                	mov    %edx,%eax
  801d54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d64:	50                   	push   %eax
  801d65:	ff 75 08             	pushl  0x8(%ebp)
  801d68:	e8 0f f5 ff ff       	call   80127c <fd_lookup>
  801d6d:	89 c2                	mov    %eax,%edx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 d2                	test   %edx,%edx
  801d74:	78 18                	js     801d8e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7c:	e8 95 f4 ff ff       	call   801216 <fd2data>
	return _pipeisclosed(fd, p);
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	e8 26 fd ff ff       	call   801ab1 <_pipeisclosed>
  801d8b:	83 c4 10             	add    $0x10,%esp
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da0:	68 4e 29 80 00       	push   $0x80294e
  801da5:	ff 75 0c             	pushl  0xc(%ebp)
  801da8:	e8 66 ea ff ff       	call   800813 <strcpy>
	return 0;
}
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcb:	eb 2d                	jmp    801dfa <devcons_write+0x46>
		m = n - tot;
  801dcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dd2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dda:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	53                   	push   %ebx
  801de1:	03 45 0c             	add    0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	57                   	push   %edi
  801de6:	e8 ba eb ff ff       	call   8009a5 <memmove>
		sys_cputs(buf, m);
  801deb:	83 c4 08             	add    $0x8,%esp
  801dee:	53                   	push   %ebx
  801def:	57                   	push   %edi
  801df0:	e8 6b ed ff ff       	call   800b60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df5:	01 de                	add    %ebx,%esi
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	89 f0                	mov    %esi,%eax
  801dfc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dff:	72 cc                	jb     801dcd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e18:	75 07                	jne    801e21 <devcons_read+0x18>
  801e1a:	eb 28                	jmp    801e44 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1c:	e8 dc ed ff ff       	call   800bfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e21:	e8 58 ed ff ff       	call   800b7e <sys_cgetc>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	74 f2                	je     801e1c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 16                	js     801e44 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e2e:	83 f8 04             	cmp    $0x4,%eax
  801e31:	74 0c                	je     801e3f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e36:	88 02                	mov    %al,(%edx)
	return 1;
  801e38:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3d:	eb 05                	jmp    801e44 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e52:	6a 01                	push   $0x1
  801e54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	e8 03 ed ff ff       	call   800b60 <sys_cputs>
  801e5d:	83 c4 10             	add    $0x10,%esp
}
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    

00801e62 <getchar>:

int
getchar(void)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e68:	6a 01                	push   $0x1
  801e6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6d:	50                   	push   %eax
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 71 f6 ff ff       	call   8014e6 <read>
	if (r < 0)
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 0f                	js     801e8b <getchar+0x29>
		return r;
	if (r < 1)
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	7e 06                	jle    801e86 <getchar+0x24>
		return -E_EOF;
	return c;
  801e80:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e84:	eb 05                	jmp    801e8b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e86:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	ff 75 08             	pushl  0x8(%ebp)
  801e9a:	e8 dd f3 ff ff       	call   80127c <fd_lookup>
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 11                	js     801eb7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea9:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801eaf:	39 10                	cmp    %edx,(%eax)
  801eb1:	0f 94 c0             	sete   %al
  801eb4:	0f b6 c0             	movzbl %al,%eax
}
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <opencons>:

int
opencons(void)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	e8 65 f3 ff ff       	call   80122d <fd_alloc>
  801ec8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 3e                	js     801f0f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	68 07 04 00 00       	push   $0x407
  801ed9:	ff 75 f4             	pushl  -0xc(%ebp)
  801edc:	6a 00                	push   $0x0
  801ede:	e8 39 ed ff ff       	call   800c1c <sys_page_alloc>
  801ee3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 23                	js     801f0f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eec:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	50                   	push   %eax
  801f05:	e8 fc f2 ff ff       	call   801206 <fd2num>
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	83 c4 10             	add    $0x10,%esp
}
  801f0f:	89 d0                	mov    %edx,%eax
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f18:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f1b:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f21:	e8 b8 ec ff ff       	call   800bde <sys_getenvid>
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	ff 75 0c             	pushl  0xc(%ebp)
  801f2c:	ff 75 08             	pushl  0x8(%ebp)
  801f2f:	56                   	push   %esi
  801f30:	50                   	push   %eax
  801f31:	68 5c 29 80 00       	push   $0x80295c
  801f36:	e8 51 e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f3b:	83 c4 18             	add    $0x18,%esp
  801f3e:	53                   	push   %ebx
  801f3f:	ff 75 10             	pushl  0x10(%ebp)
  801f42:	e8 f4 e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801f47:	c7 04 24 19 28 80 00 	movl   $0x802819,(%esp)
  801f4e:	e8 39 e3 ff ff       	call   80028c <cprintf>
  801f53:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f56:	cc                   	int3   
  801f57:	eb fd                	jmp    801f56 <_panic+0x43>

00801f59 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f5f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f66:	75 2c                	jne    801f94 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801f68:	83 ec 04             	sub    $0x4,%esp
  801f6b:	6a 07                	push   $0x7
  801f6d:	68 00 f0 bf ee       	push   $0xeebff000
  801f72:	6a 00                	push   $0x0
  801f74:	e8 a3 ec ff ff       	call   800c1c <sys_page_alloc>
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	74 14                	je     801f94 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801f80:	83 ec 04             	sub    $0x4,%esp
  801f83:	68 80 29 80 00       	push   $0x802980
  801f88:	6a 21                	push   $0x21
  801f8a:	68 e4 29 80 00       	push   $0x8029e4
  801f8f:	e8 7f ff ff ff       	call   801f13 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f94:	8b 45 08             	mov    0x8(%ebp),%eax
  801f97:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f9c:	83 ec 08             	sub    $0x8,%esp
  801f9f:	68 c8 1f 80 00       	push   $0x801fc8
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 bc ed ff ff       	call   800d67 <sys_env_set_pgfault_upcall>
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	79 14                	jns    801fc6 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	68 ac 29 80 00       	push   $0x8029ac
  801fba:	6a 29                	push   $0x29
  801fbc:	68 e4 29 80 00       	push   $0x8029e4
  801fc1:	e8 4d ff ff ff       	call   801f13 <_panic>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fce:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fd0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801fd3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801fd8:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801fdc:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801fe0:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  801fe2:	83 c4 08             	add    $0x8,%esp
        popal
  801fe5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801fe6:	83 c4 04             	add    $0x4,%esp
        popfl
  801fe9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801fea:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801feb:	c3                   	ret    

00801fec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	c1 e8 16             	shr    $0x16,%eax
  801ff7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802003:	f6 c1 01             	test   $0x1,%cl
  802006:	74 1d                	je     802025 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802012:	f6 c2 01             	test   $0x1,%dl
  802015:	74 0e                	je     802025 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802021:	ef 
  802022:	0f b7 c0             	movzwl %ax,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	83 ec 10             	sub    $0x10,%esp
  802036:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80203a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80203e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802042:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802046:	85 d2                	test   %edx,%edx
  802048:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80204c:	89 34 24             	mov    %esi,(%esp)
  80204f:	89 c8                	mov    %ecx,%eax
  802051:	75 35                	jne    802088 <__udivdi3+0x58>
  802053:	39 f1                	cmp    %esi,%ecx
  802055:	0f 87 bd 00 00 00    	ja     802118 <__udivdi3+0xe8>
  80205b:	85 c9                	test   %ecx,%ecx
  80205d:	89 cd                	mov    %ecx,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f1                	div    %ecx
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 f0                	mov    %esi,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c6                	mov    %eax,%esi
  802074:	89 f8                	mov    %edi,%eax
  802076:	f7 f5                	div    %ebp
  802078:	89 f2                	mov    %esi,%edx
  80207a:	83 c4 10             	add    $0x10,%esp
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    
  802081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802088:	3b 14 24             	cmp    (%esp),%edx
  80208b:	77 7b                	ja     802108 <__udivdi3+0xd8>
  80208d:	0f bd f2             	bsr    %edx,%esi
  802090:	83 f6 1f             	xor    $0x1f,%esi
  802093:	0f 84 97 00 00 00    	je     802130 <__udivdi3+0x100>
  802099:	bd 20 00 00 00       	mov    $0x20,%ebp
  80209e:	89 d7                	mov    %edx,%edi
  8020a0:	89 f1                	mov    %esi,%ecx
  8020a2:	29 f5                	sub    %esi,%ebp
  8020a4:	d3 e7                	shl    %cl,%edi
  8020a6:	89 c2                	mov    %eax,%edx
  8020a8:	89 e9                	mov    %ebp,%ecx
  8020aa:	d3 ea                	shr    %cl,%edx
  8020ac:	89 f1                	mov    %esi,%ecx
  8020ae:	09 fa                	or     %edi,%edx
  8020b0:	8b 3c 24             	mov    (%esp),%edi
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020c3:	89 fa                	mov    %edi,%edx
  8020c5:	d3 ea                	shr    %cl,%edx
  8020c7:	89 f1                	mov    %esi,%ecx
  8020c9:	d3 e7                	shl    %cl,%edi
  8020cb:	89 e9                	mov    %ebp,%ecx
  8020cd:	d3 e8                	shr    %cl,%eax
  8020cf:	09 c7                	or     %eax,%edi
  8020d1:	89 f8                	mov    %edi,%eax
  8020d3:	f7 74 24 08          	divl   0x8(%esp)
  8020d7:	89 d5                	mov    %edx,%ebp
  8020d9:	89 c7                	mov    %eax,%edi
  8020db:	f7 64 24 0c          	mull   0xc(%esp)
  8020df:	39 d5                	cmp    %edx,%ebp
  8020e1:	89 14 24             	mov    %edx,(%esp)
  8020e4:	72 11                	jb     8020f7 <__udivdi3+0xc7>
  8020e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020ea:	89 f1                	mov    %esi,%ecx
  8020ec:	d3 e2                	shl    %cl,%edx
  8020ee:	39 c2                	cmp    %eax,%edx
  8020f0:	73 5e                	jae    802150 <__udivdi3+0x120>
  8020f2:	3b 2c 24             	cmp    (%esp),%ebp
  8020f5:	75 59                	jne    802150 <__udivdi3+0x120>
  8020f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8020fa:	31 f6                	xor    %esi,%esi
  8020fc:	89 f2                	mov    %esi,%edx
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	31 f6                	xor    %esi,%esi
  80210a:	31 c0                	xor    %eax,%eax
  80210c:	89 f2                	mov    %esi,%edx
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    
  802115:	8d 76 00             	lea    0x0(%esi),%esi
  802118:	89 f2                	mov    %esi,%edx
  80211a:	31 f6                	xor    %esi,%esi
  80211c:	89 f8                	mov    %edi,%eax
  80211e:	f7 f1                	div    %ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802134:	76 0b                	jbe    802141 <__udivdi3+0x111>
  802136:	31 c0                	xor    %eax,%eax
  802138:	3b 14 24             	cmp    (%esp),%edx
  80213b:	0f 83 37 ff ff ff    	jae    802078 <__udivdi3+0x48>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	e9 2d ff ff ff       	jmp    802078 <__udivdi3+0x48>
  80214b:	90                   	nop
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 f8                	mov    %edi,%eax
  802152:	31 f6                	xor    %esi,%esi
  802154:	e9 1f ff ff ff       	jmp    802078 <__udivdi3+0x48>
  802159:	66 90                	xchg   %ax,%ax
  80215b:	66 90                	xchg   %ax,%ax
  80215d:	66 90                	xchg   %ax,%ax
  80215f:	90                   	nop

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	83 ec 20             	sub    $0x20,%esp
  802166:	8b 44 24 34          	mov    0x34(%esp),%eax
  80216a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802172:	89 c6                	mov    %eax,%esi
  802174:	89 44 24 10          	mov    %eax,0x10(%esp)
  802178:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80217c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802180:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802184:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802188:	89 74 24 18          	mov    %esi,0x18(%esp)
  80218c:	85 c0                	test   %eax,%eax
  80218e:	89 c2                	mov    %eax,%edx
  802190:	75 1e                	jne    8021b0 <__umoddi3+0x50>
  802192:	39 f7                	cmp    %esi,%edi
  802194:	76 52                	jbe    8021e8 <__umoddi3+0x88>
  802196:	89 c8                	mov    %ecx,%eax
  802198:	89 f2                	mov    %esi,%edx
  80219a:	f7 f7                	div    %edi
  80219c:	89 d0                	mov    %edx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	83 c4 20             	add    $0x20,%esp
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    
  8021a7:	89 f6                	mov    %esi,%esi
  8021a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021b0:	39 f0                	cmp    %esi,%eax
  8021b2:	77 5c                	ja     802210 <__umoddi3+0xb0>
  8021b4:	0f bd e8             	bsr    %eax,%ebp
  8021b7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ba:	75 64                	jne    802220 <__umoddi3+0xc0>
  8021bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021c4:	0f 86 f6 00 00 00    	jbe    8022c0 <__umoddi3+0x160>
  8021ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021ce:	0f 82 ec 00 00 00    	jb     8022c0 <__umoddi3+0x160>
  8021d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8021dc:	83 c4 20             	add    $0x20,%esp
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	85 ff                	test   %edi,%edi
  8021ea:	89 fd                	mov    %edi,%ebp
  8021ec:	75 0b                	jne    8021f9 <__umoddi3+0x99>
  8021ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f7                	div    %edi
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8021fd:	31 d2                	xor    %edx,%edx
  8021ff:	f7 f5                	div    %ebp
  802201:	89 c8                	mov    %ecx,%eax
  802203:	f7 f5                	div    %ebp
  802205:	eb 95                	jmp    80219c <__umoddi3+0x3c>
  802207:	89 f6                	mov    %esi,%esi
  802209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 20             	add    $0x20,%esp
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	90                   	nop
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	b8 20 00 00 00       	mov    $0x20,%eax
  802225:	89 e9                	mov    %ebp,%ecx
  802227:	29 e8                	sub    %ebp,%eax
  802229:	d3 e2                	shl    %cl,%edx
  80222b:	89 c7                	mov    %eax,%edi
  80222d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802231:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 c1                	mov    %eax,%ecx
  80223b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80223f:	09 d1                	or     %edx,%ecx
  802241:	89 fa                	mov    %edi,%edx
  802243:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802247:	89 e9                	mov    %ebp,%ecx
  802249:	d3 e0                	shl    %cl,%eax
  80224b:	89 f9                	mov    %edi,%ecx
  80224d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802251:	89 f0                	mov    %esi,%eax
  802253:	d3 e8                	shr    %cl,%eax
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	89 c7                	mov    %eax,%edi
  802259:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80225d:	d3 e6                	shl    %cl,%esi
  80225f:	89 d1                	mov    %edx,%ecx
  802261:	89 fa                	mov    %edi,%edx
  802263:	d3 e8                	shr    %cl,%eax
  802265:	89 e9                	mov    %ebp,%ecx
  802267:	09 f0                	or     %esi,%eax
  802269:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80226d:	f7 74 24 10          	divl   0x10(%esp)
  802271:	d3 e6                	shl    %cl,%esi
  802273:	89 d1                	mov    %edx,%ecx
  802275:	f7 64 24 0c          	mull   0xc(%esp)
  802279:	39 d1                	cmp    %edx,%ecx
  80227b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80227f:	89 d7                	mov    %edx,%edi
  802281:	89 c6                	mov    %eax,%esi
  802283:	72 0a                	jb     80228f <__umoddi3+0x12f>
  802285:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802289:	73 10                	jae    80229b <__umoddi3+0x13b>
  80228b:	39 d1                	cmp    %edx,%ecx
  80228d:	75 0c                	jne    80229b <__umoddi3+0x13b>
  80228f:	89 d7                	mov    %edx,%edi
  802291:	89 c6                	mov    %eax,%esi
  802293:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802297:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80229b:	89 ca                	mov    %ecx,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022a3:	29 f0                	sub    %esi,%eax
  8022a5:	19 fa                	sbb    %edi,%edx
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022ae:	89 d7                	mov    %edx,%edi
  8022b0:	d3 e7                	shl    %cl,%edi
  8022b2:	89 e9                	mov    %ebp,%ecx
  8022b4:	09 f8                	or     %edi,%eax
  8022b6:	d3 ea                	shr    %cl,%edx
  8022b8:	83 c4 20             	add    $0x20,%esp
  8022bb:	5e                   	pop    %esi
  8022bc:	5f                   	pop    %edi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    
  8022bf:	90                   	nop
  8022c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022c4:	29 f9                	sub    %edi,%ecx
  8022c6:	19 c6                	sbb    %eax,%esi
  8022c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022d0:	e9 ff fe ff ff       	jmp    8021d4 <__umoddi3+0x74>
