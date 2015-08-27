
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f6 05 00 00       	call   800627 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 a0 0c 00 00       	call   800ce7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 e6 13 00 00       	call   80143f <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 83 13 00 00       	call   8013eb <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 09 13 00 00       	call   801382 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 00 29 80 00       	mov    $0x802900,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	89 c2                	mov    %eax,%edx
  80009b:	c1 ea 1f             	shr    $0x1f,%edx
  80009e:	84 d2                	test   %dl,%dl
  8000a0:	74 17                	je     8000b9 <umain+0x3b>
  8000a2:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 29 80 00       	push   $0x80290b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 29 80 00       	push   $0x802925
  8000b4:	e8 ce 05 00 00       	call   800687 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 2a 80 00       	push   $0x802ac0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 29 80 00       	push   $0x802925
  8000cc:	e8 b6 05 00 00       	call   800687 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 29 80 00       	mov    $0x802935,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 29 80 00       	push   $0x80293e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 29 80 00       	push   $0x802925
  8000f1:	e8 91 05 00 00       	call   800687 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 e4 2a 80 00       	push   $0x802ae4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 29 80 00       	push   $0x802925
  800120:	e8 62 05 00 00       	call   800687 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 29 80 00       	push   $0x802956
  80012d:	e8 2e 06 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 6a 29 80 00       	push   $0x80296a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 29 80 00       	push   $0x802925
  80015b:	e8 27 05 00 00       	call   800687 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 40 0b 00 00       	call   800cae <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 2a 0b 00 00       	call   800cae <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 14 2b 80 00       	push   $0x802b14
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 29 80 00       	push   $0x802925
  800196:	e8 ec 04 00 00       	call   800687 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 29 80 00       	push   $0x802978
  8001a3:	e8 b8 05 00 00       	call   800760 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6e 0c 00 00       	call   800e2c <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 8b 29 80 00       	push   $0x80298b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 29 80 00       	push   $0x802925
  8001e6:	e8 9c 04 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 91 0b 00 00       	call   800d91 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 99 29 80 00       	push   $0x802999
  80020f:	6a 34                	push   $0x34
  800211:	68 25 29 80 00       	push   $0x802925
  800216:	e8 6c 04 00 00       	call   800687 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 29 80 00       	push   $0x8029b7
  800223:	e8 38 05 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 29 80 00       	push   $0x8029ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 29 80 00       	push   $0x802925
  800249:	e8 39 04 00 00       	call   800687 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 29 80 00       	push   $0x8029d9
  800256:	e8 05 05 00 00       	call   800760 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 eb 0e 00 00       	call   801175 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 3c 2b 80 00       	push   $0x802b3c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 29 80 00       	push   $0x802925
  8002b8:	e8 ca 03 00 00       	call   800687 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 29 80 00       	push   $0x8029ed
  8002c5:	e8 96 04 00 00       	call   800760 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 2a 80 00       	mov    $0x802a03,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 2a 80 00       	push   $0x802a0d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 29 80 00       	push   $0x802925
  8002ed:	e8 95 03 00 00       	call   800687 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 a8 09 00 00       	call   800cae <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 87 09 00 00       	call   800cae <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 26 2a 80 00       	push   $0x802a26
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 29 80 00       	push   $0x802925
  80033b:	e8 47 03 00 00       	call   800687 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 2a 80 00       	push   $0x802a35
  800348:	e8 13 04 00 00       	call   800760 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 bf 0a 00 00       	call   800e2c <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 74 2b 80 00       	push   $0x802b74
  800390:	6a 51                	push   $0x51
  800392:	68 25 29 80 00       	push   $0x802925
  800397:	e8 eb 02 00 00       	call   800687 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 04 09 00 00       	call   800cae <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 d8                	cmp    %ebx,%eax
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 94 2b 80 00       	push   $0x802b94
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 29 80 00       	push   $0x802925
  8003be:	e8 c4 02 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b9 09 00 00       	call   800d91 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 cc 2b 80 00       	push   $0x802bcc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 29 80 00       	push   $0x802925
  8003ee:	e8 94 02 00 00       	call   800687 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 2b 80 00       	push   $0x802bfc
  8003fb:	e8 60 03 00 00       	call   800760 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 29 80 00       	push   $0x802900
  80040a:	e8 fa 17 00 00       	call   801c09 <open>
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 1f             	shr    $0x1f,%edx
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	84 d2                	test   %dl,%dl
  800419:	74 17                	je     800432 <umain+0x3b4>
  80041b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 29 80 00       	push   $0x802911
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 29 80 00       	push   $0x802925
  80042d:	e8 55 02 00 00       	call   800687 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 2a 80 00       	push   $0x802a49
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 29 80 00       	push   $0x802925
  800445:	e8 3d 02 00 00       	call   800687 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 29 80 00       	push   $0x802935
  800454:	e8 b0 17 00 00       	call   801c09 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 29 80 00       	push   $0x802944
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 29 80 00       	push   $0x802925
  80046d:	e8 15 02 00 00       	call   800687 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 20 2c 80 00       	push   $0x802c20
  800498:	6a 62                	push   $0x62
  80049a:	68 25 29 80 00       	push   $0x802925
  80049f:	e8 e3 01 00 00       	call   800687 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 29 80 00       	push   $0x80295c
  8004ac:	e8 af 02 00 00       	call   800760 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 2a 80 00       	push   $0x802a64
  8004be:	e8 46 17 00 00       	call   801c09 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 2a 80 00       	push   $0x802a69
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 29 80 00       	push   $0x802925
  8004d9:	e8 a9 01 00 00       	call   800687 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 38 09 00 00       	call   800e2c <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 1b 13 00 00       	call   801832 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 2a 80 00       	push   $0x802a78
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 29 80 00       	push   $0x802925
  80052f:	e8 53 01 00 00       	call   800687 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 d0 10 00 00       	call   80161c <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 2a 80 00       	push   $0x802a64
  800556:	e8 ae 16 00 00       	call   801c09 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 2a 80 00       	push   $0x802a8a
  80056a:	6a 71                	push   $0x71
  80056c:	68 25 29 80 00       	push   $0x802925
  800571:	e8 11 01 00 00       	call   800687 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 57 12 00 00       	call   8017ed <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 2a 80 00       	push   $0x802a98
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 25 29 80 00       	push   $0x802925
  8005ae:	e8 d4 00 00 00       	call   800687 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 2c 80 00       	push   $0x802c48
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 25 29 80 00       	push   $0x802925
  8005d0:	e8 b2 00 00 00       	call   800687 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 74 2c 80 00       	push   $0x802c74
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 25 29 80 00       	push   $0x802925
  8005f0:	e8 92 00 00 00       	call   800687 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f5:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  8005fb:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  800601:	0f 8e 7a ff ff ff    	jle    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	56                   	push   %esi
  80060b:	e8 0c 10 00 00       	call   80161c <close>
	cprintf("large file is good\n");
  800610:	c7 04 24 a9 2a 80 00 	movl   $0x802aa9,(%esp)
  800617:	e8 44 01 00 00       	call   800760 <cprintf>
  80061c:	83 c4 10             	add    $0x10,%esp
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
  80062c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80062f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800632:	e8 7b 0a 00 00       	call   8010b2 <sys_getenvid>
  800637:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80063f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800644:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800649:	85 db                	test   %ebx,%ebx
  80064b:	7e 07                	jle    800654 <libmain+0x2d>
		binaryname = argv[0];
  80064d:	8b 06                	mov    (%esi),%eax
  80064f:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	56                   	push   %esi
  800658:	53                   	push   %ebx
  800659:	e8 20 fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065e:	e8 0a 00 00 00       	call   80066d <exit>
  800663:	83 c4 10             	add    $0x10,%esp
}
  800666:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800673:	e8 d1 0f 00 00       	call   801649 <close_all>
	sys_env_destroy(0);
  800678:	83 ec 0c             	sub    $0xc,%esp
  80067b:	6a 00                	push   $0x0
  80067d:	e8 ef 09 00 00       	call   801071 <sys_env_destroy>
  800682:	83 c4 10             	add    $0x10,%esp
}
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	56                   	push   %esi
  80068b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80068f:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800695:	e8 18 0a 00 00       	call   8010b2 <sys_getenvid>
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	56                   	push   %esi
  8006a4:	50                   	push   %eax
  8006a5:	68 cc 2c 80 00       	push   $0x802ccc
  8006aa:	e8 b1 00 00 00       	call   800760 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006af:	83 c4 18             	add    $0x18,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	e8 54 00 00 00       	call   80070f <vcprintf>
	cprintf("\n");
  8006bb:	c7 04 24 88 31 80 00 	movl   $0x803188,(%esp)
  8006c2:	e8 99 00 00 00       	call   800760 <cprintf>
  8006c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ca:	cc                   	int3   
  8006cb:	eb fd                	jmp    8006ca <_panic+0x43>

008006cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d7:	8b 13                	mov    (%ebx),%edx
  8006d9:	8d 42 01             	lea    0x1(%edx),%eax
  8006dc:	89 03                	mov    %eax,(%ebx)
  8006de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006ea:	75 1a                	jne    800706 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	68 ff 00 00 00       	push   $0xff
  8006f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f7:	50                   	push   %eax
  8006f8:	e8 37 09 00 00       	call   801034 <sys_cputs>
		b->idx = 0;
  8006fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800703:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800706:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800718:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80071f:	00 00 00 
	b.cnt = 0;
  800722:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800729:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 cd 06 80 00       	push   $0x8006cd
  80073e:	e8 4f 01 00 00       	call   800892 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800743:	83 c4 08             	add    $0x8,%esp
  800746:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	e8 dc 08 00 00       	call   801034 <sys_cputs>

	return b.cnt;
}
  800758:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800766:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 08             	pushl  0x8(%ebp)
  80076d:	e8 9d ff ff ff       	call   80070f <vcprintf>
	va_end(ap);

	return cnt;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	57                   	push   %edi
  800778:	56                   	push   %esi
  800779:	53                   	push   %ebx
  80077a:	83 ec 1c             	sub    $0x1c,%esp
  80077d:	89 c7                	mov    %eax,%edi
  80077f:	89 d6                	mov    %edx,%esi
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	89 d1                	mov    %edx,%ecx
  800789:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078f:	8b 45 10             	mov    0x10(%ebp),%eax
  800792:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800795:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800798:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80079f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8007a2:	72 05                	jb     8007a9 <printnum+0x35>
  8007a4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8007a7:	77 3e                	ja     8007e7 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a9:	83 ec 0c             	sub    $0xc,%esp
  8007ac:	ff 75 18             	pushl  0x18(%ebp)
  8007af:	83 eb 01             	sub    $0x1,%ebx
  8007b2:	53                   	push   %ebx
  8007b3:	50                   	push   %eax
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c3:	e8 78 1e 00 00       	call   802640 <__udivdi3>
  8007c8:	83 c4 18             	add    $0x18,%esp
  8007cb:	52                   	push   %edx
  8007cc:	50                   	push   %eax
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	89 f8                	mov    %edi,%eax
  8007d1:	e8 9e ff ff ff       	call   800774 <printnum>
  8007d6:	83 c4 20             	add    $0x20,%esp
  8007d9:	eb 13                	jmp    8007ee <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	56                   	push   %esi
  8007df:	ff 75 18             	pushl  0x18(%ebp)
  8007e2:	ff d7                	call   *%edi
  8007e4:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007e7:	83 eb 01             	sub    $0x1,%ebx
  8007ea:	85 db                	test   %ebx,%ebx
  8007ec:	7f ed                	jg     8007db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8007fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800801:	e8 6a 1f 00 00       	call   802770 <__umoddi3>
  800806:	83 c4 14             	add    $0x14,%esp
  800809:	0f be 80 ef 2c 80 00 	movsbl 0x802cef(%eax),%eax
  800810:	50                   	push   %eax
  800811:	ff d7                	call   *%edi
  800813:	83 c4 10             	add    $0x10,%esp
}
  800816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800821:	83 fa 01             	cmp    $0x1,%edx
  800824:	7e 0e                	jle    800834 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800826:	8b 10                	mov    (%eax),%edx
  800828:	8d 4a 08             	lea    0x8(%edx),%ecx
  80082b:	89 08                	mov    %ecx,(%eax)
  80082d:	8b 02                	mov    (%edx),%eax
  80082f:	8b 52 04             	mov    0x4(%edx),%edx
  800832:	eb 22                	jmp    800856 <getuint+0x38>
	else if (lflag)
  800834:	85 d2                	test   %edx,%edx
  800836:	74 10                	je     800848 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80083d:	89 08                	mov    %ecx,(%eax)
  80083f:	8b 02                	mov    (%edx),%eax
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
  800846:	eb 0e                	jmp    800856 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 02                	mov    (%edx),%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80085e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800862:	8b 10                	mov    (%eax),%edx
  800864:	3b 50 04             	cmp    0x4(%eax),%edx
  800867:	73 0a                	jae    800873 <sprintputch+0x1b>
		*b->buf++ = ch;
  800869:	8d 4a 01             	lea    0x1(%edx),%ecx
  80086c:	89 08                	mov    %ecx,(%eax)
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	88 02                	mov    %al,(%edx)
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80087e:	50                   	push   %eax
  80087f:	ff 75 10             	pushl  0x10(%ebp)
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	ff 75 08             	pushl  0x8(%ebp)
  800888:	e8 05 00 00 00       	call   800892 <vprintfmt>
	va_end(ap);
  80088d:	83 c4 10             	add    $0x10,%esp
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 2c             	sub    $0x2c,%esp
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008a4:	eb 12                	jmp    8008b8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	0f 84 90 03 00 00    	je     800c3e <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	50                   	push   %eax
  8008b3:	ff d6                	call   *%esi
  8008b5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b8:	83 c7 01             	add    $0x1,%edi
  8008bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008bf:	83 f8 25             	cmp    $0x25,%eax
  8008c2:	75 e2                	jne    8008a6 <vprintfmt+0x14>
  8008c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 07                	jmp    8008eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8d 47 01             	lea    0x1(%edi),%eax
  8008ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f1:	0f b6 07             	movzbl (%edi),%eax
  8008f4:	0f b6 c8             	movzbl %al,%ecx
  8008f7:	83 e8 23             	sub    $0x23,%eax
  8008fa:	3c 55                	cmp    $0x55,%al
  8008fc:	0f 87 21 03 00 00    	ja     800c23 <vprintfmt+0x391>
  800902:	0f b6 c0             	movzbl %al,%eax
  800905:	ff 24 85 40 2e 80 00 	jmp    *0x802e40(,%eax,4)
  80090c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80090f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800913:	eb d6                	jmp    8008eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
  80091d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800920:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800923:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800927:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80092a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80092d:	83 fa 09             	cmp    $0x9,%edx
  800930:	77 39                	ja     80096b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800932:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800935:	eb e9                	jmp    800920 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8d 48 04             	lea    0x4(%eax),%ecx
  80093d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800940:	8b 00                	mov    (%eax),%eax
  800942:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800948:	eb 27                	jmp    800971 <vprintfmt+0xdf>
  80094a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80094d:	85 c0                	test   %eax,%eax
  80094f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800954:	0f 49 c8             	cmovns %eax,%ecx
  800957:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095d:	eb 8c                	jmp    8008eb <vprintfmt+0x59>
  80095f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800962:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800969:	eb 80                	jmp    8008eb <vprintfmt+0x59>
  80096b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80096e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800971:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800975:	0f 89 70 ff ff ff    	jns    8008eb <vprintfmt+0x59>
				width = precision, precision = -1;
  80097b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80097e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800981:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800988:	e9 5e ff ff ff       	jmp    8008eb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80098d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800990:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800993:	e9 53 ff ff ff       	jmp    8008eb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800998:	8b 45 14             	mov    0x14(%ebp),%eax
  80099b:	8d 50 04             	lea    0x4(%eax),%edx
  80099e:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a1:	83 ec 08             	sub    $0x8,%esp
  8009a4:	53                   	push   %ebx
  8009a5:	ff 30                	pushl  (%eax)
  8009a7:	ff d6                	call   *%esi
			break;
  8009a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009af:	e9 04 ff ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bd:	8b 00                	mov    (%eax),%eax
  8009bf:	99                   	cltd   
  8009c0:	31 d0                	xor    %edx,%eax
  8009c2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c4:	83 f8 0f             	cmp    $0xf,%eax
  8009c7:	7f 0b                	jg     8009d4 <vprintfmt+0x142>
  8009c9:	8b 14 85 c0 2f 80 00 	mov    0x802fc0(,%eax,4),%edx
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	75 18                	jne    8009ec <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009d4:	50                   	push   %eax
  8009d5:	68 07 2d 80 00       	push   $0x802d07
  8009da:	53                   	push   %ebx
  8009db:	56                   	push   %esi
  8009dc:	e8 94 fe ff ff       	call   800875 <printfmt>
  8009e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009e7:	e9 cc fe ff ff       	jmp    8008b8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009ec:	52                   	push   %edx
  8009ed:	68 1d 31 80 00       	push   $0x80311d
  8009f2:	53                   	push   %ebx
  8009f3:	56                   	push   %esi
  8009f4:	e8 7c fe ff ff       	call   800875 <printfmt>
  8009f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ff:	e9 b4 fe ff ff       	jmp    8008b8 <vprintfmt+0x26>
  800a04:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a0a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a10:	8d 50 04             	lea    0x4(%eax),%edx
  800a13:	89 55 14             	mov    %edx,0x14(%ebp)
  800a16:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a18:	85 ff                	test   %edi,%edi
  800a1a:	ba 00 2d 80 00       	mov    $0x802d00,%edx
  800a1f:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800a22:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a26:	0f 84 92 00 00 00    	je     800abe <vprintfmt+0x22c>
  800a2c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a30:	0f 8e 96 00 00 00    	jle    800acc <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	51                   	push   %ecx
  800a3a:	57                   	push   %edi
  800a3b:	e8 86 02 00 00       	call   800cc6 <strnlen>
  800a40:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a43:	29 c1                	sub    %eax,%ecx
  800a45:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a48:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a52:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a55:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a57:	eb 0f                	jmp    800a68 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800a59:	83 ec 08             	sub    $0x8,%esp
  800a5c:	53                   	push   %ebx
  800a5d:	ff 75 e0             	pushl  -0x20(%ebp)
  800a60:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a62:	83 ef 01             	sub    $0x1,%edi
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	85 ff                	test   %edi,%edi
  800a6a:	7f ed                	jg     800a59 <vprintfmt+0x1c7>
  800a6c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	0f 49 c1             	cmovns %ecx,%eax
  800a7c:	29 c1                	sub    %eax,%ecx
  800a7e:	89 75 08             	mov    %esi,0x8(%ebp)
  800a81:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a84:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	eb 4d                	jmp    800ad8 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8f:	74 1b                	je     800aac <vprintfmt+0x21a>
  800a91:	0f be c0             	movsbl %al,%eax
  800a94:	83 e8 20             	sub    $0x20,%eax
  800a97:	83 f8 5e             	cmp    $0x5e,%eax
  800a9a:	76 10                	jbe    800aac <vprintfmt+0x21a>
					putch('?', putdat);
  800a9c:	83 ec 08             	sub    $0x8,%esp
  800a9f:	ff 75 0c             	pushl  0xc(%ebp)
  800aa2:	6a 3f                	push   $0x3f
  800aa4:	ff 55 08             	call   *0x8(%ebp)
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	eb 0d                	jmp    800ab9 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	52                   	push   %edx
  800ab3:	ff 55 08             	call   *0x8(%ebp)
  800ab6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab9:	83 eb 01             	sub    $0x1,%ebx
  800abc:	eb 1a                	jmp    800ad8 <vprintfmt+0x246>
  800abe:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aca:	eb 0c                	jmp    800ad8 <vprintfmt+0x246>
  800acc:	89 75 08             	mov    %esi,0x8(%ebp)
  800acf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad8:	83 c7 01             	add    $0x1,%edi
  800adb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800adf:	0f be d0             	movsbl %al,%edx
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	74 23                	je     800b09 <vprintfmt+0x277>
  800ae6:	85 f6                	test   %esi,%esi
  800ae8:	78 a1                	js     800a8b <vprintfmt+0x1f9>
  800aea:	83 ee 01             	sub    $0x1,%esi
  800aed:	79 9c                	jns    800a8b <vprintfmt+0x1f9>
  800aef:	89 df                	mov    %ebx,%edi
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
  800af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af7:	eb 18                	jmp    800b11 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af9:	83 ec 08             	sub    $0x8,%esp
  800afc:	53                   	push   %ebx
  800afd:	6a 20                	push   $0x20
  800aff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b01:	83 ef 01             	sub    $0x1,%edi
  800b04:	83 c4 10             	add    $0x10,%esp
  800b07:	eb 08                	jmp    800b11 <vprintfmt+0x27f>
  800b09:	89 df                	mov    %ebx,%edi
  800b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b11:	85 ff                	test   %edi,%edi
  800b13:	7f e4                	jg     800af9 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b18:	e9 9b fd ff ff       	jmp    8008b8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1d:	83 fa 01             	cmp    $0x1,%edx
  800b20:	7e 16                	jle    800b38 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8d 50 08             	lea    0x8(%eax),%edx
  800b28:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2b:	8b 50 04             	mov    0x4(%eax),%edx
  800b2e:	8b 00                	mov    (%eax),%eax
  800b30:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b33:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b36:	eb 32                	jmp    800b6a <vprintfmt+0x2d8>
	else if (lflag)
  800b38:	85 d2                	test   %edx,%edx
  800b3a:	74 18                	je     800b54 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800b3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3f:	8d 50 04             	lea    0x4(%eax),%edx
  800b42:	89 55 14             	mov    %edx,0x14(%ebp)
  800b45:	8b 00                	mov    (%eax),%eax
  800b47:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4a:	89 c1                	mov    %eax,%ecx
  800b4c:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b52:	eb 16                	jmp    800b6a <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800b54:	8b 45 14             	mov    0x14(%ebp),%eax
  800b57:	8d 50 04             	lea    0x4(%eax),%edx
  800b5a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5d:	8b 00                	mov    (%eax),%eax
  800b5f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b62:	89 c1                	mov    %eax,%ecx
  800b64:	c1 f9 1f             	sar    $0x1f,%ecx
  800b67:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b70:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b75:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b79:	79 74                	jns    800bef <vprintfmt+0x35d>
				putch('-', putdat);
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	53                   	push   %ebx
  800b7f:	6a 2d                	push   $0x2d
  800b81:	ff d6                	call   *%esi
				num = -(long long) num;
  800b83:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b86:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b89:	f7 d8                	neg    %eax
  800b8b:	83 d2 00             	adc    $0x0,%edx
  800b8e:	f7 da                	neg    %edx
  800b90:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b93:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b98:	eb 55                	jmp    800bef <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b9a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9d:	e8 7c fc ff ff       	call   80081e <getuint>
			base = 10;
  800ba2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba7:	eb 46                	jmp    800bef <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ba9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bac:	e8 6d fc ff ff       	call   80081e <getuint>
                        base = 8;
  800bb1:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800bb6:	eb 37                	jmp    800bef <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb8:	83 ec 08             	sub    $0x8,%esp
  800bbb:	53                   	push   %ebx
  800bbc:	6a 30                	push   $0x30
  800bbe:	ff d6                	call   *%esi
			putch('x', putdat);
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	53                   	push   %ebx
  800bc4:	6a 78                	push   $0x78
  800bc6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcb:	8d 50 04             	lea    0x4(%eax),%edx
  800bce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd1:	8b 00                	mov    (%eax),%eax
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bdb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800be0:	eb 0d                	jmp    800bef <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be2:	8d 45 14             	lea    0x14(%ebp),%eax
  800be5:	e8 34 fc ff ff       	call   80081e <getuint>
			base = 16;
  800bea:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf6:	57                   	push   %edi
  800bf7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bfa:	51                   	push   %ecx
  800bfb:	52                   	push   %edx
  800bfc:	50                   	push   %eax
  800bfd:	89 da                	mov    %ebx,%edx
  800bff:	89 f0                	mov    %esi,%eax
  800c01:	e8 6e fb ff ff       	call   800774 <printnum>
			break;
  800c06:	83 c4 20             	add    $0x20,%esp
  800c09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0c:	e9 a7 fc ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c11:	83 ec 08             	sub    $0x8,%esp
  800c14:	53                   	push   %ebx
  800c15:	51                   	push   %ecx
  800c16:	ff d6                	call   *%esi
			break;
  800c18:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1e:	e9 95 fc ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c23:	83 ec 08             	sub    $0x8,%esp
  800c26:	53                   	push   %ebx
  800c27:	6a 25                	push   $0x25
  800c29:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	eb 03                	jmp    800c33 <vprintfmt+0x3a1>
  800c30:	83 ef 01             	sub    $0x1,%edi
  800c33:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c37:	75 f7                	jne    800c30 <vprintfmt+0x39e>
  800c39:	e9 7a fc ff ff       	jmp    8008b8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 18             	sub    $0x18,%esp
  800c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	74 26                	je     800c8d <vsnprintf+0x47>
  800c67:	85 d2                	test   %edx,%edx
  800c69:	7e 22                	jle    800c8d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6b:	ff 75 14             	pushl  0x14(%ebp)
  800c6e:	ff 75 10             	pushl  0x10(%ebp)
  800c71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c74:	50                   	push   %eax
  800c75:	68 58 08 80 00       	push   $0x800858
  800c7a:	e8 13 fc ff ff       	call   800892 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c82:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	eb 05                	jmp    800c92 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c9a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9d:	50                   	push   %eax
  800c9e:	ff 75 10             	pushl  0x10(%ebp)
  800ca1:	ff 75 0c             	pushl  0xc(%ebp)
  800ca4:	ff 75 08             	pushl  0x8(%ebp)
  800ca7:	e8 9a ff ff ff       	call   800c46 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb9:	eb 03                	jmp    800cbe <strlen+0x10>
		n++;
  800cbb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc2:	75 f7                	jne    800cbb <strlen+0xd>
		n++;
	return n;
}
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ccf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd4:	eb 03                	jmp    800cd9 <strnlen+0x13>
		n++;
  800cd6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd9:	39 c2                	cmp    %eax,%edx
  800cdb:	74 08                	je     800ce5 <strnlen+0x1f>
  800cdd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ce1:	75 f3                	jne    800cd6 <strnlen+0x10>
  800ce3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf1:	89 c2                	mov    %eax,%edx
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d00:	84 db                	test   %bl,%bl
  800d02:	75 ef                	jne    800cf3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d04:	5b                   	pop    %ebx
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	53                   	push   %ebx
  800d0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0e:	53                   	push   %ebx
  800d0f:	e8 9a ff ff ff       	call   800cae <strlen>
  800d14:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	01 d8                	add    %ebx,%eax
  800d1c:	50                   	push   %eax
  800d1d:	e8 c5 ff ff ff       	call   800ce7 <strcpy>
	return dst;
}
  800d22:	89 d8                	mov    %ebx,%eax
  800d24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	89 f3                	mov    %esi,%ebx
  800d36:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d39:	89 f2                	mov    %esi,%edx
  800d3b:	eb 0f                	jmp    800d4c <strncpy+0x23>
		*dst++ = *src;
  800d3d:	83 c2 01             	add    $0x1,%edx
  800d40:	0f b6 01             	movzbl (%ecx),%eax
  800d43:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d46:	80 39 01             	cmpb   $0x1,(%ecx)
  800d49:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4c:	39 da                	cmp    %ebx,%edx
  800d4e:	75 ed                	jne    800d3d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d50:	89 f0                	mov    %esi,%eax
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 10             	mov    0x10(%ebp),%edx
  800d64:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d66:	85 d2                	test   %edx,%edx
  800d68:	74 21                	je     800d8b <strlcpy+0x35>
  800d6a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6e:	89 f2                	mov    %esi,%edx
  800d70:	eb 09                	jmp    800d7b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d72:	83 c2 01             	add    $0x1,%edx
  800d75:	83 c1 01             	add    $0x1,%ecx
  800d78:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d7b:	39 c2                	cmp    %eax,%edx
  800d7d:	74 09                	je     800d88 <strlcpy+0x32>
  800d7f:	0f b6 19             	movzbl (%ecx),%ebx
  800d82:	84 db                	test   %bl,%bl
  800d84:	75 ec                	jne    800d72 <strlcpy+0x1c>
  800d86:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d88:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d8b:	29 f0                	sub    %esi,%eax
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d9a:	eb 06                	jmp    800da2 <strcmp+0x11>
		p++, q++;
  800d9c:	83 c1 01             	add    $0x1,%ecx
  800d9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da2:	0f b6 01             	movzbl (%ecx),%eax
  800da5:	84 c0                	test   %al,%al
  800da7:	74 04                	je     800dad <strcmp+0x1c>
  800da9:	3a 02                	cmp    (%edx),%al
  800dab:	74 ef                	je     800d9c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dad:	0f b6 c0             	movzbl %al,%eax
  800db0:	0f b6 12             	movzbl (%edx),%edx
  800db3:	29 d0                	sub    %edx,%eax
}
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc6:	eb 06                	jmp    800dce <strncmp+0x17>
		n--, p++, q++;
  800dc8:	83 c0 01             	add    $0x1,%eax
  800dcb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dce:	39 d8                	cmp    %ebx,%eax
  800dd0:	74 15                	je     800de7 <strncmp+0x30>
  800dd2:	0f b6 08             	movzbl (%eax),%ecx
  800dd5:	84 c9                	test   %cl,%cl
  800dd7:	74 04                	je     800ddd <strncmp+0x26>
  800dd9:	3a 0a                	cmp    (%edx),%cl
  800ddb:	74 eb                	je     800dc8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	0f b6 12             	movzbl (%edx),%edx
  800de3:	29 d0                	sub    %edx,%eax
  800de5:	eb 05                	jmp    800dec <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df9:	eb 07                	jmp    800e02 <strchr+0x13>
		if (*s == c)
  800dfb:	38 ca                	cmp    %cl,%dl
  800dfd:	74 0f                	je     800e0e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dff:	83 c0 01             	add    $0x1,%eax
  800e02:	0f b6 10             	movzbl (%eax),%edx
  800e05:	84 d2                	test   %dl,%dl
  800e07:	75 f2                	jne    800dfb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e1a:	eb 03                	jmp    800e1f <strfind+0xf>
  800e1c:	83 c0 01             	add    $0x1,%eax
  800e1f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e22:	84 d2                	test   %dl,%dl
  800e24:	74 04                	je     800e2a <strfind+0x1a>
  800e26:	38 ca                	cmp    %cl,%dl
  800e28:	75 f2                	jne    800e1c <strfind+0xc>
			break;
	return (char *) s;
}
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e38:	85 c9                	test   %ecx,%ecx
  800e3a:	74 36                	je     800e72 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e42:	75 28                	jne    800e6c <memset+0x40>
  800e44:	f6 c1 03             	test   $0x3,%cl
  800e47:	75 23                	jne    800e6c <memset+0x40>
		c &= 0xFF;
  800e49:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4d:	89 d3                	mov    %edx,%ebx
  800e4f:	c1 e3 08             	shl    $0x8,%ebx
  800e52:	89 d6                	mov    %edx,%esi
  800e54:	c1 e6 18             	shl    $0x18,%esi
  800e57:	89 d0                	mov    %edx,%eax
  800e59:	c1 e0 10             	shl    $0x10,%eax
  800e5c:	09 f0                	or     %esi,%eax
  800e5e:	09 c2                	or     %eax,%edx
  800e60:	89 d0                	mov    %edx,%eax
  800e62:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e64:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e67:	fc                   	cld    
  800e68:	f3 ab                	rep stos %eax,%es:(%edi)
  800e6a:	eb 06                	jmp    800e72 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6f:	fc                   	cld    
  800e70:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e72:	89 f8                	mov    %edi,%eax
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e87:	39 c6                	cmp    %eax,%esi
  800e89:	73 35                	jae    800ec0 <memmove+0x47>
  800e8b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8e:	39 d0                	cmp    %edx,%eax
  800e90:	73 2e                	jae    800ec0 <memmove+0x47>
		s += n;
		d += n;
  800e92:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e95:	89 d6                	mov    %edx,%esi
  800e97:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e99:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9f:	75 13                	jne    800eb4 <memmove+0x3b>
  800ea1:	f6 c1 03             	test   $0x3,%cl
  800ea4:	75 0e                	jne    800eb4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ea6:	83 ef 04             	sub    $0x4,%edi
  800ea9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eaf:	fd                   	std    
  800eb0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb2:	eb 09                	jmp    800ebd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eb4:	83 ef 01             	sub    $0x1,%edi
  800eb7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eba:	fd                   	std    
  800ebb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ebd:	fc                   	cld    
  800ebe:	eb 1d                	jmp    800edd <memmove+0x64>
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ec4:	f6 c2 03             	test   $0x3,%dl
  800ec7:	75 0f                	jne    800ed8 <memmove+0x5f>
  800ec9:	f6 c1 03             	test   $0x3,%cl
  800ecc:	75 0a                	jne    800ed8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ece:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ed1:	89 c7                	mov    %eax,%edi
  800ed3:	fc                   	cld    
  800ed4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed6:	eb 05                	jmp    800edd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed8:	89 c7                	mov    %eax,%edi
  800eda:	fc                   	cld    
  800edb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee4:	ff 75 10             	pushl  0x10(%ebp)
  800ee7:	ff 75 0c             	pushl  0xc(%ebp)
  800eea:	ff 75 08             	pushl  0x8(%ebp)
  800eed:	e8 87 ff ff ff       	call   800e79 <memmove>
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f04:	eb 1a                	jmp    800f20 <memcmp+0x2c>
		if (*s1 != *s2)
  800f06:	0f b6 08             	movzbl (%eax),%ecx
  800f09:	0f b6 1a             	movzbl (%edx),%ebx
  800f0c:	38 d9                	cmp    %bl,%cl
  800f0e:	74 0a                	je     800f1a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f10:	0f b6 c1             	movzbl %cl,%eax
  800f13:	0f b6 db             	movzbl %bl,%ebx
  800f16:	29 d8                	sub    %ebx,%eax
  800f18:	eb 0f                	jmp    800f29 <memcmp+0x35>
		s1++, s2++;
  800f1a:	83 c0 01             	add    $0x1,%eax
  800f1d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f20:	39 f0                	cmp    %esi,%eax
  800f22:	75 e2                	jne    800f06 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f36:	89 c2                	mov    %eax,%edx
  800f38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f3b:	eb 07                	jmp    800f44 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3d:	38 08                	cmp    %cl,(%eax)
  800f3f:	74 07                	je     800f48 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f41:	83 c0 01             	add    $0x1,%eax
  800f44:	39 d0                	cmp    %edx,%eax
  800f46:	72 f5                	jb     800f3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f56:	eb 03                	jmp    800f5b <strtol+0x11>
		s++;
  800f58:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5b:	0f b6 01             	movzbl (%ecx),%eax
  800f5e:	3c 09                	cmp    $0x9,%al
  800f60:	74 f6                	je     800f58 <strtol+0xe>
  800f62:	3c 20                	cmp    $0x20,%al
  800f64:	74 f2                	je     800f58 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f66:	3c 2b                	cmp    $0x2b,%al
  800f68:	75 0a                	jne    800f74 <strtol+0x2a>
		s++;
  800f6a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800f72:	eb 10                	jmp    800f84 <strtol+0x3a>
  800f74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f79:	3c 2d                	cmp    $0x2d,%al
  800f7b:	75 07                	jne    800f84 <strtol+0x3a>
		s++, neg = 1;
  800f7d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800f80:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f84:	85 db                	test   %ebx,%ebx
  800f86:	0f 94 c0             	sete   %al
  800f89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f8f:	75 19                	jne    800faa <strtol+0x60>
  800f91:	80 39 30             	cmpb   $0x30,(%ecx)
  800f94:	75 14                	jne    800faa <strtol+0x60>
  800f96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f9a:	0f 85 82 00 00 00    	jne    801022 <strtol+0xd8>
		s += 2, base = 16;
  800fa0:	83 c1 02             	add    $0x2,%ecx
  800fa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa8:	eb 16                	jmp    800fc0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800faa:	84 c0                	test   %al,%al
  800fac:	74 12                	je     800fc0 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb3:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb6:	75 08                	jne    800fc0 <strtol+0x76>
		s++, base = 8;
  800fb8:	83 c1 01             	add    $0x1,%ecx
  800fbb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc8:	0f b6 11             	movzbl (%ecx),%edx
  800fcb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fce:	89 f3                	mov    %esi,%ebx
  800fd0:	80 fb 09             	cmp    $0x9,%bl
  800fd3:	77 08                	ja     800fdd <strtol+0x93>
			dig = *s - '0';
  800fd5:	0f be d2             	movsbl %dl,%edx
  800fd8:	83 ea 30             	sub    $0x30,%edx
  800fdb:	eb 22                	jmp    800fff <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800fdd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fe0:	89 f3                	mov    %esi,%ebx
  800fe2:	80 fb 19             	cmp    $0x19,%bl
  800fe5:	77 08                	ja     800fef <strtol+0xa5>
			dig = *s - 'a' + 10;
  800fe7:	0f be d2             	movsbl %dl,%edx
  800fea:	83 ea 57             	sub    $0x57,%edx
  800fed:	eb 10                	jmp    800fff <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800fef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ff2:	89 f3                	mov    %esi,%ebx
  800ff4:	80 fb 19             	cmp    $0x19,%bl
  800ff7:	77 16                	ja     80100f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ff9:	0f be d2             	movsbl %dl,%edx
  800ffc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fff:	3b 55 10             	cmp    0x10(%ebp),%edx
  801002:	7d 0f                	jge    801013 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801004:	83 c1 01             	add    $0x1,%ecx
  801007:	0f af 45 10          	imul   0x10(%ebp),%eax
  80100b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100d:	eb b9                	jmp    800fc8 <strtol+0x7e>
  80100f:	89 c2                	mov    %eax,%edx
  801011:	eb 02                	jmp    801015 <strtol+0xcb>
  801013:	89 c2                	mov    %eax,%edx

	if (endptr)
  801015:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801019:	74 0d                	je     801028 <strtol+0xde>
		*endptr = (char *) s;
  80101b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80101e:	89 0e                	mov    %ecx,(%esi)
  801020:	eb 06                	jmp    801028 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801022:	84 c0                	test   %al,%al
  801024:	75 92                	jne    800fb8 <strtol+0x6e>
  801026:	eb 98                	jmp    800fc0 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801028:	f7 da                	neg    %edx
  80102a:	85 ff                	test   %edi,%edi
  80102c:	0f 45 c2             	cmovne %edx,%eax
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 c3                	mov    %eax,%ebx
  801047:	89 c7                	mov    %eax,%edi
  801049:	89 c6                	mov    %eax,%esi
  80104b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_cgetc>:

int
sys_cgetc(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801058:	ba 00 00 00 00       	mov    $0x0,%edx
  80105d:	b8 01 00 00 00       	mov    $0x1,%eax
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 d3                	mov    %edx,%ebx
  801066:	89 d7                	mov    %edx,%edi
  801068:	89 d6                	mov    %edx,%esi
  80106a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80107a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107f:	b8 03 00 00 00       	mov    $0x3,%eax
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 cb                	mov    %ecx,%ebx
  801089:	89 cf                	mov    %ecx,%edi
  80108b:	89 ce                	mov    %ecx,%esi
  80108d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	7e 17                	jle    8010aa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 03                	push   $0x3
  801099:	68 1f 30 80 00       	push   $0x80301f
  80109e:	6a 22                	push   $0x22
  8010a0:	68 3c 30 80 00       	push   $0x80303c
  8010a5:	e8 dd f5 ff ff       	call   800687 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bd:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c2:	89 d1                	mov    %edx,%ecx
  8010c4:	89 d3                	mov    %edx,%ebx
  8010c6:	89 d7                	mov    %edx,%edi
  8010c8:	89 d6                	mov    %edx,%esi
  8010ca:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_yield>:

void
sys_yield(void)
{      
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e1:	89 d1                	mov    %edx,%ecx
  8010e3:	89 d3                	mov    %edx,%ebx
  8010e5:	89 d7                	mov    %edx,%edi
  8010e7:	89 d6                	mov    %edx,%esi
  8010e9:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8010f9:	be 00 00 00 00       	mov    $0x0,%esi
  8010fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110c:	89 f7                	mov    %esi,%edi
  80110e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801110:	85 c0                	test   %eax,%eax
  801112:	7e 17                	jle    80112b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	50                   	push   %eax
  801118:	6a 04                	push   $0x4
  80111a:	68 1f 30 80 00       	push   $0x80301f
  80111f:	6a 22                	push   $0x22
  801121:	68 3c 30 80 00       	push   $0x80303c
  801126:	e8 5c f5 ff ff       	call   800687 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80113c:	b8 05 00 00 00       	mov    $0x5,%eax
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114d:	8b 75 18             	mov    0x18(%ebp),%esi
  801150:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7e 17                	jle    80116d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	50                   	push   %eax
  80115a:	6a 05                	push   $0x5
  80115c:	68 1f 30 80 00       	push   $0x80301f
  801161:	6a 22                	push   $0x22
  801163:	68 3c 30 80 00       	push   $0x80303c
  801168:	e8 1a f5 ff ff       	call   800687 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80117e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801183:	b8 06 00 00 00       	mov    $0x6,%eax
  801188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
  80118e:	89 df                	mov    %ebx,%edi
  801190:	89 de                	mov    %ebx,%esi
  801192:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801194:	85 c0                	test   %eax,%eax
  801196:	7e 17                	jle    8011af <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	50                   	push   %eax
  80119c:	6a 06                	push   $0x6
  80119e:	68 1f 30 80 00       	push   $0x80301f
  8011a3:	6a 22                	push   $0x22
  8011a5:	68 3c 30 80 00       	push   $0x80303c
  8011aa:	e8 d8 f4 ff ff       	call   800687 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d0:	89 df                	mov    %ebx,%edi
  8011d2:	89 de                	mov    %ebx,%esi
  8011d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	7e 17                	jle    8011f1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	50                   	push   %eax
  8011de:	6a 08                	push   $0x8
  8011e0:	68 1f 30 80 00       	push   $0x80301f
  8011e5:	6a 22                	push   $0x22
  8011e7:	68 3c 30 80 00       	push   $0x80303c
  8011ec:	e8 96 f4 ff ff       	call   800687 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  8011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	b8 09 00 00 00       	mov    $0x9,%eax
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	89 df                	mov    %ebx,%edi
  801214:	89 de                	mov    %ebx,%esi
  801216:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801218:	85 c0                	test   %eax,%eax
  80121a:	7e 17                	jle    801233 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121c:	83 ec 0c             	sub    $0xc,%esp
  80121f:	50                   	push   %eax
  801220:	6a 09                	push   $0x9
  801222:	68 1f 30 80 00       	push   $0x80301f
  801227:	6a 22                	push   $0x22
  801229:	68 3c 30 80 00       	push   $0x80303c
  80122e:	e8 54 f4 ff ff       	call   800687 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801244:	bb 00 00 00 00       	mov    $0x0,%ebx
  801249:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801251:	8b 55 08             	mov    0x8(%ebp),%edx
  801254:	89 df                	mov    %ebx,%edi
  801256:	89 de                	mov    %ebx,%esi
  801258:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125a:	85 c0                	test   %eax,%eax
  80125c:	7e 17                	jle    801275 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	50                   	push   %eax
  801262:	6a 0a                	push   $0xa
  801264:	68 1f 30 80 00       	push   $0x80301f
  801269:	6a 22                	push   $0x22
  80126b:	68 3c 30 80 00       	push   $0x80303c
  801270:	e8 12 f4 ff ff       	call   800687 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801283:	be 00 00 00 00       	mov    $0x0,%esi
  801288:	b8 0c 00 00 00       	mov    $0xc,%eax
  80128d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801290:	8b 55 08             	mov    0x8(%ebp),%edx
  801293:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801296:	8b 7d 14             	mov    0x14(%ebp),%edi
  801299:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5f                   	pop    %edi
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ae:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b6:	89 cb                	mov    %ecx,%ebx
  8012b8:	89 cf                	mov    %ecx,%edi
  8012ba:	89 ce                	mov    %ecx,%esi
  8012bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	7e 17                	jle    8012d9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	50                   	push   %eax
  8012c6:	6a 0d                	push   $0xd
  8012c8:	68 1f 30 80 00       	push   $0x80301f
  8012cd:	6a 22                	push   $0x22
  8012cf:	68 3c 30 80 00       	push   $0x80303c
  8012d4:	e8 ae f3 ff ff       	call   800687 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012f1:	89 d1                	mov    %edx,%ecx
  8012f3:	89 d3                	mov    %edx,%ebx
  8012f5:	89 d7                	mov    %edx,%edi
  8012f7:	89 d6                	mov    %edx,%esi
  8012f9:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sys_transmit>:

int
sys_transmit(void *addr)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801313:	8b 55 08             	mov    0x8(%ebp),%edx
  801316:	89 cb                	mov    %ecx,%ebx
  801318:	89 cf                	mov    %ecx,%edi
  80131a:	89 ce                	mov    %ecx,%esi
  80131c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80131e:	85 c0                	test   %eax,%eax
  801320:	7e 17                	jle    801339 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	50                   	push   %eax
  801326:	6a 0f                	push   $0xf
  801328:	68 1f 30 80 00       	push   $0x80301f
  80132d:	6a 22                	push   $0x22
  80132f:	68 3c 30 80 00       	push   $0x80303c
  801334:	e8 4e f3 ff ff       	call   800687 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801339:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5f                   	pop    %edi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <sys_recv>:

int
sys_recv(void *addr)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	57                   	push   %edi
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80134a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134f:	b8 10 00 00 00       	mov    $0x10,%eax
  801354:	8b 55 08             	mov    0x8(%ebp),%edx
  801357:	89 cb                	mov    %ecx,%ebx
  801359:	89 cf                	mov    %ecx,%edi
  80135b:	89 ce                	mov    %ecx,%esi
  80135d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135f:	85 c0                	test   %eax,%eax
  801361:	7e 17                	jle    80137a <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	50                   	push   %eax
  801367:	6a 10                	push   $0x10
  801369:	68 1f 30 80 00       	push   $0x80301f
  80136e:	6a 22                	push   $0x22
  801370:	68 3c 30 80 00       	push   $0x80303c
  801375:	e8 0d f3 ff ff       	call   800687 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80137a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	8b 75 08             	mov    0x8(%ebp),%esi
  80138a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801390:	85 c0                	test   %eax,%eax
  801392:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801397:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	50                   	push   %eax
  80139e:	e8 fd fe ff ff       	call   8012a0 <sys_ipc_recv>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	79 16                	jns    8013c0 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  8013aa:	85 f6                	test   %esi,%esi
  8013ac:	74 06                	je     8013b4 <ipc_recv+0x32>
  8013ae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  8013b4:	85 db                	test   %ebx,%ebx
  8013b6:	74 2c                	je     8013e4 <ipc_recv+0x62>
  8013b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013be:	eb 24                	jmp    8013e4 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	74 0a                	je     8013ce <ipc_recv+0x4c>
  8013c4:	a1 08 50 80 00       	mov    0x805008,%eax
  8013c9:	8b 40 74             	mov    0x74(%eax),%eax
  8013cc:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8013ce:	85 db                	test   %ebx,%ebx
  8013d0:	74 0a                	je     8013dc <ipc_recv+0x5a>
  8013d2:	a1 08 50 80 00       	mov    0x805008,%eax
  8013d7:	8b 40 78             	mov    0x78(%eax),%eax
  8013da:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8013dc:	a1 08 50 80 00       	mov    0x805008,%eax
  8013e1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8013fd:	85 db                	test   %ebx,%ebx
  8013ff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801404:	0f 44 d8             	cmove  %eax,%ebx
  801407:	eb 1c                	jmp    801425 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801409:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80140c:	74 12                	je     801420 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80140e:	50                   	push   %eax
  80140f:	68 4a 30 80 00       	push   $0x80304a
  801414:	6a 39                	push   $0x39
  801416:	68 65 30 80 00       	push   $0x803065
  80141b:	e8 67 f2 ff ff       	call   800687 <_panic>
                 sys_yield();
  801420:	e8 ac fc ff ff       	call   8010d1 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801425:	ff 75 14             	pushl  0x14(%ebp)
  801428:	53                   	push   %ebx
  801429:	56                   	push   %esi
  80142a:	57                   	push   %edi
  80142b:	e8 4d fe ff ff       	call   80127d <sys_ipc_try_send>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 d2                	js     801409 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801437:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80144a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80144d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801453:	8b 52 50             	mov    0x50(%edx),%edx
  801456:	39 ca                	cmp    %ecx,%edx
  801458:	75 0d                	jne    801467 <ipc_find_env+0x28>
			return envs[i].env_id;
  80145a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80145d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801462:	8b 40 08             	mov    0x8(%eax),%eax
  801465:	eb 0e                	jmp    801475 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801467:	83 c0 01             	add    $0x1,%eax
  80146a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80146f:	75 d9                	jne    80144a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801471:	66 b8 00 00          	mov    $0x0,%ax
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	05 00 00 00 30       	add    $0x30000000,%eax
  801482:	c1 e8 0c             	shr    $0xc,%eax
}
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801492:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801497:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 ea 16             	shr    $0x16,%edx
  8014ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b5:	f6 c2 01             	test   $0x1,%dl
  8014b8:	74 11                	je     8014cb <fd_alloc+0x2d>
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	c1 ea 0c             	shr    $0xc,%edx
  8014bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	75 09                	jne    8014d4 <fd_alloc+0x36>
			*fd_store = fd;
  8014cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d2:	eb 17                	jmp    8014eb <fd_alloc+0x4d>
  8014d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014de:	75 c9                	jne    8014a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014f3:	83 f8 1f             	cmp    $0x1f,%eax
  8014f6:	77 36                	ja     80152e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014f8:	c1 e0 0c             	shl    $0xc,%eax
  8014fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 16             	shr    $0x16,%edx
  801505:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150c:	f6 c2 01             	test   $0x1,%dl
  80150f:	74 24                	je     801535 <fd_lookup+0x48>
  801511:	89 c2                	mov    %eax,%edx
  801513:	c1 ea 0c             	shr    $0xc,%edx
  801516:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151d:	f6 c2 01             	test   $0x1,%dl
  801520:	74 1a                	je     80153c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801522:	8b 55 0c             	mov    0xc(%ebp),%edx
  801525:	89 02                	mov    %eax,(%edx)
	return 0;
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
  80152c:	eb 13                	jmp    801541 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80152e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801533:	eb 0c                	jmp    801541 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801535:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153a:	eb 05                	jmp    801541 <fd_lookup+0x54>
  80153c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	eb 13                	jmp    801566 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801553:	39 08                	cmp    %ecx,(%eax)
  801555:	75 0c                	jne    801563 <dev_lookup+0x20>
			*dev = devtab[i];
  801557:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
  801561:	eb 36                	jmp    801599 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801563:	83 c2 01             	add    $0x1,%edx
  801566:	8b 04 95 f0 30 80 00 	mov    0x8030f0(,%edx,4),%eax
  80156d:	85 c0                	test   %eax,%eax
  80156f:	75 e2                	jne    801553 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801571:	a1 08 50 80 00       	mov    0x805008,%eax
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	51                   	push   %ecx
  80157d:	50                   	push   %eax
  80157e:	68 70 30 80 00       	push   $0x803070
  801583:	e8 d8 f1 ff ff       	call   800760 <cprintf>
	*dev = 0;
  801588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 10             	sub    $0x10,%esp
  8015a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015ad:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015b3:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b6:	50                   	push   %eax
  8015b7:	e8 31 ff ff ff       	call   8014ed <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 05                	js     8015c8 <fd_close+0x2d>
	    || fd != fd2)
  8015c3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015c6:	74 0c                	je     8015d4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015c8:	84 db                	test   %bl,%bl
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	0f 44 c2             	cmove  %edx,%eax
  8015d2:	eb 41                	jmp    801615 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 36                	pushl  (%esi)
  8015dd:	e8 61 ff ff ff       	call   801543 <dev_lookup>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 1a                	js     801605 <fd_close+0x6a>
		if (dev->dev_close)
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 0b                	je     801605 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	56                   	push   %esi
  8015fe:	ff d0                	call   *%eax
  801600:	89 c3                	mov    %eax,%ebx
  801602:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	56                   	push   %esi
  801609:	6a 00                	push   $0x0
  80160b:	e8 65 fb ff ff       	call   801175 <sys_page_unmap>
	return r;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	89 d8                	mov    %ebx,%eax
}
  801615:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 bf fe ff ff       	call   8014ed <fd_lookup>
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 d2                	test   %edx,%edx
  801635:	78 10                	js     801647 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	6a 01                	push   $0x1
  80163c:	ff 75 f4             	pushl  -0xc(%ebp)
  80163f:	e8 57 ff ff ff       	call   80159b <fd_close>
  801644:	83 c4 10             	add    $0x10,%esp
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <close_all>:

void
close_all(void)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801650:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	53                   	push   %ebx
  801659:	e8 be ff ff ff       	call   80161c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80165e:	83 c3 01             	add    $0x1,%ebx
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	83 fb 20             	cmp    $0x20,%ebx
  801667:	75 ec                	jne    801655 <close_all+0xc>
		close(i);
}
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	57                   	push   %edi
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 2c             	sub    $0x2c,%esp
  801677:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80167a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 67 fe ff ff       	call   8014ed <fd_lookup>
  801686:	89 c2                	mov    %eax,%edx
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	85 d2                	test   %edx,%edx
  80168d:	0f 88 c1 00 00 00    	js     801754 <dup+0xe6>
		return r;
	close(newfdnum);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	56                   	push   %esi
  801697:	e8 80 ff ff ff       	call   80161c <close>

	newfd = INDEX2FD(newfdnum);
  80169c:	89 f3                	mov    %esi,%ebx
  80169e:	c1 e3 0c             	shl    $0xc,%ebx
  8016a1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016a7:	83 c4 04             	add    $0x4,%esp
  8016aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ad:	e8 d5 fd ff ff       	call   801487 <fd2data>
  8016b2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016b4:	89 1c 24             	mov    %ebx,(%esp)
  8016b7:	e8 cb fd ff ff       	call   801487 <fd2data>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016c2:	89 f8                	mov    %edi,%eax
  8016c4:	c1 e8 16             	shr    $0x16,%eax
  8016c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016ce:	a8 01                	test   $0x1,%al
  8016d0:	74 37                	je     801709 <dup+0x9b>
  8016d2:	89 f8                	mov    %edi,%eax
  8016d4:	c1 e8 0c             	shr    $0xc,%eax
  8016d7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016de:	f6 c2 01             	test   $0x1,%dl
  8016e1:	74 26                	je     801709 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f6:	6a 00                	push   $0x0
  8016f8:	57                   	push   %edi
  8016f9:	6a 00                	push   $0x0
  8016fb:	e8 33 fa ff ff       	call   801133 <sys_page_map>
  801700:	89 c7                	mov    %eax,%edi
  801702:	83 c4 20             	add    $0x20,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 2e                	js     801737 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801709:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170c:	89 d0                	mov    %edx,%eax
  80170e:	c1 e8 0c             	shr    $0xc,%eax
  801711:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	25 07 0e 00 00       	and    $0xe07,%eax
  801720:	50                   	push   %eax
  801721:	53                   	push   %ebx
  801722:	6a 00                	push   $0x0
  801724:	52                   	push   %edx
  801725:	6a 00                	push   $0x0
  801727:	e8 07 fa ff ff       	call   801133 <sys_page_map>
  80172c:	89 c7                	mov    %eax,%edi
  80172e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801731:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801733:	85 ff                	test   %edi,%edi
  801735:	79 1d                	jns    801754 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	53                   	push   %ebx
  80173b:	6a 00                	push   $0x0
  80173d:	e8 33 fa ff ff       	call   801175 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801742:	83 c4 08             	add    $0x8,%esp
  801745:	ff 75 d4             	pushl  -0x2c(%ebp)
  801748:	6a 00                	push   $0x0
  80174a:	e8 26 fa ff ff       	call   801175 <sys_page_unmap>
	return r;
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	89 f8                	mov    %edi,%eax
}
  801754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5f                   	pop    %edi
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 14             	sub    $0x14,%esp
  801763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801766:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	53                   	push   %ebx
  80176b:	e8 7d fd ff ff       	call   8014ed <fd_lookup>
  801770:	83 c4 08             	add    $0x8,%esp
  801773:	89 c2                	mov    %eax,%edx
  801775:	85 c0                	test   %eax,%eax
  801777:	78 6d                	js     8017e6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177f:	50                   	push   %eax
  801780:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801783:	ff 30                	pushl  (%eax)
  801785:	e8 b9 fd ff ff       	call   801543 <dev_lookup>
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 4c                	js     8017dd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801791:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801794:	8b 42 08             	mov    0x8(%edx),%eax
  801797:	83 e0 03             	and    $0x3,%eax
  80179a:	83 f8 01             	cmp    $0x1,%eax
  80179d:	75 21                	jne    8017c0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80179f:	a1 08 50 80 00       	mov    0x805008,%eax
  8017a4:	8b 40 48             	mov    0x48(%eax),%eax
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	53                   	push   %ebx
  8017ab:	50                   	push   %eax
  8017ac:	68 b4 30 80 00       	push   $0x8030b4
  8017b1:	e8 aa ef ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017be:	eb 26                	jmp    8017e6 <read+0x8a>
	}
	if (!dev->dev_read)
  8017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c3:	8b 40 08             	mov    0x8(%eax),%eax
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	74 17                	je     8017e1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	ff 75 10             	pushl  0x10(%ebp)
  8017d0:	ff 75 0c             	pushl  0xc(%ebp)
  8017d3:	52                   	push   %edx
  8017d4:	ff d0                	call   *%eax
  8017d6:	89 c2                	mov    %eax,%edx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	eb 09                	jmp    8017e6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	eb 05                	jmp    8017e6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017e6:	89 d0                	mov    %edx,%eax
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	57                   	push   %edi
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801801:	eb 21                	jmp    801824 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801803:	83 ec 04             	sub    $0x4,%esp
  801806:	89 f0                	mov    %esi,%eax
  801808:	29 d8                	sub    %ebx,%eax
  80180a:	50                   	push   %eax
  80180b:	89 d8                	mov    %ebx,%eax
  80180d:	03 45 0c             	add    0xc(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	57                   	push   %edi
  801812:	e8 45 ff ff ff       	call   80175c <read>
		if (m < 0)
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 0c                	js     80182a <readn+0x3d>
			return m;
		if (m == 0)
  80181e:	85 c0                	test   %eax,%eax
  801820:	74 06                	je     801828 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801822:	01 c3                	add    %eax,%ebx
  801824:	39 f3                	cmp    %esi,%ebx
  801826:	72 db                	jb     801803 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801828:	89 d8                	mov    %ebx,%eax
}
  80182a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5f                   	pop    %edi
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 14             	sub    $0x14,%esp
  801839:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	53                   	push   %ebx
  801841:	e8 a7 fc ff ff       	call   8014ed <fd_lookup>
  801846:	83 c4 08             	add    $0x8,%esp
  801849:	89 c2                	mov    %eax,%edx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 68                	js     8018b7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801859:	ff 30                	pushl  (%eax)
  80185b:	e8 e3 fc ff ff       	call   801543 <dev_lookup>
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 47                	js     8018ae <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186e:	75 21                	jne    801891 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801870:	a1 08 50 80 00       	mov    0x805008,%eax
  801875:	8b 40 48             	mov    0x48(%eax),%eax
  801878:	83 ec 04             	sub    $0x4,%esp
  80187b:	53                   	push   %ebx
  80187c:	50                   	push   %eax
  80187d:	68 d0 30 80 00       	push   $0x8030d0
  801882:	e8 d9 ee ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80188f:	eb 26                	jmp    8018b7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801891:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801894:	8b 52 0c             	mov    0xc(%edx),%edx
  801897:	85 d2                	test   %edx,%edx
  801899:	74 17                	je     8018b2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	ff 75 10             	pushl  0x10(%ebp)
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	50                   	push   %eax
  8018a5:	ff d2                	call   *%edx
  8018a7:	89 c2                	mov    %eax,%edx
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	eb 09                	jmp    8018b7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	eb 05                	jmp    8018b7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018b7:	89 d0                	mov    %edx,%eax
  8018b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <seek>:

int
seek(int fdnum, off_t offset)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	ff 75 08             	pushl  0x8(%ebp)
  8018cb:	e8 1d fc ff ff       	call   8014ed <fd_lookup>
  8018d0:	83 c4 08             	add    $0x8,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 0e                	js     8018e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 14             	sub    $0x14,%esp
  8018ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	53                   	push   %ebx
  8018f6:	e8 f2 fb ff ff       	call   8014ed <fd_lookup>
  8018fb:	83 c4 08             	add    $0x8,%esp
  8018fe:	89 c2                	mov    %eax,%edx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 65                	js     801969 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	ff 30                	pushl  (%eax)
  801910:	e8 2e fc ff ff       	call   801543 <dev_lookup>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 44                	js     801960 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80191c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801923:	75 21                	jne    801946 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801925:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80192a:	8b 40 48             	mov    0x48(%eax),%eax
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	53                   	push   %ebx
  801931:	50                   	push   %eax
  801932:	68 90 30 80 00       	push   $0x803090
  801937:	e8 24 ee ff ff       	call   800760 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801944:	eb 23                	jmp    801969 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801946:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801949:	8b 52 18             	mov    0x18(%edx),%edx
  80194c:	85 d2                	test   %edx,%edx
  80194e:	74 14                	je     801964 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	ff 75 0c             	pushl  0xc(%ebp)
  801956:	50                   	push   %eax
  801957:	ff d2                	call   *%edx
  801959:	89 c2                	mov    %eax,%edx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	eb 09                	jmp    801969 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801960:	89 c2                	mov    %eax,%edx
  801962:	eb 05                	jmp    801969 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801964:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	53                   	push   %ebx
  801974:	83 ec 14             	sub    $0x14,%esp
  801977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	ff 75 08             	pushl  0x8(%ebp)
  801981:	e8 67 fb ff ff       	call   8014ed <fd_lookup>
  801986:	83 c4 08             	add    $0x8,%esp
  801989:	89 c2                	mov    %eax,%edx
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 58                	js     8019e7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801999:	ff 30                	pushl  (%eax)
  80199b:	e8 a3 fb ff ff       	call   801543 <dev_lookup>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 37                	js     8019de <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019ae:	74 32                	je     8019e2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ba:	00 00 00 
	stat->st_isdir = 0;
  8019bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c4:	00 00 00 
	stat->st_dev = dev;
  8019c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	53                   	push   %ebx
  8019d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d4:	ff 50 14             	call   *0x14(%eax)
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	eb 09                	jmp    8019e7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	eb 05                	jmp    8019e7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019e7:	89 d0                	mov    %edx,%eax
  8019e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019f3:	83 ec 08             	sub    $0x8,%esp
  8019f6:	6a 00                	push   $0x0
  8019f8:	ff 75 08             	pushl  0x8(%ebp)
  8019fb:	e8 09 02 00 00       	call   801c09 <open>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 db                	test   %ebx,%ebx
  801a07:	78 1b                	js     801a24 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	ff 75 0c             	pushl  0xc(%ebp)
  801a0f:	53                   	push   %ebx
  801a10:	e8 5b ff ff ff       	call   801970 <fstat>
  801a15:	89 c6                	mov    %eax,%esi
	close(fd);
  801a17:	89 1c 24             	mov    %ebx,(%esp)
  801a1a:	e8 fd fb ff ff       	call   80161c <close>
	return r;
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	89 f0                	mov    %esi,%eax
}
  801a24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	89 c6                	mov    %eax,%esi
  801a32:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a34:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a3b:	75 12                	jne    801a4f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	6a 01                	push   $0x1
  801a42:	e8 f8 f9 ff ff       	call   80143f <ipc_find_env>
  801a47:	a3 00 50 80 00       	mov    %eax,0x805000
  801a4c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a4f:	6a 07                	push   $0x7
  801a51:	68 00 60 80 00       	push   $0x806000
  801a56:	56                   	push   %esi
  801a57:	ff 35 00 50 80 00    	pushl  0x805000
  801a5d:	e8 89 f9 ff ff       	call   8013eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a62:	83 c4 0c             	add    $0xc,%esp
  801a65:	6a 00                	push   $0x0
  801a67:	53                   	push   %ebx
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 13 f9 ff ff       	call   801382 <ipc_recv>
}
  801a6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a82:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a94:	b8 02 00 00 00       	mov    $0x2,%eax
  801a99:	e8 8d ff ff ff       	call   801a2b <fsipc>
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	8b 40 0c             	mov    0xc(%eax),%eax
  801aac:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab6:	b8 06 00 00 00       	mov    $0x6,%eax
  801abb:	e8 6b ff ff ff       	call   801a2b <fsipc>
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad2:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  801adc:	b8 05 00 00 00       	mov    $0x5,%eax
  801ae1:	e8 45 ff ff ff       	call   801a2b <fsipc>
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	85 d2                	test   %edx,%edx
  801aea:	78 2c                	js     801b18 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aec:	83 ec 08             	sub    $0x8,%esp
  801aef:	68 00 60 80 00       	push   $0x806000
  801af4:	53                   	push   %ebx
  801af5:	e8 ed f1 ff ff       	call   800ce7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801afa:	a1 80 60 80 00       	mov    0x806080,%eax
  801aff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b05:	a1 84 60 80 00       	mov    0x806084,%eax
  801b0a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	57                   	push   %edi
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2f:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801b37:	eb 3d                	jmp    801b76 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801b39:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801b3f:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801b44:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801b47:	83 ec 04             	sub    $0x4,%esp
  801b4a:	57                   	push   %edi
  801b4b:	53                   	push   %ebx
  801b4c:	68 08 60 80 00       	push   $0x806008
  801b51:	e8 23 f3 ff ff       	call   800e79 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801b56:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b61:	b8 04 00 00 00       	mov    $0x4,%eax
  801b66:	e8 c0 fe ff ff       	call   801a2b <fsipc>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 0d                	js     801b7f <devfile_write+0x62>
		        return r;
                n -= tmp;
  801b72:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801b74:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801b76:	85 f6                	test   %esi,%esi
  801b78:	75 bf                	jne    801b39 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801b7a:	89 d8                	mov    %ebx,%eax
  801b7c:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 40 0c             	mov    0xc(%eax),%eax
  801b95:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b9a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba5:	b8 03 00 00 00       	mov    $0x3,%eax
  801baa:	e8 7c fe ff ff       	call   801a2b <fsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 4b                	js     801c00 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bb5:	39 c6                	cmp    %eax,%esi
  801bb7:	73 16                	jae    801bcf <devfile_read+0x48>
  801bb9:	68 04 31 80 00       	push   $0x803104
  801bbe:	68 0b 31 80 00       	push   $0x80310b
  801bc3:	6a 7c                	push   $0x7c
  801bc5:	68 20 31 80 00       	push   $0x803120
  801bca:	e8 b8 ea ff ff       	call   800687 <_panic>
	assert(r <= PGSIZE);
  801bcf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd4:	7e 16                	jle    801bec <devfile_read+0x65>
  801bd6:	68 2b 31 80 00       	push   $0x80312b
  801bdb:	68 0b 31 80 00       	push   $0x80310b
  801be0:	6a 7d                	push   $0x7d
  801be2:	68 20 31 80 00       	push   $0x803120
  801be7:	e8 9b ea ff ff       	call   800687 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bec:	83 ec 04             	sub    $0x4,%esp
  801bef:	50                   	push   %eax
  801bf0:	68 00 60 80 00       	push   $0x806000
  801bf5:	ff 75 0c             	pushl  0xc(%ebp)
  801bf8:	e8 7c f2 ff ff       	call   800e79 <memmove>
	return r;
  801bfd:	83 c4 10             	add    $0x10,%esp
}
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 20             	sub    $0x20,%esp
  801c10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c13:	53                   	push   %ebx
  801c14:	e8 95 f0 ff ff       	call   800cae <strlen>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c21:	7f 67                	jg     801c8a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 6f f8 ff ff       	call   80149e <fd_alloc>
  801c2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c32:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 57                	js     801c8f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c38:	83 ec 08             	sub    $0x8,%esp
  801c3b:	53                   	push   %ebx
  801c3c:	68 00 60 80 00       	push   $0x806000
  801c41:	e8 a1 f0 ff ff       	call   800ce7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c49:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e8 d0 fd ff ff       	call   801a2b <fsipc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	79 14                	jns    801c78 <open+0x6f>
		fd_close(fd, 0);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	6a 00                	push   $0x0
  801c69:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6c:	e8 2a f9 ff ff       	call   80159b <fd_close>
		return r;
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	89 da                	mov    %ebx,%edx
  801c76:	eb 17                	jmp    801c8f <open+0x86>
	}

	return fd2num(fd);
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7e:	e8 f4 f7 ff ff       	call   801477 <fd2num>
  801c83:	89 c2                	mov    %eax,%edx
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	eb 05                	jmp    801c8f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c8a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ca6:	e8 80 fd ff ff       	call   801a2b <fsipc>
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cb3:	68 37 31 80 00       	push   $0x803137
  801cb8:	ff 75 0c             	pushl  0xc(%ebp)
  801cbb:	e8 27 f0 ff ff       	call   800ce7 <strcpy>
	return 0;
}
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 10             	sub    $0x10,%esp
  801cce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cd1:	53                   	push   %ebx
  801cd2:	e8 23 09 00 00       	call   8025fa <pageref>
  801cd7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cda:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cdf:	83 f8 01             	cmp    $0x1,%eax
  801ce2:	75 10                	jne    801cf4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 73 0c             	pushl  0xc(%ebx)
  801cea:	e8 ca 02 00 00       	call   801fb9 <nsipc_close>
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cf4:	89 d0                	mov    %edx,%eax
  801cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d01:	6a 00                	push   $0x0
  801d03:	ff 75 10             	pushl  0x10(%ebp)
  801d06:	ff 75 0c             	pushl  0xc(%ebp)
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	ff 70 0c             	pushl  0xc(%eax)
  801d0f:	e8 82 03 00 00       	call   802096 <nsipc_send>
}
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d1c:	6a 00                	push   $0x0
  801d1e:	ff 75 10             	pushl  0x10(%ebp)
  801d21:	ff 75 0c             	pushl  0xc(%ebp)
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	ff 70 0c             	pushl  0xc(%eax)
  801d2a:	e8 fb 02 00 00       	call   80202a <nsipc_recv>
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d37:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d3a:	52                   	push   %edx
  801d3b:	50                   	push   %eax
  801d3c:	e8 ac f7 ff ff       	call   8014ed <fd_lookup>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 17                	js     801d5f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d51:	39 08                	cmp    %ecx,(%eax)
  801d53:	75 05                	jne    801d5a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d55:	8b 40 0c             	mov    0xc(%eax),%eax
  801d58:	eb 05                	jmp    801d5f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	83 ec 1c             	sub    $0x1c,%esp
  801d69:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	e8 2a f7 ff ff       	call   80149e <fd_alloc>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 1b                	js     801d98 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	68 07 04 00 00       	push   $0x407
  801d85:	ff 75 f4             	pushl  -0xc(%ebp)
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 61 f3 ff ff       	call   8010f0 <sys_page_alloc>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	79 10                	jns    801da8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	56                   	push   %esi
  801d9c:	e8 18 02 00 00       	call   801fb9 <nsipc_close>
		return r;
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	89 d8                	mov    %ebx,%eax
  801da6:	eb 24                	jmp    801dcc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801da8:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db6:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801dbd:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	52                   	push   %edx
  801dc4:	e8 ae f6 ff ff       	call   801477 <fd2num>
  801dc9:	83 c4 10             	add    $0x10,%esp
}
  801dcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	e8 50 ff ff ff       	call   801d31 <fd2sockid>
		return r;
  801de1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 1f                	js     801e06 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	ff 75 10             	pushl  0x10(%ebp)
  801ded:	ff 75 0c             	pushl  0xc(%ebp)
  801df0:	50                   	push   %eax
  801df1:	e8 1c 01 00 00       	call   801f12 <nsipc_accept>
  801df6:	83 c4 10             	add    $0x10,%esp
		return r;
  801df9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 07                	js     801e06 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dff:	e8 5d ff ff ff       	call   801d61 <alloc_sockfd>
  801e04:	89 c1                	mov    %eax,%ecx
}
  801e06:	89 c8                	mov    %ecx,%eax
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	e8 19 ff ff ff       	call   801d31 <fd2sockid>
  801e18:	89 c2                	mov    %eax,%edx
  801e1a:	85 d2                	test   %edx,%edx
  801e1c:	78 12                	js     801e30 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801e1e:	83 ec 04             	sub    $0x4,%esp
  801e21:	ff 75 10             	pushl  0x10(%ebp)
  801e24:	ff 75 0c             	pushl  0xc(%ebp)
  801e27:	52                   	push   %edx
  801e28:	e8 35 01 00 00       	call   801f62 <nsipc_bind>
  801e2d:	83 c4 10             	add    $0x10,%esp
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <shutdown>:

int
shutdown(int s, int how)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	e8 f1 fe ff ff       	call   801d31 <fd2sockid>
  801e40:	89 c2                	mov    %eax,%edx
  801e42:	85 d2                	test   %edx,%edx
  801e44:	78 0f                	js     801e55 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e46:	83 ec 08             	sub    $0x8,%esp
  801e49:	ff 75 0c             	pushl  0xc(%ebp)
  801e4c:	52                   	push   %edx
  801e4d:	e8 45 01 00 00       	call   801f97 <nsipc_shutdown>
  801e52:	83 c4 10             	add    $0x10,%esp
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	e8 cc fe ff ff       	call   801d31 <fd2sockid>
  801e65:	89 c2                	mov    %eax,%edx
  801e67:	85 d2                	test   %edx,%edx
  801e69:	78 12                	js     801e7d <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	ff 75 10             	pushl  0x10(%ebp)
  801e71:	ff 75 0c             	pushl  0xc(%ebp)
  801e74:	52                   	push   %edx
  801e75:	e8 59 01 00 00       	call   801fd3 <nsipc_connect>
  801e7a:	83 c4 10             	add    $0x10,%esp
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <listen>:

int
listen(int s, int backlog)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e85:	8b 45 08             	mov    0x8(%ebp),%eax
  801e88:	e8 a4 fe ff ff       	call   801d31 <fd2sockid>
  801e8d:	89 c2                	mov    %eax,%edx
  801e8f:	85 d2                	test   %edx,%edx
  801e91:	78 0f                	js     801ea2 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e93:	83 ec 08             	sub    $0x8,%esp
  801e96:	ff 75 0c             	pushl  0xc(%ebp)
  801e99:	52                   	push   %edx
  801e9a:	e8 69 01 00 00       	call   802008 <nsipc_listen>
  801e9f:	83 c4 10             	add    $0x10,%esp
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801eaa:	ff 75 10             	pushl  0x10(%ebp)
  801ead:	ff 75 0c             	pushl  0xc(%ebp)
  801eb0:	ff 75 08             	pushl  0x8(%ebp)
  801eb3:	e8 3c 02 00 00       	call   8020f4 <nsipc_socket>
  801eb8:	89 c2                	mov    %eax,%edx
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	85 d2                	test   %edx,%edx
  801ebf:	78 05                	js     801ec6 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801ec1:	e8 9b fe ff ff       	call   801d61 <alloc_sockfd>
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	53                   	push   %ebx
  801ecc:	83 ec 04             	sub    $0x4,%esp
  801ecf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ed1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ed8:	75 12                	jne    801eec <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	6a 02                	push   $0x2
  801edf:	e8 5b f5 ff ff       	call   80143f <ipc_find_env>
  801ee4:	a3 04 50 80 00       	mov    %eax,0x805004
  801ee9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eec:	6a 07                	push   $0x7
  801eee:	68 00 70 80 00       	push   $0x807000
  801ef3:	53                   	push   %ebx
  801ef4:	ff 35 04 50 80 00    	pushl  0x805004
  801efa:	e8 ec f4 ff ff       	call   8013eb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eff:	83 c4 0c             	add    $0xc,%esp
  801f02:	6a 00                	push   $0x0
  801f04:	6a 00                	push   $0x0
  801f06:	6a 00                	push   $0x0
  801f08:	e8 75 f4 ff ff       	call   801382 <ipc_recv>
}
  801f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	56                   	push   %esi
  801f16:	53                   	push   %ebx
  801f17:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f22:	8b 06                	mov    (%esi),%eax
  801f24:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f29:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2e:	e8 95 ff ff ff       	call   801ec8 <nsipc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 20                	js     801f59 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	ff 35 10 70 80 00    	pushl  0x807010
  801f42:	68 00 70 80 00       	push   $0x807000
  801f47:	ff 75 0c             	pushl  0xc(%ebp)
  801f4a:	e8 2a ef ff ff       	call   800e79 <memmove>
		*addrlen = ret->ret_addrlen;
  801f4f:	a1 10 70 80 00       	mov    0x807010,%eax
  801f54:	89 06                	mov    %eax,(%esi)
  801f56:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f59:	89 d8                	mov    %ebx,%eax
  801f5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5e:	5b                   	pop    %ebx
  801f5f:	5e                   	pop    %esi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	53                   	push   %ebx
  801f66:	83 ec 08             	sub    $0x8,%esp
  801f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f74:	53                   	push   %ebx
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	68 04 70 80 00       	push   $0x807004
  801f7d:	e8 f7 ee ff ff       	call   800e79 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f82:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f88:	b8 02 00 00 00       	mov    $0x2,%eax
  801f8d:	e8 36 ff ff ff       	call   801ec8 <nsipc>
}
  801f92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fad:	b8 03 00 00 00       	mov    $0x3,%eax
  801fb2:	e8 11 ff ff ff       	call   801ec8 <nsipc>
}
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <nsipc_close>:

int
nsipc_close(int s)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801fcc:	e8 f7 fe ff ff       	call   801ec8 <nsipc>
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	53                   	push   %ebx
  801fd7:	83 ec 08             	sub    $0x8,%esp
  801fda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fe5:	53                   	push   %ebx
  801fe6:	ff 75 0c             	pushl  0xc(%ebp)
  801fe9:	68 04 70 80 00       	push   $0x807004
  801fee:	e8 86 ee ff ff       	call   800e79 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ff3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ff9:	b8 05 00 00 00       	mov    $0x5,%eax
  801ffe:	e8 c5 fe ff ff       	call   801ec8 <nsipc>
}
  802003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802016:	8b 45 0c             	mov    0xc(%ebp),%eax
  802019:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80201e:	b8 06 00 00 00       	mov    $0x6,%eax
  802023:	e8 a0 fe ff ff       	call   801ec8 <nsipc>
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802032:	8b 45 08             	mov    0x8(%ebp),%eax
  802035:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80203a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802040:	8b 45 14             	mov    0x14(%ebp),%eax
  802043:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802048:	b8 07 00 00 00       	mov    $0x7,%eax
  80204d:	e8 76 fe ff ff       	call   801ec8 <nsipc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	85 c0                	test   %eax,%eax
  802056:	78 35                	js     80208d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	7f 07                	jg     802063 <nsipc_recv+0x39>
  80205c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802061:	7e 16                	jle    802079 <nsipc_recv+0x4f>
  802063:	68 43 31 80 00       	push   $0x803143
  802068:	68 0b 31 80 00       	push   $0x80310b
  80206d:	6a 62                	push   $0x62
  80206f:	68 58 31 80 00       	push   $0x803158
  802074:	e8 0e e6 ff ff       	call   800687 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	50                   	push   %eax
  80207d:	68 00 70 80 00       	push   $0x807000
  802082:	ff 75 0c             	pushl  0xc(%ebp)
  802085:	e8 ef ed ff ff       	call   800e79 <memmove>
  80208a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80208d:	89 d8                	mov    %ebx,%eax
  80208f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    

00802096 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	53                   	push   %ebx
  80209a:	83 ec 04             	sub    $0x4,%esp
  80209d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020a8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020ae:	7e 16                	jle    8020c6 <nsipc_send+0x30>
  8020b0:	68 64 31 80 00       	push   $0x803164
  8020b5:	68 0b 31 80 00       	push   $0x80310b
  8020ba:	6a 6d                	push   $0x6d
  8020bc:	68 58 31 80 00       	push   $0x803158
  8020c1:	e8 c1 e5 ff ff       	call   800687 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020c6:	83 ec 04             	sub    $0x4,%esp
  8020c9:	53                   	push   %ebx
  8020ca:	ff 75 0c             	pushl  0xc(%ebp)
  8020cd:	68 0c 70 80 00       	push   $0x80700c
  8020d2:	e8 a2 ed ff ff       	call   800e79 <memmove>
	nsipcbuf.send.req_size = size;
  8020d7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8020e0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8020ea:	e8 d9 fd ff ff       	call   801ec8 <nsipc>
}
  8020ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    

008020f4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802102:	8b 45 0c             	mov    0xc(%ebp),%eax
  802105:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80210a:	8b 45 10             	mov    0x10(%ebp),%eax
  80210d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802112:	b8 09 00 00 00       	mov    $0x9,%eax
  802117:	e8 ac fd ff ff       	call   801ec8 <nsipc>
}
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	56                   	push   %esi
  802122:	53                   	push   %ebx
  802123:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802126:	83 ec 0c             	sub    $0xc,%esp
  802129:	ff 75 08             	pushl  0x8(%ebp)
  80212c:	e8 56 f3 ff ff       	call   801487 <fd2data>
  802131:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802133:	83 c4 08             	add    $0x8,%esp
  802136:	68 70 31 80 00       	push   $0x803170
  80213b:	53                   	push   %ebx
  80213c:	e8 a6 eb ff ff       	call   800ce7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802141:	8b 56 04             	mov    0x4(%esi),%edx
  802144:	89 d0                	mov    %edx,%eax
  802146:	2b 06                	sub    (%esi),%eax
  802148:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80214e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802155:	00 00 00 
	stat->st_dev = &devpipe;
  802158:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80215f:	40 80 00 
	return 0;
}
  802162:	b8 00 00 00 00       	mov    $0x0,%eax
  802167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	53                   	push   %ebx
  802172:	83 ec 0c             	sub    $0xc,%esp
  802175:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802178:	53                   	push   %ebx
  802179:	6a 00                	push   $0x0
  80217b:	e8 f5 ef ff ff       	call   801175 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802180:	89 1c 24             	mov    %ebx,(%esp)
  802183:	e8 ff f2 ff ff       	call   801487 <fd2data>
  802188:	83 c4 08             	add    $0x8,%esp
  80218b:	50                   	push   %eax
  80218c:	6a 00                	push   $0x0
  80218e:	e8 e2 ef ff ff       	call   801175 <sys_page_unmap>
}
  802193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	57                   	push   %edi
  80219c:	56                   	push   %esi
  80219d:	53                   	push   %ebx
  80219e:	83 ec 1c             	sub    $0x1c,%esp
  8021a1:	89 c6                	mov    %eax,%esi
  8021a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021a6:	a1 08 50 80 00       	mov    0x805008,%eax
  8021ab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	56                   	push   %esi
  8021b2:	e8 43 04 00 00       	call   8025fa <pageref>
  8021b7:	89 c7                	mov    %eax,%edi
  8021b9:	83 c4 04             	add    $0x4,%esp
  8021bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021bf:	e8 36 04 00 00       	call   8025fa <pageref>
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	39 c7                	cmp    %eax,%edi
  8021c9:	0f 94 c2             	sete   %dl
  8021cc:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8021cf:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8021d5:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8021d8:	39 fb                	cmp    %edi,%ebx
  8021da:	74 19                	je     8021f5 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8021dc:	84 d2                	test   %dl,%dl
  8021de:	74 c6                	je     8021a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021e0:	8b 51 58             	mov    0x58(%ecx),%edx
  8021e3:	50                   	push   %eax
  8021e4:	52                   	push   %edx
  8021e5:	53                   	push   %ebx
  8021e6:	68 77 31 80 00       	push   $0x803177
  8021eb:	e8 70 e5 ff ff       	call   800760 <cprintf>
  8021f0:	83 c4 10             	add    $0x10,%esp
  8021f3:	eb b1                	jmp    8021a6 <_pipeisclosed+0xe>
	}
}
  8021f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    

008021fd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	57                   	push   %edi
  802201:	56                   	push   %esi
  802202:	53                   	push   %ebx
  802203:	83 ec 28             	sub    $0x28,%esp
  802206:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802209:	56                   	push   %esi
  80220a:	e8 78 f2 ff ff       	call   801487 <fd2data>
  80220f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802211:	83 c4 10             	add    $0x10,%esp
  802214:	bf 00 00 00 00       	mov    $0x0,%edi
  802219:	eb 4b                	jmp    802266 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80221b:	89 da                	mov    %ebx,%edx
  80221d:	89 f0                	mov    %esi,%eax
  80221f:	e8 74 ff ff ff       	call   802198 <_pipeisclosed>
  802224:	85 c0                	test   %eax,%eax
  802226:	75 48                	jne    802270 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802228:	e8 a4 ee ff ff       	call   8010d1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80222d:	8b 43 04             	mov    0x4(%ebx),%eax
  802230:	8b 0b                	mov    (%ebx),%ecx
  802232:	8d 51 20             	lea    0x20(%ecx),%edx
  802235:	39 d0                	cmp    %edx,%eax
  802237:	73 e2                	jae    80221b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802239:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80223c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802240:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802243:	89 c2                	mov    %eax,%edx
  802245:	c1 fa 1f             	sar    $0x1f,%edx
  802248:	89 d1                	mov    %edx,%ecx
  80224a:	c1 e9 1b             	shr    $0x1b,%ecx
  80224d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802250:	83 e2 1f             	and    $0x1f,%edx
  802253:	29 ca                	sub    %ecx,%edx
  802255:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802259:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80225d:	83 c0 01             	add    $0x1,%eax
  802260:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802263:	83 c7 01             	add    $0x1,%edi
  802266:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802269:	75 c2                	jne    80222d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80226b:	8b 45 10             	mov    0x10(%ebp),%eax
  80226e:	eb 05                	jmp    802275 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    

0080227d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	57                   	push   %edi
  802281:	56                   	push   %esi
  802282:	53                   	push   %ebx
  802283:	83 ec 18             	sub    $0x18,%esp
  802286:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802289:	57                   	push   %edi
  80228a:	e8 f8 f1 ff ff       	call   801487 <fd2data>
  80228f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	bb 00 00 00 00       	mov    $0x0,%ebx
  802299:	eb 3d                	jmp    8022d8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80229b:	85 db                	test   %ebx,%ebx
  80229d:	74 04                	je     8022a3 <devpipe_read+0x26>
				return i;
  80229f:	89 d8                	mov    %ebx,%eax
  8022a1:	eb 44                	jmp    8022e7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	89 f8                	mov    %edi,%eax
  8022a7:	e8 ec fe ff ff       	call   802198 <_pipeisclosed>
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	75 32                	jne    8022e2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022b0:	e8 1c ee ff ff       	call   8010d1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022b5:	8b 06                	mov    (%esi),%eax
  8022b7:	3b 46 04             	cmp    0x4(%esi),%eax
  8022ba:	74 df                	je     80229b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022bc:	99                   	cltd   
  8022bd:	c1 ea 1b             	shr    $0x1b,%edx
  8022c0:	01 d0                	add    %edx,%eax
  8022c2:	83 e0 1f             	and    $0x1f,%eax
  8022c5:	29 d0                	sub    %edx,%eax
  8022c7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022cf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022d2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d5:	83 c3 01             	add    $0x1,%ebx
  8022d8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022db:	75 d8                	jne    8022b5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e0:	eb 05                	jmp    8022e7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022e2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ea:	5b                   	pop    %ebx
  8022eb:	5e                   	pop    %esi
  8022ec:	5f                   	pop    %edi
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    

008022ef <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fa:	50                   	push   %eax
  8022fb:	e8 9e f1 ff ff       	call   80149e <fd_alloc>
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	89 c2                	mov    %eax,%edx
  802305:	85 c0                	test   %eax,%eax
  802307:	0f 88 2c 01 00 00    	js     802439 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80230d:	83 ec 04             	sub    $0x4,%esp
  802310:	68 07 04 00 00       	push   $0x407
  802315:	ff 75 f4             	pushl  -0xc(%ebp)
  802318:	6a 00                	push   $0x0
  80231a:	e8 d1 ed ff ff       	call   8010f0 <sys_page_alloc>
  80231f:	83 c4 10             	add    $0x10,%esp
  802322:	89 c2                	mov    %eax,%edx
  802324:	85 c0                	test   %eax,%eax
  802326:	0f 88 0d 01 00 00    	js     802439 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80232c:	83 ec 0c             	sub    $0xc,%esp
  80232f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802332:	50                   	push   %eax
  802333:	e8 66 f1 ff ff       	call   80149e <fd_alloc>
  802338:	89 c3                	mov    %eax,%ebx
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	85 c0                	test   %eax,%eax
  80233f:	0f 88 e2 00 00 00    	js     802427 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	68 07 04 00 00       	push   $0x407
  80234d:	ff 75 f0             	pushl  -0x10(%ebp)
  802350:	6a 00                	push   $0x0
  802352:	e8 99 ed ff ff       	call   8010f0 <sys_page_alloc>
  802357:	89 c3                	mov    %eax,%ebx
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	85 c0                	test   %eax,%eax
  80235e:	0f 88 c3 00 00 00    	js     802427 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802364:	83 ec 0c             	sub    $0xc,%esp
  802367:	ff 75 f4             	pushl  -0xc(%ebp)
  80236a:	e8 18 f1 ff ff       	call   801487 <fd2data>
  80236f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802371:	83 c4 0c             	add    $0xc,%esp
  802374:	68 07 04 00 00       	push   $0x407
  802379:	50                   	push   %eax
  80237a:	6a 00                	push   $0x0
  80237c:	e8 6f ed ff ff       	call   8010f0 <sys_page_alloc>
  802381:	89 c3                	mov    %eax,%ebx
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	85 c0                	test   %eax,%eax
  802388:	0f 88 89 00 00 00    	js     802417 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80238e:	83 ec 0c             	sub    $0xc,%esp
  802391:	ff 75 f0             	pushl  -0x10(%ebp)
  802394:	e8 ee f0 ff ff       	call   801487 <fd2data>
  802399:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023a0:	50                   	push   %eax
  8023a1:	6a 00                	push   $0x0
  8023a3:	56                   	push   %esi
  8023a4:	6a 00                	push   $0x0
  8023a6:	e8 88 ed ff ff       	call   801133 <sys_page_map>
  8023ab:	89 c3                	mov    %eax,%ebx
  8023ad:	83 c4 20             	add    $0x20,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	78 55                	js     802409 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023b4:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023c9:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023d2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023d7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023de:	83 ec 0c             	sub    $0xc,%esp
  8023e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e4:	e8 8e f0 ff ff       	call   801477 <fd2num>
  8023e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ec:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023ee:	83 c4 04             	add    $0x4,%esp
  8023f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f4:	e8 7e f0 ff ff       	call   801477 <fd2num>
  8023f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023fc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023ff:	83 c4 10             	add    $0x10,%esp
  802402:	ba 00 00 00 00       	mov    $0x0,%edx
  802407:	eb 30                	jmp    802439 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802409:	83 ec 08             	sub    $0x8,%esp
  80240c:	56                   	push   %esi
  80240d:	6a 00                	push   $0x0
  80240f:	e8 61 ed ff ff       	call   801175 <sys_page_unmap>
  802414:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802417:	83 ec 08             	sub    $0x8,%esp
  80241a:	ff 75 f0             	pushl  -0x10(%ebp)
  80241d:	6a 00                	push   $0x0
  80241f:	e8 51 ed ff ff       	call   801175 <sys_page_unmap>
  802424:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802427:	83 ec 08             	sub    $0x8,%esp
  80242a:	ff 75 f4             	pushl  -0xc(%ebp)
  80242d:	6a 00                	push   $0x0
  80242f:	e8 41 ed ff ff       	call   801175 <sys_page_unmap>
  802434:	83 c4 10             	add    $0x10,%esp
  802437:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802439:	89 d0                	mov    %edx,%eax
  80243b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243e:	5b                   	pop    %ebx
  80243f:	5e                   	pop    %esi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    

00802442 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802448:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244b:	50                   	push   %eax
  80244c:	ff 75 08             	pushl  0x8(%ebp)
  80244f:	e8 99 f0 ff ff       	call   8014ed <fd_lookup>
  802454:	89 c2                	mov    %eax,%edx
  802456:	83 c4 10             	add    $0x10,%esp
  802459:	85 d2                	test   %edx,%edx
  80245b:	78 18                	js     802475 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80245d:	83 ec 0c             	sub    $0xc,%esp
  802460:	ff 75 f4             	pushl  -0xc(%ebp)
  802463:	e8 1f f0 ff ff       	call   801487 <fd2data>
	return _pipeisclosed(fd, p);
  802468:	89 c2                	mov    %eax,%edx
  80246a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246d:	e8 26 fd ff ff       	call   802198 <_pipeisclosed>
  802472:	83 c4 10             	add    $0x10,%esp
}
  802475:	c9                   	leave  
  802476:	c3                   	ret    

00802477 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80247a:	b8 00 00 00 00       	mov    $0x0,%eax
  80247f:	5d                   	pop    %ebp
  802480:	c3                   	ret    

00802481 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802487:	68 8f 31 80 00       	push   $0x80318f
  80248c:	ff 75 0c             	pushl  0xc(%ebp)
  80248f:	e8 53 e8 ff ff       	call   800ce7 <strcpy>
	return 0;
}
  802494:	b8 00 00 00 00       	mov    $0x0,%eax
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	57                   	push   %edi
  80249f:	56                   	push   %esi
  8024a0:	53                   	push   %ebx
  8024a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024a7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024b2:	eb 2d                	jmp    8024e1 <devcons_write+0x46>
		m = n - tot;
  8024b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024b7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8024b9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024bc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024c1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024c4:	83 ec 04             	sub    $0x4,%esp
  8024c7:	53                   	push   %ebx
  8024c8:	03 45 0c             	add    0xc(%ebp),%eax
  8024cb:	50                   	push   %eax
  8024cc:	57                   	push   %edi
  8024cd:	e8 a7 e9 ff ff       	call   800e79 <memmove>
		sys_cputs(buf, m);
  8024d2:	83 c4 08             	add    $0x8,%esp
  8024d5:	53                   	push   %ebx
  8024d6:	57                   	push   %edi
  8024d7:	e8 58 eb ff ff       	call   801034 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024dc:	01 de                	add    %ebx,%esi
  8024de:	83 c4 10             	add    $0x10,%esp
  8024e1:	89 f0                	mov    %esi,%eax
  8024e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024e6:	72 cc                	jb     8024b4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024eb:	5b                   	pop    %ebx
  8024ec:	5e                   	pop    %esi
  8024ed:	5f                   	pop    %edi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    

008024f0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8024f6:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8024fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024ff:	75 07                	jne    802508 <devcons_read+0x18>
  802501:	eb 28                	jmp    80252b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802503:	e8 c9 eb ff ff       	call   8010d1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802508:	e8 45 eb ff ff       	call   801052 <sys_cgetc>
  80250d:	85 c0                	test   %eax,%eax
  80250f:	74 f2                	je     802503 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802511:	85 c0                	test   %eax,%eax
  802513:	78 16                	js     80252b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802515:	83 f8 04             	cmp    $0x4,%eax
  802518:	74 0c                	je     802526 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80251a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80251d:	88 02                	mov    %al,(%edx)
	return 1;
  80251f:	b8 01 00 00 00       	mov    $0x1,%eax
  802524:	eb 05                	jmp    80252b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802526:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80252b:	c9                   	leave  
  80252c:	c3                   	ret    

0080252d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80252d:	55                   	push   %ebp
  80252e:	89 e5                	mov    %esp,%ebp
  802530:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802533:	8b 45 08             	mov    0x8(%ebp),%eax
  802536:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802539:	6a 01                	push   $0x1
  80253b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80253e:	50                   	push   %eax
  80253f:	e8 f0 ea ff ff       	call   801034 <sys_cputs>
  802544:	83 c4 10             	add    $0x10,%esp
}
  802547:	c9                   	leave  
  802548:	c3                   	ret    

00802549 <getchar>:

int
getchar(void)
{
  802549:	55                   	push   %ebp
  80254a:	89 e5                	mov    %esp,%ebp
  80254c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80254f:	6a 01                	push   $0x1
  802551:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802554:	50                   	push   %eax
  802555:	6a 00                	push   $0x0
  802557:	e8 00 f2 ff ff       	call   80175c <read>
	if (r < 0)
  80255c:	83 c4 10             	add    $0x10,%esp
  80255f:	85 c0                	test   %eax,%eax
  802561:	78 0f                	js     802572 <getchar+0x29>
		return r;
	if (r < 1)
  802563:	85 c0                	test   %eax,%eax
  802565:	7e 06                	jle    80256d <getchar+0x24>
		return -E_EOF;
	return c;
  802567:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80256b:	eb 05                	jmp    802572 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80256d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802572:	c9                   	leave  
  802573:	c3                   	ret    

00802574 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80257a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257d:	50                   	push   %eax
  80257e:	ff 75 08             	pushl  0x8(%ebp)
  802581:	e8 67 ef ff ff       	call   8014ed <fd_lookup>
  802586:	83 c4 10             	add    $0x10,%esp
  802589:	85 c0                	test   %eax,%eax
  80258b:	78 11                	js     80259e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80258d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802590:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802596:	39 10                	cmp    %edx,(%eax)
  802598:	0f 94 c0             	sete   %al
  80259b:	0f b6 c0             	movzbl %al,%eax
}
  80259e:	c9                   	leave  
  80259f:	c3                   	ret    

008025a0 <opencons>:

int
opencons(void)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025a9:	50                   	push   %eax
  8025aa:	e8 ef ee ff ff       	call   80149e <fd_alloc>
  8025af:	83 c4 10             	add    $0x10,%esp
		return r;
  8025b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	78 3e                	js     8025f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025b8:	83 ec 04             	sub    $0x4,%esp
  8025bb:	68 07 04 00 00       	push   $0x407
  8025c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8025c3:	6a 00                	push   $0x0
  8025c5:	e8 26 eb ff ff       	call   8010f0 <sys_page_alloc>
  8025ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8025cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025cf:	85 c0                	test   %eax,%eax
  8025d1:	78 23                	js     8025f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025d3:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	50                   	push   %eax
  8025ec:	e8 86 ee ff ff       	call   801477 <fd2num>
  8025f1:	89 c2                	mov    %eax,%edx
  8025f3:	83 c4 10             	add    $0x10,%esp
}
  8025f6:	89 d0                	mov    %edx,%eax
  8025f8:	c9                   	leave  
  8025f9:	c3                   	ret    

008025fa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025fa:	55                   	push   %ebp
  8025fb:	89 e5                	mov    %esp,%ebp
  8025fd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802600:	89 d0                	mov    %edx,%eax
  802602:	c1 e8 16             	shr    $0x16,%eax
  802605:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80260c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802611:	f6 c1 01             	test   $0x1,%cl
  802614:	74 1d                	je     802633 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802616:	c1 ea 0c             	shr    $0xc,%edx
  802619:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802620:	f6 c2 01             	test   $0x1,%dl
  802623:	74 0e                	je     802633 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802625:	c1 ea 0c             	shr    $0xc,%edx
  802628:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80262f:	ef 
  802630:	0f b7 c0             	movzwl %ax,%eax
}
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    
  802635:	66 90                	xchg   %ax,%ax
  802637:	66 90                	xchg   %ax,%ax
  802639:	66 90                	xchg   %ax,%ax
  80263b:	66 90                	xchg   %ax,%ax
  80263d:	66 90                	xchg   %ax,%ax
  80263f:	90                   	nop

00802640 <__udivdi3>:
  802640:	55                   	push   %ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	83 ec 10             	sub    $0x10,%esp
  802646:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80264a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80264e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802652:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802656:	85 d2                	test   %edx,%edx
  802658:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80265c:	89 34 24             	mov    %esi,(%esp)
  80265f:	89 c8                	mov    %ecx,%eax
  802661:	75 35                	jne    802698 <__udivdi3+0x58>
  802663:	39 f1                	cmp    %esi,%ecx
  802665:	0f 87 bd 00 00 00    	ja     802728 <__udivdi3+0xe8>
  80266b:	85 c9                	test   %ecx,%ecx
  80266d:	89 cd                	mov    %ecx,%ebp
  80266f:	75 0b                	jne    80267c <__udivdi3+0x3c>
  802671:	b8 01 00 00 00       	mov    $0x1,%eax
  802676:	31 d2                	xor    %edx,%edx
  802678:	f7 f1                	div    %ecx
  80267a:	89 c5                	mov    %eax,%ebp
  80267c:	89 f0                	mov    %esi,%eax
  80267e:	31 d2                	xor    %edx,%edx
  802680:	f7 f5                	div    %ebp
  802682:	89 c6                	mov    %eax,%esi
  802684:	89 f8                	mov    %edi,%eax
  802686:	f7 f5                	div    %ebp
  802688:	89 f2                	mov    %esi,%edx
  80268a:	83 c4 10             	add    $0x10,%esp
  80268d:	5e                   	pop    %esi
  80268e:	5f                   	pop    %edi
  80268f:	5d                   	pop    %ebp
  802690:	c3                   	ret    
  802691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802698:	3b 14 24             	cmp    (%esp),%edx
  80269b:	77 7b                	ja     802718 <__udivdi3+0xd8>
  80269d:	0f bd f2             	bsr    %edx,%esi
  8026a0:	83 f6 1f             	xor    $0x1f,%esi
  8026a3:	0f 84 97 00 00 00    	je     802740 <__udivdi3+0x100>
  8026a9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8026ae:	89 d7                	mov    %edx,%edi
  8026b0:	89 f1                	mov    %esi,%ecx
  8026b2:	29 f5                	sub    %esi,%ebp
  8026b4:	d3 e7                	shl    %cl,%edi
  8026b6:	89 c2                	mov    %eax,%edx
  8026b8:	89 e9                	mov    %ebp,%ecx
  8026ba:	d3 ea                	shr    %cl,%edx
  8026bc:	89 f1                	mov    %esi,%ecx
  8026be:	09 fa                	or     %edi,%edx
  8026c0:	8b 3c 24             	mov    (%esp),%edi
  8026c3:	d3 e0                	shl    %cl,%eax
  8026c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026cf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026d3:	89 fa                	mov    %edi,%edx
  8026d5:	d3 ea                	shr    %cl,%edx
  8026d7:	89 f1                	mov    %esi,%ecx
  8026d9:	d3 e7                	shl    %cl,%edi
  8026db:	89 e9                	mov    %ebp,%ecx
  8026dd:	d3 e8                	shr    %cl,%eax
  8026df:	09 c7                	or     %eax,%edi
  8026e1:	89 f8                	mov    %edi,%eax
  8026e3:	f7 74 24 08          	divl   0x8(%esp)
  8026e7:	89 d5                	mov    %edx,%ebp
  8026e9:	89 c7                	mov    %eax,%edi
  8026eb:	f7 64 24 0c          	mull   0xc(%esp)
  8026ef:	39 d5                	cmp    %edx,%ebp
  8026f1:	89 14 24             	mov    %edx,(%esp)
  8026f4:	72 11                	jb     802707 <__udivdi3+0xc7>
  8026f6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026fa:	89 f1                	mov    %esi,%ecx
  8026fc:	d3 e2                	shl    %cl,%edx
  8026fe:	39 c2                	cmp    %eax,%edx
  802700:	73 5e                	jae    802760 <__udivdi3+0x120>
  802702:	3b 2c 24             	cmp    (%esp),%ebp
  802705:	75 59                	jne    802760 <__udivdi3+0x120>
  802707:	8d 47 ff             	lea    -0x1(%edi),%eax
  80270a:	31 f6                	xor    %esi,%esi
  80270c:	89 f2                	mov    %esi,%edx
  80270e:	83 c4 10             	add    $0x10,%esp
  802711:	5e                   	pop    %esi
  802712:	5f                   	pop    %edi
  802713:	5d                   	pop    %ebp
  802714:	c3                   	ret    
  802715:	8d 76 00             	lea    0x0(%esi),%esi
  802718:	31 f6                	xor    %esi,%esi
  80271a:	31 c0                	xor    %eax,%eax
  80271c:	89 f2                	mov    %esi,%edx
  80271e:	83 c4 10             	add    $0x10,%esp
  802721:	5e                   	pop    %esi
  802722:	5f                   	pop    %edi
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    
  802725:	8d 76 00             	lea    0x0(%esi),%esi
  802728:	89 f2                	mov    %esi,%edx
  80272a:	31 f6                	xor    %esi,%esi
  80272c:	89 f8                	mov    %edi,%eax
  80272e:	f7 f1                	div    %ecx
  802730:	89 f2                	mov    %esi,%edx
  802732:	83 c4 10             	add    $0x10,%esp
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802744:	76 0b                	jbe    802751 <__udivdi3+0x111>
  802746:	31 c0                	xor    %eax,%eax
  802748:	3b 14 24             	cmp    (%esp),%edx
  80274b:	0f 83 37 ff ff ff    	jae    802688 <__udivdi3+0x48>
  802751:	b8 01 00 00 00       	mov    $0x1,%eax
  802756:	e9 2d ff ff ff       	jmp    802688 <__udivdi3+0x48>
  80275b:	90                   	nop
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 f8                	mov    %edi,%eax
  802762:	31 f6                	xor    %esi,%esi
  802764:	e9 1f ff ff ff       	jmp    802688 <__udivdi3+0x48>
  802769:	66 90                	xchg   %ax,%ax
  80276b:	66 90                	xchg   %ax,%ax
  80276d:	66 90                	xchg   %ax,%ax
  80276f:	90                   	nop

00802770 <__umoddi3>:
  802770:	55                   	push   %ebp
  802771:	57                   	push   %edi
  802772:	56                   	push   %esi
  802773:	83 ec 20             	sub    $0x20,%esp
  802776:	8b 44 24 34          	mov    0x34(%esp),%eax
  80277a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80277e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802782:	89 c6                	mov    %eax,%esi
  802784:	89 44 24 10          	mov    %eax,0x10(%esp)
  802788:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80278c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802790:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802794:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802798:	89 74 24 18          	mov    %esi,0x18(%esp)
  80279c:	85 c0                	test   %eax,%eax
  80279e:	89 c2                	mov    %eax,%edx
  8027a0:	75 1e                	jne    8027c0 <__umoddi3+0x50>
  8027a2:	39 f7                	cmp    %esi,%edi
  8027a4:	76 52                	jbe    8027f8 <__umoddi3+0x88>
  8027a6:	89 c8                	mov    %ecx,%eax
  8027a8:	89 f2                	mov    %esi,%edx
  8027aa:	f7 f7                	div    %edi
  8027ac:	89 d0                	mov    %edx,%eax
  8027ae:	31 d2                	xor    %edx,%edx
  8027b0:	83 c4 20             	add    $0x20,%esp
  8027b3:	5e                   	pop    %esi
  8027b4:	5f                   	pop    %edi
  8027b5:	5d                   	pop    %ebp
  8027b6:	c3                   	ret    
  8027b7:	89 f6                	mov    %esi,%esi
  8027b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027c0:	39 f0                	cmp    %esi,%eax
  8027c2:	77 5c                	ja     802820 <__umoddi3+0xb0>
  8027c4:	0f bd e8             	bsr    %eax,%ebp
  8027c7:	83 f5 1f             	xor    $0x1f,%ebp
  8027ca:	75 64                	jne    802830 <__umoddi3+0xc0>
  8027cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8027d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8027d4:	0f 86 f6 00 00 00    	jbe    8028d0 <__umoddi3+0x160>
  8027da:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8027de:	0f 82 ec 00 00 00    	jb     8028d0 <__umoddi3+0x160>
  8027e4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027e8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8027ec:	83 c4 20             	add    $0x20,%esp
  8027ef:	5e                   	pop    %esi
  8027f0:	5f                   	pop    %edi
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    
  8027f3:	90                   	nop
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	85 ff                	test   %edi,%edi
  8027fa:	89 fd                	mov    %edi,%ebp
  8027fc:	75 0b                	jne    802809 <__umoddi3+0x99>
  8027fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802803:	31 d2                	xor    %edx,%edx
  802805:	f7 f7                	div    %edi
  802807:	89 c5                	mov    %eax,%ebp
  802809:	8b 44 24 10          	mov    0x10(%esp),%eax
  80280d:	31 d2                	xor    %edx,%edx
  80280f:	f7 f5                	div    %ebp
  802811:	89 c8                	mov    %ecx,%eax
  802813:	f7 f5                	div    %ebp
  802815:	eb 95                	jmp    8027ac <__umoddi3+0x3c>
  802817:	89 f6                	mov    %esi,%esi
  802819:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 20             	add    $0x20,%esp
  802827:	5e                   	pop    %esi
  802828:	5f                   	pop    %edi
  802829:	5d                   	pop    %ebp
  80282a:	c3                   	ret    
  80282b:	90                   	nop
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	b8 20 00 00 00       	mov    $0x20,%eax
  802835:	89 e9                	mov    %ebp,%ecx
  802837:	29 e8                	sub    %ebp,%eax
  802839:	d3 e2                	shl    %cl,%edx
  80283b:	89 c7                	mov    %eax,%edi
  80283d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802841:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802845:	89 f9                	mov    %edi,%ecx
  802847:	d3 e8                	shr    %cl,%eax
  802849:	89 c1                	mov    %eax,%ecx
  80284b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80284f:	09 d1                	or     %edx,%ecx
  802851:	89 fa                	mov    %edi,%edx
  802853:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802857:	89 e9                	mov    %ebp,%ecx
  802859:	d3 e0                	shl    %cl,%eax
  80285b:	89 f9                	mov    %edi,%ecx
  80285d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802861:	89 f0                	mov    %esi,%eax
  802863:	d3 e8                	shr    %cl,%eax
  802865:	89 e9                	mov    %ebp,%ecx
  802867:	89 c7                	mov    %eax,%edi
  802869:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80286d:	d3 e6                	shl    %cl,%esi
  80286f:	89 d1                	mov    %edx,%ecx
  802871:	89 fa                	mov    %edi,%edx
  802873:	d3 e8                	shr    %cl,%eax
  802875:	89 e9                	mov    %ebp,%ecx
  802877:	09 f0                	or     %esi,%eax
  802879:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80287d:	f7 74 24 10          	divl   0x10(%esp)
  802881:	d3 e6                	shl    %cl,%esi
  802883:	89 d1                	mov    %edx,%ecx
  802885:	f7 64 24 0c          	mull   0xc(%esp)
  802889:	39 d1                	cmp    %edx,%ecx
  80288b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80288f:	89 d7                	mov    %edx,%edi
  802891:	89 c6                	mov    %eax,%esi
  802893:	72 0a                	jb     80289f <__umoddi3+0x12f>
  802895:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802899:	73 10                	jae    8028ab <__umoddi3+0x13b>
  80289b:	39 d1                	cmp    %edx,%ecx
  80289d:	75 0c                	jne    8028ab <__umoddi3+0x13b>
  80289f:	89 d7                	mov    %edx,%edi
  8028a1:	89 c6                	mov    %eax,%esi
  8028a3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8028a7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8028ab:	89 ca                	mov    %ecx,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028b3:	29 f0                	sub    %esi,%eax
  8028b5:	19 fa                	sbb    %edi,%edx
  8028b7:	d3 e8                	shr    %cl,%eax
  8028b9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8028be:	89 d7                	mov    %edx,%edi
  8028c0:	d3 e7                	shl    %cl,%edi
  8028c2:	89 e9                	mov    %ebp,%ecx
  8028c4:	09 f8                	or     %edi,%eax
  8028c6:	d3 ea                	shr    %cl,%edx
  8028c8:	83 c4 20             	add    $0x20,%esp
  8028cb:	5e                   	pop    %esi
  8028cc:	5f                   	pop    %edi
  8028cd:	5d                   	pop    %ebp
  8028ce:	c3                   	ret    
  8028cf:	90                   	nop
  8028d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028d4:	29 f9                	sub    %edi,%ecx
  8028d6:	19 c6                	sbb    %eax,%esi
  8028d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028dc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028e0:	e9 ff fe ff ff       	jmp    8027e4 <__umoddi3+0x74>
