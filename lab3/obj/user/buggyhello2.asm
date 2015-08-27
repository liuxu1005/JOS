
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 60 00 00 00       	call   8000a9 <sys_cputs>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 c9 00 00 00       	call   800127 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 42 00 00 00       	call   8000e6 <sys_env_destroy>
  8000a4:	83 c4 10             	add    $0x10,%esp
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7e 17                	jle    80011f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	50                   	push   %eax
  80010c:	6a 03                	push   $0x3
  80010e:	68 d8 0d 80 00       	push   $0x800dd8
  800113:	6a 23                	push   $0x23
  800115:	68 f5 0d 80 00       	push   $0x800df5
  80011a:	e8 27 00 00 00       	call   800146 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014e:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800154:	e8 ce ff ff ff       	call   800127 <sys_getenvid>
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	56                   	push   %esi
  800163:	50                   	push   %eax
  800164:	68 04 0e 80 00       	push   $0x800e04
  800169:	e8 b1 00 00 00       	call   80021f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016e:	83 c4 18             	add    $0x18,%esp
  800171:	53                   	push   %ebx
  800172:	ff 75 10             	pushl  0x10(%ebp)
  800175:	e8 54 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  80017a:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  800181:	e8 99 00 00 00       	call   80021f <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800189:	cc                   	int3   
  80018a:	eb fd                	jmp    800189 <_panic+0x43>

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	75 1a                	jne    8001c5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 ed fe ff ff       	call   8000a9 <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001de:	00 00 00 
	b.cnt = 0;
  8001e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	68 8c 01 80 00       	push   $0x80018c
  8001fd:	e8 4f 01 00 00       	call   800351 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	83 c4 08             	add    $0x8,%esp
  800205:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	e8 92 fe ff ff       	call   8000a9 <sys_cputs>

	return b.cnt;
}
  800217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800225:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800228:	50                   	push   %eax
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 9d ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 1c             	sub    $0x1c,%esp
  80023c:	89 c7                	mov    %eax,%edi
  80023e:	89 d6                	mov    %edx,%esi
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 d1                	mov    %edx,%ecx
  800248:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800254:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800257:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800261:	72 05                	jb     800268 <printnum+0x35>
  800263:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800266:	77 3e                	ja     8002a6 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	83 eb 01             	sub    $0x1,%ebx
  800271:	53                   	push   %ebx
  800272:	50                   	push   %eax
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 79 08 00 00       	call   800b00 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9e ff ff ff       	call   800233 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 13                	jmp    8002ad <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f ed                	jg     80029a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 6b 09 00 00       	call   800c30 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 28 0e 80 00 	movsbl 0x800e28(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
}
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e0:	83 fa 01             	cmp    $0x1,%edx
  8002e3:	7e 0e                	jle    8002f3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	8b 52 04             	mov    0x4(%edx),%edx
  8002f1:	eb 22                	jmp    800315 <getuint+0x38>
	else if (lflag)
  8002f3:	85 d2                	test   %edx,%edx
  8002f5:	74 10                	je     800307 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	eb 0e                	jmp    800315 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800321:	8b 10                	mov    (%eax),%edx
  800323:	3b 50 04             	cmp    0x4(%eax),%edx
  800326:	73 0a                	jae    800332 <sprintputch+0x1b>
		*b->buf++ = ch;
  800328:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	88 02                	mov    %al,(%edx)
}
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033d:	50                   	push   %eax
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	ff 75 0c             	pushl  0xc(%ebp)
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 05 00 00 00       	call   800351 <vprintfmt>
	va_end(ap);
  80034c:	83 c4 10             	add    $0x10,%esp
}
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
  800357:	83 ec 2c             	sub    $0x2c,%esp
  80035a:	8b 75 08             	mov    0x8(%ebp),%esi
  80035d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800360:	8b 7d 10             	mov    0x10(%ebp),%edi
  800363:	eb 12                	jmp    800377 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800365:	85 c0                	test   %eax,%eax
  800367:	0f 84 90 03 00 00    	je     8006fd <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	53                   	push   %ebx
  800371:	50                   	push   %eax
  800372:	ff d6                	call   *%esi
  800374:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	83 c7 01             	add    $0x1,%edi
  80037a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037e:	83 f8 25             	cmp    $0x25,%eax
  800381:	75 e2                	jne    800365 <vprintfmt+0x14>
  800383:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800387:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800395:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039c:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a1:	eb 07                	jmp    8003aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8d 47 01             	lea    0x1(%edi),%eax
  8003ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b0:	0f b6 07             	movzbl (%edi),%eax
  8003b3:	0f b6 c8             	movzbl %al,%ecx
  8003b6:	83 e8 23             	sub    $0x23,%eax
  8003b9:	3c 55                	cmp    $0x55,%al
  8003bb:	0f 87 21 03 00 00    	ja     8006e2 <vprintfmt+0x391>
  8003c1:	0f b6 c0             	movzbl %al,%eax
  8003c4:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ce:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d2:	eb d6                	jmp    8003aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ec:	83 fa 09             	cmp    $0x9,%edx
  8003ef:	77 39                	ja     80042a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f4:	eb e9                	jmp    8003df <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800407:	eb 27                	jmp    800430 <vprintfmt+0xdf>
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800413:	0f 49 c8             	cmovns %eax,%ecx
  800416:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041c:	eb 8c                	jmp    8003aa <vprintfmt+0x59>
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800421:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800428:	eb 80                	jmp    8003aa <vprintfmt+0x59>
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800430:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800434:	0f 89 70 ff ff ff    	jns    8003aa <vprintfmt+0x59>
				width = precision, precision = -1;
  80043a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800440:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800447:	e9 5e ff ff ff       	jmp    8003aa <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800452:	e9 53 ff ff ff       	jmp    8003aa <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	ff 30                	pushl  (%eax)
  800466:	ff d6                	call   *%esi
			break;
  800468:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046e:	e9 04 ff ff ff       	jmp    800377 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	8b 00                	mov    (%eax),%eax
  80047e:	99                   	cltd   
  80047f:	31 d0                	xor    %edx,%eax
  800481:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 f8 07             	cmp    $0x7,%eax
  800486:	7f 0b                	jg     800493 <vprintfmt+0x142>
  800488:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 18                	jne    8004ab <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800493:	50                   	push   %eax
  800494:	68 40 0e 80 00       	push   $0x800e40
  800499:	53                   	push   %ebx
  80049a:	56                   	push   %esi
  80049b:	e8 94 fe ff ff       	call   800334 <printfmt>
  8004a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a6:	e9 cc fe ff ff       	jmp    800377 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ab:	52                   	push   %edx
  8004ac:	68 49 0e 80 00       	push   $0x800e49
  8004b1:	53                   	push   %ebx
  8004b2:	56                   	push   %esi
  8004b3:	e8 7c fe ff ff       	call   800334 <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004be:	e9 b4 fe ff ff       	jmp    800377 <vprintfmt+0x26>
  8004c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d7:	85 ff                	test   %edi,%edi
  8004d9:	ba 39 0e 80 00       	mov    $0x800e39,%edx
  8004de:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e5:	0f 84 92 00 00 00    	je     80057d <vprintfmt+0x22c>
  8004eb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004ef:	0f 8e 96 00 00 00    	jle    80058b <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	51                   	push   %ecx
  8004f9:	57                   	push   %edi
  8004fa:	e8 86 02 00 00       	call   800785 <strnlen>
  8004ff:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800502:	29 c1                	sub    %eax,%ecx
  800504:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800507:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800511:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800514:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800516:	eb 0f                	jmp    800527 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	ff 75 e0             	pushl  -0x20(%ebp)
  80051f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 ef 01             	sub    $0x1,%edi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 ff                	test   %edi,%edi
  800529:	7f ed                	jg     800518 <vprintfmt+0x1c7>
  80052b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800531:	85 c9                	test   %ecx,%ecx
  800533:	b8 00 00 00 00       	mov    $0x0,%eax
  800538:	0f 49 c1             	cmovns %ecx,%eax
  80053b:	29 c1                	sub    %eax,%ecx
  80053d:	89 75 08             	mov    %esi,0x8(%ebp)
  800540:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800546:	89 cb                	mov    %ecx,%ebx
  800548:	eb 4d                	jmp    800597 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054e:	74 1b                	je     80056b <vprintfmt+0x21a>
  800550:	0f be c0             	movsbl %al,%eax
  800553:	83 e8 20             	sub    $0x20,%eax
  800556:	83 f8 5e             	cmp    $0x5e,%eax
  800559:	76 10                	jbe    80056b <vprintfmt+0x21a>
					putch('?', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	6a 3f                	push   $0x3f
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	eb 0d                	jmp    800578 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	52                   	push   %edx
  800572:	ff 55 08             	call   *0x8(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800578:	83 eb 01             	sub    $0x1,%ebx
  80057b:	eb 1a                	jmp    800597 <vprintfmt+0x246>
  80057d:	89 75 08             	mov    %esi,0x8(%ebp)
  800580:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800589:	eb 0c                	jmp    800597 <vprintfmt+0x246>
  80058b:	89 75 08             	mov    %esi,0x8(%ebp)
  80058e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800591:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800594:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800597:	83 c7 01             	add    $0x1,%edi
  80059a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059e:	0f be d0             	movsbl %al,%edx
  8005a1:	85 d2                	test   %edx,%edx
  8005a3:	74 23                	je     8005c8 <vprintfmt+0x277>
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	78 a1                	js     80054a <vprintfmt+0x1f9>
  8005a9:	83 ee 01             	sub    $0x1,%esi
  8005ac:	79 9c                	jns    80054a <vprintfmt+0x1f9>
  8005ae:	89 df                	mov    %ebx,%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b6:	eb 18                	jmp    8005d0 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	6a 20                	push   $0x20
  8005be:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	eb 08                	jmp    8005d0 <vprintfmt+0x27f>
  8005c8:	89 df                	mov    %ebx,%edi
  8005ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d0:	85 ff                	test   %edi,%edi
  8005d2:	7f e4                	jg     8005b8 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d7:	e9 9b fd ff ff       	jmp    800377 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dc:	83 fa 01             	cmp    $0x1,%edx
  8005df:	7e 16                	jle    8005f7 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 08             	lea    0x8(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 50 04             	mov    0x4(%eax),%edx
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f5:	eb 32                	jmp    800629 <vprintfmt+0x2d8>
	else if (lflag)
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	74 18                	je     800613 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800611:	eb 16                	jmp    800629 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800621:	89 c1                	mov    %eax,%ecx
  800623:	c1 f9 1f             	sar    $0x1f,%ecx
  800626:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800629:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800634:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800638:	79 74                	jns    8006ae <vprintfmt+0x35d>
				putch('-', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 2d                	push   $0x2d
  800640:	ff d6                	call   *%esi
				num = -(long long) num;
  800642:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800645:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800648:	f7 d8                	neg    %eax
  80064a:	83 d2 00             	adc    $0x0,%edx
  80064d:	f7 da                	neg    %edx
  80064f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800652:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800657:	eb 55                	jmp    8006ae <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	e8 7c fc ff ff       	call   8002dd <getuint>
			base = 10;
  800661:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800666:	eb 46                	jmp    8006ae <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 6d fc ff ff       	call   8002dd <getuint>
                        base = 8;
  800670:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800675:	eb 37                	jmp    8006ae <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	6a 30                	push   $0x30
  80067d:	ff d6                	call   *%esi
			putch('x', putdat);
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 78                	push   $0x78
  800685:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800690:	8b 00                	mov    (%eax),%eax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800697:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069f:	eb 0d                	jmp    8006ae <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a4:	e8 34 fc ff ff       	call   8002dd <getuint>
			base = 16;
  8006a9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ae:	83 ec 0c             	sub    $0xc,%esp
  8006b1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b5:	57                   	push   %edi
  8006b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b9:	51                   	push   %ecx
  8006ba:	52                   	push   %edx
  8006bb:	50                   	push   %eax
  8006bc:	89 da                	mov    %ebx,%edx
  8006be:	89 f0                	mov    %esi,%eax
  8006c0:	e8 6e fb ff ff       	call   800233 <printnum>
			break;
  8006c5:	83 c4 20             	add    $0x20,%esp
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cb:	e9 a7 fc ff ff       	jmp    800377 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	51                   	push   %ecx
  8006d5:	ff d6                	call   *%esi
			break;
  8006d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dd:	e9 95 fc ff ff       	jmp    800377 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 03                	jmp    8006f2 <vprintfmt+0x3a1>
  8006ef:	83 ef 01             	sub    $0x1,%edi
  8006f2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f6:	75 f7                	jne    8006ef <vprintfmt+0x39e>
  8006f8:	e9 7a fc ff ff       	jmp    800377 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800714:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800718:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800722:	85 c0                	test   %eax,%eax
  800724:	74 26                	je     80074c <vsnprintf+0x47>
  800726:	85 d2                	test   %edx,%edx
  800728:	7e 22                	jle    80074c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072a:	ff 75 14             	pushl  0x14(%ebp)
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	68 17 03 80 00       	push   $0x800317
  800739:	e8 13 fc ff ff       	call   800351 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800741:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 05                	jmp    800751 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075c:	50                   	push   %eax
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	ff 75 08             	pushl  0x8(%ebp)
  800766:	e8 9a ff ff ff       	call   800705 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	b8 00 00 00 00       	mov    $0x0,%eax
  800778:	eb 03                	jmp    80077d <strlen+0x10>
		n++;
  80077a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800781:	75 f7                	jne    80077a <strlen+0xd>
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
  800793:	eb 03                	jmp    800798 <strnlen+0x13>
		n++;
  800795:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	39 c2                	cmp    %eax,%edx
  80079a:	74 08                	je     8007a4 <strnlen+0x1f>
  80079c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a0:	75 f3                	jne    800795 <strnlen+0x10>
  8007a2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bf:	84 db                	test   %bl,%bl
  8007c1:	75 ef                	jne    8007b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c3:	5b                   	pop    %ebx
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cd:	53                   	push   %ebx
  8007ce:	e8 9a ff ff ff       	call   80076d <strlen>
  8007d3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	01 d8                	add    %ebx,%eax
  8007db:	50                   	push   %eax
  8007dc:	e8 c5 ff ff ff       	call   8007a6 <strcpy>
	return dst;
}
  8007e1:	89 d8                	mov    %ebx,%eax
  8007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	89 f2                	mov    %esi,%edx
  8007fa:	eb 0f                	jmp    80080b <strncpy+0x23>
		*dst++ = *src;
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	0f b6 01             	movzbl (%ecx),%eax
  800802:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800805:	80 39 01             	cmpb   $0x1,(%ecx)
  800808:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	39 da                	cmp    %ebx,%edx
  80080d:	75 ed                	jne    8007fc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080f:	89 f0                	mov    %esi,%eax
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	8b 55 10             	mov    0x10(%ebp),%edx
  800823:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800825:	85 d2                	test   %edx,%edx
  800827:	74 21                	je     80084a <strlcpy+0x35>
  800829:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 09                	jmp    80083a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	83 c1 01             	add    $0x1,%ecx
  800837:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083a:	39 c2                	cmp    %eax,%edx
  80083c:	74 09                	je     800847 <strlcpy+0x32>
  80083e:	0f b6 19             	movzbl (%ecx),%ebx
  800841:	84 db                	test   %bl,%bl
  800843:	75 ec                	jne    800831 <strlcpy+0x1c>
  800845:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800847:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084a:	29 f0                	sub    %esi,%eax
}
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800859:	eb 06                	jmp    800861 <strcmp+0x11>
		p++, q++;
  80085b:	83 c1 01             	add    $0x1,%ecx
  80085e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800861:	0f b6 01             	movzbl (%ecx),%eax
  800864:	84 c0                	test   %al,%al
  800866:	74 04                	je     80086c <strcmp+0x1c>
  800868:	3a 02                	cmp    (%edx),%al
  80086a:	74 ef                	je     80085b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	89 c3                	mov    %eax,%ebx
  800882:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800885:	eb 06                	jmp    80088d <strncmp+0x17>
		n--, p++, q++;
  800887:	83 c0 01             	add    $0x1,%eax
  80088a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	39 d8                	cmp    %ebx,%eax
  80088f:	74 15                	je     8008a6 <strncmp+0x30>
  800891:	0f b6 08             	movzbl (%eax),%ecx
  800894:	84 c9                	test   %cl,%cl
  800896:	74 04                	je     80089c <strncmp+0x26>
  800898:	3a 0a                	cmp    (%edx),%cl
  80089a:	74 eb                	je     800887 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 00             	movzbl (%eax),%eax
  80089f:	0f b6 12             	movzbl (%edx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
  8008a4:	eb 05                	jmp    8008ab <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 07                	jmp    8008c1 <strchr+0x13>
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	74 0f                	je     8008cd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	0f b6 10             	movzbl (%eax),%edx
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d9:	eb 03                	jmp    8008de <strfind+0xf>
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	74 04                	je     8008e9 <strfind+0x1a>
  8008e5:	38 ca                	cmp    %cl,%dl
  8008e7:	75 f2                	jne    8008db <strfind+0xc>
			break;
	return (char *) s;
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f7:	85 c9                	test   %ecx,%ecx
  8008f9:	74 36                	je     800931 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800901:	75 28                	jne    80092b <memset+0x40>
  800903:	f6 c1 03             	test   $0x3,%cl
  800906:	75 23                	jne    80092b <memset+0x40>
		c &= 0xFF;
  800908:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090c:	89 d3                	mov    %edx,%ebx
  80090e:	c1 e3 08             	shl    $0x8,%ebx
  800911:	89 d6                	mov    %edx,%esi
  800913:	c1 e6 18             	shl    $0x18,%esi
  800916:	89 d0                	mov    %edx,%eax
  800918:	c1 e0 10             	shl    $0x10,%eax
  80091b:	09 f0                	or     %esi,%eax
  80091d:	09 c2                	or     %eax,%edx
  80091f:	89 d0                	mov    %edx,%eax
  800921:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800923:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800926:	fc                   	cld    
  800927:	f3 ab                	rep stos %eax,%es:(%edi)
  800929:	eb 06                	jmp    800931 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	fc                   	cld    
  80092f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800931:	89 f8                	mov    %edi,%eax
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 75 0c             	mov    0xc(%ebp),%esi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800946:	39 c6                	cmp    %eax,%esi
  800948:	73 35                	jae    80097f <memmove+0x47>
  80094a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094d:	39 d0                	cmp    %edx,%eax
  80094f:	73 2e                	jae    80097f <memmove+0x47>
		s += n;
		d += n;
  800951:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800954:	89 d6                	mov    %edx,%esi
  800956:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 13                	jne    800973 <memmove+0x3b>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 0e                	jne    800973 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800965:	83 ef 04             	sub    $0x4,%edi
  800968:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096e:	fd                   	std    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 09                	jmp    80097c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800973:	83 ef 01             	sub    $0x1,%edi
  800976:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800979:	fd                   	std    
  80097a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097c:	fc                   	cld    
  80097d:	eb 1d                	jmp    80099c <memmove+0x64>
  80097f:	89 f2                	mov    %esi,%edx
  800981:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800983:	f6 c2 03             	test   $0x3,%dl
  800986:	75 0f                	jne    800997 <memmove+0x5f>
  800988:	f6 c1 03             	test   $0x3,%cl
  80098b:	75 0a                	jne    800997 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098d:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800990:	89 c7                	mov    %eax,%edi
  800992:	fc                   	cld    
  800993:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800995:	eb 05                	jmp    80099c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800997:	89 c7                	mov    %eax,%edi
  800999:	fc                   	cld    
  80099a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a3:	ff 75 10             	pushl  0x10(%ebp)
  8009a6:	ff 75 0c             	pushl  0xc(%ebp)
  8009a9:	ff 75 08             	pushl  0x8(%ebp)
  8009ac:	e8 87 ff ff ff       	call   800938 <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 c6                	mov    %eax,%esi
  8009c0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	eb 1a                	jmp    8009df <memcmp+0x2c>
		if (*s1 != *s2)
  8009c5:	0f b6 08             	movzbl (%eax),%ecx
  8009c8:	0f b6 1a             	movzbl (%edx),%ebx
  8009cb:	38 d9                	cmp    %bl,%cl
  8009cd:	74 0a                	je     8009d9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cf:	0f b6 c1             	movzbl %cl,%eax
  8009d2:	0f b6 db             	movzbl %bl,%ebx
  8009d5:	29 d8                	sub    %ebx,%eax
  8009d7:	eb 0f                	jmp    8009e8 <memcmp+0x35>
		s1++, s2++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 f0                	cmp    %esi,%eax
  8009e1:	75 e2                	jne    8009c5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fa:	eb 07                	jmp    800a03 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fc:	38 08                	cmp    %cl,(%eax)
  8009fe:	74 07                	je     800a07 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	39 d0                	cmp    %edx,%eax
  800a05:	72 f5                	jb     8009fc <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a15:	eb 03                	jmp    800a1a <strtol+0x11>
		s++;
  800a17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	0f b6 01             	movzbl (%ecx),%eax
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f6                	je     800a17 <strtol+0xe>
  800a21:	3c 20                	cmp    $0x20,%al
  800a23:	74 f2                	je     800a17 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a25:	3c 2b                	cmp    $0x2b,%al
  800a27:	75 0a                	jne    800a33 <strtol+0x2a>
		s++;
  800a29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a31:	eb 10                	jmp    800a43 <strtol+0x3a>
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a38:	3c 2d                	cmp    $0x2d,%al
  800a3a:	75 07                	jne    800a43 <strtol+0x3a>
		s++, neg = 1;
  800a3c:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a3f:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	0f 94 c0             	sete   %al
  800a48:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4e:	75 19                	jne    800a69 <strtol+0x60>
  800a50:	80 39 30             	cmpb   $0x30,(%ecx)
  800a53:	75 14                	jne    800a69 <strtol+0x60>
  800a55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a59:	0f 85 82 00 00 00    	jne    800ae1 <strtol+0xd8>
		s += 2, base = 16;
  800a5f:	83 c1 02             	add    $0x2,%ecx
  800a62:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a67:	eb 16                	jmp    800a7f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a69:	84 c0                	test   %al,%al
  800a6b:	74 12                	je     800a7f <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	75 08                	jne    800a7f <strtol+0x76>
		s++, base = 8;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a87:	0f b6 11             	movzbl (%ecx),%edx
  800a8a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 09             	cmp    $0x9,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x93>
			dig = *s - '0';
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 30             	sub    $0x30,%edx
  800a9a:	eb 22                	jmp    800abe <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 08                	ja     800aae <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 57             	sub    $0x57,%edx
  800aac:	eb 10                	jmp    800abe <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aae:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 16                	ja     800ace <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac1:	7d 0f                	jge    800ad2 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aca:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acc:	eb b9                	jmp    800a87 <strtol+0x7e>
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	eb 02                	jmp    800ad4 <strtol+0xcb>
  800ad2:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ad4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad8:	74 0d                	je     800ae7 <strtol+0xde>
		*endptr = (char *) s;
  800ada:	8b 75 0c             	mov    0xc(%ebp),%esi
  800add:	89 0e                	mov    %ecx,(%esi)
  800adf:	eb 06                	jmp    800ae7 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae1:	84 c0                	test   %al,%al
  800ae3:	75 92                	jne    800a77 <strtol+0x6e>
  800ae5:	eb 98                	jmp    800a7f <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    
  800af3:	66 90                	xchg   %ax,%ax
  800af5:	66 90                	xchg   %ax,%ax
  800af7:	66 90                	xchg   %ax,%ax
  800af9:	66 90                	xchg   %ax,%ax
  800afb:	66 90                	xchg   %ax,%ax
  800afd:	66 90                	xchg   %ax,%ax
  800aff:	90                   	nop

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	83 ec 10             	sub    $0x10,%esp
  800b06:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800b0a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800b0e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b16:	85 d2                	test   %edx,%edx
  800b18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b1c:	89 34 24             	mov    %esi,(%esp)
  800b1f:	89 c8                	mov    %ecx,%eax
  800b21:	75 35                	jne    800b58 <__udivdi3+0x58>
  800b23:	39 f1                	cmp    %esi,%ecx
  800b25:	0f 87 bd 00 00 00    	ja     800be8 <__udivdi3+0xe8>
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	89 cd                	mov    %ecx,%ebp
  800b2f:	75 0b                	jne    800b3c <__udivdi3+0x3c>
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	31 d2                	xor    %edx,%edx
  800b38:	f7 f1                	div    %ecx
  800b3a:	89 c5                	mov    %eax,%ebp
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	31 d2                	xor    %edx,%edx
  800b40:	f7 f5                	div    %ebp
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	f7 f5                	div    %ebp
  800b48:	89 f2                	mov    %esi,%edx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
  800b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b58:	3b 14 24             	cmp    (%esp),%edx
  800b5b:	77 7b                	ja     800bd8 <__udivdi3+0xd8>
  800b5d:	0f bd f2             	bsr    %edx,%esi
  800b60:	83 f6 1f             	xor    $0x1f,%esi
  800b63:	0f 84 97 00 00 00    	je     800c00 <__udivdi3+0x100>
  800b69:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 f1                	mov    %esi,%ecx
  800b72:	29 f5                	sub    %esi,%ebp
  800b74:	d3 e7                	shl    %cl,%edi
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	89 e9                	mov    %ebp,%ecx
  800b7a:	d3 ea                	shr    %cl,%edx
  800b7c:	89 f1                	mov    %esi,%ecx
  800b7e:	09 fa                	or     %edi,%edx
  800b80:	8b 3c 24             	mov    (%esp),%edi
  800b83:	d3 e0                	shl    %cl,%eax
  800b85:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b89:	89 e9                	mov    %ebp,%ecx
  800b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b93:	89 fa                	mov    %edi,%edx
  800b95:	d3 ea                	shr    %cl,%edx
  800b97:	89 f1                	mov    %esi,%ecx
  800b99:	d3 e7                	shl    %cl,%edi
  800b9b:	89 e9                	mov    %ebp,%ecx
  800b9d:	d3 e8                	shr    %cl,%eax
  800b9f:	09 c7                	or     %eax,%edi
  800ba1:	89 f8                	mov    %edi,%eax
  800ba3:	f7 74 24 08          	divl   0x8(%esp)
  800ba7:	89 d5                	mov    %edx,%ebp
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	f7 64 24 0c          	mull   0xc(%esp)
  800baf:	39 d5                	cmp    %edx,%ebp
  800bb1:	89 14 24             	mov    %edx,(%esp)
  800bb4:	72 11                	jb     800bc7 <__udivdi3+0xc7>
  800bb6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800bba:	89 f1                	mov    %esi,%ecx
  800bbc:	d3 e2                	shl    %cl,%edx
  800bbe:	39 c2                	cmp    %eax,%edx
  800bc0:	73 5e                	jae    800c20 <__udivdi3+0x120>
  800bc2:	3b 2c 24             	cmp    (%esp),%ebp
  800bc5:	75 59                	jne    800c20 <__udivdi3+0x120>
  800bc7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
  800bd8:	31 f6                	xor    %esi,%esi
  800bda:	31 c0                	xor    %eax,%eax
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
  800be8:	89 f2                	mov    %esi,%edx
  800bea:	31 f6                	xor    %esi,%esi
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	f7 f1                	div    %ecx
  800bf0:	89 f2                	mov    %esi,%edx
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c00:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c04:	76 0b                	jbe    800c11 <__udivdi3+0x111>
  800c06:	31 c0                	xor    %eax,%eax
  800c08:	3b 14 24             	cmp    (%esp),%edx
  800c0b:	0f 83 37 ff ff ff    	jae    800b48 <__udivdi3+0x48>
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	e9 2d ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c1b:	90                   	nop
  800c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c20:	89 f8                	mov    %edi,%eax
  800c22:	31 f6                	xor    %esi,%esi
  800c24:	e9 1f ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__umoddi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	83 ec 20             	sub    $0x20,%esp
  800c36:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c3a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c3e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c48:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c4c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c50:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c54:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c58:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	75 1e                	jne    800c80 <__umoddi3+0x50>
  800c62:	39 f7                	cmp    %esi,%edi
  800c64:	76 52                	jbe    800cb8 <__umoddi3+0x88>
  800c66:	89 c8                	mov    %ecx,%eax
  800c68:	89 f2                	mov    %esi,%edx
  800c6a:	f7 f7                	div    %edi
  800c6c:	89 d0                	mov    %edx,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	83 c4 20             	add    $0x20,%esp
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
  800c77:	89 f6                	mov    %esi,%esi
  800c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c80:	39 f0                	cmp    %esi,%eax
  800c82:	77 5c                	ja     800ce0 <__umoddi3+0xb0>
  800c84:	0f bd e8             	bsr    %eax,%ebp
  800c87:	83 f5 1f             	xor    $0x1f,%ebp
  800c8a:	75 64                	jne    800cf0 <__umoddi3+0xc0>
  800c8c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c90:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c94:	0f 86 f6 00 00 00    	jbe    800d90 <__umoddi3+0x160>
  800c9a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c9e:	0f 82 ec 00 00 00    	jb     800d90 <__umoddi3+0x160>
  800ca4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ca8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800cac:	83 c4 20             	add    $0x20,%esp
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
  800cb3:	90                   	nop
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	85 ff                	test   %edi,%edi
  800cba:	89 fd                	mov    %edi,%ebp
  800cbc:	75 0b                	jne    800cc9 <__umoddi3+0x99>
  800cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc3:	31 d2                	xor    %edx,%edx
  800cc5:	f7 f7                	div    %edi
  800cc7:	89 c5                	mov    %eax,%ebp
  800cc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ccd:	31 d2                	xor    %edx,%edx
  800ccf:	f7 f5                	div    %ebp
  800cd1:	89 c8                	mov    %ecx,%eax
  800cd3:	f7 f5                	div    %ebp
  800cd5:	eb 95                	jmp    800c6c <__umoddi3+0x3c>
  800cd7:	89 f6                	mov    %esi,%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	89 c8                	mov    %ecx,%eax
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	83 c4 20             	add    $0x20,%esp
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
  800ceb:	90                   	nop
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cf5:	89 e9                	mov    %ebp,%ecx
  800cf7:	29 e8                	sub    %ebp,%eax
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	89 c7                	mov    %eax,%edi
  800cfd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d05:	89 f9                	mov    %edi,%ecx
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 c1                	mov    %eax,%ecx
  800d0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d0f:	09 d1                	or     %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d17:	89 e9                	mov    %ebp,%ecx
  800d19:	d3 e0                	shl    %cl,%eax
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 e9                	mov    %ebp,%ecx
  800d27:	89 c7                	mov    %eax,%edi
  800d29:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d2d:	d3 e6                	shl    %cl,%esi
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 fa                	mov    %edi,%edx
  800d33:	d3 e8                	shr    %cl,%eax
  800d35:	89 e9                	mov    %ebp,%ecx
  800d37:	09 f0                	or     %esi,%eax
  800d39:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d3d:	f7 74 24 10          	divl   0x10(%esp)
  800d41:	d3 e6                	shl    %cl,%esi
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	f7 64 24 0c          	mull   0xc(%esp)
  800d49:	39 d1                	cmp    %edx,%ecx
  800d4b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	72 0a                	jb     800d5f <__umoddi3+0x12f>
  800d55:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d59:	73 10                	jae    800d6b <__umoddi3+0x13b>
  800d5b:	39 d1                	cmp    %edx,%ecx
  800d5d:	75 0c                	jne    800d6b <__umoddi3+0x13b>
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d67:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d6b:	89 ca                	mov    %ecx,%edx
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d73:	29 f0                	sub    %esi,%eax
  800d75:	19 fa                	sbb    %edi,%edx
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	d3 e7                	shl    %cl,%edi
  800d82:	89 e9                	mov    %ebp,%ecx
  800d84:	09 f8                	or     %edi,%eax
  800d86:	d3 ea                	shr    %cl,%edx
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    
  800d8f:	90                   	nop
  800d90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d94:	29 f9                	sub    %edi,%ecx
  800d96:	19 c6                	sbb    %eax,%esi
  800d98:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d9c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800da0:	e9 ff fe ff ff       	jmp    800ca4 <__umoddi3+0x74>
