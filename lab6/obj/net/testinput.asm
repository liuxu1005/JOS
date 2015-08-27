
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 d1 07 00 00       	call   800802 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 4c 12 00 00       	call   80128d <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 80 	movl   $0x802e80,0x804000
  80004a:	2e 80 00 

	output_envid = fork();
  80004d:	e8 ed 15 00 00       	call   80163f <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 8a 2e 80 00       	push   $0x802e8a
  800063:	6a 4c                	push   $0x4c
  800065:	68 98 2e 80 00       	push   $0x802e98
  80006a:	e8 f3 07 00 00       	call   800862 <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 08 04 00 00       	call   800484 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 b6 15 00 00       	call   80163f <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 8a 2e 80 00       	push   $0x802e8a
  80009a:	6a 54                	push   $0x54
  80009c:	68 98 2e 80 00       	push   $0x802e98
  8000a1:	e8 bc 07 00 00       	call   800862 <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 a8 2e 80 00       	push   $0x802ea8
  8000c3:	e8 73 08 00 00       	call   80093b <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 c5 2e 80 00 	movl   $0x802ec5,(%esp)
  8000e7:	e8 e4 06 00 00       	call   8007d0 <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 cf 2e 80 00 	movl   $0x802ecf,(%esp)
  8000f6:	e8 d5 06 00 00       	call   8007d0 <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 bc 11 00 00       	call   8012cb <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 d8 2e 80 00       	push   $0x802ed8
  80011c:	6a 19                	push   $0x19
  80011e:	68 98 2e 80 00       	push   $0x802e98
  800123:	e8 3a 07 00 00       	call   800862 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 c1 0e 00 00       	call   801007 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 63 0f 00 00       	call   8010bc <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 3c 04 00 00       	call   8005a1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 2a 04 00 00       	call   8005a1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 18 04 00 00       	call   8005a1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 06 04 00 00       	call   8005a1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 f4 03 00 00       	call   8005a1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 f9 0e 00 00       	call   8010bc <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 e6 0e 00 00       	call   8010bc <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 20 0e 00 00       	call   801007 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 c2 0e 00 00       	call   8010bc <memcpy>
	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 bc 16 00 00       	call   8018ca <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 33 11 00 00       	call   801350 <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 22 16 00 00       	call   801861 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 e9 2e 80 00       	push   $0x802ee9
  80024c:	6a 63                	push   $0x63
  80024e:	68 98 2e 80 00       	push   $0x802e98
  800253:	e8 0a 06 00 00       	call   800862 <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 40 2f 80 00       	push   $0x802f40
  800269:	6a 65                	push   $0x65
  80026b:	68 98 2e 80 00       	push   $0x802e98
  800270:	e8 ed 05 00 00       	call   800862 <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 f6 2e 80 00       	push   $0x802ef6
  800280:	6a 67                	push   $0x67
  800282:	68 98 2e 80 00       	push   $0x802e98
  800287:	e8 d6 05 00 00       	call   800862 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 de                	mov    %ebx,%esi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 08 2f 80 00       	push   $0x802f08
  8002b9:	68 10 2f 80 00       	push   $0x802f10
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 a6 0b 00 00       	call   800e6f <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 30          	movzbl (%eax,%esi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 1a 2f 80 00       	push   $0x802f1a
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f8                	sub    %edi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	57                   	push   %edi
  8002e8:	e8 82 0b 00 00       	call   800e6f <snprintf>
  8002ed:	01 c7                	add    %eax,%edi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 34 03             	lea    (%ebx,%eax,1),%esi
  8002fa:	83 e6 0f             	and    $0xf,%esi
  8002fd:	29 c6                	sub    %eax,%esi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 fe 0f             	cmp    $0xf,%esi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f8                	mov    %edi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 1f 2f 80 00       	push   $0x802f1f
  800320:	e8 16 06 00 00       	call   80093b <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 07 20             	movb   $0x20,(%edi)
  80033d:	8d 7f 01             	lea    0x1(%edi),%edi
		if (i % 16 == 7)
  800340:	83 fe 07             	cmp    $0x7,%esi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 07 20             	movb   $0x20,(%edi)
  800348:	8d 7f 01             	lea    0x1(%edi),%edi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 3b 2f 80 00       	push   $0x802f3b
  80035f:	e8 d7 05 00 00       	call   80093b <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 25 2f 80 00       	push   $0x802f25
  800378:	e8 be 05 00 00       	call   80093b <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 14 11 00 00       	call   8014bc <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 65 	movl   $0x802f65,0x804000
  8003b4:	2f 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 eb 0e 00 00       	call   8012ac <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 f6 10 00 00       	call   8014bc <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 6e 2f 80 00       	push   $0x802f6e
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 80 2f 80 00       	push   $0x802f80
  8003e1:	e8 7c 04 00 00       	call   800862 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 d8 14 00 00       	call   8018ca <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 5f 14 00 00       	call   801861 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 c6                	cmp    %eax,%esi
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 8c 2f 80 00       	push   $0x802f8c
  800417:	e8 1f 05 00 00       	call   80093b <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 96 10 00 00       	call   8014bc <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	53                   	push   %ebx
  80042e:	83 ec 04             	sub    $0x4,%esp
  800431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	binaryname = "ns_input";
  800434:	c7 05 00 40 80 00 c7 	movl   $0x802fc7,0x804000
  80043b:	2f 80 00 
  80043e:	eb 1c                	jmp    80045c <input+0x32>
        int r;
        while(1) {
 
                
                 while(( r = sys_recv((void *)RXTEP)) < 0) {
                       if(r != -E_IPC_NOT_RECV)
  800440:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800443:	74 12                	je     800457 <input+0x2d>
                               panic("sys_recv fails %e\n", r);
  800445:	50                   	push   %eax
  800446:	68 d0 2f 80 00       	push   $0x802fd0
  80044b:	6a 17                	push   $0x17
  80044d:	68 e3 2f 80 00       	push   $0x802fe3
  800452:	e8 0b 04 00 00       	call   800862 <_panic>
                       sys_yield();
  800457:	e8 50 0e 00 00       	call   8012ac <sys_yield>
 
        int r;
        while(1) {
 
                
                 while(( r = sys_recv((void *)RXTEP)) < 0) {
  80045c:	83 ec 0c             	sub    $0xc,%esp
  80045f:	68 00 20 80 40       	push   $0x40802000
  800464:	e8 b3 10 00 00       	call   80151c <sys_recv>
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 c0                	test   %eax,%eax
  80046e:	78 d0                	js     800440 <input+0x16>
                       if(r != -E_IPC_NOT_RECV)
                               panic("sys_recv fails %e\n", r);
                       sys_yield();
               }
      
               ipc_send(ns_envid, NSREQ_INPUT, (void *)RXTEP, PTE_U | PTE_P); 
  800470:	6a 05                	push   $0x5
  800472:	68 00 20 80 40       	push   $0x40802000
  800477:	6a 0a                	push   $0xa
  800479:	53                   	push   %ebx
  80047a:	e8 4b 14 00 00       	call   8018ca <ipc_send>
        }
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb d8                	jmp    80045c <input+0x32>

00800484 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	57                   	push   %edi
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 1c             	sub    $0x1c,%esp
  80048d:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_output";
  800490:	c7 05 00 40 80 00 ef 	movl   $0x802fef,0x804000
  800497:	2f 80 00 
	//	- send the packet to the device driver
        envid_t from_envid;
        int perm;
        int r;
        while(1) {
                r = ipc_recv(&from_envid, (void *)TXTEP, &perm);
  80049a:	8d 75 e0             	lea    -0x20(%ebp),%esi
  80049d:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	56                   	push   %esi
  8004a4:	68 00 20 40 40       	push   $0x40402000
  8004a9:	53                   	push   %ebx
  8004aa:	e8 b2 13 00 00       	call   801861 <ipc_recv>
                if (r < 0)
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	79 12                	jns    8004c8 <output+0x44>
                        panic("ipc_recv from net fails %e\n", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 f9 2f 80 00       	push   $0x802ff9
  8004bc:	6a 13                	push   $0x13
  8004be:	68 15 30 80 00       	push   $0x803015
  8004c3:	e8 9a 03 00 00       	call   800862 <_panic>
                if (from_envid != ns_envid)
                        continue;
                if (r != NSREQ_OUTPUT)
  8004c8:	83 f8 0b             	cmp    $0xb,%eax
  8004cb:	75 d3                	jne    8004a0 <output+0x1c>
  8004cd:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
  8004d0:	75 ce                	jne    8004a0 <output+0x1c>
  8004d2:	eb 1c                	jmp    8004f0 <output+0x6c>
                        continue;
                while((r = sys_transmit((void *)TXTEP) ) < 0) {
                        if(r != -E_IPC_NOT_RECV)
  8004d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8004d7:	74 12                	je     8004eb <output+0x67>
                                panic("sys_transit fails %e\n", r);
  8004d9:	50                   	push   %eax
  8004da:	68 22 30 80 00       	push   $0x803022
  8004df:	6a 1a                	push   $0x1a
  8004e1:	68 15 30 80 00       	push   $0x803015
  8004e6:	e8 77 03 00 00       	call   800862 <_panic>
                        sys_yield();
  8004eb:	e8 bc 0d 00 00       	call   8012ac <sys_yield>
                        panic("ipc_recv from net fails %e\n", r);
                if (from_envid != ns_envid)
                        continue;
                if (r != NSREQ_OUTPUT)
                        continue;
                while((r = sys_transmit((void *)TXTEP) ) < 0) {
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	68 00 20 40 40       	push   $0x40402000
  8004f8:	e8 de 0f 00 00       	call   8014db <sys_transmit>
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 d0                	js     8004d4 <output+0x50>
  800504:	eb 9a                	jmp    8004a0 <output+0x1c>

00800506 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	53                   	push   %ebx
  80050c:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800515:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800518:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  80051f:	0f b6 1f             	movzbl (%edi),%ebx
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800527:	0f b6 d3             	movzbl %bl,%edx
  80052a:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80052d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
  800530:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800533:	66 c1 e8 0b          	shr    $0xb,%ax
  800537:	89 c2                	mov    %eax,%edx
  800539:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80053c:	01 c0                	add    %eax,%eax
  80053e:	29 c3                	sub    %eax,%ebx
  800540:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  800542:	89 d3                	mov    %edx,%ebx
      inv[i++] = '0' + rem;
  800544:	8d 71 01             	lea    0x1(%ecx),%esi
  800547:	0f b6 c9             	movzbl %cl,%ecx
  80054a:	83 c0 30             	add    $0x30,%eax
  80054d:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
  800551:	89 f1                	mov    %esi,%ecx
    } while(*ap);
  800553:	84 d2                	test   %dl,%dl
  800555:	75 d0                	jne    800527 <inet_ntoa+0x21>
  800557:	89 f2                	mov    %esi,%edx
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800559:	89 f3                	mov    %esi,%ebx
  80055b:	c6 07 00             	movb   $0x0,(%edi)
  80055e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800561:	eb 0d                	jmp    800570 <inet_ntoa+0x6a>
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  800563:	0f b6 c2             	movzbl %dl,%eax
  800566:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80056b:	88 01                	mov    %al,(%ecx)
  80056d:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800570:	83 ea 01             	sub    $0x1,%edx
  800573:	80 fa ff             	cmp    $0xff,%dl
  800576:	75 eb                	jne    800563 <inet_ntoa+0x5d>
  800578:	0f b6 db             	movzbl %bl,%ebx
  80057b:	03 5d e0             	add    -0x20(%ebp),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80057e:	8d 43 01             	lea    0x1(%ebx),%eax
  800581:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800584:	c6 03 2e             	movb   $0x2e,(%ebx)
    ap++;
  800587:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80058a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80058d:	39 c7                	cmp    %eax,%edi
  80058f:	75 8e                	jne    80051f <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800591:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800594:	b8 08 50 80 00       	mov    $0x805008,%eax
  800599:	83 c4 14             	add    $0x14,%esp
  80059c:	5b                   	pop    %ebx
  80059d:	5e                   	pop    %esi
  80059e:	5f                   	pop    %edi
  80059f:	5d                   	pop    %ebp
  8005a0:	c3                   	ret    

008005a1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005a4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005a8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005b1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005b5:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  8005b9:	5d                   	pop    %ebp
  8005ba:	c3                   	ret    

008005bb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8005c1:	89 d1                	mov    %edx,%ecx
  8005c3:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8005c6:	89 d0                	mov    %edx,%eax
  8005c8:	c1 e0 18             	shl    $0x18,%eax
  8005cb:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8005cd:	89 d1                	mov    %edx,%ecx
  8005cf:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8005d5:	c1 e1 08             	shl    $0x8,%ecx
  8005d8:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8005da:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8005e0:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8005e3:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 1c             	sub    $0x1c,%esp
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8005f3:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8005f6:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8005f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8005fc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ff:	80 f9 09             	cmp    $0x9,%cl
  800602:	0f 87 a6 01 00 00    	ja     8007ae <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  800608:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  80060f:	83 fa 30             	cmp    $0x30,%edx
  800612:	75 2b                	jne    80063f <inet_aton+0x58>
      c = *++cp;
  800614:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800618:	89 d1                	mov    %edx,%ecx
  80061a:	83 e1 df             	and    $0xffffffdf,%ecx
  80061d:	80 f9 58             	cmp    $0x58,%cl
  800620:	74 0f                	je     800631 <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800622:	83 c0 01             	add    $0x1,%eax
  800625:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800628:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  80062f:	eb 0e                	jmp    80063f <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800631:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800635:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800638:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  80063f:	83 c0 01             	add    $0x1,%eax
  800642:	bf 00 00 00 00       	mov    $0x0,%edi
  800647:	eb 03                	jmp    80064c <inet_aton+0x65>
  800649:	83 c0 01             	add    $0x1,%eax
  80064c:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  80064f:	89 d6                	mov    %edx,%esi
  800651:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800654:	80 f9 09             	cmp    $0x9,%cl
  800657:	77 0d                	ja     800666 <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  800659:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  80065d:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  800661:	0f be 10             	movsbl (%eax),%edx
  800664:	eb e3                	jmp    800649 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  800666:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  80066a:	75 2e                	jne    80069a <inet_aton+0xb3>
  80066c:	8d 4e 9f             	lea    -0x61(%esi),%ecx
  80066f:	88 4d df             	mov    %cl,-0x21(%ebp)
  800672:	89 d1                	mov    %edx,%ecx
  800674:	83 e1 df             	and    $0xffffffdf,%ecx
  800677:	83 e9 41             	sub    $0x41,%ecx
  80067a:	80 f9 05             	cmp    $0x5,%cl
  80067d:	77 21                	ja     8006a0 <inet_aton+0xb9>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80067f:	c1 e7 04             	shl    $0x4,%edi
  800682:	83 c2 0a             	add    $0xa,%edx
  800685:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  800689:	19 c9                	sbb    %ecx,%ecx
  80068b:	83 e1 20             	and    $0x20,%ecx
  80068e:	83 c1 41             	add    $0x41,%ecx
  800691:	29 ca                	sub    %ecx,%edx
  800693:	09 d7                	or     %edx,%edi
        c = *++cp;
  800695:	0f be 10             	movsbl (%eax),%edx
  800698:	eb af                	jmp    800649 <inet_aton+0x62>
  80069a:	89 d0                	mov    %edx,%eax
  80069c:	89 f9                	mov    %edi,%ecx
  80069e:	eb 04                	jmp    8006a4 <inet_aton+0xbd>
  8006a0:	89 d0                	mov    %edx,%eax
  8006a2:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  8006a4:	83 f8 2e             	cmp    $0x2e,%eax
  8006a7:	75 23                	jne    8006cc <inet_aton+0xe5>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8006a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ac:	8d 75 f0             	lea    -0x10(%ebp),%esi
  8006af:	39 f0                	cmp    %esi,%eax
  8006b1:	0f 84 fe 00 00 00    	je     8007b5 <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  8006b7:	83 c0 04             	add    $0x4,%eax
  8006ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bd:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  8006c0:	8d 43 01             	lea    0x1(%ebx),%eax
  8006c3:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  8006c7:	e9 30 ff ff ff       	jmp    8005fc <inet_aton+0x15>
  8006cc:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	74 29                	je     8006fb <inet_aton+0x114>
    return (0);
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006d7:	89 f3                	mov    %esi,%ebx
  8006d9:	80 fb 1f             	cmp    $0x1f,%bl
  8006dc:	0f 86 e6 00 00 00    	jbe    8007c8 <inet_aton+0x1e1>
  8006e2:	84 d2                	test   %dl,%dl
  8006e4:	0f 88 d2 00 00 00    	js     8007bc <inet_aton+0x1d5>
  8006ea:	83 fa 20             	cmp    $0x20,%edx
  8006ed:	74 0c                	je     8006fb <inet_aton+0x114>
  8006ef:	83 ea 09             	sub    $0x9,%edx
  8006f2:	83 fa 04             	cmp    $0x4,%edx
  8006f5:	0f 87 cd 00 00 00    	ja     8007c8 <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8006fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800701:	29 c2                	sub    %eax,%edx
  800703:	c1 fa 02             	sar    $0x2,%edx
  800706:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  800709:	83 fa 02             	cmp    $0x2,%edx
  80070c:	74 20                	je     80072e <inet_aton+0x147>
  80070e:	83 fa 02             	cmp    $0x2,%edx
  800711:	7f 0f                	jg     800722 <inet_aton+0x13b>

  case 0:
    return (0);       /* initial nondigit */
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800718:	85 d2                	test   %edx,%edx
  80071a:	0f 84 a8 00 00 00    	je     8007c8 <inet_aton+0x1e1>
  800720:	eb 71                	jmp    800793 <inet_aton+0x1ac>
  800722:	83 fa 03             	cmp    $0x3,%edx
  800725:	74 24                	je     80074b <inet_aton+0x164>
  800727:	83 fa 04             	cmp    $0x4,%edx
  80072a:	74 40                	je     80076c <inet_aton+0x185>
  80072c:	eb 65                	jmp    800793 <inet_aton+0x1ac>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800733:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  800739:	0f 87 89 00 00 00    	ja     8007c8 <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  80073f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800742:	c1 e0 18             	shl    $0x18,%eax
  800745:	89 cf                	mov    %ecx,%edi
  800747:	09 c7                	or     %eax,%edi
    break;
  800749:	eb 48                	jmp    800793 <inet_aton+0x1ac>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800750:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  800756:	77 70                	ja     8007c8 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800758:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80075b:	c1 e2 10             	shl    $0x10,%edx
  80075e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800761:	c1 e0 18             	shl    $0x18,%eax
  800764:	09 d0                	or     %edx,%eax
  800766:	09 c8                	or     %ecx,%eax
  800768:	89 c7                	mov    %eax,%edi
    break;
  80076a:	eb 27                	jmp    800793 <inet_aton+0x1ac>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80076c:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800771:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  800777:	77 4f                	ja     8007c8 <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800779:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80077c:	c1 e2 10             	shl    $0x10,%edx
  80077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800782:	c1 e0 18             	shl    $0x18,%eax
  800785:	09 c2                	or     %eax,%edx
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c1 e0 08             	shl    $0x8,%eax
  80078d:	09 d0                	or     %edx,%eax
  80078f:	09 c8                	or     %ecx,%eax
  800791:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  800793:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800797:	74 2a                	je     8007c3 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  800799:	57                   	push   %edi
  80079a:	e8 1c fe ff ff       	call   8005bb <htonl>
  80079f:	83 c4 04             	add    $0x4,%esp
  8007a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007a5:	89 06                	mov    %eax,(%esi)
  return (1);
  8007a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8007ac:	eb 1a                	jmp    8007c8 <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 13                	jmp    8007c8 <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ba:	eb 0c                	jmp    8007c8 <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 05                	jmp    8007c8 <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8007c3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8007c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8007d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 05 fe ff ff       	call   8005e7 <inet_aton>
  8007e2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8007ec:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8007f5:	ff 75 08             	pushl  0x8(%ebp)
  8007f8:	e8 be fd ff ff       	call   8005bb <htonl>
  8007fd:	83 c4 04             	add    $0x4,%esp
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80080a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80080d:	e8 7b 0a 00 00       	call   80128d <sys_getenvid>
  800812:	25 ff 03 00 00       	and    $0x3ff,%eax
  800817:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80081a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80081f:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800824:	85 db                	test   %ebx,%ebx
  800826:	7e 07                	jle    80082f <libmain+0x2d>
		binaryname = argv[0];
  800828:	8b 06                	mov    (%esi),%eax
  80082a:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	e8 fa f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800839:	e8 0a 00 00 00       	call   800848 <exit>
  80083e:	83 c4 10             	add    $0x10,%esp
}
  800841:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80084e:	e8 d5 12 00 00       	call   801b28 <close_all>
	sys_env_destroy(0);
  800853:	83 ec 0c             	sub    $0xc,%esp
  800856:	6a 00                	push   $0x0
  800858:	e8 ef 09 00 00       	call   80124c <sys_env_destroy>
  80085d:	83 c4 10             	add    $0x10,%esp
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800867:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80086a:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800870:	e8 18 0a 00 00       	call   80128d <sys_getenvid>
  800875:	83 ec 0c             	sub    $0xc,%esp
  800878:	ff 75 0c             	pushl  0xc(%ebp)
  80087b:	ff 75 08             	pushl  0x8(%ebp)
  80087e:	56                   	push   %esi
  80087f:	50                   	push   %eax
  800880:	68 44 30 80 00       	push   $0x803044
  800885:	e8 b1 00 00 00       	call   80093b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80088a:	83 c4 18             	add    $0x18,%esp
  80088d:	53                   	push   %ebx
  80088e:	ff 75 10             	pushl  0x10(%ebp)
  800891:	e8 54 00 00 00       	call   8008ea <vcprintf>
	cprintf("\n");
  800896:	c7 04 24 3b 2f 80 00 	movl   $0x802f3b,(%esp)
  80089d:	e8 99 00 00 00       	call   80093b <cprintf>
  8008a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8008a5:	cc                   	int3   
  8008a6:	eb fd                	jmp    8008a5 <_panic+0x43>

008008a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	83 ec 04             	sub    $0x4,%esp
  8008af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008b2:	8b 13                	mov    (%ebx),%edx
  8008b4:	8d 42 01             	lea    0x1(%edx),%eax
  8008b7:	89 03                	mov    %eax,(%ebx)
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008c5:	75 1a                	jne    8008e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	68 ff 00 00 00       	push   $0xff
  8008cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8008d2:	50                   	push   %eax
  8008d3:	e8 37 09 00 00       	call   80120f <sys_cputs>
		b->idx = 0;
  8008d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8008e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008fa:	00 00 00 
	b.cnt = 0;
  8008fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800904:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800907:	ff 75 0c             	pushl  0xc(%ebp)
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	68 a8 08 80 00       	push   $0x8008a8
  800919:	e8 4f 01 00 00       	call   800a6d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80091e:	83 c4 08             	add    $0x8,%esp
  800921:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800927:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	e8 dc 08 00 00       	call   80120f <sys_cputs>

	return b.cnt;
}
  800933:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800941:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800944:	50                   	push   %eax
  800945:	ff 75 08             	pushl  0x8(%ebp)
  800948:	e8 9d ff ff ff       	call   8008ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	83 ec 1c             	sub    $0x1c,%esp
  800958:	89 c7                	mov    %eax,%edi
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800962:	89 d1                	mov    %edx,%ecx
  800964:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800967:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80096a:	8b 45 10             	mov    0x10(%ebp),%eax
  80096d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800970:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800973:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80097a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80097d:	72 05                	jb     800984 <printnum+0x35>
  80097f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800982:	77 3e                	ja     8009c2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800984:	83 ec 0c             	sub    $0xc,%esp
  800987:	ff 75 18             	pushl  0x18(%ebp)
  80098a:	83 eb 01             	sub    $0x1,%ebx
  80098d:	53                   	push   %ebx
  80098e:	50                   	push   %eax
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	ff 75 e4             	pushl  -0x1c(%ebp)
  800995:	ff 75 e0             	pushl  -0x20(%ebp)
  800998:	ff 75 dc             	pushl  -0x24(%ebp)
  80099b:	ff 75 d8             	pushl  -0x28(%ebp)
  80099e:	e8 0d 22 00 00       	call   802bb0 <__udivdi3>
  8009a3:	83 c4 18             	add    $0x18,%esp
  8009a6:	52                   	push   %edx
  8009a7:	50                   	push   %eax
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	89 f8                	mov    %edi,%eax
  8009ac:	e8 9e ff ff ff       	call   80094f <printnum>
  8009b1:	83 c4 20             	add    $0x20,%esp
  8009b4:	eb 13                	jmp    8009c9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	56                   	push   %esi
  8009ba:	ff 75 18             	pushl  0x18(%ebp)
  8009bd:	ff d7                	call   *%edi
  8009bf:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009c2:	83 eb 01             	sub    $0x1,%ebx
  8009c5:	85 db                	test   %ebx,%ebx
  8009c7:	7f ed                	jg     8009b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	56                   	push   %esi
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8009d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8009dc:	e8 ff 22 00 00       	call   802ce0 <__umoddi3>
  8009e1:	83 c4 14             	add    $0x14,%esp
  8009e4:	0f be 80 67 30 80 00 	movsbl 0x803067(%eax),%eax
  8009eb:	50                   	push   %eax
  8009ec:	ff d7                	call   *%edi
  8009ee:	83 c4 10             	add    $0x10,%esp
}
  8009f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009fc:	83 fa 01             	cmp    $0x1,%edx
  8009ff:	7e 0e                	jle    800a0f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a06:	89 08                	mov    %ecx,(%eax)
  800a08:	8b 02                	mov    (%edx),%eax
  800a0a:	8b 52 04             	mov    0x4(%edx),%edx
  800a0d:	eb 22                	jmp    800a31 <getuint+0x38>
	else if (lflag)
  800a0f:	85 d2                	test   %edx,%edx
  800a11:	74 10                	je     800a23 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a13:	8b 10                	mov    (%eax),%edx
  800a15:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a18:	89 08                	mov    %ecx,(%eax)
  800a1a:	8b 02                	mov    (%edx),%eax
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	eb 0e                	jmp    800a31 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a23:	8b 10                	mov    (%eax),%edx
  800a25:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a28:	89 08                	mov    %ecx,(%eax)
  800a2a:	8b 02                	mov    (%edx),%eax
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a39:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a3d:	8b 10                	mov    (%eax),%edx
  800a3f:	3b 50 04             	cmp    0x4(%eax),%edx
  800a42:	73 0a                	jae    800a4e <sprintputch+0x1b>
		*b->buf++ = ch;
  800a44:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a47:	89 08                	mov    %ecx,(%eax)
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	88 02                	mov    %al,(%edx)
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a56:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a59:	50                   	push   %eax
  800a5a:	ff 75 10             	pushl  0x10(%ebp)
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	ff 75 08             	pushl  0x8(%ebp)
  800a63:	e8 05 00 00 00       	call   800a6d <vprintfmt>
	va_end(ap);
  800a68:	83 c4 10             	add    $0x10,%esp
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	83 ec 2c             	sub    $0x2c,%esp
  800a76:	8b 75 08             	mov    0x8(%ebp),%esi
  800a79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a7f:	eb 12                	jmp    800a93 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a81:	85 c0                	test   %eax,%eax
  800a83:	0f 84 90 03 00 00    	je     800e19 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800a89:	83 ec 08             	sub    $0x8,%esp
  800a8c:	53                   	push   %ebx
  800a8d:	50                   	push   %eax
  800a8e:	ff d6                	call   *%esi
  800a90:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a93:	83 c7 01             	add    $0x1,%edi
  800a96:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a9a:	83 f8 25             	cmp    $0x25,%eax
  800a9d:	75 e2                	jne    800a81 <vprintfmt+0x14>
  800a9f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800aa3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800aaa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ab1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	eb 07                	jmp    800ac6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ac2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac6:	8d 47 01             	lea    0x1(%edi),%eax
  800ac9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800acc:	0f b6 07             	movzbl (%edi),%eax
  800acf:	0f b6 c8             	movzbl %al,%ecx
  800ad2:	83 e8 23             	sub    $0x23,%eax
  800ad5:	3c 55                	cmp    $0x55,%al
  800ad7:	0f 87 21 03 00 00    	ja     800dfe <vprintfmt+0x391>
  800add:	0f b6 c0             	movzbl %al,%eax
  800ae0:	ff 24 85 c0 31 80 00 	jmp    *0x8031c0(,%eax,4)
  800ae7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800aea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800aee:	eb d6                	jmp    800ac6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800afb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800afe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800b02:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800b05:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800b08:	83 fa 09             	cmp    $0x9,%edx
  800b0b:	77 39                	ja     800b46 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b0d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800b10:	eb e9                	jmp    800afb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b12:	8b 45 14             	mov    0x14(%ebp),%eax
  800b15:	8d 48 04             	lea    0x4(%eax),%ecx
  800b18:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b1b:	8b 00                	mov    (%eax),%eax
  800b1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b23:	eb 27                	jmp    800b4c <vprintfmt+0xdf>
  800b25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	0f 49 c8             	cmovns %eax,%ecx
  800b32:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b38:	eb 8c                	jmp    800ac6 <vprintfmt+0x59>
  800b3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b3d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b44:	eb 80                	jmp    800ac6 <vprintfmt+0x59>
  800b46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b49:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b4c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b50:	0f 89 70 ff ff ff    	jns    800ac6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800b56:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b5c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800b63:	e9 5e ff ff ff       	jmp    800ac6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b68:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b6e:	e9 53 ff ff ff       	jmp    800ac6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8d 50 04             	lea    0x4(%eax),%edx
  800b79:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7c:	83 ec 08             	sub    $0x8,%esp
  800b7f:	53                   	push   %ebx
  800b80:	ff 30                	pushl  (%eax)
  800b82:	ff d6                	call   *%esi
			break;
  800b84:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b8a:	e9 04 ff ff ff       	jmp    800a93 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b92:	8d 50 04             	lea    0x4(%eax),%edx
  800b95:	89 55 14             	mov    %edx,0x14(%ebp)
  800b98:	8b 00                	mov    (%eax),%eax
  800b9a:	99                   	cltd   
  800b9b:	31 d0                	xor    %edx,%eax
  800b9d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b9f:	83 f8 0f             	cmp    $0xf,%eax
  800ba2:	7f 0b                	jg     800baf <vprintfmt+0x142>
  800ba4:	8b 14 85 40 33 80 00 	mov    0x803340(,%eax,4),%edx
  800bab:	85 d2                	test   %edx,%edx
  800bad:	75 18                	jne    800bc7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800baf:	50                   	push   %eax
  800bb0:	68 7f 30 80 00       	push   $0x80307f
  800bb5:	53                   	push   %ebx
  800bb6:	56                   	push   %esi
  800bb7:	e8 94 fe ff ff       	call   800a50 <printfmt>
  800bbc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800bc2:	e9 cc fe ff ff       	jmp    800a93 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800bc7:	52                   	push   %edx
  800bc8:	68 d9 35 80 00       	push   $0x8035d9
  800bcd:	53                   	push   %ebx
  800bce:	56                   	push   %esi
  800bcf:	e8 7c fe ff ff       	call   800a50 <printfmt>
  800bd4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bda:	e9 b4 fe ff ff       	jmp    800a93 <vprintfmt+0x26>
  800bdf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800be2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800be5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800be8:	8b 45 14             	mov    0x14(%ebp),%eax
  800beb:	8d 50 04             	lea    0x4(%eax),%edx
  800bee:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800bf3:	85 ff                	test   %edi,%edi
  800bf5:	ba 78 30 80 00       	mov    $0x803078,%edx
  800bfa:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800bfd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800c01:	0f 84 92 00 00 00    	je     800c99 <vprintfmt+0x22c>
  800c07:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800c0b:	0f 8e 96 00 00 00    	jle    800ca7 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c11:	83 ec 08             	sub    $0x8,%esp
  800c14:	51                   	push   %ecx
  800c15:	57                   	push   %edi
  800c16:	e8 86 02 00 00       	call   800ea1 <strnlen>
  800c1b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c1e:	29 c1                	sub    %eax,%ecx
  800c20:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800c23:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800c26:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800c30:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c32:	eb 0f                	jmp    800c43 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800c34:	83 ec 08             	sub    $0x8,%esp
  800c37:	53                   	push   %ebx
  800c38:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c3d:	83 ef 01             	sub    $0x1,%edi
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	85 ff                	test   %edi,%edi
  800c45:	7f ed                	jg     800c34 <vprintfmt+0x1c7>
  800c47:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c4a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c4d:	85 c9                	test   %ecx,%ecx
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c54:	0f 49 c1             	cmovns %ecx,%eax
  800c57:	29 c1                	sub    %eax,%ecx
  800c59:	89 75 08             	mov    %esi,0x8(%ebp)
  800c5c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c5f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c62:	89 cb                	mov    %ecx,%ebx
  800c64:	eb 4d                	jmp    800cb3 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c66:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c6a:	74 1b                	je     800c87 <vprintfmt+0x21a>
  800c6c:	0f be c0             	movsbl %al,%eax
  800c6f:	83 e8 20             	sub    $0x20,%eax
  800c72:	83 f8 5e             	cmp    $0x5e,%eax
  800c75:	76 10                	jbe    800c87 <vprintfmt+0x21a>
					putch('?', putdat);
  800c77:	83 ec 08             	sub    $0x8,%esp
  800c7a:	ff 75 0c             	pushl  0xc(%ebp)
  800c7d:	6a 3f                	push   $0x3f
  800c7f:	ff 55 08             	call   *0x8(%ebp)
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	eb 0d                	jmp    800c94 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800c87:	83 ec 08             	sub    $0x8,%esp
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	52                   	push   %edx
  800c8e:	ff 55 08             	call   *0x8(%ebp)
  800c91:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c94:	83 eb 01             	sub    $0x1,%ebx
  800c97:	eb 1a                	jmp    800cb3 <vprintfmt+0x246>
  800c99:	89 75 08             	mov    %esi,0x8(%ebp)
  800c9c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c9f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ca2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ca5:	eb 0c                	jmp    800cb3 <vprintfmt+0x246>
  800ca7:	89 75 08             	mov    %esi,0x8(%ebp)
  800caa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800cb0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800cb3:	83 c7 01             	add    $0x1,%edi
  800cb6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800cba:	0f be d0             	movsbl %al,%edx
  800cbd:	85 d2                	test   %edx,%edx
  800cbf:	74 23                	je     800ce4 <vprintfmt+0x277>
  800cc1:	85 f6                	test   %esi,%esi
  800cc3:	78 a1                	js     800c66 <vprintfmt+0x1f9>
  800cc5:	83 ee 01             	sub    $0x1,%esi
  800cc8:	79 9c                	jns    800c66 <vprintfmt+0x1f9>
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd2:	eb 18                	jmp    800cec <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800cd4:	83 ec 08             	sub    $0x8,%esp
  800cd7:	53                   	push   %ebx
  800cd8:	6a 20                	push   $0x20
  800cda:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cdc:	83 ef 01             	sub    $0x1,%edi
  800cdf:	83 c4 10             	add    $0x10,%esp
  800ce2:	eb 08                	jmp    800cec <vprintfmt+0x27f>
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cec:	85 ff                	test   %edi,%edi
  800cee:	7f e4                	jg     800cd4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf3:	e9 9b fd ff ff       	jmp    800a93 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800cf8:	83 fa 01             	cmp    $0x1,%edx
  800cfb:	7e 16                	jle    800d13 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800cfd:	8b 45 14             	mov    0x14(%ebp),%eax
  800d00:	8d 50 08             	lea    0x8(%eax),%edx
  800d03:	89 55 14             	mov    %edx,0x14(%ebp)
  800d06:	8b 50 04             	mov    0x4(%eax),%edx
  800d09:	8b 00                	mov    (%eax),%eax
  800d0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d0e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d11:	eb 32                	jmp    800d45 <vprintfmt+0x2d8>
	else if (lflag)
  800d13:	85 d2                	test   %edx,%edx
  800d15:	74 18                	je     800d2f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800d17:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1a:	8d 50 04             	lea    0x4(%eax),%edx
  800d1d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d20:	8b 00                	mov    (%eax),%eax
  800d22:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	c1 f9 1f             	sar    $0x1f,%ecx
  800d2a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d2d:	eb 16                	jmp    800d45 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800d2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d32:	8d 50 04             	lea    0x4(%eax),%edx
  800d35:	89 55 14             	mov    %edx,0x14(%ebp)
  800d38:	8b 00                	mov    (%eax),%eax
  800d3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d3d:	89 c1                	mov    %eax,%ecx
  800d3f:	c1 f9 1f             	sar    $0x1f,%ecx
  800d42:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d45:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d48:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d4b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d50:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d54:	79 74                	jns    800dca <vprintfmt+0x35d>
				putch('-', putdat);
  800d56:	83 ec 08             	sub    $0x8,%esp
  800d59:	53                   	push   %ebx
  800d5a:	6a 2d                	push   $0x2d
  800d5c:	ff d6                	call   *%esi
				num = -(long long) num;
  800d5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d61:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d64:	f7 d8                	neg    %eax
  800d66:	83 d2 00             	adc    $0x0,%edx
  800d69:	f7 da                	neg    %edx
  800d6b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800d6e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d73:	eb 55                	jmp    800dca <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d75:	8d 45 14             	lea    0x14(%ebp),%eax
  800d78:	e8 7c fc ff ff       	call   8009f9 <getuint>
			base = 10;
  800d7d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d82:	eb 46                	jmp    800dca <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800d84:	8d 45 14             	lea    0x14(%ebp),%eax
  800d87:	e8 6d fc ff ff       	call   8009f9 <getuint>
                        base = 8;
  800d8c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800d91:	eb 37                	jmp    800dca <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	53                   	push   %ebx
  800d97:	6a 30                	push   $0x30
  800d99:	ff d6                	call   *%esi
			putch('x', putdat);
  800d9b:	83 c4 08             	add    $0x8,%esp
  800d9e:	53                   	push   %ebx
  800d9f:	6a 78                	push   $0x78
  800da1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800da3:	8b 45 14             	mov    0x14(%ebp),%eax
  800da6:	8d 50 04             	lea    0x4(%eax),%edx
  800da9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800dac:	8b 00                	mov    (%eax),%eax
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800db3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800db6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800dbb:	eb 0d                	jmp    800dca <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800dbd:	8d 45 14             	lea    0x14(%ebp),%eax
  800dc0:	e8 34 fc ff ff       	call   8009f9 <getuint>
			base = 16;
  800dc5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800dd1:	57                   	push   %edi
  800dd2:	ff 75 e0             	pushl  -0x20(%ebp)
  800dd5:	51                   	push   %ecx
  800dd6:	52                   	push   %edx
  800dd7:	50                   	push   %eax
  800dd8:	89 da                	mov    %ebx,%edx
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	e8 6e fb ff ff       	call   80094f <printnum>
			break;
  800de1:	83 c4 20             	add    $0x20,%esp
  800de4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800de7:	e9 a7 fc ff ff       	jmp    800a93 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800dec:	83 ec 08             	sub    $0x8,%esp
  800def:	53                   	push   %ebx
  800df0:	51                   	push   %ecx
  800df1:	ff d6                	call   *%esi
			break;
  800df3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800df9:	e9 95 fc ff ff       	jmp    800a93 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800dfe:	83 ec 08             	sub    $0x8,%esp
  800e01:	53                   	push   %ebx
  800e02:	6a 25                	push   $0x25
  800e04:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	eb 03                	jmp    800e0e <vprintfmt+0x3a1>
  800e0b:	83 ef 01             	sub    $0x1,%edi
  800e0e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e12:	75 f7                	jne    800e0b <vprintfmt+0x39e>
  800e14:	e9 7a fc ff ff       	jmp    800a93 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 18             	sub    $0x18,%esp
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e30:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e34:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	74 26                	je     800e68 <vsnprintf+0x47>
  800e42:	85 d2                	test   %edx,%edx
  800e44:	7e 22                	jle    800e68 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e46:	ff 75 14             	pushl  0x14(%ebp)
  800e49:	ff 75 10             	pushl  0x10(%ebp)
  800e4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e4f:	50                   	push   %eax
  800e50:	68 33 0a 80 00       	push   $0x800a33
  800e55:	e8 13 fc ff ff       	call   800a6d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	eb 05                	jmp    800e6d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e75:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e78:	50                   	push   %eax
  800e79:	ff 75 10             	pushl  0x10(%ebp)
  800e7c:	ff 75 0c             	pushl  0xc(%ebp)
  800e7f:	ff 75 08             	pushl  0x8(%ebp)
  800e82:	e8 9a ff ff ff       	call   800e21 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	eb 03                	jmp    800e99 <strlen+0x10>
		n++;
  800e96:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e99:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e9d:	75 f7                	jne    800e96 <strlen+0xd>
		n++;
	return n;
}
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	eb 03                	jmp    800eb4 <strnlen+0x13>
		n++;
  800eb1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eb4:	39 c2                	cmp    %eax,%edx
  800eb6:	74 08                	je     800ec0 <strnlen+0x1f>
  800eb8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ebc:	75 f3                	jne    800eb1 <strnlen+0x10>
  800ebe:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	53                   	push   %ebx
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	83 c2 01             	add    $0x1,%edx
  800ed1:	83 c1 01             	add    $0x1,%ecx
  800ed4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ed8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800edb:	84 db                	test   %bl,%bl
  800edd:	75 ef                	jne    800ece <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	53                   	push   %ebx
  800ee6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ee9:	53                   	push   %ebx
  800eea:	e8 9a ff ff ff       	call   800e89 <strlen>
  800eef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	01 d8                	add    %ebx,%eax
  800ef7:	50                   	push   %eax
  800ef8:	e8 c5 ff ff ff       	call   800ec2 <strcpy>
	return dst;
}
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	89 f3                	mov    %esi,%ebx
  800f11:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f14:	89 f2                	mov    %esi,%edx
  800f16:	eb 0f                	jmp    800f27 <strncpy+0x23>
		*dst++ = *src;
  800f18:	83 c2 01             	add    $0x1,%edx
  800f1b:	0f b6 01             	movzbl (%ecx),%eax
  800f1e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f21:	80 39 01             	cmpb   $0x1,(%ecx)
  800f24:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f27:	39 da                	cmp    %ebx,%edx
  800f29:	75 ed                	jne    800f18 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	8b 75 08             	mov    0x8(%ebp),%esi
  800f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3c:	8b 55 10             	mov    0x10(%ebp),%edx
  800f3f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f41:	85 d2                	test   %edx,%edx
  800f43:	74 21                	je     800f66 <strlcpy+0x35>
  800f45:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	eb 09                	jmp    800f56 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f4d:	83 c2 01             	add    $0x1,%edx
  800f50:	83 c1 01             	add    $0x1,%ecx
  800f53:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f56:	39 c2                	cmp    %eax,%edx
  800f58:	74 09                	je     800f63 <strlcpy+0x32>
  800f5a:	0f b6 19             	movzbl (%ecx),%ebx
  800f5d:	84 db                	test   %bl,%bl
  800f5f:	75 ec                	jne    800f4d <strlcpy+0x1c>
  800f61:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f63:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f66:	29 f0                	sub    %esi,%eax
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f72:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f75:	eb 06                	jmp    800f7d <strcmp+0x11>
		p++, q++;
  800f77:	83 c1 01             	add    $0x1,%ecx
  800f7a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f7d:	0f b6 01             	movzbl (%ecx),%eax
  800f80:	84 c0                	test   %al,%al
  800f82:	74 04                	je     800f88 <strcmp+0x1c>
  800f84:	3a 02                	cmp    (%edx),%al
  800f86:	74 ef                	je     800f77 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f88:	0f b6 c0             	movzbl %al,%eax
  800f8b:	0f b6 12             	movzbl (%edx),%edx
  800f8e:	29 d0                	sub    %edx,%eax
}
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	53                   	push   %ebx
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9c:	89 c3                	mov    %eax,%ebx
  800f9e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fa1:	eb 06                	jmp    800fa9 <strncmp+0x17>
		n--, p++, q++;
  800fa3:	83 c0 01             	add    $0x1,%eax
  800fa6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fa9:	39 d8                	cmp    %ebx,%eax
  800fab:	74 15                	je     800fc2 <strncmp+0x30>
  800fad:	0f b6 08             	movzbl (%eax),%ecx
  800fb0:	84 c9                	test   %cl,%cl
  800fb2:	74 04                	je     800fb8 <strncmp+0x26>
  800fb4:	3a 0a                	cmp    (%edx),%cl
  800fb6:	74 eb                	je     800fa3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fb8:	0f b6 00             	movzbl (%eax),%eax
  800fbb:	0f b6 12             	movzbl (%edx),%edx
  800fbe:	29 d0                	sub    %edx,%eax
  800fc0:	eb 05                	jmp    800fc7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800fc7:	5b                   	pop    %ebx
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fd4:	eb 07                	jmp    800fdd <strchr+0x13>
		if (*s == c)
  800fd6:	38 ca                	cmp    %cl,%dl
  800fd8:	74 0f                	je     800fe9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fda:	83 c0 01             	add    $0x1,%eax
  800fdd:	0f b6 10             	movzbl (%eax),%edx
  800fe0:	84 d2                	test   %dl,%dl
  800fe2:	75 f2                	jne    800fd6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ff5:	eb 03                	jmp    800ffa <strfind+0xf>
  800ff7:	83 c0 01             	add    $0x1,%eax
  800ffa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ffd:	84 d2                	test   %dl,%dl
  800fff:	74 04                	je     801005 <strfind+0x1a>
  801001:	38 ca                	cmp    %cl,%dl
  801003:	75 f2                	jne    800ff7 <strfind+0xc>
			break;
	return (char *) s;
}
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801010:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801013:	85 c9                	test   %ecx,%ecx
  801015:	74 36                	je     80104d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801017:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80101d:	75 28                	jne    801047 <memset+0x40>
  80101f:	f6 c1 03             	test   $0x3,%cl
  801022:	75 23                	jne    801047 <memset+0x40>
		c &= 0xFF;
  801024:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801028:	89 d3                	mov    %edx,%ebx
  80102a:	c1 e3 08             	shl    $0x8,%ebx
  80102d:	89 d6                	mov    %edx,%esi
  80102f:	c1 e6 18             	shl    $0x18,%esi
  801032:	89 d0                	mov    %edx,%eax
  801034:	c1 e0 10             	shl    $0x10,%eax
  801037:	09 f0                	or     %esi,%eax
  801039:	09 c2                	or     %eax,%edx
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80103f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801042:	fc                   	cld    
  801043:	f3 ab                	rep stos %eax,%es:(%edi)
  801045:	eb 06                	jmp    80104d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104a:	fc                   	cld    
  80104b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80104d:	89 f8                	mov    %edi,%eax
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801062:	39 c6                	cmp    %eax,%esi
  801064:	73 35                	jae    80109b <memmove+0x47>
  801066:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801069:	39 d0                	cmp    %edx,%eax
  80106b:	73 2e                	jae    80109b <memmove+0x47>
		s += n;
		d += n;
  80106d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801070:	89 d6                	mov    %edx,%esi
  801072:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801074:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80107a:	75 13                	jne    80108f <memmove+0x3b>
  80107c:	f6 c1 03             	test   $0x3,%cl
  80107f:	75 0e                	jne    80108f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801081:	83 ef 04             	sub    $0x4,%edi
  801084:	8d 72 fc             	lea    -0x4(%edx),%esi
  801087:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80108a:	fd                   	std    
  80108b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80108d:	eb 09                	jmp    801098 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80108f:	83 ef 01             	sub    $0x1,%edi
  801092:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801095:	fd                   	std    
  801096:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801098:	fc                   	cld    
  801099:	eb 1d                	jmp    8010b8 <memmove+0x64>
  80109b:	89 f2                	mov    %esi,%edx
  80109d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80109f:	f6 c2 03             	test   $0x3,%dl
  8010a2:	75 0f                	jne    8010b3 <memmove+0x5f>
  8010a4:	f6 c1 03             	test   $0x3,%cl
  8010a7:	75 0a                	jne    8010b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8010a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8010ac:	89 c7                	mov    %eax,%edi
  8010ae:	fc                   	cld    
  8010af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010b1:	eb 05                	jmp    8010b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010b3:	89 c7                	mov    %eax,%edi
  8010b5:	fc                   	cld    
  8010b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8010bf:	ff 75 10             	pushl  0x10(%ebp)
  8010c2:	ff 75 0c             	pushl  0xc(%ebp)
  8010c5:	ff 75 08             	pushl  0x8(%ebp)
  8010c8:	e8 87 ff ff ff       	call   801054 <memmove>
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010da:	89 c6                	mov    %eax,%esi
  8010dc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010df:	eb 1a                	jmp    8010fb <memcmp+0x2c>
		if (*s1 != *s2)
  8010e1:	0f b6 08             	movzbl (%eax),%ecx
  8010e4:	0f b6 1a             	movzbl (%edx),%ebx
  8010e7:	38 d9                	cmp    %bl,%cl
  8010e9:	74 0a                	je     8010f5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8010eb:	0f b6 c1             	movzbl %cl,%eax
  8010ee:	0f b6 db             	movzbl %bl,%ebx
  8010f1:	29 d8                	sub    %ebx,%eax
  8010f3:	eb 0f                	jmp    801104 <memcmp+0x35>
		s1++, s2++;
  8010f5:	83 c0 01             	add    $0x1,%eax
  8010f8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010fb:	39 f0                	cmp    %esi,%eax
  8010fd:	75 e2                	jne    8010e1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801111:	89 c2                	mov    %eax,%edx
  801113:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801116:	eb 07                	jmp    80111f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801118:	38 08                	cmp    %cl,(%eax)
  80111a:	74 07                	je     801123 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80111c:	83 c0 01             	add    $0x1,%eax
  80111f:	39 d0                	cmp    %edx,%eax
  801121:	72 f5                	jb     801118 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801131:	eb 03                	jmp    801136 <strtol+0x11>
		s++;
  801133:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801136:	0f b6 01             	movzbl (%ecx),%eax
  801139:	3c 09                	cmp    $0x9,%al
  80113b:	74 f6                	je     801133 <strtol+0xe>
  80113d:	3c 20                	cmp    $0x20,%al
  80113f:	74 f2                	je     801133 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801141:	3c 2b                	cmp    $0x2b,%al
  801143:	75 0a                	jne    80114f <strtol+0x2a>
		s++;
  801145:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801148:	bf 00 00 00 00       	mov    $0x0,%edi
  80114d:	eb 10                	jmp    80115f <strtol+0x3a>
  80114f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801154:	3c 2d                	cmp    $0x2d,%al
  801156:	75 07                	jne    80115f <strtol+0x3a>
		s++, neg = 1;
  801158:	8d 49 01             	lea    0x1(%ecx),%ecx
  80115b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80115f:	85 db                	test   %ebx,%ebx
  801161:	0f 94 c0             	sete   %al
  801164:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80116a:	75 19                	jne    801185 <strtol+0x60>
  80116c:	80 39 30             	cmpb   $0x30,(%ecx)
  80116f:	75 14                	jne    801185 <strtol+0x60>
  801171:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801175:	0f 85 82 00 00 00    	jne    8011fd <strtol+0xd8>
		s += 2, base = 16;
  80117b:	83 c1 02             	add    $0x2,%ecx
  80117e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801183:	eb 16                	jmp    80119b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801185:	84 c0                	test   %al,%al
  801187:	74 12                	je     80119b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801189:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80118e:	80 39 30             	cmpb   $0x30,(%ecx)
  801191:	75 08                	jne    80119b <strtol+0x76>
		s++, base = 8;
  801193:	83 c1 01             	add    $0x1,%ecx
  801196:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011a3:	0f b6 11             	movzbl (%ecx),%edx
  8011a6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8011a9:	89 f3                	mov    %esi,%ebx
  8011ab:	80 fb 09             	cmp    $0x9,%bl
  8011ae:	77 08                	ja     8011b8 <strtol+0x93>
			dig = *s - '0';
  8011b0:	0f be d2             	movsbl %dl,%edx
  8011b3:	83 ea 30             	sub    $0x30,%edx
  8011b6:	eb 22                	jmp    8011da <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8011b8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8011bb:	89 f3                	mov    %esi,%ebx
  8011bd:	80 fb 19             	cmp    $0x19,%bl
  8011c0:	77 08                	ja     8011ca <strtol+0xa5>
			dig = *s - 'a' + 10;
  8011c2:	0f be d2             	movsbl %dl,%edx
  8011c5:	83 ea 57             	sub    $0x57,%edx
  8011c8:	eb 10                	jmp    8011da <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8011ca:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011cd:	89 f3                	mov    %esi,%ebx
  8011cf:	80 fb 19             	cmp    $0x19,%bl
  8011d2:	77 16                	ja     8011ea <strtol+0xc5>
			dig = *s - 'A' + 10;
  8011d4:	0f be d2             	movsbl %dl,%edx
  8011d7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8011da:	3b 55 10             	cmp    0x10(%ebp),%edx
  8011dd:	7d 0f                	jge    8011ee <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8011df:	83 c1 01             	add    $0x1,%ecx
  8011e2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011e6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8011e8:	eb b9                	jmp    8011a3 <strtol+0x7e>
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	eb 02                	jmp    8011f0 <strtol+0xcb>
  8011ee:	89 c2                	mov    %eax,%edx

	if (endptr)
  8011f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011f4:	74 0d                	je     801203 <strtol+0xde>
		*endptr = (char *) s;
  8011f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f9:	89 0e                	mov    %ecx,(%esi)
  8011fb:	eb 06                	jmp    801203 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011fd:	84 c0                	test   %al,%al
  8011ff:	75 92                	jne    801193 <strtol+0x6e>
  801201:	eb 98                	jmp    80119b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801203:	f7 da                	neg    %edx
  801205:	85 ff                	test   %edi,%edi
  801207:	0f 45 c2             	cmovne %edx,%eax
}
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
  80121a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121d:	8b 55 08             	mov    0x8(%ebp),%edx
  801220:	89 c3                	mov    %eax,%ebx
  801222:	89 c7                	mov    %eax,%edi
  801224:	89 c6                	mov    %eax,%esi
  801226:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_cgetc>:

int
sys_cgetc(void)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801233:	ba 00 00 00 00       	mov    $0x0,%edx
  801238:	b8 01 00 00 00       	mov    $0x1,%eax
  80123d:	89 d1                	mov    %edx,%ecx
  80123f:	89 d3                	mov    %edx,%ebx
  801241:	89 d7                	mov    %edx,%edi
  801243:	89 d6                	mov    %edx,%esi
  801245:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801255:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125a:	b8 03 00 00 00       	mov    $0x3,%eax
  80125f:	8b 55 08             	mov    0x8(%ebp),%edx
  801262:	89 cb                	mov    %ecx,%ebx
  801264:	89 cf                	mov    %ecx,%edi
  801266:	89 ce                	mov    %ecx,%esi
  801268:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	7e 17                	jle    801285 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	50                   	push   %eax
  801272:	6a 03                	push   $0x3
  801274:	68 9f 33 80 00       	push   $0x80339f
  801279:	6a 22                	push   $0x22
  80127b:	68 bc 33 80 00       	push   $0x8033bc
  801280:	e8 dd f5 ff ff       	call   800862 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801293:	ba 00 00 00 00       	mov    $0x0,%edx
  801298:	b8 02 00 00 00       	mov    $0x2,%eax
  80129d:	89 d1                	mov    %edx,%ecx
  80129f:	89 d3                	mov    %edx,%ebx
  8012a1:	89 d7                	mov    %edx,%edi
  8012a3:	89 d6                	mov    %edx,%esi
  8012a5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_yield>:

void
sys_yield(void)
{      
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012bc:	89 d1                	mov    %edx,%ecx
  8012be:	89 d3                	mov    %edx,%ebx
  8012c0:	89 d7                	mov    %edx,%edi
  8012c2:	89 d6                	mov    %edx,%esi
  8012c4:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	57                   	push   %edi
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8012d4:	be 00 00 00 00       	mov    $0x0,%esi
  8012d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8012de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012e7:	89 f7                	mov    %esi,%edi
  8012e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	7e 17                	jle    801306 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	50                   	push   %eax
  8012f3:	6a 04                	push   $0x4
  8012f5:	68 9f 33 80 00       	push   $0x80339f
  8012fa:	6a 22                	push   $0x22
  8012fc:	68 bc 33 80 00       	push   $0x8033bc
  801301:	e8 5c f5 ff ff       	call   800862 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5f                   	pop    %edi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801317:	b8 05 00 00 00       	mov    $0x5,%eax
  80131c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131f:	8b 55 08             	mov    0x8(%ebp),%edx
  801322:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801325:	8b 7d 14             	mov    0x14(%ebp),%edi
  801328:	8b 75 18             	mov    0x18(%ebp),%esi
  80132b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80132d:	85 c0                	test   %eax,%eax
  80132f:	7e 17                	jle    801348 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801331:	83 ec 0c             	sub    $0xc,%esp
  801334:	50                   	push   %eax
  801335:	6a 05                	push   $0x5
  801337:	68 9f 33 80 00       	push   $0x80339f
  80133c:	6a 22                	push   $0x22
  80133e:	68 bc 33 80 00       	push   $0x8033bc
  801343:	e8 1a f5 ff ff       	call   800862 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801348:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	57                   	push   %edi
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801359:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135e:	b8 06 00 00 00       	mov    $0x6,%eax
  801363:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801366:	8b 55 08             	mov    0x8(%ebp),%edx
  801369:	89 df                	mov    %ebx,%edi
  80136b:	89 de                	mov    %ebx,%esi
  80136d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80136f:	85 c0                	test   %eax,%eax
  801371:	7e 17                	jle    80138a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	50                   	push   %eax
  801377:	6a 06                	push   $0x6
  801379:	68 9f 33 80 00       	push   $0x80339f
  80137e:	6a 22                	push   $0x22
  801380:	68 bc 33 80 00       	push   $0x8033bc
  801385:	e8 d8 f4 ff ff       	call   800862 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80138a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80139b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8013a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ab:	89 df                	mov    %ebx,%edi
  8013ad:	89 de                	mov    %ebx,%esi
  8013af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	7e 17                	jle    8013cc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	50                   	push   %eax
  8013b9:	6a 08                	push   $0x8
  8013bb:	68 9f 33 80 00       	push   $0x80339f
  8013c0:	6a 22                	push   $0x22
  8013c2:	68 bc 33 80 00       	push   $0x8033bc
  8013c7:	e8 96 f4 ff ff       	call   800862 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  8013cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8013dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e2:	b8 09 00 00 00       	mov    $0x9,%eax
  8013e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ed:	89 df                	mov    %ebx,%edi
  8013ef:	89 de                	mov    %ebx,%esi
  8013f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	7e 17                	jle    80140e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	50                   	push   %eax
  8013fb:	6a 09                	push   $0x9
  8013fd:	68 9f 33 80 00       	push   $0x80339f
  801402:	6a 22                	push   $0x22
  801404:	68 bc 33 80 00       	push   $0x8033bc
  801409:	e8 54 f4 ff ff       	call   800862 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80140e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80141f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801424:	b8 0a 00 00 00       	mov    $0xa,%eax
  801429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142c:	8b 55 08             	mov    0x8(%ebp),%edx
  80142f:	89 df                	mov    %ebx,%edi
  801431:	89 de                	mov    %ebx,%esi
  801433:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801435:	85 c0                	test   %eax,%eax
  801437:	7e 17                	jle    801450 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	50                   	push   %eax
  80143d:	6a 0a                	push   $0xa
  80143f:	68 9f 33 80 00       	push   $0x80339f
  801444:	6a 22                	push   $0x22
  801446:	68 bc 33 80 00       	push   $0x8033bc
  80144b:	e8 12 f4 ff ff       	call   800862 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5f                   	pop    %edi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	57                   	push   %edi
  80145c:	56                   	push   %esi
  80145d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80145e:	be 00 00 00 00       	mov    $0x0,%esi
  801463:	b8 0c 00 00 00       	mov    $0xc,%eax
  801468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80146b:	8b 55 08             	mov    0x8(%ebp),%edx
  80146e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801471:	8b 7d 14             	mov    0x14(%ebp),%edi
  801474:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801484:	b9 00 00 00 00       	mov    $0x0,%ecx
  801489:	b8 0d 00 00 00       	mov    $0xd,%eax
  80148e:	8b 55 08             	mov    0x8(%ebp),%edx
  801491:	89 cb                	mov    %ecx,%ebx
  801493:	89 cf                	mov    %ecx,%edi
  801495:	89 ce                	mov    %ecx,%esi
  801497:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	7e 17                	jle    8014b4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	50                   	push   %eax
  8014a1:	6a 0d                	push   $0xd
  8014a3:	68 9f 33 80 00       	push   $0x80339f
  8014a8:	6a 22                	push   $0x22
  8014aa:	68 bc 33 80 00       	push   $0x8033bc
  8014af:	e8 ae f3 ff ff       	call   800862 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014cc:	89 d1                	mov    %edx,%ecx
  8014ce:	89 d3                	mov    %edx,%ebx
  8014d0:	89 d7                	mov    %edx,%edi
  8014d2:	89 d6                	mov    %edx,%esi
  8014d4:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <sys_transmit>:

int
sys_transmit(void *addr)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8014e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f1:	89 cb                	mov    %ecx,%ebx
  8014f3:	89 cf                	mov    %ecx,%edi
  8014f5:	89 ce                	mov    %ecx,%esi
  8014f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	7e 17                	jle    801514 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014fd:	83 ec 0c             	sub    $0xc,%esp
  801500:	50                   	push   %eax
  801501:	6a 0f                	push   $0xf
  801503:	68 9f 33 80 00       	push   $0x80339f
  801508:	6a 22                	push   $0x22
  80150a:	68 bc 33 80 00       	push   $0x8033bc
  80150f:	e8 4e f3 ff ff       	call   800862 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801514:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    

0080151c <sys_recv>:

int
sys_recv(void *addr)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	57                   	push   %edi
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  801525:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152a:	b8 10 00 00 00       	mov    $0x10,%eax
  80152f:	8b 55 08             	mov    0x8(%ebp),%edx
  801532:	89 cb                	mov    %ecx,%ebx
  801534:	89 cf                	mov    %ecx,%edi
  801536:	89 ce                	mov    %ecx,%esi
  801538:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80153a:	85 c0                	test   %eax,%eax
  80153c:	7e 17                	jle    801555 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	50                   	push   %eax
  801542:	6a 10                	push   $0x10
  801544:	68 9f 33 80 00       	push   $0x80339f
  801549:	6a 22                	push   $0x22
  80154b:	68 bc 33 80 00       	push   $0x8033bc
  801550:	e8 0d f3 ff ff       	call   800862 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  801555:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801567:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801569:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80156d:	74 2e                	je     80159d <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80156f:	89 c2                	mov    %eax,%edx
  801571:	c1 ea 16             	shr    $0x16,%edx
  801574:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157b:	f6 c2 01             	test   $0x1,%dl
  80157e:	74 1d                	je     80159d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801580:	89 c2                	mov    %eax,%edx
  801582:	c1 ea 0c             	shr    $0xc,%edx
  801585:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  80158c:	f6 c1 01             	test   $0x1,%cl
  80158f:	74 0c                	je     80159d <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801591:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  801598:	f6 c6 08             	test   $0x8,%dh
  80159b:	75 14                	jne    8015b1 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	68 cc 33 80 00       	push   $0x8033cc
  8015a5:	6a 21                	push   $0x21
  8015a7:	68 5f 34 80 00       	push   $0x80345f
  8015ac:	e8 b1 f2 ff ff       	call   800862 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  8015b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015b6:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	6a 07                	push   $0x7
  8015bd:	68 00 f0 7f 00       	push   $0x7ff000
  8015c2:	6a 00                	push   $0x0
  8015c4:	e8 02 fd ff ff       	call   8012cb <sys_page_alloc>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	79 14                	jns    8015e4 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	68 6a 34 80 00       	push   $0x80346a
  8015d8:	6a 2b                	push   $0x2b
  8015da:	68 5f 34 80 00       	push   $0x80345f
  8015df:	e8 7e f2 ff ff       	call   800862 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	68 00 10 00 00       	push   $0x1000
  8015ec:	53                   	push   %ebx
  8015ed:	68 00 f0 7f 00       	push   $0x7ff000
  8015f2:	e8 5d fa ff ff       	call   801054 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  8015f7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8015fe:	53                   	push   %ebx
  8015ff:	6a 00                	push   $0x0
  801601:	68 00 f0 7f 00       	push   $0x7ff000
  801606:	6a 00                	push   $0x0
  801608:	e8 01 fd ff ff       	call   80130e <sys_page_map>
  80160d:	83 c4 20             	add    $0x20,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	79 14                	jns    801628 <pgfault+0xcb>
                panic("sys_page_map fails\n");
  801614:	83 ec 04             	sub    $0x4,%esp
  801617:	68 80 34 80 00       	push   $0x803480
  80161c:	6a 2e                	push   $0x2e
  80161e:	68 5f 34 80 00       	push   $0x80345f
  801623:	e8 3a f2 ff ff       	call   800862 <_panic>
        sys_page_unmap(0, PFTEMP); 
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	68 00 f0 7f 00       	push   $0x7ff000
  801630:	6a 00                	push   $0x0
  801632:	e8 19 fd ff ff       	call   801350 <sys_page_unmap>
  801637:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	57                   	push   %edi
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  801648:	68 5d 15 80 00       	push   $0x80155d
  80164d:	e8 87 14 00 00       	call   802ad9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801652:	b8 07 00 00 00       	mov    $0x7,%eax
  801657:	cd 30                	int    $0x30
  801659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	79 12                	jns    801675 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  801663:	50                   	push   %eax
  801664:	68 94 34 80 00       	push   $0x803494
  801669:	6a 6d                	push   $0x6d
  80166b:	68 5f 34 80 00       	push   $0x80345f
  801670:	e8 ed f1 ff ff       	call   800862 <_panic>
  801675:	89 c7                	mov    %eax,%edi
  801677:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  80167c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801680:	75 21                	jne    8016a3 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801682:	e8 06 fc ff ff       	call   80128d <sys_getenvid>
  801687:	25 ff 03 00 00       	and    $0x3ff,%eax
  80168c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80168f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801694:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
  80169e:	e9 9c 01 00 00       	jmp    80183f <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	c1 e8 16             	shr    $0x16,%eax
  8016a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016af:	a8 01                	test   $0x1,%al
  8016b1:	0f 84 f3 00 00 00    	je     8017aa <fork+0x16b>
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	c1 e8 0c             	shr    $0xc,%eax
  8016bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c3:	f6 c2 01             	test   $0x1,%dl
  8016c6:	0f 84 de 00 00 00    	je     8017aa <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  8016cc:	89 c6                	mov    %eax,%esi
  8016ce:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  8016d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d8:	f6 c6 04             	test   $0x4,%dh
  8016db:	74 37                	je     801714 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  8016dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ec:	50                   	push   %eax
  8016ed:	56                   	push   %esi
  8016ee:	57                   	push   %edi
  8016ef:	56                   	push   %esi
  8016f0:	6a 00                	push   $0x0
  8016f2:	e8 17 fc ff ff       	call   80130e <sys_page_map>
  8016f7:	83 c4 20             	add    $0x20,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	0f 89 a8 00 00 00    	jns    8017aa <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801702:	50                   	push   %eax
  801703:	68 f0 33 80 00       	push   $0x8033f0
  801708:	6a 49                	push   $0x49
  80170a:	68 5f 34 80 00       	push   $0x80345f
  80170f:	e8 4e f1 ff ff       	call   800862 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801714:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80171b:	f6 c6 08             	test   $0x8,%dh
  80171e:	75 0b                	jne    80172b <fork+0xec>
  801720:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801727:	a8 02                	test   $0x2,%al
  801729:	74 57                	je     801782 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  80172b:	83 ec 0c             	sub    $0xc,%esp
  80172e:	68 05 08 00 00       	push   $0x805
  801733:	56                   	push   %esi
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	6a 00                	push   $0x0
  801738:	e8 d1 fb ff ff       	call   80130e <sys_page_map>
  80173d:	83 c4 20             	add    $0x20,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	79 12                	jns    801756 <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  801744:	50                   	push   %eax
  801745:	68 f0 33 80 00       	push   $0x8033f0
  80174a:	6a 4c                	push   $0x4c
  80174c:	68 5f 34 80 00       	push   $0x80345f
  801751:	e8 0c f1 ff ff       	call   800862 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	68 05 08 00 00       	push   $0x805
  80175e:	56                   	push   %esi
  80175f:	6a 00                	push   $0x0
  801761:	56                   	push   %esi
  801762:	6a 00                	push   $0x0
  801764:	e8 a5 fb ff ff       	call   80130e <sys_page_map>
  801769:	83 c4 20             	add    $0x20,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	79 3a                	jns    8017aa <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  801770:	50                   	push   %eax
  801771:	68 14 34 80 00       	push   $0x803414
  801776:	6a 4e                	push   $0x4e
  801778:	68 5f 34 80 00       	push   $0x80345f
  80177d:	e8 e0 f0 ff ff       	call   800862 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	6a 05                	push   $0x5
  801787:	56                   	push   %esi
  801788:	57                   	push   %edi
  801789:	56                   	push   %esi
  80178a:	6a 00                	push   $0x0
  80178c:	e8 7d fb ff ff       	call   80130e <sys_page_map>
  801791:	83 c4 20             	add    $0x20,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	79 12                	jns    8017aa <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  801798:	50                   	push   %eax
  801799:	68 3c 34 80 00       	push   $0x80343c
  80179e:	6a 50                	push   $0x50
  8017a0:	68 5f 34 80 00       	push   $0x80345f
  8017a5:	e8 b8 f0 ff ff       	call   800862 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  8017aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8017b0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8017b6:	0f 85 e7 fe ff ff    	jne    8016a3 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8017bc:	83 ec 04             	sub    $0x4,%esp
  8017bf:	6a 07                	push   $0x7
  8017c1:	68 00 f0 bf ee       	push   $0xeebff000
  8017c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c9:	e8 fd fa ff ff       	call   8012cb <sys_page_alloc>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	79 14                	jns    8017e9 <fork+0x1aa>
                panic("user stack alloc failure\n");	
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	68 a4 34 80 00       	push   $0x8034a4
  8017dd:	6a 76                	push   $0x76
  8017df:	68 5f 34 80 00       	push   $0x80345f
  8017e4:	e8 79 f0 ff ff       	call   800862 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	68 48 2b 80 00       	push   $0x802b48
  8017f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017f4:	e8 1d fc ff ff       	call   801416 <sys_env_set_pgfault_upcall>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	79 14                	jns    801814 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801800:	ff 75 e4             	pushl  -0x1c(%ebp)
  801803:	68 be 34 80 00       	push   $0x8034be
  801808:	6a 79                	push   $0x79
  80180a:	68 5f 34 80 00       	push   $0x80345f
  80180f:	e8 4e f0 ff ff       	call   800862 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	6a 02                	push   $0x2
  801819:	ff 75 e4             	pushl  -0x1c(%ebp)
  80181c:	e8 71 fb ff ff       	call   801392 <sys_env_set_status>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	79 14                	jns    80183c <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  801828:	ff 75 e4             	pushl  -0x1c(%ebp)
  80182b:	68 db 34 80 00       	push   $0x8034db
  801830:	6a 7b                	push   $0x7b
  801832:	68 5f 34 80 00       	push   $0x80345f
  801837:	e8 26 f0 ff ff       	call   800862 <_panic>
        return forkid;
  80183c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80183f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <sfork>:

// Challenge!
int
sfork(void)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80184d:	68 f2 34 80 00       	push   $0x8034f2
  801852:	68 83 00 00 00       	push   $0x83
  801857:	68 5f 34 80 00       	push   $0x80345f
  80185c:	e8 01 f0 ff ff       	call   800862 <_panic>

00801861 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	8b 75 08             	mov    0x8(%ebp),%esi
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  80186f:	85 c0                	test   %eax,%eax
  801871:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801876:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	50                   	push   %eax
  80187d:	e8 f9 fb ff ff       	call   80147b <sys_ipc_recv>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	79 16                	jns    80189f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801889:	85 f6                	test   %esi,%esi
  80188b:	74 06                	je     801893 <ipc_recv+0x32>
  80188d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801893:	85 db                	test   %ebx,%ebx
  801895:	74 2c                	je     8018c3 <ipc_recv+0x62>
  801897:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80189d:	eb 24                	jmp    8018c3 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80189f:	85 f6                	test   %esi,%esi
  8018a1:	74 0a                	je     8018ad <ipc_recv+0x4c>
  8018a3:	a1 20 50 80 00       	mov    0x805020,%eax
  8018a8:	8b 40 74             	mov    0x74(%eax),%eax
  8018ab:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8018ad:	85 db                	test   %ebx,%ebx
  8018af:	74 0a                	je     8018bb <ipc_recv+0x5a>
  8018b1:	a1 20 50 80 00       	mov    0x805020,%eax
  8018b6:	8b 40 78             	mov    0x78(%eax),%eax
  8018b9:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8018bb:	a1 20 50 80 00       	mov    0x805020,%eax
  8018c0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	57                   	push   %edi
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 0c             	sub    $0xc,%esp
  8018d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8018dc:	85 db                	test   %ebx,%ebx
  8018de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8018e3:	0f 44 d8             	cmove  %eax,%ebx
  8018e6:	eb 1c                	jmp    801904 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8018e8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018eb:	74 12                	je     8018ff <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8018ed:	50                   	push   %eax
  8018ee:	68 08 35 80 00       	push   $0x803508
  8018f3:	6a 39                	push   $0x39
  8018f5:	68 23 35 80 00       	push   $0x803523
  8018fa:	e8 63 ef ff ff       	call   800862 <_panic>
                 sys_yield();
  8018ff:	e8 a8 f9 ff ff       	call   8012ac <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801904:	ff 75 14             	pushl  0x14(%ebp)
  801907:	53                   	push   %ebx
  801908:	56                   	push   %esi
  801909:	57                   	push   %edi
  80190a:	e8 49 fb ff ff       	call   801458 <sys_ipc_try_send>
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	78 d2                	js     8018e8 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801929:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80192c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801932:	8b 52 50             	mov    0x50(%edx),%edx
  801935:	39 ca                	cmp    %ecx,%edx
  801937:	75 0d                	jne    801946 <ipc_find_env+0x28>
			return envs[i].env_id;
  801939:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80193c:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801941:	8b 40 08             	mov    0x8(%eax),%eax
  801944:	eb 0e                	jmp    801954 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801946:	83 c0 01             	add    $0x1,%eax
  801949:	3d 00 04 00 00       	cmp    $0x400,%eax
  80194e:	75 d9                	jne    801929 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801950:	66 b8 00 00          	mov    $0x0,%ax
}
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	05 00 00 00 30       	add    $0x30000000,%eax
  801961:	c1 e8 0c             	shr    $0xc,%eax
}
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801971:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801976:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801983:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801988:	89 c2                	mov    %eax,%edx
  80198a:	c1 ea 16             	shr    $0x16,%edx
  80198d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801994:	f6 c2 01             	test   $0x1,%dl
  801997:	74 11                	je     8019aa <fd_alloc+0x2d>
  801999:	89 c2                	mov    %eax,%edx
  80199b:	c1 ea 0c             	shr    $0xc,%edx
  80199e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019a5:	f6 c2 01             	test   $0x1,%dl
  8019a8:	75 09                	jne    8019b3 <fd_alloc+0x36>
			*fd_store = fd;
  8019aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	eb 17                	jmp    8019ca <fd_alloc+0x4d>
  8019b3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019b8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019bd:	75 c9                	jne    801988 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019bf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8019c5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019d2:	83 f8 1f             	cmp    $0x1f,%eax
  8019d5:	77 36                	ja     801a0d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019d7:	c1 e0 0c             	shl    $0xc,%eax
  8019da:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8019df:	89 c2                	mov    %eax,%edx
  8019e1:	c1 ea 16             	shr    $0x16,%edx
  8019e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019eb:	f6 c2 01             	test   $0x1,%dl
  8019ee:	74 24                	je     801a14 <fd_lookup+0x48>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	c1 ea 0c             	shr    $0xc,%edx
  8019f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019fc:	f6 c2 01             	test   $0x1,%dl
  8019ff:	74 1a                	je     801a1b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a04:	89 02                	mov    %eax,(%edx)
	return 0;
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0b:	eb 13                	jmp    801a20 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a12:	eb 0c                	jmp    801a20 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a19:	eb 05                	jmp    801a20 <fd_lookup+0x54>
  801a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	eb 13                	jmp    801a45 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801a32:	39 08                	cmp    %ecx,(%eax)
  801a34:	75 0c                	jne    801a42 <dev_lookup+0x20>
			*dev = devtab[i];
  801a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a39:	89 01                	mov    %eax,(%ecx)
			return 0;
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a40:	eb 36                	jmp    801a78 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a42:	83 c2 01             	add    $0x1,%edx
  801a45:	8b 04 95 ac 35 80 00 	mov    0x8035ac(,%edx,4),%eax
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	75 e2                	jne    801a32 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a50:	a1 20 50 80 00       	mov    0x805020,%eax
  801a55:	8b 40 48             	mov    0x48(%eax),%eax
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	51                   	push   %ecx
  801a5c:	50                   	push   %eax
  801a5d:	68 30 35 80 00       	push   $0x803530
  801a62:	e8 d4 ee ff ff       	call   80093b <cprintf>
	*dev = 0;
  801a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 10             	sub    $0x10,%esp
  801a82:	8b 75 08             	mov    0x8(%ebp),%esi
  801a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a8c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801a92:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a95:	50                   	push   %eax
  801a96:	e8 31 ff ff ff       	call   8019cc <fd_lookup>
  801a9b:	83 c4 08             	add    $0x8,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 05                	js     801aa7 <fd_close+0x2d>
	    || fd != fd2)
  801aa2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aa5:	74 0c                	je     801ab3 <fd_close+0x39>
		return (must_exist ? r : 0);
  801aa7:	84 db                	test   %bl,%bl
  801aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aae:	0f 44 c2             	cmove  %edx,%eax
  801ab1:	eb 41                	jmp    801af4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab9:	50                   	push   %eax
  801aba:	ff 36                	pushl  (%esi)
  801abc:	e8 61 ff ff ff       	call   801a22 <dev_lookup>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 1a                	js     801ae4 <fd_close+0x6a>
		if (dev->dev_close)
  801aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ad0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	74 0b                	je     801ae4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	56                   	push   %esi
  801add:	ff d0                	call   *%eax
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	56                   	push   %esi
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 61 f8 ff ff       	call   801350 <sys_page_unmap>
	return r;
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	89 d8                	mov    %ebx,%eax
}
  801af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b04:	50                   	push   %eax
  801b05:	ff 75 08             	pushl  0x8(%ebp)
  801b08:	e8 bf fe ff ff       	call   8019cc <fd_lookup>
  801b0d:	89 c2                	mov    %eax,%edx
  801b0f:	83 c4 08             	add    $0x8,%esp
  801b12:	85 d2                	test   %edx,%edx
  801b14:	78 10                	js     801b26 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	6a 01                	push   $0x1
  801b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1e:	e8 57 ff ff ff       	call   801a7a <fd_close>
  801b23:	83 c4 10             	add    $0x10,%esp
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <close_all>:

void
close_all(void)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	53                   	push   %ebx
  801b38:	e8 be ff ff ff       	call   801afb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b3d:	83 c3 01             	add    $0x1,%ebx
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	83 fb 20             	cmp    $0x20,%ebx
  801b46:	75 ec                	jne    801b34 <close_all+0xc>
		close(i);
}
  801b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	57                   	push   %edi
  801b51:	56                   	push   %esi
  801b52:	53                   	push   %ebx
  801b53:	83 ec 2c             	sub    $0x2c,%esp
  801b56:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	ff 75 08             	pushl  0x8(%ebp)
  801b60:	e8 67 fe ff ff       	call   8019cc <fd_lookup>
  801b65:	89 c2                	mov    %eax,%edx
  801b67:	83 c4 08             	add    $0x8,%esp
  801b6a:	85 d2                	test   %edx,%edx
  801b6c:	0f 88 c1 00 00 00    	js     801c33 <dup+0xe6>
		return r;
	close(newfdnum);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	56                   	push   %esi
  801b76:	e8 80 ff ff ff       	call   801afb <close>

	newfd = INDEX2FD(newfdnum);
  801b7b:	89 f3                	mov    %esi,%ebx
  801b7d:	c1 e3 0c             	shl    $0xc,%ebx
  801b80:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801b86:	83 c4 04             	add    $0x4,%esp
  801b89:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8c:	e8 d5 fd ff ff       	call   801966 <fd2data>
  801b91:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801b93:	89 1c 24             	mov    %ebx,(%esp)
  801b96:	e8 cb fd ff ff       	call   801966 <fd2data>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801ba1:	89 f8                	mov    %edi,%eax
  801ba3:	c1 e8 16             	shr    $0x16,%eax
  801ba6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bad:	a8 01                	test   $0x1,%al
  801baf:	74 37                	je     801be8 <dup+0x9b>
  801bb1:	89 f8                	mov    %edi,%eax
  801bb3:	c1 e8 0c             	shr    $0xc,%eax
  801bb6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bbd:	f6 c2 01             	test   $0x1,%dl
  801bc0:	74 26                	je     801be8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	25 07 0e 00 00       	and    $0xe07,%eax
  801bd1:	50                   	push   %eax
  801bd2:	ff 75 d4             	pushl  -0x2c(%ebp)
  801bd5:	6a 00                	push   $0x0
  801bd7:	57                   	push   %edi
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 2f f7 ff ff       	call   80130e <sys_page_map>
  801bdf:	89 c7                	mov    %eax,%edi
  801be1:	83 c4 20             	add    $0x20,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 2e                	js     801c16 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801be8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801beb:	89 d0                	mov    %edx,%eax
  801bed:	c1 e8 0c             	shr    $0xc,%eax
  801bf0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	25 07 0e 00 00       	and    $0xe07,%eax
  801bff:	50                   	push   %eax
  801c00:	53                   	push   %ebx
  801c01:	6a 00                	push   $0x0
  801c03:	52                   	push   %edx
  801c04:	6a 00                	push   $0x0
  801c06:	e8 03 f7 ff ff       	call   80130e <sys_page_map>
  801c0b:	89 c7                	mov    %eax,%edi
  801c0d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801c10:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c12:	85 ff                	test   %edi,%edi
  801c14:	79 1d                	jns    801c33 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c16:	83 ec 08             	sub    $0x8,%esp
  801c19:	53                   	push   %ebx
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 2f f7 ff ff       	call   801350 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c21:	83 c4 08             	add    $0x8,%esp
  801c24:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c27:	6a 00                	push   $0x0
  801c29:	e8 22 f7 ff ff       	call   801350 <sys_page_unmap>
	return r;
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	89 f8                	mov    %edi,%eax
}
  801c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	53                   	push   %ebx
  801c3f:	83 ec 14             	sub    $0x14,%esp
  801c42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	53                   	push   %ebx
  801c4a:	e8 7d fd ff ff       	call   8019cc <fd_lookup>
  801c4f:	83 c4 08             	add    $0x8,%esp
  801c52:	89 c2                	mov    %eax,%edx
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 6d                	js     801cc5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c62:	ff 30                	pushl  (%eax)
  801c64:	e8 b9 fd ff ff       	call   801a22 <dev_lookup>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 4c                	js     801cbc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c73:	8b 42 08             	mov    0x8(%edx),%eax
  801c76:	83 e0 03             	and    $0x3,%eax
  801c79:	83 f8 01             	cmp    $0x1,%eax
  801c7c:	75 21                	jne    801c9f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c7e:	a1 20 50 80 00       	mov    0x805020,%eax
  801c83:	8b 40 48             	mov    0x48(%eax),%eax
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	53                   	push   %ebx
  801c8a:	50                   	push   %eax
  801c8b:	68 71 35 80 00       	push   $0x803571
  801c90:	e8 a6 ec ff ff       	call   80093b <cprintf>
		return -E_INVAL;
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c9d:	eb 26                	jmp    801cc5 <read+0x8a>
	}
	if (!dev->dev_read)
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	8b 40 08             	mov    0x8(%eax),%eax
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	74 17                	je     801cc0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ca9:	83 ec 04             	sub    $0x4,%esp
  801cac:	ff 75 10             	pushl  0x10(%ebp)
  801caf:	ff 75 0c             	pushl  0xc(%ebp)
  801cb2:	52                   	push   %edx
  801cb3:	ff d0                	call   *%eax
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	eb 09                	jmp    801cc5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cbc:	89 c2                	mov    %eax,%edx
  801cbe:	eb 05                	jmp    801cc5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801cc0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce0:	eb 21                	jmp    801d03 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	29 d8                	sub    %ebx,%eax
  801ce9:	50                   	push   %eax
  801cea:	89 d8                	mov    %ebx,%eax
  801cec:	03 45 0c             	add    0xc(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	57                   	push   %edi
  801cf1:	e8 45 ff ff ff       	call   801c3b <read>
		if (m < 0)
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 0c                	js     801d09 <readn+0x3d>
			return m;
		if (m == 0)
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	74 06                	je     801d07 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d01:	01 c3                	add    %eax,%ebx
  801d03:	39 f3                	cmp    %esi,%ebx
  801d05:	72 db                	jb     801ce2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801d07:	89 d8                	mov    %ebx,%eax
}
  801d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	53                   	push   %ebx
  801d15:	83 ec 14             	sub    $0x14,%esp
  801d18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1e:	50                   	push   %eax
  801d1f:	53                   	push   %ebx
  801d20:	e8 a7 fc ff ff       	call   8019cc <fd_lookup>
  801d25:	83 c4 08             	add    $0x8,%esp
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 68                	js     801d96 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d38:	ff 30                	pushl  (%eax)
  801d3a:	e8 e3 fc ff ff       	call   801a22 <dev_lookup>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 47                	js     801d8d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d49:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d4d:	75 21                	jne    801d70 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d4f:	a1 20 50 80 00       	mov    0x805020,%eax
  801d54:	8b 40 48             	mov    0x48(%eax),%eax
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	53                   	push   %ebx
  801d5b:	50                   	push   %eax
  801d5c:	68 8d 35 80 00       	push   $0x80358d
  801d61:	e8 d5 eb ff ff       	call   80093b <cprintf>
		return -E_INVAL;
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801d6e:	eb 26                	jmp    801d96 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d73:	8b 52 0c             	mov    0xc(%edx),%edx
  801d76:	85 d2                	test   %edx,%edx
  801d78:	74 17                	je     801d91 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	ff 75 10             	pushl  0x10(%ebp)
  801d80:	ff 75 0c             	pushl  0xc(%ebp)
  801d83:	50                   	push   %eax
  801d84:	ff d2                	call   *%edx
  801d86:	89 c2                	mov    %eax,%edx
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	eb 09                	jmp    801d96 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d8d:	89 c2                	mov    %eax,%edx
  801d8f:	eb 05                	jmp    801d96 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801d91:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <seek>:

int
seek(int fdnum, off_t offset)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801da6:	50                   	push   %eax
  801da7:	ff 75 08             	pushl  0x8(%ebp)
  801daa:	e8 1d fc ff ff       	call   8019cc <fd_lookup>
  801daf:	83 c4 08             	add    $0x8,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 0e                	js     801dc4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801db6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	53                   	push   %ebx
  801dca:	83 ec 14             	sub    $0x14,%esp
  801dcd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	53                   	push   %ebx
  801dd5:	e8 f2 fb ff ff       	call   8019cc <fd_lookup>
  801dda:	83 c4 08             	add    $0x8,%esp
  801ddd:	89 c2                	mov    %eax,%edx
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 65                	js     801e48 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ded:	ff 30                	pushl  (%eax)
  801def:	e8 2e fc ff ff       	call   801a22 <dev_lookup>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 44                	js     801e3f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e02:	75 21                	jne    801e25 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e04:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e09:	8b 40 48             	mov    0x48(%eax),%eax
  801e0c:	83 ec 04             	sub    $0x4,%esp
  801e0f:	53                   	push   %ebx
  801e10:	50                   	push   %eax
  801e11:	68 50 35 80 00       	push   $0x803550
  801e16:	e8 20 eb ff ff       	call   80093b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e23:	eb 23                	jmp    801e48 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e28:	8b 52 18             	mov    0x18(%edx),%edx
  801e2b:	85 d2                	test   %edx,%edx
  801e2d:	74 14                	je     801e43 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	ff 75 0c             	pushl  0xc(%ebp)
  801e35:	50                   	push   %eax
  801e36:	ff d2                	call   *%edx
  801e38:	89 c2                	mov    %eax,%edx
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	eb 09                	jmp    801e48 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e3f:	89 c2                	mov    %eax,%edx
  801e41:	eb 05                	jmp    801e48 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801e43:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801e48:	89 d0                	mov    %edx,%eax
  801e4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 14             	sub    $0x14,%esp
  801e56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 67 fb ff ff       	call   8019cc <fd_lookup>
  801e65:	83 c4 08             	add    $0x8,%esp
  801e68:	89 c2                	mov    %eax,%edx
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 58                	js     801ec6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e74:	50                   	push   %eax
  801e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e78:	ff 30                	pushl  (%eax)
  801e7a:	e8 a3 fb ff ff       	call   801a22 <dev_lookup>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 37                	js     801ebd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e89:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e8d:	74 32                	je     801ec1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e8f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e92:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e99:	00 00 00 
	stat->st_isdir = 0;
  801e9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea3:	00 00 00 
	stat->st_dev = dev;
  801ea6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801eac:	83 ec 08             	sub    $0x8,%esp
  801eaf:	53                   	push   %ebx
  801eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb3:	ff 50 14             	call   *0x14(%eax)
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	eb 09                	jmp    801ec6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ebd:	89 c2                	mov    %eax,%edx
  801ebf:	eb 05                	jmp    801ec6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ec1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ec6:	89 d0                	mov    %edx,%eax
  801ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ed2:	83 ec 08             	sub    $0x8,%esp
  801ed5:	6a 00                	push   $0x0
  801ed7:	ff 75 08             	pushl  0x8(%ebp)
  801eda:	e8 09 02 00 00       	call   8020e8 <open>
  801edf:	89 c3                	mov    %eax,%ebx
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 db                	test   %ebx,%ebx
  801ee6:	78 1b                	js     801f03 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ee8:	83 ec 08             	sub    $0x8,%esp
  801eeb:	ff 75 0c             	pushl  0xc(%ebp)
  801eee:	53                   	push   %ebx
  801eef:	e8 5b ff ff ff       	call   801e4f <fstat>
  801ef4:	89 c6                	mov    %eax,%esi
	close(fd);
  801ef6:	89 1c 24             	mov    %ebx,(%esp)
  801ef9:	e8 fd fb ff ff       	call   801afb <close>
	return r;
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	89 f0                	mov    %esi,%eax
}
  801f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f06:	5b                   	pop    %ebx
  801f07:	5e                   	pop    %esi
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	89 c6                	mov    %eax,%esi
  801f11:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801f13:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801f1a:	75 12                	jne    801f2e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	6a 01                	push   $0x1
  801f21:	e8 f8 f9 ff ff       	call   80191e <ipc_find_env>
  801f26:	a3 18 50 80 00       	mov    %eax,0x805018
  801f2b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f2e:	6a 07                	push   $0x7
  801f30:	68 00 60 80 00       	push   $0x806000
  801f35:	56                   	push   %esi
  801f36:	ff 35 18 50 80 00    	pushl  0x805018
  801f3c:	e8 89 f9 ff ff       	call   8018ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f41:	83 c4 0c             	add    $0xc,%esp
  801f44:	6a 00                	push   $0x0
  801f46:	53                   	push   %ebx
  801f47:	6a 00                	push   $0x0
  801f49:	e8 13 f9 ff ff       	call   801861 <ipc_recv>
}
  801f4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f61:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f73:	b8 02 00 00 00       	mov    $0x2,%eax
  801f78:	e8 8d ff ff ff       	call   801f0a <fsipc>
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	8b 40 0c             	mov    0xc(%eax),%eax
  801f8b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f90:	ba 00 00 00 00       	mov    $0x0,%edx
  801f95:	b8 06 00 00 00       	mov    $0x6,%eax
  801f9a:	e8 6b ff ff ff       	call   801f0a <fsipc>
}
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	53                   	push   %ebx
  801fa5:	83 ec 04             	sub    $0x4,%esp
  801fa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb1:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801fb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbb:	b8 05 00 00 00       	mov    $0x5,%eax
  801fc0:	e8 45 ff ff ff       	call   801f0a <fsipc>
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	78 2c                	js     801ff7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fcb:	83 ec 08             	sub    $0x8,%esp
  801fce:	68 00 60 80 00       	push   $0x806000
  801fd3:	53                   	push   %ebx
  801fd4:	e8 e9 ee ff ff       	call   800ec2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fd9:	a1 80 60 80 00       	mov    0x806080,%eax
  801fde:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801fe4:	a1 84 60 80 00       	mov    0x806084,%eax
  801fe9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	83 ec 0c             	sub    $0xc,%esp
  802005:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	8b 40 0c             	mov    0xc(%eax),%eax
  80200e:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  802013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802016:	eb 3d                	jmp    802055 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  802018:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80201e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  802023:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  802026:	83 ec 04             	sub    $0x4,%esp
  802029:	57                   	push   %edi
  80202a:	53                   	push   %ebx
  80202b:	68 08 60 80 00       	push   $0x806008
  802030:	e8 1f f0 ff ff       	call   801054 <memmove>
                fsipcbuf.write.req_n = tmp; 
  802035:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80203b:	ba 00 00 00 00       	mov    $0x0,%edx
  802040:	b8 04 00 00 00       	mov    $0x4,%eax
  802045:	e8 c0 fe ff ff       	call   801f0a <fsipc>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 0d                	js     80205e <devfile_write+0x62>
		        return r;
                n -= tmp;
  802051:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  802053:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802055:	85 f6                	test   %esi,%esi
  802057:	75 bf                	jne    802018 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    

00802066 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	56                   	push   %esi
  80206a:	53                   	push   %ebx
  80206b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
  802071:	8b 40 0c             	mov    0xc(%eax),%eax
  802074:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802079:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80207f:	ba 00 00 00 00       	mov    $0x0,%edx
  802084:	b8 03 00 00 00       	mov    $0x3,%eax
  802089:	e8 7c fe ff ff       	call   801f0a <fsipc>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	85 c0                	test   %eax,%eax
  802092:	78 4b                	js     8020df <devfile_read+0x79>
		return r;
	assert(r <= n);
  802094:	39 c6                	cmp    %eax,%esi
  802096:	73 16                	jae    8020ae <devfile_read+0x48>
  802098:	68 c0 35 80 00       	push   $0x8035c0
  80209d:	68 c7 35 80 00       	push   $0x8035c7
  8020a2:	6a 7c                	push   $0x7c
  8020a4:	68 dc 35 80 00       	push   $0x8035dc
  8020a9:	e8 b4 e7 ff ff       	call   800862 <_panic>
	assert(r <= PGSIZE);
  8020ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020b3:	7e 16                	jle    8020cb <devfile_read+0x65>
  8020b5:	68 e7 35 80 00       	push   $0x8035e7
  8020ba:	68 c7 35 80 00       	push   $0x8035c7
  8020bf:	6a 7d                	push   $0x7d
  8020c1:	68 dc 35 80 00       	push   $0x8035dc
  8020c6:	e8 97 e7 ff ff       	call   800862 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8020cb:	83 ec 04             	sub    $0x4,%esp
  8020ce:	50                   	push   %eax
  8020cf:	68 00 60 80 00       	push   $0x806000
  8020d4:	ff 75 0c             	pushl  0xc(%ebp)
  8020d7:	e8 78 ef ff ff       	call   801054 <memmove>
	return r;
  8020dc:	83 c4 10             	add    $0x10,%esp
}
  8020df:	89 d8                	mov    %ebx,%eax
  8020e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    

008020e8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	53                   	push   %ebx
  8020ec:	83 ec 20             	sub    $0x20,%esp
  8020ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8020f2:	53                   	push   %ebx
  8020f3:	e8 91 ed ff ff       	call   800e89 <strlen>
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802100:	7f 67                	jg     802169 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802108:	50                   	push   %eax
  802109:	e8 6f f8 ff ff       	call   80197d <fd_alloc>
  80210e:	83 c4 10             	add    $0x10,%esp
		return r;
  802111:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802113:	85 c0                	test   %eax,%eax
  802115:	78 57                	js     80216e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802117:	83 ec 08             	sub    $0x8,%esp
  80211a:	53                   	push   %ebx
  80211b:	68 00 60 80 00       	push   $0x806000
  802120:	e8 9d ed ff ff       	call   800ec2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802125:	8b 45 0c             	mov    0xc(%ebp),%eax
  802128:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80212d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802130:	b8 01 00 00 00       	mov    $0x1,%eax
  802135:	e8 d0 fd ff ff       	call   801f0a <fsipc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	79 14                	jns    802157 <open+0x6f>
		fd_close(fd, 0);
  802143:	83 ec 08             	sub    $0x8,%esp
  802146:	6a 00                	push   $0x0
  802148:	ff 75 f4             	pushl  -0xc(%ebp)
  80214b:	e8 2a f9 ff ff       	call   801a7a <fd_close>
		return r;
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	89 da                	mov    %ebx,%edx
  802155:	eb 17                	jmp    80216e <open+0x86>
	}

	return fd2num(fd);
  802157:	83 ec 0c             	sub    $0xc,%esp
  80215a:	ff 75 f4             	pushl  -0xc(%ebp)
  80215d:	e8 f4 f7 ff ff       	call   801956 <fd2num>
  802162:	89 c2                	mov    %eax,%edx
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	eb 05                	jmp    80216e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802169:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80216e:	89 d0                	mov    %edx,%eax
  802170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80217b:	ba 00 00 00 00       	mov    $0x0,%edx
  802180:	b8 08 00 00 00       	mov    $0x8,%eax
  802185:	e8 80 fd ff ff       	call   801f0a <fsipc>
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802192:	68 f3 35 80 00       	push   $0x8035f3
  802197:	ff 75 0c             	pushl  0xc(%ebp)
  80219a:	e8 23 ed ff ff       	call   800ec2 <strcpy>
	return 0;
}
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	53                   	push   %ebx
  8021aa:	83 ec 10             	sub    $0x10,%esp
  8021ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8021b0:	53                   	push   %ebx
  8021b1:	e8 b6 09 00 00       	call   802b6c <pageref>
  8021b6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8021b9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8021be:	83 f8 01             	cmp    $0x1,%eax
  8021c1:	75 10                	jne    8021d3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8021c3:	83 ec 0c             	sub    $0xc,%esp
  8021c6:	ff 73 0c             	pushl  0xc(%ebx)
  8021c9:	e8 ca 02 00 00       	call   802498 <nsipc_close>
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8021d3:	89 d0                	mov    %edx,%eax
  8021d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d8:	c9                   	leave  
  8021d9:	c3                   	ret    

008021da <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8021e0:	6a 00                	push   $0x0
  8021e2:	ff 75 10             	pushl  0x10(%ebp)
  8021e5:	ff 75 0c             	pushl  0xc(%ebp)
  8021e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021eb:	ff 70 0c             	pushl  0xc(%eax)
  8021ee:	e8 82 03 00 00       	call   802575 <nsipc_send>
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    

008021f5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8021fb:	6a 00                	push   $0x0
  8021fd:	ff 75 10             	pushl  0x10(%ebp)
  802200:	ff 75 0c             	pushl  0xc(%ebp)
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	ff 70 0c             	pushl  0xc(%eax)
  802209:	e8 fb 02 00 00       	call   802509 <nsipc_recv>
}
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802216:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802219:	52                   	push   %edx
  80221a:	50                   	push   %eax
  80221b:	e8 ac f7 ff ff       	call   8019cc <fd_lookup>
  802220:	83 c4 10             	add    $0x10,%esp
  802223:	85 c0                	test   %eax,%eax
  802225:	78 17                	js     80223e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802227:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222a:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  802230:	39 08                	cmp    %ecx,(%eax)
  802232:	75 05                	jne    802239 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802234:	8b 40 0c             	mov    0xc(%eax),%eax
  802237:	eb 05                	jmp    80223e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802239:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    

00802240 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	56                   	push   %esi
  802244:	53                   	push   %ebx
  802245:	83 ec 1c             	sub    $0x1c,%esp
  802248:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	50                   	push   %eax
  80224e:	e8 2a f7 ff ff       	call   80197d <fd_alloc>
  802253:	89 c3                	mov    %eax,%ebx
  802255:	83 c4 10             	add    $0x10,%esp
  802258:	85 c0                	test   %eax,%eax
  80225a:	78 1b                	js     802277 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80225c:	83 ec 04             	sub    $0x4,%esp
  80225f:	68 07 04 00 00       	push   $0x407
  802264:	ff 75 f4             	pushl  -0xc(%ebp)
  802267:	6a 00                	push   $0x0
  802269:	e8 5d f0 ff ff       	call   8012cb <sys_page_alloc>
  80226e:	89 c3                	mov    %eax,%ebx
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	85 c0                	test   %eax,%eax
  802275:	79 10                	jns    802287 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802277:	83 ec 0c             	sub    $0xc,%esp
  80227a:	56                   	push   %esi
  80227b:	e8 18 02 00 00       	call   802498 <nsipc_close>
		return r;
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	89 d8                	mov    %ebx,%eax
  802285:	eb 24                	jmp    8022ab <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802287:	8b 15 20 40 80 00    	mov    0x804020,%edx
  80228d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802290:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802295:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  80229c:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80229f:	83 ec 0c             	sub    $0xc,%esp
  8022a2:	52                   	push   %edx
  8022a3:	e8 ae f6 ff ff       	call   801956 <fd2num>
  8022a8:	83 c4 10             	add    $0x10,%esp
}
  8022ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    

008022b2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	e8 50 ff ff ff       	call   802210 <fd2sockid>
		return r;
  8022c0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	78 1f                	js     8022e5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022c6:	83 ec 04             	sub    $0x4,%esp
  8022c9:	ff 75 10             	pushl  0x10(%ebp)
  8022cc:	ff 75 0c             	pushl  0xc(%ebp)
  8022cf:	50                   	push   %eax
  8022d0:	e8 1c 01 00 00       	call   8023f1 <nsipc_accept>
  8022d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022d8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	78 07                	js     8022e5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8022de:	e8 5d ff ff ff       	call   802240 <alloc_sockfd>
  8022e3:	89 c1                	mov    %eax,%ecx
}
  8022e5:	89 c8                	mov    %ecx,%eax
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f2:	e8 19 ff ff ff       	call   802210 <fd2sockid>
  8022f7:	89 c2                	mov    %eax,%edx
  8022f9:	85 d2                	test   %edx,%edx
  8022fb:	78 12                	js     80230f <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8022fd:	83 ec 04             	sub    $0x4,%esp
  802300:	ff 75 10             	pushl  0x10(%ebp)
  802303:	ff 75 0c             	pushl  0xc(%ebp)
  802306:	52                   	push   %edx
  802307:	e8 35 01 00 00       	call   802441 <nsipc_bind>
  80230c:	83 c4 10             	add    $0x10,%esp
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <shutdown>:

int
shutdown(int s, int how)
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802317:	8b 45 08             	mov    0x8(%ebp),%eax
  80231a:	e8 f1 fe ff ff       	call   802210 <fd2sockid>
  80231f:	89 c2                	mov    %eax,%edx
  802321:	85 d2                	test   %edx,%edx
  802323:	78 0f                	js     802334 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802325:	83 ec 08             	sub    $0x8,%esp
  802328:	ff 75 0c             	pushl  0xc(%ebp)
  80232b:	52                   	push   %edx
  80232c:	e8 45 01 00 00       	call   802476 <nsipc_shutdown>
  802331:	83 c4 10             	add    $0x10,%esp
}
  802334:	c9                   	leave  
  802335:	c3                   	ret    

00802336 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80233c:	8b 45 08             	mov    0x8(%ebp),%eax
  80233f:	e8 cc fe ff ff       	call   802210 <fd2sockid>
  802344:	89 c2                	mov    %eax,%edx
  802346:	85 d2                	test   %edx,%edx
  802348:	78 12                	js     80235c <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  80234a:	83 ec 04             	sub    $0x4,%esp
  80234d:	ff 75 10             	pushl  0x10(%ebp)
  802350:	ff 75 0c             	pushl  0xc(%ebp)
  802353:	52                   	push   %edx
  802354:	e8 59 01 00 00       	call   8024b2 <nsipc_connect>
  802359:	83 c4 10             	add    $0x10,%esp
}
  80235c:	c9                   	leave  
  80235d:	c3                   	ret    

0080235e <listen>:

int
listen(int s, int backlog)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802364:	8b 45 08             	mov    0x8(%ebp),%eax
  802367:	e8 a4 fe ff ff       	call   802210 <fd2sockid>
  80236c:	89 c2                	mov    %eax,%edx
  80236e:	85 d2                	test   %edx,%edx
  802370:	78 0f                	js     802381 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802372:	83 ec 08             	sub    $0x8,%esp
  802375:	ff 75 0c             	pushl  0xc(%ebp)
  802378:	52                   	push   %edx
  802379:	e8 69 01 00 00       	call   8024e7 <nsipc_listen>
  80237e:	83 c4 10             	add    $0x10,%esp
}
  802381:	c9                   	leave  
  802382:	c3                   	ret    

00802383 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802389:	ff 75 10             	pushl  0x10(%ebp)
  80238c:	ff 75 0c             	pushl  0xc(%ebp)
  80238f:	ff 75 08             	pushl  0x8(%ebp)
  802392:	e8 3c 02 00 00       	call   8025d3 <nsipc_socket>
  802397:	89 c2                	mov    %eax,%edx
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	85 d2                	test   %edx,%edx
  80239e:	78 05                	js     8023a5 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8023a0:	e8 9b fe ff ff       	call   802240 <alloc_sockfd>
}
  8023a5:	c9                   	leave  
  8023a6:	c3                   	ret    

008023a7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023a7:	55                   	push   %ebp
  8023a8:	89 e5                	mov    %esp,%ebp
  8023aa:	53                   	push   %ebx
  8023ab:	83 ec 04             	sub    $0x4,%esp
  8023ae:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023b0:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8023b7:	75 12                	jne    8023cb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8023b9:	83 ec 0c             	sub    $0xc,%esp
  8023bc:	6a 02                	push   $0x2
  8023be:	e8 5b f5 ff ff       	call   80191e <ipc_find_env>
  8023c3:	a3 1c 50 80 00       	mov    %eax,0x80501c
  8023c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8023cb:	6a 07                	push   $0x7
  8023cd:	68 00 70 80 00       	push   $0x807000
  8023d2:	53                   	push   %ebx
  8023d3:	ff 35 1c 50 80 00    	pushl  0x80501c
  8023d9:	e8 ec f4 ff ff       	call   8018ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8023de:	83 c4 0c             	add    $0xc,%esp
  8023e1:	6a 00                	push   $0x0
  8023e3:	6a 00                	push   $0x0
  8023e5:	6a 00                	push   $0x0
  8023e7:	e8 75 f4 ff ff       	call   801861 <ipc_recv>
}
  8023ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	56                   	push   %esi
  8023f5:	53                   	push   %ebx
  8023f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8023f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802401:	8b 06                	mov    (%esi),%eax
  802403:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802408:	b8 01 00 00 00       	mov    $0x1,%eax
  80240d:	e8 95 ff ff ff       	call   8023a7 <nsipc>
  802412:	89 c3                	mov    %eax,%ebx
  802414:	85 c0                	test   %eax,%eax
  802416:	78 20                	js     802438 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802418:	83 ec 04             	sub    $0x4,%esp
  80241b:	ff 35 10 70 80 00    	pushl  0x807010
  802421:	68 00 70 80 00       	push   $0x807000
  802426:	ff 75 0c             	pushl  0xc(%ebp)
  802429:	e8 26 ec ff ff       	call   801054 <memmove>
		*addrlen = ret->ret_addrlen;
  80242e:	a1 10 70 80 00       	mov    0x807010,%eax
  802433:	89 06                	mov    %eax,(%esi)
  802435:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    

00802441 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	53                   	push   %ebx
  802445:	83 ec 08             	sub    $0x8,%esp
  802448:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802453:	53                   	push   %ebx
  802454:	ff 75 0c             	pushl  0xc(%ebp)
  802457:	68 04 70 80 00       	push   $0x807004
  80245c:	e8 f3 eb ff ff       	call   801054 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802461:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802467:	b8 02 00 00 00       	mov    $0x2,%eax
  80246c:	e8 36 ff ff ff       	call   8023a7 <nsipc>
}
  802471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802474:	c9                   	leave  
  802475:	c3                   	ret    

00802476 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802476:	55                   	push   %ebp
  802477:	89 e5                	mov    %esp,%ebp
  802479:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80247c:	8b 45 08             	mov    0x8(%ebp),%eax
  80247f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802484:	8b 45 0c             	mov    0xc(%ebp),%eax
  802487:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80248c:	b8 03 00 00 00       	mov    $0x3,%eax
  802491:	e8 11 ff ff ff       	call   8023a7 <nsipc>
}
  802496:	c9                   	leave  
  802497:	c3                   	ret    

00802498 <nsipc_close>:

int
nsipc_close(int s)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80249e:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a1:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8024a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8024ab:	e8 f7 fe ff ff       	call   8023a7 <nsipc>
}
  8024b0:	c9                   	leave  
  8024b1:	c3                   	ret    

008024b2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8024b2:	55                   	push   %ebp
  8024b3:	89 e5                	mov    %esp,%ebp
  8024b5:	53                   	push   %ebx
  8024b6:	83 ec 08             	sub    $0x8,%esp
  8024b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8024bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bf:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8024c4:	53                   	push   %ebx
  8024c5:	ff 75 0c             	pushl  0xc(%ebp)
  8024c8:	68 04 70 80 00       	push   $0x807004
  8024cd:	e8 82 eb ff ff       	call   801054 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8024d2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8024d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8024dd:	e8 c5 fe ff ff       	call   8023a7 <nsipc>
}
  8024e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024e5:	c9                   	leave  
  8024e6:	c3                   	ret    

008024e7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8024e7:	55                   	push   %ebp
  8024e8:	89 e5                	mov    %esp,%ebp
  8024ea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8024ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8024f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8024fd:	b8 06 00 00 00       	mov    $0x6,%eax
  802502:	e8 a0 fe ff ff       	call   8023a7 <nsipc>
}
  802507:	c9                   	leave  
  802508:	c3                   	ret    

00802509 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
  80250e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802511:	8b 45 08             	mov    0x8(%ebp),%eax
  802514:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802519:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80251f:	8b 45 14             	mov    0x14(%ebp),%eax
  802522:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802527:	b8 07 00 00 00       	mov    $0x7,%eax
  80252c:	e8 76 fe ff ff       	call   8023a7 <nsipc>
  802531:	89 c3                	mov    %eax,%ebx
  802533:	85 c0                	test   %eax,%eax
  802535:	78 35                	js     80256c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802537:	39 f0                	cmp    %esi,%eax
  802539:	7f 07                	jg     802542 <nsipc_recv+0x39>
  80253b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802540:	7e 16                	jle    802558 <nsipc_recv+0x4f>
  802542:	68 ff 35 80 00       	push   $0x8035ff
  802547:	68 c7 35 80 00       	push   $0x8035c7
  80254c:	6a 62                	push   $0x62
  80254e:	68 14 36 80 00       	push   $0x803614
  802553:	e8 0a e3 ff ff       	call   800862 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802558:	83 ec 04             	sub    $0x4,%esp
  80255b:	50                   	push   %eax
  80255c:	68 00 70 80 00       	push   $0x807000
  802561:	ff 75 0c             	pushl  0xc(%ebp)
  802564:	e8 eb ea ff ff       	call   801054 <memmove>
  802569:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802571:	5b                   	pop    %ebx
  802572:	5e                   	pop    %esi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	53                   	push   %ebx
  802579:	83 ec 04             	sub    $0x4,%esp
  80257c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80257f:	8b 45 08             	mov    0x8(%ebp),%eax
  802582:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802587:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80258d:	7e 16                	jle    8025a5 <nsipc_send+0x30>
  80258f:	68 20 36 80 00       	push   $0x803620
  802594:	68 c7 35 80 00       	push   $0x8035c7
  802599:	6a 6d                	push   $0x6d
  80259b:	68 14 36 80 00       	push   $0x803614
  8025a0:	e8 bd e2 ff ff       	call   800862 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8025a5:	83 ec 04             	sub    $0x4,%esp
  8025a8:	53                   	push   %ebx
  8025a9:	ff 75 0c             	pushl  0xc(%ebp)
  8025ac:	68 0c 70 80 00       	push   $0x80700c
  8025b1:	e8 9e ea ff ff       	call   801054 <memmove>
	nsipcbuf.send.req_size = size;
  8025b6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8025bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8025bf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8025c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8025c9:	e8 d9 fd ff ff       	call   8023a7 <nsipc>
}
  8025ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025d1:	c9                   	leave  
  8025d2:	c3                   	ret    

008025d3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8025d3:	55                   	push   %ebp
  8025d4:	89 e5                	mov    %esp,%ebp
  8025d6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8025d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025dc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8025e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025e4:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8025e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8025ec:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8025f1:	b8 09 00 00 00       	mov    $0x9,%eax
  8025f6:	e8 ac fd ff ff       	call   8023a7 <nsipc>
}
  8025fb:	c9                   	leave  
  8025fc:	c3                   	ret    

008025fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8025fd:	55                   	push   %ebp
  8025fe:	89 e5                	mov    %esp,%ebp
  802600:	56                   	push   %esi
  802601:	53                   	push   %ebx
  802602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802605:	83 ec 0c             	sub    $0xc,%esp
  802608:	ff 75 08             	pushl  0x8(%ebp)
  80260b:	e8 56 f3 ff ff       	call   801966 <fd2data>
  802610:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802612:	83 c4 08             	add    $0x8,%esp
  802615:	68 2c 36 80 00       	push   $0x80362c
  80261a:	53                   	push   %ebx
  80261b:	e8 a2 e8 ff ff       	call   800ec2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802620:	8b 56 04             	mov    0x4(%esi),%edx
  802623:	89 d0                	mov    %edx,%eax
  802625:	2b 06                	sub    (%esi),%eax
  802627:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80262d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802634:	00 00 00 
	stat->st_dev = &devpipe;
  802637:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80263e:	40 80 00 
	return 0;
}
  802641:	b8 00 00 00 00       	mov    $0x0,%eax
  802646:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802649:	5b                   	pop    %ebx
  80264a:	5e                   	pop    %esi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    

0080264d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	53                   	push   %ebx
  802651:	83 ec 0c             	sub    $0xc,%esp
  802654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802657:	53                   	push   %ebx
  802658:	6a 00                	push   $0x0
  80265a:	e8 f1 ec ff ff       	call   801350 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80265f:	89 1c 24             	mov    %ebx,(%esp)
  802662:	e8 ff f2 ff ff       	call   801966 <fd2data>
  802667:	83 c4 08             	add    $0x8,%esp
  80266a:	50                   	push   %eax
  80266b:	6a 00                	push   $0x0
  80266d:	e8 de ec ff ff       	call   801350 <sys_page_unmap>
}
  802672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802675:	c9                   	leave  
  802676:	c3                   	ret    

00802677 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802677:	55                   	push   %ebp
  802678:	89 e5                	mov    %esp,%ebp
  80267a:	57                   	push   %edi
  80267b:	56                   	push   %esi
  80267c:	53                   	push   %ebx
  80267d:	83 ec 1c             	sub    $0x1c,%esp
  802680:	89 c6                	mov    %eax,%esi
  802682:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802685:	a1 20 50 80 00       	mov    0x805020,%eax
  80268a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80268d:	83 ec 0c             	sub    $0xc,%esp
  802690:	56                   	push   %esi
  802691:	e8 d6 04 00 00       	call   802b6c <pageref>
  802696:	89 c7                	mov    %eax,%edi
  802698:	83 c4 04             	add    $0x4,%esp
  80269b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80269e:	e8 c9 04 00 00       	call   802b6c <pageref>
  8026a3:	83 c4 10             	add    $0x10,%esp
  8026a6:	39 c7                	cmp    %eax,%edi
  8026a8:	0f 94 c2             	sete   %dl
  8026ab:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8026ae:	8b 0d 20 50 80 00    	mov    0x805020,%ecx
  8026b4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8026b7:	39 fb                	cmp    %edi,%ebx
  8026b9:	74 19                	je     8026d4 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8026bb:	84 d2                	test   %dl,%dl
  8026bd:	74 c6                	je     802685 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8026bf:	8b 51 58             	mov    0x58(%ecx),%edx
  8026c2:	50                   	push   %eax
  8026c3:	52                   	push   %edx
  8026c4:	53                   	push   %ebx
  8026c5:	68 33 36 80 00       	push   $0x803633
  8026ca:	e8 6c e2 ff ff       	call   80093b <cprintf>
  8026cf:	83 c4 10             	add    $0x10,%esp
  8026d2:	eb b1                	jmp    802685 <_pipeisclosed+0xe>
	}
}
  8026d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    

008026dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026dc:	55                   	push   %ebp
  8026dd:	89 e5                	mov    %esp,%ebp
  8026df:	57                   	push   %edi
  8026e0:	56                   	push   %esi
  8026e1:	53                   	push   %ebx
  8026e2:	83 ec 28             	sub    $0x28,%esp
  8026e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8026e8:	56                   	push   %esi
  8026e9:	e8 78 f2 ff ff       	call   801966 <fd2data>
  8026ee:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026f0:	83 c4 10             	add    $0x10,%esp
  8026f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8026f8:	eb 4b                	jmp    802745 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8026fa:	89 da                	mov    %ebx,%edx
  8026fc:	89 f0                	mov    %esi,%eax
  8026fe:	e8 74 ff ff ff       	call   802677 <_pipeisclosed>
  802703:	85 c0                	test   %eax,%eax
  802705:	75 48                	jne    80274f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802707:	e8 a0 eb ff ff       	call   8012ac <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80270c:	8b 43 04             	mov    0x4(%ebx),%eax
  80270f:	8b 0b                	mov    (%ebx),%ecx
  802711:	8d 51 20             	lea    0x20(%ecx),%edx
  802714:	39 d0                	cmp    %edx,%eax
  802716:	73 e2                	jae    8026fa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80271b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80271f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802722:	89 c2                	mov    %eax,%edx
  802724:	c1 fa 1f             	sar    $0x1f,%edx
  802727:	89 d1                	mov    %edx,%ecx
  802729:	c1 e9 1b             	shr    $0x1b,%ecx
  80272c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80272f:	83 e2 1f             	and    $0x1f,%edx
  802732:	29 ca                	sub    %ecx,%edx
  802734:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802738:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80273c:	83 c0 01             	add    $0x1,%eax
  80273f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802742:	83 c7 01             	add    $0x1,%edi
  802745:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802748:	75 c2                	jne    80270c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80274a:	8b 45 10             	mov    0x10(%ebp),%eax
  80274d:	eb 05                	jmp    802754 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80274f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    

0080275c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
  80275f:	57                   	push   %edi
  802760:	56                   	push   %esi
  802761:	53                   	push   %ebx
  802762:	83 ec 18             	sub    $0x18,%esp
  802765:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802768:	57                   	push   %edi
  802769:	e8 f8 f1 ff ff       	call   801966 <fd2data>
  80276e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802770:	83 c4 10             	add    $0x10,%esp
  802773:	bb 00 00 00 00       	mov    $0x0,%ebx
  802778:	eb 3d                	jmp    8027b7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80277a:	85 db                	test   %ebx,%ebx
  80277c:	74 04                	je     802782 <devpipe_read+0x26>
				return i;
  80277e:	89 d8                	mov    %ebx,%eax
  802780:	eb 44                	jmp    8027c6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802782:	89 f2                	mov    %esi,%edx
  802784:	89 f8                	mov    %edi,%eax
  802786:	e8 ec fe ff ff       	call   802677 <_pipeisclosed>
  80278b:	85 c0                	test   %eax,%eax
  80278d:	75 32                	jne    8027c1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80278f:	e8 18 eb ff ff       	call   8012ac <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802794:	8b 06                	mov    (%esi),%eax
  802796:	3b 46 04             	cmp    0x4(%esi),%eax
  802799:	74 df                	je     80277a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80279b:	99                   	cltd   
  80279c:	c1 ea 1b             	shr    $0x1b,%edx
  80279f:	01 d0                	add    %edx,%eax
  8027a1:	83 e0 1f             	and    $0x1f,%eax
  8027a4:	29 d0                	sub    %edx,%eax
  8027a6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8027ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027ae:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8027b1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027b4:	83 c3 01             	add    $0x1,%ebx
  8027b7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8027ba:	75 d8                	jne    802794 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8027bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8027bf:	eb 05                	jmp    8027c6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8027c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c9:	5b                   	pop    %ebx
  8027ca:	5e                   	pop    %esi
  8027cb:	5f                   	pop    %edi
  8027cc:	5d                   	pop    %ebp
  8027cd:	c3                   	ret    

008027ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8027ce:	55                   	push   %ebp
  8027cf:	89 e5                	mov    %esp,%ebp
  8027d1:	56                   	push   %esi
  8027d2:	53                   	push   %ebx
  8027d3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8027d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027d9:	50                   	push   %eax
  8027da:	e8 9e f1 ff ff       	call   80197d <fd_alloc>
  8027df:	83 c4 10             	add    $0x10,%esp
  8027e2:	89 c2                	mov    %eax,%edx
  8027e4:	85 c0                	test   %eax,%eax
  8027e6:	0f 88 2c 01 00 00    	js     802918 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027ec:	83 ec 04             	sub    $0x4,%esp
  8027ef:	68 07 04 00 00       	push   $0x407
  8027f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8027f7:	6a 00                	push   $0x0
  8027f9:	e8 cd ea ff ff       	call   8012cb <sys_page_alloc>
  8027fe:	83 c4 10             	add    $0x10,%esp
  802801:	89 c2                	mov    %eax,%edx
  802803:	85 c0                	test   %eax,%eax
  802805:	0f 88 0d 01 00 00    	js     802918 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80280b:	83 ec 0c             	sub    $0xc,%esp
  80280e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802811:	50                   	push   %eax
  802812:	e8 66 f1 ff ff       	call   80197d <fd_alloc>
  802817:	89 c3                	mov    %eax,%ebx
  802819:	83 c4 10             	add    $0x10,%esp
  80281c:	85 c0                	test   %eax,%eax
  80281e:	0f 88 e2 00 00 00    	js     802906 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802824:	83 ec 04             	sub    $0x4,%esp
  802827:	68 07 04 00 00       	push   $0x407
  80282c:	ff 75 f0             	pushl  -0x10(%ebp)
  80282f:	6a 00                	push   $0x0
  802831:	e8 95 ea ff ff       	call   8012cb <sys_page_alloc>
  802836:	89 c3                	mov    %eax,%ebx
  802838:	83 c4 10             	add    $0x10,%esp
  80283b:	85 c0                	test   %eax,%eax
  80283d:	0f 88 c3 00 00 00    	js     802906 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802843:	83 ec 0c             	sub    $0xc,%esp
  802846:	ff 75 f4             	pushl  -0xc(%ebp)
  802849:	e8 18 f1 ff ff       	call   801966 <fd2data>
  80284e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802850:	83 c4 0c             	add    $0xc,%esp
  802853:	68 07 04 00 00       	push   $0x407
  802858:	50                   	push   %eax
  802859:	6a 00                	push   $0x0
  80285b:	e8 6b ea ff ff       	call   8012cb <sys_page_alloc>
  802860:	89 c3                	mov    %eax,%ebx
  802862:	83 c4 10             	add    $0x10,%esp
  802865:	85 c0                	test   %eax,%eax
  802867:	0f 88 89 00 00 00    	js     8028f6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80286d:	83 ec 0c             	sub    $0xc,%esp
  802870:	ff 75 f0             	pushl  -0x10(%ebp)
  802873:	e8 ee f0 ff ff       	call   801966 <fd2data>
  802878:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80287f:	50                   	push   %eax
  802880:	6a 00                	push   $0x0
  802882:	56                   	push   %esi
  802883:	6a 00                	push   $0x0
  802885:	e8 84 ea ff ff       	call   80130e <sys_page_map>
  80288a:	89 c3                	mov    %eax,%ebx
  80288c:	83 c4 20             	add    $0x20,%esp
  80288f:	85 c0                	test   %eax,%eax
  802891:	78 55                	js     8028e8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802893:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80289c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80289e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8028a8:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8028ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028b1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8028b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8028bd:	83 ec 0c             	sub    $0xc,%esp
  8028c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8028c3:	e8 8e f0 ff ff       	call   801956 <fd2num>
  8028c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028cb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8028cd:	83 c4 04             	add    $0x4,%esp
  8028d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8028d3:	e8 7e f0 ff ff       	call   801956 <fd2num>
  8028d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028db:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8028de:	83 c4 10             	add    $0x10,%esp
  8028e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8028e6:	eb 30                	jmp    802918 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8028e8:	83 ec 08             	sub    $0x8,%esp
  8028eb:	56                   	push   %esi
  8028ec:	6a 00                	push   $0x0
  8028ee:	e8 5d ea ff ff       	call   801350 <sys_page_unmap>
  8028f3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8028f6:	83 ec 08             	sub    $0x8,%esp
  8028f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8028fc:	6a 00                	push   $0x0
  8028fe:	e8 4d ea ff ff       	call   801350 <sys_page_unmap>
  802903:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802906:	83 ec 08             	sub    $0x8,%esp
  802909:	ff 75 f4             	pushl  -0xc(%ebp)
  80290c:	6a 00                	push   $0x0
  80290e:	e8 3d ea ff ff       	call   801350 <sys_page_unmap>
  802913:	83 c4 10             	add    $0x10,%esp
  802916:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802918:	89 d0                	mov    %edx,%eax
  80291a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80291d:	5b                   	pop    %ebx
  80291e:	5e                   	pop    %esi
  80291f:	5d                   	pop    %ebp
  802920:	c3                   	ret    

00802921 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802921:	55                   	push   %ebp
  802922:	89 e5                	mov    %esp,%ebp
  802924:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80292a:	50                   	push   %eax
  80292b:	ff 75 08             	pushl  0x8(%ebp)
  80292e:	e8 99 f0 ff ff       	call   8019cc <fd_lookup>
  802933:	89 c2                	mov    %eax,%edx
  802935:	83 c4 10             	add    $0x10,%esp
  802938:	85 d2                	test   %edx,%edx
  80293a:	78 18                	js     802954 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80293c:	83 ec 0c             	sub    $0xc,%esp
  80293f:	ff 75 f4             	pushl  -0xc(%ebp)
  802942:	e8 1f f0 ff ff       	call   801966 <fd2data>
	return _pipeisclosed(fd, p);
  802947:	89 c2                	mov    %eax,%edx
  802949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80294c:	e8 26 fd ff ff       	call   802677 <_pipeisclosed>
  802951:	83 c4 10             	add    $0x10,%esp
}
  802954:	c9                   	leave  
  802955:	c3                   	ret    

00802956 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802956:	55                   	push   %ebp
  802957:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802959:	b8 00 00 00 00       	mov    $0x0,%eax
  80295e:	5d                   	pop    %ebp
  80295f:	c3                   	ret    

00802960 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802966:	68 4b 36 80 00       	push   $0x80364b
  80296b:	ff 75 0c             	pushl  0xc(%ebp)
  80296e:	e8 4f e5 ff ff       	call   800ec2 <strcpy>
	return 0;
}
  802973:	b8 00 00 00 00       	mov    $0x0,%eax
  802978:	c9                   	leave  
  802979:	c3                   	ret    

0080297a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80297a:	55                   	push   %ebp
  80297b:	89 e5                	mov    %esp,%ebp
  80297d:	57                   	push   %edi
  80297e:	56                   	push   %esi
  80297f:	53                   	push   %ebx
  802980:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802986:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80298b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802991:	eb 2d                	jmp    8029c0 <devcons_write+0x46>
		m = n - tot;
  802993:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802996:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802998:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80299b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8029a0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8029a3:	83 ec 04             	sub    $0x4,%esp
  8029a6:	53                   	push   %ebx
  8029a7:	03 45 0c             	add    0xc(%ebp),%eax
  8029aa:	50                   	push   %eax
  8029ab:	57                   	push   %edi
  8029ac:	e8 a3 e6 ff ff       	call   801054 <memmove>
		sys_cputs(buf, m);
  8029b1:	83 c4 08             	add    $0x8,%esp
  8029b4:	53                   	push   %ebx
  8029b5:	57                   	push   %edi
  8029b6:	e8 54 e8 ff ff       	call   80120f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8029bb:	01 de                	add    %ebx,%esi
  8029bd:	83 c4 10             	add    $0x10,%esp
  8029c0:	89 f0                	mov    %esi,%eax
  8029c2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8029c5:	72 cc                	jb     802993 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8029c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029ca:	5b                   	pop    %ebx
  8029cb:	5e                   	pop    %esi
  8029cc:	5f                   	pop    %edi
  8029cd:	5d                   	pop    %ebp
  8029ce:	c3                   	ret    

008029cf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8029cf:	55                   	push   %ebp
  8029d0:	89 e5                	mov    %esp,%ebp
  8029d2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8029d5:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8029da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8029de:	75 07                	jne    8029e7 <devcons_read+0x18>
  8029e0:	eb 28                	jmp    802a0a <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8029e2:	e8 c5 e8 ff ff       	call   8012ac <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8029e7:	e8 41 e8 ff ff       	call   80122d <sys_cgetc>
  8029ec:	85 c0                	test   %eax,%eax
  8029ee:	74 f2                	je     8029e2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8029f0:	85 c0                	test   %eax,%eax
  8029f2:	78 16                	js     802a0a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8029f4:	83 f8 04             	cmp    $0x4,%eax
  8029f7:	74 0c                	je     802a05 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8029f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029fc:	88 02                	mov    %al,(%edx)
	return 1;
  8029fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802a03:	eb 05                	jmp    802a0a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802a05:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802a0a:	c9                   	leave  
  802a0b:	c3                   	ret    

00802a0c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802a0c:	55                   	push   %ebp
  802a0d:	89 e5                	mov    %esp,%ebp
  802a0f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802a12:	8b 45 08             	mov    0x8(%ebp),%eax
  802a15:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802a18:	6a 01                	push   $0x1
  802a1a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802a1d:	50                   	push   %eax
  802a1e:	e8 ec e7 ff ff       	call   80120f <sys_cputs>
  802a23:	83 c4 10             	add    $0x10,%esp
}
  802a26:	c9                   	leave  
  802a27:	c3                   	ret    

00802a28 <getchar>:

int
getchar(void)
{
  802a28:	55                   	push   %ebp
  802a29:	89 e5                	mov    %esp,%ebp
  802a2b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802a2e:	6a 01                	push   $0x1
  802a30:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802a33:	50                   	push   %eax
  802a34:	6a 00                	push   $0x0
  802a36:	e8 00 f2 ff ff       	call   801c3b <read>
	if (r < 0)
  802a3b:	83 c4 10             	add    $0x10,%esp
  802a3e:	85 c0                	test   %eax,%eax
  802a40:	78 0f                	js     802a51 <getchar+0x29>
		return r;
	if (r < 1)
  802a42:	85 c0                	test   %eax,%eax
  802a44:	7e 06                	jle    802a4c <getchar+0x24>
		return -E_EOF;
	return c;
  802a46:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802a4a:	eb 05                	jmp    802a51 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802a4c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802a51:	c9                   	leave  
  802a52:	c3                   	ret    

00802a53 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802a53:	55                   	push   %ebp
  802a54:	89 e5                	mov    %esp,%ebp
  802a56:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a5c:	50                   	push   %eax
  802a5d:	ff 75 08             	pushl  0x8(%ebp)
  802a60:	e8 67 ef ff ff       	call   8019cc <fd_lookup>
  802a65:	83 c4 10             	add    $0x10,%esp
  802a68:	85 c0                	test   %eax,%eax
  802a6a:	78 11                	js     802a7d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a6f:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802a75:	39 10                	cmp    %edx,(%eax)
  802a77:	0f 94 c0             	sete   %al
  802a7a:	0f b6 c0             	movzbl %al,%eax
}
  802a7d:	c9                   	leave  
  802a7e:	c3                   	ret    

00802a7f <opencons>:

int
opencons(void)
{
  802a7f:	55                   	push   %ebp
  802a80:	89 e5                	mov    %esp,%ebp
  802a82:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a88:	50                   	push   %eax
  802a89:	e8 ef ee ff ff       	call   80197d <fd_alloc>
  802a8e:	83 c4 10             	add    $0x10,%esp
		return r;
  802a91:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802a93:	85 c0                	test   %eax,%eax
  802a95:	78 3e                	js     802ad5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802a97:	83 ec 04             	sub    $0x4,%esp
  802a9a:	68 07 04 00 00       	push   $0x407
  802a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  802aa2:	6a 00                	push   $0x0
  802aa4:	e8 22 e8 ff ff       	call   8012cb <sys_page_alloc>
  802aa9:	83 c4 10             	add    $0x10,%esp
		return r;
  802aac:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802aae:	85 c0                	test   %eax,%eax
  802ab0:	78 23                	js     802ad5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802ab2:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802abb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ac0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802ac7:	83 ec 0c             	sub    $0xc,%esp
  802aca:	50                   	push   %eax
  802acb:	e8 86 ee ff ff       	call   801956 <fd2num>
  802ad0:	89 c2                	mov    %eax,%edx
  802ad2:	83 c4 10             	add    $0x10,%esp
}
  802ad5:	89 d0                	mov    %edx,%eax
  802ad7:	c9                   	leave  
  802ad8:	c3                   	ret    

00802ad9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ad9:	55                   	push   %ebp
  802ada:	89 e5                	mov    %esp,%ebp
  802adc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802adf:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802ae6:	75 2c                	jne    802b14 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  802ae8:	83 ec 04             	sub    $0x4,%esp
  802aeb:	6a 07                	push   $0x7
  802aed:	68 00 f0 bf ee       	push   $0xeebff000
  802af2:	6a 00                	push   $0x0
  802af4:	e8 d2 e7 ff ff       	call   8012cb <sys_page_alloc>
  802af9:	83 c4 10             	add    $0x10,%esp
  802afc:	85 c0                	test   %eax,%eax
  802afe:	74 14                	je     802b14 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802b00:	83 ec 04             	sub    $0x4,%esp
  802b03:	68 58 36 80 00       	push   $0x803658
  802b08:	6a 21                	push   $0x21
  802b0a:	68 bc 36 80 00       	push   $0x8036bc
  802b0f:	e8 4e dd ff ff       	call   800862 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b14:	8b 45 08             	mov    0x8(%ebp),%eax
  802b17:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802b1c:	83 ec 08             	sub    $0x8,%esp
  802b1f:	68 48 2b 80 00       	push   $0x802b48
  802b24:	6a 00                	push   $0x0
  802b26:	e8 eb e8 ff ff       	call   801416 <sys_env_set_pgfault_upcall>
  802b2b:	83 c4 10             	add    $0x10,%esp
  802b2e:	85 c0                	test   %eax,%eax
  802b30:	79 14                	jns    802b46 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802b32:	83 ec 04             	sub    $0x4,%esp
  802b35:	68 84 36 80 00       	push   $0x803684
  802b3a:	6a 29                	push   $0x29
  802b3c:	68 bc 36 80 00       	push   $0x8036bc
  802b41:	e8 1c dd ff ff       	call   800862 <_panic>
}
  802b46:	c9                   	leave  
  802b47:	c3                   	ret    

00802b48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b49:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b50:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  802b53:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802b58:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802b5c:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  802b60:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  802b62:	83 c4 08             	add    $0x8,%esp
        popal
  802b65:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802b66:	83 c4 04             	add    $0x4,%esp
        popfl
  802b69:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802b6a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802b6b:	c3                   	ret    

00802b6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b6c:	55                   	push   %ebp
  802b6d:	89 e5                	mov    %esp,%ebp
  802b6f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b72:	89 d0                	mov    %edx,%eax
  802b74:	c1 e8 16             	shr    $0x16,%eax
  802b77:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b7e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b83:	f6 c1 01             	test   $0x1,%cl
  802b86:	74 1d                	je     802ba5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b88:	c1 ea 0c             	shr    $0xc,%edx
  802b8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802b92:	f6 c2 01             	test   $0x1,%dl
  802b95:	74 0e                	je     802ba5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b97:	c1 ea 0c             	shr    $0xc,%edx
  802b9a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ba1:	ef 
  802ba2:	0f b7 c0             	movzwl %ax,%eax
}
  802ba5:	5d                   	pop    %ebp
  802ba6:	c3                   	ret    
  802ba7:	66 90                	xchg   %ax,%ax
  802ba9:	66 90                	xchg   %ax,%ax
  802bab:	66 90                	xchg   %ax,%ax
  802bad:	66 90                	xchg   %ax,%ax
  802baf:	90                   	nop

00802bb0 <__udivdi3>:
  802bb0:	55                   	push   %ebp
  802bb1:	57                   	push   %edi
  802bb2:	56                   	push   %esi
  802bb3:	83 ec 10             	sub    $0x10,%esp
  802bb6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  802bba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  802bbe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802bc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802bc6:	85 d2                	test   %edx,%edx
  802bc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802bcc:	89 34 24             	mov    %esi,(%esp)
  802bcf:	89 c8                	mov    %ecx,%eax
  802bd1:	75 35                	jne    802c08 <__udivdi3+0x58>
  802bd3:	39 f1                	cmp    %esi,%ecx
  802bd5:	0f 87 bd 00 00 00    	ja     802c98 <__udivdi3+0xe8>
  802bdb:	85 c9                	test   %ecx,%ecx
  802bdd:	89 cd                	mov    %ecx,%ebp
  802bdf:	75 0b                	jne    802bec <__udivdi3+0x3c>
  802be1:	b8 01 00 00 00       	mov    $0x1,%eax
  802be6:	31 d2                	xor    %edx,%edx
  802be8:	f7 f1                	div    %ecx
  802bea:	89 c5                	mov    %eax,%ebp
  802bec:	89 f0                	mov    %esi,%eax
  802bee:	31 d2                	xor    %edx,%edx
  802bf0:	f7 f5                	div    %ebp
  802bf2:	89 c6                	mov    %eax,%esi
  802bf4:	89 f8                	mov    %edi,%eax
  802bf6:	f7 f5                	div    %ebp
  802bf8:	89 f2                	mov    %esi,%edx
  802bfa:	83 c4 10             	add    $0x10,%esp
  802bfd:	5e                   	pop    %esi
  802bfe:	5f                   	pop    %edi
  802bff:	5d                   	pop    %ebp
  802c00:	c3                   	ret    
  802c01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c08:	3b 14 24             	cmp    (%esp),%edx
  802c0b:	77 7b                	ja     802c88 <__udivdi3+0xd8>
  802c0d:	0f bd f2             	bsr    %edx,%esi
  802c10:	83 f6 1f             	xor    $0x1f,%esi
  802c13:	0f 84 97 00 00 00    	je     802cb0 <__udivdi3+0x100>
  802c19:	bd 20 00 00 00       	mov    $0x20,%ebp
  802c1e:	89 d7                	mov    %edx,%edi
  802c20:	89 f1                	mov    %esi,%ecx
  802c22:	29 f5                	sub    %esi,%ebp
  802c24:	d3 e7                	shl    %cl,%edi
  802c26:	89 c2                	mov    %eax,%edx
  802c28:	89 e9                	mov    %ebp,%ecx
  802c2a:	d3 ea                	shr    %cl,%edx
  802c2c:	89 f1                	mov    %esi,%ecx
  802c2e:	09 fa                	or     %edi,%edx
  802c30:	8b 3c 24             	mov    (%esp),%edi
  802c33:	d3 e0                	shl    %cl,%eax
  802c35:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c39:	89 e9                	mov    %ebp,%ecx
  802c3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c3f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c43:	89 fa                	mov    %edi,%edx
  802c45:	d3 ea                	shr    %cl,%edx
  802c47:	89 f1                	mov    %esi,%ecx
  802c49:	d3 e7                	shl    %cl,%edi
  802c4b:	89 e9                	mov    %ebp,%ecx
  802c4d:	d3 e8                	shr    %cl,%eax
  802c4f:	09 c7                	or     %eax,%edi
  802c51:	89 f8                	mov    %edi,%eax
  802c53:	f7 74 24 08          	divl   0x8(%esp)
  802c57:	89 d5                	mov    %edx,%ebp
  802c59:	89 c7                	mov    %eax,%edi
  802c5b:	f7 64 24 0c          	mull   0xc(%esp)
  802c5f:	39 d5                	cmp    %edx,%ebp
  802c61:	89 14 24             	mov    %edx,(%esp)
  802c64:	72 11                	jb     802c77 <__udivdi3+0xc7>
  802c66:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c6a:	89 f1                	mov    %esi,%ecx
  802c6c:	d3 e2                	shl    %cl,%edx
  802c6e:	39 c2                	cmp    %eax,%edx
  802c70:	73 5e                	jae    802cd0 <__udivdi3+0x120>
  802c72:	3b 2c 24             	cmp    (%esp),%ebp
  802c75:	75 59                	jne    802cd0 <__udivdi3+0x120>
  802c77:	8d 47 ff             	lea    -0x1(%edi),%eax
  802c7a:	31 f6                	xor    %esi,%esi
  802c7c:	89 f2                	mov    %esi,%edx
  802c7e:	83 c4 10             	add    $0x10,%esp
  802c81:	5e                   	pop    %esi
  802c82:	5f                   	pop    %edi
  802c83:	5d                   	pop    %ebp
  802c84:	c3                   	ret    
  802c85:	8d 76 00             	lea    0x0(%esi),%esi
  802c88:	31 f6                	xor    %esi,%esi
  802c8a:	31 c0                	xor    %eax,%eax
  802c8c:	89 f2                	mov    %esi,%edx
  802c8e:	83 c4 10             	add    $0x10,%esp
  802c91:	5e                   	pop    %esi
  802c92:	5f                   	pop    %edi
  802c93:	5d                   	pop    %ebp
  802c94:	c3                   	ret    
  802c95:	8d 76 00             	lea    0x0(%esi),%esi
  802c98:	89 f2                	mov    %esi,%edx
  802c9a:	31 f6                	xor    %esi,%esi
  802c9c:	89 f8                	mov    %edi,%eax
  802c9e:	f7 f1                	div    %ecx
  802ca0:	89 f2                	mov    %esi,%edx
  802ca2:	83 c4 10             	add    $0x10,%esp
  802ca5:	5e                   	pop    %esi
  802ca6:	5f                   	pop    %edi
  802ca7:	5d                   	pop    %ebp
  802ca8:	c3                   	ret    
  802ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cb0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802cb4:	76 0b                	jbe    802cc1 <__udivdi3+0x111>
  802cb6:	31 c0                	xor    %eax,%eax
  802cb8:	3b 14 24             	cmp    (%esp),%edx
  802cbb:	0f 83 37 ff ff ff    	jae    802bf8 <__udivdi3+0x48>
  802cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  802cc6:	e9 2d ff ff ff       	jmp    802bf8 <__udivdi3+0x48>
  802ccb:	90                   	nop
  802ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	89 f8                	mov    %edi,%eax
  802cd2:	31 f6                	xor    %esi,%esi
  802cd4:	e9 1f ff ff ff       	jmp    802bf8 <__udivdi3+0x48>
  802cd9:	66 90                	xchg   %ax,%ax
  802cdb:	66 90                	xchg   %ax,%ax
  802cdd:	66 90                	xchg   %ax,%ax
  802cdf:	90                   	nop

00802ce0 <__umoddi3>:
  802ce0:	55                   	push   %ebp
  802ce1:	57                   	push   %edi
  802ce2:	56                   	push   %esi
  802ce3:	83 ec 20             	sub    $0x20,%esp
  802ce6:	8b 44 24 34          	mov    0x34(%esp),%eax
  802cea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802cee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802cf2:	89 c6                	mov    %eax,%esi
  802cf4:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cf8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802cfc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802d00:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d04:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802d08:	89 74 24 18          	mov    %esi,0x18(%esp)
  802d0c:	85 c0                	test   %eax,%eax
  802d0e:	89 c2                	mov    %eax,%edx
  802d10:	75 1e                	jne    802d30 <__umoddi3+0x50>
  802d12:	39 f7                	cmp    %esi,%edi
  802d14:	76 52                	jbe    802d68 <__umoddi3+0x88>
  802d16:	89 c8                	mov    %ecx,%eax
  802d18:	89 f2                	mov    %esi,%edx
  802d1a:	f7 f7                	div    %edi
  802d1c:	89 d0                	mov    %edx,%eax
  802d1e:	31 d2                	xor    %edx,%edx
  802d20:	83 c4 20             	add    $0x20,%esp
  802d23:	5e                   	pop    %esi
  802d24:	5f                   	pop    %edi
  802d25:	5d                   	pop    %ebp
  802d26:	c3                   	ret    
  802d27:	89 f6                	mov    %esi,%esi
  802d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802d30:	39 f0                	cmp    %esi,%eax
  802d32:	77 5c                	ja     802d90 <__umoddi3+0xb0>
  802d34:	0f bd e8             	bsr    %eax,%ebp
  802d37:	83 f5 1f             	xor    $0x1f,%ebp
  802d3a:	75 64                	jne    802da0 <__umoddi3+0xc0>
  802d3c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802d40:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802d44:	0f 86 f6 00 00 00    	jbe    802e40 <__umoddi3+0x160>
  802d4a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802d4e:	0f 82 ec 00 00 00    	jb     802e40 <__umoddi3+0x160>
  802d54:	8b 44 24 14          	mov    0x14(%esp),%eax
  802d58:	8b 54 24 18          	mov    0x18(%esp),%edx
  802d5c:	83 c4 20             	add    $0x20,%esp
  802d5f:	5e                   	pop    %esi
  802d60:	5f                   	pop    %edi
  802d61:	5d                   	pop    %ebp
  802d62:	c3                   	ret    
  802d63:	90                   	nop
  802d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d68:	85 ff                	test   %edi,%edi
  802d6a:	89 fd                	mov    %edi,%ebp
  802d6c:	75 0b                	jne    802d79 <__umoddi3+0x99>
  802d6e:	b8 01 00 00 00       	mov    $0x1,%eax
  802d73:	31 d2                	xor    %edx,%edx
  802d75:	f7 f7                	div    %edi
  802d77:	89 c5                	mov    %eax,%ebp
  802d79:	8b 44 24 10          	mov    0x10(%esp),%eax
  802d7d:	31 d2                	xor    %edx,%edx
  802d7f:	f7 f5                	div    %ebp
  802d81:	89 c8                	mov    %ecx,%eax
  802d83:	f7 f5                	div    %ebp
  802d85:	eb 95                	jmp    802d1c <__umoddi3+0x3c>
  802d87:	89 f6                	mov    %esi,%esi
  802d89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802d90:	89 c8                	mov    %ecx,%eax
  802d92:	89 f2                	mov    %esi,%edx
  802d94:	83 c4 20             	add    $0x20,%esp
  802d97:	5e                   	pop    %esi
  802d98:	5f                   	pop    %edi
  802d99:	5d                   	pop    %ebp
  802d9a:	c3                   	ret    
  802d9b:	90                   	nop
  802d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802da0:	b8 20 00 00 00       	mov    $0x20,%eax
  802da5:	89 e9                	mov    %ebp,%ecx
  802da7:	29 e8                	sub    %ebp,%eax
  802da9:	d3 e2                	shl    %cl,%edx
  802dab:	89 c7                	mov    %eax,%edi
  802dad:	89 44 24 18          	mov    %eax,0x18(%esp)
  802db1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802db5:	89 f9                	mov    %edi,%ecx
  802db7:	d3 e8                	shr    %cl,%eax
  802db9:	89 c1                	mov    %eax,%ecx
  802dbb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802dbf:	09 d1                	or     %edx,%ecx
  802dc1:	89 fa                	mov    %edi,%edx
  802dc3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802dc7:	89 e9                	mov    %ebp,%ecx
  802dc9:	d3 e0                	shl    %cl,%eax
  802dcb:	89 f9                	mov    %edi,%ecx
  802dcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802dd1:	89 f0                	mov    %esi,%eax
  802dd3:	d3 e8                	shr    %cl,%eax
  802dd5:	89 e9                	mov    %ebp,%ecx
  802dd7:	89 c7                	mov    %eax,%edi
  802dd9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802ddd:	d3 e6                	shl    %cl,%esi
  802ddf:	89 d1                	mov    %edx,%ecx
  802de1:	89 fa                	mov    %edi,%edx
  802de3:	d3 e8                	shr    %cl,%eax
  802de5:	89 e9                	mov    %ebp,%ecx
  802de7:	09 f0                	or     %esi,%eax
  802de9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  802ded:	f7 74 24 10          	divl   0x10(%esp)
  802df1:	d3 e6                	shl    %cl,%esi
  802df3:	89 d1                	mov    %edx,%ecx
  802df5:	f7 64 24 0c          	mull   0xc(%esp)
  802df9:	39 d1                	cmp    %edx,%ecx
  802dfb:	89 74 24 14          	mov    %esi,0x14(%esp)
  802dff:	89 d7                	mov    %edx,%edi
  802e01:	89 c6                	mov    %eax,%esi
  802e03:	72 0a                	jb     802e0f <__umoddi3+0x12f>
  802e05:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802e09:	73 10                	jae    802e1b <__umoddi3+0x13b>
  802e0b:	39 d1                	cmp    %edx,%ecx
  802e0d:	75 0c                	jne    802e1b <__umoddi3+0x13b>
  802e0f:	89 d7                	mov    %edx,%edi
  802e11:	89 c6                	mov    %eax,%esi
  802e13:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802e17:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  802e1b:	89 ca                	mov    %ecx,%edx
  802e1d:	89 e9                	mov    %ebp,%ecx
  802e1f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802e23:	29 f0                	sub    %esi,%eax
  802e25:	19 fa                	sbb    %edi,%edx
  802e27:	d3 e8                	shr    %cl,%eax
  802e29:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802e2e:	89 d7                	mov    %edx,%edi
  802e30:	d3 e7                	shl    %cl,%edi
  802e32:	89 e9                	mov    %ebp,%ecx
  802e34:	09 f8                	or     %edi,%eax
  802e36:	d3 ea                	shr    %cl,%edx
  802e38:	83 c4 20             	add    $0x20,%esp
  802e3b:	5e                   	pop    %esi
  802e3c:	5f                   	pop    %edi
  802e3d:	5d                   	pop    %ebp
  802e3e:	c3                   	ret    
  802e3f:	90                   	nop
  802e40:	8b 74 24 10          	mov    0x10(%esp),%esi
  802e44:	29 f9                	sub    %edi,%ecx
  802e46:	19 c6                	sbb    %eax,%esi
  802e48:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802e4c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802e50:	e9 ff fe ff ff       	jmp    802d54 <__umoddi3+0x74>
