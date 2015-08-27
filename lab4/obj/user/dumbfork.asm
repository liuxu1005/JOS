
obj/user/dumbfork:     file format elf32-i386


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
  800045:	e8 4a 0c 00 00       	call   800c94 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 00 11 80 00       	push   $0x801100
  800057:	6a 20                	push   $0x20
  800059:	68 13 11 80 00       	push   $0x801113
  80005e:	e8 c8 01 00 00       	call   80022b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 61 0c 00 00       	call   800cd7 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 23 11 80 00       	push   $0x801123
  800083:	6a 22                	push   $0x22
  800085:	68 13 11 80 00       	push   $0x801113
  80008a:	e8 9c 01 00 00       	call   80022b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 7b 09 00 00       	call   800a1d <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 68 0c 00 00       	call   800d19 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 34 11 80 00       	push   $0x801134
  8000be:	6a 25                	push   $0x25
  8000c0:	68 13 11 80 00       	push   $0x801113
  8000c5:	e8 61 01 00 00       	call   80022b <_panic>
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
  8000e7:	68 47 11 80 00       	push   $0x801147
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 13 11 80 00       	push   $0x801113
  8000f3:	e8 33 01 00 00       	call   80022b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 53 0b 00 00       	call   800c56 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004
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
  80013c:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
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
  80015c:	e8 fa 0b 00 00       	call   800d5b <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 57 11 80 00       	push   $0x801157
  80016e:	6a 4c                	push   $0x4c
  800170:	68 13 11 80 00       	push   $0x801113
  800175:	e8 b1 00 00 00       	call   80022b <_panic>

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
  800196:	ba 74 11 80 00       	mov    $0x801174,%edx
  80019b:	eb 05                	jmp    8001a2 <umain+0x1f>
  80019d:	ba 6e 11 80 00       	mov    $0x80116e,%edx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	52                   	push   %edx
  8001a6:	53                   	push   %ebx
  8001a7:	68 7b 11 80 00       	push   $0x80117b
  8001ac:	e8 53 01 00 00       	call   800304 <cprintf>
		sys_yield();
  8001b1:	e8 bf 0a 00 00       	call   800c75 <sys_yield>

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
  8001de:	e8 73 0a 00 00       	call   800c56 <sys_getenvid>
  8001e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f0:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7e 07                	jle    800200 <libmain+0x2d>
		binaryname = argv[0];
  8001f9:	8b 06                	mov    (%esi),%eax
  8001fb:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80021c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80021f:	6a 00                	push   $0x0
  800221:	e8 ef 09 00 00       	call   800c15 <sys_env_destroy>
  800226:	83 c4 10             	add    $0x10,%esp
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800230:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800233:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800239:	e8 18 0a 00 00       	call   800c56 <sys_getenvid>
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 0c             	pushl  0xc(%ebp)
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	56                   	push   %esi
  800248:	50                   	push   %eax
  800249:	68 98 11 80 00       	push   $0x801198
  80024e:	e8 b1 00 00 00       	call   800304 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800253:	83 c4 18             	add    $0x18,%esp
  800256:	53                   	push   %ebx
  800257:	ff 75 10             	pushl  0x10(%ebp)
  80025a:	e8 54 00 00 00       	call   8002b3 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 8b 11 80 00 	movl   $0x80118b,(%esp)
  800266:	e8 99 00 00 00       	call   800304 <cprintf>
  80026b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026e:	cc                   	int3   
  80026f:	eb fd                	jmp    80026e <_panic+0x43>

00800271 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	53                   	push   %ebx
  800275:	83 ec 04             	sub    $0x4,%esp
  800278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027b:	8b 13                	mov    (%ebx),%edx
  80027d:	8d 42 01             	lea    0x1(%edx),%eax
  800280:	89 03                	mov    %eax,(%ebx)
  800282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800285:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800289:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028e:	75 1a                	jne    8002aa <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	68 ff 00 00 00       	push   $0xff
  800298:	8d 43 08             	lea    0x8(%ebx),%eax
  80029b:	50                   	push   %eax
  80029c:	e8 37 09 00 00       	call   800bd8 <sys_cputs>
		b->idx = 0;
  8002a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002aa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c3:	00 00 00 
	b.cnt = 0;
  8002c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dc:	50                   	push   %eax
  8002dd:	68 71 02 80 00       	push   $0x800271
  8002e2:	e8 4f 01 00 00       	call   800436 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e7:	83 c4 08             	add    $0x8,%esp
  8002ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f6:	50                   	push   %eax
  8002f7:	e8 dc 08 00 00       	call   800bd8 <sys_cputs>

	return b.cnt;
}
  8002fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	e8 9d ff ff ff       	call   8002b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 1c             	sub    $0x1c,%esp
  800321:	89 c7                	mov    %eax,%edi
  800323:	89 d6                	mov    %edx,%esi
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032b:	89 d1                	mov    %edx,%ecx
  80032d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800330:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800333:	8b 45 10             	mov    0x10(%ebp),%eax
  800336:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800339:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800343:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800346:	72 05                	jb     80034d <printnum+0x35>
  800348:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80034b:	77 3e                	ja     80038b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	ff 75 18             	pushl  0x18(%ebp)
  800353:	83 eb 01             	sub    $0x1,%ebx
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035e:	ff 75 e0             	pushl  -0x20(%ebp)
  800361:	ff 75 dc             	pushl  -0x24(%ebp)
  800364:	ff 75 d8             	pushl  -0x28(%ebp)
  800367:	e8 e4 0a 00 00       	call   800e50 <__udivdi3>
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	52                   	push   %edx
  800370:	50                   	push   %eax
  800371:	89 f2                	mov    %esi,%edx
  800373:	89 f8                	mov    %edi,%eax
  800375:	e8 9e ff ff ff       	call   800318 <printnum>
  80037a:	83 c4 20             	add    $0x20,%esp
  80037d:	eb 13                	jmp    800392 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	56                   	push   %esi
  800383:	ff 75 18             	pushl  0x18(%ebp)
  800386:	ff d7                	call   *%edi
  800388:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038b:	83 eb 01             	sub    $0x1,%ebx
  80038e:	85 db                	test   %ebx,%ebx
  800390:	7f ed                	jg     80037f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	56                   	push   %esi
  800396:	83 ec 04             	sub    $0x4,%esp
  800399:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039c:	ff 75 e0             	pushl  -0x20(%ebp)
  80039f:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a5:	e8 d6 0b 00 00       	call   800f80 <__umoddi3>
  8003aa:	83 c4 14             	add    $0x14,%esp
  8003ad:	0f be 80 bc 11 80 00 	movsbl 0x8011bc(%eax),%eax
  8003b4:	50                   	push   %eax
  8003b5:	ff d7                	call   *%edi
  8003b7:	83 c4 10             	add    $0x10,%esp
}
  8003ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7e 0e                	jle    8003d8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	8b 52 04             	mov    0x4(%edx),%edx
  8003d6:	eb 22                	jmp    8003fa <getuint+0x38>
	else if (lflag)
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	74 10                	je     8003ec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ea:	eb 0e                	jmp    8003fa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800402:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800406:	8b 10                	mov    (%eax),%edx
  800408:	3b 50 04             	cmp    0x4(%eax),%edx
  80040b:	73 0a                	jae    800417 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	88 02                	mov    %al,(%edx)
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80041f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800422:	50                   	push   %eax
  800423:	ff 75 10             	pushl  0x10(%ebp)
  800426:	ff 75 0c             	pushl  0xc(%ebp)
  800429:	ff 75 08             	pushl  0x8(%ebp)
  80042c:	e8 05 00 00 00       	call   800436 <vprintfmt>
	va_end(ap);
  800431:	83 c4 10             	add    $0x10,%esp
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    

00800436 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
  80043c:	83 ec 2c             	sub    $0x2c,%esp
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
  800442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800445:	8b 7d 10             	mov    0x10(%ebp),%edi
  800448:	eb 12                	jmp    80045c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80044a:	85 c0                	test   %eax,%eax
  80044c:	0f 84 90 03 00 00    	je     8007e2 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	50                   	push   %eax
  800457:	ff d6                	call   *%esi
  800459:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045c:	83 c7 01             	add    $0x1,%edi
  80045f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800463:	83 f8 25             	cmp    $0x25,%eax
  800466:	75 e2                	jne    80044a <vprintfmt+0x14>
  800468:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80046c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800473:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	eb 07                	jmp    80048f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80048b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8d 47 01             	lea    0x1(%edi),%eax
  800492:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800495:	0f b6 07             	movzbl (%edi),%eax
  800498:	0f b6 c8             	movzbl %al,%ecx
  80049b:	83 e8 23             	sub    $0x23,%eax
  80049e:	3c 55                	cmp    $0x55,%al
  8004a0:	0f 87 21 03 00 00    	ja     8007c7 <vprintfmt+0x391>
  8004a6:	0f b6 c0             	movzbl %al,%eax
  8004a9:	ff 24 85 80 12 80 00 	jmp    *0x801280(,%eax,4)
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b7:	eb d6                	jmp    80048f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004cb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ce:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d1:	83 fa 09             	cmp    $0x9,%edx
  8004d4:	77 39                	ja     80050f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d9:	eb e9                	jmp    8004c4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ec:	eb 27                	jmp    800515 <vprintfmt+0xdf>
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f8:	0f 49 c8             	cmovns %eax,%ecx
  8004fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	eb 8c                	jmp    80048f <vprintfmt+0x59>
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800506:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80050d:	eb 80                	jmp    80048f <vprintfmt+0x59>
  80050f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800512:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800515:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800519:	0f 89 70 ff ff ff    	jns    80048f <vprintfmt+0x59>
				width = precision, precision = -1;
  80051f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800522:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	e9 5e ff ff ff       	jmp    80048f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800531:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800537:	e9 53 ff ff ff       	jmp    80048f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	ff 30                	pushl  (%eax)
  80054b:	ff d6                	call   *%esi
			break;
  80054d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800553:	e9 04 ff ff ff       	jmp    80045c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 00                	mov    (%eax),%eax
  800563:	99                   	cltd   
  800564:	31 d0                	xor    %edx,%eax
  800566:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800568:	83 f8 09             	cmp    $0x9,%eax
  80056b:	7f 0b                	jg     800578 <vprintfmt+0x142>
  80056d:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	75 18                	jne    800590 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800578:	50                   	push   %eax
  800579:	68 d4 11 80 00       	push   $0x8011d4
  80057e:	53                   	push   %ebx
  80057f:	56                   	push   %esi
  800580:	e8 94 fe ff ff       	call   800419 <printfmt>
  800585:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80058b:	e9 cc fe ff ff       	jmp    80045c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800590:	52                   	push   %edx
  800591:	68 dd 11 80 00       	push   $0x8011dd
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 7c fe ff ff       	call   800419 <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	e9 b4 fe ff ff       	jmp    80045c <vprintfmt+0x26>
  8005a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	ba cd 11 80 00       	mov    $0x8011cd,%edx
  8005c3:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8005c6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ca:	0f 84 92 00 00 00    	je     800662 <vprintfmt+0x22c>
  8005d0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005d4:	0f 8e 96 00 00 00    	jle    800670 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	51                   	push   %ecx
  8005de:	57                   	push   %edi
  8005df:	e8 86 02 00 00       	call   80086a <strnlen>
  8005e4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005e7:	29 c1                	sub    %eax,%ecx
  8005e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	eb 0f                	jmp    80060c <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	ff 75 e0             	pushl  -0x20(%ebp)
  800604:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	85 ff                	test   %edi,%edi
  80060e:	7f ed                	jg     8005fd <vprintfmt+0x1c7>
  800610:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800613:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800616:	85 c9                	test   %ecx,%ecx
  800618:	b8 00 00 00 00       	mov    $0x0,%eax
  80061d:	0f 49 c1             	cmovns %ecx,%eax
  800620:	29 c1                	sub    %eax,%ecx
  800622:	89 75 08             	mov    %esi,0x8(%ebp)
  800625:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800628:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062b:	89 cb                	mov    %ecx,%ebx
  80062d:	eb 4d                	jmp    80067c <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800633:	74 1b                	je     800650 <vprintfmt+0x21a>
  800635:	0f be c0             	movsbl %al,%eax
  800638:	83 e8 20             	sub    $0x20,%eax
  80063b:	83 f8 5e             	cmp    $0x5e,%eax
  80063e:	76 10                	jbe    800650 <vprintfmt+0x21a>
					putch('?', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 0c             	pushl  0xc(%ebp)
  800646:	6a 3f                	push   $0x3f
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 0d                	jmp    80065d <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	ff 75 0c             	pushl  0xc(%ebp)
  800656:	52                   	push   %edx
  800657:	ff 55 08             	call   *0x8(%ebp)
  80065a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	83 eb 01             	sub    $0x1,%ebx
  800660:	eb 1a                	jmp    80067c <vprintfmt+0x246>
  800662:	89 75 08             	mov    %esi,0x8(%ebp)
  800665:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066e:	eb 0c                	jmp    80067c <vprintfmt+0x246>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	83 c7 01             	add    $0x1,%edi
  80067f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800683:	0f be d0             	movsbl %al,%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	74 23                	je     8006ad <vprintfmt+0x277>
  80068a:	85 f6                	test   %esi,%esi
  80068c:	78 a1                	js     80062f <vprintfmt+0x1f9>
  80068e:	83 ee 01             	sub    $0x1,%esi
  800691:	79 9c                	jns    80062f <vprintfmt+0x1f9>
  800693:	89 df                	mov    %ebx,%edi
  800695:	8b 75 08             	mov    0x8(%ebp),%esi
  800698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069b:	eb 18                	jmp    8006b5 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 20                	push   $0x20
  8006a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 08                	jmp    8006b5 <vprintfmt+0x27f>
  8006ad:	89 df                	mov    %ebx,%edi
  8006af:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	7f e4                	jg     80069d <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bc:	e9 9b fd ff ff       	jmp    80045c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c1:	83 fa 01             	cmp    $0x1,%edx
  8006c4:	7e 16                	jle    8006dc <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 08             	lea    0x8(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 50 04             	mov    0x4(%eax),%edx
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006da:	eb 32                	jmp    80070e <vprintfmt+0x2d8>
	else if (lflag)
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	74 18                	je     8006f8 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 c1                	mov    %eax,%ecx
  8006f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f6:	eb 16                	jmp    80070e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800706:	89 c1                	mov    %eax,%ecx
  800708:	c1 f9 1f             	sar    $0x1f,%ecx
  80070b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800711:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800719:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071d:	79 74                	jns    800793 <vprintfmt+0x35d>
				putch('-', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 2d                	push   $0x2d
  800725:	ff d6                	call   *%esi
				num = -(long long) num;
  800727:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072d:	f7 d8                	neg    %eax
  80072f:	83 d2 00             	adc    $0x0,%edx
  800732:	f7 da                	neg    %edx
  800734:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800737:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073c:	eb 55                	jmp    800793 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 7c fc ff ff       	call   8003c2 <getuint>
			base = 10;
  800746:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074b:	eb 46                	jmp    800793 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
  800750:	e8 6d fc ff ff       	call   8003c2 <getuint>
                        base = 8;
  800755:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80075a:	eb 37                	jmp    800793 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	6a 30                	push   $0x30
  800762:	ff d6                	call   *%esi
			putch('x', putdat);
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 78                	push   $0x78
  80076a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800775:	8b 00                	mov    (%eax),%eax
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800784:	eb 0d                	jmp    800793 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 34 fc ff ff       	call   8003c2 <getuint>
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800793:	83 ec 0c             	sub    $0xc,%esp
  800796:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079a:	57                   	push   %edi
  80079b:	ff 75 e0             	pushl  -0x20(%ebp)
  80079e:	51                   	push   %ecx
  80079f:	52                   	push   %edx
  8007a0:	50                   	push   %eax
  8007a1:	89 da                	mov    %ebx,%edx
  8007a3:	89 f0                	mov    %esi,%eax
  8007a5:	e8 6e fb ff ff       	call   800318 <printnum>
			break;
  8007aa:	83 c4 20             	add    $0x20,%esp
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b0:	e9 a7 fc ff ff       	jmp    80045c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	51                   	push   %ecx
  8007ba:	ff d6                	call   *%esi
			break;
  8007bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c2:	e9 95 fc ff ff       	jmp    80045c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 25                	push   $0x25
  8007cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	eb 03                	jmp    8007d7 <vprintfmt+0x3a1>
  8007d4:	83 ef 01             	sub    $0x1,%edi
  8007d7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007db:	75 f7                	jne    8007d4 <vprintfmt+0x39e>
  8007dd:	e9 7a fc ff ff       	jmp    80045c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 18             	sub    $0x18,%esp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800807:	85 c0                	test   %eax,%eax
  800809:	74 26                	je     800831 <vsnprintf+0x47>
  80080b:	85 d2                	test   %edx,%edx
  80080d:	7e 22                	jle    800831 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080f:	ff 75 14             	pushl  0x14(%ebp)
  800812:	ff 75 10             	pushl  0x10(%ebp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	68 fc 03 80 00       	push   $0x8003fc
  80081e:	e8 13 fc ff ff       	call   800436 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	eb 05                	jmp    800836 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	50                   	push   %eax
  800842:	ff 75 10             	pushl  0x10(%ebp)
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 9a ff ff ff       	call   8007ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	eb 03                	jmp    800862 <strlen+0x10>
		n++;
  80085f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800866:	75 f7                	jne    80085f <strlen+0xd>
		n++;
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800873:	ba 00 00 00 00       	mov    $0x0,%edx
  800878:	eb 03                	jmp    80087d <strnlen+0x13>
		n++;
  80087a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	74 08                	je     800889 <strnlen+0x1f>
  800881:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800885:	75 f3                	jne    80087a <strnlen+0x10>
  800887:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	89 c2                	mov    %eax,%edx
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ef                	jne    800897 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b2:	53                   	push   %ebx
  8008b3:	e8 9a ff ff ff       	call   800852 <strlen>
  8008b8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008bb:	ff 75 0c             	pushl  0xc(%ebp)
  8008be:	01 d8                	add    %ebx,%eax
  8008c0:	50                   	push   %eax
  8008c1:	e8 c5 ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008c6:	89 d8                	mov    %ebx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	89 f3                	mov    %esi,%ebx
  8008da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	89 f2                	mov    %esi,%edx
  8008df:	eb 0f                	jmp    8008f0 <strncpy+0x23>
		*dst++ = *src;
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	0f b6 01             	movzbl (%ecx),%eax
  8008e7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ea:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ed:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f0:	39 da                	cmp    %ebx,%edx
  8008f2:	75 ed                	jne    8008e1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	8b 55 10             	mov    0x10(%ebp),%edx
  800908:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090a:	85 d2                	test   %edx,%edx
  80090c:	74 21                	je     80092f <strlcpy+0x35>
  80090e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 09                	jmp    80091f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091f:	39 c2                	cmp    %eax,%edx
  800921:	74 09                	je     80092c <strlcpy+0x32>
  800923:	0f b6 19             	movzbl (%ecx),%ebx
  800926:	84 db                	test   %bl,%bl
  800928:	75 ec                	jne    800916 <strlcpy+0x1c>
  80092a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092f:	29 f0                	sub    %esi,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093e:	eb 06                	jmp    800946 <strcmp+0x11>
		p++, q++;
  800940:	83 c1 01             	add    $0x1,%ecx
  800943:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800946:	0f b6 01             	movzbl (%ecx),%eax
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strcmp+0x1c>
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 ef                	je     800940 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 c3                	mov    %eax,%ebx
  800967:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096a:	eb 06                	jmp    800972 <strncmp+0x17>
		n--, p++, q++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800972:	39 d8                	cmp    %ebx,%eax
  800974:	74 15                	je     80098b <strncmp+0x30>
  800976:	0f b6 08             	movzbl (%eax),%ecx
  800979:	84 c9                	test   %cl,%cl
  80097b:	74 04                	je     800981 <strncmp+0x26>
  80097d:	3a 0a                	cmp    (%edx),%cl
  80097f:	74 eb                	je     80096c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 00             	movzbl (%eax),%eax
  800984:	0f b6 12             	movzbl (%edx),%edx
  800987:	29 d0                	sub    %edx,%eax
  800989:	eb 05                	jmp    800990 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800990:	5b                   	pop    %ebx
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099d:	eb 07                	jmp    8009a6 <strchr+0x13>
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 0f                	je     8009b2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	0f b6 10             	movzbl (%eax),%edx
  8009a9:	84 d2                	test   %dl,%dl
  8009ab:	75 f2                	jne    80099f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009be:	eb 03                	jmp    8009c3 <strfind+0xf>
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c6:	84 d2                	test   %dl,%dl
  8009c8:	74 04                	je     8009ce <strfind+0x1a>
  8009ca:	38 ca                	cmp    %cl,%dl
  8009cc:	75 f2                	jne    8009c0 <strfind+0xc>
			break;
	return (char *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	74 36                	je     800a16 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e6:	75 28                	jne    800a10 <memset+0x40>
  8009e8:	f6 c1 03             	test   $0x3,%cl
  8009eb:	75 23                	jne    800a10 <memset+0x40>
		c &= 0xFF;
  8009ed:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f1:	89 d3                	mov    %edx,%ebx
  8009f3:	c1 e3 08             	shl    $0x8,%ebx
  8009f6:	89 d6                	mov    %edx,%esi
  8009f8:	c1 e6 18             	shl    $0x18,%esi
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	c1 e0 10             	shl    $0x10,%eax
  800a00:	09 f0                	or     %esi,%eax
  800a02:	09 c2                	or     %eax,%edx
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a08:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a0b:	fc                   	cld    
  800a0c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0e:	eb 06                	jmp    800a16 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a13:	fc                   	cld    
  800a14:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a16:	89 f8                	mov    %edi,%eax
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2b:	39 c6                	cmp    %eax,%esi
  800a2d:	73 35                	jae    800a64 <memmove+0x47>
  800a2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a32:	39 d0                	cmp    %edx,%eax
  800a34:	73 2e                	jae    800a64 <memmove+0x47>
		s += n;
		d += n;
  800a36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 13                	jne    800a58 <memmove+0x3b>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 0e                	jne    800a58 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a4a:	83 ef 04             	sub    $0x4,%edi
  800a4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a50:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a53:	fd                   	std    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 09                	jmp    800a61 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a58:	83 ef 01             	sub    $0x1,%edi
  800a5b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5e:	fd                   	std    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a61:	fc                   	cld    
  800a62:	eb 1d                	jmp    800a81 <memmove+0x64>
  800a64:	89 f2                	mov    %esi,%edx
  800a66:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 0f                	jne    800a7c <memmove+0x5f>
  800a6d:	f6 c1 03             	test   $0x3,%cl
  800a70:	75 0a                	jne    800a7c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a72:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7a:	eb 05                	jmp    800a81 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a88:	ff 75 10             	pushl  0x10(%ebp)
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	ff 75 08             	pushl  0x8(%ebp)
  800a91:	e8 87 ff ff ff       	call   800a1d <memmove>
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c6                	mov    %eax,%esi
  800aa5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	eb 1a                	jmp    800ac4 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaa:	0f b6 08             	movzbl (%eax),%ecx
  800aad:	0f b6 1a             	movzbl (%edx),%ebx
  800ab0:	38 d9                	cmp    %bl,%cl
  800ab2:	74 0a                	je     800abe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab4:	0f b6 c1             	movzbl %cl,%eax
  800ab7:	0f b6 db             	movzbl %bl,%ebx
  800aba:	29 d8                	sub    %ebx,%eax
  800abc:	eb 0f                	jmp    800acd <memcmp+0x35>
		s1++, s2++;
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac4:	39 f0                	cmp    %esi,%eax
  800ac6:	75 e2                	jne    800aaa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adf:	eb 07                	jmp    800ae8 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	74 07                	je     800aec <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	39 d0                	cmp    %edx,%eax
  800aea:	72 f5                	jb     800ae1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	eb 03                	jmp    800aff <strtol+0x11>
		s++;
  800afc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	3c 09                	cmp    $0x9,%al
  800b04:	74 f6                	je     800afc <strtol+0xe>
  800b06:	3c 20                	cmp    $0x20,%al
  800b08:	74 f2                	je     800afc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0a:	3c 2b                	cmp    $0x2b,%al
  800b0c:	75 0a                	jne    800b18 <strtol+0x2a>
		s++;
  800b0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
  800b16:	eb 10                	jmp    800b28 <strtol+0x3a>
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1d:	3c 2d                	cmp    $0x2d,%al
  800b1f:	75 07                	jne    800b28 <strtol+0x3a>
		s++, neg = 1;
  800b21:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b24:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	0f 94 c0             	sete   %al
  800b2d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b33:	75 19                	jne    800b4e <strtol+0x60>
  800b35:	80 39 30             	cmpb   $0x30,(%ecx)
  800b38:	75 14                	jne    800b4e <strtol+0x60>
  800b3a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3e:	0f 85 82 00 00 00    	jne    800bc6 <strtol+0xd8>
		s += 2, base = 16;
  800b44:	83 c1 02             	add    $0x2,%ecx
  800b47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4c:	eb 16                	jmp    800b64 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b4e:	84 c0                	test   %al,%al
  800b50:	74 12                	je     800b64 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b57:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5a:	75 08                	jne    800b64 <strtol+0x76>
		s++, base = 8;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6c:	0f b6 11             	movzbl (%ecx),%edx
  800b6f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b72:	89 f3                	mov    %esi,%ebx
  800b74:	80 fb 09             	cmp    $0x9,%bl
  800b77:	77 08                	ja     800b81 <strtol+0x93>
			dig = *s - '0';
  800b79:	0f be d2             	movsbl %dl,%edx
  800b7c:	83 ea 30             	sub    $0x30,%edx
  800b7f:	eb 22                	jmp    800ba3 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b81:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b84:	89 f3                	mov    %esi,%ebx
  800b86:	80 fb 19             	cmp    $0x19,%bl
  800b89:	77 08                	ja     800b93 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b8b:	0f be d2             	movsbl %dl,%edx
  800b8e:	83 ea 57             	sub    $0x57,%edx
  800b91:	eb 10                	jmp    800ba3 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b93:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b96:	89 f3                	mov    %esi,%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 16                	ja     800bb3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9d:	0f be d2             	movsbl %dl,%edx
  800ba0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba6:	7d 0f                	jge    800bb7 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ba8:	83 c1 01             	add    $0x1,%ecx
  800bab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800baf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb1:	eb b9                	jmp    800b6c <strtol+0x7e>
  800bb3:	89 c2                	mov    %eax,%edx
  800bb5:	eb 02                	jmp    800bb9 <strtol+0xcb>
  800bb7:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbd:	74 0d                	je     800bcc <strtol+0xde>
		*endptr = (char *) s;
  800bbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc2:	89 0e                	mov    %ecx,(%esi)
  800bc4:	eb 06                	jmp    800bcc <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc6:	84 c0                	test   %al,%al
  800bc8:	75 92                	jne    800b5c <strtol+0x6e>
  800bca:	eb 98                	jmp    800b64 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcc:	f7 da                	neg    %edx
  800bce:	85 ff                	test   %edi,%edi
  800bd0:	0f 45 c2             	cmovne %edx,%eax
}
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 c3                	mov    %eax,%ebx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 c6                	mov    %eax,%esi
  800bef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c23:	b8 03 00 00 00       	mov    $0x3,%eax
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	89 cb                	mov    %ecx,%ebx
  800c2d:	89 cf                	mov    %ecx,%edi
  800c2f:	89 ce                	mov    %ecx,%esi
  800c31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 03                	push   $0x3
  800c3d:	68 08 14 80 00       	push   $0x801408
  800c42:	6a 23                	push   $0x23
  800c44:	68 25 14 80 00       	push   $0x801425
  800c49:	e8 dd f5 ff ff       	call   80022b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c61:	b8 02 00 00 00       	mov    $0x2,%eax
  800c66:	89 d1                	mov    %edx,%ecx
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	89 d7                	mov    %edx,%edi
  800c6c:	89 d6                	mov    %edx,%esi
  800c6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_yield>:

void
sys_yield(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ca2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	89 f7                	mov    %esi,%edi
  800cb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7e 17                	jle    800ccf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 04                	push   $0x4
  800cbe:	68 08 14 80 00       	push   $0x801408
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 25 14 80 00       	push   $0x801425
  800cca:	e8 5c f5 ff ff       	call   80022b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 17                	jle    800d11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 05                	push   $0x5
  800d00:	68 08 14 80 00       	push   $0x801408
  800d05:	6a 23                	push   $0x23
  800d07:	68 25 14 80 00       	push   $0x801425
  800d0c:	e8 1a f5 ff ff       	call   80022b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 17                	jle    800d53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 06                	push   $0x6
  800d42:	68 08 14 80 00       	push   $0x801408
  800d47:	6a 23                	push   $0x23
  800d49:	68 25 14 80 00       	push   $0x801425
  800d4e:	e8 d8 f4 ff ff       	call   80022b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 17                	jle    800d95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 08                	push   $0x8
  800d84:	68 08 14 80 00       	push   $0x801408
  800d89:	6a 23                	push   $0x23
  800d8b:	68 25 14 80 00       	push   $0x801425
  800d90:	e8 96 f4 ff ff       	call   80022b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 09 00 00 00       	mov    $0x9,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 17                	jle    800dd7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	50                   	push   %eax
  800dc4:	6a 09                	push   $0x9
  800dc6:	68 08 14 80 00       	push   $0x801408
  800dcb:	6a 23                	push   $0x23
  800dcd:	68 25 14 80 00       	push   $0x801425
  800dd2:	e8 54 f4 ff ff       	call   80022b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	be 00 00 00 00       	mov    $0x0,%esi
  800dea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 cb                	mov    %ecx,%ebx
  800e1a:	89 cf                	mov    %ecx,%edi
  800e1c:	89 ce                	mov    %ecx,%esi
  800e1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 0c                	push   $0xc
  800e2a:	68 08 14 80 00       	push   $0x801408
  800e2f:	6a 23                	push   $0x23
  800e31:	68 25 14 80 00       	push   $0x801425
  800e36:	e8 f0 f3 ff ff       	call   80022b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
  800e43:	66 90                	xchg   %ax,%ax
  800e45:	66 90                	xchg   %ax,%ax
  800e47:	66 90                	xchg   %ax,%ax
  800e49:	66 90                	xchg   %ax,%ax
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	83 ec 10             	sub    $0x10,%esp
  800e56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800e5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800e5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e66:	85 d2                	test   %edx,%edx
  800e68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e6c:	89 34 24             	mov    %esi,(%esp)
  800e6f:	89 c8                	mov    %ecx,%eax
  800e71:	75 35                	jne    800ea8 <__udivdi3+0x58>
  800e73:	39 f1                	cmp    %esi,%ecx
  800e75:	0f 87 bd 00 00 00    	ja     800f38 <__udivdi3+0xe8>
  800e7b:	85 c9                	test   %ecx,%ecx
  800e7d:	89 cd                	mov    %ecx,%ebp
  800e7f:	75 0b                	jne    800e8c <__udivdi3+0x3c>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  800e86:	31 d2                	xor    %edx,%edx
  800e88:	f7 f1                	div    %ecx
  800e8a:	89 c5                	mov    %eax,%ebp
  800e8c:	89 f0                	mov    %esi,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f5                	div    %ebp
  800e92:	89 c6                	mov    %eax,%esi
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	f7 f5                	div    %ebp
  800e98:	89 f2                	mov    %esi,%edx
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    
  800ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	3b 14 24             	cmp    (%esp),%edx
  800eab:	77 7b                	ja     800f28 <__udivdi3+0xd8>
  800ead:	0f bd f2             	bsr    %edx,%esi
  800eb0:	83 f6 1f             	xor    $0x1f,%esi
  800eb3:	0f 84 97 00 00 00    	je     800f50 <__udivdi3+0x100>
  800eb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  800ebe:	89 d7                	mov    %edx,%edi
  800ec0:	89 f1                	mov    %esi,%ecx
  800ec2:	29 f5                	sub    %esi,%ebp
  800ec4:	d3 e7                	shl    %cl,%edi
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	89 e9                	mov    %ebp,%ecx
  800eca:	d3 ea                	shr    %cl,%edx
  800ecc:	89 f1                	mov    %esi,%ecx
  800ece:	09 fa                	or     %edi,%edx
  800ed0:	8b 3c 24             	mov    (%esp),%edi
  800ed3:	d3 e0                	shl    %cl,%eax
  800ed5:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ed9:	89 e9                	mov    %ebp,%ecx
  800edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edf:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee3:	89 fa                	mov    %edi,%edx
  800ee5:	d3 ea                	shr    %cl,%edx
  800ee7:	89 f1                	mov    %esi,%ecx
  800ee9:	d3 e7                	shl    %cl,%edi
  800eeb:	89 e9                	mov    %ebp,%ecx
  800eed:	d3 e8                	shr    %cl,%eax
  800eef:	09 c7                	or     %eax,%edi
  800ef1:	89 f8                	mov    %edi,%eax
  800ef3:	f7 74 24 08          	divl   0x8(%esp)
  800ef7:	89 d5                	mov    %edx,%ebp
  800ef9:	89 c7                	mov    %eax,%edi
  800efb:	f7 64 24 0c          	mull   0xc(%esp)
  800eff:	39 d5                	cmp    %edx,%ebp
  800f01:	89 14 24             	mov    %edx,(%esp)
  800f04:	72 11                	jb     800f17 <__udivdi3+0xc7>
  800f06:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f0a:	89 f1                	mov    %esi,%ecx
  800f0c:	d3 e2                	shl    %cl,%edx
  800f0e:	39 c2                	cmp    %eax,%edx
  800f10:	73 5e                	jae    800f70 <__udivdi3+0x120>
  800f12:	3b 2c 24             	cmp    (%esp),%ebp
  800f15:	75 59                	jne    800f70 <__udivdi3+0x120>
  800f17:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f1a:	31 f6                	xor    %esi,%esi
  800f1c:	89 f2                	mov    %esi,%edx
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	31 f6                	xor    %esi,%esi
  800f2a:	31 c0                	xor    %eax,%eax
  800f2c:	89 f2                	mov    %esi,%edx
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	31 f6                	xor    %esi,%esi
  800f3c:	89 f8                	mov    %edi,%eax
  800f3e:	f7 f1                	div    %ecx
  800f40:	89 f2                	mov    %esi,%edx
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f54:	76 0b                	jbe    800f61 <__udivdi3+0x111>
  800f56:	31 c0                	xor    %eax,%eax
  800f58:	3b 14 24             	cmp    (%esp),%edx
  800f5b:	0f 83 37 ff ff ff    	jae    800e98 <__udivdi3+0x48>
  800f61:	b8 01 00 00 00       	mov    $0x1,%eax
  800f66:	e9 2d ff ff ff       	jmp    800e98 <__udivdi3+0x48>
  800f6b:	90                   	nop
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	31 f6                	xor    %esi,%esi
  800f74:	e9 1f ff ff ff       	jmp    800e98 <__udivdi3+0x48>
  800f79:	66 90                	xchg   %ax,%ax
  800f7b:	66 90                	xchg   %ax,%ax
  800f7d:	66 90                	xchg   %ax,%ax
  800f7f:	90                   	nop

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	83 ec 20             	sub    $0x20,%esp
  800f86:	8b 44 24 34          	mov    0x34(%esp),%eax
  800f8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f92:	89 c6                	mov    %eax,%esi
  800f94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800fa0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fa4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800fa8:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	89 c2                	mov    %eax,%edx
  800fb0:	75 1e                	jne    800fd0 <__umoddi3+0x50>
  800fb2:	39 f7                	cmp    %esi,%edi
  800fb4:	76 52                	jbe    801008 <__umoddi3+0x88>
  800fb6:	89 c8                	mov    %ecx,%eax
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	f7 f7                	div    %edi
  800fbc:	89 d0                	mov    %edx,%eax
  800fbe:	31 d2                	xor    %edx,%edx
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    
  800fc7:	89 f6                	mov    %esi,%esi
  800fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800fd0:	39 f0                	cmp    %esi,%eax
  800fd2:	77 5c                	ja     801030 <__umoddi3+0xb0>
  800fd4:	0f bd e8             	bsr    %eax,%ebp
  800fd7:	83 f5 1f             	xor    $0x1f,%ebp
  800fda:	75 64                	jne    801040 <__umoddi3+0xc0>
  800fdc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800fe0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800fe4:	0f 86 f6 00 00 00    	jbe    8010e0 <__umoddi3+0x160>
  800fea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800fee:	0f 82 ec 00 00 00    	jb     8010e0 <__umoddi3+0x160>
  800ff4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ff8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	85 ff                	test   %edi,%edi
  80100a:	89 fd                	mov    %edi,%ebp
  80100c:	75 0b                	jne    801019 <__umoddi3+0x99>
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f7                	div    %edi
  801017:	89 c5                	mov    %eax,%ebp
  801019:	8b 44 24 10          	mov    0x10(%esp),%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	f7 f5                	div    %ebp
  801021:	89 c8                	mov    %ecx,%eax
  801023:	f7 f5                	div    %ebp
  801025:	eb 95                	jmp    800fbc <__umoddi3+0x3c>
  801027:	89 f6                	mov    %esi,%esi
  801029:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801030:	89 c8                	mov    %ecx,%eax
  801032:	89 f2                	mov    %esi,%edx
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	b8 20 00 00 00       	mov    $0x20,%eax
  801045:	89 e9                	mov    %ebp,%ecx
  801047:	29 e8                	sub    %ebp,%eax
  801049:	d3 e2                	shl    %cl,%edx
  80104b:	89 c7                	mov    %eax,%edi
  80104d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801051:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801055:	89 f9                	mov    %edi,%ecx
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 c1                	mov    %eax,%ecx
  80105b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80105f:	09 d1                	or     %edx,%ecx
  801061:	89 fa                	mov    %edi,%edx
  801063:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801067:	89 e9                	mov    %ebp,%ecx
  801069:	d3 e0                	shl    %cl,%eax
  80106b:	89 f9                	mov    %edi,%ecx
  80106d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801071:	89 f0                	mov    %esi,%eax
  801073:	d3 e8                	shr    %cl,%eax
  801075:	89 e9                	mov    %ebp,%ecx
  801077:	89 c7                	mov    %eax,%edi
  801079:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80107d:	d3 e6                	shl    %cl,%esi
  80107f:	89 d1                	mov    %edx,%ecx
  801081:	89 fa                	mov    %edi,%edx
  801083:	d3 e8                	shr    %cl,%eax
  801085:	89 e9                	mov    %ebp,%ecx
  801087:	09 f0                	or     %esi,%eax
  801089:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80108d:	f7 74 24 10          	divl   0x10(%esp)
  801091:	d3 e6                	shl    %cl,%esi
  801093:	89 d1                	mov    %edx,%ecx
  801095:	f7 64 24 0c          	mull   0xc(%esp)
  801099:	39 d1                	cmp    %edx,%ecx
  80109b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80109f:	89 d7                	mov    %edx,%edi
  8010a1:	89 c6                	mov    %eax,%esi
  8010a3:	72 0a                	jb     8010af <__umoddi3+0x12f>
  8010a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8010a9:	73 10                	jae    8010bb <__umoddi3+0x13b>
  8010ab:	39 d1                	cmp    %edx,%ecx
  8010ad:	75 0c                	jne    8010bb <__umoddi3+0x13b>
  8010af:	89 d7                	mov    %edx,%edi
  8010b1:	89 c6                	mov    %eax,%esi
  8010b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8010b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8010bb:	89 ca                	mov    %ecx,%edx
  8010bd:	89 e9                	mov    %ebp,%ecx
  8010bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010c3:	29 f0                	sub    %esi,%eax
  8010c5:	19 fa                	sbb    %edi,%edx
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8010ce:	89 d7                	mov    %edx,%edi
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	89 e9                	mov    %ebp,%ecx
  8010d4:	09 f8                	or     %edi,%eax
  8010d6:	d3 ea                	shr    %cl,%edx
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    
  8010df:	90                   	nop
  8010e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e4:	29 f9                	sub    %edi,%ecx
  8010e6:	19 c6                	sbb    %eax,%esi
  8010e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010f0:	e9 ff fe ff ff       	jmp    800ff4 <__umoddi3+0x74>
