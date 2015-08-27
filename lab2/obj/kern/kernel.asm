
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 79 11 f0       	mov    $0xf0117990,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 73 11 f0       	push   $0xf0117300
f0100058:	e8 8b 32 00 00       	call   f01032e8 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 85 04 00 00       	call   f01004e7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 c0 37 10 f0       	push   $0xf01037c0
f010006f:	e8 88 27 00 00       	call   f01027fc <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 9b 10 00 00       	call   f0101114 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 87 07 00 00       	call   f010080d <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 80 79 11 f0 00 	cmpl   $0x0,0xf0117980
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 80 79 11 f0    	mov    %esi,0xf0117980

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 db 37 10 f0       	push   $0xf01037db
f01000b5:	e8 42 27 00 00       	call   f01027fc <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 12 27 00 00       	call   f01027d6 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 04 40 10 f0 	movl   $0xf0104004,(%esp)
f01000cb:	e8 2c 27 00 00       	call   f01027fc <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 30 07 00 00       	call   f010080d <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 f3 37 10 f0       	push   $0xf01037f3
f01000f7:	e8 00 27 00 00       	call   f01027fc <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 ce 26 00 00       	call   f01027d6 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 04 40 10 f0 	movl   $0xf0104004,(%esp)
f010010f:	e8 e8 26 00 00       	call   f01027fc <cprintf>
	va_end(ap);
f0100114:	83 c4 10             	add    $0x10,%esp
}
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 08                	je     f0100131 <serial_proc_data+0x15>
f0100129:	b2 f8                	mov    $0xf8,%dl
f010012b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012c:	0f b6 c0             	movzbl %al,%eax
f010012f:	eb 05                	jmp    f0100136 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    

f0100138 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp
f010013b:	53                   	push   %ebx
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100141:	eb 2a                	jmp    f010016d <cons_intr+0x35>
		if (c == 0)
f0100143:	85 d2                	test   %edx,%edx
f0100145:	74 26                	je     f010016d <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100147:	a1 44 75 11 f0       	mov    0xf0117544,%eax
f010014c:	8d 48 01             	lea    0x1(%eax),%ecx
f010014f:	89 0d 44 75 11 f0    	mov    %ecx,0xf0117544
f0100155:	88 90 40 73 11 f0    	mov    %dl,-0xfee8cc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010015b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100161:	75 0a                	jne    f010016d <cons_intr+0x35>
			cons.wpos = 0;
f0100163:	c7 05 44 75 11 f0 00 	movl   $0x0,0xf0117544
f010016a:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010016d:	ff d3                	call   *%ebx
f010016f:	89 c2                	mov    %eax,%edx
f0100171:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100174:	75 cd                	jne    f0100143 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100176:	83 c4 04             	add    $0x4,%esp
f0100179:	5b                   	pop    %ebx
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <kbd_proc_data>:
f010017c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100181:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100182:	a8 01                	test   $0x1,%al
f0100184:	0f 84 f0 00 00 00    	je     f010027a <kbd_proc_data+0xfe>
f010018a:	b2 60                	mov    $0x60,%dl
f010018c:	ec                   	in     (%dx),%al
f010018d:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010018f:	3c e0                	cmp    $0xe0,%al
f0100191:	75 0d                	jne    f01001a0 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100193:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f010019a:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010019f:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
f01001a3:	53                   	push   %ebx
f01001a4:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001a7:	84 c0                	test   %al,%al
f01001a9:	79 36                	jns    f01001e1 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ab:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001b1:	89 cb                	mov    %ecx,%ebx
f01001b3:	83 e3 40             	and    $0x40,%ebx
f01001b6:	83 e0 7f             	and    $0x7f,%eax
f01001b9:	85 db                	test   %ebx,%ebx
f01001bb:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001be:	0f b6 d2             	movzbl %dl,%edx
f01001c1:	0f b6 82 80 39 10 f0 	movzbl -0xfefc680(%edx),%eax
f01001c8:	83 c8 40             	or     $0x40,%eax
f01001cb:	0f b6 c0             	movzbl %al,%eax
f01001ce:	f7 d0                	not    %eax
f01001d0:	21 c8                	and    %ecx,%eax
f01001d2:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f01001d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001dc:	e9 a1 00 00 00       	jmp    f0100282 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e1:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001e7:	f6 c1 40             	test   $0x40,%cl
f01001ea:	74 0e                	je     f01001fa <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ec:	83 c8 80             	or     $0xffffff80,%eax
f01001ef:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f1:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f4:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f01001fa:	0f b6 c2             	movzbl %dl,%eax
f01001fd:	0f b6 90 80 39 10 f0 	movzbl -0xfefc680(%eax),%edx
f0100204:	0b 15 00 73 11 f0    	or     0xf0117300,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 88 80 38 10 f0 	movzbl -0xfefc780(%eax),%ecx
f0100211:	31 ca                	xor    %ecx,%edx
f0100213:	89 15 00 73 11 f0    	mov    %edx,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100219:	89 d1                	mov    %edx,%ecx
f010021b:	83 e1 03             	and    $0x3,%ecx
f010021e:	8b 0c 8d 40 38 10 f0 	mov    -0xfefc7c0(,%ecx,4),%ecx
f0100225:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100229:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010022c:	f6 c2 08             	test   $0x8,%dl
f010022f:	74 1b                	je     f010024c <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100231:	89 d8                	mov    %ebx,%eax
f0100233:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100236:	83 f9 19             	cmp    $0x19,%ecx
f0100239:	77 05                	ja     f0100240 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f010023b:	83 eb 20             	sub    $0x20,%ebx
f010023e:	eb 0c                	jmp    f010024c <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100240:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f0100243:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100246:	83 f8 19             	cmp    $0x19,%eax
f0100249:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100252:	75 2c                	jne    f0100280 <kbd_proc_data+0x104>
f0100254:	f7 d2                	not    %edx
f0100256:	f6 c2 06             	test   $0x6,%dl
f0100259:	75 25                	jne    f0100280 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025b:	83 ec 0c             	sub    $0xc,%esp
f010025e:	68 0d 38 10 f0       	push   $0xf010380d
f0100263:	e8 94 25 00 00       	call   f01027fc <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100268:	ba 92 00 00 00       	mov    $0x92,%edx
f010026d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100272:	ee                   	out    %al,(%dx)
f0100273:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100276:	89 d8                	mov    %ebx,%eax
f0100278:	eb 08                	jmp    f0100282 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010027f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
}
f0100282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100285:	c9                   	leave  
f0100286:	c3                   	ret    

f0100287 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100287:	55                   	push   %ebp
f0100288:	89 e5                	mov    %esp,%ebp
f010028a:	57                   	push   %edi
f010028b:	56                   	push   %esi
f010028c:	53                   	push   %ebx
f010028d:	83 ec 1c             	sub    $0x1c,%esp
f0100290:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100292:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100297:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029c:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a1:	eb 09                	jmp    f01002ac <cons_putc+0x25>
f01002a3:	89 ca                	mov    %ecx,%edx
f01002a5:	ec                   	in     (%dx),%al
f01002a6:	ec                   	in     (%dx),%al
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002a9:	83 c3 01             	add    $0x1,%ebx
f01002ac:	89 f2                	mov    %esi,%edx
f01002ae:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002af:	a8 20                	test   $0x20,%al
f01002b1:	75 08                	jne    f01002bb <cons_putc+0x34>
f01002b3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002b9:	7e e8                	jle    f01002a3 <cons_putc+0x1c>
f01002bb:	89 f8                	mov    %edi,%eax
f01002bd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c5:	89 f8                	mov    %edi,%eax
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x5b>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	84 c0                	test   %al,%al
f01002e7:	78 08                	js     f01002f1 <cons_putc+0x6a>
f01002e9:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ef:	7e e8                	jle    f01002d9 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	b2 7a                	mov    $0x7a,%dl
f01002fd:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100302:	ee                   	out    %al,(%dx)
f0100303:	b8 08 00 00 00       	mov    $0x8,%eax
f0100308:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100309:	89 fa                	mov    %edi,%edx
f010030b:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100311:	89 f8                	mov    %edi,%eax
f0100313:	80 cc 07             	or     $0x7,%ah
f0100316:	85 d2                	test   %edx,%edx
f0100318:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031b:	89 f8                	mov    %edi,%eax
f010031d:	0f b6 c0             	movzbl %al,%eax
f0100320:	83 f8 09             	cmp    $0x9,%eax
f0100323:	74 74                	je     f0100399 <cons_putc+0x112>
f0100325:	83 f8 09             	cmp    $0x9,%eax
f0100328:	7f 0a                	jg     f0100334 <cons_putc+0xad>
f010032a:	83 f8 08             	cmp    $0x8,%eax
f010032d:	74 14                	je     f0100343 <cons_putc+0xbc>
f010032f:	e9 99 00 00 00       	jmp    f01003cd <cons_putc+0x146>
f0100334:	83 f8 0a             	cmp    $0xa,%eax
f0100337:	74 3a                	je     f0100373 <cons_putc+0xec>
f0100339:	83 f8 0d             	cmp    $0xd,%eax
f010033c:	74 3d                	je     f010037b <cons_putc+0xf4>
f010033e:	e9 8a 00 00 00       	jmp    f01003cd <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f0100343:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f010034a:	66 85 c0             	test   %ax,%ax
f010034d:	0f 84 e6 00 00 00    	je     f0100439 <cons_putc+0x1b2>
			crt_pos--;
f0100353:	83 e8 01             	sub    $0x1,%eax
f0100356:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010035c:	0f b7 c0             	movzwl %ax,%eax
f010035f:	66 81 e7 00 ff       	and    $0xff00,%di
f0100364:	83 cf 20             	or     $0x20,%edi
f0100367:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f010036d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100371:	eb 78                	jmp    f01003eb <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100373:	66 83 05 48 75 11 f0 	addw   $0x50,0xf0117548
f010037a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010037b:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f0100382:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100388:	c1 e8 16             	shr    $0x16,%eax
f010038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010038e:	c1 e0 04             	shl    $0x4,%eax
f0100391:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
f0100397:	eb 52                	jmp    f01003eb <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f0100399:	b8 20 00 00 00       	mov    $0x20,%eax
f010039e:	e8 e4 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a8:	e8 da fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003ad:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b2:	e8 d0 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bc:	e8 c6 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003c1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c6:	e8 bc fe ff ff       	call   f0100287 <cons_putc>
f01003cb:	eb 1e                	jmp    f01003eb <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003cd:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f01003d4:	8d 50 01             	lea    0x1(%eax),%edx
f01003d7:	66 89 15 48 75 11 f0 	mov    %dx,0xf0117548
f01003de:	0f b7 c0             	movzwl %ax,%eax
f01003e1:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f01003e7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003eb:	66 81 3d 48 75 11 f0 	cmpw   $0x7cf,0xf0117548
f01003f2:	cf 07 
f01003f4:	76 43                	jbe    f0100439 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f6:	a1 4c 75 11 f0       	mov    0xf011754c,%eax
f01003fb:	83 ec 04             	sub    $0x4,%esp
f01003fe:	68 00 0f 00 00       	push   $0xf00
f0100403:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100409:	52                   	push   %edx
f010040a:	50                   	push   %eax
f010040b:	e8 25 2f 00 00       	call   f0103335 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100410:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f0100416:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041c:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100422:	83 c4 10             	add    $0x10,%esp
f0100425:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010042a:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010042d:	39 d0                	cmp    %edx,%eax
f010042f:	75 f4                	jne    f0100425 <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100431:	66 83 2d 48 75 11 f0 	subw   $0x50,0xf0117548
f0100438:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100439:	8b 0d 50 75 11 f0    	mov    0xf0117550,%ecx
f010043f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100444:	89 ca                	mov    %ecx,%edx
f0100446:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100447:	0f b7 1d 48 75 11 f0 	movzwl 0xf0117548,%ebx
f010044e:	8d 71 01             	lea    0x1(%ecx),%esi
f0100451:	89 d8                	mov    %ebx,%eax
f0100453:	66 c1 e8 08          	shr    $0x8,%ax
f0100457:	89 f2                	mov    %esi,%edx
f0100459:	ee                   	out    %al,(%dx)
f010045a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010045f:	89 ca                	mov    %ecx,%edx
f0100461:	ee                   	out    %al,(%dx)
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	89 f2                	mov    %esi,%edx
f0100466:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100467:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046a:	5b                   	pop    %ebx
f010046b:	5e                   	pop    %esi
f010046c:	5f                   	pop    %edi
f010046d:	5d                   	pop    %ebp
f010046e:	c3                   	ret    

f010046f <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010046f:	80 3d 54 75 11 f0 00 	cmpb   $0x0,0xf0117554
f0100476:	74 11                	je     f0100489 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100478:	55                   	push   %ebp
f0100479:	89 e5                	mov    %esp,%ebp
f010047b:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010047e:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100483:	e8 b0 fc ff ff       	call   f0100138 <cons_intr>
}
f0100488:	c9                   	leave  
f0100489:	f3 c3                	repz ret 

f010048b <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048b:	55                   	push   %ebp
f010048c:	89 e5                	mov    %esp,%ebp
f010048e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100491:	b8 7c 01 10 f0       	mov    $0xf010017c,%eax
f0100496:	e8 9d fc ff ff       	call   f0100138 <cons_intr>
}
f010049b:	c9                   	leave  
f010049c:	c3                   	ret    

f010049d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010049d:	55                   	push   %ebp
f010049e:	89 e5                	mov    %esp,%ebp
f01004a0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a3:	e8 c7 ff ff ff       	call   f010046f <serial_intr>
	kbd_intr();
f01004a8:	e8 de ff ff ff       	call   f010048b <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ad:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f01004b2:	3b 05 44 75 11 f0    	cmp    0xf0117544,%eax
f01004b8:	74 26                	je     f01004e0 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004ba:	8d 50 01             	lea    0x1(%eax),%edx
f01004bd:	89 15 40 75 11 f0    	mov    %edx,0xf0117540
f01004c3:	0f b6 88 40 73 11 f0 	movzbl -0xfee8cc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004ca:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004cc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004d2:	75 11                	jne    f01004e5 <cons_getc+0x48>
			cons.rpos = 0;
f01004d4:	c7 05 40 75 11 f0 00 	movl   $0x0,0xf0117540
f01004db:	00 00 00 
f01004de:	eb 05                	jmp    f01004e5 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e5:	c9                   	leave  
f01004e6:	c3                   	ret    

f01004e7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004e7:	55                   	push   %ebp
f01004e8:	89 e5                	mov    %esp,%ebp
f01004ea:	57                   	push   %edi
f01004eb:	56                   	push   %esi
f01004ec:	53                   	push   %ebx
f01004ed:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004f7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004fe:	5a a5 
	if (*cp != 0xA55A) {
f0100500:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100507:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010050b:	74 11                	je     f010051e <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010050d:	c7 05 50 75 11 f0 b4 	movl   $0x3b4,0xf0117550
f0100514:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100517:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010051c:	eb 16                	jmp    f0100534 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010051e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100525:	c7 05 50 75 11 f0 d4 	movl   $0x3d4,0xf0117550
f010052c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010052f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100534:	8b 3d 50 75 11 f0    	mov    0xf0117550,%edi
f010053a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010053f:	89 fa                	mov    %edi,%edx
f0100541:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100542:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100545:	89 ca                	mov    %ecx,%edx
f0100547:	ec                   	in     (%dx),%al
f0100548:	0f b6 c0             	movzbl %al,%eax
f010054b:	c1 e0 08             	shl    $0x8,%eax
f010054e:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100550:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100555:	89 fa                	mov    %edi,%edx
f0100557:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100558:	89 ca                	mov    %ecx,%edx
f010055a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055b:	89 35 4c 75 11 f0    	mov    %esi,0xf011754c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100561:	0f b6 c8             	movzbl %al,%ecx
f0100564:	89 d8                	mov    %ebx,%eax
f0100566:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100568:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056e:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100573:	b8 00 00 00 00       	mov    $0x0,%eax
f0100578:	89 da                	mov    %ebx,%edx
f010057a:	ee                   	out    %al,(%dx)
f010057b:	b2 fb                	mov    $0xfb,%dl
f010057d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100582:	ee                   	out    %al,(%dx)
f0100583:	be f8 03 00 00       	mov    $0x3f8,%esi
f0100588:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058d:	89 f2                	mov    %esi,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 f9                	mov    $0xf9,%dl
f0100592:	b8 00 00 00 00       	mov    $0x0,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	b2 fb                	mov    $0xfb,%dl
f010059a:	b8 03 00 00 00       	mov    $0x3,%eax
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	b2 fc                	mov    $0xfc,%dl
f01005a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	b2 f9                	mov    $0xf9,%dl
f01005aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01005af:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b0:	b2 fd                	mov    $0xfd,%dl
f01005b2:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b3:	3c ff                	cmp    $0xff,%al
f01005b5:	0f 95 c1             	setne  %cl
f01005b8:	88 0d 54 75 11 f0    	mov    %cl,0xf0117554
f01005be:	89 da                	mov    %ebx,%edx
f01005c0:	ec                   	in     (%dx),%al
f01005c1:	89 f2                	mov    %esi,%edx
f01005c3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005c4:	84 c9                	test   %cl,%cl
f01005c6:	75 10                	jne    f01005d8 <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f01005c8:	83 ec 0c             	sub    $0xc,%esp
f01005cb:	68 19 38 10 f0       	push   $0xf0103819
f01005d0:	e8 27 22 00 00       	call   f01027fc <cprintf>
f01005d5:	83 c4 10             	add    $0x10,%esp
}
f01005d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005db:	5b                   	pop    %ebx
f01005dc:	5e                   	pop    %esi
f01005dd:	5f                   	pop    %edi
f01005de:	5d                   	pop    %ebp
f01005df:	c3                   	ret    

f01005e0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01005e9:	e8 99 fc ff ff       	call   f0100287 <cons_putc>
}
f01005ee:	c9                   	leave  
f01005ef:	c3                   	ret    

f01005f0 <getchar>:

int
getchar(void)
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005f6:	e8 a2 fe ff ff       	call   f010049d <cons_getc>
f01005fb:	85 c0                	test   %eax,%eax
f01005fd:	74 f7                	je     f01005f6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005ff:	c9                   	leave  
f0100600:	c3                   	ret    

f0100601 <iscons>:

int
iscons(int fdnum)
{
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100604:	b8 01 00 00 00       	mov    $0x1,%eax
f0100609:	5d                   	pop    %ebp
f010060a:	c3                   	ret    

f010060b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100611:	68 80 3a 10 f0       	push   $0xf0103a80
f0100616:	68 9e 3a 10 f0       	push   $0xf0103a9e
f010061b:	68 a3 3a 10 f0       	push   $0xf0103aa3
f0100620:	e8 d7 21 00 00       	call   f01027fc <cprintf>
f0100625:	83 c4 0c             	add    $0xc,%esp
f0100628:	68 50 3b 10 f0       	push   $0xf0103b50
f010062d:	68 ac 3a 10 f0       	push   $0xf0103aac
f0100632:	68 a3 3a 10 f0       	push   $0xf0103aa3
f0100637:	e8 c0 21 00 00       	call   f01027fc <cprintf>
f010063c:	83 c4 0c             	add    $0xc,%esp
f010063f:	68 b5 3a 10 f0       	push   $0xf0103ab5
f0100644:	68 c8 3a 10 f0       	push   $0xf0103ac8
f0100649:	68 a3 3a 10 f0       	push   $0xf0103aa3
f010064e:	e8 a9 21 00 00       	call   f01027fc <cprintf>
	return 0;
}
f0100653:	b8 00 00 00 00       	mov    $0x0,%eax
f0100658:	c9                   	leave  
f0100659:	c3                   	ret    

f010065a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010065a:	55                   	push   %ebp
f010065b:	89 e5                	mov    %esp,%ebp
f010065d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100660:	68 d2 3a 10 f0       	push   $0xf0103ad2
f0100665:	e8 92 21 00 00       	call   f01027fc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010066a:	83 c4 08             	add    $0x8,%esp
f010066d:	68 0c 00 10 00       	push   $0x10000c
f0100672:	68 78 3b 10 f0       	push   $0xf0103b78
f0100677:	e8 80 21 00 00       	call   f01027fc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010067c:	83 c4 0c             	add    $0xc,%esp
f010067f:	68 0c 00 10 00       	push   $0x10000c
f0100684:	68 0c 00 10 f0       	push   $0xf010000c
f0100689:	68 a0 3b 10 f0       	push   $0xf0103ba0
f010068e:	e8 69 21 00 00       	call   f01027fc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100693:	83 c4 0c             	add    $0xc,%esp
f0100696:	68 95 37 10 00       	push   $0x103795
f010069b:	68 95 37 10 f0       	push   $0xf0103795
f01006a0:	68 c4 3b 10 f0       	push   $0xf0103bc4
f01006a5:	e8 52 21 00 00       	call   f01027fc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006aa:	83 c4 0c             	add    $0xc,%esp
f01006ad:	68 00 73 11 00       	push   $0x117300
f01006b2:	68 00 73 11 f0       	push   $0xf0117300
f01006b7:	68 e8 3b 10 f0       	push   $0xf0103be8
f01006bc:	e8 3b 21 00 00       	call   f01027fc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006c1:	83 c4 0c             	add    $0xc,%esp
f01006c4:	68 90 79 11 00       	push   $0x117990
f01006c9:	68 90 79 11 f0       	push   $0xf0117990
f01006ce:	68 0c 3c 10 f0       	push   $0xf0103c0c
f01006d3:	e8 24 21 00 00       	call   f01027fc <cprintf>
f01006d8:	b8 8f 7d 11 f0       	mov    $0xf0117d8f,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006dd:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006e2:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006e5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f0:	85 c0                	test   %eax,%eax
f01006f2:	0f 48 c2             	cmovs  %edx,%eax
f01006f5:	c1 f8 0a             	sar    $0xa,%eax
f01006f8:	50                   	push   %eax
f01006f9:	68 30 3c 10 f0       	push   $0xf0103c30
f01006fe:	e8 f9 20 00 00       	call   f01027fc <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	c9                   	leave  
f0100709:	c3                   	ret    

f010070a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
f010070d:	57                   	push   %edi
f010070e:	56                   	push   %esi
f010070f:	53                   	push   %ebx
f0100710:	81 ec a8 00 00 00    	sub    $0xa8,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100716:	89 e8                	mov    %ebp,%eax
	// Your code here.
        uint32_t *ebp;
        uint32_t eip;
        uint32_t arg0, arg1, arg2, arg3, arg4;
        ebp = (uint32_t *)read_ebp();
f0100718:	89 c3                	mov    %eax,%ebx
        eip = ebp[1];
f010071a:	8b 70 04             	mov    0x4(%eax),%esi
        arg0 = ebp[2];
f010071d:	8b 50 08             	mov    0x8(%eax),%edx
f0100720:	89 d7                	mov    %edx,%edi
        arg1 = ebp[3];
f0100722:	8b 48 0c             	mov    0xc(%eax),%ecx
f0100725:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
        arg2 = ebp[4];
f010072b:	8b 50 10             	mov    0x10(%eax),%edx
f010072e:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
        arg3 = ebp[5];
f0100734:	8b 48 14             	mov    0x14(%eax),%ecx
f0100737:	89 8d 64 ff ff ff    	mov    %ecx,-0x9c(%ebp)
        arg4 = ebp[6];
f010073d:	8b 40 18             	mov    0x18(%eax),%eax
f0100740:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
        cprintf("Stack backtrace:\n");
f0100746:	68 eb 3a 10 f0       	push   $0xf0103aeb
f010074b:	e8 ac 20 00 00       	call   f01027fc <cprintf>
        while(ebp != 0) {
f0100750:	83 c4 10             	add    $0x10,%esp
f0100753:	89 f8                	mov    %edi,%eax
f0100755:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f010075b:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
f0100761:	e9 92 00 00 00       	jmp    f01007f8 <mon_backtrace+0xee>
             
             char fn[100];
              
             cprintf("  ebp  %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f0100766:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f010076c:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f0100772:	51                   	push   %ecx
f0100773:	52                   	push   %edx
f0100774:	50                   	push   %eax
f0100775:	56                   	push   %esi
f0100776:	53                   	push   %ebx
f0100777:	68 5c 3c 10 f0       	push   $0xf0103c5c
f010077c:	e8 7b 20 00 00       	call   f01027fc <cprintf>
                                       ebp, eip, arg0, arg1, arg2, arg3, arg4);
             struct Eipdebuginfo info;
             debuginfo_eip(eip, &info);
f0100781:	83 c4 18             	add    $0x18,%esp
f0100784:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010078a:	50                   	push   %eax
f010078b:	56                   	push   %esi
f010078c:	e8 81 21 00 00       	call   f0102912 <debuginfo_eip>
            
             snprintf(fn, info.eip_fn_namelen+1, "%s", info.eip_fn_name);
f0100791:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
f0100797:	68 56 3d 10 f0       	push   $0xf0103d56
f010079c:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
f01007a2:	83 c0 01             	add    $0x1,%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 45 84             	lea    -0x7c(%ebp),%eax
f01007a9:	50                   	push   %eax
f01007aa:	e8 c8 28 00 00       	call   f0103077 <snprintf>
            
             cprintf("         %s:%u: %s+%u\n", info.eip_file, info.eip_line, fn, eip - info.eip_fn_addr);
f01007af:	83 c4 14             	add    $0x14,%esp
f01007b2:	89 f0                	mov    %esi,%eax
f01007b4:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f01007ba:	50                   	push   %eax
f01007bb:	8d 45 84             	lea    -0x7c(%ebp),%eax
f01007be:	50                   	push   %eax
f01007bf:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f01007c5:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f01007cb:	68 fd 3a 10 f0       	push   $0xf0103afd
f01007d0:	e8 27 20 00 00       	call   f01027fc <cprintf>
             ebp = (uint32_t *)ebp[0];
f01007d5:	8b 1b                	mov    (%ebx),%ebx
             eip = ebp[1];
f01007d7:	8b 73 04             	mov    0x4(%ebx),%esi
             arg0 = ebp[2];
f01007da:	8b 43 08             	mov    0x8(%ebx),%eax
             arg1 = ebp[3];
f01007dd:	8b 53 0c             	mov    0xc(%ebx),%edx
             arg2 = ebp[4];
f01007e0:	8b 4b 10             	mov    0x10(%ebx),%ecx
             arg3 = ebp[5];
f01007e3:	8b 7b 14             	mov    0x14(%ebx),%edi
f01007e6:	89 bd 64 ff ff ff    	mov    %edi,-0x9c(%ebp)
             arg4 = ebp[6];
f01007ec:	8b 7b 18             	mov    0x18(%ebx),%edi
f01007ef:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f01007f5:	83 c4 20             	add    $0x20,%esp
        arg1 = ebp[3];
        arg2 = ebp[4];
        arg3 = ebp[5];
        arg4 = ebp[6];
        cprintf("Stack backtrace:\n");
        while(ebp != 0) {
f01007f8:	85 db                	test   %ebx,%ebx
f01007fa:	0f 85 66 ff ff ff    	jne    f0100766 <mon_backtrace+0x5c>
             arg2 = ebp[4];
             arg3 = ebp[5];
             arg4 = ebp[6];
        }
	return 0;
}
f0100800:	b8 00 00 00 00       	mov    $0x0,%eax
f0100805:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100808:	5b                   	pop    %ebx
f0100809:	5e                   	pop    %esi
f010080a:	5f                   	pop    %edi
f010080b:	5d                   	pop    %ebp
f010080c:	c3                   	ret    

f010080d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010080d:	55                   	push   %ebp
f010080e:	89 e5                	mov    %esp,%ebp
f0100810:	57                   	push   %edi
f0100811:	56                   	push   %esi
f0100812:	53                   	push   %ebx
f0100813:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100816:	68 94 3c 10 f0       	push   $0xf0103c94
f010081b:	e8 dc 1f 00 00       	call   f01027fc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100820:	c7 04 24 b8 3c 10 f0 	movl   $0xf0103cb8,(%esp)
f0100827:	e8 d0 1f 00 00       	call   f01027fc <cprintf>
f010082c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010082f:	83 ec 0c             	sub    $0xc,%esp
f0100832:	68 14 3b 10 f0       	push   $0xf0103b14
f0100837:	e8 55 28 00 00       	call   f0103091 <readline>
f010083c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010083e:	83 c4 10             	add    $0x10,%esp
f0100841:	85 c0                	test   %eax,%eax
f0100843:	74 ea                	je     f010082f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100845:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010084c:	be 00 00 00 00       	mov    $0x0,%esi
f0100851:	eb 0a                	jmp    f010085d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100853:	c6 03 00             	movb   $0x0,(%ebx)
f0100856:	89 f7                	mov    %esi,%edi
f0100858:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010085b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010085d:	0f b6 03             	movzbl (%ebx),%eax
f0100860:	84 c0                	test   %al,%al
f0100862:	74 63                	je     f01008c7 <monitor+0xba>
f0100864:	83 ec 08             	sub    $0x8,%esp
f0100867:	0f be c0             	movsbl %al,%eax
f010086a:	50                   	push   %eax
f010086b:	68 18 3b 10 f0       	push   $0xf0103b18
f0100870:	e8 36 2a 00 00       	call   f01032ab <strchr>
f0100875:	83 c4 10             	add    $0x10,%esp
f0100878:	85 c0                	test   %eax,%eax
f010087a:	75 d7                	jne    f0100853 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010087c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010087f:	74 46                	je     f01008c7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100881:	83 fe 0f             	cmp    $0xf,%esi
f0100884:	75 14                	jne    f010089a <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100886:	83 ec 08             	sub    $0x8,%esp
f0100889:	6a 10                	push   $0x10
f010088b:	68 1d 3b 10 f0       	push   $0xf0103b1d
f0100890:	e8 67 1f 00 00       	call   f01027fc <cprintf>
f0100895:	83 c4 10             	add    $0x10,%esp
f0100898:	eb 95                	jmp    f010082f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010089a:	8d 7e 01             	lea    0x1(%esi),%edi
f010089d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008a1:	eb 03                	jmp    f01008a6 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008a3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a6:	0f b6 03             	movzbl (%ebx),%eax
f01008a9:	84 c0                	test   %al,%al
f01008ab:	74 ae                	je     f010085b <monitor+0x4e>
f01008ad:	83 ec 08             	sub    $0x8,%esp
f01008b0:	0f be c0             	movsbl %al,%eax
f01008b3:	50                   	push   %eax
f01008b4:	68 18 3b 10 f0       	push   $0xf0103b18
f01008b9:	e8 ed 29 00 00       	call   f01032ab <strchr>
f01008be:	83 c4 10             	add    $0x10,%esp
f01008c1:	85 c0                	test   %eax,%eax
f01008c3:	74 de                	je     f01008a3 <monitor+0x96>
f01008c5:	eb 94                	jmp    f010085b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008c7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ce:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008cf:	85 f6                	test   %esi,%esi
f01008d1:	0f 84 58 ff ff ff    	je     f010082f <monitor+0x22>
f01008d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008dc:	83 ec 08             	sub    $0x8,%esp
f01008df:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e2:	ff 34 85 e0 3c 10 f0 	pushl  -0xfefc320(,%eax,4)
f01008e9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ec:	e8 5c 29 00 00       	call   f010324d <strcmp>
f01008f1:	83 c4 10             	add    $0x10,%esp
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	75 22                	jne    f010091a <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f01008f8:	83 ec 04             	sub    $0x4,%esp
f01008fb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008fe:	ff 75 08             	pushl  0x8(%ebp)
f0100901:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100904:	52                   	push   %edx
f0100905:	56                   	push   %esi
f0100906:	ff 14 85 e8 3c 10 f0 	call   *-0xfefc318(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010090d:	83 c4 10             	add    $0x10,%esp
f0100910:	85 c0                	test   %eax,%eax
f0100912:	0f 89 17 ff ff ff    	jns    f010082f <monitor+0x22>
f0100918:	eb 20                	jmp    f010093a <monitor+0x12d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010091a:	83 c3 01             	add    $0x1,%ebx
f010091d:	83 fb 03             	cmp    $0x3,%ebx
f0100920:	75 ba                	jne    f01008dc <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100922:	83 ec 08             	sub    $0x8,%esp
f0100925:	ff 75 a8             	pushl  -0x58(%ebp)
f0100928:	68 3a 3b 10 f0       	push   $0xf0103b3a
f010092d:	e8 ca 1e 00 00       	call   f01027fc <cprintf>
f0100932:	83 c4 10             	add    $0x10,%esp
f0100935:	e9 f5 fe ff ff       	jmp    f010082f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010093a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093d:	5b                   	pop    %ebx
f010093e:	5e                   	pop    %esi
f010093f:	5f                   	pop    %edi
f0100940:	5d                   	pop    %ebp
f0100941:	c3                   	ret    

f0100942 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100942:	83 3d 58 75 11 f0 00 	cmpl   $0x0,0xf0117558
f0100949:	75 11                	jne    f010095c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010094b:	ba 8f 89 11 f0       	mov    $0xf011898f,%edx
f0100950:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100956:	89 15 58 75 11 f0    	mov    %edx,0xf0117558
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
f010095c:	85 c0                	test   %eax,%eax
f010095e:	74 3d                	je     f010099d <boot_alloc+0x5b>
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100960:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx

		result = nextfree;
f0100966:	a1 58 75 11 f0       	mov    0xf0117558,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f010096b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		result = nextfree;
		nextfree += alloc_size;
f0100971:	01 c2                	add    %eax,%edx
f0100973:	89 15 58 75 11 f0    	mov    %edx,0xf0117558

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
f0100979:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f010097f:	76 21                	jbe    f01009a2 <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100981:	55                   	push   %ebp
f0100982:	89 e5                	mov    %esp,%ebp
f0100984:	83 ec 0c             	sub    $0xc,%esp

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
f0100987:	a3 58 75 11 f0       	mov    %eax,0xf0117558
                     result = NULL;
                     panic("boot_alloc: out of memory");
f010098c:	68 04 3d 10 f0       	push   $0xf0103d04
f0100991:	6a 72                	push   $0x72
f0100993:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100998:	e8 ee f6 ff ff       	call   f010008b <_panic>
                }

        
	} else {
		result = nextfree;
f010099d:	a1 58 75 11 f0       	mov    0xf0117558,%eax
	}
	return result;
	
}
f01009a2:	f3 c3                	repz ret 

f01009a4 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009a4:	89 d1                	mov    %edx,%ecx
f01009a6:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009a9:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009ac:	a8 01                	test   $0x1,%al
f01009ae:	74 52                	je     f0100a02 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009b5:	89 c1                	mov    %eax,%ecx
f01009b7:	c1 e9 0c             	shr    $0xc,%ecx
f01009ba:	3b 0d 84 79 11 f0    	cmp    0xf0117984,%ecx
f01009c0:	72 1b                	jb     f01009dd <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009c2:	55                   	push   %ebp
f01009c3:	89 e5                	mov    %esp,%ebp
f01009c5:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009c8:	50                   	push   %eax
f01009c9:	68 38 40 10 f0       	push   $0xf0104038
f01009ce:	68 f4 02 00 00       	push   $0x2f4
f01009d3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01009d8:	e8 ae f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009dd:	c1 ea 0c             	shr    $0xc,%edx
f01009e0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009e6:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009ed:	89 c2                	mov    %eax,%edx
f01009ef:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009f7:	85 d2                	test   %edx,%edx
f01009f9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009fe:	0f 44 c2             	cmove  %edx,%eax
f0100a01:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a07:	c3                   	ret    

f0100a08 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	57                   	push   %edi
f0100a0c:	56                   	push   %esi
f0100a0d:	53                   	push   %ebx
f0100a0e:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a11:	84 c0                	test   %al,%al
f0100a13:	0f 85 7a 02 00 00    	jne    f0100c93 <check_page_free_list+0x28b>
f0100a19:	e9 87 02 00 00       	jmp    f0100ca5 <check_page_free_list+0x29d>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a1e:	83 ec 04             	sub    $0x4,%esp
f0100a21:	68 5c 40 10 f0       	push   $0xf010405c
f0100a26:	68 37 02 00 00       	push   $0x237
f0100a2b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100a30:	e8 56 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a35:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a38:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a3b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a41:	89 c2                	mov    %eax,%edx
f0100a43:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a49:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a4f:	0f 95 c2             	setne  %dl
f0100a52:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a55:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a59:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a5b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a5f:	8b 00                	mov    (%eax),%eax
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	75 dc                	jne    f0100a41 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a71:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a74:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a76:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a79:	a3 5c 75 11 f0       	mov    %eax,0xf011755c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a7e:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a83:	8b 1d 5c 75 11 f0    	mov    0xf011755c,%ebx
f0100a89:	eb 53                	jmp    f0100ade <check_page_free_list+0xd6>
f0100a8b:	89 d8                	mov    %ebx,%eax
f0100a8d:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100a93:	c1 f8 03             	sar    $0x3,%eax
f0100a96:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a99:	89 c2                	mov    %eax,%edx
f0100a9b:	c1 ea 16             	shr    $0x16,%edx
f0100a9e:	39 f2                	cmp    %esi,%edx
f0100aa0:	73 3a                	jae    f0100adc <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aa2:	89 c2                	mov    %eax,%edx
f0100aa4:	c1 ea 0c             	shr    $0xc,%edx
f0100aa7:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100aad:	72 12                	jb     f0100ac1 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aaf:	50                   	push   %eax
f0100ab0:	68 38 40 10 f0       	push   $0xf0104038
f0100ab5:	6a 52                	push   $0x52
f0100ab7:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0100abc:	e8 ca f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ac1:	83 ec 04             	sub    $0x4,%esp
f0100ac4:	68 80 00 00 00       	push   $0x80
f0100ac9:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ace:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ad3:	50                   	push   %eax
f0100ad4:	e8 0f 28 00 00       	call   f01032e8 <memset>
f0100ad9:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100adc:	8b 1b                	mov    (%ebx),%ebx
f0100ade:	85 db                	test   %ebx,%ebx
f0100ae0:	75 a9                	jne    f0100a8b <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ae2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae7:	e8 56 fe ff ff       	call   f0100942 <boot_alloc>
f0100aec:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aef:	8b 15 5c 75 11 f0    	mov    0xf011755c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100af5:	8b 0d 8c 79 11 f0    	mov    0xf011798c,%ecx
		assert(pp < pages + npages);
f0100afb:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f0100b00:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b03:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b06:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b09:	be 00 00 00 00       	mov    $0x0,%esi
f0100b0e:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b13:	89 75 cc             	mov    %esi,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b16:	e9 33 01 00 00       	jmp    f0100c4e <check_page_free_list+0x246>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b1b:	39 ca                	cmp    %ecx,%edx
f0100b1d:	73 19                	jae    f0100b38 <check_page_free_list+0x130>
f0100b1f:	68 38 3d 10 f0       	push   $0xf0103d38
f0100b24:	68 44 3d 10 f0       	push   $0xf0103d44
f0100b29:	68 51 02 00 00       	push   $0x251
f0100b2e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100b33:	e8 53 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b38:	39 da                	cmp    %ebx,%edx
f0100b3a:	72 19                	jb     f0100b55 <check_page_free_list+0x14d>
f0100b3c:	68 59 3d 10 f0       	push   $0xf0103d59
f0100b41:	68 44 3d 10 f0       	push   $0xf0103d44
f0100b46:	68 52 02 00 00       	push   $0x252
f0100b4b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100b50:	e8 36 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b55:	89 d0                	mov    %edx,%eax
f0100b57:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b5a:	a8 07                	test   $0x7,%al
f0100b5c:	74 19                	je     f0100b77 <check_page_free_list+0x16f>
f0100b5e:	68 80 40 10 f0       	push   $0xf0104080
f0100b63:	68 44 3d 10 f0       	push   $0xf0103d44
f0100b68:	68 53 02 00 00       	push   $0x253
f0100b6d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100b72:	e8 14 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b77:	c1 f8 03             	sar    $0x3,%eax
f0100b7a:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b7d:	85 c0                	test   %eax,%eax
f0100b7f:	75 19                	jne    f0100b9a <check_page_free_list+0x192>
f0100b81:	68 6d 3d 10 f0       	push   $0xf0103d6d
f0100b86:	68 44 3d 10 f0       	push   $0xf0103d44
f0100b8b:	68 56 02 00 00       	push   $0x256
f0100b90:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100b95:	e8 f1 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b9a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b9f:	75 19                	jne    f0100bba <check_page_free_list+0x1b2>
f0100ba1:	68 7e 3d 10 f0       	push   $0xf0103d7e
f0100ba6:	68 44 3d 10 f0       	push   $0xf0103d44
f0100bab:	68 57 02 00 00       	push   $0x257
f0100bb0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100bb5:	e8 d1 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bba:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bbf:	75 19                	jne    f0100bda <check_page_free_list+0x1d2>
f0100bc1:	68 b4 40 10 f0       	push   $0xf01040b4
f0100bc6:	68 44 3d 10 f0       	push   $0xf0103d44
f0100bcb:	68 58 02 00 00       	push   $0x258
f0100bd0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100bd5:	e8 b1 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bda:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bdf:	75 19                	jne    f0100bfa <check_page_free_list+0x1f2>
f0100be1:	68 97 3d 10 f0       	push   $0xf0103d97
f0100be6:	68 44 3d 10 f0       	push   $0xf0103d44
f0100beb:	68 59 02 00 00       	push   $0x259
f0100bf0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100bf5:	e8 91 f4 ff ff       	call   f010008b <_panic>
f0100bfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bfd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c02:	76 3f                	jbe    f0100c43 <check_page_free_list+0x23b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c04:	89 c6                	mov    %eax,%esi
f0100c06:	c1 ee 0c             	shr    $0xc,%esi
f0100c09:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100c0c:	77 12                	ja     f0100c20 <check_page_free_list+0x218>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c0e:	50                   	push   %eax
f0100c0f:	68 38 40 10 f0       	push   $0xf0104038
f0100c14:	6a 52                	push   $0x52
f0100c16:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0100c1b:	e8 6b f4 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100c20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c25:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c28:	76 1e                	jbe    f0100c48 <check_page_free_list+0x240>
f0100c2a:	68 d8 40 10 f0       	push   $0xf01040d8
f0100c2f:	68 44 3d 10 f0       	push   $0xf0103d44
f0100c34:	68 5a 02 00 00       	push   $0x25a
f0100c39:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100c3e:	e8 48 f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c43:	83 c7 01             	add    $0x1,%edi
f0100c46:	eb 04                	jmp    f0100c4c <check_page_free_list+0x244>
		else
			++nfree_extmem;
f0100c48:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c4c:	8b 12                	mov    (%edx),%edx
f0100c4e:	85 d2                	test   %edx,%edx
f0100c50:	0f 85 c5 fe ff ff    	jne    f0100b1b <check_page_free_list+0x113>
f0100c56:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c59:	85 ff                	test   %edi,%edi
f0100c5b:	7f 19                	jg     f0100c76 <check_page_free_list+0x26e>
f0100c5d:	68 b1 3d 10 f0       	push   $0xf0103db1
f0100c62:	68 44 3d 10 f0       	push   $0xf0103d44
f0100c67:	68 62 02 00 00       	push   $0x262
f0100c6c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100c71:	e8 15 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c76:	85 f6                	test   %esi,%esi
f0100c78:	7f 42                	jg     f0100cbc <check_page_free_list+0x2b4>
f0100c7a:	68 c3 3d 10 f0       	push   $0xf0103dc3
f0100c7f:	68 44 3d 10 f0       	push   $0xf0103d44
f0100c84:	68 63 02 00 00       	push   $0x263
f0100c89:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100c8e:	e8 f8 f3 ff ff       	call   f010008b <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c93:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0100c98:	85 c0                	test   %eax,%eax
f0100c9a:	0f 85 95 fd ff ff    	jne    f0100a35 <check_page_free_list+0x2d>
f0100ca0:	e9 79 fd ff ff       	jmp    f0100a1e <check_page_free_list+0x16>
f0100ca5:	83 3d 5c 75 11 f0 00 	cmpl   $0x0,0xf011755c
f0100cac:	0f 84 6c fd ff ff    	je     f0100a1e <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cb2:	be 00 04 00 00       	mov    $0x400,%esi
f0100cb7:	e9 c7 fd ff ff       	jmp    f0100a83 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cbf:	5b                   	pop    %ebx
f0100cc0:	5e                   	pop    %esi
f0100cc1:	5f                   	pop    %edi
f0100cc2:	5d                   	pop    %ebp
f0100cc3:	c3                   	ret    

f0100cc4 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cc4:	55                   	push   %ebp
f0100cc5:	89 e5                	mov    %esp,%ebp
f0100cc7:	56                   	push   %esi
f0100cc8:	53                   	push   %ebx
f0100cc9:	8b 1d 5c 75 11 f0    	mov    0xf011755c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ccf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cd4:	eb 22                	jmp    f0100cf8 <page_init+0x34>
f0100cd6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100cdd:	89 d1                	mov    %edx,%ecx
f0100cdf:	03 0d 8c 79 11 f0    	add    0xf011798c,%ecx
f0100ce5:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ceb:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ced:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100cf0:	89 d3                	mov    %edx,%ebx
f0100cf2:	03 1d 8c 79 11 f0    	add    0xf011798c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100cf8:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0100cfe:	72 d6                	jb     f0100cd6 <page_init+0x12>
f0100d00:	89 1d 5c 75 11 f0    	mov    %ebx,0xf011755c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
        pages[0].pp_ref = 1;
f0100d06:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0100d0b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
  
        pages[1].pp_link = pages[0].pp_link;
f0100d11:	8b 10                	mov    (%eax),%edx
f0100d13:	89 50 08             	mov    %edx,0x8(%eax)
        //potential problem?
        uint32_t nextfreepa = PADDR(boot_alloc(0)); 
f0100d16:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d1b:	e8 22 fc ff ff       	call   f0100942 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d20:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d25:	77 15                	ja     f0100d3c <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d27:	50                   	push   %eax
f0100d28:	68 20 41 10 f0       	push   $0xf0104120
f0100d2d:	68 19 01 00 00       	push   $0x119
f0100d32:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100d37:	e8 4f f3 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d3c:	05 00 00 00 10       	add    $0x10000000,%eax
        
        void *p = pages[IOPHYSMEM/PGSIZE].pp_link;
f0100d41:	8b 15 8c 79 11 f0    	mov    0xf011798c,%edx
f0100d47:	8b b2 00 05 00 00    	mov    0x500(%edx),%esi
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100d4d:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0100d52:	eb 20                	jmp    f0100d74 <page_init+0xb0>
              pages[i/PGSIZE].pp_ref = 1;  
f0100d54:	89 d3                	mov    %edx,%ebx
f0100d56:	c1 eb 0c             	shr    $0xc,%ebx
f0100d59:	8b 0d 8c 79 11 f0    	mov    0xf011798c,%ecx
f0100d5f:	8d 0c d9             	lea    (%ecx,%ebx,8),%ecx
f0100d62:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
              pages[i/PGSIZE].pp_link = NULL;     
f0100d68:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
        pages[1].pp_link = pages[0].pp_link;
        //potential problem?
        uint32_t nextfreepa = PADDR(boot_alloc(0)); 
        
        void *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
f0100d6e:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100d74:	39 c2                	cmp    %eax,%edx
f0100d76:	72 dc                	jb     f0100d54 <page_init+0x90>
              pages[i/PGSIZE].pp_ref = 1;  
              pages[i/PGSIZE].pp_link = NULL;     
        }      
        pages[i/PGSIZE].pp_link = p;
f0100d78:	c1 ea 0c             	shr    $0xc,%edx
f0100d7b:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0100d80:	89 34 d0             	mov    %esi,(%eax,%edx,8)
}
f0100d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d86:	5b                   	pop    %ebx
f0100d87:	5e                   	pop    %esi
f0100d88:	5d                   	pop    %ebp
f0100d89:	c3                   	ret    

f0100d8a <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
       if ( page_free_list ) {
f0100d8a:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0100d8f:	85 c0                	test   %eax,%eax
f0100d91:	74 63                	je     f0100df6 <page_alloc+0x6c>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in
       if ( page_free_list ) {
            if(alloc_flags & ALLOC_ZERO) 
f0100d99:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d9d:	74 43                	je     f0100de2 <page_alloc+0x58>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d9f:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100da5:	c1 f8 03             	sar    $0x3,%eax
f0100da8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dab:	89 c2                	mov    %eax,%edx
f0100dad:	c1 ea 0c             	shr    $0xc,%edx
f0100db0:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100db6:	72 12                	jb     f0100dca <page_alloc+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100db8:	50                   	push   %eax
f0100db9:	68 38 40 10 f0       	push   $0xf0104038
f0100dbe:	6a 52                	push   $0x52
f0100dc0:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0100dc5:	e8 c1 f2 ff ff       	call   f010008b <_panic>
                memset(page2kva(page_free_list), 0, PGSIZE);
f0100dca:	83 ec 04             	sub    $0x4,%esp
f0100dcd:	68 00 10 00 00       	push   $0x1000
f0100dd2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100dd4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dd9:	50                   	push   %eax
f0100dda:	e8 09 25 00 00       	call   f01032e8 <memset>
f0100ddf:	83 c4 10             	add    $0x10,%esp
               
                struct PageInfo *tmp = page_free_list;
f0100de2:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
                 
                page_free_list = page_free_list->pp_link;
f0100de7:	8b 10                	mov    (%eax),%edx
f0100de9:	89 15 5c 75 11 f0    	mov    %edx,0xf011755c
                tmp->pp_link = NULL;
f0100def:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                      
                return tmp; 
            
        }
	return NULL;
}
f0100df5:	c9                   	leave  
f0100df6:	f3 c3                	repz ret 

f0100df8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100df8:	55                   	push   %ebp
f0100df9:	89 e5                	mov    %esp,%ebp
f0100dfb:	83 ec 08             	sub    $0x8,%esp
f0100dfe:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.    
        if(pp == NULL) return;
f0100e01:	85 c0                	test   %eax,%eax
f0100e03:	74 30                	je     f0100e35 <page_free+0x3d>
        if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100e05:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e0a:	75 05                	jne    f0100e11 <page_free+0x19>
f0100e0c:	83 38 00             	cmpl   $0x0,(%eax)
f0100e0f:	74 17                	je     f0100e28 <page_free+0x30>
            panic("page_free: invalid page free\n");
f0100e11:	83 ec 04             	sub    $0x4,%esp
f0100e14:	68 d4 3d 10 f0       	push   $0xf0103dd4
f0100e19:	68 4e 01 00 00       	push   $0x14e
f0100e1e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100e23:	e8 63 f2 ff ff       	call   f010008b <_panic>
        else {
            pp->pp_link = page_free_list;
f0100e28:	8b 15 5c 75 11 f0    	mov    0xf011755c,%edx
f0100e2e:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f0100e30:	a3 5c 75 11 f0       	mov    %eax,0xf011755c
        }
}
f0100e35:	c9                   	leave  
f0100e36:	c3                   	ret    

f0100e37 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e37:	55                   	push   %ebp
f0100e38:	89 e5                	mov    %esp,%ebp
f0100e3a:	83 ec 08             	sub    $0x8,%esp
f0100e3d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e40:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e44:	83 e8 01             	sub    $0x1,%eax
f0100e47:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e4b:	66 85 c0             	test   %ax,%ax
f0100e4e:	75 0c                	jne    f0100e5c <page_decref+0x25>
		page_free(pp);
f0100e50:	83 ec 0c             	sub    $0xc,%esp
f0100e53:	52                   	push   %edx
f0100e54:	e8 9f ff ff ff       	call   f0100df8 <page_free>
f0100e59:	83 c4 10             	add    $0x10,%esp
}
f0100e5c:	c9                   	leave  
f0100e5d:	c3                   	ret    

f0100e5e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e5e:	55                   	push   %ebp
f0100e5f:	89 e5                	mov    %esp,%ebp
f0100e61:	56                   	push   %esi
f0100e62:	53                   	push   %ebx
f0100e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t * pte;
        if ((pgdir[PDX(va)] & PTE_P) != 0) {
f0100e66:	89 de                	mov    %ebx,%esi
f0100e68:	c1 ee 16             	shr    $0x16,%esi
f0100e6b:	c1 e6 02             	shl    $0x2,%esi
f0100e6e:	03 75 08             	add    0x8(%ebp),%esi
f0100e71:	8b 06                	mov    (%esi),%eax
f0100e73:	a8 01                	test   $0x1,%al
f0100e75:	74 3c                	je     f0100eb3 <pgdir_walk+0x55>
                pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100e77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e7c:	89 c2                	mov    %eax,%edx
f0100e7e:	c1 ea 0c             	shr    $0xc,%edx
f0100e81:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100e87:	72 15                	jb     f0100e9e <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e89:	50                   	push   %eax
f0100e8a:	68 38 40 10 f0       	push   $0xf0104038
f0100e8f:	68 7c 01 00 00       	push   $0x17c
f0100e94:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100e99:	e8 ed f1 ff ff       	call   f010008b <_panic>
                return pte + PTX(va);  
f0100e9e:	c1 eb 0a             	shr    $0xa,%ebx
f0100ea1:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100ea7:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100eae:	e9 81 00 00 00       	jmp    f0100f34 <pgdir_walk+0xd6>

 
        } 
        
        if(create != 0) {
f0100eb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100eb7:	74 6f                	je     f0100f28 <pgdir_walk+0xca>
               struct PageInfo *tmp;
               tmp = page_alloc(1);
f0100eb9:	83 ec 0c             	sub    $0xc,%esp
f0100ebc:	6a 01                	push   $0x1
f0100ebe:	e8 c7 fe ff ff       	call   f0100d8a <page_alloc>
       
               if(tmp != NULL) {
f0100ec3:	83 c4 10             	add    $0x10,%esp
f0100ec6:	85 c0                	test   %eax,%eax
f0100ec8:	74 65                	je     f0100f2f <pgdir_walk+0xd1>
                       
                        
                       tmp->pp_ref += 1;
f0100eca:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
                       tmp->pp_link = NULL;
f0100ecf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ed5:	89 c2                	mov    %eax,%edx
f0100ed7:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0100edd:	c1 fa 03             	sar    $0x3,%edx
f0100ee0:	c1 e2 0c             	shl    $0xc,%edx
                       pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
f0100ee3:	83 ca 07             	or     $0x7,%edx
f0100ee6:	89 16                	mov    %edx,(%esi)
f0100ee8:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100eee:	c1 f8 03             	sar    $0x3,%eax
f0100ef1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ef4:	89 c2                	mov    %eax,%edx
f0100ef6:	c1 ea 0c             	shr    $0xc,%edx
f0100ef9:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100eff:	72 15                	jb     f0100f16 <pgdir_walk+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f01:	50                   	push   %eax
f0100f02:	68 38 40 10 f0       	push   $0xf0104038
f0100f07:	68 8c 01 00 00       	push   $0x18c
f0100f0c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100f11:	e8 75 f1 ff ff       	call   f010008b <_panic>
                       pte = (pte_t *)KADDR(page2pa(tmp));
                  
                       return pte+PTX(va); 
f0100f16:	c1 eb 0a             	shr    $0xa,%ebx
f0100f19:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f1f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f26:	eb 0c                	jmp    f0100f34 <pgdir_walk+0xd6>

               }
               
        }

	return NULL;
f0100f28:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2d:	eb 05                	jmp    f0100f34 <pgdir_walk+0xd6>
f0100f2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f34:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f37:	5b                   	pop    %ebx
f0100f38:	5e                   	pop    %esi
f0100f39:	5d                   	pop    %ebp
f0100f3a:	c3                   	ret    

f0100f3b <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f3b:	55                   	push   %ebp
f0100f3c:	89 e5                	mov    %esp,%ebp
f0100f3e:	57                   	push   %edi
f0100f3f:	56                   	push   %esi
f0100f40:	53                   	push   %ebx
f0100f41:	83 ec 1c             	sub    $0x1c,%esp
f0100f44:	89 c7                	mov    %eax,%edi
f0100f46:	89 55 e0             	mov    %edx,-0x20(%ebp)
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
f0100f49:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100f4f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0100f58:	be 00 00 00 00       	mov    $0x0,%esi
f0100f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f60:	83 c8 01             	or     $0x1,%eax
f0100f63:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f66:	eb 3d                	jmp    f0100fa5 <boot_map_region+0x6a>
              tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
f0100f68:	83 ec 04             	sub    $0x4,%esp
f0100f6b:	6a 01                	push   $0x1
f0100f6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f70:	01 f0                	add    %esi,%eax
f0100f72:	50                   	push   %eax
f0100f73:	57                   	push   %edi
f0100f74:	e8 e5 fe ff ff       	call   f0100e5e <pgdir_walk>
              if ( tmp == NULL ) {
f0100f79:	83 c4 10             	add    $0x10,%esp
f0100f7c:	85 c0                	test   %eax,%eax
f0100f7e:	75 17                	jne    f0100f97 <boot_map_region+0x5c>
                     panic("boot_map_region: fail\n");
f0100f80:	83 ec 04             	sub    $0x4,%esp
f0100f83:	68 f2 3d 10 f0       	push   $0xf0103df2
f0100f88:	68 ac 01 00 00       	push   $0x1ac
f0100f8d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100f92:	e8 f4 f0 ff ff       	call   f010008b <_panic>
f0100f97:	03 5d 08             	add    0x8(%ebp),%ebx
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
f0100f9a:	0b 5d dc             	or     -0x24(%ebp),%ebx
f0100f9d:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
        size = ROUNDUP(size, PGSIZE);
        pte_t *tmp;
        int i ;
        for( i = 0; i < size; i += PGSIZE) { 
f0100f9f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100fa5:	89 f3                	mov    %esi,%ebx
f0100fa7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0100faa:	77 bc                	ja     f0100f68 <boot_map_region+0x2d>
                     return;
              }
              *tmp = (pa + i) | perm | PTE_P; 
 
        }
}
f0100fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100faf:	5b                   	pop    %ebx
f0100fb0:	5e                   	pop    %esi
f0100fb1:	5f                   	pop    %edi
f0100fb2:	5d                   	pop    %ebp
f0100fb3:	c3                   	ret    

f0100fb4 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fb4:	55                   	push   %ebp
f0100fb5:	89 e5                	mov    %esp,%ebp
f0100fb7:	53                   	push   %ebx
f0100fb8:	83 ec 08             	sub    $0x8,%esp
f0100fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 0);
f0100fbe:	6a 00                	push   $0x0
f0100fc0:	ff 75 0c             	pushl  0xc(%ebp)
f0100fc3:	ff 75 08             	pushl  0x8(%ebp)
f0100fc6:	e8 93 fe ff ff       	call   f0100e5e <pgdir_walk>
        if ( tmp != NULL && (*tmp & PTE_P)) {
f0100fcb:	83 c4 10             	add    $0x10,%esp
f0100fce:	85 c0                	test   %eax,%eax
f0100fd0:	74 37                	je     f0101009 <page_lookup+0x55>
f0100fd2:	f6 00 01             	testb  $0x1,(%eax)
f0100fd5:	74 39                	je     f0101010 <page_lookup+0x5c>
                if(pte_store != NULL) 
f0100fd7:	85 db                	test   %ebx,%ebx
f0100fd9:	74 02                	je     f0100fdd <page_lookup+0x29>
                        *pte_store = tmp;
f0100fdb:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fdd:	8b 00                	mov    (%eax),%eax
f0100fdf:	c1 e8 0c             	shr    $0xc,%eax
f0100fe2:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0100fe8:	72 14                	jb     f0100ffe <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100fea:	83 ec 04             	sub    $0x4,%esp
f0100fed:	68 44 41 10 f0       	push   $0xf0104144
f0100ff2:	6a 4b                	push   $0x4b
f0100ff4:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0100ff9:	e8 8d f0 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100ffe:	8b 15 8c 79 11 f0    	mov    0xf011798c,%edx
f0101004:	8d 04 c2             	lea    (%edx,%eax,8),%eax
                return (struct PageInfo *)pa2page(*tmp);
f0101007:	eb 0c                	jmp    f0101015 <page_lookup+0x61>

        }
	return NULL;
f0101009:	b8 00 00 00 00       	mov    $0x0,%eax
f010100e:	eb 05                	jmp    f0101015 <page_lookup+0x61>
f0101010:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101015:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101018:	c9                   	leave  
f0101019:	c3                   	ret    

f010101a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010101a:	55                   	push   %ebp
f010101b:	89 e5                	mov    %esp,%ebp
f010101d:	53                   	push   %ebx
f010101e:	83 ec 18             	sub    $0x18,%esp
f0101021:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f0101024:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101027:	50                   	push   %eax
f0101028:	53                   	push   %ebx
f0101029:	ff 75 08             	pushl  0x8(%ebp)
f010102c:	e8 83 ff ff ff       	call   f0100fb4 <page_lookup>
        if( tmp != NULL) {
f0101031:	83 c4 10             	add    $0x10,%esp
f0101034:	85 c0                	test   %eax,%eax
f0101036:	74 15                	je     f010104d <tlb_invalidate+0x33>
                page_decref(tmp);
f0101038:	83 ec 0c             	sub    $0xc,%esp
f010103b:	50                   	push   %eax
f010103c:	e8 f6 fd ff ff       	call   f0100e37 <page_decref>
                *tmppte = 0;
f0101041:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010104a:	83 c4 10             	add    $0x10,%esp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010104d:	0f 01 3b             	invlpg (%ebx)
        }
	invlpg(va);
}
f0101050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101053:	c9                   	leave  
f0101054:	c3                   	ret    

f0101055 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101055:	55                   	push   %ebp
f0101056:	89 e5                	mov    %esp,%ebp
f0101058:	56                   	push   %esi
f0101059:	53                   	push   %ebx
f010105a:	83 ec 14             	sub    $0x14,%esp
f010105d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101060:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        pte_t *tmppte;
        struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
f0101063:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101066:	50                   	push   %eax
f0101067:	56                   	push   %esi
f0101068:	53                   	push   %ebx
f0101069:	e8 46 ff ff ff       	call   f0100fb4 <page_lookup>
        if( tmp != NULL && (*tmppte & PTE_P)) {
f010106e:	83 c4 10             	add    $0x10,%esp
f0101071:	85 c0                	test   %eax,%eax
f0101073:	74 1d                	je     f0101092 <page_remove+0x3d>
f0101075:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101078:	f6 02 01             	testb  $0x1,(%edx)
f010107b:	74 15                	je     f0101092 <page_remove+0x3d>
                page_decref(tmp);
f010107d:	83 ec 0c             	sub    $0xc,%esp
f0101080:	50                   	push   %eax
f0101081:	e8 b1 fd ff ff       	call   f0100e37 <page_decref>
                *tmppte = 0;
f0101086:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101089:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010108f:	83 c4 10             	add    $0x10,%esp
        }
        tlb_invalidate(pgdir, va);
f0101092:	83 ec 08             	sub    $0x8,%esp
f0101095:	56                   	push   %esi
f0101096:	53                   	push   %ebx
f0101097:	e8 7e ff ff ff       	call   f010101a <tlb_invalidate>
f010109c:	83 c4 10             	add    $0x10,%esp
}
f010109f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010a2:	5b                   	pop    %ebx
f01010a3:	5e                   	pop    %esi
f01010a4:	5d                   	pop    %ebp
f01010a5:	c3                   	ret    

f01010a6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010a6:	55                   	push   %ebp
f01010a7:	89 e5                	mov    %esp,%ebp
f01010a9:	57                   	push   %edi
f01010aa:	56                   	push   %esi
f01010ab:	53                   	push   %ebx
f01010ac:	83 ec 10             	sub    $0x10,%esp
f01010af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010b2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
f01010b5:	6a 01                	push   $0x1
f01010b7:	57                   	push   %edi
f01010b8:	ff 75 08             	pushl  0x8(%ebp)
f01010bb:	e8 9e fd ff ff       	call   f0100e5e <pgdir_walk>
f01010c0:	89 c3                	mov    %eax,%ebx
         
        if( tmp == NULL )
f01010c2:	83 c4 10             	add    $0x10,%esp
f01010c5:	85 c0                	test   %eax,%eax
f01010c7:	74 3e                	je     f0101107 <page_insert+0x61>
                return -E_NO_MEM;

        pp->pp_ref += 1;
f01010c9:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if( (*tmp & PTE_P) != 0 )
f01010ce:	f6 00 01             	testb  $0x1,(%eax)
f01010d1:	74 0f                	je     f01010e2 <page_insert+0x3c>
                page_remove(pgdir, va);
f01010d3:	83 ec 08             	sub    $0x8,%esp
f01010d6:	57                   	push   %edi
f01010d7:	ff 75 08             	pushl  0x8(%ebp)
f01010da:	e8 76 ff ff ff       	call   f0101055 <page_remove>
f01010df:	83 c4 10             	add    $0x10,%esp
f01010e2:	8b 55 14             	mov    0x14(%ebp),%edx
f01010e5:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010e8:	89 f0                	mov    %esi,%eax
f01010ea:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01010f0:	c1 f8 03             	sar    $0x3,%eax
f01010f3:	c1 e0 0c             	shl    $0xc,%eax
         
        *tmp = page2pa(pp) | perm | PTE_P;
f01010f6:	09 d0                	or     %edx,%eax
f01010f8:	89 03                	mov    %eax,(%ebx)
         pp->pp_link = NULL;
f01010fa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return 0;
f0101100:	b8 00 00 00 00       	mov    $0x0,%eax
f0101105:	eb 05                	jmp    f010110c <page_insert+0x66>
{
	// Fill this function in
        pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        if( tmp == NULL )
                return -E_NO_MEM;
f0101107:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
                page_remove(pgdir, va);
         
        *tmp = page2pa(pp) | perm | PTE_P;
         pp->pp_link = NULL;
	return 0;
}
f010110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010110f:	5b                   	pop    %ebx
f0101110:	5e                   	pop    %esi
f0101111:	5f                   	pop    %edi
f0101112:	5d                   	pop    %ebp
f0101113:	c3                   	ret    

f0101114 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101114:	55                   	push   %ebp
f0101115:	89 e5                	mov    %esp,%ebp
f0101117:	57                   	push   %edi
f0101118:	56                   	push   %esi
f0101119:	53                   	push   %ebx
f010111a:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010111d:	6a 15                	push   $0x15
f010111f:	e8 77 16 00 00       	call   f010279b <mc146818_read>
f0101124:	89 c3                	mov    %eax,%ebx
f0101126:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010112d:	e8 69 16 00 00       	call   f010279b <mc146818_read>
f0101132:	c1 e0 08             	shl    $0x8,%eax
f0101135:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101137:	c1 e0 0a             	shl    $0xa,%eax
f010113a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101140:	85 c0                	test   %eax,%eax
f0101142:	0f 48 c2             	cmovs  %edx,%eax
f0101145:	c1 f8 0c             	sar    $0xc,%eax
f0101148:	a3 60 75 11 f0       	mov    %eax,0xf0117560
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010114d:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101154:	e8 42 16 00 00       	call   f010279b <mc146818_read>
f0101159:	89 c3                	mov    %eax,%ebx
f010115b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101162:	e8 34 16 00 00       	call   f010279b <mc146818_read>
f0101167:	c1 e0 08             	shl    $0x8,%eax
f010116a:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010116c:	c1 e0 0a             	shl    $0xa,%eax
f010116f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101175:	83 c4 10             	add    $0x10,%esp
f0101178:	85 c0                	test   %eax,%eax
f010117a:	0f 48 c2             	cmovs  %edx,%eax
f010117d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101180:	85 c0                	test   %eax,%eax
f0101182:	74 0e                	je     f0101192 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101184:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010118a:	89 15 84 79 11 f0    	mov    %edx,0xf0117984
f0101190:	eb 0c                	jmp    f010119e <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101192:	8b 15 60 75 11 f0    	mov    0xf0117560,%edx
f0101198:	89 15 84 79 11 f0    	mov    %edx,0xf0117984

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010119e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011a1:	c1 e8 0a             	shr    $0xa,%eax
f01011a4:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01011a5:	a1 60 75 11 f0       	mov    0xf0117560,%eax
f01011aa:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011ad:	c1 e8 0a             	shr    $0xa,%eax
f01011b0:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01011b1:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f01011b6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011b9:	c1 e8 0a             	shr    $0xa,%eax
f01011bc:	50                   	push   %eax
f01011bd:	68 64 41 10 f0       	push   $0xf0104164
f01011c2:	e8 35 16 00 00       	call   f01027fc <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011c7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011cc:	e8 71 f7 ff ff       	call   f0100942 <boot_alloc>
f01011d1:	a3 88 79 11 f0       	mov    %eax,0xf0117988
	memset(kern_pgdir, 0, PGSIZE);
f01011d6:	83 c4 0c             	add    $0xc,%esp
f01011d9:	68 00 10 00 00       	push   $0x1000
f01011de:	6a 00                	push   $0x0
f01011e0:	50                   	push   %eax
f01011e1:	e8 02 21 00 00       	call   f01032e8 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011e6:	a1 88 79 11 f0       	mov    0xf0117988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011eb:	83 c4 10             	add    $0x10,%esp
f01011ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011f3:	77 15                	ja     f010120a <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011f5:	50                   	push   %eax
f01011f6:	68 20 41 10 f0       	push   $0xf0104120
f01011fb:	68 9e 00 00 00       	push   $0x9e
f0101200:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101205:	e8 81 ee ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010120a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101210:	83 ca 05             	or     $0x5,%edx
f0101213:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo));
f0101219:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f010121e:	c1 e0 03             	shl    $0x3,%eax
f0101221:	e8 1c f7 ff ff       	call   f0100942 <boot_alloc>
f0101226:	a3 8c 79 11 f0       	mov    %eax,0xf011798c
        memset(pages, 0, npages * sizeof(struct PageInfo));
f010122b:	83 ec 04             	sub    $0x4,%esp
f010122e:	8b 0d 84 79 11 f0    	mov    0xf0117984,%ecx
f0101234:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010123b:	52                   	push   %edx
f010123c:	6a 00                	push   $0x0
f010123e:	50                   	push   %eax
f010123f:	e8 a4 20 00 00       	call   f01032e8 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101244:	e8 7b fa ff ff       	call   f0100cc4 <page_init>

	check_page_free_list(1);
f0101249:	b8 01 00 00 00       	mov    $0x1,%eax
f010124e:	e8 b5 f7 ff ff       	call   f0100a08 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	83 3d 8c 79 11 f0 00 	cmpl   $0x0,0xf011798c
f010125d:	75 17                	jne    f0101276 <mem_init+0x162>
		panic("'pages' is a null pointer!");
f010125f:	83 ec 04             	sub    $0x4,%esp
f0101262:	68 09 3e 10 f0       	push   $0xf0103e09
f0101267:	68 74 02 00 00       	push   $0x274
f010126c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101271:	e8 15 ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101276:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f010127b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101280:	eb 05                	jmp    f0101287 <mem_init+0x173>
		++nfree;
f0101282:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101285:	8b 00                	mov    (%eax),%eax
f0101287:	85 c0                	test   %eax,%eax
f0101289:	75 f7                	jne    f0101282 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010128b:	83 ec 0c             	sub    $0xc,%esp
f010128e:	6a 00                	push   $0x0
f0101290:	e8 f5 fa ff ff       	call   f0100d8a <page_alloc>
f0101295:	89 c7                	mov    %eax,%edi
f0101297:	83 c4 10             	add    $0x10,%esp
f010129a:	85 c0                	test   %eax,%eax
f010129c:	75 19                	jne    f01012b7 <mem_init+0x1a3>
f010129e:	68 24 3e 10 f0       	push   $0xf0103e24
f01012a3:	68 44 3d 10 f0       	push   $0xf0103d44
f01012a8:	68 7c 02 00 00       	push   $0x27c
f01012ad:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01012b2:	e8 d4 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01012b7:	83 ec 0c             	sub    $0xc,%esp
f01012ba:	6a 00                	push   $0x0
f01012bc:	e8 c9 fa ff ff       	call   f0100d8a <page_alloc>
f01012c1:	89 c6                	mov    %eax,%esi
f01012c3:	83 c4 10             	add    $0x10,%esp
f01012c6:	85 c0                	test   %eax,%eax
f01012c8:	75 19                	jne    f01012e3 <mem_init+0x1cf>
f01012ca:	68 3a 3e 10 f0       	push   $0xf0103e3a
f01012cf:	68 44 3d 10 f0       	push   $0xf0103d44
f01012d4:	68 7d 02 00 00       	push   $0x27d
f01012d9:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01012de:	e8 a8 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012e3:	83 ec 0c             	sub    $0xc,%esp
f01012e6:	6a 00                	push   $0x0
f01012e8:	e8 9d fa ff ff       	call   f0100d8a <page_alloc>
f01012ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	75 19                	jne    f0101310 <mem_init+0x1fc>
f01012f7:	68 50 3e 10 f0       	push   $0xf0103e50
f01012fc:	68 44 3d 10 f0       	push   $0xf0103d44
f0101301:	68 7e 02 00 00       	push   $0x27e
f0101306:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010130b:	e8 7b ed ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101310:	39 f7                	cmp    %esi,%edi
f0101312:	75 19                	jne    f010132d <mem_init+0x219>
f0101314:	68 66 3e 10 f0       	push   $0xf0103e66
f0101319:	68 44 3d 10 f0       	push   $0xf0103d44
f010131e:	68 81 02 00 00       	push   $0x281
f0101323:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101328:	e8 5e ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010132d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101330:	39 c7                	cmp    %eax,%edi
f0101332:	74 04                	je     f0101338 <mem_init+0x224>
f0101334:	39 c6                	cmp    %eax,%esi
f0101336:	75 19                	jne    f0101351 <mem_init+0x23d>
f0101338:	68 a0 41 10 f0       	push   $0xf01041a0
f010133d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101342:	68 82 02 00 00       	push   $0x282
f0101347:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010134c:	e8 3a ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101351:	8b 0d 8c 79 11 f0    	mov    0xf011798c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101357:	8b 15 84 79 11 f0    	mov    0xf0117984,%edx
f010135d:	c1 e2 0c             	shl    $0xc,%edx
f0101360:	89 f8                	mov    %edi,%eax
f0101362:	29 c8                	sub    %ecx,%eax
f0101364:	c1 f8 03             	sar    $0x3,%eax
f0101367:	c1 e0 0c             	shl    $0xc,%eax
f010136a:	39 d0                	cmp    %edx,%eax
f010136c:	72 19                	jb     f0101387 <mem_init+0x273>
f010136e:	68 78 3e 10 f0       	push   $0xf0103e78
f0101373:	68 44 3d 10 f0       	push   $0xf0103d44
f0101378:	68 83 02 00 00       	push   $0x283
f010137d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101382:	e8 04 ed ff ff       	call   f010008b <_panic>
f0101387:	89 f0                	mov    %esi,%eax
f0101389:	29 c8                	sub    %ecx,%eax
f010138b:	c1 f8 03             	sar    $0x3,%eax
f010138e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101391:	39 c2                	cmp    %eax,%edx
f0101393:	77 19                	ja     f01013ae <mem_init+0x29a>
f0101395:	68 95 3e 10 f0       	push   $0xf0103e95
f010139a:	68 44 3d 10 f0       	push   $0xf0103d44
f010139f:	68 84 02 00 00       	push   $0x284
f01013a4:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01013a9:	e8 dd ec ff ff       	call   f010008b <_panic>
f01013ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013b1:	29 c8                	sub    %ecx,%eax
f01013b3:	c1 f8 03             	sar    $0x3,%eax
f01013b6:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01013b9:	39 c2                	cmp    %eax,%edx
f01013bb:	77 19                	ja     f01013d6 <mem_init+0x2c2>
f01013bd:	68 b2 3e 10 f0       	push   $0xf0103eb2
f01013c2:	68 44 3d 10 f0       	push   $0xf0103d44
f01013c7:	68 85 02 00 00       	push   $0x285
f01013cc:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01013d1:	e8 b5 ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013d6:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f01013db:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013de:	c7 05 5c 75 11 f0 00 	movl   $0x0,0xf011755c
f01013e5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013e8:	83 ec 0c             	sub    $0xc,%esp
f01013eb:	6a 00                	push   $0x0
f01013ed:	e8 98 f9 ff ff       	call   f0100d8a <page_alloc>
f01013f2:	83 c4 10             	add    $0x10,%esp
f01013f5:	85 c0                	test   %eax,%eax
f01013f7:	74 19                	je     f0101412 <mem_init+0x2fe>
f01013f9:	68 cf 3e 10 f0       	push   $0xf0103ecf
f01013fe:	68 44 3d 10 f0       	push   $0xf0103d44
f0101403:	68 8c 02 00 00       	push   $0x28c
f0101408:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010140d:	e8 79 ec ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101412:	83 ec 0c             	sub    $0xc,%esp
f0101415:	57                   	push   %edi
f0101416:	e8 dd f9 ff ff       	call   f0100df8 <page_free>
	page_free(pp1);
f010141b:	89 34 24             	mov    %esi,(%esp)
f010141e:	e8 d5 f9 ff ff       	call   f0100df8 <page_free>
	page_free(pp2);
f0101423:	83 c4 04             	add    $0x4,%esp
f0101426:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101429:	e8 ca f9 ff ff       	call   f0100df8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010142e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101435:	e8 50 f9 ff ff       	call   f0100d8a <page_alloc>
f010143a:	89 c6                	mov    %eax,%esi
f010143c:	83 c4 10             	add    $0x10,%esp
f010143f:	85 c0                	test   %eax,%eax
f0101441:	75 19                	jne    f010145c <mem_init+0x348>
f0101443:	68 24 3e 10 f0       	push   $0xf0103e24
f0101448:	68 44 3d 10 f0       	push   $0xf0103d44
f010144d:	68 93 02 00 00       	push   $0x293
f0101452:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101457:	e8 2f ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010145c:	83 ec 0c             	sub    $0xc,%esp
f010145f:	6a 00                	push   $0x0
f0101461:	e8 24 f9 ff ff       	call   f0100d8a <page_alloc>
f0101466:	89 c7                	mov    %eax,%edi
f0101468:	83 c4 10             	add    $0x10,%esp
f010146b:	85 c0                	test   %eax,%eax
f010146d:	75 19                	jne    f0101488 <mem_init+0x374>
f010146f:	68 3a 3e 10 f0       	push   $0xf0103e3a
f0101474:	68 44 3d 10 f0       	push   $0xf0103d44
f0101479:	68 94 02 00 00       	push   $0x294
f010147e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101483:	e8 03 ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101488:	83 ec 0c             	sub    $0xc,%esp
f010148b:	6a 00                	push   $0x0
f010148d:	e8 f8 f8 ff ff       	call   f0100d8a <page_alloc>
f0101492:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101495:	83 c4 10             	add    $0x10,%esp
f0101498:	85 c0                	test   %eax,%eax
f010149a:	75 19                	jne    f01014b5 <mem_init+0x3a1>
f010149c:	68 50 3e 10 f0       	push   $0xf0103e50
f01014a1:	68 44 3d 10 f0       	push   $0xf0103d44
f01014a6:	68 95 02 00 00       	push   $0x295
f01014ab:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01014b0:	e8 d6 eb ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014b5:	39 fe                	cmp    %edi,%esi
f01014b7:	75 19                	jne    f01014d2 <mem_init+0x3be>
f01014b9:	68 66 3e 10 f0       	push   $0xf0103e66
f01014be:	68 44 3d 10 f0       	push   $0xf0103d44
f01014c3:	68 97 02 00 00       	push   $0x297
f01014c8:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01014cd:	e8 b9 eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014d5:	39 c6                	cmp    %eax,%esi
f01014d7:	74 04                	je     f01014dd <mem_init+0x3c9>
f01014d9:	39 c7                	cmp    %eax,%edi
f01014db:	75 19                	jne    f01014f6 <mem_init+0x3e2>
f01014dd:	68 a0 41 10 f0       	push   $0xf01041a0
f01014e2:	68 44 3d 10 f0       	push   $0xf0103d44
f01014e7:	68 98 02 00 00       	push   $0x298
f01014ec:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01014f1:	e8 95 eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01014f6:	83 ec 0c             	sub    $0xc,%esp
f01014f9:	6a 00                	push   $0x0
f01014fb:	e8 8a f8 ff ff       	call   f0100d8a <page_alloc>
f0101500:	83 c4 10             	add    $0x10,%esp
f0101503:	85 c0                	test   %eax,%eax
f0101505:	74 19                	je     f0101520 <mem_init+0x40c>
f0101507:	68 cf 3e 10 f0       	push   $0xf0103ecf
f010150c:	68 44 3d 10 f0       	push   $0xf0103d44
f0101511:	68 99 02 00 00       	push   $0x299
f0101516:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010151b:	e8 6b eb ff ff       	call   f010008b <_panic>
f0101520:	89 f0                	mov    %esi,%eax
f0101522:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101528:	c1 f8 03             	sar    $0x3,%eax
f010152b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010152e:	89 c2                	mov    %eax,%edx
f0101530:	c1 ea 0c             	shr    $0xc,%edx
f0101533:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0101539:	72 12                	jb     f010154d <mem_init+0x439>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010153b:	50                   	push   %eax
f010153c:	68 38 40 10 f0       	push   $0xf0104038
f0101541:	6a 52                	push   $0x52
f0101543:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0101548:	e8 3e eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010154d:	83 ec 04             	sub    $0x4,%esp
f0101550:	68 00 10 00 00       	push   $0x1000
f0101555:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101557:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010155c:	50                   	push   %eax
f010155d:	e8 86 1d 00 00       	call   f01032e8 <memset>
	page_free(pp0);
f0101562:	89 34 24             	mov    %esi,(%esp)
f0101565:	e8 8e f8 ff ff       	call   f0100df8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010156a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101571:	e8 14 f8 ff ff       	call   f0100d8a <page_alloc>
f0101576:	83 c4 10             	add    $0x10,%esp
f0101579:	85 c0                	test   %eax,%eax
f010157b:	75 19                	jne    f0101596 <mem_init+0x482>
f010157d:	68 de 3e 10 f0       	push   $0xf0103ede
f0101582:	68 44 3d 10 f0       	push   $0xf0103d44
f0101587:	68 9e 02 00 00       	push   $0x29e
f010158c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101591:	e8 f5 ea ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101596:	39 c6                	cmp    %eax,%esi
f0101598:	74 19                	je     f01015b3 <mem_init+0x49f>
f010159a:	68 fc 3e 10 f0       	push   $0xf0103efc
f010159f:	68 44 3d 10 f0       	push   $0xf0103d44
f01015a4:	68 9f 02 00 00       	push   $0x29f
f01015a9:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01015ae:	e8 d8 ea ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015b3:	89 f0                	mov    %esi,%eax
f01015b5:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01015bb:	c1 f8 03             	sar    $0x3,%eax
f01015be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015c1:	89 c2                	mov    %eax,%edx
f01015c3:	c1 ea 0c             	shr    $0xc,%edx
f01015c6:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f01015cc:	72 12                	jb     f01015e0 <mem_init+0x4cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ce:	50                   	push   %eax
f01015cf:	68 38 40 10 f0       	push   $0xf0104038
f01015d4:	6a 52                	push   $0x52
f01015d6:	68 2a 3d 10 f0       	push   $0xf0103d2a
f01015db:	e8 ab ea ff ff       	call   f010008b <_panic>
f01015e0:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015e6:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015ec:	80 38 00             	cmpb   $0x0,(%eax)
f01015ef:	74 19                	je     f010160a <mem_init+0x4f6>
f01015f1:	68 0c 3f 10 f0       	push   $0xf0103f0c
f01015f6:	68 44 3d 10 f0       	push   $0xf0103d44
f01015fb:	68 a2 02 00 00       	push   $0x2a2
f0101600:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101605:	e8 81 ea ff ff       	call   f010008b <_panic>
f010160a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010160d:	39 d0                	cmp    %edx,%eax
f010160f:	75 db                	jne    f01015ec <mem_init+0x4d8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101611:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101614:	a3 5c 75 11 f0       	mov    %eax,0xf011755c

	// free the pages we took
	page_free(pp0);
f0101619:	83 ec 0c             	sub    $0xc,%esp
f010161c:	56                   	push   %esi
f010161d:	e8 d6 f7 ff ff       	call   f0100df8 <page_free>
	page_free(pp1);
f0101622:	89 3c 24             	mov    %edi,(%esp)
f0101625:	e8 ce f7 ff ff       	call   f0100df8 <page_free>
	page_free(pp2);
f010162a:	83 c4 04             	add    $0x4,%esp
f010162d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101630:	e8 c3 f7 ff ff       	call   f0100df8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101635:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f010163a:	83 c4 10             	add    $0x10,%esp
f010163d:	eb 05                	jmp    f0101644 <mem_init+0x530>
		--nfree;
f010163f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101642:	8b 00                	mov    (%eax),%eax
f0101644:	85 c0                	test   %eax,%eax
f0101646:	75 f7                	jne    f010163f <mem_init+0x52b>
		--nfree;
	assert(nfree == 0);
f0101648:	85 db                	test   %ebx,%ebx
f010164a:	74 19                	je     f0101665 <mem_init+0x551>
f010164c:	68 16 3f 10 f0       	push   $0xf0103f16
f0101651:	68 44 3d 10 f0       	push   $0xf0103d44
f0101656:	68 af 02 00 00       	push   $0x2af
f010165b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101660:	e8 26 ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101665:	83 ec 0c             	sub    $0xc,%esp
f0101668:	68 c0 41 10 f0       	push   $0xf01041c0
f010166d:	e8 8a 11 00 00       	call   f01027fc <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101672:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101679:	e8 0c f7 ff ff       	call   f0100d8a <page_alloc>
f010167e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101681:	83 c4 10             	add    $0x10,%esp
f0101684:	85 c0                	test   %eax,%eax
f0101686:	75 19                	jne    f01016a1 <mem_init+0x58d>
f0101688:	68 24 3e 10 f0       	push   $0xf0103e24
f010168d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101692:	68 08 03 00 00       	push   $0x308
f0101697:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010169c:	e8 ea e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01016a1:	83 ec 0c             	sub    $0xc,%esp
f01016a4:	6a 00                	push   $0x0
f01016a6:	e8 df f6 ff ff       	call   f0100d8a <page_alloc>
f01016ab:	89 c3                	mov    %eax,%ebx
f01016ad:	83 c4 10             	add    $0x10,%esp
f01016b0:	85 c0                	test   %eax,%eax
f01016b2:	75 19                	jne    f01016cd <mem_init+0x5b9>
f01016b4:	68 3a 3e 10 f0       	push   $0xf0103e3a
f01016b9:	68 44 3d 10 f0       	push   $0xf0103d44
f01016be:	68 09 03 00 00       	push   $0x309
f01016c3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01016c8:	e8 be e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01016cd:	83 ec 0c             	sub    $0xc,%esp
f01016d0:	6a 00                	push   $0x0
f01016d2:	e8 b3 f6 ff ff       	call   f0100d8a <page_alloc>
f01016d7:	89 c6                	mov    %eax,%esi
f01016d9:	83 c4 10             	add    $0x10,%esp
f01016dc:	85 c0                	test   %eax,%eax
f01016de:	75 19                	jne    f01016f9 <mem_init+0x5e5>
f01016e0:	68 50 3e 10 f0       	push   $0xf0103e50
f01016e5:	68 44 3d 10 f0       	push   $0xf0103d44
f01016ea:	68 0a 03 00 00       	push   $0x30a
f01016ef:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01016f4:	e8 92 e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016f9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01016fc:	75 19                	jne    f0101717 <mem_init+0x603>
f01016fe:	68 66 3e 10 f0       	push   $0xf0103e66
f0101703:	68 44 3d 10 f0       	push   $0xf0103d44
f0101708:	68 0d 03 00 00       	push   $0x30d
f010170d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101712:	e8 74 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101717:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010171a:	74 04                	je     f0101720 <mem_init+0x60c>
f010171c:	39 c3                	cmp    %eax,%ebx
f010171e:	75 19                	jne    f0101739 <mem_init+0x625>
f0101720:	68 a0 41 10 f0       	push   $0xf01041a0
f0101725:	68 44 3d 10 f0       	push   $0xf0103d44
f010172a:	68 0e 03 00 00       	push   $0x30e
f010172f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101734:	e8 52 e9 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101739:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f010173e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101741:	c7 05 5c 75 11 f0 00 	movl   $0x0,0xf011755c
f0101748:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010174b:	83 ec 0c             	sub    $0xc,%esp
f010174e:	6a 00                	push   $0x0
f0101750:	e8 35 f6 ff ff       	call   f0100d8a <page_alloc>
f0101755:	83 c4 10             	add    $0x10,%esp
f0101758:	85 c0                	test   %eax,%eax
f010175a:	74 19                	je     f0101775 <mem_init+0x661>
f010175c:	68 cf 3e 10 f0       	push   $0xf0103ecf
f0101761:	68 44 3d 10 f0       	push   $0xf0103d44
f0101766:	68 15 03 00 00       	push   $0x315
f010176b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101770:	e8 16 e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101775:	83 ec 04             	sub    $0x4,%esp
f0101778:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010177b:	50                   	push   %eax
f010177c:	6a 00                	push   $0x0
f010177e:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101784:	e8 2b f8 ff ff       	call   f0100fb4 <page_lookup>
f0101789:	83 c4 10             	add    $0x10,%esp
f010178c:	85 c0                	test   %eax,%eax
f010178e:	74 19                	je     f01017a9 <mem_init+0x695>
f0101790:	68 e0 41 10 f0       	push   $0xf01041e0
f0101795:	68 44 3d 10 f0       	push   $0xf0103d44
f010179a:	68 18 03 00 00       	push   $0x318
f010179f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01017a4:	e8 e2 e8 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017a9:	6a 02                	push   $0x2
f01017ab:	6a 00                	push   $0x0
f01017ad:	53                   	push   %ebx
f01017ae:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01017b4:	e8 ed f8 ff ff       	call   f01010a6 <page_insert>
f01017b9:	83 c4 10             	add    $0x10,%esp
f01017bc:	85 c0                	test   %eax,%eax
f01017be:	78 19                	js     f01017d9 <mem_init+0x6c5>
f01017c0:	68 18 42 10 f0       	push   $0xf0104218
f01017c5:	68 44 3d 10 f0       	push   $0xf0103d44
f01017ca:	68 1b 03 00 00       	push   $0x31b
f01017cf:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01017d4:	e8 b2 e8 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017d9:	83 ec 0c             	sub    $0xc,%esp
f01017dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017df:	e8 14 f6 ff ff       	call   f0100df8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017e4:	6a 02                	push   $0x2
f01017e6:	6a 00                	push   $0x0
f01017e8:	53                   	push   %ebx
f01017e9:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01017ef:	e8 b2 f8 ff ff       	call   f01010a6 <page_insert>
f01017f4:	83 c4 20             	add    $0x20,%esp
f01017f7:	85 c0                	test   %eax,%eax
f01017f9:	74 19                	je     f0101814 <mem_init+0x700>
f01017fb:	68 48 42 10 f0       	push   $0xf0104248
f0101800:	68 44 3d 10 f0       	push   $0xf0103d44
f0101805:	68 1f 03 00 00       	push   $0x31f
f010180a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010180f:	e8 77 e8 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101814:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010181a:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f010181f:	89 c1                	mov    %eax,%ecx
f0101821:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101824:	8b 17                	mov    (%edi),%edx
f0101826:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010182c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010182f:	29 c8                	sub    %ecx,%eax
f0101831:	c1 f8 03             	sar    $0x3,%eax
f0101834:	c1 e0 0c             	shl    $0xc,%eax
f0101837:	39 c2                	cmp    %eax,%edx
f0101839:	74 19                	je     f0101854 <mem_init+0x740>
f010183b:	68 78 42 10 f0       	push   $0xf0104278
f0101840:	68 44 3d 10 f0       	push   $0xf0103d44
f0101845:	68 20 03 00 00       	push   $0x320
f010184a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010184f:	e8 37 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101854:	ba 00 00 00 00       	mov    $0x0,%edx
f0101859:	89 f8                	mov    %edi,%eax
f010185b:	e8 44 f1 ff ff       	call   f01009a4 <check_va2pa>
f0101860:	89 da                	mov    %ebx,%edx
f0101862:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101865:	c1 fa 03             	sar    $0x3,%edx
f0101868:	c1 e2 0c             	shl    $0xc,%edx
f010186b:	39 d0                	cmp    %edx,%eax
f010186d:	74 19                	je     f0101888 <mem_init+0x774>
f010186f:	68 a0 42 10 f0       	push   $0xf01042a0
f0101874:	68 44 3d 10 f0       	push   $0xf0103d44
f0101879:	68 21 03 00 00       	push   $0x321
f010187e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101883:	e8 03 e8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101888:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010188d:	74 19                	je     f01018a8 <mem_init+0x794>
f010188f:	68 21 3f 10 f0       	push   $0xf0103f21
f0101894:	68 44 3d 10 f0       	push   $0xf0103d44
f0101899:	68 22 03 00 00       	push   $0x322
f010189e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01018a3:	e8 e3 e7 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01018a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018ab:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018b0:	74 19                	je     f01018cb <mem_init+0x7b7>
f01018b2:	68 32 3f 10 f0       	push   $0xf0103f32
f01018b7:	68 44 3d 10 f0       	push   $0xf0103d44
f01018bc:	68 23 03 00 00       	push   $0x323
f01018c1:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01018c6:	e8 c0 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018cb:	6a 02                	push   $0x2
f01018cd:	68 00 10 00 00       	push   $0x1000
f01018d2:	56                   	push   %esi
f01018d3:	57                   	push   %edi
f01018d4:	e8 cd f7 ff ff       	call   f01010a6 <page_insert>
f01018d9:	83 c4 10             	add    $0x10,%esp
f01018dc:	85 c0                	test   %eax,%eax
f01018de:	74 19                	je     f01018f9 <mem_init+0x7e5>
f01018e0:	68 d0 42 10 f0       	push   $0xf01042d0
f01018e5:	68 44 3d 10 f0       	push   $0xf0103d44
f01018ea:	68 26 03 00 00       	push   $0x326
f01018ef:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01018f4:	e8 92 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018f9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018fe:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0101903:	e8 9c f0 ff ff       	call   f01009a4 <check_va2pa>
f0101908:	89 f2                	mov    %esi,%edx
f010190a:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101910:	c1 fa 03             	sar    $0x3,%edx
f0101913:	c1 e2 0c             	shl    $0xc,%edx
f0101916:	39 d0                	cmp    %edx,%eax
f0101918:	74 19                	je     f0101933 <mem_init+0x81f>
f010191a:	68 0c 43 10 f0       	push   $0xf010430c
f010191f:	68 44 3d 10 f0       	push   $0xf0103d44
f0101924:	68 27 03 00 00       	push   $0x327
f0101929:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010192e:	e8 58 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101933:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101938:	74 19                	je     f0101953 <mem_init+0x83f>
f010193a:	68 43 3f 10 f0       	push   $0xf0103f43
f010193f:	68 44 3d 10 f0       	push   $0xf0103d44
f0101944:	68 28 03 00 00       	push   $0x328
f0101949:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010194e:	e8 38 e7 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101953:	83 ec 0c             	sub    $0xc,%esp
f0101956:	6a 00                	push   $0x0
f0101958:	e8 2d f4 ff ff       	call   f0100d8a <page_alloc>
f010195d:	83 c4 10             	add    $0x10,%esp
f0101960:	85 c0                	test   %eax,%eax
f0101962:	74 19                	je     f010197d <mem_init+0x869>
f0101964:	68 cf 3e 10 f0       	push   $0xf0103ecf
f0101969:	68 44 3d 10 f0       	push   $0xf0103d44
f010196e:	68 2b 03 00 00       	push   $0x32b
f0101973:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101978:	e8 0e e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010197d:	6a 02                	push   $0x2
f010197f:	68 00 10 00 00       	push   $0x1000
f0101984:	56                   	push   %esi
f0101985:	ff 35 88 79 11 f0    	pushl  0xf0117988
f010198b:	e8 16 f7 ff ff       	call   f01010a6 <page_insert>
f0101990:	83 c4 10             	add    $0x10,%esp
f0101993:	85 c0                	test   %eax,%eax
f0101995:	74 19                	je     f01019b0 <mem_init+0x89c>
f0101997:	68 d0 42 10 f0       	push   $0xf01042d0
f010199c:	68 44 3d 10 f0       	push   $0xf0103d44
f01019a1:	68 2e 03 00 00       	push   $0x32e
f01019a6:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01019ab:	e8 db e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019b0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019b5:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f01019ba:	e8 e5 ef ff ff       	call   f01009a4 <check_va2pa>
f01019bf:	89 f2                	mov    %esi,%edx
f01019c1:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f01019c7:	c1 fa 03             	sar    $0x3,%edx
f01019ca:	c1 e2 0c             	shl    $0xc,%edx
f01019cd:	39 d0                	cmp    %edx,%eax
f01019cf:	74 19                	je     f01019ea <mem_init+0x8d6>
f01019d1:	68 0c 43 10 f0       	push   $0xf010430c
f01019d6:	68 44 3d 10 f0       	push   $0xf0103d44
f01019db:	68 2f 03 00 00       	push   $0x32f
f01019e0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01019e5:	e8 a1 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019ea:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019ef:	74 19                	je     f0101a0a <mem_init+0x8f6>
f01019f1:	68 43 3f 10 f0       	push   $0xf0103f43
f01019f6:	68 44 3d 10 f0       	push   $0xf0103d44
f01019fb:	68 30 03 00 00       	push   $0x330
f0101a00:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101a05:	e8 81 e6 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a0a:	83 ec 0c             	sub    $0xc,%esp
f0101a0d:	6a 00                	push   $0x0
f0101a0f:	e8 76 f3 ff ff       	call   f0100d8a <page_alloc>
f0101a14:	83 c4 10             	add    $0x10,%esp
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	74 19                	je     f0101a34 <mem_init+0x920>
f0101a1b:	68 cf 3e 10 f0       	push   $0xf0103ecf
f0101a20:	68 44 3d 10 f0       	push   $0xf0103d44
f0101a25:	68 34 03 00 00       	push   $0x334
f0101a2a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101a2f:	e8 57 e6 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a34:	8b 15 88 79 11 f0    	mov    0xf0117988,%edx
f0101a3a:	8b 02                	mov    (%edx),%eax
f0101a3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a41:	89 c1                	mov    %eax,%ecx
f0101a43:	c1 e9 0c             	shr    $0xc,%ecx
f0101a46:	3b 0d 84 79 11 f0    	cmp    0xf0117984,%ecx
f0101a4c:	72 15                	jb     f0101a63 <mem_init+0x94f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a4e:	50                   	push   %eax
f0101a4f:	68 38 40 10 f0       	push   $0xf0104038
f0101a54:	68 37 03 00 00       	push   $0x337
f0101a59:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101a5e:	e8 28 e6 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101a63:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a6b:	83 ec 04             	sub    $0x4,%esp
f0101a6e:	6a 00                	push   $0x0
f0101a70:	68 00 10 00 00       	push   $0x1000
f0101a75:	52                   	push   %edx
f0101a76:	e8 e3 f3 ff ff       	call   f0100e5e <pgdir_walk>
f0101a7b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a7e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a81:	83 c4 10             	add    $0x10,%esp
f0101a84:	39 d0                	cmp    %edx,%eax
f0101a86:	74 19                	je     f0101aa1 <mem_init+0x98d>
f0101a88:	68 3c 43 10 f0       	push   $0xf010433c
f0101a8d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101a92:	68 38 03 00 00       	push   $0x338
f0101a97:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101a9c:	e8 ea e5 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aa1:	6a 06                	push   $0x6
f0101aa3:	68 00 10 00 00       	push   $0x1000
f0101aa8:	56                   	push   %esi
f0101aa9:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101aaf:	e8 f2 f5 ff ff       	call   f01010a6 <page_insert>
f0101ab4:	83 c4 10             	add    $0x10,%esp
f0101ab7:	85 c0                	test   %eax,%eax
f0101ab9:	74 19                	je     f0101ad4 <mem_init+0x9c0>
f0101abb:	68 7c 43 10 f0       	push   $0xf010437c
f0101ac0:	68 44 3d 10 f0       	push   $0xf0103d44
f0101ac5:	68 3b 03 00 00       	push   $0x33b
f0101aca:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101acf:	e8 b7 e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ad4:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101ada:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101adf:	89 f8                	mov    %edi,%eax
f0101ae1:	e8 be ee ff ff       	call   f01009a4 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ae6:	89 f2                	mov    %esi,%edx
f0101ae8:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101aee:	c1 fa 03             	sar    $0x3,%edx
f0101af1:	c1 e2 0c             	shl    $0xc,%edx
f0101af4:	39 d0                	cmp    %edx,%eax
f0101af6:	74 19                	je     f0101b11 <mem_init+0x9fd>
f0101af8:	68 0c 43 10 f0       	push   $0xf010430c
f0101afd:	68 44 3d 10 f0       	push   $0xf0103d44
f0101b02:	68 3c 03 00 00       	push   $0x33c
f0101b07:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101b0c:	e8 7a e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101b11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b16:	74 19                	je     f0101b31 <mem_init+0xa1d>
f0101b18:	68 43 3f 10 f0       	push   $0xf0103f43
f0101b1d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101b22:	68 3d 03 00 00       	push   $0x33d
f0101b27:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101b2c:	e8 5a e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b31:	83 ec 04             	sub    $0x4,%esp
f0101b34:	6a 00                	push   $0x0
f0101b36:	68 00 10 00 00       	push   $0x1000
f0101b3b:	57                   	push   %edi
f0101b3c:	e8 1d f3 ff ff       	call   f0100e5e <pgdir_walk>
f0101b41:	83 c4 10             	add    $0x10,%esp
f0101b44:	f6 00 04             	testb  $0x4,(%eax)
f0101b47:	75 19                	jne    f0101b62 <mem_init+0xa4e>
f0101b49:	68 bc 43 10 f0       	push   $0xf01043bc
f0101b4e:	68 44 3d 10 f0       	push   $0xf0103d44
f0101b53:	68 3e 03 00 00       	push   $0x33e
f0101b58:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101b5d:	e8 29 e5 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b62:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0101b67:	f6 00 04             	testb  $0x4,(%eax)
f0101b6a:	75 19                	jne    f0101b85 <mem_init+0xa71>
f0101b6c:	68 54 3f 10 f0       	push   $0xf0103f54
f0101b71:	68 44 3d 10 f0       	push   $0xf0103d44
f0101b76:	68 3f 03 00 00       	push   $0x33f
f0101b7b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101b80:	e8 06 e5 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b85:	6a 02                	push   $0x2
f0101b87:	68 00 10 00 00       	push   $0x1000
f0101b8c:	56                   	push   %esi
f0101b8d:	50                   	push   %eax
f0101b8e:	e8 13 f5 ff ff       	call   f01010a6 <page_insert>
f0101b93:	83 c4 10             	add    $0x10,%esp
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	74 19                	je     f0101bb3 <mem_init+0xa9f>
f0101b9a:	68 d0 42 10 f0       	push   $0xf01042d0
f0101b9f:	68 44 3d 10 f0       	push   $0xf0103d44
f0101ba4:	68 42 03 00 00       	push   $0x342
f0101ba9:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101bae:	e8 d8 e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bb3:	83 ec 04             	sub    $0x4,%esp
f0101bb6:	6a 00                	push   $0x0
f0101bb8:	68 00 10 00 00       	push   $0x1000
f0101bbd:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101bc3:	e8 96 f2 ff ff       	call   f0100e5e <pgdir_walk>
f0101bc8:	83 c4 10             	add    $0x10,%esp
f0101bcb:	f6 00 02             	testb  $0x2,(%eax)
f0101bce:	75 19                	jne    f0101be9 <mem_init+0xad5>
f0101bd0:	68 f0 43 10 f0       	push   $0xf01043f0
f0101bd5:	68 44 3d 10 f0       	push   $0xf0103d44
f0101bda:	68 43 03 00 00       	push   $0x343
f0101bdf:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101be4:	e8 a2 e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101be9:	83 ec 04             	sub    $0x4,%esp
f0101bec:	6a 00                	push   $0x0
f0101bee:	68 00 10 00 00       	push   $0x1000
f0101bf3:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101bf9:	e8 60 f2 ff ff       	call   f0100e5e <pgdir_walk>
f0101bfe:	83 c4 10             	add    $0x10,%esp
f0101c01:	f6 00 04             	testb  $0x4,(%eax)
f0101c04:	74 19                	je     f0101c1f <mem_init+0xb0b>
f0101c06:	68 24 44 10 f0       	push   $0xf0104424
f0101c0b:	68 44 3d 10 f0       	push   $0xf0103d44
f0101c10:	68 44 03 00 00       	push   $0x344
f0101c15:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101c1a:	e8 6c e4 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c1f:	6a 02                	push   $0x2
f0101c21:	68 00 00 40 00       	push   $0x400000
f0101c26:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c29:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101c2f:	e8 72 f4 ff ff       	call   f01010a6 <page_insert>
f0101c34:	83 c4 10             	add    $0x10,%esp
f0101c37:	85 c0                	test   %eax,%eax
f0101c39:	78 19                	js     f0101c54 <mem_init+0xb40>
f0101c3b:	68 5c 44 10 f0       	push   $0xf010445c
f0101c40:	68 44 3d 10 f0       	push   $0xf0103d44
f0101c45:	68 47 03 00 00       	push   $0x347
f0101c4a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101c4f:	e8 37 e4 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c54:	6a 02                	push   $0x2
f0101c56:	68 00 10 00 00       	push   $0x1000
f0101c5b:	53                   	push   %ebx
f0101c5c:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101c62:	e8 3f f4 ff ff       	call   f01010a6 <page_insert>
f0101c67:	83 c4 10             	add    $0x10,%esp
f0101c6a:	85 c0                	test   %eax,%eax
f0101c6c:	74 19                	je     f0101c87 <mem_init+0xb73>
f0101c6e:	68 94 44 10 f0       	push   $0xf0104494
f0101c73:	68 44 3d 10 f0       	push   $0xf0103d44
f0101c78:	68 4a 03 00 00       	push   $0x34a
f0101c7d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101c82:	e8 04 e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c87:	83 ec 04             	sub    $0x4,%esp
f0101c8a:	6a 00                	push   $0x0
f0101c8c:	68 00 10 00 00       	push   $0x1000
f0101c91:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101c97:	e8 c2 f1 ff ff       	call   f0100e5e <pgdir_walk>
f0101c9c:	83 c4 10             	add    $0x10,%esp
f0101c9f:	f6 00 04             	testb  $0x4,(%eax)
f0101ca2:	74 19                	je     f0101cbd <mem_init+0xba9>
f0101ca4:	68 24 44 10 f0       	push   $0xf0104424
f0101ca9:	68 44 3d 10 f0       	push   $0xf0103d44
f0101cae:	68 4b 03 00 00       	push   $0x34b
f0101cb3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101cb8:	e8 ce e3 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cbd:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101cc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cc8:	89 f8                	mov    %edi,%eax
f0101cca:	e8 d5 ec ff ff       	call   f01009a4 <check_va2pa>
f0101ccf:	89 c1                	mov    %eax,%ecx
f0101cd1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cd4:	89 d8                	mov    %ebx,%eax
f0101cd6:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101cdc:	c1 f8 03             	sar    $0x3,%eax
f0101cdf:	c1 e0 0c             	shl    $0xc,%eax
f0101ce2:	39 c1                	cmp    %eax,%ecx
f0101ce4:	74 19                	je     f0101cff <mem_init+0xbeb>
f0101ce6:	68 d0 44 10 f0       	push   $0xf01044d0
f0101ceb:	68 44 3d 10 f0       	push   $0xf0103d44
f0101cf0:	68 4e 03 00 00       	push   $0x34e
f0101cf5:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101cfa:	e8 8c e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cff:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d04:	89 f8                	mov    %edi,%eax
f0101d06:	e8 99 ec ff ff       	call   f01009a4 <check_va2pa>
f0101d0b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d0e:	74 19                	je     f0101d29 <mem_init+0xc15>
f0101d10:	68 fc 44 10 f0       	push   $0xf01044fc
f0101d15:	68 44 3d 10 f0       	push   $0xf0103d44
f0101d1a:	68 4f 03 00 00       	push   $0x34f
f0101d1f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101d24:	e8 62 e3 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d29:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d2e:	74 19                	je     f0101d49 <mem_init+0xc35>
f0101d30:	68 6a 3f 10 f0       	push   $0xf0103f6a
f0101d35:	68 44 3d 10 f0       	push   $0xf0103d44
f0101d3a:	68 51 03 00 00       	push   $0x351
f0101d3f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101d44:	e8 42 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d49:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d4e:	74 19                	je     f0101d69 <mem_init+0xc55>
f0101d50:	68 7b 3f 10 f0       	push   $0xf0103f7b
f0101d55:	68 44 3d 10 f0       	push   $0xf0103d44
f0101d5a:	68 52 03 00 00       	push   $0x352
f0101d5f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101d64:	e8 22 e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d69:	83 ec 0c             	sub    $0xc,%esp
f0101d6c:	6a 00                	push   $0x0
f0101d6e:	e8 17 f0 ff ff       	call   f0100d8a <page_alloc>
f0101d73:	83 c4 10             	add    $0x10,%esp
f0101d76:	85 c0                	test   %eax,%eax
f0101d78:	74 04                	je     f0101d7e <mem_init+0xc6a>
f0101d7a:	39 c6                	cmp    %eax,%esi
f0101d7c:	74 19                	je     f0101d97 <mem_init+0xc83>
f0101d7e:	68 2c 45 10 f0       	push   $0xf010452c
f0101d83:	68 44 3d 10 f0       	push   $0xf0103d44
f0101d88:	68 55 03 00 00       	push   $0x355
f0101d8d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101d92:	e8 f4 e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d97:	83 ec 08             	sub    $0x8,%esp
f0101d9a:	6a 00                	push   $0x0
f0101d9c:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101da2:	e8 ae f2 ff ff       	call   f0101055 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101da7:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101dad:	ba 00 00 00 00       	mov    $0x0,%edx
f0101db2:	89 f8                	mov    %edi,%eax
f0101db4:	e8 eb eb ff ff       	call   f01009a4 <check_va2pa>
f0101db9:	83 c4 10             	add    $0x10,%esp
f0101dbc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dbf:	74 19                	je     f0101dda <mem_init+0xcc6>
f0101dc1:	68 50 45 10 f0       	push   $0xf0104550
f0101dc6:	68 44 3d 10 f0       	push   $0xf0103d44
f0101dcb:	68 59 03 00 00       	push   $0x359
f0101dd0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101dd5:	e8 b1 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dda:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ddf:	89 f8                	mov    %edi,%eax
f0101de1:	e8 be eb ff ff       	call   f01009a4 <check_va2pa>
f0101de6:	89 da                	mov    %ebx,%edx
f0101de8:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101dee:	c1 fa 03             	sar    $0x3,%edx
f0101df1:	c1 e2 0c             	shl    $0xc,%edx
f0101df4:	39 d0                	cmp    %edx,%eax
f0101df6:	74 19                	je     f0101e11 <mem_init+0xcfd>
f0101df8:	68 fc 44 10 f0       	push   $0xf01044fc
f0101dfd:	68 44 3d 10 f0       	push   $0xf0103d44
f0101e02:	68 5a 03 00 00       	push   $0x35a
f0101e07:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101e0c:	e8 7a e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101e11:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e16:	74 19                	je     f0101e31 <mem_init+0xd1d>
f0101e18:	68 21 3f 10 f0       	push   $0xf0103f21
f0101e1d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101e22:	68 5b 03 00 00       	push   $0x35b
f0101e27:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101e2c:	e8 5a e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e31:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e36:	74 19                	je     f0101e51 <mem_init+0xd3d>
f0101e38:	68 7b 3f 10 f0       	push   $0xf0103f7b
f0101e3d:	68 44 3d 10 f0       	push   $0xf0103d44
f0101e42:	68 5c 03 00 00       	push   $0x35c
f0101e47:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101e4c:	e8 3a e2 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e51:	6a 00                	push   $0x0
f0101e53:	68 00 10 00 00       	push   $0x1000
f0101e58:	53                   	push   %ebx
f0101e59:	57                   	push   %edi
f0101e5a:	e8 47 f2 ff ff       	call   f01010a6 <page_insert>
f0101e5f:	83 c4 10             	add    $0x10,%esp
f0101e62:	85 c0                	test   %eax,%eax
f0101e64:	74 19                	je     f0101e7f <mem_init+0xd6b>
f0101e66:	68 74 45 10 f0       	push   $0xf0104574
f0101e6b:	68 44 3d 10 f0       	push   $0xf0103d44
f0101e70:	68 5f 03 00 00       	push   $0x35f
f0101e75:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101e7a:	e8 0c e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101e7f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e84:	75 19                	jne    f0101e9f <mem_init+0xd8b>
f0101e86:	68 8c 3f 10 f0       	push   $0xf0103f8c
f0101e8b:	68 44 3d 10 f0       	push   $0xf0103d44
f0101e90:	68 60 03 00 00       	push   $0x360
f0101e95:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101e9a:	e8 ec e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101e9f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ea2:	74 19                	je     f0101ebd <mem_init+0xda9>
f0101ea4:	68 98 3f 10 f0       	push   $0xf0103f98
f0101ea9:	68 44 3d 10 f0       	push   $0xf0103d44
f0101eae:	68 61 03 00 00       	push   $0x361
f0101eb3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101eb8:	e8 ce e1 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ebd:	83 ec 08             	sub    $0x8,%esp
f0101ec0:	68 00 10 00 00       	push   $0x1000
f0101ec5:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101ecb:	e8 85 f1 ff ff       	call   f0101055 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ed0:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101ed6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101edb:	89 f8                	mov    %edi,%eax
f0101edd:	e8 c2 ea ff ff       	call   f01009a4 <check_va2pa>
f0101ee2:	83 c4 10             	add    $0x10,%esp
f0101ee5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ee8:	74 19                	je     f0101f03 <mem_init+0xdef>
f0101eea:	68 50 45 10 f0       	push   $0xf0104550
f0101eef:	68 44 3d 10 f0       	push   $0xf0103d44
f0101ef4:	68 65 03 00 00       	push   $0x365
f0101ef9:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101efe:	e8 88 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f08:	89 f8                	mov    %edi,%eax
f0101f0a:	e8 95 ea ff ff       	call   f01009a4 <check_va2pa>
f0101f0f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f12:	74 19                	je     f0101f2d <mem_init+0xe19>
f0101f14:	68 ac 45 10 f0       	push   $0xf01045ac
f0101f19:	68 44 3d 10 f0       	push   $0xf0103d44
f0101f1e:	68 66 03 00 00       	push   $0x366
f0101f23:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101f28:	e8 5e e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101f2d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f32:	74 19                	je     f0101f4d <mem_init+0xe39>
f0101f34:	68 ad 3f 10 f0       	push   $0xf0103fad
f0101f39:	68 44 3d 10 f0       	push   $0xf0103d44
f0101f3e:	68 67 03 00 00       	push   $0x367
f0101f43:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101f48:	e8 3e e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101f4d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f52:	74 19                	je     f0101f6d <mem_init+0xe59>
f0101f54:	68 7b 3f 10 f0       	push   $0xf0103f7b
f0101f59:	68 44 3d 10 f0       	push   $0xf0103d44
f0101f5e:	68 68 03 00 00       	push   $0x368
f0101f63:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101f68:	e8 1e e1 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f6d:	83 ec 0c             	sub    $0xc,%esp
f0101f70:	6a 00                	push   $0x0
f0101f72:	e8 13 ee ff ff       	call   f0100d8a <page_alloc>
f0101f77:	83 c4 10             	add    $0x10,%esp
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	74 04                	je     f0101f82 <mem_init+0xe6e>
f0101f7e:	39 c3                	cmp    %eax,%ebx
f0101f80:	74 19                	je     f0101f9b <mem_init+0xe87>
f0101f82:	68 d4 45 10 f0       	push   $0xf01045d4
f0101f87:	68 44 3d 10 f0       	push   $0xf0103d44
f0101f8c:	68 6b 03 00 00       	push   $0x36b
f0101f91:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101f96:	e8 f0 e0 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f9b:	83 ec 0c             	sub    $0xc,%esp
f0101f9e:	6a 00                	push   $0x0
f0101fa0:	e8 e5 ed ff ff       	call   f0100d8a <page_alloc>
f0101fa5:	83 c4 10             	add    $0x10,%esp
f0101fa8:	85 c0                	test   %eax,%eax
f0101faa:	74 19                	je     f0101fc5 <mem_init+0xeb1>
f0101fac:	68 cf 3e 10 f0       	push   $0xf0103ecf
f0101fb1:	68 44 3d 10 f0       	push   $0xf0103d44
f0101fb6:	68 6e 03 00 00       	push   $0x36e
f0101fbb:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101fc0:	e8 c6 e0 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fc5:	8b 0d 88 79 11 f0    	mov    0xf0117988,%ecx
f0101fcb:	8b 11                	mov    (%ecx),%edx
f0101fcd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd6:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101fdc:	c1 f8 03             	sar    $0x3,%eax
f0101fdf:	c1 e0 0c             	shl    $0xc,%eax
f0101fe2:	39 c2                	cmp    %eax,%edx
f0101fe4:	74 19                	je     f0101fff <mem_init+0xeeb>
f0101fe6:	68 78 42 10 f0       	push   $0xf0104278
f0101feb:	68 44 3d 10 f0       	push   $0xf0103d44
f0101ff0:	68 71 03 00 00       	push   $0x371
f0101ff5:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101ffa:	e8 8c e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101fff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102005:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102008:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010200d:	74 19                	je     f0102028 <mem_init+0xf14>
f010200f:	68 32 3f 10 f0       	push   $0xf0103f32
f0102014:	68 44 3d 10 f0       	push   $0xf0103d44
f0102019:	68 73 03 00 00       	push   $0x373
f010201e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102023:	e8 63 e0 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102028:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010202b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102031:	83 ec 0c             	sub    $0xc,%esp
f0102034:	50                   	push   %eax
f0102035:	e8 be ed ff ff       	call   f0100df8 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010203a:	83 c4 0c             	add    $0xc,%esp
f010203d:	6a 01                	push   $0x1
f010203f:	68 00 10 40 00       	push   $0x401000
f0102044:	ff 35 88 79 11 f0    	pushl  0xf0117988
f010204a:	e8 0f ee ff ff       	call   f0100e5e <pgdir_walk>
f010204f:	89 c7                	mov    %eax,%edi
f0102051:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102054:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102059:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010205c:	8b 40 04             	mov    0x4(%eax),%eax
f010205f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102064:	8b 0d 84 79 11 f0    	mov    0xf0117984,%ecx
f010206a:	89 c2                	mov    %eax,%edx
f010206c:	c1 ea 0c             	shr    $0xc,%edx
f010206f:	83 c4 10             	add    $0x10,%esp
f0102072:	39 ca                	cmp    %ecx,%edx
f0102074:	72 15                	jb     f010208b <mem_init+0xf77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102076:	50                   	push   %eax
f0102077:	68 38 40 10 f0       	push   $0xf0104038
f010207c:	68 7a 03 00 00       	push   $0x37a
f0102081:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102086:	e8 00 e0 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010208b:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102090:	39 c7                	cmp    %eax,%edi
f0102092:	74 19                	je     f01020ad <mem_init+0xf99>
f0102094:	68 be 3f 10 f0       	push   $0xf0103fbe
f0102099:	68 44 3d 10 f0       	push   $0xf0103d44
f010209e:	68 7b 03 00 00       	push   $0x37b
f01020a3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01020a8:	e8 de df ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020b0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ba:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020c0:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01020c6:	c1 f8 03             	sar    $0x3,%eax
f01020c9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020cc:	89 c2                	mov    %eax,%edx
f01020ce:	c1 ea 0c             	shr    $0xc,%edx
f01020d1:	39 d1                	cmp    %edx,%ecx
f01020d3:	77 12                	ja     f01020e7 <mem_init+0xfd3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020d5:	50                   	push   %eax
f01020d6:	68 38 40 10 f0       	push   $0xf0104038
f01020db:	6a 52                	push   $0x52
f01020dd:	68 2a 3d 10 f0       	push   $0xf0103d2a
f01020e2:	e8 a4 df ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020e7:	83 ec 04             	sub    $0x4,%esp
f01020ea:	68 00 10 00 00       	push   $0x1000
f01020ef:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020f9:	50                   	push   %eax
f01020fa:	e8 e9 11 00 00       	call   f01032e8 <memset>
	page_free(pp0);
f01020ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102102:	89 3c 24             	mov    %edi,(%esp)
f0102105:	e8 ee ec ff ff       	call   f0100df8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010210a:	83 c4 0c             	add    $0xc,%esp
f010210d:	6a 01                	push   $0x1
f010210f:	6a 00                	push   $0x0
f0102111:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0102117:	e8 42 ed ff ff       	call   f0100e5e <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010211c:	89 fa                	mov    %edi,%edx
f010211e:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0102124:	c1 fa 03             	sar    $0x3,%edx
f0102127:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010212a:	89 d0                	mov    %edx,%eax
f010212c:	c1 e8 0c             	shr    $0xc,%eax
f010212f:	83 c4 10             	add    $0x10,%esp
f0102132:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0102138:	72 12                	jb     f010214c <mem_init+0x1038>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010213a:	52                   	push   %edx
f010213b:	68 38 40 10 f0       	push   $0xf0104038
f0102140:	6a 52                	push   $0x52
f0102142:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0102147:	e8 3f df ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010214c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102152:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102155:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010215b:	f6 00 01             	testb  $0x1,(%eax)
f010215e:	74 19                	je     f0102179 <mem_init+0x1065>
f0102160:	68 d6 3f 10 f0       	push   $0xf0103fd6
f0102165:	68 44 3d 10 f0       	push   $0xf0103d44
f010216a:	68 85 03 00 00       	push   $0x385
f010216f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102174:	e8 12 df ff ff       	call   f010008b <_panic>
f0102179:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010217c:	39 d0                	cmp    %edx,%eax
f010217e:	75 db                	jne    f010215b <mem_init+0x1047>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102180:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102185:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010218b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102194:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102197:	89 0d 5c 75 11 f0    	mov    %ecx,0xf011755c

	// free the pages we took
	page_free(pp0);
f010219d:	83 ec 0c             	sub    $0xc,%esp
f01021a0:	50                   	push   %eax
f01021a1:	e8 52 ec ff ff       	call   f0100df8 <page_free>
	page_free(pp1);
f01021a6:	89 1c 24             	mov    %ebx,(%esp)
f01021a9:	e8 4a ec ff ff       	call   f0100df8 <page_free>
	page_free(pp2);
f01021ae:	89 34 24             	mov    %esi,(%esp)
f01021b1:	e8 42 ec ff ff       	call   f0100df8 <page_free>

	cprintf("check_page() succeeded!\n");
f01021b6:	c7 04 24 ed 3f 10 f0 	movl   $0xf0103fed,(%esp)
f01021bd:	e8 3a 06 00 00       	call   f01027fc <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01021c2:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021c7:	83 c4 10             	add    $0x10,%esp
f01021ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021cf:	77 15                	ja     f01021e6 <mem_init+0x10d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021d1:	50                   	push   %eax
f01021d2:	68 20 41 10 f0       	push   $0xf0104120
f01021d7:	68 c0 00 00 00       	push   $0xc0
f01021dc:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01021e1:	e8 a5 de ff ff       	call   f010008b <_panic>
f01021e6:	83 ec 08             	sub    $0x8,%esp
f01021e9:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01021eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01021f0:	50                   	push   %eax
f01021f1:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01021f6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021fb:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102200:	e8 36 ed ff ff       	call   f0100f3b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102205:	83 c4 10             	add    $0x10,%esp
f0102208:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f010220d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102212:	77 15                	ja     f0102229 <mem_init+0x1115>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102214:	50                   	push   %eax
f0102215:	68 20 41 10 f0       	push   $0xf0104120
f010221a:	68 cc 00 00 00       	push   $0xcc
f010221f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102224:	e8 62 de ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102229:	83 ec 08             	sub    $0x8,%esp
f010222c:	6a 02                	push   $0x2
f010222e:	68 00 d0 10 00       	push   $0x10d000
f0102233:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102238:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010223d:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102242:	e8 f4 ec ff ff       	call   f0100f3b <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102247:	83 c4 08             	add    $0x8,%esp
f010224a:	6a 02                	push   $0x2
f010224c:	6a 00                	push   $0x0
f010224e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102253:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102258:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f010225d:	e8 d9 ec ff ff       	call   f0100f3b <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102262:	8b 35 88 79 11 f0    	mov    0xf0117988,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102268:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f010226d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102270:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102277:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010227c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010227f:	8b 3d 8c 79 11 f0    	mov    0xf011798c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102285:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102288:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010228b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102290:	eb 55                	jmp    f01022e7 <mem_init+0x11d3>
f0102292:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102298:	89 f0                	mov    %esi,%eax
f010229a:	e8 05 e7 ff ff       	call   f01009a4 <check_va2pa>
f010229f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022a6:	77 15                	ja     f01022bd <mem_init+0x11a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022a8:	57                   	push   %edi
f01022a9:	68 20 41 10 f0       	push   $0xf0104120
f01022ae:	68 c7 02 00 00       	push   $0x2c7
f01022b3:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01022b8:	e8 ce dd ff ff       	call   f010008b <_panic>
f01022bd:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01022c4:	39 c2                	cmp    %eax,%edx
f01022c6:	74 19                	je     f01022e1 <mem_init+0x11cd>
f01022c8:	68 f8 45 10 f0       	push   $0xf01045f8
f01022cd:	68 44 3d 10 f0       	push   $0xf0103d44
f01022d2:	68 c7 02 00 00       	push   $0x2c7
f01022d7:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01022dc:	e8 aa dd ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022e7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01022ea:	77 a6                	ja     f0102292 <mem_init+0x117e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01022ef:	c1 e7 0c             	shl    $0xc,%edi
f01022f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022f7:	eb 30                	jmp    f0102329 <mem_init+0x1215>
f01022f9:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01022ff:	89 f0                	mov    %esi,%eax
f0102301:	e8 9e e6 ff ff       	call   f01009a4 <check_va2pa>
f0102306:	39 c3                	cmp    %eax,%ebx
f0102308:	74 19                	je     f0102323 <mem_init+0x120f>
f010230a:	68 2c 46 10 f0       	push   $0xf010462c
f010230f:	68 44 3d 10 f0       	push   $0xf0103d44
f0102314:	68 cc 02 00 00       	push   $0x2cc
f0102319:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010231e:	e8 68 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102323:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102329:	39 fb                	cmp    %edi,%ebx
f010232b:	72 cc                	jb     f01022f9 <mem_init+0x11e5>
f010232d:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102332:	89 da                	mov    %ebx,%edx
f0102334:	89 f0                	mov    %esi,%eax
f0102336:	e8 69 e6 ff ff       	call   f01009a4 <check_va2pa>
f010233b:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102341:	39 c2                	cmp    %eax,%edx
f0102343:	74 19                	je     f010235e <mem_init+0x124a>
f0102345:	68 54 46 10 f0       	push   $0xf0104654
f010234a:	68 44 3d 10 f0       	push   $0xf0103d44
f010234f:	68 d0 02 00 00       	push   $0x2d0
f0102354:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102359:	e8 2d dd ff ff       	call   f010008b <_panic>
f010235e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102364:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010236a:	75 c6                	jne    f0102332 <mem_init+0x121e>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010236c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102371:	89 f0                	mov    %esi,%eax
f0102373:	e8 2c e6 ff ff       	call   f01009a4 <check_va2pa>
f0102378:	83 f8 ff             	cmp    $0xffffffff,%eax
f010237b:	74 51                	je     f01023ce <mem_init+0x12ba>
f010237d:	68 9c 46 10 f0       	push   $0xf010469c
f0102382:	68 44 3d 10 f0       	push   $0xf0103d44
f0102387:	68 d1 02 00 00       	push   $0x2d1
f010238c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102391:	e8 f5 dc ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102396:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010239b:	72 36                	jb     f01023d3 <mem_init+0x12bf>
f010239d:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01023a2:	76 07                	jbe    f01023ab <mem_init+0x1297>
f01023a4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023a9:	75 28                	jne    f01023d3 <mem_init+0x12bf>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01023ab:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01023af:	0f 85 83 00 00 00    	jne    f0102438 <mem_init+0x1324>
f01023b5:	68 06 40 10 f0       	push   $0xf0104006
f01023ba:	68 44 3d 10 f0       	push   $0xf0103d44
f01023bf:	68 d9 02 00 00       	push   $0x2d9
f01023c4:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01023c9:	e8 bd dc ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023ce:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01023d3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023d8:	76 3f                	jbe    f0102419 <mem_init+0x1305>
				assert(pgdir[i] & PTE_P);
f01023da:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01023dd:	f6 c2 01             	test   $0x1,%dl
f01023e0:	75 19                	jne    f01023fb <mem_init+0x12e7>
f01023e2:	68 06 40 10 f0       	push   $0xf0104006
f01023e7:	68 44 3d 10 f0       	push   $0xf0103d44
f01023ec:	68 dd 02 00 00       	push   $0x2dd
f01023f1:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01023f6:	e8 90 dc ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01023fb:	f6 c2 02             	test   $0x2,%dl
f01023fe:	75 38                	jne    f0102438 <mem_init+0x1324>
f0102400:	68 17 40 10 f0       	push   $0xf0104017
f0102405:	68 44 3d 10 f0       	push   $0xf0103d44
f010240a:	68 de 02 00 00       	push   $0x2de
f010240f:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102414:	e8 72 dc ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102419:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010241d:	74 19                	je     f0102438 <mem_init+0x1324>
f010241f:	68 28 40 10 f0       	push   $0xf0104028
f0102424:	68 44 3d 10 f0       	push   $0xf0103d44
f0102429:	68 e0 02 00 00       	push   $0x2e0
f010242e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102433:	e8 53 dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102438:	83 c0 01             	add    $0x1,%eax
f010243b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102440:	0f 86 50 ff ff ff    	jbe    f0102396 <mem_init+0x1282>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102446:	83 ec 0c             	sub    $0xc,%esp
f0102449:	68 cc 46 10 f0       	push   $0xf01046cc
f010244e:	e8 a9 03 00 00       	call   f01027fc <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102453:	a1 88 79 11 f0       	mov    0xf0117988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102458:	83 c4 10             	add    $0x10,%esp
f010245b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102460:	77 15                	ja     f0102477 <mem_init+0x1363>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102462:	50                   	push   %eax
f0102463:	68 20 41 10 f0       	push   $0xf0104120
f0102468:	68 e0 00 00 00       	push   $0xe0
f010246d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102472:	e8 14 dc ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102477:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010247c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010247f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102484:	e8 7f e5 ff ff       	call   f0100a08 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102489:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010248c:	83 e0 f3             	and    $0xfffffff3,%eax
f010248f:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102494:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102497:	83 ec 0c             	sub    $0xc,%esp
f010249a:	6a 00                	push   $0x0
f010249c:	e8 e9 e8 ff ff       	call   f0100d8a <page_alloc>
f01024a1:	89 c3                	mov    %eax,%ebx
f01024a3:	83 c4 10             	add    $0x10,%esp
f01024a6:	85 c0                	test   %eax,%eax
f01024a8:	75 19                	jne    f01024c3 <mem_init+0x13af>
f01024aa:	68 24 3e 10 f0       	push   $0xf0103e24
f01024af:	68 44 3d 10 f0       	push   $0xf0103d44
f01024b4:	68 a0 03 00 00       	push   $0x3a0
f01024b9:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01024be:	e8 c8 db ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01024c3:	83 ec 0c             	sub    $0xc,%esp
f01024c6:	6a 00                	push   $0x0
f01024c8:	e8 bd e8 ff ff       	call   f0100d8a <page_alloc>
f01024cd:	89 c7                	mov    %eax,%edi
f01024cf:	83 c4 10             	add    $0x10,%esp
f01024d2:	85 c0                	test   %eax,%eax
f01024d4:	75 19                	jne    f01024ef <mem_init+0x13db>
f01024d6:	68 3a 3e 10 f0       	push   $0xf0103e3a
f01024db:	68 44 3d 10 f0       	push   $0xf0103d44
f01024e0:	68 a1 03 00 00       	push   $0x3a1
f01024e5:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01024ea:	e8 9c db ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01024ef:	83 ec 0c             	sub    $0xc,%esp
f01024f2:	6a 00                	push   $0x0
f01024f4:	e8 91 e8 ff ff       	call   f0100d8a <page_alloc>
f01024f9:	89 c6                	mov    %eax,%esi
f01024fb:	83 c4 10             	add    $0x10,%esp
f01024fe:	85 c0                	test   %eax,%eax
f0102500:	75 19                	jne    f010251b <mem_init+0x1407>
f0102502:	68 50 3e 10 f0       	push   $0xf0103e50
f0102507:	68 44 3d 10 f0       	push   $0xf0103d44
f010250c:	68 a2 03 00 00       	push   $0x3a2
f0102511:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102516:	e8 70 db ff ff       	call   f010008b <_panic>
	page_free(pp0);
f010251b:	83 ec 0c             	sub    $0xc,%esp
f010251e:	53                   	push   %ebx
f010251f:	e8 d4 e8 ff ff       	call   f0100df8 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102524:	89 f8                	mov    %edi,%eax
f0102526:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010252c:	c1 f8 03             	sar    $0x3,%eax
f010252f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102532:	89 c2                	mov    %eax,%edx
f0102534:	c1 ea 0c             	shr    $0xc,%edx
f0102537:	83 c4 10             	add    $0x10,%esp
f010253a:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0102540:	72 12                	jb     f0102554 <mem_init+0x1440>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102542:	50                   	push   %eax
f0102543:	68 38 40 10 f0       	push   $0xf0104038
f0102548:	6a 52                	push   $0x52
f010254a:	68 2a 3d 10 f0       	push   $0xf0103d2a
f010254f:	e8 37 db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102554:	83 ec 04             	sub    $0x4,%esp
f0102557:	68 00 10 00 00       	push   $0x1000
f010255c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010255e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102563:	50                   	push   %eax
f0102564:	e8 7f 0d 00 00       	call   f01032e8 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102569:	89 f0                	mov    %esi,%eax
f010256b:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0102571:	c1 f8 03             	sar    $0x3,%eax
f0102574:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102577:	89 c2                	mov    %eax,%edx
f0102579:	c1 ea 0c             	shr    $0xc,%edx
f010257c:	83 c4 10             	add    $0x10,%esp
f010257f:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0102585:	72 12                	jb     f0102599 <mem_init+0x1485>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102587:	50                   	push   %eax
f0102588:	68 38 40 10 f0       	push   $0xf0104038
f010258d:	6a 52                	push   $0x52
f010258f:	68 2a 3d 10 f0       	push   $0xf0103d2a
f0102594:	e8 f2 da ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102599:	83 ec 04             	sub    $0x4,%esp
f010259c:	68 00 10 00 00       	push   $0x1000
f01025a1:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01025a3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025a8:	50                   	push   %eax
f01025a9:	e8 3a 0d 00 00       	call   f01032e8 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025ae:	6a 02                	push   $0x2
f01025b0:	68 00 10 00 00       	push   $0x1000
f01025b5:	57                   	push   %edi
f01025b6:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01025bc:	e8 e5 ea ff ff       	call   f01010a6 <page_insert>
	assert(pp1->pp_ref == 1);
f01025c1:	83 c4 20             	add    $0x20,%esp
f01025c4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025c9:	74 19                	je     f01025e4 <mem_init+0x14d0>
f01025cb:	68 21 3f 10 f0       	push   $0xf0103f21
f01025d0:	68 44 3d 10 f0       	push   $0xf0103d44
f01025d5:	68 a7 03 00 00       	push   $0x3a7
f01025da:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01025df:	e8 a7 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025e4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025eb:	01 01 01 
f01025ee:	74 19                	je     f0102609 <mem_init+0x14f5>
f01025f0:	68 ec 46 10 f0       	push   $0xf01046ec
f01025f5:	68 44 3d 10 f0       	push   $0xf0103d44
f01025fa:	68 a8 03 00 00       	push   $0x3a8
f01025ff:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102604:	e8 82 da ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102609:	6a 02                	push   $0x2
f010260b:	68 00 10 00 00       	push   $0x1000
f0102610:	56                   	push   %esi
f0102611:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0102617:	e8 8a ea ff ff       	call   f01010a6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010261c:	83 c4 10             	add    $0x10,%esp
f010261f:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102626:	02 02 02 
f0102629:	74 19                	je     f0102644 <mem_init+0x1530>
f010262b:	68 10 47 10 f0       	push   $0xf0104710
f0102630:	68 44 3d 10 f0       	push   $0xf0103d44
f0102635:	68 aa 03 00 00       	push   $0x3aa
f010263a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010263f:	e8 47 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102644:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102649:	74 19                	je     f0102664 <mem_init+0x1550>
f010264b:	68 43 3f 10 f0       	push   $0xf0103f43
f0102650:	68 44 3d 10 f0       	push   $0xf0103d44
f0102655:	68 ab 03 00 00       	push   $0x3ab
f010265a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010265f:	e8 27 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102664:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102669:	74 19                	je     f0102684 <mem_init+0x1570>
f010266b:	68 ad 3f 10 f0       	push   $0xf0103fad
f0102670:	68 44 3d 10 f0       	push   $0xf0103d44
f0102675:	68 ac 03 00 00       	push   $0x3ac
f010267a:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010267f:	e8 07 da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102684:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010268b:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010268e:	89 f0                	mov    %esi,%eax
f0102690:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0102696:	c1 f8 03             	sar    $0x3,%eax
f0102699:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010269c:	89 c2                	mov    %eax,%edx
f010269e:	c1 ea 0c             	shr    $0xc,%edx
f01026a1:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f01026a7:	72 12                	jb     f01026bb <mem_init+0x15a7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026a9:	50                   	push   %eax
f01026aa:	68 38 40 10 f0       	push   $0xf0104038
f01026af:	6a 52                	push   $0x52
f01026b1:	68 2a 3d 10 f0       	push   $0xf0103d2a
f01026b6:	e8 d0 d9 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01026bb:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01026c2:	03 03 03 
f01026c5:	74 19                	je     f01026e0 <mem_init+0x15cc>
f01026c7:	68 34 47 10 f0       	push   $0xf0104734
f01026cc:	68 44 3d 10 f0       	push   $0xf0103d44
f01026d1:	68 ae 03 00 00       	push   $0x3ae
f01026d6:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01026db:	e8 ab d9 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026e0:	83 ec 08             	sub    $0x8,%esp
f01026e3:	68 00 10 00 00       	push   $0x1000
f01026e8:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01026ee:	e8 62 e9 ff ff       	call   f0101055 <page_remove>
	assert(pp2->pp_ref == 0);
f01026f3:	83 c4 10             	add    $0x10,%esp
f01026f6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026fb:	74 19                	je     f0102716 <mem_init+0x1602>
f01026fd:	68 7b 3f 10 f0       	push   $0xf0103f7b
f0102702:	68 44 3d 10 f0       	push   $0xf0103d44
f0102707:	68 b0 03 00 00       	push   $0x3b0
f010270c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102711:	e8 75 d9 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102716:	8b 0d 88 79 11 f0    	mov    0xf0117988,%ecx
f010271c:	8b 11                	mov    (%ecx),%edx
f010271e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102724:	89 d8                	mov    %ebx,%eax
f0102726:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010272c:	c1 f8 03             	sar    $0x3,%eax
f010272f:	c1 e0 0c             	shl    $0xc,%eax
f0102732:	39 c2                	cmp    %eax,%edx
f0102734:	74 19                	je     f010274f <mem_init+0x163b>
f0102736:	68 78 42 10 f0       	push   $0xf0104278
f010273b:	68 44 3d 10 f0       	push   $0xf0103d44
f0102740:	68 b3 03 00 00       	push   $0x3b3
f0102745:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010274a:	e8 3c d9 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f010274f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102755:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010275a:	74 19                	je     f0102775 <mem_init+0x1661>
f010275c:	68 32 3f 10 f0       	push   $0xf0103f32
f0102761:	68 44 3d 10 f0       	push   $0xf0103d44
f0102766:	68 b5 03 00 00       	push   $0x3b5
f010276b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102770:	e8 16 d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102775:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010277b:	83 ec 0c             	sub    $0xc,%esp
f010277e:	53                   	push   %ebx
f010277f:	e8 74 e6 ff ff       	call   f0100df8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102784:	c7 04 24 60 47 10 f0 	movl   $0xf0104760,(%esp)
f010278b:	e8 6c 00 00 00       	call   f01027fc <cprintf>
f0102790:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102793:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102796:	5b                   	pop    %ebx
f0102797:	5e                   	pop    %esi
f0102798:	5f                   	pop    %edi
f0102799:	5d                   	pop    %ebp
f010279a:	c3                   	ret    

f010279b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010279b:	55                   	push   %ebp
f010279c:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010279e:	ba 70 00 00 00       	mov    $0x70,%edx
f01027a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01027a6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01027a7:	b2 71                	mov    $0x71,%dl
f01027a9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01027aa:	0f b6 c0             	movzbl %al,%eax
}
f01027ad:	5d                   	pop    %ebp
f01027ae:	c3                   	ret    

f01027af <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01027af:	55                   	push   %ebp
f01027b0:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01027b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01027b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01027ba:	ee                   	out    %al,(%dx)
f01027bb:	b2 71                	mov    $0x71,%dl
f01027bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027c0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01027c1:	5d                   	pop    %ebp
f01027c2:	c3                   	ret    

f01027c3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01027c3:	55                   	push   %ebp
f01027c4:	89 e5                	mov    %esp,%ebp
f01027c6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01027c9:	ff 75 08             	pushl  0x8(%ebp)
f01027cc:	e8 0f de ff ff       	call   f01005e0 <cputchar>
f01027d1:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01027d4:	c9                   	leave  
f01027d5:	c3                   	ret    

f01027d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01027d6:	55                   	push   %ebp
f01027d7:	89 e5                	mov    %esp,%ebp
f01027d9:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01027dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01027e3:	ff 75 0c             	pushl  0xc(%ebp)
f01027e6:	ff 75 08             	pushl  0x8(%ebp)
f01027e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01027ec:	50                   	push   %eax
f01027ed:	68 c3 27 10 f0       	push   $0xf01027c3
f01027f2:	e8 7e 04 00 00       	call   f0102c75 <vprintfmt>
	return cnt;
}
f01027f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027fa:	c9                   	leave  
f01027fb:	c3                   	ret    

f01027fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01027fc:	55                   	push   %ebp
f01027fd:	89 e5                	mov    %esp,%ebp
f01027ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102802:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102805:	50                   	push   %eax
f0102806:	ff 75 08             	pushl  0x8(%ebp)
f0102809:	e8 c8 ff ff ff       	call   f01027d6 <vcprintf>
	va_end(ap);

	return cnt;
}
f010280e:	c9                   	leave  
f010280f:	c3                   	ret    

f0102810 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102810:	55                   	push   %ebp
f0102811:	89 e5                	mov    %esp,%ebp
f0102813:	57                   	push   %edi
f0102814:	56                   	push   %esi
f0102815:	53                   	push   %ebx
f0102816:	83 ec 14             	sub    $0x14,%esp
f0102819:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010281c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010281f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102822:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102825:	8b 1a                	mov    (%edx),%ebx
f0102827:	8b 01                	mov    (%ecx),%eax
f0102829:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010282c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102833:	e9 88 00 00 00       	jmp    f01028c0 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0102838:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010283b:	01 d8                	add    %ebx,%eax
f010283d:	89 c6                	mov    %eax,%esi
f010283f:	c1 ee 1f             	shr    $0x1f,%esi
f0102842:	01 c6                	add    %eax,%esi
f0102844:	d1 fe                	sar    %esi
f0102846:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0102849:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010284c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010284f:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102851:	eb 03                	jmp    f0102856 <stab_binsearch+0x46>
			m--;
f0102853:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102856:	39 c3                	cmp    %eax,%ebx
f0102858:	7f 1f                	jg     f0102879 <stab_binsearch+0x69>
f010285a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010285e:	83 ea 0c             	sub    $0xc,%edx
f0102861:	39 f9                	cmp    %edi,%ecx
f0102863:	75 ee                	jne    f0102853 <stab_binsearch+0x43>
f0102865:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102868:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010286b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010286e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102872:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102875:	76 18                	jbe    f010288f <stab_binsearch+0x7f>
f0102877:	eb 05                	jmp    f010287e <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102879:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010287c:	eb 42                	jmp    f01028c0 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010287e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102881:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102883:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102886:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010288d:	eb 31                	jmp    f01028c0 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010288f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102892:	73 17                	jae    f01028ab <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102894:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102897:	83 e8 01             	sub    $0x1,%eax
f010289a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010289d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028a0:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01028a2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01028a9:	eb 15                	jmp    f01028c0 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01028ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028ae:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01028b1:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f01028b3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01028b7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01028b9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01028c0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01028c3:	0f 8e 6f ff ff ff    	jle    f0102838 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01028c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01028cd:	75 0f                	jne    f01028de <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01028cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028d2:	8b 00                	mov    (%eax),%eax
f01028d4:	83 e8 01             	sub    $0x1,%eax
f01028d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028da:	89 06                	mov    %eax,(%esi)
f01028dc:	eb 2c                	jmp    f010290a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028de:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028e1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01028e3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028e6:	8b 0e                	mov    (%esi),%ecx
f01028e8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01028eb:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01028ee:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028f1:	eb 03                	jmp    f01028f6 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01028f3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028f6:	39 c8                	cmp    %ecx,%eax
f01028f8:	7e 0b                	jle    f0102905 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01028fa:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01028fe:	83 ea 0c             	sub    $0xc,%edx
f0102901:	39 fb                	cmp    %edi,%ebx
f0102903:	75 ee                	jne    f01028f3 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102905:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102908:	89 06                	mov    %eax,(%esi)
	}
}
f010290a:	83 c4 14             	add    $0x14,%esp
f010290d:	5b                   	pop    %ebx
f010290e:	5e                   	pop    %esi
f010290f:	5f                   	pop    %edi
f0102910:	5d                   	pop    %ebp
f0102911:	c3                   	ret    

f0102912 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102912:	55                   	push   %ebp
f0102913:	89 e5                	mov    %esp,%ebp
f0102915:	57                   	push   %edi
f0102916:	56                   	push   %esi
f0102917:	53                   	push   %ebx
f0102918:	83 ec 3c             	sub    $0x3c,%esp
f010291b:	8b 75 08             	mov    0x8(%ebp),%esi
f010291e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102921:	c7 03 8c 47 10 f0    	movl   $0xf010478c,(%ebx)
	info->eip_line = 0;
f0102927:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010292e:	c7 43 08 8c 47 10 f0 	movl   $0xf010478c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102935:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010293c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010293f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102946:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010294c:	76 11                	jbe    f010295f <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010294e:	b8 d7 c5 10 f0       	mov    $0xf010c5d7,%eax
f0102953:	3d 51 a8 10 f0       	cmp    $0xf010a851,%eax
f0102958:	77 19                	ja     f0102973 <debuginfo_eip+0x61>
f010295a:	e9 a9 01 00 00       	jmp    f0102b08 <debuginfo_eip+0x1f6>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010295f:	83 ec 04             	sub    $0x4,%esp
f0102962:	68 96 47 10 f0       	push   $0xf0104796
f0102967:	6a 7f                	push   $0x7f
f0102969:	68 a3 47 10 f0       	push   $0xf01047a3
f010296e:	e8 18 d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102973:	80 3d d6 c5 10 f0 00 	cmpb   $0x0,0xf010c5d6
f010297a:	0f 85 8f 01 00 00    	jne    f0102b0f <debuginfo_eip+0x1fd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102980:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102987:	b8 50 a8 10 f0       	mov    $0xf010a850,%eax
f010298c:	2d d0 49 10 f0       	sub    $0xf01049d0,%eax
f0102991:	c1 f8 02             	sar    $0x2,%eax
f0102994:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010299a:	83 e8 01             	sub    $0x1,%eax
f010299d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01029a0:	83 ec 08             	sub    $0x8,%esp
f01029a3:	56                   	push   %esi
f01029a4:	6a 64                	push   $0x64
f01029a6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01029a9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01029ac:	b8 d0 49 10 f0       	mov    $0xf01049d0,%eax
f01029b1:	e8 5a fe ff ff       	call   f0102810 <stab_binsearch>
	if (lfile == 0)
f01029b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029b9:	83 c4 10             	add    $0x10,%esp
f01029bc:	85 c0                	test   %eax,%eax
f01029be:	0f 84 52 01 00 00    	je     f0102b16 <debuginfo_eip+0x204>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01029c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01029c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01029cd:	83 ec 08             	sub    $0x8,%esp
f01029d0:	56                   	push   %esi
f01029d1:	6a 24                	push   $0x24
f01029d3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01029d6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01029d9:	b8 d0 49 10 f0       	mov    $0xf01049d0,%eax
f01029de:	e8 2d fe ff ff       	call   f0102810 <stab_binsearch>

	if (lfun <= rfun) {
f01029e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029e9:	83 c4 10             	add    $0x10,%esp
f01029ec:	39 d0                	cmp    %edx,%eax
f01029ee:	7f 40                	jg     f0102a30 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01029f0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01029f3:	c1 e1 02             	shl    $0x2,%ecx
f01029f6:	8d b9 d0 49 10 f0    	lea    -0xfefb630(%ecx),%edi
f01029fc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029ff:	8b b9 d0 49 10 f0    	mov    -0xfefb630(%ecx),%edi
f0102a05:	b9 d7 c5 10 f0       	mov    $0xf010c5d7,%ecx
f0102a0a:	81 e9 51 a8 10 f0    	sub    $0xf010a851,%ecx
f0102a10:	39 cf                	cmp    %ecx,%edi
f0102a12:	73 09                	jae    f0102a1d <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102a14:	81 c7 51 a8 10 f0    	add    $0xf010a851,%edi
f0102a1a:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102a1d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102a20:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102a23:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102a26:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102a28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102a2b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102a2e:	eb 0f                	jmp    f0102a3f <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102a30:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102a39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102a3f:	83 ec 08             	sub    $0x8,%esp
f0102a42:	6a 3a                	push   $0x3a
f0102a44:	ff 73 08             	pushl  0x8(%ebx)
f0102a47:	e8 80 08 00 00       	call   f01032cc <strfind>
f0102a4c:	2b 43 08             	sub    0x8(%ebx),%eax
f0102a4f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102a52:	83 c4 08             	add    $0x8,%esp
f0102a55:	56                   	push   %esi
f0102a56:	6a 44                	push   $0x44
f0102a58:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102a5b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102a5e:	b8 d0 49 10 f0       	mov    $0xf01049d0,%eax
f0102a63:	e8 a8 fd ff ff       	call   f0102810 <stab_binsearch>
        if(lline <= rline)
f0102a68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a6b:	83 c4 10             	add    $0x10,%esp
f0102a6e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0102a71:	0f 8f a6 00 00 00    	jg     f0102b1d <debuginfo_eip+0x20b>
              info->eip_line = stabs[lline].n_desc;
f0102a77:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a7a:	0f b7 04 85 d6 49 10 	movzwl -0xfefb62a(,%eax,4),%eax
f0102a81:	f0 
f0102a82:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102a88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a8b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102a8e:	8d 14 95 d0 49 10 f0 	lea    -0xfefb630(,%edx,4),%edx
f0102a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102a98:	eb 06                	jmp    f0102aa0 <debuginfo_eip+0x18e>
f0102a9a:	83 e8 01             	sub    $0x1,%eax
f0102a9d:	83 ea 0c             	sub    $0xc,%edx
f0102aa0:	39 c7                	cmp    %eax,%edi
f0102aa2:	7f 23                	jg     f0102ac7 <debuginfo_eip+0x1b5>
	       && stabs[lline].n_type != N_SOL
f0102aa4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102aa8:	80 f9 84             	cmp    $0x84,%cl
f0102aab:	74 7e                	je     f0102b2b <debuginfo_eip+0x219>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102aad:	80 f9 64             	cmp    $0x64,%cl
f0102ab0:	75 e8                	jne    f0102a9a <debuginfo_eip+0x188>
f0102ab2:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0102ab6:	74 e2                	je     f0102a9a <debuginfo_eip+0x188>
f0102ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102abb:	eb 71                	jmp    f0102b2e <debuginfo_eip+0x21c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102abd:	81 c2 51 a8 10 f0    	add    $0xf010a851,%edx
f0102ac3:	89 13                	mov    %edx,(%ebx)
f0102ac5:	eb 03                	jmp    f0102aca <debuginfo_eip+0x1b8>
f0102ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102aca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102acd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102ad0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ad5:	39 f2                	cmp    %esi,%edx
f0102ad7:	7d 76                	jge    f0102b4f <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
f0102ad9:	83 c2 01             	add    $0x1,%edx
f0102adc:	89 d0                	mov    %edx,%eax
f0102ade:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102ae1:	8d 14 95 d0 49 10 f0 	lea    -0xfefb630(,%edx,4),%edx
f0102ae8:	eb 04                	jmp    f0102aee <debuginfo_eip+0x1dc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102aea:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102aee:	39 c6                	cmp    %eax,%esi
f0102af0:	7e 32                	jle    f0102b24 <debuginfo_eip+0x212>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102af2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102af6:	83 c0 01             	add    $0x1,%eax
f0102af9:	83 c2 0c             	add    $0xc,%edx
f0102afc:	80 f9 a0             	cmp    $0xa0,%cl
f0102aff:	74 e9                	je     f0102aea <debuginfo_eip+0x1d8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b06:	eb 47                	jmp    f0102b4f <debuginfo_eip+0x23d>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b0d:	eb 40                	jmp    f0102b4f <debuginfo_eip+0x23d>
f0102b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b14:	eb 39                	jmp    f0102b4f <debuginfo_eip+0x23d>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b1b:	eb 32                	jmp    f0102b4f <debuginfo_eip+0x23d>
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if(lline <= rline)
              info->eip_line = stabs[lline].n_desc;
        else
              return -1;
f0102b1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b22:	eb 2b                	jmp    f0102b4f <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b24:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b29:	eb 24                	jmp    f0102b4f <debuginfo_eip+0x23d>
f0102b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102b2e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102b31:	8b 14 85 d0 49 10 f0 	mov    -0xfefb630(,%eax,4),%edx
f0102b38:	b8 d7 c5 10 f0       	mov    $0xf010c5d7,%eax
f0102b3d:	2d 51 a8 10 f0       	sub    $0xf010a851,%eax
f0102b42:	39 c2                	cmp    %eax,%edx
f0102b44:	0f 82 73 ff ff ff    	jb     f0102abd <debuginfo_eip+0x1ab>
f0102b4a:	e9 7b ff ff ff       	jmp    f0102aca <debuginfo_eip+0x1b8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0102b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b52:	5b                   	pop    %ebx
f0102b53:	5e                   	pop    %esi
f0102b54:	5f                   	pop    %edi
f0102b55:	5d                   	pop    %ebp
f0102b56:	c3                   	ret    

f0102b57 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102b57:	55                   	push   %ebp
f0102b58:	89 e5                	mov    %esp,%ebp
f0102b5a:	57                   	push   %edi
f0102b5b:	56                   	push   %esi
f0102b5c:	53                   	push   %ebx
f0102b5d:	83 ec 1c             	sub    $0x1c,%esp
f0102b60:	89 c7                	mov    %eax,%edi
f0102b62:	89 d6                	mov    %edx,%esi
f0102b64:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b67:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b6a:	89 d1                	mov    %edx,%ecx
f0102b6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b6f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102b72:	8b 45 10             	mov    0x10(%ebp),%eax
f0102b75:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102b78:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102b7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102b82:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0102b85:	72 05                	jb     f0102b8c <printnum+0x35>
f0102b87:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102b8a:	77 3e                	ja     f0102bca <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102b8c:	83 ec 0c             	sub    $0xc,%esp
f0102b8f:	ff 75 18             	pushl  0x18(%ebp)
f0102b92:	83 eb 01             	sub    $0x1,%ebx
f0102b95:	53                   	push   %ebx
f0102b96:	50                   	push   %eax
f0102b97:	83 ec 08             	sub    $0x8,%esp
f0102b9a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b9d:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ba0:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ba3:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ba6:	e8 45 09 00 00       	call   f01034f0 <__udivdi3>
f0102bab:	83 c4 18             	add    $0x18,%esp
f0102bae:	52                   	push   %edx
f0102baf:	50                   	push   %eax
f0102bb0:	89 f2                	mov    %esi,%edx
f0102bb2:	89 f8                	mov    %edi,%eax
f0102bb4:	e8 9e ff ff ff       	call   f0102b57 <printnum>
f0102bb9:	83 c4 20             	add    $0x20,%esp
f0102bbc:	eb 13                	jmp    f0102bd1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102bbe:	83 ec 08             	sub    $0x8,%esp
f0102bc1:	56                   	push   %esi
f0102bc2:	ff 75 18             	pushl  0x18(%ebp)
f0102bc5:	ff d7                	call   *%edi
f0102bc7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102bca:	83 eb 01             	sub    $0x1,%ebx
f0102bcd:	85 db                	test   %ebx,%ebx
f0102bcf:	7f ed                	jg     f0102bbe <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102bd1:	83 ec 08             	sub    $0x8,%esp
f0102bd4:	56                   	push   %esi
f0102bd5:	83 ec 04             	sub    $0x4,%esp
f0102bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102bdb:	ff 75 e0             	pushl  -0x20(%ebp)
f0102bde:	ff 75 dc             	pushl  -0x24(%ebp)
f0102be1:	ff 75 d8             	pushl  -0x28(%ebp)
f0102be4:	e8 37 0a 00 00       	call   f0103620 <__umoddi3>
f0102be9:	83 c4 14             	add    $0x14,%esp
f0102bec:	0f be 80 b1 47 10 f0 	movsbl -0xfefb84f(%eax),%eax
f0102bf3:	50                   	push   %eax
f0102bf4:	ff d7                	call   *%edi
f0102bf6:	83 c4 10             	add    $0x10,%esp
}
f0102bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bfc:	5b                   	pop    %ebx
f0102bfd:	5e                   	pop    %esi
f0102bfe:	5f                   	pop    %edi
f0102bff:	5d                   	pop    %ebp
f0102c00:	c3                   	ret    

f0102c01 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102c01:	55                   	push   %ebp
f0102c02:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102c04:	83 fa 01             	cmp    $0x1,%edx
f0102c07:	7e 0e                	jle    f0102c17 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102c09:	8b 10                	mov    (%eax),%edx
f0102c0b:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102c0e:	89 08                	mov    %ecx,(%eax)
f0102c10:	8b 02                	mov    (%edx),%eax
f0102c12:	8b 52 04             	mov    0x4(%edx),%edx
f0102c15:	eb 22                	jmp    f0102c39 <getuint+0x38>
	else if (lflag)
f0102c17:	85 d2                	test   %edx,%edx
f0102c19:	74 10                	je     f0102c2b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102c1b:	8b 10                	mov    (%eax),%edx
f0102c1d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c20:	89 08                	mov    %ecx,(%eax)
f0102c22:	8b 02                	mov    (%edx),%eax
f0102c24:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c29:	eb 0e                	jmp    f0102c39 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102c2b:	8b 10                	mov    (%eax),%edx
f0102c2d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c30:	89 08                	mov    %ecx,(%eax)
f0102c32:	8b 02                	mov    (%edx),%eax
f0102c34:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102c39:	5d                   	pop    %ebp
f0102c3a:	c3                   	ret    

f0102c3b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102c3b:	55                   	push   %ebp
f0102c3c:	89 e5                	mov    %esp,%ebp
f0102c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102c41:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102c45:	8b 10                	mov    (%eax),%edx
f0102c47:	3b 50 04             	cmp    0x4(%eax),%edx
f0102c4a:	73 0a                	jae    f0102c56 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102c4c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102c4f:	89 08                	mov    %ecx,(%eax)
f0102c51:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c54:	88 02                	mov    %al,(%edx)
}
f0102c56:	5d                   	pop    %ebp
f0102c57:	c3                   	ret    

f0102c58 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102c58:	55                   	push   %ebp
f0102c59:	89 e5                	mov    %esp,%ebp
f0102c5b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102c5e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102c61:	50                   	push   %eax
f0102c62:	ff 75 10             	pushl  0x10(%ebp)
f0102c65:	ff 75 0c             	pushl  0xc(%ebp)
f0102c68:	ff 75 08             	pushl  0x8(%ebp)
f0102c6b:	e8 05 00 00 00       	call   f0102c75 <vprintfmt>
	va_end(ap);
f0102c70:	83 c4 10             	add    $0x10,%esp
}
f0102c73:	c9                   	leave  
f0102c74:	c3                   	ret    

f0102c75 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102c75:	55                   	push   %ebp
f0102c76:	89 e5                	mov    %esp,%ebp
f0102c78:	57                   	push   %edi
f0102c79:	56                   	push   %esi
f0102c7a:	53                   	push   %ebx
f0102c7b:	83 ec 2c             	sub    $0x2c,%esp
f0102c7e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102c84:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102c87:	eb 12                	jmp    f0102c9b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102c89:	85 c0                	test   %eax,%eax
f0102c8b:	0f 84 90 03 00 00    	je     f0103021 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0102c91:	83 ec 08             	sub    $0x8,%esp
f0102c94:	53                   	push   %ebx
f0102c95:	50                   	push   %eax
f0102c96:	ff d6                	call   *%esi
f0102c98:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c9b:	83 c7 01             	add    $0x1,%edi
f0102c9e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102ca2:	83 f8 25             	cmp    $0x25,%eax
f0102ca5:	75 e2                	jne    f0102c89 <vprintfmt+0x14>
f0102ca7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102cab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102cb2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102cb9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102cc0:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cc5:	eb 07                	jmp    f0102cce <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102cca:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cce:	8d 47 01             	lea    0x1(%edi),%eax
f0102cd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102cd4:	0f b6 07             	movzbl (%edi),%eax
f0102cd7:	0f b6 c8             	movzbl %al,%ecx
f0102cda:	83 e8 23             	sub    $0x23,%eax
f0102cdd:	3c 55                	cmp    $0x55,%al
f0102cdf:	0f 87 21 03 00 00    	ja     f0103006 <vprintfmt+0x391>
f0102ce5:	0f b6 c0             	movzbl %al,%eax
f0102ce8:	ff 24 85 40 48 10 f0 	jmp    *-0xfefb7c0(,%eax,4)
f0102cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102cf2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102cf6:	eb d6                	jmp    f0102cce <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cfb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d00:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102d03:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102d06:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102d0a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102d0d:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102d10:	83 fa 09             	cmp    $0x9,%edx
f0102d13:	77 39                	ja     f0102d4e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102d15:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102d18:	eb e9                	jmp    f0102d03 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102d1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d1d:	8d 48 04             	lea    0x4(%eax),%ecx
f0102d20:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102d23:	8b 00                	mov    (%eax),%eax
f0102d25:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102d2b:	eb 27                	jmp    f0102d54 <vprintfmt+0xdf>
f0102d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d30:	85 c0                	test   %eax,%eax
f0102d32:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d37:	0f 49 c8             	cmovns %eax,%ecx
f0102d3a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d40:	eb 8c                	jmp    f0102cce <vprintfmt+0x59>
f0102d42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102d45:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102d4c:	eb 80                	jmp    f0102cce <vprintfmt+0x59>
f0102d4e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102d51:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102d54:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d58:	0f 89 70 ff ff ff    	jns    f0102cce <vprintfmt+0x59>
				width = precision, precision = -1;
f0102d5e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d64:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102d6b:	e9 5e ff ff ff       	jmp    f0102cce <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102d70:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102d76:	e9 53 ff ff ff       	jmp    f0102cce <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102d7b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d7e:	8d 50 04             	lea    0x4(%eax),%edx
f0102d81:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d84:	83 ec 08             	sub    $0x8,%esp
f0102d87:	53                   	push   %ebx
f0102d88:	ff 30                	pushl  (%eax)
f0102d8a:	ff d6                	call   *%esi
			break;
f0102d8c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102d92:	e9 04 ff ff ff       	jmp    f0102c9b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d97:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d9a:	8d 50 04             	lea    0x4(%eax),%edx
f0102d9d:	89 55 14             	mov    %edx,0x14(%ebp)
f0102da0:	8b 00                	mov    (%eax),%eax
f0102da2:	99                   	cltd   
f0102da3:	31 d0                	xor    %edx,%eax
f0102da5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102da7:	83 f8 07             	cmp    $0x7,%eax
f0102daa:	7f 0b                	jg     f0102db7 <vprintfmt+0x142>
f0102dac:	8b 14 85 a0 49 10 f0 	mov    -0xfefb660(,%eax,4),%edx
f0102db3:	85 d2                	test   %edx,%edx
f0102db5:	75 18                	jne    f0102dcf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102db7:	50                   	push   %eax
f0102db8:	68 c9 47 10 f0       	push   $0xf01047c9
f0102dbd:	53                   	push   %ebx
f0102dbe:	56                   	push   %esi
f0102dbf:	e8 94 fe ff ff       	call   f0102c58 <printfmt>
f0102dc4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102dc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102dca:	e9 cc fe ff ff       	jmp    f0102c9b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102dcf:	52                   	push   %edx
f0102dd0:	68 56 3d 10 f0       	push   $0xf0103d56
f0102dd5:	53                   	push   %ebx
f0102dd6:	56                   	push   %esi
f0102dd7:	e8 7c fe ff ff       	call   f0102c58 <printfmt>
f0102ddc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ddf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102de2:	e9 b4 fe ff ff       	jmp    f0102c9b <vprintfmt+0x26>
f0102de7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102dea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ded:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102df0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102df3:	8d 50 04             	lea    0x4(%eax),%edx
f0102df6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102df9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102dfb:	85 ff                	test   %edi,%edi
f0102dfd:	ba c2 47 10 f0       	mov    $0xf01047c2,%edx
f0102e02:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
f0102e05:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102e09:	0f 84 92 00 00 00    	je     f0102ea1 <vprintfmt+0x22c>
f0102e0f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0102e13:	0f 8e 96 00 00 00    	jle    f0102eaf <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e19:	83 ec 08             	sub    $0x8,%esp
f0102e1c:	51                   	push   %ecx
f0102e1d:	57                   	push   %edi
f0102e1e:	e8 5f 03 00 00       	call   f0103182 <strnlen>
f0102e23:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102e26:	29 c1                	sub    %eax,%ecx
f0102e28:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102e2b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102e2e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102e32:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e35:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102e38:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e3a:	eb 0f                	jmp    f0102e4b <vprintfmt+0x1d6>
					putch(padc, putdat);
f0102e3c:	83 ec 08             	sub    $0x8,%esp
f0102e3f:	53                   	push   %ebx
f0102e40:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e43:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e45:	83 ef 01             	sub    $0x1,%edi
f0102e48:	83 c4 10             	add    $0x10,%esp
f0102e4b:	85 ff                	test   %edi,%edi
f0102e4d:	7f ed                	jg     f0102e3c <vprintfmt+0x1c7>
f0102e4f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e52:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102e55:	85 c9                	test   %ecx,%ecx
f0102e57:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e5c:	0f 49 c1             	cmovns %ecx,%eax
f0102e5f:	29 c1                	sub    %eax,%ecx
f0102e61:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e64:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e67:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e6a:	89 cb                	mov    %ecx,%ebx
f0102e6c:	eb 4d                	jmp    f0102ebb <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102e6e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102e72:	74 1b                	je     f0102e8f <vprintfmt+0x21a>
f0102e74:	0f be c0             	movsbl %al,%eax
f0102e77:	83 e8 20             	sub    $0x20,%eax
f0102e7a:	83 f8 5e             	cmp    $0x5e,%eax
f0102e7d:	76 10                	jbe    f0102e8f <vprintfmt+0x21a>
					putch('?', putdat);
f0102e7f:	83 ec 08             	sub    $0x8,%esp
f0102e82:	ff 75 0c             	pushl  0xc(%ebp)
f0102e85:	6a 3f                	push   $0x3f
f0102e87:	ff 55 08             	call   *0x8(%ebp)
f0102e8a:	83 c4 10             	add    $0x10,%esp
f0102e8d:	eb 0d                	jmp    f0102e9c <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0102e8f:	83 ec 08             	sub    $0x8,%esp
f0102e92:	ff 75 0c             	pushl  0xc(%ebp)
f0102e95:	52                   	push   %edx
f0102e96:	ff 55 08             	call   *0x8(%ebp)
f0102e99:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e9c:	83 eb 01             	sub    $0x1,%ebx
f0102e9f:	eb 1a                	jmp    f0102ebb <vprintfmt+0x246>
f0102ea1:	89 75 08             	mov    %esi,0x8(%ebp)
f0102ea4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102ea7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102eaa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102ead:	eb 0c                	jmp    f0102ebb <vprintfmt+0x246>
f0102eaf:	89 75 08             	mov    %esi,0x8(%ebp)
f0102eb2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102eb5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102eb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102ebb:	83 c7 01             	add    $0x1,%edi
f0102ebe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102ec2:	0f be d0             	movsbl %al,%edx
f0102ec5:	85 d2                	test   %edx,%edx
f0102ec7:	74 23                	je     f0102eec <vprintfmt+0x277>
f0102ec9:	85 f6                	test   %esi,%esi
f0102ecb:	78 a1                	js     f0102e6e <vprintfmt+0x1f9>
f0102ecd:	83 ee 01             	sub    $0x1,%esi
f0102ed0:	79 9c                	jns    f0102e6e <vprintfmt+0x1f9>
f0102ed2:	89 df                	mov    %ebx,%edi
f0102ed4:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102eda:	eb 18                	jmp    f0102ef4 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102edc:	83 ec 08             	sub    $0x8,%esp
f0102edf:	53                   	push   %ebx
f0102ee0:	6a 20                	push   $0x20
f0102ee2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102ee4:	83 ef 01             	sub    $0x1,%edi
f0102ee7:	83 c4 10             	add    $0x10,%esp
f0102eea:	eb 08                	jmp    f0102ef4 <vprintfmt+0x27f>
f0102eec:	89 df                	mov    %ebx,%edi
f0102eee:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ef1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ef4:	85 ff                	test   %edi,%edi
f0102ef6:	7f e4                	jg     f0102edc <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ef8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102efb:	e9 9b fd ff ff       	jmp    f0102c9b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f00:	83 fa 01             	cmp    $0x1,%edx
f0102f03:	7e 16                	jle    f0102f1b <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0102f05:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f08:	8d 50 08             	lea    0x8(%eax),%edx
f0102f0b:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f0e:	8b 50 04             	mov    0x4(%eax),%edx
f0102f11:	8b 00                	mov    (%eax),%eax
f0102f13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f16:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102f19:	eb 32                	jmp    f0102f4d <vprintfmt+0x2d8>
	else if (lflag)
f0102f1b:	85 d2                	test   %edx,%edx
f0102f1d:	74 18                	je     f0102f37 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f0102f1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f22:	8d 50 04             	lea    0x4(%eax),%edx
f0102f25:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f28:	8b 00                	mov    (%eax),%eax
f0102f2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f2d:	89 c1                	mov    %eax,%ecx
f0102f2f:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f32:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102f35:	eb 16                	jmp    f0102f4d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0102f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f3a:	8d 50 04             	lea    0x4(%eax),%edx
f0102f3d:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f40:	8b 00                	mov    (%eax),%eax
f0102f42:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f45:	89 c1                	mov    %eax,%ecx
f0102f47:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102f4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f50:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102f53:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102f58:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102f5c:	79 74                	jns    f0102fd2 <vprintfmt+0x35d>
				putch('-', putdat);
f0102f5e:	83 ec 08             	sub    $0x8,%esp
f0102f61:	53                   	push   %ebx
f0102f62:	6a 2d                	push   $0x2d
f0102f64:	ff d6                	call   *%esi
				num = -(long long) num;
f0102f66:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f69:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f6c:	f7 d8                	neg    %eax
f0102f6e:	83 d2 00             	adc    $0x0,%edx
f0102f71:	f7 da                	neg    %edx
f0102f73:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102f76:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f7b:	eb 55                	jmp    f0102fd2 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102f7d:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f80:	e8 7c fc ff ff       	call   f0102c01 <getuint>
			base = 10;
f0102f85:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102f8a:	eb 46                	jmp    f0102fd2 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0102f8c:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f8f:	e8 6d fc ff ff       	call   f0102c01 <getuint>
                        base = 8;
f0102f94:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0102f99:	eb 37                	jmp    f0102fd2 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
f0102f9b:	83 ec 08             	sub    $0x8,%esp
f0102f9e:	53                   	push   %ebx
f0102f9f:	6a 30                	push   $0x30
f0102fa1:	ff d6                	call   *%esi
			putch('x', putdat);
f0102fa3:	83 c4 08             	add    $0x8,%esp
f0102fa6:	53                   	push   %ebx
f0102fa7:	6a 78                	push   $0x78
f0102fa9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102fab:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fae:	8d 50 04             	lea    0x4(%eax),%edx
f0102fb1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102fb4:	8b 00                	mov    (%eax),%eax
f0102fb6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102fbb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102fbe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102fc3:	eb 0d                	jmp    f0102fd2 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102fc5:	8d 45 14             	lea    0x14(%ebp),%eax
f0102fc8:	e8 34 fc ff ff       	call   f0102c01 <getuint>
			base = 16;
f0102fcd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102fd2:	83 ec 0c             	sub    $0xc,%esp
f0102fd5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102fd9:	57                   	push   %edi
f0102fda:	ff 75 e0             	pushl  -0x20(%ebp)
f0102fdd:	51                   	push   %ecx
f0102fde:	52                   	push   %edx
f0102fdf:	50                   	push   %eax
f0102fe0:	89 da                	mov    %ebx,%edx
f0102fe2:	89 f0                	mov    %esi,%eax
f0102fe4:	e8 6e fb ff ff       	call   f0102b57 <printnum>
			break;
f0102fe9:	83 c4 20             	add    $0x20,%esp
f0102fec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102fef:	e9 a7 fc ff ff       	jmp    f0102c9b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102ff4:	83 ec 08             	sub    $0x8,%esp
f0102ff7:	53                   	push   %ebx
f0102ff8:	51                   	push   %ecx
f0102ff9:	ff d6                	call   *%esi
			break;
f0102ffb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ffe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103001:	e9 95 fc ff ff       	jmp    f0102c9b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103006:	83 ec 08             	sub    $0x8,%esp
f0103009:	53                   	push   %ebx
f010300a:	6a 25                	push   $0x25
f010300c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010300e:	83 c4 10             	add    $0x10,%esp
f0103011:	eb 03                	jmp    f0103016 <vprintfmt+0x3a1>
f0103013:	83 ef 01             	sub    $0x1,%edi
f0103016:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010301a:	75 f7                	jne    f0103013 <vprintfmt+0x39e>
f010301c:	e9 7a fc ff ff       	jmp    f0102c9b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103021:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103024:	5b                   	pop    %ebx
f0103025:	5e                   	pop    %esi
f0103026:	5f                   	pop    %edi
f0103027:	5d                   	pop    %ebp
f0103028:	c3                   	ret    

f0103029 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103029:	55                   	push   %ebp
f010302a:	89 e5                	mov    %esp,%ebp
f010302c:	83 ec 18             	sub    $0x18,%esp
f010302f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103032:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103035:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103038:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010303c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010303f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103046:	85 c0                	test   %eax,%eax
f0103048:	74 26                	je     f0103070 <vsnprintf+0x47>
f010304a:	85 d2                	test   %edx,%edx
f010304c:	7e 22                	jle    f0103070 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010304e:	ff 75 14             	pushl  0x14(%ebp)
f0103051:	ff 75 10             	pushl  0x10(%ebp)
f0103054:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103057:	50                   	push   %eax
f0103058:	68 3b 2c 10 f0       	push   $0xf0102c3b
f010305d:	e8 13 fc ff ff       	call   f0102c75 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103062:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103065:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103068:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010306b:	83 c4 10             	add    $0x10,%esp
f010306e:	eb 05                	jmp    f0103075 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103070:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103075:	c9                   	leave  
f0103076:	c3                   	ret    

f0103077 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103077:	55                   	push   %ebp
f0103078:	89 e5                	mov    %esp,%ebp
f010307a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010307d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103080:	50                   	push   %eax
f0103081:	ff 75 10             	pushl  0x10(%ebp)
f0103084:	ff 75 0c             	pushl  0xc(%ebp)
f0103087:	ff 75 08             	pushl  0x8(%ebp)
f010308a:	e8 9a ff ff ff       	call   f0103029 <vsnprintf>
	va_end(ap);

	return rc;
}
f010308f:	c9                   	leave  
f0103090:	c3                   	ret    

f0103091 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103091:	55                   	push   %ebp
f0103092:	89 e5                	mov    %esp,%ebp
f0103094:	57                   	push   %edi
f0103095:	56                   	push   %esi
f0103096:	53                   	push   %ebx
f0103097:	83 ec 0c             	sub    $0xc,%esp
f010309a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010309d:	85 c0                	test   %eax,%eax
f010309f:	74 11                	je     f01030b2 <readline+0x21>
		cprintf("%s", prompt);
f01030a1:	83 ec 08             	sub    $0x8,%esp
f01030a4:	50                   	push   %eax
f01030a5:	68 56 3d 10 f0       	push   $0xf0103d56
f01030aa:	e8 4d f7 ff ff       	call   f01027fc <cprintf>
f01030af:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01030b2:	83 ec 0c             	sub    $0xc,%esp
f01030b5:	6a 00                	push   $0x0
f01030b7:	e8 45 d5 ff ff       	call   f0100601 <iscons>
f01030bc:	89 c7                	mov    %eax,%edi
f01030be:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01030c1:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01030c6:	e8 25 d5 ff ff       	call   f01005f0 <getchar>
f01030cb:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01030cd:	85 c0                	test   %eax,%eax
f01030cf:	79 18                	jns    f01030e9 <readline+0x58>
			cprintf("read error: %e\n", c);
f01030d1:	83 ec 08             	sub    $0x8,%esp
f01030d4:	50                   	push   %eax
f01030d5:	68 c0 49 10 f0       	push   $0xf01049c0
f01030da:	e8 1d f7 ff ff       	call   f01027fc <cprintf>
			return NULL;
f01030df:	83 c4 10             	add    $0x10,%esp
f01030e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e7:	eb 79                	jmp    f0103162 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030e9:	83 f8 7f             	cmp    $0x7f,%eax
f01030ec:	0f 94 c2             	sete   %dl
f01030ef:	83 f8 08             	cmp    $0x8,%eax
f01030f2:	0f 94 c0             	sete   %al
f01030f5:	08 c2                	or     %al,%dl
f01030f7:	74 1a                	je     f0103113 <readline+0x82>
f01030f9:	85 f6                	test   %esi,%esi
f01030fb:	7e 16                	jle    f0103113 <readline+0x82>
			if (echoing)
f01030fd:	85 ff                	test   %edi,%edi
f01030ff:	74 0d                	je     f010310e <readline+0x7d>
				cputchar('\b');
f0103101:	83 ec 0c             	sub    $0xc,%esp
f0103104:	6a 08                	push   $0x8
f0103106:	e8 d5 d4 ff ff       	call   f01005e0 <cputchar>
f010310b:	83 c4 10             	add    $0x10,%esp
			i--;
f010310e:	83 ee 01             	sub    $0x1,%esi
f0103111:	eb b3                	jmp    f01030c6 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103113:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103119:	7f 20                	jg     f010313b <readline+0xaa>
f010311b:	83 fb 1f             	cmp    $0x1f,%ebx
f010311e:	7e 1b                	jle    f010313b <readline+0xaa>
			if (echoing)
f0103120:	85 ff                	test   %edi,%edi
f0103122:	74 0c                	je     f0103130 <readline+0x9f>
				cputchar(c);
f0103124:	83 ec 0c             	sub    $0xc,%esp
f0103127:	53                   	push   %ebx
f0103128:	e8 b3 d4 ff ff       	call   f01005e0 <cputchar>
f010312d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103130:	88 9e 80 75 11 f0    	mov    %bl,-0xfee8a80(%esi)
f0103136:	8d 76 01             	lea    0x1(%esi),%esi
f0103139:	eb 8b                	jmp    f01030c6 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010313b:	83 fb 0d             	cmp    $0xd,%ebx
f010313e:	74 05                	je     f0103145 <readline+0xb4>
f0103140:	83 fb 0a             	cmp    $0xa,%ebx
f0103143:	75 81                	jne    f01030c6 <readline+0x35>
			if (echoing)
f0103145:	85 ff                	test   %edi,%edi
f0103147:	74 0d                	je     f0103156 <readline+0xc5>
				cputchar('\n');
f0103149:	83 ec 0c             	sub    $0xc,%esp
f010314c:	6a 0a                	push   $0xa
f010314e:	e8 8d d4 ff ff       	call   f01005e0 <cputchar>
f0103153:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103156:	c6 86 80 75 11 f0 00 	movb   $0x0,-0xfee8a80(%esi)
			return buf;
f010315d:	b8 80 75 11 f0       	mov    $0xf0117580,%eax
		}
	}
}
f0103162:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103165:	5b                   	pop    %ebx
f0103166:	5e                   	pop    %esi
f0103167:	5f                   	pop    %edi
f0103168:	5d                   	pop    %ebp
f0103169:	c3                   	ret    

f010316a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010316a:	55                   	push   %ebp
f010316b:	89 e5                	mov    %esp,%ebp
f010316d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103170:	b8 00 00 00 00       	mov    $0x0,%eax
f0103175:	eb 03                	jmp    f010317a <strlen+0x10>
		n++;
f0103177:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010317a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010317e:	75 f7                	jne    f0103177 <strlen+0xd>
		n++;
	return n;
}
f0103180:	5d                   	pop    %ebp
f0103181:	c3                   	ret    

f0103182 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103182:	55                   	push   %ebp
f0103183:	89 e5                	mov    %esp,%ebp
f0103185:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103188:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010318b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103190:	eb 03                	jmp    f0103195 <strnlen+0x13>
		n++;
f0103192:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103195:	39 c2                	cmp    %eax,%edx
f0103197:	74 08                	je     f01031a1 <strnlen+0x1f>
f0103199:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010319d:	75 f3                	jne    f0103192 <strnlen+0x10>
f010319f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01031a1:	5d                   	pop    %ebp
f01031a2:	c3                   	ret    

f01031a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01031a3:	55                   	push   %ebp
f01031a4:	89 e5                	mov    %esp,%ebp
f01031a6:	53                   	push   %ebx
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01031ad:	89 c2                	mov    %eax,%edx
f01031af:	83 c2 01             	add    $0x1,%edx
f01031b2:	83 c1 01             	add    $0x1,%ecx
f01031b5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01031b9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031bc:	84 db                	test   %bl,%bl
f01031be:	75 ef                	jne    f01031af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01031c0:	5b                   	pop    %ebx
f01031c1:	5d                   	pop    %ebp
f01031c2:	c3                   	ret    

f01031c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01031c3:	55                   	push   %ebp
f01031c4:	89 e5                	mov    %esp,%ebp
f01031c6:	53                   	push   %ebx
f01031c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01031ca:	53                   	push   %ebx
f01031cb:	e8 9a ff ff ff       	call   f010316a <strlen>
f01031d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01031d3:	ff 75 0c             	pushl  0xc(%ebp)
f01031d6:	01 d8                	add    %ebx,%eax
f01031d8:	50                   	push   %eax
f01031d9:	e8 c5 ff ff ff       	call   f01031a3 <strcpy>
	return dst;
}
f01031de:	89 d8                	mov    %ebx,%eax
f01031e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031e3:	c9                   	leave  
f01031e4:	c3                   	ret    

f01031e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01031e5:	55                   	push   %ebp
f01031e6:	89 e5                	mov    %esp,%ebp
f01031e8:	56                   	push   %esi
f01031e9:	53                   	push   %ebx
f01031ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01031ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031f0:	89 f3                	mov    %esi,%ebx
f01031f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01031f5:	89 f2                	mov    %esi,%edx
f01031f7:	eb 0f                	jmp    f0103208 <strncpy+0x23>
		*dst++ = *src;
f01031f9:	83 c2 01             	add    $0x1,%edx
f01031fc:	0f b6 01             	movzbl (%ecx),%eax
f01031ff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103202:	80 39 01             	cmpb   $0x1,(%ecx)
f0103205:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103208:	39 da                	cmp    %ebx,%edx
f010320a:	75 ed                	jne    f01031f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010320c:	89 f0                	mov    %esi,%eax
f010320e:	5b                   	pop    %ebx
f010320f:	5e                   	pop    %esi
f0103210:	5d                   	pop    %ebp
f0103211:	c3                   	ret    

f0103212 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103212:	55                   	push   %ebp
f0103213:	89 e5                	mov    %esp,%ebp
f0103215:	56                   	push   %esi
f0103216:	53                   	push   %ebx
f0103217:	8b 75 08             	mov    0x8(%ebp),%esi
f010321a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010321d:	8b 55 10             	mov    0x10(%ebp),%edx
f0103220:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103222:	85 d2                	test   %edx,%edx
f0103224:	74 21                	je     f0103247 <strlcpy+0x35>
f0103226:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010322a:	89 f2                	mov    %esi,%edx
f010322c:	eb 09                	jmp    f0103237 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010322e:	83 c2 01             	add    $0x1,%edx
f0103231:	83 c1 01             	add    $0x1,%ecx
f0103234:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103237:	39 c2                	cmp    %eax,%edx
f0103239:	74 09                	je     f0103244 <strlcpy+0x32>
f010323b:	0f b6 19             	movzbl (%ecx),%ebx
f010323e:	84 db                	test   %bl,%bl
f0103240:	75 ec                	jne    f010322e <strlcpy+0x1c>
f0103242:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103244:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103247:	29 f0                	sub    %esi,%eax
}
f0103249:	5b                   	pop    %ebx
f010324a:	5e                   	pop    %esi
f010324b:	5d                   	pop    %ebp
f010324c:	c3                   	ret    

f010324d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010324d:	55                   	push   %ebp
f010324e:	89 e5                	mov    %esp,%ebp
f0103250:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103253:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103256:	eb 06                	jmp    f010325e <strcmp+0x11>
		p++, q++;
f0103258:	83 c1 01             	add    $0x1,%ecx
f010325b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010325e:	0f b6 01             	movzbl (%ecx),%eax
f0103261:	84 c0                	test   %al,%al
f0103263:	74 04                	je     f0103269 <strcmp+0x1c>
f0103265:	3a 02                	cmp    (%edx),%al
f0103267:	74 ef                	je     f0103258 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103269:	0f b6 c0             	movzbl %al,%eax
f010326c:	0f b6 12             	movzbl (%edx),%edx
f010326f:	29 d0                	sub    %edx,%eax
}
f0103271:	5d                   	pop    %ebp
f0103272:	c3                   	ret    

f0103273 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103273:	55                   	push   %ebp
f0103274:	89 e5                	mov    %esp,%ebp
f0103276:	53                   	push   %ebx
f0103277:	8b 45 08             	mov    0x8(%ebp),%eax
f010327a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010327d:	89 c3                	mov    %eax,%ebx
f010327f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103282:	eb 06                	jmp    f010328a <strncmp+0x17>
		n--, p++, q++;
f0103284:	83 c0 01             	add    $0x1,%eax
f0103287:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010328a:	39 d8                	cmp    %ebx,%eax
f010328c:	74 15                	je     f01032a3 <strncmp+0x30>
f010328e:	0f b6 08             	movzbl (%eax),%ecx
f0103291:	84 c9                	test   %cl,%cl
f0103293:	74 04                	je     f0103299 <strncmp+0x26>
f0103295:	3a 0a                	cmp    (%edx),%cl
f0103297:	74 eb                	je     f0103284 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103299:	0f b6 00             	movzbl (%eax),%eax
f010329c:	0f b6 12             	movzbl (%edx),%edx
f010329f:	29 d0                	sub    %edx,%eax
f01032a1:	eb 05                	jmp    f01032a8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01032a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01032a8:	5b                   	pop    %ebx
f01032a9:	5d                   	pop    %ebp
f01032aa:	c3                   	ret    

f01032ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01032ab:	55                   	push   %ebp
f01032ac:	89 e5                	mov    %esp,%ebp
f01032ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032b5:	eb 07                	jmp    f01032be <strchr+0x13>
		if (*s == c)
f01032b7:	38 ca                	cmp    %cl,%dl
f01032b9:	74 0f                	je     f01032ca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01032bb:	83 c0 01             	add    $0x1,%eax
f01032be:	0f b6 10             	movzbl (%eax),%edx
f01032c1:	84 d2                	test   %dl,%dl
f01032c3:	75 f2                	jne    f01032b7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01032c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032ca:	5d                   	pop    %ebp
f01032cb:	c3                   	ret    

f01032cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01032cc:	55                   	push   %ebp
f01032cd:	89 e5                	mov    %esp,%ebp
f01032cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032d6:	eb 03                	jmp    f01032db <strfind+0xf>
f01032d8:	83 c0 01             	add    $0x1,%eax
f01032db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01032de:	84 d2                	test   %dl,%dl
f01032e0:	74 04                	je     f01032e6 <strfind+0x1a>
f01032e2:	38 ca                	cmp    %cl,%dl
f01032e4:	75 f2                	jne    f01032d8 <strfind+0xc>
			break;
	return (char *) s;
}
f01032e6:	5d                   	pop    %ebp
f01032e7:	c3                   	ret    

f01032e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01032e8:	55                   	push   %ebp
f01032e9:	89 e5                	mov    %esp,%ebp
f01032eb:	57                   	push   %edi
f01032ec:	56                   	push   %esi
f01032ed:	53                   	push   %ebx
f01032ee:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01032f4:	85 c9                	test   %ecx,%ecx
f01032f6:	74 36                	je     f010332e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01032f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01032fe:	75 28                	jne    f0103328 <memset+0x40>
f0103300:	f6 c1 03             	test   $0x3,%cl
f0103303:	75 23                	jne    f0103328 <memset+0x40>
		c &= 0xFF;
f0103305:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103309:	89 d3                	mov    %edx,%ebx
f010330b:	c1 e3 08             	shl    $0x8,%ebx
f010330e:	89 d6                	mov    %edx,%esi
f0103310:	c1 e6 18             	shl    $0x18,%esi
f0103313:	89 d0                	mov    %edx,%eax
f0103315:	c1 e0 10             	shl    $0x10,%eax
f0103318:	09 f0                	or     %esi,%eax
f010331a:	09 c2                	or     %eax,%edx
f010331c:	89 d0                	mov    %edx,%eax
f010331e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103320:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103323:	fc                   	cld    
f0103324:	f3 ab                	rep stos %eax,%es:(%edi)
f0103326:	eb 06                	jmp    f010332e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103328:	8b 45 0c             	mov    0xc(%ebp),%eax
f010332b:	fc                   	cld    
f010332c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010332e:	89 f8                	mov    %edi,%eax
f0103330:	5b                   	pop    %ebx
f0103331:	5e                   	pop    %esi
f0103332:	5f                   	pop    %edi
f0103333:	5d                   	pop    %ebp
f0103334:	c3                   	ret    

f0103335 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103335:	55                   	push   %ebp
f0103336:	89 e5                	mov    %esp,%ebp
f0103338:	57                   	push   %edi
f0103339:	56                   	push   %esi
f010333a:	8b 45 08             	mov    0x8(%ebp),%eax
f010333d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103340:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103343:	39 c6                	cmp    %eax,%esi
f0103345:	73 35                	jae    f010337c <memmove+0x47>
f0103347:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010334a:	39 d0                	cmp    %edx,%eax
f010334c:	73 2e                	jae    f010337c <memmove+0x47>
		s += n;
		d += n;
f010334e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103351:	89 d6                	mov    %edx,%esi
f0103353:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103355:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010335b:	75 13                	jne    f0103370 <memmove+0x3b>
f010335d:	f6 c1 03             	test   $0x3,%cl
f0103360:	75 0e                	jne    f0103370 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103362:	83 ef 04             	sub    $0x4,%edi
f0103365:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103368:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010336b:	fd                   	std    
f010336c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010336e:	eb 09                	jmp    f0103379 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103370:	83 ef 01             	sub    $0x1,%edi
f0103373:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103376:	fd                   	std    
f0103377:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103379:	fc                   	cld    
f010337a:	eb 1d                	jmp    f0103399 <memmove+0x64>
f010337c:	89 f2                	mov    %esi,%edx
f010337e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103380:	f6 c2 03             	test   $0x3,%dl
f0103383:	75 0f                	jne    f0103394 <memmove+0x5f>
f0103385:	f6 c1 03             	test   $0x3,%cl
f0103388:	75 0a                	jne    f0103394 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010338a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010338d:	89 c7                	mov    %eax,%edi
f010338f:	fc                   	cld    
f0103390:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103392:	eb 05                	jmp    f0103399 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103394:	89 c7                	mov    %eax,%edi
f0103396:	fc                   	cld    
f0103397:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103399:	5e                   	pop    %esi
f010339a:	5f                   	pop    %edi
f010339b:	5d                   	pop    %ebp
f010339c:	c3                   	ret    

f010339d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010339d:	55                   	push   %ebp
f010339e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01033a0:	ff 75 10             	pushl  0x10(%ebp)
f01033a3:	ff 75 0c             	pushl  0xc(%ebp)
f01033a6:	ff 75 08             	pushl  0x8(%ebp)
f01033a9:	e8 87 ff ff ff       	call   f0103335 <memmove>
}
f01033ae:	c9                   	leave  
f01033af:	c3                   	ret    

f01033b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01033b0:	55                   	push   %ebp
f01033b1:	89 e5                	mov    %esp,%ebp
f01033b3:	56                   	push   %esi
f01033b4:	53                   	push   %ebx
f01033b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033bb:	89 c6                	mov    %eax,%esi
f01033bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033c0:	eb 1a                	jmp    f01033dc <memcmp+0x2c>
		if (*s1 != *s2)
f01033c2:	0f b6 08             	movzbl (%eax),%ecx
f01033c5:	0f b6 1a             	movzbl (%edx),%ebx
f01033c8:	38 d9                	cmp    %bl,%cl
f01033ca:	74 0a                	je     f01033d6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01033cc:	0f b6 c1             	movzbl %cl,%eax
f01033cf:	0f b6 db             	movzbl %bl,%ebx
f01033d2:	29 d8                	sub    %ebx,%eax
f01033d4:	eb 0f                	jmp    f01033e5 <memcmp+0x35>
		s1++, s2++;
f01033d6:	83 c0 01             	add    $0x1,%eax
f01033d9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033dc:	39 f0                	cmp    %esi,%eax
f01033de:	75 e2                	jne    f01033c2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01033e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033e5:	5b                   	pop    %ebx
f01033e6:	5e                   	pop    %esi
f01033e7:	5d                   	pop    %ebp
f01033e8:	c3                   	ret    

f01033e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01033e9:	55                   	push   %ebp
f01033ea:	89 e5                	mov    %esp,%ebp
f01033ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01033ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01033f2:	89 c2                	mov    %eax,%edx
f01033f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01033f7:	eb 07                	jmp    f0103400 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01033f9:	38 08                	cmp    %cl,(%eax)
f01033fb:	74 07                	je     f0103404 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033fd:	83 c0 01             	add    $0x1,%eax
f0103400:	39 d0                	cmp    %edx,%eax
f0103402:	72 f5                	jb     f01033f9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103404:	5d                   	pop    %ebp
f0103405:	c3                   	ret    

f0103406 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103406:	55                   	push   %ebp
f0103407:	89 e5                	mov    %esp,%ebp
f0103409:	57                   	push   %edi
f010340a:	56                   	push   %esi
f010340b:	53                   	push   %ebx
f010340c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010340f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103412:	eb 03                	jmp    f0103417 <strtol+0x11>
		s++;
f0103414:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103417:	0f b6 01             	movzbl (%ecx),%eax
f010341a:	3c 09                	cmp    $0x9,%al
f010341c:	74 f6                	je     f0103414 <strtol+0xe>
f010341e:	3c 20                	cmp    $0x20,%al
f0103420:	74 f2                	je     f0103414 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103422:	3c 2b                	cmp    $0x2b,%al
f0103424:	75 0a                	jne    f0103430 <strtol+0x2a>
		s++;
f0103426:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103429:	bf 00 00 00 00       	mov    $0x0,%edi
f010342e:	eb 10                	jmp    f0103440 <strtol+0x3a>
f0103430:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103435:	3c 2d                	cmp    $0x2d,%al
f0103437:	75 07                	jne    f0103440 <strtol+0x3a>
		s++, neg = 1;
f0103439:	8d 49 01             	lea    0x1(%ecx),%ecx
f010343c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103440:	85 db                	test   %ebx,%ebx
f0103442:	0f 94 c0             	sete   %al
f0103445:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010344b:	75 19                	jne    f0103466 <strtol+0x60>
f010344d:	80 39 30             	cmpb   $0x30,(%ecx)
f0103450:	75 14                	jne    f0103466 <strtol+0x60>
f0103452:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103456:	0f 85 82 00 00 00    	jne    f01034de <strtol+0xd8>
		s += 2, base = 16;
f010345c:	83 c1 02             	add    $0x2,%ecx
f010345f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103464:	eb 16                	jmp    f010347c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103466:	84 c0                	test   %al,%al
f0103468:	74 12                	je     f010347c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010346a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010346f:	80 39 30             	cmpb   $0x30,(%ecx)
f0103472:	75 08                	jne    f010347c <strtol+0x76>
		s++, base = 8;
f0103474:	83 c1 01             	add    $0x1,%ecx
f0103477:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010347c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103481:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103484:	0f b6 11             	movzbl (%ecx),%edx
f0103487:	8d 72 d0             	lea    -0x30(%edx),%esi
f010348a:	89 f3                	mov    %esi,%ebx
f010348c:	80 fb 09             	cmp    $0x9,%bl
f010348f:	77 08                	ja     f0103499 <strtol+0x93>
			dig = *s - '0';
f0103491:	0f be d2             	movsbl %dl,%edx
f0103494:	83 ea 30             	sub    $0x30,%edx
f0103497:	eb 22                	jmp    f01034bb <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0103499:	8d 72 9f             	lea    -0x61(%edx),%esi
f010349c:	89 f3                	mov    %esi,%ebx
f010349e:	80 fb 19             	cmp    $0x19,%bl
f01034a1:	77 08                	ja     f01034ab <strtol+0xa5>
			dig = *s - 'a' + 10;
f01034a3:	0f be d2             	movsbl %dl,%edx
f01034a6:	83 ea 57             	sub    $0x57,%edx
f01034a9:	eb 10                	jmp    f01034bb <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f01034ab:	8d 72 bf             	lea    -0x41(%edx),%esi
f01034ae:	89 f3                	mov    %esi,%ebx
f01034b0:	80 fb 19             	cmp    $0x19,%bl
f01034b3:	77 16                	ja     f01034cb <strtol+0xc5>
			dig = *s - 'A' + 10;
f01034b5:	0f be d2             	movsbl %dl,%edx
f01034b8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01034bb:	3b 55 10             	cmp    0x10(%ebp),%edx
f01034be:	7d 0f                	jge    f01034cf <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f01034c0:	83 c1 01             	add    $0x1,%ecx
f01034c3:	0f af 45 10          	imul   0x10(%ebp),%eax
f01034c7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01034c9:	eb b9                	jmp    f0103484 <strtol+0x7e>
f01034cb:	89 c2                	mov    %eax,%edx
f01034cd:	eb 02                	jmp    f01034d1 <strtol+0xcb>
f01034cf:	89 c2                	mov    %eax,%edx

	if (endptr)
f01034d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01034d5:	74 0d                	je     f01034e4 <strtol+0xde>
		*endptr = (char *) s;
f01034d7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01034da:	89 0e                	mov    %ecx,(%esi)
f01034dc:	eb 06                	jmp    f01034e4 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034de:	84 c0                	test   %al,%al
f01034e0:	75 92                	jne    f0103474 <strtol+0x6e>
f01034e2:	eb 98                	jmp    f010347c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01034e4:	f7 da                	neg    %edx
f01034e6:	85 ff                	test   %edi,%edi
f01034e8:	0f 45 c2             	cmovne %edx,%eax
}
f01034eb:	5b                   	pop    %ebx
f01034ec:	5e                   	pop    %esi
f01034ed:	5f                   	pop    %edi
f01034ee:	5d                   	pop    %ebp
f01034ef:	c3                   	ret    

f01034f0 <__udivdi3>:
f01034f0:	55                   	push   %ebp
f01034f1:	57                   	push   %edi
f01034f2:	56                   	push   %esi
f01034f3:	83 ec 10             	sub    $0x10,%esp
f01034f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f01034fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
f01034fe:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103502:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103506:	85 d2                	test   %edx,%edx
f0103508:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010350c:	89 34 24             	mov    %esi,(%esp)
f010350f:	89 c8                	mov    %ecx,%eax
f0103511:	75 35                	jne    f0103548 <__udivdi3+0x58>
f0103513:	39 f1                	cmp    %esi,%ecx
f0103515:	0f 87 bd 00 00 00    	ja     f01035d8 <__udivdi3+0xe8>
f010351b:	85 c9                	test   %ecx,%ecx
f010351d:	89 cd                	mov    %ecx,%ebp
f010351f:	75 0b                	jne    f010352c <__udivdi3+0x3c>
f0103521:	b8 01 00 00 00       	mov    $0x1,%eax
f0103526:	31 d2                	xor    %edx,%edx
f0103528:	f7 f1                	div    %ecx
f010352a:	89 c5                	mov    %eax,%ebp
f010352c:	89 f0                	mov    %esi,%eax
f010352e:	31 d2                	xor    %edx,%edx
f0103530:	f7 f5                	div    %ebp
f0103532:	89 c6                	mov    %eax,%esi
f0103534:	89 f8                	mov    %edi,%eax
f0103536:	f7 f5                	div    %ebp
f0103538:	89 f2                	mov    %esi,%edx
f010353a:	83 c4 10             	add    $0x10,%esp
f010353d:	5e                   	pop    %esi
f010353e:	5f                   	pop    %edi
f010353f:	5d                   	pop    %ebp
f0103540:	c3                   	ret    
f0103541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103548:	3b 14 24             	cmp    (%esp),%edx
f010354b:	77 7b                	ja     f01035c8 <__udivdi3+0xd8>
f010354d:	0f bd f2             	bsr    %edx,%esi
f0103550:	83 f6 1f             	xor    $0x1f,%esi
f0103553:	0f 84 97 00 00 00    	je     f01035f0 <__udivdi3+0x100>
f0103559:	bd 20 00 00 00       	mov    $0x20,%ebp
f010355e:	89 d7                	mov    %edx,%edi
f0103560:	89 f1                	mov    %esi,%ecx
f0103562:	29 f5                	sub    %esi,%ebp
f0103564:	d3 e7                	shl    %cl,%edi
f0103566:	89 c2                	mov    %eax,%edx
f0103568:	89 e9                	mov    %ebp,%ecx
f010356a:	d3 ea                	shr    %cl,%edx
f010356c:	89 f1                	mov    %esi,%ecx
f010356e:	09 fa                	or     %edi,%edx
f0103570:	8b 3c 24             	mov    (%esp),%edi
f0103573:	d3 e0                	shl    %cl,%eax
f0103575:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103579:	89 e9                	mov    %ebp,%ecx
f010357b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103583:	89 fa                	mov    %edi,%edx
f0103585:	d3 ea                	shr    %cl,%edx
f0103587:	89 f1                	mov    %esi,%ecx
f0103589:	d3 e7                	shl    %cl,%edi
f010358b:	89 e9                	mov    %ebp,%ecx
f010358d:	d3 e8                	shr    %cl,%eax
f010358f:	09 c7                	or     %eax,%edi
f0103591:	89 f8                	mov    %edi,%eax
f0103593:	f7 74 24 08          	divl   0x8(%esp)
f0103597:	89 d5                	mov    %edx,%ebp
f0103599:	89 c7                	mov    %eax,%edi
f010359b:	f7 64 24 0c          	mull   0xc(%esp)
f010359f:	39 d5                	cmp    %edx,%ebp
f01035a1:	89 14 24             	mov    %edx,(%esp)
f01035a4:	72 11                	jb     f01035b7 <__udivdi3+0xc7>
f01035a6:	8b 54 24 04          	mov    0x4(%esp),%edx
f01035aa:	89 f1                	mov    %esi,%ecx
f01035ac:	d3 e2                	shl    %cl,%edx
f01035ae:	39 c2                	cmp    %eax,%edx
f01035b0:	73 5e                	jae    f0103610 <__udivdi3+0x120>
f01035b2:	3b 2c 24             	cmp    (%esp),%ebp
f01035b5:	75 59                	jne    f0103610 <__udivdi3+0x120>
f01035b7:	8d 47 ff             	lea    -0x1(%edi),%eax
f01035ba:	31 f6                	xor    %esi,%esi
f01035bc:	89 f2                	mov    %esi,%edx
f01035be:	83 c4 10             	add    $0x10,%esp
f01035c1:	5e                   	pop    %esi
f01035c2:	5f                   	pop    %edi
f01035c3:	5d                   	pop    %ebp
f01035c4:	c3                   	ret    
f01035c5:	8d 76 00             	lea    0x0(%esi),%esi
f01035c8:	31 f6                	xor    %esi,%esi
f01035ca:	31 c0                	xor    %eax,%eax
f01035cc:	89 f2                	mov    %esi,%edx
f01035ce:	83 c4 10             	add    $0x10,%esp
f01035d1:	5e                   	pop    %esi
f01035d2:	5f                   	pop    %edi
f01035d3:	5d                   	pop    %ebp
f01035d4:	c3                   	ret    
f01035d5:	8d 76 00             	lea    0x0(%esi),%esi
f01035d8:	89 f2                	mov    %esi,%edx
f01035da:	31 f6                	xor    %esi,%esi
f01035dc:	89 f8                	mov    %edi,%eax
f01035de:	f7 f1                	div    %ecx
f01035e0:	89 f2                	mov    %esi,%edx
f01035e2:	83 c4 10             	add    $0x10,%esp
f01035e5:	5e                   	pop    %esi
f01035e6:	5f                   	pop    %edi
f01035e7:	5d                   	pop    %ebp
f01035e8:	c3                   	ret    
f01035e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01035f4:	76 0b                	jbe    f0103601 <__udivdi3+0x111>
f01035f6:	31 c0                	xor    %eax,%eax
f01035f8:	3b 14 24             	cmp    (%esp),%edx
f01035fb:	0f 83 37 ff ff ff    	jae    f0103538 <__udivdi3+0x48>
f0103601:	b8 01 00 00 00       	mov    $0x1,%eax
f0103606:	e9 2d ff ff ff       	jmp    f0103538 <__udivdi3+0x48>
f010360b:	90                   	nop
f010360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103610:	89 f8                	mov    %edi,%eax
f0103612:	31 f6                	xor    %esi,%esi
f0103614:	e9 1f ff ff ff       	jmp    f0103538 <__udivdi3+0x48>
f0103619:	66 90                	xchg   %ax,%ax
f010361b:	66 90                	xchg   %ax,%ax
f010361d:	66 90                	xchg   %ax,%ax
f010361f:	90                   	nop

f0103620 <__umoddi3>:
f0103620:	55                   	push   %ebp
f0103621:	57                   	push   %edi
f0103622:	56                   	push   %esi
f0103623:	83 ec 20             	sub    $0x20,%esp
f0103626:	8b 44 24 34          	mov    0x34(%esp),%eax
f010362a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010362e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103632:	89 c6                	mov    %eax,%esi
f0103634:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103638:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010363c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0103640:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103644:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0103648:	89 74 24 18          	mov    %esi,0x18(%esp)
f010364c:	85 c0                	test   %eax,%eax
f010364e:	89 c2                	mov    %eax,%edx
f0103650:	75 1e                	jne    f0103670 <__umoddi3+0x50>
f0103652:	39 f7                	cmp    %esi,%edi
f0103654:	76 52                	jbe    f01036a8 <__umoddi3+0x88>
f0103656:	89 c8                	mov    %ecx,%eax
f0103658:	89 f2                	mov    %esi,%edx
f010365a:	f7 f7                	div    %edi
f010365c:	89 d0                	mov    %edx,%eax
f010365e:	31 d2                	xor    %edx,%edx
f0103660:	83 c4 20             	add    $0x20,%esp
f0103663:	5e                   	pop    %esi
f0103664:	5f                   	pop    %edi
f0103665:	5d                   	pop    %ebp
f0103666:	c3                   	ret    
f0103667:	89 f6                	mov    %esi,%esi
f0103669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0103670:	39 f0                	cmp    %esi,%eax
f0103672:	77 5c                	ja     f01036d0 <__umoddi3+0xb0>
f0103674:	0f bd e8             	bsr    %eax,%ebp
f0103677:	83 f5 1f             	xor    $0x1f,%ebp
f010367a:	75 64                	jne    f01036e0 <__umoddi3+0xc0>
f010367c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0103680:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0103684:	0f 86 f6 00 00 00    	jbe    f0103780 <__umoddi3+0x160>
f010368a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010368e:	0f 82 ec 00 00 00    	jb     f0103780 <__umoddi3+0x160>
f0103694:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103698:	8b 54 24 18          	mov    0x18(%esp),%edx
f010369c:	83 c4 20             	add    $0x20,%esp
f010369f:	5e                   	pop    %esi
f01036a0:	5f                   	pop    %edi
f01036a1:	5d                   	pop    %ebp
f01036a2:	c3                   	ret    
f01036a3:	90                   	nop
f01036a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01036a8:	85 ff                	test   %edi,%edi
f01036aa:	89 fd                	mov    %edi,%ebp
f01036ac:	75 0b                	jne    f01036b9 <__umoddi3+0x99>
f01036ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01036b3:	31 d2                	xor    %edx,%edx
f01036b5:	f7 f7                	div    %edi
f01036b7:	89 c5                	mov    %eax,%ebp
f01036b9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01036bd:	31 d2                	xor    %edx,%edx
f01036bf:	f7 f5                	div    %ebp
f01036c1:	89 c8                	mov    %ecx,%eax
f01036c3:	f7 f5                	div    %ebp
f01036c5:	eb 95                	jmp    f010365c <__umoddi3+0x3c>
f01036c7:	89 f6                	mov    %esi,%esi
f01036c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01036d0:	89 c8                	mov    %ecx,%eax
f01036d2:	89 f2                	mov    %esi,%edx
f01036d4:	83 c4 20             	add    $0x20,%esp
f01036d7:	5e                   	pop    %esi
f01036d8:	5f                   	pop    %edi
f01036d9:	5d                   	pop    %ebp
f01036da:	c3                   	ret    
f01036db:	90                   	nop
f01036dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01036e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01036e5:	89 e9                	mov    %ebp,%ecx
f01036e7:	29 e8                	sub    %ebp,%eax
f01036e9:	d3 e2                	shl    %cl,%edx
f01036eb:	89 c7                	mov    %eax,%edi
f01036ed:	89 44 24 18          	mov    %eax,0x18(%esp)
f01036f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01036f5:	89 f9                	mov    %edi,%ecx
f01036f7:	d3 e8                	shr    %cl,%eax
f01036f9:	89 c1                	mov    %eax,%ecx
f01036fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01036ff:	09 d1                	or     %edx,%ecx
f0103701:	89 fa                	mov    %edi,%edx
f0103703:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103707:	89 e9                	mov    %ebp,%ecx
f0103709:	d3 e0                	shl    %cl,%eax
f010370b:	89 f9                	mov    %edi,%ecx
f010370d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103711:	89 f0                	mov    %esi,%eax
f0103713:	d3 e8                	shr    %cl,%eax
f0103715:	89 e9                	mov    %ebp,%ecx
f0103717:	89 c7                	mov    %eax,%edi
f0103719:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010371d:	d3 e6                	shl    %cl,%esi
f010371f:	89 d1                	mov    %edx,%ecx
f0103721:	89 fa                	mov    %edi,%edx
f0103723:	d3 e8                	shr    %cl,%eax
f0103725:	89 e9                	mov    %ebp,%ecx
f0103727:	09 f0                	or     %esi,%eax
f0103729:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010372d:	f7 74 24 10          	divl   0x10(%esp)
f0103731:	d3 e6                	shl    %cl,%esi
f0103733:	89 d1                	mov    %edx,%ecx
f0103735:	f7 64 24 0c          	mull   0xc(%esp)
f0103739:	39 d1                	cmp    %edx,%ecx
f010373b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010373f:	89 d7                	mov    %edx,%edi
f0103741:	89 c6                	mov    %eax,%esi
f0103743:	72 0a                	jb     f010374f <__umoddi3+0x12f>
f0103745:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0103749:	73 10                	jae    f010375b <__umoddi3+0x13b>
f010374b:	39 d1                	cmp    %edx,%ecx
f010374d:	75 0c                	jne    f010375b <__umoddi3+0x13b>
f010374f:	89 d7                	mov    %edx,%edi
f0103751:	89 c6                	mov    %eax,%esi
f0103753:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0103757:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010375b:	89 ca                	mov    %ecx,%edx
f010375d:	89 e9                	mov    %ebp,%ecx
f010375f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103763:	29 f0                	sub    %esi,%eax
f0103765:	19 fa                	sbb    %edi,%edx
f0103767:	d3 e8                	shr    %cl,%eax
f0103769:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010376e:	89 d7                	mov    %edx,%edi
f0103770:	d3 e7                	shl    %cl,%edi
f0103772:	89 e9                	mov    %ebp,%ecx
f0103774:	09 f8                	or     %edi,%eax
f0103776:	d3 ea                	shr    %cl,%edx
f0103778:	83 c4 20             	add    $0x20,%esp
f010377b:	5e                   	pop    %esi
f010377c:	5f                   	pop    %edi
f010377d:	5d                   	pop    %ebp
f010377e:	c3                   	ret    
f010377f:	90                   	nop
f0103780:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103784:	29 f9                	sub    %edi,%ecx
f0103786:	19 c6                	sbb    %eax,%esi
f0103788:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010378c:	89 74 24 18          	mov    %esi,0x18(%esp)
f0103790:	e9 ff fe ff ff       	jmp    f0103694 <__umoddi3+0x74>
