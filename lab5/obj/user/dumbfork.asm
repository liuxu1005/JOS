
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
  800052:	68 80 1f 80 00       	push   $0x801f80
  800057:	6a 20                	push   $0x20
  800059:	68 93 1f 80 00       	push   $0x801f93
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
  80007e:	68 a3 1f 80 00       	push   $0x801fa3
  800083:	6a 22                	push   $0x22
  800085:	68 93 1f 80 00       	push   $0x801f93
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
  8000b9:	68 b4 1f 80 00       	push   $0x801fb4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 93 1f 80 00       	push   $0x801f93
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
  8000e7:	68 c7 1f 80 00       	push   $0x801fc7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 93 1f 80 00       	push   $0x801f93
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
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
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
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
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
  800169:	68 d7 1f 80 00       	push   $0x801fd7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 93 1f 80 00       	push   $0x801f93
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
  800196:	ba f4 1f 80 00       	mov    $0x801ff4,%edx
  80019b:	eb 05                	jmp    8001a2 <umain+0x1f>
  80019d:	ba ee 1f 80 00       	mov    $0x801fee,%edx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	52                   	push   %edx
  8001a6:	53                   	push   %ebx
  8001a7:	68 fb 1f 80 00       	push   $0x801ffb
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
  8001f0:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80021f:	e8 36 0e 00 00       	call   80105a <close_all>
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
  800251:	68 18 20 80 00       	push   $0x802018
  800256:	e8 b1 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025b:	83 c4 18             	add    $0x18,%esp
  80025e:	53                   	push   %ebx
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	e8 54 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800267:	c7 04 24 0b 20 80 00 	movl   $0x80200b,(%esp)
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
  80036f:	e8 5c 19 00 00       	call   801cd0 <__udivdi3>
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
  8003ad:	e8 4e 1a 00 00       	call   801e00 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 3b 20 80 00 	movsbl 0x80203b(%eax),%eax
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
  8004b1:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
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
  800575:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	75 18                	jne    800598 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800580:	50                   	push   %eax
  800581:	68 53 20 80 00       	push   $0x802053
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
  800599:	68 35 24 80 00       	push   $0x802435
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
  8005c6:	ba 4c 20 80 00       	mov    $0x80204c,%edx
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
  800c45:	68 5f 23 80 00       	push   $0x80235f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 7c 23 80 00       	push   $0x80237c
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
  800cc6:	68 5f 23 80 00       	push   $0x80235f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 7c 23 80 00       	push   $0x80237c
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
  800d08:	68 5f 23 80 00       	push   $0x80235f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 23 80 00       	push   $0x80237c
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
  800d4a:	68 5f 23 80 00       	push   $0x80235f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 7c 23 80 00       	push   $0x80237c
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
  800d8c:	68 5f 23 80 00       	push   $0x80235f
  800d91:	6a 23                	push   $0x23
  800d93:	68 7c 23 80 00       	push   $0x80237c
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
  800dce:	68 5f 23 80 00       	push   $0x80235f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 7c 23 80 00       	push   $0x80237c
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
  800e10:	68 5f 23 80 00       	push   $0x80235f
  800e15:	6a 23                	push   $0x23
  800e17:	68 7c 23 80 00       	push   $0x80237c
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
  800e74:	68 5f 23 80 00       	push   $0x80235f
  800e79:	6a 23                	push   $0x23
  800e7b:	68 7c 23 80 00       	push   $0x80237c
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

00800e8d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	05 00 00 00 30       	add    $0x30000000,%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ead:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 16             	shr    $0x16,%edx
  800ec4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 11                	je     800ee1 <fd_alloc+0x2d>
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 0c             	shr    $0xc,%edx
  800ed5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	75 09                	jne    800eea <fd_alloc+0x36>
			*fd_store = fd;
  800ee1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 17                	jmp    800f01 <fd_alloc+0x4d>
  800eea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef4:	75 c9                	jne    800ebf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f09:	83 f8 1f             	cmp    $0x1f,%eax
  800f0c:	77 36                	ja     800f44 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0e:	c1 e0 0c             	shl    $0xc,%eax
  800f11:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 16             	shr    $0x16,%edx
  800f1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 24                	je     800f4b <fd_lookup+0x48>
  800f27:	89 c2                	mov    %eax,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	74 1a                	je     800f52 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 13                	jmp    800f57 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f49:	eb 0c                	jmp    800f57 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f50:	eb 05                	jmp    800f57 <fd_lookup+0x54>
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f62:	ba 0c 24 80 00       	mov    $0x80240c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f67:	eb 13                	jmp    800f7c <dev_lookup+0x23>
  800f69:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6c:	39 08                	cmp    %ecx,(%eax)
  800f6e:	75 0c                	jne    800f7c <dev_lookup+0x23>
			*dev = devtab[i];
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7a:	eb 2e                	jmp    800faa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7c:	8b 02                	mov    (%edx),%eax
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	75 e7                	jne    800f69 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f82:	a1 04 40 80 00       	mov    0x804004,%eax
  800f87:	8b 40 48             	mov    0x48(%eax),%eax
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	51                   	push   %ecx
  800f8e:	50                   	push   %eax
  800f8f:	68 8c 23 80 00       	push   $0x80238c
  800f94:	e8 73 f3 ff ff       	call   80030c <cprintf>
	*dev = 0;
  800f99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 10             	sub    $0x10,%esp
  800fb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbd:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fbe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc7:	50                   	push   %eax
  800fc8:	e8 36 ff ff ff       	call   800f03 <fd_lookup>
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 05                	js     800fd9 <fd_close+0x2d>
	    || fd != fd2)
  800fd4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd7:	74 0c                	je     800fe5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd9:	84 db                	test   %bl,%bl
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	0f 44 c2             	cmove  %edx,%eax
  800fe3:	eb 41                	jmp    801026 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 36                	pushl  (%esi)
  800fee:	e8 66 ff ff ff       	call   800f59 <dev_lookup>
  800ff3:	89 c3                	mov    %eax,%ebx
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 1a                	js     801016 <fd_close+0x6a>
		if (dev->dev_close)
  800ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fff:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801007:	85 c0                	test   %eax,%eax
  801009:	74 0b                	je     801016 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	56                   	push   %esi
  80100f:	ff d0                	call   *%eax
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	56                   	push   %esi
  80101a:	6a 00                	push   $0x0
  80101c:	e8 00 fd ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	89 d8                	mov    %ebx,%eax
}
  801026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 c4 fe ff ff       	call   800f03 <fd_lookup>
  80103f:	89 c2                	mov    %eax,%edx
  801041:	83 c4 08             	add    $0x8,%esp
  801044:	85 d2                	test   %edx,%edx
  801046:	78 10                	js     801058 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801048:	83 ec 08             	sub    $0x8,%esp
  80104b:	6a 01                	push   $0x1
  80104d:	ff 75 f4             	pushl  -0xc(%ebp)
  801050:	e8 57 ff ff ff       	call   800fac <fd_close>
  801055:	83 c4 10             	add    $0x10,%esp
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <close_all>:

void
close_all(void)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	53                   	push   %ebx
  80105e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	53                   	push   %ebx
  80106a:	e8 be ff ff ff       	call   80102d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106f:	83 c3 01             	add    $0x1,%ebx
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	83 fb 20             	cmp    $0x20,%ebx
  801078:	75 ec                	jne    801066 <close_all+0xc>
		close(i);
}
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 2c             	sub    $0x2c,%esp
  801088:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80108b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108e:	50                   	push   %eax
  80108f:	ff 75 08             	pushl  0x8(%ebp)
  801092:	e8 6c fe ff ff       	call   800f03 <fd_lookup>
  801097:	89 c2                	mov    %eax,%edx
  801099:	83 c4 08             	add    $0x8,%esp
  80109c:	85 d2                	test   %edx,%edx
  80109e:	0f 88 c1 00 00 00    	js     801165 <dup+0xe6>
		return r;
	close(newfdnum);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	56                   	push   %esi
  8010a8:	e8 80 ff ff ff       	call   80102d <close>

	newfd = INDEX2FD(newfdnum);
  8010ad:	89 f3                	mov    %esi,%ebx
  8010af:	c1 e3 0c             	shl    $0xc,%ebx
  8010b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b8:	83 c4 04             	add    $0x4,%esp
  8010bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010be:	e8 da fd ff ff       	call   800e9d <fd2data>
  8010c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c5:	89 1c 24             	mov    %ebx,(%esp)
  8010c8:	e8 d0 fd ff ff       	call   800e9d <fd2data>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d3:	89 f8                	mov    %edi,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 37                	je     80111a <dup+0x9b>
  8010e3:	89 f8                	mov    %edi,%eax
  8010e5:	c1 e8 0c             	shr    $0xc,%eax
  8010e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ef:	f6 c2 01             	test   $0x1,%dl
  8010f2:	74 26                	je     80111a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801103:	50                   	push   %eax
  801104:	ff 75 d4             	pushl  -0x2c(%ebp)
  801107:	6a 00                	push   $0x0
  801109:	57                   	push   %edi
  80110a:	6a 00                	push   $0x0
  80110c:	e8 ce fb ff ff       	call   800cdf <sys_page_map>
  801111:	89 c7                	mov    %eax,%edi
  801113:	83 c4 20             	add    $0x20,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	78 2e                	js     801148 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80111d:	89 d0                	mov    %edx,%eax
  80111f:	c1 e8 0c             	shr    $0xc,%eax
  801122:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	25 07 0e 00 00       	and    $0xe07,%eax
  801131:	50                   	push   %eax
  801132:	53                   	push   %ebx
  801133:	6a 00                	push   $0x0
  801135:	52                   	push   %edx
  801136:	6a 00                	push   $0x0
  801138:	e8 a2 fb ff ff       	call   800cdf <sys_page_map>
  80113d:	89 c7                	mov    %eax,%edi
  80113f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801142:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801144:	85 ff                	test   %edi,%edi
  801146:	79 1d                	jns    801165 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801148:	83 ec 08             	sub    $0x8,%esp
  80114b:	53                   	push   %ebx
  80114c:	6a 00                	push   $0x0
  80114e:	e8 ce fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	ff 75 d4             	pushl  -0x2c(%ebp)
  801159:	6a 00                	push   $0x0
  80115b:	e8 c1 fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	89 f8                	mov    %edi,%eax
}
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	53                   	push   %ebx
  801171:	83 ec 14             	sub    $0x14,%esp
  801174:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117a:	50                   	push   %eax
  80117b:	53                   	push   %ebx
  80117c:	e8 82 fd ff ff       	call   800f03 <fd_lookup>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	89 c2                	mov    %eax,%edx
  801186:	85 c0                	test   %eax,%eax
  801188:	78 6d                	js     8011f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801194:	ff 30                	pushl  (%eax)
  801196:	e8 be fd ff ff       	call   800f59 <dev_lookup>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 4c                	js     8011ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a5:	8b 42 08             	mov    0x8(%edx),%eax
  8011a8:	83 e0 03             	and    $0x3,%eax
  8011ab:	83 f8 01             	cmp    $0x1,%eax
  8011ae:	75 21                	jne    8011d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b5:	8b 40 48             	mov    0x48(%eax),%eax
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	53                   	push   %ebx
  8011bc:	50                   	push   %eax
  8011bd:	68 d0 23 80 00       	push   $0x8023d0
  8011c2:	e8 45 f1 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cf:	eb 26                	jmp    8011f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8011d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d4:	8b 40 08             	mov    0x8(%eax),%eax
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	74 17                	je     8011f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	ff 75 10             	pushl  0x10(%ebp)
  8011e1:	ff 75 0c             	pushl  0xc(%ebp)
  8011e4:	52                   	push   %edx
  8011e5:	ff d0                	call   *%eax
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	eb 09                	jmp    8011f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	eb 05                	jmp    8011f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f7:	89 d0                	mov    %edx,%eax
  8011f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801212:	eb 21                	jmp    801235 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	89 f0                	mov    %esi,%eax
  801219:	29 d8                	sub    %ebx,%eax
  80121b:	50                   	push   %eax
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	03 45 0c             	add    0xc(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	57                   	push   %edi
  801223:	e8 45 ff ff ff       	call   80116d <read>
		if (m < 0)
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 0c                	js     80123b <readn+0x3d>
			return m;
		if (m == 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	74 06                	je     801239 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801233:	01 c3                	add    %eax,%ebx
  801235:	39 f3                	cmp    %esi,%ebx
  801237:	72 db                	jb     801214 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801239:	89 d8                	mov    %ebx,%eax
}
  80123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	53                   	push   %ebx
  801252:	e8 ac fc ff ff       	call   800f03 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 68                	js     8012c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 e8 fc ff ff       	call   800f59 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 47                	js     8012bf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 ec 23 80 00       	push   $0x8023ec
  801293:	e8 74 f0 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a0:	eb 26                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 17                	je     8012c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	ff 75 10             	pushl  0x10(%ebp)
  8012b2:	ff 75 0c             	pushl  0xc(%ebp)
  8012b5:	50                   	push   %eax
  8012b6:	ff d2                	call   *%edx
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb 09                	jmp    8012c8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	eb 05                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c8:	89 d0                	mov    %edx,%eax
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 22 fc ff ff       	call   800f03 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 0e                	js     8012f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 14             	sub    $0x14,%esp
  8012ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	53                   	push   %ebx
  801307:	e8 f7 fb ff ff       	call   800f03 <fd_lookup>
  80130c:	83 c4 08             	add    $0x8,%esp
  80130f:	89 c2                	mov    %eax,%edx
  801311:	85 c0                	test   %eax,%eax
  801313:	78 65                	js     80137a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 33 fc ff ff       	call   800f59 <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 44                	js     801371 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801334:	75 21                	jne    801357 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801336:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	53                   	push   %ebx
  801342:	50                   	push   %eax
  801343:	68 ac 23 80 00       	push   $0x8023ac
  801348:	e8 bf ef ff ff       	call   80030c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801355:	eb 23                	jmp    80137a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135a:	8b 52 18             	mov    0x18(%edx),%edx
  80135d:	85 d2                	test   %edx,%edx
  80135f:	74 14                	je     801375 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	ff d2                	call   *%edx
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	eb 09                	jmp    80137a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	89 c2                	mov    %eax,%edx
  801373:	eb 05                	jmp    80137a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801375:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 14             	sub    $0x14,%esp
  801388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 6c fb ff ff       	call   800f03 <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 58                	js     8013f8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	e8 a8 fb ff ff       	call   800f59 <dev_lookup>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 37                	js     8013ef <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bf:	74 32                	je     8013f3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013cb:	00 00 00 
	stat->st_isdir = 0;
  8013ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d5:	00 00 00 
	stat->st_dev = dev;
  8013d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	53                   	push   %ebx
  8013e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e5:	ff 50 14             	call   *0x14(%eax)
  8013e8:	89 c2                	mov    %eax,%edx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb 09                	jmp    8013f8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	eb 05                	jmp    8013f8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f8:	89 d0                	mov    %edx,%eax
  8013fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 00                	push   $0x0
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 09 02 00 00       	call   80161a <open>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 db                	test   %ebx,%ebx
  801418:	78 1b                	js     801435 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	53                   	push   %ebx
  801421:	e8 5b ff ff ff       	call   801381 <fstat>
  801426:	89 c6                	mov    %eax,%esi
	close(fd);
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 fd fb ff ff       	call   80102d <close>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 f0                	mov    %esi,%eax
}
  801435:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	89 c6                	mov    %eax,%esi
  801443:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801445:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144c:	75 12                	jne    801460 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	6a 01                	push   $0x1
  801453:	e8 ff 07 00 00       	call   801c57 <ipc_find_env>
  801458:	a3 00 40 80 00       	mov    %eax,0x804000
  80145d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801460:	6a 07                	push   $0x7
  801462:	68 00 50 80 00       	push   $0x805000
  801467:	56                   	push   %esi
  801468:	ff 35 00 40 80 00    	pushl  0x804000
  80146e:	e8 90 07 00 00       	call   801c03 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801473:	83 c4 0c             	add    $0xc,%esp
  801476:	6a 00                	push   $0x0
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 1a 07 00 00       	call   801b9a <ipc_recv>
}
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8014aa:	e8 8d ff ff ff       	call   80143c <fsipc>
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014cc:	e8 6b ff ff ff       	call   80143c <fsipc>
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f2:	e8 45 ff ff ff       	call   80143c <fsipc>
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	85 d2                	test   %edx,%edx
  8014fb:	78 2c                	js     801529 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	68 00 50 80 00       	push   $0x805000
  801505:	53                   	push   %ebx
  801506:	e8 88 f3 ff ff       	call   800893 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150b:	a1 80 50 80 00       	mov    0x805080,%eax
  801510:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801516:	a1 84 50 80 00       	mov    0x805084,%eax
  80151b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801529:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 0c             	sub    $0xc,%esp
  801537:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 40 0c             	mov    0xc(%eax),%eax
  801540:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801548:	eb 3d                	jmp    801587 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80154a:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801550:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801555:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	57                   	push   %edi
  80155c:	53                   	push   %ebx
  80155d:	68 08 50 80 00       	push   $0x805008
  801562:	e8 be f4 ff ff       	call   800a25 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801567:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
  801572:	b8 04 00 00 00       	mov    $0x4,%eax
  801577:	e8 c0 fe ff ff       	call   80143c <fsipc>
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 0d                	js     801590 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801583:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801585:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801587:	85 f6                	test   %esi,%esi
  801589:	75 bf                	jne    80154a <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80158b:	89 d8                	mov    %ebx,%eax
  80158d:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801590:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015ab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8015bb:	e8 7c fe ff ff       	call   80143c <fsipc>
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 4b                	js     801611 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015c6:	39 c6                	cmp    %eax,%esi
  8015c8:	73 16                	jae    8015e0 <devfile_read+0x48>
  8015ca:	68 1c 24 80 00       	push   $0x80241c
  8015cf:	68 23 24 80 00       	push   $0x802423
  8015d4:	6a 7c                	push   $0x7c
  8015d6:	68 38 24 80 00       	push   $0x802438
  8015db:	e8 53 ec ff ff       	call   800233 <_panic>
	assert(r <= PGSIZE);
  8015e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e5:	7e 16                	jle    8015fd <devfile_read+0x65>
  8015e7:	68 43 24 80 00       	push   $0x802443
  8015ec:	68 23 24 80 00       	push   $0x802423
  8015f1:	6a 7d                	push   $0x7d
  8015f3:	68 38 24 80 00       	push   $0x802438
  8015f8:	e8 36 ec ff ff       	call   800233 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	50                   	push   %eax
  801601:	68 00 50 80 00       	push   $0x805000
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	e8 17 f4 ff ff       	call   800a25 <memmove>
	return r;
  80160e:	83 c4 10             	add    $0x10,%esp
}
  801611:	89 d8                	mov    %ebx,%eax
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 20             	sub    $0x20,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801624:	53                   	push   %ebx
  801625:	e8 30 f2 ff ff       	call   80085a <strlen>
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801632:	7f 67                	jg     80169b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	e8 74 f8 ff ff       	call   800eb4 <fd_alloc>
  801640:	83 c4 10             	add    $0x10,%esp
		return r;
  801643:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801645:	85 c0                	test   %eax,%eax
  801647:	78 57                	js     8016a0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	68 00 50 80 00       	push   $0x805000
  801652:	e8 3c f2 ff ff       	call   800893 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80165f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801662:	b8 01 00 00 00       	mov    $0x1,%eax
  801667:	e8 d0 fd ff ff       	call   80143c <fsipc>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	79 14                	jns    801689 <open+0x6f>
		fd_close(fd, 0);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 f4             	pushl  -0xc(%ebp)
  80167d:	e8 2a f9 ff ff       	call   800fac <fd_close>
		return r;
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	89 da                	mov    %ebx,%edx
  801687:	eb 17                	jmp    8016a0 <open+0x86>
	}

	return fd2num(fd);
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	ff 75 f4             	pushl  -0xc(%ebp)
  80168f:	e8 f9 f7 ff ff       	call   800e8d <fd2num>
  801694:	89 c2                	mov    %eax,%edx
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	eb 05                	jmp    8016a0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80169b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a0:	89 d0                	mov    %edx,%eax
  8016a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b7:	e8 80 fd ff ff       	call   80143c <fsipc>
}
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	ff 75 08             	pushl  0x8(%ebp)
  8016cc:	e8 cc f7 ff ff       	call   800e9d <fd2data>
  8016d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016d3:	83 c4 08             	add    $0x8,%esp
  8016d6:	68 4f 24 80 00       	push   $0x80244f
  8016db:	53                   	push   %ebx
  8016dc:	e8 b2 f1 ff ff       	call   800893 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016e1:	8b 56 04             	mov    0x4(%esi),%edx
  8016e4:	89 d0                	mov    %edx,%eax
  8016e6:	2b 06                	sub    (%esi),%eax
  8016e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f5:	00 00 00 
	stat->st_dev = &devpipe;
  8016f8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ff:	30 80 00 
	return 0;
}
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
  801707:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 0c             	sub    $0xc,%esp
  801715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801718:	53                   	push   %ebx
  801719:	6a 00                	push   $0x0
  80171b:	e8 01 f6 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801720:	89 1c 24             	mov    %ebx,(%esp)
  801723:	e8 75 f7 ff ff       	call   800e9d <fd2data>
  801728:	83 c4 08             	add    $0x8,%esp
  80172b:	50                   	push   %eax
  80172c:	6a 00                	push   $0x0
  80172e:	e8 ee f5 ff ff       	call   800d21 <sys_page_unmap>
}
  801733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	57                   	push   %edi
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	83 ec 1c             	sub    $0x1c,%esp
  801741:	89 c6                	mov    %eax,%esi
  801743:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801746:	a1 04 40 80 00       	mov    0x804004,%eax
  80174b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	56                   	push   %esi
  801752:	e8 38 05 00 00       	call   801c8f <pageref>
  801757:	89 c7                	mov    %eax,%edi
  801759:	83 c4 04             	add    $0x4,%esp
  80175c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175f:	e8 2b 05 00 00       	call   801c8f <pageref>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	39 c7                	cmp    %eax,%edi
  801769:	0f 94 c2             	sete   %dl
  80176c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80176f:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801775:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801778:	39 fb                	cmp    %edi,%ebx
  80177a:	74 19                	je     801795 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80177c:	84 d2                	test   %dl,%dl
  80177e:	74 c6                	je     801746 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801780:	8b 51 58             	mov    0x58(%ecx),%edx
  801783:	50                   	push   %eax
  801784:	52                   	push   %edx
  801785:	53                   	push   %ebx
  801786:	68 56 24 80 00       	push   $0x802456
  80178b:	e8 7c eb ff ff       	call   80030c <cprintf>
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	eb b1                	jmp    801746 <_pipeisclosed+0xe>
	}
}
  801795:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	57                   	push   %edi
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	83 ec 28             	sub    $0x28,%esp
  8017a6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017a9:	56                   	push   %esi
  8017aa:	e8 ee f6 ff ff       	call   800e9d <fd2data>
  8017af:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b9:	eb 4b                	jmp    801806 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017bb:	89 da                	mov    %ebx,%edx
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	e8 74 ff ff ff       	call   801738 <_pipeisclosed>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	75 48                	jne    801810 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017c8:	e8 b0 f4 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8017d0:	8b 0b                	mov    (%ebx),%ecx
  8017d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8017d5:	39 d0                	cmp    %edx,%eax
  8017d7:	73 e2                	jae    8017bb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017dc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017e0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	c1 fa 1f             	sar    $0x1f,%edx
  8017e8:	89 d1                	mov    %edx,%ecx
  8017ea:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ed:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017f0:	83 e2 1f             	and    $0x1f,%edx
  8017f3:	29 ca                	sub    %ecx,%edx
  8017f5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017fd:	83 c0 01             	add    $0x1,%eax
  801800:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801803:	83 c7 01             	add    $0x1,%edi
  801806:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801809:	75 c2                	jne    8017cd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80180b:	8b 45 10             	mov    0x10(%ebp),%eax
  80180e:	eb 05                	jmp    801815 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801815:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	83 ec 18             	sub    $0x18,%esp
  801826:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801829:	57                   	push   %edi
  80182a:	e8 6e f6 ff ff       	call   800e9d <fd2data>
  80182f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	bb 00 00 00 00       	mov    $0x0,%ebx
  801839:	eb 3d                	jmp    801878 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80183b:	85 db                	test   %ebx,%ebx
  80183d:	74 04                	je     801843 <devpipe_read+0x26>
				return i;
  80183f:	89 d8                	mov    %ebx,%eax
  801841:	eb 44                	jmp    801887 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801843:	89 f2                	mov    %esi,%edx
  801845:	89 f8                	mov    %edi,%eax
  801847:	e8 ec fe ff ff       	call   801738 <_pipeisclosed>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	75 32                	jne    801882 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801850:	e8 28 f4 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801855:	8b 06                	mov    (%esi),%eax
  801857:	3b 46 04             	cmp    0x4(%esi),%eax
  80185a:	74 df                	je     80183b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80185c:	99                   	cltd   
  80185d:	c1 ea 1b             	shr    $0x1b,%edx
  801860:	01 d0                	add    %edx,%eax
  801862:	83 e0 1f             	and    $0x1f,%eax
  801865:	29 d0                	sub    %edx,%eax
  801867:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80186c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801872:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801875:	83 c3 01             	add    $0x1,%ebx
  801878:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80187b:	75 d8                	jne    801855 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80187d:	8b 45 10             	mov    0x10(%ebp),%eax
  801880:	eb 05                	jmp    801887 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801887:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80188a:	5b                   	pop    %ebx
  80188b:	5e                   	pop    %esi
  80188c:	5f                   	pop    %edi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801897:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	e8 14 f6 ff ff       	call   800eb4 <fd_alloc>
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 88 2c 01 00 00    	js     8019d9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	68 07 04 00 00       	push   $0x407
  8018b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 dd f3 ff ff       	call   800c9c <sys_page_alloc>
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	0f 88 0d 01 00 00    	js     8019d9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d2:	50                   	push   %eax
  8018d3:	e8 dc f5 ff ff       	call   800eb4 <fd_alloc>
  8018d8:	89 c3                	mov    %eax,%ebx
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	0f 88 e2 00 00 00    	js     8019c7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	68 07 04 00 00       	push   $0x407
  8018ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 a5 f3 ff ff       	call   800c9c <sys_page_alloc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	0f 88 c3 00 00 00    	js     8019c7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	ff 75 f4             	pushl  -0xc(%ebp)
  80190a:	e8 8e f5 ff ff       	call   800e9d <fd2data>
  80190f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801911:	83 c4 0c             	add    $0xc,%esp
  801914:	68 07 04 00 00       	push   $0x407
  801919:	50                   	push   %eax
  80191a:	6a 00                	push   $0x0
  80191c:	e8 7b f3 ff ff       	call   800c9c <sys_page_alloc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	0f 88 89 00 00 00    	js     8019b7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff 75 f0             	pushl  -0x10(%ebp)
  801934:	e8 64 f5 ff ff       	call   800e9d <fd2data>
  801939:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801940:	50                   	push   %eax
  801941:	6a 00                	push   $0x0
  801943:	56                   	push   %esi
  801944:	6a 00                	push   $0x0
  801946:	e8 94 f3 ff ff       	call   800cdf <sys_page_map>
  80194b:	89 c3                	mov    %eax,%ebx
  80194d:	83 c4 20             	add    $0x20,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	78 55                	js     8019a9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801954:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801962:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801969:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801972:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801974:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801977:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	e8 04 f5 ff ff       	call   800e8d <fd2num>
  801989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80198e:	83 c4 04             	add    $0x4,%esp
  801991:	ff 75 f0             	pushl  -0x10(%ebp)
  801994:	e8 f4 f4 ff ff       	call   800e8d <fd2num>
  801999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	eb 30                	jmp    8019d9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	56                   	push   %esi
  8019ad:	6a 00                	push   $0x0
  8019af:	e8 6d f3 ff ff       	call   800d21 <sys_page_unmap>
  8019b4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bd:	6a 00                	push   $0x0
  8019bf:	e8 5d f3 ff ff       	call   800d21 <sys_page_unmap>
  8019c4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 4d f3 ff ff       	call   800d21 <sys_page_unmap>
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019d9:	89 d0                	mov    %edx,%eax
  8019db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019eb:	50                   	push   %eax
  8019ec:	ff 75 08             	pushl  0x8(%ebp)
  8019ef:	e8 0f f5 ff ff       	call   800f03 <fd_lookup>
  8019f4:	89 c2                	mov    %eax,%edx
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 d2                	test   %edx,%edx
  8019fb:	78 18                	js     801a15 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	ff 75 f4             	pushl  -0xc(%ebp)
  801a03:	e8 95 f4 ff ff       	call   800e9d <fd2data>
	return _pipeisclosed(fd, p);
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	e8 26 fd ff ff       	call   801738 <_pipeisclosed>
  801a12:	83 c4 10             	add    $0x10,%esp
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a27:	68 6e 24 80 00       	push   $0x80246e
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	e8 5f ee ff ff       	call   800893 <strcpy>
	return 0;
}
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a47:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a4c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a52:	eb 2d                	jmp    801a81 <devcons_write+0x46>
		m = n - tot;
  801a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a57:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a59:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a5c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a61:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a64:	83 ec 04             	sub    $0x4,%esp
  801a67:	53                   	push   %ebx
  801a68:	03 45 0c             	add    0xc(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	57                   	push   %edi
  801a6d:	e8 b3 ef ff ff       	call   800a25 <memmove>
		sys_cputs(buf, m);
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	53                   	push   %ebx
  801a76:	57                   	push   %edi
  801a77:	e8 64 f1 ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a7c:	01 de                	add    %ebx,%esi
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a86:	72 cc                	jb     801a54 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5f                   	pop    %edi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a9f:	75 07                	jne    801aa8 <devcons_read+0x18>
  801aa1:	eb 28                	jmp    801acb <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801aa3:	e8 d5 f1 ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801aa8:	e8 51 f1 ff ff       	call   800bfe <sys_cgetc>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	74 f2                	je     801aa3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 16                	js     801acb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ab5:	83 f8 04             	cmp    $0x4,%eax
  801ab8:	74 0c                	je     801ac6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801aba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abd:	88 02                	mov    %al,(%edx)
	return 1;
  801abf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac4:	eb 05                	jmp    801acb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ad9:	6a 01                	push   $0x1
  801adb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	e8 fc f0 ff ff       	call   800be0 <sys_cputs>
  801ae4:	83 c4 10             	add    $0x10,%esp
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <getchar>:

int
getchar(void)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aef:	6a 01                	push   $0x1
  801af1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801af4:	50                   	push   %eax
  801af5:	6a 00                	push   $0x0
  801af7:	e8 71 f6 ff ff       	call   80116d <read>
	if (r < 0)
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 0f                	js     801b12 <getchar+0x29>
		return r;
	if (r < 1)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	7e 06                	jle    801b0d <getchar+0x24>
		return -E_EOF;
	return c;
  801b07:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b0b:	eb 05                	jmp    801b12 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b0d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 dd f3 ff ff       	call   800f03 <fd_lookup>
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 11                	js     801b3e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b30:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b36:	39 10                	cmp    %edx,(%eax)
  801b38:	0f 94 c0             	sete   %al
  801b3b:	0f b6 c0             	movzbl %al,%eax
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <opencons>:

int
opencons(void)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b49:	50                   	push   %eax
  801b4a:	e8 65 f3 ff ff       	call   800eb4 <fd_alloc>
  801b4f:	83 c4 10             	add    $0x10,%esp
		return r;
  801b52:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 3e                	js     801b96 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	68 07 04 00 00       	push   $0x407
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	6a 00                	push   $0x0
  801b65:	e8 32 f1 ff ff       	call   800c9c <sys_page_alloc>
  801b6a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b6d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 23                	js     801b96 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	50                   	push   %eax
  801b8c:	e8 fc f2 ff ff       	call   800e8d <fd2num>
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	83 c4 10             	add    $0x10,%esp
}
  801b96:	89 d0                	mov    %edx,%eax
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801baf:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	50                   	push   %eax
  801bb6:	e8 91 f2 ff ff       	call   800e4c <sys_ipc_recv>
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	79 16                	jns    801bd8 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801bc2:	85 f6                	test   %esi,%esi
  801bc4:	74 06                	je     801bcc <ipc_recv+0x32>
  801bc6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801bcc:	85 db                	test   %ebx,%ebx
  801bce:	74 2c                	je     801bfc <ipc_recv+0x62>
  801bd0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bd6:	eb 24                	jmp    801bfc <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801bd8:	85 f6                	test   %esi,%esi
  801bda:	74 0a                	je     801be6 <ipc_recv+0x4c>
  801bdc:	a1 04 40 80 00       	mov    0x804004,%eax
  801be1:	8b 40 74             	mov    0x74(%eax),%eax
  801be4:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801be6:	85 db                	test   %ebx,%ebx
  801be8:	74 0a                	je     801bf4 <ipc_recv+0x5a>
  801bea:	a1 04 40 80 00       	mov    0x804004,%eax
  801bef:	8b 40 78             	mov    0x78(%eax),%eax
  801bf2:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801bf4:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	57                   	push   %edi
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801c15:	85 db                	test   %ebx,%ebx
  801c17:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c1c:	0f 44 d8             	cmove  %eax,%ebx
  801c1f:	eb 1c                	jmp    801c3d <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801c21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c24:	74 12                	je     801c38 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801c26:	50                   	push   %eax
  801c27:	68 7a 24 80 00       	push   $0x80247a
  801c2c:	6a 39                	push   $0x39
  801c2e:	68 95 24 80 00       	push   $0x802495
  801c33:	e8 fb e5 ff ff       	call   800233 <_panic>
                 sys_yield();
  801c38:	e8 40 f0 ff ff       	call   800c7d <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c3d:	ff 75 14             	pushl  0x14(%ebp)
  801c40:	53                   	push   %ebx
  801c41:	56                   	push   %esi
  801c42:	57                   	push   %edi
  801c43:	e8 e1 f1 ff ff       	call   800e29 <sys_ipc_try_send>
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 d2                	js     801c21 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c62:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c65:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c6b:	8b 52 50             	mov    0x50(%edx),%edx
  801c6e:	39 ca                	cmp    %ecx,%edx
  801c70:	75 0d                	jne    801c7f <ipc_find_env+0x28>
			return envs[i].env_id;
  801c72:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c75:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801c7a:	8b 40 08             	mov    0x8(%eax),%eax
  801c7d:	eb 0e                	jmp    801c8d <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c7f:	83 c0 01             	add    $0x1,%eax
  801c82:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c87:	75 d9                	jne    801c62 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c89:	66 b8 00 00          	mov    $0x0,%ax
}
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c95:	89 d0                	mov    %edx,%eax
  801c97:	c1 e8 16             	shr    $0x16,%eax
  801c9a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca6:	f6 c1 01             	test   $0x1,%cl
  801ca9:	74 1d                	je     801cc8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cab:	c1 ea 0c             	shr    $0xc,%edx
  801cae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cb5:	f6 c2 01             	test   $0x1,%dl
  801cb8:	74 0e                	je     801cc8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cba:	c1 ea 0c             	shr    $0xc,%edx
  801cbd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cc4:	ef 
  801cc5:	0f b7 c0             	movzwl %ax,%eax
}
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__udivdi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	83 ec 10             	sub    $0x10,%esp
  801cd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801cda:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801cde:	8b 74 24 24          	mov    0x24(%esp),%esi
  801ce2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801ce6:	85 d2                	test   %edx,%edx
  801ce8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cec:	89 34 24             	mov    %esi,(%esp)
  801cef:	89 c8                	mov    %ecx,%eax
  801cf1:	75 35                	jne    801d28 <__udivdi3+0x58>
  801cf3:	39 f1                	cmp    %esi,%ecx
  801cf5:	0f 87 bd 00 00 00    	ja     801db8 <__udivdi3+0xe8>
  801cfb:	85 c9                	test   %ecx,%ecx
  801cfd:	89 cd                	mov    %ecx,%ebp
  801cff:	75 0b                	jne    801d0c <__udivdi3+0x3c>
  801d01:	b8 01 00 00 00       	mov    $0x1,%eax
  801d06:	31 d2                	xor    %edx,%edx
  801d08:	f7 f1                	div    %ecx
  801d0a:	89 c5                	mov    %eax,%ebp
  801d0c:	89 f0                	mov    %esi,%eax
  801d0e:	31 d2                	xor    %edx,%edx
  801d10:	f7 f5                	div    %ebp
  801d12:	89 c6                	mov    %eax,%esi
  801d14:	89 f8                	mov    %edi,%eax
  801d16:	f7 f5                	div    %ebp
  801d18:	89 f2                	mov    %esi,%edx
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	3b 14 24             	cmp    (%esp),%edx
  801d2b:	77 7b                	ja     801da8 <__udivdi3+0xd8>
  801d2d:	0f bd f2             	bsr    %edx,%esi
  801d30:	83 f6 1f             	xor    $0x1f,%esi
  801d33:	0f 84 97 00 00 00    	je     801dd0 <__udivdi3+0x100>
  801d39:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d3e:	89 d7                	mov    %edx,%edi
  801d40:	89 f1                	mov    %esi,%ecx
  801d42:	29 f5                	sub    %esi,%ebp
  801d44:	d3 e7                	shl    %cl,%edi
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	d3 ea                	shr    %cl,%edx
  801d4c:	89 f1                	mov    %esi,%ecx
  801d4e:	09 fa                	or     %edi,%edx
  801d50:	8b 3c 24             	mov    (%esp),%edi
  801d53:	d3 e0                	shl    %cl,%eax
  801d55:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d63:	89 fa                	mov    %edi,%edx
  801d65:	d3 ea                	shr    %cl,%edx
  801d67:	89 f1                	mov    %esi,%ecx
  801d69:	d3 e7                	shl    %cl,%edi
  801d6b:	89 e9                	mov    %ebp,%ecx
  801d6d:	d3 e8                	shr    %cl,%eax
  801d6f:	09 c7                	or     %eax,%edi
  801d71:	89 f8                	mov    %edi,%eax
  801d73:	f7 74 24 08          	divl   0x8(%esp)
  801d77:	89 d5                	mov    %edx,%ebp
  801d79:	89 c7                	mov    %eax,%edi
  801d7b:	f7 64 24 0c          	mull   0xc(%esp)
  801d7f:	39 d5                	cmp    %edx,%ebp
  801d81:	89 14 24             	mov    %edx,(%esp)
  801d84:	72 11                	jb     801d97 <__udivdi3+0xc7>
  801d86:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d8a:	89 f1                	mov    %esi,%ecx
  801d8c:	d3 e2                	shl    %cl,%edx
  801d8e:	39 c2                	cmp    %eax,%edx
  801d90:	73 5e                	jae    801df0 <__udivdi3+0x120>
  801d92:	3b 2c 24             	cmp    (%esp),%ebp
  801d95:	75 59                	jne    801df0 <__udivdi3+0x120>
  801d97:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d9a:	31 f6                	xor    %esi,%esi
  801d9c:	89 f2                	mov    %esi,%edx
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	31 f6                	xor    %esi,%esi
  801daa:	31 c0                	xor    %eax,%eax
  801dac:	89 f2                	mov    %esi,%edx
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	31 f6                	xor    %esi,%esi
  801dbc:	89 f8                	mov    %edi,%eax
  801dbe:	f7 f1                	div    %ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dd4:	76 0b                	jbe    801de1 <__udivdi3+0x111>
  801dd6:	31 c0                	xor    %eax,%eax
  801dd8:	3b 14 24             	cmp    (%esp),%edx
  801ddb:	0f 83 37 ff ff ff    	jae    801d18 <__udivdi3+0x48>
  801de1:	b8 01 00 00 00       	mov    $0x1,%eax
  801de6:	e9 2d ff ff ff       	jmp    801d18 <__udivdi3+0x48>
  801deb:	90                   	nop
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	89 f8                	mov    %edi,%eax
  801df2:	31 f6                	xor    %esi,%esi
  801df4:	e9 1f ff ff ff       	jmp    801d18 <__udivdi3+0x48>
  801df9:	66 90                	xchg   %ax,%ax
  801dfb:	66 90                	xchg   %ax,%ax
  801dfd:	66 90                	xchg   %ax,%ax
  801dff:	90                   	nop

00801e00 <__umoddi3>:
  801e00:	55                   	push   %ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	83 ec 20             	sub    $0x20,%esp
  801e06:	8b 44 24 34          	mov    0x34(%esp),%eax
  801e0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e12:	89 c6                	mov    %eax,%esi
  801e14:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801e20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e28:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	89 c2                	mov    %eax,%edx
  801e30:	75 1e                	jne    801e50 <__umoddi3+0x50>
  801e32:	39 f7                	cmp    %esi,%edi
  801e34:	76 52                	jbe    801e88 <__umoddi3+0x88>
  801e36:	89 c8                	mov    %ecx,%eax
  801e38:	89 f2                	mov    %esi,%edx
  801e3a:	f7 f7                	div    %edi
  801e3c:	89 d0                	mov    %edx,%eax
  801e3e:	31 d2                	xor    %edx,%edx
  801e40:	83 c4 20             	add    $0x20,%esp
  801e43:	5e                   	pop    %esi
  801e44:	5f                   	pop    %edi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    
  801e47:	89 f6                	mov    %esi,%esi
  801e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e50:	39 f0                	cmp    %esi,%eax
  801e52:	77 5c                	ja     801eb0 <__umoddi3+0xb0>
  801e54:	0f bd e8             	bsr    %eax,%ebp
  801e57:	83 f5 1f             	xor    $0x1f,%ebp
  801e5a:	75 64                	jne    801ec0 <__umoddi3+0xc0>
  801e5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801e60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801e64:	0f 86 f6 00 00 00    	jbe    801f60 <__umoddi3+0x160>
  801e6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801e6e:	0f 82 ec 00 00 00    	jb     801f60 <__umoddi3+0x160>
  801e74:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e78:	8b 54 24 18          	mov    0x18(%esp),%edx
  801e7c:	83 c4 20             	add    $0x20,%esp
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    
  801e83:	90                   	nop
  801e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e88:	85 ff                	test   %edi,%edi
  801e8a:	89 fd                	mov    %edi,%ebp
  801e8c:	75 0b                	jne    801e99 <__umoddi3+0x99>
  801e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e93:	31 d2                	xor    %edx,%edx
  801e95:	f7 f7                	div    %edi
  801e97:	89 c5                	mov    %eax,%ebp
  801e99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	f7 f5                	div    %ebp
  801ea1:	89 c8                	mov    %ecx,%eax
  801ea3:	f7 f5                	div    %ebp
  801ea5:	eb 95                	jmp    801e3c <__umoddi3+0x3c>
  801ea7:	89 f6                	mov    %esi,%esi
  801ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	83 c4 20             	add    $0x20,%esp
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    
  801ebb:	90                   	nop
  801ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	b8 20 00 00 00       	mov    $0x20,%eax
  801ec5:	89 e9                	mov    %ebp,%ecx
  801ec7:	29 e8                	sub    %ebp,%eax
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	89 c7                	mov    %eax,%edi
  801ecd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ed1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	89 c1                	mov    %eax,%ecx
  801edb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801edf:	09 d1                	or     %edx,%ecx
  801ee1:	89 fa                	mov    %edi,%edx
  801ee3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ee7:	89 e9                	mov    %ebp,%ecx
  801ee9:	d3 e0                	shl    %cl,%eax
  801eeb:	89 f9                	mov    %edi,%ecx
  801eed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef1:	89 f0                	mov    %esi,%eax
  801ef3:	d3 e8                	shr    %cl,%eax
  801ef5:	89 e9                	mov    %ebp,%ecx
  801ef7:	89 c7                	mov    %eax,%edi
  801ef9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801efd:	d3 e6                	shl    %cl,%esi
  801eff:	89 d1                	mov    %edx,%ecx
  801f01:	89 fa                	mov    %edi,%edx
  801f03:	d3 e8                	shr    %cl,%eax
  801f05:	89 e9                	mov    %ebp,%ecx
  801f07:	09 f0                	or     %esi,%eax
  801f09:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801f0d:	f7 74 24 10          	divl   0x10(%esp)
  801f11:	d3 e6                	shl    %cl,%esi
  801f13:	89 d1                	mov    %edx,%ecx
  801f15:	f7 64 24 0c          	mull   0xc(%esp)
  801f19:	39 d1                	cmp    %edx,%ecx
  801f1b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801f1f:	89 d7                	mov    %edx,%edi
  801f21:	89 c6                	mov    %eax,%esi
  801f23:	72 0a                	jb     801f2f <__umoddi3+0x12f>
  801f25:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801f29:	73 10                	jae    801f3b <__umoddi3+0x13b>
  801f2b:	39 d1                	cmp    %edx,%ecx
  801f2d:	75 0c                	jne    801f3b <__umoddi3+0x13b>
  801f2f:	89 d7                	mov    %edx,%edi
  801f31:	89 c6                	mov    %eax,%esi
  801f33:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801f37:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801f3b:	89 ca                	mov    %ecx,%edx
  801f3d:	89 e9                	mov    %ebp,%ecx
  801f3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f43:	29 f0                	sub    %esi,%eax
  801f45:	19 fa                	sbb    %edi,%edx
  801f47:	d3 e8                	shr    %cl,%eax
  801f49:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801f4e:	89 d7                	mov    %edx,%edi
  801f50:	d3 e7                	shl    %cl,%edi
  801f52:	89 e9                	mov    %ebp,%ecx
  801f54:	09 f8                	or     %edi,%eax
  801f56:	d3 ea                	shr    %cl,%edx
  801f58:	83 c4 20             	add    $0x20,%esp
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    
  801f5f:	90                   	nop
  801f60:	8b 74 24 10          	mov    0x10(%esp),%esi
  801f64:	29 f9                	sub    %edi,%ecx
  801f66:	19 c6                	sbb    %eax,%esi
  801f68:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f6c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f70:	e9 ff fe ff ff       	jmp    801e74 <__umoddi3+0x74>
