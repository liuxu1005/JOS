
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80004d:	e8 c9 00 00 00       	call   80011b <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005a:	c1 e0 05             	shl    $0x5,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 42 00 00 00       	call   8000da <sys_env_destroy>
  800098:	83 c4 10             	add    $0x10,%esp
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	89 c3                	mov    %eax,%ebx
  8000b0:	89 c7                	mov    %eax,%edi
  8000b2:	89 c6                	mov    %eax,%esi
  8000b4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	89 d6                	mov    %edx,%esi
  8000d3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	89 cb                	mov    %ecx,%ebx
  8000f2:	89 cf                	mov    %ecx,%edi
  8000f4:	89 ce                	mov    %ecx,%esi
  8000f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	7e 17                	jle    800113 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	6a 03                	push   $0x3
  800102:	68 aa 0d 80 00       	push   $0x800daa
  800107:	6a 23                	push   $0x23
  800109:	68 c7 0d 80 00       	push   $0x800dc7
  80010e:	e8 27 00 00 00       	call   80013a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	89 d1                	mov    %edx,%ecx
  80012d:	89 d3                	mov    %edx,%ebx
  80012f:	89 d7                	mov    %edx,%edi
  800131:	89 d6                	mov    %edx,%esi
  800133:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800142:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800148:	e8 ce ff ff ff       	call   80011b <sys_getenvid>
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	ff 75 0c             	pushl  0xc(%ebp)
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	56                   	push   %esi
  800157:	50                   	push   %eax
  800158:	68 d8 0d 80 00       	push   $0x800dd8
  80015d:	e8 b1 00 00 00       	call   800213 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800162:	83 c4 18             	add    $0x18,%esp
  800165:	53                   	push   %ebx
  800166:	ff 75 10             	pushl  0x10(%ebp)
  800169:	e8 54 00 00 00       	call   8001c2 <vcprintf>
	cprintf("\n");
  80016e:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  800175:	e8 99 00 00 00       	call   800213 <cprintf>
  80017a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017d:	cc                   	int3   
  80017e:	eb fd                	jmp    80017d <_panic+0x43>

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	75 1a                	jne    8001b9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	68 ff 00 00 00       	push   $0xff
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 ed fe ff ff       	call   80009d <sys_cputs>
		b->idx = 0;
  8001b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d2:	00 00 00 
	b.cnt = 0;
  8001d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	68 80 01 80 00       	push   $0x800180
  8001f1:	e8 4f 01 00 00       	call   800345 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	e8 92 fe ff ff       	call   80009d <sys_cputs>

	return b.cnt;
}
  80020b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800219:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021c:	50                   	push   %eax
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	e8 9d ff ff ff       	call   8001c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 1c             	sub    $0x1c,%esp
  800230:	89 c7                	mov    %eax,%edi
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023a:	89 d1                	mov    %edx,%ecx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800242:	8b 45 10             	mov    0x10(%ebp),%eax
  800245:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800248:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800252:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800255:	72 05                	jb     80025c <printnum+0x35>
  800257:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025a:	77 3e                	ja     80029a <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	83 eb 01             	sub    $0x1,%ebx
  800265:	53                   	push   %ebx
  800266:	50                   	push   %eax
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 75 08 00 00       	call   800af0 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9e ff ff ff       	call   800227 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 13                	jmp    8002a1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f ed                	jg     80028e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 67 09 00 00       	call   800c20 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff d7                	call   *%edi
  8002c6:	83 c4 10             	add    $0x10,%esp
}
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d4:	83 fa 01             	cmp    $0x1,%edx
  8002d7:	7e 0e                	jle    8002e7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	8b 52 04             	mov    0x4(%edx),%edx
  8002e5:	eb 22                	jmp    800309 <getuint+0x38>
	else if (lflag)
  8002e7:	85 d2                	test   %edx,%edx
  8002e9:	74 10                	je     8002fb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f9:	eb 0e                	jmp    800309 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800311:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800315:	8b 10                	mov    (%eax),%edx
  800317:	3b 50 04             	cmp    0x4(%eax),%edx
  80031a:	73 0a                	jae    800326 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	88 02                	mov    %al,(%edx)
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800331:	50                   	push   %eax
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	ff 75 0c             	pushl  0xc(%ebp)
  800338:	ff 75 08             	pushl  0x8(%ebp)
  80033b:	e8 05 00 00 00       	call   800345 <vprintfmt>
	va_end(ap);
  800340:	83 c4 10             	add    $0x10,%esp
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 2c             	sub    $0x2c,%esp
  80034e:	8b 75 08             	mov    0x8(%ebp),%esi
  800351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800354:	8b 7d 10             	mov    0x10(%ebp),%edi
  800357:	eb 12                	jmp    80036b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 84 90 03 00 00    	je     8006f1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	53                   	push   %ebx
  800365:	50                   	push   %eax
  800366:	ff d6                	call   *%esi
  800368:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036b:	83 c7 01             	add    $0x1,%edi
  80036e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800372:	83 f8 25             	cmp    $0x25,%eax
  800375:	75 e2                	jne    800359 <vprintfmt+0x14>
  800377:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800382:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800389:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800390:	ba 00 00 00 00       	mov    $0x0,%edx
  800395:	eb 07                	jmp    80039e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8d 47 01             	lea    0x1(%edi),%eax
  8003a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a4:	0f b6 07             	movzbl (%edi),%eax
  8003a7:	0f b6 c8             	movzbl %al,%ecx
  8003aa:	83 e8 23             	sub    $0x23,%eax
  8003ad:	3c 55                	cmp    $0x55,%al
  8003af:	0f 87 21 03 00 00    	ja     8006d6 <vprintfmt+0x391>
  8003b5:	0f b6 c0             	movzbl %al,%eax
  8003b8:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c6:	eb d6                	jmp    80039e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003da:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003dd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e0:	83 fa 09             	cmp    $0x9,%edx
  8003e3:	77 39                	ja     80041e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e8:	eb e9                	jmp    8003d3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fb:	eb 27                	jmp    800424 <vprintfmt+0xdf>
  8003fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800400:	85 c0                	test   %eax,%eax
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	0f 49 c8             	cmovns %eax,%ecx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800410:	eb 8c                	jmp    80039e <vprintfmt+0x59>
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800415:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041c:	eb 80                	jmp    80039e <vprintfmt+0x59>
  80041e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800421:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800428:	0f 89 70 ff ff ff    	jns    80039e <vprintfmt+0x59>
				width = precision, precision = -1;
  80042e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043b:	e9 5e ff ff ff       	jmp    80039e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800440:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800446:	e9 53 ff ff ff       	jmp    80039e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	53                   	push   %ebx
  800458:	ff 30                	pushl  (%eax)
  80045a:	ff d6                	call   *%esi
			break;
  80045c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800462:	e9 04 ff ff ff       	jmp    80036b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	99                   	cltd   
  800473:	31 d0                	xor    %edx,%eax
  800475:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800477:	83 f8 07             	cmp    $0x7,%eax
  80047a:	7f 0b                	jg     800487 <vprintfmt+0x142>
  80047c:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  800483:	85 d2                	test   %edx,%edx
  800485:	75 18                	jne    80049f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800487:	50                   	push   %eax
  800488:	68 16 0e 80 00       	push   $0x800e16
  80048d:	53                   	push   %ebx
  80048e:	56                   	push   %esi
  80048f:	e8 94 fe ff ff       	call   800328 <printfmt>
  800494:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049a:	e9 cc fe ff ff       	jmp    80036b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049f:	52                   	push   %edx
  8004a0:	68 1f 0e 80 00       	push   $0x800e1f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 7c fe ff ff       	call   800328 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b2:	e9 b4 fe ff ff       	jmp    80036b <vprintfmt+0x26>
  8004b7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cb:	85 ff                	test   %edi,%edi
  8004cd:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004d2:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d9:	0f 84 92 00 00 00    	je     800571 <vprintfmt+0x22c>
  8004df:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e3:	0f 8e 96 00 00 00    	jle    80057f <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	51                   	push   %ecx
  8004ed:	57                   	push   %edi
  8004ee:	e8 86 02 00 00       	call   800779 <strnlen>
  8004f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1d6>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c7>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x21a>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x21a>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x246>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x246>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x277>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f9>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f9>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x27f>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 9b fd ff ff       	jmp    80036b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d8>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	79 74                	jns    8006a2 <vprintfmt+0x35d>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 2d                	push   $0x2d
  800634:	ff d6                	call   *%esi
				num = -(long long) num;
  800636:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800639:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063c:	f7 d8                	neg    %eax
  80063e:	83 d2 00             	adc    $0x0,%edx
  800641:	f7 da                	neg    %edx
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064b:	eb 55                	jmp    8006a2 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 7c fc ff ff       	call   8002d1 <getuint>
			base = 10;
  800655:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065a:	eb 46                	jmp    8006a2 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 6d fc ff ff       	call   8002d1 <getuint>
                        base = 8;
  800664:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800669:	eb 37                	jmp    8006a2 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 30                	push   $0x30
  800671:	ff d6                	call   *%esi
			putch('x', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 78                	push   $0x78
  800679:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 34 fc ff ff       	call   8002d1 <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a9:	57                   	push   %edi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	89 da                	mov    %ebx,%edx
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	e8 6e fb ff ff       	call   800227 <printnum>
			break;
  8006b9:	83 c4 20             	add    $0x20,%esp
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bf:	e9 a7 fc ff ff       	jmp    80036b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	51                   	push   %ecx
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d1:	e9 95 fc ff ff       	jmp    80036b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 03                	jmp    8006e6 <vprintfmt+0x3a1>
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ea:	75 f7                	jne    8006e3 <vprintfmt+0x39e>
  8006ec:	e9 7a fc ff ff       	jmp    80036b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f4:	5b                   	pop    %ebx
  8006f5:	5e                   	pop    %esi
  8006f6:	5f                   	pop    %edi
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 26                	je     800740 <vsnprintf+0x47>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7e 22                	jle    800740 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071e:	ff 75 14             	pushl  0x14(%ebp)
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	68 0b 03 80 00       	push   $0x80030b
  80072d:	e8 13 fc ff ff       	call   800345 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb 05                	jmp    800745 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 9a ff ff ff       	call   8006f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 03                	jmp    800771 <strlen+0x10>
		n++;
  80076e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f7                	jne    80076e <strlen+0xd>
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
  800787:	eb 03                	jmp    80078c <strnlen+0x13>
		n++;
  800789:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 08                	je     800798 <strnlen+0x1f>
  800790:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800794:	75 f3                	jne    800789 <strnlen+0x10>
  800796:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 9a ff ff ff       	call   800761 <strlen>
  8007c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 c5 ff ff ff       	call   80079a <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f2                	mov    %esi,%edx
  8007ee:	eb 0f                	jmp    8007ff <strncpy+0x23>
		*dst++ = *src;
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	39 da                	cmp    %ebx,%edx
  800801:	75 ed                	jne    8007f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800803:	89 f0                	mov    %esi,%eax
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	8b 55 10             	mov    0x10(%ebp),%edx
  800817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 21                	je     80083e <strlcpy+0x35>
  80081d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 09                	jmp    80082e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 09                	je     80083b <strlcpy+0x32>
  800832:	0f b6 19             	movzbl (%ecx),%ebx
  800835:	84 db                	test   %bl,%bl
  800837:	75 ec                	jne    800825 <strlcpy+0x1c>
  800839:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083e:	29 f0                	sub    %esi,%eax
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 06                	jmp    800881 <strncmp+0x17>
		n--, p++, q++;
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 15                	je     80089a <strncmp+0x30>
  800885:	0f b6 08             	movzbl (%eax),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x26>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 eb                	je     80087b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
  800898:	eb 05                	jmp    80089f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 07                	jmp    8008b5 <strchr+0x13>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 0f                	je     8008c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 03                	jmp    8008d2 <strfind+0xf>
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 04                	je     8008dd <strfind+0x1a>
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	75 f2                	jne    8008cf <strfind+0xc>
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 36                	je     800925 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 28                	jne    80091f <memset+0x40>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 23                	jne    80091f <memset+0x40>
		c &= 0xFF;
  8008fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 18             	shl    $0x18,%esi
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 10             	shl    $0x10,%eax
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 c2                	or     %eax,%edx
  800913:	89 d0                	mov    %edx,%eax
  800915:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800917:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 06                	jmp    800925 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 35                	jae    800973 <memmove+0x47>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2e                	jae    800973 <memmove+0x47>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800948:	89 d6                	mov    %edx,%esi
  80094a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800952:	75 13                	jne    800967 <memmove+0x3b>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0e                	jne    800967 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 09                	jmp    800970 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800967:	83 ef 01             	sub    $0x1,%edi
  80096a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096d:	fd                   	std    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800970:	fc                   	cld    
  800971:	eb 1d                	jmp    800990 <memmove+0x64>
  800973:	89 f2                	mov    %esi,%edx
  800975:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	75 0f                	jne    80098b <memmove+0x5f>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0a                	jne    80098b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800981:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 05                	jmp    800990 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 87 ff ff ff       	call   80092c <memmove>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	eb 1a                	jmp    8009d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	0f b6 1a             	movzbl (%edx),%ebx
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	74 0a                	je     8009cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 0f                	jmp    8009dc <memcmp+0x35>
		s1++, s2++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	39 f0                	cmp    %esi,%eax
  8009d5:	75 e2                	jne    8009b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ee:	eb 07                	jmp    8009f7 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	38 08                	cmp    %cl,(%eax)
  8009f2:	74 07                	je     8009fb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	39 d0                	cmp    %edx,%eax
  8009f9:	72 f5                	jb     8009f0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	eb 03                	jmp    800a0e <strtol+0x11>
		s++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	3c 09                	cmp    $0x9,%al
  800a13:	74 f6                	je     800a0b <strtol+0xe>
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f2                	je     800a0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 0a                	jne    800a27 <strtol+0x2a>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
  800a25:	eb 10                	jmp    800a37 <strtol+0x3a>
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2c:	3c 2d                	cmp    $0x2d,%al
  800a2e:	75 07                	jne    800a37 <strtol+0x3a>
		s++, neg = 1;
  800a30:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	0f 94 c0             	sete   %al
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 19                	jne    800a5d <strtol+0x60>
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 14                	jne    800a5d <strtol+0x60>
  800a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4d:	0f 85 82 00 00 00    	jne    800ad5 <strtol+0xd8>
		s += 2, base = 16;
  800a53:	83 c1 02             	add    $0x2,%ecx
  800a56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5b:	eb 16                	jmp    800a73 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5d:	84 c0                	test   %al,%al
  800a5f:	74 12                	je     800a73 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a66:	80 39 30             	cmpb   $0x30,(%ecx)
  800a69:	75 08                	jne    800a73 <strtol+0x76>
		s++, base = 8;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7b:	0f b6 11             	movzbl (%ecx),%edx
  800a7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 09             	cmp    $0x9,%bl
  800a86:	77 08                	ja     800a90 <strtol+0x93>
			dig = *s - '0';
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 30             	sub    $0x30,%edx
  800a8e:	eb 22                	jmp    800ab2 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a9a:	0f be d2             	movsbl %dl,%edx
  800a9d:	83 ea 57             	sub    $0x57,%edx
  800aa0:	eb 10                	jmp    800ab2 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aa2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 16                	ja     800ac2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab5:	7d 0f                	jge    800ac6 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac0:	eb b9                	jmp    800a7b <strtol+0x7e>
  800ac2:	89 c2                	mov    %eax,%edx
  800ac4:	eb 02                	jmp    800ac8 <strtol+0xcb>
  800ac6:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acc:	74 0d                	je     800adb <strtol+0xde>
		*endptr = (char *) s;
  800ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad1:	89 0e                	mov    %ecx,(%esi)
  800ad3:	eb 06                	jmp    800adb <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad5:	84 c0                	test   %al,%al
  800ad7:	75 92                	jne    800a6b <strtol+0x6e>
  800ad9:	eb 98                	jmp    800a73 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800adb:	f7 da                	neg    %edx
  800add:	85 ff                	test   %edi,%edi
  800adf:	0f 45 c2             	cmovne %edx,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    
  800ae7:	66 90                	xchg   %ax,%ax
  800ae9:	66 90                	xchg   %ax,%ax
  800aeb:	66 90                	xchg   %ax,%ax
  800aed:	66 90                	xchg   %ax,%ax
  800aef:	90                   	nop

00800af0 <__udivdi3>:
  800af0:	55                   	push   %ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	83 ec 10             	sub    $0x10,%esp
  800af6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800afa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800afe:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b02:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b06:	85 d2                	test   %edx,%edx
  800b08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0c:	89 34 24             	mov    %esi,(%esp)
  800b0f:	89 c8                	mov    %ecx,%eax
  800b11:	75 35                	jne    800b48 <__udivdi3+0x58>
  800b13:	39 f1                	cmp    %esi,%ecx
  800b15:	0f 87 bd 00 00 00    	ja     800bd8 <__udivdi3+0xe8>
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	89 cd                	mov    %ecx,%ebp
  800b1f:	75 0b                	jne    800b2c <__udivdi3+0x3c>
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	31 d2                	xor    %edx,%edx
  800b28:	f7 f1                	div    %ecx
  800b2a:	89 c5                	mov    %eax,%ebp
  800b2c:	89 f0                	mov    %esi,%eax
  800b2e:	31 d2                	xor    %edx,%edx
  800b30:	f7 f5                	div    %ebp
  800b32:	89 c6                	mov    %eax,%esi
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	f7 f5                	div    %ebp
  800b38:	89 f2                	mov    %esi,%edx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    
  800b41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b48:	3b 14 24             	cmp    (%esp),%edx
  800b4b:	77 7b                	ja     800bc8 <__udivdi3+0xd8>
  800b4d:	0f bd f2             	bsr    %edx,%esi
  800b50:	83 f6 1f             	xor    $0x1f,%esi
  800b53:	0f 84 97 00 00 00    	je     800bf0 <__udivdi3+0x100>
  800b59:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 f1                	mov    %esi,%ecx
  800b62:	29 f5                	sub    %esi,%ebp
  800b64:	d3 e7                	shl    %cl,%edi
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	89 e9                	mov    %ebp,%ecx
  800b6a:	d3 ea                	shr    %cl,%edx
  800b6c:	89 f1                	mov    %esi,%ecx
  800b6e:	09 fa                	or     %edi,%edx
  800b70:	8b 3c 24             	mov    (%esp),%edi
  800b73:	d3 e0                	shl    %cl,%eax
  800b75:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b79:	89 e9                	mov    %ebp,%ecx
  800b7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b83:	89 fa                	mov    %edi,%edx
  800b85:	d3 ea                	shr    %cl,%edx
  800b87:	89 f1                	mov    %esi,%ecx
  800b89:	d3 e7                	shl    %cl,%edi
  800b8b:	89 e9                	mov    %ebp,%ecx
  800b8d:	d3 e8                	shr    %cl,%eax
  800b8f:	09 c7                	or     %eax,%edi
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	f7 74 24 08          	divl   0x8(%esp)
  800b97:	89 d5                	mov    %edx,%ebp
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	f7 64 24 0c          	mull   0xc(%esp)
  800b9f:	39 d5                	cmp    %edx,%ebp
  800ba1:	89 14 24             	mov    %edx,(%esp)
  800ba4:	72 11                	jb     800bb7 <__udivdi3+0xc7>
  800ba6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800baa:	89 f1                	mov    %esi,%ecx
  800bac:	d3 e2                	shl    %cl,%edx
  800bae:	39 c2                	cmp    %eax,%edx
  800bb0:	73 5e                	jae    800c10 <__udivdi3+0x120>
  800bb2:	3b 2c 24             	cmp    (%esp),%ebp
  800bb5:	75 59                	jne    800c10 <__udivdi3+0x120>
  800bb7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bba:	31 f6                	xor    %esi,%esi
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	31 f6                	xor    %esi,%esi
  800bca:	31 c0                	xor    %eax,%eax
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
  800bd8:	89 f2                	mov    %esi,%edx
  800bda:	31 f6                	xor    %esi,%esi
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	f7 f1                	div    %ecx
  800be0:	89 f2                	mov    %esi,%edx
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bf0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800bf4:	76 0b                	jbe    800c01 <__udivdi3+0x111>
  800bf6:	31 c0                	xor    %eax,%eax
  800bf8:	3b 14 24             	cmp    (%esp),%edx
  800bfb:	0f 83 37 ff ff ff    	jae    800b38 <__udivdi3+0x48>
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	e9 2d ff ff ff       	jmp    800b38 <__udivdi3+0x48>
  800c0b:	90                   	nop
  800c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c10:	89 f8                	mov    %edi,%eax
  800c12:	31 f6                	xor    %esi,%esi
  800c14:	e9 1f ff ff ff       	jmp    800b38 <__udivdi3+0x48>
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__umoddi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	83 ec 20             	sub    $0x20,%esp
  800c26:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c2a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c2e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c32:	89 c6                	mov    %eax,%esi
  800c34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c38:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c3c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c40:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c44:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c48:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	89 c2                	mov    %eax,%edx
  800c50:	75 1e                	jne    800c70 <__umoddi3+0x50>
  800c52:	39 f7                	cmp    %esi,%edi
  800c54:	76 52                	jbe    800ca8 <__umoddi3+0x88>
  800c56:	89 c8                	mov    %ecx,%eax
  800c58:	89 f2                	mov    %esi,%edx
  800c5a:	f7 f7                	div    %edi
  800c5c:	89 d0                	mov    %edx,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	83 c4 20             	add    $0x20,%esp
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
  800c67:	89 f6                	mov    %esi,%esi
  800c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c70:	39 f0                	cmp    %esi,%eax
  800c72:	77 5c                	ja     800cd0 <__umoddi3+0xb0>
  800c74:	0f bd e8             	bsr    %eax,%ebp
  800c77:	83 f5 1f             	xor    $0x1f,%ebp
  800c7a:	75 64                	jne    800ce0 <__umoddi3+0xc0>
  800c7c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c80:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c84:	0f 86 f6 00 00 00    	jbe    800d80 <__umoddi3+0x160>
  800c8a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c8e:	0f 82 ec 00 00 00    	jb     800d80 <__umoddi3+0x160>
  800c94:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c98:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c9c:	83 c4 20             	add    $0x20,%esp
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
  800ca3:	90                   	nop
  800ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	89 fd                	mov    %edi,%ebp
  800cac:	75 0b                	jne    800cb9 <__umoddi3+0x99>
  800cae:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb3:	31 d2                	xor    %edx,%edx
  800cb5:	f7 f7                	div    %edi
  800cb7:	89 c5                	mov    %eax,%ebp
  800cb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cbd:	31 d2                	xor    %edx,%edx
  800cbf:	f7 f5                	div    %ebp
  800cc1:	89 c8                	mov    %ecx,%eax
  800cc3:	f7 f5                	div    %ebp
  800cc5:	eb 95                	jmp    800c5c <__umoddi3+0x3c>
  800cc7:	89 f6                	mov    %esi,%esi
  800cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cd0:	89 c8                	mov    %ecx,%eax
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	83 c4 20             	add    $0x20,%esp
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
  800cdb:	90                   	nop
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce5:	89 e9                	mov    %ebp,%ecx
  800ce7:	29 e8                	sub    %ebp,%eax
  800ce9:	d3 e2                	shl    %cl,%edx
  800ceb:	89 c7                	mov    %eax,%edi
  800ced:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cf1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cf5:	89 f9                	mov    %edi,%ecx
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 c1                	mov    %eax,%ecx
  800cfb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cff:	09 d1                	or     %edx,%ecx
  800d01:	89 fa                	mov    %edi,%edx
  800d03:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d07:	89 e9                	mov    %ebp,%ecx
  800d09:	d3 e0                	shl    %cl,%eax
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 e9                	mov    %ebp,%ecx
  800d17:	89 c7                	mov    %eax,%edi
  800d19:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d1d:	d3 e6                	shl    %cl,%esi
  800d1f:	89 d1                	mov    %edx,%ecx
  800d21:	89 fa                	mov    %edi,%edx
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 e9                	mov    %ebp,%ecx
  800d27:	09 f0                	or     %esi,%eax
  800d29:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d2d:	f7 74 24 10          	divl   0x10(%esp)
  800d31:	d3 e6                	shl    %cl,%esi
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	f7 64 24 0c          	mull   0xc(%esp)
  800d39:	39 d1                	cmp    %edx,%ecx
  800d3b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 c6                	mov    %eax,%esi
  800d43:	72 0a                	jb     800d4f <__umoddi3+0x12f>
  800d45:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d49:	73 10                	jae    800d5b <__umoddi3+0x13b>
  800d4b:	39 d1                	cmp    %edx,%ecx
  800d4d:	75 0c                	jne    800d5b <__umoddi3+0x13b>
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d57:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d5b:	89 ca                	mov    %ecx,%edx
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d63:	29 f0                	sub    %esi,%eax
  800d65:	19 fa                	sbb    %edi,%edx
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d6e:	89 d7                	mov    %edx,%edi
  800d70:	d3 e7                	shl    %cl,%edi
  800d72:	89 e9                	mov    %ebp,%ecx
  800d74:	09 f8                	or     %edi,%eax
  800d76:	d3 ea                	shr    %cl,%edx
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
  800d7f:	90                   	nop
  800d80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d84:	29 f9                	sub    %edi,%ecx
  800d86:	19 c6                	sbb    %eax,%esi
  800d88:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d8c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d90:	e9 ff fe ff ff       	jmp    800c94 <__umoddi3+0x74>
