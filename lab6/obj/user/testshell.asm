
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 db 18 00 00       	call   80192a <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 d1 18 00 00       	call   80192a <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2f 80 00 	movl   $0x802feb,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 0e 0e 00 00       	call   800e91 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 36 17 00 00       	call   8017c8 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2f 80 00       	push   $0x802ffa
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d9 0d 00 00       	call   800e91 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 01 17 00 00       	call   8017c8 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2f 80 00       	push   $0x802ff5
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
  8000e0:	83 c4 10             	add    $0x10,%esp
}
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 8d 15 00 00       	call   801688 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 81 15 00 00       	call   801688 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 30 80 00       	push   $0x803008
  80011b:	e8 55 1b 00 00       	call   801c75 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 15 30 80 00       	push   $0x803015
  80012f:	6a 13                	push   $0x13
  800131:	68 2b 30 80 00       	push   $0x80302b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 d4 27 00 00       	call   80291b <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 3c 30 80 00       	push   $0x80303c
  800154:	6a 15                	push   $0x15
  800156:	68 2b 30 80 00       	push   $0x80302b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 a4 2f 80 00       	push   $0x802fa4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 4c 11 00 00       	call   8012c1 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 1b 35 80 00       	push   $0x80351b
  800182:	6a 1a                	push   $0x1a
  800184:	68 2b 30 80 00       	push   $0x80302b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 3d 15 00 00       	call   8016da <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 32 15 00 00       	call   8016da <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 d8 14 00 00       	call   801688 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 d0 14 00 00       	call   801688 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 45 30 80 00       	push   $0x803045
  8001bf:	68 12 30 80 00       	push   $0x803012
  8001c4:	68 48 30 80 00       	push   $0x803048
  8001c9:	e8 98 20 00 00       	call   802266 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 4c 30 80 00       	push   $0x80304c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 2b 30 80 00       	push   $0x80302b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 95 14 00 00       	call   801688 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 89 14 00 00       	call   801688 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 9c 28 00 00       	call   802aa3 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 70 14 00 00       	call   801688 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 68 14 00 00       	call   801688 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 56 30 80 00       	push   $0x803056
  800230:	e8 40 1a 00 00       	call   801c75 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 c8 2f 80 00       	push   $0x802fc8
  800245:	6a 2c                	push   $0x2c
  800247:	68 2b 30 80 00       	push   $0x80302b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 5c 15 00 00       	call   8017c8 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 49 15 00 00       	call   8017c8 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 64 30 80 00       	push   $0x803064
  80028c:	6a 33                	push   $0x33
  80028e:	68 2b 30 80 00       	push   $0x80302b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 7e 30 80 00       	push   $0x80307e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 2b 30 80 00       	push   $0x80302b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 c2                	mov    %eax,%edx
  8002b0:	09 da                	or     %ebx,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 98 30 80 00       	push   $0x803098
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   
  8002f6:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 ad 30 80 00       	push   $0x8030ad
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 26 08 00 00       	call   800b44 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 7a 09 00 00       	call   800cd6 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 2b 0b 00 00       	call   800e91 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	75 07                	jne    800392 <devcons_read+0x18>
  80038b:	eb 28                	jmp    8003b5 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 9c 0b 00 00       	call   800f2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 18 0b 00 00       	call   800eaf <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c3 0a 00 00       	call   800e91 <sys_cputs>
  8003ce:	83 c4 10             	add    $0x10,%esp
}
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 e2 13 00 00       	call   8017c8 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 49 11 00 00       	call   801559 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 d1 10 00 00       	call   80150a <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f9 0a 00 00       	call   800f4d <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 68 10 00 00       	call   8014e3 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80048f:	e8 7b 0a 00 00       	call   800f0f <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
  8004c0:	83 c4 10             	add    $0x10,%esp
}
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 e0 11 00 00       	call   8016b5 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 ef 09 00 00       	call   800ece <sys_env_destroy>
  8004df:	83 c4 10             	add    $0x10,%esp
}
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 18 0a 00 00       	call   800f0f <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 c4 30 80 00       	push   $0x8030c4
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 f8 2f 80 00 	movl   $0x802ff8,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 37 09 00 00       	call   800e91 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 4f 01 00 00       	call   8006ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 dc 08 00 00       	call   800e91 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ef:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005fc:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8005ff:	72 05                	jb     800606 <printnum+0x35>
  800601:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800604:	77 3e                	ja     800644 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	ff 75 18             	pushl  0x18(%ebp)
  80060c:	83 eb 01             	sub    $0x1,%ebx
  80060f:	53                   	push   %ebx
  800610:	50                   	push   %eax
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 9b 26 00 00       	call   802cc0 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 13                	jmp    80064b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	85 db                	test   %ebx,%ebx
  800649:	7f ed                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	56                   	push   %esi
  80064f:	83 ec 04             	sub    $0x4,%esp
  800652:	ff 75 e4             	pushl  -0x1c(%ebp)
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	ff 75 dc             	pushl  -0x24(%ebp)
  80065b:	ff 75 d8             	pushl  -0x28(%ebp)
  80065e:	e8 8d 27 00 00       	call   802df0 <__umoddi3>
  800663:	83 c4 14             	add    $0x14,%esp
  800666:	0f be 80 e7 30 80 00 	movsbl 0x8030e7(%eax),%eax
  80066d:	50                   	push   %eax
  80066e:	ff d7                	call   *%edi
  800670:	83 c4 10             	add    $0x10,%esp
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067e:	83 fa 01             	cmp    $0x1,%edx
  800681:	7e 0e                	jle    800691 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800683:	8b 10                	mov    (%eax),%edx
  800685:	8d 4a 08             	lea    0x8(%edx),%ecx
  800688:	89 08                	mov    %ecx,(%eax)
  80068a:	8b 02                	mov    (%edx),%eax
  80068c:	8b 52 04             	mov    0x4(%edx),%edx
  80068f:	eb 22                	jmp    8006b3 <getuint+0x38>
	else if (lflag)
  800691:	85 d2                	test   %edx,%edx
  800693:	74 10                	je     8006a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800695:	8b 10                	mov    (%eax),%edx
  800697:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069a:	89 08                	mov    %ecx,(%eax)
  80069c:	8b 02                	mov    (%edx),%eax
  80069e:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a3:	eb 0e                	jmp    8006b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006aa:	89 08                	mov    %ecx,(%eax)
  8006ac:	8b 02                	mov    (%edx),%eax
  8006ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c4:	73 0a                	jae    8006d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c9:	89 08                	mov    %ecx,(%eax)
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	88 02                	mov    %al,(%edx)
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006db:	50                   	push   %eax
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	ff 75 08             	pushl  0x8(%ebp)
  8006e5:	e8 05 00 00 00       	call   8006ef <vprintfmt>
	va_end(ap);
  8006ea:	83 c4 10             	add    $0x10,%esp
}
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	57                   	push   %edi
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 2c             	sub    $0x2c,%esp
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800701:	eb 12                	jmp    800715 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800703:	85 c0                	test   %eax,%eax
  800705:	0f 84 90 03 00 00    	je     800a9b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	50                   	push   %eax
  800710:	ff d6                	call   *%esi
  800712:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800715:	83 c7 01             	add    $0x1,%edi
  800718:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071c:	83 f8 25             	cmp    $0x25,%eax
  80071f:	75 e2                	jne    800703 <vprintfmt+0x14>
  800721:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800725:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80072c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800733:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073a:	ba 00 00 00 00       	mov    $0x0,%edx
  80073f:	eb 07                	jmp    800748 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800744:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8d 47 01             	lea    0x1(%edi),%eax
  80074b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074e:	0f b6 07             	movzbl (%edi),%eax
  800751:	0f b6 c8             	movzbl %al,%ecx
  800754:	83 e8 23             	sub    $0x23,%eax
  800757:	3c 55                	cmp    $0x55,%al
  800759:	0f 87 21 03 00 00    	ja     800a80 <vprintfmt+0x391>
  80075f:	0f b6 c0             	movzbl %al,%eax
  800762:	ff 24 85 40 32 80 00 	jmp    *0x803240(,%eax,4)
  800769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80076c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800770:	eb d6                	jmp    800748 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800780:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800784:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800787:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078a:	83 fa 09             	cmp    $0x9,%edx
  80078d:	77 39                	ja     8007c8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800792:	eb e9                	jmp    80077d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 48 04             	lea    0x4(%eax),%ecx
  80079a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a5:	eb 27                	jmp    8007ce <vprintfmt+0xdf>
  8007a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b1:	0f 49 c8             	cmovns %eax,%ecx
  8007b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ba:	eb 8c                	jmp    800748 <vprintfmt+0x59>
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007c6:	eb 80                	jmp    800748 <vprintfmt+0x59>
  8007c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d2:	0f 89 70 ff ff ff    	jns    800748 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007e5:	e9 5e ff ff ff       	jmp    800748 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f0:	e9 53 ff ff ff       	jmp    800748 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	ff 30                	pushl  (%eax)
  800804:	ff d6                	call   *%esi
			break;
  800806:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80080c:	e9 04 ff ff ff       	jmp    800715 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	99                   	cltd   
  80081d:	31 d0                	xor    %edx,%eax
  80081f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800821:	83 f8 0f             	cmp    $0xf,%eax
  800824:	7f 0b                	jg     800831 <vprintfmt+0x142>
  800826:	8b 14 85 c0 33 80 00 	mov    0x8033c0(,%eax,4),%edx
  80082d:	85 d2                	test   %edx,%edx
  80082f:	75 18                	jne    800849 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800831:	50                   	push   %eax
  800832:	68 ff 30 80 00       	push   $0x8030ff
  800837:	53                   	push   %ebx
  800838:	56                   	push   %esi
  800839:	e8 94 fe ff ff       	call   8006d2 <printfmt>
  80083e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800844:	e9 cc fe ff ff       	jmp    800715 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800849:	52                   	push   %edx
  80084a:	68 31 36 80 00       	push   $0x803631
  80084f:	53                   	push   %ebx
  800850:	56                   	push   %esi
  800851:	e8 7c fe ff ff       	call   8006d2 <printfmt>
  800856:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085c:	e9 b4 fe ff ff       	jmp    800715 <vprintfmt+0x26>
  800861:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800864:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800867:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800875:	85 ff                	test   %edi,%edi
  800877:	ba f8 30 80 00       	mov    $0x8030f8,%edx
  80087c:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80087f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800883:	0f 84 92 00 00 00    	je     80091b <vprintfmt+0x22c>
  800889:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80088d:	0f 8e 96 00 00 00    	jle    800929 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	51                   	push   %ecx
  800897:	57                   	push   %edi
  800898:	e8 86 02 00 00       	call   800b23 <strnlen>
  80089d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008a0:	29 c1                	sub    %eax,%ecx
  8008a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b4:	eb 0f                	jmp    8008c5 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bf:	83 ef 01             	sub    $0x1,%edi
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 ff                	test   %edi,%edi
  8008c7:	7f ed                	jg     8008b6 <vprintfmt+0x1c7>
  8008c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008cc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cf:	85 c9                	test   %ecx,%ecx
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	0f 49 c1             	cmovns %ecx,%eax
  8008d9:	29 c1                	sub    %eax,%ecx
  8008db:	89 75 08             	mov    %esi,0x8(%ebp)
  8008de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e4:	89 cb                	mov    %ecx,%ebx
  8008e6:	eb 4d                	jmp    800935 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ec:	74 1b                	je     800909 <vprintfmt+0x21a>
  8008ee:	0f be c0             	movsbl %al,%eax
  8008f1:	83 e8 20             	sub    $0x20,%eax
  8008f4:	83 f8 5e             	cmp    $0x5e,%eax
  8008f7:	76 10                	jbe    800909 <vprintfmt+0x21a>
					putch('?', putdat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	ff 75 0c             	pushl  0xc(%ebp)
  8008ff:	6a 3f                	push   $0x3f
  800901:	ff 55 08             	call   *0x8(%ebp)
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 0d                	jmp    800916 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	52                   	push   %edx
  800910:	ff 55 08             	call   *0x8(%ebp)
  800913:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800916:	83 eb 01             	sub    $0x1,%ebx
  800919:	eb 1a                	jmp    800935 <vprintfmt+0x246>
  80091b:	89 75 08             	mov    %esi,0x8(%ebp)
  80091e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800921:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800924:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800927:	eb 0c                	jmp    800935 <vprintfmt+0x246>
  800929:	89 75 08             	mov    %esi,0x8(%ebp)
  80092c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800932:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800935:	83 c7 01             	add    $0x1,%edi
  800938:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093c:	0f be d0             	movsbl %al,%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 23                	je     800966 <vprintfmt+0x277>
  800943:	85 f6                	test   %esi,%esi
  800945:	78 a1                	js     8008e8 <vprintfmt+0x1f9>
  800947:	83 ee 01             	sub    $0x1,%esi
  80094a:	79 9c                	jns    8008e8 <vprintfmt+0x1f9>
  80094c:	89 df                	mov    %ebx,%edi
  80094e:	8b 75 08             	mov    0x8(%ebp),%esi
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800954:	eb 18                	jmp    80096e <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 20                	push   $0x20
  80095c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	eb 08                	jmp    80096e <vprintfmt+0x27f>
  800966:	89 df                	mov    %ebx,%edi
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096e:	85 ff                	test   %edi,%edi
  800970:	7f e4                	jg     800956 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800975:	e9 9b fd ff ff       	jmp    800715 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80097a:	83 fa 01             	cmp    $0x1,%edx
  80097d:	7e 16                	jle    800995 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	8d 50 08             	lea    0x8(%eax),%edx
  800985:	89 55 14             	mov    %edx,0x14(%ebp)
  800988:	8b 50 04             	mov    0x4(%eax),%edx
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800990:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800993:	eb 32                	jmp    8009c7 <vprintfmt+0x2d8>
	else if (lflag)
  800995:	85 d2                	test   %edx,%edx
  800997:	74 18                	je     8009b1 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8d 50 04             	lea    0x4(%eax),%edx
  80099f:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a7:	89 c1                	mov    %eax,%ecx
  8009a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009af:	eb 16                	jmp    8009c7 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8009b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b4:	8d 50 04             	lea    0x4(%eax),%edx
  8009b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ba:	8b 00                	mov    (%eax),%eax
  8009bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bf:	89 c1                	mov    %eax,%ecx
  8009c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d6:	79 74                	jns    800a4c <vprintfmt+0x35d>
				putch('-', putdat);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	53                   	push   %ebx
  8009dc:	6a 2d                	push   $0x2d
  8009de:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e6:	f7 d8                	neg    %eax
  8009e8:	83 d2 00             	adc    $0x0,%edx
  8009eb:	f7 da                	neg    %edx
  8009ed:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f5:	eb 55                	jmp    800a4c <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fa:	e8 7c fc ff ff       	call   80067b <getuint>
			base = 10;
  8009ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a04:	eb 46                	jmp    800a4c <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a06:	8d 45 14             	lea    0x14(%ebp),%eax
  800a09:	e8 6d fc ff ff       	call   80067b <getuint>
                        base = 8;
  800a0e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a13:	eb 37                	jmp    800a4c <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	53                   	push   %ebx
  800a19:	6a 30                	push   $0x30
  800a1b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1d:	83 c4 08             	add    $0x8,%esp
  800a20:	53                   	push   %ebx
  800a21:	6a 78                	push   $0x78
  800a23:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a25:	8b 45 14             	mov    0x14(%ebp),%eax
  800a28:	8d 50 04             	lea    0x4(%eax),%edx
  800a2b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2e:	8b 00                	mov    (%eax),%eax
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a35:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a38:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3d:	eb 0d                	jmp    800a4c <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a42:	e8 34 fc ff ff       	call   80067b <getuint>
			base = 16;
  800a47:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4c:	83 ec 0c             	sub    $0xc,%esp
  800a4f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a53:	57                   	push   %edi
  800a54:	ff 75 e0             	pushl  -0x20(%ebp)
  800a57:	51                   	push   %ecx
  800a58:	52                   	push   %edx
  800a59:	50                   	push   %eax
  800a5a:	89 da                	mov    %ebx,%edx
  800a5c:	89 f0                	mov    %esi,%eax
  800a5e:	e8 6e fb ff ff       	call   8005d1 <printnum>
			break;
  800a63:	83 c4 20             	add    $0x20,%esp
  800a66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a69:	e9 a7 fc ff ff       	jmp    800715 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6e:	83 ec 08             	sub    $0x8,%esp
  800a71:	53                   	push   %ebx
  800a72:	51                   	push   %ecx
  800a73:	ff d6                	call   *%esi
			break;
  800a75:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a7b:	e9 95 fc ff ff       	jmp    800715 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a80:	83 ec 08             	sub    $0x8,%esp
  800a83:	53                   	push   %ebx
  800a84:	6a 25                	push   $0x25
  800a86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a88:	83 c4 10             	add    $0x10,%esp
  800a8b:	eb 03                	jmp    800a90 <vprintfmt+0x3a1>
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a94:	75 f7                	jne    800a8d <vprintfmt+0x39e>
  800a96:	e9 7a fc ff ff       	jmp    800715 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	83 ec 18             	sub    $0x18,%esp
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	74 26                	je     800aea <vsnprintf+0x47>
  800ac4:	85 d2                	test   %edx,%edx
  800ac6:	7e 22                	jle    800aea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac8:	ff 75 14             	pushl  0x14(%ebp)
  800acb:	ff 75 10             	pushl  0x10(%ebp)
  800ace:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad1:	50                   	push   %eax
  800ad2:	68 b5 06 80 00       	push   $0x8006b5
  800ad7:	e8 13 fc ff ff       	call   8006ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800adf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	eb 05                	jmp    800aef <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800afa:	50                   	push   %eax
  800afb:	ff 75 10             	pushl  0x10(%ebp)
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	ff 75 08             	pushl  0x8(%ebp)
  800b04:	e8 9a ff ff ff       	call   800aa3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb 03                	jmp    800b1b <strlen+0x10>
		n++;
  800b18:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b1b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1f:	75 f7                	jne    800b18 <strlen+0xd>
		n++;
	return n;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	eb 03                	jmp    800b36 <strnlen+0x13>
		n++;
  800b33:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b36:	39 c2                	cmp    %eax,%edx
  800b38:	74 08                	je     800b42 <strnlen+0x1f>
  800b3a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3e:	75 f3                	jne    800b33 <strnlen+0x10>
  800b40:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b5a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5d:	84 db                	test   %bl,%bl
  800b5f:	75 ef                	jne    800b50 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b61:	5b                   	pop    %ebx
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	53                   	push   %ebx
  800b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b6b:	53                   	push   %ebx
  800b6c:	e8 9a ff ff ff       	call   800b0b <strlen>
  800b71:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b74:	ff 75 0c             	pushl  0xc(%ebp)
  800b77:	01 d8                	add    %ebx,%eax
  800b79:	50                   	push   %eax
  800b7a:	e8 c5 ff ff ff       	call   800b44 <strcpy>
	return dst;
}
  800b7f:	89 d8                	mov    %ebx,%eax
  800b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b96:	89 f2                	mov    %esi,%edx
  800b98:	eb 0f                	jmp    800ba9 <strncpy+0x23>
		*dst++ = *src;
  800b9a:	83 c2 01             	add    $0x1,%edx
  800b9d:	0f b6 01             	movzbl (%ecx),%eax
  800ba0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba3:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba9:	39 da                	cmp    %ebx,%edx
  800bab:	75 ed                	jne    800b9a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 10             	mov    0x10(%ebp),%edx
  800bc1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc3:	85 d2                	test   %edx,%edx
  800bc5:	74 21                	je     800be8 <strlcpy+0x35>
  800bc7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bcb:	89 f2                	mov    %esi,%edx
  800bcd:	eb 09                	jmp    800bd8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd8:	39 c2                	cmp    %eax,%edx
  800bda:	74 09                	je     800be5 <strlcpy+0x32>
  800bdc:	0f b6 19             	movzbl (%ecx),%ebx
  800bdf:	84 db                	test   %bl,%bl
  800be1:	75 ec                	jne    800bcf <strlcpy+0x1c>
  800be3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be8:	29 f0                	sub    %esi,%eax
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf7:	eb 06                	jmp    800bff <strcmp+0x11>
		p++, q++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bff:	0f b6 01             	movzbl (%ecx),%eax
  800c02:	84 c0                	test   %al,%al
  800c04:	74 04                	je     800c0a <strcmp+0x1c>
  800c06:	3a 02                	cmp    (%edx),%al
  800c08:	74 ef                	je     800bf9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c0a:	0f b6 c0             	movzbl %al,%eax
  800c0d:	0f b6 12             	movzbl (%edx),%edx
  800c10:	29 d0                	sub    %edx,%eax
}
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 c3                	mov    %eax,%ebx
  800c20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c23:	eb 06                	jmp    800c2b <strncmp+0x17>
		n--, p++, q++;
  800c25:	83 c0 01             	add    $0x1,%eax
  800c28:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c2b:	39 d8                	cmp    %ebx,%eax
  800c2d:	74 15                	je     800c44 <strncmp+0x30>
  800c2f:	0f b6 08             	movzbl (%eax),%ecx
  800c32:	84 c9                	test   %cl,%cl
  800c34:	74 04                	je     800c3a <strncmp+0x26>
  800c36:	3a 0a                	cmp    (%edx),%cl
  800c38:	74 eb                	je     800c25 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3a:	0f b6 00             	movzbl (%eax),%eax
  800c3d:	0f b6 12             	movzbl (%edx),%edx
  800c40:	29 d0                	sub    %edx,%eax
  800c42:	eb 05                	jmp    800c49 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c56:	eb 07                	jmp    800c5f <strchr+0x13>
		if (*s == c)
  800c58:	38 ca                	cmp    %cl,%dl
  800c5a:	74 0f                	je     800c6b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	0f b6 10             	movzbl (%eax),%edx
  800c62:	84 d2                	test   %dl,%dl
  800c64:	75 f2                	jne    800c58 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c77:	eb 03                	jmp    800c7c <strfind+0xf>
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7f:	84 d2                	test   %dl,%dl
  800c81:	74 04                	je     800c87 <strfind+0x1a>
  800c83:	38 ca                	cmp    %cl,%dl
  800c85:	75 f2                	jne    800c79 <strfind+0xc>
			break;
	return (char *) s;
}
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c95:	85 c9                	test   %ecx,%ecx
  800c97:	74 36                	je     800ccf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9f:	75 28                	jne    800cc9 <memset+0x40>
  800ca1:	f6 c1 03             	test   $0x3,%cl
  800ca4:	75 23                	jne    800cc9 <memset+0x40>
		c &= 0xFF;
  800ca6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	c1 e3 08             	shl    $0x8,%ebx
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	c1 e6 18             	shl    $0x18,%esi
  800cb4:	89 d0                	mov    %edx,%eax
  800cb6:	c1 e0 10             	shl    $0x10,%eax
  800cb9:	09 f0                	or     %esi,%eax
  800cbb:	09 c2                	or     %eax,%edx
  800cbd:	89 d0                	mov    %edx,%eax
  800cbf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cc1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cc4:	fc                   	cld    
  800cc5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc7:	eb 06                	jmp    800ccf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	fc                   	cld    
  800ccd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccf:	89 f8                	mov    %edi,%eax
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce4:	39 c6                	cmp    %eax,%esi
  800ce6:	73 35                	jae    800d1d <memmove+0x47>
  800ce8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ceb:	39 d0                	cmp    %edx,%eax
  800ced:	73 2e                	jae    800d1d <memmove+0x47>
		s += n;
		d += n;
  800cef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cf2:	89 d6                	mov    %edx,%esi
  800cf4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 13                	jne    800d11 <memmove+0x3b>
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 0e                	jne    800d11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d03:	83 ef 04             	sub    $0x4,%edi
  800d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d09:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d0c:	fd                   	std    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb 09                	jmp    800d1a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d11:	83 ef 01             	sub    $0x1,%edi
  800d14:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d17:	fd                   	std    
  800d18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d1a:	fc                   	cld    
  800d1b:	eb 1d                	jmp    800d3a <memmove+0x64>
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d21:	f6 c2 03             	test   $0x3,%dl
  800d24:	75 0f                	jne    800d35 <memmove+0x5f>
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 0a                	jne    800d35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	fc                   	cld    
  800d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d33:	eb 05                	jmp    800d3a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d35:	89 c7                	mov    %eax,%edi
  800d37:	fc                   	cld    
  800d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d41:	ff 75 10             	pushl  0x10(%ebp)
  800d44:	ff 75 0c             	pushl  0xc(%ebp)
  800d47:	ff 75 08             	pushl  0x8(%ebp)
  800d4a:	e8 87 ff ff ff       	call   800cd6 <memmove>
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 c6                	mov    %eax,%esi
  800d5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d61:	eb 1a                	jmp    800d7d <memcmp+0x2c>
		if (*s1 != *s2)
  800d63:	0f b6 08             	movzbl (%eax),%ecx
  800d66:	0f b6 1a             	movzbl (%edx),%ebx
  800d69:	38 d9                	cmp    %bl,%cl
  800d6b:	74 0a                	je     800d77 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6d:	0f b6 c1             	movzbl %cl,%eax
  800d70:	0f b6 db             	movzbl %bl,%ebx
  800d73:	29 d8                	sub    %ebx,%eax
  800d75:	eb 0f                	jmp    800d86 <memcmp+0x35>
		s1++, s2++;
  800d77:	83 c0 01             	add    $0x1,%eax
  800d7a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7d:	39 f0                	cmp    %esi,%eax
  800d7f:	75 e2                	jne    800d63 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d98:	eb 07                	jmp    800da1 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	38 08                	cmp    %cl,(%eax)
  800d9c:	74 07                	je     800da5 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d9e:	83 c0 01             	add    $0x1,%eax
  800da1:	39 d0                	cmp    %edx,%eax
  800da3:	72 f5                	jb     800d9a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db3:	eb 03                	jmp    800db8 <strtol+0x11>
		s++;
  800db5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db8:	0f b6 01             	movzbl (%ecx),%eax
  800dbb:	3c 09                	cmp    $0x9,%al
  800dbd:	74 f6                	je     800db5 <strtol+0xe>
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f2                	je     800db5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc3:	3c 2b                	cmp    $0x2b,%al
  800dc5:	75 0a                	jne    800dd1 <strtol+0x2a>
		s++;
  800dc7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dca:	bf 00 00 00 00       	mov    $0x0,%edi
  800dcf:	eb 10                	jmp    800de1 <strtol+0x3a>
  800dd1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dd6:	3c 2d                	cmp    $0x2d,%al
  800dd8:	75 07                	jne    800de1 <strtol+0x3a>
		s++, neg = 1;
  800dda:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ddd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de1:	85 db                	test   %ebx,%ebx
  800de3:	0f 94 c0             	sete   %al
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 19                	jne    800e07 <strtol+0x60>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 14                	jne    800e07 <strtol+0x60>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	0f 85 82 00 00 00    	jne    800e7f <strtol+0xd8>
		s += 2, base = 16;
  800dfd:	83 c1 02             	add    $0x2,%ecx
  800e00:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e05:	eb 16                	jmp    800e1d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e07:	84 c0                	test   %al,%al
  800e09:	74 12                	je     800e1d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e0b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e10:	80 39 30             	cmpb   $0x30,(%ecx)
  800e13:	75 08                	jne    800e1d <strtol+0x76>
		s++, base = 8;
  800e15:	83 c1 01             	add    $0x1,%ecx
  800e18:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e22:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e25:	0f b6 11             	movzbl (%ecx),%edx
  800e28:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	80 fb 09             	cmp    $0x9,%bl
  800e30:	77 08                	ja     800e3a <strtol+0x93>
			dig = *s - '0';
  800e32:	0f be d2             	movsbl %dl,%edx
  800e35:	83 ea 30             	sub    $0x30,%edx
  800e38:	eb 22                	jmp    800e5c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800e3a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e3d:	89 f3                	mov    %esi,%ebx
  800e3f:	80 fb 19             	cmp    $0x19,%bl
  800e42:	77 08                	ja     800e4c <strtol+0xa5>
			dig = *s - 'a' + 10;
  800e44:	0f be d2             	movsbl %dl,%edx
  800e47:	83 ea 57             	sub    $0x57,%edx
  800e4a:	eb 10                	jmp    800e5c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800e4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4f:	89 f3                	mov    %esi,%ebx
  800e51:	80 fb 19             	cmp    $0x19,%bl
  800e54:	77 16                	ja     800e6c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e56:	0f be d2             	movsbl %dl,%edx
  800e59:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5f:	7d 0f                	jge    800e70 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800e61:	83 c1 01             	add    $0x1,%ecx
  800e64:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e68:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e6a:	eb b9                	jmp    800e25 <strtol+0x7e>
  800e6c:	89 c2                	mov    %eax,%edx
  800e6e:	eb 02                	jmp    800e72 <strtol+0xcb>
  800e70:	89 c2                	mov    %eax,%edx

	if (endptr)
  800e72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e76:	74 0d                	je     800e85 <strtol+0xde>
		*endptr = (char *) s;
  800e78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e7b:	89 0e                	mov    %ecx,(%esi)
  800e7d:	eb 06                	jmp    800e85 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7f:	84 c0                	test   %al,%al
  800e81:	75 92                	jne    800e15 <strtol+0x6e>
  800e83:	eb 98                	jmp    800e1d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e85:	f7 da                	neg    %edx
  800e87:	85 ff                	test   %edi,%edi
  800e89:	0f 45 c2             	cmovne %edx,%eax
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e97:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 c3                	mov    %eax,%ebx
  800ea4:	89 c7                	mov    %eax,%edi
  800ea6:	89 c6                	mov    %eax,%esi
  800ea8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_cgetc>:

int
sys_cgetc(void)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eba:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebf:	89 d1                	mov    %edx,%ecx
  800ec1:	89 d3                	mov    %edx,%ebx
  800ec3:	89 d7                	mov    %edx,%edi
  800ec5:	89 d6                	mov    %edx,%esi
  800ec7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ed7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 cb                	mov    %ecx,%ebx
  800ee6:	89 cf                	mov    %ecx,%edi
  800ee8:	89 ce                	mov    %ecx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 17                	jle    800f07 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	50                   	push   %eax
  800ef4:	6a 03                	push   $0x3
  800ef6:	68 1f 34 80 00       	push   $0x80341f
  800efb:	6a 22                	push   $0x22
  800efd:	68 3c 34 80 00       	push   $0x80343c
  800f02:	e8 dd f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f15:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1f:	89 d1                	mov    %edx,%ecx
  800f21:	89 d3                	mov    %edx,%ebx
  800f23:	89 d7                	mov    %edx,%edi
  800f25:	89 d6                	mov    %edx,%esi
  800f27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <sys_yield>:

void
sys_yield(void)
{      
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f34:	ba 00 00 00 00       	mov    $0x0,%edx
  800f39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f3e:	89 d1                	mov    %edx,%ecx
  800f40:	89 d3                	mov    %edx,%ebx
  800f42:	89 d7                	mov    %edx,%edi
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f56:	be 00 00 00 00       	mov    $0x0,%esi
  800f5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f69:	89 f7                	mov    %esi,%edi
  800f6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 17                	jle    800f88 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	50                   	push   %eax
  800f75:	6a 04                	push   $0x4
  800f77:	68 1f 34 80 00       	push   $0x80341f
  800f7c:	6a 22                	push   $0x22
  800f7e:	68 3c 34 80 00       	push   $0x80343c
  800f83:	e8 5c f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f99:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800faa:	8b 75 18             	mov    0x18(%ebp),%esi
  800fad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7e 17                	jle    800fca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	50                   	push   %eax
  800fb7:	6a 05                	push   $0x5
  800fb9:	68 1f 34 80 00       	push   $0x80341f
  800fbe:	6a 22                	push   $0x22
  800fc0:	68 3c 34 80 00       	push   $0x80343c
  800fc5:	e8 1a f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe0:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe8:	8b 55 08             	mov    0x8(%ebp),%edx
  800feb:	89 df                	mov    %ebx,%edi
  800fed:	89 de                	mov    %ebx,%esi
  800fef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 17                	jle    80100c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 06                	push   $0x6
  800ffb:	68 1f 34 80 00       	push   $0x80341f
  801000:	6a 22                	push   $0x22
  801002:	68 3c 34 80 00       	push   $0x80343c
  801007:	e8 d8 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801022:	b8 08 00 00 00       	mov    $0x8,%eax
  801027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 df                	mov    %ebx,%edi
  80102f:	89 de                	mov    %ebx,%esi
  801031:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	7e 17                	jle    80104e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	50                   	push   %eax
  80103b:	6a 08                	push   $0x8
  80103d:	68 1f 34 80 00       	push   $0x80341f
  801042:	6a 22                	push   $0x22
  801044:	68 3c 34 80 00       	push   $0x80343c
  801049:	e8 96 f4 ff ff       	call   8004e4 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  80104e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801064:	b8 09 00 00 00       	mov    $0x9,%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	89 df                	mov    %ebx,%edi
  801071:	89 de                	mov    %ebx,%esi
  801073:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801075:	85 c0                	test   %eax,%eax
  801077:	7e 17                	jle    801090 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 09                	push   $0x9
  80107f:	68 1f 34 80 00       	push   $0x80341f
  801084:	6a 22                	push   $0x22
  801086:	68 3c 34 80 00       	push   $0x80343c
  80108b:	e8 54 f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	89 df                	mov    %ebx,%edi
  8010b3:	89 de                	mov    %ebx,%esi
  8010b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	7e 17                	jle    8010d2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	50                   	push   %eax
  8010bf:	6a 0a                	push   $0xa
  8010c1:	68 1f 34 80 00       	push   $0x80341f
  8010c6:	6a 22                	push   $0x22
  8010c8:	68 3c 34 80 00       	push   $0x80343c
  8010cd:	e8 12 f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010e0:	be 00 00 00 00       	mov    $0x0,%esi
  8010e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	57                   	push   %edi
  801101:	56                   	push   %esi
  801102:	53                   	push   %ebx
  801103:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801110:	8b 55 08             	mov    0x8(%ebp),%edx
  801113:	89 cb                	mov    %ecx,%ebx
  801115:	89 cf                	mov    %ecx,%edi
  801117:	89 ce                	mov    %ecx,%esi
  801119:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111b:	85 c0                	test   %eax,%eax
  80111d:	7e 17                	jle    801136 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	50                   	push   %eax
  801123:	6a 0d                	push   $0xd
  801125:	68 1f 34 80 00       	push   $0x80341f
  80112a:	6a 22                	push   $0x22
  80112c:	68 3c 34 80 00       	push   $0x80343c
  801131:	e8 ae f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	b8 0e 00 00 00       	mov    $0xe,%eax
  80114e:	89 d1                	mov    %edx,%ecx
  801150:	89 d3                	mov    %edx,%ebx
  801152:	89 d7                	mov    %edx,%edi
  801154:	89 d6                	mov    %edx,%esi
  801156:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_transmit>:

int
sys_transmit(void *addr)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801166:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801170:	8b 55 08             	mov    0x8(%ebp),%edx
  801173:	89 cb                	mov    %ecx,%ebx
  801175:	89 cf                	mov    %ecx,%edi
  801177:	89 ce                	mov    %ecx,%esi
  801179:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	7e 17                	jle    801196 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	50                   	push   %eax
  801183:	6a 0f                	push   $0xf
  801185:	68 1f 34 80 00       	push   $0x80341f
  80118a:	6a 22                	push   $0x22
  80118c:	68 3c 34 80 00       	push   $0x80343c
  801191:	e8 4e f3 ff ff       	call   8004e4 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_recv>:

int
sys_recv(void *addr)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8011a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	89 cb                	mov    %ecx,%ebx
  8011b6:	89 cf                	mov    %ecx,%edi
  8011b8:	89 ce                	mov    %ecx,%esi
  8011ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 17                	jle    8011d7 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	83 ec 0c             	sub    $0xc,%esp
  8011c3:	50                   	push   %eax
  8011c4:	6a 10                	push   $0x10
  8011c6:	68 1f 34 80 00       	push   $0x80341f
  8011cb:	6a 22                	push   $0x22
  8011cd:	68 3c 34 80 00       	push   $0x80343c
  8011d2:	e8 0d f3 ff ff       	call   8004e4 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8011e9:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  8011eb:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  8011ef:	74 2e                	je     80121f <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 16             	shr    $0x16,%edx
  8011f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 1d                	je     80121f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801202:	89 c2                	mov    %eax,%edx
  801204:	c1 ea 0c             	shr    $0xc,%edx
  801207:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80120e:	f6 c1 01             	test   $0x1,%cl
  801211:	74 0c                	je     80121f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801213:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  80121a:	f6 c6 08             	test   $0x8,%dh
  80121d:	75 14                	jne    801233 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	68 4c 34 80 00       	push   $0x80344c
  801227:	6a 21                	push   $0x21
  801229:	68 df 34 80 00       	push   $0x8034df
  80122e:	e8 b1 f2 ff ff       	call   8004e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  801233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801238:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	6a 07                	push   $0x7
  80123f:	68 00 f0 7f 00       	push   $0x7ff000
  801244:	6a 00                	push   $0x0
  801246:	e8 02 fd ff ff       	call   800f4d <sys_page_alloc>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	79 14                	jns    801266 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	68 ea 34 80 00       	push   $0x8034ea
  80125a:	6a 2b                	push   $0x2b
  80125c:	68 df 34 80 00       	push   $0x8034df
  801261:	e8 7e f2 ff ff       	call   8004e4 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	68 00 10 00 00       	push   $0x1000
  80126e:	53                   	push   %ebx
  80126f:	68 00 f0 7f 00       	push   $0x7ff000
  801274:	e8 5d fa ff ff       	call   800cd6 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  801279:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801280:	53                   	push   %ebx
  801281:	6a 00                	push   $0x0
  801283:	68 00 f0 7f 00       	push   $0x7ff000
  801288:	6a 00                	push   $0x0
  80128a:	e8 01 fd ff ff       	call   800f90 <sys_page_map>
  80128f:	83 c4 20             	add    $0x20,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	79 14                	jns    8012aa <pgfault+0xcb>
                panic("sys_page_map fails\n");
  801296:	83 ec 04             	sub    $0x4,%esp
  801299:	68 00 35 80 00       	push   $0x803500
  80129e:	6a 2e                	push   $0x2e
  8012a0:	68 df 34 80 00       	push   $0x8034df
  8012a5:	e8 3a f2 ff ff       	call   8004e4 <_panic>
        sys_page_unmap(0, PFTEMP); 
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	68 00 f0 7f 00       	push   $0x7ff000
  8012b2:	6a 00                	push   $0x0
  8012b4:	e8 19 fd ff ff       	call   800fd2 <sys_page_unmap>
  8012b9:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	57                   	push   %edi
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  8012ca:	68 df 11 80 00       	push   $0x8011df
  8012cf:	e8 1e 18 00 00       	call   802af2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012d4:	b8 07 00 00 00       	mov    $0x7,%eax
  8012d9:	cd 30                	int    $0x30
  8012db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 12                	jns    8012f7 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  8012e5:	50                   	push   %eax
  8012e6:	68 14 35 80 00       	push   $0x803514
  8012eb:	6a 6d                	push   $0x6d
  8012ed:	68 df 34 80 00       	push   $0x8034df
  8012f2:	e8 ed f1 ff ff       	call   8004e4 <_panic>
  8012f7:	89 c7                	mov    %eax,%edi
  8012f9:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  8012fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801302:	75 21                	jne    801325 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801304:	e8 06 fc ff ff       	call   800f0f <sys_getenvid>
  801309:	25 ff 03 00 00       	and    $0x3ff,%eax
  80130e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801311:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801316:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
  801320:	e9 9c 01 00 00       	jmp    8014c1 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801325:	89 d8                	mov    %ebx,%eax
  801327:	c1 e8 16             	shr    $0x16,%eax
  80132a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801331:	a8 01                	test   $0x1,%al
  801333:	0f 84 f3 00 00 00    	je     80142c <fork+0x16b>
  801339:	89 d8                	mov    %ebx,%eax
  80133b:	c1 e8 0c             	shr    $0xc,%eax
  80133e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801345:	f6 c2 01             	test   $0x1,%dl
  801348:	0f 84 de 00 00 00    	je     80142c <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  80134e:	89 c6                	mov    %eax,%esi
  801350:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801353:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135a:	f6 c6 04             	test   $0x4,%dh
  80135d:	74 37                	je     801396 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  80135f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	25 07 0e 00 00       	and    $0xe07,%eax
  80136e:	50                   	push   %eax
  80136f:	56                   	push   %esi
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	6a 00                	push   $0x0
  801374:	e8 17 fc ff ff       	call   800f90 <sys_page_map>
  801379:	83 c4 20             	add    $0x20,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	0f 89 a8 00 00 00    	jns    80142c <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801384:	50                   	push   %eax
  801385:	68 70 34 80 00       	push   $0x803470
  80138a:	6a 49                	push   $0x49
  80138c:	68 df 34 80 00       	push   $0x8034df
  801391:	e8 4e f1 ff ff       	call   8004e4 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801396:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139d:	f6 c6 08             	test   $0x8,%dh
  8013a0:	75 0b                	jne    8013ad <fork+0xec>
  8013a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a9:	a8 02                	test   $0x2,%al
  8013ab:	74 57                	je     801404 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	68 05 08 00 00       	push   $0x805
  8013b5:	56                   	push   %esi
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 d1 fb ff ff       	call   800f90 <sys_page_map>
  8013bf:	83 c4 20             	add    $0x20,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	79 12                	jns    8013d8 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8013c6:	50                   	push   %eax
  8013c7:	68 70 34 80 00       	push   $0x803470
  8013cc:	6a 4c                	push   $0x4c
  8013ce:	68 df 34 80 00       	push   $0x8034df
  8013d3:	e8 0c f1 ff ff       	call   8004e4 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	68 05 08 00 00       	push   $0x805
  8013e0:	56                   	push   %esi
  8013e1:	6a 00                	push   $0x0
  8013e3:	56                   	push   %esi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 a5 fb ff ff       	call   800f90 <sys_page_map>
  8013eb:	83 c4 20             	add    $0x20,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	79 3a                	jns    80142c <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  8013f2:	50                   	push   %eax
  8013f3:	68 94 34 80 00       	push   $0x803494
  8013f8:	6a 4e                	push   $0x4e
  8013fa:	68 df 34 80 00       	push   $0x8034df
  8013ff:	e8 e0 f0 ff ff       	call   8004e4 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	6a 05                	push   $0x5
  801409:	56                   	push   %esi
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	6a 00                	push   $0x0
  80140e:	e8 7d fb ff ff       	call   800f90 <sys_page_map>
  801413:	83 c4 20             	add    $0x20,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	79 12                	jns    80142c <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80141a:	50                   	push   %eax
  80141b:	68 bc 34 80 00       	push   $0x8034bc
  801420:	6a 50                	push   $0x50
  801422:	68 df 34 80 00       	push   $0x8034df
  801427:	e8 b8 f0 ff ff       	call   8004e4 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80142c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801432:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801438:	0f 85 e7 fe ff ff    	jne    801325 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80143e:	83 ec 04             	sub    $0x4,%esp
  801441:	6a 07                	push   $0x7
  801443:	68 00 f0 bf ee       	push   $0xeebff000
  801448:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144b:	e8 fd fa ff ff       	call   800f4d <sys_page_alloc>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	79 14                	jns    80146b <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	68 24 35 80 00       	push   $0x803524
  80145f:	6a 76                	push   $0x76
  801461:	68 df 34 80 00       	push   $0x8034df
  801466:	e8 79 f0 ff ff       	call   8004e4 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	68 61 2b 80 00       	push   $0x802b61
  801473:	ff 75 e4             	pushl  -0x1c(%ebp)
  801476:	e8 1d fc ff ff       	call   801098 <sys_env_set_pgfault_upcall>
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	79 14                	jns    801496 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801482:	ff 75 e4             	pushl  -0x1c(%ebp)
  801485:	68 3e 35 80 00       	push   $0x80353e
  80148a:	6a 79                	push   $0x79
  80148c:	68 df 34 80 00       	push   $0x8034df
  801491:	e8 4e f0 ff ff       	call   8004e4 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	6a 02                	push   $0x2
  80149b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149e:	e8 71 fb ff ff       	call   801014 <sys_env_set_status>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	79 14                	jns    8014be <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8014aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ad:	68 5b 35 80 00       	push   $0x80355b
  8014b2:	6a 7b                	push   $0x7b
  8014b4:	68 df 34 80 00       	push   $0x8034df
  8014b9:	e8 26 f0 ff ff       	call   8004e4 <_panic>
        return forkid;
  8014be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8014c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <sfork>:

// Challenge!
int
sfork(void)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014cf:	68 72 35 80 00       	push   $0x803572
  8014d4:	68 83 00 00 00       	push   $0x83
  8014d9:	68 df 34 80 00       	push   $0x8034df
  8014de:	e8 01 f0 ff ff       	call   8004e4 <_panic>

008014e3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ee:	c1 e8 0c             	shr    $0xc,%eax
}
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8014fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801503:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801510:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801515:	89 c2                	mov    %eax,%edx
  801517:	c1 ea 16             	shr    $0x16,%edx
  80151a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801521:	f6 c2 01             	test   $0x1,%dl
  801524:	74 11                	je     801537 <fd_alloc+0x2d>
  801526:	89 c2                	mov    %eax,%edx
  801528:	c1 ea 0c             	shr    $0xc,%edx
  80152b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801532:	f6 c2 01             	test   $0x1,%dl
  801535:	75 09                	jne    801540 <fd_alloc+0x36>
			*fd_store = fd;
  801537:	89 01                	mov    %eax,(%ecx)
			return 0;
  801539:	b8 00 00 00 00       	mov    $0x0,%eax
  80153e:	eb 17                	jmp    801557 <fd_alloc+0x4d>
  801540:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801545:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154a:	75 c9                	jne    801515 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80154c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801552:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80155f:	83 f8 1f             	cmp    $0x1f,%eax
  801562:	77 36                	ja     80159a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801564:	c1 e0 0c             	shl    $0xc,%eax
  801567:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	c1 ea 16             	shr    $0x16,%edx
  801571:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801578:	f6 c2 01             	test   $0x1,%dl
  80157b:	74 24                	je     8015a1 <fd_lookup+0x48>
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	c1 ea 0c             	shr    $0xc,%edx
  801582:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801589:	f6 c2 01             	test   $0x1,%dl
  80158c:	74 1a                	je     8015a8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80158e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801591:	89 02                	mov    %eax,(%edx)
	return 0;
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
  801598:	eb 13                	jmp    8015ad <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159f:	eb 0c                	jmp    8015ad <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a6:	eb 05                	jmp    8015ad <fd_lookup+0x54>
  8015a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	eb 13                	jmp    8015d2 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8015bf:	39 08                	cmp    %ecx,(%eax)
  8015c1:	75 0c                	jne    8015cf <dev_lookup+0x20>
			*dev = devtab[i];
  8015c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cd:	eb 36                	jmp    801605 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015cf:	83 c2 01             	add    $0x1,%edx
  8015d2:	8b 04 95 04 36 80 00 	mov    0x803604(,%edx,4),%eax
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	75 e2                	jne    8015bf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015dd:	a1 08 50 80 00       	mov    0x805008,%eax
  8015e2:	8b 40 48             	mov    0x48(%eax),%eax
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	51                   	push   %ecx
  8015e9:	50                   	push   %eax
  8015ea:	68 88 35 80 00       	push   $0x803588
  8015ef:	e8 c9 ef ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8015f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 10             	sub    $0x10,%esp
  80160f:	8b 75 08             	mov    0x8(%ebp),%esi
  801612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801619:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80161f:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801622:	50                   	push   %eax
  801623:	e8 31 ff ff ff       	call   801559 <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 05                	js     801634 <fd_close+0x2d>
	    || fd != fd2)
  80162f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801632:	74 0c                	je     801640 <fd_close+0x39>
		return (must_exist ? r : 0);
  801634:	84 db                	test   %bl,%bl
  801636:	ba 00 00 00 00       	mov    $0x0,%edx
  80163b:	0f 44 c2             	cmove  %edx,%eax
  80163e:	eb 41                	jmp    801681 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	ff 36                	pushl  (%esi)
  801649:	e8 61 ff ff ff       	call   8015af <dev_lookup>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 1a                	js     801671 <fd_close+0x6a>
		if (dev->dev_close)
  801657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80165d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801662:	85 c0                	test   %eax,%eax
  801664:	74 0b                	je     801671 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	56                   	push   %esi
  80166a:	ff d0                	call   *%eax
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	56                   	push   %esi
  801675:	6a 00                	push   $0x0
  801677:	e8 56 f9 ff ff       	call   800fd2 <sys_page_unmap>
	return r;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	89 d8                	mov    %ebx,%eax
}
  801681:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	ff 75 08             	pushl  0x8(%ebp)
  801695:	e8 bf fe ff ff       	call   801559 <fd_lookup>
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	85 d2                	test   %edx,%edx
  8016a1:	78 10                	js     8016b3 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	6a 01                	push   $0x1
  8016a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ab:	e8 57 ff ff ff       	call   801607 <fd_close>
  8016b0:	83 c4 10             	add    $0x10,%esp
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <close_all>:

void
close_all(void)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	53                   	push   %ebx
  8016c5:	e8 be ff ff ff       	call   801688 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ca:	83 c3 01             	add    $0x1,%ebx
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	83 fb 20             	cmp    $0x20,%ebx
  8016d3:	75 ec                	jne    8016c1 <close_all+0xc>
		close(i);
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	57                   	push   %edi
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 2c             	sub    $0x2c,%esp
  8016e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 08             	pushl  0x8(%ebp)
  8016ed:	e8 67 fe ff ff       	call   801559 <fd_lookup>
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	85 d2                	test   %edx,%edx
  8016f9:	0f 88 c1 00 00 00    	js     8017c0 <dup+0xe6>
		return r;
	close(newfdnum);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	56                   	push   %esi
  801703:	e8 80 ff ff ff       	call   801688 <close>

	newfd = INDEX2FD(newfdnum);
  801708:	89 f3                	mov    %esi,%ebx
  80170a:	c1 e3 0c             	shl    $0xc,%ebx
  80170d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801713:	83 c4 04             	add    $0x4,%esp
  801716:	ff 75 e4             	pushl  -0x1c(%ebp)
  801719:	e8 d5 fd ff ff       	call   8014f3 <fd2data>
  80171e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801720:	89 1c 24             	mov    %ebx,(%esp)
  801723:	e8 cb fd ff ff       	call   8014f3 <fd2data>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80172e:	89 f8                	mov    %edi,%eax
  801730:	c1 e8 16             	shr    $0x16,%eax
  801733:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80173a:	a8 01                	test   $0x1,%al
  80173c:	74 37                	je     801775 <dup+0x9b>
  80173e:	89 f8                	mov    %edi,%eax
  801740:	c1 e8 0c             	shr    $0xc,%eax
  801743:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80174a:	f6 c2 01             	test   $0x1,%dl
  80174d:	74 26                	je     801775 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80174f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	25 07 0e 00 00       	and    $0xe07,%eax
  80175e:	50                   	push   %eax
  80175f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801762:	6a 00                	push   $0x0
  801764:	57                   	push   %edi
  801765:	6a 00                	push   $0x0
  801767:	e8 24 f8 ff ff       	call   800f90 <sys_page_map>
  80176c:	89 c7                	mov    %eax,%edi
  80176e:	83 c4 20             	add    $0x20,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 2e                	js     8017a3 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801775:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801778:	89 d0                	mov    %edx,%eax
  80177a:	c1 e8 0c             	shr    $0xc,%eax
  80177d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	25 07 0e 00 00       	and    $0xe07,%eax
  80178c:	50                   	push   %eax
  80178d:	53                   	push   %ebx
  80178e:	6a 00                	push   $0x0
  801790:	52                   	push   %edx
  801791:	6a 00                	push   $0x0
  801793:	e8 f8 f7 ff ff       	call   800f90 <sys_page_map>
  801798:	89 c7                	mov    %eax,%edi
  80179a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80179d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80179f:	85 ff                	test   %edi,%edi
  8017a1:	79 1d                	jns    8017c0 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	53                   	push   %ebx
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 24 f8 ff ff       	call   800fd2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ae:	83 c4 08             	add    $0x8,%esp
  8017b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 17 f8 ff ff       	call   800fd2 <sys_page_unmap>
	return r;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	89 f8                	mov    %edi,%eax
}
  8017c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 14             	sub    $0x14,%esp
  8017cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d5:	50                   	push   %eax
  8017d6:	53                   	push   %ebx
  8017d7:	e8 7d fd ff ff       	call   801559 <fd_lookup>
  8017dc:	83 c4 08             	add    $0x8,%esp
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 6d                	js     801852 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	ff 30                	pushl  (%eax)
  8017f1:	e8 b9 fd ff ff       	call   8015af <dev_lookup>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 4c                	js     801849 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801800:	8b 42 08             	mov    0x8(%edx),%eax
  801803:	83 e0 03             	and    $0x3,%eax
  801806:	83 f8 01             	cmp    $0x1,%eax
  801809:	75 21                	jne    80182c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180b:	a1 08 50 80 00       	mov    0x805008,%eax
  801810:	8b 40 48             	mov    0x48(%eax),%eax
  801813:	83 ec 04             	sub    $0x4,%esp
  801816:	53                   	push   %ebx
  801817:	50                   	push   %eax
  801818:	68 c9 35 80 00       	push   $0x8035c9
  80181d:	e8 9b ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182a:	eb 26                	jmp    801852 <read+0x8a>
	}
	if (!dev->dev_read)
  80182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182f:	8b 40 08             	mov    0x8(%eax),%eax
  801832:	85 c0                	test   %eax,%eax
  801834:	74 17                	je     80184d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	ff 75 10             	pushl  0x10(%ebp)
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	52                   	push   %edx
  801840:	ff d0                	call   *%eax
  801842:	89 c2                	mov    %eax,%edx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	eb 09                	jmp    801852 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801849:	89 c2                	mov    %eax,%edx
  80184b:	eb 05                	jmp    801852 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80184d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801852:	89 d0                	mov    %edx,%eax
  801854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	57                   	push   %edi
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	8b 7d 08             	mov    0x8(%ebp),%edi
  801865:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801868:	bb 00 00 00 00       	mov    $0x0,%ebx
  80186d:	eb 21                	jmp    801890 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	89 f0                	mov    %esi,%eax
  801874:	29 d8                	sub    %ebx,%eax
  801876:	50                   	push   %eax
  801877:	89 d8                	mov    %ebx,%eax
  801879:	03 45 0c             	add    0xc(%ebp),%eax
  80187c:	50                   	push   %eax
  80187d:	57                   	push   %edi
  80187e:	e8 45 ff ff ff       	call   8017c8 <read>
		if (m < 0)
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 0c                	js     801896 <readn+0x3d>
			return m;
		if (m == 0)
  80188a:	85 c0                	test   %eax,%eax
  80188c:	74 06                	je     801894 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80188e:	01 c3                	add    %eax,%ebx
  801890:	39 f3                	cmp    %esi,%ebx
  801892:	72 db                	jb     80186f <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801894:	89 d8                	mov    %ebx,%eax
}
  801896:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801899:	5b                   	pop    %ebx
  80189a:	5e                   	pop    %esi
  80189b:	5f                   	pop    %edi
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 14             	sub    $0x14,%esp
  8018a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	53                   	push   %ebx
  8018ad:	e8 a7 fc ff ff       	call   801559 <fd_lookup>
  8018b2:	83 c4 08             	add    $0x8,%esp
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 68                	js     801923 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c5:	ff 30                	pushl  (%eax)
  8018c7:	e8 e3 fc ff ff       	call   8015af <dev_lookup>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 47                	js     80191a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018da:	75 21                	jne    8018fd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018dc:	a1 08 50 80 00       	mov    0x805008,%eax
  8018e1:	8b 40 48             	mov    0x48(%eax),%eax
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	53                   	push   %ebx
  8018e8:	50                   	push   %eax
  8018e9:	68 e5 35 80 00       	push   $0x8035e5
  8018ee:	e8 ca ec ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018fb:	eb 26                	jmp    801923 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801900:	8b 52 0c             	mov    0xc(%edx),%edx
  801903:	85 d2                	test   %edx,%edx
  801905:	74 17                	je     80191e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	ff 75 10             	pushl  0x10(%ebp)
  80190d:	ff 75 0c             	pushl  0xc(%ebp)
  801910:	50                   	push   %eax
  801911:	ff d2                	call   *%edx
  801913:	89 c2                	mov    %eax,%edx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	eb 09                	jmp    801923 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	eb 05                	jmp    801923 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80191e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801923:	89 d0                	mov    %edx,%eax
  801925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <seek>:

int
seek(int fdnum, off_t offset)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801930:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801933:	50                   	push   %eax
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 1d fc ff ff       	call   801559 <fd_lookup>
  80193c:	83 c4 08             	add    $0x8,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 0e                	js     801951 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801943:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801946:	8b 55 0c             	mov    0xc(%ebp),%edx
  801949:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 14             	sub    $0x14,%esp
  80195a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801960:	50                   	push   %eax
  801961:	53                   	push   %ebx
  801962:	e8 f2 fb ff ff       	call   801559 <fd_lookup>
  801967:	83 c4 08             	add    $0x8,%esp
  80196a:	89 c2                	mov    %eax,%edx
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 65                	js     8019d5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	ff 30                	pushl  (%eax)
  80197c:	e8 2e fc ff ff       	call   8015af <dev_lookup>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 44                	js     8019cc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80198f:	75 21                	jne    8019b2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801991:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801996:	8b 40 48             	mov    0x48(%eax),%eax
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	53                   	push   %ebx
  80199d:	50                   	push   %eax
  80199e:	68 a8 35 80 00       	push   $0x8035a8
  8019a3:	e8 15 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019b0:	eb 23                	jmp    8019d5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b5:	8b 52 18             	mov    0x18(%edx),%edx
  8019b8:	85 d2                	test   %edx,%edx
  8019ba:	74 14                	je     8019d0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	50                   	push   %eax
  8019c3:	ff d2                	call   *%edx
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	eb 09                	jmp    8019d5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	eb 05                	jmp    8019d5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019d5:	89 d0                	mov    %edx,%eax
  8019d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 14             	sub    $0x14,%esp
  8019e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e9:	50                   	push   %eax
  8019ea:	ff 75 08             	pushl  0x8(%ebp)
  8019ed:	e8 67 fb ff ff       	call   801559 <fd_lookup>
  8019f2:	83 c4 08             	add    $0x8,%esp
  8019f5:	89 c2                	mov    %eax,%edx
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 58                	js     801a53 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a01:	50                   	push   %eax
  801a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a05:	ff 30                	pushl  (%eax)
  801a07:	e8 a3 fb ff ff       	call   8015af <dev_lookup>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 37                	js     801a4a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a16:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a1a:	74 32                	je     801a4e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a1c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a1f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a26:	00 00 00 
	stat->st_isdir = 0;
  801a29:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a30:	00 00 00 
	stat->st_dev = dev;
  801a33:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	53                   	push   %ebx
  801a3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a40:	ff 50 14             	call   *0x14(%eax)
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	eb 09                	jmp    801a53 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	eb 05                	jmp    801a53 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a4e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a53:	89 d0                	mov    %edx,%eax
  801a55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	6a 00                	push   $0x0
  801a64:	ff 75 08             	pushl  0x8(%ebp)
  801a67:	e8 09 02 00 00       	call   801c75 <open>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 db                	test   %ebx,%ebx
  801a73:	78 1b                	js     801a90 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	ff 75 0c             	pushl  0xc(%ebp)
  801a7b:	53                   	push   %ebx
  801a7c:	e8 5b ff ff ff       	call   8019dc <fstat>
  801a81:	89 c6                	mov    %eax,%esi
	close(fd);
  801a83:	89 1c 24             	mov    %ebx,(%esp)
  801a86:	e8 fd fb ff ff       	call   801688 <close>
	return r;
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	89 f0                	mov    %esi,%eax
}
  801a90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	89 c6                	mov    %eax,%esi
  801a9e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801aa0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801aa7:	75 12                	jne    801abb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	6a 01                	push   $0x1
  801aae:	e8 8f 11 00 00       	call   802c42 <ipc_find_env>
  801ab3:	a3 00 50 80 00       	mov    %eax,0x805000
  801ab8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801abb:	6a 07                	push   $0x7
  801abd:	68 00 60 80 00       	push   $0x806000
  801ac2:	56                   	push   %esi
  801ac3:	ff 35 00 50 80 00    	pushl  0x805000
  801ac9:	e8 20 11 00 00       	call   802bee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ace:	83 c4 0c             	add    $0xc,%esp
  801ad1:	6a 00                	push   $0x0
  801ad3:	53                   	push   %ebx
  801ad4:	6a 00                	push   $0x0
  801ad6:	e8 aa 10 00 00       	call   802b85 <ipc_recv>
}
  801adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aeb:	8b 40 0c             	mov    0xc(%eax),%eax
  801aee:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801afb:	ba 00 00 00 00       	mov    $0x0,%edx
  801b00:	b8 02 00 00 00       	mov    $0x2,%eax
  801b05:	e8 8d ff ff ff       	call   801a97 <fsipc>
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	8b 40 0c             	mov    0xc(%eax),%eax
  801b18:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b22:	b8 06 00 00 00       	mov    $0x6,%eax
  801b27:	e8 6b ff ff ff       	call   801a97 <fsipc>
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
  801b48:	b8 05 00 00 00       	mov    $0x5,%eax
  801b4d:	e8 45 ff ff ff       	call   801a97 <fsipc>
  801b52:	89 c2                	mov    %eax,%edx
  801b54:	85 d2                	test   %edx,%edx
  801b56:	78 2c                	js     801b84 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	68 00 60 80 00       	push   $0x806000
  801b60:	53                   	push   %ebx
  801b61:	e8 de ef ff ff       	call   800b44 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b66:	a1 80 60 80 00       	mov    0x806080,%eax
  801b6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b71:	a1 84 60 80 00       	mov    0x806084,%eax
  801b76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b87:	c9                   	leave  
  801b88:	c3                   	ret    

00801b89 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	57                   	push   %edi
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801b95:	8b 45 08             	mov    0x8(%ebp),%eax
  801b98:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9b:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801ba3:	eb 3d                	jmp    801be2 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801ba5:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801bab:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801bb0:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	57                   	push   %edi
  801bb7:	53                   	push   %ebx
  801bb8:	68 08 60 80 00       	push   $0x806008
  801bbd:	e8 14 f1 ff ff       	call   800cd6 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801bc2:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcd:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd2:	e8 c0 fe ff ff       	call   801a97 <fsipc>
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 0d                	js     801beb <devfile_write+0x62>
		        return r;
                n -= tmp;
  801bde:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801be0:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801be2:	85 f6                	test   %esi,%esi
  801be4:	75 bf                	jne    801ba5 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801c01:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c06:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c11:	b8 03 00 00 00       	mov    $0x3,%eax
  801c16:	e8 7c fe ff ff       	call   801a97 <fsipc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 4b                	js     801c6c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c21:	39 c6                	cmp    %eax,%esi
  801c23:	73 16                	jae    801c3b <devfile_read+0x48>
  801c25:	68 18 36 80 00       	push   $0x803618
  801c2a:	68 1f 36 80 00       	push   $0x80361f
  801c2f:	6a 7c                	push   $0x7c
  801c31:	68 34 36 80 00       	push   $0x803634
  801c36:	e8 a9 e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801c3b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c40:	7e 16                	jle    801c58 <devfile_read+0x65>
  801c42:	68 3f 36 80 00       	push   $0x80363f
  801c47:	68 1f 36 80 00       	push   $0x80361f
  801c4c:	6a 7d                	push   $0x7d
  801c4e:	68 34 36 80 00       	push   $0x803634
  801c53:	e8 8c e8 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	50                   	push   %eax
  801c5c:	68 00 60 80 00       	push   $0x806000
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	e8 6d f0 ff ff       	call   800cd6 <memmove>
	return r;
  801c69:	83 c4 10             	add    $0x10,%esp
}
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 20             	sub    $0x20,%esp
  801c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c7f:	53                   	push   %ebx
  801c80:	e8 86 ee ff ff       	call   800b0b <strlen>
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c8d:	7f 67                	jg     801cf6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c95:	50                   	push   %eax
  801c96:	e8 6f f8 ff ff       	call   80150a <fd_alloc>
  801c9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801c9e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 57                	js     801cfb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	53                   	push   %ebx
  801ca8:	68 00 60 80 00       	push   $0x806000
  801cad:	e8 92 ee ff ff       	call   800b44 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc2:	e8 d0 fd ff ff       	call   801a97 <fsipc>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	79 14                	jns    801ce4 <open+0x6f>
		fd_close(fd, 0);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	6a 00                	push   $0x0
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	e8 2a f9 ff ff       	call   801607 <fd_close>
		return r;
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	89 da                	mov    %ebx,%edx
  801ce2:	eb 17                	jmp    801cfb <open+0x86>
	}

	return fd2num(fd);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cea:	e8 f4 f7 ff ff       	call   8014e3 <fd2num>
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	eb 05                	jmp    801cfb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cf6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d08:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  801d12:	e8 80 fd ff ff       	call   801a97 <fsipc>
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	57                   	push   %edi
  801d1d:	56                   	push   %esi
  801d1e:	53                   	push   %ebx
  801d1f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801d25:	6a 00                	push   $0x0
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	e8 46 ff ff ff       	call   801c75 <open>
  801d2f:	89 c7                	mov    %eax,%edi
  801d31:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	0f 88 97 04 00 00    	js     8021d9 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	68 00 02 00 00       	push   $0x200
  801d4a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801d50:	50                   	push   %eax
  801d51:	57                   	push   %edi
  801d52:	e8 02 fb ff ff       	call   801859 <readn>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d5f:	75 0c                	jne    801d6d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d61:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d68:	45 4c 46 
  801d6b:	74 33                	je     801da0 <spawn+0x87>
		close(fd);
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d76:	e8 0d f9 ff ff       	call   801688 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d7b:	83 c4 0c             	add    $0xc,%esp
  801d7e:	68 7f 45 4c 46       	push   $0x464c457f
  801d83:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d89:	68 4b 36 80 00       	push   $0x80364b
  801d8e:	e8 2a e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801d9b:	e9 be 04 00 00       	jmp    80225e <spawn+0x545>
  801da0:	b8 07 00 00 00       	mov    $0x7,%eax
  801da5:	cd 30                	int    $0x30
  801da7:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801dad:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801db3:	85 c0                	test   %eax,%eax
  801db5:	0f 88 26 04 00 00    	js     8021e1 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801dbb:	89 c6                	mov    %eax,%esi
  801dbd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801dc3:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801dc6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801dcc:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801dd2:	b9 11 00 00 00       	mov    $0x11,%ecx
  801dd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801dd9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ddf:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801de5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801dea:	be 00 00 00 00       	mov    $0x0,%esi
  801def:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801df2:	eb 13                	jmp    801e07 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	50                   	push   %eax
  801df8:	e8 0e ed ff ff       	call   800b0b <strlen>
  801dfd:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e01:	83 c3 01             	add    $0x1,%ebx
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801e0e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801e11:	85 c0                	test   %eax,%eax
  801e13:	75 df                	jne    801df4 <spawn+0xdb>
  801e15:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801e1b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e21:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e26:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e28:	89 fa                	mov    %edi,%edx
  801e2a:	83 e2 fc             	and    $0xfffffffc,%edx
  801e2d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801e34:	29 c2                	sub    %eax,%edx
  801e36:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e3c:	8d 42 f8             	lea    -0x8(%edx),%eax
  801e3f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e44:	0f 86 a7 03 00 00    	jbe    8021f1 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e4a:	83 ec 04             	sub    $0x4,%esp
  801e4d:	6a 07                	push   $0x7
  801e4f:	68 00 00 40 00       	push   $0x400000
  801e54:	6a 00                	push   $0x0
  801e56:	e8 f2 f0 ff ff       	call   800f4d <sys_page_alloc>
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 f8 03 00 00    	js     80225e <spawn+0x545>
  801e66:	be 00 00 00 00       	mov    $0x0,%esi
  801e6b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e74:	eb 30                	jmp    801ea6 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e76:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e7c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e82:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e85:	83 ec 08             	sub    $0x8,%esp
  801e88:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e8b:	57                   	push   %edi
  801e8c:	e8 b3 ec ff ff       	call   800b44 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e91:	83 c4 04             	add    $0x4,%esp
  801e94:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e97:	e8 6f ec ff ff       	call   800b0b <strlen>
  801e9c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ea0:	83 c6 01             	add    $0x1,%esi
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801eac:	7f c8                	jg     801e76 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801eae:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801eb4:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801eba:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ec1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ec7:	74 19                	je     801ee2 <spawn+0x1c9>
  801ec9:	68 d8 36 80 00       	push   $0x8036d8
  801ece:	68 1f 36 80 00       	push   $0x80361f
  801ed3:	68 f1 00 00 00       	push   $0xf1
  801ed8:	68 65 36 80 00       	push   $0x803665
  801edd:	e8 02 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ee2:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ee8:	89 f8                	mov    %edi,%eax
  801eea:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801eef:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ef2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ef8:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801efb:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801f01:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	6a 07                	push   $0x7
  801f0c:	68 00 d0 bf ee       	push   $0xeebfd000
  801f11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f17:	68 00 00 40 00       	push   $0x400000
  801f1c:	6a 00                	push   $0x0
  801f1e:	e8 6d f0 ff ff       	call   800f90 <sys_page_map>
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	83 c4 20             	add    $0x20,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	0f 88 1a 03 00 00    	js     80224a <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801f30:	83 ec 08             	sub    $0x8,%esp
  801f33:	68 00 00 40 00       	push   $0x400000
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 93 f0 ff ff       	call   800fd2 <sys_page_unmap>
  801f3f:	89 c3                	mov    %eax,%ebx
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	0f 88 fe 02 00 00    	js     80224a <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f4c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f52:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801f59:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f5f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f66:	00 00 00 
  801f69:	e9 85 01 00 00       	jmp    8020f3 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801f6e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f74:	83 38 01             	cmpl   $0x1,(%eax)
  801f77:	0f 85 68 01 00 00    	jne    8020e5 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f7d:	89 c7                	mov    %eax,%edi
  801f7f:	8b 40 18             	mov    0x18(%eax),%eax
  801f82:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f88:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f8b:	83 f8 01             	cmp    $0x1,%eax
  801f8e:	19 c0                	sbb    %eax,%eax
  801f90:	83 e0 fe             	and    $0xfffffffe,%eax
  801f93:	83 c0 07             	add    $0x7,%eax
  801f96:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f9c:	89 f8                	mov    %edi,%eax
  801f9e:	8b 7f 04             	mov    0x4(%edi),%edi
  801fa1:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801fa7:	8b 78 10             	mov    0x10(%eax),%edi
  801faa:	8b 48 14             	mov    0x14(%eax),%ecx
  801fad:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801fb3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801fb6:	89 f0                	mov    %esi,%eax
  801fb8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801fbd:	74 10                	je     801fcf <spawn+0x2b6>
		va -= i;
  801fbf:	29 c6                	sub    %eax,%esi
		memsz += i;
  801fc1:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801fc7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801fc9:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd4:	e9 fa 00 00 00       	jmp    8020d3 <spawn+0x3ba>
		if (i >= filesz) {
  801fd9:	39 fb                	cmp    %edi,%ebx
  801fdb:	72 27                	jb     802004 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fe6:	56                   	push   %esi
  801fe7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fed:	e8 5b ef ff ff       	call   800f4d <sys_page_alloc>
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	0f 89 ca 00 00 00    	jns    8020c7 <spawn+0x3ae>
  801ffd:	89 c7                	mov    %eax,%edi
  801fff:	e9 fe 01 00 00       	jmp    802202 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802004:	83 ec 04             	sub    $0x4,%esp
  802007:	6a 07                	push   $0x7
  802009:	68 00 00 40 00       	push   $0x400000
  80200e:	6a 00                	push   $0x0
  802010:	e8 38 ef ff ff       	call   800f4d <sys_page_alloc>
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 88 d8 01 00 00    	js     8021f8 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802020:	83 ec 08             	sub    $0x8,%esp
  802023:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802029:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  80202f:	50                   	push   %eax
  802030:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802036:	e8 ef f8 ff ff       	call   80192a <seek>
  80203b:	83 c4 10             	add    $0x10,%esp
  80203e:	85 c0                	test   %eax,%eax
  802040:	0f 88 b6 01 00 00    	js     8021fc <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802046:	83 ec 04             	sub    $0x4,%esp
  802049:	89 fa                	mov    %edi,%edx
  80204b:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  802051:	89 d0                	mov    %edx,%eax
  802053:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802059:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80205e:	0f 47 c1             	cmova  %ecx,%eax
  802061:	50                   	push   %eax
  802062:	68 00 00 40 00       	push   $0x400000
  802067:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80206d:	e8 e7 f7 ff ff       	call   801859 <readn>
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	0f 88 83 01 00 00    	js     802200 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80207d:	83 ec 0c             	sub    $0xc,%esp
  802080:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802086:	56                   	push   %esi
  802087:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80208d:	68 00 00 40 00       	push   $0x400000
  802092:	6a 00                	push   $0x0
  802094:	e8 f7 ee ff ff       	call   800f90 <sys_page_map>
  802099:	83 c4 20             	add    $0x20,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	79 15                	jns    8020b5 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  8020a0:	50                   	push   %eax
  8020a1:	68 71 36 80 00       	push   $0x803671
  8020a6:	68 24 01 00 00       	push   $0x124
  8020ab:	68 65 36 80 00       	push   $0x803665
  8020b0:	e8 2f e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  8020b5:	83 ec 08             	sub    $0x8,%esp
  8020b8:	68 00 00 40 00       	push   $0x400000
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 0e ef ff ff       	call   800fd2 <sys_page_unmap>
  8020c4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8020c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020cd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8020d3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8020d9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8020df:	0f 82 f4 fe ff ff    	jb     801fd9 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020e5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8020ec:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8020f3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020fa:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802100:	0f 8c 68 fe ff ff    	jl     801f6e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80210f:	e8 74 f5 ff ff       	call   801688 <close>
  802114:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  802117:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  802122:	89 d8                	mov    %ebx,%eax
  802124:	c1 e8 16             	shr    $0x16,%eax
  802127:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80212e:	a8 01                	test   $0x1,%al
  802130:	74 53                	je     802185 <spawn+0x46c>
  802132:	89 d8                	mov    %ebx,%eax
  802134:	c1 e8 0c             	shr    $0xc,%eax
  802137:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80213e:	f6 c2 01             	test   $0x1,%dl
  802141:	74 42                	je     802185 <spawn+0x46c>
  802143:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80214a:	f6 c6 04             	test   $0x4,%dh
  80214d:	74 36                	je     802185 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  80214f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	25 07 0e 00 00       	and    $0xe07,%eax
  80215e:	50                   	push   %eax
  80215f:	53                   	push   %ebx
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	6a 00                	push   $0x0
  802164:	e8 27 ee ff ff       	call   800f90 <sys_page_map>
                        if (r < 0) return r;
  802169:	83 c4 20             	add    $0x20,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	79 15                	jns    802185 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802170:	50                   	push   %eax
  802171:	68 8e 36 80 00       	push   $0x80368e
  802176:	68 82 00 00 00       	push   $0x82
  80217b:	68 65 36 80 00       	push   $0x803665
  802180:	e8 5f e3 ff ff       	call   8004e4 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  802185:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80218b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802191:	75 8f                	jne    802122 <spawn+0x409>
  802193:	e9 8d 00 00 00       	jmp    802225 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  802198:	50                   	push   %eax
  802199:	68 a4 36 80 00       	push   $0x8036a4
  80219e:	68 85 00 00 00       	push   $0x85
  8021a3:	68 65 36 80 00       	push   $0x803665
  8021a8:	e8 37 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8021ad:	83 ec 08             	sub    $0x8,%esp
  8021b0:	6a 02                	push   $0x2
  8021b2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021b8:	e8 57 ee ff ff       	call   801014 <sys_env_set_status>
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	79 25                	jns    8021e9 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  8021c4:	50                   	push   %eax
  8021c5:	68 be 36 80 00       	push   $0x8036be
  8021ca:	68 88 00 00 00       	push   $0x88
  8021cf:	68 65 36 80 00       	push   $0x803665
  8021d4:	e8 0b e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8021d9:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8021df:	eb 7d                	jmp    80225e <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8021e1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021e7:	eb 75                	jmp    80225e <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8021e9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021ef:	eb 6d                	jmp    80225e <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8021f1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8021f6:	eb 66                	jmp    80225e <spawn+0x545>
  8021f8:	89 c7                	mov    %eax,%edi
  8021fa:	eb 06                	jmp    802202 <spawn+0x4e9>
  8021fc:	89 c7                	mov    %eax,%edi
  8021fe:	eb 02                	jmp    802202 <spawn+0x4e9>
  802200:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802202:	83 ec 0c             	sub    $0xc,%esp
  802205:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80220b:	e8 be ec ff ff       	call   800ece <sys_env_destroy>
	close(fd);
  802210:	83 c4 04             	add    $0x4,%esp
  802213:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802219:	e8 6a f4 ff ff       	call   801688 <close>
	return r;
  80221e:	83 c4 10             	add    $0x10,%esp
  802221:	89 f8                	mov    %edi,%eax
  802223:	eb 39                	jmp    80225e <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  802225:	83 ec 08             	sub    $0x8,%esp
  802228:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80222e:	50                   	push   %eax
  80222f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802235:	e8 1c ee ff ff       	call   801056 <sys_env_set_trapframe>
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	85 c0                	test   %eax,%eax
  80223f:	0f 89 68 ff ff ff    	jns    8021ad <spawn+0x494>
  802245:	e9 4e ff ff ff       	jmp    802198 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80224a:	83 ec 08             	sub    $0x8,%esp
  80224d:	68 00 00 40 00       	push   $0x400000
  802252:	6a 00                	push   $0x0
  802254:	e8 79 ed ff ff       	call   800fd2 <sys_page_unmap>
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80225e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	56                   	push   %esi
  80226a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80226b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80226e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802273:	eb 03                	jmp    802278 <spawnl+0x12>
		argc++;
  802275:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802278:	83 c2 04             	add    $0x4,%edx
  80227b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80227f:	75 f4                	jne    802275 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802281:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802288:	83 e2 f0             	and    $0xfffffff0,%edx
  80228b:	29 d4                	sub    %edx,%esp
  80228d:	8d 54 24 03          	lea    0x3(%esp),%edx
  802291:	c1 ea 02             	shr    $0x2,%edx
  802294:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80229b:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80229d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022a0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8022a7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8022ae:	00 
  8022af:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b6:	eb 0a                	jmp    8022c2 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8022b8:	83 c0 01             	add    $0x1,%eax
  8022bb:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8022bf:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022c2:	39 d0                	cmp    %edx,%eax
  8022c4:	75 f2                	jne    8022b8 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8022c6:	83 ec 08             	sub    $0x8,%esp
  8022c9:	56                   	push   %esi
  8022ca:	ff 75 08             	pushl  0x8(%ebp)
  8022cd:	e8 47 fa ff ff       	call   801d19 <spawn>
}
  8022d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8022df:	68 fe 36 80 00       	push   $0x8036fe
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	e8 58 e8 ff ff       	call   800b44 <strcpy>
	return 0;
}
  8022ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	53                   	push   %ebx
  8022f7:	83 ec 10             	sub    $0x10,%esp
  8022fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8022fd:	53                   	push   %ebx
  8022fe:	e8 77 09 00 00       	call   802c7a <pageref>
  802303:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802306:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80230b:	83 f8 01             	cmp    $0x1,%eax
  80230e:	75 10                	jne    802320 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802310:	83 ec 0c             	sub    $0xc,%esp
  802313:	ff 73 0c             	pushl  0xc(%ebx)
  802316:	e8 ca 02 00 00       	call   8025e5 <nsipc_close>
  80231b:	89 c2                	mov    %eax,%edx
  80231d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802320:	89 d0                	mov    %edx,%eax
  802322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802325:	c9                   	leave  
  802326:	c3                   	ret    

00802327 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80232d:	6a 00                	push   $0x0
  80232f:	ff 75 10             	pushl  0x10(%ebp)
  802332:	ff 75 0c             	pushl  0xc(%ebp)
  802335:	8b 45 08             	mov    0x8(%ebp),%eax
  802338:	ff 70 0c             	pushl  0xc(%eax)
  80233b:	e8 82 03 00 00       	call   8026c2 <nsipc_send>
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802348:	6a 00                	push   $0x0
  80234a:	ff 75 10             	pushl  0x10(%ebp)
  80234d:	ff 75 0c             	pushl  0xc(%ebp)
  802350:	8b 45 08             	mov    0x8(%ebp),%eax
  802353:	ff 70 0c             	pushl  0xc(%eax)
  802356:	e8 fb 02 00 00       	call   802656 <nsipc_recv>
}
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802363:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802366:	52                   	push   %edx
  802367:	50                   	push   %eax
  802368:	e8 ec f1 ff ff       	call   801559 <fd_lookup>
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	85 c0                	test   %eax,%eax
  802372:	78 17                	js     80238b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802377:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  80237d:	39 08                	cmp    %ecx,(%eax)
  80237f:	75 05                	jne    802386 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802381:	8b 40 0c             	mov    0xc(%eax),%eax
  802384:	eb 05                	jmp    80238b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802386:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80238b:	c9                   	leave  
  80238c:	c3                   	ret    

0080238d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	56                   	push   %esi
  802391:	53                   	push   %ebx
  802392:	83 ec 1c             	sub    $0x1c,%esp
  802395:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239a:	50                   	push   %eax
  80239b:	e8 6a f1 ff ff       	call   80150a <fd_alloc>
  8023a0:	89 c3                	mov    %eax,%ebx
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	78 1b                	js     8023c4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8023a9:	83 ec 04             	sub    $0x4,%esp
  8023ac:	68 07 04 00 00       	push   $0x407
  8023b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b4:	6a 00                	push   $0x0
  8023b6:	e8 92 eb ff ff       	call   800f4d <sys_page_alloc>
  8023bb:	89 c3                	mov    %eax,%ebx
  8023bd:	83 c4 10             	add    $0x10,%esp
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	79 10                	jns    8023d4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8023c4:	83 ec 0c             	sub    $0xc,%esp
  8023c7:	56                   	push   %esi
  8023c8:	e8 18 02 00 00       	call   8025e5 <nsipc_close>
		return r;
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	89 d8                	mov    %ebx,%eax
  8023d2:	eb 24                	jmp    8023f8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8023d4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023dd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8023df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023e2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8023e9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8023ec:	83 ec 0c             	sub    $0xc,%esp
  8023ef:	52                   	push   %edx
  8023f0:	e8 ee f0 ff ff       	call   8014e3 <fd2num>
  8023f5:	83 c4 10             	add    $0x10,%esp
}
  8023f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fb:	5b                   	pop    %ebx
  8023fc:	5e                   	pop    %esi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802405:	8b 45 08             	mov    0x8(%ebp),%eax
  802408:	e8 50 ff ff ff       	call   80235d <fd2sockid>
		return r;
  80240d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80240f:	85 c0                	test   %eax,%eax
  802411:	78 1f                	js     802432 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802413:	83 ec 04             	sub    $0x4,%esp
  802416:	ff 75 10             	pushl  0x10(%ebp)
  802419:	ff 75 0c             	pushl  0xc(%ebp)
  80241c:	50                   	push   %eax
  80241d:	e8 1c 01 00 00       	call   80253e <nsipc_accept>
  802422:	83 c4 10             	add    $0x10,%esp
		return r;
  802425:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802427:	85 c0                	test   %eax,%eax
  802429:	78 07                	js     802432 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80242b:	e8 5d ff ff ff       	call   80238d <alloc_sockfd>
  802430:	89 c1                	mov    %eax,%ecx
}
  802432:	89 c8                	mov    %ecx,%eax
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	e8 19 ff ff ff       	call   80235d <fd2sockid>
  802444:	89 c2                	mov    %eax,%edx
  802446:	85 d2                	test   %edx,%edx
  802448:	78 12                	js     80245c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80244a:	83 ec 04             	sub    $0x4,%esp
  80244d:	ff 75 10             	pushl  0x10(%ebp)
  802450:	ff 75 0c             	pushl  0xc(%ebp)
  802453:	52                   	push   %edx
  802454:	e8 35 01 00 00       	call   80258e <nsipc_bind>
  802459:	83 c4 10             	add    $0x10,%esp
}
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <shutdown>:

int
shutdown(int s, int how)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802464:	8b 45 08             	mov    0x8(%ebp),%eax
  802467:	e8 f1 fe ff ff       	call   80235d <fd2sockid>
  80246c:	89 c2                	mov    %eax,%edx
  80246e:	85 d2                	test   %edx,%edx
  802470:	78 0f                	js     802481 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802472:	83 ec 08             	sub    $0x8,%esp
  802475:	ff 75 0c             	pushl  0xc(%ebp)
  802478:	52                   	push   %edx
  802479:	e8 45 01 00 00       	call   8025c3 <nsipc_shutdown>
  80247e:	83 c4 10             	add    $0x10,%esp
}
  802481:	c9                   	leave  
  802482:	c3                   	ret    

00802483 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802483:	55                   	push   %ebp
  802484:	89 e5                	mov    %esp,%ebp
  802486:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802489:	8b 45 08             	mov    0x8(%ebp),%eax
  80248c:	e8 cc fe ff ff       	call   80235d <fd2sockid>
  802491:	89 c2                	mov    %eax,%edx
  802493:	85 d2                	test   %edx,%edx
  802495:	78 12                	js     8024a9 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  802497:	83 ec 04             	sub    $0x4,%esp
  80249a:	ff 75 10             	pushl  0x10(%ebp)
  80249d:	ff 75 0c             	pushl  0xc(%ebp)
  8024a0:	52                   	push   %edx
  8024a1:	e8 59 01 00 00       	call   8025ff <nsipc_connect>
  8024a6:	83 c4 10             	add    $0x10,%esp
}
  8024a9:	c9                   	leave  
  8024aa:	c3                   	ret    

008024ab <listen>:

int
listen(int s, int backlog)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b4:	e8 a4 fe ff ff       	call   80235d <fd2sockid>
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	85 d2                	test   %edx,%edx
  8024bd:	78 0f                	js     8024ce <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8024bf:	83 ec 08             	sub    $0x8,%esp
  8024c2:	ff 75 0c             	pushl  0xc(%ebp)
  8024c5:	52                   	push   %edx
  8024c6:	e8 69 01 00 00       	call   802634 <nsipc_listen>
  8024cb:	83 c4 10             	add    $0x10,%esp
}
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8024d6:	ff 75 10             	pushl  0x10(%ebp)
  8024d9:	ff 75 0c             	pushl  0xc(%ebp)
  8024dc:	ff 75 08             	pushl  0x8(%ebp)
  8024df:	e8 3c 02 00 00       	call   802720 <nsipc_socket>
  8024e4:	89 c2                	mov    %eax,%edx
  8024e6:	83 c4 10             	add    $0x10,%esp
  8024e9:	85 d2                	test   %edx,%edx
  8024eb:	78 05                	js     8024f2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8024ed:	e8 9b fe ff ff       	call   80238d <alloc_sockfd>
}
  8024f2:	c9                   	leave  
  8024f3:	c3                   	ret    

008024f4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	53                   	push   %ebx
  8024f8:	83 ec 04             	sub    $0x4,%esp
  8024fb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8024fd:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802504:	75 12                	jne    802518 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802506:	83 ec 0c             	sub    $0xc,%esp
  802509:	6a 02                	push   $0x2
  80250b:	e8 32 07 00 00       	call   802c42 <ipc_find_env>
  802510:	a3 04 50 80 00       	mov    %eax,0x805004
  802515:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802518:	6a 07                	push   $0x7
  80251a:	68 00 70 80 00       	push   $0x807000
  80251f:	53                   	push   %ebx
  802520:	ff 35 04 50 80 00    	pushl  0x805004
  802526:	e8 c3 06 00 00       	call   802bee <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80252b:	83 c4 0c             	add    $0xc,%esp
  80252e:	6a 00                	push   $0x0
  802530:	6a 00                	push   $0x0
  802532:	6a 00                	push   $0x0
  802534:	e8 4c 06 00 00       	call   802b85 <ipc_recv>
}
  802539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80253c:	c9                   	leave  
  80253d:	c3                   	ret    

0080253e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	56                   	push   %esi
  802542:	53                   	push   %ebx
  802543:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802546:	8b 45 08             	mov    0x8(%ebp),%eax
  802549:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80254e:	8b 06                	mov    (%esi),%eax
  802550:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802555:	b8 01 00 00 00       	mov    $0x1,%eax
  80255a:	e8 95 ff ff ff       	call   8024f4 <nsipc>
  80255f:	89 c3                	mov    %eax,%ebx
  802561:	85 c0                	test   %eax,%eax
  802563:	78 20                	js     802585 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802565:	83 ec 04             	sub    $0x4,%esp
  802568:	ff 35 10 70 80 00    	pushl  0x807010
  80256e:	68 00 70 80 00       	push   $0x807000
  802573:	ff 75 0c             	pushl  0xc(%ebp)
  802576:	e8 5b e7 ff ff       	call   800cd6 <memmove>
		*addrlen = ret->ret_addrlen;
  80257b:	a1 10 70 80 00       	mov    0x807010,%eax
  802580:	89 06                	mov    %eax,(%esi)
  802582:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802585:	89 d8                	mov    %ebx,%eax
  802587:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80258a:	5b                   	pop    %ebx
  80258b:	5e                   	pop    %esi
  80258c:	5d                   	pop    %ebp
  80258d:	c3                   	ret    

0080258e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80258e:	55                   	push   %ebp
  80258f:	89 e5                	mov    %esp,%ebp
  802591:	53                   	push   %ebx
  802592:	83 ec 08             	sub    $0x8,%esp
  802595:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802598:	8b 45 08             	mov    0x8(%ebp),%eax
  80259b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8025a0:	53                   	push   %ebx
  8025a1:	ff 75 0c             	pushl  0xc(%ebp)
  8025a4:	68 04 70 80 00       	push   $0x807004
  8025a9:	e8 28 e7 ff ff       	call   800cd6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8025ae:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8025b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8025b9:	e8 36 ff ff ff       	call   8024f4 <nsipc>
}
  8025be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025c1:	c9                   	leave  
  8025c2:	c3                   	ret    

008025c3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8025c3:	55                   	push   %ebp
  8025c4:	89 e5                	mov    %esp,%ebp
  8025c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8025c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025cc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8025d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8025d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8025de:	e8 11 ff ff ff       	call   8024f4 <nsipc>
}
  8025e3:	c9                   	leave  
  8025e4:	c3                   	ret    

008025e5 <nsipc_close>:

int
nsipc_close(int s)
{
  8025e5:	55                   	push   %ebp
  8025e6:	89 e5                	mov    %esp,%ebp
  8025e8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ee:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8025f8:	e8 f7 fe ff ff       	call   8024f4 <nsipc>
}
  8025fd:	c9                   	leave  
  8025fe:	c3                   	ret    

008025ff <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025ff:	55                   	push   %ebp
  802600:	89 e5                	mov    %esp,%ebp
  802602:	53                   	push   %ebx
  802603:	83 ec 08             	sub    $0x8,%esp
  802606:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802609:	8b 45 08             	mov    0x8(%ebp),%eax
  80260c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802611:	53                   	push   %ebx
  802612:	ff 75 0c             	pushl  0xc(%ebp)
  802615:	68 04 70 80 00       	push   $0x807004
  80261a:	e8 b7 e6 ff ff       	call   800cd6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80261f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802625:	b8 05 00 00 00       	mov    $0x5,%eax
  80262a:	e8 c5 fe ff ff       	call   8024f4 <nsipc>
}
  80262f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802632:	c9                   	leave  
  802633:	c3                   	ret    

00802634 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802634:	55                   	push   %ebp
  802635:	89 e5                	mov    %esp,%ebp
  802637:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80263a:	8b 45 08             	mov    0x8(%ebp),%eax
  80263d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802642:	8b 45 0c             	mov    0xc(%ebp),%eax
  802645:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80264a:	b8 06 00 00 00       	mov    $0x6,%eax
  80264f:	e8 a0 fe ff ff       	call   8024f4 <nsipc>
}
  802654:	c9                   	leave  
  802655:	c3                   	ret    

00802656 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802656:	55                   	push   %ebp
  802657:	89 e5                	mov    %esp,%ebp
  802659:	56                   	push   %esi
  80265a:	53                   	push   %ebx
  80265b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80265e:	8b 45 08             	mov    0x8(%ebp),%eax
  802661:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802666:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80266c:	8b 45 14             	mov    0x14(%ebp),%eax
  80266f:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802674:	b8 07 00 00 00       	mov    $0x7,%eax
  802679:	e8 76 fe ff ff       	call   8024f4 <nsipc>
  80267e:	89 c3                	mov    %eax,%ebx
  802680:	85 c0                	test   %eax,%eax
  802682:	78 35                	js     8026b9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802684:	39 f0                	cmp    %esi,%eax
  802686:	7f 07                	jg     80268f <nsipc_recv+0x39>
  802688:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80268d:	7e 16                	jle    8026a5 <nsipc_recv+0x4f>
  80268f:	68 0a 37 80 00       	push   $0x80370a
  802694:	68 1f 36 80 00       	push   $0x80361f
  802699:	6a 62                	push   $0x62
  80269b:	68 1f 37 80 00       	push   $0x80371f
  8026a0:	e8 3f de ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8026a5:	83 ec 04             	sub    $0x4,%esp
  8026a8:	50                   	push   %eax
  8026a9:	68 00 70 80 00       	push   $0x807000
  8026ae:	ff 75 0c             	pushl  0xc(%ebp)
  8026b1:	e8 20 e6 ff ff       	call   800cd6 <memmove>
  8026b6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8026b9:	89 d8                	mov    %ebx,%eax
  8026bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026be:	5b                   	pop    %ebx
  8026bf:	5e                   	pop    %esi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    

008026c2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8026c2:	55                   	push   %ebp
  8026c3:	89 e5                	mov    %esp,%ebp
  8026c5:	53                   	push   %ebx
  8026c6:	83 ec 04             	sub    $0x4,%esp
  8026c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8026cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cf:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026d4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026da:	7e 16                	jle    8026f2 <nsipc_send+0x30>
  8026dc:	68 2b 37 80 00       	push   $0x80372b
  8026e1:	68 1f 36 80 00       	push   $0x80361f
  8026e6:	6a 6d                	push   $0x6d
  8026e8:	68 1f 37 80 00       	push   $0x80371f
  8026ed:	e8 f2 dd ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8026f2:	83 ec 04             	sub    $0x4,%esp
  8026f5:	53                   	push   %ebx
  8026f6:	ff 75 0c             	pushl  0xc(%ebp)
  8026f9:	68 0c 70 80 00       	push   $0x80700c
  8026fe:	e8 d3 e5 ff ff       	call   800cd6 <memmove>
	nsipcbuf.send.req_size = size;
  802703:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802709:	8b 45 14             	mov    0x14(%ebp),%eax
  80270c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802711:	b8 08 00 00 00       	mov    $0x8,%eax
  802716:	e8 d9 fd ff ff       	call   8024f4 <nsipc>
}
  80271b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80271e:	c9                   	leave  
  80271f:	c3                   	ret    

00802720 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802720:	55                   	push   %ebp
  802721:	89 e5                	mov    %esp,%ebp
  802723:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802726:	8b 45 08             	mov    0x8(%ebp),%eax
  802729:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80272e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802731:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802736:	8b 45 10             	mov    0x10(%ebp),%eax
  802739:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80273e:	b8 09 00 00 00       	mov    $0x9,%eax
  802743:	e8 ac fd ff ff       	call   8024f4 <nsipc>
}
  802748:	c9                   	leave  
  802749:	c3                   	ret    

0080274a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80274a:	55                   	push   %ebp
  80274b:	89 e5                	mov    %esp,%ebp
  80274d:	56                   	push   %esi
  80274e:	53                   	push   %ebx
  80274f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802752:	83 ec 0c             	sub    $0xc,%esp
  802755:	ff 75 08             	pushl  0x8(%ebp)
  802758:	e8 96 ed ff ff       	call   8014f3 <fd2data>
  80275d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80275f:	83 c4 08             	add    $0x8,%esp
  802762:	68 37 37 80 00       	push   $0x803737
  802767:	53                   	push   %ebx
  802768:	e8 d7 e3 ff ff       	call   800b44 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80276d:	8b 56 04             	mov    0x4(%esi),%edx
  802770:	89 d0                	mov    %edx,%eax
  802772:	2b 06                	sub    (%esi),%eax
  802774:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80277a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802781:	00 00 00 
	stat->st_dev = &devpipe;
  802784:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  80278b:	40 80 00 
	return 0;
}
  80278e:	b8 00 00 00 00       	mov    $0x0,%eax
  802793:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802796:	5b                   	pop    %ebx
  802797:	5e                   	pop    %esi
  802798:	5d                   	pop    %ebp
  802799:	c3                   	ret    

0080279a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80279a:	55                   	push   %ebp
  80279b:	89 e5                	mov    %esp,%ebp
  80279d:	53                   	push   %ebx
  80279e:	83 ec 0c             	sub    $0xc,%esp
  8027a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8027a4:	53                   	push   %ebx
  8027a5:	6a 00                	push   $0x0
  8027a7:	e8 26 e8 ff ff       	call   800fd2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8027ac:	89 1c 24             	mov    %ebx,(%esp)
  8027af:	e8 3f ed ff ff       	call   8014f3 <fd2data>
  8027b4:	83 c4 08             	add    $0x8,%esp
  8027b7:	50                   	push   %eax
  8027b8:	6a 00                	push   $0x0
  8027ba:	e8 13 e8 ff ff       	call   800fd2 <sys_page_unmap>
}
  8027bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8027c2:	c9                   	leave  
  8027c3:	c3                   	ret    

008027c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8027c4:	55                   	push   %ebp
  8027c5:	89 e5                	mov    %esp,%ebp
  8027c7:	57                   	push   %edi
  8027c8:	56                   	push   %esi
  8027c9:	53                   	push   %ebx
  8027ca:	83 ec 1c             	sub    $0x1c,%esp
  8027cd:	89 c6                	mov    %eax,%esi
  8027cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8027d2:	a1 08 50 80 00       	mov    0x805008,%eax
  8027d7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8027da:	83 ec 0c             	sub    $0xc,%esp
  8027dd:	56                   	push   %esi
  8027de:	e8 97 04 00 00       	call   802c7a <pageref>
  8027e3:	89 c7                	mov    %eax,%edi
  8027e5:	83 c4 04             	add    $0x4,%esp
  8027e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8027eb:	e8 8a 04 00 00       	call   802c7a <pageref>
  8027f0:	83 c4 10             	add    $0x10,%esp
  8027f3:	39 c7                	cmp    %eax,%edi
  8027f5:	0f 94 c2             	sete   %dl
  8027f8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8027fb:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  802801:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802804:	39 fb                	cmp    %edi,%ebx
  802806:	74 19                	je     802821 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  802808:	84 d2                	test   %dl,%dl
  80280a:	74 c6                	je     8027d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80280c:	8b 51 58             	mov    0x58(%ecx),%edx
  80280f:	50                   	push   %eax
  802810:	52                   	push   %edx
  802811:	53                   	push   %ebx
  802812:	68 3e 37 80 00       	push   $0x80373e
  802817:	e8 a1 dd ff ff       	call   8005bd <cprintf>
  80281c:	83 c4 10             	add    $0x10,%esp
  80281f:	eb b1                	jmp    8027d2 <_pipeisclosed+0xe>
	}
}
  802821:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802824:	5b                   	pop    %ebx
  802825:	5e                   	pop    %esi
  802826:	5f                   	pop    %edi
  802827:	5d                   	pop    %ebp
  802828:	c3                   	ret    

00802829 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802829:	55                   	push   %ebp
  80282a:	89 e5                	mov    %esp,%ebp
  80282c:	57                   	push   %edi
  80282d:	56                   	push   %esi
  80282e:	53                   	push   %ebx
  80282f:	83 ec 28             	sub    $0x28,%esp
  802832:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802835:	56                   	push   %esi
  802836:	e8 b8 ec ff ff       	call   8014f3 <fd2data>
  80283b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80283d:	83 c4 10             	add    $0x10,%esp
  802840:	bf 00 00 00 00       	mov    $0x0,%edi
  802845:	eb 4b                	jmp    802892 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802847:	89 da                	mov    %ebx,%edx
  802849:	89 f0                	mov    %esi,%eax
  80284b:	e8 74 ff ff ff       	call   8027c4 <_pipeisclosed>
  802850:	85 c0                	test   %eax,%eax
  802852:	75 48                	jne    80289c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802854:	e8 d5 e6 ff ff       	call   800f2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802859:	8b 43 04             	mov    0x4(%ebx),%eax
  80285c:	8b 0b                	mov    (%ebx),%ecx
  80285e:	8d 51 20             	lea    0x20(%ecx),%edx
  802861:	39 d0                	cmp    %edx,%eax
  802863:	73 e2                	jae    802847 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802865:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802868:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80286c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80286f:	89 c2                	mov    %eax,%edx
  802871:	c1 fa 1f             	sar    $0x1f,%edx
  802874:	89 d1                	mov    %edx,%ecx
  802876:	c1 e9 1b             	shr    $0x1b,%ecx
  802879:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80287c:	83 e2 1f             	and    $0x1f,%edx
  80287f:	29 ca                	sub    %ecx,%edx
  802881:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802885:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802889:	83 c0 01             	add    $0x1,%eax
  80288c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80288f:	83 c7 01             	add    $0x1,%edi
  802892:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802895:	75 c2                	jne    802859 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802897:	8b 45 10             	mov    0x10(%ebp),%eax
  80289a:	eb 05                	jmp    8028a1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80289c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8028a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028a4:	5b                   	pop    %ebx
  8028a5:	5e                   	pop    %esi
  8028a6:	5f                   	pop    %edi
  8028a7:	5d                   	pop    %ebp
  8028a8:	c3                   	ret    

008028a9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	57                   	push   %edi
  8028ad:	56                   	push   %esi
  8028ae:	53                   	push   %ebx
  8028af:	83 ec 18             	sub    $0x18,%esp
  8028b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8028b5:	57                   	push   %edi
  8028b6:	e8 38 ec ff ff       	call   8014f3 <fd2data>
  8028bb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028bd:	83 c4 10             	add    $0x10,%esp
  8028c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028c5:	eb 3d                	jmp    802904 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8028c7:	85 db                	test   %ebx,%ebx
  8028c9:	74 04                	je     8028cf <devpipe_read+0x26>
				return i;
  8028cb:	89 d8                	mov    %ebx,%eax
  8028cd:	eb 44                	jmp    802913 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8028cf:	89 f2                	mov    %esi,%edx
  8028d1:	89 f8                	mov    %edi,%eax
  8028d3:	e8 ec fe ff ff       	call   8027c4 <_pipeisclosed>
  8028d8:	85 c0                	test   %eax,%eax
  8028da:	75 32                	jne    80290e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8028dc:	e8 4d e6 ff ff       	call   800f2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8028e1:	8b 06                	mov    (%esi),%eax
  8028e3:	3b 46 04             	cmp    0x4(%esi),%eax
  8028e6:	74 df                	je     8028c7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8028e8:	99                   	cltd   
  8028e9:	c1 ea 1b             	shr    $0x1b,%edx
  8028ec:	01 d0                	add    %edx,%eax
  8028ee:	83 e0 1f             	and    $0x1f,%eax
  8028f1:	29 d0                	sub    %edx,%eax
  8028f3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8028f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028fb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8028fe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802901:	83 c3 01             	add    $0x1,%ebx
  802904:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802907:	75 d8                	jne    8028e1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802909:	8b 45 10             	mov    0x10(%ebp),%eax
  80290c:	eb 05                	jmp    802913 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80290e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802913:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802916:	5b                   	pop    %ebx
  802917:	5e                   	pop    %esi
  802918:	5f                   	pop    %edi
  802919:	5d                   	pop    %ebp
  80291a:	c3                   	ret    

0080291b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80291b:	55                   	push   %ebp
  80291c:	89 e5                	mov    %esp,%ebp
  80291e:	56                   	push   %esi
  80291f:	53                   	push   %ebx
  802920:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802926:	50                   	push   %eax
  802927:	e8 de eb ff ff       	call   80150a <fd_alloc>
  80292c:	83 c4 10             	add    $0x10,%esp
  80292f:	89 c2                	mov    %eax,%edx
  802931:	85 c0                	test   %eax,%eax
  802933:	0f 88 2c 01 00 00    	js     802a65 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802939:	83 ec 04             	sub    $0x4,%esp
  80293c:	68 07 04 00 00       	push   $0x407
  802941:	ff 75 f4             	pushl  -0xc(%ebp)
  802944:	6a 00                	push   $0x0
  802946:	e8 02 e6 ff ff       	call   800f4d <sys_page_alloc>
  80294b:	83 c4 10             	add    $0x10,%esp
  80294e:	89 c2                	mov    %eax,%edx
  802950:	85 c0                	test   %eax,%eax
  802952:	0f 88 0d 01 00 00    	js     802a65 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802958:	83 ec 0c             	sub    $0xc,%esp
  80295b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80295e:	50                   	push   %eax
  80295f:	e8 a6 eb ff ff       	call   80150a <fd_alloc>
  802964:	89 c3                	mov    %eax,%ebx
  802966:	83 c4 10             	add    $0x10,%esp
  802969:	85 c0                	test   %eax,%eax
  80296b:	0f 88 e2 00 00 00    	js     802a53 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802971:	83 ec 04             	sub    $0x4,%esp
  802974:	68 07 04 00 00       	push   $0x407
  802979:	ff 75 f0             	pushl  -0x10(%ebp)
  80297c:	6a 00                	push   $0x0
  80297e:	e8 ca e5 ff ff       	call   800f4d <sys_page_alloc>
  802983:	89 c3                	mov    %eax,%ebx
  802985:	83 c4 10             	add    $0x10,%esp
  802988:	85 c0                	test   %eax,%eax
  80298a:	0f 88 c3 00 00 00    	js     802a53 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802990:	83 ec 0c             	sub    $0xc,%esp
  802993:	ff 75 f4             	pushl  -0xc(%ebp)
  802996:	e8 58 eb ff ff       	call   8014f3 <fd2data>
  80299b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80299d:	83 c4 0c             	add    $0xc,%esp
  8029a0:	68 07 04 00 00       	push   $0x407
  8029a5:	50                   	push   %eax
  8029a6:	6a 00                	push   $0x0
  8029a8:	e8 a0 e5 ff ff       	call   800f4d <sys_page_alloc>
  8029ad:	89 c3                	mov    %eax,%ebx
  8029af:	83 c4 10             	add    $0x10,%esp
  8029b2:	85 c0                	test   %eax,%eax
  8029b4:	0f 88 89 00 00 00    	js     802a43 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029ba:	83 ec 0c             	sub    $0xc,%esp
  8029bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8029c0:	e8 2e eb ff ff       	call   8014f3 <fd2data>
  8029c5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8029cc:	50                   	push   %eax
  8029cd:	6a 00                	push   $0x0
  8029cf:	56                   	push   %esi
  8029d0:	6a 00                	push   $0x0
  8029d2:	e8 b9 e5 ff ff       	call   800f90 <sys_page_map>
  8029d7:	89 c3                	mov    %eax,%ebx
  8029d9:	83 c4 20             	add    $0x20,%esp
  8029dc:	85 c0                	test   %eax,%eax
  8029de:	78 55                	js     802a35 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8029e0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029e9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8029eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8029f5:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029fe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a03:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a0a:	83 ec 0c             	sub    $0xc,%esp
  802a0d:	ff 75 f4             	pushl  -0xc(%ebp)
  802a10:	e8 ce ea ff ff       	call   8014e3 <fd2num>
  802a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a18:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802a1a:	83 c4 04             	add    $0x4,%esp
  802a1d:	ff 75 f0             	pushl  -0x10(%ebp)
  802a20:	e8 be ea ff ff       	call   8014e3 <fd2num>
  802a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a28:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802a2b:	83 c4 10             	add    $0x10,%esp
  802a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  802a33:	eb 30                	jmp    802a65 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802a35:	83 ec 08             	sub    $0x8,%esp
  802a38:	56                   	push   %esi
  802a39:	6a 00                	push   $0x0
  802a3b:	e8 92 e5 ff ff       	call   800fd2 <sys_page_unmap>
  802a40:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802a43:	83 ec 08             	sub    $0x8,%esp
  802a46:	ff 75 f0             	pushl  -0x10(%ebp)
  802a49:	6a 00                	push   $0x0
  802a4b:	e8 82 e5 ff ff       	call   800fd2 <sys_page_unmap>
  802a50:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802a53:	83 ec 08             	sub    $0x8,%esp
  802a56:	ff 75 f4             	pushl  -0xc(%ebp)
  802a59:	6a 00                	push   $0x0
  802a5b:	e8 72 e5 ff ff       	call   800fd2 <sys_page_unmap>
  802a60:	83 c4 10             	add    $0x10,%esp
  802a63:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802a65:	89 d0                	mov    %edx,%eax
  802a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a6a:	5b                   	pop    %ebx
  802a6b:	5e                   	pop    %esi
  802a6c:	5d                   	pop    %ebp
  802a6d:	c3                   	ret    

00802a6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802a6e:	55                   	push   %ebp
  802a6f:	89 e5                	mov    %esp,%ebp
  802a71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a77:	50                   	push   %eax
  802a78:	ff 75 08             	pushl  0x8(%ebp)
  802a7b:	e8 d9 ea ff ff       	call   801559 <fd_lookup>
  802a80:	89 c2                	mov    %eax,%edx
  802a82:	83 c4 10             	add    $0x10,%esp
  802a85:	85 d2                	test   %edx,%edx
  802a87:	78 18                	js     802aa1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a89:	83 ec 0c             	sub    $0xc,%esp
  802a8c:	ff 75 f4             	pushl  -0xc(%ebp)
  802a8f:	e8 5f ea ff ff       	call   8014f3 <fd2data>
	return _pipeisclosed(fd, p);
  802a94:	89 c2                	mov    %eax,%edx
  802a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a99:	e8 26 fd ff ff       	call   8027c4 <_pipeisclosed>
  802a9e:	83 c4 10             	add    $0x10,%esp
}
  802aa1:	c9                   	leave  
  802aa2:	c3                   	ret    

00802aa3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802aa3:	55                   	push   %ebp
  802aa4:	89 e5                	mov    %esp,%ebp
  802aa6:	56                   	push   %esi
  802aa7:	53                   	push   %ebx
  802aa8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802aab:	85 f6                	test   %esi,%esi
  802aad:	75 16                	jne    802ac5 <wait+0x22>
  802aaf:	68 56 37 80 00       	push   $0x803756
  802ab4:	68 1f 36 80 00       	push   $0x80361f
  802ab9:	6a 09                	push   $0x9
  802abb:	68 61 37 80 00       	push   $0x803761
  802ac0:	e8 1f da ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802ac5:	89 f3                	mov    %esi,%ebx
  802ac7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802acd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802ad0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802ad6:	eb 05                	jmp    802add <wait+0x3a>
		sys_yield();
  802ad8:	e8 51 e4 ff ff       	call   800f2e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802add:	8b 43 48             	mov    0x48(%ebx),%eax
  802ae0:	39 f0                	cmp    %esi,%eax
  802ae2:	75 07                	jne    802aeb <wait+0x48>
  802ae4:	8b 43 54             	mov    0x54(%ebx),%eax
  802ae7:	85 c0                	test   %eax,%eax
  802ae9:	75 ed                	jne    802ad8 <wait+0x35>
		sys_yield();
}
  802aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aee:	5b                   	pop    %ebx
  802aef:	5e                   	pop    %esi
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    

00802af2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802af2:	55                   	push   %ebp
  802af3:	89 e5                	mov    %esp,%ebp
  802af5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802af8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802aff:	75 2c                	jne    802b2d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802b01:	83 ec 04             	sub    $0x4,%esp
  802b04:	6a 07                	push   $0x7
  802b06:	68 00 f0 bf ee       	push   $0xeebff000
  802b0b:	6a 00                	push   $0x0
  802b0d:	e8 3b e4 ff ff       	call   800f4d <sys_page_alloc>
  802b12:	83 c4 10             	add    $0x10,%esp
  802b15:	85 c0                	test   %eax,%eax
  802b17:	74 14                	je     802b2d <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802b19:	83 ec 04             	sub    $0x4,%esp
  802b1c:	68 6c 37 80 00       	push   $0x80376c
  802b21:	6a 21                	push   $0x21
  802b23:	68 d0 37 80 00       	push   $0x8037d0
  802b28:	e8 b7 d9 ff ff       	call   8004e4 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  802b30:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802b35:	83 ec 08             	sub    $0x8,%esp
  802b38:	68 61 2b 80 00       	push   $0x802b61
  802b3d:	6a 00                	push   $0x0
  802b3f:	e8 54 e5 ff ff       	call   801098 <sys_env_set_pgfault_upcall>
  802b44:	83 c4 10             	add    $0x10,%esp
  802b47:	85 c0                	test   %eax,%eax
  802b49:	79 14                	jns    802b5f <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802b4b:	83 ec 04             	sub    $0x4,%esp
  802b4e:	68 98 37 80 00       	push   $0x803798
  802b53:	6a 29                	push   $0x29
  802b55:	68 d0 37 80 00       	push   $0x8037d0
  802b5a:	e8 85 d9 ff ff       	call   8004e4 <_panic>
}
  802b5f:	c9                   	leave  
  802b60:	c3                   	ret    

00802b61 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b61:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b62:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b67:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b69:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802b6c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802b71:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802b75:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802b79:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802b7b:	83 c4 08             	add    $0x8,%esp
        popal
  802b7e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802b7f:	83 c4 04             	add    $0x4,%esp
        popfl
  802b82:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802b83:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802b84:	c3                   	ret    

00802b85 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b85:	55                   	push   %ebp
  802b86:	89 e5                	mov    %esp,%ebp
  802b88:	56                   	push   %esi
  802b89:	53                   	push   %ebx
  802b8a:	8b 75 08             	mov    0x8(%ebp),%esi
  802b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802b93:	85 c0                	test   %eax,%eax
  802b95:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802b9a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802b9d:	83 ec 0c             	sub    $0xc,%esp
  802ba0:	50                   	push   %eax
  802ba1:	e8 57 e5 ff ff       	call   8010fd <sys_ipc_recv>
  802ba6:	83 c4 10             	add    $0x10,%esp
  802ba9:	85 c0                	test   %eax,%eax
  802bab:	79 16                	jns    802bc3 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802bad:	85 f6                	test   %esi,%esi
  802baf:	74 06                	je     802bb7 <ipc_recv+0x32>
  802bb1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802bb7:	85 db                	test   %ebx,%ebx
  802bb9:	74 2c                	je     802be7 <ipc_recv+0x62>
  802bbb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802bc1:	eb 24                	jmp    802be7 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802bc3:	85 f6                	test   %esi,%esi
  802bc5:	74 0a                	je     802bd1 <ipc_recv+0x4c>
  802bc7:	a1 08 50 80 00       	mov    0x805008,%eax
  802bcc:	8b 40 74             	mov    0x74(%eax),%eax
  802bcf:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802bd1:	85 db                	test   %ebx,%ebx
  802bd3:	74 0a                	je     802bdf <ipc_recv+0x5a>
  802bd5:	a1 08 50 80 00       	mov    0x805008,%eax
  802bda:	8b 40 78             	mov    0x78(%eax),%eax
  802bdd:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802bdf:	a1 08 50 80 00       	mov    0x805008,%eax
  802be4:	8b 40 70             	mov    0x70(%eax),%eax
}
  802be7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bea:	5b                   	pop    %ebx
  802beb:	5e                   	pop    %esi
  802bec:	5d                   	pop    %ebp
  802bed:	c3                   	ret    

00802bee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	57                   	push   %edi
  802bf2:	56                   	push   %esi
  802bf3:	53                   	push   %ebx
  802bf4:	83 ec 0c             	sub    $0xc,%esp
  802bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  802bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802c00:	85 db                	test   %ebx,%ebx
  802c02:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802c07:	0f 44 d8             	cmove  %eax,%ebx
  802c0a:	eb 1c                	jmp    802c28 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802c0c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c0f:	74 12                	je     802c23 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802c11:	50                   	push   %eax
  802c12:	68 de 37 80 00       	push   $0x8037de
  802c17:	6a 39                	push   $0x39
  802c19:	68 f9 37 80 00       	push   $0x8037f9
  802c1e:	e8 c1 d8 ff ff       	call   8004e4 <_panic>
                 sys_yield();
  802c23:	e8 06 e3 ff ff       	call   800f2e <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802c28:	ff 75 14             	pushl  0x14(%ebp)
  802c2b:	53                   	push   %ebx
  802c2c:	56                   	push   %esi
  802c2d:	57                   	push   %edi
  802c2e:	e8 a7 e4 ff ff       	call   8010da <sys_ipc_try_send>
  802c33:	83 c4 10             	add    $0x10,%esp
  802c36:	85 c0                	test   %eax,%eax
  802c38:	78 d2                	js     802c0c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c3d:	5b                   	pop    %ebx
  802c3e:	5e                   	pop    %esi
  802c3f:	5f                   	pop    %edi
  802c40:	5d                   	pop    %ebp
  802c41:	c3                   	ret    

00802c42 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c42:	55                   	push   %ebp
  802c43:	89 e5                	mov    %esp,%ebp
  802c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802c48:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c4d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802c50:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c56:	8b 52 50             	mov    0x50(%edx),%edx
  802c59:	39 ca                	cmp    %ecx,%edx
  802c5b:	75 0d                	jne    802c6a <ipc_find_env+0x28>
			return envs[i].env_id;
  802c5d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c60:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802c65:	8b 40 08             	mov    0x8(%eax),%eax
  802c68:	eb 0e                	jmp    802c78 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c6a:	83 c0 01             	add    $0x1,%eax
  802c6d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c72:	75 d9                	jne    802c4d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c74:	66 b8 00 00          	mov    $0x0,%ax
}
  802c78:	5d                   	pop    %ebp
  802c79:	c3                   	ret    

00802c7a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c7a:	55                   	push   %ebp
  802c7b:	89 e5                	mov    %esp,%ebp
  802c7d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c80:	89 d0                	mov    %edx,%eax
  802c82:	c1 e8 16             	shr    $0x16,%eax
  802c85:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802c8c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c91:	f6 c1 01             	test   $0x1,%cl
  802c94:	74 1d                	je     802cb3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802c96:	c1 ea 0c             	shr    $0xc,%edx
  802c99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802ca0:	f6 c2 01             	test   $0x1,%dl
  802ca3:	74 0e                	je     802cb3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ca5:	c1 ea 0c             	shr    $0xc,%edx
  802ca8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802caf:	ef 
  802cb0:	0f b7 c0             	movzwl %ax,%eax
}
  802cb3:	5d                   	pop    %ebp
  802cb4:	c3                   	ret    
  802cb5:	66 90                	xchg   %ax,%ax
  802cb7:	66 90                	xchg   %ax,%ax
  802cb9:	66 90                	xchg   %ax,%ax
  802cbb:	66 90                	xchg   %ax,%ax
  802cbd:	66 90                	xchg   %ax,%ax
  802cbf:	90                   	nop

00802cc0 <__udivdi3>:
  802cc0:	55                   	push   %ebp
  802cc1:	57                   	push   %edi
  802cc2:	56                   	push   %esi
  802cc3:	83 ec 10             	sub    $0x10,%esp
  802cc6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  802cca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  802cce:	8b 74 24 24          	mov    0x24(%esp),%esi
  802cd2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802cd6:	85 d2                	test   %edx,%edx
  802cd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802cdc:	89 34 24             	mov    %esi,(%esp)
  802cdf:	89 c8                	mov    %ecx,%eax
  802ce1:	75 35                	jne    802d18 <__udivdi3+0x58>
  802ce3:	39 f1                	cmp    %esi,%ecx
  802ce5:	0f 87 bd 00 00 00    	ja     802da8 <__udivdi3+0xe8>
  802ceb:	85 c9                	test   %ecx,%ecx
  802ced:	89 cd                	mov    %ecx,%ebp
  802cef:	75 0b                	jne    802cfc <__udivdi3+0x3c>
  802cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  802cf6:	31 d2                	xor    %edx,%edx
  802cf8:	f7 f1                	div    %ecx
  802cfa:	89 c5                	mov    %eax,%ebp
  802cfc:	89 f0                	mov    %esi,%eax
  802cfe:	31 d2                	xor    %edx,%edx
  802d00:	f7 f5                	div    %ebp
  802d02:	89 c6                	mov    %eax,%esi
  802d04:	89 f8                	mov    %edi,%eax
  802d06:	f7 f5                	div    %ebp
  802d08:	89 f2                	mov    %esi,%edx
  802d0a:	83 c4 10             	add    $0x10,%esp
  802d0d:	5e                   	pop    %esi
  802d0e:	5f                   	pop    %edi
  802d0f:	5d                   	pop    %ebp
  802d10:	c3                   	ret    
  802d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d18:	3b 14 24             	cmp    (%esp),%edx
  802d1b:	77 7b                	ja     802d98 <__udivdi3+0xd8>
  802d1d:	0f bd f2             	bsr    %edx,%esi
  802d20:	83 f6 1f             	xor    $0x1f,%esi
  802d23:	0f 84 97 00 00 00    	je     802dc0 <__udivdi3+0x100>
  802d29:	bd 20 00 00 00       	mov    $0x20,%ebp
  802d2e:	89 d7                	mov    %edx,%edi
  802d30:	89 f1                	mov    %esi,%ecx
  802d32:	29 f5                	sub    %esi,%ebp
  802d34:	d3 e7                	shl    %cl,%edi
  802d36:	89 c2                	mov    %eax,%edx
  802d38:	89 e9                	mov    %ebp,%ecx
  802d3a:	d3 ea                	shr    %cl,%edx
  802d3c:	89 f1                	mov    %esi,%ecx
  802d3e:	09 fa                	or     %edi,%edx
  802d40:	8b 3c 24             	mov    (%esp),%edi
  802d43:	d3 e0                	shl    %cl,%eax
  802d45:	89 54 24 08          	mov    %edx,0x8(%esp)
  802d49:	89 e9                	mov    %ebp,%ecx
  802d4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802d53:	89 fa                	mov    %edi,%edx
  802d55:	d3 ea                	shr    %cl,%edx
  802d57:	89 f1                	mov    %esi,%ecx
  802d59:	d3 e7                	shl    %cl,%edi
  802d5b:	89 e9                	mov    %ebp,%ecx
  802d5d:	d3 e8                	shr    %cl,%eax
  802d5f:	09 c7                	or     %eax,%edi
  802d61:	89 f8                	mov    %edi,%eax
  802d63:	f7 74 24 08          	divl   0x8(%esp)
  802d67:	89 d5                	mov    %edx,%ebp
  802d69:	89 c7                	mov    %eax,%edi
  802d6b:	f7 64 24 0c          	mull   0xc(%esp)
  802d6f:	39 d5                	cmp    %edx,%ebp
  802d71:	89 14 24             	mov    %edx,(%esp)
  802d74:	72 11                	jb     802d87 <__udivdi3+0xc7>
  802d76:	8b 54 24 04          	mov    0x4(%esp),%edx
  802d7a:	89 f1                	mov    %esi,%ecx
  802d7c:	d3 e2                	shl    %cl,%edx
  802d7e:	39 c2                	cmp    %eax,%edx
  802d80:	73 5e                	jae    802de0 <__udivdi3+0x120>
  802d82:	3b 2c 24             	cmp    (%esp),%ebp
  802d85:	75 59                	jne    802de0 <__udivdi3+0x120>
  802d87:	8d 47 ff             	lea    -0x1(%edi),%eax
  802d8a:	31 f6                	xor    %esi,%esi
  802d8c:	89 f2                	mov    %esi,%edx
  802d8e:	83 c4 10             	add    $0x10,%esp
  802d91:	5e                   	pop    %esi
  802d92:	5f                   	pop    %edi
  802d93:	5d                   	pop    %ebp
  802d94:	c3                   	ret    
  802d95:	8d 76 00             	lea    0x0(%esi),%esi
  802d98:	31 f6                	xor    %esi,%esi
  802d9a:	31 c0                	xor    %eax,%eax
  802d9c:	89 f2                	mov    %esi,%edx
  802d9e:	83 c4 10             	add    $0x10,%esp
  802da1:	5e                   	pop    %esi
  802da2:	5f                   	pop    %edi
  802da3:	5d                   	pop    %ebp
  802da4:	c3                   	ret    
  802da5:	8d 76 00             	lea    0x0(%esi),%esi
  802da8:	89 f2                	mov    %esi,%edx
  802daa:	31 f6                	xor    %esi,%esi
  802dac:	89 f8                	mov    %edi,%eax
  802dae:	f7 f1                	div    %ecx
  802db0:	89 f2                	mov    %esi,%edx
  802db2:	83 c4 10             	add    $0x10,%esp
  802db5:	5e                   	pop    %esi
  802db6:	5f                   	pop    %edi
  802db7:	5d                   	pop    %ebp
  802db8:	c3                   	ret    
  802db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802dc0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802dc4:	76 0b                	jbe    802dd1 <__udivdi3+0x111>
  802dc6:	31 c0                	xor    %eax,%eax
  802dc8:	3b 14 24             	cmp    (%esp),%edx
  802dcb:	0f 83 37 ff ff ff    	jae    802d08 <__udivdi3+0x48>
  802dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  802dd6:	e9 2d ff ff ff       	jmp    802d08 <__udivdi3+0x48>
  802ddb:	90                   	nop
  802ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802de0:	89 f8                	mov    %edi,%eax
  802de2:	31 f6                	xor    %esi,%esi
  802de4:	e9 1f ff ff ff       	jmp    802d08 <__udivdi3+0x48>
  802de9:	66 90                	xchg   %ax,%ax
  802deb:	66 90                	xchg   %ax,%ax
  802ded:	66 90                	xchg   %ax,%ax
  802def:	90                   	nop

00802df0 <__umoddi3>:
  802df0:	55                   	push   %ebp
  802df1:	57                   	push   %edi
  802df2:	56                   	push   %esi
  802df3:	83 ec 20             	sub    $0x20,%esp
  802df6:	8b 44 24 34          	mov    0x34(%esp),%eax
  802dfa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802dfe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802e02:	89 c6                	mov    %eax,%esi
  802e04:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e08:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802e0c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802e10:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e14:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802e18:	89 74 24 18          	mov    %esi,0x18(%esp)
  802e1c:	85 c0                	test   %eax,%eax
  802e1e:	89 c2                	mov    %eax,%edx
  802e20:	75 1e                	jne    802e40 <__umoddi3+0x50>
  802e22:	39 f7                	cmp    %esi,%edi
  802e24:	76 52                	jbe    802e78 <__umoddi3+0x88>
  802e26:	89 c8                	mov    %ecx,%eax
  802e28:	89 f2                	mov    %esi,%edx
  802e2a:	f7 f7                	div    %edi
  802e2c:	89 d0                	mov    %edx,%eax
  802e2e:	31 d2                	xor    %edx,%edx
  802e30:	83 c4 20             	add    $0x20,%esp
  802e33:	5e                   	pop    %esi
  802e34:	5f                   	pop    %edi
  802e35:	5d                   	pop    %ebp
  802e36:	c3                   	ret    
  802e37:	89 f6                	mov    %esi,%esi
  802e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802e40:	39 f0                	cmp    %esi,%eax
  802e42:	77 5c                	ja     802ea0 <__umoddi3+0xb0>
  802e44:	0f bd e8             	bsr    %eax,%ebp
  802e47:	83 f5 1f             	xor    $0x1f,%ebp
  802e4a:	75 64                	jne    802eb0 <__umoddi3+0xc0>
  802e4c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802e50:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802e54:	0f 86 f6 00 00 00    	jbe    802f50 <__umoddi3+0x160>
  802e5a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802e5e:	0f 82 ec 00 00 00    	jb     802f50 <__umoddi3+0x160>
  802e64:	8b 44 24 14          	mov    0x14(%esp),%eax
  802e68:	8b 54 24 18          	mov    0x18(%esp),%edx
  802e6c:	83 c4 20             	add    $0x20,%esp
  802e6f:	5e                   	pop    %esi
  802e70:	5f                   	pop    %edi
  802e71:	5d                   	pop    %ebp
  802e72:	c3                   	ret    
  802e73:	90                   	nop
  802e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e78:	85 ff                	test   %edi,%edi
  802e7a:	89 fd                	mov    %edi,%ebp
  802e7c:	75 0b                	jne    802e89 <__umoddi3+0x99>
  802e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  802e83:	31 d2                	xor    %edx,%edx
  802e85:	f7 f7                	div    %edi
  802e87:	89 c5                	mov    %eax,%ebp
  802e89:	8b 44 24 10          	mov    0x10(%esp),%eax
  802e8d:	31 d2                	xor    %edx,%edx
  802e8f:	f7 f5                	div    %ebp
  802e91:	89 c8                	mov    %ecx,%eax
  802e93:	f7 f5                	div    %ebp
  802e95:	eb 95                	jmp    802e2c <__umoddi3+0x3c>
  802e97:	89 f6                	mov    %esi,%esi
  802e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802ea0:	89 c8                	mov    %ecx,%eax
  802ea2:	89 f2                	mov    %esi,%edx
  802ea4:	83 c4 20             	add    $0x20,%esp
  802ea7:	5e                   	pop    %esi
  802ea8:	5f                   	pop    %edi
  802ea9:	5d                   	pop    %ebp
  802eaa:	c3                   	ret    
  802eab:	90                   	nop
  802eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802eb0:	b8 20 00 00 00       	mov    $0x20,%eax
  802eb5:	89 e9                	mov    %ebp,%ecx
  802eb7:	29 e8                	sub    %ebp,%eax
  802eb9:	d3 e2                	shl    %cl,%edx
  802ebb:	89 c7                	mov    %eax,%edi
  802ebd:	89 44 24 18          	mov    %eax,0x18(%esp)
  802ec1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ec5:	89 f9                	mov    %edi,%ecx
  802ec7:	d3 e8                	shr    %cl,%eax
  802ec9:	89 c1                	mov    %eax,%ecx
  802ecb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ecf:	09 d1                	or     %edx,%ecx
  802ed1:	89 fa                	mov    %edi,%edx
  802ed3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802ed7:	89 e9                	mov    %ebp,%ecx
  802ed9:	d3 e0                	shl    %cl,%eax
  802edb:	89 f9                	mov    %edi,%ecx
  802edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ee1:	89 f0                	mov    %esi,%eax
  802ee3:	d3 e8                	shr    %cl,%eax
  802ee5:	89 e9                	mov    %ebp,%ecx
  802ee7:	89 c7                	mov    %eax,%edi
  802ee9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802eed:	d3 e6                	shl    %cl,%esi
  802eef:	89 d1                	mov    %edx,%ecx
  802ef1:	89 fa                	mov    %edi,%edx
  802ef3:	d3 e8                	shr    %cl,%eax
  802ef5:	89 e9                	mov    %ebp,%ecx
  802ef7:	09 f0                	or     %esi,%eax
  802ef9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  802efd:	f7 74 24 10          	divl   0x10(%esp)
  802f01:	d3 e6                	shl    %cl,%esi
  802f03:	89 d1                	mov    %edx,%ecx
  802f05:	f7 64 24 0c          	mull   0xc(%esp)
  802f09:	39 d1                	cmp    %edx,%ecx
  802f0b:	89 74 24 14          	mov    %esi,0x14(%esp)
  802f0f:	89 d7                	mov    %edx,%edi
  802f11:	89 c6                	mov    %eax,%esi
  802f13:	72 0a                	jb     802f1f <__umoddi3+0x12f>
  802f15:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802f19:	73 10                	jae    802f2b <__umoddi3+0x13b>
  802f1b:	39 d1                	cmp    %edx,%ecx
  802f1d:	75 0c                	jne    802f2b <__umoddi3+0x13b>
  802f1f:	89 d7                	mov    %edx,%edi
  802f21:	89 c6                	mov    %eax,%esi
  802f23:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802f27:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802f2b:	89 ca                	mov    %ecx,%edx
  802f2d:	89 e9                	mov    %ebp,%ecx
  802f2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802f33:	29 f0                	sub    %esi,%eax
  802f35:	19 fa                	sbb    %edi,%edx
  802f37:	d3 e8                	shr    %cl,%eax
  802f39:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802f3e:	89 d7                	mov    %edx,%edi
  802f40:	d3 e7                	shl    %cl,%edi
  802f42:	89 e9                	mov    %ebp,%ecx
  802f44:	09 f8                	or     %edi,%eax
  802f46:	d3 ea                	shr    %cl,%edx
  802f48:	83 c4 20             	add    $0x20,%esp
  802f4b:	5e                   	pop    %esi
  802f4c:	5f                   	pop    %edi
  802f4d:	5d                   	pop    %ebp
  802f4e:	c3                   	ret    
  802f4f:	90                   	nop
  802f50:	8b 74 24 10          	mov    0x10(%esp),%esi
  802f54:	29 f9                	sub    %edi,%ecx
  802f56:	19 c6                	sbb    %eax,%esi
  802f58:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802f5c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802f60:	e9 ff fe ff ff       	jmp    802e64 <__umoddi3+0x74>
