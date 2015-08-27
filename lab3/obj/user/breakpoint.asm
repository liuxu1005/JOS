
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800044:	e8 c9 00 00 00       	call   800112 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800051:	c1 e0 05             	shl    $0x5,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0a 00 00 00       	call   800082 <exit>
  800078:	83 c4 10             	add    $0x10,%esp
}
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800088:	6a 00                	push   $0x0
  80008a:	e8 42 00 00 00       	call   8000d1 <sys_env_destroy>
  80008f:	83 c4 10             	add    $0x10,%esp
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	57                   	push   %edi
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009a:	b8 00 00 00 00       	mov    $0x0,%eax
  80009f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a5:	89 c3                	mov    %eax,%ebx
  8000a7:	89 c7                	mov    %eax,%edi
  8000a9:	89 c6                	mov    %eax,%esi
  8000ab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5f                   	pop    %edi
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    

008000b2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c2:	89 d1                	mov    %edx,%ecx
  8000c4:	89 d3                	mov    %edx,%ebx
  8000c6:	89 d7                	mov    %edx,%edi
  8000c8:	89 d6                	mov    %edx,%esi
  8000ca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000df:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 cb                	mov    %ecx,%ebx
  8000e9:	89 cf                	mov    %ecx,%edi
  8000eb:	89 ce                	mov    %ecx,%esi
  8000ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	7e 17                	jle    80010a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	6a 03                	push   $0x3
  8000f9:	68 aa 0d 80 00       	push   $0x800daa
  8000fe:	6a 23                	push   $0x23
  800100:	68 c7 0d 80 00       	push   $0x800dc7
  800105:	e8 27 00 00 00       	call   800131 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 02 00 00 00       	mov    $0x2,%eax
  800122:	89 d1                	mov    %edx,%ecx
  800124:	89 d3                	mov    %edx,%ebx
  800126:	89 d7                	mov    %edx,%edi
  800128:	89 d6                	mov    %edx,%esi
  80012a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800136:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800139:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013f:	e8 ce ff ff ff       	call   800112 <sys_getenvid>
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	ff 75 0c             	pushl  0xc(%ebp)
  80014a:	ff 75 08             	pushl  0x8(%ebp)
  80014d:	56                   	push   %esi
  80014e:	50                   	push   %eax
  80014f:	68 d8 0d 80 00       	push   $0x800dd8
  800154:	e8 b1 00 00 00       	call   80020a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800159:	83 c4 18             	add    $0x18,%esp
  80015c:	53                   	push   %ebx
  80015d:	ff 75 10             	pushl  0x10(%ebp)
  800160:	e8 54 00 00 00       	call   8001b9 <vcprintf>
	cprintf("\n");
  800165:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  80016c:	e8 99 00 00 00       	call   80020a <cprintf>
  800171:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800174:	cc                   	int3   
  800175:	eb fd                	jmp    800174 <_panic+0x43>

00800177 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 04             	sub    $0x4,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 13                	mov    (%ebx),%edx
  800183:	8d 42 01             	lea    0x1(%edx),%eax
  800186:	89 03                	mov    %eax,(%ebx)
  800188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	75 1a                	jne    8001b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	68 ff 00 00 00       	push   $0xff
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	e8 ed fe ff ff       	call   800094 <sys_cputs>
		b->idx = 0;
  8001a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c9:	00 00 00 
	b.cnt = 0;
  8001cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d6:	ff 75 0c             	pushl  0xc(%ebp)
  8001d9:	ff 75 08             	pushl  0x8(%ebp)
  8001dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	68 77 01 80 00       	push   $0x800177
  8001e8:	e8 4f 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ed:	83 c4 08             	add    $0x8,%esp
  8001f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 92 fe ff ff       	call   800094 <sys_cputs>

	return b.cnt;
}
  800202:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800210:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800213:	50                   	push   %eax
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 9d ff ff ff       	call   8001b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 1c             	sub    $0x1c,%esp
  800227:	89 c7                	mov    %eax,%edi
  800229:	89 d6                	mov    %edx,%esi
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 d1                	mov    %edx,%ecx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800249:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80024c:	72 05                	jb     800253 <printnum+0x35>
  80024e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800251:	77 3e                	ja     800291 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	83 eb 01             	sub    $0x1,%ebx
  80025c:	53                   	push   %ebx
  80025d:	50                   	push   %eax
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 6e 08 00 00       	call   800ae0 <__udivdi3>
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	52                   	push   %edx
  800276:	50                   	push   %eax
  800277:	89 f2                	mov    %esi,%edx
  800279:	89 f8                	mov    %edi,%eax
  80027b:	e8 9e ff ff ff       	call   80021e <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 13                	jmp    800298 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	ff d7                	call   *%edi
  80028e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	83 eb 01             	sub    $0x1,%ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f ed                	jg     800285 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 60 09 00 00       	call   800c10 <__umoddi3>
  8002b0:	83 c4 14             	add    $0x14,%esp
  8002b3:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002ba:	50                   	push   %eax
  8002bb:	ff d7                	call   *%edi
  8002bd:	83 c4 10             	add    $0x10,%esp
}
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cb:	83 fa 01             	cmp    $0x1,%edx
  8002ce:	7e 0e                	jle    8002de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	8b 52 04             	mov    0x4(%edx),%edx
  8002dc:	eb 22                	jmp    800300 <getuint+0x38>
	else if (lflag)
  8002de:	85 d2                	test   %edx,%edx
  8002e0:	74 10                	je     8002f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f0:	eb 0e                	jmp    800300 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800308:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	3b 50 04             	cmp    0x4(%eax),%edx
  800311:	73 0a                	jae    80031d <sprintputch+0x1b>
		*b->buf++ = ch;
  800313:	8d 4a 01             	lea    0x1(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	88 02                	mov    %al,(%edx)
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800325:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800328:	50                   	push   %eax
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	ff 75 0c             	pushl  0xc(%ebp)
  80032f:	ff 75 08             	pushl  0x8(%ebp)
  800332:	e8 05 00 00 00       	call   80033c <vprintfmt>
	va_end(ap);
  800337:	83 c4 10             	add    $0x10,%esp
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
  800345:	8b 75 08             	mov    0x8(%ebp),%esi
  800348:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034e:	eb 12                	jmp    800362 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800350:	85 c0                	test   %eax,%eax
  800352:	0f 84 90 03 00 00    	je     8006e8 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	53                   	push   %ebx
  80035c:	50                   	push   %eax
  80035d:	ff d6                	call   *%esi
  80035f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800362:	83 c7 01             	add    $0x1,%edi
  800365:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800369:	83 f8 25             	cmp    $0x25,%eax
  80036c:	75 e2                	jne    800350 <vprintfmt+0x14>
  80036e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800372:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800379:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800380:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800387:	ba 00 00 00 00       	mov    $0x0,%edx
  80038c:	eb 07                	jmp    800395 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800391:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8d 47 01             	lea    0x1(%edi),%eax
  800398:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039b:	0f b6 07             	movzbl (%edi),%eax
  80039e:	0f b6 c8             	movzbl %al,%ecx
  8003a1:	83 e8 23             	sub    $0x23,%eax
  8003a4:	3c 55                	cmp    $0x55,%al
  8003a6:	0f 87 21 03 00 00    	ja     8006cd <vprintfmt+0x391>
  8003ac:	0f b6 c0             	movzbl %al,%eax
  8003af:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bd:	eb d6                	jmp    800395 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d7:	83 fa 09             	cmp    $0x9,%edx
  8003da:	77 39                	ja     800415 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003df:	eb e9                	jmp    8003ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 27                	jmp    80041b <vprintfmt+0xdf>
  8003f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	0f 49 c8             	cmovns %eax,%ecx
  800401:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	eb 8c                	jmp    800395 <vprintfmt+0x59>
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	eb 80                	jmp    800395 <vprintfmt+0x59>
  800415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	0f 89 70 ff ff ff    	jns    800395 <vprintfmt+0x59>
				width = precision, precision = -1;
  800425:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	e9 5e ff ff ff       	jmp    800395 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043d:	e9 53 ff ff ff       	jmp    800395 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	53                   	push   %ebx
  80044f:	ff 30                	pushl  (%eax)
  800451:	ff d6                	call   *%esi
			break;
  800453:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 04 ff ff ff       	jmp    800362 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	99                   	cltd   
  80046a:	31 d0                	xor    %edx,%eax
  80046c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046e:	83 f8 07             	cmp    $0x7,%eax
  800471:	7f 0b                	jg     80047e <vprintfmt+0x142>
  800473:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80047a:	85 d2                	test   %edx,%edx
  80047c:	75 18                	jne    800496 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047e:	50                   	push   %eax
  80047f:	68 16 0e 80 00       	push   $0x800e16
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 94 fe ff ff       	call   80031f <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800491:	e9 cc fe ff ff       	jmp    800362 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800496:	52                   	push   %edx
  800497:	68 1f 0e 80 00       	push   $0x800e1f
  80049c:	53                   	push   %ebx
  80049d:	56                   	push   %esi
  80049e:	e8 7c fe ff ff       	call   80031f <printfmt>
  8004a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	e9 b4 fe ff ff       	jmp    800362 <vprintfmt+0x26>
  8004ae:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b4:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004c9:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d0:	0f 84 92 00 00 00    	je     800568 <vprintfmt+0x22c>
  8004d6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004da:	0f 8e 96 00 00 00    	jle    800576 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	51                   	push   %ecx
  8004e4:	57                   	push   %edi
  8004e5:	e8 86 02 00 00       	call   800770 <strnlen>
  8004ea:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ed:	29 c1                	sub    %eax,%ecx
  8004ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	eb 0f                	jmp    800512 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	53                   	push   %ebx
  800507:	ff 75 e0             	pushl  -0x20(%ebp)
  80050a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 ef 01             	sub    $0x1,%edi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 ff                	test   %edi,%edi
  800514:	7f ed                	jg     800503 <vprintfmt+0x1c7>
  800516:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800519:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051c:	85 c9                	test   %ecx,%ecx
  80051e:	b8 00 00 00 00       	mov    $0x0,%eax
  800523:	0f 49 c1             	cmovns %ecx,%eax
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	89 cb                	mov    %ecx,%ebx
  800533:	eb 4d                	jmp    800582 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800535:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800539:	74 1b                	je     800556 <vprintfmt+0x21a>
  80053b:	0f be c0             	movsbl %al,%eax
  80053e:	83 e8 20             	sub    $0x20,%eax
  800541:	83 f8 5e             	cmp    $0x5e,%eax
  800544:	76 10                	jbe    800556 <vprintfmt+0x21a>
					putch('?', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	eb 0d                	jmp    800563 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 0c             	pushl  0xc(%ebp)
  80055c:	52                   	push   %edx
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800563:	83 eb 01             	sub    $0x1,%ebx
  800566:	eb 1a                	jmp    800582 <vprintfmt+0x246>
  800568:	89 75 08             	mov    %esi,0x8(%ebp)
  80056b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800571:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800574:	eb 0c                	jmp    800582 <vprintfmt+0x246>
  800576:	89 75 08             	mov    %esi,0x8(%ebp)
  800579:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800582:	83 c7 01             	add    $0x1,%edi
  800585:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800589:	0f be d0             	movsbl %al,%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 23                	je     8005b3 <vprintfmt+0x277>
  800590:	85 f6                	test   %esi,%esi
  800592:	78 a1                	js     800535 <vprintfmt+0x1f9>
  800594:	83 ee 01             	sub    $0x1,%esi
  800597:	79 9c                	jns    800535 <vprintfmt+0x1f9>
  800599:	89 df                	mov    %ebx,%edi
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a1:	eb 18                	jmp    8005bb <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	53                   	push   %ebx
  8005a7:	6a 20                	push   $0x20
  8005a9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	83 ef 01             	sub    $0x1,%edi
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	eb 08                	jmp    8005bb <vprintfmt+0x27f>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	7f e4                	jg     8005a3 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	e9 9b fd ff ff       	jmp    800362 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c7:	83 fa 01             	cmp    $0x1,%edx
  8005ca:	7e 16                	jle    8005e2 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 08             	lea    0x8(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 50 04             	mov    0x4(%eax),%edx
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e0:	eb 32                	jmp    800614 <vprintfmt+0x2d8>
	else if (lflag)
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	74 18                	je     8005fe <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fc:	eb 16                	jmp    800614 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 c1                	mov    %eax,%ecx
  80060e:	c1 f9 1f             	sar    $0x1f,%ecx
  800611:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800614:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800617:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800623:	79 74                	jns    800699 <vprintfmt+0x35d>
				putch('-', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 2d                	push   $0x2d
  80062b:	ff d6                	call   *%esi
				num = -(long long) num;
  80062d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800630:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800633:	f7 d8                	neg    %eax
  800635:	83 d2 00             	adc    $0x0,%edx
  800638:	f7 da                	neg    %edx
  80063a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800642:	eb 55                	jmp    800699 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800644:	8d 45 14             	lea    0x14(%ebp),%eax
  800647:	e8 7c fc ff ff       	call   8002c8 <getuint>
			base = 10;
  80064c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800651:	eb 46                	jmp    800699 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 6d fc ff ff       	call   8002c8 <getuint>
                        base = 8;
  80065b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800660:	eb 37                	jmp    800699 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 30                	push   $0x30
  800668:	ff d6                	call   *%esi
			putch('x', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 78                	push   $0x78
  800670:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800685:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068a:	eb 0d                	jmp    800699 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
  80068f:	e8 34 fc ff ff       	call   8002c8 <getuint>
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a0:	57                   	push   %edi
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	51                   	push   %ecx
  8006a5:	52                   	push   %edx
  8006a6:	50                   	push   %eax
  8006a7:	89 da                	mov    %ebx,%edx
  8006a9:	89 f0                	mov    %esi,%eax
  8006ab:	e8 6e fb ff ff       	call   80021e <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b6:	e9 a7 fc ff ff       	jmp    800362 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	51                   	push   %ecx
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 95 fc ff ff       	jmp    800362 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 03                	jmp    8006dd <vprintfmt+0x3a1>
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e1:	75 f7                	jne    8006da <vprintfmt+0x39e>
  8006e3:	e9 7a fc ff ff       	jmp    800362 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 18             	sub    $0x18,%esp
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800703:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 26                	je     800737 <vsnprintf+0x47>
  800711:	85 d2                	test   %edx,%edx
  800713:	7e 22                	jle    800737 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800715:	ff 75 14             	pushl  0x14(%ebp)
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 02 03 80 00       	push   $0x800302
  800724:	e8 13 fc ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 05                	jmp    80073c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	ff 75 08             	pushl  0x8(%ebp)
  800751:	e8 9a ff ff ff       	call   8006f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strlen+0x10>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076c:	75 f7                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	ba 00 00 00 00       	mov    $0x0,%edx
  80077e:	eb 03                	jmp    800783 <strnlen+0x13>
		n++;
  800780:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 c2                	cmp    %eax,%edx
  800785:	74 08                	je     80078f <strnlen+0x1f>
  800787:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078b:	75 f3                	jne    800780 <strnlen+0x10>
  80078d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007aa:	84 db                	test   %bl,%bl
  8007ac:	75 ef                	jne    80079d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b8:	53                   	push   %ebx
  8007b9:	e8 9a ff ff ff       	call   800758 <strlen>
  8007be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	01 d8                	add    %ebx,%eax
  8007c6:	50                   	push   %eax
  8007c7:	e8 c5 ff ff ff       	call   800791 <strcpy>
	return dst;
}
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 f3                	mov    %esi,%ebx
  8007e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 0f                	jmp    8007f6 <strncpy+0x23>
		*dst++ = *src;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	39 da                	cmp    %ebx,%edx
  8007f8:	75 ed                	jne    8007e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 10             	mov    0x10(%ebp),%edx
  80080e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 d2                	test   %edx,%edx
  800812:	74 21                	je     800835 <strlcpy+0x35>
  800814:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800818:	89 f2                	mov    %esi,%edx
  80081a:	eb 09                	jmp    800825 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 c2                	cmp    %eax,%edx
  800827:	74 09                	je     800832 <strlcpy+0x32>
  800829:	0f b6 19             	movzbl (%ecx),%ebx
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ec                	jne    80081c <strlcpy+0x1c>
  800830:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	eb 06                	jmp    80084c <strcmp+0x11>
		p++, q++;
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	84 c0                	test   %al,%al
  800851:	74 04                	je     800857 <strcmp+0x1c>
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 ef                	je     800846 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x17>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 15                	je     800891 <strncmp+0x30>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x26>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 07                	jmp    8008ac <strchr+0x13>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 0f                	je     8008b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 03                	jmp    8008c9 <strfind+0xf>
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 04                	je     8008d4 <strfind+0x1a>
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	75 f2                	jne    8008c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 36                	je     80091c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ec:	75 28                	jne    800916 <memset+0x40>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 23                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f7:	89 d3                	mov    %edx,%ebx
  8008f9:	c1 e3 08             	shl    $0x8,%ebx
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 18             	shl    $0x18,%esi
  800901:	89 d0                	mov    %edx,%eax
  800903:	c1 e0 10             	shl    $0x10,%eax
  800906:	09 f0                	or     %esi,%eax
  800908:	09 c2                	or     %eax,%edx
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 06                	jmp    80091c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	fc                   	cld    
  80091a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091c:	89 f8                	mov    %edi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 35                	jae    80096a <memmove+0x47>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	73 2e                	jae    80096a <memmove+0x47>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80093f:	89 d6                	mov    %edx,%esi
  800941:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	75 13                	jne    80095e <memmove+0x3b>
  80094b:	f6 c1 03             	test   $0x3,%cl
  80094e:	75 0e                	jne    80095e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1d                	jmp    800987 <memmove+0x64>
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0f                	jne    800982 <memmove+0x5f>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0a                	jne    800982 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800978:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 05                	jmp    800987 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 87 ff ff ff       	call   800923 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	eb 1a                	jmp    8009ca <memcmp+0x2c>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	74 0a                	je     8009c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ba:	0f b6 c1             	movzbl %cl,%eax
  8009bd:	0f b6 db             	movzbl %bl,%ebx
  8009c0:	29 d8                	sub    %ebx,%eax
  8009c2:	eb 0f                	jmp    8009d3 <memcmp+0x35>
		s1++, s2++;
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	39 f0                	cmp    %esi,%eax
  8009cc:	75 e2                	jne    8009b0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e5:	eb 07                	jmp    8009ee <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e7:	38 08                	cmp    %cl,(%eax)
  8009e9:	74 07                	je     8009f2 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	39 d0                	cmp    %edx,%eax
  8009f0:	72 f5                	jb     8009e7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	eb 03                	jmp    800a05 <strtol+0x11>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a05:	0f b6 01             	movzbl (%ecx),%eax
  800a08:	3c 09                	cmp    $0x9,%al
  800a0a:	74 f6                	je     800a02 <strtol+0xe>
  800a0c:	3c 20                	cmp    $0x20,%al
  800a0e:	74 f2                	je     800a02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a10:	3c 2b                	cmp    $0x2b,%al
  800a12:	75 0a                	jne    800a1e <strtol+0x2a>
		s++;
  800a14:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1c:	eb 10                	jmp    800a2e <strtol+0x3a>
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a23:	3c 2d                	cmp    $0x2d,%al
  800a25:	75 07                	jne    800a2e <strtol+0x3a>
		s++, neg = 1;
  800a27:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a2a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	0f 94 c0             	sete   %al
  800a33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a39:	75 19                	jne    800a54 <strtol+0x60>
  800a3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3e:	75 14                	jne    800a54 <strtol+0x60>
  800a40:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a44:	0f 85 82 00 00 00    	jne    800acc <strtol+0xd8>
		s += 2, base = 16;
  800a4a:	83 c1 02             	add    $0x2,%ecx
  800a4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a52:	eb 16                	jmp    800a6a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a54:	84 c0                	test   %al,%al
  800a56:	74 12                	je     800a6a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a58:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a60:	75 08                	jne    800a6a <strtol+0x76>
		s++, base = 8;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a72:	0f b6 11             	movzbl (%ecx),%edx
  800a75:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 09             	cmp    $0x9,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0x93>
			dig = *s - '0';
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 30             	sub    $0x30,%edx
  800a85:	eb 22                	jmp    800aa9 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 19             	cmp    $0x19,%bl
  800a8f:	77 08                	ja     800a99 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 57             	sub    $0x57,%edx
  800a97:	eb 10                	jmp    800aa9 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a99:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 16                	ja     800ab9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aac:	7d 0f                	jge    800abd <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab7:	eb b9                	jmp    800a72 <strtol+0x7e>
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	eb 02                	jmp    800abf <strtol+0xcb>
  800abd:	89 c2                	mov    %eax,%edx

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 0d                	je     800ad2 <strtol+0xde>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 0e                	mov    %ecx,(%esi)
  800aca:	eb 06                	jmp    800ad2 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acc:	84 c0                	test   %al,%al
  800ace:	75 92                	jne    800a62 <strtol+0x6e>
  800ad0:	eb 98                	jmp    800a6a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    
  800ade:	66 90                	xchg   %ax,%ax

00800ae0 <__udivdi3>:
  800ae0:	55                   	push   %ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	83 ec 10             	sub    $0x10,%esp
  800ae6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800aea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800aee:	8b 74 24 24          	mov    0x24(%esp),%esi
  800af2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800af6:	85 d2                	test   %edx,%edx
  800af8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800afc:	89 34 24             	mov    %esi,(%esp)
  800aff:	89 c8                	mov    %ecx,%eax
  800b01:	75 35                	jne    800b38 <__udivdi3+0x58>
  800b03:	39 f1                	cmp    %esi,%ecx
  800b05:	0f 87 bd 00 00 00    	ja     800bc8 <__udivdi3+0xe8>
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	89 cd                	mov    %ecx,%ebp
  800b0f:	75 0b                	jne    800b1c <__udivdi3+0x3c>
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	31 d2                	xor    %edx,%edx
  800b18:	f7 f1                	div    %ecx
  800b1a:	89 c5                	mov    %eax,%ebp
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	31 d2                	xor    %edx,%edx
  800b20:	f7 f5                	div    %ebp
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	f7 f5                	div    %ebp
  800b28:	89 f2                	mov    %esi,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
  800b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b38:	3b 14 24             	cmp    (%esp),%edx
  800b3b:	77 7b                	ja     800bb8 <__udivdi3+0xd8>
  800b3d:	0f bd f2             	bsr    %edx,%esi
  800b40:	83 f6 1f             	xor    $0x1f,%esi
  800b43:	0f 84 97 00 00 00    	je     800be0 <__udivdi3+0x100>
  800b49:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 f1                	mov    %esi,%ecx
  800b52:	29 f5                	sub    %esi,%ebp
  800b54:	d3 e7                	shl    %cl,%edi
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	89 e9                	mov    %ebp,%ecx
  800b5a:	d3 ea                	shr    %cl,%edx
  800b5c:	89 f1                	mov    %esi,%ecx
  800b5e:	09 fa                	or     %edi,%edx
  800b60:	8b 3c 24             	mov    (%esp),%edi
  800b63:	d3 e0                	shl    %cl,%eax
  800b65:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b69:	89 e9                	mov    %ebp,%ecx
  800b6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b73:	89 fa                	mov    %edi,%edx
  800b75:	d3 ea                	shr    %cl,%edx
  800b77:	89 f1                	mov    %esi,%ecx
  800b79:	d3 e7                	shl    %cl,%edi
  800b7b:	89 e9                	mov    %ebp,%ecx
  800b7d:	d3 e8                	shr    %cl,%eax
  800b7f:	09 c7                	or     %eax,%edi
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	f7 74 24 08          	divl   0x8(%esp)
  800b87:	89 d5                	mov    %edx,%ebp
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	f7 64 24 0c          	mull   0xc(%esp)
  800b8f:	39 d5                	cmp    %edx,%ebp
  800b91:	89 14 24             	mov    %edx,(%esp)
  800b94:	72 11                	jb     800ba7 <__udivdi3+0xc7>
  800b96:	8b 54 24 04          	mov    0x4(%esp),%edx
  800b9a:	89 f1                	mov    %esi,%ecx
  800b9c:	d3 e2                	shl    %cl,%edx
  800b9e:	39 c2                	cmp    %eax,%edx
  800ba0:	73 5e                	jae    800c00 <__udivdi3+0x120>
  800ba2:	3b 2c 24             	cmp    (%esp),%ebp
  800ba5:	75 59                	jne    800c00 <__udivdi3+0x120>
  800ba7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800baa:	31 f6                	xor    %esi,%esi
  800bac:	89 f2                	mov    %esi,%edx
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
  800bb5:	8d 76 00             	lea    0x0(%esi),%esi
  800bb8:	31 f6                	xor    %esi,%esi
  800bba:	31 c0                	xor    %eax,%eax
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	f7 f1                	div    %ecx
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800be4:	76 0b                	jbe    800bf1 <__udivdi3+0x111>
  800be6:	31 c0                	xor    %eax,%eax
  800be8:	3b 14 24             	cmp    (%esp),%edx
  800beb:	0f 83 37 ff ff ff    	jae    800b28 <__udivdi3+0x48>
  800bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf6:	e9 2d ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800bfb:	90                   	nop
  800bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c00:	89 f8                	mov    %edi,%eax
  800c02:	31 f6                	xor    %esi,%esi
  800c04:	e9 1f ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

00800c10 <__umoddi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	83 ec 20             	sub    $0x20,%esp
  800c16:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c22:	89 c6                	mov    %eax,%esi
  800c24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c38:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	75 1e                	jne    800c60 <__umoddi3+0x50>
  800c42:	39 f7                	cmp    %esi,%edi
  800c44:	76 52                	jbe    800c98 <__umoddi3+0x88>
  800c46:	89 c8                	mov    %ecx,%eax
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	f7 f7                	div    %edi
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	83 c4 20             	add    $0x20,%esp
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
  800c57:	89 f6                	mov    %esi,%esi
  800c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c60:	39 f0                	cmp    %esi,%eax
  800c62:	77 5c                	ja     800cc0 <__umoddi3+0xb0>
  800c64:	0f bd e8             	bsr    %eax,%ebp
  800c67:	83 f5 1f             	xor    $0x1f,%ebp
  800c6a:	75 64                	jne    800cd0 <__umoddi3+0xc0>
  800c6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c74:	0f 86 f6 00 00 00    	jbe    800d70 <__umoddi3+0x160>
  800c7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c7e:	0f 82 ec 00 00 00    	jb     800d70 <__umoddi3+0x160>
  800c84:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c88:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c8c:	83 c4 20             	add    $0x20,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	85 ff                	test   %edi,%edi
  800c9a:	89 fd                	mov    %edi,%ebp
  800c9c:	75 0b                	jne    800ca9 <__umoddi3+0x99>
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f7                	div    %edi
  800ca7:	89 c5                	mov    %eax,%ebp
  800ca9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cad:	31 d2                	xor    %edx,%edx
  800caf:	f7 f5                	div    %ebp
  800cb1:	89 c8                	mov    %ecx,%eax
  800cb3:	f7 f5                	div    %ebp
  800cb5:	eb 95                	jmp    800c4c <__umoddi3+0x3c>
  800cb7:	89 f6                	mov    %esi,%esi
  800cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    
  800ccb:	90                   	nop
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd5:	89 e9                	mov    %ebp,%ecx
  800cd7:	29 e8                	sub    %ebp,%eax
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	89 c7                	mov    %eax,%edi
  800cdd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ce1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ce5:	89 f9                	mov    %edi,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	89 c1                	mov    %eax,%ecx
  800ceb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cef:	09 d1                	or     %edx,%ecx
  800cf1:	89 fa                	mov    %edi,%edx
  800cf3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cf7:	89 e9                	mov    %ebp,%ecx
  800cf9:	d3 e0                	shl    %cl,%eax
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	89 c7                	mov    %eax,%edi
  800d09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0d:	d3 e6                	shl    %cl,%esi
  800d0f:	89 d1                	mov    %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 e9                	mov    %ebp,%ecx
  800d17:	09 f0                	or     %esi,%eax
  800d19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d1d:	f7 74 24 10          	divl   0x10(%esp)
  800d21:	d3 e6                	shl    %cl,%esi
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	f7 64 24 0c          	mull   0xc(%esp)
  800d29:	39 d1                	cmp    %edx,%ecx
  800d2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 c6                	mov    %eax,%esi
  800d33:	72 0a                	jb     800d3f <__umoddi3+0x12f>
  800d35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d39:	73 10                	jae    800d4b <__umoddi3+0x13b>
  800d3b:	39 d1                	cmp    %edx,%ecx
  800d3d:	75 0c                	jne    800d4b <__umoddi3+0x13b>
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 c6                	mov    %eax,%esi
  800d43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d4b:	89 ca                	mov    %ecx,%edx
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d53:	29 f0                	sub    %esi,%eax
  800d55:	19 fa                	sbb    %edi,%edx
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	d3 e7                	shl    %cl,%edi
  800d62:	89 e9                	mov    %ebp,%ecx
  800d64:	09 f8                	or     %edi,%eax
  800d66:	d3 ea                	shr    %cl,%edx
  800d68:	83 c4 20             	add    $0x20,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
  800d70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d74:	29 f9                	sub    %edi,%ecx
  800d76:	19 c6                	sbb    %eax,%esi
  800d78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d80:	e9 ff fe ff ff       	jmp    800c84 <__umoddi3+0x74>
