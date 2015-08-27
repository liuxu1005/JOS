
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
  80004a:	e8 35 18 00 00       	call   801884 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 2b 18 00 00       	call   801884 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
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
  80008d:	e8 90 16 00 00       	call   801722 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2a 80 00       	push   $0x802afa
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
  8000c2:	e8 5b 16 00 00       	call   801722 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2a 80 00       	push   $0x802af5
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
  8000f6:	e8 e7 14 00 00       	call   8015e2 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 db 14 00 00       	call   8015e2 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 2b 80 00       	push   $0x802b08
  80011b:	e8 af 1a 00 00       	call   801bcf <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 15 2b 80 00       	push   $0x802b15
  80012f:	6a 13                	push   $0x13
  800131:	68 2b 2b 80 00       	push   $0x802b2b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 bd 22 00 00       	call   802404 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 3c 2b 80 00       	push   $0x802b3c
  800154:	6a 15                	push   $0x15
  800156:	68 2b 2b 80 00       	push   $0x802b2b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 a4 2a 80 00       	push   $0x802aa4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 ab 10 00 00       	call   801220 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 1b 30 80 00       	push   $0x80301b
  800182:	6a 1a                	push   $0x1a
  800184:	68 2b 2b 80 00       	push   $0x802b2b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 97 14 00 00       	call   801634 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 8c 14 00 00       	call   801634 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 32 14 00 00       	call   8015e2 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 2a 14 00 00       	call   8015e2 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 45 2b 80 00       	push   $0x802b45
  8001bf:	68 12 2b 80 00       	push   $0x802b12
  8001c4:	68 48 2b 80 00       	push   $0x802b48
  8001c9:	e8 f2 1f 00 00       	call   8021c0 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 4c 2b 80 00       	push   $0x802b4c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 2b 2b 80 00       	push   $0x802b2b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 ef 13 00 00       	call   8015e2 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 e3 13 00 00       	call   8015e2 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 85 23 00 00       	call   80258c <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 ca 13 00 00       	call   8015e2 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 c2 13 00 00       	call   8015e2 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 56 2b 80 00       	push   $0x802b56
  800230:	e8 9a 19 00 00       	call   801bcf <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 c8 2a 80 00       	push   $0x802ac8
  800245:	6a 2c                	push   $0x2c
  800247:	68 2b 2b 80 00       	push   $0x802b2b
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
  800267:	e8 b6 14 00 00       	call   801722 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 a3 14 00 00       	call   801722 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 64 2b 80 00       	push   $0x802b64
  80028c:	6a 33                	push   $0x33
  80028e:	68 2b 2b 80 00       	push   $0x802b2b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 7e 2b 80 00       	push   $0x802b7e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 2b 2b 80 00       	push   $0x802b2b
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
  8002eb:	68 98 2b 80 00       	push   $0x802b98
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
  800311:	68 ad 2b 80 00       	push   $0x802bad
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
  8003e1:	e8 3c 13 00 00       	call   801722 <read>
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
  80040b:	e8 a8 10 00 00       	call   8014b8 <fd_lookup>
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
  800434:	e8 30 10 00 00       	call   801469 <fd_alloc>
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
  800476:	e8 c7 0f 00 00       	call   801442 <fd2num>
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
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

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
  8004d0:	e8 3a 11 00 00       	call   80160f <close_all>
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
  800502:	68 c4 2b 80 00       	push   $0x802bc4
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
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
  800620:	e8 7b 21 00 00       	call   8027a0 <__udivdi3>
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
  80065e:	e8 6d 22 00 00       	call   8028d0 <__umoddi3>
  800663:	83 c4 14             	add    $0x14,%esp
  800666:	0f be 80 e7 2b 80 00 	movsbl 0x802be7(%eax),%eax
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
  800762:	ff 24 85 40 2d 80 00 	jmp    *0x802d40(,%eax,4)
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
  800826:	8b 14 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%edx
  80082d:	85 d2                	test   %edx,%edx
  80082f:	75 18                	jne    800849 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800831:	50                   	push   %eax
  800832:	68 ff 2b 80 00       	push   $0x802bff
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
  80084a:	68 2d 31 80 00       	push   $0x80312d
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
  800877:	ba f8 2b 80 00       	mov    $0x802bf8,%edx
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
  800ef6:	68 1f 2f 80 00       	push   $0x802f1f
  800efb:	6a 23                	push   $0x23
  800efd:	68 3c 2f 80 00       	push   $0x802f3c
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
  800f77:	68 1f 2f 80 00       	push   $0x802f1f
  800f7c:	6a 23                	push   $0x23
  800f7e:	68 3c 2f 80 00       	push   $0x802f3c
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
  800fb9:	68 1f 2f 80 00       	push   $0x802f1f
  800fbe:	6a 23                	push   $0x23
  800fc0:	68 3c 2f 80 00       	push   $0x802f3c
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
  800ffb:	68 1f 2f 80 00       	push   $0x802f1f
  801000:	6a 23                	push   $0x23
  801002:	68 3c 2f 80 00       	push   $0x802f3c
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
  80103d:	68 1f 2f 80 00       	push   $0x802f1f
  801042:	6a 23                	push   $0x23
  801044:	68 3c 2f 80 00       	push   $0x802f3c
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
  80107f:	68 1f 2f 80 00       	push   $0x802f1f
  801084:	6a 23                	push   $0x23
  801086:	68 3c 2f 80 00       	push   $0x802f3c
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
  8010c1:	68 1f 2f 80 00       	push   $0x802f1f
  8010c6:	6a 23                	push   $0x23
  8010c8:	68 3c 2f 80 00       	push   $0x802f3c
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
  801125:	68 1f 2f 80 00       	push   $0x802f1f
  80112a:	6a 23                	push   $0x23
  80112c:	68 3c 2f 80 00       	push   $0x802f3c
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

0080113e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	53                   	push   %ebx
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801148:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  80114a:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80114e:	74 2e                	je     80117e <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801150:	89 c2                	mov    %eax,%edx
  801152:	c1 ea 16             	shr    $0x16,%edx
  801155:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115c:	f6 c2 01             	test   $0x1,%dl
  80115f:	74 1d                	je     80117e <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801161:	89 c2                	mov    %eax,%edx
  801163:	c1 ea 0c             	shr    $0xc,%edx
  801166:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80116d:	f6 c1 01             	test   $0x1,%cl
  801170:	74 0c                	je     80117e <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801172:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801179:	f6 c6 08             	test   $0x8,%dh
  80117c:	75 14                	jne    801192 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	68 4c 2f 80 00       	push   $0x802f4c
  801186:	6a 21                	push   $0x21
  801188:	68 df 2f 80 00       	push   $0x802fdf
  80118d:	e8 52 f3 ff ff       	call   8004e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  801192:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801197:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	6a 07                	push   $0x7
  80119e:	68 00 f0 7f 00       	push   $0x7ff000
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 a3 fd ff ff       	call   800f4d <sys_page_alloc>
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	79 14                	jns    8011c5 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	68 ea 2f 80 00       	push   $0x802fea
  8011b9:	6a 2b                	push   $0x2b
  8011bb:	68 df 2f 80 00       	push   $0x802fdf
  8011c0:	e8 1f f3 ff ff       	call   8004e4 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	68 00 10 00 00       	push   $0x1000
  8011cd:	53                   	push   %ebx
  8011ce:	68 00 f0 7f 00       	push   $0x7ff000
  8011d3:	e8 fe fa ff ff       	call   800cd6 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  8011d8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011df:	53                   	push   %ebx
  8011e0:	6a 00                	push   $0x0
  8011e2:	68 00 f0 7f 00       	push   $0x7ff000
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 a2 fd ff ff       	call   800f90 <sys_page_map>
  8011ee:	83 c4 20             	add    $0x20,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 14                	jns    801209 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	68 00 30 80 00       	push   $0x803000
  8011fd:	6a 2e                	push   $0x2e
  8011ff:	68 df 2f 80 00       	push   $0x802fdf
  801204:	e8 db f2 ff ff       	call   8004e4 <_panic>
        sys_page_unmap(0, PFTEMP); 
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	68 00 f0 7f 00       	push   $0x7ff000
  801211:	6a 00                	push   $0x0
  801213:	e8 ba fd ff ff       	call   800fd2 <sys_page_unmap>
  801218:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  801229:	68 3e 11 80 00       	push   $0x80113e
  80122e:	e8 a8 13 00 00       	call   8025db <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801233:	b8 07 00 00 00       	mov    $0x7,%eax
  801238:	cd 30                	int    $0x30
  80123a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	79 12                	jns    801256 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801244:	50                   	push   %eax
  801245:	68 14 30 80 00       	push   $0x803014
  80124a:	6a 6d                	push   $0x6d
  80124c:	68 df 2f 80 00       	push   $0x802fdf
  801251:	e8 8e f2 ff ff       	call   8004e4 <_panic>
  801256:	89 c7                	mov    %eax,%edi
  801258:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  80125d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801261:	75 21                	jne    801284 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801263:	e8 a7 fc ff ff       	call   800f0f <sys_getenvid>
  801268:	25 ff 03 00 00       	and    $0x3ff,%eax
  80126d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801270:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801275:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
  80127f:	e9 9c 01 00 00       	jmp    801420 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801284:	89 d8                	mov    %ebx,%eax
  801286:	c1 e8 16             	shr    $0x16,%eax
  801289:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801290:	a8 01                	test   $0x1,%al
  801292:	0f 84 f3 00 00 00    	je     80138b <fork+0x16b>
  801298:	89 d8                	mov    %ebx,%eax
  80129a:	c1 e8 0c             	shr    $0xc,%eax
  80129d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	0f 84 de 00 00 00    	je     80138b <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8012ad:	89 c6                	mov    %eax,%esi
  8012af:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8012b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b9:	f6 c6 04             	test   $0x4,%dh
  8012bc:	74 37                	je     8012f5 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8012be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cd:	50                   	push   %eax
  8012ce:	56                   	push   %esi
  8012cf:	57                   	push   %edi
  8012d0:	56                   	push   %esi
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 b8 fc ff ff       	call   800f90 <sys_page_map>
  8012d8:	83 c4 20             	add    $0x20,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 89 a8 00 00 00    	jns    80138b <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  8012e3:	50                   	push   %eax
  8012e4:	68 70 2f 80 00       	push   $0x802f70
  8012e9:	6a 49                	push   $0x49
  8012eb:	68 df 2f 80 00       	push   $0x802fdf
  8012f0:	e8 ef f1 ff ff       	call   8004e4 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8012f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012fc:	f6 c6 08             	test   $0x8,%dh
  8012ff:	75 0b                	jne    80130c <fork+0xec>
  801301:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801308:	a8 02                	test   $0x2,%al
  80130a:	74 57                	je     801363 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	68 05 08 00 00       	push   $0x805
  801314:	56                   	push   %esi
  801315:	57                   	push   %edi
  801316:	56                   	push   %esi
  801317:	6a 00                	push   $0x0
  801319:	e8 72 fc ff ff       	call   800f90 <sys_page_map>
  80131e:	83 c4 20             	add    $0x20,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	79 12                	jns    801337 <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  801325:	50                   	push   %eax
  801326:	68 70 2f 80 00       	push   $0x802f70
  80132b:	6a 4c                	push   $0x4c
  80132d:	68 df 2f 80 00       	push   $0x802fdf
  801332:	e8 ad f1 ff ff       	call   8004e4 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	68 05 08 00 00       	push   $0x805
  80133f:	56                   	push   %esi
  801340:	6a 00                	push   $0x0
  801342:	56                   	push   %esi
  801343:	6a 00                	push   $0x0
  801345:	e8 46 fc ff ff       	call   800f90 <sys_page_map>
  80134a:	83 c4 20             	add    $0x20,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	79 3a                	jns    80138b <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801351:	50                   	push   %eax
  801352:	68 94 2f 80 00       	push   $0x802f94
  801357:	6a 4e                	push   $0x4e
  801359:	68 df 2f 80 00       	push   $0x802fdf
  80135e:	e8 81 f1 ff ff       	call   8004e4 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	6a 05                	push   $0x5
  801368:	56                   	push   %esi
  801369:	57                   	push   %edi
  80136a:	56                   	push   %esi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 1e fc ff ff       	call   800f90 <sys_page_map>
  801372:	83 c4 20             	add    $0x20,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	79 12                	jns    80138b <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  801379:	50                   	push   %eax
  80137a:	68 bc 2f 80 00       	push   $0x802fbc
  80137f:	6a 50                	push   $0x50
  801381:	68 df 2f 80 00       	push   $0x802fdf
  801386:	e8 59 f1 ff ff       	call   8004e4 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80138b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801391:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801397:	0f 85 e7 fe ff ff    	jne    801284 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	6a 07                	push   $0x7
  8013a2:	68 00 f0 bf ee       	push   $0xeebff000
  8013a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013aa:	e8 9e fb ff ff       	call   800f4d <sys_page_alloc>
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	79 14                	jns    8013ca <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	68 24 30 80 00       	push   $0x803024
  8013be:	6a 76                	push   $0x76
  8013c0:	68 df 2f 80 00       	push   $0x802fdf
  8013c5:	e8 1a f1 ff ff       	call   8004e4 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	68 4a 26 80 00       	push   $0x80264a
  8013d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d5:	e8 be fc ff ff       	call   801098 <sys_env_set_pgfault_upcall>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	79 14                	jns    8013f5 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  8013e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e4:	68 3e 30 80 00       	push   $0x80303e
  8013e9:	6a 79                	push   $0x79
  8013eb:	68 df 2f 80 00       	push   $0x802fdf
  8013f0:	e8 ef f0 ff ff       	call   8004e4 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 02                	push   $0x2
  8013fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013fd:	e8 12 fc ff ff       	call   801014 <sys_env_set_status>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	79 14                	jns    80141d <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801409:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140c:	68 5b 30 80 00       	push   $0x80305b
  801411:	6a 7b                	push   $0x7b
  801413:	68 df 2f 80 00       	push   $0x802fdf
  801418:	e8 c7 f0 ff ff       	call   8004e4 <_panic>
        return forkid;
  80141d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <sfork>:

// Challenge!
int
sfork(void)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80142e:	68 72 30 80 00       	push   $0x803072
  801433:	68 83 00 00 00       	push   $0x83
  801438:	68 df 2f 80 00       	push   $0x802fdf
  80143d:	e8 a2 f0 ff ff       	call   8004e4 <_panic>

00801442 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	05 00 00 00 30       	add    $0x30000000,%eax
  80144d:	c1 e8 0c             	shr    $0xc,%eax
}
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80145d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801462:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801474:	89 c2                	mov    %eax,%edx
  801476:	c1 ea 16             	shr    $0x16,%edx
  801479:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801480:	f6 c2 01             	test   $0x1,%dl
  801483:	74 11                	je     801496 <fd_alloc+0x2d>
  801485:	89 c2                	mov    %eax,%edx
  801487:	c1 ea 0c             	shr    $0xc,%edx
  80148a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801491:	f6 c2 01             	test   $0x1,%dl
  801494:	75 09                	jne    80149f <fd_alloc+0x36>
			*fd_store = fd;
  801496:	89 01                	mov    %eax,(%ecx)
			return 0;
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
  80149d:	eb 17                	jmp    8014b6 <fd_alloc+0x4d>
  80149f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a9:	75 c9                	jne    801474 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ab:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014b1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014be:	83 f8 1f             	cmp    $0x1f,%eax
  8014c1:	77 36                	ja     8014f9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c3:	c1 e0 0c             	shl    $0xc,%eax
  8014c6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	c1 ea 16             	shr    $0x16,%edx
  8014d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d7:	f6 c2 01             	test   $0x1,%dl
  8014da:	74 24                	je     801500 <fd_lookup+0x48>
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	c1 ea 0c             	shr    $0xc,%edx
  8014e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e8:	f6 c2 01             	test   $0x1,%dl
  8014eb:	74 1a                	je     801507 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f0:	89 02                	mov    %eax,(%edx)
	return 0;
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f7:	eb 13                	jmp    80150c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fe:	eb 0c                	jmp    80150c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801505:	eb 05                	jmp    80150c <fd_lookup+0x54>
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801517:	ba 04 31 80 00       	mov    $0x803104,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80151c:	eb 13                	jmp    801531 <dev_lookup+0x23>
  80151e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801521:	39 08                	cmp    %ecx,(%eax)
  801523:	75 0c                	jne    801531 <dev_lookup+0x23>
			*dev = devtab[i];
  801525:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801528:	89 01                	mov    %eax,(%ecx)
			return 0;
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
  80152f:	eb 2e                	jmp    80155f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801531:	8b 02                	mov    (%edx),%eax
  801533:	85 c0                	test   %eax,%eax
  801535:	75 e7                	jne    80151e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801537:	a1 04 50 80 00       	mov    0x805004,%eax
  80153c:	8b 40 48             	mov    0x48(%eax),%eax
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	51                   	push   %ecx
  801543:	50                   	push   %eax
  801544:	68 88 30 80 00       	push   $0x803088
  801549:	e8 6f f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80154e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801551:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 10             	sub    $0x10,%esp
  801569:	8b 75 08             	mov    0x8(%ebp),%esi
  80156c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801573:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801579:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157c:	50                   	push   %eax
  80157d:	e8 36 ff ff ff       	call   8014b8 <fd_lookup>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 05                	js     80158e <fd_close+0x2d>
	    || fd != fd2)
  801589:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80158c:	74 0c                	je     80159a <fd_close+0x39>
		return (must_exist ? r : 0);
  80158e:	84 db                	test   %bl,%bl
  801590:	ba 00 00 00 00       	mov    $0x0,%edx
  801595:	0f 44 c2             	cmove  %edx,%eax
  801598:	eb 41                	jmp    8015db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 36                	pushl  (%esi)
  8015a3:	e8 66 ff ff ff       	call   80150e <dev_lookup>
  8015a8:	89 c3                	mov    %eax,%ebx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 1a                	js     8015cb <fd_close+0x6a>
		if (dev->dev_close)
  8015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	74 0b                	je     8015cb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	56                   	push   %esi
  8015c4:	ff d0                	call   *%eax
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	56                   	push   %esi
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 fc f9 ff ff       	call   800fd2 <sys_page_unmap>
	return r;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	89 d8                	mov    %ebx,%eax
}
  8015db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 c4 fe ff ff       	call   8014b8 <fd_lookup>
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	85 d2                	test   %edx,%edx
  8015fb:	78 10                	js     80160d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	6a 01                	push   $0x1
  801602:	ff 75 f4             	pushl  -0xc(%ebp)
  801605:	e8 57 ff ff ff       	call   801561 <fd_close>
  80160a:	83 c4 10             	add    $0x10,%esp
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <close_all>:

void
close_all(void)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801616:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	53                   	push   %ebx
  80161f:	e8 be ff ff ff       	call   8015e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801624:	83 c3 01             	add    $0x1,%ebx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	83 fb 20             	cmp    $0x20,%ebx
  80162d:	75 ec                	jne    80161b <close_all+0xc>
		close(i);
}
  80162f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	57                   	push   %edi
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
  80163a:	83 ec 2c             	sub    $0x2c,%esp
  80163d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801640:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 6c fe ff ff       	call   8014b8 <fd_lookup>
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 08             	add    $0x8,%esp
  801651:	85 d2                	test   %edx,%edx
  801653:	0f 88 c1 00 00 00    	js     80171a <dup+0xe6>
		return r;
	close(newfdnum);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	56                   	push   %esi
  80165d:	e8 80 ff ff ff       	call   8015e2 <close>

	newfd = INDEX2FD(newfdnum);
  801662:	89 f3                	mov    %esi,%ebx
  801664:	c1 e3 0c             	shl    $0xc,%ebx
  801667:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80166d:	83 c4 04             	add    $0x4,%esp
  801670:	ff 75 e4             	pushl  -0x1c(%ebp)
  801673:	e8 da fd ff ff       	call   801452 <fd2data>
  801678:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80167a:	89 1c 24             	mov    %ebx,(%esp)
  80167d:	e8 d0 fd ff ff       	call   801452 <fd2data>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801688:	89 f8                	mov    %edi,%eax
  80168a:	c1 e8 16             	shr    $0x16,%eax
  80168d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801694:	a8 01                	test   $0x1,%al
  801696:	74 37                	je     8016cf <dup+0x9b>
  801698:	89 f8                	mov    %edi,%eax
  80169a:	c1 e8 0c             	shr    $0xc,%eax
  80169d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016a4:	f6 c2 01             	test   $0x1,%dl
  8016a7:	74 26                	je     8016cf <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b0:	83 ec 0c             	sub    $0xc,%esp
  8016b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016bc:	6a 00                	push   $0x0
  8016be:	57                   	push   %edi
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 ca f8 ff ff       	call   800f90 <sys_page_map>
  8016c6:	89 c7                	mov    %eax,%edi
  8016c8:	83 c4 20             	add    $0x20,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 2e                	js     8016fd <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d2:	89 d0                	mov    %edx,%eax
  8016d4:	c1 e8 0c             	shr    $0xc,%eax
  8016d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016de:	83 ec 0c             	sub    $0xc,%esp
  8016e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e6:	50                   	push   %eax
  8016e7:	53                   	push   %ebx
  8016e8:	6a 00                	push   $0x0
  8016ea:	52                   	push   %edx
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 9e f8 ff ff       	call   800f90 <sys_page_map>
  8016f2:	89 c7                	mov    %eax,%edi
  8016f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f9:	85 ff                	test   %edi,%edi
  8016fb:	79 1d                	jns    80171a <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	53                   	push   %ebx
  801701:	6a 00                	push   $0x0
  801703:	e8 ca f8 ff ff       	call   800fd2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801708:	83 c4 08             	add    $0x8,%esp
  80170b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80170e:	6a 00                	push   $0x0
  801710:	e8 bd f8 ff ff       	call   800fd2 <sys_page_unmap>
	return r;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	89 f8                	mov    %edi,%eax
}
  80171a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5f                   	pop    %edi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 14             	sub    $0x14,%esp
  801729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	53                   	push   %ebx
  801731:	e8 82 fd ff ff       	call   8014b8 <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 6d                	js     8017ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	ff 30                	pushl  (%eax)
  80174b:	e8 be fd ff ff       	call   80150e <dev_lookup>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 4c                	js     8017a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801757:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80175a:	8b 42 08             	mov    0x8(%edx),%eax
  80175d:	83 e0 03             	and    $0x3,%eax
  801760:	83 f8 01             	cmp    $0x1,%eax
  801763:	75 21                	jne    801786 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801765:	a1 04 50 80 00       	mov    0x805004,%eax
  80176a:	8b 40 48             	mov    0x48(%eax),%eax
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	53                   	push   %ebx
  801771:	50                   	push   %eax
  801772:	68 c9 30 80 00       	push   $0x8030c9
  801777:	e8 41 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801784:	eb 26                	jmp    8017ac <read+0x8a>
	}
	if (!dev->dev_read)
  801786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801789:	8b 40 08             	mov    0x8(%eax),%eax
  80178c:	85 c0                	test   %eax,%eax
  80178e:	74 17                	je     8017a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	52                   	push   %edx
  80179a:	ff d0                	call   *%eax
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	eb 09                	jmp    8017ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	89 c2                	mov    %eax,%edx
  8017a5:	eb 05                	jmp    8017ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017ac:	89 d0                	mov    %edx,%eax
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	57                   	push   %edi
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c7:	eb 21                	jmp    8017ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	89 f0                	mov    %esi,%eax
  8017ce:	29 d8                	sub    %ebx,%eax
  8017d0:	50                   	push   %eax
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	03 45 0c             	add    0xc(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	57                   	push   %edi
  8017d8:	e8 45 ff ff ff       	call   801722 <read>
		if (m < 0)
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 0c                	js     8017f0 <readn+0x3d>
			return m;
		if (m == 0)
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	74 06                	je     8017ee <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e8:	01 c3                	add    %eax,%ebx
  8017ea:	39 f3                	cmp    %esi,%ebx
  8017ec:	72 db                	jb     8017c9 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8017ee:	89 d8                	mov    %ebx,%eax
}
  8017f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 14             	sub    $0x14,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801802:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	53                   	push   %ebx
  801807:	e8 ac fc ff ff       	call   8014b8 <fd_lookup>
  80180c:	83 c4 08             	add    $0x8,%esp
  80180f:	89 c2                	mov    %eax,%edx
  801811:	85 c0                	test   %eax,%eax
  801813:	78 68                	js     80187d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181f:	ff 30                	pushl  (%eax)
  801821:	e8 e8 fc ff ff       	call   80150e <dev_lookup>
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 47                	js     801874 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801834:	75 21                	jne    801857 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801836:	a1 04 50 80 00       	mov    0x805004,%eax
  80183b:	8b 40 48             	mov    0x48(%eax),%eax
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	53                   	push   %ebx
  801842:	50                   	push   %eax
  801843:	68 e5 30 80 00       	push   $0x8030e5
  801848:	e8 70 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801855:	eb 26                	jmp    80187d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185a:	8b 52 0c             	mov    0xc(%edx),%edx
  80185d:	85 d2                	test   %edx,%edx
  80185f:	74 17                	je     801878 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	ff 75 10             	pushl  0x10(%ebp)
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	50                   	push   %eax
  80186b:	ff d2                	call   *%edx
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	eb 09                	jmp    80187d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801874:	89 c2                	mov    %eax,%edx
  801876:	eb 05                	jmp    80187d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801878:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <seek>:

int
seek(int fdnum, off_t offset)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	ff 75 08             	pushl  0x8(%ebp)
  801891:	e8 22 fc ff ff       	call   8014b8 <fd_lookup>
  801896:	83 c4 08             	add    $0x8,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 0e                	js     8018ab <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80189d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 14             	sub    $0x14,%esp
  8018b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ba:	50                   	push   %eax
  8018bb:	53                   	push   %ebx
  8018bc:	e8 f7 fb ff ff       	call   8014b8 <fd_lookup>
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 65                	js     80192f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d0:	50                   	push   %eax
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	ff 30                	pushl  (%eax)
  8018d6:	e8 33 fc ff ff       	call   80150e <dev_lookup>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 44                	js     801926 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e9:	75 21                	jne    80190c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018eb:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f0:	8b 40 48             	mov    0x48(%eax),%eax
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	50                   	push   %eax
  8018f8:	68 a8 30 80 00       	push   $0x8030a8
  8018fd:	e8 bb ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80190a:	eb 23                	jmp    80192f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	8b 52 18             	mov    0x18(%edx),%edx
  801912:	85 d2                	test   %edx,%edx
  801914:	74 14                	je     80192a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	50                   	push   %eax
  80191d:	ff d2                	call   *%edx
  80191f:	89 c2                	mov    %eax,%edx
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	eb 09                	jmp    80192f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	89 c2                	mov    %eax,%edx
  801928:	eb 05                	jmp    80192f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80192a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 14             	sub    $0x14,%esp
  80193d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801940:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	ff 75 08             	pushl  0x8(%ebp)
  801947:	e8 6c fb ff ff       	call   8014b8 <fd_lookup>
  80194c:	83 c4 08             	add    $0x8,%esp
  80194f:	89 c2                	mov    %eax,%edx
  801951:	85 c0                	test   %eax,%eax
  801953:	78 58                	js     8019ad <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195b:	50                   	push   %eax
  80195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195f:	ff 30                	pushl  (%eax)
  801961:	e8 a8 fb ff ff       	call   80150e <dev_lookup>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 37                	js     8019a4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801970:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801974:	74 32                	je     8019a8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801976:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801979:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801980:	00 00 00 
	stat->st_isdir = 0;
  801983:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198a:	00 00 00 
	stat->st_dev = dev;
  80198d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	ff 75 f0             	pushl  -0x10(%ebp)
  80199a:	ff 50 14             	call   *0x14(%eax)
  80199d:	89 c2                	mov    %eax,%edx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 09                	jmp    8019ad <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	eb 05                	jmp    8019ad <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019ad:	89 d0                	mov    %edx,%eax
  8019af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 08             	pushl  0x8(%ebp)
  8019c1:	e8 09 02 00 00       	call   801bcf <open>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 db                	test   %ebx,%ebx
  8019cd:	78 1b                	js     8019ea <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 75 0c             	pushl  0xc(%ebp)
  8019d5:	53                   	push   %ebx
  8019d6:	e8 5b ff ff ff       	call   801936 <fstat>
  8019db:	89 c6                	mov    %eax,%esi
	close(fd);
  8019dd:	89 1c 24             	mov    %ebx,(%esp)
  8019e0:	e8 fd fb ff ff       	call   8015e2 <close>
	return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	89 f0                	mov    %esi,%eax
}
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	89 c6                	mov    %eax,%esi
  8019f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a01:	75 12                	jne    801a15 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	6a 01                	push   $0x1
  801a08:	e8 1e 0d 00 00       	call   80272b <ipc_find_env>
  801a0d:	a3 00 50 80 00       	mov    %eax,0x805000
  801a12:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a15:	6a 07                	push   $0x7
  801a17:	68 00 60 80 00       	push   $0x806000
  801a1c:	56                   	push   %esi
  801a1d:	ff 35 00 50 80 00    	pushl  0x805000
  801a23:	e8 af 0c 00 00       	call   8026d7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a28:	83 c4 0c             	add    $0xc,%esp
  801a2b:	6a 00                	push   $0x0
  801a2d:	53                   	push   %ebx
  801a2e:	6a 00                	push   $0x0
  801a30:	e8 39 0c 00 00       	call   80266e <ipc_recv>
}
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	8b 40 0c             	mov    0xc(%eax),%eax
  801a48:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a50:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5f:	e8 8d ff ff ff       	call   8019f1 <fsipc>
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a72:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a81:	e8 6b ff ff ff       	call   8019f1 <fsipc>
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 04             	sub    $0x4,%esp
  801a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	8b 40 0c             	mov    0xc(%eax),%eax
  801a98:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa7:	e8 45 ff ff ff       	call   8019f1 <fsipc>
  801aac:	89 c2                	mov    %eax,%edx
  801aae:	85 d2                	test   %edx,%edx
  801ab0:	78 2c                	js     801ade <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	68 00 60 80 00       	push   $0x806000
  801aba:	53                   	push   %ebx
  801abb:	e8 84 f0 ff ff       	call   800b44 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ac0:	a1 80 60 80 00       	mov    0x806080,%eax
  801ac5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801acb:	a1 84 60 80 00       	mov    0x806084,%eax
  801ad0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	8b 40 0c             	mov    0xc(%eax),%eax
  801af5:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801afd:	eb 3d                	jmp    801b3c <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801aff:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801b05:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801b0a:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801b0d:	83 ec 04             	sub    $0x4,%esp
  801b10:	57                   	push   %edi
  801b11:	53                   	push   %ebx
  801b12:	68 08 60 80 00       	push   $0x806008
  801b17:	e8 ba f1 ff ff       	call   800cd6 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801b1c:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b22:	ba 00 00 00 00       	mov    $0x0,%edx
  801b27:	b8 04 00 00 00       	mov    $0x4,%eax
  801b2c:	e8 c0 fe ff ff       	call   8019f1 <fsipc>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 0d                	js     801b45 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801b38:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801b3a:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801b3c:	85 f6                	test   %esi,%esi
  801b3e:	75 bf                	jne    801aff <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801b40:	89 d8                	mov    %ebx,%eax
  801b42:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b60:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b70:	e8 7c fe ff ff       	call   8019f1 <fsipc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 4b                	js     801bc6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b7b:	39 c6                	cmp    %eax,%esi
  801b7d:	73 16                	jae    801b95 <devfile_read+0x48>
  801b7f:	68 14 31 80 00       	push   $0x803114
  801b84:	68 1b 31 80 00       	push   $0x80311b
  801b89:	6a 7c                	push   $0x7c
  801b8b:	68 30 31 80 00       	push   $0x803130
  801b90:	e8 4f e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b9a:	7e 16                	jle    801bb2 <devfile_read+0x65>
  801b9c:	68 3b 31 80 00       	push   $0x80313b
  801ba1:	68 1b 31 80 00       	push   $0x80311b
  801ba6:	6a 7d                	push   $0x7d
  801ba8:	68 30 31 80 00       	push   $0x803130
  801bad:	e8 32 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb2:	83 ec 04             	sub    $0x4,%esp
  801bb5:	50                   	push   %eax
  801bb6:	68 00 60 80 00       	push   $0x806000
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	e8 13 f1 ff ff       	call   800cd6 <memmove>
	return r;
  801bc3:	83 c4 10             	add    $0x10,%esp
}
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 20             	sub    $0x20,%esp
  801bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bd9:	53                   	push   %ebx
  801bda:	e8 2c ef ff ff       	call   800b0b <strlen>
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801be7:	7f 67                	jg     801c50 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bef:	50                   	push   %eax
  801bf0:	e8 74 f8 ff ff       	call   801469 <fd_alloc>
  801bf5:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	78 57                	js     801c55 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bfe:	83 ec 08             	sub    $0x8,%esp
  801c01:	53                   	push   %ebx
  801c02:	68 00 60 80 00       	push   $0x806000
  801c07:	e8 38 ef ff ff       	call   800b44 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c17:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1c:	e8 d0 fd ff ff       	call   8019f1 <fsipc>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	79 14                	jns    801c3e <open+0x6f>
		fd_close(fd, 0);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	6a 00                	push   $0x0
  801c2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c32:	e8 2a f9 ff ff       	call   801561 <fd_close>
		return r;
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	89 da                	mov    %ebx,%edx
  801c3c:	eb 17                	jmp    801c55 <open+0x86>
	}

	return fd2num(fd);
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	ff 75 f4             	pushl  -0xc(%ebp)
  801c44:	e8 f9 f7 ff ff       	call   801442 <fd2num>
  801c49:	89 c2                	mov    %eax,%edx
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	eb 05                	jmp    801c55 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c50:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c55:	89 d0                	mov    %edx,%eax
  801c57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c62:	ba 00 00 00 00       	mov    $0x0,%edx
  801c67:	b8 08 00 00 00       	mov    $0x8,%eax
  801c6c:	e8 80 fd ff ff       	call   8019f1 <fsipc>
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c7f:	6a 00                	push   $0x0
  801c81:	ff 75 08             	pushl  0x8(%ebp)
  801c84:	e8 46 ff ff ff       	call   801bcf <open>
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 88 97 04 00 00    	js     802133 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	68 00 02 00 00       	push   $0x200
  801ca4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	57                   	push   %edi
  801cac:	e8 02 fb ff ff       	call   8017b3 <readn>
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cb9:	75 0c                	jne    801cc7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801cbb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cc2:	45 4c 46 
  801cc5:	74 33                	je     801cfa <spawn+0x87>
		close(fd);
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd0:	e8 0d f9 ff ff       	call   8015e2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cd5:	83 c4 0c             	add    $0xc,%esp
  801cd8:	68 7f 45 4c 46       	push   $0x464c457f
  801cdd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ce3:	68 47 31 80 00       	push   $0x803147
  801ce8:	e8 d0 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801cf5:	e9 be 04 00 00       	jmp    8021b8 <spawn+0x545>
  801cfa:	b8 07 00 00 00       	mov    $0x7,%eax
  801cff:	cd 30                	int    $0x30
  801d01:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d07:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 26 04 00 00    	js     80213b <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d15:	89 c6                	mov    %eax,%esi
  801d17:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d1d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d20:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d26:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d2c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d33:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d39:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d44:	be 00 00 00 00       	mov    $0x0,%esi
  801d49:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d4c:	eb 13                	jmp    801d61 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	50                   	push   %eax
  801d52:	e8 b4 ed ff ff       	call   800b0b <strlen>
  801d57:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d5b:	83 c3 01             	add    $0x1,%ebx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d68:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	75 df                	jne    801d4e <spawn+0xdb>
  801d6f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d75:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d7b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d80:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d82:	89 fa                	mov    %edi,%edx
  801d84:	83 e2 fc             	and    $0xfffffffc,%edx
  801d87:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d8e:	29 c2                	sub    %eax,%edx
  801d90:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d96:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d99:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d9e:	0f 86 a7 03 00 00    	jbe    80214b <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	6a 07                	push   $0x7
  801da9:	68 00 00 40 00       	push   $0x400000
  801dae:	6a 00                	push   $0x0
  801db0:	e8 98 f1 ff ff       	call   800f4d <sys_page_alloc>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	0f 88 f8 03 00 00    	js     8021b8 <spawn+0x545>
  801dc0:	be 00 00 00 00       	mov    $0x0,%esi
  801dc5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801dcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dce:	eb 30                	jmp    801e00 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801dd0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dd6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ddc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ddf:	83 ec 08             	sub    $0x8,%esp
  801de2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801de5:	57                   	push   %edi
  801de6:	e8 59 ed ff ff       	call   800b44 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801deb:	83 c4 04             	add    $0x4,%esp
  801dee:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801df1:	e8 15 ed ff ff       	call   800b0b <strlen>
  801df6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dfa:	83 c6 01             	add    $0x1,%esi
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e06:	7f c8                	jg     801dd0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e08:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e0e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e14:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e1b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e21:	74 19                	je     801e3c <spawn+0x1c9>
  801e23:	68 d4 31 80 00       	push   $0x8031d4
  801e28:	68 1b 31 80 00       	push   $0x80311b
  801e2d:	68 f1 00 00 00       	push   $0xf1
  801e32:	68 61 31 80 00       	push   $0x803161
  801e37:	e8 a8 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e3c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e42:	89 f8                	mov    %edi,%eax
  801e44:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e49:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e4c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e52:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e55:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e5b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e61:	83 ec 0c             	sub    $0xc,%esp
  801e64:	6a 07                	push   $0x7
  801e66:	68 00 d0 bf ee       	push   $0xeebfd000
  801e6b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e71:	68 00 00 40 00       	push   $0x400000
  801e76:	6a 00                	push   $0x0
  801e78:	e8 13 f1 ff ff       	call   800f90 <sys_page_map>
  801e7d:	89 c3                	mov    %eax,%ebx
  801e7f:	83 c4 20             	add    $0x20,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	0f 88 1a 03 00 00    	js     8021a4 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	68 00 00 40 00       	push   $0x400000
  801e92:	6a 00                	push   $0x0
  801e94:	e8 39 f1 ff ff       	call   800fd2 <sys_page_unmap>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 88 fe 02 00 00    	js     8021a4 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ea6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801eac:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801eb3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801eb9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ec0:	00 00 00 
  801ec3:	e9 85 01 00 00       	jmp    80204d <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801ec8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ece:	83 38 01             	cmpl   $0x1,(%eax)
  801ed1:	0f 85 68 01 00 00    	jne    80203f <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ed7:	89 c7                	mov    %eax,%edi
  801ed9:	8b 40 18             	mov    0x18(%eax),%eax
  801edc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ee2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ee5:	83 f8 01             	cmp    $0x1,%eax
  801ee8:	19 c0                	sbb    %eax,%eax
  801eea:	83 e0 fe             	and    $0xfffffffe,%eax
  801eed:	83 c0 07             	add    $0x7,%eax
  801ef0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ef6:	89 f8                	mov    %edi,%eax
  801ef8:	8b 7f 04             	mov    0x4(%edi),%edi
  801efb:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f01:	8b 78 10             	mov    0x10(%eax),%edi
  801f04:	8b 48 14             	mov    0x14(%eax),%ecx
  801f07:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801f0d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f10:	89 f0                	mov    %esi,%eax
  801f12:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f17:	74 10                	je     801f29 <spawn+0x2b6>
		va -= i;
  801f19:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f1b:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801f21:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f23:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f29:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f2e:	e9 fa 00 00 00       	jmp    80202d <spawn+0x3ba>
		if (i >= filesz) {
  801f33:	39 fb                	cmp    %edi,%ebx
  801f35:	72 27                	jb     801f5e <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f40:	56                   	push   %esi
  801f41:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f47:	e8 01 f0 ff ff       	call   800f4d <sys_page_alloc>
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	0f 89 ca 00 00 00    	jns    802021 <spawn+0x3ae>
  801f57:	89 c7                	mov    %eax,%edi
  801f59:	e9 fe 01 00 00       	jmp    80215c <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f5e:	83 ec 04             	sub    $0x4,%esp
  801f61:	6a 07                	push   $0x7
  801f63:	68 00 00 40 00       	push   $0x400000
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 de ef ff ff       	call   800f4d <sys_page_alloc>
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 d8 01 00 00    	js     802152 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f7a:	83 ec 08             	sub    $0x8,%esp
  801f7d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f83:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f90:	e8 ef f8 ff ff       	call   801884 <seek>
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	0f 88 b6 01 00 00    	js     802156 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fa0:	83 ec 04             	sub    $0x4,%esp
  801fa3:	89 fa                	mov    %edi,%edx
  801fa5:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801fab:	89 d0                	mov    %edx,%eax
  801fad:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801fb3:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801fb8:	0f 47 c1             	cmova  %ecx,%eax
  801fbb:	50                   	push   %eax
  801fbc:	68 00 00 40 00       	push   $0x400000
  801fc1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc7:	e8 e7 f7 ff ff       	call   8017b3 <readn>
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	0f 88 83 01 00 00    	js     80215a <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fe0:	56                   	push   %esi
  801fe1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fe7:	68 00 00 40 00       	push   $0x400000
  801fec:	6a 00                	push   $0x0
  801fee:	e8 9d ef ff ff       	call   800f90 <sys_page_map>
  801ff3:	83 c4 20             	add    $0x20,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	79 15                	jns    80200f <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801ffa:	50                   	push   %eax
  801ffb:	68 6d 31 80 00       	push   $0x80316d
  802000:	68 24 01 00 00       	push   $0x124
  802005:	68 61 31 80 00       	push   $0x803161
  80200a:	e8 d5 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  80200f:	83 ec 08             	sub    $0x8,%esp
  802012:	68 00 00 40 00       	push   $0x400000
  802017:	6a 00                	push   $0x0
  802019:	e8 b4 ef ff ff       	call   800fd2 <sys_page_unmap>
  80201e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802021:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802027:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80202d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802033:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802039:	0f 82 f4 fe ff ff    	jb     801f33 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80203f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802046:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80204d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802054:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80205a:	0f 8c 68 fe ff ff    	jl     801ec8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802069:	e8 74 f5 ff ff       	call   8015e2 <close>
  80206e:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  802071:	bb 00 00 00 00       	mov    $0x0,%ebx
  802076:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	c1 e8 16             	shr    $0x16,%eax
  802081:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802088:	a8 01                	test   $0x1,%al
  80208a:	74 53                	je     8020df <spawn+0x46c>
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	c1 e8 0c             	shr    $0xc,%eax
  802091:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802098:	f6 c2 01             	test   $0x1,%dl
  80209b:	74 42                	je     8020df <spawn+0x46c>
  80209d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020a4:	f6 c6 04             	test   $0x4,%dh
  8020a7:	74 36                	je     8020df <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  8020a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8020b8:	50                   	push   %eax
  8020b9:	53                   	push   %ebx
  8020ba:	56                   	push   %esi
  8020bb:	53                   	push   %ebx
  8020bc:	6a 00                	push   $0x0
  8020be:	e8 cd ee ff ff       	call   800f90 <sys_page_map>
                        if (r < 0) return r;
  8020c3:	83 c4 20             	add    $0x20,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	79 15                	jns    8020df <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020ca:	50                   	push   %eax
  8020cb:	68 8a 31 80 00       	push   $0x80318a
  8020d0:	68 82 00 00 00       	push   $0x82
  8020d5:	68 61 31 80 00       	push   $0x803161
  8020da:	e8 05 e4 ff ff       	call   8004e4 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  8020df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020eb:	75 8f                	jne    80207c <spawn+0x409>
  8020ed:	e9 8d 00 00 00       	jmp    80217f <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  8020f2:	50                   	push   %eax
  8020f3:	68 a0 31 80 00       	push   $0x8031a0
  8020f8:	68 85 00 00 00       	push   $0x85
  8020fd:	68 61 31 80 00       	push   $0x803161
  802102:	e8 dd e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	6a 02                	push   $0x2
  80210c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802112:	e8 fd ee ff ff       	call   801014 <sys_env_set_status>
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	85 c0                	test   %eax,%eax
  80211c:	79 25                	jns    802143 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  80211e:	50                   	push   %eax
  80211f:	68 ba 31 80 00       	push   $0x8031ba
  802124:	68 88 00 00 00       	push   $0x88
  802129:	68 61 31 80 00       	push   $0x803161
  80212e:	e8 b1 e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802133:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802139:	eb 7d                	jmp    8021b8 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80213b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802141:	eb 75                	jmp    8021b8 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802143:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802149:	eb 6d                	jmp    8021b8 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80214b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802150:	eb 66                	jmp    8021b8 <spawn+0x545>
  802152:	89 c7                	mov    %eax,%edi
  802154:	eb 06                	jmp    80215c <spawn+0x4e9>
  802156:	89 c7                	mov    %eax,%edi
  802158:	eb 02                	jmp    80215c <spawn+0x4e9>
  80215a:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80215c:	83 ec 0c             	sub    $0xc,%esp
  80215f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802165:	e8 64 ed ff ff       	call   800ece <sys_env_destroy>
	close(fd);
  80216a:	83 c4 04             	add    $0x4,%esp
  80216d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802173:	e8 6a f4 ff ff       	call   8015e2 <close>
	return r;
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	89 f8                	mov    %edi,%eax
  80217d:	eb 39                	jmp    8021b8 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  80217f:	83 ec 08             	sub    $0x8,%esp
  802182:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802188:	50                   	push   %eax
  802189:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80218f:	e8 c2 ee ff ff       	call   801056 <sys_env_set_trapframe>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	0f 89 68 ff ff ff    	jns    802107 <spawn+0x494>
  80219f:	e9 4e ff ff ff       	jmp    8020f2 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021a4:	83 ec 08             	sub    $0x8,%esp
  8021a7:	68 00 00 40 00       	push   $0x400000
  8021ac:	6a 00                	push   $0x0
  8021ae:	e8 1f ee ff ff       	call   800fd2 <sys_page_unmap>
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bb:	5b                   	pop    %ebx
  8021bc:	5e                   	pop    %esi
  8021bd:	5f                   	pop    %edi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	56                   	push   %esi
  8021c4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021c8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021cd:	eb 03                	jmp    8021d2 <spawnl+0x12>
		argc++;
  8021cf:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021d2:	83 c2 04             	add    $0x4,%edx
  8021d5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021d9:	75 f4                	jne    8021cf <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021db:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021e2:	83 e2 f0             	and    $0xfffffff0,%edx
  8021e5:	29 d4                	sub    %edx,%esp
  8021e7:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021eb:	c1 ea 02             	shr    $0x2,%edx
  8021ee:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021f5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021fa:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802201:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802208:	00 
  802209:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80220b:	b8 00 00 00 00       	mov    $0x0,%eax
  802210:	eb 0a                	jmp    80221c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802212:	83 c0 01             	add    $0x1,%eax
  802215:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802219:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80221c:	39 d0                	cmp    %edx,%eax
  80221e:	75 f2                	jne    802212 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802220:	83 ec 08             	sub    $0x8,%esp
  802223:	56                   	push   %esi
  802224:	ff 75 08             	pushl  0x8(%ebp)
  802227:	e8 47 fa ff ff       	call   801c73 <spawn>
}
  80222c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	ff 75 08             	pushl  0x8(%ebp)
  802241:	e8 0c f2 ff ff       	call   801452 <fd2data>
  802246:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802248:	83 c4 08             	add    $0x8,%esp
  80224b:	68 fa 31 80 00       	push   $0x8031fa
  802250:	53                   	push   %ebx
  802251:	e8 ee e8 ff ff       	call   800b44 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802256:	8b 56 04             	mov    0x4(%esi),%edx
  802259:	89 d0                	mov    %edx,%eax
  80225b:	2b 06                	sub    (%esi),%eax
  80225d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802263:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80226a:	00 00 00 
	stat->st_dev = &devpipe;
  80226d:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802274:	40 80 00 
	return 0;
}
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
  80227c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	53                   	push   %ebx
  802287:	83 ec 0c             	sub    $0xc,%esp
  80228a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80228d:	53                   	push   %ebx
  80228e:	6a 00                	push   $0x0
  802290:	e8 3d ed ff ff       	call   800fd2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802295:	89 1c 24             	mov    %ebx,(%esp)
  802298:	e8 b5 f1 ff ff       	call   801452 <fd2data>
  80229d:	83 c4 08             	add    $0x8,%esp
  8022a0:	50                   	push   %eax
  8022a1:	6a 00                	push   $0x0
  8022a3:	e8 2a ed ff ff       	call   800fd2 <sys_page_unmap>
}
  8022a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ab:	c9                   	leave  
  8022ac:	c3                   	ret    

008022ad <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022ad:	55                   	push   %ebp
  8022ae:	89 e5                	mov    %esp,%ebp
  8022b0:	57                   	push   %edi
  8022b1:	56                   	push   %esi
  8022b2:	53                   	push   %ebx
  8022b3:	83 ec 1c             	sub    $0x1c,%esp
  8022b6:	89 c6                	mov    %eax,%esi
  8022b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022bb:	a1 04 50 80 00       	mov    0x805004,%eax
  8022c0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022c3:	83 ec 0c             	sub    $0xc,%esp
  8022c6:	56                   	push   %esi
  8022c7:	e8 97 04 00 00       	call   802763 <pageref>
  8022cc:	89 c7                	mov    %eax,%edi
  8022ce:	83 c4 04             	add    $0x4,%esp
  8022d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022d4:	e8 8a 04 00 00       	call   802763 <pageref>
  8022d9:	83 c4 10             	add    $0x10,%esp
  8022dc:	39 c7                	cmp    %eax,%edi
  8022de:	0f 94 c2             	sete   %dl
  8022e1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8022e4:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  8022ea:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8022ed:	39 fb                	cmp    %edi,%ebx
  8022ef:	74 19                	je     80230a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8022f1:	84 d2                	test   %dl,%dl
  8022f3:	74 c6                	je     8022bb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022f5:	8b 51 58             	mov    0x58(%ecx),%edx
  8022f8:	50                   	push   %eax
  8022f9:	52                   	push   %edx
  8022fa:	53                   	push   %ebx
  8022fb:	68 01 32 80 00       	push   $0x803201
  802300:	e8 b8 e2 ff ff       	call   8005bd <cprintf>
  802305:	83 c4 10             	add    $0x10,%esp
  802308:	eb b1                	jmp    8022bb <_pipeisclosed+0xe>
	}
}
  80230a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    

00802312 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	83 ec 28             	sub    $0x28,%esp
  80231b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80231e:	56                   	push   %esi
  80231f:	e8 2e f1 ff ff       	call   801452 <fd2data>
  802324:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802326:	83 c4 10             	add    $0x10,%esp
  802329:	bf 00 00 00 00       	mov    $0x0,%edi
  80232e:	eb 4b                	jmp    80237b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802330:	89 da                	mov    %ebx,%edx
  802332:	89 f0                	mov    %esi,%eax
  802334:	e8 74 ff ff ff       	call   8022ad <_pipeisclosed>
  802339:	85 c0                	test   %eax,%eax
  80233b:	75 48                	jne    802385 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80233d:	e8 ec eb ff ff       	call   800f2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802342:	8b 43 04             	mov    0x4(%ebx),%eax
  802345:	8b 0b                	mov    (%ebx),%ecx
  802347:	8d 51 20             	lea    0x20(%ecx),%edx
  80234a:	39 d0                	cmp    %edx,%eax
  80234c:	73 e2                	jae    802330 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80234e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802351:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802355:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802358:	89 c2                	mov    %eax,%edx
  80235a:	c1 fa 1f             	sar    $0x1f,%edx
  80235d:	89 d1                	mov    %edx,%ecx
  80235f:	c1 e9 1b             	shr    $0x1b,%ecx
  802362:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802365:	83 e2 1f             	and    $0x1f,%edx
  802368:	29 ca                	sub    %ecx,%edx
  80236a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80236e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802372:	83 c0 01             	add    $0x1,%eax
  802375:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802378:	83 c7 01             	add    $0x1,%edi
  80237b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80237e:	75 c2                	jne    802342 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802380:	8b 45 10             	mov    0x10(%ebp),%eax
  802383:	eb 05                	jmp    80238a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802385:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80238a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 18             	sub    $0x18,%esp
  80239b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80239e:	57                   	push   %edi
  80239f:	e8 ae f0 ff ff       	call   801452 <fd2data>
  8023a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023ae:	eb 3d                	jmp    8023ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023b0:	85 db                	test   %ebx,%ebx
  8023b2:	74 04                	je     8023b8 <devpipe_read+0x26>
				return i;
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	eb 44                	jmp    8023fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	89 f8                	mov    %edi,%eax
  8023bc:	e8 ec fe ff ff       	call   8022ad <_pipeisclosed>
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	75 32                	jne    8023f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c5:	e8 64 eb ff ff       	call   800f2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023ca:	8b 06                	mov    (%esi),%eax
  8023cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8023cf:	74 df                	je     8023b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d1:	99                   	cltd   
  8023d2:	c1 ea 1b             	shr    $0x1b,%edx
  8023d5:	01 d0                	add    %edx,%eax
  8023d7:	83 e0 1f             	and    $0x1f,%eax
  8023da:	29 d0                	sub    %edx,%eax
  8023dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ea:	83 c3 01             	add    $0x1,%ebx
  8023ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023f0:	75 d8                	jne    8023ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f5:	eb 05                	jmp    8023fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    

00802404 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80240c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240f:	50                   	push   %eax
  802410:	e8 54 f0 ff ff       	call   801469 <fd_alloc>
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	89 c2                	mov    %eax,%edx
  80241a:	85 c0                	test   %eax,%eax
  80241c:	0f 88 2c 01 00 00    	js     80254e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802422:	83 ec 04             	sub    $0x4,%esp
  802425:	68 07 04 00 00       	push   $0x407
  80242a:	ff 75 f4             	pushl  -0xc(%ebp)
  80242d:	6a 00                	push   $0x0
  80242f:	e8 19 eb ff ff       	call   800f4d <sys_page_alloc>
  802434:	83 c4 10             	add    $0x10,%esp
  802437:	89 c2                	mov    %eax,%edx
  802439:	85 c0                	test   %eax,%eax
  80243b:	0f 88 0d 01 00 00    	js     80254e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802441:	83 ec 0c             	sub    $0xc,%esp
  802444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802447:	50                   	push   %eax
  802448:	e8 1c f0 ff ff       	call   801469 <fd_alloc>
  80244d:	89 c3                	mov    %eax,%ebx
  80244f:	83 c4 10             	add    $0x10,%esp
  802452:	85 c0                	test   %eax,%eax
  802454:	0f 88 e2 00 00 00    	js     80253c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245a:	83 ec 04             	sub    $0x4,%esp
  80245d:	68 07 04 00 00       	push   $0x407
  802462:	ff 75 f0             	pushl  -0x10(%ebp)
  802465:	6a 00                	push   $0x0
  802467:	e8 e1 ea ff ff       	call   800f4d <sys_page_alloc>
  80246c:	89 c3                	mov    %eax,%ebx
  80246e:	83 c4 10             	add    $0x10,%esp
  802471:	85 c0                	test   %eax,%eax
  802473:	0f 88 c3 00 00 00    	js     80253c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802479:	83 ec 0c             	sub    $0xc,%esp
  80247c:	ff 75 f4             	pushl  -0xc(%ebp)
  80247f:	e8 ce ef ff ff       	call   801452 <fd2data>
  802484:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802486:	83 c4 0c             	add    $0xc,%esp
  802489:	68 07 04 00 00       	push   $0x407
  80248e:	50                   	push   %eax
  80248f:	6a 00                	push   $0x0
  802491:	e8 b7 ea ff ff       	call   800f4d <sys_page_alloc>
  802496:	89 c3                	mov    %eax,%ebx
  802498:	83 c4 10             	add    $0x10,%esp
  80249b:	85 c0                	test   %eax,%eax
  80249d:	0f 88 89 00 00 00    	js     80252c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024a3:	83 ec 0c             	sub    $0xc,%esp
  8024a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a9:	e8 a4 ef ff ff       	call   801452 <fd2data>
  8024ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024b5:	50                   	push   %eax
  8024b6:	6a 00                	push   $0x0
  8024b8:	56                   	push   %esi
  8024b9:	6a 00                	push   $0x0
  8024bb:	e8 d0 ea ff ff       	call   800f90 <sys_page_map>
  8024c0:	89 c3                	mov    %eax,%ebx
  8024c2:	83 c4 20             	add    $0x20,%esp
  8024c5:	85 c0                	test   %eax,%eax
  8024c7:	78 55                	js     80251e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024c9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024de:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024f3:	83 ec 0c             	sub    $0xc,%esp
  8024f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f9:	e8 44 ef ff ff       	call   801442 <fd2num>
  8024fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802501:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802503:	83 c4 04             	add    $0x4,%esp
  802506:	ff 75 f0             	pushl  -0x10(%ebp)
  802509:	e8 34 ef ff ff       	call   801442 <fd2num>
  80250e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802511:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802514:	83 c4 10             	add    $0x10,%esp
  802517:	ba 00 00 00 00       	mov    $0x0,%edx
  80251c:	eb 30                	jmp    80254e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80251e:	83 ec 08             	sub    $0x8,%esp
  802521:	56                   	push   %esi
  802522:	6a 00                	push   $0x0
  802524:	e8 a9 ea ff ff       	call   800fd2 <sys_page_unmap>
  802529:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80252c:	83 ec 08             	sub    $0x8,%esp
  80252f:	ff 75 f0             	pushl  -0x10(%ebp)
  802532:	6a 00                	push   $0x0
  802534:	e8 99 ea ff ff       	call   800fd2 <sys_page_unmap>
  802539:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80253c:	83 ec 08             	sub    $0x8,%esp
  80253f:	ff 75 f4             	pushl  -0xc(%ebp)
  802542:	6a 00                	push   $0x0
  802544:	e8 89 ea ff ff       	call   800fd2 <sys_page_unmap>
  802549:	83 c4 10             	add    $0x10,%esp
  80254c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80254e:	89 d0                	mov    %edx,%eax
  802550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80255d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802560:	50                   	push   %eax
  802561:	ff 75 08             	pushl  0x8(%ebp)
  802564:	e8 4f ef ff ff       	call   8014b8 <fd_lookup>
  802569:	89 c2                	mov    %eax,%edx
  80256b:	83 c4 10             	add    $0x10,%esp
  80256e:	85 d2                	test   %edx,%edx
  802570:	78 18                	js     80258a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802572:	83 ec 0c             	sub    $0xc,%esp
  802575:	ff 75 f4             	pushl  -0xc(%ebp)
  802578:	e8 d5 ee ff ff       	call   801452 <fd2data>
	return _pipeisclosed(fd, p);
  80257d:	89 c2                	mov    %eax,%edx
  80257f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802582:	e8 26 fd ff ff       	call   8022ad <_pipeisclosed>
  802587:	83 c4 10             	add    $0x10,%esp
}
  80258a:	c9                   	leave  
  80258b:	c3                   	ret    

0080258c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80258c:	55                   	push   %ebp
  80258d:	89 e5                	mov    %esp,%ebp
  80258f:	56                   	push   %esi
  802590:	53                   	push   %ebx
  802591:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802594:	85 f6                	test   %esi,%esi
  802596:	75 16                	jne    8025ae <wait+0x22>
  802598:	68 19 32 80 00       	push   $0x803219
  80259d:	68 1b 31 80 00       	push   $0x80311b
  8025a2:	6a 09                	push   $0x9
  8025a4:	68 24 32 80 00       	push   $0x803224
  8025a9:	e8 36 df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8025ae:	89 f3                	mov    %esi,%ebx
  8025b0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025b6:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025b9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025bf:	eb 05                	jmp    8025c6 <wait+0x3a>
		sys_yield();
  8025c1:	e8 68 e9 ff ff       	call   800f2e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025c6:	8b 43 48             	mov    0x48(%ebx),%eax
  8025c9:	39 f0                	cmp    %esi,%eax
  8025cb:	75 07                	jne    8025d4 <wait+0x48>
  8025cd:	8b 43 54             	mov    0x54(%ebx),%eax
  8025d0:	85 c0                	test   %eax,%eax
  8025d2:	75 ed                	jne    8025c1 <wait+0x35>
		sys_yield();
}
  8025d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5d                   	pop    %ebp
  8025da:	c3                   	ret    

008025db <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025db:	55                   	push   %ebp
  8025dc:	89 e5                	mov    %esp,%ebp
  8025de:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025e1:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025e8:	75 2c                	jne    802616 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8025ea:	83 ec 04             	sub    $0x4,%esp
  8025ed:	6a 07                	push   $0x7
  8025ef:	68 00 f0 bf ee       	push   $0xeebff000
  8025f4:	6a 00                	push   $0x0
  8025f6:	e8 52 e9 ff ff       	call   800f4d <sys_page_alloc>
  8025fb:	83 c4 10             	add    $0x10,%esp
  8025fe:	85 c0                	test   %eax,%eax
  802600:	74 14                	je     802616 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802602:	83 ec 04             	sub    $0x4,%esp
  802605:	68 30 32 80 00       	push   $0x803230
  80260a:	6a 21                	push   $0x21
  80260c:	68 94 32 80 00       	push   $0x803294
  802611:	e8 ce de ff ff       	call   8004e4 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802616:	8b 45 08             	mov    0x8(%ebp),%eax
  802619:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80261e:	83 ec 08             	sub    $0x8,%esp
  802621:	68 4a 26 80 00       	push   $0x80264a
  802626:	6a 00                	push   $0x0
  802628:	e8 6b ea ff ff       	call   801098 <sys_env_set_pgfault_upcall>
  80262d:	83 c4 10             	add    $0x10,%esp
  802630:	85 c0                	test   %eax,%eax
  802632:	79 14                	jns    802648 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802634:	83 ec 04             	sub    $0x4,%esp
  802637:	68 5c 32 80 00       	push   $0x80325c
  80263c:	6a 29                	push   $0x29
  80263e:	68 94 32 80 00       	push   $0x803294
  802643:	e8 9c de ff ff       	call   8004e4 <_panic>
}
  802648:	c9                   	leave  
  802649:	c3                   	ret    

0080264a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80264a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80264b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802650:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802652:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802655:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  80265a:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80265e:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802662:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802664:	83 c4 08             	add    $0x8,%esp
        popal
  802667:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802668:	83 c4 04             	add    $0x4,%esp
        popfl
  80266b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  80266c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80266d:	c3                   	ret    

0080266e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266e:	55                   	push   %ebp
  80266f:	89 e5                	mov    %esp,%ebp
  802671:	56                   	push   %esi
  802672:	53                   	push   %ebx
  802673:	8b 75 08             	mov    0x8(%ebp),%esi
  802676:	8b 45 0c             	mov    0xc(%ebp),%eax
  802679:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80267c:	85 c0                	test   %eax,%eax
  80267e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802683:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802686:	83 ec 0c             	sub    $0xc,%esp
  802689:	50                   	push   %eax
  80268a:	e8 6e ea ff ff       	call   8010fd <sys_ipc_recv>
  80268f:	83 c4 10             	add    $0x10,%esp
  802692:	85 c0                	test   %eax,%eax
  802694:	79 16                	jns    8026ac <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802696:	85 f6                	test   %esi,%esi
  802698:	74 06                	je     8026a0 <ipc_recv+0x32>
  80269a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8026a0:	85 db                	test   %ebx,%ebx
  8026a2:	74 2c                	je     8026d0 <ipc_recv+0x62>
  8026a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026aa:	eb 24                	jmp    8026d0 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8026ac:	85 f6                	test   %esi,%esi
  8026ae:	74 0a                	je     8026ba <ipc_recv+0x4c>
  8026b0:	a1 04 50 80 00       	mov    0x805004,%eax
  8026b5:	8b 40 74             	mov    0x74(%eax),%eax
  8026b8:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8026ba:	85 db                	test   %ebx,%ebx
  8026bc:	74 0a                	je     8026c8 <ipc_recv+0x5a>
  8026be:	a1 04 50 80 00       	mov    0x805004,%eax
  8026c3:	8b 40 78             	mov    0x78(%eax),%eax
  8026c6:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8026c8:	a1 04 50 80 00       	mov    0x805004,%eax
  8026cd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5d                   	pop    %ebp
  8026d6:	c3                   	ret    

008026d7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d7:	55                   	push   %ebp
  8026d8:	89 e5                	mov    %esp,%ebp
  8026da:	57                   	push   %edi
  8026db:	56                   	push   %esi
  8026dc:	53                   	push   %ebx
  8026dd:	83 ec 0c             	sub    $0xc,%esp
  8026e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8026e9:	85 db                	test   %ebx,%ebx
  8026eb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026f0:	0f 44 d8             	cmove  %eax,%ebx
  8026f3:	eb 1c                	jmp    802711 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8026f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026f8:	74 12                	je     80270c <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8026fa:	50                   	push   %eax
  8026fb:	68 a2 32 80 00       	push   $0x8032a2
  802700:	6a 39                	push   $0x39
  802702:	68 bd 32 80 00       	push   $0x8032bd
  802707:	e8 d8 dd ff ff       	call   8004e4 <_panic>
                 sys_yield();
  80270c:	e8 1d e8 ff ff       	call   800f2e <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802711:	ff 75 14             	pushl  0x14(%ebp)
  802714:	53                   	push   %ebx
  802715:	56                   	push   %esi
  802716:	57                   	push   %edi
  802717:	e8 be e9 ff ff       	call   8010da <sys_ipc_try_send>
  80271c:	83 c4 10             	add    $0x10,%esp
  80271f:	85 c0                	test   %eax,%eax
  802721:	78 d2                	js     8026f5 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802726:	5b                   	pop    %ebx
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    

0080272b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80272b:	55                   	push   %ebp
  80272c:	89 e5                	mov    %esp,%ebp
  80272e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802731:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802736:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802739:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273f:	8b 52 50             	mov    0x50(%edx),%edx
  802742:	39 ca                	cmp    %ecx,%edx
  802744:	75 0d                	jne    802753 <ipc_find_env+0x28>
			return envs[i].env_id;
  802746:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802749:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80274e:	8b 40 08             	mov    0x8(%eax),%eax
  802751:	eb 0e                	jmp    802761 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802753:	83 c0 01             	add    $0x1,%eax
  802756:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275b:	75 d9                	jne    802736 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275d:	66 b8 00 00          	mov    $0x0,%ax
}
  802761:	5d                   	pop    %ebp
  802762:	c3                   	ret    

00802763 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802763:	55                   	push   %ebp
  802764:	89 e5                	mov    %esp,%ebp
  802766:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802769:	89 d0                	mov    %edx,%eax
  80276b:	c1 e8 16             	shr    $0x16,%eax
  80276e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802775:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277a:	f6 c1 01             	test   $0x1,%cl
  80277d:	74 1d                	je     80279c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80277f:	c1 ea 0c             	shr    $0xc,%edx
  802782:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802789:	f6 c2 01             	test   $0x1,%dl
  80278c:	74 0e                	je     80279c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80278e:	c1 ea 0c             	shr    $0xc,%edx
  802791:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802798:	ef 
  802799:	0f b7 c0             	movzwl %ax,%eax
}
  80279c:	5d                   	pop    %ebp
  80279d:	c3                   	ret    
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	83 ec 10             	sub    $0x10,%esp
  8027a6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8027aa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8027ae:	8b 74 24 24          	mov    0x24(%esp),%esi
  8027b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8027b6:	85 d2                	test   %edx,%edx
  8027b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027bc:	89 34 24             	mov    %esi,(%esp)
  8027bf:	89 c8                	mov    %ecx,%eax
  8027c1:	75 35                	jne    8027f8 <__udivdi3+0x58>
  8027c3:	39 f1                	cmp    %esi,%ecx
  8027c5:	0f 87 bd 00 00 00    	ja     802888 <__udivdi3+0xe8>
  8027cb:	85 c9                	test   %ecx,%ecx
  8027cd:	89 cd                	mov    %ecx,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f1                	div    %ecx
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 f0                	mov    %esi,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c6                	mov    %eax,%esi
  8027e4:	89 f8                	mov    %edi,%eax
  8027e6:	f7 f5                	div    %ebp
  8027e8:	89 f2                	mov    %esi,%edx
  8027ea:	83 c4 10             	add    $0x10,%esp
  8027ed:	5e                   	pop    %esi
  8027ee:	5f                   	pop    %edi
  8027ef:	5d                   	pop    %ebp
  8027f0:	c3                   	ret    
  8027f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	3b 14 24             	cmp    (%esp),%edx
  8027fb:	77 7b                	ja     802878 <__udivdi3+0xd8>
  8027fd:	0f bd f2             	bsr    %edx,%esi
  802800:	83 f6 1f             	xor    $0x1f,%esi
  802803:	0f 84 97 00 00 00    	je     8028a0 <__udivdi3+0x100>
  802809:	bd 20 00 00 00       	mov    $0x20,%ebp
  80280e:	89 d7                	mov    %edx,%edi
  802810:	89 f1                	mov    %esi,%ecx
  802812:	29 f5                	sub    %esi,%ebp
  802814:	d3 e7                	shl    %cl,%edi
  802816:	89 c2                	mov    %eax,%edx
  802818:	89 e9                	mov    %ebp,%ecx
  80281a:	d3 ea                	shr    %cl,%edx
  80281c:	89 f1                	mov    %esi,%ecx
  80281e:	09 fa                	or     %edi,%edx
  802820:	8b 3c 24             	mov    (%esp),%edi
  802823:	d3 e0                	shl    %cl,%eax
  802825:	89 54 24 08          	mov    %edx,0x8(%esp)
  802829:	89 e9                	mov    %ebp,%ecx
  80282b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802833:	89 fa                	mov    %edi,%edx
  802835:	d3 ea                	shr    %cl,%edx
  802837:	89 f1                	mov    %esi,%ecx
  802839:	d3 e7                	shl    %cl,%edi
  80283b:	89 e9                	mov    %ebp,%ecx
  80283d:	d3 e8                	shr    %cl,%eax
  80283f:	09 c7                	or     %eax,%edi
  802841:	89 f8                	mov    %edi,%eax
  802843:	f7 74 24 08          	divl   0x8(%esp)
  802847:	89 d5                	mov    %edx,%ebp
  802849:	89 c7                	mov    %eax,%edi
  80284b:	f7 64 24 0c          	mull   0xc(%esp)
  80284f:	39 d5                	cmp    %edx,%ebp
  802851:	89 14 24             	mov    %edx,(%esp)
  802854:	72 11                	jb     802867 <__udivdi3+0xc7>
  802856:	8b 54 24 04          	mov    0x4(%esp),%edx
  80285a:	89 f1                	mov    %esi,%ecx
  80285c:	d3 e2                	shl    %cl,%edx
  80285e:	39 c2                	cmp    %eax,%edx
  802860:	73 5e                	jae    8028c0 <__udivdi3+0x120>
  802862:	3b 2c 24             	cmp    (%esp),%ebp
  802865:	75 59                	jne    8028c0 <__udivdi3+0x120>
  802867:	8d 47 ff             	lea    -0x1(%edi),%eax
  80286a:	31 f6                	xor    %esi,%esi
  80286c:	89 f2                	mov    %esi,%edx
  80286e:	83 c4 10             	add    $0x10,%esp
  802871:	5e                   	pop    %esi
  802872:	5f                   	pop    %edi
  802873:	5d                   	pop    %ebp
  802874:	c3                   	ret    
  802875:	8d 76 00             	lea    0x0(%esi),%esi
  802878:	31 f6                	xor    %esi,%esi
  80287a:	31 c0                	xor    %eax,%eax
  80287c:	89 f2                	mov    %esi,%edx
  80287e:	83 c4 10             	add    $0x10,%esp
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    
  802885:	8d 76 00             	lea    0x0(%esi),%esi
  802888:	89 f2                	mov    %esi,%edx
  80288a:	31 f6                	xor    %esi,%esi
  80288c:	89 f8                	mov    %edi,%eax
  80288e:	f7 f1                	div    %ecx
  802890:	89 f2                	mov    %esi,%edx
  802892:	83 c4 10             	add    $0x10,%esp
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8028a4:	76 0b                	jbe    8028b1 <__udivdi3+0x111>
  8028a6:	31 c0                	xor    %eax,%eax
  8028a8:	3b 14 24             	cmp    (%esp),%edx
  8028ab:	0f 83 37 ff ff ff    	jae    8027e8 <__udivdi3+0x48>
  8028b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b6:	e9 2d ff ff ff       	jmp    8027e8 <__udivdi3+0x48>
  8028bb:	90                   	nop
  8028bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028c0:	89 f8                	mov    %edi,%eax
  8028c2:	31 f6                	xor    %esi,%esi
  8028c4:	e9 1f ff ff ff       	jmp    8027e8 <__udivdi3+0x48>
  8028c9:	66 90                	xchg   %ax,%ax
  8028cb:	66 90                	xchg   %ax,%ax
  8028cd:	66 90                	xchg   %ax,%ax
  8028cf:	90                   	nop

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	83 ec 20             	sub    $0x20,%esp
  8028d6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8028da:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028de:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e2:	89 c6                	mov    %eax,%esi
  8028e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028e8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8028ec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8028f0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028f4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028f8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028fc:	85 c0                	test   %eax,%eax
  8028fe:	89 c2                	mov    %eax,%edx
  802900:	75 1e                	jne    802920 <__umoddi3+0x50>
  802902:	39 f7                	cmp    %esi,%edi
  802904:	76 52                	jbe    802958 <__umoddi3+0x88>
  802906:	89 c8                	mov    %ecx,%eax
  802908:	89 f2                	mov    %esi,%edx
  80290a:	f7 f7                	div    %edi
  80290c:	89 d0                	mov    %edx,%eax
  80290e:	31 d2                	xor    %edx,%edx
  802910:	83 c4 20             	add    $0x20,%esp
  802913:	5e                   	pop    %esi
  802914:	5f                   	pop    %edi
  802915:	5d                   	pop    %ebp
  802916:	c3                   	ret    
  802917:	89 f6                	mov    %esi,%esi
  802919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802920:	39 f0                	cmp    %esi,%eax
  802922:	77 5c                	ja     802980 <__umoddi3+0xb0>
  802924:	0f bd e8             	bsr    %eax,%ebp
  802927:	83 f5 1f             	xor    $0x1f,%ebp
  80292a:	75 64                	jne    802990 <__umoddi3+0xc0>
  80292c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802930:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802934:	0f 86 f6 00 00 00    	jbe    802a30 <__umoddi3+0x160>
  80293a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80293e:	0f 82 ec 00 00 00    	jb     802a30 <__umoddi3+0x160>
  802944:	8b 44 24 14          	mov    0x14(%esp),%eax
  802948:	8b 54 24 18          	mov    0x18(%esp),%edx
  80294c:	83 c4 20             	add    $0x20,%esp
  80294f:	5e                   	pop    %esi
  802950:	5f                   	pop    %edi
  802951:	5d                   	pop    %ebp
  802952:	c3                   	ret    
  802953:	90                   	nop
  802954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802958:	85 ff                	test   %edi,%edi
  80295a:	89 fd                	mov    %edi,%ebp
  80295c:	75 0b                	jne    802969 <__umoddi3+0x99>
  80295e:	b8 01 00 00 00       	mov    $0x1,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f7                	div    %edi
  802967:	89 c5                	mov    %eax,%ebp
  802969:	8b 44 24 10          	mov    0x10(%esp),%eax
  80296d:	31 d2                	xor    %edx,%edx
  80296f:	f7 f5                	div    %ebp
  802971:	89 c8                	mov    %ecx,%eax
  802973:	f7 f5                	div    %ebp
  802975:	eb 95                	jmp    80290c <__umoddi3+0x3c>
  802977:	89 f6                	mov    %esi,%esi
  802979:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802980:	89 c8                	mov    %ecx,%eax
  802982:	89 f2                	mov    %esi,%edx
  802984:	83 c4 20             	add    $0x20,%esp
  802987:	5e                   	pop    %esi
  802988:	5f                   	pop    %edi
  802989:	5d                   	pop    %ebp
  80298a:	c3                   	ret    
  80298b:	90                   	nop
  80298c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802990:	b8 20 00 00 00       	mov    $0x20,%eax
  802995:	89 e9                	mov    %ebp,%ecx
  802997:	29 e8                	sub    %ebp,%eax
  802999:	d3 e2                	shl    %cl,%edx
  80299b:	89 c7                	mov    %eax,%edi
  80299d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8029a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029a5:	89 f9                	mov    %edi,%ecx
  8029a7:	d3 e8                	shr    %cl,%eax
  8029a9:	89 c1                	mov    %eax,%ecx
  8029ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029af:	09 d1                	or     %edx,%ecx
  8029b1:	89 fa                	mov    %edi,%edx
  8029b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8029b7:	89 e9                	mov    %ebp,%ecx
  8029b9:	d3 e0                	shl    %cl,%eax
  8029bb:	89 f9                	mov    %edi,%ecx
  8029bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029c1:	89 f0                	mov    %esi,%eax
  8029c3:	d3 e8                	shr    %cl,%eax
  8029c5:	89 e9                	mov    %ebp,%ecx
  8029c7:	89 c7                	mov    %eax,%edi
  8029c9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8029cd:	d3 e6                	shl    %cl,%esi
  8029cf:	89 d1                	mov    %edx,%ecx
  8029d1:	89 fa                	mov    %edi,%edx
  8029d3:	d3 e8                	shr    %cl,%eax
  8029d5:	89 e9                	mov    %ebp,%ecx
  8029d7:	09 f0                	or     %esi,%eax
  8029d9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8029dd:	f7 74 24 10          	divl   0x10(%esp)
  8029e1:	d3 e6                	shl    %cl,%esi
  8029e3:	89 d1                	mov    %edx,%ecx
  8029e5:	f7 64 24 0c          	mull   0xc(%esp)
  8029e9:	39 d1                	cmp    %edx,%ecx
  8029eb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8029ef:	89 d7                	mov    %edx,%edi
  8029f1:	89 c6                	mov    %eax,%esi
  8029f3:	72 0a                	jb     8029ff <__umoddi3+0x12f>
  8029f5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8029f9:	73 10                	jae    802a0b <__umoddi3+0x13b>
  8029fb:	39 d1                	cmp    %edx,%ecx
  8029fd:	75 0c                	jne    802a0b <__umoddi3+0x13b>
  8029ff:	89 d7                	mov    %edx,%edi
  802a01:	89 c6                	mov    %eax,%esi
  802a03:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802a07:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802a0b:	89 ca                	mov    %ecx,%edx
  802a0d:	89 e9                	mov    %ebp,%ecx
  802a0f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a13:	29 f0                	sub    %esi,%eax
  802a15:	19 fa                	sbb    %edi,%edx
  802a17:	d3 e8                	shr    %cl,%eax
  802a19:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802a1e:	89 d7                	mov    %edx,%edi
  802a20:	d3 e7                	shl    %cl,%edi
  802a22:	89 e9                	mov    %ebp,%ecx
  802a24:	09 f8                	or     %edi,%eax
  802a26:	d3 ea                	shr    %cl,%edx
  802a28:	83 c4 20             	add    $0x20,%esp
  802a2b:	5e                   	pop    %esi
  802a2c:	5f                   	pop    %edi
  802a2d:	5d                   	pop    %ebp
  802a2e:	c3                   	ret    
  802a2f:	90                   	nop
  802a30:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a34:	29 f9                	sub    %edi,%ecx
  802a36:	19 c6                	sbb    %eax,%esi
  802a38:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802a3c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802a40:	e9 ff fe ff ff       	jmp    802944 <__umoddi3+0x74>
