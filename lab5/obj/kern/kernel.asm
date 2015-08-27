
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

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
f0100048:	83 3d c0 ae 20 f0 00 	cmpl   $0x0,0xf020aec0
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 c0 ae 20 f0    	mov    %esi,0xf020aec0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 aa 5d 00 00       	call   f0105e0b <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 c0 64 10 f0       	push   $0xf01064c0
f010006d:	e8 ae 36 00 00       	call   f0103720 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 7e 36 00 00       	call   f01036fa <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 b3 6d 10 f0 	movl   $0xf0106db3,(%esp)
f0100083:	e8 98 36 00 00       	call   f0103720 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 12 09 00 00       	call   f01009a7 <monitor>
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
f01000a1:	b8 08 c0 24 f0       	mov    $0xf024c008,%eax
f01000a6:	2d 90 9e 20 f0       	sub    $0xf0209e90,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 90 9e 20 f0       	push   $0xf0209e90
f01000b3:	e8 2e 57 00 00       	call   f01057e6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 86 05 00 00       	call   f0100643 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 2c 65 10 f0       	push   $0xf010652c
f01000ca:	e8 51 36 00 00       	call   f0103720 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 c4 12 00 00       	call   f0101398 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 ff 2e 00 00       	call   f0102fd8 <env_init>
	trap_init();
f01000d9:	e8 16 37 00 00       	call   f01037f4 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 21 5a 00 00       	call   f0105b04 <mp_init>
	lapic_init();
f01000e3:	e8 3e 5d 00 00       	call   f0105e26 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 6f 35 00 00       	call   f010365c <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 00 14 12 f0 	movl   $0xf0121400,(%esp)
f01000f4:	e8 7d 5f 00 00       	call   f0106076 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d c8 ae 20 f0 07 	cmpl   $0x7,0xf020aec8
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 e4 64 10 f0       	push   $0xf01064e4
f010010f:	6a 5f                	push   $0x5f
f0100111:	68 47 65 10 f0       	push   $0xf0106547
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 6a 5a 10 f0       	mov    $0xf0105a6a,%eax
f0100123:	2d f0 59 10 f0       	sub    $0xf01059f0,%eax
f0100128:	50                   	push   %eax
f0100129:	68 f0 59 10 f0       	push   $0xf01059f0
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 fb 56 00 00       	call   f0105833 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 40 b0 20 f0       	mov    $0xf020b040,%ebx
f0100140:	eb 4e                	jmp    f0100190 <i386_init+0xf6>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 c4 5c 00 00       	call   f0105e0b <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 3a                	je     f010018d <i386_init+0xf3>
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 40 b0 20 f0       	sub    $0xf020b040,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	8d 80 00 40 21 f0    	lea    -0xfdec000(%eax),%eax
f010016c:	a3 c4 ae 20 f0       	mov    %eax,0xf020aec4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100171:	83 ec 08             	sub    $0x8,%esp
f0100174:	68 00 70 00 00       	push   $0x7000
f0100179:	0f b6 03             	movzbl (%ebx),%eax
f010017c:	50                   	push   %eax
f010017d:	e8 f2 5d 00 00       	call   f0105f74 <lapic_startap>
f0100182:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100185:	8b 43 04             	mov    0x4(%ebx),%eax
f0100188:	83 f8 01             	cmp    $0x1,%eax
f010018b:	75 f8                	jne    f0100185 <i386_init+0xeb>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018d:	83 c3 74             	add    $0x74,%ebx
f0100190:	6b 05 e4 b3 20 f0 74 	imul   $0x74,0xf020b3e4,%eax
f0100197:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	72 a2                	jb     f0100142 <i386_init+0xa8>
        lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a0:	83 ec 08             	sub    $0x8,%esp
f01001a3:	6a 01                	push   $0x1
f01001a5:	68 7c 8c 1c f0       	push   $0xf01c8c7c
f01001aa:	e8 ba 2f 00 00       	call   f0103169 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001af:	83 c4 08             	add    $0x8,%esp
f01001b2:	6a 00                	push   $0x0
f01001b4:	68 ec 9f 1f f0       	push   $0xf01f9fec
f01001b9:	e8 ab 2f 00 00       	call   f0103169 <env_create>
        
//>>>>>>> lab4
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001be:	e8 24 04 00 00       	call   f01005e7 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c3:	e8 b4 43 00 00       	call   f010457c <sched_yield>

f01001c8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c8:	55                   	push   %ebp
f01001c9:	89 e5                	mov    %esp,%ebp
f01001cb:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001ce:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d8:	77 12                	ja     f01001ec <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001da:	50                   	push   %eax
f01001db:	68 08 65 10 f0       	push   $0xf0106508
f01001e0:	6a 76                	push   $0x76
f01001e2:	68 47 65 10 f0       	push   $0xf0106547
f01001e7:	e8 54 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001ec:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001f1:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f4:	e8 12 5c 00 00       	call   f0105e0b <cpunum>
f01001f9:	83 ec 08             	sub    $0x8,%esp
f01001fc:	50                   	push   %eax
f01001fd:	68 53 65 10 f0       	push   $0xf0106553
f0100202:	e8 19 35 00 00       	call   f0103720 <cprintf>

	lapic_init();
f0100207:	e8 1a 5c 00 00       	call   f0105e26 <lapic_init>
	env_init_percpu();
f010020c:	e8 9d 2d 00 00       	call   f0102fae <env_init_percpu>
	trap_init_percpu();
f0100211:	e8 1e 35 00 00       	call   f0103734 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100216:	e8 f0 5b 00 00       	call   f0105e0b <cpunum>
f010021b:	6b d0 74             	imul   $0x74,%eax,%edx
f010021e:	81 c2 40 b0 20 f0    	add    $0xf020b040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100224:	b8 01 00 00 00       	mov    $0x1,%eax
f0100229:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022d:	c7 04 24 00 14 12 f0 	movl   $0xf0121400,(%esp)
f0100234:	e8 3d 5e 00 00       	call   f0106076 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100239:	e8 3e 43 00 00       	call   f010457c <sched_yield>

f010023e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	53                   	push   %ebx
f0100242:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100245:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100248:	ff 75 0c             	pushl  0xc(%ebp)
f010024b:	ff 75 08             	pushl  0x8(%ebp)
f010024e:	68 69 65 10 f0       	push   $0xf0106569
f0100253:	e8 c8 34 00 00       	call   f0103720 <cprintf>
	vcprintf(fmt, ap);
f0100258:	83 c4 08             	add    $0x8,%esp
f010025b:	53                   	push   %ebx
f010025c:	ff 75 10             	pushl  0x10(%ebp)
f010025f:	e8 96 34 00 00       	call   f01036fa <vcprintf>
	cprintf("\n");
f0100264:	c7 04 24 b3 6d 10 f0 	movl   $0xf0106db3,(%esp)
f010026b:	e8 b0 34 00 00       	call   f0103720 <cprintf>
	va_end(ap);
f0100270:	83 c4 10             	add    $0x10,%esp
}
f0100273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100276:	c9                   	leave  
f0100277:	c3                   	ret    

f0100278 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100278:	55                   	push   %ebp
f0100279:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100280:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100281:	a8 01                	test   $0x1,%al
f0100283:	74 08                	je     f010028d <serial_proc_data+0x15>
f0100285:	b2 f8                	mov    $0xf8,%dl
f0100287:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100288:	0f b6 c0             	movzbl %al,%eax
f010028b:	eb 05                	jmp    f0100292 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100292:	5d                   	pop    %ebp
f0100293:	c3                   	ret    

f0100294 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100294:	55                   	push   %ebp
f0100295:	89 e5                	mov    %esp,%ebp
f0100297:	53                   	push   %ebx
f0100298:	83 ec 04             	sub    $0x4,%esp
f010029b:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029d:	eb 2a                	jmp    f01002c9 <cons_intr+0x35>
		if (c == 0)
f010029f:	85 d2                	test   %edx,%edx
f01002a1:	74 26                	je     f01002c9 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a3:	a1 44 a2 20 f0       	mov    0xf020a244,%eax
f01002a8:	8d 48 01             	lea    0x1(%eax),%ecx
f01002ab:	89 0d 44 a2 20 f0    	mov    %ecx,0xf020a244
f01002b1:	88 90 40 a0 20 f0    	mov    %dl,-0xfdf5fc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002b7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002bd:	75 0a                	jne    f01002c9 <cons_intr+0x35>
			cons.wpos = 0;
f01002bf:	c7 05 44 a2 20 f0 00 	movl   $0x0,0xf020a244
f01002c6:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002c9:	ff d3                	call   *%ebx
f01002cb:	89 c2                	mov    %eax,%edx
f01002cd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d0:	75 cd                	jne    f010029f <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d2:	83 c4 04             	add    $0x4,%esp
f01002d5:	5b                   	pop    %ebx
f01002d6:	5d                   	pop    %ebp
f01002d7:	c3                   	ret    

f01002d8 <kbd_proc_data>:
f01002d8:	ba 64 00 00 00       	mov    $0x64,%edx
f01002dd:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002de:	a8 01                	test   $0x1,%al
f01002e0:	0f 84 f0 00 00 00    	je     f01003d6 <kbd_proc_data+0xfe>
f01002e6:	b2 60                	mov    $0x60,%dl
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002eb:	3c e0                	cmp    $0xe0,%al
f01002ed:	75 0d                	jne    f01002fc <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01002ef:	83 0d 00 a0 20 f0 40 	orl    $0x40,0xf020a000
		return 0;
f01002f6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002fb:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002fc:	55                   	push   %ebp
f01002fd:	89 e5                	mov    %esp,%ebp
f01002ff:	53                   	push   %ebx
f0100300:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100303:	84 c0                	test   %al,%al
f0100305:	79 36                	jns    f010033d <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100307:	8b 0d 00 a0 20 f0    	mov    0xf020a000,%ecx
f010030d:	89 cb                	mov    %ecx,%ebx
f010030f:	83 e3 40             	and    $0x40,%ebx
f0100312:	83 e0 7f             	and    $0x7f,%eax
f0100315:	85 db                	test   %ebx,%ebx
f0100317:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031a:	0f b6 d2             	movzbl %dl,%edx
f010031d:	0f b6 82 00 67 10 f0 	movzbl -0xfef9900(%edx),%eax
f0100324:	83 c8 40             	or     $0x40,%eax
f0100327:	0f b6 c0             	movzbl %al,%eax
f010032a:	f7 d0                	not    %eax
f010032c:	21 c8                	and    %ecx,%eax
f010032e:	a3 00 a0 20 f0       	mov    %eax,0xf020a000
		return 0;
f0100333:	b8 00 00 00 00       	mov    $0x0,%eax
f0100338:	e9 a1 00 00 00       	jmp    f01003de <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010033d:	8b 0d 00 a0 20 f0    	mov    0xf020a000,%ecx
f0100343:	f6 c1 40             	test   $0x40,%cl
f0100346:	74 0e                	je     f0100356 <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100348:	83 c8 80             	or     $0xffffff80,%eax
f010034b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010034d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100350:	89 0d 00 a0 20 f0    	mov    %ecx,0xf020a000
	}

	shift |= shiftcode[data];
f0100356:	0f b6 c2             	movzbl %dl,%eax
f0100359:	0f b6 90 00 67 10 f0 	movzbl -0xfef9900(%eax),%edx
f0100360:	0b 15 00 a0 20 f0    	or     0xf020a000,%edx
	shift ^= togglecode[data];
f0100366:	0f b6 88 00 66 10 f0 	movzbl -0xfef9a00(%eax),%ecx
f010036d:	31 ca                	xor    %ecx,%edx
f010036f:	89 15 00 a0 20 f0    	mov    %edx,0xf020a000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100375:	89 d1                	mov    %edx,%ecx
f0100377:	83 e1 03             	and    $0x3,%ecx
f010037a:	8b 0c 8d c0 65 10 f0 	mov    -0xfef9a40(,%ecx,4),%ecx
f0100381:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100385:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100388:	f6 c2 08             	test   $0x8,%dl
f010038b:	74 1b                	je     f01003a8 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010038d:	89 d8                	mov    %ebx,%eax
f010038f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100392:	83 f9 19             	cmp    $0x19,%ecx
f0100395:	77 05                	ja     f010039c <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100397:	83 eb 20             	sub    $0x20,%ebx
f010039a:	eb 0c                	jmp    f01003a8 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010039c:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010039f:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003a2:	83 f8 19             	cmp    $0x19,%eax
f01003a5:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003a8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003ae:	75 2c                	jne    f01003dc <kbd_proc_data+0x104>
f01003b0:	f7 d2                	not    %edx
f01003b2:	f6 c2 06             	test   $0x6,%dl
f01003b5:	75 25                	jne    f01003dc <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003b7:	83 ec 0c             	sub    $0xc,%esp
f01003ba:	68 83 65 10 f0       	push   $0xf0106583
f01003bf:	e8 5c 33 00 00       	call   f0103720 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c4:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c9:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ce:	ee                   	out    %al,(%dx)
f01003cf:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d2:	89 d8                	mov    %ebx,%eax
f01003d4:	eb 08                	jmp    f01003de <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003db:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003dc:	89 d8                	mov    %ebx,%eax
}
f01003de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003e1:	c9                   	leave  
f01003e2:	c3                   	ret    

f01003e3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e3:	55                   	push   %ebp
f01003e4:	89 e5                	mov    %esp,%ebp
f01003e6:	57                   	push   %edi
f01003e7:	56                   	push   %esi
f01003e8:	53                   	push   %ebx
f01003e9:	83 ec 1c             	sub    $0x1c,%esp
f01003ec:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ee:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fd:	eb 09                	jmp    f0100408 <cons_putc+0x25>
f01003ff:	89 ca                	mov    %ecx,%edx
f0100401:	ec                   	in     (%dx),%al
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100405:	83 c3 01             	add    $0x1,%ebx
f0100408:	89 f2                	mov    %esi,%edx
f010040a:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040b:	a8 20                	test   $0x20,%al
f010040d:	75 08                	jne    f0100417 <cons_putc+0x34>
f010040f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100415:	7e e8                	jle    f01003ff <cons_putc+0x1c>
f0100417:	89 f8                	mov    %edi,%eax
f0100419:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100421:	89 f8                	mov    %edi,%eax
f0100423:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100424:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100429:	be 79 03 00 00       	mov    $0x379,%esi
f010042e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100433:	eb 09                	jmp    f010043e <cons_putc+0x5b>
f0100435:	89 ca                	mov    %ecx,%edx
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	83 c3 01             	add    $0x1,%ebx
f010043e:	89 f2                	mov    %esi,%edx
f0100440:	ec                   	in     (%dx),%al
f0100441:	84 c0                	test   %al,%al
f0100443:	78 08                	js     f010044d <cons_putc+0x6a>
f0100445:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010044b:	7e e8                	jle    f0100435 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100452:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100456:	ee                   	out    %al,(%dx)
f0100457:	b2 7a                	mov    $0x7a,%dl
f0100459:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045e:	ee                   	out    %al,(%dx)
f010045f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100464:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100465:	89 fa                	mov    %edi,%edx
f0100467:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010046d:	89 f8                	mov    %edi,%eax
f010046f:	80 cc 07             	or     $0x7,%ah
f0100472:	85 d2                	test   %edx,%edx
f0100474:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100477:	89 f8                	mov    %edi,%eax
f0100479:	0f b6 c0             	movzbl %al,%eax
f010047c:	83 f8 09             	cmp    $0x9,%eax
f010047f:	74 74                	je     f01004f5 <cons_putc+0x112>
f0100481:	83 f8 09             	cmp    $0x9,%eax
f0100484:	7f 0a                	jg     f0100490 <cons_putc+0xad>
f0100486:	83 f8 08             	cmp    $0x8,%eax
f0100489:	74 14                	je     f010049f <cons_putc+0xbc>
f010048b:	e9 99 00 00 00       	jmp    f0100529 <cons_putc+0x146>
f0100490:	83 f8 0a             	cmp    $0xa,%eax
f0100493:	74 3a                	je     f01004cf <cons_putc+0xec>
f0100495:	83 f8 0d             	cmp    $0xd,%eax
f0100498:	74 3d                	je     f01004d7 <cons_putc+0xf4>
f010049a:	e9 8a 00 00 00       	jmp    f0100529 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f010049f:	0f b7 05 48 a2 20 f0 	movzwl 0xf020a248,%eax
f01004a6:	66 85 c0             	test   %ax,%ax
f01004a9:	0f 84 e6 00 00 00    	je     f0100595 <cons_putc+0x1b2>
			crt_pos--;
f01004af:	83 e8 01             	sub    $0x1,%eax
f01004b2:	66 a3 48 a2 20 f0    	mov    %ax,0xf020a248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b8:	0f b7 c0             	movzwl %ax,%eax
f01004bb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c0:	83 cf 20             	or     $0x20,%edi
f01004c3:	8b 15 4c a2 20 f0    	mov    0xf020a24c,%edx
f01004c9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cd:	eb 78                	jmp    f0100547 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004cf:	66 83 05 48 a2 20 f0 	addw   $0x50,0xf020a248
f01004d6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d7:	0f b7 05 48 a2 20 f0 	movzwl 0xf020a248,%eax
f01004de:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e4:	c1 e8 16             	shr    $0x16,%eax
f01004e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ea:	c1 e0 04             	shl    $0x4,%eax
f01004ed:	66 a3 48 a2 20 f0    	mov    %ax,0xf020a248
f01004f3:	eb 52                	jmp    f0100547 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01004f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fa:	e8 e4 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f01004ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0100504:	e8 da fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100509:	b8 20 00 00 00       	mov    $0x20,%eax
f010050e:	e8 d0 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100513:	b8 20 00 00 00       	mov    $0x20,%eax
f0100518:	e8 c6 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f010051d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100522:	e8 bc fe ff ff       	call   f01003e3 <cons_putc>
f0100527:	eb 1e                	jmp    f0100547 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100529:	0f b7 05 48 a2 20 f0 	movzwl 0xf020a248,%eax
f0100530:	8d 50 01             	lea    0x1(%eax),%edx
f0100533:	66 89 15 48 a2 20 f0 	mov    %dx,0xf020a248
f010053a:	0f b7 c0             	movzwl %ax,%eax
f010053d:	8b 15 4c a2 20 f0    	mov    0xf020a24c,%edx
f0100543:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100547:	66 81 3d 48 a2 20 f0 	cmpw   $0x7cf,0xf020a248
f010054e:	cf 07 
f0100550:	76 43                	jbe    f0100595 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100552:	a1 4c a2 20 f0       	mov    0xf020a24c,%eax
f0100557:	83 ec 04             	sub    $0x4,%esp
f010055a:	68 00 0f 00 00       	push   $0xf00
f010055f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100565:	52                   	push   %edx
f0100566:	50                   	push   %eax
f0100567:	e8 c7 52 00 00       	call   f0105833 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056c:	8b 15 4c a2 20 f0    	mov    0xf020a24c,%edx
f0100572:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100578:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010057e:	83 c4 10             	add    $0x10,%esp
f0100581:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100586:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100589:	39 d0                	cmp    %edx,%eax
f010058b:	75 f4                	jne    f0100581 <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010058d:	66 83 2d 48 a2 20 f0 	subw   $0x50,0xf020a248
f0100594:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100595:	8b 0d 50 a2 20 f0    	mov    0xf020a250,%ecx
f010059b:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a3:	0f b7 1d 48 a2 20 f0 	movzwl 0xf020a248,%ebx
f01005aa:	8d 71 01             	lea    0x1(%ecx),%esi
f01005ad:	89 d8                	mov    %ebx,%eax
f01005af:	66 c1 e8 08          	shr    $0x8,%ax
f01005b3:	89 f2                	mov    %esi,%edx
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bb:	89 ca                	mov    %ecx,%edx
f01005bd:	ee                   	out    %al,(%dx)
f01005be:	89 d8                	mov    %ebx,%eax
f01005c0:	89 f2                	mov    %esi,%edx
f01005c2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c6:	5b                   	pop    %ebx
f01005c7:	5e                   	pop    %esi
f01005c8:	5f                   	pop    %edi
f01005c9:	5d                   	pop    %ebp
f01005ca:	c3                   	ret    

f01005cb <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005cb:	80 3d 54 a2 20 f0 00 	cmpb   $0x0,0xf020a254
f01005d2:	74 11                	je     f01005e5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d4:	55                   	push   %ebp
f01005d5:	89 e5                	mov    %esp,%ebp
f01005d7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005da:	b8 78 02 10 f0       	mov    $0xf0100278,%eax
f01005df:	e8 b0 fc ff ff       	call   f0100294 <cons_intr>
}
f01005e4:	c9                   	leave  
f01005e5:	f3 c3                	repz ret 

f01005e7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ed:	b8 d8 02 10 f0       	mov    $0xf01002d8,%eax
f01005f2:	e8 9d fc ff ff       	call   f0100294 <cons_intr>
}
f01005f7:	c9                   	leave  
f01005f8:	c3                   	ret    

f01005f9 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
f01005fc:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ff:	e8 c7 ff ff ff       	call   f01005cb <serial_intr>
	kbd_intr();
f0100604:	e8 de ff ff ff       	call   f01005e7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100609:	a1 40 a2 20 f0       	mov    0xf020a240,%eax
f010060e:	3b 05 44 a2 20 f0    	cmp    0xf020a244,%eax
f0100614:	74 26                	je     f010063c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100616:	8d 50 01             	lea    0x1(%eax),%edx
f0100619:	89 15 40 a2 20 f0    	mov    %edx,0xf020a240
f010061f:	0f b6 88 40 a0 20 f0 	movzbl -0xfdf5fc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100626:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100628:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010062e:	75 11                	jne    f0100641 <cons_getc+0x48>
			cons.rpos = 0;
f0100630:	c7 05 40 a2 20 f0 00 	movl   $0x0,0xf020a240
f0100637:	00 00 00 
f010063a:	eb 05                	jmp    f0100641 <cons_getc+0x48>
		return c;
	}
	return 0;
f010063c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100641:	c9                   	leave  
f0100642:	c3                   	ret    

f0100643 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100643:	55                   	push   %ebp
f0100644:	89 e5                	mov    %esp,%ebp
f0100646:	57                   	push   %edi
f0100647:	56                   	push   %esi
f0100648:	53                   	push   %ebx
f0100649:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010064c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100653:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065a:	5a a5 
	if (*cp != 0xA55A) {
f010065c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100663:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100667:	74 11                	je     f010067a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100669:	c7 05 50 a2 20 f0 b4 	movl   $0x3b4,0xf020a250
f0100670:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100673:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100678:	eb 16                	jmp    f0100690 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010067a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100681:	c7 05 50 a2 20 f0 d4 	movl   $0x3d4,0xf020a250
f0100688:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010068b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100690:	8b 3d 50 a2 20 f0    	mov    0xf020a250,%edi
f0100696:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069b:	89 fa                	mov    %edi,%edx
f010069d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069e:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a1:	89 ca                	mov    %ecx,%edx
f01006a3:	ec                   	in     (%dx),%al
f01006a4:	0f b6 c0             	movzbl %al,%eax
f01006a7:	c1 e0 08             	shl    $0x8,%eax
f01006aa:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b1:	89 fa                	mov    %edi,%edx
f01006b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b4:	89 ca                	mov    %ecx,%edx
f01006b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b7:	89 35 4c a2 20 f0    	mov    %esi,0xf020a24c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006bd:	0f b6 c8             	movzbl %al,%ecx
f01006c0:	89 d8                	mov    %ebx,%eax
f01006c2:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006c4:	66 a3 48 a2 20 f0    	mov    %ax,0xf020a248

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ca:	e8 18 ff ff ff       	call   f01005e7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006cf:	83 ec 0c             	sub    $0xc,%esp
f01006d2:	0f b7 05 e8 13 12 f0 	movzwl 0xf01213e8,%eax
f01006d9:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006de:	50                   	push   %eax
f01006df:	e8 03 2f 00 00       	call   f01035e7 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ee:	89 da                	mov    %ebx,%edx
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	b2 fb                	mov    $0xfb,%dl
f01006f3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f8:	ee                   	out    %al,(%dx)
f01006f9:	be f8 03 00 00       	mov    $0x3f8,%esi
f01006fe:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100703:	89 f2                	mov    %esi,%edx
f0100705:	ee                   	out    %al,(%dx)
f0100706:	b2 f9                	mov    $0xf9,%dl
f0100708:	b8 00 00 00 00       	mov    $0x0,%eax
f010070d:	ee                   	out    %al,(%dx)
f010070e:	b2 fb                	mov    $0xfb,%dl
f0100710:	b8 03 00 00 00       	mov    $0x3,%eax
f0100715:	ee                   	out    %al,(%dx)
f0100716:	b2 fc                	mov    $0xfc,%dl
f0100718:	b8 00 00 00 00       	mov    $0x0,%eax
f010071d:	ee                   	out    %al,(%dx)
f010071e:	b2 f9                	mov    $0xf9,%dl
f0100720:	b8 01 00 00 00       	mov    $0x1,%eax
f0100725:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100726:	b2 fd                	mov    $0xfd,%dl
f0100728:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100729:	83 c4 10             	add    $0x10,%esp
f010072c:	3c ff                	cmp    $0xff,%al
f010072e:	0f 95 c1             	setne  %cl
f0100731:	88 0d 54 a2 20 f0    	mov    %cl,0xf020a254
f0100737:	89 da                	mov    %ebx,%edx
f0100739:	ec                   	in     (%dx),%al
f010073a:	89 f2                	mov    %esi,%edx
f010073c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010073d:	84 c9                	test   %cl,%cl
f010073f:	74 21                	je     f0100762 <cons_init+0x11f>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100741:	83 ec 0c             	sub    $0xc,%esp
f0100744:	0f b7 05 e8 13 12 f0 	movzwl 0xf01213e8,%eax
f010074b:	25 ef ff 00 00       	and    $0xffef,%eax
f0100750:	50                   	push   %eax
f0100751:	e8 91 2e 00 00       	call   f01035e7 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100756:	83 c4 10             	add    $0x10,%esp
f0100759:	80 3d 54 a2 20 f0 00 	cmpb   $0x0,0xf020a254
f0100760:	75 10                	jne    f0100772 <cons_init+0x12f>
		cprintf("Serial port does not exist!\n");
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	68 8f 65 10 f0       	push   $0xf010658f
f010076a:	e8 b1 2f 00 00       	call   f0103720 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
}
f0100772:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100775:	5b                   	pop    %ebx
f0100776:	5e                   	pop    %esi
f0100777:	5f                   	pop    %edi
f0100778:	5d                   	pop    %ebp
f0100779:	c3                   	ret    

f010077a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077a:	55                   	push   %ebp
f010077b:	89 e5                	mov    %esp,%ebp
f010077d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	e8 5b fc ff ff       	call   f01003e3 <cons_putc>
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <getchar>:

int
getchar(void)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100790:	e8 64 fe ff ff       	call   f01005f9 <cons_getc>
f0100795:	85 c0                	test   %eax,%eax
f0100797:	74 f7                	je     f0100790 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100799:	c9                   	leave  
f010079a:	c3                   	ret    

f010079b <iscons>:

int
iscons(int fdnum)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010079e:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    

f01007a5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a5:	55                   	push   %ebp
f01007a6:	89 e5                	mov    %esp,%ebp
f01007a8:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ab:	68 00 68 10 f0       	push   $0xf0106800
f01007b0:	68 1e 68 10 f0       	push   $0xf010681e
f01007b5:	68 23 68 10 f0       	push   $0xf0106823
f01007ba:	e8 61 2f 00 00       	call   f0103720 <cprintf>
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	68 d0 68 10 f0       	push   $0xf01068d0
f01007c7:	68 2c 68 10 f0       	push   $0xf010682c
f01007cc:	68 23 68 10 f0       	push   $0xf0106823
f01007d1:	e8 4a 2f 00 00       	call   f0103720 <cprintf>
f01007d6:	83 c4 0c             	add    $0xc,%esp
f01007d9:	68 35 68 10 f0       	push   $0xf0106835
f01007de:	68 48 68 10 f0       	push   $0xf0106848
f01007e3:	68 23 68 10 f0       	push   $0xf0106823
f01007e8:	e8 33 2f 00 00       	call   f0103720 <cprintf>
	return 0;
}
f01007ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f2:	c9                   	leave  
f01007f3:	c3                   	ret    

f01007f4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f4:	55                   	push   %ebp
f01007f5:	89 e5                	mov    %esp,%ebp
f01007f7:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fa:	68 52 68 10 f0       	push   $0xf0106852
f01007ff:	e8 1c 2f 00 00       	call   f0103720 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100804:	83 c4 08             	add    $0x8,%esp
f0100807:	68 0c 00 10 00       	push   $0x10000c
f010080c:	68 f8 68 10 f0       	push   $0xf01068f8
f0100811:	e8 0a 2f 00 00       	call   f0103720 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	68 0c 00 10 00       	push   $0x10000c
f010081e:	68 0c 00 10 f0       	push   $0xf010000c
f0100823:	68 20 69 10 f0       	push   $0xf0106920
f0100828:	e8 f3 2e 00 00       	call   f0103720 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082d:	83 c4 0c             	add    $0xc,%esp
f0100830:	68 a5 64 10 00       	push   $0x1064a5
f0100835:	68 a5 64 10 f0       	push   $0xf01064a5
f010083a:	68 44 69 10 f0       	push   $0xf0106944
f010083f:	e8 dc 2e 00 00       	call   f0103720 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100844:	83 c4 0c             	add    $0xc,%esp
f0100847:	68 90 9e 20 00       	push   $0x209e90
f010084c:	68 90 9e 20 f0       	push   $0xf0209e90
f0100851:	68 68 69 10 f0       	push   $0xf0106968
f0100856:	e8 c5 2e 00 00       	call   f0103720 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085b:	83 c4 0c             	add    $0xc,%esp
f010085e:	68 08 c0 24 00       	push   $0x24c008
f0100863:	68 08 c0 24 f0       	push   $0xf024c008
f0100868:	68 8c 69 10 f0       	push   $0xf010698c
f010086d:	e8 ae 2e 00 00       	call   f0103720 <cprintf>
f0100872:	b8 07 c4 24 f0       	mov    $0xf024c407,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100877:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010087f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100884:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010088a:	85 c0                	test   %eax,%eax
f010088c:	0f 48 c2             	cmovs  %edx,%eax
f010088f:	c1 f8 0a             	sar    $0xa,%eax
f0100892:	50                   	push   %eax
f0100893:	68 b0 69 10 f0       	push   $0xf01069b0
f0100898:	e8 83 2e 00 00       	call   f0103720 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010089d:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a2:	c9                   	leave  
f01008a3:	c3                   	ret    

f01008a4 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a4:	55                   	push   %ebp
f01008a5:	89 e5                	mov    %esp,%ebp
f01008a7:	57                   	push   %edi
f01008a8:	56                   	push   %esi
f01008a9:	53                   	push   %ebx
f01008aa:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b0:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f01008b2:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f01008b4:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f01008b7:	8b 50 08             	mov    0x8(%eax),%edx
f01008ba:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f01008bc:	8b 48 0c             	mov    0xc(%eax),%ecx
f01008bf:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f01008c5:	8b 50 10             	mov    0x10(%eax),%edx
f01008c8:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f01008ce:	8b 48 14             	mov    0x14(%eax),%ecx
f01008d1:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f01008d7:	8b 40 18             	mov    0x18(%eax),%eax
f01008da:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f01008e0:	68 6b 68 10 f0       	push   $0xf010686b
f01008e5:	e8 36 2e 00 00       	call   f0103720 <cprintf>
        while(ebp != 0) {
f01008ea:	83 c4 10             	add    $0x10,%esp
f01008ed:	89 f8                	mov    %edi,%eax
f01008ef:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f01008f5:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f01008fb:	e9 92 00 00 00       	jmp    f0100992 <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f0100900:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0100906:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f010090c:	51                   	push   %ecx
f010090d:	52                   	push   %edx
f010090e:	50                   	push   %eax
f010090f:	56                   	push   %esi
f0100910:	53                   	push   %ebx
f0100911:	68 dc 69 10 f0       	push   $0xf01069dc
f0100916:	e8 05 2e 00 00       	call   f0103720 <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f010091b:	83 c4 18             	add    $0x18,%esp
f010091e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100924:	50                   	push   %eax
f0100925:	56                   	push   %esi
f0100926:	e8 34 44 00 00       	call   f0104d5f <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f010092b:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f0100931:	68 d6 6a 10 f0       	push   $0xf0106ad6
f0100936:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f010093c:	83 c0 01             	add    $0x1,%eax
f010093f:	50                   	push   %eax
f0100940:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100943:	50                   	push   %eax
f0100944:	e8 14 4c 00 00       	call   f010555d <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f0100949:	83 c4 14             	add    $0x14,%esp
f010094c:	89 f0                	mov    %esi,%eax
f010094e:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f0100954:	50                   	push   %eax
f0100955:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100958:	50                   	push   %eax
f0100959:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f010095f:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f0100965:	68 7d 68 10 f0       	push   $0xf010687d
f010096a:	e8 b1 2d 00 00       	call   f0103720 <cprintf>
             ebp = (uint32_t *)ebp[0];
f010096f:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f0100971:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f0100974:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f0100977:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f010097a:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f010097d:	8b 7b 14             	mov    0x14(%ebx),%edi
f0100980:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f0100986:	8b 7b 18             	mov    0x18(%ebx),%edi
f0100989:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f010098f:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f0100992:	85 db                	test   %ebx,%ebx
f0100994:	0f 85 66 ff ff ff    	jne    f0100900 <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f010099a:	b8 00 00 00 00       	mov    $0x0,%eax
f010099f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a2:	5b                   	pop    %ebx
f01009a3:	5e                   	pop    %esi
f01009a4:	5f                   	pop    %edi
f01009a5:	5d                   	pop    %ebp
f01009a6:	c3                   	ret    

f01009a7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	57                   	push   %edi
f01009ab:	56                   	push   %esi
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009b0:	68 14 6a 10 f0       	push   $0xf0106a14
f01009b5:	e8 66 2d 00 00       	call   f0103720 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ba:	c7 04 24 38 6a 10 f0 	movl   $0xf0106a38,(%esp)
f01009c1:	e8 5a 2d 00 00       	call   f0103720 <cprintf>

	if (tf != NULL)
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009cd:	74 0e                	je     f01009dd <monitor+0x36>
		print_trapframe(tf);
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	ff 75 08             	pushl  0x8(%ebp)
f01009d5:	e8 c1 34 00 00       	call   f0103e9b <print_trapframe>
f01009da:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009dd:	83 ec 0c             	sub    $0xc,%esp
f01009e0:	68 94 68 10 f0       	push   $0xf0106894
f01009e5:	e8 8d 4b 00 00       	call   f0105577 <readline>
f01009ea:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	74 ea                	je     f01009dd <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009f3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009fa:	be 00 00 00 00       	mov    $0x0,%esi
f01009ff:	eb 0a                	jmp    f0100a0b <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a01:	c6 03 00             	movb   $0x0,(%ebx)
f0100a04:	89 f7                	mov    %esi,%edi
f0100a06:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a09:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 03             	movzbl (%ebx),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	74 63                	je     f0100a75 <monitor+0xce>
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	0f be c0             	movsbl %al,%eax
f0100a18:	50                   	push   %eax
f0100a19:	68 98 68 10 f0       	push   $0xf0106898
f0100a1e:	e8 86 4d 00 00       	call   f01057a9 <strchr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	75 d7                	jne    f0100a01 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a2a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a2d:	74 46                	je     f0100a75 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a2f:	83 fe 0f             	cmp    $0xf,%esi
f0100a32:	75 14                	jne    f0100a48 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a34:	83 ec 08             	sub    $0x8,%esp
f0100a37:	6a 10                	push   $0x10
f0100a39:	68 9d 68 10 f0       	push   $0xf010689d
f0100a3e:	e8 dd 2c 00 00       	call   f0103720 <cprintf>
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	eb 95                	jmp    f01009dd <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a48:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a4b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a4f:	eb 03                	jmp    f0100a54 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a51:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a54:	0f b6 03             	movzbl (%ebx),%eax
f0100a57:	84 c0                	test   %al,%al
f0100a59:	74 ae                	je     f0100a09 <monitor+0x62>
f0100a5b:	83 ec 08             	sub    $0x8,%esp
f0100a5e:	0f be c0             	movsbl %al,%eax
f0100a61:	50                   	push   %eax
f0100a62:	68 98 68 10 f0       	push   $0xf0106898
f0100a67:	e8 3d 4d 00 00       	call   f01057a9 <strchr>
f0100a6c:	83 c4 10             	add    $0x10,%esp
f0100a6f:	85 c0                	test   %eax,%eax
f0100a71:	74 de                	je     f0100a51 <monitor+0xaa>
f0100a73:	eb 94                	jmp    f0100a09 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a75:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a7c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a7d:	85 f6                	test   %esi,%esi
f0100a7f:	0f 84 58 ff ff ff    	je     f01009dd <monitor+0x36>
f0100a85:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8a:	83 ec 08             	sub    $0x8,%esp
f0100a8d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a90:	ff 34 85 60 6a 10 f0 	pushl  -0xfef95a0(,%eax,4)
f0100a97:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9a:	e8 ac 4c 00 00       	call   f010574b <strcmp>
f0100a9f:	83 c4 10             	add    $0x10,%esp
f0100aa2:	85 c0                	test   %eax,%eax
f0100aa4:	75 22                	jne    f0100ac8 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100aa6:	83 ec 04             	sub    $0x4,%esp
f0100aa9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aac:	ff 75 08             	pushl  0x8(%ebp)
f0100aaf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab2:	52                   	push   %edx
f0100ab3:	56                   	push   %esi
f0100ab4:	ff 14 85 68 6a 10 f0 	call   *-0xfef9598(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100abb:	83 c4 10             	add    $0x10,%esp
f0100abe:	85 c0                	test   %eax,%eax
f0100ac0:	0f 89 17 ff ff ff    	jns    f01009dd <monitor+0x36>
f0100ac6:	eb 20                	jmp    f0100ae8 <monitor+0x141>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ac8:	83 c3 01             	add    $0x1,%ebx
f0100acb:	83 fb 03             	cmp    $0x3,%ebx
f0100ace:	75 ba                	jne    f0100a8a <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad0:	83 ec 08             	sub    $0x8,%esp
f0100ad3:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ad6:	68 ba 68 10 f0       	push   $0xf01068ba
f0100adb:	e8 40 2c 00 00       	call   f0103720 <cprintf>
f0100ae0:	83 c4 10             	add    $0x10,%esp
f0100ae3:	e9 f5 fe ff ff       	jmp    f01009dd <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aeb:	5b                   	pop    %ebx
f0100aec:	5e                   	pop    %esi
f0100aed:	5f                   	pop    %edi
f0100aee:	5d                   	pop    %ebp
f0100aef:	c3                   	ret    

f0100af0 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af0:	83 3d 58 a2 20 f0 00 	cmpl   $0x0,0xf020a258
f0100af7:	75 11                	jne    f0100b0a <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100af9:	ba 07 d0 24 f0       	mov    $0xf024d007,%edx
f0100afe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b04:	89 15 58 a2 20 f0    	mov    %edx,0xf020a258
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
f0100b0a:	85 c0                	test   %eax,%eax
f0100b0c:	74 3d                	je     f0100b4b <boot_alloc+0x5b>
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100b0e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

		result = nextfree;
f0100b14:	a1 58 a2 20 f0       	mov    0xf020a258,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100b19:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		result = nextfree;
		nextfree += alloc_size;
f0100b1f:	01 c2                	add    %eax,%edx
f0100b21:	89 15 58 a2 20 f0    	mov    %edx,0xf020a258

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
f0100b27:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100b2d:	76 21                	jbe    f0100b50 <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b2f:	55                   	push   %ebp
f0100b30:	89 e5                	mov    %esp,%ebp
f0100b32:	83 ec 0c             	sub    $0xc,%esp

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
f0100b35:	a3 58 a2 20 f0       	mov    %eax,0xf020a258
                     result = NULL;
                     panic("boot_alloc: out of memory");
f0100b3a:	68 84 6a 10 f0       	push   $0xf0106a84
f0100b3f:	6a 75                	push   $0x75
f0100b41:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100b46:	e8 f5 f4 ff ff       	call   f0100040 <_panic>
                }

        
	} else {
		result = nextfree;
f0100b4b:	a1 58 a2 20 f0       	mov    0xf020a258,%eax
	}
	return result;
	
}
f0100b50:	f3 c3                	repz ret 

f0100b52 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b52:	89 d1                	mov    %edx,%ecx
f0100b54:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b57:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b5a:	a8 01                	test   $0x1,%al
f0100b5c:	74 52                	je     f0100bb0 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b63:	89 c1                	mov    %eax,%ecx
f0100b65:	c1 e9 0c             	shr    $0xc,%ecx
f0100b68:	3b 0d c8 ae 20 f0    	cmp    0xf020aec8,%ecx
f0100b6e:	72 1b                	jb     f0100b8b <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b70:	55                   	push   %ebp
f0100b71:	89 e5                	mov    %esp,%ebp
f0100b73:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b76:	50                   	push   %eax
f0100b77:	68 e4 64 10 f0       	push   $0xf01064e4
f0100b7c:	68 9a 03 00 00       	push   $0x39a
f0100b81:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100b86:	e8 b5 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b8b:	c1 ea 0c             	shr    $0xc,%edx
f0100b8e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b94:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b9b:	89 c2                	mov    %eax,%edx
f0100b9d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ba5:	85 d2                	test   %edx,%edx
f0100ba7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bac:	0f 44 c2             	cmove  %edx,%eax
f0100baf:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bb5:	c3                   	ret    

f0100bb6 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bb6:	55                   	push   %ebp
f0100bb7:	89 e5                	mov    %esp,%ebp
f0100bb9:	57                   	push   %edi
f0100bba:	56                   	push   %esi
f0100bbb:	53                   	push   %ebx
f0100bbc:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bbf:	84 c0                	test   %al,%al
f0100bc1:	0f 85 a2 02 00 00    	jne    f0100e69 <check_page_free_list+0x2b3>
f0100bc7:	e9 af 02 00 00       	jmp    f0100e7b <check_page_free_list+0x2c5>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bcc:	83 ec 04             	sub    $0x4,%esp
f0100bcf:	68 e8 6d 10 f0       	push   $0xf0106de8
f0100bd4:	68 d0 02 00 00       	push   $0x2d0
f0100bd9:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100bde:	e8 5d f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100be3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100be6:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100be9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bef:	89 c2                	mov    %eax,%edx
f0100bf1:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bf7:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bfd:	0f 95 c2             	setne  %dl
f0100c00:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c03:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c07:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c09:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0d:	8b 00                	mov    (%eax),%eax
f0100c0f:	85 c0                	test   %eax,%eax
f0100c11:	75 dc                	jne    f0100bef <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c1f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c22:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c24:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c27:	a3 60 a2 20 f0       	mov    %eax,0xf020a260
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c2c:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c31:	8b 1d 60 a2 20 f0    	mov    0xf020a260,%ebx
f0100c37:	eb 53                	jmp    f0100c8c <check_page_free_list+0xd6>
f0100c39:	89 d8                	mov    %ebx,%eax
f0100c3b:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0100c41:	c1 f8 03             	sar    $0x3,%eax
f0100c44:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c47:	89 c2                	mov    %eax,%edx
f0100c49:	c1 ea 16             	shr    $0x16,%edx
f0100c4c:	39 f2                	cmp    %esi,%edx
f0100c4e:	73 3a                	jae    f0100c8a <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c50:	89 c2                	mov    %eax,%edx
f0100c52:	c1 ea 0c             	shr    $0xc,%edx
f0100c55:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0100c5b:	72 12                	jb     f0100c6f <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c5d:	50                   	push   %eax
f0100c5e:	68 e4 64 10 f0       	push   $0xf01064e4
f0100c63:	6a 58                	push   $0x58
f0100c65:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0100c6a:	e8 d1 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c6f:	83 ec 04             	sub    $0x4,%esp
f0100c72:	68 80 00 00 00       	push   $0x80
f0100c77:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c7c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c81:	50                   	push   %eax
f0100c82:	e8 5f 4b 00 00       	call   f01057e6 <memset>
f0100c87:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c8a:	8b 1b                	mov    (%ebx),%ebx
f0100c8c:	85 db                	test   %ebx,%ebx
f0100c8e:	75 a9                	jne    f0100c39 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c90:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c95:	e8 56 fe ff ff       	call   f0100af0 <boot_alloc>
f0100c9a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9d:	8b 15 60 a2 20 f0    	mov    0xf020a260,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ca3:	8b 0d d0 ae 20 f0    	mov    0xf020aed0,%ecx
		assert(pp < pages + npages);
f0100ca9:	a1 c8 ae 20 f0       	mov    0xf020aec8,%eax
f0100cae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100cb1:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cb7:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cbc:	be 00 00 00 00       	mov    $0x0,%esi
f0100cc1:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100cc4:	89 d8                	mov    %ebx,%eax
f0100cc6:	89 cb                	mov    %ecx,%ebx
f0100cc8:	89 c1                	mov    %eax,%ecx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cca:	e9 55 01 00 00       	jmp    f0100e24 <check_page_free_list+0x26e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ccf:	39 da                	cmp    %ebx,%edx
f0100cd1:	73 19                	jae    f0100cec <check_page_free_list+0x136>
f0100cd3:	68 b8 6a 10 f0       	push   $0xf0106ab8
f0100cd8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100cdd:	68 ea 02 00 00       	push   $0x2ea
f0100ce2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100ce7:	e8 54 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cec:	39 ca                	cmp    %ecx,%edx
f0100cee:	72 19                	jb     f0100d09 <check_page_free_list+0x153>
f0100cf0:	68 d9 6a 10 f0       	push   $0xf0106ad9
f0100cf5:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100cfa:	68 eb 02 00 00       	push   $0x2eb
f0100cff:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100d04:	e8 37 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d09:	89 d0                	mov    %edx,%eax
f0100d0b:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d0e:	a8 07                	test   $0x7,%al
f0100d10:	74 19                	je     f0100d2b <check_page_free_list+0x175>
f0100d12:	68 0c 6e 10 f0       	push   $0xf0106e0c
f0100d17:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100d1c:	68 ec 02 00 00       	push   $0x2ec
f0100d21:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100d26:	e8 15 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d2b:	c1 f8 03             	sar    $0x3,%eax
f0100d2e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d31:	85 c0                	test   %eax,%eax
f0100d33:	75 19                	jne    f0100d4e <check_page_free_list+0x198>
f0100d35:	68 ed 6a 10 f0       	push   $0xf0106aed
f0100d3a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100d3f:	68 ef 02 00 00       	push   $0x2ef
f0100d44:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100d49:	e8 f2 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d4e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d53:	75 19                	jne    f0100d6e <check_page_free_list+0x1b8>
f0100d55:	68 fe 6a 10 f0       	push   $0xf0106afe
f0100d5a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100d5f:	68 f0 02 00 00       	push   $0x2f0
f0100d64:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100d69:	e8 d2 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d6e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d73:	75 19                	jne    f0100d8e <check_page_free_list+0x1d8>
f0100d75:	68 40 6e 10 f0       	push   $0xf0106e40
f0100d7a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100d7f:	68 f1 02 00 00       	push   $0x2f1
f0100d84:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100d89:	e8 b2 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d8e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d93:	75 19                	jne    f0100dae <check_page_free_list+0x1f8>
f0100d95:	68 17 6b 10 f0       	push   $0xf0106b17
f0100d9a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100d9f:	68 f2 02 00 00       	push   $0x2f2
f0100da4:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100da9:	e8 92 f2 ff ff       	call   f0100040 <_panic>
f0100dae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100db1:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db6:	0f 86 d6 00 00 00    	jbe    f0100e92 <check_page_free_list+0x2dc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dbc:	89 c6                	mov    %eax,%esi
f0100dbe:	c1 ee 0c             	shr    $0xc,%esi
f0100dc1:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100dc4:	77 12                	ja     f0100dd8 <check_page_free_list+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc6:	50                   	push   %eax
f0100dc7:	68 e4 64 10 f0       	push   $0xf01064e4
f0100dcc:	6a 58                	push   $0x58
f0100dce:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dd8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
f0100dde:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0100de1:	0f 86 b7 00 00 00    	jbe    f0100e9e <check_page_free_list+0x2e8>
f0100de7:	68 64 6e 10 f0       	push   $0xf0106e64
f0100dec:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100df1:	68 f3 02 00 00       	push   $0x2f3
f0100df6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100dfb:	e8 40 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e00:	68 31 6b 10 f0       	push   $0xf0106b31
f0100e05:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100e0a:	68 f5 02 00 00       	push   $0x2f5
f0100e0f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100e14:	e8 27 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e19:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100e1d:	eb 03                	jmp    f0100e22 <check_page_free_list+0x26c>
		else
			++nfree_extmem;
f0100e1f:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e22:	8b 12                	mov    (%edx),%edx
f0100e24:	85 d2                	test   %edx,%edx
f0100e26:	0f 85 a3 fe ff ff    	jne    f0100ccf <check_page_free_list+0x119>
f0100e2c:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e2f:	85 f6                	test   %esi,%esi
f0100e31:	7f 19                	jg     f0100e4c <check_page_free_list+0x296>
f0100e33:	68 4e 6b 10 f0       	push   $0xf0106b4e
f0100e38:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100e3d:	68 fd 02 00 00       	push   $0x2fd
f0100e42:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100e47:	e8 f4 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e4c:	85 ff                	test   %edi,%edi
f0100e4e:	7f 5e                	jg     f0100eae <check_page_free_list+0x2f8>
f0100e50:	68 60 6b 10 f0       	push   $0xf0106b60
f0100e55:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0100e5a:	68 fe 02 00 00       	push   $0x2fe
f0100e5f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100e64:	e8 d7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e69:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f0100e6e:	85 c0                	test   %eax,%eax
f0100e70:	0f 85 6d fd ff ff    	jne    f0100be3 <check_page_free_list+0x2d>
f0100e76:	e9 51 fd ff ff       	jmp    f0100bcc <check_page_free_list+0x16>
f0100e7b:	83 3d 60 a2 20 f0 00 	cmpl   $0x0,0xf020a260
f0100e82:	0f 84 44 fd ff ff    	je     f0100bcc <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e88:	be 00 04 00 00       	mov    $0x400,%esi
f0100e8d:	e9 9f fd ff ff       	jmp    f0100c31 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e92:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e97:	75 80                	jne    f0100e19 <check_page_free_list+0x263>
f0100e99:	e9 62 ff ff ff       	jmp    f0100e00 <check_page_free_list+0x24a>
f0100e9e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea3:	0f 85 76 ff ff ff    	jne    f0100e1f <check_page_free_list+0x269>
f0100ea9:	e9 52 ff ff ff       	jmp    f0100e00 <check_page_free_list+0x24a>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb1:	5b                   	pop    %ebx
f0100eb2:	5e                   	pop    %esi
f0100eb3:	5f                   	pop    %edi
f0100eb4:	5d                   	pop    %ebp
f0100eb5:	c3                   	ret    

f0100eb6 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eb6:	55                   	push   %ebp
f0100eb7:	89 e5                	mov    %esp,%ebp
f0100eb9:	56                   	push   %esi
f0100eba:	53                   	push   %ebx
f0100ebb:	8b 1d 60 a2 20 f0    	mov    0xf020a260,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ec1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ec6:	eb 22                	jmp    f0100eea <page_init+0x34>
f0100ec8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100ecf:	89 d1                	mov    %edx,%ecx
f0100ed1:	03 0d d0 ae 20 f0    	add    0xf020aed0,%ecx
f0100ed7:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100edd:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100edf:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100ee2:	89 d3                	mov    %edx,%ebx
f0100ee4:	03 1d d0 ae 20 f0    	add    0xf020aed0,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100eea:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f0100ef0:	72 d6                	jb     f0100ec8 <page_init+0x12>
f0100ef2:	89 1d 60 a2 20 f0    	mov    %ebx,0xf020a260
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
        pages[0].pp_ref = 1; 
f0100ef8:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
f0100efd:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
        pages[1].pp_link = pages[0].pp_link;
f0100f03:	8b 10                	mov    (%eax),%edx
f0100f05:	89 50 08             	mov    %edx,0x8(%eax)
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
f0100f08:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0d:	e8 de fb ff ff       	call   f0100af0 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f12:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f17:	77 15                	ja     f0100f2e <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f19:	50                   	push   %eax
f0100f1a:	68 08 65 10 f0       	push   $0xf0106508
f0100f1f:	68 51 01 00 00       	push   $0x151
f0100f24:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0100f29:	e8 12 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f2e:	05 00 00 00 10       	add    $0x10000000,%eax
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
f0100f33:	8b 15 d0 ae 20 f0    	mov    0xf020aed0,%edx
f0100f39:	8b b2 00 05 00 00    	mov    0x500(%edx),%esi
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f3f:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0100f44:	eb 20                	jmp    f0100f66 <page_init+0xb0>
              pages[i/PGSIZE].pp_ref = 1;  
f0100f46:	89 d3                	mov    %edx,%ebx
f0100f48:	c1 eb 0c             	shr    $0xc,%ebx
f0100f4b:	8b 0d d0 ae 20 f0    	mov    0xf020aed0,%ecx
f0100f51:	8d 0c d9             	lea    (%ecx,%ebx,8),%ecx
f0100f54:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
              pages[i/PGSIZE].pp_link = NULL;     
f0100f5a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
        pages[0].pp_ref = 1; 
        pages[1].pp_link = pages[0].pp_link;
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f60:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100f66:	39 c2                	cmp    %eax,%edx
f0100f68:	72 dc                	jb     f0100f46 <page_init+0x90>
              pages[i/PGSIZE].pp_ref = 1;  
              pages[i/PGSIZE].pp_link = NULL;     
        }      
        pages[i/PGSIZE].pp_link = p;
f0100f6a:	c1 ea 0c             	shr    $0xc,%edx
f0100f6d:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
f0100f72:	89 34 d0             	mov    %esi,(%eax,%edx,8)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f75:	83 3d c8 ae 20 f0 07 	cmpl   $0x7,0xf020aec8
f0100f7c:	77 14                	ja     f0100f92 <page_init+0xdc>
		panic("pa2page called with invalid pa");
f0100f7e:	83 ec 04             	sub    $0x4,%esp
f0100f81:	68 ac 6e 10 f0       	push   $0xf0106eac
f0100f86:	6a 51                	push   $0x51
f0100f88:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0100f8d:	e8 ae f0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100f92:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
        p = pa2page(MPENTRY_PADDR);
        (p + 1)->pp_link = p->pp_link;
f0100f97:	8b 50 38             	mov    0x38(%eax),%edx
f0100f9a:	89 50 40             	mov    %edx,0x40(%eax)
        p->pp_ref = 1;
f0100f9d:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
        p->pp_link = NULL;
f0100fa3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
}
f0100faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fad:	5b                   	pop    %ebx
f0100fae:	5e                   	pop    %esi
f0100faf:	5d                   	pop    %ebp
f0100fb0:	c3                   	ret    

f0100fb1 <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
       if ( page_free_list ) {
f0100fb1:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f0100fb6:	85 c0                	test   %eax,%eax
f0100fb8:	74 63                	je     f010101d <page_alloc+0x6c>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in
       if ( page_free_list ) {
            if(alloc_flags & ALLOC_ZERO) 
f0100fc0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fc4:	74 43                	je     f0101009 <page_alloc+0x58>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fc6:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0100fcc:	c1 f8 03             	sar    $0x3,%eax
f0100fcf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd2:	89 c2                	mov    %eax,%edx
f0100fd4:	c1 ea 0c             	shr    $0xc,%edx
f0100fd7:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0100fdd:	72 12                	jb     f0100ff1 <page_alloc+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fdf:	50                   	push   %eax
f0100fe0:	68 e4 64 10 f0       	push   $0xf01064e4
f0100fe5:	6a 58                	push   $0x58
f0100fe7:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0100fec:	e8 4f f0 ff ff       	call   f0100040 <_panic>
                memset(page2kva(page_free_list), 0, PGSIZE);
f0100ff1:	83 ec 04             	sub    $0x4,%esp
f0100ff4:	68 00 10 00 00       	push   $0x1000
f0100ff9:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100ffb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101000:	50                   	push   %eax
f0101001:	e8 e0 47 00 00       	call   f01057e6 <memset>
f0101006:	83 c4 10             	add    $0x10,%esp
               
                struct PageInfo *tmp = page_free_list;
f0101009:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
                 
                page_free_list = page_free_list->pp_link;
f010100e:	8b 10                	mov    (%eax),%edx
f0101010:	89 15 60 a2 20 f0    	mov    %edx,0xf020a260
                tmp->pp_link = NULL;
f0101016:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                      
                return tmp; 
            
        }
	return NULL;
}
f010101c:	c9                   	leave  
f010101d:	f3 c3                	repz ret 

f010101f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	83 ec 08             	sub    $0x8,%esp
f0101025:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.    
        if(pp == NULL) return;
f0101028:	85 c0                	test   %eax,%eax
f010102a:	74 30                	je     f010105c <page_free+0x3d>
        if (pp->pp_ref != 0 || pp->pp_link != NULL)
f010102c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101031:	75 05                	jne    f0101038 <page_free+0x19>
f0101033:	83 38 00             	cmpl   $0x0,(%eax)
f0101036:	74 17                	je     f010104f <page_free+0x30>
            panic("page_free: invalid page free\n");
f0101038:	83 ec 04             	sub    $0x4,%esp
f010103b:	68 71 6b 10 f0       	push   $0xf0106b71
f0101040:	68 89 01 00 00       	push   $0x189
f0101045:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010104a:	e8 f1 ef ff ff       	call   f0100040 <_panic>
        else {
            pp->pp_link = page_free_list;
f010104f:	8b 15 60 a2 20 f0    	mov    0xf020a260,%edx
f0101055:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f0101057:	a3 60 a2 20 f0       	mov    %eax,0xf020a260
        }
}
f010105c:	c9                   	leave  
f010105d:	c3                   	ret    

f010105e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010105e:	55                   	push   %ebp
f010105f:	89 e5                	mov    %esp,%ebp
f0101061:	83 ec 08             	sub    $0x8,%esp
f0101064:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101067:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010106b:	83 e8 01             	sub    $0x1,%eax
f010106e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101072:	66 85 c0             	test   %ax,%ax
f0101075:	75 0c                	jne    f0101083 <page_decref+0x25>
		page_free(pp);
f0101077:	83 ec 0c             	sub    $0xc,%esp
f010107a:	52                   	push   %edx
f010107b:	e8 9f ff ff ff       	call   f010101f <page_free>
f0101080:	83 c4 10             	add    $0x10,%esp
}
f0101083:	c9                   	leave  
f0101084:	c3                   	ret    

f0101085 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101085:	55                   	push   %ebp
f0101086:	89 e5                	mov    %esp,%ebp
f0101088:	56                   	push   %esi
f0101089:	53                   	push   %ebx
f010108a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t * pte;
        if ((pgdir[PDX(va)] & PTE_P) != 0) {
f010108d:	89 de                	mov    %ebx,%esi
f010108f:	c1 ee 16             	shr    $0x16,%esi
f0101092:	c1 e6 02             	shl    $0x2,%esi
f0101095:	03 75 08             	add    0x8(%ebp),%esi
f0101098:	8b 06                	mov    (%esi),%eax
f010109a:	a8 01                	test   $0x1,%al
f010109c:	74 3c                	je     f01010da <pgdir_walk+0x55>
                pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f010109e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a3:	89 c2                	mov    %eax,%edx
f01010a5:	c1 ea 0c             	shr    $0xc,%edx
f01010a8:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f01010ae:	72 15                	jb     f01010c5 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b0:	50                   	push   %eax
f01010b1:	68 e4 64 10 f0       	push   $0xf01064e4
f01010b6:	68 b7 01 00 00       	push   $0x1b7
f01010bb:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01010c0:	e8 7b ef ff ff       	call   f0100040 <_panic>
                return pte + PTX(va);  
f01010c5:	c1 eb 0a             	shr    $0xa,%ebx
f01010c8:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01010ce:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01010d5:	e9 81 00 00 00       	jmp    f010115b <pgdir_walk+0xd6>

 
        } 
        
        if(create != 0) {
f01010da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010de:	74 6f                	je     f010114f <pgdir_walk+0xca>
               struct PageInfo *tmp;
               tmp = page_alloc(1);
f01010e0:	83 ec 0c             	sub    $0xc,%esp
f01010e3:	6a 01                	push   $0x1
f01010e5:	e8 c7 fe ff ff       	call   f0100fb1 <page_alloc>
       
               if(tmp != NULL) {
f01010ea:	83 c4 10             	add    $0x10,%esp
f01010ed:	85 c0                	test   %eax,%eax
f01010ef:	74 65                	je     f0101156 <pgdir_walk+0xd1>
                       
                        
                       tmp->pp_ref += 1;
f01010f1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
                       tmp->pp_link = NULL;
f01010f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010fc:	89 c2                	mov    %eax,%edx
f01010fe:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f0101104:	c1 fa 03             	sar    $0x3,%edx
f0101107:	c1 e2 0c             	shl    $0xc,%edx
                       pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
f010110a:	83 ca 07             	or     $0x7,%edx
f010110d:	89 16                	mov    %edx,(%esi)
f010110f:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0101115:	c1 f8 03             	sar    $0x3,%eax
f0101118:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010111b:	89 c2                	mov    %eax,%edx
f010111d:	c1 ea 0c             	shr    $0xc,%edx
f0101120:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0101126:	72 15                	jb     f010113d <pgdir_walk+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101128:	50                   	push   %eax
f0101129:	68 e4 64 10 f0       	push   $0xf01064e4
f010112e:	68 c7 01 00 00       	push   $0x1c7
f0101133:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101138:	e8 03 ef ff ff       	call   f0100040 <_panic>
                       pte = (pte_t *)KADDR(page2pa(tmp));
                  
                       return pte+PTX(va); 
f010113d:	c1 eb 0a             	shr    $0xa,%ebx
f0101140:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101146:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010114d:	eb 0c                	jmp    f010115b <pgdir_walk+0xd6>

               }
               
        }

	return NULL;
f010114f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101154:	eb 05                	jmp    f010115b <pgdir_walk+0xd6>
f0101156:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010115b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010115e:	5b                   	pop    %ebx
f010115f:	5e                   	pop    %esi
f0101160:	5d                   	pop    %ebp
f0101161:	c3                   	ret    

f0101162 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101162:	55                   	push   %ebp
f0101163:	89 e5                	mov    %esp,%ebp
f0101165:	57                   	push   %edi
f0101166:	56                   	push   %esi
f0101167:	53                   	push   %ebx
f0101168:	83 ec 1c             	sub    $0x1c,%esp
f010116b:	89 c7                	mov    %eax,%edi
f010116d:	89 55 e0             	mov    %edx,-0x20(%ebp)
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
f0101170:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0101176:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010117c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f010117f:	be 00 00 00 00       	mov    $0x0,%esi
f0101184:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101187:	83 c8 01             	or     $0x1,%eax
f010118a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010118d:	eb 3d                	jmp    f01011cc <boot_map_region+0x6a>
              tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
f010118f:	83 ec 04             	sub    $0x4,%esp
f0101192:	6a 01                	push   $0x1
f0101194:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101197:	01 f0                	add    %esi,%eax
f0101199:	50                   	push   %eax
f010119a:	57                   	push   %edi
f010119b:	e8 e5 fe ff ff       	call   f0101085 <pgdir_walk>
              if ( tmp == NULL ) {
f01011a0:	83 c4 10             	add    $0x10,%esp
f01011a3:	85 c0                	test   %eax,%eax
f01011a5:	75 17                	jne    f01011be <boot_map_region+0x5c>
                     panic("boot_map_region: fail\n");
f01011a7:	83 ec 04             	sub    $0x4,%esp
f01011aa:	68 8f 6b 10 f0       	push   $0xf0106b8f
f01011af:	68 e7 01 00 00       	push   $0x1e7
f01011b4:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01011b9:	e8 82 ee ff ff       	call   f0100040 <_panic>
f01011be:	03 5d 08             	add    0x8(%ebp),%ebx
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
f01011c1:	0b 5d dc             	or     -0x24(%ebp),%ebx
f01011c4:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f01011c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01011cc:	89 f3                	mov    %esi,%ebx
f01011ce:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01011d1:	77 bc                	ja     f010118f <boot_map_region+0x2d>
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
 
        }
}
f01011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011d6:	5b                   	pop    %ebx
f01011d7:	5e                   	pop    %esi
f01011d8:	5f                   	pop    %edi
f01011d9:	5d                   	pop    %ebp
f01011da:	c3                   	ret    

f01011db <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011db:	55                   	push   %ebp
f01011dc:	89 e5                	mov    %esp,%ebp
f01011de:	53                   	push   %ebx
f01011df:	83 ec 08             	sub    $0x8,%esp
f01011e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 0);
f01011e5:	6a 00                	push   $0x0
f01011e7:	ff 75 0c             	pushl  0xc(%ebp)
f01011ea:	ff 75 08             	pushl  0x8(%ebp)
f01011ed:	e8 93 fe ff ff       	call   f0101085 <pgdir_walk>
        if ( tmp != NULL && (*tmp & PTE_P)) {
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	85 c0                	test   %eax,%eax
f01011f7:	74 37                	je     f0101230 <page_lookup+0x55>
f01011f9:	f6 00 01             	testb  $0x1,(%eax)
f01011fc:	74 39                	je     f0101237 <page_lookup+0x5c>
                if(pte_store != NULL) 
f01011fe:	85 db                	test   %ebx,%ebx
f0101200:	74 02                	je     f0101204 <page_lookup+0x29>
                        *pte_store = tmp;
f0101202:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101204:	8b 00                	mov    (%eax),%eax
f0101206:	c1 e8 0c             	shr    $0xc,%eax
f0101209:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f010120f:	72 14                	jb     f0101225 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101211:	83 ec 04             	sub    $0x4,%esp
f0101214:	68 ac 6e 10 f0       	push   $0xf0106eac
f0101219:	6a 51                	push   $0x51
f010121b:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0101220:	e8 1b ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101225:	8b 15 d0 ae 20 f0    	mov    0xf020aed0,%edx
f010122b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
                return (struct PageInfo *)pa2page(*tmp);
f010122e:	eb 0c                	jmp    f010123c <page_lookup+0x61>

        }
	return NULL;
f0101230:	b8 00 00 00 00       	mov    $0x0,%eax
f0101235:	eb 05                	jmp    f010123c <page_lookup+0x61>
f0101237:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010123f:	c9                   	leave  
f0101240:	c3                   	ret    

f0101241 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101241:	55                   	push   %ebp
f0101242:	89 e5                	mov    %esp,%ebp
f0101244:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
//<<<<<<< HEAD
	if (!curenv || curenv->env_pgdir == pgdir)
f0101247:	e8 bf 4b 00 00       	call   f0105e0b <cpunum>
f010124c:	6b c0 74             	imul   $0x74,%eax,%eax
f010124f:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0101256:	74 16                	je     f010126e <tlb_invalidate+0x2d>
f0101258:	e8 ae 4b 00 00       	call   f0105e0b <cpunum>
f010125d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101260:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0101266:	8b 55 08             	mov    0x8(%ebp),%edx
f0101269:	39 50 60             	cmp    %edx,0x60(%eax)
f010126c:	75 06                	jne    f0101274 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010126e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101271:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101274:	c9                   	leave  
f0101275:	c3                   	ret    

f0101276 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101276:	55                   	push   %ebp
f0101277:	89 e5                	mov    %esp,%ebp
f0101279:	56                   	push   %esi
f010127a:	53                   	push   %ebx
f010127b:	83 ec 14             	sub    $0x14,%esp
f010127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101281:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f0101284:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101287:	50                   	push   %eax
f0101288:	56                   	push   %esi
f0101289:	53                   	push   %ebx
f010128a:	e8 4c ff ff ff       	call   f01011db <page_lookup>
        if( tmp != NULL && (*tmppte & PTE_P)) {
f010128f:	83 c4 10             	add    $0x10,%esp
f0101292:	85 c0                	test   %eax,%eax
f0101294:	74 1d                	je     f01012b3 <page_remove+0x3d>
f0101296:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101299:	f6 02 01             	testb  $0x1,(%edx)
f010129c:	74 15                	je     f01012b3 <page_remove+0x3d>
                page_decref(tmp);
f010129e:	83 ec 0c             	sub    $0xc,%esp
f01012a1:	50                   	push   %eax
f01012a2:	e8 b7 fd ff ff       	call   f010105e <page_decref>
                *tmppte = 0;
f01012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01012b0:	83 c4 10             	add    $0x10,%esp
        }
        tlb_invalidate(pgdir, va);
f01012b3:	83 ec 08             	sub    $0x8,%esp
f01012b6:	56                   	push   %esi
f01012b7:	53                   	push   %ebx
f01012b8:	e8 84 ff ff ff       	call   f0101241 <tlb_invalidate>
f01012bd:	83 c4 10             	add    $0x10,%esp
}
f01012c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c3:	5b                   	pop    %ebx
f01012c4:	5e                   	pop    %esi
f01012c5:	5d                   	pop    %ebp
f01012c6:	c3                   	ret    

f01012c7 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012c7:	55                   	push   %ebp
f01012c8:	89 e5                	mov    %esp,%ebp
f01012ca:	57                   	push   %edi
f01012cb:	56                   	push   %esi
f01012cc:	53                   	push   %ebx
f01012cd:	83 ec 10             	sub    $0x10,%esp
f01012d0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012d3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
f01012d6:	6a 01                	push   $0x1
f01012d8:	57                   	push   %edi
f01012d9:	ff 75 08             	pushl  0x8(%ebp)
f01012dc:	e8 a4 fd ff ff       	call   f0101085 <pgdir_walk>
f01012e1:	89 c3                	mov    %eax,%ebx
         
        if( tmp == NULL )
f01012e3:	83 c4 10             	add    $0x10,%esp
f01012e6:	85 c0                	test   %eax,%eax
f01012e8:	74 3e                	je     f0101328 <page_insert+0x61>
                return -E_NO_MEM;

        pp->pp_ref += 1;
f01012ea:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if( (*tmp & PTE_P) != 0 )
f01012ef:	f6 00 01             	testb  $0x1,(%eax)
f01012f2:	74 0f                	je     f0101303 <page_insert+0x3c>
                page_remove(pgdir, va);
f01012f4:	83 ec 08             	sub    $0x8,%esp
f01012f7:	57                   	push   %edi
f01012f8:	ff 75 08             	pushl  0x8(%ebp)
f01012fb:	e8 76 ff ff ff       	call   f0101276 <page_remove>
f0101300:	83 c4 10             	add    $0x10,%esp
f0101303:	8b 55 14             	mov    0x14(%ebp),%edx
f0101306:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101309:	89 f0                	mov    %esi,%eax
f010130b:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0101311:	c1 f8 03             	sar    $0x3,%eax
f0101314:	c1 e0 0c             	shl    $0xc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
f0101317:	09 d0                	or     %edx,%eax
f0101319:	89 03                	mov    %eax,(%ebx)
        pp->pp_link = NULL;
f010131b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return 0;
f0101321:	b8 00 00 00 00       	mov    $0x0,%eax
f0101326:	eb 05                	jmp    f010132d <page_insert+0x66>
{
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        if( tmp == NULL )
                return -E_NO_MEM;
f0101328:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
                page_remove(pgdir, va);
         
        *tmp = page2pa(pp) | perm | PTE_P;
        pp->pp_link = NULL;
	return 0;
}
f010132d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101330:	5b                   	pop    %ebx
f0101331:	5e                   	pop    %esi
f0101332:	5f                   	pop    %edi
f0101333:	5d                   	pop    %ebp
f0101334:	c3                   	ret    

f0101335 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101335:	55                   	push   %ebp
f0101336:	89 e5                	mov    %esp,%ebp
f0101338:	53                   	push   %ebx
f0101339:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t roundsize = ROUNDUP(size, PGSIZE);
f010133c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010133f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101345:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if( base + roundsize >= MMIOLIM )
f010134b:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101351:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101354:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101359:	76 17                	jbe    f0101372 <mmio_map_region+0x3d>
                panic("Lapic required too much memory\n");
f010135b:	83 ec 04             	sub    $0x4,%esp
f010135e:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0101363:	68 7e 02 00 00       	push   $0x27e
f0101368:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010136d:	e8 ce ec ff ff       	call   f0100040 <_panic>
        boot_map_region(kern_pgdir, base, roundsize, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101372:	83 ec 08             	sub    $0x8,%esp
f0101375:	6a 1a                	push   $0x1a
f0101377:	ff 75 08             	pushl  0x8(%ebp)
f010137a:	89 d9                	mov    %ebx,%ecx
f010137c:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0101381:	e8 dc fd ff ff       	call   f0101162 <boot_map_region>
        base += roundsize; 
f0101386:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f010138b:	01 c3                	add    %eax,%ebx
f010138d:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	//panic("mmio_map_region not implemented");
        return (void *)(base - roundsize);
}
f0101393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101396:	c9                   	leave  
f0101397:	c3                   	ret    

f0101398 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101398:	55                   	push   %ebp
f0101399:	89 e5                	mov    %esp,%ebp
f010139b:	57                   	push   %edi
f010139c:	56                   	push   %esi
f010139d:	53                   	push   %ebx
f010139e:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013a1:	6a 15                	push   $0x15
f01013a3:	e8 17 22 00 00       	call   f01035bf <mc146818_read>
f01013a8:	89 c3                	mov    %eax,%ebx
f01013aa:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013b1:	e8 09 22 00 00       	call   f01035bf <mc146818_read>
f01013b6:	c1 e0 08             	shl    $0x8,%eax
f01013b9:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013bb:	c1 e0 0a             	shl    $0xa,%eax
f01013be:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	0f 48 c2             	cmovs  %edx,%eax
f01013c9:	c1 f8 0c             	sar    $0xc,%eax
f01013cc:	a3 64 a2 20 f0       	mov    %eax,0xf020a264
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013d1:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013d8:	e8 e2 21 00 00       	call   f01035bf <mc146818_read>
f01013dd:	89 c3                	mov    %eax,%ebx
f01013df:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013e6:	e8 d4 21 00 00       	call   f01035bf <mc146818_read>
f01013eb:	c1 e0 08             	shl    $0x8,%eax
f01013ee:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01013f0:	c1 e0 0a             	shl    $0xa,%eax
f01013f3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013f9:	83 c4 10             	add    $0x10,%esp
f01013fc:	85 c0                	test   %eax,%eax
f01013fe:	0f 48 c2             	cmovs  %edx,%eax
f0101401:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101404:	85 c0                	test   %eax,%eax
f0101406:	74 0e                	je     f0101416 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101408:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010140e:	89 15 c8 ae 20 f0    	mov    %edx,0xf020aec8
f0101414:	eb 0c                	jmp    f0101422 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101416:	8b 15 64 a2 20 f0    	mov    0xf020a264,%edx
f010141c:	89 15 c8 ae 20 f0    	mov    %edx,0xf020aec8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101422:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101425:	c1 e8 0a             	shr    $0xa,%eax
f0101428:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101429:	a1 64 a2 20 f0       	mov    0xf020a264,%eax
f010142e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101431:	c1 e8 0a             	shr    $0xa,%eax
f0101434:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101435:	a1 c8 ae 20 f0       	mov    0xf020aec8,%eax
f010143a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010143d:	c1 e8 0a             	shr    $0xa,%eax
f0101440:	50                   	push   %eax
f0101441:	68 ec 6e 10 f0       	push   $0xf0106eec
f0101446:	e8 d5 22 00 00       	call   f0103720 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010144b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101450:	e8 9b f6 ff ff       	call   f0100af0 <boot_alloc>
f0101455:	a3 cc ae 20 f0       	mov    %eax,0xf020aecc
	memset(kern_pgdir, 0, PGSIZE);
f010145a:	83 c4 0c             	add    $0xc,%esp
f010145d:	68 00 10 00 00       	push   $0x1000
f0101462:	6a 00                	push   $0x0
f0101464:	50                   	push   %eax
f0101465:	e8 7c 43 00 00       	call   f01057e6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010146a:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010146f:	83 c4 10             	add    $0x10,%esp
f0101472:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101477:	77 15                	ja     f010148e <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101479:	50                   	push   %eax
f010147a:	68 08 65 10 f0       	push   $0xf0106508
f010147f:	68 a1 00 00 00       	push   $0xa1
f0101484:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101489:	e8 b2 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010148e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101494:	83 ca 05             	or     $0x5,%edx
f0101497:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo));
f010149d:	a1 c8 ae 20 f0       	mov    0xf020aec8,%eax
f01014a2:	c1 e0 03             	shl    $0x3,%eax
f01014a5:	e8 46 f6 ff ff       	call   f0100af0 <boot_alloc>
f01014aa:	a3 d0 ae 20 f0       	mov    %eax,0xf020aed0
        memset(pages, 0, npages * sizeof(struct PageInfo));
f01014af:	83 ec 04             	sub    $0x4,%esp
f01014b2:	8b 0d c8 ae 20 f0    	mov    0xf020aec8,%ecx
f01014b8:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01014bf:	52                   	push   %edx
f01014c0:	6a 00                	push   $0x0
f01014c2:	50                   	push   %eax
f01014c3:	e8 1e 43 00 00       	call   f01057e6 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        envs = boot_alloc(NENV * sizeof(struct Env));
f01014c8:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014cd:	e8 1e f6 ff ff       	call   f0100af0 <boot_alloc>
f01014d2:	a3 68 a2 20 f0       	mov    %eax,0xf020a268
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014d7:	e8 da f9 ff ff       	call   f0100eb6 <page_init>
 
	check_page_free_list(1);
f01014dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01014e1:	e8 d0 f6 ff ff       	call   f0100bb6 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014e6:	83 c4 10             	add    $0x10,%esp
f01014e9:	83 3d d0 ae 20 f0 00 	cmpl   $0x0,0xf020aed0
f01014f0:	75 17                	jne    f0101509 <mem_init+0x171>
		panic("'pages' is a null pointer!");
f01014f2:	83 ec 04             	sub    $0x4,%esp
f01014f5:	68 a6 6b 10 f0       	push   $0xf0106ba6
f01014fa:	68 0f 03 00 00       	push   $0x30f
f01014ff:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101504:	e8 37 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101509:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f010150e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101513:	eb 05                	jmp    f010151a <mem_init+0x182>
		++nfree;
f0101515:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101518:	8b 00                	mov    (%eax),%eax
f010151a:	85 c0                	test   %eax,%eax
f010151c:	75 f7                	jne    f0101515 <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010151e:	83 ec 0c             	sub    $0xc,%esp
f0101521:	6a 00                	push   $0x0
f0101523:	e8 89 fa ff ff       	call   f0100fb1 <page_alloc>
f0101528:	89 c7                	mov    %eax,%edi
f010152a:	83 c4 10             	add    $0x10,%esp
f010152d:	85 c0                	test   %eax,%eax
f010152f:	75 19                	jne    f010154a <mem_init+0x1b2>
f0101531:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0101536:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010153b:	68 17 03 00 00       	push   $0x317
f0101540:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101545:	e8 f6 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010154a:	83 ec 0c             	sub    $0xc,%esp
f010154d:	6a 00                	push   $0x0
f010154f:	e8 5d fa ff ff       	call   f0100fb1 <page_alloc>
f0101554:	89 c6                	mov    %eax,%esi
f0101556:	83 c4 10             	add    $0x10,%esp
f0101559:	85 c0                	test   %eax,%eax
f010155b:	75 19                	jne    f0101576 <mem_init+0x1de>
f010155d:	68 d7 6b 10 f0       	push   $0xf0106bd7
f0101562:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101567:	68 18 03 00 00       	push   $0x318
f010156c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101571:	e8 ca ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101576:	83 ec 0c             	sub    $0xc,%esp
f0101579:	6a 00                	push   $0x0
f010157b:	e8 31 fa ff ff       	call   f0100fb1 <page_alloc>
f0101580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101583:	83 c4 10             	add    $0x10,%esp
f0101586:	85 c0                	test   %eax,%eax
f0101588:	75 19                	jne    f01015a3 <mem_init+0x20b>
f010158a:	68 ed 6b 10 f0       	push   $0xf0106bed
f010158f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101594:	68 19 03 00 00       	push   $0x319
f0101599:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010159e:	e8 9d ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015a3:	39 f7                	cmp    %esi,%edi
f01015a5:	75 19                	jne    f01015c0 <mem_init+0x228>
f01015a7:	68 03 6c 10 f0       	push   $0xf0106c03
f01015ac:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01015b1:	68 1c 03 00 00       	push   $0x31c
f01015b6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01015bb:	e8 80 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c3:	39 c7                	cmp    %eax,%edi
f01015c5:	74 04                	je     f01015cb <mem_init+0x233>
f01015c7:	39 c6                	cmp    %eax,%esi
f01015c9:	75 19                	jne    f01015e4 <mem_init+0x24c>
f01015cb:	68 28 6f 10 f0       	push   $0xf0106f28
f01015d0:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01015d5:	68 1d 03 00 00       	push   $0x31d
f01015da:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015e4:	8b 0d d0 ae 20 f0    	mov    0xf020aed0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015ea:	8b 15 c8 ae 20 f0    	mov    0xf020aec8,%edx
f01015f0:	c1 e2 0c             	shl    $0xc,%edx
f01015f3:	89 f8                	mov    %edi,%eax
f01015f5:	29 c8                	sub    %ecx,%eax
f01015f7:	c1 f8 03             	sar    $0x3,%eax
f01015fa:	c1 e0 0c             	shl    $0xc,%eax
f01015fd:	39 d0                	cmp    %edx,%eax
f01015ff:	72 19                	jb     f010161a <mem_init+0x282>
f0101601:	68 15 6c 10 f0       	push   $0xf0106c15
f0101606:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010160b:	68 1e 03 00 00       	push   $0x31e
f0101610:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101615:	e8 26 ea ff ff       	call   f0100040 <_panic>
f010161a:	89 f0                	mov    %esi,%eax
f010161c:	29 c8                	sub    %ecx,%eax
f010161e:	c1 f8 03             	sar    $0x3,%eax
f0101621:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101624:	39 c2                	cmp    %eax,%edx
f0101626:	77 19                	ja     f0101641 <mem_init+0x2a9>
f0101628:	68 32 6c 10 f0       	push   $0xf0106c32
f010162d:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101632:	68 1f 03 00 00       	push   $0x31f
f0101637:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>
f0101641:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101644:	29 c8                	sub    %ecx,%eax
f0101646:	c1 f8 03             	sar    $0x3,%eax
f0101649:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010164c:	39 c2                	cmp    %eax,%edx
f010164e:	77 19                	ja     f0101669 <mem_init+0x2d1>
f0101650:	68 4f 6c 10 f0       	push   $0xf0106c4f
f0101655:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010165a:	68 20 03 00 00       	push   $0x320
f010165f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101664:	e8 d7 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101669:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f010166e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101671:	c7 05 60 a2 20 f0 00 	movl   $0x0,0xf020a260
f0101678:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010167b:	83 ec 0c             	sub    $0xc,%esp
f010167e:	6a 00                	push   $0x0
f0101680:	e8 2c f9 ff ff       	call   f0100fb1 <page_alloc>
f0101685:	83 c4 10             	add    $0x10,%esp
f0101688:	85 c0                	test   %eax,%eax
f010168a:	74 19                	je     f01016a5 <mem_init+0x30d>
f010168c:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0101691:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101696:	68 27 03 00 00       	push   $0x327
f010169b:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01016a0:	e8 9b e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016a5:	83 ec 0c             	sub    $0xc,%esp
f01016a8:	57                   	push   %edi
f01016a9:	e8 71 f9 ff ff       	call   f010101f <page_free>
	page_free(pp1);
f01016ae:	89 34 24             	mov    %esi,(%esp)
f01016b1:	e8 69 f9 ff ff       	call   f010101f <page_free>
	page_free(pp2);
f01016b6:	83 c4 04             	add    $0x4,%esp
f01016b9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016bc:	e8 5e f9 ff ff       	call   f010101f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c8:	e8 e4 f8 ff ff       	call   f0100fb1 <page_alloc>
f01016cd:	89 c6                	mov    %eax,%esi
f01016cf:	83 c4 10             	add    $0x10,%esp
f01016d2:	85 c0                	test   %eax,%eax
f01016d4:	75 19                	jne    f01016ef <mem_init+0x357>
f01016d6:	68 c1 6b 10 f0       	push   $0xf0106bc1
f01016db:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01016e0:	68 2e 03 00 00       	push   $0x32e
f01016e5:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01016ea:	e8 51 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016ef:	83 ec 0c             	sub    $0xc,%esp
f01016f2:	6a 00                	push   $0x0
f01016f4:	e8 b8 f8 ff ff       	call   f0100fb1 <page_alloc>
f01016f9:	89 c7                	mov    %eax,%edi
f01016fb:	83 c4 10             	add    $0x10,%esp
f01016fe:	85 c0                	test   %eax,%eax
f0101700:	75 19                	jne    f010171b <mem_init+0x383>
f0101702:	68 d7 6b 10 f0       	push   $0xf0106bd7
f0101707:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010170c:	68 2f 03 00 00       	push   $0x32f
f0101711:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101716:	e8 25 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010171b:	83 ec 0c             	sub    $0xc,%esp
f010171e:	6a 00                	push   $0x0
f0101720:	e8 8c f8 ff ff       	call   f0100fb1 <page_alloc>
f0101725:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101728:	83 c4 10             	add    $0x10,%esp
f010172b:	85 c0                	test   %eax,%eax
f010172d:	75 19                	jne    f0101748 <mem_init+0x3b0>
f010172f:	68 ed 6b 10 f0       	push   $0xf0106bed
f0101734:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101739:	68 30 03 00 00       	push   $0x330
f010173e:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101743:	e8 f8 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101748:	39 fe                	cmp    %edi,%esi
f010174a:	75 19                	jne    f0101765 <mem_init+0x3cd>
f010174c:	68 03 6c 10 f0       	push   $0xf0106c03
f0101751:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101756:	68 32 03 00 00       	push   $0x332
f010175b:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101760:	e8 db e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101765:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101768:	39 c6                	cmp    %eax,%esi
f010176a:	74 04                	je     f0101770 <mem_init+0x3d8>
f010176c:	39 c7                	cmp    %eax,%edi
f010176e:	75 19                	jne    f0101789 <mem_init+0x3f1>
f0101770:	68 28 6f 10 f0       	push   $0xf0106f28
f0101775:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010177a:	68 33 03 00 00       	push   $0x333
f010177f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101784:	e8 b7 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101789:	83 ec 0c             	sub    $0xc,%esp
f010178c:	6a 00                	push   $0x0
f010178e:	e8 1e f8 ff ff       	call   f0100fb1 <page_alloc>
f0101793:	83 c4 10             	add    $0x10,%esp
f0101796:	85 c0                	test   %eax,%eax
f0101798:	74 19                	je     f01017b3 <mem_init+0x41b>
f010179a:	68 6c 6c 10 f0       	push   $0xf0106c6c
f010179f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01017a4:	68 34 03 00 00       	push   $0x334
f01017a9:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01017ae:	e8 8d e8 ff ff       	call   f0100040 <_panic>
f01017b3:	89 f0                	mov    %esi,%eax
f01017b5:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017c1:	89 c2                	mov    %eax,%edx
f01017c3:	c1 ea 0c             	shr    $0xc,%edx
f01017c6:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f01017cc:	72 12                	jb     f01017e0 <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017ce:	50                   	push   %eax
f01017cf:	68 e4 64 10 f0       	push   $0xf01064e4
f01017d4:	6a 58                	push   $0x58
f01017d6:	68 aa 6a 10 f0       	push   $0xf0106aaa
f01017db:	e8 60 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017e0:	83 ec 04             	sub    $0x4,%esp
f01017e3:	68 00 10 00 00       	push   $0x1000
f01017e8:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01017ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017ef:	50                   	push   %eax
f01017f0:	e8 f1 3f 00 00       	call   f01057e6 <memset>
	page_free(pp0);
f01017f5:	89 34 24             	mov    %esi,(%esp)
f01017f8:	e8 22 f8 ff ff       	call   f010101f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101804:	e8 a8 f7 ff ff       	call   f0100fb1 <page_alloc>
f0101809:	83 c4 10             	add    $0x10,%esp
f010180c:	85 c0                	test   %eax,%eax
f010180e:	75 19                	jne    f0101829 <mem_init+0x491>
f0101810:	68 7b 6c 10 f0       	push   $0xf0106c7b
f0101815:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010181a:	68 39 03 00 00       	push   $0x339
f010181f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101824:	e8 17 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101829:	39 c6                	cmp    %eax,%esi
f010182b:	74 19                	je     f0101846 <mem_init+0x4ae>
f010182d:	68 99 6c 10 f0       	push   $0xf0106c99
f0101832:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101837:	68 3a 03 00 00       	push   $0x33a
f010183c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101841:	e8 fa e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101846:	89 f0                	mov    %esi,%eax
f0101848:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f010184e:	c1 f8 03             	sar    $0x3,%eax
f0101851:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101854:	89 c2                	mov    %eax,%edx
f0101856:	c1 ea 0c             	shr    $0xc,%edx
f0101859:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f010185f:	72 12                	jb     f0101873 <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101861:	50                   	push   %eax
f0101862:	68 e4 64 10 f0       	push   $0xf01064e4
f0101867:	6a 58                	push   $0x58
f0101869:	68 aa 6a 10 f0       	push   $0xf0106aaa
f010186e:	e8 cd e7 ff ff       	call   f0100040 <_panic>
f0101873:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101879:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010187f:	80 38 00             	cmpb   $0x0,(%eax)
f0101882:	74 19                	je     f010189d <mem_init+0x505>
f0101884:	68 a9 6c 10 f0       	push   $0xf0106ca9
f0101889:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010188e:	68 3d 03 00 00       	push   $0x33d
f0101893:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101898:	e8 a3 e7 ff ff       	call   f0100040 <_panic>
f010189d:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018a0:	39 d0                	cmp    %edx,%eax
f01018a2:	75 db                	jne    f010187f <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018a7:	a3 60 a2 20 f0       	mov    %eax,0xf020a260

	// free the pages we took
	page_free(pp0);
f01018ac:	83 ec 0c             	sub    $0xc,%esp
f01018af:	56                   	push   %esi
f01018b0:	e8 6a f7 ff ff       	call   f010101f <page_free>
	page_free(pp1);
f01018b5:	89 3c 24             	mov    %edi,(%esp)
f01018b8:	e8 62 f7 ff ff       	call   f010101f <page_free>
	page_free(pp2);
f01018bd:	83 c4 04             	add    $0x4,%esp
f01018c0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018c3:	e8 57 f7 ff ff       	call   f010101f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018c8:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f01018cd:	83 c4 10             	add    $0x10,%esp
f01018d0:	eb 05                	jmp    f01018d7 <mem_init+0x53f>
		--nfree;
f01018d2:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018d5:	8b 00                	mov    (%eax),%eax
f01018d7:	85 c0                	test   %eax,%eax
f01018d9:	75 f7                	jne    f01018d2 <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f01018db:	85 db                	test   %ebx,%ebx
f01018dd:	74 19                	je     f01018f8 <mem_init+0x560>
f01018df:	68 b3 6c 10 f0       	push   $0xf0106cb3
f01018e4:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01018e9:	68 4a 03 00 00       	push   $0x34a
f01018ee:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01018f3:	e8 48 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01018f8:	83 ec 0c             	sub    $0xc,%esp
f01018fb:	68 48 6f 10 f0       	push   $0xf0106f48
f0101900:	e8 1b 1e 00 00       	call   f0103720 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101905:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010190c:	e8 a0 f6 ff ff       	call   f0100fb1 <page_alloc>
f0101911:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101914:	83 c4 10             	add    $0x10,%esp
f0101917:	85 c0                	test   %eax,%eax
f0101919:	75 19                	jne    f0101934 <mem_init+0x59c>
f010191b:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0101920:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101925:	68 af 03 00 00       	push   $0x3af
f010192a:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010192f:	e8 0c e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101934:	83 ec 0c             	sub    $0xc,%esp
f0101937:	6a 00                	push   $0x0
f0101939:	e8 73 f6 ff ff       	call   f0100fb1 <page_alloc>
f010193e:	89 c3                	mov    %eax,%ebx
f0101940:	83 c4 10             	add    $0x10,%esp
f0101943:	85 c0                	test   %eax,%eax
f0101945:	75 19                	jne    f0101960 <mem_init+0x5c8>
f0101947:	68 d7 6b 10 f0       	push   $0xf0106bd7
f010194c:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101951:	68 b0 03 00 00       	push   $0x3b0
f0101956:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010195b:	e8 e0 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101960:	83 ec 0c             	sub    $0xc,%esp
f0101963:	6a 00                	push   $0x0
f0101965:	e8 47 f6 ff ff       	call   f0100fb1 <page_alloc>
f010196a:	89 c6                	mov    %eax,%esi
f010196c:	83 c4 10             	add    $0x10,%esp
f010196f:	85 c0                	test   %eax,%eax
f0101971:	75 19                	jne    f010198c <mem_init+0x5f4>
f0101973:	68 ed 6b 10 f0       	push   $0xf0106bed
f0101978:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010197d:	68 b1 03 00 00       	push   $0x3b1
f0101982:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101987:	e8 b4 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010198c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010198f:	75 19                	jne    f01019aa <mem_init+0x612>
f0101991:	68 03 6c 10 f0       	push   $0xf0106c03
f0101996:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010199b:	68 b4 03 00 00       	push   $0x3b4
f01019a0:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01019a5:	e8 96 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019aa:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019ad:	74 04                	je     f01019b3 <mem_init+0x61b>
f01019af:	39 c3                	cmp    %eax,%ebx
f01019b1:	75 19                	jne    f01019cc <mem_init+0x634>
f01019b3:	68 28 6f 10 f0       	push   $0xf0106f28
f01019b8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01019bd:	68 b5 03 00 00       	push   $0x3b5
f01019c2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01019c7:	e8 74 e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019cc:	a1 60 a2 20 f0       	mov    0xf020a260,%eax
f01019d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019d4:	c7 05 60 a2 20 f0 00 	movl   $0x0,0xf020a260
f01019db:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019de:	83 ec 0c             	sub    $0xc,%esp
f01019e1:	6a 00                	push   $0x0
f01019e3:	e8 c9 f5 ff ff       	call   f0100fb1 <page_alloc>
f01019e8:	83 c4 10             	add    $0x10,%esp
f01019eb:	85 c0                	test   %eax,%eax
f01019ed:	74 19                	je     f0101a08 <mem_init+0x670>
f01019ef:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01019f4:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01019f9:	68 bc 03 00 00       	push   $0x3bc
f01019fe:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101a03:	e8 38 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a08:	83 ec 04             	sub    $0x4,%esp
f0101a0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a0e:	50                   	push   %eax
f0101a0f:	6a 00                	push   $0x0
f0101a11:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101a17:	e8 bf f7 ff ff       	call   f01011db <page_lookup>
f0101a1c:	83 c4 10             	add    $0x10,%esp
f0101a1f:	85 c0                	test   %eax,%eax
f0101a21:	74 19                	je     f0101a3c <mem_init+0x6a4>
f0101a23:	68 68 6f 10 f0       	push   $0xf0106f68
f0101a28:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101a2d:	68 bf 03 00 00       	push   $0x3bf
f0101a32:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101a37:	e8 04 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a3c:	6a 02                	push   $0x2
f0101a3e:	6a 00                	push   $0x0
f0101a40:	53                   	push   %ebx
f0101a41:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101a47:	e8 7b f8 ff ff       	call   f01012c7 <page_insert>
f0101a4c:	83 c4 10             	add    $0x10,%esp
f0101a4f:	85 c0                	test   %eax,%eax
f0101a51:	78 19                	js     f0101a6c <mem_init+0x6d4>
f0101a53:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101a58:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101a5d:	68 c2 03 00 00       	push   $0x3c2
f0101a62:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101a67:	e8 d4 e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a6c:	83 ec 0c             	sub    $0xc,%esp
f0101a6f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a72:	e8 a8 f5 ff ff       	call   f010101f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a77:	6a 02                	push   $0x2
f0101a79:	6a 00                	push   $0x0
f0101a7b:	53                   	push   %ebx
f0101a7c:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101a82:	e8 40 f8 ff ff       	call   f01012c7 <page_insert>
f0101a87:	83 c4 20             	add    $0x20,%esp
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0x70f>
f0101a8e:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101a93:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101a98:	68 c6 03 00 00       	push   $0x3c6
f0101a9d:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101aa7:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aad:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
f0101ab2:	89 c1                	mov    %eax,%ecx
f0101ab4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ab7:	8b 17                	mov    (%edi),%edx
f0101ab9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101abf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac2:	29 c8                	sub    %ecx,%eax
f0101ac4:	c1 f8 03             	sar    $0x3,%eax
f0101ac7:	c1 e0 0c             	shl    $0xc,%eax
f0101aca:	39 c2                	cmp    %eax,%edx
f0101acc:	74 19                	je     f0101ae7 <mem_init+0x74f>
f0101ace:	68 00 70 10 f0       	push   $0xf0107000
f0101ad3:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101ad8:	68 c7 03 00 00       	push   $0x3c7
f0101add:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101ae2:	e8 59 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ae7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aec:	89 f8                	mov    %edi,%eax
f0101aee:	e8 5f f0 ff ff       	call   f0100b52 <check_va2pa>
f0101af3:	89 da                	mov    %ebx,%edx
f0101af5:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101af8:	c1 fa 03             	sar    $0x3,%edx
f0101afb:	c1 e2 0c             	shl    $0xc,%edx
f0101afe:	39 d0                	cmp    %edx,%eax
f0101b00:	74 19                	je     f0101b1b <mem_init+0x783>
f0101b02:	68 28 70 10 f0       	push   $0xf0107028
f0101b07:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101b0c:	68 c8 03 00 00       	push   $0x3c8
f0101b11:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101b16:	e8 25 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101b1b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b20:	74 19                	je     f0101b3b <mem_init+0x7a3>
f0101b22:	68 be 6c 10 f0       	push   $0xf0106cbe
f0101b27:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101b2c:	68 c9 03 00 00       	push   $0x3c9
f0101b31:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101b36:	e8 05 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101b3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b3e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b43:	74 19                	je     f0101b5e <mem_init+0x7c6>
f0101b45:	68 cf 6c 10 f0       	push   $0xf0106ccf
f0101b4a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101b4f:	68 ca 03 00 00       	push   $0x3ca
f0101b54:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101b59:	e8 e2 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b5e:	6a 02                	push   $0x2
f0101b60:	68 00 10 00 00       	push   $0x1000
f0101b65:	56                   	push   %esi
f0101b66:	57                   	push   %edi
f0101b67:	e8 5b f7 ff ff       	call   f01012c7 <page_insert>
f0101b6c:	83 c4 10             	add    $0x10,%esp
f0101b6f:	85 c0                	test   %eax,%eax
f0101b71:	74 19                	je     f0101b8c <mem_init+0x7f4>
f0101b73:	68 58 70 10 f0       	push   $0xf0107058
f0101b78:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101b7d:	68 cd 03 00 00       	push   $0x3cd
f0101b82:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101b87:	e8 b4 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b8c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b91:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0101b96:	e8 b7 ef ff ff       	call   f0100b52 <check_va2pa>
f0101b9b:	89 f2                	mov    %esi,%edx
f0101b9d:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f0101ba3:	c1 fa 03             	sar    $0x3,%edx
f0101ba6:	c1 e2 0c             	shl    $0xc,%edx
f0101ba9:	39 d0                	cmp    %edx,%eax
f0101bab:	74 19                	je     f0101bc6 <mem_init+0x82e>
f0101bad:	68 94 70 10 f0       	push   $0xf0107094
f0101bb2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101bb7:	68 ce 03 00 00       	push   $0x3ce
f0101bbc:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101bc1:	e8 7a e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bc6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bcb:	74 19                	je     f0101be6 <mem_init+0x84e>
f0101bcd:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0101bd2:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101bd7:	68 cf 03 00 00       	push   $0x3cf
f0101bdc:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101be1:	e8 5a e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101be6:	83 ec 0c             	sub    $0xc,%esp
f0101be9:	6a 00                	push   $0x0
f0101beb:	e8 c1 f3 ff ff       	call   f0100fb1 <page_alloc>
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	85 c0                	test   %eax,%eax
f0101bf5:	74 19                	je     f0101c10 <mem_init+0x878>
f0101bf7:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0101bfc:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101c01:	68 d2 03 00 00       	push   $0x3d2
f0101c06:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101c0b:	e8 30 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c10:	6a 02                	push   $0x2
f0101c12:	68 00 10 00 00       	push   $0x1000
f0101c17:	56                   	push   %esi
f0101c18:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101c1e:	e8 a4 f6 ff ff       	call   f01012c7 <page_insert>
f0101c23:	83 c4 10             	add    $0x10,%esp
f0101c26:	85 c0                	test   %eax,%eax
f0101c28:	74 19                	je     f0101c43 <mem_init+0x8ab>
f0101c2a:	68 58 70 10 f0       	push   $0xf0107058
f0101c2f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101c34:	68 d5 03 00 00       	push   $0x3d5
f0101c39:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101c3e:	e8 fd e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c43:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c48:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0101c4d:	e8 00 ef ff ff       	call   f0100b52 <check_va2pa>
f0101c52:	89 f2                	mov    %esi,%edx
f0101c54:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f0101c5a:	c1 fa 03             	sar    $0x3,%edx
f0101c5d:	c1 e2 0c             	shl    $0xc,%edx
f0101c60:	39 d0                	cmp    %edx,%eax
f0101c62:	74 19                	je     f0101c7d <mem_init+0x8e5>
f0101c64:	68 94 70 10 f0       	push   $0xf0107094
f0101c69:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101c6e:	68 d6 03 00 00       	push   $0x3d6
f0101c73:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101c78:	e8 c3 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c7d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c82:	74 19                	je     f0101c9d <mem_init+0x905>
f0101c84:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0101c89:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101c8e:	68 d7 03 00 00       	push   $0x3d7
f0101c93:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101c98:	e8 a3 e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c9d:	83 ec 0c             	sub    $0xc,%esp
f0101ca0:	6a 00                	push   $0x0
f0101ca2:	e8 0a f3 ff ff       	call   f0100fb1 <page_alloc>
f0101ca7:	83 c4 10             	add    $0x10,%esp
f0101caa:	85 c0                	test   %eax,%eax
f0101cac:	74 19                	je     f0101cc7 <mem_init+0x92f>
f0101cae:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0101cb3:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101cb8:	68 db 03 00 00       	push   $0x3db
f0101cbd:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101cc2:	e8 79 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cc7:	8b 15 cc ae 20 f0    	mov    0xf020aecc,%edx
f0101ccd:	8b 02                	mov    (%edx),%eax
f0101ccf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cd4:	89 c1                	mov    %eax,%ecx
f0101cd6:	c1 e9 0c             	shr    $0xc,%ecx
f0101cd9:	3b 0d c8 ae 20 f0    	cmp    0xf020aec8,%ecx
f0101cdf:	72 15                	jb     f0101cf6 <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ce1:	50                   	push   %eax
f0101ce2:	68 e4 64 10 f0       	push   $0xf01064e4
f0101ce7:	68 de 03 00 00       	push   $0x3de
f0101cec:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101cf1:	e8 4a e3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101cf6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cfe:	83 ec 04             	sub    $0x4,%esp
f0101d01:	6a 00                	push   $0x0
f0101d03:	68 00 10 00 00       	push   $0x1000
f0101d08:	52                   	push   %edx
f0101d09:	e8 77 f3 ff ff       	call   f0101085 <pgdir_walk>
f0101d0e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d11:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d14:	83 c4 10             	add    $0x10,%esp
f0101d17:	39 d0                	cmp    %edx,%eax
f0101d19:	74 19                	je     f0101d34 <mem_init+0x99c>
f0101d1b:	68 c4 70 10 f0       	push   $0xf01070c4
f0101d20:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101d25:	68 df 03 00 00       	push   $0x3df
f0101d2a:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101d2f:	e8 0c e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d34:	6a 06                	push   $0x6
f0101d36:	68 00 10 00 00       	push   $0x1000
f0101d3b:	56                   	push   %esi
f0101d3c:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101d42:	e8 80 f5 ff ff       	call   f01012c7 <page_insert>
f0101d47:	83 c4 10             	add    $0x10,%esp
f0101d4a:	85 c0                	test   %eax,%eax
f0101d4c:	74 19                	je     f0101d67 <mem_init+0x9cf>
f0101d4e:	68 04 71 10 f0       	push   $0xf0107104
f0101d53:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101d58:	68 e2 03 00 00       	push   $0x3e2
f0101d5d:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101d62:	e8 d9 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d67:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
f0101d6d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d72:	89 f8                	mov    %edi,%eax
f0101d74:	e8 d9 ed ff ff       	call   f0100b52 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d79:	89 f2                	mov    %esi,%edx
f0101d7b:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f0101d81:	c1 fa 03             	sar    $0x3,%edx
f0101d84:	c1 e2 0c             	shl    $0xc,%edx
f0101d87:	39 d0                	cmp    %edx,%eax
f0101d89:	74 19                	je     f0101da4 <mem_init+0xa0c>
f0101d8b:	68 94 70 10 f0       	push   $0xf0107094
f0101d90:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101d95:	68 e3 03 00 00       	push   $0x3e3
f0101d9a:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101d9f:	e8 9c e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101da4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101da9:	74 19                	je     f0101dc4 <mem_init+0xa2c>
f0101dab:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0101db0:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101db5:	68 e4 03 00 00       	push   $0x3e4
f0101dba:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101dbf:	e8 7c e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dc4:	83 ec 04             	sub    $0x4,%esp
f0101dc7:	6a 00                	push   $0x0
f0101dc9:	68 00 10 00 00       	push   $0x1000
f0101dce:	57                   	push   %edi
f0101dcf:	e8 b1 f2 ff ff       	call   f0101085 <pgdir_walk>
f0101dd4:	83 c4 10             	add    $0x10,%esp
f0101dd7:	f6 00 04             	testb  $0x4,(%eax)
f0101dda:	75 19                	jne    f0101df5 <mem_init+0xa5d>
f0101ddc:	68 44 71 10 f0       	push   $0xf0107144
f0101de1:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101de6:	68 e5 03 00 00       	push   $0x3e5
f0101deb:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101df0:	e8 4b e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101df5:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0101dfa:	f6 00 04             	testb  $0x4,(%eax)
f0101dfd:	75 19                	jne    f0101e18 <mem_init+0xa80>
f0101dff:	68 f1 6c 10 f0       	push   $0xf0106cf1
f0101e04:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101e09:	68 e6 03 00 00       	push   $0x3e6
f0101e0e:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101e13:	e8 28 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e18:	6a 02                	push   $0x2
f0101e1a:	68 00 10 00 00       	push   $0x1000
f0101e1f:	56                   	push   %esi
f0101e20:	50                   	push   %eax
f0101e21:	e8 a1 f4 ff ff       	call   f01012c7 <page_insert>
f0101e26:	83 c4 10             	add    $0x10,%esp
f0101e29:	85 c0                	test   %eax,%eax
f0101e2b:	74 19                	je     f0101e46 <mem_init+0xaae>
f0101e2d:	68 58 70 10 f0       	push   $0xf0107058
f0101e32:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101e37:	68 e9 03 00 00       	push   $0x3e9
f0101e3c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101e41:	e8 fa e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e46:	83 ec 04             	sub    $0x4,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	68 00 10 00 00       	push   $0x1000
f0101e50:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101e56:	e8 2a f2 ff ff       	call   f0101085 <pgdir_walk>
f0101e5b:	83 c4 10             	add    $0x10,%esp
f0101e5e:	f6 00 02             	testb  $0x2,(%eax)
f0101e61:	75 19                	jne    f0101e7c <mem_init+0xae4>
f0101e63:	68 78 71 10 f0       	push   $0xf0107178
f0101e68:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101e6d:	68 ea 03 00 00       	push   $0x3ea
f0101e72:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101e77:	e8 c4 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e7c:	83 ec 04             	sub    $0x4,%esp
f0101e7f:	6a 00                	push   $0x0
f0101e81:	68 00 10 00 00       	push   $0x1000
f0101e86:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101e8c:	e8 f4 f1 ff ff       	call   f0101085 <pgdir_walk>
f0101e91:	83 c4 10             	add    $0x10,%esp
f0101e94:	f6 00 04             	testb  $0x4,(%eax)
f0101e97:	74 19                	je     f0101eb2 <mem_init+0xb1a>
f0101e99:	68 ac 71 10 f0       	push   $0xf01071ac
f0101e9e:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101ea3:	68 eb 03 00 00       	push   $0x3eb
f0101ea8:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101ead:	e8 8e e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101eb2:	6a 02                	push   $0x2
f0101eb4:	68 00 00 40 00       	push   $0x400000
f0101eb9:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ebc:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101ec2:	e8 00 f4 ff ff       	call   f01012c7 <page_insert>
f0101ec7:	83 c4 10             	add    $0x10,%esp
f0101eca:	85 c0                	test   %eax,%eax
f0101ecc:	78 19                	js     f0101ee7 <mem_init+0xb4f>
f0101ece:	68 e4 71 10 f0       	push   $0xf01071e4
f0101ed3:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101ed8:	68 ee 03 00 00       	push   $0x3ee
f0101edd:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101ee2:	e8 59 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ee7:	6a 02                	push   $0x2
f0101ee9:	68 00 10 00 00       	push   $0x1000
f0101eee:	53                   	push   %ebx
f0101eef:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101ef5:	e8 cd f3 ff ff       	call   f01012c7 <page_insert>
f0101efa:	83 c4 10             	add    $0x10,%esp
f0101efd:	85 c0                	test   %eax,%eax
f0101eff:	74 19                	je     f0101f1a <mem_init+0xb82>
f0101f01:	68 1c 72 10 f0       	push   $0xf010721c
f0101f06:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101f0b:	68 f1 03 00 00       	push   $0x3f1
f0101f10:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101f15:	e8 26 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f1a:	83 ec 04             	sub    $0x4,%esp
f0101f1d:	6a 00                	push   $0x0
f0101f1f:	68 00 10 00 00       	push   $0x1000
f0101f24:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0101f2a:	e8 56 f1 ff ff       	call   f0101085 <pgdir_walk>
f0101f2f:	83 c4 10             	add    $0x10,%esp
f0101f32:	f6 00 04             	testb  $0x4,(%eax)
f0101f35:	74 19                	je     f0101f50 <mem_init+0xbb8>
f0101f37:	68 ac 71 10 f0       	push   $0xf01071ac
f0101f3c:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101f41:	68 f2 03 00 00       	push   $0x3f2
f0101f46:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101f4b:	e8 f0 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f50:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
f0101f56:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f5b:	89 f8                	mov    %edi,%eax
f0101f5d:	e8 f0 eb ff ff       	call   f0100b52 <check_va2pa>
f0101f62:	89 c1                	mov    %eax,%ecx
f0101f64:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f67:	89 d8                	mov    %ebx,%eax
f0101f69:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0101f6f:	c1 f8 03             	sar    $0x3,%eax
f0101f72:	c1 e0 0c             	shl    $0xc,%eax
f0101f75:	39 c1                	cmp    %eax,%ecx
f0101f77:	74 19                	je     f0101f92 <mem_init+0xbfa>
f0101f79:	68 58 72 10 f0       	push   $0xf0107258
f0101f7e:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101f83:	68 f5 03 00 00       	push   $0x3f5
f0101f88:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101f8d:	e8 ae e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f92:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f97:	89 f8                	mov    %edi,%eax
f0101f99:	e8 b4 eb ff ff       	call   f0100b52 <check_va2pa>
f0101f9e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fa1:	74 19                	je     f0101fbc <mem_init+0xc24>
f0101fa3:	68 84 72 10 f0       	push   $0xf0107284
f0101fa8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101fad:	68 f6 03 00 00       	push   $0x3f6
f0101fb2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101fb7:	e8 84 e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fbc:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fc1:	74 19                	je     f0101fdc <mem_init+0xc44>
f0101fc3:	68 07 6d 10 f0       	push   $0xf0106d07
f0101fc8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101fcd:	68 f8 03 00 00       	push   $0x3f8
f0101fd2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101fd7:	e8 64 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fdc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fe1:	74 19                	je     f0101ffc <mem_init+0xc64>
f0101fe3:	68 18 6d 10 f0       	push   $0xf0106d18
f0101fe8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101fed:	68 f9 03 00 00       	push   $0x3f9
f0101ff2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101ff7:	e8 44 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ffc:	83 ec 0c             	sub    $0xc,%esp
f0101fff:	6a 00                	push   $0x0
f0102001:	e8 ab ef ff ff       	call   f0100fb1 <page_alloc>
f0102006:	83 c4 10             	add    $0x10,%esp
f0102009:	85 c0                	test   %eax,%eax
f010200b:	74 04                	je     f0102011 <mem_init+0xc79>
f010200d:	39 c6                	cmp    %eax,%esi
f010200f:	74 19                	je     f010202a <mem_init+0xc92>
f0102011:	68 b4 72 10 f0       	push   $0xf01072b4
f0102016:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010201b:	68 fc 03 00 00       	push   $0x3fc
f0102020:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102025:	e8 16 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010202a:	83 ec 08             	sub    $0x8,%esp
f010202d:	6a 00                	push   $0x0
f010202f:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102035:	e8 3c f2 ff ff       	call   f0101276 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010203a:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
f0102040:	ba 00 00 00 00       	mov    $0x0,%edx
f0102045:	89 f8                	mov    %edi,%eax
f0102047:	e8 06 eb ff ff       	call   f0100b52 <check_va2pa>
f010204c:	83 c4 10             	add    $0x10,%esp
f010204f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102052:	74 19                	je     f010206d <mem_init+0xcd5>
f0102054:	68 d8 72 10 f0       	push   $0xf01072d8
f0102059:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010205e:	68 00 04 00 00       	push   $0x400
f0102063:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102068:	e8 d3 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010206d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102072:	89 f8                	mov    %edi,%eax
f0102074:	e8 d9 ea ff ff       	call   f0100b52 <check_va2pa>
f0102079:	89 da                	mov    %ebx,%edx
f010207b:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f0102081:	c1 fa 03             	sar    $0x3,%edx
f0102084:	c1 e2 0c             	shl    $0xc,%edx
f0102087:	39 d0                	cmp    %edx,%eax
f0102089:	74 19                	je     f01020a4 <mem_init+0xd0c>
f010208b:	68 84 72 10 f0       	push   $0xf0107284
f0102090:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102095:	68 01 04 00 00       	push   $0x401
f010209a:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010209f:	e8 9c df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01020a4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020a9:	74 19                	je     f01020c4 <mem_init+0xd2c>
f01020ab:	68 be 6c 10 f0       	push   $0xf0106cbe
f01020b0:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01020b5:	68 02 04 00 00       	push   $0x402
f01020ba:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01020bf:	e8 7c df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020c4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020c9:	74 19                	je     f01020e4 <mem_init+0xd4c>
f01020cb:	68 18 6d 10 f0       	push   $0xf0106d18
f01020d0:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01020d5:	68 03 04 00 00       	push   $0x403
f01020da:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01020df:	e8 5c df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020e4:	6a 00                	push   $0x0
f01020e6:	68 00 10 00 00       	push   $0x1000
f01020eb:	53                   	push   %ebx
f01020ec:	57                   	push   %edi
f01020ed:	e8 d5 f1 ff ff       	call   f01012c7 <page_insert>
f01020f2:	83 c4 10             	add    $0x10,%esp
f01020f5:	85 c0                	test   %eax,%eax
f01020f7:	74 19                	je     f0102112 <mem_init+0xd7a>
f01020f9:	68 fc 72 10 f0       	push   $0xf01072fc
f01020fe:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102103:	68 06 04 00 00       	push   $0x406
f0102108:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010210d:	e8 2e df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102112:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102117:	75 19                	jne    f0102132 <mem_init+0xd9a>
f0102119:	68 29 6d 10 f0       	push   $0xf0106d29
f010211e:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102123:	68 07 04 00 00       	push   $0x407
f0102128:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010212d:	e8 0e df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102132:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102135:	74 19                	je     f0102150 <mem_init+0xdb8>
f0102137:	68 35 6d 10 f0       	push   $0xf0106d35
f010213c:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102141:	68 08 04 00 00       	push   $0x408
f0102146:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010214b:	e8 f0 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102150:	83 ec 08             	sub    $0x8,%esp
f0102153:	68 00 10 00 00       	push   $0x1000
f0102158:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f010215e:	e8 13 f1 ff ff       	call   f0101276 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102163:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
f0102169:	ba 00 00 00 00       	mov    $0x0,%edx
f010216e:	89 f8                	mov    %edi,%eax
f0102170:	e8 dd e9 ff ff       	call   f0100b52 <check_va2pa>
f0102175:	83 c4 10             	add    $0x10,%esp
f0102178:	83 f8 ff             	cmp    $0xffffffff,%eax
f010217b:	74 19                	je     f0102196 <mem_init+0xdfe>
f010217d:	68 d8 72 10 f0       	push   $0xf01072d8
f0102182:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102187:	68 0c 04 00 00       	push   $0x40c
f010218c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102191:	e8 aa de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102196:	ba 00 10 00 00       	mov    $0x1000,%edx
f010219b:	89 f8                	mov    %edi,%eax
f010219d:	e8 b0 e9 ff ff       	call   f0100b52 <check_va2pa>
f01021a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a5:	74 19                	je     f01021c0 <mem_init+0xe28>
f01021a7:	68 34 73 10 f0       	push   $0xf0107334
f01021ac:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01021b1:	68 0d 04 00 00       	push   $0x40d
f01021b6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01021bb:	e8 80 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01021c0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021c5:	74 19                	je     f01021e0 <mem_init+0xe48>
f01021c7:	68 4a 6d 10 f0       	push   $0xf0106d4a
f01021cc:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01021d1:	68 0e 04 00 00       	push   $0x40e
f01021d6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01021db:	e8 60 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021e0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021e5:	74 19                	je     f0102200 <mem_init+0xe68>
f01021e7:	68 18 6d 10 f0       	push   $0xf0106d18
f01021ec:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01021f1:	68 0f 04 00 00       	push   $0x40f
f01021f6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01021fb:	e8 40 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102200:	83 ec 0c             	sub    $0xc,%esp
f0102203:	6a 00                	push   $0x0
f0102205:	e8 a7 ed ff ff       	call   f0100fb1 <page_alloc>
f010220a:	83 c4 10             	add    $0x10,%esp
f010220d:	85 c0                	test   %eax,%eax
f010220f:	74 04                	je     f0102215 <mem_init+0xe7d>
f0102211:	39 c3                	cmp    %eax,%ebx
f0102213:	74 19                	je     f010222e <mem_init+0xe96>
f0102215:	68 5c 73 10 f0       	push   $0xf010735c
f010221a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010221f:	68 12 04 00 00       	push   $0x412
f0102224:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102229:	e8 12 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010222e:	83 ec 0c             	sub    $0xc,%esp
f0102231:	6a 00                	push   $0x0
f0102233:	e8 79 ed ff ff       	call   f0100fb1 <page_alloc>
f0102238:	83 c4 10             	add    $0x10,%esp
f010223b:	85 c0                	test   %eax,%eax
f010223d:	74 19                	je     f0102258 <mem_init+0xec0>
f010223f:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0102244:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102249:	68 15 04 00 00       	push   $0x415
f010224e:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102253:	e8 e8 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102258:	8b 0d cc ae 20 f0    	mov    0xf020aecc,%ecx
f010225e:	8b 11                	mov    (%ecx),%edx
f0102260:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102266:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102269:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f010226f:	c1 f8 03             	sar    $0x3,%eax
f0102272:	c1 e0 0c             	shl    $0xc,%eax
f0102275:	39 c2                	cmp    %eax,%edx
f0102277:	74 19                	je     f0102292 <mem_init+0xefa>
f0102279:	68 00 70 10 f0       	push   $0xf0107000
f010227e:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102283:	68 18 04 00 00       	push   $0x418
f0102288:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010228d:	e8 ae dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102292:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102298:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01022a0:	74 19                	je     f01022bb <mem_init+0xf23>
f01022a2:	68 cf 6c 10 f0       	push   $0xf0106ccf
f01022a7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01022ac:	68 1a 04 00 00       	push   $0x41a
f01022b1:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01022b6:	e8 85 dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01022bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022be:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022c4:	83 ec 0c             	sub    $0xc,%esp
f01022c7:	50                   	push   %eax
f01022c8:	e8 52 ed ff ff       	call   f010101f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022cd:	83 c4 0c             	add    $0xc,%esp
f01022d0:	6a 01                	push   $0x1
f01022d2:	68 00 10 40 00       	push   $0x401000
f01022d7:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f01022dd:	e8 a3 ed ff ff       	call   f0101085 <pgdir_walk>
f01022e2:	89 c7                	mov    %eax,%edi
f01022e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022e7:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f01022ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022ef:	8b 40 04             	mov    0x4(%eax),%eax
f01022f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022f7:	8b 0d c8 ae 20 f0    	mov    0xf020aec8,%ecx
f01022fd:	89 c2                	mov    %eax,%edx
f01022ff:	c1 ea 0c             	shr    $0xc,%edx
f0102302:	83 c4 10             	add    $0x10,%esp
f0102305:	39 ca                	cmp    %ecx,%edx
f0102307:	72 15                	jb     f010231e <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102309:	50                   	push   %eax
f010230a:	68 e4 64 10 f0       	push   $0xf01064e4
f010230f:	68 21 04 00 00       	push   $0x421
f0102314:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010231e:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102323:	39 c7                	cmp    %eax,%edi
f0102325:	74 19                	je     f0102340 <mem_init+0xfa8>
f0102327:	68 5b 6d 10 f0       	push   $0xf0106d5b
f010232c:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102331:	68 22 04 00 00       	push   $0x422
f0102336:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010233b:	e8 00 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102340:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102343:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010234a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010234d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102353:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0102359:	c1 f8 03             	sar    $0x3,%eax
f010235c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010235f:	89 c2                	mov    %eax,%edx
f0102361:	c1 ea 0c             	shr    $0xc,%edx
f0102364:	39 d1                	cmp    %edx,%ecx
f0102366:	77 12                	ja     f010237a <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102368:	50                   	push   %eax
f0102369:	68 e4 64 10 f0       	push   $0xf01064e4
f010236e:	6a 58                	push   $0x58
f0102370:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0102375:	e8 c6 dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010237a:	83 ec 04             	sub    $0x4,%esp
f010237d:	68 00 10 00 00       	push   $0x1000
f0102382:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102387:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010238c:	50                   	push   %eax
f010238d:	e8 54 34 00 00       	call   f01057e6 <memset>
	page_free(pp0);
f0102392:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102395:	89 3c 24             	mov    %edi,(%esp)
f0102398:	e8 82 ec ff ff       	call   f010101f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010239d:	83 c4 0c             	add    $0xc,%esp
f01023a0:	6a 01                	push   $0x1
f01023a2:	6a 00                	push   $0x0
f01023a4:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f01023aa:	e8 d6 ec ff ff       	call   f0101085 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023af:	89 fa                	mov    %edi,%edx
f01023b1:	2b 15 d0 ae 20 f0    	sub    0xf020aed0,%edx
f01023b7:	c1 fa 03             	sar    $0x3,%edx
f01023ba:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023bd:	89 d0                	mov    %edx,%eax
f01023bf:	c1 e8 0c             	shr    $0xc,%eax
f01023c2:	83 c4 10             	add    $0x10,%esp
f01023c5:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f01023cb:	72 12                	jb     f01023df <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023cd:	52                   	push   %edx
f01023ce:	68 e4 64 10 f0       	push   $0xf01064e4
f01023d3:	6a 58                	push   $0x58
f01023d5:	68 aa 6a 10 f0       	push   $0xf0106aaa
f01023da:	e8 61 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01023df:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023e8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023ee:	f6 00 01             	testb  $0x1,(%eax)
f01023f1:	74 19                	je     f010240c <mem_init+0x1074>
f01023f3:	68 73 6d 10 f0       	push   $0xf0106d73
f01023f8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01023fd:	68 2c 04 00 00       	push   $0x42c
f0102402:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102407:	e8 34 dc ff ff       	call   f0100040 <_panic>
f010240c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010240f:	39 d0                	cmp    %edx,%eax
f0102411:	75 db                	jne    f01023ee <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102413:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0102418:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010241e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102421:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102427:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010242a:	89 0d 60 a2 20 f0    	mov    %ecx,0xf020a260

	// free the pages we took
	page_free(pp0);
f0102430:	83 ec 0c             	sub    $0xc,%esp
f0102433:	50                   	push   %eax
f0102434:	e8 e6 eb ff ff       	call   f010101f <page_free>
	page_free(pp1);
f0102439:	89 1c 24             	mov    %ebx,(%esp)
f010243c:	e8 de eb ff ff       	call   f010101f <page_free>
	page_free(pp2);
f0102441:	89 34 24             	mov    %esi,(%esp)
f0102444:	e8 d6 eb ff ff       	call   f010101f <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102449:	83 c4 08             	add    $0x8,%esp
f010244c:	68 01 10 00 00       	push   $0x1001
f0102451:	6a 00                	push   $0x0
f0102453:	e8 dd ee ff ff       	call   f0101335 <mmio_map_region>
f0102458:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010245a:	83 c4 08             	add    $0x8,%esp
f010245d:	68 00 10 00 00       	push   $0x1000
f0102462:	6a 00                	push   $0x0
f0102464:	e8 cc ee ff ff       	call   f0101335 <mmio_map_region>
f0102469:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010246b:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102471:	83 c4 10             	add    $0x10,%esp
f0102474:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102479:	77 08                	ja     f0102483 <mem_init+0x10eb>
f010247b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102481:	77 19                	ja     f010249c <mem_init+0x1104>
f0102483:	68 80 73 10 f0       	push   $0xf0107380
f0102488:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010248d:	68 3c 04 00 00       	push   $0x43c
f0102492:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102497:	e8 a4 db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010249c:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024a2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024a8:	77 08                	ja     f01024b2 <mem_init+0x111a>
f01024aa:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024b0:	77 19                	ja     f01024cb <mem_init+0x1133>
f01024b2:	68 a8 73 10 f0       	push   $0xf01073a8
f01024b7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01024bc:	68 3d 04 00 00       	push   $0x43d
f01024c1:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01024c6:	e8 75 db ff ff       	call   f0100040 <_panic>
f01024cb:	89 da                	mov    %ebx,%edx
f01024cd:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024cf:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024d5:	74 19                	je     f01024f0 <mem_init+0x1158>
f01024d7:	68 d0 73 10 f0       	push   $0xf01073d0
f01024dc:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01024e1:	68 3f 04 00 00       	push   $0x43f
f01024e6:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01024eb:	e8 50 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01024f0:	39 c6                	cmp    %eax,%esi
f01024f2:	73 19                	jae    f010250d <mem_init+0x1175>
f01024f4:	68 8a 6d 10 f0       	push   $0xf0106d8a
f01024f9:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01024fe:	68 41 04 00 00       	push   $0x441
f0102503:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102508:	e8 33 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010250d:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi
f0102513:	89 da                	mov    %ebx,%edx
f0102515:	89 f8                	mov    %edi,%eax
f0102517:	e8 36 e6 ff ff       	call   f0100b52 <check_va2pa>
f010251c:	85 c0                	test   %eax,%eax
f010251e:	74 19                	je     f0102539 <mem_init+0x11a1>
f0102520:	68 f8 73 10 f0       	push   $0xf01073f8
f0102525:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010252a:	68 43 04 00 00       	push   $0x443
f010252f:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102534:	e8 07 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102539:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010253f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102542:	89 c2                	mov    %eax,%edx
f0102544:	89 f8                	mov    %edi,%eax
f0102546:	e8 07 e6 ff ff       	call   f0100b52 <check_va2pa>
f010254b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102550:	74 19                	je     f010256b <mem_init+0x11d3>
f0102552:	68 1c 74 10 f0       	push   $0xf010741c
f0102557:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010255c:	68 44 04 00 00       	push   $0x444
f0102561:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102566:	e8 d5 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010256b:	89 f2                	mov    %esi,%edx
f010256d:	89 f8                	mov    %edi,%eax
f010256f:	e8 de e5 ff ff       	call   f0100b52 <check_va2pa>
f0102574:	85 c0                	test   %eax,%eax
f0102576:	74 19                	je     f0102591 <mem_init+0x11f9>
f0102578:	68 4c 74 10 f0       	push   $0xf010744c
f010257d:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102582:	68 45 04 00 00       	push   $0x445
f0102587:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010258c:	e8 af da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102591:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102597:	89 f8                	mov    %edi,%eax
f0102599:	e8 b4 e5 ff ff       	call   f0100b52 <check_va2pa>
f010259e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025a1:	74 19                	je     f01025bc <mem_init+0x1224>
f01025a3:	68 70 74 10 f0       	push   $0xf0107470
f01025a8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01025ad:	68 46 04 00 00       	push   $0x446
f01025b2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01025b7:	e8 84 da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025bc:	83 ec 04             	sub    $0x4,%esp
f01025bf:	6a 00                	push   $0x0
f01025c1:	53                   	push   %ebx
f01025c2:	57                   	push   %edi
f01025c3:	e8 bd ea ff ff       	call   f0101085 <pgdir_walk>
f01025c8:	83 c4 10             	add    $0x10,%esp
f01025cb:	f6 00 1a             	testb  $0x1a,(%eax)
f01025ce:	75 19                	jne    f01025e9 <mem_init+0x1251>
f01025d0:	68 9c 74 10 f0       	push   $0xf010749c
f01025d5:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01025da:	68 48 04 00 00       	push   $0x448
f01025df:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01025e4:	e8 57 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01025e9:	83 ec 04             	sub    $0x4,%esp
f01025ec:	6a 00                	push   $0x0
f01025ee:	53                   	push   %ebx
f01025ef:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f01025f5:	e8 8b ea ff ff       	call   f0101085 <pgdir_walk>
f01025fa:	83 c4 10             	add    $0x10,%esp
f01025fd:	f6 00 04             	testb  $0x4,(%eax)
f0102600:	74 19                	je     f010261b <mem_init+0x1283>
f0102602:	68 e0 74 10 f0       	push   $0xf01074e0
f0102607:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010260c:	68 49 04 00 00       	push   $0x449
f0102611:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102616:	e8 25 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010261b:	83 ec 04             	sub    $0x4,%esp
f010261e:	6a 00                	push   $0x0
f0102620:	53                   	push   %ebx
f0102621:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102627:	e8 59 ea ff ff       	call   f0101085 <pgdir_walk>
f010262c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102632:	83 c4 0c             	add    $0xc,%esp
f0102635:	6a 00                	push   $0x0
f0102637:	ff 75 d4             	pushl  -0x2c(%ebp)
f010263a:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102640:	e8 40 ea ff ff       	call   f0101085 <pgdir_walk>
f0102645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010264b:	83 c4 0c             	add    $0xc,%esp
f010264e:	6a 00                	push   $0x0
f0102650:	56                   	push   %esi
f0102651:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102657:	e8 29 ea ff ff       	call   f0101085 <pgdir_walk>
f010265c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102662:	c7 04 24 9c 6d 10 f0 	movl   $0xf0106d9c,(%esp)
f0102669:	e8 b2 10 00 00       	call   f0103720 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010266e:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102673:	83 c4 10             	add    $0x10,%esp
f0102676:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010267b:	77 15                	ja     f0102692 <mem_init+0x12fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010267d:	50                   	push   %eax
f010267e:	68 08 65 10 f0       	push   $0xf0106508
f0102683:	68 c8 00 00 00       	push   $0xc8
f0102688:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010268d:	e8 ae d9 ff ff       	call   f0100040 <_panic>
f0102692:	83 ec 08             	sub    $0x8,%esp
f0102695:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102697:	05 00 00 00 10       	add    $0x10000000,%eax
f010269c:	50                   	push   %eax
f010269d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026a2:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026a7:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f01026ac:	e8 b1 ea ff ff       	call   f0101162 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01026b1:	a1 68 a2 20 f0       	mov    0xf020a268,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026b6:	83 c4 10             	add    $0x10,%esp
f01026b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026be:	77 15                	ja     f01026d5 <mem_init+0x133d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c0:	50                   	push   %eax
f01026c1:	68 08 65 10 f0       	push   $0xf0106508
f01026c6:	68 d0 00 00 00       	push   $0xd0
f01026cb:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01026d0:	e8 6b d9 ff ff       	call   f0100040 <_panic>
f01026d5:	83 ec 08             	sub    $0x8,%esp
f01026d8:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026da:	05 00 00 00 10       	add    $0x10000000,%eax
f01026df:	50                   	push   %eax
f01026e0:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026e5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026ea:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f01026ef:	e8 6e ea ff ff       	call   f0101162 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f4:	83 c4 10             	add    $0x10,%esp
f01026f7:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01026fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102701:	77 15                	ja     f0102718 <mem_init+0x1380>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102703:	50                   	push   %eax
f0102704:	68 08 65 10 f0       	push   $0xf0106508
f0102709:	68 dc 00 00 00       	push   $0xdc
f010270e:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102713:	e8 28 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102718:	83 ec 08             	sub    $0x8,%esp
f010271b:	6a 02                	push   $0x2
f010271d:	68 00 70 11 00       	push   $0x117000
f0102722:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102727:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010272c:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f0102731:	e8 2c ea ff ff       	call   f0101162 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102736:	83 c4 08             	add    $0x8,%esp
f0102739:	6a 02                	push   $0x2
f010273b:	6a 00                	push   $0x0
f010273d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102742:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102747:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f010274c:	e8 11 ea ff ff       	call   f0101162 <boot_map_region>
f0102751:	c7 45 c4 00 c0 20 f0 	movl   $0xf020c000,-0x3c(%ebp)
f0102758:	83 c4 10             	add    $0x10,%esp
f010275b:	bb 00 c0 20 f0       	mov    $0xf020c000,%ebx
f0102760:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102765:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010276b:	77 15                	ja     f0102782 <mem_init+0x13ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010276d:	53                   	push   %ebx
f010276e:	68 08 65 10 f0       	push   $0xf0106508
f0102773:	68 20 01 00 00       	push   $0x120
f0102778:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010277d:	e8 be d8 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
                boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP),
f0102782:	83 ec 08             	sub    $0x8,%esp
f0102785:	6a 02                	push   $0x2
f0102787:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010278d:	50                   	push   %eax
f010278e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102793:	89 f2                	mov    %esi,%edx
f0102795:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
f010279a:	e8 c3 e9 ff ff       	call   f0101162 <boot_map_region>
f010279f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027a5:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
f01027ab:	83 c4 10             	add    $0x10,%esp
f01027ae:	81 fb 00 c0 24 f0    	cmp    $0xf024c000,%ebx
f01027b4:	75 af                	jne    f0102765 <mem_init+0x13cd>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027b6:	8b 3d cc ae 20 f0    	mov    0xf020aecc,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027bc:	a1 c8 ae 20 f0       	mov    0xf020aec8,%eax
f01027c1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027c4:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027d3:	8b 35 d0 ae 20 f0    	mov    0xf020aed0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d9:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027dc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027e1:	eb 55                	jmp    f0102838 <mem_init+0x14a0>
f01027e3:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027e9:	89 f8                	mov    %edi,%eax
f01027eb:	e8 62 e3 ff ff       	call   f0100b52 <check_va2pa>
f01027f0:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027f7:	77 15                	ja     f010280e <mem_init+0x1476>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027f9:	56                   	push   %esi
f01027fa:	68 08 65 10 f0       	push   $0xf0106508
f01027ff:	68 62 03 00 00       	push   $0x362
f0102804:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102809:	e8 32 d8 ff ff       	call   f0100040 <_panic>
f010280e:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102815:	39 d0                	cmp    %edx,%eax
f0102817:	74 19                	je     f0102832 <mem_init+0x149a>
f0102819:	68 14 75 10 f0       	push   $0xf0107514
f010281e:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102823:	68 62 03 00 00       	push   $0x362
f0102828:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010282d:	e8 0e d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102832:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102838:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010283b:	77 a6                	ja     f01027e3 <mem_init+0x144b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010283d:	8b 35 68 a2 20 f0    	mov    0xf020a268,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102843:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102846:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010284b:	89 da                	mov    %ebx,%edx
f010284d:	89 f8                	mov    %edi,%eax
f010284f:	e8 fe e2 ff ff       	call   f0100b52 <check_va2pa>
f0102854:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010285b:	77 15                	ja     f0102872 <mem_init+0x14da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285d:	56                   	push   %esi
f010285e:	68 08 65 10 f0       	push   $0xf0106508
f0102863:	68 67 03 00 00       	push   $0x367
f0102868:	68 9e 6a 10 f0       	push   $0xf0106a9e
f010286d:	e8 ce d7 ff ff       	call   f0100040 <_panic>
f0102872:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102879:	39 d0                	cmp    %edx,%eax
f010287b:	74 19                	je     f0102896 <mem_init+0x14fe>
f010287d:	68 48 75 10 f0       	push   $0xf0107548
f0102882:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102887:	68 67 03 00 00       	push   $0x367
f010288c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102891:	e8 aa d7 ff ff       	call   f0100040 <_panic>
f0102896:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010289c:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028a2:	75 a7                	jne    f010284b <mem_init+0x14b3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f01028a4:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028a7:	c1 e6 0c             	shl    $0xc,%esi
f01028aa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028af:	eb 30                	jmp    f01028e1 <mem_init+0x1549>
f01028b1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028b7:	89 f8                	mov    %edi,%eax
f01028b9:	e8 94 e2 ff ff       	call   f0100b52 <check_va2pa>
f01028be:	39 c3                	cmp    %eax,%ebx
f01028c0:	74 19                	je     f01028db <mem_init+0x1543>
f01028c2:	68 7c 75 10 f0       	push   $0xf010757c
f01028c7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01028cc:	68 6b 03 00 00       	push   $0x36b
f01028d1:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01028d6:	e8 65 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f01028db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028e1:	39 f3                	cmp    %esi,%ebx
f01028e3:	72 cc                	jb     f01028b1 <mem_init+0x1519>
f01028e5:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01028ec:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028f1:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01028f4:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01028f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028fa:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102900:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102903:	89 c3                	mov    %eax,%ebx
f0102905:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102908:	05 00 80 00 20       	add    $0x20008000,%eax
f010290d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102910:	89 da                	mov    %ebx,%edx
f0102912:	89 f8                	mov    %edi,%eax
f0102914:	e8 39 e2 ff ff       	call   f0100b52 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102919:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010291f:	77 15                	ja     f0102936 <mem_init+0x159e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102921:	56                   	push   %esi
f0102922:	68 08 65 10 f0       	push   $0xf0106508
f0102927:	68 72 03 00 00       	push   $0x372
f010292c:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102931:	e8 0a d7 ff ff       	call   f0100040 <_panic>
f0102936:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102939:	8d 94 0b 00 c0 20 f0 	lea    -0xfdf4000(%ebx,%ecx,1),%edx
f0102940:	39 d0                	cmp    %edx,%eax
f0102942:	74 19                	je     f010295d <mem_init+0x15c5>
f0102944:	68 a4 75 10 f0       	push   $0xf01075a4
f0102949:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010294e:	68 72 03 00 00       	push   $0x372
f0102953:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102958:	e8 e3 d6 ff ff       	call   f0100040 <_panic>
f010295d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102963:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102966:	75 a8                	jne    f0102910 <mem_init+0x1578>
f0102968:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010296b:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102971:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102974:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102976:	89 da                	mov    %ebx,%edx
f0102978:	89 f8                	mov    %edi,%eax
f010297a:	e8 d3 e1 ff ff       	call   f0100b52 <check_va2pa>
f010297f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102982:	74 19                	je     f010299d <mem_init+0x1605>
f0102984:	68 ec 75 10 f0       	push   $0xf01075ec
f0102989:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010298e:	68 74 03 00 00       	push   $0x374
f0102993:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102998:	e8 a3 d6 ff ff       	call   f0100040 <_panic>
f010299d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029a3:	39 de                	cmp    %ebx,%esi
f01029a5:	75 cf                	jne    f0102976 <mem_init+0x15de>
f01029a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029aa:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029b1:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029b8:	81 c6 00 80 00 00    	add    $0x8000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01029be:	81 fe 00 c0 24 f0    	cmp    $0xf024c000,%esi
f01029c4:	0f 85 2d ff ff ff    	jne    f01028f7 <mem_init+0x155f>
f01029ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01029cf:	eb 2a                	jmp    f01029fb <mem_init+0x1663>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029d1:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01029d7:	83 fa 04             	cmp    $0x4,%edx
f01029da:	77 1f                	ja     f01029fb <mem_init+0x1663>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01029dc:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029e0:	75 7e                	jne    f0102a60 <mem_init+0x16c8>
f01029e2:	68 b5 6d 10 f0       	push   $0xf0106db5
f01029e7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01029ec:	68 7f 03 00 00       	push   $0x37f
f01029f1:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01029f6:	e8 45 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029fb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a00:	76 3f                	jbe    f0102a41 <mem_init+0x16a9>
				assert(pgdir[i] & PTE_P);
f0102a02:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a05:	f6 c2 01             	test   $0x1,%dl
f0102a08:	75 19                	jne    f0102a23 <mem_init+0x168b>
f0102a0a:	68 b5 6d 10 f0       	push   $0xf0106db5
f0102a0f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102a14:	68 83 03 00 00       	push   $0x383
f0102a19:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102a1e:	e8 1d d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a23:	f6 c2 02             	test   $0x2,%dl
f0102a26:	75 38                	jne    f0102a60 <mem_init+0x16c8>
f0102a28:	68 c6 6d 10 f0       	push   $0xf0106dc6
f0102a2d:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102a32:	68 84 03 00 00       	push   $0x384
f0102a37:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102a3c:	e8 ff d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a41:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a45:	74 19                	je     f0102a60 <mem_init+0x16c8>
f0102a47:	68 d7 6d 10 f0       	push   $0xf0106dd7
f0102a4c:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102a51:	68 86 03 00 00       	push   $0x386
f0102a56:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102a5b:	e8 e0 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a60:	83 c0 01             	add    $0x1,%eax
f0102a63:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a68:	0f 86 63 ff ff ff    	jbe    f01029d1 <mem_init+0x1639>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a6e:	83 ec 0c             	sub    $0xc,%esp
f0102a71:	68 10 76 10 f0       	push   $0xf0107610
f0102a76:	e8 a5 0c 00 00       	call   f0103720 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a7b:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a80:	83 c4 10             	add    $0x10,%esp
f0102a83:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a88:	77 15                	ja     f0102a9f <mem_init+0x1707>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8a:	50                   	push   %eax
f0102a8b:	68 08 65 10 f0       	push   $0xf0106508
f0102a90:	68 f8 00 00 00       	push   $0xf8
f0102a95:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102a9a:	e8 a1 d5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a9f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102aa4:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102aa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aac:	e8 05 e1 ff ff       	call   f0100bb6 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102ab1:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102ab4:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ab7:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102abc:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102abf:	83 ec 0c             	sub    $0xc,%esp
f0102ac2:	6a 00                	push   $0x0
f0102ac4:	e8 e8 e4 ff ff       	call   f0100fb1 <page_alloc>
f0102ac9:	89 c3                	mov    %eax,%ebx
f0102acb:	83 c4 10             	add    $0x10,%esp
f0102ace:	85 c0                	test   %eax,%eax
f0102ad0:	75 19                	jne    f0102aeb <mem_init+0x1753>
f0102ad2:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0102ad7:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102adc:	68 5e 04 00 00       	push   $0x45e
f0102ae1:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102ae6:	e8 55 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102aeb:	83 ec 0c             	sub    $0xc,%esp
f0102aee:	6a 00                	push   $0x0
f0102af0:	e8 bc e4 ff ff       	call   f0100fb1 <page_alloc>
f0102af5:	89 c7                	mov    %eax,%edi
f0102af7:	83 c4 10             	add    $0x10,%esp
f0102afa:	85 c0                	test   %eax,%eax
f0102afc:	75 19                	jne    f0102b17 <mem_init+0x177f>
f0102afe:	68 d7 6b 10 f0       	push   $0xf0106bd7
f0102b03:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102b08:	68 5f 04 00 00       	push   $0x45f
f0102b0d:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102b12:	e8 29 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b17:	83 ec 0c             	sub    $0xc,%esp
f0102b1a:	6a 00                	push   $0x0
f0102b1c:	e8 90 e4 ff ff       	call   f0100fb1 <page_alloc>
f0102b21:	89 c6                	mov    %eax,%esi
f0102b23:	83 c4 10             	add    $0x10,%esp
f0102b26:	85 c0                	test   %eax,%eax
f0102b28:	75 19                	jne    f0102b43 <mem_init+0x17ab>
f0102b2a:	68 ed 6b 10 f0       	push   $0xf0106bed
f0102b2f:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102b34:	68 60 04 00 00       	push   $0x460
f0102b39:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102b3e:	e8 fd d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b43:	83 ec 0c             	sub    $0xc,%esp
f0102b46:	53                   	push   %ebx
f0102b47:	e8 d3 e4 ff ff       	call   f010101f <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b4c:	89 f8                	mov    %edi,%eax
f0102b4e:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0102b54:	c1 f8 03             	sar    $0x3,%eax
f0102b57:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b5a:	89 c2                	mov    %eax,%edx
f0102b5c:	c1 ea 0c             	shr    $0xc,%edx
f0102b5f:	83 c4 10             	add    $0x10,%esp
f0102b62:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0102b68:	72 12                	jb     f0102b7c <mem_init+0x17e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b6a:	50                   	push   %eax
f0102b6b:	68 e4 64 10 f0       	push   $0xf01064e4
f0102b70:	6a 58                	push   $0x58
f0102b72:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b7c:	83 ec 04             	sub    $0x4,%esp
f0102b7f:	68 00 10 00 00       	push   $0x1000
f0102b84:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b86:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b8b:	50                   	push   %eax
f0102b8c:	e8 55 2c 00 00       	call   f01057e6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b91:	89 f0                	mov    %esi,%eax
f0102b93:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0102b99:	c1 f8 03             	sar    $0x3,%eax
f0102b9c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b9f:	89 c2                	mov    %eax,%edx
f0102ba1:	c1 ea 0c             	shr    $0xc,%edx
f0102ba4:	83 c4 10             	add    $0x10,%esp
f0102ba7:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0102bad:	72 12                	jb     f0102bc1 <mem_init+0x1829>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102baf:	50                   	push   %eax
f0102bb0:	68 e4 64 10 f0       	push   $0xf01064e4
f0102bb5:	6a 58                	push   $0x58
f0102bb7:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0102bbc:	e8 7f d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bc1:	83 ec 04             	sub    $0x4,%esp
f0102bc4:	68 00 10 00 00       	push   $0x1000
f0102bc9:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102bcb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bd0:	50                   	push   %eax
f0102bd1:	e8 10 2c 00 00       	call   f01057e6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bd6:	6a 02                	push   $0x2
f0102bd8:	68 00 10 00 00       	push   $0x1000
f0102bdd:	57                   	push   %edi
f0102bde:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102be4:	e8 de e6 ff ff       	call   f01012c7 <page_insert>
	assert(pp1->pp_ref == 1);
f0102be9:	83 c4 20             	add    $0x20,%esp
f0102bec:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bf1:	74 19                	je     f0102c0c <mem_init+0x1874>
f0102bf3:	68 be 6c 10 f0       	push   $0xf0106cbe
f0102bf8:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102bfd:	68 65 04 00 00       	push   $0x465
f0102c02:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102c07:	e8 34 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c0c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c13:	01 01 01 
f0102c16:	74 19                	je     f0102c31 <mem_init+0x1899>
f0102c18:	68 30 76 10 f0       	push   $0xf0107630
f0102c1d:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102c22:	68 66 04 00 00       	push   $0x466
f0102c27:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102c2c:	e8 0f d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c31:	6a 02                	push   $0x2
f0102c33:	68 00 10 00 00       	push   $0x1000
f0102c38:	56                   	push   %esi
f0102c39:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102c3f:	e8 83 e6 ff ff       	call   f01012c7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c44:	83 c4 10             	add    $0x10,%esp
f0102c47:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c4e:	02 02 02 
f0102c51:	74 19                	je     f0102c6c <mem_init+0x18d4>
f0102c53:	68 54 76 10 f0       	push   $0xf0107654
f0102c58:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102c5d:	68 68 04 00 00       	push   $0x468
f0102c62:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102c67:	e8 d4 d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c6c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c71:	74 19                	je     f0102c8c <mem_init+0x18f4>
f0102c73:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0102c78:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102c7d:	68 69 04 00 00       	push   $0x469
f0102c82:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102c87:	e8 b4 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c8c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c91:	74 19                	je     f0102cac <mem_init+0x1914>
f0102c93:	68 4a 6d 10 f0       	push   $0xf0106d4a
f0102c98:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102c9d:	68 6a 04 00 00       	push   $0x46a
f0102ca2:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cac:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cb3:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cb6:	89 f0                	mov    %esi,%eax
f0102cb8:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0102cbe:	c1 f8 03             	sar    $0x3,%eax
f0102cc1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cc4:	89 c2                	mov    %eax,%edx
f0102cc6:	c1 ea 0c             	shr    $0xc,%edx
f0102cc9:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f0102ccf:	72 12                	jb     f0102ce3 <mem_init+0x194b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd1:	50                   	push   %eax
f0102cd2:	68 e4 64 10 f0       	push   $0xf01064e4
f0102cd7:	6a 58                	push   $0x58
f0102cd9:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0102cde:	e8 5d d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ce3:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cea:	03 03 03 
f0102ced:	74 19                	je     f0102d08 <mem_init+0x1970>
f0102cef:	68 78 76 10 f0       	push   $0xf0107678
f0102cf4:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102cf9:	68 6c 04 00 00       	push   $0x46c
f0102cfe:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102d03:	e8 38 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d08:	83 ec 08             	sub    $0x8,%esp
f0102d0b:	68 00 10 00 00       	push   $0x1000
f0102d10:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0102d16:	e8 5b e5 ff ff       	call   f0101276 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d1b:	83 c4 10             	add    $0x10,%esp
f0102d1e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d23:	74 19                	je     f0102d3e <mem_init+0x19a6>
f0102d25:	68 18 6d 10 f0       	push   $0xf0106d18
f0102d2a:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102d2f:	68 6e 04 00 00       	push   $0x46e
f0102d34:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102d39:	e8 02 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d3e:	8b 0d cc ae 20 f0    	mov    0xf020aecc,%ecx
f0102d44:	8b 11                	mov    (%ecx),%edx
f0102d46:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d4c:	89 d8                	mov    %ebx,%eax
f0102d4e:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f0102d54:	c1 f8 03             	sar    $0x3,%eax
f0102d57:	c1 e0 0c             	shl    $0xc,%eax
f0102d5a:	39 c2                	cmp    %eax,%edx
f0102d5c:	74 19                	je     f0102d77 <mem_init+0x19df>
f0102d5e:	68 00 70 10 f0       	push   $0xf0107000
f0102d63:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102d68:	68 71 04 00 00       	push   $0x471
f0102d6d:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102d72:	e8 c9 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d77:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d7d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d82:	74 19                	je     f0102d9d <mem_init+0x1a05>
f0102d84:	68 cf 6c 10 f0       	push   $0xf0106ccf
f0102d89:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102d8e:	68 73 04 00 00       	push   $0x473
f0102d93:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0102d98:	e8 a3 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d9d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102da3:	83 ec 0c             	sub    $0xc,%esp
f0102da6:	53                   	push   %ebx
f0102da7:	e8 73 e2 ff ff       	call   f010101f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dac:	c7 04 24 a4 76 10 f0 	movl   $0xf01076a4,(%esp)
f0102db3:	e8 68 09 00 00       	call   f0103720 <cprintf>
f0102db8:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dbe:	5b                   	pop    %ebx
f0102dbf:	5e                   	pop    %esi
f0102dc0:	5f                   	pop    %edi
f0102dc1:	5d                   	pop    %ebp
f0102dc2:	c3                   	ret    

f0102dc3 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102dc3:	55                   	push   %ebp
f0102dc4:	89 e5                	mov    %esp,%ebp
f0102dc6:	57                   	push   %edi
f0102dc7:	56                   	push   %esi
f0102dc8:	53                   	push   %ebx
f0102dc9:	83 ec 1c             	sub    $0x1c,%esp
f0102dcc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102dcf:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102dd5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uint32_t end = (uint32_t) (va+len);
f0102ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dde:	03 45 10             	add    0x10(%ebp),%eax
f0102de1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102de4:	eb 43                	jmp    f0102e29 <user_mem_check+0x66>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102de6:	83 ec 04             	sub    $0x4,%esp
f0102de9:	6a 00                	push   $0x0
f0102deb:	53                   	push   %ebx
f0102dec:	ff 77 60             	pushl  0x60(%edi)
f0102def:	e8 91 e2 ff ff       	call   f0101085 <pgdir_walk>
       
                if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102df4:	83 c4 10             	add    $0x10,%esp
f0102df7:	85 c0                	test   %eax,%eax
f0102df9:	74 14                	je     f0102e0f <user_mem_check+0x4c>
f0102dfb:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e01:	77 0c                	ja     f0102e0f <user_mem_check+0x4c>
f0102e03:	8b 00                	mov    (%eax),%eax
f0102e05:	a8 01                	test   $0x1,%al
f0102e07:	74 06                	je     f0102e0f <user_mem_check+0x4c>
f0102e09:	21 f0                	and    %esi,%eax
f0102e0b:	39 c6                	cmp    %eax,%esi
f0102e0d:	74 14                	je     f0102e23 <user_mem_check+0x60>
f0102e0f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e12:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e16:	89 1d 5c a2 20 f0    	mov    %ebx,0xf020a25c
                      return -E_FAULT;
f0102e1c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e21:	eb 10                	jmp    f0102e33 <user_mem_check+0x70>
{
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
        uint32_t end = (uint32_t) (va+len);
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102e23:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e29:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e2c:	72 b8                	jb     f0102de6 <user_mem_check+0x23>
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                      return -E_FAULT;
                }
        }
         
	return 0;
f0102e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e36:	5b                   	pop    %ebx
f0102e37:	5e                   	pop    %esi
f0102e38:	5f                   	pop    %edi
f0102e39:	5d                   	pop    %ebp
f0102e3a:	c3                   	ret    

f0102e3b <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e3b:	55                   	push   %ebp
f0102e3c:	89 e5                	mov    %esp,%ebp
f0102e3e:	53                   	push   %ebx
f0102e3f:	83 ec 04             	sub    $0x4,%esp
f0102e42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e45:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e48:	83 c8 04             	or     $0x4,%eax
f0102e4b:	50                   	push   %eax
f0102e4c:	ff 75 10             	pushl  0x10(%ebp)
f0102e4f:	ff 75 0c             	pushl  0xc(%ebp)
f0102e52:	53                   	push   %ebx
f0102e53:	e8 6b ff ff ff       	call   f0102dc3 <user_mem_check>
f0102e58:	83 c4 10             	add    $0x10,%esp
f0102e5b:	85 c0                	test   %eax,%eax
f0102e5d:	79 21                	jns    f0102e80 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e5f:	83 ec 04             	sub    $0x4,%esp
f0102e62:	ff 35 5c a2 20 f0    	pushl  0xf020a25c
f0102e68:	ff 73 48             	pushl  0x48(%ebx)
f0102e6b:	68 d0 76 10 f0       	push   $0xf01076d0
f0102e70:	e8 ab 08 00 00       	call   f0103720 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e75:	89 1c 24             	mov    %ebx,(%esp)
f0102e78:	e8 bc 05 00 00       	call   f0103439 <env_destroy>
f0102e7d:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e83:	c9                   	leave  
f0102e84:	c3                   	ret    

f0102e85 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e85:	55                   	push   %ebp
f0102e86:	89 e5                	mov    %esp,%ebp
f0102e88:	57                   	push   %edi
f0102e89:	56                   	push   %esi
f0102e8a:	53                   	push   %ebx
f0102e8b:	83 ec 1c             	sub    $0x1c,%esp
f0102e8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        int i;
        struct PageInfo *newpage;
        va = ROUNDDOWN(va, PGSIZE);
f0102e91:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e97:	89 55 e0             	mov    %edx,-0x20(%ebp)
        len = ROUNDUP(len, PGSIZE);
f0102e9a:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102ea0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102ea6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        for(i = 0; i < len; i+=PGSIZE) {
f0102ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102eae:	eb 52                	jmp    f0102f02 <region_alloc+0x7d>
                if((newpage = page_alloc(0)) == NULL)
f0102eb0:	83 ec 0c             	sub    $0xc,%esp
f0102eb3:	6a 00                	push   $0x0
f0102eb5:	e8 f7 e0 ff ff       	call   f0100fb1 <page_alloc>
f0102eba:	89 c7                	mov    %eax,%edi
f0102ebc:	83 c4 10             	add    $0x10,%esp
f0102ebf:	85 c0                	test   %eax,%eax
f0102ec1:	75 10                	jne    f0102ed3 <region_alloc+0x4e>
                       cprintf("page_alloc return null\n");
f0102ec3:	83 ec 0c             	sub    $0xc,%esp
f0102ec6:	68 05 77 10 f0       	push   $0xf0107705
f0102ecb:	e8 50 08 00 00       	call   f0103720 <cprintf>
f0102ed0:	83 c4 10             	add    $0x10,%esp
                if(page_insert(e->env_pgdir, newpage, va + i, PTE_U | PTE_W) < 0)
f0102ed3:	6a 06                	push   $0x6
f0102ed5:	03 75 e0             	add    -0x20(%ebp),%esi
f0102ed8:	56                   	push   %esi
f0102ed9:	57                   	push   %edi
f0102eda:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102edd:	ff 70 60             	pushl  0x60(%eax)
f0102ee0:	e8 e2 e3 ff ff       	call   f01012c7 <page_insert>
f0102ee5:	83 c4 10             	add    $0x10,%esp
f0102ee8:	85 c0                	test   %eax,%eax
f0102eea:	79 10                	jns    f0102efc <region_alloc+0x77>
                       cprintf("insert failing\n");
f0102eec:	83 ec 0c             	sub    $0xc,%esp
f0102eef:	68 1d 77 10 f0       	push   $0xf010771d
f0102ef4:	e8 27 08 00 00       	call   f0103720 <cprintf>
f0102ef9:	83 c4 10             	add    $0x10,%esp
	//   (Watch out for corner-cases!)
        int i;
        struct PageInfo *newpage;
        va = ROUNDDOWN(va, PGSIZE);
        len = ROUNDUP(len, PGSIZE);
        for(i = 0; i < len; i+=PGSIZE) {
f0102efc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f02:	89 de                	mov    %ebx,%esi
f0102f04:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102f07:	77 a7                	ja     f0102eb0 <region_alloc+0x2b>
                       cprintf("page_alloc return null\n");
                if(page_insert(e->env_pgdir, newpage, va + i, PTE_U | PTE_W) < 0)
                       cprintf("insert failing\n");

        }
}
f0102f09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f0c:	5b                   	pop    %ebx
f0102f0d:	5e                   	pop    %esi
f0102f0e:	5f                   	pop    %edi
f0102f0f:	5d                   	pop    %ebp
f0102f10:	c3                   	ret    

f0102f11 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f11:	55                   	push   %ebp
f0102f12:	89 e5                	mov    %esp,%ebp
f0102f14:	56                   	push   %esi
f0102f15:	53                   	push   %ebx
f0102f16:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f19:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f1c:	85 c0                	test   %eax,%eax
f0102f1e:	75 1a                	jne    f0102f3a <envid2env+0x29>
		*env_store = curenv;
f0102f20:	e8 e6 2e 00 00       	call   f0105e0b <cpunum>
f0102f25:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f28:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0102f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f31:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f38:	eb 70                	jmp    f0102faa <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f3a:	89 c3                	mov    %eax,%ebx
f0102f3c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f42:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f45:	03 1d 68 a2 20 f0    	add    0xf020a268,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f4b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f4f:	74 05                	je     f0102f56 <envid2env+0x45>
f0102f51:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f54:	74 10                	je     f0102f66 <envid2env+0x55>
		*env_store = 0;
f0102f56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f5f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f64:	eb 44                	jmp    f0102faa <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f66:	84 d2                	test   %dl,%dl
f0102f68:	74 36                	je     f0102fa0 <envid2env+0x8f>
f0102f6a:	e8 9c 2e 00 00       	call   f0105e0b <cpunum>
f0102f6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f72:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f0102f78:	74 26                	je     f0102fa0 <envid2env+0x8f>
f0102f7a:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f7d:	e8 89 2e 00 00       	call   f0105e0b <cpunum>
f0102f82:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f85:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0102f8b:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f8e:	74 10                	je     f0102fa0 <envid2env+0x8f>
		*env_store = 0;
f0102f90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f99:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f9e:	eb 0a                	jmp    f0102faa <envid2env+0x99>
	}

	*env_store = e;
f0102fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fa3:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102faa:	5b                   	pop    %ebx
f0102fab:	5e                   	pop    %esi
f0102fac:	5d                   	pop    %ebp
f0102fad:	c3                   	ret    

f0102fae <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102fae:	55                   	push   %ebp
f0102faf:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102fb1:	b8 40 13 12 f0       	mov    $0xf0121340,%eax
f0102fb6:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102fb9:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fbe:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102fc0:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102fc2:	b0 10                	mov    $0x10,%al
f0102fc4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102fc6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102fc8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102fca:	ea d1 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fd1
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102fd1:	b0 00                	mov    $0x0,%al
f0102fd3:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fd6:	5d                   	pop    %ebp
f0102fd7:	c3                   	ret    

f0102fd8 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102fd8:	55                   	push   %ebp
f0102fd9:	89 e5                	mov    %esp,%ebp
f0102fdb:	56                   	push   %esi
f0102fdc:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
		envs[i].env_id = 0;
f0102fdd:	8b 35 68 a2 20 f0    	mov    0xf020a268,%esi
f0102fe3:	8b 15 6c a2 20 f0    	mov    0xf020a26c,%edx
f0102fe9:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102fef:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102ff2:	89 c1                	mov    %eax,%ecx
f0102ff4:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102ffb:	89 50 44             	mov    %edx,0x44(%eax)
f0102ffe:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f0103001:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
f0103003:	39 d8                	cmp    %ebx,%eax
f0103005:	75 eb                	jne    f0102ff2 <env_init+0x1a>
f0103007:	89 35 6c a2 20 f0    	mov    %esi,0xf020a26c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	} 
	// Per-CPU part of the initialization
	env_init_percpu();
f010300d:	e8 9c ff ff ff       	call   f0102fae <env_init_percpu>
                
}
f0103012:	5b                   	pop    %ebx
f0103013:	5e                   	pop    %esi
f0103014:	5d                   	pop    %ebp
f0103015:	c3                   	ret    

f0103016 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103016:	55                   	push   %ebp
f0103017:	89 e5                	mov    %esp,%ebp
f0103019:	53                   	push   %ebx
f010301a:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
f010301d:	8b 1d 6c a2 20 f0    	mov    0xf020a26c,%ebx
f0103023:	85 db                	test   %ebx,%ebx
f0103025:	0f 84 2d 01 00 00    	je     f0103158 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010302b:	83 ec 0c             	sub    $0xc,%esp
f010302e:	6a 01                	push   $0x1
f0103030:	e8 7c df ff ff       	call   f0100fb1 <page_alloc>
f0103035:	83 c4 10             	add    $0x10,%esp
f0103038:	85 c0                	test   %eax,%eax
f010303a:	0f 84 1f 01 00 00    	je     f010315f <env_alloc+0x149>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        p->pp_ref++;
f0103040:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103045:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f010304b:	c1 f8 03             	sar    $0x3,%eax
f010304e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103051:	89 c2                	mov    %eax,%edx
f0103053:	c1 ea 0c             	shr    $0xc,%edx
f0103056:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f010305c:	72 12                	jb     f0103070 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010305e:	50                   	push   %eax
f010305f:	68 e4 64 10 f0       	push   $0xf01064e4
f0103064:	6a 58                	push   $0x58
f0103066:	68 aa 6a 10 f0       	push   $0xf0106aaa
f010306b:	e8 d0 cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103070:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = page2kva(p);    
f0103075:	89 43 60             	mov    %eax,0x60(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
f0103078:	83 ec 04             	sub    $0x4,%esp
f010307b:	68 00 10 00 00       	push   $0x1000
f0103080:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0103086:	50                   	push   %eax
f0103087:	e8 0f 28 00 00       	call   f010589b <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010308c:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010308f:	83 c4 10             	add    $0x10,%esp
f0103092:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103097:	77 15                	ja     f01030ae <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103099:	50                   	push   %eax
f010309a:	68 08 65 10 f0       	push   $0xf0106508
f010309f:	68 c4 00 00 00       	push   $0xc4
f01030a4:	68 2d 77 10 f0       	push   $0xf010772d
f01030a9:	e8 92 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030ae:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030b4:	83 ca 05             	or     $0x5,%edx
f01030b7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0) 
		return r;
 
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030bd:	8b 43 48             	mov    0x48(%ebx),%eax
f01030c0:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030c5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030ca:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030cf:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01030d2:	89 da                	mov    %ebx,%edx
f01030d4:	2b 15 68 a2 20 f0    	sub    0xf020a268,%edx
f01030da:	c1 fa 02             	sar    $0x2,%edx
f01030dd:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030e3:	09 d0                	or     %edx,%eax
f01030e5:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030eb:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030ee:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030f5:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030fc:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103103:	83 ec 04             	sub    $0x4,%esp
f0103106:	6a 44                	push   $0x44
f0103108:	6a 00                	push   $0x0
f010310a:	53                   	push   %ebx
f010310b:	e8 d6 26 00 00       	call   f01057e6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103110:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103116:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010311c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103122:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103129:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f010312f:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103136:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010313d:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103141:	8b 43 44             	mov    0x44(%ebx),%eax
f0103144:	a3 6c a2 20 f0       	mov    %eax,0xf020a26c
	*newenv_store = e;
f0103149:	8b 45 08             	mov    0x8(%ebp),%eax
f010314c:	89 18                	mov    %ebx,(%eax)
	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
f010314e:	83 c4 10             	add    $0x10,%esp
f0103151:	b8 00 00 00 00       	mov    $0x0,%eax
f0103156:	eb 0c                	jmp    f0103164 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
		return -E_NO_FREE_ENV;
f0103158:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010315d:	eb 05                	jmp    f0103164 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010315f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
}
f0103164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103167:	c9                   	leave  
f0103168:	c3                   	ret    

f0103169 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103169:	55                   	push   %ebp
f010316a:	89 e5                	mov    %esp,%ebp
f010316c:	57                   	push   %edi
f010316d:	56                   	push   %esi
f010316e:	53                   	push   %ebx
f010316f:	83 ec 34             	sub    $0x34,%esp
f0103172:	8b 75 08             	mov    0x8(%ebp),%esi
f0103175:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *e;
        int tmp;
        if((tmp = env_alloc(&e, 0)) != 0)
f0103178:	6a 00                	push   $0x0
f010317a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010317d:	50                   	push   %eax
f010317e:	e8 93 fe ff ff       	call   f0103016 <env_alloc>
f0103183:	83 c4 10             	add    $0x10,%esp
f0103186:	85 c0                	test   %eax,%eax
f0103188:	74 17                	je     f01031a1 <env_create+0x38>
               panic("evn create fails!\n");
f010318a:	83 ec 04             	sub    $0x4,%esp
f010318d:	68 38 77 10 f0       	push   $0xf0107738
f0103192:	68 8d 01 00 00       	push   $0x18d
f0103197:	68 2d 77 10 f0       	push   $0xf010772d
f010319c:	e8 9f ce ff ff       	call   f0100040 <_panic>
       

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
        if (type == ENV_TYPE_FS)
f01031a1:	83 fb 01             	cmp    $0x1,%ebx
f01031a4:	75 0a                	jne    f01031b0 <env_create+0x47>
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031a9:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
        e->env_type =type;
f01031b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031b3:	89 5f 50             	mov    %ebx,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf_img = (struct Elf *)binary;
        struct Proghdr *ph, *eph;
        if (elf_img->e_magic != ELF_MAGIC)
f01031b6:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01031bc:	74 17                	je     f01031d5 <env_create+0x6c>
                panic("Not executable!");
f01031be:	83 ec 04             	sub    $0x4,%esp
f01031c1:	68 4b 77 10 f0       	push   $0xf010774b
f01031c6:	68 6c 01 00 00       	push   $0x16c
f01031cb:	68 2d 77 10 f0       	push   $0xf010772d
f01031d0:	e8 6b ce ff ff       	call   f0100040 <_panic>
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
f01031d5:	89 f3                	mov    %esi,%ebx
f01031d7:	03 5e 1c             	add    0x1c(%esi),%ebx
        eph = ph + elf_img->e_phnum;
f01031da:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01031de:	c1 e0 05             	shl    $0x5,%eax
f01031e1:	01 d8                	add    %ebx,%eax
f01031e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        lcr3(PADDR(e->env_pgdir));
f01031e6:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ee:	77 15                	ja     f0103205 <env_create+0x9c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f0:	50                   	push   %eax
f01031f1:	68 08 65 10 f0       	push   $0xf0106508
f01031f6:	68 6f 01 00 00       	push   $0x16f
f01031fb:	68 2d 77 10 f0       	push   $0xf010772d
f0103200:	e8 3b ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103205:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010320a:	0f 22 d8             	mov    %eax,%cr3
f010320d:	eb 37                	jmp    f0103246 <env_create+0xdd>
        
        for(; ph < eph; ph++) {
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010320f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103212:	8b 53 08             	mov    0x8(%ebx),%edx
f0103215:	89 f8                	mov    %edi,%eax
f0103217:	e8 69 fc ff ff       	call   f0102e85 <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f010321c:	83 ec 04             	sub    $0x4,%esp
f010321f:	ff 73 14             	pushl  0x14(%ebx)
f0103222:	6a 00                	push   $0x0
f0103224:	ff 73 08             	pushl  0x8(%ebx)
f0103227:	e8 ba 25 00 00       	call   f01057e6 <memset>
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010322c:	83 c4 0c             	add    $0xc,%esp
f010322f:	ff 73 10             	pushl  0x10(%ebx)
f0103232:	89 f0                	mov    %esi,%eax
f0103234:	03 43 04             	add    0x4(%ebx),%eax
f0103237:	50                   	push   %eax
f0103238:	ff 73 08             	pushl  0x8(%ebx)
f010323b:	e8 5b 26 00 00       	call   f010589b <memcpy>
                panic("Not executable!");
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        eph = ph + elf_img->e_phnum;
        lcr3(PADDR(e->env_pgdir));
        
        for(; ph < eph; ph++) {
f0103240:	83 c3 20             	add    $0x20,%ebx
f0103243:	83 c4 10             	add    $0x10,%esp
f0103246:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103249:	77 c4                	ja     f010320f <env_create+0xa6>
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        }
        lcr3(PADDR(kern_pgdir));
f010324b:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103250:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103255:	77 15                	ja     f010326c <env_create+0x103>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103257:	50                   	push   %eax
f0103258:	68 08 65 10 f0       	push   $0xf0106508
f010325d:	68 76 01 00 00       	push   $0x176
f0103262:	68 2d 77 10 f0       	push   $0xf010772d
f0103267:	e8 d4 cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010326c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103271:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elf_img->e_entry;
f0103274:	8b 46 18             	mov    0x18(%esi),%eax
f0103277:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f010327a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010327f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103284:	89 f8                	mov    %edi,%eax
f0103286:	e8 fa fb ff ff       	call   f0102e85 <region_alloc>
        if (type == ENV_TYPE_FS)
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
        e->env_type =type;
        load_icode(e, binary);
 
}
f010328b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010328e:	5b                   	pop    %ebx
f010328f:	5e                   	pop    %esi
f0103290:	5f                   	pop    %edi
f0103291:	5d                   	pop    %ebp
f0103292:	c3                   	ret    

f0103293 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103293:	55                   	push   %ebp
f0103294:	89 e5                	mov    %esp,%ebp
f0103296:	57                   	push   %edi
f0103297:	56                   	push   %esi
f0103298:	53                   	push   %ebx
f0103299:	83 ec 1c             	sub    $0x1c,%esp
f010329c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010329f:	e8 67 2b 00 00       	call   f0105e0b <cpunum>
f01032a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01032a7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032ae:	39 b8 48 b0 20 f0    	cmp    %edi,-0xfdf4fb8(%eax)
f01032b4:	75 30                	jne    f01032e6 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01032b6:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032c0:	77 15                	ja     f01032d7 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032c2:	50                   	push   %eax
f01032c3:	68 08 65 10 f0       	push   $0xf0106508
f01032c8:	68 a7 01 00 00       	push   $0x1a7
f01032cd:	68 2d 77 10 f0       	push   $0xf010772d
f01032d2:	e8 69 cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01032dc:	0f 22 d8             	mov    %eax,%cr3
f01032df:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032e9:	89 d0                	mov    %edx,%eax
f01032eb:	c1 e0 02             	shl    $0x2,%eax
f01032ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032f1:	8b 47 60             	mov    0x60(%edi),%eax
f01032f4:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032f7:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032fd:	0f 84 a8 00 00 00    	je     f01033ab <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103303:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103309:	89 f0                	mov    %esi,%eax
f010330b:	c1 e8 0c             	shr    $0xc,%eax
f010330e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103311:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f0103317:	72 15                	jb     f010332e <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103319:	56                   	push   %esi
f010331a:	68 e4 64 10 f0       	push   $0xf01064e4
f010331f:	68 b6 01 00 00       	push   $0x1b6
f0103324:	68 2d 77 10 f0       	push   $0xf010772d
f0103329:	e8 12 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010332e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103331:	c1 e0 16             	shl    $0x16,%eax
f0103334:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103337:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010333c:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103343:	01 
f0103344:	74 17                	je     f010335d <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103346:	83 ec 08             	sub    $0x8,%esp
f0103349:	89 d8                	mov    %ebx,%eax
f010334b:	c1 e0 0c             	shl    $0xc,%eax
f010334e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103351:	50                   	push   %eax
f0103352:	ff 77 60             	pushl  0x60(%edi)
f0103355:	e8 1c df ff ff       	call   f0101276 <page_remove>
f010335a:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010335d:	83 c3 01             	add    $0x1,%ebx
f0103360:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103366:	75 d4                	jne    f010333c <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103368:	8b 47 60             	mov    0x60(%edi),%eax
f010336b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010336e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103375:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103378:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f010337e:	72 14                	jb     f0103394 <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103380:	83 ec 04             	sub    $0x4,%esp
f0103383:	68 ac 6e 10 f0       	push   $0xf0106eac
f0103388:	6a 51                	push   $0x51
f010338a:	68 aa 6a 10 f0       	push   $0xf0106aaa
f010338f:	e8 ac cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103394:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103397:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
f010339c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010339f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033a2:	50                   	push   %eax
f01033a3:	e8 b6 dc ff ff       	call   f010105e <page_decref>
f01033a8:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033ab:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01033af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033b2:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01033b7:	0f 85 29 ff ff ff    	jne    f01032e6 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033bd:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033c5:	77 15                	ja     f01033dc <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033c7:	50                   	push   %eax
f01033c8:	68 08 65 10 f0       	push   $0xf0106508
f01033cd:	68 c4 01 00 00       	push   $0x1c4
f01033d2:	68 2d 77 10 f0       	push   $0xf010772d
f01033d7:	e8 64 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01033dc:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033e3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033e8:	c1 e8 0c             	shr    $0xc,%eax
f01033eb:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f01033f1:	72 14                	jb     f0103407 <env_free+0x174>
		panic("pa2page called with invalid pa");
f01033f3:	83 ec 04             	sub    $0x4,%esp
f01033f6:	68 ac 6e 10 f0       	push   $0xf0106eac
f01033fb:	6a 51                	push   $0x51
f01033fd:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0103402:	e8 39 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103407:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010340a:	8b 15 d0 ae 20 f0    	mov    0xf020aed0,%edx
f0103410:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103413:	50                   	push   %eax
f0103414:	e8 45 dc ff ff       	call   f010105e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103419:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103420:	a1 6c a2 20 f0       	mov    0xf020a26c,%eax
f0103425:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103428:	89 3d 6c a2 20 f0    	mov    %edi,0xf020a26c
f010342e:	83 c4 10             	add    $0x10,%esp
}
f0103431:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103434:	5b                   	pop    %ebx
f0103435:	5e                   	pop    %esi
f0103436:	5f                   	pop    %edi
f0103437:	5d                   	pop    %ebp
f0103438:	c3                   	ret    

f0103439 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103439:	55                   	push   %ebp
f010343a:	89 e5                	mov    %esp,%ebp
f010343c:	53                   	push   %ebx
f010343d:	83 ec 04             	sub    $0x4,%esp
f0103440:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103443:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103447:	75 19                	jne    f0103462 <env_destroy+0x29>
f0103449:	e8 bd 29 00 00       	call   f0105e0b <cpunum>
f010344e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103451:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f0103457:	74 09                	je     f0103462 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103459:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103460:	eb 33                	jmp    f0103495 <env_destroy+0x5c>
	}

	env_free(e);
f0103462:	83 ec 0c             	sub    $0xc,%esp
f0103465:	53                   	push   %ebx
f0103466:	e8 28 fe ff ff       	call   f0103293 <env_free>

	if (curenv == e) {
f010346b:	e8 9b 29 00 00       	call   f0105e0b <cpunum>
f0103470:	6b c0 74             	imul   $0x74,%eax,%eax
f0103473:	83 c4 10             	add    $0x10,%esp
f0103476:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f010347c:	75 17                	jne    f0103495 <env_destroy+0x5c>
		curenv = NULL;
f010347e:	e8 88 29 00 00       	call   f0105e0b <cpunum>
f0103483:	6b c0 74             	imul   $0x74,%eax,%eax
f0103486:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f010348d:	00 00 00 
		sched_yield();
f0103490:	e8 e7 10 00 00       	call   f010457c <sched_yield>
	}
}
f0103495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103498:	c9                   	leave  
f0103499:	c3                   	ret    

f010349a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010349a:	55                   	push   %ebp
f010349b:	89 e5                	mov    %esp,%ebp
f010349d:	53                   	push   %ebx
f010349e:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034a1:	e8 65 29 00 00       	call   f0105e0b <cpunum>
f01034a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a9:	8b 98 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%ebx
f01034af:	e8 57 29 00 00       	call   f0105e0b <cpunum>
f01034b4:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01034b7:	8b 65 08             	mov    0x8(%ebp),%esp
f01034ba:	61                   	popa   
f01034bb:	07                   	pop    %es
f01034bc:	1f                   	pop    %ds
f01034bd:	83 c4 08             	add    $0x8,%esp
f01034c0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034c1:	83 ec 04             	sub    $0x4,%esp
f01034c4:	68 5b 77 10 f0       	push   $0xf010775b
f01034c9:	68 fa 01 00 00       	push   $0x1fa
f01034ce:	68 2d 77 10 f0       	push   $0xf010772d
f01034d3:	e8 68 cb ff ff       	call   f0100040 <_panic>

f01034d8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034d8:	55                   	push   %ebp
f01034d9:	89 e5                	mov    %esp,%ebp
f01034db:	53                   	push   %ebx
f01034dc:	83 ec 04             	sub    $0x4,%esp
f01034df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if( e != curenv) {
f01034e2:	e8 24 29 00 00       	call   f0105e0b <cpunum>
f01034e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ea:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f01034f0:	0f 84 a4 00 00 00    	je     f010359a <env_run+0xc2>
                if (curenv && curenv->env_status == ENV_RUNNING)
f01034f6:	e8 10 29 00 00       	call   f0105e0b <cpunum>
f01034fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01034fe:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0103505:	74 29                	je     f0103530 <env_run+0x58>
f0103507:	e8 ff 28 00 00       	call   f0105e0b <cpunum>
f010350c:	6b c0 74             	imul   $0x74,%eax,%eax
f010350f:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0103515:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103519:	75 15                	jne    f0103530 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f010351b:	e8 eb 28 00 00       	call   f0105e0b <cpunum>
f0103520:	6b c0 74             	imul   $0x74,%eax,%eax
f0103523:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0103529:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
                curenv = e;
f0103530:	e8 d6 28 00 00       	call   f0105e0b <cpunum>
f0103535:	6b c0 74             	imul   $0x74,%eax,%eax
f0103538:	89 98 48 b0 20 f0    	mov    %ebx,-0xfdf4fb8(%eax)
                curenv->env_runs++;
f010353e:	e8 c8 28 00 00       	call   f0105e0b <cpunum>
f0103543:	6b c0 74             	imul   $0x74,%eax,%eax
f0103546:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010354c:	83 40 58 01          	addl   $0x1,0x58(%eax)
                curenv->env_status = ENV_RUNNING;
f0103550:	e8 b6 28 00 00       	call   f0105e0b <cpunum>
f0103555:	6b c0 74             	imul   $0x74,%eax,%eax
f0103558:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010355e:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
                lcr3(PADDR(curenv->env_pgdir));
f0103565:	e8 a1 28 00 00       	call   f0105e0b <cpunum>
f010356a:	6b c0 74             	imul   $0x74,%eax,%eax
f010356d:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0103573:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103576:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010357b:	77 15                	ja     f0103592 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010357d:	50                   	push   %eax
f010357e:	68 08 65 10 f0       	push   $0xf0106508
f0103583:	68 1e 02 00 00       	push   $0x21e
f0103588:	68 2d 77 10 f0       	push   $0xf010772d
f010358d:	e8 ae ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103592:	05 00 00 00 10       	add    $0x10000000,%eax
f0103597:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010359a:	83 ec 0c             	sub    $0xc,%esp
f010359d:	68 00 14 12 f0       	push   $0xf0121400
f01035a2:	e8 6c 2b 00 00       	call   f0106113 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01035a7:	f3 90                	pause  
        }
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01035a9:	e8 5d 28 00 00       	call   f0105e0b <cpunum>
f01035ae:	83 c4 04             	add    $0x4,%esp
f01035b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b4:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f01035ba:	e8 db fe ff ff       	call   f010349a <env_pop_tf>

f01035bf <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035bf:	55                   	push   %ebp
f01035c0:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035c2:	ba 70 00 00 00       	mov    $0x70,%edx
f01035c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ca:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035cb:	b2 71                	mov    $0x71,%dl
f01035cd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035ce:	0f b6 c0             	movzbl %al,%eax
}
f01035d1:	5d                   	pop    %ebp
f01035d2:	c3                   	ret    

f01035d3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035d3:	55                   	push   %ebp
f01035d4:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035d6:	ba 70 00 00 00       	mov    $0x70,%edx
f01035db:	8b 45 08             	mov    0x8(%ebp),%eax
f01035de:	ee                   	out    %al,(%dx)
f01035df:	b2 71                	mov    $0x71,%dl
f01035e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035e4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035e5:	5d                   	pop    %ebp
f01035e6:	c3                   	ret    

f01035e7 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035e7:	55                   	push   %ebp
f01035e8:	89 e5                	mov    %esp,%ebp
f01035ea:	56                   	push   %esi
f01035eb:	53                   	push   %ebx
f01035ec:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035ef:	66 a3 e8 13 12 f0    	mov    %ax,0xf01213e8
	if (!didinit)
f01035f5:	80 3d 70 a2 20 f0 00 	cmpb   $0x0,0xf020a270
f01035fc:	74 57                	je     f0103655 <irq_setmask_8259A+0x6e>
f01035fe:	89 c6                	mov    %eax,%esi
f0103600:	ba 21 00 00 00       	mov    $0x21,%edx
f0103605:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103606:	66 c1 e8 08          	shr    $0x8,%ax
f010360a:	b2 a1                	mov    $0xa1,%dl
f010360c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010360d:	83 ec 0c             	sub    $0xc,%esp
f0103610:	68 67 77 10 f0       	push   $0xf0107767
f0103615:	e8 06 01 00 00       	call   f0103720 <cprintf>
f010361a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010361d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103622:	0f b7 f6             	movzwl %si,%esi
f0103625:	f7 d6                	not    %esi
f0103627:	0f a3 de             	bt     %ebx,%esi
f010362a:	73 11                	jae    f010363d <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010362c:	83 ec 08             	sub    $0x8,%esp
f010362f:	53                   	push   %ebx
f0103630:	68 2b 7c 10 f0       	push   $0xf0107c2b
f0103635:	e8 e6 00 00 00       	call   f0103720 <cprintf>
f010363a:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010363d:	83 c3 01             	add    $0x1,%ebx
f0103640:	83 fb 10             	cmp    $0x10,%ebx
f0103643:	75 e2                	jne    f0103627 <irq_setmask_8259A+0x40>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103645:	83 ec 0c             	sub    $0xc,%esp
f0103648:	68 b3 6d 10 f0       	push   $0xf0106db3
f010364d:	e8 ce 00 00 00       	call   f0103720 <cprintf>
f0103652:	83 c4 10             	add    $0x10,%esp
}
f0103655:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103658:	5b                   	pop    %ebx
f0103659:	5e                   	pop    %esi
f010365a:	5d                   	pop    %ebp
f010365b:	c3                   	ret    

f010365c <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010365c:	c6 05 70 a2 20 f0 01 	movb   $0x1,0xf020a270
f0103663:	ba 21 00 00 00       	mov    $0x21,%edx
f0103668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010366d:	ee                   	out    %al,(%dx)
f010366e:	b2 a1                	mov    $0xa1,%dl
f0103670:	ee                   	out    %al,(%dx)
f0103671:	b2 20                	mov    $0x20,%dl
f0103673:	b8 11 00 00 00       	mov    $0x11,%eax
f0103678:	ee                   	out    %al,(%dx)
f0103679:	b2 21                	mov    $0x21,%dl
f010367b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103680:	ee                   	out    %al,(%dx)
f0103681:	b8 04 00 00 00       	mov    $0x4,%eax
f0103686:	ee                   	out    %al,(%dx)
f0103687:	b8 03 00 00 00       	mov    $0x3,%eax
f010368c:	ee                   	out    %al,(%dx)
f010368d:	b2 a0                	mov    $0xa0,%dl
f010368f:	b8 11 00 00 00       	mov    $0x11,%eax
f0103694:	ee                   	out    %al,(%dx)
f0103695:	b2 a1                	mov    $0xa1,%dl
f0103697:	b8 28 00 00 00       	mov    $0x28,%eax
f010369c:	ee                   	out    %al,(%dx)
f010369d:	b8 02 00 00 00       	mov    $0x2,%eax
f01036a2:	ee                   	out    %al,(%dx)
f01036a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01036a8:	ee                   	out    %al,(%dx)
f01036a9:	b2 20                	mov    $0x20,%dl
f01036ab:	b8 68 00 00 00       	mov    $0x68,%eax
f01036b0:	ee                   	out    %al,(%dx)
f01036b1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036b6:	ee                   	out    %al,(%dx)
f01036b7:	b2 a0                	mov    $0xa0,%dl
f01036b9:	b8 68 00 00 00       	mov    $0x68,%eax
f01036be:	ee                   	out    %al,(%dx)
f01036bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036c4:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036c5:	0f b7 05 e8 13 12 f0 	movzwl 0xf01213e8,%eax
f01036cc:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036d0:	74 13                	je     f01036e5 <pic_init+0x89>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036d2:	55                   	push   %ebp
f01036d3:	89 e5                	mov    %esp,%ebp
f01036d5:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036d8:	0f b7 c0             	movzwl %ax,%eax
f01036db:	50                   	push   %eax
f01036dc:	e8 06 ff ff ff       	call   f01035e7 <irq_setmask_8259A>
f01036e1:	83 c4 10             	add    $0x10,%esp
}
f01036e4:	c9                   	leave  
f01036e5:	f3 c3                	repz ret 

f01036e7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036e7:	55                   	push   %ebp
f01036e8:	89 e5                	mov    %esp,%ebp
f01036ea:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036ed:	ff 75 08             	pushl  0x8(%ebp)
f01036f0:	e8 85 d0 ff ff       	call   f010077a <cputchar>
f01036f5:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01036f8:	c9                   	leave  
f01036f9:	c3                   	ret    

f01036fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036fa:	55                   	push   %ebp
f01036fb:	89 e5                	mov    %esp,%ebp
f01036fd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103707:	ff 75 0c             	pushl  0xc(%ebp)
f010370a:	ff 75 08             	pushl  0x8(%ebp)
f010370d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103710:	50                   	push   %eax
f0103711:	68 e7 36 10 f0       	push   $0xf01036e7
f0103716:	e8 40 1a 00 00       	call   f010515b <vprintfmt>
	return cnt;
}
f010371b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010371e:	c9                   	leave  
f010371f:	c3                   	ret    

f0103720 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
f0103723:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103726:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103729:	50                   	push   %eax
f010372a:	ff 75 08             	pushl  0x8(%ebp)
f010372d:	e8 c8 ff ff ff       	call   f01036fa <vcprintf>
	va_end(ap);

	return cnt;
}
f0103732:	c9                   	leave  
f0103733:	c3                   	ret    

f0103734 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103734:	55                   	push   %ebp
f0103735:	89 e5                	mov    %esp,%ebp
f0103737:	57                   	push   %edi
f0103738:	56                   	push   %esi
f0103739:	53                   	push   %ebx
f010373a:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
        int cid = thiscpu->cpu_id;
f010373d:	e8 c9 26 00 00       	call   f0105e0b <cpunum>
f0103742:	6b c0 74             	imul   $0x74,%eax,%eax
f0103745:	0f b6 98 40 b0 20 f0 	movzbl -0xfdf4fc0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f010374c:	e8 ba 26 00 00       	call   f0105e0b <cpunum>
f0103751:	6b c0 74             	imul   $0x74,%eax,%eax
f0103754:	89 da                	mov    %ebx,%edx
f0103756:	f7 da                	neg    %edx
f0103758:	c1 e2 10             	shl    $0x10,%edx
f010375b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103761:	89 90 50 b0 20 f0    	mov    %edx,-0xfdf4fb0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103767:	e8 9f 26 00 00       	call   f0105e0b <cpunum>
f010376c:	6b c0 74             	imul   $0x74,%eax,%eax
f010376f:	66 c7 80 54 b0 20 f0 	movw   $0x10,-0xfdf4fac(%eax)
f0103776:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103778:	83 c3 05             	add    $0x5,%ebx
f010377b:	e8 8b 26 00 00       	call   f0105e0b <cpunum>
f0103780:	89 c7                	mov    %eax,%edi
f0103782:	e8 84 26 00 00       	call   f0105e0b <cpunum>
f0103787:	89 c6                	mov    %eax,%esi
f0103789:	e8 7d 26 00 00       	call   f0105e0b <cpunum>
f010378e:	66 c7 04 dd 80 13 12 	movw   $0x67,-0xfedec80(,%ebx,8)
f0103795:	f0 67 00 
f0103798:	6b ff 74             	imul   $0x74,%edi,%edi
f010379b:	81 c7 4c b0 20 f0    	add    $0xf020b04c,%edi
f01037a1:	66 89 3c dd 82 13 12 	mov    %di,-0xfedec7e(,%ebx,8)
f01037a8:	f0 
f01037a9:	6b d6 74             	imul   $0x74,%esi,%edx
f01037ac:	81 c2 4c b0 20 f0    	add    $0xf020b04c,%edx
f01037b2:	c1 ea 10             	shr    $0x10,%edx
f01037b5:	88 14 dd 84 13 12 f0 	mov    %dl,-0xfedec7c(,%ebx,8)
f01037bc:	c6 04 dd 86 13 12 f0 	movb   $0x40,-0xfedec7a(,%ebx,8)
f01037c3:	40 
f01037c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c7:	05 4c b0 20 f0       	add    $0xf020b04c,%eax
f01037cc:	c1 e8 18             	shr    $0x18,%eax
f01037cf:	88 04 dd 87 13 12 f0 	mov    %al,-0xfedec79(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f01037d6:	c6 04 dd 85 13 12 f0 	movb   $0x89,-0xfedec7b(,%ebx,8)
f01037dd:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f01037de:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037e1:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037e4:	b8 ea 13 12 f0       	mov    $0xf01213ea,%eax
f01037e9:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01037ec:	83 c4 0c             	add    $0xc,%esp
f01037ef:	5b                   	pop    %ebx
f01037f0:	5e                   	pop    %esi
f01037f1:	5f                   	pop    %edi
f01037f2:	5d                   	pop    %ebp
f01037f3:	c3                   	ret    

f01037f4 <trap_init>:
}


void
trap_init(void)
{
f01037f4:	55                   	push   %ebp
f01037f5:	89 e5                	mov    %esp,%ebp
f01037f7:	83 ec 08             	sub    $0x8,%esp
        extern void irq11();
        extern void irq12();
        extern void irq13();
        extern void irq14();
        extern void irq15();
        SETGATE(idt[0], 0, GD_KT, i0, 0);
f01037fa:	b8 8a 43 10 f0       	mov    $0xf010438a,%eax
f01037ff:	66 a3 80 a2 20 f0    	mov    %ax,0xf020a280
f0103805:	66 c7 05 82 a2 20 f0 	movw   $0x8,0xf020a282
f010380c:	08 00 
f010380e:	c6 05 84 a2 20 f0 00 	movb   $0x0,0xf020a284
f0103815:	c6 05 85 a2 20 f0 8e 	movb   $0x8e,0xf020a285
f010381c:	c1 e8 10             	shr    $0x10,%eax
f010381f:	66 a3 86 a2 20 f0    	mov    %ax,0xf020a286
        SETGATE(idt[1], 0, GD_KT, i1, 0);
f0103825:	b8 94 43 10 f0       	mov    $0xf0104394,%eax
f010382a:	66 a3 88 a2 20 f0    	mov    %ax,0xf020a288
f0103830:	66 c7 05 8a a2 20 f0 	movw   $0x8,0xf020a28a
f0103837:	08 00 
f0103839:	c6 05 8c a2 20 f0 00 	movb   $0x0,0xf020a28c
f0103840:	c6 05 8d a2 20 f0 8e 	movb   $0x8e,0xf020a28d
f0103847:	c1 e8 10             	shr    $0x10,%eax
f010384a:	66 a3 8e a2 20 f0    	mov    %ax,0xf020a28e
        SETGATE(idt[2], 0, GD_KT, i2, 0);
f0103850:	b8 9e 43 10 f0       	mov    $0xf010439e,%eax
f0103855:	66 a3 90 a2 20 f0    	mov    %ax,0xf020a290
f010385b:	66 c7 05 92 a2 20 f0 	movw   $0x8,0xf020a292
f0103862:	08 00 
f0103864:	c6 05 94 a2 20 f0 00 	movb   $0x0,0xf020a294
f010386b:	c6 05 95 a2 20 f0 8e 	movb   $0x8e,0xf020a295
f0103872:	c1 e8 10             	shr    $0x10,%eax
f0103875:	66 a3 96 a2 20 f0    	mov    %ax,0xf020a296
        SETGATE(idt[3], 0, GD_KT, i3, 3);
f010387b:	b8 a8 43 10 f0       	mov    $0xf01043a8,%eax
f0103880:	66 a3 98 a2 20 f0    	mov    %ax,0xf020a298
f0103886:	66 c7 05 9a a2 20 f0 	movw   $0x8,0xf020a29a
f010388d:	08 00 
f010388f:	c6 05 9c a2 20 f0 00 	movb   $0x0,0xf020a29c
f0103896:	c6 05 9d a2 20 f0 ee 	movb   $0xee,0xf020a29d
f010389d:	c1 e8 10             	shr    $0x10,%eax
f01038a0:	66 a3 9e a2 20 f0    	mov    %ax,0xf020a29e
        SETGATE(idt[4], 0, GD_KT, i4, 0);
f01038a6:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f01038ab:	66 a3 a0 a2 20 f0    	mov    %ax,0xf020a2a0
f01038b1:	66 c7 05 a2 a2 20 f0 	movw   $0x8,0xf020a2a2
f01038b8:	08 00 
f01038ba:	c6 05 a4 a2 20 f0 00 	movb   $0x0,0xf020a2a4
f01038c1:	c6 05 a5 a2 20 f0 8e 	movb   $0x8e,0xf020a2a5
f01038c8:	c1 e8 10             	shr    $0x10,%eax
f01038cb:	66 a3 a6 a2 20 f0    	mov    %ax,0xf020a2a6
        SETGATE(idt[5], 0, GD_KT, i5, 0);
f01038d1:	b8 bc 43 10 f0       	mov    $0xf01043bc,%eax
f01038d6:	66 a3 a8 a2 20 f0    	mov    %ax,0xf020a2a8
f01038dc:	66 c7 05 aa a2 20 f0 	movw   $0x8,0xf020a2aa
f01038e3:	08 00 
f01038e5:	c6 05 ac a2 20 f0 00 	movb   $0x0,0xf020a2ac
f01038ec:	c6 05 ad a2 20 f0 8e 	movb   $0x8e,0xf020a2ad
f01038f3:	c1 e8 10             	shr    $0x10,%eax
f01038f6:	66 a3 ae a2 20 f0    	mov    %ax,0xf020a2ae
        SETGATE(idt[6], 0, GD_KT, i6, 0);
f01038fc:	b8 c6 43 10 f0       	mov    $0xf01043c6,%eax
f0103901:	66 a3 b0 a2 20 f0    	mov    %ax,0xf020a2b0
f0103907:	66 c7 05 b2 a2 20 f0 	movw   $0x8,0xf020a2b2
f010390e:	08 00 
f0103910:	c6 05 b4 a2 20 f0 00 	movb   $0x0,0xf020a2b4
f0103917:	c6 05 b5 a2 20 f0 8e 	movb   $0x8e,0xf020a2b5
f010391e:	c1 e8 10             	shr    $0x10,%eax
f0103921:	66 a3 b6 a2 20 f0    	mov    %ax,0xf020a2b6
        SETGATE(idt[7], 0, GD_KT, i7, 0);
f0103927:	b8 d0 43 10 f0       	mov    $0xf01043d0,%eax
f010392c:	66 a3 b8 a2 20 f0    	mov    %ax,0xf020a2b8
f0103932:	66 c7 05 ba a2 20 f0 	movw   $0x8,0xf020a2ba
f0103939:	08 00 
f010393b:	c6 05 bc a2 20 f0 00 	movb   $0x0,0xf020a2bc
f0103942:	c6 05 bd a2 20 f0 8e 	movb   $0x8e,0xf020a2bd
f0103949:	c1 e8 10             	shr    $0x10,%eax
f010394c:	66 a3 be a2 20 f0    	mov    %ax,0xf020a2be
        SETGATE(idt[8], 0, GD_KT, i8, 0);
f0103952:	b8 da 43 10 f0       	mov    $0xf01043da,%eax
f0103957:	66 a3 c0 a2 20 f0    	mov    %ax,0xf020a2c0
f010395d:	66 c7 05 c2 a2 20 f0 	movw   $0x8,0xf020a2c2
f0103964:	08 00 
f0103966:	c6 05 c4 a2 20 f0 00 	movb   $0x0,0xf020a2c4
f010396d:	c6 05 c5 a2 20 f0 8e 	movb   $0x8e,0xf020a2c5
f0103974:	c1 e8 10             	shr    $0x10,%eax
f0103977:	66 a3 c6 a2 20 f0    	mov    %ax,0xf020a2c6
        SETGATE(idt[9], 0, GD_KT, i9, 0);
f010397d:	b8 e2 43 10 f0       	mov    $0xf01043e2,%eax
f0103982:	66 a3 c8 a2 20 f0    	mov    %ax,0xf020a2c8
f0103988:	66 c7 05 ca a2 20 f0 	movw   $0x8,0xf020a2ca
f010398f:	08 00 
f0103991:	c6 05 cc a2 20 f0 00 	movb   $0x0,0xf020a2cc
f0103998:	c6 05 cd a2 20 f0 8e 	movb   $0x8e,0xf020a2cd
f010399f:	c1 e8 10             	shr    $0x10,%eax
f01039a2:	66 a3 ce a2 20 f0    	mov    %ax,0xf020a2ce
        SETGATE(idt[10], 0, GD_KT, i10, 0);
f01039a8:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f01039ad:	66 a3 d0 a2 20 f0    	mov    %ax,0xf020a2d0
f01039b3:	66 c7 05 d2 a2 20 f0 	movw   $0x8,0xf020a2d2
f01039ba:	08 00 
f01039bc:	c6 05 d4 a2 20 f0 00 	movb   $0x0,0xf020a2d4
f01039c3:	c6 05 d5 a2 20 f0 8e 	movb   $0x8e,0xf020a2d5
f01039ca:	c1 e8 10             	shr    $0x10,%eax
f01039cd:	66 a3 d6 a2 20 f0    	mov    %ax,0xf020a2d6
        SETGATE(idt[11], 0, GD_KT, i11, 0);
f01039d3:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f01039d8:	66 a3 d8 a2 20 f0    	mov    %ax,0xf020a2d8
f01039de:	66 c7 05 da a2 20 f0 	movw   $0x8,0xf020a2da
f01039e5:	08 00 
f01039e7:	c6 05 dc a2 20 f0 00 	movb   $0x0,0xf020a2dc
f01039ee:	c6 05 dd a2 20 f0 8e 	movb   $0x8e,0xf020a2dd
f01039f5:	c1 e8 10             	shr    $0x10,%eax
f01039f8:	66 a3 de a2 20 f0    	mov    %ax,0xf020a2de
        SETGATE(idt[12], 0, GD_KT, i12, 0);
f01039fe:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103a03:	66 a3 e0 a2 20 f0    	mov    %ax,0xf020a2e0
f0103a09:	66 c7 05 e2 a2 20 f0 	movw   $0x8,0xf020a2e2
f0103a10:	08 00 
f0103a12:	c6 05 e4 a2 20 f0 00 	movb   $0x0,0xf020a2e4
f0103a19:	c6 05 e5 a2 20 f0 8e 	movb   $0x8e,0xf020a2e5
f0103a20:	c1 e8 10             	shr    $0x10,%eax
f0103a23:	66 a3 e6 a2 20 f0    	mov    %ax,0xf020a2e6
        SETGATE(idt[13], 0, GD_KT, i13, 0);
f0103a29:	b8 04 44 10 f0       	mov    $0xf0104404,%eax
f0103a2e:	66 a3 e8 a2 20 f0    	mov    %ax,0xf020a2e8
f0103a34:	66 c7 05 ea a2 20 f0 	movw   $0x8,0xf020a2ea
f0103a3b:	08 00 
f0103a3d:	c6 05 ec a2 20 f0 00 	movb   $0x0,0xf020a2ec
f0103a44:	c6 05 ed a2 20 f0 8e 	movb   $0x8e,0xf020a2ed
f0103a4b:	c1 e8 10             	shr    $0x10,%eax
f0103a4e:	66 a3 ee a2 20 f0    	mov    %ax,0xf020a2ee
        SETGATE(idt[14], 0, GD_KT, i14, 0);
f0103a54:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103a59:	66 a3 f0 a2 20 f0    	mov    %ax,0xf020a2f0
f0103a5f:	66 c7 05 f2 a2 20 f0 	movw   $0x8,0xf020a2f2
f0103a66:	08 00 
f0103a68:	c6 05 f4 a2 20 f0 00 	movb   $0x0,0xf020a2f4
f0103a6f:	c6 05 f5 a2 20 f0 8e 	movb   $0x8e,0xf020a2f5
f0103a76:	c1 e8 10             	shr    $0x10,%eax
f0103a79:	66 a3 f6 a2 20 f0    	mov    %ax,0xf020a2f6
        SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103a7f:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103a84:	66 a3 00 a3 20 f0    	mov    %ax,0xf020a300
f0103a8a:	66 c7 05 02 a3 20 f0 	movw   $0x8,0xf020a302
f0103a91:	08 00 
f0103a93:	c6 05 04 a3 20 f0 00 	movb   $0x0,0xf020a304
f0103a9a:	c6 05 05 a3 20 f0 8e 	movb   $0x8e,0xf020a305
f0103aa1:	c1 e8 10             	shr    $0x10,%eax
f0103aa4:	66 a3 06 a3 20 f0    	mov    %ax,0xf020a306
        SETGATE(idt[17], 0, GD_KT, i17, 0);
f0103aaa:	b8 20 44 10 f0       	mov    $0xf0104420,%eax
f0103aaf:	66 a3 08 a3 20 f0    	mov    %ax,0xf020a308
f0103ab5:	66 c7 05 0a a3 20 f0 	movw   $0x8,0xf020a30a
f0103abc:	08 00 
f0103abe:	c6 05 0c a3 20 f0 00 	movb   $0x0,0xf020a30c
f0103ac5:	c6 05 0d a3 20 f0 8e 	movb   $0x8e,0xf020a30d
f0103acc:	c1 e8 10             	shr    $0x10,%eax
f0103acf:	66 a3 0e a3 20 f0    	mov    %ax,0xf020a30e
        SETGATE(idt[18], 0, GD_KT, i18, 0);
f0103ad5:	b8 24 44 10 f0       	mov    $0xf0104424,%eax
f0103ada:	66 a3 10 a3 20 f0    	mov    %ax,0xf020a310
f0103ae0:	66 c7 05 12 a3 20 f0 	movw   $0x8,0xf020a312
f0103ae7:	08 00 
f0103ae9:	c6 05 14 a3 20 f0 00 	movb   $0x0,0xf020a314
f0103af0:	c6 05 15 a3 20 f0 8e 	movb   $0x8e,0xf020a315
f0103af7:	c1 e8 10             	shr    $0x10,%eax
f0103afa:	66 a3 16 a3 20 f0    	mov    %ax,0xf020a316
        SETGATE(idt[19], 0, GD_KT, i19, 0);
f0103b00:	b8 2a 44 10 f0       	mov    $0xf010442a,%eax
f0103b05:	66 a3 18 a3 20 f0    	mov    %ax,0xf020a318
f0103b0b:	66 c7 05 1a a3 20 f0 	movw   $0x8,0xf020a31a
f0103b12:	08 00 
f0103b14:	c6 05 1c a3 20 f0 00 	movb   $0x0,0xf020a31c
f0103b1b:	c6 05 1d a3 20 f0 8e 	movb   $0x8e,0xf020a31d
f0103b22:	c1 e8 10             	shr    $0x10,%eax
f0103b25:	66 a3 1e a3 20 f0    	mov    %ax,0xf020a31e
       
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq0, 0);
f0103b2b:	b8 36 44 10 f0       	mov    $0xf0104436,%eax
f0103b30:	66 a3 80 a3 20 f0    	mov    %ax,0xf020a380
f0103b36:	66 c7 05 82 a3 20 f0 	movw   $0x8,0xf020a382
f0103b3d:	08 00 
f0103b3f:	c6 05 84 a3 20 f0 00 	movb   $0x0,0xf020a384
f0103b46:	c6 05 85 a3 20 f0 8e 	movb   $0x8e,0xf020a385
f0103b4d:	c1 e8 10             	shr    $0x10,%eax
f0103b50:	66 a3 86 a3 20 f0    	mov    %ax,0xf020a386
        SETGATE(idt[33], 0, GD_KT, irq1, 0);
f0103b56:	b8 3c 44 10 f0       	mov    $0xf010443c,%eax
f0103b5b:	66 a3 88 a3 20 f0    	mov    %ax,0xf020a388
f0103b61:	66 c7 05 8a a3 20 f0 	movw   $0x8,0xf020a38a
f0103b68:	08 00 
f0103b6a:	c6 05 8c a3 20 f0 00 	movb   $0x0,0xf020a38c
f0103b71:	c6 05 8d a3 20 f0 8e 	movb   $0x8e,0xf020a38d
f0103b78:	c1 e8 10             	shr    $0x10,%eax
f0103b7b:	66 a3 8e a3 20 f0    	mov    %ax,0xf020a38e
        SETGATE(idt[34], 0, GD_KT, irq2, 0);
f0103b81:	b8 42 44 10 f0       	mov    $0xf0104442,%eax
f0103b86:	66 a3 90 a3 20 f0    	mov    %ax,0xf020a390
f0103b8c:	66 c7 05 92 a3 20 f0 	movw   $0x8,0xf020a392
f0103b93:	08 00 
f0103b95:	c6 05 94 a3 20 f0 00 	movb   $0x0,0xf020a394
f0103b9c:	c6 05 95 a3 20 f0 8e 	movb   $0x8e,0xf020a395
f0103ba3:	c1 e8 10             	shr    $0x10,%eax
f0103ba6:	66 a3 96 a3 20 f0    	mov    %ax,0xf020a396
        SETGATE(idt[35], 0, GD_KT, irq3, 0);
f0103bac:	b8 48 44 10 f0       	mov    $0xf0104448,%eax
f0103bb1:	66 a3 98 a3 20 f0    	mov    %ax,0xf020a398
f0103bb7:	66 c7 05 9a a3 20 f0 	movw   $0x8,0xf020a39a
f0103bbe:	08 00 
f0103bc0:	c6 05 9c a3 20 f0 00 	movb   $0x0,0xf020a39c
f0103bc7:	c6 05 9d a3 20 f0 8e 	movb   $0x8e,0xf020a39d
f0103bce:	c1 e8 10             	shr    $0x10,%eax
f0103bd1:	66 a3 9e a3 20 f0    	mov    %ax,0xf020a39e
        SETGATE(idt[36], 0, GD_KT, irq4, 0);
f0103bd7:	b8 4e 44 10 f0       	mov    $0xf010444e,%eax
f0103bdc:	66 a3 a0 a3 20 f0    	mov    %ax,0xf020a3a0
f0103be2:	66 c7 05 a2 a3 20 f0 	movw   $0x8,0xf020a3a2
f0103be9:	08 00 
f0103beb:	c6 05 a4 a3 20 f0 00 	movb   $0x0,0xf020a3a4
f0103bf2:	c6 05 a5 a3 20 f0 8e 	movb   $0x8e,0xf020a3a5
f0103bf9:	c1 e8 10             	shr    $0x10,%eax
f0103bfc:	66 a3 a6 a3 20 f0    	mov    %ax,0xf020a3a6
        SETGATE(idt[37], 0, GD_KT, irq5, 0);
f0103c02:	b8 54 44 10 f0       	mov    $0xf0104454,%eax
f0103c07:	66 a3 a8 a3 20 f0    	mov    %ax,0xf020a3a8
f0103c0d:	66 c7 05 aa a3 20 f0 	movw   $0x8,0xf020a3aa
f0103c14:	08 00 
f0103c16:	c6 05 ac a3 20 f0 00 	movb   $0x0,0xf020a3ac
f0103c1d:	c6 05 ad a3 20 f0 8e 	movb   $0x8e,0xf020a3ad
f0103c24:	c1 e8 10             	shr    $0x10,%eax
f0103c27:	66 a3 ae a3 20 f0    	mov    %ax,0xf020a3ae
        SETGATE(idt[38], 0, GD_KT, irq6, 0);
f0103c2d:	b8 5a 44 10 f0       	mov    $0xf010445a,%eax
f0103c32:	66 a3 b0 a3 20 f0    	mov    %ax,0xf020a3b0
f0103c38:	66 c7 05 b2 a3 20 f0 	movw   $0x8,0xf020a3b2
f0103c3f:	08 00 
f0103c41:	c6 05 b4 a3 20 f0 00 	movb   $0x0,0xf020a3b4
f0103c48:	c6 05 b5 a3 20 f0 8e 	movb   $0x8e,0xf020a3b5
f0103c4f:	c1 e8 10             	shr    $0x10,%eax
f0103c52:	66 a3 b6 a3 20 f0    	mov    %ax,0xf020a3b6
        SETGATE(idt[39], 0, GD_KT, irq7, 0);
f0103c58:	b8 60 44 10 f0       	mov    $0xf0104460,%eax
f0103c5d:	66 a3 b8 a3 20 f0    	mov    %ax,0xf020a3b8
f0103c63:	66 c7 05 ba a3 20 f0 	movw   $0x8,0xf020a3ba
f0103c6a:	08 00 
f0103c6c:	c6 05 bc a3 20 f0 00 	movb   $0x0,0xf020a3bc
f0103c73:	c6 05 bd a3 20 f0 8e 	movb   $0x8e,0xf020a3bd
f0103c7a:	c1 e8 10             	shr    $0x10,%eax
f0103c7d:	66 a3 be a3 20 f0    	mov    %ax,0xf020a3be
        SETGATE(idt[40], 0, GD_KT, irq8, 0);
f0103c83:	b8 66 44 10 f0       	mov    $0xf0104466,%eax
f0103c88:	66 a3 c0 a3 20 f0    	mov    %ax,0xf020a3c0
f0103c8e:	66 c7 05 c2 a3 20 f0 	movw   $0x8,0xf020a3c2
f0103c95:	08 00 
f0103c97:	c6 05 c4 a3 20 f0 00 	movb   $0x0,0xf020a3c4
f0103c9e:	c6 05 c5 a3 20 f0 8e 	movb   $0x8e,0xf020a3c5
f0103ca5:	c1 e8 10             	shr    $0x10,%eax
f0103ca8:	66 a3 c6 a3 20 f0    	mov    %ax,0xf020a3c6
        SETGATE(idt[41], 0, GD_KT, irq9, 0);
f0103cae:	b8 6c 44 10 f0       	mov    $0xf010446c,%eax
f0103cb3:	66 a3 c8 a3 20 f0    	mov    %ax,0xf020a3c8
f0103cb9:	66 c7 05 ca a3 20 f0 	movw   $0x8,0xf020a3ca
f0103cc0:	08 00 
f0103cc2:	c6 05 cc a3 20 f0 00 	movb   $0x0,0xf020a3cc
f0103cc9:	c6 05 cd a3 20 f0 8e 	movb   $0x8e,0xf020a3cd
f0103cd0:	c1 e8 10             	shr    $0x10,%eax
f0103cd3:	66 a3 ce a3 20 f0    	mov    %ax,0xf020a3ce
        SETGATE(idt[42], 0, GD_KT, irq10, 0);
f0103cd9:	b8 72 44 10 f0       	mov    $0xf0104472,%eax
f0103cde:	66 a3 d0 a3 20 f0    	mov    %ax,0xf020a3d0
f0103ce4:	66 c7 05 d2 a3 20 f0 	movw   $0x8,0xf020a3d2
f0103ceb:	08 00 
f0103ced:	c6 05 d4 a3 20 f0 00 	movb   $0x0,0xf020a3d4
f0103cf4:	c6 05 d5 a3 20 f0 8e 	movb   $0x8e,0xf020a3d5
f0103cfb:	c1 e8 10             	shr    $0x10,%eax
f0103cfe:	66 a3 d6 a3 20 f0    	mov    %ax,0xf020a3d6
        SETGATE(idt[43], 0, GD_KT, irq11, 0);
f0103d04:	b8 78 44 10 f0       	mov    $0xf0104478,%eax
f0103d09:	66 a3 d8 a3 20 f0    	mov    %ax,0xf020a3d8
f0103d0f:	66 c7 05 da a3 20 f0 	movw   $0x8,0xf020a3da
f0103d16:	08 00 
f0103d18:	c6 05 dc a3 20 f0 00 	movb   $0x0,0xf020a3dc
f0103d1f:	c6 05 dd a3 20 f0 8e 	movb   $0x8e,0xf020a3dd
f0103d26:	c1 e8 10             	shr    $0x10,%eax
f0103d29:	66 a3 de a3 20 f0    	mov    %ax,0xf020a3de
        SETGATE(idt[44], 0, GD_KT, irq12, 0);
f0103d2f:	b8 7e 44 10 f0       	mov    $0xf010447e,%eax
f0103d34:	66 a3 e0 a3 20 f0    	mov    %ax,0xf020a3e0
f0103d3a:	66 c7 05 e2 a3 20 f0 	movw   $0x8,0xf020a3e2
f0103d41:	08 00 
f0103d43:	c6 05 e4 a3 20 f0 00 	movb   $0x0,0xf020a3e4
f0103d4a:	c6 05 e5 a3 20 f0 8e 	movb   $0x8e,0xf020a3e5
f0103d51:	c1 e8 10             	shr    $0x10,%eax
f0103d54:	66 a3 e6 a3 20 f0    	mov    %ax,0xf020a3e6
        SETGATE(idt[45], 0, GD_KT, irq13, 0);
f0103d5a:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103d5f:	66 a3 e8 a3 20 f0    	mov    %ax,0xf020a3e8
f0103d65:	66 c7 05 ea a3 20 f0 	movw   $0x8,0xf020a3ea
f0103d6c:	08 00 
f0103d6e:	c6 05 ec a3 20 f0 00 	movb   $0x0,0xf020a3ec
f0103d75:	c6 05 ed a3 20 f0 8e 	movb   $0x8e,0xf020a3ed
f0103d7c:	c1 e8 10             	shr    $0x10,%eax
f0103d7f:	66 a3 ee a3 20 f0    	mov    %ax,0xf020a3ee
        SETGATE(idt[46], 0, GD_KT, irq14, 0);
f0103d85:	b8 8a 44 10 f0       	mov    $0xf010448a,%eax
f0103d8a:	66 a3 f0 a3 20 f0    	mov    %ax,0xf020a3f0
f0103d90:	66 c7 05 f2 a3 20 f0 	movw   $0x8,0xf020a3f2
f0103d97:	08 00 
f0103d99:	c6 05 f4 a3 20 f0 00 	movb   $0x0,0xf020a3f4
f0103da0:	c6 05 f5 a3 20 f0 8e 	movb   $0x8e,0xf020a3f5
f0103da7:	c1 e8 10             	shr    $0x10,%eax
f0103daa:	66 a3 f6 a3 20 f0    	mov    %ax,0xf020a3f6
        SETGATE(idt[47], 0, GD_KT, irq15, 0);
f0103db0:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103db5:	66 a3 f8 a3 20 f0    	mov    %ax,0xf020a3f8
f0103dbb:	66 c7 05 fa a3 20 f0 	movw   $0x8,0xf020a3fa
f0103dc2:	08 00 
f0103dc4:	c6 05 fc a3 20 f0 00 	movb   $0x0,0xf020a3fc
f0103dcb:	c6 05 fd a3 20 f0 8e 	movb   $0x8e,0xf020a3fd
f0103dd2:	c1 e8 10             	shr    $0x10,%eax
f0103dd5:	66 a3 fe a3 20 f0    	mov    %ax,0xf020a3fe
         SETGATE(idt[48], 0, GD_KT, i20, 3);
f0103ddb:	b8 30 44 10 f0       	mov    $0xf0104430,%eax
f0103de0:	66 a3 00 a4 20 f0    	mov    %ax,0xf020a400
f0103de6:	66 c7 05 02 a4 20 f0 	movw   $0x8,0xf020a402
f0103ded:	08 00 
f0103def:	c6 05 04 a4 20 f0 00 	movb   $0x0,0xf020a404
f0103df6:	c6 05 05 a4 20 f0 ee 	movb   $0xee,0xf020a405
f0103dfd:	c1 e8 10             	shr    $0x10,%eax
f0103e00:	66 a3 06 a4 20 f0    	mov    %ax,0xf020a406
	// Per-CPU setup 
	trap_init_percpu();
f0103e06:	e8 29 f9 ff ff       	call   f0103734 <trap_init_percpu>
}
f0103e0b:	c9                   	leave  
f0103e0c:	c3                   	ret    

f0103e0d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e0d:	55                   	push   %ebp
f0103e0e:	89 e5                	mov    %esp,%ebp
f0103e10:	53                   	push   %ebx
f0103e11:	83 ec 0c             	sub    $0xc,%esp
f0103e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e17:	ff 33                	pushl  (%ebx)
f0103e19:	68 7b 77 10 f0       	push   $0xf010777b
f0103e1e:	e8 fd f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e23:	83 c4 08             	add    $0x8,%esp
f0103e26:	ff 73 04             	pushl  0x4(%ebx)
f0103e29:	68 8a 77 10 f0       	push   $0xf010778a
f0103e2e:	e8 ed f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	ff 73 08             	pushl  0x8(%ebx)
f0103e39:	68 99 77 10 f0       	push   $0xf0107799
f0103e3e:	e8 dd f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e43:	83 c4 08             	add    $0x8,%esp
f0103e46:	ff 73 0c             	pushl  0xc(%ebx)
f0103e49:	68 a8 77 10 f0       	push   $0xf01077a8
f0103e4e:	e8 cd f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e53:	83 c4 08             	add    $0x8,%esp
f0103e56:	ff 73 10             	pushl  0x10(%ebx)
f0103e59:	68 b7 77 10 f0       	push   $0xf01077b7
f0103e5e:	e8 bd f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e63:	83 c4 08             	add    $0x8,%esp
f0103e66:	ff 73 14             	pushl  0x14(%ebx)
f0103e69:	68 c6 77 10 f0       	push   $0xf01077c6
f0103e6e:	e8 ad f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e73:	83 c4 08             	add    $0x8,%esp
f0103e76:	ff 73 18             	pushl  0x18(%ebx)
f0103e79:	68 d5 77 10 f0       	push   $0xf01077d5
f0103e7e:	e8 9d f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e83:	83 c4 08             	add    $0x8,%esp
f0103e86:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e89:	68 e4 77 10 f0       	push   $0xf01077e4
f0103e8e:	e8 8d f8 ff ff       	call   f0103720 <cprintf>
f0103e93:	83 c4 10             	add    $0x10,%esp
}
f0103e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e99:	c9                   	leave  
f0103e9a:	c3                   	ret    

f0103e9b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e9b:	55                   	push   %ebp
f0103e9c:	89 e5                	mov    %esp,%ebp
f0103e9e:	56                   	push   %esi
f0103e9f:	53                   	push   %ebx
f0103ea0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103ea3:	e8 63 1f 00 00       	call   f0105e0b <cpunum>
f0103ea8:	83 ec 04             	sub    $0x4,%esp
f0103eab:	50                   	push   %eax
f0103eac:	53                   	push   %ebx
f0103ead:	68 48 78 10 f0       	push   $0xf0107848
f0103eb2:	e8 69 f8 ff ff       	call   f0103720 <cprintf>
	print_regs(&tf->tf_regs);
f0103eb7:	89 1c 24             	mov    %ebx,(%esp)
f0103eba:	e8 4e ff ff ff       	call   f0103e0d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ebf:	83 c4 08             	add    $0x8,%esp
f0103ec2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ec6:	50                   	push   %eax
f0103ec7:	68 66 78 10 f0       	push   $0xf0107866
f0103ecc:	e8 4f f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ed1:	83 c4 08             	add    $0x8,%esp
f0103ed4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ed8:	50                   	push   %eax
f0103ed9:	68 79 78 10 f0       	push   $0xf0107879
f0103ede:	e8 3d f8 ff ff       	call   f0103720 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ee3:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ee6:	83 c4 10             	add    $0x10,%esp
f0103ee9:	83 f8 13             	cmp    $0x13,%eax
f0103eec:	77 09                	ja     f0103ef7 <print_trapframe+0x5c>
		return excnames[trapno];
f0103eee:	8b 14 85 40 7b 10 f0 	mov    -0xfef84c0(,%eax,4),%edx
f0103ef5:	eb 1f                	jmp    f0103f16 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103ef7:	83 f8 30             	cmp    $0x30,%eax
f0103efa:	74 15                	je     f0103f11 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103efc:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103eff:	83 fa 10             	cmp    $0x10,%edx
f0103f02:	b9 12 78 10 f0       	mov    $0xf0107812,%ecx
f0103f07:	ba ff 77 10 f0       	mov    $0xf01077ff,%edx
f0103f0c:	0f 43 d1             	cmovae %ecx,%edx
f0103f0f:	eb 05                	jmp    f0103f16 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f11:	ba f3 77 10 f0       	mov    $0xf01077f3,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f16:	83 ec 04             	sub    $0x4,%esp
f0103f19:	52                   	push   %edx
f0103f1a:	50                   	push   %eax
f0103f1b:	68 8c 78 10 f0       	push   $0xf010788c
f0103f20:	e8 fb f7 ff ff       	call   f0103720 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f25:	83 c4 10             	add    $0x10,%esp
f0103f28:	3b 1d 80 aa 20 f0    	cmp    0xf020aa80,%ebx
f0103f2e:	75 1a                	jne    f0103f4a <print_trapframe+0xaf>
f0103f30:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f34:	75 14                	jne    f0103f4a <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f36:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f39:	83 ec 08             	sub    $0x8,%esp
f0103f3c:	50                   	push   %eax
f0103f3d:	68 9e 78 10 f0       	push   $0xf010789e
f0103f42:	e8 d9 f7 ff ff       	call   f0103720 <cprintf>
f0103f47:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f4a:	83 ec 08             	sub    $0x8,%esp
f0103f4d:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f50:	68 ad 78 10 f0       	push   $0xf01078ad
f0103f55:	e8 c6 f7 ff ff       	call   f0103720 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f5a:	83 c4 10             	add    $0x10,%esp
f0103f5d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f61:	75 49                	jne    f0103fac <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f63:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f66:	89 c2                	mov    %eax,%edx
f0103f68:	83 e2 01             	and    $0x1,%edx
f0103f6b:	ba 2c 78 10 f0       	mov    $0xf010782c,%edx
f0103f70:	b9 21 78 10 f0       	mov    $0xf0107821,%ecx
f0103f75:	0f 44 ca             	cmove  %edx,%ecx
f0103f78:	89 c2                	mov    %eax,%edx
f0103f7a:	83 e2 02             	and    $0x2,%edx
f0103f7d:	ba 3e 78 10 f0       	mov    $0xf010783e,%edx
f0103f82:	be 38 78 10 f0       	mov    $0xf0107838,%esi
f0103f87:	0f 45 d6             	cmovne %esi,%edx
f0103f8a:	83 e0 04             	and    $0x4,%eax
f0103f8d:	be 8b 79 10 f0       	mov    $0xf010798b,%esi
f0103f92:	b8 43 78 10 f0       	mov    $0xf0107843,%eax
f0103f97:	0f 44 c6             	cmove  %esi,%eax
f0103f9a:	51                   	push   %ecx
f0103f9b:	52                   	push   %edx
f0103f9c:	50                   	push   %eax
f0103f9d:	68 bb 78 10 f0       	push   $0xf01078bb
f0103fa2:	e8 79 f7 ff ff       	call   f0103720 <cprintf>
f0103fa7:	83 c4 10             	add    $0x10,%esp
f0103faa:	eb 10                	jmp    f0103fbc <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fac:	83 ec 0c             	sub    $0xc,%esp
f0103faf:	68 b3 6d 10 f0       	push   $0xf0106db3
f0103fb4:	e8 67 f7 ff ff       	call   f0103720 <cprintf>
f0103fb9:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fbc:	83 ec 08             	sub    $0x8,%esp
f0103fbf:	ff 73 30             	pushl  0x30(%ebx)
f0103fc2:	68 ca 78 10 f0       	push   $0xf01078ca
f0103fc7:	e8 54 f7 ff ff       	call   f0103720 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fcc:	83 c4 08             	add    $0x8,%esp
f0103fcf:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fd3:	50                   	push   %eax
f0103fd4:	68 d9 78 10 f0       	push   $0xf01078d9
f0103fd9:	e8 42 f7 ff ff       	call   f0103720 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fde:	83 c4 08             	add    $0x8,%esp
f0103fe1:	ff 73 38             	pushl  0x38(%ebx)
f0103fe4:	68 ec 78 10 f0       	push   $0xf01078ec
f0103fe9:	e8 32 f7 ff ff       	call   f0103720 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fee:	83 c4 10             	add    $0x10,%esp
f0103ff1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ff5:	74 25                	je     f010401c <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ff7:	83 ec 08             	sub    $0x8,%esp
f0103ffa:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ffd:	68 fb 78 10 f0       	push   $0xf01078fb
f0104002:	e8 19 f7 ff ff       	call   f0103720 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104007:	83 c4 08             	add    $0x8,%esp
f010400a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010400e:	50                   	push   %eax
f010400f:	68 0a 79 10 f0       	push   $0xf010790a
f0104014:	e8 07 f7 ff ff       	call   f0103720 <cprintf>
f0104019:	83 c4 10             	add    $0x10,%esp
	}
}
f010401c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010401f:	5b                   	pop    %ebx
f0104020:	5e                   	pop    %esi
f0104021:	5d                   	pop    %ebp
f0104022:	c3                   	ret    

f0104023 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104023:	55                   	push   %ebp
f0104024:	89 e5                	mov    %esp,%ebp
f0104026:	57                   	push   %edi
f0104027:	56                   	push   %esi
f0104028:	53                   	push   %ebx
f0104029:	83 ec 0c             	sub    $0xc,%esp
f010402c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010402f:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if ((tf->tf_cs & 3) == 0)
f0104032:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104036:	75 17                	jne    f010404f <page_fault_handler+0x2c>
                panic("Kernel page fault!");
f0104038:	83 ec 04             	sub    $0x4,%esp
f010403b:	68 1d 79 10 f0       	push   $0xf010791d
f0104040:	68 7f 01 00 00       	push   $0x17f
f0104045:	68 30 79 10 f0       	push   $0xf0107930
f010404a:	e8 f1 bf ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        if(curenv->env_pgfault_upcall) {
f010404f:	e8 b7 1d 00 00       	call   f0105e0b <cpunum>
f0104054:	6b c0 74             	imul   $0x74,%eax,%eax
f0104057:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010405d:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104061:	0f 84 8b 00 00 00    	je     f01040f2 <page_fault_handler+0xcf>
                struct UTrapframe *utf;
                if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&  tf->tf_esp <= UXSTACKTOP-1)  
f0104067:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010406a:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                        utf = (struct UTrapframe *) ((void *)tf->tf_esp - sizeof(struct UTrapframe) -4);
f0104070:	83 e8 38             	sub    $0x38,%eax
f0104073:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104079:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010407e:	0f 46 d0             	cmovbe %eax,%edx
f0104081:	89 d7                	mov    %edx,%edi
                else
                        utf = (struct UTrapframe *) ((void *)UXSTACKTOP - sizeof(struct UTrapframe));
                user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f0104083:	e8 83 1d 00 00       	call   f0105e0b <cpunum>
f0104088:	6a 03                	push   $0x3
f010408a:	6a 34                	push   $0x34
f010408c:	57                   	push   %edi
f010408d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104090:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104096:	e8 a0 ed ff ff       	call   f0102e3b <user_mem_assert>
                utf->utf_fault_va = fault_va;
f010409b:	89 fa                	mov    %edi,%edx
f010409d:	89 37                	mov    %esi,(%edi)
                utf->utf_err = tf->tf_err;
f010409f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040a2:	89 47 04             	mov    %eax,0x4(%edi)
                utf->utf_regs = tf->tf_regs;
f01040a5:	8d 7f 08             	lea    0x8(%edi),%edi
f01040a8:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040ad:	89 de                	mov    %ebx,%esi
f01040af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
                utf->utf_eip = tf->tf_eip;
f01040b1:	8b 43 30             	mov    0x30(%ebx),%eax
f01040b4:	89 42 28             	mov    %eax,0x28(%edx)
                utf->utf_eflags = tf->tf_eflags;
f01040b7:	8b 43 38             	mov    0x38(%ebx),%eax
f01040ba:	89 d7                	mov    %edx,%edi
f01040bc:	89 42 2c             	mov    %eax,0x2c(%edx)
                utf->utf_esp = tf->tf_esp;
f01040bf:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040c2:	89 42 30             	mov    %eax,0x30(%edx)
                tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f01040c5:	e8 41 1d 00 00       	call   f0105e0b <cpunum>
f01040ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cd:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01040d3:	8b 40 64             	mov    0x64(%eax),%eax
f01040d6:	89 43 30             	mov    %eax,0x30(%ebx)
                tf->tf_esp = (uintptr_t)utf;
f01040d9:	89 7b 3c             	mov    %edi,0x3c(%ebx)
                env_run(curenv);
f01040dc:	e8 2a 1d 00 00       	call   f0105e0b <cpunum>
f01040e1:	83 c4 04             	add    $0x4,%esp
f01040e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e7:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f01040ed:	e8 e6 f3 ff ff       	call   f01034d8 <env_run>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
f01040f2:	83 ec 0c             	sub    $0xc,%esp
f01040f5:	68 d8 7a 10 f0       	push   $0xf0107ad8
f01040fa:	e8 21 f6 ff ff       	call   f0103720 <cprintf>
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ff:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104102:	e8 04 1d 00 00       	call   f0105e0b <cpunum>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104107:	57                   	push   %edi
f0104108:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104109:	6b c0 74             	imul   $0x74,%eax,%eax
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010410c:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104112:	ff 70 48             	pushl  0x48(%eax)
f0104115:	68 fc 7a 10 f0       	push   $0xf0107afc
f010411a:	e8 01 f6 ff ff       	call   f0103720 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010411f:	83 c4 14             	add    $0x14,%esp
f0104122:	53                   	push   %ebx
f0104123:	e8 73 fd ff ff       	call   f0103e9b <print_trapframe>
	env_destroy(curenv);
f0104128:	e8 de 1c 00 00       	call   f0105e0b <cpunum>
f010412d:	83 c4 04             	add    $0x4,%esp
f0104130:	6b c0 74             	imul   $0x74,%eax,%eax
f0104133:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104139:	e8 fb f2 ff ff       	call   f0103439 <env_destroy>
f010413e:	83 c4 10             	add    $0x10,%esp
}
f0104141:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104144:	5b                   	pop    %ebx
f0104145:	5e                   	pop    %esi
f0104146:	5f                   	pop    %edi
f0104147:	5d                   	pop    %ebp
f0104148:	c3                   	ret    

f0104149 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104149:	55                   	push   %ebp
f010414a:	89 e5                	mov    %esp,%ebp
f010414c:	57                   	push   %edi
f010414d:	56                   	push   %esi
f010414e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104151:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104152:	83 3d c0 ae 20 f0 00 	cmpl   $0x0,0xf020aec0
f0104159:	74 01                	je     f010415c <trap+0x13>
		asm volatile("hlt");
f010415b:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010415c:	e8 aa 1c 00 00       	call   f0105e0b <cpunum>
f0104161:	6b d0 74             	imul   $0x74,%eax,%edx
f0104164:	81 c2 40 b0 20 f0    	add    $0xf020b040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010416a:	b8 01 00 00 00       	mov    $0x1,%eax
f010416f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104173:	83 f8 02             	cmp    $0x2,%eax
f0104176:	75 10                	jne    f0104188 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104178:	83 ec 0c             	sub    $0xc,%esp
f010417b:	68 00 14 12 f0       	push   $0xf0121400
f0104180:	e8 f1 1e 00 00       	call   f0106076 <spin_lock>
f0104185:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104188:	9c                   	pushf  
f0104189:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010418a:	f6 c4 02             	test   $0x2,%ah
f010418d:	74 19                	je     f01041a8 <trap+0x5f>
f010418f:	68 3c 79 10 f0       	push   $0xf010793c
f0104194:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0104199:	68 49 01 00 00       	push   $0x149
f010419e:	68 30 79 10 f0       	push   $0xf0107930
f01041a3:	e8 98 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041a8:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041ac:	83 e0 03             	and    $0x3,%eax
f01041af:	66 83 f8 03          	cmp    $0x3,%ax
f01041b3:	0f 85 a0 00 00 00    	jne    f0104259 <trap+0x110>
f01041b9:	83 ec 0c             	sub    $0xc,%esp
f01041bc:	68 00 14 12 f0       	push   $0xf0121400
f01041c1:	e8 b0 1e 00 00       	call   f0106076 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f01041c6:	e8 40 1c 00 00       	call   f0105e0b <cpunum>
f01041cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ce:	83 c4 10             	add    $0x10,%esp
f01041d1:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f01041d8:	75 19                	jne    f01041f3 <trap+0xaa>
f01041da:	68 55 79 10 f0       	push   $0xf0107955
f01041df:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01041e4:	68 51 01 00 00       	push   $0x151
f01041e9:	68 30 79 10 f0       	push   $0xf0107930
f01041ee:	e8 4d be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041f3:	e8 13 1c 00 00       	call   f0105e0b <cpunum>
f01041f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fb:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104201:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104205:	75 2d                	jne    f0104234 <trap+0xeb>
			env_free(curenv);
f0104207:	e8 ff 1b 00 00       	call   f0105e0b <cpunum>
f010420c:	83 ec 0c             	sub    $0xc,%esp
f010420f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104212:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104218:	e8 76 f0 ff ff       	call   f0103293 <env_free>
			curenv = NULL;
f010421d:	e8 e9 1b 00 00       	call   f0105e0b <cpunum>
f0104222:	6b c0 74             	imul   $0x74,%eax,%eax
f0104225:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f010422c:	00 00 00 
			sched_yield();
f010422f:	e8 48 03 00 00       	call   f010457c <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104234:	e8 d2 1b 00 00       	call   f0105e0b <cpunum>
f0104239:	6b c0 74             	imul   $0x74,%eax,%eax
f010423c:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104242:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104247:	89 c7                	mov    %eax,%edi
f0104249:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010424b:	e8 bb 1b 00 00       	call   f0105e0b <cpunum>
f0104250:	6b c0 74             	imul   $0x74,%eax,%eax
f0104253:	8b b0 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104259:	89 35 80 aa 20 f0    	mov    %esi,0xf020aa80
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
        
        if(tf->tf_trapno == T_PGFLT ) {
f010425f:	8b 46 28             	mov    0x28(%esi),%eax
f0104262:	83 f8 0e             	cmp    $0xe,%eax
f0104265:	75 11                	jne    f0104278 <trap+0x12f>
                page_fault_handler(tf);
f0104267:	83 ec 0c             	sub    $0xc,%esp
f010426a:	56                   	push   %esi
f010426b:	e8 b3 fd ff ff       	call   f0104023 <page_fault_handler>
f0104270:	83 c4 10             	add    $0x10,%esp
f0104273:	e9 d2 00 00 00       	jmp    f010434a <trap+0x201>
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
f0104278:	83 f8 03             	cmp    $0x3,%eax
f010427b:	75 11                	jne    f010428e <trap+0x145>
                monitor(tf);
f010427d:	83 ec 0c             	sub    $0xc,%esp
f0104280:	56                   	push   %esi
f0104281:	e8 21 c7 ff ff       	call   f01009a7 <monitor>
f0104286:	83 c4 10             	add    $0x10,%esp
f0104289:	e9 bc 00 00 00       	jmp    f010434a <trap+0x201>
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
f010428e:	83 f8 30             	cmp    $0x30,%eax
f0104291:	75 24                	jne    f01042b7 <trap+0x16e>
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104293:	83 ec 08             	sub    $0x8,%esp
f0104296:	ff 76 04             	pushl  0x4(%esi)
f0104299:	ff 36                	pushl  (%esi)
f010429b:	ff 76 10             	pushl  0x10(%esi)
f010429e:	ff 76 18             	pushl  0x18(%esi)
f01042a1:	ff 76 14             	pushl  0x14(%esi)
f01042a4:	ff 76 1c             	pushl  0x1c(%esi)
f01042a7:	e8 aa 03 00 00       	call   f0104656 <syscall>
f01042ac:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042af:	83 c4 20             	add    $0x20,%esp
f01042b2:	e9 93 00 00 00       	jmp    f010434a <trap+0x201>
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042b7:	83 f8 27             	cmp    $0x27,%eax
f01042ba:	75 1a                	jne    f01042d6 <trap+0x18d>
		cprintf("Spurious interrupt on irq 7\n");
f01042bc:	83 ec 0c             	sub    $0xc,%esp
f01042bf:	68 5c 79 10 f0       	push   $0xf010795c
f01042c4:	e8 57 f4 ff ff       	call   f0103720 <cprintf>
		print_trapframe(tf);
f01042c9:	89 34 24             	mov    %esi,(%esp)
f01042cc:	e8 ca fb ff ff       	call   f0103e9b <print_trapframe>
f01042d1:	83 c4 10             	add    $0x10,%esp
f01042d4:	eb 74                	jmp    f010434a <trap+0x201>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01042d6:	83 f8 20             	cmp    $0x20,%eax
f01042d9:	75 0a                	jne    f01042e5 <trap+0x19c>
                lapic_eoi();
f01042db:	e8 76 1c 00 00       	call   f0105f56 <lapic_eoi>
                sched_yield();
f01042e0:	e8 97 02 00 00       	call   f010457c <sched_yield>
//=======
       

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
         if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01042e5:	83 f8 21             	cmp    $0x21,%eax
f01042e8:	75 0c                	jne    f01042f6 <trap+0x1ad>
                lapic_eoi();
f01042ea:	e8 67 1c 00 00       	call   f0105f56 <lapic_eoi>
		kbd_intr();
f01042ef:	e8 f3 c2 ff ff       	call   f01005e7 <kbd_intr>
f01042f4:	eb 54                	jmp    f010434a <trap+0x201>
		return;
	}
         if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01042f6:	83 f8 24             	cmp    $0x24,%eax
f01042f9:	75 0c                	jne    f0104307 <trap+0x1be>
                lapic_eoi();
f01042fb:	e8 56 1c 00 00       	call   f0105f56 <lapic_eoi>
		serial_intr(); 
f0104300:	e8 c6 c2 ff ff       	call   f01005cb <serial_intr>
f0104305:	eb 43                	jmp    f010434a <trap+0x201>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104307:	83 ec 0c             	sub    $0xc,%esp
f010430a:	56                   	push   %esi
f010430b:	e8 8b fb ff ff       	call   f0103e9b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104310:	83 c4 10             	add    $0x10,%esp
f0104313:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104318:	75 17                	jne    f0104331 <trap+0x1e8>
		panic("unhandled trap in kernel");
f010431a:	83 ec 04             	sub    $0x4,%esp
f010431d:	68 79 79 10 f0       	push   $0xf0107979
f0104322:	68 2f 01 00 00       	push   $0x12f
f0104327:	68 30 79 10 f0       	push   $0xf0107930
f010432c:	e8 0f bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104331:	e8 d5 1a 00 00       	call   f0105e0b <cpunum>
f0104336:	83 ec 0c             	sub    $0xc,%esp
f0104339:	6b c0 74             	imul   $0x74,%eax,%eax
f010433c:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104342:	e8 f2 f0 ff ff       	call   f0103439 <env_destroy>
f0104347:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010434a:	e8 bc 1a 00 00       	call   f0105e0b <cpunum>
f010434f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104352:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0104359:	74 2a                	je     f0104385 <trap+0x23c>
f010435b:	e8 ab 1a 00 00       	call   f0105e0b <cpunum>
f0104360:	6b c0 74             	imul   $0x74,%eax,%eax
f0104363:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104369:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010436d:	75 16                	jne    f0104385 <trap+0x23c>
		env_run(curenv);
f010436f:	e8 97 1a 00 00       	call   f0105e0b <cpunum>
f0104374:	83 ec 0c             	sub    $0xc,%esp
f0104377:	6b c0 74             	imul   $0x74,%eax,%eax
f010437a:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104380:	e8 53 f1 ff ff       	call   f01034d8 <env_run>
	else
		sched_yield();
f0104385:	e8 f2 01 00 00       	call   f010457c <sched_yield>

f010438a <i0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(i0, T_DIVIDE)
f010438a:	6a 00                	push   $0x0
f010438c:	6a 00                	push   $0x0
f010438e:	e9 03 01 00 00       	jmp    f0104496 <_alltraps>
f0104393:	90                   	nop

f0104394 <i1>:
TRAPHANDLER_NOEC(i1, T_DEBUG)
f0104394:	6a 00                	push   $0x0
f0104396:	6a 01                	push   $0x1
f0104398:	e9 f9 00 00 00       	jmp    f0104496 <_alltraps>
f010439d:	90                   	nop

f010439e <i2>:
TRAPHANDLER_NOEC(i2, T_NMI)
f010439e:	6a 00                	push   $0x0
f01043a0:	6a 02                	push   $0x2
f01043a2:	e9 ef 00 00 00       	jmp    f0104496 <_alltraps>
f01043a7:	90                   	nop

f01043a8 <i3>:
TRAPHANDLER_NOEC(i3, T_BRKPT)
f01043a8:	6a 00                	push   $0x0
f01043aa:	6a 03                	push   $0x3
f01043ac:	e9 e5 00 00 00       	jmp    f0104496 <_alltraps>
f01043b1:	90                   	nop

f01043b2 <i4>:
TRAPHANDLER_NOEC(i4, T_OFLOW)
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 04                	push   $0x4
f01043b6:	e9 db 00 00 00       	jmp    f0104496 <_alltraps>
f01043bb:	90                   	nop

f01043bc <i5>:
TRAPHANDLER_NOEC(i5, T_BOUND)
f01043bc:	6a 00                	push   $0x0
f01043be:	6a 05                	push   $0x5
f01043c0:	e9 d1 00 00 00       	jmp    f0104496 <_alltraps>
f01043c5:	90                   	nop

f01043c6 <i6>:
TRAPHANDLER_NOEC(i6, T_ILLOP)
f01043c6:	6a 00                	push   $0x0
f01043c8:	6a 06                	push   $0x6
f01043ca:	e9 c7 00 00 00       	jmp    f0104496 <_alltraps>
f01043cf:	90                   	nop

f01043d0 <i7>:
TRAPHANDLER_NOEC(i7, T_DEVICE)
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 07                	push   $0x7
f01043d4:	e9 bd 00 00 00       	jmp    f0104496 <_alltraps>
f01043d9:	90                   	nop

f01043da <i8>:
TRAPHANDLER(i8, T_DBLFLT)
f01043da:	6a 08                	push   $0x8
f01043dc:	e9 b5 00 00 00       	jmp    f0104496 <_alltraps>
f01043e1:	90                   	nop

f01043e2 <i9>:
TRAPHANDLER_NOEC(i9, 9)
f01043e2:	6a 00                	push   $0x0
f01043e4:	6a 09                	push   $0x9
f01043e6:	e9 ab 00 00 00       	jmp    f0104496 <_alltraps>
f01043eb:	90                   	nop

f01043ec <i10>:
TRAPHANDLER(i10, T_TSS)
f01043ec:	6a 0a                	push   $0xa
f01043ee:	e9 a3 00 00 00       	jmp    f0104496 <_alltraps>
f01043f3:	90                   	nop

f01043f4 <i11>:
TRAPHANDLER(i11, T_SEGNP)
f01043f4:	6a 0b                	push   $0xb
f01043f6:	e9 9b 00 00 00       	jmp    f0104496 <_alltraps>
f01043fb:	90                   	nop

f01043fc <i12>:
TRAPHANDLER(i12, T_STACK)
f01043fc:	6a 0c                	push   $0xc
f01043fe:	e9 93 00 00 00       	jmp    f0104496 <_alltraps>
f0104403:	90                   	nop

f0104404 <i13>:
TRAPHANDLER(i13, T_GPFLT)
f0104404:	6a 0d                	push   $0xd
f0104406:	e9 8b 00 00 00       	jmp    f0104496 <_alltraps>
f010440b:	90                   	nop

f010440c <i14>:
TRAPHANDLER(i14, T_PGFLT)
f010440c:	6a 0e                	push   $0xe
f010440e:	e9 83 00 00 00       	jmp    f0104496 <_alltraps>
f0104413:	90                   	nop

f0104414 <i15>:
TRAPHANDLER_NOEC(i15, 15)
f0104414:	6a 00                	push   $0x0
f0104416:	6a 0f                	push   $0xf
f0104418:	eb 7c                	jmp    f0104496 <_alltraps>

f010441a <i16>:
TRAPHANDLER_NOEC(i16, T_FPERR)
f010441a:	6a 00                	push   $0x0
f010441c:	6a 10                	push   $0x10
f010441e:	eb 76                	jmp    f0104496 <_alltraps>

f0104420 <i17>:
TRAPHANDLER(i17, T_ALIGN)
f0104420:	6a 11                	push   $0x11
f0104422:	eb 72                	jmp    f0104496 <_alltraps>

f0104424 <i18>:
TRAPHANDLER_NOEC(i18, T_MCHK)
f0104424:	6a 00                	push   $0x0
f0104426:	6a 12                	push   $0x12
f0104428:	eb 6c                	jmp    f0104496 <_alltraps>

f010442a <i19>:
TRAPHANDLER_NOEC(i19, T_SIMDERR)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 13                	push   $0x13
f010442e:	eb 66                	jmp    f0104496 <_alltraps>

f0104430 <i20>:
TRAPHANDLER_NOEC(i20, T_SYSCALL)
f0104430:	6a 00                	push   $0x0
f0104432:	6a 30                	push   $0x30
f0104434:	eb 60                	jmp    f0104496 <_alltraps>

f0104436 <irq0>:

TRAPHANDLER_NOEC(irq0, IRQ_OFFSET + IRQ_TIMER)
f0104436:	6a 00                	push   $0x0
f0104438:	6a 20                	push   $0x20
f010443a:	eb 5a                	jmp    f0104496 <_alltraps>

f010443c <irq1>:
TRAPHANDLER_NOEC(irq1, IRQ_OFFSET+IRQ_KBD) 
f010443c:	6a 00                	push   $0x0
f010443e:	6a 21                	push   $0x21
f0104440:	eb 54                	jmp    f0104496 <_alltraps>

f0104442 <irq2>:
TRAPHANDLER_NOEC(irq2, 34)
f0104442:	6a 00                	push   $0x0
f0104444:	6a 22                	push   $0x22
f0104446:	eb 4e                	jmp    f0104496 <_alltraps>

f0104448 <irq3>:
TRAPHANDLER_NOEC(irq3, 35)
f0104448:	6a 00                	push   $0x0
f010444a:	6a 23                	push   $0x23
f010444c:	eb 48                	jmp    f0104496 <_alltraps>

f010444e <irq4>:
TRAPHANDLER_NOEC(irq4, IRQ_OFFSET+IRQ_SERIAL)
f010444e:	6a 00                	push   $0x0
f0104450:	6a 24                	push   $0x24
f0104452:	eb 42                	jmp    f0104496 <_alltraps>

f0104454 <irq5>:
TRAPHANDLER_NOEC(irq5, 37) 
f0104454:	6a 00                	push   $0x0
f0104456:	6a 25                	push   $0x25
f0104458:	eb 3c                	jmp    f0104496 <_alltraps>

f010445a <irq6>:
TRAPHANDLER_NOEC(irq6, 38)
f010445a:	6a 00                	push   $0x0
f010445c:	6a 26                	push   $0x26
f010445e:	eb 36                	jmp    f0104496 <_alltraps>

f0104460 <irq7>:
TRAPHANDLER_NOEC(irq7, 39)
f0104460:	6a 00                	push   $0x0
f0104462:	6a 27                	push   $0x27
f0104464:	eb 30                	jmp    f0104496 <_alltraps>

f0104466 <irq8>:
TRAPHANDLER_NOEC(irq8, 40)
f0104466:	6a 00                	push   $0x0
f0104468:	6a 28                	push   $0x28
f010446a:	eb 2a                	jmp    f0104496 <_alltraps>

f010446c <irq9>:
TRAPHANDLER_NOEC(irq9, 41) 
f010446c:	6a 00                	push   $0x0
f010446e:	6a 29                	push   $0x29
f0104470:	eb 24                	jmp    f0104496 <_alltraps>

f0104472 <irq10>:
TRAPHANDLER_NOEC(irq10, 42)
f0104472:	6a 00                	push   $0x0
f0104474:	6a 2a                	push   $0x2a
f0104476:	eb 1e                	jmp    f0104496 <_alltraps>

f0104478 <irq11>:
TRAPHANDLER_NOEC(irq11, 43)
f0104478:	6a 00                	push   $0x0
f010447a:	6a 2b                	push   $0x2b
f010447c:	eb 18                	jmp    f0104496 <_alltraps>

f010447e <irq12>:
TRAPHANDLER_NOEC(irq12, 44)
f010447e:	6a 00                	push   $0x0
f0104480:	6a 2c                	push   $0x2c
f0104482:	eb 12                	jmp    f0104496 <_alltraps>

f0104484 <irq13>:
TRAPHANDLER_NOEC(irq13, 45) 
f0104484:	6a 00                	push   $0x0
f0104486:	6a 2d                	push   $0x2d
f0104488:	eb 0c                	jmp    f0104496 <_alltraps>

f010448a <irq14>:
TRAPHANDLER_NOEC(irq14, 46)
f010448a:	6a 00                	push   $0x0
f010448c:	6a 2e                	push   $0x2e
f010448e:	eb 06                	jmp    f0104496 <_alltraps>

f0104490 <irq15>:
TRAPHANDLER_NOEC(irq15, 47)
f0104490:	6a 00                	push   $0x0
f0104492:	6a 2f                	push   $0x2f
f0104494:	eb 00                	jmp    f0104496 <_alltraps>

f0104496 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f0104496:	1e                   	push   %ds
        pushl %es
f0104497:	06                   	push   %es
        pushal
f0104498:	60                   	pusha  
        mov $GD_KD, %eax
f0104499:	b8 10 00 00 00       	mov    $0x10,%eax
        mov %eax, %ds
f010449e:	8e d8                	mov    %eax,%ds
        mov %eax, %es
f01044a0:	8e c0                	mov    %eax,%es
        pushl %esp
f01044a2:	54                   	push   %esp
        call trap
f01044a3:	e8 a1 fc ff ff       	call   f0104149 <trap>

f01044a8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044a8:	55                   	push   %ebp
f01044a9:	89 e5                	mov    %esp,%ebp
f01044ab:	83 ec 08             	sub    $0x8,%esp
f01044ae:	a1 68 a2 20 f0       	mov    0xf020a268,%eax
f01044b3:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044b6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044bb:	8b 02                	mov    (%edx),%eax
f01044bd:	83 e8 01             	sub    $0x1,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044c0:	83 f8 02             	cmp    $0x2,%eax
f01044c3:	76 10                	jbe    f01044d5 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044c5:	83 c1 01             	add    $0x1,%ecx
f01044c8:	83 c2 7c             	add    $0x7c,%edx
f01044cb:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044d1:	75 e8                	jne    f01044bb <sched_halt+0x13>
f01044d3:	eb 08                	jmp    f01044dd <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044d5:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044db:	75 1f                	jne    f01044fc <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01044dd:	83 ec 0c             	sub    $0xc,%esp
f01044e0:	68 90 7b 10 f0       	push   $0xf0107b90
f01044e5:	e8 36 f2 ff ff       	call   f0103720 <cprintf>
f01044ea:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044ed:	83 ec 0c             	sub    $0xc,%esp
f01044f0:	6a 00                	push   $0x0
f01044f2:	e8 b0 c4 ff ff       	call   f01009a7 <monitor>
f01044f7:	83 c4 10             	add    $0x10,%esp
f01044fa:	eb f1                	jmp    f01044ed <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044fc:	e8 0a 19 00 00       	call   f0105e0b <cpunum>
f0104501:	6b c0 74             	imul   $0x74,%eax,%eax
f0104504:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f010450b:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010450e:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104513:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104518:	77 12                	ja     f010452c <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010451a:	50                   	push   %eax
f010451b:	68 08 65 10 f0       	push   $0xf0106508
f0104520:	6a 4a                	push   $0x4a
f0104522:	68 b9 7b 10 f0       	push   $0xf0107bb9
f0104527:	e8 14 bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010452c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104531:	0f 22 d8             	mov    %eax,%cr3
	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104534:	e8 d2 18 00 00       	call   f0105e0b <cpunum>
f0104539:	6b d0 74             	imul   $0x74,%eax,%edx
f010453c:	81 c2 40 b0 20 f0    	add    $0xf020b040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104542:	b8 02 00 00 00       	mov    $0x2,%eax
f0104547:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010454b:	83 ec 0c             	sub    $0xc,%esp
f010454e:	68 00 14 12 f0       	push   $0xf0121400
f0104553:	e8 bb 1b 00 00       	call   f0106113 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104558:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010455a:	e8 ac 18 00 00       	call   f0105e0b <cpunum>
f010455f:	6b c0 74             	imul   $0x74,%eax,%eax
	xchg(&thiscpu->cpu_status, CPU_HALTED);
	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104562:	8b 80 50 b0 20 f0    	mov    -0xfdf4fb0(%eax),%eax
f0104568:	bd 00 00 00 00       	mov    $0x0,%ebp
f010456d:	89 c4                	mov    %eax,%esp
f010456f:	6a 00                	push   $0x0
f0104571:	6a 00                	push   $0x0
f0104573:	fb                   	sti    
f0104574:	f4                   	hlt    
f0104575:	eb fd                	jmp    f0104574 <sched_halt+0xcc>
f0104577:	83 c4 10             	add    $0x10,%esp
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010457a:	c9                   	leave  
f010457b:	c3                   	ret    

f010457c <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010457c:	55                   	push   %ebp
f010457d:	89 e5                	mov    %esp,%ebp
f010457f:	56                   	push   %esi
f0104580:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f0104581:	e8 85 18 00 00       	call   f0105e0b <cpunum>
f0104586:	6b c0 74             	imul   $0x74,%eax,%eax
        else cur = 0;
f0104589:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f010458e:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0104595:	74 17                	je     f01045ae <sched_yield+0x32>
f0104597:	e8 6f 18 00 00       	call   f0105e0b <cpunum>
f010459c:	6b c0 74             	imul   $0x74,%eax,%eax
f010459f:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01045a5:	8b 48 48             	mov    0x48(%eax),%ecx
f01045a8:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045ae:	8b 35 68 a2 20 f0    	mov    0xf020a268,%esi
f01045b4:	89 ca                	mov    %ecx,%edx
f01045b6:	81 c1 00 04 00 00    	add    $0x400,%ecx
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
f01045bc:	89 d3                	mov    %edx,%ebx
f01045be:	c1 fb 1f             	sar    $0x1f,%ebx
f01045c1:	c1 eb 16             	shr    $0x16,%ebx
f01045c4:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01045c7:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045cc:	29 d8                	sub    %ebx,%eax
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045ce:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045d1:	89 c3                	mov    %eax,%ebx
f01045d3:	83 7c 06 54 02       	cmpl   $0x2,0x54(%esi,%eax,1)
f01045d8:	75 14                	jne    f01045ee <sched_yield+0x72>
                      envs[j].env_cpunum == cpunum();
f01045da:	e8 2c 18 00 00       	call   f0105e0b <cpunum>
                      env_run(envs + j);
f01045df:	83 ec 0c             	sub    $0xc,%esp
f01045e2:	03 1d 68 a2 20 f0    	add    0xf020a268,%ebx
f01045e8:	53                   	push   %ebx
f01045e9:	e8 ea ee ff ff       	call   f01034d8 <env_run>
f01045ee:	83 c2 01             	add    $0x1,%edx
	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
f01045f1:	39 ca                	cmp    %ecx,%edx
f01045f3:	75 c7                	jne    f01045bc <sched_yield+0x40>
              if (envs[j].env_status == ENV_RUNNABLE) {
                      envs[j].env_cpunum == cpunum();
                      env_run(envs + j);
              }
        }
        if (curenv && curenv->env_status == ENV_RUNNING && cpunum() == curenv->env_cpunum) {
f01045f5:	e8 11 18 00 00       	call   f0105e0b <cpunum>
f01045fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fd:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0104604:	74 44                	je     f010464a <sched_yield+0xce>
f0104606:	e8 00 18 00 00       	call   f0105e0b <cpunum>
f010460b:	6b c0 74             	imul   $0x74,%eax,%eax
f010460e:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104614:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104618:	75 30                	jne    f010464a <sched_yield+0xce>
f010461a:	e8 ec 17 00 00       	call   f0105e0b <cpunum>
f010461f:	89 c3                	mov    %eax,%ebx
f0104621:	e8 e5 17 00 00       	call   f0105e0b <cpunum>
f0104626:	6b d0 74             	imul   $0x74,%eax,%edx
f0104629:	8b 82 48 b0 20 f0    	mov    -0xfdf4fb8(%edx),%eax
f010462f:	3b 58 5c             	cmp    0x5c(%eax),%ebx
f0104632:	75 16                	jne    f010464a <sched_yield+0xce>
               env_run(curenv);
f0104634:	e8 d2 17 00 00       	call   f0105e0b <cpunum>
f0104639:	83 ec 0c             	sub    $0xc,%esp
f010463c:	6b c0 74             	imul   $0x74,%eax,%eax
f010463f:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104645:	e8 8e ee ff ff       	call   f01034d8 <env_run>
        }
	// sched_halt never returns
	sched_halt();
f010464a:	e8 59 fe ff ff       	call   f01044a8 <sched_halt>
}
f010464f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104652:	5b                   	pop    %ebx
f0104653:	5e                   	pop    %esi
f0104654:	5d                   	pop    %ebp
f0104655:	c3                   	ret    

f0104656 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104656:	55                   	push   %ebp
f0104657:	89 e5                	mov    %esp,%ebp
f0104659:	57                   	push   %edi
f010465a:	56                   	push   %esi
f010465b:	53                   	push   %ebx
f010465c:	83 ec 1c             	sub    $0x1c,%esp
f010465f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
f0104662:	83 f8 0d             	cmp    $0xd,%eax
f0104665:	0f 87 dc 05 00 00    	ja     f0104c47 <syscall+0x5f1>
f010466b:	ff 24 85 cc 7b 10 f0 	jmp    *-0xfef8434(,%eax,4)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104672:	e8 94 17 00 00       	call   f0105e0b <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104677:	83 ec 04             	sub    $0x4,%esp
f010467a:	6a 01                	push   $0x1
f010467c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010467f:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104680:	6b c0 74             	imul   $0x74,%eax,%eax
f0104683:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104689:	ff 70 48             	pushl  0x48(%eax)
f010468c:	e8 80 e8 ff ff       	call   f0102f11 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104691:	6a 04                	push   $0x4
f0104693:	ff 75 10             	pushl  0x10(%ebp)
f0104696:	ff 75 0c             	pushl  0xc(%ebp)
f0104699:	ff 75 e4             	pushl  -0x1c(%ebp)
f010469c:	e8 9a e7 ff ff       	call   f0102e3b <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01046a1:	83 c4 1c             	add    $0x1c,%esp
f01046a4:	ff 75 0c             	pushl  0xc(%ebp)
f01046a7:	ff 75 10             	pushl  0x10(%ebp)
f01046aa:	68 c6 7b 10 f0       	push   $0xf0107bc6
f01046af:	e8 6c f0 ff ff       	call   f0103720 <cprintf>
f01046b4:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
        case SYS_cputs:
                sys_cputs((char *)a1, a2);
                rslt = 0;
f01046b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046bc:	e9 92 05 00 00       	jmp    f0104c53 <syscall+0x5fd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046c1:	e8 33 bf ff ff       	call   f01005f9 <cons_getc>
f01046c6:	89 c3                	mov    %eax,%ebx
                sys_cputs((char *)a1, a2);
                rslt = 0;
                break;
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
f01046c8:	e9 86 05 00 00       	jmp    f0104c53 <syscall+0x5fd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046cd:	e8 39 17 00 00       	call   f0105e0b <cpunum>
f01046d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d5:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01046db:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
	case SYS_getenvid:
                rslt = sys_getenvid();
                break;
f01046de:	e9 70 05 00 00       	jmp    f0104c53 <syscall+0x5fd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046e3:	83 ec 04             	sub    $0x4,%esp
f01046e6:	6a 01                	push   $0x1
f01046e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046eb:	50                   	push   %eax
f01046ec:	ff 75 0c             	pushl  0xc(%ebp)
f01046ef:	e8 1d e8 ff ff       	call   f0102f11 <envid2env>
f01046f4:	83 c4 10             	add    $0x10,%esp
		return r;
f01046f7:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046f9:	85 c0                	test   %eax,%eax
f01046fb:	0f 88 52 05 00 00    	js     f0104c53 <syscall+0x5fd>
		return r;
	env_destroy(e);
f0104701:	83 ec 0c             	sub    $0xc,%esp
f0104704:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104707:	e8 2d ed ff ff       	call   f0103439 <env_destroy>
f010470c:	83 c4 10             	add    $0x10,%esp
	return 0;
f010470f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104714:	e9 3a 05 00 00       	jmp    f0104c53 <syscall+0x5fd>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104719:	e8 5e fe ff ff       	call   f010457c <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f010471e:	e8 e8 16 00 00       	call   f0105e0b <cpunum>
f0104723:	83 ec 08             	sub    $0x8,%esp
f0104726:	6b c0 74             	imul   $0x74,%eax,%eax
f0104729:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010472f:	ff 70 48             	pushl  0x48(%eax)
f0104732:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104735:	50                   	push   %eax
f0104736:	e8 db e8 ff ff       	call   f0103016 <env_alloc>
f010473b:	83 c4 10             	add    $0x10,%esp
                return ret;
f010473e:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f0104740:	85 c0                	test   %eax,%eax
f0104742:	0f 85 0b 05 00 00    	jne    f0104c53 <syscall+0x5fd>
                return ret;
        
        newenv->env_status = ENV_NOT_RUNNABLE;
f0104748:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010474b:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
        newenv->env_tf = curenv->env_tf; 
f0104752:	e8 b4 16 00 00       	call   f0105e0b <cpunum>
f0104757:	6b c0 74             	imul   $0x74,%eax,%eax
f010475a:	8b b0 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%esi
f0104760:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104765:	89 df                	mov    %ebx,%edi
f0104767:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        newenv->env_tf.tf_regs.reg_eax = 0;
f0104769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010476c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return newenv->env_id;
f0104773:	8b 58 48             	mov    0x48(%eax),%ebx
f0104776:	e9 d8 04 00 00       	jmp    f0104c53 <syscall+0x5fd>

	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f010477b:	83 ec 04             	sub    $0x4,%esp
f010477e:	6a 01                	push   $0x1
f0104780:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104783:	50                   	push   %eax
f0104784:	ff 75 0c             	pushl  0xc(%ebp)
f0104787:	e8 85 e7 ff ff       	call   f0102f11 <envid2env>
f010478c:	83 c4 10             	add    $0x10,%esp
f010478f:	85 c0                	test   %eax,%eax
f0104791:	0f 85 ba 00 00 00    	jne    f0104851 <syscall+0x1fb>
                return rslt;
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f0104797:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010479e:	0f 87 b4 00 00 00    	ja     f0104858 <syscall+0x202>
f01047a4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047ab:	0f 85 b1 00 00 00    	jne    f0104862 <syscall+0x20c>
                return -E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01047b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01047b4:	83 e0 05             	and    $0x5,%eax
f01047b7:	83 f8 05             	cmp    $0x5,%eax
f01047ba:	0f 85 ac 00 00 00    	jne    f010486c <syscall+0x216>
                return -E_INVAL;
        if((p = page_alloc(1)) == (void*)NULL)
f01047c0:	83 ec 0c             	sub    $0xc,%esp
f01047c3:	6a 01                	push   $0x1
f01047c5:	e8 e7 c7 ff ff       	call   f0100fb1 <page_alloc>
f01047ca:	89 c6                	mov    %eax,%esi
f01047cc:	83 c4 10             	add    $0x10,%esp
f01047cf:	85 c0                	test   %eax,%eax
f01047d1:	0f 84 9f 00 00 00    	je     f0104876 <syscall+0x220>
                return -E_NO_MEM;
        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) {
f01047d7:	ff 75 14             	pushl  0x14(%ebp)
f01047da:	ff 75 10             	pushl  0x10(%ebp)
f01047dd:	50                   	push   %eax
f01047de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047e1:	ff 70 60             	pushl  0x60(%eax)
f01047e4:	e8 de ca ff ff       	call   f01012c7 <page_insert>
f01047e9:	89 c3                	mov    %eax,%ebx
f01047eb:	83 c4 10             	add    $0x10,%esp
f01047ee:	85 c0                	test   %eax,%eax
f01047f0:	74 11                	je     f0104803 <syscall+0x1ad>
                page_free(p);
f01047f2:	83 ec 0c             	sub    $0xc,%esp
f01047f5:	56                   	push   %esi
f01047f6:	e8 24 c8 ff ff       	call   f010101f <page_free>
f01047fb:	83 c4 10             	add    $0x10,%esp
f01047fe:	e9 50 04 00 00       	jmp    f0104c53 <syscall+0x5fd>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104803:	2b 35 d0 ae 20 f0    	sub    0xf020aed0,%esi
f0104809:	c1 fe 03             	sar    $0x3,%esi
f010480c:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010480f:	89 f0                	mov    %esi,%eax
f0104811:	c1 e8 0c             	shr    $0xc,%eax
f0104814:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f010481a:	72 12                	jb     f010482e <syscall+0x1d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010481c:	56                   	push   %esi
f010481d:	68 e4 64 10 f0       	push   $0xf01064e4
f0104822:	6a 58                	push   $0x58
f0104824:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0104829:	e8 12 b8 ff ff       	call   f0100040 <_panic>
                return rslt;
        }
        memset(page2kva(p), 0, PGSIZE);
f010482e:	83 ec 04             	sub    $0x4,%esp
f0104831:	68 00 10 00 00       	push   $0x1000
f0104836:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0104838:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f010483e:	56                   	push   %esi
f010483f:	e8 a2 0f 00 00       	call   f01057e6 <memset>
f0104844:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104847:	bb 00 00 00 00       	mov    $0x0,%ebx
f010484c:	e9 02 04 00 00       	jmp    f0104c53 <syscall+0x5fd>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;
f0104851:	89 c3                	mov    %eax,%ebx
f0104853:	e9 fb 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL;
f0104858:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010485d:	e9 f1 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
f0104862:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104867:	e9 e7 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010486c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104871:	e9 dd 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((p = page_alloc(1)) == (void*)NULL)
                return -E_NO_MEM;
f0104876:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
        case SYS_exofork:
                rslt = sys_exofork();
                break;
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
f010487b:	e9 d3 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f0104880:	83 ec 04             	sub    $0x4,%esp
f0104883:	6a 01                	push   $0x1
f0104885:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104888:	50                   	push   %eax
f0104889:	ff 75 0c             	pushl  0xc(%ebp)
f010488c:	e8 80 e6 ff ff       	call   f0102f11 <envid2env>
f0104891:	83 c4 10             	add    $0x10,%esp
                return rslt;
f0104894:	89 c3                	mov    %eax,%ebx
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f0104896:	85 c0                	test   %eax,%eax
f0104898:	0f 85 b5 03 00 00    	jne    f0104c53 <syscall+0x5fd>
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f010489e:	83 ec 04             	sub    $0x4,%esp
f01048a1:	6a 01                	push   $0x1
f01048a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048a6:	50                   	push   %eax
f01048a7:	ff 75 14             	pushl  0x14(%ebp)
f01048aa:	e8 62 e6 ff ff       	call   f0102f11 <envid2env>
f01048af:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01048b2:	89 c3                	mov    %eax,%ebx
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048b4:	85 c0                	test   %eax,%eax
f01048b6:	0f 85 97 03 00 00    	jne    f0104c53 <syscall+0x5fd>
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
f01048bc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048c3:	77 73                	ja     f0104938 <syscall+0x2e2>
                return -E_INVAL;
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
f01048c5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048cc:	75 74                	jne    f0104942 <syscall+0x2ec>
f01048ce:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048d5:	77 6b                	ja     f0104942 <syscall+0x2ec>
f01048d7:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048de:	75 6c                	jne    f010494c <syscall+0x2f6>
                return -E_INVAL;
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
f01048e0:	83 ec 04             	sub    $0x4,%esp
f01048e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048e6:	50                   	push   %eax
f01048e7:	ff 75 10             	pushl  0x10(%ebp)
f01048ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048ed:	ff 70 60             	pushl  0x60(%eax)
f01048f0:	e8 e6 c8 ff ff       	call   f01011db <page_lookup>
f01048f5:	83 c4 10             	add    $0x10,%esp
f01048f8:	85 c0                	test   %eax,%eax
f01048fa:	74 5a                	je     f0104956 <syscall+0x300>
f01048fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048ff:	8b 12                	mov    (%edx),%edx
f0104901:	f6 c2 01             	test   $0x1,%dl
f0104904:	74 5a                	je     f0104960 <syscall+0x30a>
                return 	-E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0104906:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104909:	83 e1 05             	and    $0x5,%ecx
f010490c:	83 f9 05             	cmp    $0x5,%ecx
f010490f:	75 59                	jne    f010496a <syscall+0x314>
                return -E_INVAL;
        if((perm & PTE_W) && !(*srcpte & PTE_W))
f0104911:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104915:	74 05                	je     f010491c <syscall+0x2c6>
f0104917:	f6 c2 02             	test   $0x2,%dl
f010491a:	74 58                	je     f0104974 <syscall+0x31e>
                return -E_INVAL;
        rslt =  page_insert(dst->env_pgdir, pg, dstva, perm);
f010491c:	ff 75 1c             	pushl  0x1c(%ebp)
f010491f:	ff 75 18             	pushl  0x18(%ebp)
f0104922:	50                   	push   %eax
f0104923:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104926:	ff 70 60             	pushl  0x60(%eax)
f0104929:	e8 99 c9 ff ff       	call   f01012c7 <page_insert>
f010492e:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104931:	89 c3                	mov    %eax,%ebx
f0104933:	e9 1b 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
                return -E_INVAL;
f0104938:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010493d:	e9 11 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
                return -E_INVAL;
f0104942:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104947:	e9 07 03 00 00       	jmp    f0104c53 <syscall+0x5fd>
f010494c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104951:	e9 fd 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
                return 	-E_INVAL;
f0104956:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010495b:	e9 f3 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
f0104960:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104965:	e9 e9 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010496a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496f:	e9 df 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if((perm & PTE_W) && !(*srcpte & PTE_W))
                return -E_INVAL;
f0104974:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
f0104979:	e9 d5 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f010497e:	83 ec 04             	sub    $0x4,%esp
f0104981:	6a 01                	push   $0x1
f0104983:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104986:	50                   	push   %eax
f0104987:	ff 75 0c             	pushl  0xc(%ebp)
f010498a:	e8 82 e5 ff ff       	call   f0102f11 <envid2env>
f010498f:	83 c4 10             	add    $0x10,%esp
                return rslt;  
f0104992:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f0104994:	85 c0                	test   %eax,%eax
f0104996:	0f 85 b7 02 00 00    	jne    f0104c53 <syscall+0x5fd>
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f010499c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049a3:	77 27                	ja     f01049cc <syscall+0x376>
f01049a5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049ac:	75 28                	jne    f01049d6 <syscall+0x380>
                return -E_INVAL; 
        page_remove(tmp->env_pgdir, va);
f01049ae:	83 ec 08             	sub    $0x8,%esp
f01049b1:	ff 75 10             	pushl  0x10(%ebp)
f01049b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b7:	ff 70 60             	pushl  0x60(%eax)
f01049ba:	e8 b7 c8 ff ff       	call   f0101276 <page_remove>
f01049bf:	83 c4 10             	add    $0x10,%esp
        return 0;
f01049c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049c7:	e9 87 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL; 
f01049cc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d1:	e9 7d 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
f01049d6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
	case SYS_page_unmap:
                rslt = sys_page_unmap(a1, (void *)a2);
                break;
f01049db:	e9 73 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
	// envid's status.

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01049e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01049e3:	83 e8 02             	sub    $0x2,%eax
f01049e6:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01049eb:	75 2c                	jne    f0104a19 <syscall+0x3c3>
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f01049ed:	83 ec 04             	sub    $0x4,%esp
f01049f0:	6a 01                	push   $0x1
f01049f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049f5:	50                   	push   %eax
f01049f6:	ff 75 0c             	pushl  0xc(%ebp)
f01049f9:	e8 13 e5 ff ff       	call   f0102f11 <envid2env>
f01049fe:	83 c4 10             	add    $0x10,%esp
                tmp->env_status = status;
        return rslt;     
f0104a01:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a03:	85 c0                	test   %eax,%eax
f0104a05:	0f 85 48 02 00 00    	jne    f0104c53 <syscall+0x5fd>
                tmp->env_status = status;
f0104a0b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a11:	89 4a 54             	mov    %ecx,0x54(%edx)
f0104a14:	e9 3a 02 00 00       	jmp    f0104c53 <syscall+0x5fd>

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
f0104a19:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a1e:	e9 30 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a23:	83 ec 04             	sub    $0x4,%esp
f0104a26:	6a 01                	push   $0x1
f0104a28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a2b:	50                   	push   %eax
f0104a2c:	ff 75 0c             	pushl  0xc(%ebp)
f0104a2f:	e8 dd e4 ff ff       	call   f0102f11 <envid2env>
f0104a34:	83 c4 10             	add    $0x10,%esp
f0104a37:	85 c0                	test   %eax,%eax
f0104a39:	75 09                	jne    f0104a44 <syscall+0x3ee>
                tmp->env_pgfault_upcall = func;
f0104a3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a3e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a41:	89 7a 64             	mov    %edi,0x64(%edx)
                break;
        case SYS_env_set_status:
                rslt = sys_env_set_status(a1, a2);
                break;
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104a44:	89 c3                	mov    %eax,%ebx
                break;
f0104a46:	e9 08 02 00 00       	jmp    f0104c53 <syscall+0x5fd>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
f0104a4b:	83 ec 04             	sub    $0x4,%esp
f0104a4e:	6a 00                	push   $0x0
f0104a50:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a53:	50                   	push   %eax
f0104a54:	ff 75 0c             	pushl  0xc(%ebp)
f0104a57:	e8 b5 e4 ff ff       	call   f0102f11 <envid2env>
f0104a5c:	83 c4 10             	add    $0x10,%esp
f0104a5f:	85 c0                	test   %eax,%eax
f0104a61:	0f 88 07 01 00 00    	js     f0104b6e <syscall+0x518>
                return -E_BAD_ENV;
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
f0104a67:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a6a:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a6e:	0f 84 04 01 00 00    	je     f0104b78 <syscall+0x522>
f0104a74:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a77:	85 db                	test   %ebx,%ebx
f0104a79:	0f 85 03 01 00 00    	jne    f0104b82 <syscall+0x52c>
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
f0104a7f:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a86:	0f 87 ab 00 00 00    	ja     f0104b37 <syscall+0x4e1>
                if((size_t)srcva % PGSIZE)
f0104a8c:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a93:	75 70                	jne    f0104b05 <syscall+0x4af>
                        return -E_INVAL;
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
f0104a95:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a98:	83 e0 05             	and    $0x5,%eax
f0104a9b:	83 f8 05             	cmp    $0x5,%eax
f0104a9e:	75 6f                	jne    f0104b0f <syscall+0x4b9>
                        return -E_INVAL;
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104aa0:	e8 66 13 00 00       	call   f0105e0b <cpunum>
f0104aa5:	83 ec 04             	sub    $0x4,%esp
f0104aa8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104aab:	52                   	push   %edx
f0104aac:	ff 75 14             	pushl  0x14(%ebp)
f0104aaf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab2:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104ab8:	ff 70 60             	pushl  0x60(%eax)
f0104abb:	e8 1b c7 ff ff       	call   f01011db <page_lookup>
                if(!pg) return -E_INVAL;
f0104ac0:	83 c4 10             	add    $0x10,%esp
f0104ac3:	85 c0                	test   %eax,%eax
f0104ac5:	74 52                	je     f0104b19 <syscall+0x4c3>
                if( (perm & PTE_W) && !(*pte & PTE_W))
f0104ac7:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104acb:	74 08                	je     f0104ad5 <syscall+0x47f>
f0104acd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ad0:	f6 02 02             	testb  $0x2,(%edx)
f0104ad3:	74 4e                	je     f0104b23 <syscall+0x4cd>
                        return -E_INVAL;
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
f0104ad5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ad8:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104adb:	8d 71 ff             	lea    -0x1(%ecx),%esi
f0104ade:	81 fe fe ff bf ee    	cmp    $0xeebffffe,%esi
f0104ae4:	77 51                	ja     f0104b37 <syscall+0x4e1>
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
f0104ae6:	ff 75 18             	pushl  0x18(%ebp)
f0104ae9:	51                   	push   %ecx
f0104aea:	50                   	push   %eax
f0104aeb:	ff 72 60             	pushl  0x60(%edx)
f0104aee:	e8 d4 c7 ff ff       	call   f01012c7 <page_insert>
f0104af3:	83 c4 10             	add    $0x10,%esp
f0104af6:	85 c0                	test   %eax,%eax
f0104af8:	78 33                	js     f0104b2d <syscall+0x4d7>
                                return -E_NO_MEM;
                        target->env_ipc_perm = perm;
f0104afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104afd:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b00:	89 78 78             	mov    %edi,0x78(%eax)
f0104b03:	eb 32                	jmp    f0104b37 <syscall+0x4e1>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
                if((size_t)srcva % PGSIZE)
                        return -E_INVAL;
f0104b05:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b0a:	e9 44 01 00 00       	jmp    f0104c53 <syscall+0x5fd>
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
                        return -E_INVAL;
f0104b0f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b14:	e9 3a 01 00 00       	jmp    f0104c53 <syscall+0x5fd>
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
                if(!pg) return -E_INVAL;
f0104b19:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b1e:	e9 30 01 00 00       	jmp    f0104c53 <syscall+0x5fd>
                if( (perm & PTE_W) && !(*pte & PTE_W))
                        return -E_INVAL;
f0104b23:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b28:	e9 26 01 00 00       	jmp    f0104c53 <syscall+0x5fd>
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
                                return -E_NO_MEM;
f0104b2d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b32:	e9 1c 01 00 00       	jmp    f0104c53 <syscall+0x5fd>
                        target->env_ipc_perm = perm;
                }
        }
        target->env_ipc_recving = 0;
f0104b37:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b3a:	c6 46 68 00          	movb   $0x0,0x68(%esi)
        target->env_ipc_value = value;
f0104b3e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b41:	89 46 70             	mov    %eax,0x70(%esi)
        target->env_ipc_from = curenv->env_id;
f0104b44:	e8 c2 12 00 00       	call   f0105e0b <cpunum>
f0104b49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4c:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104b52:	8b 40 48             	mov    0x48(%eax),%eax
f0104b55:	89 46 74             	mov    %eax,0x74(%esi)
        target->env_tf.tf_regs.reg_eax = 0;
f0104b58:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b5b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        target->env_status = ENV_RUNNABLE;
f0104b62:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104b69:	e9 e5 00 00 00       	jmp    f0104c53 <syscall+0x5fd>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
                return -E_BAD_ENV;
f0104b6e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104b73:	e9 db 00 00 00       	jmp    f0104c53 <syscall+0x5fd>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
f0104b78:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b7d:	e9 d1 00 00 00       	jmp    f0104c53 <syscall+0x5fd>
f0104b82:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
f0104b87:	e9 c7 00 00 00       	jmp    f0104c53 <syscall+0x5fd>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
        if((dstva < (void *)UTOP) && ((size_t)dstva % PGSIZE))
f0104b8c:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b93:	77 0d                	ja     f0104ba2 <syscall+0x54c>
f0104b95:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b9c:	0f 85 ac 00 00 00    	jne    f0104c4e <syscall+0x5f8>
                        return -E_INVAL;
        curenv->env_ipc_recving = 1;
f0104ba2:	e8 64 12 00 00       	call   f0105e0b <cpunum>
f0104ba7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104baa:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bb0:	c6 40 68 01          	movb   $0x1,0x68(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0104bb4:	e8 52 12 00 00       	call   f0105e0b <cpunum>
f0104bb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbc:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bc2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_dstva = dstva;
f0104bc9:	e8 3d 12 00 00       	call   f0105e0b <cpunum>
f0104bce:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd1:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bd7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104bda:	89 78 6c             	mov    %edi,0x6c(%eax)
        curenv->env_ipc_from = 0;
f0104bdd:	e8 29 12 00 00       	call   f0105e0b <cpunum>
f0104be2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be5:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104beb:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104bf2:	e8 85 f9 ff ff       	call   f010457c <sched_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104bf7:	83 ec 04             	sub    $0x4,%esp
f0104bfa:	6a 01                	push   $0x1
f0104bfc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bff:	50                   	push   %eax
f0104c00:	ff 75 0c             	pushl  0xc(%ebp)
f0104c03:	e8 09 e3 ff ff       	call   f0102f11 <envid2env>
f0104c08:	83 c4 10             	add    $0x10,%esp
                return ret;
f0104c0b:	89 c3                	mov    %eax,%ebx
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104c0d:	85 c0                	test   %eax,%eax
f0104c0f:	78 42                	js     f0104c53 <syscall+0x5fd>
                return ret;
        user_mem_assert(newenv, tf, sizeof(struct Trapframe), PTE_U);
f0104c11:	6a 04                	push   $0x4
f0104c13:	6a 44                	push   $0x44
f0104c15:	ff 75 10             	pushl  0x10(%ebp)
f0104c18:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c1b:	e8 1b e2 ff ff       	call   f0102e3b <user_mem_assert>
        newenv->env_tf = *tf;
f0104c20:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c28:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_eflags |= FL_IF;
f0104c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c30:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
        newenv->env_tf.tf_cs = GD_UT | 3;	
f0104c37:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
f0104c3d:	83 c4 10             	add    $0x10,%esp
        return 0;
f0104c40:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c45:	eb 0c                	jmp    f0104c53 <syscall+0x5fd>
                break;
        case SYS_env_set_trapframe:
                rslt = sys_env_set_trapframe(a1, (void *)a2);
                break;
	default:
		return -E_INVAL;
f0104c47:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c4c:	eb 05                	jmp    f0104c53 <syscall+0x5fd>
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
        case SYS_ipc_recv:
                rslt = sys_ipc_recv((void *)a1);
f0104c4e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
                break;
	default:
		return -E_INVAL;
	}
        return rslt;
}
f0104c53:	89 d8                	mov    %ebx,%eax
f0104c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c58:	5b                   	pop    %ebx
f0104c59:	5e                   	pop    %esi
f0104c5a:	5f                   	pop    %edi
f0104c5b:	5d                   	pop    %ebp
f0104c5c:	c3                   	ret    

f0104c5d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c5d:	55                   	push   %ebp
f0104c5e:	89 e5                	mov    %esp,%ebp
f0104c60:	57                   	push   %edi
f0104c61:	56                   	push   %esi
f0104c62:	53                   	push   %ebx
f0104c63:	83 ec 14             	sub    $0x14,%esp
f0104c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c6c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c72:	8b 1a                	mov    (%edx),%ebx
f0104c74:	8b 01                	mov    (%ecx),%eax
f0104c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c80:	e9 88 00 00 00       	jmp    f0104d0d <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c88:	01 d8                	add    %ebx,%eax
f0104c8a:	89 c6                	mov    %eax,%esi
f0104c8c:	c1 ee 1f             	shr    $0x1f,%esi
f0104c8f:	01 c6                	add    %eax,%esi
f0104c91:	d1 fe                	sar    %esi
f0104c93:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c99:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c9c:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c9e:	eb 03                	jmp    f0104ca3 <stab_binsearch+0x46>
			m--;
f0104ca0:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ca3:	39 c3                	cmp    %eax,%ebx
f0104ca5:	7f 1f                	jg     f0104cc6 <stab_binsearch+0x69>
f0104ca7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cab:	83 ea 0c             	sub    $0xc,%edx
f0104cae:	39 f9                	cmp    %edi,%ecx
f0104cb0:	75 ee                	jne    f0104ca0 <stab_binsearch+0x43>
f0104cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cb5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cb8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cbb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cbf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cc2:	76 18                	jbe    f0104cdc <stab_binsearch+0x7f>
f0104cc4:	eb 05                	jmp    f0104ccb <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cc6:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104cc9:	eb 42                	jmp    f0104d0d <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104ccb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cce:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cd0:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cd3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cda:	eb 31                	jmp    f0104d0d <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104cdc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cdf:	73 17                	jae    f0104cf8 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ce4:	83 e8 01             	sub    $0x1,%eax
f0104ce7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cea:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ced:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cef:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cf6:	eb 15                	jmp    f0104d0d <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cf8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cfb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104cfe:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0104d00:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d04:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d06:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d0d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d10:	0f 8e 6f ff ff ff    	jle    f0104c85 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d16:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d1a:	75 0f                	jne    f0104d2b <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104d1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d1f:	8b 00                	mov    (%eax),%eax
f0104d21:	83 e8 01             	sub    $0x1,%eax
f0104d24:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d27:	89 06                	mov    %eax,(%esi)
f0104d29:	eb 2c                	jmp    f0104d57 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d2e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d30:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d33:	8b 0e                	mov    (%esi),%ecx
f0104d35:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d38:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d3b:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d3e:	eb 03                	jmp    f0104d43 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d40:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d43:	39 c8                	cmp    %ecx,%eax
f0104d45:	7e 0b                	jle    f0104d52 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104d47:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d4b:	83 ea 0c             	sub    $0xc,%edx
f0104d4e:	39 fb                	cmp    %edi,%ebx
f0104d50:	75 ee                	jne    f0104d40 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d55:	89 06                	mov    %eax,(%esi)
	}
}
f0104d57:	83 c4 14             	add    $0x14,%esp
f0104d5a:	5b                   	pop    %ebx
f0104d5b:	5e                   	pop    %esi
f0104d5c:	5f                   	pop    %edi
f0104d5d:	5d                   	pop    %ebp
f0104d5e:	c3                   	ret    

f0104d5f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d5f:	55                   	push   %ebp
f0104d60:	89 e5                	mov    %esp,%ebp
f0104d62:	57                   	push   %edi
f0104d63:	56                   	push   %esi
f0104d64:	53                   	push   %ebx
f0104d65:	83 ec 3c             	sub    $0x3c,%esp
f0104d68:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d6e:	c7 03 04 7c 10 f0    	movl   $0xf0107c04,(%ebx)
	info->eip_line = 0;
f0104d74:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d7b:	c7 43 08 04 7c 10 f0 	movl   $0xf0107c04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d82:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d89:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d8c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d93:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d99:	0f 87 96 00 00 00    	ja     f0104e35 <debuginfo_eip+0xd6>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104d9f:	e8 67 10 00 00       	call   f0105e0b <cpunum>
f0104da4:	6a 04                	push   $0x4
f0104da6:	6a 10                	push   $0x10
f0104da8:	68 00 00 20 00       	push   $0x200000
f0104dad:	6b c0 74             	imul   $0x74,%eax,%eax
f0104db0:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104db6:	e8 08 e0 ff ff       	call   f0102dc3 <user_mem_check>
f0104dbb:	83 c4 10             	add    $0x10,%esp
f0104dbe:	85 c0                	test   %eax,%eax
f0104dc0:	0f 85 15 02 00 00    	jne    f0104fdb <debuginfo_eip+0x27c>
			return -1;
		stabs = usd->stabs;
f0104dc6:	a1 00 00 20 00       	mov    0x200000,%eax
f0104dcb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104dce:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104dd4:	a1 08 00 20 00       	mov    0x200008,%eax
f0104dd9:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104ddc:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104de2:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104de5:	e8 21 10 00 00       	call   f0105e0b <cpunum>
f0104dea:	6a 04                	push   $0x4
f0104dec:	6a 0c                	push   $0xc
f0104dee:	ff 75 c4             	pushl  -0x3c(%ebp)
f0104df1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df4:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104dfa:	e8 c4 df ff ff       	call   f0102dc3 <user_mem_check>
f0104dff:	83 c4 10             	add    $0x10,%esp
f0104e02:	85 c0                	test   %eax,%eax
f0104e04:	0f 85 d8 01 00 00    	jne    f0104fe2 <debuginfo_eip+0x283>
                        return -1;
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104e0a:	e8 fc 0f 00 00       	call   f0105e0b <cpunum>
f0104e0f:	6a 04                	push   $0x4
f0104e11:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e14:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e17:	29 ca                	sub    %ecx,%edx
f0104e19:	52                   	push   %edx
f0104e1a:	51                   	push   %ecx
f0104e1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1e:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104e24:	e8 9a df ff ff       	call   f0102dc3 <user_mem_check>
f0104e29:	83 c4 10             	add    $0x10,%esp
f0104e2c:	85 c0                	test   %eax,%eax
f0104e2e:	74 1f                	je     f0104e4f <debuginfo_eip+0xf0>
f0104e30:	e9 b4 01 00 00       	jmp    f0104fe9 <debuginfo_eip+0x28a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104e35:	c7 45 bc c8 60 11 f0 	movl   $0xf01160c8,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104e3c:	c7 45 c0 d5 29 11 f0 	movl   $0xf01129d5,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104e43:	bf d4 29 11 f0       	mov    $0xf01129d4,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104e48:	c7 45 c4 b0 81 10 f0 	movl   $0xf01081b0,-0x3c(%ebp)
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e4f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104e52:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0104e55:	0f 83 95 01 00 00    	jae    f0104ff0 <debuginfo_eip+0x291>
f0104e5b:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104e5f:	0f 85 92 01 00 00    	jne    f0104ff7 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e6c:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104e6f:	c1 ff 02             	sar    $0x2,%edi
f0104e72:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104e78:	83 e8 01             	sub    $0x1,%eax
f0104e7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e7e:	83 ec 08             	sub    $0x8,%esp
f0104e81:	56                   	push   %esi
f0104e82:	6a 64                	push   $0x64
f0104e84:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104e87:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e8a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104e8d:	89 f8                	mov    %edi,%eax
f0104e8f:	e8 c9 fd ff ff       	call   f0104c5d <stab_binsearch>
	if (lfile == 0)
f0104e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e97:	83 c4 10             	add    $0x10,%esp
f0104e9a:	85 c0                	test   %eax,%eax
f0104e9c:	0f 84 5c 01 00 00    	je     f0104ffe <debuginfo_eip+0x29f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104ea2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ea8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104eab:	83 ec 08             	sub    $0x8,%esp
f0104eae:	56                   	push   %esi
f0104eaf:	6a 24                	push   $0x24
f0104eb1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104eb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104eb7:	89 f8                	mov    %edi,%eax
f0104eb9:	e8 9f fd ff ff       	call   f0104c5d <stab_binsearch>

	if (lfun <= rfun) {
f0104ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ec1:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104ec4:	83 c4 10             	add    $0x10,%esp
f0104ec7:	39 f8                	cmp    %edi,%eax
f0104ec9:	7f 32                	jg     f0104efd <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ecb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ece:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104ed1:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0104ed4:	8b 11                	mov    (%ecx),%edx
f0104ed6:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104ed9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104edc:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104edf:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0104ee2:	73 09                	jae    f0104eed <debuginfo_eip+0x18e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ee4:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104ee7:	03 55 c0             	add    -0x40(%ebp),%edx
f0104eea:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104eed:	8b 51 08             	mov    0x8(%ecx),%edx
f0104ef0:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ef3:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ef5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ef8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0104efb:	eb 0f                	jmp    f0104f0c <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104efd:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f03:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f09:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104f0c:	83 ec 08             	sub    $0x8,%esp
f0104f0f:	6a 3a                	push   $0x3a
f0104f11:	ff 73 08             	pushl  0x8(%ebx)
f0104f14:	e8 b1 08 00 00       	call   f01057ca <strfind>
f0104f19:	2b 43 08             	sub    0x8(%ebx),%eax
f0104f1c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104f1f:	83 c4 08             	add    $0x8,%esp
f0104f22:	56                   	push   %esi
f0104f23:	6a 44                	push   $0x44
f0104f25:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104f28:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104f2b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104f2e:	89 f0                	mov    %esi,%eax
f0104f30:	e8 28 fd ff ff       	call   f0104c5d <stab_binsearch>
        if(lline <= rline)
f0104f35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f38:	83 c4 10             	add    $0x10,%esp
f0104f3b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104f3e:	0f 8f c1 00 00 00    	jg     f0105005 <debuginfo_eip+0x2a6>
              info->eip_line = stabs[lline].n_desc;
f0104f44:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f47:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104f4c:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f55:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f58:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104f5b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f5e:	eb 06                	jmp    f0104f66 <debuginfo_eip+0x207>
f0104f60:	83 e8 01             	sub    $0x1,%eax
f0104f63:	83 ea 0c             	sub    $0xc,%edx
f0104f66:	39 c7                	cmp    %eax,%edi
f0104f68:	7f 2a                	jg     f0104f94 <debuginfo_eip+0x235>
	       && stabs[lline].n_type != N_SOL
f0104f6a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f6e:	80 f9 84             	cmp    $0x84,%cl
f0104f71:	0f 84 9c 00 00 00    	je     f0105013 <debuginfo_eip+0x2b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f77:	80 f9 64             	cmp    $0x64,%cl
f0104f7a:	75 e4                	jne    f0104f60 <debuginfo_eip+0x201>
f0104f7c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f80:	74 de                	je     f0104f60 <debuginfo_eip+0x201>
f0104f82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f85:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f88:	e9 8c 00 00 00       	jmp    f0105019 <debuginfo_eip+0x2ba>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f8d:	03 55 c0             	add    -0x40(%ebp),%edx
f0104f90:	89 13                	mov    %edx,(%ebx)
f0104f92:	eb 03                	jmp    f0104f97 <debuginfo_eip+0x238>
f0104f94:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f97:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f9a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f9d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104fa2:	39 f2                	cmp    %esi,%edx
f0104fa4:	0f 8d 8b 00 00 00    	jge    f0105035 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
f0104faa:	83 c2 01             	add    $0x1,%edx
f0104fad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104fb0:	89 d0                	mov    %edx,%eax
f0104fb2:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104fb5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104fb8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104fbb:	eb 04                	jmp    f0104fc1 <debuginfo_eip+0x262>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104fbd:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104fc1:	39 c6                	cmp    %eax,%esi
f0104fc3:	7e 47                	jle    f010500c <debuginfo_eip+0x2ad>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104fc5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104fc9:	83 c0 01             	add    $0x1,%eax
f0104fcc:	83 c2 0c             	add    $0xc,%edx
f0104fcf:	80 f9 a0             	cmp    $0xa0,%cl
f0104fd2:	74 e9                	je     f0104fbd <debuginfo_eip+0x25e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fd4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fd9:	eb 5a                	jmp    f0105035 <debuginfo_eip+0x2d6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fe0:	eb 53                	jmp    f0105035 <debuginfo_eip+0x2d6>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
                        return -1;
f0104fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fe7:	eb 4c                	jmp    f0105035 <debuginfo_eip+0x2d6>
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
f0104fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fee:	eb 45                	jmp    f0105035 <debuginfo_eip+0x2d6>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ff5:	eb 3e                	jmp    f0105035 <debuginfo_eip+0x2d6>
f0104ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ffc:	eb 37                	jmp    f0105035 <debuginfo_eip+0x2d6>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105003:	eb 30                	jmp    f0105035 <debuginfo_eip+0x2d6>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0105005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010500a:	eb 29                	jmp    f0105035 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010500c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105011:	eb 22                	jmp    f0105035 <debuginfo_eip+0x2d6>
f0105013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105016:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105019:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010501c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010501f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105022:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105025:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105028:	39 c2                	cmp    %eax,%edx
f010502a:	0f 82 5d ff ff ff    	jb     f0104f8d <debuginfo_eip+0x22e>
f0105030:	e9 62 ff ff ff       	jmp    f0104f97 <debuginfo_eip+0x238>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0105035:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105038:	5b                   	pop    %ebx
f0105039:	5e                   	pop    %esi
f010503a:	5f                   	pop    %edi
f010503b:	5d                   	pop    %ebp
f010503c:	c3                   	ret    

f010503d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010503d:	55                   	push   %ebp
f010503e:	89 e5                	mov    %esp,%ebp
f0105040:	57                   	push   %edi
f0105041:	56                   	push   %esi
f0105042:	53                   	push   %ebx
f0105043:	83 ec 1c             	sub    $0x1c,%esp
f0105046:	89 c7                	mov    %eax,%edi
f0105048:	89 d6                	mov    %edx,%esi
f010504a:	8b 45 08             	mov    0x8(%ebp),%eax
f010504d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105050:	89 d1                	mov    %edx,%ecx
f0105052:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105055:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105058:	8b 45 10             	mov    0x10(%ebp),%eax
f010505b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010505e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105068:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f010506b:	72 05                	jb     f0105072 <printnum+0x35>
f010506d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105070:	77 3e                	ja     f01050b0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105072:	83 ec 0c             	sub    $0xc,%esp
f0105075:	ff 75 18             	pushl  0x18(%ebp)
f0105078:	83 eb 01             	sub    $0x1,%ebx
f010507b:	53                   	push   %ebx
f010507c:	50                   	push   %eax
f010507d:	83 ec 08             	sub    $0x8,%esp
f0105080:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105083:	ff 75 e0             	pushl  -0x20(%ebp)
f0105086:	ff 75 dc             	pushl  -0x24(%ebp)
f0105089:	ff 75 d8             	pushl  -0x28(%ebp)
f010508c:	e8 6f 11 00 00       	call   f0106200 <__udivdi3>
f0105091:	83 c4 18             	add    $0x18,%esp
f0105094:	52                   	push   %edx
f0105095:	50                   	push   %eax
f0105096:	89 f2                	mov    %esi,%edx
f0105098:	89 f8                	mov    %edi,%eax
f010509a:	e8 9e ff ff ff       	call   f010503d <printnum>
f010509f:	83 c4 20             	add    $0x20,%esp
f01050a2:	eb 13                	jmp    f01050b7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050a4:	83 ec 08             	sub    $0x8,%esp
f01050a7:	56                   	push   %esi
f01050a8:	ff 75 18             	pushl  0x18(%ebp)
f01050ab:	ff d7                	call   *%edi
f01050ad:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01050b0:	83 eb 01             	sub    $0x1,%ebx
f01050b3:	85 db                	test   %ebx,%ebx
f01050b5:	7f ed                	jg     f01050a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050b7:	83 ec 08             	sub    $0x8,%esp
f01050ba:	56                   	push   %esi
f01050bb:	83 ec 04             	sub    $0x4,%esp
f01050be:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050c1:	ff 75 e0             	pushl  -0x20(%ebp)
f01050c4:	ff 75 dc             	pushl  -0x24(%ebp)
f01050c7:	ff 75 d8             	pushl  -0x28(%ebp)
f01050ca:	e8 61 12 00 00       	call   f0106330 <__umoddi3>
f01050cf:	83 c4 14             	add    $0x14,%esp
f01050d2:	0f be 80 0e 7c 10 f0 	movsbl -0xfef83f2(%eax),%eax
f01050d9:	50                   	push   %eax
f01050da:	ff d7                	call   *%edi
f01050dc:	83 c4 10             	add    $0x10,%esp
}
f01050df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050e2:	5b                   	pop    %ebx
f01050e3:	5e                   	pop    %esi
f01050e4:	5f                   	pop    %edi
f01050e5:	5d                   	pop    %ebp
f01050e6:	c3                   	ret    

f01050e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01050e7:	55                   	push   %ebp
f01050e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01050ea:	83 fa 01             	cmp    $0x1,%edx
f01050ed:	7e 0e                	jle    f01050fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01050ef:	8b 10                	mov    (%eax),%edx
f01050f1:	8d 4a 08             	lea    0x8(%edx),%ecx
f01050f4:	89 08                	mov    %ecx,(%eax)
f01050f6:	8b 02                	mov    (%edx),%eax
f01050f8:	8b 52 04             	mov    0x4(%edx),%edx
f01050fb:	eb 22                	jmp    f010511f <getuint+0x38>
	else if (lflag)
f01050fd:	85 d2                	test   %edx,%edx
f01050ff:	74 10                	je     f0105111 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105101:	8b 10                	mov    (%eax),%edx
f0105103:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105106:	89 08                	mov    %ecx,(%eax)
f0105108:	8b 02                	mov    (%edx),%eax
f010510a:	ba 00 00 00 00       	mov    $0x0,%edx
f010510f:	eb 0e                	jmp    f010511f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105111:	8b 10                	mov    (%eax),%edx
f0105113:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105116:	89 08                	mov    %ecx,(%eax)
f0105118:	8b 02                	mov    (%edx),%eax
f010511a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010511f:	5d                   	pop    %ebp
f0105120:	c3                   	ret    

f0105121 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105121:	55                   	push   %ebp
f0105122:	89 e5                	mov    %esp,%ebp
f0105124:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105127:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010512b:	8b 10                	mov    (%eax),%edx
f010512d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105130:	73 0a                	jae    f010513c <sprintputch+0x1b>
		*b->buf++ = ch;
f0105132:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105135:	89 08                	mov    %ecx,(%eax)
f0105137:	8b 45 08             	mov    0x8(%ebp),%eax
f010513a:	88 02                	mov    %al,(%edx)
}
f010513c:	5d                   	pop    %ebp
f010513d:	c3                   	ret    

f010513e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010513e:	55                   	push   %ebp
f010513f:	89 e5                	mov    %esp,%ebp
f0105141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105144:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105147:	50                   	push   %eax
f0105148:	ff 75 10             	pushl  0x10(%ebp)
f010514b:	ff 75 0c             	pushl  0xc(%ebp)
f010514e:	ff 75 08             	pushl  0x8(%ebp)
f0105151:	e8 05 00 00 00       	call   f010515b <vprintfmt>
	va_end(ap);
f0105156:	83 c4 10             	add    $0x10,%esp
}
f0105159:	c9                   	leave  
f010515a:	c3                   	ret    

f010515b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010515b:	55                   	push   %ebp
f010515c:	89 e5                	mov    %esp,%ebp
f010515e:	57                   	push   %edi
f010515f:	56                   	push   %esi
f0105160:	53                   	push   %ebx
f0105161:	83 ec 2c             	sub    $0x2c,%esp
f0105164:	8b 75 08             	mov    0x8(%ebp),%esi
f0105167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010516a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010516d:	eb 12                	jmp    f0105181 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010516f:	85 c0                	test   %eax,%eax
f0105171:	0f 84 90 03 00 00    	je     f0105507 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0105177:	83 ec 08             	sub    $0x8,%esp
f010517a:	53                   	push   %ebx
f010517b:	50                   	push   %eax
f010517c:	ff d6                	call   *%esi
f010517e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105181:	83 c7 01             	add    $0x1,%edi
f0105184:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105188:	83 f8 25             	cmp    $0x25,%eax
f010518b:	75 e2                	jne    f010516f <vprintfmt+0x14>
f010518d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105191:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105198:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010519f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01051a6:	ba 00 00 00 00       	mov    $0x0,%edx
f01051ab:	eb 07                	jmp    f01051b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01051b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b4:	8d 47 01             	lea    0x1(%edi),%eax
f01051b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051ba:	0f b6 07             	movzbl (%edi),%eax
f01051bd:	0f b6 c8             	movzbl %al,%ecx
f01051c0:	83 e8 23             	sub    $0x23,%eax
f01051c3:	3c 55                	cmp    $0x55,%al
f01051c5:	0f 87 21 03 00 00    	ja     f01054ec <vprintfmt+0x391>
f01051cb:	0f b6 c0             	movzbl %al,%eax
f01051ce:	ff 24 85 40 7d 10 f0 	jmp    *-0xfef82c0(,%eax,4)
f01051d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01051d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01051dc:	eb d6                	jmp    f01051b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01051e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01051e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01051ec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01051f0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01051f3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01051f6:	83 fa 09             	cmp    $0x9,%edx
f01051f9:	77 39                	ja     f0105234 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01051fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01051fe:	eb e9                	jmp    f01051e9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105200:	8b 45 14             	mov    0x14(%ebp),%eax
f0105203:	8d 48 04             	lea    0x4(%eax),%ecx
f0105206:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105209:	8b 00                	mov    (%eax),%eax
f010520b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010520e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105211:	eb 27                	jmp    f010523a <vprintfmt+0xdf>
f0105213:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105216:	85 c0                	test   %eax,%eax
f0105218:	b9 00 00 00 00       	mov    $0x0,%ecx
f010521d:	0f 49 c8             	cmovns %eax,%ecx
f0105220:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105223:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105226:	eb 8c                	jmp    f01051b4 <vprintfmt+0x59>
f0105228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010522b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105232:	eb 80                	jmp    f01051b4 <vprintfmt+0x59>
f0105234:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105237:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010523a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010523e:	0f 89 70 ff ff ff    	jns    f01051b4 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105244:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105247:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010524a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105251:	e9 5e ff ff ff       	jmp    f01051b4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105256:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105259:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010525c:	e9 53 ff ff ff       	jmp    f01051b4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105261:	8b 45 14             	mov    0x14(%ebp),%eax
f0105264:	8d 50 04             	lea    0x4(%eax),%edx
f0105267:	89 55 14             	mov    %edx,0x14(%ebp)
f010526a:	83 ec 08             	sub    $0x8,%esp
f010526d:	53                   	push   %ebx
f010526e:	ff 30                	pushl  (%eax)
f0105270:	ff d6                	call   *%esi
			break;
f0105272:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105278:	e9 04 ff ff ff       	jmp    f0105181 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010527d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105280:	8d 50 04             	lea    0x4(%eax),%edx
f0105283:	89 55 14             	mov    %edx,0x14(%ebp)
f0105286:	8b 00                	mov    (%eax),%eax
f0105288:	99                   	cltd   
f0105289:	31 d0                	xor    %edx,%eax
f010528b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010528d:	83 f8 0f             	cmp    $0xf,%eax
f0105290:	7f 0b                	jg     f010529d <vprintfmt+0x142>
f0105292:	8b 14 85 c0 7e 10 f0 	mov    -0xfef8140(,%eax,4),%edx
f0105299:	85 d2                	test   %edx,%edx
f010529b:	75 18                	jne    f01052b5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010529d:	50                   	push   %eax
f010529e:	68 26 7c 10 f0       	push   $0xf0107c26
f01052a3:	53                   	push   %ebx
f01052a4:	56                   	push   %esi
f01052a5:	e8 94 fe ff ff       	call   f010513e <printfmt>
f01052aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01052b0:	e9 cc fe ff ff       	jmp    f0105181 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01052b5:	52                   	push   %edx
f01052b6:	68 d6 6a 10 f0       	push   $0xf0106ad6
f01052bb:	53                   	push   %ebx
f01052bc:	56                   	push   %esi
f01052bd:	e8 7c fe ff ff       	call   f010513e <printfmt>
f01052c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052c8:	e9 b4 fe ff ff       	jmp    f0105181 <vprintfmt+0x26>
f01052cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01052d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d9:	8d 50 04             	lea    0x4(%eax),%edx
f01052dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01052df:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01052e1:	85 ff                	test   %edi,%edi
f01052e3:	ba 1f 7c 10 f0       	mov    $0xf0107c1f,%edx
f01052e8:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f01052eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01052ef:	0f 84 92 00 00 00    	je     f0105387 <vprintfmt+0x22c>
f01052f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01052f9:	0f 8e 96 00 00 00    	jle    f0105395 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052ff:	83 ec 08             	sub    $0x8,%esp
f0105302:	51                   	push   %ecx
f0105303:	57                   	push   %edi
f0105304:	e8 77 03 00 00       	call   f0105680 <strnlen>
f0105309:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010530c:	29 c1                	sub    %eax,%ecx
f010530e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105311:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105314:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105318:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010531b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010531e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105320:	eb 0f                	jmp    f0105331 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105322:	83 ec 08             	sub    $0x8,%esp
f0105325:	53                   	push   %ebx
f0105326:	ff 75 e0             	pushl  -0x20(%ebp)
f0105329:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010532b:	83 ef 01             	sub    $0x1,%edi
f010532e:	83 c4 10             	add    $0x10,%esp
f0105331:	85 ff                	test   %edi,%edi
f0105333:	7f ed                	jg     f0105322 <vprintfmt+0x1c7>
f0105335:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105338:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010533b:	85 c9                	test   %ecx,%ecx
f010533d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105342:	0f 49 c1             	cmovns %ecx,%eax
f0105345:	29 c1                	sub    %eax,%ecx
f0105347:	89 75 08             	mov    %esi,0x8(%ebp)
f010534a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010534d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105350:	89 cb                	mov    %ecx,%ebx
f0105352:	eb 4d                	jmp    f01053a1 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105354:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105358:	74 1b                	je     f0105375 <vprintfmt+0x21a>
f010535a:	0f be c0             	movsbl %al,%eax
f010535d:	83 e8 20             	sub    $0x20,%eax
f0105360:	83 f8 5e             	cmp    $0x5e,%eax
f0105363:	76 10                	jbe    f0105375 <vprintfmt+0x21a>
					putch('?', putdat);
f0105365:	83 ec 08             	sub    $0x8,%esp
f0105368:	ff 75 0c             	pushl  0xc(%ebp)
f010536b:	6a 3f                	push   $0x3f
f010536d:	ff 55 08             	call   *0x8(%ebp)
f0105370:	83 c4 10             	add    $0x10,%esp
f0105373:	eb 0d                	jmp    f0105382 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0105375:	83 ec 08             	sub    $0x8,%esp
f0105378:	ff 75 0c             	pushl  0xc(%ebp)
f010537b:	52                   	push   %edx
f010537c:	ff 55 08             	call   *0x8(%ebp)
f010537f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105382:	83 eb 01             	sub    $0x1,%ebx
f0105385:	eb 1a                	jmp    f01053a1 <vprintfmt+0x246>
f0105387:	89 75 08             	mov    %esi,0x8(%ebp)
f010538a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010538d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105390:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105393:	eb 0c                	jmp    f01053a1 <vprintfmt+0x246>
f0105395:	89 75 08             	mov    %esi,0x8(%ebp)
f0105398:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010539b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010539e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01053a1:	83 c7 01             	add    $0x1,%edi
f01053a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053a8:	0f be d0             	movsbl %al,%edx
f01053ab:	85 d2                	test   %edx,%edx
f01053ad:	74 23                	je     f01053d2 <vprintfmt+0x277>
f01053af:	85 f6                	test   %esi,%esi
f01053b1:	78 a1                	js     f0105354 <vprintfmt+0x1f9>
f01053b3:	83 ee 01             	sub    $0x1,%esi
f01053b6:	79 9c                	jns    f0105354 <vprintfmt+0x1f9>
f01053b8:	89 df                	mov    %ebx,%edi
f01053ba:	8b 75 08             	mov    0x8(%ebp),%esi
f01053bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053c0:	eb 18                	jmp    f01053da <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01053c2:	83 ec 08             	sub    $0x8,%esp
f01053c5:	53                   	push   %ebx
f01053c6:	6a 20                	push   $0x20
f01053c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01053ca:	83 ef 01             	sub    $0x1,%edi
f01053cd:	83 c4 10             	add    $0x10,%esp
f01053d0:	eb 08                	jmp    f01053da <vprintfmt+0x27f>
f01053d2:	89 df                	mov    %ebx,%edi
f01053d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01053d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053da:	85 ff                	test   %edi,%edi
f01053dc:	7f e4                	jg     f01053c2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053e1:	e9 9b fd ff ff       	jmp    f0105181 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053e6:	83 fa 01             	cmp    $0x1,%edx
f01053e9:	7e 16                	jle    f0105401 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f01053eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ee:	8d 50 08             	lea    0x8(%eax),%edx
f01053f1:	89 55 14             	mov    %edx,0x14(%ebp)
f01053f4:	8b 50 04             	mov    0x4(%eax),%edx
f01053f7:	8b 00                	mov    (%eax),%eax
f01053f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053ff:	eb 32                	jmp    f0105433 <vprintfmt+0x2d8>
	else if (lflag)
f0105401:	85 d2                	test   %edx,%edx
f0105403:	74 18                	je     f010541d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f0105405:	8b 45 14             	mov    0x14(%ebp),%eax
f0105408:	8d 50 04             	lea    0x4(%eax),%edx
f010540b:	89 55 14             	mov    %edx,0x14(%ebp)
f010540e:	8b 00                	mov    (%eax),%eax
f0105410:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105413:	89 c1                	mov    %eax,%ecx
f0105415:	c1 f9 1f             	sar    $0x1f,%ecx
f0105418:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010541b:	eb 16                	jmp    f0105433 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f010541d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105420:	8d 50 04             	lea    0x4(%eax),%edx
f0105423:	89 55 14             	mov    %edx,0x14(%ebp)
f0105426:	8b 00                	mov    (%eax),%eax
f0105428:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010542b:	89 c1                	mov    %eax,%ecx
f010542d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105430:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105433:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105436:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105439:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010543e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105442:	79 74                	jns    f01054b8 <vprintfmt+0x35d>
				putch('-', putdat);
f0105444:	83 ec 08             	sub    $0x8,%esp
f0105447:	53                   	push   %ebx
f0105448:	6a 2d                	push   $0x2d
f010544a:	ff d6                	call   *%esi
				num = -(long long) num;
f010544c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010544f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105452:	f7 d8                	neg    %eax
f0105454:	83 d2 00             	adc    $0x0,%edx
f0105457:	f7 da                	neg    %edx
f0105459:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010545c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105461:	eb 55                	jmp    f01054b8 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105463:	8d 45 14             	lea    0x14(%ebp),%eax
f0105466:	e8 7c fc ff ff       	call   f01050e7 <getuint>
			base = 10;
f010546b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105470:	eb 46                	jmp    f01054b8 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105472:	8d 45 14             	lea    0x14(%ebp),%eax
f0105475:	e8 6d fc ff ff       	call   f01050e7 <getuint>
                        base = 8;
f010547a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f010547f:	eb 37                	jmp    f01054b8 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f0105481:	83 ec 08             	sub    $0x8,%esp
f0105484:	53                   	push   %ebx
f0105485:	6a 30                	push   $0x30
f0105487:	ff d6                	call   *%esi
			putch('x', putdat);
f0105489:	83 c4 08             	add    $0x8,%esp
f010548c:	53                   	push   %ebx
f010548d:	6a 78                	push   $0x78
f010548f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105491:	8b 45 14             	mov    0x14(%ebp),%eax
f0105494:	8d 50 04             	lea    0x4(%eax),%edx
f0105497:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010549a:	8b 00                	mov    (%eax),%eax
f010549c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01054a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01054a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01054a9:	eb 0d                	jmp    f01054b8 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01054ab:	8d 45 14             	lea    0x14(%ebp),%eax
f01054ae:	e8 34 fc ff ff       	call   f01050e7 <getuint>
			base = 16;
f01054b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01054b8:	83 ec 0c             	sub    $0xc,%esp
f01054bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01054bf:	57                   	push   %edi
f01054c0:	ff 75 e0             	pushl  -0x20(%ebp)
f01054c3:	51                   	push   %ecx
f01054c4:	52                   	push   %edx
f01054c5:	50                   	push   %eax
f01054c6:	89 da                	mov    %ebx,%edx
f01054c8:	89 f0                	mov    %esi,%eax
f01054ca:	e8 6e fb ff ff       	call   f010503d <printnum>
			break;
f01054cf:	83 c4 20             	add    $0x20,%esp
f01054d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054d5:	e9 a7 fc ff ff       	jmp    f0105181 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01054da:	83 ec 08             	sub    $0x8,%esp
f01054dd:	53                   	push   %ebx
f01054de:	51                   	push   %ecx
f01054df:	ff d6                	call   *%esi
			break;
f01054e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01054e7:	e9 95 fc ff ff       	jmp    f0105181 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01054ec:	83 ec 08             	sub    $0x8,%esp
f01054ef:	53                   	push   %ebx
f01054f0:	6a 25                	push   $0x25
f01054f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054f4:	83 c4 10             	add    $0x10,%esp
f01054f7:	eb 03                	jmp    f01054fc <vprintfmt+0x3a1>
f01054f9:	83 ef 01             	sub    $0x1,%edi
f01054fc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105500:	75 f7                	jne    f01054f9 <vprintfmt+0x39e>
f0105502:	e9 7a fc ff ff       	jmp    f0105181 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105507:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010550a:	5b                   	pop    %ebx
f010550b:	5e                   	pop    %esi
f010550c:	5f                   	pop    %edi
f010550d:	5d                   	pop    %ebp
f010550e:	c3                   	ret    

f010550f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010550f:	55                   	push   %ebp
f0105510:	89 e5                	mov    %esp,%ebp
f0105512:	83 ec 18             	sub    $0x18,%esp
f0105515:	8b 45 08             	mov    0x8(%ebp),%eax
f0105518:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010551b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010551e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105522:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105525:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010552c:	85 c0                	test   %eax,%eax
f010552e:	74 26                	je     f0105556 <vsnprintf+0x47>
f0105530:	85 d2                	test   %edx,%edx
f0105532:	7e 22                	jle    f0105556 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105534:	ff 75 14             	pushl  0x14(%ebp)
f0105537:	ff 75 10             	pushl  0x10(%ebp)
f010553a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010553d:	50                   	push   %eax
f010553e:	68 21 51 10 f0       	push   $0xf0105121
f0105543:	e8 13 fc ff ff       	call   f010515b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105548:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010554b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010554e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105551:	83 c4 10             	add    $0x10,%esp
f0105554:	eb 05                	jmp    f010555b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105556:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010555b:	c9                   	leave  
f010555c:	c3                   	ret    

f010555d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010555d:	55                   	push   %ebp
f010555e:	89 e5                	mov    %esp,%ebp
f0105560:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105563:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105566:	50                   	push   %eax
f0105567:	ff 75 10             	pushl  0x10(%ebp)
f010556a:	ff 75 0c             	pushl  0xc(%ebp)
f010556d:	ff 75 08             	pushl  0x8(%ebp)
f0105570:	e8 9a ff ff ff       	call   f010550f <vsnprintf>
	va_end(ap);

	return rc;
}
f0105575:	c9                   	leave  
f0105576:	c3                   	ret    

f0105577 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105577:	55                   	push   %ebp
f0105578:	89 e5                	mov    %esp,%ebp
f010557a:	57                   	push   %edi
f010557b:	56                   	push   %esi
f010557c:	53                   	push   %ebx
f010557d:	83 ec 0c             	sub    $0xc,%esp
f0105580:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105583:	85 c0                	test   %eax,%eax
f0105585:	74 11                	je     f0105598 <readline+0x21>
		cprintf("%s", prompt);
f0105587:	83 ec 08             	sub    $0x8,%esp
f010558a:	50                   	push   %eax
f010558b:	68 d6 6a 10 f0       	push   $0xf0106ad6
f0105590:	e8 8b e1 ff ff       	call   f0103720 <cprintf>
f0105595:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105598:	83 ec 0c             	sub    $0xc,%esp
f010559b:	6a 00                	push   $0x0
f010559d:	e8 f9 b1 ff ff       	call   f010079b <iscons>
f01055a2:	89 c7                	mov    %eax,%edi
f01055a4:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01055a7:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01055ac:	e8 d9 b1 ff ff       	call   f010078a <getchar>
f01055b1:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055b3:	85 c0                	test   %eax,%eax
f01055b5:	79 29                	jns    f01055e0 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055b7:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01055bc:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01055bf:	0f 84 9b 00 00 00    	je     f0105660 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01055c5:	83 ec 08             	sub    $0x8,%esp
f01055c8:	53                   	push   %ebx
f01055c9:	68 1f 7f 10 f0       	push   $0xf0107f1f
f01055ce:	e8 4d e1 ff ff       	call   f0103720 <cprintf>
f01055d3:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055db:	e9 80 00 00 00       	jmp    f0105660 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055e0:	83 f8 7f             	cmp    $0x7f,%eax
f01055e3:	0f 94 c2             	sete   %dl
f01055e6:	83 f8 08             	cmp    $0x8,%eax
f01055e9:	0f 94 c0             	sete   %al
f01055ec:	08 c2                	or     %al,%dl
f01055ee:	74 1a                	je     f010560a <readline+0x93>
f01055f0:	85 f6                	test   %esi,%esi
f01055f2:	7e 16                	jle    f010560a <readline+0x93>
			if (echoing)
f01055f4:	85 ff                	test   %edi,%edi
f01055f6:	74 0d                	je     f0105605 <readline+0x8e>
				cputchar('\b');
f01055f8:	83 ec 0c             	sub    $0xc,%esp
f01055fb:	6a 08                	push   $0x8
f01055fd:	e8 78 b1 ff ff       	call   f010077a <cputchar>
f0105602:	83 c4 10             	add    $0x10,%esp
			i--;
f0105605:	83 ee 01             	sub    $0x1,%esi
f0105608:	eb a2                	jmp    f01055ac <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010560a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105610:	7f 23                	jg     f0105635 <readline+0xbe>
f0105612:	83 fb 1f             	cmp    $0x1f,%ebx
f0105615:	7e 1e                	jle    f0105635 <readline+0xbe>
			if (echoing)
f0105617:	85 ff                	test   %edi,%edi
f0105619:	74 0c                	je     f0105627 <readline+0xb0>
				cputchar(c);
f010561b:	83 ec 0c             	sub    $0xc,%esp
f010561e:	53                   	push   %ebx
f010561f:	e8 56 b1 ff ff       	call   f010077a <cputchar>
f0105624:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105627:	88 9e c0 aa 20 f0    	mov    %bl,-0xfdf5540(%esi)
f010562d:	8d 76 01             	lea    0x1(%esi),%esi
f0105630:	e9 77 ff ff ff       	jmp    f01055ac <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105635:	83 fb 0d             	cmp    $0xd,%ebx
f0105638:	74 09                	je     f0105643 <readline+0xcc>
f010563a:	83 fb 0a             	cmp    $0xa,%ebx
f010563d:	0f 85 69 ff ff ff    	jne    f01055ac <readline+0x35>
			if (echoing)
f0105643:	85 ff                	test   %edi,%edi
f0105645:	74 0d                	je     f0105654 <readline+0xdd>
				cputchar('\n');
f0105647:	83 ec 0c             	sub    $0xc,%esp
f010564a:	6a 0a                	push   $0xa
f010564c:	e8 29 b1 ff ff       	call   f010077a <cputchar>
f0105651:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105654:	c6 86 c0 aa 20 f0 00 	movb   $0x0,-0xfdf5540(%esi)
			return buf;
f010565b:	b8 c0 aa 20 f0       	mov    $0xf020aac0,%eax
		}
	}
}
f0105660:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105663:	5b                   	pop    %ebx
f0105664:	5e                   	pop    %esi
f0105665:	5f                   	pop    %edi
f0105666:	5d                   	pop    %ebp
f0105667:	c3                   	ret    

f0105668 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105668:	55                   	push   %ebp
f0105669:	89 e5                	mov    %esp,%ebp
f010566b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010566e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105673:	eb 03                	jmp    f0105678 <strlen+0x10>
		n++;
f0105675:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105678:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010567c:	75 f7                	jne    f0105675 <strlen+0xd>
		n++;
	return n;
}
f010567e:	5d                   	pop    %ebp
f010567f:	c3                   	ret    

f0105680 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105680:	55                   	push   %ebp
f0105681:	89 e5                	mov    %esp,%ebp
f0105683:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105686:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105689:	ba 00 00 00 00       	mov    $0x0,%edx
f010568e:	eb 03                	jmp    f0105693 <strnlen+0x13>
		n++;
f0105690:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105693:	39 c2                	cmp    %eax,%edx
f0105695:	74 08                	je     f010569f <strnlen+0x1f>
f0105697:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010569b:	75 f3                	jne    f0105690 <strnlen+0x10>
f010569d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010569f:	5d                   	pop    %ebp
f01056a0:	c3                   	ret    

f01056a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056a1:	55                   	push   %ebp
f01056a2:	89 e5                	mov    %esp,%ebp
f01056a4:	53                   	push   %ebx
f01056a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056ab:	89 c2                	mov    %eax,%edx
f01056ad:	83 c2 01             	add    $0x1,%edx
f01056b0:	83 c1 01             	add    $0x1,%ecx
f01056b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01056b7:	88 5a ff             	mov    %bl,-0x1(%edx)
f01056ba:	84 db                	test   %bl,%bl
f01056bc:	75 ef                	jne    f01056ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01056be:	5b                   	pop    %ebx
f01056bf:	5d                   	pop    %ebp
f01056c0:	c3                   	ret    

f01056c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056c1:	55                   	push   %ebp
f01056c2:	89 e5                	mov    %esp,%ebp
f01056c4:	53                   	push   %ebx
f01056c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056c8:	53                   	push   %ebx
f01056c9:	e8 9a ff ff ff       	call   f0105668 <strlen>
f01056ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01056d1:	ff 75 0c             	pushl  0xc(%ebp)
f01056d4:	01 d8                	add    %ebx,%eax
f01056d6:	50                   	push   %eax
f01056d7:	e8 c5 ff ff ff       	call   f01056a1 <strcpy>
	return dst;
}
f01056dc:	89 d8                	mov    %ebx,%eax
f01056de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056e1:	c9                   	leave  
f01056e2:	c3                   	ret    

f01056e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056e3:	55                   	push   %ebp
f01056e4:	89 e5                	mov    %esp,%ebp
f01056e6:	56                   	push   %esi
f01056e7:	53                   	push   %ebx
f01056e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01056eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056ee:	89 f3                	mov    %esi,%ebx
f01056f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056f3:	89 f2                	mov    %esi,%edx
f01056f5:	eb 0f                	jmp    f0105706 <strncpy+0x23>
		*dst++ = *src;
f01056f7:	83 c2 01             	add    $0x1,%edx
f01056fa:	0f b6 01             	movzbl (%ecx),%eax
f01056fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105700:	80 39 01             	cmpb   $0x1,(%ecx)
f0105703:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105706:	39 da                	cmp    %ebx,%edx
f0105708:	75 ed                	jne    f01056f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010570a:	89 f0                	mov    %esi,%eax
f010570c:	5b                   	pop    %ebx
f010570d:	5e                   	pop    %esi
f010570e:	5d                   	pop    %ebp
f010570f:	c3                   	ret    

f0105710 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105710:	55                   	push   %ebp
f0105711:	89 e5                	mov    %esp,%ebp
f0105713:	56                   	push   %esi
f0105714:	53                   	push   %ebx
f0105715:	8b 75 08             	mov    0x8(%ebp),%esi
f0105718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010571b:	8b 55 10             	mov    0x10(%ebp),%edx
f010571e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105720:	85 d2                	test   %edx,%edx
f0105722:	74 21                	je     f0105745 <strlcpy+0x35>
f0105724:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105728:	89 f2                	mov    %esi,%edx
f010572a:	eb 09                	jmp    f0105735 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010572c:	83 c2 01             	add    $0x1,%edx
f010572f:	83 c1 01             	add    $0x1,%ecx
f0105732:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105735:	39 c2                	cmp    %eax,%edx
f0105737:	74 09                	je     f0105742 <strlcpy+0x32>
f0105739:	0f b6 19             	movzbl (%ecx),%ebx
f010573c:	84 db                	test   %bl,%bl
f010573e:	75 ec                	jne    f010572c <strlcpy+0x1c>
f0105740:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105742:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105745:	29 f0                	sub    %esi,%eax
}
f0105747:	5b                   	pop    %ebx
f0105748:	5e                   	pop    %esi
f0105749:	5d                   	pop    %ebp
f010574a:	c3                   	ret    

f010574b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010574b:	55                   	push   %ebp
f010574c:	89 e5                	mov    %esp,%ebp
f010574e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105751:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105754:	eb 06                	jmp    f010575c <strcmp+0x11>
		p++, q++;
f0105756:	83 c1 01             	add    $0x1,%ecx
f0105759:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010575c:	0f b6 01             	movzbl (%ecx),%eax
f010575f:	84 c0                	test   %al,%al
f0105761:	74 04                	je     f0105767 <strcmp+0x1c>
f0105763:	3a 02                	cmp    (%edx),%al
f0105765:	74 ef                	je     f0105756 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105767:	0f b6 c0             	movzbl %al,%eax
f010576a:	0f b6 12             	movzbl (%edx),%edx
f010576d:	29 d0                	sub    %edx,%eax
}
f010576f:	5d                   	pop    %ebp
f0105770:	c3                   	ret    

f0105771 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105771:	55                   	push   %ebp
f0105772:	89 e5                	mov    %esp,%ebp
f0105774:	53                   	push   %ebx
f0105775:	8b 45 08             	mov    0x8(%ebp),%eax
f0105778:	8b 55 0c             	mov    0xc(%ebp),%edx
f010577b:	89 c3                	mov    %eax,%ebx
f010577d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105780:	eb 06                	jmp    f0105788 <strncmp+0x17>
		n--, p++, q++;
f0105782:	83 c0 01             	add    $0x1,%eax
f0105785:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105788:	39 d8                	cmp    %ebx,%eax
f010578a:	74 15                	je     f01057a1 <strncmp+0x30>
f010578c:	0f b6 08             	movzbl (%eax),%ecx
f010578f:	84 c9                	test   %cl,%cl
f0105791:	74 04                	je     f0105797 <strncmp+0x26>
f0105793:	3a 0a                	cmp    (%edx),%cl
f0105795:	74 eb                	je     f0105782 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105797:	0f b6 00             	movzbl (%eax),%eax
f010579a:	0f b6 12             	movzbl (%edx),%edx
f010579d:	29 d0                	sub    %edx,%eax
f010579f:	eb 05                	jmp    f01057a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01057a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01057a6:	5b                   	pop    %ebx
f01057a7:	5d                   	pop    %ebp
f01057a8:	c3                   	ret    

f01057a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01057a9:	55                   	push   %ebp
f01057aa:	89 e5                	mov    %esp,%ebp
f01057ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01057af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057b3:	eb 07                	jmp    f01057bc <strchr+0x13>
		if (*s == c)
f01057b5:	38 ca                	cmp    %cl,%dl
f01057b7:	74 0f                	je     f01057c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01057b9:	83 c0 01             	add    $0x1,%eax
f01057bc:	0f b6 10             	movzbl (%eax),%edx
f01057bf:	84 d2                	test   %dl,%dl
f01057c1:	75 f2                	jne    f01057b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01057c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057c8:	5d                   	pop    %ebp
f01057c9:	c3                   	ret    

f01057ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057ca:	55                   	push   %ebp
f01057cb:	89 e5                	mov    %esp,%ebp
f01057cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057d4:	eb 03                	jmp    f01057d9 <strfind+0xf>
f01057d6:	83 c0 01             	add    $0x1,%eax
f01057d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01057dc:	84 d2                	test   %dl,%dl
f01057de:	74 04                	je     f01057e4 <strfind+0x1a>
f01057e0:	38 ca                	cmp    %cl,%dl
f01057e2:	75 f2                	jne    f01057d6 <strfind+0xc>
			break;
	return (char *) s;
}
f01057e4:	5d                   	pop    %ebp
f01057e5:	c3                   	ret    

f01057e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057e6:	55                   	push   %ebp
f01057e7:	89 e5                	mov    %esp,%ebp
f01057e9:	57                   	push   %edi
f01057ea:	56                   	push   %esi
f01057eb:	53                   	push   %ebx
f01057ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057f2:	85 c9                	test   %ecx,%ecx
f01057f4:	74 36                	je     f010582c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057fc:	75 28                	jne    f0105826 <memset+0x40>
f01057fe:	f6 c1 03             	test   $0x3,%cl
f0105801:	75 23                	jne    f0105826 <memset+0x40>
		c &= 0xFF;
f0105803:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105807:	89 d3                	mov    %edx,%ebx
f0105809:	c1 e3 08             	shl    $0x8,%ebx
f010580c:	89 d6                	mov    %edx,%esi
f010580e:	c1 e6 18             	shl    $0x18,%esi
f0105811:	89 d0                	mov    %edx,%eax
f0105813:	c1 e0 10             	shl    $0x10,%eax
f0105816:	09 f0                	or     %esi,%eax
f0105818:	09 c2                	or     %eax,%edx
f010581a:	89 d0                	mov    %edx,%eax
f010581c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010581e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105821:	fc                   	cld    
f0105822:	f3 ab                	rep stos %eax,%es:(%edi)
f0105824:	eb 06                	jmp    f010582c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105826:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105829:	fc                   	cld    
f010582a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010582c:	89 f8                	mov    %edi,%eax
f010582e:	5b                   	pop    %ebx
f010582f:	5e                   	pop    %esi
f0105830:	5f                   	pop    %edi
f0105831:	5d                   	pop    %ebp
f0105832:	c3                   	ret    

f0105833 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105833:	55                   	push   %ebp
f0105834:	89 e5                	mov    %esp,%ebp
f0105836:	57                   	push   %edi
f0105837:	56                   	push   %esi
f0105838:	8b 45 08             	mov    0x8(%ebp),%eax
f010583b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010583e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105841:	39 c6                	cmp    %eax,%esi
f0105843:	73 35                	jae    f010587a <memmove+0x47>
f0105845:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105848:	39 d0                	cmp    %edx,%eax
f010584a:	73 2e                	jae    f010587a <memmove+0x47>
		s += n;
		d += n;
f010584c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010584f:	89 d6                	mov    %edx,%esi
f0105851:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105853:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105859:	75 13                	jne    f010586e <memmove+0x3b>
f010585b:	f6 c1 03             	test   $0x3,%cl
f010585e:	75 0e                	jne    f010586e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105860:	83 ef 04             	sub    $0x4,%edi
f0105863:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105866:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105869:	fd                   	std    
f010586a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010586c:	eb 09                	jmp    f0105877 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010586e:	83 ef 01             	sub    $0x1,%edi
f0105871:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105874:	fd                   	std    
f0105875:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105877:	fc                   	cld    
f0105878:	eb 1d                	jmp    f0105897 <memmove+0x64>
f010587a:	89 f2                	mov    %esi,%edx
f010587c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010587e:	f6 c2 03             	test   $0x3,%dl
f0105881:	75 0f                	jne    f0105892 <memmove+0x5f>
f0105883:	f6 c1 03             	test   $0x3,%cl
f0105886:	75 0a                	jne    f0105892 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105888:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010588b:	89 c7                	mov    %eax,%edi
f010588d:	fc                   	cld    
f010588e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105890:	eb 05                	jmp    f0105897 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105892:	89 c7                	mov    %eax,%edi
f0105894:	fc                   	cld    
f0105895:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105897:	5e                   	pop    %esi
f0105898:	5f                   	pop    %edi
f0105899:	5d                   	pop    %ebp
f010589a:	c3                   	ret    

f010589b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010589b:	55                   	push   %ebp
f010589c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010589e:	ff 75 10             	pushl  0x10(%ebp)
f01058a1:	ff 75 0c             	pushl  0xc(%ebp)
f01058a4:	ff 75 08             	pushl  0x8(%ebp)
f01058a7:	e8 87 ff ff ff       	call   f0105833 <memmove>
}
f01058ac:	c9                   	leave  
f01058ad:	c3                   	ret    

f01058ae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058ae:	55                   	push   %ebp
f01058af:	89 e5                	mov    %esp,%ebp
f01058b1:	56                   	push   %esi
f01058b2:	53                   	push   %ebx
f01058b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058b9:	89 c6                	mov    %eax,%esi
f01058bb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058be:	eb 1a                	jmp    f01058da <memcmp+0x2c>
		if (*s1 != *s2)
f01058c0:	0f b6 08             	movzbl (%eax),%ecx
f01058c3:	0f b6 1a             	movzbl (%edx),%ebx
f01058c6:	38 d9                	cmp    %bl,%cl
f01058c8:	74 0a                	je     f01058d4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01058ca:	0f b6 c1             	movzbl %cl,%eax
f01058cd:	0f b6 db             	movzbl %bl,%ebx
f01058d0:	29 d8                	sub    %ebx,%eax
f01058d2:	eb 0f                	jmp    f01058e3 <memcmp+0x35>
		s1++, s2++;
f01058d4:	83 c0 01             	add    $0x1,%eax
f01058d7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058da:	39 f0                	cmp    %esi,%eax
f01058dc:	75 e2                	jne    f01058c0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01058de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058e3:	5b                   	pop    %ebx
f01058e4:	5e                   	pop    %esi
f01058e5:	5d                   	pop    %ebp
f01058e6:	c3                   	ret    

f01058e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058e7:	55                   	push   %ebp
f01058e8:	89 e5                	mov    %esp,%ebp
f01058ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01058f0:	89 c2                	mov    %eax,%edx
f01058f2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058f5:	eb 07                	jmp    f01058fe <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058f7:	38 08                	cmp    %cl,(%eax)
f01058f9:	74 07                	je     f0105902 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058fb:	83 c0 01             	add    $0x1,%eax
f01058fe:	39 d0                	cmp    %edx,%eax
f0105900:	72 f5                	jb     f01058f7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105902:	5d                   	pop    %ebp
f0105903:	c3                   	ret    

f0105904 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105904:	55                   	push   %ebp
f0105905:	89 e5                	mov    %esp,%ebp
f0105907:	57                   	push   %edi
f0105908:	56                   	push   %esi
f0105909:	53                   	push   %ebx
f010590a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010590d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105910:	eb 03                	jmp    f0105915 <strtol+0x11>
		s++;
f0105912:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105915:	0f b6 01             	movzbl (%ecx),%eax
f0105918:	3c 09                	cmp    $0x9,%al
f010591a:	74 f6                	je     f0105912 <strtol+0xe>
f010591c:	3c 20                	cmp    $0x20,%al
f010591e:	74 f2                	je     f0105912 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105920:	3c 2b                	cmp    $0x2b,%al
f0105922:	75 0a                	jne    f010592e <strtol+0x2a>
		s++;
f0105924:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105927:	bf 00 00 00 00       	mov    $0x0,%edi
f010592c:	eb 10                	jmp    f010593e <strtol+0x3a>
f010592e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105933:	3c 2d                	cmp    $0x2d,%al
f0105935:	75 07                	jne    f010593e <strtol+0x3a>
		s++, neg = 1;
f0105937:	8d 49 01             	lea    0x1(%ecx),%ecx
f010593a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010593e:	85 db                	test   %ebx,%ebx
f0105940:	0f 94 c0             	sete   %al
f0105943:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105949:	75 19                	jne    f0105964 <strtol+0x60>
f010594b:	80 39 30             	cmpb   $0x30,(%ecx)
f010594e:	75 14                	jne    f0105964 <strtol+0x60>
f0105950:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105954:	0f 85 82 00 00 00    	jne    f01059dc <strtol+0xd8>
		s += 2, base = 16;
f010595a:	83 c1 02             	add    $0x2,%ecx
f010595d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105962:	eb 16                	jmp    f010597a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105964:	84 c0                	test   %al,%al
f0105966:	74 12                	je     f010597a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105968:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010596d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105970:	75 08                	jne    f010597a <strtol+0x76>
		s++, base = 8;
f0105972:	83 c1 01             	add    $0x1,%ecx
f0105975:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010597a:	b8 00 00 00 00       	mov    $0x0,%eax
f010597f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105982:	0f b6 11             	movzbl (%ecx),%edx
f0105985:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105988:	89 f3                	mov    %esi,%ebx
f010598a:	80 fb 09             	cmp    $0x9,%bl
f010598d:	77 08                	ja     f0105997 <strtol+0x93>
			dig = *s - '0';
f010598f:	0f be d2             	movsbl %dl,%edx
f0105992:	83 ea 30             	sub    $0x30,%edx
f0105995:	eb 22                	jmp    f01059b9 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0105997:	8d 72 9f             	lea    -0x61(%edx),%esi
f010599a:	89 f3                	mov    %esi,%ebx
f010599c:	80 fb 19             	cmp    $0x19,%bl
f010599f:	77 08                	ja     f01059a9 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01059a1:	0f be d2             	movsbl %dl,%edx
f01059a4:	83 ea 57             	sub    $0x57,%edx
f01059a7:	eb 10                	jmp    f01059b9 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f01059a9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01059ac:	89 f3                	mov    %esi,%ebx
f01059ae:	80 fb 19             	cmp    $0x19,%bl
f01059b1:	77 16                	ja     f01059c9 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01059b3:	0f be d2             	movsbl %dl,%edx
f01059b6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01059b9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01059bc:	7d 0f                	jge    f01059cd <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f01059be:	83 c1 01             	add    $0x1,%ecx
f01059c1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01059c5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01059c7:	eb b9                	jmp    f0105982 <strtol+0x7e>
f01059c9:	89 c2                	mov    %eax,%edx
f01059cb:	eb 02                	jmp    f01059cf <strtol+0xcb>
f01059cd:	89 c2                	mov    %eax,%edx

	if (endptr)
f01059cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059d3:	74 0d                	je     f01059e2 <strtol+0xde>
		*endptr = (char *) s;
f01059d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059d8:	89 0e                	mov    %ecx,(%esi)
f01059da:	eb 06                	jmp    f01059e2 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01059dc:	84 c0                	test   %al,%al
f01059de:	75 92                	jne    f0105972 <strtol+0x6e>
f01059e0:	eb 98                	jmp    f010597a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01059e2:	f7 da                	neg    %edx
f01059e4:	85 ff                	test   %edi,%edi
f01059e6:	0f 45 c2             	cmovne %edx,%eax
}
f01059e9:	5b                   	pop    %ebx
f01059ea:	5e                   	pop    %esi
f01059eb:	5f                   	pop    %edi
f01059ec:	5d                   	pop    %ebp
f01059ed:	c3                   	ret    
f01059ee:	66 90                	xchg   %ax,%ax

f01059f0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059f0:	fa                   	cli    

	xorw    %ax, %ax
f01059f1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059f3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059f5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059f7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059f9:	0f 01 16             	lgdtl  (%esi)
f01059fc:	74 70                	je     f0105a6e <mpsearch1+0x3>
	movl    %cr0, %eax
f01059fe:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a01:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a05:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a08:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a0e:	08 00                	or     %al,(%eax)

f0105a10 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a10:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a14:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a16:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a18:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a1a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a1e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a20:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a22:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105a27:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a2a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a2d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a32:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a35:	8b 25 c4 ae 20 f0    	mov    0xf020aec4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a3b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a40:	b8 c8 01 10 f0       	mov    $0xf01001c8,%eax
	call    *%eax
f0105a45:	ff d0                	call   *%eax

f0105a47 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a47:	eb fe                	jmp    f0105a47 <spin>
f0105a49:	8d 76 00             	lea    0x0(%esi),%esi

f0105a4c <gdt>:
	...
f0105a54:	ff                   	(bad)  
f0105a55:	ff 00                	incl   (%eax)
f0105a57:	00 00                	add    %al,(%eax)
f0105a59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105a64 <gdtdesc>:
f0105a64:	17                   	pop    %ss
f0105a65:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a6a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a6a:	90                   	nop

f0105a6b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a6b:	55                   	push   %ebp
f0105a6c:	89 e5                	mov    %esp,%ebp
f0105a6e:	57                   	push   %edi
f0105a6f:	56                   	push   %esi
f0105a70:	53                   	push   %ebx
f0105a71:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a74:	8b 0d c8 ae 20 f0    	mov    0xf020aec8,%ecx
f0105a7a:	89 c3                	mov    %eax,%ebx
f0105a7c:	c1 eb 0c             	shr    $0xc,%ebx
f0105a7f:	39 cb                	cmp    %ecx,%ebx
f0105a81:	72 12                	jb     f0105a95 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a83:	50                   	push   %eax
f0105a84:	68 e4 64 10 f0       	push   $0xf01064e4
f0105a89:	6a 57                	push   $0x57
f0105a8b:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a90:	e8 ab a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a95:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a9b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a9d:	89 c2                	mov    %eax,%edx
f0105a9f:	c1 ea 0c             	shr    $0xc,%edx
f0105aa2:	39 d1                	cmp    %edx,%ecx
f0105aa4:	77 12                	ja     f0105ab8 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aa6:	50                   	push   %eax
f0105aa7:	68 e4 64 10 f0       	push   $0xf01064e4
f0105aac:	6a 57                	push   $0x57
f0105aae:	68 bd 80 10 f0       	push   $0xf01080bd
f0105ab3:	e8 88 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ab8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105abe:	eb 2f                	jmp    f0105aef <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ac0:	83 ec 04             	sub    $0x4,%esp
f0105ac3:	6a 04                	push   $0x4
f0105ac5:	68 cd 80 10 f0       	push   $0xf01080cd
f0105aca:	53                   	push   %ebx
f0105acb:	e8 de fd ff ff       	call   f01058ae <memcmp>
f0105ad0:	83 c4 10             	add    $0x10,%esp
f0105ad3:	85 c0                	test   %eax,%eax
f0105ad5:	75 15                	jne    f0105aec <mpsearch1+0x81>
f0105ad7:	89 da                	mov    %ebx,%edx
f0105ad9:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105adc:	0f b6 0a             	movzbl (%edx),%ecx
f0105adf:	01 c8                	add    %ecx,%eax
f0105ae1:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ae4:	39 fa                	cmp    %edi,%edx
f0105ae6:	75 f4                	jne    f0105adc <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ae8:	84 c0                	test   %al,%al
f0105aea:	74 0e                	je     f0105afa <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105aec:	83 c3 10             	add    $0x10,%ebx
f0105aef:	39 f3                	cmp    %esi,%ebx
f0105af1:	72 cd                	jb     f0105ac0 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105af3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105af8:	eb 02                	jmp    f0105afc <mpsearch1+0x91>
f0105afa:	89 d8                	mov    %ebx,%eax
}
f0105afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105aff:	5b                   	pop    %ebx
f0105b00:	5e                   	pop    %esi
f0105b01:	5f                   	pop    %edi
f0105b02:	5d                   	pop    %ebp
f0105b03:	c3                   	ret    

f0105b04 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b04:	55                   	push   %ebp
f0105b05:	89 e5                	mov    %esp,%ebp
f0105b07:	57                   	push   %edi
f0105b08:	56                   	push   %esi
f0105b09:	53                   	push   %ebx
f0105b0a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b0d:	c7 05 e0 b3 20 f0 40 	movl   $0xf020b040,0xf020b3e0
f0105b14:	b0 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b17:	83 3d c8 ae 20 f0 00 	cmpl   $0x0,0xf020aec8
f0105b1e:	75 16                	jne    f0105b36 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b20:	68 00 04 00 00       	push   $0x400
f0105b25:	68 e4 64 10 f0       	push   $0xf01064e4
f0105b2a:	6a 6f                	push   $0x6f
f0105b2c:	68 bd 80 10 f0       	push   $0xf01080bd
f0105b31:	e8 0a a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b36:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b3d:	85 c0                	test   %eax,%eax
f0105b3f:	74 16                	je     f0105b57 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105b41:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b44:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b49:	e8 1d ff ff ff       	call   f0105a6b <mpsearch1>
f0105b4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b51:	85 c0                	test   %eax,%eax
f0105b53:	75 3c                	jne    f0105b91 <mp_init+0x8d>
f0105b55:	eb 20                	jmp    f0105b77 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105b57:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b5e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b61:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b66:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b6b:	e8 fb fe ff ff       	call   f0105a6b <mpsearch1>
f0105b70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b73:	85 c0                	test   %eax,%eax
f0105b75:	75 1a                	jne    f0105b91 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b77:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b7c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b81:	e8 e5 fe ff ff       	call   f0105a6b <mpsearch1>
f0105b86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b89:	85 c0                	test   %eax,%eax
f0105b8b:	0f 84 5a 02 00 00    	je     f0105deb <mp_init+0x2e7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b94:	8b 70 04             	mov    0x4(%eax),%esi
f0105b97:	85 f6                	test   %esi,%esi
f0105b99:	74 06                	je     f0105ba1 <mp_init+0x9d>
f0105b9b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b9f:	74 15                	je     f0105bb6 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105ba1:	83 ec 0c             	sub    $0xc,%esp
f0105ba4:	68 30 7f 10 f0       	push   $0xf0107f30
f0105ba9:	e8 72 db ff ff       	call   f0103720 <cprintf>
f0105bae:	83 c4 10             	add    $0x10,%esp
f0105bb1:	e9 35 02 00 00       	jmp    f0105deb <mp_init+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105bb6:	89 f0                	mov    %esi,%eax
f0105bb8:	c1 e8 0c             	shr    $0xc,%eax
f0105bbb:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f0105bc1:	72 15                	jb     f0105bd8 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bc3:	56                   	push   %esi
f0105bc4:	68 e4 64 10 f0       	push   $0xf01064e4
f0105bc9:	68 90 00 00 00       	push   $0x90
f0105bce:	68 bd 80 10 f0       	push   $0xf01080bd
f0105bd3:	e8 68 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105bd8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105bde:	83 ec 04             	sub    $0x4,%esp
f0105be1:	6a 04                	push   $0x4
f0105be3:	68 d2 80 10 f0       	push   $0xf01080d2
f0105be8:	53                   	push   %ebx
f0105be9:	e8 c0 fc ff ff       	call   f01058ae <memcmp>
f0105bee:	83 c4 10             	add    $0x10,%esp
f0105bf1:	85 c0                	test   %eax,%eax
f0105bf3:	74 15                	je     f0105c0a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105bf5:	83 ec 0c             	sub    $0xc,%esp
f0105bf8:	68 60 7f 10 f0       	push   $0xf0107f60
f0105bfd:	e8 1e db ff ff       	call   f0103720 <cprintf>
f0105c02:	83 c4 10             	add    $0x10,%esp
f0105c05:	e9 e1 01 00 00       	jmp    f0105deb <mp_init+0x2e7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c0a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105c0e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105c12:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c15:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c1f:	eb 0d                	jmp    f0105c2e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105c21:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105c28:	f0 
f0105c29:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c2b:	83 c0 01             	add    $0x1,%eax
f0105c2e:	39 c7                	cmp    %eax,%edi
f0105c30:	75 ef                	jne    f0105c21 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c32:	84 d2                	test   %dl,%dl
f0105c34:	74 15                	je     f0105c4b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c36:	83 ec 0c             	sub    $0xc,%esp
f0105c39:	68 94 7f 10 f0       	push   $0xf0107f94
f0105c3e:	e8 dd da ff ff       	call   f0103720 <cprintf>
f0105c43:	83 c4 10             	add    $0x10,%esp
f0105c46:	e9 a0 01 00 00       	jmp    f0105deb <mp_init+0x2e7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c4b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c4f:	3c 04                	cmp    $0x4,%al
f0105c51:	74 1d                	je     f0105c70 <mp_init+0x16c>
f0105c53:	3c 01                	cmp    $0x1,%al
f0105c55:	74 19                	je     f0105c70 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c57:	83 ec 08             	sub    $0x8,%esp
f0105c5a:	0f b6 c0             	movzbl %al,%eax
f0105c5d:	50                   	push   %eax
f0105c5e:	68 b8 7f 10 f0       	push   $0xf0107fb8
f0105c63:	e8 b8 da ff ff       	call   f0103720 <cprintf>
f0105c68:	83 c4 10             	add    $0x10,%esp
f0105c6b:	e9 7b 01 00 00       	jmp    f0105deb <mp_init+0x2e7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c70:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105c74:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c78:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c82:	01 ce                	add    %ecx,%esi
f0105c84:	eb 0d                	jmp    f0105c93 <mp_init+0x18f>
		sum += ((uint8_t *)addr)[i];
f0105c86:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c8d:	f0 
f0105c8e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c90:	83 c0 01             	add    $0x1,%eax
f0105c93:	39 c7                	cmp    %eax,%edi
f0105c95:	75 ef                	jne    f0105c86 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c97:	89 d0                	mov    %edx,%eax
f0105c99:	02 43 2a             	add    0x2a(%ebx),%al
f0105c9c:	74 15                	je     f0105cb3 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c9e:	83 ec 0c             	sub    $0xc,%esp
f0105ca1:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0105ca6:	e8 75 da ff ff       	call   f0103720 <cprintf>
f0105cab:	83 c4 10             	add    $0x10,%esp
f0105cae:	e9 38 01 00 00       	jmp    f0105deb <mp_init+0x2e7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105cb3:	85 db                	test   %ebx,%ebx
f0105cb5:	0f 84 30 01 00 00    	je     f0105deb <mp_init+0x2e7>
		return;
	ismp = 1;
f0105cbb:	c7 05 00 b0 20 f0 01 	movl   $0x1,0xf020b000
f0105cc2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105cc5:	8b 43 24             	mov    0x24(%ebx),%eax
f0105cc8:	a3 00 c0 24 f0       	mov    %eax,0xf024c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ccd:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105cd0:	be 00 00 00 00       	mov    $0x0,%esi
f0105cd5:	e9 85 00 00 00       	jmp    f0105d5f <mp_init+0x25b>
		switch (*p) {
f0105cda:	0f b6 07             	movzbl (%edi),%eax
f0105cdd:	84 c0                	test   %al,%al
f0105cdf:	74 06                	je     f0105ce7 <mp_init+0x1e3>
f0105ce1:	3c 04                	cmp    $0x4,%al
f0105ce3:	77 55                	ja     f0105d3a <mp_init+0x236>
f0105ce5:	eb 4e                	jmp    f0105d35 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105ce7:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ceb:	74 11                	je     f0105cfe <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ced:	6b 05 e4 b3 20 f0 74 	imul   $0x74,0xf020b3e4,%eax
f0105cf4:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f0105cf9:	a3 e0 b3 20 f0       	mov    %eax,0xf020b3e0
			if (ncpu < NCPU) {
f0105cfe:	a1 e4 b3 20 f0       	mov    0xf020b3e4,%eax
f0105d03:	83 f8 07             	cmp    $0x7,%eax
f0105d06:	7f 13                	jg     f0105d1b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105d08:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d0b:	88 82 40 b0 20 f0    	mov    %al,-0xfdf4fc0(%edx)
				ncpu++;
f0105d11:	83 c0 01             	add    $0x1,%eax
f0105d14:	a3 e4 b3 20 f0       	mov    %eax,0xf020b3e4
f0105d19:	eb 15                	jmp    f0105d30 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d1b:	83 ec 08             	sub    $0x8,%esp
f0105d1e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d22:	50                   	push   %eax
f0105d23:	68 08 80 10 f0       	push   $0xf0108008
f0105d28:	e8 f3 d9 ff ff       	call   f0103720 <cprintf>
f0105d2d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d30:	83 c7 14             	add    $0x14,%edi
			continue;
f0105d33:	eb 27                	jmp    f0105d5c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d35:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d38:	eb 22                	jmp    f0105d5c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d3a:	83 ec 08             	sub    $0x8,%esp
f0105d3d:	0f b6 c0             	movzbl %al,%eax
f0105d40:	50                   	push   %eax
f0105d41:	68 30 80 10 f0       	push   $0xf0108030
f0105d46:	e8 d5 d9 ff ff       	call   f0103720 <cprintf>
			ismp = 0;
f0105d4b:	c7 05 00 b0 20 f0 00 	movl   $0x0,0xf020b000
f0105d52:	00 00 00 
			i = conf->entry;
f0105d55:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105d59:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d5c:	83 c6 01             	add    $0x1,%esi
f0105d5f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d63:	39 c6                	cmp    %eax,%esi
f0105d65:	0f 82 6f ff ff ff    	jb     f0105cda <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d6b:	a1 e0 b3 20 f0       	mov    0xf020b3e0,%eax
f0105d70:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d77:	83 3d 00 b0 20 f0 00 	cmpl   $0x0,0xf020b000
f0105d7e:	75 26                	jne    f0105da6 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d80:	c7 05 e4 b3 20 f0 01 	movl   $0x1,0xf020b3e4
f0105d87:	00 00 00 
		lapicaddr = 0;
f0105d8a:	c7 05 00 c0 24 f0 00 	movl   $0x0,0xf024c000
f0105d91:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d94:	83 ec 0c             	sub    $0xc,%esp
f0105d97:	68 50 80 10 f0       	push   $0xf0108050
f0105d9c:	e8 7f d9 ff ff       	call   f0103720 <cprintf>
		return;
f0105da1:	83 c4 10             	add    $0x10,%esp
f0105da4:	eb 45                	jmp    f0105deb <mp_init+0x2e7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105da6:	83 ec 04             	sub    $0x4,%esp
f0105da9:	ff 35 e4 b3 20 f0    	pushl  0xf020b3e4
f0105daf:	0f b6 00             	movzbl (%eax),%eax
f0105db2:	50                   	push   %eax
f0105db3:	68 d7 80 10 f0       	push   $0xf01080d7
f0105db8:	e8 63 d9 ff ff       	call   f0103720 <cprintf>

	if (mp->imcrp) {
f0105dbd:	83 c4 10             	add    $0x10,%esp
f0105dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dc3:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105dc7:	74 22                	je     f0105deb <mp_init+0x2e7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105dc9:	83 ec 0c             	sub    $0xc,%esp
f0105dcc:	68 7c 80 10 f0       	push   $0xf010807c
f0105dd1:	e8 4a d9 ff ff       	call   f0103720 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dd6:	ba 22 00 00 00       	mov    $0x22,%edx
f0105ddb:	b8 70 00 00 00       	mov    $0x70,%eax
f0105de0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105de1:	b2 23                	mov    $0x23,%dl
f0105de3:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105de4:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105de7:	ee                   	out    %al,(%dx)
f0105de8:	83 c4 10             	add    $0x10,%esp
	}
}
f0105deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105dee:	5b                   	pop    %ebx
f0105def:	5e                   	pop    %esi
f0105df0:	5f                   	pop    %edi
f0105df1:	5d                   	pop    %ebp
f0105df2:	c3                   	ret    

f0105df3 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105df3:	55                   	push   %ebp
f0105df4:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105df6:	8b 0d 04 c0 24 f0    	mov    0xf024c004,%ecx
f0105dfc:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105dff:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e01:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105e06:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e09:	5d                   	pop    %ebp
f0105e0a:	c3                   	ret    

f0105e0b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e0b:	55                   	push   %ebp
f0105e0c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e0e:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105e13:	85 c0                	test   %eax,%eax
f0105e15:	74 08                	je     f0105e1f <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e17:	8b 40 20             	mov    0x20(%eax),%eax
f0105e1a:	c1 e8 18             	shr    $0x18,%eax
f0105e1d:	eb 05                	jmp    f0105e24 <cpunum+0x19>
	return 0;
f0105e1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e24:	5d                   	pop    %ebp
f0105e25:	c3                   	ret    

f0105e26 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105e26:	a1 00 c0 24 f0       	mov    0xf024c000,%eax
f0105e2b:	85 c0                	test   %eax,%eax
f0105e2d:	0f 84 21 01 00 00    	je     f0105f54 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e33:	55                   	push   %ebp
f0105e34:	89 e5                	mov    %esp,%ebp
f0105e36:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e39:	68 00 10 00 00       	push   $0x1000
f0105e3e:	50                   	push   %eax
f0105e3f:	e8 f1 b4 ff ff       	call   f0101335 <mmio_map_region>
f0105e44:	a3 04 c0 24 f0       	mov    %eax,0xf024c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e49:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e4e:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e53:	e8 9b ff ff ff       	call   f0105df3 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e58:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e5d:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e62:	e8 8c ff ff ff       	call   f0105df3 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e67:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e6c:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e71:	e8 7d ff ff ff       	call   f0105df3 <lapicw>
	lapicw(TICR, 10000000); 
f0105e76:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e7b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e80:	e8 6e ff ff ff       	call   f0105df3 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e85:	e8 81 ff ff ff       	call   f0105e0b <cpunum>
f0105e8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e8d:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f0105e92:	83 c4 10             	add    $0x10,%esp
f0105e95:	39 05 e0 b3 20 f0    	cmp    %eax,0xf020b3e0
f0105e9b:	74 0f                	je     f0105eac <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e9d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ea2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105ea7:	e8 47 ff ff ff       	call   f0105df3 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105eac:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eb1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105eb6:	e8 38 ff ff ff       	call   f0105df3 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ebb:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105ec0:	8b 40 30             	mov    0x30(%eax),%eax
f0105ec3:	c1 e8 10             	shr    $0x10,%eax
f0105ec6:	3c 03                	cmp    $0x3,%al
f0105ec8:	76 0f                	jbe    f0105ed9 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105eca:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ecf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105ed4:	e8 1a ff ff ff       	call   f0105df3 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ed9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ede:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ee3:	e8 0b ff ff ff       	call   f0105df3 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ee8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eed:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ef2:	e8 fc fe ff ff       	call   f0105df3 <lapicw>
	lapicw(ESR, 0);
f0105ef7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105efc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f01:	e8 ed fe ff ff       	call   f0105df3 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105f06:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f0b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f10:	e8 de fe ff ff       	call   f0105df3 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105f15:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f1a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f1f:	e8 cf fe ff ff       	call   f0105df3 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f24:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f29:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f2e:	e8 c0 fe ff ff       	call   f0105df3 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f33:	8b 15 04 c0 24 f0    	mov    0xf024c004,%edx
f0105f39:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f3f:	f6 c4 10             	test   $0x10,%ah
f0105f42:	75 f5                	jne    f0105f39 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f44:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f49:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f4e:	e8 a0 fe ff ff       	call   f0105df3 <lapicw>
}
f0105f53:	c9                   	leave  
f0105f54:	f3 c3                	repz ret 

f0105f56 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f56:	83 3d 04 c0 24 f0 00 	cmpl   $0x0,0xf024c004
f0105f5d:	74 13                	je     f0105f72 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f5f:	55                   	push   %ebp
f0105f60:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f62:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f67:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f6c:	e8 82 fe ff ff       	call   f0105df3 <lapicw>
}
f0105f71:	5d                   	pop    %ebp
f0105f72:	f3 c3                	repz ret 

f0105f74 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f74:	55                   	push   %ebp
f0105f75:	89 e5                	mov    %esp,%ebp
f0105f77:	56                   	push   %esi
f0105f78:	53                   	push   %ebx
f0105f79:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f7f:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f84:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f89:	ee                   	out    %al,(%dx)
f0105f8a:	b2 71                	mov    $0x71,%dl
f0105f8c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f91:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f92:	83 3d c8 ae 20 f0 00 	cmpl   $0x0,0xf020aec8
f0105f99:	75 19                	jne    f0105fb4 <lapic_startap+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f9b:	68 67 04 00 00       	push   $0x467
f0105fa0:	68 e4 64 10 f0       	push   $0xf01064e4
f0105fa5:	68 98 00 00 00       	push   $0x98
f0105faa:	68 f4 80 10 f0       	push   $0xf01080f4
f0105faf:	e8 8c a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105fb4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fbb:	00 00 
	wrv[1] = addr >> 4;
f0105fbd:	89 d8                	mov    %ebx,%eax
f0105fbf:	c1 e8 04             	shr    $0x4,%eax
f0105fc2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fc8:	c1 e6 18             	shl    $0x18,%esi
f0105fcb:	89 f2                	mov    %esi,%edx
f0105fcd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fd2:	e8 1c fe ff ff       	call   f0105df3 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fd7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105fdc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fe1:	e8 0d fe ff ff       	call   f0105df3 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fe6:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105feb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ff0:	e8 fe fd ff ff       	call   f0105df3 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ff5:	c1 eb 0c             	shr    $0xc,%ebx
f0105ff8:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ffb:	89 f2                	mov    %esi,%edx
f0105ffd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106002:	e8 ec fd ff ff       	call   f0105df3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106007:	89 da                	mov    %ebx,%edx
f0106009:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010600e:	e8 e0 fd ff ff       	call   f0105df3 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106013:	89 f2                	mov    %esi,%edx
f0106015:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010601a:	e8 d4 fd ff ff       	call   f0105df3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010601f:	89 da                	mov    %ebx,%edx
f0106021:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106026:	e8 c8 fd ff ff       	call   f0105df3 <lapicw>
		microdelay(200);
	}
}
f010602b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010602e:	5b                   	pop    %ebx
f010602f:	5e                   	pop    %esi
f0106030:	5d                   	pop    %ebp
f0106031:	c3                   	ret    

f0106032 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106032:	55                   	push   %ebp
f0106033:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106035:	8b 55 08             	mov    0x8(%ebp),%edx
f0106038:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010603e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106043:	e8 ab fd ff ff       	call   f0105df3 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106048:	8b 15 04 c0 24 f0    	mov    0xf024c004,%edx
f010604e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106054:	f6 c4 10             	test   $0x10,%ah
f0106057:	75 f5                	jne    f010604e <lapic_ipi+0x1c>
		;
}
f0106059:	5d                   	pop    %ebp
f010605a:	c3                   	ret    

f010605b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010605b:	55                   	push   %ebp
f010605c:	89 e5                	mov    %esp,%ebp
f010605e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106061:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106067:	8b 55 0c             	mov    0xc(%ebp),%edx
f010606a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010606d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106074:	5d                   	pop    %ebp
f0106075:	c3                   	ret    

f0106076 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106076:	55                   	push   %ebp
f0106077:	89 e5                	mov    %esp,%ebp
f0106079:	56                   	push   %esi
f010607a:	53                   	push   %ebx
f010607b:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010607e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106081:	74 14                	je     f0106097 <spin_lock+0x21>
f0106083:	8b 73 08             	mov    0x8(%ebx),%esi
f0106086:	e8 80 fd ff ff       	call   f0105e0b <cpunum>
f010608b:	6b c0 74             	imul   $0x74,%eax,%eax
f010608e:	05 40 b0 20 f0       	add    $0xf020b040,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106093:	39 c6                	cmp    %eax,%esi
f0106095:	74 07                	je     f010609e <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106097:	ba 01 00 00 00       	mov    $0x1,%edx
f010609c:	eb 20                	jmp    f01060be <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010609e:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060a1:	e8 65 fd ff ff       	call   f0105e0b <cpunum>
f01060a6:	83 ec 0c             	sub    $0xc,%esp
f01060a9:	53                   	push   %ebx
f01060aa:	50                   	push   %eax
f01060ab:	68 04 81 10 f0       	push   $0xf0108104
f01060b0:	6a 41                	push   $0x41
f01060b2:	68 68 81 10 f0       	push   $0xf0108168
f01060b7:	e8 84 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060bc:	f3 90                	pause  
f01060be:	89 d0                	mov    %edx,%eax
f01060c0:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01060c3:	85 c0                	test   %eax,%eax
f01060c5:	75 f5                	jne    f01060bc <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060c7:	e8 3f fd ff ff       	call   f0105e0b <cpunum>
f01060cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01060cf:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f01060d4:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060d7:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01060da:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01060dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01060e1:	eb 0b                	jmp    f01060ee <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060e3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060e6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060e9:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060eb:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060ee:	83 f8 09             	cmp    $0x9,%eax
f01060f1:	7f 14                	jg     f0106107 <spin_lock+0x91>
f01060f3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060f9:	77 e8                	ja     f01060e3 <spin_lock+0x6d>
f01060fb:	eb 0a                	jmp    f0106107 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01060fd:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106104:	83 c0 01             	add    $0x1,%eax
f0106107:	83 f8 09             	cmp    $0x9,%eax
f010610a:	7e f1                	jle    f01060fd <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010610c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010610f:	5b                   	pop    %ebx
f0106110:	5e                   	pop    %esi
f0106111:	5d                   	pop    %ebp
f0106112:	c3                   	ret    

f0106113 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106113:	55                   	push   %ebp
f0106114:	89 e5                	mov    %esp,%ebp
f0106116:	57                   	push   %edi
f0106117:	56                   	push   %esi
f0106118:	53                   	push   %ebx
f0106119:	83 ec 4c             	sub    $0x4c,%esp
f010611c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010611f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106122:	74 18                	je     f010613c <spin_unlock+0x29>
f0106124:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106127:	e8 df fc ff ff       	call   f0105e0b <cpunum>
f010612c:	6b c0 74             	imul   $0x74,%eax,%eax
f010612f:	05 40 b0 20 f0       	add    $0xf020b040,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106134:	39 c3                	cmp    %eax,%ebx
f0106136:	0f 84 a5 00 00 00    	je     f01061e1 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010613c:	83 ec 04             	sub    $0x4,%esp
f010613f:	6a 28                	push   $0x28
f0106141:	8d 46 0c             	lea    0xc(%esi),%eax
f0106144:	50                   	push   %eax
f0106145:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106148:	53                   	push   %ebx
f0106149:	e8 e5 f6 ff ff       	call   f0105833 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010614e:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106151:	0f b6 38             	movzbl (%eax),%edi
f0106154:	8b 76 04             	mov    0x4(%esi),%esi
f0106157:	e8 af fc ff ff       	call   f0105e0b <cpunum>
f010615c:	57                   	push   %edi
f010615d:	56                   	push   %esi
f010615e:	50                   	push   %eax
f010615f:	68 30 81 10 f0       	push   $0xf0108130
f0106164:	e8 b7 d5 ff ff       	call   f0103720 <cprintf>
f0106169:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010616c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010616f:	eb 54                	jmp    f01061c5 <spin_unlock+0xb2>
f0106171:	83 ec 08             	sub    $0x8,%esp
f0106174:	57                   	push   %edi
f0106175:	50                   	push   %eax
f0106176:	e8 e4 eb ff ff       	call   f0104d5f <debuginfo_eip>
f010617b:	83 c4 10             	add    $0x10,%esp
f010617e:	85 c0                	test   %eax,%eax
f0106180:	78 27                	js     f01061a9 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106182:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106184:	83 ec 04             	sub    $0x4,%esp
f0106187:	89 c2                	mov    %eax,%edx
f0106189:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010618c:	52                   	push   %edx
f010618d:	ff 75 b0             	pushl  -0x50(%ebp)
f0106190:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106193:	ff 75 ac             	pushl  -0x54(%ebp)
f0106196:	ff 75 a8             	pushl  -0x58(%ebp)
f0106199:	50                   	push   %eax
f010619a:	68 78 81 10 f0       	push   $0xf0108178
f010619f:	e8 7c d5 ff ff       	call   f0103720 <cprintf>
f01061a4:	83 c4 20             	add    $0x20,%esp
f01061a7:	eb 12                	jmp    f01061bb <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01061a9:	83 ec 08             	sub    $0x8,%esp
f01061ac:	ff 36                	pushl  (%esi)
f01061ae:	68 8f 81 10 f0       	push   $0xf010818f
f01061b3:	e8 68 d5 ff ff       	call   f0103720 <cprintf>
f01061b8:	83 c4 10             	add    $0x10,%esp
f01061bb:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061be:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01061c1:	39 c3                	cmp    %eax,%ebx
f01061c3:	74 08                	je     f01061cd <spin_unlock+0xba>
f01061c5:	89 de                	mov    %ebx,%esi
f01061c7:	8b 03                	mov    (%ebx),%eax
f01061c9:	85 c0                	test   %eax,%eax
f01061cb:	75 a4                	jne    f0106171 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061cd:	83 ec 04             	sub    $0x4,%esp
f01061d0:	68 97 81 10 f0       	push   $0xf0108197
f01061d5:	6a 67                	push   $0x67
f01061d7:	68 68 81 10 f0       	push   $0xf0108168
f01061dc:	e8 5f 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01061e1:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061e8:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01061ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f4:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01061f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061fa:	5b                   	pop    %ebx
f01061fb:	5e                   	pop    %esi
f01061fc:	5f                   	pop    %edi
f01061fd:	5d                   	pop    %ebp
f01061fe:	c3                   	ret    
f01061ff:	90                   	nop

f0106200 <__udivdi3>:
f0106200:	55                   	push   %ebp
f0106201:	57                   	push   %edi
f0106202:	56                   	push   %esi
f0106203:	83 ec 10             	sub    $0x10,%esp
f0106206:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010620a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010620e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106212:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106216:	85 d2                	test   %edx,%edx
f0106218:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010621c:	89 34 24             	mov    %esi,(%esp)
f010621f:	89 c8                	mov    %ecx,%eax
f0106221:	75 35                	jne    f0106258 <__udivdi3+0x58>
f0106223:	39 f1                	cmp    %esi,%ecx
f0106225:	0f 87 bd 00 00 00    	ja     f01062e8 <__udivdi3+0xe8>
f010622b:	85 c9                	test   %ecx,%ecx
f010622d:	89 cd                	mov    %ecx,%ebp
f010622f:	75 0b                	jne    f010623c <__udivdi3+0x3c>
f0106231:	b8 01 00 00 00       	mov    $0x1,%eax
f0106236:	31 d2                	xor    %edx,%edx
f0106238:	f7 f1                	div    %ecx
f010623a:	89 c5                	mov    %eax,%ebp
f010623c:	89 f0                	mov    %esi,%eax
f010623e:	31 d2                	xor    %edx,%edx
f0106240:	f7 f5                	div    %ebp
f0106242:	89 c6                	mov    %eax,%esi
f0106244:	89 f8                	mov    %edi,%eax
f0106246:	f7 f5                	div    %ebp
f0106248:	89 f2                	mov    %esi,%edx
f010624a:	83 c4 10             	add    $0x10,%esp
f010624d:	5e                   	pop    %esi
f010624e:	5f                   	pop    %edi
f010624f:	5d                   	pop    %ebp
f0106250:	c3                   	ret    
f0106251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106258:	3b 14 24             	cmp    (%esp),%edx
f010625b:	77 7b                	ja     f01062d8 <__udivdi3+0xd8>
f010625d:	0f bd f2             	bsr    %edx,%esi
f0106260:	83 f6 1f             	xor    $0x1f,%esi
f0106263:	0f 84 97 00 00 00    	je     f0106300 <__udivdi3+0x100>
f0106269:	bd 20 00 00 00       	mov    $0x20,%ebp
f010626e:	89 d7                	mov    %edx,%edi
f0106270:	89 f1                	mov    %esi,%ecx
f0106272:	29 f5                	sub    %esi,%ebp
f0106274:	d3 e7                	shl    %cl,%edi
f0106276:	89 c2                	mov    %eax,%edx
f0106278:	89 e9                	mov    %ebp,%ecx
f010627a:	d3 ea                	shr    %cl,%edx
f010627c:	89 f1                	mov    %esi,%ecx
f010627e:	09 fa                	or     %edi,%edx
f0106280:	8b 3c 24             	mov    (%esp),%edi
f0106283:	d3 e0                	shl    %cl,%eax
f0106285:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106289:	89 e9                	mov    %ebp,%ecx
f010628b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010628f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106293:	89 fa                	mov    %edi,%edx
f0106295:	d3 ea                	shr    %cl,%edx
f0106297:	89 f1                	mov    %esi,%ecx
f0106299:	d3 e7                	shl    %cl,%edi
f010629b:	89 e9                	mov    %ebp,%ecx
f010629d:	d3 e8                	shr    %cl,%eax
f010629f:	09 c7                	or     %eax,%edi
f01062a1:	89 f8                	mov    %edi,%eax
f01062a3:	f7 74 24 08          	divl   0x8(%esp)
f01062a7:	89 d5                	mov    %edx,%ebp
f01062a9:	89 c7                	mov    %eax,%edi
f01062ab:	f7 64 24 0c          	mull   0xc(%esp)
f01062af:	39 d5                	cmp    %edx,%ebp
f01062b1:	89 14 24             	mov    %edx,(%esp)
f01062b4:	72 11                	jb     f01062c7 <__udivdi3+0xc7>
f01062b6:	8b 54 24 04          	mov    0x4(%esp),%edx
f01062ba:	89 f1                	mov    %esi,%ecx
f01062bc:	d3 e2                	shl    %cl,%edx
f01062be:	39 c2                	cmp    %eax,%edx
f01062c0:	73 5e                	jae    f0106320 <__udivdi3+0x120>
f01062c2:	3b 2c 24             	cmp    (%esp),%ebp
f01062c5:	75 59                	jne    f0106320 <__udivdi3+0x120>
f01062c7:	8d 47 ff             	lea    -0x1(%edi),%eax
f01062ca:	31 f6                	xor    %esi,%esi
f01062cc:	89 f2                	mov    %esi,%edx
f01062ce:	83 c4 10             	add    $0x10,%esp
f01062d1:	5e                   	pop    %esi
f01062d2:	5f                   	pop    %edi
f01062d3:	5d                   	pop    %ebp
f01062d4:	c3                   	ret    
f01062d5:	8d 76 00             	lea    0x0(%esi),%esi
f01062d8:	31 f6                	xor    %esi,%esi
f01062da:	31 c0                	xor    %eax,%eax
f01062dc:	89 f2                	mov    %esi,%edx
f01062de:	83 c4 10             	add    $0x10,%esp
f01062e1:	5e                   	pop    %esi
f01062e2:	5f                   	pop    %edi
f01062e3:	5d                   	pop    %ebp
f01062e4:	c3                   	ret    
f01062e5:	8d 76 00             	lea    0x0(%esi),%esi
f01062e8:	89 f2                	mov    %esi,%edx
f01062ea:	31 f6                	xor    %esi,%esi
f01062ec:	89 f8                	mov    %edi,%eax
f01062ee:	f7 f1                	div    %ecx
f01062f0:	89 f2                	mov    %esi,%edx
f01062f2:	83 c4 10             	add    $0x10,%esp
f01062f5:	5e                   	pop    %esi
f01062f6:	5f                   	pop    %edi
f01062f7:	5d                   	pop    %ebp
f01062f8:	c3                   	ret    
f01062f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106300:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106304:	76 0b                	jbe    f0106311 <__udivdi3+0x111>
f0106306:	31 c0                	xor    %eax,%eax
f0106308:	3b 14 24             	cmp    (%esp),%edx
f010630b:	0f 83 37 ff ff ff    	jae    f0106248 <__udivdi3+0x48>
f0106311:	b8 01 00 00 00       	mov    $0x1,%eax
f0106316:	e9 2d ff ff ff       	jmp    f0106248 <__udivdi3+0x48>
f010631b:	90                   	nop
f010631c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106320:	89 f8                	mov    %edi,%eax
f0106322:	31 f6                	xor    %esi,%esi
f0106324:	e9 1f ff ff ff       	jmp    f0106248 <__udivdi3+0x48>
f0106329:	66 90                	xchg   %ax,%ax
f010632b:	66 90                	xchg   %ax,%ax
f010632d:	66 90                	xchg   %ax,%ax
f010632f:	90                   	nop

f0106330 <__umoddi3>:
f0106330:	55                   	push   %ebp
f0106331:	57                   	push   %edi
f0106332:	56                   	push   %esi
f0106333:	83 ec 20             	sub    $0x20,%esp
f0106336:	8b 44 24 34          	mov    0x34(%esp),%eax
f010633a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010633e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106342:	89 c6                	mov    %eax,%esi
f0106344:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106348:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010634c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0106350:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106354:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106358:	89 74 24 18          	mov    %esi,0x18(%esp)
f010635c:	85 c0                	test   %eax,%eax
f010635e:	89 c2                	mov    %eax,%edx
f0106360:	75 1e                	jne    f0106380 <__umoddi3+0x50>
f0106362:	39 f7                	cmp    %esi,%edi
f0106364:	76 52                	jbe    f01063b8 <__umoddi3+0x88>
f0106366:	89 c8                	mov    %ecx,%eax
f0106368:	89 f2                	mov    %esi,%edx
f010636a:	f7 f7                	div    %edi
f010636c:	89 d0                	mov    %edx,%eax
f010636e:	31 d2                	xor    %edx,%edx
f0106370:	83 c4 20             	add    $0x20,%esp
f0106373:	5e                   	pop    %esi
f0106374:	5f                   	pop    %edi
f0106375:	5d                   	pop    %ebp
f0106376:	c3                   	ret    
f0106377:	89 f6                	mov    %esi,%esi
f0106379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106380:	39 f0                	cmp    %esi,%eax
f0106382:	77 5c                	ja     f01063e0 <__umoddi3+0xb0>
f0106384:	0f bd e8             	bsr    %eax,%ebp
f0106387:	83 f5 1f             	xor    $0x1f,%ebp
f010638a:	75 64                	jne    f01063f0 <__umoddi3+0xc0>
f010638c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0106390:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0106394:	0f 86 f6 00 00 00    	jbe    f0106490 <__umoddi3+0x160>
f010639a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010639e:	0f 82 ec 00 00 00    	jb     f0106490 <__umoddi3+0x160>
f01063a4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01063a8:	8b 54 24 18          	mov    0x18(%esp),%edx
f01063ac:	83 c4 20             	add    $0x20,%esp
f01063af:	5e                   	pop    %esi
f01063b0:	5f                   	pop    %edi
f01063b1:	5d                   	pop    %ebp
f01063b2:	c3                   	ret    
f01063b3:	90                   	nop
f01063b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063b8:	85 ff                	test   %edi,%edi
f01063ba:	89 fd                	mov    %edi,%ebp
f01063bc:	75 0b                	jne    f01063c9 <__umoddi3+0x99>
f01063be:	b8 01 00 00 00       	mov    $0x1,%eax
f01063c3:	31 d2                	xor    %edx,%edx
f01063c5:	f7 f7                	div    %edi
f01063c7:	89 c5                	mov    %eax,%ebp
f01063c9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01063cd:	31 d2                	xor    %edx,%edx
f01063cf:	f7 f5                	div    %ebp
f01063d1:	89 c8                	mov    %ecx,%eax
f01063d3:	f7 f5                	div    %ebp
f01063d5:	eb 95                	jmp    f010636c <__umoddi3+0x3c>
f01063d7:	89 f6                	mov    %esi,%esi
f01063d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01063e0:	89 c8                	mov    %ecx,%eax
f01063e2:	89 f2                	mov    %esi,%edx
f01063e4:	83 c4 20             	add    $0x20,%esp
f01063e7:	5e                   	pop    %esi
f01063e8:	5f                   	pop    %edi
f01063e9:	5d                   	pop    %ebp
f01063ea:	c3                   	ret    
f01063eb:	90                   	nop
f01063ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01063f5:	89 e9                	mov    %ebp,%ecx
f01063f7:	29 e8                	sub    %ebp,%eax
f01063f9:	d3 e2                	shl    %cl,%edx
f01063fb:	89 c7                	mov    %eax,%edi
f01063fd:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106401:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106405:	89 f9                	mov    %edi,%ecx
f0106407:	d3 e8                	shr    %cl,%eax
f0106409:	89 c1                	mov    %eax,%ecx
f010640b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010640f:	09 d1                	or     %edx,%ecx
f0106411:	89 fa                	mov    %edi,%edx
f0106413:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106417:	89 e9                	mov    %ebp,%ecx
f0106419:	d3 e0                	shl    %cl,%eax
f010641b:	89 f9                	mov    %edi,%ecx
f010641d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106421:	89 f0                	mov    %esi,%eax
f0106423:	d3 e8                	shr    %cl,%eax
f0106425:	89 e9                	mov    %ebp,%ecx
f0106427:	89 c7                	mov    %eax,%edi
f0106429:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010642d:	d3 e6                	shl    %cl,%esi
f010642f:	89 d1                	mov    %edx,%ecx
f0106431:	89 fa                	mov    %edi,%edx
f0106433:	d3 e8                	shr    %cl,%eax
f0106435:	89 e9                	mov    %ebp,%ecx
f0106437:	09 f0                	or     %esi,%eax
f0106439:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010643d:	f7 74 24 10          	divl   0x10(%esp)
f0106441:	d3 e6                	shl    %cl,%esi
f0106443:	89 d1                	mov    %edx,%ecx
f0106445:	f7 64 24 0c          	mull   0xc(%esp)
f0106449:	39 d1                	cmp    %edx,%ecx
f010644b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010644f:	89 d7                	mov    %edx,%edi
f0106451:	89 c6                	mov    %eax,%esi
f0106453:	72 0a                	jb     f010645f <__umoddi3+0x12f>
f0106455:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0106459:	73 10                	jae    f010646b <__umoddi3+0x13b>
f010645b:	39 d1                	cmp    %edx,%ecx
f010645d:	75 0c                	jne    f010646b <__umoddi3+0x13b>
f010645f:	89 d7                	mov    %edx,%edi
f0106461:	89 c6                	mov    %eax,%esi
f0106463:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0106467:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010646b:	89 ca                	mov    %ecx,%edx
f010646d:	89 e9                	mov    %ebp,%ecx
f010646f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106473:	29 f0                	sub    %esi,%eax
f0106475:	19 fa                	sbb    %edi,%edx
f0106477:	d3 e8                	shr    %cl,%eax
f0106479:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010647e:	89 d7                	mov    %edx,%edi
f0106480:	d3 e7                	shl    %cl,%edi
f0106482:	89 e9                	mov    %ebp,%ecx
f0106484:	09 f8                	or     %edi,%eax
f0106486:	d3 ea                	shr    %cl,%edx
f0106488:	83 c4 20             	add    $0x20,%esp
f010648b:	5e                   	pop    %esi
f010648c:	5f                   	pop    %edi
f010648d:	5d                   	pop    %ebp
f010648e:	c3                   	ret    
f010648f:	90                   	nop
f0106490:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106494:	29 f9                	sub    %edi,%ecx
f0106496:	19 c6                	sbb    %eax,%esi
f0106498:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010649c:	89 74 24 18          	mov    %esi,0x18(%esp)
f01064a0:	e9 ff fe ff ff       	jmp    f01063a4 <__umoddi3+0x74>
