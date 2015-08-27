
obj/user/faultregs:     file format elf32-i386


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
  800044:	68 91 15 80 00       	push   $0x801591
  800049:	68 60 15 80 00       	push   $0x801560
  80004e:	e8 6f 06 00 00       	call   8006c2 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 70 15 80 00       	push   $0x801570
  80005c:	68 74 15 80 00       	push   $0x801574
  800061:	e8 5c 06 00 00       	call   8006c2 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 84 15 80 00       	push   $0x801584
  800077:	e8 46 06 00 00       	call   8006c2 <cprintf>
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
  800089:	68 88 15 80 00       	push   $0x801588
  80008e:	e8 2f 06 00 00       	call   8006c2 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 92 15 80 00       	push   $0x801592
  8000a6:	68 74 15 80 00       	push   $0x801574
  8000ab:	e8 12 06 00 00       	call   8006c2 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 84 15 80 00       	push   $0x801584
  8000c3:	e8 fa 05 00 00       	call   8006c2 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 88 15 80 00       	push   $0x801588
  8000d5:	e8 e8 05 00 00       	call   8006c2 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 96 15 80 00       	push   $0x801596
  8000ed:	68 74 15 80 00       	push   $0x801574
  8000f2:	e8 cb 05 00 00       	call   8006c2 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 84 15 80 00       	push   $0x801584
  80010a:	e8 b3 05 00 00       	call   8006c2 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 88 15 80 00       	push   $0x801588
  80011c:	e8 a1 05 00 00       	call   8006c2 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 9a 15 80 00       	push   $0x80159a
  800134:	68 74 15 80 00       	push   $0x801574
  800139:	e8 84 05 00 00       	call   8006c2 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 84 15 80 00       	push   $0x801584
  800151:	e8 6c 05 00 00       	call   8006c2 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 88 15 80 00       	push   $0x801588
  800163:	e8 5a 05 00 00       	call   8006c2 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 9e 15 80 00       	push   $0x80159e
  80017b:	68 74 15 80 00       	push   $0x801574
  800180:	e8 3d 05 00 00       	call   8006c2 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 84 15 80 00       	push   $0x801584
  800198:	e8 25 05 00 00       	call   8006c2 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 88 15 80 00       	push   $0x801588
  8001aa:	e8 13 05 00 00       	call   8006c2 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 a2 15 80 00       	push   $0x8015a2
  8001c2:	68 74 15 80 00       	push   $0x801574
  8001c7:	e8 f6 04 00 00       	call   8006c2 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 84 15 80 00       	push   $0x801584
  8001df:	e8 de 04 00 00       	call   8006c2 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 88 15 80 00       	push   $0x801588
  8001f1:	e8 cc 04 00 00       	call   8006c2 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 a6 15 80 00       	push   $0x8015a6
  800209:	68 74 15 80 00       	push   $0x801574
  80020e:	e8 af 04 00 00       	call   8006c2 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 84 15 80 00       	push   $0x801584
  800226:	e8 97 04 00 00       	call   8006c2 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 88 15 80 00       	push   $0x801588
  800238:	e8 85 04 00 00       	call   8006c2 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 aa 15 80 00       	push   $0x8015aa
  800250:	68 74 15 80 00       	push   $0x801574
  800255:	e8 68 04 00 00       	call   8006c2 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 84 15 80 00       	push   $0x801584
  80026d:	e8 50 04 00 00       	call   8006c2 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 88 15 80 00       	push   $0x801588
  80027f:	e8 3e 04 00 00       	call   8006c2 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ae 15 80 00       	push   $0x8015ae
  800297:	68 74 15 80 00       	push   $0x801574
  80029c:	e8 21 04 00 00       	call   8006c2 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 84 15 80 00       	push   $0x801584
  8002b4:	e8 09 04 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 b5 15 80 00       	push   $0x8015b5
  8002c4:	68 74 15 80 00       	push   $0x801574
  8002c9:	e8 f4 03 00 00       	call   8006c2 <cprintf>
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
  8002de:	68 88 15 80 00       	push   $0x801588
  8002e3:	e8 da 03 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 b5 15 80 00       	push   $0x8015b5
  8002f3:	68 74 15 80 00       	push   $0x801574
  8002f8:	e8 c5 03 00 00       	call   8006c2 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 84 15 80 00       	push   $0x801584
  800312:	e8 ab 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 b9 15 80 00       	push   $0x8015b9
  800322:	e8 9b 03 00 00       	call   8006c2 <cprintf>
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
  800333:	68 88 15 80 00       	push   $0x801588
  800338:	e8 85 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 b9 15 80 00       	push   $0x8015b9
  800348:	e8 75 03 00 00       	call   8006c2 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 84 15 80 00       	push   $0x801584
  80035a:	e8 63 03 00 00       	call   8006c2 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 88 15 80 00       	push   $0x801588
  80036c:	e8 51 03 00 00       	call   8006c2 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 84 15 80 00       	push   $0x801584
  80037e:	e8 3f 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 b9 15 80 00       	push   $0x8015b9
  80038e:	e8 2f 03 00 00       	call   8006c2 <cprintf>
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
  8003ba:	68 20 16 80 00       	push   $0x801620
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 c7 15 80 00       	push   $0x8015c7
  8003c6:	e8 1e 02 00 00       	call   8005e9 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 df 15 80 00       	push   $0x8015df
  800435:	68 ed 15 80 00       	push   $0x8015ed
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba d8 15 80 00       	mov    $0x8015d8,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 f3 0b 00 00       	call   801052 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 f4 15 80 00       	push   $0x8015f4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 c7 15 80 00       	push   $0x8015c7
  800473:	e8 71 01 00 00       	call   8005e9 <_panic>
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
  800485:	e8 77 0d 00 00       	call   801201 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
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
  800554:	68 54 16 80 00       	push   $0x801654
  800559:	e8 64 01 00 00       	call   8006c2 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 07 16 80 00       	push   $0x801607
  800573:	68 18 16 80 00       	push   $0x801618
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba d8 15 80 00       	mov    $0x8015d8,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
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
  80059c:	e8 73 0a 00 00       	call   801014 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8005da:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005dd:	6a 00                	push   $0x0
  8005df:	e8 ef 09 00 00       	call   800fd3 <sys_env_destroy>
  8005e4:	83 c4 10             	add    $0x10,%esp
}
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005f7:	e8 18 0a 00 00       	call   801014 <sys_getenvid>
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	56                   	push   %esi
  800606:	50                   	push   %eax
  800607:	68 80 16 80 00       	push   $0x801680
  80060c:	e8 b1 00 00 00       	call   8006c2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800611:	83 c4 18             	add    $0x18,%esp
  800614:	53                   	push   %ebx
  800615:	ff 75 10             	pushl  0x10(%ebp)
  800618:	e8 54 00 00 00       	call   800671 <vcprintf>
	cprintf("\n");
  80061d:	c7 04 24 90 15 80 00 	movl   $0x801590,(%esp)
  800624:	e8 99 00 00 00       	call   8006c2 <cprintf>
  800629:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062c:	cc                   	int3   
  80062d:	eb fd                	jmp    80062c <_panic+0x43>

0080062f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 04             	sub    $0x4,%esp
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800639:	8b 13                	mov    (%ebx),%edx
  80063b:	8d 42 01             	lea    0x1(%edx),%eax
  80063e:	89 03                	mov    %eax,(%ebx)
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800647:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064c:	75 1a                	jne    800668 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	68 ff 00 00 00       	push   $0xff
  800656:	8d 43 08             	lea    0x8(%ebx),%eax
  800659:	50                   	push   %eax
  80065a:	e8 37 09 00 00       	call   800f96 <sys_cputs>
		b->idx = 0;
  80065f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800665:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800668:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80066c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80067a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800681:	00 00 00 
	b.cnt = 0;
  800684:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	ff 75 08             	pushl  0x8(%ebp)
  800694:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	68 2f 06 80 00       	push   $0x80062f
  8006a0:	e8 4f 01 00 00       	call   8007f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	e8 dc 08 00 00       	call   800f96 <sys_cputs>

	return b.cnt;
}
  8006ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006cb:	50                   	push   %eax
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 9d ff ff ff       	call   800671 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	57                   	push   %edi
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 1c             	sub    $0x1c,%esp
  8006df:	89 c7                	mov    %eax,%edi
  8006e1:	89 d6                	mov    %edx,%esi
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e9:	89 d1                	mov    %edx,%ecx
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800701:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800704:	72 05                	jb     80070b <printnum+0x35>
  800706:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800709:	77 3e                	ja     800749 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070b:	83 ec 0c             	sub    $0xc,%esp
  80070e:	ff 75 18             	pushl  0x18(%ebp)
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	53                   	push   %ebx
  800715:	50                   	push   %eax
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff 75 dc             	pushl  -0x24(%ebp)
  800722:	ff 75 d8             	pushl  -0x28(%ebp)
  800725:	e8 76 0b 00 00       	call   8012a0 <__udivdi3>
  80072a:	83 c4 18             	add    $0x18,%esp
  80072d:	52                   	push   %edx
  80072e:	50                   	push   %eax
  80072f:	89 f2                	mov    %esi,%edx
  800731:	89 f8                	mov    %edi,%eax
  800733:	e8 9e ff ff ff       	call   8006d6 <printnum>
  800738:	83 c4 20             	add    $0x20,%esp
  80073b:	eb 13                	jmp    800750 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	56                   	push   %esi
  800741:	ff 75 18             	pushl  0x18(%ebp)
  800744:	ff d7                	call   *%edi
  800746:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800749:	83 eb 01             	sub    $0x1,%ebx
  80074c:	85 db                	test   %ebx,%ebx
  80074e:	7f ed                	jg     80073d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	56                   	push   %esi
  800754:	83 ec 04             	sub    $0x4,%esp
  800757:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075a:	ff 75 e0             	pushl  -0x20(%ebp)
  80075d:	ff 75 dc             	pushl  -0x24(%ebp)
  800760:	ff 75 d8             	pushl  -0x28(%ebp)
  800763:	e8 68 0c 00 00       	call   8013d0 <__umoddi3>
  800768:	83 c4 14             	add    $0x14,%esp
  80076b:	0f be 80 a3 16 80 00 	movsbl 0x8016a3(%eax),%eax
  800772:	50                   	push   %eax
  800773:	ff d7                	call   *%edi
  800775:	83 c4 10             	add    $0x10,%esp
}
  800778:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800783:	83 fa 01             	cmp    $0x1,%edx
  800786:	7e 0e                	jle    800796 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80078d:	89 08                	mov    %ecx,(%eax)
  80078f:	8b 02                	mov    (%edx),%eax
  800791:	8b 52 04             	mov    0x4(%edx),%edx
  800794:	eb 22                	jmp    8007b8 <getuint+0x38>
	else if (lflag)
  800796:	85 d2                	test   %edx,%edx
  800798:	74 10                	je     8007aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079a:	8b 10                	mov    (%eax),%edx
  80079c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80079f:	89 08                	mov    %ecx,(%eax)
  8007a1:	8b 02                	mov    (%edx),%eax
  8007a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a8:	eb 0e                	jmp    8007b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007af:	89 08                	mov    %ecx,(%eax)
  8007b1:	8b 02                	mov    (%edx),%eax
  8007b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8007c9:	73 0a                	jae    8007d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007ce:	89 08                	mov    %ecx,(%eax)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	88 02                	mov    %al,(%edx)
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 05 00 00 00       	call   8007f4 <vprintfmt>
	va_end(ap);
  8007ef:	83 c4 10             	add    $0x10,%esp
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	57                   	push   %edi
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 2c             	sub    $0x2c,%esp
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800803:	8b 7d 10             	mov    0x10(%ebp),%edi
  800806:	eb 12                	jmp    80081a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800808:	85 c0                	test   %eax,%eax
  80080a:	0f 84 90 03 00 00    	je     800ba0 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	53                   	push   %ebx
  800814:	50                   	push   %eax
  800815:	ff d6                	call   *%esi
  800817:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081a:	83 c7 01             	add    $0x1,%edi
  80081d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800821:	83 f8 25             	cmp    $0x25,%eax
  800824:	75 e2                	jne    800808 <vprintfmt+0x14>
  800826:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80082a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800831:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800838:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80083f:	ba 00 00 00 00       	mov    $0x0,%edx
  800844:	eb 07                	jmp    80084d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800849:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8d 47 01             	lea    0x1(%edi),%eax
  800850:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800853:	0f b6 07             	movzbl (%edi),%eax
  800856:	0f b6 c8             	movzbl %al,%ecx
  800859:	83 e8 23             	sub    $0x23,%eax
  80085c:	3c 55                	cmp    $0x55,%al
  80085e:	0f 87 21 03 00 00    	ja     800b85 <vprintfmt+0x391>
  800864:	0f b6 c0             	movzbl %al,%eax
  800867:	ff 24 85 60 17 80 00 	jmp    *0x801760(,%eax,4)
  80086e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800871:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800875:	eb d6                	jmp    80084d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800882:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800885:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800889:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80088c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80088f:	83 fa 09             	cmp    $0x9,%edx
  800892:	77 39                	ja     8008cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800894:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800897:	eb e9                	jmp    800882 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8d 48 04             	lea    0x4(%eax),%ecx
  80089f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a2:	8b 00                	mov    (%eax),%eax
  8008a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008aa:	eb 27                	jmp    8008d3 <vprintfmt+0xdf>
  8008ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b6:	0f 49 c8             	cmovns %eax,%ecx
  8008b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bf:	eb 8c                	jmp    80084d <vprintfmt+0x59>
  8008c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008cb:	eb 80                	jmp    80084d <vprintfmt+0x59>
  8008cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008d7:	0f 89 70 ff ff ff    	jns    80084d <vprintfmt+0x59>
				width = precision, precision = -1;
  8008dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ea:	e9 5e ff ff ff       	jmp    80084d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008f5:	e9 53 ff ff ff       	jmp    80084d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8d 50 04             	lea    0x4(%eax),%edx
  800900:	89 55 14             	mov    %edx,0x14(%ebp)
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	53                   	push   %ebx
  800907:	ff 30                	pushl  (%eax)
  800909:	ff d6                	call   *%esi
			break;
  80090b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800911:	e9 04 ff ff ff       	jmp    80081a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8d 50 04             	lea    0x4(%eax),%edx
  80091c:	89 55 14             	mov    %edx,0x14(%ebp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	99                   	cltd   
  800922:	31 d0                	xor    %edx,%eax
  800924:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800926:	83 f8 09             	cmp    $0x9,%eax
  800929:	7f 0b                	jg     800936 <vprintfmt+0x142>
  80092b:	8b 14 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%edx
  800932:	85 d2                	test   %edx,%edx
  800934:	75 18                	jne    80094e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800936:	50                   	push   %eax
  800937:	68 bb 16 80 00       	push   $0x8016bb
  80093c:	53                   	push   %ebx
  80093d:	56                   	push   %esi
  80093e:	e8 94 fe ff ff       	call   8007d7 <printfmt>
  800943:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800946:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800949:	e9 cc fe ff ff       	jmp    80081a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80094e:	52                   	push   %edx
  80094f:	68 c4 16 80 00       	push   $0x8016c4
  800954:	53                   	push   %ebx
  800955:	56                   	push   %esi
  800956:	e8 7c fe ff ff       	call   8007d7 <printfmt>
  80095b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800961:	e9 b4 fe ff ff       	jmp    80081a <vprintfmt+0x26>
  800966:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800969:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80096c:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8d 50 04             	lea    0x4(%eax),%edx
  800975:	89 55 14             	mov    %edx,0x14(%ebp)
  800978:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097a:	85 ff                	test   %edi,%edi
  80097c:	ba b4 16 80 00       	mov    $0x8016b4,%edx
  800981:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800984:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800988:	0f 84 92 00 00 00    	je     800a20 <vprintfmt+0x22c>
  80098e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800992:	0f 8e 96 00 00 00    	jle    800a2e <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800998:	83 ec 08             	sub    $0x8,%esp
  80099b:	51                   	push   %ecx
  80099c:	57                   	push   %edi
  80099d:	e8 86 02 00 00       	call   800c28 <strnlen>
  8009a2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009a5:	29 c1                	sub    %eax,%ecx
  8009a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009b7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b9:	eb 0f                	jmp    8009ca <vprintfmt+0x1d6>
					putch(padc, putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	53                   	push   %ebx
  8009bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c4:	83 ef 01             	sub    $0x1,%edi
  8009c7:	83 c4 10             	add    $0x10,%esp
  8009ca:	85 ff                	test   %edi,%edi
  8009cc:	7f ed                	jg     8009bb <vprintfmt+0x1c7>
  8009ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	0f 49 c1             	cmovns %ecx,%eax
  8009de:	29 c1                	sub    %eax,%ecx
  8009e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009e9:	89 cb                	mov    %ecx,%ebx
  8009eb:	eb 4d                	jmp    800a3a <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f1:	74 1b                	je     800a0e <vprintfmt+0x21a>
  8009f3:	0f be c0             	movsbl %al,%eax
  8009f6:	83 e8 20             	sub    $0x20,%eax
  8009f9:	83 f8 5e             	cmp    $0x5e,%eax
  8009fc:	76 10                	jbe    800a0e <vprintfmt+0x21a>
					putch('?', putdat);
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	6a 3f                	push   $0x3f
  800a06:	ff 55 08             	call   *0x8(%ebp)
  800a09:	83 c4 10             	add    $0x10,%esp
  800a0c:	eb 0d                	jmp    800a1b <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800a0e:	83 ec 08             	sub    $0x8,%esp
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	52                   	push   %edx
  800a15:	ff 55 08             	call   *0x8(%ebp)
  800a18:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1b:	83 eb 01             	sub    $0x1,%ebx
  800a1e:	eb 1a                	jmp    800a3a <vprintfmt+0x246>
  800a20:	89 75 08             	mov    %esi,0x8(%ebp)
  800a23:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a26:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a29:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a2c:	eb 0c                	jmp    800a3a <vprintfmt+0x246>
  800a2e:	89 75 08             	mov    %esi,0x8(%ebp)
  800a31:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a34:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a37:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3a:	83 c7 01             	add    $0x1,%edi
  800a3d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a41:	0f be d0             	movsbl %al,%edx
  800a44:	85 d2                	test   %edx,%edx
  800a46:	74 23                	je     800a6b <vprintfmt+0x277>
  800a48:	85 f6                	test   %esi,%esi
  800a4a:	78 a1                	js     8009ed <vprintfmt+0x1f9>
  800a4c:	83 ee 01             	sub    $0x1,%esi
  800a4f:	79 9c                	jns    8009ed <vprintfmt+0x1f9>
  800a51:	89 df                	mov    %ebx,%edi
  800a53:	8b 75 08             	mov    0x8(%ebp),%esi
  800a56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a59:	eb 18                	jmp    800a73 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	6a 20                	push   $0x20
  800a61:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a63:	83 ef 01             	sub    $0x1,%edi
  800a66:	83 c4 10             	add    $0x10,%esp
  800a69:	eb 08                	jmp    800a73 <vprintfmt+0x27f>
  800a6b:	89 df                	mov    %ebx,%edi
  800a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	7f e4                	jg     800a5b <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7a:	e9 9b fd ff ff       	jmp    80081a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7f:	83 fa 01             	cmp    $0x1,%edx
  800a82:	7e 16                	jle    800a9a <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 08             	lea    0x8(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8d:	8b 50 04             	mov    0x4(%eax),%edx
  800a90:	8b 00                	mov    (%eax),%eax
  800a92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a95:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a98:	eb 32                	jmp    800acc <vprintfmt+0x2d8>
	else if (lflag)
  800a9a:	85 d2                	test   %edx,%edx
  800a9c:	74 18                	je     800ab6 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa1:	8d 50 04             	lea    0x4(%eax),%edx
  800aa4:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa7:	8b 00                	mov    (%eax),%eax
  800aa9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aac:	89 c1                	mov    %eax,%ecx
  800aae:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab4:	eb 16                	jmp    800acc <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 50 04             	lea    0x4(%eax),%edx
  800abc:	89 55 14             	mov    %edx,0x14(%ebp)
  800abf:	8b 00                	mov    (%eax),%eax
  800ac1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac4:	89 c1                	mov    %eax,%ecx
  800ac6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ac9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800acc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800acf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800adb:	79 74                	jns    800b51 <vprintfmt+0x35d>
				putch('-', putdat);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	53                   	push   %ebx
  800ae1:	6a 2d                	push   $0x2d
  800ae3:	ff d6                	call   *%esi
				num = -(long long) num;
  800ae5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aeb:	f7 d8                	neg    %eax
  800aed:	83 d2 00             	adc    $0x0,%edx
  800af0:	f7 da                	neg    %edx
  800af2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800af5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800afa:	eb 55                	jmp    800b51 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800afc:	8d 45 14             	lea    0x14(%ebp),%eax
  800aff:	e8 7c fc ff ff       	call   800780 <getuint>
			base = 10;
  800b04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b09:	eb 46                	jmp    800b51 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0e:	e8 6d fc ff ff       	call   800780 <getuint>
                        base = 8;
  800b13:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800b18:	eb 37                	jmp    800b51 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	53                   	push   %ebx
  800b1e:	6a 30                	push   $0x30
  800b20:	ff d6                	call   *%esi
			putch('x', putdat);
  800b22:	83 c4 08             	add    $0x8,%esp
  800b25:	53                   	push   %ebx
  800b26:	6a 78                	push   $0x78
  800b28:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2d:	8d 50 04             	lea    0x4(%eax),%edx
  800b30:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b33:	8b 00                	mov    (%eax),%eax
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b3a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b3d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b42:	eb 0d                	jmp    800b51 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b44:	8d 45 14             	lea    0x14(%ebp),%eax
  800b47:	e8 34 fc ff ff       	call   800780 <getuint>
			base = 16;
  800b4c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b58:	57                   	push   %edi
  800b59:	ff 75 e0             	pushl  -0x20(%ebp)
  800b5c:	51                   	push   %ecx
  800b5d:	52                   	push   %edx
  800b5e:	50                   	push   %eax
  800b5f:	89 da                	mov    %ebx,%edx
  800b61:	89 f0                	mov    %esi,%eax
  800b63:	e8 6e fb ff ff       	call   8006d6 <printnum>
			break;
  800b68:	83 c4 20             	add    $0x20,%esp
  800b6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b6e:	e9 a7 fc ff ff       	jmp    80081a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	53                   	push   %ebx
  800b77:	51                   	push   %ecx
  800b78:	ff d6                	call   *%esi
			break;
  800b7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b80:	e9 95 fc ff ff       	jmp    80081a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b85:	83 ec 08             	sub    $0x8,%esp
  800b88:	53                   	push   %ebx
  800b89:	6a 25                	push   $0x25
  800b8b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	eb 03                	jmp    800b95 <vprintfmt+0x3a1>
  800b92:	83 ef 01             	sub    $0x1,%edi
  800b95:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b99:	75 f7                	jne    800b92 <vprintfmt+0x39e>
  800b9b:	e9 7a fc ff ff       	jmp    80081a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 18             	sub    $0x18,%esp
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bbb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	74 26                	je     800bef <vsnprintf+0x47>
  800bc9:	85 d2                	test   %edx,%edx
  800bcb:	7e 22                	jle    800bef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bcd:	ff 75 14             	pushl  0x14(%ebp)
  800bd0:	ff 75 10             	pushl  0x10(%ebp)
  800bd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd6:	50                   	push   %eax
  800bd7:	68 ba 07 80 00       	push   $0x8007ba
  800bdc:	e8 13 fc ff ff       	call   8007f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bea:	83 c4 10             	add    $0x10,%esp
  800bed:	eb 05                	jmp    800bf4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf4:	c9                   	leave  
  800bf5:	c3                   	ret    

00800bf6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bfc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bff:	50                   	push   %eax
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	e8 9a ff ff ff       	call   800ba8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c16:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1b:	eb 03                	jmp    800c20 <strlen+0x10>
		n++;
  800c1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c24:	75 f7                	jne    800c1d <strlen+0xd>
		n++;
	return n;
}
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	eb 03                	jmp    800c3b <strnlen+0x13>
		n++;
  800c38:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3b:	39 c2                	cmp    %eax,%edx
  800c3d:	74 08                	je     800c47 <strnlen+0x1f>
  800c3f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c43:	75 f3                	jne    800c38 <strnlen+0x10>
  800c45:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	53                   	push   %ebx
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c53:	89 c2                	mov    %eax,%edx
  800c55:	83 c2 01             	add    $0x1,%edx
  800c58:	83 c1 01             	add    $0x1,%ecx
  800c5b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c5f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c62:	84 db                	test   %bl,%bl
  800c64:	75 ef                	jne    800c55 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c66:	5b                   	pop    %ebx
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	53                   	push   %ebx
  800c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c70:	53                   	push   %ebx
  800c71:	e8 9a ff ff ff       	call   800c10 <strlen>
  800c76:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c79:	ff 75 0c             	pushl  0xc(%ebp)
  800c7c:	01 d8                	add    %ebx,%eax
  800c7e:	50                   	push   %eax
  800c7f:	e8 c5 ff ff ff       	call   800c49 <strcpy>
	return dst;
}
  800c84:	89 d8                	mov    %ebx,%eax
  800c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	8b 75 08             	mov    0x8(%ebp),%esi
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	89 f3                	mov    %esi,%ebx
  800c98:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	eb 0f                	jmp    800cae <strncpy+0x23>
		*dst++ = *src;
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	0f b6 01             	movzbl (%ecx),%eax
  800ca5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca8:	80 39 01             	cmpb   $0x1,(%ecx)
  800cab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cae:	39 da                	cmp    %ebx,%edx
  800cb0:	75 ed                	jne    800c9f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb2:	89 f0                	mov    %esi,%eax
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 10             	mov    0x10(%ebp),%edx
  800cc6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc8:	85 d2                	test   %edx,%edx
  800cca:	74 21                	je     800ced <strlcpy+0x35>
  800ccc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd0:	89 f2                	mov    %esi,%edx
  800cd2:	eb 09                	jmp    800cdd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cd4:	83 c2 01             	add    $0x1,%edx
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cdd:	39 c2                	cmp    %eax,%edx
  800cdf:	74 09                	je     800cea <strlcpy+0x32>
  800ce1:	0f b6 19             	movzbl (%ecx),%ebx
  800ce4:	84 db                	test   %bl,%bl
  800ce6:	75 ec                	jne    800cd4 <strlcpy+0x1c>
  800ce8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ced:	29 f0                	sub    %esi,%eax
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cfc:	eb 06                	jmp    800d04 <strcmp+0x11>
		p++, q++;
  800cfe:	83 c1 01             	add    $0x1,%ecx
  800d01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d04:	0f b6 01             	movzbl (%ecx),%eax
  800d07:	84 c0                	test   %al,%al
  800d09:	74 04                	je     800d0f <strcmp+0x1c>
  800d0b:	3a 02                	cmp    (%edx),%al
  800d0d:	74 ef                	je     800cfe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d0f:	0f b6 c0             	movzbl %al,%eax
  800d12:	0f b6 12             	movzbl (%edx),%edx
  800d15:	29 d0                	sub    %edx,%eax
}
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	53                   	push   %ebx
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d28:	eb 06                	jmp    800d30 <strncmp+0x17>
		n--, p++, q++;
  800d2a:	83 c0 01             	add    $0x1,%eax
  800d2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d30:	39 d8                	cmp    %ebx,%eax
  800d32:	74 15                	je     800d49 <strncmp+0x30>
  800d34:	0f b6 08             	movzbl (%eax),%ecx
  800d37:	84 c9                	test   %cl,%cl
  800d39:	74 04                	je     800d3f <strncmp+0x26>
  800d3b:	3a 0a                	cmp    (%edx),%cl
  800d3d:	74 eb                	je     800d2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3f:	0f b6 00             	movzbl (%eax),%eax
  800d42:	0f b6 12             	movzbl (%edx),%edx
  800d45:	29 d0                	sub    %edx,%eax
  800d47:	eb 05                	jmp    800d4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d5b:	eb 07                	jmp    800d64 <strchr+0x13>
		if (*s == c)
  800d5d:	38 ca                	cmp    %cl,%dl
  800d5f:	74 0f                	je     800d70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d61:	83 c0 01             	add    $0x1,%eax
  800d64:	0f b6 10             	movzbl (%eax),%edx
  800d67:	84 d2                	test   %dl,%dl
  800d69:	75 f2                	jne    800d5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d7c:	eb 03                	jmp    800d81 <strfind+0xf>
  800d7e:	83 c0 01             	add    $0x1,%eax
  800d81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d84:	84 d2                	test   %dl,%dl
  800d86:	74 04                	je     800d8c <strfind+0x1a>
  800d88:	38 ca                	cmp    %cl,%dl
  800d8a:	75 f2                	jne    800d7e <strfind+0xc>
			break;
	return (char *) s;
}
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d9a:	85 c9                	test   %ecx,%ecx
  800d9c:	74 36                	je     800dd4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da4:	75 28                	jne    800dce <memset+0x40>
  800da6:	f6 c1 03             	test   $0x3,%cl
  800da9:	75 23                	jne    800dce <memset+0x40>
		c &= 0xFF;
  800dab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800daf:	89 d3                	mov    %edx,%ebx
  800db1:	c1 e3 08             	shl    $0x8,%ebx
  800db4:	89 d6                	mov    %edx,%esi
  800db6:	c1 e6 18             	shl    $0x18,%esi
  800db9:	89 d0                	mov    %edx,%eax
  800dbb:	c1 e0 10             	shl    $0x10,%eax
  800dbe:	09 f0                	or     %esi,%eax
  800dc0:	09 c2                	or     %eax,%edx
  800dc2:	89 d0                	mov    %edx,%eax
  800dc4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc9:	fc                   	cld    
  800dca:	f3 ab                	rep stos %eax,%es:(%edi)
  800dcc:	eb 06                	jmp    800dd4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	fc                   	cld    
  800dd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 35                	jae    800e22 <memmove+0x47>
  800ded:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 2e                	jae    800e22 <memmove+0x47>
		s += n;
		d += n;
  800df4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800df7:	89 d6                	mov    %edx,%esi
  800df9:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e01:	75 13                	jne    800e16 <memmove+0x3b>
  800e03:	f6 c1 03             	test   $0x3,%cl
  800e06:	75 0e                	jne    800e16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e08:	83 ef 04             	sub    $0x4,%edi
  800e0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e11:	fd                   	std    
  800e12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e14:	eb 09                	jmp    800e1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e16:	83 ef 01             	sub    $0x1,%edi
  800e19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1c:	fd                   	std    
  800e1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e1f:	fc                   	cld    
  800e20:	eb 1d                	jmp    800e3f <memmove+0x64>
  800e22:	89 f2                	mov    %esi,%edx
  800e24:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	f6 c2 03             	test   $0x3,%dl
  800e29:	75 0f                	jne    800e3a <memmove+0x5f>
  800e2b:	f6 c1 03             	test   $0x3,%cl
  800e2e:	75 0a                	jne    800e3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e30:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e33:	89 c7                	mov    %eax,%edi
  800e35:	fc                   	cld    
  800e36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e38:	eb 05                	jmp    800e3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3a:	89 c7                	mov    %eax,%edi
  800e3c:	fc                   	cld    
  800e3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e46:	ff 75 10             	pushl  0x10(%ebp)
  800e49:	ff 75 0c             	pushl  0xc(%ebp)
  800e4c:	ff 75 08             	pushl  0x8(%ebp)
  800e4f:	e8 87 ff ff ff       	call   800ddb <memmove>
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	89 c6                	mov    %eax,%esi
  800e63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e66:	eb 1a                	jmp    800e82 <memcmp+0x2c>
		if (*s1 != *s2)
  800e68:	0f b6 08             	movzbl (%eax),%ecx
  800e6b:	0f b6 1a             	movzbl (%edx),%ebx
  800e6e:	38 d9                	cmp    %bl,%cl
  800e70:	74 0a                	je     800e7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e72:	0f b6 c1             	movzbl %cl,%eax
  800e75:	0f b6 db             	movzbl %bl,%ebx
  800e78:	29 d8                	sub    %ebx,%eax
  800e7a:	eb 0f                	jmp    800e8b <memcmp+0x35>
		s1++, s2++;
  800e7c:	83 c0 01             	add    $0x1,%eax
  800e7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e82:	39 f0                	cmp    %esi,%eax
  800e84:	75 e2                	jne    800e68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e9d:	eb 07                	jmp    800ea6 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e9f:	38 08                	cmp    %cl,(%eax)
  800ea1:	74 07                	je     800eaa <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea3:	83 c0 01             	add    $0x1,%eax
  800ea6:	39 d0                	cmp    %edx,%eax
  800ea8:	72 f5                	jb     800e9f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb8:	eb 03                	jmp    800ebd <strtol+0x11>
		s++;
  800eba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ebd:	0f b6 01             	movzbl (%ecx),%eax
  800ec0:	3c 09                	cmp    $0x9,%al
  800ec2:	74 f6                	je     800eba <strtol+0xe>
  800ec4:	3c 20                	cmp    $0x20,%al
  800ec6:	74 f2                	je     800eba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ec8:	3c 2b                	cmp    $0x2b,%al
  800eca:	75 0a                	jne    800ed6 <strtol+0x2a>
		s++;
  800ecc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ecf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed4:	eb 10                	jmp    800ee6 <strtol+0x3a>
  800ed6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800edb:	3c 2d                	cmp    $0x2d,%al
  800edd:	75 07                	jne    800ee6 <strtol+0x3a>
		s++, neg = 1;
  800edf:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ee2:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee6:	85 db                	test   %ebx,%ebx
  800ee8:	0f 94 c0             	sete   %al
  800eeb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef1:	75 19                	jne    800f0c <strtol+0x60>
  800ef3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ef6:	75 14                	jne    800f0c <strtol+0x60>
  800ef8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800efc:	0f 85 82 00 00 00    	jne    800f84 <strtol+0xd8>
		s += 2, base = 16;
  800f02:	83 c1 02             	add    $0x2,%ecx
  800f05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0a:	eb 16                	jmp    800f22 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f0c:	84 c0                	test   %al,%al
  800f0e:	74 12                	je     800f22 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f10:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f15:	80 39 30             	cmpb   $0x30,(%ecx)
  800f18:	75 08                	jne    800f22 <strtol+0x76>
		s++, base = 8;
  800f1a:	83 c1 01             	add    $0x1,%ecx
  800f1d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2a:	0f b6 11             	movzbl (%ecx),%edx
  800f2d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f30:	89 f3                	mov    %esi,%ebx
  800f32:	80 fb 09             	cmp    $0x9,%bl
  800f35:	77 08                	ja     800f3f <strtol+0x93>
			dig = *s - '0';
  800f37:	0f be d2             	movsbl %dl,%edx
  800f3a:	83 ea 30             	sub    $0x30,%edx
  800f3d:	eb 22                	jmp    800f61 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800f3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f42:	89 f3                	mov    %esi,%ebx
  800f44:	80 fb 19             	cmp    $0x19,%bl
  800f47:	77 08                	ja     800f51 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800f49:	0f be d2             	movsbl %dl,%edx
  800f4c:	83 ea 57             	sub    $0x57,%edx
  800f4f:	eb 10                	jmp    800f61 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800f51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f54:	89 f3                	mov    %esi,%ebx
  800f56:	80 fb 19             	cmp    $0x19,%bl
  800f59:	77 16                	ja     800f71 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f5b:	0f be d2             	movsbl %dl,%edx
  800f5e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f61:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f64:	7d 0f                	jge    800f75 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800f66:	83 c1 01             	add    $0x1,%ecx
  800f69:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f6d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f6f:	eb b9                	jmp    800f2a <strtol+0x7e>
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	eb 02                	jmp    800f77 <strtol+0xcb>
  800f75:	89 c2                	mov    %eax,%edx

	if (endptr)
  800f77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7b:	74 0d                	je     800f8a <strtol+0xde>
		*endptr = (char *) s;
  800f7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f80:	89 0e                	mov    %ecx,(%esi)
  800f82:	eb 06                	jmp    800f8a <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f84:	84 c0                	test   %al,%al
  800f86:	75 92                	jne    800f1a <strtol+0x6e>
  800f88:	eb 98                	jmp    800f22 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f8a:	f7 da                	neg    %edx
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	0f 45 c2             	cmovne %edx,%eax
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	89 c7                	mov    %eax,%edi
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc4:	89 d1                	mov    %edx,%ecx
  800fc6:	89 d3                	mov    %edx,%ebx
  800fc8:	89 d7                	mov    %edx,%edi
  800fca:	89 d6                	mov    %edx,%esi
  800fcc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 cb                	mov    %ecx,%ebx
  800feb:	89 cf                	mov    %ecx,%edi
  800fed:	89 ce                	mov    %ecx,%esi
  800fef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 17                	jle    80100c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 03                	push   $0x3
  800ffb:	68 e8 18 80 00       	push   $0x8018e8
  801000:	6a 23                	push   $0x23
  801002:	68 05 19 80 00       	push   $0x801905
  801007:	e8 dd f5 ff ff       	call   8005e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 02 00 00 00       	mov    $0x2,%eax
  801024:	89 d1                	mov    %edx,%ecx
  801026:	89 d3                	mov    %edx,%ebx
  801028:	89 d7                	mov    %edx,%edi
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_yield>:

void
sys_yield(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 d3                	mov    %edx,%ebx
  801047:	89 d7                	mov    %edx,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	be 00 00 00 00       	mov    $0x0,%esi
  801060:	b8 04 00 00 00       	mov    $0x4,%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106e:	89 f7                	mov    %esi,%edi
  801070:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 17                	jle    80108d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	6a 04                	push   $0x4
  80107c:	68 e8 18 80 00       	push   $0x8018e8
  801081:	6a 23                	push   $0x23
  801083:	68 05 19 80 00       	push   $0x801905
  801088:	e8 5c f5 ff ff       	call   8005e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109e:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010af:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	7e 17                	jle    8010cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	50                   	push   %eax
  8010bc:	6a 05                	push   $0x5
  8010be:	68 e8 18 80 00       	push   $0x8018e8
  8010c3:	6a 23                	push   $0x23
  8010c5:	68 05 19 80 00       	push   $0x801905
  8010ca:	e8 1a f5 ff ff       	call   8005e9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 df                	mov    %ebx,%edi
  8010f2:	89 de                	mov    %ebx,%esi
  8010f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	7e 17                	jle    801111 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	50                   	push   %eax
  8010fe:	6a 06                	push   $0x6
  801100:	68 e8 18 80 00       	push   $0x8018e8
  801105:	6a 23                	push   $0x23
  801107:	68 05 19 80 00       	push   $0x801905
  80110c:	e8 d8 f4 ff ff       	call   8005e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
  801127:	b8 08 00 00 00       	mov    $0x8,%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	89 df                	mov    %ebx,%edi
  801134:	89 de                	mov    %ebx,%esi
  801136:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	7e 17                	jle    801153 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	50                   	push   %eax
  801140:	6a 08                	push   $0x8
  801142:	68 e8 18 80 00       	push   $0x8018e8
  801147:	6a 23                	push   $0x23
  801149:	68 05 19 80 00       	push   $0x801905
  80114e:	e8 96 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	b8 09 00 00 00       	mov    $0x9,%eax
  80116e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 df                	mov    %ebx,%edi
  801176:	89 de                	mov    %ebx,%esi
  801178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117a:	85 c0                	test   %eax,%eax
  80117c:	7e 17                	jle    801195 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	50                   	push   %eax
  801182:	6a 09                	push   $0x9
  801184:	68 e8 18 80 00       	push   $0x8018e8
  801189:	6a 23                	push   $0x23
  80118b:	68 05 19 80 00       	push   $0x801905
  801190:	e8 54 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a3:	be 00 00 00 00       	mov    $0x0,%esi
  8011a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	89 cb                	mov    %ecx,%ebx
  8011d8:	89 cf                	mov    %ecx,%edi
  8011da:	89 ce                	mov    %ecx,%esi
  8011dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	7e 17                	jle    8011f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	50                   	push   %eax
  8011e6:	6a 0c                	push   $0xc
  8011e8:	68 e8 18 80 00       	push   $0x8018e8
  8011ed:	6a 23                	push   $0x23
  8011ef:	68 05 19 80 00       	push   $0x801905
  8011f4:	e8 f0 f3 ff ff       	call   8005e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5f                   	pop    %edi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801207:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80120e:	75 2c                	jne    80123c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	6a 07                	push   $0x7
  801215:	68 00 f0 bf ee       	push   $0xeebff000
  80121a:	6a 00                	push   $0x0
  80121c:	e8 31 fe ff ff       	call   801052 <sys_page_alloc>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	74 14                	je     80123c <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 14 19 80 00       	push   $0x801914
  801230:	6a 21                	push   $0x21
  801232:	68 78 19 80 00       	push   $0x801978
  801237:	e8 ad f3 ff ff       	call   8005e9 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	a3 d0 20 80 00       	mov    %eax,0x8020d0
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801244:	83 ec 08             	sub    $0x8,%esp
  801247:	68 70 12 80 00       	push   $0x801270
  80124c:	6a 00                	push   $0x0
  80124e:	e8 08 ff ff ff       	call   80115b <sys_env_set_pgfault_upcall>
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	79 14                	jns    80126e <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	68 40 19 80 00       	push   $0x801940
  801262:	6a 29                	push   $0x29
  801264:	68 78 19 80 00       	push   $0x801978
  801269:	e8 7b f3 ff ff       	call   8005e9 <_panic>
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801270:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801271:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801276:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801278:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80127b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801280:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801284:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  801288:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80128a:	83 c4 08             	add    $0x8,%esp
        popal
  80128d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80128e:	83 c4 04             	add    $0x4,%esp
        popfl
  801291:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801292:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801293:	c3                   	ret    
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	83 ec 10             	sub    $0x10,%esp
  8012a6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8012aa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8012ae:	8b 74 24 24          	mov    0x24(%esp),%esi
  8012b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012bc:	89 34 24             	mov    %esi,(%esp)
  8012bf:	89 c8                	mov    %ecx,%eax
  8012c1:	75 35                	jne    8012f8 <__udivdi3+0x58>
  8012c3:	39 f1                	cmp    %esi,%ecx
  8012c5:	0f 87 bd 00 00 00    	ja     801388 <__udivdi3+0xe8>
  8012cb:	85 c9                	test   %ecx,%ecx
  8012cd:	89 cd                	mov    %ecx,%ebp
  8012cf:	75 0b                	jne    8012dc <__udivdi3+0x3c>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	31 d2                	xor    %edx,%edx
  8012d8:	f7 f1                	div    %ecx
  8012da:	89 c5                	mov    %eax,%ebp
  8012dc:	89 f0                	mov    %esi,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f5                	div    %ebp
  8012e2:	89 c6                	mov    %eax,%esi
  8012e4:	89 f8                	mov    %edi,%eax
  8012e6:	f7 f5                	div    %ebp
  8012e8:	89 f2                	mov    %esi,%edx
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	5e                   	pop    %esi
  8012ee:	5f                   	pop    %edi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	3b 14 24             	cmp    (%esp),%edx
  8012fb:	77 7b                	ja     801378 <__udivdi3+0xd8>
  8012fd:	0f bd f2             	bsr    %edx,%esi
  801300:	83 f6 1f             	xor    $0x1f,%esi
  801303:	0f 84 97 00 00 00    	je     8013a0 <__udivdi3+0x100>
  801309:	bd 20 00 00 00       	mov    $0x20,%ebp
  80130e:	89 d7                	mov    %edx,%edi
  801310:	89 f1                	mov    %esi,%ecx
  801312:	29 f5                	sub    %esi,%ebp
  801314:	d3 e7                	shl    %cl,%edi
  801316:	89 c2                	mov    %eax,%edx
  801318:	89 e9                	mov    %ebp,%ecx
  80131a:	d3 ea                	shr    %cl,%edx
  80131c:	89 f1                	mov    %esi,%ecx
  80131e:	09 fa                	or     %edi,%edx
  801320:	8b 3c 24             	mov    (%esp),%edi
  801323:	d3 e0                	shl    %cl,%eax
  801325:	89 54 24 08          	mov    %edx,0x8(%esp)
  801329:	89 e9                	mov    %ebp,%ecx
  80132b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801333:	89 fa                	mov    %edi,%edx
  801335:	d3 ea                	shr    %cl,%edx
  801337:	89 f1                	mov    %esi,%ecx
  801339:	d3 e7                	shl    %cl,%edi
  80133b:	89 e9                	mov    %ebp,%ecx
  80133d:	d3 e8                	shr    %cl,%eax
  80133f:	09 c7                	or     %eax,%edi
  801341:	89 f8                	mov    %edi,%eax
  801343:	f7 74 24 08          	divl   0x8(%esp)
  801347:	89 d5                	mov    %edx,%ebp
  801349:	89 c7                	mov    %eax,%edi
  80134b:	f7 64 24 0c          	mull   0xc(%esp)
  80134f:	39 d5                	cmp    %edx,%ebp
  801351:	89 14 24             	mov    %edx,(%esp)
  801354:	72 11                	jb     801367 <__udivdi3+0xc7>
  801356:	8b 54 24 04          	mov    0x4(%esp),%edx
  80135a:	89 f1                	mov    %esi,%ecx
  80135c:	d3 e2                	shl    %cl,%edx
  80135e:	39 c2                	cmp    %eax,%edx
  801360:	73 5e                	jae    8013c0 <__udivdi3+0x120>
  801362:	3b 2c 24             	cmp    (%esp),%ebp
  801365:	75 59                	jne    8013c0 <__udivdi3+0x120>
  801367:	8d 47 ff             	lea    -0x1(%edi),%eax
  80136a:	31 f6                	xor    %esi,%esi
  80136c:	89 f2                	mov    %esi,%edx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	31 f6                	xor    %esi,%esi
  80137a:	31 c0                	xor    %eax,%eax
  80137c:	89 f2                	mov    %esi,%edx
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	89 f2                	mov    %esi,%edx
  80138a:	31 f6                	xor    %esi,%esi
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	f7 f1                	div    %ecx
  801390:	89 f2                	mov    %esi,%edx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013a4:	76 0b                	jbe    8013b1 <__udivdi3+0x111>
  8013a6:	31 c0                	xor    %eax,%eax
  8013a8:	3b 14 24             	cmp    (%esp),%edx
  8013ab:	0f 83 37 ff ff ff    	jae    8012e8 <__udivdi3+0x48>
  8013b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b6:	e9 2d ff ff ff       	jmp    8012e8 <__udivdi3+0x48>
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	89 f8                	mov    %edi,%eax
  8013c2:	31 f6                	xor    %esi,%esi
  8013c4:	e9 1f ff ff ff       	jmp    8012e8 <__udivdi3+0x48>
  8013c9:	66 90                	xchg   %ax,%ax
  8013cb:	66 90                	xchg   %ax,%ax
  8013cd:	66 90                	xchg   %ax,%ax
  8013cf:	90                   	nop

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	83 ec 20             	sub    $0x20,%esp
  8013d6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8013da:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013de:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e2:	89 c6                	mov    %eax,%esi
  8013e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013ec:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8013f0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013f4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8013f8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	75 1e                	jne    801420 <__umoddi3+0x50>
  801402:	39 f7                	cmp    %esi,%edi
  801404:	76 52                	jbe    801458 <__umoddi3+0x88>
  801406:	89 c8                	mov    %ecx,%eax
  801408:	89 f2                	mov    %esi,%edx
  80140a:	f7 f7                	div    %edi
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	31 d2                	xor    %edx,%edx
  801410:	83 c4 20             	add    $0x20,%esp
  801413:	5e                   	pop    %esi
  801414:	5f                   	pop    %edi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    
  801417:	89 f6                	mov    %esi,%esi
  801419:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801420:	39 f0                	cmp    %esi,%eax
  801422:	77 5c                	ja     801480 <__umoddi3+0xb0>
  801424:	0f bd e8             	bsr    %eax,%ebp
  801427:	83 f5 1f             	xor    $0x1f,%ebp
  80142a:	75 64                	jne    801490 <__umoddi3+0xc0>
  80142c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801430:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801434:	0f 86 f6 00 00 00    	jbe    801530 <__umoddi3+0x160>
  80143a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80143e:	0f 82 ec 00 00 00    	jb     801530 <__umoddi3+0x160>
  801444:	8b 44 24 14          	mov    0x14(%esp),%eax
  801448:	8b 54 24 18          	mov    0x18(%esp),%edx
  80144c:	83 c4 20             	add    $0x20,%esp
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	85 ff                	test   %edi,%edi
  80145a:	89 fd                	mov    %edi,%ebp
  80145c:	75 0b                	jne    801469 <__umoddi3+0x99>
  80145e:	b8 01 00 00 00       	mov    $0x1,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f7                	div    %edi
  801467:	89 c5                	mov    %eax,%ebp
  801469:	8b 44 24 10          	mov    0x10(%esp),%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	f7 f5                	div    %ebp
  801471:	89 c8                	mov    %ecx,%eax
  801473:	f7 f5                	div    %ebp
  801475:	eb 95                	jmp    80140c <__umoddi3+0x3c>
  801477:	89 f6                	mov    %esi,%esi
  801479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801480:	89 c8                	mov    %ecx,%eax
  801482:	89 f2                	mov    %esi,%edx
  801484:	83 c4 20             	add    $0x20,%esp
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    
  80148b:	90                   	nop
  80148c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801490:	b8 20 00 00 00       	mov    $0x20,%eax
  801495:	89 e9                	mov    %ebp,%ecx
  801497:	29 e8                	sub    %ebp,%eax
  801499:	d3 e2                	shl    %cl,%edx
  80149b:	89 c7                	mov    %eax,%edi
  80149d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8014a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014a5:	89 f9                	mov    %edi,%ecx
  8014a7:	d3 e8                	shr    %cl,%eax
  8014a9:	89 c1                	mov    %eax,%ecx
  8014ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014af:	09 d1                	or     %edx,%ecx
  8014b1:	89 fa                	mov    %edi,%edx
  8014b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014b7:	89 e9                	mov    %ebp,%ecx
  8014b9:	d3 e0                	shl    %cl,%eax
  8014bb:	89 f9                	mov    %edi,%ecx
  8014bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c1:	89 f0                	mov    %esi,%eax
  8014c3:	d3 e8                	shr    %cl,%eax
  8014c5:	89 e9                	mov    %ebp,%ecx
  8014c7:	89 c7                	mov    %eax,%edi
  8014c9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014cd:	d3 e6                	shl    %cl,%esi
  8014cf:	89 d1                	mov    %edx,%ecx
  8014d1:	89 fa                	mov    %edi,%edx
  8014d3:	d3 e8                	shr    %cl,%eax
  8014d5:	89 e9                	mov    %ebp,%ecx
  8014d7:	09 f0                	or     %esi,%eax
  8014d9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8014dd:	f7 74 24 10          	divl   0x10(%esp)
  8014e1:	d3 e6                	shl    %cl,%esi
  8014e3:	89 d1                	mov    %edx,%ecx
  8014e5:	f7 64 24 0c          	mull   0xc(%esp)
  8014e9:	39 d1                	cmp    %edx,%ecx
  8014eb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8014ef:	89 d7                	mov    %edx,%edi
  8014f1:	89 c6                	mov    %eax,%esi
  8014f3:	72 0a                	jb     8014ff <__umoddi3+0x12f>
  8014f5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8014f9:	73 10                	jae    80150b <__umoddi3+0x13b>
  8014fb:	39 d1                	cmp    %edx,%ecx
  8014fd:	75 0c                	jne    80150b <__umoddi3+0x13b>
  8014ff:	89 d7                	mov    %edx,%edi
  801501:	89 c6                	mov    %eax,%esi
  801503:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801507:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80150b:	89 ca                	mov    %ecx,%edx
  80150d:	89 e9                	mov    %ebp,%ecx
  80150f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801513:	29 f0                	sub    %esi,%eax
  801515:	19 fa                	sbb    %edi,%edx
  801517:	d3 e8                	shr    %cl,%eax
  801519:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80151e:	89 d7                	mov    %edx,%edi
  801520:	d3 e7                	shl    %cl,%edi
  801522:	89 e9                	mov    %ebp,%ecx
  801524:	09 f8                	or     %edi,%eax
  801526:	d3 ea                	shr    %cl,%edx
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	5e                   	pop    %esi
  80152c:	5f                   	pop    %edi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    
  80152f:	90                   	nop
  801530:	8b 74 24 10          	mov    0x10(%esp),%esi
  801534:	29 f9                	sub    %edi,%ecx
  801536:	19 c6                	sbb    %eax,%esi
  801538:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80153c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801540:	e9 ff fe ff ff       	jmp    801444 <__umoddi3+0x74>
