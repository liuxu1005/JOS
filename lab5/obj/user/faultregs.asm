
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 24 80 00       	push   $0x802424
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 28 24 80 00       	push   $0x802428
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 24 80 00       	push   $0x802432
  8000a6:	68 14 24 80 00       	push   $0x802414
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 24 80 00       	push   $0x802424
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 24 80 00       	push   $0x802428
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 24 80 00       	push   $0x802436
  8000ed:	68 14 24 80 00       	push   $0x802414
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 24 80 00       	push   $0x802424
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 24 80 00       	push   $0x802428
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 24 80 00       	push   $0x80243a
  800134:	68 14 24 80 00       	push   $0x802414
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 24 80 00       	push   $0x802424
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 24 80 00       	push   $0x802428
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 24 80 00       	push   $0x80243e
  80017b:	68 14 24 80 00       	push   $0x802414
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 24 80 00       	push   $0x802424
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 24 80 00       	push   $0x802428
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 24 80 00       	push   $0x802442
  8001c2:	68 14 24 80 00       	push   $0x802414
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 24 80 00       	push   $0x802424
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 24 80 00       	push   $0x802428
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 24 80 00       	push   $0x802446
  800209:	68 14 24 80 00       	push   $0x802414
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 24 80 00       	push   $0x802424
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 24 80 00       	push   $0x802428
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 24 80 00       	push   $0x80244a
  800250:	68 14 24 80 00       	push   $0x802414
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 24 80 00       	push   $0x802424
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 24 80 00       	push   $0x802428
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 24 80 00       	push   $0x80244e
  800297:	68 14 24 80 00       	push   $0x802414
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 24 80 00       	push   $0x802424
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 24 80 00       	push   $0x802455
  8002c4:	68 14 24 80 00       	push   $0x802414
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	75 57                	jne    800330 <check_regs+0x2fd>
  8002d9:	eb 2f                	jmp    80030a <check_regs+0x2d7>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 28 24 80 00       	push   $0x802428
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 24 80 00       	push   $0x802455
  8002f3:	68 14 24 80 00       	push   $0x802414
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 24 80 00       	push   $0x802424
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 24 80 00       	push   $0x802459
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 28 24 80 00       	push   $0x802428
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 24 80 00       	push   $0x802459
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 24 80 00       	push   $0x802424
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 24 80 00       	push   $0x802428
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 24 24 80 00       	push   $0x802424
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 24 80 00       	push   $0x802459
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 c0 24 80 00       	push   $0x8024c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 24 80 00       	push   $0x802467
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 7f 24 80 00       	push   $0x80247f
  800435:	68 8d 24 80 00       	push   $0x80248d
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba 78 24 80 00       	mov    $0x802478,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 fb 0b 00 00       	call   80105a <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 94 24 80 00       	push   $0x802494
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 67 24 80 00       	push   $0x802467
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 c1 0d 00 00       	call   80124b <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 f4 24 80 00       	push   $0x8024f4
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 a7 24 80 00       	push   $0x8024a7
  800573:	68 b8 24 80 00       	push   $0x8024b8
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba 78 24 80 00       	mov    $0x802478,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
  80058c:	83 c4 10             	add    $0x10,%esp
}
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80059c:	e8 7b 0a 00 00       	call   80101c <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
  8005cd:	83 c4 10             	add    $0x10,%esp
}
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 c9 0e 00 00       	call   8014ab <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 ef 09 00 00       	call   800fdb <sys_env_destroy>
  8005ec:	83 c4 10             	add    $0x10,%esp
}
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 18 0a 00 00       	call   80101c <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 20 25 80 00       	push   $0x802520
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 37 09 00 00       	call   800f9e <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 4f 01 00 00       	call   8007fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 dc 08 00 00       	call   800f9e <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 d1                	mov    %edx,%ecx
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800702:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800709:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80070c:	72 05                	jb     800713 <printnum+0x35>
  80070e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800711:	77 3e                	ja     800751 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	ff 75 18             	pushl  0x18(%ebp)
  800719:	83 eb 01             	sub    $0x1,%ebx
  80071c:	53                   	push   %ebx
  80071d:	50                   	push   %eax
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 ee 19 00 00       	call   802120 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 13                	jmp    800758 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f ed                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	ff 75 dc             	pushl  -0x24(%ebp)
  800768:	ff 75 d8             	pushl  -0x28(%ebp)
  80076b:	e8 e0 1a 00 00       	call   802250 <__umoddi3>
  800770:	83 c4 14             	add    $0x14,%esp
  800773:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  80077a:	50                   	push   %eax
  80077b:	ff d7                	call   *%edi
  80077d:	83 c4 10             	add    $0x10,%esp
}
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078b:	83 fa 01             	cmp    $0x1,%edx
  80078e:	7e 0e                	jle    80079e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8d 4a 08             	lea    0x8(%edx),%ecx
  800795:	89 08                	mov    %ecx,(%eax)
  800797:	8b 02                	mov    (%edx),%eax
  800799:	8b 52 04             	mov    0x4(%edx),%edx
  80079c:	eb 22                	jmp    8007c0 <getuint+0x38>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 10                	je     8007b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	eb 0e                	jmp    8007c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b7:	89 08                	mov    %ecx,(%eax)
  8007b9:	8b 02                	mov    (%edx),%eax
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d1:	73 0a                	jae    8007dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d6:	89 08                	mov    %ecx,(%eax)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	88 02                	mov    %al,(%edx)
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 10             	pushl  0x10(%ebp)
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	ff 75 08             	pushl  0x8(%ebp)
  8007f2:	e8 05 00 00 00       	call   8007fc <vprintfmt>
	va_end(ap);
  8007f7:	83 c4 10             	add    $0x10,%esp
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	83 ec 2c             	sub    $0x2c,%esp
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80080e:	eb 12                	jmp    800822 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 90 03 00 00    	je     800ba8 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800822:	83 c7 01             	add    $0x1,%edi
  800825:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e2                	jne    800810 <vprintfmt+0x14>
  80082e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 07                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800851:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8d 47 01             	lea    0x1(%edi),%eax
  800858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085b:	0f b6 07             	movzbl (%edi),%eax
  80085e:	0f b6 c8             	movzbl %al,%ecx
  800861:	83 e8 23             	sub    $0x23,%eax
  800864:	3c 55                	cmp    $0x55,%al
  800866:	0f 87 21 03 00 00    	ja     800b8d <vprintfmt+0x391>
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800879:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087d:	eb d6                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800891:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800894:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800897:	83 fa 09             	cmp    $0x9,%edx
  80089a:	77 39                	ja     8008d5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80089f:	eb e9                	jmp    80088a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8008a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b2:	eb 27                	jmp    8008db <vprintfmt+0xdf>
  8008b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008be:	0f 49 c8             	cmovns %eax,%ecx
  8008c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c7:	eb 8c                	jmp    800855 <vprintfmt+0x59>
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d3:	eb 80                	jmp    800855 <vprintfmt+0x59>
  8008d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008df:	0f 89 70 ff ff ff    	jns    800855 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f2:	e9 5e ff ff ff       	jmp    800855 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fd:	e9 53 ff ff ff       	jmp    800855 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	ff 30                	pushl  (%eax)
  800911:	ff d6                	call   *%esi
			break;
  800913:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800919:	e9 04 ff ff ff       	jmp    800822 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	8d 50 04             	lea    0x4(%eax),%edx
  800924:	89 55 14             	mov    %edx,0x14(%ebp)
  800927:	8b 00                	mov    (%eax),%eax
  800929:	99                   	cltd   
  80092a:	31 d0                	xor    %edx,%eax
  80092c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092e:	83 f8 0f             	cmp    $0xf,%eax
  800931:	7f 0b                	jg     80093e <vprintfmt+0x142>
  800933:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 18                	jne    800956 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80093e:	50                   	push   %eax
  80093f:	68 5b 25 80 00       	push   $0x80255b
  800944:	53                   	push   %ebx
  800945:	56                   	push   %esi
  800946:	e8 94 fe ff ff       	call   8007df <printfmt>
  80094b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800951:	e9 cc fe ff ff       	jmp    800822 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800956:	52                   	push   %edx
  800957:	68 a5 29 80 00       	push   $0x8029a5
  80095c:	53                   	push   %ebx
  80095d:	56                   	push   %esi
  80095e:	e8 7c fe ff ff       	call   8007df <printfmt>
  800963:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800969:	e9 b4 fe ff ff       	jmp    800822 <vprintfmt+0x26>
  80096e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800971:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800974:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 50 04             	lea    0x4(%eax),%edx
  80097d:	89 55 14             	mov    %edx,0x14(%ebp)
  800980:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800982:	85 ff                	test   %edi,%edi
  800984:	ba 54 25 80 00       	mov    $0x802554,%edx
  800989:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80098c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800990:	0f 84 92 00 00 00    	je     800a28 <vprintfmt+0x22c>
  800996:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80099a:	0f 8e 96 00 00 00    	jle    800a36 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	51                   	push   %ecx
  8009a4:	57                   	push   %edi
  8009a5:	e8 86 02 00 00       	call   800c30 <strnlen>
  8009aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009ad:	29 c1                	sub    %eax,%ecx
  8009af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c1:	eb 0f                	jmp    8009d2 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	53                   	push   %ebx
  8009c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cc:	83 ef 01             	sub    $0x1,%edi
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	85 ff                	test   %edi,%edi
  8009d4:	7f ed                	jg     8009c3 <vprintfmt+0x1c7>
  8009d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	0f 49 c1             	cmovns %ecx,%eax
  8009e6:	29 c1                	sub    %eax,%ecx
  8009e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8009eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f1:	89 cb                	mov    %ecx,%ebx
  8009f3:	eb 4d                	jmp    800a42 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f9:	74 1b                	je     800a16 <vprintfmt+0x21a>
  8009fb:	0f be c0             	movsbl %al,%eax
  8009fe:	83 e8 20             	sub    $0x20,%eax
  800a01:	83 f8 5e             	cmp    $0x5e,%eax
  800a04:	76 10                	jbe    800a16 <vprintfmt+0x21a>
					putch('?', putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	6a 3f                	push   $0x3f
  800a0e:	ff 55 08             	call   *0x8(%ebp)
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	eb 0d                	jmp    800a23 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	52                   	push   %edx
  800a1d:	ff 55 08             	call   *0x8(%ebp)
  800a20:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a23:	83 eb 01             	sub    $0x1,%ebx
  800a26:	eb 1a                	jmp    800a42 <vprintfmt+0x246>
  800a28:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a31:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a34:	eb 0c                	jmp    800a42 <vprintfmt+0x246>
  800a36:	89 75 08             	mov    %esi,0x8(%ebp)
  800a39:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a42:	83 c7 01             	add    $0x1,%edi
  800a45:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a49:	0f be d0             	movsbl %al,%edx
  800a4c:	85 d2                	test   %edx,%edx
  800a4e:	74 23                	je     800a73 <vprintfmt+0x277>
  800a50:	85 f6                	test   %esi,%esi
  800a52:	78 a1                	js     8009f5 <vprintfmt+0x1f9>
  800a54:	83 ee 01             	sub    $0x1,%esi
  800a57:	79 9c                	jns    8009f5 <vprintfmt+0x1f9>
  800a59:	89 df                	mov    %ebx,%edi
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a61:	eb 18                	jmp    800a7b <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 20                	push   $0x20
  800a69:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	eb 08                	jmp    800a7b <vprintfmt+0x27f>
  800a73:	89 df                	mov    %ebx,%edi
  800a75:	8b 75 08             	mov    0x8(%ebp),%esi
  800a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	7f e4                	jg     800a63 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a82:	e9 9b fd ff ff       	jmp    800822 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a87:	83 fa 01             	cmp    $0x1,%edx
  800a8a:	7e 16                	jle    800aa2 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 50 04             	mov    0x4(%eax),%edx
  800a98:	8b 00                	mov    (%eax),%eax
  800a9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa0:	eb 32                	jmp    800ad4 <vprintfmt+0x2d8>
	else if (lflag)
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	74 18                	je     800abe <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa9:	8d 50 04             	lea    0x4(%eax),%edx
  800aac:	89 55 14             	mov    %edx,0x14(%ebp)
  800aaf:	8b 00                	mov    (%eax),%eax
  800ab1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800abc:	eb 16                	jmp    800ad4 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 00                	mov    (%eax),%eax
  800ac9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800acc:	89 c1                	mov    %eax,%ecx
  800ace:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ada:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800adf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae3:	79 74                	jns    800b59 <vprintfmt+0x35d>
				putch('-', putdat);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	53                   	push   %ebx
  800ae9:	6a 2d                	push   $0x2d
  800aeb:	ff d6                	call   *%esi
				num = -(long long) num;
  800aed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af3:	f7 d8                	neg    %eax
  800af5:	83 d2 00             	adc    $0x0,%edx
  800af8:	f7 da                	neg    %edx
  800afa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b02:	eb 55                	jmp    800b59 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b04:	8d 45 14             	lea    0x14(%ebp),%eax
  800b07:	e8 7c fc ff ff       	call   800788 <getuint>
			base = 10;
  800b0c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b11:	eb 46                	jmp    800b59 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b13:	8d 45 14             	lea    0x14(%ebp),%eax
  800b16:	e8 6d fc ff ff       	call   800788 <getuint>
                        base = 8;
  800b1b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800b20:	eb 37                	jmp    800b59 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800b22:	83 ec 08             	sub    $0x8,%esp
  800b25:	53                   	push   %ebx
  800b26:	6a 30                	push   $0x30
  800b28:	ff d6                	call   *%esi
			putch('x', putdat);
  800b2a:	83 c4 08             	add    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	6a 78                	push   $0x78
  800b30:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	8d 50 04             	lea    0x4(%eax),%edx
  800b38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3b:	8b 00                	mov    (%eax),%eax
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b42:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b45:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b4a:	eb 0d                	jmp    800b59 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4f:	e8 34 fc ff ff       	call   800788 <getuint>
			base = 16;
  800b54:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b60:	57                   	push   %edi
  800b61:	ff 75 e0             	pushl  -0x20(%ebp)
  800b64:	51                   	push   %ecx
  800b65:	52                   	push   %edx
  800b66:	50                   	push   %eax
  800b67:	89 da                	mov    %ebx,%edx
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	e8 6e fb ff ff       	call   8006de <printnum>
			break;
  800b70:	83 c4 20             	add    $0x20,%esp
  800b73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b76:	e9 a7 fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	53                   	push   %ebx
  800b7f:	51                   	push   %ecx
  800b80:	ff d6                	call   *%esi
			break;
  800b82:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b88:	e9 95 fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	53                   	push   %ebx
  800b91:	6a 25                	push   $0x25
  800b93:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	eb 03                	jmp    800b9d <vprintfmt+0x3a1>
  800b9a:	83 ef 01             	sub    $0x1,%edi
  800b9d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ba1:	75 f7                	jne    800b9a <vprintfmt+0x39e>
  800ba3:	e9 7a fc ff ff       	jmp    800822 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 18             	sub    $0x18,%esp
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	74 26                	je     800bf7 <vsnprintf+0x47>
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	7e 22                	jle    800bf7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd5:	ff 75 14             	pushl  0x14(%ebp)
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bde:	50                   	push   %eax
  800bdf:	68 c2 07 80 00       	push   $0x8007c2
  800be4:	e8 13 fc ff ff       	call   8007fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	eb 05                	jmp    800bfc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c07:	50                   	push   %eax
  800c08:	ff 75 10             	pushl  0x10(%ebp)
  800c0b:	ff 75 0c             	pushl  0xc(%ebp)
  800c0e:	ff 75 08             	pushl  0x8(%ebp)
  800c11:	e8 9a ff ff ff       	call   800bb0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	eb 03                	jmp    800c28 <strlen+0x10>
		n++;
  800c25:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c28:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2c:	75 f7                	jne    800c25 <strlen+0xd>
		n++;
	return n;
}
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	eb 03                	jmp    800c43 <strnlen+0x13>
		n++;
  800c40:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c43:	39 c2                	cmp    %eax,%edx
  800c45:	74 08                	je     800c4f <strnlen+0x1f>
  800c47:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c4b:	75 f3                	jne    800c40 <strnlen+0x10>
  800c4d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	53                   	push   %ebx
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	83 c2 01             	add    $0x1,%edx
  800c60:	83 c1 01             	add    $0x1,%ecx
  800c63:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c67:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c6a:	84 db                	test   %bl,%bl
  800c6c:	75 ef                	jne    800c5d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	53                   	push   %ebx
  800c75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c78:	53                   	push   %ebx
  800c79:	e8 9a ff ff ff       	call   800c18 <strlen>
  800c7e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	01 d8                	add    %ebx,%eax
  800c86:	50                   	push   %eax
  800c87:	e8 c5 ff ff ff       	call   800c51 <strcpy>
	return dst;
}
  800c8c:	89 d8                	mov    %ebx,%eax
  800c8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	89 f3                	mov    %esi,%ebx
  800ca0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca3:	89 f2                	mov    %esi,%edx
  800ca5:	eb 0f                	jmp    800cb6 <strncpy+0x23>
		*dst++ = *src;
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	0f b6 01             	movzbl (%ecx),%eax
  800cad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb0:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb6:	39 da                	cmp    %ebx,%edx
  800cb8:	75 ed                	jne    800ca7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cba:	89 f0                	mov    %esi,%eax
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 10             	mov    0x10(%ebp),%edx
  800cce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd0:	85 d2                	test   %edx,%edx
  800cd2:	74 21                	je     800cf5 <strlcpy+0x35>
  800cd4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd8:	89 f2                	mov    %esi,%edx
  800cda:	eb 09                	jmp    800ce5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cdc:	83 c2 01             	add    $0x1,%edx
  800cdf:	83 c1 01             	add    $0x1,%ecx
  800ce2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce5:	39 c2                	cmp    %eax,%edx
  800ce7:	74 09                	je     800cf2 <strlcpy+0x32>
  800ce9:	0f b6 19             	movzbl (%ecx),%ebx
  800cec:	84 db                	test   %bl,%bl
  800cee:	75 ec                	jne    800cdc <strlcpy+0x1c>
  800cf0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf5:	29 f0                	sub    %esi,%eax
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d04:	eb 06                	jmp    800d0c <strcmp+0x11>
		p++, q++;
  800d06:	83 c1 01             	add    $0x1,%ecx
  800d09:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0c:	0f b6 01             	movzbl (%ecx),%eax
  800d0f:	84 c0                	test   %al,%al
  800d11:	74 04                	je     800d17 <strcmp+0x1c>
  800d13:	3a 02                	cmp    (%edx),%al
  800d15:	74 ef                	je     800d06 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d17:	0f b6 c0             	movzbl %al,%eax
  800d1a:	0f b6 12             	movzbl (%edx),%edx
  800d1d:	29 d0                	sub    %edx,%eax
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2b:	89 c3                	mov    %eax,%ebx
  800d2d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d30:	eb 06                	jmp    800d38 <strncmp+0x17>
		n--, p++, q++;
  800d32:	83 c0 01             	add    $0x1,%eax
  800d35:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d38:	39 d8                	cmp    %ebx,%eax
  800d3a:	74 15                	je     800d51 <strncmp+0x30>
  800d3c:	0f b6 08             	movzbl (%eax),%ecx
  800d3f:	84 c9                	test   %cl,%cl
  800d41:	74 04                	je     800d47 <strncmp+0x26>
  800d43:	3a 0a                	cmp    (%edx),%cl
  800d45:	74 eb                	je     800d32 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d47:	0f b6 00             	movzbl (%eax),%eax
  800d4a:	0f b6 12             	movzbl (%edx),%edx
  800d4d:	29 d0                	sub    %edx,%eax
  800d4f:	eb 05                	jmp    800d56 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d63:	eb 07                	jmp    800d6c <strchr+0x13>
		if (*s == c)
  800d65:	38 ca                	cmp    %cl,%dl
  800d67:	74 0f                	je     800d78 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d69:	83 c0 01             	add    $0x1,%eax
  800d6c:	0f b6 10             	movzbl (%eax),%edx
  800d6f:	84 d2                	test   %dl,%dl
  800d71:	75 f2                	jne    800d65 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d84:	eb 03                	jmp    800d89 <strfind+0xf>
  800d86:	83 c0 01             	add    $0x1,%eax
  800d89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d8c:	84 d2                	test   %dl,%dl
  800d8e:	74 04                	je     800d94 <strfind+0x1a>
  800d90:	38 ca                	cmp    %cl,%dl
  800d92:	75 f2                	jne    800d86 <strfind+0xc>
			break;
	return (char *) s;
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da2:	85 c9                	test   %ecx,%ecx
  800da4:	74 36                	je     800ddc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dac:	75 28                	jne    800dd6 <memset+0x40>
  800dae:	f6 c1 03             	test   $0x3,%cl
  800db1:	75 23                	jne    800dd6 <memset+0x40>
		c &= 0xFF;
  800db3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	c1 e3 08             	shl    $0x8,%ebx
  800dbc:	89 d6                	mov    %edx,%esi
  800dbe:	c1 e6 18             	shl    $0x18,%esi
  800dc1:	89 d0                	mov    %edx,%eax
  800dc3:	c1 e0 10             	shl    $0x10,%eax
  800dc6:	09 f0                	or     %esi,%eax
  800dc8:	09 c2                	or     %eax,%edx
  800dca:	89 d0                	mov    %edx,%eax
  800dcc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dce:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dd1:	fc                   	cld    
  800dd2:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd4:	eb 06                	jmp    800ddc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd9:	fc                   	cld    
  800dda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ddc:	89 f8                	mov    %edi,%eax
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df1:	39 c6                	cmp    %eax,%esi
  800df3:	73 35                	jae    800e2a <memmove+0x47>
  800df5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 2e                	jae    800e2a <memmove+0x47>
		s += n;
		d += n;
  800dfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e09:	75 13                	jne    800e1e <memmove+0x3b>
  800e0b:	f6 c1 03             	test   $0x3,%cl
  800e0e:	75 0e                	jne    800e1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e10:	83 ef 04             	sub    $0x4,%edi
  800e13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e16:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e19:	fd                   	std    
  800e1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1c:	eb 09                	jmp    800e27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e1e:	83 ef 01             	sub    $0x1,%edi
  800e21:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e24:	fd                   	std    
  800e25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e27:	fc                   	cld    
  800e28:	eb 1d                	jmp    800e47 <memmove+0x64>
  800e2a:	89 f2                	mov    %esi,%edx
  800e2c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2e:	f6 c2 03             	test   $0x3,%dl
  800e31:	75 0f                	jne    800e42 <memmove+0x5f>
  800e33:	f6 c1 03             	test   $0x3,%cl
  800e36:	75 0a                	jne    800e42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e38:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e3b:	89 c7                	mov    %eax,%edi
  800e3d:	fc                   	cld    
  800e3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e40:	eb 05                	jmp    800e47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e42:	89 c7                	mov    %eax,%edi
  800e44:	fc                   	cld    
  800e45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e4e:	ff 75 10             	pushl  0x10(%ebp)
  800e51:	ff 75 0c             	pushl  0xc(%ebp)
  800e54:	ff 75 08             	pushl  0x8(%ebp)
  800e57:	e8 87 ff ff ff       	call   800de3 <memmove>
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e69:	89 c6                	mov    %eax,%esi
  800e6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6e:	eb 1a                	jmp    800e8a <memcmp+0x2c>
		if (*s1 != *s2)
  800e70:	0f b6 08             	movzbl (%eax),%ecx
  800e73:	0f b6 1a             	movzbl (%edx),%ebx
  800e76:	38 d9                	cmp    %bl,%cl
  800e78:	74 0a                	je     800e84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e7a:	0f b6 c1             	movzbl %cl,%eax
  800e7d:	0f b6 db             	movzbl %bl,%ebx
  800e80:	29 d8                	sub    %ebx,%eax
  800e82:	eb 0f                	jmp    800e93 <memcmp+0x35>
		s1++, s2++;
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8a:	39 f0                	cmp    %esi,%eax
  800e8c:	75 e2                	jne    800e70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ea0:	89 c2                	mov    %eax,%edx
  800ea2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea5:	eb 07                	jmp    800eae <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	38 08                	cmp    %cl,(%eax)
  800ea9:	74 07                	je     800eb2 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eab:	83 c0 01             	add    $0x1,%eax
  800eae:	39 d0                	cmp    %edx,%eax
  800eb0:	72 f5                	jb     800ea7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec0:	eb 03                	jmp    800ec5 <strtol+0x11>
		s++;
  800ec2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec5:	0f b6 01             	movzbl (%ecx),%eax
  800ec8:	3c 09                	cmp    $0x9,%al
  800eca:	74 f6                	je     800ec2 <strtol+0xe>
  800ecc:	3c 20                	cmp    $0x20,%al
  800ece:	74 f2                	je     800ec2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed0:	3c 2b                	cmp    $0x2b,%al
  800ed2:	75 0a                	jne    800ede <strtol+0x2a>
		s++;
  800ed4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed7:	bf 00 00 00 00       	mov    $0x0,%edi
  800edc:	eb 10                	jmp    800eee <strtol+0x3a>
  800ede:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee3:	3c 2d                	cmp    $0x2d,%al
  800ee5:	75 07                	jne    800eee <strtol+0x3a>
		s++, neg = 1;
  800ee7:	8d 49 01             	lea    0x1(%ecx),%ecx
  800eea:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eee:	85 db                	test   %ebx,%ebx
  800ef0:	0f 94 c0             	sete   %al
  800ef3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef9:	75 19                	jne    800f14 <strtol+0x60>
  800efb:	80 39 30             	cmpb   $0x30,(%ecx)
  800efe:	75 14                	jne    800f14 <strtol+0x60>
  800f00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f04:	0f 85 82 00 00 00    	jne    800f8c <strtol+0xd8>
		s += 2, base = 16;
  800f0a:	83 c1 02             	add    $0x2,%ecx
  800f0d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f12:	eb 16                	jmp    800f2a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f14:	84 c0                	test   %al,%al
  800f16:	74 12                	je     800f2a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f18:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800f20:	75 08                	jne    800f2a <strtol+0x76>
		s++, base = 8;
  800f22:	83 c1 01             	add    $0x1,%ecx
  800f25:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f32:	0f b6 11             	movzbl (%ecx),%edx
  800f35:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f38:	89 f3                	mov    %esi,%ebx
  800f3a:	80 fb 09             	cmp    $0x9,%bl
  800f3d:	77 08                	ja     800f47 <strtol+0x93>
			dig = *s - '0';
  800f3f:	0f be d2             	movsbl %dl,%edx
  800f42:	83 ea 30             	sub    $0x30,%edx
  800f45:	eb 22                	jmp    800f69 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800f47:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f4a:	89 f3                	mov    %esi,%ebx
  800f4c:	80 fb 19             	cmp    $0x19,%bl
  800f4f:	77 08                	ja     800f59 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800f51:	0f be d2             	movsbl %dl,%edx
  800f54:	83 ea 57             	sub    $0x57,%edx
  800f57:	eb 10                	jmp    800f69 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800f59:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f5c:	89 f3                	mov    %esi,%ebx
  800f5e:	80 fb 19             	cmp    $0x19,%bl
  800f61:	77 16                	ja     800f79 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f63:	0f be d2             	movsbl %dl,%edx
  800f66:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f69:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6c:	7d 0f                	jge    800f7d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800f6e:	83 c1 01             	add    $0x1,%ecx
  800f71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f75:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f77:	eb b9                	jmp    800f32 <strtol+0x7e>
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	eb 02                	jmp    800f7f <strtol+0xcb>
  800f7d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800f7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f83:	74 0d                	je     800f92 <strtol+0xde>
		*endptr = (char *) s;
  800f85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f88:	89 0e                	mov    %ecx,(%esi)
  800f8a:	eb 06                	jmp    800f92 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f8c:	84 c0                	test   %al,%al
  800f8e:	75 92                	jne    800f22 <strtol+0x6e>
  800f90:	eb 98                	jmp    800f2a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f92:	f7 da                	neg    %edx
  800f94:	85 ff                	test   %edi,%edi
  800f96:	0f 45 c2             	cmovne %edx,%eax
}
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fac:	8b 55 08             	mov    0x8(%ebp),%edx
  800faf:	89 c3                	mov    %eax,%ebx
  800fb1:	89 c7                	mov    %eax,%edi
  800fb3:	89 c6                	mov    %eax,%esi
  800fb5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_cgetc>:

int
sys_cgetc(void)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcc:	89 d1                	mov    %edx,%ecx
  800fce:	89 d3                	mov    %edx,%ebx
  800fd0:	89 d7                	mov    %edx,%edi
  800fd2:	89 d6                	mov    %edx,%esi
  800fd4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe9:	b8 03 00 00 00       	mov    $0x3,%eax
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 cb                	mov    %ecx,%ebx
  800ff3:	89 cf                	mov    %ecx,%edi
  800ff5:	89 ce                	mov    %ecx,%esi
  800ff7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	7e 17                	jle    801014 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	50                   	push   %eax
  801001:	6a 03                	push   $0x3
  801003:	68 5f 28 80 00       	push   $0x80285f
  801008:	6a 23                	push   $0x23
  80100a:	68 7c 28 80 00       	push   $0x80287c
  80100f:	e8 dd f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801022:	ba 00 00 00 00       	mov    $0x0,%edx
  801027:	b8 02 00 00 00       	mov    $0x2,%eax
  80102c:	89 d1                	mov    %edx,%ecx
  80102e:	89 d3                	mov    %edx,%ebx
  801030:	89 d7                	mov    %edx,%edi
  801032:	89 d6                	mov    %edx,%esi
  801034:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sys_yield>:

void
sys_yield(void)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801041:	ba 00 00 00 00       	mov    $0x0,%edx
  801046:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104b:	89 d1                	mov    %edx,%ecx
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 d7                	mov    %edx,%edi
  801051:	89 d6                	mov    %edx,%esi
  801053:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801063:	be 00 00 00 00       	mov    $0x0,%esi
  801068:	b8 04 00 00 00       	mov    $0x4,%eax
  80106d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801076:	89 f7                	mov    %esi,%edi
  801078:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	7e 17                	jle    801095 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	50                   	push   %eax
  801082:	6a 04                	push   $0x4
  801084:	68 5f 28 80 00       	push   $0x80285f
  801089:	6a 23                	push   $0x23
  80108b:	68 7c 28 80 00       	push   $0x80287c
  801090:	e8 5c f5 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 17                	jle    8010d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	50                   	push   %eax
  8010c4:	6a 05                	push   $0x5
  8010c6:	68 5f 28 80 00       	push   $0x80285f
  8010cb:	6a 23                	push   $0x23
  8010cd:	68 7c 28 80 00       	push   $0x80287c
  8010d2:	e8 1a f5 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	89 df                	mov    %ebx,%edi
  8010fa:	89 de                	mov    %ebx,%esi
  8010fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	7e 17                	jle    801119 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	50                   	push   %eax
  801106:	6a 06                	push   $0x6
  801108:	68 5f 28 80 00       	push   $0x80285f
  80110d:	6a 23                	push   $0x23
  80110f:	68 7c 28 80 00       	push   $0x80287c
  801114:	e8 d8 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112f:	b8 08 00 00 00       	mov    $0x8,%eax
  801134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801137:	8b 55 08             	mov    0x8(%ebp),%edx
  80113a:	89 df                	mov    %ebx,%edi
  80113c:	89 de                	mov    %ebx,%esi
  80113e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801140:	85 c0                	test   %eax,%eax
  801142:	7e 17                	jle    80115b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	50                   	push   %eax
  801148:	6a 08                	push   $0x8
  80114a:	68 5f 28 80 00       	push   $0x80285f
  80114f:	6a 23                	push   $0x23
  801151:	68 7c 28 80 00       	push   $0x80287c
  801156:	e8 96 f4 ff ff       	call   8005f1 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801171:	b8 09 00 00 00       	mov    $0x9,%eax
  801176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801179:	8b 55 08             	mov    0x8(%ebp),%edx
  80117c:	89 df                	mov    %ebx,%edi
  80117e:	89 de                	mov    %ebx,%esi
  801180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801182:	85 c0                	test   %eax,%eax
  801184:	7e 17                	jle    80119d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	50                   	push   %eax
  80118a:	6a 09                	push   $0x9
  80118c:	68 5f 28 80 00       	push   $0x80285f
  801191:	6a 23                	push   $0x23
  801193:	68 7c 28 80 00       	push   $0x80287c
  801198:	e8 54 f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011be:	89 df                	mov    %ebx,%edi
  8011c0:	89 de                	mov    %ebx,%esi
  8011c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	7e 17                	jle    8011df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c8:	83 ec 0c             	sub    $0xc,%esp
  8011cb:	50                   	push   %eax
  8011cc:	6a 0a                	push   $0xa
  8011ce:	68 5f 28 80 00       	push   $0x80285f
  8011d3:	6a 23                	push   $0x23
  8011d5:	68 7c 28 80 00       	push   $0x80287c
  8011da:	e8 12 f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	57                   	push   %edi
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ed:	be 00 00 00 00       	mov    $0x0,%esi
  8011f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801200:	8b 7d 14             	mov    0x14(%ebp),%edi
  801203:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	57                   	push   %edi
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801213:	b9 00 00 00 00       	mov    $0x0,%ecx
  801218:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121d:	8b 55 08             	mov    0x8(%ebp),%edx
  801220:	89 cb                	mov    %ecx,%ebx
  801222:	89 cf                	mov    %ecx,%edi
  801224:	89 ce                	mov    %ecx,%esi
  801226:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801228:	85 c0                	test   %eax,%eax
  80122a:	7e 17                	jle    801243 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	50                   	push   %eax
  801230:	6a 0d                	push   $0xd
  801232:	68 5f 28 80 00       	push   $0x80285f
  801237:	6a 23                	push   $0x23
  801239:	68 7c 28 80 00       	push   $0x80287c
  80123e:	e8 ae f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801251:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801258:	75 2c                	jne    801286 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	6a 07                	push   $0x7
  80125f:	68 00 f0 bf ee       	push   $0xeebff000
  801264:	6a 00                	push   $0x0
  801266:	e8 ef fd ff ff       	call   80105a <sys_page_alloc>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	74 14                	je     801286 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	68 8c 28 80 00       	push   $0x80288c
  80127a:	6a 21                	push   $0x21
  80127c:	68 ee 28 80 00       	push   $0x8028ee
  801281:	e8 6b f3 ff ff       	call   8005f1 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	a3 b4 40 80 00       	mov    %eax,0x8040b4
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	68 ba 12 80 00       	push   $0x8012ba
  801296:	6a 00                	push   $0x0
  801298:	e8 08 ff ff ff       	call   8011a5 <sys_env_set_pgfault_upcall>
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 14                	jns    8012b8 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8012a4:	83 ec 04             	sub    $0x4,%esp
  8012a7:	68 b8 28 80 00       	push   $0x8028b8
  8012ac:	6a 29                	push   $0x29
  8012ae:	68 ee 28 80 00       	push   $0x8028ee
  8012b3:	e8 39 f3 ff ff       	call   8005f1 <_panic>
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012ba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012bb:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012c0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012c2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8012c5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8012ca:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8012ce:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8012d2:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8012d4:	83 c4 08             	add    $0x8,%esp
        popal
  8012d7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8012d8:	83 c4 04             	add    $0x4,%esp
        popfl
  8012db:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8012dc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8012dd:	c3                   	ret    

008012de <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f4:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012fe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801310:	89 c2                	mov    %eax,%edx
  801312:	c1 ea 16             	shr    $0x16,%edx
  801315:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131c:	f6 c2 01             	test   $0x1,%dl
  80131f:	74 11                	je     801332 <fd_alloc+0x2d>
  801321:	89 c2                	mov    %eax,%edx
  801323:	c1 ea 0c             	shr    $0xc,%edx
  801326:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132d:	f6 c2 01             	test   $0x1,%dl
  801330:	75 09                	jne    80133b <fd_alloc+0x36>
			*fd_store = fd;
  801332:	89 01                	mov    %eax,(%ecx)
			return 0;
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
  801339:	eb 17                	jmp    801352 <fd_alloc+0x4d>
  80133b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801340:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801345:	75 c9                	jne    801310 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801347:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80134d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80135a:	83 f8 1f             	cmp    $0x1f,%eax
  80135d:	77 36                	ja     801395 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135f:	c1 e0 0c             	shl    $0xc,%eax
  801362:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801367:	89 c2                	mov    %eax,%edx
  801369:	c1 ea 16             	shr    $0x16,%edx
  80136c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801373:	f6 c2 01             	test   $0x1,%dl
  801376:	74 24                	je     80139c <fd_lookup+0x48>
  801378:	89 c2                	mov    %eax,%edx
  80137a:	c1 ea 0c             	shr    $0xc,%edx
  80137d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801384:	f6 c2 01             	test   $0x1,%dl
  801387:	74 1a                	je     8013a3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801389:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138c:	89 02                	mov    %eax,(%edx)
	return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 13                	jmp    8013a8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801395:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139a:	eb 0c                	jmp    8013a8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80139c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a1:	eb 05                	jmp    8013a8 <fd_lookup+0x54>
  8013a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b3:	ba 7c 29 80 00       	mov    $0x80297c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b8:	eb 13                	jmp    8013cd <dev_lookup+0x23>
  8013ba:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013bd:	39 08                	cmp    %ecx,(%eax)
  8013bf:	75 0c                	jne    8013cd <dev_lookup+0x23>
			*dev = devtab[i];
  8013c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cb:	eb 2e                	jmp    8013fb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013cd:	8b 02                	mov    (%edx),%eax
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	75 e7                	jne    8013ba <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d3:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013d8:	8b 40 48             	mov    0x48(%eax),%eax
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	51                   	push   %ecx
  8013df:	50                   	push   %eax
  8013e0:	68 fc 28 80 00       	push   $0x8028fc
  8013e5:	e8 e0 f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  8013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 10             	sub    $0x10,%esp
  801405:	8b 75 08             	mov    0x8(%ebp),%esi
  801408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801415:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801418:	50                   	push   %eax
  801419:	e8 36 ff ff ff       	call   801354 <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 05                	js     80142a <fd_close+0x2d>
	    || fd != fd2)
  801425:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801428:	74 0c                	je     801436 <fd_close+0x39>
		return (must_exist ? r : 0);
  80142a:	84 db                	test   %bl,%bl
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	0f 44 c2             	cmove  %edx,%eax
  801434:	eb 41                	jmp    801477 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	ff 36                	pushl  (%esi)
  80143f:	e8 66 ff ff ff       	call   8013aa <dev_lookup>
  801444:	89 c3                	mov    %eax,%ebx
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 1a                	js     801467 <fd_close+0x6a>
		if (dev->dev_close)
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801453:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801458:	85 c0                	test   %eax,%eax
  80145a:	74 0b                	je     801467 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	56                   	push   %esi
  801460:	ff d0                	call   *%eax
  801462:	89 c3                	mov    %eax,%ebx
  801464:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	56                   	push   %esi
  80146b:	6a 00                	push   $0x0
  80146d:	e8 6d fc ff ff       	call   8010df <sys_page_unmap>
	return r;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	89 d8                	mov    %ebx,%eax
}
  801477:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 c4 fe ff ff       	call   801354 <fd_lookup>
  801490:	89 c2                	mov    %eax,%edx
  801492:	83 c4 08             	add    $0x8,%esp
  801495:	85 d2                	test   %edx,%edx
  801497:	78 10                	js     8014a9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	6a 01                	push   $0x1
  80149e:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a1:	e8 57 ff ff ff       	call   8013fd <fd_close>
  8014a6:	83 c4 10             	add    $0x10,%esp
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <close_all>:

void
close_all(void)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b7:	83 ec 0c             	sub    $0xc,%esp
  8014ba:	53                   	push   %ebx
  8014bb:	e8 be ff ff ff       	call   80147e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c0:	83 c3 01             	add    $0x1,%ebx
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	83 fb 20             	cmp    $0x20,%ebx
  8014c9:	75 ec                	jne    8014b7 <close_all+0xc>
		close(i);
}
  8014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	57                   	push   %edi
  8014d4:	56                   	push   %esi
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 2c             	sub    $0x2c,%esp
  8014d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	ff 75 08             	pushl  0x8(%ebp)
  8014e3:	e8 6c fe ff ff       	call   801354 <fd_lookup>
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	0f 88 c1 00 00 00    	js     8015b6 <dup+0xe6>
		return r;
	close(newfdnum);
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	56                   	push   %esi
  8014f9:	e8 80 ff ff ff       	call   80147e <close>

	newfd = INDEX2FD(newfdnum);
  8014fe:	89 f3                	mov    %esi,%ebx
  801500:	c1 e3 0c             	shl    $0xc,%ebx
  801503:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801509:	83 c4 04             	add    $0x4,%esp
  80150c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150f:	e8 da fd ff ff       	call   8012ee <fd2data>
  801514:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801516:	89 1c 24             	mov    %ebx,(%esp)
  801519:	e8 d0 fd ff ff       	call   8012ee <fd2data>
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801524:	89 f8                	mov    %edi,%eax
  801526:	c1 e8 16             	shr    $0x16,%eax
  801529:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801530:	a8 01                	test   $0x1,%al
  801532:	74 37                	je     80156b <dup+0x9b>
  801534:	89 f8                	mov    %edi,%eax
  801536:	c1 e8 0c             	shr    $0xc,%eax
  801539:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801540:	f6 c2 01             	test   $0x1,%dl
  801543:	74 26                	je     80156b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801545:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	25 07 0e 00 00       	and    $0xe07,%eax
  801554:	50                   	push   %eax
  801555:	ff 75 d4             	pushl  -0x2c(%ebp)
  801558:	6a 00                	push   $0x0
  80155a:	57                   	push   %edi
  80155b:	6a 00                	push   $0x0
  80155d:	e8 3b fb ff ff       	call   80109d <sys_page_map>
  801562:	89 c7                	mov    %eax,%edi
  801564:	83 c4 20             	add    $0x20,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 2e                	js     801599 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80156e:	89 d0                	mov    %edx,%eax
  801570:	c1 e8 0c             	shr    $0xc,%eax
  801573:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	25 07 0e 00 00       	and    $0xe07,%eax
  801582:	50                   	push   %eax
  801583:	53                   	push   %ebx
  801584:	6a 00                	push   $0x0
  801586:	52                   	push   %edx
  801587:	6a 00                	push   $0x0
  801589:	e8 0f fb ff ff       	call   80109d <sys_page_map>
  80158e:	89 c7                	mov    %eax,%edi
  801590:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801593:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801595:	85 ff                	test   %edi,%edi
  801597:	79 1d                	jns    8015b6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 00                	push   $0x0
  80159f:	e8 3b fb ff ff       	call   8010df <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015aa:	6a 00                	push   $0x0
  8015ac:	e8 2e fb ff ff       	call   8010df <sys_page_unmap>
	return r;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	89 f8                	mov    %edi,%eax
}
  8015b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5e                   	pop    %esi
  8015bb:	5f                   	pop    %edi
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	53                   	push   %ebx
  8015cd:	e8 82 fd ff ff       	call   801354 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 6d                	js     801648 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 be fd ff ff       	call   8013aa <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 4c                	js     80163f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015f6:	8b 42 08             	mov    0x8(%edx),%eax
  8015f9:	83 e0 03             	and    $0x3,%eax
  8015fc:	83 f8 01             	cmp    $0x1,%eax
  8015ff:	75 21                	jne    801622 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801601:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801606:	8b 40 48             	mov    0x48(%eax),%eax
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	53                   	push   %ebx
  80160d:	50                   	push   %eax
  80160e:	68 40 29 80 00       	push   $0x802940
  801613:	e8 b2 f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801620:	eb 26                	jmp    801648 <read+0x8a>
	}
	if (!dev->dev_read)
  801622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801625:	8b 40 08             	mov    0x8(%eax),%eax
  801628:	85 c0                	test   %eax,%eax
  80162a:	74 17                	je     801643 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80162c:	83 ec 04             	sub    $0x4,%esp
  80162f:	ff 75 10             	pushl  0x10(%ebp)
  801632:	ff 75 0c             	pushl  0xc(%ebp)
  801635:	52                   	push   %edx
  801636:	ff d0                	call   *%eax
  801638:	89 c2                	mov    %eax,%edx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	eb 09                	jmp    801648 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	eb 05                	jmp    801648 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801643:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801648:	89 d0                	mov    %edx,%eax
  80164a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	57                   	push   %edi
  801653:	56                   	push   %esi
  801654:	53                   	push   %ebx
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	8b 7d 08             	mov    0x8(%ebp),%edi
  80165b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801663:	eb 21                	jmp    801686 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	89 f0                	mov    %esi,%eax
  80166a:	29 d8                	sub    %ebx,%eax
  80166c:	50                   	push   %eax
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	03 45 0c             	add    0xc(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	57                   	push   %edi
  801674:	e8 45 ff ff ff       	call   8015be <read>
		if (m < 0)
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 0c                	js     80168c <readn+0x3d>
			return m;
		if (m == 0)
  801680:	85 c0                	test   %eax,%eax
  801682:	74 06                	je     80168a <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801684:	01 c3                	add    %eax,%ebx
  801686:	39 f3                	cmp    %esi,%ebx
  801688:	72 db                	jb     801665 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80168a:	89 d8                	mov    %ebx,%eax
}
  80168c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 14             	sub    $0x14,%esp
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	53                   	push   %ebx
  8016a3:	e8 ac fc ff ff       	call   801354 <fd_lookup>
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 68                	js     801719 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	ff 30                	pushl  (%eax)
  8016bd:	e8 e8 fc ff ff       	call   8013aa <dev_lookup>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 47                	js     801710 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d0:	75 21                	jne    8016f3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016d7:	8b 40 48             	mov    0x48(%eax),%eax
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	53                   	push   %ebx
  8016de:	50                   	push   %eax
  8016df:	68 5c 29 80 00       	push   $0x80295c
  8016e4:	e8 e1 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f1:	eb 26                	jmp    801719 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f9:	85 d2                	test   %edx,%edx
  8016fb:	74 17                	je     801714 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	ff 75 10             	pushl  0x10(%ebp)
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	50                   	push   %eax
  801707:	ff d2                	call   *%edx
  801709:	89 c2                	mov    %eax,%edx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 09                	jmp    801719 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	89 c2                	mov    %eax,%edx
  801712:	eb 05                	jmp    801719 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801714:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801719:	89 d0                	mov    %edx,%eax
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <seek>:

int
seek(int fdnum, off_t offset)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801726:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	ff 75 08             	pushl  0x8(%ebp)
  80172d:	e8 22 fc ff ff       	call   801354 <fd_lookup>
  801732:	83 c4 08             	add    $0x8,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 0e                	js     801747 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801739:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80173c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801742:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	53                   	push   %ebx
  801758:	e8 f7 fb ff ff       	call   801354 <fd_lookup>
  80175d:	83 c4 08             	add    $0x8,%esp
  801760:	89 c2                	mov    %eax,%edx
  801762:	85 c0                	test   %eax,%eax
  801764:	78 65                	js     8017cb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801770:	ff 30                	pushl  (%eax)
  801772:	e8 33 fc ff ff       	call   8013aa <dev_lookup>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 44                	js     8017c2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801785:	75 21                	jne    8017a8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801787:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80178c:	8b 40 48             	mov    0x48(%eax),%eax
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	53                   	push   %ebx
  801793:	50                   	push   %eax
  801794:	68 1c 29 80 00       	push   $0x80291c
  801799:	e8 2c ef ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a6:	eb 23                	jmp    8017cb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	8b 52 18             	mov    0x18(%edx),%edx
  8017ae:	85 d2                	test   %edx,%edx
  8017b0:	74 14                	je     8017c6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	50                   	push   %eax
  8017b9:	ff d2                	call   *%edx
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	eb 09                	jmp    8017cb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c2:	89 c2                	mov    %eax,%edx
  8017c4:	eb 05                	jmp    8017cb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017cb:	89 d0                	mov    %edx,%eax
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 14             	sub    $0x14,%esp
  8017d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	ff 75 08             	pushl  0x8(%ebp)
  8017e3:	e8 6c fb ff ff       	call   801354 <fd_lookup>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 58                	js     801849 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	ff 30                	pushl  (%eax)
  8017fd:	e8 a8 fb ff ff       	call   8013aa <dev_lookup>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	78 37                	js     801840 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801810:	74 32                	je     801844 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801812:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801815:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181c:	00 00 00 
	stat->st_isdir = 0;
  80181f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801826:	00 00 00 
	stat->st_dev = dev;
  801829:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	53                   	push   %ebx
  801833:	ff 75 f0             	pushl  -0x10(%ebp)
  801836:	ff 50 14             	call   *0x14(%eax)
  801839:	89 c2                	mov    %eax,%edx
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	eb 09                	jmp    801849 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	89 c2                	mov    %eax,%edx
  801842:	eb 05                	jmp    801849 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801844:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801849:	89 d0                	mov    %edx,%eax
  80184b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	6a 00                	push   $0x0
  80185a:	ff 75 08             	pushl  0x8(%ebp)
  80185d:	e8 09 02 00 00       	call   801a6b <open>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 db                	test   %ebx,%ebx
  801869:	78 1b                	js     801886 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	ff 75 0c             	pushl  0xc(%ebp)
  801871:	53                   	push   %ebx
  801872:	e8 5b ff ff ff       	call   8017d2 <fstat>
  801877:	89 c6                	mov    %eax,%esi
	close(fd);
  801879:	89 1c 24             	mov    %ebx,(%esp)
  80187c:	e8 fd fb ff ff       	call   80147e <close>
	return r;
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	89 f0                	mov    %esi,%eax
}
  801886:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801889:	5b                   	pop    %ebx
  80188a:	5e                   	pop    %esi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	89 c6                	mov    %eax,%esi
  801894:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801896:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80189d:	75 12                	jne    8018b1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80189f:	83 ec 0c             	sub    $0xc,%esp
  8018a2:	6a 01                	push   $0x1
  8018a4:	e8 ff 07 00 00       	call   8020a8 <ipc_find_env>
  8018a9:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018ae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b1:	6a 07                	push   $0x7
  8018b3:	68 00 50 80 00       	push   $0x805000
  8018b8:	56                   	push   %esi
  8018b9:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018bf:	e8 90 07 00 00       	call   802054 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018c4:	83 c4 0c             	add    $0xc,%esp
  8018c7:	6a 00                	push   $0x0
  8018c9:	53                   	push   %ebx
  8018ca:	6a 00                	push   $0x0
  8018cc:	e8 1a 07 00 00       	call   801feb <ipc_recv>
}
  8018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8018fb:	e8 8d ff ff ff       	call   80188d <fsipc>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 40 0c             	mov    0xc(%eax),%eax
  80190e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 06 00 00 00       	mov    $0x6,%eax
  80191d:	e8 6b ff ff ff       	call   80188d <fsipc>
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 04             	sub    $0x4,%esp
  80192b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 05 00 00 00       	mov    $0x5,%eax
  801943:	e8 45 ff ff ff       	call   80188d <fsipc>
  801948:	89 c2                	mov    %eax,%edx
  80194a:	85 d2                	test   %edx,%edx
  80194c:	78 2c                	js     80197a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	68 00 50 80 00       	push   $0x805000
  801956:	53                   	push   %ebx
  801957:	e8 f5 f2 ff ff       	call   800c51 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80195c:	a1 80 50 80 00       	mov    0x805080,%eax
  801961:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801967:	a1 84 50 80 00       	mov    0x805084,%eax
  80196c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	8b 40 0c             	mov    0xc(%eax),%eax
  801991:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801999:	eb 3d                	jmp    8019d8 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80199b:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8019a1:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8019a6:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	57                   	push   %edi
  8019ad:	53                   	push   %ebx
  8019ae:	68 08 50 80 00       	push   $0x805008
  8019b3:	e8 2b f4 ff ff       	call   800de3 <memmove>
                fsipcbuf.write.req_n = tmp; 
  8019b8:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019be:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c8:	e8 c0 fe ff ff       	call   80188d <fsipc>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 0d                	js     8019e1 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8019d4:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8019d6:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8019d8:	85 f6                	test   %esi,%esi
  8019da:	75 bf                	jne    80199b <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8019e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019fc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	b8 03 00 00 00       	mov    $0x3,%eax
  801a0c:	e8 7c fe ff ff       	call   80188d <fsipc>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 4b                	js     801a62 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a17:	39 c6                	cmp    %eax,%esi
  801a19:	73 16                	jae    801a31 <devfile_read+0x48>
  801a1b:	68 8c 29 80 00       	push   $0x80298c
  801a20:	68 93 29 80 00       	push   $0x802993
  801a25:	6a 7c                	push   $0x7c
  801a27:	68 a8 29 80 00       	push   $0x8029a8
  801a2c:	e8 c0 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  801a31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a36:	7e 16                	jle    801a4e <devfile_read+0x65>
  801a38:	68 b3 29 80 00       	push   $0x8029b3
  801a3d:	68 93 29 80 00       	push   $0x802993
  801a42:	6a 7d                	push   $0x7d
  801a44:	68 a8 29 80 00       	push   $0x8029a8
  801a49:	e8 a3 eb ff ff       	call   8005f1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	50                   	push   %eax
  801a52:	68 00 50 80 00       	push   $0x805000
  801a57:	ff 75 0c             	pushl  0xc(%ebp)
  801a5a:	e8 84 f3 ff ff       	call   800de3 <memmove>
	return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
}
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 20             	sub    $0x20,%esp
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a75:	53                   	push   %ebx
  801a76:	e8 9d f1 ff ff       	call   800c18 <strlen>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a83:	7f 67                	jg     801aec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	e8 74 f8 ff ff       	call   801305 <fd_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 57                	js     801af1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	68 00 50 80 00       	push   $0x805000
  801aa3:	e8 a9 f1 ff ff       	call   800c51 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab8:	e8 d0 fd ff ff       	call   80188d <fsipc>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	79 14                	jns    801ada <open+0x6f>
		fd_close(fd, 0);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	6a 00                	push   $0x0
  801acb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ace:	e8 2a f9 ff ff       	call   8013fd <fd_close>
		return r;
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	89 da                	mov    %ebx,%edx
  801ad8:	eb 17                	jmp    801af1 <open+0x86>
	}

	return fd2num(fd);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae0:	e8 f9 f7 ff ff       	call   8012de <fd2num>
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	eb 05                	jmp    801af1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801af1:	89 d0                	mov    %edx,%eax
  801af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afe:	ba 00 00 00 00       	mov    $0x0,%edx
  801b03:	b8 08 00 00 00       	mov    $0x8,%eax
  801b08:	e8 80 fd ff ff       	call   80188d <fsipc>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 75 08             	pushl  0x8(%ebp)
  801b1d:	e8 cc f7 ff ff       	call   8012ee <fd2data>
  801b22:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b24:	83 c4 08             	add    $0x8,%esp
  801b27:	68 bf 29 80 00       	push   $0x8029bf
  801b2c:	53                   	push   %ebx
  801b2d:	e8 1f f1 ff ff       	call   800c51 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b32:	8b 56 04             	mov    0x4(%esi),%edx
  801b35:	89 d0                	mov    %edx,%eax
  801b37:	2b 06                	sub    (%esi),%eax
  801b39:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b3f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b46:	00 00 00 
	stat->st_dev = &devpipe;
  801b49:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b50:	30 80 00 
	return 0;
}
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
  801b58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	53                   	push   %ebx
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b69:	53                   	push   %ebx
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 6e f5 ff ff       	call   8010df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b71:	89 1c 24             	mov    %ebx,(%esp)
  801b74:	e8 75 f7 ff ff       	call   8012ee <fd2data>
  801b79:	83 c4 08             	add    $0x8,%esp
  801b7c:	50                   	push   %eax
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 5b f5 ff ff       	call   8010df <sys_page_unmap>
}
  801b84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b87:	c9                   	leave  
  801b88:	c3                   	ret    

00801b89 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	57                   	push   %edi
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 1c             	sub    $0x1c,%esp
  801b92:	89 c6                	mov    %eax,%esi
  801b94:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b97:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b9c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	56                   	push   %esi
  801ba3:	e8 38 05 00 00       	call   8020e0 <pageref>
  801ba8:	89 c7                	mov    %eax,%edi
  801baa:	83 c4 04             	add    $0x4,%esp
  801bad:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb0:	e8 2b 05 00 00       	call   8020e0 <pageref>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	39 c7                	cmp    %eax,%edi
  801bba:	0f 94 c2             	sete   %dl
  801bbd:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801bc0:	8b 0d b0 40 80 00    	mov    0x8040b0,%ecx
  801bc6:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801bc9:	39 fb                	cmp    %edi,%ebx
  801bcb:	74 19                	je     801be6 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801bcd:	84 d2                	test   %dl,%dl
  801bcf:	74 c6                	je     801b97 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd1:	8b 51 58             	mov    0x58(%ecx),%edx
  801bd4:	50                   	push   %eax
  801bd5:	52                   	push   %edx
  801bd6:	53                   	push   %ebx
  801bd7:	68 c6 29 80 00       	push   $0x8029c6
  801bdc:	e8 e9 ea ff ff       	call   8006ca <cprintf>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	eb b1                	jmp    801b97 <_pipeisclosed+0xe>
	}
}
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 28             	sub    $0x28,%esp
  801bf7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bfa:	56                   	push   %esi
  801bfb:	e8 ee f6 ff ff       	call   8012ee <fd2data>
  801c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0a:	eb 4b                	jmp    801c57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	89 f0                	mov    %esi,%eax
  801c10:	e8 74 ff ff ff       	call   801b89 <_pipeisclosed>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 48                	jne    801c61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c19:	e8 1d f4 ff ff       	call   80103b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c21:	8b 0b                	mov    (%ebx),%ecx
  801c23:	8d 51 20             	lea    0x20(%ecx),%edx
  801c26:	39 d0                	cmp    %edx,%eax
  801c28:	73 e2                	jae    801c0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	c1 fa 1f             	sar    $0x1f,%edx
  801c39:	89 d1                	mov    %edx,%ecx
  801c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c41:	83 e2 1f             	and    $0x1f,%edx
  801c44:	29 ca                	sub    %ecx,%edx
  801c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c54:	83 c7 01             	add    $0x1,%edi
  801c57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5a:	75 c2                	jne    801c1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	eb 05                	jmp    801c66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c7a:	57                   	push   %edi
  801c7b:	e8 6e f6 ff ff       	call   8012ee <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8a:	eb 3d                	jmp    801cc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8c:	85 db                	test   %ebx,%ebx
  801c8e:	74 04                	je     801c94 <devpipe_read+0x26>
				return i;
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	eb 44                	jmp    801cd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	e8 ec fe ff ff       	call   801b89 <_pipeisclosed>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	75 32                	jne    801cd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca1:	e8 95 f3 ff ff       	call   80103b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca6:	8b 06                	mov    (%esi),%eax
  801ca8:	3b 46 04             	cmp    0x4(%esi),%eax
  801cab:	74 df                	je     801c8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cad:	99                   	cltd   
  801cae:	c1 ea 1b             	shr    $0x1b,%edx
  801cb1:	01 d0                	add    %edx,%eax
  801cb3:	83 e0 1f             	and    $0x1f,%eax
  801cb6:	29 d0                	sub    %edx,%eax
  801cb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc6:	83 c3 01             	add    $0x1,%ebx
  801cc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccc:	75 d8                	jne    801ca6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cce:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd1:	eb 05                	jmp    801cd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 14 f6 ff ff       	call   801305 <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 2c 01 00 00    	js     801e2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	68 07 04 00 00       	push   $0x407
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 4a f3 ff ff       	call   80105a <sys_page_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	0f 88 0d 01 00 00    	js     801e2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	e8 dc f5 ff ff       	call   801305 <fd_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 e2 00 00 00    	js     801e18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	68 07 04 00 00       	push   $0x407
  801d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 12 f3 ff ff       	call   80105a <sys_page_alloc>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 c3 00 00 00    	js     801e18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	e8 8e f5 ff ff       	call   8012ee <fd2data>
  801d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d62:	83 c4 0c             	add    $0xc,%esp
  801d65:	68 07 04 00 00       	push   $0x407
  801d6a:	50                   	push   %eax
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 e8 f2 ff ff       	call   80105a <sys_page_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 89 00 00 00    	js     801e08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f0             	pushl  -0x10(%ebp)
  801d85:	e8 64 f5 ff ff       	call   8012ee <fd2data>
  801d8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d91:	50                   	push   %eax
  801d92:	6a 00                	push   $0x0
  801d94:	56                   	push   %esi
  801d95:	6a 00                	push   $0x0
  801d97:	e8 01 f3 ff ff       	call   80109d <sys_page_map>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 55                	js     801dfa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	e8 04 f5 ff ff       	call   8012de <fd2num>
  801dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ddf:	83 c4 04             	add    $0x4,%esp
  801de2:	ff 75 f0             	pushl  -0x10(%ebp)
  801de5:	e8 f4 f4 ff ff       	call   8012de <fd2num>
  801dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ded:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	ba 00 00 00 00       	mov    $0x0,%edx
  801df8:	eb 30                	jmp    801e2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	56                   	push   %esi
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 da f2 ff ff       	call   8010df <sys_page_unmap>
  801e05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 ca f2 ff ff       	call   8010df <sys_page_unmap>
  801e15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 ba f2 ff ff       	call   8010df <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 75 08             	pushl  0x8(%ebp)
  801e40:	e8 0f f5 ff ff       	call   801354 <fd_lookup>
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	85 d2                	test   %edx,%edx
  801e4c:	78 18                	js     801e66 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	ff 75 f4             	pushl  -0xc(%ebp)
  801e54:	e8 95 f4 ff ff       	call   8012ee <fd2data>
	return _pipeisclosed(fd, p);
  801e59:	89 c2                	mov    %eax,%edx
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	e8 26 fd ff ff       	call   801b89 <_pipeisclosed>
  801e63:	83 c4 10             	add    $0x10,%esp
}
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e78:	68 de 29 80 00       	push   $0x8029de
  801e7d:	ff 75 0c             	pushl  0xc(%ebp)
  801e80:	e8 cc ed ff ff       	call   800c51 <strcpy>
	return 0;
}
  801e85:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	57                   	push   %edi
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e98:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea3:	eb 2d                	jmp    801ed2 <devcons_write+0x46>
		m = n - tot;
  801ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eaa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ead:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eb2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	03 45 0c             	add    0xc(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	57                   	push   %edi
  801ebe:	e8 20 ef ff ff       	call   800de3 <memmove>
		sys_cputs(buf, m);
  801ec3:	83 c4 08             	add    $0x8,%esp
  801ec6:	53                   	push   %ebx
  801ec7:	57                   	push   %edi
  801ec8:	e8 d1 f0 ff ff       	call   800f9e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecd:	01 de                	add    %ebx,%esi
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	89 f0                	mov    %esi,%eax
  801ed4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed7:	72 cc                	jb     801ea5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5f                   	pop    %edi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    

00801ee1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801eec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ef0:	75 07                	jne    801ef9 <devcons_read+0x18>
  801ef2:	eb 28                	jmp    801f1c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef4:	e8 42 f1 ff ff       	call   80103b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef9:	e8 be f0 ff ff       	call   800fbc <sys_cgetc>
  801efe:	85 c0                	test   %eax,%eax
  801f00:	74 f2                	je     801ef4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 16                	js     801f1c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f06:	83 f8 04             	cmp    $0x4,%eax
  801f09:	74 0c                	je     801f17 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0e:	88 02                	mov    %al,(%edx)
	return 1;
  801f10:	b8 01 00 00 00       	mov    $0x1,%eax
  801f15:	eb 05                	jmp    801f1c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f24:	8b 45 08             	mov    0x8(%ebp),%eax
  801f27:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f2a:	6a 01                	push   $0x1
  801f2c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2f:	50                   	push   %eax
  801f30:	e8 69 f0 ff ff       	call   800f9e <sys_cputs>
  801f35:	83 c4 10             	add    $0x10,%esp
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <getchar>:

int
getchar(void)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f40:	6a 01                	push   $0x1
  801f42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f45:	50                   	push   %eax
  801f46:	6a 00                	push   $0x0
  801f48:	e8 71 f6 ff ff       	call   8015be <read>
	if (r < 0)
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 0f                	js     801f63 <getchar+0x29>
		return r;
	if (r < 1)
  801f54:	85 c0                	test   %eax,%eax
  801f56:	7e 06                	jle    801f5e <getchar+0x24>
		return -E_EOF;
	return c;
  801f58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f5c:	eb 05                	jmp    801f63 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6e:	50                   	push   %eax
  801f6f:	ff 75 08             	pushl  0x8(%ebp)
  801f72:	e8 dd f3 ff ff       	call   801354 <fd_lookup>
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	78 11                	js     801f8f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f87:	39 10                	cmp    %edx,(%eax)
  801f89:	0f 94 c0             	sete   %al
  801f8c:	0f b6 c0             	movzbl %al,%eax
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <opencons>:

int
opencons(void)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9a:	50                   	push   %eax
  801f9b:	e8 65 f3 ff ff       	call   801305 <fd_alloc>
  801fa0:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 3e                	js     801fe7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa9:	83 ec 04             	sub    $0x4,%esp
  801fac:	68 07 04 00 00       	push   $0x407
  801fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 9f f0 ff ff       	call   80105a <sys_page_alloc>
  801fbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	78 23                	js     801fe7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	50                   	push   %eax
  801fdd:	e8 fc f2 ff ff       	call   8012de <fd2num>
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	83 c4 10             	add    $0x10,%esp
}
  801fe7:	89 d0                	mov    %edx,%eax
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802000:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802003:	83 ec 0c             	sub    $0xc,%esp
  802006:	50                   	push   %eax
  802007:	e8 fe f1 ff ff       	call   80120a <sys_ipc_recv>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	79 16                	jns    802029 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802013:	85 f6                	test   %esi,%esi
  802015:	74 06                	je     80201d <ipc_recv+0x32>
  802017:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80201d:	85 db                	test   %ebx,%ebx
  80201f:	74 2c                	je     80204d <ipc_recv+0x62>
  802021:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802027:	eb 24                	jmp    80204d <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802029:	85 f6                	test   %esi,%esi
  80202b:	74 0a                	je     802037 <ipc_recv+0x4c>
  80202d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802032:	8b 40 74             	mov    0x74(%eax),%eax
  802035:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802037:	85 db                	test   %ebx,%ebx
  802039:	74 0a                	je     802045 <ipc_recv+0x5a>
  80203b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802040:	8b 40 78             	mov    0x78(%eax),%eax
  802043:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802045:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80204a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80204d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    

00802054 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	57                   	push   %edi
  802058:	56                   	push   %esi
  802059:	53                   	push   %ebx
  80205a:	83 ec 0c             	sub    $0xc,%esp
  80205d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802060:	8b 75 0c             	mov    0xc(%ebp),%esi
  802063:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802066:	85 db                	test   %ebx,%ebx
  802068:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80206d:	0f 44 d8             	cmove  %eax,%ebx
  802070:	eb 1c                	jmp    80208e <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802072:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802075:	74 12                	je     802089 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802077:	50                   	push   %eax
  802078:	68 ea 29 80 00       	push   $0x8029ea
  80207d:	6a 39                	push   $0x39
  80207f:	68 05 2a 80 00       	push   $0x802a05
  802084:	e8 68 e5 ff ff       	call   8005f1 <_panic>
                 sys_yield();
  802089:	e8 ad ef ff ff       	call   80103b <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80208e:	ff 75 14             	pushl  0x14(%ebp)
  802091:	53                   	push   %ebx
  802092:	56                   	push   %esi
  802093:	57                   	push   %edi
  802094:	e8 4e f1 ff ff       	call   8011e7 <sys_ipc_try_send>
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 d2                	js     802072 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8020a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020b6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020bc:	8b 52 50             	mov    0x50(%edx),%edx
  8020bf:	39 ca                	cmp    %ecx,%edx
  8020c1:	75 0d                	jne    8020d0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020c3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c6:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020cb:	8b 40 08             	mov    0x8(%eax),%eax
  8020ce:	eb 0e                	jmp    8020de <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d0:	83 c0 01             	add    $0x1,%eax
  8020d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d8:	75 d9                	jne    8020b3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020da:	66 b8 00 00          	mov    $0x0,%ax
}
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	c1 e8 16             	shr    $0x16,%eax
  8020eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f7:	f6 c1 01             	test   $0x1,%cl
  8020fa:	74 1d                	je     802119 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020fc:	c1 ea 0c             	shr    $0xc,%edx
  8020ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802106:	f6 c2 01             	test   $0x1,%dl
  802109:	74 0e                	je     802119 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210b:	c1 ea 0c             	shr    $0xc,%edx
  80210e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802115:	ef 
  802116:	0f b7 c0             	movzwl %ax,%eax
}
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    
  80211b:	66 90                	xchg   %ax,%ax
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

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
