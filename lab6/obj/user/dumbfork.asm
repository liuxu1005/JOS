
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 a2 01 00 00       	call   8001d3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 52 0c 00 00       	call   800c9c <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 c0 24 80 00       	push   $0x8024c0
  800057:	6a 20                	push   $0x20
  800059:	68 d3 24 80 00       	push   $0x8024d3
  80005e:	e8 d0 01 00 00       	call   800233 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 69 0c 00 00       	call   800cdf <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 e3 24 80 00       	push   $0x8024e3
  800083:	6a 22                	push   $0x22
  800085:	68 d3 24 80 00       	push   $0x8024d3
  80008a:	e8 a4 01 00 00       	call   800233 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 83 09 00 00       	call   800a25 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 70 0c 00 00       	call   800d21 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 f4 24 80 00       	push   $0x8024f4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 d3 24 80 00       	push   $0x8024d3
  8000c5:	e8 69 01 00 00       	call   800233 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 07 25 80 00       	push   $0x802507
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 d3 24 80 00       	push   $0x8024d3
  8000f3:	e8 3b 01 00 00       	call   800233 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 5b 0b 00 00       	call   800c5e <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
    
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
    
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 02 0c 00 00       	call   800d63 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 17 25 80 00       	push   $0x802517
  80016e:	6a 4c                	push   $0x4c
  800170:	68 d3 24 80 00       	push   $0x8024d3
  800175:	e8 b9 00 00 00       	call   800233 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800188:	e8 44 ff ff ff       	call   8000d1 <dumbfork>
  80018d:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80018f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800194:	eb 26                	jmp    8001bc <umain+0x39>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800196:	ba 34 25 80 00       	mov    $0x802534,%edx
  80019b:	eb 05                	jmp    8001a2 <umain+0x1f>
  80019d:	ba 2e 25 80 00       	mov    $0x80252e,%edx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	52                   	push   %edx
  8001a6:	53                   	push   %ebx
  8001a7:	68 3b 25 80 00       	push   $0x80253b
  8001ac:	e8 5b 01 00 00       	call   80030c <cprintf>
		sys_yield();
  8001b1:	e8 c7 0a 00 00       	call   800c7d <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b6:	83 c3 01             	add    $0x1,%ebx
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	85 f6                	test   %esi,%esi
  8001be:	74 07                	je     8001c7 <umain+0x44>
  8001c0:	83 fb 09             	cmp    $0x9,%ebx
  8001c3:	7e d1                	jle    800196 <umain+0x13>
  8001c5:	eb 05                	jmp    8001cc <umain+0x49>
  8001c7:	83 fb 13             	cmp    $0x13,%ebx
  8001ca:	7e d1                	jle    80019d <umain+0x1a>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8001de:	e8 7b 0a 00 00       	call   800c5e <sys_getenvid>
  8001e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7e 07                	jle    800200 <libmain+0x2d>
		binaryname = argv[0];
  8001f9:	8b 06                	mov    (%esi),%eax
  8001fb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	e8 79 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  80020a:	e8 0a 00 00 00       	call   800219 <exit>
  80020f:	83 c4 10             	add    $0x10,%esp
}
  800212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021f:	e8 dc 0e 00 00       	call   801100 <close_all>
	sys_env_destroy(0);
  800224:	83 ec 0c             	sub    $0xc,%esp
  800227:	6a 00                	push   $0x0
  800229:	e8 ef 09 00 00       	call   800c1d <sys_env_destroy>
  80022e:	83 c4 10             	add    $0x10,%esp
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800241:	e8 18 0a 00 00       	call   800c5e <sys_getenvid>
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	56                   	push   %esi
  800250:	50                   	push   %eax
  800251:	68 58 25 80 00       	push   $0x802558
  800256:	e8 b1 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025b:	83 c4 18             	add    $0x18,%esp
  80025e:	53                   	push   %ebx
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	e8 54 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800267:	c7 04 24 4b 25 80 00 	movl   $0x80254b,(%esp)
  80026e:	e8 99 00 00 00       	call   80030c <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800276:	cc                   	int3   
  800277:	eb fd                	jmp    800276 <_panic+0x43>

00800279 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	53                   	push   %ebx
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800283:	8b 13                	mov    (%ebx),%edx
  800285:	8d 42 01             	lea    0x1(%edx),%eax
  800288:	89 03                	mov    %eax,(%ebx)
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800291:	3d ff 00 00 00       	cmp    $0xff,%eax
  800296:	75 1a                	jne    8002b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	68 ff 00 00 00       	push   $0xff
  8002a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 37 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	68 79 02 80 00       	push   $0x800279
  8002ea:	e8 4f 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ef:	83 c4 08             	add    $0x8,%esp
  8002f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fe:	50                   	push   %eax
  8002ff:	e8 dc 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  800304:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 9d ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 1c             	sub    $0x1c,%esp
  800329:	89 c7                	mov    %eax,%edi
  80032b:	89 d6                	mov    %edx,%esi
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 55 0c             	mov    0xc(%ebp),%edx
  800333:	89 d1                	mov    %edx,%ecx
  800335:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800338:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033b:	8b 45 10             	mov    0x10(%ebp),%eax
  80033e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800344:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80034e:	72 05                	jb     800355 <printnum+0x35>
  800350:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800353:	77 3e                	ja     800393 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 18             	pushl  0x18(%ebp)
  80035b:	83 eb 01             	sub    $0x1,%ebx
  80035e:	53                   	push   %ebx
  80035f:	50                   	push   %eax
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	ff 75 e4             	pushl  -0x1c(%ebp)
  800366:	ff 75 e0             	pushl  -0x20(%ebp)
  800369:	ff 75 dc             	pushl  -0x24(%ebp)
  80036c:	ff 75 d8             	pushl  -0x28(%ebp)
  80036f:	e8 7c 1e 00 00       	call   8021f0 <__udivdi3>
  800374:	83 c4 18             	add    $0x18,%esp
  800377:	52                   	push   %edx
  800378:	50                   	push   %eax
  800379:	89 f2                	mov    %esi,%edx
  80037b:	89 f8                	mov    %edi,%eax
  80037d:	e8 9e ff ff ff       	call   800320 <printnum>
  800382:	83 c4 20             	add    $0x20,%esp
  800385:	eb 13                	jmp    80039a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	56                   	push   %esi
  80038b:	ff 75 18             	pushl  0x18(%ebp)
  80038e:	ff d7                	call   *%edi
  800390:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800393:	83 eb 01             	sub    $0x1,%ebx
  800396:	85 db                	test   %ebx,%ebx
  800398:	7f ed                	jg     800387 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	56                   	push   %esi
  80039e:	83 ec 04             	sub    $0x4,%esp
  8003a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ad:	e8 6e 1f 00 00       	call   802320 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 7b 25 80 00 	movsbl 0x80257b(%eax),%eax
  8003bc:	50                   	push   %eax
  8003bd:	ff d7                	call   *%edi
  8003bf:	83 c4 10             	add    $0x10,%esp
}
  8003c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 fa 01             	cmp    $0x1,%edx
  8003d0:	7e 0e                	jle    8003e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	8b 52 04             	mov    0x4(%edx),%edx
  8003de:	eb 22                	jmp    800402 <getuint+0x38>
	else if (lflag)
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 10                	je     8003f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	eb 0e                	jmp    800402 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040e:	8b 10                	mov    (%eax),%edx
  800410:	3b 50 04             	cmp    0x4(%eax),%edx
  800413:	73 0a                	jae    80041f <sprintputch+0x1b>
		*b->buf++ = ch;
  800415:	8d 4a 01             	lea    0x1(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	88 02                	mov    %al,(%edx)
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800427:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 05 00 00 00       	call   80043e <vprintfmt>
	va_end(ap);
  800439:	83 c4 10             	add    $0x10,%esp
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 2c             	sub    $0x2c,%esp
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800450:	eb 12                	jmp    800464 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800452:	85 c0                	test   %eax,%eax
  800454:	0f 84 90 03 00 00    	je     8007ea <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	50                   	push   %eax
  80045f:	ff d6                	call   *%esi
  800461:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800464:	83 c7 01             	add    $0x1,%edi
  800467:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046b:	83 f8 25             	cmp    $0x25,%eax
  80046e:	75 e2                	jne    800452 <vprintfmt+0x14>
  800470:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800474:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800482:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	eb 07                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800493:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8d 47 01             	lea    0x1(%edi),%eax
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049d:	0f b6 07             	movzbl (%edi),%eax
  8004a0:	0f b6 c8             	movzbl %al,%ecx
  8004a3:	83 e8 23             	sub    $0x23,%eax
  8004a6:	3c 55                	cmp    $0x55,%al
  8004a8:	0f 87 21 03 00 00    	ja     8007cf <vprintfmt+0x391>
  8004ae:	0f b6 c0             	movzbl %al,%eax
  8004b1:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bf:	eb d6                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d9:	83 fa 09             	cmp    $0x9,%edx
  8004dc:	77 39                	ja     800517 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e1:	eb e9                	jmp    8004cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f4:	eb 27                	jmp    80051d <vprintfmt+0xdf>
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800500:	0f 49 c8             	cmovns %eax,%ecx
  800503:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	eb 8c                	jmp    800497 <vprintfmt+0x59>
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800515:	eb 80                	jmp    800497 <vprintfmt+0x59>
  800517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800521:	0f 89 70 ff ff ff    	jns    800497 <vprintfmt+0x59>
				width = precision, precision = -1;
  800527:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800534:	e9 5e ff ff ff       	jmp    800497 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800539:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053f:	e9 53 ff ff ff       	jmp    800497 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	ff 30                	pushl  (%eax)
  800553:	ff d6                	call   *%esi
			break;
  800555:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055b:	e9 04 ff ff ff       	jmp    800464 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	99                   	cltd   
  80056c:	31 d0                	xor    %edx,%eax
  80056e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800570:	83 f8 0f             	cmp    $0xf,%eax
  800573:	7f 0b                	jg     800580 <vprintfmt+0x142>
  800575:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	75 18                	jne    800598 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800580:	50                   	push   %eax
  800581:	68 93 25 80 00       	push   $0x802593
  800586:	53                   	push   %ebx
  800587:	56                   	push   %esi
  800588:	e8 94 fe ff ff       	call   800421 <printfmt>
  80058d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800593:	e9 cc fe ff ff       	jmp    800464 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800598:	52                   	push   %edx
  800599:	68 79 29 80 00       	push   $0x802979
  80059e:	53                   	push   %ebx
  80059f:	56                   	push   %esi
  8005a0:	e8 7c fe ff ff       	call   800421 <printfmt>
  8005a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 b4 fe ff ff       	jmp    800464 <vprintfmt+0x26>
  8005b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	ba 8c 25 80 00       	mov    $0x80258c,%edx
  8005cb:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8005ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d2:	0f 84 92 00 00 00    	je     80066a <vprintfmt+0x22c>
  8005d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005dc:	0f 8e 96 00 00 00    	jle    800678 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	51                   	push   %ecx
  8005e6:	57                   	push   %edi
  8005e7:	e8 86 02 00 00       	call   800872 <strnlen>
  8005ec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ef:	29 c1                	sub    %eax,%ecx
  8005f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800601:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	eb 0f                	jmp    800614 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	ff 75 e0             	pushl  -0x20(%ebp)
  80060c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 ff                	test   %edi,%edi
  800616:	7f ed                	jg     800605 <vprintfmt+0x1c7>
  800618:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	b8 00 00 00 00       	mov    $0x0,%eax
  800625:	0f 49 c1             	cmovns %ecx,%eax
  800628:	29 c1                	sub    %eax,%ecx
  80062a:	89 75 08             	mov    %esi,0x8(%ebp)
  80062d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800630:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800633:	89 cb                	mov    %ecx,%ebx
  800635:	eb 4d                	jmp    800684 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800637:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063b:	74 1b                	je     800658 <vprintfmt+0x21a>
  80063d:	0f be c0             	movsbl %al,%eax
  800640:	83 e8 20             	sub    $0x20,%eax
  800643:	83 f8 5e             	cmp    $0x5e,%eax
  800646:	76 10                	jbe    800658 <vprintfmt+0x21a>
					putch('?', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	ff 75 0c             	pushl  0xc(%ebp)
  80064e:	6a 3f                	push   $0x3f
  800650:	ff 55 08             	call   *0x8(%ebp)
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 0d                	jmp    800665 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	52                   	push   %edx
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	83 eb 01             	sub    $0x1,%ebx
  800668:	eb 1a                	jmp    800684 <vprintfmt+0x246>
  80066a:	89 75 08             	mov    %esi,0x8(%ebp)
  80066d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800670:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800673:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800676:	eb 0c                	jmp    800684 <vprintfmt+0x246>
  800678:	89 75 08             	mov    %esi,0x8(%ebp)
  80067b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800681:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800684:	83 c7 01             	add    $0x1,%edi
  800687:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068b:	0f be d0             	movsbl %al,%edx
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 23                	je     8006b5 <vprintfmt+0x277>
  800692:	85 f6                	test   %esi,%esi
  800694:	78 a1                	js     800637 <vprintfmt+0x1f9>
  800696:	83 ee 01             	sub    $0x1,%esi
  800699:	79 9c                	jns    800637 <vprintfmt+0x1f9>
  80069b:	89 df                	mov    %ebx,%edi
  80069d:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a3:	eb 18                	jmp    8006bd <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 20                	push   $0x20
  8006ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ad:	83 ef 01             	sub    $0x1,%edi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb 08                	jmp    8006bd <vprintfmt+0x27f>
  8006b5:	89 df                	mov    %ebx,%edi
  8006b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	7f e4                	jg     8006a5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c4:	e9 9b fd ff ff       	jmp    800464 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c9:	83 fa 01             	cmp    $0x1,%edx
  8006cc:	7e 16                	jle    8006e4 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 08             	lea    0x8(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d7:	8b 50 04             	mov    0x4(%eax),%edx
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e2:	eb 32                	jmp    800716 <vprintfmt+0x2d8>
	else if (lflag)
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	74 18                	je     800700 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 c1                	mov    %eax,%ecx
  8006f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fe:	eb 16                	jmp    800716 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 04             	lea    0x4(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070e:	89 c1                	mov    %eax,%ecx
  800710:	c1 f9 1f             	sar    $0x1f,%ecx
  800713:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800716:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800719:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800721:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800725:	79 74                	jns    80079b <vprintfmt+0x35d>
				putch('-', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 2d                	push   $0x2d
  80072d:	ff d6                	call   *%esi
				num = -(long long) num;
  80072f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800732:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800735:	f7 d8                	neg    %eax
  800737:	83 d2 00             	adc    $0x0,%edx
  80073a:	f7 da                	neg    %edx
  80073c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80073f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800744:	eb 55                	jmp    80079b <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 7c fc ff ff       	call   8003ca <getuint>
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800753:	eb 46                	jmp    80079b <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 6d fc ff ff       	call   8003ca <getuint>
                        base = 8;
  80075d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800762:	eb 37                	jmp    80079b <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 30                	push   $0x30
  80076a:	ff d6                	call   *%esi
			putch('x', putdat);
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 78                	push   $0x78
  800772:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800784:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800787:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078c:	eb 0d                	jmp    80079b <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 34 fc ff ff       	call   8003ca <getuint>
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079b:	83 ec 0c             	sub    $0xc,%esp
  80079e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a2:	57                   	push   %edi
  8007a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a6:	51                   	push   %ecx
  8007a7:	52                   	push   %edx
  8007a8:	50                   	push   %eax
  8007a9:	89 da                	mov    %ebx,%edx
  8007ab:	89 f0                	mov    %esi,%eax
  8007ad:	e8 6e fb ff ff       	call   800320 <printnum>
			break;
  8007b2:	83 c4 20             	add    $0x20,%esp
  8007b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b8:	e9 a7 fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	53                   	push   %ebx
  8007c1:	51                   	push   %ecx
  8007c2:	ff d6                	call   *%esi
			break;
  8007c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ca:	e9 95 fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 25                	push   $0x25
  8007d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 03                	jmp    8007df <vprintfmt+0x3a1>
  8007dc:	83 ef 01             	sub    $0x1,%edi
  8007df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e3:	75 f7                	jne    8007dc <vprintfmt+0x39e>
  8007e5:	e9 7a fc ff ff       	jmp    800464 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5f                   	pop    %edi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 18             	sub    $0x18,%esp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800801:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800805:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080f:	85 c0                	test   %eax,%eax
  800811:	74 26                	je     800839 <vsnprintf+0x47>
  800813:	85 d2                	test   %edx,%edx
  800815:	7e 22                	jle    800839 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800817:	ff 75 14             	pushl  0x14(%ebp)
  80081a:	ff 75 10             	pushl  0x10(%ebp)
  80081d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	68 04 04 80 00       	push   $0x800404
  800826:	e8 13 fc ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800834:	83 c4 10             	add    $0x10,%esp
  800837:	eb 05                	jmp    80083e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800849:	50                   	push   %eax
  80084a:	ff 75 10             	pushl  0x10(%ebp)
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 9a ff ff ff       	call   8007f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	eb 03                	jmp    80086a <strlen+0x10>
		n++;
  800867:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086e:	75 f7                	jne    800867 <strlen+0xd>
		n++;
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	ba 00 00 00 00       	mov    $0x0,%edx
  800880:	eb 03                	jmp    800885 <strnlen+0x13>
		n++;
  800882:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 08                	je     800891 <strnlen+0x1f>
  800889:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088d:	75 f3                	jne    800882 <strnlen+0x10>
  80088f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	83 c2 01             	add    $0x1,%edx
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ef                	jne    80089f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ba:	53                   	push   %ebx
  8008bb:	e8 9a ff ff ff       	call   80085a <strlen>
  8008c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c3:	ff 75 0c             	pushl  0xc(%ebp)
  8008c6:	01 d8                	add    %ebx,%eax
  8008c8:	50                   	push   %eax
  8008c9:	e8 c5 ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	89 f3                	mov    %esi,%ebx
  8008e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	89 f2                	mov    %esi,%edx
  8008e7:	eb 0f                	jmp    8008f8 <strncpy+0x23>
		*dst++ = *src;
  8008e9:	83 c2 01             	add    $0x1,%edx
  8008ec:	0f b6 01             	movzbl (%ecx),%eax
  8008ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f8:	39 da                	cmp    %ebx,%edx
  8008fa:	75 ed                	jne    8008e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fc:	89 f0                	mov    %esi,%eax
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	8b 55 10             	mov    0x10(%ebp),%edx
  800910:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800912:	85 d2                	test   %edx,%edx
  800914:	74 21                	je     800937 <strlcpy+0x35>
  800916:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091a:	89 f2                	mov    %esi,%edx
  80091c:	eb 09                	jmp    800927 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091e:	83 c2 01             	add    $0x1,%edx
  800921:	83 c1 01             	add    $0x1,%ecx
  800924:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800927:	39 c2                	cmp    %eax,%edx
  800929:	74 09                	je     800934 <strlcpy+0x32>
  80092b:	0f b6 19             	movzbl (%ecx),%ebx
  80092e:	84 db                	test   %bl,%bl
  800930:	75 ec                	jne    80091e <strlcpy+0x1c>
  800932:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800934:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800937:	29 f0                	sub    %esi,%eax
}
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800946:	eb 06                	jmp    80094e <strcmp+0x11>
		p++, q++;
  800948:	83 c1 01             	add    $0x1,%ecx
  80094b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	84 c0                	test   %al,%al
  800953:	74 04                	je     800959 <strcmp+0x1c>
  800955:	3a 02                	cmp    (%edx),%al
  800957:	74 ef                	je     800948 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 c0             	movzbl %al,%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 c3                	mov    %eax,%ebx
  80096f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800972:	eb 06                	jmp    80097a <strncmp+0x17>
		n--, p++, q++;
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097a:	39 d8                	cmp    %ebx,%eax
  80097c:	74 15                	je     800993 <strncmp+0x30>
  80097e:	0f b6 08             	movzbl (%eax),%ecx
  800981:	84 c9                	test   %cl,%cl
  800983:	74 04                	je     800989 <strncmp+0x26>
  800985:	3a 0a                	cmp    (%edx),%cl
  800987:	74 eb                	je     800974 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800989:	0f b6 00             	movzbl (%eax),%eax
  80098c:	0f b6 12             	movzbl (%edx),%edx
  80098f:	29 d0                	sub    %edx,%eax
  800991:	eb 05                	jmp    800998 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strchr+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0f                	je     8009ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c6:	eb 03                	jmp    8009cb <strfind+0xf>
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ce:	84 d2                	test   %dl,%dl
  8009d0:	74 04                	je     8009d6 <strfind+0x1a>
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	75 f2                	jne    8009c8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 36                	je     800a1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ee:	75 28                	jne    800a18 <memset+0x40>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 23                	jne    800a18 <memset+0x40>
		c &= 0xFF;
  8009f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f9:	89 d3                	mov    %edx,%ebx
  8009fb:	c1 e3 08             	shl    $0x8,%ebx
  8009fe:	89 d6                	mov    %edx,%esi
  800a00:	c1 e6 18             	shl    $0x18,%esi
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	c1 e0 10             	shl    $0x10,%eax
  800a08:	09 f0                	or     %esi,%eax
  800a0a:	09 c2                	or     %eax,%edx
  800a0c:	89 d0                	mov    %edx,%eax
  800a0e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a10:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a13:	fc                   	cld    
  800a14:	f3 ab                	rep stos %eax,%es:(%edi)
  800a16:	eb 06                	jmp    800a1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	fc                   	cld    
  800a1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1e:	89 f8                	mov    %edi,%eax
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5f                   	pop    %edi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a33:	39 c6                	cmp    %eax,%esi
  800a35:	73 35                	jae    800a6c <memmove+0x47>
  800a37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	73 2e                	jae    800a6c <memmove+0x47>
		s += n;
		d += n;
  800a3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4b:	75 13                	jne    800a60 <memmove+0x3b>
  800a4d:	f6 c1 03             	test   $0x3,%cl
  800a50:	75 0e                	jne    800a60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a52:	83 ef 04             	sub    $0x4,%edi
  800a55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a58:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5b:	fd                   	std    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 09                	jmp    800a69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	fd                   	std    
  800a67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a69:	fc                   	cld    
  800a6a:	eb 1d                	jmp    800a89 <memmove+0x64>
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	f6 c2 03             	test   $0x3,%dl
  800a73:	75 0f                	jne    800a84 <memmove+0x5f>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0a                	jne    800a84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 05                	jmp    800a89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	fc                   	cld    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a90:	ff 75 10             	pushl  0x10(%ebp)
  800a93:	ff 75 0c             	pushl  0xc(%ebp)
  800a96:	ff 75 08             	pushl  0x8(%ebp)
  800a99:	e8 87 ff ff ff       	call   800a25 <memmove>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aab:	89 c6                	mov    %eax,%esi
  800aad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab0:	eb 1a                	jmp    800acc <memcmp+0x2c>
		if (*s1 != *s2)
  800ab2:	0f b6 08             	movzbl (%eax),%ecx
  800ab5:	0f b6 1a             	movzbl (%edx),%ebx
  800ab8:	38 d9                	cmp    %bl,%cl
  800aba:	74 0a                	je     800ac6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abc:	0f b6 c1             	movzbl %cl,%eax
  800abf:	0f b6 db             	movzbl %bl,%ebx
  800ac2:	29 d8                	sub    %ebx,%eax
  800ac4:	eb 0f                	jmp    800ad5 <memcmp+0x35>
		s1++, s2++;
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 f0                	cmp    %esi,%eax
  800ace:	75 e2                	jne    800ab2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	eb 07                	jmp    800af0 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	38 08                	cmp    %cl,(%eax)
  800aeb:	74 07                	je     800af4 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	72 f5                	jb     800ae9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 03                	jmp    800b07 <strtol+0x11>
		s++;
  800b04:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	3c 09                	cmp    $0x9,%al
  800b0c:	74 f6                	je     800b04 <strtol+0xe>
  800b0e:	3c 20                	cmp    $0x20,%al
  800b10:	74 f2                	je     800b04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b12:	3c 2b                	cmp    $0x2b,%al
  800b14:	75 0a                	jne    800b20 <strtol+0x2a>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 10                	jmp    800b30 <strtol+0x3a>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b25:	3c 2d                	cmp    $0x2d,%al
  800b27:	75 07                	jne    800b30 <strtol+0x3a>
		s++, neg = 1;
  800b29:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b2c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	0f 94 c0             	sete   %al
  800b35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3b:	75 19                	jne    800b56 <strtol+0x60>
  800b3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b40:	75 14                	jne    800b56 <strtol+0x60>
  800b42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b46:	0f 85 82 00 00 00    	jne    800bce <strtol+0xd8>
		s += 2, base = 16;
  800b4c:	83 c1 02             	add    $0x2,%ecx
  800b4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b54:	eb 16                	jmp    800b6c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b56:	84 c0                	test   %al,%al
  800b58:	74 12                	je     800b6c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b62:	75 08                	jne    800b6c <strtol+0x76>
		s++, base = 8;
  800b64:	83 c1 01             	add    $0x1,%ecx
  800b67:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b74:	0f b6 11             	movzbl (%ecx),%edx
  800b77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 09             	cmp    $0x9,%bl
  800b7f:	77 08                	ja     800b89 <strtol+0x93>
			dig = *s - '0';
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 30             	sub    $0x30,%edx
  800b87:	eb 22                	jmp    800bab <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b89:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 08                	ja     800b9b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 57             	sub    $0x57,%edx
  800b99:	eb 10                	jmp    800bab <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 16                	ja     800bbb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba5:	0f be d2             	movsbl %dl,%edx
  800ba8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bae:	7d 0f                	jge    800bbf <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb9:	eb b9                	jmp    800b74 <strtol+0x7e>
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	eb 02                	jmp    800bc1 <strtol+0xcb>
  800bbf:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc5:	74 0d                	je     800bd4 <strtol+0xde>
		*endptr = (char *) s;
  800bc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bca:	89 0e                	mov    %ecx,(%esi)
  800bcc:	eb 06                	jmp    800bd4 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bce:	84 c0                	test   %al,%al
  800bd0:	75 92                	jne    800b64 <strtol+0x6e>
  800bd2:	eb 98                	jmp    800b6c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 9f 28 80 00       	push   $0x80289f
  800c4a:	6a 22                	push   $0x22
  800c4c:	68 bc 28 80 00       	push   $0x8028bc
  800c51:	e8 dd f5 ff ff       	call   800233 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
{      
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 9f 28 80 00       	push   $0x80289f
  800ccb:	6a 22                	push   $0x22
  800ccd:	68 bc 28 80 00       	push   $0x8028bc
  800cd2:	e8 5c f5 ff ff       	call   800233 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 9f 28 80 00       	push   $0x80289f
  800d0d:	6a 22                	push   $0x22
  800d0f:	68 bc 28 80 00       	push   $0x8028bc
  800d14:	e8 1a f5 ff ff       	call   800233 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 9f 28 80 00       	push   $0x80289f
  800d4f:	6a 22                	push   $0x22
  800d51:	68 bc 28 80 00       	push   $0x8028bc
  800d56:	e8 d8 f4 ff ff       	call   800233 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 9f 28 80 00       	push   $0x80289f
  800d91:	6a 22                	push   $0x22
  800d93:	68 bc 28 80 00       	push   $0x8028bc
  800d98:	e8 96 f4 ff ff       	call   800233 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 09 00 00 00       	mov    $0x9,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 9f 28 80 00       	push   $0x80289f
  800dd3:	6a 22                	push   $0x22
  800dd5:	68 bc 28 80 00       	push   $0x8028bc
  800dda:	e8 54 f4 ff ff       	call   800233 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 9f 28 80 00       	push   $0x80289f
  800e15:	6a 22                	push   $0x22
  800e17:	68 bc 28 80 00       	push   $0x8028bc
  800e1c:	e8 12 f4 ff ff       	call   800233 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 9f 28 80 00       	push   $0x80289f
  800e79:	6a 22                	push   $0x22
  800e7b:	68 bc 28 80 00       	push   $0x8028bc
  800e80:	e8 ae f3 ff ff       	call   800233 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9d:	89 d1                	mov    %edx,%ecx
  800e9f:	89 d3                	mov    %edx,%ebx
  800ea1:	89 d7                	mov    %edx,%edi
  800ea3:	89 d6                	mov    %edx,%esi
  800ea5:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_transmit>:

int
sys_transmit(void *addr)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800eb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eba:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	89 cb                	mov    %ecx,%ebx
  800ec4:	89 cf                	mov    %ecx,%edi
  800ec6:	89 ce                	mov    %ecx,%esi
  800ec8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 17                	jle    800ee5 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 0f                	push   $0xf
  800ed4:	68 9f 28 80 00       	push   $0x80289f
  800ed9:	6a 22                	push   $0x22
  800edb:	68 bc 28 80 00       	push   $0x8028bc
  800ee0:	e8 4e f3 ff ff       	call   800233 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_recv>:

int
sys_recv(void *addr)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ef6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efb:	b8 10 00 00 00       	mov    $0x10,%eax
  800f00:	8b 55 08             	mov    0x8(%ebp),%edx
  800f03:	89 cb                	mov    %ecx,%ebx
  800f05:	89 cf                	mov    %ecx,%edi
  800f07:	89 ce                	mov    %ecx,%esi
  800f09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	7e 17                	jle    800f26 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	50                   	push   %eax
  800f13:	6a 10                	push   $0x10
  800f15:	68 9f 28 80 00       	push   $0x80289f
  800f1a:	6a 22                	push   $0x22
  800f1c:	68 bc 28 80 00       	push   $0x8028bc
  800f21:	e8 0d f3 ff ff       	call   800233 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	05 00 00 00 30       	add    $0x30000000,%eax
  800f39:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800f49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f4e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	c1 ea 16             	shr    $0x16,%edx
  800f65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6c:	f6 c2 01             	test   $0x1,%dl
  800f6f:	74 11                	je     800f82 <fd_alloc+0x2d>
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	c1 ea 0c             	shr    $0xc,%edx
  800f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7d:	f6 c2 01             	test   $0x1,%dl
  800f80:	75 09                	jne    800f8b <fd_alloc+0x36>
			*fd_store = fd;
  800f82:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	eb 17                	jmp    800fa2 <fd_alloc+0x4d>
  800f8b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f90:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f95:	75 c9                	jne    800f60 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f97:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f9d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800faa:	83 f8 1f             	cmp    $0x1f,%eax
  800fad:	77 36                	ja     800fe5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800faf:	c1 e0 0c             	shl    $0xc,%eax
  800fb2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb7:	89 c2                	mov    %eax,%edx
  800fb9:	c1 ea 16             	shr    $0x16,%edx
  800fbc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	74 24                	je     800fec <fd_lookup+0x48>
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	c1 ea 0c             	shr    $0xc,%edx
  800fcd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd4:	f6 c2 01             	test   $0x1,%dl
  800fd7:	74 1a                	je     800ff3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdc:	89 02                	mov    %eax,(%edx)
	return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	eb 13                	jmp    800ff8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fea:	eb 0c                	jmp    800ff8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff1:	eb 05                	jmp    800ff8 <fd_lookup+0x54>
  800ff3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801003:	ba 00 00 00 00       	mov    $0x0,%edx
  801008:	eb 13                	jmp    80101d <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80100a:	39 08                	cmp    %ecx,(%eax)
  80100c:	75 0c                	jne    80101a <dev_lookup+0x20>
			*dev = devtab[i];
  80100e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801011:	89 01                	mov    %eax,(%ecx)
			return 0;
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	eb 36                	jmp    801050 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101a:	83 c2 01             	add    $0x1,%edx
  80101d:	8b 04 95 4c 29 80 00 	mov    0x80294c(,%edx,4),%eax
  801024:	85 c0                	test   %eax,%eax
  801026:	75 e2                	jne    80100a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801028:	a1 08 40 80 00       	mov    0x804008,%eax
  80102d:	8b 40 48             	mov    0x48(%eax),%eax
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	51                   	push   %ecx
  801034:	50                   	push   %eax
  801035:	68 cc 28 80 00       	push   $0x8028cc
  80103a:	e8 cd f2 ff ff       	call   80030c <cprintf>
	*dev = 0;
  80103f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801042:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	83 ec 10             	sub    $0x10,%esp
  80105a:	8b 75 08             	mov    0x8(%ebp),%esi
  80105d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801063:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801064:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80106a:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106d:	50                   	push   %eax
  80106e:	e8 31 ff ff ff       	call   800fa4 <fd_lookup>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 05                	js     80107f <fd_close+0x2d>
	    || fd != fd2)
  80107a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80107d:	74 0c                	je     80108b <fd_close+0x39>
		return (must_exist ? r : 0);
  80107f:	84 db                	test   %bl,%bl
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	0f 44 c2             	cmove  %edx,%eax
  801089:	eb 41                	jmp    8010cc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	ff 36                	pushl  (%esi)
  801094:	e8 61 ff ff ff       	call   800ffa <dev_lookup>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 1a                	js     8010bc <fd_close+0x6a>
		if (dev->dev_close)
  8010a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	74 0b                	je     8010bc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	56                   	push   %esi
  8010b5:	ff d0                	call   *%eax
  8010b7:	89 c3                	mov    %eax,%ebx
  8010b9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	56                   	push   %esi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 5a fc ff ff       	call   800d21 <sys_page_unmap>
	return r;
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	89 d8                	mov    %ebx,%eax
}
  8010cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	ff 75 08             	pushl  0x8(%ebp)
  8010e0:	e8 bf fe ff ff       	call   800fa4 <fd_lookup>
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	83 c4 08             	add    $0x8,%esp
  8010ea:	85 d2                	test   %edx,%edx
  8010ec:	78 10                	js     8010fe <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	6a 01                	push   $0x1
  8010f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f6:	e8 57 ff ff ff       	call   801052 <fd_close>
  8010fb:	83 c4 10             	add    $0x10,%esp
}
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <close_all>:

void
close_all(void)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	53                   	push   %ebx
  801110:	e8 be ff ff ff       	call   8010d3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801115:	83 c3 01             	add    $0x1,%ebx
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	83 fb 20             	cmp    $0x20,%ebx
  80111e:	75 ec                	jne    80110c <close_all+0xc>
		close(i);
}
  801120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 2c             	sub    $0x2c,%esp
  80112e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801131:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	e8 67 fe ff ff       	call   800fa4 <fd_lookup>
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	83 c4 08             	add    $0x8,%esp
  801142:	85 d2                	test   %edx,%edx
  801144:	0f 88 c1 00 00 00    	js     80120b <dup+0xe6>
		return r;
	close(newfdnum);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	56                   	push   %esi
  80114e:	e8 80 ff ff ff       	call   8010d3 <close>

	newfd = INDEX2FD(newfdnum);
  801153:	89 f3                	mov    %esi,%ebx
  801155:	c1 e3 0c             	shl    $0xc,%ebx
  801158:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80115e:	83 c4 04             	add    $0x4,%esp
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	e8 d5 fd ff ff       	call   800f3e <fd2data>
  801169:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80116b:	89 1c 24             	mov    %ebx,(%esp)
  80116e:	e8 cb fd ff ff       	call   800f3e <fd2data>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801179:	89 f8                	mov    %edi,%eax
  80117b:	c1 e8 16             	shr    $0x16,%eax
  80117e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801185:	a8 01                	test   $0x1,%al
  801187:	74 37                	je     8011c0 <dup+0x9b>
  801189:	89 f8                	mov    %edi,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
  80118e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	74 26                	je     8011c0 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80119a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a9:	50                   	push   %eax
  8011aa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011ad:	6a 00                	push   $0x0
  8011af:	57                   	push   %edi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 28 fb ff ff       	call   800cdf <sys_page_map>
  8011b7:	89 c7                	mov    %eax,%edi
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 2e                	js     8011ee <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011c3:	89 d0                	mov    %edx,%eax
  8011c5:	c1 e8 0c             	shr    $0xc,%eax
  8011c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d7:	50                   	push   %eax
  8011d8:	53                   	push   %ebx
  8011d9:	6a 00                	push   $0x0
  8011db:	52                   	push   %edx
  8011dc:	6a 00                	push   $0x0
  8011de:	e8 fc fa ff ff       	call   800cdf <sys_page_map>
  8011e3:	89 c7                	mov    %eax,%edi
  8011e5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011e8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ea:	85 ff                	test   %edi,%edi
  8011ec:	79 1d                	jns    80120b <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	53                   	push   %ebx
  8011f2:	6a 00                	push   $0x0
  8011f4:	e8 28 fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011ff:	6a 00                	push   $0x0
  801201:	e8 1b fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	89 f8                	mov    %edi,%eax
}
  80120b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5f                   	pop    %edi
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	53                   	push   %ebx
  801217:	83 ec 14             	sub    $0x14,%esp
  80121a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	53                   	push   %ebx
  801222:	e8 7d fd ff ff       	call   800fa4 <fd_lookup>
  801227:	83 c4 08             	add    $0x8,%esp
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 6d                	js     80129d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123a:	ff 30                	pushl  (%eax)
  80123c:	e8 b9 fd ff ff       	call   800ffa <dev_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 4c                	js     801294 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801248:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80124b:	8b 42 08             	mov    0x8(%edx),%eax
  80124e:	83 e0 03             	and    $0x3,%eax
  801251:	83 f8 01             	cmp    $0x1,%eax
  801254:	75 21                	jne    801277 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801256:	a1 08 40 80 00       	mov    0x804008,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 10 29 80 00       	push   $0x802910
  801268:	e8 9f f0 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801275:	eb 26                	jmp    80129d <read+0x8a>
	}
	if (!dev->dev_read)
  801277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127a:	8b 40 08             	mov    0x8(%eax),%eax
  80127d:	85 c0                	test   %eax,%eax
  80127f:	74 17                	je     801298 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	52                   	push   %edx
  80128b:	ff d0                	call   *%eax
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb 09                	jmp    80129d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	89 c2                	mov    %eax,%edx
  801296:	eb 05                	jmp    80129d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801298:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80129d:	89 d0                	mov    %edx,%eax
  80129f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	57                   	push   %edi
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b8:	eb 21                	jmp    8012db <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	89 f0                	mov    %esi,%eax
  8012bf:	29 d8                	sub    %ebx,%eax
  8012c1:	50                   	push   %eax
  8012c2:	89 d8                	mov    %ebx,%eax
  8012c4:	03 45 0c             	add    0xc(%ebp),%eax
  8012c7:	50                   	push   %eax
  8012c8:	57                   	push   %edi
  8012c9:	e8 45 ff ff ff       	call   801213 <read>
		if (m < 0)
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 0c                	js     8012e1 <readn+0x3d>
			return m;
		if (m == 0)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 06                	je     8012df <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d9:	01 c3                	add    %eax,%ebx
  8012db:	39 f3                	cmp    %esi,%ebx
  8012dd:	72 db                	jb     8012ba <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8012df:	89 d8                	mov    %ebx,%eax
}
  8012e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 14             	sub    $0x14,%esp
  8012f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	53                   	push   %ebx
  8012f8:	e8 a7 fc ff ff       	call   800fa4 <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	89 c2                	mov    %eax,%edx
  801302:	85 c0                	test   %eax,%eax
  801304:	78 68                	js     80136e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	ff 30                	pushl  (%eax)
  801312:	e8 e3 fc ff ff       	call   800ffa <dev_lookup>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 47                	js     801365 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801325:	75 21                	jne    801348 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801327:	a1 08 40 80 00       	mov    0x804008,%eax
  80132c:	8b 40 48             	mov    0x48(%eax),%eax
  80132f:	83 ec 04             	sub    $0x4,%esp
  801332:	53                   	push   %ebx
  801333:	50                   	push   %eax
  801334:	68 2c 29 80 00       	push   $0x80292c
  801339:	e8 ce ef ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801346:	eb 26                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801348:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134b:	8b 52 0c             	mov    0xc(%edx),%edx
  80134e:	85 d2                	test   %edx,%edx
  801350:	74 17                	je     801369 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	ff 75 10             	pushl  0x10(%ebp)
  801358:	ff 75 0c             	pushl  0xc(%ebp)
  80135b:	50                   	push   %eax
  80135c:	ff d2                	call   *%edx
  80135e:	89 c2                	mov    %eax,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb 09                	jmp    80136e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801365:	89 c2                	mov    %eax,%edx
  801367:	eb 05                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801369:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80136e:	89 d0                	mov    %edx,%eax
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <seek>:

int
seek(int fdnum, off_t offset)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	ff 75 08             	pushl  0x8(%ebp)
  801382:	e8 1d fc ff ff       	call   800fa4 <fd_lookup>
  801387:	83 c4 08             	add    $0x8,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 0e                	js     80139c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80138e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801391:	8b 55 0c             	mov    0xc(%ebp),%edx
  801394:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 14             	sub    $0x14,%esp
  8013a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	53                   	push   %ebx
  8013ad:	e8 f2 fb ff ff       	call   800fa4 <fd_lookup>
  8013b2:	83 c4 08             	add    $0x8,%esp
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 65                	js     801420 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c5:	ff 30                	pushl  (%eax)
  8013c7:	e8 2e fc ff ff       	call   800ffa <dev_lookup>
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 44                	js     801417 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013da:	75 21                	jne    8013fd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013dc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e1:	8b 40 48             	mov    0x48(%eax),%eax
  8013e4:	83 ec 04             	sub    $0x4,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	50                   	push   %eax
  8013e9:	68 ec 28 80 00       	push   $0x8028ec
  8013ee:	e8 19 ef ff ff       	call   80030c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fb:	eb 23                	jmp    801420 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801400:	8b 52 18             	mov    0x18(%edx),%edx
  801403:	85 d2                	test   %edx,%edx
  801405:	74 14                	je     80141b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	50                   	push   %eax
  80140e:	ff d2                	call   *%edx
  801410:	89 c2                	mov    %eax,%edx
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	eb 09                	jmp    801420 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801417:	89 c2                	mov    %eax,%edx
  801419:	eb 05                	jmp    801420 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80141b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801420:	89 d0                	mov    %edx,%eax
  801422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	53                   	push   %ebx
  80142b:	83 ec 14             	sub    $0x14,%esp
  80142e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 67 fb ff ff       	call   800fa4 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 c0                	test   %eax,%eax
  801444:	78 58                	js     80149e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	ff 30                	pushl  (%eax)
  801452:	e8 a3 fb ff ff       	call   800ffa <dev_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 37                	js     801495 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80145e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801461:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801465:	74 32                	je     801499 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801467:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80146a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801471:	00 00 00 
	stat->st_isdir = 0;
  801474:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80147b:	00 00 00 
	stat->st_dev = dev;
  80147e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	53                   	push   %ebx
  801488:	ff 75 f0             	pushl  -0x10(%ebp)
  80148b:	ff 50 14             	call   *0x14(%eax)
  80148e:	89 c2                	mov    %eax,%edx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	eb 09                	jmp    80149e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801495:	89 c2                	mov    %eax,%edx
  801497:	eb 05                	jmp    80149e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801499:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80149e:	89 d0                	mov    %edx,%eax
  8014a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	56                   	push   %esi
  8014a9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	6a 00                	push   $0x0
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 09 02 00 00       	call   8016c0 <open>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 db                	test   %ebx,%ebx
  8014be:	78 1b                	js     8014db <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	ff 75 0c             	pushl  0xc(%ebp)
  8014c6:	53                   	push   %ebx
  8014c7:	e8 5b ff ff ff       	call   801427 <fstat>
  8014cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ce:	89 1c 24             	mov    %ebx,(%esp)
  8014d1:	e8 fd fb ff ff       	call   8010d3 <close>
	return r;
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	89 f0                	mov    %esi,%eax
}
  8014db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
  8014e7:	89 c6                	mov    %eax,%esi
  8014e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f2:	75 12                	jne    801506 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	6a 01                	push   $0x1
  8014f9:	e8 70 0c 00 00       	call   80216e <ipc_find_env>
  8014fe:	a3 00 40 80 00       	mov    %eax,0x804000
  801503:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801506:	6a 07                	push   $0x7
  801508:	68 00 50 80 00       	push   $0x805000
  80150d:	56                   	push   %esi
  80150e:	ff 35 00 40 80 00    	pushl  0x804000
  801514:	e8 01 0c 00 00       	call   80211a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801519:	83 c4 0c             	add    $0xc,%esp
  80151c:	6a 00                	push   $0x0
  80151e:	53                   	push   %ebx
  80151f:	6a 00                	push   $0x0
  801521:	e8 8b 0b 00 00       	call   8020b1 <ipc_recv>
}
  801526:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	8b 40 0c             	mov    0xc(%eax),%eax
  801539:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801541:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 02 00 00 00       	mov    $0x2,%eax
  801550:	e8 8d ff ff ff       	call   8014e2 <fsipc>
}
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155d:	8b 45 08             	mov    0x8(%ebp),%eax
  801560:	8b 40 0c             	mov    0xc(%eax),%eax
  801563:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801568:	ba 00 00 00 00       	mov    $0x0,%edx
  80156d:	b8 06 00 00 00       	mov    $0x6,%eax
  801572:	e8 6b ff ff ff       	call   8014e2 <fsipc>
}
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	8b 40 0c             	mov    0xc(%eax),%eax
  801589:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 05 00 00 00       	mov    $0x5,%eax
  801598:	e8 45 ff ff ff       	call   8014e2 <fsipc>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 d2                	test   %edx,%edx
  8015a1:	78 2c                	js     8015cf <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	68 00 50 80 00       	push   $0x805000
  8015ab:	53                   	push   %ebx
  8015ac:	e8 e2 f2 ff ff       	call   800893 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8015eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8015ee:	eb 3d                	jmp    80162d <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8015f0:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8015f6:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8015fb:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	57                   	push   %edi
  801602:	53                   	push   %ebx
  801603:	68 08 50 80 00       	push   $0x805008
  801608:	e8 18 f4 ff ff       	call   800a25 <memmove>
                fsipcbuf.write.req_n = tmp; 
  80160d:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 04 00 00 00       	mov    $0x4,%eax
  80161d:	e8 c0 fe ff ff       	call   8014e2 <fsipc>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 0d                	js     801636 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801629:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80162b:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80162d:	85 f6                	test   %esi,%esi
  80162f:	75 bf                	jne    8015f0 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801631:	89 d8                	mov    %ebx,%eax
  801633:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	8b 40 0c             	mov    0xc(%eax),%eax
  80164c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801651:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 03 00 00 00       	mov    $0x3,%eax
  801661:	e8 7c fe ff ff       	call   8014e2 <fsipc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 4b                	js     8016b7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80166c:	39 c6                	cmp    %eax,%esi
  80166e:	73 16                	jae    801686 <devfile_read+0x48>
  801670:	68 60 29 80 00       	push   $0x802960
  801675:	68 67 29 80 00       	push   $0x802967
  80167a:	6a 7c                	push   $0x7c
  80167c:	68 7c 29 80 00       	push   $0x80297c
  801681:	e8 ad eb ff ff       	call   800233 <_panic>
	assert(r <= PGSIZE);
  801686:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80168b:	7e 16                	jle    8016a3 <devfile_read+0x65>
  80168d:	68 87 29 80 00       	push   $0x802987
  801692:	68 67 29 80 00       	push   $0x802967
  801697:	6a 7d                	push   $0x7d
  801699:	68 7c 29 80 00       	push   $0x80297c
  80169e:	e8 90 eb ff ff       	call   800233 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	50                   	push   %eax
  8016a7:	68 00 50 80 00       	push   $0x805000
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	e8 71 f3 ff ff       	call   800a25 <memmove>
	return r;
  8016b4:	83 c4 10             	add    $0x10,%esp
}
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 20             	sub    $0x20,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ca:	53                   	push   %ebx
  8016cb:	e8 8a f1 ff ff       	call   80085a <strlen>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d8:	7f 67                	jg     801741 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	e8 6f f8 ff ff       	call   800f55 <fd_alloc>
  8016e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 57                	js     801746 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	68 00 50 80 00       	push   $0x805000
  8016f8:	e8 96 f1 ff ff       	call   800893 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801705:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801708:	b8 01 00 00 00       	mov    $0x1,%eax
  80170d:	e8 d0 fd ff ff       	call   8014e2 <fsipc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	79 14                	jns    80172f <open+0x6f>
		fd_close(fd, 0);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	6a 00                	push   $0x0
  801720:	ff 75 f4             	pushl  -0xc(%ebp)
  801723:	e8 2a f9 ff ff       	call   801052 <fd_close>
		return r;
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 da                	mov    %ebx,%edx
  80172d:	eb 17                	jmp    801746 <open+0x86>
	}

	return fd2num(fd);
  80172f:	83 ec 0c             	sub    $0xc,%esp
  801732:	ff 75 f4             	pushl  -0xc(%ebp)
  801735:	e8 f4 f7 ff ff       	call   800f2e <fd2num>
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	eb 05                	jmp    801746 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801741:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801746:	89 d0                	mov    %edx,%eax
  801748:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 08 00 00 00       	mov    $0x8,%eax
  80175d:	e8 80 fd ff ff       	call   8014e2 <fsipc>
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80176a:	68 93 29 80 00       	push   $0x802993
  80176f:	ff 75 0c             	pushl  0xc(%ebp)
  801772:	e8 1c f1 ff ff       	call   800893 <strcpy>
	return 0;
}
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 10             	sub    $0x10,%esp
  801785:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801788:	53                   	push   %ebx
  801789:	e8 18 0a 00 00       	call   8021a6 <pageref>
  80178e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801796:	83 f8 01             	cmp    $0x1,%eax
  801799:	75 10                	jne    8017ab <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	ff 73 0c             	pushl  0xc(%ebx)
  8017a1:	e8 ca 02 00 00       	call   801a70 <nsipc_close>
  8017a6:	89 c2                	mov    %eax,%edx
  8017a8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8017ab:	89 d0                	mov    %edx,%eax
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017b8:	6a 00                	push   $0x0
  8017ba:	ff 75 10             	pushl  0x10(%ebp)
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	ff 70 0c             	pushl  0xc(%eax)
  8017c6:	e8 82 03 00 00       	call   801b4d <nsipc_send>
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017d3:	6a 00                	push   $0x0
  8017d5:	ff 75 10             	pushl  0x10(%ebp)
  8017d8:	ff 75 0c             	pushl  0xc(%ebp)
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	ff 70 0c             	pushl  0xc(%eax)
  8017e1:	e8 fb 02 00 00       	call   801ae1 <nsipc_recv>
}
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017ee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017f1:	52                   	push   %edx
  8017f2:	50                   	push   %eax
  8017f3:	e8 ac f7 ff ff       	call   800fa4 <fd_lookup>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 17                	js     801816 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801802:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801808:	39 08                	cmp    %ecx,(%eax)
  80180a:	75 05                	jne    801811 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80180c:	8b 40 0c             	mov    0xc(%eax),%eax
  80180f:	eb 05                	jmp    801816 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801811:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 1c             	sub    $0x1c,%esp
  801820:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	e8 2a f7 ff ff       	call   800f55 <fd_alloc>
  80182b:	89 c3                	mov    %eax,%ebx
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	85 c0                	test   %eax,%eax
  801832:	78 1b                	js     80184f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801834:	83 ec 04             	sub    $0x4,%esp
  801837:	68 07 04 00 00       	push   $0x407
  80183c:	ff 75 f4             	pushl  -0xc(%ebp)
  80183f:	6a 00                	push   $0x0
  801841:	e8 56 f4 ff ff       	call   800c9c <sys_page_alloc>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	79 10                	jns    80185f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	56                   	push   %esi
  801853:	e8 18 02 00 00       	call   801a70 <nsipc_close>
		return r;
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	89 d8                	mov    %ebx,%eax
  80185d:	eb 24                	jmp    801883 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80185f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801868:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80186a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186d:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801874:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	52                   	push   %edx
  80187b:	e8 ae f6 ff ff       	call   800f2e <fd2num>
  801880:	83 c4 10             	add    $0x10,%esp
}
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	e8 50 ff ff ff       	call   8017e8 <fd2sockid>
		return r;
  801898:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 1f                	js     8018bd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	ff 75 10             	pushl  0x10(%ebp)
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	50                   	push   %eax
  8018a8:	e8 1c 01 00 00       	call   8019c9 <nsipc_accept>
  8018ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 07                	js     8018bd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018b6:	e8 5d ff ff ff       	call   801818 <alloc_sockfd>
  8018bb:	89 c1                	mov    %eax,%ecx
}
  8018bd:	89 c8                	mov    %ecx,%eax
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	e8 19 ff ff ff       	call   8017e8 <fd2sockid>
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	85 d2                	test   %edx,%edx
  8018d3:	78 12                	js     8018e7 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	ff 75 10             	pushl  0x10(%ebp)
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	52                   	push   %edx
  8018df:	e8 35 01 00 00       	call   801a19 <nsipc_bind>
  8018e4:	83 c4 10             	add    $0x10,%esp
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <shutdown>:

int
shutdown(int s, int how)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	e8 f1 fe ff ff       	call   8017e8 <fd2sockid>
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	85 d2                	test   %edx,%edx
  8018fb:	78 0f                	js     80190c <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	ff 75 0c             	pushl  0xc(%ebp)
  801903:	52                   	push   %edx
  801904:	e8 45 01 00 00       	call   801a4e <nsipc_shutdown>
  801909:	83 c4 10             	add    $0x10,%esp
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	e8 cc fe ff ff       	call   8017e8 <fd2sockid>
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	85 d2                	test   %edx,%edx
  801920:	78 12                	js     801934 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	ff 75 10             	pushl  0x10(%ebp)
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	52                   	push   %edx
  80192c:	e8 59 01 00 00       	call   801a8a <nsipc_connect>
  801931:	83 c4 10             	add    $0x10,%esp
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <listen>:

int
listen(int s, int backlog)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	e8 a4 fe ff ff       	call   8017e8 <fd2sockid>
  801944:	89 c2                	mov    %eax,%edx
  801946:	85 d2                	test   %edx,%edx
  801948:	78 0f                	js     801959 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	52                   	push   %edx
  801951:	e8 69 01 00 00       	call   801abf <nsipc_listen>
  801956:	83 c4 10             	add    $0x10,%esp
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801961:	ff 75 10             	pushl  0x10(%ebp)
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	ff 75 08             	pushl  0x8(%ebp)
  80196a:	e8 3c 02 00 00       	call   801bab <nsipc_socket>
  80196f:	89 c2                	mov    %eax,%edx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 d2                	test   %edx,%edx
  801976:	78 05                	js     80197d <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801978:	e8 9b fe ff ff       	call   801818 <alloc_sockfd>
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	83 ec 04             	sub    $0x4,%esp
  801986:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801988:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80198f:	75 12                	jne    8019a3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	6a 02                	push   $0x2
  801996:	e8 d3 07 00 00       	call   80216e <ipc_find_env>
  80199b:	a3 04 40 80 00       	mov    %eax,0x804004
  8019a0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019a3:	6a 07                	push   $0x7
  8019a5:	68 00 60 80 00       	push   $0x806000
  8019aa:	53                   	push   %ebx
  8019ab:	ff 35 04 40 80 00    	pushl  0x804004
  8019b1:	e8 64 07 00 00       	call   80211a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019b6:	83 c4 0c             	add    $0xc,%esp
  8019b9:	6a 00                	push   $0x0
  8019bb:	6a 00                	push   $0x0
  8019bd:	6a 00                	push   $0x0
  8019bf:	e8 ed 06 00 00       	call   8020b1 <ipc_recv>
}
  8019c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019d9:	8b 06                	mov    (%esi),%eax
  8019db:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e5:	e8 95 ff ff ff       	call   80197f <nsipc>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 20                	js     801a10 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	ff 35 10 60 80 00    	pushl  0x806010
  8019f9:	68 00 60 80 00       	push   $0x806000
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	e8 1f f0 ff ff       	call   800a25 <memmove>
		*addrlen = ret->ret_addrlen;
  801a06:	a1 10 60 80 00       	mov    0x806010,%eax
  801a0b:	89 06                	mov    %eax,(%esi)
  801a0d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a10:	89 d8                	mov    %ebx,%eax
  801a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a2b:	53                   	push   %ebx
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	68 04 60 80 00       	push   $0x806004
  801a34:	e8 ec ef ff ff       	call   800a25 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a39:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a3f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a44:	e8 36 ff ff ff       	call   80197f <nsipc>
}
  801a49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a64:	b8 03 00 00 00       	mov    $0x3,%eax
  801a69:	e8 11 ff ff ff       	call   80197f <nsipc>
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <nsipc_close>:

int
nsipc_close(int s)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a7e:	b8 04 00 00 00       	mov    $0x4,%eax
  801a83:	e8 f7 fe ff ff       	call   80197f <nsipc>
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a9c:	53                   	push   %ebx
  801a9d:	ff 75 0c             	pushl  0xc(%ebp)
  801aa0:	68 04 60 80 00       	push   $0x806004
  801aa5:	e8 7b ef ff ff       	call   800a25 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801aaa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ab0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab5:	e8 c5 fe ff ff       	call   80197f <nsipc>
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ad5:	b8 06 00 00 00       	mov    $0x6,%eax
  801ada:	e8 a0 fe ff ff       	call   80197f <nsipc>
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801af1:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801af7:	8b 45 14             	mov    0x14(%ebp),%eax
  801afa:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aff:	b8 07 00 00 00       	mov    $0x7,%eax
  801b04:	e8 76 fe ff ff       	call   80197f <nsipc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 35                	js     801b44 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b0f:	39 f0                	cmp    %esi,%eax
  801b11:	7f 07                	jg     801b1a <nsipc_recv+0x39>
  801b13:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b18:	7e 16                	jle    801b30 <nsipc_recv+0x4f>
  801b1a:	68 9f 29 80 00       	push   $0x80299f
  801b1f:	68 67 29 80 00       	push   $0x802967
  801b24:	6a 62                	push   $0x62
  801b26:	68 b4 29 80 00       	push   $0x8029b4
  801b2b:	e8 03 e7 ff ff       	call   800233 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	50                   	push   %eax
  801b34:	68 00 60 80 00       	push   $0x806000
  801b39:	ff 75 0c             	pushl  0xc(%ebp)
  801b3c:	e8 e4 ee ff ff       	call   800a25 <memmove>
  801b41:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	53                   	push   %ebx
  801b51:	83 ec 04             	sub    $0x4,%esp
  801b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b5f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b65:	7e 16                	jle    801b7d <nsipc_send+0x30>
  801b67:	68 c0 29 80 00       	push   $0x8029c0
  801b6c:	68 67 29 80 00       	push   $0x802967
  801b71:	6a 6d                	push   $0x6d
  801b73:	68 b4 29 80 00       	push   $0x8029b4
  801b78:	e8 b6 e6 ff ff       	call   800233 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	53                   	push   %ebx
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	68 0c 60 80 00       	push   $0x80600c
  801b89:	e8 97 ee ff ff       	call   800a25 <memmove>
	nsipcbuf.send.req_size = size;
  801b8e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b94:	8b 45 14             	mov    0x14(%ebp),%eax
  801b97:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b9c:	b8 08 00 00 00       	mov    $0x8,%eax
  801ba1:	e8 d9 fd ff ff       	call   80197f <nsipc>
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bc9:	b8 09 00 00 00       	mov    $0x9,%eax
  801bce:	e8 ac fd ff ff       	call   80197f <nsipc>
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	ff 75 08             	pushl  0x8(%ebp)
  801be3:	e8 56 f3 ff ff       	call   800f3e <fd2data>
  801be8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bea:	83 c4 08             	add    $0x8,%esp
  801bed:	68 cc 29 80 00       	push   $0x8029cc
  801bf2:	53                   	push   %ebx
  801bf3:	e8 9b ec ff ff       	call   800893 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bf8:	8b 56 04             	mov    0x4(%esi),%edx
  801bfb:	89 d0                	mov    %edx,%eax
  801bfd:	2b 06                	sub    (%esi),%eax
  801bff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c0c:	00 00 00 
	stat->st_dev = &devpipe;
  801c0f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c16:	30 80 00 
	return 0;
}
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c21:	5b                   	pop    %ebx
  801c22:	5e                   	pop    %esi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c2f:	53                   	push   %ebx
  801c30:	6a 00                	push   $0x0
  801c32:	e8 ea f0 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c37:	89 1c 24             	mov    %ebx,(%esp)
  801c3a:	e8 ff f2 ff ff       	call   800f3e <fd2data>
  801c3f:	83 c4 08             	add    $0x8,%esp
  801c42:	50                   	push   %eax
  801c43:	6a 00                	push   $0x0
  801c45:	e8 d7 f0 ff ff       	call   800d21 <sys_page_unmap>
}
  801c4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 1c             	sub    $0x1c,%esp
  801c58:	89 c6                	mov    %eax,%esi
  801c5a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c5d:	a1 08 40 80 00       	mov    0x804008,%eax
  801c62:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c65:	83 ec 0c             	sub    $0xc,%esp
  801c68:	56                   	push   %esi
  801c69:	e8 38 05 00 00       	call   8021a6 <pageref>
  801c6e:	89 c7                	mov    %eax,%edi
  801c70:	83 c4 04             	add    $0x4,%esp
  801c73:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c76:	e8 2b 05 00 00       	call   8021a6 <pageref>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	39 c7                	cmp    %eax,%edi
  801c80:	0f 94 c2             	sete   %dl
  801c83:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c86:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801c8c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c8f:	39 fb                	cmp    %edi,%ebx
  801c91:	74 19                	je     801cac <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801c93:	84 d2                	test   %dl,%dl
  801c95:	74 c6                	je     801c5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c97:	8b 51 58             	mov    0x58(%ecx),%edx
  801c9a:	50                   	push   %eax
  801c9b:	52                   	push   %edx
  801c9c:	53                   	push   %ebx
  801c9d:	68 d3 29 80 00       	push   $0x8029d3
  801ca2:	e8 65 e6 ff ff       	call   80030c <cprintf>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	eb b1                	jmp    801c5d <_pipeisclosed+0xe>
	}
}
  801cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	57                   	push   %edi
  801cb8:	56                   	push   %esi
  801cb9:	53                   	push   %ebx
  801cba:	83 ec 28             	sub    $0x28,%esp
  801cbd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cc0:	56                   	push   %esi
  801cc1:	e8 78 f2 ff ff       	call   800f3e <fd2data>
  801cc6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd0:	eb 4b                	jmp    801d1d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cd2:	89 da                	mov    %ebx,%edx
  801cd4:	89 f0                	mov    %esi,%eax
  801cd6:	e8 74 ff ff ff       	call   801c4f <_pipeisclosed>
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	75 48                	jne    801d27 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cdf:	e8 99 ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce7:	8b 0b                	mov    (%ebx),%ecx
  801ce9:	8d 51 20             	lea    0x20(%ecx),%edx
  801cec:	39 d0                	cmp    %edx,%eax
  801cee:	73 e2                	jae    801cd2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cf7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cfa:	89 c2                	mov    %eax,%edx
  801cfc:	c1 fa 1f             	sar    $0x1f,%edx
  801cff:	89 d1                	mov    %edx,%ecx
  801d01:	c1 e9 1b             	shr    $0x1b,%ecx
  801d04:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d07:	83 e2 1f             	and    $0x1f,%edx
  801d0a:	29 ca                	sub    %ecx,%edx
  801d0c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d10:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d14:	83 c0 01             	add    $0x1,%eax
  801d17:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1a:	83 c7 01             	add    $0x1,%edi
  801d1d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d20:	75 c2                	jne    801ce4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d22:	8b 45 10             	mov    0x10(%ebp),%eax
  801d25:	eb 05                	jmp    801d2c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	57                   	push   %edi
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	83 ec 18             	sub    $0x18,%esp
  801d3d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d40:	57                   	push   %edi
  801d41:	e8 f8 f1 ff ff       	call   800f3e <fd2data>
  801d46:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d50:	eb 3d                	jmp    801d8f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d52:	85 db                	test   %ebx,%ebx
  801d54:	74 04                	je     801d5a <devpipe_read+0x26>
				return i;
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	eb 44                	jmp    801d9e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d5a:	89 f2                	mov    %esi,%edx
  801d5c:	89 f8                	mov    %edi,%eax
  801d5e:	e8 ec fe ff ff       	call   801c4f <_pipeisclosed>
  801d63:	85 c0                	test   %eax,%eax
  801d65:	75 32                	jne    801d99 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d67:	e8 11 ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d6c:	8b 06                	mov    (%esi),%eax
  801d6e:	3b 46 04             	cmp    0x4(%esi),%eax
  801d71:	74 df                	je     801d52 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d73:	99                   	cltd   
  801d74:	c1 ea 1b             	shr    $0x1b,%edx
  801d77:	01 d0                	add    %edx,%eax
  801d79:	83 e0 1f             	and    $0x1f,%eax
  801d7c:	29 d0                	sub    %edx,%eax
  801d7e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d86:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d89:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8c:	83 c3 01             	add    $0x1,%ebx
  801d8f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d92:	75 d8                	jne    801d6c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d94:	8b 45 10             	mov    0x10(%ebp),%eax
  801d97:	eb 05                	jmp    801d9e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	56                   	push   %esi
  801daa:	53                   	push   %ebx
  801dab:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db1:	50                   	push   %eax
  801db2:	e8 9e f1 ff ff       	call   800f55 <fd_alloc>
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	89 c2                	mov    %eax,%edx
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	0f 88 2c 01 00 00    	js     801ef0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	68 07 04 00 00       	push   $0x407
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 c6 ee ff ff       	call   800c9c <sys_page_alloc>
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	0f 88 0d 01 00 00    	js     801ef0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	e8 66 f1 ff ff       	call   800f55 <fd_alloc>
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	85 c0                	test   %eax,%eax
  801df6:	0f 88 e2 00 00 00    	js     801ede <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	68 07 04 00 00       	push   $0x407
  801e04:	ff 75 f0             	pushl  -0x10(%ebp)
  801e07:	6a 00                	push   $0x0
  801e09:	e8 8e ee ff ff       	call   800c9c <sys_page_alloc>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	0f 88 c3 00 00 00    	js     801ede <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	e8 18 f1 ff ff       	call   800f3e <fd2data>
  801e26:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e28:	83 c4 0c             	add    $0xc,%esp
  801e2b:	68 07 04 00 00       	push   $0x407
  801e30:	50                   	push   %eax
  801e31:	6a 00                	push   $0x0
  801e33:	e8 64 ee ff ff       	call   800c9c <sys_page_alloc>
  801e38:	89 c3                	mov    %eax,%ebx
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	0f 88 89 00 00 00    	js     801ece <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e45:	83 ec 0c             	sub    $0xc,%esp
  801e48:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4b:	e8 ee f0 ff ff       	call   800f3e <fd2data>
  801e50:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e57:	50                   	push   %eax
  801e58:	6a 00                	push   $0x0
  801e5a:	56                   	push   %esi
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 7d ee ff ff       	call   800cdf <sys_page_map>
  801e62:	89 c3                	mov    %eax,%ebx
  801e64:	83 c4 20             	add    $0x20,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 55                	js     801ec0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e6b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e74:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e79:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e80:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e89:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	e8 8e f0 ff ff       	call   800f2e <fd2num>
  801ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea5:	83 c4 04             	add    $0x4,%esp
  801ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eab:	e8 7e f0 ff ff       	call   800f2e <fd2num>
  801eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebe:	eb 30                	jmp    801ef0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ec0:	83 ec 08             	sub    $0x8,%esp
  801ec3:	56                   	push   %esi
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 56 ee ff ff       	call   800d21 <sys_page_unmap>
  801ecb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ece:	83 ec 08             	sub    $0x8,%esp
  801ed1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 46 ee ff ff       	call   800d21 <sys_page_unmap>
  801edb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee4:	6a 00                	push   $0x0
  801ee6:	e8 36 ee ff ff       	call   800d21 <sys_page_unmap>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ef0:	89 d0                	mov    %edx,%eax
  801ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f02:	50                   	push   %eax
  801f03:	ff 75 08             	pushl  0x8(%ebp)
  801f06:	e8 99 f0 ff ff       	call   800fa4 <fd_lookup>
  801f0b:	89 c2                	mov    %eax,%edx
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 d2                	test   %edx,%edx
  801f12:	78 18                	js     801f2c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1a:	e8 1f f0 ff ff       	call   800f3e <fd2data>
	return _pipeisclosed(fd, p);
  801f1f:	89 c2                	mov    %eax,%edx
  801f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f24:	e8 26 fd ff ff       	call   801c4f <_pipeisclosed>
  801f29:	83 c4 10             	add    $0x10,%esp
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f31:	b8 00 00 00 00       	mov    $0x0,%eax
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f3e:	68 eb 29 80 00       	push   $0x8029eb
  801f43:	ff 75 0c             	pushl  0xc(%ebp)
  801f46:	e8 48 e9 ff ff       	call   800893 <strcpy>
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f69:	eb 2d                	jmp    801f98 <devcons_write+0x46>
		m = n - tot;
  801f6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f6e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f70:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f73:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f78:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f7b:	83 ec 04             	sub    $0x4,%esp
  801f7e:	53                   	push   %ebx
  801f7f:	03 45 0c             	add    0xc(%ebp),%eax
  801f82:	50                   	push   %eax
  801f83:	57                   	push   %edi
  801f84:	e8 9c ea ff ff       	call   800a25 <memmove>
		sys_cputs(buf, m);
  801f89:	83 c4 08             	add    $0x8,%esp
  801f8c:	53                   	push   %ebx
  801f8d:	57                   	push   %edi
  801f8e:	e8 4d ec ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f93:	01 de                	add    %ebx,%esi
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	89 f0                	mov    %esi,%eax
  801f9a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f9d:	72 cc                	jb     801f6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801fb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb6:	75 07                	jne    801fbf <devcons_read+0x18>
  801fb8:	eb 28                	jmp    801fe2 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fba:	e8 be ec ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fbf:	e8 3a ec ff ff       	call   800bfe <sys_cgetc>
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	74 f2                	je     801fba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 16                	js     801fe2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fcc:	83 f8 04             	cmp    $0x4,%eax
  801fcf:	74 0c                	je     801fdd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd4:	88 02                	mov    %al,(%edx)
	return 1;
  801fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdb:	eb 05                	jmp    801fe2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fdd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ff0:	6a 01                	push   $0x1
  801ff2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	e8 e5 eb ff ff       	call   800be0 <sys_cputs>
  801ffb:	83 c4 10             	add    $0x10,%esp
}
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <getchar>:

int
getchar(void)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802006:	6a 01                	push   $0x1
  802008:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	6a 00                	push   $0x0
  80200e:	e8 00 f2 ff ff       	call   801213 <read>
	if (r < 0)
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	85 c0                	test   %eax,%eax
  802018:	78 0f                	js     802029 <getchar+0x29>
		return r;
	if (r < 1)
  80201a:	85 c0                	test   %eax,%eax
  80201c:	7e 06                	jle    802024 <getchar+0x24>
		return -E_EOF;
	return c;
  80201e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802022:	eb 05                	jmp    802029 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802024:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	ff 75 08             	pushl  0x8(%ebp)
  802038:	e8 67 ef ff ff       	call   800fa4 <fd_lookup>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	78 11                	js     802055 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80204d:	39 10                	cmp    %edx,(%eax)
  80204f:	0f 94 c0             	sete   %al
  802052:	0f b6 c0             	movzbl %al,%eax
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <opencons>:

int
opencons(void)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80205d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802060:	50                   	push   %eax
  802061:	e8 ef ee ff ff       	call   800f55 <fd_alloc>
  802066:	83 c4 10             	add    $0x10,%esp
		return r;
  802069:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 3e                	js     8020ad <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80206f:	83 ec 04             	sub    $0x4,%esp
  802072:	68 07 04 00 00       	push   $0x407
  802077:	ff 75 f4             	pushl  -0xc(%ebp)
  80207a:	6a 00                	push   $0x0
  80207c:	e8 1b ec ff ff       	call   800c9c <sys_page_alloc>
  802081:	83 c4 10             	add    $0x10,%esp
		return r;
  802084:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802086:	85 c0                	test   %eax,%eax
  802088:	78 23                	js     8020ad <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80208a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802093:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80209f:	83 ec 0c             	sub    $0xc,%esp
  8020a2:	50                   	push   %eax
  8020a3:	e8 86 ee ff ff       	call   800f2e <fd2num>
  8020a8:	89 c2                	mov    %eax,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
}
  8020ad:	89 d0                	mov    %edx,%eax
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020c6:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8020c9:	83 ec 0c             	sub    $0xc,%esp
  8020cc:	50                   	push   %eax
  8020cd:	e8 7a ed ff ff       	call   800e4c <sys_ipc_recv>
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	79 16                	jns    8020ef <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8020d9:	85 f6                	test   %esi,%esi
  8020db:	74 06                	je     8020e3 <ipc_recv+0x32>
  8020dd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8020e3:	85 db                	test   %ebx,%ebx
  8020e5:	74 2c                	je     802113 <ipc_recv+0x62>
  8020e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020ed:	eb 24                	jmp    802113 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8020ef:	85 f6                	test   %esi,%esi
  8020f1:	74 0a                	je     8020fd <ipc_recv+0x4c>
  8020f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8020f8:	8b 40 74             	mov    0x74(%eax),%eax
  8020fb:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8020fd:	85 db                	test   %ebx,%ebx
  8020ff:	74 0a                	je     80210b <ipc_recv+0x5a>
  802101:	a1 08 40 80 00       	mov    0x804008,%eax
  802106:	8b 40 78             	mov    0x78(%eax),%eax
  802109:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80210b:	a1 08 40 80 00       	mov    0x804008,%eax
  802110:	8b 40 70             	mov    0x70(%eax),%eax
}
  802113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802116:	5b                   	pop    %ebx
  802117:	5e                   	pop    %esi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	8b 7d 08             	mov    0x8(%ebp),%edi
  802126:	8b 75 0c             	mov    0xc(%ebp),%esi
  802129:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80212c:	85 db                	test   %ebx,%ebx
  80212e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802133:	0f 44 d8             	cmove  %eax,%ebx
  802136:	eb 1c                	jmp    802154 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802138:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213b:	74 12                	je     80214f <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80213d:	50                   	push   %eax
  80213e:	68 f7 29 80 00       	push   $0x8029f7
  802143:	6a 39                	push   $0x39
  802145:	68 12 2a 80 00       	push   $0x802a12
  80214a:	e8 e4 e0 ff ff       	call   800233 <_panic>
                 sys_yield();
  80214f:	e8 29 eb ff ff       	call   800c7d <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802154:	ff 75 14             	pushl  0x14(%ebp)
  802157:	53                   	push   %ebx
  802158:	56                   	push   %esi
  802159:	57                   	push   %edi
  80215a:	e8 ca ec ff ff       	call   800e29 <sys_ipc_try_send>
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	85 c0                	test   %eax,%eax
  802164:	78 d2                	js     802138 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802174:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802179:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80217c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802182:	8b 52 50             	mov    0x50(%edx),%edx
  802185:	39 ca                	cmp    %ecx,%edx
  802187:	75 0d                	jne    802196 <ipc_find_env+0x28>
			return envs[i].env_id;
  802189:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80218c:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802191:	8b 40 08             	mov    0x8(%eax),%eax
  802194:	eb 0e                	jmp    8021a4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802196:	83 c0 01             	add    $0x1,%eax
  802199:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219e:	75 d9                	jne    802179 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a0:	66 b8 00 00          	mov    $0x0,%ax
}
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    

008021a6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ac:	89 d0                	mov    %edx,%eax
  8021ae:	c1 e8 16             	shr    $0x16,%eax
  8021b1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021bd:	f6 c1 01             	test   $0x1,%cl
  8021c0:	74 1d                	je     8021df <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c2:	c1 ea 0c             	shr    $0xc,%edx
  8021c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021cc:	f6 c2 01             	test   $0x1,%dl
  8021cf:	74 0e                	je     8021df <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d1:	c1 ea 0c             	shr    $0xc,%edx
  8021d4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021db:	ef 
  8021dc:	0f b7 c0             	movzwl %ax,%eax
}
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
  8021e1:	66 90                	xchg   %ax,%ax
  8021e3:	66 90                	xchg   %ax,%ax
  8021e5:	66 90                	xchg   %ax,%ax
  8021e7:	66 90                	xchg   %ax,%ax
  8021e9:	66 90                	xchg   %ax,%ax
  8021eb:	66 90                	xchg   %ax,%ax
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	83 ec 10             	sub    $0x10,%esp
  8021f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8021fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8021fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802202:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802206:	85 d2                	test   %edx,%edx
  802208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80220c:	89 34 24             	mov    %esi,(%esp)
  80220f:	89 c8                	mov    %ecx,%eax
  802211:	75 35                	jne    802248 <__udivdi3+0x58>
  802213:	39 f1                	cmp    %esi,%ecx
  802215:	0f 87 bd 00 00 00    	ja     8022d8 <__udivdi3+0xe8>
  80221b:	85 c9                	test   %ecx,%ecx
  80221d:	89 cd                	mov    %ecx,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f1                	div    %ecx
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 f8                	mov    %edi,%eax
  802236:	f7 f5                	div    %ebp
  802238:	89 f2                	mov    %esi,%edx
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	3b 14 24             	cmp    (%esp),%edx
  80224b:	77 7b                	ja     8022c8 <__udivdi3+0xd8>
  80224d:	0f bd f2             	bsr    %edx,%esi
  802250:	83 f6 1f             	xor    $0x1f,%esi
  802253:	0f 84 97 00 00 00    	je     8022f0 <__udivdi3+0x100>
  802259:	bd 20 00 00 00       	mov    $0x20,%ebp
  80225e:	89 d7                	mov    %edx,%edi
  802260:	89 f1                	mov    %esi,%ecx
  802262:	29 f5                	sub    %esi,%ebp
  802264:	d3 e7                	shl    %cl,%edi
  802266:	89 c2                	mov    %eax,%edx
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	d3 ea                	shr    %cl,%edx
  80226c:	89 f1                	mov    %esi,%ecx
  80226e:	09 fa                	or     %edi,%edx
  802270:	8b 3c 24             	mov    (%esp),%edi
  802273:	d3 e0                	shl    %cl,%eax
  802275:	89 54 24 08          	mov    %edx,0x8(%esp)
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802283:	89 fa                	mov    %edi,%edx
  802285:	d3 ea                	shr    %cl,%edx
  802287:	89 f1                	mov    %esi,%ecx
  802289:	d3 e7                	shl    %cl,%edi
  80228b:	89 e9                	mov    %ebp,%ecx
  80228d:	d3 e8                	shr    %cl,%eax
  80228f:	09 c7                	or     %eax,%edi
  802291:	89 f8                	mov    %edi,%eax
  802293:	f7 74 24 08          	divl   0x8(%esp)
  802297:	89 d5                	mov    %edx,%ebp
  802299:	89 c7                	mov    %eax,%edi
  80229b:	f7 64 24 0c          	mull   0xc(%esp)
  80229f:	39 d5                	cmp    %edx,%ebp
  8022a1:	89 14 24             	mov    %edx,(%esp)
  8022a4:	72 11                	jb     8022b7 <__udivdi3+0xc7>
  8022a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022aa:	89 f1                	mov    %esi,%ecx
  8022ac:	d3 e2                	shl    %cl,%edx
  8022ae:	39 c2                	cmp    %eax,%edx
  8022b0:	73 5e                	jae    802310 <__udivdi3+0x120>
  8022b2:	3b 2c 24             	cmp    (%esp),%ebp
  8022b5:	75 59                	jne    802310 <__udivdi3+0x120>
  8022b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8022ba:	31 f6                	xor    %esi,%esi
  8022bc:	89 f2                	mov    %esi,%edx
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	31 f6                	xor    %esi,%esi
  8022ca:	31 c0                	xor    %eax,%eax
  8022cc:	89 f2                	mov    %esi,%edx
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	31 f6                	xor    %esi,%esi
  8022dc:	89 f8                	mov    %edi,%eax
  8022de:	f7 f1                	div    %ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	83 c4 10             	add    $0x10,%esp
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f4:	76 0b                	jbe    802301 <__udivdi3+0x111>
  8022f6:	31 c0                	xor    %eax,%eax
  8022f8:	3b 14 24             	cmp    (%esp),%edx
  8022fb:	0f 83 37 ff ff ff    	jae    802238 <__udivdi3+0x48>
  802301:	b8 01 00 00 00       	mov    $0x1,%eax
  802306:	e9 2d ff ff ff       	jmp    802238 <__udivdi3+0x48>
  80230b:	90                   	nop
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 f8                	mov    %edi,%eax
  802312:	31 f6                	xor    %esi,%esi
  802314:	e9 1f ff ff ff       	jmp    802238 <__udivdi3+0x48>
  802319:	66 90                	xchg   %ax,%ax
  80231b:	66 90                	xchg   %ax,%ax
  80231d:	66 90                	xchg   %ax,%ax
  80231f:	90                   	nop

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 20             	sub    $0x20,%esp
  802326:	8b 44 24 34          	mov    0x34(%esp),%eax
  80232a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802332:	89 c6                	mov    %eax,%esi
  802334:	89 44 24 10          	mov    %eax,0x10(%esp)
  802338:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80233c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802340:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802344:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802348:	89 74 24 18          	mov    %esi,0x18(%esp)
  80234c:	85 c0                	test   %eax,%eax
  80234e:	89 c2                	mov    %eax,%edx
  802350:	75 1e                	jne    802370 <__umoddi3+0x50>
  802352:	39 f7                	cmp    %esi,%edi
  802354:	76 52                	jbe    8023a8 <__umoddi3+0x88>
  802356:	89 c8                	mov    %ecx,%eax
  802358:	89 f2                	mov    %esi,%edx
  80235a:	f7 f7                	div    %edi
  80235c:	89 d0                	mov    %edx,%eax
  80235e:	31 d2                	xor    %edx,%edx
  802360:	83 c4 20             	add    $0x20,%esp
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
  802367:	89 f6                	mov    %esi,%esi
  802369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802370:	39 f0                	cmp    %esi,%eax
  802372:	77 5c                	ja     8023d0 <__umoddi3+0xb0>
  802374:	0f bd e8             	bsr    %eax,%ebp
  802377:	83 f5 1f             	xor    $0x1f,%ebp
  80237a:	75 64                	jne    8023e0 <__umoddi3+0xc0>
  80237c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802380:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802384:	0f 86 f6 00 00 00    	jbe    802480 <__umoddi3+0x160>
  80238a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80238e:	0f 82 ec 00 00 00    	jb     802480 <__umoddi3+0x160>
  802394:	8b 44 24 14          	mov    0x14(%esp),%eax
  802398:	8b 54 24 18          	mov    0x18(%esp),%edx
  80239c:	83 c4 20             	add    $0x20,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	89 fd                	mov    %edi,%ebp
  8023ac:	75 0b                	jne    8023b9 <__umoddi3+0x99>
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f7                	div    %edi
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	f7 f5                	div    %ebp
  8023c1:	89 c8                	mov    %ecx,%eax
  8023c3:	f7 f5                	div    %ebp
  8023c5:	eb 95                	jmp    80235c <__umoddi3+0x3c>
  8023c7:	89 f6                	mov    %esi,%esi
  8023c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 20             	add    $0x20,%esp
  8023d7:	5e                   	pop    %esi
  8023d8:	5f                   	pop    %edi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
  8023db:	90                   	nop
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e5:	89 e9                	mov    %ebp,%ecx
  8023e7:	29 e8                	sub    %ebp,%eax
  8023e9:	d3 e2                	shl    %cl,%edx
  8023eb:	89 c7                	mov    %eax,%edi
  8023ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 c1                	mov    %eax,%ecx
  8023fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ff:	09 d1                	or     %edx,%ecx
  802401:	89 fa                	mov    %edi,%edx
  802403:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802407:	89 e9                	mov    %ebp,%ecx
  802409:	d3 e0                	shl    %cl,%eax
  80240b:	89 f9                	mov    %edi,%ecx
  80240d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802411:	89 f0                	mov    %esi,%eax
  802413:	d3 e8                	shr    %cl,%eax
  802415:	89 e9                	mov    %ebp,%ecx
  802417:	89 c7                	mov    %eax,%edi
  802419:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80241d:	d3 e6                	shl    %cl,%esi
  80241f:	89 d1                	mov    %edx,%ecx
  802421:	89 fa                	mov    %edi,%edx
  802423:	d3 e8                	shr    %cl,%eax
  802425:	89 e9                	mov    %ebp,%ecx
  802427:	09 f0                	or     %esi,%eax
  802429:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80242d:	f7 74 24 10          	divl   0x10(%esp)
  802431:	d3 e6                	shl    %cl,%esi
  802433:	89 d1                	mov    %edx,%ecx
  802435:	f7 64 24 0c          	mull   0xc(%esp)
  802439:	39 d1                	cmp    %edx,%ecx
  80243b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80243f:	89 d7                	mov    %edx,%edi
  802441:	89 c6                	mov    %eax,%esi
  802443:	72 0a                	jb     80244f <__umoddi3+0x12f>
  802445:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802449:	73 10                	jae    80245b <__umoddi3+0x13b>
  80244b:	39 d1                	cmp    %edx,%ecx
  80244d:	75 0c                	jne    80245b <__umoddi3+0x13b>
  80244f:	89 d7                	mov    %edx,%edi
  802451:	89 c6                	mov    %eax,%esi
  802453:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802457:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80245b:	89 ca                	mov    %ecx,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802463:	29 f0                	sub    %esi,%eax
  802465:	19 fa                	sbb    %edi,%edx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80246e:	89 d7                	mov    %edx,%edi
  802470:	d3 e7                	shl    %cl,%edi
  802472:	89 e9                	mov    %ebp,%ecx
  802474:	09 f8                	or     %edi,%eax
  802476:	d3 ea                	shr    %cl,%edx
  802478:	83 c4 20             	add    $0x20,%esp
  80247b:	5e                   	pop    %esi
  80247c:	5f                   	pop    %edi
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    
  80247f:	90                   	nop
  802480:	8b 74 24 10          	mov    0x10(%esp),%esi
  802484:	29 f9                	sub    %edi,%ecx
  802486:	19 c6                	sbb    %eax,%esi
  802488:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80248c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802490:	e9 ff fe ff ff       	jmp    802394 <__umoddi3+0x74>
