
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

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
f0100048:	83 3d c0 fe 22 f0 00 	cmpl   $0x0,0xf022fec0
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 c0 fe 22 f0    	mov    %esi,0xf022fec0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 3a 5d 00 00       	call   f0105d9b <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 64 10 f0       	push   $0xf0106440
f010006d:	e8 db 36 00 00       	call   f010374d <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ab 36 00 00       	call   f0103727 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 33 6d 10 f0 	movl   $0xf0106d33,(%esp)
f0100083:	e8 c5 36 00 00       	call   f010374d <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 dd 08 00 00       	call   f0100972 <monitor>
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
f01000a1:	b8 08 10 27 f0       	mov    $0xf0271008,%eax
f01000a6:	2d 68 ef 22 f0       	sub    $0xf022ef68,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 68 ef 22 f0       	push   $0xf022ef68
f01000b3:	e8 c0 56 00 00       	call   f0105778 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 72 05 00 00       	call   f010062f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ac 64 10 f0       	push   $0xf01064ac
f01000ca:	e8 7e 36 00 00       	call   f010374d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 8f 12 00 00       	call   f0101363 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 ca 2e 00 00       	call   f0102fa3 <env_init>
	trap_init();
f01000d9:	e8 43 37 00 00       	call   f0103821 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 b1 59 00 00       	call   f0105a94 <mp_init>
	lapic_init();
f01000e3:	e8 ce 5c 00 00       	call   f0105db6 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 9c 35 00 00       	call   f0103689 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 00 04 12 f0 	movl   $0xf0120400,(%esp)
f01000f4:	e8 0d 5f 00 00       	call   f0106006 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d c8 fe 22 f0 07 	cmpl   $0x7,0xf022fec8
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 64 64 10 f0       	push   $0xf0106464
f010010f:	6a 55                	push   $0x55
f0100111:	68 c7 64 10 f0       	push   $0xf01064c7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 fa 59 10 f0       	mov    $0xf01059fa,%eax
f0100123:	2d 80 59 10 f0       	sub    $0xf0105980,%eax
f0100128:	50                   	push   %eax
f0100129:	68 80 59 10 f0       	push   $0xf0105980
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 8d 56 00 00       	call   f01057c5 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 40 00 23 f0       	mov    $0xf0230040,%ebx
f0100140:	eb 4e                	jmp    f0100190 <i386_init+0xf6>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 54 5c 00 00       	call   f0105d9b <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 40 00 23 f0       	add    $0xf0230040,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 3a                	je     f010018d <i386_init+0xf3>
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 40 00 23 f0       	sub    $0xf0230040,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	8d 80 00 90 23 f0    	lea    -0xfdc7000(%eax),%eax
f010016c:	a3 c4 fe 22 f0       	mov    %eax,0xf022fec4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100171:	83 ec 08             	sub    $0x8,%esp
f0100174:	68 00 70 00 00       	push   $0x7000
f0100179:	0f b6 03             	movzbl (%ebx),%eax
f010017c:	50                   	push   %eax
f010017d:	e8 82 5d 00 00       	call   f0105f04 <lapic_startap>
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
f0100190:	6b 05 e4 03 23 f0 74 	imul   $0x74,0xf02303e4,%eax
f0100197:	05 40 00 23 f0       	add    $0xf0230040,%eax
f010019c:	39 c3                	cmp    %eax,%ebx
f010019e:	72 a2                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a0:	83 ec 08             	sub    $0x8,%esp
f01001a3:	6a 00                	push   $0x0
f01001a5:	68 d4 54 22 f0       	push   $0xf02254d4
f01001aa:	e8 c1 2f 00 00       	call   f0103170 <env_create>
         
        
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001af:	e8 d0 43 00 00       	call   f0104584 <sched_yield>

f01001b4 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b4:	55                   	push   %ebp
f01001b5:	89 e5                	mov    %esp,%ebp
f01001b7:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001ba:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c4:	77 12                	ja     f01001d8 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c6:	50                   	push   %eax
f01001c7:	68 88 64 10 f0       	push   $0xf0106488
f01001cc:	6a 6c                	push   $0x6c
f01001ce:	68 c7 64 10 f0       	push   $0xf01064c7
f01001d3:	e8 68 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001d8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001dd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e0:	e8 b6 5b 00 00       	call   f0105d9b <cpunum>
f01001e5:	83 ec 08             	sub    $0x8,%esp
f01001e8:	50                   	push   %eax
f01001e9:	68 d3 64 10 f0       	push   $0xf01064d3
f01001ee:	e8 5a 35 00 00       	call   f010374d <cprintf>

	lapic_init();
f01001f3:	e8 be 5b 00 00       	call   f0105db6 <lapic_init>
	env_init_percpu();
f01001f8:	e8 7c 2d 00 00       	call   f0102f79 <env_init_percpu>
	trap_init_percpu();
f01001fd:	e8 5f 35 00 00       	call   f0103761 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100202:	e8 94 5b 00 00       	call   f0105d9b <cpunum>
f0100207:	6b d0 74             	imul   $0x74,%eax,%edx
f010020a:	81 c2 40 00 23 f0    	add    $0xf0230040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100210:	b8 01 00 00 00       	mov    $0x1,%eax
f0100215:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100219:	c7 04 24 00 04 12 f0 	movl   $0xf0120400,(%esp)
f0100220:	e8 e1 5d 00 00       	call   f0106006 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100225:	e8 5a 43 00 00       	call   f0104584 <sched_yield>

f010022a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	53                   	push   %ebx
f010022e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100231:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100234:	ff 75 0c             	pushl  0xc(%ebp)
f0100237:	ff 75 08             	pushl  0x8(%ebp)
f010023a:	68 e9 64 10 f0       	push   $0xf01064e9
f010023f:	e8 09 35 00 00       	call   f010374d <cprintf>
	vcprintf(fmt, ap);
f0100244:	83 c4 08             	add    $0x8,%esp
f0100247:	53                   	push   %ebx
f0100248:	ff 75 10             	pushl  0x10(%ebp)
f010024b:	e8 d7 34 00 00       	call   f0103727 <vcprintf>
	cprintf("\n");
f0100250:	c7 04 24 33 6d 10 f0 	movl   $0xf0106d33,(%esp)
f0100257:	e8 f1 34 00 00       	call   f010374d <cprintf>
	va_end(ap);
f010025c:	83 c4 10             	add    $0x10,%esp
}
f010025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100262:	c9                   	leave  
f0100263:	c3                   	ret    

f0100264 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100267:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026d:	a8 01                	test   $0x1,%al
f010026f:	74 08                	je     f0100279 <serial_proc_data+0x15>
f0100271:	b2 f8                	mov    $0xf8,%dl
f0100273:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100274:	0f b6 c0             	movzbl %al,%eax
f0100277:	eb 05                	jmp    f010027e <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010027e:	5d                   	pop    %ebp
f010027f:	c3                   	ret    

f0100280 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 04             	sub    $0x4,%esp
f0100287:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100289:	eb 2a                	jmp    f01002b5 <cons_intr+0x35>
		if (c == 0)
f010028b:	85 d2                	test   %edx,%edx
f010028d:	74 26                	je     f01002b5 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010028f:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f0100294:	8d 48 01             	lea    0x1(%eax),%ecx
f0100297:	89 0d 44 f2 22 f0    	mov    %ecx,0xf022f244
f010029d:	88 90 40 f0 22 f0    	mov    %dl,-0xfdd0fc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002a3:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002a9:	75 0a                	jne    f01002b5 <cons_intr+0x35>
			cons.wpos = 0;
f01002ab:	c7 05 44 f2 22 f0 00 	movl   $0x0,0xf022f244
f01002b2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b5:	ff d3                	call   *%ebx
f01002b7:	89 c2                	mov    %eax,%edx
f01002b9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bc:	75 cd                	jne    f010028b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002be:	83 c4 04             	add    $0x4,%esp
f01002c1:	5b                   	pop    %ebx
f01002c2:	5d                   	pop    %ebp
f01002c3:	c3                   	ret    

f01002c4 <kbd_proc_data>:
f01002c4:	ba 64 00 00 00       	mov    $0x64,%edx
f01002c9:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002ca:	a8 01                	test   $0x1,%al
f01002cc:	0f 84 f0 00 00 00    	je     f01003c2 <kbd_proc_data+0xfe>
f01002d2:	b2 60                	mov    $0x60,%dl
f01002d4:	ec                   	in     (%dx),%al
f01002d5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002d7:	3c e0                	cmp    $0xe0,%al
f01002d9:	75 0d                	jne    f01002e8 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01002db:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002e2:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e7:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002e8:	55                   	push   %ebp
f01002e9:	89 e5                	mov    %esp,%ebp
f01002eb:	53                   	push   %ebx
f01002ec:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002ef:	84 c0                	test   %al,%al
f01002f1:	79 36                	jns    f0100329 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f3:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f01002f9:	89 cb                	mov    %ecx,%ebx
f01002fb:	83 e3 40             	and    $0x40,%ebx
f01002fe:	83 e0 7f             	and    $0x7f,%eax
f0100301:	85 db                	test   %ebx,%ebx
f0100303:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100306:	0f b6 d2             	movzbl %dl,%edx
f0100309:	0f b6 82 80 66 10 f0 	movzbl -0xfef9980(%edx),%eax
f0100310:	83 c8 40             	or     $0x40,%eax
f0100313:	0f b6 c0             	movzbl %al,%eax
f0100316:	f7 d0                	not    %eax
f0100318:	21 c8                	and    %ecx,%eax
f010031a:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f010031f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100324:	e9 a1 00 00 00       	jmp    f01003ca <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100329:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f010032f:	f6 c1 40             	test   $0x40,%cl
f0100332:	74 0e                	je     f0100342 <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100334:	83 c8 80             	or     $0xffffff80,%eax
f0100337:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100339:	83 e1 bf             	and    $0xffffffbf,%ecx
f010033c:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f0100342:	0f b6 c2             	movzbl %dl,%eax
f0100345:	0f b6 90 80 66 10 f0 	movzbl -0xfef9980(%eax),%edx
f010034c:	0b 15 00 f0 22 f0    	or     0xf022f000,%edx
	shift ^= togglecode[data];
f0100352:	0f b6 88 80 65 10 f0 	movzbl -0xfef9a80(%eax),%ecx
f0100359:	31 ca                	xor    %ecx,%edx
f010035b:	89 15 00 f0 22 f0    	mov    %edx,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100361:	89 d1                	mov    %edx,%ecx
f0100363:	83 e1 03             	and    $0x3,%ecx
f0100366:	8b 0c 8d 40 65 10 f0 	mov    -0xfef9ac0(,%ecx,4),%ecx
f010036d:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100371:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100374:	f6 c2 08             	test   $0x8,%dl
f0100377:	74 1b                	je     f0100394 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100379:	89 d8                	mov    %ebx,%eax
f010037b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010037e:	83 f9 19             	cmp    $0x19,%ecx
f0100381:	77 05                	ja     f0100388 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100383:	83 eb 20             	sub    $0x20,%ebx
f0100386:	eb 0c                	jmp    f0100394 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100388:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010038b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010038e:	83 f8 19             	cmp    $0x19,%eax
f0100391:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100394:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010039a:	75 2c                	jne    f01003c8 <kbd_proc_data+0x104>
f010039c:	f7 d2                	not    %edx
f010039e:	f6 c2 06             	test   $0x6,%dl
f01003a1:	75 25                	jne    f01003c8 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a3:	83 ec 0c             	sub    $0xc,%esp
f01003a6:	68 03 65 10 f0       	push   $0xf0106503
f01003ab:	e8 9d 33 00 00       	call   f010374d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b0:	ba 92 00 00 00       	mov    $0x92,%edx
f01003b5:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ba:	ee                   	out    %al,(%dx)
f01003bb:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003be:	89 d8                	mov    %ebx,%eax
f01003c0:	eb 08                	jmp    f01003ca <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003c7:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c8:	89 d8                	mov    %ebx,%eax
}
f01003ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003cd:	c9                   	leave  
f01003ce:	c3                   	ret    

f01003cf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003cf:	55                   	push   %ebp
f01003d0:	89 e5                	mov    %esp,%ebp
f01003d2:	57                   	push   %edi
f01003d3:	56                   	push   %esi
f01003d4:	53                   	push   %ebx
f01003d5:	83 ec 1c             	sub    $0x1c,%esp
f01003d8:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003df:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e9:	eb 09                	jmp    f01003f4 <cons_putc+0x25>
f01003eb:	89 ca                	mov    %ecx,%edx
f01003ed:	ec                   	in     (%dx),%al
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f1:	83 c3 01             	add    $0x1,%ebx
f01003f4:	89 f2                	mov    %esi,%edx
f01003f6:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f7:	a8 20                	test   $0x20,%al
f01003f9:	75 08                	jne    f0100403 <cons_putc+0x34>
f01003fb:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100401:	7e e8                	jle    f01003eb <cons_putc+0x1c>
f0100403:	89 f8                	mov    %edi,%eax
f0100405:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100408:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040d:	89 f8                	mov    %edi,%eax
f010040f:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100410:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100415:	be 79 03 00 00       	mov    $0x379,%esi
f010041a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041f:	eb 09                	jmp    f010042a <cons_putc+0x5b>
f0100421:	89 ca                	mov    %ecx,%edx
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	ec                   	in     (%dx),%al
f0100426:	ec                   	in     (%dx),%al
f0100427:	83 c3 01             	add    $0x1,%ebx
f010042a:	89 f2                	mov    %esi,%edx
f010042c:	ec                   	in     (%dx),%al
f010042d:	84 c0                	test   %al,%al
f010042f:	78 08                	js     f0100439 <cons_putc+0x6a>
f0100431:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100437:	7e e8                	jle    f0100421 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100439:	ba 78 03 00 00       	mov    $0x378,%edx
f010043e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100442:	ee                   	out    %al,(%dx)
f0100443:	b2 7a                	mov    $0x7a,%dl
f0100445:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044a:	ee                   	out    %al,(%dx)
f010044b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100450:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100451:	89 fa                	mov    %edi,%edx
f0100453:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100459:	89 f8                	mov    %edi,%eax
f010045b:	80 cc 07             	or     $0x7,%ah
f010045e:	85 d2                	test   %edx,%edx
f0100460:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100463:	89 f8                	mov    %edi,%eax
f0100465:	0f b6 c0             	movzbl %al,%eax
f0100468:	83 f8 09             	cmp    $0x9,%eax
f010046b:	74 74                	je     f01004e1 <cons_putc+0x112>
f010046d:	83 f8 09             	cmp    $0x9,%eax
f0100470:	7f 0a                	jg     f010047c <cons_putc+0xad>
f0100472:	83 f8 08             	cmp    $0x8,%eax
f0100475:	74 14                	je     f010048b <cons_putc+0xbc>
f0100477:	e9 99 00 00 00       	jmp    f0100515 <cons_putc+0x146>
f010047c:	83 f8 0a             	cmp    $0xa,%eax
f010047f:	74 3a                	je     f01004bb <cons_putc+0xec>
f0100481:	83 f8 0d             	cmp    $0xd,%eax
f0100484:	74 3d                	je     f01004c3 <cons_putc+0xf4>
f0100486:	e9 8a 00 00 00       	jmp    f0100515 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f010048b:	0f b7 05 48 f2 22 f0 	movzwl 0xf022f248,%eax
f0100492:	66 85 c0             	test   %ax,%ax
f0100495:	0f 84 e6 00 00 00    	je     f0100581 <cons_putc+0x1b2>
			crt_pos--;
f010049b:	83 e8 01             	sub    $0x1,%eax
f010049e:	66 a3 48 f2 22 f0    	mov    %ax,0xf022f248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a4:	0f b7 c0             	movzwl %ax,%eax
f01004a7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ac:	83 cf 20             	or     $0x20,%edi
f01004af:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f01004b5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b9:	eb 78                	jmp    f0100533 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004bb:	66 83 05 48 f2 22 f0 	addw   $0x50,0xf022f248
f01004c2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004c3:	0f b7 05 48 f2 22 f0 	movzwl 0xf022f248,%eax
f01004ca:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d0:	c1 e8 16             	shr    $0x16,%eax
f01004d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d6:	c1 e0 04             	shl    $0x4,%eax
f01004d9:	66 a3 48 f2 22 f0    	mov    %ax,0xf022f248
f01004df:	eb 52                	jmp    f0100533 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01004e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e6:	e8 e4 fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f01004eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f0:	e8 da fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f01004f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fa:	e8 d0 fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f01004ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0100504:	e8 c6 fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f0100509:	b8 20 00 00 00       	mov    $0x20,%eax
f010050e:	e8 bc fe ff ff       	call   f01003cf <cons_putc>
f0100513:	eb 1e                	jmp    f0100533 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 05 48 f2 22 f0 	movzwl 0xf022f248,%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 15 48 f2 22 f0 	mov    %dx,0xf022f248
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100533:	66 81 3d 48 f2 22 f0 	cmpw   $0x7cf,0xf022f248
f010053a:	cf 07 
f010053c:	76 43                	jbe    f0100581 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010053e:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f0100543:	83 ec 04             	sub    $0x4,%esp
f0100546:	68 00 0f 00 00       	push   $0xf00
f010054b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100551:	52                   	push   %edx
f0100552:	50                   	push   %eax
f0100553:	e8 6d 52 00 00       	call   f01057c5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100558:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f010055e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100564:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010056a:	83 c4 10             	add    $0x10,%esp
f010056d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100572:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100575:	39 d0                	cmp    %edx,%eax
f0100577:	75 f4                	jne    f010056d <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100579:	66 83 2d 48 f2 22 f0 	subw   $0x50,0xf022f248
f0100580:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100581:	8b 0d 50 f2 22 f0    	mov    0xf022f250,%ecx
f0100587:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058c:	89 ca                	mov    %ecx,%edx
f010058e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010058f:	0f b7 1d 48 f2 22 f0 	movzwl 0xf022f248,%ebx
f0100596:	8d 71 01             	lea    0x1(%ecx),%esi
f0100599:	89 d8                	mov    %ebx,%eax
f010059b:	66 c1 e8 08          	shr    $0x8,%ax
f010059f:	89 f2                	mov    %esi,%edx
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a7:	89 ca                	mov    %ecx,%edx
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	89 d8                	mov    %ebx,%eax
f01005ac:	89 f2                	mov    %esi,%edx
f01005ae:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b2:	5b                   	pop    %ebx
f01005b3:	5e                   	pop    %esi
f01005b4:	5f                   	pop    %edi
f01005b5:	5d                   	pop    %ebp
f01005b6:	c3                   	ret    

f01005b7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b7:	80 3d 54 f2 22 f0 00 	cmpb   $0x0,0xf022f254
f01005be:	74 11                	je     f01005d1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c0:	55                   	push   %ebp
f01005c1:	89 e5                	mov    %esp,%ebp
f01005c3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005c6:	b8 64 02 10 f0       	mov    $0xf0100264,%eax
f01005cb:	e8 b0 fc ff ff       	call   f0100280 <cons_intr>
}
f01005d0:	c9                   	leave  
f01005d1:	f3 c3                	repz ret 

f01005d3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005d3:	55                   	push   %ebp
f01005d4:	89 e5                	mov    %esp,%ebp
f01005d6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005d9:	b8 c4 02 10 f0       	mov    $0xf01002c4,%eax
f01005de:	e8 9d fc ff ff       	call   f0100280 <cons_intr>
}
f01005e3:	c9                   	leave  
f01005e4:	c3                   	ret    

f01005e5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005e5:	55                   	push   %ebp
f01005e6:	89 e5                	mov    %esp,%ebp
f01005e8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005eb:	e8 c7 ff ff ff       	call   f01005b7 <serial_intr>
	kbd_intr();
f01005f0:	e8 de ff ff ff       	call   f01005d3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005f5:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01005fa:	3b 05 44 f2 22 f0    	cmp    0xf022f244,%eax
f0100600:	74 26                	je     f0100628 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100602:	8d 50 01             	lea    0x1(%eax),%edx
f0100605:	89 15 40 f2 22 f0    	mov    %edx,0xf022f240
f010060b:	0f b6 88 40 f0 22 f0 	movzbl -0xfdd0fc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100612:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100614:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010061a:	75 11                	jne    f010062d <cons_getc+0x48>
			cons.rpos = 0;
f010061c:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0100623:	00 00 00 
f0100626:	eb 05                	jmp    f010062d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100628:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010062d:	c9                   	leave  
f010062e:	c3                   	ret    

f010062f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010062f:	55                   	push   %ebp
f0100630:	89 e5                	mov    %esp,%ebp
f0100632:	57                   	push   %edi
f0100633:	56                   	push   %esi
f0100634:	53                   	push   %ebx
f0100635:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100638:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010063f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100646:	5a a5 
	if (*cp != 0xA55A) {
f0100648:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010064f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100653:	74 11                	je     f0100666 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100655:	c7 05 50 f2 22 f0 b4 	movl   $0x3b4,0xf022f250
f010065c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010065f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100664:	eb 16                	jmp    f010067c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100666:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010066d:	c7 05 50 f2 22 f0 d4 	movl   $0x3d4,0xf022f250
f0100674:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100677:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010067c:	8b 3d 50 f2 22 f0    	mov    0xf022f250,%edi
f0100682:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100687:	89 fa                	mov    %edi,%edx
f0100689:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068a:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068d:	89 ca                	mov    %ecx,%edx
f010068f:	ec                   	in     (%dx),%al
f0100690:	0f b6 c0             	movzbl %al,%eax
f0100693:	c1 e0 08             	shl    $0x8,%eax
f0100696:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100698:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 ca                	mov    %ecx,%edx
f01006a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a3:	89 35 4c f2 22 f0    	mov    %esi,0xf022f24c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006a9:	0f b6 c8             	movzbl %al,%ecx
f01006ac:	89 d8                	mov    %ebx,%eax
f01006ae:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006b0:	66 a3 48 f2 22 f0    	mov    %ax,0xf022f248

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b6:	e8 18 ff ff ff       	call   f01005d3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006bb:	83 ec 0c             	sub    $0xc,%esp
f01006be:	0f b7 05 e8 03 12 f0 	movzwl 0xf01203e8,%eax
f01006c5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ca:	50                   	push   %eax
f01006cb:	e8 44 2f 00 00       	call   f0103614 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	b2 fb                	mov    $0xfb,%dl
f01006df:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e4:	ee                   	out    %al,(%dx)
f01006e5:	be f8 03 00 00       	mov    $0x3f8,%esi
f01006ea:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
f01006f2:	b2 f9                	mov    $0xf9,%dl
f01006f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f9:	ee                   	out    %al,(%dx)
f01006fa:	b2 fb                	mov    $0xfb,%dl
f01006fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0100701:	ee                   	out    %al,(%dx)
f0100702:	b2 fc                	mov    $0xfc,%dl
f0100704:	b8 00 00 00 00       	mov    $0x0,%eax
f0100709:	ee                   	out    %al,(%dx)
f010070a:	b2 f9                	mov    $0xf9,%dl
f010070c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100711:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100712:	b2 fd                	mov    $0xfd,%dl
f0100714:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100715:	83 c4 10             	add    $0x10,%esp
f0100718:	3c ff                	cmp    $0xff,%al
f010071a:	0f 95 c1             	setne  %cl
f010071d:	88 0d 54 f2 22 f0    	mov    %cl,0xf022f254
f0100723:	89 da                	mov    %ebx,%edx
f0100725:	ec                   	in     (%dx),%al
f0100726:	89 f2                	mov    %esi,%edx
f0100728:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100729:	84 c9                	test   %cl,%cl
f010072b:	75 10                	jne    f010073d <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
f010072d:	83 ec 0c             	sub    $0xc,%esp
f0100730:	68 0f 65 10 f0       	push   $0xf010650f
f0100735:	e8 13 30 00 00       	call   f010374d <cprintf>
f010073a:	83 c4 10             	add    $0x10,%esp
}
f010073d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100740:	5b                   	pop    %ebx
f0100741:	5e                   	pop    %esi
f0100742:	5f                   	pop    %edi
f0100743:	5d                   	pop    %ebp
f0100744:	c3                   	ret    

f0100745 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010074b:	8b 45 08             	mov    0x8(%ebp),%eax
f010074e:	e8 7c fc ff ff       	call   f01003cf <cons_putc>
}
f0100753:	c9                   	leave  
f0100754:	c3                   	ret    

f0100755 <getchar>:

int
getchar(void)
{
f0100755:	55                   	push   %ebp
f0100756:	89 e5                	mov    %esp,%ebp
f0100758:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010075b:	e8 85 fe ff ff       	call   f01005e5 <cons_getc>
f0100760:	85 c0                	test   %eax,%eax
f0100762:	74 f7                	je     f010075b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <iscons>:

int
iscons(int fdnum)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100769:	b8 01 00 00 00       	mov    $0x1,%eax
f010076e:	5d                   	pop    %ebp
f010076f:	c3                   	ret    

f0100770 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100770:	55                   	push   %ebp
f0100771:	89 e5                	mov    %esp,%ebp
f0100773:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100776:	68 80 67 10 f0       	push   $0xf0106780
f010077b:	68 9e 67 10 f0       	push   $0xf010679e
f0100780:	68 a3 67 10 f0       	push   $0xf01067a3
f0100785:	e8 c3 2f 00 00       	call   f010374d <cprintf>
f010078a:	83 c4 0c             	add    $0xc,%esp
f010078d:	68 50 68 10 f0       	push   $0xf0106850
f0100792:	68 ac 67 10 f0       	push   $0xf01067ac
f0100797:	68 a3 67 10 f0       	push   $0xf01067a3
f010079c:	e8 ac 2f 00 00       	call   f010374d <cprintf>
f01007a1:	83 c4 0c             	add    $0xc,%esp
f01007a4:	68 b5 67 10 f0       	push   $0xf01067b5
f01007a9:	68 c8 67 10 f0       	push   $0xf01067c8
f01007ae:	68 a3 67 10 f0       	push   $0xf01067a3
f01007b3:	e8 95 2f 00 00       	call   f010374d <cprintf>
	return 0;
}
f01007b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bd:	c9                   	leave  
f01007be:	c3                   	ret    

f01007bf <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bf:	55                   	push   %ebp
f01007c0:	89 e5                	mov    %esp,%ebp
f01007c2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c5:	68 d2 67 10 f0       	push   $0xf01067d2
f01007ca:	e8 7e 2f 00 00       	call   f010374d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007cf:	83 c4 08             	add    $0x8,%esp
f01007d2:	68 0c 00 10 00       	push   $0x10000c
f01007d7:	68 78 68 10 f0       	push   $0xf0106878
f01007dc:	e8 6c 2f 00 00       	call   f010374d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e1:	83 c4 0c             	add    $0xc,%esp
f01007e4:	68 0c 00 10 00       	push   $0x10000c
f01007e9:	68 0c 00 10 f0       	push   $0xf010000c
f01007ee:	68 a0 68 10 f0       	push   $0xf01068a0
f01007f3:	e8 55 2f 00 00       	call   f010374d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f8:	83 c4 0c             	add    $0xc,%esp
f01007fb:	68 35 64 10 00       	push   $0x106435
f0100800:	68 35 64 10 f0       	push   $0xf0106435
f0100805:	68 c4 68 10 f0       	push   $0xf01068c4
f010080a:	e8 3e 2f 00 00       	call   f010374d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	68 68 ef 22 00       	push   $0x22ef68
f0100817:	68 68 ef 22 f0       	push   $0xf022ef68
f010081c:	68 e8 68 10 f0       	push   $0xf01068e8
f0100821:	e8 27 2f 00 00       	call   f010374d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100826:	83 c4 0c             	add    $0xc,%esp
f0100829:	68 08 10 27 00       	push   $0x271008
f010082e:	68 08 10 27 f0       	push   $0xf0271008
f0100833:	68 0c 69 10 f0       	push   $0xf010690c
f0100838:	e8 10 2f 00 00       	call   f010374d <cprintf>
f010083d:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100842:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100847:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010084a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100855:	85 c0                	test   %eax,%eax
f0100857:	0f 48 c2             	cmovs  %edx,%eax
f010085a:	c1 f8 0a             	sar    $0xa,%eax
f010085d:	50                   	push   %eax
f010085e:	68 30 69 10 f0       	push   $0xf0106930
f0100863:	e8 e5 2e 00 00       	call   f010374d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100868:	b8 00 00 00 00       	mov    $0x0,%eax
f010086d:	c9                   	leave  
f010086e:	c3                   	ret    

f010086f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010086f:	55                   	push   %ebp
f0100870:	89 e5                	mov    %esp,%ebp
f0100872:	57                   	push   %edi
f0100873:	56                   	push   %esi
f0100874:	53                   	push   %ebx
f0100875:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010087b:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f010087d:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f010087f:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f0100882:	8b 50 08             	mov    0x8(%eax),%edx
f0100885:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f0100887:	8b 48 0c             	mov    0xc(%eax),%ecx
f010088a:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f0100890:	8b 50 10             	mov    0x10(%eax),%edx
f0100893:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f0100899:	8b 48 14             	mov    0x14(%eax),%ecx
f010089c:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f01008a2:	8b 40 18             	mov    0x18(%eax),%eax
f01008a5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f01008ab:	68 eb 67 10 f0       	push   $0xf01067eb
f01008b0:	e8 98 2e 00 00       	call   f010374d <cprintf>
        while(ebp != 0) {
f01008b5:	83 c4 10             	add    $0x10,%esp
f01008b8:	89 f8                	mov    %edi,%eax
f01008ba:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f01008c0:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f01008c6:	e9 92 00 00 00       	jmp    f010095d <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f01008cb:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f01008d1:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f01008d7:	51                   	push   %ecx
f01008d8:	52                   	push   %edx
f01008d9:	50                   	push   %eax
f01008da:	56                   	push   %esi
f01008db:	53                   	push   %ebx
f01008dc:	68 5c 69 10 f0       	push   $0xf010695c
f01008e1:	e8 67 2e 00 00       	call   f010374d <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f01008e6:	83 c4 18             	add    $0x18,%esp
f01008e9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f01008ef:	50                   	push   %eax
f01008f0:	56                   	push   %esi
f01008f1:	e8 13 44 00 00       	call   f0104d09 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f01008f6:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f01008fc:	68 56 6a 10 f0       	push   $0xf0106a56
f0100901:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f0100907:	83 c0 01             	add    $0x1,%eax
f010090a:	50                   	push   %eax
f010090b:	8d 45 84             	lea    -0x7c(%ebp),%eax
f010090e:	50                   	push   %eax
f010090f:	e8 f3 4b 00 00       	call   f0105507 <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f0100914:	83 c4 14             	add    $0x14,%esp
f0100917:	89 f0                	mov    %esi,%eax
f0100919:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f010091f:	50                   	push   %eax
f0100920:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100923:	50                   	push   %eax
f0100924:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f010092a:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f0100930:	68 fd 67 10 f0       	push   $0xf01067fd
f0100935:	e8 13 2e 00 00       	call   f010374d <cprintf>
             ebp = (uint32_t *)ebp[0];
f010093a:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f010093c:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f010093f:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f0100942:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f0100945:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f0100948:	8b 7b 14             	mov    0x14(%ebx),%edi
f010094b:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f0100951:	8b 7b 18             	mov    0x18(%ebx),%edi
f0100954:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f010095a:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f010095d:	85 db                	test   %ebx,%ebx
f010095f:	0f 85 66 ff ff ff    	jne    f01008cb <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f0100965:	b8 00 00 00 00       	mov    $0x0,%eax
f010096a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010096d:	5b                   	pop    %ebx
f010096e:	5e                   	pop    %esi
f010096f:	5f                   	pop    %edi
f0100970:	5d                   	pop    %ebp
f0100971:	c3                   	ret    

f0100972 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100972:	55                   	push   %ebp
f0100973:	89 e5                	mov    %esp,%ebp
f0100975:	57                   	push   %edi
f0100976:	56                   	push   %esi
f0100977:	53                   	push   %ebx
f0100978:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010097b:	68 94 69 10 f0       	push   $0xf0106994
f0100980:	e8 c8 2d 00 00       	call   f010374d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100985:	c7 04 24 b8 69 10 f0 	movl   $0xf01069b8,(%esp)
f010098c:	e8 bc 2d 00 00       	call   f010374d <cprintf>

	if (tf != NULL)
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100998:	74 0e                	je     f01009a8 <monitor+0x36>
		print_trapframe(tf);
f010099a:	83 ec 0c             	sub    $0xc,%esp
f010099d:	ff 75 08             	pushl  0x8(%ebp)
f01009a0:	e8 23 35 00 00       	call   f0103ec8 <print_trapframe>
f01009a5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a8:	83 ec 0c             	sub    $0xc,%esp
f01009ab:	68 14 68 10 f0       	push   $0xf0106814
f01009b0:	e8 6c 4b 00 00       	call   f0105521 <readline>
f01009b5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	74 ea                	je     f01009a8 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009be:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009c5:	be 00 00 00 00       	mov    $0x0,%esi
f01009ca:	eb 0a                	jmp    f01009d6 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009cc:	c6 03 00             	movb   $0x0,(%ebx)
f01009cf:	89 f7                	mov    %esi,%edi
f01009d1:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009d4:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009d6:	0f b6 03             	movzbl (%ebx),%eax
f01009d9:	84 c0                	test   %al,%al
f01009db:	74 63                	je     f0100a40 <monitor+0xce>
f01009dd:	83 ec 08             	sub    $0x8,%esp
f01009e0:	0f be c0             	movsbl %al,%eax
f01009e3:	50                   	push   %eax
f01009e4:	68 18 68 10 f0       	push   $0xf0106818
f01009e9:	e8 4d 4d 00 00       	call   f010573b <strchr>
f01009ee:	83 c4 10             	add    $0x10,%esp
f01009f1:	85 c0                	test   %eax,%eax
f01009f3:	75 d7                	jne    f01009cc <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009f5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009f8:	74 46                	je     f0100a40 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009fa:	83 fe 0f             	cmp    $0xf,%esi
f01009fd:	75 14                	jne    f0100a13 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ff:	83 ec 08             	sub    $0x8,%esp
f0100a02:	6a 10                	push   $0x10
f0100a04:	68 1d 68 10 f0       	push   $0xf010681d
f0100a09:	e8 3f 2d 00 00       	call   f010374d <cprintf>
f0100a0e:	83 c4 10             	add    $0x10,%esp
f0100a11:	eb 95                	jmp    f01009a8 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a13:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a16:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a1a:	eb 03                	jmp    f0100a1f <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a1c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1f:	0f b6 03             	movzbl (%ebx),%eax
f0100a22:	84 c0                	test   %al,%al
f0100a24:	74 ae                	je     f01009d4 <monitor+0x62>
f0100a26:	83 ec 08             	sub    $0x8,%esp
f0100a29:	0f be c0             	movsbl %al,%eax
f0100a2c:	50                   	push   %eax
f0100a2d:	68 18 68 10 f0       	push   $0xf0106818
f0100a32:	e8 04 4d 00 00       	call   f010573b <strchr>
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 de                	je     f0100a1c <monitor+0xaa>
f0100a3e:	eb 94                	jmp    f01009d4 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a40:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a47:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a48:	85 f6                	test   %esi,%esi
f0100a4a:	0f 84 58 ff ff ff    	je     f01009a8 <monitor+0x36>
f0100a50:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a55:	83 ec 08             	sub    $0x8,%esp
f0100a58:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a5b:	ff 34 85 e0 69 10 f0 	pushl  -0xfef9620(,%eax,4)
f0100a62:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a65:	e8 73 4c 00 00       	call   f01056dd <strcmp>
f0100a6a:	83 c4 10             	add    $0x10,%esp
f0100a6d:	85 c0                	test   %eax,%eax
f0100a6f:	75 22                	jne    f0100a93 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100a71:	83 ec 04             	sub    $0x4,%esp
f0100a74:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a77:	ff 75 08             	pushl  0x8(%ebp)
f0100a7a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a7d:	52                   	push   %edx
f0100a7e:	56                   	push   %esi
f0100a7f:	ff 14 85 e8 69 10 f0 	call   *-0xfef9618(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a86:	83 c4 10             	add    $0x10,%esp
f0100a89:	85 c0                	test   %eax,%eax
f0100a8b:	0f 89 17 ff ff ff    	jns    f01009a8 <monitor+0x36>
f0100a91:	eb 20                	jmp    f0100ab3 <monitor+0x141>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a93:	83 c3 01             	add    $0x1,%ebx
f0100a96:	83 fb 03             	cmp    $0x3,%ebx
f0100a99:	75 ba                	jne    f0100a55 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a9b:	83 ec 08             	sub    $0x8,%esp
f0100a9e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa1:	68 3a 68 10 f0       	push   $0xf010683a
f0100aa6:	e8 a2 2c 00 00       	call   f010374d <cprintf>
f0100aab:	83 c4 10             	add    $0x10,%esp
f0100aae:	e9 f5 fe ff ff       	jmp    f01009a8 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab6:	5b                   	pop    %ebx
f0100ab7:	5e                   	pop    %esi
f0100ab8:	5f                   	pop    %edi
f0100ab9:	5d                   	pop    %ebp
f0100aba:	c3                   	ret    

f0100abb <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100abb:	83 3d 58 f2 22 f0 00 	cmpl   $0x0,0xf022f258
f0100ac2:	75 11                	jne    f0100ad5 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ac4:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100ac9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100acf:	89 15 58 f2 22 f0    	mov    %edx,0xf022f258
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
f0100ad5:	85 c0                	test   %eax,%eax
f0100ad7:	74 3d                	je     f0100b16 <boot_alloc+0x5b>
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100ad9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

		result = nextfree;
f0100adf:	a1 58 f2 22 f0       	mov    0xf022f258,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100ae4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		result = nextfree;
		nextfree += alloc_size;
f0100aea:	01 c2                	add    %eax,%edx
f0100aec:	89 15 58 f2 22 f0    	mov    %edx,0xf022f258

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
f0100af2:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100af8:	76 21                	jbe    f0100b1b <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100afa:	55                   	push   %ebp
f0100afb:	89 e5                	mov    %esp,%ebp
f0100afd:	83 ec 0c             	sub    $0xc,%esp

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
f0100b00:	a3 58 f2 22 f0       	mov    %eax,0xf022f258
                     result = NULL;
                     panic("boot_alloc: out of memory");
f0100b05:	68 04 6a 10 f0       	push   $0xf0106a04
f0100b0a:	6a 75                	push   $0x75
f0100b0c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100b11:	e8 2a f5 ff ff       	call   f0100040 <_panic>
                }

        
	} else {
		result = nextfree;
f0100b16:	a1 58 f2 22 f0       	mov    0xf022f258,%eax
	}
	return result;
	
}
f0100b1b:	f3 c3                	repz ret 

f0100b1d <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b1d:	89 d1                	mov    %edx,%ecx
f0100b1f:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b22:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b25:	a8 01                	test   $0x1,%al
f0100b27:	74 52                	je     f0100b7b <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b2e:	89 c1                	mov    %eax,%ecx
f0100b30:	c1 e9 0c             	shr    $0xc,%ecx
f0100b33:	3b 0d c8 fe 22 f0    	cmp    0xf022fec8,%ecx
f0100b39:	72 1b                	jb     f0100b56 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b3b:	55                   	push   %ebp
f0100b3c:	89 e5                	mov    %esp,%ebp
f0100b3e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b41:	50                   	push   %eax
f0100b42:	68 64 64 10 f0       	push   $0xf0106464
f0100b47:	68 9a 03 00 00       	push   $0x39a
f0100b4c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100b51:	e8 ea f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b56:	c1 ea 0c             	shr    $0xc,%edx
f0100b59:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b5f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b66:	89 c2                	mov    %eax,%edx
f0100b68:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b70:	85 d2                	test   %edx,%edx
f0100b72:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b77:	0f 44 c2             	cmove  %edx,%eax
f0100b7a:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b80:	c3                   	ret    

f0100b81 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b81:	55                   	push   %ebp
f0100b82:	89 e5                	mov    %esp,%ebp
f0100b84:	57                   	push   %edi
f0100b85:	56                   	push   %esi
f0100b86:	53                   	push   %ebx
f0100b87:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8a:	84 c0                	test   %al,%al
f0100b8c:	0f 85 a2 02 00 00    	jne    f0100e34 <check_page_free_list+0x2b3>
f0100b92:	e9 af 02 00 00       	jmp    f0100e46 <check_page_free_list+0x2c5>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b97:	83 ec 04             	sub    $0x4,%esp
f0100b9a:	68 68 6d 10 f0       	push   $0xf0106d68
f0100b9f:	68 d0 02 00 00       	push   $0x2d0
f0100ba4:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100ba9:	e8 92 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bae:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bb1:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bba:	89 c2                	mov    %eax,%edx
f0100bbc:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bc2:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bc8:	0f 95 c2             	setne  %dl
f0100bcb:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bce:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bd2:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bd4:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd8:	8b 00                	mov    (%eax),%eax
f0100bda:	85 c0                	test   %eax,%eax
f0100bdc:	75 dc                	jne    f0100bba <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100be1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bed:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bef:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bf2:	a3 60 f2 22 f0       	mov    %eax,0xf022f260
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bf7:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfc:	8b 1d 60 f2 22 f0    	mov    0xf022f260,%ebx
f0100c02:	eb 53                	jmp    f0100c57 <check_page_free_list+0xd6>
f0100c04:	89 d8                	mov    %ebx,%eax
f0100c06:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0100c0c:	c1 f8 03             	sar    $0x3,%eax
f0100c0f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	c1 ea 16             	shr    $0x16,%edx
f0100c17:	39 f2                	cmp    %esi,%edx
f0100c19:	73 3a                	jae    f0100c55 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c1b:	89 c2                	mov    %eax,%edx
f0100c1d:	c1 ea 0c             	shr    $0xc,%edx
f0100c20:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0100c26:	72 12                	jb     f0100c3a <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c28:	50                   	push   %eax
f0100c29:	68 64 64 10 f0       	push   $0xf0106464
f0100c2e:	6a 58                	push   $0x58
f0100c30:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0100c35:	e8 06 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c3a:	83 ec 04             	sub    $0x4,%esp
f0100c3d:	68 80 00 00 00       	push   $0x80
f0100c42:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c47:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4c:	50                   	push   %eax
f0100c4d:	e8 26 4b 00 00       	call   f0105778 <memset>
f0100c52:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c55:	8b 1b                	mov    (%ebx),%ebx
f0100c57:	85 db                	test   %ebx,%ebx
f0100c59:	75 a9                	jne    f0100c04 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c60:	e8 56 fe ff ff       	call   f0100abb <boot_alloc>
f0100c65:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c68:	8b 15 60 f2 22 f0    	mov    0xf022f260,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c6e:	8b 0d d0 fe 22 f0    	mov    0xf022fed0,%ecx
		assert(pp < pages + npages);
f0100c74:	a1 c8 fe 22 f0       	mov    0xf022fec8,%eax
f0100c79:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c7c:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c82:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c87:	be 00 00 00 00       	mov    $0x0,%esi
f0100c8c:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100c8f:	89 d8                	mov    %ebx,%eax
f0100c91:	89 cb                	mov    %ecx,%ebx
f0100c93:	89 c1                	mov    %eax,%ecx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c95:	e9 55 01 00 00       	jmp    f0100def <check_page_free_list+0x26e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c9a:	39 da                	cmp    %ebx,%edx
f0100c9c:	73 19                	jae    f0100cb7 <check_page_free_list+0x136>
f0100c9e:	68 38 6a 10 f0       	push   $0xf0106a38
f0100ca3:	68 44 6a 10 f0       	push   $0xf0106a44
f0100ca8:	68 ea 02 00 00       	push   $0x2ea
f0100cad:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100cb2:	e8 89 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cb7:	39 ca                	cmp    %ecx,%edx
f0100cb9:	72 19                	jb     f0100cd4 <check_page_free_list+0x153>
f0100cbb:	68 59 6a 10 f0       	push   $0xf0106a59
f0100cc0:	68 44 6a 10 f0       	push   $0xf0106a44
f0100cc5:	68 eb 02 00 00       	push   $0x2eb
f0100cca:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100ccf:	e8 6c f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cd4:	89 d0                	mov    %edx,%eax
f0100cd6:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100cd9:	a8 07                	test   $0x7,%al
f0100cdb:	74 19                	je     f0100cf6 <check_page_free_list+0x175>
f0100cdd:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0100ce2:	68 44 6a 10 f0       	push   $0xf0106a44
f0100ce7:	68 ec 02 00 00       	push   $0x2ec
f0100cec:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100cf1:	e8 4a f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cf6:	c1 f8 03             	sar    $0x3,%eax
f0100cf9:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cfc:	85 c0                	test   %eax,%eax
f0100cfe:	75 19                	jne    f0100d19 <check_page_free_list+0x198>
f0100d00:	68 6d 6a 10 f0       	push   $0xf0106a6d
f0100d05:	68 44 6a 10 f0       	push   $0xf0106a44
f0100d0a:	68 ef 02 00 00       	push   $0x2ef
f0100d0f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100d14:	e8 27 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d19:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d1e:	75 19                	jne    f0100d39 <check_page_free_list+0x1b8>
f0100d20:	68 7e 6a 10 f0       	push   $0xf0106a7e
f0100d25:	68 44 6a 10 f0       	push   $0xf0106a44
f0100d2a:	68 f0 02 00 00       	push   $0x2f0
f0100d2f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100d34:	e8 07 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d39:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d3e:	75 19                	jne    f0100d59 <check_page_free_list+0x1d8>
f0100d40:	68 c0 6d 10 f0       	push   $0xf0106dc0
f0100d45:	68 44 6a 10 f0       	push   $0xf0106a44
f0100d4a:	68 f1 02 00 00       	push   $0x2f1
f0100d4f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100d54:	e8 e7 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d59:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d5e:	75 19                	jne    f0100d79 <check_page_free_list+0x1f8>
f0100d60:	68 97 6a 10 f0       	push   $0xf0106a97
f0100d65:	68 44 6a 10 f0       	push   $0xf0106a44
f0100d6a:	68 f2 02 00 00       	push   $0x2f2
f0100d6f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100d74:	e8 c7 f2 ff ff       	call   f0100040 <_panic>
f0100d79:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d7c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d81:	0f 86 d6 00 00 00    	jbe    f0100e5d <check_page_free_list+0x2dc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d87:	89 c6                	mov    %eax,%esi
f0100d89:	c1 ee 0c             	shr    $0xc,%esi
f0100d8c:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100d8f:	77 12                	ja     f0100da3 <check_page_free_list+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d91:	50                   	push   %eax
f0100d92:	68 64 64 10 f0       	push   $0xf0106464
f0100d97:	6a 58                	push   $0x58
f0100d99:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0100d9e:	e8 9d f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100da3:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
f0100da9:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0100dac:	0f 86 b7 00 00 00    	jbe    f0100e69 <check_page_free_list+0x2e8>
f0100db2:	68 e4 6d 10 f0       	push   $0xf0106de4
f0100db7:	68 44 6a 10 f0       	push   $0xf0106a44
f0100dbc:	68 f3 02 00 00       	push   $0x2f3
f0100dc1:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100dc6:	e8 75 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dcb:	68 b1 6a 10 f0       	push   $0xf0106ab1
f0100dd0:	68 44 6a 10 f0       	push   $0xf0106a44
f0100dd5:	68 f5 02 00 00       	push   $0x2f5
f0100dda:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100ddf:	e8 5c f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100de4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100de8:	eb 03                	jmp    f0100ded <check_page_free_list+0x26c>
		else
			++nfree_extmem;
f0100dea:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ded:	8b 12                	mov    (%edx),%edx
f0100def:	85 d2                	test   %edx,%edx
f0100df1:	0f 85 a3 fe ff ff    	jne    f0100c9a <check_page_free_list+0x119>
f0100df7:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dfa:	85 f6                	test   %esi,%esi
f0100dfc:	7f 19                	jg     f0100e17 <check_page_free_list+0x296>
f0100dfe:	68 ce 6a 10 f0       	push   $0xf0106ace
f0100e03:	68 44 6a 10 f0       	push   $0xf0106a44
f0100e08:	68 fd 02 00 00       	push   $0x2fd
f0100e0d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100e12:	e8 29 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e17:	85 ff                	test   %edi,%edi
f0100e19:	7f 5e                	jg     f0100e79 <check_page_free_list+0x2f8>
f0100e1b:	68 e0 6a 10 f0       	push   $0xf0106ae0
f0100e20:	68 44 6a 10 f0       	push   $0xf0106a44
f0100e25:	68 fe 02 00 00       	push   $0x2fe
f0100e2a:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100e2f:	e8 0c f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e34:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f0100e39:	85 c0                	test   %eax,%eax
f0100e3b:	0f 85 6d fd ff ff    	jne    f0100bae <check_page_free_list+0x2d>
f0100e41:	e9 51 fd ff ff       	jmp    f0100b97 <check_page_free_list+0x16>
f0100e46:	83 3d 60 f2 22 f0 00 	cmpl   $0x0,0xf022f260
f0100e4d:	0f 84 44 fd ff ff    	je     f0100b97 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e53:	be 00 04 00 00       	mov    $0x400,%esi
f0100e58:	e9 9f fd ff ff       	jmp    f0100bfc <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e5d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e62:	75 80                	jne    f0100de4 <check_page_free_list+0x263>
f0100e64:	e9 62 ff ff ff       	jmp    f0100dcb <check_page_free_list+0x24a>
f0100e69:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e6e:	0f 85 76 ff ff ff    	jne    f0100dea <check_page_free_list+0x269>
f0100e74:	e9 52 ff ff ff       	jmp    f0100dcb <check_page_free_list+0x24a>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e7c:	5b                   	pop    %ebx
f0100e7d:	5e                   	pop    %esi
f0100e7e:	5f                   	pop    %edi
f0100e7f:	5d                   	pop    %ebp
f0100e80:	c3                   	ret    

f0100e81 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e81:	55                   	push   %ebp
f0100e82:	89 e5                	mov    %esp,%ebp
f0100e84:	56                   	push   %esi
f0100e85:	53                   	push   %ebx
f0100e86:	8b 1d 60 f2 22 f0    	mov    0xf022f260,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e91:	eb 22                	jmp    f0100eb5 <page_init+0x34>
f0100e93:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100e9a:	89 d1                	mov    %edx,%ecx
f0100e9c:	03 0d d0 fe 22 f0    	add    0xf022fed0,%ecx
f0100ea2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ea8:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100eaa:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100ead:	89 d3                	mov    %edx,%ebx
f0100eaf:	03 1d d0 fe 22 f0    	add    0xf022fed0,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100eb5:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f0100ebb:	72 d6                	jb     f0100e93 <page_init+0x12>
f0100ebd:	89 1d 60 f2 22 f0    	mov    %ebx,0xf022f260
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
        pages[0].pp_ref = 1; 
f0100ec3:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
f0100ec8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
        pages[1].pp_link = pages[0].pp_link;
f0100ece:	8b 10                	mov    (%eax),%edx
f0100ed0:	89 50 08             	mov    %edx,0x8(%eax)
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
f0100ed3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed8:	e8 de fb ff ff       	call   f0100abb <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100edd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ee2:	77 15                	ja     f0100ef9 <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ee4:	50                   	push   %eax
f0100ee5:	68 88 64 10 f0       	push   $0xf0106488
f0100eea:	68 51 01 00 00       	push   $0x151
f0100eef:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0100ef4:	e8 47 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ef9:	05 00 00 00 10       	add    $0x10000000,%eax
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
f0100efe:	8b 15 d0 fe 22 f0    	mov    0xf022fed0,%edx
f0100f04:	8b b2 00 05 00 00    	mov    0x500(%edx),%esi
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f0a:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0100f0f:	eb 20                	jmp    f0100f31 <page_init+0xb0>
              pages[i/PGSIZE].pp_ref = 1;  
f0100f11:	89 d3                	mov    %edx,%ebx
f0100f13:	c1 eb 0c             	shr    $0xc,%ebx
f0100f16:	8b 0d d0 fe 22 f0    	mov    0xf022fed0,%ecx
f0100f1c:	8d 0c d9             	lea    (%ecx,%ebx,8),%ecx
f0100f1f:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
              pages[i/PGSIZE].pp_link = NULL;     
f0100f25:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
        pages[0].pp_ref = 1; 
        pages[1].pp_link = pages[0].pp_link;
         
        uint32_t nextfreepa = PADDR(boot_alloc(0));         
        struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100f2b:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100f31:	39 c2                	cmp    %eax,%edx
f0100f33:	72 dc                	jb     f0100f11 <page_init+0x90>
              pages[i/PGSIZE].pp_ref = 1;  
              pages[i/PGSIZE].pp_link = NULL;     
        }      
        pages[i/PGSIZE].pp_link = p;
f0100f35:	c1 ea 0c             	shr    $0xc,%edx
f0100f38:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
f0100f3d:	89 34 d0             	mov    %esi,(%eax,%edx,8)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f40:	83 3d c8 fe 22 f0 07 	cmpl   $0x7,0xf022fec8
f0100f47:	77 14                	ja     f0100f5d <page_init+0xdc>
		panic("pa2page called with invalid pa");
f0100f49:	83 ec 04             	sub    $0x4,%esp
f0100f4c:	68 2c 6e 10 f0       	push   $0xf0106e2c
f0100f51:	6a 51                	push   $0x51
f0100f53:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0100f58:	e8 e3 f0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100f5d:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
        p = pa2page(MPENTRY_PADDR);
        (p + 1)->pp_link = p->pp_link;
f0100f62:	8b 50 38             	mov    0x38(%eax),%edx
f0100f65:	89 50 40             	mov    %edx,0x40(%eax)
        p->pp_ref = 1;
f0100f68:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
        p->pp_link = NULL;
f0100f6e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
}
f0100f75:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f78:	5b                   	pop    %ebx
f0100f79:	5e                   	pop    %esi
f0100f7a:	5d                   	pop    %ebp
f0100f7b:	c3                   	ret    

f0100f7c <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
       if ( page_free_list ) {
f0100f7c:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f0100f81:	85 c0                	test   %eax,%eax
f0100f83:	74 63                	je     f0100fe8 <page_alloc+0x6c>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f85:	55                   	push   %ebp
f0100f86:	89 e5                	mov    %esp,%ebp
f0100f88:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in
       if ( page_free_list ) {
            if(alloc_flags & ALLOC_ZERO) 
f0100f8b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f8f:	74 43                	je     f0100fd4 <page_alloc+0x58>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f91:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0100f97:	c1 f8 03             	sar    $0x3,%eax
f0100f9a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f9d:	89 c2                	mov    %eax,%edx
f0100f9f:	c1 ea 0c             	shr    $0xc,%edx
f0100fa2:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0100fa8:	72 12                	jb     f0100fbc <page_alloc+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100faa:	50                   	push   %eax
f0100fab:	68 64 64 10 f0       	push   $0xf0106464
f0100fb0:	6a 58                	push   $0x58
f0100fb2:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0100fb7:	e8 84 f0 ff ff       	call   f0100040 <_panic>
                memset(page2kva(page_free_list), 0, PGSIZE);
f0100fbc:	83 ec 04             	sub    $0x4,%esp
f0100fbf:	68 00 10 00 00       	push   $0x1000
f0100fc4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fc6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fcb:	50                   	push   %eax
f0100fcc:	e8 a7 47 00 00       	call   f0105778 <memset>
f0100fd1:	83 c4 10             	add    $0x10,%esp
               
                struct PageInfo *tmp = page_free_list;
f0100fd4:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
                 
                page_free_list = page_free_list->pp_link;
f0100fd9:	8b 10                	mov    (%eax),%edx
f0100fdb:	89 15 60 f2 22 f0    	mov    %edx,0xf022f260
                tmp->pp_link = NULL;
f0100fe1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                      
                return tmp; 
            
        }
	return NULL;
}
f0100fe7:	c9                   	leave  
f0100fe8:	f3 c3                	repz ret 

f0100fea <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	83 ec 08             	sub    $0x8,%esp
f0100ff0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.    
        if(pp == NULL) return;
f0100ff3:	85 c0                	test   %eax,%eax
f0100ff5:	74 30                	je     f0101027 <page_free+0x3d>
        if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100ff7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ffc:	75 05                	jne    f0101003 <page_free+0x19>
f0100ffe:	83 38 00             	cmpl   $0x0,(%eax)
f0101001:	74 17                	je     f010101a <page_free+0x30>
            panic("page_free: invalid page free\n");
f0101003:	83 ec 04             	sub    $0x4,%esp
f0101006:	68 f1 6a 10 f0       	push   $0xf0106af1
f010100b:	68 89 01 00 00       	push   $0x189
f0101010:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101015:	e8 26 f0 ff ff       	call   f0100040 <_panic>
        else {
            pp->pp_link = page_free_list;
f010101a:	8b 15 60 f2 22 f0    	mov    0xf022f260,%edx
f0101020:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f0101022:	a3 60 f2 22 f0       	mov    %eax,0xf022f260
        }
}
f0101027:	c9                   	leave  
f0101028:	c3                   	ret    

f0101029 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101029:	55                   	push   %ebp
f010102a:	89 e5                	mov    %esp,%ebp
f010102c:	83 ec 08             	sub    $0x8,%esp
f010102f:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101032:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101036:	83 e8 01             	sub    $0x1,%eax
f0101039:	66 89 42 04          	mov    %ax,0x4(%edx)
f010103d:	66 85 c0             	test   %ax,%ax
f0101040:	75 0c                	jne    f010104e <page_decref+0x25>
		page_free(pp);
f0101042:	83 ec 0c             	sub    $0xc,%esp
f0101045:	52                   	push   %edx
f0101046:	e8 9f ff ff ff       	call   f0100fea <page_free>
f010104b:	83 c4 10             	add    $0x10,%esp
}
f010104e:	c9                   	leave  
f010104f:	c3                   	ret    

f0101050 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	56                   	push   %esi
f0101054:	53                   	push   %ebx
f0101055:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t * pte;
        if ((pgdir[PDX(va)] & PTE_P) != 0) {
f0101058:	89 de                	mov    %ebx,%esi
f010105a:	c1 ee 16             	shr    $0x16,%esi
f010105d:	c1 e6 02             	shl    $0x2,%esi
f0101060:	03 75 08             	add    0x8(%ebp),%esi
f0101063:	8b 06                	mov    (%esi),%eax
f0101065:	a8 01                	test   $0x1,%al
f0101067:	74 3c                	je     f01010a5 <pgdir_walk+0x55>
                pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0101069:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010106e:	89 c2                	mov    %eax,%edx
f0101070:	c1 ea 0c             	shr    $0xc,%edx
f0101073:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0101079:	72 15                	jb     f0101090 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107b:	50                   	push   %eax
f010107c:	68 64 64 10 f0       	push   $0xf0106464
f0101081:	68 b7 01 00 00       	push   $0x1b7
f0101086:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010108b:	e8 b0 ef ff ff       	call   f0100040 <_panic>
                return pte + PTX(va);  
f0101090:	c1 eb 0a             	shr    $0xa,%ebx
f0101093:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101099:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01010a0:	e9 81 00 00 00       	jmp    f0101126 <pgdir_walk+0xd6>

 
        } 
        
        if(create != 0) {
f01010a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010a9:	74 6f                	je     f010111a <pgdir_walk+0xca>
               struct PageInfo *tmp;
               tmp = page_alloc(1);
f01010ab:	83 ec 0c             	sub    $0xc,%esp
f01010ae:	6a 01                	push   $0x1
f01010b0:	e8 c7 fe ff ff       	call   f0100f7c <page_alloc>
       
               if(tmp != NULL) {
f01010b5:	83 c4 10             	add    $0x10,%esp
f01010b8:	85 c0                	test   %eax,%eax
f01010ba:	74 65                	je     f0101121 <pgdir_walk+0xd1>
                       
                        
                       tmp->pp_ref += 1;
f01010bc:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
                       tmp->pp_link = NULL;
f01010c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c7:	89 c2                	mov    %eax,%edx
f01010c9:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f01010cf:	c1 fa 03             	sar    $0x3,%edx
f01010d2:	c1 e2 0c             	shl    $0xc,%edx
                       pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
f01010d5:	83 ca 07             	or     $0x7,%edx
f01010d8:	89 16                	mov    %edx,(%esi)
f01010da:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f01010e0:	c1 f8 03             	sar    $0x3,%eax
f01010e3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010e6:	89 c2                	mov    %eax,%edx
f01010e8:	c1 ea 0c             	shr    $0xc,%edx
f01010eb:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f01010f1:	72 15                	jb     f0101108 <pgdir_walk+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f3:	50                   	push   %eax
f01010f4:	68 64 64 10 f0       	push   $0xf0106464
f01010f9:	68 c7 01 00 00       	push   $0x1c7
f01010fe:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101103:	e8 38 ef ff ff       	call   f0100040 <_panic>
                       pte = (pte_t *)KADDR(page2pa(tmp));
                  
                       return pte+PTX(va); 
f0101108:	c1 eb 0a             	shr    $0xa,%ebx
f010110b:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101111:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101118:	eb 0c                	jmp    f0101126 <pgdir_walk+0xd6>

               }
               
        }

	return NULL;
f010111a:	b8 00 00 00 00       	mov    $0x0,%eax
f010111f:	eb 05                	jmp    f0101126 <pgdir_walk+0xd6>
f0101121:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101126:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101129:	5b                   	pop    %ebx
f010112a:	5e                   	pop    %esi
f010112b:	5d                   	pop    %ebp
f010112c:	c3                   	ret    

f010112d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010112d:	55                   	push   %ebp
f010112e:	89 e5                	mov    %esp,%ebp
f0101130:	57                   	push   %edi
f0101131:	56                   	push   %esi
f0101132:	53                   	push   %ebx
f0101133:	83 ec 1c             	sub    $0x1c,%esp
f0101136:	89 c7                	mov    %eax,%edi
f0101138:	89 55 e0             	mov    %edx,-0x20(%ebp)
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
f010113b:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0101141:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101147:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f010114a:	be 00 00 00 00       	mov    $0x0,%esi
f010114f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101152:	83 c8 01             	or     $0x1,%eax
f0101155:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101158:	eb 3d                	jmp    f0101197 <boot_map_region+0x6a>
              tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
f010115a:	83 ec 04             	sub    $0x4,%esp
f010115d:	6a 01                	push   $0x1
f010115f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101162:	01 f0                	add    %esi,%eax
f0101164:	50                   	push   %eax
f0101165:	57                   	push   %edi
f0101166:	e8 e5 fe ff ff       	call   f0101050 <pgdir_walk>
              if ( tmp == NULL ) {
f010116b:	83 c4 10             	add    $0x10,%esp
f010116e:	85 c0                	test   %eax,%eax
f0101170:	75 17                	jne    f0101189 <boot_map_region+0x5c>
                     panic("boot_map_region: fail\n");
f0101172:	83 ec 04             	sub    $0x4,%esp
f0101175:	68 0f 6b 10 f0       	push   $0xf0106b0f
f010117a:	68 e7 01 00 00       	push   $0x1e7
f010117f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101184:	e8 b7 ee ff ff       	call   f0100040 <_panic>
f0101189:	03 5d 08             	add    0x8(%ebp),%ebx
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
f010118c:	0b 5d dc             	or     -0x24(%ebp),%ebx
f010118f:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0101191:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101197:	89 f3                	mov    %esi,%ebx
f0101199:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f010119c:	77 bc                	ja     f010115a <boot_map_region+0x2d>
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
 
        }
}
f010119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a1:	5b                   	pop    %ebx
f01011a2:	5e                   	pop    %esi
f01011a3:	5f                   	pop    %edi
f01011a4:	5d                   	pop    %ebp
f01011a5:	c3                   	ret    

f01011a6 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011a6:	55                   	push   %ebp
f01011a7:	89 e5                	mov    %esp,%ebp
f01011a9:	53                   	push   %ebx
f01011aa:	83 ec 08             	sub    $0x8,%esp
f01011ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 0);
f01011b0:	6a 00                	push   $0x0
f01011b2:	ff 75 0c             	pushl  0xc(%ebp)
f01011b5:	ff 75 08             	pushl  0x8(%ebp)
f01011b8:	e8 93 fe ff ff       	call   f0101050 <pgdir_walk>
        if ( tmp != NULL && (*tmp & PTE_P)) {
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	85 c0                	test   %eax,%eax
f01011c2:	74 37                	je     f01011fb <page_lookup+0x55>
f01011c4:	f6 00 01             	testb  $0x1,(%eax)
f01011c7:	74 39                	je     f0101202 <page_lookup+0x5c>
                if(pte_store != NULL) 
f01011c9:	85 db                	test   %ebx,%ebx
f01011cb:	74 02                	je     f01011cf <page_lookup+0x29>
                        *pte_store = tmp;
f01011cd:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011cf:	8b 00                	mov    (%eax),%eax
f01011d1:	c1 e8 0c             	shr    $0xc,%eax
f01011d4:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f01011da:	72 14                	jb     f01011f0 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01011dc:	83 ec 04             	sub    $0x4,%esp
f01011df:	68 2c 6e 10 f0       	push   $0xf0106e2c
f01011e4:	6a 51                	push   $0x51
f01011e6:	68 2a 6a 10 f0       	push   $0xf0106a2a
f01011eb:	e8 50 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011f0:	8b 15 d0 fe 22 f0    	mov    0xf022fed0,%edx
f01011f6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
                return (struct PageInfo *)pa2page(*tmp);
f01011f9:	eb 0c                	jmp    f0101207 <page_lookup+0x61>

        }
	return NULL;
f01011fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101200:	eb 05                	jmp    f0101207 <page_lookup+0x61>
f0101202:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101207:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010120a:	c9                   	leave  
f010120b:	c3                   	ret    

f010120c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010120c:	55                   	push   %ebp
f010120d:	89 e5                	mov    %esp,%ebp
f010120f:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
//<<<<<<< HEAD
	if (!curenv || curenv->env_pgdir == pgdir)
f0101212:	e8 84 4b 00 00       	call   f0105d9b <cpunum>
f0101217:	6b c0 74             	imul   $0x74,%eax,%eax
f010121a:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f0101221:	74 16                	je     f0101239 <tlb_invalidate+0x2d>
f0101223:	e8 73 4b 00 00       	call   f0105d9b <cpunum>
f0101228:	6b c0 74             	imul   $0x74,%eax,%eax
f010122b:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0101231:	8b 55 08             	mov    0x8(%ebp),%edx
f0101234:	39 50 60             	cmp    %edx,0x60(%eax)
f0101237:	75 06                	jne    f010123f <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101239:	8b 45 0c             	mov    0xc(%ebp),%eax
f010123c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010123f:	c9                   	leave  
f0101240:	c3                   	ret    

f0101241 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101241:	55                   	push   %ebp
f0101242:	89 e5                	mov    %esp,%ebp
f0101244:	56                   	push   %esi
f0101245:	53                   	push   %ebx
f0101246:	83 ec 14             	sub    $0x14,%esp
f0101249:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010124c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f010124f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101252:	50                   	push   %eax
f0101253:	56                   	push   %esi
f0101254:	53                   	push   %ebx
f0101255:	e8 4c ff ff ff       	call   f01011a6 <page_lookup>
        if( tmp != NULL && (*tmppte & PTE_P)) {
f010125a:	83 c4 10             	add    $0x10,%esp
f010125d:	85 c0                	test   %eax,%eax
f010125f:	74 1d                	je     f010127e <page_remove+0x3d>
f0101261:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101264:	f6 02 01             	testb  $0x1,(%edx)
f0101267:	74 15                	je     f010127e <page_remove+0x3d>
                page_decref(tmp);
f0101269:	83 ec 0c             	sub    $0xc,%esp
f010126c:	50                   	push   %eax
f010126d:	e8 b7 fd ff ff       	call   f0101029 <page_decref>
                *tmppte = 0;
f0101272:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101275:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010127b:	83 c4 10             	add    $0x10,%esp
        }
        tlb_invalidate(pgdir, va);
f010127e:	83 ec 08             	sub    $0x8,%esp
f0101281:	56                   	push   %esi
f0101282:	53                   	push   %ebx
f0101283:	e8 84 ff ff ff       	call   f010120c <tlb_invalidate>
f0101288:	83 c4 10             	add    $0x10,%esp
}
f010128b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010128e:	5b                   	pop    %ebx
f010128f:	5e                   	pop    %esi
f0101290:	5d                   	pop    %ebp
f0101291:	c3                   	ret    

f0101292 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101292:	55                   	push   %ebp
f0101293:	89 e5                	mov    %esp,%ebp
f0101295:	57                   	push   %edi
f0101296:	56                   	push   %esi
f0101297:	53                   	push   %ebx
f0101298:	83 ec 10             	sub    $0x10,%esp
f010129b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010129e:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
f01012a1:	6a 01                	push   $0x1
f01012a3:	57                   	push   %edi
f01012a4:	ff 75 08             	pushl  0x8(%ebp)
f01012a7:	e8 a4 fd ff ff       	call   f0101050 <pgdir_walk>
f01012ac:	89 c3                	mov    %eax,%ebx
         
        if( tmp == NULL )
f01012ae:	83 c4 10             	add    $0x10,%esp
f01012b1:	85 c0                	test   %eax,%eax
f01012b3:	74 3e                	je     f01012f3 <page_insert+0x61>
                return -E_NO_MEM;

        pp->pp_ref += 1;
f01012b5:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if( (*tmp & PTE_P) != 0 )
f01012ba:	f6 00 01             	testb  $0x1,(%eax)
f01012bd:	74 0f                	je     f01012ce <page_insert+0x3c>
                page_remove(pgdir, va);
f01012bf:	83 ec 08             	sub    $0x8,%esp
f01012c2:	57                   	push   %edi
f01012c3:	ff 75 08             	pushl  0x8(%ebp)
f01012c6:	e8 76 ff ff ff       	call   f0101241 <page_remove>
f01012cb:	83 c4 10             	add    $0x10,%esp
f01012ce:	8b 55 14             	mov    0x14(%ebp),%edx
f01012d1:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012d4:	89 f0                	mov    %esi,%eax
f01012d6:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f01012dc:	c1 f8 03             	sar    $0x3,%eax
f01012df:	c1 e0 0c             	shl    $0xc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
f01012e2:	09 d0                	or     %edx,%eax
f01012e4:	89 03                	mov    %eax,(%ebx)
        pp->pp_link = NULL;
f01012e6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return 0;
f01012ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f1:	eb 05                	jmp    f01012f8 <page_insert+0x66>
{
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        if( tmp == NULL )
                return -E_NO_MEM;
f01012f3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
                page_remove(pgdir, va);
         
        *tmp = page2pa(pp) | perm | PTE_P;
        pp->pp_link = NULL;
	return 0;
}
f01012f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012fb:	5b                   	pop    %ebx
f01012fc:	5e                   	pop    %esi
f01012fd:	5f                   	pop    %edi
f01012fe:	5d                   	pop    %ebp
f01012ff:	c3                   	ret    

f0101300 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101300:	55                   	push   %ebp
f0101301:	89 e5                	mov    %esp,%ebp
f0101303:	53                   	push   %ebx
f0101304:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t roundsize = ROUNDUP(size, PGSIZE);
f0101307:	8b 45 0c             	mov    0xc(%ebp),%eax
f010130a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101310:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if( base + roundsize >= MMIOLIM )
f0101316:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010131c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010131f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101324:	76 17                	jbe    f010133d <mmio_map_region+0x3d>
                panic("Lapic required too much memory\n");
f0101326:	83 ec 04             	sub    $0x4,%esp
f0101329:	68 4c 6e 10 f0       	push   $0xf0106e4c
f010132e:	68 7e 02 00 00       	push   $0x27e
f0101333:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101338:	e8 03 ed ff ff       	call   f0100040 <_panic>
        boot_map_region(kern_pgdir, base, roundsize, pa, PTE_PCD | PTE_PWT | PTE_W);
f010133d:	83 ec 08             	sub    $0x8,%esp
f0101340:	6a 1a                	push   $0x1a
f0101342:	ff 75 08             	pushl  0x8(%ebp)
f0101345:	89 d9                	mov    %ebx,%ecx
f0101347:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f010134c:	e8 dc fd ff ff       	call   f010112d <boot_map_region>
        base += roundsize; 
f0101351:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101356:	01 c3                	add    %eax,%ebx
f0101358:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	//panic("mmio_map_region not implemented");
        return (void *)(base - roundsize);
}
f010135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101361:	c9                   	leave  
f0101362:	c3                   	ret    

f0101363 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101363:	55                   	push   %ebp
f0101364:	89 e5                	mov    %esp,%ebp
f0101366:	57                   	push   %edi
f0101367:	56                   	push   %esi
f0101368:	53                   	push   %ebx
f0101369:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010136c:	6a 15                	push   $0x15
f010136e:	e8 79 22 00 00       	call   f01035ec <mc146818_read>
f0101373:	89 c3                	mov    %eax,%ebx
f0101375:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010137c:	e8 6b 22 00 00       	call   f01035ec <mc146818_read>
f0101381:	c1 e0 08             	shl    $0x8,%eax
f0101384:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101386:	c1 e0 0a             	shl    $0xa,%eax
f0101389:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010138f:	85 c0                	test   %eax,%eax
f0101391:	0f 48 c2             	cmovs  %edx,%eax
f0101394:	c1 f8 0c             	sar    $0xc,%eax
f0101397:	a3 64 f2 22 f0       	mov    %eax,0xf022f264
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010139c:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013a3:	e8 44 22 00 00       	call   f01035ec <mc146818_read>
f01013a8:	89 c3                	mov    %eax,%ebx
f01013aa:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013b1:	e8 36 22 00 00       	call   f01035ec <mc146818_read>
f01013b6:	c1 e0 08             	shl    $0x8,%eax
f01013b9:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01013bb:	c1 e0 0a             	shl    $0xa,%eax
f01013be:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013c4:	83 c4 10             	add    $0x10,%esp
f01013c7:	85 c0                	test   %eax,%eax
f01013c9:	0f 48 c2             	cmovs  %edx,%eax
f01013cc:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01013cf:	85 c0                	test   %eax,%eax
f01013d1:	74 0e                	je     f01013e1 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01013d3:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013d9:	89 15 c8 fe 22 f0    	mov    %edx,0xf022fec8
f01013df:	eb 0c                	jmp    f01013ed <mem_init+0x8a>
	else
		npages = npages_basemem;
f01013e1:	8b 15 64 f2 22 f0    	mov    0xf022f264,%edx
f01013e7:	89 15 c8 fe 22 f0    	mov    %edx,0xf022fec8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01013ed:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013f0:	c1 e8 0a             	shr    $0xa,%eax
f01013f3:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01013f4:	a1 64 f2 22 f0       	mov    0xf022f264,%eax
f01013f9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013fc:	c1 e8 0a             	shr    $0xa,%eax
f01013ff:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101400:	a1 c8 fe 22 f0       	mov    0xf022fec8,%eax
f0101405:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101408:	c1 e8 0a             	shr    $0xa,%eax
f010140b:	50                   	push   %eax
f010140c:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0101411:	e8 37 23 00 00       	call   f010374d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101416:	b8 00 10 00 00       	mov    $0x1000,%eax
f010141b:	e8 9b f6 ff ff       	call   f0100abb <boot_alloc>
f0101420:	a3 cc fe 22 f0       	mov    %eax,0xf022fecc
	memset(kern_pgdir, 0, PGSIZE);
f0101425:	83 c4 0c             	add    $0xc,%esp
f0101428:	68 00 10 00 00       	push   $0x1000
f010142d:	6a 00                	push   $0x0
f010142f:	50                   	push   %eax
f0101430:	e8 43 43 00 00       	call   f0105778 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101435:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010143a:	83 c4 10             	add    $0x10,%esp
f010143d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101442:	77 15                	ja     f0101459 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101444:	50                   	push   %eax
f0101445:	68 88 64 10 f0       	push   $0xf0106488
f010144a:	68 a1 00 00 00       	push   $0xa1
f010144f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101454:	e8 e7 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101459:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010145f:	83 ca 05             	or     $0x5,%edx
f0101462:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo));
f0101468:	a1 c8 fe 22 f0       	mov    0xf022fec8,%eax
f010146d:	c1 e0 03             	shl    $0x3,%eax
f0101470:	e8 46 f6 ff ff       	call   f0100abb <boot_alloc>
f0101475:	a3 d0 fe 22 f0       	mov    %eax,0xf022fed0
        memset(pages, 0, npages * sizeof(struct PageInfo));
f010147a:	83 ec 04             	sub    $0x4,%esp
f010147d:	8b 0d c8 fe 22 f0    	mov    0xf022fec8,%ecx
f0101483:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010148a:	52                   	push   %edx
f010148b:	6a 00                	push   $0x0
f010148d:	50                   	push   %eax
f010148e:	e8 e5 42 00 00       	call   f0105778 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        envs = boot_alloc(NENV * sizeof(struct Env));
f0101493:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101498:	e8 1e f6 ff ff       	call   f0100abb <boot_alloc>
f010149d:	a3 68 f2 22 f0       	mov    %eax,0xf022f268
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014a2:	e8 da f9 ff ff       	call   f0100e81 <page_init>
 
	check_page_free_list(1);
f01014a7:	b8 01 00 00 00       	mov    $0x1,%eax
f01014ac:	e8 d0 f6 ff ff       	call   f0100b81 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014b1:	83 c4 10             	add    $0x10,%esp
f01014b4:	83 3d d0 fe 22 f0 00 	cmpl   $0x0,0xf022fed0
f01014bb:	75 17                	jne    f01014d4 <mem_init+0x171>
		panic("'pages' is a null pointer!");
f01014bd:	83 ec 04             	sub    $0x4,%esp
f01014c0:	68 26 6b 10 f0       	push   $0xf0106b26
f01014c5:	68 0f 03 00 00       	push   $0x30f
f01014ca:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01014cf:	e8 6c eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014d4:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f01014d9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014de:	eb 05                	jmp    f01014e5 <mem_init+0x182>
		++nfree;
f01014e0:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014e3:	8b 00                	mov    (%eax),%eax
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	75 f7                	jne    f01014e0 <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014e9:	83 ec 0c             	sub    $0xc,%esp
f01014ec:	6a 00                	push   $0x0
f01014ee:	e8 89 fa ff ff       	call   f0100f7c <page_alloc>
f01014f3:	89 c7                	mov    %eax,%edi
f01014f5:	83 c4 10             	add    $0x10,%esp
f01014f8:	85 c0                	test   %eax,%eax
f01014fa:	75 19                	jne    f0101515 <mem_init+0x1b2>
f01014fc:	68 41 6b 10 f0       	push   $0xf0106b41
f0101501:	68 44 6a 10 f0       	push   $0xf0106a44
f0101506:	68 17 03 00 00       	push   $0x317
f010150b:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101510:	e8 2b eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	6a 00                	push   $0x0
f010151a:	e8 5d fa ff ff       	call   f0100f7c <page_alloc>
f010151f:	89 c6                	mov    %eax,%esi
f0101521:	83 c4 10             	add    $0x10,%esp
f0101524:	85 c0                	test   %eax,%eax
f0101526:	75 19                	jne    f0101541 <mem_init+0x1de>
f0101528:	68 57 6b 10 f0       	push   $0xf0106b57
f010152d:	68 44 6a 10 f0       	push   $0xf0106a44
f0101532:	68 18 03 00 00       	push   $0x318
f0101537:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010153c:	e8 ff ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101541:	83 ec 0c             	sub    $0xc,%esp
f0101544:	6a 00                	push   $0x0
f0101546:	e8 31 fa ff ff       	call   f0100f7c <page_alloc>
f010154b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010154e:	83 c4 10             	add    $0x10,%esp
f0101551:	85 c0                	test   %eax,%eax
f0101553:	75 19                	jne    f010156e <mem_init+0x20b>
f0101555:	68 6d 6b 10 f0       	push   $0xf0106b6d
f010155a:	68 44 6a 10 f0       	push   $0xf0106a44
f010155f:	68 19 03 00 00       	push   $0x319
f0101564:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101569:	e8 d2 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010156e:	39 f7                	cmp    %esi,%edi
f0101570:	75 19                	jne    f010158b <mem_init+0x228>
f0101572:	68 83 6b 10 f0       	push   $0xf0106b83
f0101577:	68 44 6a 10 f0       	push   $0xf0106a44
f010157c:	68 1c 03 00 00       	push   $0x31c
f0101581:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101586:	e8 b5 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010158b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010158e:	39 c7                	cmp    %eax,%edi
f0101590:	74 04                	je     f0101596 <mem_init+0x233>
f0101592:	39 c6                	cmp    %eax,%esi
f0101594:	75 19                	jne    f01015af <mem_init+0x24c>
f0101596:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010159b:	68 44 6a 10 f0       	push   $0xf0106a44
f01015a0:	68 1d 03 00 00       	push   $0x31d
f01015a5:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01015aa:	e8 91 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015af:	8b 0d d0 fe 22 f0    	mov    0xf022fed0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015b5:	8b 15 c8 fe 22 f0    	mov    0xf022fec8,%edx
f01015bb:	c1 e2 0c             	shl    $0xc,%edx
f01015be:	89 f8                	mov    %edi,%eax
f01015c0:	29 c8                	sub    %ecx,%eax
f01015c2:	c1 f8 03             	sar    $0x3,%eax
f01015c5:	c1 e0 0c             	shl    $0xc,%eax
f01015c8:	39 d0                	cmp    %edx,%eax
f01015ca:	72 19                	jb     f01015e5 <mem_init+0x282>
f01015cc:	68 95 6b 10 f0       	push   $0xf0106b95
f01015d1:	68 44 6a 10 f0       	push   $0xf0106a44
f01015d6:	68 1e 03 00 00       	push   $0x31e
f01015db:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01015e0:	e8 5b ea ff ff       	call   f0100040 <_panic>
f01015e5:	89 f0                	mov    %esi,%eax
f01015e7:	29 c8                	sub    %ecx,%eax
f01015e9:	c1 f8 03             	sar    $0x3,%eax
f01015ec:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015ef:	39 c2                	cmp    %eax,%edx
f01015f1:	77 19                	ja     f010160c <mem_init+0x2a9>
f01015f3:	68 b2 6b 10 f0       	push   $0xf0106bb2
f01015f8:	68 44 6a 10 f0       	push   $0xf0106a44
f01015fd:	68 1f 03 00 00       	push   $0x31f
f0101602:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101607:	e8 34 ea ff ff       	call   f0100040 <_panic>
f010160c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010160f:	29 c8                	sub    %ecx,%eax
f0101611:	c1 f8 03             	sar    $0x3,%eax
f0101614:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101617:	39 c2                	cmp    %eax,%edx
f0101619:	77 19                	ja     f0101634 <mem_init+0x2d1>
f010161b:	68 cf 6b 10 f0       	push   $0xf0106bcf
f0101620:	68 44 6a 10 f0       	push   $0xf0106a44
f0101625:	68 20 03 00 00       	push   $0x320
f010162a:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010162f:	e8 0c ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101634:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f0101639:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010163c:	c7 05 60 f2 22 f0 00 	movl   $0x0,0xf022f260
f0101643:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101646:	83 ec 0c             	sub    $0xc,%esp
f0101649:	6a 00                	push   $0x0
f010164b:	e8 2c f9 ff ff       	call   f0100f7c <page_alloc>
f0101650:	83 c4 10             	add    $0x10,%esp
f0101653:	85 c0                	test   %eax,%eax
f0101655:	74 19                	je     f0101670 <mem_init+0x30d>
f0101657:	68 ec 6b 10 f0       	push   $0xf0106bec
f010165c:	68 44 6a 10 f0       	push   $0xf0106a44
f0101661:	68 27 03 00 00       	push   $0x327
f0101666:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010166b:	e8 d0 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101670:	83 ec 0c             	sub    $0xc,%esp
f0101673:	57                   	push   %edi
f0101674:	e8 71 f9 ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f0101679:	89 34 24             	mov    %esi,(%esp)
f010167c:	e8 69 f9 ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f0101681:	83 c4 04             	add    $0x4,%esp
f0101684:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101687:	e8 5e f9 ff ff       	call   f0100fea <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010168c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101693:	e8 e4 f8 ff ff       	call   f0100f7c <page_alloc>
f0101698:	89 c6                	mov    %eax,%esi
f010169a:	83 c4 10             	add    $0x10,%esp
f010169d:	85 c0                	test   %eax,%eax
f010169f:	75 19                	jne    f01016ba <mem_init+0x357>
f01016a1:	68 41 6b 10 f0       	push   $0xf0106b41
f01016a6:	68 44 6a 10 f0       	push   $0xf0106a44
f01016ab:	68 2e 03 00 00       	push   $0x32e
f01016b0:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01016b5:	e8 86 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016ba:	83 ec 0c             	sub    $0xc,%esp
f01016bd:	6a 00                	push   $0x0
f01016bf:	e8 b8 f8 ff ff       	call   f0100f7c <page_alloc>
f01016c4:	89 c7                	mov    %eax,%edi
f01016c6:	83 c4 10             	add    $0x10,%esp
f01016c9:	85 c0                	test   %eax,%eax
f01016cb:	75 19                	jne    f01016e6 <mem_init+0x383>
f01016cd:	68 57 6b 10 f0       	push   $0xf0106b57
f01016d2:	68 44 6a 10 f0       	push   $0xf0106a44
f01016d7:	68 2f 03 00 00       	push   $0x32f
f01016dc:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01016e1:	e8 5a e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016e6:	83 ec 0c             	sub    $0xc,%esp
f01016e9:	6a 00                	push   $0x0
f01016eb:	e8 8c f8 ff ff       	call   f0100f7c <page_alloc>
f01016f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016f3:	83 c4 10             	add    $0x10,%esp
f01016f6:	85 c0                	test   %eax,%eax
f01016f8:	75 19                	jne    f0101713 <mem_init+0x3b0>
f01016fa:	68 6d 6b 10 f0       	push   $0xf0106b6d
f01016ff:	68 44 6a 10 f0       	push   $0xf0106a44
f0101704:	68 30 03 00 00       	push   $0x330
f0101709:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010170e:	e8 2d e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101713:	39 fe                	cmp    %edi,%esi
f0101715:	75 19                	jne    f0101730 <mem_init+0x3cd>
f0101717:	68 83 6b 10 f0       	push   $0xf0106b83
f010171c:	68 44 6a 10 f0       	push   $0xf0106a44
f0101721:	68 32 03 00 00       	push   $0x332
f0101726:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010172b:	e8 10 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101730:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101733:	39 c6                	cmp    %eax,%esi
f0101735:	74 04                	je     f010173b <mem_init+0x3d8>
f0101737:	39 c7                	cmp    %eax,%edi
f0101739:	75 19                	jne    f0101754 <mem_init+0x3f1>
f010173b:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101740:	68 44 6a 10 f0       	push   $0xf0106a44
f0101745:	68 33 03 00 00       	push   $0x333
f010174a:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010174f:	e8 ec e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	6a 00                	push   $0x0
f0101759:	e8 1e f8 ff ff       	call   f0100f7c <page_alloc>
f010175e:	83 c4 10             	add    $0x10,%esp
f0101761:	85 c0                	test   %eax,%eax
f0101763:	74 19                	je     f010177e <mem_init+0x41b>
f0101765:	68 ec 6b 10 f0       	push   $0xf0106bec
f010176a:	68 44 6a 10 f0       	push   $0xf0106a44
f010176f:	68 34 03 00 00       	push   $0x334
f0101774:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101779:	e8 c2 e8 ff ff       	call   f0100040 <_panic>
f010177e:	89 f0                	mov    %esi,%eax
f0101780:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0101786:	c1 f8 03             	sar    $0x3,%eax
f0101789:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178c:	89 c2                	mov    %eax,%edx
f010178e:	c1 ea 0c             	shr    $0xc,%edx
f0101791:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0101797:	72 12                	jb     f01017ab <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101799:	50                   	push   %eax
f010179a:	68 64 64 10 f0       	push   $0xf0106464
f010179f:	6a 58                	push   $0x58
f01017a1:	68 2a 6a 10 f0       	push   $0xf0106a2a
f01017a6:	e8 95 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017ab:	83 ec 04             	sub    $0x4,%esp
f01017ae:	68 00 10 00 00       	push   $0x1000
f01017b3:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01017b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017ba:	50                   	push   %eax
f01017bb:	e8 b8 3f 00 00       	call   f0105778 <memset>
	page_free(pp0);
f01017c0:	89 34 24             	mov    %esi,(%esp)
f01017c3:	e8 22 f8 ff ff       	call   f0100fea <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017cf:	e8 a8 f7 ff ff       	call   f0100f7c <page_alloc>
f01017d4:	83 c4 10             	add    $0x10,%esp
f01017d7:	85 c0                	test   %eax,%eax
f01017d9:	75 19                	jne    f01017f4 <mem_init+0x491>
f01017db:	68 fb 6b 10 f0       	push   $0xf0106bfb
f01017e0:	68 44 6a 10 f0       	push   $0xf0106a44
f01017e5:	68 39 03 00 00       	push   $0x339
f01017ea:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01017ef:	e8 4c e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017f4:	39 c6                	cmp    %eax,%esi
f01017f6:	74 19                	je     f0101811 <mem_init+0x4ae>
f01017f8:	68 19 6c 10 f0       	push   $0xf0106c19
f01017fd:	68 44 6a 10 f0       	push   $0xf0106a44
f0101802:	68 3a 03 00 00       	push   $0x33a
f0101807:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010180c:	e8 2f e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101811:	89 f0                	mov    %esi,%eax
f0101813:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0101819:	c1 f8 03             	sar    $0x3,%eax
f010181c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010181f:	89 c2                	mov    %eax,%edx
f0101821:	c1 ea 0c             	shr    $0xc,%edx
f0101824:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f010182a:	72 12                	jb     f010183e <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010182c:	50                   	push   %eax
f010182d:	68 64 64 10 f0       	push   $0xf0106464
f0101832:	6a 58                	push   $0x58
f0101834:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0101839:	e8 02 e8 ff ff       	call   f0100040 <_panic>
f010183e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101844:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010184a:	80 38 00             	cmpb   $0x0,(%eax)
f010184d:	74 19                	je     f0101868 <mem_init+0x505>
f010184f:	68 29 6c 10 f0       	push   $0xf0106c29
f0101854:	68 44 6a 10 f0       	push   $0xf0106a44
f0101859:	68 3d 03 00 00       	push   $0x33d
f010185e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
f0101868:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010186b:	39 d0                	cmp    %edx,%eax
f010186d:	75 db                	jne    f010184a <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010186f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101872:	a3 60 f2 22 f0       	mov    %eax,0xf022f260

	// free the pages we took
	page_free(pp0);
f0101877:	83 ec 0c             	sub    $0xc,%esp
f010187a:	56                   	push   %esi
f010187b:	e8 6a f7 ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f0101880:	89 3c 24             	mov    %edi,(%esp)
f0101883:	e8 62 f7 ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f0101888:	83 c4 04             	add    $0x4,%esp
f010188b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010188e:	e8 57 f7 ff ff       	call   f0100fea <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101893:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f0101898:	83 c4 10             	add    $0x10,%esp
f010189b:	eb 05                	jmp    f01018a2 <mem_init+0x53f>
		--nfree;
f010189d:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018a0:	8b 00                	mov    (%eax),%eax
f01018a2:	85 c0                	test   %eax,%eax
f01018a4:	75 f7                	jne    f010189d <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f01018a6:	85 db                	test   %ebx,%ebx
f01018a8:	74 19                	je     f01018c3 <mem_init+0x560>
f01018aa:	68 33 6c 10 f0       	push   $0xf0106c33
f01018af:	68 44 6a 10 f0       	push   $0xf0106a44
f01018b4:	68 4a 03 00 00       	push   $0x34a
f01018b9:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01018be:	e8 7d e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01018c3:	83 ec 0c             	sub    $0xc,%esp
f01018c6:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01018cb:	e8 7d 1e 00 00       	call   f010374d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d7:	e8 a0 f6 ff ff       	call   f0100f7c <page_alloc>
f01018dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018df:	83 c4 10             	add    $0x10,%esp
f01018e2:	85 c0                	test   %eax,%eax
f01018e4:	75 19                	jne    f01018ff <mem_init+0x59c>
f01018e6:	68 41 6b 10 f0       	push   $0xf0106b41
f01018eb:	68 44 6a 10 f0       	push   $0xf0106a44
f01018f0:	68 af 03 00 00       	push   $0x3af
f01018f5:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01018fa:	e8 41 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018ff:	83 ec 0c             	sub    $0xc,%esp
f0101902:	6a 00                	push   $0x0
f0101904:	e8 73 f6 ff ff       	call   f0100f7c <page_alloc>
f0101909:	89 c3                	mov    %eax,%ebx
f010190b:	83 c4 10             	add    $0x10,%esp
f010190e:	85 c0                	test   %eax,%eax
f0101910:	75 19                	jne    f010192b <mem_init+0x5c8>
f0101912:	68 57 6b 10 f0       	push   $0xf0106b57
f0101917:	68 44 6a 10 f0       	push   $0xf0106a44
f010191c:	68 b0 03 00 00       	push   $0x3b0
f0101921:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101926:	e8 15 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010192b:	83 ec 0c             	sub    $0xc,%esp
f010192e:	6a 00                	push   $0x0
f0101930:	e8 47 f6 ff ff       	call   f0100f7c <page_alloc>
f0101935:	89 c6                	mov    %eax,%esi
f0101937:	83 c4 10             	add    $0x10,%esp
f010193a:	85 c0                	test   %eax,%eax
f010193c:	75 19                	jne    f0101957 <mem_init+0x5f4>
f010193e:	68 6d 6b 10 f0       	push   $0xf0106b6d
f0101943:	68 44 6a 10 f0       	push   $0xf0106a44
f0101948:	68 b1 03 00 00       	push   $0x3b1
f010194d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101952:	e8 e9 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101957:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010195a:	75 19                	jne    f0101975 <mem_init+0x612>
f010195c:	68 83 6b 10 f0       	push   $0xf0106b83
f0101961:	68 44 6a 10 f0       	push   $0xf0106a44
f0101966:	68 b4 03 00 00       	push   $0x3b4
f010196b:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101970:	e8 cb e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101975:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101978:	74 04                	je     f010197e <mem_init+0x61b>
f010197a:	39 c3                	cmp    %eax,%ebx
f010197c:	75 19                	jne    f0101997 <mem_init+0x634>
f010197e:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101983:	68 44 6a 10 f0       	push   $0xf0106a44
f0101988:	68 b5 03 00 00       	push   $0x3b5
f010198d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101992:	e8 a9 e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101997:	a1 60 f2 22 f0       	mov    0xf022f260,%eax
f010199c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010199f:	c7 05 60 f2 22 f0 00 	movl   $0x0,0xf022f260
f01019a6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019a9:	83 ec 0c             	sub    $0xc,%esp
f01019ac:	6a 00                	push   $0x0
f01019ae:	e8 c9 f5 ff ff       	call   f0100f7c <page_alloc>
f01019b3:	83 c4 10             	add    $0x10,%esp
f01019b6:	85 c0                	test   %eax,%eax
f01019b8:	74 19                	je     f01019d3 <mem_init+0x670>
f01019ba:	68 ec 6b 10 f0       	push   $0xf0106bec
f01019bf:	68 44 6a 10 f0       	push   $0xf0106a44
f01019c4:	68 bc 03 00 00       	push   $0x3bc
f01019c9:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019d3:	83 ec 04             	sub    $0x4,%esp
f01019d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019d9:	50                   	push   %eax
f01019da:	6a 00                	push   $0x0
f01019dc:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f01019e2:	e8 bf f7 ff ff       	call   f01011a6 <page_lookup>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	74 19                	je     f0101a07 <mem_init+0x6a4>
f01019ee:	68 e8 6e 10 f0       	push   $0xf0106ee8
f01019f3:	68 44 6a 10 f0       	push   $0xf0106a44
f01019f8:	68 bf 03 00 00       	push   $0x3bf
f01019fd:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101a02:	e8 39 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a07:	6a 02                	push   $0x2
f0101a09:	6a 00                	push   $0x0
f0101a0b:	53                   	push   %ebx
f0101a0c:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101a12:	e8 7b f8 ff ff       	call   f0101292 <page_insert>
f0101a17:	83 c4 10             	add    $0x10,%esp
f0101a1a:	85 c0                	test   %eax,%eax
f0101a1c:	78 19                	js     f0101a37 <mem_init+0x6d4>
f0101a1e:	68 20 6f 10 f0       	push   $0xf0106f20
f0101a23:	68 44 6a 10 f0       	push   $0xf0106a44
f0101a28:	68 c2 03 00 00       	push   $0x3c2
f0101a2d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101a32:	e8 09 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a37:	83 ec 0c             	sub    $0xc,%esp
f0101a3a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a3d:	e8 a8 f5 ff ff       	call   f0100fea <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a42:	6a 02                	push   $0x2
f0101a44:	6a 00                	push   $0x0
f0101a46:	53                   	push   %ebx
f0101a47:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101a4d:	e8 40 f8 ff ff       	call   f0101292 <page_insert>
f0101a52:	83 c4 20             	add    $0x20,%esp
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	74 19                	je     f0101a72 <mem_init+0x70f>
f0101a59:	68 50 6f 10 f0       	push   $0xf0106f50
f0101a5e:	68 44 6a 10 f0       	push   $0xf0106a44
f0101a63:	68 c6 03 00 00       	push   $0x3c6
f0101a68:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101a6d:	e8 ce e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a72:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a78:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
f0101a7d:	89 c1                	mov    %eax,%ecx
f0101a7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a82:	8b 17                	mov    (%edi),%edx
f0101a84:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a8d:	29 c8                	sub    %ecx,%eax
f0101a8f:	c1 f8 03             	sar    $0x3,%eax
f0101a92:	c1 e0 0c             	shl    $0xc,%eax
f0101a95:	39 c2                	cmp    %eax,%edx
f0101a97:	74 19                	je     f0101ab2 <mem_init+0x74f>
f0101a99:	68 80 6f 10 f0       	push   $0xf0106f80
f0101a9e:	68 44 6a 10 f0       	push   $0xf0106a44
f0101aa3:	68 c7 03 00 00       	push   $0x3c7
f0101aa8:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101aad:	e8 8e e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ab2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ab7:	89 f8                	mov    %edi,%eax
f0101ab9:	e8 5f f0 ff ff       	call   f0100b1d <check_va2pa>
f0101abe:	89 da                	mov    %ebx,%edx
f0101ac0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ac3:	c1 fa 03             	sar    $0x3,%edx
f0101ac6:	c1 e2 0c             	shl    $0xc,%edx
f0101ac9:	39 d0                	cmp    %edx,%eax
f0101acb:	74 19                	je     f0101ae6 <mem_init+0x783>
f0101acd:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0101ad2:	68 44 6a 10 f0       	push   $0xf0106a44
f0101ad7:	68 c8 03 00 00       	push   $0x3c8
f0101adc:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101ae1:	e8 5a e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ae6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101aeb:	74 19                	je     f0101b06 <mem_init+0x7a3>
f0101aed:	68 3e 6c 10 f0       	push   $0xf0106c3e
f0101af2:	68 44 6a 10 f0       	push   $0xf0106a44
f0101af7:	68 c9 03 00 00       	push   $0x3c9
f0101afc:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101b01:	e8 3a e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101b06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b09:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b0e:	74 19                	je     f0101b29 <mem_init+0x7c6>
f0101b10:	68 4f 6c 10 f0       	push   $0xf0106c4f
f0101b15:	68 44 6a 10 f0       	push   $0xf0106a44
f0101b1a:	68 ca 03 00 00       	push   $0x3ca
f0101b1f:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101b24:	e8 17 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b29:	6a 02                	push   $0x2
f0101b2b:	68 00 10 00 00       	push   $0x1000
f0101b30:	56                   	push   %esi
f0101b31:	57                   	push   %edi
f0101b32:	e8 5b f7 ff ff       	call   f0101292 <page_insert>
f0101b37:	83 c4 10             	add    $0x10,%esp
f0101b3a:	85 c0                	test   %eax,%eax
f0101b3c:	74 19                	je     f0101b57 <mem_init+0x7f4>
f0101b3e:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0101b43:	68 44 6a 10 f0       	push   $0xf0106a44
f0101b48:	68 cd 03 00 00       	push   $0x3cd
f0101b4d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101b52:	e8 e9 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b57:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b5c:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0101b61:	e8 b7 ef ff ff       	call   f0100b1d <check_va2pa>
f0101b66:	89 f2                	mov    %esi,%edx
f0101b68:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f0101b6e:	c1 fa 03             	sar    $0x3,%edx
f0101b71:	c1 e2 0c             	shl    $0xc,%edx
f0101b74:	39 d0                	cmp    %edx,%eax
f0101b76:	74 19                	je     f0101b91 <mem_init+0x82e>
f0101b78:	68 14 70 10 f0       	push   $0xf0107014
f0101b7d:	68 44 6a 10 f0       	push   $0xf0106a44
f0101b82:	68 ce 03 00 00       	push   $0x3ce
f0101b87:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101b8c:	e8 af e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b91:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b96:	74 19                	je     f0101bb1 <mem_init+0x84e>
f0101b98:	68 60 6c 10 f0       	push   $0xf0106c60
f0101b9d:	68 44 6a 10 f0       	push   $0xf0106a44
f0101ba2:	68 cf 03 00 00       	push   $0x3cf
f0101ba7:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101bac:	e8 8f e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101bb1:	83 ec 0c             	sub    $0xc,%esp
f0101bb4:	6a 00                	push   $0x0
f0101bb6:	e8 c1 f3 ff ff       	call   f0100f7c <page_alloc>
f0101bbb:	83 c4 10             	add    $0x10,%esp
f0101bbe:	85 c0                	test   %eax,%eax
f0101bc0:	74 19                	je     f0101bdb <mem_init+0x878>
f0101bc2:	68 ec 6b 10 f0       	push   $0xf0106bec
f0101bc7:	68 44 6a 10 f0       	push   $0xf0106a44
f0101bcc:	68 d2 03 00 00       	push   $0x3d2
f0101bd1:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101bd6:	e8 65 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bdb:	6a 02                	push   $0x2
f0101bdd:	68 00 10 00 00       	push   $0x1000
f0101be2:	56                   	push   %esi
f0101be3:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101be9:	e8 a4 f6 ff ff       	call   f0101292 <page_insert>
f0101bee:	83 c4 10             	add    $0x10,%esp
f0101bf1:	85 c0                	test   %eax,%eax
f0101bf3:	74 19                	je     f0101c0e <mem_init+0x8ab>
f0101bf5:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0101bfa:	68 44 6a 10 f0       	push   $0xf0106a44
f0101bff:	68 d5 03 00 00       	push   $0x3d5
f0101c04:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101c09:	e8 32 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c0e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c13:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0101c18:	e8 00 ef ff ff       	call   f0100b1d <check_va2pa>
f0101c1d:	89 f2                	mov    %esi,%edx
f0101c1f:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f0101c25:	c1 fa 03             	sar    $0x3,%edx
f0101c28:	c1 e2 0c             	shl    $0xc,%edx
f0101c2b:	39 d0                	cmp    %edx,%eax
f0101c2d:	74 19                	je     f0101c48 <mem_init+0x8e5>
f0101c2f:	68 14 70 10 f0       	push   $0xf0107014
f0101c34:	68 44 6a 10 f0       	push   $0xf0106a44
f0101c39:	68 d6 03 00 00       	push   $0x3d6
f0101c3e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101c43:	e8 f8 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c48:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c4d:	74 19                	je     f0101c68 <mem_init+0x905>
f0101c4f:	68 60 6c 10 f0       	push   $0xf0106c60
f0101c54:	68 44 6a 10 f0       	push   $0xf0106a44
f0101c59:	68 d7 03 00 00       	push   $0x3d7
f0101c5e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101c63:	e8 d8 e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c68:	83 ec 0c             	sub    $0xc,%esp
f0101c6b:	6a 00                	push   $0x0
f0101c6d:	e8 0a f3 ff ff       	call   f0100f7c <page_alloc>
f0101c72:	83 c4 10             	add    $0x10,%esp
f0101c75:	85 c0                	test   %eax,%eax
f0101c77:	74 19                	je     f0101c92 <mem_init+0x92f>
f0101c79:	68 ec 6b 10 f0       	push   $0xf0106bec
f0101c7e:	68 44 6a 10 f0       	push   $0xf0106a44
f0101c83:	68 db 03 00 00       	push   $0x3db
f0101c88:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101c8d:	e8 ae e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c92:	8b 15 cc fe 22 f0    	mov    0xf022fecc,%edx
f0101c98:	8b 02                	mov    (%edx),%eax
f0101c9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c9f:	89 c1                	mov    %eax,%ecx
f0101ca1:	c1 e9 0c             	shr    $0xc,%ecx
f0101ca4:	3b 0d c8 fe 22 f0    	cmp    0xf022fec8,%ecx
f0101caa:	72 15                	jb     f0101cc1 <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cac:	50                   	push   %eax
f0101cad:	68 64 64 10 f0       	push   $0xf0106464
f0101cb2:	68 de 03 00 00       	push   $0x3de
f0101cb7:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101cbc:	e8 7f e3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101cc1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cc9:	83 ec 04             	sub    $0x4,%esp
f0101ccc:	6a 00                	push   $0x0
f0101cce:	68 00 10 00 00       	push   $0x1000
f0101cd3:	52                   	push   %edx
f0101cd4:	e8 77 f3 ff ff       	call   f0101050 <pgdir_walk>
f0101cd9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cdc:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cdf:	83 c4 10             	add    $0x10,%esp
f0101ce2:	39 d0                	cmp    %edx,%eax
f0101ce4:	74 19                	je     f0101cff <mem_init+0x99c>
f0101ce6:	68 44 70 10 f0       	push   $0xf0107044
f0101ceb:	68 44 6a 10 f0       	push   $0xf0106a44
f0101cf0:	68 df 03 00 00       	push   $0x3df
f0101cf5:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101cfa:	e8 41 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cff:	6a 06                	push   $0x6
f0101d01:	68 00 10 00 00       	push   $0x1000
f0101d06:	56                   	push   %esi
f0101d07:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101d0d:	e8 80 f5 ff ff       	call   f0101292 <page_insert>
f0101d12:	83 c4 10             	add    $0x10,%esp
f0101d15:	85 c0                	test   %eax,%eax
f0101d17:	74 19                	je     f0101d32 <mem_init+0x9cf>
f0101d19:	68 84 70 10 f0       	push   $0xf0107084
f0101d1e:	68 44 6a 10 f0       	push   $0xf0106a44
f0101d23:	68 e2 03 00 00       	push   $0x3e2
f0101d28:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101d2d:	e8 0e e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d32:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
f0101d38:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3d:	89 f8                	mov    %edi,%eax
f0101d3f:	e8 d9 ed ff ff       	call   f0100b1d <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d44:	89 f2                	mov    %esi,%edx
f0101d46:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f0101d4c:	c1 fa 03             	sar    $0x3,%edx
f0101d4f:	c1 e2 0c             	shl    $0xc,%edx
f0101d52:	39 d0                	cmp    %edx,%eax
f0101d54:	74 19                	je     f0101d6f <mem_init+0xa0c>
f0101d56:	68 14 70 10 f0       	push   $0xf0107014
f0101d5b:	68 44 6a 10 f0       	push   $0xf0106a44
f0101d60:	68 e3 03 00 00       	push   $0x3e3
f0101d65:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101d6a:	e8 d1 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d6f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d74:	74 19                	je     f0101d8f <mem_init+0xa2c>
f0101d76:	68 60 6c 10 f0       	push   $0xf0106c60
f0101d7b:	68 44 6a 10 f0       	push   $0xf0106a44
f0101d80:	68 e4 03 00 00       	push   $0x3e4
f0101d85:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101d8a:	e8 b1 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d8f:	83 ec 04             	sub    $0x4,%esp
f0101d92:	6a 00                	push   $0x0
f0101d94:	68 00 10 00 00       	push   $0x1000
f0101d99:	57                   	push   %edi
f0101d9a:	e8 b1 f2 ff ff       	call   f0101050 <pgdir_walk>
f0101d9f:	83 c4 10             	add    $0x10,%esp
f0101da2:	f6 00 04             	testb  $0x4,(%eax)
f0101da5:	75 19                	jne    f0101dc0 <mem_init+0xa5d>
f0101da7:	68 c4 70 10 f0       	push   $0xf01070c4
f0101dac:	68 44 6a 10 f0       	push   $0xf0106a44
f0101db1:	68 e5 03 00 00       	push   $0x3e5
f0101db6:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101dbb:	e8 80 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dc0:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0101dc5:	f6 00 04             	testb  $0x4,(%eax)
f0101dc8:	75 19                	jne    f0101de3 <mem_init+0xa80>
f0101dca:	68 71 6c 10 f0       	push   $0xf0106c71
f0101dcf:	68 44 6a 10 f0       	push   $0xf0106a44
f0101dd4:	68 e6 03 00 00       	push   $0x3e6
f0101dd9:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101dde:	e8 5d e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101de3:	6a 02                	push   $0x2
f0101de5:	68 00 10 00 00       	push   $0x1000
f0101dea:	56                   	push   %esi
f0101deb:	50                   	push   %eax
f0101dec:	e8 a1 f4 ff ff       	call   f0101292 <page_insert>
f0101df1:	83 c4 10             	add    $0x10,%esp
f0101df4:	85 c0                	test   %eax,%eax
f0101df6:	74 19                	je     f0101e11 <mem_init+0xaae>
f0101df8:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0101dfd:	68 44 6a 10 f0       	push   $0xf0106a44
f0101e02:	68 e9 03 00 00       	push   $0x3e9
f0101e07:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101e0c:	e8 2f e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e11:	83 ec 04             	sub    $0x4,%esp
f0101e14:	6a 00                	push   $0x0
f0101e16:	68 00 10 00 00       	push   $0x1000
f0101e1b:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101e21:	e8 2a f2 ff ff       	call   f0101050 <pgdir_walk>
f0101e26:	83 c4 10             	add    $0x10,%esp
f0101e29:	f6 00 02             	testb  $0x2,(%eax)
f0101e2c:	75 19                	jne    f0101e47 <mem_init+0xae4>
f0101e2e:	68 f8 70 10 f0       	push   $0xf01070f8
f0101e33:	68 44 6a 10 f0       	push   $0xf0106a44
f0101e38:	68 ea 03 00 00       	push   $0x3ea
f0101e3d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101e42:	e8 f9 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e47:	83 ec 04             	sub    $0x4,%esp
f0101e4a:	6a 00                	push   $0x0
f0101e4c:	68 00 10 00 00       	push   $0x1000
f0101e51:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101e57:	e8 f4 f1 ff ff       	call   f0101050 <pgdir_walk>
f0101e5c:	83 c4 10             	add    $0x10,%esp
f0101e5f:	f6 00 04             	testb  $0x4,(%eax)
f0101e62:	74 19                	je     f0101e7d <mem_init+0xb1a>
f0101e64:	68 2c 71 10 f0       	push   $0xf010712c
f0101e69:	68 44 6a 10 f0       	push   $0xf0106a44
f0101e6e:	68 eb 03 00 00       	push   $0x3eb
f0101e73:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101e78:	e8 c3 e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e7d:	6a 02                	push   $0x2
f0101e7f:	68 00 00 40 00       	push   $0x400000
f0101e84:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e87:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101e8d:	e8 00 f4 ff ff       	call   f0101292 <page_insert>
f0101e92:	83 c4 10             	add    $0x10,%esp
f0101e95:	85 c0                	test   %eax,%eax
f0101e97:	78 19                	js     f0101eb2 <mem_init+0xb4f>
f0101e99:	68 64 71 10 f0       	push   $0xf0107164
f0101e9e:	68 44 6a 10 f0       	push   $0xf0106a44
f0101ea3:	68 ee 03 00 00       	push   $0x3ee
f0101ea8:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101ead:	e8 8e e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101eb2:	6a 02                	push   $0x2
f0101eb4:	68 00 10 00 00       	push   $0x1000
f0101eb9:	53                   	push   %ebx
f0101eba:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101ec0:	e8 cd f3 ff ff       	call   f0101292 <page_insert>
f0101ec5:	83 c4 10             	add    $0x10,%esp
f0101ec8:	85 c0                	test   %eax,%eax
f0101eca:	74 19                	je     f0101ee5 <mem_init+0xb82>
f0101ecc:	68 9c 71 10 f0       	push   $0xf010719c
f0101ed1:	68 44 6a 10 f0       	push   $0xf0106a44
f0101ed6:	68 f1 03 00 00       	push   $0x3f1
f0101edb:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101ee0:	e8 5b e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ee5:	83 ec 04             	sub    $0x4,%esp
f0101ee8:	6a 00                	push   $0x0
f0101eea:	68 00 10 00 00       	push   $0x1000
f0101eef:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0101ef5:	e8 56 f1 ff ff       	call   f0101050 <pgdir_walk>
f0101efa:	83 c4 10             	add    $0x10,%esp
f0101efd:	f6 00 04             	testb  $0x4,(%eax)
f0101f00:	74 19                	je     f0101f1b <mem_init+0xbb8>
f0101f02:	68 2c 71 10 f0       	push   $0xf010712c
f0101f07:	68 44 6a 10 f0       	push   $0xf0106a44
f0101f0c:	68 f2 03 00 00       	push   $0x3f2
f0101f11:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101f16:	e8 25 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f1b:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
f0101f21:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f26:	89 f8                	mov    %edi,%eax
f0101f28:	e8 f0 eb ff ff       	call   f0100b1d <check_va2pa>
f0101f2d:	89 c1                	mov    %eax,%ecx
f0101f2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f32:	89 d8                	mov    %ebx,%eax
f0101f34:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0101f3a:	c1 f8 03             	sar    $0x3,%eax
f0101f3d:	c1 e0 0c             	shl    $0xc,%eax
f0101f40:	39 c1                	cmp    %eax,%ecx
f0101f42:	74 19                	je     f0101f5d <mem_init+0xbfa>
f0101f44:	68 d8 71 10 f0       	push   $0xf01071d8
f0101f49:	68 44 6a 10 f0       	push   $0xf0106a44
f0101f4e:	68 f5 03 00 00       	push   $0x3f5
f0101f53:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101f58:	e8 e3 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f5d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f62:	89 f8                	mov    %edi,%eax
f0101f64:	e8 b4 eb ff ff       	call   f0100b1d <check_va2pa>
f0101f69:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f6c:	74 19                	je     f0101f87 <mem_init+0xc24>
f0101f6e:	68 04 72 10 f0       	push   $0xf0107204
f0101f73:	68 44 6a 10 f0       	push   $0xf0106a44
f0101f78:	68 f6 03 00 00       	push   $0x3f6
f0101f7d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101f82:	e8 b9 e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f87:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f8c:	74 19                	je     f0101fa7 <mem_init+0xc44>
f0101f8e:	68 87 6c 10 f0       	push   $0xf0106c87
f0101f93:	68 44 6a 10 f0       	push   $0xf0106a44
f0101f98:	68 f8 03 00 00       	push   $0x3f8
f0101f9d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101fa2:	e8 99 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fa7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fac:	74 19                	je     f0101fc7 <mem_init+0xc64>
f0101fae:	68 98 6c 10 f0       	push   $0xf0106c98
f0101fb3:	68 44 6a 10 f0       	push   $0xf0106a44
f0101fb8:	68 f9 03 00 00       	push   $0x3f9
f0101fbd:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101fc2:	e8 79 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101fc7:	83 ec 0c             	sub    $0xc,%esp
f0101fca:	6a 00                	push   $0x0
f0101fcc:	e8 ab ef ff ff       	call   f0100f7c <page_alloc>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	85 c0                	test   %eax,%eax
f0101fd6:	74 04                	je     f0101fdc <mem_init+0xc79>
f0101fd8:	39 c6                	cmp    %eax,%esi
f0101fda:	74 19                	je     f0101ff5 <mem_init+0xc92>
f0101fdc:	68 34 72 10 f0       	push   $0xf0107234
f0101fe1:	68 44 6a 10 f0       	push   $0xf0106a44
f0101fe6:	68 fc 03 00 00       	push   $0x3fc
f0101feb:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ff5:	83 ec 08             	sub    $0x8,%esp
f0101ff8:	6a 00                	push   $0x0
f0101ffa:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102000:	e8 3c f2 ff ff       	call   f0101241 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102005:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
f010200b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102010:	89 f8                	mov    %edi,%eax
f0102012:	e8 06 eb ff ff       	call   f0100b1d <check_va2pa>
f0102017:	83 c4 10             	add    $0x10,%esp
f010201a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201d:	74 19                	je     f0102038 <mem_init+0xcd5>
f010201f:	68 58 72 10 f0       	push   $0xf0107258
f0102024:	68 44 6a 10 f0       	push   $0xf0106a44
f0102029:	68 00 04 00 00       	push   $0x400
f010202e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102033:	e8 08 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102038:	ba 00 10 00 00       	mov    $0x1000,%edx
f010203d:	89 f8                	mov    %edi,%eax
f010203f:	e8 d9 ea ff ff       	call   f0100b1d <check_va2pa>
f0102044:	89 da                	mov    %ebx,%edx
f0102046:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f010204c:	c1 fa 03             	sar    $0x3,%edx
f010204f:	c1 e2 0c             	shl    $0xc,%edx
f0102052:	39 d0                	cmp    %edx,%eax
f0102054:	74 19                	je     f010206f <mem_init+0xd0c>
f0102056:	68 04 72 10 f0       	push   $0xf0107204
f010205b:	68 44 6a 10 f0       	push   $0xf0106a44
f0102060:	68 01 04 00 00       	push   $0x401
f0102065:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010206a:	e8 d1 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010206f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102074:	74 19                	je     f010208f <mem_init+0xd2c>
f0102076:	68 3e 6c 10 f0       	push   $0xf0106c3e
f010207b:	68 44 6a 10 f0       	push   $0xf0106a44
f0102080:	68 02 04 00 00       	push   $0x402
f0102085:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010208a:	e8 b1 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010208f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102094:	74 19                	je     f01020af <mem_init+0xd4c>
f0102096:	68 98 6c 10 f0       	push   $0xf0106c98
f010209b:	68 44 6a 10 f0       	push   $0xf0106a44
f01020a0:	68 03 04 00 00       	push   $0x403
f01020a5:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01020aa:	e8 91 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020af:	6a 00                	push   $0x0
f01020b1:	68 00 10 00 00       	push   $0x1000
f01020b6:	53                   	push   %ebx
f01020b7:	57                   	push   %edi
f01020b8:	e8 d5 f1 ff ff       	call   f0101292 <page_insert>
f01020bd:	83 c4 10             	add    $0x10,%esp
f01020c0:	85 c0                	test   %eax,%eax
f01020c2:	74 19                	je     f01020dd <mem_init+0xd7a>
f01020c4:	68 7c 72 10 f0       	push   $0xf010727c
f01020c9:	68 44 6a 10 f0       	push   $0xf0106a44
f01020ce:	68 06 04 00 00       	push   $0x406
f01020d3:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01020d8:	e8 63 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020dd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020e2:	75 19                	jne    f01020fd <mem_init+0xd9a>
f01020e4:	68 a9 6c 10 f0       	push   $0xf0106ca9
f01020e9:	68 44 6a 10 f0       	push   $0xf0106a44
f01020ee:	68 07 04 00 00       	push   $0x407
f01020f3:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01020f8:	e8 43 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020fd:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102100:	74 19                	je     f010211b <mem_init+0xdb8>
f0102102:	68 b5 6c 10 f0       	push   $0xf0106cb5
f0102107:	68 44 6a 10 f0       	push   $0xf0106a44
f010210c:	68 08 04 00 00       	push   $0x408
f0102111:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102116:	e8 25 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010211b:	83 ec 08             	sub    $0x8,%esp
f010211e:	68 00 10 00 00       	push   $0x1000
f0102123:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102129:	e8 13 f1 ff ff       	call   f0101241 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010212e:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
f0102134:	ba 00 00 00 00       	mov    $0x0,%edx
f0102139:	89 f8                	mov    %edi,%eax
f010213b:	e8 dd e9 ff ff       	call   f0100b1d <check_va2pa>
f0102140:	83 c4 10             	add    $0x10,%esp
f0102143:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102146:	74 19                	je     f0102161 <mem_init+0xdfe>
f0102148:	68 58 72 10 f0       	push   $0xf0107258
f010214d:	68 44 6a 10 f0       	push   $0xf0106a44
f0102152:	68 0c 04 00 00       	push   $0x40c
f0102157:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010215c:	e8 df de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102161:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102166:	89 f8                	mov    %edi,%eax
f0102168:	e8 b0 e9 ff ff       	call   f0100b1d <check_va2pa>
f010216d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102170:	74 19                	je     f010218b <mem_init+0xe28>
f0102172:	68 b4 72 10 f0       	push   $0xf01072b4
f0102177:	68 44 6a 10 f0       	push   $0xf0106a44
f010217c:	68 0d 04 00 00       	push   $0x40d
f0102181:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102186:	e8 b5 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010218b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102190:	74 19                	je     f01021ab <mem_init+0xe48>
f0102192:	68 ca 6c 10 f0       	push   $0xf0106cca
f0102197:	68 44 6a 10 f0       	push   $0xf0106a44
f010219c:	68 0e 04 00 00       	push   $0x40e
f01021a1:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01021a6:	e8 95 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021ab:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021b0:	74 19                	je     f01021cb <mem_init+0xe68>
f01021b2:	68 98 6c 10 f0       	push   $0xf0106c98
f01021b7:	68 44 6a 10 f0       	push   $0xf0106a44
f01021bc:	68 0f 04 00 00       	push   $0x40f
f01021c1:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01021c6:	e8 75 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01021cb:	83 ec 0c             	sub    $0xc,%esp
f01021ce:	6a 00                	push   $0x0
f01021d0:	e8 a7 ed ff ff       	call   f0100f7c <page_alloc>
f01021d5:	83 c4 10             	add    $0x10,%esp
f01021d8:	85 c0                	test   %eax,%eax
f01021da:	74 04                	je     f01021e0 <mem_init+0xe7d>
f01021dc:	39 c3                	cmp    %eax,%ebx
f01021de:	74 19                	je     f01021f9 <mem_init+0xe96>
f01021e0:	68 dc 72 10 f0       	push   $0xf01072dc
f01021e5:	68 44 6a 10 f0       	push   $0xf0106a44
f01021ea:	68 12 04 00 00       	push   $0x412
f01021ef:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01021f4:	e8 47 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021f9:	83 ec 0c             	sub    $0xc,%esp
f01021fc:	6a 00                	push   $0x0
f01021fe:	e8 79 ed ff ff       	call   f0100f7c <page_alloc>
f0102203:	83 c4 10             	add    $0x10,%esp
f0102206:	85 c0                	test   %eax,%eax
f0102208:	74 19                	je     f0102223 <mem_init+0xec0>
f010220a:	68 ec 6b 10 f0       	push   $0xf0106bec
f010220f:	68 44 6a 10 f0       	push   $0xf0106a44
f0102214:	68 15 04 00 00       	push   $0x415
f0102219:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010221e:	e8 1d de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102223:	8b 0d cc fe 22 f0    	mov    0xf022fecc,%ecx
f0102229:	8b 11                	mov    (%ecx),%edx
f010222b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102234:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f010223a:	c1 f8 03             	sar    $0x3,%eax
f010223d:	c1 e0 0c             	shl    $0xc,%eax
f0102240:	39 c2                	cmp    %eax,%edx
f0102242:	74 19                	je     f010225d <mem_init+0xefa>
f0102244:	68 80 6f 10 f0       	push   $0xf0106f80
f0102249:	68 44 6a 10 f0       	push   $0xf0106a44
f010224e:	68 18 04 00 00       	push   $0x418
f0102253:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102258:	e8 e3 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010225d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102263:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102266:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010226b:	74 19                	je     f0102286 <mem_init+0xf23>
f010226d:	68 4f 6c 10 f0       	push   $0xf0106c4f
f0102272:	68 44 6a 10 f0       	push   $0xf0106a44
f0102277:	68 1a 04 00 00       	push   $0x41a
f010227c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102281:	e8 ba dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102286:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102289:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010228f:	83 ec 0c             	sub    $0xc,%esp
f0102292:	50                   	push   %eax
f0102293:	e8 52 ed ff ff       	call   f0100fea <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102298:	83 c4 0c             	add    $0xc,%esp
f010229b:	6a 01                	push   $0x1
f010229d:	68 00 10 40 00       	push   $0x401000
f01022a2:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f01022a8:	e8 a3 ed ff ff       	call   f0101050 <pgdir_walk>
f01022ad:	89 c7                	mov    %eax,%edi
f01022af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022b2:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f01022b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022ba:	8b 40 04             	mov    0x4(%eax),%eax
f01022bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022c2:	8b 0d c8 fe 22 f0    	mov    0xf022fec8,%ecx
f01022c8:	89 c2                	mov    %eax,%edx
f01022ca:	c1 ea 0c             	shr    $0xc,%edx
f01022cd:	83 c4 10             	add    $0x10,%esp
f01022d0:	39 ca                	cmp    %ecx,%edx
f01022d2:	72 15                	jb     f01022e9 <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022d4:	50                   	push   %eax
f01022d5:	68 64 64 10 f0       	push   $0xf0106464
f01022da:	68 21 04 00 00       	push   $0x421
f01022df:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01022e4:	e8 57 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022e9:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01022ee:	39 c7                	cmp    %eax,%edi
f01022f0:	74 19                	je     f010230b <mem_init+0xfa8>
f01022f2:	68 db 6c 10 f0       	push   $0xf0106cdb
f01022f7:	68 44 6a 10 f0       	push   $0xf0106a44
f01022fc:	68 22 04 00 00       	push   $0x422
f0102301:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102306:	e8 35 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010230b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010230e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102315:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102318:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010231e:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0102324:	c1 f8 03             	sar    $0x3,%eax
f0102327:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010232a:	89 c2                	mov    %eax,%edx
f010232c:	c1 ea 0c             	shr    $0xc,%edx
f010232f:	39 d1                	cmp    %edx,%ecx
f0102331:	77 12                	ja     f0102345 <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102333:	50                   	push   %eax
f0102334:	68 64 64 10 f0       	push   $0xf0106464
f0102339:	6a 58                	push   $0x58
f010233b:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0102340:	e8 fb dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102345:	83 ec 04             	sub    $0x4,%esp
f0102348:	68 00 10 00 00       	push   $0x1000
f010234d:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102352:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102357:	50                   	push   %eax
f0102358:	e8 1b 34 00 00       	call   f0105778 <memset>
	page_free(pp0);
f010235d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102360:	89 3c 24             	mov    %edi,(%esp)
f0102363:	e8 82 ec ff ff       	call   f0100fea <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102368:	83 c4 0c             	add    $0xc,%esp
f010236b:	6a 01                	push   $0x1
f010236d:	6a 00                	push   $0x0
f010236f:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102375:	e8 d6 ec ff ff       	call   f0101050 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010237a:	89 fa                	mov    %edi,%edx
f010237c:	2b 15 d0 fe 22 f0    	sub    0xf022fed0,%edx
f0102382:	c1 fa 03             	sar    $0x3,%edx
f0102385:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102388:	89 d0                	mov    %edx,%eax
f010238a:	c1 e8 0c             	shr    $0xc,%eax
f010238d:	83 c4 10             	add    $0x10,%esp
f0102390:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f0102396:	72 12                	jb     f01023aa <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102398:	52                   	push   %edx
f0102399:	68 64 64 10 f0       	push   $0xf0106464
f010239e:	6a 58                	push   $0x58
f01023a0:	68 2a 6a 10 f0       	push   $0xf0106a2a
f01023a5:	e8 96 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01023aa:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023b3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023b9:	f6 00 01             	testb  $0x1,(%eax)
f01023bc:	74 19                	je     f01023d7 <mem_init+0x1074>
f01023be:	68 f3 6c 10 f0       	push   $0xf0106cf3
f01023c3:	68 44 6a 10 f0       	push   $0xf0106a44
f01023c8:	68 2c 04 00 00       	push   $0x42c
f01023cd:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01023d2:	e8 69 dc ff ff       	call   f0100040 <_panic>
f01023d7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023da:	39 d0                	cmp    %edx,%eax
f01023dc:	75 db                	jne    f01023b9 <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023de:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f01023e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023ec:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01023f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01023f5:	89 0d 60 f2 22 f0    	mov    %ecx,0xf022f260

	// free the pages we took
	page_free(pp0);
f01023fb:	83 ec 0c             	sub    $0xc,%esp
f01023fe:	50                   	push   %eax
f01023ff:	e8 e6 eb ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f0102404:	89 1c 24             	mov    %ebx,(%esp)
f0102407:	e8 de eb ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f010240c:	89 34 24             	mov    %esi,(%esp)
f010240f:	e8 d6 eb ff ff       	call   f0100fea <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102414:	83 c4 08             	add    $0x8,%esp
f0102417:	68 01 10 00 00       	push   $0x1001
f010241c:	6a 00                	push   $0x0
f010241e:	e8 dd ee ff ff       	call   f0101300 <mmio_map_region>
f0102423:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102425:	83 c4 08             	add    $0x8,%esp
f0102428:	68 00 10 00 00       	push   $0x1000
f010242d:	6a 00                	push   $0x0
f010242f:	e8 cc ee ff ff       	call   f0101300 <mmio_map_region>
f0102434:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102436:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010243c:	83 c4 10             	add    $0x10,%esp
f010243f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102444:	77 08                	ja     f010244e <mem_init+0x10eb>
f0102446:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010244c:	77 19                	ja     f0102467 <mem_init+0x1104>
f010244e:	68 00 73 10 f0       	push   $0xf0107300
f0102453:	68 44 6a 10 f0       	push   $0xf0106a44
f0102458:	68 3c 04 00 00       	push   $0x43c
f010245d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102462:	e8 d9 db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102467:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010246d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102473:	77 08                	ja     f010247d <mem_init+0x111a>
f0102475:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010247b:	77 19                	ja     f0102496 <mem_init+0x1133>
f010247d:	68 28 73 10 f0       	push   $0xf0107328
f0102482:	68 44 6a 10 f0       	push   $0xf0106a44
f0102487:	68 3d 04 00 00       	push   $0x43d
f010248c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102491:	e8 aa db ff ff       	call   f0100040 <_panic>
f0102496:	89 da                	mov    %ebx,%edx
f0102498:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010249a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024a0:	74 19                	je     f01024bb <mem_init+0x1158>
f01024a2:	68 50 73 10 f0       	push   $0xf0107350
f01024a7:	68 44 6a 10 f0       	push   $0xf0106a44
f01024ac:	68 3f 04 00 00       	push   $0x43f
f01024b1:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01024bb:	39 c6                	cmp    %eax,%esi
f01024bd:	73 19                	jae    f01024d8 <mem_init+0x1175>
f01024bf:	68 0a 6d 10 f0       	push   $0xf0106d0a
f01024c4:	68 44 6a 10 f0       	push   $0xf0106a44
f01024c9:	68 41 04 00 00       	push   $0x441
f01024ce:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01024d3:	e8 68 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024d8:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi
f01024de:	89 da                	mov    %ebx,%edx
f01024e0:	89 f8                	mov    %edi,%eax
f01024e2:	e8 36 e6 ff ff       	call   f0100b1d <check_va2pa>
f01024e7:	85 c0                	test   %eax,%eax
f01024e9:	74 19                	je     f0102504 <mem_init+0x11a1>
f01024eb:	68 78 73 10 f0       	push   $0xf0107378
f01024f0:	68 44 6a 10 f0       	push   $0xf0106a44
f01024f5:	68 43 04 00 00       	push   $0x443
f01024fa:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102504:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010250a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010250d:	89 c2                	mov    %eax,%edx
f010250f:	89 f8                	mov    %edi,%eax
f0102511:	e8 07 e6 ff ff       	call   f0100b1d <check_va2pa>
f0102516:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010251b:	74 19                	je     f0102536 <mem_init+0x11d3>
f010251d:	68 9c 73 10 f0       	push   $0xf010739c
f0102522:	68 44 6a 10 f0       	push   $0xf0106a44
f0102527:	68 44 04 00 00       	push   $0x444
f010252c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102536:	89 f2                	mov    %esi,%edx
f0102538:	89 f8                	mov    %edi,%eax
f010253a:	e8 de e5 ff ff       	call   f0100b1d <check_va2pa>
f010253f:	85 c0                	test   %eax,%eax
f0102541:	74 19                	je     f010255c <mem_init+0x11f9>
f0102543:	68 cc 73 10 f0       	push   $0xf01073cc
f0102548:	68 44 6a 10 f0       	push   $0xf0106a44
f010254d:	68 45 04 00 00       	push   $0x445
f0102552:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010255c:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102562:	89 f8                	mov    %edi,%eax
f0102564:	e8 b4 e5 ff ff       	call   f0100b1d <check_va2pa>
f0102569:	83 f8 ff             	cmp    $0xffffffff,%eax
f010256c:	74 19                	je     f0102587 <mem_init+0x1224>
f010256e:	68 f0 73 10 f0       	push   $0xf01073f0
f0102573:	68 44 6a 10 f0       	push   $0xf0106a44
f0102578:	68 46 04 00 00       	push   $0x446
f010257d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102582:	e8 b9 da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102587:	83 ec 04             	sub    $0x4,%esp
f010258a:	6a 00                	push   $0x0
f010258c:	53                   	push   %ebx
f010258d:	57                   	push   %edi
f010258e:	e8 bd ea ff ff       	call   f0101050 <pgdir_walk>
f0102593:	83 c4 10             	add    $0x10,%esp
f0102596:	f6 00 1a             	testb  $0x1a,(%eax)
f0102599:	75 19                	jne    f01025b4 <mem_init+0x1251>
f010259b:	68 1c 74 10 f0       	push   $0xf010741c
f01025a0:	68 44 6a 10 f0       	push   $0xf0106a44
f01025a5:	68 48 04 00 00       	push   $0x448
f01025aa:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01025af:	e8 8c da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01025b4:	83 ec 04             	sub    $0x4,%esp
f01025b7:	6a 00                	push   $0x0
f01025b9:	53                   	push   %ebx
f01025ba:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f01025c0:	e8 8b ea ff ff       	call   f0101050 <pgdir_walk>
f01025c5:	83 c4 10             	add    $0x10,%esp
f01025c8:	f6 00 04             	testb  $0x4,(%eax)
f01025cb:	74 19                	je     f01025e6 <mem_init+0x1283>
f01025cd:	68 60 74 10 f0       	push   $0xf0107460
f01025d2:	68 44 6a 10 f0       	push   $0xf0106a44
f01025d7:	68 49 04 00 00       	push   $0x449
f01025dc:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01025e1:	e8 5a da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025e6:	83 ec 04             	sub    $0x4,%esp
f01025e9:	6a 00                	push   $0x0
f01025eb:	53                   	push   %ebx
f01025ec:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f01025f2:	e8 59 ea ff ff       	call   f0101050 <pgdir_walk>
f01025f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01025fd:	83 c4 0c             	add    $0xc,%esp
f0102600:	6a 00                	push   $0x0
f0102602:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102605:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f010260b:	e8 40 ea ff ff       	call   f0101050 <pgdir_walk>
f0102610:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102616:	83 c4 0c             	add    $0xc,%esp
f0102619:	6a 00                	push   $0x0
f010261b:	56                   	push   %esi
f010261c:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102622:	e8 29 ea ff ff       	call   f0101050 <pgdir_walk>
f0102627:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010262d:	c7 04 24 1c 6d 10 f0 	movl   $0xf0106d1c,(%esp)
f0102634:	e8 14 11 00 00       	call   f010374d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102639:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010263e:	83 c4 10             	add    $0x10,%esp
f0102641:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102646:	77 15                	ja     f010265d <mem_init+0x12fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102648:	50                   	push   %eax
f0102649:	68 88 64 10 f0       	push   $0xf0106488
f010264e:	68 c8 00 00 00       	push   $0xc8
f0102653:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102658:	e8 e3 d9 ff ff       	call   f0100040 <_panic>
f010265d:	83 ec 08             	sub    $0x8,%esp
f0102660:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102662:	05 00 00 00 10       	add    $0x10000000,%eax
f0102667:	50                   	push   %eax
f0102668:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010266d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102672:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0102677:	e8 b1 ea ff ff       	call   f010112d <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010267c:	a1 68 f2 22 f0       	mov    0xf022f268,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102681:	83 c4 10             	add    $0x10,%esp
f0102684:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102689:	77 15                	ja     f01026a0 <mem_init+0x133d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010268b:	50                   	push   %eax
f010268c:	68 88 64 10 f0       	push   $0xf0106488
f0102691:	68 d0 00 00 00       	push   $0xd0
f0102696:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010269b:	e8 a0 d9 ff ff       	call   f0100040 <_panic>
f01026a0:	83 ec 08             	sub    $0x8,%esp
f01026a3:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026a5:	05 00 00 00 10       	add    $0x10000000,%eax
f01026aa:	50                   	push   %eax
f01026ab:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026b0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026b5:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f01026ba:	e8 6e ea ff ff       	call   f010112d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026bf:	83 c4 10             	add    $0x10,%esp
f01026c2:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01026c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026cc:	77 15                	ja     f01026e3 <mem_init+0x1380>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ce:	50                   	push   %eax
f01026cf:	68 88 64 10 f0       	push   $0xf0106488
f01026d4:	68 dc 00 00 00       	push   $0xdc
f01026d9:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01026de:	e8 5d d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026e3:	83 ec 08             	sub    $0x8,%esp
f01026e6:	6a 02                	push   $0x2
f01026e8:	68 00 60 11 00       	push   $0x116000
f01026ed:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026f2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026f7:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f01026fc:	e8 2c ea ff ff       	call   f010112d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102701:	83 c4 08             	add    $0x8,%esp
f0102704:	6a 02                	push   $0x2
f0102706:	6a 00                	push   $0x0
f0102708:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010270d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102712:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0102717:	e8 11 ea ff ff       	call   f010112d <boot_map_region>
f010271c:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f0102723:	83 c4 10             	add    $0x10,%esp
f0102726:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f010272b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102730:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102736:	77 15                	ja     f010274d <mem_init+0x13ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102738:	53                   	push   %ebx
f0102739:	68 88 64 10 f0       	push   $0xf0106488
f010273e:	68 20 01 00 00       	push   $0x120
f0102743:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102748:	e8 f3 d8 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
                boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP),
f010274d:	83 ec 08             	sub    $0x8,%esp
f0102750:	6a 02                	push   $0x2
f0102752:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102758:	50                   	push   %eax
f0102759:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010275e:	89 f2                	mov    %esi,%edx
f0102760:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
f0102765:	e8 c3 e9 ff ff       	call   f010112d <boot_map_region>
f010276a:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102770:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0; i < NCPU; i++) {
f0102776:	83 c4 10             	add    $0x10,%esp
f0102779:	81 fb 00 10 27 f0    	cmp    $0xf0271000,%ebx
f010277f:	75 af                	jne    f0102730 <mem_init+0x13cd>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102781:	8b 3d cc fe 22 f0    	mov    0xf022fecc,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102787:	a1 c8 fe 22 f0       	mov    0xf022fec8,%eax
f010278c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010278f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102796:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010279b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010279e:	8b 35 d0 fe 22 f0    	mov    0xf022fed0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a4:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027a7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027ac:	eb 55                	jmp    f0102803 <mem_init+0x14a0>
f01027ae:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027b4:	89 f8                	mov    %edi,%eax
f01027b6:	e8 62 e3 ff ff       	call   f0100b1d <check_va2pa>
f01027bb:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027c2:	77 15                	ja     f01027d9 <mem_init+0x1476>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027c4:	56                   	push   %esi
f01027c5:	68 88 64 10 f0       	push   $0xf0106488
f01027ca:	68 62 03 00 00       	push   $0x362
f01027cf:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01027d4:	e8 67 d8 ff ff       	call   f0100040 <_panic>
f01027d9:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027e0:	39 d0                	cmp    %edx,%eax
f01027e2:	74 19                	je     f01027fd <mem_init+0x149a>
f01027e4:	68 94 74 10 f0       	push   $0xf0107494
f01027e9:	68 44 6a 10 f0       	push   $0xf0106a44
f01027ee:	68 62 03 00 00       	push   $0x362
f01027f3:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01027f8:	e8 43 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102803:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102806:	77 a6                	ja     f01027ae <mem_init+0x144b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102808:	8b 35 68 f2 22 f0    	mov    0xf022f268,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102811:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102816:	89 da                	mov    %ebx,%edx
f0102818:	89 f8                	mov    %edi,%eax
f010281a:	e8 fe e2 ff ff       	call   f0100b1d <check_va2pa>
f010281f:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102826:	77 15                	ja     f010283d <mem_init+0x14da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102828:	56                   	push   %esi
f0102829:	68 88 64 10 f0       	push   $0xf0106488
f010282e:	68 67 03 00 00       	push   $0x367
f0102833:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102838:	e8 03 d8 ff ff       	call   f0100040 <_panic>
f010283d:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102844:	39 d0                	cmp    %edx,%eax
f0102846:	74 19                	je     f0102861 <mem_init+0x14fe>
f0102848:	68 c8 74 10 f0       	push   $0xf01074c8
f010284d:	68 44 6a 10 f0       	push   $0xf0106a44
f0102852:	68 67 03 00 00       	push   $0x367
f0102857:	68 1e 6a 10 f0       	push   $0xf0106a1e
f010285c:	e8 df d7 ff ff       	call   f0100040 <_panic>
f0102861:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102867:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010286d:	75 a7                	jne    f0102816 <mem_init+0x14b3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f010286f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102872:	c1 e6 0c             	shl    $0xc,%esi
f0102875:	bb 00 00 00 00       	mov    $0x0,%ebx
f010287a:	eb 30                	jmp    f01028ac <mem_init+0x1549>
f010287c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102882:	89 f8                	mov    %edi,%eax
f0102884:	e8 94 e2 ff ff       	call   f0100b1d <check_va2pa>
f0102889:	39 c3                	cmp    %eax,%ebx
f010288b:	74 19                	je     f01028a6 <mem_init+0x1543>
f010288d:	68 fc 74 10 f0       	push   $0xf01074fc
f0102892:	68 44 6a 10 f0       	push   $0xf0106a44
f0102897:	68 6b 03 00 00       	push   $0x36b
f010289c:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01028a1:	e8 9a d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
f01028a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028ac:	39 f3                	cmp    %esi,%ebx
f01028ae:	72 cc                	jb     f010287c <mem_init+0x1519>
f01028b0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01028b7:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028bc:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01028bf:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01028c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028c5:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028ce:	89 c3                	mov    %eax,%ebx
f01028d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028d3:	05 00 80 00 20       	add    $0x20008000,%eax
f01028d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028db:	89 da                	mov    %ebx,%edx
f01028dd:	89 f8                	mov    %edi,%eax
f01028df:	e8 39 e2 ff ff       	call   f0100b1d <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028e4:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028ea:	77 15                	ja     f0102901 <mem_init+0x159e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ec:	56                   	push   %esi
f01028ed:	68 88 64 10 f0       	push   $0xf0106488
f01028f2:	68 72 03 00 00       	push   $0x372
f01028f7:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01028fc:	e8 3f d7 ff ff       	call   f0100040 <_panic>
f0102901:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102904:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f010290b:	39 d0                	cmp    %edx,%eax
f010290d:	74 19                	je     f0102928 <mem_init+0x15c5>
f010290f:	68 24 75 10 f0       	push   $0xf0107524
f0102914:	68 44 6a 10 f0       	push   $0xf0106a44
f0102919:	68 72 03 00 00       	push   $0x372
f010291e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102923:	e8 18 d7 ff ff       	call   f0100040 <_panic>
f0102928:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010292e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102931:	75 a8                	jne    f01028db <mem_init+0x1578>
f0102933:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102936:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f010293c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010293f:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102941:	89 da                	mov    %ebx,%edx
f0102943:	89 f8                	mov    %edi,%eax
f0102945:	e8 d3 e1 ff ff       	call   f0100b1d <check_va2pa>
f010294a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010294d:	74 19                	je     f0102968 <mem_init+0x1605>
f010294f:	68 6c 75 10 f0       	push   $0xf010756c
f0102954:	68 44 6a 10 f0       	push   $0xf0106a44
f0102959:	68 74 03 00 00       	push   $0x374
f010295e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
f0102968:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010296e:	39 de                	cmp    %ebx,%esi
f0102970:	75 cf                	jne    f0102941 <mem_init+0x15de>
f0102972:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102975:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010297c:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102983:	81 c6 00 80 00 00    	add    $0x8000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)          
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102989:	81 fe 00 10 27 f0    	cmp    $0xf0271000,%esi
f010298f:	0f 85 2d ff ff ff    	jne    f01028c2 <mem_init+0x155f>
f0102995:	b8 00 00 00 00       	mov    $0x0,%eax
f010299a:	eb 2a                	jmp    f01029c6 <mem_init+0x1663>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010299c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01029a2:	83 fa 04             	cmp    $0x4,%edx
f01029a5:	77 1f                	ja     f01029c6 <mem_init+0x1663>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01029a7:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029ab:	75 7e                	jne    f0102a2b <mem_init+0x16c8>
f01029ad:	68 35 6d 10 f0       	push   $0xf0106d35
f01029b2:	68 44 6a 10 f0       	push   $0xf0106a44
f01029b7:	68 7f 03 00 00       	push   $0x37f
f01029bc:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01029c1:	e8 7a d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029c6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029cb:	76 3f                	jbe    f0102a0c <mem_init+0x16a9>
				assert(pgdir[i] & PTE_P);
f01029cd:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029d0:	f6 c2 01             	test   $0x1,%dl
f01029d3:	75 19                	jne    f01029ee <mem_init+0x168b>
f01029d5:	68 35 6d 10 f0       	push   $0xf0106d35
f01029da:	68 44 6a 10 f0       	push   $0xf0106a44
f01029df:	68 83 03 00 00       	push   $0x383
f01029e4:	68 1e 6a 10 f0       	push   $0xf0106a1e
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029ee:	f6 c2 02             	test   $0x2,%dl
f01029f1:	75 38                	jne    f0102a2b <mem_init+0x16c8>
f01029f3:	68 46 6d 10 f0       	push   $0xf0106d46
f01029f8:	68 44 6a 10 f0       	push   $0xf0106a44
f01029fd:	68 84 03 00 00       	push   $0x384
f0102a02:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a0c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a10:	74 19                	je     f0102a2b <mem_init+0x16c8>
f0102a12:	68 57 6d 10 f0       	push   $0xf0106d57
f0102a17:	68 44 6a 10 f0       	push   $0xf0106a44
f0102a1c:	68 86 03 00 00       	push   $0x386
f0102a21:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102a26:	e8 15 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a2b:	83 c0 01             	add    $0x1,%eax
f0102a2e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a33:	0f 86 63 ff ff ff    	jbe    f010299c <mem_init+0x1639>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a39:	83 ec 0c             	sub    $0xc,%esp
f0102a3c:	68 90 75 10 f0       	push   $0xf0107590
f0102a41:	e8 07 0d 00 00       	call   f010374d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a46:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a4b:	83 c4 10             	add    $0x10,%esp
f0102a4e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a53:	77 15                	ja     f0102a6a <mem_init+0x1707>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a55:	50                   	push   %eax
f0102a56:	68 88 64 10 f0       	push   $0xf0106488
f0102a5b:	68 f8 00 00 00       	push   $0xf8
f0102a60:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102a65:	e8 d6 d5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a6a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a6f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a72:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a77:	e8 05 e1 ff ff       	call   f0100b81 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a7c:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a7f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102a82:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a87:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a8a:	83 ec 0c             	sub    $0xc,%esp
f0102a8d:	6a 00                	push   $0x0
f0102a8f:	e8 e8 e4 ff ff       	call   f0100f7c <page_alloc>
f0102a94:	89 c3                	mov    %eax,%ebx
f0102a96:	83 c4 10             	add    $0x10,%esp
f0102a99:	85 c0                	test   %eax,%eax
f0102a9b:	75 19                	jne    f0102ab6 <mem_init+0x1753>
f0102a9d:	68 41 6b 10 f0       	push   $0xf0106b41
f0102aa2:	68 44 6a 10 f0       	push   $0xf0106a44
f0102aa7:	68 5e 04 00 00       	push   $0x45e
f0102aac:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102ab1:	e8 8a d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ab6:	83 ec 0c             	sub    $0xc,%esp
f0102ab9:	6a 00                	push   $0x0
f0102abb:	e8 bc e4 ff ff       	call   f0100f7c <page_alloc>
f0102ac0:	89 c7                	mov    %eax,%edi
f0102ac2:	83 c4 10             	add    $0x10,%esp
f0102ac5:	85 c0                	test   %eax,%eax
f0102ac7:	75 19                	jne    f0102ae2 <mem_init+0x177f>
f0102ac9:	68 57 6b 10 f0       	push   $0xf0106b57
f0102ace:	68 44 6a 10 f0       	push   $0xf0106a44
f0102ad3:	68 5f 04 00 00       	push   $0x45f
f0102ad8:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102add:	e8 5e d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ae2:	83 ec 0c             	sub    $0xc,%esp
f0102ae5:	6a 00                	push   $0x0
f0102ae7:	e8 90 e4 ff ff       	call   f0100f7c <page_alloc>
f0102aec:	89 c6                	mov    %eax,%esi
f0102aee:	83 c4 10             	add    $0x10,%esp
f0102af1:	85 c0                	test   %eax,%eax
f0102af3:	75 19                	jne    f0102b0e <mem_init+0x17ab>
f0102af5:	68 6d 6b 10 f0       	push   $0xf0106b6d
f0102afa:	68 44 6a 10 f0       	push   $0xf0106a44
f0102aff:	68 60 04 00 00       	push   $0x460
f0102b04:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102b09:	e8 32 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b0e:	83 ec 0c             	sub    $0xc,%esp
f0102b11:	53                   	push   %ebx
f0102b12:	e8 d3 e4 ff ff       	call   f0100fea <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b17:	89 f8                	mov    %edi,%eax
f0102b19:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0102b1f:	c1 f8 03             	sar    $0x3,%eax
f0102b22:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b25:	89 c2                	mov    %eax,%edx
f0102b27:	c1 ea 0c             	shr    $0xc,%edx
f0102b2a:	83 c4 10             	add    $0x10,%esp
f0102b2d:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0102b33:	72 12                	jb     f0102b47 <mem_init+0x17e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b35:	50                   	push   %eax
f0102b36:	68 64 64 10 f0       	push   $0xf0106464
f0102b3b:	6a 58                	push   $0x58
f0102b3d:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0102b42:	e8 f9 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b47:	83 ec 04             	sub    $0x4,%esp
f0102b4a:	68 00 10 00 00       	push   $0x1000
f0102b4f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b51:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b56:	50                   	push   %eax
f0102b57:	e8 1c 2c 00 00       	call   f0105778 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b5c:	89 f0                	mov    %esi,%eax
f0102b5e:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0102b64:	c1 f8 03             	sar    $0x3,%eax
f0102b67:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b6a:	89 c2                	mov    %eax,%edx
f0102b6c:	c1 ea 0c             	shr    $0xc,%edx
f0102b6f:	83 c4 10             	add    $0x10,%esp
f0102b72:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0102b78:	72 12                	jb     f0102b8c <mem_init+0x1829>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b7a:	50                   	push   %eax
f0102b7b:	68 64 64 10 f0       	push   $0xf0106464
f0102b80:	6a 58                	push   $0x58
f0102b82:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0102b87:	e8 b4 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b8c:	83 ec 04             	sub    $0x4,%esp
f0102b8f:	68 00 10 00 00       	push   $0x1000
f0102b94:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102b96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b9b:	50                   	push   %eax
f0102b9c:	e8 d7 2b 00 00       	call   f0105778 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ba1:	6a 02                	push   $0x2
f0102ba3:	68 00 10 00 00       	push   $0x1000
f0102ba8:	57                   	push   %edi
f0102ba9:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102baf:	e8 de e6 ff ff       	call   f0101292 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bb4:	83 c4 20             	add    $0x20,%esp
f0102bb7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bbc:	74 19                	je     f0102bd7 <mem_init+0x1874>
f0102bbe:	68 3e 6c 10 f0       	push   $0xf0106c3e
f0102bc3:	68 44 6a 10 f0       	push   $0xf0106a44
f0102bc8:	68 65 04 00 00       	push   $0x465
f0102bcd:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102bd2:	e8 69 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bd7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bde:	01 01 01 
f0102be1:	74 19                	je     f0102bfc <mem_init+0x1899>
f0102be3:	68 b0 75 10 f0       	push   $0xf01075b0
f0102be8:	68 44 6a 10 f0       	push   $0xf0106a44
f0102bed:	68 66 04 00 00       	push   $0x466
f0102bf2:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102bf7:	e8 44 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bfc:	6a 02                	push   $0x2
f0102bfe:	68 00 10 00 00       	push   $0x1000
f0102c03:	56                   	push   %esi
f0102c04:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102c0a:	e8 83 e6 ff ff       	call   f0101292 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c0f:	83 c4 10             	add    $0x10,%esp
f0102c12:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c19:	02 02 02 
f0102c1c:	74 19                	je     f0102c37 <mem_init+0x18d4>
f0102c1e:	68 d4 75 10 f0       	push   $0xf01075d4
f0102c23:	68 44 6a 10 f0       	push   $0xf0106a44
f0102c28:	68 68 04 00 00       	push   $0x468
f0102c2d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102c32:	e8 09 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c3c:	74 19                	je     f0102c57 <mem_init+0x18f4>
f0102c3e:	68 60 6c 10 f0       	push   $0xf0106c60
f0102c43:	68 44 6a 10 f0       	push   $0xf0106a44
f0102c48:	68 69 04 00 00       	push   $0x469
f0102c4d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102c52:	e8 e9 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c57:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5c:	74 19                	je     f0102c77 <mem_init+0x1914>
f0102c5e:	68 ca 6c 10 f0       	push   $0xf0106cca
f0102c63:	68 44 6a 10 f0       	push   $0xf0106a44
f0102c68:	68 6a 04 00 00       	push   $0x46a
f0102c6d:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102c72:	e8 c9 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c77:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c7e:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c81:	89 f0                	mov    %esi,%eax
f0102c83:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0102c89:	c1 f8 03             	sar    $0x3,%eax
f0102c8c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c8f:	89 c2                	mov    %eax,%edx
f0102c91:	c1 ea 0c             	shr    $0xc,%edx
f0102c94:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0102c9a:	72 12                	jb     f0102cae <mem_init+0x194b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c9c:	50                   	push   %eax
f0102c9d:	68 64 64 10 f0       	push   $0xf0106464
f0102ca2:	6a 58                	push   $0x58
f0102ca4:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0102ca9:	e8 92 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cae:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cb5:	03 03 03 
f0102cb8:	74 19                	je     f0102cd3 <mem_init+0x1970>
f0102cba:	68 f8 75 10 f0       	push   $0xf01075f8
f0102cbf:	68 44 6a 10 f0       	push   $0xf0106a44
f0102cc4:	68 6c 04 00 00       	push   $0x46c
f0102cc9:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102cce:	e8 6d d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cd3:	83 ec 08             	sub    $0x8,%esp
f0102cd6:	68 00 10 00 00       	push   $0x1000
f0102cdb:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0102ce1:	e8 5b e5 ff ff       	call   f0101241 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ce6:	83 c4 10             	add    $0x10,%esp
f0102ce9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cee:	74 19                	je     f0102d09 <mem_init+0x19a6>
f0102cf0:	68 98 6c 10 f0       	push   $0xf0106c98
f0102cf5:	68 44 6a 10 f0       	push   $0xf0106a44
f0102cfa:	68 6e 04 00 00       	push   $0x46e
f0102cff:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102d04:	e8 37 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d09:	8b 0d cc fe 22 f0    	mov    0xf022fecc,%ecx
f0102d0f:	8b 11                	mov    (%ecx),%edx
f0102d11:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d17:	89 d8                	mov    %ebx,%eax
f0102d19:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0102d1f:	c1 f8 03             	sar    $0x3,%eax
f0102d22:	c1 e0 0c             	shl    $0xc,%eax
f0102d25:	39 c2                	cmp    %eax,%edx
f0102d27:	74 19                	je     f0102d42 <mem_init+0x19df>
f0102d29:	68 80 6f 10 f0       	push   $0xf0106f80
f0102d2e:	68 44 6a 10 f0       	push   $0xf0106a44
f0102d33:	68 71 04 00 00       	push   $0x471
f0102d38:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102d3d:	e8 fe d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d48:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d4d:	74 19                	je     f0102d68 <mem_init+0x1a05>
f0102d4f:	68 4f 6c 10 f0       	push   $0xf0106c4f
f0102d54:	68 44 6a 10 f0       	push   $0xf0106a44
f0102d59:	68 73 04 00 00       	push   $0x473
f0102d5e:	68 1e 6a 10 f0       	push   $0xf0106a1e
f0102d63:	e8 d8 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d68:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d6e:	83 ec 0c             	sub    $0xc,%esp
f0102d71:	53                   	push   %ebx
f0102d72:	e8 73 e2 ff ff       	call   f0100fea <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d77:	c7 04 24 24 76 10 f0 	movl   $0xf0107624,(%esp)
f0102d7e:	e8 ca 09 00 00       	call   f010374d <cprintf>
f0102d83:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d89:	5b                   	pop    %ebx
f0102d8a:	5e                   	pop    %esi
f0102d8b:	5f                   	pop    %edi
f0102d8c:	5d                   	pop    %ebp
f0102d8d:	c3                   	ret    

f0102d8e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d8e:	55                   	push   %ebp
f0102d8f:	89 e5                	mov    %esp,%ebp
f0102d91:	57                   	push   %edi
f0102d92:	56                   	push   %esi
f0102d93:	53                   	push   %ebx
f0102d94:	83 ec 1c             	sub    $0x1c,%esp
f0102d97:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d9a:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102d9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102da0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uint32_t end = (uint32_t) (va+len);
f0102da6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102da9:	03 45 10             	add    0x10(%ebp),%eax
f0102dac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102daf:	eb 43                	jmp    f0102df4 <user_mem_check+0x66>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102db1:	83 ec 04             	sub    $0x4,%esp
f0102db4:	6a 00                	push   $0x0
f0102db6:	53                   	push   %ebx
f0102db7:	ff 77 60             	pushl  0x60(%edi)
f0102dba:	e8 91 e2 ff ff       	call   f0101050 <pgdir_walk>
       
                if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102dbf:	83 c4 10             	add    $0x10,%esp
f0102dc2:	85 c0                	test   %eax,%eax
f0102dc4:	74 14                	je     f0102dda <user_mem_check+0x4c>
f0102dc6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102dcc:	77 0c                	ja     f0102dda <user_mem_check+0x4c>
f0102dce:	8b 00                	mov    (%eax),%eax
f0102dd0:	a8 01                	test   $0x1,%al
f0102dd2:	74 06                	je     f0102dda <user_mem_check+0x4c>
f0102dd4:	21 f0                	and    %esi,%eax
f0102dd6:	39 c6                	cmp    %eax,%esi
f0102dd8:	74 14                	je     f0102dee <user_mem_check+0x60>
f0102dda:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102ddd:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102de1:	89 1d 5c f2 22 f0    	mov    %ebx,0xf022f25c
                      return -E_FAULT;
f0102de7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dec:	eb 10                	jmp    f0102dfe <user_mem_check+0x70>
{
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
        uint32_t end = (uint32_t) (va+len);
        uint32_t i;
        for (i = begin; i < end; i+=PGSIZE) {
f0102dee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102df4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102df7:	72 b8                	jb     f0102db1 <user_mem_check+0x23>
                      user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                      return -E_FAULT;
                }
        }
         
	return 0;
f0102df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e01:	5b                   	pop    %ebx
f0102e02:	5e                   	pop    %esi
f0102e03:	5f                   	pop    %edi
f0102e04:	5d                   	pop    %ebp
f0102e05:	c3                   	ret    

f0102e06 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e06:	55                   	push   %ebp
f0102e07:	89 e5                	mov    %esp,%ebp
f0102e09:	53                   	push   %ebx
f0102e0a:	83 ec 04             	sub    $0x4,%esp
f0102e0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e10:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e13:	83 c8 04             	or     $0x4,%eax
f0102e16:	50                   	push   %eax
f0102e17:	ff 75 10             	pushl  0x10(%ebp)
f0102e1a:	ff 75 0c             	pushl  0xc(%ebp)
f0102e1d:	53                   	push   %ebx
f0102e1e:	e8 6b ff ff ff       	call   f0102d8e <user_mem_check>
f0102e23:	83 c4 10             	add    $0x10,%esp
f0102e26:	85 c0                	test   %eax,%eax
f0102e28:	79 21                	jns    f0102e4b <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e2a:	83 ec 04             	sub    $0x4,%esp
f0102e2d:	ff 35 5c f2 22 f0    	pushl  0xf022f25c
f0102e33:	ff 73 48             	pushl  0x48(%ebx)
f0102e36:	68 50 76 10 f0       	push   $0xf0107650
f0102e3b:	e8 0d 09 00 00       	call   f010374d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e40:	89 1c 24             	mov    %ebx,(%esp)
f0102e43:	e8 1e 06 00 00       	call   f0103466 <env_destroy>
f0102e48:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e4e:	c9                   	leave  
f0102e4f:	c3                   	ret    

f0102e50 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e50:	55                   	push   %ebp
f0102e51:	89 e5                	mov    %esp,%ebp
f0102e53:	57                   	push   %edi
f0102e54:	56                   	push   %esi
f0102e55:	53                   	push   %ebx
f0102e56:	83 ec 1c             	sub    $0x1c,%esp
f0102e59:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        int i;
        struct PageInfo *newpage;
        va = ROUNDDOWN(va, PGSIZE);
f0102e5c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e62:	89 55 e0             	mov    %edx,-0x20(%ebp)
        len = ROUNDUP(len, PGSIZE);
f0102e65:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102e6b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102e71:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        for(i = 0; i < len; i+=PGSIZE) {
f0102e74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e79:	eb 52                	jmp    f0102ecd <region_alloc+0x7d>
                if((newpage = page_alloc(0)) == NULL)
f0102e7b:	83 ec 0c             	sub    $0xc,%esp
f0102e7e:	6a 00                	push   $0x0
f0102e80:	e8 f7 e0 ff ff       	call   f0100f7c <page_alloc>
f0102e85:	89 c7                	mov    %eax,%edi
f0102e87:	83 c4 10             	add    $0x10,%esp
f0102e8a:	85 c0                	test   %eax,%eax
f0102e8c:	75 10                	jne    f0102e9e <region_alloc+0x4e>
                       cprintf("page_alloc return null\n");
f0102e8e:	83 ec 0c             	sub    $0xc,%esp
f0102e91:	68 85 76 10 f0       	push   $0xf0107685
f0102e96:	e8 b2 08 00 00       	call   f010374d <cprintf>
f0102e9b:	83 c4 10             	add    $0x10,%esp
                if(page_insert(e->env_pgdir, newpage, va + i, PTE_U | PTE_W) < 0)
f0102e9e:	6a 06                	push   $0x6
f0102ea0:	03 75 e0             	add    -0x20(%ebp),%esi
f0102ea3:	56                   	push   %esi
f0102ea4:	57                   	push   %edi
f0102ea5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ea8:	ff 70 60             	pushl  0x60(%eax)
f0102eab:	e8 e2 e3 ff ff       	call   f0101292 <page_insert>
f0102eb0:	83 c4 10             	add    $0x10,%esp
f0102eb3:	85 c0                	test   %eax,%eax
f0102eb5:	79 10                	jns    f0102ec7 <region_alloc+0x77>
                       cprintf("insert failing\n");
f0102eb7:	83 ec 0c             	sub    $0xc,%esp
f0102eba:	68 9d 76 10 f0       	push   $0xf010769d
f0102ebf:	e8 89 08 00 00       	call   f010374d <cprintf>
f0102ec4:	83 c4 10             	add    $0x10,%esp
	//   (Watch out for corner-cases!)
        int i;
        struct PageInfo *newpage;
        va = ROUNDDOWN(va, PGSIZE);
        len = ROUNDUP(len, PGSIZE);
        for(i = 0; i < len; i+=PGSIZE) {
f0102ec7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ecd:	89 de                	mov    %ebx,%esi
f0102ecf:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102ed2:	77 a7                	ja     f0102e7b <region_alloc+0x2b>
                       cprintf("page_alloc return null\n");
                if(page_insert(e->env_pgdir, newpage, va + i, PTE_U | PTE_W) < 0)
                       cprintf("insert failing\n");

        }
}
f0102ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ed7:	5b                   	pop    %ebx
f0102ed8:	5e                   	pop    %esi
f0102ed9:	5f                   	pop    %edi
f0102eda:	5d                   	pop    %ebp
f0102edb:	c3                   	ret    

f0102edc <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102edc:	55                   	push   %ebp
f0102edd:	89 e5                	mov    %esp,%ebp
f0102edf:	56                   	push   %esi
f0102ee0:	53                   	push   %ebx
f0102ee1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ee4:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ee7:	85 c0                	test   %eax,%eax
f0102ee9:	75 1a                	jne    f0102f05 <envid2env+0x29>
		*env_store = curenv;
f0102eeb:	e8 ab 2e 00 00       	call   f0105d9b <cpunum>
f0102ef0:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ef3:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0102ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102efc:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102efe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f03:	eb 70                	jmp    f0102f75 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f05:	89 c3                	mov    %eax,%ebx
f0102f07:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f0d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f10:	03 1d 68 f2 22 f0    	add    0xf022f268,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f16:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f1a:	74 05                	je     f0102f21 <envid2env+0x45>
f0102f1c:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102f1f:	74 10                	je     f0102f31 <envid2env+0x55>
		*env_store = 0;
f0102f21:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f2a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f2f:	eb 44                	jmp    f0102f75 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f31:	84 d2                	test   %dl,%dl
f0102f33:	74 36                	je     f0102f6b <envid2env+0x8f>
f0102f35:	e8 61 2e 00 00       	call   f0105d9b <cpunum>
f0102f3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f3d:	39 98 48 00 23 f0    	cmp    %ebx,-0xfdcffb8(%eax)
f0102f43:	74 26                	je     f0102f6b <envid2env+0x8f>
f0102f45:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f48:	e8 4e 2e 00 00       	call   f0105d9b <cpunum>
f0102f4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f50:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0102f56:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f59:	74 10                	je     f0102f6b <envid2env+0x8f>
		*env_store = 0;
f0102f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f64:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f69:	eb 0a                	jmp    f0102f75 <envid2env+0x99>
	}

	*env_store = e;
f0102f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f6e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f75:	5b                   	pop    %ebx
f0102f76:	5e                   	pop    %esi
f0102f77:	5d                   	pop    %ebp
f0102f78:	c3                   	ret    

f0102f79 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f79:	55                   	push   %ebp
f0102f7a:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f7c:	b8 40 03 12 f0       	mov    $0xf0120340,%eax
f0102f81:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f84:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f89:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f8b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f8d:	b0 10                	mov    $0x10,%al
f0102f8f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f91:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f93:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f95:	ea 9c 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f9c
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f9c:	b0 00                	mov    $0x0,%al
f0102f9e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fa1:	5d                   	pop    %ebp
f0102fa2:	c3                   	ret    

f0102fa3 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102fa3:	55                   	push   %ebp
f0102fa4:	89 e5                	mov    %esp,%ebp
f0102fa6:	56                   	push   %esi
f0102fa7:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
		envs[i].env_id = 0;
f0102fa8:	8b 35 68 f2 22 f0    	mov    0xf022f268,%esi
f0102fae:	8b 15 6c f2 22 f0    	mov    0xf022f26c,%edx
f0102fb4:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102fba:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102fbd:	89 c1                	mov    %eax,%ecx
f0102fbf:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102fc6:	89 50 44             	mov    %edx,0x44(%eax)
f0102fc9:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f0102fcc:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV-1;i >= 0; i--) {
f0102fce:	39 d8                	cmp    %ebx,%eax
f0102fd0:	75 eb                	jne    f0102fbd <env_init+0x1a>
f0102fd2:	89 35 6c f2 22 f0    	mov    %esi,0xf022f26c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	} 
	// Per-CPU part of the initialization
	env_init_percpu();
f0102fd8:	e8 9c ff ff ff       	call   f0102f79 <env_init_percpu>
                
}
f0102fdd:	5b                   	pop    %ebx
f0102fde:	5e                   	pop    %esi
f0102fdf:	5d                   	pop    %ebp
f0102fe0:	c3                   	ret    

f0102fe1 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fe1:	55                   	push   %ebp
f0102fe2:	89 e5                	mov    %esp,%ebp
f0102fe4:	53                   	push   %ebx
f0102fe5:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
f0102fe8:	8b 1d 6c f2 22 f0    	mov    0xf022f26c,%ebx
f0102fee:	85 db                	test   %ebx,%ebx
f0102ff0:	0f 84 69 01 00 00    	je     f010315f <env_alloc+0x17e>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102ff6:	83 ec 0c             	sub    $0xc,%esp
f0102ff9:	6a 01                	push   $0x1
f0102ffb:	e8 7c df ff ff       	call   f0100f7c <page_alloc>
f0103000:	83 c4 10             	add    $0x10,%esp
f0103003:	85 c0                	test   %eax,%eax
f0103005:	0f 84 5b 01 00 00    	je     f0103166 <env_alloc+0x185>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        p->pp_ref++;
f010300b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103010:	2b 05 d0 fe 22 f0    	sub    0xf022fed0,%eax
f0103016:	c1 f8 03             	sar    $0x3,%eax
f0103019:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010301c:	89 c2                	mov    %eax,%edx
f010301e:	c1 ea 0c             	shr    $0xc,%edx
f0103021:	3b 15 c8 fe 22 f0    	cmp    0xf022fec8,%edx
f0103027:	72 12                	jb     f010303b <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103029:	50                   	push   %eax
f010302a:	68 64 64 10 f0       	push   $0xf0106464
f010302f:	6a 58                	push   $0x58
f0103031:	68 2a 6a 10 f0       	push   $0xf0106a2a
f0103036:	e8 05 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010303b:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = page2kva(p);    
f0103040:	89 43 60             	mov    %eax,0x60(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
f0103043:	83 ec 04             	sub    $0x4,%esp
f0103046:	68 00 10 00 00       	push   $0x1000
f010304b:	ff 35 cc fe 22 f0    	pushl  0xf022fecc
f0103051:	50                   	push   %eax
f0103052:	e8 d6 27 00 00       	call   f010582d <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103057:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010305a:	83 c4 10             	add    $0x10,%esp
f010305d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103062:	77 15                	ja     f0103079 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103064:	50                   	push   %eax
f0103065:	68 88 64 10 f0       	push   $0xf0106488
f010306a:	68 c4 00 00 00       	push   $0xc4
f010306f:	68 ad 76 10 f0       	push   $0xf01076ad
f0103074:	e8 c7 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103079:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010307f:	83 ca 05             	or     $0x5,%edx
f0103082:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0) 
		return r;
 
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103088:	8b 43 48             	mov    0x48(%ebx),%eax
f010308b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103090:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103095:	ba 00 10 00 00       	mov    $0x1000,%edx
f010309a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010309d:	89 da                	mov    %ebx,%edx
f010309f:	2b 15 68 f2 22 f0    	sub    0xf022f268,%edx
f01030a5:	c1 fa 02             	sar    $0x2,%edx
f01030a8:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030ae:	09 d0                	or     %edx,%eax
f01030b0:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030b6:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030b9:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030c0:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030c7:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030ce:	83 ec 04             	sub    $0x4,%esp
f01030d1:	6a 44                	push   $0x44
f01030d3:	6a 00                	push   $0x0
f01030d5:	53                   	push   %ebx
f01030d6:	e8 9d 26 00 00       	call   f0105778 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030db:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030e1:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030e7:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030ed:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030f4:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f01030fa:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103101:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103108:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010310c:	8b 43 44             	mov    0x44(%ebx),%eax
f010310f:	a3 6c f2 22 f0       	mov    %eax,0xf022f26c
	*newenv_store = e;
f0103114:	8b 45 08             	mov    0x8(%ebp),%eax
f0103117:	89 18                	mov    %ebx,(%eax)
         
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103119:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010311c:	e8 7a 2c 00 00       	call   f0105d9b <cpunum>
f0103121:	6b c0 74             	imul   $0x74,%eax,%eax
f0103124:	83 c4 10             	add    $0x10,%esp
f0103127:	ba 00 00 00 00       	mov    $0x0,%edx
f010312c:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f0103133:	74 11                	je     f0103146 <env_alloc+0x165>
f0103135:	e8 61 2c 00 00       	call   f0105d9b <cpunum>
f010313a:	6b c0 74             	imul   $0x74,%eax,%eax
f010313d:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0103143:	8b 50 48             	mov    0x48(%eax),%edx
f0103146:	83 ec 04             	sub    $0x4,%esp
f0103149:	53                   	push   %ebx
f010314a:	52                   	push   %edx
f010314b:	68 b8 76 10 f0       	push   $0xf01076b8
f0103150:	e8 f8 05 00 00       	call   f010374d <cprintf>
	return 0;
f0103155:	83 c4 10             	add    $0x10,%esp
f0103158:	b8 00 00 00 00       	mov    $0x0,%eax
f010315d:	eb 0c                	jmp    f010316b <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) 
		return -E_NO_FREE_ENV;
f010315f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103164:	eb 05                	jmp    f010316b <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103166:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;
         
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010316b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010316e:	c9                   	leave  
f010316f:	c3                   	ret    

f0103170 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103170:	55                   	push   %ebp
f0103171:	89 e5                	mov    %esp,%ebp
f0103173:	57                   	push   %edi
f0103174:	56                   	push   %esi
f0103175:	53                   	push   %ebx
f0103176:	83 ec 34             	sub    $0x34,%esp
f0103179:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
        struct Env *e;
        int tmp;
        if((tmp = env_alloc(&e, 0)) != 0)
f010317c:	6a 00                	push   $0x0
f010317e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103181:	50                   	push   %eax
f0103182:	e8 5a fe ff ff       	call   f0102fe1 <env_alloc>
f0103187:	83 c4 10             	add    $0x10,%esp
f010318a:	85 c0                	test   %eax,%eax
f010318c:	74 17                	je     f01031a5 <env_create+0x35>
               panic("evn create fails!\n");
f010318e:	83 ec 04             	sub    $0x4,%esp
f0103191:	68 cd 76 10 f0       	push   $0xf01076cd
f0103196:	68 88 01 00 00       	push   $0x188
f010319b:	68 ad 76 10 f0       	push   $0xf01076ad
f01031a0:	e8 9b ce ff ff       	call   f0100040 <_panic>
        e->env_type =type;
f01031a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031ab:	89 47 50             	mov    %eax,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf_img = (struct Elf *)binary;
        struct Proghdr *ph, *eph;
        if (elf_img->e_magic != ELF_MAGIC)
f01031ae:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01031b4:	74 17                	je     f01031cd <env_create+0x5d>
                panic("Not executable!");
f01031b6:	83 ec 04             	sub    $0x4,%esp
f01031b9:	68 e0 76 10 f0       	push   $0xf01076e0
f01031be:	68 67 01 00 00       	push   $0x167
f01031c3:	68 ad 76 10 f0       	push   $0xf01076ad
f01031c8:	e8 73 ce ff ff       	call   f0100040 <_panic>
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
f01031cd:	89 f3                	mov    %esi,%ebx
f01031cf:	03 5e 1c             	add    0x1c(%esi),%ebx
        eph = ph + elf_img->e_phnum;
f01031d2:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01031d6:	c1 e0 05             	shl    $0x5,%eax
f01031d9:	01 d8                	add    %ebx,%eax
f01031db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        lcr3(PADDR(e->env_pgdir));
f01031de:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e6:	77 15                	ja     f01031fd <env_create+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e8:	50                   	push   %eax
f01031e9:	68 88 64 10 f0       	push   $0xf0106488
f01031ee:	68 6a 01 00 00       	push   $0x16a
f01031f3:	68 ad 76 10 f0       	push   $0xf01076ad
f01031f8:	e8 43 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031fd:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103202:	0f 22 d8             	mov    %eax,%cr3
f0103205:	eb 37                	jmp    f010323e <env_create+0xce>
        
        for(; ph < eph; ph++) {
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103207:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010320a:	8b 53 08             	mov    0x8(%ebx),%edx
f010320d:	89 f8                	mov    %edi,%eax
f010320f:	e8 3c fc ff ff       	call   f0102e50 <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f0103214:	83 ec 04             	sub    $0x4,%esp
f0103217:	ff 73 14             	pushl  0x14(%ebx)
f010321a:	6a 00                	push   $0x0
f010321c:	ff 73 08             	pushl  0x8(%ebx)
f010321f:	e8 54 25 00 00       	call   f0105778 <memset>
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103224:	83 c4 0c             	add    $0xc,%esp
f0103227:	ff 73 10             	pushl  0x10(%ebx)
f010322a:	89 f0                	mov    %esi,%eax
f010322c:	03 43 04             	add    0x4(%ebx),%eax
f010322f:	50                   	push   %eax
f0103230:	ff 73 08             	pushl  0x8(%ebx)
f0103233:	e8 f5 25 00 00       	call   f010582d <memcpy>
                panic("Not executable!");
        ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        eph = ph + elf_img->e_phnum;
        lcr3(PADDR(e->env_pgdir));
        
        for(; ph < eph; ph++) {
f0103238:	83 c3 20             	add    $0x20,%ebx
f010323b:	83 c4 10             	add    $0x10,%esp
f010323e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103241:	77 c4                	ja     f0103207 <env_create+0x97>
                region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        }
        lcr3(PADDR(kern_pgdir));
f0103243:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103248:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010324d:	77 15                	ja     f0103264 <env_create+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010324f:	50                   	push   %eax
f0103250:	68 88 64 10 f0       	push   $0xf0106488
f0103255:	68 71 01 00 00       	push   $0x171
f010325a:	68 ad 76 10 f0       	push   $0xf01076ad
f010325f:	e8 dc cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103264:	05 00 00 00 10       	add    $0x10000000,%eax
f0103269:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elf_img->e_entry;
f010326c:	8b 46 18             	mov    0x18(%esi),%eax
f010326f:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103272:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103277:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010327c:	89 f8                	mov    %edi,%eax
f010327e:	e8 cd fb ff ff       	call   f0102e50 <region_alloc>
        int tmp;
        if((tmp = env_alloc(&e, 0)) != 0)
               panic("evn create fails!\n");
        e->env_type =type;
        load_icode(e, binary);
}
f0103283:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103286:	5b                   	pop    %ebx
f0103287:	5e                   	pop    %esi
f0103288:	5f                   	pop    %edi
f0103289:	5d                   	pop    %ebp
f010328a:	c3                   	ret    

f010328b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010328b:	55                   	push   %ebp
f010328c:	89 e5                	mov    %esp,%ebp
f010328e:	57                   	push   %edi
f010328f:	56                   	push   %esi
f0103290:	53                   	push   %ebx
f0103291:	83 ec 1c             	sub    $0x1c,%esp
f0103294:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103297:	e8 ff 2a 00 00       	call   f0105d9b <cpunum>
f010329c:	6b c0 74             	imul   $0x74,%eax,%eax
f010329f:	39 b8 48 00 23 f0    	cmp    %edi,-0xfdcffb8(%eax)
f01032a5:	75 29                	jne    f01032d0 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01032a7:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032b1:	77 15                	ja     f01032c8 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032b3:	50                   	push   %eax
f01032b4:	68 88 64 10 f0       	push   $0xf0106488
f01032b9:	68 9b 01 00 00       	push   $0x19b
f01032be:	68 ad 76 10 f0       	push   $0xf01076ad
f01032c3:	e8 78 cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032c8:	05 00 00 00 10       	add    $0x10000000,%eax
f01032cd:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032d0:	8b 5f 48             	mov    0x48(%edi),%ebx
f01032d3:	e8 c3 2a 00 00       	call   f0105d9b <cpunum>
f01032d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032db:	ba 00 00 00 00       	mov    $0x0,%edx
f01032e0:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f01032e7:	74 11                	je     f01032fa <env_free+0x6f>
f01032e9:	e8 ad 2a 00 00       	call   f0105d9b <cpunum>
f01032ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01032f1:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f01032f7:	8b 50 48             	mov    0x48(%eax),%edx
f01032fa:	83 ec 04             	sub    $0x4,%esp
f01032fd:	53                   	push   %ebx
f01032fe:	52                   	push   %edx
f01032ff:	68 f0 76 10 f0       	push   $0xf01076f0
f0103304:	e8 44 04 00 00       	call   f010374d <cprintf>
f0103309:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010330c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103313:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103316:	89 d0                	mov    %edx,%eax
f0103318:	c1 e0 02             	shl    $0x2,%eax
f010331b:	89 45 d8             	mov    %eax,-0x28(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010331e:	8b 47 60             	mov    0x60(%edi),%eax
f0103321:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103324:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010332a:	0f 84 a8 00 00 00    	je     f01033d8 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103330:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103336:	89 f0                	mov    %esi,%eax
f0103338:	c1 e8 0c             	shr    $0xc,%eax
f010333b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010333e:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f0103344:	72 15                	jb     f010335b <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103346:	56                   	push   %esi
f0103347:	68 64 64 10 f0       	push   $0xf0106464
f010334c:	68 aa 01 00 00       	push   $0x1aa
f0103351:	68 ad 76 10 f0       	push   $0xf01076ad
f0103356:	e8 e5 cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010335b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010335e:	c1 e0 16             	shl    $0x16,%eax
f0103361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103364:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103369:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103370:	01 
f0103371:	74 17                	je     f010338a <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103373:	83 ec 08             	sub    $0x8,%esp
f0103376:	89 d8                	mov    %ebx,%eax
f0103378:	c1 e0 0c             	shl    $0xc,%eax
f010337b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010337e:	50                   	push   %eax
f010337f:	ff 77 60             	pushl  0x60(%edi)
f0103382:	e8 ba de ff ff       	call   f0101241 <page_remove>
f0103387:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010338a:	83 c3 01             	add    $0x1,%ebx
f010338d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103393:	75 d4                	jne    f0103369 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103395:	8b 47 60             	mov    0x60(%edi),%eax
f0103398:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010339b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033a5:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f01033ab:	72 14                	jb     f01033c1 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01033ad:	83 ec 04             	sub    $0x4,%esp
f01033b0:	68 2c 6e 10 f0       	push   $0xf0106e2c
f01033b5:	6a 51                	push   $0x51
f01033b7:	68 2a 6a 10 f0       	push   $0xf0106a2a
f01033bc:	e8 7f cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01033c1:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033c4:	a1 d0 fe 22 f0       	mov    0xf022fed0,%eax
f01033c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033cc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033cf:	50                   	push   %eax
f01033d0:	e8 54 dc ff ff       	call   f0101029 <page_decref>
f01033d5:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033d8:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01033dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033df:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01033e4:	0f 85 29 ff ff ff    	jne    f0103313 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033ea:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f2:	77 15                	ja     f0103409 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f4:	50                   	push   %eax
f01033f5:	68 88 64 10 f0       	push   $0xf0106488
f01033fa:	68 b8 01 00 00       	push   $0x1b8
f01033ff:	68 ad 76 10 f0       	push   $0xf01076ad
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103409:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103410:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103415:	c1 e8 0c             	shr    $0xc,%eax
f0103418:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f010341e:	72 14                	jb     f0103434 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103420:	83 ec 04             	sub    $0x4,%esp
f0103423:	68 2c 6e 10 f0       	push   $0xf0106e2c
f0103428:	6a 51                	push   $0x51
f010342a:	68 2a 6a 10 f0       	push   $0xf0106a2a
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103434:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103437:	8b 15 d0 fe 22 f0    	mov    0xf022fed0,%edx
f010343d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103440:	50                   	push   %eax
f0103441:	e8 e3 db ff ff       	call   f0101029 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103446:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010344d:	a1 6c f2 22 f0       	mov    0xf022f26c,%eax
f0103452:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103455:	89 3d 6c f2 22 f0    	mov    %edi,0xf022f26c
f010345b:	83 c4 10             	add    $0x10,%esp
}
f010345e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103461:	5b                   	pop    %ebx
f0103462:	5e                   	pop    %esi
f0103463:	5f                   	pop    %edi
f0103464:	5d                   	pop    %ebp
f0103465:	c3                   	ret    

f0103466 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103466:	55                   	push   %ebp
f0103467:	89 e5                	mov    %esp,%ebp
f0103469:	53                   	push   %ebx
f010346a:	83 ec 04             	sub    $0x4,%esp
f010346d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103470:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103474:	75 19                	jne    f010348f <env_destroy+0x29>
f0103476:	e8 20 29 00 00       	call   f0105d9b <cpunum>
f010347b:	6b c0 74             	imul   $0x74,%eax,%eax
f010347e:	39 98 48 00 23 f0    	cmp    %ebx,-0xfdcffb8(%eax)
f0103484:	74 09                	je     f010348f <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103486:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010348d:	eb 33                	jmp    f01034c2 <env_destroy+0x5c>
	}

	env_free(e);
f010348f:	83 ec 0c             	sub    $0xc,%esp
f0103492:	53                   	push   %ebx
f0103493:	e8 f3 fd ff ff       	call   f010328b <env_free>

	if (curenv == e) {
f0103498:	e8 fe 28 00 00       	call   f0105d9b <cpunum>
f010349d:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a0:	83 c4 10             	add    $0x10,%esp
f01034a3:	39 98 48 00 23 f0    	cmp    %ebx,-0xfdcffb8(%eax)
f01034a9:	75 17                	jne    f01034c2 <env_destroy+0x5c>
		curenv = NULL;
f01034ab:	e8 eb 28 00 00       	call   f0105d9b <cpunum>
f01034b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034b3:	c7 80 48 00 23 f0 00 	movl   $0x0,-0xfdcffb8(%eax)
f01034ba:	00 00 00 
		sched_yield();
f01034bd:	e8 c2 10 00 00       	call   f0104584 <sched_yield>
	}
}
f01034c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034c5:	c9                   	leave  
f01034c6:	c3                   	ret    

f01034c7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034c7:	55                   	push   %ebp
f01034c8:	89 e5                	mov    %esp,%ebp
f01034ca:	53                   	push   %ebx
f01034cb:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034ce:	e8 c8 28 00 00       	call   f0105d9b <cpunum>
f01034d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d6:	8b 98 48 00 23 f0    	mov    -0xfdcffb8(%eax),%ebx
f01034dc:	e8 ba 28 00 00       	call   f0105d9b <cpunum>
f01034e1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01034e4:	8b 65 08             	mov    0x8(%ebp),%esp
f01034e7:	61                   	popa   
f01034e8:	07                   	pop    %es
f01034e9:	1f                   	pop    %ds
f01034ea:	83 c4 08             	add    $0x8,%esp
f01034ed:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034ee:	83 ec 04             	sub    $0x4,%esp
f01034f1:	68 06 77 10 f0       	push   $0xf0107706
f01034f6:	68 ee 01 00 00       	push   $0x1ee
f01034fb:	68 ad 76 10 f0       	push   $0xf01076ad
f0103500:	e8 3b cb ff ff       	call   f0100040 <_panic>

f0103505 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103505:	55                   	push   %ebp
f0103506:	89 e5                	mov    %esp,%ebp
f0103508:	53                   	push   %ebx
f0103509:	83 ec 04             	sub    $0x4,%esp
f010350c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if( e != curenv) {
f010350f:	e8 87 28 00 00       	call   f0105d9b <cpunum>
f0103514:	6b c0 74             	imul   $0x74,%eax,%eax
f0103517:	39 98 48 00 23 f0    	cmp    %ebx,-0xfdcffb8(%eax)
f010351d:	0f 84 a4 00 00 00    	je     f01035c7 <env_run+0xc2>
                if (curenv && curenv->env_status == ENV_RUNNING)
f0103523:	e8 73 28 00 00       	call   f0105d9b <cpunum>
f0103528:	6b c0 74             	imul   $0x74,%eax,%eax
f010352b:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f0103532:	74 29                	je     f010355d <env_run+0x58>
f0103534:	e8 62 28 00 00       	call   f0105d9b <cpunum>
f0103539:	6b c0 74             	imul   $0x74,%eax,%eax
f010353c:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0103542:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103546:	75 15                	jne    f010355d <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103548:	e8 4e 28 00 00       	call   f0105d9b <cpunum>
f010354d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103550:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0103556:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
                curenv = e;
f010355d:	e8 39 28 00 00       	call   f0105d9b <cpunum>
f0103562:	6b c0 74             	imul   $0x74,%eax,%eax
f0103565:	89 98 48 00 23 f0    	mov    %ebx,-0xfdcffb8(%eax)
                curenv->env_runs++;
f010356b:	e8 2b 28 00 00       	call   f0105d9b <cpunum>
f0103570:	6b c0 74             	imul   $0x74,%eax,%eax
f0103573:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0103579:	83 40 58 01          	addl   $0x1,0x58(%eax)
                curenv->env_status = ENV_RUNNING;
f010357d:	e8 19 28 00 00       	call   f0105d9b <cpunum>
f0103582:	6b c0 74             	imul   $0x74,%eax,%eax
f0103585:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010358b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
                lcr3(PADDR(curenv->env_pgdir));
f0103592:	e8 04 28 00 00       	call   f0105d9b <cpunum>
f0103597:	6b c0 74             	imul   $0x74,%eax,%eax
f010359a:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f01035a0:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a8:	77 15                	ja     f01035bf <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035aa:	50                   	push   %eax
f01035ab:	68 88 64 10 f0       	push   $0xf0106488
f01035b0:	68 12 02 00 00       	push   $0x212
f01035b5:	68 ad 76 10 f0       	push   $0xf01076ad
f01035ba:	e8 81 ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01035bf:	05 00 00 00 10       	add    $0x10000000,%eax
f01035c4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01035c7:	83 ec 0c             	sub    $0xc,%esp
f01035ca:	68 00 04 12 f0       	push   $0xf0120400
f01035cf:	e8 cf 2a 00 00       	call   f01060a3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01035d4:	f3 90                	pause  
        }
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01035d6:	e8 c0 27 00 00       	call   f0105d9b <cpunum>
f01035db:	83 c4 04             	add    $0x4,%esp
f01035de:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e1:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f01035e7:	e8 db fe ff ff       	call   f01034c7 <env_pop_tf>

f01035ec <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035ec:	55                   	push   %ebp
f01035ed:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035ef:	ba 70 00 00 00       	mov    $0x70,%edx
f01035f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01035f7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035f8:	b2 71                	mov    $0x71,%dl
f01035fa:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035fb:	0f b6 c0             	movzbl %al,%eax
}
f01035fe:	5d                   	pop    %ebp
f01035ff:	c3                   	ret    

f0103600 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103600:	55                   	push   %ebp
f0103601:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103603:	ba 70 00 00 00       	mov    $0x70,%edx
f0103608:	8b 45 08             	mov    0x8(%ebp),%eax
f010360b:	ee                   	out    %al,(%dx)
f010360c:	b2 71                	mov    $0x71,%dl
f010360e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103611:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103612:	5d                   	pop    %ebp
f0103613:	c3                   	ret    

f0103614 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103614:	55                   	push   %ebp
f0103615:	89 e5                	mov    %esp,%ebp
f0103617:	56                   	push   %esi
f0103618:	53                   	push   %ebx
f0103619:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010361c:	66 a3 e8 03 12 f0    	mov    %ax,0xf01203e8
	if (!didinit)
f0103622:	80 3d 70 f2 22 f0 00 	cmpb   $0x0,0xf022f270
f0103629:	74 57                	je     f0103682 <irq_setmask_8259A+0x6e>
f010362b:	89 c6                	mov    %eax,%esi
f010362d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103632:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103633:	66 c1 e8 08          	shr    $0x8,%ax
f0103637:	b2 a1                	mov    $0xa1,%dl
f0103639:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010363a:	83 ec 0c             	sub    $0xc,%esp
f010363d:	68 12 77 10 f0       	push   $0xf0107712
f0103642:	e8 06 01 00 00       	call   f010374d <cprintf>
f0103647:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010364a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010364f:	0f b7 f6             	movzwl %si,%esi
f0103652:	f7 d6                	not    %esi
f0103654:	0f a3 de             	bt     %ebx,%esi
f0103657:	73 11                	jae    f010366a <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103659:	83 ec 08             	sub    $0x8,%esp
f010365c:	53                   	push   %ebx
f010365d:	68 1b 7c 10 f0       	push   $0xf0107c1b
f0103662:	e8 e6 00 00 00       	call   f010374d <cprintf>
f0103667:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010366a:	83 c3 01             	add    $0x1,%ebx
f010366d:	83 fb 10             	cmp    $0x10,%ebx
f0103670:	75 e2                	jne    f0103654 <irq_setmask_8259A+0x40>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103672:	83 ec 0c             	sub    $0xc,%esp
f0103675:	68 33 6d 10 f0       	push   $0xf0106d33
f010367a:	e8 ce 00 00 00       	call   f010374d <cprintf>
f010367f:	83 c4 10             	add    $0x10,%esp
}
f0103682:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103685:	5b                   	pop    %ebx
f0103686:	5e                   	pop    %esi
f0103687:	5d                   	pop    %ebp
f0103688:	c3                   	ret    

f0103689 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103689:	c6 05 70 f2 22 f0 01 	movb   $0x1,0xf022f270
f0103690:	ba 21 00 00 00       	mov    $0x21,%edx
f0103695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010369a:	ee                   	out    %al,(%dx)
f010369b:	b2 a1                	mov    $0xa1,%dl
f010369d:	ee                   	out    %al,(%dx)
f010369e:	b2 20                	mov    $0x20,%dl
f01036a0:	b8 11 00 00 00       	mov    $0x11,%eax
f01036a5:	ee                   	out    %al,(%dx)
f01036a6:	b2 21                	mov    $0x21,%dl
f01036a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01036ad:	ee                   	out    %al,(%dx)
f01036ae:	b8 04 00 00 00       	mov    $0x4,%eax
f01036b3:	ee                   	out    %al,(%dx)
f01036b4:	b8 03 00 00 00       	mov    $0x3,%eax
f01036b9:	ee                   	out    %al,(%dx)
f01036ba:	b2 a0                	mov    $0xa0,%dl
f01036bc:	b8 11 00 00 00       	mov    $0x11,%eax
f01036c1:	ee                   	out    %al,(%dx)
f01036c2:	b2 a1                	mov    $0xa1,%dl
f01036c4:	b8 28 00 00 00       	mov    $0x28,%eax
f01036c9:	ee                   	out    %al,(%dx)
f01036ca:	b8 02 00 00 00       	mov    $0x2,%eax
f01036cf:	ee                   	out    %al,(%dx)
f01036d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01036d5:	ee                   	out    %al,(%dx)
f01036d6:	b2 20                	mov    $0x20,%dl
f01036d8:	b8 68 00 00 00       	mov    $0x68,%eax
f01036dd:	ee                   	out    %al,(%dx)
f01036de:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036e3:	ee                   	out    %al,(%dx)
f01036e4:	b2 a0                	mov    $0xa0,%dl
f01036e6:	b8 68 00 00 00       	mov    $0x68,%eax
f01036eb:	ee                   	out    %al,(%dx)
f01036ec:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036f1:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036f2:	0f b7 05 e8 03 12 f0 	movzwl 0xf01203e8,%eax
f01036f9:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036fd:	74 13                	je     f0103712 <pic_init+0x89>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103705:	0f b7 c0             	movzwl %ax,%eax
f0103708:	50                   	push   %eax
f0103709:	e8 06 ff ff ff       	call   f0103614 <irq_setmask_8259A>
f010370e:	83 c4 10             	add    $0x10,%esp
}
f0103711:	c9                   	leave  
f0103712:	f3 c3                	repz ret 

f0103714 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103714:	55                   	push   %ebp
f0103715:	89 e5                	mov    %esp,%ebp
f0103717:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010371a:	ff 75 08             	pushl  0x8(%ebp)
f010371d:	e8 23 d0 ff ff       	call   f0100745 <cputchar>
f0103722:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103725:	c9                   	leave  
f0103726:	c3                   	ret    

f0103727 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103727:	55                   	push   %ebp
f0103728:	89 e5                	mov    %esp,%ebp
f010372a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010372d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103734:	ff 75 0c             	pushl  0xc(%ebp)
f0103737:	ff 75 08             	pushl  0x8(%ebp)
f010373a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010373d:	50                   	push   %eax
f010373e:	68 14 37 10 f0       	push   $0xf0103714
f0103743:	e8 bd 19 00 00       	call   f0105105 <vprintfmt>
	return cnt;
}
f0103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010374b:	c9                   	leave  
f010374c:	c3                   	ret    

f010374d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010374d:	55                   	push   %ebp
f010374e:	89 e5                	mov    %esp,%ebp
f0103750:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103753:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103756:	50                   	push   %eax
f0103757:	ff 75 08             	pushl  0x8(%ebp)
f010375a:	e8 c8 ff ff ff       	call   f0103727 <vcprintf>
	va_end(ap);

	return cnt;
}
f010375f:	c9                   	leave  
f0103760:	c3                   	ret    

f0103761 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103761:	55                   	push   %ebp
f0103762:	89 e5                	mov    %esp,%ebp
f0103764:	57                   	push   %edi
f0103765:	56                   	push   %esi
f0103766:	53                   	push   %ebx
f0103767:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
        int cid = thiscpu->cpu_id;
f010376a:	e8 2c 26 00 00       	call   f0105d9b <cpunum>
f010376f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103772:	0f b6 98 40 00 23 f0 	movzbl -0xfdcffc0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103779:	e8 1d 26 00 00       	call   f0105d9b <cpunum>
f010377e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103781:	89 da                	mov    %ebx,%edx
f0103783:	f7 da                	neg    %edx
f0103785:	c1 e2 10             	shl    $0x10,%edx
f0103788:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010378e:	89 90 50 00 23 f0    	mov    %edx,-0xfdcffb0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103794:	e8 02 26 00 00       	call   f0105d9b <cpunum>
f0103799:	6b c0 74             	imul   $0x74,%eax,%eax
f010379c:	66 c7 80 54 00 23 f0 	movw   $0x10,-0xfdcffac(%eax)
f01037a3:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01037a5:	83 c3 05             	add    $0x5,%ebx
f01037a8:	e8 ee 25 00 00       	call   f0105d9b <cpunum>
f01037ad:	89 c7                	mov    %eax,%edi
f01037af:	e8 e7 25 00 00       	call   f0105d9b <cpunum>
f01037b4:	89 c6                	mov    %eax,%esi
f01037b6:	e8 e0 25 00 00       	call   f0105d9b <cpunum>
f01037bb:	66 c7 04 dd 80 03 12 	movw   $0x67,-0xfedfc80(,%ebx,8)
f01037c2:	f0 67 00 
f01037c5:	6b ff 74             	imul   $0x74,%edi,%edi
f01037c8:	81 c7 4c 00 23 f0    	add    $0xf023004c,%edi
f01037ce:	66 89 3c dd 82 03 12 	mov    %di,-0xfedfc7e(,%ebx,8)
f01037d5:	f0 
f01037d6:	6b d6 74             	imul   $0x74,%esi,%edx
f01037d9:	81 c2 4c 00 23 f0    	add    $0xf023004c,%edx
f01037df:	c1 ea 10             	shr    $0x10,%edx
f01037e2:	88 14 dd 84 03 12 f0 	mov    %dl,-0xfedfc7c(,%ebx,8)
f01037e9:	c6 04 dd 86 03 12 f0 	movb   $0x40,-0xfedfc7a(,%ebx,8)
f01037f0:	40 
f01037f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f4:	05 4c 00 23 f0       	add    $0xf023004c,%eax
f01037f9:	c1 e8 18             	shr    $0x18,%eax
f01037fc:	88 04 dd 87 03 12 f0 	mov    %al,-0xfedfc79(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f0103803:	c6 04 dd 85 03 12 f0 	movb   $0x89,-0xfedfc7b(,%ebx,8)
f010380a:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f010380b:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010380e:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103811:	b8 ea 03 12 f0       	mov    $0xf01203ea,%eax
f0103816:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103819:	83 c4 0c             	add    $0xc,%esp
f010381c:	5b                   	pop    %ebx
f010381d:	5e                   	pop    %esi
f010381e:	5f                   	pop    %edi
f010381f:	5d                   	pop    %ebp
f0103820:	c3                   	ret    

f0103821 <trap_init>:
}


void
trap_init(void)
{
f0103821:	55                   	push   %ebp
f0103822:	89 e5                	mov    %esp,%ebp
f0103824:	83 ec 08             	sub    $0x8,%esp
        extern void irq11();
        extern void irq12();
        extern void irq13();
        extern void irq14();
        extern void irq15();
        SETGATE(idt[0], 0, GD_KT, i0, 0);
f0103827:	b8 92 43 10 f0       	mov    $0xf0104392,%eax
f010382c:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f0103832:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f0103839:	08 00 
f010383b:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f0103842:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f0103849:	c1 e8 10             	shr    $0x10,%eax
f010384c:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
        SETGATE(idt[1], 0, GD_KT, i1, 0);
f0103852:	b8 9c 43 10 f0       	mov    $0xf010439c,%eax
f0103857:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f010385d:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103864:	08 00 
f0103866:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f010386d:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103874:	c1 e8 10             	shr    $0x10,%eax
f0103877:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
        SETGATE(idt[2], 0, GD_KT, i2, 0);
f010387d:	b8 a6 43 10 f0       	mov    $0xf01043a6,%eax
f0103882:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103888:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f010388f:	08 00 
f0103891:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103898:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f010389f:	c1 e8 10             	shr    $0x10,%eax
f01038a2:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
        SETGATE(idt[3], 0, GD_KT, i3, 3);
f01038a8:	b8 b0 43 10 f0       	mov    $0xf01043b0,%eax
f01038ad:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f01038b3:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f01038ba:	08 00 
f01038bc:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f01038c3:	c6 05 9d f2 22 f0 ee 	movb   $0xee,0xf022f29d
f01038ca:	c1 e8 10             	shr    $0x10,%eax
f01038cd:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
        SETGATE(idt[4], 0, GD_KT, i4, 0);
f01038d3:	b8 ba 43 10 f0       	mov    $0xf01043ba,%eax
f01038d8:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f01038de:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f01038e5:	08 00 
f01038e7:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f01038ee:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f01038f5:	c1 e8 10             	shr    $0x10,%eax
f01038f8:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
        SETGATE(idt[5], 0, GD_KT, i5, 0);
f01038fe:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103903:	66 a3 a8 f2 22 f0    	mov    %ax,0xf022f2a8
f0103909:	66 c7 05 aa f2 22 f0 	movw   $0x8,0xf022f2aa
f0103910:	08 00 
f0103912:	c6 05 ac f2 22 f0 00 	movb   $0x0,0xf022f2ac
f0103919:	c6 05 ad f2 22 f0 8e 	movb   $0x8e,0xf022f2ad
f0103920:	c1 e8 10             	shr    $0x10,%eax
f0103923:	66 a3 ae f2 22 f0    	mov    %ax,0xf022f2ae
        SETGATE(idt[6], 0, GD_KT, i6, 0);
f0103929:	b8 ce 43 10 f0       	mov    $0xf01043ce,%eax
f010392e:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103934:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f010393b:	08 00 
f010393d:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f0103944:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f010394b:	c1 e8 10             	shr    $0x10,%eax
f010394e:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
        SETGATE(idt[7], 0, GD_KT, i7, 0);
f0103954:	b8 d8 43 10 f0       	mov    $0xf01043d8,%eax
f0103959:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f010395f:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103966:	08 00 
f0103968:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f010396f:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103976:	c1 e8 10             	shr    $0x10,%eax
f0103979:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
        SETGATE(idt[8], 0, GD_KT, i8, 0);
f010397f:	b8 e2 43 10 f0       	mov    $0xf01043e2,%eax
f0103984:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f010398a:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103991:	08 00 
f0103993:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f010399a:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f01039a1:	c1 e8 10             	shr    $0x10,%eax
f01039a4:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
        SETGATE(idt[9], 0, GD_KT, i9, 0);
f01039aa:	b8 ea 43 10 f0       	mov    $0xf01043ea,%eax
f01039af:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f01039b5:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f01039bc:	08 00 
f01039be:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f01039c5:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f01039cc:	c1 e8 10             	shr    $0x10,%eax
f01039cf:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
        SETGATE(idt[10], 0, GD_KT, i10, 0);
f01039d5:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f01039da:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f01039e0:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f01039e7:	08 00 
f01039e9:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f01039f0:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f01039f7:	c1 e8 10             	shr    $0x10,%eax
f01039fa:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
        SETGATE(idt[11], 0, GD_KT, i11, 0);
f0103a00:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103a05:	66 a3 d8 f2 22 f0    	mov    %ax,0xf022f2d8
f0103a0b:	66 c7 05 da f2 22 f0 	movw   $0x8,0xf022f2da
f0103a12:	08 00 
f0103a14:	c6 05 dc f2 22 f0 00 	movb   $0x0,0xf022f2dc
f0103a1b:	c6 05 dd f2 22 f0 8e 	movb   $0x8e,0xf022f2dd
f0103a22:	c1 e8 10             	shr    $0x10,%eax
f0103a25:	66 a3 de f2 22 f0    	mov    %ax,0xf022f2de
        SETGATE(idt[12], 0, GD_KT, i12, 0);
f0103a2b:	b8 04 44 10 f0       	mov    $0xf0104404,%eax
f0103a30:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103a36:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103a3d:	08 00 
f0103a3f:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103a46:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103a4d:	c1 e8 10             	shr    $0x10,%eax
f0103a50:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
        SETGATE(idt[13], 0, GD_KT, i13, 0);
f0103a56:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103a5b:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103a61:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103a68:	08 00 
f0103a6a:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103a71:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103a78:	c1 e8 10             	shr    $0x10,%eax
f0103a7b:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
        SETGATE(idt[14], 0, GD_KT, i14, 0);
f0103a81:	b8 14 44 10 f0       	mov    $0xf0104414,%eax
f0103a86:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103a8c:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103a93:	08 00 
f0103a95:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103a9c:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103aa3:	c1 e8 10             	shr    $0x10,%eax
f0103aa6:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
        SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103aac:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103ab1:	66 a3 00 f3 22 f0    	mov    %ax,0xf022f300
f0103ab7:	66 c7 05 02 f3 22 f0 	movw   $0x8,0xf022f302
f0103abe:	08 00 
f0103ac0:	c6 05 04 f3 22 f0 00 	movb   $0x0,0xf022f304
f0103ac7:	c6 05 05 f3 22 f0 8e 	movb   $0x8e,0xf022f305
f0103ace:	c1 e8 10             	shr    $0x10,%eax
f0103ad1:	66 a3 06 f3 22 f0    	mov    %ax,0xf022f306
        SETGATE(idt[17], 0, GD_KT, i17, 0);
f0103ad7:	b8 28 44 10 f0       	mov    $0xf0104428,%eax
f0103adc:	66 a3 08 f3 22 f0    	mov    %ax,0xf022f308
f0103ae2:	66 c7 05 0a f3 22 f0 	movw   $0x8,0xf022f30a
f0103ae9:	08 00 
f0103aeb:	c6 05 0c f3 22 f0 00 	movb   $0x0,0xf022f30c
f0103af2:	c6 05 0d f3 22 f0 8e 	movb   $0x8e,0xf022f30d
f0103af9:	c1 e8 10             	shr    $0x10,%eax
f0103afc:	66 a3 0e f3 22 f0    	mov    %ax,0xf022f30e
        SETGATE(idt[18], 0, GD_KT, i18, 0);
f0103b02:	b8 2c 44 10 f0       	mov    $0xf010442c,%eax
f0103b07:	66 a3 10 f3 22 f0    	mov    %ax,0xf022f310
f0103b0d:	66 c7 05 12 f3 22 f0 	movw   $0x8,0xf022f312
f0103b14:	08 00 
f0103b16:	c6 05 14 f3 22 f0 00 	movb   $0x0,0xf022f314
f0103b1d:	c6 05 15 f3 22 f0 8e 	movb   $0x8e,0xf022f315
f0103b24:	c1 e8 10             	shr    $0x10,%eax
f0103b27:	66 a3 16 f3 22 f0    	mov    %ax,0xf022f316
        SETGATE(idt[19], 0, GD_KT, i19, 0);
f0103b2d:	b8 32 44 10 f0       	mov    $0xf0104432,%eax
f0103b32:	66 a3 18 f3 22 f0    	mov    %ax,0xf022f318
f0103b38:	66 c7 05 1a f3 22 f0 	movw   $0x8,0xf022f31a
f0103b3f:	08 00 
f0103b41:	c6 05 1c f3 22 f0 00 	movb   $0x0,0xf022f31c
f0103b48:	c6 05 1d f3 22 f0 8e 	movb   $0x8e,0xf022f31d
f0103b4f:	c1 e8 10             	shr    $0x10,%eax
f0103b52:	66 a3 1e f3 22 f0    	mov    %ax,0xf022f31e
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq0, 0);
f0103b58:	b8 3e 44 10 f0       	mov    $0xf010443e,%eax
f0103b5d:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103b63:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103b6a:	08 00 
f0103b6c:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103b73:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103b7a:	c1 e8 10             	shr    $0x10,%eax
f0103b7d:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
        SETGATE(idt[33], 0, GD_KT, irq1, 0);
f0103b83:	b8 44 44 10 f0       	mov    $0xf0104444,%eax
f0103b88:	66 a3 88 f3 22 f0    	mov    %ax,0xf022f388
f0103b8e:	66 c7 05 8a f3 22 f0 	movw   $0x8,0xf022f38a
f0103b95:	08 00 
f0103b97:	c6 05 8c f3 22 f0 00 	movb   $0x0,0xf022f38c
f0103b9e:	c6 05 8d f3 22 f0 8e 	movb   $0x8e,0xf022f38d
f0103ba5:	c1 e8 10             	shr    $0x10,%eax
f0103ba8:	66 a3 8e f3 22 f0    	mov    %ax,0xf022f38e
        SETGATE(idt[34], 0, GD_KT, irq2, 0);
f0103bae:	b8 4a 44 10 f0       	mov    $0xf010444a,%eax
f0103bb3:	66 a3 90 f3 22 f0    	mov    %ax,0xf022f390
f0103bb9:	66 c7 05 92 f3 22 f0 	movw   $0x8,0xf022f392
f0103bc0:	08 00 
f0103bc2:	c6 05 94 f3 22 f0 00 	movb   $0x0,0xf022f394
f0103bc9:	c6 05 95 f3 22 f0 8e 	movb   $0x8e,0xf022f395
f0103bd0:	c1 e8 10             	shr    $0x10,%eax
f0103bd3:	66 a3 96 f3 22 f0    	mov    %ax,0xf022f396
        SETGATE(idt[35], 0, GD_KT, irq3, 0);
f0103bd9:	b8 50 44 10 f0       	mov    $0xf0104450,%eax
f0103bde:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103be4:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103beb:	08 00 
f0103bed:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103bf4:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103bfb:	c1 e8 10             	shr    $0x10,%eax
f0103bfe:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
        SETGATE(idt[36], 0, GD_KT, irq4, 0);
f0103c04:	b8 56 44 10 f0       	mov    $0xf0104456,%eax
f0103c09:	66 a3 a0 f3 22 f0    	mov    %ax,0xf022f3a0
f0103c0f:	66 c7 05 a2 f3 22 f0 	movw   $0x8,0xf022f3a2
f0103c16:	08 00 
f0103c18:	c6 05 a4 f3 22 f0 00 	movb   $0x0,0xf022f3a4
f0103c1f:	c6 05 a5 f3 22 f0 8e 	movb   $0x8e,0xf022f3a5
f0103c26:	c1 e8 10             	shr    $0x10,%eax
f0103c29:	66 a3 a6 f3 22 f0    	mov    %ax,0xf022f3a6
        SETGATE(idt[37], 0, GD_KT, irq5, 0);
f0103c2f:	b8 5c 44 10 f0       	mov    $0xf010445c,%eax
f0103c34:	66 a3 a8 f3 22 f0    	mov    %ax,0xf022f3a8
f0103c3a:	66 c7 05 aa f3 22 f0 	movw   $0x8,0xf022f3aa
f0103c41:	08 00 
f0103c43:	c6 05 ac f3 22 f0 00 	movb   $0x0,0xf022f3ac
f0103c4a:	c6 05 ad f3 22 f0 8e 	movb   $0x8e,0xf022f3ad
f0103c51:	c1 e8 10             	shr    $0x10,%eax
f0103c54:	66 a3 ae f3 22 f0    	mov    %ax,0xf022f3ae
        SETGATE(idt[38], 0, GD_KT, irq6, 0);
f0103c5a:	b8 62 44 10 f0       	mov    $0xf0104462,%eax
f0103c5f:	66 a3 b0 f3 22 f0    	mov    %ax,0xf022f3b0
f0103c65:	66 c7 05 b2 f3 22 f0 	movw   $0x8,0xf022f3b2
f0103c6c:	08 00 
f0103c6e:	c6 05 b4 f3 22 f0 00 	movb   $0x0,0xf022f3b4
f0103c75:	c6 05 b5 f3 22 f0 8e 	movb   $0x8e,0xf022f3b5
f0103c7c:	c1 e8 10             	shr    $0x10,%eax
f0103c7f:	66 a3 b6 f3 22 f0    	mov    %ax,0xf022f3b6
        SETGATE(idt[39], 0, GD_KT, irq7, 0);
f0103c85:	b8 68 44 10 f0       	mov    $0xf0104468,%eax
f0103c8a:	66 a3 b8 f3 22 f0    	mov    %ax,0xf022f3b8
f0103c90:	66 c7 05 ba f3 22 f0 	movw   $0x8,0xf022f3ba
f0103c97:	08 00 
f0103c99:	c6 05 bc f3 22 f0 00 	movb   $0x0,0xf022f3bc
f0103ca0:	c6 05 bd f3 22 f0 8e 	movb   $0x8e,0xf022f3bd
f0103ca7:	c1 e8 10             	shr    $0x10,%eax
f0103caa:	66 a3 be f3 22 f0    	mov    %ax,0xf022f3be
        SETGATE(idt[40], 0, GD_KT, irq8, 0);
f0103cb0:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103cb5:	66 a3 c0 f3 22 f0    	mov    %ax,0xf022f3c0
f0103cbb:	66 c7 05 c2 f3 22 f0 	movw   $0x8,0xf022f3c2
f0103cc2:	08 00 
f0103cc4:	c6 05 c4 f3 22 f0 00 	movb   $0x0,0xf022f3c4
f0103ccb:	c6 05 c5 f3 22 f0 8e 	movb   $0x8e,0xf022f3c5
f0103cd2:	c1 e8 10             	shr    $0x10,%eax
f0103cd5:	66 a3 c6 f3 22 f0    	mov    %ax,0xf022f3c6
        SETGATE(idt[41], 0, GD_KT, irq9, 0);
f0103cdb:	b8 74 44 10 f0       	mov    $0xf0104474,%eax
f0103ce0:	66 a3 c8 f3 22 f0    	mov    %ax,0xf022f3c8
f0103ce6:	66 c7 05 ca f3 22 f0 	movw   $0x8,0xf022f3ca
f0103ced:	08 00 
f0103cef:	c6 05 cc f3 22 f0 00 	movb   $0x0,0xf022f3cc
f0103cf6:	c6 05 cd f3 22 f0 8e 	movb   $0x8e,0xf022f3cd
f0103cfd:	c1 e8 10             	shr    $0x10,%eax
f0103d00:	66 a3 ce f3 22 f0    	mov    %ax,0xf022f3ce
        SETGATE(idt[42], 0, GD_KT, irq10, 0);
f0103d06:	b8 7a 44 10 f0       	mov    $0xf010447a,%eax
f0103d0b:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103d11:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103d18:	08 00 
f0103d1a:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103d21:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103d28:	c1 e8 10             	shr    $0x10,%eax
f0103d2b:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
        SETGATE(idt[43], 0, GD_KT, irq11, 0);
f0103d31:	b8 80 44 10 f0       	mov    $0xf0104480,%eax
f0103d36:	66 a3 d8 f3 22 f0    	mov    %ax,0xf022f3d8
f0103d3c:	66 c7 05 da f3 22 f0 	movw   $0x8,0xf022f3da
f0103d43:	08 00 
f0103d45:	c6 05 dc f3 22 f0 00 	movb   $0x0,0xf022f3dc
f0103d4c:	c6 05 dd f3 22 f0 8e 	movb   $0x8e,0xf022f3dd
f0103d53:	c1 e8 10             	shr    $0x10,%eax
f0103d56:	66 a3 de f3 22 f0    	mov    %ax,0xf022f3de
        SETGATE(idt[44], 0, GD_KT, irq12, 0);
f0103d5c:	b8 86 44 10 f0       	mov    $0xf0104486,%eax
f0103d61:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103d67:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103d6e:	08 00 
f0103d70:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103d77:	c6 05 e5 f3 22 f0 8e 	movb   $0x8e,0xf022f3e5
f0103d7e:	c1 e8 10             	shr    $0x10,%eax
f0103d81:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6
        SETGATE(idt[45], 0, GD_KT, irq13, 0);
f0103d87:	b8 8c 44 10 f0       	mov    $0xf010448c,%eax
f0103d8c:	66 a3 e8 f3 22 f0    	mov    %ax,0xf022f3e8
f0103d92:	66 c7 05 ea f3 22 f0 	movw   $0x8,0xf022f3ea
f0103d99:	08 00 
f0103d9b:	c6 05 ec f3 22 f0 00 	movb   $0x0,0xf022f3ec
f0103da2:	c6 05 ed f3 22 f0 8e 	movb   $0x8e,0xf022f3ed
f0103da9:	c1 e8 10             	shr    $0x10,%eax
f0103dac:	66 a3 ee f3 22 f0    	mov    %ax,0xf022f3ee
        SETGATE(idt[46], 0, GD_KT, irq14, 0);
f0103db2:	b8 92 44 10 f0       	mov    $0xf0104492,%eax
f0103db7:	66 a3 f0 f3 22 f0    	mov    %ax,0xf022f3f0
f0103dbd:	66 c7 05 f2 f3 22 f0 	movw   $0x8,0xf022f3f2
f0103dc4:	08 00 
f0103dc6:	c6 05 f4 f3 22 f0 00 	movb   $0x0,0xf022f3f4
f0103dcd:	c6 05 f5 f3 22 f0 8e 	movb   $0x8e,0xf022f3f5
f0103dd4:	c1 e8 10             	shr    $0x10,%eax
f0103dd7:	66 a3 f6 f3 22 f0    	mov    %ax,0xf022f3f6
        SETGATE(idt[47], 0, GD_KT, irq15, 0);
f0103ddd:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103de2:	66 a3 f8 f3 22 f0    	mov    %ax,0xf022f3f8
f0103de8:	66 c7 05 fa f3 22 f0 	movw   $0x8,0xf022f3fa
f0103def:	08 00 
f0103df1:	c6 05 fc f3 22 f0 00 	movb   $0x0,0xf022f3fc
f0103df8:	c6 05 fd f3 22 f0 8e 	movb   $0x8e,0xf022f3fd
f0103dff:	c1 e8 10             	shr    $0x10,%eax
f0103e02:	66 a3 fe f3 22 f0    	mov    %ax,0xf022f3fe
        SETGATE(idt[48], 0, GD_KT, i20, 3);
f0103e08:	b8 38 44 10 f0       	mov    $0xf0104438,%eax
f0103e0d:	66 a3 00 f4 22 f0    	mov    %ax,0xf022f400
f0103e13:	66 c7 05 02 f4 22 f0 	movw   $0x8,0xf022f402
f0103e1a:	08 00 
f0103e1c:	c6 05 04 f4 22 f0 00 	movb   $0x0,0xf022f404
f0103e23:	c6 05 05 f4 22 f0 ee 	movb   $0xee,0xf022f405
f0103e2a:	c1 e8 10             	shr    $0x10,%eax
f0103e2d:	66 a3 06 f4 22 f0    	mov    %ax,0xf022f406
	// Per-CPU setup 
	trap_init_percpu();
f0103e33:	e8 29 f9 ff ff       	call   f0103761 <trap_init_percpu>
}
f0103e38:	c9                   	leave  
f0103e39:	c3                   	ret    

f0103e3a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e3a:	55                   	push   %ebp
f0103e3b:	89 e5                	mov    %esp,%ebp
f0103e3d:	53                   	push   %ebx
f0103e3e:	83 ec 0c             	sub    $0xc,%esp
f0103e41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e44:	ff 33                	pushl  (%ebx)
f0103e46:	68 26 77 10 f0       	push   $0xf0107726
f0103e4b:	e8 fd f8 ff ff       	call   f010374d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e50:	83 c4 08             	add    $0x8,%esp
f0103e53:	ff 73 04             	pushl  0x4(%ebx)
f0103e56:	68 35 77 10 f0       	push   $0xf0107735
f0103e5b:	e8 ed f8 ff ff       	call   f010374d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e60:	83 c4 08             	add    $0x8,%esp
f0103e63:	ff 73 08             	pushl  0x8(%ebx)
f0103e66:	68 44 77 10 f0       	push   $0xf0107744
f0103e6b:	e8 dd f8 ff ff       	call   f010374d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e70:	83 c4 08             	add    $0x8,%esp
f0103e73:	ff 73 0c             	pushl  0xc(%ebx)
f0103e76:	68 53 77 10 f0       	push   $0xf0107753
f0103e7b:	e8 cd f8 ff ff       	call   f010374d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e80:	83 c4 08             	add    $0x8,%esp
f0103e83:	ff 73 10             	pushl  0x10(%ebx)
f0103e86:	68 62 77 10 f0       	push   $0xf0107762
f0103e8b:	e8 bd f8 ff ff       	call   f010374d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e90:	83 c4 08             	add    $0x8,%esp
f0103e93:	ff 73 14             	pushl  0x14(%ebx)
f0103e96:	68 71 77 10 f0       	push   $0xf0107771
f0103e9b:	e8 ad f8 ff ff       	call   f010374d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ea0:	83 c4 08             	add    $0x8,%esp
f0103ea3:	ff 73 18             	pushl  0x18(%ebx)
f0103ea6:	68 80 77 10 f0       	push   $0xf0107780
f0103eab:	e8 9d f8 ff ff       	call   f010374d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	ff 73 1c             	pushl  0x1c(%ebx)
f0103eb6:	68 8f 77 10 f0       	push   $0xf010778f
f0103ebb:	e8 8d f8 ff ff       	call   f010374d <cprintf>
f0103ec0:	83 c4 10             	add    $0x10,%esp
}
f0103ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ec6:	c9                   	leave  
f0103ec7:	c3                   	ret    

f0103ec8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ec8:	55                   	push   %ebp
f0103ec9:	89 e5                	mov    %esp,%ebp
f0103ecb:	56                   	push   %esi
f0103ecc:	53                   	push   %ebx
f0103ecd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103ed0:	e8 c6 1e 00 00       	call   f0105d9b <cpunum>
f0103ed5:	83 ec 04             	sub    $0x4,%esp
f0103ed8:	50                   	push   %eax
f0103ed9:	53                   	push   %ebx
f0103eda:	68 f3 77 10 f0       	push   $0xf01077f3
f0103edf:	e8 69 f8 ff ff       	call   f010374d <cprintf>
	print_regs(&tf->tf_regs);
f0103ee4:	89 1c 24             	mov    %ebx,(%esp)
f0103ee7:	e8 4e ff ff ff       	call   f0103e3a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eec:	83 c4 08             	add    $0x8,%esp
f0103eef:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ef3:	50                   	push   %eax
f0103ef4:	68 11 78 10 f0       	push   $0xf0107811
f0103ef9:	e8 4f f8 ff ff       	call   f010374d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103efe:	83 c4 08             	add    $0x8,%esp
f0103f01:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f05:	50                   	push   %eax
f0103f06:	68 24 78 10 f0       	push   $0xf0107824
f0103f0b:	e8 3d f8 ff ff       	call   f010374d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f10:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103f13:	83 c4 10             	add    $0x10,%esp
f0103f16:	83 f8 13             	cmp    $0x13,%eax
f0103f19:	77 09                	ja     f0103f24 <print_trapframe+0x5c>
		return excnames[trapno];
f0103f1b:	8b 14 85 00 7b 10 f0 	mov    -0xfef8500(,%eax,4),%edx
f0103f22:	eb 1f                	jmp    f0103f43 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103f24:	83 f8 30             	cmp    $0x30,%eax
f0103f27:	74 15                	je     f0103f3e <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f29:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103f2c:	83 fa 10             	cmp    $0x10,%edx
f0103f2f:	b9 bd 77 10 f0       	mov    $0xf01077bd,%ecx
f0103f34:	ba aa 77 10 f0       	mov    $0xf01077aa,%edx
f0103f39:	0f 43 d1             	cmovae %ecx,%edx
f0103f3c:	eb 05                	jmp    f0103f43 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f3e:	ba 9e 77 10 f0       	mov    $0xf010779e,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f43:	83 ec 04             	sub    $0x4,%esp
f0103f46:	52                   	push   %edx
f0103f47:	50                   	push   %eax
f0103f48:	68 37 78 10 f0       	push   $0xf0107837
f0103f4d:	e8 fb f7 ff ff       	call   f010374d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f52:	83 c4 10             	add    $0x10,%esp
f0103f55:	3b 1d 80 fa 22 f0    	cmp    0xf022fa80,%ebx
f0103f5b:	75 1a                	jne    f0103f77 <print_trapframe+0xaf>
f0103f5d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f61:	75 14                	jne    f0103f77 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f63:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f66:	83 ec 08             	sub    $0x8,%esp
f0103f69:	50                   	push   %eax
f0103f6a:	68 49 78 10 f0       	push   $0xf0107849
f0103f6f:	e8 d9 f7 ff ff       	call   f010374d <cprintf>
f0103f74:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f77:	83 ec 08             	sub    $0x8,%esp
f0103f7a:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f7d:	68 58 78 10 f0       	push   $0xf0107858
f0103f82:	e8 c6 f7 ff ff       	call   f010374d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f87:	83 c4 10             	add    $0x10,%esp
f0103f8a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f8e:	75 49                	jne    f0103fd9 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f90:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f93:	89 c2                	mov    %eax,%edx
f0103f95:	83 e2 01             	and    $0x1,%edx
f0103f98:	ba d7 77 10 f0       	mov    $0xf01077d7,%edx
f0103f9d:	b9 cc 77 10 f0       	mov    $0xf01077cc,%ecx
f0103fa2:	0f 44 ca             	cmove  %edx,%ecx
f0103fa5:	89 c2                	mov    %eax,%edx
f0103fa7:	83 e2 02             	and    $0x2,%edx
f0103faa:	ba e9 77 10 f0       	mov    $0xf01077e9,%edx
f0103faf:	be e3 77 10 f0       	mov    $0xf01077e3,%esi
f0103fb4:	0f 45 d6             	cmovne %esi,%edx
f0103fb7:	83 e0 04             	and    $0x4,%eax
f0103fba:	be 36 79 10 f0       	mov    $0xf0107936,%esi
f0103fbf:	b8 ee 77 10 f0       	mov    $0xf01077ee,%eax
f0103fc4:	0f 44 c6             	cmove  %esi,%eax
f0103fc7:	51                   	push   %ecx
f0103fc8:	52                   	push   %edx
f0103fc9:	50                   	push   %eax
f0103fca:	68 66 78 10 f0       	push   $0xf0107866
f0103fcf:	e8 79 f7 ff ff       	call   f010374d <cprintf>
f0103fd4:	83 c4 10             	add    $0x10,%esp
f0103fd7:	eb 10                	jmp    f0103fe9 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fd9:	83 ec 0c             	sub    $0xc,%esp
f0103fdc:	68 33 6d 10 f0       	push   $0xf0106d33
f0103fe1:	e8 67 f7 ff ff       	call   f010374d <cprintf>
f0103fe6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fe9:	83 ec 08             	sub    $0x8,%esp
f0103fec:	ff 73 30             	pushl  0x30(%ebx)
f0103fef:	68 75 78 10 f0       	push   $0xf0107875
f0103ff4:	e8 54 f7 ff ff       	call   f010374d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ff9:	83 c4 08             	add    $0x8,%esp
f0103ffc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104000:	50                   	push   %eax
f0104001:	68 84 78 10 f0       	push   $0xf0107884
f0104006:	e8 42 f7 ff ff       	call   f010374d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010400b:	83 c4 08             	add    $0x8,%esp
f010400e:	ff 73 38             	pushl  0x38(%ebx)
f0104011:	68 97 78 10 f0       	push   $0xf0107897
f0104016:	e8 32 f7 ff ff       	call   f010374d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010401b:	83 c4 10             	add    $0x10,%esp
f010401e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104022:	74 25                	je     f0104049 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104024:	83 ec 08             	sub    $0x8,%esp
f0104027:	ff 73 3c             	pushl  0x3c(%ebx)
f010402a:	68 a6 78 10 f0       	push   $0xf01078a6
f010402f:	e8 19 f7 ff ff       	call   f010374d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104034:	83 c4 08             	add    $0x8,%esp
f0104037:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010403b:	50                   	push   %eax
f010403c:	68 b5 78 10 f0       	push   $0xf01078b5
f0104041:	e8 07 f7 ff ff       	call   f010374d <cprintf>
f0104046:	83 c4 10             	add    $0x10,%esp
	}
}
f0104049:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010404c:	5b                   	pop    %ebx
f010404d:	5e                   	pop    %esi
f010404e:	5d                   	pop    %ebp
f010404f:	c3                   	ret    

f0104050 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104050:	55                   	push   %ebp
f0104051:	89 e5                	mov    %esp,%ebp
f0104053:	57                   	push   %edi
f0104054:	56                   	push   %esi
f0104055:	53                   	push   %ebx
f0104056:	83 ec 0c             	sub    $0xc,%esp
f0104059:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010405c:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if ((tf->tf_cs & 3) == 0)
f010405f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104063:	75 17                	jne    f010407c <page_fault_handler+0x2c>
                panic("Kernel page fault!");
f0104065:	83 ec 04             	sub    $0x4,%esp
f0104068:	68 c8 78 10 f0       	push   $0xf01078c8
f010406d:	68 71 01 00 00       	push   $0x171
f0104072:	68 db 78 10 f0       	push   $0xf01078db
f0104077:	e8 c4 bf ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        if(curenv->env_pgfault_upcall) {
f010407c:	e8 1a 1d 00 00       	call   f0105d9b <cpunum>
f0104081:	6b c0 74             	imul   $0x74,%eax,%eax
f0104084:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010408a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010408e:	0f 84 8b 00 00 00    	je     f010411f <page_fault_handler+0xcf>
                struct UTrapframe *utf;
                if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&  tf->tf_esp <= UXSTACKTOP-1)  
f0104094:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104097:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                        utf = (struct UTrapframe *) ((void *)tf->tf_esp - sizeof(struct UTrapframe) -4);
f010409d:	83 e8 38             	sub    $0x38,%eax
f01040a0:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01040a6:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01040ab:	0f 46 d0             	cmovbe %eax,%edx
f01040ae:	89 d7                	mov    %edx,%edi
                else
                        utf = (struct UTrapframe *) ((void *)UXSTACKTOP - sizeof(struct UTrapframe));
                user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f01040b0:	e8 e6 1c 00 00       	call   f0105d9b <cpunum>
f01040b5:	6a 03                	push   $0x3
f01040b7:	6a 34                	push   $0x34
f01040b9:	57                   	push   %edi
f01040ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01040bd:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f01040c3:	e8 3e ed ff ff       	call   f0102e06 <user_mem_assert>
                utf->utf_fault_va = fault_va;
f01040c8:	89 fa                	mov    %edi,%edx
f01040ca:	89 37                	mov    %esi,(%edi)
                utf->utf_err = tf->tf_err;
f01040cc:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040cf:	89 47 04             	mov    %eax,0x4(%edi)
                utf->utf_regs = tf->tf_regs;
f01040d2:	8d 7f 08             	lea    0x8(%edi),%edi
f01040d5:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040da:	89 de                	mov    %ebx,%esi
f01040dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
                utf->utf_eip = tf->tf_eip;
f01040de:	8b 43 30             	mov    0x30(%ebx),%eax
f01040e1:	89 42 28             	mov    %eax,0x28(%edx)
                utf->utf_eflags = tf->tf_eflags;
f01040e4:	8b 43 38             	mov    0x38(%ebx),%eax
f01040e7:	89 d7                	mov    %edx,%edi
f01040e9:	89 42 2c             	mov    %eax,0x2c(%edx)
                utf->utf_esp = tf->tf_esp;
f01040ec:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040ef:	89 42 30             	mov    %eax,0x30(%edx)
                tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f01040f2:	e8 a4 1c 00 00       	call   f0105d9b <cpunum>
f01040f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fa:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104100:	8b 40 64             	mov    0x64(%eax),%eax
f0104103:	89 43 30             	mov    %eax,0x30(%ebx)
                tf->tf_esp = (uintptr_t)utf;
f0104106:	89 7b 3c             	mov    %edi,0x3c(%ebx)
                env_run(curenv);
f0104109:	e8 8d 1c 00 00       	call   f0105d9b <cpunum>
f010410e:	83 c4 04             	add    $0x4,%esp
f0104111:	6b c0 74             	imul   $0x74,%eax,%eax
f0104114:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f010411a:	e8 e6 f3 ff ff       	call   f0103505 <env_run>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
f010411f:	83 ec 0c             	sub    $0xc,%esp
f0104122:	68 80 7a 10 f0       	push   $0xf0107a80
f0104127:	e8 21 f6 ff ff       	call   f010374d <cprintf>
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010412c:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010412f:	e8 67 1c 00 00       	call   f0105d9b <cpunum>
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104134:	57                   	push   %edi
f0104135:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104136:	6b c0 74             	imul   $0x74,%eax,%eax
        } else {
                cprintf("curenv->env_pgfault_upcall is NULL\n");
        }
               
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104139:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010413f:	ff 70 48             	pushl  0x48(%eax)
f0104142:	68 a4 7a 10 f0       	push   $0xf0107aa4
f0104147:	e8 01 f6 ff ff       	call   f010374d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010414c:	83 c4 14             	add    $0x14,%esp
f010414f:	53                   	push   %ebx
f0104150:	e8 73 fd ff ff       	call   f0103ec8 <print_trapframe>
	env_destroy(curenv);
f0104155:	e8 41 1c 00 00       	call   f0105d9b <cpunum>
f010415a:	83 c4 04             	add    $0x4,%esp
f010415d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104160:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104166:	e8 fb f2 ff ff       	call   f0103466 <env_destroy>
f010416b:	83 c4 10             	add    $0x10,%esp
}
f010416e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104171:	5b                   	pop    %ebx
f0104172:	5e                   	pop    %esi
f0104173:	5f                   	pop    %edi
f0104174:	5d                   	pop    %ebp
f0104175:	c3                   	ret    

f0104176 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104176:	55                   	push   %ebp
f0104177:	89 e5                	mov    %esp,%ebp
f0104179:	57                   	push   %edi
f010417a:	56                   	push   %esi
f010417b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010417e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010417f:	83 3d c0 fe 22 f0 00 	cmpl   $0x0,0xf022fec0
f0104186:	74 01                	je     f0104189 <trap+0x13>
		asm volatile("hlt");
f0104188:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104189:	e8 0d 1c 00 00       	call   f0105d9b <cpunum>
f010418e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104191:	81 c2 40 00 23 f0    	add    $0xf0230040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104197:	b8 01 00 00 00       	mov    $0x1,%eax
f010419c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01041a0:	83 f8 02             	cmp    $0x2,%eax
f01041a3:	75 10                	jne    f01041b5 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01041a5:	83 ec 0c             	sub    $0xc,%esp
f01041a8:	68 00 04 12 f0       	push   $0xf0120400
f01041ad:	e8 54 1e 00 00       	call   f0106006 <spin_lock>
f01041b2:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01041b5:	9c                   	pushf  
f01041b6:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01041b7:	f6 c4 02             	test   $0x2,%ah
f01041ba:	74 19                	je     f01041d5 <trap+0x5f>
f01041bc:	68 e7 78 10 f0       	push   $0xf01078e7
f01041c1:	68 44 6a 10 f0       	push   $0xf0106a44
f01041c6:	68 3b 01 00 00       	push   $0x13b
f01041cb:	68 db 78 10 f0       	push   $0xf01078db
f01041d0:	e8 6b be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041d5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041d9:	83 e0 03             	and    $0x3,%eax
f01041dc:	66 83 f8 03          	cmp    $0x3,%ax
f01041e0:	0f 85 a0 00 00 00    	jne    f0104286 <trap+0x110>
f01041e6:	83 ec 0c             	sub    $0xc,%esp
f01041e9:	68 00 04 12 f0       	push   $0xf0120400
f01041ee:	e8 13 1e 00 00       	call   f0106006 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f01041f3:	e8 a3 1b 00 00       	call   f0105d9b <cpunum>
f01041f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fb:	83 c4 10             	add    $0x10,%esp
f01041fe:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f0104205:	75 19                	jne    f0104220 <trap+0xaa>
f0104207:	68 00 79 10 f0       	push   $0xf0107900
f010420c:	68 44 6a 10 f0       	push   $0xf0106a44
f0104211:	68 43 01 00 00       	push   $0x143
f0104216:	68 db 78 10 f0       	push   $0xf01078db
f010421b:	e8 20 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104220:	e8 76 1b 00 00       	call   f0105d9b <cpunum>
f0104225:	6b c0 74             	imul   $0x74,%eax,%eax
f0104228:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010422e:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104232:	75 2d                	jne    f0104261 <trap+0xeb>
			env_free(curenv);
f0104234:	e8 62 1b 00 00       	call   f0105d9b <cpunum>
f0104239:	83 ec 0c             	sub    $0xc,%esp
f010423c:	6b c0 74             	imul   $0x74,%eax,%eax
f010423f:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104245:	e8 41 f0 ff ff       	call   f010328b <env_free>
			curenv = NULL;
f010424a:	e8 4c 1b 00 00       	call   f0105d9b <cpunum>
f010424f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104252:	c7 80 48 00 23 f0 00 	movl   $0x0,-0xfdcffb8(%eax)
f0104259:	00 00 00 
			sched_yield();
f010425c:	e8 23 03 00 00       	call   f0104584 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104261:	e8 35 1b 00 00       	call   f0105d9b <cpunum>
f0104266:	6b c0 74             	imul   $0x74,%eax,%eax
f0104269:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010426f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104274:	89 c7                	mov    %eax,%edi
f0104276:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104278:	e8 1e 1b 00 00       	call   f0105d9b <cpunum>
f010427d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104280:	8b b0 48 00 23 f0    	mov    -0xfdcffb8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104286:	89 35 80 fa 22 f0    	mov    %esi,0xf022fa80
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
        
        if(tf->tf_trapno == T_PGFLT ) {
f010428c:	8b 46 28             	mov    0x28(%esi),%eax
f010428f:	83 f8 0e             	cmp    $0xe,%eax
f0104292:	75 11                	jne    f01042a5 <trap+0x12f>
                page_fault_handler(tf);
f0104294:	83 ec 0c             	sub    $0xc,%esp
f0104297:	56                   	push   %esi
f0104298:	e8 b3 fd ff ff       	call   f0104050 <page_fault_handler>
f010429d:	83 c4 10             	add    $0x10,%esp
f01042a0:	e9 ad 00 00 00       	jmp    f0104352 <trap+0x1dc>
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
f01042a5:	83 f8 03             	cmp    $0x3,%eax
f01042a8:	75 11                	jne    f01042bb <trap+0x145>
                monitor(tf);
f01042aa:	83 ec 0c             	sub    $0xc,%esp
f01042ad:	56                   	push   %esi
f01042ae:	e8 bf c6 ff ff       	call   f0100972 <monitor>
f01042b3:	83 c4 10             	add    $0x10,%esp
f01042b6:	e9 97 00 00 00       	jmp    f0104352 <trap+0x1dc>
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
f01042bb:	83 f8 30             	cmp    $0x30,%eax
f01042be:	75 21                	jne    f01042e1 <trap+0x16b>
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01042c0:	83 ec 08             	sub    $0x8,%esp
f01042c3:	ff 76 04             	pushl  0x4(%esi)
f01042c6:	ff 36                	pushl  (%esi)
f01042c8:	ff 76 10             	pushl  0x10(%esi)
f01042cb:	ff 76 18             	pushl  0x18(%esi)
f01042ce:	ff 76 14             	pushl  0x14(%esi)
f01042d1:	ff 76 1c             	pushl  0x1c(%esi)
f01042d4:	e8 85 03 00 00       	call   f010465e <syscall>
f01042d9:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042dc:	83 c4 20             	add    $0x20,%esp
f01042df:	eb 71                	jmp    f0104352 <trap+0x1dc>
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042e1:	83 f8 27             	cmp    $0x27,%eax
f01042e4:	75 1a                	jne    f0104300 <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f01042e6:	83 ec 0c             	sub    $0xc,%esp
f01042e9:	68 07 79 10 f0       	push   $0xf0107907
f01042ee:	e8 5a f4 ff ff       	call   f010374d <cprintf>
		print_trapframe(tf);
f01042f3:	89 34 24             	mov    %esi,(%esp)
f01042f6:	e8 cd fb ff ff       	call   f0103ec8 <print_trapframe>
f01042fb:	83 c4 10             	add    $0x10,%esp
f01042fe:	eb 52                	jmp    f0104352 <trap+0x1dc>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104300:	83 f8 20             	cmp    $0x20,%eax
f0104303:	75 0a                	jne    f010430f <trap+0x199>
		lapic_eoi();
f0104305:	e8 dc 1b 00 00       	call   f0105ee6 <lapic_eoi>
                sched_yield();
f010430a:	e8 75 02 00 00       	call   f0104584 <sched_yield>
	}
//=======
       

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010430f:	83 ec 0c             	sub    $0xc,%esp
f0104312:	56                   	push   %esi
f0104313:	e8 b0 fb ff ff       	call   f0103ec8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104318:	83 c4 10             	add    $0x10,%esp
f010431b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104320:	75 17                	jne    f0104339 <trap+0x1c3>
		panic("unhandled trap in kernel");
f0104322:	83 ec 04             	sub    $0x4,%esp
f0104325:	68 24 79 10 f0       	push   $0xf0107924
f010432a:	68 21 01 00 00       	push   $0x121
f010432f:	68 db 78 10 f0       	push   $0xf01078db
f0104334:	e8 07 bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104339:	e8 5d 1a 00 00       	call   f0105d9b <cpunum>
f010433e:	83 ec 0c             	sub    $0xc,%esp
f0104341:	6b c0 74             	imul   $0x74,%eax,%eax
f0104344:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f010434a:	e8 17 f1 ff ff       	call   f0103466 <env_destroy>
f010434f:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104352:	e8 44 1a 00 00       	call   f0105d9b <cpunum>
f0104357:	6b c0 74             	imul   $0x74,%eax,%eax
f010435a:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f0104361:	74 2a                	je     f010438d <trap+0x217>
f0104363:	e8 33 1a 00 00       	call   f0105d9b <cpunum>
f0104368:	6b c0 74             	imul   $0x74,%eax,%eax
f010436b:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104371:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104375:	75 16                	jne    f010438d <trap+0x217>
		env_run(curenv);
f0104377:	e8 1f 1a 00 00       	call   f0105d9b <cpunum>
f010437c:	83 ec 0c             	sub    $0xc,%esp
f010437f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104382:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104388:	e8 78 f1 ff ff       	call   f0103505 <env_run>
	else
		sched_yield();
f010438d:	e8 f2 01 00 00       	call   f0104584 <sched_yield>

f0104392 <i0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(i0, T_DIVIDE)
f0104392:	6a 00                	push   $0x0
f0104394:	6a 00                	push   $0x0
f0104396:	e9 03 01 00 00       	jmp    f010449e <_alltraps>
f010439b:	90                   	nop

f010439c <i1>:
TRAPHANDLER_NOEC(i1, T_DEBUG)
f010439c:	6a 00                	push   $0x0
f010439e:	6a 01                	push   $0x1
f01043a0:	e9 f9 00 00 00       	jmp    f010449e <_alltraps>
f01043a5:	90                   	nop

f01043a6 <i2>:
TRAPHANDLER_NOEC(i2, T_NMI)
f01043a6:	6a 00                	push   $0x0
f01043a8:	6a 02                	push   $0x2
f01043aa:	e9 ef 00 00 00       	jmp    f010449e <_alltraps>
f01043af:	90                   	nop

f01043b0 <i3>:
TRAPHANDLER_NOEC(i3, T_BRKPT)
f01043b0:	6a 00                	push   $0x0
f01043b2:	6a 03                	push   $0x3
f01043b4:	e9 e5 00 00 00       	jmp    f010449e <_alltraps>
f01043b9:	90                   	nop

f01043ba <i4>:
TRAPHANDLER_NOEC(i4, T_OFLOW)
f01043ba:	6a 00                	push   $0x0
f01043bc:	6a 04                	push   $0x4
f01043be:	e9 db 00 00 00       	jmp    f010449e <_alltraps>
f01043c3:	90                   	nop

f01043c4 <i5>:
TRAPHANDLER_NOEC(i5, T_BOUND)
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 05                	push   $0x5
f01043c8:	e9 d1 00 00 00       	jmp    f010449e <_alltraps>
f01043cd:	90                   	nop

f01043ce <i6>:
TRAPHANDLER_NOEC(i6, T_ILLOP)
f01043ce:	6a 00                	push   $0x0
f01043d0:	6a 06                	push   $0x6
f01043d2:	e9 c7 00 00 00       	jmp    f010449e <_alltraps>
f01043d7:	90                   	nop

f01043d8 <i7>:
TRAPHANDLER_NOEC(i7, T_DEVICE)
f01043d8:	6a 00                	push   $0x0
f01043da:	6a 07                	push   $0x7
f01043dc:	e9 bd 00 00 00       	jmp    f010449e <_alltraps>
f01043e1:	90                   	nop

f01043e2 <i8>:
TRAPHANDLER(i8, T_DBLFLT)
f01043e2:	6a 08                	push   $0x8
f01043e4:	e9 b5 00 00 00       	jmp    f010449e <_alltraps>
f01043e9:	90                   	nop

f01043ea <i9>:
TRAPHANDLER_NOEC(i9, 9)
f01043ea:	6a 00                	push   $0x0
f01043ec:	6a 09                	push   $0x9
f01043ee:	e9 ab 00 00 00       	jmp    f010449e <_alltraps>
f01043f3:	90                   	nop

f01043f4 <i10>:
TRAPHANDLER(i10, T_TSS)
f01043f4:	6a 0a                	push   $0xa
f01043f6:	e9 a3 00 00 00       	jmp    f010449e <_alltraps>
f01043fb:	90                   	nop

f01043fc <i11>:
TRAPHANDLER(i11, T_SEGNP)
f01043fc:	6a 0b                	push   $0xb
f01043fe:	e9 9b 00 00 00       	jmp    f010449e <_alltraps>
f0104403:	90                   	nop

f0104404 <i12>:
TRAPHANDLER(i12, T_STACK)
f0104404:	6a 0c                	push   $0xc
f0104406:	e9 93 00 00 00       	jmp    f010449e <_alltraps>
f010440b:	90                   	nop

f010440c <i13>:
TRAPHANDLER(i13, T_GPFLT)
f010440c:	6a 0d                	push   $0xd
f010440e:	e9 8b 00 00 00       	jmp    f010449e <_alltraps>
f0104413:	90                   	nop

f0104414 <i14>:
TRAPHANDLER(i14, T_PGFLT)
f0104414:	6a 0e                	push   $0xe
f0104416:	e9 83 00 00 00       	jmp    f010449e <_alltraps>
f010441b:	90                   	nop

f010441c <i15>:
TRAPHANDLER_NOEC(i15, 15)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 0f                	push   $0xf
f0104420:	eb 7c                	jmp    f010449e <_alltraps>

f0104422 <i16>:
TRAPHANDLER_NOEC(i16, T_FPERR)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 10                	push   $0x10
f0104426:	eb 76                	jmp    f010449e <_alltraps>

f0104428 <i17>:
TRAPHANDLER(i17, T_ALIGN)
f0104428:	6a 11                	push   $0x11
f010442a:	eb 72                	jmp    f010449e <_alltraps>

f010442c <i18>:
TRAPHANDLER_NOEC(i18, T_MCHK)
f010442c:	6a 00                	push   $0x0
f010442e:	6a 12                	push   $0x12
f0104430:	eb 6c                	jmp    f010449e <_alltraps>

f0104432 <i19>:
TRAPHANDLER_NOEC(i19, T_SIMDERR)
f0104432:	6a 00                	push   $0x0
f0104434:	6a 13                	push   $0x13
f0104436:	eb 66                	jmp    f010449e <_alltraps>

f0104438 <i20>:
TRAPHANDLER_NOEC(i20, T_SYSCALL)
f0104438:	6a 00                	push   $0x0
f010443a:	6a 30                	push   $0x30
f010443c:	eb 60                	jmp    f010449e <_alltraps>

f010443e <irq0>:

TRAPHANDLER_NOEC(irq0, IRQ_OFFSET + IRQ_TIMER)
f010443e:	6a 00                	push   $0x0
f0104440:	6a 20                	push   $0x20
f0104442:	eb 5a                	jmp    f010449e <_alltraps>

f0104444 <irq1>:
TRAPHANDLER_NOEC(irq1, 33) 
f0104444:	6a 00                	push   $0x0
f0104446:	6a 21                	push   $0x21
f0104448:	eb 54                	jmp    f010449e <_alltraps>

f010444a <irq2>:
TRAPHANDLER_NOEC(irq2, 34)
f010444a:	6a 00                	push   $0x0
f010444c:	6a 22                	push   $0x22
f010444e:	eb 4e                	jmp    f010449e <_alltraps>

f0104450 <irq3>:
TRAPHANDLER_NOEC(irq3, 35)
f0104450:	6a 00                	push   $0x0
f0104452:	6a 23                	push   $0x23
f0104454:	eb 48                	jmp    f010449e <_alltraps>

f0104456 <irq4>:
TRAPHANDLER_NOEC(irq4, 36)
f0104456:	6a 00                	push   $0x0
f0104458:	6a 24                	push   $0x24
f010445a:	eb 42                	jmp    f010449e <_alltraps>

f010445c <irq5>:
TRAPHANDLER_NOEC(irq5, 37) 
f010445c:	6a 00                	push   $0x0
f010445e:	6a 25                	push   $0x25
f0104460:	eb 3c                	jmp    f010449e <_alltraps>

f0104462 <irq6>:
TRAPHANDLER_NOEC(irq6, 38)
f0104462:	6a 00                	push   $0x0
f0104464:	6a 26                	push   $0x26
f0104466:	eb 36                	jmp    f010449e <_alltraps>

f0104468 <irq7>:
TRAPHANDLER_NOEC(irq7, 39)
f0104468:	6a 00                	push   $0x0
f010446a:	6a 27                	push   $0x27
f010446c:	eb 30                	jmp    f010449e <_alltraps>

f010446e <irq8>:
TRAPHANDLER_NOEC(irq8, 40)
f010446e:	6a 00                	push   $0x0
f0104470:	6a 28                	push   $0x28
f0104472:	eb 2a                	jmp    f010449e <_alltraps>

f0104474 <irq9>:
TRAPHANDLER_NOEC(irq9, 41) 
f0104474:	6a 00                	push   $0x0
f0104476:	6a 29                	push   $0x29
f0104478:	eb 24                	jmp    f010449e <_alltraps>

f010447a <irq10>:
TRAPHANDLER_NOEC(irq10, 42)
f010447a:	6a 00                	push   $0x0
f010447c:	6a 2a                	push   $0x2a
f010447e:	eb 1e                	jmp    f010449e <_alltraps>

f0104480 <irq11>:
TRAPHANDLER_NOEC(irq11, 43)
f0104480:	6a 00                	push   $0x0
f0104482:	6a 2b                	push   $0x2b
f0104484:	eb 18                	jmp    f010449e <_alltraps>

f0104486 <irq12>:
TRAPHANDLER_NOEC(irq12, 44)
f0104486:	6a 00                	push   $0x0
f0104488:	6a 2c                	push   $0x2c
f010448a:	eb 12                	jmp    f010449e <_alltraps>

f010448c <irq13>:
TRAPHANDLER_NOEC(irq13, 45) 
f010448c:	6a 00                	push   $0x0
f010448e:	6a 2d                	push   $0x2d
f0104490:	eb 0c                	jmp    f010449e <_alltraps>

f0104492 <irq14>:
TRAPHANDLER_NOEC(irq14, 46)
f0104492:	6a 00                	push   $0x0
f0104494:	6a 2e                	push   $0x2e
f0104496:	eb 06                	jmp    f010449e <_alltraps>

f0104498 <irq15>:
TRAPHANDLER_NOEC(irq15, 47)
f0104498:	6a 00                	push   $0x0
f010449a:	6a 2f                	push   $0x2f
f010449c:	eb 00                	jmp    f010449e <_alltraps>

f010449e <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f010449e:	1e                   	push   %ds
        pushl %es
f010449f:	06                   	push   %es
        pushal
f01044a0:	60                   	pusha  
        mov $GD_KD, %eax
f01044a1:	b8 10 00 00 00       	mov    $0x10,%eax
        mov %eax, %ds
f01044a6:	8e d8                	mov    %eax,%ds
        mov %eax, %es
f01044a8:	8e c0                	mov    %eax,%es
        pushl %esp
f01044aa:	54                   	push   %esp
        call trap
f01044ab:	e8 c6 fc ff ff       	call   f0104176 <trap>

f01044b0 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044b0:	55                   	push   %ebp
f01044b1:	89 e5                	mov    %esp,%ebp
f01044b3:	83 ec 08             	sub    $0x8,%esp
f01044b6:	a1 68 f2 22 f0       	mov    0xf022f268,%eax
f01044bb:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044be:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044c3:	8b 02                	mov    (%edx),%eax
f01044c5:	83 e8 01             	sub    $0x1,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044c8:	83 f8 02             	cmp    $0x2,%eax
f01044cb:	76 10                	jbe    f01044dd <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044cd:	83 c1 01             	add    $0x1,%ecx
f01044d0:	83 c2 7c             	add    $0x7c,%edx
f01044d3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044d9:	75 e8                	jne    f01044c3 <sched_halt+0x13>
f01044db:	eb 08                	jmp    f01044e5 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044dd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044e3:	75 1f                	jne    f0104504 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01044e5:	83 ec 0c             	sub    $0xc,%esp
f01044e8:	68 50 7b 10 f0       	push   $0xf0107b50
f01044ed:	e8 5b f2 ff ff       	call   f010374d <cprintf>
f01044f2:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044f5:	83 ec 0c             	sub    $0xc,%esp
f01044f8:	6a 00                	push   $0x0
f01044fa:	e8 73 c4 ff ff       	call   f0100972 <monitor>
f01044ff:	83 c4 10             	add    $0x10,%esp
f0104502:	eb f1                	jmp    f01044f5 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104504:	e8 92 18 00 00       	call   f0105d9b <cpunum>
f0104509:	6b c0 74             	imul   $0x74,%eax,%eax
f010450c:	c7 80 48 00 23 f0 00 	movl   $0x0,-0xfdcffb8(%eax)
f0104513:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104516:	a1 cc fe 22 f0       	mov    0xf022fecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010451b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104520:	77 12                	ja     f0104534 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104522:	50                   	push   %eax
f0104523:	68 88 64 10 f0       	push   $0xf0106488
f0104528:	6a 4a                	push   $0x4a
f010452a:	68 79 7b 10 f0       	push   $0xf0107b79
f010452f:	e8 0c bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104534:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104539:	0f 22 d8             	mov    %eax,%cr3
	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010453c:	e8 5a 18 00 00       	call   f0105d9b <cpunum>
f0104541:	6b d0 74             	imul   $0x74,%eax,%edx
f0104544:	81 c2 40 00 23 f0    	add    $0xf0230040,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010454a:	b8 02 00 00 00       	mov    $0x2,%eax
f010454f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104553:	83 ec 0c             	sub    $0xc,%esp
f0104556:	68 00 04 12 f0       	push   $0xf0120400
f010455b:	e8 43 1b 00 00       	call   f01060a3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104560:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104562:	e8 34 18 00 00       	call   f0105d9b <cpunum>
f0104567:	6b c0 74             	imul   $0x74,%eax,%eax
	xchg(&thiscpu->cpu_status, CPU_HALTED);
	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010456a:	8b 80 50 00 23 f0    	mov    -0xfdcffb0(%eax),%eax
f0104570:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104575:	89 c4                	mov    %eax,%esp
f0104577:	6a 00                	push   $0x0
f0104579:	6a 00                	push   $0x0
f010457b:	fb                   	sti    
f010457c:	f4                   	hlt    
f010457d:	eb fd                	jmp    f010457c <sched_halt+0xcc>
f010457f:	83 c4 10             	add    $0x10,%esp
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104582:	c9                   	leave  
f0104583:	c3                   	ret    

f0104584 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104584:	55                   	push   %ebp
f0104585:	89 e5                	mov    %esp,%ebp
f0104587:	56                   	push   %esi
f0104588:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f0104589:	e8 0d 18 00 00       	call   f0105d9b <cpunum>
f010458e:	6b c0 74             	imul   $0x74,%eax,%eax
        else cur = 0;
f0104591:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
f0104596:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f010459d:	74 17                	je     f01045b6 <sched_yield+0x32>
f010459f:	e8 f7 17 00 00       	call   f0105d9b <cpunum>
f01045a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a7:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f01045ad:	8b 48 48             	mov    0x48(%eax),%ecx
f01045b0:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045b6:	8b 35 68 f2 22 f0    	mov    0xf022f268,%esi
f01045bc:	89 ca                	mov    %ecx,%edx
f01045be:	81 c1 00 04 00 00    	add    $0x400,%ecx
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
              int j = (cur+i) % NENV;
f01045c4:	89 d3                	mov    %edx,%ebx
f01045c6:	c1 fb 1f             	sar    $0x1f,%ebx
f01045c9:	c1 eb 16             	shr    $0x16,%ebx
f01045cc:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01045cf:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045d4:	29 d8                	sub    %ebx,%eax
              if (envs[j].env_status == ENV_RUNNABLE) {
f01045d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045d9:	89 c3                	mov    %eax,%ebx
f01045db:	83 7c 06 54 02       	cmpl   $0x2,0x54(%esi,%eax,1)
f01045e0:	75 14                	jne    f01045f6 <sched_yield+0x72>
                      envs[j].env_cpunum == cpunum();
f01045e2:	e8 b4 17 00 00       	call   f0105d9b <cpunum>
                      env_run(envs + j);
f01045e7:	83 ec 0c             	sub    $0xc,%esp
f01045ea:	03 1d 68 f2 22 f0    	add    0xf022f268,%ebx
f01045f0:	53                   	push   %ebx
f01045f1:	e8 0f ef ff ff       	call   f0103505 <env_run>
f01045f6:	83 c2 01             	add    $0x1,%edx
	// LAB 4: Your code here.
        int i, cur=0;
        if (curenv) cur=ENVX(curenv->env_id);
        else cur = 0;
       
        for (i = 0; i < NENV; ++i) {
f01045f9:	39 ca                	cmp    %ecx,%edx
f01045fb:	75 c7                	jne    f01045c4 <sched_yield+0x40>
              if (envs[j].env_status == ENV_RUNNABLE) {
                      envs[j].env_cpunum == cpunum();
                      env_run(envs + j);
              }
        }
        if (curenv && curenv->env_status == ENV_RUNNING && cpunum() == curenv->env_cpunum) {
f01045fd:	e8 99 17 00 00       	call   f0105d9b <cpunum>
f0104602:	6b c0 74             	imul   $0x74,%eax,%eax
f0104605:	83 b8 48 00 23 f0 00 	cmpl   $0x0,-0xfdcffb8(%eax)
f010460c:	74 44                	je     f0104652 <sched_yield+0xce>
f010460e:	e8 88 17 00 00       	call   f0105d9b <cpunum>
f0104613:	6b c0 74             	imul   $0x74,%eax,%eax
f0104616:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010461c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104620:	75 30                	jne    f0104652 <sched_yield+0xce>
f0104622:	e8 74 17 00 00       	call   f0105d9b <cpunum>
f0104627:	89 c3                	mov    %eax,%ebx
f0104629:	e8 6d 17 00 00       	call   f0105d9b <cpunum>
f010462e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104631:	8b 82 48 00 23 f0    	mov    -0xfdcffb8(%edx),%eax
f0104637:	3b 58 5c             	cmp    0x5c(%eax),%ebx
f010463a:	75 16                	jne    f0104652 <sched_yield+0xce>
               env_run(curenv);
f010463c:	e8 5a 17 00 00       	call   f0105d9b <cpunum>
f0104641:	83 ec 0c             	sub    $0xc,%esp
f0104644:	6b c0 74             	imul   $0x74,%eax,%eax
f0104647:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f010464d:	e8 b3 ee ff ff       	call   f0103505 <env_run>
        }
	// sched_halt never returns
	sched_halt();
f0104652:	e8 59 fe ff ff       	call   f01044b0 <sched_halt>
}
f0104657:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010465a:	5b                   	pop    %ebx
f010465b:	5e                   	pop    %esi
f010465c:	5d                   	pop    %ebp
f010465d:	c3                   	ret    

f010465e <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010465e:	55                   	push   %ebp
f010465f:	89 e5                	mov    %esp,%ebp
f0104661:	57                   	push   %edi
f0104662:	56                   	push   %esi
f0104663:	53                   	push   %ebx
f0104664:	83 ec 1c             	sub    $0x1c,%esp
f0104667:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
f010466a:	83 f8 0c             	cmp    $0xc,%eax
f010466d:	0f 87 7e 05 00 00    	ja     f0104bf1 <syscall+0x593>
f0104673:	ff 24 85 c0 7b 10 f0 	jmp    *-0xfef8440(,%eax,4)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010467a:	e8 1c 17 00 00       	call   f0105d9b <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010467f:	83 ec 04             	sub    $0x4,%esp
f0104682:	6a 01                	push   $0x1
f0104684:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104687:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104688:	6b c0 74             	imul   $0x74,%eax,%eax
f010468b:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104691:	ff 70 48             	pushl  0x48(%eax)
f0104694:	e8 43 e8 ff ff       	call   f0102edc <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104699:	6a 04                	push   $0x4
f010469b:	ff 75 10             	pushl  0x10(%ebp)
f010469e:	ff 75 0c             	pushl  0xc(%ebp)
f01046a1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046a4:	e8 5d e7 ff ff       	call   f0102e06 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01046a9:	83 c4 1c             	add    $0x1c,%esp
f01046ac:	ff 75 0c             	pushl  0xc(%ebp)
f01046af:	ff 75 10             	pushl  0x10(%ebp)
f01046b2:	68 86 7b 10 f0       	push   $0xf0107b86
f01046b7:	e8 91 f0 ff ff       	call   f010374d <cprintf>
f01046bc:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");
        int32_t rslt;
	switch (syscallno) {
        case SYS_cputs:
                sys_cputs((char *)a1, a2);
                rslt = 0;
f01046bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046c4:	e9 34 05 00 00       	jmp    f0104bfd <syscall+0x59f>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046c9:	e8 17 bf ff ff       	call   f01005e5 <cons_getc>
f01046ce:	89 c3                	mov    %eax,%ebx
                sys_cputs((char *)a1, a2);
                rslt = 0;
                break;
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
f01046d0:	e9 28 05 00 00       	jmp    f0104bfd <syscall+0x59f>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046d5:	e8 c1 16 00 00       	call   f0105d9b <cpunum>
f01046da:	6b c0 74             	imul   $0x74,%eax,%eax
f01046dd:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f01046e3:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
                rslt = sys_cgetc();
                break;
	case SYS_getenvid:
                rslt = sys_getenvid();
                break;
f01046e6:	e9 12 05 00 00       	jmp    f0104bfd <syscall+0x59f>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046eb:	83 ec 04             	sub    $0x4,%esp
f01046ee:	6a 01                	push   $0x1
f01046f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046f3:	50                   	push   %eax
f01046f4:	ff 75 0c             	pushl  0xc(%ebp)
f01046f7:	e8 e0 e7 ff ff       	call   f0102edc <envid2env>
f01046fc:	83 c4 10             	add    $0x10,%esp
		return r;
f01046ff:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104701:	85 c0                	test   %eax,%eax
f0104703:	0f 88 f4 04 00 00    	js     f0104bfd <syscall+0x59f>
		return r;
	if (e == curenv)
f0104709:	e8 8d 16 00 00       	call   f0105d9b <cpunum>
f010470e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104711:	6b c0 74             	imul   $0x74,%eax,%eax
f0104714:	39 90 48 00 23 f0    	cmp    %edx,-0xfdcffb8(%eax)
f010471a:	75 23                	jne    f010473f <syscall+0xe1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010471c:	e8 7a 16 00 00       	call   f0105d9b <cpunum>
f0104721:	83 ec 08             	sub    $0x8,%esp
f0104724:	6b c0 74             	imul   $0x74,%eax,%eax
f0104727:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f010472d:	ff 70 48             	pushl  0x48(%eax)
f0104730:	68 8b 7b 10 f0       	push   $0xf0107b8b
f0104735:	e8 13 f0 ff ff       	call   f010374d <cprintf>
f010473a:	83 c4 10             	add    $0x10,%esp
f010473d:	eb 25                	jmp    f0104764 <syscall+0x106>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010473f:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104742:	e8 54 16 00 00       	call   f0105d9b <cpunum>
f0104747:	83 ec 04             	sub    $0x4,%esp
f010474a:	53                   	push   %ebx
f010474b:	6b c0 74             	imul   $0x74,%eax,%eax
f010474e:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104754:	ff 70 48             	pushl  0x48(%eax)
f0104757:	68 a6 7b 10 f0       	push   $0xf0107ba6
f010475c:	e8 ec ef ff ff       	call   f010374d <cprintf>
f0104761:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104764:	83 ec 0c             	sub    $0xc,%esp
f0104767:	ff 75 e4             	pushl  -0x1c(%ebp)
f010476a:	e8 f7 ec ff ff       	call   f0103466 <env_destroy>
f010476f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104772:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104777:	e9 81 04 00 00       	jmp    f0104bfd <syscall+0x59f>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010477c:	e8 03 fe ff ff       	call   f0104584 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f0104781:	e8 15 16 00 00       	call   f0105d9b <cpunum>
f0104786:	83 ec 08             	sub    $0x8,%esp
f0104789:	6b c0 74             	imul   $0x74,%eax,%eax
f010478c:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104792:	ff 70 48             	pushl  0x48(%eax)
f0104795:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104798:	50                   	push   %eax
f0104799:	e8 43 e8 ff ff       	call   f0102fe1 <env_alloc>
f010479e:	83 c4 10             	add    $0x10,%esp
                return ret;
f01047a1:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *newenv;
        int ret;
        if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
f01047a3:	85 c0                	test   %eax,%eax
f01047a5:	0f 85 52 04 00 00    	jne    f0104bfd <syscall+0x59f>
                return ret;
        
        newenv->env_status = ENV_NOT_RUNNABLE;
f01047ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01047ae:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
        newenv->env_tf = curenv->env_tf; 
f01047b5:	e8 e1 15 00 00       	call   f0105d9b <cpunum>
f01047ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01047bd:	8b b0 48 00 23 f0    	mov    -0xfdcffb8(%eax),%esi
f01047c3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047c8:	89 df                	mov    %ebx,%edi
f01047ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        newenv->env_tf.tf_regs.reg_eax = 0;
f01047cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047cf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return newenv->env_id;
f01047d6:	8b 58 48             	mov    0x48(%eax),%ebx
f01047d9:	e9 1f 04 00 00       	jmp    f0104bfd <syscall+0x59f>

	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f01047de:	83 ec 04             	sub    $0x4,%esp
f01047e1:	6a 01                	push   $0x1
f01047e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047e6:	50                   	push   %eax
f01047e7:	ff 75 0c             	pushl  0xc(%ebp)
f01047ea:	e8 ed e6 ff ff       	call   f0102edc <envid2env>
f01047ef:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01047f2:	89 c3                	mov    %eax,%ebx

	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f01047f4:	85 c0                	test   %eax,%eax
f01047f6:	0f 85 01 04 00 00    	jne    f0104bfd <syscall+0x59f>
                return rslt;
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f01047fc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104803:	77 57                	ja     f010485c <syscall+0x1fe>
f0104805:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010480c:	75 58                	jne    f0104866 <syscall+0x208>
                return -E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f010480e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104811:	83 e0 05             	and    $0x5,%eax
f0104814:	83 f8 05             	cmp    $0x5,%eax
f0104817:	75 57                	jne    f0104870 <syscall+0x212>
                return -E_INVAL;
        if((p = page_alloc(1)) == (void*)NULL)
f0104819:	83 ec 0c             	sub    $0xc,%esp
f010481c:	6a 01                	push   $0x1
f010481e:	e8 59 c7 ff ff       	call   f0100f7c <page_alloc>
f0104823:	89 c7                	mov    %eax,%edi
f0104825:	83 c4 10             	add    $0x10,%esp
f0104828:	85 c0                	test   %eax,%eax
f010482a:	74 4e                	je     f010487a <syscall+0x21c>
                return -E_NO_MEM;
        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) 
f010482c:	ff 75 14             	pushl  0x14(%ebp)
f010482f:	ff 75 10             	pushl  0x10(%ebp)
f0104832:	50                   	push   %eax
f0104833:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104836:	ff 70 60             	pushl  0x60(%eax)
f0104839:	e8 54 ca ff ff       	call   f0101292 <page_insert>
f010483e:	83 c4 10             	add    $0x10,%esp
                page_free(p);
        return rslt;
f0104841:	89 c3                	mov    %eax,%ebx
                return -E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
        if((p = page_alloc(1)) == (void*)NULL)
                return -E_NO_MEM;
        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) 
f0104843:	85 c0                	test   %eax,%eax
f0104845:	0f 84 b2 03 00 00    	je     f0104bfd <syscall+0x59f>
                page_free(p);
f010484b:	83 ec 0c             	sub    $0xc,%esp
f010484e:	57                   	push   %edi
f010484f:	e8 96 c7 ff ff       	call   f0100fea <page_free>
f0104854:	83 c4 10             	add    $0x10,%esp
f0104857:	e9 a1 03 00 00       	jmp    f0104bfd <syscall+0x59f>
        struct Env *tmp;
        struct PageInfo *p = NULL;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL;
f010485c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104861:	e9 97 03 00 00       	jmp    f0104bfd <syscall+0x59f>
f0104866:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010486b:	e9 8d 03 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f0104870:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104875:	e9 83 03 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((p = page_alloc(1)) == (void*)NULL)
                return -E_NO_MEM;
f010487a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010487f:	e9 79 03 00 00       	jmp    f0104bfd <syscall+0x59f>
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f0104884:	83 ec 04             	sub    $0x4,%esp
f0104887:	6a 01                	push   $0x1
f0104889:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010488c:	50                   	push   %eax
f010488d:	ff 75 0c             	pushl  0xc(%ebp)
f0104890:	e8 47 e6 ff ff       	call   f0102edc <envid2env>
f0104895:	83 c4 10             	add    $0x10,%esp
                return rslt;
f0104898:	89 c3                	mov    %eax,%ebx
        // LAB 4: Your code here.
        int rslt;
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
f010489a:	85 c0                	test   %eax,%eax
f010489c:	0f 85 5b 03 00 00    	jne    f0104bfd <syscall+0x59f>
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048a2:	83 ec 04             	sub    $0x4,%esp
f01048a5:	6a 01                	push   $0x1
f01048a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048aa:	50                   	push   %eax
f01048ab:	ff 75 14             	pushl  0x14(%ebp)
f01048ae:	e8 29 e6 ff ff       	call   f0102edc <envid2env>
f01048b3:	83 c4 10             	add    $0x10,%esp
                return rslt;
f01048b6:	89 c3                	mov    %eax,%ebx
        struct Env *src, *dst;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
f01048b8:	85 c0                	test   %eax,%eax
f01048ba:	0f 85 3d 03 00 00    	jne    f0104bfd <syscall+0x59f>
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
f01048c0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048c7:	77 73                	ja     f010493c <syscall+0x2de>
                return -E_INVAL;
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
f01048c9:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048d0:	75 74                	jne    f0104946 <syscall+0x2e8>
f01048d2:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048d9:	77 6b                	ja     f0104946 <syscall+0x2e8>
f01048db:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048e2:	75 6c                	jne    f0104950 <syscall+0x2f2>
                return -E_INVAL;
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
f01048e4:	83 ec 04             	sub    $0x4,%esp
f01048e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048ea:	50                   	push   %eax
f01048eb:	ff 75 10             	pushl  0x10(%ebp)
f01048ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048f1:	ff 70 60             	pushl  0x60(%eax)
f01048f4:	e8 ad c8 ff ff       	call   f01011a6 <page_lookup>
f01048f9:	83 c4 10             	add    $0x10,%esp
f01048fc:	85 c0                	test   %eax,%eax
f01048fe:	74 5a                	je     f010495a <syscall+0x2fc>
f0104900:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104903:	8b 12                	mov    (%edx),%edx
f0104905:	f6 c2 01             	test   $0x1,%dl
f0104908:	74 5a                	je     f0104964 <syscall+0x306>
                return 	-E_INVAL;
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f010490a:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f010490d:	83 e1 05             	and    $0x5,%ecx
f0104910:	83 f9 05             	cmp    $0x5,%ecx
f0104913:	75 59                	jne    f010496e <syscall+0x310>
                return -E_INVAL;
        if((perm & PTE_W) && !(*srcpte & PTE_W))
f0104915:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104919:	74 05                	je     f0104920 <syscall+0x2c2>
f010491b:	f6 c2 02             	test   $0x2,%dl
f010491e:	74 58                	je     f0104978 <syscall+0x31a>
                return -E_INVAL;
        rslt =  page_insert(dst->env_pgdir, pg, dstva, perm);
f0104920:	ff 75 1c             	pushl  0x1c(%ebp)
f0104923:	ff 75 18             	pushl  0x18(%ebp)
f0104926:	50                   	push   %eax
f0104927:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010492a:	ff 70 60             	pushl  0x60(%eax)
f010492d:	e8 60 c9 ff ff       	call   f0101292 <page_insert>
f0104932:	83 c4 10             	add    $0x10,%esp
        return rslt;
f0104935:	89 c3                	mov    %eax,%ebx
f0104937:	e9 c1 02 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
                return rslt;
        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
                return rslt;
        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
                return -E_INVAL;
f010493c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104941:	e9 b7 02 00 00       	jmp    f0104bfd <syscall+0x59f>
	if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
                return -E_INVAL;
f0104946:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494b:	e9 ad 02 00 00       	jmp    f0104bfd <syscall+0x59f>
f0104950:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104955:	e9 a3 02 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
                return 	-E_INVAL;
f010495a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010495f:	e9 99 02 00 00       	jmp    f0104bfd <syscall+0x59f>
f0104964:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104969:	e9 8f 02 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
                return -E_INVAL;
f010496e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104973:	e9 85 02 00 00       	jmp    f0104bfd <syscall+0x59f>
        if((perm & PTE_W) && !(*srcpte & PTE_W))
                return -E_INVAL;
f0104978:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
                rslt = sys_page_alloc(a1, (void*)a2, a3);
                break;
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
f010497d:	e9 7b 02 00 00       	jmp    f0104bfd <syscall+0x59f>
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f0104982:	83 ec 04             	sub    $0x4,%esp
f0104985:	6a 01                	push   $0x1
f0104987:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010498a:	50                   	push   %eax
f010498b:	ff 75 0c             	pushl  0xc(%ebp)
f010498e:	e8 49 e5 ff ff       	call   f0102edc <envid2env>
f0104993:	83 c4 10             	add    $0x10,%esp
                return rslt;  
f0104996:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
f0104998:	85 c0                	test   %eax,%eax
f010499a:	0f 85 5d 02 00 00    	jne    f0104bfd <syscall+0x59f>
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
f01049a0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049a7:	77 27                	ja     f01049d0 <syscall+0x372>
f01049a9:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049b0:	75 28                	jne    f01049da <syscall+0x37c>
                return -E_INVAL; 
        page_remove(tmp->env_pgdir, va);
f01049b2:	83 ec 08             	sub    $0x8,%esp
f01049b5:	ff 75 10             	pushl  0x10(%ebp)
f01049b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049bb:	ff 70 60             	pushl  0x60(%eax)
f01049be:	e8 7e c8 ff ff       	call   f0101241 <page_remove>
f01049c3:	83 c4 10             	add    $0x10,%esp
        return 0;
f01049c6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049cb:	e9 2d 02 00 00       	jmp    f0104bfd <syscall+0x59f>
        pte_t *srcpte;
        struct PageInfo *pg;
        if((rslt = envid2env(envid, &tmp, 1)) != 0)
                return rslt;  
        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
                return -E_INVAL; 
f01049d0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d5:	e9 23 02 00 00       	jmp    f0104bfd <syscall+0x59f>
f01049da:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
                rslt = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
	case SYS_page_unmap:
                rslt = sys_page_unmap(a1, (void *)a2);
                break;
f01049df:	e9 19 02 00 00       	jmp    f0104bfd <syscall+0x59f>
	// envid's status.

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01049e4:	8b 45 10             	mov    0x10(%ebp),%eax
f01049e7:	83 e8 02             	sub    $0x2,%eax
f01049ea:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01049ef:	75 2c                	jne    f0104a1d <syscall+0x3bf>
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f01049f1:	83 ec 04             	sub    $0x4,%esp
f01049f4:	6a 01                	push   $0x1
f01049f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049f9:	50                   	push   %eax
f01049fa:	ff 75 0c             	pushl  0xc(%ebp)
f01049fd:	e8 da e4 ff ff       	call   f0102edc <envid2env>
f0104a02:	83 c4 10             	add    $0x10,%esp
                tmp->env_status = status;
        return rslt;     
f0104a05:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a07:	85 c0                	test   %eax,%eax
f0104a09:	0f 85 ee 01 00 00    	jne    f0104bfd <syscall+0x59f>
                tmp->env_status = status;
f0104a0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a12:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a15:	89 7a 54             	mov    %edi,0x54(%edx)
f0104a18:	e9 e0 01 00 00       	jmp    f0104bfd <syscall+0x59f>

	// LAB 4: Your code here.
        struct Env *tmp;
        int rslt;
        if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                return -E_INVAL;
f0104a1d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a22:	e9 d6 01 00 00       	jmp    f0104bfd <syscall+0x59f>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
        int rslt;
        struct Env *tmp;
        if((rslt = envid2env(envid, &tmp, 1)) == 0)
f0104a27:	83 ec 04             	sub    $0x4,%esp
f0104a2a:	6a 01                	push   $0x1
f0104a2c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a2f:	50                   	push   %eax
f0104a30:	ff 75 0c             	pushl  0xc(%ebp)
f0104a33:	e8 a4 e4 ff ff       	call   f0102edc <envid2env>
f0104a38:	83 c4 10             	add    $0x10,%esp
f0104a3b:	85 c0                	test   %eax,%eax
f0104a3d:	75 09                	jne    f0104a48 <syscall+0x3ea>
                tmp->env_pgfault_upcall = func;
f0104a3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a42:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a45:	89 4a 64             	mov    %ecx,0x64(%edx)
                break;
        case SYS_env_set_status:
                rslt = sys_env_set_status(a1, a2);
                break;
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104a48:	89 c3                	mov    %eax,%ebx
                break;
f0104a4a:	e9 ae 01 00 00       	jmp    f0104bfd <syscall+0x59f>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
f0104a4f:	83 ec 04             	sub    $0x4,%esp
f0104a52:	6a 00                	push   $0x0
f0104a54:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a57:	50                   	push   %eax
f0104a58:	ff 75 0c             	pushl  0xc(%ebp)
f0104a5b:	e8 7c e4 ff ff       	call   f0102edc <envid2env>
f0104a60:	83 c4 10             	add    $0x10,%esp
f0104a63:	85 c0                	test   %eax,%eax
f0104a65:	0f 88 07 01 00 00    	js     f0104b72 <syscall+0x514>
                return -E_BAD_ENV;
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
f0104a6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a6e:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a72:	0f 84 04 01 00 00    	je     f0104b7c <syscall+0x51e>
f0104a78:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a7b:	85 db                	test   %ebx,%ebx
f0104a7d:	0f 85 00 01 00 00    	jne    f0104b83 <syscall+0x525>
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
f0104a83:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a8a:	0f 87 ab 00 00 00    	ja     f0104b3b <syscall+0x4dd>
                if((size_t)srcva % PGSIZE)
f0104a90:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a97:	75 70                	jne    f0104b09 <syscall+0x4ab>
                        return -E_INVAL;
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
f0104a99:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a9c:	83 e0 05             	and    $0x5,%eax
f0104a9f:	83 f8 05             	cmp    $0x5,%eax
f0104aa2:	75 6f                	jne    f0104b13 <syscall+0x4b5>
                        return -E_INVAL;
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104aa4:	e8 f2 12 00 00       	call   f0105d9b <cpunum>
f0104aa9:	83 ec 04             	sub    $0x4,%esp
f0104aac:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104aaf:	52                   	push   %edx
f0104ab0:	ff 75 14             	pushl  0x14(%ebp)
f0104ab3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab6:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104abc:	ff 70 60             	pushl  0x60(%eax)
f0104abf:	e8 e2 c6 ff ff       	call   f01011a6 <page_lookup>
                if(!pg) return -E_INVAL;
f0104ac4:	83 c4 10             	add    $0x10,%esp
f0104ac7:	85 c0                	test   %eax,%eax
f0104ac9:	74 52                	je     f0104b1d <syscall+0x4bf>
                if( (perm & PTE_W) && !(*pte & PTE_W))
f0104acb:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104acf:	74 08                	je     f0104ad9 <syscall+0x47b>
f0104ad1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ad4:	f6 02 02             	testb  $0x2,(%edx)
f0104ad7:	74 4e                	je     f0104b27 <syscall+0x4c9>
                        return -E_INVAL;
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
f0104ad9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104adc:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104adf:	8d 71 ff             	lea    -0x1(%ecx),%esi
f0104ae2:	81 fe fe ff bf ee    	cmp    $0xeebffffe,%esi
f0104ae8:	77 51                	ja     f0104b3b <syscall+0x4dd>
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
f0104aea:	ff 75 18             	pushl  0x18(%ebp)
f0104aed:	51                   	push   %ecx
f0104aee:	50                   	push   %eax
f0104aef:	ff 72 60             	pushl  0x60(%edx)
f0104af2:	e8 9b c7 ff ff       	call   f0101292 <page_insert>
f0104af7:	83 c4 10             	add    $0x10,%esp
f0104afa:	85 c0                	test   %eax,%eax
f0104afc:	78 33                	js     f0104b31 <syscall+0x4d3>
                                return -E_NO_MEM;
                        target->env_ipc_perm = perm;
f0104afe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b01:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104b04:	89 48 78             	mov    %ecx,0x78(%eax)
f0104b07:	eb 32                	jmp    f0104b3b <syscall+0x4dd>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
        
        if(srcva < (void *)UTOP) {
                if((size_t)srcva % PGSIZE)
                        return -E_INVAL;
f0104b09:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b0e:	e9 ea 00 00 00       	jmp    f0104bfd <syscall+0x59f>
                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
                        return -E_INVAL;
f0104b13:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b18:	e9 e0 00 00 00       	jmp    f0104bfd <syscall+0x59f>
                pte_t *pte;
                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
                if(!pg) return -E_INVAL;
f0104b1d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b22:	e9 d6 00 00 00       	jmp    f0104bfd <syscall+0x59f>
                if( (perm & PTE_W) && !(*pte & PTE_W))
                        return -E_INVAL;
f0104b27:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b2c:	e9 cc 00 00 00       	jmp    f0104bfd <syscall+0x59f>
                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
                                return -E_NO_MEM;
f0104b31:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b36:	e9 c2 00 00 00       	jmp    f0104bfd <syscall+0x59f>
                        target->env_ipc_perm = perm;
                }
        }
        target->env_ipc_recving = 0;
f0104b3b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b3e:	c6 46 68 00          	movb   $0x0,0x68(%esi)
        target->env_ipc_value = value;
f0104b42:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b45:	89 46 70             	mov    %eax,0x70(%esi)
        target->env_ipc_from = curenv->env_id;
f0104b48:	e8 4e 12 00 00       	call   f0105d9b <cpunum>
f0104b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b50:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104b56:	8b 40 48             	mov    0x48(%eax),%eax
f0104b59:	89 46 74             	mov    %eax,0x74(%esi)
        target->env_tf.tf_regs.reg_eax = 0;
f0104b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b5f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        target->env_status = ENV_RUNNABLE;
f0104b66:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104b6d:	e9 8b 00 00 00       	jmp    f0104bfd <syscall+0x59f>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *target;
        if(envid2env(envid, &target, 0) < 0)
                return -E_BAD_ENV;
f0104b72:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104b77:	e9 81 00 00 00       	jmp    f0104bfd <syscall+0x59f>
        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
                return -E_IPC_NOT_RECV;
f0104b7c:	bb f8 ff ff ff       	mov    $0xfffffff8,%ebx
f0104b81:	eb 7a                	jmp    f0104bfd <syscall+0x59f>
f0104b83:	bb f8 ff ff ff       	mov    $0xfffffff8,%ebx
	case SYS_env_set_pgfault_upcall:
                rslt = sys_env_set_pgfault_upcall(a1, (void *)a2);
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
f0104b88:	eb 73                	jmp    f0104bfd <syscall+0x59f>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
        if((dstva < (void *)UTOP) && ((size_t)dstva % PGSIZE))
f0104b8a:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b91:	77 09                	ja     f0104b9c <syscall+0x53e>
f0104b93:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b9a:	75 5c                	jne    f0104bf8 <syscall+0x59a>
                        return -E_INVAL;
        curenv->env_ipc_recving = 1;
f0104b9c:	e8 fa 11 00 00       	call   f0105d9b <cpunum>
f0104ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba4:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104baa:	c6 40 68 01          	movb   $0x1,0x68(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0104bae:	e8 e8 11 00 00       	call   f0105d9b <cpunum>
f0104bb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb6:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104bbc:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_dstva = dstva;
f0104bc3:	e8 d3 11 00 00       	call   f0105d9b <cpunum>
f0104bc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bcb:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bd4:	89 48 6c             	mov    %ecx,0x6c(%eax)
        curenv->env_ipc_from = 0;
f0104bd7:	e8 bf 11 00 00       	call   f0105d9b <cpunum>
f0104bdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bdf:	8b 80 48 00 23 f0    	mov    -0xfdcffb8(%eax),%eax
f0104be5:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104bec:	e8 93 f9 ff ff       	call   f0104584 <sched_yield>
                break;
        case SYS_ipc_recv:
                rslt = sys_ipc_recv((void *)a1);
                break;
	default:
		return -E_NO_SYS;
f0104bf1:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bf6:	eb 05                	jmp    f0104bfd <syscall+0x59f>
                break;
        case SYS_ipc_try_send:
                rslt = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
        case SYS_ipc_recv:
                rslt = sys_ipc_recv((void *)a1);
f0104bf8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
                break;
	default:
		return -E_NO_SYS;
	}
        return rslt;
}
f0104bfd:	89 d8                	mov    %ebx,%eax
f0104bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c02:	5b                   	pop    %ebx
f0104c03:	5e                   	pop    %esi
f0104c04:	5f                   	pop    %edi
f0104c05:	5d                   	pop    %ebp
f0104c06:	c3                   	ret    

f0104c07 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c07:	55                   	push   %ebp
f0104c08:	89 e5                	mov    %esp,%ebp
f0104c0a:	57                   	push   %edi
f0104c0b:	56                   	push   %esi
f0104c0c:	53                   	push   %ebx
f0104c0d:	83 ec 14             	sub    $0x14,%esp
f0104c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c16:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c19:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c1c:	8b 1a                	mov    (%edx),%ebx
f0104c1e:	8b 01                	mov    (%ecx),%eax
f0104c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c23:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c2a:	e9 88 00 00 00       	jmp    f0104cb7 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c32:	01 d8                	add    %ebx,%eax
f0104c34:	89 c6                	mov    %eax,%esi
f0104c36:	c1 ee 1f             	shr    $0x1f,%esi
f0104c39:	01 c6                	add    %eax,%esi
f0104c3b:	d1 fe                	sar    %esi
f0104c3d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c40:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c43:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c46:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c48:	eb 03                	jmp    f0104c4d <stab_binsearch+0x46>
			m--;
f0104c4a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c4d:	39 c3                	cmp    %eax,%ebx
f0104c4f:	7f 1f                	jg     f0104c70 <stab_binsearch+0x69>
f0104c51:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c55:	83 ea 0c             	sub    $0xc,%edx
f0104c58:	39 f9                	cmp    %edi,%ecx
f0104c5a:	75 ee                	jne    f0104c4a <stab_binsearch+0x43>
f0104c5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c5f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c62:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c65:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c69:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c6c:	76 18                	jbe    f0104c86 <stab_binsearch+0x7f>
f0104c6e:	eb 05                	jmp    f0104c75 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c70:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c73:	eb 42                	jmp    f0104cb7 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104c75:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c78:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c7a:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c7d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c84:	eb 31                	jmp    f0104cb7 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c86:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c89:	73 17                	jae    f0104ca2 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104c8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104c8e:	83 e8 01             	sub    $0x1,%eax
f0104c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c94:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c97:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c99:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ca0:	eb 15                	jmp    f0104cb7 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104ca2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ca5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104ca8:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0104caa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cae:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cb0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104cb7:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104cba:	0f 8e 6f ff ff ff    	jle    f0104c2f <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104cc0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cc4:	75 0f                	jne    f0104cd5 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104cc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cc9:	8b 00                	mov    (%eax),%eax
f0104ccb:	83 e8 01             	sub    $0x1,%eax
f0104cce:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cd1:	89 06                	mov    %eax,(%esi)
f0104cd3:	eb 2c                	jmp    f0104d01 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cd8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cda:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cdd:	8b 0e                	mov    (%esi),%ecx
f0104cdf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ce2:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104ce5:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ce8:	eb 03                	jmp    f0104ced <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104cea:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ced:	39 c8                	cmp    %ecx,%eax
f0104cef:	7e 0b                	jle    f0104cfc <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104cf1:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104cf5:	83 ea 0c             	sub    $0xc,%edx
f0104cf8:	39 fb                	cmp    %edi,%ebx
f0104cfa:	75 ee                	jne    f0104cea <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104cfc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cff:	89 06                	mov    %eax,(%esi)
	}
}
f0104d01:	83 c4 14             	add    $0x14,%esp
f0104d04:	5b                   	pop    %ebx
f0104d05:	5e                   	pop    %esi
f0104d06:	5f                   	pop    %edi
f0104d07:	5d                   	pop    %ebp
f0104d08:	c3                   	ret    

f0104d09 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d09:	55                   	push   %ebp
f0104d0a:	89 e5                	mov    %esp,%ebp
f0104d0c:	57                   	push   %edi
f0104d0d:	56                   	push   %esi
f0104d0e:	53                   	push   %ebx
f0104d0f:	83 ec 3c             	sub    $0x3c,%esp
f0104d12:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d18:	c7 03 f4 7b 10 f0    	movl   $0xf0107bf4,(%ebx)
	info->eip_line = 0;
f0104d1e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d25:	c7 43 08 f4 7b 10 f0 	movl   $0xf0107bf4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d2c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d33:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d36:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d3d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d43:	0f 87 96 00 00 00    	ja     f0104ddf <debuginfo_eip+0xd6>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104d49:	e8 4d 10 00 00       	call   f0105d9b <cpunum>
f0104d4e:	6a 04                	push   $0x4
f0104d50:	6a 10                	push   $0x10
f0104d52:	68 00 00 20 00       	push   $0x200000
f0104d57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d5a:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104d60:	e8 29 e0 ff ff       	call   f0102d8e <user_mem_check>
f0104d65:	83 c4 10             	add    $0x10,%esp
f0104d68:	85 c0                	test   %eax,%eax
f0104d6a:	0f 85 15 02 00 00    	jne    f0104f85 <debuginfo_eip+0x27c>
			return -1;
		stabs = usd->stabs;
f0104d70:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d75:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104d78:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104d7e:	a1 08 00 20 00       	mov    0x200008,%eax
f0104d83:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d86:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104d8c:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104d8f:	e8 07 10 00 00       	call   f0105d9b <cpunum>
f0104d94:	6a 04                	push   $0x4
f0104d96:	6a 0c                	push   $0xc
f0104d98:	ff 75 c4             	pushl  -0x3c(%ebp)
f0104d9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d9e:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104da4:	e8 e5 df ff ff       	call   f0102d8e <user_mem_check>
f0104da9:	83 c4 10             	add    $0x10,%esp
f0104dac:	85 c0                	test   %eax,%eax
f0104dae:	0f 85 d8 01 00 00    	jne    f0104f8c <debuginfo_eip+0x283>
                        return -1;
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104db4:	e8 e2 0f 00 00       	call   f0105d9b <cpunum>
f0104db9:	6a 04                	push   $0x4
f0104dbb:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104dbe:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104dc1:	29 ca                	sub    %ecx,%edx
f0104dc3:	52                   	push   %edx
f0104dc4:	51                   	push   %ecx
f0104dc5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dc8:	ff b0 48 00 23 f0    	pushl  -0xfdcffb8(%eax)
f0104dce:	e8 bb df ff ff       	call   f0102d8e <user_mem_check>
f0104dd3:	83 c4 10             	add    $0x10,%esp
f0104dd6:	85 c0                	test   %eax,%eax
f0104dd8:	74 1f                	je     f0104df9 <debuginfo_eip+0xf0>
f0104dda:	e9 b4 01 00 00       	jmp    f0104f93 <debuginfo_eip+0x28a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104ddf:	c7 45 bc 43 5e 11 f0 	movl   $0xf0115e43,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104de6:	c7 45 c0 d1 27 11 f0 	movl   $0xf01127d1,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104ded:	bf d0 27 11 f0       	mov    $0xf01127d0,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104df2:	c7 45 c4 d8 80 10 f0 	movl   $0xf01080d8,-0x3c(%ebp)
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104df9:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104dfc:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0104dff:	0f 83 95 01 00 00    	jae    f0104f9a <debuginfo_eip+0x291>
f0104e05:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104e09:	0f 85 92 01 00 00    	jne    f0104fa1 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e0f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e16:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104e19:	c1 ff 02             	sar    $0x2,%edi
f0104e1c:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104e22:	83 e8 01             	sub    $0x1,%eax
f0104e25:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e28:	83 ec 08             	sub    $0x8,%esp
f0104e2b:	56                   	push   %esi
f0104e2c:	6a 64                	push   $0x64
f0104e2e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104e31:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e34:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104e37:	89 f8                	mov    %edi,%eax
f0104e39:	e8 c9 fd ff ff       	call   f0104c07 <stab_binsearch>
	if (lfile == 0)
f0104e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e41:	83 c4 10             	add    $0x10,%esp
f0104e44:	85 c0                	test   %eax,%eax
f0104e46:	0f 84 5c 01 00 00    	je     f0104fa8 <debuginfo_eip+0x29f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e52:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e55:	83 ec 08             	sub    $0x8,%esp
f0104e58:	56                   	push   %esi
f0104e59:	6a 24                	push   $0x24
f0104e5b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104e5e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e61:	89 f8                	mov    %edi,%eax
f0104e63:	e8 9f fd ff ff       	call   f0104c07 <stab_binsearch>

	if (lfun <= rfun) {
f0104e68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e6b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104e6e:	83 c4 10             	add    $0x10,%esp
f0104e71:	39 f8                	cmp    %edi,%eax
f0104e73:	7f 32                	jg     f0104ea7 <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e75:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e78:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104e7b:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0104e7e:	8b 11                	mov    (%ecx),%edx
f0104e80:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104e83:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e86:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104e89:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0104e8c:	73 09                	jae    f0104e97 <debuginfo_eip+0x18e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e8e:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104e91:	03 55 c0             	add    -0x40(%ebp),%edx
f0104e94:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e97:	8b 51 08             	mov    0x8(%ecx),%edx
f0104e9a:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e9d:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ea2:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0104ea5:	eb 0f                	jmp    f0104eb6 <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104ea7:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ead:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104eb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104eb3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104eb6:	83 ec 08             	sub    $0x8,%esp
f0104eb9:	6a 3a                	push   $0x3a
f0104ebb:	ff 73 08             	pushl  0x8(%ebx)
f0104ebe:	e8 99 08 00 00       	call   f010575c <strfind>
f0104ec3:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ec6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ec9:	83 c4 08             	add    $0x8,%esp
f0104ecc:	56                   	push   %esi
f0104ecd:	6a 44                	push   $0x44
f0104ecf:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ed2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ed5:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ed8:	89 f0                	mov    %esi,%eax
f0104eda:	e8 28 fd ff ff       	call   f0104c07 <stab_binsearch>
        if(lline <= rline)
f0104edf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ee2:	83 c4 10             	add    $0x10,%esp
f0104ee5:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104ee8:	0f 8f c1 00 00 00    	jg     f0104faf <debuginfo_eip+0x2a6>
              info->eip_line = stabs[lline].n_desc;
f0104eee:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ef1:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104ef6:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ef9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104efc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104eff:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f02:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104f05:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f08:	eb 06                	jmp    f0104f10 <debuginfo_eip+0x207>
f0104f0a:	83 e8 01             	sub    $0x1,%eax
f0104f0d:	83 ea 0c             	sub    $0xc,%edx
f0104f10:	39 c7                	cmp    %eax,%edi
f0104f12:	7f 2a                	jg     f0104f3e <debuginfo_eip+0x235>
	       && stabs[lline].n_type != N_SOL
f0104f14:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f18:	80 f9 84             	cmp    $0x84,%cl
f0104f1b:	0f 84 9c 00 00 00    	je     f0104fbd <debuginfo_eip+0x2b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f21:	80 f9 64             	cmp    $0x64,%cl
f0104f24:	75 e4                	jne    f0104f0a <debuginfo_eip+0x201>
f0104f26:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f2a:	74 de                	je     f0104f0a <debuginfo_eip+0x201>
f0104f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f32:	e9 8c 00 00 00       	jmp    f0104fc3 <debuginfo_eip+0x2ba>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f37:	03 55 c0             	add    -0x40(%ebp),%edx
f0104f3a:	89 13                	mov    %edx,(%ebx)
f0104f3c:	eb 03                	jmp    f0104f41 <debuginfo_eip+0x238>
f0104f3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f41:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f44:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f47:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f4c:	39 f2                	cmp    %esi,%edx
f0104f4e:	0f 8d 8b 00 00 00    	jge    f0104fdf <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
f0104f54:	83 c2 01             	add    $0x1,%edx
f0104f57:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f5a:	89 d0                	mov    %edx,%eax
f0104f5c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f5f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104f62:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104f65:	eb 04                	jmp    f0104f6b <debuginfo_eip+0x262>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f67:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f6b:	39 c6                	cmp    %eax,%esi
f0104f6d:	7e 47                	jle    f0104fb6 <debuginfo_eip+0x2ad>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f6f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f73:	83 c0 01             	add    $0x1,%eax
f0104f76:	83 c2 0c             	add    $0xc,%edx
f0104f79:	80 f9 a0             	cmp    $0xa0,%cl
f0104f7c:	74 e9                	je     f0104f67 <debuginfo_eip+0x25e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f83:	eb 5a                	jmp    f0104fdf <debuginfo_eip+0x2d6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f8a:	eb 53                	jmp    f0104fdf <debuginfo_eip+0x2d6>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
                        return -1;
f0104f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f91:	eb 4c                	jmp    f0104fdf <debuginfo_eip+0x2d6>
                if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
                        return -1;
f0104f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f98:	eb 45                	jmp    f0104fdf <debuginfo_eip+0x2d6>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f9f:	eb 3e                	jmp    f0104fdf <debuginfo_eip+0x2d6>
f0104fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fa6:	eb 37                	jmp    f0104fdf <debuginfo_eip+0x2d6>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fad:	eb 30                	jmp    f0104fdf <debuginfo_eip+0x2d6>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0104faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb4:	eb 29                	jmp    f0104fdf <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fbb:	eb 22                	jmp    f0104fdf <debuginfo_eip+0x2d6>
f0104fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104fc3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104fc6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104fc9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104fcc:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104fcf:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0104fd2:	39 c2                	cmp    %eax,%edx
f0104fd4:	0f 82 5d ff ff ff    	jb     f0104f37 <debuginfo_eip+0x22e>
f0104fda:	e9 62 ff ff ff       	jmp    f0104f41 <debuginfo_eip+0x238>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0104fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fe2:	5b                   	pop    %ebx
f0104fe3:	5e                   	pop    %esi
f0104fe4:	5f                   	pop    %edi
f0104fe5:	5d                   	pop    %ebp
f0104fe6:	c3                   	ret    

f0104fe7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104fe7:	55                   	push   %ebp
f0104fe8:	89 e5                	mov    %esp,%ebp
f0104fea:	57                   	push   %edi
f0104feb:	56                   	push   %esi
f0104fec:	53                   	push   %ebx
f0104fed:	83 ec 1c             	sub    $0x1c,%esp
f0104ff0:	89 c7                	mov    %eax,%edi
f0104ff2:	89 d6                	mov    %edx,%esi
f0104ff4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ffa:	89 d1                	mov    %edx,%ecx
f0104ffc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105002:	8b 45 10             	mov    0x10(%ebp),%eax
f0105005:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105008:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010500b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105012:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0105015:	72 05                	jb     f010501c <printnum+0x35>
f0105017:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010501a:	77 3e                	ja     f010505a <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010501c:	83 ec 0c             	sub    $0xc,%esp
f010501f:	ff 75 18             	pushl  0x18(%ebp)
f0105022:	83 eb 01             	sub    $0x1,%ebx
f0105025:	53                   	push   %ebx
f0105026:	50                   	push   %eax
f0105027:	83 ec 08             	sub    $0x8,%esp
f010502a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010502d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105030:	ff 75 dc             	pushl  -0x24(%ebp)
f0105033:	ff 75 d8             	pushl  -0x28(%ebp)
f0105036:	e8 55 11 00 00       	call   f0106190 <__udivdi3>
f010503b:	83 c4 18             	add    $0x18,%esp
f010503e:	52                   	push   %edx
f010503f:	50                   	push   %eax
f0105040:	89 f2                	mov    %esi,%edx
f0105042:	89 f8                	mov    %edi,%eax
f0105044:	e8 9e ff ff ff       	call   f0104fe7 <printnum>
f0105049:	83 c4 20             	add    $0x20,%esp
f010504c:	eb 13                	jmp    f0105061 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010504e:	83 ec 08             	sub    $0x8,%esp
f0105051:	56                   	push   %esi
f0105052:	ff 75 18             	pushl  0x18(%ebp)
f0105055:	ff d7                	call   *%edi
f0105057:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010505a:	83 eb 01             	sub    $0x1,%ebx
f010505d:	85 db                	test   %ebx,%ebx
f010505f:	7f ed                	jg     f010504e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105061:	83 ec 08             	sub    $0x8,%esp
f0105064:	56                   	push   %esi
f0105065:	83 ec 04             	sub    $0x4,%esp
f0105068:	ff 75 e4             	pushl  -0x1c(%ebp)
f010506b:	ff 75 e0             	pushl  -0x20(%ebp)
f010506e:	ff 75 dc             	pushl  -0x24(%ebp)
f0105071:	ff 75 d8             	pushl  -0x28(%ebp)
f0105074:	e8 47 12 00 00       	call   f01062c0 <__umoddi3>
f0105079:	83 c4 14             	add    $0x14,%esp
f010507c:	0f be 80 fe 7b 10 f0 	movsbl -0xfef8402(%eax),%eax
f0105083:	50                   	push   %eax
f0105084:	ff d7                	call   *%edi
f0105086:	83 c4 10             	add    $0x10,%esp
}
f0105089:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010508c:	5b                   	pop    %ebx
f010508d:	5e                   	pop    %esi
f010508e:	5f                   	pop    %edi
f010508f:	5d                   	pop    %ebp
f0105090:	c3                   	ret    

f0105091 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105091:	55                   	push   %ebp
f0105092:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105094:	83 fa 01             	cmp    $0x1,%edx
f0105097:	7e 0e                	jle    f01050a7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105099:	8b 10                	mov    (%eax),%edx
f010509b:	8d 4a 08             	lea    0x8(%edx),%ecx
f010509e:	89 08                	mov    %ecx,(%eax)
f01050a0:	8b 02                	mov    (%edx),%eax
f01050a2:	8b 52 04             	mov    0x4(%edx),%edx
f01050a5:	eb 22                	jmp    f01050c9 <getuint+0x38>
	else if (lflag)
f01050a7:	85 d2                	test   %edx,%edx
f01050a9:	74 10                	je     f01050bb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01050ab:	8b 10                	mov    (%eax),%edx
f01050ad:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050b0:	89 08                	mov    %ecx,(%eax)
f01050b2:	8b 02                	mov    (%edx),%eax
f01050b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01050b9:	eb 0e                	jmp    f01050c9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01050bb:	8b 10                	mov    (%eax),%edx
f01050bd:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050c0:	89 08                	mov    %ecx,(%eax)
f01050c2:	8b 02                	mov    (%edx),%eax
f01050c4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01050c9:	5d                   	pop    %ebp
f01050ca:	c3                   	ret    

f01050cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050cb:	55                   	push   %ebp
f01050cc:	89 e5                	mov    %esp,%ebp
f01050ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050d1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01050d5:	8b 10                	mov    (%eax),%edx
f01050d7:	3b 50 04             	cmp    0x4(%eax),%edx
f01050da:	73 0a                	jae    f01050e6 <sprintputch+0x1b>
		*b->buf++ = ch;
f01050dc:	8d 4a 01             	lea    0x1(%edx),%ecx
f01050df:	89 08                	mov    %ecx,(%eax)
f01050e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e4:	88 02                	mov    %al,(%edx)
}
f01050e6:	5d                   	pop    %ebp
f01050e7:	c3                   	ret    

f01050e8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01050e8:	55                   	push   %ebp
f01050e9:	89 e5                	mov    %esp,%ebp
f01050eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01050ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050f1:	50                   	push   %eax
f01050f2:	ff 75 10             	pushl  0x10(%ebp)
f01050f5:	ff 75 0c             	pushl  0xc(%ebp)
f01050f8:	ff 75 08             	pushl  0x8(%ebp)
f01050fb:	e8 05 00 00 00       	call   f0105105 <vprintfmt>
	va_end(ap);
f0105100:	83 c4 10             	add    $0x10,%esp
}
f0105103:	c9                   	leave  
f0105104:	c3                   	ret    

f0105105 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105105:	55                   	push   %ebp
f0105106:	89 e5                	mov    %esp,%ebp
f0105108:	57                   	push   %edi
f0105109:	56                   	push   %esi
f010510a:	53                   	push   %ebx
f010510b:	83 ec 2c             	sub    $0x2c,%esp
f010510e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105114:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105117:	eb 12                	jmp    f010512b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105119:	85 c0                	test   %eax,%eax
f010511b:	0f 84 90 03 00 00    	je     f01054b1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0105121:	83 ec 08             	sub    $0x8,%esp
f0105124:	53                   	push   %ebx
f0105125:	50                   	push   %eax
f0105126:	ff d6                	call   *%esi
f0105128:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010512b:	83 c7 01             	add    $0x1,%edi
f010512e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105132:	83 f8 25             	cmp    $0x25,%eax
f0105135:	75 e2                	jne    f0105119 <vprintfmt+0x14>
f0105137:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010513b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105142:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105149:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105150:	ba 00 00 00 00       	mov    $0x0,%edx
f0105155:	eb 07                	jmp    f010515e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105157:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010515a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010515e:	8d 47 01             	lea    0x1(%edi),%eax
f0105161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105164:	0f b6 07             	movzbl (%edi),%eax
f0105167:	0f b6 c8             	movzbl %al,%ecx
f010516a:	83 e8 23             	sub    $0x23,%eax
f010516d:	3c 55                	cmp    $0x55,%al
f010516f:	0f 87 21 03 00 00    	ja     f0105496 <vprintfmt+0x391>
f0105175:	0f b6 c0             	movzbl %al,%eax
f0105178:	ff 24 85 c0 7c 10 f0 	jmp    *-0xfef8340(,%eax,4)
f010517f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105182:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105186:	eb d6                	jmp    f010515e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105188:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010518b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105190:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105193:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105196:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010519a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010519d:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01051a0:	83 fa 09             	cmp    $0x9,%edx
f01051a3:	77 39                	ja     f01051de <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01051a5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01051a8:	eb e9                	jmp    f0105193 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01051aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ad:	8d 48 04             	lea    0x4(%eax),%ecx
f01051b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01051b3:	8b 00                	mov    (%eax),%eax
f01051b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01051bb:	eb 27                	jmp    f01051e4 <vprintfmt+0xdf>
f01051bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051c0:	85 c0                	test   %eax,%eax
f01051c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051c7:	0f 49 c8             	cmovns %eax,%ecx
f01051ca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051d0:	eb 8c                	jmp    f010515e <vprintfmt+0x59>
f01051d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01051d5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01051dc:	eb 80                	jmp    f010515e <vprintfmt+0x59>
f01051de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051e1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01051e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051e8:	0f 89 70 ff ff ff    	jns    f010515e <vprintfmt+0x59>
				width = precision, precision = -1;
f01051ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01051fb:	e9 5e ff ff ff       	jmp    f010515e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105200:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105203:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105206:	e9 53 ff ff ff       	jmp    f010515e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010520b:	8b 45 14             	mov    0x14(%ebp),%eax
f010520e:	8d 50 04             	lea    0x4(%eax),%edx
f0105211:	89 55 14             	mov    %edx,0x14(%ebp)
f0105214:	83 ec 08             	sub    $0x8,%esp
f0105217:	53                   	push   %ebx
f0105218:	ff 30                	pushl  (%eax)
f010521a:	ff d6                	call   *%esi
			break;
f010521c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010521f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105222:	e9 04 ff ff ff       	jmp    f010512b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105227:	8b 45 14             	mov    0x14(%ebp),%eax
f010522a:	8d 50 04             	lea    0x4(%eax),%edx
f010522d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105230:	8b 00                	mov    (%eax),%eax
f0105232:	99                   	cltd   
f0105233:	31 d0                	xor    %edx,%eax
f0105235:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105237:	83 f8 09             	cmp    $0x9,%eax
f010523a:	7f 0b                	jg     f0105247 <vprintfmt+0x142>
f010523c:	8b 14 85 20 7e 10 f0 	mov    -0xfef81e0(,%eax,4),%edx
f0105243:	85 d2                	test   %edx,%edx
f0105245:	75 18                	jne    f010525f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105247:	50                   	push   %eax
f0105248:	68 16 7c 10 f0       	push   $0xf0107c16
f010524d:	53                   	push   %ebx
f010524e:	56                   	push   %esi
f010524f:	e8 94 fe ff ff       	call   f01050e8 <printfmt>
f0105254:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105257:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010525a:	e9 cc fe ff ff       	jmp    f010512b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010525f:	52                   	push   %edx
f0105260:	68 56 6a 10 f0       	push   $0xf0106a56
f0105265:	53                   	push   %ebx
f0105266:	56                   	push   %esi
f0105267:	e8 7c fe ff ff       	call   f01050e8 <printfmt>
f010526c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010526f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105272:	e9 b4 fe ff ff       	jmp    f010512b <vprintfmt+0x26>
f0105277:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010527a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010527d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105280:	8b 45 14             	mov    0x14(%ebp),%eax
f0105283:	8d 50 04             	lea    0x4(%eax),%edx
f0105286:	89 55 14             	mov    %edx,0x14(%ebp)
f0105289:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010528b:	85 ff                	test   %edi,%edi
f010528d:	ba 0f 7c 10 f0       	mov    $0xf0107c0f,%edx
f0105292:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f0105295:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105299:	0f 84 92 00 00 00    	je     f0105331 <vprintfmt+0x22c>
f010529f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01052a3:	0f 8e 96 00 00 00    	jle    f010533f <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052a9:	83 ec 08             	sub    $0x8,%esp
f01052ac:	51                   	push   %ecx
f01052ad:	57                   	push   %edi
f01052ae:	e8 5f 03 00 00       	call   f0105612 <strnlen>
f01052b3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01052b6:	29 c1                	sub    %eax,%ecx
f01052b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01052bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01052be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01052c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01052c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052ca:	eb 0f                	jmp    f01052db <vprintfmt+0x1d6>
					putch(padc, putdat);
f01052cc:	83 ec 08             	sub    $0x8,%esp
f01052cf:	53                   	push   %ebx
f01052d0:	ff 75 e0             	pushl  -0x20(%ebp)
f01052d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052d5:	83 ef 01             	sub    $0x1,%edi
f01052d8:	83 c4 10             	add    $0x10,%esp
f01052db:	85 ff                	test   %edi,%edi
f01052dd:	7f ed                	jg     f01052cc <vprintfmt+0x1c7>
f01052df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01052e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01052e5:	85 c9                	test   %ecx,%ecx
f01052e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ec:	0f 49 c1             	cmovns %ecx,%eax
f01052ef:	29 c1                	sub    %eax,%ecx
f01052f1:	89 75 08             	mov    %esi,0x8(%ebp)
f01052f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052fa:	89 cb                	mov    %ecx,%ebx
f01052fc:	eb 4d                	jmp    f010534b <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01052fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105302:	74 1b                	je     f010531f <vprintfmt+0x21a>
f0105304:	0f be c0             	movsbl %al,%eax
f0105307:	83 e8 20             	sub    $0x20,%eax
f010530a:	83 f8 5e             	cmp    $0x5e,%eax
f010530d:	76 10                	jbe    f010531f <vprintfmt+0x21a>
					putch('?', putdat);
f010530f:	83 ec 08             	sub    $0x8,%esp
f0105312:	ff 75 0c             	pushl  0xc(%ebp)
f0105315:	6a 3f                	push   $0x3f
f0105317:	ff 55 08             	call   *0x8(%ebp)
f010531a:	83 c4 10             	add    $0x10,%esp
f010531d:	eb 0d                	jmp    f010532c <vprintfmt+0x227>
				else
					putch(ch, putdat);
f010531f:	83 ec 08             	sub    $0x8,%esp
f0105322:	ff 75 0c             	pushl  0xc(%ebp)
f0105325:	52                   	push   %edx
f0105326:	ff 55 08             	call   *0x8(%ebp)
f0105329:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010532c:	83 eb 01             	sub    $0x1,%ebx
f010532f:	eb 1a                	jmp    f010534b <vprintfmt+0x246>
f0105331:	89 75 08             	mov    %esi,0x8(%ebp)
f0105334:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105337:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010533a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010533d:	eb 0c                	jmp    f010534b <vprintfmt+0x246>
f010533f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105342:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105345:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105348:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010534b:	83 c7 01             	add    $0x1,%edi
f010534e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105352:	0f be d0             	movsbl %al,%edx
f0105355:	85 d2                	test   %edx,%edx
f0105357:	74 23                	je     f010537c <vprintfmt+0x277>
f0105359:	85 f6                	test   %esi,%esi
f010535b:	78 a1                	js     f01052fe <vprintfmt+0x1f9>
f010535d:	83 ee 01             	sub    $0x1,%esi
f0105360:	79 9c                	jns    f01052fe <vprintfmt+0x1f9>
f0105362:	89 df                	mov    %ebx,%edi
f0105364:	8b 75 08             	mov    0x8(%ebp),%esi
f0105367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010536a:	eb 18                	jmp    f0105384 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010536c:	83 ec 08             	sub    $0x8,%esp
f010536f:	53                   	push   %ebx
f0105370:	6a 20                	push   $0x20
f0105372:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105374:	83 ef 01             	sub    $0x1,%edi
f0105377:	83 c4 10             	add    $0x10,%esp
f010537a:	eb 08                	jmp    f0105384 <vprintfmt+0x27f>
f010537c:	89 df                	mov    %ebx,%edi
f010537e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105381:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105384:	85 ff                	test   %edi,%edi
f0105386:	7f e4                	jg     f010536c <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010538b:	e9 9b fd ff ff       	jmp    f010512b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105390:	83 fa 01             	cmp    $0x1,%edx
f0105393:	7e 16                	jle    f01053ab <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0105395:	8b 45 14             	mov    0x14(%ebp),%eax
f0105398:	8d 50 08             	lea    0x8(%eax),%edx
f010539b:	89 55 14             	mov    %edx,0x14(%ebp)
f010539e:	8b 50 04             	mov    0x4(%eax),%edx
f01053a1:	8b 00                	mov    (%eax),%eax
f01053a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053a9:	eb 32                	jmp    f01053dd <vprintfmt+0x2d8>
	else if (lflag)
f01053ab:	85 d2                	test   %edx,%edx
f01053ad:	74 18                	je     f01053c7 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f01053af:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b2:	8d 50 04             	lea    0x4(%eax),%edx
f01053b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01053b8:	8b 00                	mov    (%eax),%eax
f01053ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053bd:	89 c1                	mov    %eax,%ecx
f01053bf:	c1 f9 1f             	sar    $0x1f,%ecx
f01053c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01053c5:	eb 16                	jmp    f01053dd <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f01053c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ca:	8d 50 04             	lea    0x4(%eax),%edx
f01053cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01053d0:	8b 00                	mov    (%eax),%eax
f01053d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053d5:	89 c1                	mov    %eax,%ecx
f01053d7:	c1 f9 1f             	sar    $0x1f,%ecx
f01053da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01053dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01053e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01053e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01053ec:	79 74                	jns    f0105462 <vprintfmt+0x35d>
				putch('-', putdat);
f01053ee:	83 ec 08             	sub    $0x8,%esp
f01053f1:	53                   	push   %ebx
f01053f2:	6a 2d                	push   $0x2d
f01053f4:	ff d6                	call   *%esi
				num = -(long long) num;
f01053f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053fc:	f7 d8                	neg    %eax
f01053fe:	83 d2 00             	adc    $0x0,%edx
f0105401:	f7 da                	neg    %edx
f0105403:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105406:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010540b:	eb 55                	jmp    f0105462 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010540d:	8d 45 14             	lea    0x14(%ebp),%eax
f0105410:	e8 7c fc ff ff       	call   f0105091 <getuint>
			base = 10;
f0105415:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010541a:	eb 46                	jmp    f0105462 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010541c:	8d 45 14             	lea    0x14(%ebp),%eax
f010541f:	e8 6d fc ff ff       	call   f0105091 <getuint>
                        base = 8;
f0105424:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0105429:	eb 37                	jmp    f0105462 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f010542b:	83 ec 08             	sub    $0x8,%esp
f010542e:	53                   	push   %ebx
f010542f:	6a 30                	push   $0x30
f0105431:	ff d6                	call   *%esi
			putch('x', putdat);
f0105433:	83 c4 08             	add    $0x8,%esp
f0105436:	53                   	push   %ebx
f0105437:	6a 78                	push   $0x78
f0105439:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010543b:	8b 45 14             	mov    0x14(%ebp),%eax
f010543e:	8d 50 04             	lea    0x4(%eax),%edx
f0105441:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105444:	8b 00                	mov    (%eax),%eax
f0105446:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010544b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010544e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105453:	eb 0d                	jmp    f0105462 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105455:	8d 45 14             	lea    0x14(%ebp),%eax
f0105458:	e8 34 fc ff ff       	call   f0105091 <getuint>
			base = 16;
f010545d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105462:	83 ec 0c             	sub    $0xc,%esp
f0105465:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105469:	57                   	push   %edi
f010546a:	ff 75 e0             	pushl  -0x20(%ebp)
f010546d:	51                   	push   %ecx
f010546e:	52                   	push   %edx
f010546f:	50                   	push   %eax
f0105470:	89 da                	mov    %ebx,%edx
f0105472:	89 f0                	mov    %esi,%eax
f0105474:	e8 6e fb ff ff       	call   f0104fe7 <printnum>
			break;
f0105479:	83 c4 20             	add    $0x20,%esp
f010547c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010547f:	e9 a7 fc ff ff       	jmp    f010512b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105484:	83 ec 08             	sub    $0x8,%esp
f0105487:	53                   	push   %ebx
f0105488:	51                   	push   %ecx
f0105489:	ff d6                	call   *%esi
			break;
f010548b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010548e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105491:	e9 95 fc ff ff       	jmp    f010512b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105496:	83 ec 08             	sub    $0x8,%esp
f0105499:	53                   	push   %ebx
f010549a:	6a 25                	push   $0x25
f010549c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010549e:	83 c4 10             	add    $0x10,%esp
f01054a1:	eb 03                	jmp    f01054a6 <vprintfmt+0x3a1>
f01054a3:	83 ef 01             	sub    $0x1,%edi
f01054a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01054aa:	75 f7                	jne    f01054a3 <vprintfmt+0x39e>
f01054ac:	e9 7a fc ff ff       	jmp    f010512b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01054b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054b4:	5b                   	pop    %ebx
f01054b5:	5e                   	pop    %esi
f01054b6:	5f                   	pop    %edi
f01054b7:	5d                   	pop    %ebp
f01054b8:	c3                   	ret    

f01054b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01054b9:	55                   	push   %ebp
f01054ba:	89 e5                	mov    %esp,%ebp
f01054bc:	83 ec 18             	sub    $0x18,%esp
f01054bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01054c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054d6:	85 c0                	test   %eax,%eax
f01054d8:	74 26                	je     f0105500 <vsnprintf+0x47>
f01054da:	85 d2                	test   %edx,%edx
f01054dc:	7e 22                	jle    f0105500 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054de:	ff 75 14             	pushl  0x14(%ebp)
f01054e1:	ff 75 10             	pushl  0x10(%ebp)
f01054e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054e7:	50                   	push   %eax
f01054e8:	68 cb 50 10 f0       	push   $0xf01050cb
f01054ed:	e8 13 fc ff ff       	call   f0105105 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054fb:	83 c4 10             	add    $0x10,%esp
f01054fe:	eb 05                	jmp    f0105505 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105505:	c9                   	leave  
f0105506:	c3                   	ret    

f0105507 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105507:	55                   	push   %ebp
f0105508:	89 e5                	mov    %esp,%ebp
f010550a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010550d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105510:	50                   	push   %eax
f0105511:	ff 75 10             	pushl  0x10(%ebp)
f0105514:	ff 75 0c             	pushl  0xc(%ebp)
f0105517:	ff 75 08             	pushl  0x8(%ebp)
f010551a:	e8 9a ff ff ff       	call   f01054b9 <vsnprintf>
	va_end(ap);

	return rc;
}
f010551f:	c9                   	leave  
f0105520:	c3                   	ret    

f0105521 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105521:	55                   	push   %ebp
f0105522:	89 e5                	mov    %esp,%ebp
f0105524:	57                   	push   %edi
f0105525:	56                   	push   %esi
f0105526:	53                   	push   %ebx
f0105527:	83 ec 0c             	sub    $0xc,%esp
f010552a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010552d:	85 c0                	test   %eax,%eax
f010552f:	74 11                	je     f0105542 <readline+0x21>
		cprintf("%s", prompt);
f0105531:	83 ec 08             	sub    $0x8,%esp
f0105534:	50                   	push   %eax
f0105535:	68 56 6a 10 f0       	push   $0xf0106a56
f010553a:	e8 0e e2 ff ff       	call   f010374d <cprintf>
f010553f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105542:	83 ec 0c             	sub    $0xc,%esp
f0105545:	6a 00                	push   $0x0
f0105547:	e8 1a b2 ff ff       	call   f0100766 <iscons>
f010554c:	89 c7                	mov    %eax,%edi
f010554e:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105551:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105556:	e8 fa b1 ff ff       	call   f0100755 <getchar>
f010555b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010555d:	85 c0                	test   %eax,%eax
f010555f:	79 18                	jns    f0105579 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105561:	83 ec 08             	sub    $0x8,%esp
f0105564:	50                   	push   %eax
f0105565:	68 48 7e 10 f0       	push   $0xf0107e48
f010556a:	e8 de e1 ff ff       	call   f010374d <cprintf>
			return NULL;
f010556f:	83 c4 10             	add    $0x10,%esp
f0105572:	b8 00 00 00 00       	mov    $0x0,%eax
f0105577:	eb 79                	jmp    f01055f2 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105579:	83 f8 7f             	cmp    $0x7f,%eax
f010557c:	0f 94 c2             	sete   %dl
f010557f:	83 f8 08             	cmp    $0x8,%eax
f0105582:	0f 94 c0             	sete   %al
f0105585:	08 c2                	or     %al,%dl
f0105587:	74 1a                	je     f01055a3 <readline+0x82>
f0105589:	85 f6                	test   %esi,%esi
f010558b:	7e 16                	jle    f01055a3 <readline+0x82>
			if (echoing)
f010558d:	85 ff                	test   %edi,%edi
f010558f:	74 0d                	je     f010559e <readline+0x7d>
				cputchar('\b');
f0105591:	83 ec 0c             	sub    $0xc,%esp
f0105594:	6a 08                	push   $0x8
f0105596:	e8 aa b1 ff ff       	call   f0100745 <cputchar>
f010559b:	83 c4 10             	add    $0x10,%esp
			i--;
f010559e:	83 ee 01             	sub    $0x1,%esi
f01055a1:	eb b3                	jmp    f0105556 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055a3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055a9:	7f 20                	jg     f01055cb <readline+0xaa>
f01055ab:	83 fb 1f             	cmp    $0x1f,%ebx
f01055ae:	7e 1b                	jle    f01055cb <readline+0xaa>
			if (echoing)
f01055b0:	85 ff                	test   %edi,%edi
f01055b2:	74 0c                	je     f01055c0 <readline+0x9f>
				cputchar(c);
f01055b4:	83 ec 0c             	sub    $0xc,%esp
f01055b7:	53                   	push   %ebx
f01055b8:	e8 88 b1 ff ff       	call   f0100745 <cputchar>
f01055bd:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055c0:	88 9e c0 fa 22 f0    	mov    %bl,-0xfdd0540(%esi)
f01055c6:	8d 76 01             	lea    0x1(%esi),%esi
f01055c9:	eb 8b                	jmp    f0105556 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055cb:	83 fb 0d             	cmp    $0xd,%ebx
f01055ce:	74 05                	je     f01055d5 <readline+0xb4>
f01055d0:	83 fb 0a             	cmp    $0xa,%ebx
f01055d3:	75 81                	jne    f0105556 <readline+0x35>
			if (echoing)
f01055d5:	85 ff                	test   %edi,%edi
f01055d7:	74 0d                	je     f01055e6 <readline+0xc5>
				cputchar('\n');
f01055d9:	83 ec 0c             	sub    $0xc,%esp
f01055dc:	6a 0a                	push   $0xa
f01055de:	e8 62 b1 ff ff       	call   f0100745 <cputchar>
f01055e3:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055e6:	c6 86 c0 fa 22 f0 00 	movb   $0x0,-0xfdd0540(%esi)
			return buf;
f01055ed:	b8 c0 fa 22 f0       	mov    $0xf022fac0,%eax
		}
	}
}
f01055f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055f5:	5b                   	pop    %ebx
f01055f6:	5e                   	pop    %esi
f01055f7:	5f                   	pop    %edi
f01055f8:	5d                   	pop    %ebp
f01055f9:	c3                   	ret    

f01055fa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055fa:	55                   	push   %ebp
f01055fb:	89 e5                	mov    %esp,%ebp
f01055fd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105600:	b8 00 00 00 00       	mov    $0x0,%eax
f0105605:	eb 03                	jmp    f010560a <strlen+0x10>
		n++;
f0105607:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010560a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010560e:	75 f7                	jne    f0105607 <strlen+0xd>
		n++;
	return n;
}
f0105610:	5d                   	pop    %ebp
f0105611:	c3                   	ret    

f0105612 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105612:	55                   	push   %ebp
f0105613:	89 e5                	mov    %esp,%ebp
f0105615:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105618:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010561b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105620:	eb 03                	jmp    f0105625 <strnlen+0x13>
		n++;
f0105622:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105625:	39 c2                	cmp    %eax,%edx
f0105627:	74 08                	je     f0105631 <strnlen+0x1f>
f0105629:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010562d:	75 f3                	jne    f0105622 <strnlen+0x10>
f010562f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105631:	5d                   	pop    %ebp
f0105632:	c3                   	ret    

f0105633 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105633:	55                   	push   %ebp
f0105634:	89 e5                	mov    %esp,%ebp
f0105636:	53                   	push   %ebx
f0105637:	8b 45 08             	mov    0x8(%ebp),%eax
f010563a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010563d:	89 c2                	mov    %eax,%edx
f010563f:	83 c2 01             	add    $0x1,%edx
f0105642:	83 c1 01             	add    $0x1,%ecx
f0105645:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105649:	88 5a ff             	mov    %bl,-0x1(%edx)
f010564c:	84 db                	test   %bl,%bl
f010564e:	75 ef                	jne    f010563f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105650:	5b                   	pop    %ebx
f0105651:	5d                   	pop    %ebp
f0105652:	c3                   	ret    

f0105653 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105653:	55                   	push   %ebp
f0105654:	89 e5                	mov    %esp,%ebp
f0105656:	53                   	push   %ebx
f0105657:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010565a:	53                   	push   %ebx
f010565b:	e8 9a ff ff ff       	call   f01055fa <strlen>
f0105660:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105663:	ff 75 0c             	pushl  0xc(%ebp)
f0105666:	01 d8                	add    %ebx,%eax
f0105668:	50                   	push   %eax
f0105669:	e8 c5 ff ff ff       	call   f0105633 <strcpy>
	return dst;
}
f010566e:	89 d8                	mov    %ebx,%eax
f0105670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105673:	c9                   	leave  
f0105674:	c3                   	ret    

f0105675 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105675:	55                   	push   %ebp
f0105676:	89 e5                	mov    %esp,%ebp
f0105678:	56                   	push   %esi
f0105679:	53                   	push   %ebx
f010567a:	8b 75 08             	mov    0x8(%ebp),%esi
f010567d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105680:	89 f3                	mov    %esi,%ebx
f0105682:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105685:	89 f2                	mov    %esi,%edx
f0105687:	eb 0f                	jmp    f0105698 <strncpy+0x23>
		*dst++ = *src;
f0105689:	83 c2 01             	add    $0x1,%edx
f010568c:	0f b6 01             	movzbl (%ecx),%eax
f010568f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105692:	80 39 01             	cmpb   $0x1,(%ecx)
f0105695:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105698:	39 da                	cmp    %ebx,%edx
f010569a:	75 ed                	jne    f0105689 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010569c:	89 f0                	mov    %esi,%eax
f010569e:	5b                   	pop    %ebx
f010569f:	5e                   	pop    %esi
f01056a0:	5d                   	pop    %ebp
f01056a1:	c3                   	ret    

f01056a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01056a2:	55                   	push   %ebp
f01056a3:	89 e5                	mov    %esp,%ebp
f01056a5:	56                   	push   %esi
f01056a6:	53                   	push   %ebx
f01056a7:	8b 75 08             	mov    0x8(%ebp),%esi
f01056aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056ad:	8b 55 10             	mov    0x10(%ebp),%edx
f01056b0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056b2:	85 d2                	test   %edx,%edx
f01056b4:	74 21                	je     f01056d7 <strlcpy+0x35>
f01056b6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056ba:	89 f2                	mov    %esi,%edx
f01056bc:	eb 09                	jmp    f01056c7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056be:	83 c2 01             	add    $0x1,%edx
f01056c1:	83 c1 01             	add    $0x1,%ecx
f01056c4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056c7:	39 c2                	cmp    %eax,%edx
f01056c9:	74 09                	je     f01056d4 <strlcpy+0x32>
f01056cb:	0f b6 19             	movzbl (%ecx),%ebx
f01056ce:	84 db                	test   %bl,%bl
f01056d0:	75 ec                	jne    f01056be <strlcpy+0x1c>
f01056d2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056d4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056d7:	29 f0                	sub    %esi,%eax
}
f01056d9:	5b                   	pop    %ebx
f01056da:	5e                   	pop    %esi
f01056db:	5d                   	pop    %ebp
f01056dc:	c3                   	ret    

f01056dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056dd:	55                   	push   %ebp
f01056de:	89 e5                	mov    %esp,%ebp
f01056e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056e6:	eb 06                	jmp    f01056ee <strcmp+0x11>
		p++, q++;
f01056e8:	83 c1 01             	add    $0x1,%ecx
f01056eb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056ee:	0f b6 01             	movzbl (%ecx),%eax
f01056f1:	84 c0                	test   %al,%al
f01056f3:	74 04                	je     f01056f9 <strcmp+0x1c>
f01056f5:	3a 02                	cmp    (%edx),%al
f01056f7:	74 ef                	je     f01056e8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056f9:	0f b6 c0             	movzbl %al,%eax
f01056fc:	0f b6 12             	movzbl (%edx),%edx
f01056ff:	29 d0                	sub    %edx,%eax
}
f0105701:	5d                   	pop    %ebp
f0105702:	c3                   	ret    

f0105703 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105703:	55                   	push   %ebp
f0105704:	89 e5                	mov    %esp,%ebp
f0105706:	53                   	push   %ebx
f0105707:	8b 45 08             	mov    0x8(%ebp),%eax
f010570a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010570d:	89 c3                	mov    %eax,%ebx
f010570f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105712:	eb 06                	jmp    f010571a <strncmp+0x17>
		n--, p++, q++;
f0105714:	83 c0 01             	add    $0x1,%eax
f0105717:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010571a:	39 d8                	cmp    %ebx,%eax
f010571c:	74 15                	je     f0105733 <strncmp+0x30>
f010571e:	0f b6 08             	movzbl (%eax),%ecx
f0105721:	84 c9                	test   %cl,%cl
f0105723:	74 04                	je     f0105729 <strncmp+0x26>
f0105725:	3a 0a                	cmp    (%edx),%cl
f0105727:	74 eb                	je     f0105714 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105729:	0f b6 00             	movzbl (%eax),%eax
f010572c:	0f b6 12             	movzbl (%edx),%edx
f010572f:	29 d0                	sub    %edx,%eax
f0105731:	eb 05                	jmp    f0105738 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105733:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105738:	5b                   	pop    %ebx
f0105739:	5d                   	pop    %ebp
f010573a:	c3                   	ret    

f010573b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010573b:	55                   	push   %ebp
f010573c:	89 e5                	mov    %esp,%ebp
f010573e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105741:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105745:	eb 07                	jmp    f010574e <strchr+0x13>
		if (*s == c)
f0105747:	38 ca                	cmp    %cl,%dl
f0105749:	74 0f                	je     f010575a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010574b:	83 c0 01             	add    $0x1,%eax
f010574e:	0f b6 10             	movzbl (%eax),%edx
f0105751:	84 d2                	test   %dl,%dl
f0105753:	75 f2                	jne    f0105747 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105755:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010575a:	5d                   	pop    %ebp
f010575b:	c3                   	ret    

f010575c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010575c:	55                   	push   %ebp
f010575d:	89 e5                	mov    %esp,%ebp
f010575f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105762:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105766:	eb 03                	jmp    f010576b <strfind+0xf>
f0105768:	83 c0 01             	add    $0x1,%eax
f010576b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010576e:	84 d2                	test   %dl,%dl
f0105770:	74 04                	je     f0105776 <strfind+0x1a>
f0105772:	38 ca                	cmp    %cl,%dl
f0105774:	75 f2                	jne    f0105768 <strfind+0xc>
			break;
	return (char *) s;
}
f0105776:	5d                   	pop    %ebp
f0105777:	c3                   	ret    

f0105778 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105778:	55                   	push   %ebp
f0105779:	89 e5                	mov    %esp,%ebp
f010577b:	57                   	push   %edi
f010577c:	56                   	push   %esi
f010577d:	53                   	push   %ebx
f010577e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105781:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105784:	85 c9                	test   %ecx,%ecx
f0105786:	74 36                	je     f01057be <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105788:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010578e:	75 28                	jne    f01057b8 <memset+0x40>
f0105790:	f6 c1 03             	test   $0x3,%cl
f0105793:	75 23                	jne    f01057b8 <memset+0x40>
		c &= 0xFF;
f0105795:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105799:	89 d3                	mov    %edx,%ebx
f010579b:	c1 e3 08             	shl    $0x8,%ebx
f010579e:	89 d6                	mov    %edx,%esi
f01057a0:	c1 e6 18             	shl    $0x18,%esi
f01057a3:	89 d0                	mov    %edx,%eax
f01057a5:	c1 e0 10             	shl    $0x10,%eax
f01057a8:	09 f0                	or     %esi,%eax
f01057aa:	09 c2                	or     %eax,%edx
f01057ac:	89 d0                	mov    %edx,%eax
f01057ae:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01057b0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01057b3:	fc                   	cld    
f01057b4:	f3 ab                	rep stos %eax,%es:(%edi)
f01057b6:	eb 06                	jmp    f01057be <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057bb:	fc                   	cld    
f01057bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057be:	89 f8                	mov    %edi,%eax
f01057c0:	5b                   	pop    %ebx
f01057c1:	5e                   	pop    %esi
f01057c2:	5f                   	pop    %edi
f01057c3:	5d                   	pop    %ebp
f01057c4:	c3                   	ret    

f01057c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057c5:	55                   	push   %ebp
f01057c6:	89 e5                	mov    %esp,%ebp
f01057c8:	57                   	push   %edi
f01057c9:	56                   	push   %esi
f01057ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01057cd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057d3:	39 c6                	cmp    %eax,%esi
f01057d5:	73 35                	jae    f010580c <memmove+0x47>
f01057d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057da:	39 d0                	cmp    %edx,%eax
f01057dc:	73 2e                	jae    f010580c <memmove+0x47>
		s += n;
		d += n;
f01057de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01057e1:	89 d6                	mov    %edx,%esi
f01057e3:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057eb:	75 13                	jne    f0105800 <memmove+0x3b>
f01057ed:	f6 c1 03             	test   $0x3,%cl
f01057f0:	75 0e                	jne    f0105800 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057f2:	83 ef 04             	sub    $0x4,%edi
f01057f5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057f8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01057fb:	fd                   	std    
f01057fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057fe:	eb 09                	jmp    f0105809 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105800:	83 ef 01             	sub    $0x1,%edi
f0105803:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105806:	fd                   	std    
f0105807:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105809:	fc                   	cld    
f010580a:	eb 1d                	jmp    f0105829 <memmove+0x64>
f010580c:	89 f2                	mov    %esi,%edx
f010580e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105810:	f6 c2 03             	test   $0x3,%dl
f0105813:	75 0f                	jne    f0105824 <memmove+0x5f>
f0105815:	f6 c1 03             	test   $0x3,%cl
f0105818:	75 0a                	jne    f0105824 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010581a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010581d:	89 c7                	mov    %eax,%edi
f010581f:	fc                   	cld    
f0105820:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105822:	eb 05                	jmp    f0105829 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105824:	89 c7                	mov    %eax,%edi
f0105826:	fc                   	cld    
f0105827:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105829:	5e                   	pop    %esi
f010582a:	5f                   	pop    %edi
f010582b:	5d                   	pop    %ebp
f010582c:	c3                   	ret    

f010582d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010582d:	55                   	push   %ebp
f010582e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105830:	ff 75 10             	pushl  0x10(%ebp)
f0105833:	ff 75 0c             	pushl  0xc(%ebp)
f0105836:	ff 75 08             	pushl  0x8(%ebp)
f0105839:	e8 87 ff ff ff       	call   f01057c5 <memmove>
}
f010583e:	c9                   	leave  
f010583f:	c3                   	ret    

f0105840 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105840:	55                   	push   %ebp
f0105841:	89 e5                	mov    %esp,%ebp
f0105843:	56                   	push   %esi
f0105844:	53                   	push   %ebx
f0105845:	8b 45 08             	mov    0x8(%ebp),%eax
f0105848:	8b 55 0c             	mov    0xc(%ebp),%edx
f010584b:	89 c6                	mov    %eax,%esi
f010584d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105850:	eb 1a                	jmp    f010586c <memcmp+0x2c>
		if (*s1 != *s2)
f0105852:	0f b6 08             	movzbl (%eax),%ecx
f0105855:	0f b6 1a             	movzbl (%edx),%ebx
f0105858:	38 d9                	cmp    %bl,%cl
f010585a:	74 0a                	je     f0105866 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010585c:	0f b6 c1             	movzbl %cl,%eax
f010585f:	0f b6 db             	movzbl %bl,%ebx
f0105862:	29 d8                	sub    %ebx,%eax
f0105864:	eb 0f                	jmp    f0105875 <memcmp+0x35>
		s1++, s2++;
f0105866:	83 c0 01             	add    $0x1,%eax
f0105869:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010586c:	39 f0                	cmp    %esi,%eax
f010586e:	75 e2                	jne    f0105852 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105870:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105875:	5b                   	pop    %ebx
f0105876:	5e                   	pop    %esi
f0105877:	5d                   	pop    %ebp
f0105878:	c3                   	ret    

f0105879 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105879:	55                   	push   %ebp
f010587a:	89 e5                	mov    %esp,%ebp
f010587c:	8b 45 08             	mov    0x8(%ebp),%eax
f010587f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105882:	89 c2                	mov    %eax,%edx
f0105884:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105887:	eb 07                	jmp    f0105890 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105889:	38 08                	cmp    %cl,(%eax)
f010588b:	74 07                	je     f0105894 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010588d:	83 c0 01             	add    $0x1,%eax
f0105890:	39 d0                	cmp    %edx,%eax
f0105892:	72 f5                	jb     f0105889 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105894:	5d                   	pop    %ebp
f0105895:	c3                   	ret    

f0105896 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105896:	55                   	push   %ebp
f0105897:	89 e5                	mov    %esp,%ebp
f0105899:	57                   	push   %edi
f010589a:	56                   	push   %esi
f010589b:	53                   	push   %ebx
f010589c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010589f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058a2:	eb 03                	jmp    f01058a7 <strtol+0x11>
		s++;
f01058a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058a7:	0f b6 01             	movzbl (%ecx),%eax
f01058aa:	3c 09                	cmp    $0x9,%al
f01058ac:	74 f6                	je     f01058a4 <strtol+0xe>
f01058ae:	3c 20                	cmp    $0x20,%al
f01058b0:	74 f2                	je     f01058a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058b2:	3c 2b                	cmp    $0x2b,%al
f01058b4:	75 0a                	jne    f01058c0 <strtol+0x2a>
		s++;
f01058b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01058be:	eb 10                	jmp    f01058d0 <strtol+0x3a>
f01058c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058c5:	3c 2d                	cmp    $0x2d,%al
f01058c7:	75 07                	jne    f01058d0 <strtol+0x3a>
		s++, neg = 1;
f01058c9:	8d 49 01             	lea    0x1(%ecx),%ecx
f01058cc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058d0:	85 db                	test   %ebx,%ebx
f01058d2:	0f 94 c0             	sete   %al
f01058d5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058db:	75 19                	jne    f01058f6 <strtol+0x60>
f01058dd:	80 39 30             	cmpb   $0x30,(%ecx)
f01058e0:	75 14                	jne    f01058f6 <strtol+0x60>
f01058e2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058e6:	0f 85 82 00 00 00    	jne    f010596e <strtol+0xd8>
		s += 2, base = 16;
f01058ec:	83 c1 02             	add    $0x2,%ecx
f01058ef:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058f4:	eb 16                	jmp    f010590c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01058f6:	84 c0                	test   %al,%al
f01058f8:	74 12                	je     f010590c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058ff:	80 39 30             	cmpb   $0x30,(%ecx)
f0105902:	75 08                	jne    f010590c <strtol+0x76>
		s++, base = 8;
f0105904:	83 c1 01             	add    $0x1,%ecx
f0105907:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010590c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105911:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105914:	0f b6 11             	movzbl (%ecx),%edx
f0105917:	8d 72 d0             	lea    -0x30(%edx),%esi
f010591a:	89 f3                	mov    %esi,%ebx
f010591c:	80 fb 09             	cmp    $0x9,%bl
f010591f:	77 08                	ja     f0105929 <strtol+0x93>
			dig = *s - '0';
f0105921:	0f be d2             	movsbl %dl,%edx
f0105924:	83 ea 30             	sub    $0x30,%edx
f0105927:	eb 22                	jmp    f010594b <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0105929:	8d 72 9f             	lea    -0x61(%edx),%esi
f010592c:	89 f3                	mov    %esi,%ebx
f010592e:	80 fb 19             	cmp    $0x19,%bl
f0105931:	77 08                	ja     f010593b <strtol+0xa5>
			dig = *s - 'a' + 10;
f0105933:	0f be d2             	movsbl %dl,%edx
f0105936:	83 ea 57             	sub    $0x57,%edx
f0105939:	eb 10                	jmp    f010594b <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f010593b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010593e:	89 f3                	mov    %esi,%ebx
f0105940:	80 fb 19             	cmp    $0x19,%bl
f0105943:	77 16                	ja     f010595b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105945:	0f be d2             	movsbl %dl,%edx
f0105948:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010594b:	3b 55 10             	cmp    0x10(%ebp),%edx
f010594e:	7d 0f                	jge    f010595f <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f0105950:	83 c1 01             	add    $0x1,%ecx
f0105953:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105957:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105959:	eb b9                	jmp    f0105914 <strtol+0x7e>
f010595b:	89 c2                	mov    %eax,%edx
f010595d:	eb 02                	jmp    f0105961 <strtol+0xcb>
f010595f:	89 c2                	mov    %eax,%edx

	if (endptr)
f0105961:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105965:	74 0d                	je     f0105974 <strtol+0xde>
		*endptr = (char *) s;
f0105967:	8b 75 0c             	mov    0xc(%ebp),%esi
f010596a:	89 0e                	mov    %ecx,(%esi)
f010596c:	eb 06                	jmp    f0105974 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010596e:	84 c0                	test   %al,%al
f0105970:	75 92                	jne    f0105904 <strtol+0x6e>
f0105972:	eb 98                	jmp    f010590c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105974:	f7 da                	neg    %edx
f0105976:	85 ff                	test   %edi,%edi
f0105978:	0f 45 c2             	cmovne %edx,%eax
}
f010597b:	5b                   	pop    %ebx
f010597c:	5e                   	pop    %esi
f010597d:	5f                   	pop    %edi
f010597e:	5d                   	pop    %ebp
f010597f:	c3                   	ret    

f0105980 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105980:	fa                   	cli    

	xorw    %ax, %ax
f0105981:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105983:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105985:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105987:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105989:	0f 01 16             	lgdtl  (%esi)
f010598c:	74 70                	je     f01059fe <mpsearch1+0x3>
	movl    %cr0, %eax
f010598e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105991:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105995:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105998:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010599e:	08 00                	or     %al,(%eax)

f01059a0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059a0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059a4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059a6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059a8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01059aa:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01059ae:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01059b0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01059b2:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01059b7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059ba:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059bd:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059c2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059c5:	8b 25 c4 fe 22 f0    	mov    0xf022fec4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059cb:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059d0:	b8 b4 01 10 f0       	mov    $0xf01001b4,%eax
	call    *%eax
f01059d5:	ff d0                	call   *%eax

f01059d7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059d7:	eb fe                	jmp    f01059d7 <spin>
f01059d9:	8d 76 00             	lea    0x0(%esi),%esi

f01059dc <gdt>:
	...
f01059e4:	ff                   	(bad)  
f01059e5:	ff 00                	incl   (%eax)
f01059e7:	00 00                	add    %al,(%eax)
f01059e9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059f0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01059f4 <gdtdesc>:
f01059f4:	17                   	pop    %ss
f01059f5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059fa <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059fa:	90                   	nop

f01059fb <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059fb:	55                   	push   %ebp
f01059fc:	89 e5                	mov    %esp,%ebp
f01059fe:	57                   	push   %edi
f01059ff:	56                   	push   %esi
f0105a00:	53                   	push   %ebx
f0105a01:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a04:	8b 0d c8 fe 22 f0    	mov    0xf022fec8,%ecx
f0105a0a:	89 c3                	mov    %eax,%ebx
f0105a0c:	c1 eb 0c             	shr    $0xc,%ebx
f0105a0f:	39 cb                	cmp    %ecx,%ebx
f0105a11:	72 12                	jb     f0105a25 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a13:	50                   	push   %eax
f0105a14:	68 64 64 10 f0       	push   $0xf0106464
f0105a19:	6a 57                	push   $0x57
f0105a1b:	68 e5 7f 10 f0       	push   $0xf0107fe5
f0105a20:	e8 1b a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a25:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a2b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a2d:	89 c2                	mov    %eax,%edx
f0105a2f:	c1 ea 0c             	shr    $0xc,%edx
f0105a32:	39 d1                	cmp    %edx,%ecx
f0105a34:	77 12                	ja     f0105a48 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a36:	50                   	push   %eax
f0105a37:	68 64 64 10 f0       	push   $0xf0106464
f0105a3c:	6a 57                	push   $0x57
f0105a3e:	68 e5 7f 10 f0       	push   $0xf0107fe5
f0105a43:	e8 f8 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a48:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a4e:	eb 2f                	jmp    f0105a7f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a50:	83 ec 04             	sub    $0x4,%esp
f0105a53:	6a 04                	push   $0x4
f0105a55:	68 f5 7f 10 f0       	push   $0xf0107ff5
f0105a5a:	53                   	push   %ebx
f0105a5b:	e8 e0 fd ff ff       	call   f0105840 <memcmp>
f0105a60:	83 c4 10             	add    $0x10,%esp
f0105a63:	85 c0                	test   %eax,%eax
f0105a65:	75 15                	jne    f0105a7c <mpsearch1+0x81>
f0105a67:	89 da                	mov    %ebx,%edx
f0105a69:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a6c:	0f b6 0a             	movzbl (%edx),%ecx
f0105a6f:	01 c8                	add    %ecx,%eax
f0105a71:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a74:	39 fa                	cmp    %edi,%edx
f0105a76:	75 f4                	jne    f0105a6c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a78:	84 c0                	test   %al,%al
f0105a7a:	74 0e                	je     f0105a8a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a7c:	83 c3 10             	add    $0x10,%ebx
f0105a7f:	39 f3                	cmp    %esi,%ebx
f0105a81:	72 cd                	jb     f0105a50 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a83:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a88:	eb 02                	jmp    f0105a8c <mpsearch1+0x91>
f0105a8a:	89 d8                	mov    %ebx,%eax
}
f0105a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a8f:	5b                   	pop    %ebx
f0105a90:	5e                   	pop    %esi
f0105a91:	5f                   	pop    %edi
f0105a92:	5d                   	pop    %ebp
f0105a93:	c3                   	ret    

f0105a94 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a94:	55                   	push   %ebp
f0105a95:	89 e5                	mov    %esp,%ebp
f0105a97:	57                   	push   %edi
f0105a98:	56                   	push   %esi
f0105a99:	53                   	push   %ebx
f0105a9a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a9d:	c7 05 e0 03 23 f0 40 	movl   $0xf0230040,0xf02303e0
f0105aa4:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105aa7:	83 3d c8 fe 22 f0 00 	cmpl   $0x0,0xf022fec8
f0105aae:	75 16                	jne    f0105ac6 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ab0:	68 00 04 00 00       	push   $0x400
f0105ab5:	68 64 64 10 f0       	push   $0xf0106464
f0105aba:	6a 6f                	push   $0x6f
f0105abc:	68 e5 7f 10 f0       	push   $0xf0107fe5
f0105ac1:	e8 7a a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105ac6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105acd:	85 c0                	test   %eax,%eax
f0105acf:	74 16                	je     f0105ae7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105ad1:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105ad4:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ad9:	e8 1d ff ff ff       	call   f01059fb <mpsearch1>
f0105ade:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ae1:	85 c0                	test   %eax,%eax
f0105ae3:	75 3c                	jne    f0105b21 <mp_init+0x8d>
f0105ae5:	eb 20                	jmp    f0105b07 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105ae7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105aee:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105af1:	2d 00 04 00 00       	sub    $0x400,%eax
f0105af6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105afb:	e8 fb fe ff ff       	call   f01059fb <mpsearch1>
f0105b00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b03:	85 c0                	test   %eax,%eax
f0105b05:	75 1a                	jne    f0105b21 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b07:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b0c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b11:	e8 e5 fe ff ff       	call   f01059fb <mpsearch1>
f0105b16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b19:	85 c0                	test   %eax,%eax
f0105b1b:	0f 84 5a 02 00 00    	je     f0105d7b <mp_init+0x2e7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b24:	8b 70 04             	mov    0x4(%eax),%esi
f0105b27:	85 f6                	test   %esi,%esi
f0105b29:	74 06                	je     f0105b31 <mp_init+0x9d>
f0105b2b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b2f:	74 15                	je     f0105b46 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b31:	83 ec 0c             	sub    $0xc,%esp
f0105b34:	68 58 7e 10 f0       	push   $0xf0107e58
f0105b39:	e8 0f dc ff ff       	call   f010374d <cprintf>
f0105b3e:	83 c4 10             	add    $0x10,%esp
f0105b41:	e9 35 02 00 00       	jmp    f0105d7b <mp_init+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b46:	89 f0                	mov    %esi,%eax
f0105b48:	c1 e8 0c             	shr    $0xc,%eax
f0105b4b:	3b 05 c8 fe 22 f0    	cmp    0xf022fec8,%eax
f0105b51:	72 15                	jb     f0105b68 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b53:	56                   	push   %esi
f0105b54:	68 64 64 10 f0       	push   $0xf0106464
f0105b59:	68 90 00 00 00       	push   $0x90
f0105b5e:	68 e5 7f 10 f0       	push   $0xf0107fe5
f0105b63:	e8 d8 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b68:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b6e:	83 ec 04             	sub    $0x4,%esp
f0105b71:	6a 04                	push   $0x4
f0105b73:	68 fa 7f 10 f0       	push   $0xf0107ffa
f0105b78:	53                   	push   %ebx
f0105b79:	e8 c2 fc ff ff       	call   f0105840 <memcmp>
f0105b7e:	83 c4 10             	add    $0x10,%esp
f0105b81:	85 c0                	test   %eax,%eax
f0105b83:	74 15                	je     f0105b9a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b85:	83 ec 0c             	sub    $0xc,%esp
f0105b88:	68 88 7e 10 f0       	push   $0xf0107e88
f0105b8d:	e8 bb db ff ff       	call   f010374d <cprintf>
f0105b92:	83 c4 10             	add    $0x10,%esp
f0105b95:	e9 e1 01 00 00       	jmp    f0105d7b <mp_init+0x2e7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b9a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b9e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105ba2:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ba5:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105baa:	b8 00 00 00 00       	mov    $0x0,%eax
f0105baf:	eb 0d                	jmp    f0105bbe <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105bb1:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105bb8:	f0 
f0105bb9:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bbb:	83 c0 01             	add    $0x1,%eax
f0105bbe:	39 c7                	cmp    %eax,%edi
f0105bc0:	75 ef                	jne    f0105bb1 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bc2:	84 d2                	test   %dl,%dl
f0105bc4:	74 15                	je     f0105bdb <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bc6:	83 ec 0c             	sub    $0xc,%esp
f0105bc9:	68 bc 7e 10 f0       	push   $0xf0107ebc
f0105bce:	e8 7a db ff ff       	call   f010374d <cprintf>
f0105bd3:	83 c4 10             	add    $0x10,%esp
f0105bd6:	e9 a0 01 00 00       	jmp    f0105d7b <mp_init+0x2e7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105bdb:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105bdf:	3c 04                	cmp    $0x4,%al
f0105be1:	74 1d                	je     f0105c00 <mp_init+0x16c>
f0105be3:	3c 01                	cmp    $0x1,%al
f0105be5:	74 19                	je     f0105c00 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105be7:	83 ec 08             	sub    $0x8,%esp
f0105bea:	0f b6 c0             	movzbl %al,%eax
f0105bed:	50                   	push   %eax
f0105bee:	68 e0 7e 10 f0       	push   $0xf0107ee0
f0105bf3:	e8 55 db ff ff       	call   f010374d <cprintf>
f0105bf8:	83 c4 10             	add    $0x10,%esp
f0105bfb:	e9 7b 01 00 00       	jmp    f0105d7b <mp_init+0x2e7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c00:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105c04:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c08:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c12:	01 ce                	add    %ecx,%esi
f0105c14:	eb 0d                	jmp    f0105c23 <mp_init+0x18f>
		sum += ((uint8_t *)addr)[i];
f0105c16:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c1d:	f0 
f0105c1e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c20:	83 c0 01             	add    $0x1,%eax
f0105c23:	39 c7                	cmp    %eax,%edi
f0105c25:	75 ef                	jne    f0105c16 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c27:	89 d0                	mov    %edx,%eax
f0105c29:	02 43 2a             	add    0x2a(%ebx),%al
f0105c2c:	74 15                	je     f0105c43 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c2e:	83 ec 0c             	sub    $0xc,%esp
f0105c31:	68 00 7f 10 f0       	push   $0xf0107f00
f0105c36:	e8 12 db ff ff       	call   f010374d <cprintf>
f0105c3b:	83 c4 10             	add    $0x10,%esp
f0105c3e:	e9 38 01 00 00       	jmp    f0105d7b <mp_init+0x2e7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c43:	85 db                	test   %ebx,%ebx
f0105c45:	0f 84 30 01 00 00    	je     f0105d7b <mp_init+0x2e7>
		return;
	ismp = 1;
f0105c4b:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105c52:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c55:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c58:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c5d:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c60:	be 00 00 00 00       	mov    $0x0,%esi
f0105c65:	e9 85 00 00 00       	jmp    f0105cef <mp_init+0x25b>
		switch (*p) {
f0105c6a:	0f b6 07             	movzbl (%edi),%eax
f0105c6d:	84 c0                	test   %al,%al
f0105c6f:	74 06                	je     f0105c77 <mp_init+0x1e3>
f0105c71:	3c 04                	cmp    $0x4,%al
f0105c73:	77 55                	ja     f0105cca <mp_init+0x236>
f0105c75:	eb 4e                	jmp    f0105cc5 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c77:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c7b:	74 11                	je     f0105c8e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105c7d:	6b 05 e4 03 23 f0 74 	imul   $0x74,0xf02303e4,%eax
f0105c84:	05 40 00 23 f0       	add    $0xf0230040,%eax
f0105c89:	a3 e0 03 23 f0       	mov    %eax,0xf02303e0
			if (ncpu < NCPU) {
f0105c8e:	a1 e4 03 23 f0       	mov    0xf02303e4,%eax
f0105c93:	83 f8 07             	cmp    $0x7,%eax
f0105c96:	7f 13                	jg     f0105cab <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c98:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c9b:	88 82 40 00 23 f0    	mov    %al,-0xfdcffc0(%edx)
				ncpu++;
f0105ca1:	83 c0 01             	add    $0x1,%eax
f0105ca4:	a3 e4 03 23 f0       	mov    %eax,0xf02303e4
f0105ca9:	eb 15                	jmp    f0105cc0 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105cab:	83 ec 08             	sub    $0x8,%esp
f0105cae:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105cb2:	50                   	push   %eax
f0105cb3:	68 30 7f 10 f0       	push   $0xf0107f30
f0105cb8:	e8 90 da ff ff       	call   f010374d <cprintf>
f0105cbd:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105cc0:	83 c7 14             	add    $0x14,%edi
			continue;
f0105cc3:	eb 27                	jmp    f0105cec <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cc5:	83 c7 08             	add    $0x8,%edi
			continue;
f0105cc8:	eb 22                	jmp    f0105cec <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105cca:	83 ec 08             	sub    $0x8,%esp
f0105ccd:	0f b6 c0             	movzbl %al,%eax
f0105cd0:	50                   	push   %eax
f0105cd1:	68 58 7f 10 f0       	push   $0xf0107f58
f0105cd6:	e8 72 da ff ff       	call   f010374d <cprintf>
			ismp = 0;
f0105cdb:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105ce2:	00 00 00 
			i = conf->entry;
f0105ce5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ce9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cec:	83 c6 01             	add    $0x1,%esi
f0105cef:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105cf3:	39 c6                	cmp    %eax,%esi
f0105cf5:	0f 82 6f ff ff ff    	jb     f0105c6a <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105cfb:	a1 e0 03 23 f0       	mov    0xf02303e0,%eax
f0105d00:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d07:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105d0e:	75 26                	jne    f0105d36 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d10:	c7 05 e4 03 23 f0 01 	movl   $0x1,0xf02303e4
f0105d17:	00 00 00 
		lapicaddr = 0;
f0105d1a:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105d21:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d24:	83 ec 0c             	sub    $0xc,%esp
f0105d27:	68 78 7f 10 f0       	push   $0xf0107f78
f0105d2c:	e8 1c da ff ff       	call   f010374d <cprintf>
		return;
f0105d31:	83 c4 10             	add    $0x10,%esp
f0105d34:	eb 45                	jmp    f0105d7b <mp_init+0x2e7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d36:	83 ec 04             	sub    $0x4,%esp
f0105d39:	ff 35 e4 03 23 f0    	pushl  0xf02303e4
f0105d3f:	0f b6 00             	movzbl (%eax),%eax
f0105d42:	50                   	push   %eax
f0105d43:	68 ff 7f 10 f0       	push   $0xf0107fff
f0105d48:	e8 00 da ff ff       	call   f010374d <cprintf>

	if (mp->imcrp) {
f0105d4d:	83 c4 10             	add    $0x10,%esp
f0105d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d53:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d57:	74 22                	je     f0105d7b <mp_init+0x2e7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d59:	83 ec 0c             	sub    $0xc,%esp
f0105d5c:	68 a4 7f 10 f0       	push   $0xf0107fa4
f0105d61:	e8 e7 d9 ff ff       	call   f010374d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d66:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d6b:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d70:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d71:	b2 23                	mov    $0x23,%dl
f0105d73:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105d74:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d77:	ee                   	out    %al,(%dx)
f0105d78:	83 c4 10             	add    $0x10,%esp
	}
}
f0105d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d7e:	5b                   	pop    %ebx
f0105d7f:	5e                   	pop    %esi
f0105d80:	5f                   	pop    %edi
f0105d81:	5d                   	pop    %ebp
f0105d82:	c3                   	ret    

f0105d83 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d83:	55                   	push   %ebp
f0105d84:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d86:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105d8c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d8f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d91:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105d96:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d99:	5d                   	pop    %ebp
f0105d9a:	c3                   	ret    

f0105d9b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d9b:	55                   	push   %ebp
f0105d9c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d9e:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105da3:	85 c0                	test   %eax,%eax
f0105da5:	74 08                	je     f0105daf <cpunum+0x14>
		return lapic[ID] >> 24;
f0105da7:	8b 40 20             	mov    0x20(%eax),%eax
f0105daa:	c1 e8 18             	shr    $0x18,%eax
f0105dad:	eb 05                	jmp    f0105db4 <cpunum+0x19>
	return 0;
f0105daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105db4:	5d                   	pop    %ebp
f0105db5:	c3                   	ret    

f0105db6 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105db6:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105dbb:	85 c0                	test   %eax,%eax
f0105dbd:	0f 84 21 01 00 00    	je     f0105ee4 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105dc3:	55                   	push   %ebp
f0105dc4:	89 e5                	mov    %esp,%ebp
f0105dc6:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105dc9:	68 00 10 00 00       	push   $0x1000
f0105dce:	50                   	push   %eax
f0105dcf:	e8 2c b5 ff ff       	call   f0101300 <mmio_map_region>
f0105dd4:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105dd9:	ba 27 01 00 00       	mov    $0x127,%edx
f0105dde:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105de3:	e8 9b ff ff ff       	call   f0105d83 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105de8:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105ded:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105df2:	e8 8c ff ff ff       	call   f0105d83 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105df7:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105dfc:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e01:	e8 7d ff ff ff       	call   f0105d83 <lapicw>
	lapicw(TICR, 10000000); 
f0105e06:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e0b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e10:	e8 6e ff ff ff       	call   f0105d83 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e15:	e8 81 ff ff ff       	call   f0105d9b <cpunum>
f0105e1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e1d:	05 40 00 23 f0       	add    $0xf0230040,%eax
f0105e22:	83 c4 10             	add    $0x10,%esp
f0105e25:	39 05 e0 03 23 f0    	cmp    %eax,0xf02303e0
f0105e2b:	74 0f                	je     f0105e3c <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e2d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e32:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e37:	e8 47 ff ff ff       	call   f0105d83 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e3c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e41:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e46:	e8 38 ff ff ff       	call   f0105d83 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e4b:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105e50:	8b 40 30             	mov    0x30(%eax),%eax
f0105e53:	c1 e8 10             	shr    $0x10,%eax
f0105e56:	3c 03                	cmp    $0x3,%al
f0105e58:	76 0f                	jbe    f0105e69 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e5a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e5f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e64:	e8 1a ff ff ff       	call   f0105d83 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e69:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e6e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e73:	e8 0b ff ff ff       	call   f0105d83 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e78:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e7d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e82:	e8 fc fe ff ff       	call   f0105d83 <lapicw>
	lapicw(ESR, 0);
f0105e87:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e8c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e91:	e8 ed fe ff ff       	call   f0105d83 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e96:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e9b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ea0:	e8 de fe ff ff       	call   f0105d83 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105ea5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eaa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105eaf:	e8 cf fe ff ff       	call   f0105d83 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105eb4:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105eb9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ebe:	e8 c0 fe ff ff       	call   f0105d83 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105ec3:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105ec9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105ecf:	f6 c4 10             	test   $0x10,%ah
f0105ed2:	75 f5                	jne    f0105ec9 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ed4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed9:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ede:	e8 a0 fe ff ff       	call   f0105d83 <lapicw>
}
f0105ee3:	c9                   	leave  
f0105ee4:	f3 c3                	repz ret 

f0105ee6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ee6:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105eed:	74 13                	je     f0105f02 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105eef:	55                   	push   %ebp
f0105ef0:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105ef2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ef7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105efc:	e8 82 fe ff ff       	call   f0105d83 <lapicw>
}
f0105f01:	5d                   	pop    %ebp
f0105f02:	f3 c3                	repz ret 

f0105f04 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f04:	55                   	push   %ebp
f0105f05:	89 e5                	mov    %esp,%ebp
f0105f07:	56                   	push   %esi
f0105f08:	53                   	push   %ebx
f0105f09:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f14:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f19:	ee                   	out    %al,(%dx)
f0105f1a:	b2 71                	mov    $0x71,%dl
f0105f1c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f21:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f22:	83 3d c8 fe 22 f0 00 	cmpl   $0x0,0xf022fec8
f0105f29:	75 19                	jne    f0105f44 <lapic_startap+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f2b:	68 67 04 00 00       	push   $0x467
f0105f30:	68 64 64 10 f0       	push   $0xf0106464
f0105f35:	68 98 00 00 00       	push   $0x98
f0105f3a:	68 1c 80 10 f0       	push   $0xf010801c
f0105f3f:	e8 fc a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f44:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f4b:	00 00 
	wrv[1] = addr >> 4;
f0105f4d:	89 d8                	mov    %ebx,%eax
f0105f4f:	c1 e8 04             	shr    $0x4,%eax
f0105f52:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f58:	c1 e6 18             	shl    $0x18,%esi
f0105f5b:	89 f2                	mov    %esi,%edx
f0105f5d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f62:	e8 1c fe ff ff       	call   f0105d83 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f67:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f6c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f71:	e8 0d fe ff ff       	call   f0105d83 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f76:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f7b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f80:	e8 fe fd ff ff       	call   f0105d83 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f85:	c1 eb 0c             	shr    $0xc,%ebx
f0105f88:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f8b:	89 f2                	mov    %esi,%edx
f0105f8d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f92:	e8 ec fd ff ff       	call   f0105d83 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f97:	89 da                	mov    %ebx,%edx
f0105f99:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f9e:	e8 e0 fd ff ff       	call   f0105d83 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fa3:	89 f2                	mov    %esi,%edx
f0105fa5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105faa:	e8 d4 fd ff ff       	call   f0105d83 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105faf:	89 da                	mov    %ebx,%edx
f0105fb1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fb6:	e8 c8 fd ff ff       	call   f0105d83 <lapicw>
		microdelay(200);
	}
}
f0105fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fbe:	5b                   	pop    %ebx
f0105fbf:	5e                   	pop    %esi
f0105fc0:	5d                   	pop    %ebp
f0105fc1:	c3                   	ret    

f0105fc2 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105fc2:	55                   	push   %ebp
f0105fc3:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105fc5:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fc8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105fce:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fd3:	e8 ab fd ff ff       	call   f0105d83 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105fd8:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105fde:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fe4:	f6 c4 10             	test   $0x10,%ah
f0105fe7:	75 f5                	jne    f0105fde <lapic_ipi+0x1c>
		;
}
f0105fe9:	5d                   	pop    %ebp
f0105fea:	c3                   	ret    

f0105feb <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105feb:	55                   	push   %ebp
f0105fec:	89 e5                	mov    %esp,%ebp
f0105fee:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ffa:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105ffd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106004:	5d                   	pop    %ebp
f0106005:	c3                   	ret    

f0106006 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106006:	55                   	push   %ebp
f0106007:	89 e5                	mov    %esp,%ebp
f0106009:	56                   	push   %esi
f010600a:	53                   	push   %ebx
f010600b:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010600e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106011:	74 14                	je     f0106027 <spin_lock+0x21>
f0106013:	8b 73 08             	mov    0x8(%ebx),%esi
f0106016:	e8 80 fd ff ff       	call   f0105d9b <cpunum>
f010601b:	6b c0 74             	imul   $0x74,%eax,%eax
f010601e:	05 40 00 23 f0       	add    $0xf0230040,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106023:	39 c6                	cmp    %eax,%esi
f0106025:	74 07                	je     f010602e <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106027:	ba 01 00 00 00       	mov    $0x1,%edx
f010602c:	eb 20                	jmp    f010604e <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010602e:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106031:	e8 65 fd ff ff       	call   f0105d9b <cpunum>
f0106036:	83 ec 0c             	sub    $0xc,%esp
f0106039:	53                   	push   %ebx
f010603a:	50                   	push   %eax
f010603b:	68 2c 80 10 f0       	push   $0xf010802c
f0106040:	6a 41                	push   $0x41
f0106042:	68 90 80 10 f0       	push   $0xf0108090
f0106047:	e8 f4 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010604c:	f3 90                	pause  
f010604e:	89 d0                	mov    %edx,%eax
f0106050:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106053:	85 c0                	test   %eax,%eax
f0106055:	75 f5                	jne    f010604c <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106057:	e8 3f fd ff ff       	call   f0105d9b <cpunum>
f010605c:	6b c0 74             	imul   $0x74,%eax,%eax
f010605f:	05 40 00 23 f0       	add    $0xf0230040,%eax
f0106064:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106067:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010606a:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010606c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106071:	eb 0b                	jmp    f010607e <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106073:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106076:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106079:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010607b:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010607e:	83 f8 09             	cmp    $0x9,%eax
f0106081:	7f 14                	jg     f0106097 <spin_lock+0x91>
f0106083:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106089:	77 e8                	ja     f0106073 <spin_lock+0x6d>
f010608b:	eb 0a                	jmp    f0106097 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010608d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106094:	83 c0 01             	add    $0x1,%eax
f0106097:	83 f8 09             	cmp    $0x9,%eax
f010609a:	7e f1                	jle    f010608d <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010609c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010609f:	5b                   	pop    %ebx
f01060a0:	5e                   	pop    %esi
f01060a1:	5d                   	pop    %ebp
f01060a2:	c3                   	ret    

f01060a3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01060a3:	55                   	push   %ebp
f01060a4:	89 e5                	mov    %esp,%ebp
f01060a6:	57                   	push   %edi
f01060a7:	56                   	push   %esi
f01060a8:	53                   	push   %ebx
f01060a9:	83 ec 4c             	sub    $0x4c,%esp
f01060ac:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01060af:	83 3e 00             	cmpl   $0x0,(%esi)
f01060b2:	74 18                	je     f01060cc <spin_unlock+0x29>
f01060b4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060b7:	e8 df fc ff ff       	call   f0105d9b <cpunum>
f01060bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01060bf:	05 40 00 23 f0       	add    $0xf0230040,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01060c4:	39 c3                	cmp    %eax,%ebx
f01060c6:	0f 84 a5 00 00 00    	je     f0106171 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01060cc:	83 ec 04             	sub    $0x4,%esp
f01060cf:	6a 28                	push   $0x28
f01060d1:	8d 46 0c             	lea    0xc(%esi),%eax
f01060d4:	50                   	push   %eax
f01060d5:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01060d8:	53                   	push   %ebx
f01060d9:	e8 e7 f6 ff ff       	call   f01057c5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060de:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060e1:	0f b6 38             	movzbl (%eax),%edi
f01060e4:	8b 76 04             	mov    0x4(%esi),%esi
f01060e7:	e8 af fc ff ff       	call   f0105d9b <cpunum>
f01060ec:	57                   	push   %edi
f01060ed:	56                   	push   %esi
f01060ee:	50                   	push   %eax
f01060ef:	68 58 80 10 f0       	push   $0xf0108058
f01060f4:	e8 54 d6 ff ff       	call   f010374d <cprintf>
f01060f9:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060fc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060ff:	eb 54                	jmp    f0106155 <spin_unlock+0xb2>
f0106101:	83 ec 08             	sub    $0x8,%esp
f0106104:	57                   	push   %edi
f0106105:	50                   	push   %eax
f0106106:	e8 fe eb ff ff       	call   f0104d09 <debuginfo_eip>
f010610b:	83 c4 10             	add    $0x10,%esp
f010610e:	85 c0                	test   %eax,%eax
f0106110:	78 27                	js     f0106139 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106112:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106114:	83 ec 04             	sub    $0x4,%esp
f0106117:	89 c2                	mov    %eax,%edx
f0106119:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010611c:	52                   	push   %edx
f010611d:	ff 75 b0             	pushl  -0x50(%ebp)
f0106120:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106123:	ff 75 ac             	pushl  -0x54(%ebp)
f0106126:	ff 75 a8             	pushl  -0x58(%ebp)
f0106129:	50                   	push   %eax
f010612a:	68 a0 80 10 f0       	push   $0xf01080a0
f010612f:	e8 19 d6 ff ff       	call   f010374d <cprintf>
f0106134:	83 c4 20             	add    $0x20,%esp
f0106137:	eb 12                	jmp    f010614b <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106139:	83 ec 08             	sub    $0x8,%esp
f010613c:	ff 36                	pushl  (%esi)
f010613e:	68 b7 80 10 f0       	push   $0xf01080b7
f0106143:	e8 05 d6 ff ff       	call   f010374d <cprintf>
f0106148:	83 c4 10             	add    $0x10,%esp
f010614b:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010614e:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106151:	39 c3                	cmp    %eax,%ebx
f0106153:	74 08                	je     f010615d <spin_unlock+0xba>
f0106155:	89 de                	mov    %ebx,%esi
f0106157:	8b 03                	mov    (%ebx),%eax
f0106159:	85 c0                	test   %eax,%eax
f010615b:	75 a4                	jne    f0106101 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010615d:	83 ec 04             	sub    $0x4,%esp
f0106160:	68 bf 80 10 f0       	push   $0xf01080bf
f0106165:	6a 67                	push   $0x67
f0106167:	68 90 80 10 f0       	push   $0xf0108090
f010616c:	e8 cf 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106171:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106178:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f010617f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106184:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106187:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010618a:	5b                   	pop    %ebx
f010618b:	5e                   	pop    %esi
f010618c:	5f                   	pop    %edi
f010618d:	5d                   	pop    %ebp
f010618e:	c3                   	ret    
f010618f:	90                   	nop

f0106190 <__udivdi3>:
f0106190:	55                   	push   %ebp
f0106191:	57                   	push   %edi
f0106192:	56                   	push   %esi
f0106193:	83 ec 10             	sub    $0x10,%esp
f0106196:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010619a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010619e:	8b 74 24 24          	mov    0x24(%esp),%esi
f01061a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01061a6:	85 d2                	test   %edx,%edx
f01061a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061ac:	89 34 24             	mov    %esi,(%esp)
f01061af:	89 c8                	mov    %ecx,%eax
f01061b1:	75 35                	jne    f01061e8 <__udivdi3+0x58>
f01061b3:	39 f1                	cmp    %esi,%ecx
f01061b5:	0f 87 bd 00 00 00    	ja     f0106278 <__udivdi3+0xe8>
f01061bb:	85 c9                	test   %ecx,%ecx
f01061bd:	89 cd                	mov    %ecx,%ebp
f01061bf:	75 0b                	jne    f01061cc <__udivdi3+0x3c>
f01061c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01061c6:	31 d2                	xor    %edx,%edx
f01061c8:	f7 f1                	div    %ecx
f01061ca:	89 c5                	mov    %eax,%ebp
f01061cc:	89 f0                	mov    %esi,%eax
f01061ce:	31 d2                	xor    %edx,%edx
f01061d0:	f7 f5                	div    %ebp
f01061d2:	89 c6                	mov    %eax,%esi
f01061d4:	89 f8                	mov    %edi,%eax
f01061d6:	f7 f5                	div    %ebp
f01061d8:	89 f2                	mov    %esi,%edx
f01061da:	83 c4 10             	add    $0x10,%esp
f01061dd:	5e                   	pop    %esi
f01061de:	5f                   	pop    %edi
f01061df:	5d                   	pop    %ebp
f01061e0:	c3                   	ret    
f01061e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061e8:	3b 14 24             	cmp    (%esp),%edx
f01061eb:	77 7b                	ja     f0106268 <__udivdi3+0xd8>
f01061ed:	0f bd f2             	bsr    %edx,%esi
f01061f0:	83 f6 1f             	xor    $0x1f,%esi
f01061f3:	0f 84 97 00 00 00    	je     f0106290 <__udivdi3+0x100>
f01061f9:	bd 20 00 00 00       	mov    $0x20,%ebp
f01061fe:	89 d7                	mov    %edx,%edi
f0106200:	89 f1                	mov    %esi,%ecx
f0106202:	29 f5                	sub    %esi,%ebp
f0106204:	d3 e7                	shl    %cl,%edi
f0106206:	89 c2                	mov    %eax,%edx
f0106208:	89 e9                	mov    %ebp,%ecx
f010620a:	d3 ea                	shr    %cl,%edx
f010620c:	89 f1                	mov    %esi,%ecx
f010620e:	09 fa                	or     %edi,%edx
f0106210:	8b 3c 24             	mov    (%esp),%edi
f0106213:	d3 e0                	shl    %cl,%eax
f0106215:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106219:	89 e9                	mov    %ebp,%ecx
f010621b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010621f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106223:	89 fa                	mov    %edi,%edx
f0106225:	d3 ea                	shr    %cl,%edx
f0106227:	89 f1                	mov    %esi,%ecx
f0106229:	d3 e7                	shl    %cl,%edi
f010622b:	89 e9                	mov    %ebp,%ecx
f010622d:	d3 e8                	shr    %cl,%eax
f010622f:	09 c7                	or     %eax,%edi
f0106231:	89 f8                	mov    %edi,%eax
f0106233:	f7 74 24 08          	divl   0x8(%esp)
f0106237:	89 d5                	mov    %edx,%ebp
f0106239:	89 c7                	mov    %eax,%edi
f010623b:	f7 64 24 0c          	mull   0xc(%esp)
f010623f:	39 d5                	cmp    %edx,%ebp
f0106241:	89 14 24             	mov    %edx,(%esp)
f0106244:	72 11                	jb     f0106257 <__udivdi3+0xc7>
f0106246:	8b 54 24 04          	mov    0x4(%esp),%edx
f010624a:	89 f1                	mov    %esi,%ecx
f010624c:	d3 e2                	shl    %cl,%edx
f010624e:	39 c2                	cmp    %eax,%edx
f0106250:	73 5e                	jae    f01062b0 <__udivdi3+0x120>
f0106252:	3b 2c 24             	cmp    (%esp),%ebp
f0106255:	75 59                	jne    f01062b0 <__udivdi3+0x120>
f0106257:	8d 47 ff             	lea    -0x1(%edi),%eax
f010625a:	31 f6                	xor    %esi,%esi
f010625c:	89 f2                	mov    %esi,%edx
f010625e:	83 c4 10             	add    $0x10,%esp
f0106261:	5e                   	pop    %esi
f0106262:	5f                   	pop    %edi
f0106263:	5d                   	pop    %ebp
f0106264:	c3                   	ret    
f0106265:	8d 76 00             	lea    0x0(%esi),%esi
f0106268:	31 f6                	xor    %esi,%esi
f010626a:	31 c0                	xor    %eax,%eax
f010626c:	89 f2                	mov    %esi,%edx
f010626e:	83 c4 10             	add    $0x10,%esp
f0106271:	5e                   	pop    %esi
f0106272:	5f                   	pop    %edi
f0106273:	5d                   	pop    %ebp
f0106274:	c3                   	ret    
f0106275:	8d 76 00             	lea    0x0(%esi),%esi
f0106278:	89 f2                	mov    %esi,%edx
f010627a:	31 f6                	xor    %esi,%esi
f010627c:	89 f8                	mov    %edi,%eax
f010627e:	f7 f1                	div    %ecx
f0106280:	89 f2                	mov    %esi,%edx
f0106282:	83 c4 10             	add    $0x10,%esp
f0106285:	5e                   	pop    %esi
f0106286:	5f                   	pop    %edi
f0106287:	5d                   	pop    %ebp
f0106288:	c3                   	ret    
f0106289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106290:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106294:	76 0b                	jbe    f01062a1 <__udivdi3+0x111>
f0106296:	31 c0                	xor    %eax,%eax
f0106298:	3b 14 24             	cmp    (%esp),%edx
f010629b:	0f 83 37 ff ff ff    	jae    f01061d8 <__udivdi3+0x48>
f01062a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01062a6:	e9 2d ff ff ff       	jmp    f01061d8 <__udivdi3+0x48>
f01062ab:	90                   	nop
f01062ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062b0:	89 f8                	mov    %edi,%eax
f01062b2:	31 f6                	xor    %esi,%esi
f01062b4:	e9 1f ff ff ff       	jmp    f01061d8 <__udivdi3+0x48>
f01062b9:	66 90                	xchg   %ax,%ax
f01062bb:	66 90                	xchg   %ax,%ax
f01062bd:	66 90                	xchg   %ax,%ax
f01062bf:	90                   	nop

f01062c0 <__umoddi3>:
f01062c0:	55                   	push   %ebp
f01062c1:	57                   	push   %edi
f01062c2:	56                   	push   %esi
f01062c3:	83 ec 20             	sub    $0x20,%esp
f01062c6:	8b 44 24 34          	mov    0x34(%esp),%eax
f01062ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01062ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01062d2:	89 c6                	mov    %eax,%esi
f01062d4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01062d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01062dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01062e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01062e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01062e8:	89 74 24 18          	mov    %esi,0x18(%esp)
f01062ec:	85 c0                	test   %eax,%eax
f01062ee:	89 c2                	mov    %eax,%edx
f01062f0:	75 1e                	jne    f0106310 <__umoddi3+0x50>
f01062f2:	39 f7                	cmp    %esi,%edi
f01062f4:	76 52                	jbe    f0106348 <__umoddi3+0x88>
f01062f6:	89 c8                	mov    %ecx,%eax
f01062f8:	89 f2                	mov    %esi,%edx
f01062fa:	f7 f7                	div    %edi
f01062fc:	89 d0                	mov    %edx,%eax
f01062fe:	31 d2                	xor    %edx,%edx
f0106300:	83 c4 20             	add    $0x20,%esp
f0106303:	5e                   	pop    %esi
f0106304:	5f                   	pop    %edi
f0106305:	5d                   	pop    %ebp
f0106306:	c3                   	ret    
f0106307:	89 f6                	mov    %esi,%esi
f0106309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106310:	39 f0                	cmp    %esi,%eax
f0106312:	77 5c                	ja     f0106370 <__umoddi3+0xb0>
f0106314:	0f bd e8             	bsr    %eax,%ebp
f0106317:	83 f5 1f             	xor    $0x1f,%ebp
f010631a:	75 64                	jne    f0106380 <__umoddi3+0xc0>
f010631c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0106320:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0106324:	0f 86 f6 00 00 00    	jbe    f0106420 <__umoddi3+0x160>
f010632a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010632e:	0f 82 ec 00 00 00    	jb     f0106420 <__umoddi3+0x160>
f0106334:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106338:	8b 54 24 18          	mov    0x18(%esp),%edx
f010633c:	83 c4 20             	add    $0x20,%esp
f010633f:	5e                   	pop    %esi
f0106340:	5f                   	pop    %edi
f0106341:	5d                   	pop    %ebp
f0106342:	c3                   	ret    
f0106343:	90                   	nop
f0106344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106348:	85 ff                	test   %edi,%edi
f010634a:	89 fd                	mov    %edi,%ebp
f010634c:	75 0b                	jne    f0106359 <__umoddi3+0x99>
f010634e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106353:	31 d2                	xor    %edx,%edx
f0106355:	f7 f7                	div    %edi
f0106357:	89 c5                	mov    %eax,%ebp
f0106359:	8b 44 24 10          	mov    0x10(%esp),%eax
f010635d:	31 d2                	xor    %edx,%edx
f010635f:	f7 f5                	div    %ebp
f0106361:	89 c8                	mov    %ecx,%eax
f0106363:	f7 f5                	div    %ebp
f0106365:	eb 95                	jmp    f01062fc <__umoddi3+0x3c>
f0106367:	89 f6                	mov    %esi,%esi
f0106369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106370:	89 c8                	mov    %ecx,%eax
f0106372:	89 f2                	mov    %esi,%edx
f0106374:	83 c4 20             	add    $0x20,%esp
f0106377:	5e                   	pop    %esi
f0106378:	5f                   	pop    %edi
f0106379:	5d                   	pop    %ebp
f010637a:	c3                   	ret    
f010637b:	90                   	nop
f010637c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106380:	b8 20 00 00 00       	mov    $0x20,%eax
f0106385:	89 e9                	mov    %ebp,%ecx
f0106387:	29 e8                	sub    %ebp,%eax
f0106389:	d3 e2                	shl    %cl,%edx
f010638b:	89 c7                	mov    %eax,%edi
f010638d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106391:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106395:	89 f9                	mov    %edi,%ecx
f0106397:	d3 e8                	shr    %cl,%eax
f0106399:	89 c1                	mov    %eax,%ecx
f010639b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010639f:	09 d1                	or     %edx,%ecx
f01063a1:	89 fa                	mov    %edi,%edx
f01063a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01063a7:	89 e9                	mov    %ebp,%ecx
f01063a9:	d3 e0                	shl    %cl,%eax
f01063ab:	89 f9                	mov    %edi,%ecx
f01063ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063b1:	89 f0                	mov    %esi,%eax
f01063b3:	d3 e8                	shr    %cl,%eax
f01063b5:	89 e9                	mov    %ebp,%ecx
f01063b7:	89 c7                	mov    %eax,%edi
f01063b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01063bd:	d3 e6                	shl    %cl,%esi
f01063bf:	89 d1                	mov    %edx,%ecx
f01063c1:	89 fa                	mov    %edi,%edx
f01063c3:	d3 e8                	shr    %cl,%eax
f01063c5:	89 e9                	mov    %ebp,%ecx
f01063c7:	09 f0                	or     %esi,%eax
f01063c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f01063cd:	f7 74 24 10          	divl   0x10(%esp)
f01063d1:	d3 e6                	shl    %cl,%esi
f01063d3:	89 d1                	mov    %edx,%ecx
f01063d5:	f7 64 24 0c          	mull   0xc(%esp)
f01063d9:	39 d1                	cmp    %edx,%ecx
f01063db:	89 74 24 14          	mov    %esi,0x14(%esp)
f01063df:	89 d7                	mov    %edx,%edi
f01063e1:	89 c6                	mov    %eax,%esi
f01063e3:	72 0a                	jb     f01063ef <__umoddi3+0x12f>
f01063e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
f01063e9:	73 10                	jae    f01063fb <__umoddi3+0x13b>
f01063eb:	39 d1                	cmp    %edx,%ecx
f01063ed:	75 0c                	jne    f01063fb <__umoddi3+0x13b>
f01063ef:	89 d7                	mov    %edx,%edi
f01063f1:	89 c6                	mov    %eax,%esi
f01063f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f01063f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f01063fb:	89 ca                	mov    %ecx,%edx
f01063fd:	89 e9                	mov    %ebp,%ecx
f01063ff:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106403:	29 f0                	sub    %esi,%eax
f0106405:	19 fa                	sbb    %edi,%edx
f0106407:	d3 e8                	shr    %cl,%eax
f0106409:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010640e:	89 d7                	mov    %edx,%edi
f0106410:	d3 e7                	shl    %cl,%edi
f0106412:	89 e9                	mov    %ebp,%ecx
f0106414:	09 f8                	or     %edi,%eax
f0106416:	d3 ea                	shr    %cl,%edx
f0106418:	83 c4 20             	add    $0x20,%esp
f010641b:	5e                   	pop    %esi
f010641c:	5f                   	pop    %edi
f010641d:	5d                   	pop    %ebp
f010641e:	c3                   	ret    
f010641f:	90                   	nop
f0106420:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106424:	29 f9                	sub    %edi,%ecx
f0106426:	19 c6                	sbb    %eax,%esi
f0106428:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010642c:	89 74 24 18          	mov    %esi,0x18(%esp)
f0106430:	e9 ff fe ff ff       	jmp    f0106334 <__umoddi3+0x74>
