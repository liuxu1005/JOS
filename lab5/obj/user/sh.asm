
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
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 40 01 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 00 33 80 00       	push   $0x803300
  800060:	e8 8d 0a 00 00       	call   800af2 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 26 01 00 00       	jmp    800198 <_gettoken+0x165>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 0f 33 80 00       	push   $0x80330f
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
  8000ab:	68 1d 33 80 00       	push   $0x80331d
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
  8000ca:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000d1:	0f 8e c1 00 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("EOL\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 22 33 80 00       	push   $0x803322
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
  8000f8:	68 33 33 80 00       	push   $0x803333
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
  80011b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800122:	7e 74                	jle    800198 <_gettoken+0x165>
			cprintf("TOK %c\n", t);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	53                   	push   %ebx
  800128:	68 27 33 80 00       	push   $0x803327
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
  80014e:	68 2f 33 80 00       	push   $0x80332f
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
  800169:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800170:	7e 26                	jle    800198 <_gettoken+0x165>
		t = **p2;
  800172:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	ff 37                	pushl  (%edi)
  80017d:	68 3b 33 80 00       	push   $0x80333b
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
  8001b0:	68 0c 50 80 00       	push   $0x80500c
  8001b5:	68 10 50 80 00       	push   $0x805010
  8001ba:	50                   	push   %eax
  8001bb:	e8 73 fe ff ff       	call   800033 <_gettoken>
  8001c0:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cd:	eb 3a                	jmp    800209 <gettoken+0x69>
	}
	c = nc;
  8001cf:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d4:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dc:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e2:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	68 0c 50 80 00       	push   $0x80500c
  8001ec:	68 10 50 80 00       	push   $0x805010
  8001f1:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f7:	e8 37 fe ff ff       	call   800033 <_gettoken>
  8001fc:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  800201:	a1 04 50 80 00       	mov    0x805004,%eax
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
  800275:	68 45 33 80 00       	push   $0x803345
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
  8002a9:	68 7c 34 80 00       	push   $0x80347c
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
  8002c3:	e8 83 20 00 00       	call   80234b <open>
  8002c8:	89 c7                	mov    %eax,%edi
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	79 1b                	jns    8002ec <runcmd+0xe1>
				cprintf("open %s for write: %e", t, fd);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d8:	68 59 33 80 00       	push   $0x803359
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
  8002fa:	e8 b1 1a 00 00       	call   801db0 <dup>
				close(fd);
  8002ff:	89 3c 24             	mov    %edi,(%esp)
  800302:	e8 57 1a 00 00       	call   801d5e <close>
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
  800325:	68 a4 34 80 00       	push   $0x8034a4
  80032a:	e8 c3 07 00 00       	call   800af2 <cprintf>
				exit();
  80032f:	e8 cb 06 00 00       	call   8009ff <exit>
  800334:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	68 01 03 00 00       	push   $0x301
  80033f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800342:	e8 04 20 00 00       	call   80234b <open>
  800347:	89 c7                	mov    %eax,%edi
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 19                	jns    800369 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	50                   	push   %eax
  800354:	ff 75 a4             	pushl  -0x5c(%ebp)
  800357:	68 59 33 80 00       	push   $0x803359
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
  800378:	e8 33 1a 00 00       	call   801db0 <dup>
				close(fd);
  80037d:	89 3c 24             	mov    %edi,(%esp)
  800380:	e8 d9 19 00 00       	call   801d5e <close>
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	e9 9f fe ff ff       	jmp    80022c <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800396:	50                   	push   %eax
  800397:	e8 f4 28 00 00       	call   802c90 <pipe>
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 16                	jns    8003b9 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	50                   	push   %eax
  8003a7:	68 6f 33 80 00       	push   $0x80336f
  8003ac:	e8 41 07 00 00       	call   800af2 <cprintf>
				exit();
  8003b1:	e8 49 06 00 00       	call   8009ff <exit>
  8003b6:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003c0:	74 1c                	je     8003de <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003cb:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d1:	68 78 33 80 00       	push   $0x803378
  8003d6:	e8 17 07 00 00       	call   800af2 <cprintf>
  8003db:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003de:	e8 65 14 00 00       	call   801848 <fork>
  8003e3:	89 c7                	mov    %eax,%edi
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	79 16                	jns    8003ff <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	50                   	push   %eax
  8003ed:	68 6b 39 80 00       	push   $0x80396b
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
  800413:	e8 98 19 00 00       	call   801db0 <dup>
					close(p[0]);
  800418:	83 c4 04             	add    $0x4,%esp
  80041b:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800421:	e8 38 19 00 00       	call   801d5e <close>
  800426:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800429:	83 ec 0c             	sub    $0xc,%esp
  80042c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800432:	e8 27 19 00 00       	call   801d5e <close>
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
  800450:	e8 5b 19 00 00       	call   801db0 <dup>
					close(p[1]);
  800455:	83 c4 04             	add    $0x4,%esp
  800458:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045e:	e8 fb 18 00 00       	call   801d5e <close>
  800463:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046f:	e8 ea 18 00 00       	call   801d5e <close>
				goto runit;
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	eb 17                	jmp    800490 <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800479:	50                   	push   %eax
  80047a:	68 85 33 80 00       	push   $0x803385
  80047f:	6a 78                	push   $0x78
  800481:	68 a1 33 80 00       	push   $0x8033a1
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
  800494:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80049b:	0f 84 96 01 00 00    	je     800637 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	68 ab 33 80 00       	push   $0x8033ab
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
  8004e9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f0:	74 49                	je     80053b <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f2:	a1 44 54 80 00       	mov    0x805444,%eax
  8004f7:	8b 40 48             	mov    0x48(%eax),%eax
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	50                   	push   %eax
  8004fe:	68 ba 33 80 00       	push   $0x8033ba
  800503:	e8 ea 05 00 00       	call   800af2 <cprintf>
  800508:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 11                	jmp    800521 <runcmd+0x316>
			cprintf(" %s", argv[i]);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	50                   	push   %eax
  800514:	68 45 34 80 00       	push   $0x803445
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
  80052e:	68 20 33 80 00       	push   $0x803320
  800533:	e8 ba 05 00 00       	call   800af2 <cprintf>
  800538:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800541:	50                   	push   %eax
  800542:	ff 75 a8             	pushl  -0x58(%ebp)
  800545:	e8 b5 1f 00 00       	call   8024ff <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 89 c3 00 00 00    	jns    80061a <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800557:	83 ec 04             	sub    $0x4,%esp
  80055a:	50                   	push   %eax
  80055b:	ff 75 a8             	pushl  -0x58(%ebp)
  80055e:	68 c8 33 80 00       	push   $0x8033c8
  800563:	e8 8a 05 00 00       	call   800af2 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800568:	e8 1e 18 00 00       	call   801d8b <close_all>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 4c                	jmp    8005be <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800572:	a1 44 54 80 00       	mov    0x805444,%eax
  800577:	8b 40 48             	mov    0x48(%eax),%eax
  80057a:	53                   	push   %ebx
  80057b:	ff 75 a8             	pushl  -0x58(%ebp)
  80057e:	50                   	push   %eax
  80057f:	68 d6 33 80 00       	push   $0x8033d6
  800584:	e8 69 05 00 00       	call   800af2 <cprintf>
  800589:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 83 28 00 00       	call   802e18 <wait>
		if (debug)
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059f:	0f 84 8c 00 00 00    	je     800631 <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a5:	a1 44 54 80 00       	mov    0x805444,%eax
  8005aa:	8b 40 48             	mov    0x48(%eax),%eax
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	50                   	push   %eax
  8005b1:	68 eb 33 80 00       	push   $0x8033eb
  8005b6:	e8 37 05 00 00       	call   800af2 <cprintf>
  8005bb:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	74 51                	je     800613 <runcmd+0x408>
		if (debug)
  8005c2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c9:	74 1a                	je     8005e5 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005cb:	a1 44 54 80 00       	mov    0x805444,%eax
  8005d0:	8b 40 48             	mov    0x48(%eax),%eax
  8005d3:	83 ec 04             	sub    $0x4,%esp
  8005d6:	57                   	push   %edi
  8005d7:	50                   	push   %eax
  8005d8:	68 01 34 80 00       	push   $0x803401
  8005dd:	e8 10 05 00 00       	call   800af2 <cprintf>
  8005e2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e5:	83 ec 0c             	sub    $0xc,%esp
  8005e8:	57                   	push   %edi
  8005e9:	e8 2a 28 00 00       	call   802e18 <wait>
		if (debug)
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f8:	74 19                	je     800613 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005fa:	a1 44 54 80 00       	mov    0x805444,%eax
  8005ff:	8b 40 48             	mov    0x48(%eax),%eax
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	50                   	push   %eax
  800606:	68 eb 33 80 00       	push   $0x8033eb
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
  80061a:	e8 6c 17 00 00       	call   801d8b <close_all>
	if (r >= 0) {
		if (debug)
  80061f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
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
  800645:	68 cc 34 80 00       	push   $0x8034cc
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
  80066e:	e8 f7 13 00 00       	call   801a6a <argstart>
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
  8006a1:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
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
  8006ba:	e8 db 13 00 00       	call   801a9a <argnext>
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
  8006de:	e8 7b 16 00 00       	call   801d5e <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	6a 00                	push   $0x0
  8006e8:	ff 76 04             	pushl  0x4(%esi)
  8006eb:	e8 5b 1c 00 00       	call   80234b <open>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	79 1b                	jns    800712 <umain+0xb9>
			panic("open %s: %e", argv[1], r);
  8006f7:	83 ec 0c             	sub    $0xc,%esp
  8006fa:	50                   	push   %eax
  8006fb:	ff 76 04             	pushl  0x4(%esi)
  8006fe:	68 21 34 80 00       	push   $0x803421
  800703:	68 28 01 00 00       	push   $0x128
  800708:	68 a1 33 80 00       	push   $0x8033a1
  80070d:	e8 07 03 00 00       	call   800a19 <_panic>
		assert(r == 0);
  800712:	85 c0                	test   %eax,%eax
  800714:	74 19                	je     80072f <umain+0xd6>
  800716:	68 2d 34 80 00       	push   $0x80342d
  80071b:	68 34 34 80 00       	push   $0x803434
  800720:	68 29 01 00 00       	push   $0x129
  800725:	68 a1 33 80 00       	push   $0x8033a1
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
  80074a:	ba 1e 34 80 00       	mov    $0x80341e,%edx
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
  800764:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80076b:	74 10                	je     80077d <umain+0x124>
				cprintf("EXITING\n");
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	68 49 34 80 00       	push   $0x803449
  800775:	e8 78 03 00 00       	call   800af2 <cprintf>
  80077a:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80077d:	e8 7d 02 00 00       	call   8009ff <exit>
		}
		if (debug)
  800782:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800789:	74 11                	je     80079c <umain+0x143>
			cprintf("LINE: %s\n", buf);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	68 52 34 80 00       	push   $0x803452
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
  8007ab:	68 5c 34 80 00       	push   $0x80345c
  8007b0:	e8 34 1d 00 00       	call   8024e9 <printf>
  8007b5:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bf:	74 10                	je     8007d1 <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007c1:	83 ec 0c             	sub    $0xc,%esp
  8007c4:	68 62 34 80 00       	push   $0x803462
  8007c9:	e8 24 03 00 00       	call   800af2 <cprintf>
  8007ce:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007d1:	e8 72 10 00 00       	call   801848 <fork>
  8007d6:	89 c6                	mov    %eax,%esi
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	79 15                	jns    8007f1 <umain+0x198>
			panic("fork: %e", r);
  8007dc:	50                   	push   %eax
  8007dd:	68 6b 39 80 00       	push   $0x80396b
  8007e2:	68 40 01 00 00       	push   $0x140
  8007e7:	68 a1 33 80 00       	push   $0x8033a1
  8007ec:	e8 28 02 00 00       	call   800a19 <_panic>
		if (debug)
  8007f1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f8:	74 11                	je     80080b <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	50                   	push   %eax
  8007fe:	68 6f 34 80 00       	push   $0x80346f
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
  800829:	e8 ea 25 00 00       	call   802e18 <wait>
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
  800846:	68 ed 34 80 00       	push   $0x8034ed
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
  800916:	e8 83 15 00 00       	call   801e9e <read>
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
  800940:	e8 ef 12 00 00       	call   801c34 <fd_lookup>
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 11                	js     80095d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	8b 15 00 40 80 00    	mov    0x804000,%edx
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
  800969:	e8 77 12 00 00       	call   801be5 <fd_alloc>
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
  800992:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a7:	83 ec 0c             	sub    $0xc,%esp
  8009aa:	50                   	push   %eax
  8009ab:	e8 0e 12 00 00       	call   801bbe <fd2num>
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
  8009d6:	a3 44 54 80 00       	mov    %eax,0x805444

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	7e 07                	jle    8009e6 <libmain+0x2d>
		binaryname = argv[0];
  8009df:	8b 06                	mov    (%esi),%eax
  8009e1:	a3 1c 40 80 00       	mov    %eax,0x80401c

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
  800a05:	e8 81 13 00 00       	call   801d8b <close_all>
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
  800a21:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a27:	e8 0b 0b 00 00       	call   801537 <sys_getenvid>
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	ff 75 08             	pushl  0x8(%ebp)
  800a35:	56                   	push   %esi
  800a36:	50                   	push   %eax
  800a37:	68 04 35 80 00       	push   $0x803504
  800a3c:	e8 b1 00 00 00       	call   800af2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a41:	83 c4 18             	add    $0x18,%esp
  800a44:	53                   	push   %ebx
  800a45:	ff 75 10             	pushl  0x10(%ebp)
  800a48:	e8 54 00 00 00       	call   800aa1 <vcprintf>
	cprintf("\n");
  800a4d:	c7 04 24 20 33 80 00 	movl   $0x803320,(%esp)
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
  800b55:	e8 d6 24 00 00       	call   803030 <__udivdi3>
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
  800b93:	e8 c8 25 00 00       	call   803160 <__umoddi3>
  800b98:	83 c4 14             	add    $0x14,%esp
  800b9b:	0f be 80 27 35 80 00 	movsbl 0x803527(%eax),%eax
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
  800c97:	ff 24 85 80 36 80 00 	jmp    *0x803680(,%eax,4)
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
  800d5b:	8b 14 85 00 38 80 00 	mov    0x803800(,%eax,4),%edx
  800d62:	85 d2                	test   %edx,%edx
  800d64:	75 18                	jne    800d7e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d66:	50                   	push   %eax
  800d67:	68 3f 35 80 00       	push   $0x80353f
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
  800d7f:	68 46 34 80 00       	push   $0x803446
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
  800dac:	ba 38 35 80 00       	mov    $0x803538,%edx
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
  801054:	68 46 34 80 00       	push   $0x803446
  801059:	6a 01                	push   $0x1
  80105b:	e8 72 14 00 00       	call   8024d2 <fprintf>
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
  801094:	68 5f 38 80 00       	push   $0x80385f
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
  8010f2:	88 9e 40 50 80 00    	mov    %bl,0x805040(%esi)
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
  80111f:	c6 86 40 50 80 00 00 	movb   $0x0,0x805040(%esi)
			return buf;
  801126:	b8 40 50 80 00       	mov    $0x805040,%eax
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
  80151e:	68 6f 38 80 00       	push   $0x80386f
  801523:	6a 23                	push   $0x23
  801525:	68 8c 38 80 00       	push   $0x80388c
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
  80159f:	68 6f 38 80 00       	push   $0x80386f
  8015a4:	6a 23                	push   $0x23
  8015a6:	68 8c 38 80 00       	push   $0x80388c
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
  8015e1:	68 6f 38 80 00       	push   $0x80386f
  8015e6:	6a 23                	push   $0x23
  8015e8:	68 8c 38 80 00       	push   $0x80388c
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
  801623:	68 6f 38 80 00       	push   $0x80386f
  801628:	6a 23                	push   $0x23
  80162a:	68 8c 38 80 00       	push   $0x80388c
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
  801665:	68 6f 38 80 00       	push   $0x80386f
  80166a:	6a 23                	push   $0x23
  80166c:	68 8c 38 80 00       	push   $0x80388c
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
  8016a7:	68 6f 38 80 00       	push   $0x80386f
  8016ac:	6a 23                	push   $0x23
  8016ae:	68 8c 38 80 00       	push   $0x80388c
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
  8016e9:	68 6f 38 80 00       	push   $0x80386f
  8016ee:	6a 23                	push   $0x23
  8016f0:	68 8c 38 80 00       	push   $0x80388c
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
  80174d:	68 6f 38 80 00       	push   $0x80386f
  801752:	6a 23                	push   $0x23
  801754:	68 8c 38 80 00       	push   $0x80388c
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

00801766 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801770:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801772:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801776:	74 2e                	je     8017a6 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801778:	89 c2                	mov    %eax,%edx
  80177a:	c1 ea 16             	shr    $0x16,%edx
  80177d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801784:	f6 c2 01             	test   $0x1,%dl
  801787:	74 1d                	je     8017a6 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801789:	89 c2                	mov    %eax,%edx
  80178b:	c1 ea 0c             	shr    $0xc,%edx
  80178e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801795:	f6 c1 01             	test   $0x1,%cl
  801798:	74 0c                	je     8017a6 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  80179a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  8017a1:	f6 c6 08             	test   $0x8,%dh
  8017a4:	75 14                	jne    8017ba <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	68 9c 38 80 00       	push   $0x80389c
  8017ae:	6a 21                	push   $0x21
  8017b0:	68 2f 39 80 00       	push   $0x80392f
  8017b5:	e8 5f f2 ff ff       	call   800a19 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  8017ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017bf:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	6a 07                	push   $0x7
  8017c6:	68 00 f0 7f 00       	push   $0x7ff000
  8017cb:	6a 00                	push   $0x0
  8017cd:	e8 a3 fd ff ff       	call   801575 <sys_page_alloc>
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	79 14                	jns    8017ed <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	68 3a 39 80 00       	push   $0x80393a
  8017e1:	6a 2b                	push   $0x2b
  8017e3:	68 2f 39 80 00       	push   $0x80392f
  8017e8:	e8 2c f2 ff ff       	call   800a19 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	68 00 10 00 00       	push   $0x1000
  8017f5:	53                   	push   %ebx
  8017f6:	68 00 f0 7f 00       	push   $0x7ff000
  8017fb:	e8 fe fa ff ff       	call   8012fe <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  801800:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801807:	53                   	push   %ebx
  801808:	6a 00                	push   $0x0
  80180a:	68 00 f0 7f 00       	push   $0x7ff000
  80180f:	6a 00                	push   $0x0
  801811:	e8 a2 fd ff ff       	call   8015b8 <sys_page_map>
  801816:	83 c4 20             	add    $0x20,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	79 14                	jns    801831 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	68 50 39 80 00       	push   $0x803950
  801825:	6a 2e                	push   $0x2e
  801827:	68 2f 39 80 00       	push   $0x80392f
  80182c:	e8 e8 f1 ff ff       	call   800a19 <_panic>
        sys_page_unmap(0, PFTEMP); 
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	68 00 f0 7f 00       	push   $0x7ff000
  801839:	6a 00                	push   $0x0
  80183b:	e8 ba fd ff ff       	call   8015fa <sys_page_unmap>
  801840:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	57                   	push   %edi
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  801851:	68 66 17 80 00       	push   $0x801766
  801856:	e8 0c 16 00 00       	call   802e67 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80185b:	b8 07 00 00 00       	mov    $0x7,%eax
  801860:	cd 30                	int    $0x30
  801862:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	79 12                	jns    80187e <fork+0x36>
		panic("sys_exofork: %e", forkid);
  80186c:	50                   	push   %eax
  80186d:	68 64 39 80 00       	push   $0x803964
  801872:	6a 6d                	push   $0x6d
  801874:	68 2f 39 80 00       	push   $0x80392f
  801879:	e8 9b f1 ff ff       	call   800a19 <_panic>
  80187e:	89 c7                	mov    %eax,%edi
  801880:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801885:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801889:	75 21                	jne    8018ac <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  80188b:	e8 a7 fc ff ff       	call   801537 <sys_getenvid>
  801890:	25 ff 03 00 00       	and    $0x3ff,%eax
  801895:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801898:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80189d:	a3 44 54 80 00       	mov    %eax,0x805444
		return 0;
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a7:	e9 9c 01 00 00       	jmp    801a48 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	c1 e8 16             	shr    $0x16,%eax
  8018b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018b8:	a8 01                	test   $0x1,%al
  8018ba:	0f 84 f3 00 00 00    	je     8019b3 <fork+0x16b>
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	c1 e8 0c             	shr    $0xc,%eax
  8018c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018cc:	f6 c2 01             	test   $0x1,%dl
  8018cf:	0f 84 de 00 00 00    	je     8019b3 <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8018d5:	89 c6                	mov    %eax,%esi
  8018d7:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8018da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018e1:	f6 c6 04             	test   $0x4,%dh
  8018e4:	74 37                	je     80191d <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8018e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ed:	83 ec 0c             	sub    $0xc,%esp
  8018f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8018f5:	50                   	push   %eax
  8018f6:	56                   	push   %esi
  8018f7:	57                   	push   %edi
  8018f8:	56                   	push   %esi
  8018f9:	6a 00                	push   $0x0
  8018fb:	e8 b8 fc ff ff       	call   8015b8 <sys_page_map>
  801900:	83 c4 20             	add    $0x20,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	0f 89 a8 00 00 00    	jns    8019b3 <fork+0x16b>
                        panic("sys_page_map on new page fails %d \n", r);
  80190b:	50                   	push   %eax
  80190c:	68 c0 38 80 00       	push   $0x8038c0
  801911:	6a 49                	push   $0x49
  801913:	68 2f 39 80 00       	push   $0x80392f
  801918:	e8 fc f0 ff ff       	call   800a19 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  80191d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801924:	f6 c6 08             	test   $0x8,%dh
  801927:	75 0b                	jne    801934 <fork+0xec>
  801929:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801930:	a8 02                	test   $0x2,%al
  801932:	74 57                	je     80198b <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	68 05 08 00 00       	push   $0x805
  80193c:	56                   	push   %esi
  80193d:	57                   	push   %edi
  80193e:	56                   	push   %esi
  80193f:	6a 00                	push   $0x0
  801941:	e8 72 fc ff ff       	call   8015b8 <sys_page_map>
  801946:	83 c4 20             	add    $0x20,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	79 12                	jns    80195f <fork+0x117>
                        panic("sys_page_map on new page fails %d \n", r);
  80194d:	50                   	push   %eax
  80194e:	68 c0 38 80 00       	push   $0x8038c0
  801953:	6a 4c                	push   $0x4c
  801955:	68 2f 39 80 00       	push   $0x80392f
  80195a:	e8 ba f0 ff ff       	call   800a19 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	68 05 08 00 00       	push   $0x805
  801967:	56                   	push   %esi
  801968:	6a 00                	push   $0x0
  80196a:	56                   	push   %esi
  80196b:	6a 00                	push   $0x0
  80196d:	e8 46 fc ff ff       	call   8015b8 <sys_page_map>
  801972:	83 c4 20             	add    $0x20,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	79 3a                	jns    8019b3 <fork+0x16b>
                        panic("sys_page_map on current page fails %d\n", r);
  801979:	50                   	push   %eax
  80197a:	68 e4 38 80 00       	push   $0x8038e4
  80197f:	6a 4e                	push   $0x4e
  801981:	68 2f 39 80 00       	push   $0x80392f
  801986:	e8 8e f0 ff ff       	call   800a19 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	6a 05                	push   $0x5
  801990:	56                   	push   %esi
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	6a 00                	push   $0x0
  801995:	e8 1e fc ff ff       	call   8015b8 <sys_page_map>
  80199a:	83 c4 20             	add    $0x20,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	79 12                	jns    8019b3 <fork+0x16b>
                        panic("sys_page_map on new page fails %d\n", r);
  8019a1:	50                   	push   %eax
  8019a2:	68 0c 39 80 00       	push   $0x80390c
  8019a7:	6a 50                	push   $0x50
  8019a9:	68 2f 39 80 00       	push   $0x80392f
  8019ae:	e8 66 f0 ff ff       	call   800a19 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8019b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019b9:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019bf:	0f 85 e7 fe ff ff    	jne    8018ac <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	6a 07                	push   $0x7
  8019ca:	68 00 f0 bf ee       	push   $0xeebff000
  8019cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d2:	e8 9e fb ff ff       	call   801575 <sys_page_alloc>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	79 14                	jns    8019f2 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	68 74 39 80 00       	push   $0x803974
  8019e6:	6a 76                	push   $0x76
  8019e8:	68 2f 39 80 00       	push   $0x80392f
  8019ed:	e8 27 f0 ff ff       	call   800a19 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	68 d6 2e 80 00       	push   $0x802ed6
  8019fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019fd:	e8 be fc ff ff       	call   8016c0 <sys_env_set_pgfault_upcall>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	79 14                	jns    801a1d <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801a09:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0c:	68 8e 39 80 00       	push   $0x80398e
  801a11:	6a 79                	push   $0x79
  801a13:	68 2f 39 80 00       	push   $0x80392f
  801a18:	e8 fc ef ff ff       	call   800a19 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	6a 02                	push   $0x2
  801a22:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a25:	e8 12 fc ff ff       	call   80163c <sys_env_set_status>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	79 14                	jns    801a45 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801a31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a34:	68 ab 39 80 00       	push   $0x8039ab
  801a39:	6a 7b                	push   $0x7b
  801a3b:	68 2f 39 80 00       	push   $0x80392f
  801a40:	e8 d4 ef ff ff       	call   800a19 <_panic>
        return forkid;
  801a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <sfork>:

// Challenge!
int
sfork(void)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a56:	68 c2 39 80 00       	push   $0x8039c2
  801a5b:	68 83 00 00 00       	push   $0x83
  801a60:	68 2f 39 80 00       	push   $0x80392f
  801a65:	e8 af ef ff ff       	call   800a19 <_panic>

00801a6a <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  801a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a76:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a78:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a7b:	83 3a 01             	cmpl   $0x1,(%edx)
  801a7e:	7e 09                	jle    801a89 <argstart+0x1f>
  801a80:	ba 21 33 80 00       	mov    $0x803321,%edx
  801a85:	85 c9                	test   %ecx,%ecx
  801a87:	75 05                	jne    801a8e <argstart+0x24>
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <argnext>:

int
argnext(struct Argstate *args)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801aa4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aab:	8b 43 08             	mov    0x8(%ebx),%eax
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	74 6f                	je     801b21 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801ab2:	80 38 00             	cmpb   $0x0,(%eax)
  801ab5:	75 4e                	jne    801b05 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ab7:	8b 0b                	mov    (%ebx),%ecx
  801ab9:	83 39 01             	cmpl   $0x1,(%ecx)
  801abc:	74 55                	je     801b13 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801abe:	8b 53 04             	mov    0x4(%ebx),%edx
  801ac1:	8b 42 04             	mov    0x4(%edx),%eax
  801ac4:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ac7:	75 4a                	jne    801b13 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801ac9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801acd:	74 44                	je     801b13 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801acf:	83 c0 01             	add    $0x1,%eax
  801ad2:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	8b 01                	mov    (%ecx),%eax
  801ada:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ae1:	50                   	push   %eax
  801ae2:	8d 42 08             	lea    0x8(%edx),%eax
  801ae5:	50                   	push   %eax
  801ae6:	83 c2 04             	add    $0x4,%edx
  801ae9:	52                   	push   %edx
  801aea:	e8 0f f8 ff ff       	call   8012fe <memmove>
		(*args->argc)--;
  801aef:	8b 03                	mov    (%ebx),%eax
  801af1:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801af4:	8b 43 08             	mov    0x8(%ebx),%eax
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	80 38 2d             	cmpb   $0x2d,(%eax)
  801afd:	75 06                	jne    801b05 <argnext+0x6b>
  801aff:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b03:	74 0e                	je     801b13 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b05:	8b 53 08             	mov    0x8(%ebx),%edx
  801b08:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b0b:	83 c2 01             	add    $0x1,%edx
  801b0e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b11:	eb 13                	jmp    801b26 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b13:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b1f:	eb 05                	jmp    801b26 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 04             	sub    $0x4,%esp
  801b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b35:	8b 43 08             	mov    0x8(%ebx),%eax
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	74 58                	je     801b94 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b3c:	80 38 00             	cmpb   $0x0,(%eax)
  801b3f:	74 0c                	je     801b4d <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b41:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b44:	c7 43 08 21 33 80 00 	movl   $0x803321,0x8(%ebx)
  801b4b:	eb 42                	jmp    801b8f <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b4d:	8b 13                	mov    (%ebx),%edx
  801b4f:	83 3a 01             	cmpl   $0x1,(%edx)
  801b52:	7e 2d                	jle    801b81 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b54:	8b 43 04             	mov    0x4(%ebx),%eax
  801b57:	8b 48 04             	mov    0x4(%eax),%ecx
  801b5a:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	8b 12                	mov    (%edx),%edx
  801b62:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b69:	52                   	push   %edx
  801b6a:	8d 50 08             	lea    0x8(%eax),%edx
  801b6d:	52                   	push   %edx
  801b6e:	83 c0 04             	add    $0x4,%eax
  801b71:	50                   	push   %eax
  801b72:	e8 87 f7 ff ff       	call   8012fe <memmove>
		(*args->argc)--;
  801b77:	8b 03                	mov    (%ebx),%eax
  801b79:	83 28 01             	subl   $0x1,(%eax)
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb 0e                	jmp    801b8f <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b81:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b88:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b8f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b92:	eb 05                	jmp    801b99 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801ba7:	8b 51 0c             	mov    0xc(%ecx),%edx
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	85 d2                	test   %edx,%edx
  801bae:	75 0c                	jne    801bbc <argvalue+0x1e>
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	51                   	push   %ecx
  801bb4:	e8 72 ff ff ff       	call   801b2b <argnextvalue>
  801bb9:	83 c4 10             	add    $0x10,%esp
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	05 00 00 00 30       	add    $0x30000000,%eax
  801bc9:	c1 e8 0c             	shr    $0xc,%eax
}
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd4:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801bd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bde:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801beb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	c1 ea 16             	shr    $0x16,%edx
  801bf5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bfc:	f6 c2 01             	test   $0x1,%dl
  801bff:	74 11                	je     801c12 <fd_alloc+0x2d>
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	c1 ea 0c             	shr    $0xc,%edx
  801c06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c0d:	f6 c2 01             	test   $0x1,%dl
  801c10:	75 09                	jne    801c1b <fd_alloc+0x36>
			*fd_store = fd;
  801c12:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
  801c19:	eb 17                	jmp    801c32 <fd_alloc+0x4d>
  801c1b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c20:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c25:	75 c9                	jne    801bf0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c27:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c2d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c3a:	83 f8 1f             	cmp    $0x1f,%eax
  801c3d:	77 36                	ja     801c75 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c3f:	c1 e0 0c             	shl    $0xc,%eax
  801c42:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c47:	89 c2                	mov    %eax,%edx
  801c49:	c1 ea 16             	shr    $0x16,%edx
  801c4c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c53:	f6 c2 01             	test   $0x1,%dl
  801c56:	74 24                	je     801c7c <fd_lookup+0x48>
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	c1 ea 0c             	shr    $0xc,%edx
  801c5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c64:	f6 c2 01             	test   $0x1,%dl
  801c67:	74 1a                	je     801c83 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6c:	89 02                	mov    %eax,(%edx)
	return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c73:	eb 13                	jmp    801c88 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c7a:	eb 0c                	jmp    801c88 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c81:	eb 05                	jmp    801c88 <fd_lookup+0x54>
  801c83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 08             	sub    $0x8,%esp
  801c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c93:	ba 54 3a 80 00       	mov    $0x803a54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c98:	eb 13                	jmp    801cad <dev_lookup+0x23>
  801c9a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c9d:	39 08                	cmp    %ecx,(%eax)
  801c9f:	75 0c                	jne    801cad <dev_lookup+0x23>
			*dev = devtab[i];
  801ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca4:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cab:	eb 2e                	jmp    801cdb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cad:	8b 02                	mov    (%edx),%eax
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	75 e7                	jne    801c9a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cb3:	a1 44 54 80 00       	mov    0x805444,%eax
  801cb8:	8b 40 48             	mov    0x48(%eax),%eax
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	51                   	push   %ecx
  801cbf:	50                   	push   %eax
  801cc0:	68 d8 39 80 00       	push   $0x8039d8
  801cc5:	e8 28 ee ff ff       	call   800af2 <cprintf>
	*dev = 0;
  801cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	56                   	push   %esi
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 10             	sub    $0x10,%esp
  801ce5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ce8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801cef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cf5:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cf8:	50                   	push   %eax
  801cf9:	e8 36 ff ff ff       	call   801c34 <fd_lookup>
  801cfe:	83 c4 08             	add    $0x8,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 05                	js     801d0a <fd_close+0x2d>
	    || fd != fd2)
  801d05:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d08:	74 0c                	je     801d16 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d0a:	84 db                	test   %bl,%bl
  801d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d11:	0f 44 c2             	cmove  %edx,%eax
  801d14:	eb 41                	jmp    801d57 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	ff 36                	pushl  (%esi)
  801d1f:	e8 66 ff ff ff       	call   801c8a <dev_lookup>
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 1a                	js     801d47 <fd_close+0x6a>
		if (dev->dev_close)
  801d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d30:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d33:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	74 0b                	je     801d47 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	56                   	push   %esi
  801d40:	ff d0                	call   *%eax
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d47:	83 ec 08             	sub    $0x8,%esp
  801d4a:	56                   	push   %esi
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 a8 f8 ff ff       	call   8015fa <sys_page_unmap>
	return r;
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	89 d8                	mov    %ebx,%eax
}
  801d57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	ff 75 08             	pushl  0x8(%ebp)
  801d6b:	e8 c4 fe ff ff       	call   801c34 <fd_lookup>
  801d70:	89 c2                	mov    %eax,%edx
  801d72:	83 c4 08             	add    $0x8,%esp
  801d75:	85 d2                	test   %edx,%edx
  801d77:	78 10                	js     801d89 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801d79:	83 ec 08             	sub    $0x8,%esp
  801d7c:	6a 01                	push   $0x1
  801d7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d81:	e8 57 ff ff ff       	call   801cdd <fd_close>
  801d86:	83 c4 10             	add    $0x10,%esp
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <close_all>:

void
close_all(void)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	53                   	push   %ebx
  801d8f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d92:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d97:	83 ec 0c             	sub    $0xc,%esp
  801d9a:	53                   	push   %ebx
  801d9b:	e8 be ff ff ff       	call   801d5e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801da0:	83 c3 01             	add    $0x1,%ebx
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	83 fb 20             	cmp    $0x20,%ebx
  801da9:	75 ec                	jne    801d97 <close_all+0xc>
		close(i);
}
  801dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	57                   	push   %edi
  801db4:	56                   	push   %esi
  801db5:	53                   	push   %ebx
  801db6:	83 ec 2c             	sub    $0x2c,%esp
  801db9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	ff 75 08             	pushl  0x8(%ebp)
  801dc3:	e8 6c fe ff ff       	call   801c34 <fd_lookup>
  801dc8:	89 c2                	mov    %eax,%edx
  801dca:	83 c4 08             	add    $0x8,%esp
  801dcd:	85 d2                	test   %edx,%edx
  801dcf:	0f 88 c1 00 00 00    	js     801e96 <dup+0xe6>
		return r;
	close(newfdnum);
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	56                   	push   %esi
  801dd9:	e8 80 ff ff ff       	call   801d5e <close>

	newfd = INDEX2FD(newfdnum);
  801dde:	89 f3                	mov    %esi,%ebx
  801de0:	c1 e3 0c             	shl    $0xc,%ebx
  801de3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801de9:	83 c4 04             	add    $0x4,%esp
  801dec:	ff 75 e4             	pushl  -0x1c(%ebp)
  801def:	e8 da fd ff ff       	call   801bce <fd2data>
  801df4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801df6:	89 1c 24             	mov    %ebx,(%esp)
  801df9:	e8 d0 fd ff ff       	call   801bce <fd2data>
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e04:	89 f8                	mov    %edi,%eax
  801e06:	c1 e8 16             	shr    $0x16,%eax
  801e09:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e10:	a8 01                	test   $0x1,%al
  801e12:	74 37                	je     801e4b <dup+0x9b>
  801e14:	89 f8                	mov    %edi,%eax
  801e16:	c1 e8 0c             	shr    $0xc,%eax
  801e19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e20:	f6 c2 01             	test   $0x1,%dl
  801e23:	74 26                	je     801e4b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	25 07 0e 00 00       	and    $0xe07,%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e38:	6a 00                	push   $0x0
  801e3a:	57                   	push   %edi
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 76 f7 ff ff       	call   8015b8 <sys_page_map>
  801e42:	89 c7                	mov    %eax,%edi
  801e44:	83 c4 20             	add    $0x20,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 2e                	js     801e79 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e4e:	89 d0                	mov    %edx,%eax
  801e50:	c1 e8 0c             	shr    $0xc,%eax
  801e53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	25 07 0e 00 00       	and    $0xe07,%eax
  801e62:	50                   	push   %eax
  801e63:	53                   	push   %ebx
  801e64:	6a 00                	push   $0x0
  801e66:	52                   	push   %edx
  801e67:	6a 00                	push   $0x0
  801e69:	e8 4a f7 ff ff       	call   8015b8 <sys_page_map>
  801e6e:	89 c7                	mov    %eax,%edi
  801e70:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e73:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e75:	85 ff                	test   %edi,%edi
  801e77:	79 1d                	jns    801e96 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e79:	83 ec 08             	sub    $0x8,%esp
  801e7c:	53                   	push   %ebx
  801e7d:	6a 00                	push   $0x0
  801e7f:	e8 76 f7 ff ff       	call   8015fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e84:	83 c4 08             	add    $0x8,%esp
  801e87:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 69 f7 ff ff       	call   8015fa <sys_page_unmap>
	return r;
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	89 f8                	mov    %edi,%eax
}
  801e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e99:	5b                   	pop    %ebx
  801e9a:	5e                   	pop    %esi
  801e9b:	5f                   	pop    %edi
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	53                   	push   %ebx
  801ea2:	83 ec 14             	sub    $0x14,%esp
  801ea5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ea8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	53                   	push   %ebx
  801ead:	e8 82 fd ff ff       	call   801c34 <fd_lookup>
  801eb2:	83 c4 08             	add    $0x8,%esp
  801eb5:	89 c2                	mov    %eax,%edx
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 6d                	js     801f28 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec1:	50                   	push   %eax
  801ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec5:	ff 30                	pushl  (%eax)
  801ec7:	e8 be fd ff ff       	call   801c8a <dev_lookup>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 4c                	js     801f1f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ed3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ed6:	8b 42 08             	mov    0x8(%edx),%eax
  801ed9:	83 e0 03             	and    $0x3,%eax
  801edc:	83 f8 01             	cmp    $0x1,%eax
  801edf:	75 21                	jne    801f02 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ee1:	a1 44 54 80 00       	mov    0x805444,%eax
  801ee6:	8b 40 48             	mov    0x48(%eax),%eax
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	53                   	push   %ebx
  801eed:	50                   	push   %eax
  801eee:	68 19 3a 80 00       	push   $0x803a19
  801ef3:	e8 fa eb ff ff       	call   800af2 <cprintf>
		return -E_INVAL;
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f00:	eb 26                	jmp    801f28 <read+0x8a>
	}
	if (!dev->dev_read)
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	8b 40 08             	mov    0x8(%eax),%eax
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	74 17                	je     801f23 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	ff 75 10             	pushl  0x10(%ebp)
  801f12:	ff 75 0c             	pushl  0xc(%ebp)
  801f15:	52                   	push   %edx
  801f16:	ff d0                	call   *%eax
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	eb 09                	jmp    801f28 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f1f:	89 c2                	mov    %eax,%edx
  801f21:	eb 05                	jmp    801f28 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f23:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f28:	89 d0                	mov    %edx,%eax
  801f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	57                   	push   %edi
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f43:	eb 21                	jmp    801f66 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f45:	83 ec 04             	sub    $0x4,%esp
  801f48:	89 f0                	mov    %esi,%eax
  801f4a:	29 d8                	sub    %ebx,%eax
  801f4c:	50                   	push   %eax
  801f4d:	89 d8                	mov    %ebx,%eax
  801f4f:	03 45 0c             	add    0xc(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	57                   	push   %edi
  801f54:	e8 45 ff ff ff       	call   801e9e <read>
		if (m < 0)
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 0c                	js     801f6c <readn+0x3d>
			return m;
		if (m == 0)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	74 06                	je     801f6a <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f64:	01 c3                	add    %eax,%ebx
  801f66:	39 f3                	cmp    %esi,%ebx
  801f68:	72 db                	jb     801f45 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801f6a:	89 d8                	mov    %ebx,%eax
}
  801f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	53                   	push   %ebx
  801f78:	83 ec 14             	sub    $0x14,%esp
  801f7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	53                   	push   %ebx
  801f83:	e8 ac fc ff ff       	call   801c34 <fd_lookup>
  801f88:	83 c4 08             	add    $0x8,%esp
  801f8b:	89 c2                	mov    %eax,%edx
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 68                	js     801ff9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f91:	83 ec 08             	sub    $0x8,%esp
  801f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9b:	ff 30                	pushl  (%eax)
  801f9d:	e8 e8 fc ff ff       	call   801c8a <dev_lookup>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 47                	js     801ff0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fb0:	75 21                	jne    801fd3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fb2:	a1 44 54 80 00       	mov    0x805444,%eax
  801fb7:	8b 40 48             	mov    0x48(%eax),%eax
  801fba:	83 ec 04             	sub    $0x4,%esp
  801fbd:	53                   	push   %ebx
  801fbe:	50                   	push   %eax
  801fbf:	68 35 3a 80 00       	push   $0x803a35
  801fc4:	e8 29 eb ff ff       	call   800af2 <cprintf>
		return -E_INVAL;
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fd1:	eb 26                	jmp    801ff9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fd6:	8b 52 0c             	mov    0xc(%edx),%edx
  801fd9:	85 d2                	test   %edx,%edx
  801fdb:	74 17                	je     801ff4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	ff 75 10             	pushl  0x10(%ebp)
  801fe3:	ff 75 0c             	pushl  0xc(%ebp)
  801fe6:	50                   	push   %eax
  801fe7:	ff d2                	call   *%edx
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	eb 09                	jmp    801ff9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff0:	89 c2                	mov    %eax,%edx
  801ff2:	eb 05                	jmp    801ff9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ff4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <seek>:

int
seek(int fdnum, off_t offset)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802006:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802009:	50                   	push   %eax
  80200a:	ff 75 08             	pushl  0x8(%ebp)
  80200d:	e8 22 fc ff ff       	call   801c34 <fd_lookup>
  802012:	83 c4 08             	add    $0x8,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	78 0e                	js     802027 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802019:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80201c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802027:	c9                   	leave  
  802028:	c3                   	ret    

00802029 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	53                   	push   %ebx
  80202d:	83 ec 14             	sub    $0x14,%esp
  802030:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802033:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802036:	50                   	push   %eax
  802037:	53                   	push   %ebx
  802038:	e8 f7 fb ff ff       	call   801c34 <fd_lookup>
  80203d:	83 c4 08             	add    $0x8,%esp
  802040:	89 c2                	mov    %eax,%edx
  802042:	85 c0                	test   %eax,%eax
  802044:	78 65                	js     8020ab <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802046:	83 ec 08             	sub    $0x8,%esp
  802049:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204c:	50                   	push   %eax
  80204d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802050:	ff 30                	pushl  (%eax)
  802052:	e8 33 fc ff ff       	call   801c8a <dev_lookup>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 44                	js     8020a2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802061:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802065:	75 21                	jne    802088 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802067:	a1 44 54 80 00       	mov    0x805444,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80206c:	8b 40 48             	mov    0x48(%eax),%eax
  80206f:	83 ec 04             	sub    $0x4,%esp
  802072:	53                   	push   %ebx
  802073:	50                   	push   %eax
  802074:	68 f8 39 80 00       	push   $0x8039f8
  802079:	e8 74 ea ff ff       	call   800af2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80207e:	83 c4 10             	add    $0x10,%esp
  802081:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802086:	eb 23                	jmp    8020ab <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802088:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208b:	8b 52 18             	mov    0x18(%edx),%edx
  80208e:	85 d2                	test   %edx,%edx
  802090:	74 14                	je     8020a6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802092:	83 ec 08             	sub    $0x8,%esp
  802095:	ff 75 0c             	pushl  0xc(%ebp)
  802098:	50                   	push   %eax
  802099:	ff d2                	call   *%edx
  80209b:	89 c2                	mov    %eax,%edx
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	eb 09                	jmp    8020ab <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020a2:	89 c2                	mov    %eax,%edx
  8020a4:	eb 05                	jmp    8020ab <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 14             	sub    $0x14,%esp
  8020b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020bf:	50                   	push   %eax
  8020c0:	ff 75 08             	pushl  0x8(%ebp)
  8020c3:	e8 6c fb ff ff       	call   801c34 <fd_lookup>
  8020c8:	83 c4 08             	add    $0x8,%esp
  8020cb:	89 c2                	mov    %eax,%edx
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 58                	js     802129 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020d1:	83 ec 08             	sub    $0x8,%esp
  8020d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d7:	50                   	push   %eax
  8020d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020db:	ff 30                	pushl  (%eax)
  8020dd:	e8 a8 fb ff ff       	call   801c8a <dev_lookup>
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 37                	js     802120 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020f0:	74 32                	je     802124 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020f2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020f5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020fc:	00 00 00 
	stat->st_isdir = 0;
  8020ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802106:	00 00 00 
	stat->st_dev = dev;
  802109:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80210f:	83 ec 08             	sub    $0x8,%esp
  802112:	53                   	push   %ebx
  802113:	ff 75 f0             	pushl  -0x10(%ebp)
  802116:	ff 50 14             	call   *0x14(%eax)
  802119:	89 c2                	mov    %eax,%edx
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	eb 09                	jmp    802129 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802120:	89 c2                	mov    %eax,%edx
  802122:	eb 05                	jmp    802129 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802124:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802129:	89 d0                	mov    %edx,%eax
  80212b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	56                   	push   %esi
  802134:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802135:	83 ec 08             	sub    $0x8,%esp
  802138:	6a 00                	push   $0x0
  80213a:	ff 75 08             	pushl  0x8(%ebp)
  80213d:	e8 09 02 00 00       	call   80234b <open>
  802142:	89 c3                	mov    %eax,%ebx
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	85 db                	test   %ebx,%ebx
  802149:	78 1b                	js     802166 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80214b:	83 ec 08             	sub    $0x8,%esp
  80214e:	ff 75 0c             	pushl  0xc(%ebp)
  802151:	53                   	push   %ebx
  802152:	e8 5b ff ff ff       	call   8020b2 <fstat>
  802157:	89 c6                	mov    %eax,%esi
	close(fd);
  802159:	89 1c 24             	mov    %ebx,(%esp)
  80215c:	e8 fd fb ff ff       	call   801d5e <close>
	return r;
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	89 f0                	mov    %esi,%eax
}
  802166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	89 c6                	mov    %eax,%esi
  802174:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802176:	83 3d 40 54 80 00 00 	cmpl   $0x0,0x805440
  80217d:	75 12                	jne    802191 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	6a 01                	push   $0x1
  802184:	e8 2e 0e 00 00       	call   802fb7 <ipc_find_env>
  802189:	a3 40 54 80 00       	mov    %eax,0x805440
  80218e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802191:	6a 07                	push   $0x7
  802193:	68 00 60 80 00       	push   $0x806000
  802198:	56                   	push   %esi
  802199:	ff 35 40 54 80 00    	pushl  0x805440
  80219f:	e8 bf 0d 00 00       	call   802f63 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021a4:	83 c4 0c             	add    $0xc,%esp
  8021a7:	6a 00                	push   $0x0
  8021a9:	53                   	push   %ebx
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 49 0d 00 00       	call   802efa <ipc_recv>
}
  8021b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    

008021b8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8021c4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cc:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8021db:	e8 8d ff ff ff       	call   80216d <fsipc>
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ee:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8021fd:	e8 6b ff ff ff       	call   80216d <fsipc>
}
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	53                   	push   %ebx
  802208:	83 ec 04             	sub    $0x4,%esp
  80220b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80220e:	8b 45 08             	mov    0x8(%ebp),%eax
  802211:	8b 40 0c             	mov    0xc(%eax),%eax
  802214:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802219:	ba 00 00 00 00       	mov    $0x0,%edx
  80221e:	b8 05 00 00 00       	mov    $0x5,%eax
  802223:	e8 45 ff ff ff       	call   80216d <fsipc>
  802228:	89 c2                	mov    %eax,%edx
  80222a:	85 d2                	test   %edx,%edx
  80222c:	78 2c                	js     80225a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80222e:	83 ec 08             	sub    $0x8,%esp
  802231:	68 00 60 80 00       	push   $0x806000
  802236:	53                   	push   %ebx
  802237:	e8 30 ef ff ff       	call   80116c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80223c:	a1 80 60 80 00       	mov    0x806080,%eax
  802241:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802247:	a1 84 60 80 00       	mov    0x806084,%eax
  80224c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80225a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    

0080225f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	57                   	push   %edi
  802263:	56                   	push   %esi
  802264:	53                   	push   %ebx
  802265:	83 ec 0c             	sub    $0xc,%esp
  802268:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	8b 40 0c             	mov    0xc(%eax),%eax
  802271:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  802276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802279:	eb 3d                	jmp    8022b8 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80227b:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  802281:	bf f8 0f 00 00       	mov    $0xff8,%edi
  802286:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  802289:	83 ec 04             	sub    $0x4,%esp
  80228c:	57                   	push   %edi
  80228d:	53                   	push   %ebx
  80228e:	68 08 60 80 00       	push   $0x806008
  802293:	e8 66 f0 ff ff       	call   8012fe <memmove>
                fsipcbuf.write.req_n = tmp; 
  802298:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80229e:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8022a8:	e8 c0 fe ff ff       	call   80216d <fsipc>
  8022ad:	83 c4 10             	add    $0x10,%esp
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 0d                	js     8022c1 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8022b4:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8022b6:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8022b8:	85 f6                	test   %esi,%esi
  8022ba:	75 bf                	jne    80227b <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8022c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8022d7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022dc:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8022ec:	e8 7c fe ff ff       	call   80216d <fsipc>
  8022f1:	89 c3                	mov    %eax,%ebx
  8022f3:	85 c0                	test   %eax,%eax
  8022f5:	78 4b                	js     802342 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022f7:	39 c6                	cmp    %eax,%esi
  8022f9:	73 16                	jae    802311 <devfile_read+0x48>
  8022fb:	68 64 3a 80 00       	push   $0x803a64
  802300:	68 34 34 80 00       	push   $0x803434
  802305:	6a 7c                	push   $0x7c
  802307:	68 6b 3a 80 00       	push   $0x803a6b
  80230c:	e8 08 e7 ff ff       	call   800a19 <_panic>
	assert(r <= PGSIZE);
  802311:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802316:	7e 16                	jle    80232e <devfile_read+0x65>
  802318:	68 76 3a 80 00       	push   $0x803a76
  80231d:	68 34 34 80 00       	push   $0x803434
  802322:	6a 7d                	push   $0x7d
  802324:	68 6b 3a 80 00       	push   $0x803a6b
  802329:	e8 eb e6 ff ff       	call   800a19 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80232e:	83 ec 04             	sub    $0x4,%esp
  802331:	50                   	push   %eax
  802332:	68 00 60 80 00       	push   $0x806000
  802337:	ff 75 0c             	pushl  0xc(%ebp)
  80233a:	e8 bf ef ff ff       	call   8012fe <memmove>
	return r;
  80233f:	83 c4 10             	add    $0x10,%esp
}
  802342:	89 d8                	mov    %ebx,%eax
  802344:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    

0080234b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	53                   	push   %ebx
  80234f:	83 ec 20             	sub    $0x20,%esp
  802352:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802355:	53                   	push   %ebx
  802356:	e8 d8 ed ff ff       	call   801133 <strlen>
  80235b:	83 c4 10             	add    $0x10,%esp
  80235e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802363:	7f 67                	jg     8023cc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802365:	83 ec 0c             	sub    $0xc,%esp
  802368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236b:	50                   	push   %eax
  80236c:	e8 74 f8 ff ff       	call   801be5 <fd_alloc>
  802371:	83 c4 10             	add    $0x10,%esp
		return r;
  802374:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802376:	85 c0                	test   %eax,%eax
  802378:	78 57                	js     8023d1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80237a:	83 ec 08             	sub    $0x8,%esp
  80237d:	53                   	push   %ebx
  80237e:	68 00 60 80 00       	push   $0x806000
  802383:	e8 e4 ed ff ff       	call   80116c <strcpy>
	fsipcbuf.open.req_omode = mode;
  802388:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802393:	b8 01 00 00 00       	mov    $0x1,%eax
  802398:	e8 d0 fd ff ff       	call   80216d <fsipc>
  80239d:	89 c3                	mov    %eax,%ebx
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	79 14                	jns    8023ba <open+0x6f>
		fd_close(fd, 0);
  8023a6:	83 ec 08             	sub    $0x8,%esp
  8023a9:	6a 00                	push   $0x0
  8023ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ae:	e8 2a f9 ff ff       	call   801cdd <fd_close>
		return r;
  8023b3:	83 c4 10             	add    $0x10,%esp
  8023b6:	89 da                	mov    %ebx,%edx
  8023b8:	eb 17                	jmp    8023d1 <open+0x86>
	}

	return fd2num(fd);
  8023ba:	83 ec 0c             	sub    $0xc,%esp
  8023bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c0:	e8 f9 f7 ff ff       	call   801bbe <fd2num>
  8023c5:	89 c2                	mov    %eax,%edx
  8023c7:	83 c4 10             	add    $0x10,%esp
  8023ca:	eb 05                	jmp    8023d1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023cc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023d1:	89 d0                	mov    %edx,%eax
  8023d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023d6:	c9                   	leave  
  8023d7:	c3                   	ret    

008023d8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023d8:	55                   	push   %ebp
  8023d9:	89 e5                	mov    %esp,%ebp
  8023db:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023de:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e8:	e8 80 fd ff ff       	call   80216d <fsipc>
}
  8023ed:	c9                   	leave  
  8023ee:	c3                   	ret    

008023ef <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023ef:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023f3:	7e 37                	jle    80242c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	53                   	push   %ebx
  8023f9:	83 ec 08             	sub    $0x8,%esp
  8023fc:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023fe:	ff 70 04             	pushl  0x4(%eax)
  802401:	8d 40 10             	lea    0x10(%eax),%eax
  802404:	50                   	push   %eax
  802405:	ff 33                	pushl  (%ebx)
  802407:	e8 68 fb ff ff       	call   801f74 <write>
		if (result > 0)
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	85 c0                	test   %eax,%eax
  802411:	7e 03                	jle    802416 <writebuf+0x27>
			b->result += result;
  802413:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802416:	39 43 04             	cmp    %eax,0x4(%ebx)
  802419:	74 0d                	je     802428 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80241b:	85 c0                	test   %eax,%eax
  80241d:	ba 00 00 00 00       	mov    $0x0,%edx
  802422:	0f 4f c2             	cmovg  %edx,%eax
  802425:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80242b:	c9                   	leave  
  80242c:	f3 c3                	repz ret 

0080242e <putch>:

static void
putch(int ch, void *thunk)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	53                   	push   %ebx
  802432:	83 ec 04             	sub    $0x4,%esp
  802435:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802438:	8b 53 04             	mov    0x4(%ebx),%edx
  80243b:	8d 42 01             	lea    0x1(%edx),%eax
  80243e:	89 43 04             	mov    %eax,0x4(%ebx)
  802441:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802444:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802448:	3d 00 01 00 00       	cmp    $0x100,%eax
  80244d:	75 0e                	jne    80245d <putch+0x2f>
		writebuf(b);
  80244f:	89 d8                	mov    %ebx,%eax
  802451:	e8 99 ff ff ff       	call   8023ef <writebuf>
		b->idx = 0;
  802456:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80245d:	83 c4 04             	add    $0x4,%esp
  802460:	5b                   	pop    %ebx
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    

00802463 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802463:	55                   	push   %ebp
  802464:	89 e5                	mov    %esp,%ebp
  802466:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80246c:	8b 45 08             	mov    0x8(%ebp),%eax
  80246f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802475:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80247c:	00 00 00 
	b.result = 0;
  80247f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802486:	00 00 00 
	b.error = 1;
  802489:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802490:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802493:	ff 75 10             	pushl  0x10(%ebp)
  802496:	ff 75 0c             	pushl  0xc(%ebp)
  802499:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80249f:	50                   	push   %eax
  8024a0:	68 2e 24 80 00       	push   $0x80242e
  8024a5:	e8 7a e7 ff ff       	call   800c24 <vprintfmt>
	if (b.idx > 0)
  8024aa:	83 c4 10             	add    $0x10,%esp
  8024ad:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024b4:	7e 0b                	jle    8024c1 <vfprintf+0x5e>
		writebuf(&b);
  8024b6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024bc:	e8 2e ff ff ff       	call   8023ef <writebuf>

	return (b.result ? b.result : b.error);
  8024c1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024d0:	c9                   	leave  
  8024d1:	c3                   	ret    

008024d2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024d8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024db:	50                   	push   %eax
  8024dc:	ff 75 0c             	pushl  0xc(%ebp)
  8024df:	ff 75 08             	pushl  0x8(%ebp)
  8024e2:	e8 7c ff ff ff       	call   802463 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024e7:	c9                   	leave  
  8024e8:	c3                   	ret    

008024e9 <printf>:

int
printf(const char *fmt, ...)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024f2:	50                   	push   %eax
  8024f3:	ff 75 08             	pushl  0x8(%ebp)
  8024f6:	6a 01                	push   $0x1
  8024f8:	e8 66 ff ff ff       	call   802463 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024fd:	c9                   	leave  
  8024fe:	c3                   	ret    

008024ff <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024ff:	55                   	push   %ebp
  802500:	89 e5                	mov    %esp,%ebp
  802502:	57                   	push   %edi
  802503:	56                   	push   %esi
  802504:	53                   	push   %ebx
  802505:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80250b:	6a 00                	push   $0x0
  80250d:	ff 75 08             	pushl  0x8(%ebp)
  802510:	e8 36 fe ff ff       	call   80234b <open>
  802515:	89 c7                	mov    %eax,%edi
  802517:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80251d:	83 c4 10             	add    $0x10,%esp
  802520:	85 c0                	test   %eax,%eax
  802522:	0f 88 97 04 00 00    	js     8029bf <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802528:	83 ec 04             	sub    $0x4,%esp
  80252b:	68 00 02 00 00       	push   $0x200
  802530:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802536:	50                   	push   %eax
  802537:	57                   	push   %edi
  802538:	e8 f2 f9 ff ff       	call   801f2f <readn>
  80253d:	83 c4 10             	add    $0x10,%esp
  802540:	3d 00 02 00 00       	cmp    $0x200,%eax
  802545:	75 0c                	jne    802553 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802547:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80254e:	45 4c 46 
  802551:	74 33                	je     802586 <spawn+0x87>
		close(fd);
  802553:	83 ec 0c             	sub    $0xc,%esp
  802556:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80255c:	e8 fd f7 ff ff       	call   801d5e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802561:	83 c4 0c             	add    $0xc,%esp
  802564:	68 7f 45 4c 46       	push   $0x464c457f
  802569:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80256f:	68 82 3a 80 00       	push   $0x803a82
  802574:	e8 79 e5 ff ff       	call   800af2 <cprintf>
		return -E_NOT_EXEC;
  802579:	83 c4 10             	add    $0x10,%esp
  80257c:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  802581:	e9 be 04 00 00       	jmp    802a44 <spawn+0x545>
  802586:	b8 07 00 00 00       	mov    $0x7,%eax
  80258b:	cd 30                	int    $0x30
  80258d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802593:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802599:	85 c0                	test   %eax,%eax
  80259b:	0f 88 26 04 00 00    	js     8029c7 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025a1:	89 c6                	mov    %eax,%esi
  8025a3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025a9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025ac:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025b2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025b8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025bf:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025c5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025cb:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025d0:	be 00 00 00 00       	mov    $0x0,%esi
  8025d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d8:	eb 13                	jmp    8025ed <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025da:	83 ec 0c             	sub    $0xc,%esp
  8025dd:	50                   	push   %eax
  8025de:	e8 50 eb ff ff       	call   801133 <strlen>
  8025e3:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025e7:	83 c3 01             	add    $0x1,%ebx
  8025ea:	83 c4 10             	add    $0x10,%esp
  8025ed:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025f4:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	75 df                	jne    8025da <spawn+0xdb>
  8025fb:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802601:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802607:	bf 00 10 40 00       	mov    $0x401000,%edi
  80260c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 e2 fc             	and    $0xfffffffc,%edx
  802613:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80261a:	29 c2                	sub    %eax,%edx
  80261c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802622:	8d 42 f8             	lea    -0x8(%edx),%eax
  802625:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80262a:	0f 86 a7 03 00 00    	jbe    8029d7 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802630:	83 ec 04             	sub    $0x4,%esp
  802633:	6a 07                	push   $0x7
  802635:	68 00 00 40 00       	push   $0x400000
  80263a:	6a 00                	push   $0x0
  80263c:	e8 34 ef ff ff       	call   801575 <sys_page_alloc>
  802641:	83 c4 10             	add    $0x10,%esp
  802644:	85 c0                	test   %eax,%eax
  802646:	0f 88 f8 03 00 00    	js     802a44 <spawn+0x545>
  80264c:	be 00 00 00 00       	mov    $0x0,%esi
  802651:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80265a:	eb 30                	jmp    80268c <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80265c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802662:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802668:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80266b:	83 ec 08             	sub    $0x8,%esp
  80266e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802671:	57                   	push   %edi
  802672:	e8 f5 ea ff ff       	call   80116c <strcpy>
		string_store += strlen(argv[i]) + 1;
  802677:	83 c4 04             	add    $0x4,%esp
  80267a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80267d:	e8 b1 ea ff ff       	call   801133 <strlen>
  802682:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802686:	83 c6 01             	add    $0x1,%esi
  802689:	83 c4 10             	add    $0x10,%esp
  80268c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802692:	7f c8                	jg     80265c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802694:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80269a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026a0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026a7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026ad:	74 19                	je     8026c8 <spawn+0x1c9>
  8026af:	68 0c 3b 80 00       	push   $0x803b0c
  8026b4:	68 34 34 80 00       	push   $0x803434
  8026b9:	68 f1 00 00 00       	push   $0xf1
  8026be:	68 9c 3a 80 00       	push   $0x803a9c
  8026c3:	e8 51 e3 ff ff       	call   800a19 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026c8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026ce:	89 f8                	mov    %edi,%eax
  8026d0:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026d5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026d8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026de:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026e1:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026e7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026ed:	83 ec 0c             	sub    $0xc,%esp
  8026f0:	6a 07                	push   $0x7
  8026f2:	68 00 d0 bf ee       	push   $0xeebfd000
  8026f7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026fd:	68 00 00 40 00       	push   $0x400000
  802702:	6a 00                	push   $0x0
  802704:	e8 af ee ff ff       	call   8015b8 <sys_page_map>
  802709:	89 c3                	mov    %eax,%ebx
  80270b:	83 c4 20             	add    $0x20,%esp
  80270e:	85 c0                	test   %eax,%eax
  802710:	0f 88 1a 03 00 00    	js     802a30 <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802716:	83 ec 08             	sub    $0x8,%esp
  802719:	68 00 00 40 00       	push   $0x400000
  80271e:	6a 00                	push   $0x0
  802720:	e8 d5 ee ff ff       	call   8015fa <sys_page_unmap>
  802725:	89 c3                	mov    %eax,%ebx
  802727:	83 c4 10             	add    $0x10,%esp
  80272a:	85 c0                	test   %eax,%eax
  80272c:	0f 88 fe 02 00 00    	js     802a30 <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802732:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802738:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80273f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802745:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80274c:	00 00 00 
  80274f:	e9 85 01 00 00       	jmp    8028d9 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  802754:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80275a:	83 38 01             	cmpl   $0x1,(%eax)
  80275d:	0f 85 68 01 00 00    	jne    8028cb <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802763:	89 c7                	mov    %eax,%edi
  802765:	8b 40 18             	mov    0x18(%eax),%eax
  802768:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80276e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802771:	83 f8 01             	cmp    $0x1,%eax
  802774:	19 c0                	sbb    %eax,%eax
  802776:	83 e0 fe             	and    $0xfffffffe,%eax
  802779:	83 c0 07             	add    $0x7,%eax
  80277c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802782:	89 f8                	mov    %edi,%eax
  802784:	8b 7f 04             	mov    0x4(%edi),%edi
  802787:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80278d:	8b 78 10             	mov    0x10(%eax),%edi
  802790:	8b 48 14             	mov    0x14(%eax),%ecx
  802793:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  802799:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80279c:	89 f0                	mov    %esi,%eax
  80279e:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027a3:	74 10                	je     8027b5 <spawn+0x2b6>
		va -= i;
  8027a5:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027a7:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  8027ad:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027af:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ba:	e9 fa 00 00 00       	jmp    8028b9 <spawn+0x3ba>
		if (i >= filesz) {
  8027bf:	39 fb                	cmp    %edi,%ebx
  8027c1:	72 27                	jb     8027ea <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027c3:	83 ec 04             	sub    $0x4,%esp
  8027c6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027cc:	56                   	push   %esi
  8027cd:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027d3:	e8 9d ed ff ff       	call   801575 <sys_page_alloc>
  8027d8:	83 c4 10             	add    $0x10,%esp
  8027db:	85 c0                	test   %eax,%eax
  8027dd:	0f 89 ca 00 00 00    	jns    8028ad <spawn+0x3ae>
  8027e3:	89 c7                	mov    %eax,%edi
  8027e5:	e9 fe 01 00 00       	jmp    8029e8 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027ea:	83 ec 04             	sub    $0x4,%esp
  8027ed:	6a 07                	push   $0x7
  8027ef:	68 00 00 40 00       	push   $0x400000
  8027f4:	6a 00                	push   $0x0
  8027f6:	e8 7a ed ff ff       	call   801575 <sys_page_alloc>
  8027fb:	83 c4 10             	add    $0x10,%esp
  8027fe:	85 c0                	test   %eax,%eax
  802800:	0f 88 d8 01 00 00    	js     8029de <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802806:	83 ec 08             	sub    $0x8,%esp
  802809:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80280f:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  802815:	50                   	push   %eax
  802816:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80281c:	e8 df f7 ff ff       	call   802000 <seek>
  802821:	83 c4 10             	add    $0x10,%esp
  802824:	85 c0                	test   %eax,%eax
  802826:	0f 88 b6 01 00 00    	js     8029e2 <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80282c:	83 ec 04             	sub    $0x4,%esp
  80282f:	89 fa                	mov    %edi,%edx
  802831:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  802837:	89 d0                	mov    %edx,%eax
  802839:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80283f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802844:	0f 47 c1             	cmova  %ecx,%eax
  802847:	50                   	push   %eax
  802848:	68 00 00 40 00       	push   $0x400000
  80284d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802853:	e8 d7 f6 ff ff       	call   801f2f <readn>
  802858:	83 c4 10             	add    $0x10,%esp
  80285b:	85 c0                	test   %eax,%eax
  80285d:	0f 88 83 01 00 00    	js     8029e6 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802863:	83 ec 0c             	sub    $0xc,%esp
  802866:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80286c:	56                   	push   %esi
  80286d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802873:	68 00 00 40 00       	push   $0x400000
  802878:	6a 00                	push   $0x0
  80287a:	e8 39 ed ff ff       	call   8015b8 <sys_page_map>
  80287f:	83 c4 20             	add    $0x20,%esp
  802882:	85 c0                	test   %eax,%eax
  802884:	79 15                	jns    80289b <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  802886:	50                   	push   %eax
  802887:	68 a8 3a 80 00       	push   $0x803aa8
  80288c:	68 24 01 00 00       	push   $0x124
  802891:	68 9c 3a 80 00       	push   $0x803a9c
  802896:	e8 7e e1 ff ff       	call   800a19 <_panic>
			sys_page_unmap(0, UTEMP);
  80289b:	83 ec 08             	sub    $0x8,%esp
  80289e:	68 00 00 40 00       	push   $0x400000
  8028a3:	6a 00                	push   $0x0
  8028a5:	e8 50 ed ff ff       	call   8015fa <sys_page_unmap>
  8028aa:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028b3:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028b9:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028bf:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028c5:	0f 82 f4 fe ff ff    	jb     8027bf <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028cb:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028d2:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028d9:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028e0:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028e6:	0f 8c 68 fe ff ff    	jl     802754 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028ec:	83 ec 0c             	sub    $0xc,%esp
  8028ef:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028f5:	e8 64 f4 ff ff       	call   801d5e <close>
  8028fa:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  8028fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802902:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  802908:	89 d8                	mov    %ebx,%eax
  80290a:	c1 e8 16             	shr    $0x16,%eax
  80290d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802914:	a8 01                	test   $0x1,%al
  802916:	74 53                	je     80296b <spawn+0x46c>
  802918:	89 d8                	mov    %ebx,%eax
  80291a:	c1 e8 0c             	shr    $0xc,%eax
  80291d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802924:	f6 c2 01             	test   $0x1,%dl
  802927:	74 42                	je     80296b <spawn+0x46c>
  802929:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802930:	f6 c6 04             	test   $0x4,%dh
  802933:	74 36                	je     80296b <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  802935:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80293c:	83 ec 0c             	sub    $0xc,%esp
  80293f:	25 07 0e 00 00       	and    $0xe07,%eax
  802944:	50                   	push   %eax
  802945:	53                   	push   %ebx
  802946:	56                   	push   %esi
  802947:	53                   	push   %ebx
  802948:	6a 00                	push   $0x0
  80294a:	e8 69 ec ff ff       	call   8015b8 <sys_page_map>
                        if (r < 0) return r;
  80294f:	83 c4 20             	add    $0x20,%esp
  802952:	85 c0                	test   %eax,%eax
  802954:	79 15                	jns    80296b <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802956:	50                   	push   %eax
  802957:	68 c5 3a 80 00       	push   $0x803ac5
  80295c:	68 82 00 00 00       	push   $0x82
  802961:	68 9c 3a 80 00       	push   $0x803a9c
  802966:	e8 ae e0 ff ff       	call   800a19 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  80296b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802971:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802977:	75 8f                	jne    802908 <spawn+0x409>
  802979:	e9 8d 00 00 00       	jmp    802a0b <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  80297e:	50                   	push   %eax
  80297f:	68 db 3a 80 00       	push   $0x803adb
  802984:	68 85 00 00 00       	push   $0x85
  802989:	68 9c 3a 80 00       	push   $0x803a9c
  80298e:	e8 86 e0 ff ff       	call   800a19 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802993:	83 ec 08             	sub    $0x8,%esp
  802996:	6a 02                	push   $0x2
  802998:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80299e:	e8 99 ec ff ff       	call   80163c <sys_env_set_status>
  8029a3:	83 c4 10             	add    $0x10,%esp
  8029a6:	85 c0                	test   %eax,%eax
  8029a8:	79 25                	jns    8029cf <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  8029aa:	50                   	push   %eax
  8029ab:	68 f5 3a 80 00       	push   $0x803af5
  8029b0:	68 88 00 00 00       	push   $0x88
  8029b5:	68 9c 3a 80 00       	push   $0x803a9c
  8029ba:	e8 5a e0 ff ff       	call   800a19 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029bf:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8029c5:	eb 7d                	jmp    802a44 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029c7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029cd:	eb 75                	jmp    802a44 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029cf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029d5:	eb 6d                	jmp    802a44 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029d7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8029dc:	eb 66                	jmp    802a44 <spawn+0x545>
  8029de:	89 c7                	mov    %eax,%edi
  8029e0:	eb 06                	jmp    8029e8 <spawn+0x4e9>
  8029e2:	89 c7                	mov    %eax,%edi
  8029e4:	eb 02                	jmp    8029e8 <spawn+0x4e9>
  8029e6:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029e8:	83 ec 0c             	sub    $0xc,%esp
  8029eb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029f1:	e8 00 eb ff ff       	call   8014f6 <sys_env_destroy>
	close(fd);
  8029f6:	83 c4 04             	add    $0x4,%esp
  8029f9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029ff:	e8 5a f3 ff ff       	call   801d5e <close>
	return r;
  802a04:	83 c4 10             	add    $0x10,%esp
  802a07:	89 f8                	mov    %edi,%eax
  802a09:	eb 39                	jmp    802a44 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  802a0b:	83 ec 08             	sub    $0x8,%esp
  802a0e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a14:	50                   	push   %eax
  802a15:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a1b:	e8 5e ec ff ff       	call   80167e <sys_env_set_trapframe>
  802a20:	83 c4 10             	add    $0x10,%esp
  802a23:	85 c0                	test   %eax,%eax
  802a25:	0f 89 68 ff ff ff    	jns    802993 <spawn+0x494>
  802a2b:	e9 4e ff ff ff       	jmp    80297e <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a30:	83 ec 08             	sub    $0x8,%esp
  802a33:	68 00 00 40 00       	push   $0x400000
  802a38:	6a 00                	push   $0x0
  802a3a:	e8 bb eb ff ff       	call   8015fa <sys_page_unmap>
  802a3f:	83 c4 10             	add    $0x10,%esp
  802a42:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a47:	5b                   	pop    %ebx
  802a48:	5e                   	pop    %esi
  802a49:	5f                   	pop    %edi
  802a4a:	5d                   	pop    %ebp
  802a4b:	c3                   	ret    

00802a4c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a4c:	55                   	push   %ebp
  802a4d:	89 e5                	mov    %esp,%ebp
  802a4f:	56                   	push   %esi
  802a50:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a51:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a54:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a59:	eb 03                	jmp    802a5e <spawnl+0x12>
		argc++;
  802a5b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a5e:	83 c2 04             	add    $0x4,%edx
  802a61:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a65:	75 f4                	jne    802a5b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a67:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a6e:	83 e2 f0             	and    $0xfffffff0,%edx
  802a71:	29 d4                	sub    %edx,%esp
  802a73:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a77:	c1 ea 02             	shr    $0x2,%edx
  802a7a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a81:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a86:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a8d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a94:	00 
  802a95:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a97:	b8 00 00 00 00       	mov    $0x0,%eax
  802a9c:	eb 0a                	jmp    802aa8 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a9e:	83 c0 01             	add    $0x1,%eax
  802aa1:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802aa5:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aa8:	39 d0                	cmp    %edx,%eax
  802aaa:	75 f2                	jne    802a9e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802aac:	83 ec 08             	sub    $0x8,%esp
  802aaf:	56                   	push   %esi
  802ab0:	ff 75 08             	pushl  0x8(%ebp)
  802ab3:	e8 47 fa ff ff       	call   8024ff <spawn>
}
  802ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802abb:	5b                   	pop    %ebx
  802abc:	5e                   	pop    %esi
  802abd:	5d                   	pop    %ebp
  802abe:	c3                   	ret    

00802abf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802abf:	55                   	push   %ebp
  802ac0:	89 e5                	mov    %esp,%ebp
  802ac2:	56                   	push   %esi
  802ac3:	53                   	push   %ebx
  802ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ac7:	83 ec 0c             	sub    $0xc,%esp
  802aca:	ff 75 08             	pushl  0x8(%ebp)
  802acd:	e8 fc f0 ff ff       	call   801bce <fd2data>
  802ad2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ad4:	83 c4 08             	add    $0x8,%esp
  802ad7:	68 32 3b 80 00       	push   $0x803b32
  802adc:	53                   	push   %ebx
  802add:	e8 8a e6 ff ff       	call   80116c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ae2:	8b 56 04             	mov    0x4(%esi),%edx
  802ae5:	89 d0                	mov    %edx,%eax
  802ae7:	2b 06                	sub    (%esi),%eax
  802ae9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802aef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802af6:	00 00 00 
	stat->st_dev = &devpipe;
  802af9:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b00:	40 80 00 
	return 0;
}
  802b03:	b8 00 00 00 00       	mov    $0x0,%eax
  802b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b0b:	5b                   	pop    %ebx
  802b0c:	5e                   	pop    %esi
  802b0d:	5d                   	pop    %ebp
  802b0e:	c3                   	ret    

00802b0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b0f:	55                   	push   %ebp
  802b10:	89 e5                	mov    %esp,%ebp
  802b12:	53                   	push   %ebx
  802b13:	83 ec 0c             	sub    $0xc,%esp
  802b16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b19:	53                   	push   %ebx
  802b1a:	6a 00                	push   $0x0
  802b1c:	e8 d9 ea ff ff       	call   8015fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b21:	89 1c 24             	mov    %ebx,(%esp)
  802b24:	e8 a5 f0 ff ff       	call   801bce <fd2data>
  802b29:	83 c4 08             	add    $0x8,%esp
  802b2c:	50                   	push   %eax
  802b2d:	6a 00                	push   $0x0
  802b2f:	e8 c6 ea ff ff       	call   8015fa <sys_page_unmap>
}
  802b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b37:	c9                   	leave  
  802b38:	c3                   	ret    

00802b39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b39:	55                   	push   %ebp
  802b3a:	89 e5                	mov    %esp,%ebp
  802b3c:	57                   	push   %edi
  802b3d:	56                   	push   %esi
  802b3e:	53                   	push   %ebx
  802b3f:	83 ec 1c             	sub    $0x1c,%esp
  802b42:	89 c6                	mov    %eax,%esi
  802b44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b47:	a1 44 54 80 00       	mov    0x805444,%eax
  802b4c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b4f:	83 ec 0c             	sub    $0xc,%esp
  802b52:	56                   	push   %esi
  802b53:	e8 97 04 00 00       	call   802fef <pageref>
  802b58:	89 c7                	mov    %eax,%edi
  802b5a:	83 c4 04             	add    $0x4,%esp
  802b5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b60:	e8 8a 04 00 00       	call   802fef <pageref>
  802b65:	83 c4 10             	add    $0x10,%esp
  802b68:	39 c7                	cmp    %eax,%edi
  802b6a:	0f 94 c2             	sete   %dl
  802b6d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802b70:	8b 0d 44 54 80 00    	mov    0x805444,%ecx
  802b76:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802b79:	39 fb                	cmp    %edi,%ebx
  802b7b:	74 19                	je     802b96 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  802b7d:	84 d2                	test   %dl,%dl
  802b7f:	74 c6                	je     802b47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b81:	8b 51 58             	mov    0x58(%ecx),%edx
  802b84:	50                   	push   %eax
  802b85:	52                   	push   %edx
  802b86:	53                   	push   %ebx
  802b87:	68 39 3b 80 00       	push   $0x803b39
  802b8c:	e8 61 df ff ff       	call   800af2 <cprintf>
  802b91:	83 c4 10             	add    $0x10,%esp
  802b94:	eb b1                	jmp    802b47 <_pipeisclosed+0xe>
	}
}
  802b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b99:	5b                   	pop    %ebx
  802b9a:	5e                   	pop    %esi
  802b9b:	5f                   	pop    %edi
  802b9c:	5d                   	pop    %ebp
  802b9d:	c3                   	ret    

00802b9e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b9e:	55                   	push   %ebp
  802b9f:	89 e5                	mov    %esp,%ebp
  802ba1:	57                   	push   %edi
  802ba2:	56                   	push   %esi
  802ba3:	53                   	push   %ebx
  802ba4:	83 ec 28             	sub    $0x28,%esp
  802ba7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802baa:	56                   	push   %esi
  802bab:	e8 1e f0 ff ff       	call   801bce <fd2data>
  802bb0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bb2:	83 c4 10             	add    $0x10,%esp
  802bb5:	bf 00 00 00 00       	mov    $0x0,%edi
  802bba:	eb 4b                	jmp    802c07 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bbc:	89 da                	mov    %ebx,%edx
  802bbe:	89 f0                	mov    %esi,%eax
  802bc0:	e8 74 ff ff ff       	call   802b39 <_pipeisclosed>
  802bc5:	85 c0                	test   %eax,%eax
  802bc7:	75 48                	jne    802c11 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bc9:	e8 88 e9 ff ff       	call   801556 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bce:	8b 43 04             	mov    0x4(%ebx),%eax
  802bd1:	8b 0b                	mov    (%ebx),%ecx
  802bd3:	8d 51 20             	lea    0x20(%ecx),%edx
  802bd6:	39 d0                	cmp    %edx,%eax
  802bd8:	73 e2                	jae    802bbc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bdd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802be1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802be4:	89 c2                	mov    %eax,%edx
  802be6:	c1 fa 1f             	sar    $0x1f,%edx
  802be9:	89 d1                	mov    %edx,%ecx
  802beb:	c1 e9 1b             	shr    $0x1b,%ecx
  802bee:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802bf1:	83 e2 1f             	and    $0x1f,%edx
  802bf4:	29 ca                	sub    %ecx,%edx
  802bf6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802bfa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802bfe:	83 c0 01             	add    $0x1,%eax
  802c01:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c04:	83 c7 01             	add    $0x1,%edi
  802c07:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c0a:	75 c2                	jne    802bce <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  802c0f:	eb 05                	jmp    802c16 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c11:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c19:	5b                   	pop    %ebx
  802c1a:	5e                   	pop    %esi
  802c1b:	5f                   	pop    %edi
  802c1c:	5d                   	pop    %ebp
  802c1d:	c3                   	ret    

00802c1e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c1e:	55                   	push   %ebp
  802c1f:	89 e5                	mov    %esp,%ebp
  802c21:	57                   	push   %edi
  802c22:	56                   	push   %esi
  802c23:	53                   	push   %ebx
  802c24:	83 ec 18             	sub    $0x18,%esp
  802c27:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c2a:	57                   	push   %edi
  802c2b:	e8 9e ef ff ff       	call   801bce <fd2data>
  802c30:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c32:	83 c4 10             	add    $0x10,%esp
  802c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c3a:	eb 3d                	jmp    802c79 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c3c:	85 db                	test   %ebx,%ebx
  802c3e:	74 04                	je     802c44 <devpipe_read+0x26>
				return i;
  802c40:	89 d8                	mov    %ebx,%eax
  802c42:	eb 44                	jmp    802c88 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c44:	89 f2                	mov    %esi,%edx
  802c46:	89 f8                	mov    %edi,%eax
  802c48:	e8 ec fe ff ff       	call   802b39 <_pipeisclosed>
  802c4d:	85 c0                	test   %eax,%eax
  802c4f:	75 32                	jne    802c83 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c51:	e8 00 e9 ff ff       	call   801556 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c56:	8b 06                	mov    (%esi),%eax
  802c58:	3b 46 04             	cmp    0x4(%esi),%eax
  802c5b:	74 df                	je     802c3c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c5d:	99                   	cltd   
  802c5e:	c1 ea 1b             	shr    $0x1b,%edx
  802c61:	01 d0                	add    %edx,%eax
  802c63:	83 e0 1f             	and    $0x1f,%eax
  802c66:	29 d0                	sub    %edx,%eax
  802c68:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c70:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c73:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c76:	83 c3 01             	add    $0x1,%ebx
  802c79:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c7c:	75 d8                	jne    802c56 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  802c81:	eb 05                	jmp    802c88 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c83:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c8b:	5b                   	pop    %ebx
  802c8c:	5e                   	pop    %esi
  802c8d:	5f                   	pop    %edi
  802c8e:	5d                   	pop    %ebp
  802c8f:	c3                   	ret    

00802c90 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c90:	55                   	push   %ebp
  802c91:	89 e5                	mov    %esp,%ebp
  802c93:	56                   	push   %esi
  802c94:	53                   	push   %ebx
  802c95:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c9b:	50                   	push   %eax
  802c9c:	e8 44 ef ff ff       	call   801be5 <fd_alloc>
  802ca1:	83 c4 10             	add    $0x10,%esp
  802ca4:	89 c2                	mov    %eax,%edx
  802ca6:	85 c0                	test   %eax,%eax
  802ca8:	0f 88 2c 01 00 00    	js     802dda <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cae:	83 ec 04             	sub    $0x4,%esp
  802cb1:	68 07 04 00 00       	push   $0x407
  802cb6:	ff 75 f4             	pushl  -0xc(%ebp)
  802cb9:	6a 00                	push   $0x0
  802cbb:	e8 b5 e8 ff ff       	call   801575 <sys_page_alloc>
  802cc0:	83 c4 10             	add    $0x10,%esp
  802cc3:	89 c2                	mov    %eax,%edx
  802cc5:	85 c0                	test   %eax,%eax
  802cc7:	0f 88 0d 01 00 00    	js     802dda <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802ccd:	83 ec 0c             	sub    $0xc,%esp
  802cd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cd3:	50                   	push   %eax
  802cd4:	e8 0c ef ff ff       	call   801be5 <fd_alloc>
  802cd9:	89 c3                	mov    %eax,%ebx
  802cdb:	83 c4 10             	add    $0x10,%esp
  802cde:	85 c0                	test   %eax,%eax
  802ce0:	0f 88 e2 00 00 00    	js     802dc8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ce6:	83 ec 04             	sub    $0x4,%esp
  802ce9:	68 07 04 00 00       	push   $0x407
  802cee:	ff 75 f0             	pushl  -0x10(%ebp)
  802cf1:	6a 00                	push   $0x0
  802cf3:	e8 7d e8 ff ff       	call   801575 <sys_page_alloc>
  802cf8:	89 c3                	mov    %eax,%ebx
  802cfa:	83 c4 10             	add    $0x10,%esp
  802cfd:	85 c0                	test   %eax,%eax
  802cff:	0f 88 c3 00 00 00    	js     802dc8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d05:	83 ec 0c             	sub    $0xc,%esp
  802d08:	ff 75 f4             	pushl  -0xc(%ebp)
  802d0b:	e8 be ee ff ff       	call   801bce <fd2data>
  802d10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d12:	83 c4 0c             	add    $0xc,%esp
  802d15:	68 07 04 00 00       	push   $0x407
  802d1a:	50                   	push   %eax
  802d1b:	6a 00                	push   $0x0
  802d1d:	e8 53 e8 ff ff       	call   801575 <sys_page_alloc>
  802d22:	89 c3                	mov    %eax,%ebx
  802d24:	83 c4 10             	add    $0x10,%esp
  802d27:	85 c0                	test   %eax,%eax
  802d29:	0f 88 89 00 00 00    	js     802db8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d2f:	83 ec 0c             	sub    $0xc,%esp
  802d32:	ff 75 f0             	pushl  -0x10(%ebp)
  802d35:	e8 94 ee ff ff       	call   801bce <fd2data>
  802d3a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d41:	50                   	push   %eax
  802d42:	6a 00                	push   $0x0
  802d44:	56                   	push   %esi
  802d45:	6a 00                	push   $0x0
  802d47:	e8 6c e8 ff ff       	call   8015b8 <sys_page_map>
  802d4c:	89 c3                	mov    %eax,%ebx
  802d4e:	83 c4 20             	add    $0x20,%esp
  802d51:	85 c0                	test   %eax,%eax
  802d53:	78 55                	js     802daa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d55:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d5e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d6a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d73:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d78:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d7f:	83 ec 0c             	sub    $0xc,%esp
  802d82:	ff 75 f4             	pushl  -0xc(%ebp)
  802d85:	e8 34 ee ff ff       	call   801bbe <fd2num>
  802d8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d8d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d8f:	83 c4 04             	add    $0x4,%esp
  802d92:	ff 75 f0             	pushl  -0x10(%ebp)
  802d95:	e8 24 ee ff ff       	call   801bbe <fd2num>
  802d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d9d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802da0:	83 c4 10             	add    $0x10,%esp
  802da3:	ba 00 00 00 00       	mov    $0x0,%edx
  802da8:	eb 30                	jmp    802dda <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802daa:	83 ec 08             	sub    $0x8,%esp
  802dad:	56                   	push   %esi
  802dae:	6a 00                	push   $0x0
  802db0:	e8 45 e8 ff ff       	call   8015fa <sys_page_unmap>
  802db5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802db8:	83 ec 08             	sub    $0x8,%esp
  802dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  802dbe:	6a 00                	push   $0x0
  802dc0:	e8 35 e8 ff ff       	call   8015fa <sys_page_unmap>
  802dc5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802dc8:	83 ec 08             	sub    $0x8,%esp
  802dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  802dce:	6a 00                	push   $0x0
  802dd0:	e8 25 e8 ff ff       	call   8015fa <sys_page_unmap>
  802dd5:	83 c4 10             	add    $0x10,%esp
  802dd8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802dda:	89 d0                	mov    %edx,%eax
  802ddc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ddf:	5b                   	pop    %ebx
  802de0:	5e                   	pop    %esi
  802de1:	5d                   	pop    %ebp
  802de2:	c3                   	ret    

00802de3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802de3:	55                   	push   %ebp
  802de4:	89 e5                	mov    %esp,%ebp
  802de6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802de9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dec:	50                   	push   %eax
  802ded:	ff 75 08             	pushl  0x8(%ebp)
  802df0:	e8 3f ee ff ff       	call   801c34 <fd_lookup>
  802df5:	89 c2                	mov    %eax,%edx
  802df7:	83 c4 10             	add    $0x10,%esp
  802dfa:	85 d2                	test   %edx,%edx
  802dfc:	78 18                	js     802e16 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802dfe:	83 ec 0c             	sub    $0xc,%esp
  802e01:	ff 75 f4             	pushl  -0xc(%ebp)
  802e04:	e8 c5 ed ff ff       	call   801bce <fd2data>
	return _pipeisclosed(fd, p);
  802e09:	89 c2                	mov    %eax,%edx
  802e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e0e:	e8 26 fd ff ff       	call   802b39 <_pipeisclosed>
  802e13:	83 c4 10             	add    $0x10,%esp
}
  802e16:	c9                   	leave  
  802e17:	c3                   	ret    

00802e18 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e18:	55                   	push   %ebp
  802e19:	89 e5                	mov    %esp,%ebp
  802e1b:	56                   	push   %esi
  802e1c:	53                   	push   %ebx
  802e1d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e20:	85 f6                	test   %esi,%esi
  802e22:	75 16                	jne    802e3a <wait+0x22>
  802e24:	68 51 3b 80 00       	push   $0x803b51
  802e29:	68 34 34 80 00       	push   $0x803434
  802e2e:	6a 09                	push   $0x9
  802e30:	68 5c 3b 80 00       	push   $0x803b5c
  802e35:	e8 df db ff ff       	call   800a19 <_panic>
	e = &envs[ENVX(envid)];
  802e3a:	89 f3                	mov    %esi,%ebx
  802e3c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e42:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e45:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e4b:	eb 05                	jmp    802e52 <wait+0x3a>
		sys_yield();
  802e4d:	e8 04 e7 ff ff       	call   801556 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e52:	8b 43 48             	mov    0x48(%ebx),%eax
  802e55:	39 f0                	cmp    %esi,%eax
  802e57:	75 07                	jne    802e60 <wait+0x48>
  802e59:	8b 43 54             	mov    0x54(%ebx),%eax
  802e5c:	85 c0                	test   %eax,%eax
  802e5e:	75 ed                	jne    802e4d <wait+0x35>
		sys_yield();
}
  802e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e63:	5b                   	pop    %ebx
  802e64:	5e                   	pop    %esi
  802e65:	5d                   	pop    %ebp
  802e66:	c3                   	ret    

00802e67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e67:	55                   	push   %ebp
  802e68:	89 e5                	mov    %esp,%ebp
  802e6a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e6d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e74:	75 2c                	jne    802ea2 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802e76:	83 ec 04             	sub    $0x4,%esp
  802e79:	6a 07                	push   $0x7
  802e7b:	68 00 f0 bf ee       	push   $0xeebff000
  802e80:	6a 00                	push   $0x0
  802e82:	e8 ee e6 ff ff       	call   801575 <sys_page_alloc>
  802e87:	83 c4 10             	add    $0x10,%esp
  802e8a:	85 c0                	test   %eax,%eax
  802e8c:	74 14                	je     802ea2 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802e8e:	83 ec 04             	sub    $0x4,%esp
  802e91:	68 68 3b 80 00       	push   $0x803b68
  802e96:	6a 21                	push   $0x21
  802e98:	68 cc 3b 80 00       	push   $0x803bcc
  802e9d:	e8 77 db ff ff       	call   800a19 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ea5:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802eaa:	83 ec 08             	sub    $0x8,%esp
  802ead:	68 d6 2e 80 00       	push   $0x802ed6
  802eb2:	6a 00                	push   $0x0
  802eb4:	e8 07 e8 ff ff       	call   8016c0 <sys_env_set_pgfault_upcall>
  802eb9:	83 c4 10             	add    $0x10,%esp
  802ebc:	85 c0                	test   %eax,%eax
  802ebe:	79 14                	jns    802ed4 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802ec0:	83 ec 04             	sub    $0x4,%esp
  802ec3:	68 94 3b 80 00       	push   $0x803b94
  802ec8:	6a 29                	push   $0x29
  802eca:	68 cc 3b 80 00       	push   $0x803bcc
  802ecf:	e8 45 db ff ff       	call   800a19 <_panic>
}
  802ed4:	c9                   	leave  
  802ed5:	c3                   	ret    

00802ed6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ed6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ed7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802edc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ede:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802ee1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802ee6:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802eea:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802eee:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802ef0:	83 c4 08             	add    $0x8,%esp
        popal
  802ef3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802ef4:	83 c4 04             	add    $0x4,%esp
        popfl
  802ef7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802ef8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802ef9:	c3                   	ret    

00802efa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802efa:	55                   	push   %ebp
  802efb:	89 e5                	mov    %esp,%ebp
  802efd:	56                   	push   %esi
  802efe:	53                   	push   %ebx
  802eff:	8b 75 08             	mov    0x8(%ebp),%esi
  802f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802f08:	85 c0                	test   %eax,%eax
  802f0a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802f0f:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802f12:	83 ec 0c             	sub    $0xc,%esp
  802f15:	50                   	push   %eax
  802f16:	e8 0a e8 ff ff       	call   801725 <sys_ipc_recv>
  802f1b:	83 c4 10             	add    $0x10,%esp
  802f1e:	85 c0                	test   %eax,%eax
  802f20:	79 16                	jns    802f38 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802f22:	85 f6                	test   %esi,%esi
  802f24:	74 06                	je     802f2c <ipc_recv+0x32>
  802f26:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802f2c:	85 db                	test   %ebx,%ebx
  802f2e:	74 2c                	je     802f5c <ipc_recv+0x62>
  802f30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802f36:	eb 24                	jmp    802f5c <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802f38:	85 f6                	test   %esi,%esi
  802f3a:	74 0a                	je     802f46 <ipc_recv+0x4c>
  802f3c:	a1 44 54 80 00       	mov    0x805444,%eax
  802f41:	8b 40 74             	mov    0x74(%eax),%eax
  802f44:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802f46:	85 db                	test   %ebx,%ebx
  802f48:	74 0a                	je     802f54 <ipc_recv+0x5a>
  802f4a:	a1 44 54 80 00       	mov    0x805444,%eax
  802f4f:	8b 40 78             	mov    0x78(%eax),%eax
  802f52:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802f54:	a1 44 54 80 00       	mov    0x805444,%eax
  802f59:	8b 40 70             	mov    0x70(%eax),%eax
}
  802f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f5f:	5b                   	pop    %ebx
  802f60:	5e                   	pop    %esi
  802f61:	5d                   	pop    %ebp
  802f62:	c3                   	ret    

00802f63 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f63:	55                   	push   %ebp
  802f64:	89 e5                	mov    %esp,%ebp
  802f66:	57                   	push   %edi
  802f67:	56                   	push   %esi
  802f68:	53                   	push   %ebx
  802f69:	83 ec 0c             	sub    $0xc,%esp
  802f6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802f75:	85 db                	test   %ebx,%ebx
  802f77:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802f7c:	0f 44 d8             	cmove  %eax,%ebx
  802f7f:	eb 1c                	jmp    802f9d <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802f81:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f84:	74 12                	je     802f98 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802f86:	50                   	push   %eax
  802f87:	68 da 3b 80 00       	push   $0x803bda
  802f8c:	6a 39                	push   $0x39
  802f8e:	68 f5 3b 80 00       	push   $0x803bf5
  802f93:	e8 81 da ff ff       	call   800a19 <_panic>
                 sys_yield();
  802f98:	e8 b9 e5 ff ff       	call   801556 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802f9d:	ff 75 14             	pushl  0x14(%ebp)
  802fa0:	53                   	push   %ebx
  802fa1:	56                   	push   %esi
  802fa2:	57                   	push   %edi
  802fa3:	e8 5a e7 ff ff       	call   801702 <sys_ipc_try_send>
  802fa8:	83 c4 10             	add    $0x10,%esp
  802fab:	85 c0                	test   %eax,%eax
  802fad:	78 d2                	js     802f81 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  802faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fb2:	5b                   	pop    %ebx
  802fb3:	5e                   	pop    %esi
  802fb4:	5f                   	pop    %edi
  802fb5:	5d                   	pop    %ebp
  802fb6:	c3                   	ret    

00802fb7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fb7:	55                   	push   %ebp
  802fb8:	89 e5                	mov    %esp,%ebp
  802fba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fbd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802fc2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802fc5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802fcb:	8b 52 50             	mov    0x50(%edx),%edx
  802fce:	39 ca                	cmp    %ecx,%edx
  802fd0:	75 0d                	jne    802fdf <ipc_find_env+0x28>
			return envs[i].env_id;
  802fd2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fd5:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802fda:	8b 40 08             	mov    0x8(%eax),%eax
  802fdd:	eb 0e                	jmp    802fed <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fdf:	83 c0 01             	add    $0x1,%eax
  802fe2:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fe7:	75 d9                	jne    802fc2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802fe9:	66 b8 00 00          	mov    $0x0,%ax
}
  802fed:	5d                   	pop    %ebp
  802fee:	c3                   	ret    

00802fef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fef:	55                   	push   %ebp
  802ff0:	89 e5                	mov    %esp,%ebp
  802ff2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ff5:	89 d0                	mov    %edx,%eax
  802ff7:	c1 e8 16             	shr    $0x16,%eax
  802ffa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803001:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803006:	f6 c1 01             	test   $0x1,%cl
  803009:	74 1d                	je     803028 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80300b:	c1 ea 0c             	shr    $0xc,%edx
  80300e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803015:	f6 c2 01             	test   $0x1,%dl
  803018:	74 0e                	je     803028 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80301a:	c1 ea 0c             	shr    $0xc,%edx
  80301d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803024:	ef 
  803025:	0f b7 c0             	movzwl %ax,%eax
}
  803028:	5d                   	pop    %ebp
  803029:	c3                   	ret    
  80302a:	66 90                	xchg   %ax,%ax
  80302c:	66 90                	xchg   %ax,%ax
  80302e:	66 90                	xchg   %ax,%ax

00803030 <__udivdi3>:
  803030:	55                   	push   %ebp
  803031:	57                   	push   %edi
  803032:	56                   	push   %esi
  803033:	83 ec 10             	sub    $0x10,%esp
  803036:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80303a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80303e:	8b 74 24 24          	mov    0x24(%esp),%esi
  803042:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  803046:	85 d2                	test   %edx,%edx
  803048:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80304c:	89 34 24             	mov    %esi,(%esp)
  80304f:	89 c8                	mov    %ecx,%eax
  803051:	75 35                	jne    803088 <__udivdi3+0x58>
  803053:	39 f1                	cmp    %esi,%ecx
  803055:	0f 87 bd 00 00 00    	ja     803118 <__udivdi3+0xe8>
  80305b:	85 c9                	test   %ecx,%ecx
  80305d:	89 cd                	mov    %ecx,%ebp
  80305f:	75 0b                	jne    80306c <__udivdi3+0x3c>
  803061:	b8 01 00 00 00       	mov    $0x1,%eax
  803066:	31 d2                	xor    %edx,%edx
  803068:	f7 f1                	div    %ecx
  80306a:	89 c5                	mov    %eax,%ebp
  80306c:	89 f0                	mov    %esi,%eax
  80306e:	31 d2                	xor    %edx,%edx
  803070:	f7 f5                	div    %ebp
  803072:	89 c6                	mov    %eax,%esi
  803074:	89 f8                	mov    %edi,%eax
  803076:	f7 f5                	div    %ebp
  803078:	89 f2                	mov    %esi,%edx
  80307a:	83 c4 10             	add    $0x10,%esp
  80307d:	5e                   	pop    %esi
  80307e:	5f                   	pop    %edi
  80307f:	5d                   	pop    %ebp
  803080:	c3                   	ret    
  803081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803088:	3b 14 24             	cmp    (%esp),%edx
  80308b:	77 7b                	ja     803108 <__udivdi3+0xd8>
  80308d:	0f bd f2             	bsr    %edx,%esi
  803090:	83 f6 1f             	xor    $0x1f,%esi
  803093:	0f 84 97 00 00 00    	je     803130 <__udivdi3+0x100>
  803099:	bd 20 00 00 00       	mov    $0x20,%ebp
  80309e:	89 d7                	mov    %edx,%edi
  8030a0:	89 f1                	mov    %esi,%ecx
  8030a2:	29 f5                	sub    %esi,%ebp
  8030a4:	d3 e7                	shl    %cl,%edi
  8030a6:	89 c2                	mov    %eax,%edx
  8030a8:	89 e9                	mov    %ebp,%ecx
  8030aa:	d3 ea                	shr    %cl,%edx
  8030ac:	89 f1                	mov    %esi,%ecx
  8030ae:	09 fa                	or     %edi,%edx
  8030b0:	8b 3c 24             	mov    (%esp),%edi
  8030b3:	d3 e0                	shl    %cl,%eax
  8030b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8030b9:	89 e9                	mov    %ebp,%ecx
  8030bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8030c3:	89 fa                	mov    %edi,%edx
  8030c5:	d3 ea                	shr    %cl,%edx
  8030c7:	89 f1                	mov    %esi,%ecx
  8030c9:	d3 e7                	shl    %cl,%edi
  8030cb:	89 e9                	mov    %ebp,%ecx
  8030cd:	d3 e8                	shr    %cl,%eax
  8030cf:	09 c7                	or     %eax,%edi
  8030d1:	89 f8                	mov    %edi,%eax
  8030d3:	f7 74 24 08          	divl   0x8(%esp)
  8030d7:	89 d5                	mov    %edx,%ebp
  8030d9:	89 c7                	mov    %eax,%edi
  8030db:	f7 64 24 0c          	mull   0xc(%esp)
  8030df:	39 d5                	cmp    %edx,%ebp
  8030e1:	89 14 24             	mov    %edx,(%esp)
  8030e4:	72 11                	jb     8030f7 <__udivdi3+0xc7>
  8030e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8030ea:	89 f1                	mov    %esi,%ecx
  8030ec:	d3 e2                	shl    %cl,%edx
  8030ee:	39 c2                	cmp    %eax,%edx
  8030f0:	73 5e                	jae    803150 <__udivdi3+0x120>
  8030f2:	3b 2c 24             	cmp    (%esp),%ebp
  8030f5:	75 59                	jne    803150 <__udivdi3+0x120>
  8030f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8030fa:	31 f6                	xor    %esi,%esi
  8030fc:	89 f2                	mov    %esi,%edx
  8030fe:	83 c4 10             	add    $0x10,%esp
  803101:	5e                   	pop    %esi
  803102:	5f                   	pop    %edi
  803103:	5d                   	pop    %ebp
  803104:	c3                   	ret    
  803105:	8d 76 00             	lea    0x0(%esi),%esi
  803108:	31 f6                	xor    %esi,%esi
  80310a:	31 c0                	xor    %eax,%eax
  80310c:	89 f2                	mov    %esi,%edx
  80310e:	83 c4 10             	add    $0x10,%esp
  803111:	5e                   	pop    %esi
  803112:	5f                   	pop    %edi
  803113:	5d                   	pop    %ebp
  803114:	c3                   	ret    
  803115:	8d 76 00             	lea    0x0(%esi),%esi
  803118:	89 f2                	mov    %esi,%edx
  80311a:	31 f6                	xor    %esi,%esi
  80311c:	89 f8                	mov    %edi,%eax
  80311e:	f7 f1                	div    %ecx
  803120:	89 f2                	mov    %esi,%edx
  803122:	83 c4 10             	add    $0x10,%esp
  803125:	5e                   	pop    %esi
  803126:	5f                   	pop    %edi
  803127:	5d                   	pop    %ebp
  803128:	c3                   	ret    
  803129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803130:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803134:	76 0b                	jbe    803141 <__udivdi3+0x111>
  803136:	31 c0                	xor    %eax,%eax
  803138:	3b 14 24             	cmp    (%esp),%edx
  80313b:	0f 83 37 ff ff ff    	jae    803078 <__udivdi3+0x48>
  803141:	b8 01 00 00 00       	mov    $0x1,%eax
  803146:	e9 2d ff ff ff       	jmp    803078 <__udivdi3+0x48>
  80314b:	90                   	nop
  80314c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803150:	89 f8                	mov    %edi,%eax
  803152:	31 f6                	xor    %esi,%esi
  803154:	e9 1f ff ff ff       	jmp    803078 <__udivdi3+0x48>
  803159:	66 90                	xchg   %ax,%ax
  80315b:	66 90                	xchg   %ax,%ax
  80315d:	66 90                	xchg   %ax,%ax
  80315f:	90                   	nop

00803160 <__umoddi3>:
  803160:	55                   	push   %ebp
  803161:	57                   	push   %edi
  803162:	56                   	push   %esi
  803163:	83 ec 20             	sub    $0x20,%esp
  803166:	8b 44 24 34          	mov    0x34(%esp),%eax
  80316a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80316e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803172:	89 c6                	mov    %eax,%esi
  803174:	89 44 24 10          	mov    %eax,0x10(%esp)
  803178:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80317c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  803180:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803184:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803188:	89 74 24 18          	mov    %esi,0x18(%esp)
  80318c:	85 c0                	test   %eax,%eax
  80318e:	89 c2                	mov    %eax,%edx
  803190:	75 1e                	jne    8031b0 <__umoddi3+0x50>
  803192:	39 f7                	cmp    %esi,%edi
  803194:	76 52                	jbe    8031e8 <__umoddi3+0x88>
  803196:	89 c8                	mov    %ecx,%eax
  803198:	89 f2                	mov    %esi,%edx
  80319a:	f7 f7                	div    %edi
  80319c:	89 d0                	mov    %edx,%eax
  80319e:	31 d2                	xor    %edx,%edx
  8031a0:	83 c4 20             	add    $0x20,%esp
  8031a3:	5e                   	pop    %esi
  8031a4:	5f                   	pop    %edi
  8031a5:	5d                   	pop    %ebp
  8031a6:	c3                   	ret    
  8031a7:	89 f6                	mov    %esi,%esi
  8031a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8031b0:	39 f0                	cmp    %esi,%eax
  8031b2:	77 5c                	ja     803210 <__umoddi3+0xb0>
  8031b4:	0f bd e8             	bsr    %eax,%ebp
  8031b7:	83 f5 1f             	xor    $0x1f,%ebp
  8031ba:	75 64                	jne    803220 <__umoddi3+0xc0>
  8031bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8031c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8031c4:	0f 86 f6 00 00 00    	jbe    8032c0 <__umoddi3+0x160>
  8031ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8031ce:	0f 82 ec 00 00 00    	jb     8032c0 <__umoddi3+0x160>
  8031d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8031d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8031dc:	83 c4 20             	add    $0x20,%esp
  8031df:	5e                   	pop    %esi
  8031e0:	5f                   	pop    %edi
  8031e1:	5d                   	pop    %ebp
  8031e2:	c3                   	ret    
  8031e3:	90                   	nop
  8031e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031e8:	85 ff                	test   %edi,%edi
  8031ea:	89 fd                	mov    %edi,%ebp
  8031ec:	75 0b                	jne    8031f9 <__umoddi3+0x99>
  8031ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8031f3:	31 d2                	xor    %edx,%edx
  8031f5:	f7 f7                	div    %edi
  8031f7:	89 c5                	mov    %eax,%ebp
  8031f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8031fd:	31 d2                	xor    %edx,%edx
  8031ff:	f7 f5                	div    %ebp
  803201:	89 c8                	mov    %ecx,%eax
  803203:	f7 f5                	div    %ebp
  803205:	eb 95                	jmp    80319c <__umoddi3+0x3c>
  803207:	89 f6                	mov    %esi,%esi
  803209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803210:	89 c8                	mov    %ecx,%eax
  803212:	89 f2                	mov    %esi,%edx
  803214:	83 c4 20             	add    $0x20,%esp
  803217:	5e                   	pop    %esi
  803218:	5f                   	pop    %edi
  803219:	5d                   	pop    %ebp
  80321a:	c3                   	ret    
  80321b:	90                   	nop
  80321c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803220:	b8 20 00 00 00       	mov    $0x20,%eax
  803225:	89 e9                	mov    %ebp,%ecx
  803227:	29 e8                	sub    %ebp,%eax
  803229:	d3 e2                	shl    %cl,%edx
  80322b:	89 c7                	mov    %eax,%edi
  80322d:	89 44 24 18          	mov    %eax,0x18(%esp)
  803231:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803235:	89 f9                	mov    %edi,%ecx
  803237:	d3 e8                	shr    %cl,%eax
  803239:	89 c1                	mov    %eax,%ecx
  80323b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80323f:	09 d1                	or     %edx,%ecx
  803241:	89 fa                	mov    %edi,%edx
  803243:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803247:	89 e9                	mov    %ebp,%ecx
  803249:	d3 e0                	shl    %cl,%eax
  80324b:	89 f9                	mov    %edi,%ecx
  80324d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803251:	89 f0                	mov    %esi,%eax
  803253:	d3 e8                	shr    %cl,%eax
  803255:	89 e9                	mov    %ebp,%ecx
  803257:	89 c7                	mov    %eax,%edi
  803259:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80325d:	d3 e6                	shl    %cl,%esi
  80325f:	89 d1                	mov    %edx,%ecx
  803261:	89 fa                	mov    %edi,%edx
  803263:	d3 e8                	shr    %cl,%eax
  803265:	89 e9                	mov    %ebp,%ecx
  803267:	09 f0                	or     %esi,%eax
  803269:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80326d:	f7 74 24 10          	divl   0x10(%esp)
  803271:	d3 e6                	shl    %cl,%esi
  803273:	89 d1                	mov    %edx,%ecx
  803275:	f7 64 24 0c          	mull   0xc(%esp)
  803279:	39 d1                	cmp    %edx,%ecx
  80327b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80327f:	89 d7                	mov    %edx,%edi
  803281:	89 c6                	mov    %eax,%esi
  803283:	72 0a                	jb     80328f <__umoddi3+0x12f>
  803285:	39 44 24 14          	cmp    %eax,0x14(%esp)
  803289:	73 10                	jae    80329b <__umoddi3+0x13b>
  80328b:	39 d1                	cmp    %edx,%ecx
  80328d:	75 0c                	jne    80329b <__umoddi3+0x13b>
  80328f:	89 d7                	mov    %edx,%edi
  803291:	89 c6                	mov    %eax,%esi
  803293:	2b 74 24 0c          	sub    0xc(%esp),%esi
  803297:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80329b:	89 ca                	mov    %ecx,%edx
  80329d:	89 e9                	mov    %ebp,%ecx
  80329f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8032a3:	29 f0                	sub    %esi,%eax
  8032a5:	19 fa                	sbb    %edi,%edx
  8032a7:	d3 e8                	shr    %cl,%eax
  8032a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8032ae:	89 d7                	mov    %edx,%edi
  8032b0:	d3 e7                	shl    %cl,%edi
  8032b2:	89 e9                	mov    %ebp,%ecx
  8032b4:	09 f8                	or     %edi,%eax
  8032b6:	d3 ea                	shr    %cl,%edx
  8032b8:	83 c4 20             	add    $0x20,%esp
  8032bb:	5e                   	pop    %esi
  8032bc:	5f                   	pop    %edi
  8032bd:	5d                   	pop    %ebp
  8032be:	c3                   	ret    
  8032bf:	90                   	nop
  8032c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8032c4:	29 f9                	sub    %edi,%ecx
  8032c6:	19 c6                	sbb    %eax,%esi
  8032c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8032cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8032d0:	e9 ff fe ff ff       	jmp    8031d4 <__umoddi3+0x74>
