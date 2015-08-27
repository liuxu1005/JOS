
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
f010005c:	e8 9a 5d 00 00       	call   f0105dfb <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 c0 64 10 f0       	push   $0xf01064c0
f010006d:	e8 9f 36 00 00       	call   f0103711 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 6f 36 00 00       	call   f01036eb <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 b3 6d 10 f0 	movl   $0xf0106db3,(%esp)
f0100083:	e8 89 36 00 00       	call   f0103711 <cprintf>
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
f01000b3:	e8 20 57 00 00       	call   f01057d8 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 86 05 00 00       	call   f0100643 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 2c 65 10 f0       	push   $0xf010652c
f01000ca:	e8 42 36 00 00       	call   f0103711 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 c4 12 00 00       	call   f0101398 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 f0 2e 00 00       	call   f0102fc9 <env_init>
	trap_init();
f01000d9:	e8 07 37 00 00       	call   f01037e5 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 11 5a 00 00       	call   f0105af4 <mp_init>
	lapic_init();
f01000e3:	e8 2e 5d 00 00       	call   f0105e16 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 60 35 00 00       	call   f010364d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 00 14 12 f0 	movl   $0xf0121400,(%esp)
f01000f4:	e8 6d 5f 00 00       	call   f0106066 <spin_lock>
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
f010011e:	b8 5a 5a 10 f0       	mov    $0xf0105a5a,%eax
f0100123:	2d e0 59 10 f0       	sub    $0xf01059e0,%eax
f0100128:	50                   	push   %eax
f0100129:	68 e0 59 10 f0       	push   $0xf01059e0
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 ed 56 00 00       	call   f0105825 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 40 b0 20 f0       	mov    $0xf020b040,%ebx
f0100140:	eb 4e                	jmp    f0100190 <i386_init+0xf6>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 b4 5c 00 00       	call   f0105dfb <cpunum>
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
f010017d:	e8 e2 5d 00 00       	call   f0105f64 <lapic_startap>
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
f01001aa:	e8 ab 2f 00 00       	call   f010315a <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001af:	83 c4 08             	add    $0x8,%esp
f01001b2:	6a 00                	push   $0x0
f01001b4:	68 ec 9f 1f f0       	push   $0xf01f9fec
f01001b9:	e8 9c 2f 00 00       	call   f010315a <env_create>
        
//>>>>>>> lab4
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001be:	e8 24 04 00 00       	call   f01005e7 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c3:	e8 a6 43 00 00       	call   f010456e <sched_yield>

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
f01001f4:	e8 02 5c 00 00       	call   f0105dfb <cpunum>
f01001f9:	83 ec 08             	sub    $0x8,%esp
f01001fc:	50                   	push   %eax
f01001fd:	68 53 65 10 f0       	push   $0xf0106553
f0100202:	e8 0a 35 00 00       	call   f0103711 <cprintf>

	lapic_init();
f0100207:	e8 0a 5c 00 00       	call   f0105e16 <lapic_init>
	env_init_percpu();
f010020c:	e8 8e 2d 00 00       	call   f0102f9f <env_init_percpu>
	trap_init_percpu();
f0100211:	e8 0f 35 00 00       	call   f0103725 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100216:	e8 e0 5b 00 00       	call   f0105dfb <cpunum>
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
f0100234:	e8 2d 5e 00 00       	call   f0106066 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100239:	e8 30 43 00 00       	call   f010456e <sched_yield>

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
f0100253:	e8 b9 34 00 00       	call   f0103711 <cprintf>
	vcprintf(fmt, ap);
f0100258:	83 c4 08             	add    $0x8,%esp
f010025b:	53                   	push   %ebx
f010025c:	ff 75 10             	pushl  0x10(%ebp)
f010025f:	e8 87 34 00 00       	call   f01036eb <vcprintf>
	cprintf("\n");
f0100264:	c7 04 24 b3 6d 10 f0 	movl   $0xf0106db3,(%esp)
f010026b:	e8 a1 34 00 00       	call   f0103711 <cprintf>
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
f01003bf:	e8 4d 33 00 00       	call   f0103711 <cprintf>
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
f0100567:	e8 b9 52 00 00       	call   f0105825 <memmove>
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
f01006df:	e8 f4 2e 00 00       	call   f01035d8 <irq_setmask_8259A>
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
f0100751:	e8 82 2e 00 00       	call   f01035d8 <irq_setmask_8259A>
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
f010076a:	e8 a2 2f 00 00       	call   f0103711 <cprintf>
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
f01007ba:	e8 52 2f 00 00       	call   f0103711 <cprintf>
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	68 d0 68 10 f0       	push   $0xf01068d0
f01007c7:	68 2c 68 10 f0       	push   $0xf010682c
f01007cc:	68 23 68 10 f0       	push   $0xf0106823
f01007d1:	e8 3b 2f 00 00       	call   f0103711 <cprintf>
f01007d6:	83 c4 0c             	add    $0xc,%esp
f01007d9:	68 35 68 10 f0       	push   $0xf0106835
f01007de:	68 48 68 10 f0       	push   $0xf0106848
f01007e3:	68 23 68 10 f0       	push   $0xf0106823
f01007e8:	e8 24 2f 00 00       	call   f0103711 <cprintf>
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
f01007ff:	e8 0d 2f 00 00       	call   f0103711 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100804:	83 c4 08             	add    $0x8,%esp
f0100807:	68 0c 00 10 00       	push   $0x10000c
f010080c:	68 f8 68 10 f0       	push   $0xf01068f8
f0100811:	e8 fb 2e 00 00       	call   f0103711 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	68 0c 00 10 00       	push   $0x10000c
f010081e:	68 0c 00 10 f0       	push   $0xf010000c
f0100823:	68 20 69 10 f0       	push   $0xf0106920
f0100828:	e8 e4 2e 00 00       	call   f0103711 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082d:	83 c4 0c             	add    $0xc,%esp
f0100830:	68 95 64 10 00       	push   $0x106495
f0100835:	68 95 64 10 f0       	push   $0xf0106495
f010083a:	68 44 69 10 f0       	push   $0xf0106944
f010083f:	e8 cd 2e 00 00       	call   f0103711 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100844:	83 c4 0c             	add    $0xc,%esp
f0100847:	68 90 9e 20 00       	push   $0x209e90
f010084c:	68 90 9e 20 f0       	push   $0xf0209e90
f0100851:	68 68 69 10 f0       	push   $0xf0106968
f0100856:	e8 b6 2e 00 00       	call   f0103711 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085b:	83 c4 0c             	add    $0xc,%esp
f010085e:	68 08 c0 24 00       	push   $0x24c008
f0100863:	68 08 c0 24 f0       	push   $0xf024c008
f0100868:	68 8c 69 10 f0       	push   $0xf010698c
f010086d:	e8 9f 2e 00 00       	call   f0103711 <cprintf>
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
f0100898:	e8 74 2e 00 00       	call   f0103711 <cprintf>
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
f01008e5:	e8 27 2e 00 00       	call   f0103711 <cprintf>
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
f0100916:	e8 f6 2d 00 00       	call   f0103711 <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f010091b:	83 c4 18             	add    $0x18,%esp
f010091e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100924:	50                   	push   %eax
f0100925:	56                   	push   %esi
f0100926:	e8 26 44 00 00       	call   f0104d51 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f010092b:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f0100931:	68 d6 6a 10 f0       	push   $0xf0106ad6
f0100936:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f010093c:	83 c0 01             	add    $0x1,%eax
f010093f:	50                   	push   %eax
f0100940:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100943:	50                   	push   %eax
f0100944:	e8 06 4c 00 00       	call   f010554f <snprintf>
            
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
f010096a:	e8 a2 2d 00 00       	call   f0103711 <cprintf>
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
f01009b5:	e8 57 2d 00 00       	call   f0103711 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ba:	c7 04 24 38 6a 10 f0 	movl   $0xf0106a38,(%esp)
f01009c1:	e8 4b 2d 00 00       	call   f0103711 <cprintf>

	if (tf != NULL)
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009cd:	74 0e                	je     f01009dd <monitor+0x36>
		print_trapframe(tf);
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	ff 75 08             	pushl  0x8(%ebp)
f01009d5:	e8 b2 34 00 00       	call   f0103e8c <print_trapframe>
f01009da:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009dd:	83 ec 0c             	sub    $0xc,%esp
f01009e0:	68 94 68 10 f0       	push   $0xf0106894
f01009e5:	e8 7f 4b 00 00       	call   f0105569 <readline>
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
f0100a1e:	e8 78 4d 00 00       	call   f010579b <strchr>
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
f0100a3e:	e8 ce 2c 00 00       	call   f0103711 <cprintf>
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
f0100a67:	e8 2f 4d 00 00       	call   f010579b <strchr>
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
f0100a9a:	e8 9e 4c 00 00       	call   f010573d <strcmp>
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
f0100adb:	e8 31 2c 00 00       	call   f0103711 <cprintf>
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
f0100c82:	e8 51 4b 00 00       	call   f01057d8 <memset>
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
f0101001:	e8 d2 47 00 00       	call   f01057d8 <memset>
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
f0101247:	e8 af 4b 00 00       	call   f0105dfb <cpunum>
f010124c:	6b c0 74             	imul   $0x74,%eax,%eax
f010124f:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0101256:	74 16                	je     f010126e <tlb_invalidate+0x2d>
f0101258:	e8 9e 4b 00 00       	call   f0105dfb <cpunum>
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
f01013a3:	e8 08 22 00 00       	call   f01035b0 <mc146818_read>
f01013a8:	89 c3                	mov    %eax,%ebx
f01013aa:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013b1:	e8 fa 21 00 00       	call   f01035b0 <mc146818_read>
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
f01013d8:	e8 d3 21 00 00       	call   f01035b0 <mc146818_read>
f01013dd:	89 c3                	mov    %eax,%ebx
f01013df:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013e6:	e8 c5 21 00 00       	call   f01035b0 <mc146818_read>
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
f0101446:	e8 c6 22 00 00       	call   f0103711 <cprintf>
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
f0101465:	e8 6e 43 00 00       	call   f01057d8 <memset>
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
f01014c3:	e8 10 43 00 00       	call   f01057d8 <memset>

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
f01017f0:	e8 e3 3f 00 00       	call   f01057d8 <memset>
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
f0101900:	e8 0c 1e 00 00       	call   f0103711 <cprintf>
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
f010238d:	e8 46 34 00 00       	call   f01057d8 <memset>
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
f0102669:	e8 a3 10 00 00       	call   f0103711 <cprintf>
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
f0102a76:	e8 96 0c 00 00       	call   f0103711 <cprintf>
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
f0102b8c:	e8 47 2c 00 00       	call   f01057d8 <memset>
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
f0102bd1:	e8 02 2c 00 00       	call   f01057d8 <memset>
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
f0102db3:	e8 59 09 00 00       	call   f0103711 <cprintf>
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
f0102e70:	e8 9c 08 00 00       	call   f0103711 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e75:	89 1c 24             	mov    %ebx,(%esp)
f0102e78:	e8 ad 05 00 00       	call   f010342a <env_destroy>
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
f0102e8e:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
f0102e90:	89 d3                	mov    %edx,%ebx
f0102e92:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        end = ROUNDUP(va + len, PGSIZE);
f0102e98:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102e9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ea4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(; start < end; start += PGSIZE) {
f0102ea7:	eb 4c                	jmp    f0102ef5 <region_alloc+0x70>
                if((newpage = page_alloc(0)) == NULL)
f0102ea9:	83 ec 0c             	sub    $0xc,%esp
f0102eac:	6a 00                	push   $0x0
f0102eae:	e8 fe e0 ff ff       	call   f0100fb1 <page_alloc>
f0102eb3:	89 c6                	mov    %eax,%esi
f0102eb5:	83 c4 10             	add    $0x10,%esp
f0102eb8:	85 c0                	test   %eax,%eax
f0102eba:	75 10                	jne    f0102ecc <region_alloc+0x47>
                       cprintf("page_alloc return null\n");
f0102ebc:	83 ec 0c             	sub    $0xc,%esp
f0102ebf:	68 05 77 10 f0       	push   $0xf0107705
f0102ec4:	e8 48 08 00 00       	call   f0103711 <cprintf>
f0102ec9:	83 c4 10             	add    $0x10,%esp
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
f0102ecc:	6a 06                	push   $0x6
f0102ece:	53                   	push   %ebx
f0102ecf:	56                   	push   %esi
f0102ed0:	ff 77 60             	pushl  0x60(%edi)
f0102ed3:	e8 ef e3 ff ff       	call   f01012c7 <page_insert>
f0102ed8:	83 c4 10             	add    $0x10,%esp
f0102edb:	85 c0                	test   %eax,%eax
f0102edd:	79 10                	jns    f0102eef <region_alloc+0x6a>
                       cprintf("insert failing\n");
f0102edf:	83 ec 0c             	sub    $0xc,%esp
f0102ee2:	68 1d 77 10 f0       	push   $0xf010771d
f0102ee7:	e8 25 08 00 00       	call   f0103711 <cprintf>
f0102eec:	83 c4 10             	add    $0x10,%esp
	//   (Watch out for corner-cases!)
        void *start, *end;
        struct PageInfo *newpage;
        start = ROUNDDOWN(va, PGSIZE);
        end = ROUNDUP(va + len, PGSIZE);
        for(; start < end; start += PGSIZE) {
f0102eef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ef5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102ef8:	72 af                	jb     f0102ea9 <region_alloc+0x24>
                       cprintf("page_alloc return null\n");
                if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
                       cprintf("insert failing\n");

        }
}
f0102efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102efd:	5b                   	pop    %ebx
f0102efe:	5e                   	pop    %esi
f0102eff:	5f                   	pop    %edi
f0102f00:	5d                   	pop    %ebp
f0102f01:	c3                   	ret    

f0102f02 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f02:	55                   	push   %ebp
f0102f03:	89 e5                	mov    %esp,%ebp
f0102f05:	56                   	push   %esi
f0102f06:	53                   	push   %ebx
f0102f07:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f0a:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f0d:	85 c0                	test   %eax,%eax
f0102f0f:	75 1a                	jne    f0102f2b <envid2env+0x29>
		*env_store = curenv;
f0102f11:	e8 e5 2e 00 00       	call   f0105dfb <cpunum>
f0102f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f19:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0102f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f22:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f24:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f29:	eb 70                	jmp    f0102f9b <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f2b:	89 c3                	mov    %eax,%ebx
f0102f2d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f33:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f36:	03 1d 68 a2 20 f0    	add    0xf020a268,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f3c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f40:	74 05                	je     f0102f47 <envid2env+0x45>
f0102f42:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f45:	74 10                	je     f0102f57 <envid2env+0x55>
		*env_store = 0;
f0102f47:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f50:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f55:	eb 44                	jmp    f0102f9b <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f57:	84 d2                	test   %dl,%dl
f0102f59:	74 36                	je     f0102f91 <envid2env+0x8f>
f0102f5b:	e8 9b 2e 00 00       	call   f0105dfb <cpunum>
f0102f60:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f63:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f0102f69:	74 26                	je     f0102f91 <envid2env+0x8f>
f0102f6b:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f6e:	e8 88 2e 00 00       	call   f0105dfb <cpunum>
f0102f73:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f76:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0102f7c:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f7f:	74 10                	je     f0102f91 <envid2env+0x8f>
		*env_store = 0;
f0102f81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f8a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f8f:	eb 0a                	jmp    f0102f9b <envid2env+0x99>
	}

	*env_store = e;
f0102f91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f94:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f9b:	5b                   	pop    %ebx
f0102f9c:	5e                   	pop    %esi
f0102f9d:	5d                   	pop    %ebp
f0102f9e:	c3                   	ret    

f0102f9f <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f9f:	55                   	push   %ebp
f0102fa0:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102fa2:	b8 40 13 12 f0       	mov    $0xf0121340,%eax
f0102fa7:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102faa:	b8 23 00 00 00       	mov    $0x23,%eax
f0102faf:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102fb1:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102fb3:	b0 10                	mov    $0x10,%al
f0102fb5:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102fb7:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102fb9:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102fbb:	ea c2 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fc2
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102fc2:	b0 00                	mov    $0x0,%al
f0102fc4:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fc7:	5d                   	pop    %ebp
f0102fc8:	c3                   	ret    

f0102fc9 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102fc9:	55                   	push   %ebp
f0102fca:	89 e5                	mov    %esp,%ebp
f0102fcc:	56                   	push   %esi
f0102fcd:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
		envs[i].env_id = 0;
f0102fce:	8b 35 68 a2 20 f0    	mov    0xf020a268,%esi
f0102fd4:	8b 15 6c a2 20 f0    	mov    0xf020a26c,%edx
f0102fda:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102fe0:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102fe3:	89 c1                	mov    %eax,%ecx
f0102fe5:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102fec:	89 50 44             	mov    %edx,0x44(%eax)
f0102fef:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f0102ff2:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
f0102ff4:	39 d8                	cmp    %ebx,%eax
f0102ff6:	75 eb                	jne    f0102fe3 <env_init+0x1a>
f0102ff8:	89 35 6c a2 20 f0    	mov    %esi,0xf020a26c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	} 
	// Per-CPU part of the initialization
	env_init_percpu();
f0102ffe:	e8 9c ff ff ff       	call   f0102f9f <env_init_percpu>
                
}
f0103003:	5b                   	pop    %ebx
f0103004:	5e                   	pop    %esi
f0103005:	5d                   	pop    %ebp
f0103006:	c3                   	ret    

f0103007 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103007:	55                   	push   %ebp
f0103008:	89 e5                	mov    %esp,%ebp
f010300a:	53                   	push   %ebx
f010300b:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
f010300e:	8b 1d 6c a2 20 f0    	mov    0xf020a26c,%ebx
f0103014:	85 db                	test   %ebx,%ebx
f0103016:	0f 84 2d 01 00 00    	je     f0103149 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010301c:	83 ec 0c             	sub    $0xc,%esp
f010301f:	6a 01                	push   $0x1
f0103021:	e8 8b df ff ff       	call   f0100fb1 <page_alloc>
f0103026:	83 c4 10             	add    $0x10,%esp
f0103029:	85 c0                	test   %eax,%eax
f010302b:	0f 84 1f 01 00 00    	je     f0103150 <env_alloc+0x149>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        p->pp_ref++;
f0103031:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103036:	2b 05 d0 ae 20 f0    	sub    0xf020aed0,%eax
f010303c:	c1 f8 03             	sar    $0x3,%eax
f010303f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103042:	89 c2                	mov    %eax,%edx
f0103044:	c1 ea 0c             	shr    $0xc,%edx
f0103047:	3b 15 c8 ae 20 f0    	cmp    0xf020aec8,%edx
f010304d:	72 12                	jb     f0103061 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010304f:	50                   	push   %eax
f0103050:	68 e4 64 10 f0       	push   $0xf01064e4
f0103055:	6a 58                	push   $0x58
f0103057:	68 aa 6a 10 f0       	push   $0xf0106aaa
f010305c:	e8 df cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103061:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = page2kva(p);    
f0103066:	89 43 60             	mov    %eax,0x60(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
f0103069:	83 ec 04             	sub    $0x4,%esp
f010306c:	68 00 10 00 00       	push   $0x1000
f0103071:	ff 35 cc ae 20 f0    	pushl  0xf020aecc
f0103077:	50                   	push   %eax
f0103078:	e8 10 28 00 00       	call   f010588d <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010307d:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103080:	83 c4 10             	add    $0x10,%esp
f0103083:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103088:	77 15                	ja     f010309f <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010308a:	50                   	push   %eax
f010308b:	68 08 65 10 f0       	push   $0xf0106508
f0103090:	68 c4 00 00 00       	push   $0xc4
f0103095:	68 2d 77 10 f0       	push   $0xf010772d
f010309a:	e8 a1 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010309f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030a5:	83 ca 05             	or     $0x5,%edx
f01030a8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0) 
		return r;
 
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030ae:	8b 43 48             	mov    0x48(%ebx),%eax
f01030b1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030b6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030bb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030c0:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01030c3:	89 da                	mov    %ebx,%edx
f01030c5:	2b 15 68 a2 20 f0    	sub    0xf020a268,%edx
f01030cb:	c1 fa 02             	sar    $0x2,%edx
f01030ce:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030d4:	09 d0                	or     %edx,%eax
f01030d6:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030dc:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030df:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030e6:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030ed:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030f4:	83 ec 04             	sub    $0x4,%esp
f01030f7:	6a 44                	push   $0x44
f01030f9:	6a 00                	push   $0x0
f01030fb:	53                   	push   %ebx
f01030fc:	e8 d7 26 00 00       	call   f01057d8 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103101:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103107:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010310d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103113:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010311a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0103120:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103127:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010312e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103132:	8b 43 44             	mov    0x44(%ebx),%eax
f0103135:	a3 6c a2 20 f0       	mov    %eax,0xf020a26c
	*newenv_store = e;
f010313a:	8b 45 08             	mov    0x8(%ebp),%eax
f010313d:	89 18                	mov    %ebx,(%eax)
	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
f010313f:	83 c4 10             	add    $0x10,%esp
f0103142:	b8 00 00 00 00       	mov    $0x0,%eax
f0103147:	eb 0c                	jmp    f0103155 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
		return -E_NO_FREE_ENV;
f0103149:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010314e:	eb 05                	jmp    f0103155 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103150:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//=======
         
	//cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
//>>>>>>> lab4
	return 0;
}
f0103155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103158:	c9                   	leave  
f0103159:	c3                   	ret    

f010315a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010315a:	55                   	push   %ebp
f010315b:	89 e5                	mov    %esp,%ebp
f010315d:	57                   	push   %edi
f010315e:	56                   	push   %esi
f010315f:	53                   	push   %ebx
f0103160:	83 ec 34             	sub    $0x34,%esp
f0103163:	8b 75 08             	mov    0x8(%ebp),%esi
f0103166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *e;
        int tmp;
        if((tmp = env_alloc(&e, 0)) != 0)
f0103169:	6a 00                	push   $0x0
f010316b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010316e:	50                   	push   %eax
f010316f:	e8 93 fe ff ff       	call   f0103007 <env_alloc>
f0103174:	83 c4 10             	add    $0x10,%esp
f0103177:	85 c0                	test   %eax,%eax
f0103179:	74 17                	je     f0103192 <env_create+0x38>
               panic("evn create fails!\n");
f010317b:	83 ec 04             	sub    $0x4,%esp
f010317e:	68 38 77 10 f0       	push   $0xf0107738
f0103183:	68 8d 01 00 00       	push   $0x18d
f0103188:	68 2d 77 10 f0       	push   $0xf010772d
f010318d:	e8 ae ce ff ff       	call   f0100040 <_panic>
       

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
        if (type == ENV_TYPE_FS)
f0103192:	83 fb 01             	cmp    $0x1,%ebx
f0103195:	75 0a                	jne    f01031a1 <env_create+0x47>
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010319a:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
        e->env_type =type;
f01031a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031a4:	89 5f 50             	mov    %ebx,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf_img = (struct Elf *)binary;
        struct Proghdr *ph, *eph;
        if (elf_img->e_magic != ELF_MAGIC)
f01031a7:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01031ad:	74 17                	je     f01031c6 <env_create+0x6c>
                panic("Not executable!");
f01031af:	83 ec 04             	sub    $0x4,%esp
f01031b2:	68 4b 77 10 f0       	push   $0xf010774b
f01031b7:	68 6c 01 00 00       	push   $0x16c
f01031bc:	68 2d 77 10 f0       	push   $0xf010772d
f01031c1:	e8 7a ce ff ff       	call   f0100040 <_panic>
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
f01031c6:	89 f3                	mov    %esi,%ebx
f01031c8:	03 5e 1c             	add    0x1c(%esi),%ebx
        eph = ph + elf_img->e_phnum;
f01031cb:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01031cf:	c1 e0 05             	shl    $0x5,%eax
f01031d2:	01 d8                	add    %ebx,%eax
f01031d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        lcr3(PADDR(e->env_pgdir));
f01031d7:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031da:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031df:	77 15                	ja     f01031f6 <env_create+0x9c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e1:	50                   	push   %eax
f01031e2:	68 08 65 10 f0       	push   $0xf0106508
f01031e7:	68 6f 01 00 00       	push   $0x16f
f01031ec:	68 2d 77 10 f0       	push   $0xf010772d
f01031f1:	e8 4a ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031f6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031fb:	0f 22 d8             	mov    %eax,%cr3
f01031fe:	eb 37                	jmp    f0103237 <env_create+0xdd>
        
        for(; ph < eph; ph++) {
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103200:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103203:	8b 53 08             	mov    0x8(%ebx),%edx
f0103206:	89 f8                	mov    %edi,%eax
f0103208:	e8 78 fc ff ff       	call   f0102e85 <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f010320d:	83 ec 04             	sub    $0x4,%esp
f0103210:	ff 73 14             	pushl  0x14(%ebx)
f0103213:	6a 00                	push   $0x0
f0103215:	ff 73 08             	pushl  0x8(%ebx)
f0103218:	e8 bb 25 00 00       	call   f01057d8 <memset>
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010321d:	83 c4 0c             	add    $0xc,%esp
f0103220:	ff 73 10             	pushl  0x10(%ebx)
f0103223:	89 f0                	mov    %esi,%eax
f0103225:	03 43 04             	add    0x4(%ebx),%eax
f0103228:	50                   	push   %eax
f0103229:	ff 73 08             	pushl  0x8(%ebx)
f010322c:	e8 5c 26 00 00       	call   f010588d <memcpy>
                panic("Not executable!");
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        eph = ph + elf_img->e_phnum;
        lcr3(PADDR(e->env_pgdir));
        
        for(; ph < eph; ph++) {
f0103231:	83 c3 20             	add    $0x20,%ebx
f0103234:	83 c4 10             	add    $0x10,%esp
f0103237:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010323a:	77 c4                	ja     f0103200 <env_create+0xa6>
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        }
        lcr3(PADDR(kern_pgdir));
f010323c:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103241:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103246:	77 15                	ja     f010325d <env_create+0x103>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103248:	50                   	push   %eax
f0103249:	68 08 65 10 f0       	push   $0xf0106508
f010324e:	68 76 01 00 00       	push   $0x176
f0103253:	68 2d 77 10 f0       	push   $0xf010772d
f0103258:	e8 e3 cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010325d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103262:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elf_img->e_entry;
f0103265:	8b 46 18             	mov    0x18(%esi),%eax
f0103268:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f010326b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103270:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103275:	89 f8                	mov    %edi,%eax
f0103277:	e8 09 fc ff ff       	call   f0102e85 <region_alloc>
        if (type == ENV_TYPE_FS)
                e->env_tf.tf_eflags |= FL_IOPL_MASK;
        e->env_type =type;
        load_icode(e, binary);
 
}
f010327c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327f:	5b                   	pop    %ebx
f0103280:	5e                   	pop    %esi
f0103281:	5f                   	pop    %edi
f0103282:	5d                   	pop    %ebp
f0103283:	c3                   	ret    

f0103284 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103284:	55                   	push   %ebp
f0103285:	89 e5                	mov    %esp,%ebp
f0103287:	57                   	push   %edi
f0103288:	56                   	push   %esi
f0103289:	53                   	push   %ebx
f010328a:	83 ec 1c             	sub    $0x1c,%esp
f010328d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103290:	e8 66 2b 00 00       	call   f0105dfb <cpunum>
f0103295:	6b c0 74             	imul   $0x74,%eax,%eax
f0103298:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010329f:	39 b8 48 b0 20 f0    	cmp    %edi,-0xfdf4fb8(%eax)
f01032a5:	75 30                	jne    f01032d7 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01032a7:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032b1:	77 15                	ja     f01032c8 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032b3:	50                   	push   %eax
f01032b4:	68 08 65 10 f0       	push   $0xf0106508
f01032b9:	68 a7 01 00 00       	push   $0x1a7
f01032be:	68 2d 77 10 f0       	push   $0xf010772d
f01032c3:	e8 78 cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032c8:	05 00 00 00 10       	add    $0x10000000,%eax
f01032cd:	0f 22 d8             	mov    %eax,%cr3
f01032d0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032da:	89 d0                	mov    %edx,%eax
f01032dc:	c1 e0 02             	shl    $0x2,%eax
f01032df:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032e2:	8b 47 60             	mov    0x60(%edi),%eax
f01032e5:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032e8:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032ee:	0f 84 a8 00 00 00    	je     f010339c <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032f4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032fa:	89 f0                	mov    %esi,%eax
f01032fc:	c1 e8 0c             	shr    $0xc,%eax
f01032ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103302:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f0103308:	72 15                	jb     f010331f <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010330a:	56                   	push   %esi
f010330b:	68 e4 64 10 f0       	push   $0xf01064e4
f0103310:	68 b6 01 00 00       	push   $0x1b6
f0103315:	68 2d 77 10 f0       	push   $0xf010772d
f010331a:	e8 21 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010331f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103322:	c1 e0 16             	shl    $0x16,%eax
f0103325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103328:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010332d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103334:	01 
f0103335:	74 17                	je     f010334e <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103337:	83 ec 08             	sub    $0x8,%esp
f010333a:	89 d8                	mov    %ebx,%eax
f010333c:	c1 e0 0c             	shl    $0xc,%eax
f010333f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103342:	50                   	push   %eax
f0103343:	ff 77 60             	pushl  0x60(%edi)
f0103346:	e8 2b df ff ff       	call   f0101276 <page_remove>
f010334b:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010334e:	83 c3 01             	add    $0x1,%ebx
f0103351:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103357:	75 d4                	jne    f010332d <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103359:	8b 47 60             	mov    0x60(%edi),%eax
f010335c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010335f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103366:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103369:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f010336f:	72 14                	jb     f0103385 <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103371:	83 ec 04             	sub    $0x4,%esp
f0103374:	68 ac 6e 10 f0       	push   $0xf0106eac
f0103379:	6a 51                	push   $0x51
f010337b:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0103380:	e8 bb cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103385:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103388:	a1 d0 ae 20 f0       	mov    0xf020aed0,%eax
f010338d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103390:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103393:	50                   	push   %eax
f0103394:	e8 c5 dc ff ff       	call   f010105e <page_decref>
f0103399:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010339c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01033a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033a3:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01033a8:	0f 85 29 ff ff ff    	jne    f01032d7 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033ae:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033b6:	77 15                	ja     f01033cd <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b8:	50                   	push   %eax
f01033b9:	68 08 65 10 f0       	push   $0xf0106508
f01033be:	68 c4 01 00 00       	push   $0x1c4
f01033c3:	68 2d 77 10 f0       	push   $0xf010772d
f01033c8:	e8 73 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01033cd:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033d4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033d9:	c1 e8 0c             	shr    $0xc,%eax
f01033dc:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f01033e2:	72 14                	jb     f01033f8 <env_free+0x174>
		panic("pa2page called with invalid pa");
f01033e4:	83 ec 04             	sub    $0x4,%esp
f01033e7:	68 ac 6e 10 f0       	push   $0xf0106eac
f01033ec:	6a 51                	push   $0x51
f01033ee:	68 aa 6a 10 f0       	push   $0xf0106aaa
f01033f3:	e8 48 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033f8:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033fb:	8b 15 d0 ae 20 f0    	mov    0xf020aed0,%edx
f0103401:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103404:	50                   	push   %eax
f0103405:	e8 54 dc ff ff       	call   f010105e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010340a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103411:	a1 6c a2 20 f0       	mov    0xf020a26c,%eax
f0103416:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103419:	89 3d 6c a2 20 f0    	mov    %edi,0xf020a26c
f010341f:	83 c4 10             	add    $0x10,%esp
}
f0103422:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103425:	5b                   	pop    %ebx
f0103426:	5e                   	pop    %esi
f0103427:	5f                   	pop    %edi
f0103428:	5d                   	pop    %ebp
f0103429:	c3                   	ret    

f010342a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010342a:	55                   	push   %ebp
f010342b:	89 e5                	mov    %esp,%ebp
f010342d:	53                   	push   %ebx
f010342e:	83 ec 04             	sub    $0x4,%esp
f0103431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103434:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103438:	75 19                	jne    f0103453 <env_destroy+0x29>
f010343a:	e8 bc 29 00 00       	call   f0105dfb <cpunum>
f010343f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103442:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f0103448:	74 09                	je     f0103453 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010344a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103451:	eb 33                	jmp    f0103486 <env_destroy+0x5c>
	}

	env_free(e);
f0103453:	83 ec 0c             	sub    $0xc,%esp
f0103456:	53                   	push   %ebx
f0103457:	e8 28 fe ff ff       	call   f0103284 <env_free>

	if (curenv == e) {
f010345c:	e8 9a 29 00 00       	call   f0105dfb <cpunum>
f0103461:	6b c0 74             	imul   $0x74,%eax,%eax
f0103464:	83 c4 10             	add    $0x10,%esp
f0103467:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f010346d:	75 17                	jne    f0103486 <env_destroy+0x5c>
		curenv = NULL;
f010346f:	e8 87 29 00 00       	call   f0105dfb <cpunum>
f0103474:	6b c0 74             	imul   $0x74,%eax,%eax
f0103477:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f010347e:	00 00 00 
		sched_yield();
f0103481:	e8 e8 10 00 00       	call   f010456e <sched_yield>
	}
}
f0103486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103489:	c9                   	leave  
f010348a:	c3                   	ret    

f010348b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010348b:	55                   	push   %ebp
f010348c:	89 e5                	mov    %esp,%ebp
f010348e:	53                   	push   %ebx
f010348f:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103492:	e8 64 29 00 00       	call   f0105dfb <cpunum>
f0103497:	6b c0 74             	imul   $0x74,%eax,%eax
f010349a:	8b 98 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%ebx
f01034a0:	e8 56 29 00 00       	call   f0105dfb <cpunum>
f01034a5:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01034a8:	8b 65 08             	mov    0x8(%ebp),%esp
f01034ab:	61                   	popa   
f01034ac:	07                   	pop    %es
f01034ad:	1f                   	pop    %ds
f01034ae:	83 c4 08             	add    $0x8,%esp
f01034b1:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034b2:	83 ec 04             	sub    $0x4,%esp
f01034b5:	68 5b 77 10 f0       	push   $0xf010775b
f01034ba:	68 fa 01 00 00       	push   $0x1fa
f01034bf:	68 2d 77 10 f0       	push   $0xf010772d
f01034c4:	e8 77 cb ff ff       	call   f0100040 <_panic>

f01034c9 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034c9:	55                   	push   %ebp
f01034ca:	89 e5                	mov    %esp,%ebp
f01034cc:	53                   	push   %ebx
f01034cd:	83 ec 04             	sub    $0x4,%esp
f01034d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if( e != curenv) {
f01034d3:	e8 23 29 00 00       	call   f0105dfb <cpunum>
f01034d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01034db:	39 98 48 b0 20 f0    	cmp    %ebx,-0xfdf4fb8(%eax)
f01034e1:	0f 84 a4 00 00 00    	je     f010358b <env_run+0xc2>
                if (curenv && curenv->env_status == ENV_RUNNING)
f01034e7:	e8 0f 29 00 00       	call   f0105dfb <cpunum>
f01034ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ef:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f01034f6:	74 29                	je     f0103521 <env_run+0x58>
f01034f8:	e8 fe 28 00 00       	call   f0105dfb <cpunum>
f01034fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103500:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0103506:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010350a:	75 15                	jne    f0103521 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f010350c:	e8 ea 28 00 00       	call   f0105dfb <cpunum>
f0103511:	6b c0 74             	imul   $0x74,%eax,%eax
f0103514:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010351a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
                curenv = e;
f0103521:	e8 d5 28 00 00       	call   f0105dfb <cpunum>
f0103526:	6b c0 74             	imul   $0x74,%eax,%eax
f0103529:	89 98 48 b0 20 f0    	mov    %ebx,-0xfdf4fb8(%eax)
                curenv->env_runs++;
f010352f:	e8 c7 28 00 00       	call   f0105dfb <cpunum>
f0103534:	6b c0 74             	imul   $0x74,%eax,%eax
f0103537:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010353d:	83 40 58 01          	addl   $0x1,0x58(%eax)
                curenv->env_status = ENV_RUNNING;
f0103541:	e8 b5 28 00 00       	call   f0105dfb <cpunum>
f0103546:	6b c0 74             	imul   $0x74,%eax,%eax
f0103549:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010354f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
                lcr3(PADDR(curenv->env_pgdir));
f0103556:	e8 a0 28 00 00       	call   f0105dfb <cpunum>
f010355b:	6b c0 74             	imul   $0x74,%eax,%eax
f010355e:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0103564:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103567:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010356c:	77 15                	ja     f0103583 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010356e:	50                   	push   %eax
f010356f:	68 08 65 10 f0       	push   $0xf0106508
f0103574:	68 1e 02 00 00       	push   $0x21e
f0103579:	68 2d 77 10 f0       	push   $0xf010772d
f010357e:	e8 bd ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103583:	05 00 00 00 10       	add    $0x10000000,%eax
f0103588:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010358b:	83 ec 0c             	sub    $0xc,%esp
f010358e:	68 00 14 12 f0       	push   $0xf0121400
f0103593:	e8 6b 2b 00 00       	call   f0106103 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103598:	f3 90                	pause  
        }
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f010359a:	e8 5c 28 00 00       	call   f0105dfb <cpunum>
f010359f:	83 c4 04             	add    $0x4,%esp
f01035a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a5:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f01035ab:	e8 db fe ff ff       	call   f010348b <env_pop_tf>

f01035b0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035b0:	55                   	push   %ebp
f01035b1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035b3:	ba 70 00 00 00       	mov    $0x70,%edx
f01035b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01035bb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035bc:	b2 71                	mov    $0x71,%dl
f01035be:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035bf:	0f b6 c0             	movzbl %al,%eax
}
f01035c2:	5d                   	pop    %ebp
f01035c3:	c3                   	ret    

f01035c4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035c4:	55                   	push   %ebp
f01035c5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035c7:	ba 70 00 00 00       	mov    $0x70,%edx
f01035cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01035cf:	ee                   	out    %al,(%dx)
f01035d0:	b2 71                	mov    $0x71,%dl
f01035d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035d5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035d6:	5d                   	pop    %ebp
f01035d7:	c3                   	ret    

f01035d8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	56                   	push   %esi
f01035dc:	53                   	push   %ebx
f01035dd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035e0:	66 a3 e8 13 12 f0    	mov    %ax,0xf01213e8
	if (!didinit)
f01035e6:	80 3d 70 a2 20 f0 00 	cmpb   $0x0,0xf020a270
f01035ed:	74 57                	je     f0103646 <irq_setmask_8259A+0x6e>
f01035ef:	89 c6                	mov    %eax,%esi
f01035f1:	ba 21 00 00 00       	mov    $0x21,%edx
f01035f6:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01035f7:	66 c1 e8 08          	shr    $0x8,%ax
f01035fb:	b2 a1                	mov    $0xa1,%dl
f01035fd:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01035fe:	83 ec 0c             	sub    $0xc,%esp
f0103601:	68 67 77 10 f0       	push   $0xf0107767
f0103606:	e8 06 01 00 00       	call   f0103711 <cprintf>
f010360b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010360e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103613:	0f b7 f6             	movzwl %si,%esi
f0103616:	f7 d6                	not    %esi
f0103618:	0f a3 de             	bt     %ebx,%esi
f010361b:	73 11                	jae    f010362e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010361d:	83 ec 08             	sub    $0x8,%esp
f0103620:	53                   	push   %ebx
f0103621:	68 2b 7c 10 f0       	push   $0xf0107c2b
f0103626:	e8 e6 00 00 00       	call   f0103711 <cprintf>
f010362b:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010362e:	83 c3 01             	add    $0x1,%ebx
f0103631:	83 fb 10             	cmp    $0x10,%ebx
f0103634:	75 e2                	jne    f0103618 <irq_setmask_8259A+0x40>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103636:	83 ec 0c             	sub    $0xc,%esp
f0103639:	68 b3 6d 10 f0       	push   $0xf0106db3
f010363e:	e8 ce 00 00 00       	call   f0103711 <cprintf>
f0103643:	83 c4 10             	add    $0x10,%esp
}
f0103646:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103649:	5b                   	pop    %ebx
f010364a:	5e                   	pop    %esi
f010364b:	5d                   	pop    %ebp
f010364c:	c3                   	ret    

f010364d <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010364d:	c6 05 70 a2 20 f0 01 	movb   $0x1,0xf020a270
f0103654:	ba 21 00 00 00       	mov    $0x21,%edx
f0103659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010365e:	ee                   	out    %al,(%dx)
f010365f:	b2 a1                	mov    $0xa1,%dl
f0103661:	ee                   	out    %al,(%dx)
f0103662:	b2 20                	mov    $0x20,%dl
f0103664:	b8 11 00 00 00       	mov    $0x11,%eax
f0103669:	ee                   	out    %al,(%dx)
f010366a:	b2 21                	mov    $0x21,%dl
f010366c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103671:	ee                   	out    %al,(%dx)
f0103672:	b8 04 00 00 00       	mov    $0x4,%eax
f0103677:	ee                   	out    %al,(%dx)
f0103678:	b8 03 00 00 00       	mov    $0x3,%eax
f010367d:	ee                   	out    %al,(%dx)
f010367e:	b2 a0                	mov    $0xa0,%dl
f0103680:	b8 11 00 00 00       	mov    $0x11,%eax
f0103685:	ee                   	out    %al,(%dx)
f0103686:	b2 a1                	mov    $0xa1,%dl
f0103688:	b8 28 00 00 00       	mov    $0x28,%eax
f010368d:	ee                   	out    %al,(%dx)
f010368e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103693:	ee                   	out    %al,(%dx)
f0103694:	b8 01 00 00 00       	mov    $0x1,%eax
f0103699:	ee                   	out    %al,(%dx)
f010369a:	b2 20                	mov    $0x20,%dl
f010369c:	b8 68 00 00 00       	mov    $0x68,%eax
f01036a1:	ee                   	out    %al,(%dx)
f01036a2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036a7:	ee                   	out    %al,(%dx)
f01036a8:	b2 a0                	mov    $0xa0,%dl
f01036aa:	b8 68 00 00 00       	mov    $0x68,%eax
f01036af:	ee                   	out    %al,(%dx)
f01036b0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036b5:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036b6:	0f b7 05 e8 13 12 f0 	movzwl 0xf01213e8,%eax
f01036bd:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036c1:	74 13                	je     f01036d6 <pic_init+0x89>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036c3:	55                   	push   %ebp
f01036c4:	89 e5                	mov    %esp,%ebp
f01036c6:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036c9:	0f b7 c0             	movzwl %ax,%eax
f01036cc:	50                   	push   %eax
f01036cd:	e8 06 ff ff ff       	call   f01035d8 <irq_setmask_8259A>
f01036d2:	83 c4 10             	add    $0x10,%esp
}
f01036d5:	c9                   	leave  
f01036d6:	f3 c3                	repz ret 

f01036d8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036d8:	55                   	push   %ebp
f01036d9:	89 e5                	mov    %esp,%ebp
f01036db:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036de:	ff 75 08             	pushl  0x8(%ebp)
f01036e1:	e8 94 d0 ff ff       	call   f010077a <cputchar>
f01036e6:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01036e9:	c9                   	leave  
f01036ea:	c3                   	ret    

f01036eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036eb:	55                   	push   %ebp
f01036ec:	89 e5                	mov    %esp,%ebp
f01036ee:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036f8:	ff 75 0c             	pushl  0xc(%ebp)
f01036fb:	ff 75 08             	pushl  0x8(%ebp)
f01036fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103701:	50                   	push   %eax
f0103702:	68 d8 36 10 f0       	push   $0xf01036d8
f0103707:	e8 41 1a 00 00       	call   f010514d <vprintfmt>
	return cnt;
}
f010370c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010370f:	c9                   	leave  
f0103710:	c3                   	ret    

f0103711 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103711:	55                   	push   %ebp
f0103712:	89 e5                	mov    %esp,%ebp
f0103714:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103717:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010371a:	50                   	push   %eax
f010371b:	ff 75 08             	pushl  0x8(%ebp)
f010371e:	e8 c8 ff ff ff       	call   f01036eb <vcprintf>
	va_end(ap);

	return cnt;
}
f0103723:	c9                   	leave  
f0103724:	c3                   	ret    

f0103725 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103725:	55                   	push   %ebp
f0103726:	89 e5                	mov    %esp,%ebp
f0103728:	57                   	push   %edi
f0103729:	56                   	push   %esi
f010372a:	53                   	push   %ebx
f010372b:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
        int cid = thiscpu->cpu_id;
f010372e:	e8 c8 26 00 00       	call   f0105dfb <cpunum>
f0103733:	6b c0 74             	imul   $0x74,%eax,%eax
f0103736:	0f b6 98 40 b0 20 f0 	movzbl -0xfdf4fc0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f010373d:	e8 b9 26 00 00       	call   f0105dfb <cpunum>
f0103742:	6b c0 74             	imul   $0x74,%eax,%eax
f0103745:	89 da                	mov    %ebx,%edx
f0103747:	f7 da                	neg    %edx
f0103749:	c1 e2 10             	shl    $0x10,%edx
f010374c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103752:	89 90 50 b0 20 f0    	mov    %edx,-0xfdf4fb0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103758:	e8 9e 26 00 00       	call   f0105dfb <cpunum>
f010375d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103760:	66 c7 80 54 b0 20 f0 	movw   $0x10,-0xfdf4fac(%eax)
f0103767:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103769:	83 c3 05             	add    $0x5,%ebx
f010376c:	e8 8a 26 00 00       	call   f0105dfb <cpunum>
f0103771:	89 c7                	mov    %eax,%edi
f0103773:	e8 83 26 00 00       	call   f0105dfb <cpunum>
f0103778:	89 c6                	mov    %eax,%esi
f010377a:	e8 7c 26 00 00       	call   f0105dfb <cpunum>
f010377f:	66 c7 04 dd 80 13 12 	movw   $0x67,-0xfedec80(,%ebx,8)
f0103786:	f0 67 00 
f0103789:	6b ff 74             	imul   $0x74,%edi,%edi
f010378c:	81 c7 4c b0 20 f0    	add    $0xf020b04c,%edi
f0103792:	66 89 3c dd 82 13 12 	mov    %di,-0xfedec7e(,%ebx,8)
f0103799:	f0 
f010379a:	6b d6 74             	imul   $0x74,%esi,%edx
f010379d:	81 c2 4c b0 20 f0    	add    $0xf020b04c,%edx
f01037a3:	c1 ea 10             	shr    $0x10,%edx
f01037a6:	88 14 dd 84 13 12 f0 	mov    %dl,-0xfedec7c(,%ebx,8)
f01037ad:	c6 04 dd 86 13 12 f0 	movb   $0x40,-0xfedec7a(,%ebx,8)
f01037b4:	40 
f01037b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b8:	05 4c b0 20 f0       	add    $0xf020b04c,%eax
f01037bd:	c1 e8 18             	shr    $0x18,%eax
f01037c0:	88 04 dd 87 13 12 f0 	mov    %al,-0xfedec79(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f01037c7:	c6 04 dd 85 13 12 f0 	movb   $0x89,-0xfedec7b(,%ebx,8)
f01037ce:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f01037cf:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037d2:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037d5:	b8 ea 13 12 f0       	mov    $0xf01213ea,%eax
f01037da:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01037dd:	83 c4 0c             	add    $0xc,%esp
f01037e0:	5b                   	pop    %ebx
f01037e1:	5e                   	pop    %esi
f01037e2:	5f                   	pop    %edi
f01037e3:	5d                   	pop    %ebp
f01037e4:	c3                   	ret    

f01037e5 <trap_init>:
}


void
trap_init(void)
{
f01037e5:	55                   	push   %ebp
f01037e6:	89 e5                	mov    %esp,%ebp
f01037e8:	83 ec 08             	sub    $0x8,%esp
        extern void irq11();
        extern void irq12();
        extern void irq13();
        extern void irq14();
        extern void irq15();
        SETGATE(idt[0], 0, GD_KT, i0, 0);
f01037eb:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f01037f0:	66 a3 80 a2 20 f0    	mov    %ax,0xf020a280
f01037f6:	66 c7 05 82 a2 20 f0 	movw   $0x8,0xf020a282
f01037fd:	08 00 
f01037ff:	c6 05 84 a2 20 f0 00 	movb   $0x0,0xf020a284
f0103806:	c6 05 85 a2 20 f0 8e 	movb   $0x8e,0xf020a285
f010380d:	c1 e8 10             	shr    $0x10,%eax
f0103810:	66 a3 86 a2 20 f0    	mov    %ax,0xf020a286
        SETGATE(idt[1], 0, GD_KT, i1, 0);
f0103816:	b8 86 43 10 f0       	mov    $0xf0104386,%eax
f010381b:	66 a3 88 a2 20 f0    	mov    %ax,0xf020a288
f0103821:	66 c7 05 8a a2 20 f0 	movw   $0x8,0xf020a28a
f0103828:	08 00 
f010382a:	c6 05 8c a2 20 f0 00 	movb   $0x0,0xf020a28c
f0103831:	c6 05 8d a2 20 f0 8e 	movb   $0x8e,0xf020a28d
f0103838:	c1 e8 10             	shr    $0x10,%eax
f010383b:	66 a3 8e a2 20 f0    	mov    %ax,0xf020a28e
        SETGATE(idt[2], 0, GD_KT, i2, 0);
f0103841:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103846:	66 a3 90 a2 20 f0    	mov    %ax,0xf020a290
f010384c:	66 c7 05 92 a2 20 f0 	movw   $0x8,0xf020a292
f0103853:	08 00 
f0103855:	c6 05 94 a2 20 f0 00 	movb   $0x0,0xf020a294
f010385c:	c6 05 95 a2 20 f0 8e 	movb   $0x8e,0xf020a295
f0103863:	c1 e8 10             	shr    $0x10,%eax
f0103866:	66 a3 96 a2 20 f0    	mov    %ax,0xf020a296
        SETGATE(idt[3], 0, GD_KT, i3, 3);
f010386c:	b8 9a 43 10 f0       	mov    $0xf010439a,%eax
f0103871:	66 a3 98 a2 20 f0    	mov    %ax,0xf020a298
f0103877:	66 c7 05 9a a2 20 f0 	movw   $0x8,0xf020a29a
f010387e:	08 00 
f0103880:	c6 05 9c a2 20 f0 00 	movb   $0x0,0xf020a29c
f0103887:	c6 05 9d a2 20 f0 ee 	movb   $0xee,0xf020a29d
f010388e:	c1 e8 10             	shr    $0x10,%eax
f0103891:	66 a3 9e a2 20 f0    	mov    %ax,0xf020a29e
        SETGATE(idt[4], 0, GD_KT, i4, 0);
f0103897:	b8 a4 43 10 f0       	mov    $0xf01043a4,%eax
f010389c:	66 a3 a0 a2 20 f0    	mov    %ax,0xf020a2a0
f01038a2:	66 c7 05 a2 a2 20 f0 	movw   $0x8,0xf020a2a2
f01038a9:	08 00 
f01038ab:	c6 05 a4 a2 20 f0 00 	movb   $0x0,0xf020a2a4
f01038b2:	c6 05 a5 a2 20 f0 8e 	movb   $0x8e,0xf020a2a5
f01038b9:	c1 e8 10             	shr    $0x10,%eax
f01038bc:	66 a3 a6 a2 20 f0    	mov    %ax,0xf020a2a6
        SETGATE(idt[5], 0, GD_KT, i5, 0);
f01038c2:	b8 ae 43 10 f0       	mov    $0xf01043ae,%eax
f01038c7:	66 a3 a8 a2 20 f0    	mov    %ax,0xf020a2a8
f01038cd:	66 c7 05 aa a2 20 f0 	movw   $0x8,0xf020a2aa
f01038d4:	08 00 
f01038d6:	c6 05 ac a2 20 f0 00 	movb   $0x0,0xf020a2ac
f01038dd:	c6 05 ad a2 20 f0 8e 	movb   $0x8e,0xf020a2ad
f01038e4:	c1 e8 10             	shr    $0x10,%eax
f01038e7:	66 a3 ae a2 20 f0    	mov    %ax,0xf020a2ae
        SETGATE(idt[6], 0, GD_KT, i6, 0);
f01038ed:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f01038f2:	66 a3 b0 a2 20 f0    	mov    %ax,0xf020a2b0
f01038f8:	66 c7 05 b2 a2 20 f0 	movw   $0x8,0xf020a2b2
f01038ff:	08 00 
f0103901:	c6 05 b4 a2 20 f0 00 	movb   $0x0,0xf020a2b4
f0103908:	c6 05 b5 a2 20 f0 8e 	movb   $0x8e,0xf020a2b5
f010390f:	c1 e8 10             	shr    $0x10,%eax
f0103912:	66 a3 b6 a2 20 f0    	mov    %ax,0xf020a2b6
        SETGATE(idt[7], 0, GD_KT, i7, 0);
f0103918:	b8 c2 43 10 f0       	mov    $0xf01043c2,%eax
f010391d:	66 a3 b8 a2 20 f0    	mov    %ax,0xf020a2b8
f0103923:	66 c7 05 ba a2 20 f0 	movw   $0x8,0xf020a2ba
f010392a:	08 00 
f010392c:	c6 05 bc a2 20 f0 00 	movb   $0x0,0xf020a2bc
f0103933:	c6 05 bd a2 20 f0 8e 	movb   $0x8e,0xf020a2bd
f010393a:	c1 e8 10             	shr    $0x10,%eax
f010393d:	66 a3 be a2 20 f0    	mov    %ax,0xf020a2be
        SETGATE(idt[8], 0, GD_KT, i8, 0);
f0103943:	b8 cc 43 10 f0       	mov    $0xf01043cc,%eax
f0103948:	66 a3 c0 a2 20 f0    	mov    %ax,0xf020a2c0
f010394e:	66 c7 05 c2 a2 20 f0 	movw   $0x8,0xf020a2c2
f0103955:	08 00 
f0103957:	c6 05 c4 a2 20 f0 00 	movb   $0x0,0xf020a2c4
f010395e:	c6 05 c5 a2 20 f0 8e 	movb   $0x8e,0xf020a2c5
f0103965:	c1 e8 10             	shr    $0x10,%eax
f0103968:	66 a3 c6 a2 20 f0    	mov    %ax,0xf020a2c6
        SETGATE(idt[9], 0, GD_KT, i9, 0);
f010396e:	b8 d4 43 10 f0       	mov    $0xf01043d4,%eax
f0103973:	66 a3 c8 a2 20 f0    	mov    %ax,0xf020a2c8
f0103979:	66 c7 05 ca a2 20 f0 	movw   $0x8,0xf020a2ca
f0103980:	08 00 
f0103982:	c6 05 cc a2 20 f0 00 	movb   $0x0,0xf020a2cc
f0103989:	c6 05 cd a2 20 f0 8e 	movb   $0x8e,0xf020a2cd
f0103990:	c1 e8 10             	shr    $0x10,%eax
f0103993:	66 a3 ce a2 20 f0    	mov    %ax,0xf020a2ce
        SETGATE(idt[10], 0, GD_KT, i10, 0);
f0103999:	b8 de 43 10 f0       	mov    $0xf01043de,%eax
f010399e:	66 a3 d0 a2 20 f0    	mov    %ax,0xf020a2d0
f01039a4:	66 c7 05 d2 a2 20 f0 	movw   $0x8,0xf020a2d2
f01039ab:	08 00 
f01039ad:	c6 05 d4 a2 20 f0 00 	movb   $0x0,0xf020a2d4
f01039b4:	c6 05 d5 a2 20 f0 8e 	movb   $0x8e,0xf020a2d5
f01039bb:	c1 e8 10             	shr    $0x10,%eax
f01039be:	66 a3 d6 a2 20 f0    	mov    %ax,0xf020a2d6
        SETGATE(idt[11], 0, GD_KT, i11, 0);
f01039c4:	b8 e6 43 10 f0       	mov    $0xf01043e6,%eax
f01039c9:	66 a3 d8 a2 20 f0    	mov    %ax,0xf020a2d8
f01039cf:	66 c7 05 da a2 20 f0 	movw   $0x8,0xf020a2da
f01039d6:	08 00 
f01039d8:	c6 05 dc a2 20 f0 00 	movb   $0x0,0xf020a2dc
f01039df:	c6 05 dd a2 20 f0 8e 	movb   $0x8e,0xf020a2dd
f01039e6:	c1 e8 10             	shr    $0x10,%eax
f01039e9:	66 a3 de a2 20 f0    	mov    %ax,0xf020a2de
        SETGATE(idt[12], 0, GD_KT, i12, 0);
f01039ef:	b8 ee 43 10 f0       	mov    $0xf01043ee,%eax
f01039f4:	66 a3 e0 a2 20 f0    	mov    %ax,0xf020a2e0
f01039fa:	66 c7 05 e2 a2 20 f0 	movw   $0x8,0xf020a2e2
f0103a01:	08 00 
f0103a03:	c6 05 e4 a2 20 f0 00 	movb   $0x0,0xf020a2e4
f0103a0a:	c6 05 e5 a2 20 f0 8e 	movb   $0x8e,0xf020a2e5
f0103a11:	c1 e8 10             	shr    $0x10,%eax
f0103a14:	66 a3 e6 a2 20 f0    	mov    %ax,0xf020a2e6
        SETGATE(idt[13], 0, GD_KT, i13, 0);
f0103a1a:	b8 f6 43 10 f0       	mov    $0xf01043f6,%eax
f0103a1f:	66 a3 e8 a2 20 f0    	mov    %ax,0xf020a2e8
f0103a25:	66 c7 05 ea a2 20 f0 	movw   $0x8,0xf020a2ea
f0103a2c:	08 00 
f0103a2e:	c6 05 ec a2 20 f0 00 	movb   $0x0,0xf020a2ec
f0103a35:	c6 05 ed a2 20 f0 8e 	movb   $0x8e,0xf020a2ed
f0103a3c:	c1 e8 10             	shr    $0x10,%eax
f0103a3f:	66 a3 ee a2 20 f0    	mov    %ax,0xf020a2ee
        SETGATE(idt[14], 0, GD_KT, i14, 0);
f0103a45:	b8 fe 43 10 f0       	mov    $0xf01043fe,%eax
f0103a4a:	66 a3 f0 a2 20 f0    	mov    %ax,0xf020a2f0
f0103a50:	66 c7 05 f2 a2 20 f0 	movw   $0x8,0xf020a2f2
f0103a57:	08 00 
f0103a59:	c6 05 f4 a2 20 f0 00 	movb   $0x0,0xf020a2f4
f0103a60:	c6 05 f5 a2 20 f0 8e 	movb   $0x8e,0xf020a2f5
f0103a67:	c1 e8 10             	shr    $0x10,%eax
f0103a6a:	66 a3 f6 a2 20 f0    	mov    %ax,0xf020a2f6
        SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103a70:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103a75:	66 a3 00 a3 20 f0    	mov    %ax,0xf020a300
f0103a7b:	66 c7 05 02 a3 20 f0 	movw   $0x8,0xf020a302
f0103a82:	08 00 
f0103a84:	c6 05 04 a3 20 f0 00 	movb   $0x0,0xf020a304
f0103a8b:	c6 05 05 a3 20 f0 8e 	movb   $0x8e,0xf020a305
f0103a92:	c1 e8 10             	shr    $0x10,%eax
f0103a95:	66 a3 06 a3 20 f0    	mov    %ax,0xf020a306
        SETGATE(idt[17], 0, GD_KT, i17, 0);
f0103a9b:	b8 12 44 10 f0       	mov    $0xf0104412,%eax
f0103aa0:	66 a3 08 a3 20 f0    	mov    %ax,0xf020a308
f0103aa6:	66 c7 05 0a a3 20 f0 	movw   $0x8,0xf020a30a
f0103aad:	08 00 
f0103aaf:	c6 05 0c a3 20 f0 00 	movb   $0x0,0xf020a30c
f0103ab6:	c6 05 0d a3 20 f0 8e 	movb   $0x8e,0xf020a30d
f0103abd:	c1 e8 10             	shr    $0x10,%eax
f0103ac0:	66 a3 0e a3 20 f0    	mov    %ax,0xf020a30e
        SETGATE(idt[18], 0, GD_KT, i18, 0);
f0103ac6:	b8 16 44 10 f0       	mov    $0xf0104416,%eax
f0103acb:	66 a3 10 a3 20 f0    	mov    %ax,0xf020a310
f0103ad1:	66 c7 05 12 a3 20 f0 	movw   $0x8,0xf020a312
f0103ad8:	08 00 
f0103ada:	c6 05 14 a3 20 f0 00 	movb   $0x0,0xf020a314
f0103ae1:	c6 05 15 a3 20 f0 8e 	movb   $0x8e,0xf020a315
f0103ae8:	c1 e8 10             	shr    $0x10,%eax
f0103aeb:	66 a3 16 a3 20 f0    	mov    %ax,0xf020a316
        SETGATE(idt[19], 0, GD_KT, i19, 0);
f0103af1:	b8 1c 44 10 f0       	mov    $0xf010441c,%eax
f0103af6:	66 a3 18 a3 20 f0    	mov    %ax,0xf020a318
f0103afc:	66 c7 05 1a a3 20 f0 	movw   $0x8,0xf020a31a
f0103b03:	08 00 
f0103b05:	c6 05 1c a3 20 f0 00 	movb   $0x0,0xf020a31c
f0103b0c:	c6 05 1d a3 20 f0 8e 	movb   $0x8e,0xf020a31d
f0103b13:	c1 e8 10             	shr    $0x10,%eax
f0103b16:	66 a3 1e a3 20 f0    	mov    %ax,0xf020a31e
       
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq0, 0);
f0103b1c:	b8 28 44 10 f0       	mov    $0xf0104428,%eax
f0103b21:	66 a3 80 a3 20 f0    	mov    %ax,0xf020a380
f0103b27:	66 c7 05 82 a3 20 f0 	movw   $0x8,0xf020a382
f0103b2e:	08 00 
f0103b30:	c6 05 84 a3 20 f0 00 	movb   $0x0,0xf020a384
f0103b37:	c6 05 85 a3 20 f0 8e 	movb   $0x8e,0xf020a385
f0103b3e:	c1 e8 10             	shr    $0x10,%eax
f0103b41:	66 a3 86 a3 20 f0    	mov    %ax,0xf020a386
        SETGATE(idt[33], 0, GD_KT, irq1, 0);
f0103b47:	b8 2e 44 10 f0       	mov    $0xf010442e,%eax
f0103b4c:	66 a3 88 a3 20 f0    	mov    %ax,0xf020a388
f0103b52:	66 c7 05 8a a3 20 f0 	movw   $0x8,0xf020a38a
f0103b59:	08 00 
f0103b5b:	c6 05 8c a3 20 f0 00 	movb   $0x0,0xf020a38c
f0103b62:	c6 05 8d a3 20 f0 8e 	movb   $0x8e,0xf020a38d
f0103b69:	c1 e8 10             	shr    $0x10,%eax
f0103b6c:	66 a3 8e a3 20 f0    	mov    %ax,0xf020a38e
        SETGATE(idt[34], 0, GD_KT, irq2, 0);
f0103b72:	b8 34 44 10 f0       	mov    $0xf0104434,%eax
f0103b77:	66 a3 90 a3 20 f0    	mov    %ax,0xf020a390
f0103b7d:	66 c7 05 92 a3 20 f0 	movw   $0x8,0xf020a392
f0103b84:	08 00 
f0103b86:	c6 05 94 a3 20 f0 00 	movb   $0x0,0xf020a394
f0103b8d:	c6 05 95 a3 20 f0 8e 	movb   $0x8e,0xf020a395
f0103b94:	c1 e8 10             	shr    $0x10,%eax
f0103b97:	66 a3 96 a3 20 f0    	mov    %ax,0xf020a396
        SETGATE(idt[35], 0, GD_KT, irq3, 0);
f0103b9d:	b8 3a 44 10 f0       	mov    $0xf010443a,%eax
f0103ba2:	66 a3 98 a3 20 f0    	mov    %ax,0xf020a398
f0103ba8:	66 c7 05 9a a3 20 f0 	movw   $0x8,0xf020a39a
f0103baf:	08 00 
f0103bb1:	c6 05 9c a3 20 f0 00 	movb   $0x0,0xf020a39c
f0103bb8:	c6 05 9d a3 20 f0 8e 	movb   $0x8e,0xf020a39d
f0103bbf:	c1 e8 10             	shr    $0x10,%eax
f0103bc2:	66 a3 9e a3 20 f0    	mov    %ax,0xf020a39e
        SETGATE(idt[36], 0, GD_KT, irq4, 0);
f0103bc8:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f0103bcd:	66 a3 a0 a3 20 f0    	mov    %ax,0xf020a3a0
f0103bd3:	66 c7 05 a2 a3 20 f0 	movw   $0x8,0xf020a3a2
f0103bda:	08 00 
f0103bdc:	c6 05 a4 a3 20 f0 00 	movb   $0x0,0xf020a3a4
f0103be3:	c6 05 a5 a3 20 f0 8e 	movb   $0x8e,0xf020a3a5
f0103bea:	c1 e8 10             	shr    $0x10,%eax
f0103bed:	66 a3 a6 a3 20 f0    	mov    %ax,0xf020a3a6
        SETGATE(idt[37], 0, GD_KT, irq5, 0);
f0103bf3:	b8 46 44 10 f0       	mov    $0xf0104446,%eax
f0103bf8:	66 a3 a8 a3 20 f0    	mov    %ax,0xf020a3a8
f0103bfe:	66 c7 05 aa a3 20 f0 	movw   $0x8,0xf020a3aa
f0103c05:	08 00 
f0103c07:	c6 05 ac a3 20 f0 00 	movb   $0x0,0xf020a3ac
f0103c0e:	c6 05 ad a3 20 f0 8e 	movb   $0x8e,0xf020a3ad
f0103c15:	c1 e8 10             	shr    $0x10,%eax
f0103c18:	66 a3 ae a3 20 f0    	mov    %ax,0xf020a3ae
        SETGATE(idt[38], 0, GD_KT, irq6, 0);
f0103c1e:	b8 4c 44 10 f0       	mov    $0xf010444c,%eax
f0103c23:	66 a3 b0 a3 20 f0    	mov    %ax,0xf020a3b0
f0103c29:	66 c7 05 b2 a3 20 f0 	movw   $0x8,0xf020a3b2
f0103c30:	08 00 
f0103c32:	c6 05 b4 a3 20 f0 00 	movb   $0x0,0xf020a3b4
f0103c39:	c6 05 b5 a3 20 f0 8e 	movb   $0x8e,0xf020a3b5
f0103c40:	c1 e8 10             	shr    $0x10,%eax
f0103c43:	66 a3 b6 a3 20 f0    	mov    %ax,0xf020a3b6
        SETGATE(idt[39], 0, GD_KT, irq7, 0);
f0103c49:	b8 52 44 10 f0       	mov    $0xf0104452,%eax
f0103c4e:	66 a3 b8 a3 20 f0    	mov    %ax,0xf020a3b8
f0103c54:	66 c7 05 ba a3 20 f0 	movw   $0x8,0xf020a3ba
f0103c5b:	08 00 
f0103c5d:	c6 05 bc a3 20 f0 00 	movb   $0x0,0xf020a3bc
f0103c64:	c6 05 bd a3 20 f0 8e 	movb   $0x8e,0xf020a3bd
f0103c6b:	c1 e8 10             	shr    $0x10,%eax
f0103c6e:	66 a3 be a3 20 f0    	mov    %ax,0xf020a3be
        SETGATE(idt[40], 0, GD_KT, irq8, 0);
f0103c74:	b8 58 44 10 f0       	mov    $0xf0104458,%eax
f0103c79:	66 a3 c0 a3 20 f0    	mov    %ax,0xf020a3c0
f0103c7f:	66 c7 05 c2 a3 20 f0 	movw   $0x8,0xf020a3c2
f0103c86:	08 00 
f0103c88:	c6 05 c4 a3 20 f0 00 	movb   $0x0,0xf020a3c4
f0103c8f:	c6 05 c5 a3 20 f0 8e 	movb   $0x8e,0xf020a3c5
f0103c96:	c1 e8 10             	shr    $0x10,%eax
f0103c99:	66 a3 c6 a3 20 f0    	mov    %ax,0xf020a3c6
        SETGATE(idt[41], 0, GD_KT, irq9, 0);
f0103c9f:	b8 5e 44 10 f0       	mov    $0xf010445e,%eax
f0103ca4:	66 a3 c8 a3 20 f0    	mov    %ax,0xf020a3c8
f0103caa:	66 c7 05 ca a3 20 f0 	movw   $0x8,0xf020a3ca
f0103cb1:	08 00 
f0103cb3:	c6 05 cc a3 20 f0 00 	movb   $0x0,0xf020a3cc
f0103cba:	c6 05 cd a3 20 f0 8e 	movb   $0x8e,0xf020a3cd
f0103cc1:	c1 e8 10             	shr    $0x10,%eax
f0103cc4:	66 a3 ce a3 20 f0    	mov    %ax,0xf020a3ce
        SETGATE(idt[42], 0, GD_KT, irq10, 0);
f0103cca:	b8 64 44 10 f0       	mov    $0xf0104464,%eax
f0103ccf:	66 a3 d0 a3 20 f0    	mov    %ax,0xf020a3d0
f0103cd5:	66 c7 05 d2 a3 20 f0 	movw   $0x8,0xf020a3d2
f0103cdc:	08 00 
f0103cde:	c6 05 d4 a3 20 f0 00 	movb   $0x0,0xf020a3d4
f0103ce5:	c6 05 d5 a3 20 f0 8e 	movb   $0x8e,0xf020a3d5
f0103cec:	c1 e8 10             	shr    $0x10,%eax
f0103cef:	66 a3 d6 a3 20 f0    	mov    %ax,0xf020a3d6
        SETGATE(idt[43], 0, GD_KT, irq11, 0);
f0103cf5:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103cfa:	66 a3 d8 a3 20 f0    	mov    %ax,0xf020a3d8
f0103d00:	66 c7 05 da a3 20 f0 	movw   $0x8,0xf020a3da
f0103d07:	08 00 
f0103d09:	c6 05 dc a3 20 f0 00 	movb   $0x0,0xf020a3dc
f0103d10:	c6 05 dd a3 20 f0 8e 	movb   $0x8e,0xf020a3dd
f0103d17:	c1 e8 10             	shr    $0x10,%eax
f0103d1a:	66 a3 de a3 20 f0    	mov    %ax,0xf020a3de
        SETGATE(idt[44], 0, GD_KT, irq12, 0);
f0103d20:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103d25:	66 a3 e0 a3 20 f0    	mov    %ax,0xf020a3e0
f0103d2b:	66 c7 05 e2 a3 20 f0 	movw   $0x8,0xf020a3e2
f0103d32:	08 00 
f0103d34:	c6 05 e4 a3 20 f0 00 	movb   $0x0,0xf020a3e4
f0103d3b:	c6 05 e5 a3 20 f0 8e 	movb   $0x8e,0xf020a3e5
f0103d42:	c1 e8 10             	shr    $0x10,%eax
f0103d45:	66 a3 e6 a3 20 f0    	mov    %ax,0xf020a3e6
        SETGATE(idt[45], 0, GD_KT, irq13, 0);
f0103d4b:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103d50:	66 a3 e8 a3 20 f0    	mov    %ax,0xf020a3e8
f0103d56:	66 c7 05 ea a3 20 f0 	movw   $0x8,0xf020a3ea
f0103d5d:	08 00 
f0103d5f:	c6 05 ec a3 20 f0 00 	movb   $0x0,0xf020a3ec
f0103d66:	c6 05 ed a3 20 f0 8e 	movb   $0x8e,0xf020a3ed
f0103d6d:	c1 e8 10             	shr    $0x10,%eax
f0103d70:	66 a3 ee a3 20 f0    	mov    %ax,0xf020a3ee
        SETGATE(idt[46], 0, GD_KT, irq14, 0);
f0103d76:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103d7b:	66 a3 f0 a3 20 f0    	mov    %ax,0xf020a3f0
f0103d81:	66 c7 05 f2 a3 20 f0 	movw   $0x8,0xf020a3f2
f0103d88:	08 00 
f0103d8a:	c6 05 f4 a3 20 f0 00 	movb   $0x0,0xf020a3f4
f0103d91:	c6 05 f5 a3 20 f0 8e 	movb   $0x8e,0xf020a3f5
f0103d98:	c1 e8 10             	shr    $0x10,%eax
f0103d9b:	66 a3 f6 a3 20 f0    	mov    %ax,0xf020a3f6
        SETGATE(idt[47], 0, GD_KT, irq15, 0);
f0103da1:	b8 82 44 10 f0       	mov    $0xf0104482,%eax
f0103da6:	66 a3 f8 a3 20 f0    	mov    %ax,0xf020a3f8
f0103dac:	66 c7 05 fa a3 20 f0 	movw   $0x8,0xf020a3fa
f0103db3:	08 00 
f0103db5:	c6 05 fc a3 20 f0 00 	movb   $0x0,0xf020a3fc
f0103dbc:	c6 05 fd a3 20 f0 8e 	movb   $0x8e,0xf020a3fd
f0103dc3:	c1 e8 10             	shr    $0x10,%eax
f0103dc6:	66 a3 fe a3 20 f0    	mov    %ax,0xf020a3fe
         SETGATE(idt[48], 0, GD_KT, i20, 3);
f0103dcc:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103dd1:	66 a3 00 a4 20 f0    	mov    %ax,0xf020a400
f0103dd7:	66 c7 05 02 a4 20 f0 	movw   $0x8,0xf020a402
f0103dde:	08 00 
f0103de0:	c6 05 04 a4 20 f0 00 	movb   $0x0,0xf020a404
f0103de7:	c6 05 05 a4 20 f0 ee 	movb   $0xee,0xf020a405
f0103dee:	c1 e8 10             	shr    $0x10,%eax
f0103df1:	66 a3 06 a4 20 f0    	mov    %ax,0xf020a406
	// Per-CPU setup 
	trap_init_percpu();
f0103df7:	e8 29 f9 ff ff       	call   f0103725 <trap_init_percpu>
}
f0103dfc:	c9                   	leave  
f0103dfd:	c3                   	ret    

f0103dfe <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103dfe:	55                   	push   %ebp
f0103dff:	89 e5                	mov    %esp,%ebp
f0103e01:	53                   	push   %ebx
f0103e02:	83 ec 0c             	sub    $0xc,%esp
f0103e05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e08:	ff 33                	pushl  (%ebx)
f0103e0a:	68 7b 77 10 f0       	push   $0xf010777b
f0103e0f:	e8 fd f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e14:	83 c4 08             	add    $0x8,%esp
f0103e17:	ff 73 04             	pushl  0x4(%ebx)
f0103e1a:	68 8a 77 10 f0       	push   $0xf010778a
f0103e1f:	e8 ed f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e24:	83 c4 08             	add    $0x8,%esp
f0103e27:	ff 73 08             	pushl  0x8(%ebx)
f0103e2a:	68 99 77 10 f0       	push   $0xf0107799
f0103e2f:	e8 dd f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e34:	83 c4 08             	add    $0x8,%esp
f0103e37:	ff 73 0c             	pushl  0xc(%ebx)
f0103e3a:	68 a8 77 10 f0       	push   $0xf01077a8
f0103e3f:	e8 cd f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e44:	83 c4 08             	add    $0x8,%esp
f0103e47:	ff 73 10             	pushl  0x10(%ebx)
f0103e4a:	68 b7 77 10 f0       	push   $0xf01077b7
f0103e4f:	e8 bd f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e54:	83 c4 08             	add    $0x8,%esp
f0103e57:	ff 73 14             	pushl  0x14(%ebx)
f0103e5a:	68 c6 77 10 f0       	push   $0xf01077c6
f0103e5f:	e8 ad f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e64:	83 c4 08             	add    $0x8,%esp
f0103e67:	ff 73 18             	pushl  0x18(%ebx)
f0103e6a:	68 d5 77 10 f0       	push   $0xf01077d5
f0103e6f:	e8 9d f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e74:	83 c4 08             	add    $0x8,%esp
f0103e77:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e7a:	68 e4 77 10 f0       	push   $0xf01077e4
f0103e7f:	e8 8d f8 ff ff       	call   f0103711 <cprintf>
f0103e84:	83 c4 10             	add    $0x10,%esp
}
f0103e87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e8a:	c9                   	leave  
f0103e8b:	c3                   	ret    

f0103e8c <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e8c:	55                   	push   %ebp
f0103e8d:	89 e5                	mov    %esp,%ebp
f0103e8f:	56                   	push   %esi
f0103e90:	53                   	push   %ebx
f0103e91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e94:	e8 62 1f 00 00       	call   f0105dfb <cpunum>
f0103e99:	83 ec 04             	sub    $0x4,%esp
f0103e9c:	50                   	push   %eax
f0103e9d:	53                   	push   %ebx
f0103e9e:	68 48 78 10 f0       	push   $0xf0107848
f0103ea3:	e8 69 f8 ff ff       	call   f0103711 <cprintf>
	print_regs(&tf->tf_regs);
f0103ea8:	89 1c 24             	mov    %ebx,(%esp)
f0103eab:	e8 4e ff ff ff       	call   f0103dfe <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eb7:	50                   	push   %eax
f0103eb8:	68 66 78 10 f0       	push   $0xf0107866
f0103ebd:	e8 4f f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ec2:	83 c4 08             	add    $0x8,%esp
f0103ec5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ec9:	50                   	push   %eax
f0103eca:	68 79 78 10 f0       	push   $0xf0107879
f0103ecf:	e8 3d f8 ff ff       	call   f0103711 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ed4:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ed7:	83 c4 10             	add    $0x10,%esp
f0103eda:	83 f8 13             	cmp    $0x13,%eax
f0103edd:	77 09                	ja     f0103ee8 <print_trapframe+0x5c>
		return excnames[trapno];
f0103edf:	8b 14 85 40 7b 10 f0 	mov    -0xfef84c0(,%eax,4),%edx
f0103ee6:	eb 1f                	jmp    f0103f07 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103ee8:	83 f8 30             	cmp    $0x30,%eax
f0103eeb:	74 15                	je     f0103f02 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103eed:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ef0:	83 fa 10             	cmp    $0x10,%edx
f0103ef3:	b9 12 78 10 f0       	mov    $0xf0107812,%ecx
f0103ef8:	ba ff 77 10 f0       	mov    $0xf01077ff,%edx
f0103efd:	0f 43 d1             	cmovae %ecx,%edx
f0103f00:	eb 05                	jmp    f0103f07 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f02:	ba f3 77 10 f0       	mov    $0xf01077f3,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f07:	83 ec 04             	sub    $0x4,%esp
f0103f0a:	52                   	push   %edx
f0103f0b:	50                   	push   %eax
f0103f0c:	68 8c 78 10 f0       	push   $0xf010788c
f0103f11:	e8 fb f7 ff ff       	call   f0103711 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f16:	83 c4 10             	add    $0x10,%esp
f0103f19:	3b 1d 80 aa 20 f0    	cmp    0xf020aa80,%ebx
f0103f1f:	75 1a                	jne    f0103f3b <print_trapframe+0xaf>
f0103f21:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f25:	75 14                	jne    f0103f3b <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f27:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f2a:	83 ec 08             	sub    $0x8,%esp
f0103f2d:	50                   	push   %eax
f0103f2e:	68 9e 78 10 f0       	push   $0xf010789e
f0103f33:	e8 d9 f7 ff ff       	call   f0103711 <cprintf>
f0103f38:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f3b:	83 ec 08             	sub    $0x8,%esp
f0103f3e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f41:	68 ad 78 10 f0       	push   $0xf01078ad
f0103f46:	e8 c6 f7 ff ff       	call   f0103711 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f4b:	83 c4 10             	add    $0x10,%esp
f0103f4e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f52:	75 49                	jne    f0103f9d <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f54:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f57:	89 c2                	mov    %eax,%edx
f0103f59:	83 e2 01             	and    $0x1,%edx
f0103f5c:	ba 2c 78 10 f0       	mov    $0xf010782c,%edx
f0103f61:	b9 21 78 10 f0       	mov    $0xf0107821,%ecx
f0103f66:	0f 44 ca             	cmove  %edx,%ecx
f0103f69:	89 c2                	mov    %eax,%edx
f0103f6b:	83 e2 02             	and    $0x2,%edx
f0103f6e:	ba 3e 78 10 f0       	mov    $0xf010783e,%edx
f0103f73:	be 38 78 10 f0       	mov    $0xf0107838,%esi
f0103f78:	0f 45 d6             	cmovne %esi,%edx
f0103f7b:	83 e0 04             	and    $0x4,%eax
f0103f7e:	be 8b 79 10 f0       	mov    $0xf010798b,%esi
f0103f83:	b8 43 78 10 f0       	mov    $0xf0107843,%eax
f0103f88:	0f 44 c6             	cmove  %esi,%eax
f0103f8b:	51                   	push   %ecx
f0103f8c:	52                   	push   %edx
f0103f8d:	50                   	push   %eax
f0103f8e:	68 bb 78 10 f0       	push   $0xf01078bb
f0103f93:	e8 79 f7 ff ff       	call   f0103711 <cprintf>
f0103f98:	83 c4 10             	add    $0x10,%esp
f0103f9b:	eb 10                	jmp    f0103fad <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f9d:	83 ec 0c             	sub    $0xc,%esp
f0103fa0:	68 b3 6d 10 f0       	push   $0xf0106db3
f0103fa5:	e8 67 f7 ff ff       	call   f0103711 <cprintf>
f0103faa:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fad:	83 ec 08             	sub    $0x8,%esp
f0103fb0:	ff 73 30             	pushl  0x30(%ebx)
f0103fb3:	68 ca 78 10 f0       	push   $0xf01078ca
f0103fb8:	e8 54 f7 ff ff       	call   f0103711 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fbd:	83 c4 08             	add    $0x8,%esp
f0103fc0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fc4:	50                   	push   %eax
f0103fc5:	68 d9 78 10 f0       	push   $0xf01078d9
f0103fca:	e8 42 f7 ff ff       	call   f0103711 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fcf:	83 c4 08             	add    $0x8,%esp
f0103fd2:	ff 73 38             	pushl  0x38(%ebx)
f0103fd5:	68 ec 78 10 f0       	push   $0xf01078ec
f0103fda:	e8 32 f7 ff ff       	call   f0103711 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fdf:	83 c4 10             	add    $0x10,%esp
f0103fe2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fe6:	74 25                	je     f010400d <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fe8:	83 ec 08             	sub    $0x8,%esp
f0103feb:	ff 73 3c             	pushl  0x3c(%ebx)
f0103fee:	68 fb 78 10 f0       	push   $0xf01078fb
f0103ff3:	e8 19 f7 ff ff       	call   f0103711 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ff8:	83 c4 08             	add    $0x8,%esp
f0103ffb:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fff:	50                   	push   %eax
f0104000:	68 0a 79 10 f0       	push   $0xf010790a
f0104005:	e8 07 f7 ff ff       	call   f0103711 <cprintf>
f010400a:	83 c4 10             	add    $0x10,%esp
	}
}
f010400d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104010:	5b                   	pop    %ebx
f0104011:	5e                   	pop    %esi
f0104012:	5d                   	pop    %ebp
f0104013:	c3                   	ret    

f0104014 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104014:	55                   	push   %ebp
f0104015:	89 e5                	mov    %esp,%ebp
f0104017:	57                   	push   %edi
f0104018:	56                   	push   %esi
f0104019:	53                   	push   %ebx
f010401a:	83 ec 0c             	sub    $0xc,%esp
f010401d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104020:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if ((tf->tf_cs & 3) == 0)
f0104023:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104027:	75 17                	jne    f0104040 <page_fault_handler+0x2c>
                panic("Kernel page fault!");
f0104029:	83 ec 04             	sub    $0x4,%esp
f010402c:	68 1d 79 10 f0       	push   $0xf010791d
f0104031:	68 7e 01 00 00       	push   $0x17e
f0104036:	68 30 79 10 f0       	push   $0xf0107930
f010403b:	e8 00 c0 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        if(curenv->env_pgfault_upcall) {
f0104040:	e8 b6 1d 00 00       	call   f0105dfb <cpunum>
f0104045:	6b c0 74             	imul   $0x74,%eax,%eax
f0104048:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010404e:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104052:	0f 84 8b 00 00 00    	je     f01040e3 <page_fault_handler+0xcf>
                struct UTrapframe *utf;
                if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&  tf->tf_esp <= UXSTACKTOP-1)  
f0104058:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010405b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                        utf = (struct UTrapframe *) ((void *)tf->tf_esp - sizeof(struct UTrapframe) -4);
f0104061:	83 e8 38             	sub    $0x38,%eax
f0104064:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010406a:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010406f:	0f 46 d0             	cmovbe %eax,%edx
f0104072:	89 d7                	mov    %edx,%edi
                else
                        utf = (struct UTrapframe *) ((void *)UXSTACKTOP - sizeof(struct UTrapframe));
                user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f0104074:	e8 82 1d 00 00       	call   f0105dfb <cpunum>
f0104079:	6a 03                	push   $0x3
f010407b:	6a 34                	push   $0x34
f010407d:	57                   	push   %edi
f010407e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104081:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104087:	e8 af ed ff ff       	call   f0102e3b <user_mem_assert>
                utf->utf_fault_va = fault_va;
f010408c:	89 fa                	mov    %edi,%edx
f010408e:	89 37                	mov    %esi,(%edi)
                utf->utf_err = tf->tf_err;
f0104090:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104093:	89 47 04             	mov    %eax,0x4(%edi)
                utf->utf_regs = tf->tf_regs;
f0104096:	8d 7f 08             	lea    0x8(%edi),%edi
f0104099:	b9 08 00 00 00       	mov    $0x8,%ecx
f010409e:	89 de                	mov    %ebx,%esi
f01040a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
                utf->utf_eip = tf->tf_eip;
f01040a2:	8b 43 30             	mov    0x30(%ebx),%eax
f01040a5:	89 42 28             	mov    %eax,0x28(%edx)
                utf->utf_eflags = tf->tf_eflags;
f01040a8:	8b 43 38             	mov    0x38(%ebx),%eax
f01040ab:	89 d7                	mov    %edx,%edi
f01040ad:	89 42 2c             	mov    %eax,0x2c(%edx)
                utf->utf_esp = tf->tf_esp;
f01040b0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040b3:	89 42 30             	mov    %eax,0x30(%edx)
                tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f01040b6:	e8 40 1d 00 00       	call   f0105dfb <cpunum>
f01040bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01040be:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01040c4:	8b 40 64             	mov    0x64(%eax),%eax
f01040c7:	89 43 30             	mov    %eax,0x30(%ebx)
                tf->tf_esp = (uintptr_t)utf;
f01040ca:	89 7b 3c             	mov    %edi,0x3c(%ebx)
                env_run(curenv);
f01040cd:	e8 29 1d 00 00       	call   f0105dfb <cpunum>
f01040d2:	83 c4 04             	add    $0x4,%esp
f01040d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d8:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f01040de:	e8 e6 f3 ff ff       	call   f01034c9 <env_run>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
f01040e3:	83 ec 0c             	sub    $0xc,%esp
f01040e6:	68 d8 7a 10 f0       	push   $0xf0107ad8
f01040eb:	e8 21 f6 ff ff       	call   f0103711 <cprintf>
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040f0:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040f3:	e8 03 1d 00 00       	call   f0105dfb <cpunum>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040f8:	57                   	push   %edi
f01040f9:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040fa:	6b c0 74             	imul   $0x74,%eax,%eax
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040fd:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104103:	ff 70 48             	pushl  0x48(%eax)
f0104106:	68 fc 7a 10 f0       	push   $0xf0107afc
f010410b:	e8 01 f6 ff ff       	call   f0103711 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104110:	83 c4 14             	add    $0x14,%esp
f0104113:	53                   	push   %ebx
f0104114:	e8 73 fd ff ff       	call   f0103e8c <print_trapframe>
	env_destroy(curenv);
f0104119:	e8 dd 1c 00 00       	call   f0105dfb <cpunum>
f010411e:	83 c4 04             	add    $0x4,%esp
f0104121:	6b c0 74             	imul   $0x74,%eax,%eax
f0104124:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f010412a:	e8 fb f2 ff ff       	call   f010342a <env_destroy>
f010412f:	83 c4 10             	add    $0x10,%esp
}
f0104132:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104135:	5b                   	pop    %ebx
f0104136:	5e                   	pop    %esi
f0104137:	5f                   	pop    %edi
f0104138:	5d                   	pop    %ebp
f0104139:	c3                   	ret    

f010413a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010413a:	55                   	push   %ebp
f010413b:	89 e5                	mov    %esp,%ebp
f010413d:	57                   	push   %edi
f010413e:	56                   	push   %esi
f010413f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104142:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104143:	83 3d c0 ae 20 f0 00 	cmpl   $0x0,0xf020aec0
f010414a:	74 01                	je     f010414d <trap+0x13>
		asm volatile("hlt");
f010414c:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010414d:	e8 a9 1c 00 00       	call   f0105dfb <cpunum>
f0104152:	6b d0 74             	imul   $0x74,%eax,%edx
f0104155:	81 c2 40 b0 20 f0    	add    $0xf020b040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010415b:	b8 01 00 00 00       	mov    $0x1,%eax
f0104160:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104164:	83 f8 02             	cmp    $0x2,%eax
f0104167:	75 10                	jne    f0104179 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104169:	83 ec 0c             	sub    $0xc,%esp
f010416c:	68 00 14 12 f0       	push   $0xf0121400
f0104171:	e8 f0 1e 00 00       	call   f0106066 <spin_lock>
f0104176:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104179:	9c                   	pushf  
f010417a:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010417b:	f6 c4 02             	test   $0x2,%ah
f010417e:	74 19                	je     f0104199 <trap+0x5f>
f0104180:	68 3c 79 10 f0       	push   $0xf010793c
f0104185:	68 c4 6a 10 f0       	push   $0xf0106ac4
f010418a:	68 48 01 00 00       	push   $0x148
f010418f:	68 30 79 10 f0       	push   $0xf0107930
f0104194:	e8 a7 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104199:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010419d:	83 e0 03             	and    $0x3,%eax
f01041a0:	66 83 f8 03          	cmp    $0x3,%ax
f01041a4:	0f 85 a0 00 00 00    	jne    f010424a <trap+0x110>
f01041aa:	83 ec 0c             	sub    $0xc,%esp
f01041ad:	68 00 14 12 f0       	push   $0xf0121400
f01041b2:	e8 af 1e 00 00       	call   f0106066 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f01041b7:	e8 3f 1c 00 00       	call   f0105dfb <cpunum>
f01041bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bf:	83 c4 10             	add    $0x10,%esp
f01041c2:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f01041c9:	75 19                	jne    f01041e4 <trap+0xaa>
f01041cb:	68 55 79 10 f0       	push   $0xf0107955
f01041d0:	68 c4 6a 10 f0       	push   $0xf0106ac4
f01041d5:	68 50 01 00 00       	push   $0x150
f01041da:	68 30 79 10 f0       	push   $0xf0107930
f01041df:	e8 5c be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041e4:	e8 12 1c 00 00       	call   f0105dfb <cpunum>
f01041e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ec:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01041f2:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041f6:	75 2d                	jne    f0104225 <trap+0xeb>
			env_free(curenv);
f01041f8:	e8 fe 1b 00 00       	call   f0105dfb <cpunum>
f01041fd:	83 ec 0c             	sub    $0xc,%esp
f0104200:	6b c0 74             	imul   $0x74,%eax,%eax
f0104203:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104209:	e8 76 f0 ff ff       	call   f0103284 <env_free>
			curenv = NULL;
f010420e:	e8 e8 1b 00 00       	call   f0105dfb <cpunum>
f0104213:	6b c0 74             	imul   $0x74,%eax,%eax
f0104216:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f010421d:	00 00 00 
			sched_yield();
f0104220:	e8 49 03 00 00       	call   f010456e <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104225:	e8 d1 1b 00 00       	call   f0105dfb <cpunum>
f010422a:	6b c0 74             	imul   $0x74,%eax,%eax
f010422d:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104233:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104238:	89 c7                	mov    %eax,%edi
f010423a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010423c:	e8 ba 1b 00 00       	call   f0105dfb <cpunum>
f0104241:	6b c0 74             	imul   $0x74,%eax,%eax
f0104244:	8b b0 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010424a:	89 35 80 aa 20 f0    	mov    %esi,0xf020aa80
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
        
        if(tf->tf_trapno == T_PGFLT ) {
f0104250:	8b 46 28             	mov    0x28(%esi),%eax
f0104253:	83 f8 0e             	cmp    $0xe,%eax
f0104256:	75 11                	jne    f0104269 <trap+0x12f>
                page_fault_handler(tf);
f0104258:	83 ec 0c             	sub    $0xc,%esp
f010425b:	56                   	push   %esi
f010425c:	e8 b3 fd ff ff       	call   f0104014 <page_fault_handler>
f0104261:	83 c4 10             	add    $0x10,%esp
f0104264:	e9 d2 00 00 00       	jmp    f010433b <trap+0x201>
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
f0104269:	83 f8 03             	cmp    $0x3,%eax
f010426c:	75 11                	jne    f010427f <trap+0x145>
                monitor(tf);
f010426e:	83 ec 0c             	sub    $0xc,%esp
f0104271:	56                   	push   %esi
f0104272:	e8 30 c7 ff ff       	call   f01009a7 <monitor>
f0104277:	83 c4 10             	add    $0x10,%esp
f010427a:	e9 bc 00 00 00       	jmp    f010433b <trap+0x201>
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
f010427f:	83 f8 30             	cmp    $0x30,%eax
f0104282:	75 24                	jne    f01042a8 <trap+0x16e>
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104284:	83 ec 08             	sub    $0x8,%esp
f0104287:	ff 76 04             	pushl  0x4(%esi)
f010428a:	ff 36                	pushl  (%esi)
f010428c:	ff 76 10             	pushl  0x10(%esi)
f010428f:	ff 76 18             	pushl  0x18(%esi)
f0104292:	ff 76 14             	pushl  0x14(%esi)
f0104295:	ff 76 1c             	pushl  0x1c(%esi)
f0104298:	e8 ab 03 00 00       	call   f0104648 <syscall>
f010429d:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042a0:	83 c4 20             	add    $0x20,%esp
f01042a3:	e9 93 00 00 00       	jmp    f010433b <trap+0x201>
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042a8:	83 f8 27             	cmp    $0x27,%eax
f01042ab:	75 1a                	jne    f01042c7 <trap+0x18d>
		cprintf("Spurious interrupt on irq 7\n");
f01042ad:	83 ec 0c             	sub    $0xc,%esp
f01042b0:	68 5c 79 10 f0       	push   $0xf010795c
f01042b5:	e8 57 f4 ff ff       	call   f0103711 <cprintf>
		print_trapframe(tf);
f01042ba:	89 34 24             	mov    %esi,(%esp)
f01042bd:	e8 ca fb ff ff       	call   f0103e8c <print_trapframe>
f01042c2:	83 c4 10             	add    $0x10,%esp
f01042c5:	eb 74                	jmp    f010433b <trap+0x201>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01042c7:	83 f8 20             	cmp    $0x20,%eax
f01042ca:	75 0a                	jne    f01042d6 <trap+0x19c>
                lapic_eoi();
f01042cc:	e8 75 1c 00 00       	call   f0105f46 <lapic_eoi>
                sched_yield();
f01042d1:	e8 98 02 00 00       	call   f010456e <sched_yield>
//=======
       

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
         if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01042d6:	83 f8 21             	cmp    $0x21,%eax
f01042d9:	75 0c                	jne    f01042e7 <trap+0x1ad>
                lapic_eoi();
f01042db:	e8 66 1c 00 00       	call   f0105f46 <lapic_eoi>
		kbd_intr();
f01042e0:	e8 02 c3 ff ff       	call   f01005e7 <kbd_intr>
f01042e5:	eb 54                	jmp    f010433b <trap+0x201>
		return;
	}
         if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01042e7:	83 f8 24             	cmp    $0x24,%eax
f01042ea:	75 0c                	jne    f01042f8 <trap+0x1be>
                lapic_eoi();
f01042ec:	e8 55 1c 00 00       	call   f0105f46 <lapic_eoi>
		serial_intr(); 
f01042f1:	e8 d5 c2 ff ff       	call   f01005cb <serial_intr>
f01042f6:	eb 43                	jmp    f010433b <trap+0x201>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01042f8:	83 ec 0c             	sub    $0xc,%esp
f01042fb:	56                   	push   %esi
f01042fc:	e8 8b fb ff ff       	call   f0103e8c <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104301:	83 c4 10             	add    $0x10,%esp
f0104304:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104309:	75 17                	jne    f0104322 <trap+0x1e8>
		panic("unhandled trap in kernel");
f010430b:	83 ec 04             	sub    $0x4,%esp
f010430e:	68 79 79 10 f0       	push   $0xf0107979
f0104313:	68 2f 01 00 00       	push   $0x12f
f0104318:	68 30 79 10 f0       	push   $0xf0107930
f010431d:	e8 1e bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104322:	e8 d4 1a 00 00       	call   f0105dfb <cpunum>
f0104327:	83 ec 0c             	sub    $0xc,%esp
f010432a:	6b c0 74             	imul   $0x74,%eax,%eax
f010432d:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104333:	e8 f2 f0 ff ff       	call   f010342a <env_destroy>
f0104338:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010433b:	e8 bb 1a 00 00       	call   f0105dfb <cpunum>
f0104340:	6b c0 74             	imul   $0x74,%eax,%eax
f0104343:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f010434a:	74 2a                	je     f0104376 <trap+0x23c>
f010434c:	e8 aa 1a 00 00       	call   f0105dfb <cpunum>
f0104351:	6b c0 74             	imul   $0x74,%eax,%eax
f0104354:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f010435a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010435e:	75 16                	jne    f0104376 <trap+0x23c>
		env_run(curenv);
f0104360:	e8 96 1a 00 00       	call   f0105dfb <cpunum>
f0104365:	83 ec 0c             	sub    $0xc,%esp
f0104368:	6b c0 74             	imul   $0x74,%eax,%eax
f010436b:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104371:	e8 53 f1 ff ff       	call   f01034c9 <env_run>
	else
		sched_yield();
f0104376:	e8 f3 01 00 00       	call   f010456e <sched_yield>
f010437b:	90                   	nop

f010437c <i0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(i0, T_DIVIDE)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 00                	push   $0x0
f0104380:	e9 03 01 00 00       	jmp    f0104488 <_alltraps>
f0104385:	90                   	nop

f0104386 <i1>:
TRAPHANDLER_NOEC(i1, T_DEBUG)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 01                	push   $0x1
f010438a:	e9 f9 00 00 00       	jmp    f0104488 <_alltraps>
f010438f:	90                   	nop

f0104390 <i2>:
TRAPHANDLER_NOEC(i2, T_NMI)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 02                	push   $0x2
f0104394:	e9 ef 00 00 00       	jmp    f0104488 <_alltraps>
f0104399:	90                   	nop

f010439a <i3>:
TRAPHANDLER_NOEC(i3, T_BRKPT)
f010439a:	6a 00                	push   $0x0
f010439c:	6a 03                	push   $0x3
f010439e:	e9 e5 00 00 00       	jmp    f0104488 <_alltraps>
f01043a3:	90                   	nop

f01043a4 <i4>:
TRAPHANDLER_NOEC(i4, T_OFLOW)
f01043a4:	6a 00                	push   $0x0
f01043a6:	6a 04                	push   $0x4
f01043a8:	e9 db 00 00 00       	jmp    f0104488 <_alltraps>
f01043ad:	90                   	nop

f01043ae <i5>:
TRAPHANDLER_NOEC(i5, T_BOUND)
f01043ae:	6a 00                	push   $0x0
f01043b0:	6a 05                	push   $0x5
f01043b2:	e9 d1 00 00 00       	jmp    f0104488 <_alltraps>
f01043b7:	90                   	nop

f01043b8 <i6>:
TRAPHANDLER_NOEC(i6, T_ILLOP)
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 06                	push   $0x6
f01043bc:	e9 c7 00 00 00       	jmp    f0104488 <_alltraps>
f01043c1:	90                   	nop

f01043c2 <i7>:
TRAPHANDLER_NOEC(i7, T_DEVICE)
f01043c2:	6a 00                	push   $0x0
f01043c4:	6a 07                	push   $0x7
f01043c6:	e9 bd 00 00 00       	jmp    f0104488 <_alltraps>
f01043cb:	90                   	nop

f01043cc <i8>:
TRAPHANDLER(i8, T_DBLFLT)
f01043cc:	6a 08                	push   $0x8
f01043ce:	e9 b5 00 00 00       	jmp    f0104488 <_alltraps>
f01043d3:	90                   	nop

f01043d4 <i9>:
TRAPHANDLER_NOEC(i9, 9)
f01043d4:	6a 00                	push   $0x0
f01043d6:	6a 09                	push   $0x9
f01043d8:	e9 ab 00 00 00       	jmp    f0104488 <_alltraps>
f01043dd:	90                   	nop

f01043de <i10>:
TRAPHANDLER(i10, T_TSS)
f01043de:	6a 0a                	push   $0xa
f01043e0:	e9 a3 00 00 00       	jmp    f0104488 <_alltraps>
f01043e5:	90                   	nop

f01043e6 <i11>:
TRAPHANDLER(i11, T_SEGNP)
f01043e6:	6a 0b                	push   $0xb
f01043e8:	e9 9b 00 00 00       	jmp    f0104488 <_alltraps>
f01043ed:	90                   	nop

f01043ee <i12>:
TRAPHANDLER(i12, T_STACK)
f01043ee:	6a 0c                	push   $0xc
f01043f0:	e9 93 00 00 00       	jmp    f0104488 <_alltraps>
f01043f5:	90                   	nop

f01043f6 <i13>:
TRAPHANDLER(i13, T_GPFLT)
f01043f6:	6a 0d                	push   $0xd
f01043f8:	e9 8b 00 00 00       	jmp    f0104488 <_alltraps>
f01043fd:	90                   	nop

f01043fe <i14>:
TRAPHANDLER(i14, T_PGFLT)
f01043fe:	6a 0e                	push   $0xe
f0104400:	e9 83 00 00 00       	jmp    f0104488 <_alltraps>
f0104405:	90                   	nop

f0104406 <i15>:
TRAPHANDLER_NOEC(i15, 15)
f0104406:	6a 00                	push   $0x0
f0104408:	6a 0f                	push   $0xf
f010440a:	eb 7c                	jmp    f0104488 <_alltraps>

f010440c <i16>:
TRAPHANDLER_NOEC(i16, T_FPERR)
f010440c:	6a 00                	push   $0x0
f010440e:	6a 10                	push   $0x10
f0104410:	eb 76                	jmp    f0104488 <_alltraps>

f0104412 <i17>:
TRAPHANDLER(i17, T_ALIGN)
f0104412:	6a 11                	push   $0x11
f0104414:	eb 72                	jmp    f0104488 <_alltraps>

f0104416 <i18>:
TRAPHANDLER_NOEC(i18, T_MCHK)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 12                	push   $0x12
f010441a:	eb 6c                	jmp    f0104488 <_alltraps>

f010441c <i19>:
TRAPHANDLER_NOEC(i19, T_SIMDERR)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 13                	push   $0x13
f0104420:	eb 66                	jmp    f0104488 <_alltraps>

f0104422 <i20>:
TRAPHANDLER_NOEC(i20, T_SYSCALL)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 30                	push   $0x30
f0104426:	eb 60                	jmp    f0104488 <_alltraps>

f0104428 <irq0>:

TRAPHANDLER_NOEC(irq0, IRQ_OFFSET + IRQ_TIMER)
f0104428:	6a 00                	push   $0x0
f010442a:	6a 20                	push   $0x20
f010442c:	eb 5a                	jmp    f0104488 <_alltraps>

f010442e <irq1>:
TRAPHANDLER_NOEC(irq1, IRQ_OFFSET+IRQ_KBD) 
f010442e:	6a 00                	push   $0x0
f0104430:	6a 21                	push   $0x21
f0104432:	eb 54                	jmp    f0104488 <_alltraps>

f0104434 <irq2>:
TRAPHANDLER_NOEC(irq2, 34)
f0104434:	6a 00                	push   $0x0
f0104436:	6a 22                	push   $0x22
f0104438:	eb 4e                	jmp    f0104488 <_alltraps>

f010443a <irq3>:
TRAPHANDLER_NOEC(irq3, 35)
f010443a:	6a 00                	push   $0x0
f010443c:	6a 23                	push   $0x23
f010443e:	eb 48                	jmp    f0104488 <_alltraps>

f0104440 <irq4>:
TRAPHANDLER_NOEC(irq4, IRQ_OFFSET+IRQ_SERIAL)
f0104440:	6a 00                	push   $0x0
f0104442:	6a 24                	push   $0x24
f0104444:	eb 42                	jmp    f0104488 <_alltraps>

f0104446 <irq5>:
TRAPHANDLER_NOEC(irq5, 37) 
f0104446:	6a 00                	push   $0x0
f0104448:	6a 25                	push   $0x25
f010444a:	eb 3c                	jmp    f0104488 <_alltraps>

f010444c <irq6>:
TRAPHANDLER_NOEC(irq6, 38)
f010444c:	6a 00                	push   $0x0
f010444e:	6a 26                	push   $0x26
f0104450:	eb 36                	jmp    f0104488 <_alltraps>

f0104452 <irq7>:
TRAPHANDLER_NOEC(irq7, 39)
f0104452:	6a 00                	push   $0x0
f0104454:	6a 27                	push   $0x27
f0104456:	eb 30                	jmp    f0104488 <_alltraps>

f0104458 <irq8>:
TRAPHANDLER_NOEC(irq8, 40)
f0104458:	6a 00                	push   $0x0
f010445a:	6a 28                	push   $0x28
f010445c:	eb 2a                	jmp    f0104488 <_alltraps>

f010445e <irq9>:
TRAPHANDLER_NOEC(irq9, 41) 
f010445e:	6a 00                	push   $0x0
f0104460:	6a 29                	push   $0x29
f0104462:	eb 24                	jmp    f0104488 <_alltraps>

f0104464 <irq10>:
TRAPHANDLER_NOEC(irq10, 42)
f0104464:	6a 00                	push   $0x0
f0104466:	6a 2a                	push   $0x2a
f0104468:	eb 1e                	jmp    f0104488 <_alltraps>

f010446a <irq11>:
TRAPHANDLER_NOEC(irq11, 43)
f010446a:	6a 00                	push   $0x0
f010446c:	6a 2b                	push   $0x2b
f010446e:	eb 18                	jmp    f0104488 <_alltraps>

f0104470 <irq12>:
TRAPHANDLER_NOEC(irq12, 44)
f0104470:	6a 00                	push   $0x0
f0104472:	6a 2c                	push   $0x2c
f0104474:	eb 12                	jmp    f0104488 <_alltraps>

f0104476 <irq13>:
TRAPHANDLER_NOEC(irq13, 45) 
f0104476:	6a 00                	push   $0x0
f0104478:	6a 2d                	push   $0x2d
f010447a:	eb 0c                	jmp    f0104488 <_alltraps>

f010447c <irq14>:
TRAPHANDLER_NOEC(irq14, 46)
f010447c:	6a 00                	push   $0x0
f010447e:	6a 2e                	push   $0x2e
f0104480:	eb 06                	jmp    f0104488 <_alltraps>

f0104482 <irq15>:
TRAPHANDLER_NOEC(irq15, 47)
f0104482:	6a 00                	push   $0x0
f0104484:	6a 2f                	push   $0x2f
f0104486:	eb 00                	jmp    f0104488 <_alltraps>

f0104488 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f0104488:	1e                   	push   %ds
        pushl %es
f0104489:	06                   	push   %es
        pushal
f010448a:	60                   	pusha  
        mov $GD_KD, %eax
f010448b:	b8 10 00 00 00       	mov    $0x10,%eax
        mov %eax, %ds
f0104490:	8e d8                	mov    %eax,%ds
        mov %eax, %es
f0104492:	8e c0                	mov    %eax,%es
        pushl %esp
f0104494:	54                   	push   %esp
        call trap
f0104495:	e8 a0 fc ff ff       	call   f010413a <trap>

f010449a <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010449a:	55                   	push   %ebp
f010449b:	89 e5                	mov    %esp,%ebp
f010449d:	83 ec 08             	sub    $0x8,%esp
f01044a0:	a1 68 a2 20 f0       	mov    0xf020a268,%eax
f01044a5:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044ad:	8b 02                	mov    (%edx),%eax
f01044af:	83 e8 01             	sub    $0x1,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044b2:	83 f8 02             	cmp    $0x2,%eax
f01044b5:	76 10                	jbe    f01044c7 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044b7:	83 c1 01             	add    $0x1,%ecx
f01044ba:	83 c2 7c             	add    $0x7c,%edx
f01044bd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044c3:	75 e8                	jne    f01044ad <sched_halt+0x13>
f01044c5:	eb 08                	jmp    f01044cf <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044c7:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044cd:	75 1f                	jne    f01044ee <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01044cf:	83 ec 0c             	sub    $0xc,%esp
f01044d2:	68 90 7b 10 f0       	push   $0xf0107b90
f01044d7:	e8 35 f2 ff ff       	call   f0103711 <cprintf>
f01044dc:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044df:	83 ec 0c             	sub    $0xc,%esp
f01044e2:	6a 00                	push   $0x0
f01044e4:	e8 be c4 ff ff       	call   f01009a7 <monitor>
f01044e9:	83 c4 10             	add    $0x10,%esp
f01044ec:	eb f1                	jmp    f01044df <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044ee:	e8 08 19 00 00       	call   f0105dfb <cpunum>
f01044f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f6:	c7 80 48 b0 20 f0 00 	movl   $0x0,-0xfdf4fb8(%eax)
f01044fd:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104500:	a1 cc ae 20 f0       	mov    0xf020aecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104505:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010450a:	77 12                	ja     f010451e <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010450c:	50                   	push   %eax
f010450d:	68 08 65 10 f0       	push   $0xf0106508
f0104512:	6a 4a                	push   $0x4a
f0104514:	68 b9 7b 10 f0       	push   $0xf0107bb9
f0104519:	e8 22 bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010451e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104523:	0f 22 d8             	mov    %eax,%cr3
	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104526:	e8 d0 18 00 00       	call   f0105dfb <cpunum>
f010452b:	6b d0 74             	imul   $0x74,%eax,%edx
f010452e:	81 c2 40 b0 20 f0    	add    $0xf020b040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104534:	b8 02 00 00 00       	mov    $0x2,%eax
f0104539:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010453d:	83 ec 0c             	sub    $0xc,%esp
f0104540:	68 00 14 12 f0       	push   $0xf0121400
f0104545:	e8 b9 1b 00 00       	call   f0106103 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010454a:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010454c:	e8 aa 18 00 00       	call   f0105dfb <cpunum>
f0104551:	6b c0 74             	imul   $0x74,%eax,%eax
	xchg(&thiscpu->cpu_status, CPU_HALTED);
	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104554:	8b 80 50 b0 20 f0    	mov    -0xfdf4fb0(%eax),%eax
f010455a:	bd 00 00 00 00       	mov    $0x0,%ebp
f010455f:	89 c4                	mov    %eax,%esp
f0104561:	6a 00                	push   $0x0
f0104563:	6a 00                	push   $0x0
f0104565:	fb                   	sti    
f0104566:	f4                   	hlt    
f0104567:	eb fd                	jmp    f0104566 <sched_halt+0xcc>
f0104569:	83 c4 10             	add    $0x10,%esp
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010456c:	c9                   	leave  
f010456d:	c3                   	ret    

f010456e <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010456e:	55                   	push   %ebp
f010456f:	89 e5                	mov    %esp,%ebp
f0104571:	56                   	push   %esi
f0104572:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f0104573:	e8 83 18 00 00       	call   f0105dfb <cpunum>
f0104578:	6b c0 74             	imul   $0x74,%eax,%eax
        else cur = 0;
f010457b:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f0104580:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f0104587:	74 17                	je     f01045a0 <sched_yield+0x32>
f0104589:	e8 6d 18 00 00       	call   f0105dfb <cpunum>
f010458e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104591:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104597:	8b 48 48             	mov    0x48(%eax),%ecx
f010459a:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045a0:	8b 35 68 a2 20 f0    	mov    0xf020a268,%esi
f01045a6:	89 ca                	mov    %ecx,%edx
f01045a8:	81 c1 00 04 00 00    	add    $0x400,%ecx
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
f01045ae:	89 d3                	mov    %edx,%ebx
f01045b0:	c1 fb 1f             	sar    $0x1f,%ebx
f01045b3:	c1 eb 16             	shr    $0x16,%ebx
f01045b6:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01045b9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045be:	29 d8                	sub    %ebx,%eax
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045c3:	89 c3                	mov    %eax,%ebx
f01045c5:	83 7c 06 54 02       	cmpl   $0x2,0x54(%esi,%eax,1)
f01045ca:	75 14                	jne    f01045e0 <sched_yield+0x72>
                      envs[j].env_cpunum == cpunum();
f01045cc:	e8 2a 18 00 00       	call   f0105dfb <cpunum>
                      env_run(envs + j);
f01045d1:	83 ec 0c             	sub    $0xc,%esp
f01045d4:	03 1d 68 a2 20 f0    	add    0xf020a268,%ebx
f01045da:	53                   	push   %ebx
f01045db:	e8 e9 ee ff ff       	call   f01034c9 <env_run>
f01045e0:	83 c2 01             	add    $0x1,%edx
	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
f01045e3:	39 ca                	cmp    %ecx,%edx
f01045e5:	75 c7                	jne    f01045ae <sched_yield+0x40>
              if (envs[j].env_status == ENV_RUNNABLE) {
                      envs[j].env_cpunum == cpunum();
                      env_run(envs + j);
              }
        }
        if (curenv && curenv->env_status == ENV_RUNNING && cpunum() == curenv->env_cpunum) {
f01045e7:	e8 0f 18 00 00       	call   f0105dfb <cpunum>
f01045ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ef:	83 b8 48 b0 20 f0 00 	cmpl   $0x0,-0xfdf4fb8(%eax)
f01045f6:	74 44                	je     f010463c <sched_yield+0xce>
f01045f8:	e8 fe 17 00 00       	call   f0105dfb <cpunum>
f01045fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104600:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104606:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010460a:	75 30                	jne    f010463c <sched_yield+0xce>
f010460c:	e8 ea 17 00 00       	call   f0105dfb <cpunum>
f0104611:	89 c3                	mov    %eax,%ebx
f0104613:	e8 e3 17 00 00       	call   f0105dfb <cpunum>
f0104618:	6b d0 74             	imul   $0x74,%eax,%edx
f010461b:	8b 82 48 b0 20 f0    	mov    -0xfdf4fb8(%edx),%eax
f0104621:	3b 58 5c             	cmp    0x5c(%eax),%ebx
f0104624:	75 16                	jne    f010463c <sched_yield+0xce>
               env_run(curenv);
f0104626:	e8 d0 17 00 00       	call   f0105dfb <cpunum>
f010462b:	83 ec 0c             	sub    $0xc,%esp
f010462e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104631:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104637:	e8 8d ee ff ff       	call   f01034c9 <env_run>
        }
	// sched_halt never returns
	sched_halt();
f010463c:	e8 59 fe ff ff       	call   f010449a <sched_halt>
}
f0104641:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104644:	5b                   	pop    %ebx
f0104645:	5e                   	pop    %esi
f0104646:	5d                   	pop    %ebp
f0104647:	c3                   	ret    

f0104648 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104648:	55                   	push   %ebp
f0104649:	89 e5                	mov    %esp,%ebp
f010464b:	57                   	push   %edi
f010464c:	56                   	push   %esi
f010464d:	53                   	push   %ebx
f010464e:	83 ec 1c             	sub    $0x1c,%esp
f0104651:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
f0104654:	83 f8 0d             	cmp    $0xd,%eax
f0104657:	0f 87 dc 05 00 00    	ja     f0104c39 <syscall+0x5f1>
f010465d:	ff 24 85 cc 7b 10 f0 	jmp    *-0xfef8434(,%eax,4)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104664:	e8 92 17 00 00       	call   f0105dfb <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104669:	83 ec 04             	sub    $0x4,%esp
f010466c:	6a 01                	push   $0x1
f010466e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104671:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104672:	6b c0 74             	imul   $0x74,%eax,%eax
f0104675:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010467b:	ff 70 48             	pushl  0x48(%eax)
f010467e:	e8 7f e8 ff ff       	call   f0102f02 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104683:	6a 04                	push   $0x4
f0104685:	ff 75 10             	pushl  0x10(%ebp)
f0104688:	ff 75 0c             	pushl  0xc(%ebp)
f010468b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010468e:	e8 a8 e7 ff ff       	call   f0102e3b <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104693:	83 c4 1c             	add    $0x1c,%esp
f0104696:	ff 75 0c             	pushl  0xc(%ebp)
f0104699:	ff 75 10             	pushl  0x10(%ebp)
f010469c:	68 c6 7b 10 f0       	push   $0xf0107bc6
f01046a1:	e8 6b f0 ff ff       	call   f0103711 <cprintf>
f01046a6:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
        case SYS_cputs:
                sys_cputs((char *)a1, a2);
                rslt = 0;
f01046a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046ae:	e9 92 05 00 00       	jmp    f0104c45 <syscall+0x5fd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046b3:	e8 41 bf ff ff       	call   f01005f9 <cons_getc>
f01046b8:	89 c3                	mov    %eax,%ebx
                sys_cputs((char *)a1, a2);
                rslt = 0;
                break;
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
f01046ba:	e9 86 05 00 00       	jmp    f0104c45 <syscall+0x5fd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046bf:	e8 37 17 00 00       	call   f0105dfb <cpunum>
f01046c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c7:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f01046cd:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
	case SYS_getenvid:
                rslt = sys_getenvid();
                break;
f01046d0:	e9 70 05 00 00       	jmp    f0104c45 <syscall+0x5fd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046d5:	83 ec 04             	sub    $0x4,%esp
f01046d8:	6a 01                	push   $0x1
f01046da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046dd:	50                   	push   %eax
f01046de:	ff 75 0c             	pushl  0xc(%ebp)
f01046e1:	e8 1c e8 ff ff       	call   f0102f02 <envid2env>
f01046e6:	83 c4 10             	add    $0x10,%esp
		return r;
f01046e9:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046eb:	85 c0                	test   %eax,%eax
f01046ed:	0f 88 52 05 00 00    	js     f0104c45 <syscall+0x5fd>
		return r;
	env_destroy(e);
f01046f3:	83 ec 0c             	sub    $0xc,%esp
f01046f6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046f9:	e8 2c ed ff ff       	call   f010342a <env_destroy>
f01046fe:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104701:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104706:	e9 3a 05 00 00       	jmp    f0104c45 <syscall+0x5fd>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010470b:	e8 5e fe ff ff       	call   f010456e <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f0104710:	e8 e6 16 00 00       	call   f0105dfb <cpunum>
f0104715:	83 ec 08             	sub    $0x8,%esp
f0104718:	6b c0 74             	imul   $0x74,%eax,%eax
f010471b:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104721:	ff 70 48             	pushl  0x48(%eax)
f0104724:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104727:	50                   	push   %eax
f0104728:	e8 da e8 ff ff       	call   f0103007 <env_alloc>
f010472d:	83 c4 10             	add    $0x10,%esp
                return ret;
f0104730:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f0104732:	85 c0                	test   %eax,%eax
f0104734:	0f 85 0b 05 00 00    	jne    f0104c45 <syscall+0x5fd>
                return ret;
        
        newenv->env_status = ENV_NOT_RUNNABLE;
f010473a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010473d:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
        newenv->env_tf = curenv->env_tf; 
f0104744:	e8 b2 16 00 00       	call   f0105dfb <cpunum>
f0104749:	6b c0 74             	imul   $0x74,%eax,%eax
f010474c:	8b b0 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%esi
f0104752:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104757:	89 df                	mov    %ebx,%edi
f0104759:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        newenv->env_tf.tf_regs.reg_eax = 0;
f010475b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010475e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return newenv->env_id;
f0104765:	8b 58 48             	mov    0x48(%eax),%ebx
f0104768:	e9 d8 04 00 00       	jmp    f0104c45 <syscall+0x5fd>

	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f010476d:	83 ec 04             	sub    $0x4,%esp
f0104770:	6a 01                	push   $0x1
f0104772:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104775:	50                   	push   %eax
f0104776:	ff 75 0c             	pushl  0xc(%ebp)
f0104779:	e8 84 e7 ff ff       	call   f0102f02 <envid2env>
f010477e:	83 c4 10             	add    $0x10,%esp
f0104781:	85 c0                	test   %eax,%eax
f0104783:	0f 85 ba 00 00 00    	jne    f0104843 <syscall+0x1fb>
                return rslt;
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f0104789:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104790:	0f 87 b4 00 00 00    	ja     f010484a <syscall+0x202>
f0104796:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010479d:	0f 85 b1 00 00 00    	jne    f0104854 <syscall+0x20c>
                return -E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01047a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01047a6:	83 e0 05             	and    $0x5,%eax
f01047a9:	83 f8 05             	cmp    $0x5,%eax
f01047ac:	0f 85 ac 00 00 00    	jne    f010485e <syscall+0x216>
                return -E_INVAL;
        if((p = page_alloc(1)) == (void*)NULL)
f01047b2:	83 ec 0c             	sub    $0xc,%esp
f01047b5:	6a 01                	push   $0x1
f01047b7:	e8 f5 c7 ff ff       	call   f0100fb1 <page_alloc>
f01047bc:	89 c6                	mov    %eax,%esi
f01047be:	83 c4 10             	add    $0x10,%esp
f01047c1:	85 c0                	test   %eax,%eax
f01047c3:	0f 84 9f 00 00 00    	je     f0104868 <syscall+0x220>
                return -E_NO_MEM;
        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) {
f01047c9:	ff 75 14             	pushl  0x14(%ebp)
f01047cc:	ff 75 10             	pushl  0x10(%ebp)
f01047cf:	50                   	push   %eax
f01047d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047d3:	ff 70 60             	pushl  0x60(%eax)
f01047d6:	e8 ec ca ff ff       	call   f01012c7 <page_insert>
f01047db:	89 c3                	mov    %eax,%ebx
f01047dd:	83 c4 10             	add    $0x10,%esp
f01047e0:	85 c0                	test   %eax,%eax
f01047e2:	74 11                	je     f01047f5 <syscall+0x1ad>
                page_free(p);
f01047e4:	83 ec 0c             	sub    $0xc,%esp
f01047e7:	56                   	push   %esi
f01047e8:	e8 32 c8 ff ff       	call   f010101f <page_free>
f01047ed:	83 c4 10             	add    $0x10,%esp
f01047f0:	e9 50 04 00 00       	jmp    f0104c45 <syscall+0x5fd>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01047f5:	2b 35 d0 ae 20 f0    	sub    0xf020aed0,%esi
f01047fb:	c1 fe 03             	sar    $0x3,%esi
f01047fe:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104801:	89 f0                	mov    %esi,%eax
f0104803:	c1 e8 0c             	shr    $0xc,%eax
f0104806:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f010480c:	72 12                	jb     f0104820 <syscall+0x1d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010480e:	56                   	push   %esi
f010480f:	68 e4 64 10 f0       	push   $0xf01064e4
f0104814:	6a 58                	push   $0x58
f0104816:	68 aa 6a 10 f0       	push   $0xf0106aaa
f010481b:	e8 20 b8 ff ff       	call   f0100040 <_panic>
                return rslt;
        }
        memset(page2kva(p), 0, PGSIZE);
f0104820:	83 ec 04             	sub    $0x4,%esp
f0104823:	68 00 10 00 00       	push   $0x1000
f0104828:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010482a:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0104830:	56                   	push   %esi
f0104831:	e8 a2 0f 00 00       	call   f01057d8 <memset>
f0104836:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104839:	bb 00 00 00 00       	mov    $0x0,%ebx
f010483e:	e9 02 04 00 00       	jmp    f0104c45 <syscall+0x5fd>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;
f0104843:	89 c3                	mov    %eax,%ebx
f0104845:	e9 fb 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL;
f010484a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010484f:	e9 f1 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
f0104854:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104859:	e9 e7 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010485e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104863:	e9 dd 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((p = page_alloc(1)) == (void*)NULL)
                return -E_NO_MEM;
f0104868:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
        case SYS_exofork:
                rslt = sys_exofork();
                break;
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
f010486d:	e9 d3 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f0104872:	83 ec 04             	sub    $0x4,%esp
f0104875:	6a 01                	push   $0x1
f0104877:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010487a:	50                   	push   %eax
f010487b:	ff 75 0c             	pushl  0xc(%ebp)
f010487e:	e8 7f e6 ff ff       	call   f0102f02 <envid2env>
f0104883:	83 c4 10             	add    $0x10,%esp
                return rslt;
f0104886:	89 c3                	mov    %eax,%ebx
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f0104888:	85 c0                	test   %eax,%eax
f010488a:	0f 85 b5 03 00 00    	jne    f0104c45 <syscall+0x5fd>
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f0104890:	83 ec 04             	sub    $0x4,%esp
f0104893:	6a 01                	push   $0x1
f0104895:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104898:	50                   	push   %eax
f0104899:	ff 75 14             	pushl  0x14(%ebp)
f010489c:	e8 61 e6 ff ff       	call   f0102f02 <envid2env>
f01048a1:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01048a4:	89 c3                	mov    %eax,%ebx
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048a6:	85 c0                	test   %eax,%eax
f01048a8:	0f 85 97 03 00 00    	jne    f0104c45 <syscall+0x5fd>
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
f01048ae:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048b5:	77 73                	ja     f010492a <syscall+0x2e2>
                return -E_INVAL;
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
f01048b7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048be:	75 74                	jne    f0104934 <syscall+0x2ec>
f01048c0:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048c7:	77 6b                	ja     f0104934 <syscall+0x2ec>
f01048c9:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048d0:	75 6c                	jne    f010493e <syscall+0x2f6>
                return -E_INVAL;
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
f01048d2:	83 ec 04             	sub    $0x4,%esp
f01048d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d8:	50                   	push   %eax
f01048d9:	ff 75 10             	pushl  0x10(%ebp)
f01048dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048df:	ff 70 60             	pushl  0x60(%eax)
f01048e2:	e8 f4 c8 ff ff       	call   f01011db <page_lookup>
f01048e7:	83 c4 10             	add    $0x10,%esp
f01048ea:	85 c0                	test   %eax,%eax
f01048ec:	74 5a                	je     f0104948 <syscall+0x300>
f01048ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048f1:	8b 12                	mov    (%edx),%edx
f01048f3:	f6 c2 01             	test   $0x1,%dl
f01048f6:	74 5a                	je     f0104952 <syscall+0x30a>
                return 	-E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f01048f8:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f01048fb:	83 e1 05             	and    $0x5,%ecx
f01048fe:	83 f9 05             	cmp    $0x5,%ecx
f0104901:	75 59                	jne    f010495c <syscall+0x314>
                return -E_INVAL;
        if((perm & PTE_W) && !(*srcpte & PTE_W))
f0104903:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104907:	74 05                	je     f010490e <syscall+0x2c6>
f0104909:	f6 c2 02             	test   $0x2,%dl
f010490c:	74 58                	je     f0104966 <syscall+0x31e>
                return -E_INVAL;
        rslt =  page_insert(dst->env_pgdir, pg, dstva, perm);
f010490e:	ff 75 1c             	pushl  0x1c(%ebp)
f0104911:	ff 75 18             	pushl  0x18(%ebp)
f0104914:	50                   	push   %eax
f0104915:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104918:	ff 70 60             	pushl  0x60(%eax)
f010491b:	e8 a7 c9 ff ff       	call   f01012c7 <page_insert>
f0104920:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104923:	89 c3                	mov    %eax,%ebx
f0104925:	e9 1b 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
                return -E_INVAL;
f010492a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010492f:	e9 11 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
                return -E_INVAL;
f0104934:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104939:	e9 07 03 00 00       	jmp    f0104c45 <syscall+0x5fd>
f010493e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104943:	e9 fd 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
                return 	-E_INVAL;
f0104948:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494d:	e9 f3 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
f0104952:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104957:	e9 e9 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010495c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104961:	e9 df 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if((perm & PTE_W) && !(*srcpte & PTE_W))
                return -E_INVAL;
f0104966:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
f010496b:	e9 d5 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f0104970:	83 ec 04             	sub    $0x4,%esp
f0104973:	6a 01                	push   $0x1
f0104975:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104978:	50                   	push   %eax
f0104979:	ff 75 0c             	pushl  0xc(%ebp)
f010497c:	e8 81 e5 ff ff       	call   f0102f02 <envid2env>
f0104981:	83 c4 10             	add    $0x10,%esp
                return rslt;  
f0104984:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f0104986:	85 c0                	test   %eax,%eax
f0104988:	0f 85 b7 02 00 00    	jne    f0104c45 <syscall+0x5fd>
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f010498e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104995:	77 27                	ja     f01049be <syscall+0x376>
f0104997:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010499e:	75 28                	jne    f01049c8 <syscall+0x380>
                return -E_INVAL; 
        page_remove(tmp->env_pgdir, va);
f01049a0:	83 ec 08             	sub    $0x8,%esp
f01049a3:	ff 75 10             	pushl  0x10(%ebp)
f01049a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a9:	ff 70 60             	pushl  0x60(%eax)
f01049ac:	e8 c5 c8 ff ff       	call   f0101276 <page_remove>
f01049b1:	83 c4 10             	add    $0x10,%esp
        return 0;
f01049b4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049b9:	e9 87 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL; 
f01049be:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c3:	e9 7d 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
f01049c8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
	case SYS_page_unmap:
                rslt = sys_page_unmap(a1, (void *)a2);
                break;
f01049cd:	e9 73 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
	// envid's status.

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01049d2:	8b 45 10             	mov    0x10(%ebp),%eax
f01049d5:	83 e8 02             	sub    $0x2,%eax
f01049d8:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01049dd:	75 2c                	jne    f0104a0b <syscall+0x3c3>
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f01049df:	83 ec 04             	sub    $0x4,%esp
f01049e2:	6a 01                	push   $0x1
f01049e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049e7:	50                   	push   %eax
f01049e8:	ff 75 0c             	pushl  0xc(%ebp)
f01049eb:	e8 12 e5 ff ff       	call   f0102f02 <envid2env>
f01049f0:	83 c4 10             	add    $0x10,%esp
                tmp->env_status = status;
        return rslt;     
f01049f3:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f01049f5:	85 c0                	test   %eax,%eax
f01049f7:	0f 85 48 02 00 00    	jne    f0104c45 <syscall+0x5fd>
                tmp->env_status = status;
f01049fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a03:	89 4a 54             	mov    %ecx,0x54(%edx)
f0104a06:	e9 3a 02 00 00       	jmp    f0104c45 <syscall+0x5fd>

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
f0104a0b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a10:	e9 30 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a15:	83 ec 04             	sub    $0x4,%esp
f0104a18:	6a 01                	push   $0x1
f0104a1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a1d:	50                   	push   %eax
f0104a1e:	ff 75 0c             	pushl  0xc(%ebp)
f0104a21:	e8 dc e4 ff ff       	call   f0102f02 <envid2env>
f0104a26:	83 c4 10             	add    $0x10,%esp
f0104a29:	85 c0                	test   %eax,%eax
f0104a2b:	75 09                	jne    f0104a36 <syscall+0x3ee>
                tmp->env_pgfault_upcall = func;
f0104a2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a30:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a33:	89 7a 64             	mov    %edi,0x64(%edx)
                break;
        case SYS_env_set_status:
                rslt = sys_env_set_status(a1, a2);
                break;
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104a36:	89 c3                	mov    %eax,%ebx
                break;
f0104a38:	e9 08 02 00 00       	jmp    f0104c45 <syscall+0x5fd>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
f0104a3d:	83 ec 04             	sub    $0x4,%esp
f0104a40:	6a 00                	push   $0x0
f0104a42:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a45:	50                   	push   %eax
f0104a46:	ff 75 0c             	pushl  0xc(%ebp)
f0104a49:	e8 b4 e4 ff ff       	call   f0102f02 <envid2env>
f0104a4e:	83 c4 10             	add    $0x10,%esp
f0104a51:	85 c0                	test   %eax,%eax
f0104a53:	0f 88 07 01 00 00    	js     f0104b60 <syscall+0x518>
                return -E_BAD_ENV;
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
f0104a59:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a5c:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a60:	0f 84 04 01 00 00    	je     f0104b6a <syscall+0x522>
f0104a66:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a69:	85 db                	test   %ebx,%ebx
f0104a6b:	0f 85 03 01 00 00    	jne    f0104b74 <syscall+0x52c>
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
f0104a71:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a78:	0f 87 ab 00 00 00    	ja     f0104b29 <syscall+0x4e1>
                if((size_t)srcva % PGSIZE)
f0104a7e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a85:	75 70                	jne    f0104af7 <syscall+0x4af>
                        return -E_INVAL;
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
f0104a87:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a8a:	83 e0 05             	and    $0x5,%eax
f0104a8d:	83 f8 05             	cmp    $0x5,%eax
f0104a90:	75 6f                	jne    f0104b01 <syscall+0x4b9>
                        return -E_INVAL;
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104a92:	e8 64 13 00 00       	call   f0105dfb <cpunum>
f0104a97:	83 ec 04             	sub    $0x4,%esp
f0104a9a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a9d:	52                   	push   %edx
f0104a9e:	ff 75 14             	pushl  0x14(%ebp)
f0104aa1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa4:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104aaa:	ff 70 60             	pushl  0x60(%eax)
f0104aad:	e8 29 c7 ff ff       	call   f01011db <page_lookup>
                if(!pg) return -E_INVAL;
f0104ab2:	83 c4 10             	add    $0x10,%esp
f0104ab5:	85 c0                	test   %eax,%eax
f0104ab7:	74 52                	je     f0104b0b <syscall+0x4c3>
                if( (perm & PTE_W) && !(*pte & PTE_W))
f0104ab9:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104abd:	74 08                	je     f0104ac7 <syscall+0x47f>
f0104abf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ac2:	f6 02 02             	testb  $0x2,(%edx)
f0104ac5:	74 4e                	je     f0104b15 <syscall+0x4cd>
                        return -E_INVAL;
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
f0104ac7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104aca:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104acd:	8d 71 ff             	lea    -0x1(%ecx),%esi
f0104ad0:	81 fe fe ff bf ee    	cmp    $0xeebffffe,%esi
f0104ad6:	77 51                	ja     f0104b29 <syscall+0x4e1>
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
f0104ad8:	ff 75 18             	pushl  0x18(%ebp)
f0104adb:	51                   	push   %ecx
f0104adc:	50                   	push   %eax
f0104add:	ff 72 60             	pushl  0x60(%edx)
f0104ae0:	e8 e2 c7 ff ff       	call   f01012c7 <page_insert>
f0104ae5:	83 c4 10             	add    $0x10,%esp
f0104ae8:	85 c0                	test   %eax,%eax
f0104aea:	78 33                	js     f0104b1f <syscall+0x4d7>
                                return -E_NO_MEM;
                        target->env_ipc_perm = perm;
f0104aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aef:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104af2:	89 78 78             	mov    %edi,0x78(%eax)
f0104af5:	eb 32                	jmp    f0104b29 <syscall+0x4e1>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
                if((size_t)srcva % PGSIZE)
                        return -E_INVAL;
f0104af7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104afc:	e9 44 01 00 00       	jmp    f0104c45 <syscall+0x5fd>
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
                        return -E_INVAL;
f0104b01:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b06:	e9 3a 01 00 00       	jmp    f0104c45 <syscall+0x5fd>
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
                if(!pg) return -E_INVAL;
f0104b0b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b10:	e9 30 01 00 00       	jmp    f0104c45 <syscall+0x5fd>
                if( (perm & PTE_W) && !(*pte & PTE_W))
                        return -E_INVAL;
f0104b15:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b1a:	e9 26 01 00 00       	jmp    f0104c45 <syscall+0x5fd>
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
                                return -E_NO_MEM;
f0104b1f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b24:	e9 1c 01 00 00       	jmp    f0104c45 <syscall+0x5fd>
                        target->env_ipc_perm = perm;
                }
        }
        target->env_ipc_recving = 0;
f0104b29:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b2c:	c6 46 68 00          	movb   $0x0,0x68(%esi)
        target->env_ipc_value = value;
f0104b30:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b33:	89 46 70             	mov    %eax,0x70(%esi)
        target->env_ipc_from = curenv->env_id;
f0104b36:	e8 c0 12 00 00       	call   f0105dfb <cpunum>
f0104b3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3e:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104b44:	8b 40 48             	mov    0x48(%eax),%eax
f0104b47:	89 46 74             	mov    %eax,0x74(%esi)
        target->env_tf.tf_regs.reg_eax = 0;
f0104b4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b4d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        target->env_status = ENV_RUNNABLE;
f0104b54:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104b5b:	e9 e5 00 00 00       	jmp    f0104c45 <syscall+0x5fd>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
                return -E_BAD_ENV;
f0104b60:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104b65:	e9 db 00 00 00       	jmp    f0104c45 <syscall+0x5fd>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
f0104b6a:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b6f:	e9 d1 00 00 00       	jmp    f0104c45 <syscall+0x5fd>
f0104b74:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
f0104b79:	e9 c7 00 00 00       	jmp    f0104c45 <syscall+0x5fd>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
        if((dstva < (void *)UTOP) && ((size_t)dstva % PGSIZE))
f0104b7e:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b85:	77 0d                	ja     f0104b94 <syscall+0x54c>
f0104b87:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b8e:	0f 85 ac 00 00 00    	jne    f0104c40 <syscall+0x5f8>
                        return -E_INVAL;
        curenv->env_ipc_recving = 1;
f0104b94:	e8 62 12 00 00       	call   f0105dfb <cpunum>
f0104b99:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9c:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104ba2:	c6 40 68 01          	movb   $0x1,0x68(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0104ba6:	e8 50 12 00 00       	call   f0105dfb <cpunum>
f0104bab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bae:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bb4:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_dstva = dstva;
f0104bbb:	e8 3b 12 00 00       	call   f0105dfb <cpunum>
f0104bc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc3:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bc9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104bcc:	89 78 6c             	mov    %edi,0x6c(%eax)
        curenv->env_ipc_from = 0;
f0104bcf:	e8 27 12 00 00       	call   f0105dfb <cpunum>
f0104bd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd7:	8b 80 48 b0 20 f0    	mov    -0xfdf4fb8(%eax),%eax
f0104bdd:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104be4:	e8 85 f9 ff ff       	call   f010456e <sched_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104be9:	83 ec 04             	sub    $0x4,%esp
f0104bec:	6a 01                	push   $0x1
f0104bee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bf1:	50                   	push   %eax
f0104bf2:	ff 75 0c             	pushl  0xc(%ebp)
f0104bf5:	e8 08 e3 ff ff       	call   f0102f02 <envid2env>
f0104bfa:	83 c4 10             	add    $0x10,%esp
                return ret;
f0104bfd:	89 c3                	mov    %eax,%ebx
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
        struct Env *newenv;
        int ret;
        if((ret = envid2env(envid, &newenv, 1)) < 0)  
f0104bff:	85 c0                	test   %eax,%eax
f0104c01:	78 42                	js     f0104c45 <syscall+0x5fd>
                return ret;
        user_mem_assert(newenv, tf, sizeof(struct Trapframe), PTE_U);
f0104c03:	6a 04                	push   $0x4
f0104c05:	6a 44                	push   $0x44
f0104c07:	ff 75 10             	pushl  0x10(%ebp)
f0104c0a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c0d:	e8 29 e2 ff ff       	call   f0102e3b <user_mem_assert>
        newenv->env_tf = *tf;
f0104c12:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c1a:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_eflags |= FL_IF;
f0104c1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c22:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
        newenv->env_tf.tf_cs = GD_UT | 3;	
f0104c29:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
f0104c2f:	83 c4 10             	add    $0x10,%esp
        return 0;
f0104c32:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c37:	eb 0c                	jmp    f0104c45 <syscall+0x5fd>
                break;
        case SYS_env_set_trapframe:
                rslt = sys_env_set_trapframe(a1, (void *)a2);
                break;
	default:
		return -E_INVAL;
f0104c39:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c3e:	eb 05                	jmp    f0104c45 <syscall+0x5fd>
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
        case SYS_ipc_recv:
                rslt = sys_ipc_recv((void *)a1);
f0104c40:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
                break;
	default:
		return -E_INVAL;
	}
        return rslt;
}
f0104c45:	89 d8                	mov    %ebx,%eax
f0104c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c4a:	5b                   	pop    %ebx
f0104c4b:	5e                   	pop    %esi
f0104c4c:	5f                   	pop    %edi
f0104c4d:	5d                   	pop    %ebp
f0104c4e:	c3                   	ret    

f0104c4f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c4f:	55                   	push   %ebp
f0104c50:	89 e5                	mov    %esp,%ebp
f0104c52:	57                   	push   %edi
f0104c53:	56                   	push   %esi
f0104c54:	53                   	push   %ebx
f0104c55:	83 ec 14             	sub    $0x14,%esp
f0104c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c5e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c61:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c64:	8b 1a                	mov    (%edx),%ebx
f0104c66:	8b 01                	mov    (%ecx),%eax
f0104c68:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c6b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c72:	e9 88 00 00 00       	jmp    f0104cff <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c7a:	01 d8                	add    %ebx,%eax
f0104c7c:	89 c6                	mov    %eax,%esi
f0104c7e:	c1 ee 1f             	shr    $0x1f,%esi
f0104c81:	01 c6                	add    %eax,%esi
f0104c83:	d1 fe                	sar    %esi
f0104c85:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c88:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c8b:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c8e:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c90:	eb 03                	jmp    f0104c95 <stab_binsearch+0x46>
			m--;
f0104c92:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c95:	39 c3                	cmp    %eax,%ebx
f0104c97:	7f 1f                	jg     f0104cb8 <stab_binsearch+0x69>
f0104c99:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c9d:	83 ea 0c             	sub    $0xc,%edx
f0104ca0:	39 f9                	cmp    %edi,%ecx
f0104ca2:	75 ee                	jne    f0104c92 <stab_binsearch+0x43>
f0104ca4:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ca7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104caa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cad:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cb1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cb4:	76 18                	jbe    f0104cce <stab_binsearch+0x7f>
f0104cb6:	eb 05                	jmp    f0104cbd <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cb8:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104cbb:	eb 42                	jmp    f0104cff <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104cbd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cc0:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cc2:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cc5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ccc:	eb 31                	jmp    f0104cff <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104cce:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cd1:	73 17                	jae    f0104cea <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104cd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104cd6:	83 e8 01             	sub    $0x1,%eax
f0104cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cdc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cdf:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ce1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ce8:	eb 15                	jmp    f0104cff <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ced:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104cf0:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0104cf2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cf6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cf8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104cff:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d02:	0f 8e 6f ff ff ff    	jle    f0104c77 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d08:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d0c:	75 0f                	jne    f0104d1d <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d11:	8b 00                	mov    (%eax),%eax
f0104d13:	83 e8 01             	sub    $0x1,%eax
f0104d16:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d19:	89 06                	mov    %eax,(%esi)
f0104d1b:	eb 2c                	jmp    f0104d49 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d20:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d22:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d25:	8b 0e                	mov    (%esi),%ecx
f0104d27:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d2a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d2d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d30:	eb 03                	jmp    f0104d35 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d32:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d35:	39 c8                	cmp    %ecx,%eax
f0104d37:	7e 0b                	jle    f0104d44 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104d39:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d3d:	83 ea 0c             	sub    $0xc,%edx
f0104d40:	39 fb                	cmp    %edi,%ebx
f0104d42:	75 ee                	jne    f0104d32 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d44:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d47:	89 06                	mov    %eax,(%esi)
	}
}
f0104d49:	83 c4 14             	add    $0x14,%esp
f0104d4c:	5b                   	pop    %ebx
f0104d4d:	5e                   	pop    %esi
f0104d4e:	5f                   	pop    %edi
f0104d4f:	5d                   	pop    %ebp
f0104d50:	c3                   	ret    

f0104d51 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d51:	55                   	push   %ebp
f0104d52:	89 e5                	mov    %esp,%ebp
f0104d54:	57                   	push   %edi
f0104d55:	56                   	push   %esi
f0104d56:	53                   	push   %ebx
f0104d57:	83 ec 3c             	sub    $0x3c,%esp
f0104d5a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d60:	c7 03 04 7c 10 f0    	movl   $0xf0107c04,(%ebx)
	info->eip_line = 0;
f0104d66:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d6d:	c7 43 08 04 7c 10 f0 	movl   $0xf0107c04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d74:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d7b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d7e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d85:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d8b:	0f 87 96 00 00 00    	ja     f0104e27 <debuginfo_eip+0xd6>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104d91:	e8 65 10 00 00       	call   f0105dfb <cpunum>
f0104d96:	6a 04                	push   $0x4
f0104d98:	6a 10                	push   $0x10
f0104d9a:	68 00 00 20 00       	push   $0x200000
f0104d9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da2:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104da8:	e8 16 e0 ff ff       	call   f0102dc3 <user_mem_check>
f0104dad:	83 c4 10             	add    $0x10,%esp
f0104db0:	85 c0                	test   %eax,%eax
f0104db2:	0f 85 15 02 00 00    	jne    f0104fcd <debuginfo_eip+0x27c>
			return -1;
		stabs = usd->stabs;
f0104db8:	a1 00 00 20 00       	mov    0x200000,%eax
f0104dbd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104dc0:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104dc6:	a1 08 00 20 00       	mov    0x200008,%eax
f0104dcb:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104dce:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104dd4:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104dd7:	e8 1f 10 00 00       	call   f0105dfb <cpunum>
f0104ddc:	6a 04                	push   $0x4
f0104dde:	6a 0c                	push   $0xc
f0104de0:	ff 75 c4             	pushl  -0x3c(%ebp)
f0104de3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de6:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104dec:	e8 d2 df ff ff       	call   f0102dc3 <user_mem_check>
f0104df1:	83 c4 10             	add    $0x10,%esp
f0104df4:	85 c0                	test   %eax,%eax
f0104df6:	0f 85 d8 01 00 00    	jne    f0104fd4 <debuginfo_eip+0x283>
                        return -1;
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104dfc:	e8 fa 0f 00 00       	call   f0105dfb <cpunum>
f0104e01:	6a 04                	push   $0x4
f0104e03:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e06:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e09:	29 ca                	sub    %ecx,%edx
f0104e0b:	52                   	push   %edx
f0104e0c:	51                   	push   %ecx
f0104e0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e10:	ff b0 48 b0 20 f0    	pushl  -0xfdf4fb8(%eax)
f0104e16:	e8 a8 df ff ff       	call   f0102dc3 <user_mem_check>
f0104e1b:	83 c4 10             	add    $0x10,%esp
f0104e1e:	85 c0                	test   %eax,%eax
f0104e20:	74 1f                	je     f0104e41 <debuginfo_eip+0xf0>
f0104e22:	e9 b4 01 00 00       	jmp    f0104fdb <debuginfo_eip+0x28a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104e27:	c7 45 bc d6 60 11 f0 	movl   $0xf01160d6,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104e2e:	c7 45 c0 d5 29 11 f0 	movl   $0xf01129d5,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104e35:	bf d4 29 11 f0       	mov    $0xf01129d4,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104e3a:	c7 45 c4 b0 81 10 f0 	movl   $0xf01081b0,-0x3c(%ebp)
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e41:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104e44:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0104e47:	0f 83 95 01 00 00    	jae    f0104fe2 <debuginfo_eip+0x291>
f0104e4d:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104e51:	0f 85 92 01 00 00    	jne    f0104fe9 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e5e:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104e61:	c1 ff 02             	sar    $0x2,%edi
f0104e64:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104e6a:	83 e8 01             	sub    $0x1,%eax
f0104e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e70:	83 ec 08             	sub    $0x8,%esp
f0104e73:	56                   	push   %esi
f0104e74:	6a 64                	push   $0x64
f0104e76:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104e79:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e7c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104e7f:	89 f8                	mov    %edi,%eax
f0104e81:	e8 c9 fd ff ff       	call   f0104c4f <stab_binsearch>
	if (lfile == 0)
f0104e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e89:	83 c4 10             	add    $0x10,%esp
f0104e8c:	85 c0                	test   %eax,%eax
f0104e8e:	0f 84 5c 01 00 00    	je     f0104ff0 <debuginfo_eip+0x29f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e94:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e9d:	83 ec 08             	sub    $0x8,%esp
f0104ea0:	56                   	push   %esi
f0104ea1:	6a 24                	push   $0x24
f0104ea3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104ea6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ea9:	89 f8                	mov    %edi,%eax
f0104eab:	e8 9f fd ff ff       	call   f0104c4f <stab_binsearch>

	if (lfun <= rfun) {
f0104eb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104eb3:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104eb6:	83 c4 10             	add    $0x10,%esp
f0104eb9:	39 f8                	cmp    %edi,%eax
f0104ebb:	7f 32                	jg     f0104eef <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ebd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ec0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104ec3:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0104ec6:	8b 11                	mov    (%ecx),%edx
f0104ec8:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104ecb:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104ece:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104ed1:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0104ed4:	73 09                	jae    f0104edf <debuginfo_eip+0x18e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ed6:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104ed9:	03 55 c0             	add    -0x40(%ebp),%edx
f0104edc:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104edf:	8b 51 08             	mov    0x8(%ecx),%edx
f0104ee2:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ee5:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ee7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104eea:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0104eed:	eb 0f                	jmp    f0104efe <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104eef:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104ef2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ef5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104efb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104efe:	83 ec 08             	sub    $0x8,%esp
f0104f01:	6a 3a                	push   $0x3a
f0104f03:	ff 73 08             	pushl  0x8(%ebx)
f0104f06:	e8 b1 08 00 00       	call   f01057bc <strfind>
f0104f0b:	2b 43 08             	sub    0x8(%ebx),%eax
f0104f0e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104f11:	83 c4 08             	add    $0x8,%esp
f0104f14:	56                   	push   %esi
f0104f15:	6a 44                	push   $0x44
f0104f17:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104f1a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104f1d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104f20:	89 f0                	mov    %esi,%eax
f0104f22:	e8 28 fd ff ff       	call   f0104c4f <stab_binsearch>
        if(lline <= rline)
f0104f27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f2a:	83 c4 10             	add    $0x10,%esp
f0104f2d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104f30:	0f 8f c1 00 00 00    	jg     f0104ff7 <debuginfo_eip+0x2a6>
              info->eip_line = stabs[lline].n_desc;
f0104f36:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f39:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104f3e:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f47:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f4a:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104f4d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f50:	eb 06                	jmp    f0104f58 <debuginfo_eip+0x207>
f0104f52:	83 e8 01             	sub    $0x1,%eax
f0104f55:	83 ea 0c             	sub    $0xc,%edx
f0104f58:	39 c7                	cmp    %eax,%edi
f0104f5a:	7f 2a                	jg     f0104f86 <debuginfo_eip+0x235>
	       && stabs[lline].n_type != N_SOL
f0104f5c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f60:	80 f9 84             	cmp    $0x84,%cl
f0104f63:	0f 84 9c 00 00 00    	je     f0105005 <debuginfo_eip+0x2b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f69:	80 f9 64             	cmp    $0x64,%cl
f0104f6c:	75 e4                	jne    f0104f52 <debuginfo_eip+0x201>
f0104f6e:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f72:	74 de                	je     f0104f52 <debuginfo_eip+0x201>
f0104f74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f7a:	e9 8c 00 00 00       	jmp    f010500b <debuginfo_eip+0x2ba>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f7f:	03 55 c0             	add    -0x40(%ebp),%edx
f0104f82:	89 13                	mov    %edx,(%ebx)
f0104f84:	eb 03                	jmp    f0104f89 <debuginfo_eip+0x238>
f0104f86:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f89:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f8c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f8f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f94:	39 f2                	cmp    %esi,%edx
f0104f96:	0f 8d 8b 00 00 00    	jge    f0105027 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
f0104f9c:	83 c2 01             	add    $0x1,%edx
f0104f9f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104fa2:	89 d0                	mov    %edx,%eax
f0104fa4:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104fa7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104faa:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104fad:	eb 04                	jmp    f0104fb3 <debuginfo_eip+0x262>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104faf:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104fb3:	39 c6                	cmp    %eax,%esi
f0104fb5:	7e 47                	jle    f0104ffe <debuginfo_eip+0x2ad>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104fb7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104fbb:	83 c0 01             	add    $0x1,%eax
f0104fbe:	83 c2 0c             	add    $0xc,%edx
f0104fc1:	80 f9 a0             	cmp    $0xa0,%cl
f0104fc4:	74 e9                	je     f0104faf <debuginfo_eip+0x25e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fcb:	eb 5a                	jmp    f0105027 <debuginfo_eip+0x2d6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fd2:	eb 53                	jmp    f0105027 <debuginfo_eip+0x2d6>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
                        return -1;
f0104fd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fd9:	eb 4c                	jmp    f0105027 <debuginfo_eip+0x2d6>
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
f0104fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fe0:	eb 45                	jmp    f0105027 <debuginfo_eip+0x2d6>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fe7:	eb 3e                	jmp    f0105027 <debuginfo_eip+0x2d6>
f0104fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fee:	eb 37                	jmp    f0105027 <debuginfo_eip+0x2d6>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ff5:	eb 30                	jmp    f0105027 <debuginfo_eip+0x2d6>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0104ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ffc:	eb 29                	jmp    f0105027 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ffe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105003:	eb 22                	jmp    f0105027 <debuginfo_eip+0x2d6>
f0105005:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105008:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010500b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010500e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105011:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105014:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105017:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010501a:	39 c2                	cmp    %eax,%edx
f010501c:	0f 82 5d ff ff ff    	jb     f0104f7f <debuginfo_eip+0x22e>
f0105022:	e9 62 ff ff ff       	jmp    f0104f89 <debuginfo_eip+0x238>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0105027:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010502a:	5b                   	pop    %ebx
f010502b:	5e                   	pop    %esi
f010502c:	5f                   	pop    %edi
f010502d:	5d                   	pop    %ebp
f010502e:	c3                   	ret    

f010502f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010502f:	55                   	push   %ebp
f0105030:	89 e5                	mov    %esp,%ebp
f0105032:	57                   	push   %edi
f0105033:	56                   	push   %esi
f0105034:	53                   	push   %ebx
f0105035:	83 ec 1c             	sub    $0x1c,%esp
f0105038:	89 c7                	mov    %eax,%edi
f010503a:	89 d6                	mov    %edx,%esi
f010503c:	8b 45 08             	mov    0x8(%ebp),%eax
f010503f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105042:	89 d1                	mov    %edx,%ecx
f0105044:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105047:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010504a:	8b 45 10             	mov    0x10(%ebp),%eax
f010504d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105050:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105053:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010505a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f010505d:	72 05                	jb     f0105064 <printnum+0x35>
f010505f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105062:	77 3e                	ja     f01050a2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105064:	83 ec 0c             	sub    $0xc,%esp
f0105067:	ff 75 18             	pushl  0x18(%ebp)
f010506a:	83 eb 01             	sub    $0x1,%ebx
f010506d:	53                   	push   %ebx
f010506e:	50                   	push   %eax
f010506f:	83 ec 08             	sub    $0x8,%esp
f0105072:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105075:	ff 75 e0             	pushl  -0x20(%ebp)
f0105078:	ff 75 dc             	pushl  -0x24(%ebp)
f010507b:	ff 75 d8             	pushl  -0x28(%ebp)
f010507e:	e8 6d 11 00 00       	call   f01061f0 <__udivdi3>
f0105083:	83 c4 18             	add    $0x18,%esp
f0105086:	52                   	push   %edx
f0105087:	50                   	push   %eax
f0105088:	89 f2                	mov    %esi,%edx
f010508a:	89 f8                	mov    %edi,%eax
f010508c:	e8 9e ff ff ff       	call   f010502f <printnum>
f0105091:	83 c4 20             	add    $0x20,%esp
f0105094:	eb 13                	jmp    f01050a9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105096:	83 ec 08             	sub    $0x8,%esp
f0105099:	56                   	push   %esi
f010509a:	ff 75 18             	pushl  0x18(%ebp)
f010509d:	ff d7                	call   *%edi
f010509f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01050a2:	83 eb 01             	sub    $0x1,%ebx
f01050a5:	85 db                	test   %ebx,%ebx
f01050a7:	7f ed                	jg     f0105096 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050a9:	83 ec 08             	sub    $0x8,%esp
f01050ac:	56                   	push   %esi
f01050ad:	83 ec 04             	sub    $0x4,%esp
f01050b0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050b3:	ff 75 e0             	pushl  -0x20(%ebp)
f01050b6:	ff 75 dc             	pushl  -0x24(%ebp)
f01050b9:	ff 75 d8             	pushl  -0x28(%ebp)
f01050bc:	e8 5f 12 00 00       	call   f0106320 <__umoddi3>
f01050c1:	83 c4 14             	add    $0x14,%esp
f01050c4:	0f be 80 0e 7c 10 f0 	movsbl -0xfef83f2(%eax),%eax
f01050cb:	50                   	push   %eax
f01050cc:	ff d7                	call   *%edi
f01050ce:	83 c4 10             	add    $0x10,%esp
}
f01050d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5f                   	pop    %edi
f01050d7:	5d                   	pop    %ebp
f01050d8:	c3                   	ret    

f01050d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01050d9:	55                   	push   %ebp
f01050da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01050dc:	83 fa 01             	cmp    $0x1,%edx
f01050df:	7e 0e                	jle    f01050ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01050e1:	8b 10                	mov    (%eax),%edx
f01050e3:	8d 4a 08             	lea    0x8(%edx),%ecx
f01050e6:	89 08                	mov    %ecx,(%eax)
f01050e8:	8b 02                	mov    (%edx),%eax
f01050ea:	8b 52 04             	mov    0x4(%edx),%edx
f01050ed:	eb 22                	jmp    f0105111 <getuint+0x38>
	else if (lflag)
f01050ef:	85 d2                	test   %edx,%edx
f01050f1:	74 10                	je     f0105103 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01050f3:	8b 10                	mov    (%eax),%edx
f01050f5:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050f8:	89 08                	mov    %ecx,(%eax)
f01050fa:	8b 02                	mov    (%edx),%eax
f01050fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105101:	eb 0e                	jmp    f0105111 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105103:	8b 10                	mov    (%eax),%edx
f0105105:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105108:	89 08                	mov    %ecx,(%eax)
f010510a:	8b 02                	mov    (%edx),%eax
f010510c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105111:	5d                   	pop    %ebp
f0105112:	c3                   	ret    

f0105113 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105113:	55                   	push   %ebp
f0105114:	89 e5                	mov    %esp,%ebp
f0105116:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105119:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010511d:	8b 10                	mov    (%eax),%edx
f010511f:	3b 50 04             	cmp    0x4(%eax),%edx
f0105122:	73 0a                	jae    f010512e <sprintputch+0x1b>
		*b->buf++ = ch;
f0105124:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105127:	89 08                	mov    %ecx,(%eax)
f0105129:	8b 45 08             	mov    0x8(%ebp),%eax
f010512c:	88 02                	mov    %al,(%edx)
}
f010512e:	5d                   	pop    %ebp
f010512f:	c3                   	ret    

f0105130 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105130:	55                   	push   %ebp
f0105131:	89 e5                	mov    %esp,%ebp
f0105133:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105136:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105139:	50                   	push   %eax
f010513a:	ff 75 10             	pushl  0x10(%ebp)
f010513d:	ff 75 0c             	pushl  0xc(%ebp)
f0105140:	ff 75 08             	pushl  0x8(%ebp)
f0105143:	e8 05 00 00 00       	call   f010514d <vprintfmt>
	va_end(ap);
f0105148:	83 c4 10             	add    $0x10,%esp
}
f010514b:	c9                   	leave  
f010514c:	c3                   	ret    

f010514d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010514d:	55                   	push   %ebp
f010514e:	89 e5                	mov    %esp,%ebp
f0105150:	57                   	push   %edi
f0105151:	56                   	push   %esi
f0105152:	53                   	push   %ebx
f0105153:	83 ec 2c             	sub    $0x2c,%esp
f0105156:	8b 75 08             	mov    0x8(%ebp),%esi
f0105159:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010515c:	8b 7d 10             	mov    0x10(%ebp),%edi
f010515f:	eb 12                	jmp    f0105173 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105161:	85 c0                	test   %eax,%eax
f0105163:	0f 84 90 03 00 00    	je     f01054f9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0105169:	83 ec 08             	sub    $0x8,%esp
f010516c:	53                   	push   %ebx
f010516d:	50                   	push   %eax
f010516e:	ff d6                	call   *%esi
f0105170:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105173:	83 c7 01             	add    $0x1,%edi
f0105176:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010517a:	83 f8 25             	cmp    $0x25,%eax
f010517d:	75 e2                	jne    f0105161 <vprintfmt+0x14>
f010517f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105183:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010518a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105191:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105198:	ba 00 00 00 00       	mov    $0x0,%edx
f010519d:	eb 07                	jmp    f01051a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01051a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051a6:	8d 47 01             	lea    0x1(%edi),%eax
f01051a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051ac:	0f b6 07             	movzbl (%edi),%eax
f01051af:	0f b6 c8             	movzbl %al,%ecx
f01051b2:	83 e8 23             	sub    $0x23,%eax
f01051b5:	3c 55                	cmp    $0x55,%al
f01051b7:	0f 87 21 03 00 00    	ja     f01054de <vprintfmt+0x391>
f01051bd:	0f b6 c0             	movzbl %al,%eax
f01051c0:	ff 24 85 40 7d 10 f0 	jmp    *-0xfef82c0(,%eax,4)
f01051c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01051ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01051ce:	eb d6                	jmp    f01051a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01051d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01051db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01051de:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01051e2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01051e5:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01051e8:	83 fa 09             	cmp    $0x9,%edx
f01051eb:	77 39                	ja     f0105226 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01051ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01051f0:	eb e9                	jmp    f01051db <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01051f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f5:	8d 48 04             	lea    0x4(%eax),%ecx
f01051f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01051fb:	8b 00                	mov    (%eax),%eax
f01051fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105200:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105203:	eb 27                	jmp    f010522c <vprintfmt+0xdf>
f0105205:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105208:	85 c0                	test   %eax,%eax
f010520a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010520f:	0f 49 c8             	cmovns %eax,%ecx
f0105212:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105215:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105218:	eb 8c                	jmp    f01051a6 <vprintfmt+0x59>
f010521a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010521d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105224:	eb 80                	jmp    f01051a6 <vprintfmt+0x59>
f0105226:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105229:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010522c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105230:	0f 89 70 ff ff ff    	jns    f01051a6 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105236:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105239:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010523c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105243:	e9 5e ff ff ff       	jmp    f01051a6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105248:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010524b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010524e:	e9 53 ff ff ff       	jmp    f01051a6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105253:	8b 45 14             	mov    0x14(%ebp),%eax
f0105256:	8d 50 04             	lea    0x4(%eax),%edx
f0105259:	89 55 14             	mov    %edx,0x14(%ebp)
f010525c:	83 ec 08             	sub    $0x8,%esp
f010525f:	53                   	push   %ebx
f0105260:	ff 30                	pushl  (%eax)
f0105262:	ff d6                	call   *%esi
			break;
f0105264:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105267:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010526a:	e9 04 ff ff ff       	jmp    f0105173 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010526f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105272:	8d 50 04             	lea    0x4(%eax),%edx
f0105275:	89 55 14             	mov    %edx,0x14(%ebp)
f0105278:	8b 00                	mov    (%eax),%eax
f010527a:	99                   	cltd   
f010527b:	31 d0                	xor    %edx,%eax
f010527d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010527f:	83 f8 0f             	cmp    $0xf,%eax
f0105282:	7f 0b                	jg     f010528f <vprintfmt+0x142>
f0105284:	8b 14 85 c0 7e 10 f0 	mov    -0xfef8140(,%eax,4),%edx
f010528b:	85 d2                	test   %edx,%edx
f010528d:	75 18                	jne    f01052a7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010528f:	50                   	push   %eax
f0105290:	68 26 7c 10 f0       	push   $0xf0107c26
f0105295:	53                   	push   %ebx
f0105296:	56                   	push   %esi
f0105297:	e8 94 fe ff ff       	call   f0105130 <printfmt>
f010529c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010529f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01052a2:	e9 cc fe ff ff       	jmp    f0105173 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01052a7:	52                   	push   %edx
f01052a8:	68 d6 6a 10 f0       	push   $0xf0106ad6
f01052ad:	53                   	push   %ebx
f01052ae:	56                   	push   %esi
f01052af:	e8 7c fe ff ff       	call   f0105130 <printfmt>
f01052b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052ba:	e9 b4 fe ff ff       	jmp    f0105173 <vprintfmt+0x26>
f01052bf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01052c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052cb:	8d 50 04             	lea    0x4(%eax),%edx
f01052ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01052d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01052d3:	85 ff                	test   %edi,%edi
f01052d5:	ba 1f 7c 10 f0       	mov    $0xf0107c1f,%edx
f01052da:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f01052dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01052e1:	0f 84 92 00 00 00    	je     f0105379 <vprintfmt+0x22c>
f01052e7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01052eb:	0f 8e 96 00 00 00    	jle    f0105387 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052f1:	83 ec 08             	sub    $0x8,%esp
f01052f4:	51                   	push   %ecx
f01052f5:	57                   	push   %edi
f01052f6:	e8 77 03 00 00       	call   f0105672 <strnlen>
f01052fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01052fe:	29 c1                	sub    %eax,%ecx
f0105300:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105303:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105306:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010530a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010530d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105310:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105312:	eb 0f                	jmp    f0105323 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105314:	83 ec 08             	sub    $0x8,%esp
f0105317:	53                   	push   %ebx
f0105318:	ff 75 e0             	pushl  -0x20(%ebp)
f010531b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010531d:	83 ef 01             	sub    $0x1,%edi
f0105320:	83 c4 10             	add    $0x10,%esp
f0105323:	85 ff                	test   %edi,%edi
f0105325:	7f ed                	jg     f0105314 <vprintfmt+0x1c7>
f0105327:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010532a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010532d:	85 c9                	test   %ecx,%ecx
f010532f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105334:	0f 49 c1             	cmovns %ecx,%eax
f0105337:	29 c1                	sub    %eax,%ecx
f0105339:	89 75 08             	mov    %esi,0x8(%ebp)
f010533c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010533f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105342:	89 cb                	mov    %ecx,%ebx
f0105344:	eb 4d                	jmp    f0105393 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105346:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010534a:	74 1b                	je     f0105367 <vprintfmt+0x21a>
f010534c:	0f be c0             	movsbl %al,%eax
f010534f:	83 e8 20             	sub    $0x20,%eax
f0105352:	83 f8 5e             	cmp    $0x5e,%eax
f0105355:	76 10                	jbe    f0105367 <vprintfmt+0x21a>
					putch('?', putdat);
f0105357:	83 ec 08             	sub    $0x8,%esp
f010535a:	ff 75 0c             	pushl  0xc(%ebp)
f010535d:	6a 3f                	push   $0x3f
f010535f:	ff 55 08             	call   *0x8(%ebp)
f0105362:	83 c4 10             	add    $0x10,%esp
f0105365:	eb 0d                	jmp    f0105374 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0105367:	83 ec 08             	sub    $0x8,%esp
f010536a:	ff 75 0c             	pushl  0xc(%ebp)
f010536d:	52                   	push   %edx
f010536e:	ff 55 08             	call   *0x8(%ebp)
f0105371:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105374:	83 eb 01             	sub    $0x1,%ebx
f0105377:	eb 1a                	jmp    f0105393 <vprintfmt+0x246>
f0105379:	89 75 08             	mov    %esi,0x8(%ebp)
f010537c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010537f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105382:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105385:	eb 0c                	jmp    f0105393 <vprintfmt+0x246>
f0105387:	89 75 08             	mov    %esi,0x8(%ebp)
f010538a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010538d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105390:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105393:	83 c7 01             	add    $0x1,%edi
f0105396:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010539a:	0f be d0             	movsbl %al,%edx
f010539d:	85 d2                	test   %edx,%edx
f010539f:	74 23                	je     f01053c4 <vprintfmt+0x277>
f01053a1:	85 f6                	test   %esi,%esi
f01053a3:	78 a1                	js     f0105346 <vprintfmt+0x1f9>
f01053a5:	83 ee 01             	sub    $0x1,%esi
f01053a8:	79 9c                	jns    f0105346 <vprintfmt+0x1f9>
f01053aa:	89 df                	mov    %ebx,%edi
f01053ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01053af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053b2:	eb 18                	jmp    f01053cc <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01053b4:	83 ec 08             	sub    $0x8,%esp
f01053b7:	53                   	push   %ebx
f01053b8:	6a 20                	push   $0x20
f01053ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01053bc:	83 ef 01             	sub    $0x1,%edi
f01053bf:	83 c4 10             	add    $0x10,%esp
f01053c2:	eb 08                	jmp    f01053cc <vprintfmt+0x27f>
f01053c4:	89 df                	mov    %ebx,%edi
f01053c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01053c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053cc:	85 ff                	test   %edi,%edi
f01053ce:	7f e4                	jg     f01053b4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053d3:	e9 9b fd ff ff       	jmp    f0105173 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053d8:	83 fa 01             	cmp    $0x1,%edx
f01053db:	7e 16                	jle    f01053f3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f01053dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e0:	8d 50 08             	lea    0x8(%eax),%edx
f01053e3:	89 55 14             	mov    %edx,0x14(%ebp)
f01053e6:	8b 50 04             	mov    0x4(%eax),%edx
f01053e9:	8b 00                	mov    (%eax),%eax
f01053eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053f1:	eb 32                	jmp    f0105425 <vprintfmt+0x2d8>
	else if (lflag)
f01053f3:	85 d2                	test   %edx,%edx
f01053f5:	74 18                	je     f010540f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f01053f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01053fa:	8d 50 04             	lea    0x4(%eax),%edx
f01053fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105400:	8b 00                	mov    (%eax),%eax
f0105402:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105405:	89 c1                	mov    %eax,%ecx
f0105407:	c1 f9 1f             	sar    $0x1f,%ecx
f010540a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010540d:	eb 16                	jmp    f0105425 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f010540f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105412:	8d 50 04             	lea    0x4(%eax),%edx
f0105415:	89 55 14             	mov    %edx,0x14(%ebp)
f0105418:	8b 00                	mov    (%eax),%eax
f010541a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010541d:	89 c1                	mov    %eax,%ecx
f010541f:	c1 f9 1f             	sar    $0x1f,%ecx
f0105422:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105425:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105428:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010542b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105430:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105434:	79 74                	jns    f01054aa <vprintfmt+0x35d>
				putch('-', putdat);
f0105436:	83 ec 08             	sub    $0x8,%esp
f0105439:	53                   	push   %ebx
f010543a:	6a 2d                	push   $0x2d
f010543c:	ff d6                	call   *%esi
				num = -(long long) num;
f010543e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105441:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105444:	f7 d8                	neg    %eax
f0105446:	83 d2 00             	adc    $0x0,%edx
f0105449:	f7 da                	neg    %edx
f010544b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010544e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105453:	eb 55                	jmp    f01054aa <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105455:	8d 45 14             	lea    0x14(%ebp),%eax
f0105458:	e8 7c fc ff ff       	call   f01050d9 <getuint>
			base = 10;
f010545d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105462:	eb 46                	jmp    f01054aa <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105464:	8d 45 14             	lea    0x14(%ebp),%eax
f0105467:	e8 6d fc ff ff       	call   f01050d9 <getuint>
                        base = 8;
f010546c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0105471:	eb 37                	jmp    f01054aa <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f0105473:	83 ec 08             	sub    $0x8,%esp
f0105476:	53                   	push   %ebx
f0105477:	6a 30                	push   $0x30
f0105479:	ff d6                	call   *%esi
			putch('x', putdat);
f010547b:	83 c4 08             	add    $0x8,%esp
f010547e:	53                   	push   %ebx
f010547f:	6a 78                	push   $0x78
f0105481:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105483:	8b 45 14             	mov    0x14(%ebp),%eax
f0105486:	8d 50 04             	lea    0x4(%eax),%edx
f0105489:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010548c:	8b 00                	mov    (%eax),%eax
f010548e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105493:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105496:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010549b:	eb 0d                	jmp    f01054aa <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010549d:	8d 45 14             	lea    0x14(%ebp),%eax
f01054a0:	e8 34 fc ff ff       	call   f01050d9 <getuint>
			base = 16;
f01054a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01054aa:	83 ec 0c             	sub    $0xc,%esp
f01054ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01054b1:	57                   	push   %edi
f01054b2:	ff 75 e0             	pushl  -0x20(%ebp)
f01054b5:	51                   	push   %ecx
f01054b6:	52                   	push   %edx
f01054b7:	50                   	push   %eax
f01054b8:	89 da                	mov    %ebx,%edx
f01054ba:	89 f0                	mov    %esi,%eax
f01054bc:	e8 6e fb ff ff       	call   f010502f <printnum>
			break;
f01054c1:	83 c4 20             	add    $0x20,%esp
f01054c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054c7:	e9 a7 fc ff ff       	jmp    f0105173 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01054cc:	83 ec 08             	sub    $0x8,%esp
f01054cf:	53                   	push   %ebx
f01054d0:	51                   	push   %ecx
f01054d1:	ff d6                	call   *%esi
			break;
f01054d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01054d9:	e9 95 fc ff ff       	jmp    f0105173 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01054de:	83 ec 08             	sub    $0x8,%esp
f01054e1:	53                   	push   %ebx
f01054e2:	6a 25                	push   $0x25
f01054e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054e6:	83 c4 10             	add    $0x10,%esp
f01054e9:	eb 03                	jmp    f01054ee <vprintfmt+0x3a1>
f01054eb:	83 ef 01             	sub    $0x1,%edi
f01054ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01054f2:	75 f7                	jne    f01054eb <vprintfmt+0x39e>
f01054f4:	e9 7a fc ff ff       	jmp    f0105173 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01054f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054fc:	5b                   	pop    %ebx
f01054fd:	5e                   	pop    %esi
f01054fe:	5f                   	pop    %edi
f01054ff:	5d                   	pop    %ebp
f0105500:	c3                   	ret    

f0105501 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105501:	55                   	push   %ebp
f0105502:	89 e5                	mov    %esp,%ebp
f0105504:	83 ec 18             	sub    $0x18,%esp
f0105507:	8b 45 08             	mov    0x8(%ebp),%eax
f010550a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010550d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105510:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105514:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010551e:	85 c0                	test   %eax,%eax
f0105520:	74 26                	je     f0105548 <vsnprintf+0x47>
f0105522:	85 d2                	test   %edx,%edx
f0105524:	7e 22                	jle    f0105548 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105526:	ff 75 14             	pushl  0x14(%ebp)
f0105529:	ff 75 10             	pushl  0x10(%ebp)
f010552c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010552f:	50                   	push   %eax
f0105530:	68 13 51 10 f0       	push   $0xf0105113
f0105535:	e8 13 fc ff ff       	call   f010514d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010553a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010553d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105540:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105543:	83 c4 10             	add    $0x10,%esp
f0105546:	eb 05                	jmp    f010554d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105548:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010554d:	c9                   	leave  
f010554e:	c3                   	ret    

f010554f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010554f:	55                   	push   %ebp
f0105550:	89 e5                	mov    %esp,%ebp
f0105552:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105555:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105558:	50                   	push   %eax
f0105559:	ff 75 10             	pushl  0x10(%ebp)
f010555c:	ff 75 0c             	pushl  0xc(%ebp)
f010555f:	ff 75 08             	pushl  0x8(%ebp)
f0105562:	e8 9a ff ff ff       	call   f0105501 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105567:	c9                   	leave  
f0105568:	c3                   	ret    

f0105569 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105569:	55                   	push   %ebp
f010556a:	89 e5                	mov    %esp,%ebp
f010556c:	57                   	push   %edi
f010556d:	56                   	push   %esi
f010556e:	53                   	push   %ebx
f010556f:	83 ec 0c             	sub    $0xc,%esp
f0105572:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105575:	85 c0                	test   %eax,%eax
f0105577:	74 11                	je     f010558a <readline+0x21>
		cprintf("%s", prompt);
f0105579:	83 ec 08             	sub    $0x8,%esp
f010557c:	50                   	push   %eax
f010557d:	68 d6 6a 10 f0       	push   $0xf0106ad6
f0105582:	e8 8a e1 ff ff       	call   f0103711 <cprintf>
f0105587:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010558a:	83 ec 0c             	sub    $0xc,%esp
f010558d:	6a 00                	push   $0x0
f010558f:	e8 07 b2 ff ff       	call   f010079b <iscons>
f0105594:	89 c7                	mov    %eax,%edi
f0105596:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105599:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010559e:	e8 e7 b1 ff ff       	call   f010078a <getchar>
f01055a3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055a5:	85 c0                	test   %eax,%eax
f01055a7:	79 29                	jns    f01055d2 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055a9:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01055ae:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01055b1:	0f 84 9b 00 00 00    	je     f0105652 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01055b7:	83 ec 08             	sub    $0x8,%esp
f01055ba:	53                   	push   %ebx
f01055bb:	68 1f 7f 10 f0       	push   $0xf0107f1f
f01055c0:	e8 4c e1 ff ff       	call   f0103711 <cprintf>
f01055c5:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01055cd:	e9 80 00 00 00       	jmp    f0105652 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055d2:	83 f8 7f             	cmp    $0x7f,%eax
f01055d5:	0f 94 c2             	sete   %dl
f01055d8:	83 f8 08             	cmp    $0x8,%eax
f01055db:	0f 94 c0             	sete   %al
f01055de:	08 c2                	or     %al,%dl
f01055e0:	74 1a                	je     f01055fc <readline+0x93>
f01055e2:	85 f6                	test   %esi,%esi
f01055e4:	7e 16                	jle    f01055fc <readline+0x93>
			if (echoing)
f01055e6:	85 ff                	test   %edi,%edi
f01055e8:	74 0d                	je     f01055f7 <readline+0x8e>
				cputchar('\b');
f01055ea:	83 ec 0c             	sub    $0xc,%esp
f01055ed:	6a 08                	push   $0x8
f01055ef:	e8 86 b1 ff ff       	call   f010077a <cputchar>
f01055f4:	83 c4 10             	add    $0x10,%esp
			i--;
f01055f7:	83 ee 01             	sub    $0x1,%esi
f01055fa:	eb a2                	jmp    f010559e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055fc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105602:	7f 23                	jg     f0105627 <readline+0xbe>
f0105604:	83 fb 1f             	cmp    $0x1f,%ebx
f0105607:	7e 1e                	jle    f0105627 <readline+0xbe>
			if (echoing)
f0105609:	85 ff                	test   %edi,%edi
f010560b:	74 0c                	je     f0105619 <readline+0xb0>
				cputchar(c);
f010560d:	83 ec 0c             	sub    $0xc,%esp
f0105610:	53                   	push   %ebx
f0105611:	e8 64 b1 ff ff       	call   f010077a <cputchar>
f0105616:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105619:	88 9e c0 aa 20 f0    	mov    %bl,-0xfdf5540(%esi)
f010561f:	8d 76 01             	lea    0x1(%esi),%esi
f0105622:	e9 77 ff ff ff       	jmp    f010559e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105627:	83 fb 0d             	cmp    $0xd,%ebx
f010562a:	74 09                	je     f0105635 <readline+0xcc>
f010562c:	83 fb 0a             	cmp    $0xa,%ebx
f010562f:	0f 85 69 ff ff ff    	jne    f010559e <readline+0x35>
			if (echoing)
f0105635:	85 ff                	test   %edi,%edi
f0105637:	74 0d                	je     f0105646 <readline+0xdd>
				cputchar('\n');
f0105639:	83 ec 0c             	sub    $0xc,%esp
f010563c:	6a 0a                	push   $0xa
f010563e:	e8 37 b1 ff ff       	call   f010077a <cputchar>
f0105643:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105646:	c6 86 c0 aa 20 f0 00 	movb   $0x0,-0xfdf5540(%esi)
			return buf;
f010564d:	b8 c0 aa 20 f0       	mov    $0xf020aac0,%eax
		}
	}
}
f0105652:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105655:	5b                   	pop    %ebx
f0105656:	5e                   	pop    %esi
f0105657:	5f                   	pop    %edi
f0105658:	5d                   	pop    %ebp
f0105659:	c3                   	ret    

f010565a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010565a:	55                   	push   %ebp
f010565b:	89 e5                	mov    %esp,%ebp
f010565d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105660:	b8 00 00 00 00       	mov    $0x0,%eax
f0105665:	eb 03                	jmp    f010566a <strlen+0x10>
		n++;
f0105667:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010566a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010566e:	75 f7                	jne    f0105667 <strlen+0xd>
		n++;
	return n;
}
f0105670:	5d                   	pop    %ebp
f0105671:	c3                   	ret    

f0105672 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105672:	55                   	push   %ebp
f0105673:	89 e5                	mov    %esp,%ebp
f0105675:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105678:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010567b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105680:	eb 03                	jmp    f0105685 <strnlen+0x13>
		n++;
f0105682:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105685:	39 c2                	cmp    %eax,%edx
f0105687:	74 08                	je     f0105691 <strnlen+0x1f>
f0105689:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010568d:	75 f3                	jne    f0105682 <strnlen+0x10>
f010568f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105691:	5d                   	pop    %ebp
f0105692:	c3                   	ret    

f0105693 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105693:	55                   	push   %ebp
f0105694:	89 e5                	mov    %esp,%ebp
f0105696:	53                   	push   %ebx
f0105697:	8b 45 08             	mov    0x8(%ebp),%eax
f010569a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010569d:	89 c2                	mov    %eax,%edx
f010569f:	83 c2 01             	add    $0x1,%edx
f01056a2:	83 c1 01             	add    $0x1,%ecx
f01056a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01056a9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01056ac:	84 db                	test   %bl,%bl
f01056ae:	75 ef                	jne    f010569f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01056b0:	5b                   	pop    %ebx
f01056b1:	5d                   	pop    %ebp
f01056b2:	c3                   	ret    

f01056b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056b3:	55                   	push   %ebp
f01056b4:	89 e5                	mov    %esp,%ebp
f01056b6:	53                   	push   %ebx
f01056b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056ba:	53                   	push   %ebx
f01056bb:	e8 9a ff ff ff       	call   f010565a <strlen>
f01056c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01056c3:	ff 75 0c             	pushl  0xc(%ebp)
f01056c6:	01 d8                	add    %ebx,%eax
f01056c8:	50                   	push   %eax
f01056c9:	e8 c5 ff ff ff       	call   f0105693 <strcpy>
	return dst;
}
f01056ce:	89 d8                	mov    %ebx,%eax
f01056d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056d3:	c9                   	leave  
f01056d4:	c3                   	ret    

f01056d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056d5:	55                   	push   %ebp
f01056d6:	89 e5                	mov    %esp,%ebp
f01056d8:	56                   	push   %esi
f01056d9:	53                   	push   %ebx
f01056da:	8b 75 08             	mov    0x8(%ebp),%esi
f01056dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056e0:	89 f3                	mov    %esi,%ebx
f01056e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056e5:	89 f2                	mov    %esi,%edx
f01056e7:	eb 0f                	jmp    f01056f8 <strncpy+0x23>
		*dst++ = *src;
f01056e9:	83 c2 01             	add    $0x1,%edx
f01056ec:	0f b6 01             	movzbl (%ecx),%eax
f01056ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01056f2:	80 39 01             	cmpb   $0x1,(%ecx)
f01056f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056f8:	39 da                	cmp    %ebx,%edx
f01056fa:	75 ed                	jne    f01056e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01056fc:	89 f0                	mov    %esi,%eax
f01056fe:	5b                   	pop    %ebx
f01056ff:	5e                   	pop    %esi
f0105700:	5d                   	pop    %ebp
f0105701:	c3                   	ret    

f0105702 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105702:	55                   	push   %ebp
f0105703:	89 e5                	mov    %esp,%ebp
f0105705:	56                   	push   %esi
f0105706:	53                   	push   %ebx
f0105707:	8b 75 08             	mov    0x8(%ebp),%esi
f010570a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010570d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105710:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105712:	85 d2                	test   %edx,%edx
f0105714:	74 21                	je     f0105737 <strlcpy+0x35>
f0105716:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010571a:	89 f2                	mov    %esi,%edx
f010571c:	eb 09                	jmp    f0105727 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010571e:	83 c2 01             	add    $0x1,%edx
f0105721:	83 c1 01             	add    $0x1,%ecx
f0105724:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105727:	39 c2                	cmp    %eax,%edx
f0105729:	74 09                	je     f0105734 <strlcpy+0x32>
f010572b:	0f b6 19             	movzbl (%ecx),%ebx
f010572e:	84 db                	test   %bl,%bl
f0105730:	75 ec                	jne    f010571e <strlcpy+0x1c>
f0105732:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105734:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105737:	29 f0                	sub    %esi,%eax
}
f0105739:	5b                   	pop    %ebx
f010573a:	5e                   	pop    %esi
f010573b:	5d                   	pop    %ebp
f010573c:	c3                   	ret    

f010573d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010573d:	55                   	push   %ebp
f010573e:	89 e5                	mov    %esp,%ebp
f0105740:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105743:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105746:	eb 06                	jmp    f010574e <strcmp+0x11>
		p++, q++;
f0105748:	83 c1 01             	add    $0x1,%ecx
f010574b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010574e:	0f b6 01             	movzbl (%ecx),%eax
f0105751:	84 c0                	test   %al,%al
f0105753:	74 04                	je     f0105759 <strcmp+0x1c>
f0105755:	3a 02                	cmp    (%edx),%al
f0105757:	74 ef                	je     f0105748 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105759:	0f b6 c0             	movzbl %al,%eax
f010575c:	0f b6 12             	movzbl (%edx),%edx
f010575f:	29 d0                	sub    %edx,%eax
}
f0105761:	5d                   	pop    %ebp
f0105762:	c3                   	ret    

f0105763 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105763:	55                   	push   %ebp
f0105764:	89 e5                	mov    %esp,%ebp
f0105766:	53                   	push   %ebx
f0105767:	8b 45 08             	mov    0x8(%ebp),%eax
f010576a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010576d:	89 c3                	mov    %eax,%ebx
f010576f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105772:	eb 06                	jmp    f010577a <strncmp+0x17>
		n--, p++, q++;
f0105774:	83 c0 01             	add    $0x1,%eax
f0105777:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010577a:	39 d8                	cmp    %ebx,%eax
f010577c:	74 15                	je     f0105793 <strncmp+0x30>
f010577e:	0f b6 08             	movzbl (%eax),%ecx
f0105781:	84 c9                	test   %cl,%cl
f0105783:	74 04                	je     f0105789 <strncmp+0x26>
f0105785:	3a 0a                	cmp    (%edx),%cl
f0105787:	74 eb                	je     f0105774 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105789:	0f b6 00             	movzbl (%eax),%eax
f010578c:	0f b6 12             	movzbl (%edx),%edx
f010578f:	29 d0                	sub    %edx,%eax
f0105791:	eb 05                	jmp    f0105798 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105793:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105798:	5b                   	pop    %ebx
f0105799:	5d                   	pop    %ebp
f010579a:	c3                   	ret    

f010579b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010579b:	55                   	push   %ebp
f010579c:	89 e5                	mov    %esp,%ebp
f010579e:	8b 45 08             	mov    0x8(%ebp),%eax
f01057a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057a5:	eb 07                	jmp    f01057ae <strchr+0x13>
		if (*s == c)
f01057a7:	38 ca                	cmp    %cl,%dl
f01057a9:	74 0f                	je     f01057ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01057ab:	83 c0 01             	add    $0x1,%eax
f01057ae:	0f b6 10             	movzbl (%eax),%edx
f01057b1:	84 d2                	test   %dl,%dl
f01057b3:	75 f2                	jne    f01057a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01057b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057ba:	5d                   	pop    %ebp
f01057bb:	c3                   	ret    

f01057bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057bc:	55                   	push   %ebp
f01057bd:	89 e5                	mov    %esp,%ebp
f01057bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01057c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057c6:	eb 03                	jmp    f01057cb <strfind+0xf>
f01057c8:	83 c0 01             	add    $0x1,%eax
f01057cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01057ce:	84 d2                	test   %dl,%dl
f01057d0:	74 04                	je     f01057d6 <strfind+0x1a>
f01057d2:	38 ca                	cmp    %cl,%dl
f01057d4:	75 f2                	jne    f01057c8 <strfind+0xc>
			break;
	return (char *) s;
}
f01057d6:	5d                   	pop    %ebp
f01057d7:	c3                   	ret    

f01057d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057d8:	55                   	push   %ebp
f01057d9:	89 e5                	mov    %esp,%ebp
f01057db:	57                   	push   %edi
f01057dc:	56                   	push   %esi
f01057dd:	53                   	push   %ebx
f01057de:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057e4:	85 c9                	test   %ecx,%ecx
f01057e6:	74 36                	je     f010581e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057ee:	75 28                	jne    f0105818 <memset+0x40>
f01057f0:	f6 c1 03             	test   $0x3,%cl
f01057f3:	75 23                	jne    f0105818 <memset+0x40>
		c &= 0xFF;
f01057f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057f9:	89 d3                	mov    %edx,%ebx
f01057fb:	c1 e3 08             	shl    $0x8,%ebx
f01057fe:	89 d6                	mov    %edx,%esi
f0105800:	c1 e6 18             	shl    $0x18,%esi
f0105803:	89 d0                	mov    %edx,%eax
f0105805:	c1 e0 10             	shl    $0x10,%eax
f0105808:	09 f0                	or     %esi,%eax
f010580a:	09 c2                	or     %eax,%edx
f010580c:	89 d0                	mov    %edx,%eax
f010580e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105810:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105813:	fc                   	cld    
f0105814:	f3 ab                	rep stos %eax,%es:(%edi)
f0105816:	eb 06                	jmp    f010581e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105818:	8b 45 0c             	mov    0xc(%ebp),%eax
f010581b:	fc                   	cld    
f010581c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010581e:	89 f8                	mov    %edi,%eax
f0105820:	5b                   	pop    %ebx
f0105821:	5e                   	pop    %esi
f0105822:	5f                   	pop    %edi
f0105823:	5d                   	pop    %ebp
f0105824:	c3                   	ret    

f0105825 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105825:	55                   	push   %ebp
f0105826:	89 e5                	mov    %esp,%ebp
f0105828:	57                   	push   %edi
f0105829:	56                   	push   %esi
f010582a:	8b 45 08             	mov    0x8(%ebp),%eax
f010582d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105830:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105833:	39 c6                	cmp    %eax,%esi
f0105835:	73 35                	jae    f010586c <memmove+0x47>
f0105837:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010583a:	39 d0                	cmp    %edx,%eax
f010583c:	73 2e                	jae    f010586c <memmove+0x47>
		s += n;
		d += n;
f010583e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105841:	89 d6                	mov    %edx,%esi
f0105843:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105845:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010584b:	75 13                	jne    f0105860 <memmove+0x3b>
f010584d:	f6 c1 03             	test   $0x3,%cl
f0105850:	75 0e                	jne    f0105860 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105852:	83 ef 04             	sub    $0x4,%edi
f0105855:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105858:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010585b:	fd                   	std    
f010585c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010585e:	eb 09                	jmp    f0105869 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105860:	83 ef 01             	sub    $0x1,%edi
f0105863:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105866:	fd                   	std    
f0105867:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105869:	fc                   	cld    
f010586a:	eb 1d                	jmp    f0105889 <memmove+0x64>
f010586c:	89 f2                	mov    %esi,%edx
f010586e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105870:	f6 c2 03             	test   $0x3,%dl
f0105873:	75 0f                	jne    f0105884 <memmove+0x5f>
f0105875:	f6 c1 03             	test   $0x3,%cl
f0105878:	75 0a                	jne    f0105884 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010587a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010587d:	89 c7                	mov    %eax,%edi
f010587f:	fc                   	cld    
f0105880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105882:	eb 05                	jmp    f0105889 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105884:	89 c7                	mov    %eax,%edi
f0105886:	fc                   	cld    
f0105887:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105889:	5e                   	pop    %esi
f010588a:	5f                   	pop    %edi
f010588b:	5d                   	pop    %ebp
f010588c:	c3                   	ret    

f010588d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010588d:	55                   	push   %ebp
f010588e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105890:	ff 75 10             	pushl  0x10(%ebp)
f0105893:	ff 75 0c             	pushl  0xc(%ebp)
f0105896:	ff 75 08             	pushl  0x8(%ebp)
f0105899:	e8 87 ff ff ff       	call   f0105825 <memmove>
}
f010589e:	c9                   	leave  
f010589f:	c3                   	ret    

f01058a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058a0:	55                   	push   %ebp
f01058a1:	89 e5                	mov    %esp,%ebp
f01058a3:	56                   	push   %esi
f01058a4:	53                   	push   %ebx
f01058a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058ab:	89 c6                	mov    %eax,%esi
f01058ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058b0:	eb 1a                	jmp    f01058cc <memcmp+0x2c>
		if (*s1 != *s2)
f01058b2:	0f b6 08             	movzbl (%eax),%ecx
f01058b5:	0f b6 1a             	movzbl (%edx),%ebx
f01058b8:	38 d9                	cmp    %bl,%cl
f01058ba:	74 0a                	je     f01058c6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01058bc:	0f b6 c1             	movzbl %cl,%eax
f01058bf:	0f b6 db             	movzbl %bl,%ebx
f01058c2:	29 d8                	sub    %ebx,%eax
f01058c4:	eb 0f                	jmp    f01058d5 <memcmp+0x35>
		s1++, s2++;
f01058c6:	83 c0 01             	add    $0x1,%eax
f01058c9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058cc:	39 f0                	cmp    %esi,%eax
f01058ce:	75 e2                	jne    f01058b2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01058d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058d5:	5b                   	pop    %ebx
f01058d6:	5e                   	pop    %esi
f01058d7:	5d                   	pop    %ebp
f01058d8:	c3                   	ret    

f01058d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058d9:	55                   	push   %ebp
f01058da:	89 e5                	mov    %esp,%ebp
f01058dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01058df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01058e2:	89 c2                	mov    %eax,%edx
f01058e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058e7:	eb 07                	jmp    f01058f0 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058e9:	38 08                	cmp    %cl,(%eax)
f01058eb:	74 07                	je     f01058f4 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058ed:	83 c0 01             	add    $0x1,%eax
f01058f0:	39 d0                	cmp    %edx,%eax
f01058f2:	72 f5                	jb     f01058e9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01058f4:	5d                   	pop    %ebp
f01058f5:	c3                   	ret    

f01058f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058f6:	55                   	push   %ebp
f01058f7:	89 e5                	mov    %esp,%ebp
f01058f9:	57                   	push   %edi
f01058fa:	56                   	push   %esi
f01058fb:	53                   	push   %ebx
f01058fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105902:	eb 03                	jmp    f0105907 <strtol+0x11>
		s++;
f0105904:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105907:	0f b6 01             	movzbl (%ecx),%eax
f010590a:	3c 09                	cmp    $0x9,%al
f010590c:	74 f6                	je     f0105904 <strtol+0xe>
f010590e:	3c 20                	cmp    $0x20,%al
f0105910:	74 f2                	je     f0105904 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105912:	3c 2b                	cmp    $0x2b,%al
f0105914:	75 0a                	jne    f0105920 <strtol+0x2a>
		s++;
f0105916:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105919:	bf 00 00 00 00       	mov    $0x0,%edi
f010591e:	eb 10                	jmp    f0105930 <strtol+0x3a>
f0105920:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105925:	3c 2d                	cmp    $0x2d,%al
f0105927:	75 07                	jne    f0105930 <strtol+0x3a>
		s++, neg = 1;
f0105929:	8d 49 01             	lea    0x1(%ecx),%ecx
f010592c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105930:	85 db                	test   %ebx,%ebx
f0105932:	0f 94 c0             	sete   %al
f0105935:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010593b:	75 19                	jne    f0105956 <strtol+0x60>
f010593d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105940:	75 14                	jne    f0105956 <strtol+0x60>
f0105942:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105946:	0f 85 82 00 00 00    	jne    f01059ce <strtol+0xd8>
		s += 2, base = 16;
f010594c:	83 c1 02             	add    $0x2,%ecx
f010594f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105954:	eb 16                	jmp    f010596c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105956:	84 c0                	test   %al,%al
f0105958:	74 12                	je     f010596c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010595a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010595f:	80 39 30             	cmpb   $0x30,(%ecx)
f0105962:	75 08                	jne    f010596c <strtol+0x76>
		s++, base = 8;
f0105964:	83 c1 01             	add    $0x1,%ecx
f0105967:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010596c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105971:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105974:	0f b6 11             	movzbl (%ecx),%edx
f0105977:	8d 72 d0             	lea    -0x30(%edx),%esi
f010597a:	89 f3                	mov    %esi,%ebx
f010597c:	80 fb 09             	cmp    $0x9,%bl
f010597f:	77 08                	ja     f0105989 <strtol+0x93>
			dig = *s - '0';
f0105981:	0f be d2             	movsbl %dl,%edx
f0105984:	83 ea 30             	sub    $0x30,%edx
f0105987:	eb 22                	jmp    f01059ab <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0105989:	8d 72 9f             	lea    -0x61(%edx),%esi
f010598c:	89 f3                	mov    %esi,%ebx
f010598e:	80 fb 19             	cmp    $0x19,%bl
f0105991:	77 08                	ja     f010599b <strtol+0xa5>
			dig = *s - 'a' + 10;
f0105993:	0f be d2             	movsbl %dl,%edx
f0105996:	83 ea 57             	sub    $0x57,%edx
f0105999:	eb 10                	jmp    f01059ab <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f010599b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010599e:	89 f3                	mov    %esi,%ebx
f01059a0:	80 fb 19             	cmp    $0x19,%bl
f01059a3:	77 16                	ja     f01059bb <strtol+0xc5>
			dig = *s - 'A' + 10;
f01059a5:	0f be d2             	movsbl %dl,%edx
f01059a8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01059ab:	3b 55 10             	cmp    0x10(%ebp),%edx
f01059ae:	7d 0f                	jge    f01059bf <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f01059b0:	83 c1 01             	add    $0x1,%ecx
f01059b3:	0f af 45 10          	imul   0x10(%ebp),%eax
f01059b7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01059b9:	eb b9                	jmp    f0105974 <strtol+0x7e>
f01059bb:	89 c2                	mov    %eax,%edx
f01059bd:	eb 02                	jmp    f01059c1 <strtol+0xcb>
f01059bf:	89 c2                	mov    %eax,%edx

	if (endptr)
f01059c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059c5:	74 0d                	je     f01059d4 <strtol+0xde>
		*endptr = (char *) s;
f01059c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059ca:	89 0e                	mov    %ecx,(%esi)
f01059cc:	eb 06                	jmp    f01059d4 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01059ce:	84 c0                	test   %al,%al
f01059d0:	75 92                	jne    f0105964 <strtol+0x6e>
f01059d2:	eb 98                	jmp    f010596c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01059d4:	f7 da                	neg    %edx
f01059d6:	85 ff                	test   %edi,%edi
f01059d8:	0f 45 c2             	cmovne %edx,%eax
}
f01059db:	5b                   	pop    %ebx
f01059dc:	5e                   	pop    %esi
f01059dd:	5f                   	pop    %edi
f01059de:	5d                   	pop    %ebp
f01059df:	c3                   	ret    

f01059e0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059e0:	fa                   	cli    

	xorw    %ax, %ax
f01059e1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059e3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059e5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059e7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059e9:	0f 01 16             	lgdtl  (%esi)
f01059ec:	74 70                	je     f0105a5e <mpsearch1+0x3>
	movl    %cr0, %eax
f01059ee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059f1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01059f5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059f8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059fe:	08 00                	or     %al,(%eax)

f0105a00 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a00:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a04:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a06:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a08:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a0a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a0e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a10:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a12:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105a17:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a1a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a1d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a22:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a25:	8b 25 c4 ae 20 f0    	mov    0xf020aec4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a2b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a30:	b8 c8 01 10 f0       	mov    $0xf01001c8,%eax
	call    *%eax
f0105a35:	ff d0                	call   *%eax

f0105a37 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a37:	eb fe                	jmp    f0105a37 <spin>
f0105a39:	8d 76 00             	lea    0x0(%esi),%esi

f0105a3c <gdt>:
	...
f0105a44:	ff                   	(bad)  
f0105a45:	ff 00                	incl   (%eax)
f0105a47:	00 00                	add    %al,(%eax)
f0105a49:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a50:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105a54 <gdtdesc>:
f0105a54:	17                   	pop    %ss
f0105a55:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a5a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a5a:	90                   	nop

f0105a5b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a5b:	55                   	push   %ebp
f0105a5c:	89 e5                	mov    %esp,%ebp
f0105a5e:	57                   	push   %edi
f0105a5f:	56                   	push   %esi
f0105a60:	53                   	push   %ebx
f0105a61:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a64:	8b 0d c8 ae 20 f0    	mov    0xf020aec8,%ecx
f0105a6a:	89 c3                	mov    %eax,%ebx
f0105a6c:	c1 eb 0c             	shr    $0xc,%ebx
f0105a6f:	39 cb                	cmp    %ecx,%ebx
f0105a71:	72 12                	jb     f0105a85 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a73:	50                   	push   %eax
f0105a74:	68 e4 64 10 f0       	push   $0xf01064e4
f0105a79:	6a 57                	push   $0x57
f0105a7b:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a80:	e8 bb a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a85:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a8b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a8d:	89 c2                	mov    %eax,%edx
f0105a8f:	c1 ea 0c             	shr    $0xc,%edx
f0105a92:	39 d1                	cmp    %edx,%ecx
f0105a94:	77 12                	ja     f0105aa8 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a96:	50                   	push   %eax
f0105a97:	68 e4 64 10 f0       	push   $0xf01064e4
f0105a9c:	6a 57                	push   $0x57
f0105a9e:	68 bd 80 10 f0       	push   $0xf01080bd
f0105aa3:	e8 98 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105aa8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105aae:	eb 2f                	jmp    f0105adf <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ab0:	83 ec 04             	sub    $0x4,%esp
f0105ab3:	6a 04                	push   $0x4
f0105ab5:	68 cd 80 10 f0       	push   $0xf01080cd
f0105aba:	53                   	push   %ebx
f0105abb:	e8 e0 fd ff ff       	call   f01058a0 <memcmp>
f0105ac0:	83 c4 10             	add    $0x10,%esp
f0105ac3:	85 c0                	test   %eax,%eax
f0105ac5:	75 15                	jne    f0105adc <mpsearch1+0x81>
f0105ac7:	89 da                	mov    %ebx,%edx
f0105ac9:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105acc:	0f b6 0a             	movzbl (%edx),%ecx
f0105acf:	01 c8                	add    %ecx,%eax
f0105ad1:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ad4:	39 fa                	cmp    %edi,%edx
f0105ad6:	75 f4                	jne    f0105acc <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ad8:	84 c0                	test   %al,%al
f0105ada:	74 0e                	je     f0105aea <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105adc:	83 c3 10             	add    $0x10,%ebx
f0105adf:	39 f3                	cmp    %esi,%ebx
f0105ae1:	72 cd                	jb     f0105ab0 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ae3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ae8:	eb 02                	jmp    f0105aec <mpsearch1+0x91>
f0105aea:	89 d8                	mov    %ebx,%eax
}
f0105aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105aef:	5b                   	pop    %ebx
f0105af0:	5e                   	pop    %esi
f0105af1:	5f                   	pop    %edi
f0105af2:	5d                   	pop    %ebp
f0105af3:	c3                   	ret    

f0105af4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105af4:	55                   	push   %ebp
f0105af5:	89 e5                	mov    %esp,%ebp
f0105af7:	57                   	push   %edi
f0105af8:	56                   	push   %esi
f0105af9:	53                   	push   %ebx
f0105afa:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105afd:	c7 05 e0 b3 20 f0 40 	movl   $0xf020b040,0xf020b3e0
f0105b04:	b0 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b07:	83 3d c8 ae 20 f0 00 	cmpl   $0x0,0xf020aec8
f0105b0e:	75 16                	jne    f0105b26 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b10:	68 00 04 00 00       	push   $0x400
f0105b15:	68 e4 64 10 f0       	push   $0xf01064e4
f0105b1a:	6a 6f                	push   $0x6f
f0105b1c:	68 bd 80 10 f0       	push   $0xf01080bd
f0105b21:	e8 1a a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b26:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b2d:	85 c0                	test   %eax,%eax
f0105b2f:	74 16                	je     f0105b47 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105b31:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b34:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b39:	e8 1d ff ff ff       	call   f0105a5b <mpsearch1>
f0105b3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b41:	85 c0                	test   %eax,%eax
f0105b43:	75 3c                	jne    f0105b81 <mp_init+0x8d>
f0105b45:	eb 20                	jmp    f0105b67 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105b47:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b4e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b51:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b56:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b5b:	e8 fb fe ff ff       	call   f0105a5b <mpsearch1>
f0105b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b63:	85 c0                	test   %eax,%eax
f0105b65:	75 1a                	jne    f0105b81 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b67:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b6c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b71:	e8 e5 fe ff ff       	call   f0105a5b <mpsearch1>
f0105b76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b79:	85 c0                	test   %eax,%eax
f0105b7b:	0f 84 5a 02 00 00    	je     f0105ddb <mp_init+0x2e7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b84:	8b 70 04             	mov    0x4(%eax),%esi
f0105b87:	85 f6                	test   %esi,%esi
f0105b89:	74 06                	je     f0105b91 <mp_init+0x9d>
f0105b8b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b8f:	74 15                	je     f0105ba6 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b91:	83 ec 0c             	sub    $0xc,%esp
f0105b94:	68 30 7f 10 f0       	push   $0xf0107f30
f0105b99:	e8 73 db ff ff       	call   f0103711 <cprintf>
f0105b9e:	83 c4 10             	add    $0x10,%esp
f0105ba1:	e9 35 02 00 00       	jmp    f0105ddb <mp_init+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ba6:	89 f0                	mov    %esi,%eax
f0105ba8:	c1 e8 0c             	shr    $0xc,%eax
f0105bab:	3b 05 c8 ae 20 f0    	cmp    0xf020aec8,%eax
f0105bb1:	72 15                	jb     f0105bc8 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bb3:	56                   	push   %esi
f0105bb4:	68 e4 64 10 f0       	push   $0xf01064e4
f0105bb9:	68 90 00 00 00       	push   $0x90
f0105bbe:	68 bd 80 10 f0       	push   $0xf01080bd
f0105bc3:	e8 78 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105bc8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105bce:	83 ec 04             	sub    $0x4,%esp
f0105bd1:	6a 04                	push   $0x4
f0105bd3:	68 d2 80 10 f0       	push   $0xf01080d2
f0105bd8:	53                   	push   %ebx
f0105bd9:	e8 c2 fc ff ff       	call   f01058a0 <memcmp>
f0105bde:	83 c4 10             	add    $0x10,%esp
f0105be1:	85 c0                	test   %eax,%eax
f0105be3:	74 15                	je     f0105bfa <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105be5:	83 ec 0c             	sub    $0xc,%esp
f0105be8:	68 60 7f 10 f0       	push   $0xf0107f60
f0105bed:	e8 1f db ff ff       	call   f0103711 <cprintf>
f0105bf2:	83 c4 10             	add    $0x10,%esp
f0105bf5:	e9 e1 01 00 00       	jmp    f0105ddb <mp_init+0x2e7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bfa:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105bfe:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105c02:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c05:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c0f:	eb 0d                	jmp    f0105c1e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105c11:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105c18:	f0 
f0105c19:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c1b:	83 c0 01             	add    $0x1,%eax
f0105c1e:	39 c7                	cmp    %eax,%edi
f0105c20:	75 ef                	jne    f0105c11 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c22:	84 d2                	test   %dl,%dl
f0105c24:	74 15                	je     f0105c3b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c26:	83 ec 0c             	sub    $0xc,%esp
f0105c29:	68 94 7f 10 f0       	push   $0xf0107f94
f0105c2e:	e8 de da ff ff       	call   f0103711 <cprintf>
f0105c33:	83 c4 10             	add    $0x10,%esp
f0105c36:	e9 a0 01 00 00       	jmp    f0105ddb <mp_init+0x2e7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c3b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c3f:	3c 04                	cmp    $0x4,%al
f0105c41:	74 1d                	je     f0105c60 <mp_init+0x16c>
f0105c43:	3c 01                	cmp    $0x1,%al
f0105c45:	74 19                	je     f0105c60 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c47:	83 ec 08             	sub    $0x8,%esp
f0105c4a:	0f b6 c0             	movzbl %al,%eax
f0105c4d:	50                   	push   %eax
f0105c4e:	68 b8 7f 10 f0       	push   $0xf0107fb8
f0105c53:	e8 b9 da ff ff       	call   f0103711 <cprintf>
f0105c58:	83 c4 10             	add    $0x10,%esp
f0105c5b:	e9 7b 01 00 00       	jmp    f0105ddb <mp_init+0x2e7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c60:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105c64:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c68:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c72:	01 ce                	add    %ecx,%esi
f0105c74:	eb 0d                	jmp    f0105c83 <mp_init+0x18f>
		sum += ((uint8_t *)addr)[i];
f0105c76:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c7d:	f0 
f0105c7e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c80:	83 c0 01             	add    $0x1,%eax
f0105c83:	39 c7                	cmp    %eax,%edi
f0105c85:	75 ef                	jne    f0105c76 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c87:	89 d0                	mov    %edx,%eax
f0105c89:	02 43 2a             	add    0x2a(%ebx),%al
f0105c8c:	74 15                	je     f0105ca3 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c8e:	83 ec 0c             	sub    $0xc,%esp
f0105c91:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0105c96:	e8 76 da ff ff       	call   f0103711 <cprintf>
f0105c9b:	83 c4 10             	add    $0x10,%esp
f0105c9e:	e9 38 01 00 00       	jmp    f0105ddb <mp_init+0x2e7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105ca3:	85 db                	test   %ebx,%ebx
f0105ca5:	0f 84 30 01 00 00    	je     f0105ddb <mp_init+0x2e7>
		return;
	ismp = 1;
f0105cab:	c7 05 00 b0 20 f0 01 	movl   $0x1,0xf020b000
f0105cb2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105cb5:	8b 43 24             	mov    0x24(%ebx),%eax
f0105cb8:	a3 00 c0 24 f0       	mov    %eax,0xf024c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cbd:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105cc0:	be 00 00 00 00       	mov    $0x0,%esi
f0105cc5:	e9 85 00 00 00       	jmp    f0105d4f <mp_init+0x25b>
		switch (*p) {
f0105cca:	0f b6 07             	movzbl (%edi),%eax
f0105ccd:	84 c0                	test   %al,%al
f0105ccf:	74 06                	je     f0105cd7 <mp_init+0x1e3>
f0105cd1:	3c 04                	cmp    $0x4,%al
f0105cd3:	77 55                	ja     f0105d2a <mp_init+0x236>
f0105cd5:	eb 4e                	jmp    f0105d25 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105cd7:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105cdb:	74 11                	je     f0105cee <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105cdd:	6b 05 e4 b3 20 f0 74 	imul   $0x74,0xf020b3e4,%eax
f0105ce4:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f0105ce9:	a3 e0 b3 20 f0       	mov    %eax,0xf020b3e0
			if (ncpu < NCPU) {
f0105cee:	a1 e4 b3 20 f0       	mov    0xf020b3e4,%eax
f0105cf3:	83 f8 07             	cmp    $0x7,%eax
f0105cf6:	7f 13                	jg     f0105d0b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105cf8:	6b d0 74             	imul   $0x74,%eax,%edx
f0105cfb:	88 82 40 b0 20 f0    	mov    %al,-0xfdf4fc0(%edx)
				ncpu++;
f0105d01:	83 c0 01             	add    $0x1,%eax
f0105d04:	a3 e4 b3 20 f0       	mov    %eax,0xf020b3e4
f0105d09:	eb 15                	jmp    f0105d20 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d0b:	83 ec 08             	sub    $0x8,%esp
f0105d0e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d12:	50                   	push   %eax
f0105d13:	68 08 80 10 f0       	push   $0xf0108008
f0105d18:	e8 f4 d9 ff ff       	call   f0103711 <cprintf>
f0105d1d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d20:	83 c7 14             	add    $0x14,%edi
			continue;
f0105d23:	eb 27                	jmp    f0105d4c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d25:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d28:	eb 22                	jmp    f0105d4c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d2a:	83 ec 08             	sub    $0x8,%esp
f0105d2d:	0f b6 c0             	movzbl %al,%eax
f0105d30:	50                   	push   %eax
f0105d31:	68 30 80 10 f0       	push   $0xf0108030
f0105d36:	e8 d6 d9 ff ff       	call   f0103711 <cprintf>
			ismp = 0;
f0105d3b:	c7 05 00 b0 20 f0 00 	movl   $0x0,0xf020b000
f0105d42:	00 00 00 
			i = conf->entry;
f0105d45:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105d49:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d4c:	83 c6 01             	add    $0x1,%esi
f0105d4f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d53:	39 c6                	cmp    %eax,%esi
f0105d55:	0f 82 6f ff ff ff    	jb     f0105cca <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d5b:	a1 e0 b3 20 f0       	mov    0xf020b3e0,%eax
f0105d60:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d67:	83 3d 00 b0 20 f0 00 	cmpl   $0x0,0xf020b000
f0105d6e:	75 26                	jne    f0105d96 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d70:	c7 05 e4 b3 20 f0 01 	movl   $0x1,0xf020b3e4
f0105d77:	00 00 00 
		lapicaddr = 0;
f0105d7a:	c7 05 00 c0 24 f0 00 	movl   $0x0,0xf024c000
f0105d81:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d84:	83 ec 0c             	sub    $0xc,%esp
f0105d87:	68 50 80 10 f0       	push   $0xf0108050
f0105d8c:	e8 80 d9 ff ff       	call   f0103711 <cprintf>
		return;
f0105d91:	83 c4 10             	add    $0x10,%esp
f0105d94:	eb 45                	jmp    f0105ddb <mp_init+0x2e7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d96:	83 ec 04             	sub    $0x4,%esp
f0105d99:	ff 35 e4 b3 20 f0    	pushl  0xf020b3e4
f0105d9f:	0f b6 00             	movzbl (%eax),%eax
f0105da2:	50                   	push   %eax
f0105da3:	68 d7 80 10 f0       	push   $0xf01080d7
f0105da8:	e8 64 d9 ff ff       	call   f0103711 <cprintf>

	if (mp->imcrp) {
f0105dad:	83 c4 10             	add    $0x10,%esp
f0105db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105db3:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105db7:	74 22                	je     f0105ddb <mp_init+0x2e7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105db9:	83 ec 0c             	sub    $0xc,%esp
f0105dbc:	68 7c 80 10 f0       	push   $0xf010807c
f0105dc1:	e8 4b d9 ff ff       	call   f0103711 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dc6:	ba 22 00 00 00       	mov    $0x22,%edx
f0105dcb:	b8 70 00 00 00       	mov    $0x70,%eax
f0105dd0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105dd1:	b2 23                	mov    $0x23,%dl
f0105dd3:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105dd4:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dd7:	ee                   	out    %al,(%dx)
f0105dd8:	83 c4 10             	add    $0x10,%esp
	}
}
f0105ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105dde:	5b                   	pop    %ebx
f0105ddf:	5e                   	pop    %esi
f0105de0:	5f                   	pop    %edi
f0105de1:	5d                   	pop    %ebp
f0105de2:	c3                   	ret    

f0105de3 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105de3:	55                   	push   %ebp
f0105de4:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105de6:	8b 0d 04 c0 24 f0    	mov    0xf024c004,%ecx
f0105dec:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105def:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105df1:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105df6:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105df9:	5d                   	pop    %ebp
f0105dfa:	c3                   	ret    

f0105dfb <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105dfb:	55                   	push   %ebp
f0105dfc:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105dfe:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105e03:	85 c0                	test   %eax,%eax
f0105e05:	74 08                	je     f0105e0f <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e07:	8b 40 20             	mov    0x20(%eax),%eax
f0105e0a:	c1 e8 18             	shr    $0x18,%eax
f0105e0d:	eb 05                	jmp    f0105e14 <cpunum+0x19>
	return 0;
f0105e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e14:	5d                   	pop    %ebp
f0105e15:	c3                   	ret    

f0105e16 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105e16:	a1 00 c0 24 f0       	mov    0xf024c000,%eax
f0105e1b:	85 c0                	test   %eax,%eax
f0105e1d:	0f 84 21 01 00 00    	je     f0105f44 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e23:	55                   	push   %ebp
f0105e24:	89 e5                	mov    %esp,%ebp
f0105e26:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e29:	68 00 10 00 00       	push   $0x1000
f0105e2e:	50                   	push   %eax
f0105e2f:	e8 01 b5 ff ff       	call   f0101335 <mmio_map_region>
f0105e34:	a3 04 c0 24 f0       	mov    %eax,0xf024c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e39:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e3e:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e43:	e8 9b ff ff ff       	call   f0105de3 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e48:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e4d:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e52:	e8 8c ff ff ff       	call   f0105de3 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e57:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e5c:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e61:	e8 7d ff ff ff       	call   f0105de3 <lapicw>
	lapicw(TICR, 10000000); 
f0105e66:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e6b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e70:	e8 6e ff ff ff       	call   f0105de3 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e75:	e8 81 ff ff ff       	call   f0105dfb <cpunum>
f0105e7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e7d:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f0105e82:	83 c4 10             	add    $0x10,%esp
f0105e85:	39 05 e0 b3 20 f0    	cmp    %eax,0xf020b3e0
f0105e8b:	74 0f                	je     f0105e9c <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e8d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e92:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e97:	e8 47 ff ff ff       	call   f0105de3 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e9c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ea1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ea6:	e8 38 ff ff ff       	call   f0105de3 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105eab:	a1 04 c0 24 f0       	mov    0xf024c004,%eax
f0105eb0:	8b 40 30             	mov    0x30(%eax),%eax
f0105eb3:	c1 e8 10             	shr    $0x10,%eax
f0105eb6:	3c 03                	cmp    $0x3,%al
f0105eb8:	76 0f                	jbe    f0105ec9 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105eba:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ebf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105ec4:	e8 1a ff ff ff       	call   f0105de3 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ec9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ece:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ed3:	e8 0b ff ff ff       	call   f0105de3 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ed8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105edd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ee2:	e8 fc fe ff ff       	call   f0105de3 <lapicw>
	lapicw(ESR, 0);
f0105ee7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eec:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ef1:	e8 ed fe ff ff       	call   f0105de3 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ef6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105efb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f00:	e8 de fe ff ff       	call   f0105de3 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105f05:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f0a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f0f:	e8 cf fe ff ff       	call   f0105de3 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f14:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f19:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f1e:	e8 c0 fe ff ff       	call   f0105de3 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f23:	8b 15 04 c0 24 f0    	mov    0xf024c004,%edx
f0105f29:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f2f:	f6 c4 10             	test   $0x10,%ah
f0105f32:	75 f5                	jne    f0105f29 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f34:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f39:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f3e:	e8 a0 fe ff ff       	call   f0105de3 <lapicw>
}
f0105f43:	c9                   	leave  
f0105f44:	f3 c3                	repz ret 

f0105f46 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f46:	83 3d 04 c0 24 f0 00 	cmpl   $0x0,0xf024c004
f0105f4d:	74 13                	je     f0105f62 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f4f:	55                   	push   %ebp
f0105f50:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f52:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f57:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f5c:	e8 82 fe ff ff       	call   f0105de3 <lapicw>
}
f0105f61:	5d                   	pop    %ebp
f0105f62:	f3 c3                	repz ret 

f0105f64 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f64:	55                   	push   %ebp
f0105f65:	89 e5                	mov    %esp,%ebp
f0105f67:	56                   	push   %esi
f0105f68:	53                   	push   %ebx
f0105f69:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f6f:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f74:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f79:	ee                   	out    %al,(%dx)
f0105f7a:	b2 71                	mov    $0x71,%dl
f0105f7c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f81:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f82:	83 3d c8 ae 20 f0 00 	cmpl   $0x0,0xf020aec8
f0105f89:	75 19                	jne    f0105fa4 <lapic_startap+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f8b:	68 67 04 00 00       	push   $0x467
f0105f90:	68 e4 64 10 f0       	push   $0xf01064e4
f0105f95:	68 98 00 00 00       	push   $0x98
f0105f9a:	68 f4 80 10 f0       	push   $0xf01080f4
f0105f9f:	e8 9c a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105fa4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fab:	00 00 
	wrv[1] = addr >> 4;
f0105fad:	89 d8                	mov    %ebx,%eax
f0105faf:	c1 e8 04             	shr    $0x4,%eax
f0105fb2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fb8:	c1 e6 18             	shl    $0x18,%esi
f0105fbb:	89 f2                	mov    %esi,%edx
f0105fbd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fc2:	e8 1c fe ff ff       	call   f0105de3 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fc7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105fcc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fd1:	e8 0d fe ff ff       	call   f0105de3 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fd6:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105fdb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fe0:	e8 fe fd ff ff       	call   f0105de3 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fe5:	c1 eb 0c             	shr    $0xc,%ebx
f0105fe8:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105feb:	89 f2                	mov    %esi,%edx
f0105fed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ff2:	e8 ec fd ff ff       	call   f0105de3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ff7:	89 da                	mov    %ebx,%edx
f0105ff9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ffe:	e8 e0 fd ff ff       	call   f0105de3 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106003:	89 f2                	mov    %esi,%edx
f0106005:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010600a:	e8 d4 fd ff ff       	call   f0105de3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010600f:	89 da                	mov    %ebx,%edx
f0106011:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106016:	e8 c8 fd ff ff       	call   f0105de3 <lapicw>
		microdelay(200);
	}
}
f010601b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010601e:	5b                   	pop    %ebx
f010601f:	5e                   	pop    %esi
f0106020:	5d                   	pop    %ebp
f0106021:	c3                   	ret    

f0106022 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106022:	55                   	push   %ebp
f0106023:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106025:	8b 55 08             	mov    0x8(%ebp),%edx
f0106028:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010602e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106033:	e8 ab fd ff ff       	call   f0105de3 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106038:	8b 15 04 c0 24 f0    	mov    0xf024c004,%edx
f010603e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106044:	f6 c4 10             	test   $0x10,%ah
f0106047:	75 f5                	jne    f010603e <lapic_ipi+0x1c>
		;
}
f0106049:	5d                   	pop    %ebp
f010604a:	c3                   	ret    

f010604b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010604b:	55                   	push   %ebp
f010604c:	89 e5                	mov    %esp,%ebp
f010604e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106057:	8b 55 0c             	mov    0xc(%ebp),%edx
f010605a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010605d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106064:	5d                   	pop    %ebp
f0106065:	c3                   	ret    

f0106066 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106066:	55                   	push   %ebp
f0106067:	89 e5                	mov    %esp,%ebp
f0106069:	56                   	push   %esi
f010606a:	53                   	push   %ebx
f010606b:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010606e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106071:	74 14                	je     f0106087 <spin_lock+0x21>
f0106073:	8b 73 08             	mov    0x8(%ebx),%esi
f0106076:	e8 80 fd ff ff       	call   f0105dfb <cpunum>
f010607b:	6b c0 74             	imul   $0x74,%eax,%eax
f010607e:	05 40 b0 20 f0       	add    $0xf020b040,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106083:	39 c6                	cmp    %eax,%esi
f0106085:	74 07                	je     f010608e <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106087:	ba 01 00 00 00       	mov    $0x1,%edx
f010608c:	eb 20                	jmp    f01060ae <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010608e:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106091:	e8 65 fd ff ff       	call   f0105dfb <cpunum>
f0106096:	83 ec 0c             	sub    $0xc,%esp
f0106099:	53                   	push   %ebx
f010609a:	50                   	push   %eax
f010609b:	68 04 81 10 f0       	push   $0xf0108104
f01060a0:	6a 41                	push   $0x41
f01060a2:	68 68 81 10 f0       	push   $0xf0108168
f01060a7:	e8 94 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060ac:	f3 90                	pause  
f01060ae:	89 d0                	mov    %edx,%eax
f01060b0:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01060b3:	85 c0                	test   %eax,%eax
f01060b5:	75 f5                	jne    f01060ac <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060b7:	e8 3f fd ff ff       	call   f0105dfb <cpunum>
f01060bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01060bf:	05 40 b0 20 f0       	add    $0xf020b040,%eax
f01060c4:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060c7:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01060ca:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01060cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01060d1:	eb 0b                	jmp    f01060de <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060d3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060d6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060d9:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060db:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060de:	83 f8 09             	cmp    $0x9,%eax
f01060e1:	7f 14                	jg     f01060f7 <spin_lock+0x91>
f01060e3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060e9:	77 e8                	ja     f01060d3 <spin_lock+0x6d>
f01060eb:	eb 0a                	jmp    f01060f7 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01060ed:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01060f4:	83 c0 01             	add    $0x1,%eax
f01060f7:	83 f8 09             	cmp    $0x9,%eax
f01060fa:	7e f1                	jle    f01060ed <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01060fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01060ff:	5b                   	pop    %ebx
f0106100:	5e                   	pop    %esi
f0106101:	5d                   	pop    %ebp
f0106102:	c3                   	ret    

f0106103 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106103:	55                   	push   %ebp
f0106104:	89 e5                	mov    %esp,%ebp
f0106106:	57                   	push   %edi
f0106107:	56                   	push   %esi
f0106108:	53                   	push   %ebx
f0106109:	83 ec 4c             	sub    $0x4c,%esp
f010610c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010610f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106112:	74 18                	je     f010612c <spin_unlock+0x29>
f0106114:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106117:	e8 df fc ff ff       	call   f0105dfb <cpunum>
f010611c:	6b c0 74             	imul   $0x74,%eax,%eax
f010611f:	05 40 b0 20 f0       	add    $0xf020b040,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106124:	39 c3                	cmp    %eax,%ebx
f0106126:	0f 84 a5 00 00 00    	je     f01061d1 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010612c:	83 ec 04             	sub    $0x4,%esp
f010612f:	6a 28                	push   $0x28
f0106131:	8d 46 0c             	lea    0xc(%esi),%eax
f0106134:	50                   	push   %eax
f0106135:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106138:	53                   	push   %ebx
f0106139:	e8 e7 f6 ff ff       	call   f0105825 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010613e:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106141:	0f b6 38             	movzbl (%eax),%edi
f0106144:	8b 76 04             	mov    0x4(%esi),%esi
f0106147:	e8 af fc ff ff       	call   f0105dfb <cpunum>
f010614c:	57                   	push   %edi
f010614d:	56                   	push   %esi
f010614e:	50                   	push   %eax
f010614f:	68 30 81 10 f0       	push   $0xf0108130
f0106154:	e8 b8 d5 ff ff       	call   f0103711 <cprintf>
f0106159:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010615c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010615f:	eb 54                	jmp    f01061b5 <spin_unlock+0xb2>
f0106161:	83 ec 08             	sub    $0x8,%esp
f0106164:	57                   	push   %edi
f0106165:	50                   	push   %eax
f0106166:	e8 e6 eb ff ff       	call   f0104d51 <debuginfo_eip>
f010616b:	83 c4 10             	add    $0x10,%esp
f010616e:	85 c0                	test   %eax,%eax
f0106170:	78 27                	js     f0106199 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106172:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106174:	83 ec 04             	sub    $0x4,%esp
f0106177:	89 c2                	mov    %eax,%edx
f0106179:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010617c:	52                   	push   %edx
f010617d:	ff 75 b0             	pushl  -0x50(%ebp)
f0106180:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106183:	ff 75 ac             	pushl  -0x54(%ebp)
f0106186:	ff 75 a8             	pushl  -0x58(%ebp)
f0106189:	50                   	push   %eax
f010618a:	68 78 81 10 f0       	push   $0xf0108178
f010618f:	e8 7d d5 ff ff       	call   f0103711 <cprintf>
f0106194:	83 c4 20             	add    $0x20,%esp
f0106197:	eb 12                	jmp    f01061ab <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106199:	83 ec 08             	sub    $0x8,%esp
f010619c:	ff 36                	pushl  (%esi)
f010619e:	68 8f 81 10 f0       	push   $0xf010818f
f01061a3:	e8 69 d5 ff ff       	call   f0103711 <cprintf>
f01061a8:	83 c4 10             	add    $0x10,%esp
f01061ab:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01061b1:	39 c3                	cmp    %eax,%ebx
f01061b3:	74 08                	je     f01061bd <spin_unlock+0xba>
f01061b5:	89 de                	mov    %ebx,%esi
f01061b7:	8b 03                	mov    (%ebx),%eax
f01061b9:	85 c0                	test   %eax,%eax
f01061bb:	75 a4                	jne    f0106161 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061bd:	83 ec 04             	sub    $0x4,%esp
f01061c0:	68 97 81 10 f0       	push   $0xf0108197
f01061c5:	6a 67                	push   $0x67
f01061c7:	68 68 81 10 f0       	push   $0xf0108168
f01061cc:	e8 6f 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01061d1:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061d8:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01061df:	b8 00 00 00 00       	mov    $0x0,%eax
f01061e4:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01061e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061ea:	5b                   	pop    %ebx
f01061eb:	5e                   	pop    %esi
f01061ec:	5f                   	pop    %edi
f01061ed:	5d                   	pop    %ebp
f01061ee:	c3                   	ret    
f01061ef:	90                   	nop

f01061f0 <__udivdi3>:
f01061f0:	55                   	push   %ebp
f01061f1:	57                   	push   %edi
f01061f2:	56                   	push   %esi
f01061f3:	83 ec 10             	sub    $0x10,%esp
f01061f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f01061fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
f01061fe:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106202:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106206:	85 d2                	test   %edx,%edx
f0106208:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010620c:	89 34 24             	mov    %esi,(%esp)
f010620f:	89 c8                	mov    %ecx,%eax
f0106211:	75 35                	jne    f0106248 <__udivdi3+0x58>
f0106213:	39 f1                	cmp    %esi,%ecx
f0106215:	0f 87 bd 00 00 00    	ja     f01062d8 <__udivdi3+0xe8>
f010621b:	85 c9                	test   %ecx,%ecx
f010621d:	89 cd                	mov    %ecx,%ebp
f010621f:	75 0b                	jne    f010622c <__udivdi3+0x3c>
f0106221:	b8 01 00 00 00       	mov    $0x1,%eax
f0106226:	31 d2                	xor    %edx,%edx
f0106228:	f7 f1                	div    %ecx
f010622a:	89 c5                	mov    %eax,%ebp
f010622c:	89 f0                	mov    %esi,%eax
f010622e:	31 d2                	xor    %edx,%edx
f0106230:	f7 f5                	div    %ebp
f0106232:	89 c6                	mov    %eax,%esi
f0106234:	89 f8                	mov    %edi,%eax
f0106236:	f7 f5                	div    %ebp
f0106238:	89 f2                	mov    %esi,%edx
f010623a:	83 c4 10             	add    $0x10,%esp
f010623d:	5e                   	pop    %esi
f010623e:	5f                   	pop    %edi
f010623f:	5d                   	pop    %ebp
f0106240:	c3                   	ret    
f0106241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106248:	3b 14 24             	cmp    (%esp),%edx
f010624b:	77 7b                	ja     f01062c8 <__udivdi3+0xd8>
f010624d:	0f bd f2             	bsr    %edx,%esi
f0106250:	83 f6 1f             	xor    $0x1f,%esi
f0106253:	0f 84 97 00 00 00    	je     f01062f0 <__udivdi3+0x100>
f0106259:	bd 20 00 00 00       	mov    $0x20,%ebp
f010625e:	89 d7                	mov    %edx,%edi
f0106260:	89 f1                	mov    %esi,%ecx
f0106262:	29 f5                	sub    %esi,%ebp
f0106264:	d3 e7                	shl    %cl,%edi
f0106266:	89 c2                	mov    %eax,%edx
f0106268:	89 e9                	mov    %ebp,%ecx
f010626a:	d3 ea                	shr    %cl,%edx
f010626c:	89 f1                	mov    %esi,%ecx
f010626e:	09 fa                	or     %edi,%edx
f0106270:	8b 3c 24             	mov    (%esp),%edi
f0106273:	d3 e0                	shl    %cl,%eax
f0106275:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106279:	89 e9                	mov    %ebp,%ecx
f010627b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010627f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106283:	89 fa                	mov    %edi,%edx
f0106285:	d3 ea                	shr    %cl,%edx
f0106287:	89 f1                	mov    %esi,%ecx
f0106289:	d3 e7                	shl    %cl,%edi
f010628b:	89 e9                	mov    %ebp,%ecx
f010628d:	d3 e8                	shr    %cl,%eax
f010628f:	09 c7                	or     %eax,%edi
f0106291:	89 f8                	mov    %edi,%eax
f0106293:	f7 74 24 08          	divl   0x8(%esp)
f0106297:	89 d5                	mov    %edx,%ebp
f0106299:	89 c7                	mov    %eax,%edi
f010629b:	f7 64 24 0c          	mull   0xc(%esp)
f010629f:	39 d5                	cmp    %edx,%ebp
f01062a1:	89 14 24             	mov    %edx,(%esp)
f01062a4:	72 11                	jb     f01062b7 <__udivdi3+0xc7>
f01062a6:	8b 54 24 04          	mov    0x4(%esp),%edx
f01062aa:	89 f1                	mov    %esi,%ecx
f01062ac:	d3 e2                	shl    %cl,%edx
f01062ae:	39 c2                	cmp    %eax,%edx
f01062b0:	73 5e                	jae    f0106310 <__udivdi3+0x120>
f01062b2:	3b 2c 24             	cmp    (%esp),%ebp
f01062b5:	75 59                	jne    f0106310 <__udivdi3+0x120>
f01062b7:	8d 47 ff             	lea    -0x1(%edi),%eax
f01062ba:	31 f6                	xor    %esi,%esi
f01062bc:	89 f2                	mov    %esi,%edx
f01062be:	83 c4 10             	add    $0x10,%esp
f01062c1:	5e                   	pop    %esi
f01062c2:	5f                   	pop    %edi
f01062c3:	5d                   	pop    %ebp
f01062c4:	c3                   	ret    
f01062c5:	8d 76 00             	lea    0x0(%esi),%esi
f01062c8:	31 f6                	xor    %esi,%esi
f01062ca:	31 c0                	xor    %eax,%eax
f01062cc:	89 f2                	mov    %esi,%edx
f01062ce:	83 c4 10             	add    $0x10,%esp
f01062d1:	5e                   	pop    %esi
f01062d2:	5f                   	pop    %edi
f01062d3:	5d                   	pop    %ebp
f01062d4:	c3                   	ret    
f01062d5:	8d 76 00             	lea    0x0(%esi),%esi
f01062d8:	89 f2                	mov    %esi,%edx
f01062da:	31 f6                	xor    %esi,%esi
f01062dc:	89 f8                	mov    %edi,%eax
f01062de:	f7 f1                	div    %ecx
f01062e0:	89 f2                	mov    %esi,%edx
f01062e2:	83 c4 10             	add    $0x10,%esp
f01062e5:	5e                   	pop    %esi
f01062e6:	5f                   	pop    %edi
f01062e7:	5d                   	pop    %ebp
f01062e8:	c3                   	ret    
f01062e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01062f4:	76 0b                	jbe    f0106301 <__udivdi3+0x111>
f01062f6:	31 c0                	xor    %eax,%eax
f01062f8:	3b 14 24             	cmp    (%esp),%edx
f01062fb:	0f 83 37 ff ff ff    	jae    f0106238 <__udivdi3+0x48>
f0106301:	b8 01 00 00 00       	mov    $0x1,%eax
f0106306:	e9 2d ff ff ff       	jmp    f0106238 <__udivdi3+0x48>
f010630b:	90                   	nop
f010630c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106310:	89 f8                	mov    %edi,%eax
f0106312:	31 f6                	xor    %esi,%esi
f0106314:	e9 1f ff ff ff       	jmp    f0106238 <__udivdi3+0x48>
f0106319:	66 90                	xchg   %ax,%ax
f010631b:	66 90                	xchg   %ax,%ax
f010631d:	66 90                	xchg   %ax,%ax
f010631f:	90                   	nop

f0106320 <__umoddi3>:
f0106320:	55                   	push   %ebp
f0106321:	57                   	push   %edi
f0106322:	56                   	push   %esi
f0106323:	83 ec 20             	sub    $0x20,%esp
f0106326:	8b 44 24 34          	mov    0x34(%esp),%eax
f010632a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010632e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106332:	89 c6                	mov    %eax,%esi
f0106334:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106338:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010633c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0106340:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106344:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0106348:	89 74 24 18          	mov    %esi,0x18(%esp)
f010634c:	85 c0                	test   %eax,%eax
f010634e:	89 c2                	mov    %eax,%edx
f0106350:	75 1e                	jne    f0106370 <__umoddi3+0x50>
f0106352:	39 f7                	cmp    %esi,%edi
f0106354:	76 52                	jbe    f01063a8 <__umoddi3+0x88>
f0106356:	89 c8                	mov    %ecx,%eax
f0106358:	89 f2                	mov    %esi,%edx
f010635a:	f7 f7                	div    %edi
f010635c:	89 d0                	mov    %edx,%eax
f010635e:	31 d2                	xor    %edx,%edx
f0106360:	83 c4 20             	add    $0x20,%esp
f0106363:	5e                   	pop    %esi
f0106364:	5f                   	pop    %edi
f0106365:	5d                   	pop    %ebp
f0106366:	c3                   	ret    
f0106367:	89 f6                	mov    %esi,%esi
f0106369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106370:	39 f0                	cmp    %esi,%eax
f0106372:	77 5c                	ja     f01063d0 <__umoddi3+0xb0>
f0106374:	0f bd e8             	bsr    %eax,%ebp
f0106377:	83 f5 1f             	xor    $0x1f,%ebp
f010637a:	75 64                	jne    f01063e0 <__umoddi3+0xc0>
f010637c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0106380:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0106384:	0f 86 f6 00 00 00    	jbe    f0106480 <__umoddi3+0x160>
f010638a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010638e:	0f 82 ec 00 00 00    	jb     f0106480 <__umoddi3+0x160>
f0106394:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106398:	8b 54 24 18          	mov    0x18(%esp),%edx
f010639c:	83 c4 20             	add    $0x20,%esp
f010639f:	5e                   	pop    %esi
f01063a0:	5f                   	pop    %edi
f01063a1:	5d                   	pop    %ebp
f01063a2:	c3                   	ret    
f01063a3:	90                   	nop
f01063a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063a8:	85 ff                	test   %edi,%edi
f01063aa:	89 fd                	mov    %edi,%ebp
f01063ac:	75 0b                	jne    f01063b9 <__umoddi3+0x99>
f01063ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01063b3:	31 d2                	xor    %edx,%edx
f01063b5:	f7 f7                	div    %edi
f01063b7:	89 c5                	mov    %eax,%ebp
f01063b9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01063bd:	31 d2                	xor    %edx,%edx
f01063bf:	f7 f5                	div    %ebp
f01063c1:	89 c8                	mov    %ecx,%eax
f01063c3:	f7 f5                	div    %ebp
f01063c5:	eb 95                	jmp    f010635c <__umoddi3+0x3c>
f01063c7:	89 f6                	mov    %esi,%esi
f01063c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01063d0:	89 c8                	mov    %ecx,%eax
f01063d2:	89 f2                	mov    %esi,%edx
f01063d4:	83 c4 20             	add    $0x20,%esp
f01063d7:	5e                   	pop    %esi
f01063d8:	5f                   	pop    %edi
f01063d9:	5d                   	pop    %ebp
f01063da:	c3                   	ret    
f01063db:	90                   	nop
f01063dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01063e5:	89 e9                	mov    %ebp,%ecx
f01063e7:	29 e8                	sub    %ebp,%eax
f01063e9:	d3 e2                	shl    %cl,%edx
f01063eb:	89 c7                	mov    %eax,%edi
f01063ed:	89 44 24 18          	mov    %eax,0x18(%esp)
f01063f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01063f5:	89 f9                	mov    %edi,%ecx
f01063f7:	d3 e8                	shr    %cl,%eax
f01063f9:	89 c1                	mov    %eax,%ecx
f01063fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01063ff:	09 d1                	or     %edx,%ecx
f0106401:	89 fa                	mov    %edi,%edx
f0106403:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106407:	89 e9                	mov    %ebp,%ecx
f0106409:	d3 e0                	shl    %cl,%eax
f010640b:	89 f9                	mov    %edi,%ecx
f010640d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106411:	89 f0                	mov    %esi,%eax
f0106413:	d3 e8                	shr    %cl,%eax
f0106415:	89 e9                	mov    %ebp,%ecx
f0106417:	89 c7                	mov    %eax,%edi
f0106419:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010641d:	d3 e6                	shl    %cl,%esi
f010641f:	89 d1                	mov    %edx,%ecx
f0106421:	89 fa                	mov    %edi,%edx
f0106423:	d3 e8                	shr    %cl,%eax
f0106425:	89 e9                	mov    %ebp,%ecx
f0106427:	09 f0                	or     %esi,%eax
f0106429:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010642d:	f7 74 24 10          	divl   0x10(%esp)
f0106431:	d3 e6                	shl    %cl,%esi
f0106433:	89 d1                	mov    %edx,%ecx
f0106435:	f7 64 24 0c          	mull   0xc(%esp)
f0106439:	39 d1                	cmp    %edx,%ecx
f010643b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010643f:	89 d7                	mov    %edx,%edi
f0106441:	89 c6                	mov    %eax,%esi
f0106443:	72 0a                	jb     f010644f <__umoddi3+0x12f>
f0106445:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0106449:	73 10                	jae    f010645b <__umoddi3+0x13b>
f010644b:	39 d1                	cmp    %edx,%ecx
f010644d:	75 0c                	jne    f010645b <__umoddi3+0x13b>
f010644f:	89 d7                	mov    %edx,%edi
f0106451:	89 c6                	mov    %eax,%esi
f0106453:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0106457:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010645b:	89 ca                	mov    %ecx,%edx
f010645d:	89 e9                	mov    %ebp,%ecx
f010645f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106463:	29 f0                	sub    %esi,%eax
f0106465:	19 fa                	sbb    %edi,%edx
f0106467:	d3 e8                	shr    %cl,%eax
f0106469:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010646e:	89 d7                	mov    %edx,%edi
f0106470:	d3 e7                	shl    %cl,%edi
f0106472:	89 e9                	mov    %ebp,%ecx
f0106474:	09 f8                	or     %edi,%eax
f0106476:	d3 ea                	shr    %cl,%edx
f0106478:	83 c4 20             	add    $0x20,%esp
f010647b:	5e                   	pop    %esi
f010647c:	5f                   	pop    %edi
f010647d:	5d                   	pop    %ebp
f010647e:	c3                   	ret    
f010647f:	90                   	nop
f0106480:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106484:	29 f9                	sub    %edi,%ecx
f0106486:	19 c6                	sbb    %eax,%esi
f0106488:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010648c:	89 74 24 18          	mov    %esi,0x18(%esp)
f0106490:	e9 ff fe ff ff       	jmp    f0106394 <__umoddi3+0x74>
