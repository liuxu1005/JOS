
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 e3 18 00 00       	call   801914 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800084:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	0f b6 c3             	movzbl %bl,%eax
  8000ae:	50                   	push   %eax
  8000af:	68 80 3c 80 00       	push   $0x803c80
  8000b4:	e8 94 19 00 00       	call   801a4d <cprintf>
	return (x < 1000);
}
  8000b9:	89 d8                	mov    %ebx,%eax
  8000bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000c9:	83 f8 01             	cmp    $0x1,%eax
  8000cc:	76 14                	jbe    8000e2 <ide_set_disk+0x22>
		panic("bad disk number");
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	68 97 3c 80 00       	push   $0x803c97
  8000d6:	6a 3a                	push   $0x3a
  8000d8:	68 a7 3c 80 00       	push   $0x803ca7
  8000dd:	e8 92 18 00 00       	call   801974 <_panic>
	diskno = d;
  8000e2:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fb:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800101:	76 16                	jbe    800119 <ide_read+0x30>
  800103:	68 b0 3c 80 00       	push   $0x803cb0
  800108:	68 bd 3c 80 00       	push   $0x803cbd
  80010d:	6a 44                	push   $0x44
  80010f:	68 a7 3c 80 00       	push   $0x803ca7
  800114:	e8 5b 18 00 00       	call   801974 <_panic>

	ide_wait_ready(0);
  800119:	b8 00 00 00 00       	mov    $0x0,%eax
  80011e:	e8 10 ff ff ff       	call   800033 <ide_wait_ready>
  800123:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800128:	89 f0                	mov    %esi,%eax
  80012a:	ee                   	out    %al,(%dx)
  80012b:	b2 f3                	mov    $0xf3,%dl
  80012d:	89 f8                	mov    %edi,%eax
  80012f:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800130:	89 f8                	mov    %edi,%eax
  800132:	c1 e8 08             	shr    $0x8,%eax
  800135:	b2 f4                	mov    $0xf4,%dl
  800137:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800138:	89 f8                	mov    %edi,%eax
  80013a:	c1 e8 10             	shr    $0x10,%eax
  80013d:	b2 f5                	mov    $0xf5,%dl
  80013f:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800140:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800147:	83 e0 01             	and    $0x1,%eax
  80014a:	c1 e0 04             	shl    $0x4,%eax
  80014d:	83 c8 e0             	or     $0xffffffe0,%eax
  800150:	c1 ef 18             	shr    $0x18,%edi
  800153:	83 e7 0f             	and    $0xf,%edi
  800156:	09 f8                	or     %edi,%eax
  800158:	b2 f6                	mov    $0xf6,%dl
  80015a:	ee                   	out    %al,(%dx)
  80015b:	b2 f7                	mov    $0xf7,%dl
  80015d:	b8 20 00 00 00       	mov    $0x20,%eax
  800162:	ee                   	out    %al,(%dx)
  800163:	c1 e6 09             	shl    $0x9,%esi
  800166:	01 de                	add    %ebx,%esi
  800168:	eb 23                	jmp    80018d <ide_read+0xa4>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80016a:	b8 01 00 00 00       	mov    $0x1,%eax
  80016f:	e8 bf fe ff ff       	call   800033 <ide_wait_ready>
  800174:	85 c0                	test   %eax,%eax
  800176:	78 1e                	js     800196 <ide_read+0xad>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800178:	89 df                	mov    %ebx,%edi
  80017a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80017f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800184:	fc                   	cld    
  800185:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800187:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80018d:	39 f3                	cmp    %esi,%ebx
  80018f:	75 d9                	jne    80016a <ide_read+0x81>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  800191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001b0:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001b6:	76 16                	jbe    8001ce <ide_write+0x30>
  8001b8:	68 b0 3c 80 00       	push   $0x803cb0
  8001bd:	68 bd 3c 80 00       	push   $0x803cbd
  8001c2:	6a 5d                	push   $0x5d
  8001c4:	68 a7 3c 80 00       	push   $0x803ca7
  8001c9:	e8 a6 17 00 00       	call   801974 <_panic>

	ide_wait_ready(0);
  8001ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d3:	e8 5b fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001d8:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001dd:	89 f8                	mov    %edi,%eax
  8001df:	ee                   	out    %al,(%dx)
  8001e0:	b2 f3                	mov    $0xf3,%dl
  8001e2:	89 f0                	mov    %esi,%eax
  8001e4:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001e5:	89 f0                	mov    %esi,%eax
  8001e7:	c1 e8 08             	shr    $0x8,%eax
  8001ea:	b2 f4                	mov    $0xf4,%dl
  8001ec:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001ed:	89 f0                	mov    %esi,%eax
  8001ef:	c1 e8 10             	shr    $0x10,%eax
  8001f2:	b2 f5                	mov    $0xf5,%dl
  8001f4:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  8001f5:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  8001fc:	83 e0 01             	and    $0x1,%eax
  8001ff:	c1 e0 04             	shl    $0x4,%eax
  800202:	83 c8 e0             	or     $0xffffffe0,%eax
  800205:	c1 ee 18             	shr    $0x18,%esi
  800208:	83 e6 0f             	and    $0xf,%esi
  80020b:	09 f0                	or     %esi,%eax
  80020d:	b2 f6                	mov    $0xf6,%dl
  80020f:	ee                   	out    %al,(%dx)
  800210:	b2 f7                	mov    $0xf7,%dl
  800212:	b8 30 00 00 00       	mov    $0x30,%eax
  800217:	ee                   	out    %al,(%dx)
  800218:	c1 e7 09             	shl    $0x9,%edi
  80021b:	01 df                	add    %ebx,%edi
  80021d:	eb 23                	jmp    800242 <ide_write+0xa4>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80021f:	b8 01 00 00 00       	mov    $0x1,%eax
  800224:	e8 0a fe ff ff       	call   800033 <ide_wait_ready>
  800229:	85 c0                	test   %eax,%eax
  80022b:	78 1e                	js     80024b <ide_write+0xad>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	b9 80 00 00 00       	mov    $0x80,%ecx
  800234:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800239:	fc                   	cld    
  80023a:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80023c:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800242:	39 fb                	cmp    %edi,%ebx
  800244:	75 d9                	jne    80021f <ide_write+0x81>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800246:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80024b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80025b:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80025d:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800263:	89 c6                	mov    %eax,%esi
  800265:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800268:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80026d:	76 1b                	jbe    80028a <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	ff 72 04             	pushl  0x4(%edx)
  800275:	53                   	push   %ebx
  800276:	ff 72 28             	pushl  0x28(%edx)
  800279:	68 d4 3c 80 00       	push   $0x803cd4
  80027e:	6a 27                	push   $0x27
  800280:	68 b4 3d 80 00       	push   $0x803db4
  800285:	e8 ea 16 00 00       	call   801974 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80028a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80028f:	85 c0                	test   %eax,%eax
  800291:	74 17                	je     8002aa <bc_pgfault+0x57>
  800293:	3b 70 04             	cmp    0x4(%eax),%esi
  800296:	72 12                	jb     8002aa <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  800298:	56                   	push   %esi
  800299:	68 04 3d 80 00       	push   $0x803d04
  80029e:	6a 2b                	push   $0x2b
  8002a0:	68 b4 3d 80 00       	push   $0x803db4
  8002a5:	e8 ca 16 00 00       	call   801974 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
        addr = ROUNDDOWN(addr, PGSIZE);
  8002aa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if(sys_page_alloc(0, addr, PTE_U | PTE_W | PTE_P) < 0)
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	6a 07                	push   $0x7
  8002b5:	53                   	push   %ebx
  8002b6:	6a 00                	push   $0x0
  8002b8:	e8 20 21 00 00       	call   8023dd <sys_page_alloc>
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	79 14                	jns    8002d8 <bc_pgfault+0x85>
                panic("alloc disk map page fails\n");
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	68 bc 3d 80 00       	push   $0x803dbc
  8002cc:	6a 35                	push   $0x35
  8002ce:	68 b4 3d 80 00       	push   $0x803db4
  8002d3:	e8 9c 16 00 00       	call   801974 <_panic>
        if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0) 
  8002d8:	83 ec 04             	sub    $0x4,%esp
  8002db:	6a 08                	push   $0x8
  8002dd:	53                   	push   %ebx
  8002de:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002e5:	50                   	push   %eax
  8002e6:	e8 fe fd ff ff       	call   8000e9 <ide_read>
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	79 12                	jns    800304 <bc_pgfault+0xb1>
                panic("ide_read: %e", r);
  8002f2:	50                   	push   %eax
  8002f3:	68 d7 3d 80 00       	push   $0x803dd7
  8002f8:	6a 37                	push   $0x37
  8002fa:	68 b4 3d 80 00       	push   $0x803db4
  8002ff:	e8 70 16 00 00       	call   801974 <_panic>
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800304:	89 d8                	mov    %ebx,%eax
  800306:	c1 e8 0c             	shr    $0xc,%eax
  800309:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	25 07 0e 00 00       	and    $0xe07,%eax
  800318:	50                   	push   %eax
  800319:	53                   	push   %ebx
  80031a:	6a 00                	push   $0x0
  80031c:	53                   	push   %ebx
  80031d:	6a 00                	push   $0x0
  80031f:	e8 fc 20 00 00       	call   802420 <sys_page_map>
  800324:	83 c4 20             	add    $0x20,%esp
  800327:	85 c0                	test   %eax,%eax
  800329:	79 12                	jns    80033d <bc_pgfault+0xea>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80032b:	50                   	push   %eax
  80032c:	68 28 3d 80 00       	push   $0x803d28
  800331:	6a 3b                	push   $0x3b
  800333:	68 b4 3d 80 00       	push   $0x803db4
  800338:	e8 37 16 00 00       	call   801974 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80033d:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800344:	74 22                	je     800368 <bc_pgfault+0x115>
  800346:	83 ec 0c             	sub    $0xc,%esp
  800349:	56                   	push   %esi
  80034a:	e8 5a 03 00 00       	call   8006a9 <block_is_free>
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	84 c0                	test   %al,%al
  800354:	74 12                	je     800368 <bc_pgfault+0x115>
		panic("reading free block %08x\n", blockno);
  800356:	56                   	push   %esi
  800357:	68 e4 3d 80 00       	push   $0x803de4
  80035c:	6a 41                	push   $0x41
  80035e:	68 b4 3d 80 00       	push   $0x803db4
  800363:	e8 0c 16 00 00       	call   801974 <_panic>
}
  800368:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800378:	85 c0                	test   %eax,%eax
  80037a:	74 0f                	je     80038b <diskaddr+0x1c>
  80037c:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  800382:	85 d2                	test   %edx,%edx
  800384:	74 17                	je     80039d <diskaddr+0x2e>
  800386:	3b 42 04             	cmp    0x4(%edx),%eax
  800389:	72 12                	jb     80039d <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  80038b:	50                   	push   %eax
  80038c:	68 48 3d 80 00       	push   $0x803d48
  800391:	6a 09                	push   $0x9
  800393:	68 b4 3d 80 00       	push   $0x803db4
  800398:	e8 d7 15 00 00       	call   801974 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80039d:	05 00 00 01 00       	add    $0x10000,%eax
  8003a2:	c1 e0 0c             	shl    $0xc,%eax
}
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    

008003a7 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003ad:	89 d0                	mov    %edx,%eax
  8003af:	c1 e8 16             	shr    $0x16,%eax
  8003b2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003be:	f6 c1 01             	test   $0x1,%cl
  8003c1:	74 0d                	je     8003d0 <va_is_mapped+0x29>
  8003c3:	c1 ea 0c             	shr    $0xc,%edx
  8003c6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003cd:	83 e0 01             	and    $0x1,%eax
  8003d0:	83 e0 01             	and    $0x1,%eax
}
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	c1 e8 0c             	shr    $0xc,%eax
  8003de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003e5:	c1 e8 06             	shr    $0x6,%eax
  8003e8:	83 e0 01             	and    $0x1,%eax
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003f5:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8003fb:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800400:	76 12                	jbe    800414 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800402:	53                   	push   %ebx
  800403:	68 fd 3d 80 00       	push   $0x803dfd
  800408:	6a 51                	push   $0x51
  80040a:	68 b4 3d 80 00       	push   $0x803db4
  80040f:	e8 60 15 00 00       	call   801974 <_panic>

	// LAB 5: Your code here.
        if(va_is_mapped(addr) && va_is_dirty(addr)) {
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	53                   	push   %ebx
  800418:	e8 8a ff ff ff       	call   8003a7 <va_is_mapped>
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	84 c0                	test   %al,%al
  800422:	0f 84 82 00 00 00    	je     8004aa <flush_block+0xbd>
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	53                   	push   %ebx
  80042c:	e8 a4 ff ff ff       	call   8003d5 <va_is_dirty>
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	84 c0                	test   %al,%al
  800436:	74 72                	je     8004aa <flush_block+0xbd>
                int r;
                addr = ROUNDDOWN(addr, PGSIZE);
  800438:	89 de                	mov    %ebx,%esi
  80043a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
                if((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  800440:	83 ec 04             	sub    $0x4,%esp
  800443:	6a 08                	push   $0x8
  800445:	56                   	push   %esi
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800446:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80044c:	c1 eb 0c             	shr    $0xc,%ebx

	// LAB 5: Your code here.
        if(va_is_mapped(addr) && va_is_dirty(addr)) {
                int r;
                addr = ROUNDDOWN(addr, PGSIZE);
                if((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80044f:	c1 e3 03             	shl    $0x3,%ebx
  800452:	53                   	push   %ebx
  800453:	e8 46 fd ff ff       	call   80019e <ide_write>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	85 c0                	test   %eax,%eax
  80045d:	79 12                	jns    800471 <flush_block+0x84>
                        panic("ide_write: %e", r);
  80045f:	50                   	push   %eax
  800460:	68 18 3e 80 00       	push   $0x803e18
  800465:	6a 58                	push   $0x58
  800467:	68 b4 3d 80 00       	push   $0x803db4
  80046c:	e8 03 15 00 00       	call   801974 <_panic>
                if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800471:	89 f0                	mov    %esi,%eax
  800473:	c1 e8 0c             	shr    $0xc,%eax
  800476:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	25 07 0e 00 00       	and    $0xe07,%eax
  800485:	50                   	push   %eax
  800486:	56                   	push   %esi
  800487:	6a 00                	push   $0x0
  800489:	56                   	push   %esi
  80048a:	6a 00                	push   $0x0
  80048c:	e8 8f 1f 00 00       	call   802420 <sys_page_map>
  800491:	83 c4 20             	add    $0x20,%esp
  800494:	85 c0                	test   %eax,%eax
  800496:	79 12                	jns    8004aa <flush_block+0xbd>
		        panic("in flush_block, sys_page_map: %e", r);
  800498:	50                   	push   %eax
  800499:	68 6c 3d 80 00       	push   $0x803d6c
  80049e:	6a 5a                	push   $0x5a
  8004a0:	68 b4 3d 80 00       	push   $0x803db4
  8004a5:	e8 ca 14 00 00       	call   801974 <_panic>
          //cprintf("after flush %d", uvpt[PGNUM(addr)] & PTE_D);
        }
	//panic("flush_block not implemented");
}
  8004aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ad:	5b                   	pop    %ebx
  8004ae:	5e                   	pop    %esi
  8004af:	5d                   	pop    %ebp
  8004b0:	c3                   	ret    

008004b1 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004ba:	68 53 02 80 00       	push   $0x800253
  8004bf:	e8 ab 21 00 00       	call   80266f <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004cb:	e8 9f fe ff ff       	call   80036f <diskaddr>
  8004d0:	83 c4 0c             	add    $0xc,%esp
  8004d3:	68 08 01 00 00       	push   $0x108
  8004d8:	50                   	push   %eax
  8004d9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004df:	50                   	push   %eax
  8004e0:	e8 81 1c 00 00       	call   802166 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ec:	e8 7e fe ff ff       	call   80036f <diskaddr>
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	68 26 3e 80 00       	push   $0x803e26
  8004f9:	50                   	push   %eax
  8004fa:	e8 d5 1a 00 00       	call   801fd4 <strcpy>
	flush_block(diskaddr(1));
  8004ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800506:	e8 64 fe ff ff       	call   80036f <diskaddr>
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	e8 da fe ff ff       	call   8003ed <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800513:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051a:	e8 50 fe ff ff       	call   80036f <diskaddr>
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 80 fe ff ff       	call   8003a7 <va_is_mapped>
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	84 c0                	test   %al,%al
  80052c:	75 16                	jne    800544 <bc_init+0x93>
  80052e:	68 48 3e 80 00       	push   $0x803e48
  800533:	68 bd 3c 80 00       	push   $0x803cbd
  800538:	6a 6d                	push   $0x6d
  80053a:	68 b4 3d 80 00       	push   $0x803db4
  80053f:	e8 30 14 00 00       	call   801974 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	6a 01                	push   $0x1
  800549:	e8 21 fe ff ff       	call   80036f <diskaddr>
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 7f fe ff ff       	call   8003d5 <va_is_dirty>
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	84 c0                	test   %al,%al
  80055b:	74 16                	je     800573 <bc_init+0xc2>
  80055d:	68 2d 3e 80 00       	push   $0x803e2d
  800562:	68 bd 3c 80 00       	push   $0x803cbd
  800567:	6a 6e                	push   $0x6e
  800569:	68 b4 3d 80 00       	push   $0x803db4
  80056e:	e8 01 14 00 00       	call   801974 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800573:	83 ec 0c             	sub    $0xc,%esp
  800576:	6a 01                	push   $0x1
  800578:	e8 f2 fd ff ff       	call   80036f <diskaddr>
  80057d:	83 c4 08             	add    $0x8,%esp
  800580:	50                   	push   %eax
  800581:	6a 00                	push   $0x0
  800583:	e8 da 1e 00 00       	call   802462 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800588:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058f:	e8 db fd ff ff       	call   80036f <diskaddr>
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 0b fe ff ff       	call   8003a7 <va_is_mapped>
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	84 c0                	test   %al,%al
  8005a1:	74 16                	je     8005b9 <bc_init+0x108>
  8005a3:	68 47 3e 80 00       	push   $0x803e47
  8005a8:	68 bd 3c 80 00       	push   $0x803cbd
  8005ad:	6a 72                	push   $0x72
  8005af:	68 b4 3d 80 00       	push   $0x803db4
  8005b4:	e8 bb 13 00 00       	call   801974 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	6a 01                	push   $0x1
  8005be:	e8 ac fd ff ff       	call   80036f <diskaddr>
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	68 26 3e 80 00       	push   $0x803e26
  8005cb:	50                   	push   %eax
  8005cc:	e8 ad 1a 00 00       	call   80207e <strcmp>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	74 16                	je     8005ee <bc_init+0x13d>
  8005d8:	68 90 3d 80 00       	push   $0x803d90
  8005dd:	68 bd 3c 80 00       	push   $0x803cbd
  8005e2:	6a 75                	push   $0x75
  8005e4:	68 b4 3d 80 00       	push   $0x803db4
  8005e9:	e8 86 13 00 00       	call   801974 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005ee:	83 ec 0c             	sub    $0xc,%esp
  8005f1:	6a 01                	push   $0x1
  8005f3:	e8 77 fd ff ff       	call   80036f <diskaddr>
  8005f8:	83 c4 0c             	add    $0xc,%esp
  8005fb:	68 08 01 00 00       	push   $0x108
  800600:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800606:	52                   	push   %edx
  800607:	50                   	push   %eax
  800608:	e8 59 1b 00 00       	call   802166 <memmove>
	flush_block(diskaddr(1));
  80060d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800614:	e8 56 fd ff ff       	call   80036f <diskaddr>
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 cc fd ff ff       	call   8003ed <flush_block>

	cprintf("block cache is good\n");
  800621:	c7 04 24 62 3e 80 00 	movl   $0x803e62,(%esp)
  800628:	e8 20 14 00 00       	call   801a4d <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80062d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800634:	e8 36 fd ff ff       	call   80036f <diskaddr>
  800639:	83 c4 0c             	add    $0xc,%esp
  80063c:	68 08 01 00 00       	push   $0x108
  800641:	50                   	push   %eax
  800642:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	e8 18 1b 00 00       	call   802166 <memmove>
  80064e:	83 c4 10             	add    $0x10,%esp
}
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800659:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80065e:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800664:	74 14                	je     80067a <check_super+0x27>
		panic("bad file system magic number");
  800666:	83 ec 04             	sub    $0x4,%esp
  800669:	68 77 3e 80 00       	push   $0x803e77
  80066e:	6a 0f                	push   $0xf
  800670:	68 94 3e 80 00       	push   $0x803e94
  800675:	e8 fa 12 00 00       	call   801974 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80067a:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800681:	76 14                	jbe    800697 <check_super+0x44>
		panic("file system is too large");
  800683:	83 ec 04             	sub    $0x4,%esp
  800686:	68 9c 3e 80 00       	push   $0x803e9c
  80068b:	6a 12                	push   $0x12
  80068d:	68 94 3e 80 00       	push   $0x803e94
  800692:	e8 dd 12 00 00       	call   801974 <_panic>

	cprintf("superblock is good\n");
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	68 b5 3e 80 00       	push   $0x803eb5
  80069f:	e8 a9 13 00 00       	call   801a4d <cprintf>
  8006a4:	83 c4 10             	add    $0x10,%esp
}
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006af:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	74 22                	je     8006db <block_is_free+0x32>
		return 0;
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006be:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006c1:	76 1d                	jbe    8006e0 <block_is_free+0x37>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8006c8:	d3 e0                	shl    %cl,%eax
  8006ca:	c1 e9 05             	shr    $0x5,%ecx
  8006cd:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006d3:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  8006d6:	0f 95 c0             	setne  %al
  8006d9:	eb 05                	jmp    8006e0 <block_is_free+0x37>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 04             	sub    $0x4,%esp
  8006e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	75 14                	jne    800704 <free_block+0x22>
		panic("attempt to free zero block");
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	68 c9 3e 80 00       	push   $0x803ec9
  8006f8:	6a 2d                	push   $0x2d
  8006fa:	68 94 3e 80 00       	push   $0x803e94
  8006ff:	e8 70 12 00 00       	call   801974 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800704:	89 cb                	mov    %ecx,%ebx
  800706:	c1 eb 05             	shr    $0x5,%ebx
  800709:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80070f:	b8 01 00 00 00       	mov    $0x1,%eax
  800714:	d3 e0                	shl    %cl,%eax
  800716:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	57                   	push   %edi
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	83 ec 0c             	sub    $0xc,%esp
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
        uint32_t bn = 2;
        while(bn < super->s_nblocks) {
  800727:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80072c:	8b 70 04             	mov    0x4(%eax),%esi
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
        uint32_t bn = 2;
  80072f:	bb 02 00 00 00       	mov    $0x2,%ebx
        while(bn < super->s_nblocks) {
  800734:	eb 3d                	jmp    800773 <alloc_block+0x55>
                if(block_is_free(bn)) {
  800736:	53                   	push   %ebx
  800737:	e8 6d ff ff ff       	call   8006a9 <block_is_free>
  80073c:	83 c4 04             	add    $0x4,%esp
  80073f:	84 c0                	test   %al,%al
  800741:	74 2d                	je     800770 <alloc_block+0x52>
                        bitmap[bn/32] &= ~(1<<(bn%32));
  800743:	89 df                	mov    %ebx,%edi
  800745:	c1 ef 05             	shr    $0x5,%edi
  800748:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80074d:	89 de                	mov    %ebx,%esi
  80074f:	ba 01 00 00 00       	mov    $0x1,%edx
  800754:	89 d9                	mov    %ebx,%ecx
  800756:	d3 e2                	shl    %cl,%edx
  800758:	f7 d2                	not    %edx
  80075a:	21 14 b8             	and    %edx,(%eax,%edi,4)
                        flush_block(bitmap);
  80075d:	83 ec 0c             	sub    $0xc,%esp
  800760:	ff 35 08 a0 80 00    	pushl  0x80a008
  800766:	e8 82 fc ff ff       	call   8003ed <flush_block>
                        return bn;
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb 0c                	jmp    80077c <alloc_block+0x5e>
                } else 
                        bn++;
  800770:	83 c3 01             	add    $0x1,%ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
        uint32_t bn = 2;
        while(bn < super->s_nblocks) {
  800773:	39 f3                	cmp    %esi,%ebx
  800775:	72 bf                	jb     800736 <alloc_block+0x18>
                        flush_block(bitmap);
                        return bn;
                } else 
                        bn++;
        }
	return -E_NO_DISK;
  800777:	be f7 ff ff ff       	mov    $0xfffffff7,%esi
}
  80077c:	89 f0                	mov    %esi,%eax
  80077e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	57                   	push   %edi
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	83 ec 0c             	sub    $0xc,%esp
  80078f:	89 cf                	mov    %ecx,%edi
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
       // LAB 5: Your code here.
       //panic("file_block_walk not implemented");
       int r;
       uint32_t *addr;
       uint32_t tmpbn;
       if (filebno < NDIRECT) { 
  800794:	83 fa 09             	cmp    $0x9,%edx
  800797:	77 10                	ja     8007a9 <file_block_walk+0x23>
               *ppdiskbno = &(f->f_direct[filebno]);
  800799:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007a0:	89 07                	mov    %eax,(%edi)
               return 0;
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	eb 7a                	jmp    800823 <file_block_walk+0x9d>
       }
       filebno -= NDIRECT;
  8007a9:	8d 5a f6             	lea    -0xa(%edx),%ebx
       if (filebno < NINDIRECT) {
  8007ac:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  8007b2:	77 63                	ja     800817 <file_block_walk+0x91>
  8007b4:	89 c6                	mov    %eax,%esi
               if ((tmpbn = f->f_indirect) != 0) {
  8007b6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	74 18                	je     8007d8 <file_block_walk+0x52>
                       addr = diskaddr(tmpbn);
  8007c0:	83 ec 0c             	sub    $0xc,%esp
  8007c3:	50                   	push   %eax
  8007c4:	e8 a6 fb ff ff       	call   80036f <diskaddr>
                       *ppdiskbno = &addr[filebno];
  8007c9:	8d 04 98             	lea    (%eax,%ebx,4),%eax
  8007cc:	89 07                	mov    %eax,(%edi)
                       return 0;
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 4b                	jmp    800823 <file_block_walk+0x9d>
               } else {
                       if (alloc == 0)
  8007d8:	84 c9                	test   %cl,%cl
  8007da:	74 42                	je     80081e <file_block_walk+0x98>
                               return -E_NOT_FOUND;
                       if (alloc == 1) {
                               if((r = alloc_block()) < 0)
  8007dc:	e8 3d ff ff ff       	call   80071e <alloc_block>
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	78 3c                	js     800823 <file_block_walk+0x9d>
                                       return r;
                              
                               f->f_indirect = r;
  8007e7:	89 96 b0 00 00 00    	mov    %edx,0xb0(%esi)
                               addr = diskaddr(r);
  8007ed:	83 ec 0c             	sub    $0xc,%esp
  8007f0:	52                   	push   %edx
  8007f1:	e8 79 fb ff ff       	call   80036f <diskaddr>
  8007f6:	89 c6                	mov    %eax,%esi
                               memset(addr, 0, PGSIZE);
  8007f8:	83 c4 0c             	add    $0xc,%esp
  8007fb:	68 00 10 00 00       	push   $0x1000
  800800:	6a 00                	push   $0x0
  800802:	50                   	push   %eax
  800803:	e8 11 19 00 00       	call   802119 <memset>
                               *ppdiskbno = &addr[filebno];
  800808:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
  80080b:	89 07                	mov    %eax,(%edi)
                               return 0;
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 0c                	jmp    800823 <file_block_walk+0x9d>
                       }
                        
               }
       }
       return -E_INVAL;
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081c:	eb 05                	jmp    800823 <file_block_walk+0x9d>
                       addr = diskaddr(tmpbn);
                       *ppdiskbno = &addr[filebno];
                       return 0;
               } else {
                       if (alloc == 0)
                               return -E_NOT_FOUND;
  80081e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
                        
               }
       }
       return -E_INVAL;
       
}
  800823:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5f                   	pop    %edi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800830:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800835:	8b 70 04             	mov    0x4(%eax),%esi
  800838:	bb 00 00 00 00       	mov    $0x0,%ebx
  80083d:	eb 29                	jmp    800868 <check_bitmap+0x3d>
  80083f:	8d 43 02             	lea    0x2(%ebx),%eax
		assert(!block_is_free(2+i));
  800842:	50                   	push   %eax
  800843:	e8 61 fe ff ff       	call   8006a9 <block_is_free>
  800848:	83 c4 04             	add    $0x4,%esp
  80084b:	84 c0                	test   %al,%al
  80084d:	74 16                	je     800865 <check_bitmap+0x3a>
  80084f:	68 e4 3e 80 00       	push   $0x803ee4
  800854:	68 bd 3c 80 00       	push   $0x803cbd
  800859:	6a 59                	push   $0x59
  80085b:	68 94 3e 80 00       	push   $0x803e94
  800860:	e8 0f 11 00 00       	call   801974 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800865:	83 c3 01             	add    $0x1,%ebx
  800868:	89 d8                	mov    %ebx,%eax
  80086a:	c1 e0 0f             	shl    $0xf,%eax
  80086d:	39 c6                	cmp    %eax,%esi
  80086f:	77 ce                	ja     80083f <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800871:	83 ec 0c             	sub    $0xc,%esp
  800874:	6a 00                	push   $0x0
  800876:	e8 2e fe ff ff       	call   8006a9 <block_is_free>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	84 c0                	test   %al,%al
  800880:	74 16                	je     800898 <check_bitmap+0x6d>
  800882:	68 f8 3e 80 00       	push   $0x803ef8
  800887:	68 bd 3c 80 00       	push   $0x803cbd
  80088c:	6a 5c                	push   $0x5c
  80088e:	68 94 3e 80 00       	push   $0x803e94
  800893:	e8 dc 10 00 00       	call   801974 <_panic>
	assert(!block_is_free(1));
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	6a 01                	push   $0x1
  80089d:	e8 07 fe ff ff       	call   8006a9 <block_is_free>
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 16                	je     8008bf <check_bitmap+0x94>
  8008a9:	68 0a 3f 80 00       	push   $0x803f0a
  8008ae:	68 bd 3c 80 00       	push   $0x803cbd
  8008b3:	6a 5d                	push   $0x5d
  8008b5:	68 94 3e 80 00       	push   $0x803e94
  8008ba:	e8 b5 10 00 00       	call   801974 <_panic>

	cprintf("bitmap is good\n");
  8008bf:	83 ec 0c             	sub    $0xc,%esp
  8008c2:	68 1c 3f 80 00       	push   $0x803f1c
  8008c7:	e8 81 11 00 00       	call   801a4d <cprintf>
  8008cc:	83 c4 10             	add    $0x10,%esp
}
  8008cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  8008dc:	e8 7e f7 ff ff       	call   80005f <ide_probe_disk1>
  8008e1:	84 c0                	test   %al,%al
  8008e3:	74 0f                	je     8008f4 <fs_init+0x1e>
               ide_set_disk(1);
  8008e5:	83 ec 0c             	sub    $0xc,%esp
  8008e8:	6a 01                	push   $0x1
  8008ea:	e8 d1 f7 ff ff       	call   8000c0 <ide_set_disk>
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb 0d                	jmp    800901 <fs_init+0x2b>
       else
               ide_set_disk(0);
  8008f4:	83 ec 0c             	sub    $0xc,%esp
  8008f7:	6a 00                	push   $0x0
  8008f9:	e8 c2 f7 ff ff       	call   8000c0 <ide_set_disk>
  8008fe:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800901:	e8 ab fb ff ff       	call   8004b1 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	6a 01                	push   $0x1
  80090b:	e8 5f fa ff ff       	call   80036f <diskaddr>
  800910:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800915:	e8 39 fd ff ff       	call   800653 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80091a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800921:	e8 49 fa ff ff       	call   80036f <diskaddr>
  800926:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  80092b:	e8 fb fe ff ff       	call   80082b <check_bitmap>
  800930:	83 c4 10             	add    $0x10,%esp
	
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	83 ec 24             	sub    $0x24,%esp
       // LAB 5: Your code here.
       //panic("file_get_block not implemented");
       int r;
       uint32_t *bslt;
       if((r = file_block_walk(f, filebno, &bslt, 1)) < 0)
  80093b:	6a 01                	push   $0x1
  80093d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	e8 3b fe ff ff       	call   800786 <file_block_walk>
  80094b:	83 c4 10             	add    $0x10,%esp
  80094e:	85 c0                	test   %eax,%eax
  800950:	78 57                	js     8009a9 <file_get_block+0x74>
                return r;
       if(*bslt)
  800952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800955:	8b 00                	mov    (%eax),%eax
  800957:	85 c0                	test   %eax,%eax
  800959:	74 18                	je     800973 <file_get_block+0x3e>
               *blk = diskaddr(*bslt);
  80095b:	83 ec 0c             	sub    $0xc,%esp
  80095e:	50                   	push   %eax
  80095f:	e8 0b fa ff ff       	call   80036f <diskaddr>
  800964:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800967:	89 01                	mov    %eax,(%ecx)
  800969:	83 c4 10             	add    $0x10,%esp
                      return r;
               *bslt = r;
               *blk = diskaddr(r);  
               memset(*blk, 0, PGSIZE);         
       }
       return 0;             
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
  800971:	eb 36                	jmp    8009a9 <file_get_block+0x74>
       if((r = file_block_walk(f, filebno, &bslt, 1)) < 0)
                return r;
       if(*bslt)
               *blk = diskaddr(*bslt);
       else {
               if((r = alloc_block()) < 0)
  800973:	e8 a6 fd ff ff       	call   80071e <alloc_block>
  800978:	89 c2                	mov    %eax,%edx
  80097a:	85 d2                	test   %edx,%edx
  80097c:	78 2b                	js     8009a9 <file_get_block+0x74>
                      return r;
               *bslt = r;
  80097e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800981:	89 10                	mov    %edx,(%eax)
               *blk = diskaddr(r);  
  800983:	83 ec 0c             	sub    $0xc,%esp
  800986:	52                   	push   %edx
  800987:	e8 e3 f9 ff ff       	call   80036f <diskaddr>
  80098c:	8b 55 10             	mov    0x10(%ebp),%edx
  80098f:	89 02                	mov    %eax,(%edx)
               memset(*blk, 0, PGSIZE);         
  800991:	83 c4 0c             	add    $0xc,%esp
  800994:	68 00 10 00 00       	push   $0x1000
  800999:	6a 00                	push   $0x0
  80099b:	50                   	push   %eax
  80099c:	e8 78 17 00 00       	call   802119 <memset>
  8009a1:	83 c4 10             	add    $0x10,%esp
       }
       return 0;             
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009b7:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009bd:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009c3:	eb 03                	jmp    8009c8 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009c5:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009c8:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009cb:	74 f8                	je     8009c5 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009cd:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  8009d3:	83 c1 08             	add    $0x8,%ecx
  8009d6:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009dc:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8009e3:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  8009e9:	85 c9                	test   %ecx,%ecx
  8009eb:	74 06                	je     8009f3 <walk_path+0x48>
		*pdir = 0;
  8009ed:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8009f3:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  8009f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a04:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a0a:	e9 5d 01 00 00       	jmp    800b6c <walk_path+0x1c1>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a0f:	83 c7 01             	add    $0x1,%edi
  800a12:	eb 02                	jmp    800a16 <walk_path+0x6b>
  800a14:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a16:	0f b6 17             	movzbl (%edi),%edx
  800a19:	84 d2                	test   %dl,%dl
  800a1b:	74 05                	je     800a22 <walk_path+0x77>
  800a1d:	80 fa 2f             	cmp    $0x2f,%dl
  800a20:	75 ed                	jne    800a0f <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a22:	89 fb                	mov    %edi,%ebx
  800a24:	29 c3                	sub    %eax,%ebx
  800a26:	83 fb 7f             	cmp    $0x7f,%ebx
  800a29:	0f 8f 67 01 00 00    	jg     800b96 <walk_path+0x1eb>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a2f:	83 ec 04             	sub    $0x4,%esp
  800a32:	53                   	push   %ebx
  800a33:	50                   	push   %eax
  800a34:	56                   	push   %esi
  800a35:	e8 2c 17 00 00       	call   802166 <memmove>
		name[path - p] = '\0';
  800a3a:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a41:	00 
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	eb 03                	jmp    800a4a <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a47:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a4a:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a4d:	74 f8                	je     800a47 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a4f:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a55:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a5c:	0f 85 3b 01 00 00    	jne    800b9d <walk_path+0x1f2>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a62:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a68:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a6d:	74 19                	je     800a88 <walk_path+0xdd>
  800a6f:	68 2c 3f 80 00       	push   $0x803f2c
  800a74:	68 bd 3c 80 00       	push   $0x803cbd
  800a79:	68 e1 00 00 00       	push   $0xe1
  800a7e:	68 94 3e 80 00       	push   $0x803e94
  800a83:	e8 ec 0e 00 00       	call   801974 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a88:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	0f 48 c2             	cmovs  %edx,%eax
  800a93:	c1 f8 0c             	sar    $0xc,%eax
  800a96:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800a9c:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800aa3:	00 00 00 
  800aa6:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800aac:	eb 5e                	jmp    800b0c <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800aae:	83 ec 04             	sub    $0x4,%esp
  800ab1:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ab7:	50                   	push   %eax
  800ab8:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800abe:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ac4:	e8 6c fe ff ff       	call   800935 <file_get_block>
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	85 c0                	test   %eax,%eax
  800ace:	0f 88 ec 00 00 00    	js     800bc0 <walk_path+0x215>
			return r;
		f = (struct File*) blk;
  800ad4:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800ada:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ae0:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	e8 8e 15 00 00       	call   80207e <strcmp>
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	85 c0                	test   %eax,%eax
  800af5:	0f 84 a9 00 00 00    	je     800ba4 <walk_path+0x1f9>
  800afb:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b01:	39 fb                	cmp    %edi,%ebx
  800b03:	75 db                	jne    800ae0 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b05:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b0c:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b12:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b18:	75 94                	jne    800aae <walk_path+0x103>
  800b1a:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
				return 0;
			}
	}
	return -E_NOT_FOUND;
  800b20:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
  800b25:	e9 9e 00 00 00       	jmp    800bc8 <walk_path+0x21d>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b2a:	80 3f 00             	cmpb   $0x0,(%edi)
  800b2d:	75 39                	jne    800b68 <walk_path+0x1bd>
				if (pdir)
  800b2f:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b35:	85 c0                	test   %eax,%eax
  800b37:	74 08                	je     800b41 <walk_path+0x196>
					*pdir = dir;
  800b39:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b3f:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b45:	74 15                	je     800b5c <walk_path+0x1b1>
					strcpy(lastelem, name);
  800b47:	83 ec 08             	sub    $0x8,%esp
  800b4a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b50:	50                   	push   %eax
  800b51:	ff 75 08             	pushl  0x8(%ebp)
  800b54:	e8 7b 14 00 00       	call   801fd4 <strcpy>
  800b59:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b5c:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	eb 66                	jmp    800bd2 <walk_path+0x227>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b6c:	80 38 00             	cmpb   $0x0,(%eax)
  800b6f:	0f 85 9f fe ff ff    	jne    800a14 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b75:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	74 02                	je     800b81 <walk_path+0x1d6>
		*pdir = dir;
  800b7f:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800b81:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b87:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b8d:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	eb 3c                	jmp    800bd2 <walk_path+0x227>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800b96:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800b9b:	eb 35                	jmp    800bd2 <walk_path+0x227>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800b9d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ba2:	eb 2e                	jmp    800bd2 <walk_path+0x227>
  800ba4:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800baa:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800bb0:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bb6:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bbc:	89 f8                	mov    %edi,%eax
  800bbe:	eb ac                	jmp    800b6c <walk_path+0x1c1>
  800bc0:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bc6:	89 c3                	mov    %eax,%ebx

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bc8:	83 fb f5             	cmp    $0xfffffff5,%ebx
  800bcb:	75 9b                	jne    800b68 <walk_path+0x1bd>
  800bcd:	e9 58 ff ff ff       	jmp    800b2a <walk_path+0x17f>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800be0:	6a 00                	push   $0x0
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	e8 b9 fd ff ff       	call   8009ab <walk_path>
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 2c             	sub    $0x2c,%esp
  800bfd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c00:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c11:	39 ca                	cmp    %ecx,%edx
  800c13:	7e 7e                	jle    800c93 <file_read+0x9f>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c15:	29 ca                	sub    %ecx,%edx
  800c17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1a:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c1e:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c21:	89 ce                	mov    %ecx,%esi
  800c23:	01 d1                	add    %edx,%ecx
  800c25:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c28:	eb 5f                	jmp    800c89 <file_read+0x95>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c2a:	83 ec 04             	sub    $0x4,%esp
  800c2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c30:	50                   	push   %eax
  800c31:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c37:	85 f6                	test   %esi,%esi
  800c39:	0f 49 c6             	cmovns %esi,%eax
  800c3c:	c1 f8 0c             	sar    $0xc,%eax
  800c3f:	50                   	push   %eax
  800c40:	ff 75 08             	pushl  0x8(%ebp)
  800c43:	e8 ed fc ff ff       	call   800935 <file_get_block>
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	78 44                	js     800c93 <file_read+0x9f>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c4f:	89 f2                	mov    %esi,%edx
  800c51:	c1 fa 1f             	sar    $0x1f,%edx
  800c54:	c1 ea 14             	shr    $0x14,%edx
  800c57:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c5a:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c5f:	29 d0                	sub    %edx,%eax
  800c61:	ba 00 10 00 00       	mov    $0x1000,%edx
  800c66:	29 c2                	sub    %eax,%edx
  800c68:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800c6b:	29 d9                	sub    %ebx,%ecx
  800c6d:	89 cb                	mov    %ecx,%ebx
  800c6f:	39 ca                	cmp    %ecx,%edx
  800c71:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c74:	83 ec 04             	sub    $0x4,%esp
  800c77:	53                   	push   %ebx
  800c78:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c7b:	50                   	push   %eax
  800c7c:	57                   	push   %edi
  800c7d:	e8 e4 14 00 00       	call   802166 <memmove>
		pos += bn;
  800c82:	01 de                	add    %ebx,%esi
		buf += bn;
  800c84:	01 df                	add    %ebx,%edi
  800c86:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800c89:	89 f3                	mov    %esi,%ebx
  800c8b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
  800c8e:	72 9a                	jb     800c2a <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800c90:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
  800ca4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800ca7:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cad:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800cb0:	0f 8e a7 00 00 00    	jle    800d5d <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800cb6:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800cbc:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cc1:	0f 49 f8             	cmovns %eax,%edi
  800cc4:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd2:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800cd8:	0f 49 c2             	cmovns %edx,%eax
  800cdb:	c1 f8 0c             	sar    $0xc,%eax
  800cde:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	eb 39                	jmp    800d1e <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	6a 00                	push   $0x0
  800cea:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800ced:	89 da                	mov    %ebx,%edx
  800cef:	89 f0                	mov    %esi,%eax
  800cf1:	e8 90 fa ff ff       	call   800786 <file_block_walk>
  800cf6:	83 c4 10             	add    $0x10,%esp
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	78 4d                	js     800d4a <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d00:	8b 00                	mov    (%eax),%eax
  800d02:	85 c0                	test   %eax,%eax
  800d04:	74 15                	je     800d1b <file_set_size+0x80>
		free_block(*ptr);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	e8 d3 f9 ff ff       	call   8006e2 <free_block>
		*ptr = 0;
  800d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d18:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d1b:	83 c3 01             	add    $0x1,%ebx
  800d1e:	39 df                	cmp    %ebx,%edi
  800d20:	77 c3                	ja     800ce5 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d22:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d26:	77 35                	ja     800d5d <file_set_size+0xc2>
  800d28:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	74 2b                	je     800d5d <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	e8 a7 f9 ff ff       	call   8006e2 <free_block>
		f->f_indirect = 0;
  800d3b:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d42:	00 00 00 
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	eb 13                	jmp    800d5d <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	50                   	push   %eax
  800d4e:	68 49 3f 80 00       	push   $0x803f49
  800d53:	e8 f5 0c 00 00       	call   801a4d <cprintf>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	eb be                	jmp    800d1b <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d60:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	56                   	push   %esi
  800d6a:	e8 7e f6 ff ff       	call   8003ed <flush_block>
	return 0;
}
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 2c             	sub    $0x2c,%esp
  800d85:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d88:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	03 45 10             	add    0x10(%ebp),%eax
  800d90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800d9c:	76 72                	jbe    800e10 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d9e:	83 ec 08             	sub    $0x8,%esp
  800da1:	50                   	push   %eax
  800da2:	51                   	push   %ecx
  800da3:	e8 f3 fe ff ff       	call   800c9b <file_set_size>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 6b                	js     800e1a <file_write+0x9e>
  800daf:	eb 5f                	jmp    800e10 <file_write+0x94>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800db7:	50                   	push   %eax
  800db8:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800dbe:	85 f6                	test   %esi,%esi
  800dc0:	0f 49 c6             	cmovns %esi,%eax
  800dc3:	c1 f8 0c             	sar    $0xc,%eax
  800dc6:	50                   	push   %eax
  800dc7:	ff 75 08             	pushl  0x8(%ebp)
  800dca:	e8 66 fb ff ff       	call   800935 <file_get_block>
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 44                	js     800e1a <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dd6:	89 f2                	mov    %esi,%edx
  800dd8:	c1 fa 1f             	sar    $0x1f,%edx
  800ddb:	c1 ea 14             	shr    $0x14,%edx
  800dde:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800de1:	25 ff 0f 00 00       	and    $0xfff,%eax
  800de6:	29 d0                	sub    %edx,%eax
  800de8:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800ded:	29 c1                	sub    %eax,%ecx
  800def:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800df2:	29 da                	sub    %ebx,%edx
  800df4:	39 d1                	cmp    %edx,%ecx
  800df6:	89 d3                	mov    %edx,%ebx
  800df8:	0f 46 d9             	cmovbe %ecx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	53                   	push   %ebx
  800dff:	57                   	push   %edi
  800e00:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e03:	50                   	push   %eax
  800e04:	e8 5d 13 00 00       	call   802166 <memmove>
		pos += bn;
  800e09:	01 de                	add    %ebx,%esi
		buf += bn;
  800e0b:	01 df                	add    %ebx,%edi
  800e0d:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e10:	89 f3                	mov    %esi,%ebx
  800e12:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e15:	77 9a                	ja     800db1 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e17:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 10             	sub    $0x10,%esp
  800e2a:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	eb 3c                	jmp    800e70 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	6a 00                	push   $0x0
  800e39:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e3c:	89 da                	mov    %ebx,%edx
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	e8 41 f9 ff ff       	call   800786 <file_block_walk>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	78 21                	js     800e6d <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	74 1a                	je     800e6d <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e53:	8b 00                	mov    (%eax),%eax
  800e55:	85 c0                	test   %eax,%eax
  800e57:	74 14                	je     800e6d <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e59:	83 ec 0c             	sub    $0xc,%esp
  800e5c:	50                   	push   %eax
  800e5d:	e8 0d f5 ff ff       	call   80036f <diskaddr>
  800e62:	89 04 24             	mov    %eax,(%esp)
  800e65:	e8 83 f5 ff ff       	call   8003ed <flush_block>
  800e6a:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e6d:	83 c3 01             	add    $0x1,%ebx
  800e70:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e76:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800e7c:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  800e82:	85 d2                	test   %edx,%edx
  800e84:	0f 49 ca             	cmovns %edx,%ecx
  800e87:	c1 f9 0c             	sar    $0xc,%ecx
  800e8a:	39 cb                	cmp    %ecx,%ebx
  800e8c:	7c a6                	jl     800e34 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	56                   	push   %esi
  800e92:	e8 56 f5 ff ff       	call   8003ed <flush_block>
	if (f->f_indirect)
  800e97:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	74 14                	je     800eb8 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	e8 c2 f4 ff ff       	call   80036f <diskaddr>
  800ead:	89 04 24             	mov    %eax,(%esp)
  800eb0:	e8 38 f5 ff ff       	call   8003ed <flush_block>
  800eb5:	83 c4 10             	add    $0x10,%esp
}
  800eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
  800ec5:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800ecb:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ed1:	50                   	push   %eax
  800ed2:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800ed8:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	e8 c5 fa ff ff       	call   8009ab <walk_path>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 84 d1 00 00 00    	je     800fc4 <file_create+0x105>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800ef3:	83 fa f5             	cmp    $0xfffffff5,%edx
  800ef6:	0f 85 0c 01 00 00    	jne    801008 <file_create+0x149>
  800efc:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f02:	85 f6                	test   %esi,%esi
  800f04:	0f 84 c1 00 00 00    	je     800fcb <file_create+0x10c>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f0a:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f10:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f15:	74 19                	je     800f30 <file_create+0x71>
  800f17:	68 2c 3f 80 00       	push   $0x803f2c
  800f1c:	68 bd 3c 80 00       	push   $0x803cbd
  800f21:	68 fa 00 00 00       	push   $0xfa
  800f26:	68 94 3e 80 00       	push   $0x803e94
  800f2b:	e8 44 0a 00 00       	call   801974 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f30:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f36:	85 c0                	test   %eax,%eax
  800f38:	0f 48 c2             	cmovs  %edx,%eax
  800f3b:	c1 f8 0c             	sar    $0xc,%eax
  800f3e:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f44:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f49:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f4f:	eb 3b                	jmp    800f8c <file_create+0xcd>
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	57                   	push   %edi
  800f55:	53                   	push   %ebx
  800f56:	56                   	push   %esi
  800f57:	e8 d9 f9 ff ff       	call   800935 <file_get_block>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	0f 88 a1 00 00 00    	js     801008 <file_create+0x149>
			return r;
		f = (struct File*) blk;
  800f67:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f6d:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f73:	80 38 00             	cmpb   $0x0,(%eax)
  800f76:	75 08                	jne    800f80 <file_create+0xc1>
				*file = &f[j];
  800f78:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f7e:	eb 52                	jmp    800fd2 <file_create+0x113>
  800f80:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f85:	39 d0                	cmp    %edx,%eax
  800f87:	75 ea                	jne    800f73 <file_create+0xb4>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800f89:	83 c3 01             	add    $0x1,%ebx
  800f8c:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800f92:	75 bd                	jne    800f51 <file_create+0x92>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800f94:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f9b:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	53                   	push   %ebx
  800fa9:	56                   	push   %esi
  800faa:	e8 86 f9 ff ff       	call   800935 <file_get_block>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 52                	js     801008 <file_create+0x149>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fb6:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fbc:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fc2:	eb 0e                	jmp    800fd2 <file_create+0x113>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fc4:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800fc9:	eb 3d                	jmp    801008 <file_create+0x149>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800fcb:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800fd0:	eb 36                	jmp    801008 <file_create+0x149>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800fe2:	e8 ed 0f 00 00       	call   801fd4 <strcpy>
	*pf = f;
  800fe7:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff0:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800ff2:	83 c4 04             	add    $0x4,%esp
  800ff5:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  800ffb:	e8 22 fe ff ff       	call   800e22 <file_flush>
	return 0;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801017:	bb 01 00 00 00       	mov    $0x1,%ebx
  80101c:	eb 17                	jmp    801035 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	53                   	push   %ebx
  801022:	e8 48 f3 ff ff       	call   80036f <diskaddr>
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	e8 be f3 ff ff       	call   8003ed <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80102f:	83 c3 01             	add    $0x1,%ebx
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80103a:	3b 58 04             	cmp    0x4(%eax),%ebx
  80103d:	72 df                	jb     80101e <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80103f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80104a:	e8 c1 ff ff ff       	call   801010 <fs_sync>
	return 0;
}
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	ba 80 50 80 00       	mov    $0x805080,%edx
	int i;
	uintptr_t va = FILEVA;
  80105e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801068:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80106a:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80106d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801073:	83 c0 01             	add    $0x1,%eax
  801076:	83 c2 10             	add    $0x10,%edx
  801079:	3d 00 04 00 00       	cmp    $0x400,%eax
  80107e:	75 e8                	jne    801068 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80108a:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	89 d8                	mov    %ebx,%eax
  801094:	c1 e0 04             	shl    $0x4,%eax
  801097:	ff b0 8c 50 80 00    	pushl  0x80508c(%eax)
  80109d:	e8 8b 1f 00 00       	call   80302d <pageref>
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	74 07                	je     8010b0 <openfile_alloc+0x2e>
  8010a9:	83 f8 01             	cmp    $0x1,%eax
  8010ac:	74 22                	je     8010d0 <openfile_alloc+0x4e>
  8010ae:	eb 53                	jmp    801103 <openfile_alloc+0x81>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	6a 07                	push   $0x7
  8010b5:	89 d8                	mov    %ebx,%eax
  8010b7:	c1 e0 04             	shl    $0x4,%eax
  8010ba:	ff b0 8c 50 80 00    	pushl  0x80508c(%eax)
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 16 13 00 00       	call   8023dd <sys_page_alloc>
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 d2                	test   %edx,%edx
  8010ce:	78 43                	js     801113 <openfile_alloc+0x91>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010d0:	c1 e3 04             	shl    $0x4,%ebx
  8010d3:	8d 83 80 50 80 00    	lea    0x805080(%ebx),%eax
  8010d9:	81 83 80 50 80 00 00 	addl   $0x400,0x805080(%ebx)
  8010e0:	04 00 00 
			*o = &opentab[i];
  8010e3:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	68 00 10 00 00       	push   $0x1000
  8010ed:	6a 00                	push   $0x0
  8010ef:	ff b3 8c 50 80 00    	pushl  0x80508c(%ebx)
  8010f5:	e8 1f 10 00 00       	call   802119 <memset>
			return (*o)->o_fileid;
  8010fa:	8b 06                	mov    (%esi),%eax
  8010fc:	8b 00                	mov    (%eax),%eax
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	eb 10                	jmp    801113 <openfile_alloc+0x91>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801103:	83 c3 01             	add    $0x1,%ebx
  801106:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80110c:	75 81                	jne    80108f <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80110e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 18             	sub    $0x18,%esp
  801123:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801126:	89 fb                	mov    %edi,%ebx
  801128:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80112e:	89 de                	mov    %ebx,%esi
  801130:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801133:	ff b6 8c 50 80 00    	pushl  0x80508c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801139:	81 c6 80 50 80 00    	add    $0x805080,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80113f:	e8 e9 1e 00 00       	call   80302d <pageref>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	83 f8 01             	cmp    $0x1,%eax
  80114a:	7e 17                	jle    801163 <openfile_lookup+0x49>
  80114c:	c1 e3 04             	shl    $0x4,%ebx
  80114f:	39 bb 80 50 80 00    	cmp    %edi,0x805080(%ebx)
  801155:	75 13                	jne    80116a <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801157:	8b 45 10             	mov    0x10(%ebp),%eax
  80115a:	89 30                	mov    %esi,(%eax)
	return 0;
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
  801161:	eb 0c                	jmp    80116f <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801163:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801168:	eb 05                	jmp    80116f <openfile_lookup+0x55>
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 18             	sub    $0x18,%esp
  80117e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	ff 33                	pushl  (%ebx)
  801187:	ff 75 08             	pushl  0x8(%ebp)
  80118a:	e8 8b ff ff ff       	call   80111a <openfile_lookup>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 d2                	test   %edx,%edx
  801196:	78 14                	js     8011ac <serve_set_size+0x35>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	ff 73 04             	pushl  0x4(%ebx)
  80119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a1:	ff 70 04             	pushl  0x4(%eax)
  8011a4:	e8 f2 fa ff ff       	call   800c9b <file_set_size>
  8011a9:	83 c4 10             	add    $0x10,%esp
}
  8011ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 18             	sub    $0x18,%esp
  8011b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff 33                	pushl  (%ebx)
  8011c1:	ff 75 08             	pushl  0x8(%ebp)
  8011c4:	e8 51 ff ff ff       	call   80111a <openfile_lookup>
  8011c9:	83 c4 10             	add    $0x10,%esp
                return r;
  8011cc:	89 c2                	mov    %eax,%edx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 39                	js     80120b <serve_read+0x5a>
                return r;
        if((r = file_read(o->o_file, ret->ret_buf, MIN(req->req_n, sizeof(ret->ret_buf)), o->o_fd->fd_offset)) < 0)
  8011d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d5:	8b 42 0c             	mov    0xc(%edx),%eax
  8011d8:	ff 70 04             	pushl  0x4(%eax)
  8011db:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
  8011e7:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
  8011eb:	50                   	push   %eax
  8011ec:	53                   	push   %ebx
  8011ed:	ff 72 04             	pushl  0x4(%edx)
  8011f0:	e8 ff f9 ff ff       	call   800bf4 <file_read>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 0d                	js     801209 <serve_read+0x58>
                return r; 
        o->o_fd->fd_offset += r;      
  8011fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801202:	01 42 04             	add    %eax,0x4(%edx)
	return r;
  801205:	89 c2                	mov    %eax,%edx
  801207:	eb 02                	jmp    80120b <serve_read+0x5a>
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
                return r;
        if((r = file_read(o->o_file, ret->ret_buf, MIN(req->req_n, sizeof(ret->ret_buf)), o->o_fd->fd_offset)) < 0)
                return r; 
  801209:	89 c2                	mov    %eax,%edx
        o->o_fd->fd_offset += r;      
	return r;
}
  80120b:	89 d0                	mov    %edx,%eax
  80120d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	53                   	push   %ebx
  801216:	83 ec 18             	sub    $0x18,%esp
  801219:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	//panic("serve_write not implemented");
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80121c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 33                	pushl  (%ebx)
  801222:	ff 75 08             	pushl  0x8(%ebp)
  801225:	e8 f0 fe ff ff       	call   80111a <openfile_lookup>
  80122a:	83 c4 10             	add    $0x10,%esp
                return r;
  80122d:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	//panic("serve_write not implemented");
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 2e                	js     801261 <serve_write+0x4f>
                return r;
        if((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801233:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801236:	8b 50 0c             	mov    0xc(%eax),%edx
  801239:	ff 72 04             	pushl  0x4(%edx)
  80123c:	ff 73 04             	pushl  0x4(%ebx)
  80123f:	83 c3 08             	add    $0x8,%ebx
  801242:	53                   	push   %ebx
  801243:	ff 70 04             	pushl  0x4(%eax)
  801246:	e8 31 fb ff ff       	call   800d7c <file_write>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 0d                	js     80125f <serve_write+0x4d>
                return r; 
        o->o_fd->fd_offset += r;
  801252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801255:	8b 52 0c             	mov    0xc(%edx),%edx
  801258:	01 42 04             	add    %eax,0x4(%edx)
        return r;
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	eb 02                	jmp    801261 <serve_write+0x4f>
        struct OpenFile *o;
        int r;
        if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
                return r;
        if((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
                return r; 
  80125f:	89 c2                	mov    %eax,%edx
        o->o_fd->fd_offset += r;
        return r;
}
  801261:	89 d0                	mov    %edx,%eax
  801263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	83 ec 18             	sub    $0x18,%esp
  80126f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	ff 33                	pushl  (%ebx)
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 9a fe ff ff       	call   80111a <openfile_lookup>
  801280:	89 c2                	mov    %eax,%edx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 d2                	test   %edx,%edx
  801287:	78 3f                	js     8012c8 <serve_stat+0x60>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	ff 70 04             	pushl  0x4(%eax)
  801292:	53                   	push   %ebx
  801293:	e8 3c 0d 00 00       	call   801fd4 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129b:	8b 50 04             	mov    0x4(%eax),%edx
  80129e:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012a4:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012aa:	8b 40 04             	mov    0x4(%eax),%eax
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012b7:	0f 94 c0             	sete   %al
  8012ba:	0f b6 c0             	movzbl %al,%eax
  8012bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012da:	ff 30                	pushl  (%eax)
  8012dc:	ff 75 08             	pushl  0x8(%ebp)
  8012df:	e8 36 fe ff ff       	call   80111a <openfile_lookup>
  8012e4:	89 c2                	mov    %eax,%edx
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	85 d2                	test   %edx,%edx
  8012eb:	78 16                	js     801303 <serve_flush+0x36>
		return r;
	file_flush(o->o_file);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f3:	ff 70 04             	pushl  0x4(%eax)
  8012f6:	e8 27 fb ff ff       	call   800e22 <file_flush>
	return 0;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	81 ec 18 04 00 00    	sub    $0x418,%esp
  80130f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801312:	68 00 04 00 00       	push   $0x400
  801317:	53                   	push   %ebx
  801318:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	e8 42 0e 00 00       	call   802166 <memmove>
	path[MAXPATHLEN-1] = 0;
  801324:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801328:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80132e:	89 04 24             	mov    %eax,(%esp)
  801331:	e8 4c fd ff ff       	call   801082 <openfile_alloc>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	0f 88 f0 00 00 00    	js     801431 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801341:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801348:	74 33                	je     80137d <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	e8 5f fb ff ff       	call   800ebf <file_create>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	79 37                	jns    80139e <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801367:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80136a:	0f 85 c1 00 00 00    	jne    801431 <serve_open+0x12c>
  801370:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801377:	0f 85 b4 00 00 00    	jne    801431 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	e8 47 f8 ff ff       	call   800bda <file_open>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	0f 88 93 00 00 00    	js     801431 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80139e:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013a5:	74 17                	je     8013be <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	6a 00                	push   $0x0
  8013ac:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013b2:	e8 e4 f8 ff ff       	call   800c9b <file_set_size>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 73                	js     801431 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	e8 06 f8 ff ff       	call   800bda <file_open>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 56                	js     801431 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8013db:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013e1:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8013e7:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013ea:	8b 50 0c             	mov    0xc(%eax),%edx
  8013ed:	8b 08                	mov    (%eax),%ecx
  8013ef:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8013f2:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013f5:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8013fb:	83 e2 03             	and    $0x3,%edx
  8013fe:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801401:	8b 40 0c             	mov    0xc(%eax),%eax
  801404:	8b 15 84 90 80 00    	mov    0x809084,%edx
  80140a:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80140c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801412:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801418:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80141b:	8b 50 0c             	mov    0xc(%eax),%edx
  80141e:	8b 45 10             	mov    0x10(%ebp),%eax
  801421:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801423:	8b 45 14             	mov    0x14(%ebp),%eax
  801426:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	56                   	push   %esi
  80143a:	53                   	push   %ebx
  80143b:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80143e:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801441:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801444:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	53                   	push   %ebx
  80144f:	ff 35 64 50 80 00    	pushl  0x805064
  801455:	56                   	push   %esi
  801456:	e8 a7 12 00 00       	call   802702 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801462:	75 15                	jne    801479 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	ff 75 f4             	pushl  -0xc(%ebp)
  80146a:	68 68 3f 80 00       	push   $0x803f68
  80146f:	e8 d9 05 00 00       	call   801a4d <cprintf>
				whom);
			continue; // just leave it hanging...
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb cb                	jmp    801444 <serve+0xe>
		}

		pg = NULL;
  801479:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801480:	83 f8 01             	cmp    $0x1,%eax
  801483:	75 18                	jne    80149d <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801485:	53                   	push   %ebx
  801486:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	ff 35 64 50 80 00    	pushl  0x805064
  801490:	ff 75 f4             	pushl  -0xc(%ebp)
  801493:	e8 6d fe ff ff       	call   801305 <serve_open>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb 3c                	jmp    8014d9 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  80149d:	83 f8 08             	cmp    $0x8,%eax
  8014a0:	77 1e                	ja     8014c0 <serve+0x8a>
  8014a2:	8b 14 85 40 50 80 00 	mov    0x805040(,%eax,4),%edx
  8014a9:	85 d2                	test   %edx,%edx
  8014ab:	74 13                	je     8014c0 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	ff 35 64 50 80 00    	pushl  0x805064
  8014b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b9:	ff d2                	call   *%edx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	eb 19                	jmp    8014d9 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c6:	50                   	push   %eax
  8014c7:	68 98 3f 80 00       	push   $0x803f98
  8014cc:	e8 7c 05 00 00       	call   801a4d <cprintf>
  8014d1:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8014dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8014df:	50                   	push   %eax
  8014e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e3:	e8 83 12 00 00       	call   80276b <ipc_send>
		sys_page_unmap(0, fsreq);
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	ff 35 64 50 80 00    	pushl  0x805064
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 6a 0f 00 00       	call   802462 <sys_page_unmap>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	e9 44 ff ff ff       	jmp    801444 <serve+0xe>

00801500 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801506:	c7 05 80 90 80 00 bb 	movl   $0x803fbb,0x809080
  80150d:	3f 80 00 
	cprintf("FS is running\n");
  801510:	68 be 3f 80 00       	push   $0x803fbe
  801515:	e8 33 05 00 00       	call   801a4d <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80151a:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80151f:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801524:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801526:	c7 04 24 cd 3f 80 00 	movl   $0x803fcd,(%esp)
  80152d:	e8 1b 05 00 00       	call   801a4d <cprintf>

	serve_init();
  801532:	e8 1f fb ff ff       	call   801056 <serve_init>
	fs_init();
  801537:	e8 9a f3 ff ff       	call   8008d6 <fs_init>
	serve();
  80153c:	e8 f5 fe ff ff       	call   801436 <serve>

00801541 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801548:	6a 07                	push   $0x7
  80154a:	68 00 10 00 00       	push   $0x1000
  80154f:	6a 00                	push   $0x0
  801551:	e8 87 0e 00 00       	call   8023dd <sys_page_alloc>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	79 12                	jns    80156f <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80155d:	50                   	push   %eax
  80155e:	68 dc 3f 80 00       	push   $0x803fdc
  801563:	6a 12                	push   $0x12
  801565:	68 ef 3f 80 00       	push   $0x803fef
  80156a:	e8 05 04 00 00       	call   801974 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	68 00 10 00 00       	push   $0x1000
  801577:	ff 35 08 a0 80 00    	pushl  0x80a008
  80157d:	68 00 10 00 00       	push   $0x1000
  801582:	e8 df 0b 00 00       	call   802166 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801587:	e8 92 f1 ff ff       	call   80071e <alloc_block>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	79 12                	jns    8015a5 <fs_test+0x64>
		panic("alloc_block: %e", r);
  801593:	50                   	push   %eax
  801594:	68 f9 3f 80 00       	push   $0x803ff9
  801599:	6a 17                	push   $0x17
  80159b:	68 ef 3f 80 00       	push   $0x803fef
  8015a0:	e8 cf 03 00 00       	call   801974 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015a5:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	0f 49 d0             	cmovns %eax,%edx
  8015ad:	c1 fa 05             	sar    $0x5,%edx
  8015b0:	89 c3                	mov    %eax,%ebx
  8015b2:	c1 fb 1f             	sar    $0x1f,%ebx
  8015b5:	c1 eb 1b             	shr    $0x1b,%ebx
  8015b8:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015bb:	83 e1 1f             	and    $0x1f,%ecx
  8015be:	29 d9                	sub    %ebx,%ecx
  8015c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c5:	d3 e0                	shl    %cl,%eax
  8015c7:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015ce:	75 16                	jne    8015e6 <fs_test+0xa5>
  8015d0:	68 09 40 80 00       	push   $0x804009
  8015d5:	68 bd 3c 80 00       	push   $0x803cbd
  8015da:	6a 19                	push   $0x19
  8015dc:	68 ef 3f 80 00       	push   $0x803fef
  8015e1:	e8 8e 03 00 00       	call   801974 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015e6:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8015ec:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8015ef:	74 16                	je     801607 <fs_test+0xc6>
  8015f1:	68 84 41 80 00       	push   $0x804184
  8015f6:	68 bd 3c 80 00       	push   $0x803cbd
  8015fb:	6a 1b                	push   $0x1b
  8015fd:	68 ef 3f 80 00       	push   $0x803fef
  801602:	e8 6d 03 00 00       	call   801974 <_panic>
	cprintf("alloc_block is good\n");
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	68 24 40 80 00       	push   $0x804024
  80160f:	e8 39 04 00 00       	call   801a4d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	68 39 40 80 00       	push   $0x804039
  801620:	e8 b5 f5 ff ff       	call   800bda <file_open>
  801625:	89 c2                	mov    %eax,%edx
  801627:	c1 ea 1f             	shr    $0x1f,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	84 d2                	test   %dl,%dl
  80162f:	74 17                	je     801648 <fs_test+0x107>
  801631:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801634:	74 12                	je     801648 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801636:	50                   	push   %eax
  801637:	68 44 40 80 00       	push   $0x804044
  80163c:	6a 1f                	push   $0x1f
  80163e:	68 ef 3f 80 00       	push   $0x803fef
  801643:	e8 2c 03 00 00       	call   801974 <_panic>
	else if (r == 0)
  801648:	85 c0                	test   %eax,%eax
  80164a:	75 14                	jne    801660 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	68 a4 41 80 00       	push   $0x8041a4
  801654:	6a 21                	push   $0x21
  801656:	68 ef 3f 80 00       	push   $0x803fef
  80165b:	e8 14 03 00 00       	call   801974 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	68 5d 40 80 00       	push   $0x80405d
  80166c:	e8 69 f5 ff ff       	call   800bda <file_open>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	79 12                	jns    80168a <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801678:	50                   	push   %eax
  801679:	68 66 40 80 00       	push   $0x804066
  80167e:	6a 23                	push   $0x23
  801680:	68 ef 3f 80 00       	push   $0x803fef
  801685:	e8 ea 02 00 00       	call   801974 <_panic>
	cprintf("file_open is good\n");
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	68 7d 40 80 00       	push   $0x80407d
  801692:	e8 b6 03 00 00       	call   801a4d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801697:	83 c4 0c             	add    $0xc,%esp
  80169a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	6a 00                	push   $0x0
  8016a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a3:	e8 8d f2 ff ff       	call   800935 <file_get_block>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	79 12                	jns    8016c1 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016af:	50                   	push   %eax
  8016b0:	68 90 40 80 00       	push   $0x804090
  8016b5:	6a 27                	push   $0x27
  8016b7:	68 ef 3f 80 00       	push   $0x803fef
  8016bc:	e8 b3 02 00 00       	call   801974 <_panic>
	if (strcmp(blk, msg) != 0)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	68 c4 41 80 00       	push   $0x8041c4
  8016c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016cc:	e8 ad 09 00 00       	call   80207e <strcmp>
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	74 14                	je     8016ec <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	68 ec 41 80 00       	push   $0x8041ec
  8016e0:	6a 29                	push   $0x29
  8016e2:	68 ef 3f 80 00       	push   $0x803fef
  8016e7:	e8 88 02 00 00       	call   801974 <_panic>
	cprintf("file_get_block is good\n");
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	68 a3 40 80 00       	push   $0x8040a3
  8016f4:	e8 54 03 00 00       	call   801a4d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	0f b6 10             	movzbl (%eax),%edx
  8016ff:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	c1 e8 0c             	shr    $0xc,%eax
  801707:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	a8 40                	test   $0x40,%al
  801713:	75 16                	jne    80172b <fs_test+0x1ea>
  801715:	68 bc 40 80 00       	push   $0x8040bc
  80171a:	68 bd 3c 80 00       	push   $0x803cbd
  80171f:	6a 2d                	push   $0x2d
  801721:	68 ef 3f 80 00       	push   $0x803fef
  801726:	e8 49 02 00 00       	call   801974 <_panic>
	file_flush(f);
  80172b:	83 ec 0c             	sub    $0xc,%esp
  80172e:	ff 75 f4             	pushl  -0xc(%ebp)
  801731:	e8 ec f6 ff ff       	call   800e22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801739:	c1 e8 0c             	shr    $0xc,%eax
  80173c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	a8 40                	test   $0x40,%al
  801748:	74 16                	je     801760 <fs_test+0x21f>
  80174a:	68 bb 40 80 00       	push   $0x8040bb
  80174f:	68 bd 3c 80 00       	push   $0x803cbd
  801754:	6a 2f                	push   $0x2f
  801756:	68 ef 3f 80 00       	push   $0x803fef
  80175b:	e8 14 02 00 00       	call   801974 <_panic>
	cprintf("file_flush is good\n");
  801760:	83 ec 0c             	sub    $0xc,%esp
  801763:	68 d7 40 80 00       	push   $0x8040d7
  801768:	e8 e0 02 00 00       	call   801a4d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80176d:	83 c4 08             	add    $0x8,%esp
  801770:	6a 00                	push   $0x0
  801772:	ff 75 f4             	pushl  -0xc(%ebp)
  801775:	e8 21 f5 ff ff       	call   800c9b <file_set_size>
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	79 12                	jns    801793 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801781:	50                   	push   %eax
  801782:	68 eb 40 80 00       	push   $0x8040eb
  801787:	6a 33                	push   $0x33
  801789:	68 ef 3f 80 00       	push   $0x803fef
  80178e:	e8 e1 01 00 00       	call   801974 <_panic>
	assert(f->f_direct[0] == 0);
  801793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801796:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80179d:	74 16                	je     8017b5 <fs_test+0x274>
  80179f:	68 fd 40 80 00       	push   $0x8040fd
  8017a4:	68 bd 3c 80 00       	push   $0x803cbd
  8017a9:	6a 34                	push   $0x34
  8017ab:	68 ef 3f 80 00       	push   $0x803fef
  8017b0:	e8 bf 01 00 00       	call   801974 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017b5:	c1 e8 0c             	shr    $0xc,%eax
  8017b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017bf:	a8 40                	test   $0x40,%al
  8017c1:	74 16                	je     8017d9 <fs_test+0x298>
  8017c3:	68 11 41 80 00       	push   $0x804111
  8017c8:	68 bd 3c 80 00       	push   $0x803cbd
  8017cd:	6a 35                	push   $0x35
  8017cf:	68 ef 3f 80 00       	push   $0x803fef
  8017d4:	e8 9b 01 00 00       	call   801974 <_panic>
	cprintf("file_truncate is good\n");
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	68 2b 41 80 00       	push   $0x80412b
  8017e1:	e8 67 02 00 00       	call   801a4d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017e6:	c7 04 24 c4 41 80 00 	movl   $0x8041c4,(%esp)
  8017ed:	e8 a9 07 00 00       	call   801f9b <strlen>
  8017f2:	83 c4 08             	add    $0x8,%esp
  8017f5:	50                   	push   %eax
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	e8 9d f4 ff ff       	call   800c9b <file_set_size>
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	85 c0                	test   %eax,%eax
  801803:	79 12                	jns    801817 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801805:	50                   	push   %eax
  801806:	68 42 41 80 00       	push   $0x804142
  80180b:	6a 39                	push   $0x39
  80180d:	68 ef 3f 80 00       	push   $0x803fef
  801812:	e8 5d 01 00 00       	call   801974 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	c1 ea 0c             	shr    $0xc,%edx
  80181f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801826:	f6 c2 40             	test   $0x40,%dl
  801829:	74 16                	je     801841 <fs_test+0x300>
  80182b:	68 11 41 80 00       	push   $0x804111
  801830:	68 bd 3c 80 00       	push   $0x803cbd
  801835:	6a 3a                	push   $0x3a
  801837:	68 ef 3f 80 00       	push   $0x803fef
  80183c:	e8 33 01 00 00       	call   801974 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801847:	52                   	push   %edx
  801848:	6a 00                	push   $0x0
  80184a:	50                   	push   %eax
  80184b:	e8 e5 f0 ff ff       	call   800935 <file_get_block>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	79 12                	jns    801869 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801857:	50                   	push   %eax
  801858:	68 56 41 80 00       	push   $0x804156
  80185d:	6a 3c                	push   $0x3c
  80185f:	68 ef 3f 80 00       	push   $0x803fef
  801864:	e8 0b 01 00 00       	call   801974 <_panic>
	strcpy(blk, msg);
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	68 c4 41 80 00       	push   $0x8041c4
  801871:	ff 75 f0             	pushl  -0x10(%ebp)
  801874:	e8 5b 07 00 00       	call   801fd4 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	c1 e8 0c             	shr    $0xc,%eax
  80187f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	a8 40                	test   $0x40,%al
  80188b:	75 16                	jne    8018a3 <fs_test+0x362>
  80188d:	68 bc 40 80 00       	push   $0x8040bc
  801892:	68 bd 3c 80 00       	push   $0x803cbd
  801897:	6a 3e                	push   $0x3e
  801899:	68 ef 3f 80 00       	push   $0x803fef
  80189e:	e8 d1 00 00 00       	call   801974 <_panic>
	file_flush(f);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a9:	e8 74 f5 ff ff       	call   800e22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b1:	c1 e8 0c             	shr    $0xc,%eax
  8018b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	a8 40                	test   $0x40,%al
  8018c0:	74 16                	je     8018d8 <fs_test+0x397>
  8018c2:	68 bb 40 80 00       	push   $0x8040bb
  8018c7:	68 bd 3c 80 00       	push   $0x803cbd
  8018cc:	6a 40                	push   $0x40
  8018ce:	68 ef 3f 80 00       	push   $0x803fef
  8018d3:	e8 9c 00 00 00       	call   801974 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018db:	c1 e8 0c             	shr    $0xc,%eax
  8018de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e5:	a8 40                	test   $0x40,%al
  8018e7:	74 16                	je     8018ff <fs_test+0x3be>
  8018e9:	68 11 41 80 00       	push   $0x804111
  8018ee:	68 bd 3c 80 00       	push   $0x803cbd
  8018f3:	6a 41                	push   $0x41
  8018f5:	68 ef 3f 80 00       	push   $0x803fef
  8018fa:	e8 75 00 00 00       	call   801974 <_panic>
	cprintf("file rewrite is good\n");
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	68 6b 41 80 00       	push   $0x80416b
  801907:	e8 41 01 00 00       	call   801a4d <cprintf>
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80191c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80191f:	e8 7b 0a 00 00       	call   80239f <sys_getenvid>
  801924:	25 ff 03 00 00       	and    $0x3ff,%eax
  801929:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80192c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801931:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801936:	85 db                	test   %ebx,%ebx
  801938:	7e 07                	jle    801941 <libmain+0x2d>
		binaryname = argv[0];
  80193a:	8b 06                	mov    (%esi),%eax
  80193c:	a3 80 90 80 00       	mov    %eax,0x809080

	// call user main routine
	umain(argc, argv);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	e8 b5 fb ff ff       	call   801500 <umain>

	// exit gracefully
	exit();
  80194b:	e8 0a 00 00 00       	call   80195a <exit>
  801950:	83 c4 10             	add    $0x10,%esp
}
  801953:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801960:	e8 64 10 00 00       	call   8029c9 <close_all>
	sys_env_destroy(0);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	6a 00                	push   $0x0
  80196a:	e8 ef 09 00 00       	call   80235e <sys_env_destroy>
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801979:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80197c:	8b 35 80 90 80 00    	mov    0x809080,%esi
  801982:	e8 18 0a 00 00       	call   80239f <sys_getenvid>
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	ff 75 08             	pushl  0x8(%ebp)
  801990:	56                   	push   %esi
  801991:	50                   	push   %eax
  801992:	68 1c 42 80 00       	push   $0x80421c
  801997:	e8 b1 00 00 00       	call   801a4d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80199c:	83 c4 18             	add    $0x18,%esp
  80199f:	53                   	push   %ebx
  8019a0:	ff 75 10             	pushl  0x10(%ebp)
  8019a3:	e8 54 00 00 00       	call   8019fc <vcprintf>
	cprintf("\n");
  8019a8:	c7 04 24 2b 3e 80 00 	movl   $0x803e2b,(%esp)
  8019af:	e8 99 00 00 00       	call   801a4d <cprintf>
  8019b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019b7:	cc                   	int3   
  8019b8:	eb fd                	jmp    8019b7 <_panic+0x43>

008019ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 04             	sub    $0x4,%esp
  8019c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019c4:	8b 13                	mov    (%ebx),%edx
  8019c6:	8d 42 01             	lea    0x1(%edx),%eax
  8019c9:	89 03                	mov    %eax,(%ebx)
  8019cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019d7:	75 1a                	jne    8019f3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019d9:	83 ec 08             	sub    $0x8,%esp
  8019dc:	68 ff 00 00 00       	push   $0xff
  8019e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8019e4:	50                   	push   %eax
  8019e5:	e8 37 09 00 00       	call   802321 <sys_cputs>
		b->idx = 0;
  8019ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019f0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019f3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a05:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a0c:	00 00 00 
	b.cnt = 0;
  801a0f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a16:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a19:	ff 75 0c             	pushl  0xc(%ebp)
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a25:	50                   	push   %eax
  801a26:	68 ba 19 80 00       	push   $0x8019ba
  801a2b:	e8 4f 01 00 00       	call   801b7f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a30:	83 c4 08             	add    $0x8,%esp
  801a33:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a39:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a3f:	50                   	push   %eax
  801a40:	e8 dc 08 00 00       	call   802321 <sys_cputs>

	return b.cnt;
}
  801a45:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a53:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a56:	50                   	push   %eax
  801a57:	ff 75 08             	pushl  0x8(%ebp)
  801a5a:	e8 9d ff ff ff       	call   8019fc <vcprintf>
	va_end(ap);

	return cnt;
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	57                   	push   %edi
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 1c             	sub    $0x1c,%esp
  801a6a:	89 c7                	mov    %eax,%edi
  801a6c:	89 d6                	mov    %edx,%esi
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a74:	89 d1                	mov    %edx,%ecx
  801a76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a79:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a85:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801a8c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801a8f:	72 05                	jb     801a96 <printnum+0x35>
  801a91:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801a94:	77 3e                	ja     801ad4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	ff 75 18             	pushl  0x18(%ebp)
  801a9c:	83 eb 01             	sub    $0x1,%ebx
  801a9f:	53                   	push   %ebx
  801aa0:	50                   	push   %eax
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaa:	ff 75 dc             	pushl  -0x24(%ebp)
  801aad:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab0:	e8 0b 1f 00 00       	call   8039c0 <__udivdi3>
  801ab5:	83 c4 18             	add    $0x18,%esp
  801ab8:	52                   	push   %edx
  801ab9:	50                   	push   %eax
  801aba:	89 f2                	mov    %esi,%edx
  801abc:	89 f8                	mov    %edi,%eax
  801abe:	e8 9e ff ff ff       	call   801a61 <printnum>
  801ac3:	83 c4 20             	add    $0x20,%esp
  801ac6:	eb 13                	jmp    801adb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ac8:	83 ec 08             	sub    $0x8,%esp
  801acb:	56                   	push   %esi
  801acc:	ff 75 18             	pushl  0x18(%ebp)
  801acf:	ff d7                	call   *%edi
  801ad1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801ad4:	83 eb 01             	sub    $0x1,%ebx
  801ad7:	85 db                	test   %ebx,%ebx
  801ad9:	7f ed                	jg     801ac8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	56                   	push   %esi
  801adf:	83 ec 04             	sub    $0x4,%esp
  801ae2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae8:	ff 75 dc             	pushl  -0x24(%ebp)
  801aeb:	ff 75 d8             	pushl  -0x28(%ebp)
  801aee:	e8 fd 1f 00 00       	call   803af0 <__umoddi3>
  801af3:	83 c4 14             	add    $0x14,%esp
  801af6:	0f be 80 3f 42 80 00 	movsbl 0x80423f(%eax),%eax
  801afd:	50                   	push   %eax
  801afe:	ff d7                	call   *%edi
  801b00:	83 c4 10             	add    $0x10,%esp
}
  801b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b0e:	83 fa 01             	cmp    $0x1,%edx
  801b11:	7e 0e                	jle    801b21 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b13:	8b 10                	mov    (%eax),%edx
  801b15:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b18:	89 08                	mov    %ecx,(%eax)
  801b1a:	8b 02                	mov    (%edx),%eax
  801b1c:	8b 52 04             	mov    0x4(%edx),%edx
  801b1f:	eb 22                	jmp    801b43 <getuint+0x38>
	else if (lflag)
  801b21:	85 d2                	test   %edx,%edx
  801b23:	74 10                	je     801b35 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b25:	8b 10                	mov    (%eax),%edx
  801b27:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b2a:	89 08                	mov    %ecx,(%eax)
  801b2c:	8b 02                	mov    (%edx),%eax
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	eb 0e                	jmp    801b43 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b35:	8b 10                	mov    (%eax),%edx
  801b37:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b3a:	89 08                	mov    %ecx,(%eax)
  801b3c:	8b 02                	mov    (%edx),%eax
  801b3e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b4b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b4f:	8b 10                	mov    (%eax),%edx
  801b51:	3b 50 04             	cmp    0x4(%eax),%edx
  801b54:	73 0a                	jae    801b60 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b56:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b59:	89 08                	mov    %ecx,(%eax)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	88 02                	mov    %al,(%edx)
}
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b68:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b6b:	50                   	push   %eax
  801b6c:	ff 75 10             	pushl  0x10(%ebp)
  801b6f:	ff 75 0c             	pushl  0xc(%ebp)
  801b72:	ff 75 08             	pushl  0x8(%ebp)
  801b75:	e8 05 00 00 00       	call   801b7f <vprintfmt>
	va_end(ap);
  801b7a:	83 c4 10             	add    $0x10,%esp
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 2c             	sub    $0x2c,%esp
  801b88:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b8e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b91:	eb 12                	jmp    801ba5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 84 90 03 00 00    	je     801f2b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	53                   	push   %ebx
  801b9f:	50                   	push   %eax
  801ba0:	ff d6                	call   *%esi
  801ba2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ba5:	83 c7 01             	add    $0x1,%edi
  801ba8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bac:	83 f8 25             	cmp    $0x25,%eax
  801baf:	75 e2                	jne    801b93 <vprintfmt+0x14>
  801bb1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bb5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bbc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bc3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801bca:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcf:	eb 07                	jmp    801bd8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801bd4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd8:	8d 47 01             	lea    0x1(%edi),%eax
  801bdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bde:	0f b6 07             	movzbl (%edi),%eax
  801be1:	0f b6 c8             	movzbl %al,%ecx
  801be4:	83 e8 23             	sub    $0x23,%eax
  801be7:	3c 55                	cmp    $0x55,%al
  801be9:	0f 87 21 03 00 00    	ja     801f10 <vprintfmt+0x391>
  801bef:	0f b6 c0             	movzbl %al,%eax
  801bf2:	ff 24 85 80 43 80 00 	jmp    *0x804380(,%eax,4)
  801bf9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801bfc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c00:	eb d6                	jmp    801bd8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c0d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c10:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c14:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c17:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c1a:	83 fa 09             	cmp    $0x9,%edx
  801c1d:	77 39                	ja     801c58 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c1f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c22:	eb e9                	jmp    801c0d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c24:	8b 45 14             	mov    0x14(%ebp),%eax
  801c27:	8d 48 04             	lea    0x4(%eax),%ecx
  801c2a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c2d:	8b 00                	mov    (%eax),%eax
  801c2f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c35:	eb 27                	jmp    801c5e <vprintfmt+0xdf>
  801c37:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c41:	0f 49 c8             	cmovns %eax,%ecx
  801c44:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c4a:	eb 8c                	jmp    801bd8 <vprintfmt+0x59>
  801c4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c4f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c56:	eb 80                	jmp    801bd8 <vprintfmt+0x59>
  801c58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c5b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c5e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c62:	0f 89 70 ff ff ff    	jns    801bd8 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c68:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c6e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c75:	e9 5e ff ff ff       	jmp    801bd8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c7a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c80:	e9 53 ff ff ff       	jmp    801bd8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c85:	8b 45 14             	mov    0x14(%ebp),%eax
  801c88:	8d 50 04             	lea    0x4(%eax),%edx
  801c8b:	89 55 14             	mov    %edx,0x14(%ebp)
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	53                   	push   %ebx
  801c92:	ff 30                	pushl  (%eax)
  801c94:	ff d6                	call   *%esi
			break;
  801c96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c9c:	e9 04 ff ff ff       	jmp    801ba5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ca1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca4:	8d 50 04             	lea    0x4(%eax),%edx
  801ca7:	89 55 14             	mov    %edx,0x14(%ebp)
  801caa:	8b 00                	mov    (%eax),%eax
  801cac:	99                   	cltd   
  801cad:	31 d0                	xor    %edx,%eax
  801caf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cb1:	83 f8 0f             	cmp    $0xf,%eax
  801cb4:	7f 0b                	jg     801cc1 <vprintfmt+0x142>
  801cb6:	8b 14 85 00 45 80 00 	mov    0x804500(,%eax,4),%edx
  801cbd:	85 d2                	test   %edx,%edx
  801cbf:	75 18                	jne    801cd9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cc1:	50                   	push   %eax
  801cc2:	68 57 42 80 00       	push   $0x804257
  801cc7:	53                   	push   %ebx
  801cc8:	56                   	push   %esi
  801cc9:	e8 94 fe ff ff       	call   801b62 <printfmt>
  801cce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cd4:	e9 cc fe ff ff       	jmp    801ba5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cd9:	52                   	push   %edx
  801cda:	68 cf 3c 80 00       	push   $0x803ccf
  801cdf:	53                   	push   %ebx
  801ce0:	56                   	push   %esi
  801ce1:	e8 7c fe ff ff       	call   801b62 <printfmt>
  801ce6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cec:	e9 b4 fe ff ff       	jmp    801ba5 <vprintfmt+0x26>
  801cf1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801cfa:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfd:	8d 50 04             	lea    0x4(%eax),%edx
  801d00:	89 55 14             	mov    %edx,0x14(%ebp)
  801d03:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d05:	85 ff                	test   %edi,%edi
  801d07:	ba 50 42 80 00       	mov    $0x804250,%edx
  801d0c:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801d0f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d13:	0f 84 92 00 00 00    	je     801dab <vprintfmt+0x22c>
  801d19:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801d1d:	0f 8e 96 00 00 00    	jle    801db9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	51                   	push   %ecx
  801d27:	57                   	push   %edi
  801d28:	e8 86 02 00 00       	call   801fb3 <strnlen>
  801d2d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d30:	29 c1                	sub    %eax,%ecx
  801d32:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d35:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d38:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d3f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d42:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d44:	eb 0f                	jmp    801d55 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	53                   	push   %ebx
  801d4a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d4d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d4f:	83 ef 01             	sub    $0x1,%edi
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 ff                	test   %edi,%edi
  801d57:	7f ed                	jg     801d46 <vprintfmt+0x1c7>
  801d59:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d5c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d5f:	85 c9                	test   %ecx,%ecx
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
  801d66:	0f 49 c1             	cmovns %ecx,%eax
  801d69:	29 c1                	sub    %eax,%ecx
  801d6b:	89 75 08             	mov    %esi,0x8(%ebp)
  801d6e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d71:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d74:	89 cb                	mov    %ecx,%ebx
  801d76:	eb 4d                	jmp    801dc5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d78:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d7c:	74 1b                	je     801d99 <vprintfmt+0x21a>
  801d7e:	0f be c0             	movsbl %al,%eax
  801d81:	83 e8 20             	sub    $0x20,%eax
  801d84:	83 f8 5e             	cmp    $0x5e,%eax
  801d87:	76 10                	jbe    801d99 <vprintfmt+0x21a>
					putch('?', putdat);
  801d89:	83 ec 08             	sub    $0x8,%esp
  801d8c:	ff 75 0c             	pushl  0xc(%ebp)
  801d8f:	6a 3f                	push   $0x3f
  801d91:	ff 55 08             	call   *0x8(%ebp)
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	eb 0d                	jmp    801da6 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801d99:	83 ec 08             	sub    $0x8,%esp
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	52                   	push   %edx
  801da0:	ff 55 08             	call   *0x8(%ebp)
  801da3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801da6:	83 eb 01             	sub    $0x1,%ebx
  801da9:	eb 1a                	jmp    801dc5 <vprintfmt+0x246>
  801dab:	89 75 08             	mov    %esi,0x8(%ebp)
  801dae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801db1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801db4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801db7:	eb 0c                	jmp    801dc5 <vprintfmt+0x246>
  801db9:	89 75 08             	mov    %esi,0x8(%ebp)
  801dbc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dbf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dc5:	83 c7 01             	add    $0x1,%edi
  801dc8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801dcc:	0f be d0             	movsbl %al,%edx
  801dcf:	85 d2                	test   %edx,%edx
  801dd1:	74 23                	je     801df6 <vprintfmt+0x277>
  801dd3:	85 f6                	test   %esi,%esi
  801dd5:	78 a1                	js     801d78 <vprintfmt+0x1f9>
  801dd7:	83 ee 01             	sub    $0x1,%esi
  801dda:	79 9c                	jns    801d78 <vprintfmt+0x1f9>
  801ddc:	89 df                	mov    %ebx,%edi
  801dde:	8b 75 08             	mov    0x8(%ebp),%esi
  801de1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801de4:	eb 18                	jmp    801dfe <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801de6:	83 ec 08             	sub    $0x8,%esp
  801de9:	53                   	push   %ebx
  801dea:	6a 20                	push   $0x20
  801dec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801dee:	83 ef 01             	sub    $0x1,%edi
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	eb 08                	jmp    801dfe <vprintfmt+0x27f>
  801df6:	89 df                	mov    %ebx,%edi
  801df8:	8b 75 08             	mov    0x8(%ebp),%esi
  801dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dfe:	85 ff                	test   %edi,%edi
  801e00:	7f e4                	jg     801de6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e05:	e9 9b fd ff ff       	jmp    801ba5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e0a:	83 fa 01             	cmp    $0x1,%edx
  801e0d:	7e 16                	jle    801e25 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801e0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e12:	8d 50 08             	lea    0x8(%eax),%edx
  801e15:	89 55 14             	mov    %edx,0x14(%ebp)
  801e18:	8b 50 04             	mov    0x4(%eax),%edx
  801e1b:	8b 00                	mov    (%eax),%eax
  801e1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e20:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e23:	eb 32                	jmp    801e57 <vprintfmt+0x2d8>
	else if (lflag)
  801e25:	85 d2                	test   %edx,%edx
  801e27:	74 18                	je     801e41 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801e29:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2c:	8d 50 04             	lea    0x4(%eax),%edx
  801e2f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e32:	8b 00                	mov    (%eax),%eax
  801e34:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e37:	89 c1                	mov    %eax,%ecx
  801e39:	c1 f9 1f             	sar    $0x1f,%ecx
  801e3c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e3f:	eb 16                	jmp    801e57 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801e41:	8b 45 14             	mov    0x14(%ebp),%eax
  801e44:	8d 50 04             	lea    0x4(%eax),%edx
  801e47:	89 55 14             	mov    %edx,0x14(%ebp)
  801e4a:	8b 00                	mov    (%eax),%eax
  801e4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e4f:	89 c1                	mov    %eax,%ecx
  801e51:	c1 f9 1f             	sar    $0x1f,%ecx
  801e54:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e57:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e62:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e66:	79 74                	jns    801edc <vprintfmt+0x35d>
				putch('-', putdat);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	53                   	push   %ebx
  801e6c:	6a 2d                	push   $0x2d
  801e6e:	ff d6                	call   *%esi
				num = -(long long) num;
  801e70:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e73:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e76:	f7 d8                	neg    %eax
  801e78:	83 d2 00             	adc    $0x0,%edx
  801e7b:	f7 da                	neg    %edx
  801e7d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e80:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e85:	eb 55                	jmp    801edc <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e87:	8d 45 14             	lea    0x14(%ebp),%eax
  801e8a:	e8 7c fc ff ff       	call   801b0b <getuint>
			base = 10;
  801e8f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e94:	eb 46                	jmp    801edc <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801e96:	8d 45 14             	lea    0x14(%ebp),%eax
  801e99:	e8 6d fc ff ff       	call   801b0b <getuint>
                        base = 8;
  801e9e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ea3:	eb 37                	jmp    801edc <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	53                   	push   %ebx
  801ea9:	6a 30                	push   $0x30
  801eab:	ff d6                	call   *%esi
			putch('x', putdat);
  801ead:	83 c4 08             	add    $0x8,%esp
  801eb0:	53                   	push   %ebx
  801eb1:	6a 78                	push   $0x78
  801eb3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801eb5:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb8:	8d 50 04             	lea    0x4(%eax),%edx
  801ebb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ebe:	8b 00                	mov    (%eax),%eax
  801ec0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ec5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ec8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ecd:	eb 0d                	jmp    801edc <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ecf:	8d 45 14             	lea    0x14(%ebp),%eax
  801ed2:	e8 34 fc ff ff       	call   801b0b <getuint>
			base = 16;
  801ed7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ee3:	57                   	push   %edi
  801ee4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee7:	51                   	push   %ecx
  801ee8:	52                   	push   %edx
  801ee9:	50                   	push   %eax
  801eea:	89 da                	mov    %ebx,%edx
  801eec:	89 f0                	mov    %esi,%eax
  801eee:	e8 6e fb ff ff       	call   801a61 <printnum>
			break;
  801ef3:	83 c4 20             	add    $0x20,%esp
  801ef6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ef9:	e9 a7 fc ff ff       	jmp    801ba5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801efe:	83 ec 08             	sub    $0x8,%esp
  801f01:	53                   	push   %ebx
  801f02:	51                   	push   %ecx
  801f03:	ff d6                	call   *%esi
			break;
  801f05:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f0b:	e9 95 fc ff ff       	jmp    801ba5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f10:	83 ec 08             	sub    $0x8,%esp
  801f13:	53                   	push   %ebx
  801f14:	6a 25                	push   $0x25
  801f16:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	eb 03                	jmp    801f20 <vprintfmt+0x3a1>
  801f1d:	83 ef 01             	sub    $0x1,%edi
  801f20:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f24:	75 f7                	jne    801f1d <vprintfmt+0x39e>
  801f26:	e9 7a fc ff ff       	jmp    801ba5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 18             	sub    $0x18,%esp
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f50:	85 c0                	test   %eax,%eax
  801f52:	74 26                	je     801f7a <vsnprintf+0x47>
  801f54:	85 d2                	test   %edx,%edx
  801f56:	7e 22                	jle    801f7a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f58:	ff 75 14             	pushl  0x14(%ebp)
  801f5b:	ff 75 10             	pushl  0x10(%ebp)
  801f5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f61:	50                   	push   %eax
  801f62:	68 45 1b 80 00       	push   $0x801b45
  801f67:	e8 13 fc ff ff       	call   801b7f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	eb 05                	jmp    801f7f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f87:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f8a:	50                   	push   %eax
  801f8b:	ff 75 10             	pushl  0x10(%ebp)
  801f8e:	ff 75 0c             	pushl  0xc(%ebp)
  801f91:	ff 75 08             	pushl  0x8(%ebp)
  801f94:	e8 9a ff ff ff       	call   801f33 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa6:	eb 03                	jmp    801fab <strlen+0x10>
		n++;
  801fa8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801faf:	75 f7                	jne    801fa8 <strlen+0xd>
		n++;
	return n;
}
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fbc:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc1:	eb 03                	jmp    801fc6 <strnlen+0x13>
		n++;
  801fc3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fc6:	39 c2                	cmp    %eax,%edx
  801fc8:	74 08                	je     801fd2 <strnlen+0x1f>
  801fca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801fce:	75 f3                	jne    801fc3 <strnlen+0x10>
  801fd0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	53                   	push   %ebx
  801fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801fde:	89 c2                	mov    %eax,%edx
  801fe0:	83 c2 01             	add    $0x1,%edx
  801fe3:	83 c1 01             	add    $0x1,%ecx
  801fe6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801fea:	88 5a ff             	mov    %bl,-0x1(%edx)
  801fed:	84 db                	test   %bl,%bl
  801fef:	75 ef                	jne    801fe0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ff1:	5b                   	pop    %ebx
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	53                   	push   %ebx
  801ff8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ffb:	53                   	push   %ebx
  801ffc:	e8 9a ff ff ff       	call   801f9b <strlen>
  802001:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802004:	ff 75 0c             	pushl  0xc(%ebp)
  802007:	01 d8                	add    %ebx,%eax
  802009:	50                   	push   %eax
  80200a:	e8 c5 ff ff ff       	call   801fd4 <strcpy>
	return dst;
}
  80200f:	89 d8                	mov    %ebx,%eax
  802011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	8b 75 08             	mov    0x8(%ebp),%esi
  80201e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802021:	89 f3                	mov    %esi,%ebx
  802023:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802026:	89 f2                	mov    %esi,%edx
  802028:	eb 0f                	jmp    802039 <strncpy+0x23>
		*dst++ = *src;
  80202a:	83 c2 01             	add    $0x1,%edx
  80202d:	0f b6 01             	movzbl (%ecx),%eax
  802030:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802033:	80 39 01             	cmpb   $0x1,(%ecx)
  802036:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802039:	39 da                	cmp    %ebx,%edx
  80203b:	75 ed                	jne    80202a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5d                   	pop    %ebp
  802042:	c3                   	ret    

00802043 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	8b 75 08             	mov    0x8(%ebp),%esi
  80204b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204e:	8b 55 10             	mov    0x10(%ebp),%edx
  802051:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802053:	85 d2                	test   %edx,%edx
  802055:	74 21                	je     802078 <strlcpy+0x35>
  802057:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80205b:	89 f2                	mov    %esi,%edx
  80205d:	eb 09                	jmp    802068 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80205f:	83 c2 01             	add    $0x1,%edx
  802062:	83 c1 01             	add    $0x1,%ecx
  802065:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802068:	39 c2                	cmp    %eax,%edx
  80206a:	74 09                	je     802075 <strlcpy+0x32>
  80206c:	0f b6 19             	movzbl (%ecx),%ebx
  80206f:	84 db                	test   %bl,%bl
  802071:	75 ec                	jne    80205f <strlcpy+0x1c>
  802073:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802075:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802078:	29 f0                	sub    %esi,%eax
}
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802084:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802087:	eb 06                	jmp    80208f <strcmp+0x11>
		p++, q++;
  802089:	83 c1 01             	add    $0x1,%ecx
  80208c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80208f:	0f b6 01             	movzbl (%ecx),%eax
  802092:	84 c0                	test   %al,%al
  802094:	74 04                	je     80209a <strcmp+0x1c>
  802096:	3a 02                	cmp    (%edx),%al
  802098:	74 ef                	je     802089 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80209a:	0f b6 c0             	movzbl %al,%eax
  80209d:	0f b6 12             	movzbl (%edx),%edx
  8020a0:	29 d0                	sub    %edx,%eax
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	53                   	push   %ebx
  8020a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020b3:	eb 06                	jmp    8020bb <strncmp+0x17>
		n--, p++, q++;
  8020b5:	83 c0 01             	add    $0x1,%eax
  8020b8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020bb:	39 d8                	cmp    %ebx,%eax
  8020bd:	74 15                	je     8020d4 <strncmp+0x30>
  8020bf:	0f b6 08             	movzbl (%eax),%ecx
  8020c2:	84 c9                	test   %cl,%cl
  8020c4:	74 04                	je     8020ca <strncmp+0x26>
  8020c6:	3a 0a                	cmp    (%edx),%cl
  8020c8:	74 eb                	je     8020b5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020ca:	0f b6 00             	movzbl (%eax),%eax
  8020cd:	0f b6 12             	movzbl (%edx),%edx
  8020d0:	29 d0                	sub    %edx,%eax
  8020d2:	eb 05                	jmp    8020d9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8020d9:	5b                   	pop    %ebx
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    

008020dc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020e6:	eb 07                	jmp    8020ef <strchr+0x13>
		if (*s == c)
  8020e8:	38 ca                	cmp    %cl,%dl
  8020ea:	74 0f                	je     8020fb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020ec:	83 c0 01             	add    $0x1,%eax
  8020ef:	0f b6 10             	movzbl (%eax),%edx
  8020f2:	84 d2                	test   %dl,%dl
  8020f4:	75 f2                	jne    8020e8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8020f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	8b 45 08             	mov    0x8(%ebp),%eax
  802103:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802107:	eb 03                	jmp    80210c <strfind+0xf>
  802109:	83 c0 01             	add    $0x1,%eax
  80210c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80210f:	84 d2                	test   %dl,%dl
  802111:	74 04                	je     802117 <strfind+0x1a>
  802113:	38 ca                	cmp    %cl,%dl
  802115:	75 f2                	jne    802109 <strfind+0xc>
			break;
	return (char *) s;
}
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    

00802119 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	57                   	push   %edi
  80211d:	56                   	push   %esi
  80211e:	53                   	push   %ebx
  80211f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802122:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802125:	85 c9                	test   %ecx,%ecx
  802127:	74 36                	je     80215f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802129:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80212f:	75 28                	jne    802159 <memset+0x40>
  802131:	f6 c1 03             	test   $0x3,%cl
  802134:	75 23                	jne    802159 <memset+0x40>
		c &= 0xFF;
  802136:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80213a:	89 d3                	mov    %edx,%ebx
  80213c:	c1 e3 08             	shl    $0x8,%ebx
  80213f:	89 d6                	mov    %edx,%esi
  802141:	c1 e6 18             	shl    $0x18,%esi
  802144:	89 d0                	mov    %edx,%eax
  802146:	c1 e0 10             	shl    $0x10,%eax
  802149:	09 f0                	or     %esi,%eax
  80214b:	09 c2                	or     %eax,%edx
  80214d:	89 d0                	mov    %edx,%eax
  80214f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802151:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802154:	fc                   	cld    
  802155:	f3 ab                	rep stos %eax,%es:(%edi)
  802157:	eb 06                	jmp    80215f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215c:	fc                   	cld    
  80215d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80215f:	89 f8                	mov    %edi,%eax
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	57                   	push   %edi
  80216a:	56                   	push   %esi
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802171:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802174:	39 c6                	cmp    %eax,%esi
  802176:	73 35                	jae    8021ad <memmove+0x47>
  802178:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80217b:	39 d0                	cmp    %edx,%eax
  80217d:	73 2e                	jae    8021ad <memmove+0x47>
		s += n;
		d += n;
  80217f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802182:	89 d6                	mov    %edx,%esi
  802184:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802186:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80218c:	75 13                	jne    8021a1 <memmove+0x3b>
  80218e:	f6 c1 03             	test   $0x3,%cl
  802191:	75 0e                	jne    8021a1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802193:	83 ef 04             	sub    $0x4,%edi
  802196:	8d 72 fc             	lea    -0x4(%edx),%esi
  802199:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80219c:	fd                   	std    
  80219d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80219f:	eb 09                	jmp    8021aa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8021a1:	83 ef 01             	sub    $0x1,%edi
  8021a4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021a7:	fd                   	std    
  8021a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021aa:	fc                   	cld    
  8021ab:	eb 1d                	jmp    8021ca <memmove+0x64>
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b1:	f6 c2 03             	test   $0x3,%dl
  8021b4:	75 0f                	jne    8021c5 <memmove+0x5f>
  8021b6:	f6 c1 03             	test   $0x3,%cl
  8021b9:	75 0a                	jne    8021c5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8021bb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8021be:	89 c7                	mov    %eax,%edi
  8021c0:	fc                   	cld    
  8021c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021c3:	eb 05                	jmp    8021ca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021c5:	89 c7                	mov    %eax,%edi
  8021c7:	fc                   	cld    
  8021c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021ca:	5e                   	pop    %esi
  8021cb:	5f                   	pop    %edi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    

008021ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8021d1:	ff 75 10             	pushl  0x10(%ebp)
  8021d4:	ff 75 0c             	pushl  0xc(%ebp)
  8021d7:	ff 75 08             	pushl  0x8(%ebp)
  8021da:	e8 87 ff ff ff       	call   802166 <memmove>
}
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ec:	89 c6                	mov    %eax,%esi
  8021ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8021f1:	eb 1a                	jmp    80220d <memcmp+0x2c>
		if (*s1 != *s2)
  8021f3:	0f b6 08             	movzbl (%eax),%ecx
  8021f6:	0f b6 1a             	movzbl (%edx),%ebx
  8021f9:	38 d9                	cmp    %bl,%cl
  8021fb:	74 0a                	je     802207 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8021fd:	0f b6 c1             	movzbl %cl,%eax
  802200:	0f b6 db             	movzbl %bl,%ebx
  802203:	29 d8                	sub    %ebx,%eax
  802205:	eb 0f                	jmp    802216 <memcmp+0x35>
		s1++, s2++;
  802207:	83 c0 01             	add    $0x1,%eax
  80220a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80220d:	39 f0                	cmp    %esi,%eax
  80220f:	75 e2                	jne    8021f3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802211:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802216:	5b                   	pop    %ebx
  802217:	5e                   	pop    %esi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    

0080221a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	8b 45 08             	mov    0x8(%ebp),%eax
  802220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802223:	89 c2                	mov    %eax,%edx
  802225:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802228:	eb 07                	jmp    802231 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80222a:	38 08                	cmp    %cl,(%eax)
  80222c:	74 07                	je     802235 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80222e:	83 c0 01             	add    $0x1,%eax
  802231:	39 d0                	cmp    %edx,%eax
  802233:	72 f5                	jb     80222a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	57                   	push   %edi
  80223b:	56                   	push   %esi
  80223c:	53                   	push   %ebx
  80223d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802243:	eb 03                	jmp    802248 <strtol+0x11>
		s++;
  802245:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802248:	0f b6 01             	movzbl (%ecx),%eax
  80224b:	3c 09                	cmp    $0x9,%al
  80224d:	74 f6                	je     802245 <strtol+0xe>
  80224f:	3c 20                	cmp    $0x20,%al
  802251:	74 f2                	je     802245 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802253:	3c 2b                	cmp    $0x2b,%al
  802255:	75 0a                	jne    802261 <strtol+0x2a>
		s++;
  802257:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80225a:	bf 00 00 00 00       	mov    $0x0,%edi
  80225f:	eb 10                	jmp    802271 <strtol+0x3a>
  802261:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802266:	3c 2d                	cmp    $0x2d,%al
  802268:	75 07                	jne    802271 <strtol+0x3a>
		s++, neg = 1;
  80226a:	8d 49 01             	lea    0x1(%ecx),%ecx
  80226d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802271:	85 db                	test   %ebx,%ebx
  802273:	0f 94 c0             	sete   %al
  802276:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80227c:	75 19                	jne    802297 <strtol+0x60>
  80227e:	80 39 30             	cmpb   $0x30,(%ecx)
  802281:	75 14                	jne    802297 <strtol+0x60>
  802283:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802287:	0f 85 82 00 00 00    	jne    80230f <strtol+0xd8>
		s += 2, base = 16;
  80228d:	83 c1 02             	add    $0x2,%ecx
  802290:	bb 10 00 00 00       	mov    $0x10,%ebx
  802295:	eb 16                	jmp    8022ad <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  802297:	84 c0                	test   %al,%al
  802299:	74 12                	je     8022ad <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80229b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8022a3:	75 08                	jne    8022ad <strtol+0x76>
		s++, base = 8;
  8022a5:	83 c1 01             	add    $0x1,%ecx
  8022a8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022b5:	0f b6 11             	movzbl (%ecx),%edx
  8022b8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022bb:	89 f3                	mov    %esi,%ebx
  8022bd:	80 fb 09             	cmp    $0x9,%bl
  8022c0:	77 08                	ja     8022ca <strtol+0x93>
			dig = *s - '0';
  8022c2:	0f be d2             	movsbl %dl,%edx
  8022c5:	83 ea 30             	sub    $0x30,%edx
  8022c8:	eb 22                	jmp    8022ec <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8022ca:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022cd:	89 f3                	mov    %esi,%ebx
  8022cf:	80 fb 19             	cmp    $0x19,%bl
  8022d2:	77 08                	ja     8022dc <strtol+0xa5>
			dig = *s - 'a' + 10;
  8022d4:	0f be d2             	movsbl %dl,%edx
  8022d7:	83 ea 57             	sub    $0x57,%edx
  8022da:	eb 10                	jmp    8022ec <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8022dc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8022df:	89 f3                	mov    %esi,%ebx
  8022e1:	80 fb 19             	cmp    $0x19,%bl
  8022e4:	77 16                	ja     8022fc <strtol+0xc5>
			dig = *s - 'A' + 10;
  8022e6:	0f be d2             	movsbl %dl,%edx
  8022e9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8022ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8022ef:	7d 0f                	jge    802300 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8022f1:	83 c1 01             	add    $0x1,%ecx
  8022f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8022f8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8022fa:	eb b9                	jmp    8022b5 <strtol+0x7e>
  8022fc:	89 c2                	mov    %eax,%edx
  8022fe:	eb 02                	jmp    802302 <strtol+0xcb>
  802300:	89 c2                	mov    %eax,%edx

	if (endptr)
  802302:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802306:	74 0d                	je     802315 <strtol+0xde>
		*endptr = (char *) s;
  802308:	8b 75 0c             	mov    0xc(%ebp),%esi
  80230b:	89 0e                	mov    %ecx,(%esi)
  80230d:	eb 06                	jmp    802315 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80230f:	84 c0                	test   %al,%al
  802311:	75 92                	jne    8022a5 <strtol+0x6e>
  802313:	eb 98                	jmp    8022ad <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802315:	f7 da                	neg    %edx
  802317:	85 ff                	test   %edi,%edi
  802319:	0f 45 c2             	cmovne %edx,%eax
}
  80231c:	5b                   	pop    %ebx
  80231d:	5e                   	pop    %esi
  80231e:	5f                   	pop    %edi
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	57                   	push   %edi
  802325:	56                   	push   %esi
  802326:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
  80232c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80232f:	8b 55 08             	mov    0x8(%ebp),%edx
  802332:	89 c3                	mov    %eax,%ebx
  802334:	89 c7                	mov    %eax,%edi
  802336:	89 c6                	mov    %eax,%esi
  802338:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80233a:	5b                   	pop    %ebx
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    

0080233f <sys_cgetc>:

int
sys_cgetc(void)
{
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	57                   	push   %edi
  802343:	56                   	push   %esi
  802344:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802345:	ba 00 00 00 00       	mov    $0x0,%edx
  80234a:	b8 01 00 00 00       	mov    $0x1,%eax
  80234f:	89 d1                	mov    %edx,%ecx
  802351:	89 d3                	mov    %edx,%ebx
  802353:	89 d7                	mov    %edx,%edi
  802355:	89 d6                	mov    %edx,%esi
  802357:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802359:	5b                   	pop    %ebx
  80235a:	5e                   	pop    %esi
  80235b:	5f                   	pop    %edi
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    

0080235e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80236c:	b8 03 00 00 00       	mov    $0x3,%eax
  802371:	8b 55 08             	mov    0x8(%ebp),%edx
  802374:	89 cb                	mov    %ecx,%ebx
  802376:	89 cf                	mov    %ecx,%edi
  802378:	89 ce                	mov    %ecx,%esi
  80237a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80237c:	85 c0                	test   %eax,%eax
  80237e:	7e 17                	jle    802397 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802380:	83 ec 0c             	sub    $0xc,%esp
  802383:	50                   	push   %eax
  802384:	6a 03                	push   $0x3
  802386:	68 5f 45 80 00       	push   $0x80455f
  80238b:	6a 22                	push   $0x22
  80238d:	68 7c 45 80 00       	push   $0x80457c
  802392:	e8 dd f5 ff ff       	call   801974 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239a:	5b                   	pop    %ebx
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	57                   	push   %edi
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8023a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8023af:	89 d1                	mov    %edx,%ecx
  8023b1:	89 d3                	mov    %edx,%ebx
  8023b3:	89 d7                	mov    %edx,%edi
  8023b5:	89 d6                	mov    %edx,%esi
  8023b7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5f                   	pop    %edi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <sys_yield>:

void
sys_yield(void)
{      
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8023c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023ce:	89 d1                	mov    %edx,%ecx
  8023d0:	89 d3                	mov    %edx,%ebx
  8023d2:	89 d7                	mov    %edx,%edi
  8023d4:	89 d6                	mov    %edx,%esi
  8023d6:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    

008023dd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	57                   	push   %edi
  8023e1:	56                   	push   %esi
  8023e2:	53                   	push   %ebx
  8023e3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8023e6:	be 00 00 00 00       	mov    $0x0,%esi
  8023eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8023f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8023f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023f9:	89 f7                	mov    %esi,%edi
  8023fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	7e 17                	jle    802418 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802401:	83 ec 0c             	sub    $0xc,%esp
  802404:	50                   	push   %eax
  802405:	6a 04                	push   $0x4
  802407:	68 5f 45 80 00       	push   $0x80455f
  80240c:	6a 22                	push   $0x22
  80240e:	68 7c 45 80 00       	push   $0x80457c
  802413:	e8 5c f5 ff ff       	call   801974 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802418:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241b:	5b                   	pop    %ebx
  80241c:	5e                   	pop    %esi
  80241d:	5f                   	pop    %edi
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	57                   	push   %edi
  802424:	56                   	push   %esi
  802425:	53                   	push   %ebx
  802426:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802429:	b8 05 00 00 00       	mov    $0x5,%eax
  80242e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802431:	8b 55 08             	mov    0x8(%ebp),%edx
  802434:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802437:	8b 7d 14             	mov    0x14(%ebp),%edi
  80243a:	8b 75 18             	mov    0x18(%ebp),%esi
  80243d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80243f:	85 c0                	test   %eax,%eax
  802441:	7e 17                	jle    80245a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802443:	83 ec 0c             	sub    $0xc,%esp
  802446:	50                   	push   %eax
  802447:	6a 05                	push   $0x5
  802449:	68 5f 45 80 00       	push   $0x80455f
  80244e:	6a 22                	push   $0x22
  802450:	68 7c 45 80 00       	push   $0x80457c
  802455:	e8 1a f5 ff ff       	call   801974 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80245a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    

00802462 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	57                   	push   %edi
  802466:	56                   	push   %esi
  802467:	53                   	push   %ebx
  802468:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80246b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802470:	b8 06 00 00 00       	mov    $0x6,%eax
  802475:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802478:	8b 55 08             	mov    0x8(%ebp),%edx
  80247b:	89 df                	mov    %ebx,%edi
  80247d:	89 de                	mov    %ebx,%esi
  80247f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802481:	85 c0                	test   %eax,%eax
  802483:	7e 17                	jle    80249c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802485:	83 ec 0c             	sub    $0xc,%esp
  802488:	50                   	push   %eax
  802489:	6a 06                	push   $0x6
  80248b:	68 5f 45 80 00       	push   $0x80455f
  802490:	6a 22                	push   $0x22
  802492:	68 7c 45 80 00       	push   $0x80457c
  802497:	e8 d8 f4 ff ff       	call   801974 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80249c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80249f:	5b                   	pop    %ebx
  8024a0:	5e                   	pop    %esi
  8024a1:	5f                   	pop    %edi
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8024ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8024b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8024bd:	89 df                	mov    %ebx,%edi
  8024bf:	89 de                	mov    %ebx,%esi
  8024c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024c3:	85 c0                	test   %eax,%eax
  8024c5:	7e 17                	jle    8024de <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024c7:	83 ec 0c             	sub    $0xc,%esp
  8024ca:	50                   	push   %eax
  8024cb:	6a 08                	push   $0x8
  8024cd:	68 5f 45 80 00       	push   $0x80455f
  8024d2:	6a 22                	push   $0x22
  8024d4:	68 7c 45 80 00       	push   $0x80457c
  8024d9:	e8 96 f4 ff ff       	call   801974 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  8024de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    

008024e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	57                   	push   %edi
  8024ea:	56                   	push   %esi
  8024eb:	53                   	push   %ebx
  8024ec:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8024ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8024f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ff:	89 df                	mov    %ebx,%edi
  802501:	89 de                	mov    %ebx,%esi
  802503:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802505:	85 c0                	test   %eax,%eax
  802507:	7e 17                	jle    802520 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	50                   	push   %eax
  80250d:	6a 09                	push   $0x9
  80250f:	68 5f 45 80 00       	push   $0x80455f
  802514:	6a 22                	push   $0x22
  802516:	68 7c 45 80 00       	push   $0x80457c
  80251b:	e8 54 f4 ff ff       	call   801974 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802520:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    

00802528 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802528:	55                   	push   %ebp
  802529:	89 e5                	mov    %esp,%ebp
  80252b:	57                   	push   %edi
  80252c:	56                   	push   %esi
  80252d:	53                   	push   %ebx
  80252e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802531:	bb 00 00 00 00       	mov    $0x0,%ebx
  802536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80253b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80253e:	8b 55 08             	mov    0x8(%ebp),%edx
  802541:	89 df                	mov    %ebx,%edi
  802543:	89 de                	mov    %ebx,%esi
  802545:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802547:	85 c0                	test   %eax,%eax
  802549:	7e 17                	jle    802562 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80254b:	83 ec 0c             	sub    $0xc,%esp
  80254e:	50                   	push   %eax
  80254f:	6a 0a                	push   $0xa
  802551:	68 5f 45 80 00       	push   $0x80455f
  802556:	6a 22                	push   $0x22
  802558:	68 7c 45 80 00       	push   $0x80457c
  80255d:	e8 12 f4 ff ff       	call   801974 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802562:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802565:	5b                   	pop    %ebx
  802566:	5e                   	pop    %esi
  802567:	5f                   	pop    %edi
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802570:	be 00 00 00 00       	mov    $0x0,%esi
  802575:	b8 0c 00 00 00       	mov    $0xc,%eax
  80257a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80257d:	8b 55 08             	mov    0x8(%ebp),%edx
  802580:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802583:	8b 7d 14             	mov    0x14(%ebp),%edi
  802586:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	57                   	push   %edi
  802591:	56                   	push   %esi
  802592:	53                   	push   %ebx
  802593:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80259b:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a3:	89 cb                	mov    %ecx,%ebx
  8025a5:	89 cf                	mov    %ecx,%edi
  8025a7:	89 ce                	mov    %ecx,%esi
  8025a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	7e 17                	jle    8025c6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025af:	83 ec 0c             	sub    $0xc,%esp
  8025b2:	50                   	push   %eax
  8025b3:	6a 0d                	push   $0xd
  8025b5:	68 5f 45 80 00       	push   $0x80455f
  8025ba:	6a 22                	push   $0x22
  8025bc:	68 7c 45 80 00       	push   $0x80457c
  8025c1:	e8 ae f3 ff ff       	call   801974 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c9:	5b                   	pop    %ebx
  8025ca:	5e                   	pop    %esi
  8025cb:	5f                   	pop    %edi
  8025cc:	5d                   	pop    %ebp
  8025cd:	c3                   	ret    

008025ce <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  8025ce:	55                   	push   %ebp
  8025cf:	89 e5                	mov    %esp,%ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8025d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8025d9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8025de:	89 d1                	mov    %edx,%ecx
  8025e0:	89 d3                	mov    %edx,%ebx
  8025e2:	89 d7                	mov    %edx,%edi
  8025e4:	89 d6                	mov    %edx,%esi
  8025e6:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    

008025ed <sys_transmit>:

int
sys_transmit(void *addr)
{
  8025ed:	55                   	push   %ebp
  8025ee:	89 e5                	mov    %esp,%ebp
  8025f0:	57                   	push   %edi
  8025f1:	56                   	push   %esi
  8025f2:	53                   	push   %ebx
  8025f3:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8025f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025fb:	b8 0f 00 00 00       	mov    $0xf,%eax
  802600:	8b 55 08             	mov    0x8(%ebp),%edx
  802603:	89 cb                	mov    %ecx,%ebx
  802605:	89 cf                	mov    %ecx,%edi
  802607:	89 ce                	mov    %ecx,%esi
  802609:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80260b:	85 c0                	test   %eax,%eax
  80260d:	7e 17                	jle    802626 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80260f:	83 ec 0c             	sub    $0xc,%esp
  802612:	50                   	push   %eax
  802613:	6a 0f                	push   $0xf
  802615:	68 5f 45 80 00       	push   $0x80455f
  80261a:	6a 22                	push   $0x22
  80261c:	68 7c 45 80 00       	push   $0x80457c
  802621:	e8 4e f3 ff ff       	call   801974 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  802626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5f                   	pop    %edi
  80262c:	5d                   	pop    %ebp
  80262d:	c3                   	ret    

0080262e <sys_recv>:

int
sys_recv(void *addr)
{
  80262e:	55                   	push   %ebp
  80262f:	89 e5                	mov    %esp,%ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  802637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80263c:	b8 10 00 00 00       	mov    $0x10,%eax
  802641:	8b 55 08             	mov    0x8(%ebp),%edx
  802644:	89 cb                	mov    %ecx,%ebx
  802646:	89 cf                	mov    %ecx,%edi
  802648:	89 ce                	mov    %ecx,%esi
  80264a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80264c:	85 c0                	test   %eax,%eax
  80264e:	7e 17                	jle    802667 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802650:	83 ec 0c             	sub    $0xc,%esp
  802653:	50                   	push   %eax
  802654:	6a 10                	push   $0x10
  802656:	68 5f 45 80 00       	push   $0x80455f
  80265b:	6a 22                	push   $0x22
  80265d:	68 7c 45 80 00       	push   $0x80457c
  802662:	e8 0d f3 ff ff       	call   801974 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  802667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80266a:	5b                   	pop    %ebx
  80266b:	5e                   	pop    %esi
  80266c:	5f                   	pop    %edi
  80266d:	5d                   	pop    %ebp
  80266e:	c3                   	ret    

0080266f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802675:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  80267c:	75 2c                	jne    8026aa <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  80267e:	83 ec 04             	sub    $0x4,%esp
  802681:	6a 07                	push   $0x7
  802683:	68 00 f0 bf ee       	push   $0xeebff000
  802688:	6a 00                	push   $0x0
  80268a:	e8 4e fd ff ff       	call   8023dd <sys_page_alloc>
  80268f:	83 c4 10             	add    $0x10,%esp
  802692:	85 c0                	test   %eax,%eax
  802694:	74 14                	je     8026aa <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  802696:	83 ec 04             	sub    $0x4,%esp
  802699:	68 8c 45 80 00       	push   $0x80458c
  80269e:	6a 21                	push   $0x21
  8026a0:	68 ee 45 80 00       	push   $0x8045ee
  8026a5:	e8 ca f2 ff ff       	call   801974 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ad:	a3 14 a0 80 00       	mov    %eax,0x80a014
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8026b2:	83 ec 08             	sub    $0x8,%esp
  8026b5:	68 de 26 80 00       	push   $0x8026de
  8026ba:	6a 00                	push   $0x0
  8026bc:	e8 67 fe ff ff       	call   802528 <sys_env_set_pgfault_upcall>
  8026c1:	83 c4 10             	add    $0x10,%esp
  8026c4:	85 c0                	test   %eax,%eax
  8026c6:	79 14                	jns    8026dc <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8026c8:	83 ec 04             	sub    $0x4,%esp
  8026cb:	68 b8 45 80 00       	push   $0x8045b8
  8026d0:	6a 29                	push   $0x29
  8026d2:	68 ee 45 80 00       	push   $0x8045ee
  8026d7:	e8 98 f2 ff ff       	call   801974 <_panic>
}
  8026dc:	c9                   	leave  
  8026dd:	c3                   	ret    

008026de <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026de:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026df:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  8026e4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026e6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  8026e9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  8026ee:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  8026f2:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  8026f6:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  8026f8:	83 c4 08             	add    $0x8,%esp
        popal
  8026fb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8026fc:	83 c4 04             	add    $0x4,%esp
        popfl
  8026ff:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802700:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802701:	c3                   	ret    

00802702 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802702:	55                   	push   %ebp
  802703:	89 e5                	mov    %esp,%ebp
  802705:	56                   	push   %esi
  802706:	53                   	push   %ebx
  802707:	8b 75 08             	mov    0x8(%ebp),%esi
  80270a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80270d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802710:	85 c0                	test   %eax,%eax
  802712:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802717:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80271a:	83 ec 0c             	sub    $0xc,%esp
  80271d:	50                   	push   %eax
  80271e:	e8 6a fe ff ff       	call   80258d <sys_ipc_recv>
  802723:	83 c4 10             	add    $0x10,%esp
  802726:	85 c0                	test   %eax,%eax
  802728:	79 16                	jns    802740 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80272a:	85 f6                	test   %esi,%esi
  80272c:	74 06                	je     802734 <ipc_recv+0x32>
  80272e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802734:	85 db                	test   %ebx,%ebx
  802736:	74 2c                	je     802764 <ipc_recv+0x62>
  802738:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80273e:	eb 24                	jmp    802764 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802740:	85 f6                	test   %esi,%esi
  802742:	74 0a                	je     80274e <ipc_recv+0x4c>
  802744:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802749:	8b 40 74             	mov    0x74(%eax),%eax
  80274c:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80274e:	85 db                	test   %ebx,%ebx
  802750:	74 0a                	je     80275c <ipc_recv+0x5a>
  802752:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802757:	8b 40 78             	mov    0x78(%eax),%eax
  80275a:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80275c:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802761:	8b 40 70             	mov    0x70(%eax),%eax
}
  802764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    

0080276b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80276b:	55                   	push   %ebp
  80276c:	89 e5                	mov    %esp,%ebp
  80276e:	57                   	push   %edi
  80276f:	56                   	push   %esi
  802770:	53                   	push   %ebx
  802771:	83 ec 0c             	sub    $0xc,%esp
  802774:	8b 7d 08             	mov    0x8(%ebp),%edi
  802777:	8b 75 0c             	mov    0xc(%ebp),%esi
  80277a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80277d:	85 db                	test   %ebx,%ebx
  80277f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802784:	0f 44 d8             	cmove  %eax,%ebx
  802787:	eb 1c                	jmp    8027a5 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802789:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80278c:	74 12                	je     8027a0 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80278e:	50                   	push   %eax
  80278f:	68 fc 45 80 00       	push   $0x8045fc
  802794:	6a 39                	push   $0x39
  802796:	68 17 46 80 00       	push   $0x804617
  80279b:	e8 d4 f1 ff ff       	call   801974 <_panic>
                 sys_yield();
  8027a0:	e8 19 fc ff ff       	call   8023be <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8027a5:	ff 75 14             	pushl  0x14(%ebp)
  8027a8:	53                   	push   %ebx
  8027a9:	56                   	push   %esi
  8027aa:	57                   	push   %edi
  8027ab:	e8 ba fd ff ff       	call   80256a <sys_ipc_try_send>
  8027b0:	83 c4 10             	add    $0x10,%esp
  8027b3:	85 c0                	test   %eax,%eax
  8027b5:	78 d2                	js     802789 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8027b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027ba:	5b                   	pop    %ebx
  8027bb:	5e                   	pop    %esi
  8027bc:	5f                   	pop    %edi
  8027bd:	5d                   	pop    %ebp
  8027be:	c3                   	ret    

008027bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027bf:	55                   	push   %ebp
  8027c0:	89 e5                	mov    %esp,%ebp
  8027c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027ca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d3:	8b 52 50             	mov    0x50(%edx),%edx
  8027d6:	39 ca                	cmp    %ecx,%edx
  8027d8:	75 0d                	jne    8027e7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8027da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027dd:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8027e2:	8b 40 08             	mov    0x8(%eax),%eax
  8027e5:	eb 0e                	jmp    8027f5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027e7:	83 c0 01             	add    $0x1,%eax
  8027ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027ef:	75 d9                	jne    8027ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027f1:	66 b8 00 00          	mov    $0x0,%ax
}
  8027f5:	5d                   	pop    %ebp
  8027f6:	c3                   	ret    

008027f7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8027f7:	55                   	push   %ebp
  8027f8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fd:	05 00 00 00 30       	add    $0x30000000,%eax
  802802:	c1 e8 0c             	shr    $0xc,%eax
}
  802805:	5d                   	pop    %ebp
  802806:	c3                   	ret    

00802807 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802807:	55                   	push   %ebp
  802808:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80280a:	8b 45 08             	mov    0x8(%ebp),%eax
  80280d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  802812:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802817:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80281c:	5d                   	pop    %ebp
  80281d:	c3                   	ret    

0080281e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80281e:	55                   	push   %ebp
  80281f:	89 e5                	mov    %esp,%ebp
  802821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802824:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802829:	89 c2                	mov    %eax,%edx
  80282b:	c1 ea 16             	shr    $0x16,%edx
  80282e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802835:	f6 c2 01             	test   $0x1,%dl
  802838:	74 11                	je     80284b <fd_alloc+0x2d>
  80283a:	89 c2                	mov    %eax,%edx
  80283c:	c1 ea 0c             	shr    $0xc,%edx
  80283f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802846:	f6 c2 01             	test   $0x1,%dl
  802849:	75 09                	jne    802854 <fd_alloc+0x36>
			*fd_store = fd;
  80284b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80284d:	b8 00 00 00 00       	mov    $0x0,%eax
  802852:	eb 17                	jmp    80286b <fd_alloc+0x4d>
  802854:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802859:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80285e:	75 c9                	jne    802829 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802860:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802866:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80286b:	5d                   	pop    %ebp
  80286c:	c3                   	ret    

0080286d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80286d:	55                   	push   %ebp
  80286e:	89 e5                	mov    %esp,%ebp
  802870:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802873:	83 f8 1f             	cmp    $0x1f,%eax
  802876:	77 36                	ja     8028ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802878:	c1 e0 0c             	shl    $0xc,%eax
  80287b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802880:	89 c2                	mov    %eax,%edx
  802882:	c1 ea 16             	shr    $0x16,%edx
  802885:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80288c:	f6 c2 01             	test   $0x1,%dl
  80288f:	74 24                	je     8028b5 <fd_lookup+0x48>
  802891:	89 c2                	mov    %eax,%edx
  802893:	c1 ea 0c             	shr    $0xc,%edx
  802896:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80289d:	f6 c2 01             	test   $0x1,%dl
  8028a0:	74 1a                	je     8028bc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8028a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028a5:	89 02                	mov    %eax,(%edx)
	return 0;
  8028a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ac:	eb 13                	jmp    8028c1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028b3:	eb 0c                	jmp    8028c1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028ba:	eb 05                	jmp    8028c1 <fd_lookup+0x54>
  8028bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8028c1:	5d                   	pop    %ebp
  8028c2:	c3                   	ret    

008028c3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8028c3:	55                   	push   %ebp
  8028c4:	89 e5                	mov    %esp,%ebp
  8028c6:	83 ec 08             	sub    $0x8,%esp
  8028c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8028cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8028d1:	eb 13                	jmp    8028e6 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8028d3:	39 08                	cmp    %ecx,(%eax)
  8028d5:	75 0c                	jne    8028e3 <dev_lookup+0x20>
			*dev = devtab[i];
  8028d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8028dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8028e1:	eb 36                	jmp    802919 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8028e3:	83 c2 01             	add    $0x1,%edx
  8028e6:	8b 04 95 a4 46 80 00 	mov    0x8046a4(,%edx,4),%eax
  8028ed:	85 c0                	test   %eax,%eax
  8028ef:	75 e2                	jne    8028d3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8028f1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8028f6:	8b 40 48             	mov    0x48(%eax),%eax
  8028f9:	83 ec 04             	sub    $0x4,%esp
  8028fc:	51                   	push   %ecx
  8028fd:	50                   	push   %eax
  8028fe:	68 24 46 80 00       	push   $0x804624
  802903:	e8 45 f1 ff ff       	call   801a4d <cprintf>
	*dev = 0;
  802908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80290b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802911:	83 c4 10             	add    $0x10,%esp
  802914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802919:	c9                   	leave  
  80291a:	c3                   	ret    

0080291b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80291b:	55                   	push   %ebp
  80291c:	89 e5                	mov    %esp,%ebp
  80291e:	56                   	push   %esi
  80291f:	53                   	push   %ebx
  802920:	83 ec 10             	sub    $0x10,%esp
  802923:	8b 75 08             	mov    0x8(%ebp),%esi
  802926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80292c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80292d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802933:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802936:	50                   	push   %eax
  802937:	e8 31 ff ff ff       	call   80286d <fd_lookup>
  80293c:	83 c4 08             	add    $0x8,%esp
  80293f:	85 c0                	test   %eax,%eax
  802941:	78 05                	js     802948 <fd_close+0x2d>
	    || fd != fd2)
  802943:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802946:	74 0c                	je     802954 <fd_close+0x39>
		return (must_exist ? r : 0);
  802948:	84 db                	test   %bl,%bl
  80294a:	ba 00 00 00 00       	mov    $0x0,%edx
  80294f:	0f 44 c2             	cmove  %edx,%eax
  802952:	eb 41                	jmp    802995 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802954:	83 ec 08             	sub    $0x8,%esp
  802957:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80295a:	50                   	push   %eax
  80295b:	ff 36                	pushl  (%esi)
  80295d:	e8 61 ff ff ff       	call   8028c3 <dev_lookup>
  802962:	89 c3                	mov    %eax,%ebx
  802964:	83 c4 10             	add    $0x10,%esp
  802967:	85 c0                	test   %eax,%eax
  802969:	78 1a                	js     802985 <fd_close+0x6a>
		if (dev->dev_close)
  80296b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80296e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802971:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802976:	85 c0                	test   %eax,%eax
  802978:	74 0b                	je     802985 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80297a:	83 ec 0c             	sub    $0xc,%esp
  80297d:	56                   	push   %esi
  80297e:	ff d0                	call   *%eax
  802980:	89 c3                	mov    %eax,%ebx
  802982:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802985:	83 ec 08             	sub    $0x8,%esp
  802988:	56                   	push   %esi
  802989:	6a 00                	push   $0x0
  80298b:	e8 d2 fa ff ff       	call   802462 <sys_page_unmap>
	return r;
  802990:	83 c4 10             	add    $0x10,%esp
  802993:	89 d8                	mov    %ebx,%eax
}
  802995:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802998:	5b                   	pop    %ebx
  802999:	5e                   	pop    %esi
  80299a:	5d                   	pop    %ebp
  80299b:	c3                   	ret    

0080299c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80299c:	55                   	push   %ebp
  80299d:	89 e5                	mov    %esp,%ebp
  80299f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029a5:	50                   	push   %eax
  8029a6:	ff 75 08             	pushl  0x8(%ebp)
  8029a9:	e8 bf fe ff ff       	call   80286d <fd_lookup>
  8029ae:	89 c2                	mov    %eax,%edx
  8029b0:	83 c4 08             	add    $0x8,%esp
  8029b3:	85 d2                	test   %edx,%edx
  8029b5:	78 10                	js     8029c7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8029b7:	83 ec 08             	sub    $0x8,%esp
  8029ba:	6a 01                	push   $0x1
  8029bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8029bf:	e8 57 ff ff ff       	call   80291b <fd_close>
  8029c4:	83 c4 10             	add    $0x10,%esp
}
  8029c7:	c9                   	leave  
  8029c8:	c3                   	ret    

008029c9 <close_all>:

void
close_all(void)
{
  8029c9:	55                   	push   %ebp
  8029ca:	89 e5                	mov    %esp,%ebp
  8029cc:	53                   	push   %ebx
  8029cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8029d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8029d5:	83 ec 0c             	sub    $0xc,%esp
  8029d8:	53                   	push   %ebx
  8029d9:	e8 be ff ff ff       	call   80299c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8029de:	83 c3 01             	add    $0x1,%ebx
  8029e1:	83 c4 10             	add    $0x10,%esp
  8029e4:	83 fb 20             	cmp    $0x20,%ebx
  8029e7:	75 ec                	jne    8029d5 <close_all+0xc>
		close(i);
}
  8029e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8029ec:	c9                   	leave  
  8029ed:	c3                   	ret    

008029ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8029ee:	55                   	push   %ebp
  8029ef:	89 e5                	mov    %esp,%ebp
  8029f1:	57                   	push   %edi
  8029f2:	56                   	push   %esi
  8029f3:	53                   	push   %ebx
  8029f4:	83 ec 2c             	sub    $0x2c,%esp
  8029f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8029fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8029fd:	50                   	push   %eax
  8029fe:	ff 75 08             	pushl  0x8(%ebp)
  802a01:	e8 67 fe ff ff       	call   80286d <fd_lookup>
  802a06:	89 c2                	mov    %eax,%edx
  802a08:	83 c4 08             	add    $0x8,%esp
  802a0b:	85 d2                	test   %edx,%edx
  802a0d:	0f 88 c1 00 00 00    	js     802ad4 <dup+0xe6>
		return r;
	close(newfdnum);
  802a13:	83 ec 0c             	sub    $0xc,%esp
  802a16:	56                   	push   %esi
  802a17:	e8 80 ff ff ff       	call   80299c <close>

	newfd = INDEX2FD(newfdnum);
  802a1c:	89 f3                	mov    %esi,%ebx
  802a1e:	c1 e3 0c             	shl    $0xc,%ebx
  802a21:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802a27:	83 c4 04             	add    $0x4,%esp
  802a2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a2d:	e8 d5 fd ff ff       	call   802807 <fd2data>
  802a32:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802a34:	89 1c 24             	mov    %ebx,(%esp)
  802a37:	e8 cb fd ff ff       	call   802807 <fd2data>
  802a3c:	83 c4 10             	add    $0x10,%esp
  802a3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802a42:	89 f8                	mov    %edi,%eax
  802a44:	c1 e8 16             	shr    $0x16,%eax
  802a47:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a4e:	a8 01                	test   $0x1,%al
  802a50:	74 37                	je     802a89 <dup+0x9b>
  802a52:	89 f8                	mov    %edi,%eax
  802a54:	c1 e8 0c             	shr    $0xc,%eax
  802a57:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a5e:	f6 c2 01             	test   $0x1,%dl
  802a61:	74 26                	je     802a89 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802a63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a6a:	83 ec 0c             	sub    $0xc,%esp
  802a6d:	25 07 0e 00 00       	and    $0xe07,%eax
  802a72:	50                   	push   %eax
  802a73:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a76:	6a 00                	push   $0x0
  802a78:	57                   	push   %edi
  802a79:	6a 00                	push   $0x0
  802a7b:	e8 a0 f9 ff ff       	call   802420 <sys_page_map>
  802a80:	89 c7                	mov    %eax,%edi
  802a82:	83 c4 20             	add    $0x20,%esp
  802a85:	85 c0                	test   %eax,%eax
  802a87:	78 2e                	js     802ab7 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a8c:	89 d0                	mov    %edx,%eax
  802a8e:	c1 e8 0c             	shr    $0xc,%eax
  802a91:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a98:	83 ec 0c             	sub    $0xc,%esp
  802a9b:	25 07 0e 00 00       	and    $0xe07,%eax
  802aa0:	50                   	push   %eax
  802aa1:	53                   	push   %ebx
  802aa2:	6a 00                	push   $0x0
  802aa4:	52                   	push   %edx
  802aa5:	6a 00                	push   $0x0
  802aa7:	e8 74 f9 ff ff       	call   802420 <sys_page_map>
  802aac:	89 c7                	mov    %eax,%edi
  802aae:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802ab1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ab3:	85 ff                	test   %edi,%edi
  802ab5:	79 1d                	jns    802ad4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802ab7:	83 ec 08             	sub    $0x8,%esp
  802aba:	53                   	push   %ebx
  802abb:	6a 00                	push   $0x0
  802abd:	e8 a0 f9 ff ff       	call   802462 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802ac2:	83 c4 08             	add    $0x8,%esp
  802ac5:	ff 75 d4             	pushl  -0x2c(%ebp)
  802ac8:	6a 00                	push   $0x0
  802aca:	e8 93 f9 ff ff       	call   802462 <sys_page_unmap>
	return r;
  802acf:	83 c4 10             	add    $0x10,%esp
  802ad2:	89 f8                	mov    %edi,%eax
}
  802ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ad7:	5b                   	pop    %ebx
  802ad8:	5e                   	pop    %esi
  802ad9:	5f                   	pop    %edi
  802ada:	5d                   	pop    %ebp
  802adb:	c3                   	ret    

00802adc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802adc:	55                   	push   %ebp
  802add:	89 e5                	mov    %esp,%ebp
  802adf:	53                   	push   %ebx
  802ae0:	83 ec 14             	sub    $0x14,%esp
  802ae3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ae6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ae9:	50                   	push   %eax
  802aea:	53                   	push   %ebx
  802aeb:	e8 7d fd ff ff       	call   80286d <fd_lookup>
  802af0:	83 c4 08             	add    $0x8,%esp
  802af3:	89 c2                	mov    %eax,%edx
  802af5:	85 c0                	test   %eax,%eax
  802af7:	78 6d                	js     802b66 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802af9:	83 ec 08             	sub    $0x8,%esp
  802afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aff:	50                   	push   %eax
  802b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b03:	ff 30                	pushl  (%eax)
  802b05:	e8 b9 fd ff ff       	call   8028c3 <dev_lookup>
  802b0a:	83 c4 10             	add    $0x10,%esp
  802b0d:	85 c0                	test   %eax,%eax
  802b0f:	78 4c                	js     802b5d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b11:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b14:	8b 42 08             	mov    0x8(%edx),%eax
  802b17:	83 e0 03             	and    $0x3,%eax
  802b1a:	83 f8 01             	cmp    $0x1,%eax
  802b1d:	75 21                	jne    802b40 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b1f:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802b24:	8b 40 48             	mov    0x48(%eax),%eax
  802b27:	83 ec 04             	sub    $0x4,%esp
  802b2a:	53                   	push   %ebx
  802b2b:	50                   	push   %eax
  802b2c:	68 68 46 80 00       	push   $0x804668
  802b31:	e8 17 ef ff ff       	call   801a4d <cprintf>
		return -E_INVAL;
  802b36:	83 c4 10             	add    $0x10,%esp
  802b39:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b3e:	eb 26                	jmp    802b66 <read+0x8a>
	}
	if (!dev->dev_read)
  802b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b43:	8b 40 08             	mov    0x8(%eax),%eax
  802b46:	85 c0                	test   %eax,%eax
  802b48:	74 17                	je     802b61 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802b4a:	83 ec 04             	sub    $0x4,%esp
  802b4d:	ff 75 10             	pushl  0x10(%ebp)
  802b50:	ff 75 0c             	pushl  0xc(%ebp)
  802b53:	52                   	push   %edx
  802b54:	ff d0                	call   *%eax
  802b56:	89 c2                	mov    %eax,%edx
  802b58:	83 c4 10             	add    $0x10,%esp
  802b5b:	eb 09                	jmp    802b66 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b5d:	89 c2                	mov    %eax,%edx
  802b5f:	eb 05                	jmp    802b66 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802b61:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802b66:	89 d0                	mov    %edx,%eax
  802b68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b6b:	c9                   	leave  
  802b6c:	c3                   	ret    

00802b6d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b6d:	55                   	push   %ebp
  802b6e:	89 e5                	mov    %esp,%ebp
  802b70:	57                   	push   %edi
  802b71:	56                   	push   %esi
  802b72:	53                   	push   %ebx
  802b73:	83 ec 0c             	sub    $0xc,%esp
  802b76:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b79:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b81:	eb 21                	jmp    802ba4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b83:	83 ec 04             	sub    $0x4,%esp
  802b86:	89 f0                	mov    %esi,%eax
  802b88:	29 d8                	sub    %ebx,%eax
  802b8a:	50                   	push   %eax
  802b8b:	89 d8                	mov    %ebx,%eax
  802b8d:	03 45 0c             	add    0xc(%ebp),%eax
  802b90:	50                   	push   %eax
  802b91:	57                   	push   %edi
  802b92:	e8 45 ff ff ff       	call   802adc <read>
		if (m < 0)
  802b97:	83 c4 10             	add    $0x10,%esp
  802b9a:	85 c0                	test   %eax,%eax
  802b9c:	78 0c                	js     802baa <readn+0x3d>
			return m;
		if (m == 0)
  802b9e:	85 c0                	test   %eax,%eax
  802ba0:	74 06                	je     802ba8 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802ba2:	01 c3                	add    %eax,%ebx
  802ba4:	39 f3                	cmp    %esi,%ebx
  802ba6:	72 db                	jb     802b83 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802ba8:	89 d8                	mov    %ebx,%eax
}
  802baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bad:	5b                   	pop    %ebx
  802bae:	5e                   	pop    %esi
  802baf:	5f                   	pop    %edi
  802bb0:	5d                   	pop    %ebp
  802bb1:	c3                   	ret    

00802bb2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802bb2:	55                   	push   %ebp
  802bb3:	89 e5                	mov    %esp,%ebp
  802bb5:	53                   	push   %ebx
  802bb6:	83 ec 14             	sub    $0x14,%esp
  802bb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bbf:	50                   	push   %eax
  802bc0:	53                   	push   %ebx
  802bc1:	e8 a7 fc ff ff       	call   80286d <fd_lookup>
  802bc6:	83 c4 08             	add    $0x8,%esp
  802bc9:	89 c2                	mov    %eax,%edx
  802bcb:	85 c0                	test   %eax,%eax
  802bcd:	78 68                	js     802c37 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bcf:	83 ec 08             	sub    $0x8,%esp
  802bd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bd5:	50                   	push   %eax
  802bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd9:	ff 30                	pushl  (%eax)
  802bdb:	e8 e3 fc ff ff       	call   8028c3 <dev_lookup>
  802be0:	83 c4 10             	add    $0x10,%esp
  802be3:	85 c0                	test   %eax,%eax
  802be5:	78 47                	js     802c2e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802bee:	75 21                	jne    802c11 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802bf0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bf5:	8b 40 48             	mov    0x48(%eax),%eax
  802bf8:	83 ec 04             	sub    $0x4,%esp
  802bfb:	53                   	push   %ebx
  802bfc:	50                   	push   %eax
  802bfd:	68 84 46 80 00       	push   $0x804684
  802c02:	e8 46 ee ff ff       	call   801a4d <cprintf>
		return -E_INVAL;
  802c07:	83 c4 10             	add    $0x10,%esp
  802c0a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c0f:	eb 26                	jmp    802c37 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c14:	8b 52 0c             	mov    0xc(%edx),%edx
  802c17:	85 d2                	test   %edx,%edx
  802c19:	74 17                	je     802c32 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802c1b:	83 ec 04             	sub    $0x4,%esp
  802c1e:	ff 75 10             	pushl  0x10(%ebp)
  802c21:	ff 75 0c             	pushl  0xc(%ebp)
  802c24:	50                   	push   %eax
  802c25:	ff d2                	call   *%edx
  802c27:	89 c2                	mov    %eax,%edx
  802c29:	83 c4 10             	add    $0x10,%esp
  802c2c:	eb 09                	jmp    802c37 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c2e:	89 c2                	mov    %eax,%edx
  802c30:	eb 05                	jmp    802c37 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802c32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802c37:	89 d0                	mov    %edx,%eax
  802c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c3c:	c9                   	leave  
  802c3d:	c3                   	ret    

00802c3e <seek>:

int
seek(int fdnum, off_t offset)
{
  802c3e:	55                   	push   %ebp
  802c3f:	89 e5                	mov    %esp,%ebp
  802c41:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c44:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802c47:	50                   	push   %eax
  802c48:	ff 75 08             	pushl  0x8(%ebp)
  802c4b:	e8 1d fc ff ff       	call   80286d <fd_lookup>
  802c50:	83 c4 08             	add    $0x8,%esp
  802c53:	85 c0                	test   %eax,%eax
  802c55:	78 0e                	js     802c65 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802c57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c5d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c65:	c9                   	leave  
  802c66:	c3                   	ret    

00802c67 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c67:	55                   	push   %ebp
  802c68:	89 e5                	mov    %esp,%ebp
  802c6a:	53                   	push   %ebx
  802c6b:	83 ec 14             	sub    $0x14,%esp
  802c6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c74:	50                   	push   %eax
  802c75:	53                   	push   %ebx
  802c76:	e8 f2 fb ff ff       	call   80286d <fd_lookup>
  802c7b:	83 c4 08             	add    $0x8,%esp
  802c7e:	89 c2                	mov    %eax,%edx
  802c80:	85 c0                	test   %eax,%eax
  802c82:	78 65                	js     802ce9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c84:	83 ec 08             	sub    $0x8,%esp
  802c87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c8a:	50                   	push   %eax
  802c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c8e:	ff 30                	pushl  (%eax)
  802c90:	e8 2e fc ff ff       	call   8028c3 <dev_lookup>
  802c95:	83 c4 10             	add    $0x10,%esp
  802c98:	85 c0                	test   %eax,%eax
  802c9a:	78 44                	js     802ce0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c9f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ca3:	75 21                	jne    802cc6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802ca5:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802caa:	8b 40 48             	mov    0x48(%eax),%eax
  802cad:	83 ec 04             	sub    $0x4,%esp
  802cb0:	53                   	push   %ebx
  802cb1:	50                   	push   %eax
  802cb2:	68 44 46 80 00       	push   $0x804644
  802cb7:	e8 91 ed ff ff       	call   801a4d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802cbc:	83 c4 10             	add    $0x10,%esp
  802cbf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802cc4:	eb 23                	jmp    802ce9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cc9:	8b 52 18             	mov    0x18(%edx),%edx
  802ccc:	85 d2                	test   %edx,%edx
  802cce:	74 14                	je     802ce4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802cd0:	83 ec 08             	sub    $0x8,%esp
  802cd3:	ff 75 0c             	pushl  0xc(%ebp)
  802cd6:	50                   	push   %eax
  802cd7:	ff d2                	call   *%edx
  802cd9:	89 c2                	mov    %eax,%edx
  802cdb:	83 c4 10             	add    $0x10,%esp
  802cde:	eb 09                	jmp    802ce9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ce0:	89 c2                	mov    %eax,%edx
  802ce2:	eb 05                	jmp    802ce9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802ce4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802ce9:	89 d0                	mov    %edx,%eax
  802ceb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cee:	c9                   	leave  
  802cef:	c3                   	ret    

00802cf0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802cf0:	55                   	push   %ebp
  802cf1:	89 e5                	mov    %esp,%ebp
  802cf3:	53                   	push   %ebx
  802cf4:	83 ec 14             	sub    $0x14,%esp
  802cf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cfa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cfd:	50                   	push   %eax
  802cfe:	ff 75 08             	pushl  0x8(%ebp)
  802d01:	e8 67 fb ff ff       	call   80286d <fd_lookup>
  802d06:	83 c4 08             	add    $0x8,%esp
  802d09:	89 c2                	mov    %eax,%edx
  802d0b:	85 c0                	test   %eax,%eax
  802d0d:	78 58                	js     802d67 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d0f:	83 ec 08             	sub    $0x8,%esp
  802d12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d15:	50                   	push   %eax
  802d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d19:	ff 30                	pushl  (%eax)
  802d1b:	e8 a3 fb ff ff       	call   8028c3 <dev_lookup>
  802d20:	83 c4 10             	add    $0x10,%esp
  802d23:	85 c0                	test   %eax,%eax
  802d25:	78 37                	js     802d5e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d2a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802d2e:	74 32                	je     802d62 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802d30:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802d33:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802d3a:	00 00 00 
	stat->st_isdir = 0;
  802d3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d44:	00 00 00 
	stat->st_dev = dev;
  802d47:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802d4d:	83 ec 08             	sub    $0x8,%esp
  802d50:	53                   	push   %ebx
  802d51:	ff 75 f0             	pushl  -0x10(%ebp)
  802d54:	ff 50 14             	call   *0x14(%eax)
  802d57:	89 c2                	mov    %eax,%edx
  802d59:	83 c4 10             	add    $0x10,%esp
  802d5c:	eb 09                	jmp    802d67 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d5e:	89 c2                	mov    %eax,%edx
  802d60:	eb 05                	jmp    802d67 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802d62:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802d67:	89 d0                	mov    %edx,%eax
  802d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d6c:	c9                   	leave  
  802d6d:	c3                   	ret    

00802d6e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d6e:	55                   	push   %ebp
  802d6f:	89 e5                	mov    %esp,%ebp
  802d71:	56                   	push   %esi
  802d72:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d73:	83 ec 08             	sub    $0x8,%esp
  802d76:	6a 00                	push   $0x0
  802d78:	ff 75 08             	pushl  0x8(%ebp)
  802d7b:	e8 09 02 00 00       	call   802f89 <open>
  802d80:	89 c3                	mov    %eax,%ebx
  802d82:	83 c4 10             	add    $0x10,%esp
  802d85:	85 db                	test   %ebx,%ebx
  802d87:	78 1b                	js     802da4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d89:	83 ec 08             	sub    $0x8,%esp
  802d8c:	ff 75 0c             	pushl  0xc(%ebp)
  802d8f:	53                   	push   %ebx
  802d90:	e8 5b ff ff ff       	call   802cf0 <fstat>
  802d95:	89 c6                	mov    %eax,%esi
	close(fd);
  802d97:	89 1c 24             	mov    %ebx,(%esp)
  802d9a:	e8 fd fb ff ff       	call   80299c <close>
	return r;
  802d9f:	83 c4 10             	add    $0x10,%esp
  802da2:	89 f0                	mov    %esi,%eax
}
  802da4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802da7:	5b                   	pop    %ebx
  802da8:	5e                   	pop    %esi
  802da9:	5d                   	pop    %ebp
  802daa:	c3                   	ret    

00802dab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802dab:	55                   	push   %ebp
  802dac:	89 e5                	mov    %esp,%ebp
  802dae:	56                   	push   %esi
  802daf:	53                   	push   %ebx
  802db0:	89 c6                	mov    %eax,%esi
  802db2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802db4:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802dbb:	75 12                	jne    802dcf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802dbd:	83 ec 0c             	sub    $0xc,%esp
  802dc0:	6a 01                	push   $0x1
  802dc2:	e8 f8 f9 ff ff       	call   8027bf <ipc_find_env>
  802dc7:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802dcc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802dcf:	6a 07                	push   $0x7
  802dd1:	68 00 b0 80 00       	push   $0x80b000
  802dd6:	56                   	push   %esi
  802dd7:	ff 35 00 a0 80 00    	pushl  0x80a000
  802ddd:	e8 89 f9 ff ff       	call   80276b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802de2:	83 c4 0c             	add    $0xc,%esp
  802de5:	6a 00                	push   $0x0
  802de7:	53                   	push   %ebx
  802de8:	6a 00                	push   $0x0
  802dea:	e8 13 f9 ff ff       	call   802702 <ipc_recv>
}
  802def:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802df2:	5b                   	pop    %ebx
  802df3:	5e                   	pop    %esi
  802df4:	5d                   	pop    %ebp
  802df5:	c3                   	ret    

00802df6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802df6:	55                   	push   %ebp
  802df7:	89 e5                	mov    %esp,%ebp
  802df9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  802dff:	8b 40 0c             	mov    0xc(%eax),%eax
  802e02:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e0a:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  802e14:	b8 02 00 00 00       	mov    $0x2,%eax
  802e19:	e8 8d ff ff ff       	call   802dab <fsipc>
}
  802e1e:	c9                   	leave  
  802e1f:	c3                   	ret    

00802e20 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802e20:	55                   	push   %ebp
  802e21:	89 e5                	mov    %esp,%ebp
  802e23:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802e26:	8b 45 08             	mov    0x8(%ebp),%eax
  802e29:	8b 40 0c             	mov    0xc(%eax),%eax
  802e2c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802e31:	ba 00 00 00 00       	mov    $0x0,%edx
  802e36:	b8 06 00 00 00       	mov    $0x6,%eax
  802e3b:	e8 6b ff ff ff       	call   802dab <fsipc>
}
  802e40:	c9                   	leave  
  802e41:	c3                   	ret    

00802e42 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802e42:	55                   	push   %ebp
  802e43:	89 e5                	mov    %esp,%ebp
  802e45:	53                   	push   %ebx
  802e46:	83 ec 04             	sub    $0x4,%esp
  802e49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e4f:	8b 40 0c             	mov    0xc(%eax),%eax
  802e52:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802e57:	ba 00 00 00 00       	mov    $0x0,%edx
  802e5c:	b8 05 00 00 00       	mov    $0x5,%eax
  802e61:	e8 45 ff ff ff       	call   802dab <fsipc>
  802e66:	89 c2                	mov    %eax,%edx
  802e68:	85 d2                	test   %edx,%edx
  802e6a:	78 2c                	js     802e98 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e6c:	83 ec 08             	sub    $0x8,%esp
  802e6f:	68 00 b0 80 00       	push   $0x80b000
  802e74:	53                   	push   %ebx
  802e75:	e8 5a f1 ff ff       	call   801fd4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e7a:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e85:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e90:	83 c4 10             	add    $0x10,%esp
  802e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e9b:	c9                   	leave  
  802e9c:	c3                   	ret    

00802e9d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e9d:	55                   	push   %ebp
  802e9e:	89 e5                	mov    %esp,%ebp
  802ea0:	57                   	push   %edi
  802ea1:	56                   	push   %esi
  802ea2:	53                   	push   %ebx
  802ea3:	83 ec 0c             	sub    $0xc,%esp
  802ea6:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  802ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  802eac:	8b 40 0c             	mov    0xc(%eax),%eax
  802eaf:	a3 00 b0 80 00       	mov    %eax,0x80b000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  802eb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802eb7:	eb 3d                	jmp    802ef6 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  802eb9:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  802ebf:	bf f8 0f 00 00       	mov    $0xff8,%edi
  802ec4:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  802ec7:	83 ec 04             	sub    $0x4,%esp
  802eca:	57                   	push   %edi
  802ecb:	53                   	push   %ebx
  802ecc:	68 08 b0 80 00       	push   $0x80b008
  802ed1:	e8 90 f2 ff ff       	call   802166 <memmove>
                fsipcbuf.write.req_n = tmp; 
  802ed6:	89 3d 04 b0 80 00    	mov    %edi,0x80b004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802edc:	ba 00 00 00 00       	mov    $0x0,%edx
  802ee1:	b8 04 00 00 00       	mov    $0x4,%eax
  802ee6:	e8 c0 fe ff ff       	call   802dab <fsipc>
  802eeb:	83 c4 10             	add    $0x10,%esp
  802eee:	85 c0                	test   %eax,%eax
  802ef0:	78 0d                	js     802eff <devfile_write+0x62>
		        return r;
                n -= tmp;
  802ef2:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  802ef4:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802ef6:	85 f6                	test   %esi,%esi
  802ef8:	75 bf                	jne    802eb9 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  802efa:	89 d8                	mov    %ebx,%eax
  802efc:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  802eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f02:	5b                   	pop    %ebx
  802f03:	5e                   	pop    %esi
  802f04:	5f                   	pop    %edi
  802f05:	5d                   	pop    %ebp
  802f06:	c3                   	ret    

00802f07 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f07:	55                   	push   %ebp
  802f08:	89 e5                	mov    %esp,%ebp
  802f0a:	56                   	push   %esi
  802f0b:	53                   	push   %ebx
  802f0c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f12:	8b 40 0c             	mov    0xc(%eax),%eax
  802f15:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802f1a:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802f20:	ba 00 00 00 00       	mov    $0x0,%edx
  802f25:	b8 03 00 00 00       	mov    $0x3,%eax
  802f2a:	e8 7c fe ff ff       	call   802dab <fsipc>
  802f2f:	89 c3                	mov    %eax,%ebx
  802f31:	85 c0                	test   %eax,%eax
  802f33:	78 4b                	js     802f80 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802f35:	39 c6                	cmp    %eax,%esi
  802f37:	73 16                	jae    802f4f <devfile_read+0x48>
  802f39:	68 b8 46 80 00       	push   $0x8046b8
  802f3e:	68 bd 3c 80 00       	push   $0x803cbd
  802f43:	6a 7c                	push   $0x7c
  802f45:	68 bf 46 80 00       	push   $0x8046bf
  802f4a:	e8 25 ea ff ff       	call   801974 <_panic>
	assert(r <= PGSIZE);
  802f4f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802f54:	7e 16                	jle    802f6c <devfile_read+0x65>
  802f56:	68 ca 46 80 00       	push   $0x8046ca
  802f5b:	68 bd 3c 80 00       	push   $0x803cbd
  802f60:	6a 7d                	push   $0x7d
  802f62:	68 bf 46 80 00       	push   $0x8046bf
  802f67:	e8 08 ea ff ff       	call   801974 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802f6c:	83 ec 04             	sub    $0x4,%esp
  802f6f:	50                   	push   %eax
  802f70:	68 00 b0 80 00       	push   $0x80b000
  802f75:	ff 75 0c             	pushl  0xc(%ebp)
  802f78:	e8 e9 f1 ff ff       	call   802166 <memmove>
	return r;
  802f7d:	83 c4 10             	add    $0x10,%esp
}
  802f80:	89 d8                	mov    %ebx,%eax
  802f82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f85:	5b                   	pop    %ebx
  802f86:	5e                   	pop    %esi
  802f87:	5d                   	pop    %ebp
  802f88:	c3                   	ret    

00802f89 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f89:	55                   	push   %ebp
  802f8a:	89 e5                	mov    %esp,%ebp
  802f8c:	53                   	push   %ebx
  802f8d:	83 ec 20             	sub    $0x20,%esp
  802f90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f93:	53                   	push   %ebx
  802f94:	e8 02 f0 ff ff       	call   801f9b <strlen>
  802f99:	83 c4 10             	add    $0x10,%esp
  802f9c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802fa1:	7f 67                	jg     80300a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802fa3:	83 ec 0c             	sub    $0xc,%esp
  802fa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fa9:	50                   	push   %eax
  802faa:	e8 6f f8 ff ff       	call   80281e <fd_alloc>
  802faf:	83 c4 10             	add    $0x10,%esp
		return r;
  802fb2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802fb4:	85 c0                	test   %eax,%eax
  802fb6:	78 57                	js     80300f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802fb8:	83 ec 08             	sub    $0x8,%esp
  802fbb:	53                   	push   %ebx
  802fbc:	68 00 b0 80 00       	push   $0x80b000
  802fc1:	e8 0e f0 ff ff       	call   801fd4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fc9:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  802fd6:	e8 d0 fd ff ff       	call   802dab <fsipc>
  802fdb:	89 c3                	mov    %eax,%ebx
  802fdd:	83 c4 10             	add    $0x10,%esp
  802fe0:	85 c0                	test   %eax,%eax
  802fe2:	79 14                	jns    802ff8 <open+0x6f>
		fd_close(fd, 0);
  802fe4:	83 ec 08             	sub    $0x8,%esp
  802fe7:	6a 00                	push   $0x0
  802fe9:	ff 75 f4             	pushl  -0xc(%ebp)
  802fec:	e8 2a f9 ff ff       	call   80291b <fd_close>
		return r;
  802ff1:	83 c4 10             	add    $0x10,%esp
  802ff4:	89 da                	mov    %ebx,%edx
  802ff6:	eb 17                	jmp    80300f <open+0x86>
	}

	return fd2num(fd);
  802ff8:	83 ec 0c             	sub    $0xc,%esp
  802ffb:	ff 75 f4             	pushl  -0xc(%ebp)
  802ffe:	e8 f4 f7 ff ff       	call   8027f7 <fd2num>
  803003:	89 c2                	mov    %eax,%edx
  803005:	83 c4 10             	add    $0x10,%esp
  803008:	eb 05                	jmp    80300f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80300a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80300f:	89 d0                	mov    %edx,%eax
  803011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803014:	c9                   	leave  
  803015:	c3                   	ret    

00803016 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803016:	55                   	push   %ebp
  803017:	89 e5                	mov    %esp,%ebp
  803019:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80301c:	ba 00 00 00 00       	mov    $0x0,%edx
  803021:	b8 08 00 00 00       	mov    $0x8,%eax
  803026:	e8 80 fd ff ff       	call   802dab <fsipc>
}
  80302b:	c9                   	leave  
  80302c:	c3                   	ret    

0080302d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80302d:	55                   	push   %ebp
  80302e:	89 e5                	mov    %esp,%ebp
  803030:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803033:	89 d0                	mov    %edx,%eax
  803035:	c1 e8 16             	shr    $0x16,%eax
  803038:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80303f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803044:	f6 c1 01             	test   $0x1,%cl
  803047:	74 1d                	je     803066 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803049:	c1 ea 0c             	shr    $0xc,%edx
  80304c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803053:	f6 c2 01             	test   $0x1,%dl
  803056:	74 0e                	je     803066 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803058:	c1 ea 0c             	shr    $0xc,%edx
  80305b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803062:	ef 
  803063:	0f b7 c0             	movzwl %ax,%eax
}
  803066:	5d                   	pop    %ebp
  803067:	c3                   	ret    

00803068 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803068:	55                   	push   %ebp
  803069:	89 e5                	mov    %esp,%ebp
  80306b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80306e:	68 d6 46 80 00       	push   $0x8046d6
  803073:	ff 75 0c             	pushl  0xc(%ebp)
  803076:	e8 59 ef ff ff       	call   801fd4 <strcpy>
	return 0;
}
  80307b:	b8 00 00 00 00       	mov    $0x0,%eax
  803080:	c9                   	leave  
  803081:	c3                   	ret    

00803082 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803082:	55                   	push   %ebp
  803083:	89 e5                	mov    %esp,%ebp
  803085:	53                   	push   %ebx
  803086:	83 ec 10             	sub    $0x10,%esp
  803089:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80308c:	53                   	push   %ebx
  80308d:	e8 9b ff ff ff       	call   80302d <pageref>
  803092:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803095:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80309a:	83 f8 01             	cmp    $0x1,%eax
  80309d:	75 10                	jne    8030af <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80309f:	83 ec 0c             	sub    $0xc,%esp
  8030a2:	ff 73 0c             	pushl  0xc(%ebx)
  8030a5:	e8 ca 02 00 00       	call   803374 <nsipc_close>
  8030aa:	89 c2                	mov    %eax,%edx
  8030ac:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8030af:	89 d0                	mov    %edx,%eax
  8030b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030b4:	c9                   	leave  
  8030b5:	c3                   	ret    

008030b6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8030b6:	55                   	push   %ebp
  8030b7:	89 e5                	mov    %esp,%ebp
  8030b9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8030bc:	6a 00                	push   $0x0
  8030be:	ff 75 10             	pushl  0x10(%ebp)
  8030c1:	ff 75 0c             	pushl  0xc(%ebp)
  8030c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8030c7:	ff 70 0c             	pushl  0xc(%eax)
  8030ca:	e8 82 03 00 00       	call   803451 <nsipc_send>
}
  8030cf:	c9                   	leave  
  8030d0:	c3                   	ret    

008030d1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8030d1:	55                   	push   %ebp
  8030d2:	89 e5                	mov    %esp,%ebp
  8030d4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8030d7:	6a 00                	push   $0x0
  8030d9:	ff 75 10             	pushl  0x10(%ebp)
  8030dc:	ff 75 0c             	pushl  0xc(%ebp)
  8030df:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e2:	ff 70 0c             	pushl  0xc(%eax)
  8030e5:	e8 fb 02 00 00       	call   8033e5 <nsipc_recv>
}
  8030ea:	c9                   	leave  
  8030eb:	c3                   	ret    

008030ec <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8030ec:	55                   	push   %ebp
  8030ed:	89 e5                	mov    %esp,%ebp
  8030ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8030f2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8030f5:	52                   	push   %edx
  8030f6:	50                   	push   %eax
  8030f7:	e8 71 f7 ff ff       	call   80286d <fd_lookup>
  8030fc:	83 c4 10             	add    $0x10,%esp
  8030ff:	85 c0                	test   %eax,%eax
  803101:	78 17                	js     80311a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803106:	8b 0d a0 90 80 00    	mov    0x8090a0,%ecx
  80310c:	39 08                	cmp    %ecx,(%eax)
  80310e:	75 05                	jne    803115 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803110:	8b 40 0c             	mov    0xc(%eax),%eax
  803113:	eb 05                	jmp    80311a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  803115:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80311a:	c9                   	leave  
  80311b:	c3                   	ret    

0080311c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80311c:	55                   	push   %ebp
  80311d:	89 e5                	mov    %esp,%ebp
  80311f:	56                   	push   %esi
  803120:	53                   	push   %ebx
  803121:	83 ec 1c             	sub    $0x1c,%esp
  803124:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803129:	50                   	push   %eax
  80312a:	e8 ef f6 ff ff       	call   80281e <fd_alloc>
  80312f:	89 c3                	mov    %eax,%ebx
  803131:	83 c4 10             	add    $0x10,%esp
  803134:	85 c0                	test   %eax,%eax
  803136:	78 1b                	js     803153 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803138:	83 ec 04             	sub    $0x4,%esp
  80313b:	68 07 04 00 00       	push   $0x407
  803140:	ff 75 f4             	pushl  -0xc(%ebp)
  803143:	6a 00                	push   $0x0
  803145:	e8 93 f2 ff ff       	call   8023dd <sys_page_alloc>
  80314a:	89 c3                	mov    %eax,%ebx
  80314c:	83 c4 10             	add    $0x10,%esp
  80314f:	85 c0                	test   %eax,%eax
  803151:	79 10                	jns    803163 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  803153:	83 ec 0c             	sub    $0xc,%esp
  803156:	56                   	push   %esi
  803157:	e8 18 02 00 00       	call   803374 <nsipc_close>
		return r;
  80315c:	83 c4 10             	add    $0x10,%esp
  80315f:	89 d8                	mov    %ebx,%eax
  803161:	eb 24                	jmp    803187 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803163:	8b 15 a0 90 80 00    	mov    0x8090a0,%edx
  803169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80316c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80316e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803171:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  803178:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80317b:	83 ec 0c             	sub    $0xc,%esp
  80317e:	52                   	push   %edx
  80317f:	e8 73 f6 ff ff       	call   8027f7 <fd2num>
  803184:	83 c4 10             	add    $0x10,%esp
}
  803187:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80318a:	5b                   	pop    %ebx
  80318b:	5e                   	pop    %esi
  80318c:	5d                   	pop    %ebp
  80318d:	c3                   	ret    

0080318e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80318e:	55                   	push   %ebp
  80318f:	89 e5                	mov    %esp,%ebp
  803191:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803194:	8b 45 08             	mov    0x8(%ebp),%eax
  803197:	e8 50 ff ff ff       	call   8030ec <fd2sockid>
		return r;
  80319c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80319e:	85 c0                	test   %eax,%eax
  8031a0:	78 1f                	js     8031c1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8031a2:	83 ec 04             	sub    $0x4,%esp
  8031a5:	ff 75 10             	pushl  0x10(%ebp)
  8031a8:	ff 75 0c             	pushl  0xc(%ebp)
  8031ab:	50                   	push   %eax
  8031ac:	e8 1c 01 00 00       	call   8032cd <nsipc_accept>
  8031b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8031b4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8031b6:	85 c0                	test   %eax,%eax
  8031b8:	78 07                	js     8031c1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8031ba:	e8 5d ff ff ff       	call   80311c <alloc_sockfd>
  8031bf:	89 c1                	mov    %eax,%ecx
}
  8031c1:	89 c8                	mov    %ecx,%eax
  8031c3:	c9                   	leave  
  8031c4:	c3                   	ret    

008031c5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8031c5:	55                   	push   %ebp
  8031c6:	89 e5                	mov    %esp,%ebp
  8031c8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8031ce:	e8 19 ff ff ff       	call   8030ec <fd2sockid>
  8031d3:	89 c2                	mov    %eax,%edx
  8031d5:	85 d2                	test   %edx,%edx
  8031d7:	78 12                	js     8031eb <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8031d9:	83 ec 04             	sub    $0x4,%esp
  8031dc:	ff 75 10             	pushl  0x10(%ebp)
  8031df:	ff 75 0c             	pushl  0xc(%ebp)
  8031e2:	52                   	push   %edx
  8031e3:	e8 35 01 00 00       	call   80331d <nsipc_bind>
  8031e8:	83 c4 10             	add    $0x10,%esp
}
  8031eb:	c9                   	leave  
  8031ec:	c3                   	ret    

008031ed <shutdown>:

int
shutdown(int s, int how)
{
  8031ed:	55                   	push   %ebp
  8031ee:	89 e5                	mov    %esp,%ebp
  8031f0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8031f6:	e8 f1 fe ff ff       	call   8030ec <fd2sockid>
  8031fb:	89 c2                	mov    %eax,%edx
  8031fd:	85 d2                	test   %edx,%edx
  8031ff:	78 0f                	js     803210 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  803201:	83 ec 08             	sub    $0x8,%esp
  803204:	ff 75 0c             	pushl  0xc(%ebp)
  803207:	52                   	push   %edx
  803208:	e8 45 01 00 00       	call   803352 <nsipc_shutdown>
  80320d:	83 c4 10             	add    $0x10,%esp
}
  803210:	c9                   	leave  
  803211:	c3                   	ret    

00803212 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803212:	55                   	push   %ebp
  803213:	89 e5                	mov    %esp,%ebp
  803215:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803218:	8b 45 08             	mov    0x8(%ebp),%eax
  80321b:	e8 cc fe ff ff       	call   8030ec <fd2sockid>
  803220:	89 c2                	mov    %eax,%edx
  803222:	85 d2                	test   %edx,%edx
  803224:	78 12                	js     803238 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  803226:	83 ec 04             	sub    $0x4,%esp
  803229:	ff 75 10             	pushl  0x10(%ebp)
  80322c:	ff 75 0c             	pushl  0xc(%ebp)
  80322f:	52                   	push   %edx
  803230:	e8 59 01 00 00       	call   80338e <nsipc_connect>
  803235:	83 c4 10             	add    $0x10,%esp
}
  803238:	c9                   	leave  
  803239:	c3                   	ret    

0080323a <listen>:

int
listen(int s, int backlog)
{
  80323a:	55                   	push   %ebp
  80323b:	89 e5                	mov    %esp,%ebp
  80323d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803240:	8b 45 08             	mov    0x8(%ebp),%eax
  803243:	e8 a4 fe ff ff       	call   8030ec <fd2sockid>
  803248:	89 c2                	mov    %eax,%edx
  80324a:	85 d2                	test   %edx,%edx
  80324c:	78 0f                	js     80325d <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  80324e:	83 ec 08             	sub    $0x8,%esp
  803251:	ff 75 0c             	pushl  0xc(%ebp)
  803254:	52                   	push   %edx
  803255:	e8 69 01 00 00       	call   8033c3 <nsipc_listen>
  80325a:	83 c4 10             	add    $0x10,%esp
}
  80325d:	c9                   	leave  
  80325e:	c3                   	ret    

0080325f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80325f:	55                   	push   %ebp
  803260:	89 e5                	mov    %esp,%ebp
  803262:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803265:	ff 75 10             	pushl  0x10(%ebp)
  803268:	ff 75 0c             	pushl  0xc(%ebp)
  80326b:	ff 75 08             	pushl  0x8(%ebp)
  80326e:	e8 3c 02 00 00       	call   8034af <nsipc_socket>
  803273:	89 c2                	mov    %eax,%edx
  803275:	83 c4 10             	add    $0x10,%esp
  803278:	85 d2                	test   %edx,%edx
  80327a:	78 05                	js     803281 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  80327c:	e8 9b fe ff ff       	call   80311c <alloc_sockfd>
}
  803281:	c9                   	leave  
  803282:	c3                   	ret    

00803283 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803283:	55                   	push   %ebp
  803284:	89 e5                	mov    %esp,%ebp
  803286:	53                   	push   %ebx
  803287:	83 ec 04             	sub    $0x4,%esp
  80328a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80328c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803293:	75 12                	jne    8032a7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803295:	83 ec 0c             	sub    $0xc,%esp
  803298:	6a 02                	push   $0x2
  80329a:	e8 20 f5 ff ff       	call   8027bf <ipc_find_env>
  80329f:	a3 04 a0 80 00       	mov    %eax,0x80a004
  8032a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8032a7:	6a 07                	push   $0x7
  8032a9:	68 00 c0 80 00       	push   $0x80c000
  8032ae:	53                   	push   %ebx
  8032af:	ff 35 04 a0 80 00    	pushl  0x80a004
  8032b5:	e8 b1 f4 ff ff       	call   80276b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8032ba:	83 c4 0c             	add    $0xc,%esp
  8032bd:	6a 00                	push   $0x0
  8032bf:	6a 00                	push   $0x0
  8032c1:	6a 00                	push   $0x0
  8032c3:	e8 3a f4 ff ff       	call   802702 <ipc_recv>
}
  8032c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032cb:	c9                   	leave  
  8032cc:	c3                   	ret    

008032cd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8032cd:	55                   	push   %ebp
  8032ce:	89 e5                	mov    %esp,%ebp
  8032d0:	56                   	push   %esi
  8032d1:	53                   	push   %ebx
  8032d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8032d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8032d8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8032dd:	8b 06                	mov    (%esi),%eax
  8032df:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8032e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8032e9:	e8 95 ff ff ff       	call   803283 <nsipc>
  8032ee:	89 c3                	mov    %eax,%ebx
  8032f0:	85 c0                	test   %eax,%eax
  8032f2:	78 20                	js     803314 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8032f4:	83 ec 04             	sub    $0x4,%esp
  8032f7:	ff 35 10 c0 80 00    	pushl  0x80c010
  8032fd:	68 00 c0 80 00       	push   $0x80c000
  803302:	ff 75 0c             	pushl  0xc(%ebp)
  803305:	e8 5c ee ff ff       	call   802166 <memmove>
		*addrlen = ret->ret_addrlen;
  80330a:	a1 10 c0 80 00       	mov    0x80c010,%eax
  80330f:	89 06                	mov    %eax,(%esi)
  803311:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  803314:	89 d8                	mov    %ebx,%eax
  803316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803319:	5b                   	pop    %ebx
  80331a:	5e                   	pop    %esi
  80331b:	5d                   	pop    %ebp
  80331c:	c3                   	ret    

0080331d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80331d:	55                   	push   %ebp
  80331e:	89 e5                	mov    %esp,%ebp
  803320:	53                   	push   %ebx
  803321:	83 ec 08             	sub    $0x8,%esp
  803324:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803327:	8b 45 08             	mov    0x8(%ebp),%eax
  80332a:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80332f:	53                   	push   %ebx
  803330:	ff 75 0c             	pushl  0xc(%ebp)
  803333:	68 04 c0 80 00       	push   $0x80c004
  803338:	e8 29 ee ff ff       	call   802166 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80333d:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  803343:	b8 02 00 00 00       	mov    $0x2,%eax
  803348:	e8 36 ff ff ff       	call   803283 <nsipc>
}
  80334d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803350:	c9                   	leave  
  803351:	c3                   	ret    

00803352 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803352:	55                   	push   %ebp
  803353:	89 e5                	mov    %esp,%ebp
  803355:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803358:	8b 45 08             	mov    0x8(%ebp),%eax
  80335b:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  803360:	8b 45 0c             	mov    0xc(%ebp),%eax
  803363:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803368:	b8 03 00 00 00       	mov    $0x3,%eax
  80336d:	e8 11 ff ff ff       	call   803283 <nsipc>
}
  803372:	c9                   	leave  
  803373:	c3                   	ret    

00803374 <nsipc_close>:

int
nsipc_close(int s)
{
  803374:	55                   	push   %ebp
  803375:	89 e5                	mov    %esp,%ebp
  803377:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80337a:	8b 45 08             	mov    0x8(%ebp),%eax
  80337d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  803382:	b8 04 00 00 00       	mov    $0x4,%eax
  803387:	e8 f7 fe ff ff       	call   803283 <nsipc>
}
  80338c:	c9                   	leave  
  80338d:	c3                   	ret    

0080338e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80338e:	55                   	push   %ebp
  80338f:	89 e5                	mov    %esp,%ebp
  803391:	53                   	push   %ebx
  803392:	83 ec 08             	sub    $0x8,%esp
  803395:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803398:	8b 45 08             	mov    0x8(%ebp),%eax
  80339b:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8033a0:	53                   	push   %ebx
  8033a1:	ff 75 0c             	pushl  0xc(%ebp)
  8033a4:	68 04 c0 80 00       	push   $0x80c004
  8033a9:	e8 b8 ed ff ff       	call   802166 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8033ae:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  8033b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8033b9:	e8 c5 fe ff ff       	call   803283 <nsipc>
}
  8033be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033c1:	c9                   	leave  
  8033c2:	c3                   	ret    

008033c3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8033c3:	55                   	push   %ebp
  8033c4:	89 e5                	mov    %esp,%ebp
  8033c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8033c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033cc:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8033d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033d4:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8033d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8033de:	e8 a0 fe ff ff       	call   803283 <nsipc>
}
  8033e3:	c9                   	leave  
  8033e4:	c3                   	ret    

008033e5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8033e5:	55                   	push   %ebp
  8033e6:	89 e5                	mov    %esp,%ebp
  8033e8:	56                   	push   %esi
  8033e9:	53                   	push   %ebx
  8033ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8033ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8033f0:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  8033f5:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  8033fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8033fe:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803403:	b8 07 00 00 00       	mov    $0x7,%eax
  803408:	e8 76 fe ff ff       	call   803283 <nsipc>
  80340d:	89 c3                	mov    %eax,%ebx
  80340f:	85 c0                	test   %eax,%eax
  803411:	78 35                	js     803448 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  803413:	39 f0                	cmp    %esi,%eax
  803415:	7f 07                	jg     80341e <nsipc_recv+0x39>
  803417:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80341c:	7e 16                	jle    803434 <nsipc_recv+0x4f>
  80341e:	68 e2 46 80 00       	push   $0x8046e2
  803423:	68 bd 3c 80 00       	push   $0x803cbd
  803428:	6a 62                	push   $0x62
  80342a:	68 f7 46 80 00       	push   $0x8046f7
  80342f:	e8 40 e5 ff ff       	call   801974 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803434:	83 ec 04             	sub    $0x4,%esp
  803437:	50                   	push   %eax
  803438:	68 00 c0 80 00       	push   $0x80c000
  80343d:	ff 75 0c             	pushl  0xc(%ebp)
  803440:	e8 21 ed ff ff       	call   802166 <memmove>
  803445:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803448:	89 d8                	mov    %ebx,%eax
  80344a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80344d:	5b                   	pop    %ebx
  80344e:	5e                   	pop    %esi
  80344f:	5d                   	pop    %ebp
  803450:	c3                   	ret    

00803451 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803451:	55                   	push   %ebp
  803452:	89 e5                	mov    %esp,%ebp
  803454:	53                   	push   %ebx
  803455:	83 ec 04             	sub    $0x4,%esp
  803458:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80345b:	8b 45 08             	mov    0x8(%ebp),%eax
  80345e:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  803463:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803469:	7e 16                	jle    803481 <nsipc_send+0x30>
  80346b:	68 03 47 80 00       	push   $0x804703
  803470:	68 bd 3c 80 00       	push   $0x803cbd
  803475:	6a 6d                	push   $0x6d
  803477:	68 f7 46 80 00       	push   $0x8046f7
  80347c:	e8 f3 e4 ff ff       	call   801974 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803481:	83 ec 04             	sub    $0x4,%esp
  803484:	53                   	push   %ebx
  803485:	ff 75 0c             	pushl  0xc(%ebp)
  803488:	68 0c c0 80 00       	push   $0x80c00c
  80348d:	e8 d4 ec ff ff       	call   802166 <memmove>
	nsipcbuf.send.req_size = size;
  803492:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  803498:	8b 45 14             	mov    0x14(%ebp),%eax
  80349b:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8034a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8034a5:	e8 d9 fd ff ff       	call   803283 <nsipc>
}
  8034aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034ad:	c9                   	leave  
  8034ae:	c3                   	ret    

008034af <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8034af:	55                   	push   %ebp
  8034b0:	89 e5                	mov    %esp,%ebp
  8034b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8034b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8034b8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  8034bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034c0:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  8034c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8034c8:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  8034cd:	b8 09 00 00 00       	mov    $0x9,%eax
  8034d2:	e8 ac fd ff ff       	call   803283 <nsipc>
}
  8034d7:	c9                   	leave  
  8034d8:	c3                   	ret    

008034d9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8034d9:	55                   	push   %ebp
  8034da:	89 e5                	mov    %esp,%ebp
  8034dc:	56                   	push   %esi
  8034dd:	53                   	push   %ebx
  8034de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8034e1:	83 ec 0c             	sub    $0xc,%esp
  8034e4:	ff 75 08             	pushl  0x8(%ebp)
  8034e7:	e8 1b f3 ff ff       	call   802807 <fd2data>
  8034ec:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8034ee:	83 c4 08             	add    $0x8,%esp
  8034f1:	68 0f 47 80 00       	push   $0x80470f
  8034f6:	53                   	push   %ebx
  8034f7:	e8 d8 ea ff ff       	call   801fd4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8034fc:	8b 56 04             	mov    0x4(%esi),%edx
  8034ff:	89 d0                	mov    %edx,%eax
  803501:	2b 06                	sub    (%esi),%eax
  803503:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803509:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803510:	00 00 00 
	stat->st_dev = &devpipe;
  803513:	c7 83 88 00 00 00 bc 	movl   $0x8090bc,0x88(%ebx)
  80351a:	90 80 00 
	return 0;
}
  80351d:	b8 00 00 00 00       	mov    $0x0,%eax
  803522:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803525:	5b                   	pop    %ebx
  803526:	5e                   	pop    %esi
  803527:	5d                   	pop    %ebp
  803528:	c3                   	ret    

00803529 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803529:	55                   	push   %ebp
  80352a:	89 e5                	mov    %esp,%ebp
  80352c:	53                   	push   %ebx
  80352d:	83 ec 0c             	sub    $0xc,%esp
  803530:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803533:	53                   	push   %ebx
  803534:	6a 00                	push   $0x0
  803536:	e8 27 ef ff ff       	call   802462 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80353b:	89 1c 24             	mov    %ebx,(%esp)
  80353e:	e8 c4 f2 ff ff       	call   802807 <fd2data>
  803543:	83 c4 08             	add    $0x8,%esp
  803546:	50                   	push   %eax
  803547:	6a 00                	push   $0x0
  803549:	e8 14 ef ff ff       	call   802462 <sys_page_unmap>
}
  80354e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803551:	c9                   	leave  
  803552:	c3                   	ret    

00803553 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803553:	55                   	push   %ebp
  803554:	89 e5                	mov    %esp,%ebp
  803556:	57                   	push   %edi
  803557:	56                   	push   %esi
  803558:	53                   	push   %ebx
  803559:	83 ec 1c             	sub    $0x1c,%esp
  80355c:	89 c6                	mov    %eax,%esi
  80355e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803561:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803566:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803569:	83 ec 0c             	sub    $0xc,%esp
  80356c:	56                   	push   %esi
  80356d:	e8 bb fa ff ff       	call   80302d <pageref>
  803572:	89 c7                	mov    %eax,%edi
  803574:	83 c4 04             	add    $0x4,%esp
  803577:	ff 75 e4             	pushl  -0x1c(%ebp)
  80357a:	e8 ae fa ff ff       	call   80302d <pageref>
  80357f:	83 c4 10             	add    $0x10,%esp
  803582:	39 c7                	cmp    %eax,%edi
  803584:	0f 94 c2             	sete   %dl
  803587:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80358a:	8b 0d 10 a0 80 00    	mov    0x80a010,%ecx
  803590:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  803593:	39 fb                	cmp    %edi,%ebx
  803595:	74 19                	je     8035b0 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  803597:	84 d2                	test   %dl,%dl
  803599:	74 c6                	je     803561 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80359b:	8b 51 58             	mov    0x58(%ecx),%edx
  80359e:	50                   	push   %eax
  80359f:	52                   	push   %edx
  8035a0:	53                   	push   %ebx
  8035a1:	68 16 47 80 00       	push   $0x804716
  8035a6:	e8 a2 e4 ff ff       	call   801a4d <cprintf>
  8035ab:	83 c4 10             	add    $0x10,%esp
  8035ae:	eb b1                	jmp    803561 <_pipeisclosed+0xe>
	}
}
  8035b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035b3:	5b                   	pop    %ebx
  8035b4:	5e                   	pop    %esi
  8035b5:	5f                   	pop    %edi
  8035b6:	5d                   	pop    %ebp
  8035b7:	c3                   	ret    

008035b8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8035b8:	55                   	push   %ebp
  8035b9:	89 e5                	mov    %esp,%ebp
  8035bb:	57                   	push   %edi
  8035bc:	56                   	push   %esi
  8035bd:	53                   	push   %ebx
  8035be:	83 ec 28             	sub    $0x28,%esp
  8035c1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8035c4:	56                   	push   %esi
  8035c5:	e8 3d f2 ff ff       	call   802807 <fd2data>
  8035ca:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035cc:	83 c4 10             	add    $0x10,%esp
  8035cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8035d4:	eb 4b                	jmp    803621 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8035d6:	89 da                	mov    %ebx,%edx
  8035d8:	89 f0                	mov    %esi,%eax
  8035da:	e8 74 ff ff ff       	call   803553 <_pipeisclosed>
  8035df:	85 c0                	test   %eax,%eax
  8035e1:	75 48                	jne    80362b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8035e3:	e8 d6 ed ff ff       	call   8023be <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8035e8:	8b 43 04             	mov    0x4(%ebx),%eax
  8035eb:	8b 0b                	mov    (%ebx),%ecx
  8035ed:	8d 51 20             	lea    0x20(%ecx),%edx
  8035f0:	39 d0                	cmp    %edx,%eax
  8035f2:	73 e2                	jae    8035d6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8035f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8035f7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8035fb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8035fe:	89 c2                	mov    %eax,%edx
  803600:	c1 fa 1f             	sar    $0x1f,%edx
  803603:	89 d1                	mov    %edx,%ecx
  803605:	c1 e9 1b             	shr    $0x1b,%ecx
  803608:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80360b:	83 e2 1f             	and    $0x1f,%edx
  80360e:	29 ca                	sub    %ecx,%edx
  803610:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803614:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803618:	83 c0 01             	add    $0x1,%eax
  80361b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80361e:	83 c7 01             	add    $0x1,%edi
  803621:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803624:	75 c2                	jne    8035e8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803626:	8b 45 10             	mov    0x10(%ebp),%eax
  803629:	eb 05                	jmp    803630 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80362b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803633:	5b                   	pop    %ebx
  803634:	5e                   	pop    %esi
  803635:	5f                   	pop    %edi
  803636:	5d                   	pop    %ebp
  803637:	c3                   	ret    

00803638 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803638:	55                   	push   %ebp
  803639:	89 e5                	mov    %esp,%ebp
  80363b:	57                   	push   %edi
  80363c:	56                   	push   %esi
  80363d:	53                   	push   %ebx
  80363e:	83 ec 18             	sub    $0x18,%esp
  803641:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803644:	57                   	push   %edi
  803645:	e8 bd f1 ff ff       	call   802807 <fd2data>
  80364a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80364c:	83 c4 10             	add    $0x10,%esp
  80364f:	bb 00 00 00 00       	mov    $0x0,%ebx
  803654:	eb 3d                	jmp    803693 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803656:	85 db                	test   %ebx,%ebx
  803658:	74 04                	je     80365e <devpipe_read+0x26>
				return i;
  80365a:	89 d8                	mov    %ebx,%eax
  80365c:	eb 44                	jmp    8036a2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80365e:	89 f2                	mov    %esi,%edx
  803660:	89 f8                	mov    %edi,%eax
  803662:	e8 ec fe ff ff       	call   803553 <_pipeisclosed>
  803667:	85 c0                	test   %eax,%eax
  803669:	75 32                	jne    80369d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80366b:	e8 4e ed ff ff       	call   8023be <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803670:	8b 06                	mov    (%esi),%eax
  803672:	3b 46 04             	cmp    0x4(%esi),%eax
  803675:	74 df                	je     803656 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803677:	99                   	cltd   
  803678:	c1 ea 1b             	shr    $0x1b,%edx
  80367b:	01 d0                	add    %edx,%eax
  80367d:	83 e0 1f             	and    $0x1f,%eax
  803680:	29 d0                	sub    %edx,%eax
  803682:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80368a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80368d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803690:	83 c3 01             	add    $0x1,%ebx
  803693:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803696:	75 d8                	jne    803670 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803698:	8b 45 10             	mov    0x10(%ebp),%eax
  80369b:	eb 05                	jmp    8036a2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80369d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8036a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036a5:	5b                   	pop    %ebx
  8036a6:	5e                   	pop    %esi
  8036a7:	5f                   	pop    %edi
  8036a8:	5d                   	pop    %ebp
  8036a9:	c3                   	ret    

008036aa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8036aa:	55                   	push   %ebp
  8036ab:	89 e5                	mov    %esp,%ebp
  8036ad:	56                   	push   %esi
  8036ae:	53                   	push   %ebx
  8036af:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8036b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036b5:	50                   	push   %eax
  8036b6:	e8 63 f1 ff ff       	call   80281e <fd_alloc>
  8036bb:	83 c4 10             	add    $0x10,%esp
  8036be:	89 c2                	mov    %eax,%edx
  8036c0:	85 c0                	test   %eax,%eax
  8036c2:	0f 88 2c 01 00 00    	js     8037f4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036c8:	83 ec 04             	sub    $0x4,%esp
  8036cb:	68 07 04 00 00       	push   $0x407
  8036d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8036d3:	6a 00                	push   $0x0
  8036d5:	e8 03 ed ff ff       	call   8023dd <sys_page_alloc>
  8036da:	83 c4 10             	add    $0x10,%esp
  8036dd:	89 c2                	mov    %eax,%edx
  8036df:	85 c0                	test   %eax,%eax
  8036e1:	0f 88 0d 01 00 00    	js     8037f4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8036e7:	83 ec 0c             	sub    $0xc,%esp
  8036ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8036ed:	50                   	push   %eax
  8036ee:	e8 2b f1 ff ff       	call   80281e <fd_alloc>
  8036f3:	89 c3                	mov    %eax,%ebx
  8036f5:	83 c4 10             	add    $0x10,%esp
  8036f8:	85 c0                	test   %eax,%eax
  8036fa:	0f 88 e2 00 00 00    	js     8037e2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803700:	83 ec 04             	sub    $0x4,%esp
  803703:	68 07 04 00 00       	push   $0x407
  803708:	ff 75 f0             	pushl  -0x10(%ebp)
  80370b:	6a 00                	push   $0x0
  80370d:	e8 cb ec ff ff       	call   8023dd <sys_page_alloc>
  803712:	89 c3                	mov    %eax,%ebx
  803714:	83 c4 10             	add    $0x10,%esp
  803717:	85 c0                	test   %eax,%eax
  803719:	0f 88 c3 00 00 00    	js     8037e2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80371f:	83 ec 0c             	sub    $0xc,%esp
  803722:	ff 75 f4             	pushl  -0xc(%ebp)
  803725:	e8 dd f0 ff ff       	call   802807 <fd2data>
  80372a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80372c:	83 c4 0c             	add    $0xc,%esp
  80372f:	68 07 04 00 00       	push   $0x407
  803734:	50                   	push   %eax
  803735:	6a 00                	push   $0x0
  803737:	e8 a1 ec ff ff       	call   8023dd <sys_page_alloc>
  80373c:	89 c3                	mov    %eax,%ebx
  80373e:	83 c4 10             	add    $0x10,%esp
  803741:	85 c0                	test   %eax,%eax
  803743:	0f 88 89 00 00 00    	js     8037d2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803749:	83 ec 0c             	sub    $0xc,%esp
  80374c:	ff 75 f0             	pushl  -0x10(%ebp)
  80374f:	e8 b3 f0 ff ff       	call   802807 <fd2data>
  803754:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80375b:	50                   	push   %eax
  80375c:	6a 00                	push   $0x0
  80375e:	56                   	push   %esi
  80375f:	6a 00                	push   $0x0
  803761:	e8 ba ec ff ff       	call   802420 <sys_page_map>
  803766:	89 c3                	mov    %eax,%ebx
  803768:	83 c4 20             	add    $0x20,%esp
  80376b:	85 c0                	test   %eax,%eax
  80376d:	78 55                	js     8037c4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80376f:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  803775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803778:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80377a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80377d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803784:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  80378a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80378d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80378f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803792:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803799:	83 ec 0c             	sub    $0xc,%esp
  80379c:	ff 75 f4             	pushl  -0xc(%ebp)
  80379f:	e8 53 f0 ff ff       	call   8027f7 <fd2num>
  8037a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8037a7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8037a9:	83 c4 04             	add    $0x4,%esp
  8037ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8037af:	e8 43 f0 ff ff       	call   8027f7 <fd2num>
  8037b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8037b7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8037ba:	83 c4 10             	add    $0x10,%esp
  8037bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8037c2:	eb 30                	jmp    8037f4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8037c4:	83 ec 08             	sub    $0x8,%esp
  8037c7:	56                   	push   %esi
  8037c8:	6a 00                	push   $0x0
  8037ca:	e8 93 ec ff ff       	call   802462 <sys_page_unmap>
  8037cf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8037d2:	83 ec 08             	sub    $0x8,%esp
  8037d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8037d8:	6a 00                	push   $0x0
  8037da:	e8 83 ec ff ff       	call   802462 <sys_page_unmap>
  8037df:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8037e2:	83 ec 08             	sub    $0x8,%esp
  8037e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8037e8:	6a 00                	push   $0x0
  8037ea:	e8 73 ec ff ff       	call   802462 <sys_page_unmap>
  8037ef:	83 c4 10             	add    $0x10,%esp
  8037f2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8037f4:	89 d0                	mov    %edx,%eax
  8037f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8037f9:	5b                   	pop    %ebx
  8037fa:	5e                   	pop    %esi
  8037fb:	5d                   	pop    %ebp
  8037fc:	c3                   	ret    

008037fd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8037fd:	55                   	push   %ebp
  8037fe:	89 e5                	mov    %esp,%ebp
  803800:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803803:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803806:	50                   	push   %eax
  803807:	ff 75 08             	pushl  0x8(%ebp)
  80380a:	e8 5e f0 ff ff       	call   80286d <fd_lookup>
  80380f:	89 c2                	mov    %eax,%edx
  803811:	83 c4 10             	add    $0x10,%esp
  803814:	85 d2                	test   %edx,%edx
  803816:	78 18                	js     803830 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803818:	83 ec 0c             	sub    $0xc,%esp
  80381b:	ff 75 f4             	pushl  -0xc(%ebp)
  80381e:	e8 e4 ef ff ff       	call   802807 <fd2data>
	return _pipeisclosed(fd, p);
  803823:	89 c2                	mov    %eax,%edx
  803825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803828:	e8 26 fd ff ff       	call   803553 <_pipeisclosed>
  80382d:	83 c4 10             	add    $0x10,%esp
}
  803830:	c9                   	leave  
  803831:	c3                   	ret    

00803832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803832:	55                   	push   %ebp
  803833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803835:	b8 00 00 00 00       	mov    $0x0,%eax
  80383a:	5d                   	pop    %ebp
  80383b:	c3                   	ret    

0080383c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80383c:	55                   	push   %ebp
  80383d:	89 e5                	mov    %esp,%ebp
  80383f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803842:	68 2e 47 80 00       	push   $0x80472e
  803847:	ff 75 0c             	pushl  0xc(%ebp)
  80384a:	e8 85 e7 ff ff       	call   801fd4 <strcpy>
	return 0;
}
  80384f:	b8 00 00 00 00       	mov    $0x0,%eax
  803854:	c9                   	leave  
  803855:	c3                   	ret    

00803856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803856:	55                   	push   %ebp
  803857:	89 e5                	mov    %esp,%ebp
  803859:	57                   	push   %edi
  80385a:	56                   	push   %esi
  80385b:	53                   	push   %ebx
  80385c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80386d:	eb 2d                	jmp    80389c <devcons_write+0x46>
		m = n - tot;
  80386f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80387c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80387f:	83 ec 04             	sub    $0x4,%esp
  803882:	53                   	push   %ebx
  803883:	03 45 0c             	add    0xc(%ebp),%eax
  803886:	50                   	push   %eax
  803887:	57                   	push   %edi
  803888:	e8 d9 e8 ff ff       	call   802166 <memmove>
		sys_cputs(buf, m);
  80388d:	83 c4 08             	add    $0x8,%esp
  803890:	53                   	push   %ebx
  803891:	57                   	push   %edi
  803892:	e8 8a ea ff ff       	call   802321 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803897:	01 de                	add    %ebx,%esi
  803899:	83 c4 10             	add    $0x10,%esp
  80389c:	89 f0                	mov    %esi,%eax
  80389e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8038a1:	72 cc                	jb     80386f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8038a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8038a6:	5b                   	pop    %ebx
  8038a7:	5e                   	pop    %esi
  8038a8:	5f                   	pop    %edi
  8038a9:	5d                   	pop    %ebp
  8038aa:	c3                   	ret    

008038ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8038ab:	55                   	push   %ebp
  8038ac:	89 e5                	mov    %esp,%ebp
  8038ae:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8038b1:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8038b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8038ba:	75 07                	jne    8038c3 <devcons_read+0x18>
  8038bc:	eb 28                	jmp    8038e6 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8038be:	e8 fb ea ff ff       	call   8023be <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8038c3:	e8 77 ea ff ff       	call   80233f <sys_cgetc>
  8038c8:	85 c0                	test   %eax,%eax
  8038ca:	74 f2                	je     8038be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8038cc:	85 c0                	test   %eax,%eax
  8038ce:	78 16                	js     8038e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8038d0:	83 f8 04             	cmp    $0x4,%eax
  8038d3:	74 0c                	je     8038e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8038d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8038d8:	88 02                	mov    %al,(%edx)
	return 1;
  8038da:	b8 01 00 00 00       	mov    $0x1,%eax
  8038df:	eb 05                	jmp    8038e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8038e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8038e6:	c9                   	leave  
  8038e7:	c3                   	ret    

008038e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8038e8:	55                   	push   %ebp
  8038e9:	89 e5                	mov    %esp,%ebp
  8038eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8038ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8038f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8038f4:	6a 01                	push   $0x1
  8038f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8038f9:	50                   	push   %eax
  8038fa:	e8 22 ea ff ff       	call   802321 <sys_cputs>
  8038ff:	83 c4 10             	add    $0x10,%esp
}
  803902:	c9                   	leave  
  803903:	c3                   	ret    

00803904 <getchar>:

int
getchar(void)
{
  803904:	55                   	push   %ebp
  803905:	89 e5                	mov    %esp,%ebp
  803907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80390a:	6a 01                	push   $0x1
  80390c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80390f:	50                   	push   %eax
  803910:	6a 00                	push   $0x0
  803912:	e8 c5 f1 ff ff       	call   802adc <read>
	if (r < 0)
  803917:	83 c4 10             	add    $0x10,%esp
  80391a:	85 c0                	test   %eax,%eax
  80391c:	78 0f                	js     80392d <getchar+0x29>
		return r;
	if (r < 1)
  80391e:	85 c0                	test   %eax,%eax
  803920:	7e 06                	jle    803928 <getchar+0x24>
		return -E_EOF;
	return c;
  803922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803926:	eb 05                	jmp    80392d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80392d:	c9                   	leave  
  80392e:	c3                   	ret    

0080392f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80392f:	55                   	push   %ebp
  803930:	89 e5                	mov    %esp,%ebp
  803932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803938:	50                   	push   %eax
  803939:	ff 75 08             	pushl  0x8(%ebp)
  80393c:	e8 2c ef ff ff       	call   80286d <fd_lookup>
  803941:	83 c4 10             	add    $0x10,%esp
  803944:	85 c0                	test   %eax,%eax
  803946:	78 11                	js     803959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80394b:	8b 15 d8 90 80 00    	mov    0x8090d8,%edx
  803951:	39 10                	cmp    %edx,(%eax)
  803953:	0f 94 c0             	sete   %al
  803956:	0f b6 c0             	movzbl %al,%eax
}
  803959:	c9                   	leave  
  80395a:	c3                   	ret    

0080395b <opencons>:

int
opencons(void)
{
  80395b:	55                   	push   %ebp
  80395c:	89 e5                	mov    %esp,%ebp
  80395e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803964:	50                   	push   %eax
  803965:	e8 b4 ee ff ff       	call   80281e <fd_alloc>
  80396a:	83 c4 10             	add    $0x10,%esp
		return r;
  80396d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80396f:	85 c0                	test   %eax,%eax
  803971:	78 3e                	js     8039b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803973:	83 ec 04             	sub    $0x4,%esp
  803976:	68 07 04 00 00       	push   $0x407
  80397b:	ff 75 f4             	pushl  -0xc(%ebp)
  80397e:	6a 00                	push   $0x0
  803980:	e8 58 ea ff ff       	call   8023dd <sys_page_alloc>
  803985:	83 c4 10             	add    $0x10,%esp
		return r;
  803988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80398a:	85 c0                	test   %eax,%eax
  80398c:	78 23                	js     8039b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80398e:	8b 15 d8 90 80 00    	mov    0x8090d8,%edx
  803994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80399c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8039a3:	83 ec 0c             	sub    $0xc,%esp
  8039a6:	50                   	push   %eax
  8039a7:	e8 4b ee ff ff       	call   8027f7 <fd2num>
  8039ac:	89 c2                	mov    %eax,%edx
  8039ae:	83 c4 10             	add    $0x10,%esp
}
  8039b1:	89 d0                	mov    %edx,%eax
  8039b3:	c9                   	leave  
  8039b4:	c3                   	ret    
  8039b5:	66 90                	xchg   %ax,%ax
  8039b7:	66 90                	xchg   %ax,%ax
  8039b9:	66 90                	xchg   %ax,%ax
  8039bb:	66 90                	xchg   %ax,%ax
  8039bd:	66 90                	xchg   %ax,%ax
  8039bf:	90                   	nop

008039c0 <__udivdi3>:
  8039c0:	55                   	push   %ebp
  8039c1:	57                   	push   %edi
  8039c2:	56                   	push   %esi
  8039c3:	83 ec 10             	sub    $0x10,%esp
  8039c6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8039ca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8039ce:	8b 74 24 24          	mov    0x24(%esp),%esi
  8039d2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8039d6:	85 d2                	test   %edx,%edx
  8039d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8039dc:	89 34 24             	mov    %esi,(%esp)
  8039df:	89 c8                	mov    %ecx,%eax
  8039e1:	75 35                	jne    803a18 <__udivdi3+0x58>
  8039e3:	39 f1                	cmp    %esi,%ecx
  8039e5:	0f 87 bd 00 00 00    	ja     803aa8 <__udivdi3+0xe8>
  8039eb:	85 c9                	test   %ecx,%ecx
  8039ed:	89 cd                	mov    %ecx,%ebp
  8039ef:	75 0b                	jne    8039fc <__udivdi3+0x3c>
  8039f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8039f6:	31 d2                	xor    %edx,%edx
  8039f8:	f7 f1                	div    %ecx
  8039fa:	89 c5                	mov    %eax,%ebp
  8039fc:	89 f0                	mov    %esi,%eax
  8039fe:	31 d2                	xor    %edx,%edx
  803a00:	f7 f5                	div    %ebp
  803a02:	89 c6                	mov    %eax,%esi
  803a04:	89 f8                	mov    %edi,%eax
  803a06:	f7 f5                	div    %ebp
  803a08:	89 f2                	mov    %esi,%edx
  803a0a:	83 c4 10             	add    $0x10,%esp
  803a0d:	5e                   	pop    %esi
  803a0e:	5f                   	pop    %edi
  803a0f:	5d                   	pop    %ebp
  803a10:	c3                   	ret    
  803a11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a18:	3b 14 24             	cmp    (%esp),%edx
  803a1b:	77 7b                	ja     803a98 <__udivdi3+0xd8>
  803a1d:	0f bd f2             	bsr    %edx,%esi
  803a20:	83 f6 1f             	xor    $0x1f,%esi
  803a23:	0f 84 97 00 00 00    	je     803ac0 <__udivdi3+0x100>
  803a29:	bd 20 00 00 00       	mov    $0x20,%ebp
  803a2e:	89 d7                	mov    %edx,%edi
  803a30:	89 f1                	mov    %esi,%ecx
  803a32:	29 f5                	sub    %esi,%ebp
  803a34:	d3 e7                	shl    %cl,%edi
  803a36:	89 c2                	mov    %eax,%edx
  803a38:	89 e9                	mov    %ebp,%ecx
  803a3a:	d3 ea                	shr    %cl,%edx
  803a3c:	89 f1                	mov    %esi,%ecx
  803a3e:	09 fa                	or     %edi,%edx
  803a40:	8b 3c 24             	mov    (%esp),%edi
  803a43:	d3 e0                	shl    %cl,%eax
  803a45:	89 54 24 08          	mov    %edx,0x8(%esp)
  803a49:	89 e9                	mov    %ebp,%ecx
  803a4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803a4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  803a53:	89 fa                	mov    %edi,%edx
  803a55:	d3 ea                	shr    %cl,%edx
  803a57:	89 f1                	mov    %esi,%ecx
  803a59:	d3 e7                	shl    %cl,%edi
  803a5b:	89 e9                	mov    %ebp,%ecx
  803a5d:	d3 e8                	shr    %cl,%eax
  803a5f:	09 c7                	or     %eax,%edi
  803a61:	89 f8                	mov    %edi,%eax
  803a63:	f7 74 24 08          	divl   0x8(%esp)
  803a67:	89 d5                	mov    %edx,%ebp
  803a69:	89 c7                	mov    %eax,%edi
  803a6b:	f7 64 24 0c          	mull   0xc(%esp)
  803a6f:	39 d5                	cmp    %edx,%ebp
  803a71:	89 14 24             	mov    %edx,(%esp)
  803a74:	72 11                	jb     803a87 <__udivdi3+0xc7>
  803a76:	8b 54 24 04          	mov    0x4(%esp),%edx
  803a7a:	89 f1                	mov    %esi,%ecx
  803a7c:	d3 e2                	shl    %cl,%edx
  803a7e:	39 c2                	cmp    %eax,%edx
  803a80:	73 5e                	jae    803ae0 <__udivdi3+0x120>
  803a82:	3b 2c 24             	cmp    (%esp),%ebp
  803a85:	75 59                	jne    803ae0 <__udivdi3+0x120>
  803a87:	8d 47 ff             	lea    -0x1(%edi),%eax
  803a8a:	31 f6                	xor    %esi,%esi
  803a8c:	89 f2                	mov    %esi,%edx
  803a8e:	83 c4 10             	add    $0x10,%esp
  803a91:	5e                   	pop    %esi
  803a92:	5f                   	pop    %edi
  803a93:	5d                   	pop    %ebp
  803a94:	c3                   	ret    
  803a95:	8d 76 00             	lea    0x0(%esi),%esi
  803a98:	31 f6                	xor    %esi,%esi
  803a9a:	31 c0                	xor    %eax,%eax
  803a9c:	89 f2                	mov    %esi,%edx
  803a9e:	83 c4 10             	add    $0x10,%esp
  803aa1:	5e                   	pop    %esi
  803aa2:	5f                   	pop    %edi
  803aa3:	5d                   	pop    %ebp
  803aa4:	c3                   	ret    
  803aa5:	8d 76 00             	lea    0x0(%esi),%esi
  803aa8:	89 f2                	mov    %esi,%edx
  803aaa:	31 f6                	xor    %esi,%esi
  803aac:	89 f8                	mov    %edi,%eax
  803aae:	f7 f1                	div    %ecx
  803ab0:	89 f2                	mov    %esi,%edx
  803ab2:	83 c4 10             	add    $0x10,%esp
  803ab5:	5e                   	pop    %esi
  803ab6:	5f                   	pop    %edi
  803ab7:	5d                   	pop    %ebp
  803ab8:	c3                   	ret    
  803ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ac0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803ac4:	76 0b                	jbe    803ad1 <__udivdi3+0x111>
  803ac6:	31 c0                	xor    %eax,%eax
  803ac8:	3b 14 24             	cmp    (%esp),%edx
  803acb:	0f 83 37 ff ff ff    	jae    803a08 <__udivdi3+0x48>
  803ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  803ad6:	e9 2d ff ff ff       	jmp    803a08 <__udivdi3+0x48>
  803adb:	90                   	nop
  803adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ae0:	89 f8                	mov    %edi,%eax
  803ae2:	31 f6                	xor    %esi,%esi
  803ae4:	e9 1f ff ff ff       	jmp    803a08 <__udivdi3+0x48>
  803ae9:	66 90                	xchg   %ax,%ax
  803aeb:	66 90                	xchg   %ax,%ax
  803aed:	66 90                	xchg   %ax,%ax
  803aef:	90                   	nop

00803af0 <__umoddi3>:
  803af0:	55                   	push   %ebp
  803af1:	57                   	push   %edi
  803af2:	56                   	push   %esi
  803af3:	83 ec 20             	sub    $0x20,%esp
  803af6:	8b 44 24 34          	mov    0x34(%esp),%eax
  803afa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803afe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803b02:	89 c6                	mov    %eax,%esi
  803b04:	89 44 24 10          	mov    %eax,0x10(%esp)
  803b08:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803b0c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  803b10:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803b14:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803b18:	89 74 24 18          	mov    %esi,0x18(%esp)
  803b1c:	85 c0                	test   %eax,%eax
  803b1e:	89 c2                	mov    %eax,%edx
  803b20:	75 1e                	jne    803b40 <__umoddi3+0x50>
  803b22:	39 f7                	cmp    %esi,%edi
  803b24:	76 52                	jbe    803b78 <__umoddi3+0x88>
  803b26:	89 c8                	mov    %ecx,%eax
  803b28:	89 f2                	mov    %esi,%edx
  803b2a:	f7 f7                	div    %edi
  803b2c:	89 d0                	mov    %edx,%eax
  803b2e:	31 d2                	xor    %edx,%edx
  803b30:	83 c4 20             	add    $0x20,%esp
  803b33:	5e                   	pop    %esi
  803b34:	5f                   	pop    %edi
  803b35:	5d                   	pop    %ebp
  803b36:	c3                   	ret    
  803b37:	89 f6                	mov    %esi,%esi
  803b39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803b40:	39 f0                	cmp    %esi,%eax
  803b42:	77 5c                	ja     803ba0 <__umoddi3+0xb0>
  803b44:	0f bd e8             	bsr    %eax,%ebp
  803b47:	83 f5 1f             	xor    $0x1f,%ebp
  803b4a:	75 64                	jne    803bb0 <__umoddi3+0xc0>
  803b4c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  803b50:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  803b54:	0f 86 f6 00 00 00    	jbe    803c50 <__umoddi3+0x160>
  803b5a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  803b5e:	0f 82 ec 00 00 00    	jb     803c50 <__umoddi3+0x160>
  803b64:	8b 44 24 14          	mov    0x14(%esp),%eax
  803b68:	8b 54 24 18          	mov    0x18(%esp),%edx
  803b6c:	83 c4 20             	add    $0x20,%esp
  803b6f:	5e                   	pop    %esi
  803b70:	5f                   	pop    %edi
  803b71:	5d                   	pop    %ebp
  803b72:	c3                   	ret    
  803b73:	90                   	nop
  803b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b78:	85 ff                	test   %edi,%edi
  803b7a:	89 fd                	mov    %edi,%ebp
  803b7c:	75 0b                	jne    803b89 <__umoddi3+0x99>
  803b7e:	b8 01 00 00 00       	mov    $0x1,%eax
  803b83:	31 d2                	xor    %edx,%edx
  803b85:	f7 f7                	div    %edi
  803b87:	89 c5                	mov    %eax,%ebp
  803b89:	8b 44 24 10          	mov    0x10(%esp),%eax
  803b8d:	31 d2                	xor    %edx,%edx
  803b8f:	f7 f5                	div    %ebp
  803b91:	89 c8                	mov    %ecx,%eax
  803b93:	f7 f5                	div    %ebp
  803b95:	eb 95                	jmp    803b2c <__umoddi3+0x3c>
  803b97:	89 f6                	mov    %esi,%esi
  803b99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803ba0:	89 c8                	mov    %ecx,%eax
  803ba2:	89 f2                	mov    %esi,%edx
  803ba4:	83 c4 20             	add    $0x20,%esp
  803ba7:	5e                   	pop    %esi
  803ba8:	5f                   	pop    %edi
  803ba9:	5d                   	pop    %ebp
  803baa:	c3                   	ret    
  803bab:	90                   	nop
  803bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803bb0:	b8 20 00 00 00       	mov    $0x20,%eax
  803bb5:	89 e9                	mov    %ebp,%ecx
  803bb7:	29 e8                	sub    %ebp,%eax
  803bb9:	d3 e2                	shl    %cl,%edx
  803bbb:	89 c7                	mov    %eax,%edi
  803bbd:	89 44 24 18          	mov    %eax,0x18(%esp)
  803bc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803bc5:	89 f9                	mov    %edi,%ecx
  803bc7:	d3 e8                	shr    %cl,%eax
  803bc9:	89 c1                	mov    %eax,%ecx
  803bcb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803bcf:	09 d1                	or     %edx,%ecx
  803bd1:	89 fa                	mov    %edi,%edx
  803bd3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803bd7:	89 e9                	mov    %ebp,%ecx
  803bd9:	d3 e0                	shl    %cl,%eax
  803bdb:	89 f9                	mov    %edi,%ecx
  803bdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803be1:	89 f0                	mov    %esi,%eax
  803be3:	d3 e8                	shr    %cl,%eax
  803be5:	89 e9                	mov    %ebp,%ecx
  803be7:	89 c7                	mov    %eax,%edi
  803be9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803bed:	d3 e6                	shl    %cl,%esi
  803bef:	89 d1                	mov    %edx,%ecx
  803bf1:	89 fa                	mov    %edi,%edx
  803bf3:	d3 e8                	shr    %cl,%eax
  803bf5:	89 e9                	mov    %ebp,%ecx
  803bf7:	09 f0                	or     %esi,%eax
  803bf9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  803bfd:	f7 74 24 10          	divl   0x10(%esp)
  803c01:	d3 e6                	shl    %cl,%esi
  803c03:	89 d1                	mov    %edx,%ecx
  803c05:	f7 64 24 0c          	mull   0xc(%esp)
  803c09:	39 d1                	cmp    %edx,%ecx
  803c0b:	89 74 24 14          	mov    %esi,0x14(%esp)
  803c0f:	89 d7                	mov    %edx,%edi
  803c11:	89 c6                	mov    %eax,%esi
  803c13:	72 0a                	jb     803c1f <__umoddi3+0x12f>
  803c15:	39 44 24 14          	cmp    %eax,0x14(%esp)
  803c19:	73 10                	jae    803c2b <__umoddi3+0x13b>
  803c1b:	39 d1                	cmp    %edx,%ecx
  803c1d:	75 0c                	jne    803c2b <__umoddi3+0x13b>
  803c1f:	89 d7                	mov    %edx,%edi
  803c21:	89 c6                	mov    %eax,%esi
  803c23:	2b 74 24 0c          	sub    0xc(%esp),%esi
  803c27:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  803c2b:	89 ca                	mov    %ecx,%edx
  803c2d:	89 e9                	mov    %ebp,%ecx
  803c2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803c33:	29 f0                	sub    %esi,%eax
  803c35:	19 fa                	sbb    %edi,%edx
  803c37:	d3 e8                	shr    %cl,%eax
  803c39:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  803c3e:	89 d7                	mov    %edx,%edi
  803c40:	d3 e7                	shl    %cl,%edi
  803c42:	89 e9                	mov    %ebp,%ecx
  803c44:	09 f8                	or     %edi,%eax
  803c46:	d3 ea                	shr    %cl,%edx
  803c48:	83 c4 20             	add    $0x20,%esp
  803c4b:	5e                   	pop    %esi
  803c4c:	5f                   	pop    %edi
  803c4d:	5d                   	pop    %ebp
  803c4e:	c3                   	ret    
  803c4f:	90                   	nop
  803c50:	8b 74 24 10          	mov    0x10(%esp),%esi
  803c54:	29 f9                	sub    %edi,%ecx
  803c56:	19 c6                	sbb    %eax,%esi
  803c58:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803c5c:	89 74 24 18          	mov    %esi,0x18(%esp)
  803c60:	e9 ff fe ff ff       	jmp    803b64 <__umoddi3+0x74>
