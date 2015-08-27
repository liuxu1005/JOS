
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
  80002c:	e8 e8 18 00 00       	call   801919 <libmain>
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
  8000af:	68 80 37 80 00       	push   $0x803780
  8000b4:	e8 99 19 00 00       	call   801a52 <cprintf>
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
  8000d1:	68 97 37 80 00       	push   $0x803797
  8000d6:	6a 3a                	push   $0x3a
  8000d8:	68 a7 37 80 00       	push   $0x8037a7
  8000dd:	e8 97 18 00 00       	call   801979 <_panic>
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
  800103:	68 b0 37 80 00       	push   $0x8037b0
  800108:	68 bd 37 80 00       	push   $0x8037bd
  80010d:	6a 44                	push   $0x44
  80010f:	68 a7 37 80 00       	push   $0x8037a7
  800114:	e8 60 18 00 00       	call   801979 <_panic>

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
  8001b8:	68 b0 37 80 00       	push   $0x8037b0
  8001bd:	68 bd 37 80 00       	push   $0x8037bd
  8001c2:	6a 5d                	push   $0x5d
  8001c4:	68 a7 37 80 00       	push   $0x8037a7
  8001c9:	e8 ab 17 00 00       	call   801979 <_panic>

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
  800279:	68 d4 37 80 00       	push   $0x8037d4
  80027e:	6a 27                	push   $0x27
  800280:	68 b4 38 80 00       	push   $0x8038b4
  800285:	e8 ef 16 00 00       	call   801979 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80028a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80028f:	85 c0                	test   %eax,%eax
  800291:	74 17                	je     8002aa <bc_pgfault+0x57>
  800293:	3b 70 04             	cmp    0x4(%eax),%esi
  800296:	72 12                	jb     8002aa <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  800298:	56                   	push   %esi
  800299:	68 04 38 80 00       	push   $0x803804
  80029e:	6a 2b                	push   $0x2b
  8002a0:	68 b4 38 80 00       	push   $0x8038b4
  8002a5:	e8 cf 16 00 00       	call   801979 <_panic>
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
  8002b8:	e8 25 21 00 00       	call   8023e2 <sys_page_alloc>
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	79 14                	jns    8002d8 <bc_pgfault+0x85>
                panic("alloc disk map page fails\n");
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	68 bc 38 80 00       	push   $0x8038bc
  8002cc:	6a 35                	push   $0x35
  8002ce:	68 b4 38 80 00       	push   $0x8038b4
  8002d3:	e8 a1 16 00 00       	call   801979 <_panic>
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
  8002f3:	68 d7 38 80 00       	push   $0x8038d7
  8002f8:	6a 37                	push   $0x37
  8002fa:	68 b4 38 80 00       	push   $0x8038b4
  8002ff:	e8 75 16 00 00       	call   801979 <_panic>
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
  80031f:	e8 01 21 00 00       	call   802425 <sys_page_map>
  800324:	83 c4 20             	add    $0x20,%esp
  800327:	85 c0                	test   %eax,%eax
  800329:	79 12                	jns    80033d <bc_pgfault+0xea>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80032b:	50                   	push   %eax
  80032c:	68 28 38 80 00       	push   $0x803828
  800331:	6a 3b                	push   $0x3b
  800333:	68 b4 38 80 00       	push   $0x8038b4
  800338:	e8 3c 16 00 00       	call   801979 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80033d:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800344:	74 22                	je     800368 <bc_pgfault+0x115>
  800346:	83 ec 0c             	sub    $0xc,%esp
  800349:	56                   	push   %esi
  80034a:	e8 5a 03 00 00       	call   8006a9 <block_is_free>
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	84 c0                	test   %al,%al
  800354:	74 12                	je     800368 <bc_pgfault+0x115>
		panic("reading free block %08x\n", blockno);
  800356:	56                   	push   %esi
  800357:	68 e4 38 80 00       	push   $0x8038e4
  80035c:	6a 41                	push   $0x41
  80035e:	68 b4 38 80 00       	push   $0x8038b4
  800363:	e8 11 16 00 00       	call   801979 <_panic>
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
  80037c:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800382:	85 d2                	test   %edx,%edx
  800384:	74 17                	je     80039d <diskaddr+0x2e>
  800386:	3b 42 04             	cmp    0x4(%edx),%eax
  800389:	72 12                	jb     80039d <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  80038b:	50                   	push   %eax
  80038c:	68 48 38 80 00       	push   $0x803848
  800391:	6a 09                	push   $0x9
  800393:	68 b4 38 80 00       	push   $0x8038b4
  800398:	e8 dc 15 00 00       	call   801979 <_panic>
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
  800403:	68 fd 38 80 00       	push   $0x8038fd
  800408:	6a 51                	push   $0x51
  80040a:	68 b4 38 80 00       	push   $0x8038b4
  80040f:	e8 65 15 00 00       	call   801979 <_panic>

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
  800460:	68 18 39 80 00       	push   $0x803918
  800465:	6a 58                	push   $0x58
  800467:	68 b4 38 80 00       	push   $0x8038b4
  80046c:	e8 08 15 00 00       	call   801979 <_panic>
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
  80048c:	e8 94 1f 00 00       	call   802425 <sys_page_map>
  800491:	83 c4 20             	add    $0x20,%esp
  800494:	85 c0                	test   %eax,%eax
  800496:	79 12                	jns    8004aa <flush_block+0xbd>
		        panic("in flush_block, sys_page_map: %e", r);
  800498:	50                   	push   %eax
  800499:	68 6c 38 80 00       	push   $0x80386c
  80049e:	6a 5a                	push   $0x5a
  8004a0:	68 b4 38 80 00       	push   $0x8038b4
  8004a5:	e8 cf 14 00 00       	call   801979 <_panic>
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
  8004bf:	e8 0f 21 00 00       	call   8025d3 <set_pgfault_handler>
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
  8004e0:	e8 86 1c 00 00       	call   80216b <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ec:	e8 7e fe ff ff       	call   80036f <diskaddr>
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	68 26 39 80 00       	push   $0x803926
  8004f9:	50                   	push   %eax
  8004fa:	e8 da 1a 00 00       	call   801fd9 <strcpy>
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
  80052e:	68 48 39 80 00       	push   $0x803948
  800533:	68 bd 37 80 00       	push   $0x8037bd
  800538:	6a 6d                	push   $0x6d
  80053a:	68 b4 38 80 00       	push   $0x8038b4
  80053f:	e8 35 14 00 00       	call   801979 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	6a 01                	push   $0x1
  800549:	e8 21 fe ff ff       	call   80036f <diskaddr>
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 7f fe ff ff       	call   8003d5 <va_is_dirty>
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	84 c0                	test   %al,%al
  80055b:	74 16                	je     800573 <bc_init+0xc2>
  80055d:	68 2d 39 80 00       	push   $0x80392d
  800562:	68 bd 37 80 00       	push   $0x8037bd
  800567:	6a 6e                	push   $0x6e
  800569:	68 b4 38 80 00       	push   $0x8038b4
  80056e:	e8 06 14 00 00       	call   801979 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800573:	83 ec 0c             	sub    $0xc,%esp
  800576:	6a 01                	push   $0x1
  800578:	e8 f2 fd ff ff       	call   80036f <diskaddr>
  80057d:	83 c4 08             	add    $0x8,%esp
  800580:	50                   	push   %eax
  800581:	6a 00                	push   $0x0
  800583:	e8 df 1e 00 00       	call   802467 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800588:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058f:	e8 db fd ff ff       	call   80036f <diskaddr>
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 0b fe ff ff       	call   8003a7 <va_is_mapped>
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	84 c0                	test   %al,%al
  8005a1:	74 16                	je     8005b9 <bc_init+0x108>
  8005a3:	68 47 39 80 00       	push   $0x803947
  8005a8:	68 bd 37 80 00       	push   $0x8037bd
  8005ad:	6a 72                	push   $0x72
  8005af:	68 b4 38 80 00       	push   $0x8038b4
  8005b4:	e8 c0 13 00 00       	call   801979 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	6a 01                	push   $0x1
  8005be:	e8 ac fd ff ff       	call   80036f <diskaddr>
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	68 26 39 80 00       	push   $0x803926
  8005cb:	50                   	push   %eax
  8005cc:	e8 b2 1a 00 00       	call   802083 <strcmp>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	74 16                	je     8005ee <bc_init+0x13d>
  8005d8:	68 90 38 80 00       	push   $0x803890
  8005dd:	68 bd 37 80 00       	push   $0x8037bd
  8005e2:	6a 75                	push   $0x75
  8005e4:	68 b4 38 80 00       	push   $0x8038b4
  8005e9:	e8 8b 13 00 00       	call   801979 <_panic>

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
  800608:	e8 5e 1b 00 00       	call   80216b <memmove>
	flush_block(diskaddr(1));
  80060d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800614:	e8 56 fd ff ff       	call   80036f <diskaddr>
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 cc fd ff ff       	call   8003ed <flush_block>

	cprintf("block cache is good\n");
  800621:	c7 04 24 62 39 80 00 	movl   $0x803962,(%esp)
  800628:	e8 25 14 00 00       	call   801a52 <cprintf>
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
  800649:	e8 1d 1b 00 00       	call   80216b <memmove>
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
  800659:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80065e:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800664:	74 14                	je     80067a <check_super+0x27>
		panic("bad file system magic number");
  800666:	83 ec 04             	sub    $0x4,%esp
  800669:	68 77 39 80 00       	push   $0x803977
  80066e:	6a 0f                	push   $0xf
  800670:	68 94 39 80 00       	push   $0x803994
  800675:	e8 ff 12 00 00       	call   801979 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80067a:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800681:	76 14                	jbe    800697 <check_super+0x44>
		panic("file system is too large");
  800683:	83 ec 04             	sub    $0x4,%esp
  800686:	68 9c 39 80 00       	push   $0x80399c
  80068b:	6a 12                	push   $0x12
  80068d:	68 94 39 80 00       	push   $0x803994
  800692:	e8 e2 12 00 00       	call   801979 <_panic>

	cprintf("superblock is good\n");
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	68 b5 39 80 00       	push   $0x8039b5
  80069f:	e8 ae 13 00 00       	call   801a52 <cprintf>
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
  8006af:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
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
  8006cd:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
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
  8006f3:	68 c9 39 80 00       	push   $0x8039c9
  8006f8:	6a 2d                	push   $0x2d
  8006fa:	68 94 39 80 00       	push   $0x803994
  8006ff:	e8 75 12 00 00       	call   801979 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800704:	89 cb                	mov    %ecx,%ebx
  800706:	c1 eb 05             	shr    $0x5,%ebx
  800709:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
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
  800727:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  800748:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80074d:	89 de                	mov    %ebx,%esi
  80074f:	ba 01 00 00 00       	mov    $0x1,%edx
  800754:	89 d9                	mov    %ebx,%ecx
  800756:	d3 e2                	shl    %cl,%edx
  800758:	f7 d2                	not    %edx
  80075a:	21 14 b8             	and    %edx,(%eax,%edi,4)
                        flush_block(bitmap);
  80075d:	83 ec 0c             	sub    $0xc,%esp
  800760:	ff 35 04 a0 80 00    	pushl  0x80a004
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
  800803:	e8 16 19 00 00       	call   80211e <memset>
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
  800830:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  80084f:	68 e4 39 80 00       	push   $0x8039e4
  800854:	68 bd 37 80 00       	push   $0x8037bd
  800859:	6a 59                	push   $0x59
  80085b:	68 94 39 80 00       	push   $0x803994
  800860:	e8 14 11 00 00       	call   801979 <_panic>
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
  800882:	68 f8 39 80 00       	push   $0x8039f8
  800887:	68 bd 37 80 00       	push   $0x8037bd
  80088c:	6a 5c                	push   $0x5c
  80088e:	68 94 39 80 00       	push   $0x803994
  800893:	e8 e1 10 00 00       	call   801979 <_panic>
	assert(!block_is_free(1));
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	6a 01                	push   $0x1
  80089d:	e8 07 fe ff ff       	call   8006a9 <block_is_free>
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 16                	je     8008bf <check_bitmap+0x94>
  8008a9:	68 0a 3a 80 00       	push   $0x803a0a
  8008ae:	68 bd 37 80 00       	push   $0x8037bd
  8008b3:	6a 5d                	push   $0x5d
  8008b5:	68 94 39 80 00       	push   $0x803994
  8008ba:	e8 ba 10 00 00       	call   801979 <_panic>

	cprintf("bitmap is good\n");
  8008bf:	83 ec 0c             	sub    $0xc,%esp
  8008c2:	68 1c 3a 80 00       	push   $0x803a1c
  8008c7:	e8 86 11 00 00       	call   801a52 <cprintf>
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
  800910:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800915:	e8 39 fd ff ff       	call   800653 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80091a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800921:	e8 49 fa ff ff       	call   80036f <diskaddr>
  800926:	a3 04 a0 80 00       	mov    %eax,0x80a004
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
  80099c:	e8 7d 17 00 00       	call   80211e <memset>
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
  8009cd:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
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
  800a35:	e8 31 17 00 00       	call   80216b <memmove>
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
  800a6f:	68 2c 3a 80 00       	push   $0x803a2c
  800a74:	68 bd 37 80 00       	push   $0x8037bd
  800a79:	68 e1 00 00 00       	push   $0xe1
  800a7e:	68 94 39 80 00       	push   $0x803994
  800a83:	e8 f1 0e 00 00       	call   801979 <_panic>
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
  800aeb:	e8 93 15 00 00       	call   802083 <strcmp>
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
  800b54:	e8 80 14 00 00       	call   801fd9 <strcpy>
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
  800c7d:	e8 e9 14 00 00       	call   80216b <memmove>
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
  800d4e:	68 49 3a 80 00       	push   $0x803a49
  800d53:	e8 fa 0c 00 00       	call   801a52 <cprintf>
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
  800e04:	e8 62 13 00 00       	call   80216b <memmove>
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
  800f17:	68 2c 3a 80 00       	push   $0x803a2c
  800f1c:	68 bd 37 80 00       	push   $0x8037bd
  800f21:	68 fa 00 00 00       	push   $0xfa
  800f26:	68 94 39 80 00       	push   $0x803994
  800f2b:	e8 49 0a 00 00       	call   801979 <_panic>
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
  800fe2:	e8 f2 0f 00 00       	call   801fd9 <strcpy>
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
  801035:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  80109d:	e8 ea 1e 00 00       	call   802f8c <pageref>
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
  8010c2:	e8 1b 13 00 00       	call   8023e2 <sys_page_alloc>
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
  8010f5:	e8 24 10 00 00       	call   80211e <memset>
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
  80113f:	e8 48 1e 00 00       	call   802f8c <pageref>
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
  801293:	e8 41 0d 00 00       	call   801fd9 <strcpy>
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
  80131f:	e8 47 0e 00 00       	call   80216b <memmove>
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
  801456:	e8 0b 12 00 00       	call   802666 <ipc_recv>
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
  80146a:	68 68 3a 80 00       	push   $0x803a68
  80146f:	e8 de 05 00 00       	call   801a52 <cprintf>
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
  8014c7:	68 98 3a 80 00       	push   $0x803a98
  8014cc:	e8 81 05 00 00       	call   801a52 <cprintf>
  8014d1:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8014dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8014df:	50                   	push   %eax
  8014e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e3:	e8 e7 11 00 00       	call   8026cf <ipc_send>
		sys_page_unmap(0, fsreq);
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	ff 35 64 50 80 00    	pushl  0x805064
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 6f 0f 00 00       	call   802467 <sys_page_unmap>
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
  801506:	c7 05 80 90 80 00 bb 	movl   $0x803abb,0x809080
  80150d:	3a 80 00 
	cprintf("FS is running\n");
  801510:	68 be 3a 80 00       	push   $0x803abe
  801515:	e8 38 05 00 00       	call   801a52 <cprintf>
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
  801526:	c7 04 24 cd 3a 80 00 	movl   $0x803acd,(%esp)
  80152d:	e8 20 05 00 00       	call   801a52 <cprintf>

	serve_init();
  801532:	e8 1f fb ff ff       	call   801056 <serve_init>
	fs_init();
  801537:	e8 9a f3 ff ff       	call   8008d6 <fs_init>
        fs_test();
  80153c:	e8 05 00 00 00       	call   801546 <fs_test>
	serve();
  801541:	e8 f0 fe ff ff       	call   801436 <serve>

00801546 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80154d:	6a 07                	push   $0x7
  80154f:	68 00 10 00 00       	push   $0x1000
  801554:	6a 00                	push   $0x0
  801556:	e8 87 0e 00 00       	call   8023e2 <sys_page_alloc>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	79 12                	jns    801574 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801562:	50                   	push   %eax
  801563:	68 dc 3a 80 00       	push   $0x803adc
  801568:	6a 12                	push   $0x12
  80156a:	68 ef 3a 80 00       	push   $0x803aef
  80156f:	e8 05 04 00 00       	call   801979 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	68 00 10 00 00       	push   $0x1000
  80157c:	ff 35 04 a0 80 00    	pushl  0x80a004
  801582:	68 00 10 00 00       	push   $0x1000
  801587:	e8 df 0b 00 00       	call   80216b <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80158c:	e8 8d f1 ff ff       	call   80071e <alloc_block>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	79 12                	jns    8015aa <fs_test+0x64>
		panic("alloc_block: %e", r);
  801598:	50                   	push   %eax
  801599:	68 f9 3a 80 00       	push   $0x803af9
  80159e:	6a 17                	push   $0x17
  8015a0:	68 ef 3a 80 00       	push   $0x803aef
  8015a5:	e8 cf 03 00 00       	call   801979 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015aa:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	0f 49 d0             	cmovns %eax,%edx
  8015b2:	c1 fa 05             	sar    $0x5,%edx
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	c1 fb 1f             	sar    $0x1f,%ebx
  8015ba:	c1 eb 1b             	shr    $0x1b,%ebx
  8015bd:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015c0:	83 e1 1f             	and    $0x1f,%ecx
  8015c3:	29 d9                	sub    %ebx,%ecx
  8015c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ca:	d3 e0                	shl    %cl,%eax
  8015cc:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015d3:	75 16                	jne    8015eb <fs_test+0xa5>
  8015d5:	68 09 3b 80 00       	push   $0x803b09
  8015da:	68 bd 37 80 00       	push   $0x8037bd
  8015df:	6a 19                	push   $0x19
  8015e1:	68 ef 3a 80 00       	push   $0x803aef
  8015e6:	e8 8e 03 00 00       	call   801979 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015eb:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8015f1:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8015f4:	74 16                	je     80160c <fs_test+0xc6>
  8015f6:	68 84 3c 80 00       	push   $0x803c84
  8015fb:	68 bd 37 80 00       	push   $0x8037bd
  801600:	6a 1b                	push   $0x1b
  801602:	68 ef 3a 80 00       	push   $0x803aef
  801607:	e8 6d 03 00 00       	call   801979 <_panic>
	cprintf("alloc_block is good\n");
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	68 24 3b 80 00       	push   $0x803b24
  801614:	e8 39 04 00 00       	call   801a52 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	68 39 3b 80 00       	push   $0x803b39
  801625:	e8 b0 f5 ff ff       	call   800bda <file_open>
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	c1 ea 1f             	shr    $0x1f,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	84 d2                	test   %dl,%dl
  801634:	74 17                	je     80164d <fs_test+0x107>
  801636:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801639:	74 12                	je     80164d <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80163b:	50                   	push   %eax
  80163c:	68 44 3b 80 00       	push   $0x803b44
  801641:	6a 1f                	push   $0x1f
  801643:	68 ef 3a 80 00       	push   $0x803aef
  801648:	e8 2c 03 00 00       	call   801979 <_panic>
	else if (r == 0)
  80164d:	85 c0                	test   %eax,%eax
  80164f:	75 14                	jne    801665 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801651:	83 ec 04             	sub    $0x4,%esp
  801654:	68 a4 3c 80 00       	push   $0x803ca4
  801659:	6a 21                	push   $0x21
  80165b:	68 ef 3a 80 00       	push   $0x803aef
  801660:	e8 14 03 00 00       	call   801979 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	68 5d 3b 80 00       	push   $0x803b5d
  801671:	e8 64 f5 ff ff       	call   800bda <file_open>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	79 12                	jns    80168f <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80167d:	50                   	push   %eax
  80167e:	68 66 3b 80 00       	push   $0x803b66
  801683:	6a 23                	push   $0x23
  801685:	68 ef 3a 80 00       	push   $0x803aef
  80168a:	e8 ea 02 00 00       	call   801979 <_panic>
	cprintf("file_open is good\n");
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	68 7d 3b 80 00       	push   $0x803b7d
  801697:	e8 b6 03 00 00       	call   801a52 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80169c:	83 c4 0c             	add    $0xc,%esp
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	6a 00                	push   $0x0
  8016a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a8:	e8 88 f2 ff ff       	call   800935 <file_get_block>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	79 12                	jns    8016c6 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016b4:	50                   	push   %eax
  8016b5:	68 90 3b 80 00       	push   $0x803b90
  8016ba:	6a 27                	push   $0x27
  8016bc:	68 ef 3a 80 00       	push   $0x803aef
  8016c1:	e8 b3 02 00 00       	call   801979 <_panic>
	if (strcmp(blk, msg) != 0)
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	68 c4 3c 80 00       	push   $0x803cc4
  8016ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d1:	e8 ad 09 00 00       	call   802083 <strcmp>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	74 14                	je     8016f1 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	68 ec 3c 80 00       	push   $0x803cec
  8016e5:	6a 29                	push   $0x29
  8016e7:	68 ef 3a 80 00       	push   $0x803aef
  8016ec:	e8 88 02 00 00       	call   801979 <_panic>
	cprintf("file_get_block is good\n");
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	68 a3 3b 80 00       	push   $0x803ba3
  8016f9:	e8 54 03 00 00       	call   801a52 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	0f b6 10             	movzbl (%eax),%edx
  801704:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801709:	c1 e8 0c             	shr    $0xc,%eax
  80170c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	a8 40                	test   $0x40,%al
  801718:	75 16                	jne    801730 <fs_test+0x1ea>
  80171a:	68 bc 3b 80 00       	push   $0x803bbc
  80171f:	68 bd 37 80 00       	push   $0x8037bd
  801724:	6a 2d                	push   $0x2d
  801726:	68 ef 3a 80 00       	push   $0x803aef
  80172b:	e8 49 02 00 00       	call   801979 <_panic>
	file_flush(f);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	ff 75 f4             	pushl  -0xc(%ebp)
  801736:	e8 e7 f6 ff ff       	call   800e22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	c1 e8 0c             	shr    $0xc,%eax
  801741:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	a8 40                	test   $0x40,%al
  80174d:	74 16                	je     801765 <fs_test+0x21f>
  80174f:	68 bb 3b 80 00       	push   $0x803bbb
  801754:	68 bd 37 80 00       	push   $0x8037bd
  801759:	6a 2f                	push   $0x2f
  80175b:	68 ef 3a 80 00       	push   $0x803aef
  801760:	e8 14 02 00 00       	call   801979 <_panic>
	cprintf("file_flush is good\n");
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	68 d7 3b 80 00       	push   $0x803bd7
  80176d:	e8 e0 02 00 00       	call   801a52 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801772:	83 c4 08             	add    $0x8,%esp
  801775:	6a 00                	push   $0x0
  801777:	ff 75 f4             	pushl  -0xc(%ebp)
  80177a:	e8 1c f5 ff ff       	call   800c9b <file_set_size>
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	79 12                	jns    801798 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801786:	50                   	push   %eax
  801787:	68 eb 3b 80 00       	push   $0x803beb
  80178c:	6a 33                	push   $0x33
  80178e:	68 ef 3a 80 00       	push   $0x803aef
  801793:	e8 e1 01 00 00       	call   801979 <_panic>
	assert(f->f_direct[0] == 0);
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017a2:	74 16                	je     8017ba <fs_test+0x274>
  8017a4:	68 fd 3b 80 00       	push   $0x803bfd
  8017a9:	68 bd 37 80 00       	push   $0x8037bd
  8017ae:	6a 34                	push   $0x34
  8017b0:	68 ef 3a 80 00       	push   $0x803aef
  8017b5:	e8 bf 01 00 00       	call   801979 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017ba:	c1 e8 0c             	shr    $0xc,%eax
  8017bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c4:	a8 40                	test   $0x40,%al
  8017c6:	74 16                	je     8017de <fs_test+0x298>
  8017c8:	68 11 3c 80 00       	push   $0x803c11
  8017cd:	68 bd 37 80 00       	push   $0x8037bd
  8017d2:	6a 35                	push   $0x35
  8017d4:	68 ef 3a 80 00       	push   $0x803aef
  8017d9:	e8 9b 01 00 00       	call   801979 <_panic>
	cprintf("file_truncate is good\n");
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	68 2b 3c 80 00       	push   $0x803c2b
  8017e6:	e8 67 02 00 00       	call   801a52 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017eb:	c7 04 24 c4 3c 80 00 	movl   $0x803cc4,(%esp)
  8017f2:	e8 a9 07 00 00       	call   801fa0 <strlen>
  8017f7:	83 c4 08             	add    $0x8,%esp
  8017fa:	50                   	push   %eax
  8017fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fe:	e8 98 f4 ff ff       	call   800c9b <file_set_size>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	79 12                	jns    80181c <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80180a:	50                   	push   %eax
  80180b:	68 42 3c 80 00       	push   $0x803c42
  801810:	6a 39                	push   $0x39
  801812:	68 ef 3a 80 00       	push   $0x803aef
  801817:	e8 5d 01 00 00       	call   801979 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80181c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181f:	89 c2                	mov    %eax,%edx
  801821:	c1 ea 0c             	shr    $0xc,%edx
  801824:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80182b:	f6 c2 40             	test   $0x40,%dl
  80182e:	74 16                	je     801846 <fs_test+0x300>
  801830:	68 11 3c 80 00       	push   $0x803c11
  801835:	68 bd 37 80 00       	push   $0x8037bd
  80183a:	6a 3a                	push   $0x3a
  80183c:	68 ef 3a 80 00       	push   $0x803aef
  801841:	e8 33 01 00 00       	call   801979 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80184c:	52                   	push   %edx
  80184d:	6a 00                	push   $0x0
  80184f:	50                   	push   %eax
  801850:	e8 e0 f0 ff ff       	call   800935 <file_get_block>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	79 12                	jns    80186e <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80185c:	50                   	push   %eax
  80185d:	68 56 3c 80 00       	push   $0x803c56
  801862:	6a 3c                	push   $0x3c
  801864:	68 ef 3a 80 00       	push   $0x803aef
  801869:	e8 0b 01 00 00       	call   801979 <_panic>
	strcpy(blk, msg);
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	68 c4 3c 80 00       	push   $0x803cc4
  801876:	ff 75 f0             	pushl  -0x10(%ebp)
  801879:	e8 5b 07 00 00       	call   801fd9 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801881:	c1 e8 0c             	shr    $0xc,%eax
  801884:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	a8 40                	test   $0x40,%al
  801890:	75 16                	jne    8018a8 <fs_test+0x362>
  801892:	68 bc 3b 80 00       	push   $0x803bbc
  801897:	68 bd 37 80 00       	push   $0x8037bd
  80189c:	6a 3e                	push   $0x3e
  80189e:	68 ef 3a 80 00       	push   $0x803aef
  8018a3:	e8 d1 00 00 00       	call   801979 <_panic>
	file_flush(f);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 6f f5 ff ff       	call   800e22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	c1 e8 0c             	shr    $0xc,%eax
  8018b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	a8 40                	test   $0x40,%al
  8018c5:	74 16                	je     8018dd <fs_test+0x397>
  8018c7:	68 bb 3b 80 00       	push   $0x803bbb
  8018cc:	68 bd 37 80 00       	push   $0x8037bd
  8018d1:	6a 40                	push   $0x40
  8018d3:	68 ef 3a 80 00       	push   $0x803aef
  8018d8:	e8 9c 00 00 00       	call   801979 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e0:	c1 e8 0c             	shr    $0xc,%eax
  8018e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ea:	a8 40                	test   $0x40,%al
  8018ec:	74 16                	je     801904 <fs_test+0x3be>
  8018ee:	68 11 3c 80 00       	push   $0x803c11
  8018f3:	68 bd 37 80 00       	push   $0x8037bd
  8018f8:	6a 41                	push   $0x41
  8018fa:	68 ef 3a 80 00       	push   $0x803aef
  8018ff:	e8 75 00 00 00       	call   801979 <_panic>
	cprintf("file rewrite is good\n");
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	68 6b 3c 80 00       	push   $0x803c6b
  80190c:	e8 41 01 00 00       	call   801a52 <cprintf>
  801911:	83 c4 10             	add    $0x10,%esp
}
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801921:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  801924:	e8 7b 0a 00 00       	call   8023a4 <sys_getenvid>
  801929:	25 ff 03 00 00       	and    $0x3ff,%eax
  80192e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801931:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801936:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80193b:	85 db                	test   %ebx,%ebx
  80193d:	7e 07                	jle    801946 <libmain+0x2d>
		binaryname = argv[0];
  80193f:	8b 06                	mov    (%esi),%eax
  801941:	a3 80 90 80 00       	mov    %eax,0x809080

	// call user main routine
	umain(argc, argv);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	e8 b0 fb ff ff       	call   801500 <umain>

	// exit gracefully
	exit();
  801950:	e8 0a 00 00 00       	call   80195f <exit>
  801955:	83 c4 10             	add    $0x10,%esp
}
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801965:	e8 be 0f 00 00       	call   802928 <close_all>
	sys_env_destroy(0);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	6a 00                	push   $0x0
  80196f:	e8 ef 09 00 00       	call   802363 <sys_env_destroy>
  801974:	83 c4 10             	add    $0x10,%esp
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80197e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801981:	8b 35 80 90 80 00    	mov    0x809080,%esi
  801987:	e8 18 0a 00 00       	call   8023a4 <sys_getenvid>
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	ff 75 08             	pushl  0x8(%ebp)
  801995:	56                   	push   %esi
  801996:	50                   	push   %eax
  801997:	68 1c 3d 80 00       	push   $0x803d1c
  80199c:	e8 b1 00 00 00       	call   801a52 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019a1:	83 c4 18             	add    $0x18,%esp
  8019a4:	53                   	push   %ebx
  8019a5:	ff 75 10             	pushl  0x10(%ebp)
  8019a8:	e8 54 00 00 00       	call   801a01 <vcprintf>
	cprintf("\n");
  8019ad:	c7 04 24 2b 39 80 00 	movl   $0x80392b,(%esp)
  8019b4:	e8 99 00 00 00       	call   801a52 <cprintf>
  8019b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019bc:	cc                   	int3   
  8019bd:	eb fd                	jmp    8019bc <_panic+0x43>

008019bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019c9:	8b 13                	mov    (%ebx),%edx
  8019cb:	8d 42 01             	lea    0x1(%edx),%eax
  8019ce:	89 03                	mov    %eax,(%ebx)
  8019d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019dc:	75 1a                	jne    8019f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	68 ff 00 00 00       	push   $0xff
  8019e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8019e9:	50                   	push   %eax
  8019ea:	e8 37 09 00 00       	call   802326 <sys_cputs>
		b->idx = 0;
  8019ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a0a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a11:	00 00 00 
	b.cnt = 0;
  801a14:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a1b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	ff 75 08             	pushl  0x8(%ebp)
  801a24:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a2a:	50                   	push   %eax
  801a2b:	68 bf 19 80 00       	push   $0x8019bf
  801a30:	e8 4f 01 00 00       	call   801b84 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a3e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	e8 dc 08 00 00       	call   802326 <sys_cputs>

	return b.cnt;
}
  801a4a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a58:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a5b:	50                   	push   %eax
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	e8 9d ff ff ff       	call   801a01 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	57                   	push   %edi
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 1c             	sub    $0x1c,%esp
  801a6f:	89 c7                	mov    %eax,%edi
  801a71:	89 d6                	mov    %edx,%esi
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a79:	89 d1                	mov    %edx,%ecx
  801a7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a81:	8b 45 10             	mov    0x10(%ebp),%eax
  801a84:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a8a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801a91:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801a94:	72 05                	jb     801a9b <printnum+0x35>
  801a96:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801a99:	77 3e                	ja     801ad9 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	ff 75 18             	pushl  0x18(%ebp)
  801aa1:	83 eb 01             	sub    $0x1,%ebx
  801aa4:	53                   	push   %ebx
  801aa5:	50                   	push   %eax
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aac:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaf:	ff 75 dc             	pushl  -0x24(%ebp)
  801ab2:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab5:	e8 f6 19 00 00       	call   8034b0 <__udivdi3>
  801aba:	83 c4 18             	add    $0x18,%esp
  801abd:	52                   	push   %edx
  801abe:	50                   	push   %eax
  801abf:	89 f2                	mov    %esi,%edx
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	e8 9e ff ff ff       	call   801a66 <printnum>
  801ac8:	83 c4 20             	add    $0x20,%esp
  801acb:	eb 13                	jmp    801ae0 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	56                   	push   %esi
  801ad1:	ff 75 18             	pushl  0x18(%ebp)
  801ad4:	ff d7                	call   *%edi
  801ad6:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801ad9:	83 eb 01             	sub    $0x1,%ebx
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	7f ed                	jg     801acd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aea:	ff 75 e0             	pushl  -0x20(%ebp)
  801aed:	ff 75 dc             	pushl  -0x24(%ebp)
  801af0:	ff 75 d8             	pushl  -0x28(%ebp)
  801af3:	e8 e8 1a 00 00       	call   8035e0 <__umoddi3>
  801af8:	83 c4 14             	add    $0x14,%esp
  801afb:	0f be 80 3f 3d 80 00 	movsbl 0x803d3f(%eax),%eax
  801b02:	50                   	push   %eax
  801b03:	ff d7                	call   *%edi
  801b05:	83 c4 10             	add    $0x10,%esp
}
  801b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b13:	83 fa 01             	cmp    $0x1,%edx
  801b16:	7e 0e                	jle    801b26 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b18:	8b 10                	mov    (%eax),%edx
  801b1a:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b1d:	89 08                	mov    %ecx,(%eax)
  801b1f:	8b 02                	mov    (%edx),%eax
  801b21:	8b 52 04             	mov    0x4(%edx),%edx
  801b24:	eb 22                	jmp    801b48 <getuint+0x38>
	else if (lflag)
  801b26:	85 d2                	test   %edx,%edx
  801b28:	74 10                	je     801b3a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b2a:	8b 10                	mov    (%eax),%edx
  801b2c:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b2f:	89 08                	mov    %ecx,(%eax)
  801b31:	8b 02                	mov    (%edx),%eax
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	eb 0e                	jmp    801b48 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b3a:	8b 10                	mov    (%eax),%edx
  801b3c:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b3f:	89 08                	mov    %ecx,(%eax)
  801b41:	8b 02                	mov    (%edx),%eax
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b50:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b54:	8b 10                	mov    (%eax),%edx
  801b56:	3b 50 04             	cmp    0x4(%eax),%edx
  801b59:	73 0a                	jae    801b65 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b5b:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b5e:	89 08                	mov    %ecx,(%eax)
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	88 02                	mov    %al,(%edx)
}
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b6d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b70:	50                   	push   %eax
  801b71:	ff 75 10             	pushl  0x10(%ebp)
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	e8 05 00 00 00       	call   801b84 <vprintfmt>
	va_end(ap);
  801b7f:	83 c4 10             	add    $0x10,%esp
}
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 2c             	sub    $0x2c,%esp
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b93:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b96:	eb 12                	jmp    801baa <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 84 90 03 00 00    	je     801f30 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801ba0:	83 ec 08             	sub    $0x8,%esp
  801ba3:	53                   	push   %ebx
  801ba4:	50                   	push   %eax
  801ba5:	ff d6                	call   *%esi
  801ba7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801baa:	83 c7 01             	add    $0x1,%edi
  801bad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bb1:	83 f8 25             	cmp    $0x25,%eax
  801bb4:	75 e2                	jne    801b98 <vprintfmt+0x14>
  801bb6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bba:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bc1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bc8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	eb 07                	jmp    801bdd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801bd9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bdd:	8d 47 01             	lea    0x1(%edi),%eax
  801be0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801be3:	0f b6 07             	movzbl (%edi),%eax
  801be6:	0f b6 c8             	movzbl %al,%ecx
  801be9:	83 e8 23             	sub    $0x23,%eax
  801bec:	3c 55                	cmp    $0x55,%al
  801bee:	0f 87 21 03 00 00    	ja     801f15 <vprintfmt+0x391>
  801bf4:	0f b6 c0             	movzbl %al,%eax
  801bf7:	ff 24 85 80 3e 80 00 	jmp    *0x803e80(,%eax,4)
  801bfe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c01:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c05:	eb d6                	jmp    801bdd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c12:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c15:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c19:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c1c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c1f:	83 fa 09             	cmp    $0x9,%edx
  801c22:	77 39                	ja     801c5d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c24:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c27:	eb e9                	jmp    801c12 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c29:	8b 45 14             	mov    0x14(%ebp),%eax
  801c2c:	8d 48 04             	lea    0x4(%eax),%ecx
  801c2f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c32:	8b 00                	mov    (%eax),%eax
  801c34:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c3a:	eb 27                	jmp    801c63 <vprintfmt+0xdf>
  801c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c46:	0f 49 c8             	cmovns %eax,%ecx
  801c49:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c4f:	eb 8c                	jmp    801bdd <vprintfmt+0x59>
  801c51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c54:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c5b:	eb 80                	jmp    801bdd <vprintfmt+0x59>
  801c5d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c60:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c67:	0f 89 70 ff ff ff    	jns    801bdd <vprintfmt+0x59>
				width = precision, precision = -1;
  801c6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c73:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c7a:	e9 5e ff ff ff       	jmp    801bdd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c7f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c85:	e9 53 ff ff ff       	jmp    801bdd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8d:	8d 50 04             	lea    0x4(%eax),%edx
  801c90:	89 55 14             	mov    %edx,0x14(%ebp)
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	53                   	push   %ebx
  801c97:	ff 30                	pushl  (%eax)
  801c99:	ff d6                	call   *%esi
			break;
  801c9b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801ca1:	e9 04 ff ff ff       	jmp    801baa <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ca6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca9:	8d 50 04             	lea    0x4(%eax),%edx
  801cac:	89 55 14             	mov    %edx,0x14(%ebp)
  801caf:	8b 00                	mov    (%eax),%eax
  801cb1:	99                   	cltd   
  801cb2:	31 d0                	xor    %edx,%eax
  801cb4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cb6:	83 f8 0f             	cmp    $0xf,%eax
  801cb9:	7f 0b                	jg     801cc6 <vprintfmt+0x142>
  801cbb:	8b 14 85 00 40 80 00 	mov    0x804000(,%eax,4),%edx
  801cc2:	85 d2                	test   %edx,%edx
  801cc4:	75 18                	jne    801cde <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cc6:	50                   	push   %eax
  801cc7:	68 57 3d 80 00       	push   $0x803d57
  801ccc:	53                   	push   %ebx
  801ccd:	56                   	push   %esi
  801cce:	e8 94 fe ff ff       	call   801b67 <printfmt>
  801cd3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cd9:	e9 cc fe ff ff       	jmp    801baa <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cde:	52                   	push   %edx
  801cdf:	68 cf 37 80 00       	push   $0x8037cf
  801ce4:	53                   	push   %ebx
  801ce5:	56                   	push   %esi
  801ce6:	e8 7c fe ff ff       	call   801b67 <printfmt>
  801ceb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cf1:	e9 b4 fe ff ff       	jmp    801baa <vprintfmt+0x26>
  801cf6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cfc:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801cff:	8b 45 14             	mov    0x14(%ebp),%eax
  801d02:	8d 50 04             	lea    0x4(%eax),%edx
  801d05:	89 55 14             	mov    %edx,0x14(%ebp)
  801d08:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d0a:	85 ff                	test   %edi,%edi
  801d0c:	ba 50 3d 80 00       	mov    $0x803d50,%edx
  801d11:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801d14:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d18:	0f 84 92 00 00 00    	je     801db0 <vprintfmt+0x22c>
  801d1e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801d22:	0f 8e 96 00 00 00    	jle    801dbe <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d28:	83 ec 08             	sub    $0x8,%esp
  801d2b:	51                   	push   %ecx
  801d2c:	57                   	push   %edi
  801d2d:	e8 86 02 00 00       	call   801fb8 <strnlen>
  801d32:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d35:	29 c1                	sub    %eax,%ecx
  801d37:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d3a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d3d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d44:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d47:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d49:	eb 0f                	jmp    801d5a <vprintfmt+0x1d6>
					putch(padc, putdat);
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	53                   	push   %ebx
  801d4f:	ff 75 e0             	pushl  -0x20(%ebp)
  801d52:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d54:	83 ef 01             	sub    $0x1,%edi
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 ff                	test   %edi,%edi
  801d5c:	7f ed                	jg     801d4b <vprintfmt+0x1c7>
  801d5e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d61:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6b:	0f 49 c1             	cmovns %ecx,%eax
  801d6e:	29 c1                	sub    %eax,%ecx
  801d70:	89 75 08             	mov    %esi,0x8(%ebp)
  801d73:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d76:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d79:	89 cb                	mov    %ecx,%ebx
  801d7b:	eb 4d                	jmp    801dca <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d81:	74 1b                	je     801d9e <vprintfmt+0x21a>
  801d83:	0f be c0             	movsbl %al,%eax
  801d86:	83 e8 20             	sub    $0x20,%eax
  801d89:	83 f8 5e             	cmp    $0x5e,%eax
  801d8c:	76 10                	jbe    801d9e <vprintfmt+0x21a>
					putch('?', putdat);
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	6a 3f                	push   $0x3f
  801d96:	ff 55 08             	call   *0x8(%ebp)
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	eb 0d                	jmp    801dab <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	ff 75 0c             	pushl  0xc(%ebp)
  801da4:	52                   	push   %edx
  801da5:	ff 55 08             	call   *0x8(%ebp)
  801da8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801dab:	83 eb 01             	sub    $0x1,%ebx
  801dae:	eb 1a                	jmp    801dca <vprintfmt+0x246>
  801db0:	89 75 08             	mov    %esi,0x8(%ebp)
  801db3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801db6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801db9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dbc:	eb 0c                	jmp    801dca <vprintfmt+0x246>
  801dbe:	89 75 08             	mov    %esi,0x8(%ebp)
  801dc1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dc4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dca:	83 c7 01             	add    $0x1,%edi
  801dcd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801dd1:	0f be d0             	movsbl %al,%edx
  801dd4:	85 d2                	test   %edx,%edx
  801dd6:	74 23                	je     801dfb <vprintfmt+0x277>
  801dd8:	85 f6                	test   %esi,%esi
  801dda:	78 a1                	js     801d7d <vprintfmt+0x1f9>
  801ddc:	83 ee 01             	sub    $0x1,%esi
  801ddf:	79 9c                	jns    801d7d <vprintfmt+0x1f9>
  801de1:	89 df                	mov    %ebx,%edi
  801de3:	8b 75 08             	mov    0x8(%ebp),%esi
  801de6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801de9:	eb 18                	jmp    801e03 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801deb:	83 ec 08             	sub    $0x8,%esp
  801dee:	53                   	push   %ebx
  801def:	6a 20                	push   $0x20
  801df1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801df3:	83 ef 01             	sub    $0x1,%edi
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	eb 08                	jmp    801e03 <vprintfmt+0x27f>
  801dfb:	89 df                	mov    %ebx,%edi
  801dfd:	8b 75 08             	mov    0x8(%ebp),%esi
  801e00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e03:	85 ff                	test   %edi,%edi
  801e05:	7f e4                	jg     801deb <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e0a:	e9 9b fd ff ff       	jmp    801baa <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e0f:	83 fa 01             	cmp    $0x1,%edx
  801e12:	7e 16                	jle    801e2a <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801e14:	8b 45 14             	mov    0x14(%ebp),%eax
  801e17:	8d 50 08             	lea    0x8(%eax),%edx
  801e1a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e1d:	8b 50 04             	mov    0x4(%eax),%edx
  801e20:	8b 00                	mov    (%eax),%eax
  801e22:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e25:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e28:	eb 32                	jmp    801e5c <vprintfmt+0x2d8>
	else if (lflag)
  801e2a:	85 d2                	test   %edx,%edx
  801e2c:	74 18                	je     801e46 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801e2e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e31:	8d 50 04             	lea    0x4(%eax),%edx
  801e34:	89 55 14             	mov    %edx,0x14(%ebp)
  801e37:	8b 00                	mov    (%eax),%eax
  801e39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e3c:	89 c1                	mov    %eax,%ecx
  801e3e:	c1 f9 1f             	sar    $0x1f,%ecx
  801e41:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e44:	eb 16                	jmp    801e5c <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801e46:	8b 45 14             	mov    0x14(%ebp),%eax
  801e49:	8d 50 04             	lea    0x4(%eax),%edx
  801e4c:	89 55 14             	mov    %edx,0x14(%ebp)
  801e4f:	8b 00                	mov    (%eax),%eax
  801e51:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e54:	89 c1                	mov    %eax,%ecx
  801e56:	c1 f9 1f             	sar    $0x1f,%ecx
  801e59:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e62:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e67:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e6b:	79 74                	jns    801ee1 <vprintfmt+0x35d>
				putch('-', putdat);
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	53                   	push   %ebx
  801e71:	6a 2d                	push   $0x2d
  801e73:	ff d6                	call   *%esi
				num = -(long long) num;
  801e75:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e78:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e7b:	f7 d8                	neg    %eax
  801e7d:	83 d2 00             	adc    $0x0,%edx
  801e80:	f7 da                	neg    %edx
  801e82:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e85:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e8a:	eb 55                	jmp    801ee1 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e8c:	8d 45 14             	lea    0x14(%ebp),%eax
  801e8f:	e8 7c fc ff ff       	call   801b10 <getuint>
			base = 10;
  801e94:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e99:	eb 46                	jmp    801ee1 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801e9b:	8d 45 14             	lea    0x14(%ebp),%eax
  801e9e:	e8 6d fc ff ff       	call   801b10 <getuint>
                        base = 8;
  801ea3:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ea8:	eb 37                	jmp    801ee1 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	53                   	push   %ebx
  801eae:	6a 30                	push   $0x30
  801eb0:	ff d6                	call   *%esi
			putch('x', putdat);
  801eb2:	83 c4 08             	add    $0x8,%esp
  801eb5:	53                   	push   %ebx
  801eb6:	6a 78                	push   $0x78
  801eb8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801eba:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebd:	8d 50 04             	lea    0x4(%eax),%edx
  801ec0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ec3:	8b 00                	mov    (%eax),%eax
  801ec5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801eca:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ecd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ed2:	eb 0d                	jmp    801ee1 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ed4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ed7:	e8 34 fc ff ff       	call   801b10 <getuint>
			base = 16;
  801edc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ee8:	57                   	push   %edi
  801ee9:	ff 75 e0             	pushl  -0x20(%ebp)
  801eec:	51                   	push   %ecx
  801eed:	52                   	push   %edx
  801eee:	50                   	push   %eax
  801eef:	89 da                	mov    %ebx,%edx
  801ef1:	89 f0                	mov    %esi,%eax
  801ef3:	e8 6e fb ff ff       	call   801a66 <printnum>
			break;
  801ef8:	83 c4 20             	add    $0x20,%esp
  801efb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801efe:	e9 a7 fc ff ff       	jmp    801baa <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	53                   	push   %ebx
  801f07:	51                   	push   %ecx
  801f08:	ff d6                	call   *%esi
			break;
  801f0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f10:	e9 95 fc ff ff       	jmp    801baa <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	53                   	push   %ebx
  801f19:	6a 25                	push   $0x25
  801f1b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	eb 03                	jmp    801f25 <vprintfmt+0x3a1>
  801f22:	83 ef 01             	sub    $0x1,%edi
  801f25:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f29:	75 f7                	jne    801f22 <vprintfmt+0x39e>
  801f2b:	e9 7a fc ff ff       	jmp    801baa <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 18             	sub    $0x18,%esp
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f44:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f47:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f4b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 26                	je     801f7f <vsnprintf+0x47>
  801f59:	85 d2                	test   %edx,%edx
  801f5b:	7e 22                	jle    801f7f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f5d:	ff 75 14             	pushl  0x14(%ebp)
  801f60:	ff 75 10             	pushl  0x10(%ebp)
  801f63:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f66:	50                   	push   %eax
  801f67:	68 4a 1b 80 00       	push   $0x801b4a
  801f6c:	e8 13 fc ff ff       	call   801b84 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f74:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	eb 05                	jmp    801f84 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f8c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f8f:	50                   	push   %eax
  801f90:	ff 75 10             	pushl  0x10(%ebp)
  801f93:	ff 75 0c             	pushl  0xc(%ebp)
  801f96:	ff 75 08             	pushl  0x8(%ebp)
  801f99:	e8 9a ff ff ff       	call   801f38 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fab:	eb 03                	jmp    801fb0 <strlen+0x10>
		n++;
  801fad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fb0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fb4:	75 f7                	jne    801fad <strlen+0xd>
		n++;
	return n;
}
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc6:	eb 03                	jmp    801fcb <strnlen+0x13>
		n++;
  801fc8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fcb:	39 c2                	cmp    %eax,%edx
  801fcd:	74 08                	je     801fd7 <strnlen+0x1f>
  801fcf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801fd3:	75 f3                	jne    801fc8 <strnlen+0x10>
  801fd5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	53                   	push   %ebx
  801fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801fe3:	89 c2                	mov    %eax,%edx
  801fe5:	83 c2 01             	add    $0x1,%edx
  801fe8:	83 c1 01             	add    $0x1,%ecx
  801feb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801fef:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ff2:	84 db                	test   %bl,%bl
  801ff4:	75 ef                	jne    801fe5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ff6:	5b                   	pop    %ebx
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	53                   	push   %ebx
  801ffd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802000:	53                   	push   %ebx
  802001:	e8 9a ff ff ff       	call   801fa0 <strlen>
  802006:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802009:	ff 75 0c             	pushl  0xc(%ebp)
  80200c:	01 d8                	add    %ebx,%eax
  80200e:	50                   	push   %eax
  80200f:	e8 c5 ff ff ff       	call   801fd9 <strcpy>
	return dst;
}
  802014:	89 d8                	mov    %ebx,%eax
  802016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802019:	c9                   	leave  
  80201a:	c3                   	ret    

0080201b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	8b 75 08             	mov    0x8(%ebp),%esi
  802023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802026:	89 f3                	mov    %esi,%ebx
  802028:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	eb 0f                	jmp    80203e <strncpy+0x23>
		*dst++ = *src;
  80202f:	83 c2 01             	add    $0x1,%edx
  802032:	0f b6 01             	movzbl (%ecx),%eax
  802035:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802038:	80 39 01             	cmpb   $0x1,(%ecx)
  80203b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80203e:	39 da                	cmp    %ebx,%edx
  802040:	75 ed                	jne    80202f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802042:	89 f0                	mov    %esi,%eax
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	8b 75 08             	mov    0x8(%ebp),%esi
  802050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802053:	8b 55 10             	mov    0x10(%ebp),%edx
  802056:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802058:	85 d2                	test   %edx,%edx
  80205a:	74 21                	je     80207d <strlcpy+0x35>
  80205c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802060:	89 f2                	mov    %esi,%edx
  802062:	eb 09                	jmp    80206d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802064:	83 c2 01             	add    $0x1,%edx
  802067:	83 c1 01             	add    $0x1,%ecx
  80206a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80206d:	39 c2                	cmp    %eax,%edx
  80206f:	74 09                	je     80207a <strlcpy+0x32>
  802071:	0f b6 19             	movzbl (%ecx),%ebx
  802074:	84 db                	test   %bl,%bl
  802076:	75 ec                	jne    802064 <strlcpy+0x1c>
  802078:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80207a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80207d:	29 f0                	sub    %esi,%eax
}
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802089:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80208c:	eb 06                	jmp    802094 <strcmp+0x11>
		p++, q++;
  80208e:	83 c1 01             	add    $0x1,%ecx
  802091:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802094:	0f b6 01             	movzbl (%ecx),%eax
  802097:	84 c0                	test   %al,%al
  802099:	74 04                	je     80209f <strcmp+0x1c>
  80209b:	3a 02                	cmp    (%edx),%al
  80209d:	74 ef                	je     80208e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80209f:	0f b6 c0             	movzbl %al,%eax
  8020a2:	0f b6 12             	movzbl (%edx),%edx
  8020a5:	29 d0                	sub    %edx,%eax
}
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	53                   	push   %ebx
  8020ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b3:	89 c3                	mov    %eax,%ebx
  8020b5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020b8:	eb 06                	jmp    8020c0 <strncmp+0x17>
		n--, p++, q++;
  8020ba:	83 c0 01             	add    $0x1,%eax
  8020bd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020c0:	39 d8                	cmp    %ebx,%eax
  8020c2:	74 15                	je     8020d9 <strncmp+0x30>
  8020c4:	0f b6 08             	movzbl (%eax),%ecx
  8020c7:	84 c9                	test   %cl,%cl
  8020c9:	74 04                	je     8020cf <strncmp+0x26>
  8020cb:	3a 0a                	cmp    (%edx),%cl
  8020cd:	74 eb                	je     8020ba <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020cf:	0f b6 00             	movzbl (%eax),%eax
  8020d2:	0f b6 12             	movzbl (%edx),%edx
  8020d5:	29 d0                	sub    %edx,%eax
  8020d7:	eb 05                	jmp    8020de <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8020de:	5b                   	pop    %ebx
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    

008020e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020eb:	eb 07                	jmp    8020f4 <strchr+0x13>
		if (*s == c)
  8020ed:	38 ca                	cmp    %cl,%dl
  8020ef:	74 0f                	je     802100 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020f1:	83 c0 01             	add    $0x1,%eax
  8020f4:	0f b6 10             	movzbl (%eax),%edx
  8020f7:	84 d2                	test   %dl,%dl
  8020f9:	75 f2                	jne    8020ed <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    

00802102 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	8b 45 08             	mov    0x8(%ebp),%eax
  802108:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80210c:	eb 03                	jmp    802111 <strfind+0xf>
  80210e:	83 c0 01             	add    $0x1,%eax
  802111:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802114:	84 d2                	test   %dl,%dl
  802116:	74 04                	je     80211c <strfind+0x1a>
  802118:	38 ca                	cmp    %cl,%dl
  80211a:	75 f2                	jne    80210e <strfind+0xc>
			break;
	return (char *) s;
}
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    

0080211e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	8b 7d 08             	mov    0x8(%ebp),%edi
  802127:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80212a:	85 c9                	test   %ecx,%ecx
  80212c:	74 36                	je     802164 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80212e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802134:	75 28                	jne    80215e <memset+0x40>
  802136:	f6 c1 03             	test   $0x3,%cl
  802139:	75 23                	jne    80215e <memset+0x40>
		c &= 0xFF;
  80213b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80213f:	89 d3                	mov    %edx,%ebx
  802141:	c1 e3 08             	shl    $0x8,%ebx
  802144:	89 d6                	mov    %edx,%esi
  802146:	c1 e6 18             	shl    $0x18,%esi
  802149:	89 d0                	mov    %edx,%eax
  80214b:	c1 e0 10             	shl    $0x10,%eax
  80214e:	09 f0                	or     %esi,%eax
  802150:	09 c2                	or     %eax,%edx
  802152:	89 d0                	mov    %edx,%eax
  802154:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802156:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802159:	fc                   	cld    
  80215a:	f3 ab                	rep stos %eax,%es:(%edi)
  80215c:	eb 06                	jmp    802164 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80215e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802161:	fc                   	cld    
  802162:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802164:	89 f8                	mov    %edi,%eax
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5f                   	pop    %edi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	57                   	push   %edi
  80216f:	56                   	push   %esi
  802170:	8b 45 08             	mov    0x8(%ebp),%eax
  802173:	8b 75 0c             	mov    0xc(%ebp),%esi
  802176:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 35                	jae    8021b2 <memmove+0x47>
  80217d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802180:	39 d0                	cmp    %edx,%eax
  802182:	73 2e                	jae    8021b2 <memmove+0x47>
		s += n;
		d += n;
  802184:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802187:	89 d6                	mov    %edx,%esi
  802189:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80218b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802191:	75 13                	jne    8021a6 <memmove+0x3b>
  802193:	f6 c1 03             	test   $0x3,%cl
  802196:	75 0e                	jne    8021a6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802198:	83 ef 04             	sub    $0x4,%edi
  80219b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80219e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8021a1:	fd                   	std    
  8021a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021a4:	eb 09                	jmp    8021af <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8021a6:	83 ef 01             	sub    $0x1,%edi
  8021a9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021ac:	fd                   	std    
  8021ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021af:	fc                   	cld    
  8021b0:	eb 1d                	jmp    8021cf <memmove+0x64>
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b6:	f6 c2 03             	test   $0x3,%dl
  8021b9:	75 0f                	jne    8021ca <memmove+0x5f>
  8021bb:	f6 c1 03             	test   $0x3,%cl
  8021be:	75 0a                	jne    8021ca <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8021c0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8021c3:	89 c7                	mov    %eax,%edi
  8021c5:	fc                   	cld    
  8021c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021c8:	eb 05                	jmp    8021cf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021ca:	89 c7                	mov    %eax,%edi
  8021cc:	fc                   	cld    
  8021cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8021d6:	ff 75 10             	pushl  0x10(%ebp)
  8021d9:	ff 75 0c             	pushl  0xc(%ebp)
  8021dc:	ff 75 08             	pushl  0x8(%ebp)
  8021df:	e8 87 ff ff ff       	call   80216b <memmove>
}
  8021e4:	c9                   	leave  
  8021e5:	c3                   	ret    

008021e6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	56                   	push   %esi
  8021ea:	53                   	push   %ebx
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f1:	89 c6                	mov    %eax,%esi
  8021f3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8021f6:	eb 1a                	jmp    802212 <memcmp+0x2c>
		if (*s1 != *s2)
  8021f8:	0f b6 08             	movzbl (%eax),%ecx
  8021fb:	0f b6 1a             	movzbl (%edx),%ebx
  8021fe:	38 d9                	cmp    %bl,%cl
  802200:	74 0a                	je     80220c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802202:	0f b6 c1             	movzbl %cl,%eax
  802205:	0f b6 db             	movzbl %bl,%ebx
  802208:	29 d8                	sub    %ebx,%eax
  80220a:	eb 0f                	jmp    80221b <memcmp+0x35>
		s1++, s2++;
  80220c:	83 c0 01             	add    $0x1,%eax
  80220f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802212:	39 f0                	cmp    %esi,%eax
  802214:	75 e2                	jne    8021f8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802216:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	8b 45 08             	mov    0x8(%ebp),%eax
  802225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802228:	89 c2                	mov    %eax,%edx
  80222a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80222d:	eb 07                	jmp    802236 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80222f:	38 08                	cmp    %cl,(%eax)
  802231:	74 07                	je     80223a <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802233:	83 c0 01             	add    $0x1,%eax
  802236:	39 d0                	cmp    %edx,%eax
  802238:	72 f5                	jb     80222f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    

0080223c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	57                   	push   %edi
  802240:	56                   	push   %esi
  802241:	53                   	push   %ebx
  802242:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802245:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802248:	eb 03                	jmp    80224d <strtol+0x11>
		s++;
  80224a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80224d:	0f b6 01             	movzbl (%ecx),%eax
  802250:	3c 09                	cmp    $0x9,%al
  802252:	74 f6                	je     80224a <strtol+0xe>
  802254:	3c 20                	cmp    $0x20,%al
  802256:	74 f2                	je     80224a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802258:	3c 2b                	cmp    $0x2b,%al
  80225a:	75 0a                	jne    802266 <strtol+0x2a>
		s++;
  80225c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80225f:	bf 00 00 00 00       	mov    $0x0,%edi
  802264:	eb 10                	jmp    802276 <strtol+0x3a>
  802266:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80226b:	3c 2d                	cmp    $0x2d,%al
  80226d:	75 07                	jne    802276 <strtol+0x3a>
		s++, neg = 1;
  80226f:	8d 49 01             	lea    0x1(%ecx),%ecx
  802272:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802276:	85 db                	test   %ebx,%ebx
  802278:	0f 94 c0             	sete   %al
  80227b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802281:	75 19                	jne    80229c <strtol+0x60>
  802283:	80 39 30             	cmpb   $0x30,(%ecx)
  802286:	75 14                	jne    80229c <strtol+0x60>
  802288:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80228c:	0f 85 82 00 00 00    	jne    802314 <strtol+0xd8>
		s += 2, base = 16;
  802292:	83 c1 02             	add    $0x2,%ecx
  802295:	bb 10 00 00 00       	mov    $0x10,%ebx
  80229a:	eb 16                	jmp    8022b2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80229c:	84 c0                	test   %al,%al
  80229e:	74 12                	je     8022b2 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022a0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022a5:	80 39 30             	cmpb   $0x30,(%ecx)
  8022a8:	75 08                	jne    8022b2 <strtol+0x76>
		s++, base = 8;
  8022aa:	83 c1 01             	add    $0x1,%ecx
  8022ad:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022ba:	0f b6 11             	movzbl (%ecx),%edx
  8022bd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022c0:	89 f3                	mov    %esi,%ebx
  8022c2:	80 fb 09             	cmp    $0x9,%bl
  8022c5:	77 08                	ja     8022cf <strtol+0x93>
			dig = *s - '0';
  8022c7:	0f be d2             	movsbl %dl,%edx
  8022ca:	83 ea 30             	sub    $0x30,%edx
  8022cd:	eb 22                	jmp    8022f1 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8022cf:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022d2:	89 f3                	mov    %esi,%ebx
  8022d4:	80 fb 19             	cmp    $0x19,%bl
  8022d7:	77 08                	ja     8022e1 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8022d9:	0f be d2             	movsbl %dl,%edx
  8022dc:	83 ea 57             	sub    $0x57,%edx
  8022df:	eb 10                	jmp    8022f1 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8022e1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8022e4:	89 f3                	mov    %esi,%ebx
  8022e6:	80 fb 19             	cmp    $0x19,%bl
  8022e9:	77 16                	ja     802301 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8022eb:	0f be d2             	movsbl %dl,%edx
  8022ee:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8022f1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8022f4:	7d 0f                	jge    802305 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8022f6:	83 c1 01             	add    $0x1,%ecx
  8022f9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8022fd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8022ff:	eb b9                	jmp    8022ba <strtol+0x7e>
  802301:	89 c2                	mov    %eax,%edx
  802303:	eb 02                	jmp    802307 <strtol+0xcb>
  802305:	89 c2                	mov    %eax,%edx

	if (endptr)
  802307:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80230b:	74 0d                	je     80231a <strtol+0xde>
		*endptr = (char *) s;
  80230d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802310:	89 0e                	mov    %ecx,(%esi)
  802312:	eb 06                	jmp    80231a <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802314:	84 c0                	test   %al,%al
  802316:	75 92                	jne    8022aa <strtol+0x6e>
  802318:	eb 98                	jmp    8022b2 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80231a:	f7 da                	neg    %edx
  80231c:	85 ff                	test   %edi,%edi
  80231e:	0f 45 c2             	cmovne %edx,%eax
}
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    

00802326 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802326:	55                   	push   %ebp
  802327:	89 e5                	mov    %esp,%ebp
  802329:	57                   	push   %edi
  80232a:	56                   	push   %esi
  80232b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80232c:	b8 00 00 00 00       	mov    $0x0,%eax
  802331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802334:	8b 55 08             	mov    0x8(%ebp),%edx
  802337:	89 c3                	mov    %eax,%ebx
  802339:	89 c7                	mov    %eax,%edi
  80233b:	89 c6                	mov    %eax,%esi
  80233d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80233f:	5b                   	pop    %ebx
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    

00802344 <sys_cgetc>:

int
sys_cgetc(void)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	57                   	push   %edi
  802348:	56                   	push   %esi
  802349:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80234a:	ba 00 00 00 00       	mov    $0x0,%edx
  80234f:	b8 01 00 00 00       	mov    $0x1,%eax
  802354:	89 d1                	mov    %edx,%ecx
  802356:	89 d3                	mov    %edx,%ebx
  802358:	89 d7                	mov    %edx,%edi
  80235a:	89 d6                	mov    %edx,%esi
  80235c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80235e:	5b                   	pop    %ebx
  80235f:	5e                   	pop    %esi
  802360:	5f                   	pop    %edi
  802361:	5d                   	pop    %ebp
  802362:	c3                   	ret    

00802363 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802363:	55                   	push   %ebp
  802364:	89 e5                	mov    %esp,%ebp
  802366:	57                   	push   %edi
  802367:	56                   	push   %esi
  802368:	53                   	push   %ebx
  802369:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80236c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802371:	b8 03 00 00 00       	mov    $0x3,%eax
  802376:	8b 55 08             	mov    0x8(%ebp),%edx
  802379:	89 cb                	mov    %ecx,%ebx
  80237b:	89 cf                	mov    %ecx,%edi
  80237d:	89 ce                	mov    %ecx,%esi
  80237f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802381:	85 c0                	test   %eax,%eax
  802383:	7e 17                	jle    80239c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802385:	83 ec 0c             	sub    $0xc,%esp
  802388:	50                   	push   %eax
  802389:	6a 03                	push   $0x3
  80238b:	68 5f 40 80 00       	push   $0x80405f
  802390:	6a 23                	push   $0x23
  802392:	68 7c 40 80 00       	push   $0x80407c
  802397:	e8 dd f5 ff ff       	call   801979 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80239c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	57                   	push   %edi
  8023a8:	56                   	push   %esi
  8023a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8023af:	b8 02 00 00 00       	mov    $0x2,%eax
  8023b4:	89 d1                	mov    %edx,%ecx
  8023b6:	89 d3                	mov    %edx,%ebx
  8023b8:	89 d7                	mov    %edx,%edi
  8023ba:	89 d6                	mov    %edx,%esi
  8023bc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023be:	5b                   	pop    %ebx
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    

008023c3 <sys_yield>:

void
sys_yield(void)
{
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	57                   	push   %edi
  8023c7:	56                   	push   %esi
  8023c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ce:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023d3:	89 d1                	mov    %edx,%ecx
  8023d5:	89 d3                	mov    %edx,%ebx
  8023d7:	89 d7                	mov    %edx,%edi
  8023d9:	89 d6                	mov    %edx,%esi
  8023db:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    

008023e2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	53                   	push   %ebx
  8023e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023eb:	be 00 00 00 00       	mov    $0x0,%esi
  8023f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8023f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8023fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023fe:	89 f7                	mov    %esi,%edi
  802400:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802402:	85 c0                	test   %eax,%eax
  802404:	7e 17                	jle    80241d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802406:	83 ec 0c             	sub    $0xc,%esp
  802409:	50                   	push   %eax
  80240a:	6a 04                	push   $0x4
  80240c:	68 5f 40 80 00       	push   $0x80405f
  802411:	6a 23                	push   $0x23
  802413:	68 7c 40 80 00       	push   $0x80407c
  802418:	e8 5c f5 ff ff       	call   801979 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80241d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	57                   	push   %edi
  802429:	56                   	push   %esi
  80242a:	53                   	push   %ebx
  80242b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80242e:	b8 05 00 00 00       	mov    $0x5,%eax
  802433:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802436:	8b 55 08             	mov    0x8(%ebp),%edx
  802439:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80243c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80243f:	8b 75 18             	mov    0x18(%ebp),%esi
  802442:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802444:	85 c0                	test   %eax,%eax
  802446:	7e 17                	jle    80245f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802448:	83 ec 0c             	sub    $0xc,%esp
  80244b:	50                   	push   %eax
  80244c:	6a 05                	push   $0x5
  80244e:	68 5f 40 80 00       	push   $0x80405f
  802453:	6a 23                	push   $0x23
  802455:	68 7c 40 80 00       	push   $0x80407c
  80245a:	e8 1a f5 ff ff       	call   801979 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80245f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802462:	5b                   	pop    %ebx
  802463:	5e                   	pop    %esi
  802464:	5f                   	pop    %edi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	57                   	push   %edi
  80246b:	56                   	push   %esi
  80246c:	53                   	push   %ebx
  80246d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802470:	bb 00 00 00 00       	mov    $0x0,%ebx
  802475:	b8 06 00 00 00       	mov    $0x6,%eax
  80247a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80247d:	8b 55 08             	mov    0x8(%ebp),%edx
  802480:	89 df                	mov    %ebx,%edi
  802482:	89 de                	mov    %ebx,%esi
  802484:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802486:	85 c0                	test   %eax,%eax
  802488:	7e 17                	jle    8024a1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80248a:	83 ec 0c             	sub    $0xc,%esp
  80248d:	50                   	push   %eax
  80248e:	6a 06                	push   $0x6
  802490:	68 5f 40 80 00       	push   $0x80405f
  802495:	6a 23                	push   $0x23
  802497:	68 7c 40 80 00       	push   $0x80407c
  80249c:	e8 d8 f4 ff ff       	call   801979 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    

008024a9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024a9:	55                   	push   %ebp
  8024aa:	89 e5                	mov    %esp,%ebp
  8024ac:	57                   	push   %edi
  8024ad:	56                   	push   %esi
  8024ae:	53                   	push   %ebx
  8024af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8024bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8024c2:	89 df                	mov    %ebx,%edi
  8024c4:	89 de                	mov    %ebx,%esi
  8024c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	7e 17                	jle    8024e3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024cc:	83 ec 0c             	sub    $0xc,%esp
  8024cf:	50                   	push   %eax
  8024d0:	6a 08                	push   $0x8
  8024d2:	68 5f 40 80 00       	push   $0x80405f
  8024d7:	6a 23                	push   $0x23
  8024d9:	68 7c 40 80 00       	push   $0x80407c
  8024de:	e8 96 f4 ff ff       	call   801979 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  8024e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e6:	5b                   	pop    %ebx
  8024e7:	5e                   	pop    %esi
  8024e8:	5f                   	pop    %edi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    

008024eb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8024eb:	55                   	push   %ebp
  8024ec:	89 e5                	mov    %esp,%ebp
  8024ee:	57                   	push   %edi
  8024ef:	56                   	push   %esi
  8024f0:	53                   	push   %ebx
  8024f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8024fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802501:	8b 55 08             	mov    0x8(%ebp),%edx
  802504:	89 df                	mov    %ebx,%edi
  802506:	89 de                	mov    %ebx,%esi
  802508:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80250a:	85 c0                	test   %eax,%eax
  80250c:	7e 17                	jle    802525 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80250e:	83 ec 0c             	sub    $0xc,%esp
  802511:	50                   	push   %eax
  802512:	6a 09                	push   $0x9
  802514:	68 5f 40 80 00       	push   $0x80405f
  802519:	6a 23                	push   $0x23
  80251b:	68 7c 40 80 00       	push   $0x80407c
  802520:	e8 54 f4 ff ff       	call   801979 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802528:	5b                   	pop    %ebx
  802529:	5e                   	pop    %esi
  80252a:	5f                   	pop    %edi
  80252b:	5d                   	pop    %ebp
  80252c:	c3                   	ret    

0080252d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80252d:	55                   	push   %ebp
  80252e:	89 e5                	mov    %esp,%ebp
  802530:	57                   	push   %edi
  802531:	56                   	push   %esi
  802532:	53                   	push   %ebx
  802533:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802536:	bb 00 00 00 00       	mov    $0x0,%ebx
  80253b:	b8 0a 00 00 00       	mov    $0xa,%eax
  802540:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802543:	8b 55 08             	mov    0x8(%ebp),%edx
  802546:	89 df                	mov    %ebx,%edi
  802548:	89 de                	mov    %ebx,%esi
  80254a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80254c:	85 c0                	test   %eax,%eax
  80254e:	7e 17                	jle    802567 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802550:	83 ec 0c             	sub    $0xc,%esp
  802553:	50                   	push   %eax
  802554:	6a 0a                	push   $0xa
  802556:	68 5f 40 80 00       	push   $0x80405f
  80255b:	6a 23                	push   $0x23
  80255d:	68 7c 40 80 00       	push   $0x80407c
  802562:	e8 12 f4 ff ff       	call   801979 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802567:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256a:	5b                   	pop    %ebx
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    

0080256f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	57                   	push   %edi
  802573:	56                   	push   %esi
  802574:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802575:	be 00 00 00 00       	mov    $0x0,%esi
  80257a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80257f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802582:	8b 55 08             	mov    0x8(%ebp),%edx
  802585:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802588:	8b 7d 14             	mov    0x14(%ebp),%edi
  80258b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    

00802592 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
  802595:	57                   	push   %edi
  802596:	56                   	push   %esi
  802597:	53                   	push   %ebx
  802598:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80259b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025a0:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a8:	89 cb                	mov    %ecx,%ebx
  8025aa:	89 cf                	mov    %ecx,%edi
  8025ac:	89 ce                	mov    %ecx,%esi
  8025ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025b0:	85 c0                	test   %eax,%eax
  8025b2:	7e 17                	jle    8025cb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b4:	83 ec 0c             	sub    $0xc,%esp
  8025b7:	50                   	push   %eax
  8025b8:	6a 0d                	push   $0xd
  8025ba:	68 5f 40 80 00       	push   $0x80405f
  8025bf:	6a 23                	push   $0x23
  8025c1:	68 7c 40 80 00       	push   $0x80407c
  8025c6:	e8 ae f3 ff ff       	call   801979 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ce:	5b                   	pop    %ebx
  8025cf:	5e                   	pop    %esi
  8025d0:	5f                   	pop    %edi
  8025d1:	5d                   	pop    %ebp
  8025d2:	c3                   	ret    

008025d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025d3:	55                   	push   %ebp
  8025d4:	89 e5                	mov    %esp,%ebp
  8025d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025d9:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8025e0:	75 2c                	jne    80260e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  8025e2:	83 ec 04             	sub    $0x4,%esp
  8025e5:	6a 07                	push   $0x7
  8025e7:	68 00 f0 bf ee       	push   $0xeebff000
  8025ec:	6a 00                	push   $0x0
  8025ee:	e8 ef fd ff ff       	call   8023e2 <sys_page_alloc>
  8025f3:	83 c4 10             	add    $0x10,%esp
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	74 14                	je     80260e <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  8025fa:	83 ec 04             	sub    $0x4,%esp
  8025fd:	68 8c 40 80 00       	push   $0x80408c
  802602:	6a 21                	push   $0x21
  802604:	68 ee 40 80 00       	push   $0x8040ee
  802609:	e8 6b f3 ff ff       	call   801979 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80260e:	8b 45 08             	mov    0x8(%ebp),%eax
  802611:	a3 10 a0 80 00       	mov    %eax,0x80a010
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802616:	83 ec 08             	sub    $0x8,%esp
  802619:	68 42 26 80 00       	push   $0x802642
  80261e:	6a 00                	push   $0x0
  802620:	e8 08 ff ff ff       	call   80252d <sys_env_set_pgfault_upcall>
  802625:	83 c4 10             	add    $0x10,%esp
  802628:	85 c0                	test   %eax,%eax
  80262a:	79 14                	jns    802640 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80262c:	83 ec 04             	sub    $0x4,%esp
  80262f:	68 b8 40 80 00       	push   $0x8040b8
  802634:	6a 29                	push   $0x29
  802636:	68 ee 40 80 00       	push   $0x8040ee
  80263b:	e8 39 f3 ff ff       	call   801979 <_panic>
}
  802640:	c9                   	leave  
  802641:	c3                   	ret    

00802642 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802642:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802643:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802648:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80264a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80264d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  802652:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  802656:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80265a:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80265c:	83 c4 08             	add    $0x8,%esp
        popal
  80265f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802660:	83 c4 04             	add    $0x4,%esp
        popfl
  802663:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  802664:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802665:	c3                   	ret    

00802666 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	56                   	push   %esi
  80266a:	53                   	push   %ebx
  80266b:	8b 75 08             	mov    0x8(%ebp),%esi
  80266e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802671:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802674:	85 c0                	test   %eax,%eax
  802676:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80267b:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  80267e:	83 ec 0c             	sub    $0xc,%esp
  802681:	50                   	push   %eax
  802682:	e8 0b ff ff ff       	call   802592 <sys_ipc_recv>
  802687:	83 c4 10             	add    $0x10,%esp
  80268a:	85 c0                	test   %eax,%eax
  80268c:	79 16                	jns    8026a4 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  80268e:	85 f6                	test   %esi,%esi
  802690:	74 06                	je     802698 <ipc_recv+0x32>
  802692:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802698:	85 db                	test   %ebx,%ebx
  80269a:	74 2c                	je     8026c8 <ipc_recv+0x62>
  80269c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026a2:	eb 24                	jmp    8026c8 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8026a4:	85 f6                	test   %esi,%esi
  8026a6:	74 0a                	je     8026b2 <ipc_recv+0x4c>
  8026a8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026ad:	8b 40 74             	mov    0x74(%eax),%eax
  8026b0:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8026b2:	85 db                	test   %ebx,%ebx
  8026b4:	74 0a                	je     8026c0 <ipc_recv+0x5a>
  8026b6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026bb:	8b 40 78             	mov    0x78(%eax),%eax
  8026be:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  8026c0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026c5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026cb:	5b                   	pop    %ebx
  8026cc:	5e                   	pop    %esi
  8026cd:	5d                   	pop    %ebp
  8026ce:	c3                   	ret    

008026cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026cf:	55                   	push   %ebp
  8026d0:	89 e5                	mov    %esp,%ebp
  8026d2:	57                   	push   %edi
  8026d3:	56                   	push   %esi
  8026d4:	53                   	push   %ebx
  8026d5:	83 ec 0c             	sub    $0xc,%esp
  8026d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  8026e1:	85 db                	test   %ebx,%ebx
  8026e3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026e8:	0f 44 d8             	cmove  %eax,%ebx
  8026eb:	eb 1c                	jmp    802709 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8026ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026f0:	74 12                	je     802704 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8026f2:	50                   	push   %eax
  8026f3:	68 fc 40 80 00       	push   $0x8040fc
  8026f8:	6a 39                	push   $0x39
  8026fa:	68 17 41 80 00       	push   $0x804117
  8026ff:	e8 75 f2 ff ff       	call   801979 <_panic>
                 sys_yield();
  802704:	e8 ba fc ff ff       	call   8023c3 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802709:	ff 75 14             	pushl  0x14(%ebp)
  80270c:	53                   	push   %ebx
  80270d:	56                   	push   %esi
  80270e:	57                   	push   %edi
  80270f:	e8 5b fe ff ff       	call   80256f <sys_ipc_try_send>
  802714:	83 c4 10             	add    $0x10,%esp
  802717:	85 c0                	test   %eax,%eax
  802719:	78 d2                	js     8026ed <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80271b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80271e:	5b                   	pop    %ebx
  80271f:	5e                   	pop    %esi
  802720:	5f                   	pop    %edi
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    

00802723 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802723:	55                   	push   %ebp
  802724:	89 e5                	mov    %esp,%ebp
  802726:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802729:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80272e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802731:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802737:	8b 52 50             	mov    0x50(%edx),%edx
  80273a:	39 ca                	cmp    %ecx,%edx
  80273c:	75 0d                	jne    80274b <ipc_find_env+0x28>
			return envs[i].env_id;
  80273e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802741:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802746:	8b 40 08             	mov    0x8(%eax),%eax
  802749:	eb 0e                	jmp    802759 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80274b:	83 c0 01             	add    $0x1,%eax
  80274e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802753:	75 d9                	jne    80272e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802755:	66 b8 00 00          	mov    $0x0,%ax
}
  802759:	5d                   	pop    %ebp
  80275a:	c3                   	ret    

0080275b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80275b:	55                   	push   %ebp
  80275c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80275e:	8b 45 08             	mov    0x8(%ebp),%eax
  802761:	05 00 00 00 30       	add    $0x30000000,%eax
  802766:	c1 e8 0c             	shr    $0xc,%eax
}
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    

0080276b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80276b:	55                   	push   %ebp
  80276c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80276e:	8b 45 08             	mov    0x8(%ebp),%eax
  802771:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  802776:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80277b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802780:	5d                   	pop    %ebp
  802781:	c3                   	ret    

00802782 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802782:	55                   	push   %ebp
  802783:	89 e5                	mov    %esp,%ebp
  802785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802788:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80278d:	89 c2                	mov    %eax,%edx
  80278f:	c1 ea 16             	shr    $0x16,%edx
  802792:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802799:	f6 c2 01             	test   $0x1,%dl
  80279c:	74 11                	je     8027af <fd_alloc+0x2d>
  80279e:	89 c2                	mov    %eax,%edx
  8027a0:	c1 ea 0c             	shr    $0xc,%edx
  8027a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027aa:	f6 c2 01             	test   $0x1,%dl
  8027ad:	75 09                	jne    8027b8 <fd_alloc+0x36>
			*fd_store = fd;
  8027af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b6:	eb 17                	jmp    8027cf <fd_alloc+0x4d>
  8027b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8027bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8027c2:	75 c9                	jne    80278d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8027c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8027ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8027cf:	5d                   	pop    %ebp
  8027d0:	c3                   	ret    

008027d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8027d1:	55                   	push   %ebp
  8027d2:	89 e5                	mov    %esp,%ebp
  8027d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8027d7:	83 f8 1f             	cmp    $0x1f,%eax
  8027da:	77 36                	ja     802812 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8027dc:	c1 e0 0c             	shl    $0xc,%eax
  8027df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8027e4:	89 c2                	mov    %eax,%edx
  8027e6:	c1 ea 16             	shr    $0x16,%edx
  8027e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027f0:	f6 c2 01             	test   $0x1,%dl
  8027f3:	74 24                	je     802819 <fd_lookup+0x48>
  8027f5:	89 c2                	mov    %eax,%edx
  8027f7:	c1 ea 0c             	shr    $0xc,%edx
  8027fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802801:	f6 c2 01             	test   $0x1,%dl
  802804:	74 1a                	je     802820 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802806:	8b 55 0c             	mov    0xc(%ebp),%edx
  802809:	89 02                	mov    %eax,(%edx)
	return 0;
  80280b:	b8 00 00 00 00       	mov    $0x0,%eax
  802810:	eb 13                	jmp    802825 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802817:	eb 0c                	jmp    802825 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80281e:	eb 05                	jmp    802825 <fd_lookup+0x54>
  802820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802825:	5d                   	pop    %ebp
  802826:	c3                   	ret    

00802827 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802827:	55                   	push   %ebp
  802828:	89 e5                	mov    %esp,%ebp
  80282a:	83 ec 08             	sub    $0x8,%esp
  80282d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802830:	ba a4 41 80 00       	mov    $0x8041a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802835:	eb 13                	jmp    80284a <dev_lookup+0x23>
  802837:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80283a:	39 08                	cmp    %ecx,(%eax)
  80283c:	75 0c                	jne    80284a <dev_lookup+0x23>
			*dev = devtab[i];
  80283e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802841:	89 01                	mov    %eax,(%ecx)
			return 0;
  802843:	b8 00 00 00 00       	mov    $0x0,%eax
  802848:	eb 2e                	jmp    802878 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80284a:	8b 02                	mov    (%edx),%eax
  80284c:	85 c0                	test   %eax,%eax
  80284e:	75 e7                	jne    802837 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802850:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802855:	8b 40 48             	mov    0x48(%eax),%eax
  802858:	83 ec 04             	sub    $0x4,%esp
  80285b:	51                   	push   %ecx
  80285c:	50                   	push   %eax
  80285d:	68 24 41 80 00       	push   $0x804124
  802862:	e8 eb f1 ff ff       	call   801a52 <cprintf>
	*dev = 0;
  802867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80286a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802870:	83 c4 10             	add    $0x10,%esp
  802873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802878:	c9                   	leave  
  802879:	c3                   	ret    

0080287a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80287a:	55                   	push   %ebp
  80287b:	89 e5                	mov    %esp,%ebp
  80287d:	56                   	push   %esi
  80287e:	53                   	push   %ebx
  80287f:	83 ec 10             	sub    $0x10,%esp
  802882:	8b 75 08             	mov    0x8(%ebp),%esi
  802885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80288b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80288c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802892:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802895:	50                   	push   %eax
  802896:	e8 36 ff ff ff       	call   8027d1 <fd_lookup>
  80289b:	83 c4 08             	add    $0x8,%esp
  80289e:	85 c0                	test   %eax,%eax
  8028a0:	78 05                	js     8028a7 <fd_close+0x2d>
	    || fd != fd2)
  8028a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028a5:	74 0c                	je     8028b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8028a7:	84 db                	test   %bl,%bl
  8028a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8028ae:	0f 44 c2             	cmove  %edx,%eax
  8028b1:	eb 41                	jmp    8028f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028b3:	83 ec 08             	sub    $0x8,%esp
  8028b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028b9:	50                   	push   %eax
  8028ba:	ff 36                	pushl  (%esi)
  8028bc:	e8 66 ff ff ff       	call   802827 <dev_lookup>
  8028c1:	89 c3                	mov    %eax,%ebx
  8028c3:	83 c4 10             	add    $0x10,%esp
  8028c6:	85 c0                	test   %eax,%eax
  8028c8:	78 1a                	js     8028e4 <fd_close+0x6a>
		if (dev->dev_close)
  8028ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8028d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8028d5:	85 c0                	test   %eax,%eax
  8028d7:	74 0b                	je     8028e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8028d9:	83 ec 0c             	sub    $0xc,%esp
  8028dc:	56                   	push   %esi
  8028dd:	ff d0                	call   *%eax
  8028df:	89 c3                	mov    %eax,%ebx
  8028e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8028e4:	83 ec 08             	sub    $0x8,%esp
  8028e7:	56                   	push   %esi
  8028e8:	6a 00                	push   $0x0
  8028ea:	e8 78 fb ff ff       	call   802467 <sys_page_unmap>
	return r;
  8028ef:	83 c4 10             	add    $0x10,%esp
  8028f2:	89 d8                	mov    %ebx,%eax
}
  8028f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028f7:	5b                   	pop    %ebx
  8028f8:	5e                   	pop    %esi
  8028f9:	5d                   	pop    %ebp
  8028fa:	c3                   	ret    

008028fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8028fb:	55                   	push   %ebp
  8028fc:	89 e5                	mov    %esp,%ebp
  8028fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802904:	50                   	push   %eax
  802905:	ff 75 08             	pushl  0x8(%ebp)
  802908:	e8 c4 fe ff ff       	call   8027d1 <fd_lookup>
  80290d:	89 c2                	mov    %eax,%edx
  80290f:	83 c4 08             	add    $0x8,%esp
  802912:	85 d2                	test   %edx,%edx
  802914:	78 10                	js     802926 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  802916:	83 ec 08             	sub    $0x8,%esp
  802919:	6a 01                	push   $0x1
  80291b:	ff 75 f4             	pushl  -0xc(%ebp)
  80291e:	e8 57 ff ff ff       	call   80287a <fd_close>
  802923:	83 c4 10             	add    $0x10,%esp
}
  802926:	c9                   	leave  
  802927:	c3                   	ret    

00802928 <close_all>:

void
close_all(void)
{
  802928:	55                   	push   %ebp
  802929:	89 e5                	mov    %esp,%ebp
  80292b:	53                   	push   %ebx
  80292c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80292f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802934:	83 ec 0c             	sub    $0xc,%esp
  802937:	53                   	push   %ebx
  802938:	e8 be ff ff ff       	call   8028fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80293d:	83 c3 01             	add    $0x1,%ebx
  802940:	83 c4 10             	add    $0x10,%esp
  802943:	83 fb 20             	cmp    $0x20,%ebx
  802946:	75 ec                	jne    802934 <close_all+0xc>
		close(i);
}
  802948:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80294b:	c9                   	leave  
  80294c:	c3                   	ret    

0080294d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80294d:	55                   	push   %ebp
  80294e:	89 e5                	mov    %esp,%ebp
  802950:	57                   	push   %edi
  802951:	56                   	push   %esi
  802952:	53                   	push   %ebx
  802953:	83 ec 2c             	sub    $0x2c,%esp
  802956:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802959:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80295c:	50                   	push   %eax
  80295d:	ff 75 08             	pushl  0x8(%ebp)
  802960:	e8 6c fe ff ff       	call   8027d1 <fd_lookup>
  802965:	89 c2                	mov    %eax,%edx
  802967:	83 c4 08             	add    $0x8,%esp
  80296a:	85 d2                	test   %edx,%edx
  80296c:	0f 88 c1 00 00 00    	js     802a33 <dup+0xe6>
		return r;
	close(newfdnum);
  802972:	83 ec 0c             	sub    $0xc,%esp
  802975:	56                   	push   %esi
  802976:	e8 80 ff ff ff       	call   8028fb <close>

	newfd = INDEX2FD(newfdnum);
  80297b:	89 f3                	mov    %esi,%ebx
  80297d:	c1 e3 0c             	shl    $0xc,%ebx
  802980:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802986:	83 c4 04             	add    $0x4,%esp
  802989:	ff 75 e4             	pushl  -0x1c(%ebp)
  80298c:	e8 da fd ff ff       	call   80276b <fd2data>
  802991:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802993:	89 1c 24             	mov    %ebx,(%esp)
  802996:	e8 d0 fd ff ff       	call   80276b <fd2data>
  80299b:	83 c4 10             	add    $0x10,%esp
  80299e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029a1:	89 f8                	mov    %edi,%eax
  8029a3:	c1 e8 16             	shr    $0x16,%eax
  8029a6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029ad:	a8 01                	test   $0x1,%al
  8029af:	74 37                	je     8029e8 <dup+0x9b>
  8029b1:	89 f8                	mov    %edi,%eax
  8029b3:	c1 e8 0c             	shr    $0xc,%eax
  8029b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029bd:	f6 c2 01             	test   $0x1,%dl
  8029c0:	74 26                	je     8029e8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8029c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029c9:	83 ec 0c             	sub    $0xc,%esp
  8029cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8029d1:	50                   	push   %eax
  8029d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8029d5:	6a 00                	push   $0x0
  8029d7:	57                   	push   %edi
  8029d8:	6a 00                	push   $0x0
  8029da:	e8 46 fa ff ff       	call   802425 <sys_page_map>
  8029df:	89 c7                	mov    %eax,%edi
  8029e1:	83 c4 20             	add    $0x20,%esp
  8029e4:	85 c0                	test   %eax,%eax
  8029e6:	78 2e                	js     802a16 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8029e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8029eb:	89 d0                	mov    %edx,%eax
  8029ed:	c1 e8 0c             	shr    $0xc,%eax
  8029f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029f7:	83 ec 0c             	sub    $0xc,%esp
  8029fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8029ff:	50                   	push   %eax
  802a00:	53                   	push   %ebx
  802a01:	6a 00                	push   $0x0
  802a03:	52                   	push   %edx
  802a04:	6a 00                	push   $0x0
  802a06:	e8 1a fa ff ff       	call   802425 <sys_page_map>
  802a0b:	89 c7                	mov    %eax,%edi
  802a0d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a10:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a12:	85 ff                	test   %edi,%edi
  802a14:	79 1d                	jns    802a33 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a16:	83 ec 08             	sub    $0x8,%esp
  802a19:	53                   	push   %ebx
  802a1a:	6a 00                	push   $0x0
  802a1c:	e8 46 fa ff ff       	call   802467 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a21:	83 c4 08             	add    $0x8,%esp
  802a24:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a27:	6a 00                	push   $0x0
  802a29:	e8 39 fa ff ff       	call   802467 <sys_page_unmap>
	return r;
  802a2e:	83 c4 10             	add    $0x10,%esp
  802a31:	89 f8                	mov    %edi,%eax
}
  802a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a36:	5b                   	pop    %ebx
  802a37:	5e                   	pop    %esi
  802a38:	5f                   	pop    %edi
  802a39:	5d                   	pop    %ebp
  802a3a:	c3                   	ret    

00802a3b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a3b:	55                   	push   %ebp
  802a3c:	89 e5                	mov    %esp,%ebp
  802a3e:	53                   	push   %ebx
  802a3f:	83 ec 14             	sub    $0x14,%esp
  802a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a48:	50                   	push   %eax
  802a49:	53                   	push   %ebx
  802a4a:	e8 82 fd ff ff       	call   8027d1 <fd_lookup>
  802a4f:	83 c4 08             	add    $0x8,%esp
  802a52:	89 c2                	mov    %eax,%edx
  802a54:	85 c0                	test   %eax,%eax
  802a56:	78 6d                	js     802ac5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a58:	83 ec 08             	sub    $0x8,%esp
  802a5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a5e:	50                   	push   %eax
  802a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a62:	ff 30                	pushl  (%eax)
  802a64:	e8 be fd ff ff       	call   802827 <dev_lookup>
  802a69:	83 c4 10             	add    $0x10,%esp
  802a6c:	85 c0                	test   %eax,%eax
  802a6e:	78 4c                	js     802abc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802a70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a73:	8b 42 08             	mov    0x8(%edx),%eax
  802a76:	83 e0 03             	and    $0x3,%eax
  802a79:	83 f8 01             	cmp    $0x1,%eax
  802a7c:	75 21                	jne    802a9f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802a7e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a83:	8b 40 48             	mov    0x48(%eax),%eax
  802a86:	83 ec 04             	sub    $0x4,%esp
  802a89:	53                   	push   %ebx
  802a8a:	50                   	push   %eax
  802a8b:	68 68 41 80 00       	push   $0x804168
  802a90:	e8 bd ef ff ff       	call   801a52 <cprintf>
		return -E_INVAL;
  802a95:	83 c4 10             	add    $0x10,%esp
  802a98:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802a9d:	eb 26                	jmp    802ac5 <read+0x8a>
	}
	if (!dev->dev_read)
  802a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aa2:	8b 40 08             	mov    0x8(%eax),%eax
  802aa5:	85 c0                	test   %eax,%eax
  802aa7:	74 17                	je     802ac0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802aa9:	83 ec 04             	sub    $0x4,%esp
  802aac:	ff 75 10             	pushl  0x10(%ebp)
  802aaf:	ff 75 0c             	pushl  0xc(%ebp)
  802ab2:	52                   	push   %edx
  802ab3:	ff d0                	call   *%eax
  802ab5:	89 c2                	mov    %eax,%edx
  802ab7:	83 c4 10             	add    $0x10,%esp
  802aba:	eb 09                	jmp    802ac5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802abc:	89 c2                	mov    %eax,%edx
  802abe:	eb 05                	jmp    802ac5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802ac0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802ac5:	89 d0                	mov    %edx,%eax
  802ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802aca:	c9                   	leave  
  802acb:	c3                   	ret    

00802acc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802acc:	55                   	push   %ebp
  802acd:	89 e5                	mov    %esp,%ebp
  802acf:	57                   	push   %edi
  802ad0:	56                   	push   %esi
  802ad1:	53                   	push   %ebx
  802ad2:	83 ec 0c             	sub    $0xc,%esp
  802ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ad8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802adb:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ae0:	eb 21                	jmp    802b03 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802ae2:	83 ec 04             	sub    $0x4,%esp
  802ae5:	89 f0                	mov    %esi,%eax
  802ae7:	29 d8                	sub    %ebx,%eax
  802ae9:	50                   	push   %eax
  802aea:	89 d8                	mov    %ebx,%eax
  802aec:	03 45 0c             	add    0xc(%ebp),%eax
  802aef:	50                   	push   %eax
  802af0:	57                   	push   %edi
  802af1:	e8 45 ff ff ff       	call   802a3b <read>
		if (m < 0)
  802af6:	83 c4 10             	add    $0x10,%esp
  802af9:	85 c0                	test   %eax,%eax
  802afb:	78 0c                	js     802b09 <readn+0x3d>
			return m;
		if (m == 0)
  802afd:	85 c0                	test   %eax,%eax
  802aff:	74 06                	je     802b07 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b01:	01 c3                	add    %eax,%ebx
  802b03:	39 f3                	cmp    %esi,%ebx
  802b05:	72 db                	jb     802ae2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802b07:	89 d8                	mov    %ebx,%eax
}
  802b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b0c:	5b                   	pop    %ebx
  802b0d:	5e                   	pop    %esi
  802b0e:	5f                   	pop    %edi
  802b0f:	5d                   	pop    %ebp
  802b10:	c3                   	ret    

00802b11 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b11:	55                   	push   %ebp
  802b12:	89 e5                	mov    %esp,%ebp
  802b14:	53                   	push   %ebx
  802b15:	83 ec 14             	sub    $0x14,%esp
  802b18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b1e:	50                   	push   %eax
  802b1f:	53                   	push   %ebx
  802b20:	e8 ac fc ff ff       	call   8027d1 <fd_lookup>
  802b25:	83 c4 08             	add    $0x8,%esp
  802b28:	89 c2                	mov    %eax,%edx
  802b2a:	85 c0                	test   %eax,%eax
  802b2c:	78 68                	js     802b96 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b2e:	83 ec 08             	sub    $0x8,%esp
  802b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b34:	50                   	push   %eax
  802b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b38:	ff 30                	pushl  (%eax)
  802b3a:	e8 e8 fc ff ff       	call   802827 <dev_lookup>
  802b3f:	83 c4 10             	add    $0x10,%esp
  802b42:	85 c0                	test   %eax,%eax
  802b44:	78 47                	js     802b8d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b49:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b4d:	75 21                	jne    802b70 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b4f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b54:	8b 40 48             	mov    0x48(%eax),%eax
  802b57:	83 ec 04             	sub    $0x4,%esp
  802b5a:	53                   	push   %ebx
  802b5b:	50                   	push   %eax
  802b5c:	68 84 41 80 00       	push   $0x804184
  802b61:	e8 ec ee ff ff       	call   801a52 <cprintf>
		return -E_INVAL;
  802b66:	83 c4 10             	add    $0x10,%esp
  802b69:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b6e:	eb 26                	jmp    802b96 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b73:	8b 52 0c             	mov    0xc(%edx),%edx
  802b76:	85 d2                	test   %edx,%edx
  802b78:	74 17                	je     802b91 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802b7a:	83 ec 04             	sub    $0x4,%esp
  802b7d:	ff 75 10             	pushl  0x10(%ebp)
  802b80:	ff 75 0c             	pushl  0xc(%ebp)
  802b83:	50                   	push   %eax
  802b84:	ff d2                	call   *%edx
  802b86:	89 c2                	mov    %eax,%edx
  802b88:	83 c4 10             	add    $0x10,%esp
  802b8b:	eb 09                	jmp    802b96 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b8d:	89 c2                	mov    %eax,%edx
  802b8f:	eb 05                	jmp    802b96 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802b91:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802b96:	89 d0                	mov    %edx,%eax
  802b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b9b:	c9                   	leave  
  802b9c:	c3                   	ret    

00802b9d <seek>:

int
seek(int fdnum, off_t offset)
{
  802b9d:	55                   	push   %ebp
  802b9e:	89 e5                	mov    %esp,%ebp
  802ba0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ba3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802ba6:	50                   	push   %eax
  802ba7:	ff 75 08             	pushl  0x8(%ebp)
  802baa:	e8 22 fc ff ff       	call   8027d1 <fd_lookup>
  802baf:	83 c4 08             	add    $0x8,%esp
  802bb2:	85 c0                	test   %eax,%eax
  802bb4:	78 0e                	js     802bc4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bbc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bc4:	c9                   	leave  
  802bc5:	c3                   	ret    

00802bc6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802bc6:	55                   	push   %ebp
  802bc7:	89 e5                	mov    %esp,%ebp
  802bc9:	53                   	push   %ebx
  802bca:	83 ec 14             	sub    $0x14,%esp
  802bcd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bd3:	50                   	push   %eax
  802bd4:	53                   	push   %ebx
  802bd5:	e8 f7 fb ff ff       	call   8027d1 <fd_lookup>
  802bda:	83 c4 08             	add    $0x8,%esp
  802bdd:	89 c2                	mov    %eax,%edx
  802bdf:	85 c0                	test   %eax,%eax
  802be1:	78 65                	js     802c48 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802be3:	83 ec 08             	sub    $0x8,%esp
  802be6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802be9:	50                   	push   %eax
  802bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bed:	ff 30                	pushl  (%eax)
  802bef:	e8 33 fc ff ff       	call   802827 <dev_lookup>
  802bf4:	83 c4 10             	add    $0x10,%esp
  802bf7:	85 c0                	test   %eax,%eax
  802bf9:	78 44                	js     802c3f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bfe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c02:	75 21                	jne    802c25 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c04:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c09:	8b 40 48             	mov    0x48(%eax),%eax
  802c0c:	83 ec 04             	sub    $0x4,%esp
  802c0f:	53                   	push   %ebx
  802c10:	50                   	push   %eax
  802c11:	68 44 41 80 00       	push   $0x804144
  802c16:	e8 37 ee ff ff       	call   801a52 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c1b:	83 c4 10             	add    $0x10,%esp
  802c1e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c23:	eb 23                	jmp    802c48 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c25:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c28:	8b 52 18             	mov    0x18(%edx),%edx
  802c2b:	85 d2                	test   %edx,%edx
  802c2d:	74 14                	je     802c43 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c2f:	83 ec 08             	sub    $0x8,%esp
  802c32:	ff 75 0c             	pushl  0xc(%ebp)
  802c35:	50                   	push   %eax
  802c36:	ff d2                	call   *%edx
  802c38:	89 c2                	mov    %eax,%edx
  802c3a:	83 c4 10             	add    $0x10,%esp
  802c3d:	eb 09                	jmp    802c48 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c3f:	89 c2                	mov    %eax,%edx
  802c41:	eb 05                	jmp    802c48 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c43:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c48:	89 d0                	mov    %edx,%eax
  802c4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c4d:	c9                   	leave  
  802c4e:	c3                   	ret    

00802c4f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c4f:	55                   	push   %ebp
  802c50:	89 e5                	mov    %esp,%ebp
  802c52:	53                   	push   %ebx
  802c53:	83 ec 14             	sub    $0x14,%esp
  802c56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c5c:	50                   	push   %eax
  802c5d:	ff 75 08             	pushl  0x8(%ebp)
  802c60:	e8 6c fb ff ff       	call   8027d1 <fd_lookup>
  802c65:	83 c4 08             	add    $0x8,%esp
  802c68:	89 c2                	mov    %eax,%edx
  802c6a:	85 c0                	test   %eax,%eax
  802c6c:	78 58                	js     802cc6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c6e:	83 ec 08             	sub    $0x8,%esp
  802c71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c74:	50                   	push   %eax
  802c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c78:	ff 30                	pushl  (%eax)
  802c7a:	e8 a8 fb ff ff       	call   802827 <dev_lookup>
  802c7f:	83 c4 10             	add    $0x10,%esp
  802c82:	85 c0                	test   %eax,%eax
  802c84:	78 37                	js     802cbd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c89:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802c8d:	74 32                	je     802cc1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802c8f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802c92:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802c99:	00 00 00 
	stat->st_isdir = 0;
  802c9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ca3:	00 00 00 
	stat->st_dev = dev;
  802ca6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cac:	83 ec 08             	sub    $0x8,%esp
  802caf:	53                   	push   %ebx
  802cb0:	ff 75 f0             	pushl  -0x10(%ebp)
  802cb3:	ff 50 14             	call   *0x14(%eax)
  802cb6:	89 c2                	mov    %eax,%edx
  802cb8:	83 c4 10             	add    $0x10,%esp
  802cbb:	eb 09                	jmp    802cc6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cbd:	89 c2                	mov    %eax,%edx
  802cbf:	eb 05                	jmp    802cc6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802cc1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802cc6:	89 d0                	mov    %edx,%eax
  802cc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ccb:	c9                   	leave  
  802ccc:	c3                   	ret    

00802ccd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802ccd:	55                   	push   %ebp
  802cce:	89 e5                	mov    %esp,%ebp
  802cd0:	56                   	push   %esi
  802cd1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802cd2:	83 ec 08             	sub    $0x8,%esp
  802cd5:	6a 00                	push   $0x0
  802cd7:	ff 75 08             	pushl  0x8(%ebp)
  802cda:	e8 09 02 00 00       	call   802ee8 <open>
  802cdf:	89 c3                	mov    %eax,%ebx
  802ce1:	83 c4 10             	add    $0x10,%esp
  802ce4:	85 db                	test   %ebx,%ebx
  802ce6:	78 1b                	js     802d03 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ce8:	83 ec 08             	sub    $0x8,%esp
  802ceb:	ff 75 0c             	pushl  0xc(%ebp)
  802cee:	53                   	push   %ebx
  802cef:	e8 5b ff ff ff       	call   802c4f <fstat>
  802cf4:	89 c6                	mov    %eax,%esi
	close(fd);
  802cf6:	89 1c 24             	mov    %ebx,(%esp)
  802cf9:	e8 fd fb ff ff       	call   8028fb <close>
	return r;
  802cfe:	83 c4 10             	add    $0x10,%esp
  802d01:	89 f0                	mov    %esi,%eax
}
  802d03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d06:	5b                   	pop    %ebx
  802d07:	5e                   	pop    %esi
  802d08:	5d                   	pop    %ebp
  802d09:	c3                   	ret    

00802d0a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d0a:	55                   	push   %ebp
  802d0b:	89 e5                	mov    %esp,%ebp
  802d0d:	56                   	push   %esi
  802d0e:	53                   	push   %ebx
  802d0f:	89 c6                	mov    %eax,%esi
  802d11:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d13:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d1a:	75 12                	jne    802d2e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d1c:	83 ec 0c             	sub    $0xc,%esp
  802d1f:	6a 01                	push   $0x1
  802d21:	e8 fd f9 ff ff       	call   802723 <ipc_find_env>
  802d26:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d2b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d2e:	6a 07                	push   $0x7
  802d30:	68 00 b0 80 00       	push   $0x80b000
  802d35:	56                   	push   %esi
  802d36:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d3c:	e8 8e f9 ff ff       	call   8026cf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d41:	83 c4 0c             	add    $0xc,%esp
  802d44:	6a 00                	push   $0x0
  802d46:	53                   	push   %ebx
  802d47:	6a 00                	push   $0x0
  802d49:	e8 18 f9 ff ff       	call   802666 <ipc_recv>
}
  802d4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d51:	5b                   	pop    %ebx
  802d52:	5e                   	pop    %esi
  802d53:	5d                   	pop    %ebp
  802d54:	c3                   	ret    

00802d55 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d55:	55                   	push   %ebp
  802d56:	89 e5                	mov    %esp,%ebp
  802d58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d5e:	8b 40 0c             	mov    0xc(%eax),%eax
  802d61:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d69:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  802d73:	b8 02 00 00 00       	mov    $0x2,%eax
  802d78:	e8 8d ff ff ff       	call   802d0a <fsipc>
}
  802d7d:	c9                   	leave  
  802d7e:	c3                   	ret    

00802d7f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802d7f:	55                   	push   %ebp
  802d80:	89 e5                	mov    %esp,%ebp
  802d82:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802d85:	8b 45 08             	mov    0x8(%ebp),%eax
  802d88:	8b 40 0c             	mov    0xc(%eax),%eax
  802d8b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802d90:	ba 00 00 00 00       	mov    $0x0,%edx
  802d95:	b8 06 00 00 00       	mov    $0x6,%eax
  802d9a:	e8 6b ff ff ff       	call   802d0a <fsipc>
}
  802d9f:	c9                   	leave  
  802da0:	c3                   	ret    

00802da1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802da1:	55                   	push   %ebp
  802da2:	89 e5                	mov    %esp,%ebp
  802da4:	53                   	push   %ebx
  802da5:	83 ec 04             	sub    $0x4,%esp
  802da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802dab:	8b 45 08             	mov    0x8(%ebp),%eax
  802dae:	8b 40 0c             	mov    0xc(%eax),%eax
  802db1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802db6:	ba 00 00 00 00       	mov    $0x0,%edx
  802dbb:	b8 05 00 00 00       	mov    $0x5,%eax
  802dc0:	e8 45 ff ff ff       	call   802d0a <fsipc>
  802dc5:	89 c2                	mov    %eax,%edx
  802dc7:	85 d2                	test   %edx,%edx
  802dc9:	78 2c                	js     802df7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802dcb:	83 ec 08             	sub    $0x8,%esp
  802dce:	68 00 b0 80 00       	push   $0x80b000
  802dd3:	53                   	push   %ebx
  802dd4:	e8 00 f2 ff ff       	call   801fd9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802dd9:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802dde:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802de4:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802de9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802def:	83 c4 10             	add    $0x10,%esp
  802df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802df7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dfa:	c9                   	leave  
  802dfb:	c3                   	ret    

00802dfc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802dfc:	55                   	push   %ebp
  802dfd:	89 e5                	mov    %esp,%ebp
  802dff:	57                   	push   %edi
  802e00:	56                   	push   %esi
  802e01:	53                   	push   %ebx
  802e02:	83 ec 0c             	sub    $0xc,%esp
  802e05:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  802e08:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0b:	8b 40 0c             	mov    0xc(%eax),%eax
  802e0e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  802e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802e16:	eb 3d                	jmp    802e55 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  802e18:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  802e1e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  802e23:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  802e26:	83 ec 04             	sub    $0x4,%esp
  802e29:	57                   	push   %edi
  802e2a:	53                   	push   %ebx
  802e2b:	68 08 b0 80 00       	push   $0x80b008
  802e30:	e8 36 f3 ff ff       	call   80216b <memmove>
                fsipcbuf.write.req_n = tmp; 
  802e35:	89 3d 04 b0 80 00    	mov    %edi,0x80b004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  802e40:	b8 04 00 00 00       	mov    $0x4,%eax
  802e45:	e8 c0 fe ff ff       	call   802d0a <fsipc>
  802e4a:	83 c4 10             	add    $0x10,%esp
  802e4d:	85 c0                	test   %eax,%eax
  802e4f:	78 0d                	js     802e5e <devfile_write+0x62>
		        return r;
                n -= tmp;
  802e51:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  802e53:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  802e55:	85 f6                	test   %esi,%esi
  802e57:	75 bf                	jne    802e18 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  802e59:	89 d8                	mov    %ebx,%eax
  802e5b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  802e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e61:	5b                   	pop    %ebx
  802e62:	5e                   	pop    %esi
  802e63:	5f                   	pop    %edi
  802e64:	5d                   	pop    %ebp
  802e65:	c3                   	ret    

00802e66 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e66:	55                   	push   %ebp
  802e67:	89 e5                	mov    %esp,%ebp
  802e69:	56                   	push   %esi
  802e6a:	53                   	push   %ebx
  802e6b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e71:	8b 40 0c             	mov    0xc(%eax),%eax
  802e74:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802e79:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802e7f:	ba 00 00 00 00       	mov    $0x0,%edx
  802e84:	b8 03 00 00 00       	mov    $0x3,%eax
  802e89:	e8 7c fe ff ff       	call   802d0a <fsipc>
  802e8e:	89 c3                	mov    %eax,%ebx
  802e90:	85 c0                	test   %eax,%eax
  802e92:	78 4b                	js     802edf <devfile_read+0x79>
		return r;
	assert(r <= n);
  802e94:	39 c6                	cmp    %eax,%esi
  802e96:	73 16                	jae    802eae <devfile_read+0x48>
  802e98:	68 b4 41 80 00       	push   $0x8041b4
  802e9d:	68 bd 37 80 00       	push   $0x8037bd
  802ea2:	6a 7c                	push   $0x7c
  802ea4:	68 bb 41 80 00       	push   $0x8041bb
  802ea9:	e8 cb ea ff ff       	call   801979 <_panic>
	assert(r <= PGSIZE);
  802eae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802eb3:	7e 16                	jle    802ecb <devfile_read+0x65>
  802eb5:	68 c6 41 80 00       	push   $0x8041c6
  802eba:	68 bd 37 80 00       	push   $0x8037bd
  802ebf:	6a 7d                	push   $0x7d
  802ec1:	68 bb 41 80 00       	push   $0x8041bb
  802ec6:	e8 ae ea ff ff       	call   801979 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802ecb:	83 ec 04             	sub    $0x4,%esp
  802ece:	50                   	push   %eax
  802ecf:	68 00 b0 80 00       	push   $0x80b000
  802ed4:	ff 75 0c             	pushl  0xc(%ebp)
  802ed7:	e8 8f f2 ff ff       	call   80216b <memmove>
	return r;
  802edc:	83 c4 10             	add    $0x10,%esp
}
  802edf:	89 d8                	mov    %ebx,%eax
  802ee1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ee4:	5b                   	pop    %ebx
  802ee5:	5e                   	pop    %esi
  802ee6:	5d                   	pop    %ebp
  802ee7:	c3                   	ret    

00802ee8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802ee8:	55                   	push   %ebp
  802ee9:	89 e5                	mov    %esp,%ebp
  802eeb:	53                   	push   %ebx
  802eec:	83 ec 20             	sub    $0x20,%esp
  802eef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802ef2:	53                   	push   %ebx
  802ef3:	e8 a8 f0 ff ff       	call   801fa0 <strlen>
  802ef8:	83 c4 10             	add    $0x10,%esp
  802efb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f00:	7f 67                	jg     802f69 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f02:	83 ec 0c             	sub    $0xc,%esp
  802f05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f08:	50                   	push   %eax
  802f09:	e8 74 f8 ff ff       	call   802782 <fd_alloc>
  802f0e:	83 c4 10             	add    $0x10,%esp
		return r;
  802f11:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f13:	85 c0                	test   %eax,%eax
  802f15:	78 57                	js     802f6e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f17:	83 ec 08             	sub    $0x8,%esp
  802f1a:	53                   	push   %ebx
  802f1b:	68 00 b0 80 00       	push   $0x80b000
  802f20:	e8 b4 f0 ff ff       	call   801fd9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f28:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f30:	b8 01 00 00 00       	mov    $0x1,%eax
  802f35:	e8 d0 fd ff ff       	call   802d0a <fsipc>
  802f3a:	89 c3                	mov    %eax,%ebx
  802f3c:	83 c4 10             	add    $0x10,%esp
  802f3f:	85 c0                	test   %eax,%eax
  802f41:	79 14                	jns    802f57 <open+0x6f>
		fd_close(fd, 0);
  802f43:	83 ec 08             	sub    $0x8,%esp
  802f46:	6a 00                	push   $0x0
  802f48:	ff 75 f4             	pushl  -0xc(%ebp)
  802f4b:	e8 2a f9 ff ff       	call   80287a <fd_close>
		return r;
  802f50:	83 c4 10             	add    $0x10,%esp
  802f53:	89 da                	mov    %ebx,%edx
  802f55:	eb 17                	jmp    802f6e <open+0x86>
	}

	return fd2num(fd);
  802f57:	83 ec 0c             	sub    $0xc,%esp
  802f5a:	ff 75 f4             	pushl  -0xc(%ebp)
  802f5d:	e8 f9 f7 ff ff       	call   80275b <fd2num>
  802f62:	89 c2                	mov    %eax,%edx
  802f64:	83 c4 10             	add    $0x10,%esp
  802f67:	eb 05                	jmp    802f6e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f69:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f6e:	89 d0                	mov    %edx,%eax
  802f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f73:	c9                   	leave  
  802f74:	c3                   	ret    

00802f75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802f75:	55                   	push   %ebp
  802f76:	89 e5                	mov    %esp,%ebp
  802f78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  802f80:	b8 08 00 00 00       	mov    $0x8,%eax
  802f85:	e8 80 fd ff ff       	call   802d0a <fsipc>
}
  802f8a:	c9                   	leave  
  802f8b:	c3                   	ret    

00802f8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f8c:	55                   	push   %ebp
  802f8d:	89 e5                	mov    %esp,%ebp
  802f8f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f92:	89 d0                	mov    %edx,%eax
  802f94:	c1 e8 16             	shr    $0x16,%eax
  802f97:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f9e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fa3:	f6 c1 01             	test   $0x1,%cl
  802fa6:	74 1d                	je     802fc5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fa8:	c1 ea 0c             	shr    $0xc,%edx
  802fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fb2:	f6 c2 01             	test   $0x1,%dl
  802fb5:	74 0e                	je     802fc5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fb7:	c1 ea 0c             	shr    $0xc,%edx
  802fba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fc1:	ef 
  802fc2:	0f b7 c0             	movzwl %ax,%eax
}
  802fc5:	5d                   	pop    %ebp
  802fc6:	c3                   	ret    

00802fc7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fc7:	55                   	push   %ebp
  802fc8:	89 e5                	mov    %esp,%ebp
  802fca:	56                   	push   %esi
  802fcb:	53                   	push   %ebx
  802fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fcf:	83 ec 0c             	sub    $0xc,%esp
  802fd2:	ff 75 08             	pushl  0x8(%ebp)
  802fd5:	e8 91 f7 ff ff       	call   80276b <fd2data>
  802fda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fdc:	83 c4 08             	add    $0x8,%esp
  802fdf:	68 d2 41 80 00       	push   $0x8041d2
  802fe4:	53                   	push   %ebx
  802fe5:	e8 ef ef ff ff       	call   801fd9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802fea:	8b 56 04             	mov    0x4(%esi),%edx
  802fed:	89 d0                	mov    %edx,%eax
  802fef:	2b 06                	sub    (%esi),%eax
  802ff1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ff7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ffe:	00 00 00 
	stat->st_dev = &devpipe;
  803001:	c7 83 88 00 00 00 a0 	movl   $0x8090a0,0x88(%ebx)
  803008:	90 80 00 
	return 0;
}
  80300b:	b8 00 00 00 00       	mov    $0x0,%eax
  803010:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803013:	5b                   	pop    %ebx
  803014:	5e                   	pop    %esi
  803015:	5d                   	pop    %ebp
  803016:	c3                   	ret    

00803017 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803017:	55                   	push   %ebp
  803018:	89 e5                	mov    %esp,%ebp
  80301a:	53                   	push   %ebx
  80301b:	83 ec 0c             	sub    $0xc,%esp
  80301e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803021:	53                   	push   %ebx
  803022:	6a 00                	push   $0x0
  803024:	e8 3e f4 ff ff       	call   802467 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803029:	89 1c 24             	mov    %ebx,(%esp)
  80302c:	e8 3a f7 ff ff       	call   80276b <fd2data>
  803031:	83 c4 08             	add    $0x8,%esp
  803034:	50                   	push   %eax
  803035:	6a 00                	push   $0x0
  803037:	e8 2b f4 ff ff       	call   802467 <sys_page_unmap>
}
  80303c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80303f:	c9                   	leave  
  803040:	c3                   	ret    

00803041 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803041:	55                   	push   %ebp
  803042:	89 e5                	mov    %esp,%ebp
  803044:	57                   	push   %edi
  803045:	56                   	push   %esi
  803046:	53                   	push   %ebx
  803047:	83 ec 1c             	sub    $0x1c,%esp
  80304a:	89 c6                	mov    %eax,%esi
  80304c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80304f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803054:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803057:	83 ec 0c             	sub    $0xc,%esp
  80305a:	56                   	push   %esi
  80305b:	e8 2c ff ff ff       	call   802f8c <pageref>
  803060:	89 c7                	mov    %eax,%edi
  803062:	83 c4 04             	add    $0x4,%esp
  803065:	ff 75 e4             	pushl  -0x1c(%ebp)
  803068:	e8 1f ff ff ff       	call   802f8c <pageref>
  80306d:	83 c4 10             	add    $0x10,%esp
  803070:	39 c7                	cmp    %eax,%edi
  803072:	0f 94 c2             	sete   %dl
  803075:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  803078:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  80307e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  803081:	39 fb                	cmp    %edi,%ebx
  803083:	74 19                	je     80309e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  803085:	84 d2                	test   %dl,%dl
  803087:	74 c6                	je     80304f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803089:	8b 51 58             	mov    0x58(%ecx),%edx
  80308c:	50                   	push   %eax
  80308d:	52                   	push   %edx
  80308e:	53                   	push   %ebx
  80308f:	68 d9 41 80 00       	push   $0x8041d9
  803094:	e8 b9 e9 ff ff       	call   801a52 <cprintf>
  803099:	83 c4 10             	add    $0x10,%esp
  80309c:	eb b1                	jmp    80304f <_pipeisclosed+0xe>
	}
}
  80309e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030a1:	5b                   	pop    %ebx
  8030a2:	5e                   	pop    %esi
  8030a3:	5f                   	pop    %edi
  8030a4:	5d                   	pop    %ebp
  8030a5:	c3                   	ret    

008030a6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030a6:	55                   	push   %ebp
  8030a7:	89 e5                	mov    %esp,%ebp
  8030a9:	57                   	push   %edi
  8030aa:	56                   	push   %esi
  8030ab:	53                   	push   %ebx
  8030ac:	83 ec 28             	sub    $0x28,%esp
  8030af:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030b2:	56                   	push   %esi
  8030b3:	e8 b3 f6 ff ff       	call   80276b <fd2data>
  8030b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030ba:	83 c4 10             	add    $0x10,%esp
  8030bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8030c2:	eb 4b                	jmp    80310f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030c4:	89 da                	mov    %ebx,%edx
  8030c6:	89 f0                	mov    %esi,%eax
  8030c8:	e8 74 ff ff ff       	call   803041 <_pipeisclosed>
  8030cd:	85 c0                	test   %eax,%eax
  8030cf:	75 48                	jne    803119 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030d1:	e8 ed f2 ff ff       	call   8023c3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030d6:	8b 43 04             	mov    0x4(%ebx),%eax
  8030d9:	8b 0b                	mov    (%ebx),%ecx
  8030db:	8d 51 20             	lea    0x20(%ecx),%edx
  8030de:	39 d0                	cmp    %edx,%eax
  8030e0:	73 e2                	jae    8030c4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030e5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030e9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030ec:	89 c2                	mov    %eax,%edx
  8030ee:	c1 fa 1f             	sar    $0x1f,%edx
  8030f1:	89 d1                	mov    %edx,%ecx
  8030f3:	c1 e9 1b             	shr    $0x1b,%ecx
  8030f6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8030f9:	83 e2 1f             	and    $0x1f,%edx
  8030fc:	29 ca                	sub    %ecx,%edx
  8030fe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803102:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803106:	83 c0 01             	add    $0x1,%eax
  803109:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80310c:	83 c7 01             	add    $0x1,%edi
  80310f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803112:	75 c2                	jne    8030d6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803114:	8b 45 10             	mov    0x10(%ebp),%eax
  803117:	eb 05                	jmp    80311e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803119:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80311e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803121:	5b                   	pop    %ebx
  803122:	5e                   	pop    %esi
  803123:	5f                   	pop    %edi
  803124:	5d                   	pop    %ebp
  803125:	c3                   	ret    

00803126 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803126:	55                   	push   %ebp
  803127:	89 e5                	mov    %esp,%ebp
  803129:	57                   	push   %edi
  80312a:	56                   	push   %esi
  80312b:	53                   	push   %ebx
  80312c:	83 ec 18             	sub    $0x18,%esp
  80312f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803132:	57                   	push   %edi
  803133:	e8 33 f6 ff ff       	call   80276b <fd2data>
  803138:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80313a:	83 c4 10             	add    $0x10,%esp
  80313d:	bb 00 00 00 00       	mov    $0x0,%ebx
  803142:	eb 3d                	jmp    803181 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803144:	85 db                	test   %ebx,%ebx
  803146:	74 04                	je     80314c <devpipe_read+0x26>
				return i;
  803148:	89 d8                	mov    %ebx,%eax
  80314a:	eb 44                	jmp    803190 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80314c:	89 f2                	mov    %esi,%edx
  80314e:	89 f8                	mov    %edi,%eax
  803150:	e8 ec fe ff ff       	call   803041 <_pipeisclosed>
  803155:	85 c0                	test   %eax,%eax
  803157:	75 32                	jne    80318b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803159:	e8 65 f2 ff ff       	call   8023c3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80315e:	8b 06                	mov    (%esi),%eax
  803160:	3b 46 04             	cmp    0x4(%esi),%eax
  803163:	74 df                	je     803144 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803165:	99                   	cltd   
  803166:	c1 ea 1b             	shr    $0x1b,%edx
  803169:	01 d0                	add    %edx,%eax
  80316b:	83 e0 1f             	and    $0x1f,%eax
  80316e:	29 d0                	sub    %edx,%eax
  803170:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803178:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80317b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80317e:	83 c3 01             	add    $0x1,%ebx
  803181:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803184:	75 d8                	jne    80315e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803186:	8b 45 10             	mov    0x10(%ebp),%eax
  803189:	eb 05                	jmp    803190 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80318b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803193:	5b                   	pop    %ebx
  803194:	5e                   	pop    %esi
  803195:	5f                   	pop    %edi
  803196:	5d                   	pop    %ebp
  803197:	c3                   	ret    

00803198 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803198:	55                   	push   %ebp
  803199:	89 e5                	mov    %esp,%ebp
  80319b:	56                   	push   %esi
  80319c:	53                   	push   %ebx
  80319d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031a3:	50                   	push   %eax
  8031a4:	e8 d9 f5 ff ff       	call   802782 <fd_alloc>
  8031a9:	83 c4 10             	add    $0x10,%esp
  8031ac:	89 c2                	mov    %eax,%edx
  8031ae:	85 c0                	test   %eax,%eax
  8031b0:	0f 88 2c 01 00 00    	js     8032e2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031b6:	83 ec 04             	sub    $0x4,%esp
  8031b9:	68 07 04 00 00       	push   $0x407
  8031be:	ff 75 f4             	pushl  -0xc(%ebp)
  8031c1:	6a 00                	push   $0x0
  8031c3:	e8 1a f2 ff ff       	call   8023e2 <sys_page_alloc>
  8031c8:	83 c4 10             	add    $0x10,%esp
  8031cb:	89 c2                	mov    %eax,%edx
  8031cd:	85 c0                	test   %eax,%eax
  8031cf:	0f 88 0d 01 00 00    	js     8032e2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031d5:	83 ec 0c             	sub    $0xc,%esp
  8031d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031db:	50                   	push   %eax
  8031dc:	e8 a1 f5 ff ff       	call   802782 <fd_alloc>
  8031e1:	89 c3                	mov    %eax,%ebx
  8031e3:	83 c4 10             	add    $0x10,%esp
  8031e6:	85 c0                	test   %eax,%eax
  8031e8:	0f 88 e2 00 00 00    	js     8032d0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031ee:	83 ec 04             	sub    $0x4,%esp
  8031f1:	68 07 04 00 00       	push   $0x407
  8031f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8031f9:	6a 00                	push   $0x0
  8031fb:	e8 e2 f1 ff ff       	call   8023e2 <sys_page_alloc>
  803200:	89 c3                	mov    %eax,%ebx
  803202:	83 c4 10             	add    $0x10,%esp
  803205:	85 c0                	test   %eax,%eax
  803207:	0f 88 c3 00 00 00    	js     8032d0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80320d:	83 ec 0c             	sub    $0xc,%esp
  803210:	ff 75 f4             	pushl  -0xc(%ebp)
  803213:	e8 53 f5 ff ff       	call   80276b <fd2data>
  803218:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80321a:	83 c4 0c             	add    $0xc,%esp
  80321d:	68 07 04 00 00       	push   $0x407
  803222:	50                   	push   %eax
  803223:	6a 00                	push   $0x0
  803225:	e8 b8 f1 ff ff       	call   8023e2 <sys_page_alloc>
  80322a:	89 c3                	mov    %eax,%ebx
  80322c:	83 c4 10             	add    $0x10,%esp
  80322f:	85 c0                	test   %eax,%eax
  803231:	0f 88 89 00 00 00    	js     8032c0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803237:	83 ec 0c             	sub    $0xc,%esp
  80323a:	ff 75 f0             	pushl  -0x10(%ebp)
  80323d:	e8 29 f5 ff ff       	call   80276b <fd2data>
  803242:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803249:	50                   	push   %eax
  80324a:	6a 00                	push   $0x0
  80324c:	56                   	push   %esi
  80324d:	6a 00                	push   $0x0
  80324f:	e8 d1 f1 ff ff       	call   802425 <sys_page_map>
  803254:	89 c3                	mov    %eax,%ebx
  803256:	83 c4 20             	add    $0x20,%esp
  803259:	85 c0                	test   %eax,%eax
  80325b:	78 55                	js     8032b2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80325d:	8b 15 a0 90 80 00    	mov    0x8090a0,%edx
  803263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803266:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80326b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803272:	8b 15 a0 90 80 00    	mov    0x8090a0,%edx
  803278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80327b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80327d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803280:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803287:	83 ec 0c             	sub    $0xc,%esp
  80328a:	ff 75 f4             	pushl  -0xc(%ebp)
  80328d:	e8 c9 f4 ff ff       	call   80275b <fd2num>
  803292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803295:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803297:	83 c4 04             	add    $0x4,%esp
  80329a:	ff 75 f0             	pushl  -0x10(%ebp)
  80329d:	e8 b9 f4 ff ff       	call   80275b <fd2num>
  8032a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032a5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032a8:	83 c4 10             	add    $0x10,%esp
  8032ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8032b0:	eb 30                	jmp    8032e2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032b2:	83 ec 08             	sub    $0x8,%esp
  8032b5:	56                   	push   %esi
  8032b6:	6a 00                	push   $0x0
  8032b8:	e8 aa f1 ff ff       	call   802467 <sys_page_unmap>
  8032bd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032c0:	83 ec 08             	sub    $0x8,%esp
  8032c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8032c6:	6a 00                	push   $0x0
  8032c8:	e8 9a f1 ff ff       	call   802467 <sys_page_unmap>
  8032cd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032d0:	83 ec 08             	sub    $0x8,%esp
  8032d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8032d6:	6a 00                	push   $0x0
  8032d8:	e8 8a f1 ff ff       	call   802467 <sys_page_unmap>
  8032dd:	83 c4 10             	add    $0x10,%esp
  8032e0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032e2:	89 d0                	mov    %edx,%eax
  8032e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032e7:	5b                   	pop    %ebx
  8032e8:	5e                   	pop    %esi
  8032e9:	5d                   	pop    %ebp
  8032ea:	c3                   	ret    

008032eb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8032eb:	55                   	push   %ebp
  8032ec:	89 e5                	mov    %esp,%ebp
  8032ee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032f4:	50                   	push   %eax
  8032f5:	ff 75 08             	pushl  0x8(%ebp)
  8032f8:	e8 d4 f4 ff ff       	call   8027d1 <fd_lookup>
  8032fd:	89 c2                	mov    %eax,%edx
  8032ff:	83 c4 10             	add    $0x10,%esp
  803302:	85 d2                	test   %edx,%edx
  803304:	78 18                	js     80331e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803306:	83 ec 0c             	sub    $0xc,%esp
  803309:	ff 75 f4             	pushl  -0xc(%ebp)
  80330c:	e8 5a f4 ff ff       	call   80276b <fd2data>
	return _pipeisclosed(fd, p);
  803311:	89 c2                	mov    %eax,%edx
  803313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803316:	e8 26 fd ff ff       	call   803041 <_pipeisclosed>
  80331b:	83 c4 10             	add    $0x10,%esp
}
  80331e:	c9                   	leave  
  80331f:	c3                   	ret    

00803320 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803320:	55                   	push   %ebp
  803321:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803323:	b8 00 00 00 00       	mov    $0x0,%eax
  803328:	5d                   	pop    %ebp
  803329:	c3                   	ret    

0080332a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80332a:	55                   	push   %ebp
  80332b:	89 e5                	mov    %esp,%ebp
  80332d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803330:	68 f1 41 80 00       	push   $0x8041f1
  803335:	ff 75 0c             	pushl  0xc(%ebp)
  803338:	e8 9c ec ff ff       	call   801fd9 <strcpy>
	return 0;
}
  80333d:	b8 00 00 00 00       	mov    $0x0,%eax
  803342:	c9                   	leave  
  803343:	c3                   	ret    

00803344 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803344:	55                   	push   %ebp
  803345:	89 e5                	mov    %esp,%ebp
  803347:	57                   	push   %edi
  803348:	56                   	push   %esi
  803349:	53                   	push   %ebx
  80334a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803350:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803355:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80335b:	eb 2d                	jmp    80338a <devcons_write+0x46>
		m = n - tot;
  80335d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803360:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803362:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803365:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80336a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80336d:	83 ec 04             	sub    $0x4,%esp
  803370:	53                   	push   %ebx
  803371:	03 45 0c             	add    0xc(%ebp),%eax
  803374:	50                   	push   %eax
  803375:	57                   	push   %edi
  803376:	e8 f0 ed ff ff       	call   80216b <memmove>
		sys_cputs(buf, m);
  80337b:	83 c4 08             	add    $0x8,%esp
  80337e:	53                   	push   %ebx
  80337f:	57                   	push   %edi
  803380:	e8 a1 ef ff ff       	call   802326 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803385:	01 de                	add    %ebx,%esi
  803387:	83 c4 10             	add    $0x10,%esp
  80338a:	89 f0                	mov    %esi,%eax
  80338c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80338f:	72 cc                	jb     80335d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803394:	5b                   	pop    %ebx
  803395:	5e                   	pop    %esi
  803396:	5f                   	pop    %edi
  803397:	5d                   	pop    %ebp
  803398:	c3                   	ret    

00803399 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803399:	55                   	push   %ebp
  80339a:	89 e5                	mov    %esp,%ebp
  80339c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80339f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8033a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8033a8:	75 07                	jne    8033b1 <devcons_read+0x18>
  8033aa:	eb 28                	jmp    8033d4 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8033ac:	e8 12 f0 ff ff       	call   8023c3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8033b1:	e8 8e ef ff ff       	call   802344 <sys_cgetc>
  8033b6:	85 c0                	test   %eax,%eax
  8033b8:	74 f2                	je     8033ac <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8033ba:	85 c0                	test   %eax,%eax
  8033bc:	78 16                	js     8033d4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8033be:	83 f8 04             	cmp    $0x4,%eax
  8033c1:	74 0c                	je     8033cf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8033c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033c6:	88 02                	mov    %al,(%edx)
	return 1;
  8033c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8033cd:	eb 05                	jmp    8033d4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8033cf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8033d4:	c9                   	leave  
  8033d5:	c3                   	ret    

008033d6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8033d6:	55                   	push   %ebp
  8033d7:	89 e5                	mov    %esp,%ebp
  8033d9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8033dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8033df:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8033e2:	6a 01                	push   $0x1
  8033e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8033e7:	50                   	push   %eax
  8033e8:	e8 39 ef ff ff       	call   802326 <sys_cputs>
  8033ed:	83 c4 10             	add    $0x10,%esp
}
  8033f0:	c9                   	leave  
  8033f1:	c3                   	ret    

008033f2 <getchar>:

int
getchar(void)
{
  8033f2:	55                   	push   %ebp
  8033f3:	89 e5                	mov    %esp,%ebp
  8033f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8033f8:	6a 01                	push   $0x1
  8033fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8033fd:	50                   	push   %eax
  8033fe:	6a 00                	push   $0x0
  803400:	e8 36 f6 ff ff       	call   802a3b <read>
	if (r < 0)
  803405:	83 c4 10             	add    $0x10,%esp
  803408:	85 c0                	test   %eax,%eax
  80340a:	78 0f                	js     80341b <getchar+0x29>
		return r;
	if (r < 1)
  80340c:	85 c0                	test   %eax,%eax
  80340e:	7e 06                	jle    803416 <getchar+0x24>
		return -E_EOF;
	return c;
  803410:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803414:	eb 05                	jmp    80341b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803416:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80341b:	c9                   	leave  
  80341c:	c3                   	ret    

0080341d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80341d:	55                   	push   %ebp
  80341e:	89 e5                	mov    %esp,%ebp
  803420:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803426:	50                   	push   %eax
  803427:	ff 75 08             	pushl  0x8(%ebp)
  80342a:	e8 a2 f3 ff ff       	call   8027d1 <fd_lookup>
  80342f:	83 c4 10             	add    $0x10,%esp
  803432:	85 c0                	test   %eax,%eax
  803434:	78 11                	js     803447 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803439:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  80343f:	39 10                	cmp    %edx,(%eax)
  803441:	0f 94 c0             	sete   %al
  803444:	0f b6 c0             	movzbl %al,%eax
}
  803447:	c9                   	leave  
  803448:	c3                   	ret    

00803449 <opencons>:

int
opencons(void)
{
  803449:	55                   	push   %ebp
  80344a:	89 e5                	mov    %esp,%ebp
  80344c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80344f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803452:	50                   	push   %eax
  803453:	e8 2a f3 ff ff       	call   802782 <fd_alloc>
  803458:	83 c4 10             	add    $0x10,%esp
		return r;
  80345b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80345d:	85 c0                	test   %eax,%eax
  80345f:	78 3e                	js     80349f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803461:	83 ec 04             	sub    $0x4,%esp
  803464:	68 07 04 00 00       	push   $0x407
  803469:	ff 75 f4             	pushl  -0xc(%ebp)
  80346c:	6a 00                	push   $0x0
  80346e:	e8 6f ef ff ff       	call   8023e2 <sys_page_alloc>
  803473:	83 c4 10             	add    $0x10,%esp
		return r;
  803476:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803478:	85 c0                	test   %eax,%eax
  80347a:	78 23                	js     80349f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80347c:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  803482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803485:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80348a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803491:	83 ec 0c             	sub    $0xc,%esp
  803494:	50                   	push   %eax
  803495:	e8 c1 f2 ff ff       	call   80275b <fd2num>
  80349a:	89 c2                	mov    %eax,%edx
  80349c:	83 c4 10             	add    $0x10,%esp
}
  80349f:	89 d0                	mov    %edx,%eax
  8034a1:	c9                   	leave  
  8034a2:	c3                   	ret    
  8034a3:	66 90                	xchg   %ax,%ax
  8034a5:	66 90                	xchg   %ax,%ax
  8034a7:	66 90                	xchg   %ax,%ax
  8034a9:	66 90                	xchg   %ax,%ax
  8034ab:	66 90                	xchg   %ax,%ax
  8034ad:	66 90                	xchg   %ax,%ax
  8034af:	90                   	nop

008034b0 <__udivdi3>:
  8034b0:	55                   	push   %ebp
  8034b1:	57                   	push   %edi
  8034b2:	56                   	push   %esi
  8034b3:	83 ec 10             	sub    $0x10,%esp
  8034b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8034ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8034be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8034c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8034c6:	85 d2                	test   %edx,%edx
  8034c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8034cc:	89 34 24             	mov    %esi,(%esp)
  8034cf:	89 c8                	mov    %ecx,%eax
  8034d1:	75 35                	jne    803508 <__udivdi3+0x58>
  8034d3:	39 f1                	cmp    %esi,%ecx
  8034d5:	0f 87 bd 00 00 00    	ja     803598 <__udivdi3+0xe8>
  8034db:	85 c9                	test   %ecx,%ecx
  8034dd:	89 cd                	mov    %ecx,%ebp
  8034df:	75 0b                	jne    8034ec <__udivdi3+0x3c>
  8034e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034e6:	31 d2                	xor    %edx,%edx
  8034e8:	f7 f1                	div    %ecx
  8034ea:	89 c5                	mov    %eax,%ebp
  8034ec:	89 f0                	mov    %esi,%eax
  8034ee:	31 d2                	xor    %edx,%edx
  8034f0:	f7 f5                	div    %ebp
  8034f2:	89 c6                	mov    %eax,%esi
  8034f4:	89 f8                	mov    %edi,%eax
  8034f6:	f7 f5                	div    %ebp
  8034f8:	89 f2                	mov    %esi,%edx
  8034fa:	83 c4 10             	add    $0x10,%esp
  8034fd:	5e                   	pop    %esi
  8034fe:	5f                   	pop    %edi
  8034ff:	5d                   	pop    %ebp
  803500:	c3                   	ret    
  803501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803508:	3b 14 24             	cmp    (%esp),%edx
  80350b:	77 7b                	ja     803588 <__udivdi3+0xd8>
  80350d:	0f bd f2             	bsr    %edx,%esi
  803510:	83 f6 1f             	xor    $0x1f,%esi
  803513:	0f 84 97 00 00 00    	je     8035b0 <__udivdi3+0x100>
  803519:	bd 20 00 00 00       	mov    $0x20,%ebp
  80351e:	89 d7                	mov    %edx,%edi
  803520:	89 f1                	mov    %esi,%ecx
  803522:	29 f5                	sub    %esi,%ebp
  803524:	d3 e7                	shl    %cl,%edi
  803526:	89 c2                	mov    %eax,%edx
  803528:	89 e9                	mov    %ebp,%ecx
  80352a:	d3 ea                	shr    %cl,%edx
  80352c:	89 f1                	mov    %esi,%ecx
  80352e:	09 fa                	or     %edi,%edx
  803530:	8b 3c 24             	mov    (%esp),%edi
  803533:	d3 e0                	shl    %cl,%eax
  803535:	89 54 24 08          	mov    %edx,0x8(%esp)
  803539:	89 e9                	mov    %ebp,%ecx
  80353b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80353f:	8b 44 24 04          	mov    0x4(%esp),%eax
  803543:	89 fa                	mov    %edi,%edx
  803545:	d3 ea                	shr    %cl,%edx
  803547:	89 f1                	mov    %esi,%ecx
  803549:	d3 e7                	shl    %cl,%edi
  80354b:	89 e9                	mov    %ebp,%ecx
  80354d:	d3 e8                	shr    %cl,%eax
  80354f:	09 c7                	or     %eax,%edi
  803551:	89 f8                	mov    %edi,%eax
  803553:	f7 74 24 08          	divl   0x8(%esp)
  803557:	89 d5                	mov    %edx,%ebp
  803559:	89 c7                	mov    %eax,%edi
  80355b:	f7 64 24 0c          	mull   0xc(%esp)
  80355f:	39 d5                	cmp    %edx,%ebp
  803561:	89 14 24             	mov    %edx,(%esp)
  803564:	72 11                	jb     803577 <__udivdi3+0xc7>
  803566:	8b 54 24 04          	mov    0x4(%esp),%edx
  80356a:	89 f1                	mov    %esi,%ecx
  80356c:	d3 e2                	shl    %cl,%edx
  80356e:	39 c2                	cmp    %eax,%edx
  803570:	73 5e                	jae    8035d0 <__udivdi3+0x120>
  803572:	3b 2c 24             	cmp    (%esp),%ebp
  803575:	75 59                	jne    8035d0 <__udivdi3+0x120>
  803577:	8d 47 ff             	lea    -0x1(%edi),%eax
  80357a:	31 f6                	xor    %esi,%esi
  80357c:	89 f2                	mov    %esi,%edx
  80357e:	83 c4 10             	add    $0x10,%esp
  803581:	5e                   	pop    %esi
  803582:	5f                   	pop    %edi
  803583:	5d                   	pop    %ebp
  803584:	c3                   	ret    
  803585:	8d 76 00             	lea    0x0(%esi),%esi
  803588:	31 f6                	xor    %esi,%esi
  80358a:	31 c0                	xor    %eax,%eax
  80358c:	89 f2                	mov    %esi,%edx
  80358e:	83 c4 10             	add    $0x10,%esp
  803591:	5e                   	pop    %esi
  803592:	5f                   	pop    %edi
  803593:	5d                   	pop    %ebp
  803594:	c3                   	ret    
  803595:	8d 76 00             	lea    0x0(%esi),%esi
  803598:	89 f2                	mov    %esi,%edx
  80359a:	31 f6                	xor    %esi,%esi
  80359c:	89 f8                	mov    %edi,%eax
  80359e:	f7 f1                	div    %ecx
  8035a0:	89 f2                	mov    %esi,%edx
  8035a2:	83 c4 10             	add    $0x10,%esp
  8035a5:	5e                   	pop    %esi
  8035a6:	5f                   	pop    %edi
  8035a7:	5d                   	pop    %ebp
  8035a8:	c3                   	ret    
  8035a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8035b4:	76 0b                	jbe    8035c1 <__udivdi3+0x111>
  8035b6:	31 c0                	xor    %eax,%eax
  8035b8:	3b 14 24             	cmp    (%esp),%edx
  8035bb:	0f 83 37 ff ff ff    	jae    8034f8 <__udivdi3+0x48>
  8035c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8035c6:	e9 2d ff ff ff       	jmp    8034f8 <__udivdi3+0x48>
  8035cb:	90                   	nop
  8035cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035d0:	89 f8                	mov    %edi,%eax
  8035d2:	31 f6                	xor    %esi,%esi
  8035d4:	e9 1f ff ff ff       	jmp    8034f8 <__udivdi3+0x48>
  8035d9:	66 90                	xchg   %ax,%ax
  8035db:	66 90                	xchg   %ax,%ax
  8035dd:	66 90                	xchg   %ax,%ax
  8035df:	90                   	nop

008035e0 <__umoddi3>:
  8035e0:	55                   	push   %ebp
  8035e1:	57                   	push   %edi
  8035e2:	56                   	push   %esi
  8035e3:	83 ec 20             	sub    $0x20,%esp
  8035e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8035ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035f2:	89 c6                	mov    %eax,%esi
  8035f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8035f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8035fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  803600:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803604:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803608:	89 74 24 18          	mov    %esi,0x18(%esp)
  80360c:	85 c0                	test   %eax,%eax
  80360e:	89 c2                	mov    %eax,%edx
  803610:	75 1e                	jne    803630 <__umoddi3+0x50>
  803612:	39 f7                	cmp    %esi,%edi
  803614:	76 52                	jbe    803668 <__umoddi3+0x88>
  803616:	89 c8                	mov    %ecx,%eax
  803618:	89 f2                	mov    %esi,%edx
  80361a:	f7 f7                	div    %edi
  80361c:	89 d0                	mov    %edx,%eax
  80361e:	31 d2                	xor    %edx,%edx
  803620:	83 c4 20             	add    $0x20,%esp
  803623:	5e                   	pop    %esi
  803624:	5f                   	pop    %edi
  803625:	5d                   	pop    %ebp
  803626:	c3                   	ret    
  803627:	89 f6                	mov    %esi,%esi
  803629:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803630:	39 f0                	cmp    %esi,%eax
  803632:	77 5c                	ja     803690 <__umoddi3+0xb0>
  803634:	0f bd e8             	bsr    %eax,%ebp
  803637:	83 f5 1f             	xor    $0x1f,%ebp
  80363a:	75 64                	jne    8036a0 <__umoddi3+0xc0>
  80363c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  803640:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  803644:	0f 86 f6 00 00 00    	jbe    803740 <__umoddi3+0x160>
  80364a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80364e:	0f 82 ec 00 00 00    	jb     803740 <__umoddi3+0x160>
  803654:	8b 44 24 14          	mov    0x14(%esp),%eax
  803658:	8b 54 24 18          	mov    0x18(%esp),%edx
  80365c:	83 c4 20             	add    $0x20,%esp
  80365f:	5e                   	pop    %esi
  803660:	5f                   	pop    %edi
  803661:	5d                   	pop    %ebp
  803662:	c3                   	ret    
  803663:	90                   	nop
  803664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803668:	85 ff                	test   %edi,%edi
  80366a:	89 fd                	mov    %edi,%ebp
  80366c:	75 0b                	jne    803679 <__umoddi3+0x99>
  80366e:	b8 01 00 00 00       	mov    $0x1,%eax
  803673:	31 d2                	xor    %edx,%edx
  803675:	f7 f7                	div    %edi
  803677:	89 c5                	mov    %eax,%ebp
  803679:	8b 44 24 10          	mov    0x10(%esp),%eax
  80367d:	31 d2                	xor    %edx,%edx
  80367f:	f7 f5                	div    %ebp
  803681:	89 c8                	mov    %ecx,%eax
  803683:	f7 f5                	div    %ebp
  803685:	eb 95                	jmp    80361c <__umoddi3+0x3c>
  803687:	89 f6                	mov    %esi,%esi
  803689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803690:	89 c8                	mov    %ecx,%eax
  803692:	89 f2                	mov    %esi,%edx
  803694:	83 c4 20             	add    $0x20,%esp
  803697:	5e                   	pop    %esi
  803698:	5f                   	pop    %edi
  803699:	5d                   	pop    %ebp
  80369a:	c3                   	ret    
  80369b:	90                   	nop
  80369c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8036a5:	89 e9                	mov    %ebp,%ecx
  8036a7:	29 e8                	sub    %ebp,%eax
  8036a9:	d3 e2                	shl    %cl,%edx
  8036ab:	89 c7                	mov    %eax,%edi
  8036ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8036b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036b5:	89 f9                	mov    %edi,%ecx
  8036b7:	d3 e8                	shr    %cl,%eax
  8036b9:	89 c1                	mov    %eax,%ecx
  8036bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036bf:	09 d1                	or     %edx,%ecx
  8036c1:	89 fa                	mov    %edi,%edx
  8036c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8036c7:	89 e9                	mov    %ebp,%ecx
  8036c9:	d3 e0                	shl    %cl,%eax
  8036cb:	89 f9                	mov    %edi,%ecx
  8036cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036d1:	89 f0                	mov    %esi,%eax
  8036d3:	d3 e8                	shr    %cl,%eax
  8036d5:	89 e9                	mov    %ebp,%ecx
  8036d7:	89 c7                	mov    %eax,%edi
  8036d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8036dd:	d3 e6                	shl    %cl,%esi
  8036df:	89 d1                	mov    %edx,%ecx
  8036e1:	89 fa                	mov    %edi,%edx
  8036e3:	d3 e8                	shr    %cl,%eax
  8036e5:	89 e9                	mov    %ebp,%ecx
  8036e7:	09 f0                	or     %esi,%eax
  8036e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8036ed:	f7 74 24 10          	divl   0x10(%esp)
  8036f1:	d3 e6                	shl    %cl,%esi
  8036f3:	89 d1                	mov    %edx,%ecx
  8036f5:	f7 64 24 0c          	mull   0xc(%esp)
  8036f9:	39 d1                	cmp    %edx,%ecx
  8036fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8036ff:	89 d7                	mov    %edx,%edi
  803701:	89 c6                	mov    %eax,%esi
  803703:	72 0a                	jb     80370f <__umoddi3+0x12f>
  803705:	39 44 24 14          	cmp    %eax,0x14(%esp)
  803709:	73 10                	jae    80371b <__umoddi3+0x13b>
  80370b:	39 d1                	cmp    %edx,%ecx
  80370d:	75 0c                	jne    80371b <__umoddi3+0x13b>
  80370f:	89 d7                	mov    %edx,%edi
  803711:	89 c6                	mov    %eax,%esi
  803713:	2b 74 24 0c          	sub    0xc(%esp),%esi
  803717:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80371b:	89 ca                	mov    %ecx,%edx
  80371d:	89 e9                	mov    %ebp,%ecx
  80371f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803723:	29 f0                	sub    %esi,%eax
  803725:	19 fa                	sbb    %edi,%edx
  803727:	d3 e8                	shr    %cl,%eax
  803729:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80372e:	89 d7                	mov    %edx,%edi
  803730:	d3 e7                	shl    %cl,%edi
  803732:	89 e9                	mov    %ebp,%ecx
  803734:	09 f8                	or     %edi,%eax
  803736:	d3 ea                	shr    %cl,%edx
  803738:	83 c4 20             	add    $0x20,%esp
  80373b:	5e                   	pop    %esi
  80373c:	5f                   	pop    %edi
  80373d:	5d                   	pop    %ebp
  80373e:	c3                   	ret    
  80373f:	90                   	nop
  803740:	8b 74 24 10          	mov    0x10(%esp),%esi
  803744:	29 f9                	sub    %edi,%ecx
  803746:	19 c6                	sbb    %eax,%esi
  803748:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80374c:	89 74 24 18          	mov    %esi,0x18(%esp)
  803750:	e9 ff fe ff ff       	jmp    803654 <__umoddi3+0x74>
