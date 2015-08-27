
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d f0 41 80 00 00 	cmpl   $0x0,0x8041f0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 02 28 80 00       	push   $0x802802
  80005f:	e8 3f 1a 00 00       	call   801aa3 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 28 80 00       	mov    $0x802868,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 cd 08 00 00       	call   80094b <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 68 28 80 00       	mov    $0x802868,%edx
  80008b:	b8 00 28 80 00       	mov    $0x802800,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 28 80 00       	push   $0x80280b
  80009d:	e8 01 1a 00 00       	call   801aa3 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 b9 2c 80 00       	push   $0x802cb9
  8000b0:	e8 ee 19 00 00       	call   801aa3 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	89 f0                	mov    %esi,%eax
  8000ba:	84 c0                	test   %al,%al
  8000bc:	74 19                	je     8000d7 <ls1+0xa4>
  8000be:	83 3d 58 41 80 00 00 	cmpl   $0x0,0x804158
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 28 80 00       	push   $0x802800
  8000cf:	e8 cf 19 00 00       	call   801aa3 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 28 80 00       	push   $0x802867
  8000df:	e8 bf 19 00 00       	call   801aa3 <printf>
  8000e4:	83 c4 10             	add    $0x10,%esp
}
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 00 18 00 00       	call   801905 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 28 80 00       	push   $0x802810
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 28 80 00       	push   $0x80281c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 85 13 00 00       	call   8014e9 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 26 28 80 00       	push   $0x802826
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 28 80 00       	push   $0x80281c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 28 80 00       	push   $0x80286c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 28 80 00       	push   $0x80281c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 2a 15 00 00       	call   8016ea <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 28 80 00       	push   $0x802841
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 28 80 00       	push   $0x80281c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 4d 28 80 00       	push   $0x80284d
  800225:	e8 79 18 00 00       	call   801aa3 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
  80022f:	83 c4 10             	add    $0x10,%esp
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 d2 0d 00 00       	call   80101f <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 40 40 80 00 	addl   $0x1,0x804040(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 d3 0d 00 00       	call   80104f <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 68 28 80 00       	push   $0x802868
  800296:	68 00 28 80 00       	push   $0x802800
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8002cf:	e8 7b 0a 00 00       	call   800d4f <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 40 44 80 00       	mov    %eax,0x804440

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
  800300:	83 c4 10             	add    $0x10,%esp
}
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 30 10 00 00       	call   801345 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 ef 09 00 00       	call   800d0e <sys_env_destroy>
  80031f:	83 c4 10             	add    $0x10,%esp
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 18 0a 00 00       	call   800d4f <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 98 28 80 00       	push   $0x802898
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 37 09 00 00       	call   800cd1 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 4f 01 00 00       	call   80052f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 dc 08 00 00       	call   800cd1 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 d1                	mov    %edx,%ecx
  800426:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800429:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80042c:	8b 45 10             	mov    0x10(%ebp),%eax
  80042f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80043c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80043f:	72 05                	jb     800446 <printnum+0x35>
  800441:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800444:	77 3e                	ja     800484 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800446:	83 ec 0c             	sub    $0xc,%esp
  800449:	ff 75 18             	pushl  0x18(%ebp)
  80044c:	83 eb 01             	sub    $0x1,%ebx
  80044f:	53                   	push   %ebx
  800450:	50                   	push   %eax
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 db 20 00 00       	call   802540 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 13                	jmp    80048b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800484:	83 eb 01             	sub    $0x1,%ebx
  800487:	85 db                	test   %ebx,%ebx
  800489:	7f ed                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	56                   	push   %esi
  80048f:	83 ec 04             	sub    $0x4,%esp
  800492:	ff 75 e4             	pushl  -0x1c(%ebp)
  800495:	ff 75 e0             	pushl  -0x20(%ebp)
  800498:	ff 75 dc             	pushl  -0x24(%ebp)
  80049b:	ff 75 d8             	pushl  -0x28(%ebp)
  80049e:	e8 cd 21 00 00       	call   802670 <__umoddi3>
  8004a3:	83 c4 14             	add    $0x14,%esp
  8004a6:	0f be 80 bb 28 80 00 	movsbl 0x8028bb(%eax),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff d7                	call   *%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
}
  8004b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b6:	5b                   	pop    %ebx
  8004b7:	5e                   	pop    %esi
  8004b8:	5f                   	pop    %edi
  8004b9:	5d                   	pop    %ebp
  8004ba:	c3                   	ret    

008004bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004be:	83 fa 01             	cmp    $0x1,%edx
  8004c1:	7e 0e                	jle    8004d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	8b 52 04             	mov    0x4(%edx),%edx
  8004cf:	eb 22                	jmp    8004f3 <getuint+0x38>
	else if (lflag)
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 10                	je     8004e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d5:	8b 10                	mov    (%eax),%edx
  8004d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 02                	mov    (%edx),%eax
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e3:	eb 0e                	jmp    8004f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ea:	89 08                	mov    %ecx,(%eax)
  8004ec:	8b 02                	mov    (%edx),%eax
  8004ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	3b 50 04             	cmp    0x4(%eax),%edx
  800504:	73 0a                	jae    800510 <sprintputch+0x1b>
		*b->buf++ = ch;
  800506:	8d 4a 01             	lea    0x1(%edx),%ecx
  800509:	89 08                	mov    %ecx,(%eax)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	88 02                	mov    %al,(%edx)
}
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800518:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051b:	50                   	push   %eax
  80051c:	ff 75 10             	pushl  0x10(%ebp)
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	ff 75 08             	pushl  0x8(%ebp)
  800525:	e8 05 00 00 00       	call   80052f <vprintfmt>
	va_end(ap);
  80052a:	83 c4 10             	add    $0x10,%esp
}
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 2c             	sub    $0x2c,%esp
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800541:	eb 12                	jmp    800555 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800543:	85 c0                	test   %eax,%eax
  800545:	0f 84 90 03 00 00    	je     8008db <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	50                   	push   %eax
  800550:	ff d6                	call   *%esi
  800552:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800555:	83 c7 01             	add    $0x1,%edi
  800558:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055c:	83 f8 25             	cmp    $0x25,%eax
  80055f:	75 e2                	jne    800543 <vprintfmt+0x14>
  800561:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800565:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80056c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800573:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057a:	ba 00 00 00 00       	mov    $0x0,%edx
  80057f:	eb 07                	jmp    800588 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800584:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8d 47 01             	lea    0x1(%edi),%eax
  80058b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058e:	0f b6 07             	movzbl (%edi),%eax
  800591:	0f b6 c8             	movzbl %al,%ecx
  800594:	83 e8 23             	sub    $0x23,%eax
  800597:	3c 55                	cmp    $0x55,%al
  800599:	0f 87 21 03 00 00    	ja     8008c0 <vprintfmt+0x391>
  80059f:	0f b6 c0             	movzbl %al,%eax
  8005a2:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b0:	eb d6                	jmp    800588 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ca:	83 fa 09             	cmp    $0x9,%edx
  8005cd:	77 39                	ja     800608 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d2:	eb e9                	jmp    8005bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8005da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e5:	eb 27                	jmp    80060e <vprintfmt+0xdf>
  8005e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f1:	0f 49 c8             	cmovns %eax,%ecx
  8005f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fa:	eb 8c                	jmp    800588 <vprintfmt+0x59>
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800606:	eb 80                	jmp    800588 <vprintfmt+0x59>
  800608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80060e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800612:	0f 89 70 ff ff ff    	jns    800588 <vprintfmt+0x59>
				width = precision, precision = -1;
  800618:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800625:	e9 5e ff ff ff       	jmp    800588 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800630:	e9 53 ff ff ff       	jmp    800588 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 04             	lea    0x4(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	ff 30                	pushl  (%eax)
  800644:	ff d6                	call   *%esi
			break;
  800646:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80064c:	e9 04 ff ff ff       	jmp    800555 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	99                   	cltd   
  80065d:	31 d0                	xor    %edx,%eax
  80065f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800661:	83 f8 0f             	cmp    $0xf,%eax
  800664:	7f 0b                	jg     800671 <vprintfmt+0x142>
  800666:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  80066d:	85 d2                	test   %edx,%edx
  80066f:	75 18                	jne    800689 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800671:	50                   	push   %eax
  800672:	68 d3 28 80 00       	push   $0x8028d3
  800677:	53                   	push   %ebx
  800678:	56                   	push   %esi
  800679:	e8 94 fe ff ff       	call   800512 <printfmt>
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800684:	e9 cc fe ff ff       	jmp    800555 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800689:	52                   	push   %edx
  80068a:	68 b9 2c 80 00       	push   $0x802cb9
  80068f:	53                   	push   %ebx
  800690:	56                   	push   %esi
  800691:	e8 7c fe ff ff       	call   800512 <printfmt>
  800696:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	e9 b4 fe ff ff       	jmp    800555 <vprintfmt+0x26>
  8006a1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	ba cc 28 80 00       	mov    $0x8028cc,%edx
  8006bc:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006bf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c3:	0f 84 92 00 00 00    	je     80075b <vprintfmt+0x22c>
  8006c9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006cd:	0f 8e 96 00 00 00    	jle    800769 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	51                   	push   %ecx
  8006d7:	57                   	push   %edi
  8006d8:	e8 86 02 00 00       	call   800963 <strnlen>
  8006dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e0:	29 c1                	sub    %eax,%ecx
  8006e2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ef:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	eb 0f                	jmp    800705 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	85 ff                	test   %edi,%edi
  800707:	7f ed                	jg     8006f6 <vprintfmt+0x1c7>
  800709:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	b8 00 00 00 00       	mov    $0x0,%eax
  800716:	0f 49 c1             	cmovns %ecx,%eax
  800719:	29 c1                	sub    %eax,%ecx
  80071b:	89 75 08             	mov    %esi,0x8(%ebp)
  80071e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800721:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800724:	89 cb                	mov    %ecx,%ebx
  800726:	eb 4d                	jmp    800775 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800728:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072c:	74 1b                	je     800749 <vprintfmt+0x21a>
  80072e:	0f be c0             	movsbl %al,%eax
  800731:	83 e8 20             	sub    $0x20,%eax
  800734:	83 f8 5e             	cmp    $0x5e,%eax
  800737:	76 10                	jbe    800749 <vprintfmt+0x21a>
					putch('?', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	6a 3f                	push   $0x3f
  800741:	ff 55 08             	call   *0x8(%ebp)
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 0d                	jmp    800756 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	52                   	push   %edx
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	eb 1a                	jmp    800775 <vprintfmt+0x246>
  80075b:	89 75 08             	mov    %esi,0x8(%ebp)
  80075e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800761:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800764:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800767:	eb 0c                	jmp    800775 <vprintfmt+0x246>
  800769:	89 75 08             	mov    %esi,0x8(%ebp)
  80076c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800772:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800775:	83 c7 01             	add    $0x1,%edi
  800778:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077c:	0f be d0             	movsbl %al,%edx
  80077f:	85 d2                	test   %edx,%edx
  800781:	74 23                	je     8007a6 <vprintfmt+0x277>
  800783:	85 f6                	test   %esi,%esi
  800785:	78 a1                	js     800728 <vprintfmt+0x1f9>
  800787:	83 ee 01             	sub    $0x1,%esi
  80078a:	79 9c                	jns    800728 <vprintfmt+0x1f9>
  80078c:	89 df                	mov    %ebx,%edi
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800794:	eb 18                	jmp    8007ae <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	6a 20                	push   $0x20
  80079c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079e:	83 ef 01             	sub    $0x1,%edi
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	eb 08                	jmp    8007ae <vprintfmt+0x27f>
  8007a6:	89 df                	mov    %ebx,%edi
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ae:	85 ff                	test   %edi,%edi
  8007b0:	7f e4                	jg     800796 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 9b fd ff ff       	jmp    800555 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ba:	83 fa 01             	cmp    $0x1,%edx
  8007bd:	7e 16                	jle    8007d5 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 08             	lea    0x8(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 50 04             	mov    0x4(%eax),%edx
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d3:	eb 32                	jmp    800807 <vprintfmt+0x2d8>
	else if (lflag)
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 18                	je     8007f1 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e7:	89 c1                	mov    %eax,%ecx
  8007e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ef:	eb 16                	jmp    800807 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ff:	89 c1                	mov    %eax,%ecx
  800801:	c1 f9 1f             	sar    $0x1f,%ecx
  800804:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800807:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800812:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800816:	79 74                	jns    80088c <vprintfmt+0x35d>
				putch('-', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 2d                	push   $0x2d
  80081e:	ff d6                	call   *%esi
				num = -(long long) num;
  800820:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800823:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800826:	f7 d8                	neg    %eax
  800828:	83 d2 00             	adc    $0x0,%edx
  80082b:	f7 da                	neg    %edx
  80082d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800830:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800835:	eb 55                	jmp    80088c <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
  80083a:	e8 7c fc ff ff       	call   8004bb <getuint>
			base = 10;
  80083f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800844:	eb 46                	jmp    80088c <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 6d fc ff ff       	call   8004bb <getuint>
                        base = 8;
  80084e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800853:	eb 37                	jmp    80088c <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	53                   	push   %ebx
  800859:	6a 30                	push   $0x30
  80085b:	ff d6                	call   *%esi
			putch('x', putdat);
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 78                	push   $0x78
  800863:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8d 50 04             	lea    0x4(%eax),%edx
  80086b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086e:	8b 00                	mov    (%eax),%eax
  800870:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800875:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800878:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087d:	eb 0d                	jmp    80088c <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
  800882:	e8 34 fc ff ff       	call   8004bb <getuint>
			base = 16;
  800887:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088c:	83 ec 0c             	sub    $0xc,%esp
  80088f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800893:	57                   	push   %edi
  800894:	ff 75 e0             	pushl  -0x20(%ebp)
  800897:	51                   	push   %ecx
  800898:	52                   	push   %edx
  800899:	50                   	push   %eax
  80089a:	89 da                	mov    %ebx,%edx
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	e8 6e fb ff ff       	call   800411 <printnum>
			break;
  8008a3:	83 c4 20             	add    $0x20,%esp
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a9:	e9 a7 fc ff ff       	jmp    800555 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	51                   	push   %ecx
  8008b3:	ff d6                	call   *%esi
			break;
  8008b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bb:	e9 95 fc ff ff       	jmp    800555 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c0:	83 ec 08             	sub    $0x8,%esp
  8008c3:	53                   	push   %ebx
  8008c4:	6a 25                	push   $0x25
  8008c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	eb 03                	jmp    8008d0 <vprintfmt+0x3a1>
  8008cd:	83 ef 01             	sub    $0x1,%edi
  8008d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d4:	75 f7                	jne    8008cd <vprintfmt+0x39e>
  8008d6:	e9 7a fc ff ff       	jmp    800555 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 18             	sub    $0x18,%esp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800900:	85 c0                	test   %eax,%eax
  800902:	74 26                	je     80092a <vsnprintf+0x47>
  800904:	85 d2                	test   %edx,%edx
  800906:	7e 22                	jle    80092a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800908:	ff 75 14             	pushl  0x14(%ebp)
  80090b:	ff 75 10             	pushl  0x10(%ebp)
  80090e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800911:	50                   	push   %eax
  800912:	68 f5 04 80 00       	push   $0x8004f5
  800917:	e8 13 fc ff ff       	call   80052f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	eb 05                	jmp    80092f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80092a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800937:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093a:	50                   	push   %eax
  80093b:	ff 75 10             	pushl  0x10(%ebp)
  80093e:	ff 75 0c             	pushl  0xc(%ebp)
  800941:	ff 75 08             	pushl  0x8(%ebp)
  800944:	e8 9a ff ff ff       	call   8008e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 03                	jmp    80095b <strlen+0x10>
		n++;
  800958:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80095b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095f:	75 f7                	jne    800958 <strlen+0xd>
		n++;
	return n;
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800969:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096c:	ba 00 00 00 00       	mov    $0x0,%edx
  800971:	eb 03                	jmp    800976 <strnlen+0x13>
		n++;
  800973:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800976:	39 c2                	cmp    %eax,%edx
  800978:	74 08                	je     800982 <strnlen+0x1f>
  80097a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097e:	75 f3                	jne    800973 <strnlen+0x10>
  800980:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098e:	89 c2                	mov    %eax,%edx
  800990:	83 c2 01             	add    $0x1,%edx
  800993:	83 c1 01             	add    $0x1,%ecx
  800996:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80099a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099d:	84 db                	test   %bl,%bl
  80099f:	75 ef                	jne    800990 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	53                   	push   %ebx
  8009a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ab:	53                   	push   %ebx
  8009ac:	e8 9a ff ff ff       	call   80094b <strlen>
  8009b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b4:	ff 75 0c             	pushl  0xc(%ebp)
  8009b7:	01 d8                	add    %ebx,%eax
  8009b9:	50                   	push   %eax
  8009ba:	e8 c5 ff ff ff       	call   800984 <strcpy>
	return dst;
}
  8009bf:	89 d8                	mov    %ebx,%eax
  8009c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d1:	89 f3                	mov    %esi,%ebx
  8009d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d6:	89 f2                	mov    %esi,%edx
  8009d8:	eb 0f                	jmp    8009e9 <strncpy+0x23>
		*dst++ = *src;
  8009da:	83 c2 01             	add    $0x1,%edx
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e9:	39 da                	cmp    %ebx,%edx
  8009eb:	75 ed                	jne    8009da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ed:	89 f0                	mov    %esi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fe:	8b 55 10             	mov    0x10(%ebp),%edx
  800a01:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a03:	85 d2                	test   %edx,%edx
  800a05:	74 21                	je     800a28 <strlcpy+0x35>
  800a07:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	eb 09                	jmp    800a18 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0f:	83 c2 01             	add    $0x1,%edx
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a18:	39 c2                	cmp    %eax,%edx
  800a1a:	74 09                	je     800a25 <strlcpy+0x32>
  800a1c:	0f b6 19             	movzbl (%ecx),%ebx
  800a1f:	84 db                	test   %bl,%bl
  800a21:	75 ec                	jne    800a0f <strlcpy+0x1c>
  800a23:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a25:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a28:	29 f0                	sub    %esi,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a37:	eb 06                	jmp    800a3f <strcmp+0x11>
		p++, q++;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3f:	0f b6 01             	movzbl (%ecx),%eax
  800a42:	84 c0                	test   %al,%al
  800a44:	74 04                	je     800a4a <strcmp+0x1c>
  800a46:	3a 02                	cmp    (%edx),%al
  800a48:	74 ef                	je     800a39 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4a:	0f b6 c0             	movzbl %al,%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5e:	89 c3                	mov    %eax,%ebx
  800a60:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a63:	eb 06                	jmp    800a6b <strncmp+0x17>
		n--, p++, q++;
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6b:	39 d8                	cmp    %ebx,%eax
  800a6d:	74 15                	je     800a84 <strncmp+0x30>
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	84 c9                	test   %cl,%cl
  800a74:	74 04                	je     800a7a <strncmp+0x26>
  800a76:	3a 0a                	cmp    (%edx),%cl
  800a78:	74 eb                	je     800a65 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7a:	0f b6 00             	movzbl (%eax),%eax
  800a7d:	0f b6 12             	movzbl (%edx),%edx
  800a80:	29 d0                	sub    %edx,%eax
  800a82:	eb 05                	jmp    800a89 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a96:	eb 07                	jmp    800a9f <strchr+0x13>
		if (*s == c)
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 0f                	je     800aab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	0f b6 10             	movzbl (%eax),%edx
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	75 f2                	jne    800a98 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab7:	eb 03                	jmp    800abc <strfind+0xf>
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abf:	84 d2                	test   %dl,%dl
  800ac1:	74 04                	je     800ac7 <strfind+0x1a>
  800ac3:	38 ca                	cmp    %cl,%dl
  800ac5:	75 f2                	jne    800ab9 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad5:	85 c9                	test   %ecx,%ecx
  800ad7:	74 36                	je     800b0f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adf:	75 28                	jne    800b09 <memset+0x40>
  800ae1:	f6 c1 03             	test   $0x3,%cl
  800ae4:	75 23                	jne    800b09 <memset+0x40>
		c &= 0xFF;
  800ae6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	c1 e3 08             	shl    $0x8,%ebx
  800aef:	89 d6                	mov    %edx,%esi
  800af1:	c1 e6 18             	shl    $0x18,%esi
  800af4:	89 d0                	mov    %edx,%eax
  800af6:	c1 e0 10             	shl    $0x10,%eax
  800af9:	09 f0                	or     %esi,%eax
  800afb:	09 c2                	or     %eax,%edx
  800afd:	89 d0                	mov    %edx,%eax
  800aff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b01:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b04:	fc                   	cld    
  800b05:	f3 ab                	rep stos %eax,%es:(%edi)
  800b07:	eb 06                	jmp    800b0f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	fc                   	cld    
  800b0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0f:	89 f8                	mov    %edi,%eax
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b24:	39 c6                	cmp    %eax,%esi
  800b26:	73 35                	jae    800b5d <memmove+0x47>
  800b28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	73 2e                	jae    800b5d <memmove+0x47>
		s += n;
		d += n;
  800b2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3c:	75 13                	jne    800b51 <memmove+0x3b>
  800b3e:	f6 c1 03             	test   $0x3,%cl
  800b41:	75 0e                	jne    800b51 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b43:	83 ef 04             	sub    $0x4,%edi
  800b46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b49:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4c:	fd                   	std    
  800b4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4f:	eb 09                	jmp    800b5a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b51:	83 ef 01             	sub    $0x1,%edi
  800b54:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b57:	fd                   	std    
  800b58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5a:	fc                   	cld    
  800b5b:	eb 1d                	jmp    800b7a <memmove+0x64>
  800b5d:	89 f2                	mov    %esi,%edx
  800b5f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b61:	f6 c2 03             	test   $0x3,%dl
  800b64:	75 0f                	jne    800b75 <memmove+0x5f>
  800b66:	f6 c1 03             	test   $0x3,%cl
  800b69:	75 0a                	jne    800b75 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b6e:	89 c7                	mov    %eax,%edi
  800b70:	fc                   	cld    
  800b71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b73:	eb 05                	jmp    800b7a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	fc                   	cld    
  800b78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b81:	ff 75 10             	pushl  0x10(%ebp)
  800b84:	ff 75 0c             	pushl  0xc(%ebp)
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 87 ff ff ff       	call   800b16 <memmove>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9c:	89 c6                	mov    %eax,%esi
  800b9e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba1:	eb 1a                	jmp    800bbd <memcmp+0x2c>
		if (*s1 != *s2)
  800ba3:	0f b6 08             	movzbl (%eax),%ecx
  800ba6:	0f b6 1a             	movzbl (%edx),%ebx
  800ba9:	38 d9                	cmp    %bl,%cl
  800bab:	74 0a                	je     800bb7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bad:	0f b6 c1             	movzbl %cl,%eax
  800bb0:	0f b6 db             	movzbl %bl,%ebx
  800bb3:	29 d8                	sub    %ebx,%eax
  800bb5:	eb 0f                	jmp    800bc6 <memcmp+0x35>
		s1++, s2++;
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbd:	39 f0                	cmp    %esi,%eax
  800bbf:	75 e2                	jne    800ba3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bd3:	89 c2                	mov    %eax,%edx
  800bd5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd8:	eb 07                	jmp    800be1 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	38 08                	cmp    %cl,(%eax)
  800bdc:	74 07                	je     800be5 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bde:	83 c0 01             	add    $0x1,%eax
  800be1:	39 d0                	cmp    %edx,%eax
  800be3:	72 f5                	jb     800bda <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf3:	eb 03                	jmp    800bf8 <strtol+0x11>
		s++;
  800bf5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf8:	0f b6 01             	movzbl (%ecx),%eax
  800bfb:	3c 09                	cmp    $0x9,%al
  800bfd:	74 f6                	je     800bf5 <strtol+0xe>
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f2                	je     800bf5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 0a                	jne    800c11 <strtol+0x2a>
		s++;
  800c07:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0f:	eb 10                	jmp    800c21 <strtol+0x3a>
  800c11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c16:	3c 2d                	cmp    $0x2d,%al
  800c18:	75 07                	jne    800c21 <strtol+0x3a>
		s++, neg = 1;
  800c1a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c21:	85 db                	test   %ebx,%ebx
  800c23:	0f 94 c0             	sete   %al
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 19                	jne    800c47 <strtol+0x60>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 14                	jne    800c47 <strtol+0x60>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	0f 85 82 00 00 00    	jne    800cbf <strtol+0xd8>
		s += 2, base = 16;
  800c3d:	83 c1 02             	add    $0x2,%ecx
  800c40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c45:	eb 16                	jmp    800c5d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c47:	84 c0                	test   %al,%al
  800c49:	74 12                	je     800c5d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c50:	80 39 30             	cmpb   $0x30,(%ecx)
  800c53:	75 08                	jne    800c5d <strtol+0x76>
		s++, base = 8;
  800c55:	83 c1 01             	add    $0x1,%ecx
  800c58:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c62:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c65:	0f b6 11             	movzbl (%ecx),%edx
  800c68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c6b:	89 f3                	mov    %esi,%ebx
  800c6d:	80 fb 09             	cmp    $0x9,%bl
  800c70:	77 08                	ja     800c7a <strtol+0x93>
			dig = *s - '0';
  800c72:	0f be d2             	movsbl %dl,%edx
  800c75:	83 ea 30             	sub    $0x30,%edx
  800c78:	eb 22                	jmp    800c9c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 08                	ja     800c8c <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c84:	0f be d2             	movsbl %dl,%edx
  800c87:	83 ea 57             	sub    $0x57,%edx
  800c8a:	eb 10                	jmp    800c9c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 16                	ja     800cac <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c96:	0f be d2             	movsbl %dl,%edx
  800c99:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9f:	7d 0f                	jge    800cb0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ca1:	83 c1 01             	add    $0x1,%ecx
  800ca4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800caa:	eb b9                	jmp    800c65 <strtol+0x7e>
  800cac:	89 c2                	mov    %eax,%edx
  800cae:	eb 02                	jmp    800cb2 <strtol+0xcb>
  800cb0:	89 c2                	mov    %eax,%edx

	if (endptr)
  800cb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb6:	74 0d                	je     800cc5 <strtol+0xde>
		*endptr = (char *) s;
  800cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbb:	89 0e                	mov    %ecx,(%esi)
  800cbd:	eb 06                	jmp    800cc5 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbf:	84 c0                	test   %al,%al
  800cc1:	75 92                	jne    800c55 <strtol+0x6e>
  800cc3:	eb 98                	jmp    800c5d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc5:	f7 da                	neg    %edx
  800cc7:	85 ff                	test   %edi,%edi
  800cc9:	0f 45 c2             	cmovne %edx,%eax
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	89 c7                	mov    %eax,%edi
  800ce6:	89 c6                	mov    %eax,%esi
  800ce8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_cgetc>:

int
sys_cgetc(void)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 d3                	mov    %edx,%ebx
  800d03:	89 d7                	mov    %edx,%edi
  800d05:	89 d6                	mov    %edx,%esi
  800d07:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 cb                	mov    %ecx,%ebx
  800d26:	89 cf                	mov    %ecx,%edi
  800d28:	89 ce                	mov    %ecx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 03                	push   $0x3
  800d36:	68 df 2b 80 00       	push   $0x802bdf
  800d3b:	6a 22                	push   $0x22
  800d3d:	68 fc 2b 80 00       	push   $0x802bfc
  800d42:	e8 dd f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d55:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5f:	89 d1                	mov    %edx,%ecx
  800d61:	89 d3                	mov    %edx,%ebx
  800d63:	89 d7                	mov    %edx,%edi
  800d65:	89 d6                	mov    %edx,%esi
  800d67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_yield>:

void
sys_yield(void)
{      
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7e:	89 d1                	mov    %edx,%ecx
  800d80:	89 d3                	mov    %edx,%ebx
  800d82:	89 d7                	mov    %edx,%edi
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d96:	be 00 00 00 00       	mov    $0x0,%esi
  800d9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da9:	89 f7                	mov    %esi,%edi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 04                	push   $0x4
  800db7:	68 df 2b 80 00       	push   $0x802bdf
  800dbc:	6a 22                	push   $0x22
  800dbe:	68 fc 2b 80 00       	push   $0x802bfc
  800dc3:	e8 5c f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dd9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dea:	8b 75 18             	mov    0x18(%ebp),%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 05                	push   $0x5
  800df9:	68 df 2b 80 00       	push   $0x802bdf
  800dfe:	6a 22                	push   $0x22
  800e00:	68 fc 2b 80 00       	push   $0x802bfc
  800e05:	e8 1a f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 06 00 00 00       	mov    $0x6,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 17                	jle    800e4c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 06                	push   $0x6
  800e3b:	68 df 2b 80 00       	push   $0x802bdf
  800e40:	6a 22                	push   $0x22
  800e42:	68 fc 2b 80 00       	push   $0x802bfc
  800e47:	e8 d8 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e62:	b8 08 00 00 00       	mov    $0x8,%eax
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 df                	mov    %ebx,%edi
  800e6f:	89 de                	mov    %ebx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 08                	push   $0x8
  800e7d:	68 df 2b 80 00       	push   $0x802bdf
  800e82:	6a 22                	push   $0x22
  800e84:	68 fc 2b 80 00       	push   $0x802bfc
  800e89:	e8 96 f4 ff ff       	call   800324 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 df                	mov    %ebx,%edi
  800eb1:	89 de                	mov    %ebx,%esi
  800eb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 17                	jle    800ed0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 09                	push   $0x9
  800ebf:	68 df 2b 80 00       	push   $0x802bdf
  800ec4:	6a 22                	push   $0x22
  800ec6:	68 fc 2b 80 00       	push   $0x802bfc
  800ecb:	e8 54 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 df                	mov    %ebx,%edi
  800ef3:	89 de                	mov    %ebx,%esi
  800ef5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 17                	jle    800f12 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	50                   	push   %eax
  800eff:	6a 0a                	push   $0xa
  800f01:	68 df 2b 80 00       	push   $0x802bdf
  800f06:	6a 22                	push   $0x22
  800f08:	68 fc 2b 80 00       	push   $0x802bfc
  800f0d:	e8 12 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f20:	be 00 00 00 00       	mov    $0x0,%esi
  800f25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f36:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	89 cb                	mov    %ecx,%ebx
  800f55:	89 cf                	mov    %ecx,%edi
  800f57:	89 ce                	mov    %ecx,%esi
  800f59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	7e 17                	jle    800f76 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	50                   	push   %eax
  800f63:	6a 0d                	push   $0xd
  800f65:	68 df 2b 80 00       	push   $0x802bdf
  800f6a:	6a 22                	push   $0x22
  800f6c:	68 fc 2b 80 00       	push   $0x802bfc
  800f71:	e8 ae f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f84:	ba 00 00 00 00       	mov    $0x0,%edx
  800f89:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f8e:	89 d1                	mov    %edx,%ecx
  800f90:	89 d3                	mov    %edx,%ebx
  800f92:	89 d7                	mov    %edx,%edi
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_transmit>:

int
sys_transmit(void *addr)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fab:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb3:	89 cb                	mov    %ecx,%ebx
  800fb5:	89 cf                	mov    %ecx,%edi
  800fb7:	89 ce                	mov    %ecx,%esi
  800fb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	7e 17                	jle    800fd6 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	50                   	push   %eax
  800fc3:	6a 0f                	push   $0xf
  800fc5:	68 df 2b 80 00       	push   $0x802bdf
  800fca:	6a 22                	push   $0x22
  800fcc:	68 fc 2b 80 00       	push   $0x802bfc
  800fd1:	e8 4e f3 ff ff       	call   800324 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <sys_recv>:

int
sys_recv(void *addr)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800fe7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fec:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	89 cb                	mov    %ecx,%ebx
  800ff6:	89 cf                	mov    %ecx,%edi
  800ff8:	89 ce                	mov    %ecx,%esi
  800ffa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	7e 17                	jle    801017 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	50                   	push   %eax
  801004:	6a 10                	push   $0x10
  801006:	68 df 2b 80 00       	push   $0x802bdf
  80100b:	6a 22                	push   $0x22
  80100d:	68 fc 2b 80 00       	push   $0x802bfc
  801012:	e8 0d f3 ff ff       	call   800324 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801028:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  80102b:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80102d:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801030:	83 3a 01             	cmpl   $0x1,(%edx)
  801033:	7e 09                	jle    80103e <argstart+0x1f>
  801035:	ba 68 28 80 00       	mov    $0x802868,%edx
  80103a:	85 c9                	test   %ecx,%ecx
  80103c:	75 05                	jne    801043 <argstart+0x24>
  80103e:	ba 00 00 00 00       	mov    $0x0,%edx
  801043:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801046:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <argnext>:

int
argnext(struct Argstate *args)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801059:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801060:	8b 43 08             	mov    0x8(%ebx),%eax
  801063:	85 c0                	test   %eax,%eax
  801065:	74 6f                	je     8010d6 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801067:	80 38 00             	cmpb   $0x0,(%eax)
  80106a:	75 4e                	jne    8010ba <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80106c:	8b 0b                	mov    (%ebx),%ecx
  80106e:	83 39 01             	cmpl   $0x1,(%ecx)
  801071:	74 55                	je     8010c8 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801073:	8b 53 04             	mov    0x4(%ebx),%edx
  801076:	8b 42 04             	mov    0x4(%edx),%eax
  801079:	80 38 2d             	cmpb   $0x2d,(%eax)
  80107c:	75 4a                	jne    8010c8 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80107e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801082:	74 44                	je     8010c8 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801084:	83 c0 01             	add    $0x1,%eax
  801087:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	8b 01                	mov    (%ecx),%eax
  80108f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801096:	50                   	push   %eax
  801097:	8d 42 08             	lea    0x8(%edx),%eax
  80109a:	50                   	push   %eax
  80109b:	83 c2 04             	add    $0x4,%edx
  80109e:	52                   	push   %edx
  80109f:	e8 72 fa ff ff       	call   800b16 <memmove>
		(*args->argc)--;
  8010a4:	8b 03                	mov    (%ebx),%eax
  8010a6:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010a9:	8b 43 08             	mov    0x8(%ebx),%eax
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010b2:	75 06                	jne    8010ba <argnext+0x6b>
  8010b4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010b8:	74 0e                	je     8010c8 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010ba:	8b 53 08             	mov    0x8(%ebx),%edx
  8010bd:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010c0:	83 c2 01             	add    $0x1,%edx
  8010c3:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8010c6:	eb 13                	jmp    8010db <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  8010c8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010d4:	eb 05                	jmp    8010db <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010ea:	8b 43 08             	mov    0x8(%ebx),%eax
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	74 58                	je     801149 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8010f1:	80 38 00             	cmpb   $0x0,(%eax)
  8010f4:	74 0c                	je     801102 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8010f6:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010f9:	c7 43 08 68 28 80 00 	movl   $0x802868,0x8(%ebx)
  801100:	eb 42                	jmp    801144 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801102:	8b 13                	mov    (%ebx),%edx
  801104:	83 3a 01             	cmpl   $0x1,(%edx)
  801107:	7e 2d                	jle    801136 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801109:	8b 43 04             	mov    0x4(%ebx),%eax
  80110c:	8b 48 04             	mov    0x4(%eax),%ecx
  80110f:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	8b 12                	mov    (%edx),%edx
  801117:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  80111e:	52                   	push   %edx
  80111f:	8d 50 08             	lea    0x8(%eax),%edx
  801122:	52                   	push   %edx
  801123:	83 c0 04             	add    $0x4,%eax
  801126:	50                   	push   %eax
  801127:	e8 ea f9 ff ff       	call   800b16 <memmove>
		(*args->argc)--;
  80112c:	8b 03                	mov    (%ebx),%eax
  80112e:	83 28 01             	subl   $0x1,(%eax)
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	eb 0e                	jmp    801144 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801136:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  80113d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801144:	8b 43 0c             	mov    0xc(%ebx),%eax
  801147:	eb 05                	jmp    80114e <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80115c:	8b 51 0c             	mov    0xc(%ecx),%edx
  80115f:	89 d0                	mov    %edx,%eax
  801161:	85 d2                	test   %edx,%edx
  801163:	75 0c                	jne    801171 <argvalue+0x1e>
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	51                   	push   %ecx
  801169:	e8 72 ff ff ff       	call   8010e0 <argnextvalue>
  80116e:	83 c4 10             	add    $0x10,%esp
}
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	05 00 00 00 30       	add    $0x30000000,%eax
  80117e:	c1 e8 0c             	shr    $0xc,%eax
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80118e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801193:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 16             	shr    $0x16,%edx
  8011aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b1:	f6 c2 01             	test   $0x1,%dl
  8011b4:	74 11                	je     8011c7 <fd_alloc+0x2d>
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	c1 ea 0c             	shr    $0xc,%edx
  8011bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c2:	f6 c2 01             	test   $0x1,%dl
  8011c5:	75 09                	jne    8011d0 <fd_alloc+0x36>
			*fd_store = fd;
  8011c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb 17                	jmp    8011e7 <fd_alloc+0x4d>
  8011d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011da:	75 c9                	jne    8011a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ef:	83 f8 1f             	cmp    $0x1f,%eax
  8011f2:	77 36                	ja     80122a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f4:	c1 e0 0c             	shl    $0xc,%eax
  8011f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	c1 ea 16             	shr    $0x16,%edx
  801201:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801208:	f6 c2 01             	test   $0x1,%dl
  80120b:	74 24                	je     801231 <fd_lookup+0x48>
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 0c             	shr    $0xc,%edx
  801212:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 1a                	je     801238 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801221:	89 02                	mov    %eax,(%edx)
	return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
  801228:	eb 13                	jmp    80123d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122f:	eb 0c                	jmp    80123d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801236:	eb 05                	jmp    80123d <fd_lookup+0x54>
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
  80124d:	eb 13                	jmp    801262 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80124f:	39 08                	cmp    %ecx,(%eax)
  801251:	75 0c                	jne    80125f <dev_lookup+0x20>
			*dev = devtab[i];
  801253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801256:	89 01                	mov    %eax,(%ecx)
			return 0;
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
  80125d:	eb 36                	jmp    801295 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125f:	83 c2 01             	add    $0x1,%edx
  801262:	8b 04 95 8c 2c 80 00 	mov    0x802c8c(,%edx,4),%eax
  801269:	85 c0                	test   %eax,%eax
  80126b:	75 e2                	jne    80124f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126d:	a1 40 44 80 00       	mov    0x804440,%eax
  801272:	8b 40 48             	mov    0x48(%eax),%eax
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	51                   	push   %ecx
  801279:	50                   	push   %eax
  80127a:	68 0c 2c 80 00       	push   $0x802c0c
  80127f:	e8 79 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 10             	sub    $0x10,%esp
  80129f:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b2:	50                   	push   %eax
  8012b3:	e8 31 ff ff ff       	call   8011e9 <fd_lookup>
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 05                	js     8012c4 <fd_close+0x2d>
	    || fd != fd2)
  8012bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c2:	74 0c                	je     8012d0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c4:	84 db                	test   %bl,%bl
  8012c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cb:	0f 44 c2             	cmove  %edx,%eax
  8012ce:	eb 41                	jmp    801311 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	ff 36                	pushl  (%esi)
  8012d9:	e8 61 ff ff ff       	call   80123f <dev_lookup>
  8012de:	89 c3                	mov    %eax,%ebx
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 1a                	js     801301 <fd_close+0x6a>
		if (dev->dev_close)
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	74 0b                	je     801301 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	56                   	push   %esi
  8012fa:	ff d0                	call   *%eax
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	56                   	push   %esi
  801305:	6a 00                	push   $0x0
  801307:	e8 06 fb ff ff       	call   800e12 <sys_page_unmap>
	return r;
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	89 d8                	mov    %ebx,%eax
}
  801311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 bf fe ff ff       	call   8011e9 <fd_lookup>
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 d2                	test   %edx,%edx
  801331:	78 10                	js     801343 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	6a 01                	push   $0x1
  801338:	ff 75 f4             	pushl  -0xc(%ebp)
  80133b:	e8 57 ff ff ff       	call   801297 <fd_close>
  801340:	83 c4 10             	add    $0x10,%esp
}
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <close_all>:

void
close_all(void)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	53                   	push   %ebx
  801355:	e8 be ff ff ff       	call   801318 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135a:	83 c3 01             	add    $0x1,%ebx
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	83 fb 20             	cmp    $0x20,%ebx
  801363:	75 ec                	jne    801351 <close_all+0xc>
		close(i);
}
  801365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 2c             	sub    $0x2c,%esp
  801373:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801376:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	ff 75 08             	pushl  0x8(%ebp)
  80137d:	e8 67 fe ff ff       	call   8011e9 <fd_lookup>
  801382:	89 c2                	mov    %eax,%edx
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	85 d2                	test   %edx,%edx
  801389:	0f 88 c1 00 00 00    	js     801450 <dup+0xe6>
		return r;
	close(newfdnum);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	56                   	push   %esi
  801393:	e8 80 ff ff ff       	call   801318 <close>

	newfd = INDEX2FD(newfdnum);
  801398:	89 f3                	mov    %esi,%ebx
  80139a:	c1 e3 0c             	shl    $0xc,%ebx
  80139d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a3:	83 c4 04             	add    $0x4,%esp
  8013a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a9:	e8 d5 fd ff ff       	call   801183 <fd2data>
  8013ae:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b0:	89 1c 24             	mov    %ebx,(%esp)
  8013b3:	e8 cb fd ff ff       	call   801183 <fd2data>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013be:	89 f8                	mov    %edi,%eax
  8013c0:	c1 e8 16             	shr    $0x16,%eax
  8013c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ca:	a8 01                	test   $0x1,%al
  8013cc:	74 37                	je     801405 <dup+0x9b>
  8013ce:	89 f8                	mov    %edi,%eax
  8013d0:	c1 e8 0c             	shr    $0xc,%eax
  8013d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013da:	f6 c2 01             	test   $0x1,%dl
  8013dd:	74 26                	je     801405 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f2:	6a 00                	push   $0x0
  8013f4:	57                   	push   %edi
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 d4 f9 ff ff       	call   800dd0 <sys_page_map>
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	83 c4 20             	add    $0x20,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 2e                	js     801433 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801408:	89 d0                	mov    %edx,%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	25 07 0e 00 00       	and    $0xe07,%eax
  80141c:	50                   	push   %eax
  80141d:	53                   	push   %ebx
  80141e:	6a 00                	push   $0x0
  801420:	52                   	push   %edx
  801421:	6a 00                	push   $0x0
  801423:	e8 a8 f9 ff ff       	call   800dd0 <sys_page_map>
  801428:	89 c7                	mov    %eax,%edi
  80142a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142f:	85 ff                	test   %edi,%edi
  801431:	79 1d                	jns    801450 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	53                   	push   %ebx
  801437:	6a 00                	push   $0x0
  801439:	e8 d4 f9 ff ff       	call   800e12 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143e:	83 c4 08             	add    $0x8,%esp
  801441:	ff 75 d4             	pushl  -0x2c(%ebp)
  801444:	6a 00                	push   $0x0
  801446:	e8 c7 f9 ff ff       	call   800e12 <sys_page_unmap>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 f8                	mov    %edi,%eax
}
  801450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5f                   	pop    %edi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 14             	sub    $0x14,%esp
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	53                   	push   %ebx
  801467:	e8 7d fd ff ff       	call   8011e9 <fd_lookup>
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	89 c2                	mov    %eax,%edx
  801471:	85 c0                	test   %eax,%eax
  801473:	78 6d                	js     8014e2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	ff 30                	pushl  (%eax)
  801481:	e8 b9 fd ff ff       	call   80123f <dev_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 4c                	js     8014d9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801490:	8b 42 08             	mov    0x8(%edx),%eax
  801493:	83 e0 03             	and    $0x3,%eax
  801496:	83 f8 01             	cmp    $0x1,%eax
  801499:	75 21                	jne    8014bc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149b:	a1 40 44 80 00       	mov    0x804440,%eax
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	50                   	push   %eax
  8014a8:	68 50 2c 80 00       	push   $0x802c50
  8014ad:	e8 4b ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ba:	eb 26                	jmp    8014e2 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bf:	8b 40 08             	mov    0x8(%eax),%eax
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	74 17                	je     8014dd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c6:	83 ec 04             	sub    $0x4,%esp
  8014c9:	ff 75 10             	pushl  0x10(%ebp)
  8014cc:	ff 75 0c             	pushl  0xc(%ebp)
  8014cf:	52                   	push   %edx
  8014d0:	ff d0                	call   *%eax
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	eb 09                	jmp    8014e2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	eb 05                	jmp    8014e2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e2:	89 d0                	mov    %edx,%eax
  8014e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	57                   	push   %edi
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fd:	eb 21                	jmp    801520 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	89 f0                	mov    %esi,%eax
  801504:	29 d8                	sub    %ebx,%eax
  801506:	50                   	push   %eax
  801507:	89 d8                	mov    %ebx,%eax
  801509:	03 45 0c             	add    0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	57                   	push   %edi
  80150e:	e8 45 ff ff ff       	call   801458 <read>
		if (m < 0)
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 0c                	js     801526 <readn+0x3d>
			return m;
		if (m == 0)
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 06                	je     801524 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151e:	01 c3                	add    %eax,%ebx
  801520:	39 f3                	cmp    %esi,%ebx
  801522:	72 db                	jb     8014ff <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801524:	89 d8                	mov    %ebx,%eax
}
  801526:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5f                   	pop    %edi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 14             	sub    $0x14,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801538:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	53                   	push   %ebx
  80153d:	e8 a7 fc ff ff       	call   8011e9 <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	89 c2                	mov    %eax,%edx
  801547:	85 c0                	test   %eax,%eax
  801549:	78 68                	js     8015b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	ff 30                	pushl  (%eax)
  801557:	e8 e3 fc ff ff       	call   80123f <dev_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 47                	js     8015aa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801566:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156a:	75 21                	jne    80158d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156c:	a1 40 44 80 00       	mov    0x804440,%eax
  801571:	8b 40 48             	mov    0x48(%eax),%eax
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	53                   	push   %ebx
  801578:	50                   	push   %eax
  801579:	68 6c 2c 80 00       	push   $0x802c6c
  80157e:	e8 7a ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158b:	eb 26                	jmp    8015b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801590:	8b 52 0c             	mov    0xc(%edx),%edx
  801593:	85 d2                	test   %edx,%edx
  801595:	74 17                	je     8015ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	ff 75 10             	pushl  0x10(%ebp)
  80159d:	ff 75 0c             	pushl  0xc(%ebp)
  8015a0:	50                   	push   %eax
  8015a1:	ff d2                	call   *%edx
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 09                	jmp    8015b3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	eb 05                	jmp    8015b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b3:	89 d0                	mov    %edx,%eax
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	ff 75 08             	pushl  0x8(%ebp)
  8015c7:	e8 1d fc ff ff       	call   8011e9 <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 0e                	js     8015e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 14             	sub    $0x14,%esp
  8015ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	53                   	push   %ebx
  8015f2:	e8 f2 fb ff ff       	call   8011e9 <fd_lookup>
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 65                	js     801665 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160a:	ff 30                	pushl  (%eax)
  80160c:	e8 2e fc ff ff       	call   80123f <dev_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 44                	js     80165c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161f:	75 21                	jne    801642 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801621:	a1 40 44 80 00       	mov    0x804440,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801626:	8b 40 48             	mov    0x48(%eax),%eax
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	53                   	push   %ebx
  80162d:	50                   	push   %eax
  80162e:	68 2c 2c 80 00       	push   $0x802c2c
  801633:	e8 c5 ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801640:	eb 23                	jmp    801665 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801642:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801645:	8b 52 18             	mov    0x18(%edx),%edx
  801648:	85 d2                	test   %edx,%edx
  80164a:	74 14                	je     801660 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	ff 75 0c             	pushl  0xc(%ebp)
  801652:	50                   	push   %eax
  801653:	ff d2                	call   *%edx
  801655:	89 c2                	mov    %eax,%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 09                	jmp    801665 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	eb 05                	jmp    801665 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801660:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801665:	89 d0                	mov    %edx,%eax
  801667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 14             	sub    $0x14,%esp
  801673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 67 fb ff ff       	call   8011e9 <fd_lookup>
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	89 c2                	mov    %eax,%edx
  801687:	85 c0                	test   %eax,%eax
  801689:	78 58                	js     8016e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	ff 30                	pushl  (%eax)
  801697:	e8 a3 fb ff ff       	call   80123f <dev_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 37                	js     8016da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016aa:	74 32                	je     8016de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b6:	00 00 00 
	stat->st_isdir = 0;
  8016b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c0:	00 00 00 
	stat->st_dev = dev;
  8016c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d0:	ff 50 14             	call   *0x14(%eax)
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 09                	jmp    8016e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	eb 05                	jmp    8016e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	6a 00                	push   $0x0
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 09 02 00 00       	call   801905 <open>
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 db                	test   %ebx,%ebx
  801703:	78 1b                	js     801720 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	53                   	push   %ebx
  80170c:	e8 5b ff ff ff       	call   80166c <fstat>
  801711:	89 c6                	mov    %eax,%esi
	close(fd);
  801713:	89 1c 24             	mov    %ebx,(%esp)
  801716:	e8 fd fb ff ff       	call   801318 <close>
	return r;
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	89 f0                	mov    %esi,%eax
}
  801720:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	89 c6                	mov    %eax,%esi
  80172e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801730:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801737:	75 12                	jne    80174b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	6a 01                	push   $0x1
  80173e:	e8 80 0d 00 00       	call   8024c3 <ipc_find_env>
  801743:	a3 00 40 80 00       	mov    %eax,0x804000
  801748:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174b:	6a 07                	push   $0x7
  80174d:	68 00 50 80 00       	push   $0x805000
  801752:	56                   	push   %esi
  801753:	ff 35 00 40 80 00    	pushl  0x804000
  801759:	e8 11 0d 00 00       	call   80246f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175e:	83 c4 0c             	add    $0xc,%esp
  801761:	6a 00                	push   $0x0
  801763:	53                   	push   %ebx
  801764:	6a 00                	push   $0x0
  801766:	e8 9b 0c 00 00       	call   802406 <ipc_recv>
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801783:	8b 45 0c             	mov    0xc(%ebp),%eax
  801786:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 02 00 00 00       	mov    $0x2,%eax
  801795:	e8 8d ff ff ff       	call   801727 <fsipc>
}
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b7:	e8 6b ff ff ff       	call   801727 <fsipc>
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017dd:	e8 45 ff ff ff       	call   801727 <fsipc>
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	78 2c                	js     801814 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	68 00 50 80 00       	push   $0x805000
  8017f0:	53                   	push   %ebx
  8017f1:	e8 8e f1 ff ff       	call   800984 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801801:	a1 84 50 80 00       	mov    0x805084,%eax
  801806:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	57                   	push   %edi
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	8b 40 0c             	mov    0xc(%eax),%eax
  80182b:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801833:	eb 3d                	jmp    801872 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801835:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80183b:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801840:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	57                   	push   %edi
  801847:	53                   	push   %ebx
  801848:	68 08 50 80 00       	push   $0x805008
  80184d:	e8 c4 f2 ff ff       	call   800b16 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801852:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 04 00 00 00       	mov    $0x4,%eax
  801862:	e8 c0 fe ff ff       	call   801727 <fsipc>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 0d                	js     80187b <devfile_write+0x62>
		        return r;
                n -= tmp;
  80186e:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801870:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801872:	85 f6                	test   %esi,%esi
  801874:	75 bf                	jne    801835 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801876:	89 d8                	mov    %ebx,%eax
  801878:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80187b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5f                   	pop    %edi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801896:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a6:	e8 7c fe ff ff       	call   801727 <fsipc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 4b                	js     8018fc <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018b1:	39 c6                	cmp    %eax,%esi
  8018b3:	73 16                	jae    8018cb <devfile_read+0x48>
  8018b5:	68 a0 2c 80 00       	push   $0x802ca0
  8018ba:	68 a7 2c 80 00       	push   $0x802ca7
  8018bf:	6a 7c                	push   $0x7c
  8018c1:	68 bc 2c 80 00       	push   $0x802cbc
  8018c6:	e8 59 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  8018cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d0:	7e 16                	jle    8018e8 <devfile_read+0x65>
  8018d2:	68 c7 2c 80 00       	push   $0x802cc7
  8018d7:	68 a7 2c 80 00       	push   $0x802ca7
  8018dc:	6a 7d                	push   $0x7d
  8018de:	68 bc 2c 80 00       	push   $0x802cbc
  8018e3:	e8 3c ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e8:	83 ec 04             	sub    $0x4,%esp
  8018eb:	50                   	push   %eax
  8018ec:	68 00 50 80 00       	push   $0x805000
  8018f1:	ff 75 0c             	pushl  0xc(%ebp)
  8018f4:	e8 1d f2 ff ff       	call   800b16 <memmove>
	return r;
  8018f9:	83 c4 10             	add    $0x10,%esp
}
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	53                   	push   %ebx
  801909:	83 ec 20             	sub    $0x20,%esp
  80190c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190f:	53                   	push   %ebx
  801910:	e8 36 f0 ff ff       	call   80094b <strlen>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191d:	7f 67                	jg     801986 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	e8 6f f8 ff ff       	call   80119a <fd_alloc>
  80192b:	83 c4 10             	add    $0x10,%esp
		return r;
  80192e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801930:	85 c0                	test   %eax,%eax
  801932:	78 57                	js     80198b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	53                   	push   %ebx
  801938:	68 00 50 80 00       	push   $0x805000
  80193d:	e8 42 f0 ff ff       	call   800984 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801942:	8b 45 0c             	mov    0xc(%ebp),%eax
  801945:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80194a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194d:	b8 01 00 00 00       	mov    $0x1,%eax
  801952:	e8 d0 fd ff ff       	call   801727 <fsipc>
  801957:	89 c3                	mov    %eax,%ebx
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	79 14                	jns    801974 <open+0x6f>
		fd_close(fd, 0);
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	6a 00                	push   $0x0
  801965:	ff 75 f4             	pushl  -0xc(%ebp)
  801968:	e8 2a f9 ff ff       	call   801297 <fd_close>
		return r;
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	89 da                	mov    %ebx,%edx
  801972:	eb 17                	jmp    80198b <open+0x86>
	}

	return fd2num(fd);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 f4             	pushl  -0xc(%ebp)
  80197a:	e8 f4 f7 ff ff       	call   801173 <fd2num>
  80197f:	89 c2                	mov    %eax,%edx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	eb 05                	jmp    80198b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801986:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801998:	ba 00 00 00 00       	mov    $0x0,%edx
  80199d:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a2:	e8 80 fd ff ff       	call   801727 <fsipc>
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8019a9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8019ad:	7e 37                	jle    8019e6 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019b8:	ff 70 04             	pushl  0x4(%eax)
  8019bb:	8d 40 10             	lea    0x10(%eax),%eax
  8019be:	50                   	push   %eax
  8019bf:	ff 33                	pushl  (%ebx)
  8019c1:	e8 68 fb ff ff       	call   80152e <write>
		if (result > 0)
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	7e 03                	jle    8019d0 <writebuf+0x27>
			b->result += result;
  8019cd:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019d0:	39 43 04             	cmp    %eax,0x4(%ebx)
  8019d3:	74 0d                	je     8019e2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	0f 4f c2             	cmovg  %edx,%eax
  8019df:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e5:	c9                   	leave  
  8019e6:	f3 c3                	repz ret 

008019e8 <putch>:

static void
putch(int ch, void *thunk)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019f2:	8b 53 04             	mov    0x4(%ebx),%edx
  8019f5:	8d 42 01             	lea    0x1(%edx),%eax
  8019f8:	89 43 04             	mov    %eax,0x4(%ebx)
  8019fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fe:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a02:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a07:	75 0e                	jne    801a17 <putch+0x2f>
		writebuf(b);
  801a09:	89 d8                	mov    %ebx,%eax
  801a0b:	e8 99 ff ff ff       	call   8019a9 <writebuf>
		b->idx = 0;
  801a10:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a17:	83 c4 04             	add    $0x4,%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a2f:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a36:	00 00 00 
	b.result = 0;
  801a39:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a40:	00 00 00 
	b.error = 1;
  801a43:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a4a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a4d:	ff 75 10             	pushl  0x10(%ebp)
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	68 e8 19 80 00       	push   $0x8019e8
  801a5f:	e8 cb ea ff ff       	call   80052f <vprintfmt>
	if (b.idx > 0)
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a6e:	7e 0b                	jle    801a7b <vfprintf+0x5e>
		writebuf(&b);
  801a70:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a76:	e8 2e ff ff ff       	call   8019a9 <writebuf>

	return (b.result ? b.result : b.error);
  801a7b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a81:	85 c0                	test   %eax,%eax
  801a83:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a92:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a95:	50                   	push   %eax
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	ff 75 08             	pushl  0x8(%ebp)
  801a9c:	e8 7c ff ff ff       	call   801a1d <vfprintf>
	va_end(ap);

	return cnt;
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <printf>:

int
printf(const char *fmt, ...)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aa9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801aac:	50                   	push   %eax
  801aad:	ff 75 08             	pushl  0x8(%ebp)
  801ab0:	6a 01                	push   $0x1
  801ab2:	e8 66 ff ff ff       	call   801a1d <vfprintf>
	va_end(ap);

	return cnt;
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801abf:	68 d3 2c 80 00       	push   $0x802cd3
  801ac4:	ff 75 0c             	pushl  0xc(%ebp)
  801ac7:	e8 b8 ee ff ff       	call   800984 <strcpy>
	return 0;
}
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 10             	sub    $0x10,%esp
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801add:	53                   	push   %ebx
  801ade:	e8 18 0a 00 00       	call   8024fb <pageref>
  801ae3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ae6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801aeb:	83 f8 01             	cmp    $0x1,%eax
  801aee:	75 10                	jne    801b00 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	ff 73 0c             	pushl  0xc(%ebx)
  801af6:	e8 ca 02 00 00       	call   801dc5 <nsipc_close>
  801afb:	89 c2                	mov    %eax,%edx
  801afd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b00:	89 d0                	mov    %edx,%eax
  801b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b0d:	6a 00                	push   $0x0
  801b0f:	ff 75 10             	pushl  0x10(%ebp)
  801b12:	ff 75 0c             	pushl  0xc(%ebp)
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	ff 70 0c             	pushl  0xc(%eax)
  801b1b:	e8 82 03 00 00       	call   801ea2 <nsipc_send>
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b28:	6a 00                	push   $0x0
  801b2a:	ff 75 10             	pushl  0x10(%ebp)
  801b2d:	ff 75 0c             	pushl  0xc(%ebp)
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
  801b33:	ff 70 0c             	pushl  0xc(%eax)
  801b36:	e8 fb 02 00 00       	call   801e36 <nsipc_recv>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b43:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b46:	52                   	push   %edx
  801b47:	50                   	push   %eax
  801b48:	e8 9c f6 ff ff       	call   8011e9 <fd_lookup>
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 17                	js     801b6b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b5d:	39 08                	cmp    %ecx,(%eax)
  801b5f:	75 05                	jne    801b66 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b61:	8b 40 0c             	mov    0xc(%eax),%eax
  801b64:	eb 05                	jmp    801b6b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    

00801b6d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 1c             	sub    $0x1c,%esp
  801b75:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7a:	50                   	push   %eax
  801b7b:	e8 1a f6 ff ff       	call   80119a <fd_alloc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 1b                	js     801ba4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	68 07 04 00 00       	push   $0x407
  801b91:	ff 75 f4             	pushl  -0xc(%ebp)
  801b94:	6a 00                	push   $0x0
  801b96:	e8 f2 f1 ff ff       	call   800d8d <sys_page_alloc>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	79 10                	jns    801bb4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	56                   	push   %esi
  801ba8:	e8 18 02 00 00       	call   801dc5 <nsipc_close>
		return r;
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	eb 24                	jmp    801bd8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bb4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801bc9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	52                   	push   %edx
  801bd0:	e8 9e f5 ff ff       	call   801173 <fd2num>
  801bd5:	83 c4 10             	add    $0x10,%esp
}
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	e8 50 ff ff ff       	call   801b3d <fd2sockid>
		return r;
  801bed:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 1f                	js     801c12 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	ff 75 10             	pushl  0x10(%ebp)
  801bf9:	ff 75 0c             	pushl  0xc(%ebp)
  801bfc:	50                   	push   %eax
  801bfd:	e8 1c 01 00 00       	call   801d1e <nsipc_accept>
  801c02:	83 c4 10             	add    $0x10,%esp
		return r;
  801c05:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 07                	js     801c12 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c0b:	e8 5d ff ff ff       	call   801b6d <alloc_sockfd>
  801c10:	89 c1                	mov    %eax,%ecx
}
  801c12:	89 c8                	mov    %ecx,%eax
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	e8 19 ff ff ff       	call   801b3d <fd2sockid>
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	85 d2                	test   %edx,%edx
  801c28:	78 12                	js     801c3c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	ff 75 10             	pushl  0x10(%ebp)
  801c30:	ff 75 0c             	pushl  0xc(%ebp)
  801c33:	52                   	push   %edx
  801c34:	e8 35 01 00 00       	call   801d6e <nsipc_bind>
  801c39:	83 c4 10             	add    $0x10,%esp
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <shutdown>:

int
shutdown(int s, int how)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 f1 fe ff ff       	call   801b3d <fd2sockid>
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	85 d2                	test   %edx,%edx
  801c50:	78 0f                	js     801c61 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c52:	83 ec 08             	sub    $0x8,%esp
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	52                   	push   %edx
  801c59:	e8 45 01 00 00       	call   801da3 <nsipc_shutdown>
  801c5e:	83 c4 10             	add    $0x10,%esp
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	e8 cc fe ff ff       	call   801b3d <fd2sockid>
  801c71:	89 c2                	mov    %eax,%edx
  801c73:	85 d2                	test   %edx,%edx
  801c75:	78 12                	js     801c89 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	ff 75 10             	pushl  0x10(%ebp)
  801c7d:	ff 75 0c             	pushl  0xc(%ebp)
  801c80:	52                   	push   %edx
  801c81:	e8 59 01 00 00       	call   801ddf <nsipc_connect>
  801c86:	83 c4 10             	add    $0x10,%esp
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <listen>:

int
listen(int s, int backlog)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	e8 a4 fe ff ff       	call   801b3d <fd2sockid>
  801c99:	89 c2                	mov    %eax,%edx
  801c9b:	85 d2                	test   %edx,%edx
  801c9d:	78 0f                	js     801cae <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	ff 75 0c             	pushl  0xc(%ebp)
  801ca5:	52                   	push   %edx
  801ca6:	e8 69 01 00 00       	call   801e14 <nsipc_listen>
  801cab:	83 c4 10             	add    $0x10,%esp
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cb6:	ff 75 10             	pushl  0x10(%ebp)
  801cb9:	ff 75 0c             	pushl  0xc(%ebp)
  801cbc:	ff 75 08             	pushl  0x8(%ebp)
  801cbf:	e8 3c 02 00 00       	call   801f00 <nsipc_socket>
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 d2                	test   %edx,%edx
  801ccb:	78 05                	js     801cd2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801ccd:	e8 9b fe ff ff       	call   801b6d <alloc_sockfd>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cdd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ce4:	75 12                	jne    801cf8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	6a 02                	push   $0x2
  801ceb:	e8 d3 07 00 00       	call   8024c3 <ipc_find_env>
  801cf0:	a3 04 40 80 00       	mov    %eax,0x804004
  801cf5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cf8:	6a 07                	push   $0x7
  801cfa:	68 00 60 80 00       	push   $0x806000
  801cff:	53                   	push   %ebx
  801d00:	ff 35 04 40 80 00    	pushl  0x804004
  801d06:	e8 64 07 00 00       	call   80246f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d0b:	83 c4 0c             	add    $0xc,%esp
  801d0e:	6a 00                	push   $0x0
  801d10:	6a 00                	push   $0x0
  801d12:	6a 00                	push   $0x0
  801d14:	e8 ed 06 00 00       	call   802406 <ipc_recv>
}
  801d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d2e:	8b 06                	mov    (%esi),%eax
  801d30:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d35:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3a:	e8 95 ff ff ff       	call   801cd4 <nsipc>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 20                	js     801d65 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	ff 35 10 60 80 00    	pushl  0x806010
  801d4e:	68 00 60 80 00       	push   $0x806000
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	e8 bb ed ff ff       	call   800b16 <memmove>
		*addrlen = ret->ret_addrlen;
  801d5b:	a1 10 60 80 00       	mov    0x806010,%eax
  801d60:	89 06                	mov    %eax,(%esi)
  801d62:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d65:	89 d8                	mov    %ebx,%eax
  801d67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d80:	53                   	push   %ebx
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	68 04 60 80 00       	push   $0x806004
  801d89:	e8 88 ed ff ff       	call   800b16 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d8e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d94:	b8 02 00 00 00       	mov    $0x2,%eax
  801d99:	e8 36 ff ff ff       	call   801cd4 <nsipc>
}
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801db9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dbe:	e8 11 ff ff ff       	call   801cd4 <nsipc>
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_close>:

int
nsipc_close(int s)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dd3:	b8 04 00 00 00       	mov    $0x4,%eax
  801dd8:	e8 f7 fe ff ff       	call   801cd4 <nsipc>
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	53                   	push   %ebx
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801df1:	53                   	push   %ebx
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	68 04 60 80 00       	push   $0x806004
  801dfa:	e8 17 ed ff ff       	call   800b16 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dff:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e05:	b8 05 00 00 00       	mov    $0x5,%eax
  801e0a:	e8 c5 fe ff ff       	call   801cd4 <nsipc>
}
  801e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e25:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e2a:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2f:	e8 a0 fe ff ff       	call   801cd4 <nsipc>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e46:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e54:	b8 07 00 00 00       	mov    $0x7,%eax
  801e59:	e8 76 fe ff ff       	call   801cd4 <nsipc>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 35                	js     801e99 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e64:	39 f0                	cmp    %esi,%eax
  801e66:	7f 07                	jg     801e6f <nsipc_recv+0x39>
  801e68:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e6d:	7e 16                	jle    801e85 <nsipc_recv+0x4f>
  801e6f:	68 df 2c 80 00       	push   $0x802cdf
  801e74:	68 a7 2c 80 00       	push   $0x802ca7
  801e79:	6a 62                	push   $0x62
  801e7b:	68 f4 2c 80 00       	push   $0x802cf4
  801e80:	e8 9f e4 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	50                   	push   %eax
  801e89:	68 00 60 80 00       	push   $0x806000
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	e8 80 ec ff ff       	call   800b16 <memmove>
  801e96:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e99:	89 d8                	mov    %ebx,%eax
  801e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801eb4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eba:	7e 16                	jle    801ed2 <nsipc_send+0x30>
  801ebc:	68 00 2d 80 00       	push   $0x802d00
  801ec1:	68 a7 2c 80 00       	push   $0x802ca7
  801ec6:	6a 6d                	push   $0x6d
  801ec8:	68 f4 2c 80 00       	push   $0x802cf4
  801ecd:	e8 52 e4 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ed2:	83 ec 04             	sub    $0x4,%esp
  801ed5:	53                   	push   %ebx
  801ed6:	ff 75 0c             	pushl  0xc(%ebp)
  801ed9:	68 0c 60 80 00       	push   $0x80600c
  801ede:	e8 33 ec ff ff       	call   800b16 <memmove>
	nsipcbuf.send.req_size = size;
  801ee3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ee9:	8b 45 14             	mov    0x14(%ebp),%eax
  801eec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ef1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ef6:	e8 d9 fd ff ff       	call   801cd4 <nsipc>
}
  801efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f11:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f16:	8b 45 10             	mov    0x10(%ebp),%eax
  801f19:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f1e:	b8 09 00 00 00       	mov    $0x9,%eax
  801f23:	e8 ac fd ff ff       	call   801cd4 <nsipc>
}
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f32:	83 ec 0c             	sub    $0xc,%esp
  801f35:	ff 75 08             	pushl  0x8(%ebp)
  801f38:	e8 46 f2 ff ff       	call   801183 <fd2data>
  801f3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f3f:	83 c4 08             	add    $0x8,%esp
  801f42:	68 0c 2d 80 00       	push   $0x802d0c
  801f47:	53                   	push   %ebx
  801f48:	e8 37 ea ff ff       	call   800984 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f4d:	8b 56 04             	mov    0x4(%esi),%edx
  801f50:	89 d0                	mov    %edx,%eax
  801f52:	2b 06                	sub    (%esi),%eax
  801f54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f5a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f61:	00 00 00 
	stat->st_dev = &devpipe;
  801f64:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f6b:	30 80 00 
	return 0;
}
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f84:	53                   	push   %ebx
  801f85:	6a 00                	push   $0x0
  801f87:	e8 86 ee ff ff       	call   800e12 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f8c:	89 1c 24             	mov    %ebx,(%esp)
  801f8f:	e8 ef f1 ff ff       	call   801183 <fd2data>
  801f94:	83 c4 08             	add    $0x8,%esp
  801f97:	50                   	push   %eax
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 73 ee ff ff       	call   800e12 <sys_page_unmap>
}
  801f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    

00801fa4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	57                   	push   %edi
  801fa8:	56                   	push   %esi
  801fa9:	53                   	push   %ebx
  801faa:	83 ec 1c             	sub    $0x1c,%esp
  801fad:	89 c6                	mov    %eax,%esi
  801faf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fb2:	a1 40 44 80 00       	mov    0x804440,%eax
  801fb7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	56                   	push   %esi
  801fbe:	e8 38 05 00 00       	call   8024fb <pageref>
  801fc3:	89 c7                	mov    %eax,%edi
  801fc5:	83 c4 04             	add    $0x4,%esp
  801fc8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fcb:	e8 2b 05 00 00       	call   8024fb <pageref>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	39 c7                	cmp    %eax,%edi
  801fd5:	0f 94 c2             	sete   %dl
  801fd8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801fdb:	8b 0d 40 44 80 00    	mov    0x804440,%ecx
  801fe1:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801fe4:	39 fb                	cmp    %edi,%ebx
  801fe6:	74 19                	je     802001 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801fe8:	84 d2                	test   %dl,%dl
  801fea:	74 c6                	je     801fb2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fec:	8b 51 58             	mov    0x58(%ecx),%edx
  801fef:	50                   	push   %eax
  801ff0:	52                   	push   %edx
  801ff1:	53                   	push   %ebx
  801ff2:	68 13 2d 80 00       	push   $0x802d13
  801ff7:	e8 01 e4 ff ff       	call   8003fd <cprintf>
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	eb b1                	jmp    801fb2 <_pipeisclosed+0xe>
	}
}
  802001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	57                   	push   %edi
  80200d:	56                   	push   %esi
  80200e:	53                   	push   %ebx
  80200f:	83 ec 28             	sub    $0x28,%esp
  802012:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802015:	56                   	push   %esi
  802016:	e8 68 f1 ff ff       	call   801183 <fd2data>
  80201b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	bf 00 00 00 00       	mov    $0x0,%edi
  802025:	eb 4b                	jmp    802072 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802027:	89 da                	mov    %ebx,%edx
  802029:	89 f0                	mov    %esi,%eax
  80202b:	e8 74 ff ff ff       	call   801fa4 <_pipeisclosed>
  802030:	85 c0                	test   %eax,%eax
  802032:	75 48                	jne    80207c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802034:	e8 35 ed ff ff       	call   800d6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802039:	8b 43 04             	mov    0x4(%ebx),%eax
  80203c:	8b 0b                	mov    (%ebx),%ecx
  80203e:	8d 51 20             	lea    0x20(%ecx),%edx
  802041:	39 d0                	cmp    %edx,%eax
  802043:	73 e2                	jae    802027 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802045:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802048:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80204c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80204f:	89 c2                	mov    %eax,%edx
  802051:	c1 fa 1f             	sar    $0x1f,%edx
  802054:	89 d1                	mov    %edx,%ecx
  802056:	c1 e9 1b             	shr    $0x1b,%ecx
  802059:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80205c:	83 e2 1f             	and    $0x1f,%edx
  80205f:	29 ca                	sub    %ecx,%edx
  802061:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802065:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802069:	83 c0 01             	add    $0x1,%eax
  80206c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206f:	83 c7 01             	add    $0x1,%edi
  802072:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802075:	75 c2                	jne    802039 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802077:	8b 45 10             	mov    0x10(%ebp),%eax
  80207a:	eb 05                	jmp    802081 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80207c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	57                   	push   %edi
  80208d:	56                   	push   %esi
  80208e:	53                   	push   %ebx
  80208f:	83 ec 18             	sub    $0x18,%esp
  802092:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802095:	57                   	push   %edi
  802096:	e8 e8 f0 ff ff       	call   801183 <fd2data>
  80209b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a5:	eb 3d                	jmp    8020e4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020a7:	85 db                	test   %ebx,%ebx
  8020a9:	74 04                	je     8020af <devpipe_read+0x26>
				return i;
  8020ab:	89 d8                	mov    %ebx,%eax
  8020ad:	eb 44                	jmp    8020f3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020af:	89 f2                	mov    %esi,%edx
  8020b1:	89 f8                	mov    %edi,%eax
  8020b3:	e8 ec fe ff ff       	call   801fa4 <_pipeisclosed>
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	75 32                	jne    8020ee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020bc:	e8 ad ec ff ff       	call   800d6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020c1:	8b 06                	mov    (%esi),%eax
  8020c3:	3b 46 04             	cmp    0x4(%esi),%eax
  8020c6:	74 df                	je     8020a7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c8:	99                   	cltd   
  8020c9:	c1 ea 1b             	shr    $0x1b,%edx
  8020cc:	01 d0                	add    %edx,%eax
  8020ce:	83 e0 1f             	and    $0x1f,%eax
  8020d1:	29 d0                	sub    %edx,%eax
  8020d3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020db:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020de:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e1:	83 c3 01             	add    $0x1,%ebx
  8020e4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e7:	75 d8                	jne    8020c1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ec:	eb 05                	jmp    8020f3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f6:	5b                   	pop    %ebx
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    

008020fb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802106:	50                   	push   %eax
  802107:	e8 8e f0 ff ff       	call   80119a <fd_alloc>
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	89 c2                	mov    %eax,%edx
  802111:	85 c0                	test   %eax,%eax
  802113:	0f 88 2c 01 00 00    	js     802245 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802119:	83 ec 04             	sub    $0x4,%esp
  80211c:	68 07 04 00 00       	push   $0x407
  802121:	ff 75 f4             	pushl  -0xc(%ebp)
  802124:	6a 00                	push   $0x0
  802126:	e8 62 ec ff ff       	call   800d8d <sys_page_alloc>
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	89 c2                	mov    %eax,%edx
  802130:	85 c0                	test   %eax,%eax
  802132:	0f 88 0d 01 00 00    	js     802245 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802138:	83 ec 0c             	sub    $0xc,%esp
  80213b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80213e:	50                   	push   %eax
  80213f:	e8 56 f0 ff ff       	call   80119a <fd_alloc>
  802144:	89 c3                	mov    %eax,%ebx
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	0f 88 e2 00 00 00    	js     802233 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802151:	83 ec 04             	sub    $0x4,%esp
  802154:	68 07 04 00 00       	push   $0x407
  802159:	ff 75 f0             	pushl  -0x10(%ebp)
  80215c:	6a 00                	push   $0x0
  80215e:	e8 2a ec ff ff       	call   800d8d <sys_page_alloc>
  802163:	89 c3                	mov    %eax,%ebx
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	0f 88 c3 00 00 00    	js     802233 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	ff 75 f4             	pushl  -0xc(%ebp)
  802176:	e8 08 f0 ff ff       	call   801183 <fd2data>
  80217b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217d:	83 c4 0c             	add    $0xc,%esp
  802180:	68 07 04 00 00       	push   $0x407
  802185:	50                   	push   %eax
  802186:	6a 00                	push   $0x0
  802188:	e8 00 ec ff ff       	call   800d8d <sys_page_alloc>
  80218d:	89 c3                	mov    %eax,%ebx
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	85 c0                	test   %eax,%eax
  802194:	0f 88 89 00 00 00    	js     802223 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219a:	83 ec 0c             	sub    $0xc,%esp
  80219d:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a0:	e8 de ef ff ff       	call   801183 <fd2data>
  8021a5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021ac:	50                   	push   %eax
  8021ad:	6a 00                	push   $0x0
  8021af:	56                   	push   %esi
  8021b0:	6a 00                	push   $0x0
  8021b2:	e8 19 ec ff ff       	call   800dd0 <sys_page_map>
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	83 c4 20             	add    $0x20,%esp
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	78 55                	js     802215 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021d5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021de:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f0:	e8 7e ef ff ff       	call   801173 <fd2num>
  8021f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021fa:	83 c4 04             	add    $0x4,%esp
  8021fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802200:	e8 6e ef ff ff       	call   801173 <fd2num>
  802205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802208:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80220b:	83 c4 10             	add    $0x10,%esp
  80220e:	ba 00 00 00 00       	mov    $0x0,%edx
  802213:	eb 30                	jmp    802245 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	56                   	push   %esi
  802219:	6a 00                	push   $0x0
  80221b:	e8 f2 eb ff ff       	call   800e12 <sys_page_unmap>
  802220:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802223:	83 ec 08             	sub    $0x8,%esp
  802226:	ff 75 f0             	pushl  -0x10(%ebp)
  802229:	6a 00                	push   $0x0
  80222b:	e8 e2 eb ff ff       	call   800e12 <sys_page_unmap>
  802230:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802233:	83 ec 08             	sub    $0x8,%esp
  802236:	ff 75 f4             	pushl  -0xc(%ebp)
  802239:	6a 00                	push   $0x0
  80223b:	e8 d2 eb ff ff       	call   800e12 <sys_page_unmap>
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802245:	89 d0                	mov    %edx,%eax
  802247:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80224a:	5b                   	pop    %ebx
  80224b:	5e                   	pop    %esi
  80224c:	5d                   	pop    %ebp
  80224d:	c3                   	ret    

0080224e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802257:	50                   	push   %eax
  802258:	ff 75 08             	pushl  0x8(%ebp)
  80225b:	e8 89 ef ff ff       	call   8011e9 <fd_lookup>
  802260:	89 c2                	mov    %eax,%edx
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	85 d2                	test   %edx,%edx
  802267:	78 18                	js     802281 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802269:	83 ec 0c             	sub    $0xc,%esp
  80226c:	ff 75 f4             	pushl  -0xc(%ebp)
  80226f:	e8 0f ef ff ff       	call   801183 <fd2data>
	return _pipeisclosed(fd, p);
  802274:	89 c2                	mov    %eax,%edx
  802276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802279:	e8 26 fd ff ff       	call   801fa4 <_pipeisclosed>
  80227e:	83 c4 10             	add    $0x10,%esp
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802286:	b8 00 00 00 00       	mov    $0x0,%eax
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    

0080228d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802293:	68 2b 2d 80 00       	push   $0x802d2b
  802298:	ff 75 0c             	pushl  0xc(%ebp)
  80229b:	e8 e4 e6 ff ff       	call   800984 <strcpy>
	return 0;
}
  8022a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	57                   	push   %edi
  8022ab:	56                   	push   %esi
  8022ac:	53                   	push   %ebx
  8022ad:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022b8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022be:	eb 2d                	jmp    8022ed <devcons_write+0x46>
		m = n - tot;
  8022c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022c3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022c5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022c8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022cd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d0:	83 ec 04             	sub    $0x4,%esp
  8022d3:	53                   	push   %ebx
  8022d4:	03 45 0c             	add    0xc(%ebp),%eax
  8022d7:	50                   	push   %eax
  8022d8:	57                   	push   %edi
  8022d9:	e8 38 e8 ff ff       	call   800b16 <memmove>
		sys_cputs(buf, m);
  8022de:	83 c4 08             	add    $0x8,%esp
  8022e1:	53                   	push   %ebx
  8022e2:	57                   	push   %edi
  8022e3:	e8 e9 e9 ff ff       	call   800cd1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e8:	01 de                	add    %ebx,%esi
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	89 f0                	mov    %esi,%eax
  8022ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f2:	72 cc                	jb     8022c0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    

008022fc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802302:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802307:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80230b:	75 07                	jne    802314 <devcons_read+0x18>
  80230d:	eb 28                	jmp    802337 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80230f:	e8 5a ea ff ff       	call   800d6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802314:	e8 d6 e9 ff ff       	call   800cef <sys_cgetc>
  802319:	85 c0                	test   %eax,%eax
  80231b:	74 f2                	je     80230f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80231d:	85 c0                	test   %eax,%eax
  80231f:	78 16                	js     802337 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802321:	83 f8 04             	cmp    $0x4,%eax
  802324:	74 0c                	je     802332 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802326:	8b 55 0c             	mov    0xc(%ebp),%edx
  802329:	88 02                	mov    %al,(%edx)
	return 1;
  80232b:	b8 01 00 00 00       	mov    $0x1,%eax
  802330:	eb 05                	jmp    802337 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802337:	c9                   	leave  
  802338:	c3                   	ret    

00802339 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80233f:	8b 45 08             	mov    0x8(%ebp),%eax
  802342:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802345:	6a 01                	push   $0x1
  802347:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234a:	50                   	push   %eax
  80234b:	e8 81 e9 ff ff       	call   800cd1 <sys_cputs>
  802350:	83 c4 10             	add    $0x10,%esp
}
  802353:	c9                   	leave  
  802354:	c3                   	ret    

00802355 <getchar>:

int
getchar(void)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80235b:	6a 01                	push   $0x1
  80235d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802360:	50                   	push   %eax
  802361:	6a 00                	push   $0x0
  802363:	e8 f0 f0 ff ff       	call   801458 <read>
	if (r < 0)
  802368:	83 c4 10             	add    $0x10,%esp
  80236b:	85 c0                	test   %eax,%eax
  80236d:	78 0f                	js     80237e <getchar+0x29>
		return r;
	if (r < 1)
  80236f:	85 c0                	test   %eax,%eax
  802371:	7e 06                	jle    802379 <getchar+0x24>
		return -E_EOF;
	return c;
  802373:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802377:	eb 05                	jmp    80237e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802379:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80237e:	c9                   	leave  
  80237f:	c3                   	ret    

00802380 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802389:	50                   	push   %eax
  80238a:	ff 75 08             	pushl  0x8(%ebp)
  80238d:	e8 57 ee ff ff       	call   8011e9 <fd_lookup>
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	85 c0                	test   %eax,%eax
  802397:	78 11                	js     8023aa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023a2:	39 10                	cmp    %edx,(%eax)
  8023a4:	0f 94 c0             	sete   %al
  8023a7:	0f b6 c0             	movzbl %al,%eax
}
  8023aa:	c9                   	leave  
  8023ab:	c3                   	ret    

008023ac <opencons>:

int
opencons(void)
{
  8023ac:	55                   	push   %ebp
  8023ad:	89 e5                	mov    %esp,%ebp
  8023af:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b5:	50                   	push   %eax
  8023b6:	e8 df ed ff ff       	call   80119a <fd_alloc>
  8023bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8023be:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 3e                	js     802402 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023c4:	83 ec 04             	sub    $0x4,%esp
  8023c7:	68 07 04 00 00       	push   $0x407
  8023cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8023cf:	6a 00                	push   $0x0
  8023d1:	e8 b7 e9 ff ff       	call   800d8d <sys_page_alloc>
  8023d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8023d9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	78 23                	js     802402 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023df:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023f4:	83 ec 0c             	sub    $0xc,%esp
  8023f7:	50                   	push   %eax
  8023f8:	e8 76 ed ff ff       	call   801173 <fd2num>
  8023fd:	89 c2                	mov    %eax,%edx
  8023ff:	83 c4 10             	add    $0x10,%esp
}
  802402:	89 d0                	mov    %edx,%eax
  802404:	c9                   	leave  
  802405:	c3                   	ret    

00802406 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	56                   	push   %esi
  80240a:	53                   	push   %ebx
  80240b:	8b 75 08             	mov    0x8(%ebp),%esi
  80240e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802411:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802414:	85 c0                	test   %eax,%eax
  802416:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80241b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80241e:	83 ec 0c             	sub    $0xc,%esp
  802421:	50                   	push   %eax
  802422:	e8 16 eb ff ff       	call   800f3d <sys_ipc_recv>
  802427:	83 c4 10             	add    $0x10,%esp
  80242a:	85 c0                	test   %eax,%eax
  80242c:	79 16                	jns    802444 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80242e:	85 f6                	test   %esi,%esi
  802430:	74 06                	je     802438 <ipc_recv+0x32>
  802432:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802438:	85 db                	test   %ebx,%ebx
  80243a:	74 2c                	je     802468 <ipc_recv+0x62>
  80243c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802442:	eb 24                	jmp    802468 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802444:	85 f6                	test   %esi,%esi
  802446:	74 0a                	je     802452 <ipc_recv+0x4c>
  802448:	a1 40 44 80 00       	mov    0x804440,%eax
  80244d:	8b 40 74             	mov    0x74(%eax),%eax
  802450:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802452:	85 db                	test   %ebx,%ebx
  802454:	74 0a                	je     802460 <ipc_recv+0x5a>
  802456:	a1 40 44 80 00       	mov    0x804440,%eax
  80245b:	8b 40 78             	mov    0x78(%eax),%eax
  80245e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802460:	a1 40 44 80 00       	mov    0x804440,%eax
  802465:	8b 40 70             	mov    0x70(%eax),%eax
}
  802468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80246b:	5b                   	pop    %ebx
  80246c:	5e                   	pop    %esi
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    

0080246f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80246f:	55                   	push   %ebp
  802470:	89 e5                	mov    %esp,%ebp
  802472:	57                   	push   %edi
  802473:	56                   	push   %esi
  802474:	53                   	push   %ebx
  802475:	83 ec 0c             	sub    $0xc,%esp
  802478:	8b 7d 08             	mov    0x8(%ebp),%edi
  80247b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80247e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802481:	85 db                	test   %ebx,%ebx
  802483:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802488:	0f 44 d8             	cmove  %eax,%ebx
  80248b:	eb 1c                	jmp    8024a9 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80248d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802490:	74 12                	je     8024a4 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802492:	50                   	push   %eax
  802493:	68 37 2d 80 00       	push   $0x802d37
  802498:	6a 39                	push   $0x39
  80249a:	68 52 2d 80 00       	push   $0x802d52
  80249f:	e8 80 de ff ff       	call   800324 <_panic>
                 sys_yield();
  8024a4:	e8 c5 e8 ff ff       	call   800d6e <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8024a9:	ff 75 14             	pushl  0x14(%ebp)
  8024ac:	53                   	push   %ebx
  8024ad:	56                   	push   %esi
  8024ae:	57                   	push   %edi
  8024af:	e8 66 ea ff ff       	call   800f1a <sys_ipc_try_send>
  8024b4:	83 c4 10             	add    $0x10,%esp
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	78 d2                	js     80248d <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8024bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024be:	5b                   	pop    %ebx
  8024bf:	5e                   	pop    %esi
  8024c0:	5f                   	pop    %edi
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    

008024c3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024c3:	55                   	push   %ebp
  8024c4:	89 e5                	mov    %esp,%ebp
  8024c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024ce:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024d1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024d7:	8b 52 50             	mov    0x50(%edx),%edx
  8024da:	39 ca                	cmp    %ecx,%edx
  8024dc:	75 0d                	jne    8024eb <ipc_find_env+0x28>
			return envs[i].env_id;
  8024de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024e1:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8024e6:	8b 40 08             	mov    0x8(%eax),%eax
  8024e9:	eb 0e                	jmp    8024f9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024eb:	83 c0 01             	add    $0x1,%eax
  8024ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024f3:	75 d9                	jne    8024ce <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024f5:	66 b8 00 00          	mov    $0x0,%ax
}
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    

008024fb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802501:	89 d0                	mov    %edx,%eax
  802503:	c1 e8 16             	shr    $0x16,%eax
  802506:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80250d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802512:	f6 c1 01             	test   $0x1,%cl
  802515:	74 1d                	je     802534 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802517:	c1 ea 0c             	shr    $0xc,%edx
  80251a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802521:	f6 c2 01             	test   $0x1,%dl
  802524:	74 0e                	je     802534 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802526:	c1 ea 0c             	shr    $0xc,%edx
  802529:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802530:	ef 
  802531:	0f b7 c0             	movzwl %ax,%eax
}
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	83 ec 10             	sub    $0x10,%esp
  802546:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80254a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80254e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802552:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802556:	85 d2                	test   %edx,%edx
  802558:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80255c:	89 34 24             	mov    %esi,(%esp)
  80255f:	89 c8                	mov    %ecx,%eax
  802561:	75 35                	jne    802598 <__udivdi3+0x58>
  802563:	39 f1                	cmp    %esi,%ecx
  802565:	0f 87 bd 00 00 00    	ja     802628 <__udivdi3+0xe8>
  80256b:	85 c9                	test   %ecx,%ecx
  80256d:	89 cd                	mov    %ecx,%ebp
  80256f:	75 0b                	jne    80257c <__udivdi3+0x3c>
  802571:	b8 01 00 00 00       	mov    $0x1,%eax
  802576:	31 d2                	xor    %edx,%edx
  802578:	f7 f1                	div    %ecx
  80257a:	89 c5                	mov    %eax,%ebp
  80257c:	89 f0                	mov    %esi,%eax
  80257e:	31 d2                	xor    %edx,%edx
  802580:	f7 f5                	div    %ebp
  802582:	89 c6                	mov    %eax,%esi
  802584:	89 f8                	mov    %edi,%eax
  802586:	f7 f5                	div    %ebp
  802588:	89 f2                	mov    %esi,%edx
  80258a:	83 c4 10             	add    $0x10,%esp
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    
  802591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802598:	3b 14 24             	cmp    (%esp),%edx
  80259b:	77 7b                	ja     802618 <__udivdi3+0xd8>
  80259d:	0f bd f2             	bsr    %edx,%esi
  8025a0:	83 f6 1f             	xor    $0x1f,%esi
  8025a3:	0f 84 97 00 00 00    	je     802640 <__udivdi3+0x100>
  8025a9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8025ae:	89 d7                	mov    %edx,%edi
  8025b0:	89 f1                	mov    %esi,%ecx
  8025b2:	29 f5                	sub    %esi,%ebp
  8025b4:	d3 e7                	shl    %cl,%edi
  8025b6:	89 c2                	mov    %eax,%edx
  8025b8:	89 e9                	mov    %ebp,%ecx
  8025ba:	d3 ea                	shr    %cl,%edx
  8025bc:	89 f1                	mov    %esi,%ecx
  8025be:	09 fa                	or     %edi,%edx
  8025c0:	8b 3c 24             	mov    (%esp),%edi
  8025c3:	d3 e0                	shl    %cl,%eax
  8025c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025d3:	89 fa                	mov    %edi,%edx
  8025d5:	d3 ea                	shr    %cl,%edx
  8025d7:	89 f1                	mov    %esi,%ecx
  8025d9:	d3 e7                	shl    %cl,%edi
  8025db:	89 e9                	mov    %ebp,%ecx
  8025dd:	d3 e8                	shr    %cl,%eax
  8025df:	09 c7                	or     %eax,%edi
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	f7 74 24 08          	divl   0x8(%esp)
  8025e7:	89 d5                	mov    %edx,%ebp
  8025e9:	89 c7                	mov    %eax,%edi
  8025eb:	f7 64 24 0c          	mull   0xc(%esp)
  8025ef:	39 d5                	cmp    %edx,%ebp
  8025f1:	89 14 24             	mov    %edx,(%esp)
  8025f4:	72 11                	jb     802607 <__udivdi3+0xc7>
  8025f6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025fa:	89 f1                	mov    %esi,%ecx
  8025fc:	d3 e2                	shl    %cl,%edx
  8025fe:	39 c2                	cmp    %eax,%edx
  802600:	73 5e                	jae    802660 <__udivdi3+0x120>
  802602:	3b 2c 24             	cmp    (%esp),%ebp
  802605:	75 59                	jne    802660 <__udivdi3+0x120>
  802607:	8d 47 ff             	lea    -0x1(%edi),%eax
  80260a:	31 f6                	xor    %esi,%esi
  80260c:	89 f2                	mov    %esi,%edx
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	31 f6                	xor    %esi,%esi
  80261a:	31 c0                	xor    %eax,%eax
  80261c:	89 f2                	mov    %esi,%edx
  80261e:	83 c4 10             	add    $0x10,%esp
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	89 f2                	mov    %esi,%edx
  80262a:	31 f6                	xor    %esi,%esi
  80262c:	89 f8                	mov    %edi,%eax
  80262e:	f7 f1                	div    %ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	83 c4 10             	add    $0x10,%esp
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802644:	76 0b                	jbe    802651 <__udivdi3+0x111>
  802646:	31 c0                	xor    %eax,%eax
  802648:	3b 14 24             	cmp    (%esp),%edx
  80264b:	0f 83 37 ff ff ff    	jae    802588 <__udivdi3+0x48>
  802651:	b8 01 00 00 00       	mov    $0x1,%eax
  802656:	e9 2d ff ff ff       	jmp    802588 <__udivdi3+0x48>
  80265b:	90                   	nop
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 f8                	mov    %edi,%eax
  802662:	31 f6                	xor    %esi,%esi
  802664:	e9 1f ff ff ff       	jmp    802588 <__udivdi3+0x48>
  802669:	66 90                	xchg   %ax,%ax
  80266b:	66 90                	xchg   %ax,%ax
  80266d:	66 90                	xchg   %ax,%ax
  80266f:	90                   	nop

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	83 ec 20             	sub    $0x20,%esp
  802676:	8b 44 24 34          	mov    0x34(%esp),%eax
  80267a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80267e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802682:	89 c6                	mov    %eax,%esi
  802684:	89 44 24 10          	mov    %eax,0x10(%esp)
  802688:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80268c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802690:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802694:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802698:	89 74 24 18          	mov    %esi,0x18(%esp)
  80269c:	85 c0                	test   %eax,%eax
  80269e:	89 c2                	mov    %eax,%edx
  8026a0:	75 1e                	jne    8026c0 <__umoddi3+0x50>
  8026a2:	39 f7                	cmp    %esi,%edi
  8026a4:	76 52                	jbe    8026f8 <__umoddi3+0x88>
  8026a6:	89 c8                	mov    %ecx,%eax
  8026a8:	89 f2                	mov    %esi,%edx
  8026aa:	f7 f7                	div    %edi
  8026ac:	89 d0                	mov    %edx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	83 c4 20             	add    $0x20,%esp
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    
  8026b7:	89 f6                	mov    %esi,%esi
  8026b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8026c0:	39 f0                	cmp    %esi,%eax
  8026c2:	77 5c                	ja     802720 <__umoddi3+0xb0>
  8026c4:	0f bd e8             	bsr    %eax,%ebp
  8026c7:	83 f5 1f             	xor    $0x1f,%ebp
  8026ca:	75 64                	jne    802730 <__umoddi3+0xc0>
  8026cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8026d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8026d4:	0f 86 f6 00 00 00    	jbe    8027d0 <__umoddi3+0x160>
  8026da:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8026de:	0f 82 ec 00 00 00    	jb     8027d0 <__umoddi3+0x160>
  8026e4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026e8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8026ec:	83 c4 20             	add    $0x20,%esp
  8026ef:	5e                   	pop    %esi
  8026f0:	5f                   	pop    %edi
  8026f1:	5d                   	pop    %ebp
  8026f2:	c3                   	ret    
  8026f3:	90                   	nop
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	85 ff                	test   %edi,%edi
  8026fa:	89 fd                	mov    %edi,%ebp
  8026fc:	75 0b                	jne    802709 <__umoddi3+0x99>
  8026fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802703:	31 d2                	xor    %edx,%edx
  802705:	f7 f7                	div    %edi
  802707:	89 c5                	mov    %eax,%ebp
  802709:	8b 44 24 10          	mov    0x10(%esp),%eax
  80270d:	31 d2                	xor    %edx,%edx
  80270f:	f7 f5                	div    %ebp
  802711:	89 c8                	mov    %ecx,%eax
  802713:	f7 f5                	div    %ebp
  802715:	eb 95                	jmp    8026ac <__umoddi3+0x3c>
  802717:	89 f6                	mov    %esi,%esi
  802719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 20             	add    $0x20,%esp
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    
  80272b:	90                   	nop
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	b8 20 00 00 00       	mov    $0x20,%eax
  802735:	89 e9                	mov    %ebp,%ecx
  802737:	29 e8                	sub    %ebp,%eax
  802739:	d3 e2                	shl    %cl,%edx
  80273b:	89 c7                	mov    %eax,%edi
  80273d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802741:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 c1                	mov    %eax,%ecx
  80274b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80274f:	09 d1                	or     %edx,%ecx
  802751:	89 fa                	mov    %edi,%edx
  802753:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802757:	89 e9                	mov    %ebp,%ecx
  802759:	d3 e0                	shl    %cl,%eax
  80275b:	89 f9                	mov    %edi,%ecx
  80275d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802761:	89 f0                	mov    %esi,%eax
  802763:	d3 e8                	shr    %cl,%eax
  802765:	89 e9                	mov    %ebp,%ecx
  802767:	89 c7                	mov    %eax,%edi
  802769:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80276d:	d3 e6                	shl    %cl,%esi
  80276f:	89 d1                	mov    %edx,%ecx
  802771:	89 fa                	mov    %edi,%edx
  802773:	d3 e8                	shr    %cl,%eax
  802775:	89 e9                	mov    %ebp,%ecx
  802777:	09 f0                	or     %esi,%eax
  802779:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80277d:	f7 74 24 10          	divl   0x10(%esp)
  802781:	d3 e6                	shl    %cl,%esi
  802783:	89 d1                	mov    %edx,%ecx
  802785:	f7 64 24 0c          	mull   0xc(%esp)
  802789:	39 d1                	cmp    %edx,%ecx
  80278b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80278f:	89 d7                	mov    %edx,%edi
  802791:	89 c6                	mov    %eax,%esi
  802793:	72 0a                	jb     80279f <__umoddi3+0x12f>
  802795:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802799:	73 10                	jae    8027ab <__umoddi3+0x13b>
  80279b:	39 d1                	cmp    %edx,%ecx
  80279d:	75 0c                	jne    8027ab <__umoddi3+0x13b>
  80279f:	89 d7                	mov    %edx,%edi
  8027a1:	89 c6                	mov    %eax,%esi
  8027a3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8027a7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8027ab:	89 ca                	mov    %ecx,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027b3:	29 f0                	sub    %esi,%eax
  8027b5:	19 fa                	sbb    %edi,%edx
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8027be:	89 d7                	mov    %edx,%edi
  8027c0:	d3 e7                	shl    %cl,%edi
  8027c2:	89 e9                	mov    %ebp,%ecx
  8027c4:	09 f8                	or     %edi,%eax
  8027c6:	d3 ea                	shr    %cl,%edx
  8027c8:	83 c4 20             	add    $0x20,%esp
  8027cb:	5e                   	pop    %esi
  8027cc:	5f                   	pop    %edi
  8027cd:	5d                   	pop    %ebp
  8027ce:	c3                   	ret    
  8027cf:	90                   	nop
  8027d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027d4:	29 f9                	sub    %edi,%ecx
  8027d6:	19 c6                	sbb    %eax,%esi
  8027d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8027dc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8027e0:	e9 ff fe ff ff       	jmp    8026e4 <__umoddi3+0x74>
