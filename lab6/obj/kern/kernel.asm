
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d d0 8e 2a f0 00 	cmpl   $0x0,0xf02a8ed0
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 d0 8e 2a f0    	mov    %esi,0xf02a8ed0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 ba 5e 00 00       	call   f0105f1b <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 00 6f 10 f0       	push   $0xf0106f00
f010006d:	e8 eb 36 00 00       	call   f010375d <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 bb 36 00 00       	call   f0103737 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 f3 77 10 f0 	movl   $0xf01077f3,(%esp)
f0100083:	e8 d5 36 00 00       	call   f010375d <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 2b 09 00 00       	call   f01009c0 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 10 a0 2e f0       	mov    $0xf02ea010,%eax
f01000a6:	2d 00 80 2a f0       	sub    $0xf02a8000,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 00 80 2a f0       	push   $0xf02a8000
f01000b3:	e8 3f 58 00 00       	call   f01058f7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 9f 05 00 00       	call   f010065c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 6c 6f 10 f0       	push   $0xf0106f6c
f01000ca:	e8 8e 36 00 00       	call   f010375d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 eb 12 00 00       	call   f01013bf <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 17 2f 00 00       	call   f0102ff0 <env_init>
	trap_init();
f01000d9:	e8 53 37 00 00       	call   f0103831 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 31 5b 00 00       	call   f0105c14 <mp_init>
	lapic_init();
f01000e3:	e8 4e 5e 00 00       	call   f0105f36 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 99 35 00 00       	call   f0103686 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 f5 6a 00 00       	call   f0106be7 <time_init>
	pci_init();
f01000f2:	e8 d0 6a 00 00       	call   f0106bc7 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01000fe:	e8 83 60 00 00       	call   f0106186 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d d8 8e 2a f0 07 	cmpl   $0x7,0xf02a8ed8
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 24 6f 10 f0       	push   $0xf0106f24
f0100119:	6a 68                	push   $0x68
f010011b:	68 87 6f 10 f0       	push   $0xf0106f87
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 7a 5b 10 f0       	mov    $0xf0105b7a,%eax
f010012d:	2d 00 5b 10 f0       	sub    $0xf0105b00,%eax
f0100132:	50                   	push   %eax
f0100133:	68 00 5b 10 f0       	push   $0xf0105b00
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 02 58 00 00       	call   f0105944 <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 40 90 2a f0       	mov    $0xf02a9040,%ebx
f010014a:	eb 4e                	jmp    f010019a <i386_init+0x100>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 ca 5d 00 00       	call   f0105f1b <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 40 90 2a f0       	add    $0xf02a9040,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 3a                	je     f0100197 <i386_init+0xfd>
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 40 90 2a f0       	sub    $0xf02a9040,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	8d 80 00 20 2b f0    	lea    -0xfd4e000(%eax),%eax
f0100176:	a3 d4 8e 2a f0       	mov    %eax,0xf02a8ed4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017b:	83 ec 08             	sub    $0x8,%esp
f010017e:	68 00 70 00 00       	push   $0x7000
f0100183:	0f b6 03             	movzbl (%ebx),%eax
f0100186:	50                   	push   %eax
f0100187:	e8 f8 5e 00 00       	call   f0106084 <lapic_startap>
f010018c:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100192:	83 f8 01             	cmp    $0x1,%eax
f0100195:	75 f8                	jne    f010018f <i386_init+0xf5>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100197:	83 c3 74             	add    $0x74,%ebx
f010019a:	6b 05 e4 93 2a f0 74 	imul   $0x74,0xf02a93e4,%eax
f01001a1:	05 40 90 2a f0       	add    $0xf02a9040,%eax
f01001a6:	39 c3                	cmp    %eax,%ebx
f01001a8:	72 a2                	jb     f010014c <i386_init+0xb2>
        lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001aa:	83 ec 08             	sub    $0x8,%esp
f01001ad:	6a 01                	push   $0x1
f01001af:	68 8c 4a 1d f0       	push   $0xf01d4a8c
f01001b4:	e8 cf 2f 00 00       	call   f0103188 <env_create>
 
     
#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001b9:	83 c4 08             	add    $0x8,%esp
f01001bc:	6a 02                	push   $0x2
f01001be:	68 9c d6 22 f0       	push   $0xf022d69c
f01001c3:	e8 c0 2f 00 00       	call   f0103188 <env_create>
#endif
 
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c8:	83 c4 08             	add    $0x8,%esp
f01001cb:	6a 00                	push   $0x0
f01001cd:	68 d8 54 1f f0       	push   $0xf01f54d8
f01001d2:	e8 b1 2f 00 00       	call   f0103188 <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);    
        //ENV_CREATE(user_testtime, ENV_TYPE_USER);
#endif // TEST*
	// Should not be necessary - drains keyboard because interrupt has given up.
	//ENV_CREATE(user_httpd, ENV_TYPE_USER);
        kbd_intr();
f01001d7:	e8 24 04 00 00       	call   f0100600 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001dc:	e8 ef 43 00 00       	call   f01045d0 <sched_yield>

f01001e1 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e1:	55                   	push   %ebp
f01001e2:	89 e5                	mov    %esp,%ebp
f01001e4:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001e7:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f1:	77 12                	ja     f0100205 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f3:	50                   	push   %eax
f01001f4:	68 48 6f 10 f0       	push   $0xf0106f48
f01001f9:	6a 7f                	push   $0x7f
f01001fb:	68 87 6f 10 f0       	push   $0xf0106f87
f0100200:	e8 3b fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100205:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010020a:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010020d:	e8 09 5d 00 00       	call   f0105f1b <cpunum>
f0100212:	83 ec 08             	sub    $0x8,%esp
f0100215:	50                   	push   %eax
f0100216:	68 93 6f 10 f0       	push   $0xf0106f93
f010021b:	e8 3d 35 00 00       	call   f010375d <cprintf>

	lapic_init();
f0100220:	e8 11 5d 00 00       	call   f0105f36 <lapic_init>
	env_init_percpu();
f0100225:	e8 9c 2d 00 00       	call   f0102fc6 <env_init_percpu>
	trap_init_percpu();
f010022a:	e8 42 35 00 00       	call   f0103771 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010022f:	e8 e7 5c 00 00       	call   f0105f1b <cpunum>
f0100234:	6b d0 74             	imul   $0x74,%eax,%edx
f0100237:	81 c2 40 90 2a f0    	add    $0xf02a9040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010023d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100242:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100246:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f010024d:	e8 34 5f 00 00       	call   f0106186 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100252:	e8 79 43 00 00       	call   f01045d0 <sched_yield>

f0100257 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100257:	55                   	push   %ebp
f0100258:	89 e5                	mov    %esp,%ebp
f010025a:	53                   	push   %ebx
f010025b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010025e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100261:	ff 75 0c             	pushl  0xc(%ebp)
f0100264:	ff 75 08             	pushl  0x8(%ebp)
f0100267:	68 a9 6f 10 f0       	push   $0xf0106fa9
f010026c:	e8 ec 34 00 00       	call   f010375d <cprintf>
	vcprintf(fmt, ap);
f0100271:	83 c4 08             	add    $0x8,%esp
f0100274:	53                   	push   %ebx
f0100275:	ff 75 10             	pushl  0x10(%ebp)
f0100278:	e8 ba 34 00 00       	call   f0103737 <vcprintf>
	cprintf("\n");
f010027d:	c7 04 24 f3 77 10 f0 	movl   $0xf01077f3,(%esp)
f0100284:	e8 d4 34 00 00       	call   f010375d <cprintf>
	va_end(ap);
f0100289:	83 c4 10             	add    $0x10,%esp
}
f010028c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010028f:	c9                   	leave  
f0100290:	c3                   	ret    

f0100291 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100291:	55                   	push   %ebp
f0100292:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100294:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100299:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010029a:	a8 01                	test   $0x1,%al
f010029c:	74 08                	je     f01002a6 <serial_proc_data+0x15>
f010029e:	b2 f8                	mov    $0xf8,%dl
f01002a0:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002a1:	0f b6 c0             	movzbl %al,%eax
f01002a4:	eb 05                	jmp    f01002ab <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ab:	5d                   	pop    %ebp
f01002ac:	c3                   	ret    

f01002ad <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ad:	55                   	push   %ebp
f01002ae:	89 e5                	mov    %esp,%ebp
f01002b0:	53                   	push   %ebx
f01002b1:	83 ec 04             	sub    $0x4,%esp
f01002b4:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002b6:	eb 2a                	jmp    f01002e2 <cons_intr+0x35>
		if (c == 0)
f01002b8:	85 d2                	test   %edx,%edx
f01002ba:	74 26                	je     f01002e2 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002bc:	a1 44 82 2a f0       	mov    0xf02a8244,%eax
f01002c1:	8d 48 01             	lea    0x1(%eax),%ecx
f01002c4:	89 0d 44 82 2a f0    	mov    %ecx,0xf02a8244
f01002ca:	88 90 40 80 2a f0    	mov    %dl,-0xfd57fc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002d0:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002d6:	75 0a                	jne    f01002e2 <cons_intr+0x35>
			cons.wpos = 0;
f01002d8:	c7 05 44 82 2a f0 00 	movl   $0x0,0xf02a8244
f01002df:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002e2:	ff d3                	call   *%ebx
f01002e4:	89 c2                	mov    %eax,%edx
f01002e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002e9:	75 cd                	jne    f01002b8 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002eb:	83 c4 04             	add    $0x4,%esp
f01002ee:	5b                   	pop    %ebx
f01002ef:	5d                   	pop    %ebp
f01002f0:	c3                   	ret    

f01002f1 <kbd_proc_data>:
f01002f1:	ba 64 00 00 00       	mov    $0x64,%edx
f01002f6:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002f7:	a8 01                	test   $0x1,%al
f01002f9:	0f 84 f0 00 00 00    	je     f01003ef <kbd_proc_data+0xfe>
f01002ff:	b2 60                	mov    $0x60,%dl
f0100301:	ec                   	in     (%dx),%al
f0100302:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100304:	3c e0                	cmp    $0xe0,%al
f0100306:	75 0d                	jne    f0100315 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100308:	83 0d 00 80 2a f0 40 	orl    $0x40,0xf02a8000
		return 0;
f010030f:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100314:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100315:	55                   	push   %ebp
f0100316:	89 e5                	mov    %esp,%ebp
f0100318:	53                   	push   %ebx
f0100319:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010031c:	84 c0                	test   %al,%al
f010031e:	79 36                	jns    f0100356 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100320:	8b 0d 00 80 2a f0    	mov    0xf02a8000,%ecx
f0100326:	89 cb                	mov    %ecx,%ebx
f0100328:	83 e3 40             	and    $0x40,%ebx
f010032b:	83 e0 7f             	and    $0x7f,%eax
f010032e:	85 db                	test   %ebx,%ebx
f0100330:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100333:	0f b6 d2             	movzbl %dl,%edx
f0100336:	0f b6 82 40 71 10 f0 	movzbl -0xfef8ec0(%edx),%eax
f010033d:	83 c8 40             	or     $0x40,%eax
f0100340:	0f b6 c0             	movzbl %al,%eax
f0100343:	f7 d0                	not    %eax
f0100345:	21 c8                	and    %ecx,%eax
f0100347:	a3 00 80 2a f0       	mov    %eax,0xf02a8000
		return 0;
f010034c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100351:	e9 a1 00 00 00       	jmp    f01003f7 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100356:	8b 0d 00 80 2a f0    	mov    0xf02a8000,%ecx
f010035c:	f6 c1 40             	test   $0x40,%cl
f010035f:	74 0e                	je     f010036f <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100361:	83 c8 80             	or     $0xffffff80,%eax
f0100364:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100366:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100369:	89 0d 00 80 2a f0    	mov    %ecx,0xf02a8000
	}

	shift |= shiftcode[data];
f010036f:	0f b6 c2             	movzbl %dl,%eax
f0100372:	0f b6 90 40 71 10 f0 	movzbl -0xfef8ec0(%eax),%edx
f0100379:	0b 15 00 80 2a f0    	or     0xf02a8000,%edx
	shift ^= togglecode[data];
f010037f:	0f b6 88 40 70 10 f0 	movzbl -0xfef8fc0(%eax),%ecx
f0100386:	31 ca                	xor    %ecx,%edx
f0100388:	89 15 00 80 2a f0    	mov    %edx,0xf02a8000

	c = charcode[shift & (CTL | SHIFT)][data];
f010038e:	89 d1                	mov    %edx,%ecx
f0100390:	83 e1 03             	and    $0x3,%ecx
f0100393:	8b 0c 8d 00 70 10 f0 	mov    -0xfef9000(,%ecx,4),%ecx
f010039a:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010039e:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f01003a1:	f6 c2 08             	test   $0x8,%dl
f01003a4:	74 1b                	je     f01003c1 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f01003a6:	89 d8                	mov    %ebx,%eax
f01003a8:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003ab:	83 f9 19             	cmp    $0x19,%ecx
f01003ae:	77 05                	ja     f01003b5 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f01003b0:	83 eb 20             	sub    $0x20,%ebx
f01003b3:	eb 0c                	jmp    f01003c1 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f01003b5:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f01003b8:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003bb:	83 f8 19             	cmp    $0x19,%eax
f01003be:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003c1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003c7:	75 2c                	jne    f01003f5 <kbd_proc_data+0x104>
f01003c9:	f7 d2                	not    %edx
f01003cb:	f6 c2 06             	test   $0x6,%dl
f01003ce:	75 25                	jne    f01003f5 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003d0:	83 ec 0c             	sub    $0xc,%esp
f01003d3:	68 c3 6f 10 f0       	push   $0xf0106fc3
f01003d8:	e8 80 33 00 00       	call   f010375d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003dd:	ba 92 00 00 00       	mov    $0x92,%edx
f01003e2:	b8 03 00 00 00       	mov    $0x3,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003eb:	89 d8                	mov    %ebx,%eax
f01003ed:	eb 08                	jmp    f01003f7 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003f4:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f5:	89 d8                	mov    %ebx,%eax
}
f01003f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003fa:	c9                   	leave  
f01003fb:	c3                   	ret    

f01003fc <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003fc:	55                   	push   %ebp
f01003fd:	89 e5                	mov    %esp,%ebp
f01003ff:	57                   	push   %edi
f0100400:	56                   	push   %esi
f0100401:	53                   	push   %ebx
f0100402:	83 ec 1c             	sub    $0x1c,%esp
f0100405:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100407:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040c:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100411:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100416:	eb 09                	jmp    f0100421 <cons_putc+0x25>
f0100418:	89 ca                	mov    %ecx,%edx
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
f010041c:	ec                   	in     (%dx),%al
f010041d:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010041e:	83 c3 01             	add    $0x1,%ebx
f0100421:	89 f2                	mov    %esi,%edx
f0100423:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100424:	a8 20                	test   $0x20,%al
f0100426:	75 08                	jne    f0100430 <cons_putc+0x34>
f0100428:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010042e:	7e e8                	jle    f0100418 <cons_putc+0x1c>
f0100430:	89 f8                	mov    %edi,%eax
f0100432:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100435:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010043a:	89 f8                	mov    %edi,%eax
f010043c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010043d:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100442:	be 79 03 00 00       	mov    $0x379,%esi
f0100447:	b9 84 00 00 00       	mov    $0x84,%ecx
f010044c:	eb 09                	jmp    f0100457 <cons_putc+0x5b>
f010044e:	89 ca                	mov    %ecx,%edx
f0100450:	ec                   	in     (%dx),%al
f0100451:	ec                   	in     (%dx),%al
f0100452:	ec                   	in     (%dx),%al
f0100453:	ec                   	in     (%dx),%al
f0100454:	83 c3 01             	add    $0x1,%ebx
f0100457:	89 f2                	mov    %esi,%edx
f0100459:	ec                   	in     (%dx),%al
f010045a:	84 c0                	test   %al,%al
f010045c:	78 08                	js     f0100466 <cons_putc+0x6a>
f010045e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100464:	7e e8                	jle    f010044e <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100466:	ba 78 03 00 00       	mov    $0x378,%edx
f010046b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010046f:	ee                   	out    %al,(%dx)
f0100470:	b2 7a                	mov    $0x7a,%dl
f0100472:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100477:	ee                   	out    %al,(%dx)
f0100478:	b8 08 00 00 00       	mov    $0x8,%eax
f010047d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010047e:	89 fa                	mov    %edi,%edx
f0100480:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100486:	89 f8                	mov    %edi,%eax
f0100488:	80 cc 07             	or     $0x7,%ah
f010048b:	85 d2                	test   %edx,%edx
f010048d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100490:	89 f8                	mov    %edi,%eax
f0100492:	0f b6 c0             	movzbl %al,%eax
f0100495:	83 f8 09             	cmp    $0x9,%eax
f0100498:	74 74                	je     f010050e <cons_putc+0x112>
f010049a:	83 f8 09             	cmp    $0x9,%eax
f010049d:	7f 0a                	jg     f01004a9 <cons_putc+0xad>
f010049f:	83 f8 08             	cmp    $0x8,%eax
f01004a2:	74 14                	je     f01004b8 <cons_putc+0xbc>
f01004a4:	e9 99 00 00 00       	jmp    f0100542 <cons_putc+0x146>
f01004a9:	83 f8 0a             	cmp    $0xa,%eax
f01004ac:	74 3a                	je     f01004e8 <cons_putc+0xec>
f01004ae:	83 f8 0d             	cmp    $0xd,%eax
f01004b1:	74 3d                	je     f01004f0 <cons_putc+0xf4>
f01004b3:	e9 8a 00 00 00       	jmp    f0100542 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f01004b8:	0f b7 05 48 82 2a f0 	movzwl 0xf02a8248,%eax
f01004bf:	66 85 c0             	test   %ax,%ax
f01004c2:	0f 84 e6 00 00 00    	je     f01005ae <cons_putc+0x1b2>
			crt_pos--;
f01004c8:	83 e8 01             	sub    $0x1,%eax
f01004cb:	66 a3 48 82 2a f0    	mov    %ax,0xf02a8248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d1:	0f b7 c0             	movzwl %ax,%eax
f01004d4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d9:	83 cf 20             	or     $0x20,%edi
f01004dc:	8b 15 4c 82 2a f0    	mov    0xf02a824c,%edx
f01004e2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004e6:	eb 78                	jmp    f0100560 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e8:	66 83 05 48 82 2a f0 	addw   $0x50,0xf02a8248
f01004ef:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004f0:	0f b7 05 48 82 2a f0 	movzwl 0xf02a8248,%eax
f01004f7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004fd:	c1 e8 16             	shr    $0x16,%eax
f0100500:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100503:	c1 e0 04             	shl    $0x4,%eax
f0100506:	66 a3 48 82 2a f0    	mov    %ax,0xf02a8248
f010050c:	eb 52                	jmp    f0100560 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f010050e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100513:	e8 e4 fe ff ff       	call   f01003fc <cons_putc>
		cons_putc(' ');
f0100518:	b8 20 00 00 00       	mov    $0x20,%eax
f010051d:	e8 da fe ff ff       	call   f01003fc <cons_putc>
		cons_putc(' ');
f0100522:	b8 20 00 00 00       	mov    $0x20,%eax
f0100527:	e8 d0 fe ff ff       	call   f01003fc <cons_putc>
		cons_putc(' ');
f010052c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100531:	e8 c6 fe ff ff       	call   f01003fc <cons_putc>
		cons_putc(' ');
f0100536:	b8 20 00 00 00       	mov    $0x20,%eax
f010053b:	e8 bc fe ff ff       	call   f01003fc <cons_putc>
f0100540:	eb 1e                	jmp    f0100560 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100542:	0f b7 05 48 82 2a f0 	movzwl 0xf02a8248,%eax
f0100549:	8d 50 01             	lea    0x1(%eax),%edx
f010054c:	66 89 15 48 82 2a f0 	mov    %dx,0xf02a8248
f0100553:	0f b7 c0             	movzwl %ax,%eax
f0100556:	8b 15 4c 82 2a f0    	mov    0xf02a824c,%edx
f010055c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100560:	66 81 3d 48 82 2a f0 	cmpw   $0x7cf,0xf02a8248
f0100567:	cf 07 
f0100569:	76 43                	jbe    f01005ae <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010056b:	a1 4c 82 2a f0       	mov    0xf02a824c,%eax
f0100570:	83 ec 04             	sub    $0x4,%esp
f0100573:	68 00 0f 00 00       	push   $0xf00
f0100578:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010057e:	52                   	push   %edx
f010057f:	50                   	push   %eax
f0100580:	e8 bf 53 00 00       	call   f0105944 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100585:	8b 15 4c 82 2a f0    	mov    0xf02a824c,%edx
f010058b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100591:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100597:	83 c4 10             	add    $0x10,%esp
f010059a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010059f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a2:	39 d0                	cmp    %edx,%eax
f01005a4:	75 f4                	jne    f010059a <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005a6:	66 83 2d 48 82 2a f0 	subw   $0x50,0xf02a8248
f01005ad:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005ae:	8b 0d 50 82 2a f0    	mov    0xf02a8250,%ecx
f01005b4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b9:	89 ca                	mov    %ecx,%edx
f01005bb:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005bc:	0f b7 1d 48 82 2a f0 	movzwl 0xf02a8248,%ebx
f01005c3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005c6:	89 d8                	mov    %ebx,%eax
f01005c8:	66 c1 e8 08          	shr    $0x8,%ax
f01005cc:	89 f2                	mov    %esi,%edx
f01005ce:	ee                   	out    %al,(%dx)
f01005cf:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d4:	89 ca                	mov    %ecx,%edx
f01005d6:	ee                   	out    %al,(%dx)
f01005d7:	89 d8                	mov    %ebx,%eax
f01005d9:	89 f2                	mov    %esi,%edx
f01005db:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005df:	5b                   	pop    %ebx
f01005e0:	5e                   	pop    %esi
f01005e1:	5f                   	pop    %edi
f01005e2:	5d                   	pop    %ebp
f01005e3:	c3                   	ret    

f01005e4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005e4:	80 3d 54 82 2a f0 00 	cmpb   $0x0,0xf02a8254
f01005eb:	74 11                	je     f01005fe <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005f3:	b8 91 02 10 f0       	mov    $0xf0100291,%eax
f01005f8:	e8 b0 fc ff ff       	call   f01002ad <cons_intr>
}
f01005fd:	c9                   	leave  
f01005fe:	f3 c3                	repz ret 

f0100600 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100606:	b8 f1 02 10 f0       	mov    $0xf01002f1,%eax
f010060b:	e8 9d fc ff ff       	call   f01002ad <cons_intr>
}
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100618:	e8 c7 ff ff ff       	call   f01005e4 <serial_intr>
	kbd_intr();
f010061d:	e8 de ff ff ff       	call   f0100600 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100622:	a1 40 82 2a f0       	mov    0xf02a8240,%eax
f0100627:	3b 05 44 82 2a f0    	cmp    0xf02a8244,%eax
f010062d:	74 26                	je     f0100655 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010062f:	8d 50 01             	lea    0x1(%eax),%edx
f0100632:	89 15 40 82 2a f0    	mov    %edx,0xf02a8240
f0100638:	0f b6 88 40 80 2a f0 	movzbl -0xfd57fc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010063f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100641:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100647:	75 11                	jne    f010065a <cons_getc+0x48>
			cons.rpos = 0;
f0100649:	c7 05 40 82 2a f0 00 	movl   $0x0,0xf02a8240
f0100650:	00 00 00 
f0100653:	eb 05                	jmp    f010065a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100655:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
f010065f:	57                   	push   %edi
f0100660:	56                   	push   %esi
f0100661:	53                   	push   %ebx
f0100662:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100665:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100673:	5a a5 
	if (*cp != 0xA55A) {
f0100675:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100680:	74 11                	je     f0100693 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100682:	c7 05 50 82 2a f0 b4 	movl   $0x3b4,0xf02a8250
f0100689:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100691:	eb 16                	jmp    f01006a9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100693:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069a:	c7 05 50 82 2a f0 d4 	movl   $0x3d4,0xf02a8250
f01006a1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a9:	8b 3d 50 82 2a f0    	mov    0xf02a8250,%edi
f01006af:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006b4:	89 fa                	mov    %edi,%edx
f01006b6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b7:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ba:	89 ca                	mov    %ecx,%edx
f01006bc:	ec                   	in     (%dx),%al
f01006bd:	0f b6 c0             	movzbl %al,%eax
f01006c0:	c1 e0 08             	shl    $0x8,%eax
f01006c3:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ca:	89 fa                	mov    %edi,%edx
f01006cc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 ca                	mov    %ecx,%edx
f01006cf:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006d0:	89 35 4c 82 2a f0    	mov    %esi,0xf02a824c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006d6:	0f b6 c8             	movzbl %al,%ecx
f01006d9:	89 d8                	mov    %ebx,%eax
f01006db:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006dd:	66 a3 48 82 2a f0    	mov    %ax,0xf02a8248

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006e3:	e8 18 ff ff ff       	call   f0100600 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006e8:	83 ec 0c             	sub    $0xc,%esp
f01006eb:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01006f2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f7:	50                   	push   %eax
f01006f8:	e8 14 2f 00 00       	call   f0103611 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fd:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100702:	b8 00 00 00 00       	mov    $0x0,%eax
f0100707:	89 da                	mov    %ebx,%edx
f0100709:	ee                   	out    %al,(%dx)
f010070a:	b2 fb                	mov    $0xfb,%dl
f010070c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100711:	ee                   	out    %al,(%dx)
f0100712:	be f8 03 00 00       	mov    $0x3f8,%esi
f0100717:	b8 0c 00 00 00       	mov    $0xc,%eax
f010071c:	89 f2                	mov    %esi,%edx
f010071e:	ee                   	out    %al,(%dx)
f010071f:	b2 f9                	mov    $0xf9,%dl
f0100721:	b8 00 00 00 00       	mov    $0x0,%eax
f0100726:	ee                   	out    %al,(%dx)
f0100727:	b2 fb                	mov    $0xfb,%dl
f0100729:	b8 03 00 00 00       	mov    $0x3,%eax
f010072e:	ee                   	out    %al,(%dx)
f010072f:	b2 fc                	mov    $0xfc,%dl
f0100731:	b8 00 00 00 00       	mov    $0x0,%eax
f0100736:	ee                   	out    %al,(%dx)
f0100737:	b2 f9                	mov    $0xf9,%dl
f0100739:	b8 01 00 00 00       	mov    $0x1,%eax
f010073e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073f:	b2 fd                	mov    $0xfd,%dl
f0100741:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100742:	83 c4 10             	add    $0x10,%esp
f0100745:	3c ff                	cmp    $0xff,%al
f0100747:	0f 95 c1             	setne  %cl
f010074a:	88 0d 54 82 2a f0    	mov    %cl,0xf02a8254
f0100750:	89 da                	mov    %ebx,%edx
f0100752:	ec                   	in     (%dx),%al
f0100753:	89 f2                	mov    %esi,%edx
f0100755:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100756:	84 c9                	test   %cl,%cl
f0100758:	74 21                	je     f010077b <cons_init+0x11f>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010075a:	83 ec 0c             	sub    $0xc,%esp
f010075d:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f0100764:	25 ef ff 00 00       	and    $0xffef,%eax
f0100769:	50                   	push   %eax
f010076a:	e8 a2 2e 00 00       	call   f0103611 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076f:	83 c4 10             	add    $0x10,%esp
f0100772:	80 3d 54 82 2a f0 00 	cmpb   $0x0,0xf02a8254
f0100779:	75 10                	jne    f010078b <cons_init+0x12f>
		cprintf("Serial port does not exist!\n");
f010077b:	83 ec 0c             	sub    $0xc,%esp
f010077e:	68 cf 6f 10 f0       	push   $0xf0106fcf
f0100783:	e8 d5 2f 00 00       	call   f010375d <cprintf>
f0100788:	83 c4 10             	add    $0x10,%esp
}
f010078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010078e:	5b                   	pop    %ebx
f010078f:	5e                   	pop    %esi
f0100790:	5f                   	pop    %edi
f0100791:	5d                   	pop    %ebp
f0100792:	c3                   	ret    

f0100793 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100793:	55                   	push   %ebp
f0100794:	89 e5                	mov    %esp,%ebp
f0100796:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100799:	8b 45 08             	mov    0x8(%ebp),%eax
f010079c:	e8 5b fc ff ff       	call   f01003fc <cons_putc>
}
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <getchar>:

int
getchar(void)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
f01007a6:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a9:	e8 64 fe ff ff       	call   f0100612 <cons_getc>
f01007ae:	85 c0                	test   %eax,%eax
f01007b0:	74 f7                	je     f01007a9 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b2:	c9                   	leave  
f01007b3:	c3                   	ret    

f01007b4 <iscons>:

int
iscons(int fdnum)
{
f01007b4:	55                   	push   %ebp
f01007b5:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01007bc:	5d                   	pop    %ebp
f01007bd:	c3                   	ret    

f01007be <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c4:	68 40 72 10 f0       	push   $0xf0107240
f01007c9:	68 5e 72 10 f0       	push   $0xf010725e
f01007ce:	68 63 72 10 f0       	push   $0xf0107263
f01007d3:	e8 85 2f 00 00       	call   f010375d <cprintf>
f01007d8:	83 c4 0c             	add    $0xc,%esp
f01007db:	68 10 73 10 f0       	push   $0xf0107310
f01007e0:	68 6c 72 10 f0       	push   $0xf010726c
f01007e5:	68 63 72 10 f0       	push   $0xf0107263
f01007ea:	e8 6e 2f 00 00       	call   f010375d <cprintf>
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	68 75 72 10 f0       	push   $0xf0107275
f01007f7:	68 88 72 10 f0       	push   $0xf0107288
f01007fc:	68 63 72 10 f0       	push   $0xf0107263
f0100801:	e8 57 2f 00 00       	call   f010375d <cprintf>
	return 0;
}
f0100806:	b8 00 00 00 00       	mov    $0x0,%eax
f010080b:	c9                   	leave  
f010080c:	c3                   	ret    

f010080d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010080d:	55                   	push   %ebp
f010080e:	89 e5                	mov    %esp,%ebp
f0100810:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100813:	68 92 72 10 f0       	push   $0xf0107292
f0100818:	e8 40 2f 00 00       	call   f010375d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010081d:	83 c4 08             	add    $0x8,%esp
f0100820:	68 0c 00 10 00       	push   $0x10000c
f0100825:	68 38 73 10 f0       	push   $0xf0107338
f010082a:	e8 2e 2f 00 00       	call   f010375d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082f:	83 c4 0c             	add    $0xc,%esp
f0100832:	68 0c 00 10 00       	push   $0x10000c
f0100837:	68 0c 00 10 f0       	push   $0xf010000c
f010083c:	68 60 73 10 f0       	push   $0xf0107360
f0100841:	e8 17 2f 00 00       	call   f010375d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	68 e5 6e 10 00       	push   $0x106ee5
f010084e:	68 e5 6e 10 f0       	push   $0xf0106ee5
f0100853:	68 84 73 10 f0       	push   $0xf0107384
f0100858:	e8 00 2f 00 00       	call   f010375d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085d:	83 c4 0c             	add    $0xc,%esp
f0100860:	68 00 80 2a 00       	push   $0x2a8000
f0100865:	68 00 80 2a f0       	push   $0xf02a8000
f010086a:	68 a8 73 10 f0       	push   $0xf01073a8
f010086f:	e8 e9 2e 00 00       	call   f010375d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100874:	83 c4 0c             	add    $0xc,%esp
f0100877:	68 10 a0 2e 00       	push   $0x2ea010
f010087c:	68 10 a0 2e f0       	push   $0xf02ea010
f0100881:	68 cc 73 10 f0       	push   $0xf01073cc
f0100886:	e8 d2 2e 00 00       	call   f010375d <cprintf>
f010088b:	b8 0f a4 2e f0       	mov    $0xf02ea40f,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100890:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100895:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100898:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a3:	85 c0                	test   %eax,%eax
f01008a5:	0f 48 c2             	cmovs  %edx,%eax
f01008a8:	c1 f8 0a             	sar    $0xa,%eax
f01008ab:	50                   	push   %eax
f01008ac:	68 f0 73 10 f0       	push   $0xf01073f0
f01008b1:	e8 a7 2e 00 00       	call   f010375d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008bb:	c9                   	leave  
f01008bc:	c3                   	ret    

f01008bd <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008bd:	55                   	push   %ebp
f01008be:	89 e5                	mov    %esp,%ebp
f01008c0:	57                   	push   %edi
f01008c1:	56                   	push   %esi
f01008c2:	53                   	push   %ebx
f01008c3:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c9:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f01008cb:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f01008cd:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f01008d0:	8b 50 08             	mov    0x8(%eax),%edx
f01008d3:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f01008d5:	8b 48 0c             	mov    0xc(%eax),%ecx
f01008d8:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f01008de:	8b 50 10             	mov    0x10(%eax),%edx
f01008e1:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f01008e7:	8b 48 14             	mov    0x14(%eax),%ecx
f01008ea:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f01008f0:	8b 40 18             	mov    0x18(%eax),%eax
f01008f3:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f01008f9:	68 ab 72 10 f0       	push   $0xf01072ab
f01008fe:	e8 5a 2e 00 00       	call   f010375d <cprintf>
        while(ebp != 0) {
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	89 f8                	mov    %edi,%eax
f0100908:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f010090e:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f0100914:	e9 92 00 00 00       	jmp    f01009ab <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f0100919:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f010091f:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f0100925:	51                   	push   %ecx
f0100926:	52                   	push   %edx
f0100927:	50                   	push   %eax
f0100928:	56                   	push   %esi
f0100929:	53                   	push   %ebx
f010092a:	68 1c 74 10 f0       	push   $0xf010741c
f010092f:	e8 29 2e 00 00       	call   f010375d <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f0100934:	83 c4 18             	add    $0x18,%esp
f0100937:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010093d:	50                   	push   %eax
f010093e:	56                   	push   %esi
f010093f:	e8 2c 45 00 00       	call   f0104e70 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f0100944:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f010094a:	68 16 75 10 f0       	push   $0xf0107516
f010094f:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f0100955:	83 c0 01             	add    $0x1,%eax
f0100958:	50                   	push   %eax
f0100959:	8d 45 84             	lea    -0x7c(%ebp),%eax
f010095c:	50                   	push   %eax
f010095d:	e8 0c 4d 00 00       	call   f010566e <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f0100962:	83 c4 14             	add    $0x14,%esp
f0100965:	89 f0                	mov    %esi,%eax
f0100967:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f010096d:	50                   	push   %eax
f010096e:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100971:	50                   	push   %eax
f0100972:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f0100978:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f010097e:	68 bd 72 10 f0       	push   $0xf01072bd
f0100983:	e8 d5 2d 00 00       	call   f010375d <cprintf>
             ebp = (uint32_t *)ebp[0];
f0100988:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f010098a:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f010098d:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f0100990:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f0100993:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f0100996:	8b 7b 14             	mov    0x14(%ebx),%edi
f0100999:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f010099f:	8b 7b 18             	mov    0x18(%ebx),%edi
f01009a2:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f01009a8:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f01009ab:	85 db                	test   %ebx,%ebx
f01009ad:	0f 85 66 ff ff ff    	jne    f0100919 <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f01009b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009bb:	5b                   	pop    %ebx
f01009bc:	5e                   	pop    %esi
f01009bd:	5f                   	pop    %edi
f01009be:	5d                   	pop    %ebp
f01009bf:	c3                   	ret    

f01009c0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009c0:	55                   	push   %ebp
f01009c1:	89 e5                	mov    %esp,%ebp
f01009c3:	57                   	push   %edi
f01009c4:	56                   	push   %esi
f01009c5:	53                   	push   %ebx
f01009c6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009c9:	68 54 74 10 f0       	push   $0xf0107454
f01009ce:	e8 8a 2d 00 00       	call   f010375d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d3:	c7 04 24 78 74 10 f0 	movl   $0xf0107478,(%esp)
f01009da:	e8 7e 2d 00 00       	call   f010375d <cprintf>
f01009df:	83 c4 10             	add    $0x10,%esp

	//if (tf != NULL)
	//	print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
f01009e2:	83 ec 0c             	sub    $0xc,%esp
f01009e5:	68 d4 72 10 f0       	push   $0xf01072d4
f01009ea:	e8 99 4c 00 00       	call   f0105688 <readline>
f01009ef:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	85 c0                	test   %eax,%eax
f01009f6:	74 ea                	je     f01009e2 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009f8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100a04:	eb 0a                	jmp    f0100a10 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a06:	c6 03 00             	movb   $0x0,(%ebx)
f0100a09:	89 f7                	mov    %esi,%edi
f0100a0b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a0e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a10:	0f b6 03             	movzbl (%ebx),%eax
f0100a13:	84 c0                	test   %al,%al
f0100a15:	74 63                	je     f0100a7a <monitor+0xba>
f0100a17:	83 ec 08             	sub    $0x8,%esp
f0100a1a:	0f be c0             	movsbl %al,%eax
f0100a1d:	50                   	push   %eax
f0100a1e:	68 d8 72 10 f0       	push   $0xf01072d8
f0100a23:	e8 92 4e 00 00       	call   f01058ba <strchr>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	75 d7                	jne    f0100a06 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100a2f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a32:	74 46                	je     f0100a7a <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a34:	83 fe 0f             	cmp    $0xf,%esi
f0100a37:	75 14                	jne    f0100a4d <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a39:	83 ec 08             	sub    $0x8,%esp
f0100a3c:	6a 10                	push   $0x10
f0100a3e:	68 dd 72 10 f0       	push   $0xf01072dd
f0100a43:	e8 15 2d 00 00       	call   f010375d <cprintf>
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	eb 95                	jmp    f01009e2 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100a4d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a50:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a54:	eb 03                	jmp    f0100a59 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a56:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a59:	0f b6 03             	movzbl (%ebx),%eax
f0100a5c:	84 c0                	test   %al,%al
f0100a5e:	74 ae                	je     f0100a0e <monitor+0x4e>
f0100a60:	83 ec 08             	sub    $0x8,%esp
f0100a63:	0f be c0             	movsbl %al,%eax
f0100a66:	50                   	push   %eax
f0100a67:	68 d8 72 10 f0       	push   $0xf01072d8
f0100a6c:	e8 49 4e 00 00       	call   f01058ba <strchr>
f0100a71:	83 c4 10             	add    $0x10,%esp
f0100a74:	85 c0                	test   %eax,%eax
f0100a76:	74 de                	je     f0100a56 <monitor+0x96>
f0100a78:	eb 94                	jmp    f0100a0e <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100a7a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a81:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a82:	85 f6                	test   %esi,%esi
f0100a84:	0f 84 58 ff ff ff    	je     f01009e2 <monitor+0x22>
f0100a8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8f:	83 ec 08             	sub    $0x8,%esp
f0100a92:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a95:	ff 34 85 a0 74 10 f0 	pushl  -0xfef8b60(,%eax,4)
f0100a9c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9f:	e8 b8 4d 00 00       	call   f010585c <strcmp>
f0100aa4:	83 c4 10             	add    $0x10,%esp
f0100aa7:	85 c0                	test   %eax,%eax
f0100aa9:	75 22                	jne    f0100acd <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100aab:	83 ec 04             	sub    $0x4,%esp
f0100aae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ab1:	ff 75 08             	pushl  0x8(%ebp)
f0100ab4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab7:	52                   	push   %edx
f0100ab8:	56                   	push   %esi
f0100ab9:	ff 14 85 a8 74 10 f0 	call   *-0xfef8b58(,%eax,4)
	//	print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ac0:	83 c4 10             	add    $0x10,%esp
f0100ac3:	85 c0                	test   %eax,%eax
f0100ac5:	0f 89 17 ff ff ff    	jns    f01009e2 <monitor+0x22>
f0100acb:	eb 20                	jmp    f0100aed <monitor+0x12d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100acd:	83 c3 01             	add    $0x1,%ebx
f0100ad0:	83 fb 03             	cmp    $0x3,%ebx
f0100ad3:	75 ba                	jne    f0100a8f <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad5:	83 ec 08             	sub    $0x8,%esp
f0100ad8:	ff 75 a8             	pushl  -0x58(%ebp)
f0100adb:	68 fa 72 10 f0       	push   $0xf01072fa
f0100ae0:	e8 78 2c 00 00       	call   f010375d <cprintf>
f0100ae5:	83 c4 10             	add    $0x10,%esp
f0100ae8:	e9 f5 fe ff ff       	jmp    f01009e2 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af0:	5b                   	pop    %ebx
f0100af1:	5e                   	pop    %esi
f0100af2:	5f                   	pop    %edi
f0100af3:	5d                   	pop    %ebp
f0100af4:	c3                   	ret    

f0100af5 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af5:	83 3d 5c 82 2a f0 00 	cmpl   $0x0,0xf02a825c
f0100afc:	75 11                	jne    f0100b0f <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100afe:	ba 0f b0 2e f0       	mov    $0xf02eb00f,%edx
f0100b03:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b09:	89 15 5c 82 2a f0    	mov    %edx,0xf02a825c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
f0100b0f:	85 c0                	test   %eax,%eax
f0100b11:	74 3d                	je     f0100b50 <boot_alloc+0x5b>
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100b13:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

		result = nextfree;
f0100b19:	a1 5c 82 2a f0       	mov    0xf02a825c,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100b1e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		result = nextfree;
		nextfree += alloc_size;
f0100b24:	01 c2                	add    %eax,%edx
f0100b26:	89 15 5c 82 2a f0    	mov    %edx,0xf02a825c

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
f0100b2c:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100b32:	76 21                	jbe    f0100b55 <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b34:	55                   	push   %ebp
f0100b35:	89 e5                	mov    %esp,%ebp
f0100b37:	83 ec 0c             	sub    $0xc,%esp

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
f0100b3a:	a3 5c 82 2a f0       	mov    %eax,0xf02a825c
                     result = NULL;
                     panic("boot_alloc: out of memory");
f0100b3f:	68 c4 74 10 f0       	push   $0xf01074c4
f0100b44:	6a 75                	push   $0x75
f0100b46:	68 de 74 10 f0       	push   $0xf01074de
f0100b4b:	e8 f0 f4 ff ff       	call   f0100040 <_panic>
                }

        
	} else {
		result = nextfree;
f0100b50:	a1 5c 82 2a f0       	mov    0xf02a825c,%eax
	}
	return result;
	
}
f0100b55:	f3 c3                	repz ret 

f0100b57 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b57:	89 d1                	mov    %edx,%ecx
f0100b59:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b5c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b5f:	a8 01                	test   $0x1,%al
f0100b61:	74 52                	je     f0100bb5 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b68:	89 c1                	mov    %eax,%ecx
f0100b6a:	c1 e9 0c             	shr    $0xc,%ecx
f0100b6d:	3b 0d d8 8e 2a f0    	cmp    0xf02a8ed8,%ecx
f0100b73:	72 1b                	jb     f0100b90 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b75:	55                   	push   %ebp
f0100b76:	89 e5                	mov    %esp,%ebp
f0100b78:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b7b:	50                   	push   %eax
f0100b7c:	68 24 6f 10 f0       	push   $0xf0106f24
f0100b81:	68 9e 03 00 00       	push   $0x39e
f0100b86:	68 de 74 10 f0       	push   $0xf01074de
f0100b8b:	e8 b0 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b90:	c1 ea 0c             	shr    $0xc,%edx
f0100b93:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b99:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ba0:	89 c2                	mov    %eax,%edx
f0100ba2:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100baa:	85 d2                	test   %edx,%edx
f0100bac:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bb1:	0f 44 c2             	cmove  %edx,%eax
f0100bb4:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bba:	c3                   	ret    

f0100bbb <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bbb:	55                   	push   %ebp
f0100bbc:	89 e5                	mov    %esp,%ebp
f0100bbe:	57                   	push   %edi
f0100bbf:	56                   	push   %esi
f0100bc0:	53                   	push   %ebx
f0100bc1:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bc4:	84 c0                	test   %al,%al
f0100bc6:	0f 85 a2 02 00 00    	jne    f0100e6e <check_page_free_list+0x2b3>
f0100bcc:	e9 af 02 00 00       	jmp    f0100e80 <check_page_free_list+0x2c5>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bd1:	83 ec 04             	sub    $0x4,%esp
f0100bd4:	68 28 78 10 f0       	push   $0xf0107828
f0100bd9:	68 d4 02 00 00       	push   $0x2d4
f0100bde:	68 de 74 10 f0       	push   $0xf01074de
f0100be3:	e8 58 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100be8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100beb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bee:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bf1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bf4:	89 c2                	mov    %eax,%edx
f0100bf6:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bfc:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c02:	0f 95 c2             	setne  %dl
f0100c05:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c08:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c0c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c0e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c12:	8b 00                	mov    (%eax),%eax
f0100c14:	85 c0                	test   %eax,%eax
f0100c16:	75 dc                	jne    f0100bf4 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c21:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c24:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c27:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c29:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c2c:	a3 64 82 2a f0       	mov    %eax,0xf02a8264
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c31:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c36:	8b 1d 64 82 2a f0    	mov    0xf02a8264,%ebx
f0100c3c:	eb 53                	jmp    f0100c91 <check_page_free_list+0xd6>
f0100c3e:	89 d8                	mov    %ebx,%eax
f0100c40:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0100c46:	c1 f8 03             	sar    $0x3,%eax
f0100c49:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c4c:	89 c2                	mov    %eax,%edx
f0100c4e:	c1 ea 16             	shr    $0x16,%edx
f0100c51:	39 f2                	cmp    %esi,%edx
f0100c53:	73 3a                	jae    f0100c8f <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c55:	89 c2                	mov    %eax,%edx
f0100c57:	c1 ea 0c             	shr    $0xc,%edx
f0100c5a:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0100c60:	72 12                	jb     f0100c74 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c62:	50                   	push   %eax
f0100c63:	68 24 6f 10 f0       	push   $0xf0106f24
f0100c68:	6a 58                	push   $0x58
f0100c6a:	68 ea 74 10 f0       	push   $0xf01074ea
f0100c6f:	e8 cc f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c74:	83 ec 04             	sub    $0x4,%esp
f0100c77:	68 80 00 00 00       	push   $0x80
f0100c7c:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c81:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c86:	50                   	push   %eax
f0100c87:	e8 6b 4c 00 00       	call   f01058f7 <memset>
f0100c8c:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c8f:	8b 1b                	mov    (%ebx),%ebx
f0100c91:	85 db                	test   %ebx,%ebx
f0100c93:	75 a9                	jne    f0100c3e <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c95:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9a:	e8 56 fe ff ff       	call   f0100af5 <boot_alloc>
f0100c9f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca2:	8b 15 64 82 2a f0    	mov    0xf02a8264,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ca8:	8b 0d e0 8e 2a f0    	mov    0xf02a8ee0,%ecx
		assert(pp < pages + npages);
f0100cae:	a1 d8 8e 2a f0       	mov    0xf02a8ed8,%eax
f0100cb3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100cb6:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cbc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cc1:	be 00 00 00 00       	mov    $0x0,%esi
f0100cc6:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100cc9:	89 d8                	mov    %ebx,%eax
f0100ccb:	89 cb                	mov    %ecx,%ebx
f0100ccd:	89 c1                	mov    %eax,%ecx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccf:	e9 55 01 00 00       	jmp    f0100e29 <check_page_free_list+0x26e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd4:	39 da                	cmp    %ebx,%edx
f0100cd6:	73 19                	jae    f0100cf1 <check_page_free_list+0x136>
f0100cd8:	68 f8 74 10 f0       	push   $0xf01074f8
f0100cdd:	68 04 75 10 f0       	push   $0xf0107504
f0100ce2:	68 ee 02 00 00       	push   $0x2ee
f0100ce7:	68 de 74 10 f0       	push   $0xf01074de
f0100cec:	e8 4f f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cf1:	39 ca                	cmp    %ecx,%edx
f0100cf3:	72 19                	jb     f0100d0e <check_page_free_list+0x153>
f0100cf5:	68 19 75 10 f0       	push   $0xf0107519
f0100cfa:	68 04 75 10 f0       	push   $0xf0107504
f0100cff:	68 ef 02 00 00       	push   $0x2ef
f0100d04:	68 de 74 10 f0       	push   $0xf01074de
f0100d09:	e8 32 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0e:	89 d0                	mov    %edx,%eax
f0100d10:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d13:	a8 07                	test   $0x7,%al
f0100d15:	74 19                	je     f0100d30 <check_page_free_list+0x175>
f0100d17:	68 4c 78 10 f0       	push   $0xf010784c
f0100d1c:	68 04 75 10 f0       	push   $0xf0107504
f0100d21:	68 f0 02 00 00       	push   $0x2f0
f0100d26:	68 de 74 10 f0       	push   $0xf01074de
f0100d2b:	e8 10 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d30:	c1 f8 03             	sar    $0x3,%eax
f0100d33:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d36:	85 c0                	test   %eax,%eax
f0100d38:	75 19                	jne    f0100d53 <check_page_free_list+0x198>
f0100d3a:	68 2d 75 10 f0       	push   $0xf010752d
f0100d3f:	68 04 75 10 f0       	push   $0xf0107504
f0100d44:	68 f3 02 00 00       	push   $0x2f3
f0100d49:	68 de 74 10 f0       	push   $0xf01074de
f0100d4e:	e8 ed f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d53:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d58:	75 19                	jne    f0100d73 <check_page_free_list+0x1b8>
f0100d5a:	68 3e 75 10 f0       	push   $0xf010753e
f0100d5f:	68 04 75 10 f0       	push   $0xf0107504
f0100d64:	68 f4 02 00 00       	push   $0x2f4
f0100d69:	68 de 74 10 f0       	push   $0xf01074de
f0100d6e:	e8 cd f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d73:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d78:	75 19                	jne    f0100d93 <check_page_free_list+0x1d8>
f0100d7a:	68 80 78 10 f0       	push   $0xf0107880
f0100d7f:	68 04 75 10 f0       	push   $0xf0107504
f0100d84:	68 f5 02 00 00       	push   $0x2f5
f0100d89:	68 de 74 10 f0       	push   $0xf01074de
f0100d8e:	e8 ad f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d93:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d98:	75 19                	jne    f0100db3 <check_page_free_list+0x1f8>
f0100d9a:	68 57 75 10 f0       	push   $0xf0107557
f0100d9f:	68 04 75 10 f0       	push   $0xf0107504
f0100da4:	68 f6 02 00 00       	push   $0x2f6
f0100da9:	68 de 74 10 f0       	push   $0xf01074de
f0100dae:	e8 8d f2 ff ff       	call   f0100040 <_panic>
f0100db3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100db6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dbb:	0f 86 d6 00 00 00    	jbe    f0100e97 <check_page_free_list+0x2dc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc1:	89 c6                	mov    %eax,%esi
f0100dc3:	c1 ee 0c             	shr    $0xc,%esi
f0100dc6:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100dc9:	77 12                	ja     f0100ddd <check_page_free_list+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dcb:	50                   	push   %eax
f0100dcc:	68 24 6f 10 f0       	push   $0xf0106f24
f0100dd1:	6a 58                	push   $0x58
f0100dd3:	68 ea 74 10 f0       	push   $0xf01074ea
f0100dd8:	e8 63 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ddd:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
f0100de3:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0100de6:	0f 86 b7 00 00 00    	jbe    f0100ea3 <check_page_free_list+0x2e8>
f0100dec:	68 a4 78 10 f0       	push   $0xf01078a4
f0100df1:	68 04 75 10 f0       	push   $0xf0107504
f0100df6:	68 f7 02 00 00       	push   $0x2f7
f0100dfb:	68 de 74 10 f0       	push   $0xf01074de
f0100e00:	e8 3b f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e05:	68 71 75 10 f0       	push   $0xf0107571
f0100e0a:	68 04 75 10 f0       	push   $0xf0107504
f0100e0f:	68 f9 02 00 00       	push   $0x2f9
f0100e14:	68 de 74 10 f0       	push   $0xf01074de
f0100e19:	e8 22 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e1e:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100e22:	eb 03                	jmp    f0100e27 <check_page_free_list+0x26c>
		else
			++nfree_extmem;
f0100e24:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e27:	8b 12                	mov    (%edx),%edx
f0100e29:	85 d2                	test   %edx,%edx
f0100e2b:	0f 85 a3 fe ff ff    	jne    f0100cd4 <check_page_free_list+0x119>
f0100e31:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e34:	85 f6                	test   %esi,%esi
f0100e36:	7f 19                	jg     f0100e51 <check_page_free_list+0x296>
f0100e38:	68 8e 75 10 f0       	push   $0xf010758e
f0100e3d:	68 04 75 10 f0       	push   $0xf0107504
f0100e42:	68 01 03 00 00       	push   $0x301
f0100e47:	68 de 74 10 f0       	push   $0xf01074de
f0100e4c:	e8 ef f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e51:	85 ff                	test   %edi,%edi
f0100e53:	7f 5e                	jg     f0100eb3 <check_page_free_list+0x2f8>
f0100e55:	68 a0 75 10 f0       	push   $0xf01075a0
f0100e5a:	68 04 75 10 f0       	push   $0xf0107504
f0100e5f:	68 02 03 00 00       	push   $0x302
f0100e64:	68 de 74 10 f0       	push   $0xf01074de
f0100e69:	e8 d2 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e6e:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f0100e73:	85 c0                	test   %eax,%eax
f0100e75:	0f 85 6d fd ff ff    	jne    f0100be8 <check_page_free_list+0x2d>
f0100e7b:	e9 51 fd ff ff       	jmp    f0100bd1 <check_page_free_list+0x16>
f0100e80:	83 3d 64 82 2a f0 00 	cmpl   $0x0,0xf02a8264
f0100e87:	0f 84 44 fd ff ff    	je     f0100bd1 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e8d:	be 00 04 00 00       	mov    $0x400,%esi
f0100e92:	e9 9f fd ff ff       	jmp    f0100c36 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e97:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e9c:	75 80                	jne    f0100e1e <check_page_free_list+0x263>
f0100e9e:	e9 62 ff ff ff       	jmp    f0100e05 <check_page_free_list+0x24a>
f0100ea3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea8:	0f 85 76 ff ff ff    	jne    f0100e24 <check_page_free_list+0x269>
f0100eae:	e9 52 ff ff ff       	jmp    f0100e05 <check_page_free_list+0x24a>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb6:	5b                   	pop    %ebx
f0100eb7:	5e                   	pop    %esi
f0100eb8:	5f                   	pop    %edi
f0100eb9:	5d                   	pop    %ebp
f0100eba:	c3                   	ret    

f0100ebb <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ebb:	55                   	push   %ebp
f0100ebc:	89 e5                	mov    %esp,%ebp
f0100ebe:	56                   	push   %esi
f0100ebf:	53                   	push   %ebx
f0100ec0:	8b 1d 64 82 2a f0    	mov    0xf02a8264,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ec6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ecb:	eb 22                	jmp    f0100eef <page_init+0x34>
f0100ecd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100ed4:	89 d1                	mov    %edx,%ecx
f0100ed6:	03 0d e0 8e 2a f0    	add    0xf02a8ee0,%ecx
f0100edc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ee2:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ee4:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100ee7:	89 d3                	mov    %edx,%ebx
f0100ee9:	03 1d e0 8e 2a f0    	add    0xf02a8ee0,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100eef:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0100ef5:	72 d6                	jb     f0100ecd <page_init+0x12>
f0100ef7:	89 1d 64 82 2a f0    	mov    %ebx,0xf02a8264
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
 
        pages[0].pp_ref = 1; 
f0100efd:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
f0100f02:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
        pages[1].pp_link = pages[0].pp_link;
f0100f08:	8b 10                	mov    (%eax),%edx
f0100f0a:	89 50 08             	mov    %edx,0x8(%eax)
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
f0100f0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f12:	e8 de fb ff ff       	call   f0100af5 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f17:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f1c:	77 15                	ja     f0100f33 <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f1e:	50                   	push   %eax
f0100f1f:	68 48 6f 10 f0       	push   $0xf0106f48
f0100f24:	68 53 01 00 00       	push   $0x153
f0100f29:	68 de 74 10 f0       	push   $0xf01074de
f0100f2e:	e8 0d f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f33:	05 00 00 00 10       	add    $0x10000000,%eax
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
f0100f38:	8b 15 e0 8e 2a f0    	mov    0xf02a8ee0,%edx
f0100f3e:	8b b2 00 05 00 00    	mov    0x500(%edx),%esi
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f44:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0100f49:	eb 20                	jmp    f0100f6b <page_init+0xb0>
              pages[i/PGSIZE].pp_ref = 1;  
f0100f4b:	89 d3                	mov    %edx,%ebx
f0100f4d:	c1 eb 0c             	shr    $0xc,%ebx
f0100f50:	8b 0d e0 8e 2a f0    	mov    0xf02a8ee0,%ecx
f0100f56:	8d 0c d9             	lea    (%ecx,%ebx,8),%ecx
f0100f59:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
              pages[i/PGSIZE].pp_link = NULL;     
f0100f5f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
        pages[0].pp_ref = 1; 
        pages[1].pp_link = pages[0].pp_link;
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f65:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100f6b:	39 c2                	cmp    %eax,%edx
f0100f6d:	72 dc                	jb     f0100f4b <page_init+0x90>
              pages[i/PGSIZE].pp_ref = 1;  
              pages[i/PGSIZE].pp_link = NULL;     
        }   
        pages[i/PGSIZE].pp_link = p;
f0100f6f:	c1 ea 0c             	shr    $0xc,%edx
f0100f72:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
f0100f77:	89 34 d0             	mov    %esi,(%eax,%edx,8)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f7a:	83 3d d8 8e 2a f0 07 	cmpl   $0x7,0xf02a8ed8
f0100f81:	77 14                	ja     f0100f97 <page_init+0xdc>
		panic("pa2page called with invalid pa");
f0100f83:	83 ec 04             	sub    $0x4,%esp
f0100f86:	68 ec 78 10 f0       	push   $0xf01078ec
f0100f8b:	6a 51                	push   $0x51
f0100f8d:	68 ea 74 10 f0       	push   $0xf01074ea
f0100f92:	e8 a9 f0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100f97:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
        p = pa2page(MPENTRY_PADDR);
        (p + 1)->pp_link = p->pp_link;
f0100f9c:	8b 50 38             	mov    0x38(%eax),%edx
f0100f9f:	89 50 40             	mov    %edx,0x40(%eax)
        p->pp_ref = 1;
f0100fa2:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
        p->pp_link = NULL;
f0100fa8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
 
}
f0100faf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fb2:	5b                   	pop    %ebx
f0100fb3:	5e                   	pop    %esi
f0100fb4:	5d                   	pop    %ebp
f0100fb5:	c3                   	ret    

f0100fb6 <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
       if ( page_free_list ) {
f0100fb6:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f0100fbb:	85 c0                	test   %eax,%eax
f0100fbd:	74 63                	je     f0101022 <page_alloc+0x6c>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in
       if ( page_free_list ) {
            if(alloc_flags & ALLOC_ZERO) 
f0100fc5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fc9:	74 43                	je     f010100e <page_alloc+0x58>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fcb:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0100fd1:	c1 f8 03             	sar    $0x3,%eax
f0100fd4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd7:	89 c2                	mov    %eax,%edx
f0100fd9:	c1 ea 0c             	shr    $0xc,%edx
f0100fdc:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0100fe2:	72 12                	jb     f0100ff6 <page_alloc+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe4:	50                   	push   %eax
f0100fe5:	68 24 6f 10 f0       	push   $0xf0106f24
f0100fea:	6a 58                	push   $0x58
f0100fec:	68 ea 74 10 f0       	push   $0xf01074ea
f0100ff1:	e8 4a f0 ff ff       	call   f0100040 <_panic>
                memset(page2kva(page_free_list), 0, PGSIZE);
f0100ff6:	83 ec 04             	sub    $0x4,%esp
f0100ff9:	68 00 10 00 00       	push   $0x1000
f0100ffe:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101000:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101005:	50                   	push   %eax
f0101006:	e8 ec 48 00 00       	call   f01058f7 <memset>
f010100b:	83 c4 10             	add    $0x10,%esp
               
            struct PageInfo *tmp = page_free_list;
f010100e:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
                 
            page_free_list = page_free_list->pp_link;
f0101013:	8b 10                	mov    (%eax),%edx
f0101015:	89 15 64 82 2a f0    	mov    %edx,0xf02a8264
            tmp->pp_link = NULL;
f010101b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            return tmp; 
            
        }
	return NULL;
}
f0101021:	c9                   	leave  
f0101022:	f3 c3                	repz ret 

f0101024 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101024:	55                   	push   %ebp
f0101025:	89 e5                	mov    %esp,%ebp
f0101027:	83 ec 08             	sub    $0x8,%esp
f010102a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.    
        if(pp == NULL) return;
f010102d:	85 c0                	test   %eax,%eax
f010102f:	74 30                	je     f0101061 <page_free+0x3d>
        if (pp->pp_ref != 0 || pp->pp_link != NULL) 
f0101031:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101036:	75 05                	jne    f010103d <page_free+0x19>
f0101038:	83 38 00             	cmpl   $0x0,(%eax)
f010103b:	74 17                	je     f0101054 <page_free+0x30>
            panic("page_free: invalid page free\n");
f010103d:	83 ec 04             	sub    $0x4,%esp
f0101040:	68 b1 75 10 f0       	push   $0xf01075b1
f0101045:	68 8b 01 00 00       	push   $0x18b
f010104a:	68 de 74 10 f0       	push   $0xf01074de
f010104f:	e8 ec ef ff ff       	call   f0100040 <_panic>
        else {
            pp->pp_link = page_free_list;
f0101054:	8b 15 64 82 2a f0    	mov    0xf02a8264,%edx
f010105a:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f010105c:	a3 64 82 2a f0       	mov    %eax,0xf02a8264
        }
}
f0101061:	c9                   	leave  
f0101062:	c3                   	ret    

f0101063 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101063:	55                   	push   %ebp
f0101064:	89 e5                	mov    %esp,%ebp
f0101066:	83 ec 08             	sub    $0x8,%esp
f0101069:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010106c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101070:	83 e8 01             	sub    $0x1,%eax
f0101073:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101077:	66 85 c0             	test   %ax,%ax
f010107a:	75 0c                	jne    f0101088 <page_decref+0x25>
		page_free(pp);
f010107c:	83 ec 0c             	sub    $0xc,%esp
f010107f:	52                   	push   %edx
f0101080:	e8 9f ff ff ff       	call   f0101024 <page_free>
f0101085:	83 c4 10             	add    $0x10,%esp
}
f0101088:	c9                   	leave  
f0101089:	c3                   	ret    

f010108a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010108a:	55                   	push   %ebp
f010108b:	89 e5                	mov    %esp,%ebp
f010108d:	56                   	push   %esi
f010108e:	53                   	push   %ebx
f010108f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t * pte;
        if ((pgdir[PDX(va)] & PTE_P) != 0) {
f0101092:	89 de                	mov    %ebx,%esi
f0101094:	c1 ee 16             	shr    $0x16,%esi
f0101097:	c1 e6 02             	shl    $0x2,%esi
f010109a:	03 75 08             	add    0x8(%ebp),%esi
f010109d:	8b 06                	mov    (%esi),%eax
f010109f:	a8 01                	test   $0x1,%al
f01010a1:	74 3c                	je     f01010df <pgdir_walk+0x55>
                pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f01010a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a8:	89 c2                	mov    %eax,%edx
f01010aa:	c1 ea 0c             	shr    $0xc,%edx
f01010ad:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f01010b3:	72 15                	jb     f01010ca <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b5:	50                   	push   %eax
f01010b6:	68 24 6f 10 f0       	push   $0xf0106f24
f01010bb:	68 b9 01 00 00       	push   $0x1b9
f01010c0:	68 de 74 10 f0       	push   $0xf01074de
f01010c5:	e8 76 ef ff ff       	call   f0100040 <_panic>
                return pte + PTX(va);  
f01010ca:	c1 eb 0a             	shr    $0xa,%ebx
f01010cd:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01010d3:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01010da:	e9 81 00 00 00       	jmp    f0101160 <pgdir_walk+0xd6>

 
        } 
        
        if(create != 0) {
f01010df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010e3:	74 6f                	je     f0101154 <pgdir_walk+0xca>
               struct PageInfo *tmp;
               tmp = page_alloc(1);
f01010e5:	83 ec 0c             	sub    $0xc,%esp
f01010e8:	6a 01                	push   $0x1
f01010ea:	e8 c7 fe ff ff       	call   f0100fb6 <page_alloc>
       
               if(tmp != NULL) {
f01010ef:	83 c4 10             	add    $0x10,%esp
f01010f2:	85 c0                	test   %eax,%eax
f01010f4:	74 65                	je     f010115b <pgdir_walk+0xd1>
                       
                        
                       tmp->pp_ref += 1;
f01010f6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
                       tmp->pp_link = NULL;
f01010fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101101:	89 c2                	mov    %eax,%edx
f0101103:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f0101109:	c1 fa 03             	sar    $0x3,%edx
f010110c:	c1 e2 0c             	shl    $0xc,%edx
                       pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
f010110f:	83 ca 07             	or     $0x7,%edx
f0101112:	89 16                	mov    %edx,(%esi)
f0101114:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f010111a:	c1 f8 03             	sar    $0x3,%eax
f010111d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101120:	89 c2                	mov    %eax,%edx
f0101122:	c1 ea 0c             	shr    $0xc,%edx
f0101125:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f010112b:	72 15                	jb     f0101142 <pgdir_walk+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010112d:	50                   	push   %eax
f010112e:	68 24 6f 10 f0       	push   $0xf0106f24
f0101133:	68 c9 01 00 00       	push   $0x1c9
f0101138:	68 de 74 10 f0       	push   $0xf01074de
f010113d:	e8 fe ee ff ff       	call   f0100040 <_panic>
                       pte = (pte_t *)KADDR(page2pa(tmp));
                  
                       return pte+PTX(va); 
f0101142:	c1 eb 0a             	shr    $0xa,%ebx
f0101145:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010114b:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101152:	eb 0c                	jmp    f0101160 <pgdir_walk+0xd6>

               }
               
        }

	return NULL;
f0101154:	b8 00 00 00 00       	mov    $0x0,%eax
f0101159:	eb 05                	jmp    f0101160 <pgdir_walk+0xd6>
f010115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101163:	5b                   	pop    %ebx
f0101164:	5e                   	pop    %esi
f0101165:	5d                   	pop    %ebp
f0101166:	c3                   	ret    

f0101167 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101167:	55                   	push   %ebp
f0101168:	89 e5                	mov    %esp,%ebp
f010116a:	57                   	push   %edi
f010116b:	56                   	push   %esi
f010116c:	53                   	push   %ebx
f010116d:	83 ec 1c             	sub    $0x1c,%esp
f0101170:	89 c7                	mov    %eax,%edi
f0101172:	89 55 e0             	mov    %edx,-0x20(%ebp)
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
f0101175:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010117b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101181:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0101184:	be 00 00 00 00       	mov    $0x0,%esi
f0101189:	8b 45 0c             	mov    0xc(%ebp),%eax
f010118c:	83 c8 01             	or     $0x1,%eax
f010118f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101192:	eb 3d                	jmp    f01011d1 <boot_map_region+0x6a>
              tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
f0101194:	83 ec 04             	sub    $0x4,%esp
f0101197:	6a 01                	push   $0x1
f0101199:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119c:	01 f0                	add    %esi,%eax
f010119e:	50                   	push   %eax
f010119f:	57                   	push   %edi
f01011a0:	e8 e5 fe ff ff       	call   f010108a <pgdir_walk>
              if ( tmp == NULL ) {
f01011a5:	83 c4 10             	add    $0x10,%esp
f01011a8:	85 c0                	test   %eax,%eax
f01011aa:	75 17                	jne    f01011c3 <boot_map_region+0x5c>
                     panic("boot_map_region: fail\n");
f01011ac:	83 ec 04             	sub    $0x4,%esp
f01011af:	68 cf 75 10 f0       	push   $0xf01075cf
f01011b4:	68 e9 01 00 00       	push   $0x1e9
f01011b9:	68 de 74 10 f0       	push   $0xf01074de
f01011be:	e8 7d ee ff ff       	call   f0100040 <_panic>
f01011c3:	03 5d 08             	add    0x8(%ebp),%ebx
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
f01011c6:	0b 5d dc             	or     -0x24(%ebp),%ebx
f01011c9:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f01011cb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01011d1:	89 f3                	mov    %esi,%ebx
f01011d3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01011d6:	77 bc                	ja     f0101194 <boot_map_region+0x2d>
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
 
        }
}
f01011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011db:	5b                   	pop    %ebx
f01011dc:	5e                   	pop    %esi
f01011dd:	5f                   	pop    %edi
f01011de:	5d                   	pop    %ebp
f01011df:	c3                   	ret    

f01011e0 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011e0:	55                   	push   %ebp
f01011e1:	89 e5                	mov    %esp,%ebp
f01011e3:	53                   	push   %ebx
f01011e4:	83 ec 08             	sub    $0x8,%esp
f01011e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 0);
f01011ea:	6a 00                	push   $0x0
f01011ec:	ff 75 0c             	pushl  0xc(%ebp)
f01011ef:	ff 75 08             	pushl  0x8(%ebp)
f01011f2:	e8 93 fe ff ff       	call   f010108a <pgdir_walk>
        if ( tmp != NULL && (*tmp & PTE_P)) {
f01011f7:	83 c4 10             	add    $0x10,%esp
f01011fa:	85 c0                	test   %eax,%eax
f01011fc:	74 37                	je     f0101235 <page_lookup+0x55>
f01011fe:	f6 00 01             	testb  $0x1,(%eax)
f0101201:	74 39                	je     f010123c <page_lookup+0x5c>
                if(pte_store != NULL) 
f0101203:	85 db                	test   %ebx,%ebx
f0101205:	74 02                	je     f0101209 <page_lookup+0x29>
                        *pte_store = tmp;
f0101207:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101209:	8b 00                	mov    (%eax),%eax
f010120b:	c1 e8 0c             	shr    $0xc,%eax
f010120e:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0101214:	72 14                	jb     f010122a <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101216:	83 ec 04             	sub    $0x4,%esp
f0101219:	68 ec 78 10 f0       	push   $0xf01078ec
f010121e:	6a 51                	push   $0x51
f0101220:	68 ea 74 10 f0       	push   $0xf01074ea
f0101225:	e8 16 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010122a:	8b 15 e0 8e 2a f0    	mov    0xf02a8ee0,%edx
f0101230:	8d 04 c2             	lea    (%edx,%eax,8),%eax
                return (struct PageInfo *)pa2page(*tmp);
f0101233:	eb 0c                	jmp    f0101241 <page_lookup+0x61>

        }
	return NULL;
f0101235:	b8 00 00 00 00       	mov    $0x0,%eax
f010123a:	eb 05                	jmp    f0101241 <page_lookup+0x61>
f010123c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101244:	c9                   	leave  
f0101245:	c3                   	ret    

f0101246 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101246:	55                   	push   %ebp
f0101247:	89 e5                	mov    %esp,%ebp
f0101249:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
//<<<<<<< HEAD
	if (!curenv || curenv->env_pgdir == pgdir)
f010124c:	e8 ca 4c 00 00       	call   f0105f1b <cpunum>
f0101251:	6b c0 74             	imul   $0x74,%eax,%eax
f0101254:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f010125b:	74 16                	je     f0101273 <tlb_invalidate+0x2d>
f010125d:	e8 b9 4c 00 00       	call   f0105f1b <cpunum>
f0101262:	6b c0 74             	imul   $0x74,%eax,%eax
f0101265:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010126b:	8b 55 08             	mov    0x8(%ebp),%edx
f010126e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101271:	75 06                	jne    f0101279 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101273:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101276:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101279:	c9                   	leave  
f010127a:	c3                   	ret    

f010127b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	56                   	push   %esi
f010127f:	53                   	push   %ebx
f0101280:	83 ec 14             	sub    $0x14,%esp
f0101283:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101286:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f0101289:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010128c:	50                   	push   %eax
f010128d:	56                   	push   %esi
f010128e:	53                   	push   %ebx
f010128f:	e8 4c ff ff ff       	call   f01011e0 <page_lookup>
        if( tmp != NULL && (*tmppte & PTE_P)) {
f0101294:	83 c4 10             	add    $0x10,%esp
f0101297:	85 c0                	test   %eax,%eax
f0101299:	74 1d                	je     f01012b8 <page_remove+0x3d>
f010129b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010129e:	f6 02 01             	testb  $0x1,(%edx)
f01012a1:	74 15                	je     f01012b8 <page_remove+0x3d>
                page_decref(tmp);
f01012a3:	83 ec 0c             	sub    $0xc,%esp
f01012a6:	50                   	push   %eax
f01012a7:	e8 b7 fd ff ff       	call   f0101063 <page_decref>
                *tmppte = 0;
f01012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01012b5:	83 c4 10             	add    $0x10,%esp
        }
        tlb_invalidate(pgdir, va);
f01012b8:	83 ec 08             	sub    $0x8,%esp
f01012bb:	56                   	push   %esi
f01012bc:	53                   	push   %ebx
f01012bd:	e8 84 ff ff ff       	call   f0101246 <tlb_invalidate>
f01012c2:	83 c4 10             	add    $0x10,%esp
}
f01012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c8:	5b                   	pop    %ebx
f01012c9:	5e                   	pop    %esi
f01012ca:	5d                   	pop    %ebp
f01012cb:	c3                   	ret    

f01012cc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012cc:	55                   	push   %ebp
f01012cd:	89 e5                	mov    %esp,%ebp
f01012cf:	57                   	push   %edi
f01012d0:	56                   	push   %esi
f01012d1:	53                   	push   %ebx
f01012d2:	83 ec 10             	sub    $0x10,%esp
f01012d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
f01012db:	6a 01                	push   $0x1
f01012dd:	57                   	push   %edi
f01012de:	ff 75 08             	pushl  0x8(%ebp)
f01012e1:	e8 a4 fd ff ff       	call   f010108a <pgdir_walk>
f01012e6:	89 c6                	mov    %eax,%esi
         
        if( tmp == NULL )
f01012e8:	83 c4 10             	add    $0x10,%esp
f01012eb:	85 c0                	test   %eax,%eax
f01012ed:	74 4d                	je     f010133c <page_insert+0x70>
                return -E_NO_MEM;

        pp->pp_ref += 1;
f01012ef:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
        if( (*tmp & PTE_P) == PTE_P )
f01012f4:	f6 00 01             	testb  $0x1,(%eax)
f01012f7:	74 0f                	je     f0101308 <page_insert+0x3c>
                page_remove(pgdir, va);
f01012f9:	83 ec 08             	sub    $0x8,%esp
f01012fc:	57                   	push   %edi
f01012fd:	ff 75 08             	pushl  0x8(%ebp)
f0101300:	e8 76 ff ff ff       	call   f010127b <page_remove>
f0101305:	83 c4 10             	add    $0x10,%esp
f0101308:	8b 55 14             	mov    0x14(%ebp),%edx
f010130b:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010130e:	89 d8                	mov    %ebx,%eax
f0101310:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0101316:	c1 f8 03             	sar    $0x3,%eax
f0101319:	c1 e0 0c             	shl    $0xc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
f010131c:	09 d0                	or     %edx,%eax
f010131e:	89 06                	mov    %eax,(%esi)
        pp->pp_link = NULL;
f0101320:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        tlb_invalidate(pgdir, va);
f0101326:	83 ec 08             	sub    $0x8,%esp
f0101329:	57                   	push   %edi
f010132a:	ff 75 08             	pushl  0x8(%ebp)
f010132d:	e8 14 ff ff ff       	call   f0101246 <tlb_invalidate>
	return 0;
f0101332:	83 c4 10             	add    $0x10,%esp
f0101335:	b8 00 00 00 00       	mov    $0x0,%eax
f010133a:	eb 05                	jmp    f0101341 <page_insert+0x75>
{
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        if( tmp == NULL )
                return -E_NO_MEM;
f010133c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
        pp->pp_link = NULL;
        tlb_invalidate(pgdir, va);
	return 0;
}
f0101341:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101344:	5b                   	pop    %ebx
f0101345:	5e                   	pop    %esi
f0101346:	5f                   	pop    %edi
f0101347:	5d                   	pop    %ebp
f0101348:	c3                   	ret    

f0101349 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101349:	55                   	push   %ebp
f010134a:	89 e5                	mov    %esp,%ebp
f010134c:	53                   	push   %ebx
f010134d:	83 ec 04             	sub    $0x4,%esp
	// Where to start the next region.  Initially, this is the
	// beginning of the MMIO region.  Because this is static, its
	// value will be preserved between calls to mmio_map_region
	// (just like nextfree in boot_alloc).
	static uintptr_t base;
        if (!base)
f0101350:	83 3d 58 82 2a f0 00 	cmpl   $0x0,0xf02a8258
f0101357:	75 0a                	jne    f0101363 <mmio_map_region+0x1a>
                base = MMIOBASE;
f0101359:	c7 05 58 82 2a f0 00 	movl   $0xef800000,0xf02a8258
f0101360:	00 80 ef 
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t roundsize = ROUNDUP(size, PGSIZE);
f0101363:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101366:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010136c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if( base + roundsize >= MMIOLIM )
f0101372:	8b 15 58 82 2a f0    	mov    0xf02a8258,%edx
f0101378:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010137b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101380:	76 17                	jbe    f0101399 <mmio_map_region+0x50>
                panic("Lapic required too much memory\n");
f0101382:	83 ec 04             	sub    $0x4,%esp
f0101385:	68 0c 79 10 f0       	push   $0xf010790c
f010138a:	68 82 02 00 00       	push   $0x282
f010138f:	68 de 74 10 f0       	push   $0xf01074de
f0101394:	e8 a7 ec ff ff       	call   f0100040 <_panic>
        boot_map_region(kern_pgdir, base, roundsize, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101399:	83 ec 08             	sub    $0x8,%esp
f010139c:	6a 1a                	push   $0x1a
f010139e:	ff 75 08             	pushl  0x8(%ebp)
f01013a1:	89 d9                	mov    %ebx,%ecx
f01013a3:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f01013a8:	e8 ba fd ff ff       	call   f0101167 <boot_map_region>
        base += roundsize; 
f01013ad:	a1 58 82 2a f0       	mov    0xf02a8258,%eax
f01013b2:	01 c3                	add    %eax,%ebx
f01013b4:	89 1d 58 82 2a f0    	mov    %ebx,0xf02a8258
	//panic("mmio_map_region not implemented");
        return (void *)(base - roundsize);
}
f01013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013bd:	c9                   	leave  
f01013be:	c3                   	ret    

f01013bf <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013bf:	55                   	push   %ebp
f01013c0:	89 e5                	mov    %esp,%ebp
f01013c2:	57                   	push   %edi
f01013c3:	56                   	push   %esi
f01013c4:	53                   	push   %ebx
f01013c5:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013c8:	6a 15                	push   $0x15
f01013ca:	e8 1a 22 00 00       	call   f01035e9 <mc146818_read>
f01013cf:	89 c3                	mov    %eax,%ebx
f01013d1:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013d8:	e8 0c 22 00 00       	call   f01035e9 <mc146818_read>
f01013dd:	c1 e0 08             	shl    $0x8,%eax
f01013e0:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013e2:	c1 e0 0a             	shl    $0xa,%eax
f01013e5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013eb:	85 c0                	test   %eax,%eax
f01013ed:	0f 48 c2             	cmovs  %edx,%eax
f01013f0:	c1 f8 0c             	sar    $0xc,%eax
f01013f3:	a3 68 82 2a f0       	mov    %eax,0xf02a8268
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013f8:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013ff:	e8 e5 21 00 00       	call   f01035e9 <mc146818_read>
f0101404:	89 c3                	mov    %eax,%ebx
f0101406:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010140d:	e8 d7 21 00 00       	call   f01035e9 <mc146818_read>
f0101412:	c1 e0 08             	shl    $0x8,%eax
f0101415:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101417:	c1 e0 0a             	shl    $0xa,%eax
f010141a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101420:	83 c4 10             	add    $0x10,%esp
f0101423:	85 c0                	test   %eax,%eax
f0101425:	0f 48 c2             	cmovs  %edx,%eax
f0101428:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010142b:	85 c0                	test   %eax,%eax
f010142d:	74 0e                	je     f010143d <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010142f:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101435:	89 15 d8 8e 2a f0    	mov    %edx,0xf02a8ed8
f010143b:	eb 0c                	jmp    f0101449 <mem_init+0x8a>
	else
		npages = npages_basemem;
f010143d:	8b 15 68 82 2a f0    	mov    0xf02a8268,%edx
f0101443:	89 15 d8 8e 2a f0    	mov    %edx,0xf02a8ed8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101449:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010144c:	c1 e8 0a             	shr    $0xa,%eax
f010144f:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101450:	a1 68 82 2a f0       	mov    0xf02a8268,%eax
f0101455:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101458:	c1 e8 0a             	shr    $0xa,%eax
f010145b:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010145c:	a1 d8 8e 2a f0       	mov    0xf02a8ed8,%eax
f0101461:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101464:	c1 e8 0a             	shr    $0xa,%eax
f0101467:	50                   	push   %eax
f0101468:	68 2c 79 10 f0       	push   $0xf010792c
f010146d:	e8 eb 22 00 00       	call   f010375d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101472:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101477:	e8 79 f6 ff ff       	call   f0100af5 <boot_alloc>
f010147c:	a3 dc 8e 2a f0       	mov    %eax,0xf02a8edc
	memset(kern_pgdir, 0, PGSIZE);
f0101481:	83 c4 0c             	add    $0xc,%esp
f0101484:	68 00 10 00 00       	push   $0x1000
f0101489:	6a 00                	push   $0x0
f010148b:	50                   	push   %eax
f010148c:	e8 66 44 00 00       	call   f01058f7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101491:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101496:	83 c4 10             	add    $0x10,%esp
f0101499:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010149e:	77 15                	ja     f01014b5 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014a0:	50                   	push   %eax
f01014a1:	68 48 6f 10 f0       	push   $0xf0106f48
f01014a6:	68 a1 00 00 00       	push   $0xa1
f01014ab:	68 de 74 10 f0       	push   $0xf01074de
f01014b0:	e8 8b eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01014b5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014bb:	83 ca 05             	or     $0x5,%edx
f01014be:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo));
f01014c4:	a1 d8 8e 2a f0       	mov    0xf02a8ed8,%eax
f01014c9:	c1 e0 03             	shl    $0x3,%eax
f01014cc:	e8 24 f6 ff ff       	call   f0100af5 <boot_alloc>
f01014d1:	a3 e0 8e 2a f0       	mov    %eax,0xf02a8ee0
        memset(pages, 0, npages * sizeof(struct PageInfo));
f01014d6:	83 ec 04             	sub    $0x4,%esp
f01014d9:	8b 0d d8 8e 2a f0    	mov    0xf02a8ed8,%ecx
f01014df:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01014e6:	52                   	push   %edx
f01014e7:	6a 00                	push   $0x0
f01014e9:	50                   	push   %eax
f01014ea:	e8 08 44 00 00       	call   f01058f7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        envs = boot_alloc(NENV * sizeof(struct Env));
f01014ef:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014f4:	e8 fc f5 ff ff       	call   f0100af5 <boot_alloc>
f01014f9:	a3 6c 82 2a f0       	mov    %eax,0xf02a826c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014fe:	e8 b8 f9 ff ff       	call   f0100ebb <page_init>

	check_page_free_list(1);
f0101503:	b8 01 00 00 00       	mov    $0x1,%eax
f0101508:	e8 ae f6 ff ff       	call   f0100bbb <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010150d:	83 c4 10             	add    $0x10,%esp
f0101510:	83 3d e0 8e 2a f0 00 	cmpl   $0x0,0xf02a8ee0
f0101517:	75 17                	jne    f0101530 <mem_init+0x171>
		panic("'pages' is a null pointer!");
f0101519:	83 ec 04             	sub    $0x4,%esp
f010151c:	68 e6 75 10 f0       	push   $0xf01075e6
f0101521:	68 13 03 00 00       	push   $0x313
f0101526:	68 de 74 10 f0       	push   $0xf01074de
f010152b:	e8 10 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101530:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f0101535:	bb 00 00 00 00       	mov    $0x0,%ebx
f010153a:	eb 05                	jmp    f0101541 <mem_init+0x182>
		++nfree;
f010153c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010153f:	8b 00                	mov    (%eax),%eax
f0101541:	85 c0                	test   %eax,%eax
f0101543:	75 f7                	jne    f010153c <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101545:	83 ec 0c             	sub    $0xc,%esp
f0101548:	6a 00                	push   $0x0
f010154a:	e8 67 fa ff ff       	call   f0100fb6 <page_alloc>
f010154f:	89 c7                	mov    %eax,%edi
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	85 c0                	test   %eax,%eax
f0101556:	75 19                	jne    f0101571 <mem_init+0x1b2>
f0101558:	68 01 76 10 f0       	push   $0xf0107601
f010155d:	68 04 75 10 f0       	push   $0xf0107504
f0101562:	68 1b 03 00 00       	push   $0x31b
f0101567:	68 de 74 10 f0       	push   $0xf01074de
f010156c:	e8 cf ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101571:	83 ec 0c             	sub    $0xc,%esp
f0101574:	6a 00                	push   $0x0
f0101576:	e8 3b fa ff ff       	call   f0100fb6 <page_alloc>
f010157b:	89 c6                	mov    %eax,%esi
f010157d:	83 c4 10             	add    $0x10,%esp
f0101580:	85 c0                	test   %eax,%eax
f0101582:	75 19                	jne    f010159d <mem_init+0x1de>
f0101584:	68 17 76 10 f0       	push   $0xf0107617
f0101589:	68 04 75 10 f0       	push   $0xf0107504
f010158e:	68 1c 03 00 00       	push   $0x31c
f0101593:	68 de 74 10 f0       	push   $0xf01074de
f0101598:	e8 a3 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010159d:	83 ec 0c             	sub    $0xc,%esp
f01015a0:	6a 00                	push   $0x0
f01015a2:	e8 0f fa ff ff       	call   f0100fb6 <page_alloc>
f01015a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015aa:	83 c4 10             	add    $0x10,%esp
f01015ad:	85 c0                	test   %eax,%eax
f01015af:	75 19                	jne    f01015ca <mem_init+0x20b>
f01015b1:	68 2d 76 10 f0       	push   $0xf010762d
f01015b6:	68 04 75 10 f0       	push   $0xf0107504
f01015bb:	68 1d 03 00 00       	push   $0x31d
f01015c0:	68 de 74 10 f0       	push   $0xf01074de
f01015c5:	e8 76 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015ca:	39 f7                	cmp    %esi,%edi
f01015cc:	75 19                	jne    f01015e7 <mem_init+0x228>
f01015ce:	68 43 76 10 f0       	push   $0xf0107643
f01015d3:	68 04 75 10 f0       	push   $0xf0107504
f01015d8:	68 20 03 00 00       	push   $0x320
f01015dd:	68 de 74 10 f0       	push   $0xf01074de
f01015e2:	e8 59 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015ea:	39 c7                	cmp    %eax,%edi
f01015ec:	74 04                	je     f01015f2 <mem_init+0x233>
f01015ee:	39 c6                	cmp    %eax,%esi
f01015f0:	75 19                	jne    f010160b <mem_init+0x24c>
f01015f2:	68 68 79 10 f0       	push   $0xf0107968
f01015f7:	68 04 75 10 f0       	push   $0xf0107504
f01015fc:	68 21 03 00 00       	push   $0x321
f0101601:	68 de 74 10 f0       	push   $0xf01074de
f0101606:	e8 35 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010160b:	8b 0d e0 8e 2a f0    	mov    0xf02a8ee0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101611:	8b 15 d8 8e 2a f0    	mov    0xf02a8ed8,%edx
f0101617:	c1 e2 0c             	shl    $0xc,%edx
f010161a:	89 f8                	mov    %edi,%eax
f010161c:	29 c8                	sub    %ecx,%eax
f010161e:	c1 f8 03             	sar    $0x3,%eax
f0101621:	c1 e0 0c             	shl    $0xc,%eax
f0101624:	39 d0                	cmp    %edx,%eax
f0101626:	72 19                	jb     f0101641 <mem_init+0x282>
f0101628:	68 55 76 10 f0       	push   $0xf0107655
f010162d:	68 04 75 10 f0       	push   $0xf0107504
f0101632:	68 22 03 00 00       	push   $0x322
f0101637:	68 de 74 10 f0       	push   $0xf01074de
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>
f0101641:	89 f0                	mov    %esi,%eax
f0101643:	29 c8                	sub    %ecx,%eax
f0101645:	c1 f8 03             	sar    $0x3,%eax
f0101648:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010164b:	39 c2                	cmp    %eax,%edx
f010164d:	77 19                	ja     f0101668 <mem_init+0x2a9>
f010164f:	68 72 76 10 f0       	push   $0xf0107672
f0101654:	68 04 75 10 f0       	push   $0xf0107504
f0101659:	68 23 03 00 00       	push   $0x323
f010165e:	68 de 74 10 f0       	push   $0xf01074de
f0101663:	e8 d8 e9 ff ff       	call   f0100040 <_panic>
f0101668:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166b:	29 c8                	sub    %ecx,%eax
f010166d:	c1 f8 03             	sar    $0x3,%eax
f0101670:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101673:	39 c2                	cmp    %eax,%edx
f0101675:	77 19                	ja     f0101690 <mem_init+0x2d1>
f0101677:	68 8f 76 10 f0       	push   $0xf010768f
f010167c:	68 04 75 10 f0       	push   $0xf0107504
f0101681:	68 24 03 00 00       	push   $0x324
f0101686:	68 de 74 10 f0       	push   $0xf01074de
f010168b:	e8 b0 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101690:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f0101695:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101698:	c7 05 64 82 2a f0 00 	movl   $0x0,0xf02a8264
f010169f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016a2:	83 ec 0c             	sub    $0xc,%esp
f01016a5:	6a 00                	push   $0x0
f01016a7:	e8 0a f9 ff ff       	call   f0100fb6 <page_alloc>
f01016ac:	83 c4 10             	add    $0x10,%esp
f01016af:	85 c0                	test   %eax,%eax
f01016b1:	74 19                	je     f01016cc <mem_init+0x30d>
f01016b3:	68 ac 76 10 f0       	push   $0xf01076ac
f01016b8:	68 04 75 10 f0       	push   $0xf0107504
f01016bd:	68 2b 03 00 00       	push   $0x32b
f01016c2:	68 de 74 10 f0       	push   $0xf01074de
f01016c7:	e8 74 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016cc:	83 ec 0c             	sub    $0xc,%esp
f01016cf:	57                   	push   %edi
f01016d0:	e8 4f f9 ff ff       	call   f0101024 <page_free>
	page_free(pp1);
f01016d5:	89 34 24             	mov    %esi,(%esp)
f01016d8:	e8 47 f9 ff ff       	call   f0101024 <page_free>
	page_free(pp2);
f01016dd:	83 c4 04             	add    $0x4,%esp
f01016e0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016e3:	e8 3c f9 ff ff       	call   f0101024 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016ef:	e8 c2 f8 ff ff       	call   f0100fb6 <page_alloc>
f01016f4:	89 c6                	mov    %eax,%esi
f01016f6:	83 c4 10             	add    $0x10,%esp
f01016f9:	85 c0                	test   %eax,%eax
f01016fb:	75 19                	jne    f0101716 <mem_init+0x357>
f01016fd:	68 01 76 10 f0       	push   $0xf0107601
f0101702:	68 04 75 10 f0       	push   $0xf0107504
f0101707:	68 32 03 00 00       	push   $0x332
f010170c:	68 de 74 10 f0       	push   $0xf01074de
f0101711:	e8 2a e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101716:	83 ec 0c             	sub    $0xc,%esp
f0101719:	6a 00                	push   $0x0
f010171b:	e8 96 f8 ff ff       	call   f0100fb6 <page_alloc>
f0101720:	89 c7                	mov    %eax,%edi
f0101722:	83 c4 10             	add    $0x10,%esp
f0101725:	85 c0                	test   %eax,%eax
f0101727:	75 19                	jne    f0101742 <mem_init+0x383>
f0101729:	68 17 76 10 f0       	push   $0xf0107617
f010172e:	68 04 75 10 f0       	push   $0xf0107504
f0101733:	68 33 03 00 00       	push   $0x333
f0101738:	68 de 74 10 f0       	push   $0xf01074de
f010173d:	e8 fe e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101742:	83 ec 0c             	sub    $0xc,%esp
f0101745:	6a 00                	push   $0x0
f0101747:	e8 6a f8 ff ff       	call   f0100fb6 <page_alloc>
f010174c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010174f:	83 c4 10             	add    $0x10,%esp
f0101752:	85 c0                	test   %eax,%eax
f0101754:	75 19                	jne    f010176f <mem_init+0x3b0>
f0101756:	68 2d 76 10 f0       	push   $0xf010762d
f010175b:	68 04 75 10 f0       	push   $0xf0107504
f0101760:	68 34 03 00 00       	push   $0x334
f0101765:	68 de 74 10 f0       	push   $0xf01074de
f010176a:	e8 d1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010176f:	39 fe                	cmp    %edi,%esi
f0101771:	75 19                	jne    f010178c <mem_init+0x3cd>
f0101773:	68 43 76 10 f0       	push   $0xf0107643
f0101778:	68 04 75 10 f0       	push   $0xf0107504
f010177d:	68 36 03 00 00       	push   $0x336
f0101782:	68 de 74 10 f0       	push   $0xf01074de
f0101787:	e8 b4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010178c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010178f:	39 c6                	cmp    %eax,%esi
f0101791:	74 04                	je     f0101797 <mem_init+0x3d8>
f0101793:	39 c7                	cmp    %eax,%edi
f0101795:	75 19                	jne    f01017b0 <mem_init+0x3f1>
f0101797:	68 68 79 10 f0       	push   $0xf0107968
f010179c:	68 04 75 10 f0       	push   $0xf0107504
f01017a1:	68 37 03 00 00       	push   $0x337
f01017a6:	68 de 74 10 f0       	push   $0xf01074de
f01017ab:	e8 90 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017b0:	83 ec 0c             	sub    $0xc,%esp
f01017b3:	6a 00                	push   $0x0
f01017b5:	e8 fc f7 ff ff       	call   f0100fb6 <page_alloc>
f01017ba:	83 c4 10             	add    $0x10,%esp
f01017bd:	85 c0                	test   %eax,%eax
f01017bf:	74 19                	je     f01017da <mem_init+0x41b>
f01017c1:	68 ac 76 10 f0       	push   $0xf01076ac
f01017c6:	68 04 75 10 f0       	push   $0xf0107504
f01017cb:	68 38 03 00 00       	push   $0x338
f01017d0:	68 de 74 10 f0       	push   $0xf01074de
f01017d5:	e8 66 e8 ff ff       	call   f0100040 <_panic>
f01017da:	89 f0                	mov    %esi,%eax
f01017dc:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f01017e2:	c1 f8 03             	sar    $0x3,%eax
f01017e5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017e8:	89 c2                	mov    %eax,%edx
f01017ea:	c1 ea 0c             	shr    $0xc,%edx
f01017ed:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f01017f3:	72 12                	jb     f0101807 <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f5:	50                   	push   %eax
f01017f6:	68 24 6f 10 f0       	push   $0xf0106f24
f01017fb:	6a 58                	push   $0x58
f01017fd:	68 ea 74 10 f0       	push   $0xf01074ea
f0101802:	e8 39 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101807:	83 ec 04             	sub    $0x4,%esp
f010180a:	68 00 10 00 00       	push   $0x1000
f010180f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101811:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101816:	50                   	push   %eax
f0101817:	e8 db 40 00 00       	call   f01058f7 <memset>
	page_free(pp0);
f010181c:	89 34 24             	mov    %esi,(%esp)
f010181f:	e8 00 f8 ff ff       	call   f0101024 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101824:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010182b:	e8 86 f7 ff ff       	call   f0100fb6 <page_alloc>
f0101830:	83 c4 10             	add    $0x10,%esp
f0101833:	85 c0                	test   %eax,%eax
f0101835:	75 19                	jne    f0101850 <mem_init+0x491>
f0101837:	68 bb 76 10 f0       	push   $0xf01076bb
f010183c:	68 04 75 10 f0       	push   $0xf0107504
f0101841:	68 3d 03 00 00       	push   $0x33d
f0101846:	68 de 74 10 f0       	push   $0xf01074de
f010184b:	e8 f0 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101850:	39 c6                	cmp    %eax,%esi
f0101852:	74 19                	je     f010186d <mem_init+0x4ae>
f0101854:	68 d9 76 10 f0       	push   $0xf01076d9
f0101859:	68 04 75 10 f0       	push   $0xf0107504
f010185e:	68 3e 03 00 00       	push   $0x33e
f0101863:	68 de 74 10 f0       	push   $0xf01074de
f0101868:	e8 d3 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010186d:	89 f0                	mov    %esi,%eax
f010186f:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0101875:	c1 f8 03             	sar    $0x3,%eax
f0101878:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010187b:	89 c2                	mov    %eax,%edx
f010187d:	c1 ea 0c             	shr    $0xc,%edx
f0101880:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0101886:	72 12                	jb     f010189a <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101888:	50                   	push   %eax
f0101889:	68 24 6f 10 f0       	push   $0xf0106f24
f010188e:	6a 58                	push   $0x58
f0101890:	68 ea 74 10 f0       	push   $0xf01074ea
f0101895:	e8 a6 e7 ff ff       	call   f0100040 <_panic>
f010189a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018a0:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018a6:	80 38 00             	cmpb   $0x0,(%eax)
f01018a9:	74 19                	je     f01018c4 <mem_init+0x505>
f01018ab:	68 e9 76 10 f0       	push   $0xf01076e9
f01018b0:	68 04 75 10 f0       	push   $0xf0107504
f01018b5:	68 41 03 00 00       	push   $0x341
f01018ba:	68 de 74 10 f0       	push   $0xf01074de
f01018bf:	e8 7c e7 ff ff       	call   f0100040 <_panic>
f01018c4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018c7:	39 d0                	cmp    %edx,%eax
f01018c9:	75 db                	jne    f01018a6 <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018ce:	a3 64 82 2a f0       	mov    %eax,0xf02a8264

	// free the pages we took
	page_free(pp0);
f01018d3:	83 ec 0c             	sub    $0xc,%esp
f01018d6:	56                   	push   %esi
f01018d7:	e8 48 f7 ff ff       	call   f0101024 <page_free>
	page_free(pp1);
f01018dc:	89 3c 24             	mov    %edi,(%esp)
f01018df:	e8 40 f7 ff ff       	call   f0101024 <page_free>
	page_free(pp2);
f01018e4:	83 c4 04             	add    $0x4,%esp
f01018e7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ea:	e8 35 f7 ff ff       	call   f0101024 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018ef:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f01018f4:	83 c4 10             	add    $0x10,%esp
f01018f7:	eb 05                	jmp    f01018fe <mem_init+0x53f>
		--nfree;
f01018f9:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018fc:	8b 00                	mov    (%eax),%eax
f01018fe:	85 c0                	test   %eax,%eax
f0101900:	75 f7                	jne    f01018f9 <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f0101902:	85 db                	test   %ebx,%ebx
f0101904:	74 19                	je     f010191f <mem_init+0x560>
f0101906:	68 f3 76 10 f0       	push   $0xf01076f3
f010190b:	68 04 75 10 f0       	push   $0xf0107504
f0101910:	68 4e 03 00 00       	push   $0x34e
f0101915:	68 de 74 10 f0       	push   $0xf01074de
f010191a:	e8 21 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010191f:	83 ec 0c             	sub    $0xc,%esp
f0101922:	68 88 79 10 f0       	push   $0xf0107988
f0101927:	e8 31 1e 00 00       	call   f010375d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010192c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101933:	e8 7e f6 ff ff       	call   f0100fb6 <page_alloc>
f0101938:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010193b:	83 c4 10             	add    $0x10,%esp
f010193e:	85 c0                	test   %eax,%eax
f0101940:	75 19                	jne    f010195b <mem_init+0x59c>
f0101942:	68 01 76 10 f0       	push   $0xf0107601
f0101947:	68 04 75 10 f0       	push   $0xf0107504
f010194c:	68 b3 03 00 00       	push   $0x3b3
f0101951:	68 de 74 10 f0       	push   $0xf01074de
f0101956:	e8 e5 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010195b:	83 ec 0c             	sub    $0xc,%esp
f010195e:	6a 00                	push   $0x0
f0101960:	e8 51 f6 ff ff       	call   f0100fb6 <page_alloc>
f0101965:	89 c3                	mov    %eax,%ebx
f0101967:	83 c4 10             	add    $0x10,%esp
f010196a:	85 c0                	test   %eax,%eax
f010196c:	75 19                	jne    f0101987 <mem_init+0x5c8>
f010196e:	68 17 76 10 f0       	push   $0xf0107617
f0101973:	68 04 75 10 f0       	push   $0xf0107504
f0101978:	68 b4 03 00 00       	push   $0x3b4
f010197d:	68 de 74 10 f0       	push   $0xf01074de
f0101982:	e8 b9 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101987:	83 ec 0c             	sub    $0xc,%esp
f010198a:	6a 00                	push   $0x0
f010198c:	e8 25 f6 ff ff       	call   f0100fb6 <page_alloc>
f0101991:	89 c6                	mov    %eax,%esi
f0101993:	83 c4 10             	add    $0x10,%esp
f0101996:	85 c0                	test   %eax,%eax
f0101998:	75 19                	jne    f01019b3 <mem_init+0x5f4>
f010199a:	68 2d 76 10 f0       	push   $0xf010762d
f010199f:	68 04 75 10 f0       	push   $0xf0107504
f01019a4:	68 b5 03 00 00       	push   $0x3b5
f01019a9:	68 de 74 10 f0       	push   $0xf01074de
f01019ae:	e8 8d e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019b3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01019b6:	75 19                	jne    f01019d1 <mem_init+0x612>
f01019b8:	68 43 76 10 f0       	push   $0xf0107643
f01019bd:	68 04 75 10 f0       	push   $0xf0107504
f01019c2:	68 b8 03 00 00       	push   $0x3b8
f01019c7:	68 de 74 10 f0       	push   $0xf01074de
f01019cc:	e8 6f e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019d1:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019d4:	74 04                	je     f01019da <mem_init+0x61b>
f01019d6:	39 c3                	cmp    %eax,%ebx
f01019d8:	75 19                	jne    f01019f3 <mem_init+0x634>
f01019da:	68 68 79 10 f0       	push   $0xf0107968
f01019df:	68 04 75 10 f0       	push   $0xf0107504
f01019e4:	68 b9 03 00 00       	push   $0x3b9
f01019e9:	68 de 74 10 f0       	push   $0xf01074de
f01019ee:	e8 4d e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019f3:	a1 64 82 2a f0       	mov    0xf02a8264,%eax
f01019f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019fb:	c7 05 64 82 2a f0 00 	movl   $0x0,0xf02a8264
f0101a02:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a05:	83 ec 0c             	sub    $0xc,%esp
f0101a08:	6a 00                	push   $0x0
f0101a0a:	e8 a7 f5 ff ff       	call   f0100fb6 <page_alloc>
f0101a0f:	83 c4 10             	add    $0x10,%esp
f0101a12:	85 c0                	test   %eax,%eax
f0101a14:	74 19                	je     f0101a2f <mem_init+0x670>
f0101a16:	68 ac 76 10 f0       	push   $0xf01076ac
f0101a1b:	68 04 75 10 f0       	push   $0xf0107504
f0101a20:	68 c0 03 00 00       	push   $0x3c0
f0101a25:	68 de 74 10 f0       	push   $0xf01074de
f0101a2a:	e8 11 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a2f:	83 ec 04             	sub    $0x4,%esp
f0101a32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a35:	50                   	push   %eax
f0101a36:	6a 00                	push   $0x0
f0101a38:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101a3e:	e8 9d f7 ff ff       	call   f01011e0 <page_lookup>
f0101a43:	83 c4 10             	add    $0x10,%esp
f0101a46:	85 c0                	test   %eax,%eax
f0101a48:	74 19                	je     f0101a63 <mem_init+0x6a4>
f0101a4a:	68 a8 79 10 f0       	push   $0xf01079a8
f0101a4f:	68 04 75 10 f0       	push   $0xf0107504
f0101a54:	68 c3 03 00 00       	push   $0x3c3
f0101a59:	68 de 74 10 f0       	push   $0xf01074de
f0101a5e:	e8 dd e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a63:	6a 02                	push   $0x2
f0101a65:	6a 00                	push   $0x0
f0101a67:	53                   	push   %ebx
f0101a68:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101a6e:	e8 59 f8 ff ff       	call   f01012cc <page_insert>
f0101a73:	83 c4 10             	add    $0x10,%esp
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	78 19                	js     f0101a93 <mem_init+0x6d4>
f0101a7a:	68 e0 79 10 f0       	push   $0xf01079e0
f0101a7f:	68 04 75 10 f0       	push   $0xf0107504
f0101a84:	68 c6 03 00 00       	push   $0x3c6
f0101a89:	68 de 74 10 f0       	push   $0xf01074de
f0101a8e:	e8 ad e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a93:	83 ec 0c             	sub    $0xc,%esp
f0101a96:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a99:	e8 86 f5 ff ff       	call   f0101024 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a9e:	6a 02                	push   $0x2
f0101aa0:	6a 00                	push   $0x0
f0101aa2:	53                   	push   %ebx
f0101aa3:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101aa9:	e8 1e f8 ff ff       	call   f01012cc <page_insert>
f0101aae:	83 c4 20             	add    $0x20,%esp
f0101ab1:	85 c0                	test   %eax,%eax
f0101ab3:	74 19                	je     f0101ace <mem_init+0x70f>
f0101ab5:	68 10 7a 10 f0       	push   $0xf0107a10
f0101aba:	68 04 75 10 f0       	push   $0xf0107504
f0101abf:	68 ca 03 00 00       	push   $0x3ca
f0101ac4:	68 de 74 10 f0       	push   $0xf01074de
f0101ac9:	e8 72 e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ace:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ad4:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
f0101ad9:	89 c1                	mov    %eax,%ecx
f0101adb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ade:	8b 17                	mov    (%edi),%edx
f0101ae0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ae6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ae9:	29 c8                	sub    %ecx,%eax
f0101aeb:	c1 f8 03             	sar    $0x3,%eax
f0101aee:	c1 e0 0c             	shl    $0xc,%eax
f0101af1:	39 c2                	cmp    %eax,%edx
f0101af3:	74 19                	je     f0101b0e <mem_init+0x74f>
f0101af5:	68 40 7a 10 f0       	push   $0xf0107a40
f0101afa:	68 04 75 10 f0       	push   $0xf0107504
f0101aff:	68 cb 03 00 00       	push   $0x3cb
f0101b04:	68 de 74 10 f0       	push   $0xf01074de
f0101b09:	e8 32 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b13:	89 f8                	mov    %edi,%eax
f0101b15:	e8 3d f0 ff ff       	call   f0100b57 <check_va2pa>
f0101b1a:	89 da                	mov    %ebx,%edx
f0101b1c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b1f:	c1 fa 03             	sar    $0x3,%edx
f0101b22:	c1 e2 0c             	shl    $0xc,%edx
f0101b25:	39 d0                	cmp    %edx,%eax
f0101b27:	74 19                	je     f0101b42 <mem_init+0x783>
f0101b29:	68 68 7a 10 f0       	push   $0xf0107a68
f0101b2e:	68 04 75 10 f0       	push   $0xf0107504
f0101b33:	68 cc 03 00 00       	push   $0x3cc
f0101b38:	68 de 74 10 f0       	push   $0xf01074de
f0101b3d:	e8 fe e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101b42:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b47:	74 19                	je     f0101b62 <mem_init+0x7a3>
f0101b49:	68 fe 76 10 f0       	push   $0xf01076fe
f0101b4e:	68 04 75 10 f0       	push   $0xf0107504
f0101b53:	68 cd 03 00 00       	push   $0x3cd
f0101b58:	68 de 74 10 f0       	push   $0xf01074de
f0101b5d:	e8 de e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101b62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b65:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b6a:	74 19                	je     f0101b85 <mem_init+0x7c6>
f0101b6c:	68 0f 77 10 f0       	push   $0xf010770f
f0101b71:	68 04 75 10 f0       	push   $0xf0107504
f0101b76:	68 ce 03 00 00       	push   $0x3ce
f0101b7b:	68 de 74 10 f0       	push   $0xf01074de
f0101b80:	e8 bb e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b85:	6a 02                	push   $0x2
f0101b87:	68 00 10 00 00       	push   $0x1000
f0101b8c:	56                   	push   %esi
f0101b8d:	57                   	push   %edi
f0101b8e:	e8 39 f7 ff ff       	call   f01012cc <page_insert>
f0101b93:	83 c4 10             	add    $0x10,%esp
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	74 19                	je     f0101bb3 <mem_init+0x7f4>
f0101b9a:	68 98 7a 10 f0       	push   $0xf0107a98
f0101b9f:	68 04 75 10 f0       	push   $0xf0107504
f0101ba4:	68 d1 03 00 00       	push   $0x3d1
f0101ba9:	68 de 74 10 f0       	push   $0xf01074de
f0101bae:	e8 8d e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bb3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bb8:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0101bbd:	e8 95 ef ff ff       	call   f0100b57 <check_va2pa>
f0101bc2:	89 f2                	mov    %esi,%edx
f0101bc4:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f0101bca:	c1 fa 03             	sar    $0x3,%edx
f0101bcd:	c1 e2 0c             	shl    $0xc,%edx
f0101bd0:	39 d0                	cmp    %edx,%eax
f0101bd2:	74 19                	je     f0101bed <mem_init+0x82e>
f0101bd4:	68 d4 7a 10 f0       	push   $0xf0107ad4
f0101bd9:	68 04 75 10 f0       	push   $0xf0107504
f0101bde:	68 d2 03 00 00       	push   $0x3d2
f0101be3:	68 de 74 10 f0       	push   $0xf01074de
f0101be8:	e8 53 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bed:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bf2:	74 19                	je     f0101c0d <mem_init+0x84e>
f0101bf4:	68 20 77 10 f0       	push   $0xf0107720
f0101bf9:	68 04 75 10 f0       	push   $0xf0107504
f0101bfe:	68 d3 03 00 00       	push   $0x3d3
f0101c03:	68 de 74 10 f0       	push   $0xf01074de
f0101c08:	e8 33 e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c0d:	83 ec 0c             	sub    $0xc,%esp
f0101c10:	6a 00                	push   $0x0
f0101c12:	e8 9f f3 ff ff       	call   f0100fb6 <page_alloc>
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	74 19                	je     f0101c37 <mem_init+0x878>
f0101c1e:	68 ac 76 10 f0       	push   $0xf01076ac
f0101c23:	68 04 75 10 f0       	push   $0xf0107504
f0101c28:	68 d6 03 00 00       	push   $0x3d6
f0101c2d:	68 de 74 10 f0       	push   $0xf01074de
f0101c32:	e8 09 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c37:	6a 02                	push   $0x2
f0101c39:	68 00 10 00 00       	push   $0x1000
f0101c3e:	56                   	push   %esi
f0101c3f:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101c45:	e8 82 f6 ff ff       	call   f01012cc <page_insert>
f0101c4a:	83 c4 10             	add    $0x10,%esp
f0101c4d:	85 c0                	test   %eax,%eax
f0101c4f:	74 19                	je     f0101c6a <mem_init+0x8ab>
f0101c51:	68 98 7a 10 f0       	push   $0xf0107a98
f0101c56:	68 04 75 10 f0       	push   $0xf0107504
f0101c5b:	68 d9 03 00 00       	push   $0x3d9
f0101c60:	68 de 74 10 f0       	push   $0xf01074de
f0101c65:	e8 d6 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c6f:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0101c74:	e8 de ee ff ff       	call   f0100b57 <check_va2pa>
f0101c79:	89 f2                	mov    %esi,%edx
f0101c7b:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f0101c81:	c1 fa 03             	sar    $0x3,%edx
f0101c84:	c1 e2 0c             	shl    $0xc,%edx
f0101c87:	39 d0                	cmp    %edx,%eax
f0101c89:	74 19                	je     f0101ca4 <mem_init+0x8e5>
f0101c8b:	68 d4 7a 10 f0       	push   $0xf0107ad4
f0101c90:	68 04 75 10 f0       	push   $0xf0107504
f0101c95:	68 da 03 00 00       	push   $0x3da
f0101c9a:	68 de 74 10 f0       	push   $0xf01074de
f0101c9f:	e8 9c e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca9:	74 19                	je     f0101cc4 <mem_init+0x905>
f0101cab:	68 20 77 10 f0       	push   $0xf0107720
f0101cb0:	68 04 75 10 f0       	push   $0xf0107504
f0101cb5:	68 db 03 00 00       	push   $0x3db
f0101cba:	68 de 74 10 f0       	push   $0xf01074de
f0101cbf:	e8 7c e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cc4:	83 ec 0c             	sub    $0xc,%esp
f0101cc7:	6a 00                	push   $0x0
f0101cc9:	e8 e8 f2 ff ff       	call   f0100fb6 <page_alloc>
f0101cce:	83 c4 10             	add    $0x10,%esp
f0101cd1:	85 c0                	test   %eax,%eax
f0101cd3:	74 19                	je     f0101cee <mem_init+0x92f>
f0101cd5:	68 ac 76 10 f0       	push   $0xf01076ac
f0101cda:	68 04 75 10 f0       	push   $0xf0107504
f0101cdf:	68 df 03 00 00       	push   $0x3df
f0101ce4:	68 de 74 10 f0       	push   $0xf01074de
f0101ce9:	e8 52 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cee:	8b 15 dc 8e 2a f0    	mov    0xf02a8edc,%edx
f0101cf4:	8b 02                	mov    (%edx),%eax
f0101cf6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cfb:	89 c1                	mov    %eax,%ecx
f0101cfd:	c1 e9 0c             	shr    $0xc,%ecx
f0101d00:	3b 0d d8 8e 2a f0    	cmp    0xf02a8ed8,%ecx
f0101d06:	72 15                	jb     f0101d1d <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d08:	50                   	push   %eax
f0101d09:	68 24 6f 10 f0       	push   $0xf0106f24
f0101d0e:	68 e2 03 00 00       	push   $0x3e2
f0101d13:	68 de 74 10 f0       	push   $0xf01074de
f0101d18:	e8 23 e3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101d1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d25:	83 ec 04             	sub    $0x4,%esp
f0101d28:	6a 00                	push   $0x0
f0101d2a:	68 00 10 00 00       	push   $0x1000
f0101d2f:	52                   	push   %edx
f0101d30:	e8 55 f3 ff ff       	call   f010108a <pgdir_walk>
f0101d35:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d38:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d3b:	83 c4 10             	add    $0x10,%esp
f0101d3e:	39 d0                	cmp    %edx,%eax
f0101d40:	74 19                	je     f0101d5b <mem_init+0x99c>
f0101d42:	68 04 7b 10 f0       	push   $0xf0107b04
f0101d47:	68 04 75 10 f0       	push   $0xf0107504
f0101d4c:	68 e3 03 00 00       	push   $0x3e3
f0101d51:	68 de 74 10 f0       	push   $0xf01074de
f0101d56:	e8 e5 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d5b:	6a 06                	push   $0x6
f0101d5d:	68 00 10 00 00       	push   $0x1000
f0101d62:	56                   	push   %esi
f0101d63:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101d69:	e8 5e f5 ff ff       	call   f01012cc <page_insert>
f0101d6e:	83 c4 10             	add    $0x10,%esp
f0101d71:	85 c0                	test   %eax,%eax
f0101d73:	74 19                	je     f0101d8e <mem_init+0x9cf>
f0101d75:	68 44 7b 10 f0       	push   $0xf0107b44
f0101d7a:	68 04 75 10 f0       	push   $0xf0107504
f0101d7f:	68 e6 03 00 00       	push   $0x3e6
f0101d84:	68 de 74 10 f0       	push   $0xf01074de
f0101d89:	e8 b2 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d8e:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
f0101d94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d99:	89 f8                	mov    %edi,%eax
f0101d9b:	e8 b7 ed ff ff       	call   f0100b57 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101da0:	89 f2                	mov    %esi,%edx
f0101da2:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f0101da8:	c1 fa 03             	sar    $0x3,%edx
f0101dab:	c1 e2 0c             	shl    $0xc,%edx
f0101dae:	39 d0                	cmp    %edx,%eax
f0101db0:	74 19                	je     f0101dcb <mem_init+0xa0c>
f0101db2:	68 d4 7a 10 f0       	push   $0xf0107ad4
f0101db7:	68 04 75 10 f0       	push   $0xf0107504
f0101dbc:	68 e7 03 00 00       	push   $0x3e7
f0101dc1:	68 de 74 10 f0       	push   $0xf01074de
f0101dc6:	e8 75 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101dcb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dd0:	74 19                	je     f0101deb <mem_init+0xa2c>
f0101dd2:	68 20 77 10 f0       	push   $0xf0107720
f0101dd7:	68 04 75 10 f0       	push   $0xf0107504
f0101ddc:	68 e8 03 00 00       	push   $0x3e8
f0101de1:	68 de 74 10 f0       	push   $0xf01074de
f0101de6:	e8 55 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101deb:	83 ec 04             	sub    $0x4,%esp
f0101dee:	6a 00                	push   $0x0
f0101df0:	68 00 10 00 00       	push   $0x1000
f0101df5:	57                   	push   %edi
f0101df6:	e8 8f f2 ff ff       	call   f010108a <pgdir_walk>
f0101dfb:	83 c4 10             	add    $0x10,%esp
f0101dfe:	f6 00 04             	testb  $0x4,(%eax)
f0101e01:	75 19                	jne    f0101e1c <mem_init+0xa5d>
f0101e03:	68 84 7b 10 f0       	push   $0xf0107b84
f0101e08:	68 04 75 10 f0       	push   $0xf0107504
f0101e0d:	68 e9 03 00 00       	push   $0x3e9
f0101e12:	68 de 74 10 f0       	push   $0xf01074de
f0101e17:	e8 24 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e1c:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0101e21:	f6 00 04             	testb  $0x4,(%eax)
f0101e24:	75 19                	jne    f0101e3f <mem_init+0xa80>
f0101e26:	68 31 77 10 f0       	push   $0xf0107731
f0101e2b:	68 04 75 10 f0       	push   $0xf0107504
f0101e30:	68 ea 03 00 00       	push   $0x3ea
f0101e35:	68 de 74 10 f0       	push   $0xf01074de
f0101e3a:	e8 01 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e3f:	6a 02                	push   $0x2
f0101e41:	68 00 10 00 00       	push   $0x1000
f0101e46:	56                   	push   %esi
f0101e47:	50                   	push   %eax
f0101e48:	e8 7f f4 ff ff       	call   f01012cc <page_insert>
f0101e4d:	83 c4 10             	add    $0x10,%esp
f0101e50:	85 c0                	test   %eax,%eax
f0101e52:	74 19                	je     f0101e6d <mem_init+0xaae>
f0101e54:	68 98 7a 10 f0       	push   $0xf0107a98
f0101e59:	68 04 75 10 f0       	push   $0xf0107504
f0101e5e:	68 ed 03 00 00       	push   $0x3ed
f0101e63:	68 de 74 10 f0       	push   $0xf01074de
f0101e68:	e8 d3 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e6d:	83 ec 04             	sub    $0x4,%esp
f0101e70:	6a 00                	push   $0x0
f0101e72:	68 00 10 00 00       	push   $0x1000
f0101e77:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101e7d:	e8 08 f2 ff ff       	call   f010108a <pgdir_walk>
f0101e82:	83 c4 10             	add    $0x10,%esp
f0101e85:	f6 00 02             	testb  $0x2,(%eax)
f0101e88:	75 19                	jne    f0101ea3 <mem_init+0xae4>
f0101e8a:	68 b8 7b 10 f0       	push   $0xf0107bb8
f0101e8f:	68 04 75 10 f0       	push   $0xf0107504
f0101e94:	68 ee 03 00 00       	push   $0x3ee
f0101e99:	68 de 74 10 f0       	push   $0xf01074de
f0101e9e:	e8 9d e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ea3:	83 ec 04             	sub    $0x4,%esp
f0101ea6:	6a 00                	push   $0x0
f0101ea8:	68 00 10 00 00       	push   $0x1000
f0101ead:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101eb3:	e8 d2 f1 ff ff       	call   f010108a <pgdir_walk>
f0101eb8:	83 c4 10             	add    $0x10,%esp
f0101ebb:	f6 00 04             	testb  $0x4,(%eax)
f0101ebe:	74 19                	je     f0101ed9 <mem_init+0xb1a>
f0101ec0:	68 ec 7b 10 f0       	push   $0xf0107bec
f0101ec5:	68 04 75 10 f0       	push   $0xf0107504
f0101eca:	68 ef 03 00 00       	push   $0x3ef
f0101ecf:	68 de 74 10 f0       	push   $0xf01074de
f0101ed4:	e8 67 e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ed9:	6a 02                	push   $0x2
f0101edb:	68 00 00 40 00       	push   $0x400000
f0101ee0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ee3:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101ee9:	e8 de f3 ff ff       	call   f01012cc <page_insert>
f0101eee:	83 c4 10             	add    $0x10,%esp
f0101ef1:	85 c0                	test   %eax,%eax
f0101ef3:	78 19                	js     f0101f0e <mem_init+0xb4f>
f0101ef5:	68 24 7c 10 f0       	push   $0xf0107c24
f0101efa:	68 04 75 10 f0       	push   $0xf0107504
f0101eff:	68 f2 03 00 00       	push   $0x3f2
f0101f04:	68 de 74 10 f0       	push   $0xf01074de
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f0e:	6a 02                	push   $0x2
f0101f10:	68 00 10 00 00       	push   $0x1000
f0101f15:	53                   	push   %ebx
f0101f16:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101f1c:	e8 ab f3 ff ff       	call   f01012cc <page_insert>
f0101f21:	83 c4 10             	add    $0x10,%esp
f0101f24:	85 c0                	test   %eax,%eax
f0101f26:	74 19                	je     f0101f41 <mem_init+0xb82>
f0101f28:	68 5c 7c 10 f0       	push   $0xf0107c5c
f0101f2d:	68 04 75 10 f0       	push   $0xf0107504
f0101f32:	68 f5 03 00 00       	push   $0x3f5
f0101f37:	68 de 74 10 f0       	push   $0xf01074de
f0101f3c:	e8 ff e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f41:	83 ec 04             	sub    $0x4,%esp
f0101f44:	6a 00                	push   $0x0
f0101f46:	68 00 10 00 00       	push   $0x1000
f0101f4b:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0101f51:	e8 34 f1 ff ff       	call   f010108a <pgdir_walk>
f0101f56:	83 c4 10             	add    $0x10,%esp
f0101f59:	f6 00 04             	testb  $0x4,(%eax)
f0101f5c:	74 19                	je     f0101f77 <mem_init+0xbb8>
f0101f5e:	68 ec 7b 10 f0       	push   $0xf0107bec
f0101f63:	68 04 75 10 f0       	push   $0xf0107504
f0101f68:	68 f6 03 00 00       	push   $0x3f6
f0101f6d:	68 de 74 10 f0       	push   $0xf01074de
f0101f72:	e8 c9 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f77:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
f0101f7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f82:	89 f8                	mov    %edi,%eax
f0101f84:	e8 ce eb ff ff       	call   f0100b57 <check_va2pa>
f0101f89:	89 c1                	mov    %eax,%ecx
f0101f8b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f8e:	89 d8                	mov    %ebx,%eax
f0101f90:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0101f96:	c1 f8 03             	sar    $0x3,%eax
f0101f99:	c1 e0 0c             	shl    $0xc,%eax
f0101f9c:	39 c1                	cmp    %eax,%ecx
f0101f9e:	74 19                	je     f0101fb9 <mem_init+0xbfa>
f0101fa0:	68 98 7c 10 f0       	push   $0xf0107c98
f0101fa5:	68 04 75 10 f0       	push   $0xf0107504
f0101faa:	68 f9 03 00 00       	push   $0x3f9
f0101faf:	68 de 74 10 f0       	push   $0xf01074de
f0101fb4:	e8 87 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fb9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fbe:	89 f8                	mov    %edi,%eax
f0101fc0:	e8 92 eb ff ff       	call   f0100b57 <check_va2pa>
f0101fc5:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fc8:	74 19                	je     f0101fe3 <mem_init+0xc24>
f0101fca:	68 c4 7c 10 f0       	push   $0xf0107cc4
f0101fcf:	68 04 75 10 f0       	push   $0xf0107504
f0101fd4:	68 fa 03 00 00       	push   $0x3fa
f0101fd9:	68 de 74 10 f0       	push   $0xf01074de
f0101fde:	e8 5d e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fe3:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fe8:	74 19                	je     f0102003 <mem_init+0xc44>
f0101fea:	68 47 77 10 f0       	push   $0xf0107747
f0101fef:	68 04 75 10 f0       	push   $0xf0107504
f0101ff4:	68 fc 03 00 00       	push   $0x3fc
f0101ff9:	68 de 74 10 f0       	push   $0xf01074de
f0101ffe:	e8 3d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102003:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102008:	74 19                	je     f0102023 <mem_init+0xc64>
f010200a:	68 58 77 10 f0       	push   $0xf0107758
f010200f:	68 04 75 10 f0       	push   $0xf0107504
f0102014:	68 fd 03 00 00       	push   $0x3fd
f0102019:	68 de 74 10 f0       	push   $0xf01074de
f010201e:	e8 1d e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102023:	83 ec 0c             	sub    $0xc,%esp
f0102026:	6a 00                	push   $0x0
f0102028:	e8 89 ef ff ff       	call   f0100fb6 <page_alloc>
f010202d:	83 c4 10             	add    $0x10,%esp
f0102030:	85 c0                	test   %eax,%eax
f0102032:	74 04                	je     f0102038 <mem_init+0xc79>
f0102034:	39 c6                	cmp    %eax,%esi
f0102036:	74 19                	je     f0102051 <mem_init+0xc92>
f0102038:	68 f4 7c 10 f0       	push   $0xf0107cf4
f010203d:	68 04 75 10 f0       	push   $0xf0107504
f0102042:	68 00 04 00 00       	push   $0x400
f0102047:	68 de 74 10 f0       	push   $0xf01074de
f010204c:	e8 ef df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102051:	83 ec 08             	sub    $0x8,%esp
f0102054:	6a 00                	push   $0x0
f0102056:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f010205c:	e8 1a f2 ff ff       	call   f010127b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102061:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
f0102067:	ba 00 00 00 00       	mov    $0x0,%edx
f010206c:	89 f8                	mov    %edi,%eax
f010206e:	e8 e4 ea ff ff       	call   f0100b57 <check_va2pa>
f0102073:	83 c4 10             	add    $0x10,%esp
f0102076:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102079:	74 19                	je     f0102094 <mem_init+0xcd5>
f010207b:	68 18 7d 10 f0       	push   $0xf0107d18
f0102080:	68 04 75 10 f0       	push   $0xf0107504
f0102085:	68 04 04 00 00       	push   $0x404
f010208a:	68 de 74 10 f0       	push   $0xf01074de
f010208f:	e8 ac df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102094:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102099:	89 f8                	mov    %edi,%eax
f010209b:	e8 b7 ea ff ff       	call   f0100b57 <check_va2pa>
f01020a0:	89 da                	mov    %ebx,%edx
f01020a2:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f01020a8:	c1 fa 03             	sar    $0x3,%edx
f01020ab:	c1 e2 0c             	shl    $0xc,%edx
f01020ae:	39 d0                	cmp    %edx,%eax
f01020b0:	74 19                	je     f01020cb <mem_init+0xd0c>
f01020b2:	68 c4 7c 10 f0       	push   $0xf0107cc4
f01020b7:	68 04 75 10 f0       	push   $0xf0107504
f01020bc:	68 05 04 00 00       	push   $0x405
f01020c1:	68 de 74 10 f0       	push   $0xf01074de
f01020c6:	e8 75 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01020cb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020d0:	74 19                	je     f01020eb <mem_init+0xd2c>
f01020d2:	68 fe 76 10 f0       	push   $0xf01076fe
f01020d7:	68 04 75 10 f0       	push   $0xf0107504
f01020dc:	68 06 04 00 00       	push   $0x406
f01020e1:	68 de 74 10 f0       	push   $0xf01074de
f01020e6:	e8 55 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020eb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020f0:	74 19                	je     f010210b <mem_init+0xd4c>
f01020f2:	68 58 77 10 f0       	push   $0xf0107758
f01020f7:	68 04 75 10 f0       	push   $0xf0107504
f01020fc:	68 07 04 00 00       	push   $0x407
f0102101:	68 de 74 10 f0       	push   $0xf01074de
f0102106:	e8 35 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010210b:	6a 00                	push   $0x0
f010210d:	68 00 10 00 00       	push   $0x1000
f0102112:	53                   	push   %ebx
f0102113:	57                   	push   %edi
f0102114:	e8 b3 f1 ff ff       	call   f01012cc <page_insert>
f0102119:	83 c4 10             	add    $0x10,%esp
f010211c:	85 c0                	test   %eax,%eax
f010211e:	74 19                	je     f0102139 <mem_init+0xd7a>
f0102120:	68 3c 7d 10 f0       	push   $0xf0107d3c
f0102125:	68 04 75 10 f0       	push   $0xf0107504
f010212a:	68 0a 04 00 00       	push   $0x40a
f010212f:	68 de 74 10 f0       	push   $0xf01074de
f0102134:	e8 07 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102139:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010213e:	75 19                	jne    f0102159 <mem_init+0xd9a>
f0102140:	68 69 77 10 f0       	push   $0xf0107769
f0102145:	68 04 75 10 f0       	push   $0xf0107504
f010214a:	68 0b 04 00 00       	push   $0x40b
f010214f:	68 de 74 10 f0       	push   $0xf01074de
f0102154:	e8 e7 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102159:	83 3b 00             	cmpl   $0x0,(%ebx)
f010215c:	74 19                	je     f0102177 <mem_init+0xdb8>
f010215e:	68 75 77 10 f0       	push   $0xf0107775
f0102163:	68 04 75 10 f0       	push   $0xf0107504
f0102168:	68 0c 04 00 00       	push   $0x40c
f010216d:	68 de 74 10 f0       	push   $0xf01074de
f0102172:	e8 c9 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102177:	83 ec 08             	sub    $0x8,%esp
f010217a:	68 00 10 00 00       	push   $0x1000
f010217f:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102185:	e8 f1 f0 ff ff       	call   f010127b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010218a:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
f0102190:	ba 00 00 00 00       	mov    $0x0,%edx
f0102195:	89 f8                	mov    %edi,%eax
f0102197:	e8 bb e9 ff ff       	call   f0100b57 <check_va2pa>
f010219c:	83 c4 10             	add    $0x10,%esp
f010219f:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a2:	74 19                	je     f01021bd <mem_init+0xdfe>
f01021a4:	68 18 7d 10 f0       	push   $0xf0107d18
f01021a9:	68 04 75 10 f0       	push   $0xf0107504
f01021ae:	68 10 04 00 00       	push   $0x410
f01021b3:	68 de 74 10 f0       	push   $0xf01074de
f01021b8:	e8 83 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021bd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021c2:	89 f8                	mov    %edi,%eax
f01021c4:	e8 8e e9 ff ff       	call   f0100b57 <check_va2pa>
f01021c9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021cc:	74 19                	je     f01021e7 <mem_init+0xe28>
f01021ce:	68 74 7d 10 f0       	push   $0xf0107d74
f01021d3:	68 04 75 10 f0       	push   $0xf0107504
f01021d8:	68 11 04 00 00       	push   $0x411
f01021dd:	68 de 74 10 f0       	push   $0xf01074de
f01021e2:	e8 59 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01021e7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021ec:	74 19                	je     f0102207 <mem_init+0xe48>
f01021ee:	68 8a 77 10 f0       	push   $0xf010778a
f01021f3:	68 04 75 10 f0       	push   $0xf0107504
f01021f8:	68 12 04 00 00       	push   $0x412
f01021fd:	68 de 74 10 f0       	push   $0xf01074de
f0102202:	e8 39 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102207:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010220c:	74 19                	je     f0102227 <mem_init+0xe68>
f010220e:	68 58 77 10 f0       	push   $0xf0107758
f0102213:	68 04 75 10 f0       	push   $0xf0107504
f0102218:	68 13 04 00 00       	push   $0x413
f010221d:	68 de 74 10 f0       	push   $0xf01074de
f0102222:	e8 19 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102227:	83 ec 0c             	sub    $0xc,%esp
f010222a:	6a 00                	push   $0x0
f010222c:	e8 85 ed ff ff       	call   f0100fb6 <page_alloc>
f0102231:	83 c4 10             	add    $0x10,%esp
f0102234:	85 c0                	test   %eax,%eax
f0102236:	74 04                	je     f010223c <mem_init+0xe7d>
f0102238:	39 c3                	cmp    %eax,%ebx
f010223a:	74 19                	je     f0102255 <mem_init+0xe96>
f010223c:	68 9c 7d 10 f0       	push   $0xf0107d9c
f0102241:	68 04 75 10 f0       	push   $0xf0107504
f0102246:	68 16 04 00 00       	push   $0x416
f010224b:	68 de 74 10 f0       	push   $0xf01074de
f0102250:	e8 eb dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102255:	83 ec 0c             	sub    $0xc,%esp
f0102258:	6a 00                	push   $0x0
f010225a:	e8 57 ed ff ff       	call   f0100fb6 <page_alloc>
f010225f:	83 c4 10             	add    $0x10,%esp
f0102262:	85 c0                	test   %eax,%eax
f0102264:	74 19                	je     f010227f <mem_init+0xec0>
f0102266:	68 ac 76 10 f0       	push   $0xf01076ac
f010226b:	68 04 75 10 f0       	push   $0xf0107504
f0102270:	68 19 04 00 00       	push   $0x419
f0102275:	68 de 74 10 f0       	push   $0xf01074de
f010227a:	e8 c1 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010227f:	8b 0d dc 8e 2a f0    	mov    0xf02a8edc,%ecx
f0102285:	8b 11                	mov    (%ecx),%edx
f0102287:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010228d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102290:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102296:	c1 f8 03             	sar    $0x3,%eax
f0102299:	c1 e0 0c             	shl    $0xc,%eax
f010229c:	39 c2                	cmp    %eax,%edx
f010229e:	74 19                	je     f01022b9 <mem_init+0xefa>
f01022a0:	68 40 7a 10 f0       	push   $0xf0107a40
f01022a5:	68 04 75 10 f0       	push   $0xf0107504
f01022aa:	68 1c 04 00 00       	push   $0x41c
f01022af:	68 de 74 10 f0       	push   $0xf01074de
f01022b4:	e8 87 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01022b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01022c7:	74 19                	je     f01022e2 <mem_init+0xf23>
f01022c9:	68 0f 77 10 f0       	push   $0xf010770f
f01022ce:	68 04 75 10 f0       	push   $0xf0107504
f01022d3:	68 1e 04 00 00       	push   $0x41e
f01022d8:	68 de 74 10 f0       	push   $0xf01074de
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01022e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022eb:	83 ec 0c             	sub    $0xc,%esp
f01022ee:	50                   	push   %eax
f01022ef:	e8 30 ed ff ff       	call   f0101024 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022f4:	83 c4 0c             	add    $0xc,%esp
f01022f7:	6a 01                	push   $0x1
f01022f9:	68 00 10 40 00       	push   $0x401000
f01022fe:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102304:	e8 81 ed ff ff       	call   f010108a <pgdir_walk>
f0102309:	89 c7                	mov    %eax,%edi
f010230b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010230e:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0102313:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102316:	8b 40 04             	mov    0x4(%eax),%eax
f0102319:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010231e:	8b 0d d8 8e 2a f0    	mov    0xf02a8ed8,%ecx
f0102324:	89 c2                	mov    %eax,%edx
f0102326:	c1 ea 0c             	shr    $0xc,%edx
f0102329:	83 c4 10             	add    $0x10,%esp
f010232c:	39 ca                	cmp    %ecx,%edx
f010232e:	72 15                	jb     f0102345 <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102330:	50                   	push   %eax
f0102331:	68 24 6f 10 f0       	push   $0xf0106f24
f0102336:	68 25 04 00 00       	push   $0x425
f010233b:	68 de 74 10 f0       	push   $0xf01074de
f0102340:	e8 fb dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102345:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010234a:	39 c7                	cmp    %eax,%edi
f010234c:	74 19                	je     f0102367 <mem_init+0xfa8>
f010234e:	68 9b 77 10 f0       	push   $0xf010779b
f0102353:	68 04 75 10 f0       	push   $0xf0107504
f0102358:	68 26 04 00 00       	push   $0x426
f010235d:	68 de 74 10 f0       	push   $0xf01074de
f0102362:	e8 d9 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102367:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010236a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102374:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010237a:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102380:	c1 f8 03             	sar    $0x3,%eax
f0102383:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102386:	89 c2                	mov    %eax,%edx
f0102388:	c1 ea 0c             	shr    $0xc,%edx
f010238b:	39 d1                	cmp    %edx,%ecx
f010238d:	77 12                	ja     f01023a1 <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010238f:	50                   	push   %eax
f0102390:	68 24 6f 10 f0       	push   $0xf0106f24
f0102395:	6a 58                	push   $0x58
f0102397:	68 ea 74 10 f0       	push   $0xf01074ea
f010239c:	e8 9f dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023a1:	83 ec 04             	sub    $0x4,%esp
f01023a4:	68 00 10 00 00       	push   $0x1000
f01023a9:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01023ae:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023b3:	50                   	push   %eax
f01023b4:	e8 3e 35 00 00       	call   f01058f7 <memset>
	page_free(pp0);
f01023b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01023bc:	89 3c 24             	mov    %edi,(%esp)
f01023bf:	e8 60 ec ff ff       	call   f0101024 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023c4:	83 c4 0c             	add    $0xc,%esp
f01023c7:	6a 01                	push   $0x1
f01023c9:	6a 00                	push   $0x0
f01023cb:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f01023d1:	e8 b4 ec ff ff       	call   f010108a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023d6:	89 fa                	mov    %edi,%edx
f01023d8:	2b 15 e0 8e 2a f0    	sub    0xf02a8ee0,%edx
f01023de:	c1 fa 03             	sar    $0x3,%edx
f01023e1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023e4:	89 d0                	mov    %edx,%eax
f01023e6:	c1 e8 0c             	shr    $0xc,%eax
f01023e9:	83 c4 10             	add    $0x10,%esp
f01023ec:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f01023f2:	72 12                	jb     f0102406 <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023f4:	52                   	push   %edx
f01023f5:	68 24 6f 10 f0       	push   $0xf0106f24
f01023fa:	6a 58                	push   $0x58
f01023fc:	68 ea 74 10 f0       	push   $0xf01074ea
f0102401:	e8 3a dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102406:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010240c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010240f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102415:	f6 00 01             	testb  $0x1,(%eax)
f0102418:	74 19                	je     f0102433 <mem_init+0x1074>
f010241a:	68 b3 77 10 f0       	push   $0xf01077b3
f010241f:	68 04 75 10 f0       	push   $0xf0107504
f0102424:	68 30 04 00 00       	push   $0x430
f0102429:	68 de 74 10 f0       	push   $0xf01074de
f010242e:	e8 0d dc ff ff       	call   f0100040 <_panic>
f0102433:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102436:	39 d0                	cmp    %edx,%eax
f0102438:	75 db                	jne    f0102415 <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010243a:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f010243f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102445:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102448:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010244e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102451:	89 0d 64 82 2a f0    	mov    %ecx,0xf02a8264

	// free the pages we took
	page_free(pp0);
f0102457:	83 ec 0c             	sub    $0xc,%esp
f010245a:	50                   	push   %eax
f010245b:	e8 c4 eb ff ff       	call   f0101024 <page_free>
	page_free(pp1);
f0102460:	89 1c 24             	mov    %ebx,(%esp)
f0102463:	e8 bc eb ff ff       	call   f0101024 <page_free>
	page_free(pp2);
f0102468:	89 34 24             	mov    %esi,(%esp)
f010246b:	e8 b4 eb ff ff       	call   f0101024 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102470:	83 c4 08             	add    $0x8,%esp
f0102473:	68 01 10 00 00       	push   $0x1001
f0102478:	6a 00                	push   $0x0
f010247a:	e8 ca ee ff ff       	call   f0101349 <mmio_map_region>
f010247f:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102481:	83 c4 08             	add    $0x8,%esp
f0102484:	68 00 10 00 00       	push   $0x1000
f0102489:	6a 00                	push   $0x0
f010248b:	e8 b9 ee ff ff       	call   f0101349 <mmio_map_region>
f0102490:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102492:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102498:	83 c4 10             	add    $0x10,%esp
f010249b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024a0:	77 08                	ja     f01024aa <mem_init+0x10eb>
f01024a2:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024a8:	77 19                	ja     f01024c3 <mem_init+0x1104>
f01024aa:	68 c0 7d 10 f0       	push   $0xf0107dc0
f01024af:	68 04 75 10 f0       	push   $0xf0107504
f01024b4:	68 40 04 00 00       	push   $0x440
f01024b9:	68 de 74 10 f0       	push   $0xf01074de
f01024be:	e8 7d db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024c3:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024c9:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024cf:	77 08                	ja     f01024d9 <mem_init+0x111a>
f01024d1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024d7:	77 19                	ja     f01024f2 <mem_init+0x1133>
f01024d9:	68 e8 7d 10 f0       	push   $0xf0107de8
f01024de:	68 04 75 10 f0       	push   $0xf0107504
f01024e3:	68 41 04 00 00       	push   $0x441
f01024e8:	68 de 74 10 f0       	push   $0xf01074de
f01024ed:	e8 4e db ff ff       	call   f0100040 <_panic>
f01024f2:	89 da                	mov    %ebx,%edx
f01024f4:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024f6:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024fc:	74 19                	je     f0102517 <mem_init+0x1158>
f01024fe:	68 10 7e 10 f0       	push   $0xf0107e10
f0102503:	68 04 75 10 f0       	push   $0xf0107504
f0102508:	68 43 04 00 00       	push   $0x443
f010250d:	68 de 74 10 f0       	push   $0xf01074de
f0102512:	e8 29 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102517:	39 c6                	cmp    %eax,%esi
f0102519:	73 19                	jae    f0102534 <mem_init+0x1175>
f010251b:	68 ca 77 10 f0       	push   $0xf01077ca
f0102520:	68 04 75 10 f0       	push   $0xf0107504
f0102525:	68 45 04 00 00       	push   $0x445
f010252a:	68 de 74 10 f0       	push   $0xf01074de
f010252f:	e8 0c db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102534:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi
f010253a:	89 da                	mov    %ebx,%edx
f010253c:	89 f8                	mov    %edi,%eax
f010253e:	e8 14 e6 ff ff       	call   f0100b57 <check_va2pa>
f0102543:	85 c0                	test   %eax,%eax
f0102545:	74 19                	je     f0102560 <mem_init+0x11a1>
f0102547:	68 38 7e 10 f0       	push   $0xf0107e38
f010254c:	68 04 75 10 f0       	push   $0xf0107504
f0102551:	68 47 04 00 00       	push   $0x447
f0102556:	68 de 74 10 f0       	push   $0xf01074de
f010255b:	e8 e0 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102560:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102566:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102569:	89 c2                	mov    %eax,%edx
f010256b:	89 f8                	mov    %edi,%eax
f010256d:	e8 e5 e5 ff ff       	call   f0100b57 <check_va2pa>
f0102572:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102577:	74 19                	je     f0102592 <mem_init+0x11d3>
f0102579:	68 5c 7e 10 f0       	push   $0xf0107e5c
f010257e:	68 04 75 10 f0       	push   $0xf0107504
f0102583:	68 48 04 00 00       	push   $0x448
f0102588:	68 de 74 10 f0       	push   $0xf01074de
f010258d:	e8 ae da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102592:	89 f2                	mov    %esi,%edx
f0102594:	89 f8                	mov    %edi,%eax
f0102596:	e8 bc e5 ff ff       	call   f0100b57 <check_va2pa>
f010259b:	85 c0                	test   %eax,%eax
f010259d:	74 19                	je     f01025b8 <mem_init+0x11f9>
f010259f:	68 8c 7e 10 f0       	push   $0xf0107e8c
f01025a4:	68 04 75 10 f0       	push   $0xf0107504
f01025a9:	68 49 04 00 00       	push   $0x449
f01025ae:	68 de 74 10 f0       	push   $0xf01074de
f01025b3:	e8 88 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025b8:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025be:	89 f8                	mov    %edi,%eax
f01025c0:	e8 92 e5 ff ff       	call   f0100b57 <check_va2pa>
f01025c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c8:	74 19                	je     f01025e3 <mem_init+0x1224>
f01025ca:	68 b0 7e 10 f0       	push   $0xf0107eb0
f01025cf:	68 04 75 10 f0       	push   $0xf0107504
f01025d4:	68 4a 04 00 00       	push   $0x44a
f01025d9:	68 de 74 10 f0       	push   $0xf01074de
f01025de:	e8 5d da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025e3:	83 ec 04             	sub    $0x4,%esp
f01025e6:	6a 00                	push   $0x0
f01025e8:	53                   	push   %ebx
f01025e9:	57                   	push   %edi
f01025ea:	e8 9b ea ff ff       	call   f010108a <pgdir_walk>
f01025ef:	83 c4 10             	add    $0x10,%esp
f01025f2:	f6 00 1a             	testb  $0x1a,(%eax)
f01025f5:	75 19                	jne    f0102610 <mem_init+0x1251>
f01025f7:	68 dc 7e 10 f0       	push   $0xf0107edc
f01025fc:	68 04 75 10 f0       	push   $0xf0107504
f0102601:	68 4c 04 00 00       	push   $0x44c
f0102606:	68 de 74 10 f0       	push   $0xf01074de
f010260b:	e8 30 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102610:	83 ec 04             	sub    $0x4,%esp
f0102613:	6a 00                	push   $0x0
f0102615:	53                   	push   %ebx
f0102616:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f010261c:	e8 69 ea ff ff       	call   f010108a <pgdir_walk>
f0102621:	83 c4 10             	add    $0x10,%esp
f0102624:	f6 00 04             	testb  $0x4,(%eax)
f0102627:	74 19                	je     f0102642 <mem_init+0x1283>
f0102629:	68 20 7f 10 f0       	push   $0xf0107f20
f010262e:	68 04 75 10 f0       	push   $0xf0107504
f0102633:	68 4d 04 00 00       	push   $0x44d
f0102638:	68 de 74 10 f0       	push   $0xf01074de
f010263d:	e8 fe d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102642:	83 ec 04             	sub    $0x4,%esp
f0102645:	6a 00                	push   $0x0
f0102647:	53                   	push   %ebx
f0102648:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f010264e:	e8 37 ea ff ff       	call   f010108a <pgdir_walk>
f0102653:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102659:	83 c4 0c             	add    $0xc,%esp
f010265c:	6a 00                	push   $0x0
f010265e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102661:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102667:	e8 1e ea ff ff       	call   f010108a <pgdir_walk>
f010266c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102672:	83 c4 0c             	add    $0xc,%esp
f0102675:	6a 00                	push   $0x0
f0102677:	56                   	push   %esi
f0102678:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f010267e:	e8 07 ea ff ff       	call   f010108a <pgdir_walk>
f0102683:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102689:	c7 04 24 dc 77 10 f0 	movl   $0xf01077dc,(%esp)
f0102690:	e8 c8 10 00 00       	call   f010375d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102695:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010269a:	83 c4 10             	add    $0x10,%esp
f010269d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026a2:	77 15                	ja     f01026b9 <mem_init+0x12fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a4:	50                   	push   %eax
f01026a5:	68 48 6f 10 f0       	push   $0xf0106f48
f01026aa:	68 c8 00 00 00       	push   $0xc8
f01026af:	68 de 74 10 f0       	push   $0xf01074de
f01026b4:	e8 87 d9 ff ff       	call   f0100040 <_panic>
f01026b9:	83 ec 08             	sub    $0x8,%esp
f01026bc:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026be:	05 00 00 00 10       	add    $0x10000000,%eax
f01026c3:	50                   	push   %eax
f01026c4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026c9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026ce:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f01026d3:	e8 8f ea ff ff       	call   f0101167 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01026d8:	a1 6c 82 2a f0       	mov    0xf02a826c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026dd:	83 c4 10             	add    $0x10,%esp
f01026e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026e5:	77 15                	ja     f01026fc <mem_init+0x133d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e7:	50                   	push   %eax
f01026e8:	68 48 6f 10 f0       	push   $0xf0106f48
f01026ed:	68 d0 00 00 00       	push   $0xd0
f01026f2:	68 de 74 10 f0       	push   $0xf01074de
f01026f7:	e8 44 d9 ff ff       	call   f0100040 <_panic>
f01026fc:	83 ec 08             	sub    $0x8,%esp
f01026ff:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102701:	05 00 00 00 10       	add    $0x10000000,%eax
f0102706:	50                   	push   %eax
f0102707:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010270c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102711:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0102716:	e8 4c ea ff ff       	call   f0101167 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010271b:	83 c4 10             	add    $0x10,%esp
f010271e:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f0102723:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102728:	77 15                	ja     f010273f <mem_init+0x1380>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010272a:	50                   	push   %eax
f010272b:	68 48 6f 10 f0       	push   $0xf0106f48
f0102730:	68 dc 00 00 00       	push   $0xdc
f0102735:	68 de 74 10 f0       	push   $0xf01074de
f010273a:	e8 01 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010273f:	83 ec 08             	sub    $0x8,%esp
f0102742:	6a 02                	push   $0x2
f0102744:	68 00 a0 11 00       	push   $0x11a000
f0102749:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010274e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102753:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0102758:	e8 0a ea ff ff       	call   f0101167 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f010275d:	83 c4 08             	add    $0x8,%esp
f0102760:	6a 02                	push   $0x2
f0102762:	6a 00                	push   $0x0
f0102764:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102769:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010276e:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f0102773:	e8 ef e9 ff ff       	call   f0101167 <boot_map_region>
f0102778:	c7 45 c4 00 a0 2a f0 	movl   $0xf02aa000,-0x3c(%ebp)
f010277f:	83 c4 10             	add    $0x10,%esp
f0102782:	bb 00 a0 2a f0       	mov    $0xf02aa000,%ebx
f0102787:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010278c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102792:	77 15                	ja     f01027a9 <mem_init+0x13ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102794:	53                   	push   %ebx
f0102795:	68 48 6f 10 f0       	push   $0xf0106f48
f010279a:	68 21 01 00 00       	push   $0x121
f010279f:	68 de 74 10 f0       	push   $0xf01074de
f01027a4:	e8 97 d8 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
                boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP),
f01027a9:	83 ec 08             	sub    $0x8,%esp
f01027ac:	6a 02                	push   $0x2
f01027ae:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01027b4:	50                   	push   %eax
f01027b5:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027ba:	89 f2                	mov    %esi,%edx
f01027bc:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
f01027c1:	e8 a1 e9 ff ff       	call   f0101167 <boot_map_region>
f01027c6:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027cc:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
f01027d2:	83 c4 10             	add    $0x10,%esp
f01027d5:	81 fb 00 a0 2e f0    	cmp    $0xf02ea000,%ebx
f01027db:	75 af                	jne    f010278c <mem_init+0x13cd>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027dd:	8b 3d dc 8e 2a f0    	mov    0xf02a8edc,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027e3:	a1 d8 8e 2a f0       	mov    0xf02a8ed8,%eax
f01027e8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027eb:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027fa:	8b 35 e0 8e 2a f0    	mov    0xf02a8ee0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102800:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102803:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102808:	eb 55                	jmp    f010285f <mem_init+0x14a0>
f010280a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102810:	89 f8                	mov    %edi,%eax
f0102812:	e8 40 e3 ff ff       	call   f0100b57 <check_va2pa>
f0102817:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010281e:	77 15                	ja     f0102835 <mem_init+0x1476>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102820:	56                   	push   %esi
f0102821:	68 48 6f 10 f0       	push   $0xf0106f48
f0102826:	68 66 03 00 00       	push   $0x366
f010282b:	68 de 74 10 f0       	push   $0xf01074de
f0102830:	e8 0b d8 ff ff       	call   f0100040 <_panic>
f0102835:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010283c:	39 d0                	cmp    %edx,%eax
f010283e:	74 19                	je     f0102859 <mem_init+0x149a>
f0102840:	68 54 7f 10 f0       	push   $0xf0107f54
f0102845:	68 04 75 10 f0       	push   $0xf0107504
f010284a:	68 66 03 00 00       	push   $0x366
f010284f:	68 de 74 10 f0       	push   $0xf01074de
f0102854:	e8 e7 d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102859:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010285f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102862:	77 a6                	ja     f010280a <mem_init+0x144b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102864:	8b 35 6c 82 2a f0    	mov    0xf02a826c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010286a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010286d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102872:	89 da                	mov    %ebx,%edx
f0102874:	89 f8                	mov    %edi,%eax
f0102876:	e8 dc e2 ff ff       	call   f0100b57 <check_va2pa>
f010287b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102882:	77 15                	ja     f0102899 <mem_init+0x14da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102884:	56                   	push   %esi
f0102885:	68 48 6f 10 f0       	push   $0xf0106f48
f010288a:	68 6b 03 00 00       	push   $0x36b
f010288f:	68 de 74 10 f0       	push   $0xf01074de
f0102894:	e8 a7 d7 ff ff       	call   f0100040 <_panic>
f0102899:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028a0:	39 d0                	cmp    %edx,%eax
f01028a2:	74 19                	je     f01028bd <mem_init+0x14fe>
f01028a4:	68 88 7f 10 f0       	push   $0xf0107f88
f01028a9:	68 04 75 10 f0       	push   $0xf0107504
f01028ae:	68 6b 03 00 00       	push   $0x36b
f01028b3:	68 de 74 10 f0       	push   $0xf01074de
f01028b8:	e8 83 d7 ff ff       	call   f0100040 <_panic>
f01028bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028c3:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028c9:	75 a7                	jne    f0102872 <mem_init+0x14b3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f01028cb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028ce:	c1 e6 0c             	shl    $0xc,%esi
f01028d1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028d6:	eb 30                	jmp    f0102908 <mem_init+0x1549>
f01028d8:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028de:	89 f8                	mov    %edi,%eax
f01028e0:	e8 72 e2 ff ff       	call   f0100b57 <check_va2pa>
f01028e5:	39 c3                	cmp    %eax,%ebx
f01028e7:	74 19                	je     f0102902 <mem_init+0x1543>
f01028e9:	68 bc 7f 10 f0       	push   $0xf0107fbc
f01028ee:	68 04 75 10 f0       	push   $0xf0107504
f01028f3:	68 6f 03 00 00       	push   $0x36f
f01028f8:	68 de 74 10 f0       	push   $0xf01074de
f01028fd:	e8 3e d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f0102902:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102908:	39 f3                	cmp    %esi,%ebx
f010290a:	72 cc                	jb     f01028d8 <mem_init+0x1519>
f010290c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0102913:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102918:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010291b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010291e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102921:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102927:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010292a:	89 c3                	mov    %eax,%ebx
f010292c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010292f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102934:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102937:	89 da                	mov    %ebx,%edx
f0102939:	89 f8                	mov    %edi,%eax
f010293b:	e8 17 e2 ff ff       	call   f0100b57 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102940:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102946:	77 15                	ja     f010295d <mem_init+0x159e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102948:	56                   	push   %esi
f0102949:	68 48 6f 10 f0       	push   $0xf0106f48
f010294e:	68 76 03 00 00       	push   $0x376
f0102953:	68 de 74 10 f0       	push   $0xf01074de
f0102958:	e8 e3 d6 ff ff       	call   f0100040 <_panic>
f010295d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102960:	8d 94 0b 00 a0 2a f0 	lea    -0xfd56000(%ebx,%ecx,1),%edx
f0102967:	39 d0                	cmp    %edx,%eax
f0102969:	74 19                	je     f0102984 <mem_init+0x15c5>
f010296b:	68 e4 7f 10 f0       	push   $0xf0107fe4
f0102970:	68 04 75 10 f0       	push   $0xf0107504
f0102975:	68 76 03 00 00       	push   $0x376
f010297a:	68 de 74 10 f0       	push   $0xf01074de
f010297f:	e8 bc d6 ff ff       	call   f0100040 <_panic>
f0102984:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010298a:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010298d:	75 a8                	jne    f0102937 <mem_init+0x1578>
f010298f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102992:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102998:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010299b:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010299d:	89 da                	mov    %ebx,%edx
f010299f:	89 f8                	mov    %edi,%eax
f01029a1:	e8 b1 e1 ff ff       	call   f0100b57 <check_va2pa>
f01029a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a9:	74 19                	je     f01029c4 <mem_init+0x1605>
f01029ab:	68 2c 80 10 f0       	push   $0xf010802c
f01029b0:	68 04 75 10 f0       	push   $0xf0107504
f01029b5:	68 78 03 00 00       	push   $0x378
f01029ba:	68 de 74 10 f0       	push   $0xf01074de
f01029bf:	e8 7c d6 ff ff       	call   f0100040 <_panic>
f01029c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029ca:	39 de                	cmp    %ebx,%esi
f01029cc:	75 cf                	jne    f010299d <mem_init+0x15de>
f01029ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029d1:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029d8:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029df:	81 c6 00 80 00 00    	add    $0x8000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01029e5:	81 fe 00 a0 2e f0    	cmp    $0xf02ea000,%esi
f01029eb:	0f 85 2d ff ff ff    	jne    f010291e <mem_init+0x155f>
f01029f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01029f6:	eb 2a                	jmp    f0102a22 <mem_init+0x1663>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029f8:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01029fe:	83 fa 04             	cmp    $0x4,%edx
f0102a01:	77 1f                	ja     f0102a22 <mem_init+0x1663>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a03:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a07:	75 7e                	jne    f0102a87 <mem_init+0x16c8>
f0102a09:	68 f5 77 10 f0       	push   $0xf01077f5
f0102a0e:	68 04 75 10 f0       	push   $0xf0107504
f0102a13:	68 83 03 00 00       	push   $0x383
f0102a18:	68 de 74 10 f0       	push   $0xf01074de
f0102a1d:	e8 1e d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a22:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a27:	76 3f                	jbe    f0102a68 <mem_init+0x16a9>
				assert(pgdir[i] & PTE_P);
f0102a29:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a2c:	f6 c2 01             	test   $0x1,%dl
f0102a2f:	75 19                	jne    f0102a4a <mem_init+0x168b>
f0102a31:	68 f5 77 10 f0       	push   $0xf01077f5
f0102a36:	68 04 75 10 f0       	push   $0xf0107504
f0102a3b:	68 87 03 00 00       	push   $0x387
f0102a40:	68 de 74 10 f0       	push   $0xf01074de
f0102a45:	e8 f6 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a4a:	f6 c2 02             	test   $0x2,%dl
f0102a4d:	75 38                	jne    f0102a87 <mem_init+0x16c8>
f0102a4f:	68 06 78 10 f0       	push   $0xf0107806
f0102a54:	68 04 75 10 f0       	push   $0xf0107504
f0102a59:	68 88 03 00 00       	push   $0x388
f0102a5e:	68 de 74 10 f0       	push   $0xf01074de
f0102a63:	e8 d8 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a68:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a6c:	74 19                	je     f0102a87 <mem_init+0x16c8>
f0102a6e:	68 17 78 10 f0       	push   $0xf0107817
f0102a73:	68 04 75 10 f0       	push   $0xf0107504
f0102a78:	68 8a 03 00 00       	push   $0x38a
f0102a7d:	68 de 74 10 f0       	push   $0xf01074de
f0102a82:	e8 b9 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a87:	83 c0 01             	add    $0x1,%eax
f0102a8a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a8f:	0f 86 63 ff ff ff    	jbe    f01029f8 <mem_init+0x1639>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a95:	83 ec 0c             	sub    $0xc,%esp
f0102a98:	68 50 80 10 f0       	push   $0xf0108050
f0102a9d:	e8 bb 0c 00 00       	call   f010375d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102aa2:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aa7:	83 c4 10             	add    $0x10,%esp
f0102aaa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102aaf:	77 15                	ja     f0102ac6 <mem_init+0x1707>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ab1:	50                   	push   %eax
f0102ab2:	68 48 6f 10 f0       	push   $0xf0106f48
f0102ab7:	68 f8 00 00 00       	push   $0xf8
f0102abc:	68 de 74 10 f0       	push   $0xf01074de
f0102ac1:	e8 7a d5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ac6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102acb:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102ace:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad3:	e8 e3 e0 ff ff       	call   f0100bbb <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102ad8:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102adb:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ade:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102ae3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ae6:	83 ec 0c             	sub    $0xc,%esp
f0102ae9:	6a 00                	push   $0x0
f0102aeb:	e8 c6 e4 ff ff       	call   f0100fb6 <page_alloc>
f0102af0:	89 c3                	mov    %eax,%ebx
f0102af2:	83 c4 10             	add    $0x10,%esp
f0102af5:	85 c0                	test   %eax,%eax
f0102af7:	75 19                	jne    f0102b12 <mem_init+0x1753>
f0102af9:	68 01 76 10 f0       	push   $0xf0107601
f0102afe:	68 04 75 10 f0       	push   $0xf0107504
f0102b03:	68 62 04 00 00       	push   $0x462
f0102b08:	68 de 74 10 f0       	push   $0xf01074de
f0102b0d:	e8 2e d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b12:	83 ec 0c             	sub    $0xc,%esp
f0102b15:	6a 00                	push   $0x0
f0102b17:	e8 9a e4 ff ff       	call   f0100fb6 <page_alloc>
f0102b1c:	89 c7                	mov    %eax,%edi
f0102b1e:	83 c4 10             	add    $0x10,%esp
f0102b21:	85 c0                	test   %eax,%eax
f0102b23:	75 19                	jne    f0102b3e <mem_init+0x177f>
f0102b25:	68 17 76 10 f0       	push   $0xf0107617
f0102b2a:	68 04 75 10 f0       	push   $0xf0107504
f0102b2f:	68 63 04 00 00       	push   $0x463
f0102b34:	68 de 74 10 f0       	push   $0xf01074de
f0102b39:	e8 02 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b3e:	83 ec 0c             	sub    $0xc,%esp
f0102b41:	6a 00                	push   $0x0
f0102b43:	e8 6e e4 ff ff       	call   f0100fb6 <page_alloc>
f0102b48:	89 c6                	mov    %eax,%esi
f0102b4a:	83 c4 10             	add    $0x10,%esp
f0102b4d:	85 c0                	test   %eax,%eax
f0102b4f:	75 19                	jne    f0102b6a <mem_init+0x17ab>
f0102b51:	68 2d 76 10 f0       	push   $0xf010762d
f0102b56:	68 04 75 10 f0       	push   $0xf0107504
f0102b5b:	68 64 04 00 00       	push   $0x464
f0102b60:	68 de 74 10 f0       	push   $0xf01074de
f0102b65:	e8 d6 d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b6a:	83 ec 0c             	sub    $0xc,%esp
f0102b6d:	53                   	push   %ebx
f0102b6e:	e8 b1 e4 ff ff       	call   f0101024 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b73:	89 f8                	mov    %edi,%eax
f0102b75:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102b7b:	c1 f8 03             	sar    $0x3,%eax
f0102b7e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b81:	89 c2                	mov    %eax,%edx
f0102b83:	c1 ea 0c             	shr    $0xc,%edx
f0102b86:	83 c4 10             	add    $0x10,%esp
f0102b89:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0102b8f:	72 12                	jb     f0102ba3 <mem_init+0x17e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b91:	50                   	push   %eax
f0102b92:	68 24 6f 10 f0       	push   $0xf0106f24
f0102b97:	6a 58                	push   $0x58
f0102b99:	68 ea 74 10 f0       	push   $0xf01074ea
f0102b9e:	e8 9d d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ba3:	83 ec 04             	sub    $0x4,%esp
f0102ba6:	68 00 10 00 00       	push   $0x1000
f0102bab:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bb2:	50                   	push   %eax
f0102bb3:	e8 3f 2d 00 00       	call   f01058f7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bb8:	89 f0                	mov    %esi,%eax
f0102bba:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102bc0:	c1 f8 03             	sar    $0x3,%eax
f0102bc3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bc6:	89 c2                	mov    %eax,%edx
f0102bc8:	c1 ea 0c             	shr    $0xc,%edx
f0102bcb:	83 c4 10             	add    $0x10,%esp
f0102bce:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0102bd4:	72 12                	jb     f0102be8 <mem_init+0x1829>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bd6:	50                   	push   %eax
f0102bd7:	68 24 6f 10 f0       	push   $0xf0106f24
f0102bdc:	6a 58                	push   $0x58
f0102bde:	68 ea 74 10 f0       	push   $0xf01074ea
f0102be3:	e8 58 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102be8:	83 ec 04             	sub    $0x4,%esp
f0102beb:	68 00 10 00 00       	push   $0x1000
f0102bf0:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102bf2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bf7:	50                   	push   %eax
f0102bf8:	e8 fa 2c 00 00       	call   f01058f7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bfd:	6a 02                	push   $0x2
f0102bff:	68 00 10 00 00       	push   $0x1000
f0102c04:	57                   	push   %edi
f0102c05:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102c0b:	e8 bc e6 ff ff       	call   f01012cc <page_insert>
	assert(pp1->pp_ref == 1);
f0102c10:	83 c4 20             	add    $0x20,%esp
f0102c13:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c18:	74 19                	je     f0102c33 <mem_init+0x1874>
f0102c1a:	68 fe 76 10 f0       	push   $0xf01076fe
f0102c1f:	68 04 75 10 f0       	push   $0xf0107504
f0102c24:	68 69 04 00 00       	push   $0x469
f0102c29:	68 de 74 10 f0       	push   $0xf01074de
f0102c2e:	e8 0d d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c33:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c3a:	01 01 01 
f0102c3d:	74 19                	je     f0102c58 <mem_init+0x1899>
f0102c3f:	68 70 80 10 f0       	push   $0xf0108070
f0102c44:	68 04 75 10 f0       	push   $0xf0107504
f0102c49:	68 6a 04 00 00       	push   $0x46a
f0102c4e:	68 de 74 10 f0       	push   $0xf01074de
f0102c53:	e8 e8 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c58:	6a 02                	push   $0x2
f0102c5a:	68 00 10 00 00       	push   $0x1000
f0102c5f:	56                   	push   %esi
f0102c60:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102c66:	e8 61 e6 ff ff       	call   f01012cc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c6b:	83 c4 10             	add    $0x10,%esp
f0102c6e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c75:	02 02 02 
f0102c78:	74 19                	je     f0102c93 <mem_init+0x18d4>
f0102c7a:	68 94 80 10 f0       	push   $0xf0108094
f0102c7f:	68 04 75 10 f0       	push   $0xf0107504
f0102c84:	68 6c 04 00 00       	push   $0x46c
f0102c89:	68 de 74 10 f0       	push   $0xf01074de
f0102c8e:	e8 ad d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c93:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c98:	74 19                	je     f0102cb3 <mem_init+0x18f4>
f0102c9a:	68 20 77 10 f0       	push   $0xf0107720
f0102c9f:	68 04 75 10 f0       	push   $0xf0107504
f0102ca4:	68 6d 04 00 00       	push   $0x46d
f0102ca9:	68 de 74 10 f0       	push   $0xf01074de
f0102cae:	e8 8d d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102cb3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cb8:	74 19                	je     f0102cd3 <mem_init+0x1914>
f0102cba:	68 8a 77 10 f0       	push   $0xf010778a
f0102cbf:	68 04 75 10 f0       	push   $0xf0107504
f0102cc4:	68 6e 04 00 00       	push   $0x46e
f0102cc9:	68 de 74 10 f0       	push   $0xf01074de
f0102cce:	e8 6d d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cd3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cda:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cdd:	89 f0                	mov    %esi,%eax
f0102cdf:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102ce5:	c1 f8 03             	sar    $0x3,%eax
f0102ce8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ceb:	89 c2                	mov    %eax,%edx
f0102ced:	c1 ea 0c             	shr    $0xc,%edx
f0102cf0:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0102cf6:	72 12                	jb     f0102d0a <mem_init+0x194b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cf8:	50                   	push   %eax
f0102cf9:	68 24 6f 10 f0       	push   $0xf0106f24
f0102cfe:	6a 58                	push   $0x58
f0102d00:	68 ea 74 10 f0       	push   $0xf01074ea
f0102d05:	e8 36 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d0a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d11:	03 03 03 
f0102d14:	74 19                	je     f0102d2f <mem_init+0x1970>
f0102d16:	68 b8 80 10 f0       	push   $0xf01080b8
f0102d1b:	68 04 75 10 f0       	push   $0xf0107504
f0102d20:	68 70 04 00 00       	push   $0x470
f0102d25:	68 de 74 10 f0       	push   $0xf01074de
f0102d2a:	e8 11 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d2f:	83 ec 08             	sub    $0x8,%esp
f0102d32:	68 00 10 00 00       	push   $0x1000
f0102d37:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f0102d3d:	e8 39 e5 ff ff       	call   f010127b <page_remove>
	assert(pp2->pp_ref == 0);
f0102d42:	83 c4 10             	add    $0x10,%esp
f0102d45:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d4a:	74 19                	je     f0102d65 <mem_init+0x19a6>
f0102d4c:	68 58 77 10 f0       	push   $0xf0107758
f0102d51:	68 04 75 10 f0       	push   $0xf0107504
f0102d56:	68 72 04 00 00       	push   $0x472
f0102d5b:	68 de 74 10 f0       	push   $0xf01074de
f0102d60:	e8 db d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d65:	8b 0d dc 8e 2a f0    	mov    0xf02a8edc,%ecx
f0102d6b:	8b 11                	mov    (%ecx),%edx
f0102d6d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d73:	89 d8                	mov    %ebx,%eax
f0102d75:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0102d7b:	c1 f8 03             	sar    $0x3,%eax
f0102d7e:	c1 e0 0c             	shl    $0xc,%eax
f0102d81:	39 c2                	cmp    %eax,%edx
f0102d83:	74 19                	je     f0102d9e <mem_init+0x19df>
f0102d85:	68 40 7a 10 f0       	push   $0xf0107a40
f0102d8a:	68 04 75 10 f0       	push   $0xf0107504
f0102d8f:	68 75 04 00 00       	push   $0x475
f0102d94:	68 de 74 10 f0       	push   $0xf01074de
f0102d99:	e8 a2 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d9e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102da4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102da9:	74 19                	je     f0102dc4 <mem_init+0x1a05>
f0102dab:	68 0f 77 10 f0       	push   $0xf010770f
f0102db0:	68 04 75 10 f0       	push   $0xf0107504
f0102db5:	68 77 04 00 00       	push   $0x477
f0102dba:	68 de 74 10 f0       	push   $0xf01074de
f0102dbf:	e8 7c d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102dc4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102dca:	83 ec 0c             	sub    $0xc,%esp
f0102dcd:	53                   	push   %ebx
f0102dce:	e8 51 e2 ff ff       	call   f0101024 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dd3:	c7 04 24 e4 80 10 f0 	movl   $0xf01080e4,(%esp)
f0102dda:	e8 7e 09 00 00       	call   f010375d <cprintf>
f0102ddf:	83 c4 10             	add    $0x10,%esp
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
 
}
f0102de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102de5:	5b                   	pop    %ebx
f0102de6:	5e                   	pop    %esi
f0102de7:	5f                   	pop    %edi
f0102de8:	5d                   	pop    %ebp
f0102de9:	c3                   	ret    

f0102dea <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102dea:	55                   	push   %ebp
f0102deb:	89 e5                	mov    %esp,%ebp
f0102ded:	57                   	push   %edi
f0102dee:	56                   	push   %esi
f0102def:	53                   	push   %ebx
f0102df0:	83 ec 1c             	sub    $0x1c,%esp
f0102df3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102df6:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102dfc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uint32_t end = (uint32_t) (va+len);
f0102e02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e05:	03 45 10             	add    0x10(%ebp),%eax
f0102e08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102e0b:	eb 43                	jmp    f0102e50 <user_mem_check+0x66>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102e0d:	83 ec 04             	sub    $0x4,%esp
f0102e10:	6a 00                	push   $0x0
f0102e12:	53                   	push   %ebx
f0102e13:	ff 77 60             	pushl  0x60(%edi)
f0102e16:	e8 6f e2 ff ff       	call   f010108a <pgdir_walk>
       
                if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e1b:	83 c4 10             	add    $0x10,%esp
f0102e1e:	85 c0                	test   %eax,%eax
f0102e20:	74 14                	je     f0102e36 <user_mem_check+0x4c>
f0102e22:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e28:	77 0c                	ja     f0102e36 <user_mem_check+0x4c>
f0102e2a:	8b 00                	mov    (%eax),%eax
f0102e2c:	a8 01                	test   $0x1,%al
f0102e2e:	74 06                	je     f0102e36 <user_mem_check+0x4c>
f0102e30:	21 f0                	and    %esi,%eax
f0102e32:	39 c6                	cmp    %eax,%esi
f0102e34:	74 14                	je     f0102e4a <user_mem_check+0x60>
f0102e36:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e39:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e3d:	89 1d 60 82 2a f0    	mov    %ebx,0xf02a8260
                      return -E_FAULT;
f0102e43:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e48:	eb 10                	jmp    f0102e5a <user_mem_check+0x70>
{
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
        uint32_t end = (uint32_t) (va+len);
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102e4a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e50:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e53:	72 b8                	jb     f0102e0d <user_mem_check+0x23>
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                      return -E_FAULT;
                }
        }
         
	return 0;
f0102e55:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e5d:	5b                   	pop    %ebx
f0102e5e:	5e                   	pop    %esi
f0102e5f:	5f                   	pop    %edi
f0102e60:	5d                   	pop    %ebp
f0102e61:	c3                   	ret    

f0102e62 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e62:	55                   	push   %ebp
f0102e63:	89 e5                	mov    %esp,%ebp
f0102e65:	53                   	push   %ebx
f0102e66:	83 ec 04             	sub    $0x4,%esp
f0102e69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e6f:	83 c8 04             	or     $0x4,%eax
f0102e72:	50                   	push   %eax
f0102e73:	ff 75 10             	pushl  0x10(%ebp)
f0102e76:	ff 75 0c             	pushl  0xc(%ebp)
f0102e79:	53                   	push   %ebx
f0102e7a:	e8 6b ff ff ff       	call   f0102dea <user_mem_check>
f0102e7f:	83 c4 10             	add    $0x10,%esp
f0102e82:	85 c0                	test   %eax,%eax
f0102e84:	79 21                	jns    f0102ea7 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e86:	83 ec 04             	sub    $0x4,%esp
f0102e89:	ff 35 60 82 2a f0    	pushl  0xf02a8260
f0102e8f:	ff 73 48             	pushl  0x48(%ebx)
f0102e92:	68 10 81 10 f0       	push   $0xf0108110
f0102e97:	e8 c1 08 00 00       	call   f010375d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e9c:	89 1c 24             	mov    %ebx,(%esp)
f0102e9f:	e8 bf 05 00 00       	call   f0103463 <env_destroy>
f0102ea4:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ea7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102eaa:	c9                   	leave  
f0102eab:	c3                   	ret    

f0102eac <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102eac:	55                   	push   %ebp
f0102ead:	89 e5                	mov    %esp,%ebp
f0102eaf:	57                   	push   %edi
f0102eb0:	56                   	push   %esi
f0102eb1:	53                   	push   %ebx
f0102eb2:	83 ec 1c             	sub    $0x1c,%esp
f0102eb5:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
f0102eb7:	89 d3                	mov    %edx,%ebx
f0102eb9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        end = ROUNDUP(va + len, PGSIZE);
f0102ebf:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102ec6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ecb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(; start < end; start += PGSIZE) {
f0102ece:	eb 4c                	jmp    f0102f1c <region_alloc+0x70>
                if((newpage = page_alloc(0)) == NULL)
f0102ed0:	83 ec 0c             	sub    $0xc,%esp
f0102ed3:	6a 00                	push   $0x0
f0102ed5:	e8 dc e0 ff ff       	call   f0100fb6 <page_alloc>
f0102eda:	89 c6                	mov    %eax,%esi
f0102edc:	83 c4 10             	add    $0x10,%esp
f0102edf:	85 c0                	test   %eax,%eax
f0102ee1:	75 10                	jne    f0102ef3 <region_alloc+0x47>
                       cprintf("page_alloc return null\n");
f0102ee3:	83 ec 0c             	sub    $0xc,%esp
f0102ee6:	68 45 81 10 f0       	push   $0xf0108145
f0102eeb:	e8 6d 08 00 00       	call   f010375d <cprintf>
f0102ef0:	83 c4 10             	add    $0x10,%esp
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
f0102ef3:	6a 06                	push   $0x6
f0102ef5:	53                   	push   %ebx
f0102ef6:	56                   	push   %esi
f0102ef7:	ff 77 60             	pushl  0x60(%edi)
f0102efa:	e8 cd e3 ff ff       	call   f01012cc <page_insert>
f0102eff:	83 c4 10             	add    $0x10,%esp
f0102f02:	85 c0                	test   %eax,%eax
f0102f04:	79 10                	jns    f0102f16 <region_alloc+0x6a>
                       cprintf("insert failing\n");
f0102f06:	83 ec 0c             	sub    $0xc,%esp
f0102f09:	68 5d 81 10 f0       	push   $0xf010815d
f0102f0e:	e8 4a 08 00 00       	call   f010375d <cprintf>
f0102f13:	83 c4 10             	add    $0x10,%esp
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
        end = ROUNDUP(va + len, PGSIZE);
        for(; start < end; start += PGSIZE) {
f0102f16:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f1c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f1f:	72 af                	jb     f0102ed0 <region_alloc+0x24>
                       cprintf("page_alloc return null\n");
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
                       cprintf("insert failing\n");

        }
}
f0102f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f24:	5b                   	pop    %ebx
f0102f25:	5e                   	pop    %esi
f0102f26:	5f                   	pop    %edi
f0102f27:	5d                   	pop    %ebp
f0102f28:	c3                   	ret    

f0102f29 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f29:	55                   	push   %ebp
f0102f2a:	89 e5                	mov    %esp,%ebp
f0102f2c:	56                   	push   %esi
f0102f2d:	53                   	push   %ebx
f0102f2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f31:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f34:	85 c0                	test   %eax,%eax
f0102f36:	75 1a                	jne    f0102f52 <envid2env+0x29>
		*env_store = curenv;
f0102f38:	e8 de 2f 00 00       	call   f0105f1b <cpunum>
f0102f3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f40:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0102f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f49:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f50:	eb 70                	jmp    f0102fc2 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f52:	89 c3                	mov    %eax,%ebx
f0102f54:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f5a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f5d:	03 1d 6c 82 2a f0    	add    0xf02a826c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f63:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f67:	74 05                	je     f0102f6e <envid2env+0x45>
f0102f69:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f6c:	74 10                	je     f0102f7e <envid2env+0x55>
		*env_store = 0;
f0102f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f77:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f7c:	eb 44                	jmp    f0102fc2 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f7e:	84 d2                	test   %dl,%dl
f0102f80:	74 36                	je     f0102fb8 <envid2env+0x8f>
f0102f82:	e8 94 2f 00 00       	call   f0105f1b <cpunum>
f0102f87:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f8a:	39 98 48 90 2a f0    	cmp    %ebx,-0xfd56fb8(%eax)
f0102f90:	74 26                	je     f0102fb8 <envid2env+0x8f>
f0102f92:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f95:	e8 81 2f 00 00       	call   f0105f1b <cpunum>
f0102f9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f9d:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0102fa3:	3b 70 48             	cmp    0x48(%eax),%esi
f0102fa6:	74 10                	je     f0102fb8 <envid2env+0x8f>
		*env_store = 0;
f0102fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fb1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fb6:	eb 0a                	jmp    f0102fc2 <envid2env+0x99>
	}

	*env_store = e;
f0102fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fbb:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fc2:	5b                   	pop    %ebx
f0102fc3:	5e                   	pop    %esi
f0102fc4:	5d                   	pop    %ebp
f0102fc5:	c3                   	ret    

f0102fc6 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102fc6:	55                   	push   %ebp
f0102fc7:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102fc9:	b8 00 43 12 f0       	mov    $0xf0124300,%eax
f0102fce:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102fd1:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fd6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102fd8:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102fda:	b0 10                	mov    $0x10,%al
f0102fdc:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102fde:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102fe0:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102fe2:	ea e9 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fe9
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102fe9:	b0 00                	mov    $0x0,%al
f0102feb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fee:	5d                   	pop    %ebp
f0102fef:	c3                   	ret    

f0102ff0 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102ff0:	55                   	push   %ebp
f0102ff1:	89 e5                	mov    %esp,%ebp
f0102ff3:	56                   	push   %esi
f0102ff4:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
		envs[i].env_id = 0;
f0102ff5:	8b 35 6c 82 2a f0    	mov    0xf02a826c,%esi
f0102ffb:	8b 15 70 82 2a f0    	mov    0xf02a8270,%edx
f0103001:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103007:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010300a:	89 c1                	mov    %eax,%ecx
f010300c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103013:	89 50 44             	mov    %edx,0x44(%eax)
f0103016:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f0103019:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
f010301b:	39 d8                	cmp    %ebx,%eax
f010301d:	75 eb                	jne    f010300a <env_init+0x1a>
f010301f:	89 35 70 82 2a f0    	mov    %esi,0xf02a8270
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	} 
	// Per-CPU part of the initialization
	env_init_percpu();
f0103025:	e8 9c ff ff ff       	call   f0102fc6 <env_init_percpu>
                
}
f010302a:	5b                   	pop    %ebx
f010302b:	5e                   	pop    %esi
f010302c:	5d                   	pop    %ebp
f010302d:	c3                   	ret    

f010302e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010302e:	55                   	push   %ebp
f010302f:	89 e5                	mov    %esp,%ebp
f0103031:	53                   	push   %ebx
f0103032:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
f0103035:	8b 1d 70 82 2a f0    	mov    0xf02a8270,%ebx
f010303b:	85 db                	test   %ebx,%ebx
f010303d:	0f 84 34 01 00 00    	je     f0103177 <env_alloc+0x149>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103043:	83 ec 0c             	sub    $0xc,%esp
f0103046:	6a 01                	push   $0x1
f0103048:	e8 69 df ff ff       	call   f0100fb6 <page_alloc>
f010304d:	83 c4 10             	add    $0x10,%esp
f0103050:	85 c0                	test   %eax,%eax
f0103052:	0f 84 26 01 00 00    	je     f010317e <env_alloc+0x150>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        p->pp_ref++;
f0103058:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010305d:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0103063:	c1 f8 03             	sar    $0x3,%eax
f0103066:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103069:	89 c2                	mov    %eax,%edx
f010306b:	c1 ea 0c             	shr    $0xc,%edx
f010306e:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0103074:	72 12                	jb     f0103088 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103076:	50                   	push   %eax
f0103077:	68 24 6f 10 f0       	push   $0xf0106f24
f010307c:	6a 58                	push   $0x58
f010307e:	68 ea 74 10 f0       	push   $0xf01074ea
f0103083:	e8 b8 cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103088:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = page2kva(p);    
f010308d:	89 43 60             	mov    %eax,0x60(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
f0103090:	83 ec 04             	sub    $0x4,%esp
f0103093:	68 00 10 00 00       	push   $0x1000
f0103098:	ff 35 dc 8e 2a f0    	pushl  0xf02a8edc
f010309e:	50                   	push   %eax
f010309f:	e8 08 29 00 00       	call   f01059ac <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030a4:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030a7:	83 c4 10             	add    $0x10,%esp
f01030aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030af:	77 15                	ja     f01030c6 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030b1:	50                   	push   %eax
f01030b2:	68 48 6f 10 f0       	push   $0xf0106f48
f01030b7:	68 c4 00 00 00       	push   $0xc4
f01030bc:	68 6d 81 10 f0       	push   $0xf010816d
f01030c1:	e8 7a cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030c6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030cc:	83 ca 05             	or     $0x5,%edx
f01030cf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0) 
		return r;
 
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030d5:	8b 43 48             	mov    0x48(%ebx),%eax
f01030d8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030dd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030e7:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01030ea:	89 da                	mov    %ebx,%edx
f01030ec:	2b 15 6c 82 2a f0    	sub    0xf02a826c,%edx
f01030f2:	c1 fa 02             	sar    $0x2,%edx
f01030f5:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030fb:	09 d0                	or     %edx,%eax
f01030fd:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103100:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103103:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103106:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010310d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103114:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&(e->env_tf), 0, sizeof(e->env_tf));
f010311b:	83 ec 04             	sub    $0x4,%esp
f010311e:	6a 44                	push   $0x44
f0103120:	6a 00                	push   $0x0
f0103122:	53                   	push   %ebx
f0103123:	e8 cf 27 00 00       	call   f01058f7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103128:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010312e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103134:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010313a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103141:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0103147:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010314e:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103155:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103159:	8b 43 44             	mov    0x44(%ebx),%eax
f010315c:	a3 70 82 2a f0       	mov    %eax,0xf02a8270
        e->env_link = NULL;
f0103161:	c7 43 44 00 00 00 00 	movl   $0x0,0x44(%ebx)
	*newenv_store = e;
f0103168:	8b 45 08             	mov    0x8(%ebp),%eax
f010316b:	89 18                	mov    %ebx,(%eax)
	 //cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
f010316d:	83 c4 10             	add    $0x10,%esp
f0103170:	b8 00 00 00 00       	mov    $0x0,%eax
f0103175:	eb 0c                	jmp    f0103183 <env_alloc+0x155>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
		return -E_NO_FREE_ENV;
f0103177:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010317c:	eb 05                	jmp    f0103183 <env_alloc+0x155>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010317e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
}
f0103183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103186:	c9                   	leave  
f0103187:	c3                   	ret    

f0103188 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103188:	55                   	push   %ebp
f0103189:	89 e5                	mov    %esp,%ebp
f010318b:	57                   	push   %edi
f010318c:	56                   	push   %esi
f010318d:	53                   	push   %ebx
f010318e:	83 ec 34             	sub    $0x34,%esp
f0103191:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *e;
        int tmp;
        if((tmp = env_alloc(&e, 0)) != 0)
f0103197:	6a 00                	push   $0x0
f0103199:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010319c:	50                   	push   %eax
f010319d:	e8 8c fe ff ff       	call   f010302e <env_alloc>
f01031a2:	83 c4 10             	add    $0x10,%esp
f01031a5:	85 c0                	test   %eax,%eax
f01031a7:	74 17                	je     f01031c0 <env_create+0x38>
               panic("evn create fails!\n");
f01031a9:	83 ec 04             	sub    $0x4,%esp
f01031ac:	68 78 81 10 f0       	push   $0xf0108178
f01031b1:	68 90 01 00 00       	push   $0x190
f01031b6:	68 6d 81 10 f0       	push   $0xf010816d
f01031bb:	e8 80 ce ff ff       	call   f0100040 <_panic>
       
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
        if (type == ENV_TYPE_FS)
f01031c0:	83 fb 01             	cmp    $0x1,%ebx
f01031c3:	75 0a                	jne    f01031cf <env_create+0x47>
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031c8:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
        e->env_type =type;
f01031cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01031d5:	89 58 50             	mov    %ebx,0x50(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf_img = (struct Elf *)binary;
        struct Proghdr *ph, *eph;
        if (elf_img->e_magic != ELF_MAGIC)
f01031d8:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01031de:	74 17                	je     f01031f7 <env_create+0x6f>
                panic("Not executable!");
f01031e0:	83 ec 04             	sub    $0x4,%esp
f01031e3:	68 8b 81 10 f0       	push   $0xf010818b
f01031e8:	68 6d 01 00 00       	push   $0x16d
f01031ed:	68 6d 81 10 f0       	push   $0xf010816d
f01031f2:	e8 49 ce ff ff       	call   f0100040 <_panic>
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
f01031f7:	89 fb                	mov    %edi,%ebx
f01031f9:	03 5f 1c             	add    0x1c(%edi),%ebx
        eph = ph + elf_img->e_phnum;
f01031fc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103200:	c1 e6 05             	shl    $0x5,%esi
f0103203:	01 de                	add    %ebx,%esi
        lcr3(PADDR(e->env_pgdir));
f0103205:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103208:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010320b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103210:	77 15                	ja     f0103227 <env_create+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103212:	50                   	push   %eax
f0103213:	68 48 6f 10 f0       	push   $0xf0106f48
f0103218:	68 70 01 00 00       	push   $0x170
f010321d:	68 6d 81 10 f0       	push   $0xf010816d
f0103222:	e8 19 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103227:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010322c:	0f 22 d8             	mov    %eax,%cr3
f010322f:	eb 3d                	jmp    f010326e <env_create+0xe6>
        
        for(; ph < eph; ph++) {
                if (ph->p_type != ELF_PROG_LOAD)
f0103231:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103234:	75 35                	jne    f010326b <env_create+0xe3>
                       continue;
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103236:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103239:	8b 53 08             	mov    0x8(%ebx),%edx
f010323c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010323f:	e8 68 fc ff ff       	call   f0102eac <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f0103244:	83 ec 04             	sub    $0x4,%esp
f0103247:	ff 73 14             	pushl  0x14(%ebx)
f010324a:	6a 00                	push   $0x0
f010324c:	ff 73 08             	pushl  0x8(%ebx)
f010324f:	e8 a3 26 00 00       	call   f01058f7 <memset>
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103254:	83 c4 0c             	add    $0xc,%esp
f0103257:	ff 73 10             	pushl  0x10(%ebx)
f010325a:	89 f8                	mov    %edi,%eax
f010325c:	03 43 04             	add    0x4(%ebx),%eax
f010325f:	50                   	push   %eax
f0103260:	ff 73 08             	pushl  0x8(%ebx)
f0103263:	e8 44 27 00 00       	call   f01059ac <memcpy>
f0103268:	83 c4 10             	add    $0x10,%esp
                panic("Not executable!");
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        eph = ph + elf_img->e_phnum;
        lcr3(PADDR(e->env_pgdir));
        
        for(; ph < eph; ph++) {
f010326b:	83 c3 20             	add    $0x20,%ebx
f010326e:	39 de                	cmp    %ebx,%esi
f0103270:	77 bf                	ja     f0103231 <env_create+0xa9>
                       continue;
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        }
        lcr3(PADDR(kern_pgdir));
f0103272:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103277:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010327c:	77 15                	ja     f0103293 <env_create+0x10b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010327e:	50                   	push   %eax
f010327f:	68 48 6f 10 f0       	push   $0xf0106f48
f0103284:	68 79 01 00 00       	push   $0x179
f0103289:	68 6d 81 10 f0       	push   $0xf010816d
f010328e:	e8 ad cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103293:	05 00 00 00 10       	add    $0x10000000,%eax
f0103298:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elf_img->e_entry;
f010329b:	8b 47 18             	mov    0x18(%edi),%eax
f010329e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01032a1:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01032a4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01032a9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01032ae:	89 f8                	mov    %edi,%eax
f01032b0:	e8 f7 fb ff ff       	call   f0102eac <region_alloc>
        if (type == ENV_TYPE_FS)
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
        e->env_type =type;
        load_icode(e, binary);
  
}
f01032b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032b8:	5b                   	pop    %ebx
f01032b9:	5e                   	pop    %esi
f01032ba:	5f                   	pop    %edi
f01032bb:	5d                   	pop    %ebp
f01032bc:	c3                   	ret    

f01032bd <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032bd:	55                   	push   %ebp
f01032be:	89 e5                	mov    %esp,%ebp
f01032c0:	57                   	push   %edi
f01032c1:	56                   	push   %esi
f01032c2:	53                   	push   %ebx
f01032c3:	83 ec 1c             	sub    $0x1c,%esp
f01032c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032c9:	e8 4d 2c 00 00       	call   f0105f1b <cpunum>
f01032ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01032d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032d8:	39 b8 48 90 2a f0    	cmp    %edi,-0xfd56fb8(%eax)
f01032de:	75 30                	jne    f0103310 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01032e0:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032e5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032ea:	77 15                	ja     f0103301 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032ec:	50                   	push   %eax
f01032ed:	68 48 6f 10 f0       	push   $0xf0106f48
f01032f2:	68 a9 01 00 00       	push   $0x1a9
f01032f7:	68 6d 81 10 f0       	push   $0xf010816d
f01032fc:	e8 3f cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103301:	05 00 00 00 10       	add    $0x10000000,%eax
f0103306:	0f 22 d8             	mov    %eax,%cr3
f0103309:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103310:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103313:	89 d0                	mov    %edx,%eax
f0103315:	c1 e0 02             	shl    $0x2,%eax
f0103318:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010331b:	8b 47 60             	mov    0x60(%edi),%eax
f010331e:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103321:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103327:	0f 84 a8 00 00 00    	je     f01033d5 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010332d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103333:	89 f0                	mov    %esi,%eax
f0103335:	c1 e8 0c             	shr    $0xc,%eax
f0103338:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010333b:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0103341:	72 15                	jb     f0103358 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103343:	56                   	push   %esi
f0103344:	68 24 6f 10 f0       	push   $0xf0106f24
f0103349:	68 b8 01 00 00       	push   $0x1b8
f010334e:	68 6d 81 10 f0       	push   $0xf010816d
f0103353:	e8 e8 cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103358:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010335b:	c1 e0 16             	shl    $0x16,%eax
f010335e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103361:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103366:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010336d:	01 
f010336e:	74 17                	je     f0103387 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103370:	83 ec 08             	sub    $0x8,%esp
f0103373:	89 d8                	mov    %ebx,%eax
f0103375:	c1 e0 0c             	shl    $0xc,%eax
f0103378:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010337b:	50                   	push   %eax
f010337c:	ff 77 60             	pushl  0x60(%edi)
f010337f:	e8 f7 de ff ff       	call   f010127b <page_remove>
f0103384:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103387:	83 c3 01             	add    $0x1,%ebx
f010338a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103390:	75 d4                	jne    f0103366 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103392:	8b 47 60             	mov    0x60(%edi),%eax
f0103395:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103398:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010339f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033a2:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f01033a8:	72 14                	jb     f01033be <env_free+0x101>
		panic("pa2page called with invalid pa");
f01033aa:	83 ec 04             	sub    $0x4,%esp
f01033ad:	68 ec 78 10 f0       	push   $0xf01078ec
f01033b2:	6a 51                	push   $0x51
f01033b4:	68 ea 74 10 f0       	push   $0xf01074ea
f01033b9:	e8 82 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01033be:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033c1:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
f01033c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033c9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033cc:	50                   	push   %eax
f01033cd:	e8 91 dc ff ff       	call   f0101063 <page_decref>
f01033d2:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
        //cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033d5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01033d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033dc:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01033e1:	0f 85 29 ff ff ff    	jne    f0103310 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033e7:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033ef:	77 15                	ja     f0103406 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f1:	50                   	push   %eax
f01033f2:	68 48 6f 10 f0       	push   $0xf0106f48
f01033f7:	68 c6 01 00 00       	push   $0x1c6
f01033fc:	68 6d 81 10 f0       	push   $0xf010816d
f0103401:	e8 3a cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103406:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010340d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103412:	c1 e8 0c             	shr    $0xc,%eax
f0103415:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f010341b:	72 14                	jb     f0103431 <env_free+0x174>
		panic("pa2page called with invalid pa");
f010341d:	83 ec 04             	sub    $0x4,%esp
f0103420:	68 ec 78 10 f0       	push   $0xf01078ec
f0103425:	6a 51                	push   $0x51
f0103427:	68 ea 74 10 f0       	push   $0xf01074ea
f010342c:	e8 0f cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103431:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103434:	8b 15 e0 8e 2a f0    	mov    0xf02a8ee0,%edx
f010343a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010343d:	50                   	push   %eax
f010343e:	e8 20 dc ff ff       	call   f0101063 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103443:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010344a:	a1 70 82 2a f0       	mov    0xf02a8270,%eax
f010344f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103452:	89 3d 70 82 2a f0    	mov    %edi,0xf02a8270
f0103458:	83 c4 10             	add    $0x10,%esp
}
f010345b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010345e:	5b                   	pop    %ebx
f010345f:	5e                   	pop    %esi
f0103460:	5f                   	pop    %edi
f0103461:	5d                   	pop    %ebp
f0103462:	c3                   	ret    

f0103463 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103463:	55                   	push   %ebp
f0103464:	89 e5                	mov    %esp,%ebp
f0103466:	53                   	push   %ebx
f0103467:	83 ec 04             	sub    $0x4,%esp
f010346a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010346d:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103471:	75 19                	jne    f010348c <env_destroy+0x29>
f0103473:	e8 a3 2a 00 00       	call   f0105f1b <cpunum>
f0103478:	6b c0 74             	imul   $0x74,%eax,%eax
f010347b:	39 98 48 90 2a f0    	cmp    %ebx,-0xfd56fb8(%eax)
f0103481:	74 09                	je     f010348c <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103483:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010348a:	eb 33                	jmp    f01034bf <env_destroy+0x5c>
	}

	env_free(e);
f010348c:	83 ec 0c             	sub    $0xc,%esp
f010348f:	53                   	push   %ebx
f0103490:	e8 28 fe ff ff       	call   f01032bd <env_free>

	if (curenv == e) {
f0103495:	e8 81 2a 00 00       	call   f0105f1b <cpunum>
f010349a:	6b c0 74             	imul   $0x74,%eax,%eax
f010349d:	83 c4 10             	add    $0x10,%esp
f01034a0:	39 98 48 90 2a f0    	cmp    %ebx,-0xfd56fb8(%eax)
f01034a6:	75 17                	jne    f01034bf <env_destroy+0x5c>
		curenv = NULL;
f01034a8:	e8 6e 2a 00 00       	call   f0105f1b <cpunum>
f01034ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01034b0:	c7 80 48 90 2a f0 00 	movl   $0x0,-0xfd56fb8(%eax)
f01034b7:	00 00 00 
		sched_yield();
f01034ba:	e8 11 11 00 00       	call   f01045d0 <sched_yield>
	}
}
f01034bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034c2:	c9                   	leave  
f01034c3:	c3                   	ret    

f01034c4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034c4:	55                   	push   %ebp
f01034c5:	89 e5                	mov    %esp,%ebp
f01034c7:	53                   	push   %ebx
f01034c8:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034cb:	e8 4b 2a 00 00       	call   f0105f1b <cpunum>
f01034d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d3:	8b 98 48 90 2a f0    	mov    -0xfd56fb8(%eax),%ebx
f01034d9:	e8 3d 2a 00 00       	call   f0105f1b <cpunum>
f01034de:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01034e1:	8b 65 08             	mov    0x8(%ebp),%esp
f01034e4:	61                   	popa   
f01034e5:	07                   	pop    %es
f01034e6:	1f                   	pop    %ds
f01034e7:	83 c4 08             	add    $0x8,%esp
f01034ea:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034eb:	83 ec 04             	sub    $0x4,%esp
f01034ee:	68 9b 81 10 f0       	push   $0xf010819b
f01034f3:	68 fc 01 00 00       	push   $0x1fc
f01034f8:	68 6d 81 10 f0       	push   $0xf010816d
f01034fd:	e8 3e cb ff ff       	call   f0100040 <_panic>

f0103502 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103502:	55                   	push   %ebp
f0103503:	89 e5                	mov    %esp,%ebp
f0103505:	53                   	push   %ebx
f0103506:	83 ec 04             	sub    $0x4,%esp
f0103509:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if( e != curenv) {
f010350c:	e8 0a 2a 00 00       	call   f0105f1b <cpunum>
f0103511:	6b c0 74             	imul   $0x74,%eax,%eax
f0103514:	39 98 48 90 2a f0    	cmp    %ebx,-0xfd56fb8(%eax)
f010351a:	0f 84 a4 00 00 00    	je     f01035c4 <env_run+0xc2>
                if (curenv && curenv->env_status == ENV_RUNNING)
f0103520:	e8 f6 29 00 00       	call   f0105f1b <cpunum>
f0103525:	6b c0 74             	imul   $0x74,%eax,%eax
f0103528:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f010352f:	74 29                	je     f010355a <env_run+0x58>
f0103531:	e8 e5 29 00 00       	call   f0105f1b <cpunum>
f0103536:	6b c0 74             	imul   $0x74,%eax,%eax
f0103539:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010353f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103543:	75 15                	jne    f010355a <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103545:	e8 d1 29 00 00       	call   f0105f1b <cpunum>
f010354a:	6b c0 74             	imul   $0x74,%eax,%eax
f010354d:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0103553:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
                curenv = e;
f010355a:	e8 bc 29 00 00       	call   f0105f1b <cpunum>
f010355f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103562:	89 98 48 90 2a f0    	mov    %ebx,-0xfd56fb8(%eax)
                curenv->env_runs++;
f0103568:	e8 ae 29 00 00       	call   f0105f1b <cpunum>
f010356d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103570:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0103576:	83 40 58 01          	addl   $0x1,0x58(%eax)
                curenv->env_status = ENV_RUNNING;
f010357a:	e8 9c 29 00 00       	call   f0105f1b <cpunum>
f010357f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103582:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0103588:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
                lcr3(PADDR(curenv->env_pgdir));
f010358f:	e8 87 29 00 00       	call   f0105f1b <cpunum>
f0103594:	6b c0 74             	imul   $0x74,%eax,%eax
f0103597:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010359d:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a5:	77 15                	ja     f01035bc <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a7:	50                   	push   %eax
f01035a8:	68 48 6f 10 f0       	push   $0xf0106f48
f01035ad:	68 20 02 00 00       	push   $0x220
f01035b2:	68 6d 81 10 f0       	push   $0xf010816d
f01035b7:	e8 84 ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01035bc:	05 00 00 00 10       	add    $0x10000000,%eax
f01035c1:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01035c4:	83 ec 0c             	sub    $0xc,%esp
f01035c7:	68 c0 43 12 f0       	push   $0xf01243c0
f01035cc:	e8 52 2c 00 00       	call   f0106223 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01035d1:	f3 90                	pause  
        }
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01035d3:	e8 43 29 00 00       	call   f0105f1b <cpunum>
f01035d8:	83 c4 04             	add    $0x4,%esp
f01035db:	6b c0 74             	imul   $0x74,%eax,%eax
f01035de:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f01035e4:	e8 db fe ff ff       	call   f01034c4 <env_pop_tf>

f01035e9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035e9:	55                   	push   %ebp
f01035ea:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035ec:	ba 70 00 00 00       	mov    $0x70,%edx
f01035f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01035f4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035f5:	b2 71                	mov    $0x71,%dl
f01035f7:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035f8:	0f b6 c0             	movzbl %al,%eax
}
f01035fb:	5d                   	pop    %ebp
f01035fc:	c3                   	ret    

f01035fd <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035fd:	55                   	push   %ebp
f01035fe:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103600:	ba 70 00 00 00       	mov    $0x70,%edx
f0103605:	8b 45 08             	mov    0x8(%ebp),%eax
f0103608:	ee                   	out    %al,(%dx)
f0103609:	b2 71                	mov    $0x71,%dl
f010360b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010360e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010360f:	5d                   	pop    %ebp
f0103610:	c3                   	ret    

f0103611 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103611:	55                   	push   %ebp
f0103612:	89 e5                	mov    %esp,%ebp
f0103614:	56                   	push   %esi
f0103615:	53                   	push   %ebx
f0103616:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103619:	66 a3 a8 43 12 f0    	mov    %ax,0xf01243a8
	if (!didinit)
f010361f:	80 3d 74 82 2a f0 00 	cmpb   $0x0,0xf02a8274
f0103626:	74 57                	je     f010367f <irq_setmask_8259A+0x6e>
f0103628:	89 c6                	mov    %eax,%esi
f010362a:	ba 21 00 00 00       	mov    $0x21,%edx
f010362f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103630:	66 c1 e8 08          	shr    $0x8,%ax
f0103634:	b2 a1                	mov    $0xa1,%dl
f0103636:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103637:	83 ec 0c             	sub    $0xc,%esp
f010363a:	68 a7 81 10 f0       	push   $0xf01081a7
f010363f:	e8 19 01 00 00       	call   f010375d <cprintf>
f0103644:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103647:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010364c:	0f b7 f6             	movzwl %si,%esi
f010364f:	f7 d6                	not    %esi
f0103651:	0f a3 de             	bt     %ebx,%esi
f0103654:	73 11                	jae    f0103667 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103656:	83 ec 08             	sub    $0x8,%esp
f0103659:	53                   	push   %ebx
f010365a:	68 ab 86 10 f0       	push   $0xf01086ab
f010365f:	e8 f9 00 00 00       	call   f010375d <cprintf>
f0103664:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103667:	83 c3 01             	add    $0x1,%ebx
f010366a:	83 fb 10             	cmp    $0x10,%ebx
f010366d:	75 e2                	jne    f0103651 <irq_setmask_8259A+0x40>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010366f:	83 ec 0c             	sub    $0xc,%esp
f0103672:	68 f3 77 10 f0       	push   $0xf01077f3
f0103677:	e8 e1 00 00 00       	call   f010375d <cprintf>
f010367c:	83 c4 10             	add    $0x10,%esp
}
f010367f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103682:	5b                   	pop    %ebx
f0103683:	5e                   	pop    %esi
f0103684:	5d                   	pop    %ebp
f0103685:	c3                   	ret    

f0103686 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103686:	c6 05 74 82 2a f0 01 	movb   $0x1,0xf02a8274
f010368d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103697:	ee                   	out    %al,(%dx)
f0103698:	b2 a1                	mov    $0xa1,%dl
f010369a:	ee                   	out    %al,(%dx)
f010369b:	b2 20                	mov    $0x20,%dl
f010369d:	b8 11 00 00 00       	mov    $0x11,%eax
f01036a2:	ee                   	out    %al,(%dx)
f01036a3:	b2 21                	mov    $0x21,%dl
f01036a5:	b8 20 00 00 00       	mov    $0x20,%eax
f01036aa:	ee                   	out    %al,(%dx)
f01036ab:	b8 04 00 00 00       	mov    $0x4,%eax
f01036b0:	ee                   	out    %al,(%dx)
f01036b1:	b8 03 00 00 00       	mov    $0x3,%eax
f01036b6:	ee                   	out    %al,(%dx)
f01036b7:	b2 a0                	mov    $0xa0,%dl
f01036b9:	b8 11 00 00 00       	mov    $0x11,%eax
f01036be:	ee                   	out    %al,(%dx)
f01036bf:	b2 a1                	mov    $0xa1,%dl
f01036c1:	b8 28 00 00 00       	mov    $0x28,%eax
f01036c6:	ee                   	out    %al,(%dx)
f01036c7:	b8 02 00 00 00       	mov    $0x2,%eax
f01036cc:	ee                   	out    %al,(%dx)
f01036cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01036d2:	ee                   	out    %al,(%dx)
f01036d3:	b2 20                	mov    $0x20,%dl
f01036d5:	b8 68 00 00 00       	mov    $0x68,%eax
f01036da:	ee                   	out    %al,(%dx)
f01036db:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036e0:	ee                   	out    %al,(%dx)
f01036e1:	b2 a0                	mov    $0xa0,%dl
f01036e3:	b8 68 00 00 00       	mov    $0x68,%eax
f01036e8:	ee                   	out    %al,(%dx)
f01036e9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036ee:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036ef:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01036f6:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036fa:	74 13                	je     f010370f <pic_init+0x89>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036fc:	55                   	push   %ebp
f01036fd:	89 e5                	mov    %esp,%ebp
f01036ff:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103702:	0f b7 c0             	movzwl %ax,%eax
f0103705:	50                   	push   %eax
f0103706:	e8 06 ff ff ff       	call   f0103611 <irq_setmask_8259A>
f010370b:	83 c4 10             	add    $0x10,%esp
}
f010370e:	c9                   	leave  
f010370f:	f3 c3                	repz ret 

f0103711 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103711:	55                   	push   %ebp
f0103712:	89 e5                	mov    %esp,%ebp
f0103714:	ba 20 00 00 00       	mov    $0x20,%edx
f0103719:	b8 20 00 00 00       	mov    $0x20,%eax
f010371e:	ee                   	out    %al,(%dx)
f010371f:	b2 a0                	mov    $0xa0,%dl
f0103721:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103722:	5d                   	pop    %ebp
f0103723:	c3                   	ret    

f0103724 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103724:	55                   	push   %ebp
f0103725:	89 e5                	mov    %esp,%ebp
f0103727:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010372a:	ff 75 08             	pushl  0x8(%ebp)
f010372d:	e8 61 d0 ff ff       	call   f0100793 <cputchar>
f0103732:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103735:	c9                   	leave  
f0103736:	c3                   	ret    

f0103737 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103737:	55                   	push   %ebp
f0103738:	89 e5                	mov    %esp,%ebp
f010373a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010373d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103744:	ff 75 0c             	pushl  0xc(%ebp)
f0103747:	ff 75 08             	pushl  0x8(%ebp)
f010374a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010374d:	50                   	push   %eax
f010374e:	68 24 37 10 f0       	push   $0xf0103724
f0103753:	e8 14 1b 00 00       	call   f010526c <vprintfmt>
	return cnt;
}
f0103758:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010375b:	c9                   	leave  
f010375c:	c3                   	ret    

f010375d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010375d:	55                   	push   %ebp
f010375e:	89 e5                	mov    %esp,%ebp
f0103760:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103763:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103766:	50                   	push   %eax
f0103767:	ff 75 08             	pushl  0x8(%ebp)
f010376a:	e8 c8 ff ff ff       	call   f0103737 <vcprintf>
	va_end(ap);

	return cnt;
}
f010376f:	c9                   	leave  
f0103770:	c3                   	ret    

f0103771 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103771:	55                   	push   %ebp
f0103772:	89 e5                	mov    %esp,%ebp
f0103774:	57                   	push   %edi
f0103775:	56                   	push   %esi
f0103776:	53                   	push   %ebx
f0103777:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
        int cid = thiscpu->cpu_id;
f010377a:	e8 9c 27 00 00       	call   f0105f1b <cpunum>
f010377f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103782:	0f b6 98 40 90 2a f0 	movzbl -0xfd56fc0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103789:	e8 8d 27 00 00       	call   f0105f1b <cpunum>
f010378e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103791:	89 da                	mov    %ebx,%edx
f0103793:	f7 da                	neg    %edx
f0103795:	c1 e2 10             	shl    $0x10,%edx
f0103798:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010379e:	89 90 50 90 2a f0    	mov    %edx,-0xfd56fb0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01037a4:	e8 72 27 00 00       	call   f0105f1b <cpunum>
f01037a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ac:	66 c7 80 54 90 2a f0 	movw   $0x10,-0xfd56fac(%eax)
f01037b3:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01037b5:	83 c3 05             	add    $0x5,%ebx
f01037b8:	e8 5e 27 00 00       	call   f0105f1b <cpunum>
f01037bd:	89 c7                	mov    %eax,%edi
f01037bf:	e8 57 27 00 00       	call   f0105f1b <cpunum>
f01037c4:	89 c6                	mov    %eax,%esi
f01037c6:	e8 50 27 00 00       	call   f0105f1b <cpunum>
f01037cb:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f01037d2:	f0 67 00 
f01037d5:	6b ff 74             	imul   $0x74,%edi,%edi
f01037d8:	81 c7 4c 90 2a f0    	add    $0xf02a904c,%edi
f01037de:	66 89 3c dd 42 43 12 	mov    %di,-0xfedbcbe(,%ebx,8)
f01037e5:	f0 
f01037e6:	6b d6 74             	imul   $0x74,%esi,%edx
f01037e9:	81 c2 4c 90 2a f0    	add    $0xf02a904c,%edx
f01037ef:	c1 ea 10             	shr    $0x10,%edx
f01037f2:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f01037f9:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103800:	40 
f0103801:	6b c0 74             	imul   $0x74,%eax,%eax
f0103804:	05 4c 90 2a f0       	add    $0xf02a904c,%eax
f0103809:	c1 e8 18             	shr    $0x18,%eax
f010380c:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f0103813:	c6 04 dd 45 43 12 f0 	movb   $0x89,-0xfedbcbb(,%ebx,8)
f010381a:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f010381b:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010381e:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103821:	b8 aa 43 12 f0       	mov    $0xf01243aa,%eax
f0103826:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103829:	83 c4 0c             	add    $0xc,%esp
f010382c:	5b                   	pop    %ebx
f010382d:	5e                   	pop    %esi
f010382e:	5f                   	pop    %edi
f010382f:	5d                   	pop    %ebp
f0103830:	c3                   	ret    

f0103831 <trap_init>:
}


void
trap_init(void)
{
f0103831:	55                   	push   %ebp
f0103832:	89 e5                	mov    %esp,%ebp
f0103834:	83 ec 08             	sub    $0x8,%esp
        extern void irq11();
        extern void irq12();
        extern void irq13();
        extern void irq14();
        extern void irq15();
        SETGATE(idt[0], 0, GD_KT, i0, 0);
f0103837:	b8 de 43 10 f0       	mov    $0xf01043de,%eax
f010383c:	66 a3 80 82 2a f0    	mov    %ax,0xf02a8280
f0103842:	66 c7 05 82 82 2a f0 	movw   $0x8,0xf02a8282
f0103849:	08 00 
f010384b:	c6 05 84 82 2a f0 00 	movb   $0x0,0xf02a8284
f0103852:	c6 05 85 82 2a f0 8e 	movb   $0x8e,0xf02a8285
f0103859:	c1 e8 10             	shr    $0x10,%eax
f010385c:	66 a3 86 82 2a f0    	mov    %ax,0xf02a8286
        SETGATE(idt[1], 0, GD_KT, i1, 0);
f0103862:	b8 e8 43 10 f0       	mov    $0xf01043e8,%eax
f0103867:	66 a3 88 82 2a f0    	mov    %ax,0xf02a8288
f010386d:	66 c7 05 8a 82 2a f0 	movw   $0x8,0xf02a828a
f0103874:	08 00 
f0103876:	c6 05 8c 82 2a f0 00 	movb   $0x0,0xf02a828c
f010387d:	c6 05 8d 82 2a f0 8e 	movb   $0x8e,0xf02a828d
f0103884:	c1 e8 10             	shr    $0x10,%eax
f0103887:	66 a3 8e 82 2a f0    	mov    %ax,0xf02a828e
        SETGATE(idt[2], 0, GD_KT, i2, 0);
f010388d:	b8 f2 43 10 f0       	mov    $0xf01043f2,%eax
f0103892:	66 a3 90 82 2a f0    	mov    %ax,0xf02a8290
f0103898:	66 c7 05 92 82 2a f0 	movw   $0x8,0xf02a8292
f010389f:	08 00 
f01038a1:	c6 05 94 82 2a f0 00 	movb   $0x0,0xf02a8294
f01038a8:	c6 05 95 82 2a f0 8e 	movb   $0x8e,0xf02a8295
f01038af:	c1 e8 10             	shr    $0x10,%eax
f01038b2:	66 a3 96 82 2a f0    	mov    %ax,0xf02a8296
        SETGATE(idt[3], 0, GD_KT, i3, 3);
f01038b8:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f01038bd:	66 a3 98 82 2a f0    	mov    %ax,0xf02a8298
f01038c3:	66 c7 05 9a 82 2a f0 	movw   $0x8,0xf02a829a
f01038ca:	08 00 
f01038cc:	c6 05 9c 82 2a f0 00 	movb   $0x0,0xf02a829c
f01038d3:	c6 05 9d 82 2a f0 ee 	movb   $0xee,0xf02a829d
f01038da:	c1 e8 10             	shr    $0x10,%eax
f01038dd:	66 a3 9e 82 2a f0    	mov    %ax,0xf02a829e
        SETGATE(idt[4], 0, GD_KT, i4, 0);
f01038e3:	b8 06 44 10 f0       	mov    $0xf0104406,%eax
f01038e8:	66 a3 a0 82 2a f0    	mov    %ax,0xf02a82a0
f01038ee:	66 c7 05 a2 82 2a f0 	movw   $0x8,0xf02a82a2
f01038f5:	08 00 
f01038f7:	c6 05 a4 82 2a f0 00 	movb   $0x0,0xf02a82a4
f01038fe:	c6 05 a5 82 2a f0 8e 	movb   $0x8e,0xf02a82a5
f0103905:	c1 e8 10             	shr    $0x10,%eax
f0103908:	66 a3 a6 82 2a f0    	mov    %ax,0xf02a82a6
        SETGATE(idt[5], 0, GD_KT, i5, 0);
f010390e:	b8 10 44 10 f0       	mov    $0xf0104410,%eax
f0103913:	66 a3 a8 82 2a f0    	mov    %ax,0xf02a82a8
f0103919:	66 c7 05 aa 82 2a f0 	movw   $0x8,0xf02a82aa
f0103920:	08 00 
f0103922:	c6 05 ac 82 2a f0 00 	movb   $0x0,0xf02a82ac
f0103929:	c6 05 ad 82 2a f0 8e 	movb   $0x8e,0xf02a82ad
f0103930:	c1 e8 10             	shr    $0x10,%eax
f0103933:	66 a3 ae 82 2a f0    	mov    %ax,0xf02a82ae
        SETGATE(idt[6], 0, GD_KT, i6, 0);
f0103939:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f010393e:	66 a3 b0 82 2a f0    	mov    %ax,0xf02a82b0
f0103944:	66 c7 05 b2 82 2a f0 	movw   $0x8,0xf02a82b2
f010394b:	08 00 
f010394d:	c6 05 b4 82 2a f0 00 	movb   $0x0,0xf02a82b4
f0103954:	c6 05 b5 82 2a f0 8e 	movb   $0x8e,0xf02a82b5
f010395b:	c1 e8 10             	shr    $0x10,%eax
f010395e:	66 a3 b6 82 2a f0    	mov    %ax,0xf02a82b6
        SETGATE(idt[7], 0, GD_KT, i7, 0);
f0103964:	b8 24 44 10 f0       	mov    $0xf0104424,%eax
f0103969:	66 a3 b8 82 2a f0    	mov    %ax,0xf02a82b8
f010396f:	66 c7 05 ba 82 2a f0 	movw   $0x8,0xf02a82ba
f0103976:	08 00 
f0103978:	c6 05 bc 82 2a f0 00 	movb   $0x0,0xf02a82bc
f010397f:	c6 05 bd 82 2a f0 8e 	movb   $0x8e,0xf02a82bd
f0103986:	c1 e8 10             	shr    $0x10,%eax
f0103989:	66 a3 be 82 2a f0    	mov    %ax,0xf02a82be
        SETGATE(idt[8], 0, GD_KT, i8, 0);
f010398f:	b8 2e 44 10 f0       	mov    $0xf010442e,%eax
f0103994:	66 a3 c0 82 2a f0    	mov    %ax,0xf02a82c0
f010399a:	66 c7 05 c2 82 2a f0 	movw   $0x8,0xf02a82c2
f01039a1:	08 00 
f01039a3:	c6 05 c4 82 2a f0 00 	movb   $0x0,0xf02a82c4
f01039aa:	c6 05 c5 82 2a f0 8e 	movb   $0x8e,0xf02a82c5
f01039b1:	c1 e8 10             	shr    $0x10,%eax
f01039b4:	66 a3 c6 82 2a f0    	mov    %ax,0xf02a82c6
        SETGATE(idt[9], 0, GD_KT, i9, 0);
f01039ba:	b8 36 44 10 f0       	mov    $0xf0104436,%eax
f01039bf:	66 a3 c8 82 2a f0    	mov    %ax,0xf02a82c8
f01039c5:	66 c7 05 ca 82 2a f0 	movw   $0x8,0xf02a82ca
f01039cc:	08 00 
f01039ce:	c6 05 cc 82 2a f0 00 	movb   $0x0,0xf02a82cc
f01039d5:	c6 05 cd 82 2a f0 8e 	movb   $0x8e,0xf02a82cd
f01039dc:	c1 e8 10             	shr    $0x10,%eax
f01039df:	66 a3 ce 82 2a f0    	mov    %ax,0xf02a82ce
        SETGATE(idt[10], 0, GD_KT, i10, 0);
f01039e5:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f01039ea:	66 a3 d0 82 2a f0    	mov    %ax,0xf02a82d0
f01039f0:	66 c7 05 d2 82 2a f0 	movw   $0x8,0xf02a82d2
f01039f7:	08 00 
f01039f9:	c6 05 d4 82 2a f0 00 	movb   $0x0,0xf02a82d4
f0103a00:	c6 05 d5 82 2a f0 8e 	movb   $0x8e,0xf02a82d5
f0103a07:	c1 e8 10             	shr    $0x10,%eax
f0103a0a:	66 a3 d6 82 2a f0    	mov    %ax,0xf02a82d6
        SETGATE(idt[11], 0, GD_KT, i11, 0);
f0103a10:	b8 48 44 10 f0       	mov    $0xf0104448,%eax
f0103a15:	66 a3 d8 82 2a f0    	mov    %ax,0xf02a82d8
f0103a1b:	66 c7 05 da 82 2a f0 	movw   $0x8,0xf02a82da
f0103a22:	08 00 
f0103a24:	c6 05 dc 82 2a f0 00 	movb   $0x0,0xf02a82dc
f0103a2b:	c6 05 dd 82 2a f0 8e 	movb   $0x8e,0xf02a82dd
f0103a32:	c1 e8 10             	shr    $0x10,%eax
f0103a35:	66 a3 de 82 2a f0    	mov    %ax,0xf02a82de
        SETGATE(idt[12], 0, GD_KT, i12, 0);
f0103a3b:	b8 50 44 10 f0       	mov    $0xf0104450,%eax
f0103a40:	66 a3 e0 82 2a f0    	mov    %ax,0xf02a82e0
f0103a46:	66 c7 05 e2 82 2a f0 	movw   $0x8,0xf02a82e2
f0103a4d:	08 00 
f0103a4f:	c6 05 e4 82 2a f0 00 	movb   $0x0,0xf02a82e4
f0103a56:	c6 05 e5 82 2a f0 8e 	movb   $0x8e,0xf02a82e5
f0103a5d:	c1 e8 10             	shr    $0x10,%eax
f0103a60:	66 a3 e6 82 2a f0    	mov    %ax,0xf02a82e6
        SETGATE(idt[13], 0, GD_KT, i13, 0);
f0103a66:	b8 58 44 10 f0       	mov    $0xf0104458,%eax
f0103a6b:	66 a3 e8 82 2a f0    	mov    %ax,0xf02a82e8
f0103a71:	66 c7 05 ea 82 2a f0 	movw   $0x8,0xf02a82ea
f0103a78:	08 00 
f0103a7a:	c6 05 ec 82 2a f0 00 	movb   $0x0,0xf02a82ec
f0103a81:	c6 05 ed 82 2a f0 8e 	movb   $0x8e,0xf02a82ed
f0103a88:	c1 e8 10             	shr    $0x10,%eax
f0103a8b:	66 a3 ee 82 2a f0    	mov    %ax,0xf02a82ee
        SETGATE(idt[14], 0, GD_KT, i14, 0);
f0103a91:	b8 60 44 10 f0       	mov    $0xf0104460,%eax
f0103a96:	66 a3 f0 82 2a f0    	mov    %ax,0xf02a82f0
f0103a9c:	66 c7 05 f2 82 2a f0 	movw   $0x8,0xf02a82f2
f0103aa3:	08 00 
f0103aa5:	c6 05 f4 82 2a f0 00 	movb   $0x0,0xf02a82f4
f0103aac:	c6 05 f5 82 2a f0 8e 	movb   $0x8e,0xf02a82f5
f0103ab3:	c1 e8 10             	shr    $0x10,%eax
f0103ab6:	66 a3 f6 82 2a f0    	mov    %ax,0xf02a82f6
        SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103abc:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103ac1:	66 a3 00 83 2a f0    	mov    %ax,0xf02a8300
f0103ac7:	66 c7 05 02 83 2a f0 	movw   $0x8,0xf02a8302
f0103ace:	08 00 
f0103ad0:	c6 05 04 83 2a f0 00 	movb   $0x0,0xf02a8304
f0103ad7:	c6 05 05 83 2a f0 8e 	movb   $0x8e,0xf02a8305
f0103ade:	c1 e8 10             	shr    $0x10,%eax
f0103ae1:	66 a3 06 83 2a f0    	mov    %ax,0xf02a8306
        SETGATE(idt[17], 0, GD_KT, i17, 0);
f0103ae7:	b8 74 44 10 f0       	mov    $0xf0104474,%eax
f0103aec:	66 a3 08 83 2a f0    	mov    %ax,0xf02a8308
f0103af2:	66 c7 05 0a 83 2a f0 	movw   $0x8,0xf02a830a
f0103af9:	08 00 
f0103afb:	c6 05 0c 83 2a f0 00 	movb   $0x0,0xf02a830c
f0103b02:	c6 05 0d 83 2a f0 8e 	movb   $0x8e,0xf02a830d
f0103b09:	c1 e8 10             	shr    $0x10,%eax
f0103b0c:	66 a3 0e 83 2a f0    	mov    %ax,0xf02a830e
        SETGATE(idt[18], 0, GD_KT, i18, 0);
f0103b12:	b8 78 44 10 f0       	mov    $0xf0104478,%eax
f0103b17:	66 a3 10 83 2a f0    	mov    %ax,0xf02a8310
f0103b1d:	66 c7 05 12 83 2a f0 	movw   $0x8,0xf02a8312
f0103b24:	08 00 
f0103b26:	c6 05 14 83 2a f0 00 	movb   $0x0,0xf02a8314
f0103b2d:	c6 05 15 83 2a f0 8e 	movb   $0x8e,0xf02a8315
f0103b34:	c1 e8 10             	shr    $0x10,%eax
f0103b37:	66 a3 16 83 2a f0    	mov    %ax,0xf02a8316
        SETGATE(idt[19], 0, GD_KT, i19, 0);
f0103b3d:	b8 7e 44 10 f0       	mov    $0xf010447e,%eax
f0103b42:	66 a3 18 83 2a f0    	mov    %ax,0xf02a8318
f0103b48:	66 c7 05 1a 83 2a f0 	movw   $0x8,0xf02a831a
f0103b4f:	08 00 
f0103b51:	c6 05 1c 83 2a f0 00 	movb   $0x0,0xf02a831c
f0103b58:	c6 05 1d 83 2a f0 8e 	movb   $0x8e,0xf02a831d
f0103b5f:	c1 e8 10             	shr    $0x10,%eax
f0103b62:	66 a3 1e 83 2a f0    	mov    %ax,0xf02a831e
       
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq0, 0);
f0103b68:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103b6d:	66 a3 80 83 2a f0    	mov    %ax,0xf02a8380
f0103b73:	66 c7 05 82 83 2a f0 	movw   $0x8,0xf02a8382
f0103b7a:	08 00 
f0103b7c:	c6 05 84 83 2a f0 00 	movb   $0x0,0xf02a8384
f0103b83:	c6 05 85 83 2a f0 8e 	movb   $0x8e,0xf02a8385
f0103b8a:	c1 e8 10             	shr    $0x10,%eax
f0103b8d:	66 a3 86 83 2a f0    	mov    %ax,0xf02a8386
        SETGATE(idt[33], 0, GD_KT, irq1, 0);
f0103b93:	b8 8a 44 10 f0       	mov    $0xf010448a,%eax
f0103b98:	66 a3 88 83 2a f0    	mov    %ax,0xf02a8388
f0103b9e:	66 c7 05 8a 83 2a f0 	movw   $0x8,0xf02a838a
f0103ba5:	08 00 
f0103ba7:	c6 05 8c 83 2a f0 00 	movb   $0x0,0xf02a838c
f0103bae:	c6 05 8d 83 2a f0 8e 	movb   $0x8e,0xf02a838d
f0103bb5:	c1 e8 10             	shr    $0x10,%eax
f0103bb8:	66 a3 8e 83 2a f0    	mov    %ax,0xf02a838e
        SETGATE(idt[34], 0, GD_KT, irq2, 0);
f0103bbe:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103bc3:	66 a3 90 83 2a f0    	mov    %ax,0xf02a8390
f0103bc9:	66 c7 05 92 83 2a f0 	movw   $0x8,0xf02a8392
f0103bd0:	08 00 
f0103bd2:	c6 05 94 83 2a f0 00 	movb   $0x0,0xf02a8394
f0103bd9:	c6 05 95 83 2a f0 8e 	movb   $0x8e,0xf02a8395
f0103be0:	c1 e8 10             	shr    $0x10,%eax
f0103be3:	66 a3 96 83 2a f0    	mov    %ax,0xf02a8396
        SETGATE(idt[35], 0, GD_KT, irq3, 0);
f0103be9:	b8 96 44 10 f0       	mov    $0xf0104496,%eax
f0103bee:	66 a3 98 83 2a f0    	mov    %ax,0xf02a8398
f0103bf4:	66 c7 05 9a 83 2a f0 	movw   $0x8,0xf02a839a
f0103bfb:	08 00 
f0103bfd:	c6 05 9c 83 2a f0 00 	movb   $0x0,0xf02a839c
f0103c04:	c6 05 9d 83 2a f0 8e 	movb   $0x8e,0xf02a839d
f0103c0b:	c1 e8 10             	shr    $0x10,%eax
f0103c0e:	66 a3 9e 83 2a f0    	mov    %ax,0xf02a839e
        SETGATE(idt[36], 0, GD_KT, irq4, 0);
f0103c14:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103c19:	66 a3 a0 83 2a f0    	mov    %ax,0xf02a83a0
f0103c1f:	66 c7 05 a2 83 2a f0 	movw   $0x8,0xf02a83a2
f0103c26:	08 00 
f0103c28:	c6 05 a4 83 2a f0 00 	movb   $0x0,0xf02a83a4
f0103c2f:	c6 05 a5 83 2a f0 8e 	movb   $0x8e,0xf02a83a5
f0103c36:	c1 e8 10             	shr    $0x10,%eax
f0103c39:	66 a3 a6 83 2a f0    	mov    %ax,0xf02a83a6
        SETGATE(idt[37], 0, GD_KT, irq5, 0);
f0103c3f:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103c44:	66 a3 a8 83 2a f0    	mov    %ax,0xf02a83a8
f0103c4a:	66 c7 05 aa 83 2a f0 	movw   $0x8,0xf02a83aa
f0103c51:	08 00 
f0103c53:	c6 05 ac 83 2a f0 00 	movb   $0x0,0xf02a83ac
f0103c5a:	c6 05 ad 83 2a f0 8e 	movb   $0x8e,0xf02a83ad
f0103c61:	c1 e8 10             	shr    $0x10,%eax
f0103c64:	66 a3 ae 83 2a f0    	mov    %ax,0xf02a83ae
        SETGATE(idt[38], 0, GD_KT, irq6, 0);
f0103c6a:	b8 a8 44 10 f0       	mov    $0xf01044a8,%eax
f0103c6f:	66 a3 b0 83 2a f0    	mov    %ax,0xf02a83b0
f0103c75:	66 c7 05 b2 83 2a f0 	movw   $0x8,0xf02a83b2
f0103c7c:	08 00 
f0103c7e:	c6 05 b4 83 2a f0 00 	movb   $0x0,0xf02a83b4
f0103c85:	c6 05 b5 83 2a f0 8e 	movb   $0x8e,0xf02a83b5
f0103c8c:	c1 e8 10             	shr    $0x10,%eax
f0103c8f:	66 a3 b6 83 2a f0    	mov    %ax,0xf02a83b6
        SETGATE(idt[39], 0, GD_KT, irq7, 0);
f0103c95:	b8 ae 44 10 f0       	mov    $0xf01044ae,%eax
f0103c9a:	66 a3 b8 83 2a f0    	mov    %ax,0xf02a83b8
f0103ca0:	66 c7 05 ba 83 2a f0 	movw   $0x8,0xf02a83ba
f0103ca7:	08 00 
f0103ca9:	c6 05 bc 83 2a f0 00 	movb   $0x0,0xf02a83bc
f0103cb0:	c6 05 bd 83 2a f0 8e 	movb   $0x8e,0xf02a83bd
f0103cb7:	c1 e8 10             	shr    $0x10,%eax
f0103cba:	66 a3 be 83 2a f0    	mov    %ax,0xf02a83be
        SETGATE(idt[40], 0, GD_KT, irq8, 0);
f0103cc0:	b8 b4 44 10 f0       	mov    $0xf01044b4,%eax
f0103cc5:	66 a3 c0 83 2a f0    	mov    %ax,0xf02a83c0
f0103ccb:	66 c7 05 c2 83 2a f0 	movw   $0x8,0xf02a83c2
f0103cd2:	08 00 
f0103cd4:	c6 05 c4 83 2a f0 00 	movb   $0x0,0xf02a83c4
f0103cdb:	c6 05 c5 83 2a f0 8e 	movb   $0x8e,0xf02a83c5
f0103ce2:	c1 e8 10             	shr    $0x10,%eax
f0103ce5:	66 a3 c6 83 2a f0    	mov    %ax,0xf02a83c6
        SETGATE(idt[41], 0, GD_KT, irq9, 0);
f0103ceb:	b8 ba 44 10 f0       	mov    $0xf01044ba,%eax
f0103cf0:	66 a3 c8 83 2a f0    	mov    %ax,0xf02a83c8
f0103cf6:	66 c7 05 ca 83 2a f0 	movw   $0x8,0xf02a83ca
f0103cfd:	08 00 
f0103cff:	c6 05 cc 83 2a f0 00 	movb   $0x0,0xf02a83cc
f0103d06:	c6 05 cd 83 2a f0 8e 	movb   $0x8e,0xf02a83cd
f0103d0d:	c1 e8 10             	shr    $0x10,%eax
f0103d10:	66 a3 ce 83 2a f0    	mov    %ax,0xf02a83ce
        SETGATE(idt[42], 0, GD_KT, irq10, 0);
f0103d16:	b8 c0 44 10 f0       	mov    $0xf01044c0,%eax
f0103d1b:	66 a3 d0 83 2a f0    	mov    %ax,0xf02a83d0
f0103d21:	66 c7 05 d2 83 2a f0 	movw   $0x8,0xf02a83d2
f0103d28:	08 00 
f0103d2a:	c6 05 d4 83 2a f0 00 	movb   $0x0,0xf02a83d4
f0103d31:	c6 05 d5 83 2a f0 8e 	movb   $0x8e,0xf02a83d5
f0103d38:	c1 e8 10             	shr    $0x10,%eax
f0103d3b:	66 a3 d6 83 2a f0    	mov    %ax,0xf02a83d6
        SETGATE(idt[IRQ_OFFSET + IRQ_NIC], 0, GD_KT, irq11, 0);
f0103d41:	b8 c6 44 10 f0       	mov    $0xf01044c6,%eax
f0103d46:	66 a3 d8 83 2a f0    	mov    %ax,0xf02a83d8
f0103d4c:	66 c7 05 da 83 2a f0 	movw   $0x8,0xf02a83da
f0103d53:	08 00 
f0103d55:	c6 05 dc 83 2a f0 00 	movb   $0x0,0xf02a83dc
f0103d5c:	c6 05 dd 83 2a f0 8e 	movb   $0x8e,0xf02a83dd
f0103d63:	c1 e8 10             	shr    $0x10,%eax
f0103d66:	66 a3 de 83 2a f0    	mov    %ax,0xf02a83de
        SETGATE(idt[44], 0, GD_KT, irq12, 0);
f0103d6c:	b8 cc 44 10 f0       	mov    $0xf01044cc,%eax
f0103d71:	66 a3 e0 83 2a f0    	mov    %ax,0xf02a83e0
f0103d77:	66 c7 05 e2 83 2a f0 	movw   $0x8,0xf02a83e2
f0103d7e:	08 00 
f0103d80:	c6 05 e4 83 2a f0 00 	movb   $0x0,0xf02a83e4
f0103d87:	c6 05 e5 83 2a f0 8e 	movb   $0x8e,0xf02a83e5
f0103d8e:	c1 e8 10             	shr    $0x10,%eax
f0103d91:	66 a3 e6 83 2a f0    	mov    %ax,0xf02a83e6
        SETGATE(idt[45], 0, GD_KT, irq13, 0);
f0103d97:	b8 d2 44 10 f0       	mov    $0xf01044d2,%eax
f0103d9c:	66 a3 e8 83 2a f0    	mov    %ax,0xf02a83e8
f0103da2:	66 c7 05 ea 83 2a f0 	movw   $0x8,0xf02a83ea
f0103da9:	08 00 
f0103dab:	c6 05 ec 83 2a f0 00 	movb   $0x0,0xf02a83ec
f0103db2:	c6 05 ed 83 2a f0 8e 	movb   $0x8e,0xf02a83ed
f0103db9:	c1 e8 10             	shr    $0x10,%eax
f0103dbc:	66 a3 ee 83 2a f0    	mov    %ax,0xf02a83ee
        SETGATE(idt[46], 0, GD_KT, irq14, 0);
f0103dc2:	b8 d8 44 10 f0       	mov    $0xf01044d8,%eax
f0103dc7:	66 a3 f0 83 2a f0    	mov    %ax,0xf02a83f0
f0103dcd:	66 c7 05 f2 83 2a f0 	movw   $0x8,0xf02a83f2
f0103dd4:	08 00 
f0103dd6:	c6 05 f4 83 2a f0 00 	movb   $0x0,0xf02a83f4
f0103ddd:	c6 05 f5 83 2a f0 8e 	movb   $0x8e,0xf02a83f5
f0103de4:	c1 e8 10             	shr    $0x10,%eax
f0103de7:	66 a3 f6 83 2a f0    	mov    %ax,0xf02a83f6
        SETGATE(idt[47], 0, GD_KT, irq15, 0);
f0103ded:	b8 de 44 10 f0       	mov    $0xf01044de,%eax
f0103df2:	66 a3 f8 83 2a f0    	mov    %ax,0xf02a83f8
f0103df8:	66 c7 05 fa 83 2a f0 	movw   $0x8,0xf02a83fa
f0103dff:	08 00 
f0103e01:	c6 05 fc 83 2a f0 00 	movb   $0x0,0xf02a83fc
f0103e08:	c6 05 fd 83 2a f0 8e 	movb   $0x8e,0xf02a83fd
f0103e0f:	c1 e8 10             	shr    $0x10,%eax
f0103e12:	66 a3 fe 83 2a f0    	mov    %ax,0xf02a83fe
        SETGATE(idt[48], 0, GD_KT, i20, 3);
f0103e18:	b8 e4 44 10 f0       	mov    $0xf01044e4,%eax
f0103e1d:	66 a3 00 84 2a f0    	mov    %ax,0xf02a8400
f0103e23:	66 c7 05 02 84 2a f0 	movw   $0x8,0xf02a8402
f0103e2a:	08 00 
f0103e2c:	c6 05 04 84 2a f0 00 	movb   $0x0,0xf02a8404
f0103e33:	c6 05 05 84 2a f0 ee 	movb   $0xee,0xf02a8405
f0103e3a:	c1 e8 10             	shr    $0x10,%eax
f0103e3d:	66 a3 06 84 2a f0    	mov    %ax,0xf02a8406
	// Per-CPU setup 
	trap_init_percpu();
f0103e43:	e8 29 f9 ff ff       	call   f0103771 <trap_init_percpu>
}
f0103e48:	c9                   	leave  
f0103e49:	c3                   	ret    

f0103e4a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e4a:	55                   	push   %ebp
f0103e4b:	89 e5                	mov    %esp,%ebp
f0103e4d:	53                   	push   %ebx
f0103e4e:	83 ec 0c             	sub    $0xc,%esp
f0103e51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e54:	ff 33                	pushl  (%ebx)
f0103e56:	68 bb 81 10 f0       	push   $0xf01081bb
f0103e5b:	e8 fd f8 ff ff       	call   f010375d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e60:	83 c4 08             	add    $0x8,%esp
f0103e63:	ff 73 04             	pushl  0x4(%ebx)
f0103e66:	68 ca 81 10 f0       	push   $0xf01081ca
f0103e6b:	e8 ed f8 ff ff       	call   f010375d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e70:	83 c4 08             	add    $0x8,%esp
f0103e73:	ff 73 08             	pushl  0x8(%ebx)
f0103e76:	68 d9 81 10 f0       	push   $0xf01081d9
f0103e7b:	e8 dd f8 ff ff       	call   f010375d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e80:	83 c4 08             	add    $0x8,%esp
f0103e83:	ff 73 0c             	pushl  0xc(%ebx)
f0103e86:	68 e8 81 10 f0       	push   $0xf01081e8
f0103e8b:	e8 cd f8 ff ff       	call   f010375d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e90:	83 c4 08             	add    $0x8,%esp
f0103e93:	ff 73 10             	pushl  0x10(%ebx)
f0103e96:	68 f7 81 10 f0       	push   $0xf01081f7
f0103e9b:	e8 bd f8 ff ff       	call   f010375d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ea0:	83 c4 08             	add    $0x8,%esp
f0103ea3:	ff 73 14             	pushl  0x14(%ebx)
f0103ea6:	68 06 82 10 f0       	push   $0xf0108206
f0103eab:	e8 ad f8 ff ff       	call   f010375d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	ff 73 18             	pushl  0x18(%ebx)
f0103eb6:	68 15 82 10 f0       	push   $0xf0108215
f0103ebb:	e8 9d f8 ff ff       	call   f010375d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ec0:	83 c4 08             	add    $0x8,%esp
f0103ec3:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ec6:	68 24 82 10 f0       	push   $0xf0108224
f0103ecb:	e8 8d f8 ff ff       	call   f010375d <cprintf>
f0103ed0:	83 c4 10             	add    $0x10,%esp
}
f0103ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ed6:	c9                   	leave  
f0103ed7:	c3                   	ret    

f0103ed8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ed8:	55                   	push   %ebp
f0103ed9:	89 e5                	mov    %esp,%ebp
f0103edb:	56                   	push   %esi
f0103edc:	53                   	push   %ebx
f0103edd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103ee0:	e8 36 20 00 00       	call   f0105f1b <cpunum>
f0103ee5:	83 ec 04             	sub    $0x4,%esp
f0103ee8:	50                   	push   %eax
f0103ee9:	53                   	push   %ebx
f0103eea:	68 88 82 10 f0       	push   $0xf0108288
f0103eef:	e8 69 f8 ff ff       	call   f010375d <cprintf>
	print_regs(&tf->tf_regs);
f0103ef4:	89 1c 24             	mov    %ebx,(%esp)
f0103ef7:	e8 4e ff ff ff       	call   f0103e4a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103efc:	83 c4 08             	add    $0x8,%esp
f0103eff:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f03:	50                   	push   %eax
f0103f04:	68 a6 82 10 f0       	push   $0xf01082a6
f0103f09:	e8 4f f8 ff ff       	call   f010375d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f0e:	83 c4 08             	add    $0x8,%esp
f0103f11:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f15:	50                   	push   %eax
f0103f16:	68 b9 82 10 f0       	push   $0xf01082b9
f0103f1b:	e8 3d f8 ff ff       	call   f010375d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f20:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103f23:	83 c4 10             	add    $0x10,%esp
f0103f26:	83 f8 13             	cmp    $0x13,%eax
f0103f29:	77 09                	ja     f0103f34 <print_trapframe+0x5c>
		return excnames[trapno];
f0103f2b:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f0103f32:	eb 1f                	jmp    f0103f53 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103f34:	83 f8 30             	cmp    $0x30,%eax
f0103f37:	74 15                	je     f0103f4e <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f39:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103f3c:	83 fa 10             	cmp    $0x10,%edx
f0103f3f:	b9 52 82 10 f0       	mov    $0xf0108252,%ecx
f0103f44:	ba 3f 82 10 f0       	mov    $0xf010823f,%edx
f0103f49:	0f 43 d1             	cmovae %ecx,%edx
f0103f4c:	eb 05                	jmp    f0103f53 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f4e:	ba 33 82 10 f0       	mov    $0xf0108233,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f53:	83 ec 04             	sub    $0x4,%esp
f0103f56:	52                   	push   %edx
f0103f57:	50                   	push   %eax
f0103f58:	68 cc 82 10 f0       	push   $0xf01082cc
f0103f5d:	e8 fb f7 ff ff       	call   f010375d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f62:	83 c4 10             	add    $0x10,%esp
f0103f65:	3b 1d 80 8a 2a f0    	cmp    0xf02a8a80,%ebx
f0103f6b:	75 1a                	jne    f0103f87 <print_trapframe+0xaf>
f0103f6d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f71:	75 14                	jne    f0103f87 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f73:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f76:	83 ec 08             	sub    $0x8,%esp
f0103f79:	50                   	push   %eax
f0103f7a:	68 de 82 10 f0       	push   $0xf01082de
f0103f7f:	e8 d9 f7 ff ff       	call   f010375d <cprintf>
f0103f84:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f87:	83 ec 08             	sub    $0x8,%esp
f0103f8a:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f8d:	68 ed 82 10 f0       	push   $0xf01082ed
f0103f92:	e8 c6 f7 ff ff       	call   f010375d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f97:	83 c4 10             	add    $0x10,%esp
f0103f9a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f9e:	75 49                	jne    f0103fe9 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103fa0:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103fa3:	89 c2                	mov    %eax,%edx
f0103fa5:	83 e2 01             	and    $0x1,%edx
f0103fa8:	ba 6c 82 10 f0       	mov    $0xf010826c,%edx
f0103fad:	b9 61 82 10 f0       	mov    $0xf0108261,%ecx
f0103fb2:	0f 44 ca             	cmove  %edx,%ecx
f0103fb5:	89 c2                	mov    %eax,%edx
f0103fb7:	83 e2 02             	and    $0x2,%edx
f0103fba:	ba 7e 82 10 f0       	mov    $0xf010827e,%edx
f0103fbf:	be 78 82 10 f0       	mov    $0xf0108278,%esi
f0103fc4:	0f 45 d6             	cmovne %esi,%edx
f0103fc7:	83 e0 04             	and    $0x4,%eax
f0103fca:	be cb 83 10 f0       	mov    $0xf01083cb,%esi
f0103fcf:	b8 83 82 10 f0       	mov    $0xf0108283,%eax
f0103fd4:	0f 44 c6             	cmove  %esi,%eax
f0103fd7:	51                   	push   %ecx
f0103fd8:	52                   	push   %edx
f0103fd9:	50                   	push   %eax
f0103fda:	68 fb 82 10 f0       	push   $0xf01082fb
f0103fdf:	e8 79 f7 ff ff       	call   f010375d <cprintf>
f0103fe4:	83 c4 10             	add    $0x10,%esp
f0103fe7:	eb 10                	jmp    f0103ff9 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fe9:	83 ec 0c             	sub    $0xc,%esp
f0103fec:	68 f3 77 10 f0       	push   $0xf01077f3
f0103ff1:	e8 67 f7 ff ff       	call   f010375d <cprintf>
f0103ff6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ff9:	83 ec 08             	sub    $0x8,%esp
f0103ffc:	ff 73 30             	pushl  0x30(%ebx)
f0103fff:	68 0a 83 10 f0       	push   $0xf010830a
f0104004:	e8 54 f7 ff ff       	call   f010375d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104009:	83 c4 08             	add    $0x8,%esp
f010400c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104010:	50                   	push   %eax
f0104011:	68 19 83 10 f0       	push   $0xf0108319
f0104016:	e8 42 f7 ff ff       	call   f010375d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010401b:	83 c4 08             	add    $0x8,%esp
f010401e:	ff 73 38             	pushl  0x38(%ebx)
f0104021:	68 2c 83 10 f0       	push   $0xf010832c
f0104026:	e8 32 f7 ff ff       	call   f010375d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010402b:	83 c4 10             	add    $0x10,%esp
f010402e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104032:	74 25                	je     f0104059 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104034:	83 ec 08             	sub    $0x8,%esp
f0104037:	ff 73 3c             	pushl  0x3c(%ebx)
f010403a:	68 3b 83 10 f0       	push   $0xf010833b
f010403f:	e8 19 f7 ff ff       	call   f010375d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104044:	83 c4 08             	add    $0x8,%esp
f0104047:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010404b:	50                   	push   %eax
f010404c:	68 4a 83 10 f0       	push   $0xf010834a
f0104051:	e8 07 f7 ff ff       	call   f010375d <cprintf>
f0104056:	83 c4 10             	add    $0x10,%esp
	}
}
f0104059:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010405c:	5b                   	pop    %ebx
f010405d:	5e                   	pop    %esi
f010405e:	5d                   	pop    %ebp
f010405f:	c3                   	ret    

f0104060 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104060:	55                   	push   %ebp
f0104061:	89 e5                	mov    %esp,%ebp
f0104063:	57                   	push   %edi
f0104064:	56                   	push   %esi
f0104065:	53                   	push   %ebx
f0104066:	83 ec 0c             	sub    $0xc,%esp
f0104069:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010406c:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if ((tf->tf_cs & 3) == 0) {
f010406f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104073:	75 17                	jne    f010408c <page_fault_handler+0x2c>
                panic("Kernel page fault!");
f0104075:	83 ec 04             	sub    $0x4,%esp
f0104078:	68 5d 83 10 f0       	push   $0xf010835d
f010407d:	68 93 01 00 00       	push   $0x193
f0104082:	68 70 83 10 f0       	push   $0xf0108370
f0104087:	e8 b4 bf ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        if(curenv->env_pgfault_upcall) {
f010408c:	e8 8a 1e 00 00       	call   f0105f1b <cpunum>
f0104091:	6b c0 74             	imul   $0x74,%eax,%eax
f0104094:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010409a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010409e:	0f 84 8b 00 00 00    	je     f010412f <page_fault_handler+0xcf>
                struct UTrapframe *utf;
                if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&  tf->tf_esp <= UXSTACKTOP-1)  
f01040a4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040a7:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                        utf = (struct UTrapframe *) ((void *)tf->tf_esp - sizeof(struct UTrapframe) -4);
f01040ad:	83 e8 38             	sub    $0x38,%eax
f01040b0:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01040b6:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01040bb:	0f 46 d0             	cmovbe %eax,%edx
f01040be:	89 d7                	mov    %edx,%edi
                else
                        utf = (struct UTrapframe *) ((void *)UXSTACKTOP - sizeof(struct UTrapframe));
                user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f01040c0:	e8 56 1e 00 00       	call   f0105f1b <cpunum>
f01040c5:	6a 03                	push   $0x3
f01040c7:	6a 34                	push   $0x34
f01040c9:	57                   	push   %edi
f01040ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cd:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f01040d3:	e8 8a ed ff ff       	call   f0102e62 <user_mem_assert>
                utf->utf_fault_va = fault_va;
f01040d8:	89 fa                	mov    %edi,%edx
f01040da:	89 37                	mov    %esi,(%edi)
                utf->utf_err = tf->tf_err;
f01040dc:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040df:	89 47 04             	mov    %eax,0x4(%edi)
                utf->utf_regs = tf->tf_regs;
f01040e2:	8d 7f 08             	lea    0x8(%edi),%edi
f01040e5:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040ea:	89 de                	mov    %ebx,%esi
f01040ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
                utf->utf_eip = tf->tf_eip;
f01040ee:	8b 43 30             	mov    0x30(%ebx),%eax
f01040f1:	89 42 28             	mov    %eax,0x28(%edx)
                utf->utf_eflags = tf->tf_eflags;
f01040f4:	8b 43 38             	mov    0x38(%ebx),%eax
f01040f7:	89 d7                	mov    %edx,%edi
f01040f9:	89 42 2c             	mov    %eax,0x2c(%edx)
                utf->utf_esp = tf->tf_esp;
f01040fc:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040ff:	89 42 30             	mov    %eax,0x30(%edx)
                tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f0104102:	e8 14 1e 00 00       	call   f0105f1b <cpunum>
f0104107:	6b c0 74             	imul   $0x74,%eax,%eax
f010410a:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104110:	8b 40 64             	mov    0x64(%eax),%eax
f0104113:	89 43 30             	mov    %eax,0x30(%ebx)
                tf->tf_esp = (uintptr_t)utf;
f0104116:	89 7b 3c             	mov    %edi,0x3c(%ebx)
                env_run(curenv);
f0104119:	e8 fd 1d 00 00       	call   f0105f1b <cpunum>
f010411e:	83 c4 04             	add    $0x4,%esp
f0104121:	6b c0 74             	imul   $0x74,%eax,%eax
f0104124:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f010412a:	e8 d3 f3 ff ff       	call   f0103502 <env_run>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
f010412f:	83 ec 0c             	sub    $0xc,%esp
f0104132:	68 18 85 10 f0       	push   $0xf0108518
f0104137:	e8 21 f6 ff ff       	call   f010375d <cprintf>
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010413c:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010413f:	e8 d7 1d 00 00       	call   f0105f1b <cpunum>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104144:	57                   	push   %edi
f0104145:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104146:	6b c0 74             	imul   $0x74,%eax,%eax
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104149:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010414f:	ff 70 48             	pushl  0x48(%eax)
f0104152:	68 3c 85 10 f0       	push   $0xf010853c
f0104157:	e8 01 f6 ff ff       	call   f010375d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010415c:	83 c4 14             	add    $0x14,%esp
f010415f:	53                   	push   %ebx
f0104160:	e8 73 fd ff ff       	call   f0103ed8 <print_trapframe>
	env_destroy(curenv);
f0104165:	e8 b1 1d 00 00       	call   f0105f1b <cpunum>
f010416a:	83 c4 04             	add    $0x4,%esp
f010416d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104170:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104176:	e8 e8 f2 ff ff       	call   f0103463 <env_destroy>
f010417b:	83 c4 10             	add    $0x10,%esp
}
f010417e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104181:	5b                   	pop    %ebx
f0104182:	5e                   	pop    %esi
f0104183:	5f                   	pop    %edi
f0104184:	5d                   	pop    %ebp
f0104185:	c3                   	ret    

f0104186 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104186:	55                   	push   %ebp
f0104187:	89 e5                	mov    %esp,%ebp
f0104189:	57                   	push   %edi
f010418a:	56                   	push   %esi
f010418b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010418e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010418f:	83 3d d0 8e 2a f0 00 	cmpl   $0x0,0xf02a8ed0
f0104196:	74 01                	je     f0104199 <trap+0x13>
		asm volatile("hlt");
f0104198:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104199:	e8 7d 1d 00 00       	call   f0105f1b <cpunum>
f010419e:	6b d0 74             	imul   $0x74,%eax,%edx
f01041a1:	81 c2 40 90 2a f0    	add    $0xf02a9040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01041a7:	b8 01 00 00 00       	mov    $0x1,%eax
f01041ac:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01041b0:	83 f8 02             	cmp    $0x2,%eax
f01041b3:	75 10                	jne    f01041c5 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01041b5:	83 ec 0c             	sub    $0xc,%esp
f01041b8:	68 c0 43 12 f0       	push   $0xf01243c0
f01041bd:	e8 c4 1f 00 00       	call   f0106186 <spin_lock>
f01041c2:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01041c5:	9c                   	pushf  
f01041c6:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01041c7:	f6 c4 02             	test   $0x2,%ah
f01041ca:	74 19                	je     f01041e5 <trap+0x5f>
f01041cc:	68 7c 83 10 f0       	push   $0xf010837c
f01041d1:	68 04 75 10 f0       	push   $0xf0107504
f01041d6:	68 5d 01 00 00       	push   $0x15d
f01041db:	68 70 83 10 f0       	push   $0xf0108370
f01041e0:	e8 5b be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041e5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041e9:	83 e0 03             	and    $0x3,%eax
f01041ec:	66 83 f8 03          	cmp    $0x3,%ax
f01041f0:	0f 85 a0 00 00 00    	jne    f0104296 <trap+0x110>
f01041f6:	83 ec 0c             	sub    $0xc,%esp
f01041f9:	68 c0 43 12 f0       	push   $0xf01243c0
f01041fe:	e8 83 1f 00 00       	call   f0106186 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f0104203:	e8 13 1d 00 00       	call   f0105f1b <cpunum>
f0104208:	6b c0 74             	imul   $0x74,%eax,%eax
f010420b:	83 c4 10             	add    $0x10,%esp
f010420e:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f0104215:	75 19                	jne    f0104230 <trap+0xaa>
f0104217:	68 95 83 10 f0       	push   $0xf0108395
f010421c:	68 04 75 10 f0       	push   $0xf0107504
f0104221:	68 65 01 00 00       	push   $0x165
f0104226:	68 70 83 10 f0       	push   $0xf0108370
f010422b:	e8 10 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104230:	e8 e6 1c 00 00       	call   f0105f1b <cpunum>
f0104235:	6b c0 74             	imul   $0x74,%eax,%eax
f0104238:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010423e:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104242:	75 2d                	jne    f0104271 <trap+0xeb>
			env_free(curenv);
f0104244:	e8 d2 1c 00 00       	call   f0105f1b <cpunum>
f0104249:	83 ec 0c             	sub    $0xc,%esp
f010424c:	6b c0 74             	imul   $0x74,%eax,%eax
f010424f:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104255:	e8 63 f0 ff ff       	call   f01032bd <env_free>
			curenv = NULL;
f010425a:	e8 bc 1c 00 00       	call   f0105f1b <cpunum>
f010425f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104262:	c7 80 48 90 2a f0 00 	movl   $0x0,-0xfd56fb8(%eax)
f0104269:	00 00 00 
			sched_yield();
f010426c:	e8 5f 03 00 00       	call   f01045d0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104271:	e8 a5 1c 00 00       	call   f0105f1b <cpunum>
f0104276:	6b c0 74             	imul   $0x74,%eax,%eax
f0104279:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010427f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104284:	89 c7                	mov    %eax,%edi
f0104286:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104288:	e8 8e 1c 00 00       	call   f0105f1b <cpunum>
f010428d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104290:	8b b0 48 90 2a f0    	mov    -0xfd56fb8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104296:	89 35 80 8a 2a f0    	mov    %esi,0xf02a8a80
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
        
        if(tf->tf_trapno == T_PGFLT ) {
f010429c:	8b 46 28             	mov    0x28(%esi),%eax
f010429f:	83 f8 0e             	cmp    $0xe,%eax
f01042a2:	75 11                	jne    f01042b5 <trap+0x12f>
                page_fault_handler(tf);
f01042a4:	83 ec 0c             	sub    $0xc,%esp
f01042a7:	56                   	push   %esi
f01042a8:	e8 b3 fd ff ff       	call   f0104060 <page_fault_handler>
f01042ad:	83 c4 10             	add    $0x10,%esp
f01042b0:	e9 e8 00 00 00       	jmp    f010439d <trap+0x217>
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
f01042b5:	83 f8 03             	cmp    $0x3,%eax
f01042b8:	75 11                	jne    f01042cb <trap+0x145>
                monitor(tf);
f01042ba:	83 ec 0c             	sub    $0xc,%esp
f01042bd:	56                   	push   %esi
f01042be:	e8 fd c6 ff ff       	call   f01009c0 <monitor>
f01042c3:	83 c4 10             	add    $0x10,%esp
f01042c6:	e9 d2 00 00 00       	jmp    f010439d <trap+0x217>
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
f01042cb:	83 f8 30             	cmp    $0x30,%eax
f01042ce:	75 24                	jne    f01042f4 <trap+0x16e>
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01042d0:	83 ec 08             	sub    $0x8,%esp
f01042d3:	ff 76 04             	pushl  0x4(%esi)
f01042d6:	ff 36                	pushl  (%esi)
f01042d8:	ff 76 10             	pushl  0x10(%esi)
f01042db:	ff 76 18             	pushl  0x18(%esi)
f01042de:	ff 76 14             	pushl  0x14(%esi)
f01042e1:	ff 76 1c             	pushl  0x1c(%esi)
f01042e4:	e8 9b 03 00 00       	call   f0104684 <syscall>
f01042e9:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042ec:	83 c4 20             	add    $0x20,%esp
f01042ef:	e9 a9 00 00 00       	jmp    f010439d <trap+0x217>
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042f4:	83 f8 27             	cmp    $0x27,%eax
f01042f7:	75 22                	jne    f010431b <trap+0x195>
		cprintf("Spurious interrupt on irq 7\n");
f01042f9:	83 ec 0c             	sub    $0xc,%esp
f01042fc:	68 9c 83 10 f0       	push   $0xf010839c
f0104301:	e8 57 f4 ff ff       	call   f010375d <cprintf>
		print_trapframe(tf);
f0104306:	89 34 24             	mov    %esi,(%esp)
f0104309:	e8 ca fb ff ff       	call   f0103ed8 <print_trapframe>
                lapic_eoi();
f010430e:	e8 53 1d 00 00       	call   f0106066 <lapic_eoi>
f0104313:	83 c4 10             	add    $0x10,%esp
f0104316:	e9 82 00 00 00       	jmp    f010439d <trap+0x217>
	// LAB 4: Your code here.
        // Add time tick increment to clock interrupts.
	// Be careful! In multiprocessors, clock interrupts are
	// triggered on every CPU.
	// LAB 6: Your code here.
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {	
f010431b:	83 f8 20             	cmp    $0x20,%eax
f010431e:	75 18                	jne    f0104338 <trap+0x1b2>
                if(cpunum() == 0) 
f0104320:	e8 f6 1b 00 00       	call   f0105f1b <cpunum>
f0104325:	85 c0                	test   %eax,%eax
f0104327:	75 05                	jne    f010432e <trap+0x1a8>
                        time_tick();
f0104329:	e8 c8 28 00 00       	call   f0106bf6 <time_tick>
                lapic_eoi();
f010432e:	e8 33 1d 00 00       	call   f0106066 <lapic_eoi>
                sched_yield();
f0104333:	e8 98 02 00 00       	call   f01045d0 <sched_yield>
	// LAB 6: Your code here.


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104338:	83 f8 21             	cmp    $0x21,%eax
f010433b:	75 0c                	jne    f0104349 <trap+0x1c3>
                lapic_eoi();
f010433d:	e8 24 1d 00 00       	call   f0106066 <lapic_eoi>
		kbd_intr();
f0104342:	e8 b9 c2 ff ff       	call   f0100600 <kbd_intr>
f0104347:	eb 54                	jmp    f010439d <trap+0x217>
		return;
	}
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104349:	83 f8 24             	cmp    $0x24,%eax
f010434c:	75 0c                	jne    f010435a <trap+0x1d4>
                lapic_eoi();
f010434e:	e8 13 1d 00 00       	call   f0106066 <lapic_eoi>
		serial_intr();
f0104353:	e8 8c c2 ff ff       	call   f01005e4 <serial_intr>
f0104358:	eb 43                	jmp    f010439d <trap+0x217>
                //I am net card
		return;
	}*/
	// Unexpected trap: The user process or the kernel has a bug.
 
	print_trapframe(tf);
f010435a:	83 ec 0c             	sub    $0xc,%esp
f010435d:	56                   	push   %esi
f010435e:	e8 75 fb ff ff       	call   f0103ed8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104363:	83 c4 10             	add    $0x10,%esp
f0104366:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010436b:	75 17                	jne    f0104384 <trap+0x1fe>
		panic("unhandled trap in kernel");
f010436d:	83 ec 04             	sub    $0x4,%esp
f0104370:	68 b9 83 10 f0       	push   $0xf01083b9
f0104375:	68 44 01 00 00       	push   $0x144
f010437a:	68 70 83 10 f0       	push   $0xf0108370
f010437f:	e8 bc bc ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104384:	e8 92 1b 00 00       	call   f0105f1b <cpunum>
f0104389:	83 ec 0c             	sub    $0xc,%esp
f010438c:	6b c0 74             	imul   $0x74,%eax,%eax
f010438f:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104395:	e8 c9 f0 ff ff       	call   f0103463 <env_destroy>
f010439a:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010439d:	e8 79 1b 00 00       	call   f0105f1b <cpunum>
f01043a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01043a5:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f01043ac:	74 2a                	je     f01043d8 <trap+0x252>
f01043ae:	e8 68 1b 00 00       	call   f0105f1b <cpunum>
f01043b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b6:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f01043bc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01043c0:	75 16                	jne    f01043d8 <trap+0x252>
		env_run(curenv);
f01043c2:	e8 54 1b 00 00       	call   f0105f1b <cpunum>
f01043c7:	83 ec 0c             	sub    $0xc,%esp
f01043ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cd:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f01043d3:	e8 2a f1 ff ff       	call   f0103502 <env_run>
	else
		sched_yield();
f01043d8:	e8 f3 01 00 00       	call   f01045d0 <sched_yield>
f01043dd:	90                   	nop

f01043de <i0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(i0, T_DIVIDE)
f01043de:	6a 00                	push   $0x0
f01043e0:	6a 00                	push   $0x0
f01043e2:	e9 03 01 00 00       	jmp    f01044ea <_alltraps>
f01043e7:	90                   	nop

f01043e8 <i1>:
TRAPHANDLER_NOEC(i1, T_DEBUG)
f01043e8:	6a 00                	push   $0x0
f01043ea:	6a 01                	push   $0x1
f01043ec:	e9 f9 00 00 00       	jmp    f01044ea <_alltraps>
f01043f1:	90                   	nop

f01043f2 <i2>:
TRAPHANDLER_NOEC(i2, T_NMI)
f01043f2:	6a 00                	push   $0x0
f01043f4:	6a 02                	push   $0x2
f01043f6:	e9 ef 00 00 00       	jmp    f01044ea <_alltraps>
f01043fb:	90                   	nop

f01043fc <i3>:
TRAPHANDLER_NOEC(i3, T_BRKPT)
f01043fc:	6a 00                	push   $0x0
f01043fe:	6a 03                	push   $0x3
f0104400:	e9 e5 00 00 00       	jmp    f01044ea <_alltraps>
f0104405:	90                   	nop

f0104406 <i4>:
TRAPHANDLER_NOEC(i4, T_OFLOW)
f0104406:	6a 00                	push   $0x0
f0104408:	6a 04                	push   $0x4
f010440a:	e9 db 00 00 00       	jmp    f01044ea <_alltraps>
f010440f:	90                   	nop

f0104410 <i5>:
TRAPHANDLER_NOEC(i5, T_BOUND)
f0104410:	6a 00                	push   $0x0
f0104412:	6a 05                	push   $0x5
f0104414:	e9 d1 00 00 00       	jmp    f01044ea <_alltraps>
f0104419:	90                   	nop

f010441a <i6>:
TRAPHANDLER_NOEC(i6, T_ILLOP)
f010441a:	6a 00                	push   $0x0
f010441c:	6a 06                	push   $0x6
f010441e:	e9 c7 00 00 00       	jmp    f01044ea <_alltraps>
f0104423:	90                   	nop

f0104424 <i7>:
TRAPHANDLER_NOEC(i7, T_DEVICE)
f0104424:	6a 00                	push   $0x0
f0104426:	6a 07                	push   $0x7
f0104428:	e9 bd 00 00 00       	jmp    f01044ea <_alltraps>
f010442d:	90                   	nop

f010442e <i8>:
TRAPHANDLER(i8, T_DBLFLT)
f010442e:	6a 08                	push   $0x8
f0104430:	e9 b5 00 00 00       	jmp    f01044ea <_alltraps>
f0104435:	90                   	nop

f0104436 <i9>:
TRAPHANDLER_NOEC(i9, 9)
f0104436:	6a 00                	push   $0x0
f0104438:	6a 09                	push   $0x9
f010443a:	e9 ab 00 00 00       	jmp    f01044ea <_alltraps>
f010443f:	90                   	nop

f0104440 <i10>:
TRAPHANDLER(i10, T_TSS)
f0104440:	6a 0a                	push   $0xa
f0104442:	e9 a3 00 00 00       	jmp    f01044ea <_alltraps>
f0104447:	90                   	nop

f0104448 <i11>:
TRAPHANDLER(i11, T_SEGNP)
f0104448:	6a 0b                	push   $0xb
f010444a:	e9 9b 00 00 00       	jmp    f01044ea <_alltraps>
f010444f:	90                   	nop

f0104450 <i12>:
TRAPHANDLER(i12, T_STACK)
f0104450:	6a 0c                	push   $0xc
f0104452:	e9 93 00 00 00       	jmp    f01044ea <_alltraps>
f0104457:	90                   	nop

f0104458 <i13>:
TRAPHANDLER(i13, T_GPFLT)
f0104458:	6a 0d                	push   $0xd
f010445a:	e9 8b 00 00 00       	jmp    f01044ea <_alltraps>
f010445f:	90                   	nop

f0104460 <i14>:
TRAPHANDLER(i14, T_PGFLT)
f0104460:	6a 0e                	push   $0xe
f0104462:	e9 83 00 00 00       	jmp    f01044ea <_alltraps>
f0104467:	90                   	nop

f0104468 <i15>:
TRAPHANDLER_NOEC(i15, 15)
f0104468:	6a 00                	push   $0x0
f010446a:	6a 0f                	push   $0xf
f010446c:	eb 7c                	jmp    f01044ea <_alltraps>

f010446e <i16>:
TRAPHANDLER_NOEC(i16, T_FPERR)
f010446e:	6a 00                	push   $0x0
f0104470:	6a 10                	push   $0x10
f0104472:	eb 76                	jmp    f01044ea <_alltraps>

f0104474 <i17>:
TRAPHANDLER(i17, T_ALIGN)
f0104474:	6a 11                	push   $0x11
f0104476:	eb 72                	jmp    f01044ea <_alltraps>

f0104478 <i18>:
TRAPHANDLER_NOEC(i18, T_MCHK)
f0104478:	6a 00                	push   $0x0
f010447a:	6a 12                	push   $0x12
f010447c:	eb 6c                	jmp    f01044ea <_alltraps>

f010447e <i19>:
TRAPHANDLER_NOEC(i19, T_SIMDERR)
f010447e:	6a 00                	push   $0x0
f0104480:	6a 13                	push   $0x13
f0104482:	eb 66                	jmp    f01044ea <_alltraps>

f0104484 <irq0>:


TRAPHANDLER_NOEC(irq0, IRQ_OFFSET + IRQ_TIMER)
f0104484:	6a 00                	push   $0x0
f0104486:	6a 20                	push   $0x20
f0104488:	eb 60                	jmp    f01044ea <_alltraps>

f010448a <irq1>:
TRAPHANDLER_NOEC(irq1, IRQ_OFFSET+IRQ_KBD) 
f010448a:	6a 00                	push   $0x0
f010448c:	6a 21                	push   $0x21
f010448e:	eb 5a                	jmp    f01044ea <_alltraps>

f0104490 <irq2>:
TRAPHANDLER_NOEC(irq2, 34)
f0104490:	6a 00                	push   $0x0
f0104492:	6a 22                	push   $0x22
f0104494:	eb 54                	jmp    f01044ea <_alltraps>

f0104496 <irq3>:
TRAPHANDLER_NOEC(irq3, 35)
f0104496:	6a 00                	push   $0x0
f0104498:	6a 23                	push   $0x23
f010449a:	eb 4e                	jmp    f01044ea <_alltraps>

f010449c <irq4>:
TRAPHANDLER_NOEC(irq4, IRQ_OFFSET+IRQ_SERIAL)
f010449c:	6a 00                	push   $0x0
f010449e:	6a 24                	push   $0x24
f01044a0:	eb 48                	jmp    f01044ea <_alltraps>

f01044a2 <irq5>:
TRAPHANDLER_NOEC(irq5, 37) 
f01044a2:	6a 00                	push   $0x0
f01044a4:	6a 25                	push   $0x25
f01044a6:	eb 42                	jmp    f01044ea <_alltraps>

f01044a8 <irq6>:
TRAPHANDLER_NOEC(irq6, 38)
f01044a8:	6a 00                	push   $0x0
f01044aa:	6a 26                	push   $0x26
f01044ac:	eb 3c                	jmp    f01044ea <_alltraps>

f01044ae <irq7>:
TRAPHANDLER_NOEC(irq7, 39)
f01044ae:	6a 00                	push   $0x0
f01044b0:	6a 27                	push   $0x27
f01044b2:	eb 36                	jmp    f01044ea <_alltraps>

f01044b4 <irq8>:
TRAPHANDLER_NOEC(irq8, 40)
f01044b4:	6a 00                	push   $0x0
f01044b6:	6a 28                	push   $0x28
f01044b8:	eb 30                	jmp    f01044ea <_alltraps>

f01044ba <irq9>:
TRAPHANDLER_NOEC(irq9, 41) 
f01044ba:	6a 00                	push   $0x0
f01044bc:	6a 29                	push   $0x29
f01044be:	eb 2a                	jmp    f01044ea <_alltraps>

f01044c0 <irq10>:
TRAPHANDLER_NOEC(irq10, 42)
f01044c0:	6a 00                	push   $0x0
f01044c2:	6a 2a                	push   $0x2a
f01044c4:	eb 24                	jmp    f01044ea <_alltraps>

f01044c6 <irq11>:
TRAPHANDLER_NOEC(irq11, IRQ_OFFSET + IRQ_NIC)
f01044c6:	6a 00                	push   $0x0
f01044c8:	6a 2b                	push   $0x2b
f01044ca:	eb 1e                	jmp    f01044ea <_alltraps>

f01044cc <irq12>:
TRAPHANDLER_NOEC(irq12, 44)
f01044cc:	6a 00                	push   $0x0
f01044ce:	6a 2c                	push   $0x2c
f01044d0:	eb 18                	jmp    f01044ea <_alltraps>

f01044d2 <irq13>:
TRAPHANDLER_NOEC(irq13, 45) 
f01044d2:	6a 00                	push   $0x0
f01044d4:	6a 2d                	push   $0x2d
f01044d6:	eb 12                	jmp    f01044ea <_alltraps>

f01044d8 <irq14>:
TRAPHANDLER_NOEC(irq14, 46)
f01044d8:	6a 00                	push   $0x0
f01044da:	6a 2e                	push   $0x2e
f01044dc:	eb 0c                	jmp    f01044ea <_alltraps>

f01044de <irq15>:
TRAPHANDLER_NOEC(irq15, 47)
f01044de:	6a 00                	push   $0x0
f01044e0:	6a 2f                	push   $0x2f
f01044e2:	eb 06                	jmp    f01044ea <_alltraps>

f01044e4 <i20>:
TRAPHANDLER_NOEC(i20, T_SYSCALL)
f01044e4:	6a 00                	push   $0x0
f01044e6:	6a 30                	push   $0x30
f01044e8:	eb 00                	jmp    f01044ea <_alltraps>

f01044ea <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f01044ea:	1e                   	push   %ds
        pushl %es
f01044eb:	06                   	push   %es
        pushal
f01044ec:	60                   	pusha  
        movl $GD_KD, %eax
f01044ed:	b8 10 00 00 00       	mov    $0x10,%eax
        movl %eax, %ds
f01044f2:	8e d8                	mov    %eax,%ds
        movl %eax, %es
f01044f4:	8e c0                	mov    %eax,%es
        pushl %esp
f01044f6:	54                   	push   %esp
        call trap
f01044f7:	e8 8a fc ff ff       	call   f0104186 <trap>

f01044fc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044fc:	55                   	push   %ebp
f01044fd:	89 e5                	mov    %esp,%ebp
f01044ff:	83 ec 08             	sub    $0x8,%esp
f0104502:	a1 6c 82 2a f0       	mov    0xf02a826c,%eax
f0104507:	8d 50 54             	lea    0x54(%eax),%edx
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010450a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010450f:	8b 02                	mov    (%edx),%eax
f0104511:	83 e8 01             	sub    $0x1,%eax
{
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104514:	83 f8 02             	cmp    $0x2,%eax
f0104517:	76 10                	jbe    f0104529 <sched_halt+0x2d>
sched_halt(void)
{
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104519:	83 c1 01             	add    $0x1,%ecx
f010451c:	83 c2 7c             	add    $0x7c,%edx
f010451f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104525:	75 e8                	jne    f010450f <sched_halt+0x13>
f0104527:	eb 08                	jmp    f0104531 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104529:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010452f:	75 1f                	jne    f0104550 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104531:	83 ec 0c             	sub    $0xc,%esp
f0104534:	68 d0 85 10 f0       	push   $0xf01085d0
f0104539:	e8 1f f2 ff ff       	call   f010375d <cprintf>
f010453e:	83 c4 10             	add    $0x10,%esp
		while (1)  
			monitor(NULL);
f0104541:	83 ec 0c             	sub    $0xc,%esp
f0104544:	6a 00                	push   $0x0
f0104546:	e8 75 c4 ff ff       	call   f01009c0 <monitor>
f010454b:	83 c4 10             	add    $0x10,%esp
f010454e:	eb f1                	jmp    f0104541 <sched_halt+0x45>
	}
	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104550:	e8 c6 19 00 00       	call   f0105f1b <cpunum>
f0104555:	6b c0 74             	imul   $0x74,%eax,%eax
f0104558:	c7 80 48 90 2a f0 00 	movl   $0x0,-0xfd56fb8(%eax)
f010455f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104562:	a1 dc 8e 2a f0       	mov    0xf02a8edc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104567:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010456c:	77 12                	ja     f0104580 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010456e:	50                   	push   %eax
f010456f:	68 48 6f 10 f0       	push   $0xf0106f48
f0104574:	6a 49                	push   $0x49
f0104576:	68 f9 85 10 f0       	push   $0xf01085f9
f010457b:	e8 c0 ba ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104580:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104585:	0f 22 d8             	mov    %eax,%cr3
	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104588:	e8 8e 19 00 00       	call   f0105f1b <cpunum>
f010458d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104590:	81 c2 40 90 2a f0    	add    $0xf02a9040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104596:	b8 02 00 00 00       	mov    $0x2,%eax
f010459b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010459f:	83 ec 0c             	sub    $0xc,%esp
f01045a2:	68 c0 43 12 f0       	push   $0xf01243c0
f01045a7:	e8 77 1c 00 00       	call   f0106223 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01045ac:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045ae:	e8 68 19 00 00       	call   f0105f1b <cpunum>
f01045b3:	6b c0 74             	imul   $0x74,%eax,%eax
	xchg(&thiscpu->cpu_status, CPU_HALTED);
	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01045b6:	8b 80 50 90 2a f0    	mov    -0xfd56fb0(%eax),%eax
f01045bc:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045c1:	89 c4                	mov    %eax,%esp
f01045c3:	6a 00                	push   $0x0
f01045c5:	6a 00                	push   $0x0
f01045c7:	fb                   	sti    
f01045c8:	f4                   	hlt    
f01045c9:	eb fd                	jmp    f01045c8 <sched_halt+0xcc>
f01045cb:	83 c4 10             	add    $0x10,%esp
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01045ce:	c9                   	leave  
f01045cf:	c3                   	ret    

f01045d0 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045d0:	55                   	push   %ebp
f01045d1:	89 e5                	mov    %esp,%ebp
f01045d3:	56                   	push   %esi
f01045d4:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f01045d5:	e8 41 19 00 00       	call   f0105f1b <cpunum>
f01045da:	6b c0 74             	imul   $0x74,%eax,%eax
        else cur = 0;   
f01045dd:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f01045e2:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f01045e9:	74 17                	je     f0104602 <sched_yield+0x32>
f01045eb:	e8 2b 19 00 00       	call   f0105f1b <cpunum>
f01045f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f3:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f01045f9:	8b 48 48             	mov    0x48(%eax),%ecx
f01045fc:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        else cur = 0;   
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
              if (envs[j].env_status == ENV_RUNNABLE) {
f0104602:	8b 1d 6c 82 2a f0    	mov    0xf02a826c,%ebx
f0104608:	89 ca                	mov    %ecx,%edx
f010460a:	81 c1 00 04 00 00    	add    $0x400,%ecx
	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;   
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
f0104610:	89 d6                	mov    %edx,%esi
f0104612:	c1 fe 1f             	sar    $0x1f,%esi
f0104615:	c1 ee 16             	shr    $0x16,%esi
f0104618:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010461b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104620:	29 f0                	sub    %esi,%eax
              if (envs[j].env_status == ENV_RUNNABLE) {
f0104622:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104625:	01 d8                	add    %ebx,%eax
f0104627:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010462b:	75 09                	jne    f0104636 <sched_yield+0x66>
                     // envs[j].env_cpunum == cpunum();

                      env_run(envs + j);
f010462d:	83 ec 0c             	sub    $0xc,%esp
f0104630:	50                   	push   %eax
f0104631:	e8 cc ee ff ff       	call   f0103502 <env_run>
f0104636:	83 c2 01             	add    $0x1,%edx

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;   
        for (i = 0; i < NENV; ++i) {
f0104639:	39 ca                	cmp    %ecx,%edx
f010463b:	75 d3                	jne    f0104610 <sched_yield+0x40>
                     // envs[j].env_cpunum == cpunum();

                      env_run(envs + j);
              }
        }
        if (curenv && curenv->env_status == ENV_RUNNING /*&& cpunum() == curenv->env_cpunum*/) {
f010463d:	e8 d9 18 00 00       	call   f0105f1b <cpunum>
f0104642:	6b c0 74             	imul   $0x74,%eax,%eax
f0104645:	83 b8 48 90 2a f0 00 	cmpl   $0x0,-0xfd56fb8(%eax)
f010464c:	74 2a                	je     f0104678 <sched_yield+0xa8>
f010464e:	e8 c8 18 00 00       	call   f0105f1b <cpunum>
f0104653:	6b c0 74             	imul   $0x74,%eax,%eax
f0104656:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010465c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104660:	75 16                	jne    f0104678 <sched_yield+0xa8>

               env_run(curenv);
f0104662:	e8 b4 18 00 00       	call   f0105f1b <cpunum>
f0104667:	83 ec 0c             	sub    $0xc,%esp
f010466a:	6b c0 74             	imul   $0x74,%eax,%eax
f010466d:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104673:	e8 8a ee ff ff       	call   f0103502 <env_run>
        }
	// sched_halt never returns
	sched_halt();
f0104678:	e8 7f fe ff ff       	call   f01044fc <sched_halt>
}
f010467d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104680:	5b                   	pop    %ebx
f0104681:	5e                   	pop    %esi
f0104682:	5d                   	pop    %ebp
f0104683:	c3                   	ret    

f0104684 <syscall>:
         return transmit(page2pa(tmppage) + sizeof(int), *(int *)(page2kva(tmppage)));
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104684:	55                   	push   %ebp
f0104685:	89 e5                	mov    %esp,%ebp
f0104687:	57                   	push   %edi
f0104688:	56                   	push   %esi
f0104689:	53                   	push   %ebx
f010468a:	83 ec 1c             	sub    $0x1c,%esp
f010468d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
f0104690:	83 f8 10             	cmp    $0x10,%eax
f0104693:	0f 87 b1 06 00 00    	ja     f0104d4a <syscall+0x6c6>
f0104699:	ff 24 85 40 86 10 f0 	jmp    *-0xfef79c0(,%eax,4)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046a0:	e8 76 18 00 00       	call   f0105f1b <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01046a5:	83 ec 04             	sub    $0x4,%esp
f01046a8:	6a 01                	push   $0x1
f01046aa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01046ad:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b1:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01046b7:	ff 70 48             	pushl  0x48(%eax)
f01046ba:	e8 6a e8 ff ff       	call   f0102f29 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f01046bf:	6a 04                	push   $0x4
f01046c1:	ff 75 10             	pushl  0x10(%ebp)
f01046c4:	ff 75 0c             	pushl  0xc(%ebp)
f01046c7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046ca:	e8 93 e7 ff ff       	call   f0102e62 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01046cf:	83 c4 1c             	add    $0x1c,%esp
f01046d2:	ff 75 0c             	pushl  0xc(%ebp)
f01046d5:	ff 75 10             	pushl  0x10(%ebp)
f01046d8:	68 06 86 10 f0       	push   $0xf0108606
f01046dd:	e8 7b f0 ff ff       	call   f010375d <cprintf>
f01046e2:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
        case SYS_cputs:
                sys_cputs((char *)a1, a2);
                rslt = 0;
f01046e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046ea:	e9 75 06 00 00       	jmp    f0104d64 <syscall+0x6e0>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046ef:	e8 1e bf ff ff       	call   f0100612 <cons_getc>
f01046f4:	89 c3                	mov    %eax,%ebx
                sys_cputs((char *)a1, a2);
                rslt = 0;
                break;
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
f01046f6:	e9 69 06 00 00       	jmp    f0104d64 <syscall+0x6e0>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046fb:	e8 1b 18 00 00       	call   f0105f1b <cpunum>
f0104700:	6b c0 74             	imul   $0x74,%eax,%eax
f0104703:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104709:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
	case SYS_getenvid:
                rslt = sys_getenvid();
                break;
f010470c:	e9 53 06 00 00       	jmp    f0104d64 <syscall+0x6e0>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104711:	83 ec 04             	sub    $0x4,%esp
f0104714:	6a 01                	push   $0x1
f0104716:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104719:	50                   	push   %eax
f010471a:	ff 75 0c             	pushl  0xc(%ebp)
f010471d:	e8 07 e8 ff ff       	call   f0102f29 <envid2env>
f0104722:	83 c4 10             	add    $0x10,%esp
		return r;
f0104725:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104727:	85 c0                	test   %eax,%eax
f0104729:	0f 88 35 06 00 00    	js     f0104d64 <syscall+0x6e0>
		return r;
	env_destroy(e);
f010472f:	83 ec 0c             	sub    $0xc,%esp
f0104732:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104735:	e8 29 ed ff ff       	call   f0103463 <env_destroy>
f010473a:	83 c4 10             	add    $0x10,%esp
	return 0;
f010473d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104742:	e9 1d 06 00 00       	jmp    f0104d64 <syscall+0x6e0>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104747:	e8 84 fe ff ff       	call   f01045d0 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f010474c:	e8 ca 17 00 00       	call   f0105f1b <cpunum>
f0104751:	83 ec 08             	sub    $0x8,%esp
f0104754:	6b c0 74             	imul   $0x74,%eax,%eax
f0104757:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f010475d:	ff 70 48             	pushl  0x48(%eax)
f0104760:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104763:	50                   	push   %eax
f0104764:	e8 c5 e8 ff ff       	call   f010302e <env_alloc>
f0104769:	83 c4 10             	add    $0x10,%esp
                return ret;
f010476c:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f010476e:	85 c0                	test   %eax,%eax
f0104770:	0f 85 ee 05 00 00    	jne    f0104d64 <syscall+0x6e0>
                return ret;
     
        newenv->env_status = ENV_NOT_RUNNABLE;
f0104776:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104779:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
        newenv->env_tf = curenv->env_tf; 
f0104780:	e8 96 17 00 00       	call   f0105f1b <cpunum>
f0104785:	6b c0 74             	imul   $0x74,%eax,%eax
f0104788:	8b b0 48 90 2a f0    	mov    -0xfd56fb8(%eax),%esi
f010478e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104793:	89 df                	mov    %ebx,%edi
f0104795:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        newenv->env_tf.tf_regs.reg_eax = 0;
f0104797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010479a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return newenv->env_id;
f01047a1:	8b 58 48             	mov    0x48(%eax),%ebx
f01047a4:	e9 bb 05 00 00       	jmp    f0104d64 <syscall+0x6e0>

	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f01047a9:	83 ec 04             	sub    $0x4,%esp
f01047ac:	6a 01                	push   $0x1
f01047ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047b1:	50                   	push   %eax
f01047b2:	ff 75 0c             	pushl  0xc(%ebp)
f01047b5:	e8 6f e7 ff ff       	call   f0102f29 <envid2env>
f01047ba:	83 c4 10             	add    $0x10,%esp
f01047bd:	85 c0                	test   %eax,%eax
f01047bf:	0f 85 ba 00 00 00    	jne    f010487f <syscall+0x1fb>
                return rslt;
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f01047c5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047cc:	0f 87 b4 00 00 00    	ja     f0104886 <syscall+0x202>
f01047d2:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047d9:	0f 85 b1 00 00 00    	jne    f0104890 <syscall+0x20c>
                return -E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01047df:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e2:	83 e0 05             	and    $0x5,%eax
f01047e5:	83 f8 05             	cmp    $0x5,%eax
f01047e8:	0f 85 ac 00 00 00    	jne    f010489a <syscall+0x216>
                return -E_INVAL;
        if((p = page_alloc(1)) == (void*)NULL)
f01047ee:	83 ec 0c             	sub    $0xc,%esp
f01047f1:	6a 01                	push   $0x1
f01047f3:	e8 be c7 ff ff       	call   f0100fb6 <page_alloc>
f01047f8:	89 c6                	mov    %eax,%esi
f01047fa:	83 c4 10             	add    $0x10,%esp
f01047fd:	85 c0                	test   %eax,%eax
f01047ff:	0f 84 9f 00 00 00    	je     f01048a4 <syscall+0x220>
                return -E_NO_MEM;
        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) {
f0104805:	ff 75 14             	pushl  0x14(%ebp)
f0104808:	ff 75 10             	pushl  0x10(%ebp)
f010480b:	50                   	push   %eax
f010480c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010480f:	ff 70 60             	pushl  0x60(%eax)
f0104812:	e8 b5 ca ff ff       	call   f01012cc <page_insert>
f0104817:	89 c3                	mov    %eax,%ebx
f0104819:	83 c4 10             	add    $0x10,%esp
f010481c:	85 c0                	test   %eax,%eax
f010481e:	74 11                	je     f0104831 <syscall+0x1ad>
                page_free(p);
f0104820:	83 ec 0c             	sub    $0xc,%esp
f0104823:	56                   	push   %esi
f0104824:	e8 fb c7 ff ff       	call   f0101024 <page_free>
f0104829:	83 c4 10             	add    $0x10,%esp
f010482c:	e9 33 05 00 00       	jmp    f0104d64 <syscall+0x6e0>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104831:	2b 35 e0 8e 2a f0    	sub    0xf02a8ee0,%esi
f0104837:	c1 fe 03             	sar    $0x3,%esi
f010483a:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010483d:	89 f0                	mov    %esi,%eax
f010483f:	c1 e8 0c             	shr    $0xc,%eax
f0104842:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0104848:	72 12                	jb     f010485c <syscall+0x1d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010484a:	56                   	push   %esi
f010484b:	68 24 6f 10 f0       	push   $0xf0106f24
f0104850:	6a 58                	push   $0x58
f0104852:	68 ea 74 10 f0       	push   $0xf01074ea
f0104857:	e8 e4 b7 ff ff       	call   f0100040 <_panic>
                return rslt;
        }
        memset(page2kva(p), 0, PGSIZE);
f010485c:	83 ec 04             	sub    $0x4,%esp
f010485f:	68 00 10 00 00       	push   $0x1000
f0104864:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0104866:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f010486c:	56                   	push   %esi
f010486d:	e8 85 10 00 00       	call   f01058f7 <memset>
f0104872:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104875:	bb 00 00 00 00       	mov    $0x0,%ebx
f010487a:	e9 e5 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;
f010487f:	89 c3                	mov    %eax,%ebx
f0104881:	e9 de 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL;
f0104886:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010488b:	e9 d4 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
f0104890:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104895:	e9 ca 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010489a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010489f:	e9 c0 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((p = page_alloc(1)) == (void*)NULL)
                return -E_NO_MEM;
f01048a4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
        case SYS_exofork:
                rslt = sys_exofork();
                break;
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
f01048a9:	e9 b6 04 00 00       	jmp    f0104d64 <syscall+0x6e0>
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f01048ae:	83 ec 04             	sub    $0x4,%esp
f01048b1:	6a 01                	push   $0x1
f01048b3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048b6:	50                   	push   %eax
f01048b7:	ff 75 0c             	pushl  0xc(%ebp)
f01048ba:	e8 6a e6 ff ff       	call   f0102f29 <envid2env>
f01048bf:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01048c2:	89 c3                	mov    %eax,%ebx
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f01048c4:	85 c0                	test   %eax,%eax
f01048c6:	0f 85 98 04 00 00    	jne    f0104d64 <syscall+0x6e0>
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048cc:	83 ec 04             	sub    $0x4,%esp
f01048cf:	6a 01                	push   $0x1
f01048d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048d4:	50                   	push   %eax
f01048d5:	ff 75 14             	pushl  0x14(%ebp)
f01048d8:	e8 4c e6 ff ff       	call   f0102f29 <envid2env>
f01048dd:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01048e0:	89 c3                	mov    %eax,%ebx
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048e2:	85 c0                	test   %eax,%eax
f01048e4:	0f 85 7a 04 00 00    	jne    f0104d64 <syscall+0x6e0>
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
f01048ea:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048f1:	77 73                	ja     f0104966 <syscall+0x2e2>
                return -E_INVAL;
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
f01048f3:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048fa:	75 74                	jne    f0104970 <syscall+0x2ec>
f01048fc:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104903:	77 6b                	ja     f0104970 <syscall+0x2ec>
f0104905:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010490c:	75 6c                	jne    f010497a <syscall+0x2f6>
                return -E_INVAL;
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
f010490e:	83 ec 04             	sub    $0x4,%esp
f0104911:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104914:	50                   	push   %eax
f0104915:	ff 75 10             	pushl  0x10(%ebp)
f0104918:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010491b:	ff 70 60             	pushl  0x60(%eax)
f010491e:	e8 bd c8 ff ff       	call   f01011e0 <page_lookup>
f0104923:	83 c4 10             	add    $0x10,%esp
f0104926:	85 c0                	test   %eax,%eax
f0104928:	74 5a                	je     f0104984 <syscall+0x300>
f010492a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010492d:	8b 12                	mov    (%edx),%edx
f010492f:	f6 c2 01             	test   $0x1,%dl
f0104932:	74 5a                	je     f010498e <syscall+0x30a>
                return 	-E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0104934:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104937:	83 e1 05             	and    $0x5,%ecx
f010493a:	83 f9 05             	cmp    $0x5,%ecx
f010493d:	75 59                	jne    f0104998 <syscall+0x314>
                return -E_INVAL;
        if((perm & PTE_W) && !(*srcpte & PTE_W))
f010493f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104943:	74 05                	je     f010494a <syscall+0x2c6>
f0104945:	f6 c2 02             	test   $0x2,%dl
f0104948:	74 58                	je     f01049a2 <syscall+0x31e>
                return -E_INVAL;
        rslt =  page_insert(dst->env_pgdir, pg, dstva, perm);
f010494a:	ff 75 1c             	pushl  0x1c(%ebp)
f010494d:	ff 75 18             	pushl  0x18(%ebp)
f0104950:	50                   	push   %eax
f0104951:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104954:	ff 70 60             	pushl  0x60(%eax)
f0104957:	e8 70 c9 ff ff       	call   f01012cc <page_insert>
f010495c:	83 c4 10             	add    $0x10,%esp
        return rslt;
f010495f:	89 c3                	mov    %eax,%ebx
f0104961:	e9 fe 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
                return -E_INVAL;
f0104966:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496b:	e9 f4 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
                return -E_INVAL;
f0104970:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104975:	e9 ea 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
f010497a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010497f:	e9 e0 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
                return 	-E_INVAL;
f0104984:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104989:	e9 d6 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
f010498e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104993:	e9 cc 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f0104998:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010499d:	e9 c2 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
        if((perm & PTE_W) && !(*srcpte & PTE_W))
                return -E_INVAL;
f01049a2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
f01049a7:	e9 b8 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f01049ac:	83 ec 04             	sub    $0x4,%esp
f01049af:	6a 01                	push   $0x1
f01049b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049b4:	50                   	push   %eax
f01049b5:	ff 75 0c             	pushl  0xc(%ebp)
f01049b8:	e8 6c e5 ff ff       	call   f0102f29 <envid2env>
f01049bd:	83 c4 10             	add    $0x10,%esp
                return rslt;  
f01049c0:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f01049c2:	85 c0                	test   %eax,%eax
f01049c4:	0f 85 9a 03 00 00    	jne    f0104d64 <syscall+0x6e0>
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f01049ca:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049d1:	77 27                	ja     f01049fa <syscall+0x376>
f01049d3:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049da:	75 28                	jne    f0104a04 <syscall+0x380>
                return -E_INVAL; 
        page_remove(tmp->env_pgdir, va);
f01049dc:	83 ec 08             	sub    $0x8,%esp
f01049df:	ff 75 10             	pushl  0x10(%ebp)
f01049e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049e5:	ff 70 60             	pushl  0x60(%eax)
f01049e8:	e8 8e c8 ff ff       	call   f010127b <page_remove>
f01049ed:	83 c4 10             	add    $0x10,%esp
        return 0;
f01049f0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049f5:	e9 6a 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL; 
f01049fa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049ff:	e9 60 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
f0104a04:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
	case SYS_page_unmap:
                rslt = sys_page_unmap(a1, (void *)a2);
                break;
f0104a09:	e9 56 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
	// envid's status.

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104a0e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a11:	83 e8 02             	sub    $0x2,%eax
f0104a14:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104a19:	75 2c                	jne    f0104a47 <syscall+0x3c3>
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a1b:	83 ec 04             	sub    $0x4,%esp
f0104a1e:	6a 01                	push   $0x1
f0104a20:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a23:	50                   	push   %eax
f0104a24:	ff 75 0c             	pushl  0xc(%ebp)
f0104a27:	e8 fd e4 ff ff       	call   f0102f29 <envid2env>
f0104a2c:	83 c4 10             	add    $0x10,%esp
                tmp->env_status = status;
        return rslt;     
f0104a2f:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a31:	85 c0                	test   %eax,%eax
f0104a33:	0f 85 2b 03 00 00    	jne    f0104d64 <syscall+0x6e0>
                tmp->env_status = status;
f0104a39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a3f:	89 4a 54             	mov    %ecx,0x54(%edx)
f0104a42:	e9 1d 03 00 00       	jmp    f0104d64 <syscall+0x6e0>

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
f0104a47:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a4c:	e9 13 03 00 00       	jmp    f0104d64 <syscall+0x6e0>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a51:	83 ec 04             	sub    $0x4,%esp
f0104a54:	6a 01                	push   $0x1
f0104a56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a59:	50                   	push   %eax
f0104a5a:	ff 75 0c             	pushl  0xc(%ebp)
f0104a5d:	e8 c7 e4 ff ff       	call   f0102f29 <envid2env>
f0104a62:	83 c4 10             	add    $0x10,%esp
f0104a65:	85 c0                	test   %eax,%eax
f0104a67:	75 09                	jne    f0104a72 <syscall+0x3ee>
                tmp->env_pgfault_upcall = func;
f0104a69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a6c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a6f:	89 7a 64             	mov    %edi,0x64(%edx)
                break;
        case SYS_env_set_status:
                rslt = sys_env_set_status(a1, a2);
                break;
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104a72:	89 c3                	mov    %eax,%ebx
                break;
f0104a74:	e9 eb 02 00 00       	jmp    f0104d64 <syscall+0x6e0>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
f0104a79:	83 ec 04             	sub    $0x4,%esp
f0104a7c:	6a 00                	push   $0x0
f0104a7e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a81:	50                   	push   %eax
f0104a82:	ff 75 0c             	pushl  0xc(%ebp)
f0104a85:	e8 9f e4 ff ff       	call   f0102f29 <envid2env>
f0104a8a:	83 c4 10             	add    $0x10,%esp
f0104a8d:	85 c0                	test   %eax,%eax
f0104a8f:	0f 88 07 01 00 00    	js     f0104b9c <syscall+0x518>
                return -E_BAD_ENV;

        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
f0104a95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a98:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a9c:	0f 84 04 01 00 00    	je     f0104ba6 <syscall+0x522>
f0104aa2:	8b 58 74             	mov    0x74(%eax),%ebx
f0104aa5:	85 db                	test   %ebx,%ebx
f0104aa7:	0f 85 03 01 00 00    	jne    f0104bb0 <syscall+0x52c>
                return -E_IPC_NOT_RECV;   
        if(srcva < (void *)UTOP) {
f0104aad:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104ab4:	0f 87 ab 00 00 00    	ja     f0104b65 <syscall+0x4e1>

                if((size_t)srcva % PGSIZE)  
f0104aba:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104ac1:	75 70                	jne    f0104b33 <syscall+0x4af>
                        return -E_INVAL;

                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
f0104ac3:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ac6:	83 e0 05             	and    $0x5,%eax
f0104ac9:	83 f8 05             	cmp    $0x5,%eax
f0104acc:	75 6f                	jne    f0104b3d <syscall+0x4b9>
                        return -E_INVAL;
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104ace:	e8 48 14 00 00       	call   f0105f1b <cpunum>
f0104ad3:	83 ec 04             	sub    $0x4,%esp
f0104ad6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ad9:	52                   	push   %edx
f0104ada:	ff 75 14             	pushl  0x14(%ebp)
f0104add:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae0:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104ae6:	ff 70 60             	pushl  0x60(%eax)
f0104ae9:	e8 f2 c6 ff ff       	call   f01011e0 <page_lookup>
 
                if(!pg) return -E_INVAL;
f0104aee:	83 c4 10             	add    $0x10,%esp
f0104af1:	85 c0                	test   %eax,%eax
f0104af3:	74 52                	je     f0104b47 <syscall+0x4c3>
 
                if( (perm & PTE_W) && !(*pte & PTE_W))  
f0104af5:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104af9:	74 08                	je     f0104b03 <syscall+0x47f>
f0104afb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104afe:	f6 02 02             	testb  $0x2,(%edx)
f0104b01:	74 4e                	je     f0104b51 <syscall+0x4cd>
                        return -E_INVAL;
 
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
f0104b03:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b06:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104b09:	8d 71 ff             	lea    -0x1(%ecx),%esi
f0104b0c:	81 fe fe ff bf ee    	cmp    $0xeebffffe,%esi
f0104b12:	77 51                	ja     f0104b65 <syscall+0x4e1>
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
f0104b14:	ff 75 18             	pushl  0x18(%ebp)
f0104b17:	51                   	push   %ecx
f0104b18:	50                   	push   %eax
f0104b19:	ff 72 60             	pushl  0x60(%edx)
f0104b1c:	e8 ab c7 ff ff       	call   f01012cc <page_insert>
f0104b21:	83 c4 10             	add    $0x10,%esp
f0104b24:	85 c0                	test   %eax,%eax
f0104b26:	78 33                	js     f0104b5b <syscall+0x4d7>
                                return -E_NO_MEM;
                        target->env_ipc_perm = perm;
f0104b28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b2b:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b2e:	89 78 78             	mov    %edi,0x78(%eax)
f0104b31:	eb 32                	jmp    f0104b65 <syscall+0x4e1>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;   
        if(srcva < (void *)UTOP) {

                if((size_t)srcva % PGSIZE)  
                        return -E_INVAL;
f0104b33:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b38:	e9 27 02 00 00       	jmp    f0104d64 <syscall+0x6e0>

                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
                        return -E_INVAL;
f0104b3d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b42:	e9 1d 02 00 00       	jmp    f0104d64 <syscall+0x6e0>
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
 
                if(!pg) return -E_INVAL;
f0104b47:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b4c:	e9 13 02 00 00       	jmp    f0104d64 <syscall+0x6e0>
 
                if( (perm & PTE_W) && !(*pte & PTE_W))  
                        return -E_INVAL;
f0104b51:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b56:	e9 09 02 00 00       	jmp    f0104d64 <syscall+0x6e0>
 
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
                                return -E_NO_MEM;
f0104b5b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b60:	e9 ff 01 00 00       	jmp    f0104d64 <syscall+0x6e0>
                        target->env_ipc_perm = perm;
                }
        }
        target->env_ipc_recving = 0;
f0104b65:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b68:	c6 46 68 00          	movb   $0x0,0x68(%esi)
        target->env_ipc_value = value;
f0104b6c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b6f:	89 46 70             	mov    %eax,0x70(%esi)
        target->env_ipc_from = curenv->env_id;
f0104b72:	e8 a4 13 00 00       	call   f0105f1b <cpunum>
f0104b77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7a:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104b80:	8b 40 48             	mov    0x48(%eax),%eax
f0104b83:	89 46 74             	mov    %eax,0x74(%esi)
        target->env_tf.tf_regs.reg_eax = 0;
f0104b86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b89:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        target->env_status = ENV_RUNNABLE;
f0104b90:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104b97:	e9 c8 01 00 00       	jmp    f0104d64 <syscall+0x6e0>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
                return -E_BAD_ENV;
f0104b9c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104ba1:	e9 be 01 00 00       	jmp    f0104d64 <syscall+0x6e0>

        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;   
f0104ba6:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bab:	e9 b4 01 00 00       	jmp    f0104d64 <syscall+0x6e0>
f0104bb0:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
f0104bb5:	e9 aa 01 00 00       	jmp    f0104d64 <syscall+0x6e0>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
        if((dstva < (void *)UTOP) && ((size_t)dstva % PGSIZE))
f0104bba:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104bc1:	77 0d                	ja     f0104bd0 <syscall+0x54c>
f0104bc3:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104bca:	0f 85 81 01 00 00    	jne    f0104d51 <syscall+0x6cd>
                        return -E_INVAL;
        curenv->env_ipc_recving = 1;
f0104bd0:	e8 46 13 00 00       	call   f0105f1b <cpunum>
f0104bd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd8:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104bde:	c6 40 68 01          	movb   $0x1,0x68(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0104be2:	e8 34 13 00 00       	call   f0105f1b <cpunum>
f0104be7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bea:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104bf0:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_dstva = dstva;
f0104bf7:	e8 1f 13 00 00       	call   f0105f1b <cpunum>
f0104bfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bff:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104c05:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104c08:	89 78 6c             	mov    %edi,0x6c(%eax)
        curenv->env_ipc_from = 0;
f0104c0b:	e8 0b 13 00 00       	call   f0105f1b <cpunum>
f0104c10:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c13:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104c19:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c20:	e8 ab f9 ff ff       	call   f01045d0 <sched_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104c25:	83 ec 04             	sub    $0x4,%esp
f0104c28:	6a 01                	push   $0x1
f0104c2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c2d:	50                   	push   %eax
f0104c2e:	ff 75 0c             	pushl  0xc(%ebp)
f0104c31:	e8 f3 e2 ff ff       	call   f0102f29 <envid2env>
f0104c36:	83 c4 10             	add    $0x10,%esp
                return ret;
f0104c39:	89 c3                	mov    %eax,%ebx
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104c3b:	85 c0                	test   %eax,%eax
f0104c3d:	0f 88 21 01 00 00    	js     f0104d64 <syscall+0x6e0>
                return ret;
        user_mem_assert(newenv, tf, sizeof(struct Trapframe), PTE_U);
f0104c43:	6a 04                	push   $0x4
f0104c45:	6a 44                	push   $0x44
f0104c47:	ff 75 10             	pushl  0x10(%ebp)
f0104c4a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c4d:	e8 10 e2 ff ff       	call   f0102e62 <user_mem_assert>
        newenv->env_tf = *tf;
f0104c52:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c5a:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_eflags |= FL_IF;
f0104c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c62:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
        newenv->env_tf.tf_cs = GD_UT | 3;	
f0104c69:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
f0104c6f:	83 c4 10             	add    $0x10,%esp
        return 0;
f0104c72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c77:	e9 e8 00 00 00       	jmp    f0104d64 <syscall+0x6e0>
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	//panic("sys_time_msec not implemented");
        return time_msec();
f0104c7c:	e8 a4 1f 00 00       	call   f0106c25 <time_msec>
f0104c81:	89 c3                	mov    %eax,%ebx
        case SYS_env_set_trapframe:
                rslt = sys_env_set_trapframe(a1, (void *)a2);
                break;
        case SYS_time_msec:
                rslt = sys_time_msec();
                break;
f0104c83:	e9 dc 00 00 00       	jmp    f0104d64 <syscall+0x6e0>

static int
sys_transmit(void *addr)
{
 
         if((addr < (void *)UTOP) && ((size_t)addr % PGSIZE))
f0104c88:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104c8f:	77 0d                	ja     f0104c9e <syscall+0x61a>
f0104c91:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104c98:	0f 85 ba 00 00 00    	jne    f0104d58 <syscall+0x6d4>
                        return -E_INVAL;
         struct PageInfo *tmppage;
         if ((tmppage = page_lookup(curenv->env_pgdir, addr, 0)) == NULL)
f0104c9e:	e8 78 12 00 00       	call   f0105f1b <cpunum>
f0104ca3:	83 ec 04             	sub    $0x4,%esp
f0104ca6:	6a 00                	push   $0x0
f0104ca8:	ff 75 0c             	pushl  0xc(%ebp)
f0104cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cae:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0104cb4:	ff 70 60             	pushl  0x60(%eax)
f0104cb7:	e8 24 c5 ff ff       	call   f01011e0 <page_lookup>
f0104cbc:	83 c4 10             	add    $0x10,%esp
f0104cbf:	85 c0                	test   %eax,%eax
f0104cc1:	75 17                	jne    f0104cda <syscall+0x656>
                panic("Page doesn't exist from transmit\n");
f0104cc3:	83 ec 04             	sub    $0x4,%esp
f0104cc6:	68 1c 86 10 f0       	push   $0xf010861c
f0104ccb:	68 c3 01 00 00       	push   $0x1c3
f0104cd0:	68 0b 86 10 f0       	push   $0xf010860b
f0104cd5:	e8 66 b3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104cda:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0104ce0:	c1 f8 03             	sar    $0x3,%eax
f0104ce3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104ce6:	89 c2                	mov    %eax,%edx
f0104ce8:	c1 ea 0c             	shr    $0xc,%edx
f0104ceb:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0104cf1:	72 12                	jb     f0104d05 <syscall+0x681>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104cf3:	50                   	push   %eax
f0104cf4:	68 24 6f 10 f0       	push   $0xf0106f24
f0104cf9:	6a 58                	push   $0x58
f0104cfb:	68 ea 74 10 f0       	push   $0xf01074ea
f0104d00:	e8 3b b3 ff ff       	call   f0100040 <_panic>
         return transmit(page2pa(tmppage) + sizeof(int), *(int *)(page2kva(tmppage)));
f0104d05:	83 ec 04             	sub    $0x4,%esp
f0104d08:	0f b7 90 00 00 00 f0 	movzwl -0x10000000(%eax),%edx
f0104d0f:	52                   	push   %edx
f0104d10:	83 c0 04             	add    $0x4,%eax
f0104d13:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d18:	52                   	push   %edx
f0104d19:	50                   	push   %eax
f0104d1a:	e8 3b 18 00 00       	call   f010655a <transmit>
f0104d1f:	89 c3                	mov    %eax,%ebx
f0104d21:	83 c4 10             	add    $0x10,%esp
f0104d24:	eb 3e                	jmp    f0104d64 <syscall+0x6e0>
	return 0;
}
static int 
sys_recv(void *tempage)
{
        if((tempage < (void *)UTOP) && ((size_t)tempage % PGSIZE))
f0104d26:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104d2d:	77 09                	ja     f0104d38 <syscall+0x6b4>
f0104d2f:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104d36:	75 27                	jne    f0104d5f <syscall+0x6db>
                        return -E_INVAL;
       
        return recv(tempage);
f0104d38:	83 ec 0c             	sub    $0xc,%esp
f0104d3b:	ff 75 0c             	pushl  0xc(%ebp)
f0104d3e:	e8 7e 18 00 00       	call   f01065c1 <recv>
f0104d43:	89 c3                	mov    %eax,%ebx
f0104d45:	83 c4 10             	add    $0x10,%esp
f0104d48:	eb 1a                	jmp    f0104d64 <syscall+0x6e0>
                break;
        case SYS_recv:
                rslt = sys_recv((void *)a1);
                break;
	default:
		return -E_INVAL;
f0104d4a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d4f:	eb 13                	jmp    f0104d64 <syscall+0x6e0>
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
        case SYS_ipc_recv:
                rslt = sys_ipc_recv((void *)a1);
f0104d51:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d56:	eb 0c                	jmp    f0104d64 <syscall+0x6e0>
static int
sys_transmit(void *addr)
{
 
         if((addr < (void *)UTOP) && ((size_t)addr % PGSIZE))
                        return -E_INVAL;
f0104d58:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d5d:	eb 05                	jmp    f0104d64 <syscall+0x6e0>
}
static int 
sys_recv(void *tempage)
{
        if((tempage < (void *)UTOP) && ((size_t)tempage % PGSIZE))
                        return -E_INVAL;
f0104d5f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
                break;
	default:
		return -E_INVAL;
	}
        return rslt;
}
f0104d64:	89 d8                	mov    %ebx,%eax
f0104d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d69:	5b                   	pop    %ebx
f0104d6a:	5e                   	pop    %esi
f0104d6b:	5f                   	pop    %edi
f0104d6c:	5d                   	pop    %ebp
f0104d6d:	c3                   	ret    

f0104d6e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104d6e:	55                   	push   %ebp
f0104d6f:	89 e5                	mov    %esp,%ebp
f0104d71:	57                   	push   %edi
f0104d72:	56                   	push   %esi
f0104d73:	53                   	push   %ebx
f0104d74:	83 ec 14             	sub    $0x14,%esp
f0104d77:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104d7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104d7d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d80:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104d83:	8b 1a                	mov    (%edx),%ebx
f0104d85:	8b 01                	mov    (%ecx),%eax
f0104d87:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d8a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104d91:	e9 88 00 00 00       	jmp    f0104e1e <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d99:	01 d8                	add    %ebx,%eax
f0104d9b:	89 c6                	mov    %eax,%esi
f0104d9d:	c1 ee 1f             	shr    $0x1f,%esi
f0104da0:	01 c6                	add    %eax,%esi
f0104da2:	d1 fe                	sar    %esi
f0104da4:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104da7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104daa:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104dad:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104daf:	eb 03                	jmp    f0104db4 <stab_binsearch+0x46>
			m--;
f0104db1:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104db4:	39 c3                	cmp    %eax,%ebx
f0104db6:	7f 1f                	jg     f0104dd7 <stab_binsearch+0x69>
f0104db8:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104dbc:	83 ea 0c             	sub    $0xc,%edx
f0104dbf:	39 f9                	cmp    %edi,%ecx
f0104dc1:	75 ee                	jne    f0104db1 <stab_binsearch+0x43>
f0104dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104dc6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104dc9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104dcc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104dd0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104dd3:	76 18                	jbe    f0104ded <stab_binsearch+0x7f>
f0104dd5:	eb 05                	jmp    f0104ddc <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104dd7:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104dda:	eb 42                	jmp    f0104e1e <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104ddc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ddf:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104de1:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104de4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104deb:	eb 31                	jmp    f0104e1e <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ded:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104df0:	73 17                	jae    f0104e09 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104df5:	83 e8 01             	sub    $0x1,%eax
f0104df8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104dfb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104dfe:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104e00:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e07:	eb 15                	jmp    f0104e1e <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104e09:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e0c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104e0f:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0104e11:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104e15:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104e17:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104e1e:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104e21:	0f 8e 6f ff ff ff    	jle    f0104d96 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104e27:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104e2b:	75 0f                	jne    f0104e3c <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e30:	8b 00                	mov    (%eax),%eax
f0104e32:	83 e8 01             	sub    $0x1,%eax
f0104e35:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104e38:	89 06                	mov    %eax,(%esi)
f0104e3a:	eb 2c                	jmp    f0104e68 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104e3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e3f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104e41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e44:	8b 0e                	mov    (%esi),%ecx
f0104e46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e49:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104e4c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104e4f:	eb 03                	jmp    f0104e54 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104e51:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104e54:	39 c8                	cmp    %ecx,%eax
f0104e56:	7e 0b                	jle    f0104e63 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104e58:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104e5c:	83 ea 0c             	sub    $0xc,%edx
f0104e5f:	39 fb                	cmp    %edi,%ebx
f0104e61:	75 ee                	jne    f0104e51 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104e63:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e66:	89 06                	mov    %eax,(%esi)
	}
}
f0104e68:	83 c4 14             	add    $0x14,%esp
f0104e6b:	5b                   	pop    %ebx
f0104e6c:	5e                   	pop    %esi
f0104e6d:	5f                   	pop    %edi
f0104e6e:	5d                   	pop    %ebp
f0104e6f:	c3                   	ret    

f0104e70 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104e70:	55                   	push   %ebp
f0104e71:	89 e5                	mov    %esp,%ebp
f0104e73:	57                   	push   %edi
f0104e74:	56                   	push   %esi
f0104e75:	53                   	push   %ebx
f0104e76:	83 ec 3c             	sub    $0x3c,%esp
f0104e79:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104e7f:	c7 03 84 86 10 f0    	movl   $0xf0108684,(%ebx)
	info->eip_line = 0;
f0104e85:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104e8c:	c7 43 08 84 86 10 f0 	movl   $0xf0108684,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104e93:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104e9a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104e9d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ea4:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104eaa:	0f 87 96 00 00 00    	ja     f0104f46 <debuginfo_eip+0xd6>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104eb0:	e8 66 10 00 00       	call   f0105f1b <cpunum>
f0104eb5:	6a 04                	push   $0x4
f0104eb7:	6a 10                	push   $0x10
f0104eb9:	68 00 00 20 00       	push   $0x200000
f0104ebe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec1:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104ec7:	e8 1e df ff ff       	call   f0102dea <user_mem_check>
f0104ecc:	83 c4 10             	add    $0x10,%esp
f0104ecf:	85 c0                	test   %eax,%eax
f0104ed1:	0f 85 15 02 00 00    	jne    f01050ec <debuginfo_eip+0x27c>
			return -1;
		stabs = usd->stabs;
f0104ed7:	a1 00 00 20 00       	mov    0x200000,%eax
f0104edc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104edf:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104ee5:	a1 08 00 20 00       	mov    0x200008,%eax
f0104eea:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104eed:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104ef3:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104ef6:	e8 20 10 00 00       	call   f0105f1b <cpunum>
f0104efb:	6a 04                	push   $0x4
f0104efd:	6a 0c                	push   $0xc
f0104eff:	ff 75 c4             	pushl  -0x3c(%ebp)
f0104f02:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f05:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104f0b:	e8 da de ff ff       	call   f0102dea <user_mem_check>
f0104f10:	83 c4 10             	add    $0x10,%esp
f0104f13:	85 c0                	test   %eax,%eax
f0104f15:	0f 85 d8 01 00 00    	jne    f01050f3 <debuginfo_eip+0x283>
                        return -1;
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104f1b:	e8 fb 0f 00 00       	call   f0105f1b <cpunum>
f0104f20:	6a 04                	push   $0x4
f0104f22:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104f25:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104f28:	29 ca                	sub    %ecx,%edx
f0104f2a:	52                   	push   %edx
f0104f2b:	51                   	push   %ecx
f0104f2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f2f:	ff b0 48 90 2a f0    	pushl  -0xfd56fb8(%eax)
f0104f35:	e8 b0 de ff ff       	call   f0102dea <user_mem_check>
f0104f3a:	83 c4 10             	add    $0x10,%esp
f0104f3d:	85 c0                	test   %eax,%eax
f0104f3f:	74 1f                	je     f0104f60 <debuginfo_eip+0xf0>
f0104f41:	e9 b4 01 00 00       	jmp    f01050fa <debuginfo_eip+0x28a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104f46:	c7 45 bc 49 91 11 f0 	movl   $0xf0119149,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104f4d:	c7 45 c0 ad 4e 11 f0 	movl   $0xf0114ead,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104f54:	bf ac 4e 11 f0       	mov    $0xf0114eac,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104f59:	c7 45 c4 b8 8e 10 f0 	movl   $0xf0108eb8,-0x3c(%ebp)
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104f60:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104f63:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0104f66:	0f 83 95 01 00 00    	jae    f0105101 <debuginfo_eip+0x291>
f0104f6c:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104f70:	0f 85 92 01 00 00    	jne    f0105108 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104f76:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104f7d:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104f80:	c1 ff 02             	sar    $0x2,%edi
f0104f83:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104f89:	83 e8 01             	sub    $0x1,%eax
f0104f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104f8f:	83 ec 08             	sub    $0x8,%esp
f0104f92:	56                   	push   %esi
f0104f93:	6a 64                	push   $0x64
f0104f95:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104f98:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f9b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104f9e:	89 f8                	mov    %edi,%eax
f0104fa0:	e8 c9 fd ff ff       	call   f0104d6e <stab_binsearch>
	if (lfile == 0)
f0104fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fa8:	83 c4 10             	add    $0x10,%esp
f0104fab:	85 c0                	test   %eax,%eax
f0104fad:	0f 84 5c 01 00 00    	je     f010510f <debuginfo_eip+0x29f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104fb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fb9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104fbc:	83 ec 08             	sub    $0x8,%esp
f0104fbf:	56                   	push   %esi
f0104fc0:	6a 24                	push   $0x24
f0104fc2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104fc5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104fc8:	89 f8                	mov    %edi,%eax
f0104fca:	e8 9f fd ff ff       	call   f0104d6e <stab_binsearch>

	if (lfun <= rfun) {
f0104fcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104fd2:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104fd5:	83 c4 10             	add    $0x10,%esp
f0104fd8:	39 f8                	cmp    %edi,%eax
f0104fda:	7f 32                	jg     f010500e <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104fdc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fdf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104fe2:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0104fe5:	8b 11                	mov    (%ecx),%edx
f0104fe7:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104fea:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104fed:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104ff0:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0104ff3:	73 09                	jae    f0104ffe <debuginfo_eip+0x18e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ff5:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104ff8:	03 55 c0             	add    -0x40(%ebp),%edx
f0104ffb:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ffe:	8b 51 08             	mov    0x8(%ecx),%edx
f0105001:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105004:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105006:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105009:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010500c:	eb 0f                	jmp    f010501d <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010500e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105014:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105017:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010501a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010501d:	83 ec 08             	sub    $0x8,%esp
f0105020:	6a 3a                	push   $0x3a
f0105022:	ff 73 08             	pushl  0x8(%ebx)
f0105025:	e8 b1 08 00 00       	call   f01058db <strfind>
f010502a:	2b 43 08             	sub    0x8(%ebx),%eax
f010502d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105030:	83 c4 08             	add    $0x8,%esp
f0105033:	56                   	push   %esi
f0105034:	6a 44                	push   $0x44
f0105036:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105039:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010503c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010503f:	89 f0                	mov    %esi,%eax
f0105041:	e8 28 fd ff ff       	call   f0104d6e <stab_binsearch>
        if(lline <= rline)
f0105046:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105049:	83 c4 10             	add    $0x10,%esp
f010504c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010504f:	0f 8f c1 00 00 00    	jg     f0105116 <debuginfo_eip+0x2a6>
              info->eip_line = stabs[lline].n_desc;
f0105055:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105058:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010505d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105060:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105063:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105066:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105069:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010506c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010506f:	eb 06                	jmp    f0105077 <debuginfo_eip+0x207>
f0105071:	83 e8 01             	sub    $0x1,%eax
f0105074:	83 ea 0c             	sub    $0xc,%edx
f0105077:	39 c7                	cmp    %eax,%edi
f0105079:	7f 2a                	jg     f01050a5 <debuginfo_eip+0x235>
	       && stabs[lline].n_type != N_SOL
f010507b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010507f:	80 f9 84             	cmp    $0x84,%cl
f0105082:	0f 84 9c 00 00 00    	je     f0105124 <debuginfo_eip+0x2b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105088:	80 f9 64             	cmp    $0x64,%cl
f010508b:	75 e4                	jne    f0105071 <debuginfo_eip+0x201>
f010508d:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105091:	74 de                	je     f0105071 <debuginfo_eip+0x201>
f0105093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105096:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105099:	e9 8c 00 00 00       	jmp    f010512a <debuginfo_eip+0x2ba>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010509e:	03 55 c0             	add    -0x40(%ebp),%edx
f01050a1:	89 13                	mov    %edx,(%ebx)
f01050a3:	eb 03                	jmp    f01050a8 <debuginfo_eip+0x238>
f01050a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01050a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01050ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01050ae:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01050b3:	39 f2                	cmp    %esi,%edx
f01050b5:	0f 8d 8b 00 00 00    	jge    f0105146 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
f01050bb:	83 c2 01             	add    $0x1,%edx
f01050be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01050c1:	89 d0                	mov    %edx,%eax
f01050c3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01050c6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01050c9:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01050cc:	eb 04                	jmp    f01050d2 <debuginfo_eip+0x262>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01050ce:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01050d2:	39 c6                	cmp    %eax,%esi
f01050d4:	7e 47                	jle    f010511d <debuginfo_eip+0x2ad>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01050d6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01050da:	83 c0 01             	add    $0x1,%eax
f01050dd:	83 c2 0c             	add    $0xc,%edx
f01050e0:	80 f9 a0             	cmp    $0xa0,%cl
f01050e3:	74 e9                	je     f01050ce <debuginfo_eip+0x25e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01050e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01050ea:	eb 5a                	jmp    f0105146 <debuginfo_eip+0x2d6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f01050ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050f1:	eb 53                	jmp    f0105146 <debuginfo_eip+0x2d6>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
                        return -1;
f01050f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050f8:	eb 4c                	jmp    f0105146 <debuginfo_eip+0x2d6>
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
f01050fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050ff:	eb 45                	jmp    f0105146 <debuginfo_eip+0x2d6>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105106:	eb 3e                	jmp    f0105146 <debuginfo_eip+0x2d6>
f0105108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010510d:	eb 37                	jmp    f0105146 <debuginfo_eip+0x2d6>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010510f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105114:	eb 30                	jmp    f0105146 <debuginfo_eip+0x2d6>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0105116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010511b:	eb 29                	jmp    f0105146 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010511d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105122:	eb 22                	jmp    f0105146 <debuginfo_eip+0x2d6>
f0105124:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105127:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010512a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010512d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105130:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105133:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105136:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105139:	39 c2                	cmp    %eax,%edx
f010513b:	0f 82 5d ff ff ff    	jb     f010509e <debuginfo_eip+0x22e>
f0105141:	e9 62 ff ff ff       	jmp    f01050a8 <debuginfo_eip+0x238>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0105146:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105149:	5b                   	pop    %ebx
f010514a:	5e                   	pop    %esi
f010514b:	5f                   	pop    %edi
f010514c:	5d                   	pop    %ebp
f010514d:	c3                   	ret    

f010514e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010514e:	55                   	push   %ebp
f010514f:	89 e5                	mov    %esp,%ebp
f0105151:	57                   	push   %edi
f0105152:	56                   	push   %esi
f0105153:	53                   	push   %ebx
f0105154:	83 ec 1c             	sub    $0x1c,%esp
f0105157:	89 c7                	mov    %eax,%edi
f0105159:	89 d6                	mov    %edx,%esi
f010515b:	8b 45 08             	mov    0x8(%ebp),%eax
f010515e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105161:	89 d1                	mov    %edx,%ecx
f0105163:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105166:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105169:	8b 45 10             	mov    0x10(%ebp),%eax
f010516c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010516f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105172:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105179:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f010517c:	72 05                	jb     f0105183 <printnum+0x35>
f010517e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105181:	77 3e                	ja     f01051c1 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105183:	83 ec 0c             	sub    $0xc,%esp
f0105186:	ff 75 18             	pushl  0x18(%ebp)
f0105189:	83 eb 01             	sub    $0x1,%ebx
f010518c:	53                   	push   %ebx
f010518d:	50                   	push   %eax
f010518e:	83 ec 08             	sub    $0x8,%esp
f0105191:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105194:	ff 75 e0             	pushl  -0x20(%ebp)
f0105197:	ff 75 dc             	pushl  -0x24(%ebp)
f010519a:	ff 75 d8             	pushl  -0x28(%ebp)
f010519d:	e8 9e 1a 00 00       	call   f0106c40 <__udivdi3>
f01051a2:	83 c4 18             	add    $0x18,%esp
f01051a5:	52                   	push   %edx
f01051a6:	50                   	push   %eax
f01051a7:	89 f2                	mov    %esi,%edx
f01051a9:	89 f8                	mov    %edi,%eax
f01051ab:	e8 9e ff ff ff       	call   f010514e <printnum>
f01051b0:	83 c4 20             	add    $0x20,%esp
f01051b3:	eb 13                	jmp    f01051c8 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01051b5:	83 ec 08             	sub    $0x8,%esp
f01051b8:	56                   	push   %esi
f01051b9:	ff 75 18             	pushl  0x18(%ebp)
f01051bc:	ff d7                	call   *%edi
f01051be:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01051c1:	83 eb 01             	sub    $0x1,%ebx
f01051c4:	85 db                	test   %ebx,%ebx
f01051c6:	7f ed                	jg     f01051b5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01051c8:	83 ec 08             	sub    $0x8,%esp
f01051cb:	56                   	push   %esi
f01051cc:	83 ec 04             	sub    $0x4,%esp
f01051cf:	ff 75 e4             	pushl  -0x1c(%ebp)
f01051d2:	ff 75 e0             	pushl  -0x20(%ebp)
f01051d5:	ff 75 dc             	pushl  -0x24(%ebp)
f01051d8:	ff 75 d8             	pushl  -0x28(%ebp)
f01051db:	e8 90 1b 00 00       	call   f0106d70 <__umoddi3>
f01051e0:	83 c4 14             	add    $0x14,%esp
f01051e3:	0f be 80 8e 86 10 f0 	movsbl -0xfef7972(%eax),%eax
f01051ea:	50                   	push   %eax
f01051eb:	ff d7                	call   *%edi
f01051ed:	83 c4 10             	add    $0x10,%esp
}
f01051f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051f3:	5b                   	pop    %ebx
f01051f4:	5e                   	pop    %esi
f01051f5:	5f                   	pop    %edi
f01051f6:	5d                   	pop    %ebp
f01051f7:	c3                   	ret    

f01051f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01051f8:	55                   	push   %ebp
f01051f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01051fb:	83 fa 01             	cmp    $0x1,%edx
f01051fe:	7e 0e                	jle    f010520e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105200:	8b 10                	mov    (%eax),%edx
f0105202:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105205:	89 08                	mov    %ecx,(%eax)
f0105207:	8b 02                	mov    (%edx),%eax
f0105209:	8b 52 04             	mov    0x4(%edx),%edx
f010520c:	eb 22                	jmp    f0105230 <getuint+0x38>
	else if (lflag)
f010520e:	85 d2                	test   %edx,%edx
f0105210:	74 10                	je     f0105222 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105212:	8b 10                	mov    (%eax),%edx
f0105214:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105217:	89 08                	mov    %ecx,(%eax)
f0105219:	8b 02                	mov    (%edx),%eax
f010521b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105220:	eb 0e                	jmp    f0105230 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105222:	8b 10                	mov    (%eax),%edx
f0105224:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105227:	89 08                	mov    %ecx,(%eax)
f0105229:	8b 02                	mov    (%edx),%eax
f010522b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105230:	5d                   	pop    %ebp
f0105231:	c3                   	ret    

f0105232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105232:	55                   	push   %ebp
f0105233:	89 e5                	mov    %esp,%ebp
f0105235:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105238:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010523c:	8b 10                	mov    (%eax),%edx
f010523e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105241:	73 0a                	jae    f010524d <sprintputch+0x1b>
		*b->buf++ = ch;
f0105243:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105246:	89 08                	mov    %ecx,(%eax)
f0105248:	8b 45 08             	mov    0x8(%ebp),%eax
f010524b:	88 02                	mov    %al,(%edx)
}
f010524d:	5d                   	pop    %ebp
f010524e:	c3                   	ret    

f010524f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010524f:	55                   	push   %ebp
f0105250:	89 e5                	mov    %esp,%ebp
f0105252:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105258:	50                   	push   %eax
f0105259:	ff 75 10             	pushl  0x10(%ebp)
f010525c:	ff 75 0c             	pushl  0xc(%ebp)
f010525f:	ff 75 08             	pushl  0x8(%ebp)
f0105262:	e8 05 00 00 00       	call   f010526c <vprintfmt>
	va_end(ap);
f0105267:	83 c4 10             	add    $0x10,%esp
}
f010526a:	c9                   	leave  
f010526b:	c3                   	ret    

f010526c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010526c:	55                   	push   %ebp
f010526d:	89 e5                	mov    %esp,%ebp
f010526f:	57                   	push   %edi
f0105270:	56                   	push   %esi
f0105271:	53                   	push   %ebx
f0105272:	83 ec 2c             	sub    $0x2c,%esp
f0105275:	8b 75 08             	mov    0x8(%ebp),%esi
f0105278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010527b:	8b 7d 10             	mov    0x10(%ebp),%edi
f010527e:	eb 12                	jmp    f0105292 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105280:	85 c0                	test   %eax,%eax
f0105282:	0f 84 90 03 00 00    	je     f0105618 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0105288:	83 ec 08             	sub    $0x8,%esp
f010528b:	53                   	push   %ebx
f010528c:	50                   	push   %eax
f010528d:	ff d6                	call   *%esi
f010528f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105292:	83 c7 01             	add    $0x1,%edi
f0105295:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105299:	83 f8 25             	cmp    $0x25,%eax
f010529c:	75 e2                	jne    f0105280 <vprintfmt+0x14>
f010529e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01052a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01052a9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01052b0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01052b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01052bc:	eb 07                	jmp    f01052c5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052be:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01052c1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052c5:	8d 47 01             	lea    0x1(%edi),%eax
f01052c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01052cb:	0f b6 07             	movzbl (%edi),%eax
f01052ce:	0f b6 c8             	movzbl %al,%ecx
f01052d1:	83 e8 23             	sub    $0x23,%eax
f01052d4:	3c 55                	cmp    $0x55,%al
f01052d6:	0f 87 21 03 00 00    	ja     f01055fd <vprintfmt+0x391>
f01052dc:	0f b6 c0             	movzbl %al,%eax
f01052df:	ff 24 85 c0 87 10 f0 	jmp    *-0xfef7840(,%eax,4)
f01052e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01052e9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01052ed:	eb d6                	jmp    f01052c5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01052fa:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01052fd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105301:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105304:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105307:	83 fa 09             	cmp    $0x9,%edx
f010530a:	77 39                	ja     f0105345 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010530c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010530f:	eb e9                	jmp    f01052fa <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105311:	8b 45 14             	mov    0x14(%ebp),%eax
f0105314:	8d 48 04             	lea    0x4(%eax),%ecx
f0105317:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010531a:	8b 00                	mov    (%eax),%eax
f010531c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010531f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105322:	eb 27                	jmp    f010534b <vprintfmt+0xdf>
f0105324:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105327:	85 c0                	test   %eax,%eax
f0105329:	b9 00 00 00 00       	mov    $0x0,%ecx
f010532e:	0f 49 c8             	cmovns %eax,%ecx
f0105331:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105337:	eb 8c                	jmp    f01052c5 <vprintfmt+0x59>
f0105339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010533c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105343:	eb 80                	jmp    f01052c5 <vprintfmt+0x59>
f0105345:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105348:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010534b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010534f:	0f 89 70 ff ff ff    	jns    f01052c5 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105355:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105358:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010535b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105362:	e9 5e ff ff ff       	jmp    f01052c5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105367:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010536a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010536d:	e9 53 ff ff ff       	jmp    f01052c5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105372:	8b 45 14             	mov    0x14(%ebp),%eax
f0105375:	8d 50 04             	lea    0x4(%eax),%edx
f0105378:	89 55 14             	mov    %edx,0x14(%ebp)
f010537b:	83 ec 08             	sub    $0x8,%esp
f010537e:	53                   	push   %ebx
f010537f:	ff 30                	pushl  (%eax)
f0105381:	ff d6                	call   *%esi
			break;
f0105383:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105389:	e9 04 ff ff ff       	jmp    f0105292 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010538e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105391:	8d 50 04             	lea    0x4(%eax),%edx
f0105394:	89 55 14             	mov    %edx,0x14(%ebp)
f0105397:	8b 00                	mov    (%eax),%eax
f0105399:	99                   	cltd   
f010539a:	31 d0                	xor    %edx,%eax
f010539c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010539e:	83 f8 0f             	cmp    $0xf,%eax
f01053a1:	7f 0b                	jg     f01053ae <vprintfmt+0x142>
f01053a3:	8b 14 85 40 89 10 f0 	mov    -0xfef76c0(,%eax,4),%edx
f01053aa:	85 d2                	test   %edx,%edx
f01053ac:	75 18                	jne    f01053c6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01053ae:	50                   	push   %eax
f01053af:	68 a6 86 10 f0       	push   $0xf01086a6
f01053b4:	53                   	push   %ebx
f01053b5:	56                   	push   %esi
f01053b6:	e8 94 fe ff ff       	call   f010524f <printfmt>
f01053bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01053c1:	e9 cc fe ff ff       	jmp    f0105292 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01053c6:	52                   	push   %edx
f01053c7:	68 16 75 10 f0       	push   $0xf0107516
f01053cc:	53                   	push   %ebx
f01053cd:	56                   	push   %esi
f01053ce:	e8 7c fe ff ff       	call   f010524f <printfmt>
f01053d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053d9:	e9 b4 fe ff ff       	jmp    f0105292 <vprintfmt+0x26>
f01053de:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01053e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01053e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ea:	8d 50 04             	lea    0x4(%eax),%edx
f01053ed:	89 55 14             	mov    %edx,0x14(%ebp)
f01053f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01053f2:	85 ff                	test   %edi,%edi
f01053f4:	ba 9f 86 10 f0       	mov    $0xf010869f,%edx
f01053f9:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f01053fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105400:	0f 84 92 00 00 00    	je     f0105498 <vprintfmt+0x22c>
f0105406:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010540a:	0f 8e 96 00 00 00    	jle    f01054a6 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105410:	83 ec 08             	sub    $0x8,%esp
f0105413:	51                   	push   %ecx
f0105414:	57                   	push   %edi
f0105415:	e8 77 03 00 00       	call   f0105791 <strnlen>
f010541a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010541d:	29 c1                	sub    %eax,%ecx
f010541f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105422:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105425:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105429:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010542c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010542f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105431:	eb 0f                	jmp    f0105442 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105433:	83 ec 08             	sub    $0x8,%esp
f0105436:	53                   	push   %ebx
f0105437:	ff 75 e0             	pushl  -0x20(%ebp)
f010543a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010543c:	83 ef 01             	sub    $0x1,%edi
f010543f:	83 c4 10             	add    $0x10,%esp
f0105442:	85 ff                	test   %edi,%edi
f0105444:	7f ed                	jg     f0105433 <vprintfmt+0x1c7>
f0105446:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105449:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010544c:	85 c9                	test   %ecx,%ecx
f010544e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105453:	0f 49 c1             	cmovns %ecx,%eax
f0105456:	29 c1                	sub    %eax,%ecx
f0105458:	89 75 08             	mov    %esi,0x8(%ebp)
f010545b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010545e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105461:	89 cb                	mov    %ecx,%ebx
f0105463:	eb 4d                	jmp    f01054b2 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105465:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105469:	74 1b                	je     f0105486 <vprintfmt+0x21a>
f010546b:	0f be c0             	movsbl %al,%eax
f010546e:	83 e8 20             	sub    $0x20,%eax
f0105471:	83 f8 5e             	cmp    $0x5e,%eax
f0105474:	76 10                	jbe    f0105486 <vprintfmt+0x21a>
					putch('?', putdat);
f0105476:	83 ec 08             	sub    $0x8,%esp
f0105479:	ff 75 0c             	pushl  0xc(%ebp)
f010547c:	6a 3f                	push   $0x3f
f010547e:	ff 55 08             	call   *0x8(%ebp)
f0105481:	83 c4 10             	add    $0x10,%esp
f0105484:	eb 0d                	jmp    f0105493 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0105486:	83 ec 08             	sub    $0x8,%esp
f0105489:	ff 75 0c             	pushl  0xc(%ebp)
f010548c:	52                   	push   %edx
f010548d:	ff 55 08             	call   *0x8(%ebp)
f0105490:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105493:	83 eb 01             	sub    $0x1,%ebx
f0105496:	eb 1a                	jmp    f01054b2 <vprintfmt+0x246>
f0105498:	89 75 08             	mov    %esi,0x8(%ebp)
f010549b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010549e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01054a4:	eb 0c                	jmp    f01054b2 <vprintfmt+0x246>
f01054a6:	89 75 08             	mov    %esi,0x8(%ebp)
f01054a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01054ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01054b2:	83 c7 01             	add    $0x1,%edi
f01054b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054b9:	0f be d0             	movsbl %al,%edx
f01054bc:	85 d2                	test   %edx,%edx
f01054be:	74 23                	je     f01054e3 <vprintfmt+0x277>
f01054c0:	85 f6                	test   %esi,%esi
f01054c2:	78 a1                	js     f0105465 <vprintfmt+0x1f9>
f01054c4:	83 ee 01             	sub    $0x1,%esi
f01054c7:	79 9c                	jns    f0105465 <vprintfmt+0x1f9>
f01054c9:	89 df                	mov    %ebx,%edi
f01054cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01054ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054d1:	eb 18                	jmp    f01054eb <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01054d3:	83 ec 08             	sub    $0x8,%esp
f01054d6:	53                   	push   %ebx
f01054d7:	6a 20                	push   $0x20
f01054d9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01054db:	83 ef 01             	sub    $0x1,%edi
f01054de:	83 c4 10             	add    $0x10,%esp
f01054e1:	eb 08                	jmp    f01054eb <vprintfmt+0x27f>
f01054e3:	89 df                	mov    %ebx,%edi
f01054e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01054e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054eb:	85 ff                	test   %edi,%edi
f01054ed:	7f e4                	jg     f01054d3 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054f2:	e9 9b fd ff ff       	jmp    f0105292 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01054f7:	83 fa 01             	cmp    $0x1,%edx
f01054fa:	7e 16                	jle    f0105512 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f01054fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ff:	8d 50 08             	lea    0x8(%eax),%edx
f0105502:	89 55 14             	mov    %edx,0x14(%ebp)
f0105505:	8b 50 04             	mov    0x4(%eax),%edx
f0105508:	8b 00                	mov    (%eax),%eax
f010550a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010550d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105510:	eb 32                	jmp    f0105544 <vprintfmt+0x2d8>
	else if (lflag)
f0105512:	85 d2                	test   %edx,%edx
f0105514:	74 18                	je     f010552e <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f0105516:	8b 45 14             	mov    0x14(%ebp),%eax
f0105519:	8d 50 04             	lea    0x4(%eax),%edx
f010551c:	89 55 14             	mov    %edx,0x14(%ebp)
f010551f:	8b 00                	mov    (%eax),%eax
f0105521:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105524:	89 c1                	mov    %eax,%ecx
f0105526:	c1 f9 1f             	sar    $0x1f,%ecx
f0105529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010552c:	eb 16                	jmp    f0105544 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f010552e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105531:	8d 50 04             	lea    0x4(%eax),%edx
f0105534:	89 55 14             	mov    %edx,0x14(%ebp)
f0105537:	8b 00                	mov    (%eax),%eax
f0105539:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010553c:	89 c1                	mov    %eax,%ecx
f010553e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105541:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105544:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105547:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010554a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010554f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105553:	79 74                	jns    f01055c9 <vprintfmt+0x35d>
				putch('-', putdat);
f0105555:	83 ec 08             	sub    $0x8,%esp
f0105558:	53                   	push   %ebx
f0105559:	6a 2d                	push   $0x2d
f010555b:	ff d6                	call   *%esi
				num = -(long long) num;
f010555d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105560:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105563:	f7 d8                	neg    %eax
f0105565:	83 d2 00             	adc    $0x0,%edx
f0105568:	f7 da                	neg    %edx
f010556a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010556d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105572:	eb 55                	jmp    f01055c9 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105574:	8d 45 14             	lea    0x14(%ebp),%eax
f0105577:	e8 7c fc ff ff       	call   f01051f8 <getuint>
			base = 10;
f010557c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105581:	eb 46                	jmp    f01055c9 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105583:	8d 45 14             	lea    0x14(%ebp),%eax
f0105586:	e8 6d fc ff ff       	call   f01051f8 <getuint>
                        base = 8;
f010558b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0105590:	eb 37                	jmp    f01055c9 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f0105592:	83 ec 08             	sub    $0x8,%esp
f0105595:	53                   	push   %ebx
f0105596:	6a 30                	push   $0x30
f0105598:	ff d6                	call   *%esi
			putch('x', putdat);
f010559a:	83 c4 08             	add    $0x8,%esp
f010559d:	53                   	push   %ebx
f010559e:	6a 78                	push   $0x78
f01055a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01055a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01055a5:	8d 50 04             	lea    0x4(%eax),%edx
f01055a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01055ab:	8b 00                	mov    (%eax),%eax
f01055ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01055b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01055b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01055ba:	eb 0d                	jmp    f01055c9 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01055bc:	8d 45 14             	lea    0x14(%ebp),%eax
f01055bf:	e8 34 fc ff ff       	call   f01051f8 <getuint>
			base = 16;
f01055c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01055c9:	83 ec 0c             	sub    $0xc,%esp
f01055cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01055d0:	57                   	push   %edi
f01055d1:	ff 75 e0             	pushl  -0x20(%ebp)
f01055d4:	51                   	push   %ecx
f01055d5:	52                   	push   %edx
f01055d6:	50                   	push   %eax
f01055d7:	89 da                	mov    %ebx,%edx
f01055d9:	89 f0                	mov    %esi,%eax
f01055db:	e8 6e fb ff ff       	call   f010514e <printnum>
			break;
f01055e0:	83 c4 20             	add    $0x20,%esp
f01055e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055e6:	e9 a7 fc ff ff       	jmp    f0105292 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01055eb:	83 ec 08             	sub    $0x8,%esp
f01055ee:	53                   	push   %ebx
f01055ef:	51                   	push   %ecx
f01055f0:	ff d6                	call   *%esi
			break;
f01055f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01055f8:	e9 95 fc ff ff       	jmp    f0105292 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01055fd:	83 ec 08             	sub    $0x8,%esp
f0105600:	53                   	push   %ebx
f0105601:	6a 25                	push   $0x25
f0105603:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105605:	83 c4 10             	add    $0x10,%esp
f0105608:	eb 03                	jmp    f010560d <vprintfmt+0x3a1>
f010560a:	83 ef 01             	sub    $0x1,%edi
f010560d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105611:	75 f7                	jne    f010560a <vprintfmt+0x39e>
f0105613:	e9 7a fc ff ff       	jmp    f0105292 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105618:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010561b:	5b                   	pop    %ebx
f010561c:	5e                   	pop    %esi
f010561d:	5f                   	pop    %edi
f010561e:	5d                   	pop    %ebp
f010561f:	c3                   	ret    

f0105620 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105620:	55                   	push   %ebp
f0105621:	89 e5                	mov    %esp,%ebp
f0105623:	83 ec 18             	sub    $0x18,%esp
f0105626:	8b 45 08             	mov    0x8(%ebp),%eax
f0105629:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010562c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010562f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105633:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010563d:	85 c0                	test   %eax,%eax
f010563f:	74 26                	je     f0105667 <vsnprintf+0x47>
f0105641:	85 d2                	test   %edx,%edx
f0105643:	7e 22                	jle    f0105667 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105645:	ff 75 14             	pushl  0x14(%ebp)
f0105648:	ff 75 10             	pushl  0x10(%ebp)
f010564b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010564e:	50                   	push   %eax
f010564f:	68 32 52 10 f0       	push   $0xf0105232
f0105654:	e8 13 fc ff ff       	call   f010526c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105659:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010565c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010565f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105662:	83 c4 10             	add    $0x10,%esp
f0105665:	eb 05                	jmp    f010566c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010566c:	c9                   	leave  
f010566d:	c3                   	ret    

f010566e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010566e:	55                   	push   %ebp
f010566f:	89 e5                	mov    %esp,%ebp
f0105671:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105674:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105677:	50                   	push   %eax
f0105678:	ff 75 10             	pushl  0x10(%ebp)
f010567b:	ff 75 0c             	pushl  0xc(%ebp)
f010567e:	ff 75 08             	pushl  0x8(%ebp)
f0105681:	e8 9a ff ff ff       	call   f0105620 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105686:	c9                   	leave  
f0105687:	c3                   	ret    

f0105688 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105688:	55                   	push   %ebp
f0105689:	89 e5                	mov    %esp,%ebp
f010568b:	57                   	push   %edi
f010568c:	56                   	push   %esi
f010568d:	53                   	push   %ebx
f010568e:	83 ec 0c             	sub    $0xc,%esp
f0105691:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105694:	85 c0                	test   %eax,%eax
f0105696:	74 11                	je     f01056a9 <readline+0x21>
		cprintf("%s", prompt);
f0105698:	83 ec 08             	sub    $0x8,%esp
f010569b:	50                   	push   %eax
f010569c:	68 16 75 10 f0       	push   $0xf0107516
f01056a1:	e8 b7 e0 ff ff       	call   f010375d <cprintf>
f01056a6:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01056a9:	83 ec 0c             	sub    $0xc,%esp
f01056ac:	6a 00                	push   $0x0
f01056ae:	e8 01 b1 ff ff       	call   f01007b4 <iscons>
f01056b3:	89 c7                	mov    %eax,%edi
f01056b5:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01056b8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01056bd:	e8 e1 b0 ff ff       	call   f01007a3 <getchar>
f01056c2:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01056c4:	85 c0                	test   %eax,%eax
f01056c6:	79 29                	jns    f01056f1 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01056c8:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01056cd:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01056d0:	0f 84 9b 00 00 00    	je     f0105771 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01056d6:	83 ec 08             	sub    $0x8,%esp
f01056d9:	53                   	push   %ebx
f01056da:	68 9f 89 10 f0       	push   $0xf010899f
f01056df:	e8 79 e0 ff ff       	call   f010375d <cprintf>
f01056e4:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01056e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ec:	e9 80 00 00 00       	jmp    f0105771 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01056f1:	83 f8 7f             	cmp    $0x7f,%eax
f01056f4:	0f 94 c2             	sete   %dl
f01056f7:	83 f8 08             	cmp    $0x8,%eax
f01056fa:	0f 94 c0             	sete   %al
f01056fd:	08 c2                	or     %al,%dl
f01056ff:	74 1a                	je     f010571b <readline+0x93>
f0105701:	85 f6                	test   %esi,%esi
f0105703:	7e 16                	jle    f010571b <readline+0x93>
			if (echoing)
f0105705:	85 ff                	test   %edi,%edi
f0105707:	74 0d                	je     f0105716 <readline+0x8e>
				cputchar('\b');
f0105709:	83 ec 0c             	sub    $0xc,%esp
f010570c:	6a 08                	push   $0x8
f010570e:	e8 80 b0 ff ff       	call   f0100793 <cputchar>
f0105713:	83 c4 10             	add    $0x10,%esp
			i--;
f0105716:	83 ee 01             	sub    $0x1,%esi
f0105719:	eb a2                	jmp    f01056bd <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010571b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105721:	7f 23                	jg     f0105746 <readline+0xbe>
f0105723:	83 fb 1f             	cmp    $0x1f,%ebx
f0105726:	7e 1e                	jle    f0105746 <readline+0xbe>
			if (echoing)
f0105728:	85 ff                	test   %edi,%edi
f010572a:	74 0c                	je     f0105738 <readline+0xb0>
				cputchar(c);
f010572c:	83 ec 0c             	sub    $0xc,%esp
f010572f:	53                   	push   %ebx
f0105730:	e8 5e b0 ff ff       	call   f0100793 <cputchar>
f0105735:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105738:	88 9e c0 8a 2a f0    	mov    %bl,-0xfd57540(%esi)
f010573e:	8d 76 01             	lea    0x1(%esi),%esi
f0105741:	e9 77 ff ff ff       	jmp    f01056bd <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105746:	83 fb 0d             	cmp    $0xd,%ebx
f0105749:	74 09                	je     f0105754 <readline+0xcc>
f010574b:	83 fb 0a             	cmp    $0xa,%ebx
f010574e:	0f 85 69 ff ff ff    	jne    f01056bd <readline+0x35>
			if (echoing)
f0105754:	85 ff                	test   %edi,%edi
f0105756:	74 0d                	je     f0105765 <readline+0xdd>
				cputchar('\n');
f0105758:	83 ec 0c             	sub    $0xc,%esp
f010575b:	6a 0a                	push   $0xa
f010575d:	e8 31 b0 ff ff       	call   f0100793 <cputchar>
f0105762:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105765:	c6 86 c0 8a 2a f0 00 	movb   $0x0,-0xfd57540(%esi)
			return buf;
f010576c:	b8 c0 8a 2a f0       	mov    $0xf02a8ac0,%eax
		}
	}
}
f0105771:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105774:	5b                   	pop    %ebx
f0105775:	5e                   	pop    %esi
f0105776:	5f                   	pop    %edi
f0105777:	5d                   	pop    %ebp
f0105778:	c3                   	ret    

f0105779 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105779:	55                   	push   %ebp
f010577a:	89 e5                	mov    %esp,%ebp
f010577c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010577f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105784:	eb 03                	jmp    f0105789 <strlen+0x10>
		n++;
f0105786:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105789:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010578d:	75 f7                	jne    f0105786 <strlen+0xd>
		n++;
	return n;
}
f010578f:	5d                   	pop    %ebp
f0105790:	c3                   	ret    

f0105791 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105791:	55                   	push   %ebp
f0105792:	89 e5                	mov    %esp,%ebp
f0105794:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105797:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010579a:	ba 00 00 00 00       	mov    $0x0,%edx
f010579f:	eb 03                	jmp    f01057a4 <strnlen+0x13>
		n++;
f01057a1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057a4:	39 c2                	cmp    %eax,%edx
f01057a6:	74 08                	je     f01057b0 <strnlen+0x1f>
f01057a8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01057ac:	75 f3                	jne    f01057a1 <strnlen+0x10>
f01057ae:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01057b0:	5d                   	pop    %ebp
f01057b1:	c3                   	ret    

f01057b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01057b2:	55                   	push   %ebp
f01057b3:	89 e5                	mov    %esp,%ebp
f01057b5:	53                   	push   %ebx
f01057b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01057bc:	89 c2                	mov    %eax,%edx
f01057be:	83 c2 01             	add    $0x1,%edx
f01057c1:	83 c1 01             	add    $0x1,%ecx
f01057c4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01057c8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01057cb:	84 db                	test   %bl,%bl
f01057cd:	75 ef                	jne    f01057be <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01057cf:	5b                   	pop    %ebx
f01057d0:	5d                   	pop    %ebp
f01057d1:	c3                   	ret    

f01057d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01057d2:	55                   	push   %ebp
f01057d3:	89 e5                	mov    %esp,%ebp
f01057d5:	53                   	push   %ebx
f01057d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01057d9:	53                   	push   %ebx
f01057da:	e8 9a ff ff ff       	call   f0105779 <strlen>
f01057df:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01057e2:	ff 75 0c             	pushl  0xc(%ebp)
f01057e5:	01 d8                	add    %ebx,%eax
f01057e7:	50                   	push   %eax
f01057e8:	e8 c5 ff ff ff       	call   f01057b2 <strcpy>
	return dst;
}
f01057ed:	89 d8                	mov    %ebx,%eax
f01057ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057f2:	c9                   	leave  
f01057f3:	c3                   	ret    

f01057f4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01057f4:	55                   	push   %ebp
f01057f5:	89 e5                	mov    %esp,%ebp
f01057f7:	56                   	push   %esi
f01057f8:	53                   	push   %ebx
f01057f9:	8b 75 08             	mov    0x8(%ebp),%esi
f01057fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01057ff:	89 f3                	mov    %esi,%ebx
f0105801:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105804:	89 f2                	mov    %esi,%edx
f0105806:	eb 0f                	jmp    f0105817 <strncpy+0x23>
		*dst++ = *src;
f0105808:	83 c2 01             	add    $0x1,%edx
f010580b:	0f b6 01             	movzbl (%ecx),%eax
f010580e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105811:	80 39 01             	cmpb   $0x1,(%ecx)
f0105814:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105817:	39 da                	cmp    %ebx,%edx
f0105819:	75 ed                	jne    f0105808 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010581b:	89 f0                	mov    %esi,%eax
f010581d:	5b                   	pop    %ebx
f010581e:	5e                   	pop    %esi
f010581f:	5d                   	pop    %ebp
f0105820:	c3                   	ret    

f0105821 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105821:	55                   	push   %ebp
f0105822:	89 e5                	mov    %esp,%ebp
f0105824:	56                   	push   %esi
f0105825:	53                   	push   %ebx
f0105826:	8b 75 08             	mov    0x8(%ebp),%esi
f0105829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010582c:	8b 55 10             	mov    0x10(%ebp),%edx
f010582f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105831:	85 d2                	test   %edx,%edx
f0105833:	74 21                	je     f0105856 <strlcpy+0x35>
f0105835:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105839:	89 f2                	mov    %esi,%edx
f010583b:	eb 09                	jmp    f0105846 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010583d:	83 c2 01             	add    $0x1,%edx
f0105840:	83 c1 01             	add    $0x1,%ecx
f0105843:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105846:	39 c2                	cmp    %eax,%edx
f0105848:	74 09                	je     f0105853 <strlcpy+0x32>
f010584a:	0f b6 19             	movzbl (%ecx),%ebx
f010584d:	84 db                	test   %bl,%bl
f010584f:	75 ec                	jne    f010583d <strlcpy+0x1c>
f0105851:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105853:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105856:	29 f0                	sub    %esi,%eax
}
f0105858:	5b                   	pop    %ebx
f0105859:	5e                   	pop    %esi
f010585a:	5d                   	pop    %ebp
f010585b:	c3                   	ret    

f010585c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010585c:	55                   	push   %ebp
f010585d:	89 e5                	mov    %esp,%ebp
f010585f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105862:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105865:	eb 06                	jmp    f010586d <strcmp+0x11>
		p++, q++;
f0105867:	83 c1 01             	add    $0x1,%ecx
f010586a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010586d:	0f b6 01             	movzbl (%ecx),%eax
f0105870:	84 c0                	test   %al,%al
f0105872:	74 04                	je     f0105878 <strcmp+0x1c>
f0105874:	3a 02                	cmp    (%edx),%al
f0105876:	74 ef                	je     f0105867 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105878:	0f b6 c0             	movzbl %al,%eax
f010587b:	0f b6 12             	movzbl (%edx),%edx
f010587e:	29 d0                	sub    %edx,%eax
}
f0105880:	5d                   	pop    %ebp
f0105881:	c3                   	ret    

f0105882 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105882:	55                   	push   %ebp
f0105883:	89 e5                	mov    %esp,%ebp
f0105885:	53                   	push   %ebx
f0105886:	8b 45 08             	mov    0x8(%ebp),%eax
f0105889:	8b 55 0c             	mov    0xc(%ebp),%edx
f010588c:	89 c3                	mov    %eax,%ebx
f010588e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105891:	eb 06                	jmp    f0105899 <strncmp+0x17>
		n--, p++, q++;
f0105893:	83 c0 01             	add    $0x1,%eax
f0105896:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105899:	39 d8                	cmp    %ebx,%eax
f010589b:	74 15                	je     f01058b2 <strncmp+0x30>
f010589d:	0f b6 08             	movzbl (%eax),%ecx
f01058a0:	84 c9                	test   %cl,%cl
f01058a2:	74 04                	je     f01058a8 <strncmp+0x26>
f01058a4:	3a 0a                	cmp    (%edx),%cl
f01058a6:	74 eb                	je     f0105893 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01058a8:	0f b6 00             	movzbl (%eax),%eax
f01058ab:	0f b6 12             	movzbl (%edx),%edx
f01058ae:	29 d0                	sub    %edx,%eax
f01058b0:	eb 05                	jmp    f01058b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01058b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01058b7:	5b                   	pop    %ebx
f01058b8:	5d                   	pop    %ebp
f01058b9:	c3                   	ret    

f01058ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01058ba:	55                   	push   %ebp
f01058bb:	89 e5                	mov    %esp,%ebp
f01058bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01058c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058c4:	eb 07                	jmp    f01058cd <strchr+0x13>
		if (*s == c)
f01058c6:	38 ca                	cmp    %cl,%dl
f01058c8:	74 0f                	je     f01058d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01058ca:	83 c0 01             	add    $0x1,%eax
f01058cd:	0f b6 10             	movzbl (%eax),%edx
f01058d0:	84 d2                	test   %dl,%dl
f01058d2:	75 f2                	jne    f01058c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01058d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058d9:	5d                   	pop    %ebp
f01058da:	c3                   	ret    

f01058db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01058db:	55                   	push   %ebp
f01058dc:	89 e5                	mov    %esp,%ebp
f01058de:	8b 45 08             	mov    0x8(%ebp),%eax
f01058e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058e5:	eb 03                	jmp    f01058ea <strfind+0xf>
f01058e7:	83 c0 01             	add    $0x1,%eax
f01058ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01058ed:	84 d2                	test   %dl,%dl
f01058ef:	74 04                	je     f01058f5 <strfind+0x1a>
f01058f1:	38 ca                	cmp    %cl,%dl
f01058f3:	75 f2                	jne    f01058e7 <strfind+0xc>
			break;
	return (char *) s;
}
f01058f5:	5d                   	pop    %ebp
f01058f6:	c3                   	ret    

f01058f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01058f7:	55                   	push   %ebp
f01058f8:	89 e5                	mov    %esp,%ebp
f01058fa:	57                   	push   %edi
f01058fb:	56                   	push   %esi
f01058fc:	53                   	push   %ebx
f01058fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105903:	85 c9                	test   %ecx,%ecx
f0105905:	74 36                	je     f010593d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105907:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010590d:	75 28                	jne    f0105937 <memset+0x40>
f010590f:	f6 c1 03             	test   $0x3,%cl
f0105912:	75 23                	jne    f0105937 <memset+0x40>
		c &= 0xFF;
f0105914:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105918:	89 d3                	mov    %edx,%ebx
f010591a:	c1 e3 08             	shl    $0x8,%ebx
f010591d:	89 d6                	mov    %edx,%esi
f010591f:	c1 e6 18             	shl    $0x18,%esi
f0105922:	89 d0                	mov    %edx,%eax
f0105924:	c1 e0 10             	shl    $0x10,%eax
f0105927:	09 f0                	or     %esi,%eax
f0105929:	09 c2                	or     %eax,%edx
f010592b:	89 d0                	mov    %edx,%eax
f010592d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010592f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105932:	fc                   	cld    
f0105933:	f3 ab                	rep stos %eax,%es:(%edi)
f0105935:	eb 06                	jmp    f010593d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105937:	8b 45 0c             	mov    0xc(%ebp),%eax
f010593a:	fc                   	cld    
f010593b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010593d:	89 f8                	mov    %edi,%eax
f010593f:	5b                   	pop    %ebx
f0105940:	5e                   	pop    %esi
f0105941:	5f                   	pop    %edi
f0105942:	5d                   	pop    %ebp
f0105943:	c3                   	ret    

f0105944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105944:	55                   	push   %ebp
f0105945:	89 e5                	mov    %esp,%ebp
f0105947:	57                   	push   %edi
f0105948:	56                   	push   %esi
f0105949:	8b 45 08             	mov    0x8(%ebp),%eax
f010594c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010594f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105952:	39 c6                	cmp    %eax,%esi
f0105954:	73 35                	jae    f010598b <memmove+0x47>
f0105956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105959:	39 d0                	cmp    %edx,%eax
f010595b:	73 2e                	jae    f010598b <memmove+0x47>
		s += n;
		d += n;
f010595d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105960:	89 d6                	mov    %edx,%esi
f0105962:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105964:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010596a:	75 13                	jne    f010597f <memmove+0x3b>
f010596c:	f6 c1 03             	test   $0x3,%cl
f010596f:	75 0e                	jne    f010597f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105971:	83 ef 04             	sub    $0x4,%edi
f0105974:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105977:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010597a:	fd                   	std    
f010597b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010597d:	eb 09                	jmp    f0105988 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010597f:	83 ef 01             	sub    $0x1,%edi
f0105982:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105985:	fd                   	std    
f0105986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105988:	fc                   	cld    
f0105989:	eb 1d                	jmp    f01059a8 <memmove+0x64>
f010598b:	89 f2                	mov    %esi,%edx
f010598d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010598f:	f6 c2 03             	test   $0x3,%dl
f0105992:	75 0f                	jne    f01059a3 <memmove+0x5f>
f0105994:	f6 c1 03             	test   $0x3,%cl
f0105997:	75 0a                	jne    f01059a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105999:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010599c:	89 c7                	mov    %eax,%edi
f010599e:	fc                   	cld    
f010599f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01059a1:	eb 05                	jmp    f01059a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01059a3:	89 c7                	mov    %eax,%edi
f01059a5:	fc                   	cld    
f01059a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01059a8:	5e                   	pop    %esi
f01059a9:	5f                   	pop    %edi
f01059aa:	5d                   	pop    %ebp
f01059ab:	c3                   	ret    

f01059ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01059ac:	55                   	push   %ebp
f01059ad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01059af:	ff 75 10             	pushl  0x10(%ebp)
f01059b2:	ff 75 0c             	pushl  0xc(%ebp)
f01059b5:	ff 75 08             	pushl  0x8(%ebp)
f01059b8:	e8 87 ff ff ff       	call   f0105944 <memmove>
}
f01059bd:	c9                   	leave  
f01059be:	c3                   	ret    

f01059bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01059bf:	55                   	push   %ebp
f01059c0:	89 e5                	mov    %esp,%ebp
f01059c2:	56                   	push   %esi
f01059c3:	53                   	push   %ebx
f01059c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01059c7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059ca:	89 c6                	mov    %eax,%esi
f01059cc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059cf:	eb 1a                	jmp    f01059eb <memcmp+0x2c>
		if (*s1 != *s2)
f01059d1:	0f b6 08             	movzbl (%eax),%ecx
f01059d4:	0f b6 1a             	movzbl (%edx),%ebx
f01059d7:	38 d9                	cmp    %bl,%cl
f01059d9:	74 0a                	je     f01059e5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01059db:	0f b6 c1             	movzbl %cl,%eax
f01059de:	0f b6 db             	movzbl %bl,%ebx
f01059e1:	29 d8                	sub    %ebx,%eax
f01059e3:	eb 0f                	jmp    f01059f4 <memcmp+0x35>
		s1++, s2++;
f01059e5:	83 c0 01             	add    $0x1,%eax
f01059e8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059eb:	39 f0                	cmp    %esi,%eax
f01059ed:	75 e2                	jne    f01059d1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01059ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059f4:	5b                   	pop    %ebx
f01059f5:	5e                   	pop    %esi
f01059f6:	5d                   	pop    %ebp
f01059f7:	c3                   	ret    

f01059f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01059f8:	55                   	push   %ebp
f01059f9:	89 e5                	mov    %esp,%ebp
f01059fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01059fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105a01:	89 c2                	mov    %eax,%edx
f0105a03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105a06:	eb 07                	jmp    f0105a0f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105a08:	38 08                	cmp    %cl,(%eax)
f0105a0a:	74 07                	je     f0105a13 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105a0c:	83 c0 01             	add    $0x1,%eax
f0105a0f:	39 d0                	cmp    %edx,%eax
f0105a11:	72 f5                	jb     f0105a08 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105a13:	5d                   	pop    %ebp
f0105a14:	c3                   	ret    

f0105a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105a15:	55                   	push   %ebp
f0105a16:	89 e5                	mov    %esp,%ebp
f0105a18:	57                   	push   %edi
f0105a19:	56                   	push   %esi
f0105a1a:	53                   	push   %ebx
f0105a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105a21:	eb 03                	jmp    f0105a26 <strtol+0x11>
		s++;
f0105a23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105a26:	0f b6 01             	movzbl (%ecx),%eax
f0105a29:	3c 09                	cmp    $0x9,%al
f0105a2b:	74 f6                	je     f0105a23 <strtol+0xe>
f0105a2d:	3c 20                	cmp    $0x20,%al
f0105a2f:	74 f2                	je     f0105a23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105a31:	3c 2b                	cmp    $0x2b,%al
f0105a33:	75 0a                	jne    f0105a3f <strtol+0x2a>
		s++;
f0105a35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105a38:	bf 00 00 00 00       	mov    $0x0,%edi
f0105a3d:	eb 10                	jmp    f0105a4f <strtol+0x3a>
f0105a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105a44:	3c 2d                	cmp    $0x2d,%al
f0105a46:	75 07                	jne    f0105a4f <strtol+0x3a>
		s++, neg = 1;
f0105a48:	8d 49 01             	lea    0x1(%ecx),%ecx
f0105a4b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a4f:	85 db                	test   %ebx,%ebx
f0105a51:	0f 94 c0             	sete   %al
f0105a54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105a5a:	75 19                	jne    f0105a75 <strtol+0x60>
f0105a5c:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a5f:	75 14                	jne    f0105a75 <strtol+0x60>
f0105a61:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105a65:	0f 85 82 00 00 00    	jne    f0105aed <strtol+0xd8>
		s += 2, base = 16;
f0105a6b:	83 c1 02             	add    $0x2,%ecx
f0105a6e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105a73:	eb 16                	jmp    f0105a8b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105a75:	84 c0                	test   %al,%al
f0105a77:	74 12                	je     f0105a8b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105a79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105a7e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a81:	75 08                	jne    f0105a8b <strtol+0x76>
		s++, base = 8;
f0105a83:	83 c1 01             	add    $0x1,%ecx
f0105a86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105a8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105a93:	0f b6 11             	movzbl (%ecx),%edx
f0105a96:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105a99:	89 f3                	mov    %esi,%ebx
f0105a9b:	80 fb 09             	cmp    $0x9,%bl
f0105a9e:	77 08                	ja     f0105aa8 <strtol+0x93>
			dig = *s - '0';
f0105aa0:	0f be d2             	movsbl %dl,%edx
f0105aa3:	83 ea 30             	sub    $0x30,%edx
f0105aa6:	eb 22                	jmp    f0105aca <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0105aa8:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105aab:	89 f3                	mov    %esi,%ebx
f0105aad:	80 fb 19             	cmp    $0x19,%bl
f0105ab0:	77 08                	ja     f0105aba <strtol+0xa5>
			dig = *s - 'a' + 10;
f0105ab2:	0f be d2             	movsbl %dl,%edx
f0105ab5:	83 ea 57             	sub    $0x57,%edx
f0105ab8:	eb 10                	jmp    f0105aca <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0105aba:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105abd:	89 f3                	mov    %esi,%ebx
f0105abf:	80 fb 19             	cmp    $0x19,%bl
f0105ac2:	77 16                	ja     f0105ada <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105ac4:	0f be d2             	movsbl %dl,%edx
f0105ac7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105aca:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105acd:	7d 0f                	jge    f0105ade <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f0105acf:	83 c1 01             	add    $0x1,%ecx
f0105ad2:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ad6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105ad8:	eb b9                	jmp    f0105a93 <strtol+0x7e>
f0105ada:	89 c2                	mov    %eax,%edx
f0105adc:	eb 02                	jmp    f0105ae0 <strtol+0xcb>
f0105ade:	89 c2                	mov    %eax,%edx

	if (endptr)
f0105ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ae4:	74 0d                	je     f0105af3 <strtol+0xde>
		*endptr = (char *) s;
f0105ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ae9:	89 0e                	mov    %ecx,(%esi)
f0105aeb:	eb 06                	jmp    f0105af3 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105aed:	84 c0                	test   %al,%al
f0105aef:	75 92                	jne    f0105a83 <strtol+0x6e>
f0105af1:	eb 98                	jmp    f0105a8b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105af3:	f7 da                	neg    %edx
f0105af5:	85 ff                	test   %edi,%edi
f0105af7:	0f 45 c2             	cmovne %edx,%eax
}
f0105afa:	5b                   	pop    %ebx
f0105afb:	5e                   	pop    %esi
f0105afc:	5f                   	pop    %edi
f0105afd:	5d                   	pop    %ebp
f0105afe:	c3                   	ret    
f0105aff:	90                   	nop

f0105b00 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105b00:	fa                   	cli    

	xorw    %ax, %ax
f0105b01:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105b03:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b05:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b07:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105b09:	0f 01 16             	lgdtl  (%esi)
f0105b0c:	74 70                	je     f0105b7e <mpsearch1+0x3>
	movl    %cr0, %eax
f0105b0e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105b11:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105b15:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105b18:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105b1e:	08 00                	or     %al,(%eax)

f0105b20 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105b20:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105b24:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b26:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b28:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105b2a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105b2e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105b30:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105b32:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105b37:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105b3a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105b3d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105b42:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105b45:	8b 25 d4 8e 2a f0    	mov    0xf02a8ed4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105b4b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105b50:	b8 e1 01 10 f0       	mov    $0xf01001e1,%eax
	call    *%eax
f0105b55:	ff d0                	call   *%eax

f0105b57 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105b57:	eb fe                	jmp    f0105b57 <spin>
f0105b59:	8d 76 00             	lea    0x0(%esi),%esi

f0105b5c <gdt>:
	...
f0105b64:	ff                   	(bad)  
f0105b65:	ff 00                	incl   (%eax)
f0105b67:	00 00                	add    %al,(%eax)
f0105b69:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105b70:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105b74 <gdtdesc>:
f0105b74:	17                   	pop    %ss
f0105b75:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105b7a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105b7a:	90                   	nop

f0105b7b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105b7b:	55                   	push   %ebp
f0105b7c:	89 e5                	mov    %esp,%ebp
f0105b7e:	57                   	push   %edi
f0105b7f:	56                   	push   %esi
f0105b80:	53                   	push   %ebx
f0105b81:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b84:	8b 0d d8 8e 2a f0    	mov    0xf02a8ed8,%ecx
f0105b8a:	89 c3                	mov    %eax,%ebx
f0105b8c:	c1 eb 0c             	shr    $0xc,%ebx
f0105b8f:	39 cb                	cmp    %ecx,%ebx
f0105b91:	72 12                	jb     f0105ba5 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b93:	50                   	push   %eax
f0105b94:	68 24 6f 10 f0       	push   $0xf0106f24
f0105b99:	6a 57                	push   $0x57
f0105b9b:	68 3d 8b 10 f0       	push   $0xf0108b3d
f0105ba0:	e8 9b a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ba5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105bab:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105bad:	89 c2                	mov    %eax,%edx
f0105baf:	c1 ea 0c             	shr    $0xc,%edx
f0105bb2:	39 d1                	cmp    %edx,%ecx
f0105bb4:	77 12                	ja     f0105bc8 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bb6:	50                   	push   %eax
f0105bb7:	68 24 6f 10 f0       	push   $0xf0106f24
f0105bbc:	6a 57                	push   $0x57
f0105bbe:	68 3d 8b 10 f0       	push   $0xf0108b3d
f0105bc3:	e8 78 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105bc8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105bce:	eb 2f                	jmp    f0105bff <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bd0:	83 ec 04             	sub    $0x4,%esp
f0105bd3:	6a 04                	push   $0x4
f0105bd5:	68 4d 8b 10 f0       	push   $0xf0108b4d
f0105bda:	53                   	push   %ebx
f0105bdb:	e8 df fd ff ff       	call   f01059bf <memcmp>
f0105be0:	83 c4 10             	add    $0x10,%esp
f0105be3:	85 c0                	test   %eax,%eax
f0105be5:	75 15                	jne    f0105bfc <mpsearch1+0x81>
f0105be7:	89 da                	mov    %ebx,%edx
f0105be9:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105bec:	0f b6 0a             	movzbl (%edx),%ecx
f0105bef:	01 c8                	add    %ecx,%eax
f0105bf1:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bf4:	39 fa                	cmp    %edi,%edx
f0105bf6:	75 f4                	jne    f0105bec <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bf8:	84 c0                	test   %al,%al
f0105bfa:	74 0e                	je     f0105c0a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105bfc:	83 c3 10             	add    $0x10,%ebx
f0105bff:	39 f3                	cmp    %esi,%ebx
f0105c01:	72 cd                	jb     f0105bd0 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105c03:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c08:	eb 02                	jmp    f0105c0c <mpsearch1+0x91>
f0105c0a:	89 d8                	mov    %ebx,%eax
}
f0105c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c0f:	5b                   	pop    %ebx
f0105c10:	5e                   	pop    %esi
f0105c11:	5f                   	pop    %edi
f0105c12:	5d                   	pop    %ebp
f0105c13:	c3                   	ret    

f0105c14 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105c14:	55                   	push   %ebp
f0105c15:	89 e5                	mov    %esp,%ebp
f0105c17:	57                   	push   %edi
f0105c18:	56                   	push   %esi
f0105c19:	53                   	push   %ebx
f0105c1a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105c1d:	c7 05 e0 93 2a f0 40 	movl   $0xf02a9040,0xf02a93e0
f0105c24:	90 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c27:	83 3d d8 8e 2a f0 00 	cmpl   $0x0,0xf02a8ed8
f0105c2e:	75 16                	jne    f0105c46 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c30:	68 00 04 00 00       	push   $0x400
f0105c35:	68 24 6f 10 f0       	push   $0xf0106f24
f0105c3a:	6a 6f                	push   $0x6f
f0105c3c:	68 3d 8b 10 f0       	push   $0xf0108b3d
f0105c41:	e8 fa a3 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105c46:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105c4d:	85 c0                	test   %eax,%eax
f0105c4f:	74 16                	je     f0105c67 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105c51:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105c54:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c59:	e8 1d ff ff ff       	call   f0105b7b <mpsearch1>
f0105c5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c61:	85 c0                	test   %eax,%eax
f0105c63:	75 3c                	jne    f0105ca1 <mp_init+0x8d>
f0105c65:	eb 20                	jmp    f0105c87 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105c67:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105c6e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105c71:	2d 00 04 00 00       	sub    $0x400,%eax
f0105c76:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c7b:	e8 fb fe ff ff       	call   f0105b7b <mpsearch1>
f0105c80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c83:	85 c0                	test   %eax,%eax
f0105c85:	75 1a                	jne    f0105ca1 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105c87:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c8c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105c91:	e8 e5 fe ff ff       	call   f0105b7b <mpsearch1>
f0105c96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105c99:	85 c0                	test   %eax,%eax
f0105c9b:	0f 84 5a 02 00 00    	je     f0105efb <mp_init+0x2e7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ca4:	8b 70 04             	mov    0x4(%eax),%esi
f0105ca7:	85 f6                	test   %esi,%esi
f0105ca9:	74 06                	je     f0105cb1 <mp_init+0x9d>
f0105cab:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105caf:	74 15                	je     f0105cc6 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105cb1:	83 ec 0c             	sub    $0xc,%esp
f0105cb4:	68 b0 89 10 f0       	push   $0xf01089b0
f0105cb9:	e8 9f da ff ff       	call   f010375d <cprintf>
f0105cbe:	83 c4 10             	add    $0x10,%esp
f0105cc1:	e9 35 02 00 00       	jmp    f0105efb <mp_init+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105cc6:	89 f0                	mov    %esi,%eax
f0105cc8:	c1 e8 0c             	shr    $0xc,%eax
f0105ccb:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0105cd1:	72 15                	jb     f0105ce8 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cd3:	56                   	push   %esi
f0105cd4:	68 24 6f 10 f0       	push   $0xf0106f24
f0105cd9:	68 90 00 00 00       	push   $0x90
f0105cde:	68 3d 8b 10 f0       	push   $0xf0108b3d
f0105ce3:	e8 58 a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ce8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105cee:	83 ec 04             	sub    $0x4,%esp
f0105cf1:	6a 04                	push   $0x4
f0105cf3:	68 52 8b 10 f0       	push   $0xf0108b52
f0105cf8:	53                   	push   %ebx
f0105cf9:	e8 c1 fc ff ff       	call   f01059bf <memcmp>
f0105cfe:	83 c4 10             	add    $0x10,%esp
f0105d01:	85 c0                	test   %eax,%eax
f0105d03:	74 15                	je     f0105d1a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105d05:	83 ec 0c             	sub    $0xc,%esp
f0105d08:	68 e0 89 10 f0       	push   $0xf01089e0
f0105d0d:	e8 4b da ff ff       	call   f010375d <cprintf>
f0105d12:	83 c4 10             	add    $0x10,%esp
f0105d15:	e9 e1 01 00 00       	jmp    f0105efb <mp_init+0x2e7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105d1a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105d1e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105d22:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105d25:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105d2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d2f:	eb 0d                	jmp    f0105d3e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105d31:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105d38:	f0 
f0105d39:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d3b:	83 c0 01             	add    $0x1,%eax
f0105d3e:	39 c7                	cmp    %eax,%edi
f0105d40:	75 ef                	jne    f0105d31 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105d42:	84 d2                	test   %dl,%dl
f0105d44:	74 15                	je     f0105d5b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105d46:	83 ec 0c             	sub    $0xc,%esp
f0105d49:	68 14 8a 10 f0       	push   $0xf0108a14
f0105d4e:	e8 0a da ff ff       	call   f010375d <cprintf>
f0105d53:	83 c4 10             	add    $0x10,%esp
f0105d56:	e9 a0 01 00 00       	jmp    f0105efb <mp_init+0x2e7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105d5b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105d5f:	3c 04                	cmp    $0x4,%al
f0105d61:	74 1d                	je     f0105d80 <mp_init+0x16c>
f0105d63:	3c 01                	cmp    $0x1,%al
f0105d65:	74 19                	je     f0105d80 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105d67:	83 ec 08             	sub    $0x8,%esp
f0105d6a:	0f b6 c0             	movzbl %al,%eax
f0105d6d:	50                   	push   %eax
f0105d6e:	68 38 8a 10 f0       	push   $0xf0108a38
f0105d73:	e8 e5 d9 ff ff       	call   f010375d <cprintf>
f0105d78:	83 c4 10             	add    $0x10,%esp
f0105d7b:	e9 7b 01 00 00       	jmp    f0105efb <mp_init+0x2e7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105d80:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105d84:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105d88:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105d8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d92:	01 ce                	add    %ecx,%esi
f0105d94:	eb 0d                	jmp    f0105da3 <mp_init+0x18f>
		sum += ((uint8_t *)addr)[i];
f0105d96:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105d9d:	f0 
f0105d9e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105da0:	83 c0 01             	add    $0x1,%eax
f0105da3:	39 c7                	cmp    %eax,%edi
f0105da5:	75 ef                	jne    f0105d96 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105da7:	89 d0                	mov    %edx,%eax
f0105da9:	02 43 2a             	add    0x2a(%ebx),%al
f0105dac:	74 15                	je     f0105dc3 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105dae:	83 ec 0c             	sub    $0xc,%esp
f0105db1:	68 58 8a 10 f0       	push   $0xf0108a58
f0105db6:	e8 a2 d9 ff ff       	call   f010375d <cprintf>
f0105dbb:	83 c4 10             	add    $0x10,%esp
f0105dbe:	e9 38 01 00 00       	jmp    f0105efb <mp_init+0x2e7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105dc3:	85 db                	test   %ebx,%ebx
f0105dc5:	0f 84 30 01 00 00    	je     f0105efb <mp_init+0x2e7>
		return;
	ismp = 1;
f0105dcb:	c7 05 00 90 2a f0 01 	movl   $0x1,0xf02a9000
f0105dd2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105dd5:	8b 43 24             	mov    0x24(%ebx),%eax
f0105dd8:	a3 00 a0 2e f0       	mov    %eax,0xf02ea000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ddd:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105de0:	be 00 00 00 00       	mov    $0x0,%esi
f0105de5:	e9 85 00 00 00       	jmp    f0105e6f <mp_init+0x25b>
		switch (*p) {
f0105dea:	0f b6 07             	movzbl (%edi),%eax
f0105ded:	84 c0                	test   %al,%al
f0105def:	74 06                	je     f0105df7 <mp_init+0x1e3>
f0105df1:	3c 04                	cmp    $0x4,%al
f0105df3:	77 55                	ja     f0105e4a <mp_init+0x236>
f0105df5:	eb 4e                	jmp    f0105e45 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105df7:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105dfb:	74 11                	je     f0105e0e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105dfd:	6b 05 e4 93 2a f0 74 	imul   $0x74,0xf02a93e4,%eax
f0105e04:	05 40 90 2a f0       	add    $0xf02a9040,%eax
f0105e09:	a3 e0 93 2a f0       	mov    %eax,0xf02a93e0
			if (ncpu < NCPU) {
f0105e0e:	a1 e4 93 2a f0       	mov    0xf02a93e4,%eax
f0105e13:	83 f8 07             	cmp    $0x7,%eax
f0105e16:	7f 13                	jg     f0105e2b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105e18:	6b d0 74             	imul   $0x74,%eax,%edx
f0105e1b:	88 82 40 90 2a f0    	mov    %al,-0xfd56fc0(%edx)
				ncpu++;
f0105e21:	83 c0 01             	add    $0x1,%eax
f0105e24:	a3 e4 93 2a f0       	mov    %eax,0xf02a93e4
f0105e29:	eb 15                	jmp    f0105e40 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105e2b:	83 ec 08             	sub    $0x8,%esp
f0105e2e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105e32:	50                   	push   %eax
f0105e33:	68 88 8a 10 f0       	push   $0xf0108a88
f0105e38:	e8 20 d9 ff ff       	call   f010375d <cprintf>
f0105e3d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105e40:	83 c7 14             	add    $0x14,%edi
			continue;
f0105e43:	eb 27                	jmp    f0105e6c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105e45:	83 c7 08             	add    $0x8,%edi
			continue;
f0105e48:	eb 22                	jmp    f0105e6c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e4a:	83 ec 08             	sub    $0x8,%esp
f0105e4d:	0f b6 c0             	movzbl %al,%eax
f0105e50:	50                   	push   %eax
f0105e51:	68 b0 8a 10 f0       	push   $0xf0108ab0
f0105e56:	e8 02 d9 ff ff       	call   f010375d <cprintf>
			ismp = 0;
f0105e5b:	c7 05 00 90 2a f0 00 	movl   $0x0,0xf02a9000
f0105e62:	00 00 00 
			i = conf->entry;
f0105e65:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105e69:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e6c:	83 c6 01             	add    $0x1,%esi
f0105e6f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105e73:	39 c6                	cmp    %eax,%esi
f0105e75:	0f 82 6f ff ff ff    	jb     f0105dea <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e7b:	a1 e0 93 2a f0       	mov    0xf02a93e0,%eax
f0105e80:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e87:	83 3d 00 90 2a f0 00 	cmpl   $0x0,0xf02a9000
f0105e8e:	75 26                	jne    f0105eb6 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105e90:	c7 05 e4 93 2a f0 01 	movl   $0x1,0xf02a93e4
f0105e97:	00 00 00 
		lapicaddr = 0;
f0105e9a:	c7 05 00 a0 2e f0 00 	movl   $0x0,0xf02ea000
f0105ea1:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ea4:	83 ec 0c             	sub    $0xc,%esp
f0105ea7:	68 d0 8a 10 f0       	push   $0xf0108ad0
f0105eac:	e8 ac d8 ff ff       	call   f010375d <cprintf>
		return;
f0105eb1:	83 c4 10             	add    $0x10,%esp
f0105eb4:	eb 45                	jmp    f0105efb <mp_init+0x2e7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105eb6:	83 ec 04             	sub    $0x4,%esp
f0105eb9:	ff 35 e4 93 2a f0    	pushl  0xf02a93e4
f0105ebf:	0f b6 00             	movzbl (%eax),%eax
f0105ec2:	50                   	push   %eax
f0105ec3:	68 57 8b 10 f0       	push   $0xf0108b57
f0105ec8:	e8 90 d8 ff ff       	call   f010375d <cprintf>

	if (mp->imcrp) {
f0105ecd:	83 c4 10             	add    $0x10,%esp
f0105ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ed3:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ed7:	74 22                	je     f0105efb <mp_init+0x2e7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105ed9:	83 ec 0c             	sub    $0xc,%esp
f0105edc:	68 fc 8a 10 f0       	push   $0xf0108afc
f0105ee1:	e8 77 d8 ff ff       	call   f010375d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ee6:	ba 22 00 00 00       	mov    $0x22,%edx
f0105eeb:	b8 70 00 00 00       	mov    $0x70,%eax
f0105ef0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105ef1:	b2 23                	mov    $0x23,%dl
f0105ef3:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105ef4:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ef7:	ee                   	out    %al,(%dx)
f0105ef8:	83 c4 10             	add    $0x10,%esp
	}
}
f0105efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105efe:	5b                   	pop    %ebx
f0105eff:	5e                   	pop    %esi
f0105f00:	5f                   	pop    %edi
f0105f01:	5d                   	pop    %ebp
f0105f02:	c3                   	ret    

f0105f03 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105f03:	55                   	push   %ebp
f0105f04:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105f06:	8b 0d 04 a0 2e f0    	mov    0xf02ea004,%ecx
f0105f0c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105f0f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105f11:	a1 04 a0 2e f0       	mov    0xf02ea004,%eax
f0105f16:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105f19:	5d                   	pop    %ebp
f0105f1a:	c3                   	ret    

f0105f1b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105f1b:	55                   	push   %ebp
f0105f1c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105f1e:	a1 04 a0 2e f0       	mov    0xf02ea004,%eax
f0105f23:	85 c0                	test   %eax,%eax
f0105f25:	74 08                	je     f0105f2f <cpunum+0x14>
		return lapic[ID] >> 24;
f0105f27:	8b 40 20             	mov    0x20(%eax),%eax
f0105f2a:	c1 e8 18             	shr    $0x18,%eax
f0105f2d:	eb 05                	jmp    f0105f34 <cpunum+0x19>
	return 0;
f0105f2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f34:	5d                   	pop    %ebp
f0105f35:	c3                   	ret    

f0105f36 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105f36:	a1 00 a0 2e f0       	mov    0xf02ea000,%eax
f0105f3b:	85 c0                	test   %eax,%eax
f0105f3d:	0f 84 21 01 00 00    	je     f0106064 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105f43:	55                   	push   %ebp
f0105f44:	89 e5                	mov    %esp,%ebp
f0105f46:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f49:	68 00 10 00 00       	push   $0x1000
f0105f4e:	50                   	push   %eax
f0105f4f:	e8 f5 b3 ff ff       	call   f0101349 <mmio_map_region>
f0105f54:	a3 04 a0 2e f0       	mov    %eax,0xf02ea004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f59:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f5e:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f63:	e8 9b ff ff ff       	call   f0105f03 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105f68:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105f6d:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105f72:	e8 8c ff ff ff       	call   f0105f03 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f77:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f7c:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f81:	e8 7d ff ff ff       	call   f0105f03 <lapicw>
	lapicw(TICR, 10000000); 
f0105f86:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f8b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f90:	e8 6e ff ff ff       	call   f0105f03 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105f95:	e8 81 ff ff ff       	call   f0105f1b <cpunum>
f0105f9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f9d:	05 40 90 2a f0       	add    $0xf02a9040,%eax
f0105fa2:	83 c4 10             	add    $0x10,%esp
f0105fa5:	39 05 e0 93 2a f0    	cmp    %eax,0xf02a93e0
f0105fab:	74 0f                	je     f0105fbc <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105fad:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fb2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105fb7:	e8 47 ff ff ff       	call   f0105f03 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105fbc:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fc1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105fc6:	e8 38 ff ff ff       	call   f0105f03 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105fcb:	a1 04 a0 2e f0       	mov    0xf02ea004,%eax
f0105fd0:	8b 40 30             	mov    0x30(%eax),%eax
f0105fd3:	c1 e8 10             	shr    $0x10,%eax
f0105fd6:	3c 03                	cmp    $0x3,%al
f0105fd8:	76 0f                	jbe    f0105fe9 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105fda:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fdf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105fe4:	e8 1a ff ff ff       	call   f0105f03 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105fe9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105fee:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ff3:	e8 0b ff ff ff       	call   f0105f03 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ff8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ffd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106002:	e8 fc fe ff ff       	call   f0105f03 <lapicw>
	lapicw(ESR, 0);
f0106007:	ba 00 00 00 00       	mov    $0x0,%edx
f010600c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106011:	e8 ed fe ff ff       	call   f0105f03 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106016:	ba 00 00 00 00       	mov    $0x0,%edx
f010601b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106020:	e8 de fe ff ff       	call   f0105f03 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106025:	ba 00 00 00 00       	mov    $0x0,%edx
f010602a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010602f:	e8 cf fe ff ff       	call   f0105f03 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106034:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106039:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010603e:	e8 c0 fe ff ff       	call   f0105f03 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106043:	8b 15 04 a0 2e f0    	mov    0xf02ea004,%edx
f0106049:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010604f:	f6 c4 10             	test   $0x10,%ah
f0106052:	75 f5                	jne    f0106049 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106054:	ba 00 00 00 00       	mov    $0x0,%edx
f0106059:	b8 20 00 00 00       	mov    $0x20,%eax
f010605e:	e8 a0 fe ff ff       	call   f0105f03 <lapicw>
}
f0106063:	c9                   	leave  
f0106064:	f3 c3                	repz ret 

f0106066 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106066:	83 3d 04 a0 2e f0 00 	cmpl   $0x0,0xf02ea004
f010606d:	74 13                	je     f0106082 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010606f:	55                   	push   %ebp
f0106070:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106072:	ba 00 00 00 00       	mov    $0x0,%edx
f0106077:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010607c:	e8 82 fe ff ff       	call   f0105f03 <lapicw>
}
f0106081:	5d                   	pop    %ebp
f0106082:	f3 c3                	repz ret 

f0106084 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106084:	55                   	push   %ebp
f0106085:	89 e5                	mov    %esp,%ebp
f0106087:	56                   	push   %esi
f0106088:	53                   	push   %ebx
f0106089:	8b 75 08             	mov    0x8(%ebp),%esi
f010608c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010608f:	ba 70 00 00 00       	mov    $0x70,%edx
f0106094:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106099:	ee                   	out    %al,(%dx)
f010609a:	b2 71                	mov    $0x71,%dl
f010609c:	b8 0a 00 00 00       	mov    $0xa,%eax
f01060a1:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01060a2:	83 3d d8 8e 2a f0 00 	cmpl   $0x0,0xf02a8ed8
f01060a9:	75 19                	jne    f01060c4 <lapic_startap+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060ab:	68 67 04 00 00       	push   $0x467
f01060b0:	68 24 6f 10 f0       	push   $0xf0106f24
f01060b5:	68 98 00 00 00       	push   $0x98
f01060ba:	68 74 8b 10 f0       	push   $0xf0108b74
f01060bf:	e8 7c 9f ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01060c4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01060cb:	00 00 
	wrv[1] = addr >> 4;
f01060cd:	89 d8                	mov    %ebx,%eax
f01060cf:	c1 e8 04             	shr    $0x4,%eax
f01060d2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01060d8:	c1 e6 18             	shl    $0x18,%esi
f01060db:	89 f2                	mov    %esi,%edx
f01060dd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060e2:	e8 1c fe ff ff       	call   f0105f03 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01060e7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01060ec:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060f1:	e8 0d fe ff ff       	call   f0105f03 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01060f6:	ba 00 85 00 00       	mov    $0x8500,%edx
f01060fb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106100:	e8 fe fd ff ff       	call   f0105f03 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106105:	c1 eb 0c             	shr    $0xc,%ebx
f0106108:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010610b:	89 f2                	mov    %esi,%edx
f010610d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106112:	e8 ec fd ff ff       	call   f0105f03 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106117:	89 da                	mov    %ebx,%edx
f0106119:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010611e:	e8 e0 fd ff ff       	call   f0105f03 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106123:	89 f2                	mov    %esi,%edx
f0106125:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010612a:	e8 d4 fd ff ff       	call   f0105f03 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010612f:	89 da                	mov    %ebx,%edx
f0106131:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106136:	e8 c8 fd ff ff       	call   f0105f03 <lapicw>
		microdelay(200);
	}
}
f010613b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010613e:	5b                   	pop    %ebx
f010613f:	5e                   	pop    %esi
f0106140:	5d                   	pop    %ebp
f0106141:	c3                   	ret    

f0106142 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106142:	55                   	push   %ebp
f0106143:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106145:	8b 55 08             	mov    0x8(%ebp),%edx
f0106148:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010614e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106153:	e8 ab fd ff ff       	call   f0105f03 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106158:	8b 15 04 a0 2e f0    	mov    0xf02ea004,%edx
f010615e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106164:	f6 c4 10             	test   $0x10,%ah
f0106167:	75 f5                	jne    f010615e <lapic_ipi+0x1c>
		;
}
f0106169:	5d                   	pop    %ebp
f010616a:	c3                   	ret    

f010616b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010616b:	55                   	push   %ebp
f010616c:	89 e5                	mov    %esp,%ebp
f010616e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106171:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106177:	8b 55 0c             	mov    0xc(%ebp),%edx
f010617a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010617d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106184:	5d                   	pop    %ebp
f0106185:	c3                   	ret    

f0106186 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106186:	55                   	push   %ebp
f0106187:	89 e5                	mov    %esp,%ebp
f0106189:	56                   	push   %esi
f010618a:	53                   	push   %ebx
f010618b:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010618e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106191:	74 14                	je     f01061a7 <spin_lock+0x21>
f0106193:	8b 73 08             	mov    0x8(%ebx),%esi
f0106196:	e8 80 fd ff ff       	call   f0105f1b <cpunum>
f010619b:	6b c0 74             	imul   $0x74,%eax,%eax
f010619e:	05 40 90 2a f0       	add    $0xf02a9040,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01061a3:	39 c6                	cmp    %eax,%esi
f01061a5:	74 07                	je     f01061ae <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01061a7:	ba 01 00 00 00       	mov    $0x1,%edx
f01061ac:	eb 20                	jmp    f01061ce <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01061ae:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01061b1:	e8 65 fd ff ff       	call   f0105f1b <cpunum>
f01061b6:	83 ec 0c             	sub    $0xc,%esp
f01061b9:	53                   	push   %ebx
f01061ba:	50                   	push   %eax
f01061bb:	68 84 8b 10 f0       	push   $0xf0108b84
f01061c0:	6a 41                	push   $0x41
f01061c2:	68 e6 8b 10 f0       	push   $0xf0108be6
f01061c7:	e8 74 9e ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01061cc:	f3 90                	pause  
f01061ce:	89 d0                	mov    %edx,%eax
f01061d0:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01061d3:	85 c0                	test   %eax,%eax
f01061d5:	75 f5                	jne    f01061cc <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01061d7:	e8 3f fd ff ff       	call   f0105f1b <cpunum>
f01061dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01061df:	05 40 90 2a f0       	add    $0xf02a9040,%eax
f01061e4:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01061e7:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01061ea:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01061ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f1:	eb 0b                	jmp    f01061fe <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01061f3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01061f6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01061f9:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061fb:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01061fe:	83 f8 09             	cmp    $0x9,%eax
f0106201:	7f 14                	jg     f0106217 <spin_lock+0x91>
f0106203:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106209:	77 e8                	ja     f01061f3 <spin_lock+0x6d>
f010620b:	eb 0a                	jmp    f0106217 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010620d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106214:	83 c0 01             	add    $0x1,%eax
f0106217:	83 f8 09             	cmp    $0x9,%eax
f010621a:	7e f1                	jle    f010620d <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010621c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010621f:	5b                   	pop    %ebx
f0106220:	5e                   	pop    %esi
f0106221:	5d                   	pop    %ebp
f0106222:	c3                   	ret    

f0106223 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106223:	55                   	push   %ebp
f0106224:	89 e5                	mov    %esp,%ebp
f0106226:	57                   	push   %edi
f0106227:	56                   	push   %esi
f0106228:	53                   	push   %ebx
f0106229:	83 ec 4c             	sub    $0x4c,%esp
f010622c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010622f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106232:	74 18                	je     f010624c <spin_unlock+0x29>
f0106234:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106237:	e8 df fc ff ff       	call   f0105f1b <cpunum>
f010623c:	6b c0 74             	imul   $0x74,%eax,%eax
f010623f:	05 40 90 2a f0       	add    $0xf02a9040,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106244:	39 c3                	cmp    %eax,%ebx
f0106246:	0f 84 a5 00 00 00    	je     f01062f1 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010624c:	83 ec 04             	sub    $0x4,%esp
f010624f:	6a 28                	push   $0x28
f0106251:	8d 46 0c             	lea    0xc(%esi),%eax
f0106254:	50                   	push   %eax
f0106255:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106258:	53                   	push   %ebx
f0106259:	e8 e6 f6 ff ff       	call   f0105944 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010625e:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106261:	0f b6 38             	movzbl (%eax),%edi
f0106264:	8b 76 04             	mov    0x4(%esi),%esi
f0106267:	e8 af fc ff ff       	call   f0105f1b <cpunum>
f010626c:	57                   	push   %edi
f010626d:	56                   	push   %esi
f010626e:	50                   	push   %eax
f010626f:	68 b0 8b 10 f0       	push   $0xf0108bb0
f0106274:	e8 e4 d4 ff ff       	call   f010375d <cprintf>
f0106279:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010627c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010627f:	eb 54                	jmp    f01062d5 <spin_unlock+0xb2>
f0106281:	83 ec 08             	sub    $0x8,%esp
f0106284:	57                   	push   %edi
f0106285:	50                   	push   %eax
f0106286:	e8 e5 eb ff ff       	call   f0104e70 <debuginfo_eip>
f010628b:	83 c4 10             	add    $0x10,%esp
f010628e:	85 c0                	test   %eax,%eax
f0106290:	78 27                	js     f01062b9 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106292:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106294:	83 ec 04             	sub    $0x4,%esp
f0106297:	89 c2                	mov    %eax,%edx
f0106299:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010629c:	52                   	push   %edx
f010629d:	ff 75 b0             	pushl  -0x50(%ebp)
f01062a0:	ff 75 b4             	pushl  -0x4c(%ebp)
f01062a3:	ff 75 ac             	pushl  -0x54(%ebp)
f01062a6:	ff 75 a8             	pushl  -0x58(%ebp)
f01062a9:	50                   	push   %eax
f01062aa:	68 f6 8b 10 f0       	push   $0xf0108bf6
f01062af:	e8 a9 d4 ff ff       	call   f010375d <cprintf>
f01062b4:	83 c4 20             	add    $0x20,%esp
f01062b7:	eb 12                	jmp    f01062cb <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01062b9:	83 ec 08             	sub    $0x8,%esp
f01062bc:	ff 36                	pushl  (%esi)
f01062be:	68 0d 8c 10 f0       	push   $0xf0108c0d
f01062c3:	e8 95 d4 ff ff       	call   f010375d <cprintf>
f01062c8:	83 c4 10             	add    $0x10,%esp
f01062cb:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01062ce:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01062d1:	39 c3                	cmp    %eax,%ebx
f01062d3:	74 08                	je     f01062dd <spin_unlock+0xba>
f01062d5:	89 de                	mov    %ebx,%esi
f01062d7:	8b 03                	mov    (%ebx),%eax
f01062d9:	85 c0                	test   %eax,%eax
f01062db:	75 a4                	jne    f0106281 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01062dd:	83 ec 04             	sub    $0x4,%esp
f01062e0:	68 15 8c 10 f0       	push   $0xf0108c15
f01062e5:	6a 67                	push   $0x67
f01062e7:	68 e6 8b 10 f0       	push   $0xf0108be6
f01062ec:	e8 4f 9d ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01062f1:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01062f8:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01062ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0106304:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106307:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010630a:	5b                   	pop    %ebx
f010630b:	5e                   	pop    %esi
f010630c:	5f                   	pop    %edi
f010630d:	5d                   	pop    %ebp
f010630e:	c3                   	ret    

f010630f <nic_init>:
        if(nic_init() < 0)
                panic("No mem failure from nic_attach\n");
        return 0;
}

int nic_init() {
f010630f:	55                   	push   %ebp
f0106310:	89 e5                	mov    %esp,%ebp
f0106312:	56                   	push   %esi
f0106313:	53                   	push   %ebx
        struct PageInfo *tmpt, *tmpr, *tmpr1;

        //steal 1 page for rxda
        tmpr = page_alloc(ALLOC_ZERO);
f0106314:	83 ec 0c             	sub    $0xc,%esp
f0106317:	6a 01                	push   $0x1
f0106319:	e8 98 ac ff ff       	call   f0100fb6 <page_alloc>
f010631e:	89 c6                	mov    %eax,%esi
        if (tmpr == NULL)
f0106320:	83 c4 10             	add    $0x10,%esp
f0106323:	85 c0                	test   %eax,%eax
f0106325:	0f 84 c8 01 00 00    	je     f01064f3 <nic_init+0x1e4>
                return -E_NO_MEM;
        tmpr->pp_ref++;
f010632b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0106330:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0106336:	c1 f8 03             	sar    $0x3,%eax
f0106339:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010633c:	89 c2                	mov    %eax,%edx
f010633e:	c1 ea 0c             	shr    $0xc,%edx
f0106341:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0106347:	72 12                	jb     f010635b <nic_init+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106349:	50                   	push   %eax
f010634a:	68 24 6f 10 f0       	push   $0xf0106f24
f010634f:	6a 58                	push   $0x58
f0106351:	68 ea 74 10 f0       	push   $0xf01074ea
f0106356:	e8 e5 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010635b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106360:	a3 0c a0 2e f0       	mov    %eax,0xf02ea00c
        rx_ring = page2kva(tmpr);
f0106365:	bb 00 00 00 00       	mov    $0x0,%ebx
        //recieve init
        int i;
        for(i = 0; i < 128; i++) {
                rx_ring[i].status = 0;
f010636a:	a1 0c a0 2e f0       	mov    0xf02ea00c,%eax
f010636f:	c6 44 18 0c 00       	movb   $0x0,0xc(%eax,%ebx,1)
                //temporarily borrow 128 pages for buff
                tmpr1 = page_alloc(ALLOC_ZERO);
f0106374:	83 ec 0c             	sub    $0xc,%esp
f0106377:	6a 01                	push   $0x1
f0106379:	e8 38 ac ff ff       	call   f0100fb6 <page_alloc>
                if (tmpr1 == NULL)
f010637e:	83 c4 10             	add    $0x10,%esp
f0106381:	85 c0                	test   %eax,%eax
f0106383:	0f 84 71 01 00 00    	je     f01064fa <nic_init+0x1eb>
                        return -E_NO_MEM;
                tmpr1->pp_ref++;
f0106389:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010638e:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0106394:	89 c2                	mov    %eax,%edx
f0106396:	c1 fa 03             	sar    $0x3,%edx
f0106399:	c1 e2 0c             	shl    $0xc,%edx
                rx_ring[i].addr = page2pa(tmpr1) + sizeof(int);         
f010639c:	83 c2 04             	add    $0x4,%edx
f010639f:	a1 0c a0 2e f0       	mov    0xf02ea00c,%eax
f01063a4:	89 14 18             	mov    %edx,(%eax,%ebx,1)
f01063a7:	c7 44 18 04 00 00 00 	movl   $0x0,0x4(%eax,%ebx,1)
f01063ae:	00 
f01063af:	83 c3 10             	add    $0x10,%ebx
                return -E_NO_MEM;
        tmpr->pp_ref++;
        rx_ring = page2kva(tmpr);
        //recieve init
        int i;
        for(i = 0; i < 128; i++) {
f01063b2:	81 fb 00 08 00 00    	cmp    $0x800,%ebx
f01063b8:	75 b0                	jne    f010636a <nic_init+0x5b>
                        return -E_NO_MEM;
                tmpr1->pp_ref++;
                rx_ring[i].addr = page2pa(tmpr1) + sizeof(int);         
        }

        nic[E1000_RAL/4] = 0x12005452;
f01063ba:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f01063bf:	c7 80 00 54 00 00 52 	movl   $0x12005452,0x5400(%eax)
f01063c6:	54 00 12 
        nic[E1000_RAH/4] = 0x5634 | E1000_RAH_AV;
f01063c9:	c7 80 04 54 00 00 34 	movl   $0x80005634,0x5404(%eax)
f01063d0:	56 00 80 
f01063d3:	b8 00 52 00 00       	mov    $0x5200,%eax
        for (i = 0; i < 128; i++)
                nic[E1000_MTA/4 + i] = 0;
f01063d8:	89 c2                	mov    %eax,%edx
f01063da:	03 15 cc 8e 2a f0    	add    0xf02a8ecc,%edx
f01063e0:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01063e6:	83 c0 04             	add    $0x4,%eax
                rx_ring[i].addr = page2pa(tmpr1) + sizeof(int);         
        }

        nic[E1000_RAL/4] = 0x12005452;
        nic[E1000_RAH/4] = 0x5634 | E1000_RAH_AV;
        for (i = 0; i < 128; i++)
f01063e9:	3d 00 54 00 00       	cmp    $0x5400,%eax
f01063ee:	75 e8                	jne    f01063d8 <nic_init+0xc9>
                nic[E1000_MTA/4 + i] = 0;
         

        nic[E1000_RDBAL/4] = page2pa(tmpr);
f01063f0:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f01063f5:	2b 35 e0 8e 2a f0    	sub    0xf02a8ee0,%esi
f01063fb:	c1 fe 03             	sar    $0x3,%esi
f01063fe:	c1 e6 0c             	shl    $0xc,%esi
f0106401:	89 b0 00 28 00 00    	mov    %esi,0x2800(%eax)
        nic[E1000_RDBAH/4] = 0;
f0106407:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f010640e:	00 00 00 
        nic[E1000_RDLEN/4] = 2048;
f0106411:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f0106418:	08 00 00 
        nic[E1000_RDH/4] = 0; 
f010641b:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106422:	00 00 00 
        nic[E1000_RDT/4] = 127; 
f0106425:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f010642c:	00 00 00 
        nic[E1000_RCTL/4] = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SECRC | E1000_RCTL_SZ_2048 | E1000_RCTL_RDMTS_QUAT; 
f010642f:	c7 80 00 01 00 00 02 	movl   $0x4008102,0x100(%eax)
f0106436:	81 00 04 
        nic[E1000_IMS/4] =  E1000_IMS_RXT0 | E1000_IMS_RXDMT0 | E1000_IMS_RXO; 
f0106439:	c7 80 d0 00 00 00 d0 	movl   $0xd0,0xd0(%eax)
f0106440:	00 00 00 
       // nic[E1000_ICS/4] =  E1000_ICS_RXT0;
        //nic[E1000_ICR/4] =  E1000_ICR_RXT0;
        //nic[E1000_RDTR/4] = 0;

        //steal 1 page for txda
        tmpt = page_alloc(ALLOC_ZERO);
f0106443:	83 ec 0c             	sub    $0xc,%esp
f0106446:	6a 01                	push   $0x1
f0106448:	e8 69 ab ff ff       	call   f0100fb6 <page_alloc>
        if (tmpt == NULL)
f010644d:	83 c4 10             	add    $0x10,%esp
f0106450:	85 c0                	test   %eax,%eax
f0106452:	0f 84 a9 00 00 00    	je     f0106501 <nic_init+0x1f2>
                return -E_NO_MEM;
        tmpt->pp_ref++;
f0106458:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010645d:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0106463:	89 c1                	mov    %eax,%ecx
f0106465:	c1 f9 03             	sar    $0x3,%ecx
f0106468:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010646b:	89 c8                	mov    %ecx,%eax
f010646d:	c1 e8 0c             	shr    $0xc,%eax
f0106470:	3b 05 d8 8e 2a f0    	cmp    0xf02a8ed8,%eax
f0106476:	72 12                	jb     f010648a <nic_init+0x17b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106478:	51                   	push   %ecx
f0106479:	68 24 6f 10 f0       	push   $0xf0106f24
f010647e:	6a 58                	push   $0x58
f0106480:	68 ea 74 10 f0       	push   $0xf01074ea
f0106485:	e8 b6 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010648a:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
f0106490:	a3 08 a0 2e f0       	mov    %eax,0xf02ea008
f0106495:	8d 81 0c 00 00 f0    	lea    -0xffffff4(%ecx),%eax
f010649b:	8d 91 0c 04 00 f0    	lea    -0xffffbf4(%ecx),%edx
        tx_ring = page2kva(tmpt);

        //transmit init
        for(i = 0; i < 64; i++) {
                tx_ring[i].status = 1;
f01064a1:	c6 00 01             	movb   $0x1,(%eax)
                tx_ring[i].cmd = 9;
f01064a4:	c6 40 ff 09          	movb   $0x9,-0x1(%eax)
f01064a8:	83 c0 10             	add    $0x10,%eax
                return -E_NO_MEM;
        tmpt->pp_ref++;
        tx_ring = page2kva(tmpt);

        //transmit init
        for(i = 0; i < 64; i++) {
f01064ab:	39 d0                	cmp    %edx,%eax
f01064ad:	75 f2                	jne    f01064a1 <nic_init+0x192>
                tx_ring[i].status = 1;
                tx_ring[i].cmd = 9;
        }

        nic[E1000_TDBAL/4] = page2pa(tmpt);
f01064af:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f01064b4:	89 88 00 38 00 00    	mov    %ecx,0x3800(%eax)
        nic[E1000_TDLEN/4] = 1024;
f01064ba:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f01064c1:	04 00 00 
        nic[E1000_TDH/4] = 0;
f01064c4:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f01064cb:	00 00 00 
        nic[E1000_TDT/4] = 0;
f01064ce:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f01064d5:	00 00 00 
        nic[E1000_TCTL/4] = E1000_TCTL_EN | E1000_TCTL_PSP | E1000_TCTL_COLD;
f01064d8:	c7 80 00 04 00 00 0a 	movl   $0x4000a,0x400(%eax)
f01064df:	00 04 00 
        nic[E1000_TIPG/4] = IPGT | IPGR1 | IPGR2;
f01064e2:	c7 80 10 04 00 00 0a 	movl   $0xa0280a,0x410(%eax)
f01064e9:	28 a0 00 
        return 0;
f01064ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01064f1:	eb 13                	jmp    f0106506 <nic_init+0x1f7>
        struct PageInfo *tmpt, *tmpr, *tmpr1;

        //steal 1 page for rxda
        tmpr = page_alloc(ALLOC_ZERO);
        if (tmpr == NULL)
                return -E_NO_MEM;
f01064f3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01064f8:	eb 0c                	jmp    f0106506 <nic_init+0x1f7>
        for(i = 0; i < 128; i++) {
                rx_ring[i].status = 0;
                //temporarily borrow 128 pages for buff
                tmpr1 = page_alloc(ALLOC_ZERO);
                if (tmpr1 == NULL)
                        return -E_NO_MEM;
f01064fa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01064ff:	eb 05                	jmp    f0106506 <nic_init+0x1f7>
        //nic[E1000_RDTR/4] = 0;

        //steal 1 page for txda
        tmpt = page_alloc(ALLOC_ZERO);
        if (tmpt == NULL)
                return -E_NO_MEM;
f0106501:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        nic[E1000_TDH/4] = 0;
        nic[E1000_TDT/4] = 0;
        nic[E1000_TCTL/4] = E1000_TCTL_EN | E1000_TCTL_PSP | E1000_TCTL_COLD;
        nic[E1000_TIPG/4] = IPGT | IPGR1 | IPGR2;
        return 0;
}
f0106506:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106509:	5b                   	pop    %ebx
f010650a:	5e                   	pop    %esi
f010650b:	5d                   	pop    %ebp
f010650c:	c3                   	ret    

f010650d <nic_attach>:

struct tx_desc *tx_ring;
struct rx_desc *rx_ring;
int nic_init();

int nic_attach(struct pci_func *pcif) {
f010650d:	55                   	push   %ebp
f010650e:	89 e5                	mov    %esp,%ebp
f0106510:	53                   	push   %ebx
f0106511:	83 ec 10             	sub    $0x10,%esp
f0106514:	8b 5d 08             	mov    0x8(%ebp),%ebx
        pci_func_enable(pcif);
f0106517:	53                   	push   %ebx
f0106518:	e8 77 05 00 00       	call   f0106a94 <pci_func_enable>
        nic = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);
f010651d:	83 c4 08             	add    $0x8,%esp
f0106520:	ff 73 2c             	pushl  0x2c(%ebx)
f0106523:	ff 73 14             	pushl  0x14(%ebx)
f0106526:	e8 1e ae ff ff       	call   f0101349 <mmio_map_region>
f010652b:	a3 cc 8e 2a f0       	mov    %eax,0xf02a8ecc
        if(nic_init() < 0)
f0106530:	e8 da fd ff ff       	call   f010630f <nic_init>
f0106535:	83 c4 10             	add    $0x10,%esp
f0106538:	85 c0                	test   %eax,%eax
f010653a:	79 14                	jns    f0106550 <nic_attach+0x43>
                panic("No mem failure from nic_attach\n");
f010653c:	83 ec 04             	sub    $0x4,%esp
f010653f:	68 30 8c 10 f0       	push   $0xf0108c30
f0106544:	6a 0d                	push   $0xd
f0106546:	68 50 8c 10 f0       	push   $0xf0108c50
f010654b:	e8 f0 9a ff ff       	call   f0100040 <_panic>
        return 0;
}
f0106550:	b8 00 00 00 00       	mov    $0x0,%eax
f0106555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106558:	c9                   	leave  
f0106559:	c3                   	ret    

f010655a <transmit>:
        nic[E1000_TCTL/4] = E1000_TCTL_EN | E1000_TCTL_PSP | E1000_TCTL_COLD;
        nic[E1000_TIPG/4] = IPGT | IPGR1 | IPGR2;
        return 0;
}

int transmit(uint64_t buf, uint16_t size) {
f010655a:	55                   	push   %ebp
f010655b:	89 e5                	mov    %esp,%ebp
f010655d:	57                   	push   %edi
f010655e:	56                   	push   %esi
f010655f:	53                   	push   %ebx
f0106560:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106566:	8b 75 10             	mov    0x10(%ebp),%esi
 
        uint32_t index = nic[E1000_TDT/4];
f0106569:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f010656e:	8b 80 18 38 00 00    	mov    0x3818(%eax),%eax
        if ((tx_ring[index].status & 1) != 1)
f0106574:	89 c2                	mov    %eax,%edx
f0106576:	c1 e2 04             	shl    $0x4,%edx
f0106579:	89 d7                	mov    %edx,%edi
f010657b:	03 3d 08 a0 2e f0    	add    0xf02ea008,%edi
f0106581:	f6 47 0c 01          	testb  $0x1,0xc(%edi)
f0106585:	74 30                	je     f01065b7 <transmit+0x5d>
                return -E_IPC_NOT_RECV;
      
        tx_ring[index].cmd = 0x9;
f0106587:	c6 47 0b 09          	movb   $0x9,0xb(%edi)
        tx_ring[index].addr = buf;
f010658b:	89 0f                	mov    %ecx,(%edi)
f010658d:	89 5f 04             	mov    %ebx,0x4(%edi)
         
        tx_ring[index].length = size;
f0106590:	03 15 08 a0 2e f0    	add    0xf02ea008,%edx
f0106596:	66 89 72 08          	mov    %si,0x8(%edx)
        tx_ring[index].status = 0;
f010659a:	c6 42 0c 00          	movb   $0x0,0xc(%edx)
        nic[E1000_TDT/4] = (index + 1) % 64;
f010659e:	83 c0 01             	add    $0x1,%eax
f01065a1:	83 e0 3f             	and    $0x3f,%eax
f01065a4:	8b 15 cc 8e 2a f0    	mov    0xf02a8ecc,%edx
f01065aa:	89 82 18 38 00 00    	mov    %eax,0x3818(%edx)

        return 0;
f01065b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01065b5:	eb 05                	jmp    f01065bc <transmit+0x62>

int transmit(uint64_t buf, uint16_t size) {
 
        uint32_t index = nic[E1000_TDT/4];
        if ((tx_ring[index].status & 1) != 1)
                return -E_IPC_NOT_RECV;
f01065b7:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
        tx_ring[index].length = size;
        tx_ring[index].status = 0;
        nic[E1000_TDT/4] = (index + 1) % 64;

        return 0;
}
f01065bc:	5b                   	pop    %ebx
f01065bd:	5e                   	pop    %esi
f01065be:	5f                   	pop    %edi
f01065bf:	5d                   	pop    %ebp
f01065c0:	c3                   	ret    

f01065c1 <recv>:

int recv(void *tempage) {
f01065c1:	55                   	push   %ebp
f01065c2:	89 e5                	mov    %esp,%ebp
f01065c4:	57                   	push   %edi
f01065c5:	56                   	push   %esi
f01065c6:	53                   	push   %ebx
f01065c7:	83 ec 0c             	sub    $0xc,%esp

        uint32_t index = (nic[E1000_RDT/4] + 1)%128;
f01065ca:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f01065cf:	8b 98 18 28 00 00    	mov    0x2818(%eax),%ebx
f01065d5:	83 c3 01             	add    $0x1,%ebx
f01065d8:	83 e3 7f             	and    $0x7f,%ebx
        if ((rx_ring[index].status & 1) == 0) {
f01065db:	89 de                	mov    %ebx,%esi
f01065dd:	c1 e6 04             	shl    $0x4,%esi
f01065e0:	89 f0                	mov    %esi,%eax
f01065e2:	03 05 0c a0 2e f0    	add    0xf02ea00c,%eax
f01065e8:	f6 40 0c 01          	testb  $0x1,0xc(%eax)
f01065ec:	0f 84 c7 00 00 00    	je     f01066b9 <recv+0xf8>
                return -E_IPC_NOT_RECV;
        }
        uint32_t tmppa = (uint32_t)rx_ring[index].addr - sizeof(int);
f01065f2:	8b 08                	mov    (%eax),%ecx
f01065f4:	8d 79 fc             	lea    -0x4(%ecx),%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065f7:	89 fa                	mov    %edi,%edx
f01065f9:	c1 ea 0c             	shr    $0xc,%edx
f01065fc:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0106602:	72 12                	jb     f0106616 <recv+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106604:	57                   	push   %edi
f0106605:	68 24 6f 10 f0       	push   $0xf0106f24
f010660a:	6a 64                	push   $0x64
f010660c:	68 50 8c 10 f0       	push   $0xf0108c50
f0106611:	e8 2a 9a ff ff       	call   f0100040 <_panic>
        *(int *)(KADDR(tmppa)) = rx_ring[index].length;
f0106616:	0f b7 40 08          	movzwl 0x8(%eax),%eax
f010661a:	89 81 fc ff ff ef    	mov    %eax,-0x10000004(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106620:	3b 15 d8 8e 2a f0    	cmp    0xf02a8ed8,%edx
f0106626:	72 14                	jb     f010663c <recv+0x7b>
		panic("pa2page called with invalid pa");
f0106628:	83 ec 04             	sub    $0x4,%esp
f010662b:	68 ec 78 10 f0       	push   $0xf01078ec
f0106630:	6a 51                	push   $0x51
f0106632:	68 ea 74 10 f0       	push   $0xf01074ea
f0106637:	e8 04 9a ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010663c:	a1 e0 8e 2a f0       	mov    0xf02a8ee0,%eax
f0106641:	8d 3c d0             	lea    (%eax,%edx,8),%edi
        if(page_insert(curenv->env_pgdir, pa2page(tmppa), tempage, PTE_U|PTE_P) < 0)
f0106644:	e8 d2 f8 ff ff       	call   f0105f1b <cpunum>
f0106649:	6a 05                	push   $0x5
f010664b:	ff 75 08             	pushl  0x8(%ebp)
f010664e:	57                   	push   %edi
f010664f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106652:	8b 80 48 90 2a f0    	mov    -0xfd56fb8(%eax),%eax
f0106658:	ff 70 60             	pushl  0x60(%eax)
f010665b:	e8 6c ac ff ff       	call   f01012cc <page_insert>
f0106660:	83 c4 10             	add    $0x10,%esp
f0106663:	85 c0                	test   %eax,%eax
f0106665:	78 59                	js     f01066c0 <recv+0xff>
                return -E_NO_MEM; 

        struct PageInfo *tmpr = page_alloc(ALLOC_ZERO);
f0106667:	83 ec 0c             	sub    $0xc,%esp
f010666a:	6a 01                	push   $0x1
f010666c:	e8 45 a9 ff ff       	call   f0100fb6 <page_alloc>
        if (tmpr == NULL)
f0106671:	83 c4 10             	add    $0x10,%esp
f0106674:	85 c0                	test   %eax,%eax
f0106676:	74 4f                	je     f01066c7 <recv+0x106>
                return -E_NO_MEM;
        tmpr->pp_ref++; 
f0106678:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010667d:	2b 05 e0 8e 2a f0    	sub    0xf02a8ee0,%eax
f0106683:	c1 f8 03             	sar    $0x3,%eax
f0106686:	c1 e0 0c             	shl    $0xc,%eax
        rx_ring[index].addr = page2pa(tmpr) + sizeof(int);
f0106689:	83 c0 04             	add    $0x4,%eax
f010668c:	8b 15 0c a0 2e f0    	mov    0xf02ea00c,%edx
f0106692:	89 04 32             	mov    %eax,(%edx,%esi,1)
f0106695:	c7 44 32 04 00 00 00 	movl   $0x0,0x4(%edx,%esi,1)
f010669c:	00 
        rx_ring[index].status =  0;
f010669d:	a1 0c a0 2e f0       	mov    0xf02ea00c,%eax
f01066a2:	c6 44 30 0c 00       	movb   $0x0,0xc(%eax,%esi,1)
        nic[E1000_RDT/4] = index;
f01066a7:	a1 cc 8e 2a f0       	mov    0xf02a8ecc,%eax
f01066ac:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
        return 0;
f01066b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01066b7:	eb 13                	jmp    f01066cc <recv+0x10b>

int recv(void *tempage) {

        uint32_t index = (nic[E1000_RDT/4] + 1)%128;
        if ((rx_ring[index].status & 1) == 0) {
                return -E_IPC_NOT_RECV;
f01066b9:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01066be:	eb 0c                	jmp    f01066cc <recv+0x10b>
        }
        uint32_t tmppa = (uint32_t)rx_ring[index].addr - sizeof(int);
        *(int *)(KADDR(tmppa)) = rx_ring[index].length;
        if(page_insert(curenv->env_pgdir, pa2page(tmppa), tempage, PTE_U|PTE_P) < 0)
                return -E_NO_MEM; 
f01066c0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01066c5:	eb 05                	jmp    f01066cc <recv+0x10b>

        struct PageInfo *tmpr = page_alloc(ALLOC_ZERO);
        if (tmpr == NULL)
                return -E_NO_MEM;
f01066c7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        rx_ring[index].addr = page2pa(tmpr) + sizeof(int);
        rx_ring[index].status =  0;
        nic[E1000_RDT/4] = index;
        return 0;

}
f01066cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066cf:	5b                   	pop    %ebx
f01066d0:	5e                   	pop    %esi
f01066d1:	5f                   	pop    %edi
f01066d2:	5d                   	pop    %ebp
f01066d3:	c3                   	ret    

f01066d4 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f01066d4:	55                   	push   %ebp
f01066d5:	89 e5                	mov    %esp,%ebp
f01066d7:	57                   	push   %edi
f01066d8:	56                   	push   %esi
f01066d9:	53                   	push   %ebx
f01066da:	83 ec 0c             	sub    $0xc,%esp
f01066dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01066e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01066e3:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01066e6:	eb 3a                	jmp    f0106722 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f01066e8:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f01066eb:	75 32                	jne    f010671f <pci_attach_match+0x4b>
f01066ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066f0:	39 56 fc             	cmp    %edx,-0x4(%esi)
f01066f3:	75 2a                	jne    f010671f <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f01066f5:	83 ec 0c             	sub    $0xc,%esp
f01066f8:	ff 75 14             	pushl  0x14(%ebp)
f01066fb:	ff d0                	call   *%eax
			if (r > 0)
f01066fd:	83 c4 10             	add    $0x10,%esp
f0106700:	85 c0                	test   %eax,%eax
f0106702:	7f 26                	jg     f010672a <pci_attach_match+0x56>
				return r;
			if (r < 0)
f0106704:	85 c0                	test   %eax,%eax
f0106706:	79 17                	jns    f010671f <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0106708:	83 ec 0c             	sub    $0xc,%esp
f010670b:	50                   	push   %eax
f010670c:	ff 36                	pushl  (%esi)
f010670e:	ff 75 0c             	pushl  0xc(%ebp)
f0106711:	57                   	push   %edi
f0106712:	68 60 8c 10 f0       	push   $0xf0108c60
f0106717:	e8 41 d0 ff ff       	call   f010375d <cprintf>
f010671c:	83 c4 20             	add    $0x20,%esp
f010671f:	83 c3 0c             	add    $0xc,%ebx
f0106722:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106724:	8b 03                	mov    (%ebx),%eax
f0106726:	85 c0                	test   %eax,%eax
f0106728:	75 be                	jne    f01066e8 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f010672a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010672d:	5b                   	pop    %ebx
f010672e:	5e                   	pop    %esi
f010672f:	5f                   	pop    %edi
f0106730:	5d                   	pop    %ebp
f0106731:	c3                   	ret    

f0106732 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0106732:	55                   	push   %ebp
f0106733:	89 e5                	mov    %esp,%ebp
f0106735:	53                   	push   %ebx
f0106736:	83 ec 04             	sub    $0x4,%esp
f0106739:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f010673c:	3d ff 00 00 00       	cmp    $0xff,%eax
f0106741:	76 16                	jbe    f0106759 <pci_conf1_set_addr+0x27>
f0106743:	68 b8 8d 10 f0       	push   $0xf0108db8
f0106748:	68 04 75 10 f0       	push   $0xf0107504
f010674d:	6a 2c                	push   $0x2c
f010674f:	68 c2 8d 10 f0       	push   $0xf0108dc2
f0106754:	e8 e7 98 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0106759:	83 fa 1f             	cmp    $0x1f,%edx
f010675c:	76 16                	jbe    f0106774 <pci_conf1_set_addr+0x42>
f010675e:	68 cd 8d 10 f0       	push   $0xf0108dcd
f0106763:	68 04 75 10 f0       	push   $0xf0107504
f0106768:	6a 2d                	push   $0x2d
f010676a:	68 c2 8d 10 f0       	push   $0xf0108dc2
f010676f:	e8 cc 98 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106774:	83 f9 07             	cmp    $0x7,%ecx
f0106777:	76 16                	jbe    f010678f <pci_conf1_set_addr+0x5d>
f0106779:	68 d6 8d 10 f0       	push   $0xf0108dd6
f010677e:	68 04 75 10 f0       	push   $0xf0107504
f0106783:	6a 2e                	push   $0x2e
f0106785:	68 c2 8d 10 f0       	push   $0xf0108dc2
f010678a:	e8 b1 98 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f010678f:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106795:	76 16                	jbe    f01067ad <pci_conf1_set_addr+0x7b>
f0106797:	68 df 8d 10 f0       	push   $0xf0108ddf
f010679c:	68 04 75 10 f0       	push   $0xf0107504
f01067a1:	6a 2f                	push   $0x2f
f01067a3:	68 c2 8d 10 f0       	push   $0xf0108dc2
f01067a8:	e8 93 98 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01067ad:	f6 c3 03             	test   $0x3,%bl
f01067b0:	74 16                	je     f01067c8 <pci_conf1_set_addr+0x96>
f01067b2:	68 ec 8d 10 f0       	push   $0xf0108dec
f01067b7:	68 04 75 10 f0       	push   $0xf0107504
f01067bc:	6a 30                	push   $0x30
f01067be:	68 c2 8d 10 f0       	push   $0xf0108dc2
f01067c3:	e8 78 98 ff ff       	call   f0100040 <_panic>
f01067c8:	81 cb 00 00 00 80    	or     $0x80000000,%ebx

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f01067ce:	c1 e1 08             	shl    $0x8,%ecx
f01067d1:	09 d9                	or     %ebx,%ecx
f01067d3:	c1 e2 0b             	shl    $0xb,%edx
f01067d6:	09 ca                	or     %ecx,%edx
f01067d8:	c1 e0 10             	shl    $0x10,%eax
	assert(dev < 32);
	assert(func < 8);
	assert(offset < 256);
	assert((offset & 0x3) == 0);

	uint32_t v = (1 << 31) |		// config-space
f01067db:	09 d0                	or     %edx,%eax
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01067dd:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f01067e2:	ef                   	out    %eax,(%dx)
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f01067e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01067e6:	c9                   	leave  
f01067e7:	c3                   	ret    

f01067e8 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f01067e8:	55                   	push   %ebp
f01067e9:	89 e5                	mov    %esp,%ebp
f01067eb:	53                   	push   %ebx
f01067ec:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01067ef:	8b 48 08             	mov    0x8(%eax),%ecx
f01067f2:	8b 58 04             	mov    0x4(%eax),%ebx
f01067f5:	8b 00                	mov    (%eax),%eax
f01067f7:	8b 40 04             	mov    0x4(%eax),%eax
f01067fa:	52                   	push   %edx
f01067fb:	89 da                	mov    %ebx,%edx
f01067fd:	e8 30 ff ff ff       	call   f0106732 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106802:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106807:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010680b:	c9                   	leave  
f010680c:	c3                   	ret    

f010680d <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f010680d:	55                   	push   %ebp
f010680e:	89 e5                	mov    %esp,%ebp
f0106810:	57                   	push   %edi
f0106811:	56                   	push   %esi
f0106812:	53                   	push   %ebx
f0106813:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106819:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f010681b:	6a 48                	push   $0x48
f010681d:	6a 00                	push   $0x0
f010681f:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106822:	50                   	push   %eax
f0106823:	e8 cf f0 ff ff       	call   f01058f7 <memset>
	df.bus = bus;
f0106828:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010682b:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0106832:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f0106835:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f010683c:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f010683f:	ba 0c 00 00 00       	mov    $0xc,%edx
f0106844:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106847:	e8 9c ff ff ff       	call   f01067e8 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f010684c:	89 c2                	mov    %eax,%edx
f010684e:	c1 ea 10             	shr    $0x10,%edx
f0106851:	83 e2 7f             	and    $0x7f,%edx
f0106854:	83 fa 01             	cmp    $0x1,%edx
f0106857:	0f 87 45 01 00 00    	ja     f01069a2 <pci_scan_bus+0x195>
			continue;

		totaldev++;
f010685d:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f0106864:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106869:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f010686f:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0106872:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106874:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f010687b:	00 00 00 
f010687e:	25 00 00 80 00       	and    $0x800000,%eax
f0106883:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
		     f.func++) {
			struct pci_func af = f;
f0106889:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010688f:	e9 f3 00 00 00       	jmp    f0106987 <pci_scan_bus+0x17a>
		     f.func++) {
			struct pci_func af = f;
f0106894:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106899:	89 df                	mov    %ebx,%edi
f010689b:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01068a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01068a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01068a8:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01068ae:	e8 35 ff ff ff       	call   f01067e8 <pci_conf_read>
f01068b3:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f01068b9:	66 83 f8 ff          	cmp    $0xffff,%ax
f01068bd:	0f 84 bd 00 00 00    	je     f0106980 <pci_scan_bus+0x173>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01068c3:	ba 3c 00 00 00       	mov    $0x3c,%edx
f01068c8:	89 d8                	mov    %ebx,%eax
f01068ca:	e8 19 ff ff ff       	call   f01067e8 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01068cf:	88 45 9c             	mov    %al,-0x64(%ebp)
			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01068d2:	ba 08 00 00 00       	mov    $0x8,%edx
f01068d7:	89 d8                	mov    %ebx,%eax
f01068d9:	e8 0a ff ff ff       	call   f01067e8 <pci_conf_read>
f01068de:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01068e4:	89 c2                	mov    %eax,%edx
f01068e6:	c1 ea 18             	shr    $0x18,%edx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01068e9:	be 00 8e 10 f0       	mov    $0xf0108e00,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01068ee:	83 fa 06             	cmp    $0x6,%edx
f01068f1:	77 07                	ja     f01068fa <pci_scan_bus+0xed>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01068f3:	8b 34 95 74 8e 10 f0 	mov    -0xfef718c(,%edx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01068fa:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106900:	83 ec 08             	sub    $0x8,%esp
f0106903:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0106907:	57                   	push   %edi
f0106908:	56                   	push   %esi
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f0106909:	c1 e8 10             	shr    $0x10,%eax
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f010690c:	0f b6 c0             	movzbl %al,%eax
f010690f:	50                   	push   %eax
f0106910:	52                   	push   %edx
f0106911:	89 c8                	mov    %ecx,%eax
f0106913:	c1 e8 10             	shr    $0x10,%eax
f0106916:	50                   	push   %eax
f0106917:	0f b7 c9             	movzwl %cx,%ecx
f010691a:	51                   	push   %ecx
f010691b:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0106921:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f0106927:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f010692d:	ff 70 04             	pushl  0x4(%eax)
f0106930:	68 8c 8c 10 f0       	push   $0xf0108c8c
f0106935:	e8 23 ce ff ff       	call   f010375d <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f010693a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106940:	83 c4 30             	add    $0x30,%esp
f0106943:	53                   	push   %ebx
f0106944:	68 0c 44 12 f0       	push   $0xf012440c
				 PCI_SUBCLASS(f->dev_class),
f0106949:	89 c2                	mov    %eax,%edx
f010694b:	c1 ea 10             	shr    $0x10,%edx

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f010694e:	0f b6 d2             	movzbl %dl,%edx
f0106951:	52                   	push   %edx
f0106952:	c1 e8 18             	shr    $0x18,%eax
f0106955:	50                   	push   %eax
f0106956:	e8 79 fd ff ff       	call   f01066d4 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f010695b:	83 c4 10             	add    $0x10,%esp
f010695e:	85 c0                	test   %eax,%eax
f0106960:	75 1e                	jne    f0106980 <pci_scan_bus+0x173>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0106962:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106968:	53                   	push   %ebx
f0106969:	68 f4 43 12 f0       	push   $0xf01243f4
f010696e:	89 c2                	mov    %eax,%edx
f0106970:	c1 ea 10             	shr    $0x10,%edx
f0106973:	52                   	push   %edx
f0106974:	0f b7 c0             	movzwl %ax,%eax
f0106977:	50                   	push   %eax
f0106978:	e8 57 fd ff ff       	call   f01066d4 <pci_attach_match>
f010697d:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106980:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106987:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
f010698e:	19 c0                	sbb    %eax,%eax
f0106990:	83 e0 f9             	and    $0xfffffff9,%eax
f0106993:	83 c0 08             	add    $0x8,%eax
f0106996:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f010699c:	0f 87 f2 fe ff ff    	ja     f0106894 <pci_scan_bus+0x87>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01069a2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01069a5:	83 c0 01             	add    $0x1,%eax
f01069a8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01069ab:	83 f8 1f             	cmp    $0x1f,%eax
f01069ae:	0f 86 8b fe ff ff    	jbe    f010683f <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01069b4:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f01069ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01069bd:	5b                   	pop    %ebx
f01069be:	5e                   	pop    %esi
f01069bf:	5f                   	pop    %edi
f01069c0:	5d                   	pop    %ebp
f01069c1:	c3                   	ret    

f01069c2 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f01069c2:	55                   	push   %ebp
f01069c3:	89 e5                	mov    %esp,%ebp
f01069c5:	57                   	push   %edi
f01069c6:	56                   	push   %esi
f01069c7:	53                   	push   %ebx
f01069c8:	83 ec 1c             	sub    $0x1c,%esp
f01069cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f01069ce:	ba 1c 00 00 00       	mov    $0x1c,%edx
f01069d3:	89 d8                	mov    %ebx,%eax
f01069d5:	e8 0e fe ff ff       	call   f01067e8 <pci_conf_read>
f01069da:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f01069dc:	ba 18 00 00 00       	mov    $0x18,%edx
f01069e1:	89 d8                	mov    %ebx,%eax
f01069e3:	e8 00 fe ff ff       	call   f01067e8 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f01069e8:	83 e7 0f             	and    $0xf,%edi
f01069eb:	83 ff 01             	cmp    $0x1,%edi
f01069ee:	75 1f                	jne    f0106a0f <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01069f0:	ff 73 08             	pushl  0x8(%ebx)
f01069f3:	ff 73 04             	pushl  0x4(%ebx)
f01069f6:	8b 03                	mov    (%ebx),%eax
f01069f8:	ff 70 04             	pushl  0x4(%eax)
f01069fb:	68 c8 8c 10 f0       	push   $0xf0108cc8
f0106a00:	e8 58 cd ff ff       	call   f010375d <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0106a05:	83 c4 10             	add    $0x10,%esp
f0106a08:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a0d:	eb 4e                	jmp    f0106a5d <pci_bridge_attach+0x9b>
f0106a0f:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106a11:	83 ec 04             	sub    $0x4,%esp
f0106a14:	6a 08                	push   $0x8
f0106a16:	6a 00                	push   $0x0
f0106a18:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0106a1b:	57                   	push   %edi
f0106a1c:	e8 d6 ee ff ff       	call   f01058f7 <memset>
	nbus.parent_bridge = pcif;
f0106a21:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106a24:	89 f0                	mov    %esi,%eax
f0106a26:	0f b6 c4             	movzbl %ah,%eax
f0106a29:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106a2c:	83 c4 08             	add    $0x8,%esp
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f0106a2f:	89 f2                	mov    %esi,%edx
f0106a31:	c1 ea 10             	shr    $0x10,%edx
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106a34:	0f b6 f2             	movzbl %dl,%esi
f0106a37:	56                   	push   %esi
f0106a38:	50                   	push   %eax
f0106a39:	ff 73 08             	pushl  0x8(%ebx)
f0106a3c:	ff 73 04             	pushl  0x4(%ebx)
f0106a3f:	8b 03                	mov    (%ebx),%eax
f0106a41:	ff 70 04             	pushl  0x4(%eax)
f0106a44:	68 fc 8c 10 f0       	push   $0xf0108cfc
f0106a49:	e8 0f cd ff ff       	call   f010375d <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0106a4e:	83 c4 20             	add    $0x20,%esp
f0106a51:	89 f8                	mov    %edi,%eax
f0106a53:	e8 b5 fd ff ff       	call   f010680d <pci_scan_bus>
	return 1;
f0106a58:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106a60:	5b                   	pop    %ebx
f0106a61:	5e                   	pop    %esi
f0106a62:	5f                   	pop    %edi
f0106a63:	5d                   	pop    %ebp
f0106a64:	c3                   	ret    

f0106a65 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0106a65:	55                   	push   %ebp
f0106a66:	89 e5                	mov    %esp,%ebp
f0106a68:	56                   	push   %esi
f0106a69:	53                   	push   %ebx
f0106a6a:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106a6c:	83 ec 0c             	sub    $0xc,%esp
f0106a6f:	8b 48 08             	mov    0x8(%eax),%ecx
f0106a72:	8b 70 04             	mov    0x4(%eax),%esi
f0106a75:	8b 00                	mov    (%eax),%eax
f0106a77:	8b 40 04             	mov    0x4(%eax),%eax
f0106a7a:	52                   	push   %edx
f0106a7b:	89 f2                	mov    %esi,%edx
f0106a7d:	e8 b0 fc ff ff       	call   f0106732 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106a82:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106a87:	89 d8                	mov    %ebx,%eax
f0106a89:	ef                   	out    %eax,(%dx)
f0106a8a:	83 c4 10             	add    $0x10,%esp
	outl(pci_conf1_data_ioport, v);
}
f0106a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106a90:	5b                   	pop    %ebx
f0106a91:	5e                   	pop    %esi
f0106a92:	5d                   	pop    %ebp
f0106a93:	c3                   	ret    

f0106a94 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106a94:	55                   	push   %ebp
f0106a95:	89 e5                	mov    %esp,%ebp
f0106a97:	57                   	push   %edi
f0106a98:	56                   	push   %esi
f0106a99:	53                   	push   %ebx
f0106a9a:	83 ec 1c             	sub    $0x1c,%esp
f0106a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106aa0:	b9 07 00 00 00       	mov    $0x7,%ecx
f0106aa5:	ba 04 00 00 00       	mov    $0x4,%edx
f0106aaa:	89 f8                	mov    %edi,%eax
f0106aac:	e8 b4 ff ff ff       	call   f0106a65 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106ab1:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0106ab6:	89 f2                	mov    %esi,%edx
f0106ab8:	89 f8                	mov    %edi,%eax
f0106aba:	e8 29 fd ff ff       	call   f01067e8 <pci_conf_read>
f0106abf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106ac2:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0106ac7:	89 f2                	mov    %esi,%edx
f0106ac9:	89 f8                	mov    %edi,%eax
f0106acb:	e8 95 ff ff ff       	call   f0106a65 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106ad0:	89 f2                	mov    %esi,%edx
f0106ad2:	89 f8                	mov    %edi,%eax
f0106ad4:	e8 0f fd ff ff       	call   f01067e8 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106ad9:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0106ade:	85 c0                	test   %eax,%eax
f0106ae0:	0f 84 a6 00 00 00    	je     f0106b8c <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0106ae6:	8d 56 f0             	lea    -0x10(%esi),%edx
f0106ae9:	c1 ea 02             	shr    $0x2,%edx
f0106aec:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0106aef:	a8 01                	test   $0x1,%al
f0106af1:	75 2c                	jne    f0106b1f <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0106af3:	89 c2                	mov    %eax,%edx
f0106af5:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f0106af8:	83 fa 04             	cmp    $0x4,%edx
f0106afb:	0f 94 c3             	sete   %bl
f0106afe:	0f b6 db             	movzbl %bl,%ebx
f0106b01:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f0106b08:	83 e0 f0             	and    $0xfffffff0,%eax
f0106b0b:	89 c2                	mov    %eax,%edx
f0106b0d:	f7 da                	neg    %edx
f0106b0f:	21 d0                	and    %edx,%eax
f0106b11:	89 45 d8             	mov    %eax,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b17:	83 e0 f0             	and    $0xfffffff0,%eax
f0106b1a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106b1d:	eb 1a                	jmp    f0106b39 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0106b1f:	83 e0 fc             	and    $0xfffffffc,%eax
f0106b22:	89 c2                	mov    %eax,%edx
f0106b24:	f7 da                	neg    %edx
f0106b26:	21 d0                	and    %edx,%eax
f0106b28:	89 45 d8             	mov    %eax,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0106b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b2e:	83 e0 fc             	and    $0xfffffffc,%eax
f0106b31:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106b34:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0106b39:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106b3c:	89 f2                	mov    %esi,%edx
f0106b3e:	89 f8                	mov    %edi,%eax
f0106b40:	e8 20 ff ff ff       	call   f0106a65 <pci_conf_write>
f0106b45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106b48:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0106b4b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0106b4e:	89 48 14             	mov    %ecx,0x14(%eax)
		f->reg_size[regnum] = size;
f0106b51:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106b54:	89 50 2c             	mov    %edx,0x2c(%eax)

		if (size && !base)
f0106b57:	85 c9                	test   %ecx,%ecx
f0106b59:	75 31                	jne    f0106b8c <pci_func_enable+0xf8>
f0106b5b:	85 d2                	test   %edx,%edx
f0106b5d:	74 2d                	je     f0106b8c <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106b5f:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106b62:	83 ec 0c             	sub    $0xc,%esp
f0106b65:	52                   	push   %edx
f0106b66:	51                   	push   %ecx
f0106b67:	ff 75 e0             	pushl  -0x20(%ebp)
f0106b6a:	89 c2                	mov    %eax,%edx
f0106b6c:	c1 ea 10             	shr    $0x10,%edx
f0106b6f:	52                   	push   %edx
f0106b70:	0f b7 c0             	movzwl %ax,%eax
f0106b73:	50                   	push   %eax
f0106b74:	ff 77 08             	pushl  0x8(%edi)
f0106b77:	ff 77 04             	pushl  0x4(%edi)
f0106b7a:	8b 07                	mov    (%edi),%eax
f0106b7c:	ff 70 04             	pushl  0x4(%eax)
f0106b7f:	68 2c 8d 10 f0       	push   $0xf0108d2c
f0106b84:	e8 d4 cb ff ff       	call   f010375d <cprintf>
f0106b89:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106b8c:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106b8e:	83 fe 27             	cmp    $0x27,%esi
f0106b91:	0f 86 1f ff ff ff    	jbe    f0106ab6 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0106b97:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106b9a:	83 ec 08             	sub    $0x8,%esp
f0106b9d:	89 c2                	mov    %eax,%edx
f0106b9f:	c1 ea 10             	shr    $0x10,%edx
f0106ba2:	52                   	push   %edx
f0106ba3:	0f b7 c0             	movzwl %ax,%eax
f0106ba6:	50                   	push   %eax
f0106ba7:	ff 77 08             	pushl  0x8(%edi)
f0106baa:	ff 77 04             	pushl  0x4(%edi)
f0106bad:	8b 07                	mov    (%edi),%eax
f0106baf:	ff 70 04             	pushl  0x4(%eax)
f0106bb2:	68 88 8d 10 f0       	push   $0xf0108d88
f0106bb7:	e8 a1 cb ff ff       	call   f010375d <cprintf>
f0106bbc:	83 c4 20             	add    $0x20,%esp
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106bc2:	5b                   	pop    %ebx
f0106bc3:	5e                   	pop    %esi
f0106bc4:	5f                   	pop    %edi
f0106bc5:	5d                   	pop    %ebp
f0106bc6:	c3                   	ret    

f0106bc7 <pci_init>:

int
pci_init(void)
{
f0106bc7:	55                   	push   %ebp
f0106bc8:	89 e5                	mov    %esp,%ebp
f0106bca:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106bcd:	6a 08                	push   $0x8
f0106bcf:	6a 00                	push   $0x0
f0106bd1:	68 c0 8e 2a f0       	push   $0xf02a8ec0
f0106bd6:	e8 1c ed ff ff       	call   f01058f7 <memset>

	return pci_scan_bus(&root_bus);
f0106bdb:	b8 c0 8e 2a f0       	mov    $0xf02a8ec0,%eax
f0106be0:	e8 28 fc ff ff       	call   f010680d <pci_scan_bus>
}
f0106be5:	c9                   	leave  
f0106be6:	c3                   	ret    

f0106be7 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0106be7:	55                   	push   %ebp
f0106be8:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0106bea:	c7 05 c8 8e 2a f0 00 	movl   $0x0,0xf02a8ec8
f0106bf1:	00 00 00 
}
f0106bf4:	5d                   	pop    %ebp
f0106bf5:	c3                   	ret    

f0106bf6 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106bf6:	a1 c8 8e 2a f0       	mov    0xf02a8ec8,%eax
f0106bfb:	83 c0 01             	add    $0x1,%eax
f0106bfe:	a3 c8 8e 2a f0       	mov    %eax,0xf02a8ec8
	if (ticks * 10 < ticks)
f0106c03:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106c06:	01 d2                	add    %edx,%edx
f0106c08:	39 d0                	cmp    %edx,%eax
f0106c0a:	76 17                	jbe    f0106c23 <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0106c0c:	55                   	push   %ebp
f0106c0d:	89 e5                	mov    %esp,%ebp
f0106c0f:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f0106c12:	68 90 8e 10 f0       	push   $0xf0108e90
f0106c17:	6a 13                	push   $0x13
f0106c19:	68 ab 8e 10 f0       	push   $0xf0108eab
f0106c1e:	e8 1d 94 ff ff       	call   f0100040 <_panic>
f0106c23:	f3 c3                	repz ret 

f0106c25 <time_msec>:
}

unsigned int
time_msec(void)
{
f0106c25:	55                   	push   %ebp
f0106c26:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f0106c28:	a1 c8 8e 2a f0       	mov    0xf02a8ec8,%eax
f0106c2d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106c30:	01 c0                	add    %eax,%eax
}
f0106c32:	5d                   	pop    %ebp
f0106c33:	c3                   	ret    
f0106c34:	66 90                	xchg   %ax,%ax
f0106c36:	66 90                	xchg   %ax,%ax
f0106c38:	66 90                	xchg   %ax,%ax
f0106c3a:	66 90                	xchg   %ax,%ax
f0106c3c:	66 90                	xchg   %ax,%ax
f0106c3e:	66 90                	xchg   %ax,%ax

f0106c40 <__udivdi3>:
f0106c40:	55                   	push   %ebp
f0106c41:	57                   	push   %edi
f0106c42:	56                   	push   %esi
f0106c43:	83 ec 10             	sub    $0x10,%esp
f0106c46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f0106c4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0106c4e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106c52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106c56:	85 d2                	test   %edx,%edx
f0106c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c5c:	89 34 24             	mov    %esi,(%esp)
f0106c5f:	89 c8                	mov    %ecx,%eax
f0106c61:	75 35                	jne    f0106c98 <__udivdi3+0x58>
f0106c63:	39 f1                	cmp    %esi,%ecx
f0106c65:	0f 87 bd 00 00 00    	ja     f0106d28 <__udivdi3+0xe8>
f0106c6b:	85 c9                	test   %ecx,%ecx
f0106c6d:	89 cd                	mov    %ecx,%ebp
f0106c6f:	75 0b                	jne    f0106c7c <__udivdi3+0x3c>
f0106c71:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c76:	31 d2                	xor    %edx,%edx
f0106c78:	f7 f1                	div    %ecx
f0106c7a:	89 c5                	mov    %eax,%ebp
f0106c7c:	89 f0                	mov    %esi,%eax
f0106c7e:	31 d2                	xor    %edx,%edx
f0106c80:	f7 f5                	div    %ebp
f0106c82:	89 c6                	mov    %eax,%esi
f0106c84:	89 f8                	mov    %edi,%eax
f0106c86:	f7 f5                	div    %ebp
f0106c88:	89 f2                	mov    %esi,%edx
f0106c8a:	83 c4 10             	add    $0x10,%esp
f0106c8d:	5e                   	pop    %esi
f0106c8e:	5f                   	pop    %edi
f0106c8f:	5d                   	pop    %ebp
f0106c90:	c3                   	ret    
f0106c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106c98:	3b 14 24             	cmp    (%esp),%edx
f0106c9b:	77 7b                	ja     f0106d18 <__udivdi3+0xd8>
f0106c9d:	0f bd f2             	bsr    %edx,%esi
f0106ca0:	83 f6 1f             	xor    $0x1f,%esi
f0106ca3:	0f 84 97 00 00 00    	je     f0106d40 <__udivdi3+0x100>
f0106ca9:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106cae:	89 d7                	mov    %edx,%edi
f0106cb0:	89 f1                	mov    %esi,%ecx
f0106cb2:	29 f5                	sub    %esi,%ebp
f0106cb4:	d3 e7                	shl    %cl,%edi
f0106cb6:	89 c2                	mov    %eax,%edx
f0106cb8:	89 e9                	mov    %ebp,%ecx
f0106cba:	d3 ea                	shr    %cl,%edx
f0106cbc:	89 f1                	mov    %esi,%ecx
f0106cbe:	09 fa                	or     %edi,%edx
f0106cc0:	8b 3c 24             	mov    (%esp),%edi
f0106cc3:	d3 e0                	shl    %cl,%eax
f0106cc5:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106cc9:	89 e9                	mov    %ebp,%ecx
f0106ccb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106ccf:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cd3:	89 fa                	mov    %edi,%edx
f0106cd5:	d3 ea                	shr    %cl,%edx
f0106cd7:	89 f1                	mov    %esi,%ecx
f0106cd9:	d3 e7                	shl    %cl,%edi
f0106cdb:	89 e9                	mov    %ebp,%ecx
f0106cdd:	d3 e8                	shr    %cl,%eax
f0106cdf:	09 c7                	or     %eax,%edi
f0106ce1:	89 f8                	mov    %edi,%eax
f0106ce3:	f7 74 24 08          	divl   0x8(%esp)
f0106ce7:	89 d5                	mov    %edx,%ebp
f0106ce9:	89 c7                	mov    %eax,%edi
f0106ceb:	f7 64 24 0c          	mull   0xc(%esp)
f0106cef:	39 d5                	cmp    %edx,%ebp
f0106cf1:	89 14 24             	mov    %edx,(%esp)
f0106cf4:	72 11                	jb     f0106d07 <__udivdi3+0xc7>
f0106cf6:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106cfa:	89 f1                	mov    %esi,%ecx
f0106cfc:	d3 e2                	shl    %cl,%edx
f0106cfe:	39 c2                	cmp    %eax,%edx
f0106d00:	73 5e                	jae    f0106d60 <__udivdi3+0x120>
f0106d02:	3b 2c 24             	cmp    (%esp),%ebp
f0106d05:	75 59                	jne    f0106d60 <__udivdi3+0x120>
f0106d07:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106d0a:	31 f6                	xor    %esi,%esi
f0106d0c:	89 f2                	mov    %esi,%edx
f0106d0e:	83 c4 10             	add    $0x10,%esp
f0106d11:	5e                   	pop    %esi
f0106d12:	5f                   	pop    %edi
f0106d13:	5d                   	pop    %ebp
f0106d14:	c3                   	ret    
f0106d15:	8d 76 00             	lea    0x0(%esi),%esi
f0106d18:	31 f6                	xor    %esi,%esi
f0106d1a:	31 c0                	xor    %eax,%eax
f0106d1c:	89 f2                	mov    %esi,%edx
f0106d1e:	83 c4 10             	add    $0x10,%esp
f0106d21:	5e                   	pop    %esi
f0106d22:	5f                   	pop    %edi
f0106d23:	5d                   	pop    %ebp
f0106d24:	c3                   	ret    
f0106d25:	8d 76 00             	lea    0x0(%esi),%esi
f0106d28:	89 f2                	mov    %esi,%edx
f0106d2a:	31 f6                	xor    %esi,%esi
f0106d2c:	89 f8                	mov    %edi,%eax
f0106d2e:	f7 f1                	div    %ecx
f0106d30:	89 f2                	mov    %esi,%edx
f0106d32:	83 c4 10             	add    $0x10,%esp
f0106d35:	5e                   	pop    %esi
f0106d36:	5f                   	pop    %edi
f0106d37:	5d                   	pop    %ebp
f0106d38:	c3                   	ret    
f0106d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106d40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106d44:	76 0b                	jbe    f0106d51 <__udivdi3+0x111>
f0106d46:	31 c0                	xor    %eax,%eax
f0106d48:	3b 14 24             	cmp    (%esp),%edx
f0106d4b:	0f 83 37 ff ff ff    	jae    f0106c88 <__udivdi3+0x48>
f0106d51:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d56:	e9 2d ff ff ff       	jmp    f0106c88 <__udivdi3+0x48>
f0106d5b:	90                   	nop
f0106d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d60:	89 f8                	mov    %edi,%eax
f0106d62:	31 f6                	xor    %esi,%esi
f0106d64:	e9 1f ff ff ff       	jmp    f0106c88 <__udivdi3+0x48>
f0106d69:	66 90                	xchg   %ax,%ax
f0106d6b:	66 90                	xchg   %ax,%ax
f0106d6d:	66 90                	xchg   %ax,%ax
f0106d6f:	90                   	nop

f0106d70 <__umoddi3>:
f0106d70:	55                   	push   %ebp
f0106d71:	57                   	push   %edi
f0106d72:	56                   	push   %esi
f0106d73:	83 ec 20             	sub    $0x20,%esp
f0106d76:	8b 44 24 34          	mov    0x34(%esp),%eax
f0106d7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106d7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106d82:	89 c6                	mov    %eax,%esi
f0106d84:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106d88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0106d8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0106d90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106d98:	89 74 24 18          	mov    %esi,0x18(%esp)
f0106d9c:	85 c0                	test   %eax,%eax
f0106d9e:	89 c2                	mov    %eax,%edx
f0106da0:	75 1e                	jne    f0106dc0 <__umoddi3+0x50>
f0106da2:	39 f7                	cmp    %esi,%edi
f0106da4:	76 52                	jbe    f0106df8 <__umoddi3+0x88>
f0106da6:	89 c8                	mov    %ecx,%eax
f0106da8:	89 f2                	mov    %esi,%edx
f0106daa:	f7 f7                	div    %edi
f0106dac:	89 d0                	mov    %edx,%eax
f0106dae:	31 d2                	xor    %edx,%edx
f0106db0:	83 c4 20             	add    $0x20,%esp
f0106db3:	5e                   	pop    %esi
f0106db4:	5f                   	pop    %edi
f0106db5:	5d                   	pop    %ebp
f0106db6:	c3                   	ret    
f0106db7:	89 f6                	mov    %esi,%esi
f0106db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106dc0:	39 f0                	cmp    %esi,%eax
f0106dc2:	77 5c                	ja     f0106e20 <__umoddi3+0xb0>
f0106dc4:	0f bd e8             	bsr    %eax,%ebp
f0106dc7:	83 f5 1f             	xor    $0x1f,%ebp
f0106dca:	75 64                	jne    f0106e30 <__umoddi3+0xc0>
f0106dcc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0106dd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0106dd4:	0f 86 f6 00 00 00    	jbe    f0106ed0 <__umoddi3+0x160>
f0106dda:	3b 44 24 18          	cmp    0x18(%esp),%eax
f0106dde:	0f 82 ec 00 00 00    	jb     f0106ed0 <__umoddi3+0x160>
f0106de4:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106de8:	8b 54 24 18          	mov    0x18(%esp),%edx
f0106dec:	83 c4 20             	add    $0x20,%esp
f0106def:	5e                   	pop    %esi
f0106df0:	5f                   	pop    %edi
f0106df1:	5d                   	pop    %ebp
f0106df2:	c3                   	ret    
f0106df3:	90                   	nop
f0106df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106df8:	85 ff                	test   %edi,%edi
f0106dfa:	89 fd                	mov    %edi,%ebp
f0106dfc:	75 0b                	jne    f0106e09 <__umoddi3+0x99>
f0106dfe:	b8 01 00 00 00       	mov    $0x1,%eax
f0106e03:	31 d2                	xor    %edx,%edx
f0106e05:	f7 f7                	div    %edi
f0106e07:	89 c5                	mov    %eax,%ebp
f0106e09:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106e0d:	31 d2                	xor    %edx,%edx
f0106e0f:	f7 f5                	div    %ebp
f0106e11:	89 c8                	mov    %ecx,%eax
f0106e13:	f7 f5                	div    %ebp
f0106e15:	eb 95                	jmp    f0106dac <__umoddi3+0x3c>
f0106e17:	89 f6                	mov    %esi,%esi
f0106e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106e20:	89 c8                	mov    %ecx,%eax
f0106e22:	89 f2                	mov    %esi,%edx
f0106e24:	83 c4 20             	add    $0x20,%esp
f0106e27:	5e                   	pop    %esi
f0106e28:	5f                   	pop    %edi
f0106e29:	5d                   	pop    %ebp
f0106e2a:	c3                   	ret    
f0106e2b:	90                   	nop
f0106e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e30:	b8 20 00 00 00       	mov    $0x20,%eax
f0106e35:	89 e9                	mov    %ebp,%ecx
f0106e37:	29 e8                	sub    %ebp,%eax
f0106e39:	d3 e2                	shl    %cl,%edx
f0106e3b:	89 c7                	mov    %eax,%edi
f0106e3d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106e41:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106e45:	89 f9                	mov    %edi,%ecx
f0106e47:	d3 e8                	shr    %cl,%eax
f0106e49:	89 c1                	mov    %eax,%ecx
f0106e4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106e4f:	09 d1                	or     %edx,%ecx
f0106e51:	89 fa                	mov    %edi,%edx
f0106e53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106e57:	89 e9                	mov    %ebp,%ecx
f0106e59:	d3 e0                	shl    %cl,%eax
f0106e5b:	89 f9                	mov    %edi,%ecx
f0106e5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e61:	89 f0                	mov    %esi,%eax
f0106e63:	d3 e8                	shr    %cl,%eax
f0106e65:	89 e9                	mov    %ebp,%ecx
f0106e67:	89 c7                	mov    %eax,%edi
f0106e69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106e6d:	d3 e6                	shl    %cl,%esi
f0106e6f:	89 d1                	mov    %edx,%ecx
f0106e71:	89 fa                	mov    %edi,%edx
f0106e73:	d3 e8                	shr    %cl,%eax
f0106e75:	89 e9                	mov    %ebp,%ecx
f0106e77:	09 f0                	or     %esi,%eax
f0106e79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f0106e7d:	f7 74 24 10          	divl   0x10(%esp)
f0106e81:	d3 e6                	shl    %cl,%esi
f0106e83:	89 d1                	mov    %edx,%ecx
f0106e85:	f7 64 24 0c          	mull   0xc(%esp)
f0106e89:	39 d1                	cmp    %edx,%ecx
f0106e8b:	89 74 24 14          	mov    %esi,0x14(%esp)
f0106e8f:	89 d7                	mov    %edx,%edi
f0106e91:	89 c6                	mov    %eax,%esi
f0106e93:	72 0a                	jb     f0106e9f <__umoddi3+0x12f>
f0106e95:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0106e99:	73 10                	jae    f0106eab <__umoddi3+0x13b>
f0106e9b:	39 d1                	cmp    %edx,%ecx
f0106e9d:	75 0c                	jne    f0106eab <__umoddi3+0x13b>
f0106e9f:	89 d7                	mov    %edx,%edi
f0106ea1:	89 c6                	mov    %eax,%esi
f0106ea3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0106ea7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f0106eab:	89 ca                	mov    %ecx,%edx
f0106ead:	89 e9                	mov    %ebp,%ecx
f0106eaf:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106eb3:	29 f0                	sub    %esi,%eax
f0106eb5:	19 fa                	sbb    %edi,%edx
f0106eb7:	d3 e8                	shr    %cl,%eax
f0106eb9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f0106ebe:	89 d7                	mov    %edx,%edi
f0106ec0:	d3 e7                	shl    %cl,%edi
f0106ec2:	89 e9                	mov    %ebp,%ecx
f0106ec4:	09 f8                	or     %edi,%eax
f0106ec6:	d3 ea                	shr    %cl,%edx
f0106ec8:	83 c4 20             	add    $0x20,%esp
f0106ecb:	5e                   	pop    %esi
f0106ecc:	5f                   	pop    %edi
f0106ecd:	5d                   	pop    %ebp
f0106ece:	c3                   	ret    
f0106ecf:	90                   	nop
f0106ed0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106ed4:	29 f9                	sub    %edi,%ecx
f0106ed6:	19 c6                	sbb    %eax,%esi
f0106ed8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106edc:	89 74 24 18          	mov    %esi,0x18(%esp)
f0106ee0:	e9 ff fe ff ff       	jmp    f0106de4 <__umoddi3+0x74>
