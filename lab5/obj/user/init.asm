
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
  80006d:	68 00 26 80 00       	push   $0x802600
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c8 26 80 00       	push   $0x8026c8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 0f 26 80 00       	push   $0x80260f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 40 50 80 00       	push   $0x805040
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 04 27 80 00       	push   $0x802704
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 26 26 80 00       	push   $0x802626
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 3c 26 80 00       	push   $0x80263c
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
  80011e:	68 48 26 80 00       	push   $0x802648
  800123:	56                   	push   %esi
  800124:	e8 56 09 00 00       	call   800a7f <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 4a 09 00 00       	call   800a7f <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 49 26 80 00       	push   $0x802649
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
  800158:	68 4b 26 80 00       	push   $0x80264b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 7f 10 00 00       	call   8011f9 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 61 26 80 00       	push   $0x802661
  80018c:	6a 37                	push   $0x37
  80018e:	68 6e 26 80 00       	push   $0x80266e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 7a 26 80 00       	push   $0x80267a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 6e 26 80 00       	push   $0x80266e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 91 10 00 00       	call   80124b <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 94 26 80 00       	push   $0x802694
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 6e 26 80 00       	push   $0x80266e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 9c 26 80 00       	push   $0x80269c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 b0 26 80 00       	push   $0x8026b0
  8001ea:	68 af 26 80 00       	push   $0x8026af
  8001ef:	e8 e3 1b 00 00       	call   801dd7 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 b3 26 80 00       	push   $0x8026b3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 8c 1f 00 00       	call   8021a3 <wait>
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
  80022c:	68 33 27 80 00       	push   $0x802733
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
  8002fc:	e8 38 10 00 00       	call   801339 <read>
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
  800326:	e8 a4 0d 00 00       	call   8010cf <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
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
  80034f:	e8 2c 0d 00 00       	call   801080 <fd_alloc>
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
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 c3 0c 00 00       	call   801059 <fd2num>
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
  8003bc:	a3 b0 67 80 00       	mov    %eax,0x8067b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

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
  8003eb:	e8 36 0e 00 00       	call   801226 <close_all>
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
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 18 0a 00 00       	call   800e2a <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 4c 27 80 00       	push   $0x80274c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
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
  80053b:	e8 f0 1d 00 00       	call   802330 <__udivdi3>
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
  800579:	e8 e2 1e 00 00       	call   802460 <__umoddi3>
  80057e:	83 c4 14             	add    $0x14,%esp
  800581:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
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
  80067d:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
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
  800741:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800748:	85 d2                	test   %edx,%edx
  80074a:	75 18                	jne    800764 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80074c:	50                   	push   %eax
  80074d:	68 87 27 80 00       	push   $0x802787
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
  800765:	68 71 2b 80 00       	push   $0x802b71
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
  800792:	ba 80 27 80 00       	mov    $0x802780,%edx
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
  800e11:	68 9f 2a 80 00       	push   $0x802a9f
  800e16:	6a 23                	push   $0x23
  800e18:	68 bc 2a 80 00       	push   $0x802abc
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
  800e92:	68 9f 2a 80 00       	push   $0x802a9f
  800e97:	6a 23                	push   $0x23
  800e99:	68 bc 2a 80 00       	push   $0x802abc
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
  800ed4:	68 9f 2a 80 00       	push   $0x802a9f
  800ed9:	6a 23                	push   $0x23
  800edb:	68 bc 2a 80 00       	push   $0x802abc
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
  800f16:	68 9f 2a 80 00       	push   $0x802a9f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 bc 2a 80 00       	push   $0x802abc
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
  800f58:	68 9f 2a 80 00       	push   $0x802a9f
  800f5d:	6a 23                	push   $0x23
  800f5f:	68 bc 2a 80 00       	push   $0x802abc
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
  800f9a:	68 9f 2a 80 00       	push   $0x802a9f
  800f9f:	6a 23                	push   $0x23
  800fa1:	68 bc 2a 80 00       	push   $0x802abc
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
  800fdc:	68 9f 2a 80 00       	push   $0x802a9f
  800fe1:	6a 23                	push   $0x23
  800fe3:	68 bc 2a 80 00       	push   $0x802abc
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
  801040:	68 9f 2a 80 00       	push   $0x802a9f
  801045:	6a 23                	push   $0x23
  801047:	68 bc 2a 80 00       	push   $0x802abc
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

00801059 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	05 00 00 00 30       	add    $0x30000000,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
}
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801079:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	c1 ea 16             	shr    $0x16,%edx
  801090:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	74 11                	je     8010ad <fd_alloc+0x2d>
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	c1 ea 0c             	shr    $0xc,%edx
  8010a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a8:	f6 c2 01             	test   $0x1,%dl
  8010ab:	75 09                	jne    8010b6 <fd_alloc+0x36>
			*fd_store = fd;
  8010ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010af:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b4:	eb 17                	jmp    8010cd <fd_alloc+0x4d>
  8010b6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c0:	75 c9                	jne    80108b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d5:	83 f8 1f             	cmp    $0x1f,%eax
  8010d8:	77 36                	ja     801110 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010da:	c1 e0 0c             	shl    $0xc,%eax
  8010dd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	c1 ea 16             	shr    $0x16,%edx
  8010e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ee:	f6 c2 01             	test   $0x1,%dl
  8010f1:	74 24                	je     801117 <fd_lookup+0x48>
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	c1 ea 0c             	shr    $0xc,%edx
  8010f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 1a                	je     80111e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 02                	mov    %eax,(%edx)
	return 0;
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
  80110e:	eb 13                	jmp    801123 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb 0c                	jmp    801123 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb 05                	jmp    801123 <fd_lookup+0x54>
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801133:	eb 13                	jmp    801148 <dev_lookup+0x23>
  801135:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801138:	39 08                	cmp    %ecx,(%eax)
  80113a:	75 0c                	jne    801148 <dev_lookup+0x23>
			*dev = devtab[i];
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	eb 2e                	jmp    801176 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801148:	8b 02                	mov    (%edx),%eax
  80114a:	85 c0                	test   %eax,%eax
  80114c:	75 e7                	jne    801135 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114e:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801153:	8b 40 48             	mov    0x48(%eax),%eax
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	51                   	push   %ecx
  80115a:	50                   	push   %eax
  80115b:	68 cc 2a 80 00       	push   $0x802acc
  801160:	e8 73 f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  801165:	8b 45 0c             	mov    0xc(%ebp),%eax
  801168:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 10             	sub    $0x10,%esp
  801180:	8b 75 08             	mov    0x8(%ebp),%esi
  801183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801190:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801193:	50                   	push   %eax
  801194:	e8 36 ff ff ff       	call   8010cf <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 05                	js     8011a5 <fd_close+0x2d>
	    || fd != fd2)
  8011a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a3:	74 0c                	je     8011b1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a5:	84 db                	test   %bl,%bl
  8011a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ac:	0f 44 c2             	cmove  %edx,%eax
  8011af:	eb 41                	jmp    8011f2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 36                	pushl  (%esi)
  8011ba:	e8 66 ff ff ff       	call   801125 <dev_lookup>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 1a                	js     8011e2 <fd_close+0x6a>
		if (dev->dev_close)
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 0b                	je     8011e2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	56                   	push   %esi
  8011db:	ff d0                	call   *%eax
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	56                   	push   %esi
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 00 fd ff ff       	call   800eed <sys_page_unmap>
	return r;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	89 d8                	mov    %ebx,%eax
}
  8011f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	ff 75 08             	pushl  0x8(%ebp)
  801206:	e8 c4 fe ff ff       	call   8010cf <fd_lookup>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 d2                	test   %edx,%edx
  801212:	78 10                	js     801224 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	6a 01                	push   $0x1
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 57 ff ff ff       	call   801178 <fd_close>
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	53                   	push   %ebx
  801236:	e8 be ff ff ff       	call   8011f9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123b:	83 c3 01             	add    $0x1,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	83 fb 20             	cmp    $0x20,%ebx
  801244:	75 ec                	jne    801232 <close_all+0xc>
		close(i);
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 2c             	sub    $0x2c,%esp
  801254:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801257:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 6c fe ff ff       	call   8010cf <fd_lookup>
  801263:	89 c2                	mov    %eax,%edx
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 d2                	test   %edx,%edx
  80126a:	0f 88 c1 00 00 00    	js     801331 <dup+0xe6>
		return r;
	close(newfdnum);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	56                   	push   %esi
  801274:	e8 80 ff ff ff       	call   8011f9 <close>

	newfd = INDEX2FD(newfdnum);
  801279:	89 f3                	mov    %esi,%ebx
  80127b:	c1 e3 0c             	shl    $0xc,%ebx
  80127e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801284:	83 c4 04             	add    $0x4,%esp
  801287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80128a:	e8 da fd ff ff       	call   801069 <fd2data>
  80128f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801291:	89 1c 24             	mov    %ebx,(%esp)
  801294:	e8 d0 fd ff ff       	call   801069 <fd2data>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	c1 e8 16             	shr    $0x16,%eax
  8012a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ab:	a8 01                	test   $0x1,%al
  8012ad:	74 37                	je     8012e6 <dup+0x9b>
  8012af:	89 f8                	mov    %edi,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 26                	je     8012e6 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	57                   	push   %edi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 ce fb ff ff       	call   800eab <sys_page_map>
  8012dd:	89 c7                	mov    %eax,%edi
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 2e                	js     801314 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	c1 e8 0c             	shr    $0xc,%eax
  8012ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fd:	50                   	push   %eax
  8012fe:	53                   	push   %ebx
  8012ff:	6a 00                	push   $0x0
  801301:	52                   	push   %edx
  801302:	6a 00                	push   $0x0
  801304:	e8 a2 fb ff ff       	call   800eab <sys_page_map>
  801309:	89 c7                	mov    %eax,%edi
  80130b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801310:	85 ff                	test   %edi,%edi
  801312:	79 1d                	jns    801331 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	53                   	push   %ebx
  801318:	6a 00                	push   $0x0
  80131a:	e8 ce fb ff ff       	call   800eed <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	ff 75 d4             	pushl  -0x2c(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 c1 fb ff ff       	call   800eed <sys_page_unmap>
	return r;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 f8                	mov    %edi,%eax
}
  801331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 14             	sub    $0x14,%esp
  801340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801343:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	53                   	push   %ebx
  801348:	e8 82 fd ff ff       	call   8010cf <fd_lookup>
  80134d:	83 c4 08             	add    $0x8,%esp
  801350:	89 c2                	mov    %eax,%edx
  801352:	85 c0                	test   %eax,%eax
  801354:	78 6d                	js     8013c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	ff 30                	pushl  (%eax)
  801362:	e8 be fd ff ff       	call   801125 <dev_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 4c                	js     8013ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801371:	8b 42 08             	mov    0x8(%edx),%eax
  801374:	83 e0 03             	and    $0x3,%eax
  801377:	83 f8 01             	cmp    $0x1,%eax
  80137a:	75 21                	jne    80139d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137c:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801381:	8b 40 48             	mov    0x48(%eax),%eax
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	50                   	push   %eax
  801389:	68 0d 2b 80 00       	push   $0x802b0d
  80138e:	e8 45 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139b:	eb 26                	jmp    8013c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	8b 40 08             	mov    0x8(%eax),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 17                	je     8013be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	ff 75 10             	pushl  0x10(%ebp)
  8013ad:	ff 75 0c             	pushl  0xc(%ebp)
  8013b0:	52                   	push   %edx
  8013b1:	ff d0                	call   *%eax
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb 09                	jmp    8013c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	eb 05                	jmp    8013c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013c3:	89 d0                	mov    %edx,%eax
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013de:	eb 21                	jmp    801401 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	29 d8                	sub    %ebx,%eax
  8013e7:	50                   	push   %eax
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	03 45 0c             	add    0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	57                   	push   %edi
  8013ef:	e8 45 ff ff ff       	call   801339 <read>
		if (m < 0)
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 0c                	js     801407 <readn+0x3d>
			return m;
		if (m == 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 06                	je     801405 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ff:	01 c3                	add    %eax,%ebx
  801401:	39 f3                	cmp    %esi,%ebx
  801403:	72 db                	jb     8013e0 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801405:	89 d8                	mov    %ebx,%eax
}
  801407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
  801416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	53                   	push   %ebx
  80141e:	e8 ac fc ff ff       	call   8010cf <fd_lookup>
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	89 c2                	mov    %eax,%edx
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 68                	js     801494 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	ff 30                	pushl  (%eax)
  801438:	e8 e8 fc ff ff       	call   801125 <dev_lookup>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 47                	js     80148b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144b:	75 21                	jne    80146e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	53                   	push   %ebx
  801459:	50                   	push   %eax
  80145a:	68 29 2b 80 00       	push   $0x802b29
  80145f:	e8 74 f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146c:	eb 26                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 0c             	mov    0xc(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 17                	je     80148f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	pushl  0x10(%ebp)
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	50                   	push   %eax
  801482:	ff d2                	call   *%edx
  801484:	89 c2                	mov    %eax,%edx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 09                	jmp    801494 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	eb 05                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801494:	89 d0                	mov    %edx,%eax
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <seek>:

int
seek(int fdnum, off_t offset)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	ff 75 08             	pushl  0x8(%ebp)
  8014a8:	e8 22 fc ff ff       	call   8010cf <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 0e                	js     8014c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 14             	sub    $0x14,%esp
  8014cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	53                   	push   %ebx
  8014d3:	e8 f7 fb ff ff       	call   8010cf <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 65                	js     801546 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	ff 30                	pushl  (%eax)
  8014ed:	e8 33 fc ff ff       	call   801125 <dev_lookup>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 44                	js     80153d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801500:	75 21                	jne    801523 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801502:	a1 b0 67 80 00       	mov    0x8067b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801507:	8b 40 48             	mov    0x48(%eax),%eax
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	53                   	push   %ebx
  80150e:	50                   	push   %eax
  80150f:	68 ec 2a 80 00       	push   $0x802aec
  801514:	e8 bf ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801521:	eb 23                	jmp    801546 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801523:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801526:	8b 52 18             	mov    0x18(%edx),%edx
  801529:	85 d2                	test   %edx,%edx
  80152b:	74 14                	je     801541 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	50                   	push   %eax
  801534:	ff d2                	call   *%edx
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 14             	sub    $0x14,%esp
  801554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 6c fb ff ff       	call   8010cf <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	89 c2                	mov    %eax,%edx
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 58                	js     8015c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	ff 30                	pushl  (%eax)
  801578:	e8 a8 fb ff ff       	call   801125 <dev_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 37                	js     8015bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158b:	74 32                	je     8015bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801590:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801597:	00 00 00 
	stat->st_isdir = 0;
  80159a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a1:	00 00 00 
	stat->st_dev = dev;
  8015a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b1:	ff 50 14             	call   *0x14(%eax)
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	eb 09                	jmp    8015c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	eb 05                	jmp    8015c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	e8 09 02 00 00       	call   8017e6 <open>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 db                	test   %ebx,%ebx
  8015e4:	78 1b                	js     801601 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	53                   	push   %ebx
  8015ed:	e8 5b ff ff ff       	call   80154d <fstat>
  8015f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f4:	89 1c 24             	mov    %ebx,(%esp)
  8015f7:	e8 fd fb ff ff       	call   8011f9 <close>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 f0                	mov    %esi,%eax
}
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	89 c6                	mov    %eax,%esi
  80160f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801611:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801618:	75 12                	jne    80162c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	6a 01                	push   $0x1
  80161f:	e8 8b 0c 00 00       	call   8022af <ipc_find_env>
  801624:	a3 00 50 80 00       	mov    %eax,0x805000
  801629:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162c:	6a 07                	push   $0x7
  80162e:	68 00 70 80 00       	push   $0x807000
  801633:	56                   	push   %esi
  801634:	ff 35 00 50 80 00    	pushl  0x805000
  80163a:	e8 1c 0c 00 00       	call   80225b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163f:	83 c4 0c             	add    $0xc,%esp
  801642:	6a 00                	push   $0x0
  801644:	53                   	push   %ebx
  801645:	6a 00                	push   $0x0
  801647:	e8 a6 0b 00 00       	call   8021f2 <ipc_recv>
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	b8 02 00 00 00       	mov    $0x2,%eax
  801676:	e8 8d ff ff ff       	call   801608 <fsipc>
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 40 0c             	mov    0xc(%eax),%eax
  801689:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 06 00 00 00       	mov    $0x6,%eax
  801698:	e8 6b ff ff ff       	call   801608 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016be:	e8 45 ff ff ff       	call   801608 <fsipc>
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	78 2c                	js     8016f5 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	68 00 70 80 00       	push   $0x807000
  8016d1:	53                   	push   %ebx
  8016d2:	e8 88 f3 ff ff       	call   800a5f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d7:	a1 80 70 80 00       	mov    0x807080,%eax
  8016dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e2:	a1 84 70 80 00       	mov    0x807084,%eax
  8016e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	8b 40 0c             	mov    0xc(%eax),%eax
  80170c:	a3 00 70 80 00       	mov    %eax,0x807000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801714:	eb 3d                	jmp    801753 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801716:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80171c:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801721:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	57                   	push   %edi
  801728:	53                   	push   %ebx
  801729:	68 08 70 80 00       	push   $0x807008
  80172e:	e8 be f4 ff ff       	call   800bf1 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801733:	89 3d 04 70 80 00    	mov    %edi,0x807004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	b8 04 00 00 00       	mov    $0x4,%eax
  801743:	e8 c0 fe ff ff       	call   801608 <fsipc>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 0d                	js     80175c <devfile_write+0x62>
		        return r;
                n -= tmp;
  80174f:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801751:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801753:	85 f6                	test   %esi,%esi
  801755:	75 bf                	jne    801716 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801757:	89 d8                	mov    %ebx,%eax
  801759:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80175c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8b 40 0c             	mov    0xc(%eax),%eax
  801772:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801777:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 03 00 00 00       	mov    $0x3,%eax
  801787:	e8 7c fe ff ff       	call   801608 <fsipc>
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 4b                	js     8017dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801792:	39 c6                	cmp    %eax,%esi
  801794:	73 16                	jae    8017ac <devfile_read+0x48>
  801796:	68 58 2b 80 00       	push   $0x802b58
  80179b:	68 5f 2b 80 00       	push   $0x802b5f
  8017a0:	6a 7c                	push   $0x7c
  8017a2:	68 74 2b 80 00       	push   $0x802b74
  8017a7:	e8 53 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b1:	7e 16                	jle    8017c9 <devfile_read+0x65>
  8017b3:	68 7f 2b 80 00       	push   $0x802b7f
  8017b8:	68 5f 2b 80 00       	push   $0x802b5f
  8017bd:	6a 7d                	push   $0x7d
  8017bf:	68 74 2b 80 00       	push   $0x802b74
  8017c4:	e8 36 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	50                   	push   %eax
  8017cd:	68 00 70 80 00       	push   $0x807000
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	e8 17 f4 ff ff       	call   800bf1 <memmove>
	return r;
  8017da:	83 c4 10             	add    $0x10,%esp
}
  8017dd:	89 d8                	mov    %ebx,%eax
  8017df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	83 ec 20             	sub    $0x20,%esp
  8017ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f0:	53                   	push   %ebx
  8017f1:	e8 30 f2 ff ff       	call   800a26 <strlen>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fe:	7f 67                	jg     801867 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801800:	83 ec 0c             	sub    $0xc,%esp
  801803:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801806:	50                   	push   %eax
  801807:	e8 74 f8 ff ff       	call   801080 <fd_alloc>
  80180c:	83 c4 10             	add    $0x10,%esp
		return r;
  80180f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801811:	85 c0                	test   %eax,%eax
  801813:	78 57                	js     80186c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	53                   	push   %ebx
  801819:	68 00 70 80 00       	push   $0x807000
  80181e:	e8 3c f2 ff ff       	call   800a5f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801823:	8b 45 0c             	mov    0xc(%ebp),%eax
  801826:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182e:	b8 01 00 00 00       	mov    $0x1,%eax
  801833:	e8 d0 fd ff ff       	call   801608 <fsipc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	79 14                	jns    801855 <open+0x6f>
		fd_close(fd, 0);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	6a 00                	push   $0x0
  801846:	ff 75 f4             	pushl  -0xc(%ebp)
  801849:	e8 2a f9 ff ff       	call   801178 <fd_close>
		return r;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	89 da                	mov    %ebx,%edx
  801853:	eb 17                	jmp    80186c <open+0x86>
	}

	return fd2num(fd);
  801855:	83 ec 0c             	sub    $0xc,%esp
  801858:	ff 75 f4             	pushl  -0xc(%ebp)
  80185b:	e8 f9 f7 ff ff       	call   801059 <fd2num>
  801860:	89 c2                	mov    %eax,%edx
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb 05                	jmp    80186c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801867:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186c:	89 d0                	mov    %edx,%eax
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801879:	ba 00 00 00 00       	mov    $0x0,%edx
  80187e:	b8 08 00 00 00       	mov    $0x8,%eax
  801883:	e8 80 fd ff ff       	call   801608 <fsipc>
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801896:	6a 00                	push   $0x0
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 46 ff ff ff       	call   8017e6 <open>
  8018a0:	89 c7                	mov    %eax,%edi
  8018a2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	0f 88 97 04 00 00    	js     801d4a <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	68 00 02 00 00       	push   $0x200
  8018bb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	57                   	push   %edi
  8018c3:	e8 02 fb ff ff       	call   8013ca <readn>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018d0:	75 0c                	jne    8018de <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018d2:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018d9:	45 4c 46 
  8018dc:	74 33                	je     801911 <spawn+0x87>
		close(fd);
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018e7:	e8 0d f9 ff ff       	call   8011f9 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018ec:	83 c4 0c             	add    $0xc,%esp
  8018ef:	68 7f 45 4c 46       	push   $0x464c457f
  8018f4:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018fa:	68 8b 2b 80 00       	push   $0x802b8b
  8018ff:	e8 d4 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80190c:	e9 be 04 00 00       	jmp    801dcf <spawn+0x545>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801911:	b8 07 00 00 00       	mov    $0x7,%eax
  801916:	cd 30                	int    $0x30
  801918:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80191e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801924:	85 c0                	test   %eax,%eax
  801926:	0f 88 26 04 00 00    	js     801d52 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80192c:	89 c6                	mov    %eax,%esi
  80192e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801934:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801937:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80193d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801943:	b9 11 00 00 00       	mov    $0x11,%ecx
  801948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80194a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801950:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801956:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80195b:	be 00 00 00 00       	mov    $0x0,%esi
  801960:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801963:	eb 13                	jmp    801978 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	50                   	push   %eax
  801969:	e8 b8 f0 ff ff       	call   800a26 <strlen>
  80196e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801972:	83 c3 01             	add    $0x1,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80197f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801982:	85 c0                	test   %eax,%eax
  801984:	75 df                	jne    801965 <spawn+0xdb>
  801986:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80198c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801992:	bf 00 10 40 00       	mov    $0x401000,%edi
  801997:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801999:	89 fa                	mov    %edi,%edx
  80199b:	83 e2 fc             	and    $0xfffffffc,%edx
  80199e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019a5:	29 c2                	sub    %eax,%edx
  8019a7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019ad:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019b0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019b5:	0f 86 a7 03 00 00    	jbe    801d62 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	6a 07                	push   $0x7
  8019c0:	68 00 00 40 00       	push   $0x400000
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 9c f4 ff ff       	call   800e68 <sys_page_alloc>
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	0f 88 f8 03 00 00    	js     801dcf <spawn+0x545>
  8019d7:	be 00 00 00 00       	mov    $0x0,%esi
  8019dc:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e5:	eb 30                	jmp    801a17 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019e7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019ed:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019f3:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019fc:	57                   	push   %edi
  8019fd:	e8 5d f0 ff ff       	call   800a5f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a02:	83 c4 04             	add    $0x4,%esp
  801a05:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a08:	e8 19 f0 ff ff       	call   800a26 <strlen>
  801a0d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a11:	83 c6 01             	add    $0x1,%esi
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a1d:	7f c8                	jg     8019e7 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a1f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a25:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a2b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a32:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a38:	74 19                	je     801a53 <spawn+0x1c9>
  801a3a:	68 18 2c 80 00       	push   $0x802c18
  801a3f:	68 5f 2b 80 00       	push   $0x802b5f
  801a44:	68 f1 00 00 00       	push   $0xf1
  801a49:	68 a5 2b 80 00       	push   $0x802ba5
  801a4e:	e8 ac e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a53:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a59:	89 f8                	mov    %edi,%eax
  801a5b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a60:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a63:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a69:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a6c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a72:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	6a 07                	push   $0x7
  801a7d:	68 00 d0 bf ee       	push   $0xeebfd000
  801a82:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a88:	68 00 00 40 00       	push   $0x400000
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 17 f4 ff ff       	call   800eab <sys_page_map>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	83 c4 20             	add    $0x20,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	0f 88 1a 03 00 00    	js     801dbb <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	68 00 00 40 00       	push   $0x400000
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 3d f4 ff ff       	call   800eed <sys_page_unmap>
  801ab0:	89 c3                	mov    %eax,%ebx
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	0f 88 fe 02 00 00    	js     801dbb <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801abd:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ac3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801aca:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ad0:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ad7:	00 00 00 
  801ada:	e9 85 01 00 00       	jmp    801c64 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801adf:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ae5:	83 38 01             	cmpl   $0x1,(%eax)
  801ae8:	0f 85 68 01 00 00    	jne    801c56 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801aee:	89 c7                	mov    %eax,%edi
  801af0:	8b 40 18             	mov    0x18(%eax),%eax
  801af3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801af9:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801afc:	83 f8 01             	cmp    $0x1,%eax
  801aff:	19 c0                	sbb    %eax,%eax
  801b01:	83 e0 fe             	and    $0xfffffffe,%eax
  801b04:	83 c0 07             	add    $0x7,%eax
  801b07:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b0d:	89 f8                	mov    %edi,%eax
  801b0f:	8b 7f 04             	mov    0x4(%edi),%edi
  801b12:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b18:	8b 78 10             	mov    0x10(%eax),%edi
  801b1b:	8b 48 14             	mov    0x14(%eax),%ecx
  801b1e:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801b24:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b27:	89 f0                	mov    %esi,%eax
  801b29:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b2e:	74 10                	je     801b40 <spawn+0x2b6>
		va -= i;
  801b30:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b32:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801b38:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b3a:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b45:	e9 fa 00 00 00       	jmp    801c44 <spawn+0x3ba>
		if (i >= filesz) {
  801b4a:	39 fb                	cmp    %edi,%ebx
  801b4c:	72 27                	jb     801b75 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b4e:	83 ec 04             	sub    $0x4,%esp
  801b51:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b57:	56                   	push   %esi
  801b58:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b5e:	e8 05 f3 ff ff       	call   800e68 <sys_page_alloc>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 89 ca 00 00 00    	jns    801c38 <spawn+0x3ae>
  801b6e:	89 c7                	mov    %eax,%edi
  801b70:	e9 fe 01 00 00       	jmp    801d73 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b75:	83 ec 04             	sub    $0x4,%esp
  801b78:	6a 07                	push   $0x7
  801b7a:	68 00 00 40 00       	push   $0x400000
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 e2 f2 ff ff       	call   800e68 <sys_page_alloc>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	0f 88 d8 01 00 00    	js     801d69 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b91:	83 ec 08             	sub    $0x8,%esp
  801b94:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b9a:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ba7:	e8 ef f8 ff ff       	call   80149b <seek>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 b6 01 00 00    	js     801d6d <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bb7:	83 ec 04             	sub    $0x4,%esp
  801bba:	89 fa                	mov    %edi,%edx
  801bbc:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801bc2:	89 d0                	mov    %edx,%eax
  801bc4:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801bca:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801bcf:	0f 47 c1             	cmova  %ecx,%eax
  801bd2:	50                   	push   %eax
  801bd3:	68 00 00 40 00       	push   $0x400000
  801bd8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bde:	e8 e7 f7 ff ff       	call   8013ca <readn>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 83 01 00 00    	js     801d71 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bf7:	56                   	push   %esi
  801bf8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bfe:	68 00 00 40 00       	push   $0x400000
  801c03:	6a 00                	push   $0x0
  801c05:	e8 a1 f2 ff ff       	call   800eab <sys_page_map>
  801c0a:	83 c4 20             	add    $0x20,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	79 15                	jns    801c26 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801c11:	50                   	push   %eax
  801c12:	68 b1 2b 80 00       	push   $0x802bb1
  801c17:	68 24 01 00 00       	push   $0x124
  801c1c:	68 a5 2b 80 00       	push   $0x802ba5
  801c21:	e8 d9 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	68 00 00 40 00       	push   $0x400000
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 b8 f2 ff ff       	call   800eed <sys_page_unmap>
  801c35:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c38:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c3e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c44:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c4a:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c50:	0f 82 f4 fe ff ff    	jb     801b4a <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c56:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c5d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c64:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c6b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c71:	0f 8c 68 fe ff ff    	jl     801adf <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c80:	e8 74 f5 ff ff       	call   8011f9 <close>
  801c85:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801c93:	89 d8                	mov    %ebx,%eax
  801c95:	c1 e8 16             	shr    $0x16,%eax
  801c98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c9f:	a8 01                	test   $0x1,%al
  801ca1:	74 53                	je     801cf6 <spawn+0x46c>
  801ca3:	89 d8                	mov    %ebx,%eax
  801ca5:	c1 e8 0c             	shr    $0xc,%eax
  801ca8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801caf:	f6 c2 01             	test   $0x1,%dl
  801cb2:	74 42                	je     801cf6 <spawn+0x46c>
  801cb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cbb:	f6 c6 04             	test   $0x4,%dh
  801cbe:	74 36                	je     801cf6 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801cc0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	25 07 0e 00 00       	and    $0xe07,%eax
  801ccf:	50                   	push   %eax
  801cd0:	53                   	push   %ebx
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 d1 f1 ff ff       	call   800eab <sys_page_map>
                        if (r < 0) return r;
  801cda:	83 c4 20             	add    $0x20,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	79 15                	jns    801cf6 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ce1:	50                   	push   %eax
  801ce2:	68 ce 2b 80 00       	push   $0x802bce
  801ce7:	68 82 00 00 00       	push   $0x82
  801cec:	68 a5 2b 80 00       	push   $0x802ba5
  801cf1:	e8 09 e7 ff ff       	call   8003ff <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801cf6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cfc:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d02:	75 8f                	jne    801c93 <spawn+0x409>
  801d04:	e9 8d 00 00 00       	jmp    801d96 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801d09:	50                   	push   %eax
  801d0a:	68 e4 2b 80 00       	push   $0x802be4
  801d0f:	68 85 00 00 00       	push   $0x85
  801d14:	68 a5 2b 80 00       	push   $0x802ba5
  801d19:	e8 e1 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	6a 02                	push   $0x2
  801d23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d29:	e8 01 f2 ff ff       	call   800f2f <sys_env_set_status>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	79 25                	jns    801d5a <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801d35:	50                   	push   %eax
  801d36:	68 fe 2b 80 00       	push   $0x802bfe
  801d3b:	68 88 00 00 00       	push   $0x88
  801d40:	68 a5 2b 80 00       	push   $0x802ba5
  801d45:	e8 b5 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d4a:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d50:	eb 7d                	jmp    801dcf <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d52:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d58:	eb 75                	jmp    801dcf <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d5a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d60:	eb 6d                	jmp    801dcf <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d62:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801d67:	eb 66                	jmp    801dcf <spawn+0x545>
  801d69:	89 c7                	mov    %eax,%edi
  801d6b:	eb 06                	jmp    801d73 <spawn+0x4e9>
  801d6d:	89 c7                	mov    %eax,%edi
  801d6f:	eb 02                	jmp    801d73 <spawn+0x4e9>
  801d71:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d7c:	e8 68 f0 ff ff       	call   800de9 <sys_env_destroy>
	close(fd);
  801d81:	83 c4 04             	add    $0x4,%esp
  801d84:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d8a:	e8 6a f4 ff ff       	call   8011f9 <close>
	return r;
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	89 f8                	mov    %edi,%eax
  801d94:	eb 39                	jmp    801dcf <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d9f:	50                   	push   %eax
  801da0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801da6:	e8 c6 f1 ff ff       	call   800f71 <sys_env_set_trapframe>
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	0f 89 68 ff ff ff    	jns    801d1e <spawn+0x494>
  801db6:	e9 4e ff ff ff       	jmp    801d09 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	68 00 00 40 00       	push   $0x400000
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 23 f1 ff ff       	call   800eed <sys_page_unmap>
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ddc:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ddf:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de4:	eb 03                	jmp    801de9 <spawnl+0x12>
		argc++;
  801de6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de9:	83 c2 04             	add    $0x4,%edx
  801dec:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801df0:	75 f4                	jne    801de6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801df2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801df9:	83 e2 f0             	and    $0xfffffff0,%edx
  801dfc:	29 d4                	sub    %edx,%esp
  801dfe:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e02:	c1 ea 02             	shr    $0x2,%edx
  801e05:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e0c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e11:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e18:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e1f:	00 
  801e20:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
  801e27:	eb 0a                	jmp    801e33 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e29:	83 c0 01             	add    $0x1,%eax
  801e2c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e30:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e33:	39 d0                	cmp    %edx,%eax
  801e35:	75 f2                	jne    801e29 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e37:	83 ec 08             	sub    $0x8,%esp
  801e3a:	56                   	push   %esi
  801e3b:	ff 75 08             	pushl  0x8(%ebp)
  801e3e:	e8 47 fa ff ff       	call   80188a <spawn>
}
  801e43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	ff 75 08             	pushl  0x8(%ebp)
  801e58:	e8 0c f2 ff ff       	call   801069 <fd2data>
  801e5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e5f:	83 c4 08             	add    $0x8,%esp
  801e62:	68 40 2c 80 00       	push   $0x802c40
  801e67:	53                   	push   %ebx
  801e68:	e8 f2 eb ff ff       	call   800a5f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e6d:	8b 56 04             	mov    0x4(%esi),%edx
  801e70:	89 d0                	mov    %edx,%eax
  801e72:	2b 06                	sub    (%esi),%eax
  801e74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e7a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e81:	00 00 00 
	stat->st_dev = &devpipe;
  801e84:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801e8b:	47 80 00 
	return 0;
}
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ea4:	53                   	push   %ebx
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 41 f0 ff ff       	call   800eed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eac:	89 1c 24             	mov    %ebx,(%esp)
  801eaf:	e8 b5 f1 ff ff       	call   801069 <fd2data>
  801eb4:	83 c4 08             	add    $0x8,%esp
  801eb7:	50                   	push   %eax
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 2e f0 ff ff       	call   800eed <sys_page_unmap>
}
  801ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 1c             	sub    $0x1c,%esp
  801ecd:	89 c6                	mov    %eax,%esi
  801ecf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ed2:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801ed7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	56                   	push   %esi
  801ede:	e8 04 04 00 00       	call   8022e7 <pageref>
  801ee3:	89 c7                	mov    %eax,%edi
  801ee5:	83 c4 04             	add    $0x4,%esp
  801ee8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eeb:	e8 f7 03 00 00       	call   8022e7 <pageref>
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	39 c7                	cmp    %eax,%edi
  801ef5:	0f 94 c2             	sete   %dl
  801ef8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801efb:	8b 0d b0 67 80 00    	mov    0x8067b0,%ecx
  801f01:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801f04:	39 fb                	cmp    %edi,%ebx
  801f06:	74 19                	je     801f21 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801f08:	84 d2                	test   %dl,%dl
  801f0a:	74 c6                	je     801ed2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f0c:	8b 51 58             	mov    0x58(%ecx),%edx
  801f0f:	50                   	push   %eax
  801f10:	52                   	push   %edx
  801f11:	53                   	push   %ebx
  801f12:	68 47 2c 80 00       	push   $0x802c47
  801f17:	e8 bc e5 ff ff       	call   8004d8 <cprintf>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	eb b1                	jmp    801ed2 <_pipeisclosed+0xe>
	}
}
  801f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5e                   	pop    %esi
  801f26:	5f                   	pop    %edi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	57                   	push   %edi
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	83 ec 28             	sub    $0x28,%esp
  801f32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f35:	56                   	push   %esi
  801f36:	e8 2e f1 ff ff       	call   801069 <fd2data>
  801f3b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	bf 00 00 00 00       	mov    $0x0,%edi
  801f45:	eb 4b                	jmp    801f92 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f47:	89 da                	mov    %ebx,%edx
  801f49:	89 f0                	mov    %esi,%eax
  801f4b:	e8 74 ff ff ff       	call   801ec4 <_pipeisclosed>
  801f50:	85 c0                	test   %eax,%eax
  801f52:	75 48                	jne    801f9c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f54:	e8 f0 ee ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f59:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5c:	8b 0b                	mov    (%ebx),%ecx
  801f5e:	8d 51 20             	lea    0x20(%ecx),%edx
  801f61:	39 d0                	cmp    %edx,%eax
  801f63:	73 e2                	jae    801f47 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f6f:	89 c2                	mov    %eax,%edx
  801f71:	c1 fa 1f             	sar    $0x1f,%edx
  801f74:	89 d1                	mov    %edx,%ecx
  801f76:	c1 e9 1b             	shr    $0x1b,%ecx
  801f79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f7c:	83 e2 1f             	and    $0x1f,%edx
  801f7f:	29 ca                	sub    %ecx,%edx
  801f81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f89:	83 c0 01             	add    $0x1,%eax
  801f8c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8f:	83 c7 01             	add    $0x1,%edi
  801f92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f95:	75 c2                	jne    801f59 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f97:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9a:	eb 05                	jmp    801fa1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	57                   	push   %edi
  801fad:	56                   	push   %esi
  801fae:	53                   	push   %ebx
  801faf:	83 ec 18             	sub    $0x18,%esp
  801fb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fb5:	57                   	push   %edi
  801fb6:	e8 ae f0 ff ff       	call   801069 <fd2data>
  801fbb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc5:	eb 3d                	jmp    802004 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc7:	85 db                	test   %ebx,%ebx
  801fc9:	74 04                	je     801fcf <devpipe_read+0x26>
				return i;
  801fcb:	89 d8                	mov    %ebx,%eax
  801fcd:	eb 44                	jmp    802013 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fcf:	89 f2                	mov    %esi,%edx
  801fd1:	89 f8                	mov    %edi,%eax
  801fd3:	e8 ec fe ff ff       	call   801ec4 <_pipeisclosed>
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	75 32                	jne    80200e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fdc:	e8 68 ee ff ff       	call   800e49 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fe1:	8b 06                	mov    (%esi),%eax
  801fe3:	3b 46 04             	cmp    0x4(%esi),%eax
  801fe6:	74 df                	je     801fc7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe8:	99                   	cltd   
  801fe9:	c1 ea 1b             	shr    $0x1b,%edx
  801fec:	01 d0                	add    %edx,%eax
  801fee:	83 e0 1f             	and    $0x1f,%eax
  801ff1:	29 d0                	sub    %edx,%eax
  801ff3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ffe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802001:	83 c3 01             	add    $0x1,%ebx
  802004:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802007:	75 d8                	jne    801fe1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802009:	8b 45 10             	mov    0x10(%ebp),%eax
  80200c:	eb 05                	jmp    802013 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802026:	50                   	push   %eax
  802027:	e8 54 f0 ff ff       	call   801080 <fd_alloc>
  80202c:	83 c4 10             	add    $0x10,%esp
  80202f:	89 c2                	mov    %eax,%edx
  802031:	85 c0                	test   %eax,%eax
  802033:	0f 88 2c 01 00 00    	js     802165 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	68 07 04 00 00       	push   $0x407
  802041:	ff 75 f4             	pushl  -0xc(%ebp)
  802044:	6a 00                	push   $0x0
  802046:	e8 1d ee ff ff       	call   800e68 <sys_page_alloc>
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	89 c2                	mov    %eax,%edx
  802050:	85 c0                	test   %eax,%eax
  802052:	0f 88 0d 01 00 00    	js     802165 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80205e:	50                   	push   %eax
  80205f:	e8 1c f0 ff ff       	call   801080 <fd_alloc>
  802064:	89 c3                	mov    %eax,%ebx
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 e2 00 00 00    	js     802153 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802071:	83 ec 04             	sub    $0x4,%esp
  802074:	68 07 04 00 00       	push   $0x407
  802079:	ff 75 f0             	pushl  -0x10(%ebp)
  80207c:	6a 00                	push   $0x0
  80207e:	e8 e5 ed ff ff       	call   800e68 <sys_page_alloc>
  802083:	89 c3                	mov    %eax,%ebx
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	85 c0                	test   %eax,%eax
  80208a:	0f 88 c3 00 00 00    	js     802153 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802090:	83 ec 0c             	sub    $0xc,%esp
  802093:	ff 75 f4             	pushl  -0xc(%ebp)
  802096:	e8 ce ef ff ff       	call   801069 <fd2data>
  80209b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209d:	83 c4 0c             	add    $0xc,%esp
  8020a0:	68 07 04 00 00       	push   $0x407
  8020a5:	50                   	push   %eax
  8020a6:	6a 00                	push   $0x0
  8020a8:	e8 bb ed ff ff       	call   800e68 <sys_page_alloc>
  8020ad:	89 c3                	mov    %eax,%ebx
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	0f 88 89 00 00 00    	js     802143 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c0:	e8 a4 ef ff ff       	call   801069 <fd2data>
  8020c5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020cc:	50                   	push   %eax
  8020cd:	6a 00                	push   $0x0
  8020cf:	56                   	push   %esi
  8020d0:	6a 00                	push   $0x0
  8020d2:	e8 d4 ed ff ff       	call   800eab <sys_page_map>
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	83 c4 20             	add    $0x20,%esp
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	78 55                	js     802135 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020e0:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020f5:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802100:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802103:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80210a:	83 ec 0c             	sub    $0xc,%esp
  80210d:	ff 75 f4             	pushl  -0xc(%ebp)
  802110:	e8 44 ef ff ff       	call   801059 <fd2num>
  802115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802118:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80211a:	83 c4 04             	add    $0x4,%esp
  80211d:	ff 75 f0             	pushl  -0x10(%ebp)
  802120:	e8 34 ef ff ff       	call   801059 <fd2num>
  802125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802128:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	ba 00 00 00 00       	mov    $0x0,%edx
  802133:	eb 30                	jmp    802165 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802135:	83 ec 08             	sub    $0x8,%esp
  802138:	56                   	push   %esi
  802139:	6a 00                	push   $0x0
  80213b:	e8 ad ed ff ff       	call   800eed <sys_page_unmap>
  802140:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802143:	83 ec 08             	sub    $0x8,%esp
  802146:	ff 75 f0             	pushl  -0x10(%ebp)
  802149:	6a 00                	push   $0x0
  80214b:	e8 9d ed ff ff       	call   800eed <sys_page_unmap>
  802150:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	ff 75 f4             	pushl  -0xc(%ebp)
  802159:	6a 00                	push   $0x0
  80215b:	e8 8d ed ff ff       	call   800eed <sys_page_unmap>
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802165:	89 d0                	mov    %edx,%eax
  802167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802177:	50                   	push   %eax
  802178:	ff 75 08             	pushl  0x8(%ebp)
  80217b:	e8 4f ef ff ff       	call   8010cf <fd_lookup>
  802180:	89 c2                	mov    %eax,%edx
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	85 d2                	test   %edx,%edx
  802187:	78 18                	js     8021a1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802189:	83 ec 0c             	sub    $0xc,%esp
  80218c:	ff 75 f4             	pushl  -0xc(%ebp)
  80218f:	e8 d5 ee ff ff       	call   801069 <fd2data>
	return _pipeisclosed(fd, p);
  802194:	89 c2                	mov    %eax,%edx
  802196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802199:	e8 26 fd ff ff       	call   801ec4 <_pipeisclosed>
  80219e:	83 c4 10             	add    $0x10,%esp
}
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    

008021a3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021ab:	85 f6                	test   %esi,%esi
  8021ad:	75 16                	jne    8021c5 <wait+0x22>
  8021af:	68 5f 2c 80 00       	push   $0x802c5f
  8021b4:	68 5f 2b 80 00       	push   $0x802b5f
  8021b9:	6a 09                	push   $0x9
  8021bb:	68 6a 2c 80 00       	push   $0x802c6a
  8021c0:	e8 3a e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8021c5:	89 f3                	mov    %esi,%ebx
  8021c7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021cd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021d0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021d6:	eb 05                	jmp    8021dd <wait+0x3a>
		sys_yield();
  8021d8:	e8 6c ec ff ff       	call   800e49 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021dd:	8b 43 48             	mov    0x48(%ebx),%eax
  8021e0:	39 f0                	cmp    %esi,%eax
  8021e2:	75 07                	jne    8021eb <wait+0x48>
  8021e4:	8b 43 54             	mov    0x54(%ebx),%eax
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	75 ed                	jne    8021d8 <wait+0x35>
		sys_yield();
}
  8021eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ee:	5b                   	pop    %ebx
  8021ef:	5e                   	pop    %esi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    

008021f2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	56                   	push   %esi
  8021f6:	53                   	push   %ebx
  8021f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8021fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802200:	85 c0                	test   %eax,%eax
  802202:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802207:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80220a:	83 ec 0c             	sub    $0xc,%esp
  80220d:	50                   	push   %eax
  80220e:	e8 05 ee ff ff       	call   801018 <sys_ipc_recv>
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	79 16                	jns    802230 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80221a:	85 f6                	test   %esi,%esi
  80221c:	74 06                	je     802224 <ipc_recv+0x32>
  80221e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802224:	85 db                	test   %ebx,%ebx
  802226:	74 2c                	je     802254 <ipc_recv+0x62>
  802228:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80222e:	eb 24                	jmp    802254 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802230:	85 f6                	test   %esi,%esi
  802232:	74 0a                	je     80223e <ipc_recv+0x4c>
  802234:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  802239:	8b 40 74             	mov    0x74(%eax),%eax
  80223c:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80223e:	85 db                	test   %ebx,%ebx
  802240:	74 0a                	je     80224c <ipc_recv+0x5a>
  802242:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  802247:	8b 40 78             	mov    0x78(%eax),%eax
  80224a:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80224c:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  802251:	8b 40 70             	mov    0x70(%eax),%eax
}
  802254:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 0c             	sub    $0xc,%esp
  802264:	8b 7d 08             	mov    0x8(%ebp),%edi
  802267:	8b 75 0c             	mov    0xc(%ebp),%esi
  80226a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80226d:	85 db                	test   %ebx,%ebx
  80226f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802274:	0f 44 d8             	cmove  %eax,%ebx
  802277:	eb 1c                	jmp    802295 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802279:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80227c:	74 12                	je     802290 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80227e:	50                   	push   %eax
  80227f:	68 75 2c 80 00       	push   $0x802c75
  802284:	6a 39                	push   $0x39
  802286:	68 90 2c 80 00       	push   $0x802c90
  80228b:	e8 6f e1 ff ff       	call   8003ff <_panic>
                 sys_yield();
  802290:	e8 b4 eb ff ff       	call   800e49 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802295:	ff 75 14             	pushl  0x14(%ebp)
  802298:	53                   	push   %ebx
  802299:	56                   	push   %esi
  80229a:	57                   	push   %edi
  80229b:	e8 55 ed ff ff       	call   800ff5 <sys_ipc_try_send>
  8022a0:	83 c4 10             	add    $0x10,%esp
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	78 d2                	js     802279 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8022a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022aa:	5b                   	pop    %ebx
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c3:	8b 52 50             	mov    0x50(%edx),%edx
  8022c6:	39 ca                	cmp    %ecx,%edx
  8022c8:	75 0d                	jne    8022d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022cd:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8022d2:	8b 40 08             	mov    0x8(%eax),%eax
  8022d5:	eb 0e                	jmp    8022e5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022d7:	83 c0 01             	add    $0x1,%eax
  8022da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022df:	75 d9                	jne    8022ba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ed:	89 d0                	mov    %edx,%eax
  8022ef:	c1 e8 16             	shr    $0x16,%eax
  8022f2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022f9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022fe:	f6 c1 01             	test   $0x1,%cl
  802301:	74 1d                	je     802320 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802303:	c1 ea 0c             	shr    $0xc,%edx
  802306:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80230d:	f6 c2 01             	test   $0x1,%dl
  802310:	74 0e                	je     802320 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802312:	c1 ea 0c             	shr    $0xc,%edx
  802315:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80231c:	ef 
  80231d:	0f b7 c0             	movzwl %ax,%eax
}
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	83 ec 10             	sub    $0x10,%esp
  802336:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80233a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80233e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802342:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802346:	85 d2                	test   %edx,%edx
  802348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234c:	89 34 24             	mov    %esi,(%esp)
  80234f:	89 c8                	mov    %ecx,%eax
  802351:	75 35                	jne    802388 <__udivdi3+0x58>
  802353:	39 f1                	cmp    %esi,%ecx
  802355:	0f 87 bd 00 00 00    	ja     802418 <__udivdi3+0xe8>
  80235b:	85 c9                	test   %ecx,%ecx
  80235d:	89 cd                	mov    %ecx,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f1                	div    %ecx
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 f0                	mov    %esi,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c6                	mov    %eax,%esi
  802374:	89 f8                	mov    %edi,%eax
  802376:	f7 f5                	div    %ebp
  802378:	89 f2                	mov    %esi,%edx
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	3b 14 24             	cmp    (%esp),%edx
  80238b:	77 7b                	ja     802408 <__udivdi3+0xd8>
  80238d:	0f bd f2             	bsr    %edx,%esi
  802390:	83 f6 1f             	xor    $0x1f,%esi
  802393:	0f 84 97 00 00 00    	je     802430 <__udivdi3+0x100>
  802399:	bd 20 00 00 00       	mov    $0x20,%ebp
  80239e:	89 d7                	mov    %edx,%edi
  8023a0:	89 f1                	mov    %esi,%ecx
  8023a2:	29 f5                	sub    %esi,%ebp
  8023a4:	d3 e7                	shl    %cl,%edi
  8023a6:	89 c2                	mov    %eax,%edx
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	d3 ea                	shr    %cl,%edx
  8023ac:	89 f1                	mov    %esi,%ecx
  8023ae:	09 fa                	or     %edi,%edx
  8023b0:	8b 3c 24             	mov    (%esp),%edi
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023c3:	89 fa                	mov    %edi,%edx
  8023c5:	d3 ea                	shr    %cl,%edx
  8023c7:	89 f1                	mov    %esi,%ecx
  8023c9:	d3 e7                	shl    %cl,%edi
  8023cb:	89 e9                	mov    %ebp,%ecx
  8023cd:	d3 e8                	shr    %cl,%eax
  8023cf:	09 c7                	or     %eax,%edi
  8023d1:	89 f8                	mov    %edi,%eax
  8023d3:	f7 74 24 08          	divl   0x8(%esp)
  8023d7:	89 d5                	mov    %edx,%ebp
  8023d9:	89 c7                	mov    %eax,%edi
  8023db:	f7 64 24 0c          	mull   0xc(%esp)
  8023df:	39 d5                	cmp    %edx,%ebp
  8023e1:	89 14 24             	mov    %edx,(%esp)
  8023e4:	72 11                	jb     8023f7 <__udivdi3+0xc7>
  8023e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023ea:	89 f1                	mov    %esi,%ecx
  8023ec:	d3 e2                	shl    %cl,%edx
  8023ee:	39 c2                	cmp    %eax,%edx
  8023f0:	73 5e                	jae    802450 <__udivdi3+0x120>
  8023f2:	3b 2c 24             	cmp    (%esp),%ebp
  8023f5:	75 59                	jne    802450 <__udivdi3+0x120>
  8023f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023fa:	31 f6                	xor    %esi,%esi
  8023fc:	89 f2                	mov    %esi,%edx
  8023fe:	83 c4 10             	add    $0x10,%esp
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	31 f6                	xor    %esi,%esi
  80240a:	31 c0                	xor    %eax,%eax
  80240c:	89 f2                	mov    %esi,%edx
  80240e:	83 c4 10             	add    $0x10,%esp
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	89 f2                	mov    %esi,%edx
  80241a:	31 f6                	xor    %esi,%esi
  80241c:	89 f8                	mov    %edi,%eax
  80241e:	f7 f1                	div    %ecx
  802420:	89 f2                	mov    %esi,%edx
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802434:	76 0b                	jbe    802441 <__udivdi3+0x111>
  802436:	31 c0                	xor    %eax,%eax
  802438:	3b 14 24             	cmp    (%esp),%edx
  80243b:	0f 83 37 ff ff ff    	jae    802378 <__udivdi3+0x48>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	e9 2d ff ff ff       	jmp    802378 <__udivdi3+0x48>
  80244b:	90                   	nop
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 f8                	mov    %edi,%eax
  802452:	31 f6                	xor    %esi,%esi
  802454:	e9 1f ff ff ff       	jmp    802378 <__udivdi3+0x48>
  802459:	66 90                	xchg   %ax,%ax
  80245b:	66 90                	xchg   %ax,%ax
  80245d:	66 90                	xchg   %ax,%ax
  80245f:	90                   	nop

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 20             	sub    $0x20,%esp
  802466:	8b 44 24 34          	mov    0x34(%esp),%eax
  80246a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802472:	89 c6                	mov    %eax,%esi
  802474:	89 44 24 10          	mov    %eax,0x10(%esp)
  802478:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80247c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802480:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802484:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802488:	89 74 24 18          	mov    %esi,0x18(%esp)
  80248c:	85 c0                	test   %eax,%eax
  80248e:	89 c2                	mov    %eax,%edx
  802490:	75 1e                	jne    8024b0 <__umoddi3+0x50>
  802492:	39 f7                	cmp    %esi,%edi
  802494:	76 52                	jbe    8024e8 <__umoddi3+0x88>
  802496:	89 c8                	mov    %ecx,%eax
  802498:	89 f2                	mov    %esi,%edx
  80249a:	f7 f7                	div    %edi
  80249c:	89 d0                	mov    %edx,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	83 c4 20             	add    $0x20,%esp
  8024a3:	5e                   	pop    %esi
  8024a4:	5f                   	pop    %edi
  8024a5:	5d                   	pop    %ebp
  8024a6:	c3                   	ret    
  8024a7:	89 f6                	mov    %esi,%esi
  8024a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8024b0:	39 f0                	cmp    %esi,%eax
  8024b2:	77 5c                	ja     802510 <__umoddi3+0xb0>
  8024b4:	0f bd e8             	bsr    %eax,%ebp
  8024b7:	83 f5 1f             	xor    $0x1f,%ebp
  8024ba:	75 64                	jne    802520 <__umoddi3+0xc0>
  8024bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8024c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8024c4:	0f 86 f6 00 00 00    	jbe    8025c0 <__umoddi3+0x160>
  8024ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8024ce:	0f 82 ec 00 00 00    	jb     8025c0 <__umoddi3+0x160>
  8024d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8024dc:	83 c4 20             	add    $0x20,%esp
  8024df:	5e                   	pop    %esi
  8024e0:	5f                   	pop    %edi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    
  8024e3:	90                   	nop
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	85 ff                	test   %edi,%edi
  8024ea:	89 fd                	mov    %edi,%ebp
  8024ec:	75 0b                	jne    8024f9 <__umoddi3+0x99>
  8024ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f7                	div    %edi
  8024f7:	89 c5                	mov    %eax,%ebp
  8024f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	f7 f5                	div    %ebp
  802501:	89 c8                	mov    %ecx,%eax
  802503:	f7 f5                	div    %ebp
  802505:	eb 95                	jmp    80249c <__umoddi3+0x3c>
  802507:	89 f6                	mov    %esi,%esi
  802509:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 20             	add    $0x20,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	b8 20 00 00 00       	mov    $0x20,%eax
  802525:	89 e9                	mov    %ebp,%ecx
  802527:	29 e8                	sub    %ebp,%eax
  802529:	d3 e2                	shl    %cl,%edx
  80252b:	89 c7                	mov    %eax,%edi
  80252d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802531:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e8                	shr    %cl,%eax
  802539:	89 c1                	mov    %eax,%ecx
  80253b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80253f:	09 d1                	or     %edx,%ecx
  802541:	89 fa                	mov    %edi,%edx
  802543:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802547:	89 e9                	mov    %ebp,%ecx
  802549:	d3 e0                	shl    %cl,%eax
  80254b:	89 f9                	mov    %edi,%ecx
  80254d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802551:	89 f0                	mov    %esi,%eax
  802553:	d3 e8                	shr    %cl,%eax
  802555:	89 e9                	mov    %ebp,%ecx
  802557:	89 c7                	mov    %eax,%edi
  802559:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80255d:	d3 e6                	shl    %cl,%esi
  80255f:	89 d1                	mov    %edx,%ecx
  802561:	89 fa                	mov    %edi,%edx
  802563:	d3 e8                	shr    %cl,%eax
  802565:	89 e9                	mov    %ebp,%ecx
  802567:	09 f0                	or     %esi,%eax
  802569:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80256d:	f7 74 24 10          	divl   0x10(%esp)
  802571:	d3 e6                	shl    %cl,%esi
  802573:	89 d1                	mov    %edx,%ecx
  802575:	f7 64 24 0c          	mull   0xc(%esp)
  802579:	39 d1                	cmp    %edx,%ecx
  80257b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80257f:	89 d7                	mov    %edx,%edi
  802581:	89 c6                	mov    %eax,%esi
  802583:	72 0a                	jb     80258f <__umoddi3+0x12f>
  802585:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802589:	73 10                	jae    80259b <__umoddi3+0x13b>
  80258b:	39 d1                	cmp    %edx,%ecx
  80258d:	75 0c                	jne    80259b <__umoddi3+0x13b>
  80258f:	89 d7                	mov    %edx,%edi
  802591:	89 c6                	mov    %eax,%esi
  802593:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802597:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80259b:	89 ca                	mov    %ecx,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025a3:	29 f0                	sub    %esi,%eax
  8025a5:	19 fa                	sbb    %edi,%edx
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8025ae:	89 d7                	mov    %edx,%edi
  8025b0:	d3 e7                	shl    %cl,%edi
  8025b2:	89 e9                	mov    %ebp,%ecx
  8025b4:	09 f8                	or     %edi,%eax
  8025b6:	d3 ea                	shr    %cl,%edx
  8025b8:	83 c4 20             	add    $0x20,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8025c4:	29 f9                	sub    %edi,%ecx
  8025c6:	19 c6                	sbb    %eax,%esi
  8025c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025d0:	e9 ff fe ff ff       	jmp    8024d4 <__umoddi3+0x74>
