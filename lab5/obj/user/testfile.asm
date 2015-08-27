
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
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 a0 0c 00 00       	call   800ce7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 45 13 00 00       	call   80139e <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 e2 12 00 00       	call   80134a <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 68 12 00 00       	call   8012e1 <ipc_recv>
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
  80008f:	b8 00 24 80 00       	mov    $0x802400,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	89 c2                	mov    %eax,%edx
  80009b:	c1 ea 1f             	shr    $0x1f,%edx
  80009e:	84 d2                	test   %dl,%dl
  8000a0:	74 17                	je     8000b9 <umain+0x3b>
  8000a2:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 24 80 00       	push   $0x80240b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 24 80 00       	push   $0x802425
  8000b4:	e8 ce 05 00 00       	call   800687 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 25 80 00       	push   $0x8025c0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 24 80 00       	push   $0x802425
  8000cc:	e8 b6 05 00 00       	call   800687 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 24 80 00       	mov    $0x802435,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 24 80 00       	push   $0x80243e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 24 80 00       	push   $0x802425
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
  800114:	68 e4 25 80 00       	push   $0x8025e4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 24 80 00       	push   $0x802425
  800120:	e8 62 05 00 00       	call   800687 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 24 80 00       	push   $0x802456
  80012d:	e8 2e 06 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 6a 24 80 00       	push   $0x80246a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 24 80 00       	push   $0x802425
  80015b:	e8 27 05 00 00       	call   800687 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 40 0b 00 00       	call   800cae <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 2a 0b 00 00       	call   800cae <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 14 26 80 00       	push   $0x802614
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 24 80 00       	push   $0x802425
  800196:	e8 ec 04 00 00       	call   800687 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 24 80 00       	push   $0x802478
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
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 8b 24 80 00       	push   $0x80248b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 24 80 00       	push   $0x802425
  8001e6:	e8 9c 04 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 91 0b 00 00       	call   800d91 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 99 24 80 00       	push   $0x802499
  80020f:	6a 34                	push   $0x34
  800211:	68 25 24 80 00       	push   $0x802425
  800216:	e8 6c 04 00 00       	call   800687 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 24 80 00       	push   $0x8024b7
  800223:	e8 38 05 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 24 80 00       	push   $0x8024ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 24 80 00       	push   $0x802425
  800249:	e8 39 04 00 00       	call   800687 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 24 80 00       	push   $0x8024d9
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
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 3c 26 80 00       	push   $0x80263c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 24 80 00       	push   $0x802425
  8002b8:	e8 ca 03 00 00       	call   800687 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 24 80 00       	push   $0x8024ed
  8002c5:	e8 96 04 00 00       	call   800760 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 25 80 00       	mov    $0x802503,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 25 80 00       	push   $0x80250d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 24 80 00       	push   $0x802425
  8002ed:	e8 95 03 00 00       	call   800687 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 a8 09 00 00       	call   800cae <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 87 09 00 00       	call   800cae <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 26 25 80 00       	push   $0x802526
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 24 80 00       	push   $0x802425
  80033b:	e8 47 03 00 00       	call   800687 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 25 80 00       	push   $0x802535
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
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 74 26 80 00       	push   $0x802674
  800390:	6a 51                	push   $0x51
  800392:	68 25 24 80 00       	push   $0x802425
  800397:	e8 eb 02 00 00       	call   800687 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 04 09 00 00       	call   800cae <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 d8                	cmp    %ebx,%eax
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 94 26 80 00       	push   $0x802694
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 24 80 00       	push   $0x802425
  8003be:	e8 c4 02 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b9 09 00 00       	call   800d91 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 cc 26 80 00       	push   $0x8026cc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 24 80 00       	push   $0x802425
  8003ee:	e8 94 02 00 00       	call   800687 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 26 80 00       	push   $0x8026fc
  8003fb:	e8 60 03 00 00       	call   800760 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 24 80 00       	push   $0x802400
  80040a:	e8 54 17 00 00       	call   801b63 <open>
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 1f             	shr    $0x1f,%edx
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	84 d2                	test   %dl,%dl
  800419:	74 17                	je     800432 <umain+0x3b4>
  80041b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 24 80 00       	push   $0x802411
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 24 80 00       	push   $0x802425
  80042d:	e8 55 02 00 00       	call   800687 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 25 80 00       	push   $0x802549
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 24 80 00       	push   $0x802425
  800445:	e8 3d 02 00 00       	call   800687 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 24 80 00       	push   $0x802435
  800454:	e8 0a 17 00 00       	call   801b63 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 24 80 00       	push   $0x802444
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 24 80 00       	push   $0x802425
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
  800493:	68 20 27 80 00       	push   $0x802720
  800498:	6a 62                	push   $0x62
  80049a:	68 25 24 80 00       	push   $0x802425
  80049f:	e8 e3 01 00 00       	call   800687 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 24 80 00       	push   $0x80245c
  8004ac:	e8 af 02 00 00       	call   800760 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 25 80 00       	push   $0x802564
  8004be:	e8 a0 16 00 00       	call   801b63 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 25 80 00       	push   $0x802569
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 24 80 00       	push   $0x802425
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
  800512:	e8 75 12 00 00       	call   80178c <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 25 80 00       	push   $0x802578
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 24 80 00       	push   $0x802425
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
  800547:	e8 2a 10 00 00       	call   801576 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 25 80 00       	push   $0x802564
  800556:	e8 08 16 00 00       	call   801b63 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 25 80 00       	push   $0x80258a
  80056a:	6a 71                	push   $0x71
  80056c:	68 25 24 80 00       	push   $0x802425
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
  800591:	e8 b1 11 00 00       	call   801747 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 25 80 00       	push   $0x802598
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 25 24 80 00       	push   $0x802425
  8005ae:	e8 d4 00 00 00       	call   800687 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 27 80 00       	push   $0x802748
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 25 24 80 00       	push   $0x802425
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
  8005e4:	68 74 27 80 00       	push   $0x802774
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 25 24 80 00       	push   $0x802425
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
  80060b:	e8 66 0f 00 00       	call   801576 <close>
	cprintf("large file is good\n");
  800610:	c7 04 24 a9 25 80 00 	movl   $0x8025a9,(%esp)
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
  800644:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800649:	85 db                	test   %ebx,%ebx
  80064b:	7e 07                	jle    800654 <libmain+0x2d>
		binaryname = argv[0];
  80064d:	8b 06                	mov    (%esi),%eax
  80064f:	a3 04 30 80 00       	mov    %eax,0x803004

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
  800673:	e8 2b 0f 00 00       	call   8015a3 <close_all>
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
  80068f:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800695:	e8 18 0a 00 00       	call   8010b2 <sys_getenvid>
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	56                   	push   %esi
  8006a4:	50                   	push   %eax
  8006a5:	68 cc 27 80 00       	push   $0x8027cc
  8006aa:	e8 b1 00 00 00       	call   800760 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006af:	83 c4 18             	add    $0x18,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	e8 54 00 00 00       	call   80070f <vcprintf>
	cprintf("\n");
  8006bb:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
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
  8007c3:	e8 58 19 00 00       	call   802120 <__udivdi3>
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
  800801:	e8 4a 1a 00 00       	call   802250 <__umoddi3>
  800806:	83 c4 14             	add    $0x14,%esp
  800809:	0f be 80 ef 27 80 00 	movsbl 0x8027ef(%eax),%eax
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
  800905:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
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
  8009c9:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	75 18                	jne    8009ec <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009d4:	50                   	push   %eax
  8009d5:	68 07 28 80 00       	push   $0x802807
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
  8009ed:	68 19 2c 80 00       	push   $0x802c19
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
  800a1a:	ba 00 28 80 00       	mov    $0x802800,%edx
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
  801099:	68 1f 2b 80 00       	push   $0x802b1f
  80109e:	6a 23                	push   $0x23
  8010a0:	68 3c 2b 80 00       	push   $0x802b3c
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
  80111a:	68 1f 2b 80 00       	push   $0x802b1f
  80111f:	6a 23                	push   $0x23
  801121:	68 3c 2b 80 00       	push   $0x802b3c
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
  80115c:	68 1f 2b 80 00       	push   $0x802b1f
  801161:	6a 23                	push   $0x23
  801163:	68 3c 2b 80 00       	push   $0x802b3c
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
  80119e:	68 1f 2b 80 00       	push   $0x802b1f
  8011a3:	6a 23                	push   $0x23
  8011a5:	68 3c 2b 80 00       	push   $0x802b3c
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
  8011e0:	68 1f 2b 80 00       	push   $0x802b1f
  8011e5:	6a 23                	push   $0x23
  8011e7:	68 3c 2b 80 00       	push   $0x802b3c
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
  801222:	68 1f 2b 80 00       	push   $0x802b1f
  801227:	6a 23                	push   $0x23
  801229:	68 3c 2b 80 00       	push   $0x802b3c
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
  801264:	68 1f 2b 80 00       	push   $0x802b1f
  801269:	6a 23                	push   $0x23
  80126b:	68 3c 2b 80 00       	push   $0x802b3c
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
  8012c8:	68 1f 2b 80 00       	push   $0x802b1f
  8012cd:	6a 23                	push   $0x23
  8012cf:	68 3c 2b 80 00       	push   $0x802b3c
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

008012e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012f6:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	50                   	push   %eax
  8012fd:	e8 9e ff ff ff       	call   8012a0 <sys_ipc_recv>
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	79 16                	jns    80131f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801309:	85 f6                	test   %esi,%esi
  80130b:	74 06                	je     801313 <ipc_recv+0x32>
  80130d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801313:	85 db                	test   %ebx,%ebx
  801315:	74 2c                	je     801343 <ipc_recv+0x62>
  801317:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80131d:	eb 24                	jmp    801343 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80131f:	85 f6                	test   %esi,%esi
  801321:	74 0a                	je     80132d <ipc_recv+0x4c>
  801323:	a1 04 40 80 00       	mov    0x804004,%eax
  801328:	8b 40 74             	mov    0x74(%eax),%eax
  80132b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80132d:	85 db                	test   %ebx,%ebx
  80132f:	74 0a                	je     80133b <ipc_recv+0x5a>
  801331:	a1 04 40 80 00       	mov    0x804004,%eax
  801336:	8b 40 78             	mov    0x78(%eax),%eax
  801339:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80133b:	a1 04 40 80 00       	mov    0x804004,%eax
  801340:	8b 40 70             	mov    0x70(%eax),%eax
}
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	57                   	push   %edi
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	8b 7d 08             	mov    0x8(%ebp),%edi
  801356:	8b 75 0c             	mov    0xc(%ebp),%esi
  801359:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80135c:	85 db                	test   %ebx,%ebx
  80135e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801363:	0f 44 d8             	cmove  %eax,%ebx
  801366:	eb 1c                	jmp    801384 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801368:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80136b:	74 12                	je     80137f <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80136d:	50                   	push   %eax
  80136e:	68 4a 2b 80 00       	push   $0x802b4a
  801373:	6a 39                	push   $0x39
  801375:	68 65 2b 80 00       	push   $0x802b65
  80137a:	e8 08 f3 ff ff       	call   800687 <_panic>
                 sys_yield();
  80137f:	e8 4d fd ff ff       	call   8010d1 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801384:	ff 75 14             	pushl  0x14(%ebp)
  801387:	53                   	push   %ebx
  801388:	56                   	push   %esi
  801389:	57                   	push   %edi
  80138a:	e8 ee fe ff ff       	call   80127d <sys_ipc_try_send>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 d2                	js     801368 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801396:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5f                   	pop    %edi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013ac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b2:	8b 52 50             	mov    0x50(%edx),%edx
  8013b5:	39 ca                	cmp    %ecx,%edx
  8013b7:	75 0d                	jne    8013c6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013bc:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8013c1:	8b 40 08             	mov    0x8(%eax),%eax
  8013c4:	eb 0e                	jmp    8013d4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013c6:	83 c0 01             	add    $0x1,%eax
  8013c9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013ce:	75 d9                	jne    8013a9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d0:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dc:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
}
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ec:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013f6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801403:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801408:	89 c2                	mov    %eax,%edx
  80140a:	c1 ea 16             	shr    $0x16,%edx
  80140d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801414:	f6 c2 01             	test   $0x1,%dl
  801417:	74 11                	je     80142a <fd_alloc+0x2d>
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 0c             	shr    $0xc,%edx
  80141e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801425:	f6 c2 01             	test   $0x1,%dl
  801428:	75 09                	jne    801433 <fd_alloc+0x36>
			*fd_store = fd;
  80142a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	eb 17                	jmp    80144a <fd_alloc+0x4d>
  801433:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801438:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143d:	75 c9                	jne    801408 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80143f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801445:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801452:	83 f8 1f             	cmp    $0x1f,%eax
  801455:	77 36                	ja     80148d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801457:	c1 e0 0c             	shl    $0xc,%eax
  80145a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80145f:	89 c2                	mov    %eax,%edx
  801461:	c1 ea 16             	shr    $0x16,%edx
  801464:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146b:	f6 c2 01             	test   $0x1,%dl
  80146e:	74 24                	je     801494 <fd_lookup+0x48>
  801470:	89 c2                	mov    %eax,%edx
  801472:	c1 ea 0c             	shr    $0xc,%edx
  801475:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147c:	f6 c2 01             	test   $0x1,%dl
  80147f:	74 1a                	je     80149b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801481:	8b 55 0c             	mov    0xc(%ebp),%edx
  801484:	89 02                	mov    %eax,(%edx)
	return 0;
  801486:	b8 00 00 00 00       	mov    $0x0,%eax
  80148b:	eb 13                	jmp    8014a0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80148d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801492:	eb 0c                	jmp    8014a0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801494:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801499:	eb 05                	jmp    8014a0 <fd_lookup+0x54>
  80149b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ab:	ba f0 2b 80 00       	mov    $0x802bf0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b0:	eb 13                	jmp    8014c5 <dev_lookup+0x23>
  8014b2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014b5:	39 08                	cmp    %ecx,(%eax)
  8014b7:	75 0c                	jne    8014c5 <dev_lookup+0x23>
			*dev = devtab[i];
  8014b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014be:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c3:	eb 2e                	jmp    8014f3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014c5:	8b 02                	mov    (%edx),%eax
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	75 e7                	jne    8014b2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d0:	8b 40 48             	mov    0x48(%eax),%eax
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	51                   	push   %ecx
  8014d7:	50                   	push   %eax
  8014d8:	68 70 2b 80 00       	push   $0x802b70
  8014dd:	e8 7e f2 ff ff       	call   800760 <cprintf>
	*dev = 0;
  8014e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 10             	sub    $0x10,%esp
  8014fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801500:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801503:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801506:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801507:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80150d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801510:	50                   	push   %eax
  801511:	e8 36 ff ff ff       	call   80144c <fd_lookup>
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 05                	js     801522 <fd_close+0x2d>
	    || fd != fd2)
  80151d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801520:	74 0c                	je     80152e <fd_close+0x39>
		return (must_exist ? r : 0);
  801522:	84 db                	test   %bl,%bl
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	0f 44 c2             	cmove  %edx,%eax
  80152c:	eb 41                	jmp    80156f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	ff 36                	pushl  (%esi)
  801537:	e8 66 ff ff ff       	call   8014a2 <dev_lookup>
  80153c:	89 c3                	mov    %eax,%ebx
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 1a                	js     80155f <fd_close+0x6a>
		if (dev->dev_close)
  801545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801548:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80154b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801550:	85 c0                	test   %eax,%eax
  801552:	74 0b                	je     80155f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	56                   	push   %esi
  801558:	ff d0                	call   *%eax
  80155a:	89 c3                	mov    %eax,%ebx
  80155c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	56                   	push   %esi
  801563:	6a 00                	push   $0x0
  801565:	e8 0b fc ff ff       	call   801175 <sys_page_unmap>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	89 d8                	mov    %ebx,%eax
}
  80156f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	ff 75 08             	pushl  0x8(%ebp)
  801583:	e8 c4 fe ff ff       	call   80144c <fd_lookup>
  801588:	89 c2                	mov    %eax,%edx
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	85 d2                	test   %edx,%edx
  80158f:	78 10                	js     8015a1 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	6a 01                	push   $0x1
  801596:	ff 75 f4             	pushl  -0xc(%ebp)
  801599:	e8 57 ff ff ff       	call   8014f5 <fd_close>
  80159e:	83 c4 10             	add    $0x10,%esp
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <close_all>:

void
close_all(void)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	e8 be ff ff ff       	call   801576 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b8:	83 c3 01             	add    $0x1,%ebx
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	83 fb 20             	cmp    $0x20,%ebx
  8015c1:	75 ec                	jne    8015af <close_all+0xc>
		close(i);
}
  8015c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	57                   	push   %edi
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 2c             	sub    $0x2c,%esp
  8015d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 6c fe ff ff       	call   80144c <fd_lookup>
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	85 d2                	test   %edx,%edx
  8015e7:	0f 88 c1 00 00 00    	js     8016ae <dup+0xe6>
		return r;
	close(newfdnum);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	56                   	push   %esi
  8015f1:	e8 80 ff ff ff       	call   801576 <close>

	newfd = INDEX2FD(newfdnum);
  8015f6:	89 f3                	mov    %esi,%ebx
  8015f8:	c1 e3 0c             	shl    $0xc,%ebx
  8015fb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801601:	83 c4 04             	add    $0x4,%esp
  801604:	ff 75 e4             	pushl  -0x1c(%ebp)
  801607:	e8 da fd ff ff       	call   8013e6 <fd2data>
  80160c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80160e:	89 1c 24             	mov    %ebx,(%esp)
  801611:	e8 d0 fd ff ff       	call   8013e6 <fd2data>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80161c:	89 f8                	mov    %edi,%eax
  80161e:	c1 e8 16             	shr    $0x16,%eax
  801621:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801628:	a8 01                	test   $0x1,%al
  80162a:	74 37                	je     801663 <dup+0x9b>
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	c1 e8 0c             	shr    $0xc,%eax
  801631:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801638:	f6 c2 01             	test   $0x1,%dl
  80163b:	74 26                	je     801663 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	25 07 0e 00 00       	and    $0xe07,%eax
  80164c:	50                   	push   %eax
  80164d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801650:	6a 00                	push   $0x0
  801652:	57                   	push   %edi
  801653:	6a 00                	push   $0x0
  801655:	e8 d9 fa ff ff       	call   801133 <sys_page_map>
  80165a:	89 c7                	mov    %eax,%edi
  80165c:	83 c4 20             	add    $0x20,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 2e                	js     801691 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801663:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801666:	89 d0                	mov    %edx,%eax
  801668:	c1 e8 0c             	shr    $0xc,%eax
  80166b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	25 07 0e 00 00       	and    $0xe07,%eax
  80167a:	50                   	push   %eax
  80167b:	53                   	push   %ebx
  80167c:	6a 00                	push   $0x0
  80167e:	52                   	push   %edx
  80167f:	6a 00                	push   $0x0
  801681:	e8 ad fa ff ff       	call   801133 <sys_page_map>
  801686:	89 c7                	mov    %eax,%edi
  801688:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80168b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168d:	85 ff                	test   %edi,%edi
  80168f:	79 1d                	jns    8016ae <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	53                   	push   %ebx
  801695:	6a 00                	push   $0x0
  801697:	e8 d9 fa ff ff       	call   801175 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 cc fa ff ff       	call   801175 <sys_page_unmap>
	return r;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	89 f8                	mov    %edi,%eax
}
  8016ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5f                   	pop    %edi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 14             	sub    $0x14,%esp
  8016bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	53                   	push   %ebx
  8016c5:	e8 82 fd ff ff       	call   80144c <fd_lookup>
  8016ca:	83 c4 08             	add    $0x8,%esp
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 6d                	js     801740 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	ff 30                	pushl  (%eax)
  8016df:	e8 be fd ff ff       	call   8014a2 <dev_lookup>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 4c                	js     801737 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ee:	8b 42 08             	mov    0x8(%edx),%eax
  8016f1:	83 e0 03             	and    $0x3,%eax
  8016f4:	83 f8 01             	cmp    $0x1,%eax
  8016f7:	75 21                	jne    80171a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fe:	8b 40 48             	mov    0x48(%eax),%eax
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	53                   	push   %ebx
  801705:	50                   	push   %eax
  801706:	68 b4 2b 80 00       	push   $0x802bb4
  80170b:	e8 50 f0 ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801718:	eb 26                	jmp    801740 <read+0x8a>
	}
	if (!dev->dev_read)
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	8b 40 08             	mov    0x8(%eax),%eax
  801720:	85 c0                	test   %eax,%eax
  801722:	74 17                	je     80173b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	ff 75 10             	pushl  0x10(%ebp)
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	52                   	push   %edx
  80172e:	ff d0                	call   *%eax
  801730:	89 c2                	mov    %eax,%edx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb 09                	jmp    801740 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	89 c2                	mov    %eax,%edx
  801739:	eb 05                	jmp    801740 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80173b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801740:	89 d0                	mov    %edx,%eax
  801742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	57                   	push   %edi
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	8b 7d 08             	mov    0x8(%ebp),%edi
  801753:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	eb 21                	jmp    80177e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	89 f0                	mov    %esi,%eax
  801762:	29 d8                	sub    %ebx,%eax
  801764:	50                   	push   %eax
  801765:	89 d8                	mov    %ebx,%eax
  801767:	03 45 0c             	add    0xc(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	57                   	push   %edi
  80176c:	e8 45 ff ff ff       	call   8016b6 <read>
		if (m < 0)
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 0c                	js     801784 <readn+0x3d>
			return m;
		if (m == 0)
  801778:	85 c0                	test   %eax,%eax
  80177a:	74 06                	je     801782 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80177c:	01 c3                	add    %eax,%ebx
  80177e:	39 f3                	cmp    %esi,%ebx
  801780:	72 db                	jb     80175d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801782:	89 d8                	mov    %ebx,%eax
}
  801784:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 14             	sub    $0x14,%esp
  801793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801796:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	53                   	push   %ebx
  80179b:	e8 ac fc ff ff       	call   80144c <fd_lookup>
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	89 c2                	mov    %eax,%edx
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 68                	js     801811 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b3:	ff 30                	pushl  (%eax)
  8017b5:	e8 e8 fc ff ff       	call   8014a2 <dev_lookup>
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 47                	js     801808 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c8:	75 21                	jne    8017eb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8017cf:	8b 40 48             	mov    0x48(%eax),%eax
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	53                   	push   %ebx
  8017d6:	50                   	push   %eax
  8017d7:	68 d0 2b 80 00       	push   $0x802bd0
  8017dc:	e8 7f ef ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e9:	eb 26                	jmp    801811 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f1:	85 d2                	test   %edx,%edx
  8017f3:	74 17                	je     80180c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	ff 75 10             	pushl  0x10(%ebp)
  8017fb:	ff 75 0c             	pushl  0xc(%ebp)
  8017fe:	50                   	push   %eax
  8017ff:	ff d2                	call   *%edx
  801801:	89 c2                	mov    %eax,%edx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 09                	jmp    801811 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801808:	89 c2                	mov    %eax,%edx
  80180a:	eb 05                	jmp    801811 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80180c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801811:	89 d0                	mov    %edx,%eax
  801813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <seek>:

int
seek(int fdnum, off_t offset)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 22 fc ff ff       	call   80144c <fd_lookup>
  80182a:	83 c4 08             	add    $0x8,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 0e                	js     80183f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801831:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801834:	8b 55 0c             	mov    0xc(%ebp),%edx
  801837:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	53                   	push   %ebx
  801845:	83 ec 14             	sub    $0x14,%esp
  801848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184e:	50                   	push   %eax
  80184f:	53                   	push   %ebx
  801850:	e8 f7 fb ff ff       	call   80144c <fd_lookup>
  801855:	83 c4 08             	add    $0x8,%esp
  801858:	89 c2                	mov    %eax,%edx
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 65                	js     8018c3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801868:	ff 30                	pushl  (%eax)
  80186a:	e8 33 fc ff ff       	call   8014a2 <dev_lookup>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 44                	js     8018ba <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801876:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801879:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80187d:	75 21                	jne    8018a0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80187f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801884:	8b 40 48             	mov    0x48(%eax),%eax
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	53                   	push   %ebx
  80188b:	50                   	push   %eax
  80188c:	68 90 2b 80 00       	push   $0x802b90
  801891:	e8 ca ee ff ff       	call   800760 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80189e:	eb 23                	jmp    8018c3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a3:	8b 52 18             	mov    0x18(%edx),%edx
  8018a6:	85 d2                	test   %edx,%edx
  8018a8:	74 14                	je     8018be <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	50                   	push   %eax
  8018b1:	ff d2                	call   *%edx
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 09                	jmp    8018c3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	eb 05                	jmp    8018c3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 14             	sub    $0x14,%esp
  8018d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d7:	50                   	push   %eax
  8018d8:	ff 75 08             	pushl  0x8(%ebp)
  8018db:	e8 6c fb ff ff       	call   80144c <fd_lookup>
  8018e0:	83 c4 08             	add    $0x8,%esp
  8018e3:	89 c2                	mov    %eax,%edx
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 58                	js     801941 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ef:	50                   	push   %eax
  8018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f3:	ff 30                	pushl  (%eax)
  8018f5:	e8 a8 fb ff ff       	call   8014a2 <dev_lookup>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 37                	js     801938 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801901:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801904:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801908:	74 32                	je     80193c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80190a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80190d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801914:	00 00 00 
	stat->st_isdir = 0;
  801917:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191e:	00 00 00 
	stat->st_dev = dev;
  801921:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	53                   	push   %ebx
  80192b:	ff 75 f0             	pushl  -0x10(%ebp)
  80192e:	ff 50 14             	call   *0x14(%eax)
  801931:	89 c2                	mov    %eax,%edx
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	eb 09                	jmp    801941 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	89 c2                	mov    %eax,%edx
  80193a:	eb 05                	jmp    801941 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80193c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801941:	89 d0                	mov    %edx,%eax
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	6a 00                	push   $0x0
  801952:	ff 75 08             	pushl  0x8(%ebp)
  801955:	e8 09 02 00 00       	call   801b63 <open>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 db                	test   %ebx,%ebx
  801961:	78 1b                	js     80197e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	53                   	push   %ebx
  80196a:	e8 5b ff ff ff       	call   8018ca <fstat>
  80196f:	89 c6                	mov    %eax,%esi
	close(fd);
  801971:	89 1c 24             	mov    %ebx,(%esp)
  801974:	e8 fd fb ff ff       	call   801576 <close>
	return r;
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	89 f0                	mov    %esi,%eax
}
  80197e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	89 c6                	mov    %eax,%esi
  80198c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80198e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801995:	75 12                	jne    8019a9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	6a 01                	push   $0x1
  80199c:	e8 fd f9 ff ff       	call   80139e <ipc_find_env>
  8019a1:	a3 00 40 80 00       	mov    %eax,0x804000
  8019a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019a9:	6a 07                	push   $0x7
  8019ab:	68 00 50 80 00       	push   $0x805000
  8019b0:	56                   	push   %esi
  8019b1:	ff 35 00 40 80 00    	pushl  0x804000
  8019b7:	e8 8e f9 ff ff       	call   80134a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019bc:	83 c4 0c             	add    $0xc,%esp
  8019bf:	6a 00                	push   $0x0
  8019c1:	53                   	push   %ebx
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 18 f9 ff ff       	call   8012e1 <ipc_recv>
}
  8019c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f3:	e8 8d ff ff ff       	call   801985 <fsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	8b 40 0c             	mov    0xc(%eax),%eax
  801a06:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	b8 06 00 00 00       	mov    $0x6,%eax
  801a15:	e8 6b ff ff ff       	call   801985 <fsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 04             	sub    $0x4,%esp
  801a23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 05 00 00 00       	mov    $0x5,%eax
  801a3b:	e8 45 ff ff ff       	call   801985 <fsipc>
  801a40:	89 c2                	mov    %eax,%edx
  801a42:	85 d2                	test   %edx,%edx
  801a44:	78 2c                	js     801a72 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	68 00 50 80 00       	push   $0x805000
  801a4e:	53                   	push   %ebx
  801a4f:	e8 93 f2 ff ff       	call   800ce7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a54:	a1 80 50 80 00       	mov    0x805080,%eax
  801a59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a5f:	a1 84 50 80 00       	mov    0x805084,%eax
  801a64:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	8b 40 0c             	mov    0xc(%eax),%eax
  801a89:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801a91:	eb 3d                	jmp    801ad0 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801a93:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801a99:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801a9e:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	57                   	push   %edi
  801aa5:	53                   	push   %ebx
  801aa6:	68 08 50 80 00       	push   $0x805008
  801aab:	e8 c9 f3 ff ff       	call   800e79 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801ab0:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  801abb:	b8 04 00 00 00       	mov    $0x4,%eax
  801ac0:	e8 c0 fe ff ff       	call   801985 <fsipc>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 0d                	js     801ad9 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801acc:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801ace:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801ad0:	85 f6                	test   %esi,%esi
  801ad2:	75 bf                	jne    801a93 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801ad4:	89 d8                	mov    %ebx,%eax
  801ad6:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 40 0c             	mov    0xc(%eax),%eax
  801aef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801af4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801afa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aff:	b8 03 00 00 00       	mov    $0x3,%eax
  801b04:	e8 7c fe ff ff       	call   801985 <fsipc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 4b                	js     801b5a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b0f:	39 c6                	cmp    %eax,%esi
  801b11:	73 16                	jae    801b29 <devfile_read+0x48>
  801b13:	68 00 2c 80 00       	push   $0x802c00
  801b18:	68 07 2c 80 00       	push   $0x802c07
  801b1d:	6a 7c                	push   $0x7c
  801b1f:	68 1c 2c 80 00       	push   $0x802c1c
  801b24:	e8 5e eb ff ff       	call   800687 <_panic>
	assert(r <= PGSIZE);
  801b29:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2e:	7e 16                	jle    801b46 <devfile_read+0x65>
  801b30:	68 27 2c 80 00       	push   $0x802c27
  801b35:	68 07 2c 80 00       	push   $0x802c07
  801b3a:	6a 7d                	push   $0x7d
  801b3c:	68 1c 2c 80 00       	push   $0x802c1c
  801b41:	e8 41 eb ff ff       	call   800687 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	50                   	push   %eax
  801b4a:	68 00 50 80 00       	push   $0x805000
  801b4f:	ff 75 0c             	pushl  0xc(%ebp)
  801b52:	e8 22 f3 ff ff       	call   800e79 <memmove>
	return r;
  801b57:	83 c4 10             	add    $0x10,%esp
}
  801b5a:	89 d8                	mov    %ebx,%eax
  801b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	53                   	push   %ebx
  801b67:	83 ec 20             	sub    $0x20,%esp
  801b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b6d:	53                   	push   %ebx
  801b6e:	e8 3b f1 ff ff       	call   800cae <strlen>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b7b:	7f 67                	jg     801be4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	e8 74 f8 ff ff       	call   8013fd <fd_alloc>
  801b89:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 57                	js     801be9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b92:	83 ec 08             	sub    $0x8,%esp
  801b95:	53                   	push   %ebx
  801b96:	68 00 50 80 00       	push   $0x805000
  801b9b:	e8 47 f1 ff ff       	call   800ce7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bab:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb0:	e8 d0 fd ff ff       	call   801985 <fsipc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	79 14                	jns    801bd2 <open+0x6f>
		fd_close(fd, 0);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	6a 00                	push   $0x0
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	e8 2a f9 ff ff       	call   8014f5 <fd_close>
		return r;
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	89 da                	mov    %ebx,%edx
  801bd0:	eb 17                	jmp    801be9 <open+0x86>
	}

	return fd2num(fd);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd8:	e8 f9 f7 ff ff       	call   8013d6 <fd2num>
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	eb 05                	jmp    801be9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801be4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be9:	89 d0                	mov    %edx,%eax
  801beb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfb:	b8 08 00 00 00       	mov    $0x8,%eax
  801c00:	e8 80 fd ff ff       	call   801985 <fsipc>
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 08             	pushl  0x8(%ebp)
  801c15:	e8 cc f7 ff ff       	call   8013e6 <fd2data>
  801c1a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c1c:	83 c4 08             	add    $0x8,%esp
  801c1f:	68 33 2c 80 00       	push   $0x802c33
  801c24:	53                   	push   %ebx
  801c25:	e8 bd f0 ff ff       	call   800ce7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c2a:	8b 56 04             	mov    0x4(%esi),%edx
  801c2d:	89 d0                	mov    %edx,%eax
  801c2f:	2b 06                	sub    (%esi),%eax
  801c31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3e:	00 00 00 
	stat->st_dev = &devpipe;
  801c41:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c48:	30 80 00 
	return 0;
}
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	53                   	push   %ebx
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c61:	53                   	push   %ebx
  801c62:	6a 00                	push   $0x0
  801c64:	e8 0c f5 ff ff       	call   801175 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c69:	89 1c 24             	mov    %ebx,(%esp)
  801c6c:	e8 75 f7 ff ff       	call   8013e6 <fd2data>
  801c71:	83 c4 08             	add    $0x8,%esp
  801c74:	50                   	push   %eax
  801c75:	6a 00                	push   $0x0
  801c77:	e8 f9 f4 ff ff       	call   801175 <sys_page_unmap>
}
  801c7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	57                   	push   %edi
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	83 ec 1c             	sub    $0x1c,%esp
  801c8a:	89 c6                	mov    %eax,%esi
  801c8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c8f:	a1 04 40 80 00       	mov    0x804004,%eax
  801c94:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	56                   	push   %esi
  801c9b:	e8 43 04 00 00       	call   8020e3 <pageref>
  801ca0:	89 c7                	mov    %eax,%edi
  801ca2:	83 c4 04             	add    $0x4,%esp
  801ca5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ca8:	e8 36 04 00 00       	call   8020e3 <pageref>
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	39 c7                	cmp    %eax,%edi
  801cb2:	0f 94 c2             	sete   %dl
  801cb5:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cb8:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801cbe:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cc1:	39 fb                	cmp    %edi,%ebx
  801cc3:	74 19                	je     801cde <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801cc5:	84 d2                	test   %dl,%dl
  801cc7:	74 c6                	je     801c8f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cc9:	8b 51 58             	mov    0x58(%ecx),%edx
  801ccc:	50                   	push   %eax
  801ccd:	52                   	push   %edx
  801cce:	53                   	push   %ebx
  801ccf:	68 3a 2c 80 00       	push   $0x802c3a
  801cd4:	e8 87 ea ff ff       	call   800760 <cprintf>
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	eb b1                	jmp    801c8f <_pipeisclosed+0xe>
	}
}
  801cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 28             	sub    $0x28,%esp
  801cef:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cf2:	56                   	push   %esi
  801cf3:	e8 ee f6 ff ff       	call   8013e6 <fd2data>
  801cf8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	bf 00 00 00 00       	mov    $0x0,%edi
  801d02:	eb 4b                	jmp    801d4f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d04:	89 da                	mov    %ebx,%edx
  801d06:	89 f0                	mov    %esi,%eax
  801d08:	e8 74 ff ff ff       	call   801c81 <_pipeisclosed>
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	75 48                	jne    801d59 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d11:	e8 bb f3 ff ff       	call   8010d1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d16:	8b 43 04             	mov    0x4(%ebx),%eax
  801d19:	8b 0b                	mov    (%ebx),%ecx
  801d1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d1e:	39 d0                	cmp    %edx,%eax
  801d20:	73 e2                	jae    801d04 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	c1 fa 1f             	sar    $0x1f,%edx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	c1 e9 1b             	shr    $0x1b,%ecx
  801d36:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d39:	83 e2 1f             	and    $0x1f,%edx
  801d3c:	29 ca                	sub    %ecx,%edx
  801d3e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d46:	83 c0 01             	add    $0x1,%eax
  801d49:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4c:	83 c7 01             	add    $0x1,%edi
  801d4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d52:	75 c2                	jne    801d16 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d54:	8b 45 10             	mov    0x10(%ebp),%eax
  801d57:	eb 05                	jmp    801d5e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	57                   	push   %edi
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	83 ec 18             	sub    $0x18,%esp
  801d6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d72:	57                   	push   %edi
  801d73:	e8 6e f6 ff ff       	call   8013e6 <fd2data>
  801d78:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d82:	eb 3d                	jmp    801dc1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d84:	85 db                	test   %ebx,%ebx
  801d86:	74 04                	je     801d8c <devpipe_read+0x26>
				return i;
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	eb 44                	jmp    801dd0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d8c:	89 f2                	mov    %esi,%edx
  801d8e:	89 f8                	mov    %edi,%eax
  801d90:	e8 ec fe ff ff       	call   801c81 <_pipeisclosed>
  801d95:	85 c0                	test   %eax,%eax
  801d97:	75 32                	jne    801dcb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d99:	e8 33 f3 ff ff       	call   8010d1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d9e:	8b 06                	mov    (%esi),%eax
  801da0:	3b 46 04             	cmp    0x4(%esi),%eax
  801da3:	74 df                	je     801d84 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da5:	99                   	cltd   
  801da6:	c1 ea 1b             	shr    $0x1b,%edx
  801da9:	01 d0                	add    %edx,%eax
  801dab:	83 e0 1f             	and    $0x1f,%eax
  801dae:	29 d0                	sub    %edx,%eax
  801db0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dbb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	83 c3 01             	add    $0x1,%ebx
  801dc1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc4:	75 d8                	jne    801d9e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc9:	eb 05                	jmp    801dd0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	e8 14 f6 ff ff       	call   8013fd <fd_alloc>
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	89 c2                	mov    %eax,%edx
  801dee:	85 c0                	test   %eax,%eax
  801df0:	0f 88 2c 01 00 00    	js     801f22 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	68 07 04 00 00       	push   $0x407
  801dfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801e01:	6a 00                	push   $0x0
  801e03:	e8 e8 f2 ff ff       	call   8010f0 <sys_page_alloc>
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 0d 01 00 00    	js     801f22 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	e8 dc f5 ff ff       	call   8013fd <fd_alloc>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	0f 88 e2 00 00 00    	js     801f10 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2e:	83 ec 04             	sub    $0x4,%esp
  801e31:	68 07 04 00 00       	push   $0x407
  801e36:	ff 75 f0             	pushl  -0x10(%ebp)
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 b0 f2 ff ff       	call   8010f0 <sys_page_alloc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	0f 88 c3 00 00 00    	js     801f10 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	ff 75 f4             	pushl  -0xc(%ebp)
  801e53:	e8 8e f5 ff ff       	call   8013e6 <fd2data>
  801e58:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	83 c4 0c             	add    $0xc,%esp
  801e5d:	68 07 04 00 00       	push   $0x407
  801e62:	50                   	push   %eax
  801e63:	6a 00                	push   $0x0
  801e65:	e8 86 f2 ff ff       	call   8010f0 <sys_page_alloc>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	0f 88 89 00 00 00    	js     801f00 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e7d:	e8 64 f5 ff ff       	call   8013e6 <fd2data>
  801e82:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e89:	50                   	push   %eax
  801e8a:	6a 00                	push   $0x0
  801e8c:	56                   	push   %esi
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 9f f2 ff ff       	call   801133 <sys_page_map>
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	83 c4 20             	add    $0x20,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 55                	js     801ef2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e9d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb2:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	e8 04 f5 ff ff       	call   8013d6 <fd2num>
  801ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ed7:	83 c4 04             	add    $0x4,%esp
  801eda:	ff 75 f0             	pushl  -0x10(%ebp)
  801edd:	e8 f4 f4 ff ff       	call   8013d6 <fd2num>
  801ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef0:	eb 30                	jmp    801f22 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ef2:	83 ec 08             	sub    $0x8,%esp
  801ef5:	56                   	push   %esi
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 78 f2 ff ff       	call   801175 <sys_page_unmap>
  801efd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	ff 75 f0             	pushl  -0x10(%ebp)
  801f06:	6a 00                	push   $0x0
  801f08:	e8 68 f2 ff ff       	call   801175 <sys_page_unmap>
  801f0d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f10:	83 ec 08             	sub    $0x8,%esp
  801f13:	ff 75 f4             	pushl  -0xc(%ebp)
  801f16:	6a 00                	push   $0x0
  801f18:	e8 58 f2 ff ff       	call   801175 <sys_page_unmap>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f22:	89 d0                	mov    %edx,%eax
  801f24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f34:	50                   	push   %eax
  801f35:	ff 75 08             	pushl  0x8(%ebp)
  801f38:	e8 0f f5 ff ff       	call   80144c <fd_lookup>
  801f3d:	89 c2                	mov    %eax,%edx
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 d2                	test   %edx,%edx
  801f44:	78 18                	js     801f5e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4c:	e8 95 f4 ff ff       	call   8013e6 <fd2data>
	return _pipeisclosed(fd, p);
  801f51:	89 c2                	mov    %eax,%edx
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	e8 26 fd ff ff       	call   801c81 <_pipeisclosed>
  801f5b:	83 c4 10             	add    $0x10,%esp
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f70:	68 52 2c 80 00       	push   $0x802c52
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	e8 6a ed ff ff       	call   800ce7 <strcpy>
	return 0;
}
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	57                   	push   %edi
  801f88:	56                   	push   %esi
  801f89:	53                   	push   %ebx
  801f8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f90:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9b:	eb 2d                	jmp    801fca <devcons_write+0x46>
		m = n - tot;
  801f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fa2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fa5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801faa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fad:	83 ec 04             	sub    $0x4,%esp
  801fb0:	53                   	push   %ebx
  801fb1:	03 45 0c             	add    0xc(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	57                   	push   %edi
  801fb6:	e8 be ee ff ff       	call   800e79 <memmove>
		sys_cputs(buf, m);
  801fbb:	83 c4 08             	add    $0x8,%esp
  801fbe:	53                   	push   %ebx
  801fbf:	57                   	push   %edi
  801fc0:	e8 6f f0 ff ff       	call   801034 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc5:	01 de                	add    %ebx,%esi
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	89 f0                	mov    %esi,%eax
  801fcc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fcf:	72 cc                	jb     801f9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801fe4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe8:	75 07                	jne    801ff1 <devcons_read+0x18>
  801fea:	eb 28                	jmp    802014 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fec:	e8 e0 f0 ff ff       	call   8010d1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ff1:	e8 5c f0 ff ff       	call   801052 <sys_cgetc>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	74 f2                	je     801fec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	78 16                	js     802014 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ffe:	83 f8 04             	cmp    $0x4,%eax
  802001:	74 0c                	je     80200f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802003:	8b 55 0c             	mov    0xc(%ebp),%edx
  802006:	88 02                	mov    %al,(%edx)
	return 1;
  802008:	b8 01 00 00 00       	mov    $0x1,%eax
  80200d:	eb 05                	jmp    802014 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802022:	6a 01                	push   $0x1
  802024:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	e8 07 f0 ff ff       	call   801034 <sys_cputs>
  80202d:	83 c4 10             	add    $0x10,%esp
}
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <getchar>:

int
getchar(void)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802038:	6a 01                	push   $0x1
  80203a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	6a 00                	push   $0x0
  802040:	e8 71 f6 ff ff       	call   8016b6 <read>
	if (r < 0)
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 0f                	js     80205b <getchar+0x29>
		return r;
	if (r < 1)
  80204c:	85 c0                	test   %eax,%eax
  80204e:	7e 06                	jle    802056 <getchar+0x24>
		return -E_EOF;
	return c;
  802050:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802054:	eb 05                	jmp    80205b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802056:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	ff 75 08             	pushl  0x8(%ebp)
  80206a:	e8 dd f3 ff ff       	call   80144c <fd_lookup>
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	78 11                	js     802087 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802079:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80207f:	39 10                	cmp    %edx,(%eax)
  802081:	0f 94 c0             	sete   %al
  802084:	0f b6 c0             	movzbl %al,%eax
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <opencons>:

int
opencons(void)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	e8 65 f3 ff ff       	call   8013fd <fd_alloc>
  802098:	83 c4 10             	add    $0x10,%esp
		return r;
  80209b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 3e                	js     8020df <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a1:	83 ec 04             	sub    $0x4,%esp
  8020a4:	68 07 04 00 00       	push   $0x407
  8020a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ac:	6a 00                	push   $0x0
  8020ae:	e8 3d f0 ff ff       	call   8010f0 <sys_page_alloc>
  8020b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 23                	js     8020df <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020bc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	50                   	push   %eax
  8020d5:	e8 fc f2 ff ff       	call   8013d6 <fd2num>
  8020da:	89 c2                	mov    %eax,%edx
  8020dc:	83 c4 10             	add    $0x10,%esp
}
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	c9                   	leave  
  8020e2:	c3                   	ret    

008020e3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	c1 e8 16             	shr    $0x16,%eax
  8020ee:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fa:	f6 c1 01             	test   $0x1,%cl
  8020fd:	74 1d                	je     80211c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ff:	c1 ea 0c             	shr    $0xc,%edx
  802102:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802109:	f6 c2 01             	test   $0x1,%dl
  80210c:	74 0e                	je     80211c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210e:	c1 ea 0c             	shr    $0xc,%edx
  802111:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802118:	ef 
  802119:	0f b7 c0             	movzwl %ax,%eax
}
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	83 ec 10             	sub    $0x10,%esp
  802126:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80212a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80212e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802132:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802136:	85 d2                	test   %edx,%edx
  802138:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80213c:	89 34 24             	mov    %esi,(%esp)
  80213f:	89 c8                	mov    %ecx,%eax
  802141:	75 35                	jne    802178 <__udivdi3+0x58>
  802143:	39 f1                	cmp    %esi,%ecx
  802145:	0f 87 bd 00 00 00    	ja     802208 <__udivdi3+0xe8>
  80214b:	85 c9                	test   %ecx,%ecx
  80214d:	89 cd                	mov    %ecx,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f1                	div    %ecx
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 f0                	mov    %esi,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c6                	mov    %eax,%esi
  802164:	89 f8                	mov    %edi,%eax
  802166:	f7 f5                	div    %ebp
  802168:	89 f2                	mov    %esi,%edx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	5e                   	pop    %esi
  80216e:	5f                   	pop    %edi
  80216f:	5d                   	pop    %ebp
  802170:	c3                   	ret    
  802171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802178:	3b 14 24             	cmp    (%esp),%edx
  80217b:	77 7b                	ja     8021f8 <__udivdi3+0xd8>
  80217d:	0f bd f2             	bsr    %edx,%esi
  802180:	83 f6 1f             	xor    $0x1f,%esi
  802183:	0f 84 97 00 00 00    	je     802220 <__udivdi3+0x100>
  802189:	bd 20 00 00 00       	mov    $0x20,%ebp
  80218e:	89 d7                	mov    %edx,%edi
  802190:	89 f1                	mov    %esi,%ecx
  802192:	29 f5                	sub    %esi,%ebp
  802194:	d3 e7                	shl    %cl,%edi
  802196:	89 c2                	mov    %eax,%edx
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	d3 ea                	shr    %cl,%edx
  80219c:	89 f1                	mov    %esi,%ecx
  80219e:	09 fa                	or     %edi,%edx
  8021a0:	8b 3c 24             	mov    (%esp),%edi
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021af:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021b3:	89 fa                	mov    %edi,%edx
  8021b5:	d3 ea                	shr    %cl,%edx
  8021b7:	89 f1                	mov    %esi,%ecx
  8021b9:	d3 e7                	shl    %cl,%edi
  8021bb:	89 e9                	mov    %ebp,%ecx
  8021bd:	d3 e8                	shr    %cl,%eax
  8021bf:	09 c7                	or     %eax,%edi
  8021c1:	89 f8                	mov    %edi,%eax
  8021c3:	f7 74 24 08          	divl   0x8(%esp)
  8021c7:	89 d5                	mov    %edx,%ebp
  8021c9:	89 c7                	mov    %eax,%edi
  8021cb:	f7 64 24 0c          	mull   0xc(%esp)
  8021cf:	39 d5                	cmp    %edx,%ebp
  8021d1:	89 14 24             	mov    %edx,(%esp)
  8021d4:	72 11                	jb     8021e7 <__udivdi3+0xc7>
  8021d6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021da:	89 f1                	mov    %esi,%ecx
  8021dc:	d3 e2                	shl    %cl,%edx
  8021de:	39 c2                	cmp    %eax,%edx
  8021e0:	73 5e                	jae    802240 <__udivdi3+0x120>
  8021e2:	3b 2c 24             	cmp    (%esp),%ebp
  8021e5:	75 59                	jne    802240 <__udivdi3+0x120>
  8021e7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021ea:	31 f6                	xor    %esi,%esi
  8021ec:	89 f2                	mov    %esi,%edx
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	31 f6                	xor    %esi,%esi
  8021fa:	31 c0                	xor    %eax,%eax
  8021fc:	89 f2                	mov    %esi,%edx
  8021fe:	83 c4 10             	add    $0x10,%esp
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	89 f2                	mov    %esi,%edx
  80220a:	31 f6                	xor    %esi,%esi
  80220c:	89 f8                	mov    %edi,%eax
  80220e:	f7 f1                	div    %ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802224:	76 0b                	jbe    802231 <__udivdi3+0x111>
  802226:	31 c0                	xor    %eax,%eax
  802228:	3b 14 24             	cmp    (%esp),%edx
  80222b:	0f 83 37 ff ff ff    	jae    802168 <__udivdi3+0x48>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	e9 2d ff ff ff       	jmp    802168 <__udivdi3+0x48>
  80223b:	90                   	nop
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f8                	mov    %edi,%eax
  802242:	31 f6                	xor    %esi,%esi
  802244:	e9 1f ff ff ff       	jmp    802168 <__udivdi3+0x48>
  802249:	66 90                	xchg   %ax,%ax
  80224b:	66 90                	xchg   %ax,%ax
  80224d:	66 90                	xchg   %ax,%ax
  80224f:	90                   	nop

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	83 ec 20             	sub    $0x20,%esp
  802256:	8b 44 24 34          	mov    0x34(%esp),%eax
  80225a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802262:	89 c6                	mov    %eax,%esi
  802264:	89 44 24 10          	mov    %eax,0x10(%esp)
  802268:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80226c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802270:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802274:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802278:	89 74 24 18          	mov    %esi,0x18(%esp)
  80227c:	85 c0                	test   %eax,%eax
  80227e:	89 c2                	mov    %eax,%edx
  802280:	75 1e                	jne    8022a0 <__umoddi3+0x50>
  802282:	39 f7                	cmp    %esi,%edi
  802284:	76 52                	jbe    8022d8 <__umoddi3+0x88>
  802286:	89 c8                	mov    %ecx,%eax
  802288:	89 f2                	mov    %esi,%edx
  80228a:	f7 f7                	div    %edi
  80228c:	89 d0                	mov    %edx,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	83 c4 20             	add    $0x20,%esp
  802293:	5e                   	pop    %esi
  802294:	5f                   	pop    %edi
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
  802297:	89 f6                	mov    %esi,%esi
  802299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022a0:	39 f0                	cmp    %esi,%eax
  8022a2:	77 5c                	ja     802300 <__umoddi3+0xb0>
  8022a4:	0f bd e8             	bsr    %eax,%ebp
  8022a7:	83 f5 1f             	xor    $0x1f,%ebp
  8022aa:	75 64                	jne    802310 <__umoddi3+0xc0>
  8022ac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022b0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022b4:	0f 86 f6 00 00 00    	jbe    8023b0 <__umoddi3+0x160>
  8022ba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022be:	0f 82 ec 00 00 00    	jb     8023b0 <__umoddi3+0x160>
  8022c4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022c8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022cc:	83 c4 20             	add    $0x20,%esp
  8022cf:	5e                   	pop    %esi
  8022d0:	5f                   	pop    %edi
  8022d1:	5d                   	pop    %ebp
  8022d2:	c3                   	ret    
  8022d3:	90                   	nop
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	85 ff                	test   %edi,%edi
  8022da:	89 fd                	mov    %edi,%ebp
  8022dc:	75 0b                	jne    8022e9 <__umoddi3+0x99>
  8022de:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f7                	div    %edi
  8022e7:	89 c5                	mov    %eax,%ebp
  8022e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022ed:	31 d2                	xor    %edx,%edx
  8022ef:	f7 f5                	div    %ebp
  8022f1:	89 c8                	mov    %ecx,%eax
  8022f3:	f7 f5                	div    %ebp
  8022f5:	eb 95                	jmp    80228c <__umoddi3+0x3c>
  8022f7:	89 f6                	mov    %esi,%esi
  8022f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 20             	add    $0x20,%esp
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    
  80230b:	90                   	nop
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	b8 20 00 00 00       	mov    $0x20,%eax
  802315:	89 e9                	mov    %ebp,%ecx
  802317:	29 e8                	sub    %ebp,%eax
  802319:	d3 e2                	shl    %cl,%edx
  80231b:	89 c7                	mov    %eax,%edi
  80231d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802321:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 c1                	mov    %eax,%ecx
  80232b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80232f:	09 d1                	or     %edx,%ecx
  802331:	89 fa                	mov    %edi,%edx
  802333:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802337:	89 e9                	mov    %ebp,%ecx
  802339:	d3 e0                	shl    %cl,%eax
  80233b:	89 f9                	mov    %edi,%ecx
  80233d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802341:	89 f0                	mov    %esi,%eax
  802343:	d3 e8                	shr    %cl,%eax
  802345:	89 e9                	mov    %ebp,%ecx
  802347:	89 c7                	mov    %eax,%edi
  802349:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80234d:	d3 e6                	shl    %cl,%esi
  80234f:	89 d1                	mov    %edx,%ecx
  802351:	89 fa                	mov    %edi,%edx
  802353:	d3 e8                	shr    %cl,%eax
  802355:	89 e9                	mov    %ebp,%ecx
  802357:	09 f0                	or     %esi,%eax
  802359:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80235d:	f7 74 24 10          	divl   0x10(%esp)
  802361:	d3 e6                	shl    %cl,%esi
  802363:	89 d1                	mov    %edx,%ecx
  802365:	f7 64 24 0c          	mull   0xc(%esp)
  802369:	39 d1                	cmp    %edx,%ecx
  80236b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80236f:	89 d7                	mov    %edx,%edi
  802371:	89 c6                	mov    %eax,%esi
  802373:	72 0a                	jb     80237f <__umoddi3+0x12f>
  802375:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802379:	73 10                	jae    80238b <__umoddi3+0x13b>
  80237b:	39 d1                	cmp    %edx,%ecx
  80237d:	75 0c                	jne    80238b <__umoddi3+0x13b>
  80237f:	89 d7                	mov    %edx,%edi
  802381:	89 c6                	mov    %eax,%esi
  802383:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802387:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80238b:	89 ca                	mov    %ecx,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802393:	29 f0                	sub    %esi,%eax
  802395:	19 fa                	sbb    %edi,%edx
  802397:	d3 e8                	shr    %cl,%eax
  802399:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80239e:	89 d7                	mov    %edx,%edi
  8023a0:	d3 e7                	shl    %cl,%edi
  8023a2:	89 e9                	mov    %ebp,%ecx
  8023a4:	09 f8                	or     %edi,%eax
  8023a6:	d3 ea                	shr    %cl,%edx
  8023a8:	83 c4 20             	add    $0x20,%esp
  8023ab:	5e                   	pop    %esi
  8023ac:	5f                   	pop    %edi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    
  8023af:	90                   	nop
  8023b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023b4:	29 f9                	sub    %edi,%ecx
  8023b6:	19 c6                	sbb    %eax,%esi
  8023b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023c0:	e9 ff fe ff ff       	jmp    8022c4 <__umoddi3+0x74>
