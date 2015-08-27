
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 88 09 00 00       	call   8009b9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800052:	0f 8e 40 01 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 00 38 80 00       	push   $0x803800
  800060:	e8 8d 0a 00 00       	call   800af2 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 26 01 00 00       	jmp    800198 <_gettoken+0x165>
	}

	if (debug > 1)
  800072:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 0f 38 80 00       	push   $0x80380f
  800084:	e8 69 0a 00 00       	call   800af2 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 1d 38 80 00       	push   $0x80381d
  8000b0:	e8 bf 11 00 00       	call   801274 <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
  8000bc:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000be:	0f b6 03             	movzbl (%ebx),%eax
  8000c1:	84 c0                	test   %al,%al
  8000c3:	75 2c                	jne    8000f1 <_gettoken+0xbe>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000ca:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000d1:	0f 8e c1 00 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("EOL\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 22 38 80 00       	push   $0x803822
  8000df:	e8 0e 0a 00 00       	call   800af2 <cprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ec:	e9 a7 00 00 00       	jmp    800198 <_gettoken+0x165>
	}
	if (strchr(SYMBOLS, *s)) {
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	0f be c0             	movsbl %al,%eax
  8000f7:	50                   	push   %eax
  8000f8:	68 33 38 80 00       	push   $0x803833
  8000fd:	e8 72 11 00 00       	call   801274 <strchr>
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	85 c0                	test   %eax,%eax
  800107:	74 30                	je     800139 <_gettoken+0x106>
		t = *s;
  800109:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  80010c:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  80010e:	c6 06 00             	movb   $0x0,(%esi)
  800111:	83 c6 01             	add    $0x1,%esi
  800114:	8b 45 10             	mov    0x10(%ebp),%eax
  800117:	89 30                	mov    %esi,(%eax)
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800119:	89 d8                	mov    %ebx,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  80011b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800122:	7e 74                	jle    800198 <_gettoken+0x165>
			cprintf("TOK %c\n", t);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	53                   	push   %ebx
  800128:	68 27 38 80 00       	push   $0x803827
  80012d:	e8 c0 09 00 00       	call   800af2 <cprintf>
  800132:	83 c4 10             	add    $0x10,%esp
		return t;
  800135:	89 d8                	mov    %ebx,%eax
  800137:	eb 5f                	jmp    800198 <_gettoken+0x165>
	}
	*p1 = s;
  800139:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013b:	eb 03                	jmp    800140 <_gettoken+0x10d>
		s++;
  80013d:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800140:	0f b6 03             	movzbl (%ebx),%eax
  800143:	84 c0                	test   %al,%al
  800145:	74 18                	je     80015f <_gettoken+0x12c>
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	0f be c0             	movsbl %al,%eax
  80014d:	50                   	push   %eax
  80014e:	68 2f 38 80 00       	push   $0x80382f
  800153:	e8 1c 11 00 00       	call   801274 <strchr>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 de                	je     80013d <_gettoken+0x10a>
		s++;
	*p2 = s;
  80015f:	8b 45 10             	mov    0x10(%ebp),%eax
  800162:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800164:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800169:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800170:	7e 26                	jle    800198 <_gettoken+0x165>
		t = **p2;
  800172:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	ff 37                	pushl  (%edi)
  80017d:	68 3b 38 80 00       	push   $0x80383b
  800182:	e8 6b 09 00 00       	call   800af2 <cprintf>
		**p2 = t;
  800187:	8b 45 10             	mov    0x10(%ebp),%eax
  80018a:	8b 00                	mov    (%eax),%eax
  80018c:	89 f2                	mov    %esi,%edx
  80018e:	88 10                	mov    %dl,(%eax)
  800190:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800193:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	74 22                	je     8001cf <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	68 0c 60 80 00       	push   $0x80600c
  8001b5:	68 10 60 80 00       	push   $0x806010
  8001ba:	50                   	push   %eax
  8001bb:	e8 73 fe ff ff       	call   800033 <_gettoken>
  8001c0:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cd:	eb 3a                	jmp    800209 <gettoken+0x69>
	}
	c = nc;
  8001cf:	a1 08 60 80 00       	mov    0x806008,%eax
  8001d4:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dc:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001e2:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	68 0c 60 80 00       	push   $0x80600c
  8001ec:	68 10 60 80 00       	push   $0x806010
  8001f1:	ff 35 0c 60 80 00    	pushl  0x80600c
  8001f7:	e8 37 fe ff ff       	call   800033 <_gettoken>
  8001fc:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  800201:	a1 04 60 80 00       	mov    0x806004,%eax
  800206:	83 c4 10             	add    $0x10,%esp
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800217:	6a 00                	push   $0x0
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 7f ff ff ff       	call   8001a0 <gettoken>
  800221:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800224:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800227:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	53                   	push   %ebx
  800230:	6a 00                	push   $0x0
  800232:	e8 69 ff ff ff       	call   8001a0 <gettoken>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	83 f8 3e             	cmp    $0x3e,%eax
  80023d:	0f 84 cc 00 00 00    	je     80030f <runcmd+0x104>
  800243:	83 f8 3e             	cmp    $0x3e,%eax
  800246:	7f 12                	jg     80025a <runcmd+0x4f>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 3b 02 00 00    	je     80048b <runcmd+0x280>
  800250:	83 f8 3c             	cmp    $0x3c,%eax
  800253:	74 3e                	je     800293 <runcmd+0x88>
  800255:	e9 1f 02 00 00       	jmp    800479 <runcmd+0x26e>
  80025a:	83 f8 77             	cmp    $0x77,%eax
  80025d:	74 0e                	je     80026d <runcmd+0x62>
  80025f:	83 f8 7c             	cmp    $0x7c,%eax
  800262:	0f 84 25 01 00 00    	je     80038d <runcmd+0x182>
  800268:	e9 0c 02 00 00       	jmp    800479 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026d:	83 fe 10             	cmp    $0x10,%esi
  800270:	75 15                	jne    800287 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	68 45 38 80 00       	push   $0x803845
  80027a:	e8 73 08 00 00       	call   800af2 <cprintf>
				exit();
  80027f:	e8 7b 07 00 00       	call   8009ff <exit>
  800284:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800287:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80028a:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028e:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  800291:	eb 99                	jmp    80022c <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	53                   	push   %ebx
  800297:	6a 00                	push   $0x0
  800299:	e8 02 ff ff ff       	call   8001a0 <gettoken>
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	83 f8 77             	cmp    $0x77,%eax
  8002a4:	74 15                	je     8002bb <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	68 7c 39 80 00       	push   $0x80397c
  8002ae:	e8 3f 08 00 00       	call   800af2 <cprintf>
				exit();
  8002b3:	e8 47 07 00 00       	call   8009ff <exit>
  8002b8:	83 c4 10             	add    $0x10,%esp
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//panic("< redirection not implemented");
                        if ((fd = open(t, O_RDONLY)) < 0) {
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	6a 00                	push   $0x0
  8002c0:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c3:	e8 29 21 00 00       	call   8023f1 <open>
  8002c8:	89 c7                	mov    %eax,%edi
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	79 1b                	jns    8002ec <runcmd+0xe1>
				cprintf("open %s for write: %e", t, fd);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d8:	68 59 38 80 00       	push   $0x803859
  8002dd:	e8 10 08 00 00       	call   800af2 <cprintf>
				exit();
  8002e2:	e8 18 07 00 00       	call   8009ff <exit>
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	eb 08                	jmp    8002f4 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	0f 84 38 ff ff ff    	je     80022c <runcmd+0x21>
				dup(fd, 0);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	6a 00                	push   $0x0
  8002f9:	57                   	push   %edi
  8002fa:	e8 57 1b 00 00       	call   801e56 <dup>
				close(fd);
  8002ff:	89 3c 24             	mov    %edi,(%esp)
  800302:	e8 fd 1a 00 00       	call   801e04 <close>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 1d ff ff ff       	jmp    80022c <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	53                   	push   %ebx
  800313:	6a 00                	push   $0x0
  800315:	e8 86 fe ff ff       	call   8001a0 <gettoken>
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	83 f8 77             	cmp    $0x77,%eax
  800320:	74 15                	je     800337 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	68 a4 39 80 00       	push   $0x8039a4
  80032a:	e8 c3 07 00 00       	call   800af2 <cprintf>
				exit();
  80032f:	e8 cb 06 00 00       	call   8009ff <exit>
  800334:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	68 01 03 00 00       	push   $0x301
  80033f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800342:	e8 aa 20 00 00       	call   8023f1 <open>
  800347:	89 c7                	mov    %eax,%edi
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 19                	jns    800369 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	50                   	push   %eax
  800354:	ff 75 a4             	pushl  -0x5c(%ebp)
  800357:	68 59 38 80 00       	push   $0x803859
  80035c:	e8 91 07 00 00       	call   800af2 <cprintf>
				exit();
  800361:	e8 99 06 00 00       	call   8009ff <exit>
  800366:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800369:	83 ff 01             	cmp    $0x1,%edi
  80036c:	0f 84 ba fe ff ff    	je     80022c <runcmd+0x21>
				dup(fd, 1);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	6a 01                	push   $0x1
  800377:	57                   	push   %edi
  800378:	e8 d9 1a 00 00       	call   801e56 <dup>
				close(fd);
  80037d:	89 3c 24             	mov    %edi,(%esp)
  800380:	e8 7f 1a 00 00       	call   801e04 <close>
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	e9 9f fe ff ff       	jmp    80022c <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800396:	50                   	push   %eax
  800397:	e8 0b 2e 00 00       	call   8031a7 <pipe>
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 16                	jns    8003b9 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	50                   	push   %eax
  8003a7:	68 6f 38 80 00       	push   $0x80386f
  8003ac:	e8 41 07 00 00       	call   800af2 <cprintf>
				exit();
  8003b1:	e8 49 06 00 00       	call   8009ff <exit>
  8003b6:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8003c0:	74 1c                	je     8003de <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003cb:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d1:	68 78 38 80 00       	push   $0x803878
  8003d6:	e8 17 07 00 00       	call   800af2 <cprintf>
  8003db:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003de:	e8 06 15 00 00       	call   8018e9 <fork>
  8003e3:	89 c7                	mov    %eax,%edi
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	79 16                	jns    8003ff <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	50                   	push   %eax
  8003ed:	68 6b 3e 80 00       	push   $0x803e6b
  8003f2:	e8 fb 06 00 00       	call   800af2 <cprintf>
				exit();
  8003f7:	e8 03 06 00 00       	call   8009ff <exit>
  8003fc:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003ff:	85 ff                	test   %edi,%edi
  800401:	75 3c                	jne    80043f <runcmd+0x234>
				if (p[0] != 0) {
  800403:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	74 1c                	je     800429 <runcmd+0x21e>
					dup(p[0], 0);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	6a 00                	push   $0x0
  800412:	50                   	push   %eax
  800413:	e8 3e 1a 00 00       	call   801e56 <dup>
					close(p[0]);
  800418:	83 c4 04             	add    $0x4,%esp
  80041b:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800421:	e8 de 19 00 00       	call   801e04 <close>
  800426:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800429:	83 ec 0c             	sub    $0xc,%esp
  80042c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800432:	e8 cd 19 00 00       	call   801e04 <close>
				goto again;
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	e9 e8 fd ff ff       	jmp    800227 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043f:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800445:	83 f8 01             	cmp    $0x1,%eax
  800448:	74 1c                	je     800466 <runcmd+0x25b>
					dup(p[1], 1);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 01                	push   $0x1
  80044f:	50                   	push   %eax
  800450:	e8 01 1a 00 00       	call   801e56 <dup>
					close(p[1]);
  800455:	83 c4 04             	add    $0x4,%esp
  800458:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045e:	e8 a1 19 00 00       	call   801e04 <close>
  800463:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046f:	e8 90 19 00 00       	call   801e04 <close>
				goto runit;
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	eb 17                	jmp    800490 <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800479:	50                   	push   %eax
  80047a:	68 85 38 80 00       	push   $0x803885
  80047f:	6a 78                	push   $0x78
  800481:	68 a1 38 80 00       	push   $0x8038a1
  800486:	e8 8e 05 00 00       	call   800a19 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80048b:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800490:	85 f6                	test   %esi,%esi
  800492:	75 22                	jne    8004b6 <runcmd+0x2ab>
		if (debug)
  800494:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80049b:	0f 84 96 01 00 00    	je     800637 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	68 ab 38 80 00       	push   $0x8038ab
  8004a9:	e8 44 06 00 00       	call   800af2 <cprintf>
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	e9 81 01 00 00       	jmp    800637 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b9:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004bc:	74 23                	je     8004e1 <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004be:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	50                   	push   %eax
  8004c9:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cf:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d5:	50                   	push   %eax
  8004d6:	e8 91 0c 00 00       	call   80116c <strcpy>
		argv[0] = argv0buf;
  8004db:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004e1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e8:	00 

	// Print the command.
	if (debug) {
  8004e9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004f0:	74 49                	je     80053b <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f2:	a1 48 64 80 00       	mov    0x806448,%eax
  8004f7:	8b 40 48             	mov    0x48(%eax),%eax
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	50                   	push   %eax
  8004fe:	68 ba 38 80 00       	push   $0x8038ba
  800503:	e8 ea 05 00 00       	call   800af2 <cprintf>
  800508:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 11                	jmp    800521 <runcmd+0x316>
			cprintf(" %s", argv[i]);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	50                   	push   %eax
  800514:	68 45 39 80 00       	push   $0x803945
  800519:	e8 d4 05 00 00       	call   800af2 <cprintf>
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800524:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 e5                	jne    800510 <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	68 20 38 80 00       	push   $0x803820
  800533:	e8 ba 05 00 00       	call   800af2 <cprintf>
  800538:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800541:	50                   	push   %eax
  800542:	ff 75 a8             	pushl  -0x58(%ebp)
  800545:	e8 5b 20 00 00       	call   8025a5 <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 89 c3 00 00 00    	jns    80061a <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800557:	83 ec 04             	sub    $0x4,%esp
  80055a:	50                   	push   %eax
  80055b:	ff 75 a8             	pushl  -0x58(%ebp)
  80055e:	68 c8 38 80 00       	push   $0x8038c8
  800563:	e8 8a 05 00 00       	call   800af2 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800568:	e8 c4 18 00 00       	call   801e31 <close_all>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 4c                	jmp    8005be <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800572:	a1 48 64 80 00       	mov    0x806448,%eax
  800577:	8b 40 48             	mov    0x48(%eax),%eax
  80057a:	53                   	push   %ebx
  80057b:	ff 75 a8             	pushl  -0x58(%ebp)
  80057e:	50                   	push   %eax
  80057f:	68 d6 38 80 00       	push   $0x8038d6
  800584:	e8 69 05 00 00       	call   800af2 <cprintf>
  800589:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 9a 2d 00 00       	call   80332f <wait>
		if (debug)
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80059f:	0f 84 8c 00 00 00    	je     800631 <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a5:	a1 48 64 80 00       	mov    0x806448,%eax
  8005aa:	8b 40 48             	mov    0x48(%eax),%eax
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	50                   	push   %eax
  8005b1:	68 eb 38 80 00       	push   $0x8038eb
  8005b6:	e8 37 05 00 00       	call   800af2 <cprintf>
  8005bb:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	74 51                	je     800613 <runcmd+0x408>
		if (debug)
  8005c2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005c9:	74 1a                	je     8005e5 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005cb:	a1 48 64 80 00       	mov    0x806448,%eax
  8005d0:	8b 40 48             	mov    0x48(%eax),%eax
  8005d3:	83 ec 04             	sub    $0x4,%esp
  8005d6:	57                   	push   %edi
  8005d7:	50                   	push   %eax
  8005d8:	68 01 39 80 00       	push   $0x803901
  8005dd:	e8 10 05 00 00       	call   800af2 <cprintf>
  8005e2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e5:	83 ec 0c             	sub    $0xc,%esp
  8005e8:	57                   	push   %edi
  8005e9:	e8 41 2d 00 00       	call   80332f <wait>
		if (debug)
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005f8:	74 19                	je     800613 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005fa:	a1 48 64 80 00       	mov    0x806448,%eax
  8005ff:	8b 40 48             	mov    0x48(%eax),%eax
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	50                   	push   %eax
  800606:	68 eb 38 80 00       	push   $0x8038eb
  80060b:	e8 e2 04 00 00       	call   800af2 <cprintf>
  800610:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800613:	e8 e7 03 00 00       	call   8009ff <exit>
  800618:	eb 1d                	jmp    800637 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80061a:	e8 12 18 00 00       	call   801e31 <close_all>
	if (r >= 0) {
		if (debug)
  80061f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800626:	0f 84 60 ff ff ff    	je     80058c <runcmd+0x381>
  80062c:	e9 41 ff ff ff       	jmp    800572 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  800631:	85 ff                	test   %edi,%edi
  800633:	75 b0                	jne    8005e5 <runcmd+0x3da>
  800635:	eb dc                	jmp    800613 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063a:	5b                   	pop    %ebx
  80063b:	5e                   	pop    %esi
  80063c:	5f                   	pop    %edi
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <usage>:
}


void
usage(void)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800645:	68 cc 39 80 00       	push   $0x8039cc
  80064a:	e8 a3 04 00 00       	call   800af2 <cprintf>
	exit();
  80064f:	e8 ab 03 00 00       	call   8009ff <exit>
  800654:	83 c4 10             	add    $0x10,%esp
}
  800657:	c9                   	leave  
  800658:	c3                   	ret    

00800659 <umain>:

void
umain(int argc, char **argv)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	57                   	push   %edi
  80065d:	56                   	push   %esi
  80065e:	53                   	push   %ebx
  80065f:	83 ec 30             	sub    $0x30,%esp
  800662:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800665:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800668:	50                   	push   %eax
  800669:	56                   	push   %esi
  80066a:	8d 45 08             	lea    0x8(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	e8 98 14 00 00       	call   801b0b <argstart>
	while ((r = argnext(&args)) >= 0)
  800673:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800676:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067d:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800682:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800685:	eb 2f                	jmp    8006b6 <umain+0x5d>
		switch (r) {
  800687:	83 f8 69             	cmp    $0x69,%eax
  80068a:	74 25                	je     8006b1 <umain+0x58>
  80068c:	83 f8 78             	cmp    $0x78,%eax
  80068f:	74 07                	je     800698 <umain+0x3f>
  800691:	83 f8 64             	cmp    $0x64,%eax
  800694:	75 14                	jne    8006aa <umain+0x51>
  800696:	eb 09                	jmp    8006a1 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800698:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069f:	eb 15                	jmp    8006b6 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006a1:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006a8:	eb 0c                	jmp    8006b6 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006aa:	e8 90 ff ff ff       	call   80063f <usage>
  8006af:	eb 05                	jmp    8006b6 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006b1:	bf 01 00 00 00       	mov    $0x1,%edi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	e8 7c 14 00 00       	call   801b3b <argnext>
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	79 c1                	jns    800687 <umain+0x2e>
  8006c6:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c8:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006cc:	7e 05                	jle    8006d3 <umain+0x7a>
		usage();
  8006ce:	e8 6c ff ff ff       	call   80063f <usage>
	if (argc == 2) {
  8006d3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d7:	75 56                	jne    80072f <umain+0xd6>
		close(0);
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	6a 00                	push   $0x0
  8006de:	e8 21 17 00 00       	call   801e04 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	6a 00                	push   $0x0
  8006e8:	ff 76 04             	pushl  0x4(%esi)
  8006eb:	e8 01 1d 00 00       	call   8023f1 <open>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	79 1b                	jns    800712 <umain+0xb9>
			panic("open %s: %e", argv[1], r);
  8006f7:	83 ec 0c             	sub    $0xc,%esp
  8006fa:	50                   	push   %eax
  8006fb:	ff 76 04             	pushl  0x4(%esi)
  8006fe:	68 21 39 80 00       	push   $0x803921
  800703:	68 28 01 00 00       	push   $0x128
  800708:	68 a1 38 80 00       	push   $0x8038a1
  80070d:	e8 07 03 00 00       	call   800a19 <_panic>
		assert(r == 0);
  800712:	85 c0                	test   %eax,%eax
  800714:	74 19                	je     80072f <umain+0xd6>
  800716:	68 2d 39 80 00       	push   $0x80392d
  80071b:	68 34 39 80 00       	push   $0x803934
  800720:	68 29 01 00 00       	push   $0x129
  800725:	68 a1 38 80 00       	push   $0x8038a1
  80072a:	e8 ea 02 00 00       	call   800a19 <_panic>
	}
	if (interactive == '?')
  80072f:	83 fb 3f             	cmp    $0x3f,%ebx
  800732:	75 0f                	jne    800743 <umain+0xea>
		interactive = iscons(0);
  800734:	83 ec 0c             	sub    $0xc,%esp
  800737:	6a 00                	push   $0x0
  800739:	e8 f5 01 00 00       	call   800933 <iscons>
  80073e:	89 c7                	mov    %eax,%edi
  800740:	83 c4 10             	add    $0x10,%esp

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800743:	85 ff                	test   %edi,%edi
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	ba 1e 39 80 00       	mov    $0x80391e,%edx
  80074f:	0f 45 c2             	cmovne %edx,%eax
  800752:	83 ec 0c             	sub    $0xc,%esp
  800755:	50                   	push   %eax
  800756:	e8 e5 08 00 00       	call   801040 <readline>
  80075b:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 c0                	test   %eax,%eax
  800762:	75 1e                	jne    800782 <umain+0x129>
			if (debug)
  800764:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80076b:	74 10                	je     80077d <umain+0x124>
				cprintf("EXITING\n");
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	68 49 39 80 00       	push   $0x803949
  800775:	e8 78 03 00 00       	call   800af2 <cprintf>
  80077a:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80077d:	e8 7d 02 00 00       	call   8009ff <exit>
		}
		if (debug)
  800782:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800789:	74 11                	je     80079c <umain+0x143>
			cprintf("LINE: %s\n", buf);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	68 52 39 80 00       	push   $0x803952
  800794:	e8 59 03 00 00       	call   800af2 <cprintf>
  800799:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80079c:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079f:	74 a2                	je     800743 <umain+0xea>
			continue;
		if (echocmds)
  8007a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a5:	74 11                	je     8007b8 <umain+0x15f>
			printf("# %s\n", buf);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	68 5c 39 80 00       	push   $0x80395c
  8007b0:	e8 da 1d 00 00       	call   80258f <printf>
  8007b5:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007bf:	74 10                	je     8007d1 <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007c1:	83 ec 0c             	sub    $0xc,%esp
  8007c4:	68 62 39 80 00       	push   $0x803962
  8007c9:	e8 24 03 00 00       	call   800af2 <cprintf>
  8007ce:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0) 
  8007d1:	e8 13 11 00 00       	call   8018e9 <fork>
  8007d6:	89 c6                	mov    %eax,%esi
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	79 15                	jns    8007f1 <umain+0x198>
			panic("fork: %e", r);
  8007dc:	50                   	push   %eax
  8007dd:	68 6b 3e 80 00       	push   $0x803e6b
  8007e2:	68 40 01 00 00       	push   $0x140
  8007e7:	68 a1 38 80 00       	push   $0x8038a1
  8007ec:	e8 28 02 00 00       	call   800a19 <_panic>
		if (debug)
  8007f1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007f8:	74 11                	je     80080b <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	50                   	push   %eax
  8007fe:	68 6f 39 80 00       	push   $0x80396f
  800803:	e8 ea 02 00 00       	call   800af2 <cprintf>
  800808:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  80080b:	85 f6                	test   %esi,%esi
  80080d:	75 16                	jne    800825 <umain+0x1cc>
			runcmd(buf);
  80080f:	83 ec 0c             	sub    $0xc,%esp
  800812:	53                   	push   %ebx
  800813:	e8 f3 f9 ff ff       	call   80020b <runcmd>
			exit();
  800818:	e8 e2 01 00 00       	call   8009ff <exit>
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	e9 1e ff ff ff       	jmp    800743 <umain+0xea>
		} else
			wait(r);
  800825:	83 ec 0c             	sub    $0xc,%esp
  800828:	56                   	push   %esi
  800829:	e8 01 2b 00 00       	call   80332f <wait>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	e9 0d ff ff ff       	jmp    800743 <umain+0xea>

00800836 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800846:	68 ed 39 80 00       	push   $0x8039ed
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	e8 19 09 00 00       	call   80116c <strcpy>
	return 0;
}
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800866:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80086b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	eb 2d                	jmp    8008a0 <devcons_write+0x46>
		m = n - tot;
  800873:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800876:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800878:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80087b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800880:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800883:	83 ec 04             	sub    $0x4,%esp
  800886:	53                   	push   %ebx
  800887:	03 45 0c             	add    0xc(%ebp),%eax
  80088a:	50                   	push   %eax
  80088b:	57                   	push   %edi
  80088c:	e8 6d 0a 00 00       	call   8012fe <memmove>
		sys_cputs(buf, m);
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	57                   	push   %edi
  800896:	e8 1e 0c 00 00       	call   8014b9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80089b:	01 de                	add    %ebx,%esi
  80089d:	83 c4 10             	add    $0x10,%esp
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a5:	72 cc                	jb     800873 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8008ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008be:	75 07                	jne    8008c7 <devcons_read+0x18>
  8008c0:	eb 28                	jmp    8008ea <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c2:	e8 8f 0c 00 00       	call   801556 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c7:	e8 0b 0c 00 00       	call   8014d7 <sys_cgetc>
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 f2                	je     8008c2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 16                	js     8008ea <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d4:	83 f8 04             	cmp    $0x4,%eax
  8008d7:	74 0c                	je     8008e5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	88 02                	mov    %al,(%edx)
	return 1;
  8008de:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e3:	eb 05                	jmp    8008ea <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f8:	6a 01                	push   $0x1
  8008fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	e8 b6 0b 00 00       	call   8014b9 <sys_cputs>
  800903:	83 c4 10             	add    $0x10,%esp
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <getchar>:

int
getchar(void)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090e:	6a 01                	push   $0x1
  800910:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	6a 00                	push   $0x0
  800916:	e8 29 16 00 00       	call   801f44 <read>
	if (r < 0)
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	85 c0                	test   %eax,%eax
  800920:	78 0f                	js     800931 <getchar+0x29>
		return r;
	if (r < 1)
  800922:	85 c0                	test   %eax,%eax
  800924:	7e 06                	jle    80092c <getchar+0x24>
		return -E_EOF;
	return c;
  800926:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80092a:	eb 05                	jmp    800931 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80092c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800939:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093c:	50                   	push   %eax
  80093d:	ff 75 08             	pushl  0x8(%ebp)
  800940:	e8 90 13 00 00       	call   801cd5 <fd_lookup>
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 11                	js     80095d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800955:	39 10                	cmp    %edx,(%eax)
  800957:	0f 94 c0             	sete   %al
  80095a:	0f b6 c0             	movzbl %al,%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <opencons>:

int
opencons(void)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800965:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800968:	50                   	push   %eax
  800969:	e8 18 13 00 00       	call   801c86 <fd_alloc>
  80096e:	83 c4 10             	add    $0x10,%esp
		return r;
  800971:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800973:	85 c0                	test   %eax,%eax
  800975:	78 3e                	js     8009b5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800977:	83 ec 04             	sub    $0x4,%esp
  80097a:	68 07 04 00 00       	push   $0x407
  80097f:	ff 75 f4             	pushl  -0xc(%ebp)
  800982:	6a 00                	push   $0x0
  800984:	e8 ec 0b 00 00       	call   801575 <sys_page_alloc>
  800989:	83 c4 10             	add    $0x10,%esp
		return r;
  80098c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098e:	85 c0                	test   %eax,%eax
  800990:	78 23                	js     8009b5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800992:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a7:	83 ec 0c             	sub    $0xc,%esp
  8009aa:	50                   	push   %eax
  8009ab:	e8 af 12 00 00       	call   801c5f <fd2num>
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	83 c4 10             	add    $0x10,%esp
}
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8009c4:	e8 6e 0b 00 00       	call   801537 <sys_getenvid>
  8009c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d6:	a3 48 64 80 00       	mov    %eax,0x806448

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	7e 07                	jle    8009e6 <libmain+0x2d>
		binaryname = argv[0];
  8009df:	8b 06                	mov    (%esi),%eax
  8009e1:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	e8 69 fc ff ff       	call   800659 <umain>

	// exit gracefully
	exit();
  8009f0:	e8 0a 00 00 00       	call   8009ff <exit>
  8009f5:	83 c4 10             	add    $0x10,%esp
}
  8009f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a05:	e8 27 14 00 00       	call   801e31 <close_all>
	sys_env_destroy(0);
  800a0a:	83 ec 0c             	sub    $0xc,%esp
  800a0d:	6a 00                	push   $0x0
  800a0f:	e8 e2 0a 00 00       	call   8014f6 <sys_env_destroy>
  800a14:	83 c4 10             	add    $0x10,%esp
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a21:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a27:	e8 0b 0b 00 00       	call   801537 <sys_getenvid>
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	ff 75 08             	pushl  0x8(%ebp)
  800a35:	56                   	push   %esi
  800a36:	50                   	push   %eax
  800a37:	68 04 3a 80 00       	push   $0x803a04
  800a3c:	e8 b1 00 00 00       	call   800af2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a41:	83 c4 18             	add    $0x18,%esp
  800a44:	53                   	push   %ebx
  800a45:	ff 75 10             	pushl  0x10(%ebp)
  800a48:	e8 54 00 00 00       	call   800aa1 <vcprintf>
	cprintf("\n");
  800a4d:	c7 04 24 20 38 80 00 	movl   $0x803820,(%esp)
  800a54:	e8 99 00 00 00       	call   800af2 <cprintf>
  800a59:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a5c:	cc                   	int3   
  800a5d:	eb fd                	jmp    800a5c <_panic+0x43>

00800a5f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	53                   	push   %ebx
  800a63:	83 ec 04             	sub    $0x4,%esp
  800a66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a69:	8b 13                	mov    (%ebx),%edx
  800a6b:	8d 42 01             	lea    0x1(%edx),%eax
  800a6e:	89 03                	mov    %eax,(%ebx)
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a77:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a7c:	75 1a                	jne    800a98 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	68 ff 00 00 00       	push   $0xff
  800a86:	8d 43 08             	lea    0x8(%ebx),%eax
  800a89:	50                   	push   %eax
  800a8a:	e8 2a 0a 00 00       	call   8014b9 <sys_cputs>
		b->idx = 0;
  800a8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a95:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a98:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aaa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ab1:	00 00 00 
	b.cnt = 0;
  800ab4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800abb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	ff 75 08             	pushl  0x8(%ebp)
  800ac4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800aca:	50                   	push   %eax
  800acb:	68 5f 0a 80 00       	push   $0x800a5f
  800ad0:	e8 4f 01 00 00       	call   800c24 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad5:	83 c4 08             	add    $0x8,%esp
  800ad8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ade:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	e8 cf 09 00 00       	call   8014b9 <sys_cputs>

	return b.cnt;
}
  800aea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800afb:	50                   	push   %eax
  800afc:	ff 75 08             	pushl  0x8(%ebp)
  800aff:	e8 9d ff ff ff       	call   800aa1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 1c             	sub    $0x1c,%esp
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b21:	8b 45 10             	mov    0x10(%ebp),%eax
  800b24:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b2a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800b31:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800b34:	72 05                	jb     800b3b <printnum+0x35>
  800b36:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800b39:	77 3e                	ja     800b79 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 18             	pushl  0x18(%ebp)
  800b41:	83 eb 01             	sub    $0x1,%ebx
  800b44:	53                   	push   %ebx
  800b45:	50                   	push   %eax
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4c:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4f:	ff 75 dc             	pushl  -0x24(%ebp)
  800b52:	ff 75 d8             	pushl  -0x28(%ebp)
  800b55:	e8 f6 29 00 00       	call   803550 <__udivdi3>
  800b5a:	83 c4 18             	add    $0x18,%esp
  800b5d:	52                   	push   %edx
  800b5e:	50                   	push   %eax
  800b5f:	89 f2                	mov    %esi,%edx
  800b61:	89 f8                	mov    %edi,%eax
  800b63:	e8 9e ff ff ff       	call   800b06 <printnum>
  800b68:	83 c4 20             	add    $0x20,%esp
  800b6b:	eb 13                	jmp    800b80 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b6d:	83 ec 08             	sub    $0x8,%esp
  800b70:	56                   	push   %esi
  800b71:	ff 75 18             	pushl  0x18(%ebp)
  800b74:	ff d7                	call   *%edi
  800b76:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b79:	83 eb 01             	sub    $0x1,%ebx
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	7f ed                	jg     800b6d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b80:	83 ec 08             	sub    $0x8,%esp
  800b83:	56                   	push   %esi
  800b84:	83 ec 04             	sub    $0x4,%esp
  800b87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8d:	ff 75 dc             	pushl  -0x24(%ebp)
  800b90:	ff 75 d8             	pushl  -0x28(%ebp)
  800b93:	e8 e8 2a 00 00       	call   803680 <__umoddi3>
  800b98:	83 c4 14             	add    $0x14,%esp
  800b9b:	0f be 80 27 3a 80 00 	movsbl 0x803a27(%eax),%eax
  800ba2:	50                   	push   %eax
  800ba3:	ff d7                	call   *%edi
  800ba5:	83 c4 10             	add    $0x10,%esp
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb3:	83 fa 01             	cmp    $0x1,%edx
  800bb6:	7e 0e                	jle    800bc6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb8:	8b 10                	mov    (%eax),%edx
  800bba:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbd:	89 08                	mov    %ecx,(%eax)
  800bbf:	8b 02                	mov    (%edx),%eax
  800bc1:	8b 52 04             	mov    0x4(%edx),%edx
  800bc4:	eb 22                	jmp    800be8 <getuint+0x38>
	else if (lflag)
  800bc6:	85 d2                	test   %edx,%edx
  800bc8:	74 10                	je     800bda <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bca:	8b 10                	mov    (%eax),%edx
  800bcc:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bcf:	89 08                	mov    %ecx,(%eax)
  800bd1:	8b 02                	mov    (%edx),%eax
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	eb 0e                	jmp    800be8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bda:	8b 10                	mov    (%eax),%edx
  800bdc:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bdf:	89 08                	mov    %ecx,(%eax)
  800be1:	8b 02                	mov    (%edx),%eax
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf4:	8b 10                	mov    (%eax),%edx
  800bf6:	3b 50 04             	cmp    0x4(%eax),%edx
  800bf9:	73 0a                	jae    800c05 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bfe:	89 08                	mov    %ecx,(%eax)
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	88 02                	mov    %al,(%edx)
}
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c10:	50                   	push   %eax
  800c11:	ff 75 10             	pushl  0x10(%ebp)
  800c14:	ff 75 0c             	pushl  0xc(%ebp)
  800c17:	ff 75 08             	pushl  0x8(%ebp)
  800c1a:	e8 05 00 00 00       	call   800c24 <vprintfmt>
	va_end(ap);
  800c1f:	83 c4 10             	add    $0x10,%esp
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 2c             	sub    $0x2c,%esp
  800c2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c33:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c36:	eb 12                	jmp    800c4a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	0f 84 90 03 00 00    	je     800fd0 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	53                   	push   %ebx
  800c44:	50                   	push   %eax
  800c45:	ff d6                	call   *%esi
  800c47:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4a:	83 c7 01             	add    $0x1,%edi
  800c4d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c51:	83 f8 25             	cmp    $0x25,%eax
  800c54:	75 e2                	jne    800c38 <vprintfmt+0x14>
  800c56:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c61:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c68:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	eb 07                	jmp    800c7d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c76:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c79:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7d:	8d 47 01             	lea    0x1(%edi),%eax
  800c80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c83:	0f b6 07             	movzbl (%edi),%eax
  800c86:	0f b6 c8             	movzbl %al,%ecx
  800c89:	83 e8 23             	sub    $0x23,%eax
  800c8c:	3c 55                	cmp    $0x55,%al
  800c8e:	0f 87 21 03 00 00    	ja     800fb5 <vprintfmt+0x391>
  800c94:	0f b6 c0             	movzbl %al,%eax
  800c97:	ff 24 85 80 3b 80 00 	jmp    *0x803b80(,%eax,4)
  800c9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca5:	eb d6                	jmp    800c7d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800caa:	b8 00 00 00 00       	mov    $0x0,%eax
  800caf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cb9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cbc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cbf:	83 fa 09             	cmp    $0x9,%edx
  800cc2:	77 39                	ja     800cfd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc7:	eb e9                	jmp    800cb2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccc:	8d 48 04             	lea    0x4(%eax),%ecx
  800ccf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd2:	8b 00                	mov    (%eax),%eax
  800cd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cda:	eb 27                	jmp    800d03 <vprintfmt+0xdf>
  800cdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce6:	0f 49 c8             	cmovns %eax,%ecx
  800ce9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cef:	eb 8c                	jmp    800c7d <vprintfmt+0x59>
  800cf1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfb:	eb 80                	jmp    800c7d <vprintfmt+0x59>
  800cfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d00:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d03:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d07:	0f 89 70 ff ff ff    	jns    800c7d <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d10:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d13:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d1a:	e9 5e ff ff ff       	jmp    800c7d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d1f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d25:	e9 53 ff ff ff       	jmp    800c7d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2d:	8d 50 04             	lea    0x4(%eax),%edx
  800d30:	89 55 14             	mov    %edx,0x14(%ebp)
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	53                   	push   %ebx
  800d37:	ff 30                	pushl  (%eax)
  800d39:	ff d6                	call   *%esi
			break;
  800d3b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d41:	e9 04 ff ff ff       	jmp    800c4a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d46:	8b 45 14             	mov    0x14(%ebp),%eax
  800d49:	8d 50 04             	lea    0x4(%eax),%edx
  800d4c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4f:	8b 00                	mov    (%eax),%eax
  800d51:	99                   	cltd   
  800d52:	31 d0                	xor    %edx,%eax
  800d54:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d56:	83 f8 0f             	cmp    $0xf,%eax
  800d59:	7f 0b                	jg     800d66 <vprintfmt+0x142>
  800d5b:	8b 14 85 00 3d 80 00 	mov    0x803d00(,%eax,4),%edx
  800d62:	85 d2                	test   %edx,%edx
  800d64:	75 18                	jne    800d7e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d66:	50                   	push   %eax
  800d67:	68 3f 3a 80 00       	push   $0x803a3f
  800d6c:	53                   	push   %ebx
  800d6d:	56                   	push   %esi
  800d6e:	e8 94 fe ff ff       	call   800c07 <printfmt>
  800d73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d79:	e9 cc fe ff ff       	jmp    800c4a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7e:	52                   	push   %edx
  800d7f:	68 46 39 80 00       	push   $0x803946
  800d84:	53                   	push   %ebx
  800d85:	56                   	push   %esi
  800d86:	e8 7c fe ff ff       	call   800c07 <printfmt>
  800d8b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d91:	e9 b4 fe ff ff       	jmp    800c4a <vprintfmt+0x26>
  800d96:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d9c:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800da2:	8d 50 04             	lea    0x4(%eax),%edx
  800da5:	89 55 14             	mov    %edx,0x14(%ebp)
  800da8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800daa:	85 ff                	test   %edi,%edi
  800dac:	ba 38 3a 80 00       	mov    $0x803a38,%edx
  800db1:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800db4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800db8:	0f 84 92 00 00 00    	je     800e50 <vprintfmt+0x22c>
  800dbe:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800dc2:	0f 8e 96 00 00 00    	jle    800e5e <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc8:	83 ec 08             	sub    $0x8,%esp
  800dcb:	51                   	push   %ecx
  800dcc:	57                   	push   %edi
  800dcd:	e8 79 03 00 00       	call   80114b <strnlen>
  800dd2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dd5:	29 c1                	sub    %eax,%ecx
  800dd7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dda:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800ddd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800de1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de9:	eb 0f                	jmp    800dfa <vprintfmt+0x1d6>
					putch(padc, putdat);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	53                   	push   %ebx
  800def:	ff 75 e0             	pushl  -0x20(%ebp)
  800df2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800df4:	83 ef 01             	sub    $0x1,%edi
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 ff                	test   %edi,%edi
  800dfc:	7f ed                	jg     800deb <vprintfmt+0x1c7>
  800dfe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e01:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e04:	85 c9                	test   %ecx,%ecx
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	0f 49 c1             	cmovns %ecx,%eax
  800e0e:	29 c1                	sub    %eax,%ecx
  800e10:	89 75 08             	mov    %esi,0x8(%ebp)
  800e13:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e19:	89 cb                	mov    %ecx,%ebx
  800e1b:	eb 4d                	jmp    800e6a <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e1d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e21:	74 1b                	je     800e3e <vprintfmt+0x21a>
  800e23:	0f be c0             	movsbl %al,%eax
  800e26:	83 e8 20             	sub    $0x20,%eax
  800e29:	83 f8 5e             	cmp    $0x5e,%eax
  800e2c:	76 10                	jbe    800e3e <vprintfmt+0x21a>
					putch('?', putdat);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	6a 3f                	push   $0x3f
  800e36:	ff 55 08             	call   *0x8(%ebp)
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	eb 0d                	jmp    800e4b <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	ff 75 0c             	pushl  0xc(%ebp)
  800e44:	52                   	push   %edx
  800e45:	ff 55 08             	call   *0x8(%ebp)
  800e48:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e4b:	83 eb 01             	sub    $0x1,%ebx
  800e4e:	eb 1a                	jmp    800e6a <vprintfmt+0x246>
  800e50:	89 75 08             	mov    %esi,0x8(%ebp)
  800e53:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e5c:	eb 0c                	jmp    800e6a <vprintfmt+0x246>
  800e5e:	89 75 08             	mov    %esi,0x8(%ebp)
  800e61:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e64:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e67:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e6a:	83 c7 01             	add    $0x1,%edi
  800e6d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e71:	0f be d0             	movsbl %al,%edx
  800e74:	85 d2                	test   %edx,%edx
  800e76:	74 23                	je     800e9b <vprintfmt+0x277>
  800e78:	85 f6                	test   %esi,%esi
  800e7a:	78 a1                	js     800e1d <vprintfmt+0x1f9>
  800e7c:	83 ee 01             	sub    $0x1,%esi
  800e7f:	79 9c                	jns    800e1d <vprintfmt+0x1f9>
  800e81:	89 df                	mov    %ebx,%edi
  800e83:	8b 75 08             	mov    0x8(%ebp),%esi
  800e86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e89:	eb 18                	jmp    800ea3 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	53                   	push   %ebx
  800e8f:	6a 20                	push   $0x20
  800e91:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e93:	83 ef 01             	sub    $0x1,%edi
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	eb 08                	jmp    800ea3 <vprintfmt+0x27f>
  800e9b:	89 df                	mov    %ebx,%edi
  800e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea3:	85 ff                	test   %edi,%edi
  800ea5:	7f e4                	jg     800e8b <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eaa:	e9 9b fd ff ff       	jmp    800c4a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eaf:	83 fa 01             	cmp    $0x1,%edx
  800eb2:	7e 16                	jle    800eca <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800eb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb7:	8d 50 08             	lea    0x8(%eax),%edx
  800eba:	89 55 14             	mov    %edx,0x14(%ebp)
  800ebd:	8b 50 04             	mov    0x4(%eax),%edx
  800ec0:	8b 00                	mov    (%eax),%eax
  800ec2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec8:	eb 32                	jmp    800efc <vprintfmt+0x2d8>
	else if (lflag)
  800eca:	85 d2                	test   %edx,%edx
  800ecc:	74 18                	je     800ee6 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800ece:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed1:	8d 50 04             	lea    0x4(%eax),%edx
  800ed4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed7:	8b 00                	mov    (%eax),%eax
  800ed9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800edc:	89 c1                	mov    %eax,%ecx
  800ede:	c1 f9 1f             	sar    $0x1f,%ecx
  800ee1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ee4:	eb 16                	jmp    800efc <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800ee6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee9:	8d 50 04             	lea    0x4(%eax),%edx
  800eec:	89 55 14             	mov    %edx,0x14(%ebp)
  800eef:	8b 00                	mov    (%eax),%eax
  800ef1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef4:	89 c1                	mov    %eax,%ecx
  800ef6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800efc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800eff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f02:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f0b:	79 74                	jns    800f81 <vprintfmt+0x35d>
				putch('-', putdat);
  800f0d:	83 ec 08             	sub    $0x8,%esp
  800f10:	53                   	push   %ebx
  800f11:	6a 2d                	push   $0x2d
  800f13:	ff d6                	call   *%esi
				num = -(long long) num;
  800f15:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f1b:	f7 d8                	neg    %eax
  800f1d:	83 d2 00             	adc    $0x0,%edx
  800f20:	f7 da                	neg    %edx
  800f22:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f25:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f2a:	eb 55                	jmp    800f81 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f2c:	8d 45 14             	lea    0x14(%ebp),%eax
  800f2f:	e8 7c fc ff ff       	call   800bb0 <getuint>
			base = 10;
  800f34:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f39:	eb 46                	jmp    800f81 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800f3e:	e8 6d fc ff ff       	call   800bb0 <getuint>
                        base = 8;
  800f43:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800f48:	eb 37                	jmp    800f81 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	53                   	push   %ebx
  800f4e:	6a 30                	push   $0x30
  800f50:	ff d6                	call   *%esi
			putch('x', putdat);
  800f52:	83 c4 08             	add    $0x8,%esp
  800f55:	53                   	push   %ebx
  800f56:	6a 78                	push   $0x78
  800f58:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5d:	8d 50 04             	lea    0x4(%eax),%edx
  800f60:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f63:	8b 00                	mov    (%eax),%eax
  800f65:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f6a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f6d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f72:	eb 0d                	jmp    800f81 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f74:	8d 45 14             	lea    0x14(%ebp),%eax
  800f77:	e8 34 fc ff ff       	call   800bb0 <getuint>
			base = 16;
  800f7c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f88:	57                   	push   %edi
  800f89:	ff 75 e0             	pushl  -0x20(%ebp)
  800f8c:	51                   	push   %ecx
  800f8d:	52                   	push   %edx
  800f8e:	50                   	push   %eax
  800f8f:	89 da                	mov    %ebx,%edx
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	e8 6e fb ff ff       	call   800b06 <printnum>
			break;
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f9e:	e9 a7 fc ff ff       	jmp    800c4a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	53                   	push   %ebx
  800fa7:	51                   	push   %ecx
  800fa8:	ff d6                	call   *%esi
			break;
  800faa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fb0:	e9 95 fc ff ff       	jmp    800c4a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	53                   	push   %ebx
  800fb9:	6a 25                	push   $0x25
  800fbb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	eb 03                	jmp    800fc5 <vprintfmt+0x3a1>
  800fc2:	83 ef 01             	sub    $0x1,%edi
  800fc5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fc9:	75 f7                	jne    800fc2 <vprintfmt+0x39e>
  800fcb:	e9 7a fc ff ff       	jmp    800c4a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 18             	sub    $0x18,%esp
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fe4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800feb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	74 26                	je     80101f <vsnprintf+0x47>
  800ff9:	85 d2                	test   %edx,%edx
  800ffb:	7e 22                	jle    80101f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ffd:	ff 75 14             	pushl  0x14(%ebp)
  801000:	ff 75 10             	pushl  0x10(%ebp)
  801003:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801006:	50                   	push   %eax
  801007:	68 ea 0b 80 00       	push   $0x800bea
  80100c:	e8 13 fc ff ff       	call   800c24 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801011:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801014:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	eb 05                	jmp    801024 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80101f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80102c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80102f:	50                   	push   %eax
  801030:	ff 75 10             	pushl  0x10(%ebp)
  801033:	ff 75 0c             	pushl  0xc(%ebp)
  801036:	ff 75 08             	pushl  0x8(%ebp)
  801039:	e8 9a ff ff ff       	call   800fd8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	74 13                	je     801063 <readline+0x23>
		fprintf(1, "%s", prompt);
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	50                   	push   %eax
  801054:	68 46 39 80 00       	push   $0x803946
  801059:	6a 01                	push   $0x1
  80105b:	e8 18 15 00 00       	call   802578 <fprintf>
  801060:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	6a 00                	push   $0x0
  801068:	e8 c6 f8 ff ff       	call   800933 <iscons>
  80106d:	89 c7                	mov    %eax,%edi
  80106f:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801072:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801077:	e8 8c f8 ff ff       	call   800908 <getchar>
  80107c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80107e:	85 c0                	test   %eax,%eax
  801080:	79 29                	jns    8010ab <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801087:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80108a:	0f 84 9b 00 00 00    	je     80112b <readline+0xeb>
				cprintf("read error: %e\n", c);
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	53                   	push   %ebx
  801094:	68 5f 3d 80 00       	push   $0x803d5f
  801099:	e8 54 fa ff ff       	call   800af2 <cprintf>
  80109e:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a6:	e9 80 00 00 00       	jmp    80112b <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010ab:	83 f8 7f             	cmp    $0x7f,%eax
  8010ae:	0f 94 c2             	sete   %dl
  8010b1:	83 f8 08             	cmp    $0x8,%eax
  8010b4:	0f 94 c0             	sete   %al
  8010b7:	08 c2                	or     %al,%dl
  8010b9:	74 1a                	je     8010d5 <readline+0x95>
  8010bb:	85 f6                	test   %esi,%esi
  8010bd:	7e 16                	jle    8010d5 <readline+0x95>
			if (echoing)
  8010bf:	85 ff                	test   %edi,%edi
  8010c1:	74 0d                	je     8010d0 <readline+0x90>
				cputchar('\b');
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	6a 08                	push   $0x8
  8010c8:	e8 1f f8 ff ff       	call   8008ec <cputchar>
  8010cd:	83 c4 10             	add    $0x10,%esp
			i--;
  8010d0:	83 ee 01             	sub    $0x1,%esi
  8010d3:	eb a2                	jmp    801077 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010d5:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010db:	7f 23                	jg     801100 <readline+0xc0>
  8010dd:	83 fb 1f             	cmp    $0x1f,%ebx
  8010e0:	7e 1e                	jle    801100 <readline+0xc0>
			if (echoing)
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	74 0c                	je     8010f2 <readline+0xb2>
				cputchar(c);
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	e8 fd f7 ff ff       	call   8008ec <cputchar>
  8010ef:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010f2:	88 9e 40 60 80 00    	mov    %bl,0x806040(%esi)
  8010f8:	8d 76 01             	lea    0x1(%esi),%esi
  8010fb:	e9 77 ff ff ff       	jmp    801077 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801100:	83 fb 0d             	cmp    $0xd,%ebx
  801103:	74 09                	je     80110e <readline+0xce>
  801105:	83 fb 0a             	cmp    $0xa,%ebx
  801108:	0f 85 69 ff ff ff    	jne    801077 <readline+0x37>
			if (echoing)
  80110e:	85 ff                	test   %edi,%edi
  801110:	74 0d                	je     80111f <readline+0xdf>
				cputchar('\n');
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	6a 0a                	push   $0xa
  801117:	e8 d0 f7 ff ff       	call   8008ec <cputchar>
  80111c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80111f:	c6 86 40 60 80 00 00 	movb   $0x0,0x806040(%esi)
			return buf;
  801126:	b8 40 60 80 00       	mov    $0x806040,%eax
		}
	}
}
  80112b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb 03                	jmp    801143 <strlen+0x10>
		n++;
  801140:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801143:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801147:	75 f7                	jne    801140 <strlen+0xd>
		n++;
	return n;
}
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801151:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801154:	ba 00 00 00 00       	mov    $0x0,%edx
  801159:	eb 03                	jmp    80115e <strnlen+0x13>
		n++;
  80115b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80115e:	39 c2                	cmp    %eax,%edx
  801160:	74 08                	je     80116a <strnlen+0x1f>
  801162:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801166:	75 f3                	jne    80115b <strnlen+0x10>
  801168:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	53                   	push   %ebx
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801176:	89 c2                	mov    %eax,%edx
  801178:	83 c2 01             	add    $0x1,%edx
  80117b:	83 c1 01             	add    $0x1,%ecx
  80117e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801182:	88 5a ff             	mov    %bl,-0x1(%edx)
  801185:	84 db                	test   %bl,%bl
  801187:	75 ef                	jne    801178 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801189:	5b                   	pop    %ebx
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801193:	53                   	push   %ebx
  801194:	e8 9a ff ff ff       	call   801133 <strlen>
  801199:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80119c:	ff 75 0c             	pushl  0xc(%ebp)
  80119f:	01 d8                	add    %ebx,%eax
  8011a1:	50                   	push   %eax
  8011a2:	e8 c5 ff ff ff       	call   80116c <strcpy>
	return dst;
}
  8011a7:	89 d8                	mov    %ebx,%eax
  8011a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
  8011b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	89 f3                	mov    %esi,%ebx
  8011bb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011be:	89 f2                	mov    %esi,%edx
  8011c0:	eb 0f                	jmp    8011d1 <strncpy+0x23>
		*dst++ = *src;
  8011c2:	83 c2 01             	add    $0x1,%edx
  8011c5:	0f b6 01             	movzbl (%ecx),%eax
  8011c8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011cb:	80 39 01             	cmpb   $0x1,(%ecx)
  8011ce:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d1:	39 da                	cmp    %ebx,%edx
  8011d3:	75 ed                	jne    8011c2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011d5:	89 f0                	mov    %esi,%eax
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e6:	8b 55 10             	mov    0x10(%ebp),%edx
  8011e9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011eb:	85 d2                	test   %edx,%edx
  8011ed:	74 21                	je     801210 <strlcpy+0x35>
  8011ef:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	eb 09                	jmp    801200 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011f7:	83 c2 01             	add    $0x1,%edx
  8011fa:	83 c1 01             	add    $0x1,%ecx
  8011fd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801200:	39 c2                	cmp    %eax,%edx
  801202:	74 09                	je     80120d <strlcpy+0x32>
  801204:	0f b6 19             	movzbl (%ecx),%ebx
  801207:	84 db                	test   %bl,%bl
  801209:	75 ec                	jne    8011f7 <strlcpy+0x1c>
  80120b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80120d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801210:	29 f0                	sub    %esi,%eax
}
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80121f:	eb 06                	jmp    801227 <strcmp+0x11>
		p++, q++;
  801221:	83 c1 01             	add    $0x1,%ecx
  801224:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801227:	0f b6 01             	movzbl (%ecx),%eax
  80122a:	84 c0                	test   %al,%al
  80122c:	74 04                	je     801232 <strcmp+0x1c>
  80122e:	3a 02                	cmp    (%edx),%al
  801230:	74 ef                	je     801221 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801232:	0f b6 c0             	movzbl %al,%eax
  801235:	0f b6 12             	movzbl (%edx),%edx
  801238:	29 d0                	sub    %edx,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	53                   	push   %ebx
  801240:	8b 45 08             	mov    0x8(%ebp),%eax
  801243:	8b 55 0c             	mov    0xc(%ebp),%edx
  801246:	89 c3                	mov    %eax,%ebx
  801248:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80124b:	eb 06                	jmp    801253 <strncmp+0x17>
		n--, p++, q++;
  80124d:	83 c0 01             	add    $0x1,%eax
  801250:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801253:	39 d8                	cmp    %ebx,%eax
  801255:	74 15                	je     80126c <strncmp+0x30>
  801257:	0f b6 08             	movzbl (%eax),%ecx
  80125a:	84 c9                	test   %cl,%cl
  80125c:	74 04                	je     801262 <strncmp+0x26>
  80125e:	3a 0a                	cmp    (%edx),%cl
  801260:	74 eb                	je     80124d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801262:	0f b6 00             	movzbl (%eax),%eax
  801265:	0f b6 12             	movzbl (%edx),%edx
  801268:	29 d0                	sub    %edx,%eax
  80126a:	eb 05                	jmp    801271 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801271:	5b                   	pop    %ebx
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	8b 45 08             	mov    0x8(%ebp),%eax
  80127a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80127e:	eb 07                	jmp    801287 <strchr+0x13>
		if (*s == c)
  801280:	38 ca                	cmp    %cl,%dl
  801282:	74 0f                	je     801293 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801284:	83 c0 01             	add    $0x1,%eax
  801287:	0f b6 10             	movzbl (%eax),%edx
  80128a:	84 d2                	test   %dl,%dl
  80128c:	75 f2                	jne    801280 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	8b 45 08             	mov    0x8(%ebp),%eax
  80129b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80129f:	eb 03                	jmp    8012a4 <strfind+0xf>
  8012a1:	83 c0 01             	add    $0x1,%eax
  8012a4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012a7:	84 d2                	test   %dl,%dl
  8012a9:	74 04                	je     8012af <strfind+0x1a>
  8012ab:	38 ca                	cmp    %cl,%dl
  8012ad:	75 f2                	jne    8012a1 <strfind+0xc>
			break;
	return (char *) s;
}
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012bd:	85 c9                	test   %ecx,%ecx
  8012bf:	74 36                	je     8012f7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012c7:	75 28                	jne    8012f1 <memset+0x40>
  8012c9:	f6 c1 03             	test   $0x3,%cl
  8012cc:	75 23                	jne    8012f1 <memset+0x40>
		c &= 0xFF;
  8012ce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012d2:	89 d3                	mov    %edx,%ebx
  8012d4:	c1 e3 08             	shl    $0x8,%ebx
  8012d7:	89 d6                	mov    %edx,%esi
  8012d9:	c1 e6 18             	shl    $0x18,%esi
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	c1 e0 10             	shl    $0x10,%eax
  8012e1:	09 f0                	or     %esi,%eax
  8012e3:	09 c2                	or     %eax,%edx
  8012e5:	89 d0                	mov    %edx,%eax
  8012e7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8012e9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8012ec:	fc                   	cld    
  8012ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8012ef:	eb 06                	jmp    8012f7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f4:	fc                   	cld    
  8012f5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012f7:	89 f8                	mov    %edi,%eax
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	8b 75 0c             	mov    0xc(%ebp),%esi
  801309:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80130c:	39 c6                	cmp    %eax,%esi
  80130e:	73 35                	jae    801345 <memmove+0x47>
  801310:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801313:	39 d0                	cmp    %edx,%eax
  801315:	73 2e                	jae    801345 <memmove+0x47>
		s += n;
		d += n;
  801317:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80131e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801324:	75 13                	jne    801339 <memmove+0x3b>
  801326:	f6 c1 03             	test   $0x3,%cl
  801329:	75 0e                	jne    801339 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80132b:	83 ef 04             	sub    $0x4,%edi
  80132e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801331:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801334:	fd                   	std    
  801335:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801337:	eb 09                	jmp    801342 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801339:	83 ef 01             	sub    $0x1,%edi
  80133c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80133f:	fd                   	std    
  801340:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801342:	fc                   	cld    
  801343:	eb 1d                	jmp    801362 <memmove+0x64>
  801345:	89 f2                	mov    %esi,%edx
  801347:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801349:	f6 c2 03             	test   $0x3,%dl
  80134c:	75 0f                	jne    80135d <memmove+0x5f>
  80134e:	f6 c1 03             	test   $0x3,%cl
  801351:	75 0a                	jne    80135d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801353:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801356:	89 c7                	mov    %eax,%edi
  801358:	fc                   	cld    
  801359:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80135b:	eb 05                	jmp    801362 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80135d:	89 c7                	mov    %eax,%edi
  80135f:	fc                   	cld    
  801360:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801369:	ff 75 10             	pushl  0x10(%ebp)
  80136c:	ff 75 0c             	pushl  0xc(%ebp)
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 87 ff ff ff       	call   8012fe <memmove>
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	8b 55 0c             	mov    0xc(%ebp),%edx
  801384:	89 c6                	mov    %eax,%esi
  801386:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801389:	eb 1a                	jmp    8013a5 <memcmp+0x2c>
		if (*s1 != *s2)
  80138b:	0f b6 08             	movzbl (%eax),%ecx
  80138e:	0f b6 1a             	movzbl (%edx),%ebx
  801391:	38 d9                	cmp    %bl,%cl
  801393:	74 0a                	je     80139f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801395:	0f b6 c1             	movzbl %cl,%eax
  801398:	0f b6 db             	movzbl %bl,%ebx
  80139b:	29 d8                	sub    %ebx,%eax
  80139d:	eb 0f                	jmp    8013ae <memcmp+0x35>
		s1++, s2++;
  80139f:	83 c0 01             	add    $0x1,%eax
  8013a2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a5:	39 f0                	cmp    %esi,%eax
  8013a7:	75 e2                	jne    80138b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8013c0:	eb 07                	jmp    8013c9 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013c2:	38 08                	cmp    %cl,(%eax)
  8013c4:	74 07                	je     8013cd <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c6:	83 c0 01             	add    $0x1,%eax
  8013c9:	39 d0                	cmp    %edx,%eax
  8013cb:	72 f5                	jb     8013c2 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013db:	eb 03                	jmp    8013e0 <strtol+0x11>
		s++;
  8013dd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e0:	0f b6 01             	movzbl (%ecx),%eax
  8013e3:	3c 09                	cmp    $0x9,%al
  8013e5:	74 f6                	je     8013dd <strtol+0xe>
  8013e7:	3c 20                	cmp    $0x20,%al
  8013e9:	74 f2                	je     8013dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013eb:	3c 2b                	cmp    $0x2b,%al
  8013ed:	75 0a                	jne    8013f9 <strtol+0x2a>
		s++;
  8013ef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f7:	eb 10                	jmp    801409 <strtol+0x3a>
  8013f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013fe:	3c 2d                	cmp    $0x2d,%al
  801400:	75 07                	jne    801409 <strtol+0x3a>
		s++, neg = 1;
  801402:	8d 49 01             	lea    0x1(%ecx),%ecx
  801405:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801409:	85 db                	test   %ebx,%ebx
  80140b:	0f 94 c0             	sete   %al
  80140e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801414:	75 19                	jne    80142f <strtol+0x60>
  801416:	80 39 30             	cmpb   $0x30,(%ecx)
  801419:	75 14                	jne    80142f <strtol+0x60>
  80141b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80141f:	0f 85 82 00 00 00    	jne    8014a7 <strtol+0xd8>
		s += 2, base = 16;
  801425:	83 c1 02             	add    $0x2,%ecx
  801428:	bb 10 00 00 00       	mov    $0x10,%ebx
  80142d:	eb 16                	jmp    801445 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80142f:	84 c0                	test   %al,%al
  801431:	74 12                	je     801445 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801433:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801438:	80 39 30             	cmpb   $0x30,(%ecx)
  80143b:	75 08                	jne    801445 <strtol+0x76>
		s++, base = 8;
  80143d:	83 c1 01             	add    $0x1,%ecx
  801440:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
  80144a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80144d:	0f b6 11             	movzbl (%ecx),%edx
  801450:	8d 72 d0             	lea    -0x30(%edx),%esi
  801453:	89 f3                	mov    %esi,%ebx
  801455:	80 fb 09             	cmp    $0x9,%bl
  801458:	77 08                	ja     801462 <strtol+0x93>
			dig = *s - '0';
  80145a:	0f be d2             	movsbl %dl,%edx
  80145d:	83 ea 30             	sub    $0x30,%edx
  801460:	eb 22                	jmp    801484 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801462:	8d 72 9f             	lea    -0x61(%edx),%esi
  801465:	89 f3                	mov    %esi,%ebx
  801467:	80 fb 19             	cmp    $0x19,%bl
  80146a:	77 08                	ja     801474 <strtol+0xa5>
			dig = *s - 'a' + 10;
  80146c:	0f be d2             	movsbl %dl,%edx
  80146f:	83 ea 57             	sub    $0x57,%edx
  801472:	eb 10                	jmp    801484 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801474:	8d 72 bf             	lea    -0x41(%edx),%esi
  801477:	89 f3                	mov    %esi,%ebx
  801479:	80 fb 19             	cmp    $0x19,%bl
  80147c:	77 16                	ja     801494 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80147e:	0f be d2             	movsbl %dl,%edx
  801481:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801484:	3b 55 10             	cmp    0x10(%ebp),%edx
  801487:	7d 0f                	jge    801498 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801489:	83 c1 01             	add    $0x1,%ecx
  80148c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801490:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801492:	eb b9                	jmp    80144d <strtol+0x7e>
  801494:	89 c2                	mov    %eax,%edx
  801496:	eb 02                	jmp    80149a <strtol+0xcb>
  801498:	89 c2                	mov    %eax,%edx

	if (endptr)
  80149a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80149e:	74 0d                	je     8014ad <strtol+0xde>
		*endptr = (char *) s;
  8014a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a3:	89 0e                	mov    %ecx,(%esi)
  8014a5:	eb 06                	jmp    8014ad <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014a7:	84 c0                	test   %al,%al
  8014a9:	75 92                	jne    80143d <strtol+0x6e>
  8014ab:	eb 98                	jmp    801445 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014ad:	f7 da                	neg    %edx
  8014af:	85 ff                	test   %edi,%edi
  8014b1:	0f 45 c2             	cmovne %edx,%eax
}
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	57                   	push   %edi
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	89 c7                	mov    %eax,%edi
  8014ce:	89 c6                	mov    %eax,%esi
  8014d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014d2:	5b                   	pop    %ebx
  8014d3:	5e                   	pop    %esi
  8014d4:	5f                   	pop    %edi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	57                   	push   %edi
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 d3                	mov    %edx,%ebx
  8014eb:	89 d7                	mov    %edx,%edi
  8014ed:	89 d6                	mov    %edx,%esi
  8014ef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5f                   	pop    %edi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801504:	b8 03 00 00 00       	mov    $0x3,%eax
  801509:	8b 55 08             	mov    0x8(%ebp),%edx
  80150c:	89 cb                	mov    %ecx,%ebx
  80150e:	89 cf                	mov    %ecx,%edi
  801510:	89 ce                	mov    %ecx,%esi
  801512:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801514:	85 c0                	test   %eax,%eax
  801516:	7e 17                	jle    80152f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	50                   	push   %eax
  80151c:	6a 03                	push   $0x3
  80151e:	68 6f 3d 80 00       	push   $0x803d6f
  801523:	6a 22                	push   $0x22
  801525:	68 8c 3d 80 00       	push   $0x803d8c
  80152a:	e8 ea f4 ff ff       	call   800a19 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80152f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	57                   	push   %edi
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 02 00 00 00       	mov    $0x2,%eax
  801547:	89 d1                	mov    %edx,%ecx
  801549:	89 d3                	mov    %edx,%ebx
  80154b:	89 d7                	mov    %edx,%edi
  80154d:	89 d6                	mov    %edx,%esi
  80154f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <sys_yield>:

void
sys_yield(void)
{      
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80155c:	ba 00 00 00 00       	mov    $0x0,%edx
  801561:	b8 0b 00 00 00       	mov    $0xb,%eax
  801566:	89 d1                	mov    %edx,%ecx
  801568:	89 d3                	mov    %edx,%ebx
  80156a:	89 d7                	mov    %edx,%edi
  80156c:	89 d6                	mov    %edx,%esi
  80156e:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5f                   	pop    %edi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	57                   	push   %edi
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80157e:	be 00 00 00 00       	mov    $0x0,%esi
  801583:	b8 04 00 00 00       	mov    $0x4,%eax
  801588:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158b:	8b 55 08             	mov    0x8(%ebp),%edx
  80158e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801591:	89 f7                	mov    %esi,%edi
  801593:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801595:	85 c0                	test   %eax,%eax
  801597:	7e 17                	jle    8015b0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801599:	83 ec 0c             	sub    $0xc,%esp
  80159c:	50                   	push   %eax
  80159d:	6a 04                	push   $0x4
  80159f:	68 6f 3d 80 00       	push   $0x803d6f
  8015a4:	6a 22                	push   $0x22
  8015a6:	68 8c 3d 80 00       	push   $0x803d8c
  8015ab:	e8 69 f4 ff ff       	call   800a19 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5e                   	pop    %esi
  8015b5:	5f                   	pop    %edi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8015c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015d2:	8b 75 18             	mov    0x18(%ebp),%esi
  8015d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	7e 17                	jle    8015f2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	50                   	push   %eax
  8015df:	6a 05                	push   $0x5
  8015e1:	68 6f 3d 80 00       	push   $0x803d6f
  8015e6:	6a 22                	push   $0x22
  8015e8:	68 8c 3d 80 00       	push   $0x803d8c
  8015ed:	e8 27 f4 ff ff       	call   800a19 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5e                   	pop    %esi
  8015f7:	5f                   	pop    %edi
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    

008015fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	57                   	push   %edi
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801603:	bb 00 00 00 00       	mov    $0x0,%ebx
  801608:	b8 06 00 00 00       	mov    $0x6,%eax
  80160d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801610:	8b 55 08             	mov    0x8(%ebp),%edx
  801613:	89 df                	mov    %ebx,%edi
  801615:	89 de                	mov    %ebx,%esi
  801617:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801619:	85 c0                	test   %eax,%eax
  80161b:	7e 17                	jle    801634 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	50                   	push   %eax
  801621:	6a 06                	push   $0x6
  801623:	68 6f 3d 80 00       	push   $0x803d6f
  801628:	6a 22                	push   $0x22
  80162a:	68 8c 3d 80 00       	push   $0x803d8c
  80162f:	e8 e5 f3 ff ff       	call   800a19 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801637:	5b                   	pop    %ebx
  801638:	5e                   	pop    %esi
  801639:	5f                   	pop    %edi
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	57                   	push   %edi
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801645:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164a:	b8 08 00 00 00       	mov    $0x8,%eax
  80164f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801652:	8b 55 08             	mov    0x8(%ebp),%edx
  801655:	89 df                	mov    %ebx,%edi
  801657:	89 de                	mov    %ebx,%esi
  801659:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	7e 17                	jle    801676 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	50                   	push   %eax
  801663:	6a 08                	push   $0x8
  801665:	68 6f 3d 80 00       	push   $0x803d6f
  80166a:	6a 22                	push   $0x22
  80166c:	68 8c 3d 80 00       	push   $0x803d8c
  801671:	e8 a3 f3 ff ff       	call   800a19 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  801676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801687:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168c:	b8 09 00 00 00       	mov    $0x9,%eax
  801691:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801694:	8b 55 08             	mov    0x8(%ebp),%edx
  801697:	89 df                	mov    %ebx,%edi
  801699:	89 de                	mov    %ebx,%esi
  80169b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	7e 17                	jle    8016b8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	50                   	push   %eax
  8016a5:	6a 09                	push   $0x9
  8016a7:	68 6f 3d 80 00       	push   $0x803d6f
  8016ac:	6a 22                	push   $0x22
  8016ae:	68 8c 3d 80 00       	push   $0x803d8c
  8016b3:	e8 61 f3 ff ff       	call   800a19 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8016c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d9:	89 df                	mov    %ebx,%edi
  8016db:	89 de                	mov    %ebx,%esi
  8016dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	7e 17                	jle    8016fa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	50                   	push   %eax
  8016e7:	6a 0a                	push   $0xa
  8016e9:	68 6f 3d 80 00       	push   $0x803d6f
  8016ee:	6a 22                	push   $0x22
  8016f0:	68 8c 3d 80 00       	push   $0x803d8c
  8016f5:	e8 1f f3 ff ff       	call   800a19 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801708:	be 00 00 00 00       	mov    $0x0,%esi
  80170d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801715:	8b 55 08             	mov    0x8(%ebp),%edx
  801718:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80171b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80171e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5f                   	pop    %edi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	57                   	push   %edi
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80172e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801733:	b8 0d 00 00 00       	mov    $0xd,%eax
  801738:	8b 55 08             	mov    0x8(%ebp),%edx
  80173b:	89 cb                	mov    %ecx,%ebx
  80173d:	89 cf                	mov    %ecx,%edi
  80173f:	89 ce                	mov    %ecx,%esi
  801741:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801743:	85 c0                	test   %eax,%eax
  801745:	7e 17                	jle    80175e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801747:	83 ec 0c             	sub    $0xc,%esp
  80174a:	50                   	push   %eax
  80174b:	6a 0d                	push   $0xd
  80174d:	68 6f 3d 80 00       	push   $0x803d6f
  801752:	6a 22                	push   $0x22
  801754:	68 8c 3d 80 00       	push   $0x803d8c
  801759:	e8 bb f2 ff ff       	call   800a19 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80175e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5f                   	pop    %edi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	57                   	push   %edi
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	b8 0e 00 00 00       	mov    $0xe,%eax
  801776:	89 d1                	mov    %edx,%ecx
  801778:	89 d3                	mov    %edx,%ebx
  80177a:	89 d7                	mov    %edx,%edi
  80177c:	89 d6                	mov    %edx,%esi
  80177e:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <sys_transmit>:

int
sys_transmit(void *addr)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	57                   	push   %edi
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80178e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801793:	b8 0f 00 00 00       	mov    $0xf,%eax
  801798:	8b 55 08             	mov    0x8(%ebp),%edx
  80179b:	89 cb                	mov    %ecx,%ebx
  80179d:	89 cf                	mov    %ecx,%edi
  80179f:	89 ce                	mov    %ecx,%esi
  8017a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	7e 17                	jle    8017be <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	50                   	push   %eax
  8017ab:	6a 0f                	push   $0xf
  8017ad:	68 6f 3d 80 00       	push   $0x803d6f
  8017b2:	6a 22                	push   $0x22
  8017b4:	68 8c 3d 80 00       	push   $0x803d8c
  8017b9:	e8 5b f2 ff ff       	call   800a19 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8017be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c1:	5b                   	pop    %ebx
  8017c2:	5e                   	pop    %esi
  8017c3:	5f                   	pop    %edi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <sys_recv>:

int
sys_recv(void *addr)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	57                   	push   %edi
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8017cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8017d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8017dc:	89 cb                	mov    %ecx,%ebx
  8017de:	89 cf                	mov    %ecx,%edi
  8017e0:	89 ce                	mov    %ecx,%esi
  8017e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	7e 17                	jle    8017ff <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017e8:	83 ec 0c             	sub    $0xc,%esp
  8017eb:	50                   	push   %eax
  8017ec:	6a 10                	push   $0x10
  8017ee:	68 6f 3d 80 00       	push   $0x803d6f
  8017f3:	6a 22                	push   $0x22
  8017f5:	68 8c 3d 80 00       	push   $0x803d8c
  8017fa:	e8 1a f2 ff ff       	call   800a19 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8017ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5f                   	pop    %edi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801811:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801813:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801817:	74 2e                	je     801847 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801819:	89 c2                	mov    %eax,%edx
  80181b:	c1 ea 16             	shr    $0x16,%edx
  80181e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801825:	f6 c2 01             	test   $0x1,%dl
  801828:	74 1d                	je     801847 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	c1 ea 0c             	shr    $0xc,%edx
  80182f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801836:	f6 c1 01             	test   $0x1,%cl
  801839:	74 0c                	je     801847 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  80183b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801842:	f6 c6 08             	test   $0x8,%dh
  801845:	75 14                	jne    80185b <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	68 9c 3d 80 00       	push   $0x803d9c
  80184f:	6a 21                	push   $0x21
  801851:	68 2f 3e 80 00       	push   $0x803e2f
  801856:	e8 be f1 ff ff       	call   800a19 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  80185b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801860:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	6a 07                	push   $0x7
  801867:	68 00 f0 7f 00       	push   $0x7ff000
  80186c:	6a 00                	push   $0x0
  80186e:	e8 02 fd ff ff       	call   801575 <sys_page_alloc>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	79 14                	jns    80188e <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	68 3a 3e 80 00       	push   $0x803e3a
  801882:	6a 2b                	push   $0x2b
  801884:	68 2f 3e 80 00       	push   $0x803e2f
  801889:	e8 8b f1 ff ff       	call   800a19 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	68 00 10 00 00       	push   $0x1000
  801896:	53                   	push   %ebx
  801897:	68 00 f0 7f 00       	push   $0x7ff000
  80189c:	e8 5d fa ff ff       	call   8012fe <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  8018a1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018a8:	53                   	push   %ebx
  8018a9:	6a 00                	push   $0x0
  8018ab:	68 00 f0 7f 00       	push   $0x7ff000
  8018b0:	6a 00                	push   $0x0
  8018b2:	e8 01 fd ff ff       	call   8015b8 <sys_page_map>
  8018b7:	83 c4 20             	add    $0x20,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	79 14                	jns    8018d2 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  8018be:	83 ec 04             	sub    $0x4,%esp
  8018c1:	68 50 3e 80 00       	push   $0x803e50
  8018c6:	6a 2e                	push   $0x2e
  8018c8:	68 2f 3e 80 00       	push   $0x803e2f
  8018cd:	e8 47 f1 ff ff       	call   800a19 <_panic>
        sys_page_unmap(0, PFTEMP); 
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	68 00 f0 7f 00       	push   $0x7ff000
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 19 fd ff ff       	call   8015fa <sys_page_unmap>
  8018e1:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  8018e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	57                   	push   %edi
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  8018f2:	68 07 18 80 00       	push   $0x801807
  8018f7:	e8 82 1a 00 00       	call   80337e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018fc:	b8 07 00 00 00       	mov    $0x7,%eax
  801901:	cd 30                	int    $0x30
  801903:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	85 c0                	test   %eax,%eax
  80190b:	79 12                	jns    80191f <fork+0x36>
		panic("sys_exofork: %e", forkid);
  80190d:	50                   	push   %eax
  80190e:	68 64 3e 80 00       	push   $0x803e64
  801913:	6a 6d                	push   $0x6d
  801915:	68 2f 3e 80 00       	push   $0x803e2f
  80191a:	e8 fa f0 ff ff       	call   800a19 <_panic>
  80191f:	89 c7                	mov    %eax,%edi
  801921:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801926:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80192a:	75 21                	jne    80194d <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  80192c:	e8 06 fc ff ff       	call   801537 <sys_getenvid>
  801931:	25 ff 03 00 00       	and    $0x3ff,%eax
  801936:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801939:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80193e:	a3 48 64 80 00       	mov    %eax,0x806448
		return 0;
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
  801948:	e9 9c 01 00 00       	jmp    801ae9 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  80194d:	89 d8                	mov    %ebx,%eax
  80194f:	c1 e8 16             	shr    $0x16,%eax
  801952:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801959:	a8 01                	test   $0x1,%al
  80195b:	0f 84 f3 00 00 00    	je     801a54 <fork+0x16b>
  801961:	89 d8                	mov    %ebx,%eax
  801963:	c1 e8 0c             	shr    $0xc,%eax
  801966:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80196d:	f6 c2 01             	test   $0x1,%dl
  801970:	0f 84 de 00 00 00    	je     801a54 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801976:	89 c6                	mov    %eax,%esi
  801978:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  80197b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801982:	f6 c6 04             	test   $0x4,%dh
  801985:	74 37                	je     8019be <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801987:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	25 07 0e 00 00       	and    $0xe07,%eax
  801996:	50                   	push   %eax
  801997:	56                   	push   %esi
  801998:	57                   	push   %edi
  801999:	56                   	push   %esi
  80199a:	6a 00                	push   $0x0
  80199c:	e8 17 fc ff ff       	call   8015b8 <sys_page_map>
  8019a1:	83 c4 20             	add    $0x20,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	0f 89 a8 00 00 00    	jns    801a54 <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  8019ac:	50                   	push   %eax
  8019ad:	68 c0 3d 80 00       	push   $0x803dc0
  8019b2:	6a 49                	push   $0x49
  8019b4:	68 2f 3e 80 00       	push   $0x803e2f
  8019b9:	e8 5b f0 ff ff       	call   800a19 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  8019be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019c5:	f6 c6 08             	test   $0x8,%dh
  8019c8:	75 0b                	jne    8019d5 <fork+0xec>
  8019ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019d1:	a8 02                	test   $0x2,%al
  8019d3:	74 57                	je     801a2c <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	68 05 08 00 00       	push   $0x805
  8019dd:	56                   	push   %esi
  8019de:	57                   	push   %edi
  8019df:	56                   	push   %esi
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 d1 fb ff ff       	call   8015b8 <sys_page_map>
  8019e7:	83 c4 20             	add    $0x20,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	79 12                	jns    801a00 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8019ee:	50                   	push   %eax
  8019ef:	68 c0 3d 80 00       	push   $0x803dc0
  8019f4:	6a 4c                	push   $0x4c
  8019f6:	68 2f 3e 80 00       	push   $0x803e2f
  8019fb:	e8 19 f0 ff ff       	call   800a19 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801a00:	83 ec 0c             	sub    $0xc,%esp
  801a03:	68 05 08 00 00       	push   $0x805
  801a08:	56                   	push   %esi
  801a09:	6a 00                	push   $0x0
  801a0b:	56                   	push   %esi
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 a5 fb ff ff       	call   8015b8 <sys_page_map>
  801a13:	83 c4 20             	add    $0x20,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	79 3a                	jns    801a54 <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801a1a:	50                   	push   %eax
  801a1b:	68 e4 3d 80 00       	push   $0x803de4
  801a20:	6a 4e                	push   $0x4e
  801a22:	68 2f 3e 80 00       	push   $0x803e2f
  801a27:	e8 ed ef ff ff       	call   800a19 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	6a 05                	push   $0x5
  801a31:	56                   	push   %esi
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	6a 00                	push   $0x0
  801a36:	e8 7d fb ff ff       	call   8015b8 <sys_page_map>
  801a3b:	83 c4 20             	add    $0x20,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	79 12                	jns    801a54 <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801a42:	50                   	push   %eax
  801a43:	68 0c 3e 80 00       	push   $0x803e0c
  801a48:	6a 50                	push   $0x50
  801a4a:	68 2f 3e 80 00       	push   $0x803e2f
  801a4f:	e8 c5 ef ff ff       	call   800a19 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  801a54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a5a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a60:	0f 85 e7 fe ff ff    	jne    80194d <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	6a 07                	push   $0x7
  801a6b:	68 00 f0 bf ee       	push   $0xeebff000
  801a70:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a73:	e8 fd fa ff ff       	call   801575 <sys_page_alloc>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	79 14                	jns    801a93 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  801a7f:	83 ec 04             	sub    $0x4,%esp
  801a82:	68 74 3e 80 00       	push   $0x803e74
  801a87:	6a 76                	push   $0x76
  801a89:	68 2f 3e 80 00       	push   $0x803e2f
  801a8e:	e8 86 ef ff ff       	call   800a19 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	68 ed 33 80 00       	push   $0x8033ed
  801a9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9e:	e8 1d fc ff ff       	call   8016c0 <sys_env_set_pgfault_upcall>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	79 14                	jns    801abe <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801aaa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aad:	68 8e 3e 80 00       	push   $0x803e8e
  801ab2:	6a 79                	push   $0x79
  801ab4:	68 2f 3e 80 00       	push   $0x803e2f
  801ab9:	e8 5b ef ff ff       	call   800a19 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	6a 02                	push   $0x2
  801ac3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac6:	e8 71 fb ff ff       	call   80163c <sys_env_set_status>
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	79 14                	jns    801ae6 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801ad2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad5:	68 ab 3e 80 00       	push   $0x803eab
  801ada:	6a 7b                	push   $0x7b
  801adc:	68 2f 3e 80 00       	push   $0x803e2f
  801ae1:	e8 33 ef ff ff       	call   800a19 <_panic>
        return forkid;
  801ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <sfork>:

// Challenge!
int
sfork(void)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801af7:	68 c2 3e 80 00       	push   $0x803ec2
  801afc:	68 83 00 00 00       	push   $0x83
  801b01:	68 2f 3e 80 00       	push   $0x803e2f
  801b06:	e8 0e ef ff ff       	call   800a19 <_panic>

00801b0b <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  801b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b14:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b17:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b19:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b1c:	83 3a 01             	cmpl   $0x1,(%edx)
  801b1f:	7e 09                	jle    801b2a <argstart+0x1f>
  801b21:	ba 21 38 80 00       	mov    $0x803821,%edx
  801b26:	85 c9                	test   %ecx,%ecx
  801b28:	75 05                	jne    801b2f <argstart+0x24>
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b32:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <argnext>:

int
argnext(struct Argstate *args)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b45:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b4c:	8b 43 08             	mov    0x8(%ebx),%eax
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	74 6f                	je     801bc2 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b53:	80 38 00             	cmpb   $0x0,(%eax)
  801b56:	75 4e                	jne    801ba6 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b58:	8b 0b                	mov    (%ebx),%ecx
  801b5a:	83 39 01             	cmpl   $0x1,(%ecx)
  801b5d:	74 55                	je     801bb4 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b5f:	8b 53 04             	mov    0x4(%ebx),%edx
  801b62:	8b 42 04             	mov    0x4(%edx),%eax
  801b65:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b68:	75 4a                	jne    801bb4 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b6a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b6e:	74 44                	je     801bb4 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b70:	83 c0 01             	add    $0x1,%eax
  801b73:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	8b 01                	mov    (%ecx),%eax
  801b7b:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b82:	50                   	push   %eax
  801b83:	8d 42 08             	lea    0x8(%edx),%eax
  801b86:	50                   	push   %eax
  801b87:	83 c2 04             	add    $0x4,%edx
  801b8a:	52                   	push   %edx
  801b8b:	e8 6e f7 ff ff       	call   8012fe <memmove>
		(*args->argc)--;
  801b90:	8b 03                	mov    (%ebx),%eax
  801b92:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b95:	8b 43 08             	mov    0x8(%ebx),%eax
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b9e:	75 06                	jne    801ba6 <argnext+0x6b>
  801ba0:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ba4:	74 0e                	je     801bb4 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801ba6:	8b 53 08             	mov    0x8(%ebx),%edx
  801ba9:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801bac:	83 c2 01             	add    $0x1,%edx
  801baf:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801bb2:	eb 13                	jmp    801bc7 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801bb4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bc0:	eb 05                	jmp    801bc7 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 04             	sub    $0x4,%esp
  801bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bd6:	8b 43 08             	mov    0x8(%ebx),%eax
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	74 58                	je     801c35 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801bdd:	80 38 00             	cmpb   $0x0,(%eax)
  801be0:	74 0c                	je     801bee <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801be2:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801be5:	c7 43 08 21 38 80 00 	movl   $0x803821,0x8(%ebx)
  801bec:	eb 42                	jmp    801c30 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801bee:	8b 13                	mov    (%ebx),%edx
  801bf0:	83 3a 01             	cmpl   $0x1,(%edx)
  801bf3:	7e 2d                	jle    801c22 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bf5:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf8:	8b 48 04             	mov    0x4(%eax),%ecx
  801bfb:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	8b 12                	mov    (%edx),%edx
  801c03:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c0a:	52                   	push   %edx
  801c0b:	8d 50 08             	lea    0x8(%eax),%edx
  801c0e:	52                   	push   %edx
  801c0f:	83 c0 04             	add    $0x4,%eax
  801c12:	50                   	push   %eax
  801c13:	e8 e6 f6 ff ff       	call   8012fe <memmove>
		(*args->argc)--;
  801c18:	8b 03                	mov    (%ebx),%eax
  801c1a:	83 28 01             	subl   $0x1,(%eax)
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	eb 0e                	jmp    801c30 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801c22:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c29:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c30:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c33:	eb 05                	jmp    801c3a <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c48:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c4b:	89 d0                	mov    %edx,%eax
  801c4d:	85 d2                	test   %edx,%edx
  801c4f:	75 0c                	jne    801c5d <argvalue+0x1e>
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	51                   	push   %ecx
  801c55:	e8 72 ff ff ff       	call   801bcc <argnextvalue>
  801c5a:	83 c4 10             	add    $0x10,%esp
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	05 00 00 00 30       	add    $0x30000000,%eax
  801c6a:	c1 e8 0c             	shr    $0xc,%eax
}
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801c7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c7f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c91:	89 c2                	mov    %eax,%edx
  801c93:	c1 ea 16             	shr    $0x16,%edx
  801c96:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c9d:	f6 c2 01             	test   $0x1,%dl
  801ca0:	74 11                	je     801cb3 <fd_alloc+0x2d>
  801ca2:	89 c2                	mov    %eax,%edx
  801ca4:	c1 ea 0c             	shr    $0xc,%edx
  801ca7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cae:	f6 c2 01             	test   $0x1,%dl
  801cb1:	75 09                	jne    801cbc <fd_alloc+0x36>
			*fd_store = fd;
  801cb3:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	eb 17                	jmp    801cd3 <fd_alloc+0x4d>
  801cbc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801cc1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cc6:	75 c9                	jne    801c91 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cc8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801cce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cdb:	83 f8 1f             	cmp    $0x1f,%eax
  801cde:	77 36                	ja     801d16 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ce0:	c1 e0 0c             	shl    $0xc,%eax
  801ce3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	c1 ea 16             	shr    $0x16,%edx
  801ced:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cf4:	f6 c2 01             	test   $0x1,%dl
  801cf7:	74 24                	je     801d1d <fd_lookup+0x48>
  801cf9:	89 c2                	mov    %eax,%edx
  801cfb:	c1 ea 0c             	shr    $0xc,%edx
  801cfe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d05:	f6 c2 01             	test   $0x1,%dl
  801d08:	74 1a                	je     801d24 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0d:	89 02                	mov    %eax,(%edx)
	return 0;
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d14:	eb 13                	jmp    801d29 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d1b:	eb 0c                	jmp    801d29 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d22:	eb 05                	jmp    801d29 <fd_lookup+0x54>
  801d24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801d34:	ba 00 00 00 00       	mov    $0x0,%edx
  801d39:	eb 13                	jmp    801d4e <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801d3b:	39 08                	cmp    %ecx,(%eax)
  801d3d:	75 0c                	jne    801d4b <dev_lookup+0x20>
			*dev = devtab[i];
  801d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d42:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
  801d49:	eb 36                	jmp    801d81 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d4b:	83 c2 01             	add    $0x1,%edx
  801d4e:	8b 04 95 54 3f 80 00 	mov    0x803f54(,%edx,4),%eax
  801d55:	85 c0                	test   %eax,%eax
  801d57:	75 e2                	jne    801d3b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d59:	a1 48 64 80 00       	mov    0x806448,%eax
  801d5e:	8b 40 48             	mov    0x48(%eax),%eax
  801d61:	83 ec 04             	sub    $0x4,%esp
  801d64:	51                   	push   %ecx
  801d65:	50                   	push   %eax
  801d66:	68 d8 3e 80 00       	push   $0x803ed8
  801d6b:	e8 82 ed ff ff       	call   800af2 <cprintf>
	*dev = 0;
  801d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 10             	sub    $0x10,%esp
  801d8b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d94:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d95:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d9b:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d9e:	50                   	push   %eax
  801d9f:	e8 31 ff ff ff       	call   801cd5 <fd_lookup>
  801da4:	83 c4 08             	add    $0x8,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 05                	js     801db0 <fd_close+0x2d>
	    || fd != fd2)
  801dab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801dae:	74 0c                	je     801dbc <fd_close+0x39>
		return (must_exist ? r : 0);
  801db0:	84 db                	test   %bl,%bl
  801db2:	ba 00 00 00 00       	mov    $0x0,%edx
  801db7:	0f 44 c2             	cmove  %edx,%eax
  801dba:	eb 41                	jmp    801dfd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801dbc:	83 ec 08             	sub    $0x8,%esp
  801dbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	ff 36                	pushl  (%esi)
  801dc5:	e8 61 ff ff ff       	call   801d2b <dev_lookup>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 1a                	js     801ded <fd_close+0x6a>
		if (dev->dev_close)
  801dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	74 0b                	je     801ded <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	56                   	push   %esi
  801de6:	ff d0                	call   *%eax
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ded:	83 ec 08             	sub    $0x8,%esp
  801df0:	56                   	push   %esi
  801df1:	6a 00                	push   $0x0
  801df3:	e8 02 f8 ff ff       	call   8015fa <sys_page_unmap>
	return r;
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	89 d8                	mov    %ebx,%eax
}
  801dfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e00:	5b                   	pop    %ebx
  801e01:	5e                   	pop    %esi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0d:	50                   	push   %eax
  801e0e:	ff 75 08             	pushl  0x8(%ebp)
  801e11:	e8 bf fe ff ff       	call   801cd5 <fd_lookup>
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	83 c4 08             	add    $0x8,%esp
  801e1b:	85 d2                	test   %edx,%edx
  801e1d:	78 10                	js     801e2f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	6a 01                	push   $0x1
  801e24:	ff 75 f4             	pushl  -0xc(%ebp)
  801e27:	e8 57 ff ff ff       	call   801d83 <fd_close>
  801e2c:	83 c4 10             	add    $0x10,%esp
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <close_all>:

void
close_all(void)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	53                   	push   %ebx
  801e35:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e38:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	53                   	push   %ebx
  801e41:	e8 be ff ff ff       	call   801e04 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e46:	83 c3 01             	add    $0x1,%ebx
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	83 fb 20             	cmp    $0x20,%ebx
  801e4f:	75 ec                	jne    801e3d <close_all+0xc>
		close(i);
}
  801e51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	57                   	push   %edi
  801e5a:	56                   	push   %esi
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 2c             	sub    $0x2c,%esp
  801e5f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 67 fe ff ff       	call   801cd5 <fd_lookup>
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	83 c4 08             	add    $0x8,%esp
  801e73:	85 d2                	test   %edx,%edx
  801e75:	0f 88 c1 00 00 00    	js     801f3c <dup+0xe6>
		return r;
	close(newfdnum);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	56                   	push   %esi
  801e7f:	e8 80 ff ff ff       	call   801e04 <close>

	newfd = INDEX2FD(newfdnum);
  801e84:	89 f3                	mov    %esi,%ebx
  801e86:	c1 e3 0c             	shl    $0xc,%ebx
  801e89:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e8f:	83 c4 04             	add    $0x4,%esp
  801e92:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e95:	e8 d5 fd ff ff       	call   801c6f <fd2data>
  801e9a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e9c:	89 1c 24             	mov    %ebx,(%esp)
  801e9f:	e8 cb fd ff ff       	call   801c6f <fd2data>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eaa:	89 f8                	mov    %edi,%eax
  801eac:	c1 e8 16             	shr    $0x16,%eax
  801eaf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801eb6:	a8 01                	test   $0x1,%al
  801eb8:	74 37                	je     801ef1 <dup+0x9b>
  801eba:	89 f8                	mov    %edi,%eax
  801ebc:	c1 e8 0c             	shr    $0xc,%eax
  801ebf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ec6:	f6 c2 01             	test   $0x1,%dl
  801ec9:	74 26                	je     801ef1 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ecb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	25 07 0e 00 00       	and    $0xe07,%eax
  801eda:	50                   	push   %eax
  801edb:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	57                   	push   %edi
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 d0 f6 ff ff       	call   8015b8 <sys_page_map>
  801ee8:	89 c7                	mov    %eax,%edi
  801eea:	83 c4 20             	add    $0x20,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 2e                	js     801f1f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ef1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	c1 e8 0c             	shr    $0xc,%eax
  801ef9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f00:	83 ec 0c             	sub    $0xc,%esp
  801f03:	25 07 0e 00 00       	and    $0xe07,%eax
  801f08:	50                   	push   %eax
  801f09:	53                   	push   %ebx
  801f0a:	6a 00                	push   $0x0
  801f0c:	52                   	push   %edx
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 a4 f6 ff ff       	call   8015b8 <sys_page_map>
  801f14:	89 c7                	mov    %eax,%edi
  801f16:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801f19:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f1b:	85 ff                	test   %edi,%edi
  801f1d:	79 1d                	jns    801f3c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	53                   	push   %ebx
  801f23:	6a 00                	push   $0x0
  801f25:	e8 d0 f6 ff ff       	call   8015fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f2a:	83 c4 08             	add    $0x8,%esp
  801f2d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f30:	6a 00                	push   $0x0
  801f32:	e8 c3 f6 ff ff       	call   8015fa <sys_page_unmap>
	return r;
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	89 f8                	mov    %edi,%eax
}
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 14             	sub    $0x14,%esp
  801f4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	53                   	push   %ebx
  801f53:	e8 7d fd ff ff       	call   801cd5 <fd_lookup>
  801f58:	83 c4 08             	add    $0x8,%esp
  801f5b:	89 c2                	mov    %eax,%edx
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 6d                	js     801fce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6b:	ff 30                	pushl  (%eax)
  801f6d:	e8 b9 fd ff ff       	call   801d2b <dev_lookup>
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 4c                	js     801fc5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f79:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7c:	8b 42 08             	mov    0x8(%edx),%eax
  801f7f:	83 e0 03             	and    $0x3,%eax
  801f82:	83 f8 01             	cmp    $0x1,%eax
  801f85:	75 21                	jne    801fa8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f87:	a1 48 64 80 00       	mov    0x806448,%eax
  801f8c:	8b 40 48             	mov    0x48(%eax),%eax
  801f8f:	83 ec 04             	sub    $0x4,%esp
  801f92:	53                   	push   %ebx
  801f93:	50                   	push   %eax
  801f94:	68 19 3f 80 00       	push   $0x803f19
  801f99:	e8 54 eb ff ff       	call   800af2 <cprintf>
		return -E_INVAL;
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fa6:	eb 26                	jmp    801fce <read+0x8a>
	}
	if (!dev->dev_read)
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	8b 40 08             	mov    0x8(%eax),%eax
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	74 17                	je     801fc9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	ff 75 10             	pushl  0x10(%ebp)
  801fb8:	ff 75 0c             	pushl  0xc(%ebp)
  801fbb:	52                   	push   %edx
  801fbc:	ff d0                	call   *%eax
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	eb 09                	jmp    801fce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	eb 05                	jmp    801fce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fc9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	57                   	push   %edi
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fe9:	eb 21                	jmp    80200c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801feb:	83 ec 04             	sub    $0x4,%esp
  801fee:	89 f0                	mov    %esi,%eax
  801ff0:	29 d8                	sub    %ebx,%eax
  801ff2:	50                   	push   %eax
  801ff3:	89 d8                	mov    %ebx,%eax
  801ff5:	03 45 0c             	add    0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	57                   	push   %edi
  801ffa:	e8 45 ff ff ff       	call   801f44 <read>
		if (m < 0)
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	78 0c                	js     802012 <readn+0x3d>
			return m;
		if (m == 0)
  802006:	85 c0                	test   %eax,%eax
  802008:	74 06                	je     802010 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80200a:	01 c3                	add    %eax,%ebx
  80200c:	39 f3                	cmp    %esi,%ebx
  80200e:	72 db                	jb     801feb <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802010:	89 d8                	mov    %ebx,%eax
}
  802012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5f                   	pop    %edi
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	53                   	push   %ebx
  80201e:	83 ec 14             	sub    $0x14,%esp
  802021:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802024:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	53                   	push   %ebx
  802029:	e8 a7 fc ff ff       	call   801cd5 <fd_lookup>
  80202e:	83 c4 08             	add    $0x8,%esp
  802031:	89 c2                	mov    %eax,%edx
  802033:	85 c0                	test   %eax,%eax
  802035:	78 68                	js     80209f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802037:	83 ec 08             	sub    $0x8,%esp
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802041:	ff 30                	pushl  (%eax)
  802043:	e8 e3 fc ff ff       	call   801d2b <dev_lookup>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 47                	js     802096 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80204f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802052:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802056:	75 21                	jne    802079 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802058:	a1 48 64 80 00       	mov    0x806448,%eax
  80205d:	8b 40 48             	mov    0x48(%eax),%eax
  802060:	83 ec 04             	sub    $0x4,%esp
  802063:	53                   	push   %ebx
  802064:	50                   	push   %eax
  802065:	68 35 3f 80 00       	push   $0x803f35
  80206a:	e8 83 ea ff ff       	call   800af2 <cprintf>
		return -E_INVAL;
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802077:	eb 26                	jmp    80209f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802079:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207c:	8b 52 0c             	mov    0xc(%edx),%edx
  80207f:	85 d2                	test   %edx,%edx
  802081:	74 17                	je     80209a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802083:	83 ec 04             	sub    $0x4,%esp
  802086:	ff 75 10             	pushl  0x10(%ebp)
  802089:	ff 75 0c             	pushl  0xc(%ebp)
  80208c:	50                   	push   %eax
  80208d:	ff d2                	call   *%edx
  80208f:	89 c2                	mov    %eax,%edx
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	eb 09                	jmp    80209f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802096:	89 c2                	mov    %eax,%edx
  802098:	eb 05                	jmp    80209f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80209a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020af:	50                   	push   %eax
  8020b0:	ff 75 08             	pushl  0x8(%ebp)
  8020b3:	e8 1d fc ff ff       	call   801cd5 <fd_lookup>
  8020b8:	83 c4 08             	add    $0x8,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	78 0e                	js     8020cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    

008020cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	53                   	push   %ebx
  8020d3:	83 ec 14             	sub    $0x14,%esp
  8020d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020dc:	50                   	push   %eax
  8020dd:	53                   	push   %ebx
  8020de:	e8 f2 fb ff ff       	call   801cd5 <fd_lookup>
  8020e3:	83 c4 08             	add    $0x8,%esp
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 65                	js     802151 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f2:	50                   	push   %eax
  8020f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f6:	ff 30                	pushl  (%eax)
  8020f8:	e8 2e fc ff ff       	call   801d2b <dev_lookup>
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 c0                	test   %eax,%eax
  802102:	78 44                	js     802148 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802107:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80210b:	75 21                	jne    80212e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80210d:	a1 48 64 80 00       	mov    0x806448,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802112:	8b 40 48             	mov    0x48(%eax),%eax
  802115:	83 ec 04             	sub    $0x4,%esp
  802118:	53                   	push   %ebx
  802119:	50                   	push   %eax
  80211a:	68 f8 3e 80 00       	push   $0x803ef8
  80211f:	e8 ce e9 ff ff       	call   800af2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80212c:	eb 23                	jmp    802151 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80212e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802131:	8b 52 18             	mov    0x18(%edx),%edx
  802134:	85 d2                	test   %edx,%edx
  802136:	74 14                	je     80214c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	ff 75 0c             	pushl  0xc(%ebp)
  80213e:	50                   	push   %eax
  80213f:	ff d2                	call   *%edx
  802141:	89 c2                	mov    %eax,%edx
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	eb 09                	jmp    802151 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802148:	89 c2                	mov    %eax,%edx
  80214a:	eb 05                	jmp    802151 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80214c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802151:	89 d0                	mov    %edx,%eax
  802153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	53                   	push   %ebx
  80215c:	83 ec 14             	sub    $0x14,%esp
  80215f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802162:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802165:	50                   	push   %eax
  802166:	ff 75 08             	pushl  0x8(%ebp)
  802169:	e8 67 fb ff ff       	call   801cd5 <fd_lookup>
  80216e:	83 c4 08             	add    $0x8,%esp
  802171:	89 c2                	mov    %eax,%edx
  802173:	85 c0                	test   %eax,%eax
  802175:	78 58                	js     8021cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802177:	83 ec 08             	sub    $0x8,%esp
  80217a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217d:	50                   	push   %eax
  80217e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802181:	ff 30                	pushl  (%eax)
  802183:	e8 a3 fb ff ff       	call   801d2b <dev_lookup>
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	85 c0                	test   %eax,%eax
  80218d:	78 37                	js     8021c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802196:	74 32                	je     8021ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802198:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80219b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021a2:	00 00 00 
	stat->st_isdir = 0;
  8021a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021ac:	00 00 00 
	stat->st_dev = dev;
  8021af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021b5:	83 ec 08             	sub    $0x8,%esp
  8021b8:	53                   	push   %ebx
  8021b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bc:	ff 50 14             	call   *0x14(%eax)
  8021bf:	89 c2                	mov    %eax,%edx
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	eb 09                	jmp    8021cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	eb 05                	jmp    8021cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    

008021d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021db:	83 ec 08             	sub    $0x8,%esp
  8021de:	6a 00                	push   $0x0
  8021e0:	ff 75 08             	pushl  0x8(%ebp)
  8021e3:	e8 09 02 00 00       	call   8023f1 <open>
  8021e8:	89 c3                	mov    %eax,%ebx
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	85 db                	test   %ebx,%ebx
  8021ef:	78 1b                	js     80220c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021f1:	83 ec 08             	sub    $0x8,%esp
  8021f4:	ff 75 0c             	pushl  0xc(%ebp)
  8021f7:	53                   	push   %ebx
  8021f8:	e8 5b ff ff ff       	call   802158 <fstat>
  8021fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8021ff:	89 1c 24             	mov    %ebx,(%esp)
  802202:	e8 fd fb ff ff       	call   801e04 <close>
	return r;
  802207:	83 c4 10             	add    $0x10,%esp
  80220a:	89 f0                	mov    %esi,%eax
}
  80220c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    

00802213 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	89 c6                	mov    %eax,%esi
  80221a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80221c:	83 3d 40 64 80 00 00 	cmpl   $0x0,0x806440
  802223:	75 12                	jne    802237 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802225:	83 ec 0c             	sub    $0xc,%esp
  802228:	6a 01                	push   $0x1
  80222a:	e8 9f 12 00 00       	call   8034ce <ipc_find_env>
  80222f:	a3 40 64 80 00       	mov    %eax,0x806440
  802234:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802237:	6a 07                	push   $0x7
  802239:	68 00 70 80 00       	push   $0x807000
  80223e:	56                   	push   %esi
  80223f:	ff 35 40 64 80 00    	pushl  0x806440
  802245:	e8 30 12 00 00       	call   80347a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80224a:	83 c4 0c             	add    $0xc,%esp
  80224d:	6a 00                	push   $0x0
  80224f:	53                   	push   %ebx
  802250:	6a 00                	push   $0x0
  802252:	e8 ba 11 00 00       	call   803411 <ipc_recv>
}
  802257:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225a:	5b                   	pop    %ebx
  80225b:	5e                   	pop    %esi
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802264:	8b 45 08             	mov    0x8(%ebp),%eax
  802267:	8b 40 0c             	mov    0xc(%eax),%eax
  80226a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80226f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802272:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802277:	ba 00 00 00 00       	mov    $0x0,%edx
  80227c:	b8 02 00 00 00       	mov    $0x2,%eax
  802281:	e8 8d ff ff ff       	call   802213 <fsipc>
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80228e:	8b 45 08             	mov    0x8(%ebp),%eax
  802291:	8b 40 0c             	mov    0xc(%eax),%eax
  802294:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  802299:	ba 00 00 00 00       	mov    $0x0,%edx
  80229e:	b8 06 00 00 00       	mov    $0x6,%eax
  8022a3:	e8 6b ff ff ff       	call   802213 <fsipc>
}
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	53                   	push   %ebx
  8022ae:	83 ec 04             	sub    $0x4,%esp
  8022b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ba:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8022c9:	e8 45 ff ff ff       	call   802213 <fsipc>
  8022ce:	89 c2                	mov    %eax,%edx
  8022d0:	85 d2                	test   %edx,%edx
  8022d2:	78 2c                	js     802300 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022d4:	83 ec 08             	sub    $0x8,%esp
  8022d7:	68 00 70 80 00       	push   $0x807000
  8022dc:	53                   	push   %ebx
  8022dd:	e8 8a ee ff ff       	call   80116c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022e2:	a1 80 70 80 00       	mov    0x807080,%eax
  8022e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ed:	a1 84 70 80 00       	mov    0x807084,%eax
  8022f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	57                   	push   %edi
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 0c             	sub    $0xc,%esp
  80230e:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  802311:	8b 45 08             	mov    0x8(%ebp),%eax
  802314:	8b 40 0c             	mov    0xc(%eax),%eax
  802317:	a3 00 70 80 00       	mov    %eax,0x807000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80231c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80231f:	eb 3d                	jmp    80235e <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  802321:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  802327:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80232c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80232f:	83 ec 04             	sub    $0x4,%esp
  802332:	57                   	push   %edi
  802333:	53                   	push   %ebx
  802334:	68 08 70 80 00       	push   $0x807008
  802339:	e8 c0 ef ff ff       	call   8012fe <memmove>
                fsipcbuf.write.req_n = tmp; 
  80233e:	89 3d 04 70 80 00    	mov    %edi,0x807004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802344:	ba 00 00 00 00       	mov    $0x0,%edx
  802349:	b8 04 00 00 00       	mov    $0x4,%eax
  80234e:	e8 c0 fe ff ff       	call   802213 <fsipc>
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	85 c0                	test   %eax,%eax
  802358:	78 0d                	js     802367 <devfile_write+0x62>
		        return r;
                n -= tmp;
  80235a:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80235c:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80235e:	85 f6                	test   %esi,%esi
  802360:	75 bf                	jne    802321 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  802362:	89 d8                	mov    %ebx,%eax
  802364:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  802367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5f                   	pop    %edi
  80236d:	5d                   	pop    %ebp
  80236e:	c3                   	ret    

0080236f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802377:	8b 45 08             	mov    0x8(%ebp),%eax
  80237a:	8b 40 0c             	mov    0xc(%eax),%eax
  80237d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802382:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802388:	ba 00 00 00 00       	mov    $0x0,%edx
  80238d:	b8 03 00 00 00       	mov    $0x3,%eax
  802392:	e8 7c fe ff ff       	call   802213 <fsipc>
  802397:	89 c3                	mov    %eax,%ebx
  802399:	85 c0                	test   %eax,%eax
  80239b:	78 4b                	js     8023e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80239d:	39 c6                	cmp    %eax,%esi
  80239f:	73 16                	jae    8023b7 <devfile_read+0x48>
  8023a1:	68 68 3f 80 00       	push   $0x803f68
  8023a6:	68 34 39 80 00       	push   $0x803934
  8023ab:	6a 7c                	push   $0x7c
  8023ad:	68 6f 3f 80 00       	push   $0x803f6f
  8023b2:	e8 62 e6 ff ff       	call   800a19 <_panic>
	assert(r <= PGSIZE);
  8023b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023bc:	7e 16                	jle    8023d4 <devfile_read+0x65>
  8023be:	68 7a 3f 80 00       	push   $0x803f7a
  8023c3:	68 34 39 80 00       	push   $0x803934
  8023c8:	6a 7d                	push   $0x7d
  8023ca:	68 6f 3f 80 00       	push   $0x803f6f
  8023cf:	e8 45 e6 ff ff       	call   800a19 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023d4:	83 ec 04             	sub    $0x4,%esp
  8023d7:	50                   	push   %eax
  8023d8:	68 00 70 80 00       	push   $0x807000
  8023dd:	ff 75 0c             	pushl  0xc(%ebp)
  8023e0:	e8 19 ef ff ff       	call   8012fe <memmove>
	return r;
  8023e5:	83 c4 10             	add    $0x10,%esp
}
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	53                   	push   %ebx
  8023f5:	83 ec 20             	sub    $0x20,%esp
  8023f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8023fb:	53                   	push   %ebx
  8023fc:	e8 32 ed ff ff       	call   801133 <strlen>
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802409:	7f 67                	jg     802472 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80240b:	83 ec 0c             	sub    $0xc,%esp
  80240e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802411:	50                   	push   %eax
  802412:	e8 6f f8 ff ff       	call   801c86 <fd_alloc>
  802417:	83 c4 10             	add    $0x10,%esp
		return r;
  80241a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80241c:	85 c0                	test   %eax,%eax
  80241e:	78 57                	js     802477 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802420:	83 ec 08             	sub    $0x8,%esp
  802423:	53                   	push   %ebx
  802424:	68 00 70 80 00       	push   $0x807000
  802429:	e8 3e ed ff ff       	call   80116c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80242e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802431:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802436:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802439:	b8 01 00 00 00       	mov    $0x1,%eax
  80243e:	e8 d0 fd ff ff       	call   802213 <fsipc>
  802443:	89 c3                	mov    %eax,%ebx
  802445:	83 c4 10             	add    $0x10,%esp
  802448:	85 c0                	test   %eax,%eax
  80244a:	79 14                	jns    802460 <open+0x6f>
		fd_close(fd, 0);
  80244c:	83 ec 08             	sub    $0x8,%esp
  80244f:	6a 00                	push   $0x0
  802451:	ff 75 f4             	pushl  -0xc(%ebp)
  802454:	e8 2a f9 ff ff       	call   801d83 <fd_close>
		return r;
  802459:	83 c4 10             	add    $0x10,%esp
  80245c:	89 da                	mov    %ebx,%edx
  80245e:	eb 17                	jmp    802477 <open+0x86>
	}

	return fd2num(fd);
  802460:	83 ec 0c             	sub    $0xc,%esp
  802463:	ff 75 f4             	pushl  -0xc(%ebp)
  802466:	e8 f4 f7 ff ff       	call   801c5f <fd2num>
  80246b:	89 c2                	mov    %eax,%edx
  80246d:	83 c4 10             	add    $0x10,%esp
  802470:	eb 05                	jmp    802477 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802472:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802477:	89 d0                	mov    %edx,%eax
  802479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802484:	ba 00 00 00 00       	mov    $0x0,%edx
  802489:	b8 08 00 00 00       	mov    $0x8,%eax
  80248e:	e8 80 fd ff ff       	call   802213 <fsipc>
}
  802493:	c9                   	leave  
  802494:	c3                   	ret    

00802495 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802495:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802499:	7e 37                	jle    8024d2 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	53                   	push   %ebx
  80249f:	83 ec 08             	sub    $0x8,%esp
  8024a2:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8024a4:	ff 70 04             	pushl  0x4(%eax)
  8024a7:	8d 40 10             	lea    0x10(%eax),%eax
  8024aa:	50                   	push   %eax
  8024ab:	ff 33                	pushl  (%ebx)
  8024ad:	e8 68 fb ff ff       	call   80201a <write>
		if (result > 0)
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	7e 03                	jle    8024bc <writebuf+0x27>
			b->result += result;
  8024b9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8024bc:	39 43 04             	cmp    %eax,0x4(%ebx)
  8024bf:	74 0d                	je     8024ce <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8024c1:	85 c0                	test   %eax,%eax
  8024c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c8:	0f 4f c2             	cmovg  %edx,%eax
  8024cb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024d1:	c9                   	leave  
  8024d2:	f3 c3                	repz ret 

008024d4 <putch>:

static void
putch(int ch, void *thunk)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 04             	sub    $0x4,%esp
  8024db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024de:	8b 53 04             	mov    0x4(%ebx),%edx
  8024e1:	8d 42 01             	lea    0x1(%edx),%eax
  8024e4:	89 43 04             	mov    %eax,0x4(%ebx)
  8024e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024ea:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024ee:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024f3:	75 0e                	jne    802503 <putch+0x2f>
		writebuf(b);
  8024f5:	89 d8                	mov    %ebx,%eax
  8024f7:	e8 99 ff ff ff       	call   802495 <writebuf>
		b->idx = 0;
  8024fc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802503:	83 c4 04             	add    $0x4,%esp
  802506:	5b                   	pop    %ebx
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    

00802509 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802512:	8b 45 08             	mov    0x8(%ebp),%eax
  802515:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80251b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802522:	00 00 00 
	b.result = 0;
  802525:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80252c:	00 00 00 
	b.error = 1;
  80252f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802536:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802539:	ff 75 10             	pushl  0x10(%ebp)
  80253c:	ff 75 0c             	pushl  0xc(%ebp)
  80253f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802545:	50                   	push   %eax
  802546:	68 d4 24 80 00       	push   $0x8024d4
  80254b:	e8 d4 e6 ff ff       	call   800c24 <vprintfmt>
	if (b.idx > 0)
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80255a:	7e 0b                	jle    802567 <vfprintf+0x5e>
		writebuf(&b);
  80255c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802562:	e8 2e ff ff ff       	call   802495 <writebuf>

	return (b.result ? b.result : b.error);
  802567:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80256d:	85 c0                	test   %eax,%eax
  80256f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802576:	c9                   	leave  
  802577:	c3                   	ret    

00802578 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80257e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802581:	50                   	push   %eax
  802582:	ff 75 0c             	pushl  0xc(%ebp)
  802585:	ff 75 08             	pushl  0x8(%ebp)
  802588:	e8 7c ff ff ff       	call   802509 <vfprintf>
	va_end(ap);

	return cnt;
}
  80258d:	c9                   	leave  
  80258e:	c3                   	ret    

0080258f <printf>:

int
printf(const char *fmt, ...)
{
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802595:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802598:	50                   	push   %eax
  802599:	ff 75 08             	pushl  0x8(%ebp)
  80259c:	6a 01                	push   $0x1
  80259e:	e8 66 ff ff ff       	call   802509 <vfprintf>
	va_end(ap);

	return cnt;
}
  8025a3:	c9                   	leave  
  8025a4:	c3                   	ret    

008025a5 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8025a5:	55                   	push   %ebp
  8025a6:	89 e5                	mov    %esp,%ebp
  8025a8:	57                   	push   %edi
  8025a9:	56                   	push   %esi
  8025aa:	53                   	push   %ebx
  8025ab:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8025b1:	6a 00                	push   $0x0
  8025b3:	ff 75 08             	pushl  0x8(%ebp)
  8025b6:	e8 36 fe ff ff       	call   8023f1 <open>
  8025bb:	89 c7                	mov    %eax,%edi
  8025bd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8025c3:	83 c4 10             	add    $0x10,%esp
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	0f 88 97 04 00 00    	js     802a65 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025ce:	83 ec 04             	sub    $0x4,%esp
  8025d1:	68 00 02 00 00       	push   $0x200
  8025d6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025dc:	50                   	push   %eax
  8025dd:	57                   	push   %edi
  8025de:	e8 f2 f9 ff ff       	call   801fd5 <readn>
  8025e3:	83 c4 10             	add    $0x10,%esp
  8025e6:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025eb:	75 0c                	jne    8025f9 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8025ed:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025f4:	45 4c 46 
  8025f7:	74 33                	je     80262c <spawn+0x87>
		close(fd);
  8025f9:	83 ec 0c             	sub    $0xc,%esp
  8025fc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802602:	e8 fd f7 ff ff       	call   801e04 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802607:	83 c4 0c             	add    $0xc,%esp
  80260a:	68 7f 45 4c 46       	push   $0x464c457f
  80260f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802615:	68 86 3f 80 00       	push   $0x803f86
  80261a:	e8 d3 e4 ff ff       	call   800af2 <cprintf>
		return -E_NOT_EXEC;
  80261f:	83 c4 10             	add    $0x10,%esp
  802622:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  802627:	e9 be 04 00 00       	jmp    802aea <spawn+0x545>
  80262c:	b8 07 00 00 00       	mov    $0x7,%eax
  802631:	cd 30                	int    $0x30
  802633:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802639:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80263f:	85 c0                	test   %eax,%eax
  802641:	0f 88 26 04 00 00    	js     802a6d <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802647:	89 c6                	mov    %eax,%esi
  802649:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80264f:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802652:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802658:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80265e:	b9 11 00 00 00       	mov    $0x11,%ecx
  802663:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802665:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80266b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802671:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802676:	be 00 00 00 00       	mov    $0x0,%esi
  80267b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80267e:	eb 13                	jmp    802693 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802680:	83 ec 0c             	sub    $0xc,%esp
  802683:	50                   	push   %eax
  802684:	e8 aa ea ff ff       	call   801133 <strlen>
  802689:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80268d:	83 c3 01             	add    $0x1,%ebx
  802690:	83 c4 10             	add    $0x10,%esp
  802693:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80269a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80269d:	85 c0                	test   %eax,%eax
  80269f:	75 df                	jne    802680 <spawn+0xdb>
  8026a1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8026a7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8026ad:	bf 00 10 40 00       	mov    $0x401000,%edi
  8026b2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8026b4:	89 fa                	mov    %edi,%edx
  8026b6:	83 e2 fc             	and    $0xfffffffc,%edx
  8026b9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8026c0:	29 c2                	sub    %eax,%edx
  8026c2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8026c8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026cb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026d0:	0f 86 a7 03 00 00    	jbe    802a7d <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026d6:	83 ec 04             	sub    $0x4,%esp
  8026d9:	6a 07                	push   $0x7
  8026db:	68 00 00 40 00       	push   $0x400000
  8026e0:	6a 00                	push   $0x0
  8026e2:	e8 8e ee ff ff       	call   801575 <sys_page_alloc>
  8026e7:	83 c4 10             	add    $0x10,%esp
  8026ea:	85 c0                	test   %eax,%eax
  8026ec:	0f 88 f8 03 00 00    	js     802aea <spawn+0x545>
  8026f2:	be 00 00 00 00       	mov    $0x0,%esi
  8026f7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8026fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802700:	eb 30                	jmp    802732 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802702:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802708:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80270e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802711:	83 ec 08             	sub    $0x8,%esp
  802714:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802717:	57                   	push   %edi
  802718:	e8 4f ea ff ff       	call   80116c <strcpy>
		string_store += strlen(argv[i]) + 1;
  80271d:	83 c4 04             	add    $0x4,%esp
  802720:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802723:	e8 0b ea ff ff       	call   801133 <strlen>
  802728:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80272c:	83 c6 01             	add    $0x1,%esi
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802738:	7f c8                	jg     802702 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80273a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802740:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802746:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80274d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802753:	74 19                	je     80276e <spawn+0x1c9>
  802755:	68 10 40 80 00       	push   $0x804010
  80275a:	68 34 39 80 00       	push   $0x803934
  80275f:	68 f1 00 00 00       	push   $0xf1
  802764:	68 a0 3f 80 00       	push   $0x803fa0
  802769:	e8 ab e2 ff ff       	call   800a19 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80276e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802774:	89 f8                	mov    %edi,%eax
  802776:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80277b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80277e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802784:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802787:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80278d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802793:	83 ec 0c             	sub    $0xc,%esp
  802796:	6a 07                	push   $0x7
  802798:	68 00 d0 bf ee       	push   $0xeebfd000
  80279d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8027a3:	68 00 00 40 00       	push   $0x400000
  8027a8:	6a 00                	push   $0x0
  8027aa:	e8 09 ee ff ff       	call   8015b8 <sys_page_map>
  8027af:	89 c3                	mov    %eax,%ebx
  8027b1:	83 c4 20             	add    $0x20,%esp
  8027b4:	85 c0                	test   %eax,%eax
  8027b6:	0f 88 1a 03 00 00    	js     802ad6 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8027bc:	83 ec 08             	sub    $0x8,%esp
  8027bf:	68 00 00 40 00       	push   $0x400000
  8027c4:	6a 00                	push   $0x0
  8027c6:	e8 2f ee ff ff       	call   8015fa <sys_page_unmap>
  8027cb:	89 c3                	mov    %eax,%ebx
  8027cd:	83 c4 10             	add    $0x10,%esp
  8027d0:	85 c0                	test   %eax,%eax
  8027d2:	0f 88 fe 02 00 00    	js     802ad6 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027d8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027de:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027e5:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027eb:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8027f2:	00 00 00 
  8027f5:	e9 85 01 00 00       	jmp    80297f <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  8027fa:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802800:	83 38 01             	cmpl   $0x1,(%eax)
  802803:	0f 85 68 01 00 00    	jne    802971 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802809:	89 c7                	mov    %eax,%edi
  80280b:	8b 40 18             	mov    0x18(%eax),%eax
  80280e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802814:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802817:	83 f8 01             	cmp    $0x1,%eax
  80281a:	19 c0                	sbb    %eax,%eax
  80281c:	83 e0 fe             	and    $0xfffffffe,%eax
  80281f:	83 c0 07             	add    $0x7,%eax
  802822:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802828:	89 f8                	mov    %edi,%eax
  80282a:	8b 7f 04             	mov    0x4(%edi),%edi
  80282d:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802833:	8b 78 10             	mov    0x10(%eax),%edi
  802836:	8b 48 14             	mov    0x14(%eax),%ecx
  802839:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  80283f:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802842:	89 f0                	mov    %esi,%eax
  802844:	25 ff 0f 00 00       	and    $0xfff,%eax
  802849:	74 10                	je     80285b <spawn+0x2b6>
		va -= i;
  80284b:	29 c6                	sub    %eax,%esi
		memsz += i;
  80284d:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  802853:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802855:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80285b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802860:	e9 fa 00 00 00       	jmp    80295f <spawn+0x3ba>
		if (i >= filesz) {
  802865:	39 fb                	cmp    %edi,%ebx
  802867:	72 27                	jb     802890 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802869:	83 ec 04             	sub    $0x4,%esp
  80286c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802872:	56                   	push   %esi
  802873:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802879:	e8 f7 ec ff ff       	call   801575 <sys_page_alloc>
  80287e:	83 c4 10             	add    $0x10,%esp
  802881:	85 c0                	test   %eax,%eax
  802883:	0f 89 ca 00 00 00    	jns    802953 <spawn+0x3ae>
  802889:	89 c7                	mov    %eax,%edi
  80288b:	e9 fe 01 00 00       	jmp    802a8e <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802890:	83 ec 04             	sub    $0x4,%esp
  802893:	6a 07                	push   $0x7
  802895:	68 00 00 40 00       	push   $0x400000
  80289a:	6a 00                	push   $0x0
  80289c:	e8 d4 ec ff ff       	call   801575 <sys_page_alloc>
  8028a1:	83 c4 10             	add    $0x10,%esp
  8028a4:	85 c0                	test   %eax,%eax
  8028a6:	0f 88 d8 01 00 00    	js     802a84 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8028ac:	83 ec 08             	sub    $0x8,%esp
  8028af:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8028b5:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  8028bb:	50                   	push   %eax
  8028bc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028c2:	e8 df f7 ff ff       	call   8020a6 <seek>
  8028c7:	83 c4 10             	add    $0x10,%esp
  8028ca:	85 c0                	test   %eax,%eax
  8028cc:	0f 88 b6 01 00 00    	js     802a88 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028d2:	83 ec 04             	sub    $0x4,%esp
  8028d5:	89 fa                	mov    %edi,%edx
  8028d7:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  8028dd:	89 d0                	mov    %edx,%eax
  8028df:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8028e5:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8028ea:	0f 47 c1             	cmova  %ecx,%eax
  8028ed:	50                   	push   %eax
  8028ee:	68 00 00 40 00       	push   $0x400000
  8028f3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028f9:	e8 d7 f6 ff ff       	call   801fd5 <readn>
  8028fe:	83 c4 10             	add    $0x10,%esp
  802901:	85 c0                	test   %eax,%eax
  802903:	0f 88 83 01 00 00    	js     802a8c <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802909:	83 ec 0c             	sub    $0xc,%esp
  80290c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802912:	56                   	push   %esi
  802913:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802919:	68 00 00 40 00       	push   $0x400000
  80291e:	6a 00                	push   $0x0
  802920:	e8 93 ec ff ff       	call   8015b8 <sys_page_map>
  802925:	83 c4 20             	add    $0x20,%esp
  802928:	85 c0                	test   %eax,%eax
  80292a:	79 15                	jns    802941 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  80292c:	50                   	push   %eax
  80292d:	68 ac 3f 80 00       	push   $0x803fac
  802932:	68 24 01 00 00       	push   $0x124
  802937:	68 a0 3f 80 00       	push   $0x803fa0
  80293c:	e8 d8 e0 ff ff       	call   800a19 <_panic>
			sys_page_unmap(0, UTEMP);
  802941:	83 ec 08             	sub    $0x8,%esp
  802944:	68 00 00 40 00       	push   $0x400000
  802949:	6a 00                	push   $0x0
  80294b:	e8 aa ec ff ff       	call   8015fa <sys_page_unmap>
  802950:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802953:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802959:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80295f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802965:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80296b:	0f 82 f4 fe ff ff    	jb     802865 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802971:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802978:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80297f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802986:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80298c:	0f 8c 68 fe ff ff    	jl     8027fa <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802992:	83 ec 0c             	sub    $0xc,%esp
  802995:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80299b:	e8 64 f4 ff ff       	call   801e04 <close>
  8029a0:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  8029a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029a8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8029ae:	89 d8                	mov    %ebx,%eax
  8029b0:	c1 e8 16             	shr    $0x16,%eax
  8029b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029ba:	a8 01                	test   $0x1,%al
  8029bc:	74 53                	je     802a11 <spawn+0x46c>
  8029be:	89 d8                	mov    %ebx,%eax
  8029c0:	c1 e8 0c             	shr    $0xc,%eax
  8029c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029ca:	f6 c2 01             	test   $0x1,%dl
  8029cd:	74 42                	je     802a11 <spawn+0x46c>
  8029cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029d6:	f6 c6 04             	test   $0x4,%dh
  8029d9:	74 36                	je     802a11 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  8029db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029e2:	83 ec 0c             	sub    $0xc,%esp
  8029e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8029ea:	50                   	push   %eax
  8029eb:	53                   	push   %ebx
  8029ec:	56                   	push   %esi
  8029ed:	53                   	push   %ebx
  8029ee:	6a 00                	push   $0x0
  8029f0:	e8 c3 eb ff ff       	call   8015b8 <sys_page_map>
                        if (r < 0) return r;
  8029f5:	83 c4 20             	add    $0x20,%esp
  8029f8:	85 c0                	test   %eax,%eax
  8029fa:	79 15                	jns    802a11 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8029fc:	50                   	push   %eax
  8029fd:	68 c9 3f 80 00       	push   $0x803fc9
  802a02:	68 82 00 00 00       	push   $0x82
  802a07:	68 a0 3f 80 00       	push   $0x803fa0
  802a0c:	e8 08 e0 ff ff       	call   800a19 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  802a11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a17:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802a1d:	75 8f                	jne    8029ae <spawn+0x409>
  802a1f:	e9 8d 00 00 00       	jmp    802ab1 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  802a24:	50                   	push   %eax
  802a25:	68 df 3f 80 00       	push   $0x803fdf
  802a2a:	68 85 00 00 00       	push   $0x85
  802a2f:	68 a0 3f 80 00       	push   $0x803fa0
  802a34:	e8 e0 df ff ff       	call   800a19 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a39:	83 ec 08             	sub    $0x8,%esp
  802a3c:	6a 02                	push   $0x2
  802a3e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a44:	e8 f3 eb ff ff       	call   80163c <sys_env_set_status>
  802a49:	83 c4 10             	add    $0x10,%esp
  802a4c:	85 c0                	test   %eax,%eax
  802a4e:	79 25                	jns    802a75 <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  802a50:	50                   	push   %eax
  802a51:	68 f9 3f 80 00       	push   $0x803ff9
  802a56:	68 88 00 00 00       	push   $0x88
  802a5b:	68 a0 3f 80 00       	push   $0x803fa0
  802a60:	e8 b4 df ff ff       	call   800a19 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a65:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802a6b:	eb 7d                	jmp    802aea <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802a6d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802a73:	eb 75                	jmp    802aea <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a75:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802a7b:	eb 6d                	jmp    802aea <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a7d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802a82:	eb 66                	jmp    802aea <spawn+0x545>
  802a84:	89 c7                	mov    %eax,%edi
  802a86:	eb 06                	jmp    802a8e <spawn+0x4e9>
  802a88:	89 c7                	mov    %eax,%edi
  802a8a:	eb 02                	jmp    802a8e <spawn+0x4e9>
  802a8c:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a8e:	83 ec 0c             	sub    $0xc,%esp
  802a91:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a97:	e8 5a ea ff ff       	call   8014f6 <sys_env_destroy>
	close(fd);
  802a9c:	83 c4 04             	add    $0x4,%esp
  802a9f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802aa5:	e8 5a f3 ff ff       	call   801e04 <close>
	return r;
  802aaa:	83 c4 10             	add    $0x10,%esp
  802aad:	89 f8                	mov    %edi,%eax
  802aaf:	eb 39                	jmp    802aea <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  802ab1:	83 ec 08             	sub    $0x8,%esp
  802ab4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802aba:	50                   	push   %eax
  802abb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802ac1:	e8 b8 eb ff ff       	call   80167e <sys_env_set_trapframe>
  802ac6:	83 c4 10             	add    $0x10,%esp
  802ac9:	85 c0                	test   %eax,%eax
  802acb:	0f 89 68 ff ff ff    	jns    802a39 <spawn+0x494>
  802ad1:	e9 4e ff ff ff       	jmp    802a24 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802ad6:	83 ec 08             	sub    $0x8,%esp
  802ad9:	68 00 00 40 00       	push   $0x400000
  802ade:	6a 00                	push   $0x0
  802ae0:	e8 15 eb ff ff       	call   8015fa <sys_page_unmap>
  802ae5:	83 c4 10             	add    $0x10,%esp
  802ae8:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aed:	5b                   	pop    %ebx
  802aee:	5e                   	pop    %esi
  802aef:	5f                   	pop    %edi
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    

00802af2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802af2:	55                   	push   %ebp
  802af3:	89 e5                	mov    %esp,%ebp
  802af5:	56                   	push   %esi
  802af6:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802af7:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802afa:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aff:	eb 03                	jmp    802b04 <spawnl+0x12>
		argc++;
  802b01:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b04:	83 c2 04             	add    $0x4,%edx
  802b07:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802b0b:	75 f4                	jne    802b01 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802b0d:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802b14:	83 e2 f0             	and    $0xfffffff0,%edx
  802b17:	29 d4                	sub    %edx,%esp
  802b19:	8d 54 24 03          	lea    0x3(%esp),%edx
  802b1d:	c1 ea 02             	shr    $0x2,%edx
  802b20:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802b27:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b2c:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b33:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b3a:	00 
  802b3b:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  802b42:	eb 0a                	jmp    802b4e <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802b44:	83 c0 01             	add    $0x1,%eax
  802b47:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b4b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b4e:	39 d0                	cmp    %edx,%eax
  802b50:	75 f2                	jne    802b44 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b52:	83 ec 08             	sub    $0x8,%esp
  802b55:	56                   	push   %esi
  802b56:	ff 75 08             	pushl  0x8(%ebp)
  802b59:	e8 47 fa ff ff       	call   8025a5 <spawn>
}
  802b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b61:	5b                   	pop    %ebx
  802b62:	5e                   	pop    %esi
  802b63:	5d                   	pop    %ebp
  802b64:	c3                   	ret    

00802b65 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802b65:	55                   	push   %ebp
  802b66:	89 e5                	mov    %esp,%ebp
  802b68:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802b6b:	68 36 40 80 00       	push   $0x804036
  802b70:	ff 75 0c             	pushl  0xc(%ebp)
  802b73:	e8 f4 e5 ff ff       	call   80116c <strcpy>
	return 0;
}
  802b78:	b8 00 00 00 00       	mov    $0x0,%eax
  802b7d:	c9                   	leave  
  802b7e:	c3                   	ret    

00802b7f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802b7f:	55                   	push   %ebp
  802b80:	89 e5                	mov    %esp,%ebp
  802b82:	53                   	push   %ebx
  802b83:	83 ec 10             	sub    $0x10,%esp
  802b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802b89:	53                   	push   %ebx
  802b8a:	e8 77 09 00 00       	call   803506 <pageref>
  802b8f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802b92:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802b97:	83 f8 01             	cmp    $0x1,%eax
  802b9a:	75 10                	jne    802bac <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802b9c:	83 ec 0c             	sub    $0xc,%esp
  802b9f:	ff 73 0c             	pushl  0xc(%ebx)
  802ba2:	e8 ca 02 00 00       	call   802e71 <nsipc_close>
  802ba7:	89 c2                	mov    %eax,%edx
  802ba9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802bac:	89 d0                	mov    %edx,%eax
  802bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bb1:	c9                   	leave  
  802bb2:	c3                   	ret    

00802bb3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802bb3:	55                   	push   %ebp
  802bb4:	89 e5                	mov    %esp,%ebp
  802bb6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802bb9:	6a 00                	push   $0x0
  802bbb:	ff 75 10             	pushl  0x10(%ebp)
  802bbe:	ff 75 0c             	pushl  0xc(%ebp)
  802bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  802bc4:	ff 70 0c             	pushl  0xc(%eax)
  802bc7:	e8 82 03 00 00       	call   802f4e <nsipc_send>
}
  802bcc:	c9                   	leave  
  802bcd:	c3                   	ret    

00802bce <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802bce:	55                   	push   %ebp
  802bcf:	89 e5                	mov    %esp,%ebp
  802bd1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802bd4:	6a 00                	push   $0x0
  802bd6:	ff 75 10             	pushl  0x10(%ebp)
  802bd9:	ff 75 0c             	pushl  0xc(%ebp)
  802bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  802bdf:	ff 70 0c             	pushl  0xc(%eax)
  802be2:	e8 fb 02 00 00       	call   802ee2 <nsipc_recv>
}
  802be7:	c9                   	leave  
  802be8:	c3                   	ret    

00802be9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802be9:	55                   	push   %ebp
  802bea:	89 e5                	mov    %esp,%ebp
  802bec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802bef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802bf2:	52                   	push   %edx
  802bf3:	50                   	push   %eax
  802bf4:	e8 dc f0 ff ff       	call   801cd5 <fd_lookup>
  802bf9:	83 c4 10             	add    $0x10,%esp
  802bfc:	85 c0                	test   %eax,%eax
  802bfe:	78 17                	js     802c17 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c03:	8b 0d 3c 50 80 00    	mov    0x80503c,%ecx
  802c09:	39 08                	cmp    %ecx,(%eax)
  802c0b:	75 05                	jne    802c12 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802c0d:	8b 40 0c             	mov    0xc(%eax),%eax
  802c10:	eb 05                	jmp    802c17 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802c12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802c17:	c9                   	leave  
  802c18:	c3                   	ret    

00802c19 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802c19:	55                   	push   %ebp
  802c1a:	89 e5                	mov    %esp,%ebp
  802c1c:	56                   	push   %esi
  802c1d:	53                   	push   %ebx
  802c1e:	83 ec 1c             	sub    $0x1c,%esp
  802c21:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802c23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c26:	50                   	push   %eax
  802c27:	e8 5a f0 ff ff       	call   801c86 <fd_alloc>
  802c2c:	89 c3                	mov    %eax,%ebx
  802c2e:	83 c4 10             	add    $0x10,%esp
  802c31:	85 c0                	test   %eax,%eax
  802c33:	78 1b                	js     802c50 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802c35:	83 ec 04             	sub    $0x4,%esp
  802c38:	68 07 04 00 00       	push   $0x407
  802c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  802c40:	6a 00                	push   $0x0
  802c42:	e8 2e e9 ff ff       	call   801575 <sys_page_alloc>
  802c47:	89 c3                	mov    %eax,%ebx
  802c49:	83 c4 10             	add    $0x10,%esp
  802c4c:	85 c0                	test   %eax,%eax
  802c4e:	79 10                	jns    802c60 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802c50:	83 ec 0c             	sub    $0xc,%esp
  802c53:	56                   	push   %esi
  802c54:	e8 18 02 00 00       	call   802e71 <nsipc_close>
		return r;
  802c59:	83 c4 10             	add    $0x10,%esp
  802c5c:	89 d8                	mov    %ebx,%eax
  802c5e:	eb 24                	jmp    802c84 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802c60:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c69:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c6e:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802c75:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  802c78:	83 ec 0c             	sub    $0xc,%esp
  802c7b:	52                   	push   %edx
  802c7c:	e8 de ef ff ff       	call   801c5f <fd2num>
  802c81:	83 c4 10             	add    $0x10,%esp
}
  802c84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c87:	5b                   	pop    %ebx
  802c88:	5e                   	pop    %esi
  802c89:	5d                   	pop    %ebp
  802c8a:	c3                   	ret    

00802c8b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802c8b:	55                   	push   %ebp
  802c8c:	89 e5                	mov    %esp,%ebp
  802c8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c91:	8b 45 08             	mov    0x8(%ebp),%eax
  802c94:	e8 50 ff ff ff       	call   802be9 <fd2sockid>
		return r;
  802c99:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c9b:	85 c0                	test   %eax,%eax
  802c9d:	78 1f                	js     802cbe <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c9f:	83 ec 04             	sub    $0x4,%esp
  802ca2:	ff 75 10             	pushl  0x10(%ebp)
  802ca5:	ff 75 0c             	pushl  0xc(%ebp)
  802ca8:	50                   	push   %eax
  802ca9:	e8 1c 01 00 00       	call   802dca <nsipc_accept>
  802cae:	83 c4 10             	add    $0x10,%esp
		return r;
  802cb1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802cb3:	85 c0                	test   %eax,%eax
  802cb5:	78 07                	js     802cbe <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802cb7:	e8 5d ff ff ff       	call   802c19 <alloc_sockfd>
  802cbc:	89 c1                	mov    %eax,%ecx
}
  802cbe:	89 c8                	mov    %ecx,%eax
  802cc0:	c9                   	leave  
  802cc1:	c3                   	ret    

00802cc2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802cc2:	55                   	push   %ebp
  802cc3:	89 e5                	mov    %esp,%ebp
  802cc5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  802ccb:	e8 19 ff ff ff       	call   802be9 <fd2sockid>
  802cd0:	89 c2                	mov    %eax,%edx
  802cd2:	85 d2                	test   %edx,%edx
  802cd4:	78 12                	js     802ce8 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  802cd6:	83 ec 04             	sub    $0x4,%esp
  802cd9:	ff 75 10             	pushl  0x10(%ebp)
  802cdc:	ff 75 0c             	pushl  0xc(%ebp)
  802cdf:	52                   	push   %edx
  802ce0:	e8 35 01 00 00       	call   802e1a <nsipc_bind>
  802ce5:	83 c4 10             	add    $0x10,%esp
}
  802ce8:	c9                   	leave  
  802ce9:	c3                   	ret    

00802cea <shutdown>:

int
shutdown(int s, int how)
{
  802cea:	55                   	push   %ebp
  802ceb:	89 e5                	mov    %esp,%ebp
  802ced:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  802cf3:	e8 f1 fe ff ff       	call   802be9 <fd2sockid>
  802cf8:	89 c2                	mov    %eax,%edx
  802cfa:	85 d2                	test   %edx,%edx
  802cfc:	78 0f                	js     802d0d <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802cfe:	83 ec 08             	sub    $0x8,%esp
  802d01:	ff 75 0c             	pushl  0xc(%ebp)
  802d04:	52                   	push   %edx
  802d05:	e8 45 01 00 00       	call   802e4f <nsipc_shutdown>
  802d0a:	83 c4 10             	add    $0x10,%esp
}
  802d0d:	c9                   	leave  
  802d0e:	c3                   	ret    

00802d0f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802d0f:	55                   	push   %ebp
  802d10:	89 e5                	mov    %esp,%ebp
  802d12:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802d15:	8b 45 08             	mov    0x8(%ebp),%eax
  802d18:	e8 cc fe ff ff       	call   802be9 <fd2sockid>
  802d1d:	89 c2                	mov    %eax,%edx
  802d1f:	85 d2                	test   %edx,%edx
  802d21:	78 12                	js     802d35 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  802d23:	83 ec 04             	sub    $0x4,%esp
  802d26:	ff 75 10             	pushl  0x10(%ebp)
  802d29:	ff 75 0c             	pushl  0xc(%ebp)
  802d2c:	52                   	push   %edx
  802d2d:	e8 59 01 00 00       	call   802e8b <nsipc_connect>
  802d32:	83 c4 10             	add    $0x10,%esp
}
  802d35:	c9                   	leave  
  802d36:	c3                   	ret    

00802d37 <listen>:

int
listen(int s, int backlog)
{
  802d37:	55                   	push   %ebp
  802d38:	89 e5                	mov    %esp,%ebp
  802d3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  802d40:	e8 a4 fe ff ff       	call   802be9 <fd2sockid>
  802d45:	89 c2                	mov    %eax,%edx
  802d47:	85 d2                	test   %edx,%edx
  802d49:	78 0f                	js     802d5a <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802d4b:	83 ec 08             	sub    $0x8,%esp
  802d4e:	ff 75 0c             	pushl  0xc(%ebp)
  802d51:	52                   	push   %edx
  802d52:	e8 69 01 00 00       	call   802ec0 <nsipc_listen>
  802d57:	83 c4 10             	add    $0x10,%esp
}
  802d5a:	c9                   	leave  
  802d5b:	c3                   	ret    

00802d5c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802d5c:	55                   	push   %ebp
  802d5d:	89 e5                	mov    %esp,%ebp
  802d5f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802d62:	ff 75 10             	pushl  0x10(%ebp)
  802d65:	ff 75 0c             	pushl  0xc(%ebp)
  802d68:	ff 75 08             	pushl  0x8(%ebp)
  802d6b:	e8 3c 02 00 00       	call   802fac <nsipc_socket>
  802d70:	89 c2                	mov    %eax,%edx
  802d72:	83 c4 10             	add    $0x10,%esp
  802d75:	85 d2                	test   %edx,%edx
  802d77:	78 05                	js     802d7e <socket+0x22>
		return r;
	return alloc_sockfd(r);
  802d79:	e8 9b fe ff ff       	call   802c19 <alloc_sockfd>
}
  802d7e:	c9                   	leave  
  802d7f:	c3                   	ret    

00802d80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802d80:	55                   	push   %ebp
  802d81:	89 e5                	mov    %esp,%ebp
  802d83:	53                   	push   %ebx
  802d84:	83 ec 04             	sub    $0x4,%esp
  802d87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802d89:	83 3d 44 64 80 00 00 	cmpl   $0x0,0x806444
  802d90:	75 12                	jne    802da4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802d92:	83 ec 0c             	sub    $0xc,%esp
  802d95:	6a 02                	push   $0x2
  802d97:	e8 32 07 00 00       	call   8034ce <ipc_find_env>
  802d9c:	a3 44 64 80 00       	mov    %eax,0x806444
  802da1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802da4:	6a 07                	push   $0x7
  802da6:	68 00 80 80 00       	push   $0x808000
  802dab:	53                   	push   %ebx
  802dac:	ff 35 44 64 80 00    	pushl  0x806444
  802db2:	e8 c3 06 00 00       	call   80347a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802db7:	83 c4 0c             	add    $0xc,%esp
  802dba:	6a 00                	push   $0x0
  802dbc:	6a 00                	push   $0x0
  802dbe:	6a 00                	push   $0x0
  802dc0:	e8 4c 06 00 00       	call   803411 <ipc_recv>
}
  802dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dc8:	c9                   	leave  
  802dc9:	c3                   	ret    

00802dca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802dca:	55                   	push   %ebp
  802dcb:	89 e5                	mov    %esp,%ebp
  802dcd:	56                   	push   %esi
  802dce:	53                   	push   %ebx
  802dcf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  802dd5:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802dda:	8b 06                	mov    (%esi),%eax
  802ddc:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802de1:	b8 01 00 00 00       	mov    $0x1,%eax
  802de6:	e8 95 ff ff ff       	call   802d80 <nsipc>
  802deb:	89 c3                	mov    %eax,%ebx
  802ded:	85 c0                	test   %eax,%eax
  802def:	78 20                	js     802e11 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802df1:	83 ec 04             	sub    $0x4,%esp
  802df4:	ff 35 10 80 80 00    	pushl  0x808010
  802dfa:	68 00 80 80 00       	push   $0x808000
  802dff:	ff 75 0c             	pushl  0xc(%ebp)
  802e02:	e8 f7 e4 ff ff       	call   8012fe <memmove>
		*addrlen = ret->ret_addrlen;
  802e07:	a1 10 80 80 00       	mov    0x808010,%eax
  802e0c:	89 06                	mov    %eax,(%esi)
  802e0e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802e11:	89 d8                	mov    %ebx,%eax
  802e13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e16:	5b                   	pop    %ebx
  802e17:	5e                   	pop    %esi
  802e18:	5d                   	pop    %ebp
  802e19:	c3                   	ret    

00802e1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802e1a:	55                   	push   %ebp
  802e1b:	89 e5                	mov    %esp,%ebp
  802e1d:	53                   	push   %ebx
  802e1e:	83 ec 08             	sub    $0x8,%esp
  802e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802e24:	8b 45 08             	mov    0x8(%ebp),%eax
  802e27:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802e2c:	53                   	push   %ebx
  802e2d:	ff 75 0c             	pushl  0xc(%ebp)
  802e30:	68 04 80 80 00       	push   $0x808004
  802e35:	e8 c4 e4 ff ff       	call   8012fe <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802e3a:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  802e40:	b8 02 00 00 00       	mov    $0x2,%eax
  802e45:	e8 36 ff ff ff       	call   802d80 <nsipc>
}
  802e4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e4d:	c9                   	leave  
  802e4e:	c3                   	ret    

00802e4f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802e4f:	55                   	push   %ebp
  802e50:	89 e5                	mov    %esp,%ebp
  802e52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802e55:	8b 45 08             	mov    0x8(%ebp),%eax
  802e58:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e60:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802e65:	b8 03 00 00 00       	mov    $0x3,%eax
  802e6a:	e8 11 ff ff ff       	call   802d80 <nsipc>
}
  802e6f:	c9                   	leave  
  802e70:	c3                   	ret    

00802e71 <nsipc_close>:

int
nsipc_close(int s)
{
  802e71:	55                   	push   %ebp
  802e72:	89 e5                	mov    %esp,%ebp
  802e74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802e77:	8b 45 08             	mov    0x8(%ebp),%eax
  802e7a:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802e7f:	b8 04 00 00 00       	mov    $0x4,%eax
  802e84:	e8 f7 fe ff ff       	call   802d80 <nsipc>
}
  802e89:	c9                   	leave  
  802e8a:	c3                   	ret    

00802e8b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802e8b:	55                   	push   %ebp
  802e8c:	89 e5                	mov    %esp,%ebp
  802e8e:	53                   	push   %ebx
  802e8f:	83 ec 08             	sub    $0x8,%esp
  802e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802e95:	8b 45 08             	mov    0x8(%ebp),%eax
  802e98:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802e9d:	53                   	push   %ebx
  802e9e:	ff 75 0c             	pushl  0xc(%ebp)
  802ea1:	68 04 80 80 00       	push   $0x808004
  802ea6:	e8 53 e4 ff ff       	call   8012fe <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802eab:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802eb1:	b8 05 00 00 00       	mov    $0x5,%eax
  802eb6:	e8 c5 fe ff ff       	call   802d80 <nsipc>
}
  802ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ebe:	c9                   	leave  
  802ebf:	c3                   	ret    

00802ec0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802ec0:	55                   	push   %ebp
  802ec1:	89 e5                	mov    %esp,%ebp
  802ec3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  802ec9:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802ece:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ed1:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802ed6:	b8 06 00 00 00       	mov    $0x6,%eax
  802edb:	e8 a0 fe ff ff       	call   802d80 <nsipc>
}
  802ee0:	c9                   	leave  
  802ee1:	c3                   	ret    

00802ee2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802ee2:	55                   	push   %ebp
  802ee3:	89 e5                	mov    %esp,%ebp
  802ee5:	56                   	push   %esi
  802ee6:	53                   	push   %ebx
  802ee7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802eea:	8b 45 08             	mov    0x8(%ebp),%eax
  802eed:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802ef2:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  802ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  802efb:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802f00:	b8 07 00 00 00       	mov    $0x7,%eax
  802f05:	e8 76 fe ff ff       	call   802d80 <nsipc>
  802f0a:	89 c3                	mov    %eax,%ebx
  802f0c:	85 c0                	test   %eax,%eax
  802f0e:	78 35                	js     802f45 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802f10:	39 f0                	cmp    %esi,%eax
  802f12:	7f 07                	jg     802f1b <nsipc_recv+0x39>
  802f14:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802f19:	7e 16                	jle    802f31 <nsipc_recv+0x4f>
  802f1b:	68 42 40 80 00       	push   $0x804042
  802f20:	68 34 39 80 00       	push   $0x803934
  802f25:	6a 62                	push   $0x62
  802f27:	68 57 40 80 00       	push   $0x804057
  802f2c:	e8 e8 da ff ff       	call   800a19 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802f31:	83 ec 04             	sub    $0x4,%esp
  802f34:	50                   	push   %eax
  802f35:	68 00 80 80 00       	push   $0x808000
  802f3a:	ff 75 0c             	pushl  0xc(%ebp)
  802f3d:	e8 bc e3 ff ff       	call   8012fe <memmove>
  802f42:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802f45:	89 d8                	mov    %ebx,%eax
  802f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f4a:	5b                   	pop    %ebx
  802f4b:	5e                   	pop    %esi
  802f4c:	5d                   	pop    %ebp
  802f4d:	c3                   	ret    

00802f4e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802f4e:	55                   	push   %ebp
  802f4f:	89 e5                	mov    %esp,%ebp
  802f51:	53                   	push   %ebx
  802f52:	83 ec 04             	sub    $0x4,%esp
  802f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802f58:	8b 45 08             	mov    0x8(%ebp),%eax
  802f5b:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802f60:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802f66:	7e 16                	jle    802f7e <nsipc_send+0x30>
  802f68:	68 63 40 80 00       	push   $0x804063
  802f6d:	68 34 39 80 00       	push   $0x803934
  802f72:	6a 6d                	push   $0x6d
  802f74:	68 57 40 80 00       	push   $0x804057
  802f79:	e8 9b da ff ff       	call   800a19 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802f7e:	83 ec 04             	sub    $0x4,%esp
  802f81:	53                   	push   %ebx
  802f82:	ff 75 0c             	pushl  0xc(%ebp)
  802f85:	68 0c 80 80 00       	push   $0x80800c
  802f8a:	e8 6f e3 ff ff       	call   8012fe <memmove>
	nsipcbuf.send.req_size = size;
  802f8f:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802f95:	8b 45 14             	mov    0x14(%ebp),%eax
  802f98:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802f9d:	b8 08 00 00 00       	mov    $0x8,%eax
  802fa2:	e8 d9 fd ff ff       	call   802d80 <nsipc>
}
  802fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802faa:	c9                   	leave  
  802fab:	c3                   	ret    

00802fac <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802fac:	55                   	push   %ebp
  802fad:	89 e5                	mov    %esp,%ebp
  802faf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb5:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802fba:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fbd:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802fc2:	8b 45 10             	mov    0x10(%ebp),%eax
  802fc5:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802fca:	b8 09 00 00 00       	mov    $0x9,%eax
  802fcf:	e8 ac fd ff ff       	call   802d80 <nsipc>
}
  802fd4:	c9                   	leave  
  802fd5:	c3                   	ret    

00802fd6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fd6:	55                   	push   %ebp
  802fd7:	89 e5                	mov    %esp,%ebp
  802fd9:	56                   	push   %esi
  802fda:	53                   	push   %ebx
  802fdb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fde:	83 ec 0c             	sub    $0xc,%esp
  802fe1:	ff 75 08             	pushl  0x8(%ebp)
  802fe4:	e8 86 ec ff ff       	call   801c6f <fd2data>
  802fe9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802feb:	83 c4 08             	add    $0x8,%esp
  802fee:	68 6f 40 80 00       	push   $0x80406f
  802ff3:	53                   	push   %ebx
  802ff4:	e8 73 e1 ff ff       	call   80116c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ff9:	8b 56 04             	mov    0x4(%esi),%edx
  802ffc:	89 d0                	mov    %edx,%eax
  802ffe:	2b 06                	sub    (%esi),%eax
  803000:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803006:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80300d:	00 00 00 
	stat->st_dev = &devpipe;
  803010:	c7 83 88 00 00 00 58 	movl   $0x805058,0x88(%ebx)
  803017:	50 80 00 
	return 0;
}
  80301a:	b8 00 00 00 00       	mov    $0x0,%eax
  80301f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803022:	5b                   	pop    %ebx
  803023:	5e                   	pop    %esi
  803024:	5d                   	pop    %ebp
  803025:	c3                   	ret    

00803026 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803026:	55                   	push   %ebp
  803027:	89 e5                	mov    %esp,%ebp
  803029:	53                   	push   %ebx
  80302a:	83 ec 0c             	sub    $0xc,%esp
  80302d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803030:	53                   	push   %ebx
  803031:	6a 00                	push   $0x0
  803033:	e8 c2 e5 ff ff       	call   8015fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803038:	89 1c 24             	mov    %ebx,(%esp)
  80303b:	e8 2f ec ff ff       	call   801c6f <fd2data>
  803040:	83 c4 08             	add    $0x8,%esp
  803043:	50                   	push   %eax
  803044:	6a 00                	push   $0x0
  803046:	e8 af e5 ff ff       	call   8015fa <sys_page_unmap>
}
  80304b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80304e:	c9                   	leave  
  80304f:	c3                   	ret    

00803050 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803050:	55                   	push   %ebp
  803051:	89 e5                	mov    %esp,%ebp
  803053:	57                   	push   %edi
  803054:	56                   	push   %esi
  803055:	53                   	push   %ebx
  803056:	83 ec 1c             	sub    $0x1c,%esp
  803059:	89 c6                	mov    %eax,%esi
  80305b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80305e:	a1 48 64 80 00       	mov    0x806448,%eax
  803063:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803066:	83 ec 0c             	sub    $0xc,%esp
  803069:	56                   	push   %esi
  80306a:	e8 97 04 00 00       	call   803506 <pageref>
  80306f:	89 c7                	mov    %eax,%edi
  803071:	83 c4 04             	add    $0x4,%esp
  803074:	ff 75 e4             	pushl  -0x1c(%ebp)
  803077:	e8 8a 04 00 00       	call   803506 <pageref>
  80307c:	83 c4 10             	add    $0x10,%esp
  80307f:	39 c7                	cmp    %eax,%edi
  803081:	0f 94 c2             	sete   %dl
  803084:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  803087:	8b 0d 48 64 80 00    	mov    0x806448,%ecx
  80308d:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  803090:	39 fb                	cmp    %edi,%ebx
  803092:	74 19                	je     8030ad <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  803094:	84 d2                	test   %dl,%dl
  803096:	74 c6                	je     80305e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803098:	8b 51 58             	mov    0x58(%ecx),%edx
  80309b:	50                   	push   %eax
  80309c:	52                   	push   %edx
  80309d:	53                   	push   %ebx
  80309e:	68 76 40 80 00       	push   $0x804076
  8030a3:	e8 4a da ff ff       	call   800af2 <cprintf>
  8030a8:	83 c4 10             	add    $0x10,%esp
  8030ab:	eb b1                	jmp    80305e <_pipeisclosed+0xe>
	}
}
  8030ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030b0:	5b                   	pop    %ebx
  8030b1:	5e                   	pop    %esi
  8030b2:	5f                   	pop    %edi
  8030b3:	5d                   	pop    %ebp
  8030b4:	c3                   	ret    

008030b5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030b5:	55                   	push   %ebp
  8030b6:	89 e5                	mov    %esp,%ebp
  8030b8:	57                   	push   %edi
  8030b9:	56                   	push   %esi
  8030ba:	53                   	push   %ebx
  8030bb:	83 ec 28             	sub    $0x28,%esp
  8030be:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030c1:	56                   	push   %esi
  8030c2:	e8 a8 eb ff ff       	call   801c6f <fd2data>
  8030c7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030c9:	83 c4 10             	add    $0x10,%esp
  8030cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8030d1:	eb 4b                	jmp    80311e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030d3:	89 da                	mov    %ebx,%edx
  8030d5:	89 f0                	mov    %esi,%eax
  8030d7:	e8 74 ff ff ff       	call   803050 <_pipeisclosed>
  8030dc:	85 c0                	test   %eax,%eax
  8030de:	75 48                	jne    803128 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030e0:	e8 71 e4 ff ff       	call   801556 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8030e8:	8b 0b                	mov    (%ebx),%ecx
  8030ea:	8d 51 20             	lea    0x20(%ecx),%edx
  8030ed:	39 d0                	cmp    %edx,%eax
  8030ef:	73 e2                	jae    8030d3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030f4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030f8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030fb:	89 c2                	mov    %eax,%edx
  8030fd:	c1 fa 1f             	sar    $0x1f,%edx
  803100:	89 d1                	mov    %edx,%ecx
  803102:	c1 e9 1b             	shr    $0x1b,%ecx
  803105:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803108:	83 e2 1f             	and    $0x1f,%edx
  80310b:	29 ca                	sub    %ecx,%edx
  80310d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803115:	83 c0 01             	add    $0x1,%eax
  803118:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80311b:	83 c7 01             	add    $0x1,%edi
  80311e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803121:	75 c2                	jne    8030e5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803123:	8b 45 10             	mov    0x10(%ebp),%eax
  803126:	eb 05                	jmp    80312d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803128:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80312d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803130:	5b                   	pop    %ebx
  803131:	5e                   	pop    %esi
  803132:	5f                   	pop    %edi
  803133:	5d                   	pop    %ebp
  803134:	c3                   	ret    

00803135 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803135:	55                   	push   %ebp
  803136:	89 e5                	mov    %esp,%ebp
  803138:	57                   	push   %edi
  803139:	56                   	push   %esi
  80313a:	53                   	push   %ebx
  80313b:	83 ec 18             	sub    $0x18,%esp
  80313e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803141:	57                   	push   %edi
  803142:	e8 28 eb ff ff       	call   801c6f <fd2data>
  803147:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803149:	83 c4 10             	add    $0x10,%esp
  80314c:	bb 00 00 00 00       	mov    $0x0,%ebx
  803151:	eb 3d                	jmp    803190 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803153:	85 db                	test   %ebx,%ebx
  803155:	74 04                	je     80315b <devpipe_read+0x26>
				return i;
  803157:	89 d8                	mov    %ebx,%eax
  803159:	eb 44                	jmp    80319f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80315b:	89 f2                	mov    %esi,%edx
  80315d:	89 f8                	mov    %edi,%eax
  80315f:	e8 ec fe ff ff       	call   803050 <_pipeisclosed>
  803164:	85 c0                	test   %eax,%eax
  803166:	75 32                	jne    80319a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803168:	e8 e9 e3 ff ff       	call   801556 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80316d:	8b 06                	mov    (%esi),%eax
  80316f:	3b 46 04             	cmp    0x4(%esi),%eax
  803172:	74 df                	je     803153 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803174:	99                   	cltd   
  803175:	c1 ea 1b             	shr    $0x1b,%edx
  803178:	01 d0                	add    %edx,%eax
  80317a:	83 e0 1f             	and    $0x1f,%eax
  80317d:	29 d0                	sub    %edx,%eax
  80317f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803184:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803187:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80318a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80318d:	83 c3 01             	add    $0x1,%ebx
  803190:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803193:	75 d8                	jne    80316d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803195:	8b 45 10             	mov    0x10(%ebp),%eax
  803198:	eb 05                	jmp    80319f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80319a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80319f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031a2:	5b                   	pop    %ebx
  8031a3:	5e                   	pop    %esi
  8031a4:	5f                   	pop    %edi
  8031a5:	5d                   	pop    %ebp
  8031a6:	c3                   	ret    

008031a7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8031a7:	55                   	push   %ebp
  8031a8:	89 e5                	mov    %esp,%ebp
  8031aa:	56                   	push   %esi
  8031ab:	53                   	push   %ebx
  8031ac:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031b2:	50                   	push   %eax
  8031b3:	e8 ce ea ff ff       	call   801c86 <fd_alloc>
  8031b8:	83 c4 10             	add    $0x10,%esp
  8031bb:	89 c2                	mov    %eax,%edx
  8031bd:	85 c0                	test   %eax,%eax
  8031bf:	0f 88 2c 01 00 00    	js     8032f1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031c5:	83 ec 04             	sub    $0x4,%esp
  8031c8:	68 07 04 00 00       	push   $0x407
  8031cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8031d0:	6a 00                	push   $0x0
  8031d2:	e8 9e e3 ff ff       	call   801575 <sys_page_alloc>
  8031d7:	83 c4 10             	add    $0x10,%esp
  8031da:	89 c2                	mov    %eax,%edx
  8031dc:	85 c0                	test   %eax,%eax
  8031de:	0f 88 0d 01 00 00    	js     8032f1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031e4:	83 ec 0c             	sub    $0xc,%esp
  8031e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031ea:	50                   	push   %eax
  8031eb:	e8 96 ea ff ff       	call   801c86 <fd_alloc>
  8031f0:	89 c3                	mov    %eax,%ebx
  8031f2:	83 c4 10             	add    $0x10,%esp
  8031f5:	85 c0                	test   %eax,%eax
  8031f7:	0f 88 e2 00 00 00    	js     8032df <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031fd:	83 ec 04             	sub    $0x4,%esp
  803200:	68 07 04 00 00       	push   $0x407
  803205:	ff 75 f0             	pushl  -0x10(%ebp)
  803208:	6a 00                	push   $0x0
  80320a:	e8 66 e3 ff ff       	call   801575 <sys_page_alloc>
  80320f:	89 c3                	mov    %eax,%ebx
  803211:	83 c4 10             	add    $0x10,%esp
  803214:	85 c0                	test   %eax,%eax
  803216:	0f 88 c3 00 00 00    	js     8032df <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80321c:	83 ec 0c             	sub    $0xc,%esp
  80321f:	ff 75 f4             	pushl  -0xc(%ebp)
  803222:	e8 48 ea ff ff       	call   801c6f <fd2data>
  803227:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803229:	83 c4 0c             	add    $0xc,%esp
  80322c:	68 07 04 00 00       	push   $0x407
  803231:	50                   	push   %eax
  803232:	6a 00                	push   $0x0
  803234:	e8 3c e3 ff ff       	call   801575 <sys_page_alloc>
  803239:	89 c3                	mov    %eax,%ebx
  80323b:	83 c4 10             	add    $0x10,%esp
  80323e:	85 c0                	test   %eax,%eax
  803240:	0f 88 89 00 00 00    	js     8032cf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803246:	83 ec 0c             	sub    $0xc,%esp
  803249:	ff 75 f0             	pushl  -0x10(%ebp)
  80324c:	e8 1e ea ff ff       	call   801c6f <fd2data>
  803251:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803258:	50                   	push   %eax
  803259:	6a 00                	push   $0x0
  80325b:	56                   	push   %esi
  80325c:	6a 00                	push   $0x0
  80325e:	e8 55 e3 ff ff       	call   8015b8 <sys_page_map>
  803263:	89 c3                	mov    %eax,%ebx
  803265:	83 c4 20             	add    $0x20,%esp
  803268:	85 c0                	test   %eax,%eax
  80326a:	78 55                	js     8032c1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80326c:	8b 15 58 50 80 00    	mov    0x805058,%edx
  803272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803275:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80327a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803281:	8b 15 58 50 80 00    	mov    0x805058,%edx
  803287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80328a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80328c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80328f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803296:	83 ec 0c             	sub    $0xc,%esp
  803299:	ff 75 f4             	pushl  -0xc(%ebp)
  80329c:	e8 be e9 ff ff       	call   801c5f <fd2num>
  8032a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032a4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8032a6:	83 c4 04             	add    $0x4,%esp
  8032a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8032ac:	e8 ae e9 ff ff       	call   801c5f <fd2num>
  8032b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032b4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032b7:	83 c4 10             	add    $0x10,%esp
  8032ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8032bf:	eb 30                	jmp    8032f1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032c1:	83 ec 08             	sub    $0x8,%esp
  8032c4:	56                   	push   %esi
  8032c5:	6a 00                	push   $0x0
  8032c7:	e8 2e e3 ff ff       	call   8015fa <sys_page_unmap>
  8032cc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032cf:	83 ec 08             	sub    $0x8,%esp
  8032d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8032d5:	6a 00                	push   $0x0
  8032d7:	e8 1e e3 ff ff       	call   8015fa <sys_page_unmap>
  8032dc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032df:	83 ec 08             	sub    $0x8,%esp
  8032e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e5:	6a 00                	push   $0x0
  8032e7:	e8 0e e3 ff ff       	call   8015fa <sys_page_unmap>
  8032ec:	83 c4 10             	add    $0x10,%esp
  8032ef:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032f1:	89 d0                	mov    %edx,%eax
  8032f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032f6:	5b                   	pop    %ebx
  8032f7:	5e                   	pop    %esi
  8032f8:	5d                   	pop    %ebp
  8032f9:	c3                   	ret    

008032fa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8032fa:	55                   	push   %ebp
  8032fb:	89 e5                	mov    %esp,%ebp
  8032fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803303:	50                   	push   %eax
  803304:	ff 75 08             	pushl  0x8(%ebp)
  803307:	e8 c9 e9 ff ff       	call   801cd5 <fd_lookup>
  80330c:	89 c2                	mov    %eax,%edx
  80330e:	83 c4 10             	add    $0x10,%esp
  803311:	85 d2                	test   %edx,%edx
  803313:	78 18                	js     80332d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803315:	83 ec 0c             	sub    $0xc,%esp
  803318:	ff 75 f4             	pushl  -0xc(%ebp)
  80331b:	e8 4f e9 ff ff       	call   801c6f <fd2data>
	return _pipeisclosed(fd, p);
  803320:	89 c2                	mov    %eax,%edx
  803322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803325:	e8 26 fd ff ff       	call   803050 <_pipeisclosed>
  80332a:	83 c4 10             	add    $0x10,%esp
}
  80332d:	c9                   	leave  
  80332e:	c3                   	ret    

0080332f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80332f:	55                   	push   %ebp
  803330:	89 e5                	mov    %esp,%ebp
  803332:	56                   	push   %esi
  803333:	53                   	push   %ebx
  803334:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803337:	85 f6                	test   %esi,%esi
  803339:	75 16                	jne    803351 <wait+0x22>
  80333b:	68 8e 40 80 00       	push   $0x80408e
  803340:	68 34 39 80 00       	push   $0x803934
  803345:	6a 09                	push   $0x9
  803347:	68 99 40 80 00       	push   $0x804099
  80334c:	e8 c8 d6 ff ff       	call   800a19 <_panic>
	e = &envs[ENVX(envid)];
  803351:	89 f3                	mov    %esi,%ebx
  803353:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803359:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80335c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803362:	eb 05                	jmp    803369 <wait+0x3a>
		sys_yield();
  803364:	e8 ed e1 ff ff       	call   801556 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803369:	8b 43 48             	mov    0x48(%ebx),%eax
  80336c:	39 f0                	cmp    %esi,%eax
  80336e:	75 07                	jne    803377 <wait+0x48>
  803370:	8b 43 54             	mov    0x54(%ebx),%eax
  803373:	85 c0                	test   %eax,%eax
  803375:	75 ed                	jne    803364 <wait+0x35>
		sys_yield();
}
  803377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80337a:	5b                   	pop    %ebx
  80337b:	5e                   	pop    %esi
  80337c:	5d                   	pop    %ebp
  80337d:	c3                   	ret    

0080337e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80337e:	55                   	push   %ebp
  80337f:	89 e5                	mov    %esp,%ebp
  803381:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  803384:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80338b:	75 2c                	jne    8033b9 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80338d:	83 ec 04             	sub    $0x4,%esp
  803390:	6a 07                	push   $0x7
  803392:	68 00 f0 bf ee       	push   $0xeebff000
  803397:	6a 00                	push   $0x0
  803399:	e8 d7 e1 ff ff       	call   801575 <sys_page_alloc>
  80339e:	83 c4 10             	add    $0x10,%esp
  8033a1:	85 c0                	test   %eax,%eax
  8033a3:	74 14                	je     8033b9 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8033a5:	83 ec 04             	sub    $0x4,%esp
  8033a8:	68 a4 40 80 00       	push   $0x8040a4
  8033ad:	6a 21                	push   $0x21
  8033af:	68 08 41 80 00       	push   $0x804108
  8033b4:	e8 60 d6 ff ff       	call   800a19 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8033b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033bc:	a3 00 90 80 00       	mov    %eax,0x809000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8033c1:	83 ec 08             	sub    $0x8,%esp
  8033c4:	68 ed 33 80 00       	push   $0x8033ed
  8033c9:	6a 00                	push   $0x0
  8033cb:	e8 f0 e2 ff ff       	call   8016c0 <sys_env_set_pgfault_upcall>
  8033d0:	83 c4 10             	add    $0x10,%esp
  8033d3:	85 c0                	test   %eax,%eax
  8033d5:	79 14                	jns    8033eb <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8033d7:	83 ec 04             	sub    $0x4,%esp
  8033da:	68 d0 40 80 00       	push   $0x8040d0
  8033df:	6a 29                	push   $0x29
  8033e1:	68 08 41 80 00       	push   $0x804108
  8033e6:	e8 2e d6 ff ff       	call   800a19 <_panic>
}
  8033eb:	c9                   	leave  
  8033ec:	c3                   	ret    

008033ed <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8033ed:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8033ee:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  8033f3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8033f5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8033f8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8033fd:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  803401:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  803405:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  803407:	83 c4 08             	add    $0x8,%esp
        popal
  80340a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80340b:	83 c4 04             	add    $0x4,%esp
        popfl
  80340e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  80340f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  803410:	c3                   	ret    

00803411 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803411:	55                   	push   %ebp
  803412:	89 e5                	mov    %esp,%ebp
  803414:	56                   	push   %esi
  803415:	53                   	push   %ebx
  803416:	8b 75 08             	mov    0x8(%ebp),%esi
  803419:	8b 45 0c             	mov    0xc(%ebp),%eax
  80341c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80341f:	85 c0                	test   %eax,%eax
  803421:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  803426:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  803429:	83 ec 0c             	sub    $0xc,%esp
  80342c:	50                   	push   %eax
  80342d:	e8 f3 e2 ff ff       	call   801725 <sys_ipc_recv>
  803432:	83 c4 10             	add    $0x10,%esp
  803435:	85 c0                	test   %eax,%eax
  803437:	79 16                	jns    80344f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  803439:	85 f6                	test   %esi,%esi
  80343b:	74 06                	je     803443 <ipc_recv+0x32>
  80343d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  803443:	85 db                	test   %ebx,%ebx
  803445:	74 2c                	je     803473 <ipc_recv+0x62>
  803447:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80344d:	eb 24                	jmp    803473 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80344f:	85 f6                	test   %esi,%esi
  803451:	74 0a                	je     80345d <ipc_recv+0x4c>
  803453:	a1 48 64 80 00       	mov    0x806448,%eax
  803458:	8b 40 74             	mov    0x74(%eax),%eax
  80345b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80345d:	85 db                	test   %ebx,%ebx
  80345f:	74 0a                	je     80346b <ipc_recv+0x5a>
  803461:	a1 48 64 80 00       	mov    0x806448,%eax
  803466:	8b 40 78             	mov    0x78(%eax),%eax
  803469:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80346b:	a1 48 64 80 00       	mov    0x806448,%eax
  803470:	8b 40 70             	mov    0x70(%eax),%eax
}
  803473:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803476:	5b                   	pop    %ebx
  803477:	5e                   	pop    %esi
  803478:	5d                   	pop    %ebp
  803479:	c3                   	ret    

0080347a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80347a:	55                   	push   %ebp
  80347b:	89 e5                	mov    %esp,%ebp
  80347d:	57                   	push   %edi
  80347e:	56                   	push   %esi
  80347f:	53                   	push   %ebx
  803480:	83 ec 0c             	sub    $0xc,%esp
  803483:	8b 7d 08             	mov    0x8(%ebp),%edi
  803486:	8b 75 0c             	mov    0xc(%ebp),%esi
  803489:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80348c:	85 db                	test   %ebx,%ebx
  80348e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803493:	0f 44 d8             	cmove  %eax,%ebx
  803496:	eb 1c                	jmp    8034b4 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  803498:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80349b:	74 12                	je     8034af <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80349d:	50                   	push   %eax
  80349e:	68 16 41 80 00       	push   $0x804116
  8034a3:	6a 39                	push   $0x39
  8034a5:	68 31 41 80 00       	push   $0x804131
  8034aa:	e8 6a d5 ff ff       	call   800a19 <_panic>
                 sys_yield();
  8034af:	e8 a2 e0 ff ff       	call   801556 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8034b4:	ff 75 14             	pushl  0x14(%ebp)
  8034b7:	53                   	push   %ebx
  8034b8:	56                   	push   %esi
  8034b9:	57                   	push   %edi
  8034ba:	e8 43 e2 ff ff       	call   801702 <sys_ipc_try_send>
  8034bf:	83 c4 10             	add    $0x10,%esp
  8034c2:	85 c0                	test   %eax,%eax
  8034c4:	78 d2                	js     803498 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8034c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034c9:	5b                   	pop    %ebx
  8034ca:	5e                   	pop    %esi
  8034cb:	5f                   	pop    %edi
  8034cc:	5d                   	pop    %ebp
  8034cd:	c3                   	ret    

008034ce <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8034ce:	55                   	push   %ebp
  8034cf:	89 e5                	mov    %esp,%ebp
  8034d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8034d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8034d9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8034dc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8034e2:	8b 52 50             	mov    0x50(%edx),%edx
  8034e5:	39 ca                	cmp    %ecx,%edx
  8034e7:	75 0d                	jne    8034f6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8034e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8034ec:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8034f1:	8b 40 08             	mov    0x8(%eax),%eax
  8034f4:	eb 0e                	jmp    803504 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8034f6:	83 c0 01             	add    $0x1,%eax
  8034f9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034fe:	75 d9                	jne    8034d9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803500:	66 b8 00 00          	mov    $0x0,%ax
}
  803504:	5d                   	pop    %ebp
  803505:	c3                   	ret    

00803506 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803506:	55                   	push   %ebp
  803507:	89 e5                	mov    %esp,%ebp
  803509:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80350c:	89 d0                	mov    %edx,%eax
  80350e:	c1 e8 16             	shr    $0x16,%eax
  803511:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803518:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80351d:	f6 c1 01             	test   $0x1,%cl
  803520:	74 1d                	je     80353f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803522:	c1 ea 0c             	shr    $0xc,%edx
  803525:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80352c:	f6 c2 01             	test   $0x1,%dl
  80352f:	74 0e                	je     80353f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803531:	c1 ea 0c             	shr    $0xc,%edx
  803534:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80353b:	ef 
  80353c:	0f b7 c0             	movzwl %ax,%eax
}
  80353f:	5d                   	pop    %ebp
  803540:	c3                   	ret    
  803541:	66 90                	xchg   %ax,%ax
  803543:	66 90                	xchg   %ax,%ax
  803545:	66 90                	xchg   %ax,%ax
  803547:	66 90                	xchg   %ax,%ax
  803549:	66 90                	xchg   %ax,%ax
  80354b:	66 90                	xchg   %ax,%ax
  80354d:	66 90                	xchg   %ax,%ax
  80354f:	90                   	nop

00803550 <__udivdi3>:
  803550:	55                   	push   %ebp
  803551:	57                   	push   %edi
  803552:	56                   	push   %esi
  803553:	83 ec 10             	sub    $0x10,%esp
  803556:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80355a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80355e:	8b 74 24 24          	mov    0x24(%esp),%esi
  803562:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  803566:	85 d2                	test   %edx,%edx
  803568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80356c:	89 34 24             	mov    %esi,(%esp)
  80356f:	89 c8                	mov    %ecx,%eax
  803571:	75 35                	jne    8035a8 <__udivdi3+0x58>
  803573:	39 f1                	cmp    %esi,%ecx
  803575:	0f 87 bd 00 00 00    	ja     803638 <__udivdi3+0xe8>
  80357b:	85 c9                	test   %ecx,%ecx
  80357d:	89 cd                	mov    %ecx,%ebp
  80357f:	75 0b                	jne    80358c <__udivdi3+0x3c>
  803581:	b8 01 00 00 00       	mov    $0x1,%eax
  803586:	31 d2                	xor    %edx,%edx
  803588:	f7 f1                	div    %ecx
  80358a:	89 c5                	mov    %eax,%ebp
  80358c:	89 f0                	mov    %esi,%eax
  80358e:	31 d2                	xor    %edx,%edx
  803590:	f7 f5                	div    %ebp
  803592:	89 c6                	mov    %eax,%esi
  803594:	89 f8                	mov    %edi,%eax
  803596:	f7 f5                	div    %ebp
  803598:	89 f2                	mov    %esi,%edx
  80359a:	83 c4 10             	add    $0x10,%esp
  80359d:	5e                   	pop    %esi
  80359e:	5f                   	pop    %edi
  80359f:	5d                   	pop    %ebp
  8035a0:	c3                   	ret    
  8035a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035a8:	3b 14 24             	cmp    (%esp),%edx
  8035ab:	77 7b                	ja     803628 <__udivdi3+0xd8>
  8035ad:	0f bd f2             	bsr    %edx,%esi
  8035b0:	83 f6 1f             	xor    $0x1f,%esi
  8035b3:	0f 84 97 00 00 00    	je     803650 <__udivdi3+0x100>
  8035b9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8035be:	89 d7                	mov    %edx,%edi
  8035c0:	89 f1                	mov    %esi,%ecx
  8035c2:	29 f5                	sub    %esi,%ebp
  8035c4:	d3 e7                	shl    %cl,%edi
  8035c6:	89 c2                	mov    %eax,%edx
  8035c8:	89 e9                	mov    %ebp,%ecx
  8035ca:	d3 ea                	shr    %cl,%edx
  8035cc:	89 f1                	mov    %esi,%ecx
  8035ce:	09 fa                	or     %edi,%edx
  8035d0:	8b 3c 24             	mov    (%esp),%edi
  8035d3:	d3 e0                	shl    %cl,%eax
  8035d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8035d9:	89 e9                	mov    %ebp,%ecx
  8035db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8035df:	8b 44 24 04          	mov    0x4(%esp),%eax
  8035e3:	89 fa                	mov    %edi,%edx
  8035e5:	d3 ea                	shr    %cl,%edx
  8035e7:	89 f1                	mov    %esi,%ecx
  8035e9:	d3 e7                	shl    %cl,%edi
  8035eb:	89 e9                	mov    %ebp,%ecx
  8035ed:	d3 e8                	shr    %cl,%eax
  8035ef:	09 c7                	or     %eax,%edi
  8035f1:	89 f8                	mov    %edi,%eax
  8035f3:	f7 74 24 08          	divl   0x8(%esp)
  8035f7:	89 d5                	mov    %edx,%ebp
  8035f9:	89 c7                	mov    %eax,%edi
  8035fb:	f7 64 24 0c          	mull   0xc(%esp)
  8035ff:	39 d5                	cmp    %edx,%ebp
  803601:	89 14 24             	mov    %edx,(%esp)
  803604:	72 11                	jb     803617 <__udivdi3+0xc7>
  803606:	8b 54 24 04          	mov    0x4(%esp),%edx
  80360a:	89 f1                	mov    %esi,%ecx
  80360c:	d3 e2                	shl    %cl,%edx
  80360e:	39 c2                	cmp    %eax,%edx
  803610:	73 5e                	jae    803670 <__udivdi3+0x120>
  803612:	3b 2c 24             	cmp    (%esp),%ebp
  803615:	75 59                	jne    803670 <__udivdi3+0x120>
  803617:	8d 47 ff             	lea    -0x1(%edi),%eax
  80361a:	31 f6                	xor    %esi,%esi
  80361c:	89 f2                	mov    %esi,%edx
  80361e:	83 c4 10             	add    $0x10,%esp
  803621:	5e                   	pop    %esi
  803622:	5f                   	pop    %edi
  803623:	5d                   	pop    %ebp
  803624:	c3                   	ret    
  803625:	8d 76 00             	lea    0x0(%esi),%esi
  803628:	31 f6                	xor    %esi,%esi
  80362a:	31 c0                	xor    %eax,%eax
  80362c:	89 f2                	mov    %esi,%edx
  80362e:	83 c4 10             	add    $0x10,%esp
  803631:	5e                   	pop    %esi
  803632:	5f                   	pop    %edi
  803633:	5d                   	pop    %ebp
  803634:	c3                   	ret    
  803635:	8d 76 00             	lea    0x0(%esi),%esi
  803638:	89 f2                	mov    %esi,%edx
  80363a:	31 f6                	xor    %esi,%esi
  80363c:	89 f8                	mov    %edi,%eax
  80363e:	f7 f1                	div    %ecx
  803640:	89 f2                	mov    %esi,%edx
  803642:	83 c4 10             	add    $0x10,%esp
  803645:	5e                   	pop    %esi
  803646:	5f                   	pop    %edi
  803647:	5d                   	pop    %ebp
  803648:	c3                   	ret    
  803649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803650:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803654:	76 0b                	jbe    803661 <__udivdi3+0x111>
  803656:	31 c0                	xor    %eax,%eax
  803658:	3b 14 24             	cmp    (%esp),%edx
  80365b:	0f 83 37 ff ff ff    	jae    803598 <__udivdi3+0x48>
  803661:	b8 01 00 00 00       	mov    $0x1,%eax
  803666:	e9 2d ff ff ff       	jmp    803598 <__udivdi3+0x48>
  80366b:	90                   	nop
  80366c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803670:	89 f8                	mov    %edi,%eax
  803672:	31 f6                	xor    %esi,%esi
  803674:	e9 1f ff ff ff       	jmp    803598 <__udivdi3+0x48>
  803679:	66 90                	xchg   %ax,%ax
  80367b:	66 90                	xchg   %ax,%ax
  80367d:	66 90                	xchg   %ax,%ax
  80367f:	90                   	nop

00803680 <__umoddi3>:
  803680:	55                   	push   %ebp
  803681:	57                   	push   %edi
  803682:	56                   	push   %esi
  803683:	83 ec 20             	sub    $0x20,%esp
  803686:	8b 44 24 34          	mov    0x34(%esp),%eax
  80368a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80368e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803692:	89 c6                	mov    %eax,%esi
  803694:	89 44 24 10          	mov    %eax,0x10(%esp)
  803698:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80369c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8036a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8036a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8036a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8036ac:	85 c0                	test   %eax,%eax
  8036ae:	89 c2                	mov    %eax,%edx
  8036b0:	75 1e                	jne    8036d0 <__umoddi3+0x50>
  8036b2:	39 f7                	cmp    %esi,%edi
  8036b4:	76 52                	jbe    803708 <__umoddi3+0x88>
  8036b6:	89 c8                	mov    %ecx,%eax
  8036b8:	89 f2                	mov    %esi,%edx
  8036ba:	f7 f7                	div    %edi
  8036bc:	89 d0                	mov    %edx,%eax
  8036be:	31 d2                	xor    %edx,%edx
  8036c0:	83 c4 20             	add    $0x20,%esp
  8036c3:	5e                   	pop    %esi
  8036c4:	5f                   	pop    %edi
  8036c5:	5d                   	pop    %ebp
  8036c6:	c3                   	ret    
  8036c7:	89 f6                	mov    %esi,%esi
  8036c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8036d0:	39 f0                	cmp    %esi,%eax
  8036d2:	77 5c                	ja     803730 <__umoddi3+0xb0>
  8036d4:	0f bd e8             	bsr    %eax,%ebp
  8036d7:	83 f5 1f             	xor    $0x1f,%ebp
  8036da:	75 64                	jne    803740 <__umoddi3+0xc0>
  8036dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8036e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8036e4:	0f 86 f6 00 00 00    	jbe    8037e0 <__umoddi3+0x160>
  8036ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8036ee:	0f 82 ec 00 00 00    	jb     8037e0 <__umoddi3+0x160>
  8036f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8036f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8036fc:	83 c4 20             	add    $0x20,%esp
  8036ff:	5e                   	pop    %esi
  803700:	5f                   	pop    %edi
  803701:	5d                   	pop    %ebp
  803702:	c3                   	ret    
  803703:	90                   	nop
  803704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803708:	85 ff                	test   %edi,%edi
  80370a:	89 fd                	mov    %edi,%ebp
  80370c:	75 0b                	jne    803719 <__umoddi3+0x99>
  80370e:	b8 01 00 00 00       	mov    $0x1,%eax
  803713:	31 d2                	xor    %edx,%edx
  803715:	f7 f7                	div    %edi
  803717:	89 c5                	mov    %eax,%ebp
  803719:	8b 44 24 10          	mov    0x10(%esp),%eax
  80371d:	31 d2                	xor    %edx,%edx
  80371f:	f7 f5                	div    %ebp
  803721:	89 c8                	mov    %ecx,%eax
  803723:	f7 f5                	div    %ebp
  803725:	eb 95                	jmp    8036bc <__umoddi3+0x3c>
  803727:	89 f6                	mov    %esi,%esi
  803729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803730:	89 c8                	mov    %ecx,%eax
  803732:	89 f2                	mov    %esi,%edx
  803734:	83 c4 20             	add    $0x20,%esp
  803737:	5e                   	pop    %esi
  803738:	5f                   	pop    %edi
  803739:	5d                   	pop    %ebp
  80373a:	c3                   	ret    
  80373b:	90                   	nop
  80373c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803740:	b8 20 00 00 00       	mov    $0x20,%eax
  803745:	89 e9                	mov    %ebp,%ecx
  803747:	29 e8                	sub    %ebp,%eax
  803749:	d3 e2                	shl    %cl,%edx
  80374b:	89 c7                	mov    %eax,%edi
  80374d:	89 44 24 18          	mov    %eax,0x18(%esp)
  803751:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803755:	89 f9                	mov    %edi,%ecx
  803757:	d3 e8                	shr    %cl,%eax
  803759:	89 c1                	mov    %eax,%ecx
  80375b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80375f:	09 d1                	or     %edx,%ecx
  803761:	89 fa                	mov    %edi,%edx
  803763:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803767:	89 e9                	mov    %ebp,%ecx
  803769:	d3 e0                	shl    %cl,%eax
  80376b:	89 f9                	mov    %edi,%ecx
  80376d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803771:	89 f0                	mov    %esi,%eax
  803773:	d3 e8                	shr    %cl,%eax
  803775:	89 e9                	mov    %ebp,%ecx
  803777:	89 c7                	mov    %eax,%edi
  803779:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80377d:	d3 e6                	shl    %cl,%esi
  80377f:	89 d1                	mov    %edx,%ecx
  803781:	89 fa                	mov    %edi,%edx
  803783:	d3 e8                	shr    %cl,%eax
  803785:	89 e9                	mov    %ebp,%ecx
  803787:	09 f0                	or     %esi,%eax
  803789:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80378d:	f7 74 24 10          	divl   0x10(%esp)
  803791:	d3 e6                	shl    %cl,%esi
  803793:	89 d1                	mov    %edx,%ecx
  803795:	f7 64 24 0c          	mull   0xc(%esp)
  803799:	39 d1                	cmp    %edx,%ecx
  80379b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80379f:	89 d7                	mov    %edx,%edi
  8037a1:	89 c6                	mov    %eax,%esi
  8037a3:	72 0a                	jb     8037af <__umoddi3+0x12f>
  8037a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8037a9:	73 10                	jae    8037bb <__umoddi3+0x13b>
  8037ab:	39 d1                	cmp    %edx,%ecx
  8037ad:	75 0c                	jne    8037bb <__umoddi3+0x13b>
  8037af:	89 d7                	mov    %edx,%edi
  8037b1:	89 c6                	mov    %eax,%esi
  8037b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8037b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8037bb:	89 ca                	mov    %ecx,%edx
  8037bd:	89 e9                	mov    %ebp,%ecx
  8037bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8037c3:	29 f0                	sub    %esi,%eax
  8037c5:	19 fa                	sbb    %edi,%edx
  8037c7:	d3 e8                	shr    %cl,%eax
  8037c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8037ce:	89 d7                	mov    %edx,%edi
  8037d0:	d3 e7                	shl    %cl,%edi
  8037d2:	89 e9                	mov    %ebp,%ecx
  8037d4:	09 f8                	or     %edi,%eax
  8037d6:	d3 ea                	shr    %cl,%edx
  8037d8:	83 c4 20             	add    $0x20,%esp
  8037db:	5e                   	pop    %esi
  8037dc:	5f                   	pop    %edi
  8037dd:	5d                   	pop    %ebp
  8037de:	c3                   	ret    
  8037df:	90                   	nop
  8037e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8037e4:	29 f9                	sub    %edi,%ecx
  8037e6:	19 c6                	sbb    %eax,%esi
  8037e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8037ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8037f0:	e9 ff fe ff ff       	jmp    8036f4 <__umoddi3+0x74>
