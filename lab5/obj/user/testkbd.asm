
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 c5 0d 00 00       	call   800e09 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 66 11 00 00       	call   8011b9 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 20 80 00       	push   $0x8020c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 20 80 00       	push   $0x8020cd
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 20 80 00       	push   $0x8020dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 20 80 00       	push   $0x8020cd
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 78 11 00 00       	call   80120b <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 20 80 00       	push   $0x8020f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 20 80 00       	push   $0x8020cd
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 20 80 00       	push   $0x8020fe
  8000b4:	e8 3a 08 00 00       	call   8008f3 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 21 80 00       	push   $0x80210c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 5d 18 00 00       	call   80192d <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 21 80 00       	push   $0x802110
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 49 18 00 00       	call   80192d <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 28 21 80 00       	push   $0x802128
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 19 09 00 00       	call   800a1f <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 6d 0a 00 00       	call   800bb1 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 1e 0c 00 00       	call   800d6c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	75 07                	jne    80017a <devcons_read+0x18>
  800173:	eb 28                	jmp    80019d <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 8f 0c 00 00       	call   800e09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 0b 0c 00 00       	call   800d8a <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 b6 0b 00 00       	call   800d6c <sys_cputs>
  8001b6:	83 c4 10             	add    $0x10,%esp
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 2b 11 00 00       	call   8012f9 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 97 0e 00 00       	call   80108f <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 1f 0e 00 00       	call   801040 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 ec 0b 00 00       	call   800e28 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 b6 0d 00 00       	call   801019 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800277:	e8 6e 0b 00 00       	call   800dea <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
  8002a8:	83 c4 10             	add    $0x10,%esp
}
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 29 0f 00 00       	call   8011e6 <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 e2 0a 00 00       	call   800da9 <sys_env_destroy>
  8002c7:	83 c4 10             	add    $0x10,%esp
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 0b 0b 00 00       	call   800dea <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 40 21 80 00       	push   $0x802140
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 26 21 80 00 	movl   $0x802126,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 2a 0a 00 00       	call   800d6c <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 4f 01 00 00       	call   8004d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 cf 09 00 00       	call   800d6c <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 d1                	mov    %edx,%ecx
  8003ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003e4:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8003e7:	72 05                	jb     8003ee <printnum+0x35>
  8003e9:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003ec:	77 3e                	ja     80042c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ee:	83 ec 0c             	sub    $0xc,%esp
  8003f1:	ff 75 18             	pushl  0x18(%ebp)
  8003f4:	83 eb 01             	sub    $0x1,%ebx
  8003f7:	53                   	push   %ebx
  8003f8:	50                   	push   %eax
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 e3 19 00 00       	call   801df0 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 13                	jmp    800433 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042c:	83 eb 01             	sub    $0x1,%ebx
  80042f:	85 db                	test   %ebx,%ebx
  800431:	7f ed                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	56                   	push   %esi
  800437:	83 ec 04             	sub    $0x4,%esp
  80043a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff 75 dc             	pushl  -0x24(%ebp)
  800443:	ff 75 d8             	pushl  -0x28(%ebp)
  800446:	e8 d5 1a 00 00       	call   801f20 <__umoddi3>
  80044b:	83 c4 14             	add    $0x14,%esp
  80044e:	0f be 80 63 21 80 00 	movsbl 0x802163(%eax),%eax
  800455:	50                   	push   %eax
  800456:	ff d7                	call   *%edi
  800458:	83 c4 10             	add    $0x10,%esp
}
  80045b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80045e:	5b                   	pop    %ebx
  80045f:	5e                   	pop    %esi
  800460:	5f                   	pop    %edi
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800466:	83 fa 01             	cmp    $0x1,%edx
  800469:	7e 0e                	jle    800479 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80046b:	8b 10                	mov    (%eax),%edx
  80046d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800470:	89 08                	mov    %ecx,(%eax)
  800472:	8b 02                	mov    (%edx),%eax
  800474:	8b 52 04             	mov    0x4(%edx),%edx
  800477:	eb 22                	jmp    80049b <getuint+0x38>
	else if (lflag)
  800479:	85 d2                	test   %edx,%edx
  80047b:	74 10                	je     80048d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047d:	8b 10                	mov    (%eax),%edx
  80047f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 02                	mov    (%edx),%eax
  800486:	ba 00 00 00 00       	mov    $0x0,%edx
  80048b:	eb 0e                	jmp    80049b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048d:	8b 10                	mov    (%eax),%edx
  80048f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800492:	89 08                	mov    %ecx,(%eax)
  800494:	8b 02                	mov    (%edx),%eax
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a7:	8b 10                	mov    (%eax),%edx
  8004a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ac:	73 0a                	jae    8004b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b6:	88 02                	mov    %al,(%edx)
}
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    

008004ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
  8004bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c3:	50                   	push   %eax
  8004c4:	ff 75 10             	pushl  0x10(%ebp)
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 05 00 00 00       	call   8004d7 <vprintfmt>
	va_end(ap);
  8004d2:	83 c4 10             	add    $0x10,%esp
}
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	53                   	push   %ebx
  8004dd:	83 ec 2c             	sub    $0x2c,%esp
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e9:	eb 12                	jmp    8004fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	0f 84 90 03 00 00    	je     800883 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	50                   	push   %eax
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fd:	83 c7 01             	add    $0x1,%edi
  800500:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800504:	83 f8 25             	cmp    $0x25,%eax
  800507:	75 e2                	jne    8004eb <vprintfmt+0x14>
  800509:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80050d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800514:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800522:	ba 00 00 00 00       	mov    $0x0,%edx
  800527:	eb 07                	jmp    800530 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80052c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8d 47 01             	lea    0x1(%edi),%eax
  800533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800536:	0f b6 07             	movzbl (%edi),%eax
  800539:	0f b6 c8             	movzbl %al,%ecx
  80053c:	83 e8 23             	sub    $0x23,%eax
  80053f:	3c 55                	cmp    $0x55,%al
  800541:	0f 87 21 03 00 00    	ja     800868 <vprintfmt+0x391>
  800547:	0f b6 c0             	movzbl %al,%eax
  80054a:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800554:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800558:	eb d6                	jmp    800530 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800565:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800568:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80056c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80056f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800572:	83 fa 09             	cmp    $0x9,%edx
  800575:	77 39                	ja     8005b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800577:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057a:	eb e9                	jmp    800565 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 48 04             	lea    0x4(%eax),%ecx
  800582:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058d:	eb 27                	jmp    8005b6 <vprintfmt+0xdf>
  80058f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800592:	85 c0                	test   %eax,%eax
  800594:	b9 00 00 00 00       	mov    $0x0,%ecx
  800599:	0f 49 c8             	cmovns %eax,%ecx
  80059c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a2:	eb 8c                	jmp    800530 <vprintfmt+0x59>
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ae:	eb 80                	jmp    800530 <vprintfmt+0x59>
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ba:	0f 89 70 ff ff ff    	jns    800530 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cd:	e9 5e ff ff ff       	jmp    800530 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d8:	e9 53 ff ff ff       	jmp    800530 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 30                	pushl  (%eax)
  8005ec:	ff d6                	call   *%esi
			break;
  8005ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f4:	e9 04 ff ff ff       	jmp    8004fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	99                   	cltd   
  800605:	31 d0                	xor    %edx,%eax
  800607:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800609:	83 f8 0f             	cmp    $0xf,%eax
  80060c:	7f 0b                	jg     800619 <vprintfmt+0x142>
  80060e:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800615:	85 d2                	test   %edx,%edx
  800617:	75 18                	jne    800631 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800619:	50                   	push   %eax
  80061a:	68 7b 21 80 00       	push   $0x80217b
  80061f:	53                   	push   %ebx
  800620:	56                   	push   %esi
  800621:	e8 94 fe ff ff       	call   8004ba <printfmt>
  800626:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062c:	e9 cc fe ff ff       	jmp    8004fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800631:	52                   	push   %edx
  800632:	68 85 25 80 00       	push   $0x802585
  800637:	53                   	push   %ebx
  800638:	56                   	push   %esi
  800639:	e8 7c fe ff ff       	call   8004ba <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 b4 fe ff ff       	jmp    8004fd <vprintfmt+0x26>
  800649:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80064c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80065d:	85 ff                	test   %edi,%edi
  80065f:	ba 74 21 80 00       	mov    $0x802174,%edx
  800664:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800667:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80066b:	0f 84 92 00 00 00    	je     800703 <vprintfmt+0x22c>
  800671:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800675:	0f 8e 96 00 00 00    	jle    800711 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	51                   	push   %ecx
  80067f:	57                   	push   %edi
  800680:	e8 79 03 00 00       	call   8009fe <strnlen>
  800685:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800688:	29 c1                	sub    %eax,%ecx
  80068a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800690:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800694:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800697:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069c:	eb 0f                	jmp    8006ad <vprintfmt+0x1d6>
					putch(padc, putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	83 ef 01             	sub    $0x1,%edi
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	85 ff                	test   %edi,%edi
  8006af:	7f ed                	jg     80069e <vprintfmt+0x1c7>
  8006b1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006be:	0f 49 c1             	cmovns %ecx,%eax
  8006c1:	29 c1                	sub    %eax,%ecx
  8006c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cc:	89 cb                	mov    %ecx,%ebx
  8006ce:	eb 4d                	jmp    80071d <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d4:	74 1b                	je     8006f1 <vprintfmt+0x21a>
  8006d6:	0f be c0             	movsbl %al,%eax
  8006d9:	83 e8 20             	sub    $0x20,%eax
  8006dc:	83 f8 5e             	cmp    $0x5e,%eax
  8006df:	76 10                	jbe    8006f1 <vprintfmt+0x21a>
					putch('?', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	6a 3f                	push   $0x3f
  8006e9:	ff 55 08             	call   *0x8(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 0d                	jmp    8006fe <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	52                   	push   %edx
  8006f8:	ff 55 08             	call   *0x8(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	83 eb 01             	sub    $0x1,%ebx
  800701:	eb 1a                	jmp    80071d <vprintfmt+0x246>
  800703:	89 75 08             	mov    %esi,0x8(%ebp)
  800706:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800709:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070f:	eb 0c                	jmp    80071d <vprintfmt+0x246>
  800711:	89 75 08             	mov    %esi,0x8(%ebp)
  800714:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800717:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071d:	83 c7 01             	add    $0x1,%edi
  800720:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800724:	0f be d0             	movsbl %al,%edx
  800727:	85 d2                	test   %edx,%edx
  800729:	74 23                	je     80074e <vprintfmt+0x277>
  80072b:	85 f6                	test   %esi,%esi
  80072d:	78 a1                	js     8006d0 <vprintfmt+0x1f9>
  80072f:	83 ee 01             	sub    $0x1,%esi
  800732:	79 9c                	jns    8006d0 <vprintfmt+0x1f9>
  800734:	89 df                	mov    %ebx,%edi
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073c:	eb 18                	jmp    800756 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 20                	push   $0x20
  800744:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 08                	jmp    800756 <vprintfmt+0x27f>
  80074e:	89 df                	mov    %ebx,%edi
  800750:	8b 75 08             	mov    0x8(%ebp),%esi
  800753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800756:	85 ff                	test   %edi,%edi
  800758:	7f e4                	jg     80073e <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075d:	e9 9b fd ff ff       	jmp    8004fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800762:	83 fa 01             	cmp    $0x1,%edx
  800765:	7e 16                	jle    80077d <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 08             	lea    0x8(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)
  800770:	8b 50 04             	mov    0x4(%eax),%edx
  800773:	8b 00                	mov    (%eax),%eax
  800775:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800778:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077b:	eb 32                	jmp    8007af <vprintfmt+0x2d8>
	else if (lflag)
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 18                	je     800799 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078f:	89 c1                	mov    %eax,%ecx
  800791:	c1 f9 1f             	sar    $0x1f,%ecx
  800794:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800797:	eb 16                	jmp    8007af <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 50 04             	lea    0x4(%eax),%edx
  80079f:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a7:	89 c1                	mov    %eax,%ecx
  8007a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007be:	79 74                	jns    800834 <vprintfmt+0x35d>
				putch('-', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	6a 2d                	push   $0x2d
  8007c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ce:	f7 d8                	neg    %eax
  8007d0:	83 d2 00             	adc    $0x0,%edx
  8007d3:	f7 da                	neg    %edx
  8007d5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007dd:	eb 55                	jmp    800834 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e2:	e8 7c fc ff ff       	call   800463 <getuint>
			base = 10;
  8007e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ec:	eb 46                	jmp    800834 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f1:	e8 6d fc ff ff       	call   800463 <getuint>
                        base = 8;
  8007f6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8007fb:	eb 37                	jmp    800834 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	53                   	push   %ebx
  800801:	6a 30                	push   $0x30
  800803:	ff d6                	call   *%esi
			putch('x', putdat);
  800805:	83 c4 08             	add    $0x8,%esp
  800808:	53                   	push   %ebx
  800809:	6a 78                	push   $0x78
  80080b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8d 50 04             	lea    0x4(%eax),%edx
  800813:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800816:	8b 00                	mov    (%eax),%eax
  800818:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800820:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800825:	eb 0d                	jmp    800834 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	e8 34 fc ff ff       	call   800463 <getuint>
			base = 16;
  80082f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800834:	83 ec 0c             	sub    $0xc,%esp
  800837:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80083b:	57                   	push   %edi
  80083c:	ff 75 e0             	pushl  -0x20(%ebp)
  80083f:	51                   	push   %ecx
  800840:	52                   	push   %edx
  800841:	50                   	push   %eax
  800842:	89 da                	mov    %ebx,%edx
  800844:	89 f0                	mov    %esi,%eax
  800846:	e8 6e fb ff ff       	call   8003b9 <printnum>
			break;
  80084b:	83 c4 20             	add    $0x20,%esp
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800851:	e9 a7 fc ff ff       	jmp    8004fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	51                   	push   %ecx
  80085b:	ff d6                	call   *%esi
			break;
  80085d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800863:	e9 95 fc ff ff       	jmp    8004fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 25                	push   $0x25
  80086e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 03                	jmp    800878 <vprintfmt+0x3a1>
  800875:	83 ef 01             	sub    $0x1,%edi
  800878:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087c:	75 f7                	jne    800875 <vprintfmt+0x39e>
  80087e:	e9 7a fc ff ff       	jmp    8004fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800883:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5f                   	pop    %edi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 18             	sub    $0x18,%esp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800897:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	74 26                	je     8008d2 <vsnprintf+0x47>
  8008ac:	85 d2                	test   %edx,%edx
  8008ae:	7e 22                	jle    8008d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b0:	ff 75 14             	pushl  0x14(%ebp)
  8008b3:	ff 75 10             	pushl  0x10(%ebp)
  8008b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	68 9d 04 80 00       	push   $0x80049d
  8008bf:	e8 13 fc ff ff       	call   8004d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	eb 05                	jmp    8008d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e2:	50                   	push   %eax
  8008e3:	ff 75 10             	pushl  0x10(%ebp)
  8008e6:	ff 75 0c             	pushl  0xc(%ebp)
  8008e9:	ff 75 08             	pushl  0x8(%ebp)
  8008ec:	e8 9a ff ff ff       	call   80088b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	83 ec 0c             	sub    $0xc,%esp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8008ff:	85 c0                	test   %eax,%eax
  800901:	74 13                	je     800916 <readline+0x23>
		fprintf(1, "%s", prompt);
  800903:	83 ec 04             	sub    $0x4,%esp
  800906:	50                   	push   %eax
  800907:	68 85 25 80 00       	push   $0x802585
  80090c:	6a 01                	push   $0x1
  80090e:	e8 1a 10 00 00       	call   80192d <fprintf>
  800913:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800916:	83 ec 0c             	sub    $0xc,%esp
  800919:	6a 00                	push   $0x0
  80091b:	e8 c6 f8 ff ff       	call   8001e6 <iscons>
  800920:	89 c7                	mov    %eax,%edi
  800922:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800925:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80092a:	e8 8c f8 ff ff       	call   8001bb <getchar>
  80092f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800931:	85 c0                	test   %eax,%eax
  800933:	79 29                	jns    80095e <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80093a:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80093d:	0f 84 9b 00 00 00    	je     8009de <readline+0xeb>
				cprintf("read error: %e\n", c);
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	53                   	push   %ebx
  800947:	68 9f 24 80 00       	push   $0x80249f
  80094c:	e8 54 fa ff ff       	call   8003a5 <cprintf>
  800951:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
  800959:	e9 80 00 00 00       	jmp    8009de <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80095e:	83 f8 7f             	cmp    $0x7f,%eax
  800961:	0f 94 c2             	sete   %dl
  800964:	83 f8 08             	cmp    $0x8,%eax
  800967:	0f 94 c0             	sete   %al
  80096a:	08 c2                	or     %al,%dl
  80096c:	74 1a                	je     800988 <readline+0x95>
  80096e:	85 f6                	test   %esi,%esi
  800970:	7e 16                	jle    800988 <readline+0x95>
			if (echoing)
  800972:	85 ff                	test   %edi,%edi
  800974:	74 0d                	je     800983 <readline+0x90>
				cputchar('\b');
  800976:	83 ec 0c             	sub    $0xc,%esp
  800979:	6a 08                	push   $0x8
  80097b:	e8 1f f8 ff ff       	call   80019f <cputchar>
  800980:	83 c4 10             	add    $0x10,%esp
			i--;
  800983:	83 ee 01             	sub    $0x1,%esi
  800986:	eb a2                	jmp    80092a <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800988:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80098e:	7f 23                	jg     8009b3 <readline+0xc0>
  800990:	83 fb 1f             	cmp    $0x1f,%ebx
  800993:	7e 1e                	jle    8009b3 <readline+0xc0>
			if (echoing)
  800995:	85 ff                	test   %edi,%edi
  800997:	74 0c                	je     8009a5 <readline+0xb2>
				cputchar(c);
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	53                   	push   %ebx
  80099d:	e8 fd f7 ff ff       	call   80019f <cputchar>
  8009a2:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009a5:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009ab:	8d 76 01             	lea    0x1(%esi),%esi
  8009ae:	e9 77 ff ff ff       	jmp    80092a <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009b3:	83 fb 0d             	cmp    $0xd,%ebx
  8009b6:	74 09                	je     8009c1 <readline+0xce>
  8009b8:	83 fb 0a             	cmp    $0xa,%ebx
  8009bb:	0f 85 69 ff ff ff    	jne    80092a <readline+0x37>
			if (echoing)
  8009c1:	85 ff                	test   %edi,%edi
  8009c3:	74 0d                	je     8009d2 <readline+0xdf>
				cputchar('\n');
  8009c5:	83 ec 0c             	sub    $0xc,%esp
  8009c8:	6a 0a                	push   $0xa
  8009ca:	e8 d0 f7 ff ff       	call   80019f <cputchar>
  8009cf:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009d2:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009d9:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 03                	jmp    8009f6 <strlen+0x10>
		n++;
  8009f3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fa:	75 f7                	jne    8009f3 <strlen+0xd>
		n++;
	return n;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a04:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	eb 03                	jmp    800a11 <strnlen+0x13>
		n++;
  800a0e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a11:	39 c2                	cmp    %eax,%edx
  800a13:	74 08                	je     800a1d <strnlen+0x1f>
  800a15:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a19:	75 f3                	jne    800a0e <strnlen+0x10>
  800a1b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a35:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a38:	84 db                	test   %bl,%bl
  800a3a:	75 ef                	jne    800a2b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a46:	53                   	push   %ebx
  800a47:	e8 9a ff ff ff       	call   8009e6 <strlen>
  800a4c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	01 d8                	add    %ebx,%eax
  800a54:	50                   	push   %eax
  800a55:	e8 c5 ff ff ff       	call   800a1f <strcpy>
	return dst;
}
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 75 08             	mov    0x8(%ebp),%esi
  800a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a71:	89 f2                	mov    %esi,%edx
  800a73:	eb 0f                	jmp    800a84 <strncpy+0x23>
		*dst++ = *src;
  800a75:	83 c2 01             	add    $0x1,%edx
  800a78:	0f b6 01             	movzbl (%ecx),%eax
  800a7b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a81:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a84:	39 da                	cmp    %ebx,%edx
  800a86:	75 ed                	jne    800a75 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 75 08             	mov    0x8(%ebp),%esi
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a9e:	85 d2                	test   %edx,%edx
  800aa0:	74 21                	je     800ac3 <strlcpy+0x35>
  800aa2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa6:	89 f2                	mov    %esi,%edx
  800aa8:	eb 09                	jmp    800ab3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aaa:	83 c2 01             	add    $0x1,%edx
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab3:	39 c2                	cmp    %eax,%edx
  800ab5:	74 09                	je     800ac0 <strlcpy+0x32>
  800ab7:	0f b6 19             	movzbl (%ecx),%ebx
  800aba:	84 db                	test   %bl,%bl
  800abc:	75 ec                	jne    800aaa <strlcpy+0x1c>
  800abe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ac0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac3:	29 f0                	sub    %esi,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad2:	eb 06                	jmp    800ada <strcmp+0x11>
		p++, q++;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ada:	0f b6 01             	movzbl (%ecx),%eax
  800add:	84 c0                	test   %al,%al
  800adf:	74 04                	je     800ae5 <strcmp+0x1c>
  800ae1:	3a 02                	cmp    (%edx),%al
  800ae3:	74 ef                	je     800ad4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
}
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800afe:	eb 06                	jmp    800b06 <strncmp+0x17>
		n--, p++, q++;
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b06:	39 d8                	cmp    %ebx,%eax
  800b08:	74 15                	je     800b1f <strncmp+0x30>
  800b0a:	0f b6 08             	movzbl (%eax),%ecx
  800b0d:	84 c9                	test   %cl,%cl
  800b0f:	74 04                	je     800b15 <strncmp+0x26>
  800b11:	3a 0a                	cmp    (%edx),%cl
  800b13:	74 eb                	je     800b00 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b15:	0f b6 00             	movzbl (%eax),%eax
  800b18:	0f b6 12             	movzbl (%edx),%edx
  800b1b:	29 d0                	sub    %edx,%eax
  800b1d:	eb 05                	jmp    800b24 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b31:	eb 07                	jmp    800b3a <strchr+0x13>
		if (*s == c)
  800b33:	38 ca                	cmp    %cl,%dl
  800b35:	74 0f                	je     800b46 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b37:	83 c0 01             	add    $0x1,%eax
  800b3a:	0f b6 10             	movzbl (%eax),%edx
  800b3d:	84 d2                	test   %dl,%dl
  800b3f:	75 f2                	jne    800b33 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b52:	eb 03                	jmp    800b57 <strfind+0xf>
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b5a:	84 d2                	test   %dl,%dl
  800b5c:	74 04                	je     800b62 <strfind+0x1a>
  800b5e:	38 ca                	cmp    %cl,%dl
  800b60:	75 f2                	jne    800b54 <strfind+0xc>
			break;
	return (char *) s;
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b70:	85 c9                	test   %ecx,%ecx
  800b72:	74 36                	je     800baa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 28                	jne    800ba4 <memset+0x40>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 23                	jne    800ba4 <memset+0x40>
		c &= 0xFF;
  800b81:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 c2                	or     %eax,%edx
  800b98:	89 d0                	mov    %edx,%eax
  800b9a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b9f:	fc                   	cld    
  800ba0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba2:	eb 06                	jmp    800baa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	fc                   	cld    
  800ba8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800baa:	89 f8                	mov    %edi,%eax
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbf:	39 c6                	cmp    %eax,%esi
  800bc1:	73 35                	jae    800bf8 <memmove+0x47>
  800bc3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc6:	39 d0                	cmp    %edx,%eax
  800bc8:	73 2e                	jae    800bf8 <memmove+0x47>
		s += n;
		d += n;
  800bca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd7:	75 13                	jne    800bec <memmove+0x3b>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 0e                	jne    800bec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bde:	83 ef 04             	sub    $0x4,%edi
  800be1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800be7:	fd                   	std    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb 09                	jmp    800bf5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bec:	83 ef 01             	sub    $0x1,%edi
  800bef:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf2:	fd                   	std    
  800bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf5:	fc                   	cld    
  800bf6:	eb 1d                	jmp    800c15 <memmove+0x64>
  800bf8:	89 f2                	mov    %esi,%edx
  800bfa:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfc:	f6 c2 03             	test   $0x3,%dl
  800bff:	75 0f                	jne    800c10 <memmove+0x5f>
  800c01:	f6 c1 03             	test   $0x3,%cl
  800c04:	75 0a                	jne    800c10 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c06:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 05                	jmp    800c15 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c10:	89 c7                	mov    %eax,%edi
  800c12:	fc                   	cld    
  800c13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1c:	ff 75 10             	pushl  0x10(%ebp)
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	e8 87 ff ff ff       	call   800bb1 <memmove>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c37:	89 c6                	mov    %eax,%esi
  800c39:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3c:	eb 1a                	jmp    800c58 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3e:	0f b6 08             	movzbl (%eax),%ecx
  800c41:	0f b6 1a             	movzbl (%edx),%ebx
  800c44:	38 d9                	cmp    %bl,%cl
  800c46:	74 0a                	je     800c52 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c48:	0f b6 c1             	movzbl %cl,%eax
  800c4b:	0f b6 db             	movzbl %bl,%ebx
  800c4e:	29 d8                	sub    %ebx,%eax
  800c50:	eb 0f                	jmp    800c61 <memcmp+0x35>
		s1++, s2++;
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	75 e2                	jne    800c3e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c73:	eb 07                	jmp    800c7c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c75:	38 08                	cmp    %cl,(%eax)
  800c77:	74 07                	je     800c80 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	39 d0                	cmp    %edx,%eax
  800c7e:	72 f5                	jb     800c75 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8e:	eb 03                	jmp    800c93 <strtol+0x11>
		s++;
  800c90:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c93:	0f b6 01             	movzbl (%ecx),%eax
  800c96:	3c 09                	cmp    $0x9,%al
  800c98:	74 f6                	je     800c90 <strtol+0xe>
  800c9a:	3c 20                	cmp    $0x20,%al
  800c9c:	74 f2                	je     800c90 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9e:	3c 2b                	cmp    $0x2b,%al
  800ca0:	75 0a                	jne    800cac <strtol+0x2a>
		s++;
  800ca2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca5:	bf 00 00 00 00       	mov    $0x0,%edi
  800caa:	eb 10                	jmp    800cbc <strtol+0x3a>
  800cac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb1:	3c 2d                	cmp    $0x2d,%al
  800cb3:	75 07                	jne    800cbc <strtol+0x3a>
		s++, neg = 1;
  800cb5:	8d 49 01             	lea    0x1(%ecx),%ecx
  800cb8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	0f 94 c0             	sete   %al
  800cc1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc7:	75 19                	jne    800ce2 <strtol+0x60>
  800cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccc:	75 14                	jne    800ce2 <strtol+0x60>
  800cce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd2:	0f 85 82 00 00 00    	jne    800d5a <strtol+0xd8>
		s += 2, base = 16;
  800cd8:	83 c1 02             	add    $0x2,%ecx
  800cdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce0:	eb 16                	jmp    800cf8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ce2:	84 c0                	test   %al,%al
  800ce4:	74 12                	je     800cf8 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ceb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cee:	75 08                	jne    800cf8 <strtol+0x76>
		s++, base = 8;
  800cf0:	83 c1 01             	add    $0x1,%ecx
  800cf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d00:	0f b6 11             	movzbl (%ecx),%edx
  800d03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d06:	89 f3                	mov    %esi,%ebx
  800d08:	80 fb 09             	cmp    $0x9,%bl
  800d0b:	77 08                	ja     800d15 <strtol+0x93>
			dig = *s - '0';
  800d0d:	0f be d2             	movsbl %dl,%edx
  800d10:	83 ea 30             	sub    $0x30,%edx
  800d13:	eb 22                	jmp    800d37 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800d15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d18:	89 f3                	mov    %esi,%ebx
  800d1a:	80 fb 19             	cmp    $0x19,%bl
  800d1d:	77 08                	ja     800d27 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800d1f:	0f be d2             	movsbl %dl,%edx
  800d22:	83 ea 57             	sub    $0x57,%edx
  800d25:	eb 10                	jmp    800d37 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800d27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d2a:	89 f3                	mov    %esi,%ebx
  800d2c:	80 fb 19             	cmp    $0x19,%bl
  800d2f:	77 16                	ja     800d47 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d31:	0f be d2             	movsbl %dl,%edx
  800d34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d3a:	7d 0f                	jge    800d4b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800d3c:	83 c1 01             	add    $0x1,%ecx
  800d3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d45:	eb b9                	jmp    800d00 <strtol+0x7e>
  800d47:	89 c2                	mov    %eax,%edx
  800d49:	eb 02                	jmp    800d4d <strtol+0xcb>
  800d4b:	89 c2                	mov    %eax,%edx

	if (endptr)
  800d4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d51:	74 0d                	je     800d60 <strtol+0xde>
		*endptr = (char *) s;
  800d53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d56:	89 0e                	mov    %ecx,(%esi)
  800d58:	eb 06                	jmp    800d60 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d5a:	84 c0                	test   %al,%al
  800d5c:	75 92                	jne    800cf0 <strtol+0x6e>
  800d5e:	eb 98                	jmp    800cf8 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d60:	f7 da                	neg    %edx
  800d62:	85 ff                	test   %edi,%edi
  800d64:	0f 45 c2             	cmovne %edx,%eax
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b8 00 00 00 00       	mov    $0x0,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 c3                	mov    %eax,%ebx
  800d7f:	89 c7                	mov    %eax,%edi
  800d81:	89 c6                	mov    %eax,%esi
  800d83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9a:	89 d1                	mov    %edx,%ecx
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 d7                	mov    %edx,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db7:	b8 03 00 00 00       	mov    $0x3,%eax
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 cb                	mov    %ecx,%ebx
  800dc1:	89 cf                	mov    %ecx,%edi
  800dc3:	89 ce                	mov    %ecx,%esi
  800dc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 17                	jle    800de2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 03                	push   $0x3
  800dd1:	68 af 24 80 00       	push   $0x8024af
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 cc 24 80 00       	push   $0x8024cc
  800ddd:	e8 ea f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	ba 00 00 00 00       	mov    $0x0,%edx
  800df5:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfa:	89 d1                	mov    %edx,%ecx
  800dfc:	89 d3                	mov    %edx,%ebx
  800dfe:	89 d7                	mov    %edx,%edi
  800e00:	89 d6                	mov    %edx,%esi
  800e02:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_yield>:

void
sys_yield(void)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e19:	89 d1                	mov    %edx,%ecx
  800e1b:	89 d3                	mov    %edx,%ebx
  800e1d:	89 d7                	mov    %edx,%edi
  800e1f:	89 d6                	mov    %edx,%esi
  800e21:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	be 00 00 00 00       	mov    $0x0,%esi
  800e36:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e44:	89 f7                	mov    %esi,%edi
  800e46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7e 17                	jle    800e63 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	50                   	push   %eax
  800e50:	6a 04                	push   $0x4
  800e52:	68 af 24 80 00       	push   $0x8024af
  800e57:	6a 23                	push   $0x23
  800e59:	68 cc 24 80 00       	push   $0x8024cc
  800e5e:	e8 69 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	b8 05 00 00 00       	mov    $0x5,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	8b 75 18             	mov    0x18(%ebp),%esi
  800e88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 17                	jle    800ea5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	50                   	push   %eax
  800e92:	6a 05                	push   $0x5
  800e94:	68 af 24 80 00       	push   $0x8024af
  800e99:	6a 23                	push   $0x23
  800e9b:	68 cc 24 80 00       	push   $0x8024cc
  800ea0:	e8 27 f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 17                	jle    800ee7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	50                   	push   %eax
  800ed4:	6a 06                	push   $0x6
  800ed6:	68 af 24 80 00       	push   $0x8024af
  800edb:	6a 23                	push   $0x23
  800edd:	68 cc 24 80 00       	push   $0x8024cc
  800ee2:	e8 e5 f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 08 00 00 00       	mov    $0x8,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 17                	jle    800f29 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	50                   	push   %eax
  800f16:	6a 08                	push   $0x8
  800f18:	68 af 24 80 00       	push   $0x8024af
  800f1d:	6a 23                	push   $0x23
  800f1f:	68 cc 24 80 00       	push   $0x8024cc
  800f24:	e8 a3 f3 ff ff       	call   8002cc <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800f44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7e 17                	jle    800f6b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	50                   	push   %eax
  800f58:	6a 09                	push   $0x9
  800f5a:	68 af 24 80 00       	push   $0x8024af
  800f5f:	6a 23                	push   $0x23
  800f61:	68 cc 24 80 00       	push   $0x8024cc
  800f66:	e8 61 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	89 df                	mov    %ebx,%edi
  800f8e:	89 de                	mov    %ebx,%esi
  800f90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 17                	jle    800fad <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	50                   	push   %eax
  800f9a:	6a 0a                	push   $0xa
  800f9c:	68 af 24 80 00       	push   $0x8024af
  800fa1:	6a 23                	push   $0x23
  800fa3:	68 cc 24 80 00       	push   $0x8024cc
  800fa8:	e8 1f f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	be 00 00 00 00       	mov    $0x0,%esi
  800fc0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 cb                	mov    %ecx,%ebx
  800ff0:	89 cf                	mov    %ecx,%edi
  800ff2:	89 ce                	mov    %ecx,%esi
  800ff4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 17                	jle    801011 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	50                   	push   %eax
  800ffe:	6a 0d                	push   $0xd
  801000:	68 af 24 80 00       	push   $0x8024af
  801005:	6a 23                	push   $0x23
  801007:	68 cc 24 80 00       	push   $0x8024cc
  80100c:	e8 bb f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	05 00 00 00 30       	add    $0x30000000,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
}
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801034:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801039:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801046:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80104b:	89 c2                	mov    %eax,%edx
  80104d:	c1 ea 16             	shr    $0x16,%edx
  801050:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801057:	f6 c2 01             	test   $0x1,%dl
  80105a:	74 11                	je     80106d <fd_alloc+0x2d>
  80105c:	89 c2                	mov    %eax,%edx
  80105e:	c1 ea 0c             	shr    $0xc,%edx
  801061:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801068:	f6 c2 01             	test   $0x1,%dl
  80106b:	75 09                	jne    801076 <fd_alloc+0x36>
			*fd_store = fd;
  80106d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80106f:	b8 00 00 00 00       	mov    $0x0,%eax
  801074:	eb 17                	jmp    80108d <fd_alloc+0x4d>
  801076:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80107b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801080:	75 c9                	jne    80104b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801082:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801088:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801095:	83 f8 1f             	cmp    $0x1f,%eax
  801098:	77 36                	ja     8010d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80109a:	c1 e0 0c             	shl    $0xc,%eax
  80109d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	c1 ea 16             	shr    $0x16,%edx
  8010a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ae:	f6 c2 01             	test   $0x1,%dl
  8010b1:	74 24                	je     8010d7 <fd_lookup+0x48>
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	c1 ea 0c             	shr    $0xc,%edx
  8010b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 1a                	je     8010de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ce:	eb 13                	jmp    8010e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d5:	eb 0c                	jmp    8010e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb 05                	jmp    8010e3 <fd_lookup+0x54>
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ee:	ba 5c 25 80 00       	mov    $0x80255c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010f3:	eb 13                	jmp    801108 <dev_lookup+0x23>
  8010f5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010f8:	39 08                	cmp    %ecx,(%eax)
  8010fa:	75 0c                	jne    801108 <dev_lookup+0x23>
			*dev = devtab[i];
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	eb 2e                	jmp    801136 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801108:	8b 02                	mov    (%edx),%eax
  80110a:	85 c0                	test   %eax,%eax
  80110c:	75 e7                	jne    8010f5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80110e:	a1 04 44 80 00       	mov    0x804404,%eax
  801113:	8b 40 48             	mov    0x48(%eax),%eax
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	51                   	push   %ecx
  80111a:	50                   	push   %eax
  80111b:	68 dc 24 80 00       	push   $0x8024dc
  801120:	e8 80 f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  801125:	8b 45 0c             	mov    0xc(%ebp),%eax
  801128:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 10             	sub    $0x10,%esp
  801140:	8b 75 08             	mov    0x8(%ebp),%esi
  801143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801146:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801149:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801150:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801153:	50                   	push   %eax
  801154:	e8 36 ff ff ff       	call   80108f <fd_lookup>
  801159:	83 c4 08             	add    $0x8,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 05                	js     801165 <fd_close+0x2d>
	    || fd != fd2)
  801160:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801163:	74 0c                	je     801171 <fd_close+0x39>
		return (must_exist ? r : 0);
  801165:	84 db                	test   %bl,%bl
  801167:	ba 00 00 00 00       	mov    $0x0,%edx
  80116c:	0f 44 c2             	cmove  %edx,%eax
  80116f:	eb 41                	jmp    8011b2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801177:	50                   	push   %eax
  801178:	ff 36                	pushl  (%esi)
  80117a:	e8 66 ff ff ff       	call   8010e5 <dev_lookup>
  80117f:	89 c3                	mov    %eax,%ebx
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 1a                	js     8011a2 <fd_close+0x6a>
		if (dev->dev_close)
  801188:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80118e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801193:	85 c0                	test   %eax,%eax
  801195:	74 0b                	je     8011a2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	56                   	push   %esi
  80119b:	ff d0                	call   *%eax
  80119d:	89 c3                	mov    %eax,%ebx
  80119f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	56                   	push   %esi
  8011a6:	6a 00                	push   $0x0
  8011a8:	e8 00 fd ff ff       	call   800ead <sys_page_unmap>
	return r;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	89 d8                	mov    %ebx,%eax
}
  8011b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	ff 75 08             	pushl  0x8(%ebp)
  8011c6:	e8 c4 fe ff ff       	call   80108f <fd_lookup>
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	85 d2                	test   %edx,%edx
  8011d2:	78 10                	js     8011e4 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	6a 01                	push   $0x1
  8011d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011dc:	e8 57 ff ff ff       	call   801138 <fd_close>
  8011e1:	83 c4 10             	add    $0x10,%esp
}
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <close_all>:

void
close_all(void)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	53                   	push   %ebx
  8011f6:	e8 be ff ff ff       	call   8011b9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011fb:	83 c3 01             	add    $0x1,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	83 fb 20             	cmp    $0x20,%ebx
  801204:	75 ec                	jne    8011f2 <close_all+0xc>
		close(i);
}
  801206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 2c             	sub    $0x2c,%esp
  801214:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801217:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	ff 75 08             	pushl  0x8(%ebp)
  80121e:	e8 6c fe ff ff       	call   80108f <fd_lookup>
  801223:	89 c2                	mov    %eax,%edx
  801225:	83 c4 08             	add    $0x8,%esp
  801228:	85 d2                	test   %edx,%edx
  80122a:	0f 88 c1 00 00 00    	js     8012f1 <dup+0xe6>
		return r;
	close(newfdnum);
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	56                   	push   %esi
  801234:	e8 80 ff ff ff       	call   8011b9 <close>

	newfd = INDEX2FD(newfdnum);
  801239:	89 f3                	mov    %esi,%ebx
  80123b:	c1 e3 0c             	shl    $0xc,%ebx
  80123e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801244:	83 c4 04             	add    $0x4,%esp
  801247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124a:	e8 da fd ff ff       	call   801029 <fd2data>
  80124f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801251:	89 1c 24             	mov    %ebx,(%esp)
  801254:	e8 d0 fd ff ff       	call   801029 <fd2data>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80125f:	89 f8                	mov    %edi,%eax
  801261:	c1 e8 16             	shr    $0x16,%eax
  801264:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126b:	a8 01                	test   $0x1,%al
  80126d:	74 37                	je     8012a6 <dup+0x9b>
  80126f:	89 f8                	mov    %edi,%eax
  801271:	c1 e8 0c             	shr    $0xc,%eax
  801274:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80127b:	f6 c2 01             	test   $0x1,%dl
  80127e:	74 26                	je     8012a6 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801280:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	25 07 0e 00 00       	and    $0xe07,%eax
  80128f:	50                   	push   %eax
  801290:	ff 75 d4             	pushl  -0x2c(%ebp)
  801293:	6a 00                	push   $0x0
  801295:	57                   	push   %edi
  801296:	6a 00                	push   $0x0
  801298:	e8 ce fb ff ff       	call   800e6b <sys_page_map>
  80129d:	89 c7                	mov    %eax,%edi
  80129f:	83 c4 20             	add    $0x20,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 2e                	js     8012d4 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012a9:	89 d0                	mov    %edx,%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bd:	50                   	push   %eax
  8012be:	53                   	push   %ebx
  8012bf:	6a 00                	push   $0x0
  8012c1:	52                   	push   %edx
  8012c2:	6a 00                	push   $0x0
  8012c4:	e8 a2 fb ff ff       	call   800e6b <sys_page_map>
  8012c9:	89 c7                	mov    %eax,%edi
  8012cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d0:	85 ff                	test   %edi,%edi
  8012d2:	79 1d                	jns    8012f1 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	53                   	push   %ebx
  8012d8:	6a 00                	push   $0x0
  8012da:	e8 ce fb ff ff       	call   800ead <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 c1 fb ff ff       	call   800ead <sys_page_unmap>
	return r;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	89 f8                	mov    %edi,%eax
}
  8012f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 14             	sub    $0x14,%esp
  801300:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	53                   	push   %ebx
  801308:	e8 82 fd ff ff       	call   80108f <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	89 c2                	mov    %eax,%edx
  801312:	85 c0                	test   %eax,%eax
  801314:	78 6d                	js     801383 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	ff 30                	pushl  (%eax)
  801322:	e8 be fd ff ff       	call   8010e5 <dev_lookup>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 4c                	js     80137a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80132e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801331:	8b 42 08             	mov    0x8(%edx),%eax
  801334:	83 e0 03             	and    $0x3,%eax
  801337:	83 f8 01             	cmp    $0x1,%eax
  80133a:	75 21                	jne    80135d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80133c:	a1 04 44 80 00       	mov    0x804404,%eax
  801341:	8b 40 48             	mov    0x48(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	53                   	push   %ebx
  801348:	50                   	push   %eax
  801349:	68 20 25 80 00       	push   $0x802520
  80134e:	e8 52 f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135b:	eb 26                	jmp    801383 <read+0x8a>
	}
	if (!dev->dev_read)
  80135d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801360:	8b 40 08             	mov    0x8(%eax),%eax
  801363:	85 c0                	test   %eax,%eax
  801365:	74 17                	je     80137e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	ff 75 10             	pushl  0x10(%ebp)
  80136d:	ff 75 0c             	pushl  0xc(%ebp)
  801370:	52                   	push   %edx
  801371:	ff d0                	call   *%eax
  801373:	89 c2                	mov    %eax,%edx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	eb 09                	jmp    801383 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	eb 05                	jmp    801383 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80137e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801383:	89 d0                	mov    %edx,%eax
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	8b 7d 08             	mov    0x8(%ebp),%edi
  801396:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801399:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139e:	eb 21                	jmp    8013c1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a0:	83 ec 04             	sub    $0x4,%esp
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	29 d8                	sub    %ebx,%eax
  8013a7:	50                   	push   %eax
  8013a8:	89 d8                	mov    %ebx,%eax
  8013aa:	03 45 0c             	add    0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	57                   	push   %edi
  8013af:	e8 45 ff ff ff       	call   8012f9 <read>
		if (m < 0)
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 0c                	js     8013c7 <readn+0x3d>
			return m;
		if (m == 0)
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	74 06                	je     8013c5 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013bf:	01 c3                	add    %eax,%ebx
  8013c1:	39 f3                	cmp    %esi,%ebx
  8013c3:	72 db                	jb     8013a0 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8013c5:	89 d8                	mov    %ebx,%eax
}
  8013c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5f                   	pop    %edi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 14             	sub    $0x14,%esp
  8013d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013dc:	50                   	push   %eax
  8013dd:	53                   	push   %ebx
  8013de:	e8 ac fc ff ff       	call   80108f <fd_lookup>
  8013e3:	83 c4 08             	add    $0x8,%esp
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 68                	js     801454 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f6:	ff 30                	pushl  (%eax)
  8013f8:	e8 e8 fc ff ff       	call   8010e5 <dev_lookup>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 47                	js     80144b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801404:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801407:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80140b:	75 21                	jne    80142e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80140d:	a1 04 44 80 00       	mov    0x804404,%eax
  801412:	8b 40 48             	mov    0x48(%eax),%eax
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	53                   	push   %ebx
  801419:	50                   	push   %eax
  80141a:	68 3c 25 80 00       	push   $0x80253c
  80141f:	e8 81 ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80142c:	eb 26                	jmp    801454 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80142e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801431:	8b 52 0c             	mov    0xc(%edx),%edx
  801434:	85 d2                	test   %edx,%edx
  801436:	74 17                	je     80144f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	ff 75 10             	pushl  0x10(%ebp)
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	50                   	push   %eax
  801442:	ff d2                	call   *%edx
  801444:	89 c2                	mov    %eax,%edx
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	eb 09                	jmp    801454 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	eb 05                	jmp    801454 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80144f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801454:	89 d0                	mov    %edx,%eax
  801456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <seek>:

int
seek(int fdnum, off_t offset)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801461:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	ff 75 08             	pushl  0x8(%ebp)
  801468:	e8 22 fc ff ff       	call   80108f <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 0e                	js     801482 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801474:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801477:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80147d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 14             	sub    $0x14,%esp
  80148b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	53                   	push   %ebx
  801493:	e8 f7 fb ff ff       	call   80108f <fd_lookup>
  801498:	83 c4 08             	add    $0x8,%esp
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 65                	js     801506 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ab:	ff 30                	pushl  (%eax)
  8014ad:	e8 33 fc ff ff       	call   8010e5 <dev_lookup>
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 44                	js     8014fd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c0:	75 21                	jne    8014e3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014c2:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014c7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ca:	83 ec 04             	sub    $0x4,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	50                   	push   %eax
  8014cf:	68 fc 24 80 00       	push   $0x8024fc
  8014d4:	e8 cc ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e1:	eb 23                	jmp    801506 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e6:	8b 52 18             	mov    0x18(%edx),%edx
  8014e9:	85 d2                	test   %edx,%edx
  8014eb:	74 14                	je     801501 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	ff 75 0c             	pushl  0xc(%ebp)
  8014f3:	50                   	push   %eax
  8014f4:	ff d2                	call   *%edx
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 09                	jmp    801506 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	eb 05                	jmp    801506 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801501:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801506:	89 d0                	mov    %edx,%eax
  801508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	53                   	push   %ebx
  801511:	83 ec 14             	sub    $0x14,%esp
  801514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	ff 75 08             	pushl  0x8(%ebp)
  80151e:	e8 6c fb ff ff       	call   80108f <fd_lookup>
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	89 c2                	mov    %eax,%edx
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 58                	js     801584 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	ff 30                	pushl  (%eax)
  801538:	e8 a8 fb ff ff       	call   8010e5 <dev_lookup>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 37                	js     80157b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801547:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80154b:	74 32                	je     80157f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80154d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801550:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801557:	00 00 00 
	stat->st_isdir = 0;
  80155a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801561:	00 00 00 
	stat->st_dev = dev;
  801564:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	53                   	push   %ebx
  80156e:	ff 75 f0             	pushl  -0x10(%ebp)
  801571:	ff 50 14             	call   *0x14(%eax)
  801574:	89 c2                	mov    %eax,%edx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 09                	jmp    801584 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	eb 05                	jmp    801584 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80157f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801584:	89 d0                	mov    %edx,%eax
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	6a 00                	push   $0x0
  801595:	ff 75 08             	pushl  0x8(%ebp)
  801598:	e8 09 02 00 00       	call   8017a6 <open>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 db                	test   %ebx,%ebx
  8015a4:	78 1b                	js     8015c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	53                   	push   %ebx
  8015ad:	e8 5b ff ff ff       	call   80150d <fstat>
  8015b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015b4:	89 1c 24             	mov    %ebx,(%esp)
  8015b7:	e8 fd fb ff ff       	call   8011b9 <close>
	return r;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	89 f0                	mov    %esi,%eax
}
  8015c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	89 c6                	mov    %eax,%esi
  8015cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015d1:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015d8:	75 12                	jne    8015ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	6a 01                	push   $0x1
  8015df:	e8 8c 07 00 00       	call   801d70 <ipc_find_env>
  8015e4:	a3 00 44 80 00       	mov    %eax,0x804400
  8015e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ec:	6a 07                	push   $0x7
  8015ee:	68 00 50 80 00       	push   $0x805000
  8015f3:	56                   	push   %esi
  8015f4:	ff 35 00 44 80 00    	pushl  0x804400
  8015fa:	e8 1d 07 00 00       	call   801d1c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015ff:	83 c4 0c             	add    $0xc,%esp
  801602:	6a 00                	push   $0x0
  801604:	53                   	push   %ebx
  801605:	6a 00                	push   $0x0
  801607:	e8 a7 06 00 00       	call   801cb3 <ipc_recv>
}
  80160c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	8b 40 0c             	mov    0xc(%eax),%eax
  80161f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801624:	8b 45 0c             	mov    0xc(%ebp),%eax
  801627:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80162c:	ba 00 00 00 00       	mov    $0x0,%edx
  801631:	b8 02 00 00 00       	mov    $0x2,%eax
  801636:	e8 8d ff ff ff       	call   8015c8 <fsipc>
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	8b 40 0c             	mov    0xc(%eax),%eax
  801649:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80164e:	ba 00 00 00 00       	mov    $0x0,%edx
  801653:	b8 06 00 00 00       	mov    $0x6,%eax
  801658:	e8 6b ff ff ff       	call   8015c8 <fsipc>
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	8b 40 0c             	mov    0xc(%eax),%eax
  80166f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801674:	ba 00 00 00 00       	mov    $0x0,%edx
  801679:	b8 05 00 00 00       	mov    $0x5,%eax
  80167e:	e8 45 ff ff ff       	call   8015c8 <fsipc>
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 d2                	test   %edx,%edx
  801687:	78 2c                	js     8016b5 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	68 00 50 80 00       	push   $0x805000
  801691:	53                   	push   %ebx
  801692:	e8 88 f3 ff ff       	call   800a1f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801697:	a1 80 50 80 00       	mov    0x805080,%eax
  80169c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8016a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	57                   	push   %edi
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cc:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8016d4:	eb 3d                	jmp    801713 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8016d6:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8016dc:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8016e1:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	57                   	push   %edi
  8016e8:	53                   	push   %ebx
  8016e9:	68 08 50 80 00       	push   $0x805008
  8016ee:	e8 be f4 ff ff       	call   800bb1 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8016f3:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801703:	e8 c0 fe ff ff       	call   8015c8 <fsipc>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 0d                	js     80171c <devfile_write+0x62>
		        return r;
                n -= tmp;
  80170f:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801711:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801713:	85 f6                	test   %esi,%esi
  801715:	75 bf                	jne    8016d6 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801717:	89 d8                	mov    %ebx,%eax
  801719:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80171c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5f                   	pop    %edi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	8b 40 0c             	mov    0xc(%eax),%eax
  801732:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801737:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 03 00 00 00       	mov    $0x3,%eax
  801747:	e8 7c fe ff ff       	call   8015c8 <fsipc>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 4b                	js     80179d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801752:	39 c6                	cmp    %eax,%esi
  801754:	73 16                	jae    80176c <devfile_read+0x48>
  801756:	68 6c 25 80 00       	push   $0x80256c
  80175b:	68 73 25 80 00       	push   $0x802573
  801760:	6a 7c                	push   $0x7c
  801762:	68 88 25 80 00       	push   $0x802588
  801767:	e8 60 eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  80176c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801771:	7e 16                	jle    801789 <devfile_read+0x65>
  801773:	68 93 25 80 00       	push   $0x802593
  801778:	68 73 25 80 00       	push   $0x802573
  80177d:	6a 7d                	push   $0x7d
  80177f:	68 88 25 80 00       	push   $0x802588
  801784:	e8 43 eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801789:	83 ec 04             	sub    $0x4,%esp
  80178c:	50                   	push   %eax
  80178d:	68 00 50 80 00       	push   $0x805000
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	e8 17 f4 ff ff       	call   800bb1 <memmove>
	return r;
  80179a:	83 c4 10             	add    $0x10,%esp
}
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 20             	sub    $0x20,%esp
  8017ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b0:	53                   	push   %ebx
  8017b1:	e8 30 f2 ff ff       	call   8009e6 <strlen>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017be:	7f 67                	jg     801827 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c0:	83 ec 0c             	sub    $0xc,%esp
  8017c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	e8 74 f8 ff ff       	call   801040 <fd_alloc>
  8017cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017cf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 57                	js     80182c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	53                   	push   %ebx
  8017d9:	68 00 50 80 00       	push   $0x805000
  8017de:	e8 3c f2 ff ff       	call   800a1f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f3:	e8 d0 fd ff ff       	call   8015c8 <fsipc>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	79 14                	jns    801815 <open+0x6f>
		fd_close(fd, 0);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	6a 00                	push   $0x0
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	e8 2a f9 ff ff       	call   801138 <fd_close>
		return r;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	89 da                	mov    %ebx,%edx
  801813:	eb 17                	jmp    80182c <open+0x86>
	}

	return fd2num(fd);
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	ff 75 f4             	pushl  -0xc(%ebp)
  80181b:	e8 f9 f7 ff ff       	call   801019 <fd2num>
  801820:	89 c2                	mov    %eax,%edx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	eb 05                	jmp    80182c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801827:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	b8 08 00 00 00       	mov    $0x8,%eax
  801843:	e8 80 fd ff ff       	call   8015c8 <fsipc>
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80184a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80184e:	7e 37                	jle    801887 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801859:	ff 70 04             	pushl  0x4(%eax)
  80185c:	8d 40 10             	lea    0x10(%eax),%eax
  80185f:	50                   	push   %eax
  801860:	ff 33                	pushl  (%ebx)
  801862:	e8 68 fb ff ff       	call   8013cf <write>
		if (result > 0)
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	7e 03                	jle    801871 <writebuf+0x27>
			b->result += result;
  80186e:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801871:	39 43 04             	cmp    %eax,0x4(%ebx)
  801874:	74 0d                	je     801883 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801876:	85 c0                	test   %eax,%eax
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	0f 4f c2             	cmovg  %edx,%eax
  801880:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801886:	c9                   	leave  
  801887:	f3 c3                	repz ret 

00801889 <putch>:

static void
putch(int ch, void *thunk)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801893:	8b 53 04             	mov    0x4(%ebx),%edx
  801896:	8d 42 01             	lea    0x1(%edx),%eax
  801899:	89 43 04             	mov    %eax,0x4(%ebx)
  80189c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189f:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018a3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018a8:	75 0e                	jne    8018b8 <putch+0x2f>
		writebuf(b);
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	e8 99 ff ff ff       	call   80184a <writebuf>
		b->idx = 0;
  8018b1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018b8:	83 c4 04             	add    $0x4,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018d0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018d7:	00 00 00 
	b.result = 0;
  8018da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018e1:	00 00 00 
	b.error = 1;
  8018e4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018eb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ee:	ff 75 10             	pushl  0x10(%ebp)
  8018f1:	ff 75 0c             	pushl  0xc(%ebp)
  8018f4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018fa:	50                   	push   %eax
  8018fb:	68 89 18 80 00       	push   $0x801889
  801900:	e8 d2 eb ff ff       	call   8004d7 <vprintfmt>
	if (b.idx > 0)
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80190f:	7e 0b                	jle    80191c <vfprintf+0x5e>
		writebuf(&b);
  801911:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801917:	e8 2e ff ff ff       	call   80184a <writebuf>

	return (b.result ? b.result : b.error);
  80191c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801922:	85 c0                	test   %eax,%eax
  801924:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801933:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801936:	50                   	push   %eax
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	ff 75 08             	pushl  0x8(%ebp)
  80193d:	e8 7c ff ff ff       	call   8018be <vfprintf>
	va_end(ap);

	return cnt;
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <printf>:

int
printf(const char *fmt, ...)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80194a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80194d:	50                   	push   %eax
  80194e:	ff 75 08             	pushl  0x8(%ebp)
  801951:	6a 01                	push   $0x1
  801953:	e8 66 ff ff ff       	call   8018be <vfprintf>
	va_end(ap);

	return cnt;
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	56                   	push   %esi
  80195e:	53                   	push   %ebx
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801962:	83 ec 0c             	sub    $0xc,%esp
  801965:	ff 75 08             	pushl  0x8(%ebp)
  801968:	e8 bc f6 ff ff       	call   801029 <fd2data>
  80196d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196f:	83 c4 08             	add    $0x8,%esp
  801972:	68 9f 25 80 00       	push   $0x80259f
  801977:	53                   	push   %ebx
  801978:	e8 a2 f0 ff ff       	call   800a1f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197d:	8b 56 04             	mov    0x4(%esi),%edx
  801980:	89 d0                	mov    %edx,%eax
  801982:	2b 06                	sub    (%esi),%eax
  801984:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80198a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801991:	00 00 00 
	stat->st_dev = &devpipe;
  801994:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80199b:	30 80 00 
	return 0;
}
  80199e:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5e                   	pop    %esi
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	53                   	push   %ebx
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b4:	53                   	push   %ebx
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 f1 f4 ff ff       	call   800ead <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019bc:	89 1c 24             	mov    %ebx,(%esp)
  8019bf:	e8 65 f6 ff ff       	call   801029 <fd2data>
  8019c4:	83 c4 08             	add    $0x8,%esp
  8019c7:	50                   	push   %eax
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 de f4 ff ff       	call   800ead <sys_page_unmap>
}
  8019cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	57                   	push   %edi
  8019d8:	56                   	push   %esi
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 1c             	sub    $0x1c,%esp
  8019dd:	89 c6                	mov    %eax,%esi
  8019df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019e2:	a1 04 44 80 00       	mov    0x804404,%eax
  8019e7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	56                   	push   %esi
  8019ee:	e8 b5 03 00 00       	call   801da8 <pageref>
  8019f3:	89 c7                	mov    %eax,%edi
  8019f5:	83 c4 04             	add    $0x4,%esp
  8019f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019fb:	e8 a8 03 00 00       	call   801da8 <pageref>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	39 c7                	cmp    %eax,%edi
  801a05:	0f 94 c2             	sete   %dl
  801a08:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a0b:	8b 0d 04 44 80 00    	mov    0x804404,%ecx
  801a11:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a14:	39 fb                	cmp    %edi,%ebx
  801a16:	74 19                	je     801a31 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801a18:	84 d2                	test   %dl,%dl
  801a1a:	74 c6                	je     8019e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a1c:	8b 51 58             	mov    0x58(%ecx),%edx
  801a1f:	50                   	push   %eax
  801a20:	52                   	push   %edx
  801a21:	53                   	push   %ebx
  801a22:	68 a6 25 80 00       	push   $0x8025a6
  801a27:	e8 79 e9 ff ff       	call   8003a5 <cprintf>
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	eb b1                	jmp    8019e2 <_pipeisclosed+0xe>
	}
}
  801a31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	57                   	push   %edi
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	83 ec 28             	sub    $0x28,%esp
  801a42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a45:	56                   	push   %esi
  801a46:	e8 de f5 ff ff       	call   801029 <fd2data>
  801a4b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	bf 00 00 00 00       	mov    $0x0,%edi
  801a55:	eb 4b                	jmp    801aa2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a57:	89 da                	mov    %ebx,%edx
  801a59:	89 f0                	mov    %esi,%eax
  801a5b:	e8 74 ff ff ff       	call   8019d4 <_pipeisclosed>
  801a60:	85 c0                	test   %eax,%eax
  801a62:	75 48                	jne    801aac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a64:	e8 a0 f3 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a69:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6c:	8b 0b                	mov    (%ebx),%ecx
  801a6e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a71:	39 d0                	cmp    %edx,%eax
  801a73:	73 e2                	jae    801a57 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a78:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a7c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a7f:	89 c2                	mov    %eax,%edx
  801a81:	c1 fa 1f             	sar    $0x1f,%edx
  801a84:	89 d1                	mov    %edx,%ecx
  801a86:	c1 e9 1b             	shr    $0x1b,%ecx
  801a89:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a8c:	83 e2 1f             	and    $0x1f,%edx
  801a8f:	29 ca                	sub    %ecx,%edx
  801a91:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a95:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a99:	83 c0 01             	add    $0x1,%eax
  801a9c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9f:	83 c7 01             	add    $0x1,%edi
  801aa2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa5:	75 c2                	jne    801a69 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aaa:	eb 05                	jmp    801ab1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5f                   	pop    %edi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	57                   	push   %edi
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	83 ec 18             	sub    $0x18,%esp
  801ac2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac5:	57                   	push   %edi
  801ac6:	e8 5e f5 ff ff       	call   801029 <fd2data>
  801acb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad5:	eb 3d                	jmp    801b14 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad7:	85 db                	test   %ebx,%ebx
  801ad9:	74 04                	je     801adf <devpipe_read+0x26>
				return i;
  801adb:	89 d8                	mov    %ebx,%eax
  801add:	eb 44                	jmp    801b23 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801adf:	89 f2                	mov    %esi,%edx
  801ae1:	89 f8                	mov    %edi,%eax
  801ae3:	e8 ec fe ff ff       	call   8019d4 <_pipeisclosed>
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	75 32                	jne    801b1e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aec:	e8 18 f3 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af1:	8b 06                	mov    (%esi),%eax
  801af3:	3b 46 04             	cmp    0x4(%esi),%eax
  801af6:	74 df                	je     801ad7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af8:	99                   	cltd   
  801af9:	c1 ea 1b             	shr    $0x1b,%edx
  801afc:	01 d0                	add    %edx,%eax
  801afe:	83 e0 1f             	and    $0x1f,%eax
  801b01:	29 d0                	sub    %edx,%eax
  801b03:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b0e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b11:	83 c3 01             	add    $0x1,%ebx
  801b14:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b17:	75 d8                	jne    801af1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b19:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1c:	eb 05                	jmp    801b23 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b26:	5b                   	pop    %ebx
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	e8 04 f5 ff ff       	call   801040 <fd_alloc>
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	89 c2                	mov    %eax,%edx
  801b41:	85 c0                	test   %eax,%eax
  801b43:	0f 88 2c 01 00 00    	js     801c75 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b49:	83 ec 04             	sub    $0x4,%esp
  801b4c:	68 07 04 00 00       	push   $0x407
  801b51:	ff 75 f4             	pushl  -0xc(%ebp)
  801b54:	6a 00                	push   $0x0
  801b56:	e8 cd f2 ff ff       	call   800e28 <sys_page_alloc>
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	85 c0                	test   %eax,%eax
  801b62:	0f 88 0d 01 00 00    	js     801c75 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6e:	50                   	push   %eax
  801b6f:	e8 cc f4 ff ff       	call   801040 <fd_alloc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	0f 88 e2 00 00 00    	js     801c63 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b81:	83 ec 04             	sub    $0x4,%esp
  801b84:	68 07 04 00 00       	push   $0x407
  801b89:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8c:	6a 00                	push   $0x0
  801b8e:	e8 95 f2 ff ff       	call   800e28 <sys_page_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 c3 00 00 00    	js     801c63 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba6:	e8 7e f4 ff ff       	call   801029 <fd2data>
  801bab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bad:	83 c4 0c             	add    $0xc,%esp
  801bb0:	68 07 04 00 00       	push   $0x407
  801bb5:	50                   	push   %eax
  801bb6:	6a 00                	push   $0x0
  801bb8:	e8 6b f2 ff ff       	call   800e28 <sys_page_alloc>
  801bbd:	89 c3                	mov    %eax,%ebx
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 89 00 00 00    	js     801c53 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd0:	e8 54 f4 ff ff       	call   801029 <fd2data>
  801bd5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bdc:	50                   	push   %eax
  801bdd:	6a 00                	push   $0x0
  801bdf:	56                   	push   %esi
  801be0:	6a 00                	push   $0x0
  801be2:	e8 84 f2 ff ff       	call   800e6b <sys_page_map>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	83 c4 20             	add    $0x20,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 55                	js     801c45 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c05:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c13:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	e8 f4 f3 ff ff       	call   801019 <fd2num>
  801c25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c28:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c2a:	83 c4 04             	add    $0x4,%esp
  801c2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c30:	e8 e4 f3 ff ff       	call   801019 <fd2num>
  801c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c38:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c43:	eb 30                	jmp    801c75 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	56                   	push   %esi
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 5d f2 ff ff       	call   800ead <sys_page_unmap>
  801c50:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c53:	83 ec 08             	sub    $0x8,%esp
  801c56:	ff 75 f0             	pushl  -0x10(%ebp)
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 4d f2 ff ff       	call   800ead <sys_page_unmap>
  801c60:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c63:	83 ec 08             	sub    $0x8,%esp
  801c66:	ff 75 f4             	pushl  -0xc(%ebp)
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 3d f2 ff ff       	call   800ead <sys_page_unmap>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c75:	89 d0                	mov    %edx,%eax
  801c77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	ff 75 08             	pushl  0x8(%ebp)
  801c8b:	e8 ff f3 ff ff       	call   80108f <fd_lookup>
  801c90:	89 c2                	mov    %eax,%edx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 d2                	test   %edx,%edx
  801c97:	78 18                	js     801cb1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9f:	e8 85 f3 ff ff       	call   801029 <fd2data>
	return _pipeisclosed(fd, p);
  801ca4:	89 c2                	mov    %eax,%edx
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	e8 26 fd ff ff       	call   8019d4 <_pipeisclosed>
  801cae:	83 c4 10             	add    $0x10,%esp
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801cc8:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	50                   	push   %eax
  801ccf:	e8 04 f3 ff ff       	call   800fd8 <sys_ipc_recv>
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	79 16                	jns    801cf1 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801cdb:	85 f6                	test   %esi,%esi
  801cdd:	74 06                	je     801ce5 <ipc_recv+0x32>
  801cdf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801ce5:	85 db                	test   %ebx,%ebx
  801ce7:	74 2c                	je     801d15 <ipc_recv+0x62>
  801ce9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cef:	eb 24                	jmp    801d15 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801cf1:	85 f6                	test   %esi,%esi
  801cf3:	74 0a                	je     801cff <ipc_recv+0x4c>
  801cf5:	a1 04 44 80 00       	mov    0x804404,%eax
  801cfa:	8b 40 74             	mov    0x74(%eax),%eax
  801cfd:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801cff:	85 db                	test   %ebx,%ebx
  801d01:	74 0a                	je     801d0d <ipc_recv+0x5a>
  801d03:	a1 04 44 80 00       	mov    0x804404,%eax
  801d08:	8b 40 78             	mov    0x78(%eax),%eax
  801d0b:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801d0d:	a1 04 44 80 00       	mov    0x804404,%eax
  801d12:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    

00801d1c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	57                   	push   %edi
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801d2e:	85 db                	test   %ebx,%ebx
  801d30:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d35:	0f 44 d8             	cmove  %eax,%ebx
  801d38:	eb 1c                	jmp    801d56 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801d3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d3d:	74 12                	je     801d51 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801d3f:	50                   	push   %eax
  801d40:	68 be 25 80 00       	push   $0x8025be
  801d45:	6a 39                	push   $0x39
  801d47:	68 d9 25 80 00       	push   $0x8025d9
  801d4c:	e8 7b e5 ff ff       	call   8002cc <_panic>
                 sys_yield();
  801d51:	e8 b3 f0 ff ff       	call   800e09 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d56:	ff 75 14             	pushl  0x14(%ebp)
  801d59:	53                   	push   %ebx
  801d5a:	56                   	push   %esi
  801d5b:	57                   	push   %edi
  801d5c:	e8 54 f2 ff ff       	call   800fb5 <sys_ipc_try_send>
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 d2                	js     801d3a <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6b:	5b                   	pop    %ebx
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d7b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d7e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d84:	8b 52 50             	mov    0x50(%edx),%edx
  801d87:	39 ca                	cmp    %ecx,%edx
  801d89:	75 0d                	jne    801d98 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d8b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d8e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801d93:	8b 40 08             	mov    0x8(%eax),%eax
  801d96:	eb 0e                	jmp    801da6 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da0:	75 d9                	jne    801d7b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801da2:	66 b8 00 00          	mov    $0x0,%ax
}
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dae:	89 d0                	mov    %edx,%eax
  801db0:	c1 e8 16             	shr    $0x16,%eax
  801db3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dbf:	f6 c1 01             	test   $0x1,%cl
  801dc2:	74 1d                	je     801de1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dc4:	c1 ea 0c             	shr    $0xc,%edx
  801dc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dce:	f6 c2 01             	test   $0x1,%dl
  801dd1:	74 0e                	je     801de1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dd3:	c1 ea 0c             	shr    $0xc,%edx
  801dd6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ddd:	ef 
  801dde:	0f b7 c0             	movzwl %ax,%eax
}
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	66 90                	xchg   %ax,%ax
  801de5:	66 90                	xchg   %ax,%ax
  801de7:	66 90                	xchg   %ax,%ax
  801de9:	66 90                	xchg   %ax,%ax
  801deb:	66 90                	xchg   %ax,%ax
  801ded:	66 90                	xchg   %ax,%ax
  801def:	90                   	nop

00801df0 <__udivdi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	83 ec 10             	sub    $0x10,%esp
  801df6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801dfa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801dfe:	8b 74 24 24          	mov    0x24(%esp),%esi
  801e02:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e06:	85 d2                	test   %edx,%edx
  801e08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e0c:	89 34 24             	mov    %esi,(%esp)
  801e0f:	89 c8                	mov    %ecx,%eax
  801e11:	75 35                	jne    801e48 <__udivdi3+0x58>
  801e13:	39 f1                	cmp    %esi,%ecx
  801e15:	0f 87 bd 00 00 00    	ja     801ed8 <__udivdi3+0xe8>
  801e1b:	85 c9                	test   %ecx,%ecx
  801e1d:	89 cd                	mov    %ecx,%ebp
  801e1f:	75 0b                	jne    801e2c <__udivdi3+0x3c>
  801e21:	b8 01 00 00 00       	mov    $0x1,%eax
  801e26:	31 d2                	xor    %edx,%edx
  801e28:	f7 f1                	div    %ecx
  801e2a:	89 c5                	mov    %eax,%ebp
  801e2c:	89 f0                	mov    %esi,%eax
  801e2e:	31 d2                	xor    %edx,%edx
  801e30:	f7 f5                	div    %ebp
  801e32:	89 c6                	mov    %eax,%esi
  801e34:	89 f8                	mov    %edi,%eax
  801e36:	f7 f5                	div    %ebp
  801e38:	89 f2                	mov    %esi,%edx
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	5e                   	pop    %esi
  801e3e:	5f                   	pop    %edi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    
  801e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e48:	3b 14 24             	cmp    (%esp),%edx
  801e4b:	77 7b                	ja     801ec8 <__udivdi3+0xd8>
  801e4d:	0f bd f2             	bsr    %edx,%esi
  801e50:	83 f6 1f             	xor    $0x1f,%esi
  801e53:	0f 84 97 00 00 00    	je     801ef0 <__udivdi3+0x100>
  801e59:	bd 20 00 00 00       	mov    $0x20,%ebp
  801e5e:	89 d7                	mov    %edx,%edi
  801e60:	89 f1                	mov    %esi,%ecx
  801e62:	29 f5                	sub    %esi,%ebp
  801e64:	d3 e7                	shl    %cl,%edi
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	d3 ea                	shr    %cl,%edx
  801e6c:	89 f1                	mov    %esi,%ecx
  801e6e:	09 fa                	or     %edi,%edx
  801e70:	8b 3c 24             	mov    (%esp),%edi
  801e73:	d3 e0                	shl    %cl,%eax
  801e75:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e7f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e83:	89 fa                	mov    %edi,%edx
  801e85:	d3 ea                	shr    %cl,%edx
  801e87:	89 f1                	mov    %esi,%ecx
  801e89:	d3 e7                	shl    %cl,%edi
  801e8b:	89 e9                	mov    %ebp,%ecx
  801e8d:	d3 e8                	shr    %cl,%eax
  801e8f:	09 c7                	or     %eax,%edi
  801e91:	89 f8                	mov    %edi,%eax
  801e93:	f7 74 24 08          	divl   0x8(%esp)
  801e97:	89 d5                	mov    %edx,%ebp
  801e99:	89 c7                	mov    %eax,%edi
  801e9b:	f7 64 24 0c          	mull   0xc(%esp)
  801e9f:	39 d5                	cmp    %edx,%ebp
  801ea1:	89 14 24             	mov    %edx,(%esp)
  801ea4:	72 11                	jb     801eb7 <__udivdi3+0xc7>
  801ea6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eaa:	89 f1                	mov    %esi,%ecx
  801eac:	d3 e2                	shl    %cl,%edx
  801eae:	39 c2                	cmp    %eax,%edx
  801eb0:	73 5e                	jae    801f10 <__udivdi3+0x120>
  801eb2:	3b 2c 24             	cmp    (%esp),%ebp
  801eb5:	75 59                	jne    801f10 <__udivdi3+0x120>
  801eb7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801eba:	31 f6                	xor    %esi,%esi
  801ebc:	89 f2                	mov    %esi,%edx
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	31 f6                	xor    %esi,%esi
  801eca:	31 c0                	xor    %eax,%eax
  801ecc:	89 f2                	mov    %esi,%edx
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    
  801ed5:	8d 76 00             	lea    0x0(%esi),%esi
  801ed8:	89 f2                	mov    %esi,%edx
  801eda:	31 f6                	xor    %esi,%esi
  801edc:	89 f8                	mov    %edi,%eax
  801ede:	f7 f1                	div    %ecx
  801ee0:	89 f2                	mov    %esi,%edx
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	5e                   	pop    %esi
  801ee6:	5f                   	pop    %edi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ef4:	76 0b                	jbe    801f01 <__udivdi3+0x111>
  801ef6:	31 c0                	xor    %eax,%eax
  801ef8:	3b 14 24             	cmp    (%esp),%edx
  801efb:	0f 83 37 ff ff ff    	jae    801e38 <__udivdi3+0x48>
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
  801f06:	e9 2d ff ff ff       	jmp    801e38 <__udivdi3+0x48>
  801f0b:	90                   	nop
  801f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f10:	89 f8                	mov    %edi,%eax
  801f12:	31 f6                	xor    %esi,%esi
  801f14:	e9 1f ff ff ff       	jmp    801e38 <__udivdi3+0x48>
  801f19:	66 90                	xchg   %ax,%ax
  801f1b:	66 90                	xchg   %ax,%ax
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

00801f20 <__umoddi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	83 ec 20             	sub    $0x20,%esp
  801f26:	8b 44 24 34          	mov    0x34(%esp),%eax
  801f2a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f2e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f32:	89 c6                	mov    %eax,%esi
  801f34:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f38:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f3c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801f40:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f44:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f48:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	75 1e                	jne    801f70 <__umoddi3+0x50>
  801f52:	39 f7                	cmp    %esi,%edi
  801f54:	76 52                	jbe    801fa8 <__umoddi3+0x88>
  801f56:	89 c8                	mov    %ecx,%eax
  801f58:	89 f2                	mov    %esi,%edx
  801f5a:	f7 f7                	div    %edi
  801f5c:	89 d0                	mov    %edx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	83 c4 20             	add    $0x20,%esp
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    
  801f67:	89 f6                	mov    %esi,%esi
  801f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f70:	39 f0                	cmp    %esi,%eax
  801f72:	77 5c                	ja     801fd0 <__umoddi3+0xb0>
  801f74:	0f bd e8             	bsr    %eax,%ebp
  801f77:	83 f5 1f             	xor    $0x1f,%ebp
  801f7a:	75 64                	jne    801fe0 <__umoddi3+0xc0>
  801f7c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801f80:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801f84:	0f 86 f6 00 00 00    	jbe    802080 <__umoddi3+0x160>
  801f8a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801f8e:	0f 82 ec 00 00 00    	jb     802080 <__umoddi3+0x160>
  801f94:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f98:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f9c:	83 c4 20             	add    $0x20,%esp
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
  801fa3:	90                   	nop
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	85 ff                	test   %edi,%edi
  801faa:	89 fd                	mov    %edi,%ebp
  801fac:	75 0b                	jne    801fb9 <__umoddi3+0x99>
  801fae:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb3:	31 d2                	xor    %edx,%edx
  801fb5:	f7 f7                	div    %edi
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fbd:	31 d2                	xor    %edx,%edx
  801fbf:	f7 f5                	div    %ebp
  801fc1:	89 c8                	mov    %ecx,%eax
  801fc3:	f7 f5                	div    %ebp
  801fc5:	eb 95                	jmp    801f5c <__umoddi3+0x3c>
  801fc7:	89 f6                	mov    %esi,%esi
  801fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801fd0:	89 c8                	mov    %ecx,%eax
  801fd2:	89 f2                	mov    %esi,%edx
  801fd4:	83 c4 20             	add    $0x20,%esp
  801fd7:	5e                   	pop    %esi
  801fd8:	5f                   	pop    %edi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    
  801fdb:	90                   	nop
  801fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	b8 20 00 00 00       	mov    $0x20,%eax
  801fe5:	89 e9                	mov    %ebp,%ecx
  801fe7:	29 e8                	sub    %ebp,%eax
  801fe9:	d3 e2                	shl    %cl,%edx
  801feb:	89 c7                	mov    %eax,%edi
  801fed:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ff1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e8                	shr    %cl,%eax
  801ff9:	89 c1                	mov    %eax,%ecx
  801ffb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fff:	09 d1                	or     %edx,%ecx
  802001:	89 fa                	mov    %edi,%edx
  802003:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802007:	89 e9                	mov    %ebp,%ecx
  802009:	d3 e0                	shl    %cl,%eax
  80200b:	89 f9                	mov    %edi,%ecx
  80200d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802011:	89 f0                	mov    %esi,%eax
  802013:	d3 e8                	shr    %cl,%eax
  802015:	89 e9                	mov    %ebp,%ecx
  802017:	89 c7                	mov    %eax,%edi
  802019:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80201d:	d3 e6                	shl    %cl,%esi
  80201f:	89 d1                	mov    %edx,%ecx
  802021:	89 fa                	mov    %edi,%edx
  802023:	d3 e8                	shr    %cl,%eax
  802025:	89 e9                	mov    %ebp,%ecx
  802027:	09 f0                	or     %esi,%eax
  802029:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80202d:	f7 74 24 10          	divl   0x10(%esp)
  802031:	d3 e6                	shl    %cl,%esi
  802033:	89 d1                	mov    %edx,%ecx
  802035:	f7 64 24 0c          	mull   0xc(%esp)
  802039:	39 d1                	cmp    %edx,%ecx
  80203b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80203f:	89 d7                	mov    %edx,%edi
  802041:	89 c6                	mov    %eax,%esi
  802043:	72 0a                	jb     80204f <__umoddi3+0x12f>
  802045:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802049:	73 10                	jae    80205b <__umoddi3+0x13b>
  80204b:	39 d1                	cmp    %edx,%ecx
  80204d:	75 0c                	jne    80205b <__umoddi3+0x13b>
  80204f:	89 d7                	mov    %edx,%edi
  802051:	89 c6                	mov    %eax,%esi
  802053:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802057:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80205b:	89 ca                	mov    %ecx,%edx
  80205d:	89 e9                	mov    %ebp,%ecx
  80205f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802063:	29 f0                	sub    %esi,%eax
  802065:	19 fa                	sbb    %edi,%edx
  802067:	d3 e8                	shr    %cl,%eax
  802069:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80206e:	89 d7                	mov    %edx,%edi
  802070:	d3 e7                	shl    %cl,%edi
  802072:	89 e9                	mov    %ebp,%ecx
  802074:	09 f8                	or     %edi,%eax
  802076:	d3 ea                	shr    %cl,%edx
  802078:	83 c4 20             	add    $0x20,%esp
  80207b:	5e                   	pop    %esi
  80207c:	5f                   	pop    %edi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
  80207f:	90                   	nop
  802080:	8b 74 24 10          	mov    0x10(%esp),%esi
  802084:	29 f9                	sub    %edi,%ecx
  802086:	19 c6                	sbb    %eax,%esi
  802088:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80208c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802090:	e9 ff fe ff ff       	jmp    801f94 <__umoddi3+0x74>
