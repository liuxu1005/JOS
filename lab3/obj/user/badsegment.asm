
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800049:	e8 c9 00 00 00       	call   800117 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800056:	c1 e0 05             	shl    $0x5,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
  80007d:	83 c4 10             	add    $0x10,%esp
}
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
  800094:	83 c4 10             	add    $0x10,%esp
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 aa 0d 80 00       	push   $0x800daa
  800103:	6a 23                	push   $0x23
  800105:	68 c7 0d 80 00       	push   $0x800dc7
  80010a:	e8 27 00 00 00       	call   800136 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800144:	e8 ce ff ff ff       	call   800117 <sys_getenvid>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	56                   	push   %esi
  800153:	50                   	push   %eax
  800154:	68 d8 0d 80 00       	push   $0x800dd8
  800159:	e8 b1 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015e:	83 c4 18             	add    $0x18,%esp
  800161:	53                   	push   %ebx
  800162:	ff 75 10             	pushl  0x10(%ebp)
  800165:	e8 54 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  80016a:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  800171:	e8 99 00 00 00       	call   80020f <cprintf>
  800176:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800179:	cc                   	int3   
  80017a:	eb fd                	jmp    800179 <_panic+0x43>

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 13                	mov    (%ebx),%edx
  800188:	8d 42 01             	lea    0x1(%edx),%eax
  80018b:	89 03                	mov    %eax,(%ebx)
  80018d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800194:	3d ff 00 00 00       	cmp    $0xff,%eax
  800199:	75 1a                	jne    8001b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 ed fe ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7c 01 80 00       	push   $0x80017c
  8001ed:	e8 4f 01 00 00       	call   800341 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 92 fe ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 c7                	mov    %eax,%edi
  80022e:	89 d6                	mov    %edx,%esi
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	8b 55 0c             	mov    0xc(%ebp),%edx
  800236:	89 d1                	mov    %edx,%ecx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800247:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800251:	72 05                	jb     800258 <printnum+0x35>
  800253:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800256:	77 3e                	ja     800296 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	83 eb 01             	sub    $0x1,%ebx
  800261:	53                   	push   %ebx
  800262:	50                   	push   %eax
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 79 08 00 00       	call   800af0 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9e ff ff ff       	call   800223 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 13                	jmp    80029d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f ed                	jg     80028a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 6b 09 00 00       	call   800c20 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
  8002c2:	83 c4 10             	add    $0x10,%esp
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d0:	83 fa 01             	cmp    $0x1,%edx
  8002d3:	7e 0e                	jle    8002e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	8b 52 04             	mov    0x4(%edx),%edx
  8002e1:	eb 22                	jmp    800305 <getuint+0x38>
	else if (lflag)
  8002e3:	85 d2                	test   %edx,%edx
  8002e5:	74 10                	je     8002f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 02                	mov    (%edx),%eax
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	eb 0e                	jmp    800305 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800311:	8b 10                	mov    (%eax),%edx
  800313:	3b 50 04             	cmp    0x4(%eax),%edx
  800316:	73 0a                	jae    800322 <sprintputch+0x1b>
		*b->buf++ = ch;
  800318:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	88 02                	mov    %al,(%edx)
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032d:	50                   	push   %eax
  80032e:	ff 75 10             	pushl  0x10(%ebp)
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	e8 05 00 00 00       	call   800341 <vprintfmt>
	va_end(ap);
  80033c:	83 c4 10             	add    $0x10,%esp
}
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 2c             	sub    $0x2c,%esp
  80034a:	8b 75 08             	mov    0x8(%ebp),%esi
  80034d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800350:	8b 7d 10             	mov    0x10(%ebp),%edi
  800353:	eb 12                	jmp    800367 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800355:	85 c0                	test   %eax,%eax
  800357:	0f 84 90 03 00 00    	je     8006ed <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	53                   	push   %ebx
  800361:	50                   	push   %eax
  800362:	ff d6                	call   *%esi
  800364:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800367:	83 c7 01             	add    $0x1,%edi
  80036a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036e:	83 f8 25             	cmp    $0x25,%eax
  800371:	75 e2                	jne    800355 <vprintfmt+0x14>
  800373:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800377:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800385:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038c:	ba 00 00 00 00       	mov    $0x0,%edx
  800391:	eb 07                	jmp    80039a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800396:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8d 47 01             	lea    0x1(%edi),%eax
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	0f b6 07             	movzbl (%edi),%eax
  8003a3:	0f b6 c8             	movzbl %al,%ecx
  8003a6:	83 e8 23             	sub    $0x23,%eax
  8003a9:	3c 55                	cmp    $0x55,%al
  8003ab:	0f 87 21 03 00 00    	ja     8006d2 <vprintfmt+0x391>
  8003b1:	0f b6 c0             	movzbl %al,%eax
  8003b4:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c2:	eb d6                	jmp    80039a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003dc:	83 fa 09             	cmp    $0x9,%edx
  8003df:	77 39                	ja     80041a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e4:	eb e9                	jmp    8003cf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f7:	eb 27                	jmp    800420 <vprintfmt+0xdf>
  8003f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800403:	0f 49 c8             	cmovns %eax,%ecx
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	eb 8c                	jmp    80039a <vprintfmt+0x59>
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800411:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800418:	eb 80                	jmp    80039a <vprintfmt+0x59>
  80041a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	0f 89 70 ff ff ff    	jns    80039a <vprintfmt+0x59>
				width = precision, precision = -1;
  80042a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800430:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800437:	e9 5e ff ff ff       	jmp    80039a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800442:	e9 53 ff ff ff       	jmp    80039a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	53                   	push   %ebx
  800454:	ff 30                	pushl  (%eax)
  800456:	ff d6                	call   *%esi
			break;
  800458:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045e:	e9 04 ff ff ff       	jmp    800367 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 00                	mov    (%eax),%eax
  80046e:	99                   	cltd   
  80046f:	31 d0                	xor    %edx,%eax
  800471:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 07             	cmp    $0x7,%eax
  800476:	7f 0b                	jg     800483 <vprintfmt+0x142>
  800478:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	75 18                	jne    80049b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800483:	50                   	push   %eax
  800484:	68 16 0e 80 00       	push   $0x800e16
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 94 fe ff ff       	call   800324 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800496:	e9 cc fe ff ff       	jmp    800367 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 1f 0e 80 00       	push   $0x800e1f
  8004a1:	53                   	push   %ebx
  8004a2:	56                   	push   %esi
  8004a3:	e8 7c fe ff ff       	call   800324 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	e9 b4 fe ff ff       	jmp    800367 <vprintfmt+0x26>
  8004b3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004ce:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004d1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d5:	0f 84 92 00 00 00    	je     80056d <vprintfmt+0x22c>
  8004db:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004df:	0f 8e 96 00 00 00    	jle    80057b <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	51                   	push   %ecx
  8004e9:	57                   	push   %edi
  8004ea:	e8 86 02 00 00       	call   800775 <strnlen>
  8004ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f2:	29 c1                	sub    %eax,%ecx
  8004f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800504:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	eb 0f                	jmp    800517 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	ff 75 e0             	pushl  -0x20(%ebp)
  80050f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ef 01             	sub    $0x1,%edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 ff                	test   %edi,%edi
  800519:	7f ed                	jg     800508 <vprintfmt+0x1c7>
  80051b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800521:	85 c9                	test   %ecx,%ecx
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	0f 49 c1             	cmovns %ecx,%eax
  80052b:	29 c1                	sub    %eax,%ecx
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb 4d                	jmp    800587 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053e:	74 1b                	je     80055b <vprintfmt+0x21a>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 10                	jbe    80055b <vprintfmt+0x21a>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 3f                	push   $0x3f
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 0d                	jmp    800568 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	52                   	push   %edx
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 eb 01             	sub    $0x1,%ebx
  80056b:	eb 1a                	jmp    800587 <vprintfmt+0x246>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	eb 0c                	jmp    800587 <vprintfmt+0x246>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800584:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058e:	0f be d0             	movsbl %al,%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	74 23                	je     8005b8 <vprintfmt+0x277>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 a1                	js     80053a <vprintfmt+0x1f9>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 9c                	jns    80053a <vprintfmt+0x1f9>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 18                	jmp    8005c0 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 20                	push   $0x20
  8005ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	83 ef 01             	sub    $0x1,%edi
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 08                	jmp    8005c0 <vprintfmt+0x27f>
  8005b8:	89 df                	mov    %ebx,%edi
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	85 ff                	test   %edi,%edi
  8005c2:	7f e4                	jg     8005a8 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c7:	e9 9b fd ff ff       	jmp    800367 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cc:	83 fa 01             	cmp    $0x1,%edx
  8005cf:	7e 16                	jle    8005e7 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 08             	lea    0x8(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 50 04             	mov    0x4(%eax),%edx
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e5:	eb 32                	jmp    800619 <vprintfmt+0x2d8>
	else if (lflag)
  8005e7:	85 d2                	test   %edx,%edx
  8005e9:	74 18                	je     800603 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 c1                	mov    %eax,%ecx
  8005fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800601:	eb 16                	jmp    800619 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800624:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800628:	79 74                	jns    80069e <vprintfmt+0x35d>
				putch('-', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 2d                	push   $0x2d
  800630:	ff d6                	call   *%esi
				num = -(long long) num;
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800638:	f7 d8                	neg    %eax
  80063a:	83 d2 00             	adc    $0x0,%edx
  80063d:	f7 da                	neg    %edx
  80063f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800647:	eb 55                	jmp    80069e <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 7c fc ff ff       	call   8002cd <getuint>
			base = 10;
  800651:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800656:	eb 46                	jmp    80069e <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 6d fc ff ff       	call   8002cd <getuint>
                        base = 8;
  800660:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800665:	eb 37                	jmp    80069e <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800680:	8b 00                	mov    (%eax),%eax
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800687:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068f:	eb 0d                	jmp    80069e <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 34 fc ff ff       	call   8002cd <getuint>
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a5:	57                   	push   %edi
  8006a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a9:	51                   	push   %ecx
  8006aa:	52                   	push   %edx
  8006ab:	50                   	push   %eax
  8006ac:	89 da                	mov    %ebx,%edx
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	e8 6e fb ff ff       	call   800223 <printnum>
			break;
  8006b5:	83 c4 20             	add    $0x20,%esp
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 a7 fc ff ff       	jmp    800367 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	51                   	push   %ecx
  8006c5:	ff d6                	call   *%esi
			break;
  8006c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 95 fc ff ff       	jmp    800367 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 03                	jmp    8006e2 <vprintfmt+0x3a1>
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e6:	75 f7                	jne    8006df <vprintfmt+0x39e>
  8006e8:	e9 7a fc ff ff       	jmp    800367 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 07 03 80 00       	push   $0x800307
  800729:	e8 13 fc ff ff       	call   800341 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 05                	jmp    800741 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 08                	je     800794 <strnlen+0x1f>
  80078c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
  800792:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	83 c2 01             	add    $0x1,%edx
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bd:	53                   	push   %ebx
  8007be:	e8 9a ff ff ff       	call   80075d <strlen>
  8007c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 c5 ff ff ff       	call   800796 <strcpy>
	return dst;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	89 f3                	mov    %esi,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	89 f2                	mov    %esi,%edx
  8007ea:	eb 0f                	jmp    8007fb <strncpy+0x23>
		*dst++ = *src;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	0f b6 01             	movzbl (%ecx),%eax
  8007f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	39 da                	cmp    %ebx,%edx
  8007fd:	75 ed                	jne    8007ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	8b 55 10             	mov    0x10(%ebp),%edx
  800813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800815:	85 d2                	test   %edx,%edx
  800817:	74 21                	je     80083a <strlcpy+0x35>
  800819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 09                	jmp    80082a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 09                	je     800837 <strlcpy+0x32>
  80082e:	0f b6 19             	movzbl (%ecx),%ebx
  800831:	84 db                	test   %bl,%bl
  800833:	75 ec                	jne    800821 <strlcpy+0x1c>
  800835:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083a:	29 f0                	sub    %esi,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	eb 06                	jmp    800851 <strcmp+0x11>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 04                	je     80085c <strcmp+0x1c>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	74 ef                	je     80084b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 c0             	movzbl %al,%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800870:	89 c3                	mov    %eax,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800875:	eb 06                	jmp    80087d <strncmp+0x17>
		n--, p++, q++;
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 15                	je     800896 <strncmp+0x30>
  800881:	0f b6 08             	movzbl (%eax),%ecx
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x26>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 eb                	je     800877 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
  800894:	eb 05                	jmp    80089b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089b:	5b                   	pop    %ebx
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 07                	jmp    8008b1 <strchr+0x13>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 0f                	je     8008bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 03                	jmp    8008ce <strfind+0xf>
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	74 04                	je     8008d9 <strfind+0x1a>
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	75 f2                	jne    8008cb <strfind+0xc>
			break;
	return (char *) s;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	74 36                	je     800921 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f1:	75 28                	jne    80091b <memset+0x40>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 23                	jne    80091b <memset+0x40>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d6                	mov    %edx,%esi
  800903:	c1 e6 18             	shl    $0x18,%esi
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 10             	shl    $0x10,%eax
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 c2                	or     %eax,%edx
  80090f:	89 d0                	mov    %edx,%eax
  800911:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800913:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 35                	jae    80096f <memmove+0x47>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2e                	jae    80096f <memmove+0x47>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800944:	89 d6                	mov    %edx,%esi
  800946:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 13                	jne    800963 <memmove+0x3b>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0e                	jne    800963 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800955:	83 ef 04             	sub    $0x4,%edi
  800958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095e:	fd                   	std    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 09                	jmp    80096c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 1d                	jmp    80098c <memmove+0x64>
  80096f:	89 f2                	mov    %esi,%edx
  800971:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 0f                	jne    800987 <memmove+0x5f>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0a                	jne    800987 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097d:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 05                	jmp    80098c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 87 ff ff ff       	call   800928 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	eb 1a                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b5:	0f b6 08             	movzbl (%eax),%ecx
  8009b8:	0f b6 1a             	movzbl (%edx),%ebx
  8009bb:	38 d9                	cmp    %bl,%cl
  8009bd:	74 0a                	je     8009c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c1             	movzbl %cl,%eax
  8009c2:	0f b6 db             	movzbl %bl,%ebx
  8009c5:	29 d8                	sub    %ebx,%eax
  8009c7:	eb 0f                	jmp    8009d8 <memcmp+0x35>
		s1++, s2++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 f0                	cmp    %esi,%eax
  8009d1:	75 e2                	jne    8009b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e5:	89 c2                	mov    %eax,%edx
  8009e7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ea:	eb 07                	jmp    8009f3 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	38 08                	cmp    %cl,(%eax)
  8009ee:	74 07                	je     8009f7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	39 d0                	cmp    %edx,%eax
  8009f5:	72 f5                	jb     8009ec <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a05:	eb 03                	jmp    800a0a <strtol+0x11>
		s++;
  800a07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0a:	0f b6 01             	movzbl (%ecx),%eax
  800a0d:	3c 09                	cmp    $0x9,%al
  800a0f:	74 f6                	je     800a07 <strtol+0xe>
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f2                	je     800a07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a15:	3c 2b                	cmp    $0x2b,%al
  800a17:	75 0a                	jne    800a23 <strtol+0x2a>
		s++;
  800a19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a21:	eb 10                	jmp    800a33 <strtol+0x3a>
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a28:	3c 2d                	cmp    $0x2d,%al
  800a2a:	75 07                	jne    800a33 <strtol+0x3a>
		s++, neg = 1;
  800a2c:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a2f:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	0f 94 c0             	sete   %al
  800a38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3e:	75 19                	jne    800a59 <strtol+0x60>
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 14                	jne    800a59 <strtol+0x60>
  800a45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a49:	0f 85 82 00 00 00    	jne    800ad1 <strtol+0xd8>
		s += 2, base = 16;
  800a4f:	83 c1 02             	add    $0x2,%ecx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 16                	jmp    800a6f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a59:	84 c0                	test   %al,%al
  800a5b:	74 12                	je     800a6f <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 08                	jne    800a6f <strtol+0x76>
		s++, base = 8;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a77:	0f b6 11             	movzbl (%ecx),%edx
  800a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x93>
			dig = *s - '0';
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 30             	sub    $0x30,%edx
  800a8a:	eb 22                	jmp    800aae <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb 10                	jmp    800aae <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 16                	ja     800abe <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab1:	7d 0f                	jge    800ac2 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abc:	eb b9                	jmp    800a77 <strtol+0x7e>
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	eb 02                	jmp    800ac4 <strtol+0xcb>
  800ac2:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac8:	74 0d                	je     800ad7 <strtol+0xde>
		*endptr = (char *) s;
  800aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acd:	89 0e                	mov    %ecx,(%esi)
  800acf:	eb 06                	jmp    800ad7 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	84 c0                	test   %al,%al
  800ad3:	75 92                	jne    800a67 <strtol+0x6e>
  800ad5:	eb 98                	jmp    800a6f <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad7:	f7 da                	neg    %edx
  800ad9:	85 ff                	test   %edi,%edi
  800adb:	0f 45 c2             	cmovne %edx,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    
  800ae3:	66 90                	xchg   %ax,%ax
  800ae5:	66 90                	xchg   %ax,%ax
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
