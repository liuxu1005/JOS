
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 60 00 00 00       	call   8000a5 <sys_cputs>
  800045:	83 c4 10             	add    $0x10,%esp
}
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800055:	e8 c9 00 00 00       	call   800123 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800062:	c1 e0 05             	shl    $0x5,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0a 00 00 00       	call   800093 <exit>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 42 00 00 00       	call   8000e2 <sys_env_destroy>
  8000a0:	83 c4 10             	add    $0x10,%esp
}
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 cb                	mov    %ecx,%ebx
  8000fa:	89 cf                	mov    %ecx,%edi
  8000fc:	89 ce                	mov    %ecx,%esi
  8000fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800100:	85 c0                	test   %eax,%eax
  800102:	7e 17                	jle    80011b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	50                   	push   %eax
  800108:	6a 03                	push   $0x3
  80010a:	68 aa 0d 80 00       	push   $0x800daa
  80010f:	6a 23                	push   $0x23
  800111:	68 c7 0d 80 00       	push   $0x800dc7
  800116:	e8 27 00 00 00       	call   800142 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 02 00 00 00       	mov    $0x2,%eax
  800133:	89 d1                	mov    %edx,%ecx
  800135:	89 d3                	mov    %edx,%ebx
  800137:	89 d7                	mov    %edx,%edi
  800139:	89 d6                	mov    %edx,%esi
  80013b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800147:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800150:	e8 ce ff ff ff       	call   800123 <sys_getenvid>
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	56                   	push   %esi
  80015f:	50                   	push   %eax
  800160:	68 d8 0d 80 00       	push   $0x800dd8
  800165:	e8 b1 00 00 00       	call   80021b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016a:	83 c4 18             	add    $0x18,%esp
  80016d:	53                   	push   %ebx
  80016e:	ff 75 10             	pushl  0x10(%ebp)
  800171:	e8 54 00 00 00       	call   8001ca <vcprintf>
	cprintf("\n");
  800176:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  80017d:	e8 99 00 00 00       	call   80021b <cprintf>
  800182:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800185:	cc                   	int3   
  800186:	eb fd                	jmp    800185 <_panic+0x43>

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	53                   	push   %ebx
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800192:	8b 13                	mov    (%ebx),%edx
  800194:	8d 42 01             	lea    0x1(%edx),%eax
  800197:	89 03                	mov    %eax,(%ebx)
  800199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a5:	75 1a                	jne    8001c1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	68 ff 00 00 00       	push   $0xff
  8001af:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 ed fe ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8001b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001be:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001da:	00 00 00 
	b.cnt = 0;
  8001dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	ff 75 08             	pushl  0x8(%ebp)
  8001ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f3:	50                   	push   %eax
  8001f4:	68 88 01 80 00       	push   $0x800188
  8001f9:	e8 4f 01 00 00       	call   80034d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fe:	83 c4 08             	add    $0x8,%esp
  800201:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800207:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 92 fe ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  800213:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800221:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800224:	50                   	push   %eax
  800225:	ff 75 08             	pushl  0x8(%ebp)
  800228:	e8 9d ff ff ff       	call   8001ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 1c             	sub    $0x1c,%esp
  800238:	89 c7                	mov    %eax,%edi
  80023a:	89 d6                	mov    %edx,%esi
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800242:	89 d1                	mov    %edx,%ecx
  800244:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800247:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800253:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80025d:	72 05                	jb     800264 <printnum+0x35>
  80025f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800262:	77 3e                	ja     8002a2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	ff 75 18             	pushl  0x18(%ebp)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	53                   	push   %ebx
  80026e:	50                   	push   %eax
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	ff 75 dc             	pushl  -0x24(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	e8 6d 08 00 00       	call   800af0 <__udivdi3>
  800283:	83 c4 18             	add    $0x18,%esp
  800286:	52                   	push   %edx
  800287:	50                   	push   %eax
  800288:	89 f2                	mov    %esi,%edx
  80028a:	89 f8                	mov    %edi,%eax
  80028c:	e8 9e ff ff ff       	call   80022f <printnum>
  800291:	83 c4 20             	add    $0x20,%esp
  800294:	eb 13                	jmp    8002a9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	ff 75 18             	pushl  0x18(%ebp)
  80029d:	ff d7                	call   *%edi
  80029f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f ed                	jg     800296 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bc:	e8 5f 09 00 00       	call   800c20 <__umoddi3>
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff d7                	call   *%edi
  8002ce:	83 c4 10             	add    $0x10,%esp
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002dc:	83 fa 01             	cmp    $0x1,%edx
  8002df:	7e 0e                	jle    8002ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 02                	mov    (%edx),%eax
  8002ea:	8b 52 04             	mov    0x4(%edx),%edx
  8002ed:	eb 22                	jmp    800311 <getuint+0x38>
	else if (lflag)
  8002ef:	85 d2                	test   %edx,%edx
  8002f1:	74 10                	je     800303 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 02                	mov    (%edx),%eax
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800301:	eb 0e                	jmp    800311 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800319:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	3b 50 04             	cmp    0x4(%eax),%edx
  800322:	73 0a                	jae    80032e <sprintputch+0x1b>
		*b->buf++ = ch;
  800324:	8d 4a 01             	lea    0x1(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	88 02                	mov    %al,(%edx)
}
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800336:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800339:	50                   	push   %eax
  80033a:	ff 75 10             	pushl  0x10(%ebp)
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	e8 05 00 00 00       	call   80034d <vprintfmt>
	va_end(ap);
  800348:	83 c4 10             	add    $0x10,%esp
}
  80034b:	c9                   	leave  
  80034c:	c3                   	ret    

0080034d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 2c             	sub    $0x2c,%esp
  800356:	8b 75 08             	mov    0x8(%ebp),%esi
  800359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035f:	eb 12                	jmp    800373 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800361:	85 c0                	test   %eax,%eax
  800363:	0f 84 90 03 00 00    	je     8006f9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	53                   	push   %ebx
  80036d:	50                   	push   %eax
  80036e:	ff d6                	call   *%esi
  800370:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800373:	83 c7 01             	add    $0x1,%edi
  800376:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037a:	83 f8 25             	cmp    $0x25,%eax
  80037d:	75 e2                	jne    800361 <vprintfmt+0x14>
  80037f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800383:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800391:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
  80039d:	eb 07                	jmp    8003a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8d 47 01             	lea    0x1(%edi),%eax
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	0f b6 07             	movzbl (%edi),%eax
  8003af:	0f b6 c8             	movzbl %al,%ecx
  8003b2:	83 e8 23             	sub    $0x23,%eax
  8003b5:	3c 55                	cmp    $0x55,%al
  8003b7:	0f 87 21 03 00 00    	ja     8006de <vprintfmt+0x391>
  8003bd:	0f b6 c0             	movzbl %al,%eax
  8003c0:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ce:	eb d6                	jmp    8003a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003de:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e8:	83 fa 09             	cmp    $0x9,%edx
  8003eb:	77 39                	ja     800426 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f0:	eb e9                	jmp    8003db <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800403:	eb 27                	jmp    80042c <vprintfmt+0xdf>
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	85 c0                	test   %eax,%eax
  80040a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040f:	0f 49 c8             	cmovns %eax,%ecx
  800412:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800418:	eb 8c                	jmp    8003a6 <vprintfmt+0x59>
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800424:	eb 80                	jmp    8003a6 <vprintfmt+0x59>
  800426:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800429:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800430:	0f 89 70 ff ff ff    	jns    8003a6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800436:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800439:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800443:	e9 5e ff ff ff       	jmp    8003a6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800448:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044e:	e9 53 ff ff ff       	jmp    8003a6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	53                   	push   %ebx
  800460:	ff 30                	pushl  (%eax)
  800462:	ff d6                	call   *%esi
			break;
  800464:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046a:	e9 04 ff ff ff       	jmp    800373 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	99                   	cltd   
  80047b:	31 d0                	xor    %edx,%eax
  80047d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047f:	83 f8 07             	cmp    $0x7,%eax
  800482:	7f 0b                	jg     80048f <vprintfmt+0x142>
  800484:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	75 18                	jne    8004a7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048f:	50                   	push   %eax
  800490:	68 16 0e 80 00       	push   $0x800e16
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	e8 94 fe ff ff       	call   800330 <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a2:	e9 cc fe ff ff       	jmp    800373 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a7:	52                   	push   %edx
  8004a8:	68 1f 0e 80 00       	push   $0x800e1f
  8004ad:	53                   	push   %ebx
  8004ae:	56                   	push   %esi
  8004af:	e8 7c fe ff ff       	call   800330 <printfmt>
  8004b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ba:	e9 b4 fe ff ff       	jmp    800373 <vprintfmt+0x26>
  8004bf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d3:	85 ff                	test   %edi,%edi
  8004d5:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004da:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 92 00 00 00    	je     800579 <vprintfmt+0x22c>
  8004e7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004eb:	0f 8e 96 00 00 00    	jle    800587 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	51                   	push   %ecx
  8004f5:	57                   	push   %edi
  8004f6:	e8 86 02 00 00       	call   800781 <strnlen>
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	29 c1                	sub    %eax,%ecx
  800500:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800503:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800506:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800510:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800512:	eb 0f                	jmp    800523 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	ff 75 e0             	pushl  -0x20(%ebp)
  80051b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 ff                	test   %edi,%edi
  800525:	7f ed                	jg     800514 <vprintfmt+0x1c7>
  800527:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	b8 00 00 00 00       	mov    $0x0,%eax
  800534:	0f 49 c1             	cmovns %ecx,%eax
  800537:	29 c1                	sub    %eax,%ecx
  800539:	89 75 08             	mov    %esi,0x8(%ebp)
  80053c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800542:	89 cb                	mov    %ecx,%ebx
  800544:	eb 4d                	jmp    800593 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054a:	74 1b                	je     800567 <vprintfmt+0x21a>
  80054c:	0f be c0             	movsbl %al,%eax
  80054f:	83 e8 20             	sub    $0x20,%eax
  800552:	83 f8 5e             	cmp    $0x5e,%eax
  800555:	76 10                	jbe    800567 <vprintfmt+0x21a>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	6a 3f                	push   $0x3f
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 0d                	jmp    800574 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	ff 75 0c             	pushl  0xc(%ebp)
  80056d:	52                   	push   %edx
  80056e:	ff 55 08             	call   *0x8(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	eb 1a                	jmp    800593 <vprintfmt+0x246>
  800579:	89 75 08             	mov    %esi,0x8(%ebp)
  80057c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800582:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800585:	eb 0c                	jmp    800593 <vprintfmt+0x246>
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800593:	83 c7 01             	add    $0x1,%edi
  800596:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059a:	0f be d0             	movsbl %al,%edx
  80059d:	85 d2                	test   %edx,%edx
  80059f:	74 23                	je     8005c4 <vprintfmt+0x277>
  8005a1:	85 f6                	test   %esi,%esi
  8005a3:	78 a1                	js     800546 <vprintfmt+0x1f9>
  8005a5:	83 ee 01             	sub    $0x1,%esi
  8005a8:	79 9c                	jns    800546 <vprintfmt+0x1f9>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	eb 18                	jmp    8005cc <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 20                	push   $0x20
  8005ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	83 ef 01             	sub    $0x1,%edi
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	eb 08                	jmp    8005cc <vprintfmt+0x27f>
  8005c4:	89 df                	mov    %ebx,%edi
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cc:	85 ff                	test   %edi,%edi
  8005ce:	7f e4                	jg     8005b4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d3:	e9 9b fd ff ff       	jmp    800373 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d8:	83 fa 01             	cmp    $0x1,%edx
  8005db:	7e 16                	jle    8005f3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 08             	lea    0x8(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 50 04             	mov    0x4(%eax),%edx
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f1:	eb 32                	jmp    800625 <vprintfmt+0x2d8>
	else if (lflag)
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	74 18                	je     80060f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060d:	eb 16                	jmp    800625 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 c1                	mov    %eax,%ecx
  80061f:	c1 f9 1f             	sar    $0x1f,%ecx
  800622:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800625:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800628:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800634:	79 74                	jns    8006aa <vprintfmt+0x35d>
				putch('-', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 2d                	push   $0x2d
  80063c:	ff d6                	call   *%esi
				num = -(long long) num;
  80063e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800641:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800644:	f7 d8                	neg    %eax
  800646:	83 d2 00             	adc    $0x0,%edx
  800649:	f7 da                	neg    %edx
  80064b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800653:	eb 55                	jmp    8006aa <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 7c fc ff ff       	call   8002d9 <getuint>
			base = 10;
  80065d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800662:	eb 46                	jmp    8006aa <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 6d fc ff ff       	call   8002d9 <getuint>
                        base = 8;
  80066c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800671:	eb 37                	jmp    8006aa <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 30                	push   $0x30
  800679:	ff d6                	call   *%esi
			putch('x', putdat);
  80067b:	83 c4 08             	add    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 78                	push   $0x78
  800681:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800693:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800696:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069b:	eb 0d                	jmp    8006aa <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069d:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a0:	e8 34 fc ff ff       	call   8002d9 <getuint>
			base = 16;
  8006a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006aa:	83 ec 0c             	sub    $0xc,%esp
  8006ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b1:	57                   	push   %edi
  8006b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b5:	51                   	push   %ecx
  8006b6:	52                   	push   %edx
  8006b7:	50                   	push   %eax
  8006b8:	89 da                	mov    %ebx,%edx
  8006ba:	89 f0                	mov    %esi,%eax
  8006bc:	e8 6e fb ff ff       	call   80022f <printnum>
			break;
  8006c1:	83 c4 20             	add    $0x20,%esp
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	e9 a7 fc ff ff       	jmp    800373 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	51                   	push   %ecx
  8006d1:	ff d6                	call   *%esi
			break;
  8006d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d9:	e9 95 fc ff ff       	jmp    800373 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 03                	jmp    8006ee <vprintfmt+0x3a1>
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f2:	75 f7                	jne    8006eb <vprintfmt+0x39e>
  8006f4:	e9 7a fc ff ff       	jmp    800373 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 18             	sub    $0x18,%esp
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800710:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800714:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800717:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071e:	85 c0                	test   %eax,%eax
  800720:	74 26                	je     800748 <vsnprintf+0x47>
  800722:	85 d2                	test   %edx,%edx
  800724:	7e 22                	jle    800748 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800726:	ff 75 14             	pushl  0x14(%ebp)
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072f:	50                   	push   %eax
  800730:	68 13 03 80 00       	push   $0x800313
  800735:	e8 13 fc ff ff       	call   80034d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb 05                	jmp    80074d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800748:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800758:	50                   	push   %eax
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	ff 75 08             	pushl  0x8(%ebp)
  800762:	e8 9a ff ff ff       	call   800701 <vsnprintf>
	va_end(ap);

	return rc;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	eb 03                	jmp    800779 <strlen+0x10>
		n++;
  800776:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077d:	75 f7                	jne    800776 <strlen+0xd>
		n++;
	return n;
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
  80078f:	eb 03                	jmp    800794 <strnlen+0x13>
		n++;
  800791:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	39 c2                	cmp    %eax,%edx
  800796:	74 08                	je     8007a0 <strnlen+0x1f>
  800798:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079c:	75 f3                	jne    800791 <strnlen+0x10>
  80079e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	83 c2 01             	add    $0x1,%edx
  8007b1:	83 c1 01             	add    $0x1,%ecx
  8007b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bb:	84 db                	test   %bl,%bl
  8007bd:	75 ef                	jne    8007ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007bf:	5b                   	pop    %ebx
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c9:	53                   	push   %ebx
  8007ca:	e8 9a ff ff ff       	call   800769 <strlen>
  8007cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	01 d8                	add    %ebx,%eax
  8007d7:	50                   	push   %eax
  8007d8:	e8 c5 ff ff ff       	call   8007a2 <strcpy>
	return dst;
}
  8007dd:	89 d8                	mov    %ebx,%eax
  8007df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	89 f3                	mov    %esi,%ebx
  8007f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	89 f2                	mov    %esi,%edx
  8007f6:	eb 0f                	jmp    800807 <strncpy+0x23>
		*dst++ = *src;
  8007f8:	83 c2 01             	add    $0x1,%edx
  8007fb:	0f b6 01             	movzbl (%ecx),%eax
  8007fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800801:	80 39 01             	cmpb   $0x1,(%ecx)
  800804:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	39 da                	cmp    %ebx,%edx
  800809:	75 ed                	jne    8007f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081c:	8b 55 10             	mov    0x10(%ebp),%edx
  80081f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800821:	85 d2                	test   %edx,%edx
  800823:	74 21                	je     800846 <strlcpy+0x35>
  800825:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800829:	89 f2                	mov    %esi,%edx
  80082b:	eb 09                	jmp    800836 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082d:	83 c2 01             	add    $0x1,%edx
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800836:	39 c2                	cmp    %eax,%edx
  800838:	74 09                	je     800843 <strlcpy+0x32>
  80083a:	0f b6 19             	movzbl (%ecx),%ebx
  80083d:	84 db                	test   %bl,%bl
  80083f:	75 ec                	jne    80082d <strlcpy+0x1c>
  800841:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800843:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	eb 06                	jmp    80085d <strcmp+0x11>
		p++, q++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 04                	je     800868 <strcmp+0x1c>
  800864:	3a 02                	cmp    (%edx),%al
  800866:	74 ef                	je     800857 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800881:	eb 06                	jmp    800889 <strncmp+0x17>
		n--, p++, q++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 15                	je     8008a2 <strncmp+0x30>
  80088d:	0f b6 08             	movzbl (%eax),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	74 04                	je     800898 <strncmp+0x26>
  800894:	3a 0a                	cmp    (%edx),%cl
  800896:	74 eb                	je     800883 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb 05                	jmp    8008a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	eb 07                	jmp    8008bd <strchr+0x13>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 0f                	je     8008c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 03                	jmp    8008da <strfind+0xf>
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	74 04                	je     8008e5 <strfind+0x1a>
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	75 f2                	jne    8008d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 36                	je     80092d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fd:	75 28                	jne    800927 <memset+0x40>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 23                	jne    800927 <memset+0x40>
		c &= 0xFF;
  800904:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	89 d3                	mov    %edx,%ebx
  80090a:	c1 e3 08             	shl    $0x8,%ebx
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 18             	shl    $0x18,%esi
  800912:	89 d0                	mov    %edx,%eax
  800914:	c1 e0 10             	shl    $0x10,%eax
  800917:	09 f0                	or     %esi,%eax
  800919:	09 c2                	or     %eax,%edx
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800922:	fc                   	cld    
  800923:	f3 ab                	rep stos %eax,%es:(%edi)
  800925:	eb 06                	jmp    80092d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 35                	jae    80097b <memmove+0x47>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 d0                	cmp    %edx,%eax
  80094b:	73 2e                	jae    80097b <memmove+0x47>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800950:	89 d6                	mov    %edx,%esi
  800952:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 13                	jne    80096f <memmove+0x3b>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0e                	jne    80096f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800961:	83 ef 04             	sub    $0x4,%edi
  800964:	8d 72 fc             	lea    -0x4(%edx),%esi
  800967:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096a:	fd                   	std    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 09                	jmp    800978 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096f:	83 ef 01             	sub    $0x1,%edi
  800972:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	fd                   	std    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800978:	fc                   	cld    
  800979:	eb 1d                	jmp    800998 <memmove+0x64>
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	75 0f                	jne    800993 <memmove+0x5f>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 0a                	jne    800993 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800989:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 05                	jmp    800998 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099f:	ff 75 10             	pushl  0x10(%ebp)
  8009a2:	ff 75 0c             	pushl  0xc(%ebp)
  8009a5:	ff 75 08             	pushl  0x8(%ebp)
  8009a8:	e8 87 ff ff ff       	call   800934 <memmove>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	89 c6                	mov    %eax,%esi
  8009bc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bf:	eb 1a                	jmp    8009db <memcmp+0x2c>
		if (*s1 != *s2)
  8009c1:	0f b6 08             	movzbl (%eax),%ecx
  8009c4:	0f b6 1a             	movzbl (%edx),%ebx
  8009c7:	38 d9                	cmp    %bl,%cl
  8009c9:	74 0a                	je     8009d5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cb:	0f b6 c1             	movzbl %cl,%eax
  8009ce:	0f b6 db             	movzbl %bl,%ebx
  8009d1:	29 d8                	sub    %ebx,%eax
  8009d3:	eb 0f                	jmp    8009e4 <memcmp+0x35>
		s1++, s2++;
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 f0                	cmp    %esi,%eax
  8009dd:	75 e2                	jne    8009c1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f1:	89 c2                	mov    %eax,%edx
  8009f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f6:	eb 07                	jmp    8009ff <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f8:	38 08                	cmp    %cl,(%eax)
  8009fa:	74 07                	je     800a03 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	39 d0                	cmp    %edx,%eax
  800a01:	72 f5                	jb     8009f8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	eb 03                	jmp    800a16 <strtol+0x11>
		s++;
  800a13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	0f b6 01             	movzbl (%ecx),%eax
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f6                	je     800a13 <strtol+0xe>
  800a1d:	3c 20                	cmp    $0x20,%al
  800a1f:	74 f2                	je     800a13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	75 0a                	jne    800a2f <strtol+0x2a>
		s++;
  800a25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2d:	eb 10                	jmp    800a3f <strtol+0x3a>
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a34:	3c 2d                	cmp    $0x2d,%al
  800a36:	75 07                	jne    800a3f <strtol+0x3a>
		s++, neg = 1;
  800a38:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a3b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3f:	85 db                	test   %ebx,%ebx
  800a41:	0f 94 c0             	sete   %al
  800a44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4a:	75 19                	jne    800a65 <strtol+0x60>
  800a4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4f:	75 14                	jne    800a65 <strtol+0x60>
  800a51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a55:	0f 85 82 00 00 00    	jne    800add <strtol+0xd8>
		s += 2, base = 16;
  800a5b:	83 c1 02             	add    $0x2,%ecx
  800a5e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a63:	eb 16                	jmp    800a7b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a65:	84 c0                	test   %al,%al
  800a67:	74 12                	je     800a7b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a69:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a71:	75 08                	jne    800a7b <strtol+0x76>
		s++, base = 8;
  800a73:	83 c1 01             	add    $0x1,%ecx
  800a76:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a83:	0f b6 11             	movzbl (%ecx),%edx
  800a86:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 09             	cmp    $0x9,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0x93>
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
  800a96:	eb 22                	jmp    800aba <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a98:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 57             	sub    $0x57,%edx
  800aa8:	eb 10                	jmp    800aba <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 16                	ja     800aca <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aba:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abd:	7d 0f                	jge    800ace <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac8:	eb b9                	jmp    800a83 <strtol+0x7e>
  800aca:	89 c2                	mov    %eax,%edx
  800acc:	eb 02                	jmp    800ad0 <strtol+0xcb>
  800ace:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ad0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad4:	74 0d                	je     800ae3 <strtol+0xde>
		*endptr = (char *) s;
  800ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad9:	89 0e                	mov    %ecx,(%esi)
  800adb:	eb 06                	jmp    800ae3 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800add:	84 c0                	test   %al,%al
  800adf:	75 92                	jne    800a73 <strtol+0x6e>
  800ae1:	eb 98                	jmp    800a7b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae3:	f7 da                	neg    %edx
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	0f 45 c2             	cmovne %edx,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    
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
