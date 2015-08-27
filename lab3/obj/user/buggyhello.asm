
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 60 00 00 00       	call   8000a2 <sys_cputs>
  800042:	83 c4 10             	add    $0x10,%esp
}
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 c9 00 00 00       	call   800120 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
  800086:	83 c4 10             	add    $0x10,%esp
}
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 aa 0d 80 00       	push   $0x800daa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 0d 80 00       	push   $0x800dc7
  800113:	e8 27 00 00 00       	call   80013f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014d:	e8 ce ff ff ff       	call   800120 <sys_getenvid>
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	ff 75 0c             	pushl  0xc(%ebp)
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	56                   	push   %esi
  80015c:	50                   	push   %eax
  80015d:	68 d8 0d 80 00       	push   $0x800dd8
  800162:	e8 b1 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800167:	83 c4 18             	add    $0x18,%esp
  80016a:	53                   	push   %ebx
  80016b:	ff 75 10             	pushl  0x10(%ebp)
  80016e:	e8 54 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800173:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  80017a:	e8 99 00 00 00       	call   800218 <cprintf>
  80017f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800182:	cc                   	int3   
  800183:	eb fd                	jmp    800182 <_panic+0x43>

00800185 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 04             	sub    $0x4,%esp
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018f:	8b 13                	mov    (%ebx),%edx
  800191:	8d 42 01             	lea    0x1(%edx),%eax
  800194:	89 03                	mov    %eax,(%ebx)
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a2:	75 1a                	jne    8001be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	68 ff 00 00 00       	push   $0xff
  8001ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 ed fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 85 01 80 00       	push   $0x800185
  8001f6:	e8 4f 01 00 00       	call   80034a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 92 fe ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 1c             	sub    $0x1c,%esp
  800235:	89 c7                	mov    %eax,%edi
  800237:	89 d6                	mov    %edx,%esi
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 d1                	mov    %edx,%ecx
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800247:	8b 45 10             	mov    0x10(%ebp),%eax
  80024a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800257:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80025a:	72 05                	jb     800261 <printnum+0x35>
  80025c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025f:	77 3e                	ja     80029f <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 18             	pushl  0x18(%ebp)
  800267:	83 eb 01             	sub    $0x1,%ebx
  80026a:	53                   	push   %ebx
  80026b:	50                   	push   %eax
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 70 08 00 00       	call   800af0 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 9e ff ff ff       	call   80022c <printnum>
  80028e:	83 c4 20             	add    $0x20,%esp
  800291:	eb 13                	jmp    8002a6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	ff 75 18             	pushl  0x18(%ebp)
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7f ed                	jg     800293 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 62 09 00 00       	call   800c20 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff d7                	call   *%edi
  8002cb:	83 c4 10             	add    $0x10,%esp
}
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ea:	eb 22                	jmp    80030e <getuint+0x38>
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	74 10                	je     800300 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 0e                	jmp    80030e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800316:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	3b 50 04             	cmp    0x4(%eax),%edx
  80031f:	73 0a                	jae    80032b <sprintputch+0x1b>
		*b->buf++ = ch;
  800321:	8d 4a 01             	lea    0x1(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	88 02                	mov    %al,(%edx)
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800333:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800336:	50                   	push   %eax
  800337:	ff 75 10             	pushl  0x10(%ebp)
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	e8 05 00 00 00       	call   80034a <vprintfmt>
	va_end(ap);
  800345:	83 c4 10             	add    $0x10,%esp
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 2c             	sub    $0x2c,%esp
  800353:	8b 75 08             	mov    0x8(%ebp),%esi
  800356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800359:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035c:	eb 12                	jmp    800370 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035e:	85 c0                	test   %eax,%eax
  800360:	0f 84 90 03 00 00    	je     8006f6 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	53                   	push   %ebx
  80036a:	50                   	push   %eax
  80036b:	ff d6                	call   *%esi
  80036d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800370:	83 c7 01             	add    $0x1,%edi
  800373:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800377:	83 f8 25             	cmp    $0x25,%eax
  80037a:	75 e2                	jne    80035e <vprintfmt+0x14>
  80037c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800380:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800387:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800395:	ba 00 00 00 00       	mov    $0x0,%edx
  80039a:	eb 07                	jmp    8003a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8d 47 01             	lea    0x1(%edi),%eax
  8003a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a9:	0f b6 07             	movzbl (%edi),%eax
  8003ac:	0f b6 c8             	movzbl %al,%ecx
  8003af:	83 e8 23             	sub    $0x23,%eax
  8003b2:	3c 55                	cmp    $0x55,%al
  8003b4:	0f 87 21 03 00 00    	ja     8006db <vprintfmt+0x391>
  8003ba:	0f b6 c0             	movzbl %al,%eax
  8003bd:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cb:	eb d6                	jmp    8003a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003db:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003df:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e5:	83 fa 09             	cmp    $0x9,%edx
  8003e8:	77 39                	ja     800423 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ed:	eb e9                	jmp    8003d8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800400:	eb 27                	jmp    800429 <vprintfmt+0xdf>
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040c:	0f 49 c8             	cmovns %eax,%ecx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800415:	eb 8c                	jmp    8003a3 <vprintfmt+0x59>
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800421:	eb 80                	jmp    8003a3 <vprintfmt+0x59>
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	0f 89 70 ff ff ff    	jns    8003a3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800433:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800440:	e9 5e ff ff ff       	jmp    8003a3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800445:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	e9 53 ff ff ff       	jmp    8003a3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	53                   	push   %ebx
  80045d:	ff 30                	pushl  (%eax)
  80045f:	ff d6                	call   *%esi
			break;
  800461:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800467:	e9 04 ff ff ff       	jmp    800370 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	99                   	cltd   
  800478:	31 d0                	xor    %edx,%eax
  80047a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047c:	83 f8 07             	cmp    $0x7,%eax
  80047f:	7f 0b                	jg     80048c <vprintfmt+0x142>
  800481:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	75 18                	jne    8004a4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048c:	50                   	push   %eax
  80048d:	68 16 0e 80 00       	push   $0x800e16
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 94 fe ff ff       	call   80032d <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 cc fe ff ff       	jmp    800370 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	52                   	push   %edx
  8004a5:	68 1f 0e 80 00       	push   $0x800e1f
  8004aa:	53                   	push   %ebx
  8004ab:	56                   	push   %esi
  8004ac:	e8 7c fe ff ff       	call   80032d <printfmt>
  8004b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b7:	e9 b4 fe ff ff       	jmp    800370 <vprintfmt+0x26>
  8004bc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d0:	85 ff                	test   %edi,%edi
  8004d2:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004d7:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004da:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004de:	0f 84 92 00 00 00    	je     800576 <vprintfmt+0x22c>
  8004e4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e8:	0f 8e 96 00 00 00    	jle    800584 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	51                   	push   %ecx
  8004f2:	57                   	push   %edi
  8004f3:	e8 86 02 00 00       	call   80077e <strnlen>
  8004f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fb:	29 c1                	sub    %eax,%ecx
  8004fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800503:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800507:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	eb 0f                	jmp    800520 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	ff 75 e0             	pushl  -0x20(%ebp)
  800518:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ef 01             	sub    $0x1,%edi
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	85 ff                	test   %edi,%edi
  800522:	7f ed                	jg     800511 <vprintfmt+0x1c7>
  800524:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800527:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	b8 00 00 00 00       	mov    $0x0,%eax
  800531:	0f 49 c1             	cmovns %ecx,%eax
  800534:	29 c1                	sub    %eax,%ecx
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	89 cb                	mov    %ecx,%ebx
  800541:	eb 4d                	jmp    800590 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800543:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800547:	74 1b                	je     800564 <vprintfmt+0x21a>
  800549:	0f be c0             	movsbl %al,%eax
  80054c:	83 e8 20             	sub    $0x20,%eax
  80054f:	83 f8 5e             	cmp    $0x5e,%eax
  800552:	76 10                	jbe    800564 <vprintfmt+0x21a>
					putch('?', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	6a 3f                	push   $0x3f
  80055c:	ff 55 08             	call   *0x8(%ebp)
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	eb 0d                	jmp    800571 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	52                   	push   %edx
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800571:	83 eb 01             	sub    $0x1,%ebx
  800574:	eb 1a                	jmp    800590 <vprintfmt+0x246>
  800576:	89 75 08             	mov    %esi,0x8(%ebp)
  800579:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800582:	eb 0c                	jmp    800590 <vprintfmt+0x246>
  800584:	89 75 08             	mov    %esi,0x8(%ebp)
  800587:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800590:	83 c7 01             	add    $0x1,%edi
  800593:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800597:	0f be d0             	movsbl %al,%edx
  80059a:	85 d2                	test   %edx,%edx
  80059c:	74 23                	je     8005c1 <vprintfmt+0x277>
  80059e:	85 f6                	test   %esi,%esi
  8005a0:	78 a1                	js     800543 <vprintfmt+0x1f9>
  8005a2:	83 ee 01             	sub    $0x1,%esi
  8005a5:	79 9c                	jns    800543 <vprintfmt+0x1f9>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	eb 18                	jmp    8005c9 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 20                	push   $0x20
  8005b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b9:	83 ef 01             	sub    $0x1,%edi
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb 08                	jmp    8005c9 <vprintfmt+0x27f>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f e4                	jg     8005b1 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d0:	e9 9b fd ff ff       	jmp    800370 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d5:	83 fa 01             	cmp    $0x1,%edx
  8005d8:	7e 16                	jle    8005f0 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 08             	lea    0x8(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 50 04             	mov    0x4(%eax),%edx
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ee:	eb 32                	jmp    800622 <vprintfmt+0x2d8>
	else if (lflag)
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	74 18                	je     80060c <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060a:	eb 16                	jmp    800622 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800622:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800625:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800628:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800631:	79 74                	jns    8006a7 <vprintfmt+0x35d>
				putch('-', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 2d                	push   $0x2d
  800639:	ff d6                	call   *%esi
				num = -(long long) num;
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800641:	f7 d8                	neg    %eax
  800643:	83 d2 00             	adc    $0x0,%edx
  800646:	f7 da                	neg    %edx
  800648:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800650:	eb 55                	jmp    8006a7 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 7c fc ff ff       	call   8002d6 <getuint>
			base = 10;
  80065a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065f:	eb 46                	jmp    8006a7 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 6d fc ff ff       	call   8002d6 <getuint>
                        base = 8;
  800669:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80066e:	eb 37                	jmp    8006a7 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 30                	push   $0x30
  800676:	ff d6                	call   *%esi
			putch('x', putdat);
  800678:	83 c4 08             	add    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 78                	push   $0x78
  80067e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800690:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800693:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800698:	eb 0d                	jmp    8006a7 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	e8 34 fc ff ff       	call   8002d6 <getuint>
			base = 16;
  8006a2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a7:	83 ec 0c             	sub    $0xc,%esp
  8006aa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ae:	57                   	push   %edi
  8006af:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b2:	51                   	push   %ecx
  8006b3:	52                   	push   %edx
  8006b4:	50                   	push   %eax
  8006b5:	89 da                	mov    %ebx,%edx
  8006b7:	89 f0                	mov    %esi,%eax
  8006b9:	e8 6e fb ff ff       	call   80022c <printnum>
			break;
  8006be:	83 c4 20             	add    $0x20,%esp
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c4:	e9 a7 fc ff ff       	jmp    800370 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	51                   	push   %ecx
  8006ce:	ff d6                	call   *%esi
			break;
  8006d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d6:	e9 95 fc ff ff       	jmp    800370 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 25                	push   $0x25
  8006e1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	eb 03                	jmp    8006eb <vprintfmt+0x3a1>
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ef:	75 f7                	jne    8006e8 <vprintfmt+0x39e>
  8006f1:	e9 7a fc ff ff       	jmp    800370 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	5f                   	pop    %edi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 18             	sub    $0x18,%esp
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 26                	je     800745 <vsnprintf+0x47>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 22                	jle    800745 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	ff 75 14             	pushl  0x14(%ebp)
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	68 10 03 80 00       	push   $0x800310
  800732:	e8 13 fc ff ff       	call   80034a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 05                	jmp    80074a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800755:	50                   	push   %eax
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 9a ff ff ff       	call   8006fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076c:	b8 00 00 00 00       	mov    $0x0,%eax
  800771:	eb 03                	jmp    800776 <strlen+0x10>
		n++;
  800773:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077a:	75 f7                	jne    800773 <strlen+0xd>
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	ba 00 00 00 00       	mov    $0x0,%edx
  80078c:	eb 03                	jmp    800791 <strnlen+0x13>
		n++;
  80078e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	39 c2                	cmp    %eax,%edx
  800793:	74 08                	je     80079d <strnlen+0x1f>
  800795:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800799:	75 f3                	jne    80078e <strnlen+0x10>
  80079b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a9:	89 c2                	mov    %eax,%edx
  8007ab:	83 c2 01             	add    $0x1,%edx
  8007ae:	83 c1 01             	add    $0x1,%ecx
  8007b1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b8:	84 db                	test   %bl,%bl
  8007ba:	75 ef                	jne    8007ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	53                   	push   %ebx
  8007c7:	e8 9a ff ff ff       	call   800766 <strlen>
  8007cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	01 d8                	add    %ebx,%eax
  8007d4:	50                   	push   %eax
  8007d5:	e8 c5 ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ec:	89 f3                	mov    %esi,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	89 f2                	mov    %esi,%edx
  8007f3:	eb 0f                	jmp    800804 <strncpy+0x23>
		*dst++ = *src;
  8007f5:	83 c2 01             	add    $0x1,%edx
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fe:	80 39 01             	cmpb   $0x1,(%ecx)
  800801:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800804:	39 da                	cmp    %ebx,%edx
  800806:	75 ed                	jne    8007f5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800808:	89 f0                	mov    %esi,%eax
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	8b 55 10             	mov    0x10(%ebp),%edx
  80081c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 21                	je     800843 <strlcpy+0x35>
  800822:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 09                	jmp    800833 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	83 c1 01             	add    $0x1,%ecx
  800830:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800833:	39 c2                	cmp    %eax,%edx
  800835:	74 09                	je     800840 <strlcpy+0x32>
  800837:	0f b6 19             	movzbl (%ecx),%ebx
  80083a:	84 db                	test   %bl,%bl
  80083c:	75 ec                	jne    80082a <strlcpy+0x1c>
  80083e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800840:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800843:	29 f0                	sub    %esi,%eax
}
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800852:	eb 06                	jmp    80085a <strcmp+0x11>
		p++, q++;
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085a:	0f b6 01             	movzbl (%ecx),%eax
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x1c>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 ef                	je     800854 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 c3                	mov    %eax,%ebx
  80087b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087e:	eb 06                	jmp    800886 <strncmp+0x17>
		n--, p++, q++;
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800886:	39 d8                	cmp    %ebx,%eax
  800888:	74 15                	je     80089f <strncmp+0x30>
  80088a:	0f b6 08             	movzbl (%eax),%ecx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	74 04                	je     800895 <strncmp+0x26>
  800891:	3a 0a                	cmp    (%edx),%cl
  800893:	74 eb                	je     800880 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 00             	movzbl (%eax),%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
  80089d:	eb 05                	jmp    8008a4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	eb 07                	jmp    8008ba <strchr+0x13>
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	74 0f                	je     8008c6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 10             	movzbl (%eax),%edx
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f2                	jne    8008b3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 03                	jmp    8008d7 <strfind+0xf>
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 04                	je     8008e2 <strfind+0x1a>
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	75 f2                	jne    8008d4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 36                	je     80092a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fa:	75 28                	jne    800924 <memset+0x40>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 23                	jne    800924 <memset+0x40>
		c &= 0xFF;
  800901:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 18             	shl    $0x18,%esi
  80090f:	89 d0                	mov    %edx,%eax
  800911:	c1 e0 10             	shl    $0x10,%eax
  800914:	09 f0                	or     %esi,%eax
  800916:	09 c2                	or     %eax,%edx
  800918:	89 d0                	mov    %edx,%eax
  80091a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091f:	fc                   	cld    
  800920:	f3 ab                	rep stos %eax,%es:(%edi)
  800922:	eb 06                	jmp    80092a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	fc                   	cld    
  800928:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093f:	39 c6                	cmp    %eax,%esi
  800941:	73 35                	jae    800978 <memmove+0x47>
  800943:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800946:	39 d0                	cmp    %edx,%eax
  800948:	73 2e                	jae    800978 <memmove+0x47>
		s += n;
		d += n;
  80094a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800957:	75 13                	jne    80096c <memmove+0x3b>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0e                	jne    80096c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095e:	83 ef 04             	sub    $0x4,%edi
  800961:	8d 72 fc             	lea    -0x4(%edx),%esi
  800964:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800967:	fd                   	std    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 09                	jmp    800975 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096c:	83 ef 01             	sub    $0x1,%edi
  80096f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800972:	fd                   	std    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800975:	fc                   	cld    
  800976:	eb 1d                	jmp    800995 <memmove+0x64>
  800978:	89 f2                	mov    %esi,%edx
  80097a:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	f6 c2 03             	test   $0x3,%dl
  80097f:	75 0f                	jne    800990 <memmove+0x5f>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 0a                	jne    800990 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800986:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 05                	jmp    800995 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800990:	89 c7                	mov    %eax,%edi
  800992:	fc                   	cld    
  800993:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	ff 75 08             	pushl  0x8(%ebp)
  8009a5:	e8 87 ff ff ff       	call   800931 <memmove>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c6                	mov    %eax,%esi
  8009b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	eb 1a                	jmp    8009d8 <memcmp+0x2c>
		if (*s1 != *s2)
  8009be:	0f b6 08             	movzbl (%eax),%ecx
  8009c1:	0f b6 1a             	movzbl (%edx),%ebx
  8009c4:	38 d9                	cmp    %bl,%cl
  8009c6:	74 0a                	je     8009d2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c8:	0f b6 c1             	movzbl %cl,%eax
  8009cb:	0f b6 db             	movzbl %bl,%ebx
  8009ce:	29 d8                	sub    %ebx,%eax
  8009d0:	eb 0f                	jmp    8009e1 <memcmp+0x35>
		s1++, s2++;
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	39 f0                	cmp    %esi,%eax
  8009da:	75 e2                	jne    8009be <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	eb 07                	jmp    8009fc <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 07                	je     800a00 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	39 d0                	cmp    %edx,%eax
  8009fe:	72 f5                	jb     8009f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	eb 03                	jmp    800a13 <strtol+0x11>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	3c 09                	cmp    $0x9,%al
  800a18:	74 f6                	je     800a10 <strtol+0xe>
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f2                	je     800a10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1e:	3c 2b                	cmp    $0x2b,%al
  800a20:	75 0a                	jne    800a2c <strtol+0x2a>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2a:	eb 10                	jmp    800a3c <strtol+0x3a>
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 07                	jne    800a3c <strtol+0x3a>
		s++, neg = 1;
  800a35:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a38:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	0f 94 c0             	sete   %al
  800a41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a47:	75 19                	jne    800a62 <strtol+0x60>
  800a49:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4c:	75 14                	jne    800a62 <strtol+0x60>
  800a4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a52:	0f 85 82 00 00 00    	jne    800ada <strtol+0xd8>
		s += 2, base = 16;
  800a58:	83 c1 02             	add    $0x2,%ecx
  800a5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a60:	eb 16                	jmp    800a78 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a62:	84 c0                	test   %al,%al
  800a64:	74 12                	je     800a78 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a66:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6e:	75 08                	jne    800a78 <strtol+0x76>
		s++, base = 8;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a80:	0f b6 11             	movzbl (%ecx),%edx
  800a83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 09             	cmp    $0x9,%bl
  800a8b:	77 08                	ja     800a95 <strtol+0x93>
			dig = *s - '0';
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 30             	sub    $0x30,%edx
  800a93:	eb 22                	jmp    800ab7 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 57             	sub    $0x57,%edx
  800aa5:	eb 10                	jmp    800ab7 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aa7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 19             	cmp    $0x19,%bl
  800aaf:	77 16                	ja     800ac7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aba:	7d 0f                	jge    800acb <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac5:	eb b9                	jmp    800a80 <strtol+0x7e>
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	eb 02                	jmp    800acd <strtol+0xcb>
  800acb:	89 c2                	mov    %eax,%edx

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 0d                	je     800ae0 <strtol+0xde>
		*endptr = (char *) s;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad6:	89 0e                	mov    %ecx,(%esi)
  800ad8:	eb 06                	jmp    800ae0 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ada:	84 c0                	test   %al,%al
  800adc:	75 92                	jne    800a70 <strtol+0x6e>
  800ade:	eb 98                	jmp    800a78 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae0:	f7 da                	neg    %edx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 45 c2             	cmovne %edx,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    
  800aec:	66 90                	xchg   %ax,%ax
  800aee:	66 90                	xchg   %ax,%ax

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
