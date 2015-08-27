
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
  800039:	e8 52 0f 00 00       	call   800f90 <fork>
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
  800057:	e8 56 11 00 00       	call   8011b2 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 28 80 00       	push   $0x802800
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
  80009d:	68 14 28 80 00       	push   $0x802814
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
  8000db:	e8 3b 11 00 00       	call   80121b <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
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
  800131:	e8 e5 10 00 00       	call   80121b <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 69 10 00 00       	call   8011b2 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 28 80 00       	push   $0x802800
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
  80018a:	68 34 28 80 00       	push   $0x802834
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
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001e5:	e8 8f 12 00 00       	call   801479 <close_all>
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
  8002ef:	e8 4c 22 00 00       	call   802540 <__udivdi3>
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
  80032d:	e8 3e 23 00 00       	call   802670 <__umoddi3>
  800332:	83 c4 14             	add    $0x14,%esp
  800335:	0f be 80 ac 28 80 00 	movsbl 0x8028ac(%eax),%eax
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
  800431:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
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
  8004f5:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	75 18                	jne    800518 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800500:	50                   	push   %eax
  800501:	68 c4 28 80 00       	push   $0x8028c4
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
  800519:	68 19 2e 80 00       	push   $0x802e19
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
  800546:	ba bd 28 80 00       	mov    $0x8028bd,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800bc5:	68 df 2b 80 00       	push   $0x802bdf
  800bca:	6a 22                	push   $0x22
  800bcc:	68 fc 2b 80 00       	push   $0x802bfc
  800bd1:	e8 54 18 00 00       	call   80242a <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800c46:	68 df 2b 80 00       	push   $0x802bdf
  800c4b:	6a 22                	push   $0x22
  800c4d:	68 fc 2b 80 00       	push   $0x802bfc
  800c52:	e8 d3 17 00 00       	call   80242a <_panic>

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
	// return value.
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
  800c88:	68 df 2b 80 00       	push   $0x802bdf
  800c8d:	6a 22                	push   $0x22
  800c8f:	68 fc 2b 80 00       	push   $0x802bfc
  800c94:	e8 91 17 00 00       	call   80242a <_panic>

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
	// return value.
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
  800cca:	68 df 2b 80 00       	push   $0x802bdf
  800ccf:	6a 22                	push   $0x22
  800cd1:	68 fc 2b 80 00       	push   $0x802bfc
  800cd6:	e8 4f 17 00 00       	call   80242a <_panic>

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
	// return value.
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
  800d0c:	68 df 2b 80 00       	push   $0x802bdf
  800d11:	6a 22                	push   $0x22
  800d13:	68 fc 2b 80 00       	push   $0x802bfc
  800d18:	e8 0d 17 00 00       	call   80242a <_panic>
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
	// return value.
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
  800d4e:	68 df 2b 80 00       	push   $0x802bdf
  800d53:	6a 22                	push   $0x22
  800d55:	68 fc 2b 80 00       	push   $0x802bfc
  800d5a:	e8 cb 16 00 00       	call   80242a <_panic>

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
	// return value.
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
  800d90:	68 df 2b 80 00       	push   $0x802bdf
  800d95:	6a 22                	push   $0x22
  800d97:	68 fc 2b 80 00       	push   $0x802bfc
  800d9c:	e8 89 16 00 00       	call   80242a <_panic>

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
	// return value.
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
	// return value.
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
  800df4:	68 df 2b 80 00       	push   $0x802bdf
  800df9:	6a 22                	push   $0x22
  800dfb:	68 fc 2b 80 00       	push   $0x802bfc
  800e00:	e8 25 16 00 00       	call   80242a <_panic>

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

00800e0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_transmit>:

int
sys_transmit(void *addr)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 cb                	mov    %ecx,%ebx
  800e44:	89 cf                	mov    %ecx,%edi
  800e46:	89 ce                	mov    %ecx,%esi
  800e48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 17                	jle    800e65 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	50                   	push   %eax
  800e52:	6a 0f                	push   $0xf
  800e54:	68 df 2b 80 00       	push   $0x802bdf
  800e59:	6a 22                	push   $0x22
  800e5b:	68 fc 2b 80 00       	push   $0x802bfc
  800e60:	e8 c5 15 00 00       	call   80242a <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_recv>:

int
sys_recv(void *addr)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	89 cb                	mov    %ecx,%ebx
  800e85:	89 cf                	mov    %ecx,%edi
  800e87:	89 ce                	mov    %ecx,%esi
  800e89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7e 17                	jle    800ea6 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	50                   	push   %eax
  800e93:	6a 10                	push   $0x10
  800e95:	68 df 2b 80 00       	push   $0x802bdf
  800e9a:	6a 22                	push   $0x22
  800e9c:	68 fc 2b 80 00       	push   $0x802bfc
  800ea1:	e8 84 15 00 00       	call   80242a <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800eb8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800eba:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ebe:	74 2e                	je     800eee <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 16             	shr    $0x16,%edx
  800ec5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 1d                	je     800eee <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800edd:	f6 c1 01             	test   $0x1,%cl
  800ee0:	74 0c                	je     800eee <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ee2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ee9:	f6 c6 08             	test   $0x8,%dh
  800eec:	75 14                	jne    800f02 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 0c 2c 80 00       	push   $0x802c0c
  800ef6:	6a 21                	push   $0x21
  800ef8:	68 9f 2c 80 00       	push   $0x802c9f
  800efd:	e8 28 15 00 00       	call   80242a <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800f02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f07:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800f09:	83 ec 04             	sub    $0x4,%esp
  800f0c:	6a 07                	push   $0x7
  800f0e:	68 00 f0 7f 00       	push   $0x7ff000
  800f13:	6a 00                	push   $0x0
  800f15:	e8 02 fd ff ff       	call   800c1c <sys_page_alloc>
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 14                	jns    800f35 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 aa 2c 80 00       	push   $0x802caa
  800f29:	6a 2b                	push   $0x2b
  800f2b:	68 9f 2c 80 00       	push   $0x802c9f
  800f30:	e8 f5 14 00 00       	call   80242a <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	68 00 10 00 00       	push   $0x1000
  800f3d:	53                   	push   %ebx
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	e8 5d fa ff ff       	call   8009a5 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800f48:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4f:	53                   	push   %ebx
  800f50:	6a 00                	push   $0x0
  800f52:	68 00 f0 7f 00       	push   $0x7ff000
  800f57:	6a 00                	push   $0x0
  800f59:	e8 01 fd ff ff       	call   800c5f <sys_page_map>
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 14                	jns    800f79 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	68 c0 2c 80 00       	push   $0x802cc0
  800f6d:	6a 2e                	push   $0x2e
  800f6f:	68 9f 2c 80 00       	push   $0x802c9f
  800f74:	e8 b1 14 00 00       	call   80242a <_panic>
        sys_page_unmap(0, PFTEMP); 
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	68 00 f0 7f 00       	push   $0x7ff000
  800f81:	6a 00                	push   $0x0
  800f83:	e8 19 fd ff ff       	call   800ca1 <sys_page_unmap>
  800f88:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800f8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800f99:	68 ae 0e 80 00       	push   $0x800eae
  800f9e:	e8 cd 14 00 00       	call   802470 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fa3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa8:	cd 30                	int    $0x30
  800faa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 12                	jns    800fc6 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800fb4:	50                   	push   %eax
  800fb5:	68 d4 2c 80 00       	push   $0x802cd4
  800fba:	6a 6d                	push   $0x6d
  800fbc:	68 9f 2c 80 00       	push   $0x802c9f
  800fc1:	e8 64 14 00 00       	call   80242a <_panic>
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800fcd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fd1:	75 21                	jne    800ff4 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800fd3:	e8 06 fc ff ff       	call   800bde <sys_getenvid>
  800fd8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe5:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fea:	b8 00 00 00 00       	mov    $0x0,%eax
  800fef:	e9 9c 01 00 00       	jmp    801190 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800ff4:	89 d8                	mov    %ebx,%eax
  800ff6:	c1 e8 16             	shr    $0x16,%eax
  800ff9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801000:	a8 01                	test   $0x1,%al
  801002:	0f 84 f3 00 00 00    	je     8010fb <fork+0x16b>
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	c1 e8 0c             	shr    $0xc,%eax
  80100d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801014:	f6 c2 01             	test   $0x1,%dl
  801017:	0f 84 de 00 00 00    	je     8010fb <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  80101d:	89 c6                	mov    %eax,%esi
  80101f:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801022:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801029:	f6 c6 04             	test   $0x4,%dh
  80102c:	74 37                	je     801065 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  80102e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	25 07 0e 00 00       	and    $0xe07,%eax
  80103d:	50                   	push   %eax
  80103e:	56                   	push   %esi
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	6a 00                	push   $0x0
  801043:	e8 17 fc ff ff       	call   800c5f <sys_page_map>
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	0f 89 a8 00 00 00    	jns    8010fb <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801053:	50                   	push   %eax
  801054:	68 30 2c 80 00       	push   $0x802c30
  801059:	6a 49                	push   $0x49
  80105b:	68 9f 2c 80 00       	push   $0x802c9f
  801060:	e8 c5 13 00 00       	call   80242a <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801065:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106c:	f6 c6 08             	test   $0x8,%dh
  80106f:	75 0b                	jne    80107c <fork+0xec>
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	a8 02                	test   $0x2,%al
  80107a:	74 57                	je     8010d3 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	68 05 08 00 00       	push   $0x805
  801084:	56                   	push   %esi
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	6a 00                	push   $0x0
  801089:	e8 d1 fb ff ff       	call   800c5f <sys_page_map>
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 12                	jns    8010a7 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  801095:	50                   	push   %eax
  801096:	68 30 2c 80 00       	push   $0x802c30
  80109b:	6a 4c                	push   $0x4c
  80109d:	68 9f 2c 80 00       	push   $0x802c9f
  8010a2:	e8 83 13 00 00       	call   80242a <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	68 05 08 00 00       	push   $0x805
  8010af:	56                   	push   %esi
  8010b0:	6a 00                	push   $0x0
  8010b2:	56                   	push   %esi
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 a5 fb ff ff       	call   800c5f <sys_page_map>
  8010ba:	83 c4 20             	add    $0x20,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 3a                	jns    8010fb <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  8010c1:	50                   	push   %eax
  8010c2:	68 54 2c 80 00       	push   $0x802c54
  8010c7:	6a 4e                	push   $0x4e
  8010c9:	68 9f 2c 80 00       	push   $0x802c9f
  8010ce:	e8 57 13 00 00       	call   80242a <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	6a 05                	push   $0x5
  8010d8:	56                   	push   %esi
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 7d fb ff ff       	call   800c5f <sys_page_map>
  8010e2:	83 c4 20             	add    $0x20,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	79 12                	jns    8010fb <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  8010e9:	50                   	push   %eax
  8010ea:	68 7c 2c 80 00       	push   $0x802c7c
  8010ef:	6a 50                	push   $0x50
  8010f1:	68 9f 2c 80 00       	push   $0x802c9f
  8010f6:	e8 2f 13 00 00       	call   80242a <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8010fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801101:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801107:	0f 85 e7 fe ff ff    	jne    800ff4 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	6a 07                	push   $0x7
  801112:	68 00 f0 bf ee       	push   $0xeebff000
  801117:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111a:	e8 fd fa ff ff       	call   800c1c <sys_page_alloc>
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	79 14                	jns    80113a <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	68 e4 2c 80 00       	push   $0x802ce4
  80112e:	6a 76                	push   $0x76
  801130:	68 9f 2c 80 00       	push   $0x802c9f
  801135:	e8 f0 12 00 00       	call   80242a <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	68 df 24 80 00       	push   $0x8024df
  801142:	ff 75 e4             	pushl  -0x1c(%ebp)
  801145:	e8 1d fc ff ff       	call   800d67 <sys_env_set_pgfault_upcall>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 14                	jns    801165 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801151:	ff 75 e4             	pushl  -0x1c(%ebp)
  801154:	68 fe 2c 80 00       	push   $0x802cfe
  801159:	6a 79                	push   $0x79
  80115b:	68 9f 2c 80 00       	push   $0x802c9f
  801160:	e8 c5 12 00 00       	call   80242a <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	6a 02                	push   $0x2
  80116a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116d:	e8 71 fb ff ff       	call   800ce3 <sys_env_set_status>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	79 14                	jns    80118d <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801179:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117c:	68 1b 2d 80 00       	push   $0x802d1b
  801181:	6a 7b                	push   $0x7b
  801183:	68 9f 2c 80 00       	push   $0x802c9f
  801188:	e8 9d 12 00 00       	call   80242a <_panic>
        return forkid;
  80118d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sfork>:

// Challenge!
int
sfork(void)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80119e:	68 32 2d 80 00       	push   $0x802d32
  8011a3:	68 83 00 00 00       	push   $0x83
  8011a8:	68 9f 2c 80 00       	push   $0x802c9f
  8011ad:	e8 78 12 00 00       	call   80242a <_panic>

008011b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011c7:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	50                   	push   %eax
  8011ce:	e8 f9 fb ff ff       	call   800dcc <sys_ipc_recv>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	79 16                	jns    8011f0 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8011da:	85 f6                	test   %esi,%esi
  8011dc:	74 06                	je     8011e4 <ipc_recv+0x32>
  8011de:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8011e4:	85 db                	test   %ebx,%ebx
  8011e6:	74 2c                	je     801214 <ipc_recv+0x62>
  8011e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011ee:	eb 24                	jmp    801214 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011f0:	85 f6                	test   %esi,%esi
  8011f2:	74 0a                	je     8011fe <ipc_recv+0x4c>
  8011f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f9:	8b 40 74             	mov    0x74(%eax),%eax
  8011fc:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8011fe:	85 db                	test   %ebx,%ebx
  801200:	74 0a                	je     80120c <ipc_recv+0x5a>
  801202:	a1 08 40 80 00       	mov    0x804008,%eax
  801207:	8b 40 78             	mov    0x78(%eax),%eax
  80120a:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80120c:	a1 08 40 80 00       	mov    0x804008,%eax
  801211:	8b 40 70             	mov    0x70(%eax),%eax
}
  801214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	8b 7d 08             	mov    0x8(%ebp),%edi
  801227:	8b 75 0c             	mov    0xc(%ebp),%esi
  80122a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80122d:	85 db                	test   %ebx,%ebx
  80122f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801234:	0f 44 d8             	cmove  %eax,%ebx
  801237:	eb 1c                	jmp    801255 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801239:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80123c:	74 12                	je     801250 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80123e:	50                   	push   %eax
  80123f:	68 48 2d 80 00       	push   $0x802d48
  801244:	6a 39                	push   $0x39
  801246:	68 63 2d 80 00       	push   $0x802d63
  80124b:	e8 da 11 00 00       	call   80242a <_panic>
                 sys_yield();
  801250:	e8 a8 f9 ff ff       	call   800bfd <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801255:	ff 75 14             	pushl  0x14(%ebp)
  801258:	53                   	push   %ebx
  801259:	56                   	push   %esi
  80125a:	57                   	push   %edi
  80125b:	e8 49 fb ff ff       	call   800da9 <sys_ipc_try_send>
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 d2                	js     801239 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80127a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801283:	8b 52 50             	mov    0x50(%edx),%edx
  801286:	39 ca                	cmp    %ecx,%edx
  801288:	75 0d                	jne    801297 <ipc_find_env+0x28>
			return envs[i].env_id;
  80128a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801292:	8b 40 08             	mov    0x8(%eax),%eax
  801295:	eb 0e                	jmp    8012a5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801297:	83 c0 01             	add    $0x1,%eax
  80129a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80129f:	75 d9                	jne    80127a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012a1:	66 b8 00 00          	mov    $0x0,%ax
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	c1 ea 16             	shr    $0x16,%edx
  8012de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e5:	f6 c2 01             	test   $0x1,%dl
  8012e8:	74 11                	je     8012fb <fd_alloc+0x2d>
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 0c             	shr    $0xc,%edx
  8012ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	75 09                	jne    801304 <fd_alloc+0x36>
			*fd_store = fd;
  8012fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	eb 17                	jmp    80131b <fd_alloc+0x4d>
  801304:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801309:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130e:	75 c9                	jne    8012d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801310:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801316:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801323:	83 f8 1f             	cmp    $0x1f,%eax
  801326:	77 36                	ja     80135e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801328:	c1 e0 0c             	shl    $0xc,%eax
  80132b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801330:	89 c2                	mov    %eax,%edx
  801332:	c1 ea 16             	shr    $0x16,%edx
  801335:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133c:	f6 c2 01             	test   $0x1,%dl
  80133f:	74 24                	je     801365 <fd_lookup+0x48>
  801341:	89 c2                	mov    %eax,%edx
  801343:	c1 ea 0c             	shr    $0xc,%edx
  801346:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134d:	f6 c2 01             	test   $0x1,%dl
  801350:	74 1a                	je     80136c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801352:	8b 55 0c             	mov    0xc(%ebp),%edx
  801355:	89 02                	mov    %eax,(%edx)
	return 0;
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	eb 13                	jmp    801371 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801363:	eb 0c                	jmp    801371 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136a:	eb 05                	jmp    801371 <fd_lookup+0x54>
  80136c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80137c:	ba 00 00 00 00       	mov    $0x0,%edx
  801381:	eb 13                	jmp    801396 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801383:	39 08                	cmp    %ecx,(%eax)
  801385:	75 0c                	jne    801393 <dev_lookup+0x20>
			*dev = devtab[i];
  801387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
  801391:	eb 36                	jmp    8013c9 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801393:	83 c2 01             	add    $0x1,%edx
  801396:	8b 04 95 ec 2d 80 00 	mov    0x802dec(,%edx,4),%eax
  80139d:	85 c0                	test   %eax,%eax
  80139f:	75 e2                	jne    801383 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a6:	8b 40 48             	mov    0x48(%eax),%eax
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	51                   	push   %ecx
  8013ad:	50                   	push   %eax
  8013ae:	68 70 2d 80 00       	push   $0x802d70
  8013b3:	e8 d4 ee ff ff       	call   80028c <cprintf>
	*dev = 0;
  8013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 10             	sub    $0x10,%esp
  8013d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013dc:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013dd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013e3:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e6:	50                   	push   %eax
  8013e7:	e8 31 ff ff ff       	call   80131d <fd_lookup>
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 05                	js     8013f8 <fd_close+0x2d>
	    || fd != fd2)
  8013f3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f6:	74 0c                	je     801404 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013f8:	84 db                	test   %bl,%bl
  8013fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ff:	0f 44 c2             	cmove  %edx,%eax
  801402:	eb 41                	jmp    801445 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	ff 36                	pushl  (%esi)
  80140d:	e8 61 ff ff ff       	call   801373 <dev_lookup>
  801412:	89 c3                	mov    %eax,%ebx
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 1a                	js     801435 <fd_close+0x6a>
		if (dev->dev_close)
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801421:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801426:	85 c0                	test   %eax,%eax
  801428:	74 0b                	je     801435 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	56                   	push   %esi
  80142e:	ff d0                	call   *%eax
  801430:	89 c3                	mov    %eax,%ebx
  801432:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	56                   	push   %esi
  801439:	6a 00                	push   $0x0
  80143b:	e8 61 f8 ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	89 d8                	mov    %ebx,%eax
}
  801445:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	ff 75 08             	pushl  0x8(%ebp)
  801459:	e8 bf fe ff ff       	call   80131d <fd_lookup>
  80145e:	89 c2                	mov    %eax,%edx
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 d2                	test   %edx,%edx
  801465:	78 10                	js     801477 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	6a 01                	push   $0x1
  80146c:	ff 75 f4             	pushl  -0xc(%ebp)
  80146f:	e8 57 ff ff ff       	call   8013cb <fd_close>
  801474:	83 c4 10             	add    $0x10,%esp
}
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <close_all>:

void
close_all(void)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	53                   	push   %ebx
  80147d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801480:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	53                   	push   %ebx
  801489:	e8 be ff ff ff       	call   80144c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148e:	83 c3 01             	add    $0x1,%ebx
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	83 fb 20             	cmp    $0x20,%ebx
  801497:	75 ec                	jne    801485 <close_all+0xc>
		close(i);
}
  801499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	57                   	push   %edi
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 2c             	sub    $0x2c,%esp
  8014a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	ff 75 08             	pushl  0x8(%ebp)
  8014b1:	e8 67 fe ff ff       	call   80131d <fd_lookup>
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	85 d2                	test   %edx,%edx
  8014bd:	0f 88 c1 00 00 00    	js     801584 <dup+0xe6>
		return r;
	close(newfdnum);
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	56                   	push   %esi
  8014c7:	e8 80 ff ff ff       	call   80144c <close>

	newfd = INDEX2FD(newfdnum);
  8014cc:	89 f3                	mov    %esi,%ebx
  8014ce:	c1 e3 0c             	shl    $0xc,%ebx
  8014d1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014d7:	83 c4 04             	add    $0x4,%esp
  8014da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014dd:	e8 d5 fd ff ff       	call   8012b7 <fd2data>
  8014e2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014e4:	89 1c 24             	mov    %ebx,(%esp)
  8014e7:	e8 cb fd ff ff       	call   8012b7 <fd2data>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f2:	89 f8                	mov    %edi,%eax
  8014f4:	c1 e8 16             	shr    $0x16,%eax
  8014f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fe:	a8 01                	test   $0x1,%al
  801500:	74 37                	je     801539 <dup+0x9b>
  801502:	89 f8                	mov    %edi,%eax
  801504:	c1 e8 0c             	shr    $0xc,%eax
  801507:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150e:	f6 c2 01             	test   $0x1,%dl
  801511:	74 26                	je     801539 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801513:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	25 07 0e 00 00       	and    $0xe07,%eax
  801522:	50                   	push   %eax
  801523:	ff 75 d4             	pushl  -0x2c(%ebp)
  801526:	6a 00                	push   $0x0
  801528:	57                   	push   %edi
  801529:	6a 00                	push   $0x0
  80152b:	e8 2f f7 ff ff       	call   800c5f <sys_page_map>
  801530:	89 c7                	mov    %eax,%edi
  801532:	83 c4 20             	add    $0x20,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 2e                	js     801567 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801539:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80153c:	89 d0                	mov    %edx,%eax
  80153e:	c1 e8 0c             	shr    $0xc,%eax
  801541:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	25 07 0e 00 00       	and    $0xe07,%eax
  801550:	50                   	push   %eax
  801551:	53                   	push   %ebx
  801552:	6a 00                	push   $0x0
  801554:	52                   	push   %edx
  801555:	6a 00                	push   $0x0
  801557:	e8 03 f7 ff ff       	call   800c5f <sys_page_map>
  80155c:	89 c7                	mov    %eax,%edi
  80155e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801561:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801563:	85 ff                	test   %edi,%edi
  801565:	79 1d                	jns    801584 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 00                	push   $0x0
  80156d:	e8 2f f7 ff ff       	call   800ca1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	ff 75 d4             	pushl  -0x2c(%ebp)
  801578:	6a 00                	push   $0x0
  80157a:	e8 22 f7 ff ff       	call   800ca1 <sys_page_unmap>
	return r;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	89 f8                	mov    %edi,%eax
}
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	53                   	push   %ebx
  80159b:	e8 7d fd ff ff       	call   80131d <fd_lookup>
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 6d                	js     801616 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b3:	ff 30                	pushl  (%eax)
  8015b5:	e8 b9 fd ff ff       	call   801373 <dev_lookup>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 4c                	js     80160d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015c4:	8b 42 08             	mov    0x8(%edx),%eax
  8015c7:	83 e0 03             	and    $0x3,%eax
  8015ca:	83 f8 01             	cmp    $0x1,%eax
  8015cd:	75 21                	jne    8015f0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d4:	8b 40 48             	mov    0x48(%eax),%eax
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	68 b1 2d 80 00       	push   $0x802db1
  8015e1:	e8 a6 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ee:	eb 26                	jmp    801616 <read+0x8a>
	}
	if (!dev->dev_read)
  8015f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f3:	8b 40 08             	mov    0x8(%eax),%eax
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 17                	je     801611 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	ff 75 10             	pushl  0x10(%ebp)
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	52                   	push   %edx
  801604:	ff d0                	call   *%eax
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 09                	jmp    801616 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	eb 05                	jmp    801616 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801611:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	57                   	push   %edi
  801621:	56                   	push   %esi
  801622:	53                   	push   %ebx
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	8b 7d 08             	mov    0x8(%ebp),%edi
  801629:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801631:	eb 21                	jmp    801654 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	89 f0                	mov    %esi,%eax
  801638:	29 d8                	sub    %ebx,%eax
  80163a:	50                   	push   %eax
  80163b:	89 d8                	mov    %ebx,%eax
  80163d:	03 45 0c             	add    0xc(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	57                   	push   %edi
  801642:	e8 45 ff ff ff       	call   80158c <read>
		if (m < 0)
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 0c                	js     80165a <readn+0x3d>
			return m;
		if (m == 0)
  80164e:	85 c0                	test   %eax,%eax
  801650:	74 06                	je     801658 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801652:	01 c3                	add    %eax,%ebx
  801654:	39 f3                	cmp    %esi,%ebx
  801656:	72 db                	jb     801633 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801658:	89 d8                	mov    %ebx,%eax
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	83 ec 14             	sub    $0x14,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	53                   	push   %ebx
  801671:	e8 a7 fc ff ff       	call   80131d <fd_lookup>
  801676:	83 c4 08             	add    $0x8,%esp
  801679:	89 c2                	mov    %eax,%edx
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 68                	js     8016e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	ff 30                	pushl  (%eax)
  80168b:	e8 e3 fc ff ff       	call   801373 <dev_lookup>
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 47                	js     8016de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169e:	75 21                	jne    8016c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8016a5:	8b 40 48             	mov    0x48(%eax),%eax
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	50                   	push   %eax
  8016ad:	68 cd 2d 80 00       	push   $0x802dcd
  8016b2:	e8 d5 eb ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bf:	eb 26                	jmp    8016e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c7:	85 d2                	test   %edx,%edx
  8016c9:	74 17                	je     8016e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	ff 75 10             	pushl  0x10(%ebp)
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	ff d2                	call   *%edx
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	eb 09                	jmp    8016e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	eb 05                	jmp    8016e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016e7:	89 d0                	mov    %edx,%eax
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 1d fc ff ff       	call   80131d <fd_lookup>
  801700:	83 c4 08             	add    $0x8,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 0e                	js     801715 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801707:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80170a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801710:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 14             	sub    $0x14,%esp
  80171e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801721:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	53                   	push   %ebx
  801726:	e8 f2 fb ff ff       	call   80131d <fd_lookup>
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	89 c2                	mov    %eax,%edx
  801730:	85 c0                	test   %eax,%eax
  801732:	78 65                	js     801799 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	ff 30                	pushl  (%eax)
  801740:	e8 2e fc ff ff       	call   801373 <dev_lookup>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 44                	js     801790 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801753:	75 21                	jne    801776 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801755:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175a:	8b 40 48             	mov    0x48(%eax),%eax
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	53                   	push   %ebx
  801761:	50                   	push   %eax
  801762:	68 90 2d 80 00       	push   $0x802d90
  801767:	e8 20 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801774:	eb 23                	jmp    801799 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801776:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801779:	8b 52 18             	mov    0x18(%edx),%edx
  80177c:	85 d2                	test   %edx,%edx
  80177e:	74 14                	je     801794 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	50                   	push   %eax
  801787:	ff d2                	call   *%edx
  801789:	89 c2                	mov    %eax,%edx
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	eb 09                	jmp    801799 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801790:	89 c2                	mov    %eax,%edx
  801792:	eb 05                	jmp    801799 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801794:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801799:	89 d0                	mov    %edx,%eax
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 14             	sub    $0x14,%esp
  8017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	ff 75 08             	pushl  0x8(%ebp)
  8017b1:	e8 67 fb ff ff       	call   80131d <fd_lookup>
  8017b6:	83 c4 08             	add    $0x8,%esp
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 58                	js     801817 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	ff 30                	pushl  (%eax)
  8017cb:	e8 a3 fb ff ff       	call   801373 <dev_lookup>
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 37                	js     80180e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017de:	74 32                	je     801812 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ea:	00 00 00 
	stat->st_isdir = 0;
  8017ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f4:	00 00 00 
	stat->st_dev = dev;
  8017f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	53                   	push   %ebx
  801801:	ff 75 f0             	pushl  -0x10(%ebp)
  801804:	ff 50 14             	call   *0x14(%eax)
  801807:	89 c2                	mov    %eax,%edx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	eb 09                	jmp    801817 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180e:	89 c2                	mov    %eax,%edx
  801810:	eb 05                	jmp    801817 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801812:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801817:	89 d0                	mov    %edx,%eax
  801819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	6a 00                	push   $0x0
  801828:	ff 75 08             	pushl  0x8(%ebp)
  80182b:	e8 09 02 00 00       	call   801a39 <open>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 db                	test   %ebx,%ebx
  801837:	78 1b                	js     801854 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	53                   	push   %ebx
  801840:	e8 5b ff ff ff       	call   8017a0 <fstat>
  801845:	89 c6                	mov    %eax,%esi
	close(fd);
  801847:	89 1c 24             	mov    %ebx,(%esp)
  80184a:	e8 fd fb ff ff       	call   80144c <close>
	return r;
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	89 f0                	mov    %esi,%eax
}
  801854:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	56                   	push   %esi
  80185f:	53                   	push   %ebx
  801860:	89 c6                	mov    %eax,%esi
  801862:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801864:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80186b:	75 12                	jne    80187f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	6a 01                	push   $0x1
  801872:	e8 f8 f9 ff ff       	call   80126f <ipc_find_env>
  801877:	a3 00 40 80 00       	mov    %eax,0x804000
  80187c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80187f:	6a 07                	push   $0x7
  801881:	68 00 50 80 00       	push   $0x805000
  801886:	56                   	push   %esi
  801887:	ff 35 00 40 80 00    	pushl  0x804000
  80188d:	e8 89 f9 ff ff       	call   80121b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801892:	83 c4 0c             	add    $0xc,%esp
  801895:	6a 00                	push   $0x0
  801897:	53                   	push   %ebx
  801898:	6a 00                	push   $0x0
  80189a:	e8 13 f9 ff ff       	call   8011b2 <ipc_recv>
}
  80189f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a2:	5b                   	pop    %ebx
  8018a3:	5e                   	pop    %esi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c9:	e8 8d ff ff ff       	call   80185b <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018eb:	e8 6b ff ff ff       	call   80185b <fsipc>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801902:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801907:	ba 00 00 00 00       	mov    $0x0,%edx
  80190c:	b8 05 00 00 00       	mov    $0x5,%eax
  801911:	e8 45 ff ff ff       	call   80185b <fsipc>
  801916:	89 c2                	mov    %eax,%edx
  801918:	85 d2                	test   %edx,%edx
  80191a:	78 2c                	js     801948 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	68 00 50 80 00       	push   $0x805000
  801924:	53                   	push   %ebx
  801925:	e8 e9 ee ff ff       	call   800813 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80192a:	a1 80 50 80 00       	mov    0x805080,%eax
  80192f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801935:	a1 84 50 80 00       	mov    0x805084,%eax
  80193a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801948:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	8b 40 0c             	mov    0xc(%eax),%eax
  80195f:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801967:	eb 3d                	jmp    8019a6 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801969:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80196f:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801974:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	57                   	push   %edi
  80197b:	53                   	push   %ebx
  80197c:	68 08 50 80 00       	push   $0x805008
  801981:	e8 1f f0 ff ff       	call   8009a5 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801986:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80198c:	ba 00 00 00 00       	mov    $0x0,%edx
  801991:	b8 04 00 00 00       	mov    $0x4,%eax
  801996:	e8 c0 fe ff ff       	call   80185b <fsipc>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 0d                	js     8019af <devfile_write+0x62>
		        return r;
                n -= tmp;
  8019a2:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8019a4:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8019a6:	85 f6                	test   %esi,%esi
  8019a8:	75 bf                	jne    801969 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8019aa:	89 d8                	mov    %ebx,%eax
  8019ac:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8019af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5f                   	pop    %edi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019ca:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8019da:	e8 7c fe ff ff       	call   80185b <fsipc>
  8019df:	89 c3                	mov    %eax,%ebx
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 4b                	js     801a30 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e5:	39 c6                	cmp    %eax,%esi
  8019e7:	73 16                	jae    8019ff <devfile_read+0x48>
  8019e9:	68 00 2e 80 00       	push   $0x802e00
  8019ee:	68 07 2e 80 00       	push   $0x802e07
  8019f3:	6a 7c                	push   $0x7c
  8019f5:	68 1c 2e 80 00       	push   $0x802e1c
  8019fa:	e8 2b 0a 00 00       	call   80242a <_panic>
	assert(r <= PGSIZE);
  8019ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a04:	7e 16                	jle    801a1c <devfile_read+0x65>
  801a06:	68 27 2e 80 00       	push   $0x802e27
  801a0b:	68 07 2e 80 00       	push   $0x802e07
  801a10:	6a 7d                	push   $0x7d
  801a12:	68 1c 2e 80 00       	push   $0x802e1c
  801a17:	e8 0e 0a 00 00       	call   80242a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a1c:	83 ec 04             	sub    $0x4,%esp
  801a1f:	50                   	push   %eax
  801a20:	68 00 50 80 00       	push   $0x805000
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	e8 78 ef ff ff       	call   8009a5 <memmove>
	return r;
  801a2d:	83 c4 10             	add    $0x10,%esp
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 20             	sub    $0x20,%esp
  801a40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a43:	53                   	push   %ebx
  801a44:	e8 91 ed ff ff       	call   8007da <strlen>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a51:	7f 67                	jg     801aba <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	e8 6f f8 ff ff       	call   8012ce <fd_alloc>
  801a5f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a62:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 57                	js     801abf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	53                   	push   %ebx
  801a6c:	68 00 50 80 00       	push   $0x805000
  801a71:	e8 9d ed ff ff       	call   800813 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a79:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a81:	b8 01 00 00 00       	mov    $0x1,%eax
  801a86:	e8 d0 fd ff ff       	call   80185b <fsipc>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	79 14                	jns    801aa8 <open+0x6f>
		fd_close(fd, 0);
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	6a 00                	push   $0x0
  801a99:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9c:	e8 2a f9 ff ff       	call   8013cb <fd_close>
		return r;
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	89 da                	mov    %ebx,%edx
  801aa6:	eb 17                	jmp    801abf <open+0x86>
	}

	return fd2num(fd);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	e8 f4 f7 ff ff       	call   8012a7 <fd2num>
  801ab3:	89 c2                	mov    %eax,%edx
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	eb 05                	jmp    801abf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801abf:	89 d0                	mov    %edx,%eax
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801acc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad6:	e8 80 fd ff ff       	call   80185b <fsipc>
}
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ae3:	68 33 2e 80 00       	push   $0x802e33
  801ae8:	ff 75 0c             	pushl  0xc(%ebp)
  801aeb:	e8 23 ed ff ff       	call   800813 <strcpy>
	return 0;
}
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	53                   	push   %ebx
  801afb:	83 ec 10             	sub    $0x10,%esp
  801afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b01:	53                   	push   %ebx
  801b02:	e8 fc 09 00 00       	call   802503 <pageref>
  801b07:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b0a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b0f:	83 f8 01             	cmp    $0x1,%eax
  801b12:	75 10                	jne    801b24 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	ff 73 0c             	pushl  0xc(%ebx)
  801b1a:	e8 ca 02 00 00       	call   801de9 <nsipc_close>
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b24:	89 d0                	mov    %edx,%eax
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b31:	6a 00                	push   $0x0
  801b33:	ff 75 10             	pushl  0x10(%ebp)
  801b36:	ff 75 0c             	pushl  0xc(%ebp)
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	ff 70 0c             	pushl  0xc(%eax)
  801b3f:	e8 82 03 00 00       	call   801ec6 <nsipc_send>
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b4c:	6a 00                	push   $0x0
  801b4e:	ff 75 10             	pushl  0x10(%ebp)
  801b51:	ff 75 0c             	pushl  0xc(%ebp)
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	ff 70 0c             	pushl  0xc(%eax)
  801b5a:	e8 fb 02 00 00       	call   801e5a <nsipc_recv>
}
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b67:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b6a:	52                   	push   %edx
  801b6b:	50                   	push   %eax
  801b6c:	e8 ac f7 ff ff       	call   80131d <fd_lookup>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 17                	js     801b8f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7b:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801b81:	39 08                	cmp    %ecx,(%eax)
  801b83:	75 05                	jne    801b8a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b85:	8b 40 0c             	mov    0xc(%eax),%eax
  801b88:	eb 05                	jmp    801b8f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b8a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 1c             	sub    $0x1c,%esp
  801b99:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9e:	50                   	push   %eax
  801b9f:	e8 2a f7 ff ff       	call   8012ce <fd_alloc>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 1b                	js     801bc8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	68 07 04 00 00       	push   $0x407
  801bb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 5d f0 ff ff       	call   800c1c <sys_page_alloc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	79 10                	jns    801bd8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	56                   	push   %esi
  801bcc:	e8 18 02 00 00       	call   801de9 <nsipc_close>
		return r;
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	eb 24                	jmp    801bfc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bd8:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be6:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801bed:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	52                   	push   %edx
  801bf4:	e8 ae f6 ff ff       	call   8012a7 <fd2num>
  801bf9:	83 c4 10             	add    $0x10,%esp
}
  801bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	e8 50 ff ff ff       	call   801b61 <fd2sockid>
		return r;
  801c11:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c13:	85 c0                	test   %eax,%eax
  801c15:	78 1f                	js     801c36 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	ff 75 10             	pushl  0x10(%ebp)
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	50                   	push   %eax
  801c21:	e8 1c 01 00 00       	call   801d42 <nsipc_accept>
  801c26:	83 c4 10             	add    $0x10,%esp
		return r;
  801c29:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	78 07                	js     801c36 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c2f:	e8 5d ff ff ff       	call   801b91 <alloc_sockfd>
  801c34:	89 c1                	mov    %eax,%ecx
}
  801c36:	89 c8                	mov    %ecx,%eax
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	e8 19 ff ff ff       	call   801b61 <fd2sockid>
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	85 d2                	test   %edx,%edx
  801c4c:	78 12                	js     801c60 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	ff 75 10             	pushl  0x10(%ebp)
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	52                   	push   %edx
  801c58:	e8 35 01 00 00       	call   801d92 <nsipc_bind>
  801c5d:	83 c4 10             	add    $0x10,%esp
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <shutdown>:

int
shutdown(int s, int how)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	e8 f1 fe ff ff       	call   801b61 <fd2sockid>
  801c70:	89 c2                	mov    %eax,%edx
  801c72:	85 d2                	test   %edx,%edx
  801c74:	78 0f                	js     801c85 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c76:	83 ec 08             	sub    $0x8,%esp
  801c79:	ff 75 0c             	pushl  0xc(%ebp)
  801c7c:	52                   	push   %edx
  801c7d:	e8 45 01 00 00       	call   801dc7 <nsipc_shutdown>
  801c82:	83 c4 10             	add    $0x10,%esp
}
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    

00801c87 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	e8 cc fe ff ff       	call   801b61 <fd2sockid>
  801c95:	89 c2                	mov    %eax,%edx
  801c97:	85 d2                	test   %edx,%edx
  801c99:	78 12                	js     801cad <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	ff 75 10             	pushl  0x10(%ebp)
  801ca1:	ff 75 0c             	pushl  0xc(%ebp)
  801ca4:	52                   	push   %edx
  801ca5:	e8 59 01 00 00       	call   801e03 <nsipc_connect>
  801caa:	83 c4 10             	add    $0x10,%esp
}
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <listen>:

int
listen(int s, int backlog)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	e8 a4 fe ff ff       	call   801b61 <fd2sockid>
  801cbd:	89 c2                	mov    %eax,%edx
  801cbf:	85 d2                	test   %edx,%edx
  801cc1:	78 0f                	js     801cd2 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801cc3:	83 ec 08             	sub    $0x8,%esp
  801cc6:	ff 75 0c             	pushl  0xc(%ebp)
  801cc9:	52                   	push   %edx
  801cca:	e8 69 01 00 00       	call   801e38 <nsipc_listen>
  801ccf:	83 c4 10             	add    $0x10,%esp
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cda:	ff 75 10             	pushl  0x10(%ebp)
  801cdd:	ff 75 0c             	pushl  0xc(%ebp)
  801ce0:	ff 75 08             	pushl  0x8(%ebp)
  801ce3:	e8 3c 02 00 00       	call   801f24 <nsipc_socket>
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 d2                	test   %edx,%edx
  801cef:	78 05                	js     801cf6 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801cf1:	e8 9b fe ff ff       	call   801b91 <alloc_sockfd>
}
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	53                   	push   %ebx
  801cfc:	83 ec 04             	sub    $0x4,%esp
  801cff:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d01:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d08:	75 12                	jne    801d1c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	6a 02                	push   $0x2
  801d0f:	e8 5b f5 ff ff       	call   80126f <ipc_find_env>
  801d14:	a3 04 40 80 00       	mov    %eax,0x804004
  801d19:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d1c:	6a 07                	push   $0x7
  801d1e:	68 00 60 80 00       	push   $0x806000
  801d23:	53                   	push   %ebx
  801d24:	ff 35 04 40 80 00    	pushl  0x804004
  801d2a:	e8 ec f4 ff ff       	call   80121b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d2f:	83 c4 0c             	add    $0xc,%esp
  801d32:	6a 00                	push   $0x0
  801d34:	6a 00                	push   $0x0
  801d36:	6a 00                	push   $0x0
  801d38:	e8 75 f4 ff ff       	call   8011b2 <ipc_recv>
}
  801d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d52:	8b 06                	mov    (%esi),%eax
  801d54:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d59:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5e:	e8 95 ff ff ff       	call   801cf8 <nsipc>
  801d63:	89 c3                	mov    %eax,%ebx
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 20                	js     801d89 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	ff 35 10 60 80 00    	pushl  0x806010
  801d72:	68 00 60 80 00       	push   $0x806000
  801d77:	ff 75 0c             	pushl  0xc(%ebp)
  801d7a:	e8 26 ec ff ff       	call   8009a5 <memmove>
		*addrlen = ret->ret_addrlen;
  801d7f:	a1 10 60 80 00       	mov    0x806010,%eax
  801d84:	89 06                	mov    %eax,(%esi)
  801d86:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d89:	89 d8                	mov    %ebx,%eax
  801d8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	53                   	push   %ebx
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801da4:	53                   	push   %ebx
  801da5:	ff 75 0c             	pushl  0xc(%ebp)
  801da8:	68 04 60 80 00       	push   $0x806004
  801dad:	e8 f3 eb ff ff       	call   8009a5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801db2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801db8:	b8 02 00 00 00       	mov    $0x2,%eax
  801dbd:	e8 36 ff ff ff       	call   801cf8 <nsipc>
}
  801dc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ddd:	b8 03 00 00 00       	mov    $0x3,%eax
  801de2:	e8 11 ff ff ff       	call   801cf8 <nsipc>
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <nsipc_close>:

int
nsipc_close(int s)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801df7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dfc:	e8 f7 fe ff ff       	call   801cf8 <nsipc>
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	53                   	push   %ebx
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e10:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e15:	53                   	push   %ebx
  801e16:	ff 75 0c             	pushl  0xc(%ebp)
  801e19:	68 04 60 80 00       	push   $0x806004
  801e1e:	e8 82 eb ff ff       	call   8009a5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e23:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e29:	b8 05 00 00 00       	mov    $0x5,%eax
  801e2e:	e8 c5 fe ff ff       	call   801cf8 <nsipc>
}
  801e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e4e:	b8 06 00 00 00       	mov    $0x6,%eax
  801e53:	e8 a0 fe ff ff       	call   801cf8 <nsipc>
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e62:	8b 45 08             	mov    0x8(%ebp),%eax
  801e65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e6a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e70:	8b 45 14             	mov    0x14(%ebp),%eax
  801e73:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e78:	b8 07 00 00 00       	mov    $0x7,%eax
  801e7d:	e8 76 fe ff ff       	call   801cf8 <nsipc>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 35                	js     801ebd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e88:	39 f0                	cmp    %esi,%eax
  801e8a:	7f 07                	jg     801e93 <nsipc_recv+0x39>
  801e8c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e91:	7e 16                	jle    801ea9 <nsipc_recv+0x4f>
  801e93:	68 3f 2e 80 00       	push   $0x802e3f
  801e98:	68 07 2e 80 00       	push   $0x802e07
  801e9d:	6a 62                	push   $0x62
  801e9f:	68 54 2e 80 00       	push   $0x802e54
  801ea4:	e8 81 05 00 00       	call   80242a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ea9:	83 ec 04             	sub    $0x4,%esp
  801eac:	50                   	push   %eax
  801ead:	68 00 60 80 00       	push   $0x806000
  801eb2:	ff 75 0c             	pushl  0xc(%ebp)
  801eb5:	e8 eb ea ff ff       	call   8009a5 <memmove>
  801eba:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ebd:	89 d8                	mov    %ebx,%eax
  801ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5e                   	pop    %esi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 04             	sub    $0x4,%esp
  801ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ed8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ede:	7e 16                	jle    801ef6 <nsipc_send+0x30>
  801ee0:	68 60 2e 80 00       	push   $0x802e60
  801ee5:	68 07 2e 80 00       	push   $0x802e07
  801eea:	6a 6d                	push   $0x6d
  801eec:	68 54 2e 80 00       	push   $0x802e54
  801ef1:	e8 34 05 00 00       	call   80242a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ef6:	83 ec 04             	sub    $0x4,%esp
  801ef9:	53                   	push   %ebx
  801efa:	ff 75 0c             	pushl  0xc(%ebp)
  801efd:	68 0c 60 80 00       	push   $0x80600c
  801f02:	e8 9e ea ff ff       	call   8009a5 <memmove>
	nsipcbuf.send.req_size = size;
  801f07:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f10:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f15:	b8 08 00 00 00       	mov    $0x8,%eax
  801f1a:	e8 d9 fd ff ff       	call   801cf8 <nsipc>
}
  801f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f35:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f3d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f42:	b8 09 00 00 00       	mov    $0x9,%eax
  801f47:	e8 ac fd ff ff       	call   801cf8 <nsipc>
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	ff 75 08             	pushl  0x8(%ebp)
  801f5c:	e8 56 f3 ff ff       	call   8012b7 <fd2data>
  801f61:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f63:	83 c4 08             	add    $0x8,%esp
  801f66:	68 6c 2e 80 00       	push   $0x802e6c
  801f6b:	53                   	push   %ebx
  801f6c:	e8 a2 e8 ff ff       	call   800813 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f71:	8b 56 04             	mov    0x4(%esi),%edx
  801f74:	89 d0                	mov    %edx,%eax
  801f76:	2b 06                	sub    (%esi),%eax
  801f78:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f7e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f85:	00 00 00 
	stat->st_dev = &devpipe;
  801f88:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801f8f:	30 80 00 
	return 0;
}
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
  801f97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	53                   	push   %ebx
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fa8:	53                   	push   %ebx
  801fa9:	6a 00                	push   $0x0
  801fab:	e8 f1 ec ff ff       	call   800ca1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fb0:	89 1c 24             	mov    %ebx,(%esp)
  801fb3:	e8 ff f2 ff ff       	call   8012b7 <fd2data>
  801fb8:	83 c4 08             	add    $0x8,%esp
  801fbb:	50                   	push   %eax
  801fbc:	6a 00                	push   $0x0
  801fbe:	e8 de ec ff ff       	call   800ca1 <sys_page_unmap>
}
  801fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	57                   	push   %edi
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 1c             	sub    $0x1c,%esp
  801fd1:	89 c6                	mov    %eax,%esi
  801fd3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fd6:	a1 08 40 80 00       	mov    0x804008,%eax
  801fdb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fde:	83 ec 0c             	sub    $0xc,%esp
  801fe1:	56                   	push   %esi
  801fe2:	e8 1c 05 00 00       	call   802503 <pageref>
  801fe7:	89 c7                	mov    %eax,%edi
  801fe9:	83 c4 04             	add    $0x4,%esp
  801fec:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fef:	e8 0f 05 00 00       	call   802503 <pageref>
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	39 c7                	cmp    %eax,%edi
  801ff9:	0f 94 c2             	sete   %dl
  801ffc:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fff:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  802005:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802008:	39 fb                	cmp    %edi,%ebx
  80200a:	74 19                	je     802025 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80200c:	84 d2                	test   %dl,%dl
  80200e:	74 c6                	je     801fd6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802010:	8b 51 58             	mov    0x58(%ecx),%edx
  802013:	50                   	push   %eax
  802014:	52                   	push   %edx
  802015:	53                   	push   %ebx
  802016:	68 73 2e 80 00       	push   $0x802e73
  80201b:	e8 6c e2 ff ff       	call   80028c <cprintf>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	eb b1                	jmp    801fd6 <_pipeisclosed+0xe>
	}
}
  802025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	57                   	push   %edi
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
  802033:	83 ec 28             	sub    $0x28,%esp
  802036:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802039:	56                   	push   %esi
  80203a:	e8 78 f2 ff ff       	call   8012b7 <fd2data>
  80203f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	bf 00 00 00 00       	mov    $0x0,%edi
  802049:	eb 4b                	jmp    802096 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80204b:	89 da                	mov    %ebx,%edx
  80204d:	89 f0                	mov    %esi,%eax
  80204f:	e8 74 ff ff ff       	call   801fc8 <_pipeisclosed>
  802054:	85 c0                	test   %eax,%eax
  802056:	75 48                	jne    8020a0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802058:	e8 a0 eb ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80205d:	8b 43 04             	mov    0x4(%ebx),%eax
  802060:	8b 0b                	mov    (%ebx),%ecx
  802062:	8d 51 20             	lea    0x20(%ecx),%edx
  802065:	39 d0                	cmp    %edx,%eax
  802067:	73 e2                	jae    80204b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802070:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802073:	89 c2                	mov    %eax,%edx
  802075:	c1 fa 1f             	sar    $0x1f,%edx
  802078:	89 d1                	mov    %edx,%ecx
  80207a:	c1 e9 1b             	shr    $0x1b,%ecx
  80207d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802080:	83 e2 1f             	and    $0x1f,%edx
  802083:	29 ca                	sub    %ecx,%edx
  802085:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802089:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80208d:	83 c0 01             	add    $0x1,%eax
  802090:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802093:	83 c7 01             	add    $0x1,%edi
  802096:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802099:	75 c2                	jne    80205d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80209b:	8b 45 10             	mov    0x10(%ebp),%eax
  80209e:	eb 05                	jmp    8020a5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020a0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5f                   	pop    %edi
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    

008020ad <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	57                   	push   %edi
  8020b1:	56                   	push   %esi
  8020b2:	53                   	push   %ebx
  8020b3:	83 ec 18             	sub    $0x18,%esp
  8020b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020b9:	57                   	push   %edi
  8020ba:	e8 f8 f1 ff ff       	call   8012b7 <fd2data>
  8020bf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c9:	eb 3d                	jmp    802108 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020cb:	85 db                	test   %ebx,%ebx
  8020cd:	74 04                	je     8020d3 <devpipe_read+0x26>
				return i;
  8020cf:	89 d8                	mov    %ebx,%eax
  8020d1:	eb 44                	jmp    802117 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020d3:	89 f2                	mov    %esi,%edx
  8020d5:	89 f8                	mov    %edi,%eax
  8020d7:	e8 ec fe ff ff       	call   801fc8 <_pipeisclosed>
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	75 32                	jne    802112 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020e0:	e8 18 eb ff ff       	call   800bfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020e5:	8b 06                	mov    (%esi),%eax
  8020e7:	3b 46 04             	cmp    0x4(%esi),%eax
  8020ea:	74 df                	je     8020cb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ec:	99                   	cltd   
  8020ed:	c1 ea 1b             	shr    $0x1b,%edx
  8020f0:	01 d0                	add    %edx,%eax
  8020f2:	83 e0 1f             	and    $0x1f,%eax
  8020f5:	29 d0                	sub    %edx,%eax
  8020f7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ff:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802102:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802105:	83 c3 01             	add    $0x1,%ebx
  802108:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80210b:	75 d8                	jne    8020e5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80210d:	8b 45 10             	mov    0x10(%ebp),%eax
  802110:	eb 05                	jmp    802117 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211a:	5b                   	pop    %ebx
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212a:	50                   	push   %eax
  80212b:	e8 9e f1 ff ff       	call   8012ce <fd_alloc>
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	89 c2                	mov    %eax,%edx
  802135:	85 c0                	test   %eax,%eax
  802137:	0f 88 2c 01 00 00    	js     802269 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213d:	83 ec 04             	sub    $0x4,%esp
  802140:	68 07 04 00 00       	push   $0x407
  802145:	ff 75 f4             	pushl  -0xc(%ebp)
  802148:	6a 00                	push   $0x0
  80214a:	e8 cd ea ff ff       	call   800c1c <sys_page_alloc>
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	89 c2                	mov    %eax,%edx
  802154:	85 c0                	test   %eax,%eax
  802156:	0f 88 0d 01 00 00    	js     802269 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80215c:	83 ec 0c             	sub    $0xc,%esp
  80215f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802162:	50                   	push   %eax
  802163:	e8 66 f1 ff ff       	call   8012ce <fd_alloc>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	0f 88 e2 00 00 00    	js     802257 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802175:	83 ec 04             	sub    $0x4,%esp
  802178:	68 07 04 00 00       	push   $0x407
  80217d:	ff 75 f0             	pushl  -0x10(%ebp)
  802180:	6a 00                	push   $0x0
  802182:	e8 95 ea ff ff       	call   800c1c <sys_page_alloc>
  802187:	89 c3                	mov    %eax,%ebx
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	85 c0                	test   %eax,%eax
  80218e:	0f 88 c3 00 00 00    	js     802257 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802194:	83 ec 0c             	sub    $0xc,%esp
  802197:	ff 75 f4             	pushl  -0xc(%ebp)
  80219a:	e8 18 f1 ff ff       	call   8012b7 <fd2data>
  80219f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a1:	83 c4 0c             	add    $0xc,%esp
  8021a4:	68 07 04 00 00       	push   $0x407
  8021a9:	50                   	push   %eax
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 6b ea ff ff       	call   800c1c <sys_page_alloc>
  8021b1:	89 c3                	mov    %eax,%ebx
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	0f 88 89 00 00 00    	js     802247 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c4:	e8 ee f0 ff ff       	call   8012b7 <fd2data>
  8021c9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021d0:	50                   	push   %eax
  8021d1:	6a 00                	push   $0x0
  8021d3:	56                   	push   %esi
  8021d4:	6a 00                	push   $0x0
  8021d6:	e8 84 ea ff ff       	call   800c5f <sys_page_map>
  8021db:	89 c3                	mov    %eax,%ebx
  8021dd:	83 c4 20             	add    $0x20,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 55                	js     802239 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021e4:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8021ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021f9:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8021ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802202:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802207:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	ff 75 f4             	pushl  -0xc(%ebp)
  802214:	e8 8e f0 ff ff       	call   8012a7 <fd2num>
  802219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80221c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80221e:	83 c4 04             	add    $0x4,%esp
  802221:	ff 75 f0             	pushl  -0x10(%ebp)
  802224:	e8 7e f0 ff ff       	call   8012a7 <fd2num>
  802229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	ba 00 00 00 00       	mov    $0x0,%edx
  802237:	eb 30                	jmp    802269 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802239:	83 ec 08             	sub    $0x8,%esp
  80223c:	56                   	push   %esi
  80223d:	6a 00                	push   $0x0
  80223f:	e8 5d ea ff ff       	call   800ca1 <sys_page_unmap>
  802244:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802247:	83 ec 08             	sub    $0x8,%esp
  80224a:	ff 75 f0             	pushl  -0x10(%ebp)
  80224d:	6a 00                	push   $0x0
  80224f:	e8 4d ea ff ff       	call   800ca1 <sys_page_unmap>
  802254:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802257:	83 ec 08             	sub    $0x8,%esp
  80225a:	ff 75 f4             	pushl  -0xc(%ebp)
  80225d:	6a 00                	push   $0x0
  80225f:	e8 3d ea ff ff       	call   800ca1 <sys_page_unmap>
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802269:	89 d0                	mov    %edx,%eax
  80226b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226e:	5b                   	pop    %ebx
  80226f:	5e                   	pop    %esi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227b:	50                   	push   %eax
  80227c:	ff 75 08             	pushl  0x8(%ebp)
  80227f:	e8 99 f0 ff ff       	call   80131d <fd_lookup>
  802284:	89 c2                	mov    %eax,%edx
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	85 d2                	test   %edx,%edx
  80228b:	78 18                	js     8022a5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80228d:	83 ec 0c             	sub    $0xc,%esp
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	e8 1f f0 ff ff       	call   8012b7 <fd2data>
	return _pipeisclosed(fd, p);
  802298:	89 c2                	mov    %eax,%edx
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	e8 26 fd ff ff       	call   801fc8 <_pipeisclosed>
  8022a2:	83 c4 10             	add    $0x10,%esp
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    

008022b1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022b7:	68 8b 2e 80 00       	push   $0x802e8b
  8022bc:	ff 75 0c             	pushl  0xc(%ebp)
  8022bf:	e8 4f e5 ff ff       	call   800813 <strcpy>
	return 0;
}
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	57                   	push   %edi
  8022cf:	56                   	push   %esi
  8022d0:	53                   	push   %ebx
  8022d1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022dc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e2:	eb 2d                	jmp    802311 <devcons_write+0x46>
		m = n - tot;
  8022e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022e7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022e9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022f1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f4:	83 ec 04             	sub    $0x4,%esp
  8022f7:	53                   	push   %ebx
  8022f8:	03 45 0c             	add    0xc(%ebp),%eax
  8022fb:	50                   	push   %eax
  8022fc:	57                   	push   %edi
  8022fd:	e8 a3 e6 ff ff       	call   8009a5 <memmove>
		sys_cputs(buf, m);
  802302:	83 c4 08             	add    $0x8,%esp
  802305:	53                   	push   %ebx
  802306:	57                   	push   %edi
  802307:	e8 54 e8 ff ff       	call   800b60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230c:	01 de                	add    %ebx,%esi
  80230e:	83 c4 10             	add    $0x10,%esp
  802311:	89 f0                	mov    %esi,%eax
  802313:	3b 75 10             	cmp    0x10(%ebp),%esi
  802316:	72 cc                	jb     8022e4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80231b:	5b                   	pop    %ebx
  80231c:	5e                   	pop    %esi
  80231d:	5f                   	pop    %edi
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802326:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232f:	75 07                	jne    802338 <devcons_read+0x18>
  802331:	eb 28                	jmp    80235b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802333:	e8 c5 e8 ff ff       	call   800bfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802338:	e8 41 e8 ff ff       	call   800b7e <sys_cgetc>
  80233d:	85 c0                	test   %eax,%eax
  80233f:	74 f2                	je     802333 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802341:	85 c0                	test   %eax,%eax
  802343:	78 16                	js     80235b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802345:	83 f8 04             	cmp    $0x4,%eax
  802348:	74 0c                	je     802356 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80234a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80234d:	88 02                	mov    %al,(%edx)
	return 1;
  80234f:	b8 01 00 00 00       	mov    $0x1,%eax
  802354:	eb 05                	jmp    80235b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802363:	8b 45 08             	mov    0x8(%ebp),%eax
  802366:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802369:	6a 01                	push   $0x1
  80236b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236e:	50                   	push   %eax
  80236f:	e8 ec e7 ff ff       	call   800b60 <sys_cputs>
  802374:	83 c4 10             	add    $0x10,%esp
}
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <getchar>:

int
getchar(void)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80237f:	6a 01                	push   $0x1
  802381:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802384:	50                   	push   %eax
  802385:	6a 00                	push   $0x0
  802387:	e8 00 f2 ff ff       	call   80158c <read>
	if (r < 0)
  80238c:	83 c4 10             	add    $0x10,%esp
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 0f                	js     8023a2 <getchar+0x29>
		return r;
	if (r < 1)
  802393:	85 c0                	test   %eax,%eax
  802395:	7e 06                	jle    80239d <getchar+0x24>
		return -E_EOF;
	return c;
  802397:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80239b:	eb 05                	jmp    8023a2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80239d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023a2:	c9                   	leave  
  8023a3:	c3                   	ret    

008023a4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ad:	50                   	push   %eax
  8023ae:	ff 75 08             	pushl  0x8(%ebp)
  8023b1:	e8 67 ef ff ff       	call   80131d <fd_lookup>
  8023b6:	83 c4 10             	add    $0x10,%esp
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	78 11                	js     8023ce <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c0:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8023c6:	39 10                	cmp    %edx,(%eax)
  8023c8:	0f 94 c0             	sete   %al
  8023cb:	0f b6 c0             	movzbl %al,%eax
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <opencons>:

int
opencons(void)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d9:	50                   	push   %eax
  8023da:	e8 ef ee ff ff       	call   8012ce <fd_alloc>
  8023df:	83 c4 10             	add    $0x10,%esp
		return r;
  8023e2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	78 3e                	js     802426 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e8:	83 ec 04             	sub    $0x4,%esp
  8023eb:	68 07 04 00 00       	push   $0x407
  8023f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 22 e8 ff ff       	call   800c1c <sys_page_alloc>
  8023fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 23                	js     802426 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802403:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802411:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802418:	83 ec 0c             	sub    $0xc,%esp
  80241b:	50                   	push   %eax
  80241c:	e8 86 ee ff ff       	call   8012a7 <fd2num>
  802421:	89 c2                	mov    %eax,%edx
  802423:	83 c4 10             	add    $0x10,%esp
}
  802426:	89 d0                	mov    %edx,%eax
  802428:	c9                   	leave  
  802429:	c3                   	ret    

0080242a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	56                   	push   %esi
  80242e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80242f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802432:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802438:	e8 a1 e7 ff ff       	call   800bde <sys_getenvid>
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	ff 75 0c             	pushl  0xc(%ebp)
  802443:	ff 75 08             	pushl  0x8(%ebp)
  802446:	56                   	push   %esi
  802447:	50                   	push   %eax
  802448:	68 98 2e 80 00       	push   $0x802e98
  80244d:	e8 3a de ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802452:	83 c4 18             	add    $0x18,%esp
  802455:	53                   	push   %ebx
  802456:	ff 75 10             	pushl  0x10(%ebp)
  802459:	e8 dd dd ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  80245e:	c7 04 24 19 2d 80 00 	movl   $0x802d19,(%esp)
  802465:	e8 22 de ff ff       	call   80028c <cprintf>
  80246a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80246d:	cc                   	int3   
  80246e:	eb fd                	jmp    80246d <_panic+0x43>

00802470 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802476:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80247d:	75 2c                	jne    8024ab <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80247f:	83 ec 04             	sub    $0x4,%esp
  802482:	6a 07                	push   $0x7
  802484:	68 00 f0 bf ee       	push   $0xeebff000
  802489:	6a 00                	push   $0x0
  80248b:	e8 8c e7 ff ff       	call   800c1c <sys_page_alloc>
  802490:	83 c4 10             	add    $0x10,%esp
  802493:	85 c0                	test   %eax,%eax
  802495:	74 14                	je     8024ab <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802497:	83 ec 04             	sub    $0x4,%esp
  80249a:	68 bc 2e 80 00       	push   $0x802ebc
  80249f:	6a 21                	push   $0x21
  8024a1:	68 20 2f 80 00       	push   $0x802f20
  8024a6:	e8 7f ff ff ff       	call   80242a <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8024b3:	83 ec 08             	sub    $0x8,%esp
  8024b6:	68 df 24 80 00       	push   $0x8024df
  8024bb:	6a 00                	push   $0x0
  8024bd:	e8 a5 e8 ff ff       	call   800d67 <sys_env_set_pgfault_upcall>
  8024c2:	83 c4 10             	add    $0x10,%esp
  8024c5:	85 c0                	test   %eax,%eax
  8024c7:	79 14                	jns    8024dd <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8024c9:	83 ec 04             	sub    $0x4,%esp
  8024cc:	68 e8 2e 80 00       	push   $0x802ee8
  8024d1:	6a 29                	push   $0x29
  8024d3:	68 20 2f 80 00       	push   $0x802f20
  8024d8:	e8 4d ff ff ff       	call   80242a <_panic>
}
  8024dd:	c9                   	leave  
  8024de:	c3                   	ret    

008024df <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024df:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024e0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024e5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024e7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8024ea:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8024ef:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8024f3:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8024f7:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8024f9:	83 c4 08             	add    $0x8,%esp
        popal
  8024fc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8024fd:	83 c4 04             	add    $0x4,%esp
        popfl
  802500:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802501:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802502:	c3                   	ret    

00802503 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802509:	89 d0                	mov    %edx,%eax
  80250b:	c1 e8 16             	shr    $0x16,%eax
  80250e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802515:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80251a:	f6 c1 01             	test   $0x1,%cl
  80251d:	74 1d                	je     80253c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80251f:	c1 ea 0c             	shr    $0xc,%edx
  802522:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802529:	f6 c2 01             	test   $0x1,%dl
  80252c:	74 0e                	je     80253c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80252e:	c1 ea 0c             	shr    $0xc,%edx
  802531:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802538:	ef 
  802539:	0f b7 c0             	movzwl %ax,%eax
}
  80253c:	5d                   	pop    %ebp
  80253d:	c3                   	ret    
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	83 ec 10             	sub    $0x10,%esp
  802546:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80254a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80254e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802552:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802556:	85 d2                	test   %edx,%edx
  802558:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80255c:	89 34 24             	mov    %esi,(%esp)
  80255f:	89 c8                	mov    %ecx,%eax
  802561:	75 35                	jne    802598 <__udivdi3+0x58>
  802563:	39 f1                	cmp    %esi,%ecx
  802565:	0f 87 bd 00 00 00    	ja     802628 <__udivdi3+0xe8>
  80256b:	85 c9                	test   %ecx,%ecx
  80256d:	89 cd                	mov    %ecx,%ebp
  80256f:	75 0b                	jne    80257c <__udivdi3+0x3c>
  802571:	b8 01 00 00 00       	mov    $0x1,%eax
  802576:	31 d2                	xor    %edx,%edx
  802578:	f7 f1                	div    %ecx
  80257a:	89 c5                	mov    %eax,%ebp
  80257c:	89 f0                	mov    %esi,%eax
  80257e:	31 d2                	xor    %edx,%edx
  802580:	f7 f5                	div    %ebp
  802582:	89 c6                	mov    %eax,%esi
  802584:	89 f8                	mov    %edi,%eax
  802586:	f7 f5                	div    %ebp
  802588:	89 f2                	mov    %esi,%edx
  80258a:	83 c4 10             	add    $0x10,%esp
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    
  802591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802598:	3b 14 24             	cmp    (%esp),%edx
  80259b:	77 7b                	ja     802618 <__udivdi3+0xd8>
  80259d:	0f bd f2             	bsr    %edx,%esi
  8025a0:	83 f6 1f             	xor    $0x1f,%esi
  8025a3:	0f 84 97 00 00 00    	je     802640 <__udivdi3+0x100>
  8025a9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8025ae:	89 d7                	mov    %edx,%edi
  8025b0:	89 f1                	mov    %esi,%ecx
  8025b2:	29 f5                	sub    %esi,%ebp
  8025b4:	d3 e7                	shl    %cl,%edi
  8025b6:	89 c2                	mov    %eax,%edx
  8025b8:	89 e9                	mov    %ebp,%ecx
  8025ba:	d3 ea                	shr    %cl,%edx
  8025bc:	89 f1                	mov    %esi,%ecx
  8025be:	09 fa                	or     %edi,%edx
  8025c0:	8b 3c 24             	mov    (%esp),%edi
  8025c3:	d3 e0                	shl    %cl,%eax
  8025c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025d3:	89 fa                	mov    %edi,%edx
  8025d5:	d3 ea                	shr    %cl,%edx
  8025d7:	89 f1                	mov    %esi,%ecx
  8025d9:	d3 e7                	shl    %cl,%edi
  8025db:	89 e9                	mov    %ebp,%ecx
  8025dd:	d3 e8                	shr    %cl,%eax
  8025df:	09 c7                	or     %eax,%edi
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	f7 74 24 08          	divl   0x8(%esp)
  8025e7:	89 d5                	mov    %edx,%ebp
  8025e9:	89 c7                	mov    %eax,%edi
  8025eb:	f7 64 24 0c          	mull   0xc(%esp)
  8025ef:	39 d5                	cmp    %edx,%ebp
  8025f1:	89 14 24             	mov    %edx,(%esp)
  8025f4:	72 11                	jb     802607 <__udivdi3+0xc7>
  8025f6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025fa:	89 f1                	mov    %esi,%ecx
  8025fc:	d3 e2                	shl    %cl,%edx
  8025fe:	39 c2                	cmp    %eax,%edx
  802600:	73 5e                	jae    802660 <__udivdi3+0x120>
  802602:	3b 2c 24             	cmp    (%esp),%ebp
  802605:	75 59                	jne    802660 <__udivdi3+0x120>
  802607:	8d 47 ff             	lea    -0x1(%edi),%eax
  80260a:	31 f6                	xor    %esi,%esi
  80260c:	89 f2                	mov    %esi,%edx
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	31 f6                	xor    %esi,%esi
  80261a:	31 c0                	xor    %eax,%eax
  80261c:	89 f2                	mov    %esi,%edx
  80261e:	83 c4 10             	add    $0x10,%esp
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	89 f2                	mov    %esi,%edx
  80262a:	31 f6                	xor    %esi,%esi
  80262c:	89 f8                	mov    %edi,%eax
  80262e:	f7 f1                	div    %ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	83 c4 10             	add    $0x10,%esp
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802644:	76 0b                	jbe    802651 <__udivdi3+0x111>
  802646:	31 c0                	xor    %eax,%eax
  802648:	3b 14 24             	cmp    (%esp),%edx
  80264b:	0f 83 37 ff ff ff    	jae    802588 <__udivdi3+0x48>
  802651:	b8 01 00 00 00       	mov    $0x1,%eax
  802656:	e9 2d ff ff ff       	jmp    802588 <__udivdi3+0x48>
  80265b:	90                   	nop
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 f8                	mov    %edi,%eax
  802662:	31 f6                	xor    %esi,%esi
  802664:	e9 1f ff ff ff       	jmp    802588 <__udivdi3+0x48>
  802669:	66 90                	xchg   %ax,%ax
  80266b:	66 90                	xchg   %ax,%ax
  80266d:	66 90                	xchg   %ax,%ax
  80266f:	90                   	nop

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	83 ec 20             	sub    $0x20,%esp
  802676:	8b 44 24 34          	mov    0x34(%esp),%eax
  80267a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80267e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802682:	89 c6                	mov    %eax,%esi
  802684:	89 44 24 10          	mov    %eax,0x10(%esp)
  802688:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80268c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802690:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802694:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802698:	89 74 24 18          	mov    %esi,0x18(%esp)
  80269c:	85 c0                	test   %eax,%eax
  80269e:	89 c2                	mov    %eax,%edx
  8026a0:	75 1e                	jne    8026c0 <__umoddi3+0x50>
  8026a2:	39 f7                	cmp    %esi,%edi
  8026a4:	76 52                	jbe    8026f8 <__umoddi3+0x88>
  8026a6:	89 c8                	mov    %ecx,%eax
  8026a8:	89 f2                	mov    %esi,%edx
  8026aa:	f7 f7                	div    %edi
  8026ac:	89 d0                	mov    %edx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	83 c4 20             	add    $0x20,%esp
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    
  8026b7:	89 f6                	mov    %esi,%esi
  8026b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8026c0:	39 f0                	cmp    %esi,%eax
  8026c2:	77 5c                	ja     802720 <__umoddi3+0xb0>
  8026c4:	0f bd e8             	bsr    %eax,%ebp
  8026c7:	83 f5 1f             	xor    $0x1f,%ebp
  8026ca:	75 64                	jne    802730 <__umoddi3+0xc0>
  8026cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8026d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8026d4:	0f 86 f6 00 00 00    	jbe    8027d0 <__umoddi3+0x160>
  8026da:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8026de:	0f 82 ec 00 00 00    	jb     8027d0 <__umoddi3+0x160>
  8026e4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026e8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8026ec:	83 c4 20             	add    $0x20,%esp
  8026ef:	5e                   	pop    %esi
  8026f0:	5f                   	pop    %edi
  8026f1:	5d                   	pop    %ebp
  8026f2:	c3                   	ret    
  8026f3:	90                   	nop
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	85 ff                	test   %edi,%edi
  8026fa:	89 fd                	mov    %edi,%ebp
  8026fc:	75 0b                	jne    802709 <__umoddi3+0x99>
  8026fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802703:	31 d2                	xor    %edx,%edx
  802705:	f7 f7                	div    %edi
  802707:	89 c5                	mov    %eax,%ebp
  802709:	8b 44 24 10          	mov    0x10(%esp),%eax
  80270d:	31 d2                	xor    %edx,%edx
  80270f:	f7 f5                	div    %ebp
  802711:	89 c8                	mov    %ecx,%eax
  802713:	f7 f5                	div    %ebp
  802715:	eb 95                	jmp    8026ac <__umoddi3+0x3c>
  802717:	89 f6                	mov    %esi,%esi
  802719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 20             	add    $0x20,%esp
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    
  80272b:	90                   	nop
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	b8 20 00 00 00       	mov    $0x20,%eax
  802735:	89 e9                	mov    %ebp,%ecx
  802737:	29 e8                	sub    %ebp,%eax
  802739:	d3 e2                	shl    %cl,%edx
  80273b:	89 c7                	mov    %eax,%edi
  80273d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802741:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 c1                	mov    %eax,%ecx
  80274b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80274f:	09 d1                	or     %edx,%ecx
  802751:	89 fa                	mov    %edi,%edx
  802753:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802757:	89 e9                	mov    %ebp,%ecx
  802759:	d3 e0                	shl    %cl,%eax
  80275b:	89 f9                	mov    %edi,%ecx
  80275d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802761:	89 f0                	mov    %esi,%eax
  802763:	d3 e8                	shr    %cl,%eax
  802765:	89 e9                	mov    %ebp,%ecx
  802767:	89 c7                	mov    %eax,%edi
  802769:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80276d:	d3 e6                	shl    %cl,%esi
  80276f:	89 d1                	mov    %edx,%ecx
  802771:	89 fa                	mov    %edi,%edx
  802773:	d3 e8                	shr    %cl,%eax
  802775:	89 e9                	mov    %ebp,%ecx
  802777:	09 f0                	or     %esi,%eax
  802779:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80277d:	f7 74 24 10          	divl   0x10(%esp)
  802781:	d3 e6                	shl    %cl,%esi
  802783:	89 d1                	mov    %edx,%ecx
  802785:	f7 64 24 0c          	mull   0xc(%esp)
  802789:	39 d1                	cmp    %edx,%ecx
  80278b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80278f:	89 d7                	mov    %edx,%edi
  802791:	89 c6                	mov    %eax,%esi
  802793:	72 0a                	jb     80279f <__umoddi3+0x12f>
  802795:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802799:	73 10                	jae    8027ab <__umoddi3+0x13b>
  80279b:	39 d1                	cmp    %edx,%ecx
  80279d:	75 0c                	jne    8027ab <__umoddi3+0x13b>
  80279f:	89 d7                	mov    %edx,%edi
  8027a1:	89 c6                	mov    %eax,%esi
  8027a3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8027a7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8027ab:	89 ca                	mov    %ecx,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027b3:	29 f0                	sub    %esi,%eax
  8027b5:	19 fa                	sbb    %edi,%edx
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8027be:	89 d7                	mov    %edx,%edi
  8027c0:	d3 e7                	shl    %cl,%edi
  8027c2:	89 e9                	mov    %ebp,%ecx
  8027c4:	09 f8                	or     %edi,%eax
  8027c6:	d3 ea                	shr    %cl,%edx
  8027c8:	83 c4 20             	add    $0x20,%esp
  8027cb:	5e                   	pop    %esi
  8027cc:	5f                   	pop    %edi
  8027cd:	5d                   	pop    %ebp
  8027ce:	c3                   	ret    
  8027cf:	90                   	nop
  8027d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027d4:	29 f9                	sub    %edi,%ecx
  8027d6:	19 c6                	sbb    %eax,%esi
  8027d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8027dc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8027e0:	e9 ff fe ff ff       	jmp    8026e4 <__umoddi3+0x74>
