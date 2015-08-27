
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 00 2b 80 00       	push   $0x802b00
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c8 2b 80 00       	push   $0x802bc8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 0f 2b 80 00       	push   $0x802b0f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 40 60 80 00       	push   $0x806040
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 04 2c 80 00       	push   $0x802c04
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 26 2b 80 00       	push   $0x802b26
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 3c 2b 80 00       	push   $0x802b3c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 74 09 00 00       	call   800a7f <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 48 2b 80 00       	push   $0x802b48
  800123:	56                   	push   %esi
  800124:	e8 56 09 00 00       	call   800a7f <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 4a 09 00 00       	call   800a7f <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 49 2b 80 00       	push   $0x802b49
  80013d:	56                   	push   %esi
  80013e:	e8 3c 09 00 00       	call   800a7f <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 4b 2b 80 00       	push   $0x802b4b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 4f 2b 80 00 	movl   $0x802b4f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 25 11 00 00       	call   80129f <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 61 2b 80 00       	push   $0x802b61
  80018c:	6a 37                	push   $0x37
  80018e:	68 6e 2b 80 00       	push   $0x802b6e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 7a 2b 80 00       	push   $0x802b7a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 6e 2b 80 00       	push   $0x802b6e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 37 11 00 00       	call   8012f1 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 94 2b 80 00       	push   $0x802b94
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 6e 2b 80 00       	push   $0x802b6e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 9c 2b 80 00       	push   $0x802b9c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 b0 2b 80 00       	push   $0x802bb0
  8001ea:	68 af 2b 80 00       	push   $0x802baf
  8001ef:	e8 89 1c 00 00       	call   801e7d <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 b3 2b 80 00       	push   $0x802bb3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 a3 24 00 00       	call   8026ba <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 33 2c 80 00       	push   $0x802c33
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 26 08 00 00       	call   800a5f <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 7a 09 00 00       	call   800bf1 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 2b 0b 00 00       	call   800dac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	75 07                	jne    8002ad <devcons_read+0x18>
  8002a6:	eb 28                	jmp    8002d0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 9c 0b 00 00       	call   800e49 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 18 0b 00 00       	call   800dca <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 c3 0a 00 00       	call   800dac <sys_cputs>
  8002e9:	83 c4 10             	add    $0x10,%esp
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 de 10 00 00       	call   8013df <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 45 0e 00 00       	call   801170 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 cd 0d 00 00       	call   801121 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 f9 0a 00 00       	call   800e68 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 64 0d 00 00       	call   8010fa <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8003aa:	e8 7b 0a 00 00       	call   800e2a <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 b0 77 80 00       	mov    %eax,0x8077b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
  8003db:	83 c4 10             	add    $0x10,%esp
}
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 dc 0e 00 00       	call   8012cc <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 ef 09 00 00       	call   800de9 <sys_env_destroy>
  8003fa:	83 c4 10             	add    $0x10,%esp
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80040d:	e8 18 0a 00 00       	call   800e2a <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 4c 2c 80 00       	push   $0x802c4c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 95 31 80 00 	movl   $0x803195,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 37 09 00 00       	call   800dac <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 4f 01 00 00       	call   80060a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 dc 08 00 00       	call   800dac <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 d1                	mov    %edx,%ecx
  800501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800504:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800507:	8b 45 10             	mov    0x10(%ebp),%eax
  80050a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800510:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800517:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80051a:	72 05                	jb     800521 <printnum+0x35>
  80051c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80051f:	77 3e                	ja     80055f <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800521:	83 ec 0c             	sub    $0xc,%esp
  800524:	ff 75 18             	pushl  0x18(%ebp)
  800527:	83 eb 01             	sub    $0x1,%ebx
  80052a:	53                   	push   %ebx
  80052b:	50                   	push   %eax
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 00 23 00 00       	call   802840 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 13                	jmp    800566 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80055f:	83 eb 01             	sub    $0x1,%ebx
  800562:	85 db                	test   %ebx,%ebx
  800564:	7f ed                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	56                   	push   %esi
  80056a:	83 ec 04             	sub    $0x4,%esp
  80056d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800570:	ff 75 e0             	pushl  -0x20(%ebp)
  800573:	ff 75 dc             	pushl  -0x24(%ebp)
  800576:	ff 75 d8             	pushl  -0x28(%ebp)
  800579:	e8 f2 23 00 00       	call   802970 <__umoddi3>
  80057e:	83 c4 14             	add    $0x14,%esp
  800581:	0f be 80 6f 2c 80 00 	movsbl 0x802c6f(%eax),%eax
  800588:	50                   	push   %eax
  800589:	ff d7                	call   *%edi
  80058b:	83 c4 10             	add    $0x10,%esp
}
  80058e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800591:	5b                   	pop    %ebx
  800592:	5e                   	pop    %esi
  800593:	5f                   	pop    %edi
  800594:	5d                   	pop    %ebp
  800595:	c3                   	ret    

00800596 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800599:	83 fa 01             	cmp    $0x1,%edx
  80059c:	7e 0e                	jle    8005ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a3:	89 08                	mov    %ecx,(%eax)
  8005a5:	8b 02                	mov    (%edx),%eax
  8005a7:	8b 52 04             	mov    0x4(%edx),%edx
  8005aa:	eb 22                	jmp    8005ce <getuint+0x38>
	else if (lflag)
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	74 10                	je     8005c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005b5:	89 08                	mov    %ecx,(%eax)
  8005b7:	8b 02                	mov    (%edx),%eax
  8005b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005be:	eb 0e                	jmp    8005ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c5:	89 08                	mov    %ecx,(%eax)
  8005c7:	8b 02                	mov    (%edx),%eax
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ce:	5d                   	pop    %ebp
  8005cf:	c3                   	ret    

008005d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8005df:	73 0a                	jae    8005eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e4:	89 08                	mov    %ecx,(%eax)
  8005e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e9:	88 02                	mov    %al,(%edx)
}
  8005eb:	5d                   	pop    %ebp
  8005ec:	c3                   	ret    

008005ed <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f6:	50                   	push   %eax
  8005f7:	ff 75 10             	pushl  0x10(%ebp)
  8005fa:	ff 75 0c             	pushl  0xc(%ebp)
  8005fd:	ff 75 08             	pushl  0x8(%ebp)
  800600:	e8 05 00 00 00       	call   80060a <vprintfmt>
	va_end(ap);
  800605:	83 c4 10             	add    $0x10,%esp
}
  800608:	c9                   	leave  
  800609:	c3                   	ret    

0080060a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	57                   	push   %edi
  80060e:	56                   	push   %esi
  80060f:	53                   	push   %ebx
  800610:	83 ec 2c             	sub    $0x2c,%esp
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	8b 7d 10             	mov    0x10(%ebp),%edi
  80061c:	eb 12                	jmp    800630 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80061e:	85 c0                	test   %eax,%eax
  800620:	0f 84 90 03 00 00    	je     8009b6 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	50                   	push   %eax
  80062b:	ff d6                	call   *%esi
  80062d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800630:	83 c7 01             	add    $0x1,%edi
  800633:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800637:	83 f8 25             	cmp    $0x25,%eax
  80063a:	75 e2                	jne    80061e <vprintfmt+0x14>
  80063c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800640:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800647:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80064e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800655:	ba 00 00 00 00       	mov    $0x0,%edx
  80065a:	eb 07                	jmp    800663 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80065f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8d 47 01             	lea    0x1(%edi),%eax
  800666:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800669:	0f b6 07             	movzbl (%edi),%eax
  80066c:	0f b6 c8             	movzbl %al,%ecx
  80066f:	83 e8 23             	sub    $0x23,%eax
  800672:	3c 55                	cmp    $0x55,%al
  800674:	0f 87 21 03 00 00    	ja     80099b <vprintfmt+0x391>
  80067a:	0f b6 c0             	movzbl %al,%eax
  80067d:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800687:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80068b:	eb d6                	jmp    800663 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800690:	b8 00 00 00 00       	mov    $0x0,%eax
  800695:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800698:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80069b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80069f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006a5:	83 fa 09             	cmp    $0x9,%edx
  8006a8:	77 39                	ja     8006e3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006ad:	eb e9                	jmp    800698 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c0:	eb 27                	jmp    8006e9 <vprintfmt+0xdf>
  8006c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cc:	0f 49 c8             	cmovns %eax,%ecx
  8006cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	eb 8c                	jmp    800663 <vprintfmt+0x59>
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e1:	eb 80                	jmp    800663 <vprintfmt+0x59>
  8006e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ed:	0f 89 70 ff ff ff    	jns    800663 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800700:	e9 5e ff ff ff       	jmp    800663 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800705:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80070b:	e9 53 ff ff ff       	jmp    800663 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	ff 30                	pushl  (%eax)
  80071f:	ff d6                	call   *%esi
			break;
  800721:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800727:	e9 04 ff ff ff       	jmp    800630 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	99                   	cltd   
  800738:	31 d0                	xor    %edx,%eax
  80073a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80073c:	83 f8 0f             	cmp    $0xf,%eax
  80073f:	7f 0b                	jg     80074c <vprintfmt+0x142>
  800741:	8b 14 85 40 2f 80 00 	mov    0x802f40(,%eax,4),%edx
  800748:	85 d2                	test   %edx,%edx
  80074a:	75 18                	jne    800764 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80074c:	50                   	push   %eax
  80074d:	68 87 2c 80 00       	push   $0x802c87
  800752:	53                   	push   %ebx
  800753:	56                   	push   %esi
  800754:	e8 94 fe ff ff       	call   8005ed <printfmt>
  800759:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80075f:	e9 cc fe ff ff       	jmp    800630 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800764:	52                   	push   %edx
  800765:	68 75 30 80 00       	push   $0x803075
  80076a:	53                   	push   %ebx
  80076b:	56                   	push   %esi
  80076c:	e8 7c fe ff ff       	call   8005ed <printfmt>
  800771:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	e9 b4 fe ff ff       	jmp    800630 <vprintfmt+0x26>
  80077c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80077f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800782:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800790:	85 ff                	test   %edi,%edi
  800792:	ba 80 2c 80 00       	mov    $0x802c80,%edx
  800797:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80079a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80079e:	0f 84 92 00 00 00    	je     800836 <vprintfmt+0x22c>
  8007a4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007a8:	0f 8e 96 00 00 00    	jle    800844 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	51                   	push   %ecx
  8007b2:	57                   	push   %edi
  8007b3:	e8 86 02 00 00       	call   800a3e <strnlen>
  8007b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007bb:	29 c1                	sub    %eax,%ecx
  8007bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cf:	eb 0f                	jmp    8007e0 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007da:	83 ef 01             	sub    $0x1,%edi
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	85 ff                	test   %edi,%edi
  8007e2:	7f ed                	jg     8007d1 <vprintfmt+0x1c7>
  8007e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007ea:	85 c9                	test   %ecx,%ecx
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	0f 49 c1             	cmovns %ecx,%eax
  8007f4:	29 c1                	sub    %eax,%ecx
  8007f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007ff:	89 cb                	mov    %ecx,%ebx
  800801:	eb 4d                	jmp    800850 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800803:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800807:	74 1b                	je     800824 <vprintfmt+0x21a>
  800809:	0f be c0             	movsbl %al,%eax
  80080c:	83 e8 20             	sub    $0x20,%eax
  80080f:	83 f8 5e             	cmp    $0x5e,%eax
  800812:	76 10                	jbe    800824 <vprintfmt+0x21a>
					putch('?', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	ff 75 0c             	pushl  0xc(%ebp)
  80081a:	6a 3f                	push   $0x3f
  80081c:	ff 55 08             	call   *0x8(%ebp)
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb 0d                	jmp    800831 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	52                   	push   %edx
  80082b:	ff 55 08             	call   *0x8(%ebp)
  80082e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800831:	83 eb 01             	sub    $0x1,%ebx
  800834:	eb 1a                	jmp    800850 <vprintfmt+0x246>
  800836:	89 75 08             	mov    %esi,0x8(%ebp)
  800839:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800842:	eb 0c                	jmp    800850 <vprintfmt+0x246>
  800844:	89 75 08             	mov    %esi,0x8(%ebp)
  800847:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80084a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800850:	83 c7 01             	add    $0x1,%edi
  800853:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800857:	0f be d0             	movsbl %al,%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 23                	je     800881 <vprintfmt+0x277>
  80085e:	85 f6                	test   %esi,%esi
  800860:	78 a1                	js     800803 <vprintfmt+0x1f9>
  800862:	83 ee 01             	sub    $0x1,%esi
  800865:	79 9c                	jns    800803 <vprintfmt+0x1f9>
  800867:	89 df                	mov    %ebx,%edi
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086f:	eb 18                	jmp    800889 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	6a 20                	push   $0x20
  800877:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800879:	83 ef 01             	sub    $0x1,%edi
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	eb 08                	jmp    800889 <vprintfmt+0x27f>
  800881:	89 df                	mov    %ebx,%edi
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800889:	85 ff                	test   %edi,%edi
  80088b:	7f e4                	jg     800871 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800890:	e9 9b fd ff ff       	jmp    800630 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800895:	83 fa 01             	cmp    $0x1,%edx
  800898:	7e 16                	jle    8008b0 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8d 50 08             	lea    0x8(%eax),%edx
  8008a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a3:	8b 50 04             	mov    0x4(%eax),%edx
  8008a6:	8b 00                	mov    (%eax),%eax
  8008a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ae:	eb 32                	jmp    8008e2 <vprintfmt+0x2d8>
	else if (lflag)
  8008b0:	85 d2                	test   %edx,%edx
  8008b2:	74 18                	je     8008cc <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bd:	8b 00                	mov    (%eax),%eax
  8008bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c2:	89 c1                	mov    %eax,%ecx
  8008c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ca:	eb 16                	jmp    8008e2 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8d 50 04             	lea    0x4(%eax),%edx
  8008d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d5:	8b 00                	mov    (%eax),%eax
  8008d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008da:	89 c1                	mov    %eax,%ecx
  8008dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f1:	79 74                	jns    800967 <vprintfmt+0x35d>
				putch('-', putdat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	53                   	push   %ebx
  8008f7:	6a 2d                	push   $0x2d
  8008f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8008fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800901:	f7 d8                	neg    %eax
  800903:	83 d2 00             	adc    $0x0,%edx
  800906:	f7 da                	neg    %edx
  800908:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80090b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800910:	eb 55                	jmp    800967 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
  800915:	e8 7c fc ff ff       	call   800596 <getuint>
			base = 10;
  80091a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091f:	eb 46                	jmp    800967 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800921:	8d 45 14             	lea    0x14(%ebp),%eax
  800924:	e8 6d fc ff ff       	call   800596 <getuint>
                        base = 8;
  800929:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80092e:	eb 37                	jmp    800967 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	6a 30                	push   $0x30
  800936:	ff d6                	call   *%esi
			putch('x', putdat);
  800938:	83 c4 08             	add    $0x8,%esp
  80093b:	53                   	push   %ebx
  80093c:	6a 78                	push   $0x78
  80093e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800940:	8b 45 14             	mov    0x14(%ebp),%eax
  800943:	8d 50 04             	lea    0x4(%eax),%edx
  800946:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800949:	8b 00                	mov    (%eax),%eax
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800950:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800953:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800958:	eb 0d                	jmp    800967 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80095a:	8d 45 14             	lea    0x14(%ebp),%eax
  80095d:	e8 34 fc ff ff       	call   800596 <getuint>
			base = 16;
  800962:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800967:	83 ec 0c             	sub    $0xc,%esp
  80096a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096e:	57                   	push   %edi
  80096f:	ff 75 e0             	pushl  -0x20(%ebp)
  800972:	51                   	push   %ecx
  800973:	52                   	push   %edx
  800974:	50                   	push   %eax
  800975:	89 da                	mov    %ebx,%edx
  800977:	89 f0                	mov    %esi,%eax
  800979:	e8 6e fb ff ff       	call   8004ec <printnum>
			break;
  80097e:	83 c4 20             	add    $0x20,%esp
  800981:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800984:	e9 a7 fc ff ff       	jmp    800630 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800989:	83 ec 08             	sub    $0x8,%esp
  80098c:	53                   	push   %ebx
  80098d:	51                   	push   %ecx
  80098e:	ff d6                	call   *%esi
			break;
  800990:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800996:	e9 95 fc ff ff       	jmp    800630 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	53                   	push   %ebx
  80099f:	6a 25                	push   $0x25
  8009a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	eb 03                	jmp    8009ab <vprintfmt+0x3a1>
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009af:	75 f7                	jne    8009a8 <vprintfmt+0x39e>
  8009b1:	e9 7a fc ff ff       	jmp    800630 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 18             	sub    $0x18,%esp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	74 26                	je     800a05 <vsnprintf+0x47>
  8009df:	85 d2                	test   %edx,%edx
  8009e1:	7e 22                	jle    800a05 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e3:	ff 75 14             	pushl  0x14(%ebp)
  8009e6:	ff 75 10             	pushl  0x10(%ebp)
  8009e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ec:	50                   	push   %eax
  8009ed:	68 d0 05 80 00       	push   $0x8005d0
  8009f2:	e8 13 fc ff ff       	call   80060a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	eb 05                	jmp    800a0a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a12:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a15:	50                   	push   %eax
  800a16:	ff 75 10             	pushl  0x10(%ebp)
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	ff 75 08             	pushl  0x8(%ebp)
  800a1f:	e8 9a ff ff ff       	call   8009be <vsnprintf>
	va_end(ap);

	return rc;
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 03                	jmp    800a36 <strlen+0x10>
		n++;
  800a33:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3a:	75 f7                	jne    800a33 <strlen+0xd>
		n++;
	return n;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a44:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	eb 03                	jmp    800a51 <strnlen+0x13>
		n++;
  800a4e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a51:	39 c2                	cmp    %eax,%edx
  800a53:	74 08                	je     800a5d <strnlen+0x1f>
  800a55:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a59:	75 f3                	jne    800a4e <strnlen+0x10>
  800a5b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	53                   	push   %ebx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	83 c2 01             	add    $0x1,%edx
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a75:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a78:	84 db                	test   %bl,%bl
  800a7a:	75 ef                	jne    800a6b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a86:	53                   	push   %ebx
  800a87:	e8 9a ff ff ff       	call   800a26 <strlen>
  800a8c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8f:	ff 75 0c             	pushl  0xc(%ebp)
  800a92:	01 d8                	add    %ebx,%eax
  800a94:	50                   	push   %eax
  800a95:	e8 c5 ff ff ff       	call   800a5f <strcpy>
	return dst;
}
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab1:	89 f2                	mov    %esi,%edx
  800ab3:	eb 0f                	jmp    800ac4 <strncpy+0x23>
		*dst++ = *src;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	0f b6 01             	movzbl (%ecx),%eax
  800abb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abe:	80 39 01             	cmpb   $0x1,(%ecx)
  800ac1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac4:	39 da                	cmp    %ebx,%edx
  800ac6:	75 ed                	jne    800ab5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac8:	89 f0                	mov    %esi,%eax
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad9:	8b 55 10             	mov    0x10(%ebp),%edx
  800adc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ade:	85 d2                	test   %edx,%edx
  800ae0:	74 21                	je     800b03 <strlcpy+0x35>
  800ae2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae6:	89 f2                	mov    %esi,%edx
  800ae8:	eb 09                	jmp    800af3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aea:	83 c2 01             	add    $0x1,%edx
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af3:	39 c2                	cmp    %eax,%edx
  800af5:	74 09                	je     800b00 <strlcpy+0x32>
  800af7:	0f b6 19             	movzbl (%ecx),%ebx
  800afa:	84 db                	test   %bl,%bl
  800afc:	75 ec                	jne    800aea <strlcpy+0x1c>
  800afe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b00:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b03:	29 f0                	sub    %esi,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b12:	eb 06                	jmp    800b1a <strcmp+0x11>
		p++, q++;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b1a:	0f b6 01             	movzbl (%ecx),%eax
  800b1d:	84 c0                	test   %al,%al
  800b1f:	74 04                	je     800b25 <strcmp+0x1c>
  800b21:	3a 02                	cmp    (%edx),%al
  800b23:	74 ef                	je     800b14 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 12             	movzbl (%edx),%edx
  800b2b:	29 d0                	sub    %edx,%eax
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3e:	eb 06                	jmp    800b46 <strncmp+0x17>
		n--, p++, q++;
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b46:	39 d8                	cmp    %ebx,%eax
  800b48:	74 15                	je     800b5f <strncmp+0x30>
  800b4a:	0f b6 08             	movzbl (%eax),%ecx
  800b4d:	84 c9                	test   %cl,%cl
  800b4f:	74 04                	je     800b55 <strncmp+0x26>
  800b51:	3a 0a                	cmp    (%edx),%cl
  800b53:	74 eb                	je     800b40 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b55:	0f b6 00             	movzbl (%eax),%eax
  800b58:	0f b6 12             	movzbl (%edx),%edx
  800b5b:	29 d0                	sub    %edx,%eax
  800b5d:	eb 05                	jmp    800b64 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b71:	eb 07                	jmp    800b7a <strchr+0x13>
		if (*s == c)
  800b73:	38 ca                	cmp    %cl,%dl
  800b75:	74 0f                	je     800b86 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	0f b6 10             	movzbl (%eax),%edx
  800b7d:	84 d2                	test   %dl,%dl
  800b7f:	75 f2                	jne    800b73 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b92:	eb 03                	jmp    800b97 <strfind+0xf>
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b9a:	84 d2                	test   %dl,%dl
  800b9c:	74 04                	je     800ba2 <strfind+0x1a>
  800b9e:	38 ca                	cmp    %cl,%dl
  800ba0:	75 f2                	jne    800b94 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb0:	85 c9                	test   %ecx,%ecx
  800bb2:	74 36                	je     800bea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 28                	jne    800be4 <memset+0x40>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 23                	jne    800be4 <memset+0x40>
		c &= 0xFF;
  800bc1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	c1 e3 08             	shl    $0x8,%ebx
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	c1 e6 18             	shl    $0x18,%esi
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	c1 e0 10             	shl    $0x10,%eax
  800bd4:	09 f0                	or     %esi,%eax
  800bd6:	09 c2                	or     %eax,%edx
  800bd8:	89 d0                	mov    %edx,%eax
  800bda:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdf:	fc                   	cld    
  800be0:	f3 ab                	rep stos %eax,%es:(%edi)
  800be2:	eb 06                	jmp    800bea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	fc                   	cld    
  800be8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bea:	89 f8                	mov    %edi,%eax
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bff:	39 c6                	cmp    %eax,%esi
  800c01:	73 35                	jae    800c38 <memmove+0x47>
  800c03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c06:	39 d0                	cmp    %edx,%eax
  800c08:	73 2e                	jae    800c38 <memmove+0x47>
		s += n;
		d += n;
  800c0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c17:	75 13                	jne    800c2c <memmove+0x3b>
  800c19:	f6 c1 03             	test   $0x3,%cl
  800c1c:	75 0e                	jne    800c2c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1e:	83 ef 04             	sub    $0x4,%edi
  800c21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c24:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c27:	fd                   	std    
  800c28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2a:	eb 09                	jmp    800c35 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2c:	83 ef 01             	sub    $0x1,%edi
  800c2f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c32:	fd                   	std    
  800c33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c35:	fc                   	cld    
  800c36:	eb 1d                	jmp    800c55 <memmove+0x64>
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3c:	f6 c2 03             	test   $0x3,%dl
  800c3f:	75 0f                	jne    800c50 <memmove+0x5f>
  800c41:	f6 c1 03             	test   $0x3,%cl
  800c44:	75 0a                	jne    800c50 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c46:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	fc                   	cld    
  800c4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 05                	jmp    800c55 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	fc                   	cld    
  800c53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5c:	ff 75 10             	pushl  0x10(%ebp)
  800c5f:	ff 75 0c             	pushl  0xc(%ebp)
  800c62:	ff 75 08             	pushl  0x8(%ebp)
  800c65:	e8 87 ff ff ff       	call   800bf1 <memmove>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c77:	89 c6                	mov    %eax,%esi
  800c79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7c:	eb 1a                	jmp    800c98 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7e:	0f b6 08             	movzbl (%eax),%ecx
  800c81:	0f b6 1a             	movzbl (%edx),%ebx
  800c84:	38 d9                	cmp    %bl,%cl
  800c86:	74 0a                	je     800c92 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c88:	0f b6 c1             	movzbl %cl,%eax
  800c8b:	0f b6 db             	movzbl %bl,%ebx
  800c8e:	29 d8                	sub    %ebx,%eax
  800c90:	eb 0f                	jmp    800ca1 <memcmp+0x35>
		s1++, s2++;
  800c92:	83 c0 01             	add    $0x1,%eax
  800c95:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c98:	39 f0                	cmp    %esi,%eax
  800c9a:	75 e2                	jne    800c7e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb3:	eb 07                	jmp    800cbc <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	38 08                	cmp    %cl,(%eax)
  800cb7:	74 07                	je     800cc0 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb9:	83 c0 01             	add    $0x1,%eax
  800cbc:	39 d0                	cmp    %edx,%eax
  800cbe:	72 f5                	jb     800cb5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cce:	eb 03                	jmp    800cd3 <strtol+0x11>
		s++;
  800cd0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd3:	0f b6 01             	movzbl (%ecx),%eax
  800cd6:	3c 09                	cmp    $0x9,%al
  800cd8:	74 f6                	je     800cd0 <strtol+0xe>
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f2                	je     800cd0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cde:	3c 2b                	cmp    $0x2b,%al
  800ce0:	75 0a                	jne    800cec <strtol+0x2a>
		s++;
  800ce2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce5:	bf 00 00 00 00       	mov    $0x0,%edi
  800cea:	eb 10                	jmp    800cfc <strtol+0x3a>
  800cec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf1:	3c 2d                	cmp    $0x2d,%al
  800cf3:	75 07                	jne    800cfc <strtol+0x3a>
		s++, neg = 1;
  800cf5:	8d 49 01             	lea    0x1(%ecx),%ecx
  800cf8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	0f 94 c0             	sete   %al
  800d01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d07:	75 19                	jne    800d22 <strtol+0x60>
  800d09:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0c:	75 14                	jne    800d22 <strtol+0x60>
  800d0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d12:	0f 85 82 00 00 00    	jne    800d9a <strtol+0xd8>
		s += 2, base = 16;
  800d18:	83 c1 02             	add    $0x2,%ecx
  800d1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d20:	eb 16                	jmp    800d38 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d22:	84 c0                	test   %al,%al
  800d24:	74 12                	je     800d38 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d26:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2e:	75 08                	jne    800d38 <strtol+0x76>
		s++, base = 8;
  800d30:	83 c1 01             	add    $0x1,%ecx
  800d33:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d40:	0f b6 11             	movzbl (%ecx),%edx
  800d43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d46:	89 f3                	mov    %esi,%ebx
  800d48:	80 fb 09             	cmp    $0x9,%bl
  800d4b:	77 08                	ja     800d55 <strtol+0x93>
			dig = *s - '0';
  800d4d:	0f be d2             	movsbl %dl,%edx
  800d50:	83 ea 30             	sub    $0x30,%edx
  800d53:	eb 22                	jmp    800d77 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800d55:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d58:	89 f3                	mov    %esi,%ebx
  800d5a:	80 fb 19             	cmp    $0x19,%bl
  800d5d:	77 08                	ja     800d67 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800d5f:	0f be d2             	movsbl %dl,%edx
  800d62:	83 ea 57             	sub    $0x57,%edx
  800d65:	eb 10                	jmp    800d77 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800d67:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d6a:	89 f3                	mov    %esi,%ebx
  800d6c:	80 fb 19             	cmp    $0x19,%bl
  800d6f:	77 16                	ja     800d87 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d71:	0f be d2             	movsbl %dl,%edx
  800d74:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d77:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d7a:	7d 0f                	jge    800d8b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800d7c:	83 c1 01             	add    $0x1,%ecx
  800d7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d83:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d85:	eb b9                	jmp    800d40 <strtol+0x7e>
  800d87:	89 c2                	mov    %eax,%edx
  800d89:	eb 02                	jmp    800d8d <strtol+0xcb>
  800d8b:	89 c2                	mov    %eax,%edx

	if (endptr)
  800d8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d91:	74 0d                	je     800da0 <strtol+0xde>
		*endptr = (char *) s;
  800d93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d96:	89 0e                	mov    %ecx,(%esi)
  800d98:	eb 06                	jmp    800da0 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9a:	84 c0                	test   %al,%al
  800d9c:	75 92                	jne    800d30 <strtol+0x6e>
  800d9e:	eb 98                	jmp    800d38 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800da0:	f7 da                	neg    %edx
  800da2:	85 ff                	test   %edi,%edi
  800da4:	0f 45 c2             	cmovne %edx,%eax
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	89 c7                	mov    %eax,%edi
  800dc1:	89 c6                	mov    %eax,%esi
  800dc3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_cgetc>:

int
sys_cgetc(void)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dda:	89 d1                	mov    %edx,%ecx
  800ddc:	89 d3                	mov    %edx,%ebx
  800dde:	89 d7                	mov    %edx,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 03                	push   $0x3
  800e11:	68 9f 2f 80 00       	push   $0x802f9f
  800e16:	6a 22                	push   $0x22
  800e18:	68 bc 2f 80 00       	push   $0x802fbc
  800e1d:	e8 dd f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3a:	89 d1                	mov    %edx,%ecx
  800e3c:	89 d3                	mov    %edx,%ebx
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_yield>:

void
sys_yield(void)
{      
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 d3                	mov    %edx,%ebx
  800e5d:	89 d7                	mov    %edx,%edi
  800e5f:	89 d6                	mov    %edx,%esi
  800e61:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e71:	be 00 00 00 00       	mov    $0x0,%esi
  800e76:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	89 f7                	mov    %esi,%edi
  800e86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 17                	jle    800ea3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 04                	push   $0x4
  800e92:	68 9f 2f 80 00       	push   $0x802f9f
  800e97:	6a 22                	push   $0x22
  800e99:	68 bc 2f 80 00       	push   $0x802fbc
  800e9e:	e8 5c f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800eb4:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 17                	jle    800ee5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 05                	push   $0x5
  800ed4:	68 9f 2f 80 00       	push   $0x802f9f
  800ed9:	6a 22                	push   $0x22
  800edb:	68 bc 2f 80 00       	push   $0x802fbc
  800ee0:	e8 1a f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 06 00 00 00       	mov    $0x6,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 17                	jle    800f27 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 06                	push   $0x6
  800f16:	68 9f 2f 80 00       	push   $0x802f9f
  800f1b:	6a 22                	push   $0x22
  800f1d:	68 bc 2f 80 00       	push   $0x802fbc
  800f22:	e8 d8 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	89 df                	mov    %ebx,%edi
  800f4a:	89 de                	mov    %ebx,%esi
  800f4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	7e 17                	jle    800f69 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	50                   	push   %eax
  800f56:	6a 08                	push   $0x8
  800f58:	68 9f 2f 80 00       	push   $0x802f9f
  800f5d:	6a 22                	push   $0x22
  800f5f:	68 bc 2f 80 00       	push   $0x802fbc
  800f64:	e8 96 f4 ff ff       	call   8003ff <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7f:	b8 09 00 00 00       	mov    $0x9,%eax
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8a:	89 df                	mov    %ebx,%edi
  800f8c:	89 de                	mov    %ebx,%esi
  800f8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 17                	jle    800fab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	50                   	push   %eax
  800f98:	6a 09                	push   $0x9
  800f9a:	68 9f 2f 80 00       	push   $0x802f9f
  800f9f:	6a 22                	push   $0x22
  800fa1:	68 bc 2f 80 00       	push   $0x802fbc
  800fa6:	e8 54 f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 df                	mov    %ebx,%edi
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 17                	jle    800fed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	6a 0a                	push   $0xa
  800fdc:	68 9f 2f 80 00       	push   $0x802f9f
  800fe1:	6a 22                	push   $0x22
  800fe3:	68 bc 2f 80 00       	push   $0x802fbc
  800fe8:	e8 12 f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ffb:	be 00 00 00 00       	mov    $0x0,%esi
  801000:	b8 0c 00 00 00       	mov    $0xc,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
  80101e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801021:	b9 00 00 00 00       	mov    $0x0,%ecx
  801026:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102b:	8b 55 08             	mov    0x8(%ebp),%edx
  80102e:	89 cb                	mov    %ecx,%ebx
  801030:	89 cf                	mov    %ecx,%edi
  801032:	89 ce                	mov    %ecx,%esi
  801034:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801036:	85 c0                	test   %eax,%eax
  801038:	7e 17                	jle    801051 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	50                   	push   %eax
  80103e:	6a 0d                	push   $0xd
  801040:	68 9f 2f 80 00       	push   $0x802f9f
  801045:	6a 22                	push   $0x22
  801047:	68 bc 2f 80 00       	push   $0x802fbc
  80104c:	e8 ae f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80105f:	ba 00 00 00 00       	mov    $0x0,%edx
  801064:	b8 0e 00 00 00       	mov    $0xe,%eax
  801069:	89 d1                	mov    %edx,%ecx
  80106b:	89 d3                	mov    %edx,%ebx
  80106d:	89 d7                	mov    %edx,%edi
  80106f:	89 d6                	mov    %edx,%esi
  801071:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <sys_transmit>:

int
sys_transmit(void *addr)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801081:	b9 00 00 00 00       	mov    $0x0,%ecx
  801086:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	89 cb                	mov    %ecx,%ebx
  801090:	89 cf                	mov    %ecx,%edi
  801092:	89 ce                	mov    %ecx,%esi
  801094:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801096:	85 c0                	test   %eax,%eax
  801098:	7e 17                	jle    8010b1 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	50                   	push   %eax
  80109e:	6a 0f                	push   $0xf
  8010a0:	68 9f 2f 80 00       	push   $0x802f9f
  8010a5:	6a 22                	push   $0x22
  8010a7:	68 bc 2f 80 00       	push   $0x802fbc
  8010ac:	e8 4e f3 ff ff       	call   8003ff <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_recv>:

int
sys_recv(void *addr)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c7:	b8 10 00 00 00       	mov    $0x10,%eax
  8010cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cf:	89 cb                	mov    %ecx,%ebx
  8010d1:	89 cf                	mov    %ecx,%edi
  8010d3:	89 ce                	mov    %ecx,%esi
  8010d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	7e 17                	jle    8010f2 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	50                   	push   %eax
  8010df:	6a 10                	push   $0x10
  8010e1:	68 9f 2f 80 00       	push   $0x802f9f
  8010e6:	6a 22                	push   $0x22
  8010e8:	68 bc 2f 80 00       	push   $0x802fbc
  8010ed:	e8 0d f3 ff ff       	call   8003ff <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8010f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5f                   	pop    %edi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	05 00 00 00 30       	add    $0x30000000,%eax
  801105:	c1 e8 0c             	shr    $0xc,%eax
}
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110d:	8b 45 08             	mov    0x8(%ebp),%eax
  801110:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801115:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801127:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 16             	shr    $0x16,%edx
  801131:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	74 11                	je     80114e <fd_alloc+0x2d>
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 0c             	shr    $0xc,%edx
  801142:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	75 09                	jne    801157 <fd_alloc+0x36>
			*fd_store = fd;
  80114e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801150:	b8 00 00 00 00       	mov    $0x0,%eax
  801155:	eb 17                	jmp    80116e <fd_alloc+0x4d>
  801157:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801161:	75 c9                	jne    80112c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801163:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801169:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801176:	83 f8 1f             	cmp    $0x1f,%eax
  801179:	77 36                	ja     8011b1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117b:	c1 e0 0c             	shl    $0xc,%eax
  80117e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 16             	shr    $0x16,%edx
  801188:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 24                	je     8011b8 <fd_lookup+0x48>
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 0c             	shr    $0xc,%edx
  801199:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a0:	f6 c2 01             	test   $0x1,%dl
  8011a3:	74 1a                	je     8011bf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	eb 13                	jmp    8011c4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b6:	eb 0c                	jmp    8011c4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bd:	eb 05                	jmp    8011c4 <fd_lookup+0x54>
  8011bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d4:	eb 13                	jmp    8011e9 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8011d6:	39 08                	cmp    %ecx,(%eax)
  8011d8:	75 0c                	jne    8011e6 <dev_lookup+0x20>
			*dev = devtab[i];
  8011da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	eb 36                	jmp    80121c <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e6:	83 c2 01             	add    $0x1,%edx
  8011e9:	8b 04 95 48 30 80 00 	mov    0x803048(,%edx,4),%eax
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	75 e2                	jne    8011d6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f4:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  8011f9:	8b 40 48             	mov    0x48(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	51                   	push   %ecx
  801200:	50                   	push   %eax
  801201:	68 cc 2f 80 00       	push   $0x802fcc
  801206:	e8 cd f2 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80120b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 10             	sub    $0x10,%esp
  801226:	8b 75 08             	mov    0x8(%ebp),%esi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801230:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801236:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801239:	50                   	push   %eax
  80123a:	e8 31 ff ff ff       	call   801170 <fd_lookup>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 05                	js     80124b <fd_close+0x2d>
	    || fd != fd2)
  801246:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801249:	74 0c                	je     801257 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124b:	84 db                	test   %bl,%bl
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
  801252:	0f 44 c2             	cmove  %edx,%eax
  801255:	eb 41                	jmp    801298 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	ff 36                	pushl  (%esi)
  801260:	e8 61 ff ff ff       	call   8011c6 <dev_lookup>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1a                	js     801288 <fd_close+0x6a>
		if (dev->dev_close)
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801279:	85 c0                	test   %eax,%eax
  80127b:	74 0b                	je     801288 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	56                   	push   %esi
  801281:	ff d0                	call   *%eax
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	56                   	push   %esi
  80128c:	6a 00                	push   $0x0
  80128e:	e8 5a fc ff ff       	call   800eed <sys_page_unmap>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 d8                	mov    %ebx,%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 bf fe ff ff       	call   801170 <fd_lookup>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	78 10                	js     8012ca <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	6a 01                	push   $0x1
  8012bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c2:	e8 57 ff ff ff       	call   80121e <fd_close>
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <close_all>:

void
close_all(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	53                   	push   %ebx
  8012dc:	e8 be ff ff ff       	call   80129f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e1:	83 c3 01             	add    $0x1,%ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	83 fb 20             	cmp    $0x20,%ebx
  8012ea:	75 ec                	jne    8012d8 <close_all+0xc>
		close(i);
}
  8012ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	57                   	push   %edi
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 2c             	sub    $0x2c,%esp
  8012fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 67 fe ff ff       	call   801170 <fd_lookup>
  801309:	89 c2                	mov    %eax,%edx
  80130b:	83 c4 08             	add    $0x8,%esp
  80130e:	85 d2                	test   %edx,%edx
  801310:	0f 88 c1 00 00 00    	js     8013d7 <dup+0xe6>
		return r;
	close(newfdnum);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	56                   	push   %esi
  80131a:	e8 80 ff ff ff       	call   80129f <close>

	newfd = INDEX2FD(newfdnum);
  80131f:	89 f3                	mov    %esi,%ebx
  801321:	c1 e3 0c             	shl    $0xc,%ebx
  801324:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80132a:	83 c4 04             	add    $0x4,%esp
  80132d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801330:	e8 d5 fd ff ff       	call   80110a <fd2data>
  801335:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801337:	89 1c 24             	mov    %ebx,(%esp)
  80133a:	e8 cb fd ff ff       	call   80110a <fd2data>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801345:	89 f8                	mov    %edi,%eax
  801347:	c1 e8 16             	shr    $0x16,%eax
  80134a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801351:	a8 01                	test   $0x1,%al
  801353:	74 37                	je     80138c <dup+0x9b>
  801355:	89 f8                	mov    %edi,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
  80135a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801361:	f6 c2 01             	test   $0x1,%dl
  801364:	74 26                	je     80138c <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801366:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	25 07 0e 00 00       	and    $0xe07,%eax
  801375:	50                   	push   %eax
  801376:	ff 75 d4             	pushl  -0x2c(%ebp)
  801379:	6a 00                	push   $0x0
  80137b:	57                   	push   %edi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 28 fb ff ff       	call   800eab <sys_page_map>
  801383:	89 c7                	mov    %eax,%edi
  801385:	83 c4 20             	add    $0x20,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 2e                	js     8013ba <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138f:	89 d0                	mov    %edx,%eax
  801391:	c1 e8 0c             	shr    $0xc,%eax
  801394:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a3:	50                   	push   %eax
  8013a4:	53                   	push   %ebx
  8013a5:	6a 00                	push   $0x0
  8013a7:	52                   	push   %edx
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 fc fa ff ff       	call   800eab <sys_page_map>
  8013af:	89 c7                	mov    %eax,%edi
  8013b1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013b4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b6:	85 ff                	test   %edi,%edi
  8013b8:	79 1d                	jns    8013d7 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	53                   	push   %ebx
  8013be:	6a 00                	push   $0x0
  8013c0:	e8 28 fb ff ff       	call   800eed <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 1b fb ff ff       	call   800eed <sys_page_unmap>
	return r;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f8                	mov    %edi,%eax
}
  8013d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	53                   	push   %ebx
  8013ee:	e8 7d fd ff ff       	call   801170 <fd_lookup>
  8013f3:	83 c4 08             	add    $0x8,%esp
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 6d                	js     801469 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	ff 30                	pushl  (%eax)
  801408:	e8 b9 fd ff ff       	call   8011c6 <dev_lookup>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 4c                	js     801460 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801414:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801417:	8b 42 08             	mov    0x8(%edx),%eax
  80141a:	83 e0 03             	and    $0x3,%eax
  80141d:	83 f8 01             	cmp    $0x1,%eax
  801420:	75 21                	jne    801443 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801422:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  801427:	8b 40 48             	mov    0x48(%eax),%eax
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	53                   	push   %ebx
  80142e:	50                   	push   %eax
  80142f:	68 0d 30 80 00       	push   $0x80300d
  801434:	e8 9f f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801441:	eb 26                	jmp    801469 <read+0x8a>
	}
	if (!dev->dev_read)
  801443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801446:	8b 40 08             	mov    0x8(%eax),%eax
  801449:	85 c0                	test   %eax,%eax
  80144b:	74 17                	je     801464 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	ff 75 10             	pushl  0x10(%ebp)
  801453:	ff 75 0c             	pushl  0xc(%ebp)
  801456:	52                   	push   %edx
  801457:	ff d0                	call   *%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	eb 09                	jmp    801469 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801460:	89 c2                	mov    %eax,%edx
  801462:	eb 05                	jmp    801469 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801464:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801469:	89 d0                	mov    %edx,%eax
  80146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	8b 7d 08             	mov    0x8(%ebp),%edi
  80147c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801484:	eb 21                	jmp    8014a7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	89 f0                	mov    %esi,%eax
  80148b:	29 d8                	sub    %ebx,%eax
  80148d:	50                   	push   %eax
  80148e:	89 d8                	mov    %ebx,%eax
  801490:	03 45 0c             	add    0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	57                   	push   %edi
  801495:	e8 45 ff ff ff       	call   8013df <read>
		if (m < 0)
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 0c                	js     8014ad <readn+0x3d>
			return m;
		if (m == 0)
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	74 06                	je     8014ab <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a5:	01 c3                	add    %eax,%ebx
  8014a7:	39 f3                	cmp    %esi,%ebx
  8014a9:	72 db                	jb     801486 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014ab:	89 d8                	mov    %ebx,%eax
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	53                   	push   %ebx
  8014c4:	e8 a7 fc ff ff       	call   801170 <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 68                	js     80153a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	ff 30                	pushl  (%eax)
  8014de:	e8 e3 fc ff ff       	call   8011c6 <dev_lookup>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 47                	js     801531 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f1:	75 21                	jne    801514 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 29 30 80 00       	push   $0x803029
  801505:	e8 ce ef ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801512:	eb 26                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801514:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801517:	8b 52 0c             	mov    0xc(%edx),%edx
  80151a:	85 d2                	test   %edx,%edx
  80151c:	74 17                	je     801535 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	50                   	push   %eax
  801528:	ff d2                	call   *%edx
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <seek>:

int
seek(int fdnum, off_t offset)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801547:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 1d fc ff ff       	call   801170 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 0e                	js     801568 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801560:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801563:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	53                   	push   %ebx
  801579:	e8 f2 fb ff ff       	call   801170 <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	89 c2                	mov    %eax,%edx
  801583:	85 c0                	test   %eax,%eax
  801585:	78 65                	js     8015ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	ff 30                	pushl  (%eax)
  801593:	e8 2e fc ff ff       	call   8011c6 <dev_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 44                	js     8015e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a6:	75 21                	jne    8015c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a8:	a1 b0 77 80 00       	mov    0x8077b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ad:	8b 40 48             	mov    0x48(%eax),%eax
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	50                   	push   %eax
  8015b5:	68 ec 2f 80 00       	push   $0x802fec
  8015ba:	e8 19 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c7:	eb 23                	jmp    8015ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cc:	8b 52 18             	mov    0x18(%edx),%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	74 14                	je     8015e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	50                   	push   %eax
  8015da:	ff d2                	call   *%edx
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb 09                	jmp    8015ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e3:	89 c2                	mov    %eax,%edx
  8015e5:	eb 05                	jmp    8015ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	e8 67 fb ff ff       	call   801170 <fd_lookup>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 58                	js     80166a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	ff 30                	pushl  (%eax)
  80161e:	e8 a3 fb ff ff       	call   8011c6 <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 37                	js     801661 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801631:	74 32                	je     801665 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801633:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801636:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163d:	00 00 00 
	stat->st_isdir = 0;
  801640:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801647:	00 00 00 
	stat->st_dev = dev;
  80164a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	ff 75 f0             	pushl  -0x10(%ebp)
  801657:	ff 50 14             	call   *0x14(%eax)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 09 02 00 00       	call   80188c <open>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 db                	test   %ebx,%ebx
  80168a:	78 1b                	js     8016a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	53                   	push   %ebx
  801693:	e8 5b ff ff ff       	call   8015f3 <fstat>
  801698:	89 c6                	mov    %eax,%esi
	close(fd);
  80169a:	89 1c 24             	mov    %ebx,(%esp)
  80169d:	e8 fd fb ff ff       	call   80129f <close>
	return r;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	89 f0                	mov    %esi,%eax
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	89 c6                	mov    %eax,%esi
  8016b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016be:	75 12                	jne    8016d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	6a 01                	push   $0x1
  8016c5:	e8 fc 10 00 00       	call   8027c6 <ipc_find_env>
  8016ca:	a3 00 60 80 00       	mov    %eax,0x806000
  8016cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d2:	6a 07                	push   $0x7
  8016d4:	68 00 80 80 00       	push   $0x808000
  8016d9:	56                   	push   %esi
  8016da:	ff 35 00 60 80 00    	pushl  0x806000
  8016e0:	e8 8d 10 00 00       	call   802772 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e5:	83 c4 0c             	add    $0xc,%esp
  8016e8:	6a 00                	push   $0x0
  8016ea:	53                   	push   %ebx
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 17 10 00 00       	call   802709 <ipc_recv>
}
  8016f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 02 00 00 00       	mov    $0x2,%eax
  80171c:	e8 8d ff ff ff       	call   8016ae <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 06 00 00 00       	mov    $0x6,%eax
  80173e:	e8 6b ff ff ff       	call   8016ae <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 05 00 00 00       	mov    $0x5,%eax
  801764:	e8 45 ff ff ff       	call   8016ae <fsipc>
  801769:	89 c2                	mov    %eax,%edx
  80176b:	85 d2                	test   %edx,%edx
  80176d:	78 2c                	js     80179b <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	68 00 80 80 00       	push   $0x808000
  801777:	53                   	push   %ebx
  801778:	e8 e2 f2 ff ff       	call   800a5f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177d:	a1 80 80 80 00       	mov    0x808080,%eax
  801782:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801788:	a1 84 80 80 00       	mov    0x808084,%eax
  80178d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b2:	a3 00 80 80 00       	mov    %eax,0x808000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8017b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017ba:	eb 3d                	jmp    8017f9 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8017bc:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8017c2:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8017c7:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	57                   	push   %edi
  8017ce:	53                   	push   %ebx
  8017cf:	68 08 80 80 00       	push   $0x808008
  8017d4:	e8 18 f4 ff ff       	call   800bf1 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8017d9:	89 3d 04 80 80 00    	mov    %edi,0x808004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 c0 fe ff ff       	call   8016ae <fsipc>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 0d                	js     801802 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8017f5:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8017f7:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8017f9:	85 f6                	test   %esi,%esi
  8017fb:	75 bf                	jne    8017bc <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8017fd:	89 d8                	mov    %ebx,%eax
  8017ff:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  80181d:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 03 00 00 00       	mov    $0x3,%eax
  80182d:	e8 7c fe ff ff       	call   8016ae <fsipc>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 4b                	js     801883 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801838:	39 c6                	cmp    %eax,%esi
  80183a:	73 16                	jae    801852 <devfile_read+0x48>
  80183c:	68 5c 30 80 00       	push   $0x80305c
  801841:	68 63 30 80 00       	push   $0x803063
  801846:	6a 7c                	push   $0x7c
  801848:	68 78 30 80 00       	push   $0x803078
  80184d:	e8 ad eb ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  801852:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801857:	7e 16                	jle    80186f <devfile_read+0x65>
  801859:	68 83 30 80 00       	push   $0x803083
  80185e:	68 63 30 80 00       	push   $0x803063
  801863:	6a 7d                	push   $0x7d
  801865:	68 78 30 80 00       	push   $0x803078
  80186a:	e8 90 eb ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	50                   	push   %eax
  801873:	68 00 80 80 00       	push   $0x808000
  801878:	ff 75 0c             	pushl  0xc(%ebp)
  80187b:	e8 71 f3 ff ff       	call   800bf1 <memmove>
	return r;
  801880:	83 c4 10             	add    $0x10,%esp
}
  801883:	89 d8                	mov    %ebx,%eax
  801885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 20             	sub    $0x20,%esp
  801893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801896:	53                   	push   %ebx
  801897:	e8 8a f1 ff ff       	call   800a26 <strlen>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a4:	7f 67                	jg     80190d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	e8 6f f8 ff ff       	call   801121 <fd_alloc>
  8018b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 57                	js     801912 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	68 00 80 80 00       	push   $0x808000
  8018c4:	e8 96 f1 ff ff       	call   800a5f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cc:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d9:	e8 d0 fd ff ff       	call   8016ae <fsipc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 14                	jns    8018fb <open+0x6f>
		fd_close(fd, 0);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	6a 00                	push   $0x0
  8018ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ef:	e8 2a f9 ff ff       	call   80121e <fd_close>
		return r;
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	89 da                	mov    %ebx,%edx
  8018f9:	eb 17                	jmp    801912 <open+0x86>
	}

	return fd2num(fd);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801901:	e8 f4 f7 ff ff       	call   8010fa <fd2num>
  801906:	89 c2                	mov    %eax,%edx
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb 05                	jmp    801912 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80190d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	b8 08 00 00 00       	mov    $0x8,%eax
  801929:	e8 80 fd ff ff       	call   8016ae <fsipc>
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	57                   	push   %edi
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80193c:	6a 00                	push   $0x0
  80193e:	ff 75 08             	pushl  0x8(%ebp)
  801941:	e8 46 ff ff ff       	call   80188c <open>
  801946:	89 c7                	mov    %eax,%edi
  801948:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	0f 88 97 04 00 00    	js     801df0 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801959:	83 ec 04             	sub    $0x4,%esp
  80195c:	68 00 02 00 00       	push   $0x200
  801961:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	57                   	push   %edi
  801969:	e8 02 fb ff ff       	call   801470 <readn>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	3d 00 02 00 00       	cmp    $0x200,%eax
  801976:	75 0c                	jne    801984 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801978:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80197f:	45 4c 46 
  801982:	74 33                	je     8019b7 <spawn+0x87>
		close(fd);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80198d:	e8 0d f9 ff ff       	call   80129f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801992:	83 c4 0c             	add    $0xc,%esp
  801995:	68 7f 45 4c 46       	push   $0x464c457f
  80199a:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019a0:	68 8f 30 80 00       	push   $0x80308f
  8019a5:	e8 2e eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8019b2:	e9 be 04 00 00       	jmp    801e75 <spawn+0x545>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8019b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8019bc:	cd 30                	int    $0x30
  8019be:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019c4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	0f 88 26 04 00 00    	js     801df8 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019d2:	89 c6                	mov    %eax,%esi
  8019d4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019da:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019dd:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019e3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019e9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019f0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019f6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a01:	be 00 00 00 00       	mov    $0x0,%esi
  801a06:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a09:	eb 13                	jmp    801a1e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	50                   	push   %eax
  801a0f:	e8 12 f0 ff ff       	call   800a26 <strlen>
  801a14:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a18:	83 c3 01             	add    $0x1,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a25:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	75 df                	jne    801a0b <spawn+0xdb>
  801a2c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a32:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a38:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a3d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a3f:	89 fa                	mov    %edi,%edx
  801a41:	83 e2 fc             	and    $0xfffffffc,%edx
  801a44:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a4b:	29 c2                	sub    %eax,%edx
  801a4d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a53:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a56:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a5b:	0f 86 a7 03 00 00    	jbe    801e08 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	6a 07                	push   $0x7
  801a66:	68 00 00 40 00       	push   $0x400000
  801a6b:	6a 00                	push   $0x0
  801a6d:	e8 f6 f3 ff ff       	call   800e68 <sys_page_alloc>
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	85 c0                	test   %eax,%eax
  801a77:	0f 88 f8 03 00 00    	js     801e75 <spawn+0x545>
  801a7d:	be 00 00 00 00       	mov    $0x0,%esi
  801a82:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a8b:	eb 30                	jmp    801abd <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a8d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a93:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a99:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801aa2:	57                   	push   %edi
  801aa3:	e8 b7 ef ff ff       	call   800a5f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801aa8:	83 c4 04             	add    $0x4,%esp
  801aab:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801aae:	e8 73 ef ff ff       	call   800a26 <strlen>
  801ab3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ab7:	83 c6 01             	add    $0x1,%esi
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ac3:	7f c8                	jg     801a8d <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ac5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801acb:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ad1:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ad8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ade:	74 19                	je     801af9 <spawn+0x1c9>
  801ae0:	68 1c 31 80 00       	push   $0x80311c
  801ae5:	68 63 30 80 00       	push   $0x803063
  801aea:	68 f1 00 00 00       	push   $0xf1
  801aef:	68 a9 30 80 00       	push   $0x8030a9
  801af4:	e8 06 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801af9:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801aff:	89 f8                	mov    %edi,%eax
  801b01:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b06:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b09:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b0f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b12:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b18:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	6a 07                	push   $0x7
  801b23:	68 00 d0 bf ee       	push   $0xeebfd000
  801b28:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b2e:	68 00 00 40 00       	push   $0x400000
  801b33:	6a 00                	push   $0x0
  801b35:	e8 71 f3 ff ff       	call   800eab <sys_page_map>
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	83 c4 20             	add    $0x20,%esp
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	0f 88 1a 03 00 00    	js     801e61 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b47:	83 ec 08             	sub    $0x8,%esp
  801b4a:	68 00 00 40 00       	push   $0x400000
  801b4f:	6a 00                	push   $0x0
  801b51:	e8 97 f3 ff ff       	call   800eed <sys_page_unmap>
  801b56:	89 c3                	mov    %eax,%ebx
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	0f 88 fe 02 00 00    	js     801e61 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b63:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b69:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b70:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b76:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b7d:	00 00 00 
  801b80:	e9 85 01 00 00       	jmp    801d0a <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801b85:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b8b:	83 38 01             	cmpl   $0x1,(%eax)
  801b8e:	0f 85 68 01 00 00    	jne    801cfc <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	8b 40 18             	mov    0x18(%eax),%eax
  801b99:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b9f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ba2:	83 f8 01             	cmp    $0x1,%eax
  801ba5:	19 c0                	sbb    %eax,%eax
  801ba7:	83 e0 fe             	and    $0xfffffffe,%eax
  801baa:	83 c0 07             	add    $0x7,%eax
  801bad:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bb3:	89 f8                	mov    %edi,%eax
  801bb5:	8b 7f 04             	mov    0x4(%edi),%edi
  801bb8:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bbe:	8b 78 10             	mov    0x10(%eax),%edi
  801bc1:	8b 48 14             	mov    0x14(%eax),%ecx
  801bc4:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801bca:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bcd:	89 f0                	mov    %esi,%eax
  801bcf:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bd4:	74 10                	je     801be6 <spawn+0x2b6>
		va -= i;
  801bd6:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bd8:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801bde:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801be0:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801beb:	e9 fa 00 00 00       	jmp    801cea <spawn+0x3ba>
		if (i >= filesz) {
  801bf0:	39 fb                	cmp    %edi,%ebx
  801bf2:	72 27                	jb     801c1b <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bf4:	83 ec 04             	sub    $0x4,%esp
  801bf7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bfd:	56                   	push   %esi
  801bfe:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c04:	e8 5f f2 ff ff       	call   800e68 <sys_page_alloc>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 89 ca 00 00 00    	jns    801cde <spawn+0x3ae>
  801c14:	89 c7                	mov    %eax,%edi
  801c16:	e9 fe 01 00 00       	jmp    801e19 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c1b:	83 ec 04             	sub    $0x4,%esp
  801c1e:	6a 07                	push   $0x7
  801c20:	68 00 00 40 00       	push   $0x400000
  801c25:	6a 00                	push   $0x0
  801c27:	e8 3c f2 ff ff       	call   800e68 <sys_page_alloc>
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 d8 01 00 00    	js     801e0f <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c40:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c4d:	e8 ef f8 ff ff       	call   801541 <seek>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	0f 88 b6 01 00 00    	js     801e13 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c5d:	83 ec 04             	sub    $0x4,%esp
  801c60:	89 fa                	mov    %edi,%edx
  801c62:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801c68:	89 d0                	mov    %edx,%eax
  801c6a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801c70:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c75:	0f 47 c1             	cmova  %ecx,%eax
  801c78:	50                   	push   %eax
  801c79:	68 00 00 40 00       	push   $0x400000
  801c7e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c84:	e8 e7 f7 ff ff       	call   801470 <readn>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 83 01 00 00    	js     801e17 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c9d:	56                   	push   %esi
  801c9e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ca4:	68 00 00 40 00       	push   $0x400000
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 fb f1 ff ff       	call   800eab <sys_page_map>
  801cb0:	83 c4 20             	add    $0x20,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 15                	jns    801ccc <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801cb7:	50                   	push   %eax
  801cb8:	68 b5 30 80 00       	push   $0x8030b5
  801cbd:	68 24 01 00 00       	push   $0x124
  801cc2:	68 a9 30 80 00       	push   $0x8030a9
  801cc7:	e8 33 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801ccc:	83 ec 08             	sub    $0x8,%esp
  801ccf:	68 00 00 40 00       	push   $0x400000
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 12 f2 ff ff       	call   800eed <sys_page_unmap>
  801cdb:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cde:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ce4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cea:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cf0:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801cf6:	0f 82 f4 fe ff ff    	jb     801bf0 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cfc:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d03:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d0a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d11:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d17:	0f 8c 68 fe ff ff    	jl     801b85 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d26:	e8 74 f5 ff ff       	call   80129f <close>
  801d2b:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d33:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801d39:	89 d8                	mov    %ebx,%eax
  801d3b:	c1 e8 16             	shr    $0x16,%eax
  801d3e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d45:	a8 01                	test   $0x1,%al
  801d47:	74 53                	je     801d9c <spawn+0x46c>
  801d49:	89 d8                	mov    %ebx,%eax
  801d4b:	c1 e8 0c             	shr    $0xc,%eax
  801d4e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d55:	f6 c2 01             	test   $0x1,%dl
  801d58:	74 42                	je     801d9c <spawn+0x46c>
  801d5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d61:	f6 c6 04             	test   $0x4,%dh
  801d64:	74 36                	je     801d9c <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801d66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	25 07 0e 00 00       	and    $0xe07,%eax
  801d75:	50                   	push   %eax
  801d76:	53                   	push   %ebx
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 2b f1 ff ff       	call   800eab <sys_page_map>
                        if (r < 0) return r;
  801d80:	83 c4 20             	add    $0x20,%esp
  801d83:	85 c0                	test   %eax,%eax
  801d85:	79 15                	jns    801d9c <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801d87:	50                   	push   %eax
  801d88:	68 d2 30 80 00       	push   $0x8030d2
  801d8d:	68 82 00 00 00       	push   $0x82
  801d92:	68 a9 30 80 00       	push   $0x8030a9
  801d97:	e8 63 e6 ff ff       	call   8003ff <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801d9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801da2:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801da8:	75 8f                	jne    801d39 <spawn+0x409>
  801daa:	e9 8d 00 00 00       	jmp    801e3c <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801daf:	50                   	push   %eax
  801db0:	68 e8 30 80 00       	push   $0x8030e8
  801db5:	68 85 00 00 00       	push   $0x85
  801dba:	68 a9 30 80 00       	push   $0x8030a9
  801dbf:	e8 3b e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	6a 02                	push   $0x2
  801dc9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dcf:	e8 5b f1 ff ff       	call   800f2f <sys_env_set_status>
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	79 25                	jns    801e00 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801ddb:	50                   	push   %eax
  801ddc:	68 02 31 80 00       	push   $0x803102
  801de1:	68 88 00 00 00       	push   $0x88
  801de6:	68 a9 30 80 00       	push   $0x8030a9
  801deb:	e8 0f e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801df0:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801df6:	eb 7d                	jmp    801e75 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801df8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801dfe:	eb 75                	jmp    801e75 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e00:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e06:	eb 6d                	jmp    801e75 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e08:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801e0d:	eb 66                	jmp    801e75 <spawn+0x545>
  801e0f:	89 c7                	mov    %eax,%edi
  801e11:	eb 06                	jmp    801e19 <spawn+0x4e9>
  801e13:	89 c7                	mov    %eax,%edi
  801e15:	eb 02                	jmp    801e19 <spawn+0x4e9>
  801e17:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e22:	e8 c2 ef ff ff       	call   800de9 <sys_env_destroy>
	close(fd);
  801e27:	83 c4 04             	add    $0x4,%esp
  801e2a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e30:	e8 6a f4 ff ff       	call   80129f <close>
	return r;
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	89 f8                	mov    %edi,%eax
  801e3a:	eb 39                	jmp    801e75 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e4c:	e8 20 f1 ff ff       	call   800f71 <sys_env_set_trapframe>
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	0f 89 68 ff ff ff    	jns    801dc4 <spawn+0x494>
  801e5c:	e9 4e ff ff ff       	jmp    801daf <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	68 00 00 40 00       	push   $0x400000
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 7d f0 ff ff       	call   800eed <sys_page_unmap>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e82:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e85:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e8a:	eb 03                	jmp    801e8f <spawnl+0x12>
		argc++;
  801e8c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e8f:	83 c2 04             	add    $0x4,%edx
  801e92:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e96:	75 f4                	jne    801e8c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e98:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e9f:	83 e2 f0             	and    $0xfffffff0,%edx
  801ea2:	29 d4                	sub    %edx,%esp
  801ea4:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ea8:	c1 ea 02             	shr    $0x2,%edx
  801eab:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801eb2:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb7:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ebe:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ec5:	00 
  801ec6:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecd:	eb 0a                	jmp    801ed9 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ecf:	83 c0 01             	add    $0x1,%eax
  801ed2:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ed6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ed9:	39 d0                	cmp    %edx,%eax
  801edb:	75 f2                	jne    801ecf <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801edd:	83 ec 08             	sub    $0x8,%esp
  801ee0:	56                   	push   %esi
  801ee1:	ff 75 08             	pushl  0x8(%ebp)
  801ee4:	e8 47 fa ff ff       	call   801930 <spawn>
}
  801ee9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    

00801ef0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ef6:	68 44 31 80 00       	push   $0x803144
  801efb:	ff 75 0c             	pushl  0xc(%ebp)
  801efe:	e8 5c eb ff ff       	call   800a5f <strcpy>
	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	53                   	push   %ebx
  801f0e:	83 ec 10             	sub    $0x10,%esp
  801f11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f14:	53                   	push   %ebx
  801f15:	e8 e4 08 00 00       	call   8027fe <pageref>
  801f1a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f1d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f22:	83 f8 01             	cmp    $0x1,%eax
  801f25:	75 10                	jne    801f37 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff 73 0c             	pushl  0xc(%ebx)
  801f2d:	e8 ca 02 00 00       	call   8021fc <nsipc_close>
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f37:	89 d0                	mov    %edx,%eax
  801f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f44:	6a 00                	push   $0x0
  801f46:	ff 75 10             	pushl  0x10(%ebp)
  801f49:	ff 75 0c             	pushl  0xc(%ebp)
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	ff 70 0c             	pushl  0xc(%eax)
  801f52:	e8 82 03 00 00       	call   8022d9 <nsipc_send>
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f5f:	6a 00                	push   $0x0
  801f61:	ff 75 10             	pushl  0x10(%ebp)
  801f64:	ff 75 0c             	pushl  0xc(%ebp)
  801f67:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6a:	ff 70 0c             	pushl  0xc(%eax)
  801f6d:	e8 fb 02 00 00       	call   80226d <nsipc_recv>
}
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f7a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f7d:	52                   	push   %edx
  801f7e:	50                   	push   %eax
  801f7f:	e8 ec f1 ff ff       	call   801170 <fd_lookup>
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 17                	js     801fa2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8e:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f94:	39 08                	cmp    %ecx,(%eax)
  801f96:	75 05                	jne    801f9d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f98:	8b 40 0c             	mov    0xc(%eax),%eax
  801f9b:	eb 05                	jmp    801fa2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f9d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    

00801fa4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	56                   	push   %esi
  801fa8:	53                   	push   %ebx
  801fa9:	83 ec 1c             	sub    $0x1c,%esp
  801fac:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb1:	50                   	push   %eax
  801fb2:	e8 6a f1 ff ff       	call   801121 <fd_alloc>
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 1b                	js     801fdb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fc0:	83 ec 04             	sub    $0x4,%esp
  801fc3:	68 07 04 00 00       	push   $0x407
  801fc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcb:	6a 00                	push   $0x0
  801fcd:	e8 96 ee ff ff       	call   800e68 <sys_page_alloc>
  801fd2:	89 c3                	mov    %eax,%ebx
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	79 10                	jns    801feb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	56                   	push   %esi
  801fdf:	e8 18 02 00 00       	call   8021fc <nsipc_close>
		return r;
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	89 d8                	mov    %ebx,%eax
  801fe9:	eb 24                	jmp    80200f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801feb:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff9:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802000:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  802003:	83 ec 0c             	sub    $0xc,%esp
  802006:	52                   	push   %edx
  802007:	e8 ee f0 ff ff       	call   8010fa <fd2num>
  80200c:	83 c4 10             	add    $0x10,%esp
}
  80200f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802012:	5b                   	pop    %ebx
  802013:	5e                   	pop    %esi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	e8 50 ff ff ff       	call   801f74 <fd2sockid>
		return r;
  802024:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802026:	85 c0                	test   %eax,%eax
  802028:	78 1f                	js     802049 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80202a:	83 ec 04             	sub    $0x4,%esp
  80202d:	ff 75 10             	pushl  0x10(%ebp)
  802030:	ff 75 0c             	pushl  0xc(%ebp)
  802033:	50                   	push   %eax
  802034:	e8 1c 01 00 00       	call   802155 <nsipc_accept>
  802039:	83 c4 10             	add    $0x10,%esp
		return r;
  80203c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 07                	js     802049 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802042:	e8 5d ff ff ff       	call   801fa4 <alloc_sockfd>
  802047:	89 c1                	mov    %eax,%ecx
}
  802049:	89 c8                	mov    %ecx,%eax
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802053:	8b 45 08             	mov    0x8(%ebp),%eax
  802056:	e8 19 ff ff ff       	call   801f74 <fd2sockid>
  80205b:	89 c2                	mov    %eax,%edx
  80205d:	85 d2                	test   %edx,%edx
  80205f:	78 12                	js     802073 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  802061:	83 ec 04             	sub    $0x4,%esp
  802064:	ff 75 10             	pushl  0x10(%ebp)
  802067:	ff 75 0c             	pushl  0xc(%ebp)
  80206a:	52                   	push   %edx
  80206b:	e8 35 01 00 00       	call   8021a5 <nsipc_bind>
  802070:	83 c4 10             	add    $0x10,%esp
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <shutdown>:

int
shutdown(int s, int how)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	e8 f1 fe ff ff       	call   801f74 <fd2sockid>
  802083:	89 c2                	mov    %eax,%edx
  802085:	85 d2                	test   %edx,%edx
  802087:	78 0f                	js     802098 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802089:	83 ec 08             	sub    $0x8,%esp
  80208c:	ff 75 0c             	pushl  0xc(%ebp)
  80208f:	52                   	push   %edx
  802090:	e8 45 01 00 00       	call   8021da <nsipc_shutdown>
  802095:	83 c4 10             	add    $0x10,%esp
}
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	e8 cc fe ff ff       	call   801f74 <fd2sockid>
  8020a8:	89 c2                	mov    %eax,%edx
  8020aa:	85 d2                	test   %edx,%edx
  8020ac:	78 12                	js     8020c0 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  8020ae:	83 ec 04             	sub    $0x4,%esp
  8020b1:	ff 75 10             	pushl  0x10(%ebp)
  8020b4:	ff 75 0c             	pushl  0xc(%ebp)
  8020b7:	52                   	push   %edx
  8020b8:	e8 59 01 00 00       	call   802216 <nsipc_connect>
  8020bd:	83 c4 10             	add    $0x10,%esp
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <listen>:

int
listen(int s, int backlog)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cb:	e8 a4 fe ff ff       	call   801f74 <fd2sockid>
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	85 d2                	test   %edx,%edx
  8020d4:	78 0f                	js     8020e5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8020d6:	83 ec 08             	sub    $0x8,%esp
  8020d9:	ff 75 0c             	pushl  0xc(%ebp)
  8020dc:	52                   	push   %edx
  8020dd:	e8 69 01 00 00       	call   80224b <nsipc_listen>
  8020e2:	83 c4 10             	add    $0x10,%esp
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020ed:	ff 75 10             	pushl  0x10(%ebp)
  8020f0:	ff 75 0c             	pushl  0xc(%ebp)
  8020f3:	ff 75 08             	pushl  0x8(%ebp)
  8020f6:	e8 3c 02 00 00       	call   802337 <nsipc_socket>
  8020fb:	89 c2                	mov    %eax,%edx
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 d2                	test   %edx,%edx
  802102:	78 05                	js     802109 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  802104:	e8 9b fe ff ff       	call   801fa4 <alloc_sockfd>
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	53                   	push   %ebx
  80210f:	83 ec 04             	sub    $0x4,%esp
  802112:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802114:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  80211b:	75 12                	jne    80212f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	6a 02                	push   $0x2
  802122:	e8 9f 06 00 00       	call   8027c6 <ipc_find_env>
  802127:	a3 04 60 80 00       	mov    %eax,0x806004
  80212c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80212f:	6a 07                	push   $0x7
  802131:	68 00 90 80 00       	push   $0x809000
  802136:	53                   	push   %ebx
  802137:	ff 35 04 60 80 00    	pushl  0x806004
  80213d:	e8 30 06 00 00       	call   802772 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802142:	83 c4 0c             	add    $0xc,%esp
  802145:	6a 00                	push   $0x0
  802147:	6a 00                	push   $0x0
  802149:	6a 00                	push   $0x0
  80214b:	e8 b9 05 00 00       	call   802709 <ipc_recv>
}
  802150:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
  80215a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80215d:	8b 45 08             	mov    0x8(%ebp),%eax
  802160:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802165:	8b 06                	mov    (%esi),%eax
  802167:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80216c:	b8 01 00 00 00       	mov    $0x1,%eax
  802171:	e8 95 ff ff ff       	call   80210b <nsipc>
  802176:	89 c3                	mov    %eax,%ebx
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 20                	js     80219c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80217c:	83 ec 04             	sub    $0x4,%esp
  80217f:	ff 35 10 90 80 00    	pushl  0x809010
  802185:	68 00 90 80 00       	push   $0x809000
  80218a:	ff 75 0c             	pushl  0xc(%ebp)
  80218d:	e8 5f ea ff ff       	call   800bf1 <memmove>
		*addrlen = ret->ret_addrlen;
  802192:	a1 10 90 80 00       	mov    0x809010,%eax
  802197:	89 06                	mov    %eax,(%esi)
  802199:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 08             	sub    $0x8,%esp
  8021ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021b7:	53                   	push   %ebx
  8021b8:	ff 75 0c             	pushl  0xc(%ebp)
  8021bb:	68 04 90 80 00       	push   $0x809004
  8021c0:	e8 2c ea ff ff       	call   800bf1 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021c5:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8021cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d0:	e8 36 ff ff ff       	call   80210b <nsipc>
}
  8021d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d8:	c9                   	leave  
  8021d9:	c3                   	ret    

008021da <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e3:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  8021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021eb:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  8021f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8021f5:	e8 11 ff ff ff       	call   80210b <nsipc>
}
  8021fa:	c9                   	leave  
  8021fb:	c3                   	ret    

008021fc <nsipc_close>:

int
nsipc_close(int s)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802202:	8b 45 08             	mov    0x8(%ebp),%eax
  802205:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  80220a:	b8 04 00 00 00       	mov    $0x4,%eax
  80220f:	e8 f7 fe ff ff       	call   80210b <nsipc>
}
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	53                   	push   %ebx
  80221a:	83 ec 08             	sub    $0x8,%esp
  80221d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802220:	8b 45 08             	mov    0x8(%ebp),%eax
  802223:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802228:	53                   	push   %ebx
  802229:	ff 75 0c             	pushl  0xc(%ebp)
  80222c:	68 04 90 80 00       	push   $0x809004
  802231:	e8 bb e9 ff ff       	call   800bf1 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802236:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  80223c:	b8 05 00 00 00       	mov    $0x5,%eax
  802241:	e8 c5 fe ff ff       	call   80210b <nsipc>
}
  802246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802249:	c9                   	leave  
  80224a:	c3                   	ret    

0080224b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802251:	8b 45 08             	mov    0x8(%ebp),%eax
  802254:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225c:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802261:	b8 06 00 00 00       	mov    $0x6,%eax
  802266:	e8 a0 fe ff ff       	call   80210b <nsipc>
}
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    

0080226d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	56                   	push   %esi
  802271:	53                   	push   %ebx
  802272:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802275:	8b 45 08             	mov    0x8(%ebp),%eax
  802278:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  80227d:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  802283:	8b 45 14             	mov    0x14(%ebp),%eax
  802286:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80228b:	b8 07 00 00 00       	mov    $0x7,%eax
  802290:	e8 76 fe ff ff       	call   80210b <nsipc>
  802295:	89 c3                	mov    %eax,%ebx
  802297:	85 c0                	test   %eax,%eax
  802299:	78 35                	js     8022d0 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80229b:	39 f0                	cmp    %esi,%eax
  80229d:	7f 07                	jg     8022a6 <nsipc_recv+0x39>
  80229f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022a4:	7e 16                	jle    8022bc <nsipc_recv+0x4f>
  8022a6:	68 50 31 80 00       	push   $0x803150
  8022ab:	68 63 30 80 00       	push   $0x803063
  8022b0:	6a 62                	push   $0x62
  8022b2:	68 65 31 80 00       	push   $0x803165
  8022b7:	e8 43 e1 ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022bc:	83 ec 04             	sub    $0x4,%esp
  8022bf:	50                   	push   %eax
  8022c0:	68 00 90 80 00       	push   $0x809000
  8022c5:	ff 75 0c             	pushl  0xc(%ebp)
  8022c8:	e8 24 e9 ff ff       	call   800bf1 <memmove>
  8022cd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	53                   	push   %ebx
  8022dd:	83 ec 04             	sub    $0x4,%esp
  8022e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e6:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  8022eb:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022f1:	7e 16                	jle    802309 <nsipc_send+0x30>
  8022f3:	68 71 31 80 00       	push   $0x803171
  8022f8:	68 63 30 80 00       	push   $0x803063
  8022fd:	6a 6d                	push   $0x6d
  8022ff:	68 65 31 80 00       	push   $0x803165
  802304:	e8 f6 e0 ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802309:	83 ec 04             	sub    $0x4,%esp
  80230c:	53                   	push   %ebx
  80230d:	ff 75 0c             	pushl  0xc(%ebp)
  802310:	68 0c 90 80 00       	push   $0x80900c
  802315:	e8 d7 e8 ff ff       	call   800bf1 <memmove>
	nsipcbuf.send.req_size = size;
  80231a:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802320:	8b 45 14             	mov    0x14(%ebp),%eax
  802323:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802328:	b8 08 00 00 00       	mov    $0x8,%eax
  80232d:	e8 d9 fd ff ff       	call   80210b <nsipc>
}
  802332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802335:	c9                   	leave  
  802336:	c3                   	ret    

00802337 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802337:	55                   	push   %ebp
  802338:	89 e5                	mov    %esp,%ebp
  80233a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80233d:	8b 45 08             	mov    0x8(%ebp),%eax
  802340:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802345:	8b 45 0c             	mov    0xc(%ebp),%eax
  802348:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  80234d:	8b 45 10             	mov    0x10(%ebp),%eax
  802350:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  802355:	b8 09 00 00 00       	mov    $0x9,%eax
  80235a:	e8 ac fd ff ff       	call   80210b <nsipc>
}
  80235f:	c9                   	leave  
  802360:	c3                   	ret    

00802361 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	56                   	push   %esi
  802365:	53                   	push   %ebx
  802366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802369:	83 ec 0c             	sub    $0xc,%esp
  80236c:	ff 75 08             	pushl  0x8(%ebp)
  80236f:	e8 96 ed ff ff       	call   80110a <fd2data>
  802374:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802376:	83 c4 08             	add    $0x8,%esp
  802379:	68 7d 31 80 00       	push   $0x80317d
  80237e:	53                   	push   %ebx
  80237f:	e8 db e6 ff ff       	call   800a5f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802384:	8b 56 04             	mov    0x4(%esi),%edx
  802387:	89 d0                	mov    %edx,%eax
  802389:	2b 06                	sub    (%esi),%eax
  80238b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802391:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802398:	00 00 00 
	stat->st_dev = &devpipe;
  80239b:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  8023a2:	57 80 00 
	return 0;
}
  8023a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5d                   	pop    %ebp
  8023b0:	c3                   	ret    

008023b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023b1:	55                   	push   %ebp
  8023b2:	89 e5                	mov    %esp,%ebp
  8023b4:	53                   	push   %ebx
  8023b5:	83 ec 0c             	sub    $0xc,%esp
  8023b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023bb:	53                   	push   %ebx
  8023bc:	6a 00                	push   $0x0
  8023be:	e8 2a eb ff ff       	call   800eed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023c3:	89 1c 24             	mov    %ebx,(%esp)
  8023c6:	e8 3f ed ff ff       	call   80110a <fd2data>
  8023cb:	83 c4 08             	add    $0x8,%esp
  8023ce:	50                   	push   %eax
  8023cf:	6a 00                	push   $0x0
  8023d1:	e8 17 eb ff ff       	call   800eed <sys_page_unmap>
}
  8023d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023d9:	c9                   	leave  
  8023da:	c3                   	ret    

008023db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	57                   	push   %edi
  8023df:	56                   	push   %esi
  8023e0:	53                   	push   %ebx
  8023e1:	83 ec 1c             	sub    $0x1c,%esp
  8023e4:	89 c6                	mov    %eax,%esi
  8023e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023e9:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  8023ee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023f1:	83 ec 0c             	sub    $0xc,%esp
  8023f4:	56                   	push   %esi
  8023f5:	e8 04 04 00 00       	call   8027fe <pageref>
  8023fa:	89 c7                	mov    %eax,%edi
  8023fc:	83 c4 04             	add    $0x4,%esp
  8023ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  802402:	e8 f7 03 00 00       	call   8027fe <pageref>
  802407:	83 c4 10             	add    $0x10,%esp
  80240a:	39 c7                	cmp    %eax,%edi
  80240c:	0f 94 c2             	sete   %dl
  80240f:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802412:	8b 0d b0 77 80 00    	mov    0x8077b0,%ecx
  802418:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80241b:	39 fb                	cmp    %edi,%ebx
  80241d:	74 19                	je     802438 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80241f:	84 d2                	test   %dl,%dl
  802421:	74 c6                	je     8023e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802423:	8b 51 58             	mov    0x58(%ecx),%edx
  802426:	50                   	push   %eax
  802427:	52                   	push   %edx
  802428:	53                   	push   %ebx
  802429:	68 84 31 80 00       	push   $0x803184
  80242e:	e8 a5 e0 ff ff       	call   8004d8 <cprintf>
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	eb b1                	jmp    8023e9 <_pipeisclosed+0xe>
	}
}
  802438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	5f                   	pop    %edi
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	57                   	push   %edi
  802444:	56                   	push   %esi
  802445:	53                   	push   %ebx
  802446:	83 ec 28             	sub    $0x28,%esp
  802449:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80244c:	56                   	push   %esi
  80244d:	e8 b8 ec ff ff       	call   80110a <fd2data>
  802452:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802454:	83 c4 10             	add    $0x10,%esp
  802457:	bf 00 00 00 00       	mov    $0x0,%edi
  80245c:	eb 4b                	jmp    8024a9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80245e:	89 da                	mov    %ebx,%edx
  802460:	89 f0                	mov    %esi,%eax
  802462:	e8 74 ff ff ff       	call   8023db <_pipeisclosed>
  802467:	85 c0                	test   %eax,%eax
  802469:	75 48                	jne    8024b3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80246b:	e8 d9 e9 ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802470:	8b 43 04             	mov    0x4(%ebx),%eax
  802473:	8b 0b                	mov    (%ebx),%ecx
  802475:	8d 51 20             	lea    0x20(%ecx),%edx
  802478:	39 d0                	cmp    %edx,%eax
  80247a:	73 e2                	jae    80245e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80247c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80247f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802483:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802486:	89 c2                	mov    %eax,%edx
  802488:	c1 fa 1f             	sar    $0x1f,%edx
  80248b:	89 d1                	mov    %edx,%ecx
  80248d:	c1 e9 1b             	shr    $0x1b,%ecx
  802490:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802493:	83 e2 1f             	and    $0x1f,%edx
  802496:	29 ca                	sub    %ecx,%edx
  802498:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80249c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024a0:	83 c0 01             	add    $0x1,%eax
  8024a3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024a6:	83 c7 01             	add    $0x1,%edi
  8024a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024ac:	75 c2                	jne    802470 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8024ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8024b1:	eb 05                	jmp    8024b8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8024b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024bb:	5b                   	pop    %ebx
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	57                   	push   %edi
  8024c4:	56                   	push   %esi
  8024c5:	53                   	push   %ebx
  8024c6:	83 ec 18             	sub    $0x18,%esp
  8024c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024cc:	57                   	push   %edi
  8024cd:	e8 38 ec ff ff       	call   80110a <fd2data>
  8024d2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024d4:	83 c4 10             	add    $0x10,%esp
  8024d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024dc:	eb 3d                	jmp    80251b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024de:	85 db                	test   %ebx,%ebx
  8024e0:	74 04                	je     8024e6 <devpipe_read+0x26>
				return i;
  8024e2:	89 d8                	mov    %ebx,%eax
  8024e4:	eb 44                	jmp    80252a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024e6:	89 f2                	mov    %esi,%edx
  8024e8:	89 f8                	mov    %edi,%eax
  8024ea:	e8 ec fe ff ff       	call   8023db <_pipeisclosed>
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	75 32                	jne    802525 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024f3:	e8 51 e9 ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024f8:	8b 06                	mov    (%esi),%eax
  8024fa:	3b 46 04             	cmp    0x4(%esi),%eax
  8024fd:	74 df                	je     8024de <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024ff:	99                   	cltd   
  802500:	c1 ea 1b             	shr    $0x1b,%edx
  802503:	01 d0                	add    %edx,%eax
  802505:	83 e0 1f             	and    $0x1f,%eax
  802508:	29 d0                	sub    %edx,%eax
  80250a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80250f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802512:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802515:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802518:	83 c3 01             	add    $0x1,%ebx
  80251b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80251e:	75 d8                	jne    8024f8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802520:	8b 45 10             	mov    0x10(%ebp),%eax
  802523:	eb 05                	jmp    80252a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802525:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80252a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    

00802532 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	56                   	push   %esi
  802536:	53                   	push   %ebx
  802537:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80253a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80253d:	50                   	push   %eax
  80253e:	e8 de eb ff ff       	call   801121 <fd_alloc>
  802543:	83 c4 10             	add    $0x10,%esp
  802546:	89 c2                	mov    %eax,%edx
  802548:	85 c0                	test   %eax,%eax
  80254a:	0f 88 2c 01 00 00    	js     80267c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802550:	83 ec 04             	sub    $0x4,%esp
  802553:	68 07 04 00 00       	push   $0x407
  802558:	ff 75 f4             	pushl  -0xc(%ebp)
  80255b:	6a 00                	push   $0x0
  80255d:	e8 06 e9 ff ff       	call   800e68 <sys_page_alloc>
  802562:	83 c4 10             	add    $0x10,%esp
  802565:	89 c2                	mov    %eax,%edx
  802567:	85 c0                	test   %eax,%eax
  802569:	0f 88 0d 01 00 00    	js     80267c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80256f:	83 ec 0c             	sub    $0xc,%esp
  802572:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802575:	50                   	push   %eax
  802576:	e8 a6 eb ff ff       	call   801121 <fd_alloc>
  80257b:	89 c3                	mov    %eax,%ebx
  80257d:	83 c4 10             	add    $0x10,%esp
  802580:	85 c0                	test   %eax,%eax
  802582:	0f 88 e2 00 00 00    	js     80266a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802588:	83 ec 04             	sub    $0x4,%esp
  80258b:	68 07 04 00 00       	push   $0x407
  802590:	ff 75 f0             	pushl  -0x10(%ebp)
  802593:	6a 00                	push   $0x0
  802595:	e8 ce e8 ff ff       	call   800e68 <sys_page_alloc>
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	83 c4 10             	add    $0x10,%esp
  80259f:	85 c0                	test   %eax,%eax
  8025a1:	0f 88 c3 00 00 00    	js     80266a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025a7:	83 ec 0c             	sub    $0xc,%esp
  8025aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8025ad:	e8 58 eb ff ff       	call   80110a <fd2data>
  8025b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025b4:	83 c4 0c             	add    $0xc,%esp
  8025b7:	68 07 04 00 00       	push   $0x407
  8025bc:	50                   	push   %eax
  8025bd:	6a 00                	push   $0x0
  8025bf:	e8 a4 e8 ff ff       	call   800e68 <sys_page_alloc>
  8025c4:	89 c3                	mov    %eax,%ebx
  8025c6:	83 c4 10             	add    $0x10,%esp
  8025c9:	85 c0                	test   %eax,%eax
  8025cb:	0f 88 89 00 00 00    	js     80265a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025d1:	83 ec 0c             	sub    $0xc,%esp
  8025d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8025d7:	e8 2e eb ff ff       	call   80110a <fd2data>
  8025dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025e3:	50                   	push   %eax
  8025e4:	6a 00                	push   $0x0
  8025e6:	56                   	push   %esi
  8025e7:	6a 00                	push   $0x0
  8025e9:	e8 bd e8 ff ff       	call   800eab <sys_page_map>
  8025ee:	89 c3                	mov    %eax,%ebx
  8025f0:	83 c4 20             	add    $0x20,%esp
  8025f3:	85 c0                	test   %eax,%eax
  8025f5:	78 55                	js     80264c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025f7:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  8025fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802600:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802605:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80260c:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802615:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80261a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802621:	83 ec 0c             	sub    $0xc,%esp
  802624:	ff 75 f4             	pushl  -0xc(%ebp)
  802627:	e8 ce ea ff ff       	call   8010fa <fd2num>
  80262c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802631:	83 c4 04             	add    $0x4,%esp
  802634:	ff 75 f0             	pushl  -0x10(%ebp)
  802637:	e8 be ea ff ff       	call   8010fa <fd2num>
  80263c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80263f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802642:	83 c4 10             	add    $0x10,%esp
  802645:	ba 00 00 00 00       	mov    $0x0,%edx
  80264a:	eb 30                	jmp    80267c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80264c:	83 ec 08             	sub    $0x8,%esp
  80264f:	56                   	push   %esi
  802650:	6a 00                	push   $0x0
  802652:	e8 96 e8 ff ff       	call   800eed <sys_page_unmap>
  802657:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80265a:	83 ec 08             	sub    $0x8,%esp
  80265d:	ff 75 f0             	pushl  -0x10(%ebp)
  802660:	6a 00                	push   $0x0
  802662:	e8 86 e8 ff ff       	call   800eed <sys_page_unmap>
  802667:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80266a:	83 ec 08             	sub    $0x8,%esp
  80266d:	ff 75 f4             	pushl  -0xc(%ebp)
  802670:	6a 00                	push   $0x0
  802672:	e8 76 e8 ff ff       	call   800eed <sys_page_unmap>
  802677:	83 c4 10             	add    $0x10,%esp
  80267a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80267c:	89 d0                	mov    %edx,%eax
  80267e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802681:	5b                   	pop    %ebx
  802682:	5e                   	pop    %esi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    

00802685 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802685:	55                   	push   %ebp
  802686:	89 e5                	mov    %esp,%ebp
  802688:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80268b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80268e:	50                   	push   %eax
  80268f:	ff 75 08             	pushl  0x8(%ebp)
  802692:	e8 d9 ea ff ff       	call   801170 <fd_lookup>
  802697:	89 c2                	mov    %eax,%edx
  802699:	83 c4 10             	add    $0x10,%esp
  80269c:	85 d2                	test   %edx,%edx
  80269e:	78 18                	js     8026b8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026a0:	83 ec 0c             	sub    $0xc,%esp
  8026a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8026a6:	e8 5f ea ff ff       	call   80110a <fd2data>
	return _pipeisclosed(fd, p);
  8026ab:	89 c2                	mov    %eax,%edx
  8026ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b0:	e8 26 fd ff ff       	call   8023db <_pipeisclosed>
  8026b5:	83 c4 10             	add    $0x10,%esp
}
  8026b8:	c9                   	leave  
  8026b9:	c3                   	ret    

008026ba <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026ba:	55                   	push   %ebp
  8026bb:	89 e5                	mov    %esp,%ebp
  8026bd:	56                   	push   %esi
  8026be:	53                   	push   %ebx
  8026bf:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026c2:	85 f6                	test   %esi,%esi
  8026c4:	75 16                	jne    8026dc <wait+0x22>
  8026c6:	68 9c 31 80 00       	push   $0x80319c
  8026cb:	68 63 30 80 00       	push   $0x803063
  8026d0:	6a 09                	push   $0x9
  8026d2:	68 a7 31 80 00       	push   $0x8031a7
  8026d7:	e8 23 dd ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8026dc:	89 f3                	mov    %esi,%ebx
  8026de:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026e4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026e7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026ed:	eb 05                	jmp    8026f4 <wait+0x3a>
		sys_yield();
  8026ef:	e8 55 e7 ff ff       	call   800e49 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026f4:	8b 43 48             	mov    0x48(%ebx),%eax
  8026f7:	39 f0                	cmp    %esi,%eax
  8026f9:	75 07                	jne    802702 <wait+0x48>
  8026fb:	8b 43 54             	mov    0x54(%ebx),%eax
  8026fe:	85 c0                	test   %eax,%eax
  802700:	75 ed                	jne    8026ef <wait+0x35>
		sys_yield();
}
  802702:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802705:	5b                   	pop    %ebx
  802706:	5e                   	pop    %esi
  802707:	5d                   	pop    %ebp
  802708:	c3                   	ret    

00802709 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802709:	55                   	push   %ebp
  80270a:	89 e5                	mov    %esp,%ebp
  80270c:	56                   	push   %esi
  80270d:	53                   	push   %ebx
  80270e:	8b 75 08             	mov    0x8(%ebp),%esi
  802711:	8b 45 0c             	mov    0xc(%ebp),%eax
  802714:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802717:	85 c0                	test   %eax,%eax
  802719:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80271e:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802721:	83 ec 0c             	sub    $0xc,%esp
  802724:	50                   	push   %eax
  802725:	e8 ee e8 ff ff       	call   801018 <sys_ipc_recv>
  80272a:	83 c4 10             	add    $0x10,%esp
  80272d:	85 c0                	test   %eax,%eax
  80272f:	79 16                	jns    802747 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802731:	85 f6                	test   %esi,%esi
  802733:	74 06                	je     80273b <ipc_recv+0x32>
  802735:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80273b:	85 db                	test   %ebx,%ebx
  80273d:	74 2c                	je     80276b <ipc_recv+0x62>
  80273f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802745:	eb 24                	jmp    80276b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802747:	85 f6                	test   %esi,%esi
  802749:	74 0a                	je     802755 <ipc_recv+0x4c>
  80274b:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  802750:	8b 40 74             	mov    0x74(%eax),%eax
  802753:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802755:	85 db                	test   %ebx,%ebx
  802757:	74 0a                	je     802763 <ipc_recv+0x5a>
  802759:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  80275e:	8b 40 78             	mov    0x78(%eax),%eax
  802761:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802763:	a1 b0 77 80 00       	mov    0x8077b0,%eax
  802768:	8b 40 70             	mov    0x70(%eax),%eax
}
  80276b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80276e:	5b                   	pop    %ebx
  80276f:	5e                   	pop    %esi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    

00802772 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	57                   	push   %edi
  802776:	56                   	push   %esi
  802777:	53                   	push   %ebx
  802778:	83 ec 0c             	sub    $0xc,%esp
  80277b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80277e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802781:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802784:	85 db                	test   %ebx,%ebx
  802786:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80278b:	0f 44 d8             	cmove  %eax,%ebx
  80278e:	eb 1c                	jmp    8027ac <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802790:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802793:	74 12                	je     8027a7 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802795:	50                   	push   %eax
  802796:	68 b2 31 80 00       	push   $0x8031b2
  80279b:	6a 39                	push   $0x39
  80279d:	68 cd 31 80 00       	push   $0x8031cd
  8027a2:	e8 58 dc ff ff       	call   8003ff <_panic>
                 sys_yield();
  8027a7:	e8 9d e6 ff ff       	call   800e49 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8027ac:	ff 75 14             	pushl  0x14(%ebp)
  8027af:	53                   	push   %ebx
  8027b0:	56                   	push   %esi
  8027b1:	57                   	push   %edi
  8027b2:	e8 3e e8 ff ff       	call   800ff5 <sys_ipc_try_send>
  8027b7:	83 c4 10             	add    $0x10,%esp
  8027ba:	85 c0                	test   %eax,%eax
  8027bc:	78 d2                	js     802790 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8027be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c1:	5b                   	pop    %ebx
  8027c2:	5e                   	pop    %esi
  8027c3:	5f                   	pop    %edi
  8027c4:	5d                   	pop    %ebp
  8027c5:	c3                   	ret    

008027c6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027c6:	55                   	push   %ebp
  8027c7:	89 e5                	mov    %esp,%ebp
  8027c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027da:	8b 52 50             	mov    0x50(%edx),%edx
  8027dd:	39 ca                	cmp    %ecx,%edx
  8027df:	75 0d                	jne    8027ee <ipc_find_env+0x28>
			return envs[i].env_id;
  8027e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027e4:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8027e9:	8b 40 08             	mov    0x8(%eax),%eax
  8027ec:	eb 0e                	jmp    8027fc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027ee:	83 c0 01             	add    $0x1,%eax
  8027f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027f6:	75 d9                	jne    8027d1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027f8:	66 b8 00 00          	mov    $0x0,%ax
}
  8027fc:	5d                   	pop    %ebp
  8027fd:	c3                   	ret    

008027fe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027fe:	55                   	push   %ebp
  8027ff:	89 e5                	mov    %esp,%ebp
  802801:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802804:	89 d0                	mov    %edx,%eax
  802806:	c1 e8 16             	shr    $0x16,%eax
  802809:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802810:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802815:	f6 c1 01             	test   $0x1,%cl
  802818:	74 1d                	je     802837 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80281a:	c1 ea 0c             	shr    $0xc,%edx
  80281d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802824:	f6 c2 01             	test   $0x1,%dl
  802827:	74 0e                	je     802837 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802829:	c1 ea 0c             	shr    $0xc,%edx
  80282c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802833:	ef 
  802834:	0f b7 c0             	movzwl %ax,%eax
}
  802837:	5d                   	pop    %ebp
  802838:	c3                   	ret    
  802839:	66 90                	xchg   %ax,%ax
  80283b:	66 90                	xchg   %ax,%ax
  80283d:	66 90                	xchg   %ax,%ax
  80283f:	90                   	nop

00802840 <__udivdi3>:
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	83 ec 10             	sub    $0x10,%esp
  802846:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80284a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80284e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802852:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802856:	85 d2                	test   %edx,%edx
  802858:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80285c:	89 34 24             	mov    %esi,(%esp)
  80285f:	89 c8                	mov    %ecx,%eax
  802861:	75 35                	jne    802898 <__udivdi3+0x58>
  802863:	39 f1                	cmp    %esi,%ecx
  802865:	0f 87 bd 00 00 00    	ja     802928 <__udivdi3+0xe8>
  80286b:	85 c9                	test   %ecx,%ecx
  80286d:	89 cd                	mov    %ecx,%ebp
  80286f:	75 0b                	jne    80287c <__udivdi3+0x3c>
  802871:	b8 01 00 00 00       	mov    $0x1,%eax
  802876:	31 d2                	xor    %edx,%edx
  802878:	f7 f1                	div    %ecx
  80287a:	89 c5                	mov    %eax,%ebp
  80287c:	89 f0                	mov    %esi,%eax
  80287e:	31 d2                	xor    %edx,%edx
  802880:	f7 f5                	div    %ebp
  802882:	89 c6                	mov    %eax,%esi
  802884:	89 f8                	mov    %edi,%eax
  802886:	f7 f5                	div    %ebp
  802888:	89 f2                	mov    %esi,%edx
  80288a:	83 c4 10             	add    $0x10,%esp
  80288d:	5e                   	pop    %esi
  80288e:	5f                   	pop    %edi
  80288f:	5d                   	pop    %ebp
  802890:	c3                   	ret    
  802891:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802898:	3b 14 24             	cmp    (%esp),%edx
  80289b:	77 7b                	ja     802918 <__udivdi3+0xd8>
  80289d:	0f bd f2             	bsr    %edx,%esi
  8028a0:	83 f6 1f             	xor    $0x1f,%esi
  8028a3:	0f 84 97 00 00 00    	je     802940 <__udivdi3+0x100>
  8028a9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8028ae:	89 d7                	mov    %edx,%edi
  8028b0:	89 f1                	mov    %esi,%ecx
  8028b2:	29 f5                	sub    %esi,%ebp
  8028b4:	d3 e7                	shl    %cl,%edi
  8028b6:	89 c2                	mov    %eax,%edx
  8028b8:	89 e9                	mov    %ebp,%ecx
  8028ba:	d3 ea                	shr    %cl,%edx
  8028bc:	89 f1                	mov    %esi,%ecx
  8028be:	09 fa                	or     %edi,%edx
  8028c0:	8b 3c 24             	mov    (%esp),%edi
  8028c3:	d3 e0                	shl    %cl,%eax
  8028c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028cf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028d3:	89 fa                	mov    %edi,%edx
  8028d5:	d3 ea                	shr    %cl,%edx
  8028d7:	89 f1                	mov    %esi,%ecx
  8028d9:	d3 e7                	shl    %cl,%edi
  8028db:	89 e9                	mov    %ebp,%ecx
  8028dd:	d3 e8                	shr    %cl,%eax
  8028df:	09 c7                	or     %eax,%edi
  8028e1:	89 f8                	mov    %edi,%eax
  8028e3:	f7 74 24 08          	divl   0x8(%esp)
  8028e7:	89 d5                	mov    %edx,%ebp
  8028e9:	89 c7                	mov    %eax,%edi
  8028eb:	f7 64 24 0c          	mull   0xc(%esp)
  8028ef:	39 d5                	cmp    %edx,%ebp
  8028f1:	89 14 24             	mov    %edx,(%esp)
  8028f4:	72 11                	jb     802907 <__udivdi3+0xc7>
  8028f6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028fa:	89 f1                	mov    %esi,%ecx
  8028fc:	d3 e2                	shl    %cl,%edx
  8028fe:	39 c2                	cmp    %eax,%edx
  802900:	73 5e                	jae    802960 <__udivdi3+0x120>
  802902:	3b 2c 24             	cmp    (%esp),%ebp
  802905:	75 59                	jne    802960 <__udivdi3+0x120>
  802907:	8d 47 ff             	lea    -0x1(%edi),%eax
  80290a:	31 f6                	xor    %esi,%esi
  80290c:	89 f2                	mov    %esi,%edx
  80290e:	83 c4 10             	add    $0x10,%esp
  802911:	5e                   	pop    %esi
  802912:	5f                   	pop    %edi
  802913:	5d                   	pop    %ebp
  802914:	c3                   	ret    
  802915:	8d 76 00             	lea    0x0(%esi),%esi
  802918:	31 f6                	xor    %esi,%esi
  80291a:	31 c0                	xor    %eax,%eax
  80291c:	89 f2                	mov    %esi,%edx
  80291e:	83 c4 10             	add    $0x10,%esp
  802921:	5e                   	pop    %esi
  802922:	5f                   	pop    %edi
  802923:	5d                   	pop    %ebp
  802924:	c3                   	ret    
  802925:	8d 76 00             	lea    0x0(%esi),%esi
  802928:	89 f2                	mov    %esi,%edx
  80292a:	31 f6                	xor    %esi,%esi
  80292c:	89 f8                	mov    %edi,%eax
  80292e:	f7 f1                	div    %ecx
  802930:	89 f2                	mov    %esi,%edx
  802932:	83 c4 10             	add    $0x10,%esp
  802935:	5e                   	pop    %esi
  802936:	5f                   	pop    %edi
  802937:	5d                   	pop    %ebp
  802938:	c3                   	ret    
  802939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802940:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802944:	76 0b                	jbe    802951 <__udivdi3+0x111>
  802946:	31 c0                	xor    %eax,%eax
  802948:	3b 14 24             	cmp    (%esp),%edx
  80294b:	0f 83 37 ff ff ff    	jae    802888 <__udivdi3+0x48>
  802951:	b8 01 00 00 00       	mov    $0x1,%eax
  802956:	e9 2d ff ff ff       	jmp    802888 <__udivdi3+0x48>
  80295b:	90                   	nop
  80295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802960:	89 f8                	mov    %edi,%eax
  802962:	31 f6                	xor    %esi,%esi
  802964:	e9 1f ff ff ff       	jmp    802888 <__udivdi3+0x48>
  802969:	66 90                	xchg   %ax,%ax
  80296b:	66 90                	xchg   %ax,%ax
  80296d:	66 90                	xchg   %ax,%ax
  80296f:	90                   	nop

00802970 <__umoddi3>:
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	83 ec 20             	sub    $0x20,%esp
  802976:	8b 44 24 34          	mov    0x34(%esp),%eax
  80297a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80297e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802982:	89 c6                	mov    %eax,%esi
  802984:	89 44 24 10          	mov    %eax,0x10(%esp)
  802988:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80298c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802990:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802994:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802998:	89 74 24 18          	mov    %esi,0x18(%esp)
  80299c:	85 c0                	test   %eax,%eax
  80299e:	89 c2                	mov    %eax,%edx
  8029a0:	75 1e                	jne    8029c0 <__umoddi3+0x50>
  8029a2:	39 f7                	cmp    %esi,%edi
  8029a4:	76 52                	jbe    8029f8 <__umoddi3+0x88>
  8029a6:	89 c8                	mov    %ecx,%eax
  8029a8:	89 f2                	mov    %esi,%edx
  8029aa:	f7 f7                	div    %edi
  8029ac:	89 d0                	mov    %edx,%eax
  8029ae:	31 d2                	xor    %edx,%edx
  8029b0:	83 c4 20             	add    $0x20,%esp
  8029b3:	5e                   	pop    %esi
  8029b4:	5f                   	pop    %edi
  8029b5:	5d                   	pop    %ebp
  8029b6:	c3                   	ret    
  8029b7:	89 f6                	mov    %esi,%esi
  8029b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8029c0:	39 f0                	cmp    %esi,%eax
  8029c2:	77 5c                	ja     802a20 <__umoddi3+0xb0>
  8029c4:	0f bd e8             	bsr    %eax,%ebp
  8029c7:	83 f5 1f             	xor    $0x1f,%ebp
  8029ca:	75 64                	jne    802a30 <__umoddi3+0xc0>
  8029cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8029d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8029d4:	0f 86 f6 00 00 00    	jbe    802ad0 <__umoddi3+0x160>
  8029da:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8029de:	0f 82 ec 00 00 00    	jb     802ad0 <__umoddi3+0x160>
  8029e4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029e8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8029ec:	83 c4 20             	add    $0x20,%esp
  8029ef:	5e                   	pop    %esi
  8029f0:	5f                   	pop    %edi
  8029f1:	5d                   	pop    %ebp
  8029f2:	c3                   	ret    
  8029f3:	90                   	nop
  8029f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029f8:	85 ff                	test   %edi,%edi
  8029fa:	89 fd                	mov    %edi,%ebp
  8029fc:	75 0b                	jne    802a09 <__umoddi3+0x99>
  8029fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802a03:	31 d2                	xor    %edx,%edx
  802a05:	f7 f7                	div    %edi
  802a07:	89 c5                	mov    %eax,%ebp
  802a09:	8b 44 24 10          	mov    0x10(%esp),%eax
  802a0d:	31 d2                	xor    %edx,%edx
  802a0f:	f7 f5                	div    %ebp
  802a11:	89 c8                	mov    %ecx,%eax
  802a13:	f7 f5                	div    %ebp
  802a15:	eb 95                	jmp    8029ac <__umoddi3+0x3c>
  802a17:	89 f6                	mov    %esi,%esi
  802a19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802a20:	89 c8                	mov    %ecx,%eax
  802a22:	89 f2                	mov    %esi,%edx
  802a24:	83 c4 20             	add    $0x20,%esp
  802a27:	5e                   	pop    %esi
  802a28:	5f                   	pop    %edi
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    
  802a2b:	90                   	nop
  802a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a30:	b8 20 00 00 00       	mov    $0x20,%eax
  802a35:	89 e9                	mov    %ebp,%ecx
  802a37:	29 e8                	sub    %ebp,%eax
  802a39:	d3 e2                	shl    %cl,%edx
  802a3b:	89 c7                	mov    %eax,%edi
  802a3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802a41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a45:	89 f9                	mov    %edi,%ecx
  802a47:	d3 e8                	shr    %cl,%eax
  802a49:	89 c1                	mov    %eax,%ecx
  802a4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a4f:	09 d1                	or     %edx,%ecx
  802a51:	89 fa                	mov    %edi,%edx
  802a53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802a57:	89 e9                	mov    %ebp,%ecx
  802a59:	d3 e0                	shl    %cl,%eax
  802a5b:	89 f9                	mov    %edi,%ecx
  802a5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a61:	89 f0                	mov    %esi,%eax
  802a63:	d3 e8                	shr    %cl,%eax
  802a65:	89 e9                	mov    %ebp,%ecx
  802a67:	89 c7                	mov    %eax,%edi
  802a69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a6d:	d3 e6                	shl    %cl,%esi
  802a6f:	89 d1                	mov    %edx,%ecx
  802a71:	89 fa                	mov    %edi,%edx
  802a73:	d3 e8                	shr    %cl,%eax
  802a75:	89 e9                	mov    %ebp,%ecx
  802a77:	09 f0                	or     %esi,%eax
  802a79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  802a7d:	f7 74 24 10          	divl   0x10(%esp)
  802a81:	d3 e6                	shl    %cl,%esi
  802a83:	89 d1                	mov    %edx,%ecx
  802a85:	f7 64 24 0c          	mull   0xc(%esp)
  802a89:	39 d1                	cmp    %edx,%ecx
  802a8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  802a8f:	89 d7                	mov    %edx,%edi
  802a91:	89 c6                	mov    %eax,%esi
  802a93:	72 0a                	jb     802a9f <__umoddi3+0x12f>
  802a95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802a99:	73 10                	jae    802aab <__umoddi3+0x13b>
  802a9b:	39 d1                	cmp    %edx,%ecx
  802a9d:	75 0c                	jne    802aab <__umoddi3+0x13b>
  802a9f:	89 d7                	mov    %edx,%edi
  802aa1:	89 c6                	mov    %eax,%esi
  802aa3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802aa7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802aab:	89 ca                	mov    %ecx,%edx
  802aad:	89 e9                	mov    %ebp,%ecx
  802aaf:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ab3:	29 f0                	sub    %esi,%eax
  802ab5:	19 fa                	sbb    %edi,%edx
  802ab7:	d3 e8                	shr    %cl,%eax
  802ab9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802abe:	89 d7                	mov    %edx,%edi
  802ac0:	d3 e7                	shl    %cl,%edi
  802ac2:	89 e9                	mov    %ebp,%ecx
  802ac4:	09 f8                	or     %edi,%eax
  802ac6:	d3 ea                	shr    %cl,%edx
  802ac8:	83 c4 20             	add    $0x20,%esp
  802acb:	5e                   	pop    %esi
  802acc:	5f                   	pop    %edi
  802acd:	5d                   	pop    %ebp
  802ace:	c3                   	ret    
  802acf:	90                   	nop
  802ad0:	8b 74 24 10          	mov    0x10(%esp),%esi
  802ad4:	29 f9                	sub    %edi,%ecx
  802ad6:	19 c6                	sbb    %eax,%esi
  802ad8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802adc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802ae0:	e9 ff fe ff ff       	jmp    8029e4 <__umoddi3+0x74>
