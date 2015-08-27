
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 56 02 00 00       	call   800287 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 d5 0c 00 00       	call   800d12 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 40 80 00 00 	movl   $0x802900,0x804000
  800046:	29 80 00 
	output_envid = fork();
  800049:	e8 76 10 00 00       	call   8010c4 <fork>
  80004e:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 0b 29 80 00       	push   $0x80290b
  80005f:	6a 15                	push   $0x15
  800061:	68 19 29 80 00       	push   $0x802919
  800066:	e8 7c 02 00 00       	call   8002e7 <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 88 01 00 00       	call   800205 <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8c 00 00 00       	jmp    800111 <umain+0xde>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 ba 0c 00 00       	call   800d50 <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 2a 29 80 00       	push   $0x80292a
  8000a3:	6a 1d                	push   $0x1d
  8000a5:	68 19 29 80 00       	push   $0x802919
  8000aa:	e8 38 02 00 00       	call   8002e7 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 3d 29 80 00       	push   $0x80293d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 30 08 00 00       	call   8008f4 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 49 29 80 00       	push   $0x802949
  8000d2:	e8 e9 02 00 00       	call   8003c0 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 50 80 00    	pushl  0x805000
  8000e6:	e8 64 12 00 00       	call   80134f <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 db 0c 00 00       	call   800dd5 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	b3 14                	mov    $0x14,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800107:	e8 25 0c 00 00       	call   800d31 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010c:	83 eb 01             	sub    $0x1,%ebx
  80010f:	75 f6                	jne    800107 <umain+0xd4>
		sys_yield();
}
  800111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 1c             	sub    $0x1c,%esp
  800121:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800124:	e8 18 0e 00 00       	call   800f41 <sys_time_msec>
  800129:	03 45 0c             	add    0xc(%ebp),%eax
  80012c:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  80012e:	c7 05 00 40 80 00 61 	movl   $0x802961,0x804000
  800135:	29 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800138:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013b:	eb 05                	jmp    800142 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  80013d:	e8 ef 0b 00 00       	call   800d31 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800142:	e8 fa 0d 00 00       	call   800f41 <sys_time_msec>
  800147:	89 c2                	mov    %eax,%edx
  800149:	85 c0                	test   %eax,%eax
  80014b:	78 04                	js     800151 <timer+0x39>
  80014d:	39 c3                	cmp    %eax,%ebx
  80014f:	77 ec                	ja     80013d <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800151:	85 c0                	test   %eax,%eax
  800153:	79 12                	jns    800167 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800155:	52                   	push   %edx
  800156:	68 6a 29 80 00       	push   $0x80296a
  80015b:	6a 0f                	push   $0xf
  80015d:	68 7c 29 80 00       	push   $0x80297c
  800162:	e8 80 01 00 00       	call   8002e7 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	6a 0c                	push   $0xc
  80016d:	56                   	push   %esi
  80016e:	e8 dc 11 00 00       	call   80134f <ipc_send>
  800173:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800176:	83 ec 04             	sub    $0x4,%esp
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	57                   	push   %edi
  80017e:	e8 63 11 00 00       	call   8012e6 <ipc_recv>
  800183:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	39 c6                	cmp    %eax,%esi
  80018d:	74 13                	je     8001a2 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	50                   	push   %eax
  800193:	68 88 29 80 00       	push   $0x802988
  800198:	e8 23 02 00 00       	call   8003c0 <cprintf>
				continue;
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb d4                	jmp    800176 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a2:	e8 9a 0d 00 00       	call   800f41 <sys_time_msec>
  8001a7:	01 c3                	add    %eax,%ebx
  8001a9:	eb 97                	jmp    800142 <timer+0x2a>

008001ab <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 04             	sub    $0x4,%esp
  8001b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	binaryname = "ns_input";
  8001b5:	c7 05 00 40 80 00 c3 	movl   $0x8029c3,0x804000
  8001bc:	29 80 00 
  8001bf:	eb 1c                	jmp    8001dd <input+0x32>
        int r;
        while(1) {
 
                
                 while(( r = sys_recv((void *)RXTEP)) < 0) {
                       if(r != -E_IPC_NOT_RECV)
  8001c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8001c4:	74 12                	je     8001d8 <input+0x2d>
                               panic("sys_recv fails %e\n", r);
  8001c6:	50                   	push   %eax
  8001c7:	68 cc 29 80 00       	push   $0x8029cc
  8001cc:	6a 17                	push   $0x17
  8001ce:	68 df 29 80 00       	push   $0x8029df
  8001d3:	e8 0f 01 00 00       	call   8002e7 <_panic>
                       sys_yield();
  8001d8:	e8 54 0b 00 00       	call   800d31 <sys_yield>
 
        int r;
        while(1) {
 
                
                 while(( r = sys_recv((void *)RXTEP)) < 0) {
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	68 00 20 80 40       	push   $0x40802000
  8001e5:	e8 b7 0d 00 00       	call   800fa1 <sys_recv>
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	85 c0                	test   %eax,%eax
  8001ef:	78 d0                	js     8001c1 <input+0x16>
                       if(r != -E_IPC_NOT_RECV)
                               panic("sys_recv fails %e\n", r);
                       sys_yield();
               }
      
               ipc_send(ns_envid, NSREQ_INPUT, (void *)RXTEP, PTE_U | PTE_P); 
  8001f1:	6a 05                	push   $0x5
  8001f3:	68 00 20 80 40       	push   $0x40802000
  8001f8:	6a 0a                	push   $0xa
  8001fa:	53                   	push   %ebx
  8001fb:	e8 4f 11 00 00       	call   80134f <ipc_send>
        }
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	eb d8                	jmp    8001dd <input+0x32>

00800205 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_output";
  800211:	c7 05 00 40 80 00 eb 	movl   $0x8029eb,0x804000
  800218:	29 80 00 
	//	- send the packet to the device driver
        envid_t from_envid;
        int perm;
        int r;
        while(1) {
                r = ipc_recv(&from_envid, (void *)TXTEP, &perm);
  80021b:	8d 75 e0             	lea    -0x20(%ebp),%esi
  80021e:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800221:	83 ec 04             	sub    $0x4,%esp
  800224:	56                   	push   %esi
  800225:	68 00 20 40 40       	push   $0x40402000
  80022a:	53                   	push   %ebx
  80022b:	e8 b6 10 00 00       	call   8012e6 <ipc_recv>
                if (r < 0)
  800230:	83 c4 10             	add    $0x10,%esp
  800233:	85 c0                	test   %eax,%eax
  800235:	79 12                	jns    800249 <output+0x44>
                        panic("ipc_recv from net fails %e\n", r);
  800237:	50                   	push   %eax
  800238:	68 f5 29 80 00       	push   $0x8029f5
  80023d:	6a 13                	push   $0x13
  80023f:	68 11 2a 80 00       	push   $0x802a11
  800244:	e8 9e 00 00 00       	call   8002e7 <_panic>
                if (from_envid != ns_envid)
                        continue;
                if (r != NSREQ_OUTPUT)
  800249:	83 f8 0b             	cmp    $0xb,%eax
  80024c:	75 d3                	jne    800221 <output+0x1c>
  80024e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
  800251:	75 ce                	jne    800221 <output+0x1c>
  800253:	eb 1c                	jmp    800271 <output+0x6c>
                        continue;
                while((r = sys_transmit((void *)TXTEP) ) < 0) {
                        if(r != -E_IPC_NOT_RECV)
  800255:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800258:	74 12                	je     80026c <output+0x67>
                                panic("sys_transit fails %e\n", r);
  80025a:	50                   	push   %eax
  80025b:	68 1e 2a 80 00       	push   $0x802a1e
  800260:	6a 1a                	push   $0x1a
  800262:	68 11 2a 80 00       	push   $0x802a11
  800267:	e8 7b 00 00 00       	call   8002e7 <_panic>
                        sys_yield();
  80026c:	e8 c0 0a 00 00       	call   800d31 <sys_yield>
                        panic("ipc_recv from net fails %e\n", r);
                if (from_envid != ns_envid)
                        continue;
                if (r != NSREQ_OUTPUT)
                        continue;
                while((r = sys_transmit((void *)TXTEP) ) < 0) {
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	68 00 20 40 40       	push   $0x40402000
  800279:	e8 e2 0c 00 00       	call   800f60 <sys_transmit>
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	85 c0                	test   %eax,%eax
  800283:	78 d0                	js     800255 <output+0x50>
  800285:	eb 9a                	jmp    800221 <output+0x1c>

00800287 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80028f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800292:	e8 7b 0a 00 00       	call   800d12 <sys_getenvid>
  800297:	25 ff 03 00 00       	and    $0x3ff,%eax
  80029c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80029f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002a4:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7e 07                	jle    8002b4 <libmain+0x2d>
		binaryname = argv[0];
  8002ad:	8b 06                	mov    (%esi),%eax
  8002af:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	e8 75 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002be:	e8 0a 00 00 00       	call   8002cd <exit>
  8002c3:	83 c4 10             	add    $0x10,%esp
}
  8002c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002d3:	e8 d5 12 00 00       	call   8015ad <close_all>
	sys_env_destroy(0);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	6a 00                	push   $0x0
  8002dd:	e8 ef 09 00 00       	call   800cd1 <sys_env_destroy>
  8002e2:	83 c4 10             	add    $0x10,%esp
}
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ef:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8002f5:	e8 18 0a 00 00       	call   800d12 <sys_getenvid>
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	ff 75 0c             	pushl  0xc(%ebp)
  800300:	ff 75 08             	pushl  0x8(%ebp)
  800303:	56                   	push   %esi
  800304:	50                   	push   %eax
  800305:	68 40 2a 80 00       	push   $0x802a40
  80030a:	e8 b1 00 00 00       	call   8003c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80030f:	83 c4 18             	add    $0x18,%esp
  800312:	53                   	push   %ebx
  800313:	ff 75 10             	pushl  0x10(%ebp)
  800316:	e8 54 00 00 00       	call   80036f <vcprintf>
	cprintf("\n");
  80031b:	c7 04 24 d9 2e 80 00 	movl   $0x802ed9,(%esp)
  800322:	e8 99 00 00 00       	call   8003c0 <cprintf>
  800327:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032a:	cc                   	int3   
  80032b:	eb fd                	jmp    80032a <_panic+0x43>

0080032d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	53                   	push   %ebx
  800331:	83 ec 04             	sub    $0x4,%esp
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800337:	8b 13                	mov    (%ebx),%edx
  800339:	8d 42 01             	lea    0x1(%edx),%eax
  80033c:	89 03                	mov    %eax,(%ebx)
  80033e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800341:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800345:	3d ff 00 00 00       	cmp    $0xff,%eax
  80034a:	75 1a                	jne    800366 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	68 ff 00 00 00       	push   $0xff
  800354:	8d 43 08             	lea    0x8(%ebx),%eax
  800357:	50                   	push   %eax
  800358:	e8 37 09 00 00       	call   800c94 <sys_cputs>
		b->idx = 0;
  80035d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800363:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800366:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800378:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037f:	00 00 00 
	b.cnt = 0;
  800382:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800389:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800398:	50                   	push   %eax
  800399:	68 2d 03 80 00       	push   $0x80032d
  80039e:	e8 4f 01 00 00       	call   8004f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a3:	83 c4 08             	add    $0x8,%esp
  8003a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	e8 dc 08 00 00       	call   800c94 <sys_cputs>

	return b.cnt;
}
  8003b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c9:	50                   	push   %eax
  8003ca:	ff 75 08             	pushl  0x8(%ebp)
  8003cd:	e8 9d ff ff ff       	call   80036f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 1c             	sub    $0x1c,%esp
  8003dd:	89 c7                	mov    %eax,%edi
  8003df:	89 d6                	mov    %edx,%esi
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 d1                	mov    %edx,%ecx
  8003e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ff:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800402:	72 05                	jb     800409 <printnum+0x35>
  800404:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800407:	77 3e                	ja     800447 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800409:	83 ec 0c             	sub    $0xc,%esp
  80040c:	ff 75 18             	pushl  0x18(%ebp)
  80040f:	83 eb 01             	sub    $0x1,%ebx
  800412:	53                   	push   %ebx
  800413:	50                   	push   %eax
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041a:	ff 75 e0             	pushl  -0x20(%ebp)
  80041d:	ff 75 dc             	pushl  -0x24(%ebp)
  800420:	ff 75 d8             	pushl  -0x28(%ebp)
  800423:	e8 08 22 00 00       	call   802630 <__udivdi3>
  800428:	83 c4 18             	add    $0x18,%esp
  80042b:	52                   	push   %edx
  80042c:	50                   	push   %eax
  80042d:	89 f2                	mov    %esi,%edx
  80042f:	89 f8                	mov    %edi,%eax
  800431:	e8 9e ff ff ff       	call   8003d4 <printnum>
  800436:	83 c4 20             	add    $0x20,%esp
  800439:	eb 13                	jmp    80044e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	56                   	push   %esi
  80043f:	ff 75 18             	pushl  0x18(%ebp)
  800442:	ff d7                	call   *%edi
  800444:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800447:	83 eb 01             	sub    $0x1,%ebx
  80044a:	85 db                	test   %ebx,%ebx
  80044c:	7f ed                	jg     80043b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	83 ec 04             	sub    $0x4,%esp
  800455:	ff 75 e4             	pushl  -0x1c(%ebp)
  800458:	ff 75 e0             	pushl  -0x20(%ebp)
  80045b:	ff 75 dc             	pushl  -0x24(%ebp)
  80045e:	ff 75 d8             	pushl  -0x28(%ebp)
  800461:	e8 fa 22 00 00       	call   802760 <__umoddi3>
  800466:	83 c4 14             	add    $0x14,%esp
  800469:	0f be 80 63 2a 80 00 	movsbl 0x802a63(%eax),%eax
  800470:	50                   	push   %eax
  800471:	ff d7                	call   *%edi
  800473:	83 c4 10             	add    $0x10,%esp
}
  800476:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c7:	73 0a                	jae    8004d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	88 02                	mov    %al,(%edx)
}
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004de:	50                   	push   %eax
  8004df:	ff 75 10             	pushl  0x10(%ebp)
  8004e2:	ff 75 0c             	pushl  0xc(%ebp)
  8004e5:	ff 75 08             	pushl  0x8(%ebp)
  8004e8:	e8 05 00 00 00       	call   8004f2 <vprintfmt>
	va_end(ap);
  8004ed:	83 c4 10             	add    $0x10,%esp
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 2c             	sub    $0x2c,%esp
  8004fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800501:	8b 7d 10             	mov    0x10(%ebp),%edi
  800504:	eb 12                	jmp    800518 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800506:	85 c0                	test   %eax,%eax
  800508:	0f 84 90 03 00 00    	je     80089e <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	50                   	push   %eax
  800513:	ff d6                	call   *%esi
  800515:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800518:	83 c7 01             	add    $0x1,%edi
  80051b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051f:	83 f8 25             	cmp    $0x25,%eax
  800522:	75 e2                	jne    800506 <vprintfmt+0x14>
  800524:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800528:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800536:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
  800542:	eb 07                	jmp    80054b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8d 47 01             	lea    0x1(%edi),%eax
  80054e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800551:	0f b6 07             	movzbl (%edi),%eax
  800554:	0f b6 c8             	movzbl %al,%ecx
  800557:	83 e8 23             	sub    $0x23,%eax
  80055a:	3c 55                	cmp    $0x55,%al
  80055c:	0f 87 21 03 00 00    	ja     800883 <vprintfmt+0x391>
  800562:	0f b6 c0             	movzbl %al,%eax
  800565:	ff 24 85 c0 2b 80 00 	jmp    *0x802bc0(,%eax,4)
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800573:	eb d6                	jmp    80054b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800578:	b8 00 00 00 00       	mov    $0x0,%eax
  80057d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800580:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800583:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800587:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80058a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80058d:	83 fa 09             	cmp    $0x9,%edx
  800590:	77 39                	ja     8005cb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800592:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800595:	eb e9                	jmp    800580 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 48 04             	lea    0x4(%eax),%ecx
  80059d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a8:	eb 27                	jmp    8005d1 <vprintfmt+0xdf>
  8005aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b4:	0f 49 c8             	cmovns %eax,%ecx
  8005b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bd:	eb 8c                	jmp    80054b <vprintfmt+0x59>
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c9:	eb 80                	jmp    80054b <vprintfmt+0x59>
  8005cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ce:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d5:	0f 89 70 ff ff ff    	jns    80054b <vprintfmt+0x59>
				width = precision, precision = -1;
  8005db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e8:	e9 5e ff ff ff       	jmp    80054b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f3:	e9 53 ff ff ff       	jmp    80054b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	ff 30                	pushl  (%eax)
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060f:	e9 04 ff ff ff       	jmp    800518 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	99                   	cltd   
  800620:	31 d0                	xor    %edx,%eax
  800622:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800624:	83 f8 0f             	cmp    $0xf,%eax
  800627:	7f 0b                	jg     800634 <vprintfmt+0x142>
  800629:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  800630:	85 d2                	test   %edx,%edx
  800632:	75 18                	jne    80064c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800634:	50                   	push   %eax
  800635:	68 7b 2a 80 00       	push   $0x802a7b
  80063a:	53                   	push   %ebx
  80063b:	56                   	push   %esi
  80063c:	e8 94 fe ff ff       	call   8004d5 <printfmt>
  800641:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800647:	e9 cc fe ff ff       	jmp    800518 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80064c:	52                   	push   %edx
  80064d:	68 d9 2f 80 00       	push   $0x802fd9
  800652:	53                   	push   %ebx
  800653:	56                   	push   %esi
  800654:	e8 7c fe ff ff       	call   8004d5 <printfmt>
  800659:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	e9 b4 fe ff ff       	jmp    800518 <vprintfmt+0x26>
  800664:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800667:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800678:	85 ff                	test   %edi,%edi
  80067a:	ba 74 2a 80 00       	mov    $0x802a74,%edx
  80067f:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800682:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800686:	0f 84 92 00 00 00    	je     80071e <vprintfmt+0x22c>
  80068c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800690:	0f 8e 96 00 00 00    	jle    80072c <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	51                   	push   %ecx
  80069a:	57                   	push   %edi
  80069b:	e8 86 02 00 00       	call   800926 <strnlen>
  8006a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a3:	29 c1                	sub    %eax,%ecx
  8006a5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006a8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ab:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	eb 0f                	jmp    8006c8 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	7f ed                	jg     8006b9 <vprintfmt+0x1c7>
  8006cc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d2:	85 c9                	test   %ecx,%ecx
  8006d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d9:	0f 49 c1             	cmovns %ecx,%eax
  8006dc:	29 c1                	sub    %eax,%ecx
  8006de:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e7:	89 cb                	mov    %ecx,%ebx
  8006e9:	eb 4d                	jmp    800738 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ef:	74 1b                	je     80070c <vprintfmt+0x21a>
  8006f1:	0f be c0             	movsbl %al,%eax
  8006f4:	83 e8 20             	sub    $0x20,%eax
  8006f7:	83 f8 5e             	cmp    $0x5e,%eax
  8006fa:	76 10                	jbe    80070c <vprintfmt+0x21a>
					putch('?', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	6a 3f                	push   $0x3f
  800704:	ff 55 08             	call   *0x8(%ebp)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	52                   	push   %edx
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800719:	83 eb 01             	sub    $0x1,%ebx
  80071c:	eb 1a                	jmp    800738 <vprintfmt+0x246>
  80071e:	89 75 08             	mov    %esi,0x8(%ebp)
  800721:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800724:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800727:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072a:	eb 0c                	jmp    800738 <vprintfmt+0x246>
  80072c:	89 75 08             	mov    %esi,0x8(%ebp)
  80072f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800732:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800735:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800738:	83 c7 01             	add    $0x1,%edi
  80073b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073f:	0f be d0             	movsbl %al,%edx
  800742:	85 d2                	test   %edx,%edx
  800744:	74 23                	je     800769 <vprintfmt+0x277>
  800746:	85 f6                	test   %esi,%esi
  800748:	78 a1                	js     8006eb <vprintfmt+0x1f9>
  80074a:	83 ee 01             	sub    $0x1,%esi
  80074d:	79 9c                	jns    8006eb <vprintfmt+0x1f9>
  80074f:	89 df                	mov    %ebx,%edi
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800757:	eb 18                	jmp    800771 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 20                	push   $0x20
  80075f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800761:	83 ef 01             	sub    $0x1,%edi
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	eb 08                	jmp    800771 <vprintfmt+0x27f>
  800769:	89 df                	mov    %ebx,%edi
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800771:	85 ff                	test   %edi,%edi
  800773:	7f e4                	jg     800759 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800778:	e9 9b fd ff ff       	jmp    800518 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077d:	83 fa 01             	cmp    $0x1,%edx
  800780:	7e 16                	jle    800798 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 08             	lea    0x8(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)
  80078b:	8b 50 04             	mov    0x4(%eax),%edx
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800793:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800796:	eb 32                	jmp    8007ca <vprintfmt+0x2d8>
	else if (lflag)
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 18                	je     8007b4 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 50 04             	lea    0x4(%eax),%edx
  8007a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007aa:	89 c1                	mov    %eax,%ecx
  8007ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8007af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b2:	eb 16                	jmp    8007ca <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	89 c1                	mov    %eax,%ecx
  8007c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d9:	79 74                	jns    80084f <vprintfmt+0x35d>
				putch('-', putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	53                   	push   %ebx
  8007df:	6a 2d                	push   $0x2d
  8007e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e9:	f7 d8                	neg    %eax
  8007eb:	83 d2 00             	adc    $0x0,%edx
  8007ee:	f7 da                	neg    %edx
  8007f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007f8:	eb 55                	jmp    80084f <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fd:	e8 7c fc ff ff       	call   80047e <getuint>
			base = 10;
  800802:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800807:	eb 46                	jmp    80084f <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
  80080c:	e8 6d fc ff ff       	call   80047e <getuint>
                        base = 8;
  800811:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800816:	eb 37                	jmp    80084f <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 30                	push   $0x30
  80081e:	ff d6                	call   *%esi
			putch('x', putdat);
  800820:	83 c4 08             	add    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 78                	push   $0x78
  800826:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8d 50 04             	lea    0x4(%eax),%edx
  80082e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800831:	8b 00                	mov    (%eax),%eax
  800833:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800838:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80083b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800840:	eb 0d                	jmp    80084f <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 34 fc ff ff       	call   80047e <getuint>
			base = 16;
  80084a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084f:	83 ec 0c             	sub    $0xc,%esp
  800852:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800856:	57                   	push   %edi
  800857:	ff 75 e0             	pushl  -0x20(%ebp)
  80085a:	51                   	push   %ecx
  80085b:	52                   	push   %edx
  80085c:	50                   	push   %eax
  80085d:	89 da                	mov    %ebx,%edx
  80085f:	89 f0                	mov    %esi,%eax
  800861:	e8 6e fb ff ff       	call   8003d4 <printnum>
			break;
  800866:	83 c4 20             	add    $0x20,%esp
  800869:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086c:	e9 a7 fc ff ff       	jmp    800518 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	51                   	push   %ecx
  800876:	ff d6                	call   *%esi
			break;
  800878:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087e:	e9 95 fc ff ff       	jmp    800518 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 25                	push   $0x25
  800889:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	eb 03                	jmp    800893 <vprintfmt+0x3a1>
  800890:	83 ef 01             	sub    $0x1,%edi
  800893:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800897:	75 f7                	jne    800890 <vprintfmt+0x39e>
  800899:	e9 7a fc ff ff       	jmp    800518 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80089e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 18             	sub    $0x18,%esp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	74 26                	je     8008ed <vsnprintf+0x47>
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	7e 22                	jle    8008ed <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cb:	ff 75 14             	pushl  0x14(%ebp)
  8008ce:	ff 75 10             	pushl  0x10(%ebp)
  8008d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d4:	50                   	push   %eax
  8008d5:	68 b8 04 80 00       	push   $0x8004b8
  8008da:	e8 13 fc ff ff       	call   8004f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	eb 05                	jmp    8008f2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fd:	50                   	push   %eax
  8008fe:	ff 75 10             	pushl  0x10(%ebp)
  800901:	ff 75 0c             	pushl  0xc(%ebp)
  800904:	ff 75 08             	pushl  0x8(%ebp)
  800907:	e8 9a ff ff ff       	call   8008a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
  800919:	eb 03                	jmp    80091e <strlen+0x10>
		n++;
  80091b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800922:	75 f7                	jne    80091b <strlen+0xd>
		n++;
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	ba 00 00 00 00       	mov    $0x0,%edx
  800934:	eb 03                	jmp    800939 <strnlen+0x13>
		n++;
  800936:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800939:	39 c2                	cmp    %eax,%edx
  80093b:	74 08                	je     800945 <strnlen+0x1f>
  80093d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800941:	75 f3                	jne    800936 <strnlen+0x10>
  800943:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800951:	89 c2                	mov    %eax,%edx
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800960:	84 db                	test   %bl,%bl
  800962:	75 ef                	jne    800953 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096e:	53                   	push   %ebx
  80096f:	e8 9a ff ff ff       	call   80090e <strlen>
  800974:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	01 d8                	add    %ebx,%eax
  80097c:	50                   	push   %eax
  80097d:	e8 c5 ff ff ff       	call   800947 <strcpy>
	return dst;
}
  800982:	89 d8                	mov    %ebx,%eax
  800984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 75 08             	mov    0x8(%ebp),%esi
  800991:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800994:	89 f3                	mov    %esi,%ebx
  800996:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	89 f2                	mov    %esi,%edx
  80099b:	eb 0f                	jmp    8009ac <strncpy+0x23>
		*dst++ = *src;
  80099d:	83 c2 01             	add    $0x1,%edx
  8009a0:	0f b6 01             	movzbl (%ecx),%eax
  8009a3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a6:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	39 da                	cmp    %ebx,%edx
  8009ae:	75 ed                	jne    80099d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b0:	89 f0                	mov    %esi,%eax
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c1:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	74 21                	je     8009eb <strlcpy+0x35>
  8009ca:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	eb 09                	jmp    8009db <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d2:	83 c2 01             	add    $0x1,%edx
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009db:	39 c2                	cmp    %eax,%edx
  8009dd:	74 09                	je     8009e8 <strlcpy+0x32>
  8009df:	0f b6 19             	movzbl (%ecx),%ebx
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	75 ec                	jne    8009d2 <strlcpy+0x1c>
  8009e6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009eb:	29 f0                	sub    %esi,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fa:	eb 06                	jmp    800a02 <strcmp+0x11>
		p++, q++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	84 c0                	test   %al,%al
  800a07:	74 04                	je     800a0d <strcmp+0x1c>
  800a09:	3a 02                	cmp    (%edx),%al
  800a0b:	74 ef                	je     8009fc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	0f b6 12             	movzbl (%edx),%edx
  800a13:	29 d0                	sub    %edx,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a26:	eb 06                	jmp    800a2e <strncmp+0x17>
		n--, p++, q++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2e:	39 d8                	cmp    %ebx,%eax
  800a30:	74 15                	je     800a47 <strncmp+0x30>
  800a32:	0f b6 08             	movzbl (%eax),%ecx
  800a35:	84 c9                	test   %cl,%cl
  800a37:	74 04                	je     800a3d <strncmp+0x26>
  800a39:	3a 0a                	cmp    (%edx),%cl
  800a3b:	74 eb                	je     800a28 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3d:	0f b6 00             	movzbl (%eax),%eax
  800a40:	0f b6 12             	movzbl (%edx),%edx
  800a43:	29 d0                	sub    %edx,%eax
  800a45:	eb 05                	jmp    800a4c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a59:	eb 07                	jmp    800a62 <strchr+0x13>
		if (*s == c)
  800a5b:	38 ca                	cmp    %cl,%dl
  800a5d:	74 0f                	je     800a6e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	0f b6 10             	movzbl (%eax),%edx
  800a65:	84 d2                	test   %dl,%dl
  800a67:	75 f2                	jne    800a5b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7a:	eb 03                	jmp    800a7f <strfind+0xf>
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a82:	84 d2                	test   %dl,%dl
  800a84:	74 04                	je     800a8a <strfind+0x1a>
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	75 f2                	jne    800a7c <strfind+0xc>
			break;
	return (char *) s;
}
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a98:	85 c9                	test   %ecx,%ecx
  800a9a:	74 36                	je     800ad2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa2:	75 28                	jne    800acc <memset+0x40>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 23                	jne    800acc <memset+0x40>
		c &= 0xFF;
  800aa9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	c1 e3 08             	shl    $0x8,%ebx
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	c1 e6 18             	shl    $0x18,%esi
  800ab7:	89 d0                	mov    %edx,%eax
  800ab9:	c1 e0 10             	shl    $0x10,%eax
  800abc:	09 f0                	or     %esi,%eax
  800abe:	09 c2                	or     %eax,%edx
  800ac0:	89 d0                	mov    %edx,%eax
  800ac2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac7:	fc                   	cld    
  800ac8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aca:	eb 06                	jmp    800ad2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	fc                   	cld    
  800ad0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad2:	89 f8                	mov    %edi,%eax
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae7:	39 c6                	cmp    %eax,%esi
  800ae9:	73 35                	jae    800b20 <memmove+0x47>
  800aeb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aee:	39 d0                	cmp    %edx,%eax
  800af0:	73 2e                	jae    800b20 <memmove+0x47>
		s += n;
		d += n;
  800af2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aff:	75 13                	jne    800b14 <memmove+0x3b>
  800b01:	f6 c1 03             	test   $0x3,%cl
  800b04:	75 0e                	jne    800b14 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b06:	83 ef 04             	sub    $0x4,%edi
  800b09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0f:	fd                   	std    
  800b10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b12:	eb 09                	jmp    800b1d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b14:	83 ef 01             	sub    $0x1,%edi
  800b17:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1d:	fc                   	cld    
  800b1e:	eb 1d                	jmp    800b3d <memmove+0x64>
  800b20:	89 f2                	mov    %esi,%edx
  800b22:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f6 c2 03             	test   $0x3,%dl
  800b27:	75 0f                	jne    800b38 <memmove+0x5f>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 0a                	jne    800b38 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b36:	eb 05                	jmp    800b3d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b38:	89 c7                	mov    %eax,%edi
  800b3a:	fc                   	cld    
  800b3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b44:	ff 75 10             	pushl  0x10(%ebp)
  800b47:	ff 75 0c             	pushl  0xc(%ebp)
  800b4a:	ff 75 08             	pushl  0x8(%ebp)
  800b4d:	e8 87 ff ff ff       	call   800ad9 <memmove>
}
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5f:	89 c6                	mov    %eax,%esi
  800b61:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b64:	eb 1a                	jmp    800b80 <memcmp+0x2c>
		if (*s1 != *s2)
  800b66:	0f b6 08             	movzbl (%eax),%ecx
  800b69:	0f b6 1a             	movzbl (%edx),%ebx
  800b6c:	38 d9                	cmp    %bl,%cl
  800b6e:	74 0a                	je     800b7a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b70:	0f b6 c1             	movzbl %cl,%eax
  800b73:	0f b6 db             	movzbl %bl,%ebx
  800b76:	29 d8                	sub    %ebx,%eax
  800b78:	eb 0f                	jmp    800b89 <memcmp+0x35>
		s1++, s2++;
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b80:	39 f0                	cmp    %esi,%eax
  800b82:	75 e2                	jne    800b66 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9b:	eb 07                	jmp    800ba4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9d:	38 08                	cmp    %cl,(%eax)
  800b9f:	74 07                	je     800ba8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba1:	83 c0 01             	add    $0x1,%eax
  800ba4:	39 d0                	cmp    %edx,%eax
  800ba6:	72 f5                	jb     800b9d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb6:	eb 03                	jmp    800bbb <strtol+0x11>
		s++;
  800bb8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbb:	0f b6 01             	movzbl (%ecx),%eax
  800bbe:	3c 09                	cmp    $0x9,%al
  800bc0:	74 f6                	je     800bb8 <strtol+0xe>
  800bc2:	3c 20                	cmp    $0x20,%al
  800bc4:	74 f2                	je     800bb8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc6:	3c 2b                	cmp    $0x2b,%al
  800bc8:	75 0a                	jne    800bd4 <strtol+0x2a>
		s++;
  800bca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd2:	eb 10                	jmp    800be4 <strtol+0x3a>
  800bd4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd9:	3c 2d                	cmp    $0x2d,%al
  800bdb:	75 07                	jne    800be4 <strtol+0x3a>
		s++, neg = 1;
  800bdd:	8d 49 01             	lea    0x1(%ecx),%ecx
  800be0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be4:	85 db                	test   %ebx,%ebx
  800be6:	0f 94 c0             	sete   %al
  800be9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bef:	75 19                	jne    800c0a <strtol+0x60>
  800bf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf4:	75 14                	jne    800c0a <strtol+0x60>
  800bf6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bfa:	0f 85 82 00 00 00    	jne    800c82 <strtol+0xd8>
		s += 2, base = 16;
  800c00:	83 c1 02             	add    $0x2,%ecx
  800c03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c08:	eb 16                	jmp    800c20 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c0a:	84 c0                	test   %al,%al
  800c0c:	74 12                	je     800c20 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c13:	80 39 30             	cmpb   $0x30,(%ecx)
  800c16:	75 08                	jne    800c20 <strtol+0x76>
		s++, base = 8;
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
  800c25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 11             	movzbl (%ecx),%edx
  800c2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2e:	89 f3                	mov    %esi,%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0x93>
			dig = *s - '0';
  800c35:	0f be d2             	movsbl %dl,%edx
  800c38:	83 ea 30             	sub    $0x30,%edx
  800c3b:	eb 22                	jmp    800c5f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c40:	89 f3                	mov    %esi,%ebx
  800c42:	80 fb 19             	cmp    $0x19,%bl
  800c45:	77 08                	ja     800c4f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	83 ea 57             	sub    $0x57,%edx
  800c4d:	eb 10                	jmp    800c5f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c52:	89 f3                	mov    %esi,%ebx
  800c54:	80 fb 19             	cmp    $0x19,%bl
  800c57:	77 16                	ja     800c6f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c59:	0f be d2             	movsbl %dl,%edx
  800c5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c62:	7d 0f                	jge    800c73 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c64:	83 c1 01             	add    $0x1,%ecx
  800c67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c6d:	eb b9                	jmp    800c28 <strtol+0x7e>
  800c6f:	89 c2                	mov    %eax,%edx
  800c71:	eb 02                	jmp    800c75 <strtol+0xcb>
  800c73:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c79:	74 0d                	je     800c88 <strtol+0xde>
		*endptr = (char *) s;
  800c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7e:	89 0e                	mov    %ecx,(%esi)
  800c80:	eb 06                	jmp    800c88 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c82:	84 c0                	test   %al,%al
  800c84:	75 92                	jne    800c18 <strtol+0x6e>
  800c86:	eb 98                	jmp    800c20 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c88:	f7 da                	neg    %edx
  800c8a:	85 ff                	test   %edi,%edi
  800c8c:	0f 45 c2             	cmovne %edx,%eax
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 c3                	mov    %eax,%ebx
  800ca7:	89 c7                	mov    %eax,%edi
  800ca9:	89 c6                	mov    %eax,%esi
  800cab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc2:	89 d1                	mov    %edx,%ecx
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	89 d7                	mov    %edx,%edi
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 03                	push   $0x3
  800cf9:	68 9f 2d 80 00       	push   $0x802d9f
  800cfe:	6a 22                	push   $0x22
  800d00:	68 bc 2d 80 00       	push   $0x802dbc
  800d05:	e8 dd f5 ff ff       	call   8002e7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d22:	89 d1                	mov    %edx,%ecx
  800d24:	89 d3                	mov    %edx,%ebx
  800d26:	89 d7                	mov    %edx,%edi
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_yield>:

void
sys_yield(void)
{      
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d37:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d41:	89 d1                	mov    %edx,%ecx
  800d43:	89 d3                	mov    %edx,%ebx
  800d45:	89 d7                	mov    %edx,%edi
  800d47:	89 d6                	mov    %edx,%esi
  800d49:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d59:	be 00 00 00 00       	mov    $0x0,%esi
  800d5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6c:	89 f7                	mov    %esi,%edi
  800d6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7e 17                	jle    800d8b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	50                   	push   %eax
  800d78:	6a 04                	push   $0x4
  800d7a:	68 9f 2d 80 00       	push   $0x802d9f
  800d7f:	6a 22                	push   $0x22
  800d81:	68 bc 2d 80 00       	push   $0x802dbc
  800d86:	e8 5c f5 ff ff       	call   8002e7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d9c:	b8 05 00 00 00       	mov    $0x5,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dad:	8b 75 18             	mov    0x18(%ebp),%esi
  800db0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7e 17                	jle    800dcd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 05                	push   $0x5
  800dbc:	68 9f 2d 80 00       	push   $0x802d9f
  800dc1:	6a 22                	push   $0x22
  800dc3:	68 bc 2d 80 00       	push   $0x802dbc
  800dc8:	e8 1a f5 ff ff       	call   8002e7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	57                   	push   %edi
  800dd9:	56                   	push   %esi
  800dda:	53                   	push   %ebx
  800ddb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800dde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de3:	b8 06 00 00 00       	mov    $0x6,%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 df                	mov    %ebx,%edi
  800df0:	89 de                	mov    %ebx,%esi
  800df2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df4:	85 c0                	test   %eax,%eax
  800df6:	7e 17                	jle    800e0f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	50                   	push   %eax
  800dfc:	6a 06                	push   $0x6
  800dfe:	68 9f 2d 80 00       	push   $0x802d9f
  800e03:	6a 22                	push   $0x22
  800e05:	68 bc 2d 80 00       	push   $0x802dbc
  800e0a:	e8 d8 f4 ff ff       	call   8002e7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 df                	mov    %ebx,%edi
  800e32:	89 de                	mov    %ebx,%esi
  800e34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e36:	85 c0                	test   %eax,%eax
  800e38:	7e 17                	jle    800e51 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	50                   	push   %eax
  800e3e:	6a 08                	push   $0x8
  800e40:	68 9f 2d 80 00       	push   $0x802d9f
  800e45:	6a 22                	push   $0x22
  800e47:	68 bc 2d 80 00       	push   $0x802dbc
  800e4c:	e8 96 f4 ff ff       	call   8002e7 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800e51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	b8 09 00 00 00       	mov    $0x9,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 df                	mov    %ebx,%edi
  800e74:	89 de                	mov    %ebx,%esi
  800e76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	7e 17                	jle    800e93 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	50                   	push   %eax
  800e80:	6a 09                	push   $0x9
  800e82:	68 9f 2d 80 00       	push   $0x802d9f
  800e87:	6a 22                	push   $0x22
  800e89:	68 bc 2d 80 00       	push   $0x802dbc
  800e8e:	e8 54 f4 ff ff       	call   8002e7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ea4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	89 df                	mov    %ebx,%edi
  800eb6:	89 de                	mov    %ebx,%esi
  800eb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	7e 17                	jle    800ed5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	50                   	push   %eax
  800ec2:	6a 0a                	push   $0xa
  800ec4:	68 9f 2d 80 00       	push   $0x802d9f
  800ec9:	6a 22                	push   $0x22
  800ecb:	68 bc 2d 80 00       	push   $0x802dbc
  800ed0:	e8 12 f4 ff ff       	call   8002e7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ee3:	be 00 00 00 00       	mov    $0x0,%esi
  800ee8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	89 cb                	mov    %ecx,%ebx
  800f18:	89 cf                	mov    %ecx,%edi
  800f1a:	89 ce                	mov    %ecx,%esi
  800f1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	7e 17                	jle    800f39 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	50                   	push   %eax
  800f26:	6a 0d                	push   $0xd
  800f28:	68 9f 2d 80 00       	push   $0x802d9f
  800f2d:	6a 22                	push   $0x22
  800f2f:	68 bc 2d 80 00       	push   $0x802dbc
  800f34:	e8 ae f3 ff ff       	call   8002e7 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f51:	89 d1                	mov    %edx,%ecx
  800f53:	89 d3                	mov    %edx,%ebx
  800f55:	89 d7                	mov    %edx,%edi
  800f57:	89 d6                	mov    %edx,%esi
  800f59:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
  800f66:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800f69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	89 cb                	mov    %ecx,%ebx
  800f78:	89 cf                	mov    %ecx,%edi
  800f7a:	89 ce                	mov    %ecx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 17                	jle    800f99 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	50                   	push   %eax
  800f86:	6a 0f                	push   $0xf
  800f88:	68 9f 2d 80 00       	push   $0x802d9f
  800f8d:	6a 22                	push   $0x22
  800f8f:	68 bc 2d 80 00       	push   $0x802dbc
  800f94:	e8 4e f3 ff ff       	call   8002e7 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <sys_recv>:

int
sys_recv(void *addr)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800faa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800faf:	b8 10 00 00 00       	mov    $0x10,%eax
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	89 cb                	mov    %ecx,%ebx
  800fb9:	89 cf                	mov    %ecx,%edi
  800fbb:	89 ce                	mov    %ecx,%esi
  800fbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	7e 17                	jle    800fda <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	50                   	push   %eax
  800fc7:	6a 10                	push   $0x10
  800fc9:	68 9f 2d 80 00       	push   $0x802d9f
  800fce:	6a 22                	push   $0x22
  800fd0:	68 bc 2d 80 00       	push   $0x802dbc
  800fd5:	e8 0d f3 ff ff       	call   8002e7 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fec:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800fee:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ff2:	74 2e                	je     801022 <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800ff4:	89 c2                	mov    %eax,%edx
  800ff6:	c1 ea 16             	shr    $0x16,%edx
  800ff9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801000:	f6 c2 01             	test   $0x1,%dl
  801003:	74 1d                	je     801022 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801005:	89 c2                	mov    %eax,%edx
  801007:	c1 ea 0c             	shr    $0xc,%edx
  80100a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  801011:	f6 c1 01             	test   $0x1,%cl
  801014:	74 0c                	je     801022 <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801016:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  80101d:	f6 c6 08             	test   $0x8,%dh
  801020:	75 14                	jne    801036 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	68 cc 2d 80 00       	push   $0x802dcc
  80102a:	6a 21                	push   $0x21
  80102c:	68 5f 2e 80 00       	push   $0x802e5f
  801031:	e8 b1 f2 ff ff       	call   8002e7 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  801036:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80103b:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	6a 07                	push   $0x7
  801042:	68 00 f0 7f 00       	push   $0x7ff000
  801047:	6a 00                	push   $0x0
  801049:	e8 02 fd ff ff       	call   800d50 <sys_page_alloc>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 14                	jns    801069 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	68 6a 2e 80 00       	push   $0x802e6a
  80105d:	6a 2b                	push   $0x2b
  80105f:	68 5f 2e 80 00       	push   $0x802e5f
  801064:	e8 7e f2 ff ff       	call   8002e7 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	68 00 10 00 00       	push   $0x1000
  801071:	53                   	push   %ebx
  801072:	68 00 f0 7f 00       	push   $0x7ff000
  801077:	e8 5d fa ff ff       	call   800ad9 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  80107c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801083:	53                   	push   %ebx
  801084:	6a 00                	push   $0x0
  801086:	68 00 f0 7f 00       	push   $0x7ff000
  80108b:	6a 00                	push   $0x0
  80108d:	e8 01 fd ff ff       	call   800d93 <sys_page_map>
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 14                	jns    8010ad <pgfault+0xcb>
                panic("sys_page_map fails\n");
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	68 80 2e 80 00       	push   $0x802e80
  8010a1:	6a 2e                	push   $0x2e
  8010a3:	68 5f 2e 80 00       	push   $0x802e5f
  8010a8:	e8 3a f2 ff ff       	call   8002e7 <_panic>
        sys_page_unmap(0, PFTEMP); 
  8010ad:	83 ec 08             	sub    $0x8,%esp
  8010b0:	68 00 f0 7f 00       	push   $0x7ff000
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 19 fd ff ff       	call   800dd5 <sys_page_unmap>
  8010bc:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  8010bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  8010cd:	68 e2 0f 80 00       	push   $0x800fe2
  8010d2:	e8 87 14 00 00       	call   80255e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010d7:	b8 07 00 00 00       	mov    $0x7,%eax
  8010dc:	cd 30                	int    $0x30
  8010de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 12                	jns    8010fa <fork+0x36>
		panic("sys_exofork: %e", forkid);
  8010e8:	50                   	push   %eax
  8010e9:	68 94 2e 80 00       	push   $0x802e94
  8010ee:	6a 6d                	push   $0x6d
  8010f0:	68 5f 2e 80 00       	push   $0x802e5f
  8010f5:	e8 ed f1 ff ff       	call   8002e7 <_panic>
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  801101:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801105:	75 21                	jne    801128 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  801107:	e8 06 fc ff ff       	call   800d12 <sys_getenvid>
  80110c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801111:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801119:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80111e:	b8 00 00 00 00       	mov    $0x0,%eax
  801123:	e9 9c 01 00 00       	jmp    8012c4 <fork+0x200>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  801128:	89 d8                	mov    %ebx,%eax
  80112a:	c1 e8 16             	shr    $0x16,%eax
  80112d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801134:	a8 01                	test   $0x1,%al
  801136:	0f 84 f3 00 00 00    	je     80122f <fork+0x16b>
  80113c:	89 d8                	mov    %ebx,%eax
  80113e:	c1 e8 0c             	shr    $0xc,%eax
  801141:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	0f 84 de 00 00 00    	je     80122f <fork+0x16b>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  801151:	89 c6                	mov    %eax,%esi
  801153:	c1 e6 0c             	shl    $0xc,%esi
        if(uvpt[pn] & PTE_SHARE) {
  801156:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80115d:	f6 c6 04             	test   $0x4,%dh
  801160:	74 37                	je     801199 <fork+0xd5>
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
  801162:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	25 07 0e 00 00       	and    $0xe07,%eax
  801171:	50                   	push   %eax
  801172:	56                   	push   %esi
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	6a 00                	push   $0x0
  801177:	e8 17 fc ff ff       	call   800d93 <sys_page_map>
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	0f 89 a8 00 00 00    	jns    80122f <fork+0x16b>
                        panic("sys_page_map on new page fails %e \n", r);
  801187:	50                   	push   %eax
  801188:	68 f0 2d 80 00       	push   $0x802df0
  80118d:	6a 49                	push   $0x49
  80118f:	68 5f 2e 80 00       	push   $0x802e5f
  801194:	e8 4e f1 ff ff       	call   8002e7 <_panic>
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  801199:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a0:	f6 c6 08             	test   $0x8,%dh
  8011a3:	75 0b                	jne    8011b0 <fork+0xec>
  8011a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ac:	a8 02                	test   $0x2,%al
  8011ae:	74 57                	je     801207 <fork+0x143>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	68 05 08 00 00       	push   $0x805
  8011b8:	56                   	push   %esi
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	6a 00                	push   $0x0
  8011bd:	e8 d1 fb ff ff       	call   800d93 <sys_page_map>
  8011c2:	83 c4 20             	add    $0x20,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	79 12                	jns    8011db <fork+0x117>
                        panic("sys_page_map on new page fails %e \n", r);
  8011c9:	50                   	push   %eax
  8011ca:	68 f0 2d 80 00       	push   $0x802df0
  8011cf:	6a 4c                	push   $0x4c
  8011d1:	68 5f 2e 80 00       	push   $0x802e5f
  8011d6:	e8 0c f1 ff ff       	call   8002e7 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	68 05 08 00 00       	push   $0x805
  8011e3:	56                   	push   %esi
  8011e4:	6a 00                	push   $0x0
  8011e6:	56                   	push   %esi
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 a5 fb ff ff       	call   800d93 <sys_page_map>
  8011ee:	83 c4 20             	add    $0x20,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 3a                	jns    80122f <fork+0x16b>
                        panic("sys_page_map on current page fails %e\n", r);
  8011f5:	50                   	push   %eax
  8011f6:	68 14 2e 80 00       	push   $0x802e14
  8011fb:	6a 4e                	push   $0x4e
  8011fd:	68 5f 2e 80 00       	push   $0x802e5f
  801202:	e8 e0 f0 ff ff       	call   8002e7 <_panic>
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	6a 05                	push   $0x5
  80120c:	56                   	push   %esi
  80120d:	57                   	push   %edi
  80120e:	56                   	push   %esi
  80120f:	6a 00                	push   $0x0
  801211:	e8 7d fb ff ff       	call   800d93 <sys_page_map>
  801216:	83 c4 20             	add    $0x20,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	79 12                	jns    80122f <fork+0x16b>
                        panic("sys_page_map on new page fails %e\n", r);
  80121d:	50                   	push   %eax
  80121e:	68 3c 2e 80 00       	push   $0x802e3c
  801223:	6a 50                	push   $0x50
  801225:	68 5f 2e 80 00       	push   $0x802e5f
  80122a:	e8 b8 f0 ff ff       	call   8002e7 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  80122f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801235:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80123b:	0f 85 e7 fe ff ff    	jne    801128 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	6a 07                	push   $0x7
  801246:	68 00 f0 bf ee       	push   $0xeebff000
  80124b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124e:	e8 fd fa ff ff       	call   800d50 <sys_page_alloc>
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	79 14                	jns    80126e <fork+0x1aa>
                panic("user stack alloc failure\n");	
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	68 a4 2e 80 00       	push   $0x802ea4
  801262:	6a 76                	push   $0x76
  801264:	68 5f 2e 80 00       	push   $0x802e5f
  801269:	e8 79 f0 ff ff       	call   8002e7 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	68 cd 25 80 00       	push   $0x8025cd
  801276:	ff 75 e4             	pushl  -0x1c(%ebp)
  801279:	e8 1d fc ff ff       	call   800e9b <sys_env_set_pgfault_upcall>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	79 14                	jns    801299 <fork+0x1d5>
                panic("set pgfault upcall fails %d\n", forkid);
  801285:	ff 75 e4             	pushl  -0x1c(%ebp)
  801288:	68 be 2e 80 00       	push   $0x802ebe
  80128d:	6a 79                	push   $0x79
  80128f:	68 5f 2e 80 00       	push   $0x802e5f
  801294:	e8 4e f0 ff ff       	call   8002e7 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	6a 02                	push   $0x2
  80129e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a1:	e8 71 fb ff ff       	call   800e17 <sys_env_set_status>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	79 14                	jns    8012c1 <fork+0x1fd>
                panic("set %d runnable fails\n", forkid);
  8012ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b0:	68 db 2e 80 00       	push   $0x802edb
  8012b5:	6a 7b                	push   $0x7b
  8012b7:	68 5f 2e 80 00       	push   $0x802e5f
  8012bc:	e8 26 f0 ff ff       	call   8002e7 <_panic>
        return forkid;
  8012c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8012c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5e                   	pop    %esi
  8012c9:	5f                   	pop    %edi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <sfork>:

// Challenge!
int
sfork(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012d2:	68 f2 2e 80 00       	push   $0x802ef2
  8012d7:	68 83 00 00 00       	push   $0x83
  8012dc:	68 5f 2e 80 00       	push   $0x802e5f
  8012e1:	e8 01 f0 ff ff       	call   8002e7 <_panic>

008012e6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
  8012eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012fb:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	50                   	push   %eax
  801302:	e8 f9 fb ff ff       	call   800f00 <sys_ipc_recv>
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	79 16                	jns    801324 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80130e:	85 f6                	test   %esi,%esi
  801310:	74 06                	je     801318 <ipc_recv+0x32>
  801312:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801318:	85 db                	test   %ebx,%ebx
  80131a:	74 2c                	je     801348 <ipc_recv+0x62>
  80131c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801322:	eb 24                	jmp    801348 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801324:	85 f6                	test   %esi,%esi
  801326:	74 0a                	je     801332 <ipc_recv+0x4c>
  801328:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80132d:	8b 40 74             	mov    0x74(%eax),%eax
  801330:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801332:	85 db                	test   %ebx,%ebx
  801334:	74 0a                	je     801340 <ipc_recv+0x5a>
  801336:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80133b:	8b 40 78             	mov    0x78(%eax),%eax
  80133e:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801340:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801345:	8b 40 70             	mov    0x70(%eax),%eax
}
  801348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	57                   	push   %edi
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	8b 7d 08             	mov    0x8(%ebp),%edi
  80135b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80135e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801361:	85 db                	test   %ebx,%ebx
  801363:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801368:	0f 44 d8             	cmove  %eax,%ebx
  80136b:	eb 1c                	jmp    801389 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80136d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801370:	74 12                	je     801384 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801372:	50                   	push   %eax
  801373:	68 08 2f 80 00       	push   $0x802f08
  801378:	6a 39                	push   $0x39
  80137a:	68 23 2f 80 00       	push   $0x802f23
  80137f:	e8 63 ef ff ff       	call   8002e7 <_panic>
                 sys_yield();
  801384:	e8 a8 f9 ff ff       	call   800d31 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801389:	ff 75 14             	pushl  0x14(%ebp)
  80138c:	53                   	push   %ebx
  80138d:	56                   	push   %esi
  80138e:	57                   	push   %edi
  80138f:	e8 49 fb ff ff       	call   800edd <sys_ipc_try_send>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 d2                	js     80136d <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80139b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139e:	5b                   	pop    %ebx
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013ae:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013b1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b7:	8b 52 50             	mov    0x50(%edx),%edx
  8013ba:	39 ca                	cmp    %ecx,%edx
  8013bc:	75 0d                	jne    8013cb <ipc_find_env+0x28>
			return envs[i].env_id;
  8013be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013c1:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8013c6:	8b 40 08             	mov    0x8(%eax),%eax
  8013c9:	eb 0e                	jmp    8013d9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013cb:	83 c0 01             	add    $0x1,%eax
  8013ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d3:	75 d9                	jne    8013ae <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d5:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f1:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801408:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80140d:	89 c2                	mov    %eax,%edx
  80140f:	c1 ea 16             	shr    $0x16,%edx
  801412:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801419:	f6 c2 01             	test   $0x1,%dl
  80141c:	74 11                	je     80142f <fd_alloc+0x2d>
  80141e:	89 c2                	mov    %eax,%edx
  801420:	c1 ea 0c             	shr    $0xc,%edx
  801423:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142a:	f6 c2 01             	test   $0x1,%dl
  80142d:	75 09                	jne    801438 <fd_alloc+0x36>
			*fd_store = fd;
  80142f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801431:	b8 00 00 00 00       	mov    $0x0,%eax
  801436:	eb 17                	jmp    80144f <fd_alloc+0x4d>
  801438:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80143d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801442:	75 c9                	jne    80140d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801444:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80144a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801457:	83 f8 1f             	cmp    $0x1f,%eax
  80145a:	77 36                	ja     801492 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80145c:	c1 e0 0c             	shl    $0xc,%eax
  80145f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801464:	89 c2                	mov    %eax,%edx
  801466:	c1 ea 16             	shr    $0x16,%edx
  801469:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801470:	f6 c2 01             	test   $0x1,%dl
  801473:	74 24                	je     801499 <fd_lookup+0x48>
  801475:	89 c2                	mov    %eax,%edx
  801477:	c1 ea 0c             	shr    $0xc,%edx
  80147a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	74 1a                	je     8014a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801486:	8b 55 0c             	mov    0xc(%ebp),%edx
  801489:	89 02                	mov    %eax,(%edx)
	return 0;
  80148b:	b8 00 00 00 00       	mov    $0x0,%eax
  801490:	eb 13                	jmp    8014a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801497:	eb 0c                	jmp    8014a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149e:	eb 05                	jmp    8014a5 <fd_lookup+0x54>
  8014a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	eb 13                	jmp    8014ca <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8014b7:	39 08                	cmp    %ecx,(%eax)
  8014b9:	75 0c                	jne    8014c7 <dev_lookup+0x20>
			*dev = devtab[i];
  8014bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c5:	eb 36                	jmp    8014fd <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014c7:	83 c2 01             	add    $0x1,%edx
  8014ca:	8b 04 95 ac 2f 80 00 	mov    0x802fac(,%edx,4),%eax
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	75 e2                	jne    8014b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d5:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	51                   	push   %ecx
  8014e1:	50                   	push   %eax
  8014e2:	68 30 2f 80 00       	push   $0x802f30
  8014e7:	e8 d4 ee ff ff       	call   8003c0 <cprintf>
	*dev = 0;
  8014ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 10             	sub    $0x10,%esp
  801507:	8b 75 08             	mov    0x8(%ebp),%esi
  80150a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801510:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801511:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801517:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151a:	50                   	push   %eax
  80151b:	e8 31 ff ff ff       	call   801451 <fd_lookup>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 05                	js     80152c <fd_close+0x2d>
	    || fd != fd2)
  801527:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80152a:	74 0c                	je     801538 <fd_close+0x39>
		return (must_exist ? r : 0);
  80152c:	84 db                	test   %bl,%bl
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	0f 44 c2             	cmove  %edx,%eax
  801536:	eb 41                	jmp    801579 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	ff 36                	pushl  (%esi)
  801541:	e8 61 ff ff ff       	call   8014a7 <dev_lookup>
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 1a                	js     801569 <fd_close+0x6a>
		if (dev->dev_close)
  80154f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801552:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801555:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80155a:	85 c0                	test   %eax,%eax
  80155c:	74 0b                	je     801569 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	56                   	push   %esi
  801562:	ff d0                	call   *%eax
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	56                   	push   %esi
  80156d:	6a 00                	push   $0x0
  80156f:	e8 61 f8 ff ff       	call   800dd5 <sys_page_unmap>
	return r;
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	89 d8                	mov    %ebx,%eax
}
  801579:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	ff 75 08             	pushl  0x8(%ebp)
  80158d:	e8 bf fe ff ff       	call   801451 <fd_lookup>
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	85 d2                	test   %edx,%edx
  801599:	78 10                	js     8015ab <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	6a 01                	push   $0x1
  8015a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a3:	e8 57 ff ff ff       	call   8014ff <fd_close>
  8015a8:	83 c4 10             	add    $0x10,%esp
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <close_all>:

void
close_all(void)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	e8 be ff ff ff       	call   801580 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c2:	83 c3 01             	add    $0x1,%ebx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	83 fb 20             	cmp    $0x20,%ebx
  8015cb:	75 ec                	jne    8015b9 <close_all+0xc>
		close(i);
}
  8015cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	57                   	push   %edi
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 2c             	sub    $0x2c,%esp
  8015db:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	ff 75 08             	pushl  0x8(%ebp)
  8015e5:	e8 67 fe ff ff       	call   801451 <fd_lookup>
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	85 d2                	test   %edx,%edx
  8015f1:	0f 88 c1 00 00 00    	js     8016b8 <dup+0xe6>
		return r;
	close(newfdnum);
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	56                   	push   %esi
  8015fb:	e8 80 ff ff ff       	call   801580 <close>

	newfd = INDEX2FD(newfdnum);
  801600:	89 f3                	mov    %esi,%ebx
  801602:	c1 e3 0c             	shl    $0xc,%ebx
  801605:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80160b:	83 c4 04             	add    $0x4,%esp
  80160e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801611:	e8 d5 fd ff ff       	call   8013eb <fd2data>
  801616:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801618:	89 1c 24             	mov    %ebx,(%esp)
  80161b:	e8 cb fd ff ff       	call   8013eb <fd2data>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801626:	89 f8                	mov    %edi,%eax
  801628:	c1 e8 16             	shr    $0x16,%eax
  80162b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801632:	a8 01                	test   $0x1,%al
  801634:	74 37                	je     80166d <dup+0x9b>
  801636:	89 f8                	mov    %edi,%eax
  801638:	c1 e8 0c             	shr    $0xc,%eax
  80163b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801642:	f6 c2 01             	test   $0x1,%dl
  801645:	74 26                	je     80166d <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801647:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	25 07 0e 00 00       	and    $0xe07,%eax
  801656:	50                   	push   %eax
  801657:	ff 75 d4             	pushl  -0x2c(%ebp)
  80165a:	6a 00                	push   $0x0
  80165c:	57                   	push   %edi
  80165d:	6a 00                	push   $0x0
  80165f:	e8 2f f7 ff ff       	call   800d93 <sys_page_map>
  801664:	89 c7                	mov    %eax,%edi
  801666:	83 c4 20             	add    $0x20,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 2e                	js     80169b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801670:	89 d0                	mov    %edx,%eax
  801672:	c1 e8 0c             	shr    $0xc,%eax
  801675:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	25 07 0e 00 00       	and    $0xe07,%eax
  801684:	50                   	push   %eax
  801685:	53                   	push   %ebx
  801686:	6a 00                	push   $0x0
  801688:	52                   	push   %edx
  801689:	6a 00                	push   $0x0
  80168b:	e8 03 f7 ff ff       	call   800d93 <sys_page_map>
  801690:	89 c7                	mov    %eax,%edi
  801692:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801695:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801697:	85 ff                	test   %edi,%edi
  801699:	79 1d                	jns    8016b8 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	53                   	push   %ebx
  80169f:	6a 00                	push   $0x0
  8016a1:	e8 2f f7 ff ff       	call   800dd5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 22 f7 ff ff       	call   800dd5 <sys_page_unmap>
	return r;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	89 f8                	mov    %edi,%eax
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 14             	sub    $0x14,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	53                   	push   %ebx
  8016cf:	e8 7d fd ff ff       	call   801451 <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 6d                	js     80174a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e7:	ff 30                	pushl  (%eax)
  8016e9:	e8 b9 fd ff ff       	call   8014a7 <dev_lookup>
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 4c                	js     801741 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f8:	8b 42 08             	mov    0x8(%edx),%eax
  8016fb:	83 e0 03             	and    $0x3,%eax
  8016fe:	83 f8 01             	cmp    $0x1,%eax
  801701:	75 21                	jne    801724 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801703:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801708:	8b 40 48             	mov    0x48(%eax),%eax
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	53                   	push   %ebx
  80170f:	50                   	push   %eax
  801710:	68 71 2f 80 00       	push   $0x802f71
  801715:	e8 a6 ec ff ff       	call   8003c0 <cprintf>
		return -E_INVAL;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801722:	eb 26                	jmp    80174a <read+0x8a>
	}
	if (!dev->dev_read)
  801724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801727:	8b 40 08             	mov    0x8(%eax),%eax
  80172a:	85 c0                	test   %eax,%eax
  80172c:	74 17                	je     801745 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	ff 75 10             	pushl  0x10(%ebp)
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	52                   	push   %edx
  801738:	ff d0                	call   *%eax
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	eb 09                	jmp    80174a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801741:	89 c2                	mov    %eax,%edx
  801743:	eb 05                	jmp    80174a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801745:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80174a:	89 d0                	mov    %edx,%eax
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	57                   	push   %edi
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80175d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801760:	bb 00 00 00 00       	mov    $0x0,%ebx
  801765:	eb 21                	jmp    801788 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	89 f0                	mov    %esi,%eax
  80176c:	29 d8                	sub    %ebx,%eax
  80176e:	50                   	push   %eax
  80176f:	89 d8                	mov    %ebx,%eax
  801771:	03 45 0c             	add    0xc(%ebp),%eax
  801774:	50                   	push   %eax
  801775:	57                   	push   %edi
  801776:	e8 45 ff ff ff       	call   8016c0 <read>
		if (m < 0)
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 0c                	js     80178e <readn+0x3d>
			return m;
		if (m == 0)
  801782:	85 c0                	test   %eax,%eax
  801784:	74 06                	je     80178c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801786:	01 c3                	add    %eax,%ebx
  801788:	39 f3                	cmp    %esi,%ebx
  80178a:	72 db                	jb     801767 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80178c:	89 d8                	mov    %ebx,%eax
}
  80178e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5f                   	pop    %edi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 14             	sub    $0x14,%esp
  80179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	53                   	push   %ebx
  8017a5:	e8 a7 fc ff ff       	call   801451 <fd_lookup>
  8017aa:	83 c4 08             	add    $0x8,%esp
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 68                	js     80181b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b9:	50                   	push   %eax
  8017ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bd:	ff 30                	pushl  (%eax)
  8017bf:	e8 e3 fc ff ff       	call   8014a7 <dev_lookup>
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 47                	js     801812 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d2:	75 21                	jne    8017f5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d4:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8017d9:	8b 40 48             	mov    0x48(%eax),%eax
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	53                   	push   %ebx
  8017e0:	50                   	push   %eax
  8017e1:	68 8d 2f 80 00       	push   $0x802f8d
  8017e6:	e8 d5 eb ff ff       	call   8003c0 <cprintf>
		return -E_INVAL;
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f3:	eb 26                	jmp    80181b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	74 17                	je     801816 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	ff 75 10             	pushl  0x10(%ebp)
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	50                   	push   %eax
  801809:	ff d2                	call   *%edx
  80180b:	89 c2                	mov    %eax,%edx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	eb 09                	jmp    80181b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801812:	89 c2                	mov    %eax,%edx
  801814:	eb 05                	jmp    80181b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801816:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80181b:	89 d0                	mov    %edx,%eax
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <seek>:

int
seek(int fdnum, off_t offset)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801828:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	ff 75 08             	pushl  0x8(%ebp)
  80182f:	e8 1d fc ff ff       	call   801451 <fd_lookup>
  801834:	83 c4 08             	add    $0x8,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 0e                	js     801849 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80183b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80183e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801841:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 14             	sub    $0x14,%esp
  801852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	53                   	push   %ebx
  80185a:	e8 f2 fb ff ff       	call   801451 <fd_lookup>
  80185f:	83 c4 08             	add    $0x8,%esp
  801862:	89 c2                	mov    %eax,%edx
  801864:	85 c0                	test   %eax,%eax
  801866:	78 65                	js     8018cd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186e:	50                   	push   %eax
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	ff 30                	pushl  (%eax)
  801874:	e8 2e fc ff ff       	call   8014a7 <dev_lookup>
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 44                	js     8018c4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801883:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801887:	75 21                	jne    8018aa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801889:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188e:	8b 40 48             	mov    0x48(%eax),%eax
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	53                   	push   %ebx
  801895:	50                   	push   %eax
  801896:	68 50 2f 80 00       	push   $0x802f50
  80189b:	e8 20 eb ff ff       	call   8003c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a8:	eb 23                	jmp    8018cd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ad:	8b 52 18             	mov    0x18(%edx),%edx
  8018b0:	85 d2                	test   %edx,%edx
  8018b2:	74 14                	je     8018c8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	50                   	push   %eax
  8018bb:	ff d2                	call   *%edx
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	eb 09                	jmp    8018cd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	eb 05                	jmp    8018cd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018cd:	89 d0                	mov    %edx,%eax
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 14             	sub    $0x14,%esp
  8018db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 67 fb ff ff       	call   801451 <fd_lookup>
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 58                	js     80194b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fd:	ff 30                	pushl  (%eax)
  8018ff:	e8 a3 fb ff ff       	call   8014a7 <dev_lookup>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 37                	js     801942 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801912:	74 32                	je     801946 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801914:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801917:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191e:	00 00 00 
	stat->st_isdir = 0;
  801921:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801928:	00 00 00 
	stat->st_dev = dev;
  80192b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	ff 75 f0             	pushl  -0x10(%ebp)
  801938:	ff 50 14             	call   *0x14(%eax)
  80193b:	89 c2                	mov    %eax,%edx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	eb 09                	jmp    80194b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801942:	89 c2                	mov    %eax,%edx
  801944:	eb 05                	jmp    80194b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801946:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80194b:	89 d0                	mov    %edx,%eax
  80194d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	6a 00                	push   $0x0
  80195c:	ff 75 08             	pushl  0x8(%ebp)
  80195f:	e8 09 02 00 00       	call   801b6d <open>
  801964:	89 c3                	mov    %eax,%ebx
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 db                	test   %ebx,%ebx
  80196b:	78 1b                	js     801988 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	ff 75 0c             	pushl  0xc(%ebp)
  801973:	53                   	push   %ebx
  801974:	e8 5b ff ff ff       	call   8018d4 <fstat>
  801979:	89 c6                	mov    %eax,%esi
	close(fd);
  80197b:	89 1c 24             	mov    %ebx,(%esp)
  80197e:	e8 fd fb ff ff       	call   801580 <close>
	return r;
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	89 f0                	mov    %esi,%eax
}
  801988:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	89 c6                	mov    %eax,%esi
  801996:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801998:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80199f:	75 12                	jne    8019b3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	6a 01                	push   $0x1
  8019a6:	e8 f8 f9 ff ff       	call   8013a3 <ipc_find_env>
  8019ab:	a3 04 50 80 00       	mov    %eax,0x805004
  8019b0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b3:	6a 07                	push   $0x7
  8019b5:	68 00 60 80 00       	push   $0x806000
  8019ba:	56                   	push   %esi
  8019bb:	ff 35 04 50 80 00    	pushl  0x805004
  8019c1:	e8 89 f9 ff ff       	call   80134f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019c6:	83 c4 0c             	add    $0xc,%esp
  8019c9:	6a 00                	push   $0x0
  8019cb:	53                   	push   %ebx
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 13 f9 ff ff       	call   8012e6 <ipc_recv>
}
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fd:	e8 8d ff ff ff       	call   80198f <fsipc>
}
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1f:	e8 6b ff ff ff       	call   80198f <fsipc>
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	8b 40 0c             	mov    0xc(%eax),%eax
  801a36:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 05 00 00 00       	mov    $0x5,%eax
  801a45:	e8 45 ff ff ff       	call   80198f <fsipc>
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	85 d2                	test   %edx,%edx
  801a4e:	78 2c                	js     801a7c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	68 00 60 80 00       	push   $0x806000
  801a58:	53                   	push   %ebx
  801a59:	e8 e9 ee ff ff       	call   800947 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5e:	a1 80 60 80 00       	mov    0x806080,%eax
  801a63:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a69:	a1 84 60 80 00       	mov    0x806084,%eax
  801a6e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	57                   	push   %edi
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	8b 40 0c             	mov    0xc(%eax),%eax
  801a93:	a3 00 60 80 00       	mov    %eax,0x806000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801a9b:	eb 3d                	jmp    801ada <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801a9d:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801aa3:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801aa8:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801aab:	83 ec 04             	sub    $0x4,%esp
  801aae:	57                   	push   %edi
  801aaf:	53                   	push   %ebx
  801ab0:	68 08 60 80 00       	push   $0x806008
  801ab5:	e8 1f f0 ff ff       	call   800ad9 <memmove>
                fsipcbuf.write.req_n = tmp; 
  801aba:	89 3d 04 60 80 00    	mov    %edi,0x806004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac5:	b8 04 00 00 00       	mov    $0x4,%eax
  801aca:	e8 c0 fe ff ff       	call   80198f <fsipc>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 0d                	js     801ae3 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801ad6:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801ad8:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801ada:	85 f6                	test   %esi,%esi
  801adc:	75 bf                	jne    801a9d <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801ade:	89 d8                	mov    %ebx,%eax
  801ae0:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	8b 40 0c             	mov    0xc(%eax),%eax
  801af9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801afe:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	b8 03 00 00 00       	mov    $0x3,%eax
  801b0e:	e8 7c fe ff ff       	call   80198f <fsipc>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 4b                	js     801b64 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b19:	39 c6                	cmp    %eax,%esi
  801b1b:	73 16                	jae    801b33 <devfile_read+0x48>
  801b1d:	68 c0 2f 80 00       	push   $0x802fc0
  801b22:	68 c7 2f 80 00       	push   $0x802fc7
  801b27:	6a 7c                	push   $0x7c
  801b29:	68 dc 2f 80 00       	push   $0x802fdc
  801b2e:	e8 b4 e7 ff ff       	call   8002e7 <_panic>
	assert(r <= PGSIZE);
  801b33:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b38:	7e 16                	jle    801b50 <devfile_read+0x65>
  801b3a:	68 e7 2f 80 00       	push   $0x802fe7
  801b3f:	68 c7 2f 80 00       	push   $0x802fc7
  801b44:	6a 7d                	push   $0x7d
  801b46:	68 dc 2f 80 00       	push   $0x802fdc
  801b4b:	e8 97 e7 ff ff       	call   8002e7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b50:	83 ec 04             	sub    $0x4,%esp
  801b53:	50                   	push   %eax
  801b54:	68 00 60 80 00       	push   $0x806000
  801b59:	ff 75 0c             	pushl  0xc(%ebp)
  801b5c:	e8 78 ef ff ff       	call   800ad9 <memmove>
	return r;
  801b61:	83 c4 10             	add    $0x10,%esp
}
  801b64:	89 d8                	mov    %ebx,%eax
  801b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	53                   	push   %ebx
  801b71:	83 ec 20             	sub    $0x20,%esp
  801b74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b77:	53                   	push   %ebx
  801b78:	e8 91 ed ff ff       	call   80090e <strlen>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b85:	7f 67                	jg     801bee <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 6f f8 ff ff       	call   801402 <fd_alloc>
  801b93:	83 c4 10             	add    $0x10,%esp
		return r;
  801b96:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 57                	js     801bf3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	53                   	push   %ebx
  801ba0:	68 00 60 80 00       	push   $0x806000
  801ba5:	e8 9d ed ff ff       	call   800947 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bad:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801bba:	e8 d0 fd ff ff       	call   80198f <fsipc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	79 14                	jns    801bdc <open+0x6f>
		fd_close(fd, 0);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	6a 00                	push   $0x0
  801bcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd0:	e8 2a f9 ff ff       	call   8014ff <fd_close>
		return r;
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	89 da                	mov    %ebx,%edx
  801bda:	eb 17                	jmp    801bf3 <open+0x86>
	}

	return fd2num(fd);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801be2:	e8 f4 f7 ff ff       	call   8013db <fd2num>
  801be7:	89 c2                	mov    %eax,%edx
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	eb 05                	jmp    801bf3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bee:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf3:	89 d0                	mov    %edx,%eax
  801bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c00:	ba 00 00 00 00       	mov    $0x0,%edx
  801c05:	b8 08 00 00 00       	mov    $0x8,%eax
  801c0a:	e8 80 fd ff ff       	call   80198f <fsipc>
}
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c17:	68 f3 2f 80 00       	push   $0x802ff3
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	e8 23 ed ff ff       	call   800947 <strcpy>
	return 0;
}
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 10             	sub    $0x10,%esp
  801c32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c35:	53                   	push   %ebx
  801c36:	e8 b6 09 00 00       	call   8025f1 <pageref>
  801c3b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c3e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c43:	83 f8 01             	cmp    $0x1,%eax
  801c46:	75 10                	jne    801c58 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c48:	83 ec 0c             	sub    $0xc,%esp
  801c4b:	ff 73 0c             	pushl  0xc(%ebx)
  801c4e:	e8 ca 02 00 00       	call   801f1d <nsipc_close>
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c58:	89 d0                	mov    %edx,%eax
  801c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c65:	6a 00                	push   $0x0
  801c67:	ff 75 10             	pushl  0x10(%ebp)
  801c6a:	ff 75 0c             	pushl  0xc(%ebp)
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	ff 70 0c             	pushl  0xc(%eax)
  801c73:	e8 82 03 00 00       	call   801ffa <nsipc_send>
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c80:	6a 00                	push   $0x0
  801c82:	ff 75 10             	pushl  0x10(%ebp)
  801c85:	ff 75 0c             	pushl  0xc(%ebp)
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	ff 70 0c             	pushl  0xc(%eax)
  801c8e:	e8 fb 02 00 00       	call   801f8e <nsipc_recv>
}
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c9b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c9e:	52                   	push   %edx
  801c9f:	50                   	push   %eax
  801ca0:	e8 ac f7 ff ff       	call   801451 <fd_lookup>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 17                	js     801cc3 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801cb5:	39 08                	cmp    %ecx,(%eax)
  801cb7:	75 05                	jne    801cbe <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cb9:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbc:	eb 05                	jmp    801cc3 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cbe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	56                   	push   %esi
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 1c             	sub    $0x1c,%esp
  801ccd:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ccf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd2:	50                   	push   %eax
  801cd3:	e8 2a f7 ff ff       	call   801402 <fd_alloc>
  801cd8:	89 c3                	mov    %eax,%ebx
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 1b                	js     801cfc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	68 07 04 00 00       	push   $0x407
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 5d f0 ff ff       	call   800d50 <sys_page_alloc>
  801cf3:	89 c3                	mov    %eax,%ebx
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	79 10                	jns    801d0c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	56                   	push   %esi
  801d00:	e8 18 02 00 00       	call   801f1d <nsipc_close>
		return r;
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	eb 24                	jmp    801d30 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d0c:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1a:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801d21:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	52                   	push   %edx
  801d28:	e8 ae f6 ff ff       	call   8013db <fd2num>
  801d2d:	83 c4 10             	add    $0x10,%esp
}
  801d30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	e8 50 ff ff ff       	call   801c95 <fd2sockid>
		return r;
  801d45:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 1f                	js     801d6a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	ff 75 10             	pushl  0x10(%ebp)
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	50                   	push   %eax
  801d55:	e8 1c 01 00 00       	call   801e76 <nsipc_accept>
  801d5a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d5d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	78 07                	js     801d6a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d63:	e8 5d ff ff ff       	call   801cc5 <alloc_sockfd>
  801d68:	89 c1                	mov    %eax,%ecx
}
  801d6a:	89 c8                	mov    %ecx,%eax
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	e8 19 ff ff ff       	call   801c95 <fd2sockid>
  801d7c:	89 c2                	mov    %eax,%edx
  801d7e:	85 d2                	test   %edx,%edx
  801d80:	78 12                	js     801d94 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801d82:	83 ec 04             	sub    $0x4,%esp
  801d85:	ff 75 10             	pushl  0x10(%ebp)
  801d88:	ff 75 0c             	pushl  0xc(%ebp)
  801d8b:	52                   	push   %edx
  801d8c:	e8 35 01 00 00       	call   801ec6 <nsipc_bind>
  801d91:	83 c4 10             	add    $0x10,%esp
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <shutdown>:

int
shutdown(int s, int how)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	e8 f1 fe ff ff       	call   801c95 <fd2sockid>
  801da4:	89 c2                	mov    %eax,%edx
  801da6:	85 d2                	test   %edx,%edx
  801da8:	78 0f                	js     801db9 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	52                   	push   %edx
  801db1:	e8 45 01 00 00       	call   801efb <nsipc_shutdown>
  801db6:	83 c4 10             	add    $0x10,%esp
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc4:	e8 cc fe ff ff       	call   801c95 <fd2sockid>
  801dc9:	89 c2                	mov    %eax,%edx
  801dcb:	85 d2                	test   %edx,%edx
  801dcd:	78 12                	js     801de1 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	ff 75 10             	pushl  0x10(%ebp)
  801dd5:	ff 75 0c             	pushl  0xc(%ebp)
  801dd8:	52                   	push   %edx
  801dd9:	e8 59 01 00 00       	call   801f37 <nsipc_connect>
  801dde:	83 c4 10             	add    $0x10,%esp
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <listen>:

int
listen(int s, int backlog)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	e8 a4 fe ff ff       	call   801c95 <fd2sockid>
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	85 d2                	test   %edx,%edx
  801df5:	78 0f                	js     801e06 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	ff 75 0c             	pushl  0xc(%ebp)
  801dfd:	52                   	push   %edx
  801dfe:	e8 69 01 00 00       	call   801f6c <nsipc_listen>
  801e03:	83 c4 10             	add    $0x10,%esp
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e0e:	ff 75 10             	pushl  0x10(%ebp)
  801e11:	ff 75 0c             	pushl  0xc(%ebp)
  801e14:	ff 75 08             	pushl  0x8(%ebp)
  801e17:	e8 3c 02 00 00       	call   802058 <nsipc_socket>
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 d2                	test   %edx,%edx
  801e23:	78 05                	js     801e2a <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801e25:	e8 9b fe ff ff       	call   801cc5 <alloc_sockfd>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 04             	sub    $0x4,%esp
  801e33:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e35:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  801e3c:	75 12                	jne    801e50 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	6a 02                	push   $0x2
  801e43:	e8 5b f5 ff ff       	call   8013a3 <ipc_find_env>
  801e48:	a3 08 50 80 00       	mov    %eax,0x805008
  801e4d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e50:	6a 07                	push   $0x7
  801e52:	68 00 70 80 00       	push   $0x807000
  801e57:	53                   	push   %ebx
  801e58:	ff 35 08 50 80 00    	pushl  0x805008
  801e5e:	e8 ec f4 ff ff       	call   80134f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e63:	83 c4 0c             	add    $0xc,%esp
  801e66:	6a 00                	push   $0x0
  801e68:	6a 00                	push   $0x0
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 75 f4 ff ff       	call   8012e6 <ipc_recv>
}
  801e71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	56                   	push   %esi
  801e7a:	53                   	push   %ebx
  801e7b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e81:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e86:	8b 06                	mov    (%esi),%eax
  801e88:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e92:	e8 95 ff ff ff       	call   801e2c <nsipc>
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 20                	js     801ebd <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e9d:	83 ec 04             	sub    $0x4,%esp
  801ea0:	ff 35 10 70 80 00    	pushl  0x807010
  801ea6:	68 00 70 80 00       	push   $0x807000
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	e8 26 ec ff ff       	call   800ad9 <memmove>
		*addrlen = ret->ret_addrlen;
  801eb3:	a1 10 70 80 00       	mov    0x807010,%eax
  801eb8:	89 06                	mov    %eax,(%esi)
  801eba:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ebd:	89 d8                	mov    %ebx,%eax
  801ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5e                   	pop    %esi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ed8:	53                   	push   %ebx
  801ed9:	ff 75 0c             	pushl  0xc(%ebp)
  801edc:	68 04 70 80 00       	push   $0x807004
  801ee1:	e8 f3 eb ff ff       	call   800ad9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ee6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801eec:	b8 02 00 00 00       	mov    $0x2,%eax
  801ef1:	e8 36 ff ff ff       	call   801e2c <nsipc>
}
  801ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f01:	8b 45 08             	mov    0x8(%ebp),%eax
  801f04:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f11:	b8 03 00 00 00       	mov    $0x3,%eax
  801f16:	e8 11 ff ff ff       	call   801e2c <nsipc>
}
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <nsipc_close>:

int
nsipc_close(int s)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f2b:	b8 04 00 00 00       	mov    $0x4,%eax
  801f30:	e8 f7 fe ff ff       	call   801e2c <nsipc>
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	53                   	push   %ebx
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f41:	8b 45 08             	mov    0x8(%ebp),%eax
  801f44:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f49:	53                   	push   %ebx
  801f4a:	ff 75 0c             	pushl  0xc(%ebp)
  801f4d:	68 04 70 80 00       	push   $0x807004
  801f52:	e8 82 eb ff ff       	call   800ad9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f57:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f5d:	b8 05 00 00 00       	mov    $0x5,%eax
  801f62:	e8 c5 fe ff ff       	call   801e2c <nsipc>
}
  801f67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f72:	8b 45 08             	mov    0x8(%ebp),%eax
  801f75:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f82:	b8 06 00 00 00       	mov    $0x6,%eax
  801f87:	e8 a0 fe ff ff       	call   801e2c <nsipc>
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801f9e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801fa4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fac:	b8 07 00 00 00       	mov    $0x7,%eax
  801fb1:	e8 76 fe ff ff       	call   801e2c <nsipc>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	78 35                	js     801ff1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fbc:	39 f0                	cmp    %esi,%eax
  801fbe:	7f 07                	jg     801fc7 <nsipc_recv+0x39>
  801fc0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fc5:	7e 16                	jle    801fdd <nsipc_recv+0x4f>
  801fc7:	68 ff 2f 80 00       	push   $0x802fff
  801fcc:	68 c7 2f 80 00       	push   $0x802fc7
  801fd1:	6a 62                	push   $0x62
  801fd3:	68 14 30 80 00       	push   $0x803014
  801fd8:	e8 0a e3 ff ff       	call   8002e7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	50                   	push   %eax
  801fe1:	68 00 70 80 00       	push   $0x807000
  801fe6:	ff 75 0c             	pushl  0xc(%ebp)
  801fe9:	e8 eb ea ff ff       	call   800ad9 <memmove>
  801fee:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ff1:	89 d8                	mov    %ebx,%eax
  801ff3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 04             	sub    $0x4,%esp
  802001:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802004:	8b 45 08             	mov    0x8(%ebp),%eax
  802007:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80200c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802012:	7e 16                	jle    80202a <nsipc_send+0x30>
  802014:	68 20 30 80 00       	push   $0x803020
  802019:	68 c7 2f 80 00       	push   $0x802fc7
  80201e:	6a 6d                	push   $0x6d
  802020:	68 14 30 80 00       	push   $0x803014
  802025:	e8 bd e2 ff ff       	call   8002e7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80202a:	83 ec 04             	sub    $0x4,%esp
  80202d:	53                   	push   %ebx
  80202e:	ff 75 0c             	pushl  0xc(%ebp)
  802031:	68 0c 70 80 00       	push   $0x80700c
  802036:	e8 9e ea ff ff       	call   800ad9 <memmove>
	nsipcbuf.send.req_size = size;
  80203b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802041:	8b 45 14             	mov    0x14(%ebp),%eax
  802044:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802049:	b8 08 00 00 00       	mov    $0x8,%eax
  80204e:	e8 d9 fd ff ff       	call   801e2c <nsipc>
}
  802053:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80205e:	8b 45 08             	mov    0x8(%ebp),%eax
  802061:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802066:	8b 45 0c             	mov    0xc(%ebp),%eax
  802069:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80206e:	8b 45 10             	mov    0x10(%ebp),%eax
  802071:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802076:	b8 09 00 00 00       	mov    $0x9,%eax
  80207b:	e8 ac fd ff ff       	call   801e2c <nsipc>
}
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	56                   	push   %esi
  802086:	53                   	push   %ebx
  802087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	ff 75 08             	pushl  0x8(%ebp)
  802090:	e8 56 f3 ff ff       	call   8013eb <fd2data>
  802095:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802097:	83 c4 08             	add    $0x8,%esp
  80209a:	68 2c 30 80 00       	push   $0x80302c
  80209f:	53                   	push   %ebx
  8020a0:	e8 a2 e8 ff ff       	call   800947 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020a5:	8b 56 04             	mov    0x4(%esi),%edx
  8020a8:	89 d0                	mov    %edx,%eax
  8020aa:	2b 06                	sub    (%esi),%eax
  8020ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020b9:	00 00 00 
	stat->st_dev = &devpipe;
  8020bc:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8020c3:	40 80 00 
	return 0;
}
  8020c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ce:	5b                   	pop    %ebx
  8020cf:	5e                   	pop    %esi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    

008020d2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	53                   	push   %ebx
  8020d6:	83 ec 0c             	sub    $0xc,%esp
  8020d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020dc:	53                   	push   %ebx
  8020dd:	6a 00                	push   $0x0
  8020df:	e8 f1 ec ff ff       	call   800dd5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020e4:	89 1c 24             	mov    %ebx,(%esp)
  8020e7:	e8 ff f2 ff ff       	call   8013eb <fd2data>
  8020ec:	83 c4 08             	add    $0x8,%esp
  8020ef:	50                   	push   %eax
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 de ec ff ff       	call   800dd5 <sys_page_unmap>
}
  8020f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	57                   	push   %edi
  802100:	56                   	push   %esi
  802101:	53                   	push   %ebx
  802102:	83 ec 1c             	sub    $0x1c,%esp
  802105:	89 c6                	mov    %eax,%esi
  802107:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80210a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80210f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802112:	83 ec 0c             	sub    $0xc,%esp
  802115:	56                   	push   %esi
  802116:	e8 d6 04 00 00       	call   8025f1 <pageref>
  80211b:	89 c7                	mov    %eax,%edi
  80211d:	83 c4 04             	add    $0x4,%esp
  802120:	ff 75 e4             	pushl  -0x1c(%ebp)
  802123:	e8 c9 04 00 00       	call   8025f1 <pageref>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	39 c7                	cmp    %eax,%edi
  80212d:	0f 94 c2             	sete   %dl
  802130:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802133:	8b 0d 0c 50 80 00    	mov    0x80500c,%ecx
  802139:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80213c:	39 fb                	cmp    %edi,%ebx
  80213e:	74 19                	je     802159 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  802140:	84 d2                	test   %dl,%dl
  802142:	74 c6                	je     80210a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802144:	8b 51 58             	mov    0x58(%ecx),%edx
  802147:	50                   	push   %eax
  802148:	52                   	push   %edx
  802149:	53                   	push   %ebx
  80214a:	68 33 30 80 00       	push   $0x803033
  80214f:	e8 6c e2 ff ff       	call   8003c0 <cprintf>
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	eb b1                	jmp    80210a <_pipeisclosed+0xe>
	}
}
  802159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215c:	5b                   	pop    %ebx
  80215d:	5e                   	pop    %esi
  80215e:	5f                   	pop    %edi
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    

00802161 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	57                   	push   %edi
  802165:	56                   	push   %esi
  802166:	53                   	push   %ebx
  802167:	83 ec 28             	sub    $0x28,%esp
  80216a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80216d:	56                   	push   %esi
  80216e:	e8 78 f2 ff ff       	call   8013eb <fd2data>
  802173:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	bf 00 00 00 00       	mov    $0x0,%edi
  80217d:	eb 4b                	jmp    8021ca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80217f:	89 da                	mov    %ebx,%edx
  802181:	89 f0                	mov    %esi,%eax
  802183:	e8 74 ff ff ff       	call   8020fc <_pipeisclosed>
  802188:	85 c0                	test   %eax,%eax
  80218a:	75 48                	jne    8021d4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80218c:	e8 a0 eb ff ff       	call   800d31 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802191:	8b 43 04             	mov    0x4(%ebx),%eax
  802194:	8b 0b                	mov    (%ebx),%ecx
  802196:	8d 51 20             	lea    0x20(%ecx),%edx
  802199:	39 d0                	cmp    %edx,%eax
  80219b:	73 e2                	jae    80217f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80219d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021a0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021a4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021a7:	89 c2                	mov    %eax,%edx
  8021a9:	c1 fa 1f             	sar    $0x1f,%edx
  8021ac:	89 d1                	mov    %edx,%ecx
  8021ae:	c1 e9 1b             	shr    $0x1b,%ecx
  8021b1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021b4:	83 e2 1f             	and    $0x1f,%edx
  8021b7:	29 ca                	sub    %ecx,%edx
  8021b9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021c1:	83 c0 01             	add    $0x1,%eax
  8021c4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021c7:	83 c7 01             	add    $0x1,%edi
  8021ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021cd:	75 c2                	jne    802191 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8021d2:	eb 05                	jmp    8021d9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5f                   	pop    %edi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	57                   	push   %edi
  8021e5:	56                   	push   %esi
  8021e6:	53                   	push   %ebx
  8021e7:	83 ec 18             	sub    $0x18,%esp
  8021ea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021ed:	57                   	push   %edi
  8021ee:	e8 f8 f1 ff ff       	call   8013eb <fd2data>
  8021f3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f5:	83 c4 10             	add    $0x10,%esp
  8021f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021fd:	eb 3d                	jmp    80223c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021ff:	85 db                	test   %ebx,%ebx
  802201:	74 04                	je     802207 <devpipe_read+0x26>
				return i;
  802203:	89 d8                	mov    %ebx,%eax
  802205:	eb 44                	jmp    80224b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802207:	89 f2                	mov    %esi,%edx
  802209:	89 f8                	mov    %edi,%eax
  80220b:	e8 ec fe ff ff       	call   8020fc <_pipeisclosed>
  802210:	85 c0                	test   %eax,%eax
  802212:	75 32                	jne    802246 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802214:	e8 18 eb ff ff       	call   800d31 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802219:	8b 06                	mov    (%esi),%eax
  80221b:	3b 46 04             	cmp    0x4(%esi),%eax
  80221e:	74 df                	je     8021ff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802220:	99                   	cltd   
  802221:	c1 ea 1b             	shr    $0x1b,%edx
  802224:	01 d0                	add    %edx,%eax
  802226:	83 e0 1f             	and    $0x1f,%eax
  802229:	29 d0                	sub    %edx,%eax
  80222b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802233:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802236:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802239:	83 c3 01             	add    $0x1,%ebx
  80223c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80223f:	75 d8                	jne    802219 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802241:	8b 45 10             	mov    0x10(%ebp),%eax
  802244:	eb 05                	jmp    80224b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802246:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80224b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80224e:	5b                   	pop    %ebx
  80224f:	5e                   	pop    %esi
  802250:	5f                   	pop    %edi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	56                   	push   %esi
  802257:	53                   	push   %ebx
  802258:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80225b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225e:	50                   	push   %eax
  80225f:	e8 9e f1 ff ff       	call   801402 <fd_alloc>
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	89 c2                	mov    %eax,%edx
  802269:	85 c0                	test   %eax,%eax
  80226b:	0f 88 2c 01 00 00    	js     80239d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802271:	83 ec 04             	sub    $0x4,%esp
  802274:	68 07 04 00 00       	push   $0x407
  802279:	ff 75 f4             	pushl  -0xc(%ebp)
  80227c:	6a 00                	push   $0x0
  80227e:	e8 cd ea ff ff       	call   800d50 <sys_page_alloc>
  802283:	83 c4 10             	add    $0x10,%esp
  802286:	89 c2                	mov    %eax,%edx
  802288:	85 c0                	test   %eax,%eax
  80228a:	0f 88 0d 01 00 00    	js     80239d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802296:	50                   	push   %eax
  802297:	e8 66 f1 ff ff       	call   801402 <fd_alloc>
  80229c:	89 c3                	mov    %eax,%ebx
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	0f 88 e2 00 00 00    	js     80238b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a9:	83 ec 04             	sub    $0x4,%esp
  8022ac:	68 07 04 00 00       	push   $0x407
  8022b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b4:	6a 00                	push   $0x0
  8022b6:	e8 95 ea ff ff       	call   800d50 <sys_page_alloc>
  8022bb:	89 c3                	mov    %eax,%ebx
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	0f 88 c3 00 00 00    	js     80238b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022c8:	83 ec 0c             	sub    $0xc,%esp
  8022cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ce:	e8 18 f1 ff ff       	call   8013eb <fd2data>
  8022d3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022d5:	83 c4 0c             	add    $0xc,%esp
  8022d8:	68 07 04 00 00       	push   $0x407
  8022dd:	50                   	push   %eax
  8022de:	6a 00                	push   $0x0
  8022e0:	e8 6b ea ff ff       	call   800d50 <sys_page_alloc>
  8022e5:	89 c3                	mov    %eax,%ebx
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	0f 88 89 00 00 00    	js     80237b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022f2:	83 ec 0c             	sub    $0xc,%esp
  8022f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8022f8:	e8 ee f0 ff ff       	call   8013eb <fd2data>
  8022fd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802304:	50                   	push   %eax
  802305:	6a 00                	push   $0x0
  802307:	56                   	push   %esi
  802308:	6a 00                	push   $0x0
  80230a:	e8 84 ea ff ff       	call   800d93 <sys_page_map>
  80230f:	89 c3                	mov    %eax,%ebx
  802311:	83 c4 20             	add    $0x20,%esp
  802314:	85 c0                	test   %eax,%eax
  802316:	78 55                	js     80236d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802318:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80231e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802321:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802326:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80232d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802336:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80233b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	ff 75 f4             	pushl  -0xc(%ebp)
  802348:	e8 8e f0 ff ff       	call   8013db <fd2num>
  80234d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802350:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802352:	83 c4 04             	add    $0x4,%esp
  802355:	ff 75 f0             	pushl  -0x10(%ebp)
  802358:	e8 7e f0 ff ff       	call   8013db <fd2num>
  80235d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802360:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	ba 00 00 00 00       	mov    $0x0,%edx
  80236b:	eb 30                	jmp    80239d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80236d:	83 ec 08             	sub    $0x8,%esp
  802370:	56                   	push   %esi
  802371:	6a 00                	push   $0x0
  802373:	e8 5d ea ff ff       	call   800dd5 <sys_page_unmap>
  802378:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80237b:	83 ec 08             	sub    $0x8,%esp
  80237e:	ff 75 f0             	pushl  -0x10(%ebp)
  802381:	6a 00                	push   $0x0
  802383:	e8 4d ea ff ff       	call   800dd5 <sys_page_unmap>
  802388:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80238b:	83 ec 08             	sub    $0x8,%esp
  80238e:	ff 75 f4             	pushl  -0xc(%ebp)
  802391:	6a 00                	push   $0x0
  802393:	e8 3d ea ff ff       	call   800dd5 <sys_page_unmap>
  802398:	83 c4 10             	add    $0x10,%esp
  80239b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80239d:	89 d0                	mov    %edx,%eax
  80239f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a2:	5b                   	pop    %ebx
  8023a3:	5e                   	pop    %esi
  8023a4:	5d                   	pop    %ebp
  8023a5:	c3                   	ret    

008023a6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023af:	50                   	push   %eax
  8023b0:	ff 75 08             	pushl  0x8(%ebp)
  8023b3:	e8 99 f0 ff ff       	call   801451 <fd_lookup>
  8023b8:	89 c2                	mov    %eax,%edx
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	85 d2                	test   %edx,%edx
  8023bf:	78 18                	js     8023d9 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023c1:	83 ec 0c             	sub    $0xc,%esp
  8023c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c7:	e8 1f f0 ff ff       	call   8013eb <fd2data>
	return _pipeisclosed(fd, p);
  8023cc:	89 c2                	mov    %eax,%edx
  8023ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d1:	e8 26 fd ff ff       	call   8020fc <_pipeisclosed>
  8023d6:	83 c4 10             	add    $0x10,%esp
}
  8023d9:	c9                   	leave  
  8023da:	c3                   	ret    

008023db <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023de:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    

008023e5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023eb:	68 4b 30 80 00       	push   $0x80304b
  8023f0:	ff 75 0c             	pushl  0xc(%ebp)
  8023f3:	e8 4f e5 ff ff       	call   800947 <strcpy>
	return 0;
}
  8023f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    

008023ff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	57                   	push   %edi
  802403:	56                   	push   %esi
  802404:	53                   	push   %ebx
  802405:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80240b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802410:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802416:	eb 2d                	jmp    802445 <devcons_write+0x46>
		m = n - tot;
  802418:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80241b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80241d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802420:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802425:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802428:	83 ec 04             	sub    $0x4,%esp
  80242b:	53                   	push   %ebx
  80242c:	03 45 0c             	add    0xc(%ebp),%eax
  80242f:	50                   	push   %eax
  802430:	57                   	push   %edi
  802431:	e8 a3 e6 ff ff       	call   800ad9 <memmove>
		sys_cputs(buf, m);
  802436:	83 c4 08             	add    $0x8,%esp
  802439:	53                   	push   %ebx
  80243a:	57                   	push   %edi
  80243b:	e8 54 e8 ff ff       	call   800c94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802440:	01 de                	add    %ebx,%esi
  802442:	83 c4 10             	add    $0x10,%esp
  802445:	89 f0                	mov    %esi,%eax
  802447:	3b 75 10             	cmp    0x10(%ebp),%esi
  80244a:	72 cc                	jb     802418 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80244c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80245a:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80245f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802463:	75 07                	jne    80246c <devcons_read+0x18>
  802465:	eb 28                	jmp    80248f <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802467:	e8 c5 e8 ff ff       	call   800d31 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80246c:	e8 41 e8 ff ff       	call   800cb2 <sys_cgetc>
  802471:	85 c0                	test   %eax,%eax
  802473:	74 f2                	je     802467 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802475:	85 c0                	test   %eax,%eax
  802477:	78 16                	js     80248f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802479:	83 f8 04             	cmp    $0x4,%eax
  80247c:	74 0c                	je     80248a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80247e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802481:	88 02                	mov    %al,(%edx)
	return 1;
  802483:	b8 01 00 00 00       	mov    $0x1,%eax
  802488:	eb 05                	jmp    80248f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80248a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80248f:	c9                   	leave  
  802490:	c3                   	ret    

00802491 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802497:	8b 45 08             	mov    0x8(%ebp),%eax
  80249a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80249d:	6a 01                	push   $0x1
  80249f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024a2:	50                   	push   %eax
  8024a3:	e8 ec e7 ff ff       	call   800c94 <sys_cputs>
  8024a8:	83 c4 10             	add    $0x10,%esp
}
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <getchar>:

int
getchar(void)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024b3:	6a 01                	push   $0x1
  8024b5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024b8:	50                   	push   %eax
  8024b9:	6a 00                	push   $0x0
  8024bb:	e8 00 f2 ff ff       	call   8016c0 <read>
	if (r < 0)
  8024c0:	83 c4 10             	add    $0x10,%esp
  8024c3:	85 c0                	test   %eax,%eax
  8024c5:	78 0f                	js     8024d6 <getchar+0x29>
		return r;
	if (r < 1)
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	7e 06                	jle    8024d1 <getchar+0x24>
		return -E_EOF;
	return c;
  8024cb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024cf:	eb 05                	jmp    8024d6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024d1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024d6:	c9                   	leave  
  8024d7:	c3                   	ret    

008024d8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e1:	50                   	push   %eax
  8024e2:	ff 75 08             	pushl  0x8(%ebp)
  8024e5:	e8 67 ef ff ff       	call   801451 <fd_lookup>
  8024ea:	83 c4 10             	add    $0x10,%esp
  8024ed:	85 c0                	test   %eax,%eax
  8024ef:	78 11                	js     802502 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f4:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8024fa:	39 10                	cmp    %edx,(%eax)
  8024fc:	0f 94 c0             	sete   %al
  8024ff:	0f b6 c0             	movzbl %al,%eax
}
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <opencons>:

int
opencons(void)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80250a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80250d:	50                   	push   %eax
  80250e:	e8 ef ee ff ff       	call   801402 <fd_alloc>
  802513:	83 c4 10             	add    $0x10,%esp
		return r;
  802516:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802518:	85 c0                	test   %eax,%eax
  80251a:	78 3e                	js     80255a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80251c:	83 ec 04             	sub    $0x4,%esp
  80251f:	68 07 04 00 00       	push   $0x407
  802524:	ff 75 f4             	pushl  -0xc(%ebp)
  802527:	6a 00                	push   $0x0
  802529:	e8 22 e8 ff ff       	call   800d50 <sys_page_alloc>
  80252e:	83 c4 10             	add    $0x10,%esp
		return r;
  802531:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802533:	85 c0                	test   %eax,%eax
  802535:	78 23                	js     80255a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802537:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80253d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802540:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802545:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80254c:	83 ec 0c             	sub    $0xc,%esp
  80254f:	50                   	push   %eax
  802550:	e8 86 ee ff ff       	call   8013db <fd2num>
  802555:	89 c2                	mov    %eax,%edx
  802557:	83 c4 10             	add    $0x10,%esp
}
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	c9                   	leave  
  80255d:	c3                   	ret    

0080255e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802564:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80256b:	75 2c                	jne    802599 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80256d:	83 ec 04             	sub    $0x4,%esp
  802570:	6a 07                	push   $0x7
  802572:	68 00 f0 bf ee       	push   $0xeebff000
  802577:	6a 00                	push   $0x0
  802579:	e8 d2 e7 ff ff       	call   800d50 <sys_page_alloc>
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	85 c0                	test   %eax,%eax
  802583:	74 14                	je     802599 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802585:	83 ec 04             	sub    $0x4,%esp
  802588:	68 58 30 80 00       	push   $0x803058
  80258d:	6a 21                	push   $0x21
  80258f:	68 bc 30 80 00       	push   $0x8030bc
  802594:	e8 4e dd ff ff       	call   8002e7 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802599:	8b 45 08             	mov    0x8(%ebp),%eax
  80259c:	a3 00 80 80 00       	mov    %eax,0x808000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8025a1:	83 ec 08             	sub    $0x8,%esp
  8025a4:	68 cd 25 80 00       	push   $0x8025cd
  8025a9:	6a 00                	push   $0x0
  8025ab:	e8 eb e8 ff ff       	call   800e9b <sys_env_set_pgfault_upcall>
  8025b0:	83 c4 10             	add    $0x10,%esp
  8025b3:	85 c0                	test   %eax,%eax
  8025b5:	79 14                	jns    8025cb <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8025b7:	83 ec 04             	sub    $0x4,%esp
  8025ba:	68 84 30 80 00       	push   $0x803084
  8025bf:	6a 29                	push   $0x29
  8025c1:	68 bc 30 80 00       	push   $0x8030bc
  8025c6:	e8 1c dd ff ff       	call   8002e7 <_panic>
}
  8025cb:	c9                   	leave  
  8025cc:	c3                   	ret    

008025cd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025cd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025ce:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8025d3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025d5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8025d8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8025dd:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8025e1:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8025e5:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8025e7:	83 c4 08             	add    $0x8,%esp
        popal
  8025ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8025eb:	83 c4 04             	add    $0x4,%esp
        popfl
  8025ee:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  8025ef:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8025f0:	c3                   	ret    

008025f1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f7:	89 d0                	mov    %edx,%eax
  8025f9:	c1 e8 16             	shr    $0x16,%eax
  8025fc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802603:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802608:	f6 c1 01             	test   $0x1,%cl
  80260b:	74 1d                	je     80262a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80260d:	c1 ea 0c             	shr    $0xc,%edx
  802610:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802617:	f6 c2 01             	test   $0x1,%dl
  80261a:	74 0e                	je     80262a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80261c:	c1 ea 0c             	shr    $0xc,%edx
  80261f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802626:	ef 
  802627:	0f b7 c0             	movzwl %ax,%eax
}
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__udivdi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	83 ec 10             	sub    $0x10,%esp
  802636:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80263a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80263e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802642:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802646:	85 d2                	test   %edx,%edx
  802648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80264c:	89 34 24             	mov    %esi,(%esp)
  80264f:	89 c8                	mov    %ecx,%eax
  802651:	75 35                	jne    802688 <__udivdi3+0x58>
  802653:	39 f1                	cmp    %esi,%ecx
  802655:	0f 87 bd 00 00 00    	ja     802718 <__udivdi3+0xe8>
  80265b:	85 c9                	test   %ecx,%ecx
  80265d:	89 cd                	mov    %ecx,%ebp
  80265f:	75 0b                	jne    80266c <__udivdi3+0x3c>
  802661:	b8 01 00 00 00       	mov    $0x1,%eax
  802666:	31 d2                	xor    %edx,%edx
  802668:	f7 f1                	div    %ecx
  80266a:	89 c5                	mov    %eax,%ebp
  80266c:	89 f0                	mov    %esi,%eax
  80266e:	31 d2                	xor    %edx,%edx
  802670:	f7 f5                	div    %ebp
  802672:	89 c6                	mov    %eax,%esi
  802674:	89 f8                	mov    %edi,%eax
  802676:	f7 f5                	div    %ebp
  802678:	89 f2                	mov    %esi,%edx
  80267a:	83 c4 10             	add    $0x10,%esp
  80267d:	5e                   	pop    %esi
  80267e:	5f                   	pop    %edi
  80267f:	5d                   	pop    %ebp
  802680:	c3                   	ret    
  802681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802688:	3b 14 24             	cmp    (%esp),%edx
  80268b:	77 7b                	ja     802708 <__udivdi3+0xd8>
  80268d:	0f bd f2             	bsr    %edx,%esi
  802690:	83 f6 1f             	xor    $0x1f,%esi
  802693:	0f 84 97 00 00 00    	je     802730 <__udivdi3+0x100>
  802699:	bd 20 00 00 00       	mov    $0x20,%ebp
  80269e:	89 d7                	mov    %edx,%edi
  8026a0:	89 f1                	mov    %esi,%ecx
  8026a2:	29 f5                	sub    %esi,%ebp
  8026a4:	d3 e7                	shl    %cl,%edi
  8026a6:	89 c2                	mov    %eax,%edx
  8026a8:	89 e9                	mov    %ebp,%ecx
  8026aa:	d3 ea                	shr    %cl,%edx
  8026ac:	89 f1                	mov    %esi,%ecx
  8026ae:	09 fa                	or     %edi,%edx
  8026b0:	8b 3c 24             	mov    (%esp),%edi
  8026b3:	d3 e0                	shl    %cl,%eax
  8026b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026c3:	89 fa                	mov    %edi,%edx
  8026c5:	d3 ea                	shr    %cl,%edx
  8026c7:	89 f1                	mov    %esi,%ecx
  8026c9:	d3 e7                	shl    %cl,%edi
  8026cb:	89 e9                	mov    %ebp,%ecx
  8026cd:	d3 e8                	shr    %cl,%eax
  8026cf:	09 c7                	or     %eax,%edi
  8026d1:	89 f8                	mov    %edi,%eax
  8026d3:	f7 74 24 08          	divl   0x8(%esp)
  8026d7:	89 d5                	mov    %edx,%ebp
  8026d9:	89 c7                	mov    %eax,%edi
  8026db:	f7 64 24 0c          	mull   0xc(%esp)
  8026df:	39 d5                	cmp    %edx,%ebp
  8026e1:	89 14 24             	mov    %edx,(%esp)
  8026e4:	72 11                	jb     8026f7 <__udivdi3+0xc7>
  8026e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026ea:	89 f1                	mov    %esi,%ecx
  8026ec:	d3 e2                	shl    %cl,%edx
  8026ee:	39 c2                	cmp    %eax,%edx
  8026f0:	73 5e                	jae    802750 <__udivdi3+0x120>
  8026f2:	3b 2c 24             	cmp    (%esp),%ebp
  8026f5:	75 59                	jne    802750 <__udivdi3+0x120>
  8026f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8026fa:	31 f6                	xor    %esi,%esi
  8026fc:	89 f2                	mov    %esi,%edx
  8026fe:	83 c4 10             	add    $0x10,%esp
  802701:	5e                   	pop    %esi
  802702:	5f                   	pop    %edi
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    
  802705:	8d 76 00             	lea    0x0(%esi),%esi
  802708:	31 f6                	xor    %esi,%esi
  80270a:	31 c0                	xor    %eax,%eax
  80270c:	89 f2                	mov    %esi,%edx
  80270e:	83 c4 10             	add    $0x10,%esp
  802711:	5e                   	pop    %esi
  802712:	5f                   	pop    %edi
  802713:	5d                   	pop    %ebp
  802714:	c3                   	ret    
  802715:	8d 76 00             	lea    0x0(%esi),%esi
  802718:	89 f2                	mov    %esi,%edx
  80271a:	31 f6                	xor    %esi,%esi
  80271c:	89 f8                	mov    %edi,%eax
  80271e:	f7 f1                	div    %ecx
  802720:	89 f2                	mov    %esi,%edx
  802722:	83 c4 10             	add    $0x10,%esp
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802734:	76 0b                	jbe    802741 <__udivdi3+0x111>
  802736:	31 c0                	xor    %eax,%eax
  802738:	3b 14 24             	cmp    (%esp),%edx
  80273b:	0f 83 37 ff ff ff    	jae    802678 <__udivdi3+0x48>
  802741:	b8 01 00 00 00       	mov    $0x1,%eax
  802746:	e9 2d ff ff ff       	jmp    802678 <__udivdi3+0x48>
  80274b:	90                   	nop
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	89 f8                	mov    %edi,%eax
  802752:	31 f6                	xor    %esi,%esi
  802754:	e9 1f ff ff ff       	jmp    802678 <__udivdi3+0x48>
  802759:	66 90                	xchg   %ax,%ax
  80275b:	66 90                	xchg   %ax,%ax
  80275d:	66 90                	xchg   %ax,%ax
  80275f:	90                   	nop

00802760 <__umoddi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	83 ec 20             	sub    $0x20,%esp
  802766:	8b 44 24 34          	mov    0x34(%esp),%eax
  80276a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80276e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802772:	89 c6                	mov    %eax,%esi
  802774:	89 44 24 10          	mov    %eax,0x10(%esp)
  802778:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80277c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802780:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802784:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802788:	89 74 24 18          	mov    %esi,0x18(%esp)
  80278c:	85 c0                	test   %eax,%eax
  80278e:	89 c2                	mov    %eax,%edx
  802790:	75 1e                	jne    8027b0 <__umoddi3+0x50>
  802792:	39 f7                	cmp    %esi,%edi
  802794:	76 52                	jbe    8027e8 <__umoddi3+0x88>
  802796:	89 c8                	mov    %ecx,%eax
  802798:	89 f2                	mov    %esi,%edx
  80279a:	f7 f7                	div    %edi
  80279c:	89 d0                	mov    %edx,%eax
  80279e:	31 d2                	xor    %edx,%edx
  8027a0:	83 c4 20             	add    $0x20,%esp
  8027a3:	5e                   	pop    %esi
  8027a4:	5f                   	pop    %edi
  8027a5:	5d                   	pop    %ebp
  8027a6:	c3                   	ret    
  8027a7:	89 f6                	mov    %esi,%esi
  8027a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027b0:	39 f0                	cmp    %esi,%eax
  8027b2:	77 5c                	ja     802810 <__umoddi3+0xb0>
  8027b4:	0f bd e8             	bsr    %eax,%ebp
  8027b7:	83 f5 1f             	xor    $0x1f,%ebp
  8027ba:	75 64                	jne    802820 <__umoddi3+0xc0>
  8027bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8027c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8027c4:	0f 86 f6 00 00 00    	jbe    8028c0 <__umoddi3+0x160>
  8027ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8027ce:	0f 82 ec 00 00 00    	jb     8028c0 <__umoddi3+0x160>
  8027d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8027dc:	83 c4 20             	add    $0x20,%esp
  8027df:	5e                   	pop    %esi
  8027e0:	5f                   	pop    %edi
  8027e1:	5d                   	pop    %ebp
  8027e2:	c3                   	ret    
  8027e3:	90                   	nop
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	85 ff                	test   %edi,%edi
  8027ea:	89 fd                	mov    %edi,%ebp
  8027ec:	75 0b                	jne    8027f9 <__umoddi3+0x99>
  8027ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8027f3:	31 d2                	xor    %edx,%edx
  8027f5:	f7 f7                	div    %edi
  8027f7:	89 c5                	mov    %eax,%ebp
  8027f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8027fd:	31 d2                	xor    %edx,%edx
  8027ff:	f7 f5                	div    %ebp
  802801:	89 c8                	mov    %ecx,%eax
  802803:	f7 f5                	div    %ebp
  802805:	eb 95                	jmp    80279c <__umoddi3+0x3c>
  802807:	89 f6                	mov    %esi,%esi
  802809:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	83 c4 20             	add    $0x20,%esp
  802817:	5e                   	pop    %esi
  802818:	5f                   	pop    %edi
  802819:	5d                   	pop    %ebp
  80281a:	c3                   	ret    
  80281b:	90                   	nop
  80281c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802820:	b8 20 00 00 00       	mov    $0x20,%eax
  802825:	89 e9                	mov    %ebp,%ecx
  802827:	29 e8                	sub    %ebp,%eax
  802829:	d3 e2                	shl    %cl,%edx
  80282b:	89 c7                	mov    %eax,%edi
  80282d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802831:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e8                	shr    %cl,%eax
  802839:	89 c1                	mov    %eax,%ecx
  80283b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80283f:	09 d1                	or     %edx,%ecx
  802841:	89 fa                	mov    %edi,%edx
  802843:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802847:	89 e9                	mov    %ebp,%ecx
  802849:	d3 e0                	shl    %cl,%eax
  80284b:	89 f9                	mov    %edi,%ecx
  80284d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802851:	89 f0                	mov    %esi,%eax
  802853:	d3 e8                	shr    %cl,%eax
  802855:	89 e9                	mov    %ebp,%ecx
  802857:	89 c7                	mov    %eax,%edi
  802859:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80285d:	d3 e6                	shl    %cl,%esi
  80285f:	89 d1                	mov    %edx,%ecx
  802861:	89 fa                	mov    %edi,%edx
  802863:	d3 e8                	shr    %cl,%eax
  802865:	89 e9                	mov    %ebp,%ecx
  802867:	09 f0                	or     %esi,%eax
  802869:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80286d:	f7 74 24 10          	divl   0x10(%esp)
  802871:	d3 e6                	shl    %cl,%esi
  802873:	89 d1                	mov    %edx,%ecx
  802875:	f7 64 24 0c          	mull   0xc(%esp)
  802879:	39 d1                	cmp    %edx,%ecx
  80287b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80287f:	89 d7                	mov    %edx,%edi
  802881:	89 c6                	mov    %eax,%esi
  802883:	72 0a                	jb     80288f <__umoddi3+0x12f>
  802885:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802889:	73 10                	jae    80289b <__umoddi3+0x13b>
  80288b:	39 d1                	cmp    %edx,%ecx
  80288d:	75 0c                	jne    80289b <__umoddi3+0x13b>
  80288f:	89 d7                	mov    %edx,%edi
  802891:	89 c6                	mov    %eax,%esi
  802893:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802897:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80289b:	89 ca                	mov    %ecx,%edx
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028a3:	29 f0                	sub    %esi,%eax
  8028a5:	19 fa                	sbb    %edi,%edx
  8028a7:	d3 e8                	shr    %cl,%eax
  8028a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8028ae:	89 d7                	mov    %edx,%edi
  8028b0:	d3 e7                	shl    %cl,%edi
  8028b2:	89 e9                	mov    %ebp,%ecx
  8028b4:	09 f8                	or     %edi,%eax
  8028b6:	d3 ea                	shr    %cl,%edx
  8028b8:	83 c4 20             	add    $0x20,%esp
  8028bb:	5e                   	pop    %esi
  8028bc:	5f                   	pop    %edi
  8028bd:	5d                   	pop    %ebp
  8028be:	c3                   	ret    
  8028bf:	90                   	nop
  8028c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028c4:	29 f9                	sub    %edi,%ecx
  8028c6:	19 c6                	sbb    %eax,%esi
  8028c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028d0:	e9 ff fe ff ff       	jmp    8027d4 <__umoddi3+0x74>
